# Final referee report: code

**Verdict.** needs major fixes. One new soundness bug: on a narrow but legal class of threshold circuits, the tilting path (and so meta_estimate) returns an interval that misses the evaluator's p with probability 1. All six earlier code findings are resolved, one of them only partly: asserts that guard soundness remain in janson.py, cftp.py and dist.py.

**What was checked.** Code reviewed at HEAD 750222ce. No repository file was edited (git status is clean). Scratch scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_code/.

LENS A: line-by-line reading.
- I read stats, envelope, compile, circuit, nnf, cnf, ve, exact, meta, janson, tilting, argument, rup, dfsb, ctxwidth, cftp, localthr and affine in full, plus sec-setting.tex and sec-envelopes.tex.
- Steps I re-derived and found correct:
  - KL interval endpoints and the stage levels 6δ/(π²j²); intersecting the stage intervals is valid.
  - Log-domain mass and rounding bound of log_masses: the SUM/PROD local errors and the max-sum DP over derivations.
  - Box bias identity Ẑ·E_Q̂W ∈ [ρmin, ρmax]·p, and the bias_range DP.
  - Rejection fill and the fill_cap truncation, which gives [0,1].
  - Compiler rules: forcing, independence, Shannon, dropped conjuncts, opaque nodes give 1, budget gives 1.
  - DFSB rules F/D/S/E/B/T', and every _combine operation rounded outwards (the OR via log1p/expm1 with relative widening).
  - Unit propagation, probing, Gaussian elimination (RREF singleton rows) and the Tseitin/XOR clauses.
  - The VE mantissa/exponent analysis (Higham γ_r) and the exact-zero detection.
  - Janson product form (Boppana–Spencer step and Harris) and its outward rounding.
  - CFTP: anti-monotone bounding chain, TV ≤ θ for halted runs, bias e^{±a_k}, the Chebyshev/median step with data-dependent v, and κ for the sampler's law.
  - TG: Dobrushin bound monotone in θ, weighted-norm sweep bound, Riemann gap, Bernstein/Maurer/pairing variance, window/KL exceedance, coupling budget.
  - Presolve: p = M·E[W], pivots never read, solved-form homomorphism.
  - Affine abstract interpretation, the restrict_to RREF, LinearOrderDP, and the KLM identity with masses (1±rel).
  - Propagator THR monotonicity of rounded sums; context-width decomposability (kappa(h) ∩ sup(c) ⊆ kappa(c), shared variables ⊆ kappa(h)).
- I checked sanitize_envelope, canonical_proof and the domination CNF offsets.
- Citations: Hoeffding Thm 1, Maurer 2003, Higham Lemmas 3.1/3.3, Alon–Spencer Thm 8.1.1 and Häggström–Nelander say what is attributed to them.
- The sec-envelopes example K = 2^25.7 (k=20, p=2^-40) recomputes to 2^25.74.

LENS B: brute force against exact rational p.
- The project suite passes: 247 tests.
- meta_estimate on random edge-case circuits: 2,880 runs, 0 misses. The circuits mix THR gates (integer, negative and real weights, thresholds at an achievable sum ±1e-13 or ±0.5), repeated children, constants, wide gates that force VE to decline, and marginals of 0, 1, 1e-9 and 1−1e-9. Methods exercised: VE, TG, context width, DFSB, presolve, affine envelope, and the empty-envelope p=0 exit. A further 80 runs on 16–18-input circuits where VE declines also had 0 misses.
- Direct runs, 800 circuits per method at δ=0.1: DFSB 0 misses, auto_estimate 0, context width 0, presolve 3/800, affine envelope 2/800. Those 5 misses are plain Monte Carlo cases and are statistical, well under δ.
- Janson: 0/600 misses, including duplicated literals and clauses and 0/1 and extreme marginals. CFTP: 0/200 misses (187 non-trivial verdicts).
- TG on chain LTCs with exact p: 0/780 misses, covering Glauber and CFTP samplers, with and without window, with and without an H conjunct, with tiny p.
- LinearOrderDP mass against exact rationals: 400 subspaces, worst relative error 3.7e-16, always within its rel bound; zero masses exact.
- verify() fuzz: 900 runs with random lying-support and non-decomposable envelopes and honest, bogus or missing proofs, 0 misses.
- Tilting at integer t against exact p: 0/150 misses.

