# Fix round: cftp

## Fixer's summary

Fixed every cftp finding from 'referee:cftp:proof'. The key 'referee:cftp:counterexample' does not exist in batch23.json; its keys are dfsb, ctx-modules, independence, cftp:proof, pcis, separations and code-soundness:code. The cftp/janson duplicate-literal item under code-soundness:code is the same bug as the cftp major finding and is fixed too.

Code (/home/user/AI-works/circuit-output-fraction/code/rareprob/cftp.py):
- Every stage now uses its own Harris guarantee h_k = prod_{c in stage}(1 - D(B_c)), rounded down, in place of the constant 1/2.
- If th_k >= h_k there is no verdict. The bias is sum_k th_k/(h_k - th_k), and the relative variance is prod_k(1 + (1 - h_k + th_k)/((h_k - th_k) n_k)) - 1, using the smallest halted count per stage.
- The docstring now gives the exact guarantee in three parts: truncation, bias (both ends), and the Chebyshev/median step conditional on the halted counts.
- Reproduced the referee case before the fix: 10 unit clauses, q = 0.02, delta = 0.05. The old code had hi < p in 16/20 runs at N=200 and 6/20 at N=2000, and lo > p in 20/20 runs.
- That second failure is new: the old Harris clamp, computed in floating point, exceeded the exact p by about 1e-14 relative. The Harris bounds are now rounded outwards.
- After the fix: 0/20 misses at N=200 and N=2000 (the upper end is 1 there because each stage ratio is only 0.02), and 0/10 at N=20000 with median hi/lo 1.49.
- On 4 unit clauses with q = 0.05 and N=4000: old 40/40 misses, new 0/40 with median hi/lo 1.38.
- Other code fixes: [0,0] is returned exactly when a clause is false with probability 1, decided on D.q itself. A zero ratio in the median repetition, or an upper end below the Harris bound, now gives no verdict. A bound kappa covers the gap between D and the law the floating-point sampler actually draws from: marginals within 2^-40 of 0 or 1 give no verdict.

Repeated literals:
- UnateSystem and janson_interval now remove repeated literals within a clause.
- Referee example (x0 v x0)&(x1 v x1 v x2), q = 0.5, p = 0.375: old cftp gave the empty interval [0.656, 0.419] and old Janson gave [0.65625, 0.65625]. Now cftp gives [0.375, 0.416] and Janson gives [0.375, 0.375].

Paper (/home/user/AI-works/circuit-output-fraction/paper/p1-cftp.tex):
- The sampler paragraph now states its hypotheses: increasing events, D(F) > 0 (from Harris when all b_i < 1), and the site-wise anti-monotonicity of Häggström and Nelander. It also proves that the sampler halts almost surely.
- Theorem thm:cftp is restated as a full procedure with a complete proof:
  - b_i^+ = b_i for CNFs; for general circuits, Hoeffding-KL upper confidence bounds at level delta/(3m).
  - Greedy stages with guarantees rho_k; eta = eps' rho/(16K); certificates at delta/(3K); R = ceil(8 ln(3/delta)) rounds; N = ceil(256 Lambda/eps'^2) with Lambda = sum_k 1/rho_k.
  - Output [M e^{-eps'/2}, min(1, M e^{eps'/2})], so U <= (1+eps)L.
  - Completeness when every theta_k <= eta/16, which holds for gamma > 0 and T >= (n/gamma) ln(16n/eta).
  - Explicit cost; if max b_i^+ <= 1/2 it is O(K^2 log(K/delta)/eps + K(mu^+ + 1) log(1/delta)/eps^2) runs, with K <= 4mu^+ + 1 and Lambda <= 2K. A Lambda bound for the general case is in the proof.
- Added one sentence on how the implementation's certificate differs (it pools runs into a KL bound and widens the interval).
- The Karp-Luby-Madras claim is downgraded to a stated expectation, with the ingredients it would need.
- Checked numerically: the eps' inequalities, the Chernoff completeness bound, and the K and Lambda staging bounds (200k random cases).
- The paper builds in a scratch copy with no warnings in this section.

Experiment: I reran only L=20 of exp_cftp.py with the new code and the same seed. It draws the same samples (value 0.023216, 234000 runs) and certifies [0.02056, 0.02662], which contains p = 0.023116. The published interval was [0.01984, 0.02792]; eps0 drops from 0.165 to 0.124 and the bias from 0.0046 to 0.0042.

