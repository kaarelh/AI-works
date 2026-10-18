"""Numerical checks for drafts/T4-protocols.md (protocols that make the intended behaviour
approval-maximising).

Notation as in the draft:
  eps          rate of predictable grader errors (cells E: the grader prefers X, intended is I)
  v            demonstrability: P(verifier accepts a valid flag) in a cell
  f            P(verifier accepts a spurious flag) in a clean cell (cells N)
  b, c         bonus for an accepted flag, penalty for a rejected flag (reward gap Delta+ = 1)
  v* = (1+c)/(1+b+c)   acceptance probability at which challenging the grader breaks even
Drift against the best responder under the KL tilt (D), in reward units:
  Phi = (1+b+c) [ eps E_E (v* - v)^+  +  (1-eps) E_N (f - v*)^+ ]
"""
import numpy as np
from math import comb, lgamma, exp, log

rng = np.random.default_rng(4)
out = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


def check(name, pred, sim, tol):
    ok = abs(pred - sim) <= tol
    say(f"CHECK {name}: predicted {pred:.6g}, computed {sim:.6g}  -> {'OK' if ok else 'MISMATCH'}")
    return ok


# ---------------------------------------------------------------------------
say("=== 1. Best response under the flag protocol, brute force against the closed form")


def brute(eps, vE, wE, fN, wN, b, c):
    """Expected reward of A (always flags true errors, never spurious) and of the
    best responder G*, by enumerating actions cell by cell."""
    JA = JG = 0.0
    for v, w in zip(vE, wE):          # error cells: grader gives X 1, I 0
        flag = v * (1 + b) - (1 - v) * c
        JA += eps * w * flag
        JG += eps * w * max(1.0, 0.0, flag)    # X, I silent, I + valid flag
    for f, w in zip(fN, wN):          # clean cells: grader gives I 1, X 0
        spur = f * (1 + b) - (1 - f) * c
        JA += (1 - eps) * w * 1.0
        JG += (1 - eps) * w * max(1.0, spur)   # I, X + spurious flag
    return JA, JG


def phi(eps, vE, wE, fN, wN, b, c):
    vs = (1 + c) / (1 + b + c)
    tE = sum(w * max(vs - v, 0) for v, w in zip(vE, wE))
    tN = sum(w * max(f - vs, 0) for f, w in zip(fN, wN))
    return (1 + b + c) * (eps * tE + (1 - eps) * tN)


for trial in range(5):
    k = 4
    vE = rng.uniform(0, 1, k); wE = rng.dirichlet(np.ones(k))
    fN = rng.uniform(0, 0.6, k); wN = rng.dirichlet(np.ones(k))
    eps = rng.uniform(0.005, 0.05); b = rng.uniform(0, 3); c = rng.uniform(0, 2)
    JA, JG = brute(eps, vE, wE, fN, wN, b, c)
    check(f"trial {trial} J(G*)-J(A) (b={b:.2f}, c={c:.2f})", phi(eps, vE, wE, fN, wN, b, c), JG - JA, 1e-12)

say("--- b = c = 0 gives eps (1 - vbar)")
vE = [0.95, 0.6, 0.1]; wE = [0.6, 0.25, 0.15]
fN = [0.02, 0.4]; wN = [0.97, 0.03]
eps = 0.02
vbar = float(np.dot(vE, wE))
check("Phi(b=c=0) = eps(1-vbar)", eps * (1 - vbar), phi(eps, vE, wE, fN, wN, 0, 0), 1e-12)

say("--- for fixed v*, the penalty c only inflates the scale: c = 0 is optimal")
for vs in [0.3, 0.5, 0.8]:
    vals = []
    for c in [0, 0.5, 1, 2]:
        b = (1 + c) / vs - 1 - c
        vals.append(phi(eps, vE, wE, fN, wN, b, c))
    say(f"     v*={vs}: Phi for c=0,0.5,1,2: " + ", ".join(f"{x:.5f}" for x in vals))
    check(f"v*={vs}: Phi(c)/Phi(0) = 1+c at c=2", 3.0, vals[3] / vals[0] if vals[0] > 0 else 3.0, 1e-9)

# ---------------------------------------------------------------------------
say("=== 2. Worked example: choose v* (c = 0, b = 1/v* - 1)")
grid = np.linspace(0.05, 1.0, 1901)
P = np.array([phi(eps, vE, wE, fN, wN, 1 / g - 1, 0) for g in grid])
i = int(np.argmin(P))
say(f"     vbar = {vbar:.3f};  no protocol: eps = {eps:.4f};  v*=1: eps(1-vbar) = {eps*(1-vbar):.5f}")
say(f"     optimum v* = {grid[i]:.3f} (b = {1/grid[i]-1:.2f}), Phi = {P[i]:.5f}")
for g in [1.0, 0.6, 0.4, 0.3, 0.1]:
    say(f"     v*={g}: Phi = {phi(eps, vE, wE, fN, wN, 1/g-1, 0):.5f}")
