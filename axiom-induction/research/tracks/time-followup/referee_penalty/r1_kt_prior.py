"""r1: the Kt-style penalty P1b of time-followup notes.md (Def 1.1, Prop 2.3), checked by explicit arithmetic.

P1b gives a decider p the weight 2^-|p| / c_p with c_p := sup_chi time_p(chi) / t(|chi|), t(m) = m^a* (a* >= 3).
Every decider reads its whole program, so time_p(chi) >= |p|.

Part A (Prop 2.3(ii) uses W_{AI^Kt}(0) <= 1).  c_p can be < 1, so a weight can exceed 2^-|p|.  Family used: the deciders
  p_n := W + delta(n) (a fixed wrapper W that reads an Elias-delta code delta(n), ignores it, and rejects every input,
  i.e. decides the empty axiom set, compatible with the empty data set), with time_p(chi) = |p| + |chi|.
  Then c_p = sup_{m >= m0} (|p| + m)/m^a* = (|p| + m0)/m0^a* (the ratio decreases in m).  The family alone already has
  total weight > 1 for small |W| and moderate m0.  The general bound is W(0) <= t(m0), since c_p >= |p|/t(m0) >= 1/t(m0).
Part B (the remark after Prop 2.3: "Measuring the time against t(|chi| + |p|) instead of t(|chi|) removes both charges").
  With c_p := sup time_p(chi)/t(|chi| + |p|), the same family has c_p = (|p| + m0)^(1 - a*), weight
  2^-|p| (|p| + m0)^(a* - 1), and the total weight DIVERGES (linearly in N = log2 n for a* = 3, like log N for a* = 2).
  Capping c_p below at 1 restores Kraft.
Part C (the size of the Kt charge on a padded Craig decider, Prop 2.3(ii)).  Cost model: the decider of Lemma 2.1(b)
  on chi of length L costs (notes' bound) alpha*(L + |q| + 1)^a; an early-exit variant (parse chi, read q while
  counting down from m, reject if m - 1 < |q| before simulating) costs |q| + 3L + [L > |q|]*alpha*(L + 1)^a.
  Compare log2 c_p with the floor log2(|q|/t(m0)) that every program pays (Prop 2.3(i)).
"""
import math

out = []


def delta_len(n):
    N = n.bit_length() - 1
    return N + 2 * ((N + 1).bit_length() - 1) + 1


# ---------------------------------------------------------------- Part A
out.append("Part A: W_{AI^Kt}(empty) can exceed 1 (Prop 2.3(ii) assumes <= 1); the correct general bound is t(m0).")
out.append(f"{'|W|':>4} {'m0':>4} {'a*':>3} {'family weight':>14} {'t(m0)':>8}")
for (W, m0, a) in [(4, 4, 3), (4, 10, 3), (8, 10, 3), (4, 10, 5)]:
    tot = 0.0
    # group n by N = floor(log2 n): 2^N members, all with the same delta length
    for N in range(0, 200):
        L = N + 2 * ((N + 1).bit_length() - 1) + 1
        P = W + L
        c = (P + m0) / m0 ** a
        tot += 2.0 ** N * 2.0 ** (-P) / c
    out.append(f"{W:>4} {m0:>4} {a:>3} {tot:>14.4f} {m0 ** a:>8}")
out.append("  -> a family of 2^-|W|-weighted deciders reaches total weight > 1; Kraft gives only W(0) <= t(m0).")
out.append("")

# ---------------------------------------------------------------- Part B
out.append("Part B: c_p measured against t(|chi| + |p|): partial sums of the family's weights (uncapped vs capped at c_p >= 1).")
out.append(f"{'a*':>3} {'N_max':>8} {'sum (uncapped)':>16} {'sum (capped)':>14}")
W, m0 = 4, 4
for a in (2, 3):
    for Nmax in (10, 100, 1000, 10000, 100000):
        unc = cap = 0.0
        for N in range(0, Nmax + 1):
            L = N + 2 * ((N + 1).bit_length() - 1) + 1
            P = W + L
            c = (P + m0) ** (1 - a)          # sup_m (P + m)/(m + P)^a, attained at m = m0
            # 2^N members, each of weight 2^-P / c; compute 2^(N - P) exactly in log space
            lw = N - P
            unc += 2.0 ** lw / c
            cap += 2.0 ** lw / max(1.0, c)
        out.append(f"{a:>3} {Nmax:>8} {unc:>16.3f} {cap:>14.6f}")
out.append("  -> uncapped sums grow without bound (a* = 3: about 2^-|W| per group, i.e. ~ 2^-|W| N_max; a* = 2: ~ log N_max): the prior is")
out.append("     not normalisable, so 'measuring against t(|chi|+|p|)' needs weight 2^-|p|/max(1, c_p).")
out.append("")

# ---------------------------------------------------------------- Part C
out.append("Part C: log2 c_p of a padded Craig decider vs the floor log2(|q|/t(m0)) every program pays.")
alpha, a, astar, m0 = 2.0, 2, 3, 4
out.append(f"  cost model: alpha = {alpha}, simulation exponent a = {a}, t(m) = m^{astar}, m0 = {m0}")
out.append(f"{'|q|':>10} {'floor':>8} {'notes bound':>12} {'early exit':>11} {'notes-floor':>12} {'early-floor':>12}")
for e in range(4, 31, 3):
    q = 2 ** e
    floor = math.log2(q / m0 ** astar)
    # sup over L >= m0 of cost/L^a*; scan L on a geometric grid plus the region around q
    Ls = sorted(set([m0] + [int(m0 * 1.1 ** i) for i in range(0, 400)] + [q - 1, q, q + 1, q + 2]))
    Ls = [L for L in Ls if L >= m0]
    notes = max(alpha * (L + q + 1) ** a / L ** astar for L in Ls)
    early = max((q + 3 * L + (alpha * (L + 1) ** a if L > q else 0.0)) / L ** astar for L in Ls)
    out.append(f"{q:>10} {floor:>8.2f} {math.log2(notes):>12.2f} {math.log2(early):>11.2f} "
               f"{math.log2(notes) - floor:>12.2f} {math.log2(early) - floor:>12.2f}")
out.append("  -> the notes' bound charges (a - 1) log2|q| bits above the floor (growing); the early-exit decider stays a")
out.append("     bounded number of bits above it, so P1b costs log2|f| + O(1), exactly the charge every program pays.")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
