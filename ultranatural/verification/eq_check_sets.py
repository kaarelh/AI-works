"""Referee's checks of particular identity sets (equational.md, Sections 1, 4, 5 and 6.2).

Own evaluator, own size function, own derivation procedures.  The identity sets of Section 4 and
Section 5 are taken as data from the constructors in code/theories.py (so that it is THEIR sets
that are checked); nothing else of code/ is used.

Part C.  {f(0) = 1, x = S(f(S(S(S(x)))))} is inconsistent; {f(0) = 1, f(S(x)) = 2} is consistent
         and fits successor at 0 and 1.  Done with a breadth-first search over ground terms
         (words over {S, f} applied to 0) that returns an explicit proof, which is then re-checked
         step by step by a separate function.
Part D.  For every set of code/theories.py: size, truth of every identity for the target on a
         range, and a derivation of every value on a box by innermost rewriting (each step is an
         instance of an identity used left to right inside a term: a valid equational step).

Usage: python3 eq_check_sets.py
"""
import itertools
import os
import sys
from collections import deque

sys.setrecursionlimit(100000)
sys.dont_write_bytecode = True          # do not leave cache files in code/ or here

# =============================================================== Part C: unary words
# A ground term is a word over {S, f} (outermost letter first) applied to 0.
# A unary identity is (u, a, v, b): word u applied to leaf a  =  word v applied to leaf b.


def parse_unary(text):
    lhs, rhs = text.split("=")
    return lhs[:-1], lhs[-1], rhs[:-1], rhs[-1]


def neighbours(word, ids, L):
    """All words (of at most L letters) that one equational step turns `word` into, with the reason.
    A step replaces, behind some prefix p, an instance of one side of an identity by the
    corresponding instance of the other side."""
    out = []
    n = len(word)
    for k, (u, a, v, b) in enumerate(ids):
        for (s, sa, t, tb) in ((u, a, v, b), (v, b, u, a)):          # use the identity in both directions
            for i in range(n + 1):                                    # p = word[:i]
                rest = word[i:]
                if not rest.startswith(s):
                    continue
                tail = rest[len(s):]                                  # what the leaf of this side stands for
                if sa == "0":
                    if tail != "":
                        continue
                    tails_s = {}
                else:
                    tails_s = {sa: tail}
                p = word[:i]
                if tb == "0":
                    cands = [p + t]
                elif tb in tails_s:
                    cands = [p + t + tails_s[tb]]
                else:                                                 # a variable that the other side lacks: any word
                    cands = None
                if cands is None:
                    room = L - len(p) - len(t)
                    cands = [p + t + "".join(w) for m in range(0, room + 1) for w in itertools.product("Sf", repeat=m)]
                for c in cands:
                    if len(c) <= L and c != word:
                        out.append((c, k, i))
    return out


def find_proof(ids, start, goal, L):
    """Shortest chain of steps from start to goal through words of at most L letters, or None."""
    prev = {start: None}
    queue = deque([start])
    while queue:
        w = queue.popleft()
        if w == goal:
            chain = []
            while w is not None:
                chain.append(w)
                w = prev[w]
            return chain[::-1]
        for c, _, _ in neighbours(w, ids, L):
            if c not in prev:
                prev[c] = w
                queue.append(c)
    return None


def step_ok(w1, w2, ids):
    """Independent re-check of one step: w1 = p.s.t1 and w2 = p.s'.t2 for an identity {s(a), s'(b)}"""
    for (u, a, v, b) in ids:
        for (s, sa, t, tb) in ((u, a, v, b), (v, b, u, a)):
            for i in range(min(len(w1), len(w2)) + 1):
                if w1[:i] != w2[:i]:
                    break
                r1, r2 = w1[i:], w2[i:]
                if not (r1.startswith(s) and r2.startswith(t)):
                    continue
                t1, t2 = r1[len(s):], r2[len(t):]
                if sa == "0" and t1 != "":
                    continue
                if tb == "0" and t2 != "":
                    continue
                if sa != "0" and tb != "0" and sa == tb and t1 != t2:
                    continue
                return True
    return False


def closure_classes(ids, L):
    """Union-find closure over all words of at most L letters (plain Python, small L only)."""
    words = [""]
    for m in range(1, L + 1):
        words += ["".join(w) for w in itertools.product("Sf", repeat=m)]
    parent = {w: w for w in words}

    def find(w):
        while parent[w] != w:
            parent[w] = parent[parent[w]]
            w = parent[w]
        return w

    for w in words:
        for c, _, _ in neighbours(w, ids, L):
            ra, rb = find(w), find(c)
            if ra != rb:
                parent[ra] = rb
    return find


