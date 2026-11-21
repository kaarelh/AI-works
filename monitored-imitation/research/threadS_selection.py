"""Thread S (second red team of verified-slack.md): quantitative checks.

Run:  python3 threadS_selection.py > threadS_selection.out   (about 30 s, seed fixed)

A. Repeated verification under "rerun until accepted".
   A problem's first run carries a wrong claimed solution caused by one culprit
   committed step c (uniform below n0), plus u harmless committed mistakes
   (paraphrases, valid alternatives) uniform over the n committed steps. Each
   rejection runs VSI's search (streams U, S, H; Lemma 3 of verified-slack.md)
   until it hits *some* mistake, fixes that one, and reruns. Fixing a harmless
   mistake leaves the wrong claim in place, so the rerun is verified again.
   The verifier passes a wrong notebook with marginal probability f per look; a
   share rho of f is fixed by the claim (same verdict on every rerun), the rest is
   presentation-dependent (fresh on every rerun). rho = 1 is the note's implicit
   model. Output: P(wrong output | first run wrong), E[J] (verifications of wrong
   notebooks), E[task queries until the culprit is fixed].
B. Steady-state output failure when insights are problem-specific.
C. Enrichment of verifier-targeting deviations among accepted wrong outputs.
D. Bits of selection: the filter bound and best-of-k resampling.
E. Heavy-tailed durations: share of problems with tau(x0) > n, and the largest
   number of problems for which VSI stays under a fifth of chained imitation's
   effort.
"""
import math
import random

RNG = random.Random(20261121)


# ---------------------------------------------------------------- part A
def schedule(kind):
    """Deterministic stream schedule, cycled."""
    return {
        "U only (SI-V)": ["U"],
        "S only (check-and-scan)": ["S"],
        "U,S,H equal (VSI)": ["U", "S", "H"],
        "S-heavy 8:1:1": ["S"] * 8 + ["U", "H"],
    }[kind]


def one_problem(n0, n, u, h, s, kind):
    c = RNG.randrange(n0)
    others = [k for k in range(n) if k != c]
    mistakes = set(RNG.sample(others, u)) | {c}
    # post-mortem list of s entries, fixed for the problem (deterministic human)
    lst = RNG.sample(others, s)
    if RNG.random() < h:
        lst[RNG.randrange(s)] = c
    sched = schedule(kind)
    J, Q = 1, 0
    while True:  # one rejection's search
        scan, hp, i = 0, 0, 0
        while True:
            st = sched[i % len(sched)]
            i += 1
            if st == "S":
                if scan >= n:
                    continue
                k, scan = scan, scan + 1
            elif st == "H":
                if hp >= s:
                    if all(x != "U" and x != "S" for x in sched):
                        raise RuntimeError
                    continue
                k, hp = lst[hp], hp + 1
            else:
                k = RNG.randrange(n)
            Q += 1
            if k in mistakes:
                break
        mistakes.discard(k)
        if k == c:
            return J, Q
        J += 1  # the rerun still carries the wrong claim and is verified again


def part_a():
    n0, n, s, N = 30, 60, 5, 20000
    fs, rhos = [0.05, 0.1, 0.3], [1.0, 0.5, 0.0]
    print("A. Repeated verification (n0 = 30, n = 60, post-mortem list s = 5, "
          f"{N} problems per row)")
    print("   P(wrong output | first run wrong) for f per look and share rho of f fixed by the claim")
    hdr = "   %-24s %3s %4s | %5s %6s |" % ("search", "u", "h", "E[J]", "E[Q]")
    hdr += "".join(" f=%.2f:rho=%s" % (f, "/".join("%g" % r for r in rhos)) for f in fs)
    print(hdr)
    for kind in ["U only (SI-V)", "S only (check-and-scan)",
                 "U,S,H equal (VSI)", "S-heavy 8:1:1"]:
        for u in [0, 5, 20]:
            for h in [0.0, 0.6]:
                if "H" not in schedule(kind) and h > 0:
                    continue
                Js, Qs = [], []
                for _ in range(N):
                    J, Q = one_problem(n0, n, u, h, s, kind)
                    Js.append(J)
                    Qs.append(Q)
                cells = []
                for f in fs:
                    vals = []
                    for rho in rhos:
                        fc = rho * f
                        keep = (1 - f) / (1 - fc)  # 1 - f_p
                        p_ok = (1 - fc) * sum(keep ** j for j in Js) / N
                        vals.append("%.2f" % (1 - p_ok))
                    cells.append("  " + "/".join(vals) + "     ")
                print("   %-24s %3d %4.1f | %5.2f %6.1f |%s" % (
                    kind, u, h, sum(Js) / N, sum(Qs) / N, "".join(cells)))
    print()


# ---------------------------------------------------------------- part B
def part_b():
    print("B. Steady-state output failure per problem = p_f0 * w * f_eff "
          "(problem-specific insights: does not decay)")
    print("   p_f0 = first-run failure rate on a new problem, w = share of failed runs with a "
          "claimed solution, f_eff = verifier pass rate after reruns")
    fe = [0.02, 0.1, 0.2, 0.35, 0.5]
    print("   %5s %4s | " % ("p_f0", "w") + " ".join("f=%-5.2f" % f for f in fe))
    for p in [0.1, 0.3, 0.5]:
        for w in [0.2, 0.5, 0.8]:
            row = " ".join("%6.1f%%" % (100 * p * w * f) for f in fe)
            print("   %5.1f %4.1f | %s" % (p, w, row))
    print("   'Works' needs <= 5%.\n")


