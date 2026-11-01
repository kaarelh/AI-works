"""Exact failure count of the d = 32 net smc_mse_d32_w64_s600 (meet-in-the-middle
enumeration of 2^32 inputs, nets.exact_failure_count; about 80 minutes of
CPU), to check the SMC reference estimate (writes results/exact_d32.json)."""

import json
import os
import time

from common import RES, get_net
from rareprob.nets import exact_failure_count  # noqa: E402

NAME = "smc_mse_d32_w64_s600"

if __name__ == "__main__":
    t = time.time()
    cnt = exact_failure_count(get_net(NAME))
    out = dict(name=NAME, fail_count=cnt, p_exact=cnt / 2.0 ** 32, seconds=round(time.time() - t, 1),
               method="nets.exact_failure_count (meet in the middle over all 2^32 inputs, numpy float64 order)")
    print(json.dumps(out))
    json.dump(out, open(os.path.join(RES, "exact_d32.json"), "w"), indent=1)
