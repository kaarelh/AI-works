# Referee report: lower-surprise (proof lens)

**Verdict.** needs major fixes. The identity in Proposition prop:proposal and the main inequality of Theorem thm:surprise(a) are correct. Part (b) is underspecified. Under the natural reading that gives "exactly 1.5" it is false, and its proof sketch runs the coupling in the direction that only gives T*2^l, not T. The tightness and "matching lower bound" claims go beyond what is proved, and the soundness of the proposal rule silently assumes the prover's pmf and sampler agree, which the verifier cannot check.

**What was checked.** Scope: sec-part2.tex lines 190-263 (prop:proposal and its special cases, the surprise-accounting cost formula paragraph, thm:surprise (a) and (b) with their proofs, and the closing MDL paragraph). I read these against sec-setting.tex (def:sound, def:argument), sec-envelopes.tex (thm:envelope, lem:K, the dispersion remark) and sec-limits.tex (thm:blackbox), and checked how the results are summarised in sec-intro.tex (lines 24-43, 98-108) and sec-discussion.tex (lines 8-30).

1. prop:proposal: I re-derived the bijection between R* = {r : phi(psi(r)) = r} and X* = {x : psi(phi(x)) = x}, with inverse phi, and the identity E W = sum over x in C^{-1}(1) and X* of min(D(x), tau P_R(phi(x))) <= p. I confirmed it with exact rational arithmetic on 300 random instances (n <= 4, r <= 4, random psi, phi, C, D, P_R, tau), using /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/prop.py. All passed. The same script shows E W = 125 > p = 1/8 when the prover's sampler and pmf disagree.
   - The completeness claim also holds once the omitted Chernoff step is added. Together, tau <= Kp and the coverage hypothesis force tau >= (1 - eps/2)p, so tau/E[W] <= 2K and N = O(K log(1/delta)/eps^2) suffices, giving L >= (1 - eps/2)^2 p >= (1 - eps)p.

2. thm:surprise(a): I re-derived the coupling. It is valid: on the zero function the queries are determined by pi and the coins, a fixed point lies in a uniformly random codimension-k subcube with probability exactly 2^{-k}, and the union over at most 2^l arguments gives T*2^l >= (1 - 2delta)2^k. Adaptivity is handled correctly.

3. thm:surprise(b): I brute-forced the hitting probability max_x Pr[x in S' \ S] for candidate planted families (/tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/fam.py).
   - The overlap family I' = I - {i} + {i'} gives a ratio of exactly 1.5 but hitting probability 1/(2k): 1/8 at k = 4 and 1/14 vs 2^{-7} = 1/128 at k = 7.
   - The "flip one coordinate of I plus k fresh coordinates" family gives a ratio of exactly 1.5 and hitting probability exactly 2^{-k}.

4. Cost formula: I checked it against thm:envelope(iv), thm:sis(c), thm:certenv and prop:calculus.

No repository file was edited.

## Findings

### 1. [major] sec-part2.tex, Proposition prop:proposal ("a seed law P_R on {0,1}^r with computable pmf and an exact sampler ... for every C and every choice of the other objects")

**Problem.** Soundness (E W <= p) requires the sampler's output law to equal the pmf the verifier uses in D(X)/P_R(R). In an argument system both are supplied by the prover, and consistency between a pmf circuit and a sampler circuit is a semantic property the verifier cannot check. If they disagree, the weight can be arbitrarily inflated. Example: n = 3, uniform D, C = 1 only at (1,1,1), a sampler that always outputs seed 0, a claimed pmf P_R(0) = 1/1000, psi(0) = 111, phi consistent with it, tau = 10^6. Then E W = 125 while p = 1/8 (checked with exact rationals). The proposition is fed into thm:pcis-sound as if it held for every argument.

