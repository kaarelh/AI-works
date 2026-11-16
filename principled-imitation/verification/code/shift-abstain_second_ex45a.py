"""Second check, shift-abstain: Example 4.5a (editor) and the arithmetic of Theorem 4.5.

(1) the numbers quoted in item 3; (2) the inequality N1/2 >= a/(8 sigma) - 1/2
on a grid, with pi chosen freely (sigma := p_pi/4, a := 1-(1-N1 pi)^L);
(3) item 2 by exact enumeration of runs for small L, N1: silent failure 0
for every member, abort probability a (0 for f_{c0});
(4) Theorem 4.5, second claim: from the first claim with N0=(1-a)L/(2 sigma)
integer, check n >= (1-a)^2 L/(4 sigma) - L numerically.
"""
import itertools, math

# (1) numbers of item 3
def pi_for_sigma(L, sigma):
    return 1 - (1 - 4 * sigma) ** (1 / L)
L = 10
print("item 3 numbers (L=10):")
for sigma, N1 in [(1e-3, 55), (1e-4, 551), (1e-5, 5516)]:
    pi = pi_for_sigma(L, sigma)
    a = 1 - (1 - N1 * pi) ** L
    print("  sigma=%g N1=%d pi=%.6g a=%.4f N1/2=%.1f a/(8sigma)-1/2=%.2f 1/(1-a)^2=%.3f"
          % (sigma, N1, pi, a, N1 / 2, a / (8 * sigma) - 0.5, 1 / (1 - a) ** 2))
# a = 0.5 variant: find N1 with a closest to 0.5 from below or as quoted
for sigma, N1 in [(1e-3, 167), (1e-4, 1673), (1e-5, 16741)]:
    pi = pi_for_sigma(L, sigma)
    a = 1 - (1 - N1 * pi) ** L
    print("  (a=0.5 line) sigma=%g N1=%d a=%.4f N1/2=%.1f" % (sigma, N1, a, N1 / 2))

# (2) inequality grid
bad = 0; cnt = 0
for L in [1, 2, 3, 5, 10, 30, 100]:
    for N1 in [1, 2, 5, 10, 55, 300, 2000]:
        for k in range(1, 60):
            pi = (1.0 / N1) * k / 60.0  # N1 pi <= 1 (strictly < 1)
            if N1 * pi >= 1: continue
            sigma = (1 - (1 - pi) ** L) / 4
            a = 1 - (1 - N1 * pi) ** L
            cnt += 1
            if N1 / 2 < a / (8 * sigma) - 0.5 - 1e-12:
                bad += 1; print("VIOLATION", L, N1, pi)
print("inequality N1/2 >= a/(8 sigma) - 1/2: %d cases, %d violations" % (cnt, bad))

# (3) item 2 exact
def item2(L, N1, pi):
    cells = ['c0'] + list(range(1, N1 + 1))
    probs = {'c0': 1 - N1 * pi}; probs.update({c: pi for c in range(1, N1 + 1)})
    members = ['f0', 'c0'] + list(range(1, N1 + 1))
    res = {}
    for m in members:
        human = lambda x, m=m: 1 if (m != 'f0' and x == m) else 0
        ans_c0 = human('c0')
        sil = 0.0; ab = 0.0
        for seq in itertools.product(cells, repeat=L):
            p = math.prod(probs[x] for x in seq)
            truth = max(human(x) for x in seq)
            out = []
            aborted = False
            for x in seq:
                if ans_c0 == 1:
                    y = 1 if x == 'c0' else 0
                else:
                    if x == 'c0': y = 0
                    else:
                        aborted = True; break
                out.append(y)
            if aborted: ab += p
            elif max(out) != truth: sil += p
        res[m] = (sil, ab)
    return res
a_ok = True
for (L, N1, pi) in [(1, 2, 0.2), (2, 3, 0.1), (3, 2, 0.3), (4, 2, 0.05)]:
    r = item2(L, N1, pi)
    a = 1 - (1 - N1 * pi) ** L
    for m, (sil, ab) in r.items():
        want = 0.0 if m == 'c0' else a
        if sil > 1e-15 or abs(ab - want) > 1e-12:
            a_ok = False; print("item2 mismatch", L, N1, pi, m, sil, ab, want)
print("item 2 (exact enumeration, 4 settings): silent 0 and abort a for every member:", a_ok)

# (4) Theorem 4.5 second claim from the first claim, sharp n from the first claim
bad = 0; cnt = 0
for L in [1, 2, 5, 10, 40]:
    for astar in [0, 0.1, 0.3, 0.5, 0.8]:
        for N0 in range(max(1, L), 400, 7):
            sigma = (1 - astar) * L / (2 * N0)
            if sigma >= 1: continue
            p = 1 - (1 - 1 / N0) ** L
            # least n with ((N0-n)p - L a)/(N0+L) <= sigma
            nmin = N0 - (sigma * (N0 + L) + L * astar) / p
            cnt += 1
            if max(nmin, 0.0) < (1 - astar) ** 2 * L / (4 * sigma) - L - 1e-9:  # n >= 0 always
                bad += 1; print("VIOLATION 4.5", L, astar, N0, nmin)
print("Theorem 4.5 second claim from the first: %d cases, %d violations" % (cnt, bad))
