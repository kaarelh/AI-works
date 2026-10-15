"""Assemble the Paper 2 arXiv review from its parts (review B). Usage: python3 -I assemble.py"""
import os, shutil
here = os.path.dirname(os.path.abspath(__file__))
parts = ['review_head.md', 'conversion_table.md', 'review_mid.md', 'issue_list.md']
text = '\n'.join(open(os.path.join(here, p), encoding='utf8').read().rstrip('\n') + '\n' for p in parts)
out = os.path.join(here, '..', '..', 'p2', 'review-p2-arxiv.md')
open(out, 'w', encoding='utf8').write(text)
os.makedirs(os.path.join(here, 'final'), exist_ok=True)
shutil.copy(out, os.path.join(here, 'final', 'review-p2-arxiv.md'))
shutil.copy(os.path.join(here, '..', '..', 'p2', 'issues-p2-arxiv.json'), os.path.join(here, 'final', 'issues-p2-arxiv.json'))
print(len(text), 'chars')