**Proposed fix.** Make the seed law self-certifying, so that the verifier derives both the pmf and the sampler from one object. Examples: (i) autoregressive form, with circuits q_i(r_<i) in [0,1] (rational); the verifier samples r_i ~ Bernoulli(q_i(r_<i)) with its own coins and computes P_R(r) = prod_i q_i^{r_i}(1 - q_i)^{1 - r_i}. Any such q defines a valid law, so no check is needed. (ii) A smooth decomposable probabilistic circuit, whose sampler and normaliser the verifier computes itself. (iii) Uniform seeds. Then state: "for every C, psi, phi, tau and every P_R given in this form". The special cases already listed (autoregressive models, PCs, unproved envelopes via lem:envmass) are all of this kind.

### 2. [major] sec-part2.tex, Theorem thm:surprise(b), statement ("distinguishing C_0 = E and [x_I=b] from C_1 = E and ([x_I=b] or [x_I'=b']) (factor 1.5 apart) needs T >= (1-2delta)D(E)/p")

**Problem.** I, I', b, b' are not quantified, and the claim depends on how S' = [x_I'=b'] is drawn.
- The natural way to get a ratio of exactly 1.5 with consistent subcubes is |I'| = |I| = k, |I and I'| = k-1, b' = b on the overlap, which gives D(S or S') = 1.5 * 2^{-k}. For that family the claim is false. Every point x that agrees with b on I except at one coordinate lies in S' \ S with probability 1/(2k) over the family (brute force: 1/14 vs 2^{-7} at k = 7). A black-box verifier that knows S (S is the explained part of C_0) therefore finds a point of C_1 \ C_0 after O(k log(1/delta)) evaluations, far below D(E)/p = 2^k.
- The statement also needs E to be independent of x_{I and I'}. Otherwise D(E and S' \ S) can be 0, so that C_1 = C_0, or the ratio is not 1.5.
- "p" is ambiguous between p(C_0) and p(C_1).
- The statement needs eps < 1/2 for a tight interval to separate ratios 1.5 apart.

**Proposed fix.** Specify the family. Let D be uniform on (y, x), with E = E(y) depending only on y, S = [x_I = b], |I| = k, and at least 2k x-coordinates. Draw S' = [x_{i0} = 1 - b_{i0}] and [x_J = b''], with i0 in I, J a uniformly random k-subset of the x-coordinates outside I, and b'' uniform. Then p(C_1) = 1.5 p(C_0) exactly for every member, and every fixed point lies in S' with probability <= 2^{-k} = p(C_0)/D(E) (verified by brute force). Alternatively take I' a random (k+1)-subset disjoint from I with b' uniform; the ratio is then 1.5 - 2^{-k-1} and the hitting probability is 2^{-k-1}. With either family, state the bound as T >= (1-3delta)D(E)/p(C_0) for eps < 1/2. See the next finding for the proof direction and the constant.

### 3. [major] sec-part2.tex, proof of thm:surprise(b) ("The same coupling, with C_0 in place of the zero function and the random subcube [x_I'=b'] planted")

**Problem.** In (a), the zero function is the circuit on which soundness is invoked, and the run uses the argument pi_S of the planted circuit. Transcribed literally to (b), soundness is invoked on C_0 with the argument for C_1, which depends on the planted S'. The averaging over S' then has to union-bound over the 2^l arguments and yields only T*2^l >= (1-2delta)D(E)/p, not the l-free bound stated. The l-free bound is false in that direction. An O(k log n)-bit argument for C_1 can name I', b'. The verifier then samples D conditioned on E and S' \ S, sees C = 1, and outputs L > p_0 after O(eps^{-2} log(1/delta)) evaluations, while soundness on C_0 keeps L <= p_0. Distinguishing is cheap.

**Proposed fix.** Run the coupling in the upper-bound direction, as in thm:blackbox. Let pi_0 be the honest argument for C_0; it does not depend on S'.
- On C_0, soundness plus tightness give U <= (1+eps)L <= (1+eps)p_0 < p_1 with probability >= 1-2delta, when eps < 1/2.
- On C_1 with the same string pi_0, soundness gives U >= p_1 with probability >= 1-delta.
- The coupled runs differ only if a query lands in S' \ S. Averaging over S' (each fixed point is hit with probability <= 2^{-k}) gives T*2^{-k} >= 1-3delta. The constant is 1-2delta if completeness is defined to include containment.

