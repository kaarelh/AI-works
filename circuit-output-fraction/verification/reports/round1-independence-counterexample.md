# Round 1 referee report: independence (counterexample lens)

**Verdict.** Sound with minor fixes, plus two major gaps in the estimation procedure of thm:janson-general. The mathematics I was assigned is correct: the first-order sandwich, (H1)-(H6), both bounds of thm:second-order, the E_3 derivation, the formulas and the 0.29 constant of prop:pairwise-barrier, the interface-DP identity and the Möbius identity. The two major gaps: (1) the definition of "unate" ignores the XOR and threshold gates that sec:setting allows, so "sound on every circuit" is false as written; (2) the sample size depends on mu, which is never defined or estimated. Some quoted numbers are off by a factor 2 in the exponent.

**What was checked.** Proofs, by hand:
- thm:janson-general. The Harris lower bound; the Boppana-Spencer step c_i >= b_i - d_i (including c_i >= Pr[B_i F_N | F_R] and the Harris bound Pr[B_iB_j | F_R] <= D(B_iB_j)); the step 1-b+d <= (1-b)e^{d/(1-b)}; and sum_i d_i = Delta over unordered pairs.
- The procedure's bookkeeping. If |log Mhat - log M| <= eps/4, max b <= 1/2 and Delta <= eps/4, then p lies in [Mhat e^{-eps/4}, Mhat e^{3eps/4}]. The pre-test thresholds (1/3 against 1/2 and 1/4; eps/16 against eps/4 and eps/64) leave the needed gaps. The Delta test costs O(|E| eps^{-1} log(1/delta)) pair samples.
- thm:second-order. The identity for c_i, each of (H1)-(H6), both Bonferroni directions, the case split C_i >= Theta'_i versus C_i < Theta'_i (including dividing a negative X by nu(F_N) >= 1-beta_i), and both sides of the E_3 bound.

Numerical checks (scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad):
- stress2.py, exact enumeration on about 1,020 instances. Arbitrary monotone DNF events, q in (0.01, 0.99), duplicated events, padded syntactic supports, random orders. It checks each of (H1)-(H6) on its own, both sandwiches, and the E_3 bound. 0 violations.
- minmatters.py: the "min" remark holds. In 74 of 2,057 instances the product without the min exceeds p.
- barrier.py: the star and triangle probabilities, and min_{q<=1/2} f = 0.29391 at q = 0.2790 (f(1/2) = 0.314, f -> 1/3 as q -> 0).
- barrier_e3.py: E_3 >= |log p - log M2| on the star and triangle instances, and their M2 values are equal.
- triangles.py: closed-form Delta and E_3 for triangle-freeness in K_{10^4}.
- dp_mobius.py: the interface-DP identity, the Möbius identity (mu(T) = 0 for disconnected T; the terms sum to log p), and Finner's bound D(AND_T B_i) <= prod_i b_i^{1/r}, on 300 random non-monotone instances. 0 mismatches.
- xorcx.py: the gate-type counterexample.
- proc.py: the error of log Mhat as a function of the sample size N and mu.

Citations: Boppana-Spencer 1989, Kotecký-Preiss 1986 and Mousset-Noever-Panagiotou-Samotij 2020 are correctly attributed.

Also correct:
- Repeated children (duplicate A_i) and constant sub-circuits are handled.
- The KP condition max b <= (2e^3 d)^{-r} is sufficient once the polymer weights are bounded via Finner. With a(T) = |T|, the KP left-hand side is <= 0.17|T|.

## Findings

### 1. [major] sec-part1.tex, sec:independence, definition of unate ("every path from x_v to the output has the same parity of negations") as used by thm:janson-general ("The following procedure is sound on every circuit")

**Problem.** sec:setting allows XOR gates and threshold gates with arbitrary weights. The unate definition counts only negation gates, so XOR gates and negative weights pass the syntactic check, the B_i need not be increasing, and both the Harris bound M <= p and the soundness claim fail. Counterexample (threshold version): take K disjoint copies of A1 = [-x - y >= -1] and A2 = [x - z >= 0] with x, y, z uniform. Neither contains a negation gate. Then B1 = x AND y, B2 = (NOT x) AND z, b_i = 1/4 (passes the b-hat <= 1/3 test), D(B1 B2) = 0 (so Delta = 0), and p/M = (8/9)^K. A version with XOR gates and q = 1 constant inputs gives the same numbers. At K = 50, log(p/M) = -5.89 (xorcx.py), so the output interval [Mhat e^{-eps/4}, Mhat e^{3eps/4}] misses p with probability close to 1.

