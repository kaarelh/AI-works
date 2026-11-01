# Trained networks, design round: verify

I built and measured a sound deductive engine for p = Pr[f(x) < t] on trained ReLU MLPs. It is input branch and bound (B&B): the cube is split into subcubes, and a subcube is settled when CROWN-type bounds certify that none of its points fails or that all of them fail. Small subcubes (at most 4 to 6 free inputs) are enumerated exactly. Undecided mass gives a sound upper bound, and sampling inside the undecided subcubes (the paper's envelope estimator) can be added. The code is in code/rareprob/nets_verify.py.

A previous run had left code and partial results. I kept and reviewed that code and made these changes:
- **Witness storage:** points returned by the HiGHS solver are now stored. All 6 were rechecked in exact rational arithmetic and all fail.
- **New diagnostic:** the tree a perfect engine would need.
- **New experiments:** exp_gap.py (why only small subcubes are certified), exp_milp.py (a stronger but unsound engine, run against the sound B&B), a short-training sweep added to exp_zero.py, and the perfect-engine tree added to exp_isolation.py.
- **One soundness fix:** the 2^-53 rounding of a sample mean is now passed to the confidence interval in the sampling stage.

Everything reported was re-run on the final code. Soundness checks found no violation in 12,000 bound checks or 232 B&B runs against exact rational counting.

**Main findings:**

1. **p = 0 is common, and deduction handles it well; Monte Carlo cannot certify it at all.**
   - Of 107 one-hidden-layer nets trained to moderate length, 98 have p = 0 and it is certified exactly. 5 have p > 0 and are counted exactly. 4 at d = 40 to 64 stay open.
   - Nets trained long enough are certified at or near the root (5 to 5e3 forward-pass equivalents, fpe) up to d = 40. At d = 48 and 64, after 16,000 steps, certification costs 1.6e7 and 3.7e7 fpe.
   - For moderately trained nets the median cost grows about 3x per 4 extra inputs (d = 20 to 32). Enumeration grows 13x.

2. **For p > 0, exact counts cost about as much as brute-force enumeration.**
   - One hidden layer, d = 24 and 28 (13 suite nets): the exact count costs 0.7 to 4x the meet-in-the-middle enumeration for squared loss, and 0.008 to 0.5x for logistic loss.
   - It beats Monte Carlo (eps = 0.1) by 24x to 1.8e5x when there are at most a few thousand failing points (F). It loses, by up to 1.3e3x, when F is 1e4 or more.
   - The tree has about 2^(d − 6.5) nodes whatever p is, so cost doubles with every input.
   - Two hidden layers: only 9 to 22% of the cube is certified within 940 to 2600 s.

3. **Why the cost is exponential.**
   - CROWN's looseness on a subcube grows like r^1.5 to r^2 in its number r of free inputs. The best linear (LP) relaxation removes only 20 to 55% of it. The margin min f − t shrinks as r grows.
   - So certification stops at r* of about 4 to 12, roughly sqrt(margin/(κ·ι)), with κ ≈ 0.006 to 0.02 (fitted) and ι the mean per-input influence.
   - A perfect engine would need only about F·(d − log2 F) nodes: 10 to 5000x fewer, more so the rarer the event. So the obstacle is the bounds, not where the failures sit: failing points are about d/2 apart and form no failing subcube larger than dimension 4.
   - Even the exact minimum over a subcube's box (the limit of every relaxation that works on the box) certifies only r = 8 to 20 on 6 of 10 nets, against at least 16 for the cube itself.
   - The paper's barriers apply to this architecture: every 3-CNF is a net of this form (checked), so nothing is efficient on all nets unless NP ⊆ BPP. Certifying p = 0 is coNP-hard. Evaluation-only methods cannot certify upper bounds below about 1/T, so small certified upper bounds need deduction.

4. **At large d with p > 0 a two-sided sound method by deduction is hopeless.** For every d = 64 and d = 128 suite net the deterministic interval stays [0, 1]: r* ≤ 24 means at least 2^40 nodes. Sampling inside the undecided subcubes costs K/eps² with K = undecided mass / p, and K stays near 1/p until the tree is almost complete. So two-sided intervals there come only from sampling, at about Monte Carlo's cost.

5. **An unsound but stronger engine finds failures that Monte Carlo misses.** HiGHS branch and cut over the cube claims p = 0 on 7 nets with d ≤ 28 to 32, in 31 to 96 s. The sound B&B certifies the same nets in 0.0 to 39 s, plus two nets the solver fails on.
   - The solver finds failing inputs where Monte Carlo (1e7 samples) and B&B see none: both d = 48 nets, and the d = 64 suite net bce_d64_w64_s100 (f = −1.09). This proves p ≥ 2^-64 > 0 for a suite net that has no exact p.
   - It fails on the d = 64 squared-loss nets and on two-hidden-layer nets.

Two prototypes did not work and are not in the repository:
- A quadratic relaxation that uses x_i² = 1 was looser than CROWN at every r.
- An LP-dual phase-and-input B&B with naive branching did not certify an easy d = 32 net in 120 to 300 s; plain B&B does it in under 1 s.

## Methods

### Input branch and bound with CROWN bounds and exact enumeration of small subcubes (nets_verify.bab) (two-sided deterministic interval [F, F+A+U]/2^d; exact value when the tree completes; anytime upper bound)

**Soundness.** Holds for every net, adversarial weights included. ReLU relaxations: alpha*z <= relu(z) for any alpha in [0,1]; lam*(z−l) >= relu(z) on [l,u] when lam >= u/(u−l), with lam rounded up by 2^-48. Stable units are fixed only when their padded interval proves the sign. The linear bound is minimised over the box in closed form. Rounding: every computed bound is within tau = 2^-30·(M+1) of its exact value, where M is the absolute forward pass. Intermediate intervals are padded by tau_k. Decisions keep a margin of 2·tau, and thresholds are rounded outwards exactly with Fractions, so a decision holds both for the exact real net and for any float64 evaluation of it. Points with |f − t| <= tau are counted as ambiguous (A) and go into the gap. The tree partitions the cube, and counts are Python integers. Nothing depends on training. Checked: 12,000 bound checks and 232 B&B runs against exact rational counting (weight scales 1e-6 to 1e6, integer-weight nets with exact ties), 0 violations. Every 3-CNF is a one-hidden-layer net of this form (checked on 40 CNFs), so worst-case efficiency is impossible unless NP ⊆ BPP.

**Results.** Suite nets with exact p, one hidden layer (13 nets), r_enum = 4:
- **mse_d24_w32** (p from 7.1e-2 to 6.0e-8): exact in 1.4e6 to 7.3e6 fpe, 1.3 to 10 s. That is 0.7 to 3.6x the meet-in-the-middle (MITM) enumeration (2.0e6 fpe).
- **mse_d28_w64:** 4.4e7 to 1.1e8 fpe, 1.6 to 4.0x MITM (2.8e7 fpe), 130 to 350 s. The p = 0 net s1500 is certified in 4.4e7 fpe although f(0) < t.
- **bce_d28_w32:** 2.3e5 to 1.5e7 fpe, 0.008 to 0.52x MITM. The p = 0 net s150 is certified in 0.4 s.
- **Ambiguous points:** two nets end with a gap of A = 9 and A = 1 such points; both intervals contain the exact p.
- **Versus Monte Carlo** (3 ln(2/delta)/(eps² p) samples, eps = 0.1, delta = 0.05), as MC cost over B&B cost:
  - F = 1: 1.3e4 (p = 6e-8)
  - F = 2: 1.8e5 (p = 7.5e-9)
  - F = 89: 49
  - F = 163: 48
  - F = 3543 (bce): 24
  - F = 6012: 0.84
  - F = 16155: 0.2
  - F from 1.4e5 to 3.5e6: 0.024 down to 7.6e-4
- **Short-training family** (width 32, p from 6e-8 to 2e-2): nodes bounded are about 1e3, 1.4e4, 1.1 to 2.1e5 and 1.6 to 3.1e6 at d = 16, 20, 24, 28, i.e. about 2^(d − 6.5) independent of p.
- **Two hidden layers** (d = 28, 4 nets, 900 s limit): 6.7e7 to 4.2e8 fpe; the upper end hi stays at 0.78 to 0.91.
- **d = 64 and d = 128** (9 suite nets): [0, 1] after 1e7 fpe.
- **Same 180 s budget as the solver:** B&B gives [0, 1] at d = 48, 64 and 128 (apart from the near-constant d = 64 net).

**Verdict.** Works in a regime. It gives exact p cheaply up to about d = 30, at roughly brute-force cost, and beats Monte Carlo only when F is at most a few thousand. Cost is about 2^(d − r*) with r* ≈ 4 to 8 for nets with p > 0. That is exponential in d and hopeless at d = 64 or more, where Monte Carlo is far cheaper for p ≥ 1e-6.

### Complete verification of p = 0 (the same B&B run to completion; certify min_cube f ≥ t) (exact (upper bound 0); otherwise the same interval as above)

**Soundness.** Same argument as the B&B. p = 0 is reported only if every leaf is certified safe with the 2·tau margin, or enumerated with no point below t + tau.

**Results.** - **Frequency (exp_zero, width 32, 107 nets trained ≥ 1000 squared-loss or ≥ 300 logistic steps):** 98 have p = 0, certified; 5 have p > 0, counted exactly; 4 open (squared loss: d = 40 at 3000 steps, d = 48 at 3000, d = 64 at 3000 and 8000). With 300 to 600 steps, 13 of 18 nets have p > 0.
- **Root-level certification:** about 5 fpe (under 0.01 s) for long training, e.g. squared loss at 4000 to 8000 steps up to d = 32, and logistic loss at 1000 to 3000 steps up to d = 40.
- **Higher d:** d = 40 at 8000 and 16000 steps costs 2 to 5e3 fpe. d = 48 at 8000 and 16000 steps costs 4.8e7 and 1.6e7 fpe. d = 64 at 16000 steps costs 3.7e7 fpe (152 s).
- **Median cost over the family** by d: 1.0e4 (d = 20), 2.6e4 (24), 1.1e5 (28), 2.9e5 (32) fpe. That is about 3x per 4 inputs, against 13x for enumeration.
- **Monte Carlo with 1e7 samples** can only reach an upper bound of 3.7e-7.

**Verdict.** Works well on nets trained long enough that the margin at the root exceeds CROWN's looseness: then certification is essentially free at any d tried. For moderately trained nets the cost is exponential but with exponent about 0.4 instead of 1. It fails at d ≥ 40 when the margin is small. This is the regime where only deduction can certify small upper bounds (the paper's black-box barrier).

