# Split gain by feature type in the final boosters

Source files: $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | booster | rounds | rows fitted | test err alone | raw: gain share (features used / all) | pool4: gain share (features used / all) | pool9: gain share (features used / all) | pool16: gain share (features used / all) | bars2: gain share (features used / all) | bars4: gain share (features used / all) | pairs: gain share (features used / all) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | cgbt | 100 | 1000 | 0.2208 | 0.025 (452/784) | 0.033 (525/676) | 0.073 (551/676) | 0.152 (608/676) | 0.256 (2210/2704) | 0.461 (2360/2704) | – |
| v3 | qd_dev | 1000 | ggbt | 100 | 1000 | 0.2478 | 0.065 (590/784) | 0.098 (619/676) | 0.157 (647/676) | 0.277 (666/676) | – | – | 0.404 (300/300) |
| v3 | qd_dev | 10000 | cgbt | 229 | 10000 | 0.1368 | 0.012 (552/784) | 0.022 (592/676) | 0.045 (626/676) | 0.151 (642/676) | 0.241 (2520/2704) | 0.529 (2596/2704) | – |
| v3 | qd_dev | 10000 | ggbt | 123 | 10000 | 0.1578 | 0.037 (625/784) | 0.095 (656/676) | 0.156 (670/676) | 0.317 (676/676) | – | – | 0.395 (300/300) |
| v3 | fashion_mnist | 10000 | cgbt | 255 | 10000 | 0.1216 | 0.085 (692/784) | 0.096 (726/784) | 0.100 (725/784) | 0.118 (718/784) | 0.249 (2894/3136) | 0.352 (2911/3136) | – |
| v3 | fashion_mnist | 10000 | ggbt | 242 | 10000 | 0.1222 | 0.157 (750/784) | 0.153 (769/784) | 0.162 (778/784) | 0.147 (780/784) | – | – | 0.381 (299/300) |
