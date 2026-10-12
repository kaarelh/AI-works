"""e5: Haenni's 'counting lengths of odd strings' example on an enumerated program class
(track notes §5.3).  Exact Bayes mixture over the grammar of code/sfi_dsl.py.

Training data: (x, |x|) for every string of odd length 1, 3, 5, 7 (170 pairs).
Test inputs: every string of even length 2, 4, 6, 8.
We report the posterior predictive probability of the intended label |x| and of the
label 0, averaged over test strings of each length, for several priors:
  * p_plain = P(program has no top-level 'if') in {0.5, 0.9, 0.99};
  * a 'tilted machine' that adds one program, "if even(len) then 0 else len",
    with prior mass equal to that of all plain programs (cf. context track Prop 2.4).
Then we reveal correctly labelled even-length examples one length at a time and
recompute: the errors are a bounded resource (track notes Prop 4.1; context track Thm 2.7).

No randomness is used.  Output in e5_dsl_odd_lengths.out.txt.
"""
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..", "..", "..", "code")))
import sfi_dsl as dsl  # noqa: E402

OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def summarise(domain, preds, test_idx, lengths):
    res = {}
    for L in lengths:
        js = [j for j, x in enumerate(test_idx) if len(domain[x]) == L]
        pc = np.mean([preds[j].get(L, 0.0) for j in js])
        p0 = np.mean([preds[j].get(0, 0.0) for j in js])
        pmin = np.min([preds[j].get(L, 0.0) for j in js])
        res[L] = (pc, p0, pmin)
    return res


def main():
    domain = dsl.all_strings(range(1, 9))
    lens = np.array([len(s) for s in domain])
    say("e5_dsl_odd_lengths.py (deterministic)")
    say(f"domain: all strings of length 1..8 ({len(domain)} strings)")
    ec = dsl.enumerate_expressions(domain, depth_max=2)
    say(f"expression classes (distinct value vectors, depth <= 2): {len(ec.mass)}; total prior mass {ec.mass.sum():.6f}")
    conds = dsl.conditions(domain)
    say(f"conditions: {len(conds)}; total condition prior {sum(c[1] for c in conds):.6f}")
    train_idx = np.array([i for i, s in enumerate(domain) if len(s) % 2 == 1])
    train_y = lens[train_idx]
    test_idx = np.array([i for i, s in enumerate(domain) if len(s) % 2 == 0])
    say(f"training: {len(train_idx)} odd-length strings labelled by length; test: {len(test_idx)} even-length strings")
    # which plain expression classes are consistent with training, and what they do on test
    ok = np.all(ec.values[:, train_idx] == train_y[None, :], axis=1)
    agree_test = np.all(ec.values[ok][:, test_idx] == lens[test_idx][None, :], axis=1)
    say(f"plain expression classes consistent with training: {ok.sum()} (mass {ec.mass[ok].sum():.6f}); "
        f"of these, agreeing with len on all test strings: {agree_test.sum()} (mass {ec.mass[ok][agree_test].sum():.6f})")
    say("examples of consistent plain classes:", [ec.example[i] for i in np.where(ok)[0][:6]])
    say("")
    say("Posterior predictive on even-length test strings (mean over strings of each length):")
    say("  prior                        | P(correct): L=2     L=4     L=6     L=8   | P(label 0): L=2  L=4 ... | min P(correct)")
    lengths = [2, 4, 6, 8]
    m_plain_ok = ec.mass[ok].sum()
    for p_plain in [0.5, 0.9, 0.99]:
        Z, preds = dsl.posterior_predictive(ec, conds, train_idx, train_y, test_idx, p_plain=p_plain)
        r = summarise(domain, preds, test_idx, lengths)
        say(f"  p_plain={p_plain:<5}                | " + "  ".join(f"{r[L][0]:.5f}" for L in lengths)
            + " | " + "  ".join(f"{r[L][1]:.2e}" for L in lengths) + f" | {min(r[L][2] for L in lengths):.5f}")
    # analytic size of the 'if even(len) then 0 else len' program and of all if-even(len) variants
    p_if = 0.5
    pc_even_len = (1 / 5) * (1 / 6)
    m_len = ec.mass[[i for i in range(len(ec.mass)) if np.array_equal(ec.values[i], lens)][0]]
    m_zero = ec.mass[[i for i in range(len(ec.mass)) if np.all(ec.values[i] == 0)][0]]
    say(f"  [p_plain=0.5] prior mass of class 'len' = {m_len:.6f}; of class '0' = {m_zero:.6f}")
    say(f"  [p_plain=0.5] mass of 'if even(len) then 0 else len' programs = "
        f"{p_if*pc_even_len*m_zero*m_len:.3e} vs plain consistent mass {0.5*m_plain_ok:.3e}"
        f" -> ratio {p_if*pc_even_len*m_zero*m_len/(0.5*m_plain_ok):.3e}")
    # tilted machine
    bad = np.where(lens % 2 == 0, 0, lens)
    for tilt in [1.0, 10.0]:
        Z, preds = dsl.posterior_predictive(ec, conds, train_idx, train_y, test_idx, p_plain=0.5,
                                            extra_programs=[(bad, tilt * 0.5 * m_plain_ok)])
        r = summarise(domain, preds, test_idx, lengths)
        say(f"  tilted x{tilt:<4} (extra program)  | " + "  ".join(f"{r[L][0]:.5f}" for L in lengths)
            + " | " + "  ".join(f"{r[L][1]:.2e}" for L in lengths) + f" | {min(r[L][2] for L in lengths):.5f}")
    say("")
    say("Online: reveal correctly labelled even-length strings, then predict the remaining even lengths (p_plain=0.5)")
    revealed = list(train_idx)
    for Lrev in [2, 4, 6]:
        add = [i for i, s in enumerate(domain) if len(s) == Lrev]
        revealed += add
        tr = np.array(revealed)
        rest = [L for L in lengths if L > Lrev]
        te = np.array([i for i, s in enumerate(domain) if len(s) in rest])
        Z, preds = dsl.posterior_predictive(ec, conds, tr, lens[tr], te, p_plain=0.5)
        r = summarise(domain, preds, te, rest)
        say(f"  after all strings of length <= {Lrev} revealed: -log2 Z = {-math.log2(Z):.3f}; "
            + ", ".join(f"P(wrong | L={L}) = {1-r[L][0]:.3e}" for L in rest))
    # single revealed even example: shows that one example does not kill all wrong variants
    one = [i for i, s in enumerate(domain) if s == "00"]
    tr = np.array(list(train_idx) + one)
    te = np.array([i for i, s in enumerate(domain) if len(s) in (4, 6, 8)])
    Z, preds = dsl.posterior_predictive(ec, conds, tr, lens[tr], te, p_plain=0.5)
    r = summarise(domain, preds, te, [4, 6, 8])
    say("  after the single extra example ('00', 2): " + ", ".join(f"P(wrong | L={L}) = {1-r[L][0]:.3e}" for L in [4, 6, 8]))
    with open(os.path.join(HERE, "e5_dsl_odd_lengths.out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
