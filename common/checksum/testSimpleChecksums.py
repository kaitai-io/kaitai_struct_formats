#!/usr/bin/env python3

import array
import struct
import unittest

from kaitaistruct import KaitaiStream

from checksum_simple_additive_u1 import ChecksumSimpleAdditiveU1
from checksum_simple_additive_u4 import ChecksumSimpleAdditiveU4
from checksum_simple_xor_u4 import ChecksumSimpleXorU4


class DummyKaitaiStream(KaitaiStream):
	def __init__(self):
		super().__init__(None)

	def seek(self, n):
		pass

	def pos(self):
		return 0

	def read_bytes(self, n):
		return None


def splitRoundedResidual(letter: str, data: bytes):
	byteSize = struct.calcsize(letter)
	residualMask = byteSize - 1
	roundedMask = ~residualMask
	roundedSize = len(data) & roundedMask
	residualBytes = len(data) & residualMask
	return byteSize, data[:roundedSize], data[roundedSize:]


def padWithZerosToFullBlocksLE(letter: str, data: bytes):
	byteSize, rounded, residual = splitRoundedResidual(letter, data)
	b = array.ArrayType(letter)
	b.frombytes(rounded)
	if residual:
		paddedRes = residual + b"\0" * (byteSize - len(residual))
		resEl = struct.unpack("<" + letter, paddedRes)[0]
		b.append(resEl)
	return byteSize, b


def padWithZerosToFullBlocksBE(letter: str, data: bytes):
	byteSize, rounded, residual = splitRoundedResidual(letter, data)
	b = array.ArrayType(letter)
	b.frombytes(rounded)

	s = struct.Struct("<" + str(len(rounded) // byteSize) + letter)
	b = array.array(letter, s.unpack(rounded))

	if residual:
		paddedRes = b"\0" * (byteSize - len(residual)) + residual
		resEl = struct.unpack(">" + letter, paddedRes)[0]
		b.append(resEl)
	return byteSize, b


def calcAdditiveChecksum8(init, data) -> int:
	c = ChecksumSimpleAdditiveU1(init, data, DummyKaitaiStream())
	return c.value


def calcChecksum32(init, data) -> int:
	byteSize, dataPadded = padWithZerosToFullBlocksLE("I", data)
	c = ChecksumSimpleU4(init, dataPadded, DummyKaitaiStream())
	return c.value


def calcCABChecksum(init, data) -> int:
	byteSize, dataPadded = padWithZerosToFullBlocksBE("I", data)
	c = ChecksumSimpleXorU4(init, dataPadded, DummyKaitaiStream())
	return c.value


class Tests(unittest.TestCase):
	def testAdditive8(self):
		assert calcAdditiveChecksum8(0xFF, b"abcde") == 238
		assert calcAdditiveChecksum8(0xFF, b"abcdef") == 84
		assert calcAdditiveChecksum8(0xFF, b"abcdefgh") == 35
		assert calcAdditiveChecksum8(0xFF, bytes(range(256))) == 127

		assert calcAdditiveChecksum8(0, b"abcde") == 239
		assert calcAdditiveChecksum8(0, b"abcdef") == 85
		assert calcAdditiveChecksum8(0, b"abcdefgh") == 36
		assert calcAdditiveChecksum8(0, bytes(range(256))) == 128

	def testCAB(self):
		assert calcCABChecksum(0, b"abcde") == 0x64636204
		assert calcCABChecksum(0, b"abcdef") == 0x64630707
		assert calcCABChecksum(0, b"abcdefgh") == 0xC040404
		assert calcCABChecksum(0, bytes(range(256))) == 0x0

		assert calcCABChecksum(0xFF, b"abcde") == 0x646362FB
		assert calcCABChecksum(0xFF, b"abcdef") == 0x646307F8
		assert calcCABChecksum(0xFF, b"abcdefgh") == 0xC0404FB
		assert calcCABChecksum(0xFF, bytes(range(256))) == 0xFF

		assert calcCABChecksum(0xFFFFFFFF, b"abcde") == 0x9B9C9DFB
		assert calcCABChecksum(0xFFFFFFFF, b"abcdef") == 0x9B9CF8F8
		assert calcCABChecksum(0xFFFFFFFF, b"abcdefgh") == 0xF3FBFBFB
		assert calcCABChecksum(0xFFFFFFFF, bytes(range(256))) == 0xFFFFFFFF


if __name__ == "__main__":
	unittest.main()
