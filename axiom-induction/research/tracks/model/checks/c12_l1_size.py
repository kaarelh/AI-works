"""c12: derivation size under L1 (referee issue M2; notes-final Prop 6.9 [refuted], Lemma 6.10, Prop 6.11, Thm 6.12).

Part A.  Independent re-implementation of the referee's family (r2), in closure-normal form with de Bruijn indices:
  start from the logical axiom forall x (x = x); repeat k times: forall-E with t = p+p, then Gen on p; close with one
  forall-E.  For each k we count nu = the number of grammar nodes of the L1 tree (derivation nodes + Q nodes of the
  instantiated terms + the nodes of the geometric parameter-index chains), and the symbol size of the conclusion.
  Claims checked: size = 2^(k+3) - 1 (exponential in nu), nu linear in k, and the Lemma 6.10 bound
  size <= (c_T + 1) * nu * e^(nu/e) (c_T = 2 * max template size^2).
Part B.  Lemma 6.10 on random valid chains: random sequences of forall-E (random terms from a PCFG) and Gen steps from
  random quantified cited sentences; check, for every conclusion, the inductive bound
  s(conclusion) <= (c_T * nu + #Gen) * prod_(forall-E steps) |t|  and the final bound (c_T + 1) * nu * e^(nu/e).
Part C.  Prop 6.11 (exponential tail of nu): simulate the joint L1 process (derivation nodes with their Q bodies and
  parameter chains; no validity conditioning) and print the empirical tail of nu.  The tail must decay exponentially.
"""
import math
import random

out = []
rng = random.Random(1212)

# formulas: ('all', body) with de Bruijn ('idx', i); ('par', j); ('=', a, b); ('+', a, b); ('0',); ('S', a)
def size(f):
    return 1 + sum(size(c) for c in f[1:] if isinstance(c, tuple))


def subst_top(body, t, depth=0):
    """Replace de Bruijn index `depth` (the eliminated binder) by the closed term t (no bound variables: no shifting)."""
    if body[0] == 'idx':
        if body[1] == depth:
            return t
        return ('idx', body[1] - 1) if body[1] > depth else body     # indices of outer binders move down by one
    if body[0] == 'all':
        return ('all', subst_top(body[1], t, depth + 1))
    if body[0] == 'par':
        return body
    return (body[0],) + tuple(subst_top(c, t, depth) for c in body[1:])


def forall_elim(f, t):
    assert f[0] == 'all', 'forall-E needs a premise with root forall (validity)'
    return subst_top(f[1], t)


def abstract(f, j, depth=0):
    """Gen on parameter p_j: replace p_j by the index of the new outermost binder (depth-dependent)."""
    if f[0] == 'par':
        return ('idx', depth) if f[1] == j else f
    if f[0] == 'idx':
        return ('idx', f[1] + 1) if f[1] >= depth else f      # free indices (none in sentences) would shift
    if f[0] == 'all':
        return ('all', abstract(f[1], j, depth + 1))
    return (f[0],) + tuple(abstract(c, j, depth) for c in f[1:])


def gen(f, j):
    return ('all', abstract(f, j))


def nu_term(t):
    """Grammar nodes for a term drawn from Q: one per symbol, plus the geometric index chain of each parameter
    (index j costs j + 1 chain nodes)."""
    if t[0] == 'par':
        return 1 + (t[1] + 1)
    return 1 + sum(nu_term(c) for c in t[1:])


REFL = ('all', ('=', ('idx', 0), ('idx', 0)))
p0 = ('par', 0)
T_PP = ('+', p0, p0)
C_T = 2 * size(REFL) ** 2
rows = []
f = REFL
nu = 1                 # the citation node (reflexivity has no metavariables to instantiate)
for k in range(0, 13):
    phi = forall_elim(f, T_PP)
    nu_phi = nu + 1 + nu_term(T_PP)                       # one forall-E node and its term
    s = size(phi)
    ok_size = (s == 2 ** (k + 3) - 1)
    bound_log = math.log(C_T + 1) + math.log(nu_phi) + nu_phi / math.e
    rows.append((k, nu_phi, s, ok_size, math.log(s) <= bound_log))
    # next round: forall-E with p+p, then Gen on p_0 (Gen node + parameter chain of index 0: 1 node)
    f = gen(forall_elim(f, T_PP), 0)
    nu += (1 + nu_term(T_PP)) + (1 + 1)
for k, n_, s, a, b in rows:
    if k in (0, 1, 2, 3, 6, 9, 12):
        out.append(f"A: k = {k:2d}: nu = {n_:3d}, |phi_k| = {s:6d}, size = 2^(k+3)-1: {a}, Lemma 6.10 bound holds: {b}")
nus = [r[1] for r in rows]
out.append(f"A: nu(k) = {nus[0]} + {nus[1] - nus[0]} k (linear), size doubles per round: symbol size is exponential in nu "
           f"(ln size / nu -> ln 2 / 8 = {math.log(2) / 8:.4f}; the bound allows 1/e = {1 / math.e:.4f})")

