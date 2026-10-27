# Round 1 referee report: limits (proof lens)

**Verdict.** Sound, with minor fixes. Prop. worstcase (a, b), Thm. blackbox, Thm. ma and Prop. interactive are all correct in substance. The fixes needed are: one false side claim (the white-box sentence in the Remark after thm:blackbox; a major finding), a missing range hypothesis in the 'In particular' of thm:blackbox, a 1-delta that should be 1-2delta in both parts of prop:worstcase, a circuit-simulation constant, an imprecise SBP equivalence, and some imprecise assumptions in prop:interactive and the Fiat-Shamir remark.

**What was checked.** I re-derived every step of the assigned results in /home/user/AI-works/circuit-output-fraction/paper/sec-limits.tex against the definitions in sec-setting.tex (Def. sound, complete, argument).

prop:worstcase(a): the decision rule 'satisfiable iff L>0' is correct. Its error is at most delta on unsatisfiable formulas and at most 2*delta on satisfiable ones; the text says delta. Any single finite eps works.

prop:worstcase(b): the two bounds on p are correct (Markov on |G^{-1}(y)|, with E = 2^{-k}). The coupling and averaging idea is correct, but the firing probability on G(s) is 1-2delta, not 1-delta, so the advantage is at least 1-3delta-2^{-k}. This is still at least 1/2 for delta<=1/8 and k>=3, which contradicts the strict '<1/2' hypothesis. The step 'MC/A <= 2^{o(k)}' holds uniformly because MC <= 2^k poly(k) on every instance.

thm:blackbox: the proof is correct as written. With coins fixed, the f-run's query sequence is fixed; the f_t-run is identical unless a query lands in H_t, which happens for exactly one t per query; then I checked the averaging over t and the use of soundness on f_t. In the 'In particular', only 2^k >= 1/(2eta) is needed, and that holds.

Remark (planting with H = {x : Ax = b}): Ax+b is pairwise independent, and Var D(H) <= 2^{-k} sum_x D(x)^2. Chebyshev then gives failure probability at most 4*2^k*sum_x D(x)^2, as claimed. I checked this numerically (n=12, k=2..6, random product D): the empirical failure rate was always well below the bound, the single-point rate was about 2^{-k}, and the pair rate about 2^{-2k}.

thm:ma: correct. Completeness is 2/3 and soundness 1/3. 3-UNSAT is coNP-complete and MA is closed under Karp reductions. BHZ87 gives coNP in AM implies PH = Sigma_2^p. The conclusion could even be strengthened: coNP in MA gives Sigma_2^p in MA, hence PH = MA.

SBP: MA in SBP in AM matches Bohler-Glasser-Meister 2006. The lower-bound system is equivalent to prSBP in prMA, using gap amplification by AND of copies and tensoring for (1+eps).

