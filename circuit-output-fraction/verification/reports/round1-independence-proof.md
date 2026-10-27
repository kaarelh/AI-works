# Referee report: independence (proof lens)

**Verdict.** needs major fixes. The mathematical core is correct: the first-order sandwich, the full second-order theorem with (H1)-(H6) and the E_3 bound, and the barrier constant 0.29. The problems are around it. The definition of unateness lets XOR and negative-weight threshold gates through, and with those gates the theorem is false as literally stated. The sample size depends on mu, which is never defined and is unknown to the procedure. The Kotecky-Preiss FPRAS claim has no proof (I checked that it is true). Two of the three triangle-freeness numbers in the text do not follow from the stated theorems.

**What was checked.** Every step re-derived by hand, plus exact-enumeration experiments. Scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad (so_check.py, barrier.py, tri.py, tri_small.py, cex.py).

(1) thm:janson-general sandwich:
- p=prod(1-c_i). The bound c_i<=b_i follows from Harris.
- Boppana-Spencer: c_i >= Pr[B_i F_N | F_R] >= b_i - sum_N Pr[B_iB_j|F_R] >= b_i-d_i. Each step is correct: B_i is independent of F_R, and Harris applies to B_iB_j against F_R.
- 1-b+d <= (1-b)e^{d/(1-b)} holds, and sum_i d_i = Delta over unordered pairs.
- Exact enumeration on 1816 random instances found no violation (arbitrary monotone events, q in [0.02,0.95], supports up to 6, up to 7 events).

(2) The procedure's thresholds:
- With b_hat_i <= 1/3, and rejection when max b > 1/2, the factor Delta/(1-max b) is at most 2 Delta.
- The Delta thresholds eps/64, eps/16 and eps/4 are consistent.
- If |log M_hat - log M| <= eps/4 and p is in [M, M e^{eps/2}], the interval [M_hat e^{-eps/4}, M_hat e^{3eps/4}] contains p.
- The variance of log M_hat is sum b_i/((1-b_i)N) <= 2mu/N, and the quadratic remainder is O(mu/N) once b_hat <= 1/3.
- The stated cost is a valid (loose) upper bound.

(3) thm:second-order:
- I re-derived the formula for c_i in terms of nu, and each of (H1)-(H6), including that the events in R'' are independent of B_i and B_j and that Pr[F_R] <= Pr[F_{R''}].
- Both Bonferroni directions, both cases C_i >= Theta'_i and C_i < Theta'_i (using C_i >= 0 and X >= 0 from Harris), and both halves of the E_3 derivation are correct. No errors found.

(4) prop:pairwise-barrier:
- I enumerated p_stars and p_triangles directly; the difference is q^3(1-q).
- The minimum of log(1+q^3(1-q)/(1-3q^2+2q^3))/(3q^3) is 0.29391 at q=0.2790, so 0.29 is correct; it also holds on all of (0,1).
- The dependency graphs and the pairwise data match.

(5) Mobius expansion and interface DP:
- mu(T)=0 for any T that is disconnected in G.
- The interface-DP identity is correct, and interval arithmetic is sound because the expression is a polynomial with nonnegative coefficients.
- The Kotecky-Preiss condition b <= (2e^3 d)^{-r} is sufficient. I derived it by bounding cluster weights with Finner's inequality.

(6) Triangle-freeness example: I checked my counting formulas by brute force at N=11 for three different event orders, then evaluated them at N=10^4.

(7) Bibliography entries for Boppana-Spencer 1989, Kotecky-Preiss 1986, Mousset-Noever-Panagiotou-Samotij 2020 and Harris 1960 are correct, and the description of what MNPS proves is accurate.

## Findings

### 1. [major] sec-part1.tex, sec:independence, definition 'Call C unate if there is a sign pattern such that every path from x_v to the output has the same parity of negations ... checked syntactically'; used as the hypothesis of thm:janson-general

