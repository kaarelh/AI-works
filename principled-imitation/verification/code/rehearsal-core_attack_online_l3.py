#!/usr/bin/env python3
"""
Follow-up to rehearsal-core_attack_online.py: for L = 3 and q = 1/3 the first search
found a loss factor S_frozen/(L ln(W/w(P))) = 1.4416 with four runs, above the limit
27/19 = 1.4211 of the example in Proposition 10.3 of research/prove-c/rehearsal-core.md
(two functions that differ everywhere).  This script repeats the search with another
seed and prints the best instance in full, so that the value can be recomputed by hand
or by another program.  (Generator, enumeration and perturbation as in the first script.)
"""
import math, random, importlib.util, os

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("atk_on", os.path.join(here, "rehearsal-core_attack_online.py"))
ON = importlib.util.module_from_spec(spec); spec.loader.exec_module(ON)
R1 = ON.R1

def main():
    rng = random.Random(3303)
    L, r = 3, 4
    best = (0.0, None)
    for restart in range(4):
        nx, ny, nz, nh = rng.choice([(2, 2, 1, 2), (3, 2, 1, 3), (3, 2, 2, 2)])
        inst = R1.make_instance(rng, nx, ny, L, nz, nh, rng.choice(['det', 'stoch']))
        try: cur = ON.ratios(inst, r, 1.0/L)['loss']
        except (ValueError, ZeroDivisionError): continue
        for step in range(160):
            cand = R1.perturb(rng, inst, rng.choice([0.05, 0.3, 1.0]))
            try: v = ON.ratios(cand, r, 1.0/L)['loss']
            except (ValueError, ZeroDivisionError, OverflowError): continue
            if v > cur: cur = v; inst = cand
        print(f"restart {restart}: nx={nx} ny={ny} nz={nz} nh={nh}: best S_frozen/(L c) = {cur:.6f}")
        if cur > best[0]: best = (cur, inst)
    val, inst = best
    example = sum((1-1.0/L)**(L*i) for i in range(r))
    print(f"best over the restarts: {val:.6f};  example of Proposition 10.3 with {r} runs: {example:.6f}, its limit: {1/(1-(1-1.0/L)**L):.6f};  proved bound: {(1-1.0/L)**(-(L-1)):.4f}")
    out = ON.ratios(inst, r, 1.0/L)
    W = sum(inst['w'])
    print("the instance:")
    print("  weights:", [float(f"{w:.6g}") for w in inst['w']], " W =", f"{W:.6g}", " ln(W/w(P)) =", f"{math.log(W/inst['w'][0]):.6g}")
    print("  D0:", [float(f"{p:.6g}") for p in inst['D0']])
    for h, rows in enumerate(inst['hyps']):
        print(f"  hypothesis {h}{' (the human)' if h == 0 else ''}:", [[float(f'{v:.6g}') for v in row] for row in rows])
    print("  scaffold (z, earlier answers) -> input, -1 = STOP; answer index", inst['ny'], "= no answer:")
    for k in sorted(inst['nxt']):
        print("   ", k, "->", inst['nxt'][k])
    print("  all ratios for this instance:", {k: float(f"{v:.6g}") for k, v in out.items()})

if __name__ == '__main__':
    main()
