# Round 2: consolidation

## core

I fixed the dfsb re-review's MAJOR deterministic miss with a proved error bound, plus a second deterministic miss in ve.py that I found myself. I resolved the remaining dfsb items in p1-dfsb.tex and p1-tail.tex, added the local-threshold (TG) and affine modules to meta_estimate, and updated thm:meta, including the CFTP cut-off. The full suite passes (245 tests).

Code:
- ve.py: new `ve_bounds` stores each table entry as a mantissa in [1/2,1) with an integer exponent. Nothing can underflow, and an exact zero is reported separately. It counts roundings per factor and returns p = mant·2^exp·(1±γ_r), where γ_r is proved from IEEE round-to-nearest. `exact_ve` keeps its float return value for compatibility.
- ve.py, newly found bug: the THR gate table used Python's sum(), which is compensated in Python ≥3.12. The circuit evaluator adds left to right, so the two differ. Example: THR([1e16,1,−1e16],0.5) under the uniform distribution has true p = 3/8, but old VE returned 0.5 ± 1e-9, a certain miss. VE now uses the evaluator's summation order.
- meta.py: the 2^-1000 branch is gone; VE's certified interval is returned at once. as_cnf now merges repeated literals and duplicate clauses and drops tautologies. A Janson lower end below the normal float range is flushed to 0.
- meta.py, new modules: the affine presolve (DFSB on the reduced circuit when all pivots are uniform), the affine-union envelope, and TG. Each is gated on applicability before any sampling and runs at δ/(3M). The two affine modules run only when they explain at least one bit; the affine checks also return p = 0 when they certify it.
- dfsb.py and envelope.py: each box fill of an (E)-leaf's rejection sampler is now truncated after T_f = ⌈16K ln(8N_f/δ)⌉ draws, where N_f bounds the number of fills; a truncated leaf outputs [0,1]. Phase-1 pilots are truncated the same way, which only makes the (E) test fail.
- envelope.py: box-mass draws are chunked, and `_exp_up`/`_exp_down` are safe below the normal float range.
- compile.py: a rule-application budget B. Past it, a node gets the constant-1 envelope, so the compiler's work is polynomial.

Paper:
- thm:dfsb cost statement: NNF size |N| = O(2^a|C|) replaces |C|, and the preprocessing that tabulates small cones (O(2^a|C|²)), the density pilots that find dense nodes (s_7·B evaluations per (E) test) and B are counted. The unexplained '+|Φ_h|' term is dropped.
- thm:dfsb proof: the completeness budget is re-split as δ/8+δ/4+δ/2+δ/8+δ = 2δ, with the truncation term proved.
- Rule (R8) now says its invariance holds for fixed a, K and m. The absolute constant in the sample cap is renamed c_0.
- cor:dfsb: (a) and (b) state their costs with the pilot and log log K terms; (c) requires a node budget at least the tree size.
- The implementation's choices are stated where the procedures are described: a = 12, s_7 = 512, τ = 0.05, B = 2·10^5, a greedy min-degree order with w ≤ 18, and which modules meta_estimate runs.
- p1-tail.tex: the Local thresholds and Affine/quadratic module items and the algebraic-rarity limits item are added (edits 40, 59, 60, with corrected claims). thm:meta lists B, T, Λ_max and the module caps, and its proof bounds CFTP's work via Λ_max (aligned with the concurrent p1-cftp edit).
- The scratch LaTeX build has no errors and nothing undefined or overfull from my files, apart from the gjl2019 citation.

Tests:
- Run: VE against exact rationals on random circuits with extreme marginals; the 2^-1000 boundary; p = 0.3^1100; the threshold summation case; canonical CNFs; meta running presolve and TG; a 40-instance meta soundness loop; per-fill truncation, including a monkeypatched one-draw cap that still gives valid intervals.
- Run: compiler budget domination, chunked box draws, and subnormal exponentials.
- Stress checks: meta 0 misses in 720 runs with VE off; DFSB 0 misses in 300 runs, none on exact paths.

