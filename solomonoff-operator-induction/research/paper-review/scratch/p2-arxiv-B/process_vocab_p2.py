"""Find process vocabulary, unverified-literature hedges, Wyeth mentions, third-person author references and
script names in the visible text of Paper 2 (comments, \\status{} and \\src{} removed, since the arXiv
conversion strips those). Scans sections/*.tex and main.tex. Prints file:line<TAB>category<TAB>context.
Usage: python3 -I process_vocab_p2.py <paper-steeper> > process_vocab.out"""
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
        out.append('\n' * s[j:k].count('\n')); i = k
    return ''.join(out)
PATTERNS = [
 (r'\btracks?\b', 'track'), (r'\breferees?\b|\brefereed\b', 'referee'), (r'\bledger\b', 'ledger'), (r'notes-final|notes\.md', 'notes-file'),
 (r'\bbrief\b|00-brief', 'brief'), (r'orchestrat', 'orchestrator'), (r'\brequest\b', 'request'), (r'\bverdicts?\b', 'verdict'),
 (r'[Ww]yeth', 'Wyeth'), (r'unverified', 'unverified'), (r'not (?:been )?checked|unchecked|not re-checked', 'not checked'),
 (r'snippet', 'snippet'), (r'abstracts?\b', 'abstract(s)'), (r'full texts?', 'full text'), (r'search', 'search'),
 (r'\bClaude\b|Anthropic', 'Claude'), (r'\bT5\b', 'T5'), (r'\bSt\b', 'St'),
 (r'\\texttt\{[^}]*\}', 'texttt/path'), (r'\bseed\b', 'seed'), (r'run2|revision|re-run|rerun|scratch cop', 'process-run'),
 (r'\bdraft\b', 'draft'), (r'internal', 'internal'), (r'personal communication', 'pers.comm'),
 (r'H\\"anni\'s|H\\"anni\b', 'Hanni-3rd-person'), (r'the author', 'the author'), (r'\bhis\b|\bHe\b|\bhe\b', 'his/he'),
 (r'presumably|looks within reach|as far as we can tell|we have not|our reading|is our reading', 'hedge'),
 (r'undated', 'undated'), (r'(?<![a-z])c\d(?:\([A-Za-z]\))?\b|\b[rq]\d\b', 'check id'),
 (r'accompanying repository', 'repo'), (r'illustration', 'illustration'), (r'\\status|\\src', 'marker'),
]
files = sorted(glob.glob(os.path.join(PAPER, 'sections', '*.tex'))) + [os.path.join(PAPER, 'main.tex')]
for f in files:
    s = open(f, encoding='utf8').read()
    s = re.sub(r'(?<!\\)%.*', '', s)
    s = strip_cmd(s, 'status'); s = strip_cmd(s, 'src')
    for ln, line in enumerate(s.split('\n'), 1):
        for pat, name in PATTERNS:
            for m in re.finditer(pat, line):
                a = max(0, m.start() - 70); b = min(len(line), m.end() + 70)
                print(f"{os.path.basename(f)}:{ln}\t{name}\t{line[a:b]!r}")
