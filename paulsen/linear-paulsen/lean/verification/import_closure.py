import sys,re,os
import os; root=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def imports(mod):
    p=os.path.join(root,*mod.split('.'))+'.lean'
    if not os.path.exists(p): return None
    return [l.split()[1] for l in open(p) if l.startswith('import ')]
seen=set(); stack=list(sys.argv[1:])
while stack:
    m=stack.pop()
    if m in seen: continue
    im=imports(m)
    if im is None: continue
    seen.add(m); stack+= [x for x in im if x.startswith('Paulsen')]
for m in sorted(seen): print(m)
