# Per-class test error, v3 vs v2 (same test points)

Source files: $SCRATCH/p10/interp_out_final/image/v2/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

| dataset | n | class | v2 err | v3 err | v3 - v2 | ggbt alone (v3 fit) | cgbt alone (v3 fit) |
|---|---|---|---|---|---|---|---|
| qd_dev | 10000 | ocean | 0.087 | 0.084 | -0.003 | 0.103 | 0.096 |
| qd_dev | 10000 | motorbike | 0.110 | 0.095 | -0.015 | 0.126 | 0.105 |
| qd_dev | 10000 | matches | 0.269 | 0.247 | -0.022 | 0.288 | 0.254 |
| qd_dev | 10000 | grapes | 0.280 | 0.243 | -0.037 | 0.262 | 0.229 |
| qd_dev | 10000 | paper clip | 0.138 | 0.134 | -0.004 | 0.156 | 0.141 |
| qd_dev | 10000 | campfire | 0.200 | 0.158 | -0.042 | 0.201 | 0.155 |
| qd_dev | 10000 | washing machine | 0.060 | 0.055 | -0.005 | 0.074 | 0.061 |
| qd_dev | 10000 | soccer ball | 0.082 | 0.075 | -0.007 | 0.092 | 0.075 |
| qd_dev | 10000 | frying pan | 0.121 | 0.119 | -0.002 | 0.155 | 0.129 |
| qd_dev | 10000 | foot | 0.120 | 0.120 | +0.000 | 0.121 | 0.123 |
| qd_dev | 10000 | **all** | 0.1467 | 0.1330 | -0.0137 |  |  |

v3's two boosters alone on the same test points (each booster's own argmax; 'oof fit': the stacker gave ggbt no weight, so it was not refitted and the booster shown is its out-of-fold fit on n - 2000 rows):

| dataset | n | v3 (stacked) | cgbt alone | ggbt alone | cgbt-ggbt agreement | per class: cgbt / ggbt |
|---|---|---|---|---|---|---|
| qd_dev | 1000 | 0.2118 | 0.2208 | 0.2478 | 0.888 | ocean: 0.165/0.169; motorbike: 0.163/0.201; matches: 0.392/0.456; grapes: 0.386/0.433; paper clip: 0.224/0.242; campfire: 0.266/0.295; washing machine: 0.099/0.113; soccer ball: 0.142/0.156; frying pan: 0.227/0.245; foot: 0.144/0.168 |
| qd_dev | 3000 | 0.1753 | 0.1851 | 0.1968 | 0.915 | ocean: 0.129/0.130; motorbike: 0.153/0.150; matches: 0.334/0.381; grapes: 0.307/0.319; paper clip: 0.201/0.202; campfire: 0.220/0.238; washing machine: 0.094/0.105; soccer ball: 0.095/0.109; frying pan: 0.183/0.197; foot: 0.135/0.137 |
| qd_dev | 10000 | 0.1330 | 0.1368 | 0.1578 | 0.933 | ocean: 0.096/0.103; motorbike: 0.105/0.126; matches: 0.254/0.288; grapes: 0.229/0.262; paper clip: 0.141/0.156; campfire: 0.155/0.201; washing machine: 0.061/0.074; soccer ball: 0.075/0.092; frying pan: 0.129/0.155; foot: 0.123/0.121 |
| fashion_mnist | 10000 | 0.1238 | 0.1216 | 0.1222 | 0.966 | T-shirt: 0.163/0.161; trouser: 0.039/0.038; pullover: 0.197/0.191; dress: 0.110/0.105; coat: 0.179/0.181; sandal: 0.038/0.047; shirt: 0.373/0.381; sneaker: 0.048/0.040; bag: 0.030/0.034; boot: 0.039/0.044 |
| mnist | 10000 | 0.0255 | 0.0278 | 0.0392 (oof fit) | 0.981 | 0: 0.010/0.011; 1: 0.013/0.016; 2: 0.026/0.046; 3: 0.033/0.045; 4: 0.025/0.036; 5: 0.030/0.054; 6: 0.030/0.038; 7: 0.034/0.050; 8: 0.035/0.044; 9: 0.043/0.057 |
| qd_a | 10000 | 0.1422 | 0.1442 | 0.1654 (oof fit) | 0.921 | broccoli: 0.121/0.131; oven: 0.193/0.200; leaf: 0.170/0.211; strawberry: 0.126/0.144; The Eiffel Tower: 0.051/0.047; star: 0.112/0.132; piano: 0.207/0.245; camouflage: 0.238/0.287; coffee cup: 0.145/0.170; skateboard: 0.079/0.087 |
