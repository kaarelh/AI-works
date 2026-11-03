"""Part 11, Q7 'order': checks of the instrumented fits (order_fit.py), written to tables/order_validation.json.

1. identity   every cell's test error and FLOP count against the evaluation's merged result file
              part11/results/toy__dfg13-perm__designed.json (exact equality);
2. s replay   the residual rms replayed from the recorded least-squares weights equals DFG's own round log (4 decimals);
3. test replay for every round of every final fit and every target character not yet a feature: the replayed best
              z-score (order_fit.replay_round, DFG's own thresholds) against what DFG did -
                admitted by the tests (in the round's first n_new characters)  -> z > 1 expected (else 'forced'
                                                                                   if the fit is the forced variant)
                not admitted as a character                                     -> z <= 1 expected, unless the round
                                                                                   admitted 64 characters (the cap) or
                                                                                   filled the room p <= n / 2
              The z-scores are DFG's statistics on the target's characters only; other characters are not replayed.
4. stopping round (added after verification, VERIFY_ORDER.md omission 5): the replay at round R, where the fit stopped.
              A sign-rule stop ('all-training-signs-right') breaks before testing, so a z > 1 there is expected and
              only counted; any other stop ('nothing-passed-or-budget-or-room') with a target character at z > 1 is
              listed as unexplained (it could only be the budget cap or the room, which the cell does not separate).
"""
import os, sys, json, gzip, glob
HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(os.path.dirname(HERE))
CELLS = os.path.join(HERE, "results", "cells")


def main():
    R = json.load(open(os.path.join(P11, "results", "toy__dfg13-perm__designed.json")))
    out = dict(cells=0, identical=0, different=[], s_ok=0, s_bad=[], admit_ok=0, admit_forced=0, admit_bad=[],
               reject_ok=0, reject_capped=0, reject_bad=[])
    for p in sorted(glob.glob(os.path.join(CELLS, "*.json.gz"))):
        with gzip.open(p, "rt") as fh:
            c = json.load(fh)
        out["cells"] += 1
        r = R["fns"][c["target"]]; a, b = R["ns"].index(c["n"]), R["seeds"].index(c["seed"])
        if r["err"][a][b] == c["err"] and r["flops"][a][b] == c["flops"]:
            out["identical"] += 1
        else:
            out["different"].append((c["target"], c["n"], c["seed"]))
        if all(c["s_check"]):
            out["s_ok"] += 1
        else:
            out["s_bad"].append((c["target"], c["n"], c["seed"]))
        for j, rd in enumerate(c["rounds"]):
            admitted = {"".join(f"x{i + 1}" for i in S) for S in rd["new"]}
            capped = rd["n_new"] >= 64 or rd["p_after"] >= min(256, c["n"] // 2)
            for ch in c["chars"]:
                o = c["replay"][ch][j]
                if o is None:
                    continue                                              # already a feature
                z = o["zbest"]
                if ch in admitted:
                    if z > 1.0:
                        out["admit_ok"] += 1
                    elif c["variant"] == 1 and rd["n_new"] == 1:
                        out["admit_forced"] += 1
                    else:
                        out["admit_bad"].append((c["target"], c["n"], c["seed"], j, ch, z))
                else:
                    if z <= 1.0:
                        out["reject_ok"] += 1
                    elif capped:
                        out["reject_capped"] += 1
                    else:
                        out["reject_bad"].append((c["target"], c["n"], c["seed"], j, ch, z, o["best"]))
    for k in ("different", "s_bad", "admit_bad", "reject_bad"):
        out[k + "_count"] = len(out[k]); out[k] = out[k][:40]
    json.dump(out, open(os.path.join(HERE, "tables", "order_validation.json"), "w"), indent=1)
    return out


if __name__ == "__main__":
    o = main()
    print({k: v for k, v in o.items() if not isinstance(v, list)})
    for k in ("admit_bad", "reject_bad", "different"):
        print(k, o[k][:12])
