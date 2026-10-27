# p9_bank: the Part 8 portfolio plus a screened bank of prototype-pair threshold bits (Part 9, builder I2)

Frozen code: `learner.py` (class `Learner`, default constructor, name `p9_bank`), md5 `@@MD5@@`.
`Learner` is the Part 8 portfolio `hybrid/hyb_portfolio/learner.py` (md5 063bcd91e0b221c948760ec1ba28e042) plus one
member, `bank`. The bank runs only when every input column is continuous and d >= 256 (the images); on every other input
the code path, the random stream and the result are those of the Part 8 file. The bank draws from its own random
generator (`default_rng([seed, 9209])`), so on images every other member's out-of-fold and final fit is also identical
to Part 8's; only the stacker sees one more member.

Development data: MNIST, Fashion-MNIST and `qd_dev` only, with errors measured on **validation rows of the training pool**
(the last 10000 rows of the seed-0 pool permutation, disjoint from every training prefix used, n <= 50000). See section 7
for one exception inherited from the session that was killed.

## 1. Algorithm (the `bank` member)

**Features.** Each feature is a discrete object: a pair of training points (a, b) of different classes and a threshold t,

  phi(x) = [ (x_a - x_b) . x > t ].

- a is a uniformly drawn training point; b is the nearest point of another class to a (squared Euclidean distance)
  within a random reference sample of <= 4000 training points;
- t is a quantile of the projection (x_a - x_b) . x over <= 2000 training points; each direction is offered with
  n_thr = 3 thresholds at stratified random quantiles (one in each third of [0.1, 0.9]).

**Screening (the search).** The bank is built in 8 rounds on a subsample S of the training rows (<= 15000). Each round
draws a fresh pool of 6k candidate bits (2k directions x 3 thresholds; k = F / 8), drops bits that fire on < 1% or
> 99% of S, scores each by its squared standardized correlation with the current multi-output ridge residual (one-hot
targets, summed over classes), and keeps the k best. The ridge fit on S (penalty 10 n_S / 1000, Cholesky on the
incrementally grown Gram matrix) is updated after every round, so later rounds look for what the earlier bits miss.
This is a forward-selection test over discrete candidates; nothing continuous is optimized.

**Readout (convex).** Ridge regression of the one-hot labels on the centred bits, closed form, on all training rows
(Gram matrix, sums and cross-products accumulated over row chunks, so adding rows is additive). The penalty lambda
(in units of N / 1000) is chosen on an internal validation split V (15% of the training rows, <= 5000): grid
{1, 10, 100, 1000}, then the best value x 3 and / 3, by the validation cross-entropy of softmax(tau * scores), with the
temperature tau fitted on V (1-d bounded search). The model is then refitted on all its training rows. Class
probabilities = softmax(tau * ridge scores).

**In the portfolio.** Out-of-fold probabilities exactly like the other members: in the holdout regime (n > 3000) the
bank is fitted on the n - h non-stacking rows, predicts the h stacking rows, and its final model is the same feature set
refitted on all n rows (the Gram matrix is a sum over rows, so this costs one more Cholesky); in the k-fold regime
(n <= 3000) one fit per fold plus a final fit on all n with its own screening. The stacker (Part 8, unchanged) weights it
against the other members.

**Size from the budget.** F is the largest value in {8000, 7000, ..., 500, 250} with F <= 5 x |S| whose projected cost
(`bank_cost`) fits min(0.6 x budget, 0.9 x budget - spent so far - 0.7 x the LightGBM charge). The LightGBM reserve
is there because the Part 8 compute audit found that charge up to 1.7x low on Fashion-MNIST. Resulting F: 2500 at
n = 1000 (k-fold, 6 fits), 5000 at n = 10000, 4000 at n = 60000.

**Permutation invariance.** The member uses only Euclidean distances between images, inner products with differences of
training images, per-feature quantiles and the labels. A fixed permutation of the pixel columns leaves every one of
these unchanged, so with the same random seed the fitted model and its predictions are the same up to floating-point
summation order. `test_perm.py` checks this (section 5). The other members are the Part 8 ones (trees, kNN, logistic
regression), also invariant.

## 2. What is discrete

| part | what it is | how it is chosen |
|---|---|---|
| directions | differences x_a - x_b of two training images (a pair of indices) | a at random, b by a nearest-neighbour search |
| thresholds | quantiles of a projection over training points (an order statistic) | stratified random quantile levels |
| the bank | a subset of candidate bits | forward screening by residual correlation, in rounds |
| readout | ridge weights (continuous), penalty and temperature | closed form (convex); penalty and temperature by validation |

No neural network, no gradient descent, no continuous parameter inside a feature. The only continuous fits are the
convex ridge readout, the 1-d temperature and the Part 8 stacker. Borderline: the hyperplane normal x_a - x_b has
continuous entries, but it is a pair of data points, not a fitted vector; the threshold is an order statistic of the data.

## 3. FLOP accounting (multiply-add = 2; prediction not counted)

Charged by `fit_bank` as it runs; `bank_cost` projects the same terms, with every selected bit counted as its own
direction (an upper bound), and is only used to choose F.

| step | FLOPs |
|---|---|
| reference distances for the pairs (per round) | 2 U_r n_ref d + 3 U_r n_ref |
| directions, candidate projections on S | U_r d + 2 n_S d U_r |
| thresholds (sort of <= 2000 values per candidate), candidate bits and firing rates | m log2 m x F_c + 2 n_S F_c |
| screening scores | 2 n_S F_c C |
| Gram blocks on S (cross block and new block), target cross-products | 2 n_S s k + 2 n_S k^2 + 2 n_S k C |
| ridge on S after each round (Cholesky + 2 triangular solves for C columns), residual | s^3 / 3 + 4 s^2 C + 2 n_S s C + n_S C |
| final bits for every training row (U distinct directions) | 2 N d U + N F |
| final Gram matrix (the task's rule 2 N F^2, no symmetry discount), cross-products | 2 N F^2 + 2 N F C |
| each ridge solve (centring, Cholesky, solves) | 2 F^2 + F^3 / 3 + 4 F^2 C |
| validation scores and temperature search per penalty | 2 n_V F C + 6 n_V C x (function evaluations) |
| out-of-fold scores of the stacking rows | 2 h F C |

(U_r directions and F_c = 3 U_r candidate bits per round, s bits selected so far, k new ones, N training rows, C classes.)
The other members are charged as in Part 8 (kNN, LightGBM analytic, ExtraTrees, logistic, stacker).

@@RESULTS@@
