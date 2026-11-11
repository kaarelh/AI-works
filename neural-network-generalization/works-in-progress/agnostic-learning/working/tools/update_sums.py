"""Update NNG/SHA256SUMS for the agnostic-learning folder and the NNG README (byte-sorted, two-space format)."""
import hashlib, os
NNG='/workspace/ai-works/neural-network-generalization'
SUB='works-in-progress/agnostic-learning'
lines=open(f'{NNG}/SHA256SUMS').read().splitlines()
entries={l.split('  ',1)[1]: l.split('  ',1)[0] for l in lines}
for k in [k for k in entries if k.startswith(SUB+'/')]: del entries[k]
def h(p): return hashlib.sha256(open(f'{NNG}/{p}','rb').read()).hexdigest()
added=0
for root,dirs,files in os.walk(f'{NNG}/{SUB}'):
    dirs[:]=[d for d in dirs if d!='__pycache__' and not (root.endswith(SUB) and d=='working')]
    for f in files:
        if f.endswith('.pyc'): continue
        rel=os.path.relpath(os.path.join(root,f),NNG)
        entries[rel]=h(rel); added+=1
entries['README.md']=h('README.md')
out='\n'.join(f'{v}  {k}' for k,v in sorted(entries.items(), key=lambda kv: kv[0].encode()))+'\n'
open(f'{NNG}/SHA256SUMS','w').write(out)
print('agnostic files:',added,'total entries:',len(entries))
