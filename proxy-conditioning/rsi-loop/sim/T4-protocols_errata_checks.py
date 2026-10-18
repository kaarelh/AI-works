"""Errata checks for drafts/T4-protocols.md after the reconciliation (sim/reconciliation.md, sections 3.6 and 4).

E1. T4.5 under (B): fresh-coin versus fixed-verdict verifier randomness; drift, reduction factor,
    judgment-cell share. Mixture bound: for any per-episode acceptance probability V with mean v,
    the evidence per rewarded opportunity lies between the fresh-coin and the fixed-verdict values
    (convexity of g(V) = ln[((1-d)+dV)/((1-d)V+d)] on [0,1]).
E2. T4.7 under (B), both readings: lambda_+, t*, sign flip of the naive gamer, per-kind break-evens,
    proportional and optimised honeypot allocation for a best responder that sees the cell kind;
    Monte Carlo of the naive gamer's drift under the fixed reading at s = 0.90 and 0.93.
E3. T1.4c pointwise audit-density ratio t*/(1-t*) = lambda_+/lambda_- with and without the protocol.
"""
import numpy as np

out = []
nchk = nbad = 0


def say(s=""):
    print(s)
    out.append(s)


def check(name, pred, got, tol):
    global nchk, nbad
    ok = abs(pred - got) <= tol
    nchk += 1
    nbad += (not ok)
    say(f"CHECK {name}: predicted {pred:.6g}, computed {got:.6g} -> {'OK' if ok else 'MISMATCH'}")


d = 0.01
Lam = np.log((1 - d) / d)
vE = np.array([0.95, 0.6, 0.1])
wE = np.array([0.6, 0.25, 0.15])
eps = 0.02


def g(V):
    return np.log(((1 - d) + d * V) / ((1 - d) * V + d))


say("E1. T4.5 worked example under (B), delta = 0.01, Lam = %.4f" % Lam)
lp_fresh = float(np.dot(wE, g(vE)))
lp_fixed = float(Lam * np.dot(wE, 1 - vE))
D0 = eps * Lam
Dfr, Dfx = eps * lp_fresh, eps * lp_fixed
say(f"   no protocol: {D0:.5f} nats/episode")
say(f"   fresh coin : lambda_+ = {lp_fresh:.4f}, drift {Dfr:.5f}, reduction {D0/Dfr:.2f}x, judgment share {wE[2]*g(vE[2])/lp_fresh:.3f}")
say(f"   fixed      : lambda_+ = {lp_fixed:.4f}, drift {Dfx:.5f}, reduction {D0/Dfx:.2f}x, judgment share {wE[2]*Lam*(1-vE[2])/lp_fixed:.3f}")
check("fixed-verdict drift 0.0244 (reconciliation R13)", 0.0244, Dfx, 5e-5)
check("fixed-verdict reduction 3.8x", 3.8, D0 / Dfx, 0.05)
check("fresh-coin reduction 9.4x", 9.4, D0 / Dfr, 0.06)
say("   per-kind cost, fresh vs fixed: " + ", ".join(f"v={v}: {g(v):.3f} vs {Lam*(1-v):.3f}" for v in vE))
# convexity of g on [0,1]
V = np.linspace(0, 1, 100001)
gpp = -(d ** 2) / ((1 - d) + d * V) ** 2 + (1 - d) ** 2 / ((1 - d) * V + d) ** 2
check("g'' >= 0 on [0,1] (min g'')", 1.0, float(gpp.min() > 0), 0)
check("g(1) = 0 and g(0) = Lam", 0.0, abs(g(1.0)) + abs(g(0.0) - Lam), 1e-12)
# random laws of V with mean v: lambda lies between g(v) and Lam(1-v)
rng = np.random.default_rng(7)
viol = 0
for _ in range(20000):
    k = rng.integers(1, 6)
    pts = rng.random(k)
    wts = rng.dirichlet(np.ones(k))
    m = float(np.dot(wts, pts))
    val = float(np.dot(wts, g(pts)))
    if not (g(m) - 1e-12 <= val <= Lam * (1 - m) + 1e-12):
        viol += 1
