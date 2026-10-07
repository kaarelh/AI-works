"""
Abstract simulation of a weakly coherent computable credence that gradually
verifies Sigma_2 (counterexample to L3 line 447 / Sec.8 L3-T2 'coherent ceiling = Delta_2').
Each Sigma_2 sentence s has: index (birth stage), a set of witness-change stages
(finite for true s, infinite/unbounded for false s). Incompatibility edges
(PA |- s -> ~s') only between pairs not both true (PA sound), each discovered at a stage.
Credence: age a_t(s) = t - max(index, last change <= t);
P_t(s) = min(1-2^-a(s), min{2^-a(s') : s' incompatible (discovered by t, index<=t), a(s')>=a(s)}).
Check: (1) every discovered incompatible pair has P_t(s)+P_t(s') <= 1 at every t;
(2) true sentences have P_T close to 1 at horizon; (3) false ones hit 0 infinitely often.
"""
import random
from fractions import Fraction as F
random.seed(1)
T = 3000; N = 60
sent = []
for i in range(N):
    true = random.random() < 0.4
    birth = random.randint(0, 200)
    if true:
        k = random.randint(0, 5)
        changes = sorted(random.sample(range(birth, birth+400), k))
    else:
        # adversarial: geometric-ish long stable runs, but infinitely many changes
        c = birth + random.randint(1, 50); changes = []
        g = random.choice([1.3, 1.6, 2.0])
        while c < 10*T:
            changes.append(int(c)); c = c*g + random.randint(1, 30)
    sent.append(dict(true=true, birth=birth, changes=changes))
edges = {}
for i in range(N):
    for j in range(i, N):
        if sent[i]['true'] and sent[j]['true']:
            continue
        if random.random() < 0.15:
            edges[(i, j)] = random.randint(max(sent[i]['birth'], sent[j]['birth']), 1500)
def age(i, t):
    s = sent[i]
    if t < s['birth']: return None
    last = max([c for c in s['changes'] if c <= t], default=-1)
    return t - max(s['birth'], last)
viol = 0; zero_hits = {i: 0 for i in range(N)}
for t in range(T):
    a = [age(i, t) for i in range(N)]
    P = []
    for i in range(N):
        if a[i] is None: P.append(F(0)); continue
        v = 1 - F(1, 2**min(a[i], 60))
        for (x, y), d in edges.items():
            if d > t or i not in (x, y): continue
            j = y if x == i else x
            if a[j] is None: continue
            if a[j] >= a[i]:
                v = min(v, F(1, 2**min(a[j], 60)))
        P.append(v)
    for (x, y), d in edges.items():
        if d <= t and P[x] + P[y] > 1: viol += 1
    for i in range(N):
        if P[i] == 0 and t > 1500: zero_hits[i] += 1
print("pairwise violations:", viol)
tr = [i for i in range(N) if sent[i]['true']]; fa = [i for i in range(N) if not sent[i]['true']]
print("true sentences: min credence at horizon =", float(min(P[i] for i in tr)))
print("false sentences hitting 0 after t=1500 (should be all with a change after 1500):",
      sum(1 for i in fa if zero_hits[i] > 0), "/", len(fa))
