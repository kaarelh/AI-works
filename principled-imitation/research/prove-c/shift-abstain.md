# Inputs from outside the closed system, and failing obviously (key: shift-abstain)

Part `shift-abstain` of the third proving round for `research/candidate-theory.md` (version 2). It covers the candidate's S1 and S3, the three kinds of shift, the online form of asking, Ab1, Ab2, Ab3, N4 and the trade-off between silent errors, abstentions and questions. N3 and S2 are proved in `research/prove/lower-bounds.md`, Section 4, and are used here by reference. Every statement below is proved in this file unless it says otherwise. Nothing here has been refereed. Scripts: `research/prove-c/code/shift-abstain_*.py`; their output is quoted in Section 8.

## 0. Summary

### 0.1 Table of statements

SUMMARY-TABLE-PLACEHOLDER

### 0.2 Conventions

* log is log₂ and ln is the natural logarithm. KL is in nats. TV(p, q) := ½ Σ_y |p(y) − q(y)|. H²(p, q) := 1 − Σ_y √(p(y) q(y)). For kernels C, C′ and an input x, TV(C, C′)(x) abbreviates TV(C(·|x), C′(·|x)), and likewise KL(C ‖ C′)(x) and H²(C, C′)(x).
* (x)⁺ := max(x, 0). C(t, ≤ j) := Σ_{i=0}^{j} C(t, i) is a sum of binomial coefficients.
* "Function" means a sampler whose answers are deterministic. "Asked input" means an input that was put to the human.

### 0.3 Changes of notation, and symbols added to those of `research/outline.md`