### Tighter per-subcube engines: optimised slopes (alpha-CROWN, approximately the LP/triangle relaxation) and ReLU phase splitting with Lagrange multipliers (beta-CROWN style) (lower bounds on f per subcube (feeding the upper bound on p))

**Soundness.** Any alpha in [0,1] and any beta ≥ 0 give a valid bound (weak duality), so every iterate of the supergradient ascent is valid. The beta terms subtract their own rounding margin, 2^-30·sum_j beta_j·(rho_1j + tau_1). Covered by the same randomised checks.

**Results.** - **mse_d24_w32_s1500:** CROWN 4.4e5 nodes and 2.4e6 fpe. Optimised slopes: 1.4 to 1.6x fewer nodes but 2.7 to 4x more cost. Phase splitting with 16 leaves: 3.3x fewer nodes but 75x more cost.
- **Looseness (exp_gap):** the LP removes only 20 to 55% of CROWN's gap at r = 8.
- **Upper limit for any box method:** the exact box minimum (MILP over the box, re-checked witnesses) certifies only r50 = 8 to 20 on 6 of 10 nets, against CROWN's 4 to 12 and ≥ 16 for the cube.

**Verdict.** Hopeless as a fix. Fewer nodes never pay for the cost per node, and even a perfect box relaxation is capped well below the cube by box points with f < t.

