import re, glob, os, collections
here='/home/user/AI-works/inferential-learning/paper'
files=sorted(f for f in glob.glob(here+'/bib/*.bib') if not f.endswith('all.bib'))
defs=collections.defaultdict(list)
def norm(body):
    fields={}
    for m in re.finditer(r'(\w+)\s*=\s*(\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\}|"[^"]*"|\d+)', body):
        v=m.group(2).strip('{}"')
        v=re.sub(r'[{}\s]+',' ',v).strip().lower()
        fields[m.group(1).lower()]=v
    return fields
for f in files:
    t=open(f).read()
    for m in re.finditer(r'(?ms)^@(\w+)\s*\{\s*([^,\s]+)\s*,(.*?)(?=^@|\Z)', t):
        defs[m.group(2)].append((os.path.basename(f), m.group(1).lower(), norm(m.group(3))))
for k,v in defs.items():
    if len(v)>1:
        base=v[0]
        for other in v[1:]:
            diffs=[]
            if other[1]!=base[1]: diffs.append(('TYPE',base[1],other[1]))
            for fld in set(base[2])|set(other[2]):
                a=base[2].get(fld); b=other[2].get(fld)
                if a!=b: diffs.append((fld,a,b))
            if diffs:
                print(f"== {k}: {base[0]} vs {other[0]}")
                for d in diffs: print("    ",d)