**Problem.** The Setting (sec-setting.tex) allows XOR gates and threshold gates [sum w_j y_j >= t] with arbitrary weights. The parity of NOT gates along a path certifies nothing through such gates: x XOR y, or [-x >= 0] (which is NOT x), has no negation on any path. Under the literal definition, both the sandwich and the procedure's soundness fail. Concrete counterexample, all variables uniform: A_1 = x OR y, A_2 = [-x>=0] OR y'. No path contains a NOT gate, so C is 'unate' by the definition. Then b_1 = b_2 = 1/4, D(B_1B_2) = 0 so Delta = 0, M = 9/16, but p = 1/2 < M. The procedure passes both pre-tests (b_hat <= 1/3 with high probability, and Delta_hat = 0 always) and outputs an interval around 9/16 of log-width eps, which misses p whenever eps < 0.47. With M' disjoint copies, log(M/p) = 0.118 M'.

**Proposed fix.** Define unateness on the NNF: every input variable occurs in literals of only one polarity. Equivalently, compute path parities in a circuit where XOR gates make their inputs binate and threshold gates with negative weights count as negations. Say explicitly that this is the check run in O(|C| n) time.

### 2. [major] sec-part1.tex, thm:janson-general, 'estimate every b_i with O((mu+1)eps^{-2}) independent samples' and the proof's 'N=O((mu+1)/eps^2)'

**Problem.** mu is never defined in this subsection; elsewhere in sec-part1 mu denotes a pilot hit count. Presumably mu = sum_i b_i. It is unknown to the procedure, yet soundness on every circuit needs N >= c mu/eps^2. With smaller N, the standard deviation of log M_hat, about sqrt(mu/N), exceeds eps/4, and the median trick does not help because each repetition fails with probability above 1/2. Simulation with m=10^4 independent events, b_i=0.1, eps=0.1 (so mu=1000): N=100/eps^2 gives |log M_hat - log M| > eps/4 in 92% of runs. As written, the procedure's soundness depends on an unspecified choice of N.

**Proposed fix.** Define mu = sum_i b_i. Make N computable: either use mu <= m (N = O((m+1)/eps^2)), or take an upper confidence bound from the pre-test samples. With N_0 >= 10 ln(1/delta) samples per event and mu_hat_0 = sum b_hat_i, Bernstein (independent summands bounded by 1/N_0, variance <= mu/N_0) gives mu <= max(2 mu_hat_0, 10 ln(1/delta)/N_0) with probability 1-delta. Then use N = C(2 mu_hat_0 + 1)/eps^2 with C about 100; my simulation shows that N = 4 mu/eps^2 still fails 62% of the time. Also state that the b_hat_i entering M_hat are the gated ones (b_hat_i <= 1/3), so the Taylor remainder bound applies.

### 3. [major] sec-part1.tex, 'Beyond pairs' (ii): 'a Kotecky--Preiss argument certifies the tail when max_i b_i <= (2e^3 d)^{-r} ..., giving an FPRAS for bounded d'

**Problem.** An FPRAS with a specific constant is asserted with no proof. The non-obvious ingredient is missing. Without monotonicity, the cluster weights |w(gamma)| = Pr[intersection over gamma of B_i] cannot be bounded through correlation inequalities; the exponent r needs Finner's generalized Hoelder inequality, which gives Pr[intersection over gamma of B_i] <= prod_{i in gamma} b_i^{1/r} when every variable lies in at most r events. The precision issue is also not addressed: each mu(T) is an alternating sum of 2^{|T|} logarithms of estimated probabilities. 'd the degree' and 'r the number of events per variable' should say maximum. I checked the claim and it is true.

