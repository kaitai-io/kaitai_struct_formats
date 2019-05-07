import typing
from os import environ
from pathlib import Path
from collections import defaultdict

ctors = {"WORKSPACE": Path, "WORKFLOW": Path, "HOME": Path}


def postprocessEnviron(e):
	for k in tuple(e):
		if k in ctors:
			ctor = ctors[k]
		elif k.endswith("_PATH"):
			ctor = Path
		else:
			continue
		e[k] = ctor(e[k])


def filterEnviron():
	pfxes = ("GITHUB", "ACTIONS", "INPUT")
	res = defaultdict(dict)
	for pfx in pfxes:
		pfx_ = pfx + "_"
		l = len(pfx_)
		res[pfx] = {k[l:]: v for k, v in environ.items() if k[:l] == pfx_}
	for k in ("HOME",):
		res[k] = environ[k]
	return res


def getGHEnv():
	r = filterEnviron()
	for d in r.values():
		postprocessEnviron(d)
	return r
