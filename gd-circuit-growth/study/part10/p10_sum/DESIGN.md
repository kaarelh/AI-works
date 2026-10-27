# p10_sum: DFG v1.3 (weighted sum blocks, forced blocks, wider small-n search) inside v2

Part 10, builder T. Files:
- `dfg13.py`: DFG v1.3 = `part9/p9_sum/dfg12.py` (v1.2, md5 `4ff2e0c9c324f0f1be93f604734b4a69`) plus the changes in
  section 1. Every change is inside the sum-feature component (the `SumBlock` class, `_block_search`, and the
  sum-block part of a DFG round); characters, extensions, the local Walsh search, the linear / spectral blocks, the
  least-squares and logistic readout, the kernel background, the budget caps and the stopping rule are v1.2's code.
- `learner.py`: class `Learner`, default name `p10_sum` = v2 (`part9/hyb_portfolio2/learner.py`, md5
  `e38af40493816ef1bc82e4f16428dcdf`) with its DFG module loaded from `part10/p10_sum/dfg13.py` instead of
  `part9/p9_sum/dfg12.py`. The other two changes are the default name and the docstring header. The image member
  (gates), LightGBM, ExtraTrees, kNN, logistic regression and the stacker are v2's code, bit for bit. DFG runs only
  on binary / categorical inputs with C = 2 (the toy suites, kr_vs_kp-like tables), so on images and on every other
  tabular set p10_sum is v2 by construction.

FREEZE: see section 6.

Development used only the toy suites `designed`, `dlsymdev`, `dlfamdev` and `dlheld6` (already seen), a few
synthetic targets of my own (section 4), inputs permuted per fit. No held-out suite (`dlheld7`) or held-out image set
(`qd_c`, `qd_d`) was loaded, generated, printed or inspected, and no result file or log about them was read.

## 1. What changed in the sum-feature search

### 1a. Weighted sum blocks u = t + a·τ (the main change)