State the hypotheses explicitly: V is sound for upper ends on all circuits inside E, and complete (two-sided tight, eps < 1/2) on C_0. Optionally add the lower-bound-direction analogue, T*2^l >= (1-2delta)D(E)/p_0, for l-bit arguments.

### 4. [major] sec-part2.tex, thm:surprise(a), tightness clause ("Each bit of argument buys at most one bit of surprise, and this is tight: revealing j coordinates of S leaves T=O(2^{k-j}eps^{-2}log(1/delta))"); propagated to sec-intro.tex l.104-105

**Problem.** The hypothesis ranges over all subcubes of codimension k, so revealing j coordinates of S costs j(ceil(log2 n) + 1) bits (positions and values), not j bits. The exhibited scheme gives log2 T ~ k - l/(1 + log2 n), and T*2^l ~ 2^k n^j eps^{-2} log(1/delta), against the lower bound (1-2delta)2^k. "One bit per bit, tight" is therefore not established for the stated family. For the bare L > 0 question, near-tightness does hold, but by a different scheme: an explicit (n,k)-universal set (Naor-Schulman-Srinivasan) of size 2^k k^{O(log k)} log n, cut into 2^l blocks, gives T*2^l = 2^k k^{O(log k)} log n. Whether (1-eps)-tight lower bounds can be had at about one argument bit per bit of surprise for the full family is not shown, and plausibly needs about log2(2n/k) bits per coordinate. Smaller point: if "l-bit argument" means length at most l, there are 2^{l+1} - 1 arguments and the bound becomes T*2^{l+1} >= (1-2delta)2^k.

**Proposed fix.** Either (i) restrict the family in (a) to subcubes on a fixed coordinate set I with b ranging over {0,1}^k. The proof is unchanged, since a fixed point lies in a random member with probability 2^{-k}, and revealing j bits of b costs exactly j bits, so the bound becomes exactly tight. Or (ii) keep all codimension-k subcubes and say "tight up to the ceil(log2 n) bits needed to name each revealed coordinate", citing universal sets for near-tightness of the L > 0 question. Also say "arguments of exactly l bits", or replace 2^l by 2^{l+1}.

### 5. [minor] sec-part2.tex, surprise-accounting cost formula ("An envelope argument explains sigma_e = log2(1/D(E)) bits ... verifier time = poly(|pi|,|C|) + O(2^{sigma_u} eps^{-2} log(1/delta)) * (|C|+|E|)")

**Problem.** The formula holds only for deterministic envelopes (subcubes, OBDD, SDD, d-DNNF, affine) sampled exactly from D conditioned on E.
- For a non-deterministic DNNF used through thm:envelope, the sample count is governed by K = Z/p with Z = E_D[phi] (derivations counted with multiplicity), which can exceed D(E)/p exponentially. The paper's own example E = AND_{i<=m}(x_i or y_i) under uniform D has Z = 1 and D(E) = (3/4)^m, so Z/D(E) = (4/3)^m.
- Through thm:sis the count is D(E)/p, but each sample costs 2n FPRAS calls, poly(n, |E|) each, not O(|C|+|E|).
- For several envelopes (thm:certenv) the relevant mass is Lambda = sum_j D(E_j).
- "=" should be "<=": the formula is an upper bound under completeness.
- Dropping the log log K term of thm:envelope(iv) is fine here, because the sample size is written in the argument.

**Proposed fix.** Define sigma_e = log2(1/Z) and sigma_u = log2(Z/p), where Z is the mass of the envelope actually sampled: Z = D(E) for deterministic or FPRAS-guided envelopes, Z = E_D[phi] for thm:envelope, Z = Lambda for unions. Write "verifier time <= poly(|pi|,|C|) + O(2^{sigma_u} eps^{-2} log(1/delta)) * c_s", where c_s is the per-sample cost: |C|+|E| for deterministic envelopes, and |C| + 2n * (FPRAS call cost) for thm:sis.

### 6. [minor] sec-part2.tex, "For a skeleton of independent components (PROD at the top) the second term is sum_lambda 2^{sigma_u(lambda)} ... costs about t 2^{sigma_u/t}"