### Hybrid: B&B to a budget, then sampling inside the undecided subcubes (estimate_undecided, the envelope estimator) (two-sided, probabilistic (coverage ≥ 1−delta))

**Soundness.** The undecided subcubes of one breadth-first level are disjoint and equal-sized, so their union is an envelope with exact mass and an exact uniform sampler. KL intervals are applied to the definitely-failing indicator (lower end) and the failing-or-ambiguous indicator (upper end), with a union bound over doubling stages (delta_j = 6·delta/(pi²·j²)) and the 2^-53 rounding of the mean passed on. Empirical coverage: 2 misses in 200 runs at delta = 0.2.

**Results.** - **K = Z_u / (p − lo):** stays close to 1/p until the tree is nearly complete. Values: 2.8e3 down to 466 (p = 3.6e-4), about 1e5 (p = 9.7e-6), 1.7e7 to 4e6 (p = 6e-8), 77 (d = 28, p = 1.3e-2).
- **Example:** at p = 9.7e-6 the 3e7-sample cap gives [8.0e-6, 1.23e-5]; Monte Carlo needs 1.1e8 samples for ratio 1.1.
- **Coverage:** every interval contained p.

**Verdict.** Sound but no gain over Monte Carlo on the suite. The envelope's looseness K is about 1/p, because CROWN certifies almost nothing above r*.