1. The outline uses D₀ for the law of the top-level input and D for data. To keep the two apart, the data gathered in rounds 1, …, t − 1 are written D_{<t} (so D_{<1} is the empty list), and the data after n rounds D_{≤n}. M^(t) := M_{D_{<t}}, as in the outline.
2. The outline uses T for the uniformly chosen round whose rule is deployed. The number of calls of a run τ is written len(τ), and ℓ_t for the run of round t. The number of steps of an open-ended interaction is written h ("horizon").
3. A(D) is the set of inputs that occur in the data D. The letter A alone is used for sets of inputs, as in sep(x; A), and for nothing else; an answerer is called G, a kernel C.
4. Rules that may abstain: Thr_η (threshold rule, Section 4), Min_𝒞 (minimum rule over a plausible set 𝒞, Section 5; its sub-probability kernel is S_𝒞, the candidate's S_C), Nov_s (novelty rule, Section 6). The symbol ⊥ is the abstention.
5. Counts in the trade-off statements are written as words: Sil (silent errors), Abs (abstentions), Qu (questions).
6. W := Σ_ν w(ν) ≤ 1 is the total weight of the class, w_max(D) the largest posterior weight after D, and K_D := log(1/max{w(ν) : ν(D) > 0}) for a class of functions (the complexity of the best explanation of D).

### 0.4 What is used from other files

* `research/prove/lower-bounds.md` (cited as LB): Lemma 1.5 and Theorem 1.6 (N1), Corollary 1.7, Proposition 1.8, Lemma 1.10 (patch family), Theorem 2.1 and Corollary 2.2 (N2), Theorem 4.1 (N3), Corollary 4.2, Theorem 4.3, Proposition 4.4 (S2). These are used as stated there; I checked the proofs of Lemma 1.10, Theorem 4.1, Theorem 4.3 and Proposition 4.4(a) while using them and found no error.
* `research/prove-b/hellinger-runs.md` (cited as HR): Theorem 3.1 (R2 in general: E TV(Q_{M^(T)}, Q_P) ≤ 2√(L·K ln 2/n)). Used only in Proposition 2.1(c); not re-checked here.
* The regret bound for Bayes mixtures on adaptively chosen questions (the candidate's L3) and Theorem R1 are re-proved here in the form needed (Lemma 1.1, Corollary 1.3), so that this file can be read alone.

## 1. Setting and tools

### 1.1 Objects

**Samplers, hypotheses, the class.** X and Y are countable sets, and Y has at least two elements; b₀ ≠ b₁ are two fixed elements of Y. Put Y_⊥ := Y ∪ {⊥}. A *sampler* is a probability kernel S(·|x) on Y. A *hypothesis* is a conditional semimeasure: ν(y|x) ≥ 0 with Σ_{y∈Y} ν(y|x) ≤ 1; the missing mass 1 − Σ_y ν(y|x) is put on ⊥, so that a hypothesis is a probability kernel on Y_⊥. A *function* f : X → Y is the sampler that answers f(x) with probability 1. The human is a sampler P (assumption A1: every question x is answered by a fresh draw from P(·|x)). H is a countable set of hypotheses with weights w(ν) > 0, W := Σ_ν w(ν) ≤ 1, and P ∈ H (assumption A2). K := log(1/w(P)).

**Data, posterior, mixture.** A *data list* D is a finite sequence of pairs (x_i, y_i) ∈ X × Y; D + (x, y) is D with one pair appended; A(D) is the set of the inputs x_i. Put ν(D) := Π_i ν(y_i|x_i) and ξ(D) := Σ_ν w(ν) ν(D), so ξ(∅) = W. If ξ(D) > 0, the posterior is w_D(ν) := w(ν) ν(D)/ξ(D), its largest value is w_max(D), and the mixture is

  M_D(y|x) := Σ_ν w_D(ν) ν(y|x) = ξ(D + (x, y))/ξ(D) for y ∈ Y.

Since P ∈ H, M_D(y|x) ≥ w_D(P)·P(y|x).

**Answer rules.** An *answer rule* 𝔯 assigns to every data list D a probability kernel 𝔯_D(·|x) on Y_⊥. The answer ⊥ is an *abstention*. The mixture is the rule 𝔯_D = M_D (it abstains with the missing mass, which is 0 when all hypotheses are samplers). A rule is *frozen at D* when the kernel 𝔯_D answers all later inputs.

**Scaffolds and runs.** A scaffold Π of horizon L ≥ 1 consists of a countable set Z with a law D₀ (top-level inputs), a probability space (R, λ) (the scaffold's own randomness ρ), and measurable maps next_j : Z × R × Y^{j−1} → X ∪ {STOP} for j = 1, …, L; next_{L+1} := STOP. An *answerer* G gives, for each call j, a law G_j(· | z, ρ, y_1, …, y_{j−1}) on Y_⊥. A kernel C on Y_⊥ is the answerer that looks only at the input of the call. A *run* with answerer G is produced as follows: draw z ~ D₀ and ρ ~ λ; for j = 1, 2, …, compute x_j := next_j(z, ρ, y_1, …, y_{j−1}); if x_j = STOP the run ends; otherwise draw y_j from G_j; **if y_j = ⊥ the run ends** (it is *aborted* at call j). The run is τ = (z, ρ, y_1, …, y_{len(τ)}), where len(τ) ≤ L is the number of calls made, an aborting call included; x_1, …, x_{len(τ)} are its inputs. A run that is not aborted is *complete*. Q_G is the law of the run, and Q_P the *human system*; all runs of the human system are complete. The *visit measure* of G is d_G(B) := E_{Q_G} #{j ≤ len(τ) : x_j ∈ B} for B ⊆ X; its total mass is at most L. (In `research/prove/rehearsal-core.md` the scaffold continues after an answer ⊥. Here ⊥ ends the run, because for an abstaining rule this is the behaviour wanted. For the statements about the mixture that are used below the two conventions give the same proofs.)

**Separation.** For x ∈ X and A ⊆ X, sep(x; A) is the least complexity K(Q) of a decidable set Q ⊆ X with x ∈ Q and Q ∩ A = ∅ (∞ if there is none, in particular if x ∈ A). The complexity K(Q) is the length of a shortest program, for a fixed universal prefix machine, that decides Q. The statements that involve sep are made for classes with the two properties (P1), (P2) of Section 5.3, which hold in the class of all programs.

### 1.2 The regret bound on asked inputs

**Setting 1.0 (a sequence of asked inputs).** Rounds t = 1, 2, …. 𝓖_t is the σ-algebra of everything realised before the human's answer of round t. In round t there are an indicator a_t ∈ {0, 1} ("a question is asked") and an input x_t ∈ X, both 𝓖_t-measurable and otherwise arbitrary: they may depend on all earlier questions and answers and on any randomness. If a_t = 1 the human's answer y_t satisfies Pr[y_t = y | 𝓖_t] = P(y|x_t) (A1 and A3), and the pair (x_t, y_t) is appended to the data; if a_t = 0 the data do not change.

**Lemma 1.1 (regret on asked inputs; the candidate's L3). PROVED (standard).** In Setting 1.0 put κ_t := KL(P ‖ M^(t))(x_t), the divergence between the laws P(·|x_t) and M^(t)(·|x_t) on Y_⊥.

1. Almost surely, for all n: P(D_{≤n}) > 0 and Σ_{t≤n, a_t=1} ln( P(y_t|x_t)/M^(t)(y_t|x_t) ) = ln( W·P(D_{≤n})/ξ(D_{≤n}) ) ≤ ln(W/w(P)).
2. κ_t ≤ ln(1/w_{D_{<t}}(P)) < ∞ almost surely, and Σ_{t≥1} E[a_t κ_t] ≤ ln(W/w(P)) ≤ K ln 2.
3. Σ_{t≥1} E[a_t·H²(P, M^(t))(x_t)] ≤ ½·K ln 2 and Σ_{t≥1} E[a_t·TV(P, M^(t))(x_t)²] ≤ ½·K ln 2.
4. If P is a function f and e_t := 1 − M^(t)(f(x_t)|x_t), then on every path and for every n: Π_{t≤n, a_t=1} (1 − e_t) = ξ(D_{≤n})/W ≥ w(f)/W ≥ w(f).

*Proof.* (1) Pr[a_t = 1 and P(y_t|x_t) = 0 | 𝓖_t] = 0, so almost surely every recorded answer has positive probability under P, and then ξ(D) ≥ w(P)·P(D) > 0 for all data lists that arise. By definition M^(t)(y_t|x_t) = ξ(D_{<t} + (x_t, y_t))/ξ(D_{<t}) on {a_t = 1}, so the product of these numbers over the asked rounds t ≤ n telescopes to ξ(D_{≤n})/W, and the product of the numbers P(y_t|x_t) is P(D_{≤n}). The inequality is ξ ≥ w(P)·P.

(2) M^(t)(y|x) ≥ w_{D_{<t}}(P)·P(y|x) gives the bound on κ_t. Write Z_t := ln(P(y_t|x_t)/M^(t)(y_t|x_t)) on {a_t = 1}. Given 𝓖_t and a_t = 1, y_t has law p := P(·|x_t), and m := M^(t)(·|x_t) restricted to Y is a sub-probability; since (ln u)⁺ ≤ u/e for u > 0, E[Z_t⁻ | 𝓖_t] = Σ_y p(y)(ln(m(y)/p(y)))⁺ ≤ Σ_y m(y)/e ≤ 1/e. So E[Z_t | 𝓖_t] is well defined and equals κ_t. Put S_n := Σ_{t≤n} a_t Z_t and c := ln(W/w(P)). By (1), a_t Z_t = S_t − S_{t−1} ≤ c + Σ_{s<t} (a_s Z_s)⁻, and the right side is integrable; so every a_t Z_t is integrable, and E[S_n] = Σ_{t≤n} E[a_t κ_t] because a_t is 𝓖_t-measurable. E[S_n] ≤ c by (1). The terms are nonnegative; let n → ∞.

(3) For a probability vector p on Y and a sub-probability m on Y, Jensen's inequality gives ln Σ_y p(y)√(m(y)/p(y)) ≥ ½ Σ_y p(y) ln(m(y)/p(y)), that is, −ln(1 − H²) ≤ ½·KL; and H² ≤ −ln(1 − H²). The second bound is Pinsker's inequality TV ≤ √(KL/2) for the two laws on Y_⊥. Now use (2).

(4) For a function, every data list that can arise has f(D) = 1; hence ξ(D) ≥ w(f) > 0 on every path, no exceptional set is needed, 1 − e_t = ξ(D_{<t} + (x_t, f(x_t)))/ξ(D_{<t}), and the product telescopes. ∎

*Source.* This is the standard regret bound for Bayes mixtures (Solomonoff 1978 for sequences); for pairs with adaptively chosen questions it is Lemma 4.1 and Lemma 4.2 of `research/prove/rehearsal-core.md`, whose proof the one above follows.

### 1.3 Rehearsal with any driver

**Protocol R[𝔯] (rehearsal driven by an answer rule 𝔯).** For t = 1, …, n: (1) freeze the kernel C^(t) := 𝔯_{D_{<t}}; (2) run Π with C^(t) answering every call; the run has ℓ_t calls with inputs x_{t,1}, …, x_{t,ℓ_t}, and if C^(t) abstains at a call the run ends there; (3) draw J_t uniformly from {1, …, L}, independently of everything so far; if J_t ≤ ℓ_t, put x_t := x_{t,J_t} to the human, receive y_t ~ P(·|x_t) and append the pair to the data (a_t = 1); otherwise a_t = 0. The call at which a run was aborted can be asked like any other. *Deployment:* draw T uniformly from {1, …, n}, independently, and run Π with C^(T). 𝓕_{t−1} is the σ-algebra of everything realised in rounds 1, …, t − 1; d_t := d_{C^(t)} is the visit measure of the kernel of round t (a function of D_{<t}). Protocol R of the candidate theory is R[mixture].

**Lemma 1.2 (the asked call is a uniformly chosen call of the driver's run). PROVED.** For every measurable φ ≥ 0 defined on (data lists) × X,

  E[a_t·φ(D_{<t}, x_t) | 𝓕_{t−1}] = (1/L)·E[ Σ_{j≤ℓ_t} φ(D_{<t}, x_{t,j}) | 𝓕_{t−1} ] = (1/L) ∫ φ(D_{<t}, x) d_t(dx).

Moreover, given 𝓕_{T−1}, the deployed run has the same law as the rehearsal run of round T.

*Proof.* J_t is independent of the run of round t and uniform on {1, …, L}, so the conditional expectation of a_t φ(D_{<t}, x_t) = 1{J_t ≤ ℓ_t}·φ(D_{<t}, x_{t,J_t}) given 𝓕_{t−1} and the run is (1/L) Σ_{j≤ℓ_t} φ(D_{<t}, x_{t,j}). Both runs are runs of Π with the kernel C^(T) and fresh (z, ρ). ∎

**Corollary 1.3 (R1 for any driver). PROVED.** Under Protocol R[𝔯], with M^(t) = M_{D_{<t}} the mixture of round t (whether or not it is the driver):

  Σ_{t=1}^{n} E[ Σ_{j≤ℓ_t} KL(P ‖ M^(t))(x_{t,j}) ] ≤ L·K ln 2,  and for a function f:  Σ_{t=1}^{n} E[ Σ_{j≤ℓ_t} e^(t)(x_{t,j}) ] ≤ L·K ln 2,

where e^(t)(x) := 1 − M^(t)(f(x)|x). With the mixture as driver this is Theorem R1: E β(M^(T)) ≤ L·K ln 2/n for a function and E β(M^(T)) ≤ L·√(K ln 2/(2n)) in general, where β(C) := E_{Q_C} Σ_{j≤len(τ)} TV(P, C)(x_j).

*Proof.* The questions of Protocol R[𝔯] form a sequence as in Setting 1.0. Lemma 1.1(2) and Lemma 1.2 with φ(D, x) := KL(P ‖ M_D)(x) give the first bound; for a function, e ≤ −ln(1 − e) = KL. For the last claim, with the mixture as driver, Lemma 1.1(3) and Lemma 1.2 give Σ_t E ∫ TV(P, M^(t))² dd_t ≤ L·K ln 2/2, and by the Cauchy–Schwarz inequality, twice, Σ_t E ∫ TV(P, M^(t)) dd_t ≤ Σ_t E √(L ∫ TV² dd_t) ≤ √(n·L·Σ_t E ∫ TV² dd_t) ≤ L·√(n·K ln 2/2). ∎

### 1.4 Unfaithful calls, and runs compared up to the first of them

**Lemma 1.4 (coupling up to the first unfaithful call). PROVED.** Let C be a kernel on Y_⊥. There is a joint construction of a run τ^C with law Q_C and a run τ^P with law Q_P, with the same (z, ρ), and of an index σ ∈ {1, …, L} ∪ {∞}, such that: the two runs have the same inputs and the same answers at all calls j < σ; they have the same input at call σ and different answers there (call σ is the first *unfaithful* call); and if σ = ∞ the runs are equal. With p := Pr[σ < ∞], β(C) as in Corollary 1.3 and β^P(C) := E_{Q_P} Σ_{j≤len(τ)} TV(P, C)(x_j):

1. p = E Σ_{j ≤ min(σ, len)} TV(P, C)(x_j), the sum running over the common calls; hence p ≤ β(C) and p ≤ β^P(C), and TV(Q_C, Q_P) ≤ p.
2. For every g : X → [0, 1]: | ∫ g dd_C − ∫ g dd_P | ≤ (L − 1)·p.
3. β^P(C) ≤ L·p ≤ L·β(C) and β(C) ≤ L·p ≤ L·β^P(C).

If P is a function f and C abstains with probability 0, then τ^P is the run of f on the same (z, ρ), and {σ < ∞} is the event that the run of C contains an answer different from f's.

*Proof.* Draw (z, ρ). For j = 1, 2, …, as long as the two runs have the same history and the next input x_j is not STOP, draw the pair (y_j, y′_j) from a maximal coupling of C(·|x_j) and P(·|x_j), so that Pr[y_j ≠ y′_j | past] = TV(P, C)(x_j); y_j is the answer in τ^C and y′_j the answer in τ^P. At the first j with y_j ≠ y′_j put σ := j and continue the two runs separately, each with its own kernel and fresh randomness. Each run has the right law because, at every call, its answer has the right conditional law given its own past. (1) Pr[σ = j | the runs agree before call j and call j exists] = TV(P, C)(x_j); sum over j. The calls j ≤ min(σ, len) are calls of both runs, which gives the two inequalities, and the runs differ only if σ < ∞. (2) The calls j ≤ σ have the same inputs in both runs; after call σ each run has at most L − σ ≤ L − 1 further calls, and g ≤ 1. (3) β^P(C) is the expectation of the sum of TV(P, C)(x_j) over the common calls, which is p by (1), plus the sum over at most L − 1 later calls of τ^P on {σ < ∞}. The same for β(C). ∎

The factor L in (3) cannot be removed (Example 2.2).

## 2. Shift (S1, S3, and the three kinds of shift)

Throughout this section a protocol has rehearsed on a scaffold Π with top-level law D₀, and something is then deployed on inputs with a different law.

### 2.1 S1 for the law of the top-level input

Let Π′ be the scaffold Π with D₀ replaced by another law D₀′ on Z; the randomness ρ and the maps next_j are unchanged. For an answerer G (a kernel, a rule frozen at some data, or an answerer that looks at the whole history) and a measurable φ on runs with 0 ≤ φ ≤ φ_max ≤ ∞, put Φ_G(z) := E[φ(τ) | z] for a run of G with top-level input z.

**Proposition 2.1 (S1, form for the top-level law). PROVED; the candidate's S1 is MODIFIED (see Example 2.2).**

(a) If D₀′(z) ≤ B·D₀(z) for all z, then E_{z~D₀′} Φ_G(z) ≤ B·E_{z~D₀} Φ_G(z).

(b) For every B ≥ 0: E_{z~D₀′} Φ_G(z) ≤ B·E_{z~D₀} Φ_G(z) + φ_max·D₀′{z : D₀′(z) > B·D₀(z)}.

(c) Let Protocol R = R[mixture] be run on Π with n questions, let M^(T) be deployed on Π′, and let D₀′ ≤ B·D₀. Then, with expectations over the rehearsal and the deployed run:
 1. E Σ_{j≤len(τ)} KL(P ‖ M^(T))(x_j) ≤ B·L·K ln 2/n;
 2. for a function, the expected number of unfaithful calls is at most B·L·K ln 2/n, and the deployed run is the human system's run on the same (z, ρ) with probability at least 1 − B·L·K ln 2/n;
 3. in general the expected number of unfaithful calls is at most B·L·√(K ln 2/(2n)), and E TV(Q′_{M^(T)}, Q′_P) ≤ 2B·√(L·K ln 2/n), where Q′ denotes run laws on Π′;
 4. a rate of unfaithful calls certified under D₀ by the validation phase (Theorem V1 of `note.md`) holds under D₀′ with the factor B.

(d) The factor B is necessary in general: for N task laws with disjoint supports and D₀ their uniform mixture (B = N), every protocol needs N·(L/(4δ) − 3L/2) questions to have failure probability at most δ ≤ 1/6 under each of them for all members of a class with K = log(N·⌈L/(2δ)⌉ + 1) (LB, Theorem 4.3), and by (c) N·L·K ln 2/δ questions suffice for Protocol R.

(e) The last term in (b) cannot be removed: on the part of Z where D₀ vanishes no question of the rehearsal has been asked, and LB Theorem 1.6 (N1) applies to it.

*Proof.* (a) Σ_z D₀′(z) Φ_G(z) ≤ B Σ_z D₀(z) Φ_G(z). (b) Split Z into {D₀′ ≤ B·D₀} and its complement, and use Φ_G ≤ φ_max on the complement. (c) Condition on the rehearsal; the deployed kernel C = M^(T) is then fixed and each quantity is of the form E_{z~D₀′} Φ_C(z) with Φ_C ≥ 0; apply (a) and then Corollary 1.3. For the probability in (2): by Lemma 1.4 the run differs from the run of f only if it has an unfaithful call. For the total variation in (3): two run laws on Π′ have the same marginal D₀′ of z, so TV(Q′_C, Q′_P) = Σ_z D₀′(z)·TV(Q_C(·|z), Q_P(·|z)) ≤ B·Σ_z D₀(z)·TV(Q_C(·|z), Q_P(·|z)) = B·TV(Q_C, Q_P); then HR Theorem 3.1. (4) is (a) for the validated answerer. (d) and (e) are the cited results. ∎

*Remark.* The same holds, with the same proof, when the joint law of (z, ρ) is changed with density ratio at most B. What (a) needs is that the changed object is drawn before any answer and is not influenced by the answerer.

### 2.2 The candidate's S1, stated with visit measures, is false by a factor of order L

The candidate states S1 as: "if the deployment visit measure satisfies d′ ≤ B·d̄ for the average rehearsal visit measure d̄, every per-call bound holds under d′ with a factor B". Here d̄ := (1/n) Σ_t d_t is the average of the visit measures of the rehearsal mixtures (or its expectation). The per-call bound of R1 pairs each mixture M^(t) with *its own* visit measure d_t. An integral of the error of M^(T) against d̄ also contains the errors of M^(T) at the inputs that *other* rounds visit, and these are not controlled by the regret.

**Example 2.2 (S1 with visit measures fails). REFUTED as stated.** Let X = {x₀, a, b}, Y = {0, 1}, f ≡ 0, and g(x₀) = 1, g(a) = 1, g(b) = 0. H = {f, g} with w(f) = ω ∈ (0, 1) and w(g) = 1 − ω; the human is f, so K = log(1/ω). The scaffold has horizon L ≥ 2: call 1 is at x₀; if its answer is 0 the calls 2, …, L are at a, otherwise they are at b. Run Protocol R. As long as g is not refuted the posterior is the prior, because a question at b gives no information and a question at x₀ or at a refutes g at once. While g is alive, a rehearsal run asks x₀ with probability 1/L and asks a with probability ω·(L − 1)/L, so g is refuted in a round with probability κ := (1 + ω(L − 1))/L. While g is alive the mixture M = ω·f + (1 − ω)·g has

  β(M) = (1 − ω)·(1 + ω(L − 1))  (errors along its own run),  β^f(M) = ∫ e_M dd_f = (1 − ω)·L  (errors along the human's run),

with d_f = δ_{x₀} + (L − 1)·δ_a the visit measure of the human system. After g is refuted both are 0. With π_t := (1 − κ)^{t−1} the probability that g is alive in round t,

  E β(M^(T)) = (1 − ω)·L·(1 − (1 − κ)^n)/n ≤ L·K ln 2/n  (as R1 says),
  E ∫ e_{M^(T)} dd_f = (1 − ω)·L²·(1 − (1 − κ)^n)/(n·(1 + ω(L − 1))),

so the second is L/(1 + ω(L − 1)) times the first. The expected average rehearsal visit measure d̄ has d̄(x₀) = 1 and d̄(a) = (L − 1)·(1/n) Σ_t (1 − π_t(1 − ω)) ≥ (L − 1)(1 − L/n), so d_f ≤ B·d̄ with B ≤ 1/(1 − L/n). Now let the deployment be the scaffold Π′ that calls x₀ once and then a L − 1 times, whatever the answers. Its visit measure is d′ = d_f for every answerer, and the expected number of unfaithful calls of M^(T) on Π′ is E ∫ e_{M^(T)} dd_f. The candidate's S1 would give E ∫ e_{M^(T)} dd_f ≤ B·L·K ln 2/n. For ω = 1/L (so K = log L) the left side is (1 + o(1))·L²/(2n) and the right side is (1 + o(1))·L·ln L/n as n/L → ∞: the claim fails by the factor L/(2 ln L). Exact values (script `shift-abstain_s1.py`): for L = 100, ω = 0.01, n = 10⁴ the left side is 0.4975 and the claimed bound 0.0463; for L = 1000, ω = 0.001, n = 10⁶ they are 0.4997 and 0.00691.

What the example shows in words: an early mixture is wrong at x₀ and is therefore never sent to a; it is also wrong at a, and nothing in its own runs shows it. A deployment that sends inputs as the human system would (to a) meets L − 1 further errors.

**Proposition 2.3 (what is true for visit measures). NEW.** Under Protocol R, let d′ be a measure on X with d′ ≤ B·d̄, where d̄ is either the realised average (1/n) Σ_t d_t or its expectation. Then

  E ∫ TV(P, M^(T)) dd′ ≤ (2L − 1)·B·E β(M^(T)),

which is at most (2L − 1)·B·L·K ln 2/n for a function and (2L − 1)·B·L·√(K ln 2/(2n)) in general. By Example 2.2 the factor 2L − 1 cannot be replaced by anything below L/(1 + ω(L − 1)), which is L/2 for a human of log L bits.

*Proof.* Fix two kernels C_u and C_t and put g := TV(P, C_u) ∈ [0, 1]. By Lemma 1.4(2), applied to C_t and then to C_u, and by Lemma 1.4(1),

  ∫ g dd_{C_t} ≤ ∫ g dd_P + (L − 1)·β(C_t) ≤ ∫ g dd_{C_u} + (L − 1)·β(C_u) + (L − 1)·β(C_t) = L·β(C_u) + (L − 1)·β(C_t).

For the realised d̄: ∫ TV(P, M^(u)) dd′ ≤ B·(1/n) Σ_t ∫ TV(P, M^(u)) dd_t ≤ B·(L·β(M^(u)) + (L − 1)·(1/n) Σ_t β(M^(t))); average over u = T. For the expected d̄ the mixtures M^(t) in the middle expression come from an independent copy of the rehearsal, and the same computation applies. Then Corollary 1.3. ∎

So S1 holds with the factor B when the shift is a change of the law of the top-level input (or of anything else that is drawn before the answers), and with the factor (2L − 1)·B when all that is known is a bound on visit measures. Scripts: the inequality in the proof and Lemma 1.4(3) were checked by exact enumeration on 20000 random adaptive scaffolds (Section 8).

### 2.3 S3: a property of tasks

**Proposition 2.4 (S3). PROVED, with the meaning of "costs 1/β" made exact.** Let Γ ⊆ Z be a set of top-level inputs (a property of tasks) with β := D₀(Γ) > 0.

(a) For every answerer G and every φ ≥ 0 on runs: E[φ(τ) | z ∈ Γ] ≤ E[φ(τ)]/β. Hence, after Protocol R with n questions, the run of M^(T) on a task with the property has at most L·K ln 2/(β·n) unfaithful calls in expectation for a function, and at most L·√(K ln 2/(2n))/β in general.

(b) For a set Q ⊆ X of inputs (a property of calls): the expected number of unfaithful calls of the deployed run with input in Q is at most E β(M^(T)); so if the deployed run makes at least β_Q·L calls in Q in expectation, the ratio of the expected number of unfaithful calls in Q to the expected number of calls in Q is at most K ln 2/(β_Q·n) for a function.

(c) *The factor 1/β is necessary for a protocol that takes its questions from runs on tasks drawn from D₀.* Call a protocol a *rehearsal on D₀* if in each of n rounds it draws z ~ D₀, runs the scaffold on z with an answerer of its choice, and may put one call of that run to the human. For every L ≥ 1, δ ∈ (0, 1/4] with L/(2δ) an integer, and β ∈ (0, 1], there are a scaffold with horizon L, a class of L/(2δ) + 1 functions and a set Γ with D₀(Γ) = β such that every rehearsal on D₀, with any deployed system, whose outcome on tasks in Γ is right with probability at least 1 − δ for every member, has n ≥ (L/(4δ) − L)/β.

(d) *A property that is known in advance costs nothing; N unknown ones cost N.* If Γ is known, the protocol can rehearse on D₀(· | Γ), which is sampled by rejection with computation only. If the guarantee is wanted for each of N disjoint sets Γ_1, …, Γ_N of probability 1/N, every protocol whatever needs N·(L/(4δ) − 3L/2) questions for some class (LB, Theorem 4.3, with the laws D₀(· | Γ_i)).

*Proof.* (a) E[φ·1{z ∈ Γ}] ≤ E[φ]; divide by β; then Corollary 1.3. (b) The unfaithful calls in Q are among the unfaithful calls. (c) Let N₀ := L/(2δ), X := [N₀] ∪ {x*}, and let the class be the needle class of LB Section 2.1 extended by 0 at x*: f₀ ≡ 0 and f_c := 1[· = c] for c ∈ [N₀]. Let Z := {z*} ∪ [N₀]^L with D₀(z*) = 1 − β and D₀ uniform on Γ := [N₀]^L with total mass β. On z* the scaffold makes L calls at x*; on z = (z_1, …, z_L) ∈ Γ it calls z_1, …, z_L and its outcome is the largest answer. A call at x* is answered 0 by every member. In a round with z = z* every call is at x*, so the questions that lie in [N₀] come from the rounds with z ∈ Γ, and their expected number is at most β·n. Apply LB Lemma 1.10(2) to the scaffold with top-level law D₀(· | Γ), the patches B_c := {c} and M = L, exactly as in the proof of LB Theorem 2.1. In the proof of that lemma the sum Σ_c π_c of the probabilities that patch c is asked is bounded by the expected number of questions that lie in the patches, which here is at most β·n. So some member has failure probability on Γ at least (N₀ − β·n)·p/(N₀ + L) with p = 1 − (1 − 1/N₀)^L. By the computation of LB Corollary 2.2(1) this is at most δ only if β·n ≥ L/(4δ) − L. (d) is the cited theorem. ∎

*What S3 does not say.* The factor 1/β is not a law of nature for one fixed property: a protocol that knows Γ pays nothing. It is the price of a guarantee for a property that the designer did not single out, and the price of N such guarantees at once.

### 2.4 The three kinds of shift

**Theorem 2.5 (three kinds of shift). PROVED (a statement that collects R1, S1, S2, N3 and N1).** Let Protocol R be run on a scaffold Π with top-level law D₀ and n questions, and let M^(T) be deployed.

(i) *The shift produced by the system itself costs nothing.* For every B ⊆ X, the probability that the question of round T is asked and lies in B equals 1/L times the expected number of calls of the deployed run on Π that lie in B. In other words, a uniformly chosen call of the deployed run and the question put to the human in a uniformly chosen round have the same distribution, whatever the scaffold does with the answers (decomposition, recursion, calls whose inputs are written by earlier calls). Consequently the bounds of Theorem R1 hold for the deployed run with no factor for shift, and for every property Q of inputs the expected number of unfaithful calls with input in Q is at most L·K ln 2/n for a function.

(ii) *A shift to a described law costs the density ratio, and no less.* If the deployment draws its top-level input from D₀′ ≤ B·D₀, every bound holds with the factor B (Proposition 2.1). If the rehearsal draws z from a mixture Σ_i π_i D_i, each D_i has B ≤ 1/π_i (LB Proposition 4.4(a)); for N laws with disjoint supports the factor N is necessary for every protocol (LB Theorem 4.3). For 2^k laws of description length at most k + 2 log k + c this is the price 2^k of "all simple shifts" (LB Corollary 4.2), and with advantage η over a coin the exact number of questions is 2η·2^k (LB Theorem 4.1).

(iii) *Any other shift has no guarantee.* Let x be an input, let A be a set that contains all questions of the protocol with probability 1 and not x, and let the class contain, with P, a hypothesis P′ that equals P on A. Then for every protocol whose questions lie in A and every deployed system, the laws R, R′ of the answer at x under P and P′ satisfy TV(R, P(·|x)) + TV(R′, P′(·|x)) ≥ TV(P(·|x), P′(·|x)) (LB Theorem 1.6(4)); for functions with f′(x) ≠ f(x) the answer at x is wrong or withheld with probability at least 1/2 for one of the two. In the class of all programs such an f′ exists with K(f′) ≤ K(f) + sep(x; A) + c (LB Proposition 1.8). In terms of laws: for a deployment law D₀′ that is not dominated by D₀, Proposition 2.1(b) covers the part where D₀′ ≤ B·D₀ at the price B and leaves the rest, D₀′{D₀′ > B·D₀}, without a guarantee.

*Proof.* (i) Lemma 1.2 with φ := 1_B, for the round T, together with its last sentence; the bounds are Corollary 1.3. (ii) and (iii) are the cited statements. ∎

*What the theorem does not say.* (i) is a statement about expected numbers of calls. It does not say that a particular call of a kind that occurs with frequency below 1/n per call is answered faithfully: such kinds are not sampled, and what the imitator does there is fixed by the prior, as in (iii).

## 3. Open systems: asking at random for ever, and why asking cannot stop

In this section there is no scaffold that we can run in advance. Inputs arrive from outside, in any way.

### 3.1 The online form

**Setting 3.0.** Steps t = 1, 2, …. 𝓖_t is the σ-algebra of everything realised before the coin of step t: all earlier inputs, coins, answers of the human and outputs of the system, and any outside randomness. At step t an input x_t arrives; x_t is 𝓖_t-measurable and otherwise arbitrary (it may be chosen by an adversary who knows the whole past, the system's own outputs included). A coin c_t ∈ {0, 1} is flipped with Pr[c_t = 1 | 𝓖_t] = q_t, where q_t ∈ (0, 1] is 𝓖_t-measurable; in the basic form q_t = q is a constant. If c_t = 1 the human is asked, answers y_t with Pr[y_t = y | 𝓖_t, c_t = 1] = P(y|x_t), the answer is the output of the step, and (x_t, y_t) is appended to the data. If c_t = 0 the output is a draw from M^(t)(·|x_t), the mixture given the pairs gathered so far, and the data do not change. Write κ_t := KL(P ‖ M^(t))(x_t), and call an unasked step *unfaithful* if the system's answer differs from a shadow answer of the human drawn jointly with it from a maximal coupling; for a function f this is the event that the system's answer differs from f(x_t).

**Theorem 3.1 (each call is put to the human with probability q, for ever). PROVED (Observation A of `understand/notes.md`; X3 and X4 of `understand/repo.md`).** In Setting 3.0:

(a) Σ_{t≥1} E[q_t κ_t] ≤ K ln 2. For constant q: E Σ_{t≥1} KL(P ‖ M^(t))(x_t) ≤ K ln 2/q, the sum running over all steps, asked or not.

(b) For a function and constant q, the expected number of unfaithful steps, over the whole unbounded interaction, is at most (1 − q)·K ln 2/q.

(c) In general, for constant q: Σ_{t≥1} E[TV(P, M^(t))(x_t)²] ≤ K ln 2/(2q), and the expected number of unfaithful steps among the first h steps is at most (1 − q)·√(h·K ln 2/(2q)).

(d) The number of questions among the first h steps has mean q·h. So for a function, (expected silent errors) × (expected questions in h steps) ≤ (1 − q)·h·K ln 2.

*Proof.* The asked steps form a sequence as in Setting 1.0 with a_t := c_t (the σ-algebra of Setting 1.0 at round t is generated by 𝓖_t and c_t). Lemma 1.1(2) gives Σ_t E[c_t κ_t] ≤ K ln 2. κ_t is 𝓖_t-measurable, so E[c_t κ_t] = E[q_t κ_t]. This is (a). (b) Given 𝓖_t and c_t = 0, the system's answer differs from f(x_t) with probability e_t = 1 − M^(t)(f(x_t)|x_t) ≤ −ln(1 − e_t) = κ_t, and E[(1 − c_t) e_t] = (1 − q)·E[e_t]. (c) Lemma 1.1(3) in the same way gives the first bound; an unasked step is unfaithful with conditional probability TV(P, M^(t))(x_t), and Σ_{t≤h} E TV_t ≤ √(h·Σ_t E TV_t²) by the Cauchy–Schwarz inequality. (d) E Σ_{t≤h} c_t = q·h; combine with (b). ∎

*Which hypotheses are needed.* (1) The input x_t must be fixed before the coin c_t. If the source of inputs sees the coin first, it can send the inputs on which the mixture is wrong only at unasked steps. (2) The human's answer must be a fresh draw given the past (A1, A3). (3) A2 is used through K. Nothing is assumed about the inputs.

**Example 3.2 (the bounds of Theorem 3.1 are attained up to the factor 2 ln 2). PROVED.** (i) *Divergence.* By Lemma 1.1(1), E Σ_{t≤n} c_t κ_t = ln(W/w(P)) − E ln(1/w_{D_{≤n}}(P)). So (a) holds with equality in the limit whenever the questions identify the human, in the sense that E ln(1/w_{D_{≤n}}(P)) → 0. In a simulation with 8 samplers and an input rule that always shows the input at which the mixture is farthest from the human, the simulated sums were 4.159 ± 0.027, 10.46 ± 0.07 and 41.55 ± 0.28 for q = 0.5, 0.2, 0.05, against the bounds 4.159, 10.40 and 41.59 (Section 8).

(ii) *Silent errors.* Let X = {a_1, …, a_K}, let H be all 2^K functions X → {0, 1} with weights 2^(−K), and f ≡ 0. The input rule shows a_1 at every step until a_1 has been asked, then a_2 until it has been asked, and so on. At an unasked step with input a_i the posterior is uniform on the functions that vanish at a_1, …, a_{i−1}, so the mixture's draw is wrong with probability 1/2. The number of unasked steps before a_i is asked has mean (1 − q)/q. So the expected number of silent errors is K(1 − q)/(2q), against the bound (1 − q)·K ln 2/q of (b).

### 3.2 Silent mistakes times questions is at least the horizon over a constant

Can the asking stop? The following class has N members of log N bits each and shows that it cannot, on arbitrary input sequences. A *learner with questions on request* acts at each step knowing the inputs so far, the answers to its own earlier questions, and a random seed. At each step it asks (and sees the human's answer), or predicts an answer (and sees nothing), or abstains (and sees nothing). Qu is the number of questions, Sil the number of wrong predictions (silent mistakes), Abs the number of abstentions.

**Theorem 3.3 (thresholds; silent mistakes against questions). PROVED (the bound of `understand/ask-for-help.md`, Section 3.4, with the constant improved from 1/32 to 3/16, a version for the expected number of questions, and abstentions included).** Let N ≥ 2. The inputs 1, 2, …, N − 1 are shown in increasing order, once each. The class consists of the N thresholds h_s(x) := 1[x ≤ s], s ∈ {0, 1, …, N − 1}, with weights 1/N (so K = log N), and s is drawn uniformly. For every learner with questions on request:

(a) if Qu ≤ Q on every run, then E[Sil + Abs] ≥ ¼·( N/(Q + 1) − (Q + 1)/N ); in particular E[Sil + Abs]·(Q + 1) ≥ 3N/16 whenever Q + 1 ≤ N/2;

(b) with Q̄ := E[Qu]: E[Sil + Abs] ≥ N/(9(Q̄ + 1)) − √((Q̄ + 1)/(8N)); in particular E[Sil + Abs]·(Q̄ + 1) ≥ N/15 whenever Q̄ + 1 ≤ N/4;

(c) if Q + 1 divides N, the learner that asks at the Q positions that are multiples of N/(Q + 1), predicts 1 until an answer 0 has been seen and 0 afterwards, has Qu ≤ Q and E[Sil] = (N/(Q + 1) − 1)/2 < N/(2(Q + 1)). So (a) is optimal up to the factor 2.

Since the left sides are averages over s, some member s has at least as many expected silent mistakes and abstentions.

**Lemma 3.4.** Let b_1, …, b_u > 0 with Σ_j b_j = N. Then (Σ_j b_j²)·(Σ_j j·b_j) ≥ (4/9)·N³.

*Proof.* Put A := Σ_j b_j² and S := Σ_j j b_j, and let J > 0 be real. Then J·N − S = Σ_j (J − j) b_j ≤ Σ_{1≤j<J} (J − j) b_j ≤ √A·√(Σ_{1≤j<J} (J − j)²) by the Cauchy–Schwarz inequality, and Σ_{1≤j<J} (J − j)² ≤ ∫_0^J v² dv = J³/3, because (J − j)² ≤ ∫_{J−j}^{J−j+1} v² dv and these intervals are disjoint subsets of [0, J]. Take J := 3S/N; then J·N − S = 2S > 0 and A ≥ 3·(2S)²/J³ = (4/9)·N³/S. ∎

*Proof of Theorem 3.3.* *Step 0: reductions.* Replace every abstention by the prediction 1. This gives a learner without abstentions, with the same questions and with Sil′ ≤ Sil + Abs on every run. So it suffices to bound E[Sil] for learners that never abstain. A randomised learner is a deterministic one for each value of its seed; we fix the seed and treat a deterministic learner, and average at the end.

*Step 1: the all-ones path.* As long as all answers to its questions have been 1, the learner's behaviour is a fixed sequence: it asks at certain positions q_1 < q_2 < … < q_m and predicts fixed labels p(x) at the other positions x. Put q_0 := 0, q_{m+1} := N, and let 𝔅_j := {q_{j−1}, …, q_j − 1} for j = 1, …, m + 1. These blocks partition {0, …, N − 1}; b_j := |𝔅_j| ≥ 1 and Σ_j b_j = N. If s ∈ 𝔅_j, the questions at q_1, …, q_{j−1} are answered 1, because these positions are at most q_{j−1} ≤ s. So for s ∈ 𝔅_j the learner follows the all-ones path at every position before q_j: it asks at q_1, …, q_{min(j,m)} at least, and at each position x with q_{j−1} < x < q_j it predicts p(x).

*Step 2: mistakes.* Fix j and write the b_j − 1 positions strictly between q_{j−1} and q_j as x = q_{j−1} + r, r = 1, …, b_j − 1, and the members of the block as s = q_{j−1} + i, i = 0, …, b_j − 1. The label of x under h_s is 1[r ≤ i]. If p(x) = 1 the prediction at x is wrong for the r members with i < r; if p(x) = 0 it is wrong for the b_j − r members with i ≥ r. Hence the number of mistakes at these positions, summed over the members of 𝔅_j, is at least Σ_{r=1}^{b_j − 1} min(r, b_j − r) = ⌊b_j²/4⌋ ≥ (b_j² − 1)/4. Summing over the blocks,

  Σ_{s=0}^{N−1} Sil(s) ≥ (A − (m + 1))/4,  A := Σ_{j=1}^{m+1} b_j².  (3.1)

*Step 3: questions.* By Step 1, Qu(s) ≥ min(j, m) for s ∈ 𝔅_j, so Qu(s) + 1 ≥ j and

  Σ_{s=0}^{N−1} (Qu(s) + 1) ≥ S := Σ_{j=1}^{m+1} j·b_j ≥ (m + 1)(m + 2)/2.  (3.2)

*Step 4: proof of (a).* The member s = N − 1 lies in the last block, so m ≤ Qu(N − 1) ≤ Q. By the Cauchy–Schwarz inequality A ≥ N²/(m + 1), and v ↦ N²/v − v is decreasing; so (3.1) gives Σ_s Sil(s) ≥ (N²/(Q + 1) − (Q + 1))/4 for every seed. Divide by N and average over the seed. If Q + 1 ≤ N/2 then (Q + 1)/N ≤ N/(4(Q + 1)).

*Step 5: proof of (b).* Index the quantities of Steps 1 to 3 by the seed r. By Lemma 3.4, A_r·S_r ≥ (4/9)N³ for every r, so by the Cauchy–Schwarz inequality E_r[A_r]·E_r[S_r] ≥ (E_r √(A_r S_r))² ≥ (4/9)N³. By (3.2), E_r[S_r] ≤ N·(Q̄ + 1) and m_r + 1 ≤ √(2S_r), so E_r[m_r + 1] ≤ √(2N(Q̄ + 1)) by Jensen's inequality. With (3.1): N·E[Sil] ≥ ( (4/9)·N²/(Q̄ + 1) − √(2N(Q̄ + 1)) )/4, which is the first claim. If Q̄ + 1 ≤ N/4, then (Q̄ + 1)·√((Q̄ + 1)/(8N)) ≤ (N/4)^(3/2)/√(8N) = N/(8√8), and N/9 − N/(8√8) > N/15.

*Step 6: proof of (c).* Put b := N/(Q + 1). For s = q_{j−1} + i in block j, the learner predicts 1 at the b − 1 − i positions of the block's gap that lie above s, where the label is 0, and makes no other mistake: below s the label is 1, and after the answer 0 at q_j it predicts 0, which is right. (In the last block there is no question at the end, and the count is the same.) The average of b − 1 − i over i = 0, …, b − 1 is (b − 1)/2. ∎

*Numerical check.* A dynamic programme over the information states of all deterministic learners gives the exact minimum of N·E[Sil] for N ≤ 16 and all Q ≤ 5, and a reduction to block sizes gives it for N up to 240. The minimum of E[Sil]·(Q + 1)/N lies between 0.25 (Q = 0) and 0.441 (N = 240, Q = 11), in agreement with (a) and (c); for Q = 1 it tends to 1/3, the value found by exhaustive search in the digest. The bound (b) was checked on the lower hull of all deterministic learners for N = 12, 24, 48 (Section 8).

**Corollary 3.5 (the factor K). NEW.** Let u ≥ 1 and N₁ ≥ 2. Take u copies of the threshold problem: inputs (i, x) with i ∈ [u], x ∈ {1, …, N₁ − 1}, shown in lexicographic order, and the class of the N₁^u functions (i, x) ↦ 1[x ≤ s_i], with uniform weights; so K = u·log N₁ and the number of steps is h = u(N₁ − 1). For every learner with questions on request and uniformly drawn (s_1, …, s_u), with Q̄ := E[Qu]:

  E[Sil + Abs]·(Q̄ + u) ≥ u·(h + u)/15 = K·(h + u)/(15·log(h/u + 1))  whenever Q̄ + u ≤ (h + u)/4.

So in Theorem 3.1(d) the factor K cannot be removed: the product of silent errors and questions is at most h·K ln 2 for asking at random, for every class and every input sequence, and at least about h·K/(15·log(h/u + 1)) for every learner on this class and this sequence.

*Proof.* Let Q̄_i and M̄_i be the expected numbers of questions and of silent mistakes plus abstentions at the inputs (i, ·). Conditionally on the seed and on (s_{i′})_{i′≠i}, the learner restricted to the inputs (i, ·) is a randomised learner for one threshold problem with N₁ members: what it has seen in the other copies is a function of the seed and of the other s_{i′}, which are independent of s_i. Averaging Theorem 3.3(b) over the conditioning (its right side is convex in Q̄) gives M̄_i ≥ γ(Q̄_i) with γ(v) := N₁/(9(v + 1)) − √((v + 1)/(8N₁)), a convex and decreasing function. By Jensen's inequality Σ_i M̄_i ≥ u·γ(Q̄/u) = u²N₁/(9(Q̄ + u)) − √(u(Q̄ + u)/(8N₁)). If Q̄ + u ≤ uN₁/4, then (Q̄ + u)·√(u(Q̄ + u)/(8N₁)) ≤ u²N₁/(8√8), and u²N₁·(1/9 − 1/(8√8)) > u²N₁/15; finally uN₁ = h + u. ∎

**Corollary 3.6 (the asking cannot stop on arbitrary inputs). PROVED.** For every Q and every horizon h there is a class of h + 1 functions of log(h + 1) bits each and a sequence of h distinct inputs on which every learner that asks at most Q questions has, for some member, an expected number of silent mistakes and abstentions of at least ¼·((h + 1)/(Q + 1) − (Q + 1)/(h + 1)). So a rule that asks finitely often, on inputs that arrive from outside, makes silent mistakes or abstains at a rate of at least 1/(4(Q + 1)) per step on some sequence, however simple the class. A bound on the total number of silent errors over an unbounded deployment, as in Theorem 3.1(b), requires the human for ever.

*Proof.* Theorem 3.3(a) with N = h + 1. ∎

*Relation to the literature.* The product form "mistakes × queries ≳ horizon" for thresholds is derived in `understand/ask-for-help.md`, Section 3.4, whose argument is Steps 1, 2 and 4 above with the constant 1/32. That digest reports the same product law, in a model in which every label is shown and abstentions on injected inputs are free, from J. Yu and M. Blanchard, "Distribution-Free Sequential Prediction with Abstentions", arXiv:2602.17918: E[MisErr] ≥ T^α/32 or E[AbsErr] ≥ T^(1−α)/2 for a class of VC dimension 1. I did not open that paper in this session; it is quoted from the digest and is not used in any proof here.
