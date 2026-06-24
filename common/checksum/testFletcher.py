import array
import struct
import unittest
from math import floor, sqrt

from kaitaistruct import KaitaiStream

from adler32 import Adler32
from fletcher import Fletcher


class DummyKaitaiStream(KaitaiStream):
	def __init__(self):
		super().__init__(None)

	def seek(self, n):
		pass

	def pos(self):
		return 0

	def read_bytes(self, n):
		return None


def fletcherInnerLoop(c0, c1, j, Root, blockSize, data1):

	inner = Fletcher.FletcherInner(j, blockSize, _io=DummyKaitaiStream(), _parent=Parent, _root=Root)

	c0 = inner.c0
	c1 = inner.c1
	return c0, c1, j


def fletcher(byteness, data: bytes):
	f = Fletcher(byteness, data, _io=DummyKaitaiStream())
	return f.value


def adler32(data: bytes):
	f = Adler32(data, _io=DummyKaitaiStream())
	return f.value


def fletcher16(data: bytes):
	return fletcher(1, data)


def padWithZerosToFullBlocks(letter: str, data: bytes):
	byteSize = struct.calcsize(letter)
	residualMask = byteSize - 1
	roundedMask = ~residualMask
	roundedSize = len(data) & roundedMask
	residualBytes = len(data) & residualMask
	b = array.ArrayType(letter)
	b.frombytes(data[:roundedSize])
	if residualBytes:
		paddedRes = data[-residualBytes:] + b"\0" * (byteSize - residualBytes)
		resEl = struct.unpack("<" + letter, paddedRes)[0]
		b.append(resEl)
	# print([hex(el) for el in b])
	return byteSize, b


def fletcher32(data: bytes):
	byteSize, dataPadded = padWithZerosToFullBlocks("H", data)
	return fletcher(byteSize, dataPadded)


def fletcher64(data: bytes):
	byteSize, dataPadded = padWithZerosToFullBlocks("I", data)
	return fletcher(byteSize, dataPadded)


def getMaxIterCountWithoutModulo(a: int, modulus: int, accumulatorBitness: int) -> int:
	b = modulus
	maxMask = (1 << accumulatorBitness) - 1
	return floor((-2 * a + b + sqrt(4 * a**2 - 4 * a * b + b**2 + 8 * b * maxMask)) / (2 * b) - 2)


def getMaxIterCountWithoutModuloAdler32(operandBitness: int, a: int, modulus: int, accumulatorBitness: int):
	return getMaxIterCountWithoutModulo(1, 65521, accumulatorBitness)


def getMaxIterCountWithoutModuloFletcher(operandBitness: int, accumulatorBitness: int):
	return getMaxIterCountWithoutModulo(0, (1 << operandBitness) - 1, accumulatorBitness)


class Tests(unittest.TestCase):
	def testAdler32(self):
		self.assertEqual(adler32(b"abcde"), 96993776)
		self.assertEqual(adler32(b"abcdef"), 136184406)
		self.assertEqual(adler32(b"abcdefgh"), 234881829)

	def testFletcher16(self):
		self.assertEqual(fletcher16(b"abcde"), 0xC8F0)
		self.assertEqual(fletcher16(b"abcdef"), 0x2057)
		self.assertEqual(fletcher16(b"abcdefgh"), 0x0627)

	def testFletcher32(self):
		self.assertEqual(fletcher32(b"abcde"), 0xF04FC729)
		self.assertEqual(fletcher32(b"abcdef"), 0x56502D2A)
		self.assertEqual(fletcher32(b"abcdefgh"), 0xEBE19591)

	def testFletcher64(self):
		self.assertEqual(fletcher64(b"abcde"), 0xC8C6C527646362C6)
		self.assertEqual(fletcher64(b"abcdef"), 0xC8C72B276463C8C6)


if __name__ == "__main__":
	unittest.main()