**Proposed fix.** Define unateness for {AND, OR, NOT}-circuits plus threshold gates with nonnegative weights, counting a negative weight on an edge as a negation. Any path through a XOR gate or an opaque gate disqualifies the circuit. Equivalently: no variable occurs in both polarities in the NNF of C, where XOR expands into both polarities. The check stays O(|C| n).

### 2. [major] sec-part1.tex, thm:janson-general, "estimate every b_i with O((mu+1)eps^{-2}) independent samples", and its proof

**Problem.** mu is never defined in the theorem; from context it is sum_i b_i. It is not known in advance, yet soundness depends on N growing with mu. The standard deviation of log Mhat is about sqrt(mu/N). Simulation with m = 2000, b_i = 0.05 (mu = 100), eps = 0.2: with N = 16/eps^2, i.e. ignoring mu, P(|log Mhat - log M| > eps/4) = 0.90. The procedure as stated cannot be run, and with any fixed N it is not sound. Separately, log(1 - b-hat_i) equals -infinity with positive probability, so the 'total variance O(mu/N)' argument only works on the event that all b-hat_i <= 1/3.

**Proposed fix.** State mu = sum_i b_i and add a pilot stage. Draw N_0 = C log(m/delta) samples per event and set mu-hat_0 = sum_i b-hat_i^(0). N_0 * mu-hat_0 is a sum of independent Bernoullis with mean N_0 mu, so Chernoff gives mu-hat_0 >= mu/2 with probability 1 - delta/4 whenever mu >= 8 ln(4/delta)/N_0; otherwise mu < 1. Then use N = C(2 mu-hat_0 + 1)/eps^2 fresh samples per event, so N >= C(mu+1)/eps^2 with high probability. Do the Taylor and Chebyshev analysis on the event that all b-hat_i <= 1/3 (where log(1 - b) is 3/2-Lipschitz with bounded second derivative), and take a union bound over the pilot, the median step and the two pre-tests.

### 3. [minor] sec-part1.tex, thm:janson-general, output interval [Mhat e^{-eps/4}, Mhat e^{3eps/4}] and the completeness claim

**Problem.** The output's U/L ratio is exactly e^eps > 1 + eps, so it never meets the tightness condition U <= (1+eps)L of def:sound, and the procedure is never 'complete' in that sense. Also, U can exceed 1, e.g. when all b_i = 0, but def:sound requires [L,U] to lie in [0,1].

