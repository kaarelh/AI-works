"""r2: the generation-time penalty P2 of time-followup notes.md (Def 1.1, Lemma 2.1(c), Thm 2.2(b), Rem 2.6).

Syntax and cost model as in checks/c2_padding.py: sentences are atoms R(w), w a nonempty binary word, |R(w)| = |w| + 3,
~psi adds 1; psi^(m) := (psi & (psi & ... psi)) has length m|psi| + 3(m - 1).  One simulated step of an assigner costs 1,
generating a sentence costs its length, writing an axiom costs its length.

Part A (strict form e_i = O(t(|a_i|)) is a sparsity condition).  By step N an enumerator has completed at most N outputs,
  so a set with more than C*t(L) members of length <= L has no strict-form enumerator with constant C.  We count members
  of length <= L for
    (i)   the unpadded Craig set A^C_f of a fast total assigner (f decides R(w) in exactly |w| steps): ~2^sqrt(L) members;
    (ii)  the schema {R(w) -> R(w)} (a DT-style template with one metavariable, instantiated on atoms): ~2^(L/2);
    (iii) the padded set Pad(q) of Lemma 2.1: at most one member per counter value, members longer than the counter,
          so at most L members of length <= L,
  and report the least L at which (i), (ii) exceed C*L^a* for C = 1, 10^6 and a* = 3, 5.  (i) and (ii) have no
  strict-form enumerator at all; (iii) does.  So P2-strict excludes every set with superpolynomially many short members.
Part B (polynomial delay, the standard enumeration-complexity notion).  For the c2 enumerator with 'work' padding, the
  delay e_i - e_(i-1) is bounded by a polynomial in |a_i| (here: delay <= |a_i|), for the slow assigners of c2 too; for
  the unpadded Craig set the delay over |a_i| is large.  So Lemma 2.1's padding also meets polynomial delay, which does
  not exclude dense schemas.
Part C (Rem 2.6, cumulative form).  f_pow2 decides R(w_s) in |R(w_s)| steps if s is a power of 2 and loops otherwise
  (w_s the s-th word).  The dovetailing enumerator of A^C_f completes the j-th axiom after ~4^j/2 steps while the
  cumulative length is O(j^3): ratio unbounded (the notes' claim, true for this enumerator).  A different enumerator,
  a constant-size wrapper around f that runs f only on s = 2^j, completes the j-th axiom within a bounded multiple of
  the cumulative length: the SET A^C_f is cheap to enumerate in the cumulative form.
"""
import math

out = []


def word(s):
    return bin(s + 1)[3:]


def plen(L_psi, m):
    return m * L_psi + 3 * (m - 1)


# ---------------------------------------------------------------- Part A
out.append("Part A: members of length <= L, against C*L^a* (strict form needs count <= C*t(L) for all large L).")


def count_craig_fast(L):
    """Unpadded Craig set of f deciding R(w) in |w| steps: one member per w (accepted or rejected literal)."""
    tot = 0
    n = 1
    while plen(n + 3, n + 1) <= L:
        # f_fast of c2 accepts iff w has an even number of 1s: 2^(n-1) words accepted (axiom R(w)^(n+1)),
        # 2^(n-1) rejected (axiom (~R(w))^(n+1), one symbol longer per copy)
        tot += 2 ** (n - 1)
        if plen(n + 4, n + 1) <= L:
            tot += 2 ** (n - 1)
        n += 1
    return tot


def count_template(L):
    """{R(w) -> R(w)}: length 2(|w| + 3) + 3 (parentheses and arrow)."""
    tot = 0
    n = 1
    while 2 * (n + 3) + 3 <= L:
        tot += 2 ** n
        n += 1
    return tot


