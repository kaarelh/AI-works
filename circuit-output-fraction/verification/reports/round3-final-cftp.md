# Final referee report: cftp

**Verdict.** sound with minor fixes

**What was checked.** Files read in full: paper/p1-cftp.tex; sec-setting.tex (def:sound); sec-envelopes.tex (Hoeffding–KL interval, Harris–Janson); p1-indep.tex (definition of unate, mu); and the cross-references in p1-tail.tex (meta class and thm:meta), p1-local.tex (abort-rule remark), sec-intro.tex and sec-discussion.tex. Code read in full: code/rareprob/cftp.py, plus the helpers it uses (janson.is_unate/exp_down/exp_up, stats.kl_interval, dist.Product), tests/test_fix_cftp.py and the cftp tests in test_core.py. The 12 relevant tests pass.

LENS A (re-derived by hand; inequalities also checked numerically):
- prop:truncation: the TV decomposition, and the Chernoff lower tail exp(-mu/8) with mu > eta R.
- Anti-monotonicity: phi_v is decreasing, and the heat-bath update preserves F, since events not containing v are untouched and F is a down-set.
- Bounding chains: L <= X <= U is preserved.
- Monotonicity across horizons: L' <= L <= U <= U' is preserved, so doubling with reused randomness is exact.
- Almost-sure termination: the window argument holds; 1_W is in F because D(F) > 0 and F is a down-set.
- Soundness proof of thm:cftp, step by step:
  - G has probability >= 1 - 2delta/3.
  - Harris gives r_k >= rho_k.
  - Halted outputs are i.i.d. from pi' whatever the stopping rule.
  - eta <= rho_k/16.
  - Bias: Z'/p is in [(1-eps'/16), e^{eps'/16}].
  - Variance: (1-rho+eta)/(rho-eta) <= 2/rho, which I re-derived. Also e^{2Lambda/N} <= 1 + eps'^2/64, and Chebyshev gives 1/4.
  - Median: the Hoeffding bound e^{-R/8} holds, also for even R.
  - Final interval: (1-x/4)(1-x/16) >= e^{-x/2} and (1+x/4)e^{x/16} <= e^{x/2} on (0, ln 2] (checked numerically). The three failure events sum to delta.
- Certificates: Chernoff gives (e/8)^{eta R_k/2} <= (3K/delta)^{-4.32} <= delta/(3K).
- Coalescence drift: E|D_{t+1}| <= (1 - gamma/n)|D_t|. I also simulated this for non-CNF majority-of-3 events; the bound holds and is conservative.
- Cost: K <= Lambda, 1/rho <= Lambda, eta >= eps'/(16 Lambda^2).
- Staging count: K < 1 + 4mu^+ from s_i <= 2ln2 b_i^+. I re-derived the general Lambda <= 8mu^+ + 2 + 2 sum over big events of 1/(1 - b^+).
- b_i^+ analysis: KL(a||c) >= (a-c)^2/(2max) (checked on a grid), t < 4l/N_b <= 1/(48m), Chernoff with a = b/2 + 1/(32m), so b^+ <= 3b + 1/(8m), giving Lambda <= 24mu + 3.
- Implementation paragraph versus docstring:
  - The KL pooling is valid, because halted outputs are independent of the halting pattern.
  - a_k = th/(h - th) bounds both directions of r/r'.
  - The variance uses nmin.
  - Failure budget: delta/4 + delta/2.
  - kappa: |s_v - r_v| < 2^-52 on numpy's 53-bit grid.
  - The rounding of h, b, v, eps0 and the endpoints is handled.
- Citations: hn1998 (Statistica Neerlandica 52(3):360–380, anti-monotone CFTP) and pw1996 (RSA 9:223–252) are correctly attributed.
- The KLM sentence is now hedged.
- The abort-rule remark in p1-local is correct (truncated runs that halt coincide with the untruncated runs).

LENS B (scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/cftp_final/):
- Sampler exactness against exact D|F, by TV and chi-square (t2_sampler.py, t2b_chi.py). Cases: q in {0,1} sites, unit clauses, mixed signs, repeated literals, duplicate clauses, idle variables. The p-values are 0.43, 0.21 and 0.10, and no output lies outside F.
- Randomised coverage against brute-force p (t3_cover.py, 4 seeds):
  - 882 runs on random unate CNFs with n <= 10. The CNFs include repeated literals, 0/1 and extreme marginals, and p = 0 (108 runs).
  - Settings: N in {20, 60, 300}, T_max as low as 4n, delta in {0.2, 0.4}.
  - Result: 0 misses and 379 non-trivial verdicts.
- Truncation stress on a star (t6_star.py): theta_k up to 0.19, measured r and r'. With T_max = 32n: 150/150 verdicts and 0 misses. With T_max = 16n: correctly no verdict.
- Edge cases:
  - Empty CNF gives [1,1]; an empty clause gives [0,0]; N = 0 or 1 is sound.
  - Repeated literals: p = 0.375 is now inside [0.375, 0.432].
  - Variables with marginal < 2^-40 give no verdict.

Experiment-dependent claims: none in p1-cftp.tex. The cftp paragraph of sec-experiments.tex ('bias factor below e^{0.02}', 'thousands of updates', 'intervals contain the exact p') depends on the experiment numbers being regenerated, so I did not judge it.

## Audit of earlier findings

resolved: 10

- [resolved] (critical) code: stages with ratio < 1/2 while the bias and variance assumed r_k >= 1/2 (critical): telescoping_estimate now uses per-stage Harris guarantees h_k = harris_lower(stage)*e^{-2kappa}(1-2^-50). It requires th_k < h_k (otherwise no verdict), uses a_k = th/(h-th), and computes the variance term from (1-h+th)/((h-th)n_k). Rerun of the reproduction (10 unit clauses, q = 0.02): 0/20 misses at N=200 and 0/20 at N=2000; the runs give no verdict, with lo equal to the tight Harris bound. The regression tests test_unit_clauses_low_ratio_coverage and test_low_ratio_nontrivial_intervals pass.
- [resolved] (major) thm:cftp missing hypothesis b_i <= 1/2; b_i not computable for general unate circuits (major): The theorem now uses per-stage rho_k = prod(1 - b_i^+), Lambda = sum 1/rho_k with a Lambda_max cut-off, eta = eps' rho/(16K), and the bias and variance bounds in terms of rho_k. For non-CNF circuits, b_i^+ is the upper end of a KL interval at level delta/(3m) from N_b samples, with its failure probability charged to delta. I re-derived all of these steps and they are correct.
- [resolved] (major) code: a repeated variable in a clause gave the wrong D(B_c) (major): UnateSystem deduplicates literals (sorted set of (i,b)), and so does janson_interval. Rerun of the reproduction [(0,0),(0,0)],[(1,0),(1,0),(2,0)]: [0.37499999993, 0.432] contains p = 0.375. test_repeated_literals passes.
- [resolved] (minor) mu undefined; no link from K to mu (minor): mu = sum b_i is defined in sec:independence and mu^+ = sum b_i^+ in thm:cftp. K <= 4mu^+ + 1 is proved in the Cost paragraph, and I re-derived it.
- [resolved] (minor) delta bookkeeping, certification cost, output as interval, completeness margin (minor): Certificates now run at delta/(3K) with R_k = ceil(8 ln(3K/delta)/eta) runs. The costs are stated, and the output is the interval [M e^{-eps'/2}, min(1, M e^{eps'/2})]. Completeness is shown under theta_k <= eta/16, using the (e/8)^{eta R_k/2} Chernoff bound.
- [resolved] (minor) code: p = 0 gave a positive lower end (minor): The 'sure' check (decided on D.q exactly) returns [0,0], and a zero ratio in the median repetition gives no verdict. Rerun: [(0,1)] with q0 = 0 gives [0,0], and an empty clause gives [0,0].
- [resolved] (minor) docstring constant 1/N, lower-end justification, code differs from the paper's procedure (minor): The module docstring no longer states a wrong variance constant. The function docstring now gives r_k/r'_k >= 1/(1+theta/r) >= e^{-a_k}. The paper's implementation paragraph (p1-cftp.tex lines 152-162) describes the pooled KL bound, the requirement theta^+ < rho_k, the bias factors e^{+-a_k} and the realised n_k.
- [resolved] (minor) Las Vegas termination and hypotheses (D(F)>0, increasing events) implicit (minor): Lines 23-41 now state that the events are increasing (after flipping) and that D(F) > 0. The text gives the HN site-wise anti-monotonicity and an almost-sure-termination window argument, which I checked and found correct.
- [resolved] (minor) unate definition ignores XOR and negative threshold weights (minor): p1-indep.tex now defines unateness by top-down polarity propagation: XOR passes both polarities, a negative weight counts as a negation, and any other gate disqualifies the circuit. The induction gives increasing B_i.
- [resolved] (minor) KLM extension to ORs stated without proof (minor): It is now phrased as 'should extend ... we have not worked out that error budget', with the needed ingredients listed.