Claims that depend on experiment numbers, not judged:
- sec-envelopes: the Janson example (m=6·10^4 clauses, [4.33, 5.07]·10^-7, about 30 s).
- README examples (p≈10^-20 to a factor 1.7 with 7·10^4 samples).
- p1-affine: '600 estimates (E7)', '75 seconds'.

## Audit of earlier findings

resolved: 5, partially resolved: 1

- [resolved] (critical) argument.verify trusts the prover's env.sup (PROD disjointness check): verify() now calls sanitize_envelope. It reads only kind, data and root, each once, and accepts only exact-str kinds. It checks literal and child index ranges, requires children to precede parents, recomputes supports bottom-up and checks every PROD for decomposability. This runs with or without a proof, and a malformed envelope gives [0,1]. Re-ran both earlier attacks under python -O (C=x0∧x1 with PROD(x0, x0', x1); C=x1∧x2 with a SUM over a lying PROD, with and without a proof): all three give 'malformed envelope: trivial interval' [0,1]. Regression tests exist in tests/test_fix_pcis.py. My 900-run verify fuzz with lying-support and non-decomposable envelopes had 0 misses.
- [resolved] (critical) Janson/Harris/CFTP count a repeated literal twice: Clauses are now canonicalised in three places: meta.as_cnf (literal sets, tautologies dropped, duplicate clauses removed), janson_interval (sorted({...}) per clause) and cftp.UnateSystem (sorted set). Raw duplicated input (x0∨x0)∧(x1∨x1∨x2) with p=0.375: Janson [0.37499999993, 0.37500000007]; CFTP [0.375, 0.393] (it was lo > hi before). The 200-clause doubled-literal instance through meta now gives the Janson sandwich [0.82250, 0.83873] instead of [0.9998, 0.99999]. 600 random unate CNFs with duplicates: 0 misses.
- [resolved] (major) RUPChecker iterates each proof step twice (is_rup vs add): check_refutation now snapshots each step once (step = list(raw), integer check, then [int(l) ...]) and uses the same list for is_rup and add. verify() also passes only the fresh copy made by canonical_proof (exact list/tuple/str/bytes types, deletions dropped, literals bounded by the CNF's variable count). The earlier list subclass that yields [1,-1] and then [] is now rejected (check_refutation returns False). A test exists: test_rup_snapshots_steps.
- [resolved] (minor) tilting.tilted_estimate has no outward rounding (misses at t = k by ~1e-14): log B is now computed with fsum. The interval is widened by eta (block masses, log B, the sampler's law) and by tau (53-bit draws), and rounded with _exp_down/_exp_up. 150 random threshold_of_blocks instances, including t = k, checked against exact rational p: 0 misses (28/150 before). exp_coverage.contains now compares exactly, with no 1e-9 slack. A separate, deterministic tilting miss at non-integer thresholds is reported below as a new finding.
- [resolved] (minor) VE result underflows; meta returns [0,0] 'exact' for tiny p: meta now uses ve.ve_bounds: a mantissa/exponent representation with a proved relative error and a separate exact-zero flag. VEResult.interval() rounds outwards and keeps the upper end positive. AND of 1,100 inputs at q=0.3 (p = 2^-1910.66): meta returns [0, 5e-324] with log2 bounds, not [0,0]. exact_ve's docstring now warns that it may underflow.
- [partially resolved] (minor) sequential_mean's [0,1] check was an assert (removed by python -O): stats.sequential_mean now checks isfinite and the range explicitly and raises ValueError; verified under python -O with inf samples. The earlier fix also asked to replace every other assert that guards soundness. These remain: janson.py:71, cftp.py:38 (is_unate) and dist.py:20 (marginals in [0,1]). They are reported below as a new minor finding.

## New findings

### 1. [critical] code/rareprob/meta.py as_block_threshold (returns the gate's real t) and code/rareprob/tilting.py tilted_estimate (logB = log_chernoff(blocks, t, th) and draw(): np.where(S >= t - 1e-12, np.exp(-th*(S - t)), 0))

**Problem.** The tilting path checks C with the evaluator's rule (S >= t - 1e-12) but builds the envelope phi_theta = exp(theta(S - t)) and the Chernoff mass with the real t. Take t in (m, m+1e-12], for example t = 20 + 1e-13. The gate fires at S = m, but phi = e^{-theta(t-m)} < 1 there, so phi does not dominate C. W = C/phi then exceeds 1 by about theta·1e-13, sequential_mean clips it to 1, and Z_theta is too small: the upper end falls below p with probability 1.

Reproduction: C = THR(x0..x19; weights 1; t = 20+1e-13), D uniform; evaluator p = 2^-20 exactly. tilted_estimate misses 20/20 (hi = 9.536743164034964e-07 < p = 9.5367431640625e-07). VE declines (fan-in 20 > 18), and tilting's interval is already tight, so meta_estimate skips context width and DFSB and returns it alone: 10/10 misses. A biased variant (20 OR-blocks, q in [0.6, 0.95], t = 20+5e-13) gives meta [0.356974, 0.3593075422547] against p = 0.3593075422633, 10/10 misses. DFSB on the same circuit contains p.

The relative error is only about 1e-11, but the miss is certain on a legal input. The experiments use integer t and are not affected.

**Proposed fix.** In as_block_threshold, read the integer threshold off the evaluator: t_int = localthr._thr_count_threshold(C.params[g], len(C.args[g])), and return None if it is None. Pass t_int to tilted_estimate. In tilted_estimate, require an integer t and use [S >= t] in both W and phi/logB, with no 1e-12. Checked in scratch: with t_int = 20 the interval contains p 20/20 times. Add the circuit above as a regression test.

### 2. [major] paper/sec-setting.tex (threshold gate defined as [sum_j w_j y_j >= t]) vs code/rareprob/circuit.py eval_packed (`s >= t - 1e-12`, left-to-right float sum) and the circuit.py docstring ('1 iff sum_i w_i*g_i >= t (real weights)')

**Problem.** Every module computes p for the evaluator's function: VE thr_sum, to_nnf ceil(t-1e-12), ltc_from_circuit, the affine Propagator and the ground truth exact_prob_rational. That function differs from the paper's definition for real weights and for thresholds within 1e-12 of an achievable sum, so the claim 'sound for every circuit' holds only under an unstated convention.

Example: THR(x0, x1; 0.1, 0.2; t = 0.30000000000000004). In exact arithmetic on these doubles, 0.1 + 0.2 < t, so the gate never fires and p = 0. The evaluator fires at (1,1), and meta_estimate returns VE's 'exact' [0.2499999999999996, 0.25000000000000044]. For THR(x0..x19; 1; 20+1e-13), the paper's p is 0 while every module reports about 2^-20. p1-affine.tex and p1-local.tex already refer to 'the function the circuit computes' as the evaluator's, but sec-setting, the README and the circuit.py docstring do not say so.

**Proposed fix.** Pick one convention and state it everywhere. Option (a): define THR in sec-setting, the README and the circuit.py docstring as the evaluator's function, [fl(((w1 g1 + w2 g2) + ...) + wk gk) >= t - 1e-12] in IEEE double (with integer weights this is [sum >= ceil(t - 1e-12)]), and say that all guarantees refer to it. Option (b): evaluate thresholds exactly, comparing exact rational sums of the double weights with t, and update ve.thr_sum, nnf.to_nnf, affine.thr_sum and localthr._thr_count_threshold to match.

### 3. [minor] code/rareprob/envelope.py envelope_estimate (_exp_up(...), math.exp(logZ) in the point value, hi not capped) and code/rareprob/argument.py verify (no exception handling around step 3); code/rareprob/tilting.py tilted_estimate and meta.meta_estimate (hi not capped)

**Problem.** A well-formed argument can crash the verifier instead of getting a verdict. Example: PROD of 700 copies of SUM(ONE,ONE,ONE) (empty support) times x0∧x1, with an honest DRUP proof. log Z is about 769, so math.exp raises OverflowError and verify() propagates it. If phi overflows to inf at a node off the sampled derivation, inf·0 = NaN reaches sequential_mean, which raises ValueError.

Upper ends above 1 are also returned. With 100 copies verify gives [0, 1.16e42]. Tilting with t <= 0 gives hi ≈ 1.00006, and meta passes it through. Definition 'sound interval estimation' requires [L, U] ⊆ [0, 1], and thm:envelope(ii) states min(Zu, 1). Soundness itself is not affected.

**Proposed fix.** In envelope_estimate, when log Z >= 0, fall back to phi ≡ 1 (plain Monte Carlo), as sec-envelopes says to; otherwise guard every exp. Return hi = min(1.0, hi) in envelope_estimate, tilted_estimate and meta_estimate. In verify, wrap step 3 in try/except and return [0, 1] (or the lower bound 0) on an exception.

### 4. [minor] code/rareprob/affine.py xpt_check (iterative walk over node['children'] with no visited set or node budget); likewise argument.sanitize_envelope's list(env.kind) on an unbounded iterable

**Problem.** Arguments are in-memory Python objects, so a prover can supply cyclic or unbounded ones. node = {'split': ('form', [4], 0), 'children': [node, node]} makes xpt_check run forever: it was still running after 10 s on a one-node argument. Each revisit splits on x4 again; one branch closes and the other continues. Soundness is not affected, but the 'poly-time verifier' claim does not hold for such inputs.

**Proposed fix.** Accept arguments only in a serialised form (JSON or bytes), or track id() of visited dict nodes and enforce a node budget tied to the argument size, treating a revisited or over-budget node as an open leaf (sound) or returning [0, 1]. Apply the same size bound when copying env.kind and env.data.

### 5. [minor] code/rareprob/localthr.py tg_estimate (widen = 1e-9; sampler == 'cftp' path)

**Problem.** The module claims a valid interval 'on every input', but two floating-point terms are not covered by the error budget.
(i) The 1e-9 log-slack is not derived. The rounding of That = h·sum(Y_l) is about (log2 L + 1)·u·theta·max|S|, roughly 9e-15·m for theta <= 4, and exceeds 1e-9 once there are m ≳ 1e5 factors.
(ii) In CFTP mode the per-update discrepancy between the float and exact samplers (FLOAT_TV_PER_UPDATE per site update, over up to 2·T_max·n updates per sample) is never charged; d_c stays unused, whereas Glauber mode charges it via cert.sweeps. No miss was observed in 780 TG runs (meta uses Glauber mode).

**Proposed fix.** (i) Replace widen with a proved bound, e.g. 2^-40·(1 + |zlo| + |zhi| + theta·(|t| + S_hi - S_lo))·(log2 L + 2). (ii) In CFTP mode, add 2·(sweeps used)·n·FLOAT_TV_PER_UPDATE per sample to a running total and return no verdict if it exceeds d_c.

### 6. [minor] code/rareprob/janson.py:71 (assert is_unate), code/rareprob/cftp.py:38 (assert is_unate), code/rareprob/dist.py:20 (assert on the marginals)

**Problem.** Soundness preconditions are still enforced by asserts, which python -O removes. Under -O, janson_interval([[(0,1)],[(0,0)]], uniform), i.e. x0 ∧ ¬x0 with p = 0, returns [0.25, 0.5], and telescoping_estimate on the same input returns [0.468, 0.532]. Product also accepts a NaN marginal under -O. meta_estimate checks is_unate itself and is not affected; the public functions are.

**Proposed fix.** Replace these asserts with explicit checks that raise ValueError: is_unate in janson_interval and UnateSystem, and np.all((q >= 0) & (q <= 1)) (which also rejects NaN) in Product. Add a test that runs under -O or calls the check directly.