So the published numbers would change: the cftp intervals get tighter, while janson_lo/janson_hi, the CFTP run counts and the point values stay the same. The published intervals are still valid, because every stage guarantee on the ladders is at least 0.517 >= 1/2, so the old assumption held there. Regenerating is optional.

## Findings resolved

- critical: cftp.py stages()/telescoping_estimate assume r_k >= 1/2 (bias th/(0.5-th), variance 1.5/N); invalid intervals on unit clauses with q=0.02: Per-stage Harris guarantee h_k (rounded down) replaces 1/2: no verdict if th_k >= h_k, bias a_k = th_k/(h_k-th_k), variance prod_k(1+(1-h_k+th_k)/((h_k-th_k) nmin_k)) - 1, eps0 = 2 sqrt(v). The argument is re-derived in the docstring. Reproduced and fixed: 10 unit clauses q=0.02 went from 16/20 misses (N=200) and 6/20 (N=2000) to 0/20, 0/20, and 0/10 at N=20000; 4 unit clauses q=0.05, N=4000 went from 40/40 to 0/40. Regression tests are in tests/test_fix_cftp.py.
- major: thm:cftp missing hypothesis max b_i <= 1/2; b_i not computable for general unate circuits: Restated thm:cftp in general form with per-stage guarantees rho_k = prod(1-b_i^+), eta = eps' rho/(16K), relative variance (1-rho_k+eta)/((rho_k-eta)N) <= 2/(rho_k N), and N = ceil(256 Lambda/eps'^2). For general circuits b_i^+ is a Hoeffding-KL upper bound at level delta/(3m), charged delta/3. The full proof covers soundness, certificates, coalescence and cost.
- major: UnateSystem (and janson_interval) multiply a repeated variable's marginal twice; referee example gives an empty interval: Reproduced: old cftp [0.656, 0.419], old Janson [0.65625, 0.65625] with p = 0.375. Repeated literals are now removed within each clause in UnateSystem.__init__ and at the start of janson_interval; the algorithm is otherwise unchanged. New results: cftp [0.375, 0.416], Janson [0.375, 0.375]. Covered by a regression test.
- minor: mu undefined; K not linked to mu: mu = sum b_i is defined at the top of sec:independence; the theorem defines mu^+ = sum b_i^+. The proof shows K <= 4mu^+ + 1 and Lambda <= 2K when max b_i^+ <= 1/2, and Lambda <= 8mu^+ + 2 + 2 sum_{b_i^+ > 1/2} (1-b_i^+)^{-1} in general. Checked numerically on 200k random cases.
- minor: delta bookkeeping, certification cost, output not phrased as a sound interval, completeness threshold: Certificates run at delta/(3K) with R_k = ceil(8 ln(3K/delta)/eta) runs. Total cost is stated as K R_k + RKN/(1-eta) runs of at most 2T updates each, which is O(K^2 log(K/delta)/eps + K(mu^+ + 1) log(1/delta)/eps^2). The output is the interval [M e^{-eps'/2}, min(1, M e^{eps'/2})] or [0,1]. Completeness needs theta_k <= eta/16, giving the (e/8)^{4 ln(3K/delta)} bound, which holds for T >= (n/gamma) ln(16n/eta).
- minor: lo > 0 when p = 0 (r_hat = 0 floored at 1e-300): If a clause is false with probability 1, decided exactly on D.q, the code returns [0,0]. Zero ratios are kept as -inf; if the median repetition contains one, there is no verdict. The old code returned lo = 5e-301 on the referee input; the regression test now passes.
- minor: docstrings (constant 1/N vs 1.5/N, lower-end justification), code differs from the paper procedure: Module and function docstrings rewritten. The lower end now uses the r_k/r'_k >= 1/(1+theta_k/r_k) >= e^{-a_k} argument. Added a paragraph to sec:cftp saying the implementation pools runs into a KL bound theta_k^+, widens by e^{+-a_k} and Chebyshev, takes N rather than eps, and that the same argument applies.
- minor: Las Vegas claim leaves hypotheses implicit; almost-sure termination not argued: The paragraph before thm:cftp now states increasing events, F a down-set with D(F) > 0 (Harris when all b_i < 1), HN site-wise anti-monotonicity, and the local check phi_v. It adds the termination argument: in a window, sites with q_v < 1 get u >= q_v, then W = {q_v = 1} is updated, ending at L = U = 1_W, which lies in F.
- minor: syntactic unate definition fails for XOR/negative-weight threshold gates: Already fixed in p1-indep.tex by commit 8144315d (polarities are propagated: an XOR passes both polarities and a negative weight counts as a negation). thm:cftp refers to that definition and to the flipped, increasing events, so no further change was needed.
- minor: KLM extension stated as a consequence without proof: Downgraded to a stated expectation ('should extend'), naming the ingredients: per-disjunct estimates from thm:cftp and certified conditional samplers at truncation O(eps/t). Says the error budget has not been worked out.
- additional (found while checking): floating-point Harris clamp exceeded p (lo > p in 20/20 old runs on unit clauses); sampler law differs from D for marginals near 0/1: The Harris bound is rounded outwards (pb_hi and log-sum slack as in janson.py). kappa bounds the gap between D and the law the sampler draws from; the stage guarantees are scaled by e^{-2 kappa} and the interval widened by e^{+-kappa}. Marginals within 2^-40 of 0 or 1 give no verdict, and a test covers this.

