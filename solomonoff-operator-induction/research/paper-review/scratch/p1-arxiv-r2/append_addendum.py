"""Append the second pass's unique findings to the canonical p1/review-p1-arxiv.md and p1/issues-p1-arxiv.json
(written first by a concurrent pass with ids P1X-nn). Additive only: nothing in the canonical files is changed."""
import json, os, sys
P1 = '/home/user/AI-works/solomonoff-function-induction/research/paper-review/p1/'
mine = {x['id']: x for x in json.load(open('issues-p1-arxiv.json', encoding='utf8'))}
REL = {
 'P1-ARX-03': 'Not in the P1X list (its table marks the Eisenstat sentence of the introduction OK). ',
 'P1-ARX-04': 'Not in the P1X list (its row A10 marks the abstract sentence OK). ',
 'P1-ARX-05': 'Not in the P1X list; concerns the ledger from which the introduction was written. ',
 'P1-ARX-25': 'Corrects P1X-32: the repository does exist. ',
 'P1-ARX-26': 'Complements P1X-09 and P1X-31, which do not address the process vocabulary of the acknowledgements paragraph. ',
 'P1-ARX-34': '',
 'P1-ARX-36': '',
 'P1-ARX-38': 'Applies only if rem:nn:rigorous is kept (P1X-33 proposes deleting it). ',
 'P1-ARX-41': 'Complements P1X-48: two fields that P1X-48 leaves unconfirmed are now confirmed. ',
 'P1-ARX-43': '',
 'P1-ARX-44': '',
 'P1-ARX-45': 'A special case of P1X-08 that a macro redefinition does not catch (the tags sit inside table floats). ',
 'P1-ARX-46': '',
 'P1-ARX-47': '',
}
add = []
for k, rel in REL.items():
    x = dict(mine[k])
    x['problem'] = ('[Second pass] ' + rel + x['problem']).strip()
    add.append(x)
# --- JSON
jpath = P1 + 'issues-p1-arxiv.json'
cur = json.load(open(jpath, encoding='utf8'))
ids = {x['id'] for x in cur}
if any(x['id'] in ids for x in add):
    sys.exit('already appended')
cur.extend(add)
with open(jpath, 'w', encoding='utf8') as f:
    json.dump(cur, f, indent=1, ensure_ascii=False)
# --- markdown addendum
sev = {}
for x in cur: sev[x['severity']] = sev.get(x['severity'], 0) + 1
lines = ['', '---', '',
 '## Addendum: findings of a second independent pass (ids P1-ARX-nn)', '',
 'A second reviewer ran the same brief at the same time. Its full report is `p1/review-p1-arxiv-pass2.md` (with `p1/issues-p1-arxiv-pass2.json`; checks in `scratch/p1-arxiv-r2/`). The two passes agree on every point they both cover. This addendum lists only what the second pass adds; the same 14 issues are appended to `issues-p1-arxiv.json`.',
 f'Combined counts in `issues-p1-arxiv.json`: {len(cur)} issues ({sev.get("fatal",0)} fatal, {sev.get("major",0)} major, {sev.get("minor",0)} minor).', '',
 '**Bibliography corrections to section 5:**', '',
 '* **`hanni2026notes`: the repository exists**, so the entry is fixable, not unverifiable. WebFetch of github.com/kaarelh/notes shows a public MIT-licensed repository described as "some of my notes from 2023–2026". The SFI note is `ai/learning/solomonoff induction/solomonoff function induction.md` (with a `.pdf`), and the same folder holds "polytime solomonoff (response to lucius).md". Suggested entry: `title={Solomonoff Function Induction}, howpublished={Note in the repository \\url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year={2026}`.',
 '* **`day2011increasing`: volume and pages confirmed.** An extended WebSearch returns the AMS issue listing for Trans. Amer. Math. Soc. 363(10) with "Increasing the gap between descriptional complexity and algorithmic probability: Adam R. Day. Trans. Amer. Math. Soc. 363 (2011), 5577-5604". Add `volume={363}, number={10}, pages={5577--5604}`.',
 '* **`orseau2013universal`: volume confirmed.** Springer lists the ALT 2013 proceedings (eds. Jain, Munos, Stephan, Zeugmann) as Lecture Notes in Computer Science volume 8139 (LNAI subseries). Add `volume={8139}`.', '',
 '**Additional issues:**', '']
for x in add:
    lines += [f"**{x['id']} ({x['severity']})** — `{x['file']}`, {x['label_or_line']}",
              f"* Problem: {x['problem']}", f"* Evidence: {x['evidence']}", f"* Fix: {x['fix']}", '']
with open(P1 + 'review-p1-arxiv.md', 'a', encoding='utf8') as f:
    f.write('\n'.join(lines))
print('appended', len(add), 'issues; combined', len(cur), sev)
