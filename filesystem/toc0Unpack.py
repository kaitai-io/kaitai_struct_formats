#!/usr/bin/env python3

import sys
from pathlib import Path

import fsutilz

from sunxi_toc0 import SunxiToc0


def main():
	curDir = Path(".").resolve().absolute()

	for fn in sys.argv[1:]:
		fileName = Path(fn).resolve().absolute()
		extractedDir = (fileName.parent / ("_" + fileName.stem + ".extracted")).absolute()  # binwalk convention

		f = SunxiToc0.from_file(fileName)
		unpTgts = []
		for i, el in enumerate(f.items):
			extrFilePath = (extractedDir / (str(i) + "_" + el.name)).resolve().absolute()
			if not fsutilz.isNestedIn(extractedDir, extrFilePath):
				raise ValueError("Path traversal attampt: ", el.name)
			unpTgts.append((extrFilePath, el))
		del f

		extractedDir.mkdir(exist_ok=True)

		for extrFilePath, el in unpTgts:
			extrFilePath.write_bytes(el.payload)


if __name__ == "__main__":
	main()
