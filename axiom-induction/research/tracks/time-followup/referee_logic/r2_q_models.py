"""r2 (referee, logic): nonstandard models of Robinson's Q, used to test the Q facts the notes rely on.

Models: M = N u {a, b} with S(a) = a, S(b) = b, standard operations on N, and the forced values a + n = a, b + n = b,
x * 0 = 0.  The free entries x + y for y in {a, b} (any value in {a, b}: Q5 forces x + y to be an S-fixed point)
and x * y for y in {a, b} are enumerated; the products x * n for x in {a, b} are then forced by Q7.  Each candidate is
checked against Q1-Q7 on the truncated domain {0..K} u {a, b} (the operations are uniform in the standard part, so
this is a sanity check, not a proof).  On the models that pass, we evaluate:

  (L1) bounded lemma, z on the left:   forall y (exists z (z + y = k) -> y in {0..k}),            k <= 6
  (L2) bounded lemma, z on the right:  forall y (exists z (y + z = k) -> y in {0..k}),            k <= 6
  (D1) dichotomy, z on the left:       forall x (exists z (z + x = n) or exists z (z + n = x)),   n <= 6
  (D2) dichotomy, z on the right:      forall x (exists z (x + z = n) or exists z (n + z = x)),   n <= 6
  (F)  the false Sigma_1 sentence  exists c (S0 + c = c)  (true in no standard model): is it true in M?
  (FB) its bounded form (Prop 2.5 style)  exists c (exists z (z + c = k) and S0 + c = c),  k <= 6: true in M?

Expected (the notes, Thm 3.2(b), Rem 3.5, Prop 2.5): (L1) holds in every model of Q (Q proves it; used in Prop 2.5(a));
(D1) holds in every model (Q proves it for the "z on the left" reading; used for the Rosser variant in Rem 3.5);
(F) holds in some model, i.e. Q does not refute every false Sigma_1 sentence, which is why Thm 3.2 needs DET (or the
Rosser form) for the label-0 case and why Hanni's unbounded antecedents can be satisfied by nonstandard witnesses;
(FB) fails in every model, i.e. a numeral bound removes the nonstandard witnesses (Prop 2.5(a)).
(D2) is included to show that the orientation of the defined order matters: it fails in some model.
"""
import itertools

K = 12
STD = list(range(K + 1))
A, B = 'a', 'b'
NS = [A, B]
DOM = STD + NS
out = []


def S(x):
    return x if x in NS else x + 1


def make_model(add_tab, mul_tab):
    """add_tab[(x, y)] for y in NS; mul_tab[(x, y)] for y in NS.  Returns (add, mul) or None if outside the domain."""
    def add(x, y):
        if y in NS:
            return add_tab[(x, y)]
        if x in NS:
            return x                       # a + n = a: forced by Q4, Q5 and S(a) = a
        return x + y                       # may leave the truncated standard part
    def mul(x, y):
        if y in NS:
            return mul_tab[(x, y)]
        if x in NS:                        # x * n by Q6, Q7: x*0 = 0, x*(m+1) = x*m + x
            r = 0
            for _ in range(y):
                r = add(r, x)
            return r
        return x * y
    return add, mul


def in_dom(v):
    return v in NS or (isinstance(v, int) and v <= K)


def check_Q(add, mul):
    for x in DOM:
        if S(x) == 0:
            return False                                               # Q1
        if x != 0 and not any(S(y) == x for y in DOM):
            return False                                               # Q3
        if add(x, 0) != x or mul(x, 0) != 0:
            return False                                               # Q4, Q6
        for y in DOM:
            if x != y and S(x) == S(y):
                return False                                           # Q2
            sy = S(y)
            if not in_dom(sy):
                continue
            l5, r5 = add(x, sy), add(x, y)
            if in_dom(l5) and in_dom(r5) and in_dom(S(r5)) and l5 != S(r5):
                return False                                           # Q5
            l7, xy = mul(x, sy), mul(x, y)
            if in_dom(l7) and in_dom(xy):
                r7 = add(xy, x)
                if in_dom(r7) and l7 != r7:
                    return False                                       # Q7
    return True


