"""r2 (referee): Prop 6.9 of notes.md -- "under L1, -ln P_T(phi) >= kappa * l_min(phi) - ln(C/Z_T)", with l_min the
least *symbol size* of a derivation of phi.

Counterexample.  The L1 grammar has Gen (abstract a parameter) and forall-E (instantiate with t ~ Q).  Start from the
logical axiom A6 = forall x (x = x).  Repeat k times:  forall-E with t = p + p ;  Gen on p.  Finish with one forall-E.
Each round costs O(1) random choices, but the instantiated term doubles the number of occurrences of the variable,
so the conclusion phi_k has size ~ 2^(k+2).  Every derivation of phi_k contains phi_k, so l_min(phi_k) >= |phi_k|.
The single tree gives a lower bound P_T(phi_k) >= Pr(tree) (Z_T <= 1), so -ln P_T(phi_k) <= c k = O(log l_min).

A second, one-node example: the A4 instance  forall x B(x) -> B(t)  with B having m occurrences of x and |t| ~ m has
size ~ m^2 but probability e^{-O(m)}.

We implement the formulas, the two rules (checking validity of each step), and the tree's probability for a concrete
choice of grammar parameters and PCFG.
"""
import math

out = []

# ---- formulas: ('all', var, body), ('=', a, b), ('+', a, b), ('par', i), ('var', name), ('0',), ('S', a)
def size(f):
    return 1 + sum(size(c) for c in f[1:] if isinstance(c, tuple))

def subst_var(f, name, t):
    if f[0] == 'var':
        return t if f[1] == name else f
    if f[0] == 'all':
        if f[1] == name:
            return f
        return ('all', f[1], subst_var(f[2], name, t))
    if f[0] == 'par':
        return f
    return (f[0],) + tuple(subst_var(c, name, t) for c in f[1:])

def abstract_par(f, i, name):
    if f[0] == 'par':
        return ('var', name) if f[1] == i else f
    if f[0] == 'var':
        return f
    if f[0] == 'all':
        return ('all', f[1], abstract_par(f[2], i, name))
    return (f[0],) + tuple(abstract_par(c, i, name) for c in f[1:])

def forall_elim(f, t):
    assert f[0] == 'all', 'forall-E needs a universally quantified premise (validity check)'
    return subst_var(f[2], f[1], t)

def gen(f, i):
    return ('all', 'x', abstract_par(f, i, 'x'))   # bound variables are renamed apart: body has no bound 'x' free

# ---- grammar parameters (any positive values work; these are subcritical: m = 2a_mp + a_gen + a_fe = 0.6)
a_ax, a_lg, a_mp, a_gen, a_fe = 0.2, 0.2, 0.2, 0.1, 0.1
m = 2 * a_mp + a_gen + a_fe
N_LOGICAL_TEMPLATES = 7          # A1..A5, reflexivity, substitutivity; cited uniformly
# PCFG on terms: root law over {0, S, +, *, par}; parameter index ~ geometric(1/2) starting at 0
q = {'0': 0.4, 'S': 0.2, '+': 0.1, '*': 0.1, 'par': 0.2}
def geom(i):
    return 0.5 ** (i + 1)
lnQ_p_plus_p = math.log(q['+']) + 2 * (math.log(q['par']) + math.log(geom(0)))   # Q(p0 + p0)
ln_gen_p0 = math.log(geom(0))
out.append(f"grammar: a_ax={a_ax}, a_lg={a_lg}, a_mp={a_mp}, a_gen={a_gen}, a_fe={a_fe}; m = {m:.2f} (< 1)")

p0 = ('par', 0)
t = ('+', p0, p0)
A6 = ('all', 'x', ('=', ('var', 'x'), ('var', 'x')))
f = A6
ln_tree = math.log(a_lg) - math.log(N_LOGICAL_TEMPLATES)       # leaf: cite A6
rows = []
BUILD = 14                     # formulas are built (and every step checked) up to k = BUILD; beyond, sizes are 2^(k+3)-1
for k in range(0, 31):
    ln_closed = ln_tree + math.log(a_fe) + lnQ_p_plus_p
    if k <= BUILD:
        phi = forall_elim(f, t)                                  # one more forall-E closes the chain
    if k in (0, 1, 2, 3, 5, 10, 14, 20, 25, 30):
        s = size(phi) if k <= BUILD else None
        rows.append((k, s, -ln_closed))
    if k < BUILD:
        # next round: forall-E with t = p0 + p0, then Gen on p0
        f = gen(forall_elim(f, t), 0)
    ln_tree += math.log(a_fe) + lnQ_p_plus_p + math.log(a_gen) + ln_gen_p0

for k, s, nl in rows:
    if s is None:
        s_txt = f"2^{k + 3}-1 = {2**(k+3)-1} (not built)"
    else:
        s_txt = f"{s}"
    out.append(f"k = {k:2d}: |phi_k| = {s_txt:>28}; -ln Pr(tree) = {nl:8.2f} nats >= -ln P_T(phi_k)")
# size formula check
f = A6
sizes = []
for k in range(0, 12):
    sizes.append(size(forall_elim(f, t)))
    f = gen(forall_elim(f, t), 0)
out.append("sizes for k = 0..11: " + ", ".join(map(str, sizes)) + "  (size = 2^(k+3) - 1: "
           + str(all(sizes[k] == 2 ** (k + 3) - 1 for k in range(12))) + ")")
per_round = -(math.log(a_fe) + lnQ_p_plus_p + math.log(a_gen) + ln_gen_p0)
out.append(f"cost per round = {per_round:.3f} nats; so -ln P_T(phi_k) <= {-(math.log(a_lg) - math.log(7) + math.log(a_fe) + lnQ_p_plus_p):.2f} "
           f"+ {per_round:.3f} k, while l_min(phi_k) >= 2^(k+3) - 1.")
out.append("For every kappa > 0 and constant C, kappa * l_min(phi_k) - ln C exceeds -ln P_T(phi_k) for large k: "
           "Prop 6.9 fails; L1's code length is at most O(log) of derivation symbol size on this family.")

# second example: one-node A4 instance with quadratic blow-up
out.append("One-node A4 example: B_m(x) := (x + ... + x = 0) with m summands, t := S^m 0.")
for mm in (5, 10, 20, 40, 80):
    # body B_m: m holes, (m-1) '+' nodes, '=' and '0' -> Q-prob of the body: (m-1) '+' choices, m hole choices, one 0
    # upper bound on the cost, assuming every PCFG production used here has probability >= 1/20
    nodes_body = (m_plus := mm - 1) + mm + 2
    nodes_t = mm + 1
    cost = -math.log(a_lg) + math.log(N_LOGICAL_TEMPLATES) + (nodes_body + nodes_t) * math.log(20)
    size_instance = (1 + 1 + nodes_body) + (nodes_body - mm + mm * nodes_t) + 1  # forall x B -> B[t/x]
    out.append(f"  m = {mm:3d}: |A4 instance| = {size_instance:6d} symbols; -ln P_T(instance) <= {cost:7.1f} nats "
               f"(ratio cost/size = {cost / size_instance:.4f})")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
