import numpy as np, itertools
# Lemma E' counterexample for Sec.9 #7: arbitrary arbitrage-free move vs Euclidean projection
x=np.array([.6,.6]); W=[np.array([1.,0.]),np.array([0.,1.])]
def brier(p,w): return float(((p-w)**2).sum())
def arb(p):
    best=-1e9
    for xs in itertools.product(np.linspace(-1,1,41),repeat=2):
        xs=np.array(xs); best=max(best,min(float(xs@(w-p)) for w in W))
    return best
print("Arb(0.6,0.6)=",round(arb(x),4)," Arb(1,0)=",round(arb(np.array([1.,0.])),4))
print("Brier world(0,1): x",brier(x,W[1])," moved to (1,0):",brier(np.array([1.,0.]),W[1])," projection (.5,.5):",brier(np.array([.5,.5]),W[1]))
# converse of E': actual world outside W -> projection of its own indicator strictly hurts
# S={phi}, unsound constraint 'not phi' -> W={0}; actual world phi true -> v=1
print("converse: v=1, K={0}: Brier before",brier(np.array([1.]),np.array([1.]))," after",brier(np.array([0.]),np.array([1.])))
# Sec 4.5 threshold: P(phi_n)->1-p; threshold 1-delta never certifies iff 1-p < 1-delta iff delta < p
for p,d in [(0.1,0.05),(0.1,0.2)]:
    print(f"p={p} delta={d}: limit {1-p} >= threshold {1-d}?", 1-p>=1-d, "-> never certifies" if 1-p<1-d else "-> certifies")
