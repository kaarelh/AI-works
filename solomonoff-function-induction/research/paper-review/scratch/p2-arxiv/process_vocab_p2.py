"""Find process vocabulary in the visible text of Paper 1 (comments, \\status{} and \\src{} removed,
since the arXiv conversion strips those anyway). Prints file:line: match: context."""
import re, sys, os, glob
PAPER = sys.argv[1]
def strip_cmd(s, cmd):
    out = []; i = 0
    while True:
        j = s.find('\\' + cmd + '{', i)
        if j < 0: out.append(s[i:]); break
        out.append(s[i:j]); k = j + len(cmd) + 2; depth = 1
        while k < len(s) and depth:
            if s[k] == '{' and s[k-1] != '\\': depth += 1
            elif s[k] == '}' and s[k-1] != '\\': depth -= 1
            k += 1
        # keep newlines so line numbers survive
        out.append('\n' * s[j:k].count('\n')); i = k
    return ''.join(out)
PATTERNS = [
 (r'\btracks?\b', 'track'), (r'\breferees?\b', 'referee'), (r'\bledger\b', 'ledger'), (r'notes-final', 'notes-final'),
 (r'\bbrief\b', 'brief'), (r'orchestrat', 'orchestrator'), (r'\brequest\b', 'request'), (r'\bverdicts?\b', 'verdict'),
 (r'\bH(?:10|[1-9])(?:\([a-c]\))?\b', 'H-label'), (r'[Ww]yeth', 'Wyeth'),
 (r'unverified', 'unverified'), (r'not (?:been )?checked', 'not checked'), (r'unchecked', 'unchecked'),
 (r'snippet', 'snippet'), (r'(?:abstract|abstracts) (?:only )?seen|seen only|abstract only|only (?:the |their )?abstract', 'abstract-only'),
 (r'we have not (?:read|checked|examined)', 'not read'), (r'\bClaude\b', 'Claude'),
 (r'\b(?:foundations|history|examples|context|steeper)\s+(?:[a-z]\d|Thm|Prop|Lemma|Cor|Rem|Table|\\S)', 'track cite'),
 (r'\((?:[a-z]\d+(?:\([a-z,]+\))?(?:,\s*)?)+\)', 'check id'), (r'\b[cers]\d+(?:\([a-z]\))?\b', 'check id?'),
 (r'web-search|WebSearch|search tool', 'search tool'), (r'\bgroups?\b', 'group'), (r'working hypothes', 'working hyp'),
 (r'H\\"anni\'s (?:later )?request|his request', 'his request'), (r'\(corrected\)', 'corrected'),
 (r'scratch', 'scratch'), (r'run2|run1|re-run|rerun', 'run'), (r'\\texttt\{[^}]*\.py', 'script name'), (r'repository', 'repository'), (r'illustration', 'illustration'), (r'T5', 'T5'), (r'internal', 'internal'), (r'draft', 'draft'), (r'framing|writer|editor|planning', 'roles'), (r'seed', 'seed'), (r'independent (?:re-implementation|computation|simulation)', 'independent check'), (r'direct computation', 'direct computation'), (r'presumably|we have no proof|looks within reach', 'hedge'),
]
for f in sorted(glob.glob(os.path.join(PAPER, 'sections', '*.tex'))):
    s = open(f, encoding='utf8').read()
    s = re.sub(r'(?<!\\)%.*', '', s)
    s = strip_cmd(s, 'status'); s = strip_cmd(s, 'src')
    for ln, line in enumerate(s.split('\n'), 1):
        for pat, name in PATTERNS:
            for m in re.finditer(pat, line):
                a = max(0, m.start() - 60); b = min(len(line), m.end() + 60)
                print(f"{os.path.basename(f)}:{ln}\t{name}\t{line[a:b]!r}")
