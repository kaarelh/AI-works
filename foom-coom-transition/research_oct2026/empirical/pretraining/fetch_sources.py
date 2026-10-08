#!/usr/bin/env python3
"""Optional network refresh from immutable URLs; refuse any changed bytes."""
from pathlib import Path
import concurrent.futures
import hashlib
import json
import urllib.request

root = Path(__file__).resolve().parent / "sources"
manifest = json.loads((root / "manifest.json").read_text())

def fetch(item):
    request = urllib.request.Request(item["url"], headers={"User-Agent":"empirical-research-audit/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read(1_000_001)
    assert len(data) <= 1_000_000, "Unexpectedly large metadata file"
    assert hashlib.sha256(data).hexdigest() == item["sha256"], item["file"]
    path = root / item["file"]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return item["file"]

if __name__ == "__main__":
    with concurrent.futures.ThreadPoolExecutor(6) as pool:
        for name in pool.map(fetch, manifest["files"]):
            print(name)
