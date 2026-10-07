import re, glob, os, collections
here='/home/user/AI-works/inferential-learning/paper'
files=sorted(f for f in glob.glob(here+'/bib/*.bib') if not f.endswith('all.bib'))
defs=collections.defaultdict(list)
for f in files:
    t=open(f).read()
    for m in re.finditer(r'(?ms)^@(\w+)\s*\{\s*([^,\s]+)\s*,(.*?)(?=^@|\Z)', t):
        defs[m.group(2)].append(os.path.basename(f))
# citations
cites=collections.defaultdict(set)
for f in sorted(glob.glob(here+'/sections/*.tex'))+[here+'/main.tex']:
    t=open(f).read()
    for m in re.finditer(r'\\(?:cite|citet|citep|citealt|citealp|citeauthor|citeyear|nocite)\*?(?:\[[^\]]*\])*\{([^}]*)\}', t):
        for k in m.group(1).split(','):
            cites[k.strip()].add(os.path.basename(f))
print("num defs",len(defs))
print("DUPLICATE KEYS:")
for k,v in defs.items():
    if len(v)>1: print(" ",k,v)
print("UNCITED:")
for k in defs:
    if k not in cites: print(" ",k,defs[k])
print("CITED BUT UNDEFINED:")
for k in cites:
    if k not in defs: print(" ",k,cites[k])
print("MAP:")
for k in sorted(defs):
    print(k, defs[k][0], sorted(cites.get(k,[])))