v1.2's blocks have ±1 weights. A sum with one heavier term, `u = Σ_{i∈S} s_i x_i + a·τ(x)` with `a ∈ {±2, ±3}` and τ a
literal, a parity of two inputs or an AND of two literals (as ±1), was representable only through a modulated block
when τ was a character already in the model; for τ = a literal x_j (whose own degree-1 coefficient is often exactly 0,
e.g. dlheld6's h6_10 = `[|x1+…+x12 − 3 x13| > 1]`, where E[f x13] = 0 by symmetry) or τ = AND it was not representable
at all. v1.3 adds the class

  WeightedBlock(S, s, fold, a, τ):  u(x) = Σ_{i∈S} s_i x_i + a τ(x),   features [u (or |u|) ∈ group v]

with the same contiguous value groups, the same χ² statistic T and the same Laurent–Massart threshold. The union
bound pays for the inner term: t = tk(|S|) + ln(2 · (4d + 20·C(d, 2))) (a literal on any input with a ∈ {±2, ±3}: 4d;
a parity (4) or an AND with any of 4 literal signs (16) on any pair of inputs, each with a ∈ {±2, ±3}; ×2 because the
weighted class gets its own false-accept share δ next to the unweighted class, so the level of the block test per
round is at most 2δ instead of δ). At d = 30 this adds 9.8 nats (≈ +20–25 to the threshold).

Three routes produce weighted candidates, all in the **additive** block search only (not in the modulated or product
searches, for CPU):
1. *Weighted eigenvector prefixes.* For a function of a weighted sum w·x the residual pair matrix is ≈ c·w wᵀ (off the
   diagonal), so the heavy input leads the order of the top eigenvector. For each of the top-2 eigenvectors' orders,
   the first input gets weight a ∈ {2, 3} (sign from the eigenvector) and every prefix of the rest is scored, folded
   and unfolded.
2. *τ first.* For the strongest pair (j, l) of the pair matrix (`ntau` = 1), the 5 terms τ ∈ {x_j x_l, AND(±x_j, ±x_l)}
   with a ∈ {±2, ±3} are held fixed and the eigenvector prefixes of the other inputs are scored.
3. *Extensions of the best unweighted candidates.* For the 2 best refined unweighted candidates (S, s): every literal
   outside S with a ∈ {±2, ±3}; every input of S re-weighted to 2 or 3; a parity or AND on the 24 pairs outside S with the
   largest pair coefficients.
The 3 best weighted candidates are refined by the same local search as v1.2 (add / remove / flip-sign moves on S, the
inner term held fixed), and the best weighted candidate replaces the unweighted one only if its margin (T̂ minus its own,
larger threshold) is higher. The final test, the second test on r_S (beyond the round's characters), the deflation and
the products are as in v1.2; a product with a weighted factor pays that factor's weighted t.

### 1b. Forced blocks in the forced variant (n ≥ 48)

v1.2's forced small-n variant (a stacking member at n ≤ 512 in the portfolio) forces the best character when nothing
passes. v1.2 had a `sum_force` option (force the best block candidate instead, when its T/threshold ratio beats the best
character's squared z-ratio); it was off, because it cost accuracy on andxor at n = 32 and the search could not find
the blocks at n = 64 anyway. v1.3 turns it on for n ≥ 48 only (so the 10-fold out-of-fold fits at n = 64, on ~58
points, force too, and nothing changes at n ≤ 32) and pairs it with 1c. Why: at n = 64 a perfect 7-input block has
T ≈ 64 but its union-bound threshold is ≈ 80 (section 5b of p9_sum/DESIGN.md), so no block can pass the test there;
the forced variant gets the block anyway, and the stacker decides by cross-validation whether the forced member is
trusted, exactly as for forced characters.

### 1c. Beam search for the first additive block at n ≤ 128

At n = 64–128 v1.2's eigenvector / greedy seeds miss strong-pair blocks on some seeds (fd_09 at n = 128: 1 of 3
seeds; ssym9 seed 2 at 128; sym7 at 64 on every seed). v1.3 adds, for the first additive search of each round and
only when n ≤ 128, a beam search: start from all pairs (both relative signs), keep the 32 best (S, s) by the block
margin (best of folded / unfolded), extend each by every input and sign, keep the 32 best distinct ones, until the
best margin has not improved for 5 sizes; the two best of each size are scored as candidates for refinement. The beam
is a purely combinatorial search on (S, s) with the block statistic.

### 1d. What was tried and dropped (dev data only)

- *Residue classes mod 3 of 10–13 inputs* (fd_10, h6_00). Measured landscape (fd_10, n = 16384, true block known): each
  missing input divides T by ≈ 4, each extra input by ≈ 2–2.5, a sign flip by ≈ 2–3, and errors compound (5 extras +
  2 flips: T ≈ 6). The Fourier weight sits at degree ≈ 3k/4 (pair and degree-1 coefficients ≈ 0.002). A detectable
  candidate must be within ≈ 3–4 errors of the truth; random multi-start coverage of C(30,10)·2⁹ ≈ 1.5·10¹⁰ (S, s) would
  need ≫ 10⁵ restarts. Not attempted further; fd_10 and h6_00 stay unlearned.
- *Beam search (width 16) and truncated-power-method seeds at n = 256–512* for weak-pair blocks (band11, h6_01): no
  change (1 of 3 seeds for band11 at 256 and 512, as v1.2). At n = 256 the true block has T = 256 against a threshold
  of ≈ 100, but blocks with ≥ 4 wrong inputs are below the noise of the search; the pair-matrix spike (k a₂ ≈ 0.4) is
  below the noise edge 2√(d/n) ≈ 0.48–0.68 at n ≤ 512, and a sparse-PCA local search over the pair objective returned
  4–7 of band11's 11 inputs. The limit there is computational, not the test.
- *Beam width 64 / 256 and beam at n ≤ 512*: no further gain at n = 64–128 and 4–40× the search CPU.

## 2. What is discrete; permutation invariance

| part | object | continuous? |
|---|---|---|
| weighted block | a subset S, signs s, an integer weight a ∈ {±2, ±3}, an inner term τ (a literal, a parity of two inputs or an AND of two literals) | no |
| value groups | contiguous sets of integer values of u, from training counts | no |
| beam / refinement / extensions | enumeration of (S, s, a, τ) scored by the χ² block statistic | no |
| ordering heuristic | eigenvectors of the residual pair matrix (as in v1.2) rank inputs for prefixes; the eigenvector's magnitudes only pick which input gets weight a | used inside the search, not in the hypothesis |

No gradient descent, no network. All new statistics are functions of the column set (pair matrix, counts), so a
permutation of the input columns permutes every candidate; ties are broken by index as in v1.2 (the harness permutes
the inputs per fit).

## 3. Cost (FLOPs, multiply-add = 2; CPU)

Every new operation is added to DFG's own counter `fl` with v1.2's conventions (8 m C per block-statistic call over m
points and C candidate columns; beam: 16 m C per step for the folded and unfolded statistics; extensions: + 4 m C for
building the columns; τ evaluations included), so it also counts against DFG's budget caps (a round starts only below
0.75 of the DFG share).

RESULTS: section 5.

## 4. Development history (dev data only)

TBD

## 5. Fixed dev evaluation (frozen files, run once)

TBD

## 6. Freeze

TBD
