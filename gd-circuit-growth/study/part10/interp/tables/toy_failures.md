### Targets never learned or learned late (n_struct >= 1024) by v3's DFG member (seed 0)

| suite | target | k_class | n_struct | n_max | err_last | n_unfold | n_fold | n_mod | ratio_unfold_max | ratio_fold_max | W1 | W2 | W_le3 | deg_peak | reach_eig_max | reach_deg1_max | chance | best_jaccard_last | nstar3 | nets_best | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dlsymdev | band11 | 11 | 1024 | 2048 | 0.0 | 128 | 128 | None | 147.317 | 173.181 | 0.0 | 0.04721 | 0.04721 | 6 | 1.0 | 0.27 | 0.37 | 1.0 | 829 | 1836 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11\| (0.97); quad(23 inputs) (0.10) |

n_unfold / n_fold / n_mod: first n with T / threshold > 1 for the true block (toy_power); ratio_*_max: at the largest power n (16384); W_k: the target's Fourier weight at degree k; deg_peak: the degree with the largest weight; reach_*: fraction of the true class among the top |S| inputs of the search's orders at n = 16384 (eigenvector prefix: best of the top 2); chance = |S| / 30; best_jaccard_last: best Jaccard overlap of a learned block, factor or modulator with the true class at n_max.
