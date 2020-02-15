import typing


def val_(v, vals, issues: typing.Iterable[str]):
	if isinstance(vals, tuple):
		validate(v, vals[0], vals[1], issues)
	elif callable(vals):
		vals(v, issues)


def mandatoryValFc(v, vals, issues: typing.Iterable[str]):
	for n, val in vals.items():
		if n not in v:
			issues.append(n + " is mandatory")
		else:
			val_(v[n], val, issues)


def nonMandatoryValFc(v, vals, issues: typing.Iterable[str]):
	for n, val in vals.items():
		if n in v:
			val_(v[n], val, issues)


def validate(dic, mandatory, nonMandatory, issues: typing.Iterable[str]):
	mandatoryValFc(dic, mandatory, issues)
	nonMandatoryValFc(dic, nonMandatory, issues)