def part_c():
    print("== Part C ==")
    T1 = [parse_unary("f0=S0"), parse_unary("x=SfSSSx")]
    print("T1 = {f(0) = S(0),  x = S(f(S(S(S(x)))))}")
    found = None
    for L in range(6, 19):
        for m in range(1, 8):
            chain = find_proof(T1, "", "S" * m, L)
            if chain:
                found = (L, m, chain)
                break
        if found:
            break
    L, m, chain = found
    print(f"   least bound L at which a proof of 0 = S^m(0) exists (strict: every term at most L letters): L = {L}, m = {m}")
    print(f"   a shortest proof has {len(chain) - 1} steps; longest term in it: {max(len(w) for w in chain)} letters")
    assert all(step_ok(a, b, T1) for a, b in zip(chain, chain[1:])), "a step failed the re-check"
    print("   every step re-checked: OK.  The proof (terms as words applied to 0):")
    for w in chain:
        print("      " + (w if w else "(empty word, the term 0)"))
    # which numerals are identified at that bound, and nothing smaller
    for L2 in (L - 1, L):
        pairs = [(i, j) for i in range(8) for j in range(i + 1, 8) if find_proof(T1, "S" * i, "S" * j, L2)]
        print(f"   pairs i < j < 8 with S^i(0) = S^j(0) provable within bound {L2}: {pairs}")
    print("   Semantically: the second identity makes S a bijection with inverse f.S.S.S, hence f = S^-4; with f(0) = 1")
    print("   this gives 0 = S^4(1) = 5.")

    T2 = [parse_unary("f0=S0"), parse_unary("fSx=SS0")]
    print("T2 = {f(0) = S(0),  f(S(x)) = S(S(0))}")
    g = lambda n: min(n + 1, 2)
    ok = g(0) == 1 and all(g(n + 1) == 2 for n in range(1000))
    print(f"   min(x+1, 2) satisfies both identities for x < 1000: {ok}  (and for all x, plainly); so T2 is consistent")
    p0 = find_proof(T2, "f", "S", 6)
    p1 = find_proof(T2, "fS", "SS", 6)
    p7 = find_proof(T2, "f" + "S" * 7, "SS", 9)
    print(f"   proof of f(0) = 1: {p0};  of f(1) = 2: {p1};  of f(7) = 2: {p7}")
    find = closure_classes(T2, 9)
    nums = [find("S" * i) for i in range(10)]
    print(f"   closure over words of at most 9 letters: numerals 0..9 pairwise distinct: {len(set(nums)) == 10};"
          f" profile f(0..7) = {[next((y for y in range(10) if nums[y] == find('f' + 'S' * x)), -1) for x in range(8)]}")

    print("Other sets mentioned in Section 6.2:")
    for text, target in (("ffx=0 fSSx=S0", "0,0,1,1,1,..."), ("0=f0 fSx=SSx", "successor but 0 at 0"), ("0=f0 x=fSx", "predecessor"),
                         ("x=SfSx", "(Section 1) f(x) = x - 2 on the integers")):
        ids = [parse_unary(t) for t in text.split()]
        find = closure_classes(ids, 10)
        nums = [find("S" * i) for i in range(11)]
        prof = [next((y for y in range(11) if nums[y] == find("f" + "S" * x)), -1) for x in range(8)]
        print(f"   {text:18s} [{target}]: consistent within 10 letters: {len(set(nums)) == 11}; proves f(0..7) = {prof}")


# =============================================================== Part D: the sets of code/theories.py
def tsize(t):
    return 1 + sum(tsize(s) for s in t[1:] if isinstance(s, tuple))


def value(t, env, interp):
    h = t[0]
    if h == "v":
        return env[t[1]]
    if h == "0":
        return 0
    if h == "S":
        return 1 + value(t[1], env, interp)
    return interp[h](*[value(s, env, interp) for s in t[1:]])


def varset(t, acc):
    if t[0] == "v":
        acc.add(t[1])
    else:
        for s in t[1:]:
            if isinstance(s, tuple):
                varset(s, acc)
    return acc


def true_on_range(T, interp, R):
    for (s, t) in T:
        vs = sorted(varset(s, set()) | varset(t, set()))
        for u in itertools.product(range(R), repeat=len(vs)):
            env = dict(zip(vs, u))
            if value(s, env, interp) != value(t, env, interp):
                return False, (s, t, env)
    return True, None


def match_constructor(pat, n, env):
    """match a pattern built from S, 0 and variables against the number n; extend env or return False"""
    k = 0
    while pat[0] == "S":
        pat, k = pat[1], k + 1
    if n < k:
        return False
    if pat[0] == "0":
        return n == k
    if pat[0] == "v":
        if pat[1] in env and env[pat[1]] != n - k:
            return False
        env[pat[1]] = n - k
        return True
    return None                                    # not a constructor pattern


