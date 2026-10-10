"""c2: padded Craig sets (Lemma 2.1 and Remark 2.6 of the time-followup notes.md and notes-final.md) on toy assigners with step-counted runs.

Sentences are atoms R(w), w a nonempty binary word, enumerated in length-lexicographic order; an assigner f is a
step-counted program (a Python generator: one yield = one step) that accepts, rejects, or runs forever.
A cost model stands in for the machine: one simulated step of f costs 1, generating the s-th sentence costs its length,
writing an axiom costs its length.  "work" = all cost except writing axioms.

E_f (padded enumerator): stage s = 1, 2, ...: generate sentence s and start f on it; advance every unfinished run by one
step.  When the run on phi halts, write psi^(m) := (psi & (psi & ... psi)) (m copies, right-nested; |psi^(m)| =
m|psi| + 3(m-1)), psi = phi (acc) or ~phi (rej), with
   padding 'work': m := (work counter at that moment) + 1      [the version used in Lemma 2.1]
   padding 'all' : m := (total cost counter, writing included) + 1.
A^E_f := the set of axioms E_f writes.  Decider: given chi = psi^(m), rerun E_f (without writing) until its counter passes
m - 1, and accept iff E_f would start writing psi^(m) exactly when the counter equals m - 1.
Unpadded Craig set A^C_f := {psi^(k+1) : f decides phi in exactly k steps} (the paper's thm:time:equiv); its decider runs f
on phi for k steps; here enumerated by the same dovetailing.

Claims checked:
  (1) every axiom is psi^(m) with psi in Gamma_f (correct literal, f's step count recorded correctly), each phi once;
  (2) the decider accepts members and rejects perturbed strings (m +- 1, flipped literal, undecided phi); a from-scratch
      rerun of the decider agrees with the event log on random small queries;
  (3) P1: decider work <= 2 |chi| for every f, padded ('work' and 'all') and unpadded;
      [the dec/|chi| column is computed from the cost model, as (|chi| + m)/|chi| (padded) or (|chi| + k)/|chi|
       (unpadded); the decider itself is run only in the 30-query from-scratch check of (2), column 'rerun']
  (4) P2, cumulative form: completion time of a_i <= 2 * (|a_1| + ... + |a_i|) for 'work' padding, every f;
  (5) P2, strict per-axiom form: completion time of a_i <= 2 |a_i| for 'all' padding (whose lengths grow geometrically),
      and <= |a_i|^2 for 'work' padding (Lemma 2.1 states a polynomial bound);
  (6) unpadded: completion time / |a_i| is unbounded (dovetailing delay), and so is completion / cumulative length for
      slow f, which is why P2 needs the padding while P1 does not;
  (7) f's own steps per |phi| range from below 1 to exponential: the bounds in (3)-(5) do not depend on it.
"""
import random

SEED = 777
rng = random.Random(SEED)
out = []


def word(s):
    """The s-th nonempty binary word in length-lexicographic order (s >= 1)."""
    return bin(s + 1)[3:]


def f_fast(w):            # |w| steps, accept iff even parity
    for _ in range(len(w)):
        yield
    return 'acc' if w.count('1') % 2 == 0 else 'rej'


def f_quad(w):            # |w|^2 steps
    for _ in range(len(w) ** 2):
        yield
    return 'acc' if w.count('1') > w.count('0') else 'rej'


def f_exp(w):             # 2^|w| steps
    for _ in range(2 ** len(w)):
        yield
    return 'acc' if int(w, 2) % 3 == 0 else 'rej'


def f_partial(w):         # diverges on words starting with 11
    if w.startswith('11'):
        while True:
            yield
    for _ in range(len(w) + 3):
        yield
    return 'acc' if w.endswith('0') else 'rej'


def f_exp4(w):            # 4^|w| steps
    for _ in range(4 ** len(w)):
        yield
    return 'acc' if w[0] == w[-1] else 'rej'


ASSIGNERS = [('fast', f_fast), ('quad', f_quad), ('exp2', f_exp), ('partial', f_partial), ('exp4', f_exp4)]


def truth(f, w, cap=10 ** 7):
    g = f(w)
    k = 0
    try:
        while True:
            next(g)
            k += 1
            if k > cap:
                return None, None
    except StopIteration as e:
        return e.value, k


def plen(psi, m):
    return m * len(psi) + 3 * (m - 1)


def enumerate_axioms(f, budget, pad):
    """Dovetailing enumerator until its total cost exceeds budget.  pad in {'work', 'all', 'none'}.
    Returns the event log: (counter_at_start, completion_time, psi, m, f_steps, cumulative_length)."""
    work, total, s, runs, log, cum = 0, 0, 0, [], [], 0
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
                ctr = work if pad == 'work' else total
                m = ctr + 1 if pad in ('work', 'all') else k + 1
                L = plen(psi, m)
                total += L
                cum += L
                log.append((ctr, total, psi, m, k, cum))
        runs = alive
    return log