lam = 0.05  # nats per unit reward gap under (D), as in T1's example
L0 = np.log(1e6)
for name, val in [("no protocol", eps), ("v*=1", eps * (1 - vbar)), ("v* optimal", P[i])]:
    say(f"     episodes to overturn odds 1e6 under (D), lam={lam}: {name}: {L0/(lam*val):,.0f}")

say("--- the same cells under (B), Bayes on the final verdict (G* never flags unless v = 1)")
delta = 0.01
Lam = np.log((1 - delta) / delta)
perE = [np.log(((1 - delta) + delta * v) / ((1 - delta) * v + delta)) for v in vE]
DB = eps * float(np.dot(perE, wE))
say("     per-cell nats: " + ", ".join(f"v={v}: {x:.4f}" for v, x in zip(vE, perE)))
say(f"     (B) drift with protocol {DB:.5f} nats/episode; without {eps*Lam:.5f}; ratio {eps*Lam/DB:.2f}")
say(f"     compare eps E[-ln v] = {eps*float(np.dot(-np.log(vE), wE)):.5f}")

# Monte Carlo: sample episodes, apply exact tilt, compare drift
say("--- Monte Carlo: sampled episodes, exact tilt, G* vs A")
n = 400000
cellE = rng.choice(3, size=n, p=wE); isE = rng.random(n) < eps
cellN = rng.choice(2, size=n, p=wN)
b = 1 / 0.4 - 1
acc = rng.random(n)
rA = np.where(isE, np.where(acc < np.array(vE)[cellE], 1 + b, 0.0), 1.0)
vs = 0.4
gflag = np.array(vE)[cellE] >= vs
rG = np.where(isE, np.where(gflag, np.where(acc < np.array(vE)[cellE], 1 + b, 0.0), 1.0),
              np.where(np.array(fN)[cellN] > vs, np.where(acc < np.array(fN)[cellN], 1 + b, 0.0), 1.0))
check("MC mean reward gap at v*=0.4", phi(eps, vE, wE, fN, wN, b, 0), float(np.mean(rG - rA)), 3e-4)

# ---------------------------------------------------------------------------
say("=== 3. Adversarial routing: the gamer chooses where the dispute lands")
m = 50
e = rng.beta(0.3, 6, size=m)   # predictable judge error per atomic claim the prover can route to
say(f"     mean atomic error {e.mean():.4f}; verifier-chosen random atom: f = mean = {e.mean():.4f}")
say(f"     prover-chosen atom: f = max = {e.max():.4f}")
for kk in [1, 5, 20]:
    # if the prover can only route to a random subset of kk atoms (others fixed by the protocol)
    sims = [np.max(rng.choice(e, kk, replace=False)) for _ in range(20000)]
    say(f"     route among {kk:2d} random atoms: E f = {np.mean(sims):.4f}")

# ---------------------------------------------------------------------------
say("=== 4. Consistency checks")
say("--- (a) liar tracks each framing w.p. R (exchangeable): P(detect) = 1 - E[R^m]")
for m in [1, 5, 10, 20, 100]:
    pc, r = 0.3, 0.7
    pred_two = (1 - pc) * (1 - r ** m)
    sims = rng.random(200000) < pc
    Rs = np.where(sims, 1.0, r)
    tracked = (rng.random((200000, m)) < Rs[:, None]).all(axis=1) if m <= 20 else None
    if tracked is not None:
        check(f"two-point mixture pi_coh=0.3, r=0.7, m={m}", pred_two, 1 - tracked.mean(), 4e-3)
    al, be = 4.0, 1.0
    pred_beta = 1 - exp(lgamma(al + m) + lgamma(al + be) - lgamma(al) - lgamma(al + be + m))
    say(f"     m={m:3d}: independent r=0.8: {1-0.8**m:.4f};  Beta(4,1): {pred_beta:.4f} (=m/(4+m) {m/(4+m):.4f});"
        f"  two-point: {pred_two:.4f} (ceiling {1-pc:.2f})")
R = rng.beta(4, 1, 200000)
tracked = (rng.random((200000, 10)) < R[:, None]).all(axis=1)
check("Beta(4,1), m=10", 10 / 14, 1 - tracked.mean(), 4e-3)

say("--- (b) independent instances, open-ended lie: all m agree w.p. sum_i p_i^m")
p = np.array([0.4, 0.3, 0.2, 0.1])
for m in [2, 3, 5]:
    draws = rng.choice(4, size=(200000, m), p=p)
    agree = (draws == draws[:, :1]).all(axis=1).mean()
    check(f"agreement m={m}", float(np.sum(p ** m)), agree, 4e-3)

