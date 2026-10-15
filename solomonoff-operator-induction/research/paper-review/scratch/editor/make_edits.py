"""Assemble the merged issue lists (edits/*.json) and rejected.json; check that every reviewer issue is covered."""
import json, glob, sys, os, importlib.util
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))   # research/paper-review
def load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(HERE, name + '.py'))
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
groups = {}
for mod in ['edits_p1_front', 'edits_p1_setting', 'edits_p1_histex', 'edits_p1_ood', 'edits_p2_body', 'edits_p2_front']:
    m = load(mod); groups[m.G] = m.ISSUES
rej = load('edits_rejected').REJECTED
# originals
orig = {}
for f in sorted(glob.glob(os.path.join(ROOT, 'p1', 'issues-*.json'))) + sorted(glob.glob(os.path.join(ROOT, 'p2', 'issues-*.json'))):
    for i in json.load(open(f)):
        orig.setdefault(i['id'], []).append((os.path.relpath(f, ROOT), i['severity']))
covered = set()
ids = set()
for g, lst in groups.items():
    for it in lst:
        assert it['id'] not in ids, it['id']; ids.add(it['id'])
        for s in it['sources']:
            assert s in orig, (it['id'], s)
            covered.add(s)
        for k in ['id', 'file', 'label_or_line', 'severity', 'problem', 'evidence', 'fix', 'verdict', 'sources']:
            assert k in it and it[k], (it['id'], k)
        assert it['severity'] in ('fatal', 'major', 'minor')
rcov = set()
for r in rej:
    for s in r['sources']:
        assert s in orig, (r['id'], s); rcov.add(s)
missing = sorted(set(orig) - covered - rcov)
print('original ids:', len(orig), 'records:', sum(len(v) for v in orig.values()))
print('covered by merged:', len(covered), 'only in rejected:', len(rcov - covered), 'missing:', missing)
os.makedirs(os.path.join(ROOT, 'edits'), exist_ok=True)
total = {}
for g, lst in groups.items():
    out = []
    for it in lst:
        sev_orig = sorted({s for src in it['sources'] for (_, s) in orig[src]})
        out.append(dict(id=it['id'], group=g, file=it['file'], label_or_line=it['label_or_line'], severity=it['severity'],
                        problem=it['problem'], evidence=it['evidence'], fix=it['fix'], verdict=it['verdict'],
                        source_ids=it['sources'], reviewer_severities=sev_orig))
    order = {'fatal': 0, 'major': 1, 'minor': 2}
    out.sort(key=lambda x: (order[x['severity']], x['id']))
    json.dump(out, open(os.path.join(ROOT, 'edits', g + '.json'), 'w'), indent=1, ensure_ascii=False)
    c = {s: sum(1 for x in out if x['severity'] == s) for s in ('fatal', 'major', 'minor')}
    total[g] = c
    print(f'{g:12s} {len(out):3d} issues  {c}')
json.dump([dict(id=r['id'], source_ids=r['sources'], file=r['file'], label_or_line=r['label_or_line'],
                severity_proposed=r['severity_proposed'], proposal=r['proposal'], reason=r['reason']) for r in rej],
          open(os.path.join(ROOT, 'edits', 'rejected.json'), 'w'), indent=1, ensure_ascii=False)
print('rejected entries:', len(rej))
json.dump(total, open(os.path.join(HERE, 'counts.json'), 'w'), indent=1)
if missing: sys.exit(1)
