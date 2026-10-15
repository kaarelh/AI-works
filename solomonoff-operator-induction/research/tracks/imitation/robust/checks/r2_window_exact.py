"""r2: the population window for environment-coupled coins in an explicit toy class (notes Section 4:
Proposition 4.3, Lemma 4.5, Theorem 4.6(vi), Proposition 4.9(c), Remark 4.11).  Deterministic, except the PRG seeds
in (B), one per case, drawn from numpy default_rng(2); hash = sha256.  Exact arithmetic in floating point; no machine constant:
the class and its code lengths are explicit, so every number is a statement about this class.

World.  Input x = (z, w), z in {0,1}^m (environment cell), w in {0,1}^du (what the human attends to), uniform.
The human answers y = f_a(w) XOR b with a private coin b ~ Bern(p) -- this is the human's kernel nu_H.
In the world the coin is b = 1_S(z) for a fixed set S of s0 = p 2^m cells (environment-driven coins); the
human's kernel is calibrated (P(y != f_a(w)) = p).  (C) adds a private residual coin b' ~ Bern(p').

Class (prefix code: a 2-bit tag, then the fields; Kraft sum <= 1):
  00          coin                                         l = 2
  01 a q      human-type: f_a with flip rate q, q in Q      l = 2 + du + 6      (Q = {j/64}, uniform code)
  10 a q t T  S-cell alien: declares the cells of T (|T| = t, T a subset of {0,1}^m) to have coin 1, predicts
              f_a XOR 1 there with probability 1, and f_a with flip rate q elsewhere
              l = 2 + du + 6 + gamma(t) + ceil(log2 C(2^m, t)),  gamma(t) = 2 floor(log2(t+1)) + 1
  11 a sigma  PRG alien: predicts f_a XOR G_sigma(z) with probability 1 - 2^-10, sigma in {0,1}^s
              l = 2 + du + s
Programs with a wrong parity have risk >= 1 and are dominated by the coin; S-cell aliens with T not inside S
have infinite risk.  So the population hull is determined by: coin, H(a,q), A(a,q,t) with T inside S, and
(in the PRG world) P(a, sigma*).
"""
import hashlib
from math import lgamma, log, log2, floor, ceil
import numpy as np

LN2 = log(2.0)


def lc(n, k):                      # log2 C(n, k)
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / LN2


def H2(p):
    return 0.0 if p <= 0 or p >= 1 else -p * log2(p) - (1 - p) * log2(1 - p)


def CE(p, q):                      # cross-entropy of Bern(p) under prediction Bern(q), bits
    if q <= 0:
        return 0.0 if p <= 0 else float("inf")
    if q >= 1:
        return 0.0 if p >= 1 else float("inf")
    return -p * log2(q) - (1 - p) * log2(1 - q)


def gamma(t):
    return 2 * floor(log2(t + 1)) + 1


def best_rate(p, Q):
    vals = [CE(p, q) for q in Q]
    j = int(np.argmin(vals))
    return Q[j], vals[j]


def window(points, ref):
    """points: list of (length, risk, name); ref: (length, risk).  Returns (s_plus, s_minus, argmax, argmin)."""
    a0, r0 = ref
    sp, sp_arg = 0.0, None
    sm, sm_arg = float("inf"), None
    for (l, r, nm) in points:
        if l > a0 and r < r0:
            v = (r0 - r) / (l - a0)
            if v > sp:
                sp, sp_arg = v, nm
        if l < a0:
            v = (r - r0) / (a0 - l)
            if v < sm:
                sm, sm_arg = v, nm
        if l == a0 and r <= r0 and (l, r) != ref and nm != "human":
            sm, sm_arg = -1.0, nm          # another program at or below the human's point
    return sp, sp_arg, sm, sm_arg