**Proposed fix.** Run the procedure with eps' = ln(1+eps), which is >= eps/2 for eps <= 1, in place of eps, and output [Mhat e^{-eps'/4}, min(1, Mhat e^{3eps'/4})]. The completeness thresholds become Delta <= eps'/64, a constant-factor change.

### 4. [minor] sec-part1.tex, sec:independence: "after flipping the negative variables, every B_i is increasing"

**Problem.** This is backwards. If x_v is negative (odd parity), A_i is decreasing in x_v, so B_i is already increasing in it. Flipping the negative variables makes every A_i increasing and every B_i decreasing. The proof of thm:janson in sec-envelopes correctly flips the positive variables.

**Proposed fix.** Say "after flipping the positive variables, every B_i is increasing". Alternatively, note that Harris applies equally when all B_i are decreasing.

### 5. [minor] sec-part1.tex, after thm:janson-general and in the paragraph 'Second order': "for triangle-freeness of G(N,q) at N=10^4, mu=10, the window is e^{+-0.023}" and "the first-order window is e^{2.1} while the second-order one is e^{+-0.055}"

**Problem.** The first-order windows are overstated by a factor 2 in the exponent, apparently because of the two Delta conventions: thm:janson uses Delta = 2 sum d_i (ordered pairs), thm:janson-general uses Delta = sum d_i (unordered pairs). Exact counts: at mu = 10, Delta = C(N,2)C(N-2,2)q^5 = 0.0230, so the window is [M, M e^{0.023}], i.e. e^{+-0.0115} about the geometric mean, not e^{+-0.023}. At mu = 100, Delta = 1.067, so the window is e^{1.07}, not e^{2.1}. The e^{+-0.055} figure is the order-free upper bound on E_3 (0.0550), valid for every order; a random order gives E_3 of about 0.018. No script in experiments/ reproduces these numbers, nor the '300-module chain' interface-DP result.

**Proposed fix.** Write e^{1.07} for mu = 100 and [M, M e^{0.023}] for mu = 10, and state that 0.055 bounds E_3 for every order. Use a single Delta convention across thm:janson, thm:janson-general and prop:pairwise-barrier. Add the scripts behind the triangle-freeness and chain-of-modules numbers to experiments/.

### 6. [minor] sec-part1.tex, thm:janson-general (last inequality, M exp(Delta/(1-max_i b_i))) and appendix.tex, thm:second-order (the E_3 bound and (H1), (H5), (H6))

**Problem.** If some b_i = 1 (for example a constant-0 A_i), Delta/(1-max b) and E_3 involve 0*infinity or 0/0. If b_i = 0, (H1), (H5) and (H6) divide by b_i. The main-text statement of the second-order bound also omits the appendix's hypothesis beta_i < 1.

**Proposed fix.** Add the hypotheses max_i b_i < 1 (if some b_i = 1 then p = M = 0; the procedure already declines) and beta_i < 1 for all i. Note that if b_i = 0 then c_i = 0 and the i-th factor is exactly 1.

### 7. [minor] sec-part1.tex, thm:janson-general: "at a cost of O(sum_i |A_i| ...) evaluations, independent of p"

**Problem.** In the complete regime the cost is linear in mu = Theta(log(1/p)), so it is not independent of p. Also, the factor sum_i |A_i| makes the quantity gate operations, not circuit evaluations.

**Proposed fix.** Say "polynomial in log(1/p) (linear in mu), with no 1/p dependence", and "gate operations" in place of "evaluations".

### 8. [minor] sec-part1.tex, paragraph 'Beyond pairs' (ii): "a Kotecky-Preiss argument certifies the tail when max_i b_i <= (2e^3 d)^{-r} ... giving an FPRAS for bounded d"

**Problem.** This is unproved, and the step that explains the exponent r is missing. The claim covers non-monotone events, so the polymer weights D(AND_{i in T} B_i) must be shown to decay like (max b)^{|T|/r}. That needs Finner's generalized Hölder inequality (each variable lies in at most r supports), which holds for arbitrary events under a product measure; I checked it numerically. The definitions of d and r (maximum degree; maximum number of events per variable) are also loose. The logs in the Möbius terms need P(U) > 0, which follows from KP convergence but is not stated.

**Proposed fix.** Add a short argument. Write p as a polymer sum over pairwise non-adjacent connected sets T with weights (-1)^{|T|} D(AND_T B_i), bounded by (max b)^{|T|/r} via Finner. Verify KP with a(T) = |T|: the left-hand side is <= (d+1)|T| sum_s (ed)^{s-1}(2e^3 d)^{-s} e^s <= 0.17|T|. Identify mu(T) with the sum of clusters whose support is T. Truncate at |T| = O(log(m/eps)), giving m(ed)^{O(log(m/eps))} terms, each needing additive estimates of non-rare log P(U).

### 9. [minor] sec-part1.tex, paragraph 'Second order': "in a regime where the local-lemma counting conditions fail"; sec-intro.tex and README: "pin p to within e^{Delta} of the independence estimate"

**Problem.** (a) In the triangle example the symmetric LLL existence condition holds easily: e*b*(d+1) is about 4.9e-5. What fails are the algorithmic counting and sampling conditions (b*d^c <~ 1 for c around 5-7) and the KP condition of (ii) with r = N-2. As written, the claim is vague. (b) thm:janson-general gives e^{Delta/(1-max b)}, or prod_i(1 + d_i/(1-b_i)), not e^{Delta}. Under the procedure's own pre-test (max b <= 1/2) this can be e^{2 Delta}.

**Proposed fix.** Name the specific counting conditions that fail. Replace 'within e^{Delta}' with 'within e^{Delta/(1-max_i b_i)}'.

