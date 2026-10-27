# Referee report: envelopes (proof lens)

**Verdict.** The core results are sound once minor fixes are made: Definition def:envelope, Lemma lem:envmass, Theorem thm:envelope (i)-(iv) and Lemma lem:K are correct, but they need several hypotheses and constants stated and one bound term fixed. The variance/dispersion remark is not sound: it contains a false claim (major). Its claim that dispersion, not the mean, is what costs samples is false for the paper's own estimator and for its own example. It also says "(10/9)^m-1 under every reweighting" where it should say "at least".

**What was checked.** I re-derived every step of the assigned items.

def:envelope / derivations:
- Checked that literal/constant/box leaves with SUM/PROD give a function with values in {0,1,2,...}.
- Checked that DNF and DNNF give dominating envelopes with supp(phi) = C^{-1}(1).
- Checked the derivation-count identity, including corner cases (shared nodes; semantic versus syntactic support).

lem:envmass:
- Proved the bottom-up mass by independence of disjoint-support factors under a product D.
- Proved by induction over the unfolded tree that the top-down sampler picks derivation T with probability w(T)/Z_v (SUM: (Z_c/Z_v)*w(T_c)/Z_c; PROD: product of w(T_c)/Z_c; leaf: D(l)/D(l)).
- Checked that every node the sampler reaches has positive mass, and that a node with nonempty support is reached at most once per run (paths diverge only at a PROD).
- Checked numerically: on 20 random decomposable envelopes (n=5, random product D), the project's Envelope.mass equals E_D[phi] by enumeration to 1e-12. The empirical Q from 2e5 samples of Envelope.sample matches D*phi/Z (worst standardized chi^2 deviation 1.57, no mass outside the support).

thm:envelope:
- (i) Checked W in [0,1] and E W = D(C and phi>0)/Z = p/Z. Under domination Z >= p, so K >= 1.
- (ii) Checked the validity of the two-sided KL interval {m: KL(mu_hat||m) <= ln(2/delta)/N} from Hoeffding 1963 Thm 1 (which allows independent [0,1] variables). The citation is correct.
- (iii) Integer-valued phi gives W <= 1 without domination, and Z*l <= D(C and phi>0) <= p.
- (iv) The KL inequality KL(a||b) >= (a-b)^2/(2 max(a,b)) holds. Proof via KL = integral_b^a (a-s)/(s(1-s)) ds >= integral (a-s)/s ds. Grid check: min ratio 1.0026 over 640k pairs, including a near 0 and 1.
- (iv) The multiplicative Chernoff bound holds for [0,1] variables (eta = eps/8 needs eps <= 8).
- (iv) Solving the quadratic d^2 <= 2(mu_hat+d)L/N gives half-width <= a + sqrt(a*mu_hat) <= (eps/4)mu_hat; c ~ 2000 suffices.
- (iv) (1+eps/4)/(1-eps/4) <= 1+eps iff eps <= 2.
- (iv) sum_j 6delta/(pi^2 j^2) = delta. Stage sizes are deterministic, so each stage's interval is valid and the union bound applies.

lem:K: Checked the identity K = E[phi|C] + E[phi 1_{C=0}]/p, the expected-ambiguity reading, and K <= m for DNF.

Dispersion remark:
- Verified the relative variance (Z/p)E[1/phi|C=1]-1 <= K-1 by exact enumeration (E with m=3: 0.37174 = (10/9)^3-1, K = (4/3)^3).
- Derived the per-clause factor (2/9)((a+b)^2/(ab)+1) under edge weights (a,b). This is >= 10/9, with equality only at a=b.
- Ran the project's sequential_mean on W ≡ 1/K, on W ~ Bernoulli(1/K), and on the actual W of E (m=10,20,30). The sample counts are identical and scale like K, not like rho: at m=30, N = 6.7e7 for both, with K = 5600, rho = 22.6, eps*K = 560.

Surprise paragraph: checked the identity log2(1/p) = log2(1/Z) + log2 K and the cost statements.

## Findings

### 1. [major] sec-envelopes.tex, remark after lem:K: "K bounds the relative variance; its exact value is ... so what costs samples is the \emph{dispersion} of the number of derivations, not its mean" (repeated in sec-part2.tex, paragraph before thm:sis)

