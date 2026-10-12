"""Extract every theorem-like environment of Paper 2 with label, \\status and \\src (nested braces handled)."""
import re, sys, json, os, glob
PAPER = sys.argv[1]
ENVS = ['theorem','proposition','lemma','corollary','conjecture','definition','example','assumption','remark']
def braced(s, i):
    # s[i] == '{'; return content and end index
    assert s[i] == '{'
    depth = 0; j = i
    while j < len(s):
        if s[j] == '{' and (j == 0 or s[j-1] != '\\'): depth += 1
        elif s[j] == '}' and (j == 0 or s[j-1] != '\\'):
            depth -= 1
            if depth == 0: return s[i+1:j], j+1
        j += 1
    return s[i+1:], len(s)
rows = []
for f in sorted(glob.glob(os.path.join(PAPER, 'sections', '*.tex'))):
    s = open(f, encoding='utf8').read()
    for m in re.finditer(r'\\begin\{(' + '|'.join(ENVS) + r')\}', s):
        env = m.group(1)
        start = m.end()
        end = s.find('\\end{' + env + '}', start)
        body = s[start:end]
        line = s.count('\n', 0, m.start()) + 1
        title = ''
        if body.startswith('['):
            # optional title, may contain brackets in math; take to first ']' at depth 0
            depth = 0
            for k, ch in enumerate(body):
                if ch == '{': depth += 1
                elif ch == '}': depth -= 1
                elif ch == ']' and depth == 0:
                    title = body[1:k]; break
        lab = re.search(r'\\label\{([^}]*)\}', body)
        st = body.find('\\status{')
        status = braced(body, st + 7)[0] if st >= 0 else None
        sr = body.find('\\src{')
        src = braced(body, sr + 4)[0] if sr >= 0 else None
        rows.append(dict(file=os.path.relpath(f, PAPER), line=line, env=env, title=title,
                         label=lab.group(1) if lab else None, status=status, src=src))
json.dump(rows, open(sys.argv[2], 'w'), indent=1, ensure_ascii=False)
from collections import Counter
print('environments:', len(rows))
print(Counter(r['env'] for r in rows))
print('no status:', [(r['file'], r['line'], r['label']) for r in rows if r['status'] is None])
nonplain = [r for r in rows if r['status'] is not None and r['status'].strip() != 'proved']
print('status not plain proved:', len(nonplain))
for r in rows:
    print(f"{r['file']}:{r['line']}\t{r['env']}\t{r['label']}\t[{r['status']}]\t<{r['src']}>")