**Proposed fix.** Add a proof sketch:
- Write the polymer representation Pr[AND A_i] = sum over compatible families of connected gamma of prod w(gamma), with w(gamma) = (-1)^{|gamma|} Pr[intersection over gamma of B_i], where polymers are compatible when they are disjoint and non-adjacent in G. Then mu(T) is the sum of the clusters whose support is exactly T.
- Bound |w(gamma)| <= beta^{|gamma|} with beta = (max b)^{1/r}, by Finner.
- Apply Kotecky-Preiss with a(gamma) = |gamma| and decay g(gamma) = |gamma|. A connected set of size s containing a given vertex is one of at most (ed)^{s-1}, so the per-vertex sum is at most sum_s (ed)^{s-1}(e^2 beta)^s <= 2^{-s}/(ed) summed, i.e. <= 1/(ed), when beta <= 1/(2e^3 d). Multiplying by (d+1)|gamma| gives (2/e)|gamma| < a(gamma).
- Hence the tail over clusters of size >= s is at most m e^{-s}; truncate at s = ln(m/eps).
- There are m(ed)^s = poly(m/eps) connected sets T of size <= s for bounded d. Each needs the probabilities Pr[AND_{U subset of T} A_i] to additive accuracy eps/(m(2ed)^s), which costs poly(m/eps) samples.
- Alternatively, downgrade the sentence to a remark without the FPRAS claim.

### 4. [minor] sec-part1.tex, after thm:janson-general: 'triangle-freeness of G(N,q) at N=10^4, mu=10, the window is e^{+-0.023}'; Second order paragraph: 'the first-order window is e^{2.1} while the second-order one is e^{+-0.055}'

**Problem.** These numbers do not follow from the paper's theorems, and they mix conventions. With mu = C(N,3) q^3, the unordered Delta = C(N,2)C(N-2,2) q^5, as used in thm:janson-general, is 0.0230 at mu=10 and 1.067 at mu=100.
- At mu=10 the window ratio is e^{0.023}, i.e. e^{+-0.0115} about the geometric mean, not e^{+-0.023}.
- At mu=100 it is e^{1.07}, not e^{2.1}; 2.13 is the ordered-pair Delta.
- For E_3: sum_i Theta'_i is order-independent and equals the sum over connected triples, (7/12) N^5 q^7 + N^4 q^6/6 = 0.01831. Theta_i and beta_i C_i contribute about 1e-5 each, and (1-beta)(1-b) is about 1. So E_3 = 0.0183, the window is e^{+-0.018}, and the actual sandwich ratio is about e^{0.018}. The text says +-0.055, three times larger. (I checked the counting formulas by brute force at N=11 for three orders.)
- No script in experiments/ reproduces any of these numbers.
- Related: thm:janson defines Delta over ordered pairs with a factor 1/2, while thm:janson-general uses unordered pairs; the same symbol has two meanings.

**Proposed fix.** Replace with 'window e^{0.023}' at mu=10, and with 'first-order window e^{1.07}, second-order e^{+-0.018}' at mu=100. Use one Delta convention throughout (unordered pairs, as in thm:janson-general, and restate thm:janson as e^{Delta/(1-eps_0)}). Add the script that computes these numbers to experiments/.

### 5. [minor] sec-part1.tex, thm:janson-general, output interval [M_hat e^{-eps/4}, M_hat e^{3eps/4}] and 'It is complete when ...'

**Problem.** The output interval has ratio U/L = e^{eps} > 1+eps, so it is not 'tight' in the sense of def:sound (U <= (1+eps)L). The completeness claim is therefore off by a constant in eps.

