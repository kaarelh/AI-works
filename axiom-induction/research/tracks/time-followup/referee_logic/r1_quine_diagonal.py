"""r1 (referee, logic): the diagonal construction of notes.md Theorem 3.2, built as a genuine fixed point.

c1_diagonal.py (the track's check) feeds its predictors only the step index j; the self-reference of the proof is
not exercised there.  Here the program e is a quine: its source text SRC is available inside e, and the sentence of
step j is the string
    s_j := "EX c (T(<hex of SRC>, j, c) & Out(c, 1))"
which contains e's own code as its "numeral".  The predictors read the full sentence text, so a predictor can parse
e's code out of s_j and run it.  This is the situation of the recursion theorem (e(n) = G(e, n)).

e(n): for j = 1..n, form s_j, ask the predictor (through an approximation function with error <= 2^-(j+3)) for its
pair (q0, q1) on (history, s_j), set beta_j := 0 if a0 <= a1 else 1; return the history.

Checks, for each predictor and approximation mode:
  (A) fixed point: SRC (the text e reads from its own namespace) equals the program text that was executed;
  (B) history consistency: for every n <= N, a from-scratch execution of the program on n returns a history whose
      first n-1 entries equal the history inside the run on N, and whose sentences equal s_j computed outside the
      program from the program text: so "the label of s_j" is e(j), and s_j is true iff e(j) = 1 (Thm 3.2(a));
  (C) loss: sum_j -log2 q_{b_j} >= n - 1/(2 ln 2) for every n (the notes' bound, Thm 3.2(c)), and also the sharper
      n - 1/(4 ln 2), which follows from q_b <= q_{1-b} + 2*2^-(j+3) and q_0 + q_1 <= 1 (so q_b <= 1/2 + 2^-(j+3));
      exact mode: >= n.
Predictors (all read the sentence text; none is told j directly):
  kt          KT estimator on the labels (ignores the sentence)
  hashmix     q1 from a SHA-256 hash of (sentence, history), in [0.05, 0.95]
  fi-mix      semimeasure mixture of deterministic "assigners" that read the sentence (label = bit of
              SHA-256(code part of the sentence) at position (j*k) mod 256, k = 1..40, or parity of j mod k), some of them
              partial (abstain when j % 5 == 0), plus a uniform component
  evaluator   a budgeted self-evaluator in the spirit of the assigner u of Prop 4.1: it parses e's code out of s_j,
              executes it on j with the evaluator one level deeper as predictor (depth cap 2, then 1/2), and puts
              probability 0.9 on the label that simulation returns.  It is a fixed total function of (history, sentence).
  near-half   q1 = 1/2 + 0.99 * 2^-(j+3) * sign: inside the approximation error, so that the adversarial
              approximation makes the diagonal pick the larger probability (tests the precision bound)
Approximation modes: exact; adversarial (lower the larger q_b by 2^-(j+3), raise the smaller).
"""
import hashlib
import math
import re

N_CHEAP = 120
N_EVAL = 24
out = []

# ----------------------------------------------------------------------------------------------------------------
# The library (the fixed "machine"): predictors and approximation functions, looked up by name from inside e.
SENT_RE = re.compile(r"^EX c \(T\(([0-9a-f]+), (\d+), c\) & Out\(c, 1\)\)$")


def parse_sentence(s):
    m = SENT_RE.match(s)
    return bytes.fromhex(m.group(1)).decode(), int(m.group(2))


def p_kt(hist, s):
    n1 = sum(b for _, b in hist)
    q1 = (n1 + 0.5) / (len(hist) + 1.0)
    return (1.0 - q1, q1)


def p_hashmix(hist, s):
    h = hashlib.sha256((s + '|' + ''.join(str(b) for _, b in hist)).encode()).digest()
    q1 = 0.05 + 0.9 * h[0] / 255.0
    return (1.0 - q1, q1)