**Problem.** The formula rho = (Z/p)E_D[1/phi|C=1]-1 <= K-1 is correct. The conclusion drawn from it is false.

(a) The paper's own estimator (thm:envelope(iv), Hoeffding-KL intervals) costs Theta(K log(1/delta)/eps^2) whatever rho is. Near mu_hat = 1/K the KL interval has half-width ~ sqrt(2 mu L/N), independent of the variance. I ran the project's sequential_mean on W ≡ 1/K (zero variance) and on W ~ Bernoulli(1/K): it uses the same number of samples in both cases, growing linearly in K.

(b) Even the optimal black-box rule for [0,1] variables (DKLR's AA, cited in sec-setting) needs Theta(max(rho, eps*K) log(1/delta)/eps^2) samples. The mean always enters through the eps*K term.

(c) In the paper's own example E = AND_i(x_i OR y_i) under uniform D: K = (4/3)^m and rho = (10/9)^m - 1, so eps*K >> rho for large m. The cost is therefore governed by the mean K, not by the dispersion. Simulation of the actual W of E at m = 10, 20, 30 matches the Bernoulli(1/K) cost exactly.

**Proposed fix.** Replace with: "K bounds the relative variance rho = (Z/p)E_D[1/phi|C=1]-1 <= K-1. The KL procedure of (iv) pays Theta(K log(1/delta)/eps^2) regardless of rho. A variance-adaptive rule (the AA algorithm of [dklr2000]) pays Theta(max(rho, eps K) log(1/delta)/eps^2), so low dispersion helps only when rho << eps K. A deterministic DNNF has phi = 1_C, K = 1 and rho = 0. For E = AND_{i<=m}(x_i OR y_i) under uniform D, K = (4/3)^m and rho >= (10/9)^m - 1 under every reweighting of its OR-edges; both are exponential." Then say that thm:sis removes the cost because its looseness is D(supp phi)/p rather than E_D[phi]/p: it removes the overcounting term E[phi|C=1], not just its dispersion. Make the same correction in sec-part2.tex ("which depends on the dispersion of the number of derivations").

### 2. [minor] sec-envelopes.tex, same remark: "has relative variance $(10/9)^m-1$ under every reweighting of its $\vee$-edges" (also sec-part2.tex)

**Problem.** Give OR-gate i edge weights (a,b), i.e. envelope prod_i(a x_i + b y_i). Under uniform D the per-clause factor of 1+rho is E[phi_i]E[1_sat/phi_i]/p_i^2 = (2/9)((a+b)^2/(ab)+1). This is >= 10/9, with equality only for a = b; for example a = 0.5, b = 1 gives 1.222. So the relative variance is at least (10/9)^m - 1, with equality only for the unweighted envelope, not equal to it for every reweighting. The value 10/9 also assumes D uniform, which the text does not state.

**Proposed fix.** "under the uniform distribution, has relative variance at least (10/9)^m-1 under every reweighting of its OR-edges (equality for the unweighted envelope; per clause the factor is (2/9)((a+b)^2/ab+1) >= 10/9)".

### 3. [minor] sec-envelopes.tex, thm:envelope(iv) and its proof: "N=O(K(log(1/delta)+log log K)/eps^2)"; "The doubling stage at which this first holds has j=O(log K)"; "u/l <= (1+eps/4)/(1-eps/4) <= 1+eps"

**Problem.** (1) The initial sample size N_0 is not specified. With a fixed N_0, the threshold c K log(1/delta_j)/eps^2 is first reached at j ≈ log2(cK log(1/delta)/(eps^2 N_0)), so j = O(log(K/eps) + log log(1/delta)), not O(log K). The bound then has a log log(1/eps) term that the statement omits (it matters for constant delta and eps -> 0).

(2) The last inequality, (1+eps/4)/(1-eps/4) <= 1+eps, holds only for eps <= 2. The eps/8 Chernoff step needs eps <= 8. Neither restriction is stated.

(3) The step |m - mu_hat| <= sqrt(2 max(m, mu_hat) log(2/delta_j)/N) <= (eps/4)mu_hat has m on both sides. It is correct, but only after a quadratic solve: with a = 2 log(2/delta_j)/N, any m > mu_hat satisfies m - mu_hat <= a + sqrt(a mu_hat), and this is <= (eps/4)mu_hat once c >~ 2000.

**Proposed fix.** State: "for 0 < eps <= 1, starting from N_0 = ceil(c log(1/delta)/eps^2) and doubling". With that N_0, j = O(log K) and the stated bound holds. Otherwise write log log(K/eps) in place of log log K. Add the one-line quadratic solve: for m > mu_hat, (m-mu_hat)^2 <= a m gives m - mu_hat <= a + sqrt(a mu_hat).

### 4. [minor] sec-envelopes.tex, def:envelope ("their children have pairwise disjoint supports") and lem:K ("whose support is exactly $C^{-1}(1)$")

**Problem.** "Support" is used in two senses: the variable set of a node (in the definition) and the set {x: phi(x) > 0} (in lem:K). The lemma also needs the syntactic sense: the variables occurring at leaves in the node's cone, with sv(B) for a box. Under the semantic reading (the variables the node's function depends on), Phi = PROD(SUM([x1=1],[x1=0]), [x1=1]) counts as decomposable, because its first child is the constant 1. The mass pass still returns E phi = q_1. But the sampler picks the derivation {[x1=0],[x1=1]} with probability 1-q_1 and sets x1 to both values, so lem:envmass fails. The proof's parenthetical ("two literals on the same variable ... would lie below different children of a decomposable PROD") silently uses the syntactic sense. The code also uses it (union bitmasks of cone variables).

