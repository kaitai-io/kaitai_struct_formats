import typing
from ruamel.yaml import YAML
import commonmark


def crawl(root, predicate: typing.Callable):
	for n, entered in root.walker():
		if predicate(n):
			yield n


def parseHeaders(text: str):
	parser = commonmark.Parser()
	parsed = parser.parse(text)

	def isSuitableCodeBlock(n):
		return n.t == "code_block" and n.info == "yaml"

	res = list(crawl(parsed, isSuitableCodeBlock))[:2]
	res1 = []
	for b in res:
		parser = YAML(typ="safe")
		yaml = parser.load(b.literal)
		res1.append(yaml)

	return res1
