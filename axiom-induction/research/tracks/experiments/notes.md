# Track "experiments": a Bayesian template-theory inducer and empirical tests

*Track "experiments" of the axiom-induction project. Read `../../00-brief.md` first. Code: the package `bai`
("Bayesian axiom induction") in `../../../code/bai`, experiments in `../../../code/experiments`, results in
`../../../code/results/*.md` and `*.json`, unit tests in `../../../code/tests`. Small checks for these notes are in
`checks/` (each writes a `.out` file next to it).*

**Status tags.** **[proved]**: full proof here. **[proof sketch]**: argument given, some steps not written out.
**[computed]**: by a named script; the output file is named. **[known]**: published, with reference; **(unverified)**
means recalled, not checked against the source in this session. **[conjecture]**. **[refuted]**: kept, with the
counterexample.

**References to other work.** `AS:` labels refer to `../../../../axiom-schemas/paper/sections/*.tex`; `IL:` labels to
`../../../../inferential-learning/paper/sections/*.tex`. "Track model / universal / pa" are the parallel tracks in
`../model/notes.md`, `../universal/notes.md`, `../pa/notes.md`; I cite their proposition numbers where my computations
test them. I read those notes; I did not rely on them for any proof below.

**Framing.** The code is a small, exact laboratory for checking claims about a Bayesian axiom inducer. It is not a
prover and is not meant to become one.

---

## 0. Summary

**What was built.** `code/bai` computes exact posteriors over finite pools of theories made of DT° templates
(§1). The prior is a prefix code with an optional time factor. There are three likelihoods, all with
Dirichlet-integrated mixture weights: citation (L0), a chain derivation grammar (L1: a cited axiom followed by at
most K ≤ 2 steps of ∀-elimination, Gen, or MP with a cited major premise), and L1 observed through a filter
(L1sel). The verifier accepts s when the posterior mass of theories with T ⊢_K s is at least 1 − δ. Exactness is
proved (Props X1–X4) and checked against brute force, a forward sampler and Monte Carlo (18 unit tests). The main
restriction: the posterior is exact over a pool of hand-specified and data-derived theories, not over the whole
class.

**Answers, with status** (all "computed" claims are from seeded runs listed in §13).

1. **∀xφ from instances (E1, Prop X6).** The posterior identifies the *generator*, at the predicted rates.
   * On closed instance data, mass never moves from the schema H_sch to H_∀ = {∀xφ}. Under L0, H_∀ cannot emit
     instances. Under L1 it loses exactly log₂(1/(1 − c_stop)) bits per datum (one bit here) [proved; computed].
     Under L1sel the odds stay at the prior odds [proved; computed]. So P(T ⊢ ∀xφ | D) → 0 (L0, L1), or it stays
     at the prior share of H_∀ (0.48 or 0.27, L1sel), while P(T ⊢ φ(t*) | D) for held-out instances is ≥ 0.999 from
     n = 8 [computed].
   * When the data come from a theory that proves ∀xφ, L1 finds that theory by n = 16 in every run, and
     P(⊢ ∀xφ) → 1 [computed]. The theories are H_∀, with or without quantified theorems, and H_open with Gen.
   * Under L0, derived theorems can only be explained as axioms. Gen-generated data therefore end at memorisation
     [computed].
2. **PA without labels (E2).** With a well-specified grammar, T* = Q + T_Ind has posterior 0.996 at n = 512, but
   only after every axiom has been cited at least once [computed]. Before that, sound sub-theories win. In 3 of 5
   seeds an *unsound* lump of the rarely used Q axioms has mass ≥ 0.997 at some n ≤ 32 [computed]. A threshold
   verifier with δ = 0.05 then accepts a false sentence such as ∀x∀y(y = x). This is allowed by the soundness
   theorem, whose threshold would have to be 2^(−226)·δ′. Fragmentation of induction by the motive's root does not
   win [computed]: frag-complete stays ≈ 700 bits behind, with O(log n) drift. A false spare slot keeps posterior
   ≈ 0.004 at n = 512 and decays only like n^(−1/2) [computed; Prop X7].
3. **Misspecification (E3).** When all data are theorems of the target but the term or motive law is not the
   model's, the posterior moves at a rate linear in n to the theory that best fits the usage statistics [computed].
   Three kinds of theory win:
   * splits with the same instance set (sound and complete);
   * over-specific theories, such as numeral splits, which are sound but no longer derive φ(2+3);
   * a finite memoriser, when the data's support is finite.

   In PA, when T* loses, the winners are fragments of induction that are deductively equivalent to T* (Prop X9).
   So the result is robust at the level of theorems but not of axioms. Apart from the early lumping already seen in E2, no
   misspecified run moved mass to an over-general theory.
4. **Soundness (E4, Prop X8).** Under well-specification the adaptive prover's win rate is within the Ville bound
   δ′ in every setting [proved; computed]. On the tight construction it stays 9–46 times below the bound, because
   the decoy's Dirichlet factor delays the win; the full pipeline wins on exactly the predicted streams. Under
   misspecification the prover wins almost surely in two cases [computed]:
   * a fraction of false "near miss" data;
   * selected data, when the only competitor that fits better is a decoy.

   With a clean better-fitting theory in the pool, selection was harmless.
5. **Gold (E5, Prop X7).**
   * Spare slots die only polynomially: n^(−1/2) if unused [proved; computed], about n^(−1/4) if nested inside the
     data's support [proof sketch; computed to n = 10⁸, fitted exponent −0.259].
   * With stochastic data both ends of Gold's limit point are identified: L_5 data give L_5, L_∞ data give L_∞
     [computed].
   * On Gold's adversarial text the MAP changes at every stage [computed].
6. **Equivalent axiomatisations (E6).** L1 identifies the generating axiomatisation among logically equivalent ones
   (∀x∀y against ∀y∀x, the schema, and mixed forms) [computed]. L1sel ties them exactly, so the prior decides
   [proved; computed].
7. **Time factor (E7).** A time factor on axiom checking barely moves mass inside DT° (at most 0.016) [computed]. A
   steeper simplicity penalty (λ = 2) makes the early unsound lumping certain (MAP in 5/5 seeds at n = 8) but
   removes the false spare slot faster [computed].

**What can be promised.** If the data are i.i.d. from a theory in the pool, the posterior concentrates on that
theory's data law [known: Doob; Prop X5]. Under L1 that singles out the generating axiomatisation (E6), under L0
its cited axioms, and under a filtered likelihood such as L1sel only a class of tied axiomatisations. The threshold verifier is time-uniformly sound with probability 1 − δ′ for δ ≤ 2^(−bits(T*))·δ′, for
any pool containing T*, even a data-dependent one.

What cannot be promised:
* the "actual axioms" under misspecification;
* soundness at practical thresholds early on;
* completeness when the usage statistics are selected.

On the user's question: it robustly finds the generator, often finds an equivalent system under misspecification,
and gives the actual axioms much mass only when the data look like the model's own derivations.

---

## 1. The model as implemented

Everything below is implemented in `code/bai`; module names are given in brackets.

### 1.1 Sentences, templates, components

* **Syntax** (dtrc `syntax.py`, reused). Terms over 0, S, +, ·; atoms =, <; connectives ¬, ∧, ∨, →, ↔; ∀, ∃. Bound
  variables are de Bruijn indices. Formulas are in closure-normal form: a free *parameter* is read under universal
  closure (`AS:sec:setting:syntax`). Leading ∀'s are not stripped.
* **Single-parameter convention.** The only parameter is w0. A datum such as φ(Sw0) means ∀y φ(Sy). Bodies and
  data with two different parameters are outside the model (probability 0). This keeps the closure-normal renaming
  of parameters the identity, which §2 needs. It is a restriction of the implementation, not of the theory.
* **Templates** (dtrc `templates.py`, reused). DT° templates: metavariable occurrences M(t̄) with metavariable-free
  arguments, every metavariable with a pattern occurrence. Matching is unique and linear (`AS:thm:setting:matching`).
* **Components** [`theory.Component`]. A DT° template in dtrc canonical form, with a *guard* per metavariable:
  `closed` (the body may not contain w0) or `open` (it may). A ground component is a single sentence.
* **Theories** [`theory.Theory`]. Finite sets of components. Deduplication is by canonical template plus guards.

### 1.2 The instantiation grammar Q [`grammar.Grammar`]

