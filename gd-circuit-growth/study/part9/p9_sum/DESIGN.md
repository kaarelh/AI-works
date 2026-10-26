# p9_sum: DFG v1.2 (sum-feature blocks) inside the Part 8 portfolio

Part 9, builder S. Files:
- `dfg12.py`: DFG v1.2 = `discrete_learner/dfg.py` (v1.1, md5 `162e42028a40f5672951edb538f2df99`) plus sum-feature blocks.
- `learner.py`: class `Learner`, name `p9_sum` = `hybrid/hyb_portfolio/learner.py` (md5 `063bcd91e0b221c948760ec1ba28e042`)
  with its DFG member loaded from `dfg12.py`. The only other changes are the file-location constants, the default name
  and the docstring header.
- `run_toy.sh`: runs `hybrid/eval_toy.py` (unchanged) on `p9_sum.learner:Learner` with `study/part9` on `PYTHONPATH`.

Frozen file: see section 6 for the md5 of `learner.py` and `dfg12.py`.

Development used only the toy suites `designed` and `dlsymdev`, with inputs permuted per fit, as in Part 8.

## 1. What was added to DFG

Part 8's one clear toy loss was sym9 = [|x1 + … + x9| ≤ 1]. Its Fourier weight is spread over many characters of
degrees 2, 4, 6 and 8, so a character search pays for each character separately. v1.2 adds one more candidate class to
DFG's round: **sum-feature blocks**.

**The features.** A block is a subset S of the inputs, signs s_i ∈ {−1, +1}, and a fold flag. Its statistic is the
integer t(x) = Σ_{i∈S} s_i x_i, or |t(x)| when folded. The training values of t are cut into contiguous value groups,
each holding at least max(3, 0.005 n) training points (rare tail values are merged inward). The block's features are
the group indicators φ_v(x) = [t(x) ∈ group v], one group dropped (the most populous one). Every function of t,
including every symmetric function of the signed inputs in S, is then a linear combination of the block's features,
up to the merged rare values.

Three variants:
- **additive**: φ_v as above;
- **modulated**: χ_T(x) · φ_v(x), for a character χ_T already in the model (the inputs of T are excluded from S);
- **product**: the indicators of the joint cells (group of block A, group of block B), for two blocks with disjoint
  supports.

With additive and modulated blocks on the same (S, s) and one character χ_T, any function g(t(x) + w χ_T(x)) with
integer w is representable: for χ_T = ±1 it is g(t ± w), so it equals A(t) + χ_T · B(t) with A and B functions of t.
This covers "integer combinations of found characters" such as [|x1 + … + x5 + 2 x6 x7| ≤ 1]. Thresholds of such
combinations, like sign(x1 + … + x6 + 3 x7 x8 + ½), are also covered by v1.1's logistic readout on the inputs and the
character.

**The test.** A candidate block is accepted when the squared norm of the projection of the residual r onto its group
indicators clears a χ² tail bound with a union bound over the whole class. The projection onto disjoint indicators is
the group means, so

  T = Σ_v n_v · mean_v(r)² / s²,  s² = mean(r²),

