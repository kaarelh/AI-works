"""Assemble research/paper-review/p1/review-p1-arxiv.md from the parts in this folder."""
import json
mid = open('review_mid.md').read(); i = mid.index('## 6. Structure and length')
issues = json.load(open('../../p1/issues-p1-arxiv.json'))
sec8 = ['\n## 8. Numbered issue list\n', 'Severity: fatal = false or unsupported mathematical claim, or a claim stronger than the sources; major = missing hypothesis, wrong number, inconsistency, misleading framing, arXiv-standard violation a reader would notice, or a reader cannot follow; minor = local wording or formatting. The same records are in `issues-p1-arxiv.json`.\n']
for x in issues:
    sec8 += [f"\n**{x['id']} ({x['severity']})** — `{x['file']}`, {x['label_or_line']}\n", f"* Problem: {x['problem']}\n", f"* Evidence: {x['evidence']}\n", f"* Fix: {x['fix']}\n"]
out = (open('review_head.md').read() + open('review_sec4_pre.md').read() + open('conversion_table.md').read()
       + open('review_sec42_pre.md').read() + open('process_vocab_filtered.md').read().rsplit('\n\n',1)[0] + '\n'
       + mid[:i] + open('review_sec5_pre.md').read() + open('bib_table.md').read() + '\n' + mid[i:] + ''.join(sec8))
open('../../p1/review-p1-arxiv.md', 'w').write(out)
print(len(out), 'chars;', len(issues), 'issues')
