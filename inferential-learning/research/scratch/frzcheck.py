import itertools, sys
sys.path.insert(0,'.')
from comprehension_toy import learner
DC=['INT','UNI','PAIR','DIFF','EMP']
def rule(s,w):
    zr,v=w['ZR'],w['V']
    avoidPOS = not (s & {'DIFF','EMP'})
    avoidSEP = not (s & {'UNI','PAIR','EMP'})
    if zr>v: return 'SEP' if avoidSEP else 'Z'
    if v>zr: return 'POS' if avoidPOS else 'STRAT'
    return 'POS' if avoidPOS else ('SEP' if avoidSEP else 'STRAT')
n=0;bad=0
for k in range(0,6):
  for sub in itertools.combinations(DC,k):
    s=set(sub)
    for wz,wv in [(1,2),(2,1),(1,1),(3,1),(1,3)]:
      for base in [1,2]:
        pr={i:base for i in s}; pr['ZR']=wz; pr['V']=wv
        _,best=learner(pr,{'NC'})
        n+=1
        if best!=rule(s,pr): bad+=1; print(s,wz,wv,best,rule(s,pr))
print(n,bad)