class Rewriter:
    """Innermost rewriting with the identities used left to right (or right to left) as rules
    h(patterns) -> term.  `background` gives symbols whose values on numerals are provable from
    background identities (doubling).  A pattern that contains a background symbol is matched
    by search: the background proves the numeral equal to the instance of the pattern."""

    def __init__(self, T, background=None, search=64):
        self.rules = {}
        self.bg = background or {}
        self.search = search
        for (s, t) in T:
            cands = [(lhs, rhs) for lhs, rhs in ((s, t), (t, s)) if self.is_lhs(lhs)]
            if len(cands) == 2:                      # both sides could serve: rewrite the larger into the smaller
                cands = [c for c in cands if tsize(c[0]) > tsize(c[1])] or cands[:1]
            for lhs, rhs in cands:
                self.rules.setdefault(lhs[0], []).append((lhs, rhs))
        self.memo = {}
        self.active = set()

    def is_lhs(self, t):
        """a function symbol that is not background, applied to patterns over S, 0, variables and background symbols"""
        def pattern(u):
            return u[0] in ("v", "0") or ((u[0] == "S" or u[0] in self.bg) and all(pattern(w) for w in u[1:]))
        return t[0] not in ("v", "0", "S") and t[0] not in self.bg and all(pattern(u) for u in t[1:])

    def norm(self, t, env):
        """value of the term with numbers for its variables, or None"""
        h = t[0]
        if h == "v":
            return env[t[1]]
        if h == "0":
            return 0
        if h == "S":
            v = self.norm(t[1], env)
            return None if v is None else v + 1
        args = []
        for s in t[1:]:
            v = self.norm(s, env)
            if v is None:
                return None
            args.append(v)
        if h in self.bg:
            return self.bg[h](*args)
        return self.apply(h, tuple(args))

    def apply(self, h, args):
        key = (h, args)
        if key in self.memo:
            return self.memo[key]
        if key in self.active:
            return None                              # a loop: no derivation this way
        self.active.add(key)
        results = set()
        for lhs, rhs in self.rules.get(h, []):
            if lhs == rhs:
                continue
            for env in self.matches(lhs[1:], args):
                # the right side must not need variables the left side does not bind
                if not varset(rhs, set()) <= set(env):
                    continue
                v = self.norm(rhs, env)
                if v is not None:
                    results.add(v)
        self.active.discard(key)
        if len(results) > 1:
            raise AssertionError(f"two different values derived for {key}: {results}")
        out = results.pop() if results else None
        if out is not None:
            self.memo[key] = out
        return out

    def matches(self, pats, args):
        """all bindings under which the patterns denote the numbers args"""
        envs = [dict()]
        for pat, n in zip(pats, args):
            new = []
            for env in envs:
                e2 = dict(env)
                r = match_constructor(pat, n, e2)
                if r is True:
                    new.append(e2)
                elif r is None:                      # search the free variables of the pattern
                    vs = sorted(varset(pat, set()) - set(env))
                    for u in itertools.product(range(self.search), repeat=len(vs)):
                        e3 = dict(env)
                        e3.update(zip(vs, u))
                        if self.pattern_value(pat, e3) == n:
                            new.append(e3)
            envs = new
        return envs

    def pattern_value(self, pat, env):
        h = pat[0]
        if h == "v":
            return env[pat[1]]
        if h == "0":
            return 0
        if h == "S":
            return 1 + self.pattern_value(pat[1], env)
        if h in self.bg:
            return self.bg[h](*[self.pattern_value(s, env) for s in pat[1:]])
        raise ValueError("pattern contains a symbol that is not background")


def check(name, T, interp, box, R, arity=2, background=None, expect_size=None):
    size = sum(tsize(s) + tsize(t) for s, t in T)
    ok_true, bad = true_on_range(T, interp, R)
    rw = Rewriter(T, background)
    g = interp["f"]
    pts = list(itertools.product(box, repeat=arity))
    missing = [p for p in pts if rw.apply("f", p) != g(*p)]
    flag = "" if expect_size is None else ("  size as stated" if size == expect_size else f"  SIZE DIFFERS from stated {expect_size}")
    print(f"   {name:42s} size {size:5d}  identities {len(T):3d}  all true on range: {ok_true}  "
          f"all values on the box derived: {not missing}{flag}")
    if bad or missing:
        print("      PROBLEM", bad, missing[:5])
    return size


