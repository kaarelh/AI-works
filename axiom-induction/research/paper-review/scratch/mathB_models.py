"""Independent model checks (review B): Prop univ:q4 (Q - Q4 model on N u {a,b}), the R_k / Split_k
countermodel N u {e,e'}, the counterexample to the score part of Thm univ:B (B3) with a background,
Lemma univ:survivors (Lemma S1) by brute force over small atomic sentences, and the w-invariant of
Prop univ:eqfrag(a) on random rewrites.  No track code imported."""
import itertools, random

# ---------- Prop univ:q4 ----------
N = 60
A, B = 'a', 'b'
dom = list(range(N + 1)) + [A, B]

def S(x):
    if x in (A, B):
        return x
    return x + 1  # may exceed N: treat as standard number

def add(x, y):
    if isinstance(x, int) and isinstance(y, int):
        return x + y
    if x == A and isinstance(y, int):
        return y
    if x == B and isinstance(y, int):
        return B
    if y == A:
        return A if (isinstance(x, int) or x == A) else B
    if y == B:
        return B
    raise ValueError

def mul(x, y):
    if y == 0:
        return 0
    if isinstance(x, int) and isinstance(y, int):
        return x * y
    if x == A and isinstance(y, int):
        return A
    if x == B and isinstance(y, int):
        return B
    if isinstance(x, int) and y in (A, B):
        return 0 if x == 0 else B
    if x == A:
        return A
    if x == B:
        return B
    raise ValueError

viol = []
for x in dom:
    if S(x) == 0: viol.append(('Q1', x))
    if x != 0 and not any(S(y) == x for y in dom + [x - 1 if isinstance(x, int) and x > 0 else None] if y is not None):
        viol.append(('Q3', x))
    if add(x, 0) != x and x not in (A, B): viol.append(('Q4-std', x))
    if mul(x, 0) != 0: viol.append(('Q6', x))
    for y in dom:
        if x != y and S(x) == S(y): viol.append(('Q2', x, y))
        if add(x, S(y)) != S(add(x, y)): viol.append(('Q5', x, y))
        if mul(x, S(y)) != add(mul(x, y), x): viol.append(('Q7', x, y))
print('Prop univ:q4: violations of Q1-Q3, Q5-Q7 on {0..%d} u {a,b}:' % N, viol[:5], 'count', len(viol))
print('   a+0 =', add(A, 0), '(Q4 fails at a);  closed terms denote standard numbers, so closed instances hold')

# ---------- countermodel for R_k / Split_k in pure logic ----------
E1, E2 = 'e', "e'"
def S2(x):
    return E2 if x in (E1, E2) else x + 1
def add2(x, y):
    if x == 0 and y in (E1, E2):
        return E2
    if isinstance(x, int) and isinstance(y, int):
        return x + y
    return E2  # arbitrary elsewhere
ok = True
for k in range(1, 6):
    for x in list(range(30)) + [E1, E2]:
        y = x
        for _ in range(k):
            y = S2(y)
        if add2(0, y) != y:
            ok = False
print('R_k countermodel: all instances of phi(S^k x) hold for k=1..5:', ok, ';  0+e =', add2(0, E1), '!= e')

# ---------- (B3) score counterexample ----------
# B = { (forall x 0+x=x) -> S0=0 }.  Model: N u {e} with 0+e = 1 (!= e), S0 = 1 != 0.
# forall x phi is false (at e), so B holds; every closed instance 0+t=t holds (closed terms are standard);
# S0=0 is false.  Hence B u Ic(phi) does not prove S0=0, while B u {forall x phi} does.
print('B3 score counterexample: in N u {e} with 0+e=S0: forall x phi false ->', 'B true; Ic true; S0=0 false')

# ---------- Lemma S1 brute force ----------
# terms over {0, S, +, y1, y2, y3}; atomic sentences chi = (l = r); A = forall y1 y2 y3 chi.
def terms(depth):
    if depth == 0:
        return ['0', 'y1', 'y2', 'y3']
    sub = terms(depth - 1)
    out = list(sub)
    out += [('S', t) for t in sub]
    out += [('+', t, u) for t in terms(depth - 1) for u in terms(depth - 1)] if depth <= 1 else [('+', t, u) for t in terms(1) for u in terms(1)]
    return list(dict.fromkeys(out))

def subst(t, env):
    if t == '0':
        return ('num', 0)
    if isinstance(t, str):
        return env[t]
    if t[0] == 'S':
        a = subst(t[1], env)
        if a[0] == 'num':
            return ('num', a[1] + 1)
        return ('S', a)
    return ('+', subst(t[1], env), subst(t[2], env))

def evalnum(t):
    if t[0] == 'num':
        return t[1]
    if t[0] == 'S':
        return evalnum(t[1]) + 1
    return evalnum(t[1]) + evalnum(t[2])

def is_instance(l, r):
    # 0 + S^j 0 = S^j 0 syntactically
    return l[0] == '+' and l[1] == ('num', 0) and l[2][0] == 'num' and r[0] == 'num' and l[2][1] == r[1]

