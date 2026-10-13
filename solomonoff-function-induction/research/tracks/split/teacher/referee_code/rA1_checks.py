"""rA1: referee A (proofs) checks for the sub-track "teacher" (notes.md). Deterministic.

(A) The Reading after Prop 3.2 says the good model is an interior vertex of the population hull whose
    lambda-interval "contains (2^-m, c_hi]". Counterexample in natural explicit codes: at the paper's
    instance (d = 100, m = 20, p = 2^-10, B = infinity, population, uniform inputs) take the programs
    "true parity a + flip rate q" that differ only in the code of q. Their risk is
    R(q) = -p log q - (1-p) log(1-q) = H(p) + KL(p || q). The parity part is common, so only the rate
    code length matters. For two codes of q we list, for c in (2^-20, c_hi], which q minimises
    c * len(q) + R(q):
      code 1: the rate code RC of the notes' own tcommon.py (q = j/2^b, j odd: 1 + g(b) + (b - 1) bits,
              g(k) = 2 floor(log2(k+1)) + 1), re-implemented here;
      code 2: q = 2^-r with the length 2 log2(r) used in kappa_g of def:teacher:instance (real lengths).
    If a rate other than p is the minimiser on part of (2^-m, c_hi], then the rate-p good model is not
    the selected program there, although every conclusion of thm:teacher:main(ii) holds for the selected
    program (it is level 1, short, and has R >= H(p)).
(B) Re-reading of t2_reuse_factor.out (A): the vertex intervals of the rate-p parity F1(a, 1/16)
    against the union over all rates that the notes report as "the good model's lambda-interval";
    and of t2(B): the fraction of samples whose 2-MAP is the true parity, for n <= 2^m.
(C) Numbers quoted in notes.md: L_S at d = 20, m = 12, p = 2^-10 (quoted as 41 bits) and theta_m;
    the effect of delta_S = 20 on the certified window at p = 15/128 (quoted as "at most a few
    percent"); the c-grid ratio of t4 (how conservative the certified upper ends are).
(D) Lambda_2 >= 0 (needed for g >= 0 in Lemma 1.1 and for Delta to equal the paper's max{0, .}):
    the paper's stated lower bound on delta_S alone does not give it; (D2) at the good model does.
"""
import math
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
CHECKS = os.path.join(HERE, "..", "checks")


def H(q):
    return 0.0 if q in (0.0, 1.0) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def risk(p, q):
    return -(p * math.log2(q) + (1 - p) * math.log2(1 - q))


def g(k):
    return 2 * int(math.floor(math.log2(k + 1))) + 1


def rc_len(b):
    return 1 + g(b) + (b - 1)


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


def candidates_code1(p, bmax=16):
    out = []
    for b in range(1, bmax + 1):
        M = 2 ** b
        x = p * M
        js = set()
        for j in range(max(1, int(x) - 3), min(M - 1, int(x) + 4) + 1):
            if j % 2 == 1:
                js.add(j)
        if 1 not in js:
            js.add(1)
        for j in js:
            q = j / M
            out.append((rc_len(b), risk(p, q), f"{j}/2^{b}"))
    return out


def candidates_code2(p, rmax=20):
    return [(2 * math.log2(r), risk(p, 2.0 ** -r), f"2^-{r}") for r in range(2, rmax + 1)]


def minimiser_intervals(cands, cmin, cmax, n=20000):
    cs = [cmin * (cmax / cmin) ** (i / n) for i in range(n + 1)]
    runs = []
    for c in cs:
        best = min(cands, key=lambda t: c * t[0] + t[1])
        if runs and runs[-1][2] == best[2]:
            runs[-1][1] = c
        else:
            runs.append([c, c, best[2]])
    return runs


def part_A():
    print("=" * 100)
    print("(A) the rate-p good model is not the population minimiser on all of (2^-m, c_hi]")
    d, m, p = 100, 20, 2.0 ** -10
    chi = {0: 8.0618e-3, 30: 3.6590e-3}  # the paper's c_hi (t1 output), kappa = 0 and 30
    print(f"    instance d={d}, m={m}, p=2^-10, H(p)={H(p):.6f}; programs: true parity + rate q, only the rate code differs")
    for name, cands in [("code 1 (tcommon RC code)", candidates_code1(p)), ("code 2 (2 log r for q = 2^-r)", candidates_code2(p))]:
        for kap, ch in chi.items():
            runs = minimiser_intervals(cands, 2.0 ** -m * 1.0000001, ch)
            print(f"    {name}, window (2^-20, c_hi = {ch:.4e}] (kappa = {kap}):")
            for lo, hi, desc in runs:
                tag = "  <- rate p (the good model)" if desc in ("1/2^10", "2^-10") else ""
                print(f"        c in [{lo:.4e}, {hi:.4e}]: minimiser q = {desc}{tag}")
    # the first crossover in closed form
    kl = lambda q: risk(p, q) - H(p)
    print(f"    KL(p || 2^-9) = {kl(2.0 ** -9):.6f} bits; code 1 saves {rc_len(10) - rc_len(9)} bit(s) for 2^-9 against 2^-10,"
          f" so 2^-9 wins for c > {kl(2.0 ** -9) / (rc_len(10) - rc_len(9)):.4e}")
    print(f"    code 2 saves {2 * math.log2(10) - 2 * math.log2(9):.4f} bits, so 2^-9 wins for c > "
          f"{kl(2.0 ** -9) / (2 * math.log2(10) - 2 * math.log2(9)):.4e}")