# Part B: random chains
PQ = {'0': 0.4, 'S': 0.2, '+': 0.15, 'par': 0.25}
def rand_term():
    r = rng.random()
    acc = 0.0
    for s, p in PQ.items():
        acc += p
        if r < acc:
            break
    if s == '0':
        return ('0',)
    if s == 'S':
        return ('S', rand_term())
    if s == '+':
        return ('+', rand_term(), rand_term())
    j = 0
    while rng.random() < 0.5:
        j += 1
    return ('par', j)


def params(f):
    if f[0] == 'par':
        return {f[1]}
    return set().union(*[params(c) for c in f[1:] if isinstance(c, tuple)]) if len(f) > 1 else set()


def rand_body(nb, depth=0):
    """A random quantifier-free equation body over nb bound indices, with repeated index occurrences."""
    def rt(d):
        r = rng.random()
        if d > 3 or r < 0.35:
            return ('idx', rng.randrange(nb)) if nb else ('0',)
        if r < 0.5:
            return ('0',)
        if r < 0.65:
            return ('S', rt(d + 1))
        return ('+', rt(d + 1), rt(d + 1))
    return ('=', rt(0), rt(0))


viol = viol2 = 0
checked = 0
maxratio = 0.0
for trial in range(3000):
    nb = rng.randint(1, 3)
    body = rand_body(nb)
    f = body
    for _ in range(nb):
        f = ('all', f)
    cited = f
    tau_size = size(cited)
    nu = 1 + tau_size                    # citation node plus (generously) its instantiation nodes
    n_gen = 0
    prod_t = 1
    c_t = 2 * tau_size ** 2
    for step in range(rng.randint(1, 12)):
        if f[0] == 'all' and (rng.random() < 0.7 or not params(f)):
            t = rand_term()
            f = forall_elim(f, t)
            nu += 1 + nu_term(t)
            prod_t *= size(t)
        elif params(f):
            j = min(params(f))
            f = gen(f, j)
            nu += 1 + (j + 1)
            n_gen += 1
        else:
            break
        checked += 1
        if size(f) > (c_t * nu + n_gen) * prod_t:
            viol += 1
        if math.log(size(f)) > math.log(c_t + 1) + math.log(nu) + nu / math.e:
            viol2 += 1
        maxratio = max(maxratio, math.log(size(f)) / nu)
out.append(f"B: {checked} conclusions on 3000 random forall-E/Gen chains: violations of the inductive bound = {viol}, "
           f"of the final bound = {viol2}; max ln(size)/nu = {maxratio:.3f}")

# Part C: tail of nu for the joint process (no validity conditioning)
A_AX, A_LG, A_MP, A_GEN, A_FE = 0.3, 0.3, 0.15, 0.1, 0.15
TERM_P = {'0': 0.4, 'S': 0.2, '+': 0.1, '*': 0.1, 'var': 0.2}
TERM_CH = {'0': 0, 'S': 1, '+': 2, '*': 2, 'var': 0}
FORM = {'=': (0.3, 2, 0), '<': (0.2, 2, 0), 'not': (0.1, 0, 1), 'and': (0.1, 0, 2), 'imp': (0.1, 0, 2),
        'forall': (0.1, 0, 1), 'exists': (0.1, 0, 1)}


def joint_nu(cap=10**6):
    stack = ['D']
    n = 0
    while stack:
        x = stack.pop()
        n += 1
        if n > cap:
            return cap
        if x == 'D':
            r = rng.random()
            if r < A_AX:
                stack.append('F')                 # one formula metavariable in the cited template
            elif r < A_AX + A_LG:
                stack.extend(['F', 'F'])           # e.g. A1: two formula metavariables
            elif r < A_AX + A_LG + A_MP:
                stack.extend(['D', 'D'])
            elif r < A_AX + A_LG + A_MP + A_GEN:
                stack.extend(['D', 'P'])
            else:
                stack.extend(['D', 'T'])
        elif x == 'P':
            if rng.random() < 0.5:
                stack.append('P')
        elif x == 'T':
            keys = list(TERM_P)
            s = rng.choices(keys, [TERM_P[k] for k in keys])[0]
            stack.extend(['T'] * TERM_CH[s])
        else:
            keys = list(FORM)
            s = rng.choices(keys, [FORM[k][0] for k in keys])[0]
            stack.extend(['T'] * FORM[s][1] + ['F'] * FORM[s][2])
    return n


R = 100_000
vals = [joint_nu() for _ in range(R)]
mean = sum(vals) / R
tail = {L: sum(1 for v in vals if v >= L) / R for L in (25, 50, 100, 200, 400)}
out.append(f"C: joint process (m = {2 * A_MP + A_GEN + A_FE:.2f}, Q as in c10 with the k >= 1 term law throughout), {R} trees: mean nu = {mean:.1f}; "
           "P(nu >= L) for L = 25, 50, 100, 200, 400: " + ", ".join(f"{v:.2e}" for v in tail.values()))
if tail[200] > 0 and tail[100] > 0:
    out.append(f"C: log-tail decay per node between L = 100 and 200: {math.log(tail[100] / tail[200]) / 100:.4f} nats "
               "(exponential tail; Prop 6.11)")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