A probabilistic context-free grammar over metavariable bodies. The context of a node is (nh, nb, ap): nh holes
(the metavariable's arguments), nb bound variables of the body's own binders, ap = whether w0 is allowed.

* Term node: 0, S, +, · with weights 0.45, 0.35, 0.10, 0.10; a variable with total weight 0.3, split uniformly over
  the nh + nb variables in scope (absent if none); w0 with weight 0.15 (only if ap). Normalised over what is
  available.
* Formula node: =, <, ¬, ∧, ∨, →, ↔, ∀, ∃ with weights 0.35, 0.20, 0.10, 0.10, 0.05, 0.10, 0.02, 0.05, 0.03. A
  quantifier adds a bound variable.

The expected number of same-sort children is 0.75 (closed terms), at most 0.75 (other term contexts) and 0.72
(formulas), all < 1, so Q is a proper distribution: finite trees have total probability 1 [known: extinction of
subcritical branching processes, e.g. Harris, *The Theory of Branching Processes*, 1963 (unverified); directly:
the expected number of formula nodes is at most Σ_k 0.72^k, each formula node has at most two term children, and
each term subtree has expected size at most Σ_k 0.75^k, in every context; so the expected size is finite and the
tree is finite almost surely]. Holes and bound variables are counted alike, so a body with a hole and the same formula with that hole bound
by a quantifier get matching probabilities. This makes splits of a schema by the root symbol of its body exact
reparametrisations under Q (used in E2 and E3).

### 1.3 The prior [`grammar.TemplateCode`, `grammar.theory_bits`, `Theory.log_prior`]

A prefix code for templates, given as −log₂ of a subcritical stochastic grammar over templates:
* formula node ∈ {=, <, ¬, ∧, ∨, →, ↔, ∀, ∃, M} with probabilities 0.20, 0.10, 0.10, 0.10, 0.05, 0.10, 0.05, 0.10,
  0.05, 0.15;
* term node ∈ {0, S, +, ·, var, w0, M} with 0.30, 0.20, 0.10, 0.10, 0.15, 0.05, 0.10 ('var' only with a bound variable
  in scope; renormalised), the variable chosen uniformly (log₂ nb bits);
* an occurrence M: which metavariable of its sort, uniform over the k already introduced and "new" (log₂(k+1) bits);
  a new one codes its arity r with r+1 bits and its guard with 1 bit; its arguments are metavariable-free terms.

A theory {T₁..T_m} costs bits(T) = Elias-gamma(m) + Σ bits(T_i) − log₂ m! (a set of distinct components saves the
order). The prior is π(T) ∝ 2^(−λ·bits(T)) · (1 + |T|)^(−τ), where |T| is the total template size. Defaults λ = 1,
τ = 0. The factor (1+|T|)^(−τ) is the time penalty: deciding whether a sentence is an axiom of T is one linear match
per template, so its time is O(|T|·|s|) and log₂(1+|T|) is its size-dependent part. Examples of theory code
lengths (bits): {?t+0=?t} 17.1; {∀x(x+0=x)} 17.2; {?P} 5.7; T* = Q1..Q7 + T_Ind 226.2 (the template T_Ind alone
costs 44.8).

### 1.4 L0: citation [`Component.logcoef0`, `lik.logcoefs0`]

A theory with weights w emits a datum by choosing component i with probability w_i and drawing a body for each
metavariable from Q (respecting guards). So P(d | T, w) = Σ_i w_i a_i(d) with a_i(d) = Π_M Q(θ_d(M)), θ_d the
unique matcher (Prop X1).

### 1.5 Dirichlet-integrated weights [`lik.dirichlet_marginal`]

The weights get a symmetric Dirichlet(α) prior, α = ½ throughout. The marginal likelihood
M_T(D) = E_w Π_j Σ_i w_i a_i(d_j) is computed exactly (Prop X2):
* data covered by one component are counted directly;
* if at most 3 components overlap, a dense dynamic programme over their counts;
* otherwise variable elimination over count vectors, with a cap of 20000 states. Above the cap the code returns
  rigorous lower and upper bounds (Prop X2(c)) and reports the largest posterior mass the theory could have.
  This happened for Mem and the skeleton theory skel4 in E1 under L1 (the largest posterior mass they could have
  had: 2·10⁻¹⁵; E1 results file), once in E2 and for Mem in E6 (largest possible mass 0 to double precision), and
  not at all in E3 and E4 (seed 0 re-evaluated; `checks/check_bounded.out`).

### 1.6 L1: the chain derivation grammar [`lik.Chain`]

A derivation is a chain s₀, s₁, …, s_k with k ≤ K:
* s₀ = T_iθ, a citation (component i with probability w_i, bodies from Q);
* at step j < K, if some rule applies to s_j, the chain stops with probability c_stop; otherwise it picks an
  applicable rule r with probability c_r / Σ(c over applicable rules), and applies it:
  * **elim** (s_j = ∀xψ): s_{j+1} = ψ[t/x], with t drawn from a term grammar Qe (closed terms; with w0 allowed iff
    `qe_open`);
  * **gen** (s_j contains w0): s_{j+1} = ∀x s_j[x/w0], abstracting every occurrence;
  * **mp** (an *MP component* A → B, A and B DT° with every metavariable of A in B, has A matching s_j): one such
    component is chosen uniformly; s_{j+1} = Bθ, θ read off s_j on A's metavariables and drawn from Q on the rest.
    The major premise is cited; the minor premise is the current sentence.
* if no rule applies, or j = K, the chain stops; the datum is the last sentence.

Defaults: c_stop = ½, c_elim = c_gen = c_mp = 1. K = 1 in the main runs, K = 2 in E1 (allq2) and E6. The chain
never fails, so L1 is a proper distribution (Prop X3). The first citation is the only mixture choice, so
P(d | T, w) = Σ_i w_i a_i^{L1}(d) and §1.5 applies unchanged.

*What the brief asked and what was built.* The brief's grammar is a tree: each node cites or applies MP/∀-elim/Gen
to sub-derivations. The chain grammar is the special case in which every MP has a cited major premise and a
derived minor premise. I chose it because it never fails, so the likelihood needs no normaliser, and because its
exact backward sum is tractable (Prop X4). A tree grammar with derived major premises is not implemented.

### 1.7 L1sel: the chain observed through a filter [`lik.SelChain`, `lik.class_prob_qf`]

A model of "only closed quantifier-free theorems are reported": each citation of component i is repeated until
its chain outputs a closed quantifier-free sentence. So a_i^{sel}(d) = a_i^{L1}(d)/c_i, with c_i the probability that
a chain from component i ends in that class. c_i is computed exactly for components ∀^a φ with φ quantifier-free,
term metavariables only, every leading variable used, and no MP components (a finite Markov chain on (number of
leading ∀, w0 present)); `class_prob_qf` raises an error otherwise and such theories are left out of L1sel pools.
Checked against Monte Carlo (unit test `test_class_prob_monte_carlo`).

### 1.8 Pools and the posterior [`pool.py`, `posterior.evaluate`]

The posterior is computed **by exact enumeration over a finite pool**, i.e. it is the full posterior conditioned on
"the theory is in the pool". The pool is built once per run and then used at every n: hand-specified alternatives
(§§3–9 list them per experiment), Min of random subsets of the first 64 data (dtrc `aligned_min`), skeleton clusters
of the first 64 data (dtrc `DTRC` without refutation, stopped at k), DTRC with refutation (PA only; first 16 and 40
data), plus Mem(D_n), the set of distinct data seen so far, added at each n. So the data-derived members may have
been built from data later than n; this only changes which theories are in the pool, not how they are scored. Mem(D_n) is data-dependent; among memorising theories that cover
D_n it has the largest posterior (any extra sentence costs prior bits and a Dirichlet factor). Theories whose L1
coefficients would need the brute-force fallback of Prop X4 are left out of the L1 pools and listed in the results.

### 1.9 Bounded derivability and the verifier [`posterior.Deriver`, `support_mass`]

T ⊢_K s iff s is the output of some chain of length ≤ K from T with Qe allowing w0 and all rule weights positive,
i.e. iff P_T(s) > 0 under that L1. This is a sound under-approximation of first-order derivability from inst(T)
(each rule is sound: citation, ∀-elimination, Gen on the parameter, MP). The threshold verifier accepts s iff
Σ_{T ⊢_K s} π(T | D) ≥ 1 − δ (sum over the pool and Mem(D_n)). K = 1 in E1, E3a and E4; K = 0 (citation only) in E2
and E3b.

---

## 2. Propositions about the implementation

**Prop X1 (L0 is exact) [proved].** Let T be a component, Q the grammar of §1.2, and d a sentence with at most the
parameter w0. Citing T with independent bodies θ(M) ~ Q (guards respected) yields d with probability
Π_M Q(θ_d(M)) if T matches d with matcher θ_d respecting the guards, and 0 otherwise.

*Proof.* The bodies contain no parameter other than w0, so Tθ contains at most w0 and is already in closure-normal
form; the event "the datum is d" is the event Tθ = d. By `AS:thm:setting:matching` there is at most one θ with
Tθ = d (template parameters, if any, are w0 and map to w0). So P(Tθ = d) = Σ_{θ:Tθ=d} Π_M Q(θ(M)) is the single
term Π_M Q(θ_d(M)) when θ_d exists and respects the guards (a guard-violating body has probability 0 under the
closed grammar), and 0 otherwise. ∎

**Prop X2 (the Dirichlet sum) [proved; computed].** (a) With coefficients a_ij ≥ 0,
E_{w~Dir(α)} Π_j Σ_i w_i a_ij = Σ_z Π_j a_{z_j j} · Γ(mα)/Γ(mα+n) · Π_i Γ(α+n_i(z))/Γ(α), the sum over assignments
z of data to components with a_{z_j j} > 0 and n_i(z) the counts. (b) `dirichlet_marginal` computes this sum.
(c) `dirichlet_bounds` returns L ≤ log M ≤ U.

*Proof.* (a) Expand the product and use E Π w_i^{n_i} = Γ(mα)/Γ(mα+n)·Π Γ(α+n_i)/Γ(α) [known: Dirichlet moments].
(b) The summand depends on z only through Π a and the count vector. Data with one covering component contribute a
fixed factor and a fixed count. For the others, summing over their assignments is summing a product of linear
forms Π_j(Σ_{i∈S_j} a_ij x_i) against the functional x^c ↦ Π Γ(α+c_i); the dense programme (≤ 3 overlapping
components) and the dictionary programme both compute the coefficients of this polynomial exactly. In the dictionary
programme a component's factor Γ(α + c_i) is applied as soon as no later group contains it, which is valid because
the functional is a product over components. (c) Lower: one term of the sum in (a). Upper: E_w L(w) ≤ max_w L(w),
and f = log L is concave on the simplex, so for any w, f(w*) ≤ f(w) + ∇f(w)·(w* − w) ≤ f(w) + max_i ∇_i f(w) − n,
since w·∇f(w) = n. ∎

*Computed.* Against brute-force enumeration of assignments on 300 + 200 random instances (m ≤ 6, n ≤ 9): maximum
difference 1.4·10⁻¹⁴ (unit test `test_dirichlet_dp_exact`; the instances exercise both programmes). The bounds of
(c) bracket the exact value on 100 random instances (`test_dirichlet_bounds_bracket_exact`).

**Prop X3 (L1 is proper) [proved].** For every theory, weights and K, Σ_d P^{L1}(d | T, w) = 1.

*Proof.* The chain makes at most K rule applications. Each step chooses among finitely many outcomes (stop, or an
applicable rule) with probabilities summing to 1, and each rule's random input (a term from Qe, a body from Q, a
uniform choice of MP component) is drawn from a proper distribution (§1.2). A rule is only applied when it applies,
so no run fails. The probabilities of all runs sum to 1, and the datum is a function of the run. ∎

**Prop X4 (the backward recursion is exact) [proved; computed].** Write G_k(s) for the vector (over components i)
of P(s_k = s, first citation i)/w_i. Then G_0(s)_i = a_i^{L0}(s), and for k ≥ 1
  G_k(d) = Σ_{(pred, r, ξ)} G_{k−1}(pred) · (1 − c_stop) · c_r/Σ_{r' applicable to pred} c_{r'} · P(ξ),