def lower_hull(points):
    """Lower convex hull of (l, r) points with r finite (vertices, by increasing l), via monotone chain."""
    pts = {}
    for (l, r, nm) in points:
        if np.isfinite(r) and (l not in pts or r < pts[l][0]):
            pts[l] = (r, nm)
    xs = sorted(pts)
    # keep only points with strictly decreasing risk (the structure function's jumps)
    chain = []
    for x in xs:
        r, nm = pts[x]
        if chain and r >= chain[-1][1]:
            continue
        chain.append((x, r, nm))
    hull = []
    for p in chain:
        while len(hull) >= 2:
            (x1, y1, _), (x2, y2, _) = hull[-2], hull[-1]
            if (y2 - y1) * (p[0] - x1) >= (p[1] - y1) * (x2 - x1):   # hull[-1] on or above the chord
                hull.pop()
            else:
                break
        hull.append(p)
    return hull


def toy_points(du, m, s0, Q, qbits=6, extra=()):
    N = 2 ** m
    p = s0 / N
    pts = [(2, 1.0, "coin")]
    qh, rh = best_rate(p, Q)
    lH = 2 + du + qbits
    pts.append((lH, rh, "human"))
    for q in Q:                                    # other rates: same length, larger risk
        if q != qh:
            pts.append((lH, CE(p, q), f"H(q={q:.4f})"))
    aliens = []
    for t in range(1, s0 + 1):
        pt = (s0 - t) / (N - t) if t < N else 0.0
        q, ce = best_rate(pt, Q)
        R = (1 - t / N) * ce
        l = 2 + du + qbits + gamma(t) + ceil(lc(N, t))
        aliens.append((l, R, f"A(t={t})"))
    pts += aliens
    pts += list(extra)
    return pts, (lH, rh), aliens, p


Q64 = [j / 64 for j in range(64)]

print("(A) Random coupling S (any S with |S| = s0; the population quantities depend only on s0).")
print("    window = (s_plus, s_minus): the human H(a,p) is the unique J_c-minimiser exactly for c inside it.")
print(f"{'du':>3} {'m':>3} {'s0':>5} {'p':>7} {'l_H':>4} {'s_plus':>11} {'2^-m':>11} {'s_plus*2^m':>10}"
      f" {'argmax':>10} {'s_minus':>9} {'argmin':>6} {'ratio':>8} {'memo rate*2^m':>13} {'G_expl':>7} {'bound':>6}")
for (du, m, s0) in [(6, 8, 16), (6, 10, 64), (6, 12, 256), (6, 14, 1024), (6, 16, 4096),
                    (12, 10, 64), (20, 10, 64), (6, 10, 16), (6, 10, 128)]:
    pts, ref, aliens, p = toy_points(du, m, s0, Q64)
    sp, spa, sm, sma = window(pts, ref)
    N = 2 ** m
    lmemo, Rmemo, _ = aliens[-1]
    memo_rate = (ref[1] - Rmemo) / (lmemo - ref[0])
    # explicit right-line offset: max over aliens of 2^m (R_H - R) - (l - l_H), in bits
    G = max(N * (ref[1] - R) - (l - ref[0]) for (l, R, _) in aliens)
    bound = 2 * log2(N + 1) + 2 * log2(m)
    hull = lower_hull(pts)
    is_vertex = any(nm == "human" for (_, _, nm) in hull)
    assert is_vertex == (sp < sm), (du, m, s0)
    print(f"{du:3d} {m:3d} {s0:5d} {p:7.4f} {ref[0]:4d} {sp:11.4e} {1/N:11.4e} {sp*N:10.4f} {spa:>10s}"
          f" {sm:9.4f} {sma:>6s} {sm/sp:8.1f} {memo_rate*N:13.4f} {G:7.2f} {bound:6.2f}")
print("    (G_expl = max over aliens of [2^m (R_H - R) - (l - l_H)]: the offset of the right line of slope 2^-m")
print("     in this class, in bits; 'bound' = |B| log2(2^m+1) + 2 log2 m, the machine-free part of Lemma 4.5's offset.)")