and the block passes if T > m + 2√(m t) + 2t (the Laurent–Massart bound P(χ²_m > ·) ≤ e^{−t}). Here m is the number of
occupied groups minus 1, and

  t = ln(4 K · C(d, k) · 2^{k−1} · 2 · (1 + #modulators) · k_max / δ)

for a block of size k. This counts every (S, s) of size k, both fold variants, every modulator and every size up to
k_max = 24, with K = 4 and δ = 0.1 as in DFG's character tests. Because the bound covers the whole class and not only
the candidates tried, the adaptive search below does not invalidate it. A product block uses the sum of the two
blocks' t values (the class of pairs).

**The search for (S, s)** (`_block_search`). It does not use the target's identity, only the residual on the training
points. Scores use the first min(n, 2048) points; the final test uses all n.
1. *Pair-matrix seeds.* M = mean(r x xᵀ) with the diagonal removed; DFG already computes it every round. An even
   symmetric function on (S, s) has pairwise coefficients a₂ s_i s_j on S, so M restricted to S is rank one with the
   sign pattern s. For the top-2 eigenvectors u of M, order the inputs by |u_i| with s_i = sign(u_i), and score every
   prefix. The eigenvector only orders the inputs; the candidate is the discrete (S, s).
2. *Degree-1 seeds.* Order the inputs by |mean(r x_i)| with signs from those coefficients; score every prefix. This is
   for sums that are not even, such as ex3of8 = [exactly 3 of 8 are +1].
3. *Greedy growth.* Start from each of the 3 strongest pairs of M (both relative signs) and from the 2 strongest single
   inputs. At each step, add the input and sign that maximise T. Stop after 5 steps without improvement of the
   estimated margin, or at k_max. Score every prefix, folded and unfolded.
4. *Local refinement.* For the 3 best candidates (by estimated margin T̂ − threshold, with T̂ rescaled from the
   subsample), run a discrete local search: remove an input, add an input with either sign, or flip a sign. Take the
   best improving move, until none improves.
5. Test the best refined candidate on all n.

**Per round** (after v1.1's character searches and blocks, same residual):
- Up to 2 additive blocks. After each candidate, the residual is deflated by its group means (and M recomputed), and
  the search is repeated.
- *Conditional product.* The second block B is searched again with A's groups fixed, scored on the joint cells (A
  group × B level). It is seeded by the deflated-residual candidate, and the product is accepted if it passes the joint
  test. This is for f = h_A(t_A) · h_B(t_B), where each additive part explains little, such as twosym, or parmaj =
  MAJ3 xor MAJ3.
- A modulated block for each of the 4 current characters with the largest least-squares weights, searched on r · χ_T.
- Products of pairs of additive blocks accepted in earlier rounds.

Accepted blocks become least-squares columns like any other feature, within DFG's p ≤ n/2 limit. The logistic
refinement, kernel background, stopping rule and budget caps are unchanged.

**Forced variant** (small n). In DFG's "forced" variant, which runs only when nothing passes, the best additive block
candidate is taken instead of the best character when its T / threshold exceeds the character's (|v| / t)². As in
v1.1, the stacker, or DFG's own McNemar cross-validation, decides whether the forced variant is used at all.

## 2. What is discrete

| part | discrete object | continuous? |
|---|---|---|
| block support and signs (S, s) | a subset of inputs and a sign vector, chosen by enumeration-style search (prefixes, greedy steps, local moves) and a union-bound test | no |
| value groups | contiguous sets of integer values of t, from training counts | no |
| modulator χ_T | a character already chosen by DFG's tests | no |
| readout | least squares + 15 Newton steps of L2 logistic regression on the features (v1.1 unchanged) | convex readout |
| ordering heuristic | eigenvectors of the residual pair matrix (which DFG v1.1 already computes for its quadratic block); they only rank inputs for candidate prefixes | used inside the search, not in the hypothesis |

The hypothesis is a weighted sum of characters, group indicators of integer signed sums (optionally times a
character), the inputs, and v1.1's spectral (u·x)² features, which are unchanged and remain the one continuous-direction
feature, as in Part 8. No gradient descent and no neural network is involved.

## 3. FLOP accounting (multiply-add = 2)

Everything is added to DFG's own counter `fl`, so it also counts against the budget caps (rounds start only below
0.75 of the DFG share):
- block-statistic evaluations (`_multi_T` over a level matrix of m × C entries: sums, level index, two bincounts):
  8 m C per call (prefix scoring: 8 m K; one greedy step: 8 m · 2L; one refinement pass: 8 m · #moves);
- the eigendecomposition: 10 d³ per search;
- degree-1 coefficients: 2 n d;
- the modulated pair matrices: 2 n d² + n (d + |T|) each, and after each deflation: 2 n d² + 4 n;
- final tests: 2 n k + 4 n; product tests: 4 n (k_A + k_B);
- building the block columns: n (k + 2 G);
- the larger least-squares and logistic fits: through v1.1's own lsfit / Newton counters.

The block search is cheap in FLOPs: on the toy suites it is a few percent of a fit. The largest fit uses 0.11 of one
network run on dlsymdev and designed at n ≤ 4096 in dev runs; see the frozen tables for the full grid. In CPU time it
is not small: Python overhead per search step, plus the extra DFG rounds that accepted blocks cause. DFG v1.2 fits take
about 1.5–3× v1.1's CPU time on the toy suites.

**Prediction cost** (not counted, as for the networks and Part 8). Per query and block: k additions for t, a
binary search over at most k + 1 group edges, one multiply for a modulator, and a product block's two lookups. This is
O(Σ_blocks k) ≤ a few hundred FLOPs per query, negligible next to the portfolio's kNN members (2 n d per query on real
data). On the toy suites, prediction cost is dominated by the same members as in Part 8.

## 4. Development history (dev data only)

(see section 5 for the frozen dev results)

1. Additive blocks only, eigenvector-prefix and pair-growth seeds. DFG alone at n = 128 solves sym7 and ssym9 (v1.1:
   0.48 and 0.50 test error). band11 at n = 2048 failed on one seed: the eigenvector ordering put a noise input into the
   block (11 relevant + 1). → local refinement (add / remove / flip).
2. ex3of8 (not even) at n = 128–256 was partly missed: no pair signal (coefficients 0.035). → degree-1 seeds and
   single-input growth seeds. ex3of8 is then solved from n = 128.
3. twosym at n = 512: block A was found but B only partly (3 of 5 inputs), since B's additive part explains about 6% of
   the variance. → conditional product search (B scored on the joint cells with A). One of 2 seeds is then solved at
   n = 512, both at 1024.
4. Forced block in the small-n forced variant: no effect at n = 64 on 5 dev targets in a DFG-alone check (the search
   itself is the limit at n = 64), kept since it is used only if cross-validation or the stacker prefers it.