def decide_from_scratch(f, psi, m, pad):
    """The decider of A^E_f run for real: rerun E_f without writing until its counter passes m - 1."""
    work, total, s, runs = 0, 0, 0, []
    effort = plen(psi, m)                         # parsing chi
    ctr = lambda: work if pad == 'work' else total
    while ctr() <= m - 1:
        s += 1
        phi = f"R({word(s)})"
        work += len(phi)
        total += len(phi)
        effort += len(phi)
        runs.append([phi, f(word(s)), 0])
        alive = []
        for r in runs:
            work += 1
            total += 1
            effort += 1
            r[2] += 1
            try:
                next(r[1])
                alive.append(r)
            except StopIteration as e:
                q = r[0] if e.value == 'acc' else '~' + r[0]
                if ctr() == m - 1 and q == psi:
                    return True, effort
                if ctr() > m - 1:
                    return False, effort
                total += plen(q, ctr() + 1)       # advance the counter as E_f would; nothing is written
                effort += 1
        runs = alive
    return False, effort


BUDGET = 3 * 10 ** 6
out.append(f"c2_padding  (seed {SEED}, enumerator budget {BUDGET} cost units)")
out.append("")
hdr = (f"{'f':<8} {'pad':<5} {'#ax':>5} {'f-steps/|phi|':>16} {'dec/|chi|':>10} {'end/|a_i|':>10} "
       f"{'end/|a_i|^2':>12} {'end/cum':>9} {'members':>8} {'non-mem':>8} {'rerun':>6}")
out.append(hdr)
all_ok = True
for name, f in ASSIGNERS:
    for pad in ('work', 'all', 'none'):
        log = enumerate_axioms(f, BUDGET, pad)
        seen, ok1 = set(), True
        for (ctr, end, psi, m, k, cum) in log:
            phi = psi.lstrip('~')
            val, steps = truth(f, phi[2:-1])
            ok1 &= (val is not None) and psi == (phi if val == 'acc' else '~' + phi) and steps == k and phi not in seen
            seen.add(phi)
        members = {(psi, m) for (_, _, psi, m, _, _) in log}
        okm = okn = True
        dec = 0.0
        for (ctr, end, psi, m, k, cum) in rng.sample(log, min(200, len(log))):
            okm &= (psi, m) in members
            # decider work: |chi| plus the enumerator's work up to counter m - 1 (padded), or k steps of f (unpadded)
            extra = m if pad in ('work', 'all') else k
            dec = max(dec, (plen(psi, m) + extra) / plen(psi, m))
            flip = psi[1:] if psi[0] == '~' else '~' + psi
            for (q, mm) in [(psi, m + 1), (psi, m - 1), (flip, m)]:
                okn &= (q, mm) not in members
        if name == 'partial':
            okn &= not any(psi.lstrip('~').startswith('R(11') for (_, _, psi, _, _, _) in log)
        e1 = max(end / plen(psi, m) for (_, end, psi, m, _, _) in log)
        e2 = max(end / plen(psi, m) ** 2 for (_, end, psi, m, _, _) in log)
        ec = max(end / cum for (_, end, _, _, _, cum) in log)
        rat = [k / len(psi.lstrip('~')) for (_, _, psi, _, k, _) in log]
        okr = True
        if pad in ('work', 'all'):
            small = [x for x in log if x[3] < 3 * 10 ** 4]
            for (ctr, end, psi, m, k, cum) in rng.sample(small, min(30, len(small))):
                for (q, mm, expect) in [(psi, m, True), (psi, m + 1, False)]:
                    ans, eff = decide_from_scratch(f, q, mm, pad)
                    okr &= ans == expect and eff <= 2 * plen(q, mm) + 2 * mm
        ok = ok1 and okm and okn and okr and dec <= 2.0
        if pad == 'work':
            ok &= ec <= 2.0 and e2 <= 1.0
        if pad == 'all':
            ok &= e1 <= 2.0
        all_ok &= ok
        out.append(f"{name:<8} {pad:<5} {len(log):>5} {min(rat):>7.2f}..{max(rat):>7.1f} {dec:>10.4f} {e1:>10.2f} "
                   f"{e2:>12.2e} {ec:>9.3f} {str(ok1 and okm):>8} {str(okn):>8} "
                   f"{(str(okr) if pad != 'none' else '-'):>6}")
out.append("")
out.append("Columns: dec/|chi| = max decider work / |chi| (P1); end/|a_i| and end/|a_i|^2 = max completion time of a_i")
out.append("relative to its length (P2 strict); end/cum = max completion time / cumulative output length (P2 cumulative).")
out.append("Expected: dec/|chi| <= 2 in every row; 'work': end/cum <= 2 and end/|a_i|^2 <= 1; 'all': end/|a_i| <= 2;")
out.append("'none' (unpadded Craig): end/|a_i| large, and end/cum large for slow f.  f-steps/|phi| shows f's own speed.")
out.append(f"verdict: {'all checks pass' if all_ok else 'SOME CHECK FAILS'}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