### Perfect-engine (oracle) tree: oracle_tree_static / oracle_tree_greedy (diagnostic (not a procedure))

**Soundness.** Not a certificate: it uses the exact failing set. Checked against a brute-force recursive count on 200 random small cases.

**Results.** - **Tree size:** about F·(d − log2 F) nodes. Examples: 49 (F = 1), 105 (F = 2), 3.8e3 (F = 163, d = 24), 3.4e3 (F = 89, d = 28), 7.9e4 (F = 6012).
- **Against CROWN's tree:** CROWN's is 10x (F = 6012) to 4800x (F = 89) larger. For p = 0 nets a perfect engine needs 1 node.
- **Failing sets (exp_isolation):** mean pairwise distance ≈ d/2 (11.9 of 12, 13.4 to 13.9 of 14). The largest greedily grown failing subcubes have dimension ≤ 4. 36 to 91% of failing points have a failing neighbour.

**Verdict.** It locates the bottleneck: the deductive engine, not the geometry of the failing set. Each perfect-engine node is a coNP-hard question (min of f over a subcube), so this is not achievable in general.

### HiGHS MILP branch and cut over the cube (milp_min, integer inputs) (heuristic: unsound p = 0 claims; sound lower bound p ≥ 2^-d from re-checked witnesses)

**Soundness.** Its optimality and p = 0 claims rest on floating-point tolerances and are not certificates. A returned point is re-evaluated with the tau margin, so a failure is a sound witness. All 6 witnesses were also rechecked in exact rational arithmetic.

**Results.** - **Claims p = 0** on 7 nets with d = 16 to 32, in 31 to 96 s. The sound B&B certifies all 7 in 0.0 to 39 s.
- **Fails where B&B succeeds:** the near-constant d = 64 net (B&B: 460 fpe, 0.0 s) and mse_d28_w64_s1500 (B&B: 405 s); the solver's dual bounds there were −1.4 and 0.91.
- **Witnesses found:** the single failing point of mse_d24_w32_s2000 (73 s); bce_d28_w32_s100 (15 s); both d = 48 own nets, where B&B and Monte Carlo find nothing; and the d = 64 suite net bce_d64_w64_s100 (f = −1.09), where Monte Carlo found 0 failures in 1e7 samples.
- **No result within 180 s:** d = 64 squared-loss nets (dual bounds −0.8 to −6.6) and all two-hidden-layer nets.

**Verdict.** Works in a regime, as a witness finder and an indication of what a branch-and-cut engine could certify. It is not sound for upper bounds without exactly checked proofs, and it cannot count.

### Prototypes that failed (scratch only, not kept): quadratic cube-aware relaxation, and LP-dual phase+input B&B (lower bounds on f per subcube)

**Soundness.** Quadratic relaxation: relu(z) ≥ z(z − l)/(u − l) on [l, u], plus a diagonal shift using y_i² = 1 on the cube, plus a Frank–Wolfe bound for the convex QP. Valid, but not hardened for rounding. LP-dual B&B: the LP's dual values (alpha, beta) are fed into the sound Lagrangian evaluation; it matched HiGHS's LP value exactly.

**Results.** - **Quadratic relaxation:** worse than CROWN at every r = 4 to 16 on mse_d24_w32_s1500 (median gap 0.33 against 0.23 at r = 4).
- **LP-dual B&B** with fractionality or chord-gap branching: did not certify own_mse_d32_w32_s3000 within 120 to 300 s (11.8k nodes, 0.41 left below t). CROWN B&B certifies it in under 1 s.

**Verdict.** Hopeless as tried. A phase-branching engine would need good branching and cuts, as in branch-and-cut solvers, to compete.

## Adversarial soundness check

