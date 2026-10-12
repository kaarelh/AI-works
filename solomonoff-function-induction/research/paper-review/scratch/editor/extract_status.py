"""Independent extraction of every \\status{...} and \\src{...} call in both papers (lead editor's check).
Writes status_p1.json / status_p2.json: one record per \\status call with file, line, enclosing environment, label, status, src."""
import re, glob, os, json, sys
ROOT = '/home/user/AI-works/solomonoff-function-induction'
ENVS = 'theorem|proposition|lemma|corollary|conjecture|definition|example|assumption|remark|table'
def brace_arg(text, i):
    depth = 1; j = i
    while depth and j < len(text):
        if text[j] == '{': depth += 1
        elif text[j] == '}': depth -= 1
        j += 1
    return text[i:j-1], j
def run(paper, out):
    recs = []
    for f in sorted(glob.glob(f'{ROOT}/{paper}/sections/*.tex')):
        t = open(f).read()
        # strip comments
        t = re.sub(r'(?<!\\)%.*', '', t)
        for m in re.finditer(r'\\status\{', t):
            st, end = brace_arg(t, m.end())
            line = t.count('\n', 0, m.start()) + 1
            # enclosing env: last \begin{env} before m without matching \end
            befores = [(b.start(), b.group(1)) for b in re.finditer(r'\\begin\{(' + ENVS + r')\}', t[:m.start()])]
            env = None; envpos = None
            for pos, e in reversed(befores):
                if t.count('\\end{' + e + '}', pos, m.start()) == 0:
                    env, envpos = e, pos; break
            lab = None; src = None
            if envpos is not None:
                seg = t[envpos:m.start() + 600]
                lm = re.search(r'\\label\{([^}]*)\}', seg)
                lab = lm.group(1) if lm else None
            sm = re.match(r'\s*\\src\{', t[end:end+5])
            nxt = t.find('\\src{', end)
            if nxt != -1 and nxt - end < 5:
                src, _ = brace_arg(t, nxt + 5)
            recs.append(dict(file=os.path.basename(f), line=line, env=env, label=lab, status=st, src=src))
    json.dump(recs, open(out, 'w'), indent=1, ensure_ascii=False)
    return recs
for paper, tag in [('paper', 'p1'), ('paper-steeper', 'p2')]:
    r = run(paper, f'{ROOT}/research/paper-review/scratch/editor/status_{tag}.json')
    plain = [x for x in r if x['status'].strip() == 'proved']
    print(tag, 'status calls:', len(r), 'plain proved:', len(plain), 'other:', len(r) - len(plain),
          'outside env:', sum(1 for x in r if x['env'] is None))
