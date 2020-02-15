#!/usr/bin/env python3

import typing
from . import *
from plumbum import cli

from datetime import datetime
from pprint import pprint
from pathlib import Path
from dateutil.parser import parse as parseDate


class CLI(cli.Application):
	@classmethod
	def generateIssuesMessage(cls, issues):
		return "Your header has the following issues:\n" + "\n".join(issues)

	invalidLabel = "invalid"

	def main(self):
		env = getGHEnv()
		gh = env["GITHUB"]
		inpV = env["INPUT"]
		e = json.loads(gh["EVENT_PATH"].read_text())
		#pprint(e)
		i = e["issue"]
		id = i["id"]
		no = i["number"]
		b = i["body"]
		l = i["locked"]
		c = parseDate(i["created_at"])
		up = parseDate(i["updated_at"])
		u = i["user"]
		r = e["repository"]
		rn = r["name"]
		ro = r["owner"]
		rol = ro["login"]
		lblz = set(i["labels"])

		#print(e["action"], "c", c, "up", up, u["login"], i["state"], lblz)
		ksyStub, otherMetadata = parseHeaders(b)
		ksyStubIssues = lintKSYStub(ksyStub)

		api = GHAPI(inpV["GITHUB_TOKEN"])
		#api = GHAPI(inpV["secrets.GITHUB_TOKEN"])
		repO = api.repo(rol, rn)
		issueO = repO.issue(no)

		invalidLabel = self.invalidLabel

		if ksyStubIssues:
			if invalidLabel not in lblz:
				issueO.setLabels(lblz | {invalidLabel})
				issueO.leaveAComment(self.__class__.generateIssuesMessage(ksyStubIssues))
			else:
				pass  # todo: parse the issues and diff them
		else:
			if invalidLabel in lblz:
				issueO.setLabels(lblz - {invalidLabel})
				issueO.leaveAComment("The issues have been fixed. Thanks.")
			else:
				pass  # everything is OK

		#pprint(ksyStub)
		#print(ksyStubIssues)
		#pprint(otherMetadata)


if __name__ == "__main__":
	CLI.run()
