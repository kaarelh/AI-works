import re, sys
txt = open(sys.argv[1]).read()
defined = set(m.group(2) for m in re.finditer(r'\*\*(Lemma|Theorem|Proposition|Corollary|Remark) (\d+\.\d+[a-z]?)', txt))
ext_markers = ['B-tempered-likelihood.md', 'E-finite-prior-scale.md', 'red-team.md', 'C-fixed-temperature-bayes.md', 'paper.tex', 'slt-likelihood', 'noisy-interpolation', 'Theorem C.', 'Proposition C.', 'its ', 'Its ', 'B ', 'E ']
bad = []
for m in re.finditer(r'(Lemmas?|Theorems?|Propositions?|Corollar(?:y|ies)|Remarks?) ((?:\d+\.\d+[a-z]?(?:\([a-z]′?\))?(?:–|, | and |–)?)+)', txt):
    nums = re.findall(r'\d+\.\d+[a-z]?', m.group(2))
    ctx = txt[max(0, m.start()-60):m.start()]
    external = any(k in ctx[-45:] for k in ['B-tempered-likelihood.md', 'E-finite-prior-scale.md', 'red-team.md`', 'red-team.md', 'C-fixed-temperature-bayes.md', '`paper.tex`', 'its Corollary', 'its Theorem', 'Its Theorem', 'its Proposition'])
    for n in nums:
        if n not in defined and not external:
            bad.append((n, ctx[-60:].replace('\n',' '), m.group(0)))
print("defined:", sorted(defined, key=lambda s: [int(x) if x.isdigit() else x for x in re.split(r'(\d+)', s)]))
print("undefined internal refs (may include external ones):")
for b in bad: print(b)