summing over predecessors pred, rules r applicable to pred, and random inputs ξ with r(pred, ξ) = d; finally
a_i^{L1}(d) = Σ_k G_k(d)_i · stop_k(d), with stop_k(d) = 1 if k = K or no rule applies to d, and c_stop otherwise.
`Chain.logcoefs` computes this sum exactly for every theory accepted by `l1_exact_supported`, because its
predecessor sets are complete:

(a) *Elim, template-guided.* Let U = ∀xB be a template whose derived template D = B[?u/x] (x replaced by a fresh
0-ary term metavariable) is DT°. Then the pairs (θ, t) with ∀-elim(Uθ, t) = d and x occurring in B correspond
one-to-one to matchers θ' = θ ∪ {u ↦ t} of D against d; so there is at most one.
*Proof.* D is DT° only if x is not an argument of a metavariable occurrence (an argument ?u would not be
metavariable-free). So x occurs in B only at rigid positions, bodies never contain x (λ-convention), and
substituting t for x commutes with plugging the bodies: (Bθ)[t/x] = Dθ'. Uniqueness is `AS:thm:setting:matching`. ∎

The vacuous predecessor ∀x d contributes G_{k−1}(∀x d) with weight Σ_t Qe(t) = 1.

(b) *Elim from bare formula metavariables* ?P and ∀x ?P(x), at step 0. For a parameter-free d, the predecessors are
∀xψ_S with ψ_S = d with a nonempty set S of occurrences of one closed term t replaced by x. Under Q every node of
ψ_S lies in a context with a variable, so Q_F(∀xψ_S) = Q_F(∀x d) · Π_{o∈S} r_o with r_o = (p_var/nv_o)/Q_hv(t),
where nv_o = 1 + (binder depth at o) and Q_hv(t) is t's probability in a context with variables. Summing over S:
Σ_{S≠∅} Q_F(∀xψ_S) = Q_F(∀x d)·(Π_o(1 + r_o) − 1). For ∀x ?P(x) the body probability is the same up to the factor
q(∀). These predecessors have no parameter and no MP component exists in such theories, so elim is the only
applicable rule. If d contains w0 and the guard is closed, the predecessor must have no parameter, so t contains
w0 and S is all occurrences: one predecessor per t.
*Proof.* Direct from the product form of the PCFG; nodes inside a replaced occurrence are removed and replaced by
one variable node; contexts of the remaining nodes do not change between S and ∅ (all lie under the new ∀). ∎

(c) *Gen then elim* (K = 2). A level-1 ∀-sentence from gen is gen(s₀) for a level-0 sentence s₀ = Tθ₀ containing
w0, and ∀-elim(gen(s₀), t) = s₀[t/w0]. Write D for T with its rigid w0 replaced by a fresh ?u. Then s₀[t/w0] = Dθ
with θ(M) = θ₀(M)[t/w0], so θ is the unique matcher of D against d; closed-guard bodies equal θ₀(M); open-guard
bodies θ₀(M) arise from θ(M) by replacing a subset of the occurrences of t by w0; and if T has no rigid w0, t occurs
in some open body. The code enumerates exactly these candidates and keeps those with ∀-elim(gen(s₀), t) = d. ∎

(d) *Gen and MP predecessors* are unique: gen⁻¹(∀xχ) = χ[w0/x] if χ uses x and d has no parameter; for MP,
B is DT° and contains A's metavariables, so θ is the unique matcher of B against d and pred = Aθ.