def _fi_label(k, code_hash, j):
    if k % 3 == 0 and j % 5 == 0:
        return None                                      # a partial assigner abstains here
    if k % 2 == 0:
        return (code_hash[(j * k) % 32] >> (k % 8)) & 1  # reads e's code out of the sentence
    return (j // k) % 2


def p_fimix(hist, s):
    src, j = parse_sentence(s)
    code_hash = hashlib.sha256(src.encode()).digest()
    lw = []                                              # log2 weights of hypotheses still compatible with hist
    for k in range(1, 41):
        w = -float(k) - 1.0
        for (s_i, b_i) in hist:
            _, j_i = parse_sentence(s_i)
            if _fi_label(k, code_hash, j_i) != b_i:
                w = -math.inf
                break
        lw.append(w)
    lu = -1.0 - len(hist)                                # uniform component: prior 1/2, 1/2 per label
    tot = math.log2(sum(2.0 ** x for x in lw if x != -math.inf) + 2.0 ** lu)
    q = [2.0 ** (lu - 1.0 - tot), 2.0 ** (lu - 1.0 - tot)]
    for k, w in zip(range(1, 41), lw):
        if w == -math.inf:
            continue
        b = _fi_label(k, code_hash, j)
        if b is not None:
            q[b] += 2.0 ** (w - tot)
    return (q[0], q[1])


def make_evaluator(depth, cap=2):
    def p_eval(hist, s):
        if depth >= cap:
            return (0.5, 0.5)
        src, j = parse_sentence(s)
        ns = {}
        exec(src, ns)
        sim = ns['e'](j, predictor=make_evaluator(depth + 1, cap))
        b = sim[-1][1]
        return (0.1, 0.9) if b == 1 else (0.9, 0.1)
    return p_eval


def p_nearhalf(hist, s):
    _, j = parse_sentence(s)
    ones = sum(b for _, b in hist)
    e = 0.99 * 2.0 ** -(j + 3) * (1 if ones % 2 == 0 else -1)
    return (0.5 - e, 0.5 + e)


PREDICTORS = {'kt': p_kt, 'hashmix': p_hashmix, 'fi-mix': p_fimix, 'evaluator': make_evaluator(0),
              'near-half': p_nearhalf}


def approx_exact(pred, hist, s, k):
    return pred(hist, s)


def approx_adv(pred, hist, s, k):
    q0, q1 = pred(hist, s)
    d = 2.0 ** -k
    return (q0 - d, q1 + d) if q0 >= q1 else (q0 + d, q1 - d)


APPROX = {'exact': approx_exact, 'adversarial': approx_adv}

LIB = {'PREDICTORS': PREDICTORS, 'APPROX': APPROX}

# ----------------------------------------------------------------------------------------------------------------
# The quine.  PROGRAM_T.format(...) is the program text; inside it, SRC is rebuilt from its own template.
PROGRAM_T = '''T_ = {T!r}
PRED = {pred!r}
MODE = {mode!r}
SRC = T_.format(T=T_, pred=PRED, mode=MODE)
import r1_lib as LIB
def sentence(src, j):
    return "EX c (T(" + src.encode().hex() + ", " + str(j) + ", c) & Out(c, 1))"
def e(n, predictor=None, approx=None):
    predictor = predictor or LIB.PREDICTORS[PRED]
    approx = approx or LIB.APPROX[MODE]
    hist = []
    for j in range(1, n + 1):
        s = sentence(SRC, j)
        a0, a1 = approx(predictor, hist, s, j + 3)
        hist.append((s, 0 if a0 <= a1 else 1))
    return hist
'''


def program(pred, mode):
    return PROGRAM_T.format(T=PROGRAM_T, pred=pred, mode=mode)


def ext_sentence(src, j):
    return "EX c (T(" + src.encode().hex() + ", " + str(j) + ", c) & Out(c, 1))"


# make the library importable as r1_lib from inside exec'd programs
import sys
import types
lib_mod = types.ModuleType('r1_lib')
lib_mod.PREDICTORS = PREDICTORS
lib_mod.APPROX = APPROX
sys.modules['r1_lib'] = lib_mod


def run(src, n, predictor=None):
    ns = {}
    exec(src, ns)
    return ns, ns['e'](n, predictor=predictor)


B_NOTES = 1.0 / (2.0 * math.log(2.0))
B_SHARP = 1.0 / (4.0 * math.log(2.0))
out.append("r1_quine_diagonal  (deterministic; no randomness)")
out.append(f"bounds: notes n - 1/(2 ln 2) = n - {B_NOTES:.4f};  sharper n - 1/(4 ln 2) = n - {B_SHARP:.4f}")
out.append(f"{'predictor':<11} {'mode':<12} {'N':>4} {'fixpt':>6} {'hist':>6} {'min(l_n - n)':>13} {'l_N - N':>10}"
           f" {'>=notes':>8} {'>=sharp':>8}")
ok_all = True
for pname in PREDICTORS:
    for mode in APPROX:
        N = N_EVAL if pname == 'evaluator' else N_CHEAP
        src = program(pname, mode)
        ns, full = run(src, N)
        fix = (ns['SRC'] == src)
        hist_ok = True
        for n in range(1, N + 1):
            _, h = run(src, n)
            if h != full[:n]:
                hist_ok = False
            if [s for s, _ in h] != [ext_sentence(src, j) for j in range(1, n + 1)]:
                hist_ok = False
        pred = PREDICTORS[pname]
        loss, worst = 0.0, math.inf
        for j in range(1, N + 1):
            q = pred(full[:j - 1], full[j - 1][0])
            assert q[0] >= -1e-12 and q[1] >= -1e-12 and q[0] + q[1] <= 1 + 1e-9
            b = full[j - 1][1]
            loss += -math.log2(q[b]) if q[b] > 0 else math.inf
            worst = min(worst, loss - j)
        ok_n = worst >= -B_NOTES - 1e-12
        ok_s = worst >= -B_SHARP - 1e-12
        if mode == 'exact':
            ok_n = ok_s = worst >= -1e-12
        ok = fix and hist_ok and ok_n and ok_s
        ok_all &= ok
        out.append(f"{pname:<11} {mode:<12} {N:>4} {str(fix):>6} {str(hist_ok):>6} {worst:>13.6f} {loss - N:>10.3f}"
                   f" {str(ok_n):>8} {str(ok_s):>8}")
out.append(f"verdict: {'all checks pass' if ok_all else 'SOME CHECK FAILS'}")
out.append("Note: the evaluator parses e's code from s_j and runs it; it still loses >= n, because the label of s_j is")
out.append("decided against the evaluator itself, while its simulation of e uses a cheaper predictor (depth + 1).")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
