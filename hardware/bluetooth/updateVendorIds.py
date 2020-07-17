#!/usr/bin/env python3

__license__ = "Unlicense"

import typing
import keyword
import re
import unicodedata
from collections import defaultdict
from pathlib import Path

import bs4
import httpx
import inflect
import inflection
import ruamel.yaml

VENDORS_IDS_SOURCE_URI = "https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/"
VENDORS_IDS_KSY_FILE_NAME = "bluetooth_vendors_ids.ksy"
VENDORS_IDS_CACHE_FILE_NAME = "company-identifiers.html"

yaml = ruamel.yaml.YAML()
yaml.indent(mapping=2, sequence=4, offset=2)

inflEng = inflect.engine()


def findPredecessor(node: bs4.element.Tag, predicate: typing.Callable) -> bs4.element.Tag:
	n = node
	while not predicate(n):
		if not n:
			raise KeyError("Matching predecessor found")
		n = n.parent
	return n


def locateTableAndExtractHead(doc: bs4.BeautifulSoup) -> typing.Tuple[bs4.element.Tag, typing.Iterable[str]]:
	vidTh = next(el for el in doc.select("th") if el.text.strip() == "VendorId")
	tableHeadRowNode = findPredecessor(vidTh, lambda n: n.name == "tr")
	head = tuple(el.text.strip() for el in tableHeadRowNode.select("th"))

	return findPredecessor(vidTh, lambda n: n.name == "table"), head


alphaNumRx = re.compile("[a-zA-Z0-9_ ]+")
chainedUnderscoreRx = re.compile("_+")
leadingDigitsRx = re.compile(r"^(\d+)")
pythonKeywordsList = set(keyword.kwlist)


def fixLeadingDigits(s: str) -> str:
	return leadingDigitsRx.sub(inflEng.number_to_words, s)


def dechainUnderscores(s: str) -> str:
	return chainedUnderscoreRx.subn("_", s)[0]


def filterNonAlphaNum(s: str) -> str:
	return "_".join(alphaNumRx.findall(s))


corpPostfixes = ("gmb_h", "inc", "ltd", "co", "ag", "company", "corporation", "limited", "ab", "llc", "bv", "b_v", "a_s", "group", "s_a", "gmbh", "gmb_h", "kg", "s_r_o", "corp", "z_o_o", "s_r_l", "s_p_a", "srl", "pty", "llp", "ap_s", "sr_l", "sp_a", "s_l", "sas", "asa", "oy", "pte", "private", "sa", "se", "incorporated", "sp", "as", "n_v", "lda", "kft", "bvba", "spol", "spa", "aps", "pvt", "ltda", "snc", "uab", "d_o_o", "sarl", "plc", "nv", "ogh", "ohg", "sl", "oyj", "sdn", "bhd", "and", "ga_a", "hf", "l_imited", "co_k", "s")


def depostfixCorpName(s: str) -> str:
	postfixFound = 1
	while postfixFound:
		postfixFound = 0
		for postfix in corpPostfixes:
			if len(s) > len(postfix) + 1 and s[-len(postfix) - 1] == "_" and s[-len(postfix) :] == postfix:
				s = s[: -len(postfix) - 1]
				postfixFound += 1
	return s


def transformCompanyName(s: str) -> str:
	s = "".join([c for c in unicodedata.normalize("NFKD", s) if not unicodedata.combining(c)])
	s = inflection.underscore(s).lower()
	s = fixLeadingDigits(s)
	s = filterNonAlphaNum(s).replace(" ", "_")
	s = dechainUnderscores(s)
	s = depostfixCorpName(s)
	if s[-1] == "_":
		s = s[:-1]
	if s[0] == "_":
		s = s[1:]
	if s in pythonKeywordsList:
		s += "_"
	return s


formerlyRx = re.compile("^(?P<currentName>.+?)\s+\\(?formerly(?:\s+as|:)?\s+(?P<formerNames>[^\\)]+)\\)?$")


def parseTable(tableNode: bs4.element.Tag, head: typing.Iterable[str]) -> typing.Iterator[typing.Tuple[str, int]]:
	rows = tableNode.select("tr")
	for row in rows:
		cols = row.select("TD")
		if cols:
			rowRes = {k: col.text.strip() for k, col in zip(head, cols)}
			rowRes["Decimal"] = int(rowRes["Decimal"])
			rowRes["Hexadecimal"] = int(rowRes["Hexadecimal"][2:], 16)
			if rowRes["Decimal"] != rowRes["Hexadecimal"]:
				print("Problems with ", rowRes, "dec != hex")

			rawName = rowRes["Company"]
			m = formerlyRx.match(rawName)
			formerName = None
			if m:
				#formerName = m.group("formerNames").split(" and ")
				currentName = m.group("currentName")
			else:
				currentName = rawName

			yield transformCompanyName(currentName), ruamel.yaml.scalarint.HexInt(rowRes["Hexadecimal"])


def deduplicateAndSwap(maps: typing.Iterable[typing.Tuple[str, int]]) -> typing.Iterable[typing.Tuple[int, str]]:
	occurrences = defaultdict(list)
	for k, v in maps:
		occurrences[k].append(v)

	for k, l in occurrences.items():
		if len(l) == 1:
			for v in l:
				yield v, k
		else:
			for v in l:
				yield v, k + "_" + hex(v)[2:]


def parseVendors(doc: bs4.BeautifulSoup) -> typing.Mapping[int, str]:
	table, head = locateTableAndExtractHead(doc)
	return ruamel.yaml.comments.CommentedMap(sorted(deduplicateAndSwap(parseTable(table, head)), key=lambda x: x[0]))


thisDir = Path(__file__).absolute().parent


def genVendorsTable() -> typing.Mapping[int, str]:
	cacheFile = Path(thisDir / VENDORS_IDS_CACHE_FILE_NAME)
	if not cacheFile.is_file():
		q = httpx.get(VENDORS_IDS_SOURCE_URI, headers={"User-Agent": None})
		data = q.text
		del q
		cacheFile.write_text(data, encoding="utf-8")
	else:
		data = cacheFile.read_text(encoding="utf-8")
	d = bs4.BeautifulSoup(data, "lxml")
	return parseVendors(d)


def main() -> None:
	vendorsTable = genVendorsTable()

	fileName = thisDir / VENDORS_IDS_KSY_FILE_NAME
	with fileName.open("rt", encoding="utf-8") as f:
		ksy = yaml.load(f)

	ksy["doc-ref"] = VENDORS_IDS_SOURCE_URI
	ksy["enums"]["vendor"] = vendorsTable

	with fileName.open("wt", encoding="utf-8") as f:
		yaml.dump(ksy, f)


if __name__ == "__main__":
	main()