def subst_sym(t, env):
    # symbolic substitution, numerals as ('num',k), variable y as ('y',) with S applied
    if t == '0':
        return ('num', 0)
    if isinstance(t, str):
        return env[t]
    if t[0] == 'S':
        return ('S', subst_sym(t[1], env))
    return ('+', subst_sym(t[1], env), subst_sym(t[2], env))

def norm(t):
    if t[0] == 'S':
        a = norm(t[1])
        if a[0] == 'num':
            return ('num', a[1] + 1)
        if a[0] == 'Sy':
            return ('Sy', a[1] + 1)
        return ('S', a)
    if t[0] == '+':
        return ('+', norm(t[1]), norm(t[2]))
    return t

T1 = terms(2)
# substitution of numerals preserves the root symbol and every '+': so an output 0+S^j0=S^j0 needs
# l rooted at '+' and r free of '+'.  Pre-filter on that (justified syntactically, not by the lemma).
def hasplus(t):
    return (not isinstance(t, str)) and (t[0] == '+' or any(hasplus(s) for s in t[1:]))
lefts = [t for t in T1 if not isinstance(t, str) and t[0] == '+']
rights = [t for t in T1 if not hasplus(t)]
vals = range(0, 10)
checked = 0; inf_cases = 0; bad = []
for l in lefts:
    for r in rights:
        js = set()
        for a1, a2, a3 in itertools.product(vals, repeat=3):
            env = {'y1': ('num', a1), 'y2': ('num', a2), 'y3': ('num', a3)}
            L, R = subst(l, env), subst(r, env)
            if is_instance(L, R):
                js.add(R[1])
        checked += 1
        if len(js) < 8:
            continue
        inf_cases += 1
        # (i) some numeral instance is a false closed equation -> Q u T inconsistent
        false_eq = False
        for a1, a2, a3 in itertools.product(range(0, 5), repeat=3):
            env = {'y1': ('num', a1), 'y2': ('num', a2), 'y3': ('num', a3)}
            if evalnum(subst(l, env)) != evalnum(subst(r, env)):
                false_eq = True; break
        # (ii) some substitution of variables by 0 or S^b y gives 0 + S^a y = S^a y
        univ = False
        choices = [('num', 0)] + [('Sy', b) for b in range(0, 4)]
        for c1, c2, c3 in itertools.product(choices, repeat=3):
            env = {'y1': c1, 'y2': c2, 'y3': c3}
            Ln, Rn = norm(subst_sym(l, env)), norm(subst_sym(r, env))
            if Ln[0] == '+' and Ln[1] == ('num', 0) and Ln[2][0] == 'Sy' and Rn == Ln[2]:
                univ = True; break
        if not (false_eq or univ):
            bad.append((l, r, sorted(js)[:10]))
print(f'Lemma S1 brute force: {checked} atomic sentences, {inf_cases} yield >= 8 distinct numeral instances;'
      f' cases neither refuted by Q nor proving forall y phi(S^a y): {len(bad)}', bad[:3])

# ---------- Prop univ:eqfrag(a): w invariant ----------
def w(t):
    if t[0] == 'num0':
        return 0
    if t[0] == 'S':
        return w(t[1])
    if t[0] == '+':
        return 1 + nS(t[2]) + w(t[1]) + w(t[2])
def nS(t):
    if t[0] == 'num0':
        return 0
    if t[0] == 'S':
        return 1 + nS(t[1])
    return nS(t[1]) + nS(t[2])
def rand_term(rng, d):
    u = rng.random()
    if d == 0 or u < 0.3:
        return ('num0',)
    if u < 0.65:
        return ('S', rand_term(rng, d - 1))
    return ('+', rand_term(rng, d - 1), rand_term(rng, d - 1))
def positions(t, path=()):
    yield path, t
    if t[0] == 'S':
        yield from positions(t[1], path + (1,))
    elif t[0] == '+':
        yield from positions(t[1], path + (1,)); yield from positions(t[2], path + (2,))
def replace(t, path, new):
    if not path:
        return new
    l = list(t); l[path[0]] = replace(t[path[0]], path[1:], new); return tuple(l)
rng = random.Random(3)
nsteps = 0; badw = 0
for _ in range(20000):
    t = rand_term(rng, 6)
    for path, s in list(positions(t)):
        if s[0] == '+' and s[2] == ('num0',):          # Q4: u+0 -> u
            t2 = replace(t, path, s[1]); nsteps += 1
            if w(t) - w(t2) != 1: badw += 1
        if s[0] == '+' and s[2][0] == 'S':             # Q5: u+Sv -> S(u+v)
            t2 = replace(t, path, ('S', ('+', s[1], s[2][1]))); nsteps += 1
            if w(t) - w(t2) != 1: badw += 1
print(f'eqfrag invariant: {nsteps} random rewrites, violations of dw = -1: {badw};'
      f' threshold e^(-1/2) = {2.718281828459045 ** -0.5:.4f}')