## Not changed, with reasons

- referee:cftp:counterexample (all findings): This key does not exist in batch23.json, so there was nothing to address. The cftp/janson duplicate-literal finding under referee:code-soundness:code is fixed by the repeated-literal change.

## Independent re-review

**Verdict.** All the cftp findings are now correctly resolved, apart from minor issues listed below. I re-derived the revised thm:cftp (p1-cftp.tex) line by line and found no error. Checked: Harris staging r_k >= rho_k; the bias factors (1 -+ eta/rho)^K; the per-stage relative variance <= 2/(rho_k N) and the bound e^{2 Lambda/N}; Chebyshev and Hoeffding for the median; the e^{-+eps'/2} inequalities for eps' <= ln 2; the delta/3 + delta/3 + delta/3 budget; the completeness Chernoff bound (e/8)^{4 ln(3K/delta)} <= delta/(3K); the coalescence contraction 1 - gamma/n with d_max(k_max - 1); the almost-sure termination argument; K <= 4mu^+ + 1, Lambda <= 2K, and the general Lambda bound (100k random b-vectors, all hold). The new cftp.py guarantee is also sound: per-stage h_k, a_k = th/(h - th), the variance product, the KL union bound at delta/4 plus the median at delta/2, and the kappa correction for the floating-point sampler law. Empirical checks: (1) 12,217 stages on random small unate CNFs, with repeated literals and extreme marginals: h_k <= exact r_k every time (min r/h = 1.00000000004). (2) 20,000 disjoint-clause instances in rational arithmetic: Harris and Janson bounds never exceed p. (3) The referee cases: 10 unit clauses with q = 0.02 give 0/40 misses at N = 200 and 2000, though there the interval is [Harris, 1]. 4 unit clauses with q = 0.05 at N = 4000 give 0/20 misses with median hi/lo 1.37. The repeated-literal example now gives [0.375, 0.399], and Janson [0.375, 0.375]. p = 0 and an empty clause give [0,0]. (4) Random-CNF stress runs at delta = 0.5 to 0.9, with N from 30 to 1000 and T_max from 64 to 4096: miss rates of 0% to 2%, far below delta. The full test suite passes (185 tests). The key 'referee:cftp:counterexample' does not exist in batch23.json; the fixer is right about that. The remaining problems are all minor: thm:meta's polynomial-time claim needs a cut-off for the now-general thm:cftp; empty input crashes; the Harris clamp is not rounded outwards in the subnormal range; the symbol S is used both for stages and for supports; and the experiments text and table are stale.

- [resolved] critical: cftp.py stages()/telescoping_estimate assume r_k >= 1/2 (bias th/(0.5-th), variance 1.5/N), giving invalid intervals on unit clauses with q=0.02: Each stage now has its own guarantee h_k = harris_lower(stage)*e^{-2kappa}, rounded outwards. There is no verdict if th_k >= h_k. The bias is a_k = th_k/(h_k - th_k) and the variance is prod(1 + (1-h+th)/((h-th) n_min)) - 1. I re-derived the docstring argument (conditioning on the halted counts is valid; failure budget delta/4 + delta/2). Checks: h_k <= exact r_k on 12,217 random stages; 0/40 misses on the referee's unit-clause case; 0/20 on 4 unit clauses with q=0.05 at N=4000; random-CNF stress runs well below delta.
- [resolved] major: thm:cftp missing hypothesis max b_i <= 1/2; b_i not computable for general unate circuits: The theorem is now stated in general form, with b_i^+ (exact for CNFs, Hoeffding-KL at delta/(3m) otherwise) and stage guarantees rho_k, eta = eps' rho/(16K), N = ceil(256 Lambda/eps'^2). I checked every step of the proof and it is correct. Minor residue: for non-CNF circuits the sample size for b_i^+ is not specified, and its cost is left out of the cost statement (see the new findings).
- [resolved] major: UnateSystem (and janson_interval) multiply a repeated variable's marginal twice: Both now deduplicate literals within each clause after is_unate. Referee example: cftp [0.375, 0.399], Janson [0.375, 0.375], with p = 0.375. Janson results on clauses with distinct literals are unchanged (test plus my 20k rational-arithmetic checks).
- [resolved] minor: mu undefined; K not linked to mu: mu = sum b_i is defined at the top of sec:independence, and mu^+ in the theorem. The proof of K <= 4mu^+ + 1 (via s_i <= 2 ln2 b_i^+ and the closing condition) is correct. The general bound Lambda <= 8mu^+ + 2 + 2 sum_{b^+ > 1/2} (1-b^+)^{-1} is also correct. Checked numerically on 100k random sequences.
- [resolved] minor: delta bookkeeping, certification cost, output not phrased as a sound interval, completeness threshold: Certificates run at delta/(3K) with R_k = ceil(8 ln(3K/delta)/eta). The cost K R_k + RKN/(1-eta) is stated. The output is [M e^{-eps'/2}, min(1, M e^{eps'/2})] or [0,1]. Completeness holds when theta_k <= eta/16, which follows from T >= (n/gamma) ln(16n/eta). All verified.
- [resolved] minor: lo > 0 when p = 0 (r_hat = 0 floored at 1e-300): A clause that is false with probability 1, decided exactly on D.q, now returns [0,0]; an empty clause also returns [0,0]. A median repetition containing a zero ratio gives no verdict. Verified.
- [resolved] minor: docstrings (1/N vs 1.5/N, lower-end justification); code differs from the paper procedure: The docstrings are rewritten with a correct three-part guarantee, including the lower-end argument r_k/r'_k >= 1/(1 + theta/r) >= e^{-a_k}. The sec:cftp paragraph accurately describes how the implementation's bookkeeping differs.
- [resolved] minor: Las Vegas claim leaves hypotheses implicit; almost-sure termination not argued: The text now states the increasing events, the down-set F with D(F) > 0, HN site-wise anti-monotonicity, and phi_v. The termination argument (q_v < 1 sites set to 0, then W-sites set to 1, with 1_W in F) is correct.
- [resolved] minor: syntactic unate definition fails for XOR / negative-weight threshold gates: p1-indep.tex now propagates polarities: XOR passes both polarities, and a negative weight flips the polarity. thm:cftp relies on that definition. Correct.
- [resolved] minor: KLM extension stated as a consequence without proof: Downgraded to 'should extend', with the needed ingredients named and a statement that the error budget has not been worked out.
- [finding was wrong] referee:cftp:counterexample (key absent from batch23.json): I confirmed that batch23.json has no such key; the fixer is right. The related cftp/janson repeated-literal item under referee:code-soundness:code is fixed by the deduplication (see above).

