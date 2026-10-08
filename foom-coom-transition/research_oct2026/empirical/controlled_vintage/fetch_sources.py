#!/usr/bin/env python3
"""Fetch pinned, public source files; analysis itself runs offline."""
import urllib.request, pathlib, json, hashlib, datetime
BASE=pathlib.Path(__file__).resolve().parent
SHA="4ea6b937337a4889b8cfe3f38a93d120048d8f71"
ROOT="https://raw.githubusercontent.com/KellerJordan/modded-nanogpt/"+SHA+"/"
FILES={"README.upstream.md":"README.md", "source_tree.json":"https://api.github.com/repos/KellerJordan/modded-nanogpt/git/trees/"+SHA+"?recursive=1"}
manifest=[]
for dest, source in FILES.items():
    url=source if source.startswith("https:") else ROOT+source
    content=urllib.request.urlopen(url,timeout=90).read()
    BASE.joinpath(dest).write_bytes(content)
    manifest.append(dict(file=dest,url=url,sha256=hashlib.sha256(content).hexdigest(),bytes=len(content)))
BASE.joinpath("source_manifest.json").write_text(json.dumps(dict(commit=SHA,downloaded_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),files=manifest),indent=2)+"\n")
print(json.dumps(manifest,indent=2))
