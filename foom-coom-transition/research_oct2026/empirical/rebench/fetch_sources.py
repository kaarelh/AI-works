#!/usr/bin/env python3
"""Optional: refetch exactly the four frozen public sources; reject changed bytes.
The analysis itself is offline. Existing files are not overwritten on mismatch.
"""
from pathlib import Path
import hashlib,json,urllib.request
root=Path(__file__).resolve().parent/'source'
for row in json.loads((root/'manifest.json').read_text()):
    data=urllib.request.urlopen(row['url'],timeout=60).read()
    actual=hashlib.sha256(data).hexdigest()
    if actual != row['sha256']:
        raise ValueError(f"Source changed: {row['url']} expected {row['sha256']} got {actual}")
    (root/row['file']).write_bytes(data)
    print(row['file'],len(data),'verified')