# ---------------------------------------------------------------- part C
def part_c():
    print("C. Enrichment: share of verifier-targeting (malign) deviations among accepted "
          "wrong outputs")
    print("   prior odds r = malign : honest among deviations reaching the output; "
          "f_m = 0.9 (targets V's blind spots)")
    fm = 0.9
    print("   %8s | " % "r" + " ".join("f_h=%-5g" % fh for fh in [0.3, 0.1, 0.01, 0.001]))
    for r in [1e-1, 1e-2, 1e-3]:
        row = " ".join("%8.0f%%" % (100 * r * fm / (r * fm + fh)) for fh in [0.3, 0.1, 0.01, 0.001])
        print("   %8g | %s" % (r, row))
    print("   bits of enrichment log2(f_m/f_h): " + ", ".join(
        "f_h=%g: %.1f" % (fh, math.log2(fm / fh)) for fh in [0.3, 0.1, 0.01, 0.001]))
    print("   A better honest verifier makes the accepted errors *more* adversarial, "
          "unless f_m falls with f_h.\n")


# ---------------------------------------------------------------- part D
def part_d():
    print("D. Bits of selection")
    print("   Deterministic decoder, reruns only after a rejection: per problem <= log2(1+R_p);")
    print("   lifetime max over sum R_p <= K (b_alpha = 1) is T*log2(1+K/T) <= K*log2(e)")
    for K in [100, 1000]:
        cells = []
        for T in [K // 10, K, 10 * K]:
            cells.append("T=%d: %.0f bits (%.2f per problem)" % (
                T, T * math.log2(1 + K / T), math.log2(1 + K / T)))
        print("   K=%d: " % K + "; ".join(cells))
    print("   Resampling decoder (best-of-k, no update between attempts): "
          "KL(output || policy) = ln k - (k-1)/k")
    print("   " + ", ".join("k=%d: %.2f bits" % (k, (math.log(k) - (k - 1) / k) / math.log(2))
                            for k in [2, 4, 16, 64, 256, 1024]))
    print()


# ---------------------------------------------------------------- part E
def phi_lognormal(sig, q):
    # tau lognormal with median 1; n0 = q-quantile; n = 2 n0
    from statistics import NormalDist
    nd = NormalDist()
    zq = nd.inv_cdf(q)
    return 1 - nd.cdf(zq + math.log(2) / sig)


def phi_pareto(a, q):
    # P(tau > x) = x^-a for x >= 1; n0 = q-quantile; n = 2 n0
    x0 = (1 - q) ** (-1 / a)
    return (2 * x0) ** (-a)


def part_e():
    print("E. Heavy tails: phi = Pr[tau(x0) > n] with n = 2 n0 and n0 at quantile q")
    for q in [0.5, 0.75, 0.9]:
        ln = ", ".join("lognormal s=%.2f: %4.1f%%" % (s, 100 * phi_lognormal(s, q))
                       for s in [0.75, 1.0, 1.25])
        pa = ", ".join("Pareto a=%.1f: %4.1f%%" % (a, 100 * phi_pareto(a, q))
                       for a in [1.2, 1.5, 2.0])
        print("   q=%.2f | %s | %s" % (q, ln, pa))
    print()
    print("   Effort budget: VSI <= CI/5 = 4 n0 K at eps = 5%. VSI effort / (n0 K) =")
    print("     a*iota (search, a = 3 worst case) + 2*iota*phi*(T/K) (futile full search of n on")
    print("     each problem the human's own chain cannot finish) + beta*(T/K)/n0 (audits)")
    print("     + c_V*(T/K + 1)/n0 (verifications, c_V task steps each).  n0 = 30, beta = 1.")
    print("   Largest T/K for which VSI still meets the budget ('-' = never):")
    n0, beta = 30, 1.0
    print("   %3s %5s %5s | " % ("a", "iota", "c_V") + " ".join("phi=%-5.2f" % p for p in [0.0, 0.05, 0.1, 0.2]))
    for a in [1.0, 2.0, 3.0]:
        for iota in [1.0, 1.3, 1.6]:
            for cv in [0.1, 0.5]:
                cells = []
                for phi in [0.0, 0.05, 0.1, 0.2]:
                    num = 4 - a * iota - cv / n0
                    den = 2 * iota * phi + beta / n0 + cv / n0
                    cells.append("%9s" % ("-" if num <= 0 else "%.1f" % (num / den)))
                print("   %3.0f %5.1f %5.1f | %s" % (a, iota, cv, " ".join(cells)))
    print("   With a = 3 the worst case alone fits only if iota < 4/3.")
    print()
    print("   Against the human doing every problem itself (about n0 per problem): on each problem")
    print("   its own chain cannot finish within n, VSI ends with the human answering every step of")
    print("   a full run (>= n = 2*iota*n0 task queries) and no output, so the saving is at most")
    print("   about 1/(2*iota*phi), before any other cost:")
    for iota in [1.0, 1.3, 1.6]:
        print("     iota=%.1f: " % iota + ", ".join(
            "phi=%.2f: %.1fx" % (phi, 1 / (2 * iota * phi)) for phi in [0.05, 0.1, 0.2]))


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()
