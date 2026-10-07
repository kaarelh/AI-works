import re,collections
txt=open('/home/user/AI-works/inferential-learning/lean/audit-output.txt').read()
# join entries: each starts with 'info: '
entries=re.split(r'\n(?=info: |ℹ |Build )',txt)
res={'Audit':collections.Counter(),'module':collections.Counter()}
names={'Audit':[], 'module':[]}
for e in entries:
    if not e.startswith('info: '): continue
    e1=' '.join(e.split())
    m=re.match(r"info: (\S+?):\d+:\d+: '(.+?)' (depends on axioms: \[([^\]]*)\]|does not depend on any axioms)",e1)
    if not m:
        print('UNPARSED',e1[:200]); continue
    src='Audit' if m.group(1).startswith('Audit.lean') else 'module'
    ax=m.group(4)
    key=', '.join(a.strip() for a in ax.split(',')) if ax is not None else 'none'
    res[src][key]+=1
    names[src].append(m.group(2))
for k,v in res.items():
    print(k,sum(v.values()),dict(v))
print('distinct Audit names',len(set(names['Audit'])))
print('dup Audit names',[n for n,c in collections.Counter(names['Audit']).items() if c>1])
print('sorry anywhere', 'sorryAx' in txt)