## New findings

### 1. [minor] paper/p1-cftp.tex, thm:cftp step (4) (lines 61-63, 'run A_k until N runs have halted'), used by thm:meta's proof in p1-tail.tex line 71 ('thm:cftp draws poly(...) samples and runs')

**Problem.** Step (4) has no worst-case bound on the number of runs. The theorem states the cost only 'in expectation' and only 'if all theta_k <= eta'. But thm:meta asserts that the meta-procedure 'runs in polynomial time'. With an uncapped loop that holds only in expectation or with high probability, not deterministically as def:sound's 'efficient' and thm:meta claim. The code is not affected: it runs exactly N runs and uses the realised n_k.

**Proposed fix.** Cap step (4): in each round and stage, run 2N runs and keep the first N halted outputs. If fewer than N halt, output [0,1]. The kept outputs are still i.i.d. from pi', so the soundness proof is unchanged. Under theta_k <= eta/16 <= 1/16, Hoeffding gives Pr[fewer than N of 2N halt] <= e^{-0.76N}. Add this term to the delta/3 completeness bound, and state the cost as at most 2RKN runs.

### 2. [minor] code/rareprob/cftp.py line 38 (UnateSystem.__init__: assert is_unate(clauses)); the same pattern at code/rareprob/janson.py line 71