(e) *Pruning.* A predecessor is skipped only if its (∀-spine, parameter flag) is not in the abstract set of
step k−1, computed forward from the components (elim drops a leading ∀ and may add w0 if Qe allows it; gen adds a
∀ and removes w0; MP gives B's spine). By induction on k every step-k sentence lies in the step-k set, so pruning
never drops a predecessor with G > 0.

*Computed.* (i) The guided recursion equals the brute-force recursion (all subsets of all occurrences, no
templates, no closed forms) to 10⁻⁹ on every datum of random samples from 10 theories, at K = 1 and K = 2
(`test_l1_guided_equals_bruteforce_K1`, `_K2`, `test_star_closed_form_large_numeral`; the brute force is skipped
on data with more than 14 occurrences of one term). (ii) The forward sampler agrees with the exact probabilities
(chi-square over cells with expected count ≥ 20 plus one pooled cell, 30000 samples each, 5 theories:
`test_l1_sampler_matches_exact`). (iii) The exact probabilities of sampled data sum to ≤ 1.

**Prop X5 (what a well-specified posterior can identify) [known: Doob 1949 (unverified page); see track model §2
for a proof for countable classes].** If the data are i.i.d. from a pool theory T* (with weights drawn from the
Dirichlet prior, or T* with one component), the posterior concentrates almost surely on the theories whose
marginal law equals that of T*, and among those it stays proportional to the prior. In particular nothing in the
likelihood separates two theories with the same data law. I use this only as the yardstick for the experiments
below; I did not re-prove it.

**Prop X6 (L1 against L1sel for the universal) [proved; computed].** Let φ be quantifier-free with one variable
used, H_∀ = {∀xφ}, H_sch = {φ(?z)} (closed guard), Qe = Q with closed terms, K ≥ 1. For every closed instance
d = φ(t):
(a) under L1, P_∀(d) = (1 − c_stop)·Q(t) and P_sch(d) = Q(t), so after n closed instances
log₂[π(H_sch|D)/π(H_∀|D)] = log₂[π(H_sch)/π(H_∀)] + n·log₂(1/(1 − c_stop));
(b) under L1sel, P^{sel}_∀(d) = P^{sel}_sch(d) = Q(t), so the posterior odds equal the prior odds for every n.
*Proof.* H_∀ cites ∀xφ; only elim applies (no w0, no MP component); the chain stops with probability c_stop
(datum ∀xφ, not an instance) or eliminates with t ~ Q, giving φ(t), to which no rule applies. t ↦ φ(t) is
injective because x occurs in φ. H_sch cites φ(t) and no rule applies. (b): c_∀ = 1 − c_stop and c_sch = 1. Each
theory has one component, so the Dirichlet integral is trivial. ∎ This is track universal Thm U2 for this grammar
(their c is my 1 − c_stop). The same argument gives exact ties under L1sel among all axiomatisations of §8 whose
fully instantiated matrices are the same template (E6).

**Prop X7 (spare slots) [(a) proved; (b) proof sketch; both computed].** (a) If τ covers no datum, then for every D and every theory T with m
components covering D, M_{T∪{τ}}(D)/M_T(D) = Γ((m+1)α)Γ(mα+n)/(Γ(mα)Γ((m+1)α+n)) ~ (Γ((m+1)α)/Γ(mα))·n^{−α}.
(b) [proof sketch] If τ = φ(S?z) is nested in T = {φ(?z)} and data come from T, the log Bayes factor behaves as
−(α/2)·ln n + O_P(1).
*Proof of (a).* The assignments of data are the same with and without τ, and each assignment has count 0 on τ.
The Dirichlet moment of (a) of Prop X2 then changes by the stated ratio, which does not depend on the assignment;
Stirling gives the rate. ∎ This is the formula of track model §5.
*Sketch of (b).* Under {φ(?z), φ(S?z)} a datum has probability Q(t)(1 − w₂ + w₂/q_S) if t is S-rooted and
Q(t)(1 − w₂) otherwise (q_S = Q's root probability of S, since Q(St') = q_S·Q(t')). So the likelihood ratio is
(1 + w₂(1/q_S − 1))^{n_S}(1 − w₂)^{n−n_S}, a regular one-parameter family whose true value w₂ = 0 is on the boundary;
its log is n·(O_P(n^{−1/2})·w₂ − c·w₂²) near 0, so the integrand is of order 1 on w₂ ≲ n^{−1/2}. The Beta(α, α)
density near 0 is ∝ w₂^{α−1}, so the integral is ≍ ∫₀^{n^{−1/2}} w₂^{α−1} dw₂ ≍ n^{−α/2}. For a disjoint spare the
factor (1−w₂)^n confines w₂ to ≲ 1/n, giving n^{−α} as in (a). The step not written out is the uniform control of
the O_P term. Computed in E5.

**Prop X8 (soundness of the threshold verifier) [(a), (b) proved, adapted from IL:thm:caution:ville(b);
(c) proof sketch].** Let F be a
countable family of theories with prior weights 2^(−bits(T)) (total ≤ 1, because the theory code is prefix-free
up to the set discount, and Σ_{sets} 2^(−bits) ≤ Σ_m 2^(−γ(m))·(Σ_T 2^(−bits(T)))^m ≤ 1). For T ∈ F let M_T be its
Dirichlet-integrated marginal law on data sequences (L0, L1 or L1sel). Fix T* ∈ F and suppose the data
d₁, d₂, … are distributed as M_{T*} (i.i.d. from P_{T*} if T* has one component). Let R_n ⊆ F be any pool, possibly
chosen by looking at the data, with T* ∈ R_n, and let the verifier use the posterior restricted to R_n.

(a) If δ ≤ 2^(−bits(T*))·δ′, then with probability at least 1 − δ′ the verifier never accepts any s with
T* ⊬_K s, at any n, whatever the prover asks and when. The event depends only on the data.
(b) If F is a fixed pool H plus the memorisation family {Mem(S)}, the factor 2^(−bits(T*)) can be replaced by
w* = 2^(−bits(T*)) / (Σ_{T∈H} 2^(−bits(T)) + 1).
(c) [proof sketch; computed] If T* has m components and fixed weights w (not drawn from the prior), (a) holds
with δ′ replaced by δ′ / R(n, m) up to horizon n, where R(n, m) = min_c DirMult_α(c)/Π_i(c_i/n)^{c_i} ≍ n^(−(m−1)/2):
the guarantee is no longer uniform in time.

*Proof.* (a) Let C = Σ_{T∈F} 2^(−bits(T)) ≤ 1 and Z_n = Σ_{T∈F} (2^(−bits(T))/C)·M_T(D_n)/M_{T*}(D_n). Each M_T
is a probability on sequences with Σ_d M_T(D_n d) = M_T(D_n), so under M_{T*},
E[M_T(D_{n+1})/M_{T*}(D_{n+1}) | D_n] = Σ_{d: M_{T*}(D_n d)>0} M_T(D_n d)/M_{T*}(D_n) ≤ M_T(D_n)/M_{T*}(D_n). By
Tonelli Z is a nonnegative supermartingale with Z_0 = 1, and Ville's inequality (`IL:lem:app:caution:ville`) gives
P[sup_n Z_n ≥ 1/δ′] ≤ δ′. The restricted posterior satisfies, pathwise,
π_R(T* | D_n) = 2^(−bits(T*))M_{T*}(D_n) / Σ_{T∈R_n} 2^(−bits(T))M_T(D_n) ≥ (2^(−bits(T*))/C)/Z_n ≥ 2^(−bits(T*))/Z_n,
because R_n ⊆ F and all terms are nonnegative. Off the Ville event this is > 2^(−bits(T*))δ′ ≥ δ. Accepting s needs
posterior mass ≥ 1 − δ on {T ∈ R_n : T ⊢_K s}, which excludes T*, so it needs π_R(T* | D_n) ≤ δ. (b) Same, with
C ≤ Σ_{T∈H} 2^(−bits(T)) + 1. (c) With data i.i.d. from P_{T*,w}, use M = P_{T*,w} as reference measure instead:
Z′_n = Σ_T π(T) M_T(D_n)/P_{T*,w}(D_n) is a supermartingale, and π_R(T* | D_n) ≥ π(T*)·ρ_n/Z′_n with
ρ_n = M_{T*}(D_n)/P_{T*,w}(D_n). Termwise in the assignment expansion of Prop X2(a), DirMult(c) ≥ R(n,m)·Π w_i^{c_i},
so ρ_n ≥ R(n, m). The rate R(n, m) ≍ n^(−(m−1)/2) for α = ½ is the Krichevsky–Trofimov regret [known:
Krichevsky and Trofimov 1981 (unverified)]; computed exhaustively for m = 2, 3, 4 in `checks/kt_regret.py`
(`checks/kt_regret.out`: slopes of log₂ R against log₂ n of −0.499, −0.998, −1.485). ∎

What the proposition does not cover: data that are not distributed as any M_T in F (misspecification), and data
whose selection depends on the prover. E4 shows what happens then.

**Prop X9 (fragments of induction are deductively equivalent) [proved].** Let T_f, for a root symbol f, be T_Ind
with the motive restricted to root f: for = and <, λx.a(x) f b(x) with 1-ary term metavariables a, b; for ¬,
λx.¬P₁(x); for ∧, ∨, →, ↔, λx.P₁(x) f P₂(x); for ∀, ∃, λx.f y P₁(x, y). Let Q⁻ be any set of sentences.
(a) inst({T_f : all 9 roots}) = inst(T_Ind). (b) For each connective f ∈ {¬, ∧, ∨, →, ↔, ∀, ∃}, Q⁻ ∪ {T_f} and
Q⁻ ∪ {T_Ind} have the same first-order consequences. (c) For f ∈ {=, <} this argument does not apply.

*Proof.* (a) Every motive body has one of the 9 roots, and an instance of T_Ind whose body has root f is the
instance of T_f whose sub-bodies are read off the body (for ∀, ∃ the bound variable becomes the second argument
of P₁). Conversely every instance of T_f is an instance of T_Ind. (b) inst(T_f) ⊆ inst(T_Ind) gives one direction.
For the other, let φ be any motive and choose: for ∧ and ∨, P₁ = P₂ = φ; for ¬, P₁ = ¬φ; for → and ↔, P₁ = (0=0),
P₂ = φ; for ∀ and ∃, P₁(x, y) = φ(x). In each case the chosen body ψ satisfies ⊢ ∀x(ψ(x) ↔ φ(x)) in first-order
logic with equality (for ∃ because domains are nonempty; for ¬ by double negation). Ind(ψ) is
(ψ(0) ∧ ∀x(ψ(x) → ψ(Sx))) → ∀xψ(x); replacing ψ by the equivalent φ in all three places gives Ind(φ). ∎
This is the "any non-atomic connective" observation of the earlier conversation (`../../../../axiom-schemas/research/conversation.md` §7)
and of track pa §2.

---

## 3. E1: ∀xφ from data about φ

**Setup** (`code/experiments/e1_universal.py`; results `code/results/e1_universal.md`, `.json`). φ ∈ {x+0=x, 0+x=x,
¬(Sx=0)}, given as templates P = φ(?t). Seeds 0–4; n = 1, 2, 4, …, 256 (prefixes of one data stream per seed).
Generators:
* **sch**: L0 citations of φ(?t), closed terms from Q;
* **all**: the L1 chain (K = 1, closed elim terms) from H_∀ = {∀xφ}; about half of the data are ∀xφ itself, the rest
  closed instances;
* **allq**: the same with open elim terms (instances such as φ(Sw0), i.e. the quantified theorem ∀yφ(Sy) in
  closure-normal form);
* **open**: the L1 chain (K = 1, open elim terms) from H_open = {φ(?t), guard open}; Gen turns open instances into
  explicit ∀-sentences such as ∀yφ(Sy);
* **allq2**: the L1 chain with K = 2 from H_∀ (elim with an open term, then Gen), which emits explicit quantified
  theorems derived from ∀xφ.

Pool (about 16–19 theories plus Mem(D_n)): H_∀, H_sch, H_open, H_∀+sch, H_∀+open, the over-specific {φ(0), φ(S?z)},
the root splits frag1 (4 templates) and frag2 (37 templates), three spare-slot theories ({φ(?t), φ(S?z)},
{φ(?t), 0=S0}, {φ(?t), ?u·0=0}), the one- and two-step generalisations of P (over-general), the bare ?P, Min of
random data subsets, skeleton clusters, and Mem(D_n). Likelihoods: L0; L1 with the generator's own chain (well
specified); for sch data also L1sel. The L1 pools contain only theories with exact L1 (§1.8); this excluded the
skeleton theories skel2 and skel4 for the open and allq2 generators (all seeds) and one Min theory (allq2, one
seed), and nothing else. For allq2 (K = 2) the pool has no bare formula metavariables. No L1 coefficient used the brute-force
fallback (inexact counters 0 in all runs).

**Results** (means over 5 seeds and, where the three φ agree, over φ; the φ differ only through prior bits).

| generator | likelihood | mass of the generating theory at n = 4, 8, 32, 256 | MAP at n = 256 (all runs) | P(T ⊢₁ ∀xφ \| D) at n = 256 | first n with generator mass ≥ 0.99 from then on (worst run) |
|---|---|---|---|---|---|
| sch | L0 | 0.87, 0.97, 1.000, 1.000 | H_sch | 2·10⁻⁷ | 16 |
| sch | L1 | 0.84, 0.96, 1.000, 1.000 | H_sch | 3·10⁻⁷ | 16 |
| sch | L1sel | 0.43, 0.42, 0.53, 0.59 | H_sch | 0.484 (x+0=x, 0+x=x), 0.269 (¬(Sx=0)) | never (tie with H_∀) |
| all | L0 | H_∀ dies at the first instance; H_∀+sch takes 1.000 by n = 32 | H_∀+sch | 1.000 | – |
| all | L1 | 0.87, 0.99, 1.000, 1.000 | H_∀ | 1.000 | 16 |
| allq | L0 | H_∀+open takes 1.000 by n = 8 | H_∀+open | 1.000 | – |
| allq | L1 | 0.73, 0.90, 1.000, 1.000 | H_∀ | 1.000 | 16 |
| open | L0 | Mem takes 1.000 by n = 16 | Mem | 1.000 | – |
| open | L1 | 0.89, 1.000, 1.000, 1.000 | H_open | 1.000 | 8 |
| allq2 | L0 | Mem takes 1.000 by n = 16 | Mem | 1.000 | – |
| allq2 | L1 | 0.88, 0.997, 1.000, 1.000 | H_∀ | 1.000 | 16 |

Further computed facts (results file, per φ and seed):
* **The L1 factor is exact.** On sch data the log₂ posterior odds H_sch : H_∀ under L1 are n + 0.09 for x+0=x and
  0+x=x, and n + 1.4 for ¬(Sx=0), at every n and seed: one bit per datum (c_stop = ½) plus the prior difference.
  This is Prop X6(a) and track universal Thm U2.
* **L1sel is an exact tie.** Under L1sel the odds H_sch : H_∀ stay at the prior odds (0.09 or 1.4 bits) for all n,
  and P(T ⊢ ∀xφ | D) converges to the prior share of H_∀ among the tied theories (0.484 or 0.269), not to 0 or 1
  (Prop X6(b); track universal Thm U10, first regime).
* **Instance generalisation.** The posterior mass of theories deriving a held-out closed instance φ(t*) (mean of
  three) is ≥ 0.999 from n = 8 in every run under L1 and L1sel, and under L0 in every run except open data, where it
  is 0 at n = 4 and 8 in the worst run (Mem without ∀xφ wins there) and 1.000 from n = 16. "All instances follow" is
  learned quickly whichever theory wins.
* **Memorisation and over-general templates die fast.** On sch data at n = 8, Mem's mass is ≤ 2.4·10⁻¹² and the
  over-general theories (bare ?P and the generalisations of P) sum to ≤ 7·10⁻⁵, under L0 and L1, in every run (size
  principle); both keep falling exponentially (tables).
* **Under L0, derived data must be axioms.** Data that are outputs of derivations (∀xφ next to its instances;
  Gen-outputs ∀yφ(Sy)) are explained under L0 only by theories that contain them as axioms: H_∀+sch, H_∀+open, or
  Mem. With Gen-outputs of unbounded variety (open, allq2), L0 ends at Mem: citation alone cannot represent
  "theorems of a small theory".

**Verdicts on the brief's H4 (E1 part).**
* "Instance data move mass away from memorisation and over-general templates at an exponential rate": **computed,
  confirmed** for over-general templates and for Mem under these term laws (Mem has to pay for every new
  instance; track universal Prop U6 shows slower, non-exponential decay for memorisers with learned weights under a
  geometric numeral law, which E1 does not test).
* "Instance data do not by themselves move mass from H_sch to H_∀; under a derivation likelihood they may move it
  the other way by c^(−n)": **computed, confirmed exactly** (L1: one bit per datum; L1sel: no movement; L0: H_∀ has
  likelihood 0 on instances).
* "'All future data are φ-instances' gets probability → 1, but 'the axioms prove ∀xφ' need not": **computed,
  confirmed**: P(⊢ held-out instance) = 1 from n = 8 while P(⊢ ∀xφ) → 0 (L0, L1) or stays at the prior share
  (L1sel).
