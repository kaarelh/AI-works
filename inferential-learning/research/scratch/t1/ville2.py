import math
# exact: R*={a,b}, p*(a)=1-u, p*(b)=u; R'={a,c}, p'(a)=1. LR after t a's = (1-u)^-t; R' dies at first b.
# accept c iff w*/(w*+(1-w*)LR) < w* d'  <=> LR > (1-w* d')/((1-w*) d')
for u in [0.5,0.2,0.05,0.01]:
    for wstar,dp in [(0.01,0.01),(0.001,0.05)]:
        thr=(1-wstar*dp)/((1-wstar)*dp)
        t=math.floor(math.log(thr)/(-math.log(1-u)))+1   # smallest t with LR>thr
        P=(1-u)**t
        print(f"u={u:5} w*={wstar} d'={dp}: exact P(ever accept invalid)={P:.5f}  bound d'={dp}  ratio={P/dp:.3f}")
