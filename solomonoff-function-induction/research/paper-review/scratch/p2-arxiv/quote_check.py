"""Check that every ``...'' quotation in Paper 2's visible text that is attributed to Hänni occurs verbatim
(up to whitespace, case, dashes and TeX markup) in his notes, the LessWrong thread or the brief.
Usage: python3 -I quote_check.py <paper-steeper> <research>"""
import re, sys, glob, os
P, R = sys.argv[1], sys.argv[2]
srcs = {}
for f in glob.glob(os.path.join(R, 'prior', '*.md')) + glob.glob(os.path.join(R, 'prior', '*.txt')) + [os.path.join(R, '00-brief.md')]:
    srcs[os.path.basename(f)] = open(f, encoding='utf8', errors='replace').read()
def norm(s):
    s = s.replace('---', '—').replace('--', '–').replace('\\dots', '...').replace('\\ ', ' ')
    s = re.sub(r'\$([^$]*)\$', r'\1', s)
    s = re.sub(r'\\[a-zA-Z]+\{([^}]*)\}', r'\1', s)
    s = s.replace('{,}', ',').replace('\\%', '%').replace('`', "'").replace('’', "'").replace('“', '"').replace('”', '"')
    s = s.replace('{', '').replace('}', '').replace('\\', '')
    s = re.sub(r'\s+', ' ', s).strip().lower()
    return s
nsrc = {k: norm(v) for k, v in srcs.items()}
for f in sorted(glob.glob(os.path.join(P, 'sections', '*.tex'))):
    if 'verification' in f: continue
    s = re.sub(r'(?<!\\)%.*', '', open(f, encoding='utf8').read())
    for m in re.finditer(r"``(.+?)''", s, re.S):
        q = m.group(1)
        line = s.count('\n', 0, m.start()) + 1
        nq = norm(q)
        # allow ellipses in quotes: split at '...' and require all pieces in one source
        pieces = [x.strip(" .,'") for x in re.split(r'\.\.\.|…', nq) if x.strip(" .,'")]
        hits = [k for k, v in nsrc.items() if pieces and all(p in v for p in pieces)]
        status = 'OK ' + ','.join(hits[:2]) if hits else 'NOT FOUND'
        print(f"{os.path.basename(f)}:{line}\t{status}\t{q[:90]!r}")