**Verdict.** For nets with 1 or 2 hidden layers (the whole suite), the colleague's B&B deduction engine is sound in every test I ran, and every efficiency number I re-ran reproduces exactly. But the claim that it is sound on EVERY MLP, and that every interval contains p, is false in three edge cases, each found and confirmed against exact rational counting.

(1) Real false certificate, 3 or more hidden layers, extreme weights. A layer-3 CROWN bound overflows to NaN; np.maximum passes the NaN on; _relax then treats the NaN interval as a dead unit. A d = 3 net that fails on all 8 points (p = 1) is certified exactly p = 0 at the root. The weight guard (rho <= 1e300) does not bound products across layers such as |W3||W2|: the floor tau >= 2^-30 lets them reach about 2.1e308, which overflows. The window is narrow (rho at least about 0.86e300), and depth 2 is immune: the NaN only reaches the output bound, which then decides nothing.

(2) 1-ulp violation in estimate_undecided. lo starts at F = res.fail/2.0**d, rounded to nearest rather than down. At d = 57 it returns lo = 0.5 + 2^-53 > p = 0.5 + 12/2^57 deterministically. This needs a certified count of 2^53 or more, so d >= 54.

(3) r_enum < 0 is accepted. Undecided single points are then "split" on an already-fixed coordinate, which breaks the partition. The only guard is an `assert`, so under python -O with stop_on_failure the engine returns an "exact" [0.25, 0.25] for p = 0.5. Normal Python stops with an error instead.

All three fixes are one-liners: treat non-finite bounds as undecided (or lower the guard), start lo at res.lo, and validate r_enum >= 0 with an explicit raise instead of the assert.

Holds:
- About 94,000 adversarial B&B runs: 0 violations against exact rational counts and 0 against the float count.
- 64,000 direct bound checks (CROWN, optimised slopes, phase splitting): 0 violations; a lower bound never exceeds the exact minimum by more than 2.8e-7 tau.
- Sampling-stage coverage over 12,000 runs: 0.3% misses at delta = 0.1 and 1.5% at delta = 0.3.
- Their own check_soundness reproduces identically.
- All 6 MILP witnesses fail in exact arithmetic, and p = 0 certificates at d = 16, 24 and 32 match full enumeration.

Overstated:
- Costs in fpe hide about 2.2x more wall-clock per fpe for B&B than for a Monte Carlo sample, so the speedups over Monte Carlo shrink by about that factor.
- The large-d runs "after 1e7 fpe" and "at the same 180 s budget" actually stopped after 3.3e4 to 6.1e5 fpe and 10 to 19 s. The conclusion, [0, 1] at d = 64 and 128, still follows from the measured r50 <= 24.

Scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/redteam/.

- [soundness broken] Input B&B with CROWN bounds (nets_verify.Bounder / bab), nets with 3 or more hidden layers: Hand-built net (attack_overflow.py): d = 3, widths [1, 2, 1].
- W1 = 1e-200 (all entries), b1 = 1e-15.
- W2 = [[1e154], [1e154]], W3 = [[1e154, 1e154]].
- w4 = -0.4, b4 = 2e291, t = 0.
rho_max = 9.31e299 passes the 1e300 guard, because tau_1 >= 2^-30 lets |W3||W2| reach about rho·2^30/5. The layer-3 CROWN product Aeff @ W2 = 2e308 overflows to inf, then NaN (inf·0 at free coordinates). np.maximum(lo_c, IBP) passes the NaN on. _relax(NaN, NaN) gives active = False and unstable = False, so the unit is treated as DEAD (slopes 0) without any sign proof. Result: Every point fails: float f = -7.8e292, and the exact rational count is 8/8, so p = 1. The root bounds are lb = ub = b4 = 2e291 >= t + 2·tau, so bab certifies the root safe and returns exact = True, [lo, hi] = [0, 0].

The written argument (item 2) bounds rounding error but assumes no overflow, and item 4 ('stable units fixed only when the padded interval proves the sign') fails for NaN intervals.

Scope:
- At depth 2 the same construction is harmless (attack_overflow_L2.py): the NaN only reaches the output bound, nothing is decided, and the counts are correct.
- A random search of 418 nets aimed at this window found nothing; the window is narrow (rho_max between about 0.86e300 and 1e300).