**Proposed fix.** Run the procedure with eps' = ln(1+eps), which is at least eps/2 for eps <= 1: output [M_hat e^{-eps'/4}, M_hat e^{3eps'/4}] with Delta thresholds eps'/16 and eps'/64. Alternatively, state completeness as U <= e^{eps} L.

### 6. [minor] sec-part1.tex, thm:janson-general, 'estimate Delta by sampling dependent pairs' and the cost bound

**Problem.** The Delta estimator and its error analysis are not given, so the claimed pre-test guarantees (reject when Delta > eps/4, accept when Delta <= eps/64) and the |E(G)| eps^{-1} cost term are unsupported. Estimating each pair separately with Hoeffding at confidence delta/|E| would need far more samples. 'Evaluations' with a sum_i |A_i| factor is really gate-operation count.

**Proposed fix.** Specify the estimator: estimate each D(B_iB_j), (i,j) in E(G), from N_Delta = ceil(C eps^{-1} ln(3/delta)) fresh samples, and set Delta_hat = sum of the estimates. Its variance is <= Delta/N_Delta and its summands are bounded by 1/N_Delta, so Bernstein gives:
- if Delta <= eps/64, P(Delta_hat > eps/16) <= exp(-9 N_Delta eps/256);
- if Delta > eps/4, P(Delta_hat <= eps/16) <= exp(-9 N_Delta eps/128).
The pre-test b_hat_i <= 1/3 needs O(log(m/delta)) samples per event, with a union bound. The cost is sum_i |A_i| deg_G(i) N_Delta, which is at most the stated bound. Say 'gate evaluations' or 'time'.

### 7. [minor] sec-part1.tex, sec:independence, 'after flipping the negative variables, every B_i is increasing'

**Problem.** Orientation slip. Flipping the variables whose paths have odd parity makes C, and hence every A_i (the top AND-tree has no negations), increasing, so every B_i = NOT A_i becomes decreasing, not increasing. Harris needs only a common direction, so nothing breaks, but the sentence is literally wrong.

**Proposed fix.** Write 'after flipping the variables that occur positively (or: after a global flip), every B_i is increasing'. Alternatively, note that Harris applies to any family of events that are all monotone in the same direction.

### 8. [minor] sec-part1.tex, Second order paragraph ('gives |log p - log M_2| <= E_3') versus appendix.tex thm:second-order

**Problem.** The main text omits the hypothesis beta_i = sum_{j in N_i} b_j < 1, which the appendix assumes. It also does not say that E_3 carries the denominators (1-beta_i)(1-b_i), so 'a sum of third-order quantities' is only accurate when every beta_i is bounded away from 1.

**Proposed fix.** Add 'when every beta_i = sum_{j<i, j~i} b_j < 1', and write E_3 = sum_i (Theta_i + Theta'_i + beta_i C_i)/((1-beta_i)(1-b_i)), or refer to it explicitly.

### 9. [minor] sec-part1.tex, 'Beyond pairs' (i), interface dynamic programming

**Problem.** The identity p = sum_z D_Z(z) prod_i a_i(z_{I_i}) and its soundness with interval arithmetic are correct: the expression is a polynomial with nonnegative coefficients in the table entries, and a union bound is taken over the sum_i 2^{|I_i|} entries. But no completeness condition or cost is stated, and the supporting experiment (a chain of 300 modules, p about 3e-115, log error < 0.06) has no script in experiments/.

**Proposed fix.** State the precision bookkeeping. If every a_i(y) is within e^{+-eta_i}, the output is within e^{+-sum_i eta_i}, so eta_i = eps/m. Each entry then costs O(m^2 eps^{-2} log(sum_i 2^{|I_i|}/delta)/a_i(y)) samples, and the time is exponential in the interface treewidth and in max|I_i|. The method is therefore complete when all a_i(y) are at least 1/poly and those widths are O(log|C|). Add the chain experiment script.

### 10. [minor] sec-intro.tex, item on thm:janson-general: 'pin p to within e^{Delta} of ... using only additive estimates of non-rare quantities'

**Problem.** This overstates thm:janson-general in two ways. The window there is e^{Delta/(1-max b_i)}, not e^{Delta}. And M_hat needs additive accuracy on log M, i.e. relative accuracy on a possibly exponentially small product, costing Theta(mu/eps^2) samples per event; the proof itself says 'Only M needs relative accuracy'.

**Proposed fix.** Write 'within e^{Delta/(1-max_i b_i)}', and say that the cost is linear in mu (about log(1/p)) rather than relying on 'additive estimates' alone.