**Proposed fix.** In def:envelope: "the support sv(v) of a node is the set of variables occurring in the leaves of its cone (sv(B) for a box); PROD gates must have children with pairwise disjoint sv". In lem:K: "whose support {x: phi(x)>0} is exactly C^{-1}(1)".

### 5. [minor] sec-envelopes.tex, paragraph after def:envelope: "A \emph{derivation} of $\Phi$ is a subcircuit obtained by keeping, top-down, one child of every SUM gate reached ... $\varphi(x)$ is the number of derivations"

**Problem.** Read as subcircuits of the DAG, derivations undercount when a node with empty support is shared below a PROD. Example: PROD(A, A, [x1=1]) with A = SUM(1, 1) is decomposable (sv(A) = ∅), and phi(1) = 4 (the project's Envelope.evaluate returns 4.0). But keeping one child of the single node A gives only 2 subcircuits. The sampler in lem:envmass visits A twice with independent choices, i.e. it works on the unfolded tree.

**Proposed fix.** Define a derivation as a proof tree, i.e. a subtree of the tree unfolding of Phi (one child at each SUM occurrence, all children at each PROD occurrence). Add that, by decomposability, an unfolding visits each node of nonempty support at most once, so for such nodes the two notions coincide.

### 6. [minor] sec-envelopes.tex, def:envelope ("$K=Z/p$"), lem:envmass ("samples exactly from $Q_\varphi(x)=D(x)\varphi(x)/Z$"), thm:envelope(ii) ("gives an interval $[Z\ell,Zu]$")

**Problem.** Some hypotheses and edge cases are unstated.
- Q_phi needs Z > 0, and K needs p > 0.
- Z can exceed 1 (e.g. a DNF envelope with many terms), so [Z l, Z u] need not lie in [0,1], whereas def:sound requires [L,U] ⊆ [0,1].
- The fact that domination gives Z >= p, hence K >= 1, is never stated.

**Proposed fix.** Add "(assume Z > 0; if Z = 0, output [0,0], which is valid under domination)" to lem:envmass and thm:envelope. Define K only for p > 0 and note K >= 1 under domination. In (ii), output [Z l, min(Z u, 1)].

### 7. [minor] sec-envelopes.tex, thm:envelope(iii) proof: "(For real-valued $\varphi$ clip $W$ at 1, which only decreases its mean.)"; and sec:tilting: "Envelopes need not be $\{0,1,2,\dots\}$-valued"

**Problem.** def:envelope only produces integer-valued phi, yet sec:tilting applies thm:envelope to the real-valued phi_theta, which is not an envelope circuit in this sense. Also, for real-valued phi that does not dominate C, the clipped mean E[min(W,1)] is <= D(C and phi>0)/Z. So [Z l, Z u] then bounds only Z E[min(W,1)], and only the lower end Z l <= p survives. Statement (iii)'s claim of "a valid interval for Pr[C=1 and phi>0]" holds only for integer-valued phi.

**Proposed fix.** State thm:envelope for any phi: {0,1}^n -> R_{>=0} with exact Z and an exact sampler for Q_phi; envelope circuits and phi_theta are special cases. In (iii) write: "if phi is integer-valued, [Z l, Z u] is a valid interval for D(C and phi>0); for real-valued phi, with W clipped at 1, Z l is still a valid lower bound on p."

### 8. [minor] sec-envelopes.tex, thm:envelope(ii): "the Hoeffding--KL interval $[\ell,u]$ for $\E W$ at level $\delta$"

**Problem.** The interval is never defined in the paper, yet the proof of (iv) relies on its exact form (every m in it satisfies KL(mu_hat||m) <= log(2/delta_j)/N).

**Proposed fix.** Define it: "[l,u] = {m in [0,1]: KL(mu_hat||m) <= ln(2/delta)/N}, where KL is the Bernoulli relative entropy. It is valid for independent [0,1]-valued samples by Hoeffding's Theorem 1 applied to each tail at delta/2."

### 9. [minor] sec-envelopes.tex, surprise-accounting paragraph: "exact computation explains everything, possibly at exponential cost in $|\Phi|$"; "the envelope explains $\log_2(1/Z)$ bits"

**Problem.** (1) Exact computation with a deterministic DNNF costs O(|Phi|), linear in |Phi|. What can be exponential is |Phi| as a function of |C|, so "exponential cost in |Phi|" is garbled.

(2) If Z > 1, the envelope "explains" a negative number of bits and leaves log2 K > log2(1/p) bits to sampling, i.e. it is worse than Monte Carlo. The accounting should use min(Z,1), with a fallback to Monte Carlo when Z >= 1.

(3) Hilton's surprise accounting also charges the explanation's own description length. That cost is zero when Phi is computed from C, but it is |pi| bits when a prover supplies Phi (cf. thm:surprise). The paragraph charges computation time instead, without saying so.

(4) "at cost K" means up to log(1/delta)/eps^2 factors, and by finding 1 it is an upper bound, not a tight cost.

**Proposed fix.** "exact computation explains everything, with |Phi| possibly exponential in |C|". Add: "(if Z >= 1, use Monte Carlo instead; the envelope explains log2(1/min(Z,1)) bits)". Add a clause noting that in [hilton2024surprise] the explanation's description length also counts, which is zero for envelopes computed from C and |pi| for prover-supplied ones (thm:surprise).

### 10. [minor] sec-envelopes.tex, opening sentence: "All our upper-bound-capable methods, with and without a prover, are instances of one estimator."

**Problem.** This is contradicted inside the same section. The Harris--Janson sandwich (thm:janson) gives a deterministic upper bound without any sampling. thm:sis uses Knuth-style sequential-importance weights driven by an approximate counter, not W = C/phi with Q proportional to D*phi.

**Proposed fix.** Weaken to: "Most of our upper-bound-capable methods are instances of one estimator (the exceptions are the correlation-inequality bounds of sec:janson and the counter-guided sampler of thm:sis, which is a variant of it)."

### 11. [minor] sec-envelopes.tex, thm:envelope(iv): "each costing $O(|C|+|\Phi|)$ time" and lem:envmass "samples exactly"

**Problem.** phi(X) can be as large as 2^{Theta(|Phi|)} (it is a derivation count), and the masses Z_v are products and sums of marginals q_i. So exact sampling and computing W = 1/phi(X) take O(|Phi|) operations on numbers of poly(|Phi|, b) bits, not O(|Phi|) bit operations. The time claim holds only in a unit-cost RAM model.

**Proposed fix.** Say "O(|C|+|Phi|) arithmetic operations on poly(|Phi|, b)-bit rationals (b = bit length of the q_i)". Alternatively, note that W only needs relative precision eps/poly, so O(log|Phi| + log(1/eps))-bit floating point suffices for the estimate. The exactness of the sampler needs exact rational arithmetic.