- dfsb NF (major): meta.py VE underflow branch misses p just above 2^-1000: Removed the branch. ve.py: new ve_bounds keeps each table entry as a mantissa in [1/2,1) with an int64 exponent (exact frexp/ldexp), counts roundings per factor, and returns p = mant*2^exp*(1+θ) with |θ| ≤ γ_r (Higham 3.1/3.3), plus an exact-zero flag. meta returns VE's outward-rounded interval at once, with log2 bounds in the note. Regression test test_ve_boundary_two_to_minus_1000 covers q=1/2, p = 2^-1000(1+2^-52) and the referee's 0.5±1e-13 noise, and checks the certificate against exact rationals.
- code-soundness (ve.py): return log p or bounds so tiny p never collapses to 0; keep exact zero separate: VEResult carries mant/exp/rel, log2_bounds() and interval(): the lower end flushes to 0 below the normal range, the upper end stays positive. zero=True only when no positive term exists. Tests: p = 0.3^1100 (certificate contains the exact Fraction; meta gives [0, hi>0]); the zero case; subnormal and 1e-200 marginals.
- New bug found in ve.py: THR gate tables used Python's compensated sum(), not the evaluator's left-to-right sum: Added thr_sum, the evaluator's own order and comparison with t-1e-12. Old VE gave 0.5±1e-9 for THR([1e16,1,-1e16],0.5) where the true p is 3/8. Regression test test_ve_threshold_uses_evaluator_sum.
- code-soundness: meta.as_cnf must canonicalise clauses before Harris/Janson/CFTP: as_cnf merges repeated literals (including two distinct NOT(x) gates), drops tautologies, removes duplicate clauses, and keeps an empty clause. Tests: test_as_cnf_canonicalises_clauses and the referee's (x0∨x0)∧(x1∨x1∨x2) example. meta also flushes a Janson lower end below 2*TINY to 0 and widens a subnormal upper end, covering the cftp re-review's subnormal Harris issue on the meta path.
- dfsb NF (minor): truncation on the good event not budgeted; truncation length unspecified: Paper: each box fill is truncated after T_f=⌈16K ln(8N_f/δ)⌉ draws, N_f = Σ L·cap. The proof bounds truncation on the good event (box masses ≥ 1/(16K)) by δ/8 and re-splits the completeness budget as δ/8+δ/4+δ/2+δ/8+δ = 2δ, using 3m(δ/2m)^6 ≤ δ/8 for the pilots. It also notes that failed or truncated (E) tests do not affect the pruning argument. Code: envelope._rejection_fill(fill_cap) truncates per fill; DFSB.estimate computes N_f and T_f for Phase 2; Phase-1 pilots use a cap too. Measured: 0 truncations in 42 real Phase-2 box leaves.
- dfsb NF (minor): thm:dfsb cost accounting ((R8) tabulation, (R7) pilots, NNF size vs |C|, '+|Φ_h|'): The theorem now counts evaluations of nodes of the canonicalised NNF N, with |N| = O(2^a|C|) for {∧,∨,¬,⊕}-circuits. It adds s_7·B (R7) pilot evaluations per (E)-test and O(2^a|C|^2) for (R8), and gives the remaining work as O(m(n+2^a+B)|N| + n^2(|C|+|N|) + n^3). The unexplained +|Φ_h| term is dropped. N, B, s_7 and τ are defined in the text, and the proof gives each cost. compile.py gained the rule budget (call_budget) that makes B real.
- dfsb NF (minor): (R8) invariance needs fixed a; symbol c overloaded: (R8) now says the invariance holds 'as long as a, K and m stay fixed (they depend on |C|, which such a rewrite can change)'. The cap constant is renamed c_0. The local-lemma bullet uses c' (an absolute constant) instead of c.
- dfsb NF (minor): cor:dfsb (b) cost and (c) budget: (b): for an atom C|_F there are no samples; otherwise O(Kε^{-2}(log(1/δ)+log log K)+K log(m/δ)) evaluations. (c): exactness and no sampling now require a node budget at least the size of the tree. (a): the example cost is corrected to no samples for atom blocks and Õ(K t^3 ε^{-2} log(m/δ)) otherwise.
- dfsb NF (minor): code-vs-paper simplifications (greedy VE order, ve_width 18, fixed atom size 12): Stated in the paper: p1-dfsb fixes a=12 and gives s_7=512, τ=0.05, B=2·10^5 and three Shannon expansions per path. The p1-tail treewidth bullet notes the greedy min-degree order with w ≤ 18 and the certified floating point. A paragraph after thm:meta lists the modules meta.py runs and those it omits. The dfsb.py docstring says the same.
- cftp NF: thm:meta needs a Λ/1/ρ cut-off; CFTP class omits Λ ≤ poly: thm:meta now lists T=|C|^c and Λ_max=|C|^c, aligned with the Λ_max that the concurrent p1-cftp.tex edit added. The proof bounds CFTP's work by poly(|C|,Λ_max,1/ε,log(1/δ)). The module bullet states completeness as Λ ≤ Λ_max (e.g. max b_i^+ ≤ 1/2 gives Λ ≤ 8μ^++2) plus γ > 0 with T ≥ (n/γ)ln(16n/η).
- external edit 40 (p1-tail Local thresholds item): Added, with a decline condition dk > c log|C|.
- external edit 59 (p1-tail Affine and quadratic structure item): Replaced the Algebraic item. Corrected the claim about one linear threshold: prop:affine-ltf gives an FPTAS and an exact sampler, not an exact count. Added a width cut-off.
- external edit 60 (p1-tail limits: algebraic rarity): Added, with the hypotheses of cor:barrier-methods (events filling a 1/poly(n) fraction of the solution set of m ≤ n/6 checks) and the exact statement of thm:biased-hard (no sound procedure complete within 2^{N^{1-γ}} unless NP⊆BPP; no argument system within a factor 2 unless coNP⊆MA). Changed 'Two natural kinds' to 'Three'.
- external edits 50 and 68 (TG, presolve and affine envelope in meta_estimate): Implemented. Applicability is decided before any sampling and M counts all applicable methods (δ/(3M) each). TG runs when ltc_from_circuit recognises C and the block-threshold form does not; it declines on ValueError or AssertionError, and its log-domain interval is converted with outward rounding. The presolve runs when rank > 0 and M ≤ 1/2, with inner DFSB when all pivots are uniform. The affine envelope runs when its mass is ≤ 1/2. A deductive p = 0 from an inconsistent spine or an empty envelope returns [0,0]. Each module is skipped once some interval is tight.
- external edit 6 (envelope.py chunked box draws): estimate_boxes now draws in batches of 2^15. The sample stream is unchanged. Test test_estimate_boxes_draws_in_batches.
- thm:meta module list and parameters: The list adds Local thresholds and Affine/quadratic structure. The parameters now include B, T, Λ_max and the sample caps and list budgets. The text notes that skipping procedures once an interval is tight changes neither soundness nor completeness, and lists what the implementation runs.
- envelope.py subnormal exp (_exp_up/_exp_down): Below the normal range _exp_up adds 4 ulp(0) and _exp_down flushes to 0. Values in the normal range are unchanged. This also makes tilting.py and the TG conversion safe, since both use these helpers. Test test_exp_bounds_below_normal_range.

## ctx

I fixed all five remaining 'ctx-modules' re-review items in paper/p1-ctx.tex. I also added three tests to code/tests/test_fix_ctx.py that check the new claims. code/rareprob/ctxwidth.py needed no change, because the module walk is not implemented in code.

(1) The module walk now clips its output to [e^{-Σξ}L_F, min{1, e^{Σξ}U_F}] and states [L_j,U_j] ⊆ [0,1].
(2) The third rule is replaced by q̂_j = sqrt(L_jU_j) with the least valid ξ_j = max{½log(U_j/L_j), log((1−L_j)/(1−q̂_j)), log((1−q̂_j)/(1−U_j))}. When both of the first two rules apply, the walk takes the one with the smaller ξ_j. A vanishing denominator gives ξ_j=∞ and the interval [0,1].
(3) The completeness sentence is rewritten as an exact claim. Let each module estimate the polarity its parent's rule uses. Then the final log-ratio is at most S, the sum of all quotient log-ratios, when only the first two rules are used. In general it is at most e^{O(dS)}S, because the third rule's interval contains 1/2 and gives 2ξ_j ≤ (1+O(ρ_j))ρ_j.
(4) The module-tree quotient is renamed R_g, with its own definition. Q_g now means only the quotient with respect to the output.
(5) The frontier remark now reads 'is a d-DNNF if, in addition to the hypothesis of thm:cw, every D_f is one'.
(6) Threshold gates: integer weights of either sign are now covered, with O(kW) wires, W = Σ|w_i|. A negative weight acts on the complemented input, since w·h = |w|·¬h − |w|.