### New findings of the re-review

### 1. [minor] paper/p1-tail.tex thm:meta ('Fix the polynomial parameters ... a truncation time |C|^gamma for coupling from the past ... runs in polynomial time'), interacting with the revised thm:cftp in paper/p1-cftp.tex

**Problem.** The revised thm:cftp now allows events with b_i^+ > 1/2. Its run count is K ceil(8 ln(3K/delta)/eta) + RKN with eta = eps' rho/(16K) and N = ceil(256 Lambda/eps'^2), and both scale with 1/rho and Lambda >= 1/(1 - b_i^+). These grow without bound: for example, a CNF with a unit clause whose b = 1 - 2^{-n} has N >= 256*2^n/eps'^2. Separately, for non-CNF circuits the sample size behind each b_i^+ is unspecified and not counted. thm:meta fixes only a truncation time for CFTP and asserts that every module runs in polynomial time, so as now written that claim is false for the CFTP module. The CFTP completeness class quoted in p1-tail ('fast coalescence') also omits the condition that Lambda is polynomial.

**Proposed fix.** In thm:cftp, add a decline rule: output [0,1] if Lambda (or 1/rho) exceeds a given polynomial bound. Fix the b_i^+ sample size, for example s = O(log(m/delta)/beta) samples, so that b_i^+ <= 2 b_i + beta, and add that cost. List the Lambda cut-off among thm:meta's parameters. State the CFTP class as gamma > 0 together with max_i b_i <= 1/2, or more generally Lambda <= poly.