def leq_left(add, x, y):        # exists z (z + x = y)
    return any(add(z, x) == y for z in DOM)


def leq_right(add, x, y):       # exists z (x + z = y)
    return any(add(x, z) == y for z in DOM)


def props(add):
    L1 = all((not leq_left(add, y, k)) or (y in STD and y <= k) for k in range(7) for y in DOM)
    L2 = all((not leq_right(add, y, k)) or (y in STD and y <= k) for k in range(7) for y in DOM)
    D1 = all(leq_left(add, x, n) or leq_left(add, n, x) for n in range(7) for x in DOM)
    D2 = all(leq_right(add, x, n) or leq_right(add, n, x) for n in range(7) for x in DOM)
    F = any(add(1, c) == c for c in DOM)
    FB = any(any(add(z, c) == k for z in DOM) and add(1, c) == c for k in range(7) for c in DOM)
    return L1, L2, D1, D2, F, FB


add_keys = [(x, y) for x in DOM for y in NS]
# the free addition entries: x + a, x + b in {a, b}; enumerate them with x grouped as {standard, a, b}
models = 0
counts = {'L1': 0, 'L2': 0, 'D1': 0, 'D2': 0, 'F': 0, 'FB': 0}
examples = {}
for std_a, std_b, aa, ab, ba, bb in itertools.product(NS, repeat=6):
    add_tab = {}
    for x in STD:
        add_tab[(x, A)], add_tab[(x, B)] = std_a, std_b
    add_tab[(A, A)], add_tab[(A, B)], add_tab[(B, A)], add_tab[(B, B)] = aa, ab, ba, bb
    for m_choice in itertools.product([0] + NS, repeat=6):
        # x * a, x * b: 0 * y = 0 is not forced; use values for (std nonzero, a, b) x (a, b)
        mul_tab = {}
        for x in STD:
            mul_tab[(x, A)] = 0 if x == 0 else m_choice[0]
            mul_tab[(x, B)] = 0 if x == 0 else m_choice[1]
        mul_tab[(A, A)], mul_tab[(A, B)], mul_tab[(B, A)], mul_tab[(B, B)] = m_choice[2:]
        add, mul = make_model(add_tab, mul_tab)
        if not check_Q(add, mul):
            continue
        models += 1
        p = props(add)
        for name, v in zip(['L1', 'L2', 'D1', 'D2', 'F', 'FB'], p):
            if v:
                counts[name] += 1
            elif name not in examples and name in ('D2',):
                examples[name] = (std_a, std_b, aa, ab, ba, bb)
        if p[4] and 'F' not in examples:
            examples['F'] = (std_a, std_b, aa, ab, ba, bb)

out.append(f"r2_q_models  (deterministic; truncation K = {K})")
out.append(f"candidate structures N u {{a, b}} passing Q1-Q7 on the truncation: {models}")
for name, desc in [('L1', 'bounded lemma, z left  (needed: Prop 2.5(a))'),
                   ('L2', 'bounded lemma, z right'),
                   ('D1', 'dichotomy, z left      (needed: Rosser form, Rem 3.5)'),
                   ('D2', 'dichotomy, z right'),
                   ('F', 'false Sigma_1 "exists c (S0 + c = c)" true'),
                   ('FB', 'its numeral-bounded form true')]:
    out.append(f"  {name:<3} {desc:<52} holds in {counts[name]:>5} of {models}")
out.append(f"  example model with D2 false: (n+a, n+b, a+a, a+b, b+a, b+b) = {examples.get('D2')}")
out.append(f"  example model with F true:   (n+a, n+b, a+a, a+b, b+a, b+b) = {examples.get('F')}")
ok = (models > 0 and counts['L1'] == models and counts['L2'] == models and counts['D1'] == models
      and counts['F'] > 0 and counts['FB'] == 0 and counts['D2'] < models)
out.append(f"verdict: {'as expected' if ok else 'UNEXPECTED'}  (L1, L2, D1 in every model; F in some; FB in none;"
           f" D2 fails in some)")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
