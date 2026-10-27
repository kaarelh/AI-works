# Referee report: code-soundness (code lens)

**Verdict.** needs major fixes. The sampling code is sound: tens of thousands of runs checked against exact p found no failures. Two soundness bugs remain, each giving a wrong interval with probability 1. (1) The Part-2 verifier trusts a support field that the prover controls. (2) The Janson/Harris code computes D(B_i) wrongly when a clause repeats a literal. There are also three minor floating-point or validation issues. The theorems themselves are not affected; these are implementation bugs on soundness-critical paths. Code reviewed: HEAD 42ec83fb (includes 6f67d2a9 'outward-rounded envelope/DFSB/Janson'); the code was being edited while I worked, and every finding was re-run against this version.

**What was checked.** All test scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/review/. No repository file was edited.

What holds up:
- stats.kl_interval: the endpoints are conservative, and coverage is exact. Over every k in 0..N, N up to 1e4, delta from 0.5 to 1e-6, and mu from 1e-9 to 1, the worst miss probability is 0.69*delta (t_kl.py). sequential_mean: the stage sizes are fixed in advance, delta_j = 6 delta/(pi^2 j^2), and intersecting the stage intervals is valid. Empirical miss rates at delta=0.2 were 0.3-2%.
- rup.RUPChecker: 40,000 random CNFs with random proofs (deletions, empty clauses, fresh variables). Its verdicts agree with a naive unit-propagation checker every time, and it never accepted a satisfiable formula. It also accepted all 194 real Glucose DRUP proofs, and rejected those proofs and 970 mutated ones when replayed against formulas made satisfiable by deleting clauses (t_rup.py, t_rup2.py). The 2-watched-literal invariants and the handling of level-0 units look correct. cnf.check_rup_refutation is also sound on the same fuzz.
- argument.domination_cnf: compared with brute force over 4,232 pairs of circuit and envelope (compiled, context-width and random envelopes; circuits with XOR/THR gates). UNSAT always implied domination, and leaving THR gates unconstrained is a sound relaxation.
- Forcing: forced_input_literals (unit propagation, probing, Gaussian elimination), dfsb.nnf_forced, to_nnf equivalence and exact_ve: 3,000 random circuits, 0 errors. gauss_forced: 20,000 random affine systems, sound and complete (t_forcing.py).
- Envelopes: the compiler and context-width envelopes dominated C in 2,732 cases. Context-width support equals C^{-1}(1) in 1,366 cases. Masses are exact. Chi-square tests of the literal-leaf sampler gave uniform p-values over 834 tests (t_envelope.py). With deliberately wrong box values, the sampler's law matches Q_hat = D*phi_rho/Z_hat as in the proof of Thm boxes (360 chi-square tests, t_box_sampler.py). envelope_estimate with boxes and wide box intervals: 1,436 runs, 0 misses (t_box_cov.py). bias_range's min/max-product DP is exact on derivations.
- DFSB interval combination (force/and/or/branch, now rounded outwards) and the delta/#leaves union bound are correct.
- End-to-end coverage at delta=0.05 against p by enumeration: DFSB 124/45,127 statistical misses; auto_estimate 4/142,177; meta_estimate 0/123,119 (t_coverage.py). The other apparent misses were 1-ulp errors in my float reference; checked against exact rational p, there were 0 misses in 450 runs (t_fp_exact.py). Opaque-threshold circuits: 2/600 (t_dfsb_opaque2.py).
- Janson, current product form with outward rounding: 4,000 random unate CNFs, including marginals in {0,1} and near-certain clauses, 0 misses. Tilting: correct except the rounding issue below. Meta's intersection and delta split are fine. The project's own pytest suite passes (45 tests).
- A bug in 5011536e was fixed in 6f67d2a9. The old envelope_estimate returned [0,0] when every box estimate was 0 (Z_hat=0). It now returns [0, z_upper]: re-run on a box of mass 6e-8 with 1e5 samples, 0/40 misses (t_box_zero.py). A regression test for this would be worth adding.

## Findings

### 1. [critical] code/rareprob/argument.py, verify(), step 1 ('re-check: the argument is untrusted data')

**Problem.** The PROD disjointness check reads env.sup, but that field comes from the prover's own Envelope object. A prover can set the support of a duplicate literal node to 0. A non-decomposable PROD then passes the check: the mass DP multiplies probabilities that are not independent, and the sampler is not Q_phi. The domination proof is still valid, because support_circuit never reads sup, so proof_ok=True.

Results (t_attack_verify.py, t_attack_verify2.py):
- Under-estimate: C=x0∧x1 (p=0.25) with envelope PROD(x0, x0', x1), sup[x0']=0, and the honest DRUP proof. Output [0.1245, 0.125], wrong in 20/20 runs.
- Over-estimate: C=x1∧x2 with envelope SUM(PROD(x0=1, x0=0 with lied support), x1∧x2). With the proof the output is [0.304, 0.3186] vs p=0.25 (20/20 wrong). With no proof, the 'valid lower bound' is 0.3045 > p (20/20).

This breaks Thm pcis-sound as implemented, in both two-sided and lower-bound-only mode.