### 2. [minor] code/rareprob/cftp.py telescoping_estimate, line 263 (note string uses float(h.min()))

**Problem.** This is a regression introduced by the revision. On a CNF with no clauses (p = 1), K = 0 and h is an empty array, so h.min() raises 'ValueError: zero-size array to reduction operation minimum'. The old code returned an interval here. The input is valid and the docstring claims a guarantee 'for every unate CNF'.

**Proposed fix.** Return [1,1] (or the computed interval) when there are no clauses, or write f"{float(h.min()) if K else 1.0:.3g}" in the note.

### 3. [minor] code/rareprob/cftp.py UnateSystem.harris_lower (line 88) and the clamp lo = max(lo, harris) (line 258); the same pattern in janson.py janson_interval line 90 (and the statistical lo at cftp.py line 253)

**Problem.** The fixer reports the Harris bounds as 'rounded outwards', but they are not in the subnormal range. There the spacing of exp(s), 2^-1074, exceeds the relative slack 2^-36(m+2), so exp(s)*(1 - slack) can round up past the true product. Reproduction: 1061 unit clauses (x_i), q = [0.5]*1060 + [0.8*2^-10]. Then p = prod q = 12.8 * 2^-1074 exactly (disjoint clauses, so Harris is tight), but harris_lower(all) = 13 * 2^-1074 > p, and janson_interval returns lo = 13 * 2^-1074 > p, a deterministic miss. In telescoping_estimate the clamp would make every verdict on this instance miss p. That instance is too large to run in pure Python, but nothing in the code prevents it. This only arises for p below about 1e-310, so it is contrived.

**Proposed fix.** Below the normal range, flush to zero or step down. For example, in harris_lower, janson_interval and the statistical lo use x = math.exp(s)*(1 - slack); return max(0.0, x - 2*math.ulp(0.0)), or return 0.0 if x < 2^-1000. Symmetrically, add 2*math.ulp(0.0) to the upper ends computed with exp.

### 4. [minor] paper/p1-cftp.tex thm:cftp and its proof (stages 'S_1,...,S_K', rho_k = prod_{i in S_k}, F_{S_k}, 'first event j of S_{k+1}') versus supports S_i ('samples of x_{S_i}', 'k_max = max_i |S_i|', 'v in S_i' in the sampler paragraph, and sec:independence)

**Problem.** The revision names the stages S_k, but S_i already denotes the support of event i (defined in sec:independence and used in the same theorem). As a result, S_1, |S_i| and 'i in S_k' are ambiguous, since S_1 could mean the support of event 1 or the first stage.

**Proposed fix.** Rename the stages, for example to I_1,...,I_K (rho_k = prod_{i in I_k}, F_{I_k}, F_{<k} = F_{I_1 cup ... cup I_{k-1}}), and keep S_i for supports.

### 5. [minor] paper/sec-experiments.tex paragraph 'Certified telescoping (tab:cftp)' and paper/tables/cftp.tex, experiments/results/cftp.json

**Problem.** These files were outside the revised set, but they are now stale or false in light of it. (a) 'the truncation certificates contribute a bias below 1%' is false: the L=60 run's note gives bias 0.015, a factor e^{0.015} (about 1.5%). (b) The table was produced by the old interval arithmetic, so the current implementation, which the revised sec:cftp paragraph describes, does not reproduce it. I reran L=20 with seed 4 and got [0.020565, 0.026620] (eps0 0.124, bias 0.0042) against the published [0.019845, 0.027916]. The published intervals are still valid, because every stage guarantee on the ladders is 0.5168 >= 1/2, but they are not reproducible from the code.

**Proposed fix.** Change the sentence to 'a bias factor below e^{0.02}' (or quote the per-L values), then regenerate with exp_cftp.py and make_tables.py, or add a note that the table predates the per-stage bookkeeping.