out.append(f"{'set':<22} {'C':>8} {'a*':>3} {'least L with count > C L^a*':>28} {'count there':>14}")
for name, fn in [('Craig, fast f', count_craig_fast), ('{R(w) -> R(w)}', count_template)]:
    for C in (1, 10 ** 6):
        for astar in (3, 5):
            L = 4
            while fn(L) <= C * L ** astar:
                L += 1 if L < 2000 else max(1, L // 200)
                if L > 10 ** 6:
                    break
            out.append(f"{name:<22} {C:>8} {astar:>3} {L:>28} {fn(L):>14.3e}")
out.append("Pad(q) (Lemma 2.1): at most L members of length <= L for every L (one per counter value T, length >= T+1),")
out.append("  so it never exceeds C L^a* with C >= 1.")
out.append("  -> no enumerator of the fast Craig set or of the template {R(w) -> R(w)} meets the strict form, whatever")
out.append("     its order; P2-strict admits only sparse sets (Pad(q) among them) and excludes every schema.")
out.append("")

# ---------------------------------------------------------------- Part B (reuses c2's enumerator, cost model unchanged)


def f_fast(w):
    for _ in range(len(w)):
        yield
    return 'acc' if w.count('1') % 2 == 0 else 'rej'


def f_exp(w):
    for _ in range(2 ** len(w)):
        yield
    return 'acc' if int(w, 2) % 3 == 0 else 'rej'


def f_partial(w):
    if w.startswith('11'):
        while True:
            yield
    for _ in range(len(w) + 3):
        yield
    return 'acc' if w.endswith('0') else 'rej'


def f_exp4(w):
    for _ in range(4 ** len(w)):
        yield
    return 'acc' if w[0] == w[-1] else 'rej'


def enumerate_axioms(f, budget, pad):
    """Copy of checks/c2_padding.py's dovetailing enumerator.  Returns (counter, completion time, |a_i|) per axiom."""
    work, total, s, runs, log = 0, 0, 0, [], []
    while total <= budget:
        s += 1
        phi = f"R({word(s)})"
        work += len(phi)
        total += len(phi)
        runs.append([phi, f(word(s)), 0])
        alive = []
        for r in runs:
            work += 1
            total += 1
            r[2] += 1
            try:
                next(r[1])
                alive.append(r)
            except StopIteration as e:
                k = r[2] - 1
                psi = r[0] if e.value == 'acc' else '~' + r[0]
                ctr = work
                m = ctr + 1 if pad == 'work' else k + 1
                L = plen(len(psi), m)
                total += L
                log.append((ctr, total, L))
        runs = alive
    return log


out.append("Part B: delay e_i - e_(i-1) relative to |a_i| (c2 cost model, budget 3e6).")
out.append(f"{'f':<8} {'pad':<5} {'#ax':>6} {'max delay/|a_i|':>16} {'max delay/|a_i|^2':>18}")
for name, f in [('fast', f_fast), ('exp2', f_exp), ('partial', f_partial), ('exp4', f_exp4)]:
    for pad in ('work', 'none'):
        log = enumerate_axioms(f, 3 * 10 ** 6, pad)
        prev = 0
        r1 = r2 = 0.0
        for (_, end, L) in log:
            d = end - prev
            r1 = max(r1, d / L)
            r2 = max(r2, d / L ** 2)
            prev = end
        out.append(f"{name:<8} {pad:<5} {len(log):>6} {r1:>16.3f} {r2:>18.3e}")
out.append("  -> with Lemma 2.1's padding the delay stays below ~|a_i| (polynomial delay); unpadded it does not.")
out.append("")

# ---------------------------------------------------------------- Part C
out.append("Part C: Rem 2.6 cumulative example, f_pow2 (halts in |phi_s| steps iff s is a power of 2, else loops).")
J = 20
pow2 = {2 ** j: j for j in range(J + 1)}
# dovetailing enumerator (c2 schedule): stage s costs |phi_s| + (number of live runs advanced)
total, live, halts, cum, dov = 0, 0, {}, 0, []
# a run for s = 2^j halts on its (k+1)-th advance, k = |phi_s|, i.e. at stage s + k
for s in range(1, 2 ** J + 2 * J + 10):
    Ls = len(word(s)) + 3
    total += Ls
    live += 1
    total += live                                         # advance every live run by one step
    if s in pow2:
        halts.setdefault(s + Ls, []).append(s)
    for s0 in halts.pop(s, []):
        live -= 1
        k = len(word(s0)) + 3
        L = plen(len(word(s0)) + 3, k + 1)
        total += L
        cum += L
        dov.append((pow2[s0], total, cum))
# constant-size alternative enumerator: run f only on s = 2^j
smart, total, cum = [], 0, 0
for j in range(J + 1):
    s = 2 ** j
    Ls = len(word(s)) + 3
    total += Ls + Ls                                      # generate phi_s, run f for k = |phi_s| steps
    L = plen(Ls, Ls + 1)
    total += L
    cum += L
    smart.append((j, total, cum))
out.append(f"{'j':>3} {'dovetail end':>14} {'dovetail end/cum':>17} {'wrapper end':>12} {'wrapper end/cum':>16}")
for (j, e1, c1), (_, e2, c2) in zip(dov, smart):
    if j % 2 == 0 or j == J:
        out.append(f"{j:>3} {e1:>14} {e1 / c1:>17.2f} {e2:>12} {e2 / c2:>16.3f}")
out.append("  -> dovetailing: end/cum grows like 4^j/j^3 (not polynomial in cum); the wrapper that runs f on powers of 2")
out.append("     only: end/cum <= ~1.2.  'A^C_f is not cheap to enumerate' is a property of the dovetailing enumerator, not")
out.append("     of the set A^C_f, for the notes' own example.")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