check("mixtures: g(v) <= E g(V) <= Lam(1-v) for 20000 random laws", 0, viol, 0)

say()
say("E2. T4.7 under (B): T1's honeypot example eps=0.01, a=0.03, h=1")
e7, a7 = 0.01, 0.03
vrate = (1 - a7) * e7
s_B0 = 1 - vrate / a7
say(f"   no protocol: lambda_+ = Lam, t* = 0.5, flip at s = {s_B0:.4f}")
res = {}
for lab, lpj in (("fresh coin", g(vE)), ("fixed verdict", Lam * (1 - vE))):
    lp = float(np.dot(wE, lpj))
    ts = lp / (lp + Lam)
    sflip = 1 - vrate * lp / (a7 * Lam)
    tj = lpj / (lpj + Lam)
    r = tj.max() / (1 - tj.max())
    s_prop = 1 - r * vrate / a7
    alloc = wE * lpj / np.sum(wE * lpj)
    # check optimal allocation holds every kind at break-even just below the flip
    st = sflip - 1e-4
    ph = a7 * (1 - st) * alloc / (a7 * (1 - st) * alloc + vrate * wE)
    ok_alloc = bool(np.all(ph >= tj - 1e-12))
    res[lab] = (lp, ts, sflip, s_prop)
    say(f"   {lab}: lambda_+ = {lp:.4f}, t* = {ts:.4f}, flip s = {sflip:.4f}; per-kind t*_j = {np.round(tj,4)}; "
        f"proportional honeypots: best responder gains once s > {s_prop:.4f}; optimal allocation {np.round(alloc,3)} (holds: {ok_alloc})")
    say(f"      T1.4c pointwise audit-density ratio t*/(1-t*) = lambda_+/lambda_- = {lp/Lam:.4f} (no protocol: 1)")
check("fixed-verdict t* = 0.209", 0.209, res["fixed verdict"][1], 5e-4)
check("fixed-verdict flip s = 0.914", 0.914, res["fixed verdict"][2], 5e-4)
check("fresh-coin flip s = 0.966", 0.966, res["fresh coin"][2], 5e-4)
# Monte Carlo of naive gamer's drift under fixed verdicts
S, N = 60, 200000
for s in (0.90, 0.93):
    pred = vrate * res["fixed verdict"][0] - a7 * (1 - s) * Lam
    sl = []
    for _ in range(S):
        r = rng.random(N)
        aud = r < a7
        unrec = aud & (rng.random(N) > s)
        err = (~aud) & (rng.random(N) < e7)
        kind = rng.choice(3, size=N, p=wE)
        acc = rng.random(N) < vE[kind]
        pG = (1 - d) + d * acc
        pA = (1 - d) * acc + d
        inc = err * (np.log(pG) - np.log(pA)) - unrec * Lam
        sl.append(inc.sum() / N)
    sl = np.array(sl)
    se = sl.std() / np.sqrt(S)
    say(f"   fixed verdict, s = {s:.2f}: predicted naive-gamer drift {pred:+.6f}, simulated {sl.mean():+.6f} +- {se:.6f}")
    check(f"fixed-verdict MC drift sign/size at s={s}", pred, sl.mean(), 3 * se + 1e-5)

say()
say("E3. (D), b = 1.5, convention A gets 1 and caught X gets -1 on honeypots: residual (judgment) cells")
Dp, Dm = 1 - 0.1 * 2.5, 2.0
say(f"   t* = {Dp/(Dp+Dm):.4f}; pointwise audit-density ratio on judgment-like features = {Dp/Dm:.4f}"
    f" (no protocol, same convention: 1/2 = 0.5, required on all error-like features)")

say()
say(f"{nchk} checks, {nbad} mismatches")
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
