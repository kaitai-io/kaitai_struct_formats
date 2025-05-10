#!/usr/bin/python3

import importlib
import json
import sys
from ast import literal_eval
from csv import DictReader, excel_tab
from pathlib import Path

import crc_tabulated_generic
import ruamel.yaml
from crc_gen_table import CrcGenTable
from kaitaistruct import KaitaiStream
from tqdm.auto import tqdm

testStr = b"123456789"

thisDir = Path(__file__).absolute().resolve().parent
tsvFile = thisDir / "crcs.tsv"
ksyPrototypeFile = thisDir / "8/crc8.ksy"


def literal_eval_1(v: str):
	try:
		return literal_eval(v)
	except Exception:
		print(v)
		raise


class DummyKaitaiStream(KaitaiStream):
	def __init__(self):
		super().__init__(None)

	def seek(self, n):
		pass

	def pos(self):
		return 0

	def read_bytes(self, n):
		return None


def crc8Table(span: bytes, table: bytes):
	c8g = crc8_generic.Crc8Generic(0xFF, table, span, DummyKaitaiStream(), None, None)
	return c8g.value


y = ruamel.yaml.YAML(typ="rt")
y.indent(2, 4, 2)
y.width = 100500


def loadTemplate():
	ks = y.load(ksyPrototypeFile.read_text())
	return ks


ks = loadTemplate()


def crcGenTable(bitLength, poly):
	return tuple(el.value for el in CrcGenTable(bitLength, poly, DummyKaitaiStream()).table)


def readCrcParamsTSV(tsvLines):
	for d in DictReader(tsvLines, dialect=excel_tab):
		d["check_value"] = literal_eval_1(d["check_value"])
		d["xor_out"] = literal_eval_1(d["xor_out"])
		d["polynomial"] = literal_eval_1(d["polynomial"])
		d["init"] = literal_eval_1(d["init"])
		d["size"] = literal_eval_1(d["size"])
		d["reflect_in"] = bool(literal_eval_1(d["reflect_in"]))
		d["reflect_out"] = bool(literal_eval_1(d["reflect_out"]))
		yield d


def loadOurParamsFile():
	return tuple(readCrcParamsTSV(Path(tsvFile).read_text().splitlines()))


def genSpecs(tabulate: bool = True):
	paramsDicts = loadOurParamsFile()
	for d in tqdm(paramsDicts):
		ks["meta"]["id"] = d["id"]
		if d["name"]:
			ks["meta"]["title"] = d["name"] + " variant of CRC-" + str(d["size"])
			ks["doc"] = "Computes " + d["name"] + " variant of " + str(d["size"]) + " of an array."
		else:
			ks["meta"]["title"] = "CRC-" + str(d["size"])
			ks["doc"] = "Computes " + "CRC-" + str(d["size"]) + " of an array."

		ks["meta"]["-initial"] = ruamel.yaml.scalarint.HexInt(d["init"])
		ks["meta"]["-check"] = ruamel.yaml.scalarint.HexInt(d["check_value"])
		ks["meta"]["-polynomial"] = ruamel.yaml.scalarint.HexInt(d["polynomial"])
		ks["meta"]["-reflect_in"] = d["reflect_in"]
		ks["meta"]["-reflect_out"] = d["reflect_out"]

		tabulate = tabulate and d["size"] <= 8
		if tabulate:
			ks["instances"]["table"] = {}
			ks["instances"]["table"]["value"] = repr(list(crcGenTable(d["size"], d["polynomial"])))

			if d["size"] == 8:
				typeName = "crc8_tabulated_generic"
				ks["meta"]["imports"] = ["./" + typeName]
				ks["seq"][0]["type"] = "".join((typeName + "(", (hex(d["init"]) if d["init"] else "0"), ", " + hex(d["xor_out"]) + ", ", json.dumps(d["reflect_in"]) + ", ", json.dumps(d["reflect_out"]) + ", ", "table, ", "array", ")"))
			else:
				typeName = "crc_tabulated_generic"
				ks["meta"]["imports"] = ["../" + typeName]
				ks["seq"][0]["type"] = "".join((typeName + "(", str(d["size"]) + ", ", (hex(d["init"]) if d["init"] else "0"), ", " + hex(d["xor_out"]) + ", ", json.dumps(d["reflect_in"]) + ", ", json.dumps(d["reflect_out"]) + ", ", "table, ", "array", ")"))
		else:
			typeName = "crc_generic"
			ks["meta"]["imports"] = ["../" + typeName]
			if "table" in ks["instances"]:
				del ks["instances"]["table"]

			ks["seq"][0]["type"] = "".join((typeName + "(", str(d["size"]) + ", ", (hex(d["init"]) if d["init"] else "0"), ", " + hex(d["xor_out"]) + ", ", json.dumps(d["reflect_in"]) + ", ", json.dumps(d["reflect_out"]) + ", ", hex(d["polynomial"]) + ", ", "array", ")"))

		fn = thisDir / str(d["size"]) / (d["id"] + ".ksy")
		fn.parent.mkdir(exist_ok=True, parents=True)
		with fn.open("wt") as f:
			y.dump(ks, f)


def crcGenericKSDic(span: bytes, d):
	c8 = crc_generic.CrcGeneric(d["size"], d["init"], d["xor_out"], d["reflect_in"], d["reflect_out"], d["polynomial"], span, DummyKaitaiStream(), None, None)
	return c8.value


def crcSpecializedKSDic(span: bytes, KaitCRCClass):
	c = KaitCRCClass(span, DummyKaitaiStream(), None, None)
	return c.value


def testSpecs():
	oks = []
	nonOks = []

	for d in loadOurParamsFile():
		# name, iD = genIdAndNameFromCrcClass(crcClass)

		m = importlib.import_module(d["id"])
		KaitCRCClass = getattr(m, [el for el in dir(m) if el.startswith("Crc" + str(d["size"]))][0])
		res = crcSpecializedKSDic(b"123456789", KaitCRCClass)

		if d["check_value"] == res:
			oks.append((KaitCRCClass, d["id"], res))
		else:
			nonOks.append((KaitCRCClass, d["id"], res))

	return oks, nonOks


from plumbum import cli


class CLI(cli.Application):
	"""Generates and tests KS specs for computing CRC checksums"""


@CLI.subcommand("gen")
class GenCLI(cli.Application):
	"""Generates KS specs for computing CRC checksums"""

	def main(self):
		genSpecs()


@CLI.subcommand("test")
class TestCLI(cli.Application):
	"""Generates KS specs for computing CRC checksums"""

	def main(self):
		oks, nonOks = testSpecs()
		if nonOks:
			for crcClass, modId, testResult in nonOks:
				print(crcClass, modId, hex(testResult))


if __name__ == "__main__":
	CLI.run()
