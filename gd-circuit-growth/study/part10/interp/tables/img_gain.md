# Split gain by feature type in the final boosters

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | booster | rounds | rows fitted | test err alone | raw: gain share (features used / all) | pool4: gain share (features used / all) | pool9: gain share (features used / all) | pool16: gain share (features used / all) | bars2: gain share (features used / all) | bars4: gain share (features used / all) | pairs: gain share (features used / all) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | cgbt | 100 | 1000 | 0.2208 | 0.025 (452/784) | 0.033 (525/676) | 0.073 (551/676) | 0.152 (608/676) | 0.256 (2210/2704) | 0.461 (2360/2704) | – |
| v3 | qd_dev | 1000 | ggbt | 100 | 1000 | 0.2478 | 0.065 (590/784) | 0.098 (619/676) | 0.157 (647/676) | 0.277 (666/676) | – | – | 0.404 (300/300) |