**Proposed fix.** Never read derived fields from the argument. In verify, before the RUP step and before any sampling:
- Rebuild the envelope from a canonical serialisation through Envelope.lit/SUM/PROD.
- Or validate it directly: kinds in {ONE, ZERO, LIT, SUM, PROD}; child ids are integers in [0, u); LIT data (i, b) with 0<=i<n and b in {0,1}; SUM and PROD have at least one child.
- Recompute every support bottom-up: LIT gives 1<<i, ONE/ZERO give 0, SUM/PROD give the OR of their children.
- Check PROD disjointness on the recomputed supports.
- Run the validation even when proof is None, since lower-bound mode also needs a correct Z and Q.
- Add the two attacks above as regression tests. The experiment's 'adversarial arguments' do not cover malformed envelopes.

### 2. [critical] code/rareprob/janson.py janson_interval (log_false(c) over the literal list); meta.as_cnf; cftp.UnateSystem (self.vars / self.pb)

**Problem.** D(B_i) is computed as a product over the clause's literal list, so a repeated literal is counted twice. as_cnf accepts such clauses, for example C.OR(x,x) or two distinct NOT(x) gates. The Delta terms are deduplicated through dict(), but b_i, M and the stage partition are not.

Results (t_janson_dup.py):
- Small case: (x0∨x0)∧(x1∨x1∨x2), p=0.375, gives Janson [0.6562, 0.6563].
- Large case: 200 random monotone width-10 clauses over 200 variables, literals doubled. VE declines, and Janson's interval [0.999809, 0.999997] is tight, so meta_estimate returns it alone. The correct sandwich is [0.822499, 0.838445], so p is missed with certainty.
- cftp.telescoping_estimate on a doubled CNF with p=0.166 returns [0.461, 0.184] (lo > hi), because of the inflated Harris floor (t_cftp_dup.py).

**Proposed fix.** Canonicalise clauses once, at entry to as_cnf, janson_interval and UnateSystem: c = sorted(set(c)), and reject or drop tautologies. Equivalently, compute log_false(dict(c).items()), as is already done for the pair terms. Add a regression test with repeated literals.

### 3. [major] code/rareprob/rup.py RUPChecker.check_refutation (is_rup(step), then len(step), then add(step))

**Problem.** Each proof step is iterated twice. A prover-supplied object can therefore show a RUP-valid clause to is_rup and the empty clause to add. A list subclass whose __iter__ yields [1,-1] the first time and [] after that makes the checker accept a 'refutation' of the satisfiable CNF {[1,2],[-1,2]} (t_attack_proofobj.py). This is harmless when proofs come from parse_drup, but verify() accepts arbitrary in-process objects. It is the same trust problem as the env.sup finding.

**Proposed fix.** At the top of the loop, take a snapshot: cl = [int(l) for l in step] after type-checking that step is a list or tuple of ints or a deletion. Use cl for is_rup, the emptiness test and add. Better still, have verify accept the proof only as DRUP text or bytes and parse it itself.

### 4. [minor] code/rareprob/tilting.py tilted_estimate (B = chernoff(...) then est.scaled(B)); propagates through meta.meta_estimate

**Problem.** Tilting has no outward rounding, unlike the envelope, DFSB and Janson code. When t equals the number of blocks, the tilted law puts S=t almost surely, so W is 1 and the KL upper end is exactly 1. The interval is then [Z*lo, Z_float], and the float Chernoff value lands up to 4.3e-14 (relative) below the true p. This happened in 28/150 random threshold_of_blocks instances (every one with t=k). meta_estimate returned [0.0699309, 0.07031249999999925] for p=9/128=0.0703125 (dbg_tilt2.py). experiments/exp_coverage.py hides misses like this with its 1e-9 relative slack in contains().

**Proposed fix.** Compute log Z with math.fsum. Bound the rounding error of the log1p/exp terms, about (k+2)*2^-50. Return [exp_down(log lo + logZ - eta), exp_up(log hi + logZ + eta)], reusing envelope._exp_up and _exp_down. Drop or shrink the 1e-9 slack in the coverage experiment so rounding misses are visible.

### 5. [minor] code/rareprob/ve.py exact_ve (return float(np.exp(scale) * rest)) and meta.meta_estimate ([p(1-1e-9), p(1+1e-9)])

**Problem.** VE keeps a log scale internally but returns a float that underflows. For C = AND of 1,100 inputs with q=0.3, the true p is 10^-575.2 > 0, yet meta returns the point interval [0.0, 0.0] labelled 'exact (variable elimination)' (t_ve_tiny.py). For p in the subnormal range (below 2^-1022), the returned float has less relative precision than the 1e-9 padding. The paper explicitly considers p = 2^-Omega(n).

**Proposed fix.** Return log p (scale + log rest) and keep the exact-zero case (mx == 0) separate. In meta, when exp underflows, output [0, ulp(0)], or carry log-domain bounds. For subnormal results, widen by an absolute few*ulp(0) as well as the relative 1e-9.

### 6. [minor] code/rareprob/stats.py sequential_mean: assert z.min(...) >= -1e-12 and z.max(...) <= 1 + 1e-9

**Problem.** The requirement that samples lie in [0,1], which the KL interval needs, is enforced only by an assert, and python -O removes asserts. With a malformed envelope, a weight 1/phi = inf or NaN would then reach total/N. kl_interval clamps that mean to 1 and returns an interval near 1 for E[W], silently inflating the estimate.

**Proposed fix.** Replace the assert with an explicit check (np.isfinite(z).all() and the [0,1] bounds) that raises ValueError, or clip z to [0,1], which is sound for the lower-bound path. Do the same for any other assert that guards soundness.
