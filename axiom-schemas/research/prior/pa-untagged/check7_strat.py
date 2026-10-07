# Remedy: use the premise count as a free partial tag (stratified class: any premise-free part + <=k2 premised schemas).
from pa_common import *
import check3_k8_witness as c3   # reuses its realistic data D (7 Q + 400 induction steps, 5 roots, names x,y,n)
D=c3.D
D2=[d for d in D if len(d)==4]
L=lgg_list(D2)
print('k2=1: lgg of the premised data == sigma_ind (x metavariable):',equiv(L,sigma_V(True)))
for qn,q in c3.qs: print('  accepts',qn,':',is_instance(q,L))
