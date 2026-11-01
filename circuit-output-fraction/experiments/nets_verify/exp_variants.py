"""Which deductive engine is cheapest? Exact counts of mse_d24_w32_s1500
(p = 9.7e-6, 163 failing points), mse_d24_w32_s2000 (1 failing point) and
own_mse_d24_w32_s3000 (trained longer by exp_barrier.py, p = 0) by
input branch and bound with: CROWN (enumeration threshold r_enum = 3 ... 7,
per-node or static branching), optimised slopes, and ReLU phase splitting
inside small subcubes. Cost in forward-pass equivalents (fpe) against the
meet-in-the-middle enumeration of the whole cube and Monte Carlo
(eps = 0.1, delta = 0.05). Writes results/variants.json.
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_verify import Bounder, bab, mc_cost  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")

CONFIGS = [
    ("crown r_enum=3", dict(r_enum=3)),
    ("crown r_enum=4", dict(r_enum=4)),
    ("crown r_enum=5", dict(r_enum=5)),
    ("crown r_enum=6", dict(r_enum=6)),
    ("crown r_enum=7", dict(r_enum=7)),
    ("crown r_enum=4 static order", dict(r_enum=4, branch="static")),
    ("crown r_enum=4 no probing", dict(r_enum=4, min_rate=0.0)),
    ("alpha-crown 20 it (r<=7) r_enum=4", dict(r_enum=4, alpha_iters=20, alpha_max_free=7)),
    ("alpha-crown 20 it (r<=16) r_enum=4", dict(r_enum=4, alpha_iters=20, alpha_max_free=16)),
    ("phase split 4 leaves, 20 it (r<=7) r_enum=4", dict(r_enum=4, phase_depth=2, phase_iters=20, phase_max_free=7)),
    ("phase split 8 leaves, 30 it (r<=8) r_enum=4", dict(r_enum=4, phase_depth=3, phase_iters=30, phase_max_free=8)),
    ("phase split 16 leaves, 50 it (r<=9) r_enum=4", dict(r_enum=4, phase_depth=4, phase_iters=50, phase_max_free=9)),
]


def main():
    suite = {r["name"]: r for r in json.load(open(os.path.join(NETS, "suite.json")))}
    out = []
    # the trained-longer net of exp_barrier.py (p = 0, z = 11.8)
    suite["own_mse_d24_w32_s3000"] = dict(p_exact=0.0, fail_count=0)
    for name in ["mse_d24_w32_s1500", "mse_d24_w32_s2000", "own_mse_d24_w32_s3000"]:
        folder = OUT if name.startswith("own_") else NETS
        net = load_net(os.path.join(folder, name + ".npz"))
        bd = Bounder(net)
        row = suite[name]
        if row["fail_count"] == 0:
            from rareprob.nets import exact_failure_count
            assert exact_failure_count(net) == 0
        base = dict(name=name, p=row["p_exact"], fail_count=row["fail_count"],
                    full_enum_fpe=bd.full_enum_flops() / bd.flops_forward,
                    mc_samples=mc_cost(row["p_exact"], 0.1, 0.05), runs=[])
        for label, kw in CONFIGS:
            kw = {**dict(min_rate=0.01), **kw}
            res = bab(net, bounder=bd, **kw)
            S = res.summary()
            ent = dict(label=label, exact=S["exact"], fail=S["fail"], nodes_bounded=S["nodes_bounded"],
                       points_enumerated=S["points_enumerated"], certified_safe_nodes=S["certified_safe_nodes"],
                       fpe=S["fpe"], seconds=S["seconds"])
            assert S["exact"] and S["fail"] == row["fail_count"]
            base["runs"].append(ent)
            print(name, ent, flush=True)
        out.append(base)
        json.dump(out, open(os.path.join(OUT, "variants.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