print("\n    Hull of the (du, m, s0) = (6, 10, 64) instance (vertices by length):")
pts, ref, aliens, p = toy_points(6, 10, 64, Q64)
hull = lower_hull(pts)
for i, (l, r, nm) in enumerate(hull):
    sl = "" if i == 0 else f"   slope to previous = {-(r - hull[i-1][1]) / (l - hull[i-1][0]):.4e}"
    print(f"      l = {l:4d}  R = {r:.5f}  {nm}{sl}")

print("\n(B) PRG coupling: S = the s0 cells with the smallest sha256(sigma*, z), sigma* a uniformly drawn s-bit seed.")
print("    The PRG alien P(a, sigma*) has l = 2 + du + s and risk -log2(1 - 2^-10).")
rng = np.random.default_rng(2)
RP = -log2(1 - 2 ** -10)
print(f"{'du':>3} {'m':>3} {'s':>3} {'l_H':>4} {'PRG rate':>10} {'s_plus':>10} {'s_minus':>9} {'window?':>8}"
      f" {'(1-H(p))/(l_H-2)':>17}")
for du in (6, 16, 32):
    for s in (4, 8, 12, 16, 24, 32, 48, 64, 128):
        m, s0 = 10, 64
        sigma = int(rng.integers(0, 2 ** min(s, 62)))
        hv = [int.from_bytes(hashlib.sha256(f"{sigma}:{z}".encode()).digest()[:8], "big") for z in range(2 ** m)]
        S = set(np.argsort(hv, kind="stable")[:s0].tolist())
        assert len(S) == s0
        prg = (2 + du + s, RP, "PRG")
        pts, ref, aliens, p = toy_points(du, m, s0, Q64, extra=[prg])
        sp, spa, sm, sma = window(pts, ref)
        prg_rate = (ref[1] - RP) / (prg[0] - ref[0]) if prg[0] > ref[0] else float("inf")
        print(f"{du:3d} {m:3d} {s:3d} {ref[0]:4d} {prg_rate:10.4e} {sp:10.4e} {sm:9.4f} {str(sp < sm):>8s}"
              f" {(1 - H2(p)) / (ref[0] - 2):17.4e}")

print("\n(C) Partially private coins: y = f_a(w) XOR 1_S(z) XOR b', b' ~ Bern(p') private.  Rate grid Q = {j/1024}")
print("    (10-bit code).  Human: flip rate p_h = s(1-p') + (1-s)p', s = s0/2^m.  Aliens: T inside S, rate q_in on T")
print("    and q_out off T (two 10-bit rate codes).  'ideal' = 2^-m (H(p_h) - H(p'))/H(s): the full-knowledge rate.")
Q1024 = [j / 1024 for j in range(1024)]
print(f"{'m':>3} {'s0':>5} {'pp':>8} {'p_h':>8} {'s_plus*2^m':>10} {'ideal*2^m':>9} {'s_minus':>8} {'window?':>8}")
for (m, s0, pp_num) in [(10, 64, 16), (10, 64, 32), (12, 256, 16), (12, 256, 64)]:
    du = 6
    N = 2 ** m
    s = s0 / N
    pp = pp_num / 1024
    ph = s * (1 - pp) + (1 - s) * pp
    lH = 2 + du + 10
    qh, rh = best_rate(ph, Q1024)
    pts = [(2, 1.0, "coin"), (lH, rh, "human")]
    for t in range(1, s0 + 1):
        pout = ((s0 - t) * (1 - pp) + (N - s0) * pp) / (N - t)
        _, ce_in = best_rate(1 - pp, Q1024)
        _, ce_out = best_rate(pout, Q1024)
        R = (t / N) * ce_in + (1 - t / N) * ce_out
        l = 2 + du + 20 + gamma(t) + ceil(lc(N, t))
        pts.append((l, R, f"A(t={t})"))
    sp, spa, sm, sma = window(pts, (lH, rh))
    ideal = (H2(ph) - H2(pp)) / H2(s)
    print(f"{m:3d} {s0:5d} {pp:8.5f} {ph:8.5f} {sp*N:10.4f} {ideal:9.4f} {sm:8.4f} {str(sp < sm):>8s}")