**Problem.** Combining t leaf intervals at a PROD node by interval arithmetic (prop:calculus) requires each leaf to have ratio 1 + eps/(2t), and the confidence budget must be split delta/t. The second term is therefore O(t^2 eps^{-2} log(t/delta) * sum_lambda 2^{sigma_u(lambda)}). With even spreading this is about t^3 2^{sigma_u/t} eps^{-2} log(t/delta), not t 2^{sigma_u/t}. The qualitative point (sum instead of product) stands. Optimal allocation of point estimates would give (sum_lambda sqrt(K_lambda))^2/eps^2, which is still a factor up to t above sum_lambda K_lambda.

**Proposed fix.** State the second term as O(t^2 eps^{-2} log(t/delta)) * sum_lambda 2^{sigma_u(lambda)} * (per-sample cost), and "about t^3 2^{sigma_u/t}" for even spreading. Alternatively, say explicitly that poly(t, 1/eps, log(1/delta)) factors are suppressed.

### 7. [minor] sec-part2.tex, "Both terms are necessary in the black-box sense" and closing paragraph ("governed by min_pi(|pi| + 2^{sigma_u(pi)}) ... with a sound verifier and a matching lower bound"); same claim in sec-intro.tex l.103-105 and sec-discussion.tex ("with a matching black-box lower bound")

**Problem.** The two halves of thm:surprise address different tasks from the cost formula.
- Part (a) concerns lower-bound certification (L > 0), where arguments are proposals, not envelopes.
- For two-sided or upper bounds in the black-box model, no argument helps at all (thm:blackbox), so the |pi| term is not shown to be "necessary" for envelope arguments.
- In the white-box PCIS model, which the cost formula describes, there is no lower bound on |pi| whatsoever. For example, C an explicit subcube indicator is computed exactly with an empty argument.
- What is proved is: in the black-box model, sigma - log2 T <= l + O(1) for lower bounds (tight only up to the log n naming cost; see the finding on (a)), and T >= ~2^{sigma_u} for two-sided intervals given a certified envelope (after the fixes to (b)).

This is not a matching lower bound for min_pi(|pi| + 2^{sigma_u(pi)}). Also, Hilton's surprise accounting adds bits (|pi| + sigma_u), whereas the cost here is |pi| + 2^{sigma_u}; "of the kind" is acceptable, but "made exact" overstates the correspondence.

**Proposed fix.** Replace "matching lower bound" with something like: "in the black-box model, each bit of argument reduces the number of evaluations needed for a lower bound by at most a factor 2 (thm:surprise(a)), and given a certified envelope, the 2^{sigma_u} sampling term cannot be avoided for two-sided intervals (thm:surprise(b))". Make the same change in sec-intro.tex and sec-discussion.tex.

### 8. [minor] sec-part2.tex, Proposition prop:proposal, completeness clause ("the pairs x with D(x) <= tau P_R(phi(x)) and psi(phi(x))=x carry (1-eps/2)p") and its proof

**Problem.** Four gaps:
- The coverage condition omits the restriction to C^{-1}(1). Read literally ("D-mass of the set of such x"), it can be met by points where C = 0 and then implies nothing.
- "pairs x" is garbled.
- W lies in [0, tau], not [0,1], so the KL/Hoeffding interval applies to W/tau and must be rescaled.
- The success probability (1 - delta) is not stated, and the proof proves only the identity, not the sample bound.

**Proposed fix.** Restate: "if tau <= Kp and the inputs x in C^{-1}(1) with psi(phi(x)) = x and D(x) <= tau P_R(phi(x)) have total D-mass at least (1 - eps/2)p, then with probability >= 1-delta, tau times the KL lower end for W/tau is >= (1-eps)p after N = O(K log(1/delta)/eps^2) samples". Add the proof: E W >= (1-eps/2)p, and the two hypotheses force tau >= (1-eps/2)p, so tau/E W <= 2K. The multiplicative Chernoff bound applied to W/tau then puts the KL lower end within a factor (1-eps/2) of E W once N >= cK log(1/delta)/eps^2, and (1-eps/2)^2 >= 1-eps.
