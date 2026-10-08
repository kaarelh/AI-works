#!/usr/bin/env python3
"""Download a compact, explicitly selected log audit, not all successful runs."""
import hashlib
import json
import pathlib
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE = pathlib.Path(__file__).resolve().parent
SHA = "4ea6b937337a4889b8cfe3f38a93d120048d8f71"
PREFIX = "records/track_1_short/"
PATHS = [
    "2025-01-26_BatchSize/c44090cc-1b99-4c95-8624-38fb4b5834f9.txt",
    "2025-02-01_RuleTweak/eff63a8c-2f7e-4fc5-97ce-7f600dae0bc7.txt",
    "2025-05-24_StableTorch/89d9f224-3b01-4581-966e-358d692335e0.txt",
    "2026-08-30_ANVIL2/README.md",
    "2026-08-30_ANVIL2/this_pr/statistics.md",
    "2026-08-30_ANVIL2/baseline/statistics.md",
    "2026-08-30_ANVIL2/this_pr/01b2f094-4536-479c-b0dd-cb14eba4844c.txt",
    "2026-08-30_ANVIL2/baseline/085f1982-3a55-4070-aed5-2e7921c53728.txt",
]

def fetch(path):
    url = f"https://raw.githubusercontent.com/KellerJordan/modded-nanogpt/{SHA}/{PREFIX}{path}"
    content = urllib.request.urlopen(url, timeout=90).read()
    out = BASE / "source_logs" / path
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(content)
    return dict(file=str(out.relative_to(BASE)), url=url,
                sha256=hashlib.sha256(content).hexdigest(), bytes=len(content))

if __name__ == "__main__":
    with ThreadPoolExecutor(max_workers=4) as pool:
        manifest = list(pool.map(fetch, PATHS))
    (BASE / "audit_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps(manifest, indent=2))
