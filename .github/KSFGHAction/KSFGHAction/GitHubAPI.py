import typing
import requests

try:
	import ujson as json
except ImportError:
	import json


GH_API_BASE = "https://api.github.com/"


class GHApiObj_:
	__slots__ = ()

	@property
	def prefix(self) -> str:
		raise NotImplementedError()

	def req(self, path, obj):
		raise NotImplementedError()


class GHAPI(GHApiObj_):
	__slots__ = ("token",)

	def __init__(self, token):
		self.token = token

	@property
	def prefix(self) -> str:
		return GH_API_BASE

	def req(self, path, obj):
		res = requests.post(self.prefix + path, json.dumps(obj), headers={"Authorization": "Bearer " + self.token, "Content-Type": "application/json"})
		res.raise_for_status()
		return res.json()

	def repo(self, owner: str, repo: str):
		return Repo(self, owner, repo)


class GHApiObj(GHApiObj_):
	__slots__ = ("parent",)

	def __init__(self, parent):
		self.parent = parent

	def req(self, path, obj):
		return self.parent.req(self.prefix + path, obj)


class Repo(GHApiObj):
	__slots__ = ("owner", "repo")

	def __init__(self, parent, owner: str, repo: str):
		super().__init__(parent)
		self.owner = owner
		self.repo = repo

	@property
	def prefix(self) -> str:
		return "repos/" + self.owner + "/" + self.repo + "/"

	def issue(self, no: int):
		return Issue(self, no)


class Issue(GHApiObj):
	__slots__ = ("no",)

	def __init__(self, parent, no: int):
		super().__init__(parent)
		self.no = no

	@property
	def prefix(self) -> str:
		return "issues/" + str(self.no) + "/"

	def leaveAComment(self, body: str):
		self.req("comments", {"body": str(body)})

	def setLabels(self, labels: typing.Iterable[str]):
		self.req("labels", {"labels": list(labels)})