**Problem.** Unateness, on which the Harris bound and the anti-monotone sampler depend, is checked only by an assert, and asserts are removed under 'python -O'. Then a non-unate CNF is accepted silently: bad[i] takes the last sign seen, and the returned interval can exclude p. Reproduction (t5_O.py): (x0) AND (NOT x0 OR x1) with q = (1/2, 1/2) has p = 1/4. Under python -O the call returns [0.473, 0.525] with 'Harris bound 0.375' > p. With asserts on it raises AssertionError. The input is outside the documented contract ('for every unate CNF'), and meta.py checks is_unate before calling janson_interval. Still, it is a soundness hole reachable on an input. The authors already removed this pattern from stats.sequential_mean for the same reason.

**Proposed fix.** Replace the assert with an explicit check: 'if not is_unate(clauses): raise ValueError("telescoping needs a unate CNF")'. Alternatively, return Estimate(0, 0, 1, ...) with a 'no verdict' note. Do the same in janson_interval.

### 3. [minor] code/rareprob/cftp.py, cftp_samples lines 122-153 (T0 = 4*n; 'if idx.size == 0 or T > T_max: break'; coalescence tested on all n columns; sites/us arrays kept for all B runs)

**Problem.** This affects completeness and efficiency only, not soundness. (a) If 4n > T_max, the loop exits before any update, so every run 'fails' and the result is always 'no coalescence: no verdict'. This happens for n > 8192 at the default T_max = 2^15, whatever the clauses. For example, 9000 variables with the single clause (x0 OR x1) gives no verdict (t8_bign.py), and so does T_max = 2^17 with N = 10. (b) The chain updates all n sites and tests L = U on all of them, including variables in no clause. Coalescence therefore costs a coupon collector over every variable of D, not only the relevant ones. (c) The randomness arrays have shape (B, 2T) for every run, including runs that have already halted, and grow up to 2*T_max columns. On a non-coalescing 200-variable instance with B = 200, peak RSS was 547 MB (t9_mem.py). The arrays scale linearly in B, so the default N = 2000 needs several GB.

**Proposed fix.** Run the chain only on the variables that occur in some clause, since the others never affect an event or the stage test. Set T0 = min(4n', T_max) with n' the number of such variables, so at least one horizon is always tried. Store the randomness only for the runs still undone (index by idx), or regenerate it from per-run seeds, instead of concatenating (B, T) blocks for all B runs.

### 4. [minor] code/rareprob/cftp.py, _reps_for lines 157-164

**Problem.** The binomial tail multiplies the exact integer math.comb(R, j) by a float. For delta around 1e-70 or below, R exceeds about 1000, the conversion overflows, and telescoping_estimate crashes with OverflowError (t4_edge.py: delta = 1e-80 crashes, delta = 1e-60 gives R = 939). This is a crash, not an unsound interval.

**Proposed fix.** Compute the terms in log space, for example exp(lgamma(R+1) - lgamma(j+1) - lgamma(R-j+1) + j ln(fail) + (R-j) ln(1-fail)). Alternatively, for small delta fall back to the Hoeffding count R = 2*ceil(8 ln(1/delta)) + 1, which gives Pr[Bin(R, 1/4) >= R/2] <= e^{-R/8} <= delta.

### 5. [minor] paper/p1-cftp.tex, thm:cftp statement (lines 43-48, 51-57, 67)

**Problem.** These are scoping and edge-case gaps in the statement, and none is a mathematical error. (a) The procedure is claimed sound only 'for every unate circuit', but def:sound requires soundness on every circuit. Unlike thm:janson-general, the procedure has no step for non-unate input. (b) With m = 0 (C a constant-true, empty AND), K = 0, so rho = min over an empty set and eta = eps' rho/(16K) are undefined. (c) T, and the horizon schedule ('horizons doubling up to T'), are used but never declared as inputs. The coalescence bound theta_k <= n e^{-gamma T/n} and the cost of 2T updates both need the last horizon to equal T, which an arbitrary starting horizon does not guarantee.

**Proposed fix.** Add step (0): 'if C is not unate (the syntactic check of sec:independence), output [0,1]; if m = 0, output [1,1]'. List T among the inputs ('a truncation time T'), and fix the horizons as T 2^{-j}, j = J, ..., 0, for some starting index J, so that the final horizon is T.

