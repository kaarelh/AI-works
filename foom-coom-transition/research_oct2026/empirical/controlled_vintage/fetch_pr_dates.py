#!/usr/bin/env python3
"""Freeze compact primary GitHub PR metadata for record date validation."""
import urllib.request, pathlib, json, hashlib, re
from concurrent.futures import ThreadPoolExecutor
BASE=pathlib.Path(__file__).resolve().parent
text=(BASE/'README.upstream.md').read_text().split('## Rules')[0]
needed={int(x) for x in re.findall(r'/pull/(\d+)',text)}
def fetch(page):
    url=f'https://api.github.com/repos/KellerJordan/modded-nanogpt/pulls?state=closed&sort=created&direction=desc&per_page=100&page={page}'
    raw=urllib.request.urlopen(url,timeout=90).read()
    return json.loads(raw),dict(url=url,sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw))
fields=['number','title','created_at','merged_at','closed_at','updated_at','merge_commit_sha','html_url']
records=[];manifest=[]
with ThreadPoolExecutor(max_workers=4) as pool:
    for data,meta in pool.map(fetch,range(1,5)):
        manifest.append(meta)
        records.extend({k:p[k] for k in fields} for p in data if p['number'] in needed)
records.sort(key=lambda p:p['number'])
(BASE/'pr_metadata.json').write_text(json.dumps(records,indent=2)+'\n')
(BASE/'pr_metadata_manifest.json').write_text(json.dumps(dict(query_responses=manifest,projection_fields=fields,missing_prs=sorted(needed-{p['number'] for p in records})),indent=2)+'\n')
print('matched',len(records),'missing',needed-{p['number'] for p in records})
for p in records[-5:]: print(p['number'],p['created_at'],p['merged_at'])