def part_d():
    here = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, os.path.join(here, "..", "code"))
    import theories as TH                             # only the constructors of the sets are used

    V = lambda i: ("v", i)
    Z = ("0",)
    x, y = V(0), V(1)
    plus = lambda a, b: a + b
    print("\n== Part D: the two sets asked for ==")
    q4 = lambda a, b: a + b if a < 4 and b < 4 else 5
    check("quus_4", TH.quus_theory(4), {"f": q4}, range(12), 12, expect_size=2 * 64 + 2 * 16 + 2 * 4 + 18)
    g23 = lambda a, b: 0 if (a, b) == (2, 3) else a + b
    check("plus, but 0 at (2,3)", TH.patch_theory(2, 3, 0), {"f": g23}, range(12), 12, expect_size=143)

    print("\n== Part D, extended: every set and size quoted in the note ==")
    check("plus", TH.plus_theory(), {"f": plus}, range(10), 10, expect_size=12)
    check("successor", [(("f", x), ("S", x))], {"f": lambda a: a + 1}, range(10), 10, arity=1, expect_size=4)
    S = lambda t: ("S", t)
    F = lambda *a: ("f",) + a
    check("max", [(F(Z, y), y), (F(x, Z), x), (F(S(x), S(y)), S(F(x, y)))], {"f": max}, range(10), 10, expect_size=17)
    check("min", [(F(Z, y), Z), (F(x, Z), Z), (F(S(x), S(y)), S(F(x, y)))], {"f": min}, range(10), 10, expect_size=17)
    check("monus", [(F(x, Z), x), (F(Z, y), Z), (F(S(x), S(y)), F(x, y))], {"f": lambda a, b: max(a - b, 0)}, range(10), 10, expect_size=16)
    check("[x = y]", [(F(Z, Z), S(Z)), (F(S(x), Z), Z), (F(Z, S(y)), Z), (F(S(x), S(y)), F(x, y))],
          {"f": lambda a, b: int(a == b)}, range(10), 10, expect_size=23)
    for N in (3, 4, 5, 6, 8):
        q = lambda a, b, N=N: a + b if a < N and b < N else 5
        check(f"quus_{N}  (2N^3+2N^2+2N+18)", TH.quus_theory(N), {"f": q}, range(N + 5), N + 5, expect_size=2 * N ** 3 + 2 * N * N + 2 * N + 18)
    for (a, b), stated in (((1, 1), 68), ((2, 3), 143), ((4, 2), 146), ((5, 5), 296), ((8, 3), 287)):
        g = lambda p, q, a=a, b=b: 0 if (p, q) == (a, b) else p + q
        check(f"plus, but 0 at ({a},{b})", TH.patch_theory(a, b, 0), {"f": g}, range(max(a, b) + 6), max(a, b) + 6, expect_size=stated)
    for n in (1, 2, 3, 4, 6, 10, 15):
        g = lambda p, q, n=n: 0 if (p, q) == (n, 0) else p + q
        check(f"plus, but 0 at ({n},0)  (n^2+8n+36)", TH.patch_theory(n, 0, 0), {"f": g}, range(n + 6), n + 6, expect_size=n * n + 8 * n + 36)
    for j in (0, 1, 2, 3, 4):
        N = 2 ** j
        interp = {"f": lambda a, b, N=N: a + b if a < N and b < N else 5, "h": plus, "d": lambda a: 2 * a,
                  "l": lambda a, b: int(a < b), "c": lambda a, b, c: b if a else c}
        R = N + 4
        # truth: every variable over a range; the range of l, c arguments is covered by evaluation
        check(f"quus_{N} with auxiliary symbols  (79+2j)", TH.quus_aux_theory(j), interp, range(N + 4), R, expect_size=79 + 2 * j)
    for j in (1, 2, 3, 4, 5):
        N = 2 ** j
        g = lambda p, q, N=N: 0 if (p, q) == (N, 0) else p + q
        check(f"plus, but 0 at ({N},0), doubling  (j^2+10j+33)", TH.doubling_patch_theory(j), {"f": g, "d": lambda a: 2 * a},
              range(2 * N + 6), 2 * N + 6, background={"d": lambda a: 2 * a}, expect_size=j * j + 10 * j + 33)
    # the unary set of 36 symbols for "successor, but 0 at 3" (Section 6.2)
    num = lambda n: Z if n == 0 else S(num(n - 1))
    Sn = lambda t, n: t if n == 0 else S(Sn(t, n - 1))
    T36 = [(F(num(0)), num(1)), (F(num(1)), num(2)), (F(num(2)), num(3)), (F(num(3)), num(0)), (F(Sn(x, 4)), Sn(x, 5))]
    check("successor, but 0 at 3 (unary)", T36, {"f": lambda a: 0 if a == 3 else a + 1}, range(12), 12, arity=1, expect_size=36)
    Tpar = [(F(Z), Z), (F(S(Z)), S(Z)), (F(S(S(x))), F(x))]
    check("parity (unary)", Tpar, {"f": lambda a: a % 2}, range(12), 12, arity=1, expect_size=14)


if __name__ == "__main__":
    part_c()
    part_d()
