"""Referee C r1: small factual checks.
(a) B_2 circuit size of MAJ_3 (is 4 minimal?) by exhaustive search over <=3-gate circuits on 3 inputs.
(b) cost of PAR_8 in the Fourier-sign class F_{8,1} at d=30, against the 7-gate circuit (65 nats) and junta (193).
(c) level-1 Fourier weight of MAJ_9, i.e. what Proposition C1.5(1) gives for maj9 with the 9 degree-1 characters."""
import itertools, math, sys
sys.dont_write_bytecode = True
import c_common as cc
pts = list(itertools.product([0, 1], repeat=3)); full = (1 << 8) - 1
inp = []
for i in range(3):
    v = 0
    for k, p in enumerate(pts):
        if p[i]: v |= 1 << k
    inp.append(v)
maj = 0
for k, p in enumerate(pts):
    if sum(p) >= 2: maj |= 1 << k
def ap(tt, a, b):
    out = 0
    for ba in (0, 1):
        for bb in (0, 1):
            if (tt >> (2 * ba + bb)) & 1:
                out |= (a if ba else ~a & full) & (b if bb else ~b & full)
    return out
reach = [set(inp)]
level = {frozenset(inp)}
found = None
for T in range(1, 4):
    nxt = set()
    for W in level:
        Wl = list(W)
        for a in Wl:
            for b in Wl:
                for tt in range(16):
                    v = ap(tt, a, b)
                    if v not in W: nxt.add(W | {v})
    level = nxt
    if any(maj in W for W in level):
        found = T; break
print(f"(a) MAJ_3 computable with <= 3 B_2 gates: {found is not None} (so its circuit size is {'<=3' if found else '4 (given the 4-gate formula)'})")
d = 30
D8 = sum(math.comb(d, i) for i in range(1, 9))
print(f"(b) ln|F_(8,1)| = ln D_8* + ln Phi(2,1) = {math.log(D8) + cc.log_Phi(2, 1):.1f} nats (vs 65 as a 7-gate circuit, 193 as an 8-junta)")
u9 = math.comb(8, 4) / 2 ** 8
print(f"(c) MAJ_9: level-1 weight = 9 u_9^2 = {9 * u9 ** 2:.4f}; Prop C1.5(1) with the 9 linear characters gives dis <= {1 - 9 * u9 ** 2:.3f},"
      f" whereas sgn(sum x_i) = MAJ_9 exactly")