prop:interactive(a): I built the Tseitin arithmetisation sum_{x,w} D(x) * prod_g [w_g = g] * w_out for a small AND/OR/XOR/NOT circuit with dyadic marginals, using exact rationals (script /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/tseitin_check.py). The cube sum equals p exactly (3/8). Individual degrees are fanout+1 in the constraint polynomial and up to fanout+2 in the full summand. The sum-check error bound (#vars)*d/|F| is the standard one.

prop:interactive(b): the Goldwasser-Sipser constants are fine. With pairwise hashing into 2^k ~ 2K buckets, acceptance is at least 3/8 when |S| >= K and at most 1/(2c) when |S| <= K/c; this is a constant gap, amplifiable by parallel repetition.

Citations checked: lfkn1992 (JACM 39(4)), gs1986 (STOC'86 pp. 59-68), bhz1987 (IPL 25(2)) and bgm2006 (JCSS 72(6)) have correct metadata and attribution.

No repository file was edited. Scratch scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad.

## Findings

### 1. [major] sec-limits.tex, Remark after thm:blackbox: 'so the theorem also holds for white-box verifiers that look at $C$ only through evaluations and its size'

**Problem.** As stated this is false. The coupling argument compares runs on C and on C or [Ax=b], but these circuits have different sizes, and the size of the gadget even depends on the Hamming weight of A. So a verifier that reads |C| sees different inputs and the runs are not coupled. Counterexample: a circuit with s wires reads at most s variables, so p is in {0} union [2^{-s}, 1]. Let V, on seeing |C| = s <= 20, query ceil(2^s ln(1/delta)) uniform points and output U = 0 if all evaluations are 0, else U = 1; for larger s, V outputs U = 1. V is delta-sound for upper bounds on every circuit. On the 3-wire circuit x1 AND NOT x1 it outputs U = 0 < 2^{-k} with probability 1 using T = 8 ln(1/delta) queries, which contradicts delta + T*2^{-k} for k = 20.

**Proposed fix.** Restate the claim with size padding. Build the gadget G_{A,b} = [Ax=b] with a topology that does not depend on (A,b): for example, row i is XOR_j (x_j AND a_ij) XOR b_i, with a_ij and b_i as constant leaves. Then: for every C and pi, the circuit C' = C OR (0 AND G_{A0,b0}) computes the same function, has size |C| + O(nk), and Pr[V(C',pi) outputs U < 2^{-k-1}] <= delta + T*2^{-k} + 4*2^k*sum_x D(x)^2. In words, the lower bound holds for some circuit for f of size |C| + O(nk), not for every circuit computing f.

### 2. [minor] sec-limits.tex, Remark after thm:blackbox: 'The same argument works for any distribution $D$ with enough min-entropy'

**Problem.** The resulting inequality is not stated, and it differs from the theorem. The planted mass is only guaranteed to be at least 2^{-k-1}, not 2^{-k}. The averaging over (A,b) must also exclude the bad event D(H) < 2^{-k-1}, which adds a term. The Chebyshev constant itself is correct; I verified it numerically.

**Proposed fix.** State it explicitly: if V is delta-sound for upper bounds under D, then for every f, pi and k, Pr[V^f(pi) outputs U < 2^{-k-1}] <= delta + T*2^{-k} + 4*2^k*sum_x D(x)^2. Also note that sum_x D(x)^2 <= 2^{-H_inf(D)}; collision entropy is enough. For product D, sum_x D(x)^2 = prod_i (q_i^2 + (1-q_i)^2).

### 3. [minor] sec-limits.tex, thm:blackbox, last claim ('to output an upper bound below $\eta$ ... needs $T\ge(1-\delta-\delta')/(2\eta)$') and its proof ('so that $\eta\le 2^{-k}<2\eta$')

**Problem.** (i) There is a missing hypothesis. The choice k = ceil(log2(1/eta)) - 1 needs k <= n, which means eta >= 2^{-(n+1)}. Without it the claim is false: for f = 0, the verifier that queries all 2^n points and outputs the exact p is 0-sound, and it outputs U = 0 < eta for every eta > 0 with T = 2^n. That contradicts T >= (1-delta)/(2*eta) whenever eta < 2^{-n-1}. (ii) The chosen k actually satisfies eta < 2^{-k} <= 2*eta, not eta <= 2^{-k} < 2*eta: when log2(1/eta) is an integer, 2^{-k} = 2*eta. This slip is harmless, because only 2^k >= 1/(2*eta) is used.