* "With open instances and Gen, H_open ⊢ ∀xφ": **computed**: H_open is identified on open data and P(⊢∀xφ) → 1.
* "Quantified theorems whose derivations use ∀xφ shift mass to H_∀": **computed, confirmed under L1** when they are
  generated by H_∀ (allq, allq2), and **refined**: if the quantified theorems come from H_open with Gen, the mass
  goes to H_open, which also proves ∀xφ. Under L0 they shift mass to theories that list them, not to H_∀.

---

## 4. E2: unlabelled PA mixture

**Setup** (`code/experiments/e2_pa.py`, `pa_common.py`; results `code/results/e2_pa.md`, `.json`). Data: L0 citations
from T* = Q1..Q7 + T_Ind (dtrc `schemas.py`) with weights 0.05 for each Q axiom and 0.65 for T_Ind; induction
motives from Q (one hole, no parameter). Seeds 0–4; n = 8, …, 512. Likelihood L0 with the same Q (well specified).
Pool (about 24 theories + Mem(D_n), depending on the seed): T*; T* − Qᵢ for each i ("sub-T*"); frag-complete (Q + the 9 root fragments T_f of
Prop X9); frag-observed64 (Q + the fragments for the roots seen in the first 64 data); frag-atoms (Q + T_=, T_<);
spare slots T* + T_∧ (nested), T* + ∀x(0+x=x) (a true sentence), T* + 0=S0 (a false one); IndSwap (Q + the
deductively equivalent swapped induction template, never cited); over-general variants of induction ("any base",
"any antecedent"); Q-lumped ({∀x∀y ?P(x,y), ∀x ?P(x), T_Ind}); bare ?P; skeleton clusters (k = 4, 6, 8) and DTRC with
refutation (on the first 16 and 40 data); Q + Min of random data subsets; Mem(D_n). Deductive-equivalence tags are
by Prop X9 and by construction; "unsound" = contains a false axiom or an over-general template refuted in ℕ.

**Posterior mass (means over 5 seeds).** "Unsound" = theories with a false axiom or a template for which the dtrc
PA refuter finds a false instance (`pa_common.refuted_template`; budgeted, so "not refuted" is not "sound").

| n | T* | equivalent to T* (incl. T*) | sub-T* | unsound | MAP (count over seeds) |
|---|---|---|---|---|---|
| 8 | 2·10⁻²⁶ | 2·10⁻²⁶ | 0.60 | 0.40 (1.0 in seeds 1, 4) | DTRC(n=16) ×3, Q-lumped ×2 |
| 16 | 8·10⁻²² | 8·10⁻²² | 0.60 | 0.40 (≥ 0.997 in seeds 1, 4) | DTRC(n=16) ×3, Q-lumped ×2 |
| 32 | 0.197 | 0.197 | 0.60 | 0.20 (1.0 in seed 2: skel4) | T*−Q2 ×2, skel6, skel4, T* |
| 64 | 0.790 | 0.790 | 0.20 | 0.010 | T* ×4, T*−Q3 |
| 128 | 0.991 | 0.991 | 0 | 0.009 | T* ×5 |
| 512 | 0.996 | 0.996 | 0 | 0.004 (spare-false) | T* ×5 |

(sub-T* = T* minus some Q axioms not yet seen, with T_Ind; DTRC(n=16) and skel6 are of this kind. skel4 contains
the lump ∀x∀y ?P0(y, x), refuted by ∀x∀y(y = x).)

**Code length relative to T* (bits, mean over seeds; positive = worse).**

| n | frag-complete | T* + T_∧ (nested spare) | T* + ∀x(0+x=x) (unused true) | T* + 0=S0 (unused false) | Q-lumped |
|---|---|---|---|---|---|
| 8 | 697.0 | 88.0 | 13.8 | 5.1 | −91.3 |
| 64 | 704.1 | 89.0 | 15.1 | 6.3 | 203.1 |
| 512 | 716.7 | 89.6 | 16.6 | 7.8 | 2941.0 |

**Findings.**
1. **The true theory takes the mass, but only after every axiom has been used once** [computed]. Before that the
   posterior prefers T* minus the unseen axioms (sound but weaker): an axiom that has never been cited costs its
   prior bits plus the Dirichlet factor of Prop X7(a). In the five seeds the last Q axiom first appears at datum
   64, 37, 65, 54 and 26; T* is the MAP in every seed from n = 128 and has mass 0.996 at n = 512.
2. **Early lumping is unsound, and a practical threshold does not stop it** [computed]. At n ≤ 16 the theory
   Q-lumped, which replaces the Q axioms by ∀x∀y ?P(x, y) and ∀x ?P(x), is preferred to T* by 34–119 bits in every
   seed, and it is the MAP with mass ≥ 0.997 in seeds 1 and 4. In seed 2 at n = 32 the data-derived skeleton
   theory skel4, which contains the lump ∀x∀y ?P0(y, x), has mass 1.0. So in 3 of 5 seeds, at some n ≤ 32, the
   posterior puts ≥ 0.997 on a theory that cites false sentences (∀x(x+0 = 0); ∀x∀y(y = x)), and a threshold
   verifier with δ = 0.05 **accepts a false sentence**. This does not contradict Prop X8: its guarantee needs
   δ ≤ 2^(−bits(T*))·δ′ with bits(T*) = 226, a threshold no practical verifier uses. From n = 64 the lumps are
   worse than T* in every seed (Q-lumped: +148 to +243 bits at n = 64, +2737 to +3280 at n = 512) and the unsound
   mass is the spare-false slot only. This is the Bayesian form of the MDL observation `AS:app:many:mdl` that
   rarely used ground axioms are lumped unsoundly.
