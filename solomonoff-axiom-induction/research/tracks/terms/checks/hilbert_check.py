"""hilbert_check.py -- an independent checker for the derivations of the `terms` thread.

Language: closed terms over e, s0, s1 written as `word.base`, where `word` lists the function letters
from the outside in (so `0110.e` is s0(s1(s1(s0(e)))) = t_{0110}) and `base` is `e` or a variable name.
Formulas are written in prefix notation, tokens separated by single spaces:
    R t            unary observable predicate R
    C t t          binary (theoretical) relation C
    E t t          binary observable relation E (used only for the binary-observable example)
    Q t t          equality t = t
    N F            negation
    I F G          implication F -> G
    A v F          universal quantifier
Calculus (a fragment of the AI-paper's Hilbert calculus K, enough for the derivations here):
    ax   -- a member of the theory (checked by the caller's membership test)
    A4   -- forall v F -> F[t/v] with t a closed term
    MP i j -- from line i (= F) and line j (= F -> G) infer G
The checker parses the strings itself and shares no code with the generators.
"""


def parse(s):
    toks = s.split(" ")
    pos = [0]

    def term():
        t = toks[pos[0]]
        pos[0] += 1
        word, base = t.split(".")
        assert set(word) <= {"0", "1"}, t
        return (word, base)

    def form():
        t = toks[pos[0]]
        pos[0] += 1
        if t == "R":
            return ("R", term())
        if t in ("C", "E", "Q"):
            a = term()
            b = term()
            return (t, a, b)
        if t == "N":
            return ("N", form())
        if t == "I":
            a = form()
            b = form()
            return ("I", a, b)
        if t == "A":
            v = toks[pos[0]]
            pos[0] += 1
            return ("A", v, form())
        raise ValueError("bad token " + t)

    f = form()
    if pos[0] != len(toks):
        raise ValueError("trailing tokens")
    return f


def size(f):
    """Number of symbols: each function letter, base, predicate, connective, quantifier, variable."""
    k = f[0]
    if k == "R":
        return 1 + len(f[1][0]) + 1
    if k in ("C", "E", "Q"):
        return 1 + len(f[1][0]) + 1 + len(f[2][0]) + 1
    if k == "N":
        return 1 + size(f[1])
    if k == "I":
        return 1 + size(f[1]) + size(f[2])
    return 2 + size(f[2])


def _sub_term(t, v, w):
    return (t[0] + w, "e") if t[1] == v else t


def subst(f, v, w):
    """Replace the free occurrences of variable v by the closed term t_w."""
    k = f[0]
    if k == "R":
        return ("R", _sub_term(f[1], v, w))
    if k in ("C", "E", "Q"):
        return (k, _sub_term(f[1], v, w), _sub_term(f[2], v, w))
    if k == "N":
        return ("N", subst(f[1], v, w))
    if k == "I":
        return ("I", subst(f[1], v, w), subst(f[2], v, w))
    if f[1] == v:  # v is bound here
        return f
    return ("A", f[1], subst(f[2], v, w))


def _find_witness(phi, psi, v):
    """Find a word w with subst(phi, v, w) == psi, by locating the first free occurrence of v."""
    k = phi[0]
    if k != psi[0]:
        return None
    if k == "R":
        terms = [(phi[1], psi[1])]
    elif k in ("C", "E", "Q"):
        terms = [(phi[1], psi[1]), (phi[2], psi[2])]
    else:
        terms = []
    for a, b in terms:
        if a[1] == v:
            if b[1] != "e" or not b[0].startswith(a[0]):
                return None
            return b[0][len(a[0]):]
    if k == "N":
        return _find_witness(phi[1], psi[1], v)
    if k == "I":
        w = _find_witness(phi[1], psi[1], v)
        if w is not None:
            return w
        return _find_witness(phi[2], psi[2], v)
    if k == "A":
        if phi[1] != psi[1] or phi[1] == v:
            return None
        return _find_witness(phi[2], psi[2], v)
    return None


def is_A4(f):
    if f[0] != "I" or f[1][0] != "A":
        return False
    v, phi = f[1][1], f[1][2]
    psi = f[2]
    w = _find_witness(phi, psi, v)
    if w is None:
        return phi == psi  # vacuous quantifier (v not free)
    return subst(phi, v, w) == psi


def check(lines, is_member):
    """lines: list of (formula_string, just); just = ('ax',) | ('A4',) | ('MP', i, j).
    Returns (ok, message, parsed_lines)."""
    parsed = []
    for n, (s, just) in enumerate(lines):
        try:
            f = parse(s)
        except Exception as exc:  # noqa: BLE001
            return False, f"line {n}: parse error {exc}", parsed
        if just[0] == "ax":
            if not is_member(s, f):
                return False, f"line {n}: not an axiom: {s[:80]}", parsed
        elif just[0] == "A4":
            if not is_A4(f):
                return False, f"line {n}: not an A4 instance: {s[:80]}", parsed
        elif just[0] == "MP":
            i, j = just[1], just[2]
            if not (0 <= i < n and 0 <= j < n):
                return False, f"line {n}: MP cites a later line", parsed
            if parsed[j] != ("I", parsed[i], f):
                return False, f"line {n}: MP mismatch", parsed
        else:
            return False, f"line {n}: unknown justification", parsed
        parsed.append(f)
    return True, "ok", parsed