**Proposed fix.** Write 'In particular, for 2^{-(n+1)} <= eta <= 1 ...', or state the bound as T >= (1-delta-delta')*min{1/(2*eta), 2^n}. In the proof, write 'so that eta < 2^{-k} <= 2*eta'.

### 4. [minor] sec-limits.tex, proof of prop:worstcase(b): 'On $y=G(s)$ it fires with probability at least $1-\delta$' and 'The advantage is at least $1-2\delta-2^{-k}>1/2$'

**Problem.** Completeness (tightness with probability at least 1-delta) and soundness (p in [L,U] with probability at least 1-delta) are separate events. L = 0 happens when the output is not tight, or when it is tight and equal to [0,0] (which excludes p > 0). So the firing probability is only at least 1-2*delta. Example: a procedure that outputs [0,1] with probability delta, [0,0] with probability delta, and [p,p] otherwise is delta-sound and complete, and fires with probability exactly 1-2*delta. The correct advantage bound is 1 - 3*delta - 2^{-k}.

**Proposed fix.** Replace 1-delta with 1-2*delta and the advantage bound with 1 - 3*delta - 2^{-k}. This is at least 5/8 - 2^{-k} >= 1/2 for delta <= 1/8 and k >= 3, which still contradicts the strict hypothesis 'advantage < 1/2'. Add 'k >= 3' to the statement.

### 5. [minor] sec-limits.tex, proof of prop:worstcase(b): 'fixing $A$'s coins to their best value gives a circuit of size $t+\poly(k)$, so $t\ge T(k)-\poly(k)$'

**Problem.** Simulating a time-t algorithm by a circuit costs O(t log t) for multitape Turing machines (Pippenger-Fischer) or t*polylog(t) for RAMs, not t + poly(k). Also, t is A's running time only on the family {C_{G(s)}}, so on uniform y the simulation must be truncated; the proof does not mention this. If t is an expected running time, a Markov step is also needed.

**Proposed fix.** Truncate A after t steps and output 'no fire'. Truncation only lowers the firing probability on uniform y, so the bound 2^{-k}+delta still holds. Then conclude t*log t >= T(k) - poly(k), i.e. t >= (T(k) - poly(k))/O(k), since log t = O(k) in the relevant range. Alternatively, measure A's cost as circuit size. The application with T(k) = 2^{(1-o(1))k} is unaffected.

### 6. [minor] sec-limits.tex, prop:worstcase(a), statement '(for any fixed $\eps<1$)' and proof 'If $p=0$, a tight interval must be $[0,0]$ ... errs with probability at most $\delta$'

**Problem.** Three problems. (i) A tight interval need not contain p, so 'if p = 0 a tight interval must be [0,0]' is false as written; it should be a tight interval containing 0. (ii) On satisfiable formulas the error bound is 2*delta (not tight, or soundness failure), not delta; the same example as for part (b) attains it. (iii) 'for any fixed eps<1' is ambiguous: it can be read as requiring completeness for every eps < 1. The proof works for any single finite eps > 0.

**Proposed fix.** Write: 'If p = 0, L > 0 implies p not in [L,U] (probability at most delta). If p > 0 (so p >= 2^{-n}), L = 0 implies the output is not tight or excludes p (probability at most 2*delta). Run with delta = 1/8, so the error is at most 1/4.' In the statement write '(for some fixed eps > 0; any finite eps works)'.

### 7. [minor] sec-limits.tex, SBP paragraph: 'a system complete for lower bounds within a constant factor on all circuits is exactly a proof that the class $\SBP$ of \cite{bgm2006} is contained in $\MA$'

**Problem.** The exact equivalence is with the promise classes, prSBP in prMA; sec-part2.tex (Universality paragraph) states it that way. Such a system implies SBP in MA for languages, but the converse is not known for language classes, so 'exactly' is wrong. Also, the direction 'system implies prSBP in prMA' needs the SBP acceptance gap amplified past the constant c (by AND of copies) when c >= 2. That should be said, because the canonical prSBP gap is a factor of 2.

**Proposed fix.** Write: 'A system complete for lower bounds within a constant factor on all circuits exists iff prSBP is contained in prMA (amplify the SBP gap by AND-ing copies; conversely, send the scale j with an MA proof that p >= 2*2^{-j}). In particular it would give SBP in MA.' Optionally add that a constant factor upgrades to (1+eps) by tensor powers C^{(m)} with m = O(1/eps).

### 8. [minor] sec-limits.tex, prop:interactive(a): 'For every circuit $C$ ... $O(n+|C|)$ rounds and soundness error $O((n+|C|)\,d/|\F|)$, where $d$ bounds the individual degrees of the arithmetised Tseitin constraint polynomial'

**Problem.** (i) The setting allows threshold gates with arbitrary (binary-encoded) weights, and |C| counts wires, not weight bits. The verifier's final step evaluates the gate constraints at random field points. For the multilinear extension of [sum_j w_j y_j >= t], that evaluation is #P-hard in general: at (1/2,...,1/2) it equals #knapsack/2^f. So the verifier is not polynomial time 'for every circuit' unless threshold gates are first compiled into AND/OR/NOT/XOR subcircuits. That raises the variable count, and hence the number of rounds, to O(n + poly(|C|, log W)). (ii) Exact recovery of p requires odd characteristic and |F| > 2^B, where B is the total number of denominator bits of the dyadic q_i, because 2^B*p is an integer in [0, 2^B]. This is not stated. (iii) d must bound the individual degree of the whole summand D(x)*prod(constraints)*w_out, which is up to fanout+2 by my exact check, not just the constraint polynomial. This is absorbed in the O(.) when d >= 1.

**Proposed fix.** Add: 'after replacing threshold gates by AND/OR/NOT/XOR subcircuits (size poly(|C|, log max|w|)); rounds O(n+|C'|); work over a prime field with |F| > 2^{B+1}'. Note that d <= 2 + max fan-out <= |C|+2, so the error is O((n+|C'|)*|C'|/|F|), which is exponentially small with poly(|C|)-bit field elements.