Checks:
- A scratch simulation (/tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/ctxfix2/walk.py) ran 40,000 random module trees with clipping and the new rules. It found no coverage failures and no domain errors. With only rules 1–2, R/S ≤ 1. With rule 3, R ≤ S·e^{0.36 dS} was observed. On the referee's depth-10 XOR chain, the final log-ratio is 0.00202 with the new rule versus 2.46 with the old one.
- 2ξ ≤ ρ(1+4ρ) for ρ ≤ 1/2, on either polarity.
- The paper builds in a scratch copy with no errors and no overfull boxes in p1-ctx. Citations are undefined only because the refs.bib entries are still pending.

- ctx-modules new finding: module-walk intervals must be clipped to [0,1] (q-hat could exceed 1; sqrt of a negative number; undefined log): paper/p1-ctx.tex walk paragraph: [L_j,U_j] ⊆ [0,1] is now stated, and the module output is [e^{-Σξ}L_F, min{1, e^{Σξ}U_F}], with a note that the clipping keeps q̂_j in [0,1]. The convention 'if a denominator vanishes, ξ_j=∞ and the bound is [0,1]' covers L_j=0 and U_j=1. test_module_walk_sound_and_additive checks coverage and q̂ ∈ [0,1] on 1,500 random module trees; clipping is triggered 499 times.
- ctx-modules new finding: third rule doubles the error near 1/2 for non-unate quotients; the completeness sentence read as sufficient: The third rule is now q̂_j = sqrt(L_jU_j) with the least ξ_j for which both conditions of lem:quotient hold on all of [L_j,U_j]: ξ_j = max{½log(U_j/L_j), log((1−L_j)/(1−q̂_j)), log((1−q̂_j)/(1−U_j))}. When both of the first two rules apply, the walk takes the one with the smaller ξ_j; without this, completeness fails when a child estimates the polarity that matches an antitone input. The completeness claim is now exact: with each module estimating the polarity its parent's rule uses, the final log-ratio is ≤ S under rules 1–2 and ≤ e^{O(dS)}S in general (the third rule's interval contains 1/2, and 2ξ_j ≤ (1+O(ρ_j))ρ_j). New tests test_quotient_third_rule_near_additive (soundness, and 2ξ ≤ (1+4ρ)ρ for either polarity) and test_module_walk_sound_and_additive (R ≤ S when only rules 1–2 are used).
- ctx-modules new finding: Q_g defined twice with different meanings: The module-tree quotient is renamed R_g, defined as 'obtained from the cone of g by replacing each g_j with a fresh input'. The walk uses 'Q be R_g or ¬R_g'. Q_g now denotes only the quotient with respect to the output.
- ctx-modules new finding: frontier remark 'd-DNNF only if every D_f is one' has the wrong direction: Now reads 'the result is a d-DNNF if, in addition to the hypothesis of thm:cw, every D_f is one'.
- ctx-modules new finding: threshold-weight statement (nonnegative only) disagrees with sec-setting and understates the reach: p1-ctx.tex now says that a threshold gate with integer weights w_i becomes a sequential counter with O(kW) wires, W=Σ_i|w_i|, where a negative weight acts on the complemented input (w_i h = |w_i|¬h − |w_i|). The counter's ORs remain deterministic. test_negative_threshold_weights_by_complementing checks the identity, the absence of opaque nodes, the wire bound |N| ≤ 2|C| + 6k(W+1), and DNNF equivalence. The matching sec-setting.tex change is listed in external_edits.

## cftp

All remaining 'cftp' re-review items that fall in my files are fixed, and so are the two Janson consistency edits. The full suite passes (230 tests).

Reproduction first: with 1061 unit clauses, q = [0.5]*1060 + [0.8*2^-10] and p = 12.8*2^-1074, the old code returned harris_lower = 13*2^-1074 and a Janson lower end of 13*2^-1074, both above p. The upper end was also wrong: at p = 13.4*2^-1074 (or 2.6 or 1000.4 units of 2^-1074), the old Janson upper end rounded to 13*2^-1074, below p.

Fix: janson.py now has exp_down(s, err) and exp_up(s, err). They give rigorous bounds on e^t for every t within err of s. Below twice the smallest normal float, exp_down returns 0 and exp_up adds 4 units of 2^-1074. harris_lower, janson_interval and the statistical ends of telescoping_estimate (a new helper, _stat_interval) all use them.

While doing this I found that the old 1e-12 slack on the statistical ends did not provably cover the rounding in normal range either:
- 1 - mean lost relative precision when a stage ratio is small;
- the naive sum of K logs can be off by about K*2^-53*|log Z|;
- prod(1+x)-1 cancels, and the error is amplified by -log1p(-eps0) as eps0 approaches 1.

The code now counts integers exactly and uses log1p or log by regime, fsum, and expm1(fsum(log1p)). It rounds h_k down and b, v and eps0 up, with stated error bounds. On 120 random CNFs with the same seeds, the new intervals differ from the old by at most 1e-12 relative, and none missed p.

Empty CNF: returns [1,1] where it used to crash.

Janson: Delta is now summed over unordered pairs; the docstrings in janson.py and exp_janson.py say this.

Paper (thm:cftp in p1-cftp.tex):
- stages renamed I_k, with S_i kept for supports;
- new input Lambda_max and a decline rule ('if Lambda > Lambda_max, output [0,1]');
- the b_i^+ sample size is now N_b = ceil(192 m ln(6m/delta)) and its cost of m*N_b samples is counted;
- the cost bound is now O(Lambda_max^3 log(Lambda_max/delta)/eps + Lambda_max^2 log(1/delta)/eps^2) runs, using K <= Lambda and 1/rho <= Lambda;
- completeness: for a CNF with max b_i <= 1/2, or (except with probability delta/6) any unate C with max b_i <= 1/8, Lambda <= 24mu+3 <= 24m+3, so the cut-off 24m+3 costs no completeness there;
- the proof gains a short paragraph showing b_i^+ <= 3b_i + 1/(8m), using the KL lower bound and Chernoff;
- the implementation paragraph notes that cftp.py needs no Lambda_max because it takes N.

