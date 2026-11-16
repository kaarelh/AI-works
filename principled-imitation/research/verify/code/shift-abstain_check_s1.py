# Referee check of Example 2.2 of prove-c/shift-abstain.md: exact formulas and Monte Carlo of Protocol R.
import math, random
def exact(L, w, n):
    kap = (1 + w*(L-1))/L
    s = (1-(1-kap)**n)/kap          # sum_t pi_t
    Ebeta = (1-w)*(1+w*(L-1))*s/n
    Ef = (1-w)*L*s/n
    dbar_a = (L-1)*(1 - s*(1-w)/n)
    B = max(1.0, (L-1)/dbar_a)
    K = math.log2(1/w)
    return Ebeta, Ef, B*L*K*math.log(2)/n, L*K*math.log(2)/n
for L, w, n in [(100, .01, 10**4), (1000, .001, 10**6)]:
    print(L, w, n, "E beta=%.5f  E int e dd_f=%.4f  claimed S1 bound=%.5f  R1 bound=%.5f" % exact(L, w, n))
def mc(L, w, n, reps, rng):
    tb = tf = 0.0
    for _ in range(reps):
        alive = True; sb = sf = 0.0
        for t in range(n):
            if alive:
                sb += (1-w)*(1+w*(L-1)); sf += (1-w)*L
                # rehearsal run: x0 answered 0 w.p. w (then calls at a) else at b
                ans0 = rng.random() < w
                J = rng.randrange(1, L+1)
                if J == 1 or (J >= 2 and ans0): alive = False
        tb += sb/n; tf += sf/n
    return tb/reps, tf/reps
rng = random.Random(1)
L, w, n = 20, .05, 200
print("MC L=20,w=.05,n=200:", mc(L, w, n, 20000, rng), "exact:", exact(L, w, n)[:2])