### 9. [minor] sec-limits.tex, paragraph after prop:interactive: 'Applying the Fiat--Shamir transform to (a) gives a one-message argument that is only computationally sound' (and sec-setting.tex: 'interaction or computational soundness would trivialise the problem')

**Problem.** The claim is true in the random-oracle model, or heuristically with a fixed hash. In the plain model without a common reference string, computational soundness against non-uniform provers coincides with statistical soundness for one-message systems: a non-uniform cheater can hardwire any accepting pi for a fixed false instance. So the claim that computational soundness trivialises the problem holds only with a random oracle or a trusted setup. As far as I know, standard-model Fiat-Shamir soundness for #P-size sum-check is not known from standard assumptions; correlation-intractable hashing needs efficiently searchable bad challenges, and here the bad challenges are roots of g_i - h_i where h_i is #P-hard.

**Proposed fix.** Write: 'Applying Fiat-Shamir to (a) gives, in the random-oracle model (or with a trusted hash key, heuristically), a one-message argument that is only computationally sound ...'. Make the same qualification in sec-setting.tex.

### 10. [minor] sec-limits.tex, prop:interactive(b): 'Two-round public-coin protocols certify $p\ge L$ within a constant factor for every circuit'

**Problem.** The distribution D is unspecified. Goldwasser-Sipser certifies set sizes, which corresponds to uniform D. For a product D it applies only through the sampler reduction (dyadic marginals) or with a discretisation error. The verifier must also output L/c rather than the claimed value, and needs parallel repetition to bring the soundness error down to delta.

**Proposed fix.** State it as: 'for uniform D (or product D with dyadic marginals, via C composed with S), after parallel repetition, outputting L/c on acceptance'.

### 11. [minor] sec-limits.tex, closing paragraph: 'an argument must contain \emph{deductive} content about the circuit, and can be complete only on a restricted class' (also sec-intro.tex: 'black-box verification of upper bounds is impossible')

**Problem.** Both sentences claim more than is proved. thm:ma is conditional (it assumes coNP is not in MA) and concerns upper bounds only. thm:blackbox rules out black-box certification only below about 1/T, not black-box upper-bound verification in general.

**Proposed fix.** Write '... and, unless coNP is contained in MA, can be complete for upper bounds only on a restricted class'. In the intro, write 'black-box verification of upper bounds below ~1/T is impossible'.