The paper builds without errors in a scratch copy. There are undefined citations from other files (bodlaender1996, bodlaenderkloks1996, greenhill2000, acms2020, finner1992, cited in p1-ctx.tex and p1-indep.tex), but no warnings from p1-cftp.tex.

Files: /home/user/AI-works/circuit-output-fraction/code/rareprob/janson.py, /home/user/AI-works/circuit-output-fraction/code/rareprob/cftp.py, /home/user/AI-works/circuit-output-fraction/code/tests/test_fix_cftp.py, /home/user/AI-works/circuit-output-fraction/experiments/exp_janson.py, /home/user/AI-works/circuit-output-fraction/paper/p1-cftp.tex.

- cftp re-review: subnormal-range outward rounding in harris_lower (line 88) and the Harris clamp: Reproduced the 1061-unit-clause case: harris_lower gave 13*2^-1074 > p = 12.8*2^-1074. harris_lower now returns exp_down(s, 2^-36(|cls|+2)), which is rigorous and gives 0 below 2^-1021. The deductive clamp lo = max(lo, harris) is therefore sound. Stage guarantees h_k are rounded down by (1-2^-50) and set to 0 if they fall below the normal range.
- cftp re-review: subnormal-range outward rounding in janson_interval (line 90): Reproduced: lo = 13*2^-1074 > p at 12.8 units. Also found that the upper end fell below p at 13.4, 2.6 and 1000.4 units (hi = 13, 3 and 1000 units). lo = exp_down(logM, slack) and hi = min(1, exp_up(log_up, slack)). Checked against exact rationals on the 1061-clause family and on 15,000 random near-subnormal instances; the HEAD code missed 1 of those, the new code 0.
- cftp re-review: statistical ends of telescoping_estimate (old cftp.py lines 253-255): New _stat_interval(med, b, eps0, kap) uses exp_down/exp_up with error 2^-48*(sum of magnitudes). log Z^ is now an fsum of log1p(-bad/n_k) or log((n_k-bad)/n_k), chosen by regime, with integer counts. b = fsum(th/(h-th)), v = expm1(fsum(log1p(x))) and eps0 are each rounded up by (1+2^-48). Checked against 60-digit decimal arithmetic on 200k random inputs and in a new unit test.
- cftp re-review: empty-CNF regression (h.min() on K = 0): telescoping_estimate returns Estimate(1,1,1,...,'no clauses: p = 1') before staging. New test_empty_cnf also checks that janson_interval([]) contains 1.
- cftp re-review: symbol S used for both stages and supports: In thm:cftp and its proof the stages are now I_1..I_K (rho_k = prod_{i in I_k}, F_{<k} = F_{I_1 cup ... cup I_{k-1}}, F_{I_k}, 'no event of I_k', 'first event j of I_{k+1}'). S_i is kept for supports.
- cftp re-review: decline rule / Lambda cut-off and b_i^+ sample size and cost in thm:cftp: Added the input Lambda_max >= 1 and, in step (2), 'If Lambda > Lambda_max, output [0,1]'. b_i^+ for non-CNF circuits now comes from N_b = ceil(192 m ln(6m/delta)) samples, and the m*N_b samples are counted in the cost. Run count is O(Lambda_max^3 log(Lambda_max/delta)/eps + Lambda_max^2 log(1/delta)/eps^2), using K <= Lambda and 1/rho <= Lambda (proved in the Cost paragraph). Completeness now reads: if Lambda <= Lambda_max and theta_k <= eta/16, output [0,1] with probability <= delta/3. New proof paragraph 'The bounds b_i^+': b_i^+ <= 3b_i + 1/(8m) for all i except with probability delta/6, so for a CNF with max b_i <= 1/2, or any unate C with max b_i <= 1/8, Lambda <= 24mu+3 <= 24m+3. The cut-off Lambda_max = 24m+3 therefore costs no completeness there. The implementation paragraph notes that cftp.py takes N and needs no Lambda_max. Builds cleanly in a scratch copy.
- external edit (fix:independence): janson.py Delta over unordered dependent pairs, docstring M exp(Delta/(1-max b)): 'Delta += v' moved inside 'if rank[k] < rank[j]', so Delta = sum_j d_j over unordered pairs. The docstring now reads 'M exp(Delta / (1 - max_i b_i)), Delta = sum_i d_i the sum over unordered dependent pairs'. The interval is unchanged because it uses d_j. Test test_janson_delta_unordered: (x0 v x1) & (x1 v x2), uniform, gives Delta = 0.125; HEAD gave 0.25.
- external edit (fix:independence): exp_janson.py docstring/output text: The docstring was already partly updated in HEAD. It is now reflowed and corrected: the interval is [M, prod_i(1-b_i+d_i)], inside [M, M e^{Delta/(1-eps)}], and the reported Delta is over unordered pairs. The printed note now reports unordered Delta through janson.py.

## pcis

I made all the requested changes in my three files, and the full test suite passes (246 tests).

**argument.py.** HEAD already contained a sanitizer that closes both of the referee's support-lie attacks; I re-ran the referee's attack scripts to confirm. I tightened the rest of the verifier:
- It reads only `kind`, `data` and `root` from the prover's envelope, each entry once. Kinds must be exact strings: a str subclass that compares equal to every kind used to pass.
- It recomputes supports bottom-up and checks PROD disjointness on them, with or without a proof.
- It accepts a proof only as DRUP text (str or ASCII bytes) or as a plain list/tuple of int clauses, and copies it into fresh Python ints with a new `canonical_proof()` (which drops deletions). Literals outside the domination CNF's variables, and DRUP tokens longer than 18 digits, make the proof invalid. Without this bound, a 5000-digit token raised a ValueError and crashed the verifier.
- Honest proofs from `parse_drup` are accepted as before, so no experiment output changes.

**test_fix_pcis.py.** I added regression tests for:
- both referee attacks, with the honest proof present and without a proof (lower-bound mode);
- the unknown-kind attack, a str-subclass kind and a bool index;
- nine malformed proofs, including a step that changes between reads and a list subclass;
- the accepted proof formats (list, tuple, text, bytes, numpy ints).

The attack tests fail on the old verifier (f2eed8a1), and two of the new tests fail on HEAD.