Fix: treat any non-finite l or u as unstable with infinite range (or refuse to decide), or tighten the guard to about 1e290.
- [soundness broken] Hybrid sampling stage (estimate_undecided): lo is initialised to F = res.fail / 2.0**d, a round-to-nearest float, not res.lo. attack_Fround.py builds a d = 57 net:
- relu(-x0), plus two AND detectors with exact failing subcubes of 8 and 4 points;
- plus an identically zero but CROWN-loose pair 0.3·relu(x55+x56) - 0.3·relu(x55+x56).
bab(r_enum=0, max_nodes=budget) certifies F = 2^56 + 12 and stops at the last level with 4 undecided points, none of which fail. Result: p = (2^56 + 12)/2^57 = 0.5 + 1.5·2^-54. Returned lo = 0.5 + 2^-53 > p, and Fraction(lo) > p is True every time (probability 1, not <= delta). res.lo itself is correct (0.5).

The error is 1 ulp and needs res.fail >= 2^53 (d >= 54), so it cannot occur on the suite. Fix: start with lo = res.lo.
- [soundness broken] bab parameter validation (r_enum) and the mass-balance assert: r_enum = -1 (a natural way to ask for 'no enumeration') on random small nets. In attack_renum_neg.py, a d = 2 net has one clear failing point and one near-tie failing point (exact f = -2^-40, within 2·tau of t), run with stop_on_failure = True. Result: At r = 0 an undecided point is split on argmax(score), which is a fixed coordinate. One child duplicates the parent and the other is a point outside it, so the partition is broken.
- Normal Python: ValueError ('negative shift count') in 76 of 300 random nets, or AssertionError in the stop_on_failure case. No wrong output.
- python -O: the assert vanishes and bab returns exact = True, [0.25, 0.25], while the exact p = 0.5.