def part_B():
    print("=" * 100)
    print("(B) re-reading t2_reuse_factor.out")
    txt = open(os.path.join(CHECKS, "t2_reuse_factor.out")).read()
    blocks = re.split(r"\n  m=", txt.split("(B)")[0])
    for blk in blocks[1:]:
        head = blk.splitlines()[0]
        mm = int(head.split()[0])
        verts = re.findall(r"lambda in \(\s*([0-9.e+inf-]+),\s*([0-9.e+inf-]+)\)\s+\('F1', (\d+), ([0-9.]+)\)", blk)
        if not verts:
            continue
        rep = re.search(r"good model's lambda-interval = \(([^)]*)\)", head)
        print(f"    m={mm:2d}: reported 'good model' interval ({rep.group(1) if rep else '?'}); F1 vertices by rate:")
        for lo, hi, a, q in verts:
            print(f"        F1(a={a}, q={float(q):.4f}): lambda in ({float(lo):.4g}, {float(hi):.4g})")
    tail = txt.split("(B)")[1]
    print("    t2(B): fraction of samples whose 2-MAP is F1 with the true parity (last column), n <= 2^m = 256:")
    for line in tail.splitlines():
        mt = re.match(r"\s+(\d+) \|.*\|\s+(\S+)\s+(\S+)\s+([0-9.]+)\s*$", line)
        if mt and int(mt.group(1)) <= 256:
            print(f"        n={int(mt.group(1)):4d}: 2-MAP family (mode) {mt.group(2)}, good@2 = {mt.group(4)}")


def part_C():
    print("=" * 100)
    print("(C) numbers quoted in notes.md")
    LS = log2binom(4096, 4)
    p = 2.0 ** -10
    d, m, r = 20, 12, 10
    s0 = 2 ** (m - r)
    kb = 2 * math.log2(d) + 2 * math.log2(m) + 2 * math.log2(s0)
    L1 = 2 * math.log2(d) + 2 * math.log2(m)
    theta = 2 ** m * H(p) / (math.ceil(LS) + kb + 4 + L1)
    print(f"    d=20, m=12, p=2^-10: s0={s0}, L_S = {LS:.2f} bits (notes: 41), theta_m = {theta:.3f} (notes: 0.55)")
    txt = open(os.path.join(CHECKS, "t4_junta_window.out")).read()
    rows = re.findall(r"p= 15/128 .*kappa= 0 delta_S=(\d+): .*certified cells: \[([0-9.e-]+), ([0-9.e-]+)\]", txt)
    w = {int(dS): (float(a), float(b)) for dS, a, b in rows}
    if 0 in w and 20 in w:
        print(f"    p=15/128, kappa=0: window delta_S=0 {w[0]}, delta_S=20 {w[20]}: lower end x{w[20][0] / w[0][0]:.3f}, "
              f"upper end x{w[20][1] / w[0][1]:.3f} (notes: 'at most a few percent')")
    ratio = (0.05 * 2 ** 20) ** (1 / 400)
    print(f"    t4 c-grid: 400 geometric cells on [2^-20, 0.05], ratio {ratio:.4f} per cell; certified upper ends can be"
          f" low by up to {100 * (ratio - 1):.1f}%.")
    print(f"    p=2^-10, kappa=0: paper c_hi = 8.0618e-3, certified end 7.882e-3 (ratio {7.882e-3 / 8.0618e-3:.4f}), although"
          f" Phi_2^sharp >= Phi_2 makes the true window contain the paper's.")


def part_D():
    print("=" * 100)
    print("(D) Lambda_2 >= 0: from the stated lower bound on delta_S alone, or from (D2) at the good model")
    print("    Lambda_2 = (2^m H(p) - L_S) + delta_S + 4 + Lambda_1 + kappa_g. With delta_S at its stated lower bound")
    print("    -2 log m - 2 log s0 (kappa = 0, B = infinity):")
    for (d, m, r) in [(100, 20, 10), (100, 100, 2), (400, 400, 3), (60, 60, 2)]:
        p = 2.0 ** -r
        s0 = 2 ** (m - r)
        LS = log2binom(2 ** m, s0) if m <= 30 else None
        gap = (2 ** m * H(p) - LS) if LS is not None else 0.5 * math.log2(2 * math.pi * 2 ** m * p * (1 - p))
        L1 = 2 * math.log2(d) + 2 * math.log2(m)
        kg = 2 * math.log2(d) + 2 * math.log2(r)
        dmin = -2 * math.log2(m) - 2 * math.log2(s0)
        print(f"      d={d:3d} m={m:3d} r={r:2d}: gap={gap:7.2f}, delta_S lower bound={dmin:8.2f}, "
              f"Lambda_2 at that bound = {gap + dmin + 4 + L1 + kg:8.2f}")
    print("    A negative value only shows that the stated lower bound on delta_S is too weak to give Lambda_2 >= 0.")
    print("    (D2) at pi_g (level 1, l <= d + kappa_g, R_B = H(p)) gives d + kappa_g + 2^m H(p) >= d + B_S - 4 - Lambda_1,")
    print("    i.e. Lambda_2 >= 0 always.")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    part_D()
