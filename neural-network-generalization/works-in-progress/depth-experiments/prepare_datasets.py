"""Fetch/reconstruct public data, checking the already published source hashes."""
from pathlib import Path
import hashlib,json,subprocess,sys

ROOT=Path(__file__).resolve().parent
manifest=ROOT/'experiment/data/source-manifest.json'
expected_bytes=manifest.read_bytes();expected=json.loads(expected_bytes)
try:
    subprocess.run([sys.executable,str(ROOT/'experiment/download_datasets.py')],check=True)
    for row in expected:
        path=ROOT/'experiment/data'/row['file']
        assert path.stat().st_size==row['bytes'],row['file']
        assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256'],row['file']
finally:
    manifest.write_bytes(expected_bytes)
print(json.dumps({'all_source_hashes_match':True,'checked_compressed_files':len(expected)}))