**p2-pcis.tex.** I addressed every remaining item of the pcis re-review:
- The hidden-trigger sentence now cites `tab:arguments` with no numbers.
- The "i.i.d." step in thm:sis(c), thm:sis(d) and the thm:certenv proof is replaced by an argument for adapted sequences: each walk's mean given the past lies between μ₋ and μ₊, and the Chernoff bounds behind the KL interval still hold.
- The missing side conditions are stated:
  - γ < 1/(2n), so η < 1.
  - 0 ≤ θ ≤ Σwᵢ; a larger θ is a case for REFUTE.
  - "All constants of Φ are nonnegative integers" replaces the semantic "integer-valued".
  - The verifier always clips W at 1 for the tilted envelope, which keeps a downgraded node's lower end valid.
  - The overloaded letter G is renamed: the side condition and the planted-union sets are now H and H_j, and the good event is 𝒢.
- The wrong example after thm:certenv is now a DNNF whose leaves are affine atoms. The text says only that it falls outside the theorem's rules, and no longer claims there is no FPRAS.
- Sandwiches: a threshold gate becomes a counter only if its weights are polynomially bounded, and an adder tree with a comparator otherwise.

The one external edit aimed at this file (thm:sis(a)) was already in the text, as the ctx-modules re-review also says. A scratch build of the paper has no undefined references and no overfull boxes in p2-pcis; the undefined citations are all in other files.