This needs an invalid parameter, plus -O for a wrong answer. Fix: reject r_enum < 0 and replace the assert with an explicit raise (the project's stats.py already notes that asserts vanish under -O).
- [holds] bab, randomized adversarial fuzz against exact rational counting (fuzz_bab.py, fuzz_overflow.py, edge_params.py): About 8,900 nets with d = 2 to 7, L = 1 to 4, widths 1 to 6:
- weight and bias scales from 1e-300 to 1e150, chosen independently per layer;
- 20% zero weights;
- integer weights with exact ties f = t;
- subnormal-only weights;
- catastrophic cancellation (output weights 1e8 on near-duplicate units);
- dead units;
- p = 0 and p = 1;
- thresholds at values f actually attains.
Each net was run under 12 parameter sets: r_enum 0 to d, static branching, max_nodes 1 to 20, max_fpe, stop_on_failure, probe = 1 with min_rate = 1, max_frontier 1 to 5, time_limit = 0, batch = 1, optimised slopes 1 to 40 iterations, phase depth 1 to 3. On top of that:
- 1,500 near-tie nets (perturbations of 2^-52 to 2^-60, below float resolution, so the float and exact signs of f - t disagree);
- edge values max_nodes = 0, max_frontier = 0, probe = 0, alpha_iters < 0. Result: 94,000 runs: 0 violations against exact rational counts, 0 violations against the float64 count, 0 crashes. The near-tie and edge-value runs also had 0 violations. Near-tie points always land in the ambiguous gap.

The written argument checks out line by line:
- lam rounding: u >= ulp(tau), so u/(u - l) >= about 2^-84 and never underflows.
- tau dominates gamma_n·M.
- The beta margin in phase_bound is correct.
- The minimax/LP claim for the optimised slopes is correct.
- The tree is a partition, counted with Python integers.
- [holds] Bound validity (CROWN, optimised slopes, phase splitting) checked directly (fuzz_bounds.py): 3,000 random nets: L = 1 to 3, scales 1e-8 to 1e8, 30% rounded to integers. 8 random subcubes each. Optimised slopes up to 300 iterations; phase splitting with depth 1 to 4 and up to 300 iterations. Every computed lb was compared with the EXACT rational minimum over the subcube's points (plus tau) and with 200 random real points of the box; ub symmetrically. Result: 64,032 checks, 0 violations. The largest excess of a computed lower bound over the exact minimum is 2.8e-7·tau. A copy of their check_soundness.py, writing to scratch, reproduces their numbers exactly: 12,000 bound checks with 0 violations, 232 B&B runs with 0 violations, 2 misses in 200 coverage runs.
- [holds] Sampling stage coverage (estimate_undecided): 12,000 runs on 91 nets (d = 8 to 13, L = 1 or 2, including integer-tie nets with ambiguous points).
- Stops: max_fpe, stop_on_failure or max_nodes.
- eps in {0, 0.1, 0.5}.
- max_samples in {1, 2, 7, 64, 1000, 20000}.
- first in {1, 3, 64}.
I also checked the argument: the frontier cubes are equal-sized and disjoint, so cube-then-bits sampling is exactly uniform; the doubling stages are deterministic with union bound delta_j = 6·delta/(pi²·j²); the two ends use one-sided KL bounds on the definite and definite-or-ambiguous indicators. Result: Miss rates: 0.3% at delta = 0.1 (19/6000) and 1.5% at delta = 0.3 (91/6000), far below delta. The argument is valid, apart from the lo initialisation bug reported above.
- [holds] Reproduction of the reported certificates and counts: - Re-ran exp_suite settings on 7 suite nets.
- Retallied zero.json.
- Retrained exp_zero nets at d = 40 and d = 64 (16,000 steps, same seeds).
- Rechecked all 6 MILP witnesses in exact rational arithmetic.
- Enumerated 4 own nets (d = 16, 24) and own_mse_d32_w32_s3000 (2^32 points, 1,522 s) to check B&B's p = 0 claims. Result: Everything matches:
- Counts and fpe reproduce bit for bit: mse_d24 s300/s1000/s1500/s2000 (7.33e6, 3.69e6, 2.39e6, 1.44e6 fpe) and bce_d28 s60/s100/s150.
- Cost relative to MITM enumeration: 0.71 to 3.64x (mse), 0.0083 to 0.125x (bce).
- MC/B&B ratios: 47.7 (F = 163), 1.29e4 (F = 1), 0.84 (F = 6012), 1.81e5 (F = 2), 24.2 (F = 3543).
- zero.json: 98 / 5 / 4 of 107 nets.
- The medians by d (1.03e4, 2.56e4, 1.09e5, 2.9e5) reproduce as summarize.py computes them, i.e. over nets with p = 0 certified, of all training lengths.
- d = 40: 2.08e3 fpe; d = 64: 3.65e7 fpe in 144 s.
- All 6 witnesses fail exactly, from f - t = -0.0012 to -1.09 (bce_d64_w64_s100). This sound lower bound needs no Monte Carlo.
- The d = 32 enumeration gives 0 failures, matching B&B's 2.5 s certificate.
- [claim overstated] Cost metric: fpe versus wall-clock (comparisons with Monte Carlo): Measured Monte Carlo (numpy forward on fresh random inputs) and B&B wall-clock under the same machine load, on mse_d24_w32_s1500 and s2000. Result: Monte Carlo costs 1.75 µs per sample; B&B costs 3.8 to 4.1 µs per fpe. So in wall-clock the B&B advantages are about 2.3x smaller than in fpe:
- F = 163: 48x in fpe, 21x in wall-clock.
- F = 1: 1.3e4x in fpe, 5.9e3x in wall-clock.
- The crossover (0.84 in fpe at F = 6012) becomes about 0.36, so B&B wins only up to roughly F ~ 2e3.
The ordering and conclusions survive, and their README does say that times are indicative.
- [claim overstated] Large-d anytime intervals (exp_large and exp_milp's 'same budget' B&B): Read the stored runs and the stopping logic. bab checks fpe_now + n·crown_flops > max_fpe, which assumes every frontier node will be bounded, although the probe (min_rate = 0.01) skips most of them. Result: '[0, 1] after 1e7 fpe' is overstated. All d = 64 runs stopped at depth 21 after 3.3e4 fpe and 6,655 bounded nodes; the d = 128 runs stopped at 6.1e5 fpe. That is 16 to 300x less than the stated budget.

Likewise, 'same 180 s budget as the solver': B&B stopped after 10 to 19 s on its frontier or projected-cost cap.

The conclusion ([0, 1] at d = 64 and 128) is still supported independently by the measured CROWN r50 of 4 to 24, which implies at least 2^40 leaves. Only the stated effort is wrong.
