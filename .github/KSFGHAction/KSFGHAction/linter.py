import typing
import re

from .validator import *
from .utils import *


idRxText = "[a-z][\\da-z_]*[\\da-z]"
idRx = re.compile(idRxText)


class metaMandatory(metaclass=ClassDictMeta):
	def id(v, issues):
		if not idRx.match(v):
			issues.append("Id must match " + idRxText)

	def title(v, issues):
		pass


class rootLevelMandatory(metaclass=ClassDictMeta):
	meta = ((metaMandatory, None),)

	def doc(v, issues):
		pass


def validateDocRef(v, issues):
	pass


rootLevelMandatory["doc-ref"] = validateDocRef


def lintKSYStub(stub) -> typing.Iterable[str]:
	issues = []
	validate(stub, rootLevelMandatory, {}, issues)
	return issues
