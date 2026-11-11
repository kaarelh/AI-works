# Regions of the contribution maps (v3, n = 10000, seed 0)

Source: $SCRATCH/p10/interp_out_final/image/v3/<dataset>__n10000__s0.npz (image_regions.py; regions in the script). share = the region's part of the class's net evidence (map summed over the region / over the image); blank = the part of the region's evidence on pixels blank in the point (x <= 0.1); ink = mean of the class's mean image over the region / the same for the other 9 classes.

| dataset | class | region | area share | ink: class / others | cgbt share | cgbt blank | ggbt share | ggbt blank |
|---|---|---|---|---|---|---|---|---|
| qd_dev | ocean | horizon line (rows 13-15) | 0.107 | 0.410 / 0.283 | 0.178 | 0.40 | 0.395 | 0.15 |
| qd_dev | ocean | ends of the horizon at the edges | 0.051 | 0.191 / 0.144 | 0.168 | 0.57 | 0.211 | 0.43 |
| qd_dev | ocean | diagonal band, left edge to bottom centre | 0.077 | 0.134 / 0.258 | 0.258 | 0.84 | 0.227 | 0.65 |
| qd_dev | motorbike | gap between the wheels, bottom centre | 0.026 | 0.036 / 0.275 | 0.200 | 1.03 | 0.163 | 1.03 |
| qd_dev | matches | left of the stick | 0.041 | 0.182 / 0.372 | 0.134 | 1.04 | 0.111 | 0.92 |
| qd_dev | matches | head of the stick | 0.020 | 0.184 / 0.122 | 0.008 | 0.93 | 0.026 | 0.51 |
| qd_dev | grapes | dense centre | 0.069 | 0.594 / 0.341 | 0.355 | 0.03 | 0.347 | -0.01 |
| qd_dev | paper clip | top end of the clip | 0.031 | 0.250 / 0.108 | 0.107 | 0.15 | 0.125 | 0.09 |
| qd_dev | paper clip | left and right sides | 0.054 | 0.037 / 0.206 | 0.060 | 1.00 | 0.090 | 1.01 |
| qd_dev | campfire | base of the fire | 0.080 | 0.586 / 0.281 | 0.358 | 0.05 | 0.318 | -0.00 |
| qd_dev | campfire | left and right sides | 0.061 | 0.029 / 0.106 | 0.097 | 0.98 | 0.084 | 0.98 |
| qd_dev | washing machine | upper corners | 0.092 | 0.339 / 0.113 | 0.188 | 0.34 | 0.236 | 0.22 |
| qd_dev | soccer ball | upper-left arc | 0.060 | 0.395 / 0.141 | 0.176 | 0.16 | 0.122 | 0.01 |
| qd_dev | soccer ball | left and right sides | 0.080 | 0.309 / 0.136 | 0.223 | 0.14 | 0.242 | 0.05 |
| qd_dev | frying pan | ends at the left and right edges | 0.038 | 0.181 / 0.100 | 0.073 | 0.19 | 0.094 | 0.02 |
| qd_dev | frying pan | below the pan | 0.070 | 0.071 / 0.255 | 0.095 | 0.98 | 0.097 | 0.93 |
| qd_dev | foot | sole | 0.061 | 0.251 / 0.170 | 0.091 | 0.07 | 0.104 | -0.05 |
| qd_dev | foot | middle | 0.077 | 0.179 / 0.383 | 0.223 | 0.95 | 0.169 | 0.68 |
| fashion_mnist | T-shirt | sleeve ends | 0.057 | 0.425 / 0.176 | 0.165 | 0.06 | 0.179 | 0.01 |
| fashion_mnist | T-shirt | lower sides | 0.168 | 0.044 / 0.226 | 0.295 | 1.02 | 0.244 | 1.03 |
| fashion_mnist | trouser | gap between the legs | 0.054 | 0.263 / 0.501 | 0.256 | 0.89 | 0.308 | 0.81 |
| fashion_mnist | pullover | neckline | 0.015 | 0.431 / 0.200 | 0.073 | 0.10 | 0.081 | 0.05 |
| fashion_mnist | pullover | below the hem | 0.038 | 0.223 / 0.303 | 0.035 | 1.33 | 0.032 | 1.30 |
| fashion_mnist | dress | beside the waist | 0.038 | 0.289 / 0.452 | 0.101 | 1.18 | 0.103 | 1.18 |
| fashion_mnist | dress | hem | 0.046 | 0.623 / 0.297 | 0.175 | 0.05 | 0.182 | 0.01 |
| fashion_mnist | coat | outside the shoulders | 0.133 | 0.174 / 0.138 | 0.169 | 1.11 | 0.155 | 1.07 |
| fashion_mnist | coat | below the hem | 0.038 | 0.324 / 0.292 | 0.041 | 1.42 | 0.029 | 1.36 |
| fashion_mnist | sandal | upper left | 0.061 | 0.002 / 0.312 | 0.390 | 1.00 | 0.303 | 1.00 |
| fashion_mnist | sandal | heel | 0.045 | 0.392 / 0.289 | 0.098 | 0.51 | 0.116 | 0.39 |
| fashion_mnist | sandal | middle of the shoe | 0.026 | 0.233 / 0.608 | 0.136 | 1.10 | 0.130 | 1.07 |
| fashion_mnist | shirt | left shoulder | 0.041 | 0.444 / 0.208 | 0.277 | 0.11 | 0.306 | 0.09 |
| fashion_mnist | sneaker | upper left | 0.046 | 0.000 / 0.366 | 0.364 | 1.00 | 0.261 | 1.00 |
| fashion_mnist | sneaker | heel | 0.026 | 0.537 / 0.152 | 0.104 | 0.02 | 0.137 | -0.00 |
| fashion_mnist | bag | handle | 0.036 | 0.104 / 0.358 | 0.177 | 0.74 | 0.128 | 0.69 |
| fashion_mnist | bag | inside the handle | 0.026 | 0.240 / 0.462 | 0.090 | 1.03 | 0.071 | 1.03 |
| fashion_mnist | bag | left edge | 0.027 | 0.140 / 0.004 | 0.115 | 0.42 | 0.122 | 0.40 |
| fashion_mnist | boot | left of the shaft | 0.046 | 0.001 / 0.342 | 0.410 | 1.00 | 0.246 | 1.00 |
| fashion_mnist | boot | ankle | 0.020 | 0.769 / 0.468 | 0.094 | -0.00 | 0.092 | -0.00 |
| mnist | 0 | centre (the hole) | 0.032 | 0.061 / 0.486 | 0.461 | 0.99 | 0.409 | 0.99 |
| mnist | 1 | beside the stroke | 0.092 | 0.080 / 0.398 | 0.456 | 0.99 | 0.323 | 0.82 |
| mnist | 2 | left of the upper bowl (row 10-12) | 0.034 | 0.049 / 0.243 | 0.187 | 1.02 | 0.126 | 1.03 |
| mnist | 2 | base | 0.115 | 0.480 / 0.306 | 0.258 | 0.25 | 0.326 | 0.12 |
| mnist | 3 | open left side | 0.077 | 0.190 / 0.326 | 0.321 | 0.94 | 0.226 | 0.82 |
| mnist | 4 | open top | 0.032 | 0.175 / 0.463 | 0.276 | 0.94 | 0.245 | 0.90 |
| mnist | 5 | right, below the top bar | 0.031 | 0.169 / 0.329 | 0.258 | 0.92 | 0.190 | 0.84 |
| mnist | 6 | right of the stem, above the loop | 0.032 | 0.099 / 0.425 | 0.146 | 0.99 | 0.154 | 0.98 |
| mnist | 7 | diagonal band left of the stem | 0.050 | 0.062 / 0.331 | 0.301 | 1.01 | 0.225 | 0.99 |
| mnist | 7 | bottom of the stem | 0.027 | 0.312 / 0.171 | 0.089 | 0.51 | 0.048 | 0.13 |
| mnist | 8 | centre crossing | 0.045 | 0.582 / 0.356 | 0.262 | 0.17 | 0.296 | 0.10 |
| mnist | 9 | bottom rows 23-25 | 0.034 | 0.223 / 0.162 | 0.084 | 0.70 | 0.028 | 0.29 |
| mnist | 9 | lower left rows 19-21 | 0.023 | 0.067 / 0.348 | 0.080 | 0.99 | 0.075 | 0.97 |
