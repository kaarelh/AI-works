"""Split each main-text section into blocks (environments, tables, paragraphs) and
estimate their printed length from source size. Calibration: pages per KB of source,
fitted per section from the measured page spans of the built PDF."""
import re, sys, os
SEC = '/home/user/AI-works/axiom-induction/paper/sections'
# measured page spans (start->end as fractional pages, from pdftotext -bbox of main.pdf)
spans = {'intro': 4.67, 'model': 6.48, 'universal': 7.85, 'ident': 6.51, 'sound': 5.87,
         'time': 5.92, 'pa': 8.40, 'experiments': 6.59, 'discussion': 3.71}
ENV = r'(theorem|proposition|lemma|corollary|conjecture|definition|example|assumption|remark|table|proof|enumerate|itemize|quote)'
for name, pages in spans.items():
    src = open(os.path.join(SEC, name + '.tex')).read()
    body = '\n'.join(l for l in src.split('\n') if not l.lstrip().startswith('%'))
    total = len(body)
    ppk = pages / total
    blocks = []
    i = 0
    pat = re.compile(r'\\begin\{' + ENV + r'\}')
    while i < len(body):
        m = pat.search(body, i)
        if not m:
            blocks.append(('text', body[i:])); break
        if m.start() > i:
            blocks.append(('text', body[i:m.start()]))
        env = m.group(1)
        # find matching end (no nesting of same env assumed except enumerate/itemize)
        depth, j = 0, m.start()
        endpat = re.compile(r'\\(begin|end)\{' + env + r'\}')
        for mm in endpat.finditer(body, m.start()):
            depth += 1 if mm.group(1) == 'begin' else -1
            if depth == 0:
                j = mm.end(); break
        blocks.append((env, body[m.start():j]))
        i = j
    print(f'===== {name}: {pages:.2f} pp, {total/1000:.1f} KB source')
    for kind, txt in blocks:
        lab = re.search(r'\\label\{([^}]*)\}', txt)
        sub = re.search(r'\\(sub)*section\*?\{([^}]*)\}', txt)
        est = len(txt) * ppk
        if est < 0.04: continue
        tag = lab.group(1) if lab else (('§ ' + sub.group(2)[:40]) if sub else txt.strip()[:50].replace('\n', ' '))
        print(f'{est:5.2f} pp  {kind:12s} {tag}')
