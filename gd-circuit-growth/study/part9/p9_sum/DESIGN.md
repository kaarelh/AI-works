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

**Acceptance beyond the round's characters.** Candidates are searched on the round's residual r, the same residual
v1.1's character tests use. A candidate is accepted only if it also passes the same test on r_S: r projected off the
constant and the characters accepted in the same round. So a block must add something beyond those characters. If the
characters already explain r (mean(r_S²) < 10⁻⁴ s²), no block is searched in that round. Without this, a block
{x1, noise input} was accepted together with the character x1 on dict and sparsepoly (section 4, item 7).

**Per round** (after v1.1's character searches and blocks, same residual):
- Up to 2 additive blocks. After each candidate, the residual is deflated by its group means (and M recomputed), and
  the search is repeated.
- *Products.* Two routes, scored on the joint cells (A group × B level):
  - *conditional:* B is searched again with A = the first candidate's groups fixed, seeded by the deflated-residual
    candidate;
  - *split:* if the first candidate has at least 2 inputs of each sign, A = its + part and B is searched with the −
    part as seed. A product h_A(t_A) · h_B(t_B) of two symmetric functions correlates with |t_A − t_B|, which the
    additive search returns as one mixed-sign block.

  The better product, by T − threshold, is accepted if it passes the joint test *and* its margin beats the first
  additive candidate's own margin. Otherwise a product would be added redundantly on top of a single signed block,
  such as ssym9. This is for f = h_A(t_A) · h_B(t_B), where each additive part explains little, such as twosym, or
  parmaj = MAJ3 xor MAJ3.
- A modulated block for each of the 4 current characters with the largest least-squares weights, searched on r · χ_T.
- Products of pairs of additive blocks accepted in earlier rounds.

Accepted blocks become least-squares columns like any other feature, within DFG's p ≤ n/2 limit. The logistic
refinement, kernel background, stopping rule and budget caps are unchanged.

**Forced variant** (small n). Unchanged from v1.1. A "forced block" option (`sum_force`) was tried in development
and is off in the frozen file (section 4).

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
4. twosym, seed 0 at n = 512: the additive search returned one mixed-sign 10-input block (both 5-blocks, one with
   flipped signs), and the conditional product built on it was inexact (error 0.24). → the split move, and products
   must beat the additive margin. Both seeds are then solved at n = 512, and one of 3 at 256.
5. Forced block (`sum_force`): in DFG's forced variant, force the best block candidate instead of a character. No
   effect at n = 64 on 5 symmetric dev targets in a DFG-alone check (the search itself is the limit there). In the
   portfolio it raised andxor's error at n = 32 from 0.078 to 0.139 (n* 30 → 43, seeds 0–1). → off (default False).
6. More search seeds (4 eigenvectors, 6 pairs): band11 at n = 512 mean error 0.33 → 0.17 (3 seeds), about 30% more
   time. Not adopted (defaults: 2 eigenvectors, 3 pairs, 2 single inputs).
7. Portfolio on designed (seeds 0–1, n ≤ 512), against v1 on the same fits: sparsepoly 155 against 109 (+0.51 in
   log2). In round 0 the character x1 (sparsepoly = sign(2 x1 + x2 x3 + x4 x5 x6)) passed, and the same round's block
   search accepted {x1, noise input}, carried by x1's signal. Dict accepted such blocks too, though without error cost.
   → the acceptance rule above. A first version searched on the projected residual too: that broke maj9 at n = 256
   (a partial 5-input block once 4 of the 9 linear characters had passed; error 0.034 against 0.000) and, without the
   constant column, still accepted a block on dict. The final rule (search on r, test also on r_S with the constant)
   gives sparsepoly 0.093 / 0.012 at n = 128 / 256 (= v1.1), maj9 0.000 / 0.000, and no block on dict or par2.
8. Real-data check (DEV kr_vs_kp, n = 1000, seed 0, the only DEV dataset where DFG runs), final code: test error
   0.0113 against v1's 0.0100 (a difference of about one test point), 0.080 of the budget against v1's 0.063, CPU
   12.9 s against 3.7 s.

**Data-access note.** While reading `boolfuncs.py` for the dev suite's definitions, an over-long `grep -A 60` printed
the source of the next function, `make_dl_heldout4_suite` (the held-out target definitions; no data or results).
Nothing of it was loaded, run or evaluated. The design follows the dev suites and the directions given in the task
(sum blocks found from pair coefficients or greedy residual growth, union-bound tests, integer combinations with found
characters). The exposure happened at the start, before any design work, so every choice above was made after it. No
choice was checked against those definitions, and every change in this list was driven by a dev-target failure. Two
generic parameters bear on block size and composition: k_max = 24 (block sizes up to 24 inputs) and 2 additive blocks
per round with products of two. Neither was tuned. The exposure is recorded here so that the held-out result can be
read with it in mind.
