# Final referee report: setting-limits

**Verdict.** Paper (sec-setting, sec-limits): sound with minor fixes. All eleven round-1 findings are resolved in the current text; the one partial is that the size of the compiled circuit C' in prop:interactive(a) is still left implicit. Code: one critical finding. The implementation's threshold gates do not compute the threshold function defined in the Setting, so on such circuits every procedure can return an interval that excludes p with probability 1. The fix is simple: evaluate exactly, or declare the floating-point semantics and reject inputs that lose precision. The other new findings are minor.

**What was checked.** I read in full: sec-setting.tex; sec-limits.tex; sec-envelopes.tex (for the KL interval and envelope definitions); the parts of sec-intro, the main.tex abstract, sec-discussion, p2-sep (Universality), p2-pcis, p1-tail and p1-affine that restate the limits results; the README; and code/rareprob/{circuit,dist,stats,exact}.py plus the THR handling in nnf/ve/affine/localthr/meta.

LENS A, proofs re-derived.
- prop:worstcase(a). The rule "satisfiable iff L>0" has error at most delta on unsatisfiable formulas and at most 2*delta on satisfiable ones. With delta=1/8 the error is at most 1/4, which gives NP in BPP. Any fixed finite eps works.
- prop:worstcase(b). E_y|G^{-1}(y)| = 2^{-k}, so Pr_y[p>0] <= 2^{-k}, and p(C_{G(s)}) >= 2^{-k}. Firing probability on G(s) is at least 1-2*delta. On uniform y it is at most 2^{-k}+delta, and truncation only lowers it. Advantage is at least 1-3*delta-2^{-k} >= 1/2 for delta <= 1/8 and k >= 3. Fixing coins to the best value gives size O(t log t)+poly(k) > T(k), hence t log t >= T(k)/poly(k). Monte Carlo costs O(2^k poly(k)). The 2^{o(k)} conclusion is right; writing it as p^{-o(1)} assumes p = 2^{-Theta(k)}, which is harmless.
- thm:blackbox. I checked the coin-fixed coupling, that each fixed query lies in H_t for exactly one t, the union bound T*2^{-k}, the averaging over t, and soundness on f_t. For the 'In particular': k = ceil(log2(1/eta)) - 1 gives eta < 2^{-k} <= 2*eta, and k <= n iff eta >= 2^{-(n+1)}. The derived T >= (1-delta-delta')/(2*eta) is correct; the only exception is eta=1, which gives k=-1 (finding below).
- Remark. Ax+b is pairwise independent and Var D(H) <= 2^{-k} sum_x D(x)^2. Chebyshev then gives failure probability at most 4*2^k*sum_x D(x)^2, and the stated final bound follows. I checked this numerically for n=12, k=1..6, random biased product D (scratch remark_planting.py). Empirical failure was always below the bound, Pr[point in H] was about 2^{-k}, and sum_x D(x)^2 = prod_i(q_i^2+(1-q_i)^2) to machine precision. The padded white-box version is coherent: the planted circuits C or (1 and G_{A,b}) have the same size as C or (0 and G_{A0,b0}).
- thm:ma. Completeness 2/3, soundness 1/3. BHZ87 gives coNP in AM implies PH = Sigma_2^p. From coNP in MA: Sigma_2 is in MA, which is in AM, which is in Pi_2, so PH = MA, as the text says.
- SBP paragraph and p2-sep. Both directions check out: amplification by k >= log2 c conjunctions; and conversely, sending j = floor(log2(1/p))+1 gives completeness within a factor 4 and soundness outside the promise. Tensoring with m = O(1/eps) copies gives a (1+eps) factor.
- prop:interactive(a). The field size |F| > 2^{B+1} suffices to recover 2^B*p in [0, 2^B]. Individual degree is fanout+2 <= |C'|+2. Soundness is v*d/|F|. The dyadic restriction is unnecessary, since a prime larger than the product of denominators handles any rational marginals, but what is stated is correct.
- prop:interactive(b). Goldwasser-Sipser is correctly scoped to uniform or dyadic D, with parallel repetition.

Setting.
- The NNF size claims hold: XOR fan-in k gives O(k) gates per polarity; a threshold gate gives a sequential counter with O(kW) wires, with negative weights shifting the threshold.
- A sound procedure complete on a class gives a (1 +/- eps)-approximation with probability 1-2*delta.
- The Monte Carlo baseline Theta(log(1/delta)/(p eps^2)) and the DKLR optimality attribution are correct.

Citations.
- bgm2006: a web search confirms the abstract states an oracle relative to which SBP is not in Sigma_2^p.
- chen2007inverse (arXiv:0711.2801): search results say it identifies a gap in DKLR's Stopping Rule Theorem proof and derives a threshold from which DKLR's claim follows. 'Repaired proof' is fair, though 'alternative proof' would be more precise. arxiv.org was unreachable from here, so I could not read Appendix D myself.
- bhz1987, lfkn1992, gs1986, darwiche2002map, dklr2000: metadata and attributions are correct.

LENS B, code.
- Fuzz test (scratch edge_fuzz.py): 300 meta_estimate runs on random small circuits, with VE on and off. The circuits included repeated children, XOR(x,x), CONST gates, small-integer THR, and marginals in {0, 1, 1e-9, 1e-3, 0.3, 0.5, 0.999}. I also ran an n=0 constant circuit. Every run was checked against brute force under the evaluator's semantics: no violations and no crashes.
- kl_interval against an 80-digit Decimal KL (scratch klcheck.py, klcheck2.py): conservative up to a relative delta inflation of at most 1.5e-6 for N <= 1e10 (finding below).
- Threshold-gate semantics against exact rational semantics (scratch thr_sem.py): a critical mismatch (finding below).
- dklr_stopping_rule hitting its sample cap: returns a wrong estimate (finding below).

sec-setting and sec-limits contain no experiment numbers. Scratch scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/limits_final/. No repository file was edited.

## Audit of earlier findings

resolved: 11

- [resolved] (major) Remark after thm:blackbox: white-box claim false (circuit size reveals info): sec-limits.tex lines 96-101 now restrict the claim to verifiers that use the circuit only through evaluations and its size, with a gadget padded to a topology independent of (A,b) (rows written as XOR_j(x_j AND a_ij) XOR b_i with constant leaves). The bound is stated for some circuit of size |C|+O(nk), namely C or (0 and G_{A0,b0}), and the |C|=3 counterexample shows it cannot hold for every circuit computing f. Remaining small gaps: the counterexample needs uniform D; the planted circuits C or (1 and G_{A,b}) are not written out; constant leaves are not part of the Setting's circuit model (new nit F7).
- [resolved] (minor) Remark: general-D inequality not stated (2^{-k-1}, extra Chebyshev term): Line 95 now states Pr[U<2^{-k-1}] <= delta + T*2^{-k} + 4*2^k*sum_x D(x)^2. Line 90 says 'collision entropy', and line 94 gives the product formula prod(q_i^2+(1-q_i)^2). I re-derived it and checked it numerically for biased product D.
- [resolved] (minor) thm:blackbox 'In particular' missing k<=n hypothesis; eta<=2^{-k}<2eta slip: The statement now reads 'for 2^{-(n+1)} <= eta <= 1', and the proof reads 'eta < 2^{-k} <= 2*eta'. One residual edge: eta=1 gives k=-1 (folded into new nit F7).
- [resolved] (minor) prop:worstcase(b): firing prob 1-2delta, advantage 1-3delta-2^{-k}, need k>=3: The proof (lines 31-36) now says 1-2*delta, explaining that tightness and containment each fail with probability at most delta, and gives advantage 1-3*delta-2^{-k} >= 1/2 for delta <= 1/8, k >= 3. The statement includes 'k >= 3' and 'delta <= 1/8'.
- [resolved] (minor) prop:worstcase(b): circuit simulation is not t+poly(k); truncation needed: The proof now stops A after t steps, noting that this only lowers firing on other inputs. It simulates with a circuit of size O(t log t)+poly(k), and the statement concludes t log t >= T(k)/poly(k). The machine model (multitape TM, Pippenger-Fischer) is still unstated, which is acceptable.
- [resolved] (minor) prop:worstcase(a): tight interval need not contain p; 2delta on satisfiable; 'any fixed eps<1' ambiguous: The statement now reads '(for some fixed eps>0; any finite eps works)'. The proof distinguishes p=0 (L>0 has probability <= delta) from p>0 (L=0 means not tight or excludes p, probability <= 2*delta) and runs with delta=1/8.
- [resolved] (minor) SBP: 'exactly SBP in MA' should be prSBP in prMA, with gap amplification: Lines 125-130 now say 'exists iff prSBP is in prMA (amplify the SBP gap by conjunctions of copies; conversely send the scale with an MA proof), and in particular it would give SBP in MA'. This matches the p2-sep proof sketch, which I checked. The following sentence still has an inference and expectation problem (new finding F4).
- [resolved] (minor) prop:interactive(a): threshold gates, field size, degree of the full summand: The statement now compiles threshold gates into {AND,OR,NOT,XOR}-subcircuits C', uses a prime field with |F| > 2^{B+1}, and bounds d <= |C'|+2 for the full Tseitin summand. Only the size of C' (poly in |C| and the weight bits) is left implicit. Since |C'| is polynomial in the input length, 'polynomial-time verifier' remains correct.
- [resolved] (minor) Fiat-Shamir / computational soundness only in the random-oracle model: sec-limits lines 153-155 now say 'in the random-oracle model (or heuristically with a fixed hash)', and sec-setting lines 94-95 say 'computational soundness in the random-oracle model'.
- [resolved] (minor) prop:interactive(b): distribution unspecified; output L/c; repetition: The statement now reads 'For uniform D (or dyadic product D, via the sampler reduction), two-round public-coin protocols, repeated in parallel, certify p >= L/c for a constant c'.
- [resolved] (minor) Closing paragraph and intro overclaim (conditional, upper bounds only, below ~1/T): sec-limits lines 156-159 now say 'unless coNP in MA, can be complete for upper bounds only on a restricted class'. The intro (lines 31-34, 56-57) says 'cannot certify p<1/T (up to constants)' and 'below about 1/T with T evaluations'. The same unconditional phrasing of thm:ma survives in sec-discussion.tex:39-40 and p2-pcis.tex:3-5 (new finding F5). The intro and README still omit the distribution hypothesis of thm:blackbox (new finding F6).

## New findings

### 1. [critical] code/rareprob/circuit.py: Circuit.add lines 53-56 (weights and threshold coerced with float()), eval_packed THR branch lines 168-173 (left-to-right double sum compared with t - 1e-12), docstring line 11 ('1 iff sum_i w_i*g_i >= t (real weights)'). The convention is replicated in ve.py:96, nnf.py:334-350, affine.py:1226-1230 and localthr._thr_count_threshold. Versus paper/sec-setting.tex lines 5-6 (threshold gate [sum_j w_j y_j >= t]).

**Problem.** The implementation's threshold gate is not the Setting's threshold function, and it does not match the class's own docstring either. All estimators are deliberately consistent with the evaluator (the tests probe float edge cases), so they are sound for the function the evaluator computes. For a circuit specified as in the Setting, however, the returned interval excludes p with probability 1. Brute force with exact rational arithmetic (scratch thr_sem.py) shows three ways this happens. (1) Integer weights that are exactly representable as doubles: C = THR(x1,x2,x3; w=(10^20, 1, -10^20), t=1) under uniform D has p = 1/2. The evaluator rounds 10^20+1 to 10^20 and computes p = 3/8, and meta_estimate returns [0.37499999999999917, 0.37500000000000083] ('exact (variable elimination)'). (2) Tolerance: AND of 30 gates THR(x_i; w=1, t=1+1e-13) has p = 0, since 1 < 1+1e-13. The evaluator fires at s >= t - 1e-12, and meta_estimate returns [9.3132e-10, 9.3132e-10] = 2^-30. (3) Silent coercion: THR(x1,x2; w=(2^60, 1), t=2^60+1) is stored as t = 2^60, so C(1,0) = 1 while the true value is 0. The paper's Setting never says the implementation uses rounded threshold arithmetic. p1-affine.tex:469 and p1-local.tex:19 refer to 'the function the circuit computes' as the evaluator's, which a reader of sec-setting cannot know.

**Proposed fix.** Choose one of two fixes. (a) Exact semantics: keep integer or Fraction weights as given, evaluate THR exactly (int64 when sum_j|w_j| + |t| < 2^62, Python ints or Fractions otherwise), drop the 1e-12 tolerance, and route thr_sum in ve/affine/nnf through the same exact function. (b) Declared semantics: state in sec-setting (and the Circuit docstring and README) that implemented threshold gates compute [fl(sum_j w_j y_j) >= t - 1e-12], with weights rounded to doubles and summed left to right, and that soundness is relative to this function. In that case make Circuit.add raise when float(v) != v for an int or Fraction weight or threshold, when sum_j|w_j| >= 2^53, or when t lies within 1e-12 above an attainable sum. Option (b) is two sentences plus input validation.

### 2. [minor] paper/sec-setting.tex Def. def:sound lines 46-47 ('efficient if it runs in time poly(|C|,1/eps,log(1/delta))') and Def. def:argument line 88 (pi of size poly(|C|)); |C| counts wires only (line 7)

**Problem.** The input size omits the description length of D (the bit length b of the marginals q_i) and of the threshold weights. Reading the q_i already takes time linear in b. lem:envmass works with poly(|Phi|, b)-bit rationals, and prop:interactive needs |F| > 2^{B+1}, so the positive results are polynomial in b, not in |C| alone. As literally stated, 'efficient' is unachievable for D with long marginals. The representation of the q_i (rationals? doubles?) and of the threshold weights is also never stated.

**Proposed fix.** Define the input size as |C| plus the total bit length of the weights and of D's marginals (say, rationals in binary). Write 'poly(|C|, b, 1/eps, log(1/delta))', and use the same measure for the size of pi.

### 3. [minor] paper/sec-setting.tex lines 75-76 (definition of beating sampling): 'Its cost is then polynomial in the surprise log(1/p) rather than in 1/p.'

**Problem.** This is imprecise. 'Efficient' means poly(|C|, 1/eps, log(1/delta)), which is independent of p and not bounded by poly(log(1/p)). For example, a class member with p = 1/2 may still cost poly(|C|). The point is that the cost does not grow with 1/p.

**Proposed fix.** Write: 'Its cost is then polynomial in the input size, independently of p, whereas Monte Carlo's grows like 1/p = 2^{surprise}.'

### 4. [minor] paper/sec-limits.tex lines 131-133: 'Since MA is in SBP is in AM, with an oracle relative to which SBP is not in Sigma_2^p, we should not expect proposal-based lower bounds for every circuit either.'

**Problem.** (i) The inference omits the fact it needs: the oracle result gives SBP not in MA only because MA is in Sigma_2^p, and that inclusion relativizes. 'MA in SBP in AM' is not the reason. (ii) 'We should not expect' contradicts p2-sep.tex lines 261-266, which correctly note that the inclusion prSBP in prMA holds if prAM = prNP. That follows from standard derandomization hypotheses (Miltersen-Vinodchandran) and is widely believed. The oracle separation shows only that a proof would need non-relativizing techniques.

**Proposed fix.** Write: 'Since MA is in Sigma_2^p relativizes and [bgm2006] give an oracle relative to which SBP is not in Sigma_2^p, such a system cannot be shown to exist by relativizing arguments. It does exist if prAM = prNP (Section p2-sep), with soundness resting on that derandomization hypothesis.'

### 5. [minor] paper/sec-discussion.tex lines 39-40 ('no system certifies them for all circuits (thm:ma)'); paper/p2-pcis.tex lines 3-5 ('by thm:ma no argument system does so for every circuit'); paper/sec-limits.tex lines 105-106 ('In general such proofs cannot always exist')

**Problem.** Each passage states thm:ma unconditionally, but the theorem is conditional (unless coNP is in MA) and is about polynomial-size arguments. Exponential-size confinement proofs (truth tables) always exist.

**Proposed fix.** Add 'unless coNP is in MA' in sec-discussion and p2-pcis. In sec-limits, write 'Short such proofs cannot always exist unless coNP is in MA:'.

### 6. [minor] paper/sec-intro.tex lines 31-34 and 56-57; README.md 'Limits' bullet ('A verifier that only evaluates C cannot certify an upper bound below about 1/T with T evaluations, whatever the argument')

**Problem.** thm:blackbox is proved for the uniform distribution, and the Remark extends it to D with small collision probability. The summaries drop this hypothesis, and without it they are false. Counterexample: let D be a point mass (all q_i in {0,1}), so p = C(x0). One evaluation certifies p = 0 exactly when C(x0) = 0. More generally the planted bound is vacuous when 4*2^k*sum_x D(x)^2 >= 1.

**Proposed fix.** Add 'under the uniform distribution (or any product D whose collision probability sum_x D(x)^2 is much smaller than 1/T)' in both intro places and in the README.

### 7. [minor] paper/sec-limits.tex thm:blackbox line 68 and Remark lines 96-101

**Problem.** Small precision nits. (i) The 'In particular' range includes eta = 1, where k = ceil(log2(1/eta)) - 1 = -1 is undefined. The claim still holds via k = 0, but the proof as written does not cover it. (ii) 'A verifier that sees |C|=3 knows p in {0} union [1/8,1]' holds only under the uniform distribution, yet the Remark has just moved to general D. (iii) The planted circuits must be C or (1 and G_{A,b}), so that they have the same size as C or (0 and G_{A0,b0}); this is not written. (iv) Constant leaves are used but are not part of the Setting's circuit model (they can be simulated by x1 and not x1).

**Proposed fix.** Write '2^{-(n+1)} <= eta < 1' (or take k = max(0, ceil(log2(1/eta)) - 1)), and add 'under the uniform distribution' to the |C|=3 sentence. Add 'the planted circuits being C or (1 and G_{A,b})'. Allow constant leaves in the Setting's circuit definition.

### 8. [minor] code/rareprob/stats.py dklr_stopping_rule lines 143-156

**Problem.** The docstring promises Pr[|est/mu - 1| > eps] <= delta. When max_samples is reached, though, the function returns ups1/N, which is unrelated to mu. Tested: with mu = 0 and cap 1e4 it returns 0.1167; with mu = 1e-7 and cap 1e5 it returns 0.0117, a relative error of 1.2e5. If anyone used it as the Monte Carlo baseline (the README lists it), the guarantee would fail. No code or experiment currently calls it.

**Proposed fix.** When the cap is hit, return a flag or None (or raise) instead of an estimate. Alternatively, return a valid KL interval for the samples drawn so far. Or remove the function and its README mention.

### 9. [minor] code/rareprob/stats.py kl_bern/kl_interval lines 18-68 (implements the Hoeffding-KL interval of sec-envelopes.tex lines 75-79, used by all procedures)

**Problem.** Rounding in kl_bern, where the two terms nearly cancel when m is close to the mean, makes the returned endpoints lie slightly inside the exact interval {m: N KL(mean||m) <= ln(2/delta)}. I compared against an 80-digit Decimal evaluation on 6000 random (mean, N, delta) cases. The effective level delta' = 2*exp(-N*KL(endpoint)) satisfies delta'/delta <= 1 + 1.1e-7 for N ~ 1e8 and <= 1 + 1.5e-6 for N ~ 1e10. At N = 1e15 (unrealistic) it reaches about 1.03. This is negligible in practice, but the code otherwise claims outward rounding everywhere and does not apply it here. Similarly, the rounding of the running float sum in sequential_mean is not accounted for.

**Proposed fix.** Exclude a candidate m only if kl_bern(mean, m) > c + 8u(|term1| + |term2|), where u = 2^-53 and term1, term2 are the two summands of kl_bern. Alternatively, compute the terms with log1p and xlogy and inflate c by a relative 1e-12 plus an absolute few ulps. The bisection then stays conservative.