3. **With a well-specified Q, fragmentation does not win** [computed; consistent with `AS:prop:many:mdlwell`].
   frag-complete has exactly T*'s instance set (Prop X9(a)), and its family of data laws contains T*'s law (take
   the weight of T_f to be w_Ind·q(f), with q(f) Q's probability of root f; §1.2 makes this exact). So it can only
   lose: its code length exceeds T*'s by the prior difference (698.9 bits) plus a Dirichlet term growing like
   (16 − 8)/2·log₂ n: +697 at n = 8, +717 at n = 512 (≈ 3.3 bits per doubling of n; the asymptotic value is 4).
4. **Spare slots decay polynomially, at the predicted rates** [computed; Prop X7]. Unused spare sentences grow by
   0.45–0.47 bits per doubling (α = ½), the nested T_∧ by ≈ 0.27 bits per doubling (α/2). So the inconsistent theory
   T* + 0=S0 keeps posterior mass 0.004 at n = 512 and loses it only like n^(−1/2): positive data never refute it.
5. **A deductively equivalent but uncited axiomatisation gets nothing** [computed]. IndSwap has the same theorems as
   T* but likelihood 0 under L0 from the first induction datum. Under citation, identification is of the cited
   axioms, not of the theory.
6. **Over-general induction templates die fast** [computed]: "any base" and "any antecedent" are 49–888 bits
   worse than T* at n = 8 and at least 336 bits worse from n = 32 in every seed.

---

## 5. E3: misspecification

**Setup** (`code/experiments/e3_misspec.py`; results `code/results/e3_misspec.md`, `.json`). In every generator all
data are theorems of the target (instances of φ(?t), or Q axioms and induction instances), but their distribution
is not that of any pool theory. Seeds 0–4.

**(a) φ = x+0=x**, model Q = default grammar, likelihoods L0 and L1 (closed elim, K = 1), n up to 1024 (L0) and 512
(L1). Generators: *heavy*: a zeta(1.5) numeral S^k0 (k ≤ 400) with probability 0.7, else S^k(t₁ ∘ t₂) with zeta k
and Q-terms; *numerals*: S^k0 with k ~ Geometric(0.2); *small*: Q-terms selected to have at most 4 symbols (a
selected set of theorems, 12 distinct sentences); *skewQ*: another PCFG (0: 0.5, S: 0.1, +: 0.2, ·: 0.2). Pool: the
E1 pool plus numeral splits N_m = {φ(0), …, φ(S^{m−1}0), φ(S^m ?z)} for m = 1..4. Theories are grouped by their
instance set relative to inst(φ(?t)): the same (H_sch, frag1, frag2, {φ(?t), φ(S?z)}), a subset (over-specific;
incomplete), a superset (over-general, spare slots with extra sentences, H_open), ∀-type, Mem.

| generator | MAP at the largest n (all 5 seeds, L0 and L1 alike unless noted) | instance set of the MAP | gain of the MAP over H_sch (bits; L0, n = 1024) | P(⊢ held-out instance) | mass on superset theories |
|---|---|---|---|---|---|
| heavy | {φ(?t), φ(S?z)} (from n = 128) | same | 140–178, linear in n | 1.000 | ≤ 4·10⁻²⁷ |
| numerals | N_4 (from n = 128); Mem in 1 seed at n = 1024 | subset | 1989–2228 | 0.333 (only the numeral one) | ≤ 4·10⁻²⁸⁰ |
| small | H_sch up to n = 512; Mem at n = 1024 (L0, all seeds) | same → finite | 151–160 at n = 1024 | 1.000 → 0.000 | ≤ 7·10⁻⁵ |
| skewQ | frag1 (from n = 512) | same | 186–251 | 1.000 | ≤ 2·10⁻²⁰ |

**Findings.**
1. **The posterior moves to the theory that best matches the usage statistics, at a rate linear in n**
   [computed]. The gains double when n doubles (heavy: 74–79 bits at n = 512 under L1, 140–178 at n = 1024 under
   L0). This is the misspecified half of `AS:sec:many:mdl` ("MDL tracks the statistics of usage, not the logical
   boundaries of schemas") in Bayesian form: the model's Q fixes the usage statistics, and a theory with extra
   components can re-weight them.
2. **In these runs misspecification never moved mass to over-general (unsound) theories** [computed]: the superset
   mass is at most 7·10⁻⁵ at the largest n in every run, and at most 2·10⁻²⁰ except for *small* under L1. The
   winners are splits with the same instance set (heavy, skewQ), over-specific theories (numerals), or a finite
   memoriser (small). With positive data only, a superset theory always pays the size principle, so this is expected; it is
   not a guarantee (see E4 C1 for data with mistakes).
3. **What fails is completeness** [computed]. With numerals only, the winner N_4 does not derive φ(2+3) or φ(1·4):
   the posterior mass on theories deriving these held-out instances falls to 0 (only the numeral instance φ(9) is
   derived). With a finite selected support (*small*), the posterior concludes that the axioms are exactly the
   12 observed sentences once n ≈ 1024, and no held-out instance is derived. Both are reasonable inferences from
   the data seen; both lose the universal law that generated the theorems before selection.
4. **Under L1 the same happens**; L1 adds the factor of Prop X6 against H_∀-type theories and otherwise agrees with
   L0 on instance-only data (computed: identical MAPs at every n ≤ 512 in every run).

**(b) PA mixture with a misspecified motive law** (L0; same weights as E2; n up to 2048). Generators:
*dtrc-motive* (motives from the dtrc generator `pa_motive`, without parameters: bounded quantifiers, other
frequencies); *root-skew* (motive root drawn from {→ 0.5, ∧ 0.2, = 0.2, ∃ 0.1}, the rest from Q); *deep* (a PCFG
with more connectives). Pool: the E2 pool plus T* + T_f for every root f (nested fragments; T* + T_∧ is the E2
theory spare-nested(T_∧), so the code-length table in the results file shows it as "inf" under its other name).

| generator | MAP at n = 256 / 1024 / 2048 (all seeds) | mass equivalent to T* at 2048 | T* at 2048 | unsound mass at n = 16 (mean; max over seeds) |
|---|---|---|---|---|
| dtrc-motive | T* / T* + T_∃ / T* + T_∃ | 1.000 | 5·10⁻⁷⁰ | 0.20; 1.0 (seed 1: Q-lumped) |
| root-skew | T* + T_→ / frag-observed64 / frag-observed64 | 1.000 | 0 | 0.29; 1.0 (seed 1: Q-lumped) |
| deep | T* / T* / T* | 0.998 | 0.998 | 3·10⁻¹¹ |

Code length relative to T* at n = 2048 (bits, range over seeds): root-skew: frag-observed64 −1387 to −1509,
frag-complete −965 to −1087, T* + T_→ −789 to −957; dtrc-motive: frag-complete +8 to +125; deep: frag-complete
+665 to +674.

**Findings (b).**
5. **Axiom-level identification fails under a misspecified motive law; theorem-level identification survives**
   [computed; Prop X9]. With dtrc motives the posterior moves from T* (0.994 at n = 256) to T* + T_∃ (a nested
   fragment that re-weights existential motives) by n = 1024. With the root-skewed law it moves to T* + T_→ and
   then to the observed-root split frag-observed64 (the four roots the generator uses), which beats T* by 1387–1509
   bits at n = 2048. All winners are deductively equivalent to T* (they contain T_Ind or a connective fragment),
   so the mass on theories with T*'s theorems stays 1.000. With the *deep* law, which changes the frequencies but not in a way a single fragment can
   exploit cheaply, T* keeps 0.998.
6. **Citation-level derivability is lost even when theorems are kept** [computed]. Under root-skew, the winner
   frag-observed64 lacks the fragments for roots not seen in the first 64 data, so it does not *cite* every
   held-out induction instance (mass deriving them at K = 0: 0.533), although it proves them all (Prop X9(b)).
7. **The early unsound lumping recurs** (seed 1 under dtrc-motive and root-skew, mass 1.0 at n = 16), as in E2.

---

## 6. E4: an adaptive prover against the threshold verifier

**Setup** (`code/experiments/e4_ville.py`; results `code/results/e4_ville.md`, `.json`; check
`checks/check_e4_tight.py`). The verifier accepts s iff the posterior mass of {T : T ⊢₁ s} is ≥ 1 − δ. The prover
wins if some s with T* ⊬₁ s is ever accepted. The bound of Prop X8 is P(win) ≤ δ′ when δ = w*·δ′.

**(A) The tight construction** (`IL:prop:caution:tight` in theory form). T* = {φ(?t)} with numerals only and
P(t = 0) = 1 − u; the decoy T′ = {φ(0), 0=S0}; prior w* on T*; the prover asks 0=S0 in every round. T′ fits the
frequent datum φ(0) better (Dirichlet weight on one sentence) and dies at the first other datum. The prover wins
iff the first t* data are φ(0), where t* is the first n with π(T* | φ(0)ⁿ) ≤ δ; so P(win) = (1 − u)^t* exactly.

| u | w* | δ′ | t* | exact P(win) | closed-form Monte Carlo (10⁵ streams) | full pipeline (400 streams) | bound δ′ | selected data (only φ(0)) |
|---|---|---|---|---|---|---|---|---|
| 0.05 | 0.01 | 0.01 | 150 | 0.00046 | 0.00046 | 0/400 | 0.01 | 20/20 |
| 0.01 | 0.001 | 0.05 | 680 | 0.00108 | 0.00123 | not run | 0.05 | 20/20 |
| 0.5 | 0.01 | 0.01 | 10 | 0.00098 | 0.00095 | 2/400 | 0.01 | 20/20 |
| 0.1 | 0.1 | 0.1 | 47 | 0.00707 | 0.00694 | 5/400 | 0.1 | 20/20 |
| 0.2 | 0.05 | 0.2 | 17 | 0.02252 | 0.02298 | 6/400 | 0.2 | 20/20 |

* The win probability is always below the bound δ′ [computed; Prop X8]. Here it is 9–46 times below it. The
  Dirichlet factor of T′ (≈ n^(−1/2)) delays t* compared with the fixed-weight construction of
  `IL:prop:caution:tight`, which reaches 0.99δ′.
* The full pipeline (posterior + derivability + threshold) wins on exactly the streams where the first t* data are
  φ(0): 400/400 agreement in two settings (`checks/check_e4_tight.out`).
* With *selected* data (only φ(0) is ever shown; every datum is still a theorem of T*), the prover wins in every
  run. Well-specification of the theorem set is not enough; the data law matters (track model Prop 4.2).

**(B, C) Pools.** φ = x+0=x, T* = H_sch. Pool: the E1 hand alternatives (those with exact L1) plus Mem(D_n), and per
setting one extra theory. w* = 2^(−bits(T*))/(Σ_pool 2^(−bits) + 1) = 7·10⁻⁶ (Prop X8(b), valid with the
data-dependent Mem). δ = 0.05·w*, so the bound is 0.05. In every round the prover asks every statement of a fixed
list that T* does not derive: ∀x(x+0=x), 1+0=0, 0+0=1, S0+0=0, 0=S0, 2+0=3, 7+0=8, (1+1)+0=S(1+1), 0=0. Two of
these are true (∀x(x+0=x), 0=0); the guarantee is about derivability from T*, not truth. 100 streams per row,
n = 1..256, L0 and L1 (closed elim, K = 1) alike.

| setting | data | prover wins (L0 / L1) | largest mass ever on an invalid query (L0 / L1) | MAP at n = 256 |
|---|---|---|---|---|
| B | well specified: L0 citations of φ(?t) | 0/100 / 0/100 | 0.45 / 0.53 (at small n) | H_sch ×100 |
| C1 | 10% of data replaced by false near misses t+0=St; the pool also has {φ(?t), ?t+0=S?t} | 100/100 / 100/100 | 1.00 / 1.00 | {φ(?t), ?t+0=S?t} ×100 |
| C2 | heavy-tailed terms (as E3 heavy) | 0/100 / 0/100 | 0.45 / 0.54 | {φ(?t), φ(S?z)} ×96, H_sch ×4 |
| C3 | only φ(0) is shown; the decoy T′ is in the pool | 0/100 / 0/100 | 0.11 / 0.11 | Mem ×100 |

**Findings** [computed].
1. **Well specified: no wins**, within the bound. The largest mass ever put on theories deriving an invalid query is
   0.53. It sits mostly on H_open, which derives the true but T*-underivable ∀x(x+0=x) by Gen, and on bare ?P at
   n = 1; it is below 0.09 from n = 8 in the stream inspected, and never near 1 − δ.
2. **Mistakes in the data make the verifier accept false sentences, every time.** The posterior goes to the theory
   that also contains the mistake pattern, and accepts false instances such as 0+0=1 (98 streams) or 2+0=3
   (2 streams), first at n = 1 to 39 (median 7; at n = 1 when the first datum is itself that mistake).
   Relative to the generator this is no failure: the generator is that two-schema theory, and Prop X8 applies to it
   (with fixed weights, X8(c)). Relative to the intended T* it is the failure that the brief's H2 anticipated:
   nothing forces the data-law minimiser to be "the actual axioms".
3. **Misspecification by heavy tails or by selection did no harm here, because a clean better-fitting theory was in
   the pool.** Under selection the posterior goes to Mem = {φ(0)} rather than to the decoy {φ(0), 0=S0}, which
   costs more prior bits and a Dirichlet factor. Compare (A), where the decoy was the only alternative and won
   every time. Soundness under misspecification depends on what else is in the pool; I have no theorem for this
   (open problem 5).

---

## 7. E5: spare slots, L_∞ against L_k, and Gold's text

**Setup** (`code/experiments/e5_gold.py`; results `code/results/e5_gold.md`, `.json`). Seeds 0–9 (numpy seed 0 for
the quadrature draws). Dirichlet α = ½.

**(a) Spare slots** [computed; Prop X7]. Data: L0 citations of φ(?t) (φ = x+0=x). Exact log₂ Bayes factors of
T + spare against T = {φ(?t)}.

| spare | mean log₂ BF at n = 1, 16, 256, 4096 | slope against log₂ n (n = 256 → 4096) | extra prior bits |
|---|---|---|---|
| false sentence 0=S0 (never cited) | −1.00, −2.84, −4.83, −6.83 | −0.500 | 8.4 |
| disjoint schema ?u·0=0 (never matched) | −1.00, −2.84, −4.83, −6.83 | −0.500 | 14.5 |
| nested φ(S?z) | +0.17, −1.05, −2.85, −3.97 | −0.281 | 21.3 |

The two unused spares agree with the exact formula of Prop X7(a) to all printed digits on every seed (the factor
does not depend on the data). The nested spare decays more slowly. Part (a2) computes it by quadrature up to
n = 10⁸: the Bayes factor depends only on n and the number n_S of S-rooted data (Prop X7(b)), so
BF = E[(1 − w₂ + w₂/q_S)^{n_S}(1 − w₂)^{n−n_S}] with w₂ ~ Beta(½, ½) and q_S = 0.35; n_S ~ Binomial(n, q_S), 200
draws per n. The quadrature agrees with the exact DP at n = 500 to 10⁻⁴ bits (two seeds: −3.97229 against
−3.97236, −3.16922 against −3.16926).

| n | 10² | 10⁴ | 10⁶ | 10⁸ |
|---|---|---|---|---|
| mean log₂ BF, nested spare | −2.11 | −3.87 | −5.50 | −7.27 |

The least-squares slope of the mean against log₂ n over n = 10²…10⁸ is −0.259; the slopes per decade lie between
−0.224 and −0.290. This supports the rate n^(−α/2) = n^(−1/4) of Prop X7(b) and track model Prop 5.5(c)
[computed; the proposition itself is a proof sketch].

So a spare slot never dies at an exponential rate. A spare slot holding a false sentence makes the theory
inconsistent, and positive data remove it only like n^(−1/2), on top of its prior cost. This is what Gold's
theorem leaves to a Bayesian learner: no refutation, only polynomial attrition.

**(b) L_∞ against L_k** [computed]. Numerals only: Q_num gives S^j0 probability 2^(−(j+1)).
L_k = {φ(0), …, φ(S^{k−1}0)} (k ground sentences with Dirichlet weights), k = 1..40, and L_∞ = {φ(?t)}. Prior
bits: L_1 10.9, L_5 89.4, L_8 187.9, L_∞ 17.1.
* Data i.i.d. uniform on L_5: the posterior first prefers L_∞ (prior), then switches to L_5 between n = 64
  (mass of L_5: 2·10⁻⁶) and n = 128 (0.66), and has L_5 mass 1.000 from n = 256 in all 10 seeds. Per datum L_5
  gains 3 − log₂5 ≈ 0.68 bits over L_∞ (code length log₂5 = 2.32 bits against the mean code length 3 bits under
  Q_num), which repays the 72-bit prior difference, plus L_5's Dirichlet cost of about 2 log₂ n bits, between
  n = 64 and 128.
* Data i.i.d. from L_∞: L_∞ has mean mass 0.986 at n = 4, 0.999 at n = 8, and 1.000 from n = 16; it is the MAP
  in all 10 seeds from n = 4.
So with stochastic data the Bayesian learner identifies both ends of Gold's limit point, L_5 and L_∞
(conversation §9's "L_∞ versus L_5"): it does not need to choose a preference in advance; the size principle
decides.

**(c) Gold's text** [computed]. Against the MAP learner over {L_1, …, L_60, L_∞}, stage i presents
φ(0), …, φ(S^{i−1}0) round-robin until the MAP is L_i. Every stage ends: lengths 1, 24, 81, 115, 104, 83, 68, 55,
45, 39, 33, 33, 32, 27 for i = 1..14 (740 data). The sequence is a text for L_∞ and the MAP changes at every
stage, as Gold's theorem requires of some text. The stages shorten after i = 4 because L_∞'s cost per datum on
round-robin data grows with i (mean code length 1 + (i−1)/2 bits) while L_i pays log₂ i. Such texts have
probability 0 under i.i.d. sampling from L_∞, which is why (b) succeeds.

---

## 8. E6: equivalent axiomatisations under the derivation likelihood

**Setup** (`code/experiments/e6_equivalent.py`; results `code/results/e6_equivalent.md`, `.json`). Commutativity of
+, in five forms: A_xy = {∀x∀y x+y=y+x}, A_yx = {∀y∀x x+y=y+x}, the closed schema S_ab = {?a+?b=?b+?a}, and the mixed
M_x = {∀x x+?b=?b+x}, M_y = {∀y ?a+y=y+?a}; also A_xy+A_yx, A_xy+S_ab and Mem(D_n). With closed elim terms they emit
the same closed instances; they differ in their partially instantiated outputs (∀y t+y=y+t against ∀x x+t=t+x). Prior
bits: A_xy, A_yx 31.6; S_ab 30.0; M_x, M_y 28.4. Data: the L1 chain (K = 2, c_stop = ½, closed elim terms) from A_xy
and from M_x, and L0 citations of S_ab; seeds 0–4; n up to 256. Likelihoods: L1 (that chain) and L1sel (the same
stream filtered to closed quantifier-free outputs).

| data from | L1: generator's mass at n = 2, 4, 8, 16 | L1: n = 256 | L1sel at every n ≥ 8 (all three sources) |
|---|---|---|---|
| A_xy | 0.32, 1.000, 1.000, 1.000 | A_xy 1.000 | A_xy 0.044, A_yx 0.044, S_ab 0.128, M_x 0.392, M_y 0.392 |
| M_x | 0.78, 0.993, 1.000, 1.000 | M_x 1.000 | the same |
| S_ab | 0.39, 0.65, 0.977, 1.000 | S_ab 1.000 | the same |

**Findings** [computed; Prop X6 for the tie].
1. **L1 identifies the generating axiomatisation among logically equivalent ones** by n = 16 in every run: ∀x∀y is
   told apart from ∀y∀x after a handful of data, through outputs such as ∀y(2+y = y+2). This is the brief's
   "identification is of the generator, not of the theory" (H2; track model Prop 2.5).
2. **Under L1sel all five are tied exactly.** Their likelihoods are equal on every datum, so the posterior is the
   prior, renormalised, whichever of the three generated the data (exactly so from n = 8 on; before that Mem holds
   up to 0.031). The cheapest forms (the mixed ones) get the most mass. With only fully
   instantiated theorems in view, the method cannot prefer the textbook axiom to its variants; only the prior can.
3. **Two equivalent axioms are not better than one.** A_xy+A_yx and A_xy+S_ab stay below 10⁻¹⁰: a redundant
   second form is a spare slot.

---

## 9. E7: the time factor and a steeper simplicity penalty (brief H6)

**Setup** (`code/experiments/e7_prior.py`; results `code/results/e7_prior.md`, `.json`). The E2 data, pools and
seeds; prior π(T) ∝ 2^(−λ·bits(T))·(1+|T|)^(−τ) for (λ, τ) ∈ {(1, 0), (1, 1), (1, 4), (2, 0), (½, 0)}. Template
sizes: T* 77 symbols, frag-complete 287, Q-lumped 22, bare ?P 1.

| (λ, τ) | T* at n = 64 / 512 | unsound mass at n = 8 / 16 / 32 / 512 | MAP at n = 8 (5 seeds) |
|---|---|---|---|
| (1, 0) | 0.790 / 0.996 | 0.401 / 0.399 / 0.203 / 0.004 | DTRC(n=16) ×3, Q-lumped ×2 |
| (1, 1) | 0.791 / 0.996 | 0.401 / 0.400 / 0.203 / 0.004 | DTRC(n=16) ×3, Q-lumped, skel4 |
| (1, 4) | 0.792 / 0.996 | 0.404 / 0.400 / 0.203 / 0.004 | DTRC(n=16) ×3, Q-lumped ×2 |
| (2, 0) | 0.799 / 1.000 | 1.000 / 0.809 / 1.000 / 2·10⁻⁴ | Q-lumped ×5 |
| (½, 0) | 0.757 / 0.980 | 0.200 / 10⁻⁶ / 0.107 / 0.019 | DTRC(n=16) ×4, Q-lumped |

**Findings** [computed].
1. **The time factor does not bite inside DT°.** Deciding axiomhood is a linear match per template, so the factor is
   τ·log₂(1+|T|) bits: at τ = 1 at most log₂(78/2) ≈ 5.3 bits between T* and any competitor. Per seed, the masses
   of T*, of its equivalents and of unsound theories move by at most 0.002 (τ = 1) and 0.016 (τ = 4) at any n; the
   MAP changes only in seed 4 at n = 8 and 16 under τ = 1, from one unsound lump (Q-lumped) to another (skel4).
   This confirms the brief's H6 that a penalty on checking axiomhood barely bites inside the template class. (Where a time penalty matters, for
   unrestricted axiom sets and Hänni's collapse, see track model §6; it is not tested here.)
2. **A steeper simplicity penalty trades early soundness for late soundness.** With λ = 2 the unsound lump Q-lumped
   is the MAP in all 5 seeds at n = 8, and the unsound mass is 1.000 at n = 8 and 32; T* recovers by n = 64. In
   return the false spare slot vanishes faster (unsound mass 2·10⁻⁴ instead of 0.004 at n = 512). With λ = ½ the
   reverse: less early lumping (unsound mass ≤ 0.2), but the false spare slot keeps 0.019 at n = 512. Neither
   setting removes both failure modes.

---

## 10. Relation to the other tracks (independent cross-checks)

The tracks were run in parallel; the code here is independent of their scripts (different grammar, prior and
candidate pools). Where the same question was asked, the answers agree:

* **Track universal, Thm U2 / Thm B** (instance data never favour ∀xφ over its schema; factor c per datum under
  L1; no movement under L1-sel and L0-closure). E1 reproduces the factor exactly (one bit per datum at
  c_stop = ½) and the exact tie under L1sel, for three formulas, in a richer pool (Prop X6; §3).
* **Track universal, Thm U10** (Bayesian ω-gap: P(T ⊢ ∀xφ | D) tends to the prior share of the provers among the
  tied theories): E1 under L1sel, limits 0.484 and 0.269.
* **Track model, Prop 5.5** (spare template costs n^(−α) if it covers no datum or reaches outside the data's
  support, n^(−α/2) if redundant inside it): E5(a) and (a2), and the E2 code-length growth of the spares
  (≈ 0.47 and ≈ 0.27 bits per doubling of n).
* **Track model, Thm 4.1 / Prop 4.2** (time-uniform soundness under well-specification; acceptance of a non-theorem
  with probability 1 under misspecification): E4 (A), (B) and (C1). Prop X8 here adds data-dependent pools (via the
  absolute prior 2^(−bits(T*))) and the fixed-weight case (X8(c)).
* **Track model, Prop 5.2 and conversation §9** (L_∞ versus L_5): E5(b), (c).
* **Track pa, §4** (Bayesian DTRC: unsound lumps of rarely used Q axioms at small n, fragmentation costing about
  the prior difference, spare slots costing ½ log₂ n): E2 finds the same three effects with a context-free Q and a
  data-derived pool (lumps preferred by 34–119 bits at n ≤ 16; frag-complete +697 to +717 bits; spares as above),
  and adds that the lumps are not only preferred to T* but take ≥ 0.997 of the mass in 3 of 5 seeds.
* **Track pa, §2** (the MDL split comes from the instantiation grammar, not from the likelihood family): E3(b) is
  consistent with it. With a misspecified motive law the posterior moves to nested or observed-root fragments at a
  linear rate, under a context-free Q; with a well-specified Q (E2) it does not.

---

## 11. Limitations (what the experiments do not show)

* **Pool, not class.** Every posterior is exact over a finite pool (hand alternatives, Min of data subsets,
  skeleton clusters, DTRC, Mem(D_n)). A theory outside the pool can beat all of them. The pools were chosen to
  contain the brief's alternatives, not to be complete; E2's "sub-T*" and E3's numeral splits N_m show that the
  winner can be a theory one did not think of first. Prop X8 is stated so that pool restriction does not break
  soundness; nothing comparable is shown for identification.
* **Chain derivations, K ≤ 2.** MP needs a cited major premise; derived conditionals (e.g. uses of induction
  followed by ∀-elimination) are outside L1. Gen acts on the single parameter w0.
* **One parameter.** Data with two distinct parameters are outside the model.
* **Fixed Q.** The instantiation grammar is fixed, not learned; misspecification of usage statistics is therefore
  absorbed by extra components (E3). A hierarchical Q is not implemented.
* **Bounded derivability.** ⊢_K under-approximates first-order derivability, so "P(T ⊢ s)" columns are lower
  bounds on the mass of theories that prove s (E3(b): frag-observed64 proves every induction instance by Prop X9
  but cites only some).
* **Soundness tags** of data-derived PA theories come from a budgeted refuter: "unsound" is certain, "not refuted"
  is not "sound".
* **Small runs.** 5 seeds (10 in E5), n ≤ 2048 (10⁸ for the E5 quadrature). Means are reported with ranges where
  they differ across seeds.
* **Wall-clock.** The exact Dirichlet sum is exponential in the number of overlapping components in the worst
  case; above 3 overlapping components and 20000 states it is replaced by bounds (§1.5: used for memorisers and
  one skeleton theory, whose largest possible mass was ≤ 2·10⁻¹⁵).

---

## 12. Open problems

1. **Beyond a pool.** An exact or certified posterior over all finite sets of DT° templates (for instance a
   sampler whose moves are Min and DTRC merges, with the exact likelihoods of this package as targets), and a
   condition under which a data-derived pool provably contains the posterior mode.
2. **Tree derivations.** A derivation likelihood in which MP may use a derived major premise (needed for induction
   followed by ∀-elimination), with an exact or certified normaliser.
3. **Learning Q.** A hierarchical instantiation grammar (Dirichlet priors on Q's production weights, shared
   across components). Prediction: it removes the linear advantage of splits in E3, leaving splits and schemas
   tied up to Occam terms (as in E2).
4. **Early unsound lumping.** E2 shows that rarely used ground axioms are lumped into unsound templates, with
   posterior ≥ 0.997 in 3 of 5 seeds at some n ≤ 32. Which cheap additions fix this: negative data (one refuted sentence; track pa §4
   reports this works), a prior that charges metavariables more, or a refutation step before the posterior?
5. **Soundness under misspecification.** A bound for the threshold verifier in terms of how far the data law is
   from the pool (e.g. when every KL-minimiser in the pool is sound), matching E4: misspecification by selection
   was harmless when a clean minimiser was in the pool and fatal when only a decoy was.
6. **The nested spare-slot rate.** Prop X7(b) is a proof sketch; E5(a2) supports −α/2 up to n = 10⁸.

---

## 13. Commands, seeds, reproduction

All commands from `code/` (results in `code/results`, logs `*.log`, tables `*.md`, raw data `*.json`):

| command | what | seeds | wall time (4 cores, shared machine) |
|---|---|---|---|
| `python3 -m pytest -q tests` | 18 unit tests (`results/pytest.txt`) | fixed in the tests | 20 s |
| `cd experiments && python3 e1_universal.py` | E1 | 0–4 (data); 1000+seed (Min subsets) | 45–90 s |
| `cd experiments && python3 e2_pa.py` | E2 | 0–4; 500+seed (Min subsets); 9000+seed (held-out probes); DTRC refuter seed = seed, tagging refuter seed 0 | 10–25 s |
| `cd experiments && python3 e3_misspec.py` | E3 | 0–4; 77+seed (Min subsets) | 10–15 min |
| `cd experiments && python3 e4_ville.py` | E4 | (A) streams 0–399, closed-form MC seed 1; (B, C) 0–99 | 11 min |
| `cd experiments && python3 e5_gold.py` | E5 | 0–9; numpy seed 0 (quadrature draws) | 20 s |
| `cd experiments && python3 e6_equivalent.py` | E6 | 0–4 | 10 s |
| `cd experiments && python3 e7_prior.py` | E7 | 0–4 (E2 data) | 50 s |
| `sh run_all.sh` | tests and E1–E7 | as above | 28 min |
| `cd ../research/tracks/experiments/checks && python3 kt_regret.py` | Prop X8(c) regret factor | none | 5 s |
| `… && python3 check_x6.py` | Prop X6 against the E1 output | reads E1 json | 1 s |
| `… && python3 check_e4_tight.py` | E4(A) pipeline against the closed-form event | streams 0–399 | 1 min |
| `… && python3 check_bounded.py` | where the Dirichlet bounds replaced the exact sum (E2–E4, E6) | as the experiments | 5 min |

Python 3.11, numpy 2.4, scipy 1.17. The dtrc package is read from `../../axiom-schemas/code` (not modified).

---

## 14. Verification log

**Checks of the implementation** (all re-run on the final code; outputs named).

| what | how | result |
|---|---|---|
| L0 coefficient and grammar | hand values (`test_term_logq_hand`, `test_component_canonical_and_l0`); sampler against exp(log Q) (`test_sampler_matches_logq`); fixed point for "contains w0" against sampling (`test_param_fixed_point`) | pass |
| prior code | hand-computed code lengths (`test_template_code_hand`) | pass |
| Dirichlet sum (Prop X2) | brute force over assignments, 200 random cases in the tests and 300 more in a scratch run | max difference 1.4·10⁻¹⁴ |
| Dirichlet bounds | bracket the exact value, 100 random cases (`test_dirichlet_bounds_bracket_exact`) | pass |
| unused spare factor | exact formula (`test_dirichlet_unused_component`); E5(a) | to 10⁻¹² and to all printed digits |
| L1 backward recursion (Prop X4) | guided against brute force on random samples from 10 theories, K = 1 and 2 (`test_l1_guided_equals_bruteforce_K1/_K2`, `test_star_closed_form_large_numeral`) | to 10⁻⁹ |
| L1 against its sampler | chi-square, 5 theories × 30000 samples (`test_l1_sampler_matches_exact`) | pass |
| L1sel class probabilities | Monte Carlo, 3 theories × 2 elim laws × 20000 (`test_class_prob_monte_carlo`) | within 4.5 s.e. |
| syntax helpers, pool helpers | `test_elim_gen_inverse`, `test_elim_predecessors_are_predecessors`, `test_term_patterns_partition`, `test_generalisations_are_more_general` | pass |
| posterior and derivability | `test_posterior_and_verifier` | pass |
| Prop X6 | E1 output, all 15 sch runs (`checks/check_x6.out`) | L1: 1.1·10⁻¹¹ from prior + n; L1sel: 1.1·10⁻¹³ from prior |
| E4(A) | pipeline against the closed-form event, 2 × 400 streams (`checks/check_e4_tight.out`) | 400/400 agreement both times |
| E5(a2) | quadrature against the exact DP at n = 500, 2 seeds | 7·10⁻⁵ bits |
| bounded marginals | re-evaluation of E2 (5 seeds), E3, E4(B, C), E6 (seed 0) recording every use of the bounds (`checks/check_bounded.out`) | E2: 1 case, E6: Mem; largest possible mass 0 to double precision; E3, E4: none |
| Prop X8(c) | regret factor R(n, m), exhaustive, m = 2, 3, 4 (`checks/kt_regret.out`) | slopes −0.499, −0.998, −1.485 against −(m−1)/2 |
| reproducibility | a full `sh run_all.sh` on the final code, diffed against the earlier results files | all seven results tables identical apart from wall-time lines; 18/18 tests pass; no errors in the logs |
| numbers quoted in §§3–9 | re-read from the json files by short scripts while writing (E1 summary, held-out masses, Mem and over-general masses; E2 per-seed unsound mass, MAPs, first appearances, code lengths; E3 per-seed MAPs and gains, L0/L1 MAP agreement (0 differences), the 12-sentence support of *small*; E4 first-win range; E7 per-seed changes) | corrected where they differed (below) |

**Corrections made during the work** (kept as the brief asks; none survives in the claims above).
* *[refuted] "On E2 data a δ = 0.05 verifier accepts no false probe."* My first reading of E2 used the mean over
  seeds (largest mass on a false probe 0.40). Per seed, the mass is ≥ 0.997 in seeds 1 and 4 at n = 8 and 16, and
  1.0 in seed 2 at n = 32 (§4, finding 2).
* *[refuted] "P(T ⊢ φ(t*) | D) = 1.000 from n = 8 in every E1 configuration."* Counterexample: open data under L0,
  worst seed, 0.0 at n = 4 and 8 (§3).
* *E2 soundness tags.* The first tagging marked a data-derived theory unsound only if a template was more general
  than T_Ind. It missed skel4's lump ∀x∀y ?P0(y, x). Tags now come from the dtrc PA refuter as well.
* *E4 prior normalisation.* The first version normalised w* over the fixed pool only. That is not valid with the
  data-dependent Mem(D_n). It now uses Prop X8(b).
* *Implementation faults found by the tests and runs.*
  1. Theories differing only in metavariable names were not deduplicated. Fixed by canonical components.
  2. The brute-force predecessor enumeration exploded (15 occurrences of 0 in one datum). Replaced by the
     template-guided recursion and the closed forms of Prop X4.
  3. The dictionary DP exploded on memorisers. Fixed with the dense DP and the bounds.
  4. The closed form overflowed for large numerals. Fixed with a stable softplus.
  5. E6's filtered data were too short. Now drawn from 12n outputs.

**Not done.**
* No independent referee has checked this track's code or notes, at the time of writing.
* No human has checked the proofs.
* Nothing is verified in a proof assistant.
* The references marked (unverified) were not checked against their sources in this session.