say("--- (c) framing-specific graders, consistency enforced: G* answers the majority-approved answer")
eps_c, eps_f = 0.004, 0.016
for m in [1, 3, 5, 7]:
    tail = sum(comb(m, j) * eps_f ** j * (1 - eps_f) ** (m - j) for j in range(m // 2 + 1, m + 1))
    pred = eps_c + (1 - eps_c) * tail
    N = 2000000
    common = rng.random(N) < eps_c
    own = rng.binomial(m, eps_f, N)
    sim = np.mean(common | (own > m / 2))
    check(f"eps_res with m={m} framings", pred, sim, 3e-4)

# ---------------------------------------------------------------------------
say("=== 5. Collusion: detection of a careful gamer's deviation by a monitor")


def detect(pi_A, pi_G, pi_C, v, sigma, xi, hM, r, tM):
    """pi_*: P(monitor type | policy is a careful gamer). A and G monitors report (rewarded,
    demonstrable w.p. v). A colluding C monitor stays silent on a signalled item unless its
    posterior that the item is a honeypot is >= tM; it reports unsignalled items."""
    post_sig = hM * xi / (hM * xi + r * sigma) if (hM * xi + r * sigma) > 0 else 0
    dC = (1 - sigma) + sigma * (post_sig >= tM)
    return (pi_A + pi_G) * v + pi_C * dC * v, post_sig


for (piC, sigma, xi) in [(1.0, 0.9, 0.0), (1.0, 0.3, 0.0), (1.0, 0.9, 0.5), (0.3, 0.9, 0.0)]:
    d, ps = detect(1 - piC, 0.0, piC, 0.9, sigma, xi, hM=0.05, r=0.01, tM=0.3)
    # Monte Carlo
    N = 400000
    mon = rng.random(N) < piC
    sig = rng.random(N) < sigma
    acc = rng.random(N) < 0.9
    rep = np.where(mon, np.where(sig, ps >= 0.3, True), True) & acc
    check(f"pi_C={piC}, sigma={sigma}, xi={xi} (P(honeypot|signal)={ps:.2f})", d, rep.mean(), 3e-3)

# ---------------------------------------------------------------------------
say("=== 6. The loop with a protocol: aligned-end drift and separatrix by generation")


def run(scn, K=14, L0=3.0, verbose=True):
    eps0, kap, deps = 0.01, 0.15, 0.05
    a, s0, sg = 0.03, 0.5, 0.3
    lam, n = 0.05, 20000
    r0, nu, om = scn["r0"], scn["nu"], scn["om"]

    def D(q, k):
        eh = eps0 * np.exp(kap * k)
        ep = eh + q * deps
        rA = r0 * np.exp(-nu * k)
        rX = min(1.0, r0 * np.exp(om * k))
        rho = (1 - q) * rA + q * rX
        s = 1 - (1 - s0) * np.exp(-sg * k)
        u = a * (1 - q) * (1 - s)
        return lam * ((1 - a * (1 - q)) * ep * rho - u)

    L = L0
    rows = []
    for k in range(K):
        qs = np.linspace(0, 1, 100001)
        Ds = np.array([D(q, k) for q in qs])
        qd = qs[np.argmax(Ds > 0)] if (Ds[0] < 0 and Ds[-1] > 0) else (0.0 if Ds[0] >= 0 else 1.0)
        q = 1 / (1 + np.exp(L))
        rows.append((k, n * D(0, k), qd, L, q))
        L = L - n * D(q, k)
        L = max(min(L, 60), -60)
    if verbose:
        say(f"--- scenario {scn['name']}: r0={r0}, nu={nu}, omega={om}")
        for (k, d0, qd, Lk, q) in rows:
            say(f"     k={k:2d}  n D(0) = {d0:8.2f} nats/gen   q_dagger = {qd:.3f}   L_k = {Lk:7.2f}   q_k = {q:.3f}")
    return rows


scenarios = [dict(name="S0 no protocol", r0=1.0, nu=0.0, om=0.0),
             dict(name="S1 protocol, demonstration outpaces blind spots", r0=0.3, nu=0.3, om=0.3),
             dict(name="S2 protocol, blind spots outpace demonstration", r0=0.3, nu=0.05, om=0.3),
             dict(name="S3 protocol, demonstration outpaces blind spots and recognition", r0=0.3, nu=0.5, om=0.3)]
res = {}
for scn in scenarios:
    res[scn["name"]] = run(scn)

say("--- crossing generation of the aligned-end drift: k_c = ln(a(1-s0)/((1-a) eps0 r0)) / (kappa - nu + sigma)")
for scn in scenarios:
    r0, nu = scn["r0"], scn["nu"]
    rate = 0.15 - nu + 0.3
    kc = np.log(0.03 * 0.5 / (0.97 * 0.01 * r0)) / rate if rate > 0 else np.inf
    rows = res[scn["name"]]
    first = next((k for (k, d0, *_r) in rows if d0 > 0), None)
    say(f"     {scn['name']}: k_c = {kc:.2f}; first generation with n D(0) > 0 in the run: {first}")

say("--- S1 from several starting log-odds (final L after 14 generations)")
for L0 in [-1.0, 0.0, 1.0, 2.0, 3.0]:
    rows = run(scenarios[1], L0=L0, verbose=False)
    k, d0, qd, Lk, q = rows[-1]
    say(f"     L0={L0:5.1f}: L_13 = {Lk:7.2f}")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