- CRITICAL code-soundness finding, argument.py verify(): never read derived fields from the prover's envelope; validate from scratch; check PROD disjointness on recomputed supports, also without a proof: Confirmed that the existing sanitize_envelope closes both attacks: the referee scripts t_attack_verify.py, t_attack_verify2.py and t_attack_kind.py all return [0,1] or a valid lower bound. Hardened it further. Only kind, data and root are read, each entry once. Kinds must be exact str and map to canonical constants; a str subclass equal to every kind was accepted by HEAD. Children must have smaller ids than their parents (so the DAG is acyclic), LIT data must be in range, supports are recomputed bottom-up, and PROD disjointness is checked on them. All of this runs before the proof check and in lower-bound mode. The docstrings state the trust model.
- Code-soundness: accept proofs only as DRUP text/bytes or plain lists of ints that are copied: Added canonical_proof() and _parse_drup_text() to argument.py. Accepted: exact str, ASCII bytes, or an exact list/tuple of exact list/tuple steps of Python or numpy ints (no bools), with deletion steps marked by exactly 'd'. These are copied once into fresh Python ints, and deletions are dropped (sound). Rejected: subclasses, unknown markers, literal 0 inside a clause, unterminated clauses, tokens longer than 18 digits, and literals outside the domination CNF's variables. Rejection means no valid proof, so the output is a lower bound only. Verdict.proof_steps now counts the accepted clauses.
- Code-soundness: add both attacks from the referee report as regression tests: Added to code/tests/test_fix_pcis.py: test_attack_lied_support_underestimate (C = x0 AND x1, PROD(x0, x0', x1) with a lied support, honest proof present), test_attack_lied_support_overestimate (C = x1 AND x2, SUM(PROD(x0=1, x0=0 lied), x1 x2), with and without a proof), test_unknown_kind_without_proof, two new MALFORMED envelopes (str-subclass kind, bool index), test_proof_format_rejected (10 cases, including a step that changes between reads, a list-subclass proof and an over-long token) and test_proof_formats_accepted. The attack tests fail on the pre-sanitizer verifier (f2eed8a1); the str-subclass and text-proof tests fail on HEAD.
- pcis new finding: 'in our runs (sec:experiments)' evidence pointer: The hidden-trigger bullet now reads 'the DRUP proofs found by a CDCL solver grow rapidly with |A| in our runs (\cref{tab:arguments}); this is evidence, not a lower bound, ...' and quotes no numbers. The label is defined in sec-experiments.tex, so the reference resolves now; the table itself stays pending until the re-run.
- pcis new finding: 'the walks are i.i.d. given D-hat' (thm:sis(c), (d) and thm:certenv): Rewrote the end of the thm:sis(c) proof. With F = D-hat plus the earlier walks, (b) and (*) hold given F, so every walk's conditional mean lies in [mu_-, mu_+] (on A; at most mu_+ always). The KL Chernoff bounds hold for such adapted [0,1]-valued sequences, because E[e^{lambda W'}|F] <= 1 - mu + mu e^lambda with mu = mu_+ for lambda >= 0 and mu = mu_- for lambda <= 0. Hence l <= mu_+, and u >= mu_- on A. In the statement, 'i.i.d.' is removed ('computed from the walks' values', 'with fresh coins'). (d) now uses mu_- > 1/(5K) and notes that the proof of thm:envelope(iv) uses only the lower tail. thm:certenv's proof applies the same adapted argument to min(Y,M)/M, in both soundness and completeness.
- pcis new finding: unstated side conditions (i) eta < 1, (ii) theta bound, (iii) integer constants, (iv) clipping for downgraded tilted nodes, (v) letter G overloaded: (i) thm:sis(c) now requires gamma < 1/(2n), so eta = 2n gamma < 1. (ii) def:pcis and the Thresholds bullet require an integer 0 <= theta <= sum_i w_i; a larger theta makes G unsatisfiable, a case for REFUTE. (iii) The ENVELOPE rule now reads 'when all constants of Phi are nonnegative integers, since then phi is integer-valued and supp Phi = [phi >= 1]'. (iv) def:pcis says the verifier always clips W at 1 for the tilted envelope (thm:envelope(iii)), which changes nothing under domination, and the soundness proof cites the clipping. (v) The Thresholds side condition is now H, consistent with cor:local-side; the planted-union G_j is now H_j; the good event in the proof of thm:sis is now \mathcal G. G remains only for the domination circuit and the generic F |- G notation.
- pcis new finding: wrong example after thm:certenv (affine atom times a union): Replaced it with 'a DNNF whose leaves are affine atoms instead of literals'. The text now says such a piece falls outside the rules of thm:certenv: they give it neither an exact mass nor a counter, and distributing its OR-gates gives a union of possibly exponentially many R_0 pieces. The 'no FPRAS' claim is dropped. It also notes that the derivation-count mass Z equals the Lambda of that union, and words the (3/4)^m example as 'Z = 1 while the mass is (3/4)^m'.
- pcis new finding: Sandwiches threshold caveat: Now reads 'Binarize C (fan-in two; a threshold gate becomes a counter if its weights are polynomially bounded, \cref{sec:setting}, and an adder tree with a comparator otherwise)'.
- External edit (fix:ctx-modules) for p2-pcis.tex thm:sis(a): define b_i, smoothing over all n variables, range-restricted comparator for not-x_i: Checked the current text. It already has q_i = a_i/b_i, smoothing so that every derivation mentions every variable exactly once, one shared block y_i, x_i -> [y_i < a_i] and not-x_i -> [a_i <= y_i < b_i], and the proof of #E' = (prod b_i) D(E). The ctx-modules re-review says the same. No change needed.

## separations

I fixed every remaining item of the separations re-review that concerns /home/user/AI-works/circuit-output-fraction/paper/p2-sep.tex, and checked each request against the current text before applying it.

- **Gap hypothesis.** "Why not NP-hardness?" now assumes gamma >= 1+1/poly(|C|) and says why smaller gaps do not matter. In the large-side case it now names O(1/(gamma-1)) copies, which raise the gap to at least 2.
- **Converse by padding.** I proved the converse rather than dropping the claim, so "the two conditions differ only by derandomisation" is now justified. If prBPP=prP, the prover strictly helps on these tasks exactly when P is not weakly automatable.
- **Notation clashes.** All four flagged clashes are removed, and I removed three more of the same kind (A, f, the old two-sided C_u definition).
- **Wording.** I fixed both flagged wording items (Atserias-Mueller, injectivity) and the cosmetic V_T item: the instance now fixes eps and delta.

The section compiles in a scratch copy (/tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/sepbuild) with no warnings from p2-sep.tex. That build shows undefined citations in other files, all outside p2-sep.tex. A brute-force check with exact fractions confirms the new arithmetic: the pad_0 values, the tensoring count and the universality bound.

The major item from the re-review is still open and is outside my file: the abstract, the intro and the README still carry the retracted "exactly" claim and the unqualified NP-hardness sentence. I have restated those edits in external_edits, worded to match the new converse remark.

- separations new finding (minor): orientation-2 tensoring in 'Why not NP-hardness?' needs gamma >= 1+1/poly: The hypothesis is now gamma >= 1+1/poly(|C|), with the reason smaller gaps do not matter: a tight interval decides the gap only when 1+eps<gamma, and an efficient procedure reaches such eps in polynomial time only if 1/(gamma-1) is polynomial. The set lower bound step now says it uses O(1/(gamma-1)) independent copies, which raise the gap to at least 2.
- separations new finding (minor): converse-by-padding remark for 'the two conditions differ by derandomisation': Kept the claim and proved it. For the systems of prop:canonical(c), a P-refutation of F gives one of Tseitin(C_F) AND [C_F=1], with polynomial overhead, for a circuit C_F computing F gate by gate (derive the clauses of F, or for Frege-type systems the equivalence of each gate variable with its subformula). So (F,1^k) -> C_F padded to size at least k reduces Pudlak's pair to the slice (Z_P^{m0},SAT) for a fixed polynomial m0. Hence P is weakly automatable iff that slice is separable in deterministic polynomial time, and if prBPP=prP the prover strictly helps on these tasks exactly when P is not weakly automatable. I used polynomial rather than linear m0, because the Frege-type transfer has polynomial overhead.
- notation (i): beta is both the pad variable and the NP formula beta_ell in 'Hard slices': Renamed the 'Hard slices' formulas alpha_ell, beta_ell to varphi_ell, psi_ell. beta is now only the pad selector variable.
- notation (ii): B is both the second NP set and the complement verifier in 'Two-sided': Renamed the 'Two-sided' verifiers A, B to R, R'. A and B now appear only as the NP pair in 'Hard slices'. I also renamed the V_T program A (and delta_A) to M (and delta_M), which removes a third meaning of A.
- notation (iii): C_u defined twice: The 'Hard slices' circuits are now F_u = varphi_{|u|}(u,.) ('the formula ..., as a circuit'), with Z={F_u : u in B} in the text and in the proof of the corollary. The two-sided gadget is now written C_u = pad_0(R(u,.)), which equals the old definition and reuses the pad notation. This removes the second explicit use of the beta variable.
- notation (iv): G is both the generator and the envelope circuit: Renamed the proof-complexity generator to g. G keeps the meaning it has in p2-pcis.tex: the circuit of an ENVELOPE node with C_v |-_P G. The hypothesis now reads 'no short proofs C_y |-_P G for the circuits G of ENVELOPE nodes (sec:pcis) whose envelopes have mass n^{-omega(1)}'. The old phrase 'envelope circuits G' did not match the paper's own definition, where an envelope circuit is the arithmetic circuit Phi.
- wording (v): 'No polynomial-time algorithm finds ... in time polynomial in |F| and ...' contradicts itself: Now reads: 'No algorithm finds resolution refutations of unsatisfiable CNFs F in time polynomial in |F| and the size of the shortest refutation of F unless P=NP'.
- wording (vi): 'need a proof that f is injective' overstates: Now reads: 'need a proof that f^{-1}(f(x_0))={x_0} (for V_T, e.g. the instance of a T-proof that f is injective)'.
- cosmetic (proof #2 note): the V_T instance should also fix (eps,delta): The p-simulation now uses V'(.,.,pi',eps,delta), t=t'(|C|,|pi'|,1/eps,log(1/delta)), and the instance of the T-proof at (C,D,pi',eps,delta). This matches V(C,D,pi,eps,delta) in def:argument.
- additional clash: f was both the one-way permutation and the SBP exponent in 'Universality': Renamed the exponent to j, the same letter as the converse direction of that paragraph (2^{-j} versus 2^{-j-1}). The arithmetic, 2^{-k(j+1)} <= 2^{-kj}/c for k >= log2 c, is checked by brute force.
- consistency: Changed 'randomised many-one' to 'randomized many-one', matching the other 12 uses in the file. I reflowed the edited paragraphs with a script that asserts the word sequence is unchanged.

## affine

The three tasks are done. Most edits are to text. The only code change is a docstring, and all 246 tests pass.
(1) The cor:barrier-methods (iii) bound was already up to date. It now applies only when every threshold gate of C has integer weights, so that the NNF is defined, and N is an NNF of C as in thm:cw without frontier gates. The appendix proof (iii) matches.
(2) The p2-xpt sentence calling resolution's failure on parity a fact now says it is a conjecture.
(3) I re-read my sections against the current p1-dfsb, p1-ctx and p2-pcis. I fixed one stale appendix claim and two stale XPT claims, and renamed the XPT rules (R1)-(R3) to (X1)-(X3) so they no longer clash with (R1)-(R8) of sec:rules.
A scratch build in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/build_affine compiles with no undefined references. The only undefined citations are the refs.bib entries requested earlier, and the overfull boxes are all in sec-envelopes.tex. Files changed: /home/user/AI-works/circuit-output-fraction/paper/p1-affine.tex, /home/user/AI-works/circuit-output-fraction/paper/app-affine.tex, /home/user/AI-works/circuit-output-fraction/paper/p2-xpt.tex, /home/user/AI-works/circuit-output-fraction/code/rareprob/affine.py (docstring only).

- ctx-modules re-review new finding: cor:barrier-methods (iii) quotes the deleted O(|C| cw 2^cw) bound and applies to circuits without an NNF: Checked the current text: it already used the thm:cw bound (|N|+1)(cw+3)2^cw and the derived cw >= m-14-log2((n+2)(|N|+1)(cw+3)/c). I re-derived the bound: 3(n+2)S >= c2^{m-12} and log2 3 < 2. It still did not restrict to circuits whose NNF is defined. Rewrote (iii) in p1-affine.tex: 'Let every threshold gate of C have integer weights, so that the NNF of C is defined (sec:ctxwidth), and let N be an NNF of C as in thm:cw, without frontier gates (|N| <= 12|C| for the gate-by-gate NNF of a {and,or,not,xor}-circuit). The DNNF that thm:cw builds from N ...'. This matches p1-ctx: integer weights, including negative ones by complementing the input, give counters; other thresholds are frontier gates only. app-affine (iii) now says 'For an NNF N without frontier gates, ...'.
- External edit (fix:pcis) for p2-xpt.tex lines 4-5: resolution lower bound for dense linear hashes stated as fact: Replaced it with: 'resolution appears to be the wrong system: the refutations of dense linear hashes that a CDCL solver finds grow rapidly, and we conjecture that resolution needs exponential size (sec:pcis)'. I used 'grow rapidly' rather than the requested 'exponentially' to match p2-pcis, which says 'grow rapidly with |A| in our runs' and calls this evidence, not a lower bound.
- Stale claim in p2-xpt line 3: 'thm:certenv admits affine subspaces as envelope pieces': thm:certenv now admits as atoms only affine subspaces on uniform coordinates, inside R_0 products. Changed to 'admits affine subspaces on uniform coordinates as atoms of envelope pieces'.
- Stale claim in p2-xpt: 'XPT is an instance of the certified-envelope rule' (the EXACT/atom rules now accept only checkable deterministic forms): Made the claim precise. A piece constrained only on uniform coordinates is an affine atom of thm:certenv. Along a linear order, the dynamic program of prop:bw-dp is an OBDD, which p2-pcis accepts as checked-deterministic: on a caterpillar tree, N_t[s] = (N_{t-1}[s] and not x_t) or (N_{t-1}[s+a_t] and x_t). So the composition with def:pcis and the inheritance of thm:pcis-sound still hold.
- Stale statement in app-affine proof of cor:barrier-methods (ii): 'its clipped weight has mean Theta(1/K_E) on [0,3]': The current thm:sis(c) uses W' = C(x)min(w,M)/M in [0,1]. Changed to 'the values W' in [0,1] of thm:sis(c) have mean Theta(1/K_E)'. On the counter-accuracy event the mean lies between (1-eta)p/M and p/M, with M in [9/4,15/4]D(E).
- Rule-name clash: XPT rules (R1)-(R3) in def:xpt vs rules (R1)-(R8) of sec:rules, both cited in p1-affine: Renamed the XPT rules to (X1)-(X3) everywhere they appear: the def:xpt list, the proof of thm:xpt(a), the dense-hash remark, 'threshold rule (X1) of sec:xpt' in p1-affine, and the Propagator docstring in affine.py. I found no other file that refers to the XPT rule names.
- Re-check of p1-affine against current p1-dfsb (atoms, (T'), canonicalised NNF, T*_K, m_K): No change needed. cor:barrier-methods (iv) and its proof (rules (T),(T'),(F),(D),(B); leaves of T*_{K'} are constants, atoms and (S)-leaves; 'atom size a <= 2n/3'; the completeness guarantee needs m_{K'}(C) <= budget) match the current DFSB. The remark that rule (F) keeps only forced literals from Gaussian elimination at the root also still matches. All cross-references in my three files resolve.

## frontmatter

I applied every requested edit to the files I own, after checking each one against the current text and the current theorem statements in the p1-, p2- and app- files. I also added all 31 missing BibTeX entries and rewrote the abstract, intro Results, discussion and README so they agree with the theorems as they now stand. The paper builds cleanly in a scratch copy (pdflatex, bibtex, pdflatex x3; 80 pages): no undefined citations or references, no multiply-defined labels, no bibtex warnings, no overfull boxes.

Several requests were stale, wrong or superseded, so I adjusted them before applying:
- Edits 74, 76 and 77 supersede 61, 64 and 65.
- Edit 13 now follows p1-ctx: integer weights, with negative weights acting on the complemented input.
- Edit 8 said "every circuit"; it now covers circuits whose NNF has no opaque gates.
- Edit 41: added the private-pivot hypothesis. "Where p=e^{-Omega(m)}" became "a range that contains thresholds with p=e^{-Omega(m)}", matching the corrected thm:local(iii).
- Edit 74: the "hard to approximate" claim now states the exact factors of thm:biased-hard.
- Edits 20 and 21:
  - "Hard to factor" is now "cannot be factored by polynomial-size circuits".
  - The two-sided separation is attributed to the verifier that checks proofs in a theory such as ZFC.
  - The NP-hardness barrier is limited to upper-bound and two-sided separations, randomized many-one reductions and gaps of at least 1+1/poly, as in p2-sep.
- Edit 19: the abstract uses the separations referee's shorter wording, which says the same thing.

Abstract: 309 words. It no longer says "exactly" about weak automatability. It states the corrected DFSB class (read-once compositions of sub-circuits that are component-dense in their polarity). DNF and DNNF coverage is attributed to envelope leaves and the meta-procedure. Context width is tied to the bracketing. Local thresholds, affine structure and the parity barrier are included.

Intro also gets:
- the corrected thm:cw bound O(|N|(cw+1)2^cw), with bounded-pathwidth CNFs bracketed along a path decomposition;
- the corrected module claim;
- the XPT and Gibbs-envelope sentences;
- the local-threshold headline result;
- a revised SPN claim;
- a related-work sentence for the new citations.

I checked the SPN claim on the exp_arguments instances with the current code: DFSB is now exact on SPN triggers with k ≤ 12 (they are atoms) and on k=16 (by branching). So the old sentence "DFSB returns an uninformative interval" was false, and I replaced it in sec-experiments and the intro. The surprise-accounting wording now says "for lower bounds" and "for two-sided intervals" in the README and discussion.

In sec-experiments, the text no longer says "every number below is reproduced by them". The implementation's simplifications are now listed. I left all table numbers as they are; see stale_numbers.

- refs.bib: missing citations (31 keys: gjl2019; acms2020, bodlaender1996, bodlaenderkloks1996, greenhill2000; finner1992; the 13 local-threshold keys; the 12 affine keys): Appended all 31 requested entries in the file's field style. Moved friedman2008's number into note={No.~910}, which removed the bibtex 'volume and number' warning. A scratch build has no undefined citations and no bibtex warnings.
- edits 1, 9, 19, 44, 63: abstract (main.tex): Rewrote the abstract (309 words):
- corrected DFSB class: read-once formulas; read-once compositions of sub-circuits component-dense in their polarity; triggers; cutsets;
- DNF/DNNF coverage via envelope leaves and the meta-procedure;
- context width depends on the bracketing (bounded-pathwidth CNF example);
- independence, annealing, local thresholds, affine structure, and the parity barrier for decomposable envelopes with small leaves;
- prover cost poly(|pi|)+2^sigma_u;
- limits: canonical-pair slices instead of 'exactly the non-weak-automatability'; NP-hardness barrier qualified to randomized many-one reductions with gap 1+1/poly.
- edits 2, 8, 20, 41, 42, 43, 62/75, 61/74: sec-intro.tex Results: Rewrote the 'Without a prover' paragraph:
- corrected cor:dfsb class;
- logarithmic-support disguise;
- DNF/DNNF coverage attributed to prop:dnnf-env and thm:meta.

Items, all checked against current statements:
- context width: O(|N|(cw+1)2^cw) for an NNF without opaque gates, the bracketing, lem:pathcw;
- corrected module claim;
- certified telescoping now names its completeness condition;
- new local-thresholds item;
- new affine item: presolve, envelopes, parity barrier with its hypotheses, biased hardness with its exact factors.

The prover paragraph gains the XPT and Gibbs sentences and the canonical-pair separation statement, with the open question and the qualified NP-hardness barrier. Experiments paragraph: added the local-threshold result, rounded the Janson interval outward to [6.18,7.35]e-22, and corrected the SPN claim. Added a related-work sentence for koriche2013, lagniez2016, daviesperkins2021 and jpss2021.
- edits 3, 23: sec-discussion.tex: 'What the answers are' now:
- lists context width, local thresholds and affine constraints;
- says logarithmic-support disguise;
- says complete on the union of the module classes (thm:meta);
- adds the parity barrier and biased hardness, and the canonical-pair separation;
- no longer claims 'exactly where'.

Other changes:
- 'both halves have a black-box meaning' wording;
- distributed-surprise paragraph points to thm:cftp and thm:local;
- open problems: added the parity-barrier pointer, the certified-annealing scope, the requested 'Weak automatability and envelopes' item, and a local-threshold pointer in Networks.
- edits 4, 10, 21, 22, 46, 47, 48, 64/76, 65/77, 66: README.md: Updated:
- DFSB class and DNF/DNNF attribution;
- context-width bullet (bracketing, size bound);
- module claim;
- local-threshold and affine bullets;
- XPT/Gibbs and surprise-accounting wording in the prover bullet;
- Limits paragraph (canonical-pair slices, open question, qualified NP-hardness barrier);
- localthr.py and affine.py code entries;
- exp_local and exp_affine in the experiments list and Reproduce loop;
- Status: failure of feasible interpolation, plus the new proved results and their cited ingredients;
- implementation notes (atom size 12, greedy VE order).
- edits 5, 11, 14, 17, 45, 69: sec-experiments.tex: Opening paragraph:
- lists all implemented procedures and the simplifications (atom size 12, greedy orders, heuristic TG pilot, counters only for nonnegative integer weights);
- 'every number below is reproduced' replaced by 'each table and figure is generated from the raw output of the script named in its caption'.

Then:
- blocks family: now exact by (T') and (D) with no samples; the 'cubic in the number of blocks' claim is removed;
- ctx bracketing sentence (edit 11);
- Janson interval rounded outward;
- cftp: 'bias factor below e^{0.02}';
- added Local thresholds (tab:local) and Affine structure (tab:affine) pointer paragraphs;
- hidden-trigger paragraph: DRUP proofs as evidence, not a resolution lower bound; SPN tests reached through small-cone atoms and branching (about 2^{|S|-a} leaves) instead of 'DFSB returns an uninformative interval'.
- edits 27, 38, 39: sec-envelopes.tex: Removed 'deterministic'. Listed the tilted Gibbs estimator as a variant of the envelope estimator. Added the prop:certgap sentence and the overlapping-blocks/rem:local-blocks sentence. Rounded the Janson example outward to [4.33,5.07]e-7. Fixed three small overfull boxes.
- edits 24, 25, 26, 28, 29, 30 (listed as DONE): Checked that they are present in the current text; not touched.
- edit 13: sec-setting.tex threshold expansion: Now reads 'integer weights of polynomially bounded total W=sum|w_j| expand by a sequential counter with O(kW) wires (a negative weight acts on the complemented input)', matching p1-ctx and the ctx referee. The implementation's nonnegative-only restriction is noted in sec-experiments.
- sec-limits.tex: lower-bound universality statement: Qualified to 'under the uniform distribution', as in p2-sep.
- edits 49, 67: code/rareprob/__init__.py: Exported LTC, ltc_from_circuit, tg_estimate, presolve_estimate, affine_envelope_estimate and xpt_verify. Import checked: no circular imports.

