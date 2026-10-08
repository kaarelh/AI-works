# Track "model": general theory of a Bayesian axiom inducer — final record

*Track "model" of the axiom-induction project. Read `../../00-brief.md` first. This file is the complete, self-contained final record of the track. It was written after the referee report `referee.md` (the referee's code is in `referee_code/`). It supersedes `notes.md`, which is kept unchanged as the pre-referee version. The track covers brief items H1, H2, H3, H5 and H6, and the relations to Hänni's note `../../prior/hanni-solomonoff-axiom-induction.md`. The case ∀xφ is track "universal"; PA and ZF are track "pa"; the code laboratory is track "experiments". Scripts are in `checks/`. Each is seeded and writes `<name>.out` next to itself.*

**Status tags.**
* **[proved]**: full proof in these notes.
* **[proof sketch]**: the argument is given; the steps not written out are named.
* **[computed]**: checked by a script in `checks/` (or the referee's `referee_code/`); the output file is named.
* **[known]**: a published result, with reference. **(unverified)** means recalled and not checked against the source in this session.
* **[conjecture]**: believed, not proved.
* **[refuted]**: a claim shown false, kept with the counterexample.

**Reference labels.** `AS:` refers to `../../../axiom-schemas/paper/sections/*.tex`, by LaTeX label. `IL:` refers to `../../../inferential-learning/paper/sections/*.tex`, by label. `conv §k` is section k of `../../../axiom-schemas/research/conversation.md`. "Hänni's note" is `../../prior/hanni-solomonoff-axiom-induction.md`. "Universal §k", "pa §k" and "experiments §k / Prop Xk" refer to the parallel tracks' current notes: `../universal/notes-final.md`, `../pa/notes-final.md`, `../experiments/notes.md`.

**What changed after the referee.** The referee found no fatal issue, five major issues (M1–M5), sixteen minor issues (m1–m16) and six questions the track had missed or left thin (Q1–Q6). Every one is resolved in the text; the map is in the verification log (§12.1). In short:
* **M1.** The soundness theorem (Thm 4.1) is proved for fixed mixture weights only. Under the default Dirichlet weights it is vacuous (Remark 4.5), and its natural analogue at a fixed weight vector is false (Example 4.9). Two correct replacements are proved: a Bayes-averaged version (Thm 4.7) and a fixed-weight version with a shrinking threshold (Thm 4.8, via the mixture-regret Lemma 4.6).
* **M2.** Prop 6.9 ("L1 charges derivation symbol size") is **refuted**. It is replaced by what L1 does charge: its own code length (Prop 6.11). Hard assigners force that code length up only logarithmically in their nondeterministic time (Thm 6.12, Cor 6.13). A symbol-size-penalised grammar L1^σ, or Hänni's graded score, charges it polynomially (Prop 6.14). The polynomial version for plain L1 is a conjecture (Conj 6.15).
* **M3.** "A derivation likelihood does not change the MDL finding [proved]" claimed more than was proved. The L1 statement is now Prop 5.6: three parts proved (exact representation, a time-uniform bound on the split's gain, the linear gain under misspecified usage), and the n^{−(K−1)/2} rate a conjecture with computed support.
* **M4.** Thm 5.1(b) is corrected. Its original statement is **refuted** (the set it names has posterior mass 0 at every n). The instance-union statement it was used for is proved by a different argument.
* **M5.** The subcriticality condition of Def 1.5 is replaced by a uniform, weighted condition that formula grammars can satisfy, and Lemma 1.6 is reproved under it.
* **New sections** answer the referee's questions: robustness under a derivation likelihood (Example 3.6, Q1), computing the likelihood (§2.4, Q2), data that come with proofs (Prop 8.2, Q5) and near misses (Remark 8.3, Q6). Section 11 aligns notation with the other tracks.

---

## 0. Summary

The question (brief): is there a good Bayesian or Solomonoff-style axiom inducer, with a template prior, a derivation-length likelihood and a time penalty? Does it find the actual axioms, or an equivalent system, or at least put much posterior mass on them?

What this track establishes.

1. **A model (§1).** Theories are finite sets of DT° templates. The prior is a prefix code. Metavariable bodies come from a grammar Q that satisfies a uniform weighted subcriticality condition (Def 1.5, revised). Four likelihoods are defined with explicit normalisation:
   * L0, axiom citation, with Dirichlet-integrated mixture weights;
   * L1, a derivation grammar (a branching process; proper iff the mean number of premises per node is at most 1);
   * L2, its bounded-depth version;
   * L1^σ, L1 reweighted by e^{−κ·(symbol size of the derivation)}.

   Hänni's two variants ("proves the givens", "does not contradict") are 0/1 scores. The likelihoods have the size principle, because their normalisers do not depend on the data. The scores do not.
2. **Well-specified case (§2, §5.1).** For a countable class with fixed weights, π(T*) > 0 and i.i.d. data from P_{T*}, the posterior concentrates a.s. on the *generator class* C* = {T : P_T = P_{T*}}. Inside C* it stays proportional to the prior forever (Doob's theorem; a direct proof is given). With Dirichlet weights the instance union ∪inst(T*) is identified for Lebesgue-almost every true weight vector (Thm 5.1(b), proof replaced after the referee).
3. **Identification is of the generator (§2.3, §5.3).**
   * Under L1, deductively equivalent theories generally have different laws (Prop 2.5).
   * Under L0 and L1, a schema and its split by the root production of Q are *exact* likelihood ties when the split's fixed weights match Q (Prop 2.6(b)).
   * With Dirichlet weights the split is the schema with a *learned* root law (Prop 5.6(a), under L0, L1 and L2). Under L1 the split never gains more than ln(1/η) nats with probability 1 − η when Q fits the usage, and it gains linearly when it does not (Prop 5.6(b),(c), proved). The rate n^{−(K−1)/2} at which the schema wins under a well-specified Q is proved under L0 (Prop 5.4) and is a conjecture under L1 (computed slope −0.507 in a latent-citation example).
   * So, to the extent proved, a derivation likelihood does not change the MDL finding of `AS:sec:many:mdl`. Competitors that only L1 keeps alive (partial schemas that derive the rest; pa §2) are outside Prop 5.6.
4. **Misspecification (§3).** For finite classes the posterior concentrates on the KL-minimisers (proved). Examples:
   * all data are theorems of T*, and the posterior concentrates on strictly weaker theories (Example 3.2, L0);
   * all data are true closed equations, and the posterior concentrates on a theory that proves 0 = S0 (Example 3.4, L0);
   * under an equational derivation grammar the human's axioms no longer have likelihood 0, but they still lose to the unsound escape template in all 16 computed settings in which Q generates the data's terms at moderate cost; they win in 5 of 8 settings when + is rare under Q (Example 3.6, new; computed in a truncated model).

   For the full countable class the KL-projection picture can fail (Remark 3.5, conjecture with computed illustration).
5. **Soundness against adaptive provers (§4).**
   * *Fixed weights.* The verifier "accept s iff the posterior mass of {T : s ∉ Th_d(T)} is ≤ δ" is sound at all times, against every prover, with probability ≥ 1 − δ′ when δ ≤ π(C*_d)·δ′ (Thm 4.1).
   * *Dirichlet weights, the default.* Thm 4.1 is vacuous there (Remark 4.5). At a fixed true weight vector a constant threshold fails: acceptance probability 0.997 and 1.000 against a nominal 0.02 (Example 4.9, computed). Two correct versions: averaged over w* drawn from the prior, with a constant threshold (Thm 4.7); and at every fixed w*, with a threshold shrinking like n^{−(|T*|−1)/2} for α = ½ (Thm 4.8).
   * *Misspecified.* A prover that waits gets a false sentence accepted with probability 1 (Prop 4.2).
   * The cautious verifier is the δ = 0 limit, read at the level of theorems (Prop 4.3).
6. **Positive data and Gold (§5).** With stochastic data and a well-specified generator the instance set (L0) or theorem set (L1) is identified in the limit with probability 1, with no bound on the number of templates. Gold's theorem still applies, but only on a null set of texts. Spare templates: disjoint from the data, exactly ≈ n^{−α} (½·log₂ n bits at α = ½); reaching outside, ≈ n^{−α}; redundant, ≈ n^{−α/2} (sketches; computed); with the law of a component of T*, a constant (proved, new). A spare whose law equals the true law can even gain slowly (computed, new).
7. **Time penalty and Hänni's collapse (§6).**
   * Hänni's equivalence (axiom induction requiring proofs ≈ function induction over consistent assigners) holds within 2c bits, with Craig's padding trick in place of his schema and in the semimeasure convention (Thm 6.1). His schema is inconsistent for some consistent assigners in single-sorted arithmetic over PA (Prop 6.3).
   * Templates block his schema (Prop 6.4) but not the collapse: one ground reflection sentence over PA reproduces any Σ_n-sound assigner (Prop 6.5).
   * A penalty on the time to check or generate axioms does not block the collapse (Prop 6.6); the brief's H6 sentence is refuted.
   * Derivation length is what prices the assigner. Measured in symbols, any theory consistent with an assigner needs derivations whose size bounds the assigner's nondeterministic time polynomially (Thm 6.7, Cor 6.8). L1^σ and Hänni's graded score charge this (Prop 6.14).
   * Plain L1 does not charge symbol size (Prop 6.9 refuted). Proved: it charges its own code length ν (Prop 6.11), and hard assigners force ν above s(m) infinitely often when their language lies outside NTIME(2^{(d+1)s(m)}), d a fixed constant (Cor 6.13): a charge logarithmic in the assigner's time. Conjecture: polynomially, as for symbol size (Conj 6.15).
8. **The trichotomy (§7).** Bel(s) = P(T ⊢ s | D) is a belief function and Pl(s) = 1 − P(T ⊢ ¬s | D) its plausibility. Hänni's two point estimates are incoherent in general. The 50/50 rule is coherent exactly when every theory in the posterior's support has at most two models (Prop 7.6, new).
9. **Predictive versus deductive (§8).** Predictions merge at total expected KL ≤ ln(1/π(C*)). Deductive beliefs converge only to what the generator class agrees on. Data that come with their proofs identify the instance union of the axioms, not just the theorems (Prop 8.2, new).
10. **Computing the likelihood (§2.4, new).** Under subcritical L1 with computable parameters, P_T(s) is a computable real, but whether P_T(s) > 0 is undecidable (it is "s ∈ Th(T)"). The two-part (maximum) approximation does not keep the generator class tied (Prop 2.8).

**What can be promised.** If the data really are i.i.d. from one of the model's generators, the method is consistent for the generator. It identifies the theorem set in the limit (L1), or the instance set (L0, also with Dirichlet weights for almost every weight vector). Its thresholded verifier is time-uniformly sound against any prover with probability 1 − δ/π(C*) for fixed weights, on average over the weight prior for Dirichlet weights, and at each fixed weight vector if the threshold shrinks like n^{−(|T*|−1)/2}. It needs no bound on the number of axioms. It does not identify "the actual axioms" beyond their generator class. In the class, splits of a schema tie exactly at matched weights; with learned weights the schema wins only at the slow Occam rate, and wrong usage statistics reverse the decision. If the data are human theorems not generated by the model, none of these guarantees survives: the posterior can concentrate on weaker or on unsound theories, under citation and, in the computed equational example, under a derivation likelihood too.

---

## 1. Definitions

### 1.1 Sentences and templates

We use the syntax of `AS:sec:setting` without change.
* **Closure-normal form.** Formulas may contain *parameters* (free names), are read under universal closure, and use de Bruijn indices for bound variables (`AS:sec:setting:syntax`). Leading universal quantifiers are not stripped. S denotes the set of these formulas; we call them *sentences*.
* **Templates.** A *template* is as in `AS:def:setting:template`: metavariable occurrences M(t̄) with metavariable-free arguments. DT° (*determinate*) requires every metavariable to have a pattern occurrence. FO ⊆ PAT ⊆ DT° are the subclasses. A template without metavariables (a *ground* template) is a single sentence.
* **Instances.** inst(τ) is as in `AS:def:setting:instances`, under the λ convention. We say each time whether parameters are admissible as values.
* **Matching** (`AS:thm:setting:matching`). For τ ∈ DT° and s ∈ S, at most one substitution θ has τθ = s, and it is found in linear time.

**Definition 1.1 (theories).** A *theory* is a finite set T = {τ_1, …, τ_k} of DT° templates, with ∪inst(T) := ⋃_i inst(τ_i). The class of all theories is **H**. A *weighted theory* is a pair (T, w) with w in the open simplex over T.

### 1.2 Background calculus

**Choice.** The calculus is Mendelson's first-order predicate calculus with equality, K (Mendelson, *Introduction to Mathematical Logic*, Ch. 2 [known; edition and numbering not checked]). Its axiom schemas are:
* A1 B→(C→B);
* A2 (B→(C→D))→((B→C)→(B→D));
* A3 (¬C→¬B)→((¬C→B)→C);
* A4 ∀x B → B[t/x], with t free for x;
* A5 ∀x(B→C) → (B→∀x C), with x not free in B;
* the equality axioms: reflexivity, and substitutivity x = y → (B(x,x) → B(x,y)).

The rules are MP and Gen.

**Relation to closure-normal form.**
* *Free variables.* Mendelson's free variables are our parameters, and Gen generalises a parameter: from φ infer ∀x φ[x/p]. Mendelson reads a formula as true in a structure iff its universal closure is, which is exactly the closure reading of `AS:sec:setting:syntax`. So a datum φ(p) and the sentence ∀xφ are interderivable (`AS:prop:univ:gen`), while a closed instance φ(t) is not (`AS:ex:univ:q`).
* *Theorems.* For a theory T, Th(T) is the set of K-derivable formulas from inst(T) used as extra axioms, with Gen allowed on every parameter. Th_d(T) is the set derivable by derivations of size at most d. Size counts symbols, axioms included; a depth measure works the same way below.
* *Completeness* [known: Gödel; Mendelson Ch. 2]. φ ∈ Th(T) iff the closure of φ holds in every structure in which the closures of all members of inst(T) hold.
* *Theorems depend only on instances.* Th(T) and Th_d(T) depend on T only through ∪inst(T). This is used repeatedly.

**Lemma 1.2 (A4 is not a template).**
(a) **[proved]** The schema A4, written as the template ∀x P(x) → P(f) with f a 0-ary term metavariable, is not in SO, so not in DT°.
(b) **[proof sketch]** No finite set of DT° templates has instance union equal to inst(A4).

*Proof of (a).* `AS:def:setting:template` requires the arguments of an occurrence to be metavariable-free. The occurrence P(f) has the metavariable f as its argument. ∎

*Sketch of (b).* Let B_m be x + ⋯ + x = x, with m summands, and s_{m,t} := ∀x B_m → B_m[t/x].
* Suppose a DT° template τ with inst(τ) ⊆ inst(A4) covers s_{m,t} and s_{m',t'} with m ≠ m'.
  * The antecedents differ inside the scope of ∀x, at positions whose subterms contain the bound x. So τ has a metavariable occurrence there with x among its arguments, say g(x).
  * The matching position in the consequent carries B_m[t/x]. In τ it must be either an occurrence g(c) with a fixed, metavariable-free c, or a metavariable independent of g.
  * In the first case t = t' = c at that position. The second case has instances outside inst(A4) (a mismatched consequent).
* So each template either covers s_{m,t} for a single m, or for a single t.
* A finite set therefore misses s_{m,t} for some m and t outside the finitely many values used.

The step not written out: turning "the matching position in the consequent" into a statement about every DT° shape.

So A4, i.e. ∀-elimination, belongs to the fixed background, not to the learned class. This matches `AS:rem:setting:nested` and conv §4: "the Hilbert axiom ∀xφ → φ[t/x] has exactly the same problem as the rule ∀E". The other logical axioms are templates:
* A1–A3 are in FO, with 0-ary formula metavariables.
* A5 is in PAT: ∀x(P → Q(x)) → (P → ∀x Q(x)). The side condition is built in, because a body for the 0-ary P cannot mention x.
* Substitutivity, ∀x∀y(x = y → (P(x,x) → P(x,y))), is in DT°, with pattern occurrence P(x,y).

In derivation grammars (L1 below) we also use ∀E, "from ∀xφ infer φ[t/x]", as a primitive rule. It is derivable in K (A4 then MP), so it does not change Th.

### 1.3 Prior

**Definition 1.3 (template code).** Templates are coded in preorder.
* *Symbol tokens.* Each node writes one token from a fixed alphabet: the symbols of the language, the connectives, ∀, ∃, and three escape tokens IDX, PAR, MV. Each token takes ⌈log₂(alphabet size)⌉ bits.
* *Escapes.* After IDX comes Elias-γ(k+1) for a de Bruijn index k. After PAR comes Elias-γ(j+1) for parameter p_j. After MV comes one bit for new/old. A new metavariable then gets its arity n (γ(n+1)) and sort (1 bit); an old one gets its index among the metavariables introduced so far (γ). Then its n argument terms follow.
* *Prefix-freeness.* Arities fix the tree shape, so the code is prefix-free. Naming metavariables by first occurrence makes renamings receive the same code. Argument permutations (M(x,y) against M(y,x)) receive different codes.
* *Theory code.* A theory T = {τ_1..τ_k} is coded as γ(k) followed by the k template codes in lexicographic order. Its length is ℓ(T).
* *Prior.* π_λ(T) := 2^{−λℓ(T)}/Z_λ with λ ≥ 1 and Z_λ := Σ_T 2^{−λℓ(T)} ≤ 1.
* *Weights.* Mixture weights get the prior Dir(α, …, α); the default is α = ½ (Krichevsky–Trofimov). Where a statement needs fixed weights, it says so.

**Lemma 1.4 (Kraft) [proved].** Σ_{T∈H} 2^{−ℓ(T)} ≤ 1, so π_λ is a probability for λ ≥ 1. Moreover Σ_T π_λ(T)^{1/2} < ∞ when λ ≥ 2.

*Proof.* Theory codes form a prefix-free set, because the tree code is prefix-free and γ(k) fixes how many template codes follow. Kraft's inequality gives the first claim. For λ ≥ 2, 2^{−λℓ/2} ≤ 2^{−ℓ}. ∎

**Time factor (Levin Kt).** For an axiom set given by a decider p (Hänni's setting), a Kt-style prior is 2^{−|p|}/c_p, where c_p := min{c : time_p(m) ≤ c·t(m) for all m} for a reference bound t. Inside DT°, membership costs O(|τ| + |s|) (`AS:thm:setting:matching`). So the factor is polynomial in ℓ(T), changes log π by O(log ℓ(T)), and does not bite. Where time matters is §6.

### 1.4 Instantiation grammar

**Definition 1.5 (Q; revised after the referee).** Q is a probabilistic context-free grammar on metavariable bodies, with one production law per *type*.
* *Types.* A type is a pair (s, k): the sort s of the node (term ι or formula o) and the number k of variables available there (holes of the body plus bound indices in scope). A body λz̄.β of a metavariable of type ι^n → s is generated top-down from the root type (s, n).
* *Productions.* At a node of type (s, k) a production is chosen with a probability that depends only on (s, k):
  * a function or relation symbol, or a connective, with children of the right sorts and the same k;
  * a quantifier, whose child has type (o, k+1);
  * a variable among the k available, a constant, or a parameter (drawn from a geometric law).
* *Holes and bound indices are treated alike.* So a body of type ι^n → s that sits under one binder inside another body is drawn like a body of type ι^{n+1} → s. This makes the grammar factor at the root for binder productions too (used in Prop 2.6(b)).
* *Substitutions.* A substitution θ for τ has Q(θ) := Π_M Q_{type(M)}(θ(M)), with metavariables drawn independently.
* *Uniformly subcritical.* Every production has at most b < ∞ children, and there are weights h(type) ∈ [h_min, h_max] with h_min > 0, and a ρ < 1, such that for every type i,
  E_i[Σ_{children c} h(type(c))] ≤ ρ·h(i).
* *Full support.* Every production has positive probability.

The definition in `notes.md` asked instead that every type's mean number of children be < 1. That condition is **[refuted]** as a usable hypothesis (referee M5): it cannot hold for formula types in L_A or L_∈, since every formula production has at least one child; and with infinitely many types it does not imply finiteness (the next item). The uniform weighted condition repairs both.

* *Example [computed: `c10_subcritical.out`, Part A].* Q_A for L_A. Term node: 0 .4, S .2, + .1, · .1, variable .2 (split uniformly over the k variables; removed and renormalised when k = 0). Formula node: = .3, < .2 (two term children), ¬ .1, ∧ .1, → .1, ∀ .1, ∃ .1. With h(o) = 1 and h(ι) = 0.05 the condition holds with ρ = 0.75 at every type, because the law depends on k only through [k = 0]. The grammar of experiments §1.2 satisfies it too (mean same-sort children 0.72 for formulas and ≤ 0.75 for terms; take h(ι) small).
* *What the condition excludes [proved; computed: `c10_subcritical.out`, Part C].* The referee's chain: at a formula node with k variables, ∀ (one child, k+1 variables) with probability 1 − 1/(k+2)² and a nullary ⊤ otherwise. Every type has mean < 1, yet the chain is infinite with probability Π_k(1 − 1/(k+2)²) = ½ [computed: `referee_code/r1_subcritical.out`]. Under the uniform condition, h(k+1)(1 − 1/(k+2)²) ≤ ρh(k), so h(k) ≤ h(0)ρ^k Π_{j<k}(j+2)²/((j+1)(j+3)) = h(0)ρ^k·2(k+1)/(k+2) < 2h(0)ρ^k → 0, contradicting h ≥ h_min > 0.

**Lemma 1.6 (Q_τ is a distribution on inst(τ)) [proved].** Let Q be uniformly subcritical (Def 1.5), τ ∈ DT°, and let N be the number of nodes of a body drawn from a root of type i.
(a) E_i N ≤ h(i)/(h_min(1 − ρ)). Hence bodies are finite almost surely.
(b) *Exponential tail.* Put K := 2/((1 − ρ)h_min) and θ_0 := (K b h_max)^{−2}. For 0 < θ ≤ θ_0, E_i[e^{θN}] ≤ e^{θKh(i)}. Hence P_i(N ≥ ℓ) ≤ e^{θ(K h_max − ℓ)}.
(c) Q_τ(s) := Q(θ_s) if τθ_s = s, and 0 otherwise, is a probability on S. Its support is inst(τ) if Q has full support.
(d) Parts (a) and (b) hold for every multi-type branching process in which each node's children are drawn independently given its type, each node has at most b children, and the uniform condition holds. This is used for derivation trees (Lemma 1.7, Prop 6.11).

*Proof.*
* (a) Let G_j be the sum of h over the nodes of generation j. Conditional on the first j generations, E[G_{j+1}] ≤ ρG_j, by the condition at each node and linearity. So E G_j ≤ ρ^j h(i). Generation j has at most G_j/h_min nodes. Sum over j.
* (b) Let N_D be the number of nodes of depth at most D. We show E_j[e^{θN_D}] ≤ e^{θKh(j)} for every type j, by induction on D.
  * D = 0: N_0 = 1, and Kh(j) ≥ Kh_min = 2/(1−ρ) ≥ 1.
  * Step: let the root have children of types c_1, …, c_r (r ≤ b) and put H := Σ_l h(c_l) ∈ [0, b h_max]. The subtrees are independent given the types, so by induction E_j[e^{θN_{D+1}}] ≤ e^θ·E_j[e^{θKH}].
  * Put x := θKH. Then 0 ≤ x ≤ θKbh_max ≤ 1, since θ ≤ θ_0 and Kbh_max ≥ 1. For x ∈ [0,1], e^x ≤ 1 + x + x², because e^x − 1 − x = Σ_{k≥2}x^k/k! ≤ x²(e − 2).
  * So E_j[e^{θKH}] ≤ 1 + θKρh(j) + θ²K²b²h_max² ≤ exp(θKρh(j) + θ²K²b²h_max²).
  * Hence E_j[e^{θN_{D+1}}] ≤ exp(θ + θKρh(j) + θ²K²b²h_max²). This is ≤ e^{θKh(j)} iff 1 + θK²b²h_max² ≤ K(1−ρ)h(j). The right side is ≥ 2, and θK²b²h_max² ≤ 1 by the choice of θ_0.
  * Monotone convergence (N_D ↑ N) gives the bound for N. The tail bound is Markov's inequality applied to e^{θN}.
* (c) By `AS:thm:setting:matching`(a), θ ↦ τθ is injective on substitutions. So Σ_s Q_τ(s) = Σ_θ Q(θ) = 1, using (a) for each metavariable. Full support makes Q(θ) > 0 for every θ.
* (d) The proofs of (a) and (b) use only the stated properties. ∎

**[computed: `c10_subcritical.out`, Part B]** For Q_A, 2·10⁵ bodies from a formula root: mean size 14.62 (s.e. 0.04), against the bound 80; from a term root at k = 0: 4.016 (s.e. 0.015), against the bound 4, which equals the exact mean 1/(1 − 0.75) (single-type case, where the bound is tight). Both empirical tails decay exponentially.

### 1.5 Likelihoods

Data are a sequence D = (X_1, …, X_n) of sentences.

**L0 (axiom citation).**
* *Fixed weights.* P_{T,w}(s) := Σ_{τ∈T} w_τ Q_τ(s), and P_{T,w}(D) = Π_i P_{T,w}(X_i). It is normalised by Lemma 1.6.
* *Dirichlet-integrated.* P^Dir_T(D) := ∫ Π_i P_{T,w}(X_i) Dir(dw; α). Expanding the product and using Dirichlet moments gives
  P^Dir_T(D) = Σ_{ℓ: D→T, X_i ∈ inst(ℓ_i)} [Γ(A)/Γ(A+n)] Π_τ [Γ(α_τ + n_τ(ℓ))/Γ(α_τ)] · Π_i Q_{ℓ_i}(X_i),
  where A = Σ_τ α_τ and n_τ(ℓ) is the number of data labelled τ **[proved; computed: `c8_formulas.out` (1), exact to 10⁻¹² against quadrature]**.
* *Disjoint instance sets.* When the instance sets are pairwise disjoint, the sum has one term. The predictive rule is then P(X_{n+1} = s | D) = Σ_τ [(α_τ + n_τ)/(A + n)] Q_τ(s), the Krichevsky–Trofimov rule per template.
* *Normalisation.* P^Dir_T is an exchangeable probability on S^n for each n, consistent in n. Its normaliser is independent of D.

**L1 (derivation grammar).** Fix probabilities α_ax, α_lg, α_MP, α_Gen, α_∀E summing to 1, with α_ax + α_lg > 0, and put α_r := α_MP + α_Gen + α_∀E. A random tree is grown from the root. Each node independently does one of the following:
* *cite a theory axiom* (probability α_ax): choose τ ∈ T with probability w_τ, then θ ∼ Q; the conclusion is τθ;
* *cite a logical axiom* (α_lg): choose one of K's axiom templates uniformly, then instantiate by Q (for A4, the term t is drawn from Q_ι);
* *apply MP* (α_MP): two independent children;
* *apply Gen* (α_Gen): one child; a parameter p is drawn from a geometric law and abstracted;
* *apply ∀E* (α_∀E): one child; a term t ∼ Q_ι is drawn.

A tree is *valid* iff:
* at each MP node the right child's conclusion is (left child's conclusion → B), and the node's conclusion is B;
* at each ∀E node the child's conclusion has root ∀.

Gen nodes are always valid. Then:
* μ_T(s) := Pr[valid, conclusion s];
* Z_T := Pr[valid] = Σ_s μ_T(s);
* P_T(s) := μ_T(s)/Z_T.

The tree's code length −log₂ Pr(tree) is a derivation-length prior: each rule application and each instantiated symbol costs bits. Note that this code length counts *grammar choices*, not the symbols of the formulas in the tree; §6.5 shows that the two can differ exponentially. The two-part (MDL) approximation replaces the sum over trees by the maximum (§2.4). The universal track calls this normalised likelihood "L1-norm"; its "L1(c)" is the unnormalised μ_T of a chain calculus.

**Lemma 1.7 (L1 is proper; support) [proved, except the extinction criterion, which is known].**
(a) Let m := 2α_MP + α_Gen + α_∀E be the mean number of premises per node, and assume α_ax + α_lg > 0 and Q uniformly subcritical.
* The derivation tree is finite a.s. iff m ≤ 1 [known: Galton–Watson extinction theorem, for offspring laws with positive mass at 0; Athreya & Ney 1972 Ch. I (unverified numbering)]. If α_ax + α_lg = 0, every node is unary or binary and the tree is infinite even at m = 1 (referee m11); this case is excluded.
* For m < 1 the expected number of derivation nodes is 1/(1 − m) [proved]. With the Q bodies and Gen parameters counted, the whole tree satisfies Lemma 1.6(d) (Prop 6.11).
* For m > 1 the tree is infinite with probability 1 − q > 0, where q is the least root of q = (α_ax + α_lg) + (α_Gen + α_∀E)q + α_MP q². Then μ_T is defective and P_T must be read as conditional on finiteness.

(b) Z_T ≥ α_ax + α_lg = 1 − α_r > 0, because a one-node tree is valid. So P_T is a probability with a data-independent normaliser.

(c) Assume all α's positive, w > 0, Q with full support, and **parameters admissible** in the draws of logical-axiom instances, ∀E terms and Gen (referee m12). Then supp P_T = Th(T). Without parameters, Gen is vacuous and some closed theorems, such as ∀x(R(x) → R(x)), have no tree.

*Proof.*
* (a), expected size. Let N be the number of derivation nodes. Then E N = 1 + m·E N, by conditioning on the root's rule and using linearity (the children are i.i.d. copies). Finiteness of E N for m < 1 follows from the generation sizes: E[generation k] = m^k, and Σ_k m^k < ∞.
* (b). Immediate.
* (c), ⊆. Every valid tree is a K-derivation from inst(T), with ∀E replaced by an A4 instance and MP.
* (c), ⊇. Every K-derivation from inst(T) ∪ inst(Λ) is a tree of the grammar, and it has positive probability. Each citation has w_τ Q(θ) > 0. Each logical axiom instance has positive Q-probability, A4's term included, and parameters can be drawn where the derivation uses them. Each Gen has positive parameter probability. ∎

Computed **[computed: `c8_formulas.out` (2)]**:
* mean sizes 2.010 and 9.965 against 1/(1 − m) = 2 and 10;
* at m = 1, a heavy tail;
* at m = 1.1, P(finite) = 0.7489 against q = 0.75.

**L2 (bounded depth).** This is L1, except that at depth d a node must cite (α_ax, α_lg renormalised). Every tree is finite and no subcriticality is needed. P^{(d)}_T := μ^{(d)}_T / Z^{(d)}_T, with support Th_{≤d}(T), the conclusions of valid trees of depth ≤ d.

**L1^σ (symbol-size penalty; new).** Fix κ > 0. For a tree π let |π| := Σ_{nodes v} |concl(v)| be its total symbol size. Put μ^σ_T(s) := Σ_{valid π with conclusion s} Pr(π)e^{−κ|π|}, Z^σ_T := Σ_s μ^σ_T(s) and P^σ_T := μ^σ_T/Z^σ_T.
* **[proved]** 0 < Z^σ_T ≤ Z_T ≤ 1: one-node citation trees have positive weight, and e^{−κ|π|} ≤ 1. So P^σ_T is a probability with a data-independent normaliser, and supp P^σ_T = supp P_T.
* It is Hänni's "penalize longer proofs", with proof length measured in symbols, made into a normalised generator. It is the likelihood to which the symbol-size results of §6 transfer (Prop 6.14).

**Hänni's variants as scores.** Data may carry labels D = D₊ ∪ D₋ (true, false).
* *Proves the givens.* S_prove(T; D) := 1[T consistent] · Π_{s∈D₊} 1[T ⊢ s] · Π_{s∈D₋} 1[T ⊢ ¬s].
* *Does not contradict.* S_nc(T; D) := 1[T ∪ D₊ ∪ ¬D₋ consistent].
* *Graded*, as in his "depend … on how many of the given statements can be proven" and "penalize longer proofs": S_g(T; D) := S_nc(T; D) · Π_{s∈D₊} g(ℓ_T(s)), with ℓ_T(s) the shortest derivation size (∞ if none), g decreasing, and g(∞) = β ∈ [0,1).

The posterior is π(T)·S(T; D). These are scores, not likelihoods: Σ_D S(T; D) is not 1 and depends on T. Track universal uses the same names (S_prove, and S_nc,β for its graded variant).

### 1.6 The size principle

**Lemma 1.8 (size principle, exact form) [proved].** Let P*, P be probabilities on a countable S, and ε := P(S ∖ supp P*). Write P̃ := P(· | supp P*).
(a) KL(P* ‖ P) = KL(P* ‖ P̃) + ln(1/(1−ε)) ≥ ln(1/(1−ε)).
(b) For every data sequence in supp P*, P(D) = (1−ε)^n P̃(D), and E_{P*}[P̃(D)/P*(D)] ≤ 1.

*Proof.* On supp P*, P = (1−ε)P̃. Substitute into KL(P* ‖ P) = Σ_{s∈supp P*} P*(s) ln(P*(s)/P(s)). For (b), E_{P*}[P̃(X)/P*(X)] = Σ_{s∈supp P*} P̃(s) = 1, and use independence. ∎

So a hypothesis that puts mass ε outside the data's support loses at least ln(1/(1−ε)) nats per datum in expectation. It also loses exactly the factor (1−ε)^n against its own conditional version, on every data sequence. **[computed: `c1_size_principle.out`]** For T* = {z+0=z} against the over-general {z₁+0=z₂}, the decomposition holds to 10⁻⁹, and the simulated per-datum log-ratio 3.94 matches KL = H(Q) = 3.894 nats.

**Proposition 1.9 (which likelihoods have the size principle) [proved].**
(a) L0, L1, L2 and L1^σ have it. Each P_T is a probability on S whose normaliser does not depend on the data, so Lemma 1.8 applies to any T whose generator puts mass outside the data law's support. Under L0 with full-support Q, this is any T with ∪inst(T) ⊄ supp P*.
(b) Hänni's scores do not. Let Th(T) ⊆ Th(T').
* S_nc(T') ≤ S_nc(T): a weaker theory never scores lower under "does not contradict".
* If T' is consistent with the labelled data, S_prove(T') ≥ S_prove(T).
* If moreover ∪inst(T) ⊆ ∪inst(T'), then S_g(T') ≥ S_g(T): T' proves everything T proves, by derivations no longer.
* Consequence: let T' = T* ∪ {ψ} with ψ ∉ Th(T*), and assume T* ∪ {ψ} ∪ D₊ ∪ ¬D₋ is consistent (referee m9: "ψ never mentioned in the data" does not ensure this; for example ψ = ∀xR(x), T* = ∅, D₊ = {¬R(0)}). The consistency holds automatically under S_prove when T* proves the labelled data and T* ∪ {ψ} is consistent. Then the posterior odds π_n(T')/π_n(T*) never fall below the prior odds under S_prove or S_g. Under S_nc they equal the prior odds, since both scores are 1.

(c) Generative likelihoods do penalise that strengthening (ψ ground, ψ ∉ Th(T*)).
* Under L0 with fixed weights (ψ's weight w_ψ, the others scaled by 1 − w_ψ), the likelihood ratio against T* is exactly (1 − w_ψ)^n on data not containing ψ.
* Under L1, P_{T'}(ψ) ≥ α_ax w_ψ while ψ ∉ Th(T*) = supp P_{T*}. So Lemma 1.8 gives exponential decay at rate at least ln(1/(1 − α_ax w_ψ)) per datum.
* With Dirichlet weights the ratio is ≈ n^{−α} (Prop 5.5(a)).

*Proof.* (a) is Lemma 1.8. (b): monotonicity of ⊢ in the axiom set, and of consistency (in the reverse direction). For S_g, inclusion of instances makes every derivation from T a derivation from T'. (c): direct computation under L0; for L1, Lemma 1.8 with ε ≥ μ_{T'}(ψ)/Z_{T'} ≥ α_ax w_ψ, using Z_{T'} ≤ 1. ∎

**Remark 1.10 (Hänni's graded score, normalised) [proved; the claim of `notes.md` refuted].**
* *Setting.* Let ℓ_T(s) be the least length, in bits, of an explicit derivation of s from T, written in a fixed prefix-free code that writes every formula out (theory axioms as formulas, not by name). Let g(ℓ) := 2^{−κℓ} with κ ≥ 1, and β = g(∞) = 0. With β > 0 the normaliser below is infinite, since infinitely many sentences have no derivation (referee m3).
* *Normalisation.* Z_T := Σ_s 2^{−κℓ_T(s)} ≤ 1 by Kraft: distinct s have distinct shortest derivations. So P^g_T(s) := 2^{−κℓ_T(s)}/Z_T is a probability with a data-independent normaliser. It is a two-part (maximum) code of the same kind as L1^σ: both charge the written length of the derivation, while L1 charges only the grammar's choices (§6.5 explains the difference).
* *Size principle in this form [proved].* If ∪inst(T) ⊆ ∪inst(T'), then ℓ_{T'} ≤ ℓ_T pointwise, so Z_{T'} ≥ Z_T, so P^g_{T'}(s) ≤ P^g_T(s) for every s with ℓ_{T'}(s) = ℓ_T(s).
* *[refuted]* `notes.md` said: "A stronger theory has more short theorems, hence a larger Z_T, hence a smaller P_T(s) on each datum." Counterexample [computed: `referee_code/r6_stronger_theory.out`]: T = {a, a→b} and T' = T ∪ {b} have the same theorems and nested instances. With κ = 1, P_T(b) = 0.032 and P_{T'}(b) = 0.346; ten sentences gain and 36 lose. Under L2 (depth 2), P_T(b) = 0.016 and P_{T'}(b) = 0.24. A datum whose shortest derivation gets shorter can gain.
* His remark "you can probably equivalently think of this as there being some model for how the statements get generated" is right once the score is divided by Z_T and β = 0.

---
## 2. Consistency and identification (well-specified case)

**Setting W (well-specified, fixed weights).**
* **H** is a countable class; π is a prior with π(T) ≥ 0 and Σπ = 1.
* Each T ∈ **H** carries a fixed probability P_T on the countable set S. Weights are fixed here; Dirichlet weights are treated in §4.2 and §5.
* The data X_1, X_2, … are i.i.d. from P_{T*}, for some T* ∈ **H** with π(T*) > 0.
* Posterior: π_n(T) := π(T)P_T(X^n) / Σ_{T'} π(T')P_{T'}(X^n), defined whenever the denominator is positive.
* Generator class: C* := {T ∈ **H** : P_T = P_{T*}}. (Track universal uses the same name.)

### 2.1 Concentration on the generator class

**Theorem 2.1 (posterior consistency for the generator) [proved; known as a special case of Doob 1949].** Under W, π_n(C*) → 1 almost surely.

*Proof.* The argument is Doob's, written out for the countable case.
1. **Joint measure and Lévy.**
   * Let Π be the joint law of (T, X_1, X_2, …) on **H** × S^∞: Π(T = t, X ∈ E) = π(t)P_t^∞(E). Let M(E) := Σ_t π(t)P_t^∞(E) be the marginal law of the data.
   * For countable **H**, Bayes' rule gives π_n(A) = Π(T ∈ A | X_1, …, X_n), on the M-full event where the denominator is positive.
   * By Lévy's upward theorem [known], for each fixed A ⊆ **H**, π_n(A) → Π(T ∈ A | X_∞) Π-a.s. The convergence event is a data event, so it holds M-a.s.
2. **The data determine the generator.**
   * For x ∈ S^∞ let F(x)(s) := lim_n n^{-1}#{i ≤ n : x_i = s}. Set F(x) := ⊥ if, for some s, the limit fails to exist, or if the limits do not sum to 1.
   * By the strong law of large numbers, applied to countably many s, P_t^∞(F = P_t) = 1 for each t. On that event the limits are the numbers P_t(s), which sum to 1.
   * Hence Π(P_T = F(X)) = 1.
3. **The limit puts all mass on {T : P_T = F(X)}.**
   * Choose a version of the conditional law {Π(T = t | X_∞)}_t that sums to 1 a.s.
   * For each t the indicator 1{P_t = F(X)} is X_∞-measurable. So E[1{P_T = F(X)} | X_∞] = Σ_t 1{P_t = F(X)} Π(T = t | X_∞), by monotone convergence.
   * The left side is 1 a.s., because the indicator is 1 a.s.
   * The values F(X) range Π-a.s. over the countable set {P_t : t ∈ **H**}. Apply step 1 to the countably many sets A_ν := {t : P_t = ν} and intersect the full-measure events. Then, M-a.s., lim_n π_n(A_{F(X)}) = Π(T ∈ A_{F(X)} | X_∞) = 1.
4. **Transfer to the truth.**
   * M ≥ π(T*)P_{T*}^∞ as measures on S^∞. So every M-null event is P_{T*}^∞-null, and step 3 holds P_{T*}^∞-a.s.
   * Under P_{T*}^∞, F(X) = P_{T*} a.s. by step 2, so A_{F(X)} = C*. ∎

**Corollary 2.2 (inside C* the posterior is the prior) [proved].** For T, T' ∈ C* and every n, π_n(T)/π_n(T') = π(T)/π(T'). Hence, a.s., π_n(T) → π(T)/π(C*) for every T ∈ C*.

*Proof.* Members of C* have equal likelihoods on every data sequence. Combine with Theorem 2.1. ∎

**Corollary 2.3 (limits of deductive beliefs) [proved].** Under W, almost surely, simultaneously for all s ∈ S and all d ≤ ∞:
  π_n({T : s ∈ Th_d(T)}) → π({T ∈ C* : s ∈ Th_d(T)}) / π(C*).

*Proof.* Write A := {T : s ∈ Th_d(T)}. Then π_n(A) = π_n(A ∩ C*) + π_n(A ∖ C*). The second term is at most π_n(**H** ∖ C*) → 0. The first equals π_n(C*)·π(A ∩ C*)/π(C*), by Corollary 2.2. There are countably many pairs (s, d). ∎

So the data decide deductive questions only through C*. Inside C* the prior decides. When is the limit 1[T* ⊢ s]?
* *L0* (full-support Q, positive weights). supp P_T = ∪inst(T). So every T ∈ C* has ∪inst(T) = ∪inst(T*), hence Th_d(T) = Th_d(T*) for every d. The limit is 1[s ∈ Th_d(T*)].
* *L1* (Lemma 1.7(c), parameters admissible). supp P_T = Th(T). So the limit is 1[s ∈ Th(T*)] for d = ∞. For finite d it can differ: members of C* may need derivations of different length.
* *L2.* Only Th_{≤d} is determined.
* *Hänni's scores.* They are not generators, and nothing like Theorem 2.1 holds for them (Prop 1.9(b)).

**[computed: `c9b_consistency_matching.out`]** Class: T*, its root split, an over-general template, a split missing one root, and T* plus a spare ground template. Every likelihood is computed by first-order matching of the datum against each template.
* log P_{T*}(D) and log P_{T_split}(D) agree to 5.7·10⁻¹⁴ at every n ≤ 2000 in three seeds, as Corollary 2.2 says.
* The other three go to 0. The spare decays as 0.95^n exactly (2.6·10⁻²³ at n = 1000). The missing-root split dies at the first datum with root · (data 1, 1 and 10 in the three seeds).
* The earlier check `c9_consistency.py` coded T_split's likelihood as T*'s by construction, so for the split it checked nothing (referee m5). Its other rows are correct. The genuine check of the tie at the level of single instances is `c2_split.out`, Part A.

### 2.2 Rates

**Proposition 2.4 [proved].** Assume W.
(a) **Fixed competitor.** For T ∉ C*, n^{-1} ln[π_n(T*)/π_n(T)] → KL(P_{T*} ‖ P_T) ∈ (0, ∞] a.s.
(b) **Prediction.** Let M_n(s) := Σ_T π_n(T)P_T(s) be the predictive law. Then
  Σ_{i=1}^n E_{T*}[KL(P_{T*} ‖ M_{i−1})] ≤ ln(1/π(C*)) for all n.
(c) **Uniform rate.** For A ⊆ **H** ∖ C*, let ρ_T := Σ_s (P_{T*}(s)P_T(s))^{1/2} (the Bhattacharyya coefficient). Then
  E_{T*}[(π_n(A)/π_n(T*))^{1/2}] ≤ Σ_{T∈A} (π(T)/π(T*))^{1/2} ρ_T^n.
  * If sup_{T∈A} ρ_T ≤ ρ < 1 and Σ_T π(T)^{1/2} < ∞ (true for λ ≥ 2 by Lemma 1.4), then P[π_n(A) ≥ ε] ≤ C ρ^n ε^{−1/2}, with C := Σ_{T∈A}(π(T)/π(T*))^{1/2}.

*Proof.*
* (a) The log-ratio is ln(π(T*)/π(T)) + Σ_i Y_i, with Y_i := ln(P_{T*}(X_i)/P_T(X_i)) i.i.d. and E Y = KL > 0 (Gibbs; P_T ≠ P_{T*}). The negative part is integrable: E[Y^−] = E[(ln(P_T/P_{T*}))^+] ≤ E[P_T(X)/P_{T*}(X)] ≤ 1. So the strong law holds with limit in (0, ∞]. If P_T(X_i) = 0 for some i, the ratio is +∞ from then on.
* (b) M(X^n) := Σ_T π(T)P_T(X^n) ≥ π(C*)P_{T*}(X^n). By the chain rule, ln[P_{T*}(X^n)/M(X^n)] = Σ_i ln[P_{T*}(X_i)/M_{i−1}(X_i)]. The conditional expectation of the i-th term is KL(P_{T*} ‖ M_{i−1}). Take expectations.
* (c) π_n(A)/π_n(T*) = Σ_{T∈A} (π(T)/π(T*)) L_T, with L_T := Π_i P_T(X_i)/P_{T*}(X_i). Use (Σ a_T)^{1/2} ≤ Σ a_T^{1/2}, and E[L_T^{1/2}] = ρ_T^n by independence. For the probability bound use Markov, and π_n(A) ≤ π_n(A)/π_n(T*). ∎

(b) is the Solomonoff–Barron bound for Bayes mixtures. Predictions converge at total cost ln(1/π(C*)) nats, whatever happens to deductive beliefs (§8).

The uniform rate (c) degenerates in the cases that matter. A theory T* ∪ {τ} with weight ε on τ has ρ ≥ (1−ε)^{1/2} → 1 as ε → 0. So no exponential rate holds uniformly over spare templates. Their decay is governed by the weight prior (Prop 5.5).

### 2.3 Identification is of the generator

**Proposition 2.5 (L1 separates deductively equivalent theories) [proved for an open set of grammar parameters; computed beyond it].**
* Let a := ¬(S0 = 0) and b := ¬(SS0 = 0). Let T1 := {a, b} and T2 := {a, a → b}, ground, with weights ½.
* Th(T1) = Th(T2): b follows from a and a → b by MP, and a → b follows from b by an A1 instance and MP.
* Under L1 (or L2), P_{T1}(b) ≥ α_ax/2 and P_{T2}(b) ≤ α_r/(1 − α_r).
* So P_{T1} ≠ P_{T2} whenever α_ax/2 > α_r/(1 − α_r).

*Proof.*
* b has root ¬. Every instance of a logical axiom has root → or ∀, and b is not an axiom of T2. So no one-node tree concludes b under T2, and μ_{T2}(b) ≤ Pr[the root is a rule node] = α_r.
* By Lemma 1.7(b), Z_{T2} ≥ 1 − α_r.
* Under T1, the one-node tree citing b has probability α_ax/2, and Z_{T1} ≤ 1. ∎

**[computed: `c6_L1_ident.out`; `referee_code/r6_stronger_theory.out` (ii)]** The propositional fragment (A1–A3 and MP, Q truncated to formulas of size ≤ 3, depth ≤ 2), four parameter settings, three of them outside the proved region (including α_MP = 0.4). P_{T1}(b) lies between 0.16 and 0.35 (0.31–0.35 in the first two settings, 0.24–0.25 and 0.16–0.17 in the last two), against P_{T2}(b) between 0.007 and 0.04. TV(P_{T1}, P_{T2}) lies between 0.16 and 0.35. (`notes.md` misreported the P_{T1}(b) range as 0.31–0.35; referee m6.) The referee's independent implementation confirms both bounds in three settings.

What this means for the posterior. If the data come from P_{T1} or from P_{T2}, the ratio π_n(T1)/π_n(T2) goes to ∞ or to 0 (Prop 2.4(a)). If the data come from a third generator, its drift is the difference of two KL divergences, which can be zero (referee m15). In the well-specified case the posterior picks an axiomatisation, not only a theory. Which one is decided by which generator produced the data, not by a logical criterion.

**Proposition 2.6 (when P_T = P_{T'} under L0) [proved].** Let Q have full support and all weights be positive.
(a) **Necessary condition.** P_{T,w} = P_{T',w'} implies ∪inst(T) = ∪inst(T'). Hence Th_d(T) = Th_d(T') for all d.
(b) **Splits are exact ties.**
  * Let τ ∈ T have a metavariable M whose PCFG factors at the root over a *finite* set R of root productions: Q_M(λz̄.r(β_1, …, β_a)) = p_r Π_j Q(β_j). Here a production r is a symbol with its children's types, or a hole, or a constant.
  * Let τ_r := τ[M := λz̄. r(N_1(z̄, …), …, N_a(z̄, …))], with fresh metavariables N_j of the child types (one more argument under a binder production).
  * Let T' := (T ∖ {τ}) ∪ {τ_r : r ∈ R}, with weights w'_{τ_r} := w_τ p_r and the other weights unchanged.
  * Then each τ_r ∈ DT°, and P_{T',w'} = P_{T,w}.
(c) **Single templates.** If τ ≡ τ' (renaming and argument permutation, `AS:lem:setting:renaming`) and Q treats holes symmetrically, then Q_τ = Q_{τ'}. Conversely, Q_τ = Q_{τ'} implies inst(τ) = inst(τ').
  * If τ and τ' are both first-order with only 0-ary *term* metavariables, then under Rich, inst(τ) = inst(τ') gives τ ≡ τ' (`AS:prop:univ:determine`, applied in both directions).
  * That proposition assumes one side has only 0-ary term metavariables (referee m10), so it says nothing about FO templates with formula metavariables such as A1 = B → (C → B). For those, and for DT° in general, it is open here whether inst(τ) = inst(τ') implies τ ≡ τ'; `AS:sec:setting:templates` leaves the DT° case open.

*Proof.*
* (a) supp P_{T,w} = ∪inst(T) by Lemma 1.6, and theorems depend only on instances (§1.2).
* (b), templates. Plugging the body into a pattern occurrence M(ȳ) gives r(N_1(ȳ, …), …). Each N_j has a pattern occurrence, because ȳ are distinct bound variables, and a binder adds one more distinct bound variable. Other occurrences of M receive the same body with metavariable-free arguments, which `AS:def:setting:template` allows. So τ_r ∈ DT°.
* (b), instances. inst(τ) = ⊔_r inst(τ_r). At a pattern occurrence of M the instance shows θ(M)'s root production, and distinct productions give distinct subtrees there; for hole productions z_i, the distinct bound variables y_i.
* (b), probabilities. For s ∈ inst(τ_r), let θ be τ's matcher for s. Then the matcher of τ_r gives the children's bodies of θ(M), and Q(θ) = p_r · Q_{τ_r}(s), by the root factorisation. Summing over the template's contribution gives w_τ Q_τ(s) = Σ_r w_τ p_r Q_{τ_r}(s).
* (c) Renaming permutes the factors of Q(θ), and argument permutation permutes the holes, which a hole-symmetric Q ignores. The converse is (a) for single templates. ∎

**[computed: `c2_split.out`, Part A]** For z + 0 = z and its four root splits over {0, S, +, ·}, the two generators agree to 10⁻¹⁹ on all 2849 instances with |t| ≤ 9. The check matches each instance against each template; it does not just use the algebra.

**Remarks.**
* *Splits under L1 (fixed matched weights).* Prop 2.6(b) holds verbatim under L1 and L2. A citation node's conclusion has the same law under T and under its split, and a tree's validity and conclusion depend only on the conclusions of its nodes. So μ_T = μ_{T'} and Z_T = Z_{T'}. With *learned* weights the likelihoods differ; that case is Prop 5.4 (L0) and Prop 5.6 (L1, L2). So the sentence of `notes.md`, "the likelihood never tells a schema from its split", holds only for fixed weights matched to Q (referee m14).
* *Which splits.* The split of T_Ind by the main connective of the motive (`AS:prop:many:mdlnaive`) is an instance of (b). The metavariable is P : ι → o, and the productions are the connectives, quantifiers and the relation symbols.
* *Exactness depends on Q.* The exact tie needs Q to factor at the root. If Q does not factor (for instance, a uniform law on bodies of each size, or the KT-learned positional grammar of pa §0), the split's generator differs, and either may fit better.

### 2.4 Computing the likelihood (new; referee Q2)

**Proposition 2.7 (what can be computed) [(a) proved; (b) proved, modulo Church's theorem].** Assume L1 with m < 1 and Q uniformly subcritical, all grammar probabilities and weights computable reals, and the hypotheses of Lemma 1.7(c).
(a) μ_T(s), Z_T and P_T(s) are computable reals, uniformly in (T, s).
(b) The set {(T, s) : P_T(s) > 0} equals {(T, s) : s ∈ Th(T)}. It is recursively enumerable and, for a language with a binary relation symbol (or L_A), not decidable, already for T = ∅ [known: Church 1936 and Turing 1936, undecidability of first-order validity].
(c) Consequently no algorithm decides whether a theory has likelihood 0 on a datum. For a finite class the posterior π_n(T) is a computable real whenever it is defined, but which theories it has excluded is not decidable.

*Proof.*
* (a) Let ν(π) be the number of grammar nodes of a tree: derivation nodes, Q nodes and the nodes of the geometric parameter chains. The whole tree is a multi-type branching process satisfying Lemma 1.6(d) (proof of Prop 6.11), so E ν ≤ C_ν with C_ν computable from the parameters. There are finitely many trees with ν ≤ N: each node chooses from a finite list (a rule, a template of T, a logical axiom, a production, one of finitely many variables (at most the metavariable's arity plus N), a chain step). Validity of each is decidable. So μ^{≤N}_T(s) and Z^{≤N}_T, the sums over trees with ν ≤ N, are computable. The truncation errors are at most Pr[ν > N] ≤ C_ν/N (Markov). Finally Z_T ≥ 1 − α_r > 0, so P_T = μ_T/Z_T is computable.
* (b) Lemma 1.7(c) gives the identity. Th(T) is r.e. Undecidability is Church's theorem.
* (c) From (a) and (b): a positive denominator is approximated to any precision, but no finite computation certifies that a likelihood is 0. ∎

*Cost.* The truncation algorithm needs N of order C_ν/ε and enumerates a number of trees exponential in N. Getting a likelihood *ratio* right needs ε below the likelihoods themselves, and these are at most C·e^{−θν_min(s)}/Z_T (Prop 6.11), so tiny for data with only long derivations. I have no better general algorithm, and (b) rules out a general exact one. In practice the other tracks restrict the grammar (experiments §1.6: chains of length ≤ 2) or use explicit derivations (pa §0: two-part codes).

**Proposition 2.8 (the maximum is not the sum) [proved].** The two-part (MDL, Viterbi) approximation replaces P_T(s) by V_T(s) := max over derivations (L1) or over citing templates (L0) of the probability. It does not keep the generator class tied.
* *Example.* Let τ := ∀x∀y M(x, y), with M a formula metavariable of type ι² → o, and τ' := ∀x∀y M(y, x), its argument permutation. With a hole-symmetric Q, inst(τ) = inst(τ') and Q_τ = Q_{τ'} (Prop 2.6(c)); their codes differ (Def 1.3). Let T1 := {τ} and T2 := {τ, τ'} with fixed weights ½, ½.
* Under L0, P_{T2} = ½Q_τ + ½Q_{τ'} = Q_τ = P_{T1}. So T1, T2 ∈ C*, and π_n(T2)/π_n(T1) = π(T2)/π(T1) at every n (Cor 2.2).
* Under the maximum, every instance s has exactly two citations, one per template, with equal probability. So V_{T2}(s) = ½Q_τ(s) = ½V_{T1}(s), and the two-part posterior ratio is (π(T2)/π(T1))·2^{−n} → 0.

*Proof.* Matching is unique (`AS:thm:setting:matching`), so each template contributes one citation; the rest is arithmetic. ∎

So posterior limits under the two-part code can differ from the Bayesian ones. In this example the theorems agree, so the difference is harmless deductively. Whether a deductively relevant difference can arise is not settled here. Track universal's "L1-max" and the two-part codes of track pa are this approximation.

---

## 3. Misspecification

The human's data are theorems of the actual axioms T*, but they are not generated by any P_T in the model. What does the posterior do?

**Theorem 3.1 (finite class: concentration on the KL-minimisers) [proved; the general form is known].**
* Let **H** be finite, with π(T) > 0 for all T. Let the data be i.i.d. from an arbitrary law P_H on S.
* Let K_T := KL(P_H ‖ P_T) ∈ [0, ∞], suppose K_min := min_T K_T < ∞, and let 𝕄 := argmin_T K_T.
* Then π_n(𝕄) → 1 a.s. The rate is exponential: n^{-1} ln[π_n(T)/π_n(T_0)] → K_{T_0} − K_T < 0 for T ∉ 𝕄, T_0 ∈ 𝕄.

*Proof.*
* On supp P_H, ln(P_T/P_{T_0}) = Y_0 − Y_T, with Y_T := ln(P_H/P_T).
* Y_T has integrable negative part: E[(ln(P_T/P_H))^+] ≤ E[P_T/P_H] ≤ 1. Its mean is K_T.
* Y_0 ∈ L¹, since K_{T_0} < ∞.
* By the strong law, n^{-1}Σ(Y_0 − Y_T) → K_{T_0} − K_T a.s., with value −∞ allowed when K_T = ∞.
* **H** is finite. ∎

Inside 𝕄 the posterior need not converge: members with equal KL but different P_T trade places like a zero-drift random walk.

For general parameter spaces, concentration on the KL-minimisers is known.
* Berk (1966, *Ann. Math. Statist.* 37(1):51–58): under conditions, the posterior concentrates on an "asymptotic carrier" (the KL-minimising set), and it may fail to converge within the carrier. This matches the remark above.
* Kleijn & van der Vaart (2006, *Ann. Statist.* 34(2):837–877): the posterior concentrates near the KL-closest points of the prior's support, at a rate set by an entropy condition and a prior-mass condition.

[known; bibliographic data and the main statements checked against the publishers' abstracts in a web search in the first session. The exact conditions were not read.] Remark 3.5 shows that their conclusion need not describe our countable class.

**Example 3.2 (all data are theorems of T*; the posterior concentrates on strictly weaker theories) [proved].**
* *Language and model.* L_A, under the λ convention with parameters *not* admissible as values, so instances are closed. Model: L0 with fixed full-support Q over finite DT° theories, and any prior with π(σ) > 0, where σ := {0 + z = z}.
* *Human.* The human's axioms are T* := {∀x(0 + x = x)}. The human states closed instances 0 + t = t with t ∼ Q. Each is a T*-theorem (A4, MP).
* *The data are well specified for σ.* P_H = P_σ, so Theorem 2.1 applies with truth σ, and π_n(C_σ) → 1.
* *No member of C_σ proves the axiom.* Every T ∈ C_σ has ∪inst(T) = inst_c(0 + x = x), the closed instances (Prop 2.6(a)), hence Th(T) = Th(inst_c). And ∀x(0 + x = x) ∉ Th(inst_c). Take the structure ℕ ∪ {a}, standard on ℕ, with 0 + a := 0 and the other operations extended arbitrarily, for instance Sa = a and a ∘ y = y ∘ a = a for ∘ ∈ {+, ·} except 0 + a = 0. Closed terms denote standard numbers, so every closed instance holds. The universal fails at a.
* *Conclusion.* By Corollary 2.3, P(T ⊢ ∀x(0+x=x) | D_n) → 0 a.s. The posterior moves away from the actual axioms, to a deductively weaker theory, on data consisting only of their theorems.

This is the ω-gap of `AS:sec:univ:omega` in Bayesian form. Under L0 it is forced by the likelihood, not by caution. Track universal (Thm U10, §6) treats the derivation-likelihood case. Moving this example to L1 needs care: with parameters not admissible, Gen is vacuous and Lemma 1.7(c) fails (referee m12); universal defines faithfulness relative to its calculus for this reason.

**Lemma 3.3 (sound templates cover at most one zero-sum equation) [proved].** Let Z := {t = 0 : t a closed term built from 0 and + only}. If τ ∈ DT° and every instance of τ is true in ℕ (parameters, if admissible, read universally), then τ covers at most one member of Z.

*Proof.* Let τ cover some t = 0 ∈ Z.
* *Shape.* The datum has no binders. So τ's rigid skeleton has none, and every metavariable is 0-ary: a pattern occurrence of positive arity needs bound variables in scope. The only formula position in t = 0 is the root.
* *Root metavariable.* Then τ = F, a formula metavariable, which has the false instance 0 = S0.
* *Otherwise* τ = (u = v), with u, v term templates. u matches t, so u's rigid nodes are + and 0, and its metavariable occurrences are leaves. Hence val(uθ) = Σ_j c_j val(θ(z_j)), where c_j is the multiplicity of z_j in u. v matches 0, so v is 0 or a metavariable z.
* *v = 0.* Soundness requires Σ_j c_j val(θ(z_j)) = 0 for all θ. Taking θ(z_j) = S0 shows c_j = 0 for all j. So τ is ground and covers one sentence.
* *v = z, z not in u.* The value of uθ does not depend on θ(z). One of θ(z) ∈ {0, S0} gives a false instance.
* *v = z, z in u.* Soundness requires Σ_j c_j val(θ(z_j)) = val(θ(z)) for all θ. Unit test values give c_z = 1, and c_j = 0 for j ≠ z. So u contains z once and is otherwise ground. Covering t = 0 forces θ(z) = 0, and τ covers exactly one member of Z, namely u[0/z] = 0. ∎

**Example 3.4 (finite class; the KL-minimiser is unsound; L0) [proved; computed].**
* *Human.* The human's axioms are Q. The human states t = 0 with t random in Z, from a law P_H with infinite support. Each datum is true, hence a Q-theorem (Q decides closed equations [known]).
* *Class.* **H** := {T_1, …, T_m, T_esc}, with prior positive on all. Each T_j is any finite set of DT° templates all of whose instances are true. T_esc := {z = 0}. Likelihood L0 with full-support Q.
* *Claim.* A.s. π_n(T_esc) = 1 for all large n.
* *Proof of the claim.*
  * By Lemma 3.3 each T_j covers only finitely many members of Z. Since supp P_H is infinite, P_H(Z ∖ ⋃_j ∪inst(T_j)) > 0.
  * So a.s. some datum falls outside all of them. Then every T_j has likelihood 0, while P_{T_esc} > 0 on Z.
* *Consequence.* T_esc ⊢ S0 = 0, and Q ⊢ ¬(S0 = 0).
* *Adding Q does not help under L0.* Q's axioms are ground templates whose instance set contains no member of Z, so Q dies at the first datum. This is specific to citation: the human's axioms have likelihood 0 because the data are not axiom instances (referee m16). Example 3.6 asks what a derivation likelihood changes.

**[computed: `c4_ville.out`, Part 2]** Twenty sound theories (the best possible: ground equations for the 20 most likely data, with weights equal to the human's conditional probabilities) against T_esc, with prior 0.99 on the sound ones. S0 = 0 reached posterior ≥ 0.99 in 2000/2000 runs, with median time 17 data.

**Remark 3.5 (the full countable class; the KL-projection picture can fail) [conjecture; computed illustration].**
* *Why the picture fails.* In the full class **H** with Dirichlet weights, the theories with finite KL to the human law of Example 3.4 are unsound (Lemma 3.3), and their infimum KL is 0. Approximating "hybrids" (memorise the frequent data, plus an escape template for the rest) have KL → 0. Pure memorisation theories are sound but have infinite KL each. Yet as a family they code the data with o(n) extra bits, so they beat any single theory with KL > 0. Theorem 3.1 says nothing here, and neither do the general results without their conditions.
* *Which wins.* Memorisation pays prior bits λℓ(s) once per distinct datum, plus a Dirichlet cost. A hybrid pays ln(1/w_esc) + ln(1/Q(t)) nats per occurrence of an unmemorised datum. In c7 the hybrid wins. **[computed: `c7_misspec_full.out`]** The lower bound on the hybrid's score exceeds memorisation's by 7 000–25 000 bits at n = 10⁴ for λ = 1 and 2, on three seeds.
* *Conjecture.* In Example 3.4 with the full class, the posterior mass of unsound theories tends to 1. The computation compares three hand-picked families and does not sum over **H**, so it is evidence, not a proof.

**Example 3.6 (a derivation likelihood does not reliably rescue the human's axioms) [computed: `c16_L1_robust.out`; new, referee Q1 and m16].**
* *Model "L1-eq".* A derivation grammar of the brief's kind for closed equations over 0, S, +. Each node cites a template of T (α_ax; metavariables from Q), or applies refl (t ∼ Q), sym, trans (valid iff the middle terms agree), congruence for S, or congruence for + (a side term u ∼ Q, left or right). A tree is valid iff its steps are valid and every term lies in U_N, the closed terms of size ≤ N. P_T = μ_T/Z_T, with μ_T computed exactly as the least fixpoint of the grammar's equation. These rules are complete for closed equational consequence [known: Birkhoff 1935 (unverified)]. A Monte Carlo simulation agrees with the fixpoint (Z = 0.54909 against 0.54965 ± 0.00091; |z| ≤ 1.31 on eight conclusion frequencies).
* *Class.* T_Q := {z+0=z, z₁+Sz₂=S(z₁+z₂)} (Q4 and Q5, the human's axioms for +; sound); T_Q0 := T_Q ∪ {0+z=z} (sound); T_esc := {z=0} (unsound); T_mix := T_Q ∪ {z=0} (unsound). Uniform weights.
* *Human law.* t = 0, with t a closed {0,+}-term from a PCFG (0 with probability 1 − h, + with h) conditioned on size ≤ N; h ∈ {0.3, 0.45}; with and without the datum 0 = 0.
* *Results.* The table gives which theory minimises the cross-entropy CE(T) = −E_H ln P_T(t = 0). By Theorem 3.1 the posterior on this finite class concentrates on it.

| grammar | Q root law (0, S, +) | settings (N ∈ {7, 9}, 2 values of h, with/without 0 = 0) | CE minimiser |
|---|---|---|---|
| 1: α = (ax .35, refl .15, sym .1, trans .15, congS .1, cong+ .15) | (.55, .2, .25) | 8 | unsound in 8/8 (T_esc with 0 = 0, T_mix without) |
| 2: α = (.5, .1, .05, .2, .05, .1) | (.55, .2, .25) | 8 | unsound in 8/8 |
| 3: as grammar 1 | (.8995, .1, .0005): + rare under Q | 8 | sound T_Q0 in 5/8; unsound T_mix in 3/8 (all with 0 = 0) |

* *Per-datum costs* (grammar 1, N = 9; mean ln P_T(t = 0) over the terms of each size 3, 5, 7, 9): T_Q −1.82, −8.45, −15.52, −22.89, about 7 nats per extra +; T_esc −3.23, −5.22, −7.20, −9.19, about 2 nats per +. T_Q wins only on 0+0 = 0, a single citation of Q4. In grammar 3, T_esc pays ln(1/(p₊p₀)) ≈ 7.7 nats per + through Q (−8.58, −16.30, −24.01, −31.72) and T_Q0 is ahead by a roughly constant offset at sizes 5–9 (−7.34, −14.55, −22.19 against −16.30, −24.01, −31.72).
* *Example cross-entropies* (grammar 1, N = 9, h = 0.45, data t ≠ 0): T_Q 7.758, T_Q0 7.124, T_esc 4.951, T_mix 4.904 nats. So the posterior odds of T_Q against T_mix fall by about 2.85 nats per datum.
* *Reading.* A citation of z = 0 pays for the symbols of t once, through Q. A derivation from Q4 and Q5 pays for one citation and one transitivity or congruence step per +, and also for the instantiated terms. Which is cheaper depends on Q: when Q generates the data's terms at moderate cost (grammars 1 and 2, where Q gives + probability 0.25, comparable to its frequency in the data), the unsound escape wins; when + is very rare under Q (grammar 3), the sound axioms win on data with + symbols.
* *Limits.* Truncated model (terms of size ≤ 9), equational fragment only (not the calculus K), three grammars, a finite class. The per-+ costs are measured only up to size 9; in grammar 3 the per-+ cost of T_Q is still rising there (6.3, 7.5, 7.9 nats between consecutive sizes) while T_esc's is 7.7, so the large-term limit in grammar 3 is not settled.

**Conjecture 3.7.** In untruncated L1-eq, the per-+ derivation cost from T_Q converges: ln P_{T_Q}(t = 0) = −c_der·#₊(t) + O(1) on balanced families of {0,+}-terms, with c_der depending on the rule probabilities and Q. Then T_esc beats T_Q on human laws with a large mean number of + symbols iff ln(1/(p₊p₀)) < c_der. In grammar 1 the measured values are c_der ≈ 7 and ln(1/(p₊p₀)) ≈ 2.

**Summary of §3.**
* Under misspecification the posterior follows the best *generator*, not the best *axioms*.
* The best generator can be deductively weaker (Example 3.2) or unsound (Examples 3.4 and 3.6).
* In the finite case the target is the KL-minimiser. In the full template class, "best" is decided by the coding costs of rare data, and an over-general escape template is cheap.
* A derivation likelihood removes the specific L0 failure (the human's axioms no longer have likelihood 0), but in the computed equational model the unsound escape template still wins whenever Q instantiates the data's terms cheaply relative to derivation steps.

---
## 4. Soundness against adaptive provers

**Protocol.** In each round, either a datum X_i arrives, or the prover submits a query q.
* The arrival schedule may be chosen by the prover.
* The verifier V_{δ,d} answers ACCEPT iff π_t({T : q ∉ Th_d(T)}) ≤ δ. Otherwise it may ESCALATE to a deterministic oracle that answers whether q ∈ Th_d(T*). The answer becomes a constraint that multiplies each T's weight by 1[q ∈ Th_d(T) ⟺ q ∈ Th_d(T*)].
* The posterior is π_t(T) ∝ π(T) Π_{i≤n(t)} P_T(X_i) Π_j c_j(T). With Dirichlet weights, P_T(X^n) is replaced by the marginal P^Dir_T(X^n) (§4.2).
* d ≤ ∞ is the derivability bound used by the verifier ("bounded derivability").
* Let C*_d := {T : P_T = P_{T*}, Th_d(T) = Th_d(T*)} and W*_d := π(C*_d) ≥ π(T*).

### 4.1 Fixed weights

**Theorem 4.1 (time-uniform soundness, fixed weights) [proved; this is `IL:thm:caution:ville`(b) adapted].**
* *Hypotheses.* Setting W: every T carries a *fixed* law P_T (fixed mixture weights), and the data are i.i.d. from P_{T*}, T* ∈ **H**. And δ ≤ W*_d δ′.
* *Conclusion.* There is an event G with P(G) ≥ 1 − δ′, depending only on the data sequence, on which no prover ever gets accepted a sentence outside Th_d(T*), in any round.
* *Provers covered.* Randomised, adaptive, computationally unbounded, knowing T*, the verifier and the whole future data sequence, and choosing the arrival timing.

*Proof.* This is the proof of `IL:thm:caution:ville`(b) (`IL:app:caution:ville`, using `IL:lem:app:caution:ville`), in the class form of `IL:thm:informal:ville` (proof in `app-informal.tex`, `app:informal:verify`). The role of shadow-measurability there is played by the definition of C*_d. Let L_t(T) := Π_{i≤n(t)} P_T(X_i) Π_j c_j(T).
1. **C*_d keeps the target's likelihood.** For T ∈ C*_d: P_T = P_{T*}, and every constraint satisfies c_j(T) = c_j(T*) = 1, because Th_d(T) = Th_d(T*). So L_t(T) = L_t(T*), and with Z_t := Σ_T π(T)L_t(T)/L_t(T*) we get π_t(C*_d) = W*_d/Z_t. Here L_t(T*) > 0 a.s.
2. **Constraints only help.** Every c_j ≤ 1, so Z_t ≤ Z^H_{n(t)} pathwise, where Z^H_n := Σ_T π(T)Π_{i≤n}P_T(X_i)/P_{T*}(X_i) = M(X^n)/P_{T*}(X^n).
3. **Ville.** Z^H is a nonnegative supermartingale in σ(X_1..X_n) with Z^H_0 = 1: E[P_T(X)/P_{T*}(X)] ≤ 1, then Tonelli. By Ville's inequality the event G := {sup_n Z^H_n < 1/δ′} has probability ≥ 1 − δ′.
4. **Conclusion.** On G, π_t(C*_d) > W*_d δ′ ≥ δ at every t. If q ∉ Th_d(T*), then q ∉ Th_d(T) for every T ∈ C*_d. So π_t({T : q ∉ Th_d(T)}) > δ, and q is not accepted. ∎

**[computed: `c4_ville.out`, Part 1; `referee_code/r7_ville_fixed.out`]** Well specified, fixed weights. The frequency of {∃n ≤ 300 : π_n(T*) ≤ δ} was 0.044, 0.014 and 0.004, against the Ville bounds 0.10, 0.033 and 0.010 (δ = 0.03, 0.01, 0.003; π(T*) = 0.3). The referee's richer class (9 hypotheses, every competitor proving the same invalid query) gave 0.0365, 0.0125, 0.0027 against δ/π(C*) = 0.130, 0.052, 0.013.

**Remarks on Theorem 4.1.**
* **The brief's H3 is confirmed, for fixed weights.** It is the special case C*_d ⊇ {T*}: an invalid acceptance requires π_t(T*) ≤ δ, i.e. Z_t ≥ π(T*)/δ. That has probability ≤ δ/π(T*), uniformly over times and queries, because there is one global event and no union bound over queries.
* **It is a per-target guarantee.** It covers every T* with π(C*_d) ≥ δ/δ′. Under π_λ it covers every theory with λℓ(T*) ≤ log₂(δ′/δ). For long axiom systems the guarantee is weak: δ must be below 2^{−λℓ(T*)}δ′.
* **The constant δ ≤ W*δ′ cannot be improved [proved].** `IL:prop:caution:tight` uses R* = {a, b} (probabilities 1 − u, u) against a competitor R′ = {a, c} that generates only a but proves c. That exact pair is not in the template models: supp P_{T′} ⊆ supp P_{T*} implies Th_d(T′) ⊆ Th_d(T*), under L0 (theorems depend only on instances) and under L1 (supp = Th) (referee m13). Take instead T′ = {a, c} with fixed weight ε on c. On data a, a, … its likelihood ratio against T* is ((1−ε)/(1−u))^t. The IL waiting time t* is the least t with (1−u)^{−t} > θ, and the inequality is strict at t*. So for every ε below some ε₀ > 0 the threshold is crossed at the same t*, T′ dies at the first b exactly as R′ does, and the acceptance probability equals the IL value (1−u)^{t*}, which tends to δ′ as u, W* → 0.
* **The hypotheses that matter.**
  * Well-specification of the *data law*, not only of the theorem set.
  * Fixed weights, or one of the two Dirichlet versions of §4.2. With Dirichlet weights Theorem 4.1 itself is vacuous (Remark 4.5), and its natural analogue fails (Example 4.9; referee M1).
  * A proper prior that does not depend on n. A steeper penalty λ_n that grows with n (as in `inferential-learning/research/theory/T5-…`) makes π_n something other than a posterior. Step 3 then fails, and I have no replacement.
  * Truthful constraints.
* **Computability (corrected after the referee, m8).**
  * *Finite truncations.* The theorem holds for any finite truncation **H**_N ∋ T* with the renormalised prior, with W*_d replaced by π(C*_d ∩ **H**_N)/π(**H**_N). That quantity is at least π(T*)/π(**H**_N) ≥ π(T*), so the guarantee stated through π(T*) only improves. Stated through π(C*_d) it can get worse, when most of C*_d lies outside **H**_N (`notes.md` said "W* only grows"; false in general). Example: **H** = {T*, T₂, T₃} with T₂ ∈ C*_d and prior (0.01, 0.89, 0.10); for **H**_N = {T*, T₃} the quantity is 0.01/0.11 ≈ 0.09, against π(C*_d) = 0.90.
  * *Likelihoods.* L2 likelihoods are finite sums only when Q has finite support (truncated bodies; then the cut formulas of MP range over a finite set too). With full-support Q they are infinite sums (`notes.md` said "finite sums"; false). Example: T = {P → b} with P a 0-ary formula metavariable. At depth 1, P_T(b) sums α_MP·μ(A)·μ(A → b) over the infinitely many logical-axiom instances A, each with its own citation of the template at P := A. For L1 with m < 1, Prop 2.7(a) computes each likelihood to any precision.
  * *A computable verifier.* For a finite class and finite d, compute the non-deriving mass π_t({T : q ∉ Th_d(T)}) to within ε (Prop 2.7(a); Th_d is decidable) and accept iff the upper end of the interval is ≤ δ. Acceptance then implies that the true mass is ≤ δ, so the guarantee of Theorem 4.1 holds verbatim [proved]. For truncated Q the computation is exact.

**Proposition 4.2 (misspecified: a non-theorem is accepted with probability 1) [proved; computed].**
* *Setting.* Example 3.4: human axioms Q; human data t = 0 with t ∈ Z; finite class of sound theories plus T_esc = {z = 0}; Q itself may be in the class. Likelihood L0.
* *Prover (corrected after the referee, m2).* It waits until the non-deriving mass π_t({T : T ⊬ S0 = 0}) is ≤ δ, and then submits S0 = 0.
* *Claim.* With probability 1 the verifier V_{δ,∞} accepts S0 = 0 at some finite time, for every δ > 0, whether or not it escalates. And Q ⊢ ¬(S0 = 0).
* *Why the waiting matters.* `notes.md` used a prover that submits S0 = 0 in every round. Against a verifier that escalates every non-accepted query, the oracle's "not a theorem" kills T_esc at the first submission, so that prover succeeds only if T_esc already dominates at the first round.

*Proof.* Example 3.4: a.s. π_n(T_esc) = 1 eventually, and T_esc ⊢ S0 = 0. The prover's only submission is made when it is accepted. ∎

**[computed: `c4_ville.out`, Part 2; `referee_code/r3_ville_dirichlet.out`, Part 2]**
* Non-escalating verifier, prover submitting every round: accepted in 2000/2000 runs, by n = 50 in 90%.
* Escalating verifier: the non-adaptive prover succeeded in 11/400 runs; the waiting prover in 400/400.

In Example 3.2 the misspecification makes the verifier incomplete (it never accepts ∀x(0+x=x)), not unsound. In Example 3.4 it makes it unsound. Which happens depends on whether the best generator is weaker than T* or incomparable with it.

**Proposition 4.3 (the δ → 0 limit is the cautious verifier, read on theorems) [proved].** Suppose each P_T has a fixed support supp_T. (This holds for fixed weights, and for Dirichlet weights, whose marginal P^Dir_T(D) > 0 iff D ⊆ ∪inst(T) under L0.)
(a) **Support of the posterior.** π_n(T) > 0 iff π(T) > 0 and D_n ⊆ supp_T. So V_{0,d}, which accepts iff π_n({T : q ∉ Th_d(T)}) = 0, accepts exactly
  ∩{Th_d(T) : π(T) > 0, D_n ⊆ supp_T}.
(b) **Deterministic soundness.** V_{0,d} is sound for every T* with π(T*) > 0 and D_n ⊆ supp_{T*}, with no probability and no well-specification. This is `IL:thm:caution:bayesdet` with the VS posterior. Also V_{δ,d} ⊇ V_{0,d} for δ ≥ 0.
(c) **No bound gives no generalisation.** Under L0 with full-support Q, if π charges every finite theory, then V_{0,d} accepts exactly Th_d(D_n). This is `AS:prop:many:bound` (Acc_∞(D) = D), read on theorems.
(d) **With a bound, theorem-level caution accepts at least as much.** Under L0, if supp π = **H**_k (at most k templates), then
  V_{0,d} ⊇ Th_d(Acc_k(D_n)),
  where Acc_k is the cautious k-union learner of `AS:def:setting:protocol`. In general classes the inclusion can be strict.

*Proof.*
* (a) The likelihood is positive iff every datum is in supp_T.
* (b) T* is in the intersection of (a).
* (c) The memorisation theory T_D (ground templates for the distinct data) is in the support, and Th_d(T_D) = Th_d(D_n) ⊆ Th_d(T) for every T whose instances contain D_n.
* (d) Every T in the support has ∪inst(T) ⊇ Acc_k(D_n), and Th_d is monotone in the axiom set.
* (d), strictness. Take the class {T_1, T_2} with T_1 = {c, a∧b}, T_2 = {c, b∧a}, and D = {c}. Then V_0 ∋ a. But the instance-level intersection is {c}, which does not prove a.
* Whether the inclusion can be strict for **H**_k(DT°) itself, I did not settle. Conv §7 makes a related but different point: the cautious learner may not accept induction on an unused connective *as an axiom instance*, while Th(Acc_k(D)) contains it *as a theorem*. ∎

**Proposition 4.4 (completeness without anchors) [proved].**
* *Setting.* Setting W, under L0 (full-support Q, any d) or under L1 (d = ∞, parameters admissible).
* *Claim.* For every s ∈ Th_d(T*) and every δ > 0, V_{δ,d} accepts s at all sufficiently large n, almost surely.
* *Proof.* By Corollary 2.3 the non-deriving mass tends to π(C* ∩ {T : s ∉ Th_d(T)})/π(C*) = 0. Under these likelihoods all of C* has the theorems of T* (§2.1). ∎
* *Dirichlet weights.* Under L0 the same holds for Lebesgue-a.e. w*, by Theorem 5.1(b): the posterior mass of {T : ∪inst(T) = ∪inst(T*)} tends to 1, and all those T prove s.

### 4.2 Dirichlet weights (new; referee M1)

**Remark 4.5 (Theorem 4.1 is vacuous for Dirichlet weights) [proved].** Read Theorem 4.1 with the parameter (T, w) and the prior π(T)Dir_T(dw). Its class is C*_d = {(T, w) : P_{T,w} = P_{T*,w*}, Th_d(T) = Th_d(T*)}. If |T*| ≥ 2, the component laws of T* are linearly independent, and w* lies outside a countable set, then this class has prior mass 0 (proof of Theorem 5.1(b″)). Then δ ≤ W*δ′ forces δ = 0. So `notes.md`'s use of Theorem 4.1 for the default Dirichlet model (§0, §5.4, §5.5 there) was unsupported.

**Lemma 4.6 (mixture regret) [(a), (b), (d) proved; (c) known and computed].** Let T have K templates with laws q_τ (any probability laws on S; under L0, q_τ = Q_τ), P_{T,w} := Σ_τ w_τ q_τ, and Dir(α) weights, A := Σ_τ α_τ. Define
  R_α(n, K) := min over c ∈ ℕ^K with Σ_τ c_τ = n of E_{Dir(α)}[Π_τ w_τ^{c_τ}] / Π_τ (c_τ/n)^{c_τ}   (0⁰ := 1).
(a) For every w in the closed simplex and every x^n: P^Dir_T(x^n) ≥ R_α(n, K)·P_{T,w}(x^n).
(b) If α_τ ≤ 1 for every τ, then R_α(n, K) ≥ Γ(A) / (e·(K−1)!·Π_τ Γ(α_τ)) · (n+1)^{−(K−1)}.
(c) For α_τ ≡ ½: −ln R_{½}(n, K) = ((K−1)/2)·ln n + O(1) [known: Krichevsky & Trofimov 1981 (unverified); computed: `c11_ville_dirichlet.out`, Part A2, slopes −0.499 (K = 2) and −0.993 (K = 3) against −0.5 and −1; experiments `checks/kt_regret.out`].
(d) For α_τ ≡ α > 0: R_α(n, K) ≤ Γ(Kα)Γ(α+n)/(Γ(α)Γ(Kα+n)) ~ [Γ(Kα)/Γ(α)]·n^{−(K−1)α}. So for α = 1 the exponent K − 1 in (b) is tight [computed: Part A2, slopes −0.993 (K = 2) and −1.960 (K = 3)].

*Proof.*
* (a) Expand both sides over labellings ℓ of the positions by templates (as in §1.5): P_{T,w}(x^n) = Σ_ℓ Π_τ w_τ^{c_τ(ℓ)} Π_i q_{ℓ_i}(x_i), and P^Dir_T(x^n) = Σ_ℓ E_Dir[Π_τ w_τ^{c_τ(ℓ)}] Π_i q_{ℓ_i}(x_i). For each ℓ, Π_τ w_τ^{c_τ} ≤ Π_τ (c_τ/n)^{c_τ} (the maximum over the simplex is at w = c/n), so the Dirichlet moment is ≥ R_α(n, K)·Π_τ w_τ^{c_τ}. Sum over ℓ. This termwise argument is experiments Prop X8(c).
* (b) Fix c and put v := c/n, η := 1/(n+1), B := {(1−η)v + ηu : u in the simplex}. On B, w_τ ≥ (1−η)v_τ, so Π_τ w_τ^{c_τ} ≥ (1−η)^n Π_τ v_τ^{c_τ} ≥ e^{−1}Π_τ v_τ^{c_τ}, because (1 + 1/n)^{−n} ≥ e^{−1}. The Dirichlet density Γ(A)/Π_τΓ(α_τ)·Π_τ w_τ^{α_τ−1} is ≥ Γ(A)/Π_τΓ(α_τ) on the simplex, since w_τ ≤ 1 and α_τ ≤ 1. B is an affine image of the simplex scaled by η, so its (K−1)-dimensional volume is η^{K−1}/(K−1)!. Hence E_Dir[Π w^c] ≥ ∫_B Π w^c dDir ≥ e^{−1}Π v^c · Γ(A)/Π_τΓ(α_τ) · η^{K−1}/(K−1)!.
* (d) Take c = (n, 0, …, 0): Π(c/n)^c = 1 and E_Dir[w_1^n] = Γ(Kα)Γ(α+n)/(Γ(α)Γ(Kα+n)); then Γ(a+n)/Γ(b+n) ~ n^{a−b}. ∎

**[computed: `c11_ville_dirichlet.out`, Part A]** The Dirichlet marginal computed exactly (a Bernstein-form dynamic programme, checked against quadrature to 6 decimals) for K = 2 and K = 3 with *overlapping* components on a four-letter alphabet, w* interior and on the boundary, random and constant sequences, n up to 3000. The largest value of (regret − bound (b)) was −2.81 (K = 2, α = ½), −1.00 (K = 2, α = 1) and −6.45 (K = 3, α = ½): the bound holds in every trial, and it is attained up to the constant 1 at the boundary for α = 1.

**Theorem 4.7 (soundness on average over the weight prior) [proved].**
* *Setting.* A countable class with prior π(T) and Dirichlet weights Dir_T. Each T has the marginal law P^Dir_T on data sequences (under L0, L1 or L2; it is a probability on S^n, consistent in n). The verifier uses the posterior on T, π_t(T) ∝ π(T)P^Dir_T(X^n)Π_j c_j(T), with truthful constraints. The data are drawn from P^Dir_{T*}: first w* ∼ Dir_{T*}, then i.i.d. from P_{T*,w*}.
* *Class.* C^Dir_d := {T : P^Dir_T = P^Dir_{T*} on S^n for every n, and Th_d(T) = Th_d(T*)} ∋ T*.
* *Conclusion.* If δ ≤ π(C^Dir_d)·δ′, there is a data event G with P^Dir_{T*}(G) ≥ 1 − δ′ on which no prover ever gets accepted a sentence outside Th_d(T*). Consequently, for every η ∈ (0, 1], Dir_{T*}{w* : P^∞_{T*,w*}(G^c) > δ′/η} ≤ η.

*Proof.* Steps 1, 2 and 4 of Theorem 4.1 with P_{T*} replaced by the sequence law P^Dir_{T*}. Step 3: Z_n := M(X^n)/P^Dir_{T*}(X^n), M := Σ_T π(T)P^Dir_T, is a nonnegative supermartingale under P^Dir_{T*} with Z_0 = 1. Indeed E[Z_{n+1} | X^n] = Σ_{x : P^Dir_{T*}(X^n x) > 0} M(X^n x)/P^Dir_{T*}(X^n) ≤ M(X^n)/P^Dir_{T*}(X^n), because M is consistent. Ville gives G := {sup_n Z_n < 1/δ′}. For the consequence, f(w*) := P^∞_{T*,w*}(G^c) has ∫ f dDir_{T*} = P^Dir_{T*}(G^c) ≤ δ′; apply Markov's inequality. ∎

This is experiments Prop X8(a), with the class C^Dir_d in place of T*. No bound on the number of templates is needed.

**Theorem 4.8 (soundness at every fixed weight vector, with a shrinking threshold) [proved].**
* *Setting.* As in Theorem 4.7, but the data are i.i.d. from P_{T*,w*} for a *fixed* w* in the closed simplex over T*, the likelihood is linear in w (L0; also the chain grammar of experiments §1.6), and K := |T*|. The verifier accepts at time t iff the non-deriving mass is ≤ δ_{n(t)}.
* *Conclusion.* If δ_n ≤ π(C^Dir_d)·δ′·R_α(n, K) for every n, then with P^∞_{T*,w*}-probability ≥ 1 − δ′ no prover ever gets accepted a sentence outside Th_d(T*).
* *Explicit thresholds.* By Lemma 4.6(b), for α ≤ 1 one may take δ_n := π(C^Dir_d)·δ′·Γ(A)/(e(K−1)!Π_τΓ(α_τ))·(n+1)^{−(K−1)}. With α = ½ and the exact R, δ_n ≍ n^{−(K−1)/2}. To cover every target with at most k templates, use min_{K≤k} R_α(n, K).

*Proof.* Z′_n := M(X^n)/P_{T*,w*}(X^n) is a nonnegative supermartingale under P_{T*,w*} (M is a probability on sequences). Let G := {sup_n Z′_n < 1/δ′}; P(G) ≥ 1 − δ′. All members of C^Dir_d have T*'s marginal likelihood and satisfy every constraint, and the other constraints are ≤ 1, so
  π_t(C^Dir_d) ≥ π(C^Dir_d)·P^Dir_{T*}(X^n)/M(X^n) = π(C^Dir_d)·[P^Dir_{T*}(X^n)/P_{T*,w*}(X^n)]/Z′_n.
On G this is > π(C^Dir_d)·R_α(n, K)·δ′ ≥ δ_n, by Lemma 4.6(a). An invalid q is not derived by any member of C^Dir_d, so its non-deriving mass exceeds δ_n. ∎

This is experiments Prop X8(c), with Lemma 4.6 supplying the termwise bound and an explicit constant. The guarantee is time-uniform; the price is a threshold that shrinks, which slows acceptance. Whether completeness (Prop 4.4) survives a threshold shrinking like n^{−(K−1)/2} is not settled here (§10).

**Example 4.9 (a constant threshold at a fixed weight vector fails) [computed: `c11_ville_dirichlet.out`, Part B; `referee_code/r3_ville_dirichlet.out`, Part 1; mechanism: proof sketch].**
* *Setting* (the referee's). L0. Q's root law is (p_0, p_S, p_+, p_·) = (0.5, 0.5 − ε, ε/2, ε/2). Truth T* = {0+0=0, (Sz)+0=Sz} with Dir(½, ½) weights; data from P_{T*,w*} with w* = (p_0, p_S)/(1 − ε), an interior point. Competitor T′ = {z+0=z}, a single template. T′ proves q := (0·0)+0 = 0·0; T* does not (term model in which + returns its first argument on (a, 0) exactly when a has root 0 or S). Prior ½ each; the verifier accepts q iff π_n(T*) ≤ δ = 0.01.
* *Results* (every n ≤ 2·10⁶ checked, 300 runs each):

| ε | B1: fixed w*, constant δ | B2: w* ∼ Dir(½,½), constant δ | B3: fixed w*, δ_n of Thm 4.8 |
|---|---|---|---|
| 10⁻⁵ | 0.997 | 0.007 | 0.000 |
| 10⁻⁶ | 1.000 | 0.003 | 0.000 |

  The bound of Theorem 4.7 is δ/π(T*) = 0.02; B2 respects it, B1 violates it by a factor of 50. B3 uses δ_n = π(T*)·δ′·(1/(eπ))/(n+1) with δ′ = 0.02 and never accepts.
* *Mechanism.* ln[P_{T′}(D)/P^Dir_{T*}(D)] = n ln(1−ε) + [ln P_{T*,ŵ}(D) − ln P^Dir_{T*}(D)] − n·KL(ŵ ‖ w*), with ŵ the empirical weights. The middle term is the KT regret ½ ln n + O(1) (Prop 5.4(b) with K = 2, α = ½); the last is O_P(1) (χ²₁/2). While εn ≪ 1, the log-ratio grows like ½ ln n and crosses ln 99. Not written out: a version of the χ² limit uniform over the window of n.
* *Contrast.* With fixed weights (Theorem 4.1's setting) P_{T′}/P_{T*,w*} = (1−ε)^n ≤ 1, so q is never accepted.

**Relation to anchors.**
* The cautious verifier becomes exact only once the data contain an anchor (`AS:lem:setting:closed`(c)), and in a class with unbounded k it never generalises (Prop 4.3(c)).
* The Bayesian verifier needs neither an anchor nor a bound. The likelihood, not mere consistency, moves mass away from memorisation and from splits.
* What it gives up is deterministic soundness. Its soundness is probabilistic (1 − δ′), holds only for well-specified data and for targets of prior mass at least δ/δ′, and with Dirichlet weights holds on average over w* (Thm 4.7) or at fixed w* with a shrinking threshold (Thm 4.8).
* The time to accept a given s is governed by the competitors that miss s. A split that omits a root of probability p gains a factor (1−p)^{−n} until the first datum with that root. This is the mechanism of `IL:prop:caution:tight`.
* The escalation bound `IL:thm:caution:bayesesc` transfers unchanged (with R* := C*_d) for fixed weights.

---

## 5. Positive data, Gold, spare slots

### 5.1 Identification in the limit with probability 1

**Theorem 5.1.** Let **H** be all finite sets of DT° templates, with any prior positive on T*.
(a) **Fixed generators [proved].**
* Let each T carry a fixed generator: L0 with fixed weights (full-support Q, positive weights), or L1 with fixed grammar parameters (all positive, m ≤ 1, full-support Q, parameters admissible).
* Let the data be i.i.d. from P_{T*}.
* Let the learner output the language g_n := L if π_n({T : supp P_T = L}) > ½, and "?" otherwise.
* Then, almost surely, g_n = supp P_{T*} for all large n. That is ∪inst(T*) under L0, and Th(T*) under L1.
* No bound on the number of templates is needed.

(b) **Dirichlet weights, instance-union level [proved; new proof after the referee].** Let the parameter be (T, w), with prior π(T)·Dir_T(dw; α), likelihood L0 with full-support Q, and data i.i.d. from P_{T*,w*}. For every T* with π(T*) > 0 and Lebesgue-almost every w* in the open simplex,
  π_n({T : ∪inst(T) = ∪inst(T*)}) → 1 almost surely.

(b′) **Weak consistency [known: Doob 1949; Ghosal & van der Vaart 2017, Thm 6.9 (numbering confirmed only through citing papers); proof sketch].** Under the same hypotheses, for every ε > 0, π_n({(T, w) : ‖P_{T,w} − P_{T*,w*}‖_TV < ε}) → 1 a.s.

(b″) **[refuted]** `notes.md` stated: "for every T* with π(T*) > 0 and Lebesgue-almost every w*, π_n({(T, w) : P_{T,w} = P_{T*,w*}}) → 1 a.s." *Counter-statement [proved]:* if |T*| ≥ 2 and the component laws {Q_τ : τ ∈ T*} are linearly independent, then for all w* outside a countable set this posterior mass is 0 at every n (referee M4).

(c) **[conjecture]** (b) holds for *every* w* in the open simplex.

*Proof of (a).* Theorem 2.1, together with supp P_T = ∪inst(T) (Lemma 1.6) or supp P_T = Th(T) (Lemma 1.7(c)). When π_n(C*) > ½, g_n = supp P_{T*}.

*Proof of (b).* The proof of Theorem 2.1, with the frequency functional replaced by a support functional.
* *A countable parameter that the data determine.* Let U(T, w) := ∪inst(T); it takes countably many values. For a data sequence x let F′(x) := {x_i : i ≥ 1}, the set of sentences that occur. For w in the open simplex, supp P_{T,w} = ∪inst(T) (Lemma 1.6(c)), a countable set of points of positive probability. Each occurs a.s. and nothing else occurs, so P^∞_{T,w}(F′ = U(T,w)) = 1. Dir_T charges only the open simplex. Hence Π(U = F′(X)) = 1 for the joint law Π of (T, w, X).
* *Steps 1 and 3 of Theorem 2.1.* The posterior given X^n is the conditional law Π(· | X^n) (Bayes' formula, with the likelihood as a density with respect to the prior). For each of the countably many sets A_ν := {(T, w) : ∪inst(T) = ν}, Lévy's upward theorem gives π_n(A_ν) → Π(A_ν | X_∞), M-a.s. Since F′(X) is X_∞-measurable, 1 = E[1{U = F′(X)} | X_∞] = Σ_ν 1{F′(X) = ν}Π(A_ν | X_∞) a.s. So M-a.s., π_n(A_{F′(X)}) → 1.
* *Step 4, changed.* Let E be the M-null event where this fails. M ≥ π(T*)∫P^∞_{T*,w}(·)Dir_{T*}(dw), so ∫P^∞_{T*,w}(E)Dir_{T*}(dw) = 0, and P^∞_{T*,w}(E) = 0 for Dir-a.e. w, which is Lebesgue-a.e. w (Dir has a positive density on the open simplex). For such w*, a.s. F′(X) = ∪inst(T*) and π_n(A_{∪inst(T*)}) → 1. ∎

This is the route the referee suggested. The sentence of `notes.md`, "the steps of the proof of Theorem 2.1 go through with the countable sum over **H** replaced by an integral", is withdrawn: step 3 needs a countable family of sets, which the support functional provides and the law itself does not.

*Sketch of (b′).* The law P_{T,w} lies in the Polish space of probability vectors on S (ℓ¹ metric), and the frequency functional F of Theorem 2.1 recovers it a.s. For a countable convergence-determining family of bounded continuous functions g, Lévy's theorem gives π_n(g(P)) → g(F(X)) a.s. So the posterior law of P_{T,w} converges weakly to δ_{P*}, which gives the TV statement. Transfer to Lebesgue-a.e. w* as in (b). Not written out: the choice of the family and the passage from weak convergence to TV balls.

*Proof of (b″).* Fix T. The set W_T := {w : P_{T,w} = P*} is the intersection of the simplex with an affine subspace. If it had positive Lebesgue measure in the simplex, the affine map w ↦ P_{T,w} would be constant on an open set, hence on the whole simplex, so every component of T would have law P*. (For |T| = 1 the weight is trivial, and the condition is Q_τ = P*.) The posterior on w given T is absolutely continuous with respect to Dir_T. So the posterior mass of the exact class is 0 at every n unless some template σ has Q_σ = P* = Σ_τ w*_τ Q_τ. For each σ, linear independence allows at most one such w*. There are countably many σ. ∎

### 5.2 Gold

**Proposition 5.2 (L∞ versus L₅) [proved].**
* *Setting.* Let L_1 ⊊ L_2 ⊊ ⋯ with union L_∞, all subsets of S. Each L_i (i ≤ ∞) has a generator P_i with supp P_i = L_i, and prior mass π_i > 0 on the class with generator P_i.
* (a) For each i ≤ ∞, if the data are i.i.d. P_i, then g_n = L_i eventually, almost surely.
* (b) There is a text for L_∞ (a sequence that enumerates L_∞ and contains nothing else) on which g_n ≠ L_∞ for infinitely many n.
* (c) The set of such texts has P_∞^∞-probability 0.

*Proof.*
* (a) Theorem 2.1.
* (b) Enumerate L_∞ = {e_1, e_2, …}. Build the text in stages.
  * At stage i, let σ be the finite prefix built so far. Pick k_i > k_{i−1} with σ ∪ {e_i} ⊆ L_{k_i}. This is possible because the chain is increasing with union L_∞.
  * Append e_i. The new prefix σ' has positive P_{k_i}-probability, because its elements lie in L_{k_i} = supp P_{k_i}.
  * By (a), applied to P_{k_i}^∞ conditioned on the prefix σ', almost every continuation leads to g_n = L_{k_i} at some finite n. Pick such a continuation, with elements in L_{k_i} ⊆ L_∞, and cut it at a time where g_n = L_{k_i}.
  * The resulting sequence lists every e_i and only elements of L_∞. At infinitely many times g_n = L_{k_i} ≠ L_∞.
* (c) (a) with i = ∞. ∎

**Relation to conv §9.**
* The cautious verifier always prefers the smallest consistent hypothesis and never reaches L_∞. A bold learner prefers L_∞ and loses the chain. Gold's theorem says no single preference handles both ends of a limit point, on every text.
* The Bayesian learner with generators has no fixed preference. It prefers L_5 when the data look like P_5-data and L_∞ when they look like P_∞-data. For example, on P_5-data the likelihood ratio of L_∞'s generator against L_5's is P_∞(L_5)^n times a factor of mean ≤ 1 (Lemma 1.8(b)).
* It fails only on a null set of texts, as (b) and (c) show. The price is the assumption that the generators are known up to the prior, i.e. well-specification.
* For the IΣ_n chain of conv §8 under L1 (theorem data):
  * P_PA puts positive mass on Th(PA) ∖ Th(IΣ_n), so IΣ_n is eventually rejected on PA-data.
  * Conversely, P_PA(Th(PA) ∖ Th(IΣ_5)) > 0, so PA is eventually rejected on IΣ_5-data.
  * Both masses are presumably tiny, since they need long derivations with induction of high complexity. If so, the number of data needed is of order 1/P_PA(Th(PA) ∖ Th(IΣ_n)), which grows with n. This is a heuristic; I did not estimate the masses. Track pa (§3) treats this chain.

**Prior work.**
* Stochastic positive data plus a generator in the hypothesis go back to Horning (1969, PhD thesis, Stanford: identification of stochastic context-free grammars) [known (unverified details)].
* Angluin (1988, "Identifying languages from stochastic examples", Yale tech. report YALEU/DCS/RR-614) [known (unverified)]. My recollection: without assumptions tying the distribution to the hypothesis, identification with probability 1 is no stronger than identification from text; with such assumptions it is stronger. Theorem 5.1 is of the second kind. I could not check her exact statements.

**Memorisation and the bound.**
* *Memorisation dies.* Every fixed memorisation theory T_E (ground templates for a finite set E) has supp P_{T_E} = E. If supp P_{T*} is infinite, P_{T_E}(D_n) = 0 eventually, a.s. This is part of Theorem 2.1, so memorisation needs no separate treatment.
* *Before it dies.* Prior and likelihood also penalise it. Its prior is 2^{−λΣ_{s∈E}ℓ(s)}, and with Dirichlet weights its marginal likelihood is a Dirichlet-multinomial over |E| categories, which costs about (|E|−1)/2·ln n. Track universal (Prop U6) shows that the *class* of memorisers can keep mass exp(−O(log² n)) under geometric numerals.

So the Bayesian needs no bound k. The cautious learner needs one (`AS:prop:many:bound`) because it uses only consistency, under which T_{D_n} is always a live hypothesis. The Bayesian uses likelihood, under which T_{D_n} is a live hypothesis with small weight.

### 5.3 Splits: the Occam terms and the MDL finding

By Prop 2.6(b) a schema and its root split are exact likelihood ties for matched fixed weights, under L0 and L1. With Dirichlet weights they are not ties: the split must learn the root distribution, which the unsplit template gets from Q.

**Proposition 5.4 (split against whole, L0) [proved (Stirling); the χ² limit is known].**
* *Setting.* Let τ be a single template, cited alone (no weight to learn), with T = {τ}. Let T' be its root split over K productions, with Dir(α) weights. Let the data be n instances of τ whose metavariable has root law r (children from Q). Write n_f for the root counts and r̂ := n_f/n.
* (a) **Exact formula.** Δ_n := ln P^Dir_{T'}(D) − ln P_T(D) = ln DirMult(n_f; α) − Σ_f n_f ln p_f. It depends on the data only through the root counts.
* (b) **Expansion.** If all n_f → ∞, then
  Δ_n = n·KL(r̂ ‖ p) − (K−1)/2·ln n + c_{K,α} + (α − ½)Σ_f ln r̂_f + o(1),
  with c_{K,α} := ln[Γ(Kα)/Γ(α)^K] + (K−1)/2·ln(2π).
* (c) **Well specified (r = p).** 2n·KL(r̂ ‖ p) → χ²_{K−1} in law [known: Wilks / Pearson]. So Δ_n = −(K−1)/2·ln n + O_P(1) → −∞: the posterior prefers the whole schema, at a polynomial rate n^{−(K−1)/2}.
* (d) **Misspecified (r ≠ p).** Δ_n/n → KL(r ‖ p) > 0 a.s.: the split wins linearly.
* (e) **Prior.** The prior adds a constant λ(ℓ(T') − ℓ(T)) > 0 in favour of the whole schema.

*Proof.*
* (a) Disjointness of the split's instance sets (Prop 2.6(b)) gives a single labelling. Q_{τ_f}(s) = Q_τ(s)/p_f.
* (b) Stirling: ln Γ(a + m) = (a + m − ½)ln m − m + ½ln(2π) + o(1). Apply it to the K + 1 Gamma terms with growing argument, write ln n_f = ln n + ln r̂_f, and collect terms.
* (d) The strong law for r̂, plus (b). ∎

**[computed: `c2_split.out`, Part B; `referee_code/r4_dirichlet_rates.out`, A]** K = 4, α = ½, p = (.5, .3, .1, .1), 400 runs per n.
* *Well specified.* Mean Δ_n = −4.93, −8.34, −11.77, −15.27, −18.85 at n = 10², …, 10⁶, against the predictions −4.94, −8.39, −11.85, −15.30, −18.76. P(Δ_n > 0) = 0 from n = 10³ on.
* *Misspecified* (r = (.4, .3, .2, .1), KL = 0.0494 nats). Mean Δ_n = 39.7, 482, 4917, 49356 at n = 10³, …, 10⁶, against the predictions 39.5, 480, 4920, 49352.
* The referee checked (b) for α = 0.3, 1, 2 (K = 3): the residual tends to 0 like 1/n.

**Proposition 5.6 (a schema against its split under derivation likelihoods; new, referee M3) [(a)–(c) proved; (d) conjecture; computed].**
* *Setting.* T = {τ}, where τ's metavariable M has a root-factoring Q (Prop 2.6(b)) with finite production set R, |R| = K, and root law p in the open simplex. T′ := {τ_r : r ∈ R} is the root split, with Dir(α) weights. The likelihood is L0, L1 (m < 1) or L2, all other grammar parameters fixed and shared. For a root law p′ on R, P^{(p′)} denotes the law for the theory {τ} when M's root production is drawn from p′ (children still from Q). BF_n := P^Dir_{T′}(X^n)/P_T(X^n).
* (a) For every weight vector w′ on R, P_{T′,w′} = P^{(w′)}. Hence P^Dir_{T′}(D) = ∫ Π_i P^{(p′)}(X_i) Dir(dp′; α), while P_T = P^{(p)}: *the split with learned weights is the schema with a learned root law.*
* (b) **Q fits the usage.** If the data are i.i.d. from P_T, then BF_n is a nonnegative supermartingale with BF_0 = 1. So P(sup_n BF_n ≥ 1/η) ≤ η for every η ∈ (0, 1), and BF_n converges a.s. to a finite limit. In posterior terms: with probability ≥ 1 − η, π_n(T′)/π_n(T) ≤ (π(T′)/π(T))/η at every n.
* (c) **Q misfits the usage.** If the data are i.i.d. from P^{(r)}, with r in the open simplex and P^{(r)} ≠ P^{(p)}, then n^{−1} ln BF_n → KL(P^{(r)} ‖ P^{(p)}) ∈ (0, ∞] a.s.: the split wins at a linear rate.
* (d) **[conjecture]** If the data are i.i.d. from P_T, p′ ↦ P^{(p′)} is identifiable, and its Fisher information at p is nonsingular, then ln BF_n = −((K−1)/2)·ln n + O_P(1), as under L0.

*Proof.*
* (a) Under (T′, w′) a theory-citation node chooses τ_r with probability w′_r and draws the children's bodies from Q. By the root factorisation and inst(τ) = ⊔_r inst(τ_r) (Prop 2.6(b)), its conclusion has the law of a citation of τ whose M has root law w′. All other nodes have the same laws, and validity and conclusions depend only on the nodes' conclusions. So μ and Z coincide, under L0, L1 and L2.
* (b) By Tonelli, E[BF_{n+1} | X^n] = ∫ Π_{i≤n}(P^{(p′)}/P^{(p)})(X_i) · Σ_{x : P^{(p)}(x) > 0} P^{(p′)}(x) Dir(dp′) ≤ BF_n. Ville's inequality [known; `IL:lem:app:caution:ville`] and the supermartingale convergence theorem [known].
* (c) Write ln BF_n = ln[P^Dir_{T′}(X^n)/P^{(r)}(X^n)] + Σ_i ln[P^{(r)}(X_i)/P^{(p)}(X_i)]. The second term divided by n tends to KL(P^{(r)} ‖ P^{(p)}) a.s., as in Prop 2.4(a). For the first term:
  * *Upper.* P^Dir_{T′}(X^n)/P^{(r)}(X^n) is a nonnegative supermartingale under P^{(r)} (as in (b)), so it converges a.s. to a finite limit, and limsup_n n^{−1} ln of it is ≤ 0.
  * *Lower.* For γ > 0 let U_γ := {p′ : KL(P^{(r)} ‖ P^{(p′)}) < γ}. By the continuity lemma below it contains a neighbourhood of the interior point r, so Dir(U_γ) > 0. Let Dir_U be the normalised restriction. By Jensen's inequality,
    ln ∫_{U_γ} Π_i (P^{(p′)}/P^{(r)})(X_i) Dir(dp′) ≥ ln Dir(U_γ) + Σ_i Y_i,  Y_i := ∫ ln(P^{(p′)}(X_i)/P^{(r)}(X_i)) Dir_U(dp′).
    The Y_i are i.i.d., E[Y⁺] ≤ ∫ E[P^{(p′)}(X)/P^{(r)}(X)] Dir_U(dp′) ≤ 1, and E Y = −∫ KL(P^{(r)} ‖ P^{(p′)}) Dir_U(dp′) ≥ −γ (Tonelli, applied to the positive and negative parts separately). By the strong law, liminf_n n^{−1} ln[P^Dir_{T′}(X^n)/P^{(r)}(X^n)] ≥ −γ a.s. Let γ ↓ 0 along a sequence.
  * *Continuity lemma: KL(P^{(r)} ‖ P^{(p′)}) → 0 as p′ → r.* For a tree π, Pr_{p′}(π)/Pr_r(π) = Π over π's theory-citation leaves of p′_f/r_f, where f is the root production chosen there. Let L(π) be the number of these leaves, ρ := min_f p′_f/r_f and ρ′ := max_f p′_f/r_f. Then μ_{p′}(x) ≥ Σ_{π→x} ρ^{L(π)}Pr_r(π) ≥ μ_r(x)·ρ^{E_r[L | x]} (Jensen, with E_r[· | x] the law of the valid trees with conclusion x), and Z_{p′} ≤ E_r[ρ′^L; valid]. So
    KL(P^{(r)} ‖ P^{(p′)}) ≤ ln(1/ρ)·E_r[L | valid] + ln(E_r[ρ′^L; valid]/Z_r).
    Here E_r[L | valid] ≤ E_r[N]/Z_r < ∞, with N the number of derivation nodes (m < 1). And E_r[ρ′^L; valid] → Z_r as ρ′ ↓ 1, by dominated convergence: L ≤ N and E_r[e^{θN}] < ∞ for small θ > 0 (Lemma 1.6(d) for the derivation tree). Both terms tend to 0 as p′ → r. Under L2, L ≤ 2^d and the lemma is immediate. ∎

**[computed: `c13_split_L2.out`]** A propositional L2 model (depth 2; atom a; logical axioms A1–A3 instantiated from a PCFG truncated to size ≤ 5; MP), τ = F → F with F = a or ¬G, K = 2, 5885 possible conclusions.
* (a) The split with weights (u, 1 − u) and the schema with root law u agree to 1.1·10⁻¹⁴ at three values of u.
* Citations are latent but only weakly so in this model: 88 of the 5885 conclusions have u-dependent probability through derived trees, and the derived share of P(a→a) is 2·10⁻⁵.
* (b) P(max_{n≤3000} BF_n ≥ 1/η) = 0.427, 0.133, 0.036 for η = 0.5, 0.2, 0.05 (1000 runs; every n checked).
* (c) KL(P^{(0.3)} ‖ P^{(0.6)}) = 0.11487 nats; mean n^{−1} ln BF_n = 0.11301, 0.11460, 0.11464 at n = 10³, 10⁴, 10⁵.
* (d) Mean ln BF_n = −1.765, −2.898, −4.114, −5.283, −6.405 at n = 10², …, 10⁶ (400 runs each); fitted slope −0.507 against ln n, and −0.498 on n ≥ 10⁴, against the conjectured −0.5.

**What this says about the MDL finding.**
* `AS:prop:many:mdlwell` (a well-specified code gains at most O(log n) from splitting). Under L0 it is Prop 5.4(c), with the sharper statement that the split *loses* like n^{−(K−1)/2}. Under L1 the upper half is proved in a sharper, time-uniform form (Prop 5.6(b): gain ≤ ln(1/η) nats at all times with probability 1 − η). The n^{−(K−1)/2} decay under L1 is a conjecture (Prop 5.6(d)), supported by c13.
* `AS:prop:many:mdlnaive` (a code that cannot learn the root statistics splits by a linear margin). Prop 5.4(d) under L0 and Prop 5.6(c) under L1, both proved.
* So, as far as proved, **a derivation-based likelihood does not change the MDL finding.** `notes.md` marked this sentence [proved] for all of it; that overclaimed (referee M3) and is withdrawn in favour of the precise statement above.
* *Not covered: competitors that only L1 keeps alive.* A partial split {τ_r : r ∈ R″}, R″ ⊊ R, has likelihood 0 under L0 at the first datum with a root outside R″. Under L1 it survives whenever it derives those instances. Conv §7 notes that induction for one connective class already yields all of PA. Track pa (§2) proves, with checked derivations, that a split containing any non-atomic connective derives every induction instance, and computes that an unseen-connective datum then costs 370–490 bits instead of having probability 0. Under well-specification such a theory has a different law, so it loses at the linear rate of Prop 2.4(a); under misspecified usage it can win. A general comparison is open (§10).
* *What would change the finding.* A richer, hierarchical Q, learned per template. Then the whole schema can learn r too, and the split's advantage reduces to context dependence of usage. The PC/DPC codes of `AS:tab:many:mdl` measure exactly this, and under the natural law G1 even DPC splits. Track pa (§2) finds the same: a shared positional grammar removes the linear gain.
* In Bayesian terms: the posterior tracks the usage statistics, not the logical boundary of the schema, whenever the instantiation model is misspecified.

### 5.4 Spare templates

**Proposition 5.5 (cost of a spare template) [(a), (d1) proved; (b), (c), (d2) proof sketch; all computed].** Let the truth be (T*, w*) with Dir(α_τ) priors, A := Σ_{τ∈T*} α_τ, and a spare template σ with prior parameter α_σ. Let R_n := P^Dir_{T*∪{σ}}(D)/P^Dir_{T*}(D).
(a) **σ covers no datum.**
* If no datum of D lies in inst(σ), then, for every such D, exactly,
  R_n = Γ(A + α_σ)Γ(A + n) / (Γ(A)Γ(A + α_σ + n)) ~ [Γ(A+α_σ)/Γ(A)]·n^{−α_σ}.
* With α_σ = ½ the cost is ½·log₂ n bits plus a constant, plus the prior's λℓ(σ) bits.
* It is enough that the data avoid inst(σ).
(b) **σ reaches outside the data's support.** If Q_σ(supp P*) = 1 − c with c > 0 and σ covers data, then ln R_n = −α_σ ln n + O_P(1).
(c) **σ is redundant** (inst(σ) ⊆ supp P*, Q_σ not in the span of T*'s components). Then ln R_n = −(α_σ/2) ln n + O_P(1).
(d) **σ's law is in the span of T*'s component laws** (new; referee m7).
* (d1) If Q_σ = Q_{τ_1} for some τ_1 ∈ T* (for instance σ an argument-permuted copy of τ_1, so inst(σ) = inst(τ_1) with a different code) and T*'s instance sets are pairwise disjoint, then for every D with n_1 data in inst(τ_1), exactly,
  R_n = [Γ(A+α_σ)Γ(A+n) / (Γ(A)Γ(A+α_σ+n))] · [Γ(α_1+α_σ+n_1)Γ(α_1) / (Γ(α_1+α_σ)Γ(α_1+n_1))],
  and R_n → [Γ(A+α_σ)Γ(α_1)/(Γ(A)Γ(α_1+α_σ))]·(w*_1)^{α_σ} a.s. The spare never vanishes; only its prior bits penalise it.
* (d2) If Q_σ is in the convex hull of T*'s component laws but equal to none, and the pushforward of the Dirichlet prior under w ↦ P_{T*∪{σ},w} has a continuous positive density at P*, then R_n tends to a positive constant (the ratio of the two prior densities at P*).

*Proof of (a).*
* The labellings for T* ∪ {σ} are those for T* with n_σ = 0.
* For each labelling the Dirichlet moment ratio is [Γ(A+α_σ)/Γ(A+α_σ+n)]·Γ(α_σ)/Γ(α_σ) ÷ [Γ(A)/Γ(A+n)], the same for every labelling. Factor it out.
* Asymptotics: Γ(a+n)/Γ(b+n) ~ n^{a−b}. ∎

*Proof of (d1).* P_{T*∪{σ},w} = Σ_{τ≠τ_1} w_τQ_τ + (w_{τ_1} + w_σ)Q_{τ_1}. By the aggregation property of Dirichlet laws, (w_{τ_1} + w_σ, (w_τ)_{τ≠τ_1}) ∼ Dir(α_1 + α_σ, (α_τ)_{τ≠τ_1}). So P^Dir_{T*∪{σ}} is the Dirichlet marginal of T* with α_1 replaced by α_1 + α_σ. With disjoint instance sets the single-labelling formula of §1.5 gives the ratio. Then Γ(a+n)/Γ(b+n) ~ n^{a−b} and n_1/n → w*_1 a.s. ∎

*Sketch of (b), (c).*
* *Reduction to one weight.* Write w = ((1−u)w̃, u), with u ~ Beta(α_σ, A) independent of w̃ ~ Dir(α_τ), by the aggregation property of Dirichlet laws. The per-datum factor is 1 − u + u·Q_σ(X)/P_{T*,w̃}(X).
* *(b).* At w̃ = w* its mean is 1 − uc, so the likelihood decays like e^{−ncu} in u. Then ∫u^{α_σ−1}e^{−ncu}du ~ Γ(α_σ)(cn)^{−α_σ}.
* *(c).* The mean is 1 (zero drift), and the log-likelihood in u is a local quadratic, −nIu²/2 + √n Z u. The integral against u^{α_σ−1} scales as n^{−α_σ/2}.
* *What is missing.* Uniformity in w̃ near w*, and the a.s. or in-probability control of the fluctuations. This is a boundary Laplace approximation, as in the overfitted-mixture analysis of Rousseau & Mengersen (2011, *JRSS B* 73(5):689–710) [known (the referee confirmed that their setting has continuous component parameters)].

*Sketch of (d2).* T* and T* ∪ {σ} parametrise the same family of laws, so the two marginals are integrals of the same likelihood against two prior densities on that family, and Laplace's method gives the ratio of the densities at P*. Not written out: the Laplace step.

**[computed: `c3_spare.out`, `c3b_redundant.out`, `c15_spare_inspan.out`; `referee_code/r4_dirichlet_rates.out`]**
* (a) The numerical integral matches the exact formula to 4 decimals at every n. The referee found slopes −0.500, −1.000, −1.999 for α_σ = ½, 1, 2.
* (b) Fitted slope −0.498 against −0.5; the referee: −0.500, −0.999, −1.991 for α_σ = ½, 1, 2.
* (c) Slope −0.346 on n ∈ [10², 10⁴], but −0.265 (standard errors ≈ 0.07 per point) on [10³, 10⁷], against −0.25; the referee: −0.230, −0.523, −0.961 for α_σ = ½, 1, 2 (against −0.25, −0.5, −1). The small-n slope is a transient.
* (d1) The exact formula equals the numerical integral to 5 decimals at n = 20, 200, 2000 for α_σ = ½, 1, 2. At n = 10⁶, ln R_n is within 0.003 of the limit (for example 0.1050 against 0.1050 at α_σ = ½, −0.405 against −0.4055 at α_σ = 2). The referee's case (d): slope 0.000, limit −0.288 matched.
* (d2) With w*_1 = 0.3, ln R_n changes by −0.031, −0.021, −0.004 per decade from n = 10² to 10⁵ (α_σ = ½), consistent with a limit. The density hypothesis matters: at w*_1 = ½ the truth equals Q_σ itself, the pushforward density is infinite at P* (the line w_1 + w_σ/2 = ½ runs into the vertex w_σ = 1, where the Dir(½) density behaves like (w_1w_2)^{−1/2}), and ln R_n *grows*, by 0.22, 0.20, 0.13 per decade (heuristically R_n ∝ ln n). The spare then gains on T*; in that case {σ} alone is also a generator of the data.

**Reading.**
* *How fast spares vanish.* Spares outside the data's support, or reaching outside it, vanish polynomially under Dirichlet weights, and exponentially under fixed weights (Lemma 1.8). Redundant spares vanish more slowly. Spares in the span do not vanish at all, and can even gain slowly.
* *The total over all spares.* Summed over all spares σ, the posterior mass of "T* plus one spare that covers no datum" is at most Σ_σ π(T* ∪ {σ})/π(T*) · R_n. That is O(n^{−α}) when Σ_σ 2^{−λℓ(σ)} converges (Lemma 1.4).
* *Spares do not threaten instance-set identification* when they lie in the support: inst(σ) ⊆ ∪inst(T*) in case (d). Those outside the support die (cases (a), (b)).
* *Spares and soundness.* For the verifier to accept an extra instance q ∉ Th_d(T*) of a spare, the theories containing it must hold mass ≥ 1 − δ. With fixed weights Theorem 4.1 excludes that with probability ≥ 1 − δ′; with Dirichlet weights, Theorem 4.7 (on average over w*) or Theorem 4.8 (shrinking threshold) does. `notes.md` cited Theorem 4.1 here for the Dirichlet model; that was unsupported (referee M1).
* *What spares cost is slow rejection.* With a REJECT option at threshold δ_r, q is rejected once the spare-containing mass falls below δ_r. That takes about (prior ratio/δ_r)^{1/α} data in case (b): polynomially many in the prior ratio and in 1/δ_r, against logarithmically many with fixed weights.
* *Contrast with the cautious learner.* There spare slots allow *splits*, which block acceptance of target instances and cost data *diversity* (`AS:thm:many:splits`). The Bayesian analogue of that incompleteness is not the spare template but the competitor that misses a type of target instance. Its cost is set by the frequency of that type: it gains (1−p)^{−n} until the first datum of the missing type (§4, "relation to anchors").

### 5.5 What the Bayesian gives up, compared with the cautious learner

| | cautious k-union verifier (`AS`) | Bayesian thresholded verifier (this track) |
|---|---|---|
| assumptions for soundness | realizability (target in **H**_k), bound k ≥ k′ | well-specification of the generator, prior mass ≥ δ/δ′; with Dirichlet weights, either averaging over w* or a threshold shrinking with n |
| soundness | deterministic, every prover, every time | probability ≥ 1 − δ′, every prover, every time: Thm 4.1 (fixed weights), Thm 4.7 (Dirichlet, on average over w*), Thm 4.8 (Dirichlet, every w*, δ_n ≍ n^{−(\|T*\|−1)/2}) |
| without the assumptions | sound relative to the closure cl(R*) (`AS:lem:setting:closed`); without a bound it accepts only the data | can accept a false sentence with probability 1 (Prop 4.2); with Dirichlet weights and a constant threshold, even a well-specified fixed w* can fail (Example 4.9) |
| completeness | exact once an anchor is present | each theorem eventually, a.s. (Prop 4.4; Dirichlet: a.e. w*); no anchor, no bound |
| splits | sound splits survive any negatives (`AS:thm:many:splits`) | exact ties at matched fixed weights; with learned weights Occam terms decide (Props 5.4, 5.6); usage statistics can reverse |
| guarantee depends on the target's length | no | yes: δ ≤ 2^{−λℓ(T*)}δ′; with Thm 4.8 also on \|T*\| |

---
## 6. Time penalty and Hänni's collapse

### 6.1 The two inductors, made precise

**Setting (Hänni's note).**
* L is a countable first-order language, U a universal prefix machine, and programs carry weight 2^{−|p|}.
* B is a fixed decidable background set of L-sentences, part of every axiom hypothesis; it may be empty.
* Data are labelled sentences D = ((φ_1, b_1), …, (φ_n, b_n)), with b_i ∈ {1 (true), 0 (false)}.

The two inductors:
* **AI (axiom induction requiring proofs).**
  * A hypothesis is a program p that halts on every input and decides a set A_p ⊆ Sent_L.
  * p is *compatible* with D if B ∪ A_p is consistent, B ∪ A_p ⊢ φ_i when b_i = 1, and B ∪ A_p ⊢ ¬φ_i when b_i = 0.
  * W_AI(D) := Σ_{p compatible} 2^{−|p|}.
* **FI_cons (function induction over consistent assigners).**
  * A hypothesis is a program f computing a partial map Sent_L → {acc, rej}, such that B ∪ Γ_f is consistent, where Γ_f := {φ : f(φ) = acc} ∪ {¬φ : f(φ) = rej}.
  * f is compatible if it gives every φ_i the label b_i.
  * W_FI(D) := Σ_{f compatible} 2^{−|f|}.
* **Predictions (semimeasure convention).** P_X(b_1..b_n | φ_1..φ_n) := W_X(D_n)/W_X(∅), with per-step factors W_X(D + (φ, b))/W_X(D).
  * Hypotheses that leave φ undecided drop out, so W(D + (φ,1)) + W(D + (φ,0)) ≤ W(D). This is Hänni's "speak of a semimeasure instead of renormalizing".
  * Log loss is −log₂ of the sequence probability.

**Proposition 6.0 (why Hänni restricts to consistent assigners) [proved].**
* Let FI_all be function induction over all assigners, consistent or not.
* Let R be a unary predicate, w_1, w_2, … distinct closed terms, and let φ_i be R(w_i) or ¬R(w_i) according to independent fair coins. Every φ_i is labelled true. This labelling is consistent.
* Then FI_all's log loss is at most c, a constant (the program "always accept").
* But AI's and FI_cons's expected log loss is at least n bits.

*Proof.*
* A compatible AI or FI_cons hypothesis cannot assign true to both ψ and ¬ψ. So W(D + (ψ,1)) + W(D + (¬ψ,1)) ≤ W(D), i.e. a + a' ≤ 1 for the two predictive probabilities.
* Averaged over the coin, the step loss is ½(−log₂ a − log₂ a') ≥ −log₂((a + a')/2) ≥ 1 bit.
* Sum over steps. ∎

This confirms Hänni's informal argument ("then solomonoff function induction will do well because 'always accept' … but axiom induction will suck"). It also shows why the fair comparison is with FI_cons.

**Theorem 6.1 (Hänni's equivalence, repaired) [proved].** There is a constant c, depending only on U, the syntax coding and the decider for B, such that for every finite labelled D:
  2^{−c} W_AI(D) ≤ W_FI(D) ≤ 2^{c} W_AI(D).
Hence, for every reveal order and every labelling, the semimeasure log losses of AI and FI_cons differ by at most 2c bits.

*Proof.*
* **W_FI ≥ 2^{−c} W_AI.** Map p to f_p := "on input φ, dovetail proof searches from B ∪ A_p for φ and for ¬φ; output acc or rej for the first proof found". Then |f_p| ≤ |p| + c₁, and the map is injective because p is a suffix of f_p's code.
  * If p is compatible, B ∪ A_p is consistent, so at most one of φ, ¬φ is provable. So f_p labels each φ_i correctly.
  * Γ_{f_p} ⊆ Th(B ∪ A_p), so B ∪ Γ_{f_p} is consistent. So f_p is compatible.
* **W_AI ≥ 2^{−c} W_FI (Craig's trick; Craig 1953, *J. Symb. Logic* 18:30–32 [known]).** Map f to the decider p_f of
  A^C_f := {φ^{∧(k+1)} : f(φ) = acc in exactly k steps} ∪ {(¬φ)^{∧(k+1)} : f(φ) = rej in exactly k steps},
  where ψ^{∧m} is the right-nested m-fold conjunction.
  * *Decidability.* Given χ, try each of the at most |χ| decompositions χ = ψ^{∧m}, and for each run f on the matching φ for m − 1 steps. This halts on every input.
  * *Same consequences.* Every member is equivalent to a member of Γ_f, and every member of Γ_f has such a power. So Cn(B ∪ A^C_f) = Cn(B ∪ Γ_f), which is consistent, and B ∪ A^C_f decides each φ_i as f does.
  * *Size.* |p_f| ≤ |f| + c₂, and the map is injective.
* **Losses.** Take c := max(c₁, c₂). The log losses are −log W(D_n) + log W(∅); each term differs by at most c between the two inductors. ∎

**Remarks on Theorem 6.1.**
* **The convention matters.** If one renormalises per step, P(b | φ, D) := W(D+b)/(W(D+0) + W(D+1)), the argument bounds each step's ratio by 2^{2c}, so only by 2c bits *per step*. The exact (constant) equivalence holds in the semimeasure convention. This answers Hänni's question "wtf is a sequence here?": any reveal order, with the semimeasure convention (§7).
* **The overhead.** Hänni's "same spec length as the axiom system plus a const" is right in both directions, with the proof-search wrapper and the Craig wrapper.
* **The background.** It needs no arithmetic. Hänni's own route via the schema "T(⌜φ⌝) = accept → φ" does need arithmetic, and it is correct only in a two-sorted reading.

### 6.2 Hänni's schema: when it is consistent

For an assigner f let Acc_f(x) be a Σ₁ arithmetic formula expressing "f halts on input x with output acc" (via Kleene's T predicate), and Rej_f likewise. Hänni's schema is
  A_f := {Acc_f(⌜φ⌝) → φ : φ ∈ Sent_L} ∪ {Rej_f(⌜φ⌝) → ¬φ : φ ∈ Sent_L}.

**Proposition 6.2 (two-sorted: his argument works) [proved].**
* *Setting.* Let L-sentences live in a sort σ, and arithmetic in a separate sort ν with B := Q on ν. Let Γ_f have a model.
* *Claim.* B ∪ A_f is consistent, and Cn(B ∪ A_f) ∩ Sent_L = Cn(Γ_f).

*Proof.*
* *Consistency.* Take the model whose ν-part is the standard ℕ and whose σ-part is any model M of Γ_f. In ℕ, Acc_f(⌜φ⌝) is true iff f accepts φ. So every member of A_f holds.
* *⊇.* If f(φ) = acc, Acc_f(⌜φ⌝) is a true Σ₁ sentence, hence Q-provable (Σ₁-completeness of Q [known; e.g. Boolos, Burgess & Jeffrey, *Computability and Logic*, the chapter on Q (unverified numbering)]). Then MP gives φ. Rejections are similar.
* *⊆.* A provable L-sentence holds in every ℕ ⊕ M with M ⊨ Γ_f, so it is a consequence of Γ_f. ∎

**Proposition 6.3 (single-sorted arithmetic over PA: inconsistent for a consistent assigner) [proved, assuming Con(PA) and the standard formalisation of computations in PA].**
* *Setting.* L = L_A, B = PA. Let f be the program:
  * on input ⌜¬Con(PA)⌝: output acc;
  * on input ⌜Con(PA)⌝: search p = 0, 1, 2, … for a PA-proof of ⊥, and output acc if one is found;
  * otherwise: loop.
* *Claim.* Γ_f = {¬Con(PA)}, and PA ∪ Γ_f is consistent. Yet PA ∪ A_f is inconsistent.

*Proof.*
* *Γ_f.* Since Con(PA) holds, the search never ends, so Γ_f = {¬Con(PA)}. PA + ¬Con(PA) is consistent by Gödel's second incompleteness theorem.
* *Deriving ¬Con(PA).* Acc_f(⌜¬Con(PA)⌝) is a true Σ₁ sentence, so PA proves it. With its schema instance, PA ∪ A_f ⊢ ¬Con(PA).
* *Deriving Con(PA).* PA ⊢ ¬Con(PA) → Acc_f(⌜Con(PA)⌝): if a proof of ⊥ exists, there is a least one, and PA proves that the search halts on it. This formalisation step is standard, and is provable already in IΣ₁. With the instance Acc_f(⌜Con(PA)⌝) → Con(PA), PA ∪ A_f ⊢ Con(PA). ∎

*Where Hänni's argument fails.* He argues: "a model of the phis alone would be a model of the added sentences also". That assumes the antecedents Acc_f(⌜φ⌝) are evaluated correctly. In a model of PA + ¬Con(PA) they are not: Acc_f(⌜Con(PA)⌝) holds there, via a nonstandard proof of ⊥, while Con(PA) fails. The argument is correct when the arithmetic is standard (Prop 6.2), or when f is sound, i.e. Γ_f is true in ℕ. Craig's construction (Thm 6.1) avoids the issue.

### 6.3 What templates do

**Proposition 6.4 (Hänni's schema contains no non-ground DT° template) [proved].**
* *Setting.* Use unary numerals S^n 0. More generally, any numeral system works if some term symbol, here +, never occurs in numerals. Let C_f be the set of all sentences Acc_f(⌜φ⌝) → φ, for φ ∈ Sent_L (single- or two-sorted).
* *Claim.* Every DT° template τ with inst(τ) ⊆ C_f is ground.
* *Consequences.* C_f is not the instance union of any finite set of DT° templates. And a finite set of DT° templates whose instances lie in C_f covers only finitely many members of C_f.

*Proof.* Let τ have a metavariable M with some occurrence at position q. Constant bodies are allowed for any type: λz̄.0 and λz̄.(0+0) for terms, λz̄.(0=0) and λz̄.¬(0=0) for formulas. By `AS:lem:setting:preservation`, the subtree of τθ at q is θ(M)[t̄], whatever the occurrence's arguments t̄. The rigid symbols of τ above q are the same in all instances.
* **Case 1: q is the root, or lies inside the antecedent.**
  * *q inside a numeral.* All members of C_f have S or 0 there. Choose θ(M) := λz̄.(0+0). Then τθ has a non-numeral at an argument position of Acc_f, so τθ ∉ C_f.
  * *q the root, or a position of Acc_f's own skeleton.* This includes the antecedent's root. All members of C_f carry the same fixed symbol there, so choose a constant body with a different root symbol. Then τθ ∉ C_f.
* **Case 2: no metavariable occurs in the antecedent.** Then the antecedent is a fixed sentence Acc_f(⌜φ_0⌝). Every instance in C_f must then equal Acc_f(⌜φ_0⌝) → φ_0, so τ has at most one instance.
  * But a template with a metavariable has infinitely many instances: there are infinitely many bodies of each type, and θ ↦ τθ is injective (`AS:thm:setting:matching`(a)).
  * So τ has no metavariable. ∎

So Hänni's own motivation for restricting to substitution schemas ("maybe we just say we have to have second-order substitution schemas of a specific kind") is borne out for his construction. Within DT°, the collapse schema costs one template per sentence, which is memorisation.

But the restriction does not block the collapse itself, at least in arithmetic, because a single ground sentence can carry it.

**Proposition 6.5 (reflection sentence: the collapse inside the template class) [proved, modulo the known partial-truth facts cited].**
* *Partial truth predicates.* For n ≥ 1 there is a Σ_n formula Tr_n(x) such that PA ⊢ φ ↔ Tr_n(⌜φ⌝) for every Σ_n sentence φ [known: partial truth definitions; Hájek & Pudlák 1993, *Metamathematics of First-Order Arithmetic*, Ch. I; Kaye 1991, *Models of Peano Arithmetic*, Ch. 9 (unverified numbering)].
* *The sentence.* For an assigner f let
  ρ_{f,n} := ∀x[(Sent_{Σn}(x) ∧ Acc_f(x)) → Tr_n(x)] ∧ ∀x[(Sent_{Σn}(x) ∧ Rej_f(x)) → ¬Tr_n(x)].
  It is a single sentence, i.e. a ground DT° template. With binary numerals for f's index, ℓ(ρ_{f,n}) ≤ a·|f| + b_n for constants a, b_n.
* *Claims.*
  * PA + ρ_{f,n} proves every Σ_n sentence that f accepts, and the negation of every Σ_n sentence that f rejects.
  * If f is Σ_n-sound (it accepts only true and rejects only false Σ_n sentences), PA + ρ_{f,n} is true in ℕ, hence consistent.

*Proof.*
* *Provability.* Let f(φ) = acc. Then PA ⊢ Acc_f(⌜φ⌝) (a true Σ₁ sentence) and PA ⊢ Sent_{Σn}(⌜φ⌝) (a true Δ₁ fact). So PA + ρ_{f,n} ⊢ Tr_n(⌜φ⌝) ⊢ φ.
* *Truth.* In ℕ, Acc_f and Rej_f hold only of actual decisions, and Tr_n is Σ_n-truth. ∎

So the template inducer (PA's templates, i.e. Q1–Q7 and T_Ind, plus one ground sentence) reproduces any Σ_n-sound assigner on Σ_n sentences. The overhead is ℓ(PA) + a|f| + b_n: a syntactic description length, linear in |f| rather than |f| + c.

For merely consistent assigners, ρ can be inconsistent with PA, as in Prop 6.3. So the template version of the collapse covers sound assigners only.

### 6.4 Time penalties

**Proposition 6.6 (membership is cheap in both collapse constructions) [proved].**
(a) With binary numerals, membership of χ in A_f is decidable in time polynomial in |χ|, without running f at all: parse χ as Acc_f(t) → φ, compute ⌜φ⌝, and compare. With unary numerals it is polynomial in |χ|, since |χ| ≥ ⌜φ⌝.
(b) Membership in A^C_f is decidable in time poly(|χ|): at most |χ| decompositions, each running f for fewer than |χ| steps.

So a Levin-Kt or speed-prior penalty on the time to *check* that a sentence is an axiom, as a function of the sentence's length, gives these sets the same polynomial time class as DT° templates. The brief's H6 claim, "A schema 'T(⌜φ⌝) = accept → φ' requires running T to check membership, so a Kt- or speed-prior-style penalty prices it by T's running time", is **[refuted]** by (a). Hänni's note already says membership "is in fact decidable"; it is in fact cheap. A penalty on the time to *generate* axioms is defeated the same way: enumerating A^C_f costs time linear in the output.


The computation of f moves either into the *proofs* (A_f: a derivation of φ must prove Acc_f(⌜φ⌝)) or into the *axiom length* (A^C_f: the axiom φ^{∧(k+1)} has length about k|φ|). Both are counted by the symbol size of derivations. The next theorem shows that no theory escapes this. Which likelihoods charge symbol size is §6.5.

**Theorem 6.7 (derivation size bounds the assigner's nondeterministic time) [proved].**
* *Setting.* Let L contain 0, S, +, · and a unary predicate R. Let X ⊆ {0,1}* be a language, and φ_w := R(ν(w)), where ν(w) is a binary numeral term for w. Let f_X accept φ_w if w ∈ X and reject it otherwise. Then Γ_{f_X} is consistent: interpret R as X.
* *Hypotheses.* Let T be any axiom set whose membership is decidable in time O(n^e), with T ∪ Γ_{f_X} consistent. Suppose that every φ_w with w ∈ X has a K-derivation from T of symbol size at most ℓ(|w|), where ℓ(m) ≥ m is time-constructible.
* *Claim.* X ∈ NTIME(ℓ(m)^c) for a constant c that depends only on e and on the proof-checking overhead of K.

*Proof.*
* *Algorithm.* On input w, guess a derivation of size ≤ ℓ(|w|) and check it. The checks are: K's axiom instances (A4 needs first-order matching, which is polynomial), MP and Gen steps, and T-membership. All are polynomial in the derivation's size, with degree at most max(e, d_K), where d_K bounds K's checks. Accept iff the derivation is valid and ends in φ_w.
* *Completeness.* If w ∈ X, such a derivation exists by hypothesis.
* *Soundness.* If w ∉ X, then ¬φ_w ∈ Γ_{f_X}. So T ⊢ φ_w would make T ∪ Γ_{f_X} inconsistent. Hence no derivation exists. ∎

**Corollary 6.8 (hard assigners force long derivations, for every theory) [proved, modulo the nondeterministic time hierarchy theorem; quantifiers corrected after the referee, m1].**
* *Uniformity.* The constant c of Theorem 6.7 depends on T only through the exponent e. For finite DT° template theories, membership is O(|T|·|χ|) (`AS:thm:setting:matching`), so e = 1 for all of them and c is one constant c_DT. (`notes.md` fixed c "as in Theorem 6.7" and then quantified over every T, although c depends on T; referee m1.)
* (a) *Template theories.* Let s(m) ≥ m be time-constructible, with s(m+1)^c = o(s(m)^{c+1}) for c = c_DT (true for every polynomial s). There is a decidable X such that every finite DT° theory T with T ∪ Γ_{f_X} consistent needs, for infinitely many m, a derivation of size > s(m) for some w ∈ X of length m.
* (b) *General axiom sets.* For each e, the same holds, with an X depending on e, for every axiom set T with membership decidable in time O(n^e).
* *Input.* The nondeterministic time hierarchy theorem (Cook 1972; Seiferas, Fischer & Meyer 1978, *JACM* 25:146–167; Žák 1983, *TCS* 26:327–333) [known (exact form unverified)]: if t₂ is time-constructible and t₁(m+1) = o(t₂(m)), then NTIME(t₂) ∖ NTIME(t₁) ≠ ∅. With t₁ := s^c and t₂ := s^{c+1} this applies, for instance, to every polynomial s. Such an X is decidable, and for fixed s it has a fixed program, so K(f_X) is a constant.
* *Proof.* Suppose that for all but finitely many m every w ∈ X of length m has a derivation of size ≤ s(m). Handle the finitely many exceptional lengths by a table. Then Theorem 6.7 with ℓ = s gives X ∈ NTIME(s^c), a contradiction. ∎
* *Remark [proof sketch].* A single X for all e exists: take X ∈ NTIME(s^{log s}) ∖ NTIME(s^{(log s)/2}) (when these bounds are time-constructible and meet the gap condition); every s^c is eventually below s^{(log s)/2}.

**Upper bound for the collapse constructions [proof sketch].**
* *A^C_f.* Each derivation of φ is "cite φ^{∧(k+1)}, then ∧-elimination", of size poly(k|φ|) with k = time_f(φ).
* *A_f (two-sorted).* A derivation is a Q-proof of the true Σ₁ sentence Acc_f(⌜φ⌝), then MP. A Q-proof of a true Σ₁ sentence of this kind has size polynomial in the length of the computation [known (unverified); see Pudlák 1998, "The lengths of proofs", *Handbook of Proof Theory*].
* *Template version (Prop 6.5).* The same, plus the Tarski biconditional for φ.

### 6.5 What the derivation likelihoods charge

**Proposition 6.9 [refuted].** `notes.md` claimed, as a proof sketch: "Under L1 with subcritical parameters, −ln P_T(φ) ≥ κ·ℓ_min(φ) − ln(C/Z_T) for constants κ, C > 0 that depend on the grammar. Here ℓ_min(φ) is the least size of a derivation of φ from T." With ℓ_min the least *symbol* size, this is false (referee M2).
* *Counterexample [proved; computed: `referee_code/r2_l1_size.out`, `c12_l1_size.out`, Part A].* Start from the logical axiom ∀x(x = x). Repeat k times: ∀E with t = p+p, then Gen on p. Close with one ∀E. Each round makes O(1) grammar choices, but the substituted term doubles the number of occurrences of the variable. The conclusion φ_k has symbol size exactly 2^{k+3} − 1 (checked by both scripts, independently implemented, to k = 14 and k = 12). The tree has ν = 7 + 8k grammar nodes (c12) and −ln Pr(tree) ≤ 12.8 + 12.2k nats (r2's grammar). Every derivation of φ_k contains φ_k, so ℓ_min(φ_k) ≥ 2^{k+3} − 1, while −ln P_T(φ_k) ≤ −ln Pr(tree) grows only linearly in k. For every κ > 0 and C the claimed inequality fails for large k.
* *A one-node example.* An A4 instance ∀x B(x) → B(t), with m occurrences of x and |t| ≈ m, has size ≈ m² but costs O(m) nats.
* *Where the sketch went wrong.* It bounded P_T(φ) by the tail of the tree's "total size", but L1's probability counts grammar choices, not symbols. ∀E and Gen substitute into every occurrence of a variable.
* *Consequence.* Theorem 6.7 and Corollary 6.8 bound symbol size. They transfer to Hänni's graded score and to L1^σ (Prop 6.14), but not to plain L1. What plain L1 does charge is Prop 6.11 and Cor 6.13 below.

**Lemma 6.10 (symbol size is at most exponential in the number of grammar choices) [proved; computed].** Let π be a valid L1 tree from a finite theory T, with ν grammar nodes (derivation nodes, Q nodes and parameter-chain nodes). Let a_T ≥ 2 bound the sizes of the templates of T and of K's logical templates, and c_T := 2a_T². Then every conclusion in π has symbol size at most (c_T + 1)·ν²·e^{ν/e}.

*Proof.* For a node v let G(v) be the number of Gen nodes in its subtree and Π(v) := Π_u |t_u|, over the ∀E nodes u in its subtree, with t_u the substituted term. We show |concl(v)| ≤ (c_Tν² + G(v))·Π(v), by induction on the tree.
* *Citation leaf, DT° template* (of T, or A1–A3, A5, equality; substitution θ). Each metavariable occurrence M(t̄) of τ becomes θ(M)[t̄/z̄]. The body θ(M) has at most ν nodes and each argument t_i has size ≤ a_T, so this piece has size ≤ νa_T. There are at most a_T occurrences and at most a_T rigid symbols. So |τθ| ≤ a_T + a_T²ν ≤ c_Tν.
* *Citation leaf, A4* (∀xB → B[t/x], which is not a template, Lemma 1.2). B and t have at most ν nodes each, so the size is at most 1 + (|B| + 1) + |B|·|t| ≤ 3ν² ≤ c_Tν². This is the referee's one-node example: size quadratic in ν.
* *∀E with term t.* The conclusion ψ[t/x] replaces each occurrence of the bound variable by t, which has no bound indices, so no shifting is needed: |ψ[t/x]| ≤ |ψ|·|t| ≤ |premise|·|t|.
* *Gen.* Replacing a parameter by an index keeps the size; the new ∀ adds 1. And Π(v) ≥ 1.
* *MP.* The conclusion is a proper subformula of the major premise.

Finally G(v) ≤ ν, and the terms of the ∀E nodes are disjoint sets of grammar nodes, so Σ_u |t_u| ≤ ν. By the AM–GM inequality, Π_u |t_u| ≤ (ν/k)^k for k terms, and max_{k>0}(ν/k)^k = e^{ν/e}. ∎

**[computed: `c12_l1_size.out`, Parts A and B]** The checks use chains without A4 citations, for which the proof gives the stronger bound (c_T + 1)·ν·e^{ν/e}; that is what c12 tests. The referee's family satisfies it, with ln(size)/ν → ln 2/8 ≈ 0.087 against the allowed 1/e ≈ 0.368. On 9865 conclusions of 3000 random valid ∀E/Gen chains, the inductive bound and the final bound were never violated; the largest ln(size)/ν was 0.220. So symbol size can be exponential in ν, and no more.

**Proposition 6.11 (L1 charges its own code length exponentially) [proved].** Assume L1 with m < 1, Q uniformly subcritical (Def 1.5), a finite theory T, and a geometric parameter law. Let ν_min(φ) be the least number of grammar nodes of a valid tree with conclusion φ. There are constants θ, C > 0, depending on the grammar and on T, with
  P_T(φ) ≤ C·e^{−θ·ν_min(φ)} / Z_T   for every φ.

*Proof.* The whole tree (derivation nodes, Q nodes, parameter-chain nodes) is a multi-type branching process with finitely many children per node. It satisfies the uniform condition of Lemma 1.6(d): give derivation nodes weight 1, Q nodes weight η·h_Q (h_Q from Def 1.5) and chain nodes weight η. A derivation node has expected weighted offspring at most m + η·(v_T·h_Q,max + 1), where v_T bounds the number of metavariables of a template of T or of K; this is < 1 for small η. Q nodes satisfy the condition with ρ_Q, and a chain node continues with probability g < 1. So ρ := max(m + η(v_T h_Q,max + 1), ρ_Q, g) < 1. Lemma 1.6(b) gives E[e^{θν}] ≤ C for some θ > 0. Hence P_T(φ) = μ_T(φ)/Z_T ≤ Pr[ν ≥ ν_min(φ)]/Z_T ≤ C e^{−θν_min(φ)}/Z_T. ∎

**[computed: `c12_l1_size.out`, Part C]** For a joint process with m = 0.55 and the grammar of c10, the empirical tail of ν decays exponentially (about 0.025 nats per node between ν = 100 and 200; mean ν = 26.9).

**Theorem 6.12 (code length bounds the assigner's nondeterministic time, logarithmically) [proved].** In the setting of Theorem 6.7, let T be a finite set of DT° templates with T ∪ Γ_{f_X} consistent, and suppose that every φ_w, w ∈ X, has a valid L1 tree from T with ν ≤ ℓ(|w|) grammar nodes, ℓ(m) ≥ m time-constructible. Then X ∈ NTIME(2^{(d+1)·ℓ(m)}), where d is the fixed polynomial degree of the syntactic operations used in checking (substitution, comparison); d does not depend on T or ℓ.

*Proof.* On input w, guess a tree with at most ℓ := ℓ(|w|) grammar nodes. Each node is a choice from a finite list, or one of at most ℓ + O(1) variables, so the guess has O(ℓ log ℓ) bits. Compute every node's conclusion explicitly, check validity (MP needs equality of formulas; ∀E needs a root ∀) and compare the root's conclusion with φ_w. By Lemma 6.10 every formula has size at most (c_T + 1)ℓ²e^{ℓ/e}, and all the operations are polynomial, of a fixed degree d, in that size. So the time is at most ℓ·((c_T + 1)ℓ²e^{ℓ/e})^d ≤ 2^{(d+1)ℓ} for ℓ ≥ ℓ_0(T), since e^{d/e} < 2^{d}; smaller inputs go in a table. Soundness and completeness are as in Theorem 6.7: citations name a template of T, so no membership test is needed, and a valid tree is a K-derivation from inst(T). ∎

**Corollary 6.13 (hard assigners make plain L1 pay, logarithmically in their time) [proved, modulo the hierarchy theorem].** Let s(m) ≥ m be time-constructible with s(m)² − (d+1)s(m+1) → ∞ (true for every polynomial s, and for s(m) = 2^m). There is a decidable X such that, for every finite DT° theory T with T ∪ Γ_{f_X} consistent, for infinitely many m some w ∈ X of length m has ν_min(φ_w) > s(m). On those data, −ln P_T(φ_w) ≥ θ·s(m) − ln(C/Z_T) (Prop 6.11).

*Proof.* By the hierarchy theorem with t₁ := 2^{(d+1)s} and t₂ := 2^{s²}, there is X ∈ NTIME(2^{s²}) ∖ NTIME(2^{(d+1)s}); it is decidable. If, for all but finitely many m, every w ∈ X of length m had ν_min(φ_w) ≤ s(m), Theorem 6.12 with ℓ = s (and a table) would put X in NTIME(2^{(d+1)s}). ∎

In words: if an assigner's language needs nondeterministic time t(m), plain L1 is only guaranteed to charge about log t(m) nats per hard datum, against a polynomial root of t(m) for symbol-size penalties (next proposition).

**Proposition 6.14 (symbol-size penalties charge polynomially) [proved, given Theorem 6.7].**
(a) *L1^σ.* For every φ, P^σ_T(φ) ≤ e^{−κ·ℓ^σ_min(φ)}·Z_T/Z^σ_T, where ℓ^σ_min(φ) is the least total symbol size of a valid L1 tree with conclusion φ.
(b) *Translation.* A valid L1 tree of total symbol size ℓ yields a K-derivation of symbol size ≤ 4ℓ (each ∀E node becomes an A4 instance and an MP step). So with X from Corollary 6.8(a), for every finite DT° theory T consistent with Γ_{f_X}, infinitely often −ln P^σ_T(φ_w) ≥ κ·s(m)/4 − ln(Z_T/Z^σ_T).
(c) *Hänni's graded score* with g(ℓ) = 2^{−κℓ} on explicit derivations (Remark 1.10) charges at least κ·s(m) bits on the same data, before normalisation, and at least κ·s(m) + log₂ Z_T after it.

*Proof.* (a) μ^σ_T(φ) = Σ_{π→φ} Pr(π)e^{−κ|π|} ≤ e^{−κℓ^σ_min(φ)}·Σ_π Pr(π) ≤ e^{−κℓ^σ_min(φ)}Z_T. (b) Keep every node's conclusion (total ℓ) and add, for each ∀E node v with premise u, the A4 instance concl(u) → concl(v), of size |concl(u)| + |concl(v)| + 1. Each node is the premise of at most one node, and there are at most ℓ nodes, so the additions total at most 3ℓ. Then Corollary 6.8(a). (c) Remark 1.10 measures explicit derivations in bits, which is at least their symbol count; then Corollary 6.8. ∎

**Conjecture 6.15 (plain L1 charges polynomially too).** Theorem 6.12 holds with NTIME(ℓ^c), for some constant c, in place of NTIME(2^{(d+1)ℓ}). Route: check L1 trees on shared representations (formula DAGs, or compressed terms), without writing formulas out. Equality of compressed first-order terms is decidable in polynomial time [known (unverified): Plandowski for strings; Busatto, Lohrey & Maneth, and Schmidt-Schauß, for tree grammars]. What is not done: handling de Bruijn indices and Gen under sharing (an abstracted parameter becomes an index whose value depends on the binder depth at each occurrence).

**What the time penalty does: the precise statement.**
1. **Membership- and generation-time penalties do not block the collapse.** Theorem 6.1 with Craig's sets and Prop 6.6: they change Hänni's equivalence by an additive constant at most.
2. **The template restriction blocks Hänni's schema (Prop 6.4) but not the collapse.** In arithmetic, one ground reflection sentence over PA gives every Σ_n-sound assigner, with linear overhead (Prop 6.5).
3. **A derivation-size penalty does separate the inducers.**
   * Any axiom set with polynomial-time membership, template or not, needs derivations whose *symbol size* is, infinitely often, at least the nondeterministic time of the assigner's language, up to a polynomial (Theorem 6.7, Cor 6.8).
   * Penalties on symbol size charge that per datum: L1^σ at least κs(m)/4 nats, Hänni's graded score at least κs(m) bits (Prop 6.14).
   * Plain L1 charges only its code length, which can be logarithmic in symbol size (Prop 6.9 refuted). Proved: at least θs(m) nats when the assigner's language lies outside NTIME(2^{(d+1)s(m)}) (Cor 6.13), i.e. logarithmically in the assigner's time. Polynomially: Conjecture 6.15.
   * The collapse constructions pay at most a polynomial of the assigner's deterministic running time in symbol size (upper bound above).
   * Function induction's cumulative log loss on f_X's labels is at most |f_X| bits, a constant, because W_FI(D_n) ≥ 2^{−|f_X|}.

So the clean theorem is the negative half. No membership-time penalty blocks the collapse, while a symbol-size derivation penalty prices it per datum, between nondeterministic and deterministic time. For the user's derivation-length prior this means: measure derivation length in written symbols (L1^σ), or prove Conjecture 6.15; the grammar's own code length is a weaker measure. I found no clean equivalence for the derivation-penalised inducer. Its exact relation to a time-bounded function inducer (Hänni's polytime Solomonoff, `../../prior/hanni-polytime-solomonoff.md`) is open (§10).

---

## 7. The trichotomy: true, false, independent

**Definitions.** Fix a posterior π_D on a countable class of theories, and write ⊢ for derivability, bounded or not. Then:
* Bel(s) := π_D(T ⊢ s);
* Dis(s) := π_D(T ⊢ ¬s);
* Ind(s) := π_D(T ⊬ s and T ⊬ ¬s);
* Inc := π_D(T inconsistent);
* Pl(s) := 1 − Dis(s).

**Proposition 7.1 (basic laws) [proved].**
(a) Bel(s) + Dis(s) + Ind(s) = 1 + Inc. In particular the three sum to 1 when the posterior is on consistent theories. Assume this from now on.
(b) Dis(s) = Bel(¬s). Bel(⊤) = 1 and Bel(⊥) = 0. Pl(s) = Bel(s) + Ind(s).
(c) If s ⊢ s', then Bel(s) ≤ Bel(s').
(d) If ⊢ ¬(s ∧ s'), then Bel(s ∨ s') ≥ Bel(s) + Bel(s'): Bel is superadditive on incompatible sentences.

*Proof.*
* (a) An inconsistent T is counted in both Bel and Dis.
* (b) Classically T ⊢ ¬¬s iff T ⊢ s.
* (c) Closure of Th(T) under consequence.
* (d) A consistent T proves at most one of two incompatible sentences, and proves s ∨ s' if it proves either. ∎

**Proposition 7.2 (Bel is a belief function) [proved; framework known: Shafer 1976, *A Mathematical Theory of Evidence*].**
* *Claim.* For all sentences s_1, …, s_k:
  Bel(s_1 ∨ ⋯ ∨ s_k) ≥ Σ_{∅≠I⊆[k]} (−1)^{|I|+1} Bel(∧_{i∈I} s_i).
  So Bel is a totally monotone capacity on the Lindenbaum algebra, with "focal elements" Mod(T), and Pl is its plausibility.

*Proof.* For one consistent T, write u(s) := 1[T ⊢ s]. Then u(∧_I s_i) = Π_{i∈I} u(s_i). So the right side equals 1 − Π_i(1 − u(s_i)) = 1[T proves some s_i] ≤ u(∨s_i). Mixtures preserve the inequality. ∎

**Proposition 7.3 (coherent bracketing) [proved].** There is a probability P on complete consistent theories (equivalently, a finitely additive probability on sentences) with Bel(s) ≤ P(s) ≤ Pl(s) for all s.

*Proof.* For each T in the posterior's support choose a completion c(T) (Lindenbaum), and put P(s) := Σ_T π_D(T)·1[s ∈ c(T)]. Then 1[T ⊢ s] ≤ 1[s ∈ c(T)] ≤ 1 − 1[T ⊢ ¬s]. ∎

**Example 7.4 (renormalising is incoherent) [proved; computed].**
* *Rule.* Hänni's first option: drop the independent fraction and renormalise per sentence, R(s) := Bel(s)/(Bel(s) + Dis(s)).
* *Posterior.* Atoms a, b; theories T_1 = {a}, T_2 = {b}, T_3 = {¬(a∧b)}; each with posterior ⅓.
* *Values.* Bel(a) = ⅓ and Dis(a) = 0, so R(a) = 1. Likewise R(b) = 1. But Bel(a∧b) = 0 and Dis(a∧b) = ⅓, so R(a∧b) = 0.
* *Incoherent.* No probability has P(a) = P(b) = 1 and P(a∧b) = 0.

**Example 7.5 (the 50/50 rule is incoherent) [proved; computed].**
* *Rule.* Hänni's second option: H(s) := Bel(s) + ½Ind(s).
* *Posterior.* Already the single empty theory (pure logic) over atoms b, c.
* *Values.* H(b) = H(b∧c) = H(b∧¬c) = ½.
* *Incoherent.* Coherence would need P(b∧c) + P(b∧¬c) = P(b).

**Proposition 7.6 (exactly when the 50/50 rule is coherent; new, referee m4) [proved; computed].** Over finitely many propositional atoms, identify a consistent theory with its nonempty set of models Mod(T), and call an assignment g on sentences coherent if some probability P on valuations has P(s) = g(s) for every sentence s. Then H = Bel + ½Ind is coherent iff every theory with positive posterior mass has at most two models.

*Proof.*
* *If.* For one theory, H_T(s) = 1[Mod(T) ⊆ s] + ½·1[Mod(T) meets s and its complement]. If |Mod(T)| = 1 this is the point mass on the model. If Mod(T) = {v, v′}, it is ½(δ_v + δ_{v′}): the value is 1, ½ or 0 according as s contains both, one or none of v, v′. H = Σ_T π(T)H_T is then a mixture of probabilities.
* *Only if.* For distinct valuations v, v′ put D_T := H_T({v, v′}) − H_T({v}) − H_T({v′}). If v, v′ ∈ Mod(T) and |Mod(T)| ≥ 3, then D_T = ½ − ½ − ½ = −½. In every other case D_T ≤ 0: if both are models and Mod(T) = {v, v′}, D_T = 1 − ½ − ½ = 0; if exactly one is a model, D_T = H_T({v}) − H_T({v}) = 0 whatever |Mod(T)|; if neither, 0. So if some T with π(T) > 0 has three or more models, pick two of them: D = Σ_T π(T)D_T ≤ −½π(T) < 0. A probability has D = 0. ∎

**[computed: `c5_trichotomy.out`, `c14_fiftyfifty.out`; `referee_code/r5_trichotomy.out`]**
* *Examples 7.4 and 7.5.* Linear programming confirms that both are incoherent.
* *Props 7.2 and 7.3.* No violation of 2-, 3- or 4-monotonicity and no bracketing failure, in 300 random posteriors on 3 atoms (c5) and in the referee's independent trials (exhaustive on 2 atoms).
* *Prop 7.6.* The criterion agrees with LP coherence in all 3225 posteriors on 2 atoms (every 1- and 2-theory support, plus 3000 random) and all 600 random posteriors on 3 atoms.
* *Frequencies.* Renormalisation was incoherent in 90 of 300 trials in c5. `notes.md` added "the coherent cases are essentially those where every theory is complete". That remark is **[refuted]** (referee m4): in the referee's trials renormalisation was coherent in 199 of 300 and only 2 of those had all theories complete; in c14 it was coherent in 1761 cases on 2 atoms (218 with all theories complete) and 306 on 3 atoms (42). For the 50/50 rule the exact condition is Prop 7.6.

**Answers to Hänni's questions in his note.**
* "i guess you could also naturally just get true/false by … removing the independent fraction and renormalizing". This is incoherent in general (Example 7.4), confirming his "i guess we probably usually don't get coherent probabilities either".
* "instead of renormalizing, you could also turn the independent fraction into 50/50 … not giving coherent probabilities usually". Confirmed (Example 7.5). It fails already with one theory, and it is coherent exactly when no theory has more than two models (Prop 7.6).
* "maybe this motivates not removing the independent fraction?". Yes.
  * The pair (Bel, Pl) is a coherent lower/upper probability (Props 7.2 and 7.3).
  * It is the exact analogue of a semimeasure: mass on "undecided" is kept, not redistributed.
  * It is also the convention under which Theorem 6.1 holds with a constant.
  * A coherent point value needs an extra ingredient: a distribution over completions of each theory. The trichotomy does not supply one.

**How the likelihood shapes Ind.**
* Under Hänni's 0/1 scores, stronger consistent theories keep their prior odds (Prop 1.9(b)). So Bel of a sentence ψ that is independent of the data stays at its prior level forever.
* Under L0 and L1, a theory that proves *and generates* ψ, when ψ never appears, loses posterior mass: polynomially with Dirichlet weights (Prop 5.5), exponentially with fixed weights. So Ind(ψ) grows.
* So with a generative likelihood, "the data never mention ψ" is evidence against theories that would have mentioned it. With 0/1 scores it is no evidence at all.

---

## 8. Predictive versus deductive

This is the general statement; track universal does the case of ∀xφ.

**Theorem 8.1 [proved, from §2].** Assume setting W.
(a) **Predictions merge, whatever the deductive questions.** The predictive law M_n satisfies Σ_n E KL(P_{T*} ‖ M_n) ≤ ln(1/π(C*)) (Prop 2.4(b)).
(b) **Deductive beliefs converge to the generator class's prior-weighted vote.** π_n(T ⊢ s) → π(C* ∩ {T ⊢ s})/π(C*) (Corollary 2.3). This equals 1[T* ⊢ s] iff C*'s members agree on s up to prior-null sets.
  * They agree when the generator determines the theorem set (L0 with full support, L1 with parameters admissible).
  * They need not agree under L2, under generators that reveal only part of the theory, or under any generator whose support is smaller than Th(T).
(c) **Finite n.** Let T_1 ⊢ s, T_2 ⊬ s, and data from P_{T_1}.
  * The expected posterior log-odds of T_1 against T_2 grow by exactly KL(P_{T_1} ‖ P_{T_2}) per datum.
  * The two generators are within total variation (KL/2)^{1/2} (Pinsker), so their per-datum predictions differ by at most that much.
  * So when two theories differ in what they prove but hardly in what they generate, the predictive question "what will the next datum look like" is nearly settled after a few data, while the deductive question stays near its prior odds for about 1/KL data.

*Proof.* (a) and (b) are restated. (c): E ln[P_{T_1}(X)/P_{T_2}(X)] = KL, summed over the data; Pinsker's inequality. ∎

**Under misspecification** (finite class, Theorem 3.1):
* Predictions converge to the KL-projection.
* Deductive beliefs converge to the projection's theorems, which can be weaker than the human's (Example 3.2) or unsound (Examples 3.4, 3.6).
* Predictions still compete with every member of the class: M(X^n) ≥ π(T)P_T(X^n) gives cumulative log loss at most that of any T plus ln(1/π(T)), on every sequence. But predictive success then certifies nothing deductive: the best predictor in the class can be a weaker or an unsound theory.

**Relation to the user's ∀xφ case** (stated generally, details in track universal):
* "All future data are φ-instances" is a predictive statement, settled by (a).
* "The axioms prove ∀xφ" is a deductive statement, settled by (b) only as far as the generator class agrees.
* Under L0 with closed instances, the generator class is "the instance schema", which does not prove ∀xφ (Example 3.2).
* The analogous fact for Solomonoff's universal prior and universal hypotheses is Hutter (2007, "On universal prediction and Bayesian confirmation", *TCS* 384(1):33–48) [known; bibliographic data and abstract checked by the referee and by track universal; full text unverified]: the universal prior confirms "all future observations are black" in the predictive sense.

**Proposition 8.2 (data that come with their proofs; new, referee Q5) [proved].**
* *Setting.* Each datum is a whole valid L1 tree drawn from P_T(· | valid), written out: every node's rule and conclusion, and for each citation leaf whether it cites a theory axiom or a logical axiom, but not which template. (A human proof says "by an axiom" without naming the schema it is an instance of; if the name is recorded, the argument is easier.) Weights are fixed.
* *(a) Likelihood.* P_T(π) = Π_{theory-citation leaves v of π} P^{L0}_T(concl(v)) · G(π)/Z_T, where P^{L0}_T := Σ_τ w_τ Q_τ is T's citation law and G(π) collects factors that do not depend on T (rule choices, α_ax per theory leaf, logical citations, ∀E terms, Gen parameters). Z_T depends on T only through P^{L0}_T.
* *(b) Generator class.* P_T = P_{T′} on trees iff P^{L0}_T = P^{L0}_{T′}. So by Theorem 2.1 the posterior concentrates on the L0 generator class of T*, whose members all have ∪inst(T) = ∪inst(T*) (Prop 2.6(a)). Inside it the posterior equals the prior (Corollary 2.2), so splits still tie.
* *(c) Comparison.* Conclusions alone identify Th(T*) (L1, §2.1). Proofs identify ∪inst(T*), which is finer: T1 = {a, b} and T2 = {a, a → b} of Prop 2.5 have the same theorems and different instance unions.

*Proof.* (a) A tree's probability is the product of its nodes' probabilities. A theory-citation leaf whose template is not recorded contributes α_ax·Σ_τ w_τ Q_τ(concl(v)) = α_ax P^{L0}_T(concl(v)), the sum over the unrecorded choices factorising over leaves. No other node depends on T. Validity depends only on conclusions, so Z_T = Pr[valid] is a function of the law of theory-leaf conclusions, i.e. of P^{L0}_T. (b) "If" is (a). "Only if": a one-node tree citing s has probability α_ax P^{L0}_T(s)/Z_T; equality for all s makes P^{L0}_T and P^{L0}_{T′} proportional, and both sum to 1. ∎

**Remark 8.3 (near misses; referee Q6) [the transfer is proved; nothing is computed].** Hänni's "grade near misses" can be modelled by a corruption channel K(s′ | s) that favours s′ close to s in some metric on sentences or values: P^K_T(s′) := Σ_s P_T(s)K(s′ | s). Each P^K_T is a fixed probability on S with a data-independent normaliser. Theorem 2.1, Corollary 2.3, Theorem 4.1 (with C*_d defined through P^K) and the size principle use nothing else, so they hold verbatim when the channel is part of the well-specified model. The generator class {T : P^K_T = P^K_{T*}} can be larger than without the channel, since K need not be injective. How large, for natural metrics, is not studied here. Track universal (Prop U2n) studies the related noise mixture (1 − η)P_T + ηN.

---
## 9. Answers, and relations to Hänni's note

### 9.1 The brief's hypotheses

| hypothesis | verdict | where |
|---|---|---|
| **H1** model (templates, prior, derivation grammar, size principle from data-independent normalisation) | adopted and made precise. Q needs a uniform weighted subcriticality condition (revised). L1 is proper iff m ≤ 1 (given a citation option). Hänni's scores lack the size principle; his graded score, normalised, is a two-part code that charges written derivation length, like L1^σ and unlike L1 | §1, Def 1.5, Lemmas 1.6, 1.7, Prop 1.9, Rem 1.10 |
| **H2** concentration on {P_T = P_{T*}}; identification of the generator; misspecification goes to the KL-minimiser | confirmed for fixed weights (Doob, direct proof; inside the class the posterior equals the prior). Dirichlet weights: instance union identified for a.e. w*; the exact class has mass 0. Splits are exact ties at matched weights and differ only by Occam terms with learned weights, under L0 and L1. KL-minimiser: proved for finite classes; can fail to describe the full class | Thm 2.1, Cor 2.2, Props 2.5, 2.6, Thm 5.1, Props 5.4, 5.6, Thm 3.1, Rem 3.5 |
| **H3** thresholded verifier sound w.p. ≥ 1 − δ/π(T*) against adaptive provers; δ → 0 is the cautious verifier | confirmed for fixed weights, with exact hypotheses (well-specified data law, proper n-independent prior); the constant improves to π(C*_d) and is tight. For Dirichlet weights: vacuous as stated, false at fixed w* with a constant threshold, true on average over w* or with a threshold shrinking like n^{−(\|T*\|−1)/2}. Misspecified counterexample with acceptance probability 1. The δ → 0 limit is the theorem-level version-space verifier | Thm 4.1, Rem 4.5, Lemma 4.6, Thms 4.7, 4.8, Ex 4.9, Props 4.2, 4.3 |
| **H5** stochastic positive data plus size principle get around Gold; spare slots cost about ½ log n bits | confirmed. Identification of the instance or theorem set with probability 1, with no bound. Gold still applies on a null set of texts. Disjoint spare: exactly ≈ n^{−α} (½ log₂ n bits at α = ½). Overlapping and outside: ≈ n^{−α}. Redundant: ≈ n^{−α/2}. In the span: a constant, and possibly a slow gain | Thm 5.1, Prop 5.2, Prop 5.5 |
| **H6** a time penalty on membership prices the collapse schema | **refuted**: membership is polynomial without running T. What prices the assigner is derivation length measured in symbols (Thm 6.7); plain L1's code length prices it only logarithmically, as far as proved (Cor 6.13) | Prop 6.6, Thm 6.7, Props 6.9 (refuted), 6.14, Cor 6.13 |

### 9.2 The user's question, at the level of this track

* **"Once we see all these other statements, we should up the probability on ∀xφ."**
  * Under a generative likelihood with the size principle, data move mass away from memorisation and from over-general templates, exponentially with fixed weights (Lemma 1.8, §5.2).
  * Between theories that generate nearly the same data but prove different things, the data move mass only at rate KL per datum (Thm 8.1(c)), and in the limit only as far as the generator class disagrees (Corollary 2.3).
  * Whether ∀xφ itself gains is track universal's question. Example 3.2 shows that under L0 with closed instances it does not.
* **"Not just any enumerable axioms, but ones with templates."**
  * Templates make matching linear and block Hänni's collapse *schema* (Prop 6.4).
  * They do not make the posterior see schema boundaries: splits are exact ties at matched weights (Prop 2.6(b)), decided by Occam terms or by usage statistics with learned weights (Props 5.4, 5.6).
  * In arithmetic they do not block the collapse at the level of theorems (Prop 6.5).
* **"A derivation length prior."**
  * L1 is that prior, normalised over grammar choices; normalisation supplies the size principle.
  * Its code length can be exponentially shorter than the written derivation (Prop 6.9, refuted). To price computation, measure derivation length in written symbols (L1^σ, or Hänni's graded score normalised): then hard assigners cost a polynomial root of their nondeterministic time per datum (Prop 6.14). With plain L1 only a logarithmic charge is proved (Cor 6.13).
* **"A time complexity penalty for generating or checking axioms."** It does not bite: the collapse constructions have polynomial membership (Prop 6.6).
* **"Robustly picks up the axioms we actually have, or something equivalent in theorems, or at least a lot of posterior mass."**
  * *Well specified.* The theorem set is identified (L1), or the instance set (L0; with Dirichlet weights for a.e. weight vector). The axiom set is identified up to its generator class, in which the posterior is the prior (Corollary 2.2). So the actual axioms get asymptotic mass π(T*)/π(C*) under fixed weights. With Dirichlet weights and a well-specified Q, their splits lose like n^{−(K−1)/2} under L0 (Prop 5.4(c)); under L1 the split never gains more than ln(1/η) nats (Prop 5.6(b)) and the rate is a conjecture.
  * *If the data come with proofs,* the instance union of the axioms is identified, not just the theorems (Prop 8.2).
  * *Robustly: no.* If human usage differs from Q, splits win linearly (Props 5.4(d), 5.6(c)). If humans state derived theorems that the model does not generate, the posterior goes to the best generator, which can be weaker (Example 3.2) or unsound (Example 3.4); under a derivation likelihood the unsound escape still wins in the computed equational model unless Q makes the data's terms expensive (Example 3.6). And the soundness guarantee is lost (Prop 4.2).

### 9.3 Hänni's note, point by point

* **Two variants.** As scores they are monotone in the theory's strength (Prop 1.9(b)), so they never penalise a consistent strengthening. "Posterior weight depend[ing] … on how many of the given statements can be proven" plus "penalize longer proofs", divided by its T-dependent normaliser and with g(∞) = 0, is a normalised two-part code that charges written derivation length, like L1^σ (Remark 1.10).
* **Trichotomy.** It is a belief/plausibility pair. Both point estimates he considers are incoherent in general; the 50/50 rule is coherent exactly when no theory has more than two models (Prop 7.6); keeping the triple is coherent (§7).
* **Equivalence.** True, with the constant he expects, in the semimeasure convention and via Craig's trick. Via his schema it holds in a two-sorted reading, and fails for some consistent assigners over PA in a single sort (Thm 6.1, Props 6.2, 6.3). His "easy" separation of unrestricted function induction from axiom induction is Prop 6.0.
* **His conclusion, and the restriction to substitution schemas.** The restriction blocks his schema (Prop 6.4). It does not block a reflection sentence (Prop 6.5). A time penalty must sit on derivations measured in symbols, not on axiom checking (§6.4, §6.5).
* **"Other ideas for how to fix axiom induction".**
  * *"generate only a very small subset of observations"*: this is what a generative likelihood with data-independent normaliser does. The theory need not produce its theorems with appreciable probability, and normalisation charges it for what it does produce.
  * *"allow some mistakes"*: a noise mixture P = (1−η)P_T + ηN. Theorem 4.1 still holds if the noise model is part of the well-specified generator. Systematic mistakes are misspecification (§3; `inferential-learning/research/theory/T1-…` §6; universal Prop U2n).
  * *"grade near misses"*: a corruption channel; the general results transfer, the size of the generator class is open (Remark 8.3).
* **Polytime Solomonoff note.** The derivation-bounded L2 inducer with a growing depth budget is the analogue of his time-capped mixture. A constant-regret theorem against theories whose data have derivations within the budget plausibly follows by his argument [conjecture; not written out].

---

## 10. Open problems

1. **Spares at every w*.** Is Theorem 5.1(b) true for every interior w* (Theorem 5.1(c))? This needs control of the sum over all spare templates, not just one (Prop 5.5).
2. **Rigorous spare rates.** Make Prop 5.5(b), (c), (d2) rigorous: boundary Laplace asymptotics for a mixture with known components and a weight at the boundary, and the interior case with a reparametrised family.
3. **The full class under misspecification.** For the human law of Example 3.4, does the posterior mass of unsound theories tend to 1 (Remark 3.5)? More generally, which conditions of Kleijn–van der Vaart type hold for template classes with memorisation in them?
4. **Robustness under derivation likelihoods.** Conjecture 3.7: the per-+ derivation cost in L1-eq and the boundary between the two regimes of Example 3.6. And the same question in the calculus K, untruncated, and for the full class.
5. **The Occam rate under L1.** Prop 5.6(d): identifiability of the root law from L1 data, a nonsingular Fisher information, and the −(K−1)/2·ln n rate.
6. **Competitors only L1 keeps alive.** A general comparison of a schema with its partial splits that derive the rest (pa §2), under well-specified and misspecified usage.
7. **The general L1 identification statement.** Is P_{T1} ≠ P_{T2} under L1 for all grammar parameters in Prop 2.5? A route: P_T(s) is a power series in the rule probabilities with nonnegative coefficients, so the difference is real-analytic on the subcritical region, and nonzero near α_r = 0. Analyticity in a neighbourhood of every point is not checked.
8. **Identification of single templates.** Does Q_τ = Q_{τ'} (or inst(τ) = inst(τ')) imply τ ≡ τ' in DT°, or in FO with formula metavariables? This is open in `AS` as well.
9. **Lemma 1.2(b).** Write out the full proof.
10. **Theorem-level caution.** Is the inclusion V_{0,d} ⊇ Th_d(Acc_k(D)) ever strict for **H**_k(DT°) (Prop 4.3(d))?
11. **Completeness with a shrinking threshold.** Does Prop 4.4 hold for the verifier of Theorem 4.8, whose threshold falls like n^{−(K−1)/2}?
12. **Plain L1 and computation.** Conjecture 6.15 (polynomial checking of L1 trees on shared representations).
13. **The derivation-penalised inducer.** Is axiom induction with a symbol-size derivation penalty equivalent, up to polynomial factors, to function induction over consistent assigners with short certificates (an NP-like class), in the way Theorem 6.1 is exact without penalties? Theorem 6.7 is the lower half. The upper half for Hänni's and Craig's constructions is deterministic time, not nondeterministic.
14. **Single-sorted repair.** Is there a single-sorted repair of Hänni's schema for consistent but unsound assigners, short of Craig's trick? Prop 6.5 covers Σ_n-sound assigners only.
15. **Craig sets in DT°.** For which assigners f is A^C_f, or some set with the same consequences and polynomial membership, a finite union of DT° templates?
16. **Two-part versus Bayesian limits.** Can the maximum approximation change *deductive* limits, not only ties inside the generator class (Prop 2.8)?
17. **Near misses.** How large is the generator class under natural corruption channels (Remark 8.3)?
18. **Robust versions.** Tempered or SafeBayes posteriors, explicit noise models, and what each does to Theorem 4.1 under misspecification.

---

## 11. Cross-track consistency

I read the current notes of the other tracks: `../universal/notes-final.md`, `../pa/notes-final.md` and `../experiments/notes.md` (experiments had no `notes-final.md` when I read it). Universal and experiments cite `notes.md` of this track. Pa was revised in parallel and its final notes already cite this file (Thms 4.7–4.8, Prop 2.7, Lemma 1.7(c), L1^σ, §6.5). I kept the numbering of every result of `notes.md`, so the citations to it still point to the same statements, with the exceptions listed in §11.3.

### 11.1 Aligned in this revision

| item | this track now | was (`notes.md`) | matches |
|---|---|---|---|
| subcriticality of Q | uniform weighted condition (Def 1.5) | per-type mean < 1 | experiments §1.2 argues the block-triangular special case; its grammar satisfies Def 1.5 |
| soundness with Dirichlet weights | Thm 4.7 (average over w*), Thm 4.8 (fixed w*, threshold ∝ R_α(n, \|T*\|)) | Thm 4.1 applied without qualification | experiments Prop X8(a) and X8(c); Lemma 4.6(a) is X8(c)'s termwise argument, (b) adds an explicit constant |
| parameters and support of L1 | Lemma 1.7(c) assumes parameters admissible | implicit | universal §12.3 ("faithfulness relative to the calculus") |
| names of likelihoods | L1 = normalised tree grammar (universal "L1-norm"); two-part = universal "L1-max", pa "L1-sch"; L2 = bounded depth | same, two-part unnamed | universal renamed its Viterbi likelihood to L1-max to avoid the clash with L2 |
| symbol-size grammar | L1^σ (new); Hänni's graded score, normalised, is a two-part code of the same kind | "the MDL version of L1" | pa's L1-sch charges β bits per written symbol, so it is on the L1^σ side of Prop 6.9's distinction |
| Hänni's variants | S_prove, S_nc, S_g | same | universal (S_prove, S_nc,β), pa (S_prove, S_nc, S_g, L_ε) |
| generator class, posterior | C*, π_n | same | all tracks |
| Dirichlet α | ½ by default | ½ | all tracks (universal's older checks use α = 1) |
| verifier with Dirichlet weights in pa | pa §5.4 now cites Thms 4.7 and 4.8 | an earlier draft of pa's final notes cited Thm 4.1 | pa notes-final §5.4 |
| support of L1 in pa | pa Props 3.3, 4.6(a) now state the parameter hypothesis of Lemma 1.7(c) | implicit | pa notes-final §3.6, §4.1 |
| computability of L1 | value computable, support undecidable (Prop 2.7) | not discussed | pa notes-final Def 0.3 (which said "not computable" before) |

### 11.2 Results that agree across tracks

* **Size principle.** Lemma 1.8 is the decomposition behind universal Thm U4(1); Prop 1.9 matches universal's and pa's remarks that S_prove has no size principle.
* **Splits.** Prop 2.6(b) (exact ties) is used by universal §10 and pa Prop 2.1. Props 5.4 and 5.6 (the grammar decides; learned weights pay Occam terms; misfit usage gives a linear gain) agree with pa §2 ("the MDL finding survives a derivation likelihood; the split comes from the instantiation grammar") and with experiments E2 and E3. Pa Prop 2.2 (a split with a non-atomic connective derives every induction instance; 370–490 bits per unseen-connective datum) is the L1-specific competitor that Prop 5.6 does not cover.
* **Spare slots.** Prop 5.5(a) (½ log₂ n bits at α = ½) agrees with pa Prop 5.1 and experiments X7 and E5; Prop 5.5(c) (n^{−α/2}) with experiments X7(b) (computed slopes −0.224 and −0.290 against −0.25).
* **ω-gap.** Example 3.2 (L0), universal Thm U10 (derivation likelihoods) and pa §5.5 (the head-symbol split) are the same phenomenon in three models.
* **Gold and the IΣ_n chain.** Prop 5.2 (the data law decides between L_5 and L_∞) agrees with pa §4.1 and experiments E5.
* **Time penalties.** Prop 6.6 (membership-time penalties do not block the collapse) agrees with universal Prop U2t (no penalty monotone in derivation length reverses its Thm B) and with experiments' time factor (1+|T|)^{−τ}, which is a membership-time penalty and, as §1.3 says, barely bites inside DT° (experiments E7).
* **Soundness.** Universal §11 applies Theorem 4.1 to fixed-weight generators, which is within its hypotheses. Experiments E4 finds win rates 9–46 times below the bound of Prop X8, which is Theorem 4.7's.

### 11.3 Remaining differences

* **Citations that now point to changed statements.**
  * Prop 6.9 is refuted. No other track cites it. Universal §2.2 and §8 cite "model §6: only derivation length prices computation"; that remains true for derivation length in symbols, while the grammar's own code length prices it only logarithmically as far as proved (§6.5).
  * Thm 5.1(b) changed (instance-union level; the exact-class statement is refuted). No other track cites it.
  * Def 1.5 changed (uniform condition). Experiments' grammar satisfies the new condition.
  * Universal §11 states its soundness result through Theorem 4.1 (fixed weights). Its generators have fixed weights, so this is within the hypotheses; for its learned-weight variants the applicable statements are Theorems 4.7 and 4.8.
* **Truncation cost.** Pa Def 0.3 summarises Prop 2.7 as "evaluation by truncation takes time exponential in the derivation size". Prop 2.7 says slightly less: the truncation enumerates a number of trees exponential in N ≈ C_ν/ε. No lower bound on the cost of evaluating P_T is proved here.
* **Calculi.** This track uses Mendelson's K as a tree grammar (and, in Example 3.6, an equational grammar L1-eq). Universal uses the chains C_min and C_open and the U3 tree calculi; experiments use chains with at most two steps; pa uses natural deduction with a two-part code. Numerical rates are not comparable across tracks; the qualitative statements are.
* **Instantiation grammar.** Fixed PCFGs here, in universal (numeral and Galton–Watson laws) and in experiments; a KT-learned positional grammar in pa. Props 5.4 and 5.6 assume a fixed Q. With a learned grammar the sign of the fragmentation drift can change (pa §2.2 and §8.3); pa's Prop 2.3 (§2.2) reconciles the two.
* **Priors.** Prefix code π_λ here (proper for λ ≥ 1); 2^{−β·symbols} on finite candidate sets in pa (β = 5 or log₂ 23) and 2^{−λ(Σ|A| + 1)} in universal; a stochastic template code with a time factor in experiments. Prior shares differ accordingly (universal §6.6).
* **Verifier constants.** δ/π(C*_d) here; 2^{−bits(T*)} in experiments; δ/π(C*_∀) in universal. They are the same theorem with different priors and classes.
* **Memorisation.** Here: a fixed memoriser dies (well specified) and memorisation-plus-escape wins in one misspecified example (Remark 3.5, conjecture). Universal U6: the memoriser class keeps exp(−O(log² n)) under geometric numerals. Pa §3: memorising short theorems wins under a two-part code on theorem data. Experiments: only Mem(D_n) is in the pools. Different settings; each statement holds in its own.
* **Misspecification and unsound theories.** Experiments E3 found no mass on unsound theories under misspecified *usage* of instance data, where the schema itself is in the pool. Examples 3.4 and 3.6 here concern data that are *derived theorems*, not instances of any sound template; there the escape template is the cheapest generator. Pa §6 (a false generalisation whose counterexamples never occur) is a third kind. The three are compatible.

---

## References

Known results are cited from memory unless marked otherwise. In the first session I checked the bibliographic data of Berk 1966, Kleijn & van der Vaart 2006, Ghosal & van der Vaart's Theorem 6.9 and Žák 1983 by web search (abstracts and catalogue records only). The referee additionally checked, by web search, Hutter 2007, Rousseau & Mengersen 2011, Schwartz 1965, Seiferas–Fischer–Meyer 1978, Craig 1953, Krichevsky & Trofimov 1981, Tenenbaum & Griffiths 2001 and Waudby-Smith & Ramdas 2020. In this revision I checked no further sources; the references added below are marked unverified.

* Angluin, D. (1980). Inductive inference of formal languages from positive data. *Information and Control* 45:117–135.
* Angluin, D. (1988). Identifying languages from stochastic examples. Yale Univ. tech. report YALEU/DCS/RR-614. (existence checked by the referee; content unverified)
* Athreya, K. B., & Ney, P. E. (1972). *Branching Processes*. Springer. (Galton–Watson extinction; unverified numbering)
* Berk, R. H. (1966). Limiting behavior of posterior distributions when the model is incorrect. *Ann. Math. Statist.* 37(1):51–58. doi:10.1214/aoms/1177699597. (abstract checked; the conditions were not read)
* Birkhoff, G. (1935). On the structure of abstract algebras. *Proc. Cambridge Philos. Soc.* 31:433–454. (completeness of equational logic; unverified)
* Boolos, G., Burgess, J., & Jeffrey, R. *Computability and Logic*. (Σ₁-completeness of Q; unverified chapter)
* Busatto, G., Lohrey, M., & Maneth, S. (2008). Efficient memory representation of XML document trees. *Information Systems*. (equality of grammar-compressed trees; recalled from memory, unverified)
* Church, A. (1936). A note on the Entscheidungsproblem. *J. Symbolic Logic* 1:40–41. (unverified)
* Cook, S. A. (1972). A hierarchy for nondeterministic time complexity. *STOC '72*.
* Craig, W. (1953). On axiomatizability within a system. *J. Symbolic Logic* 18(1):30–32.
* Doob, J. L. (1949). Application of the theory of martingales. *Colloques Internationaux du CNRS* 13:23–27.
* Ghosal, S., & van der Vaart, A. (2017). *Fundamentals of Nonparametric Bayesian Inference*. CUP. (Doob's theorem as Thm 6.9, confirmed via citing papers only)
* Gold, E. M. (1967). Language identification in the limit. *Information and Control* 10:447–474.
* Hájek, P., & Pudlák, P. (1993). *Metamathematics of First-Order Arithmetic*. Springer. (partial truth predicates; unverified numbering)
* Horning, J. J. (1969). *A Study of Grammatical Inference*. PhD thesis, Stanford. (existence checked by the referee; details unverified)
* Hutter, M. (2007). On universal prediction and Bayesian confirmation. *Theoretical Computer Science* 384(1):33–48. (abstract checked by the referee; full text unverified)
* Kaye, R. (1991). *Models of Peano Arithmetic*. OUP.
* Kleijn, B. J. K., & van der Vaart, A. W. (2006). Misspecification in infinite-dimensional Bayesian statistics. *Ann. Statist.* 34(2):837–877. doi:10.1214/009053606000000029; arXiv math/0607023. (abstract checked; the conditions were not read)
* Krichevsky, R., & Trofimov, V. (1981). The performance of universal encoding. *IEEE Trans. IT* 27(2):199–207.
* Mendelson, E. *Introduction to Mathematical Logic*, Ch. 2. (system K, completeness; edition and numbering unverified)
* Plandowski, W. (1994). Testing equivalence of morphisms on context-free languages. *ESA '94*. (polynomial equality of compressed strings; recalled from memory, unverified)
* Pudlák, P. (1998). The lengths of proofs. In *Handbook of Proof Theory*, Elsevier. (unverified)
* Rousseau, J., & Mengersen, K. (2011). Asymptotic behaviour of the posterior distribution in overfitted mixture models. *JRSS B* 73(5):689–710.
* Schmidt-Schauß, M. (2005). Polynomial equality testing for terms with shared substructures. Technical report, Univ. Frankfurt. (recalled from memory, unverified)
* Schwartz, L. (1965). On Bayes procedures. *Z. Wahrscheinlichkeitstheorie verw. Geb.* 4:10–26.
* Seiferas, J., Fischer, M., & Meyer, A. (1978). Separating nondeterministic time complexity classes. *JACM* 25(1):146–167.
* Shafer, G. (1976). *A Mathematical Theory of Evidence*. Princeton.
* Tenenbaum, J. B., & Griffiths, T. L. (2001). Generalization, similarity, and Bayesian inference. *Behavioral and Brain Sciences* 24:629–640. (the size principle)
* Turing, A. M. (1936). On computable numbers, with an application to the Entscheidungsproblem. *Proc. London Math. Soc.* 42:230–265. (unverified)
* Ville, J. (1939). *Étude critique de la notion de collectif*. Gauthier-Villars.
* Waudby-Smith, I., & Ramdas, A. (2020). Confidence sequences for sampling without replacement. *NeurIPS*. (prior–posterior-ratio martingale; as cited in `IL`)
* Žák, S. (1983). A Turing machine time hierarchy. *Theoretical Computer Science* 26(3):327–333.

Internal: `../../../axiom-schemas/paper/sections/{setting,universal,app-universal,many,app-many}.tex`; `../../../inferential-learning/paper/sections/{caution,app-caution,informal,app-informal}.tex`; `../../../inferential-learning/research/theory/{T1,T5}-…md`; `../../../axiom-schemas/research/conversation.md` §§3–9; `../../prior/*.md`; the other tracks' notes named in §11.

---
## 12. Verification log

All checks below were done in this track, in two sessions: the first produced `notes.md`; the second, after the referee report, produced this file. Nothing is checked in a proof assistant.

### 12.1 Referee issues and their resolution

| issue | referee's point | resolution | where |
|---|---|---|---|
| **M1** | Thm 4.1 proved for fixed weights; applied to the default Dirichlet model, where it is vacuous and its analogue fails (0.98–1.00 against 0.02) | **Accepted.** Thm 4.1 restricted to fixed weights everywhere (§0, §4, §5.4, §5.5). Vacuity proved (Remark 4.5). Counterexample reproduced with independent code, every n checked: 0.997 and 1.000 (Example 4.9). Two correct versions proved: Bayes-averaged (Thm 4.7, = experiments X8(a)) and fixed w* with threshold ∝ R_α(n, \|T*\|) (Thm 4.8), via Lemma 4.6 (termwise reduction; explicit bound for α ≤ 1; tight exponent at α = 1). Computed: B2 0.007/0.003 ≤ 0.02; B3 0/300 | §4.2; `c11` |
| **M2** | Prop 6.9 false: L1 code length can be logarithmic in symbol size | **Accepted.** Prop 6.9 kept, marked refuted, with the counterexample (reproduced in `c12`). Replaced by Lemma 6.10 (size ≤ (c_T+1)ν²e^{ν/e}), Prop 6.11 (L1 charges ν exponentially), Thm 6.12 and Cor 6.13 (logarithmic charge for hard assigners), Prop 6.14 (L1^σ and the graded score charge symbol size), Conj 6.15. Remark 1.10, §6.4 item 3, §9.2 and the summary weakened accordingly | §1.5 (L1^σ), §6.5; `c12` |
| **M3** | "a derivation likelihood does not change the MDL finding [proved]" proved only for matched fixed weights | **Accepted.** The [proved] tag withdrawn. New Prop 5.6: (a) split with learned weights = schema with learned root law (L0, L1, L2); (b) Ville bound on the split's gain; (c) linear gain under misfit usage (with a KL-continuity lemma); (d) the n^{−(K−1)/2} rate as a conjecture. L1-specific competitors listed as not covered, with pa's results cited | §5.3; `c13` |
| **M4** | Thm 5.1(b): the named set has posterior mass 0 at every n | **Accepted.** The original statement kept as (b″), refuted, with a proof that the mass is 0 for all w* outside a countable set. The instance-union statement proved by the referee's suggested route (support functional, countable parameter). Weak consistency stated as known with a sketch. (c) re-read at the instance-union level | §5.1 |
| **M5** | per-type subcriticality unsatisfiable for formula sorts and insufficient with infinitely many types; the domination step invalid | **Accepted.** Def 1.5 replaced by a uniform weighted condition; Lemma 1.6 reproved (expected size; exponential tail; extension to any multi-type process), without domination. Satisfiable for L_A (explicit grammar, ρ = 0.75); excludes the referee's chain (proved) | §1.4; `c10` |
| m1 | Cor 6.8: c depends on T | **Accepted.** c depends on T only through the membership exponent; uniform for template theories; statement split into (a) template theories, (b) each exponent; single X for all exponents as a sketch | Cor 6.8 |
| m2 | Prop 4.2's non-adaptive prover fails against an escalating verifier | **Accepted.** Prover replaced by the waiting prover; the referee's numbers (11/400 against 400/400) quoted | Prop 4.2 |
| m3 | Remark 1.10's "smaller P_T(s) on each datum" false; β must be 0; symbol size vs L1 code length | **Accepted.** Original sentence kept as refuted (referee's r6 numbers). Correct version proved (data whose shortest derivation is unchanged). β = 0 required, bit-length of explicit derivations used, and the score identified as a two-part code that charges written length, like L1^σ | Remark 1.10 |
| m4 | c5 remark "coherent cases are essentially those where every theory is complete" wrong | **Accepted.** Remark marked refuted. New Prop 7.6 (proved): the 50/50 rule is coherent iff every theory has ≤ 2 models. Checked by LP on 3825 posteriors with no disagreement | Prop 7.6; `c14` |
| m5 | c9 tautological for the split | **Accepted.** New `c9b` computes every likelihood by matching; agreement to 5.7·10⁻¹⁴ | §2.1; `c9b` |
| m6 | c6 numbers misreported (P_{T1}(b)) | **Accepted.** Corrected to 0.16–0.35 | Prop 2.5 |
| m7 | spares in the span omitted | **Accepted.** Prop 5.5(d1) proved (exact formula, constant limit), (d2) sketched with its density hypothesis; computed; a case where the spare gains found and reported | Prop 5.5(d); `c15` |
| m8 | §4 Computability: "W* only grows" and "finite sums" false | **Accepted.** Both corrected; a computable verifier with the guarantee given via Prop 2.7(a) with one-sided acceptance | §4.1 remarks |
| m9 | Prop 1.9(b) needs T* ∪ {ψ} ∪ D consistent | **Accepted.** Hypothesis added, with the referee's example | Prop 1.9(b) |
| m10 | Prop 2.6(c) cites `AS:prop:univ:determine` beyond its scope | **Accepted.** Restricted to FO templates with only 0-ary term metavariables; the rest stated as open | Prop 2.6(c) |
| m11 | Lemma 1.7(a) needs α_ax + α_lg > 0 | **Accepted.** Added | Lemma 1.7 |
| m12 | Lemma 1.7(c), Cor 2.3 need parameters admissible | **Accepted.** Added to Lemma 1.7(c) and to its uses; noted for Example 3.2; pa's Prop 3.3 now states it too | Lemma 1.7(c), §3, §11.3 |
| m13 | `IL:prop:caution:tight` does not transfer as stated | **Accepted in part.** The exact IL pair is not in the template models. But tightness holds exactly, not only as a supremum: T′ = {a, c} with small fixed weight on c reproduces the IL acceptance probability (proved) | Remarks on Thm 4.1 |
| m14 | "the likelihood never tells a schema from its split" only for matched fixed weights | **Accepted.** Qualified in the summary and in §2.3 | §0 item 3, §2.3 |
| m15 | Prop 2.5's "goes to 0 or ∞" only if T* ∈ {T1, T2} | **Accepted.** Qualified | §2.3 |
| m16 | Example 3.4 and Remark 3.5 are L0 only; "Robustly: no" should say L1 is untested | **Accepted, and the L1 question computed** (Example 3.6) | §3, §9.2 |
| Q1 | robustness under L1 | Example 3.6 (computed, equational derivation grammar): unsound minimiser in 16/16 settings with Q's + probability 0.25; sound minimiser in 5/8 when + is rare under Q. Conjecture 3.7 | §3; `c16` |
| Q2 | cost of computing the L1 likelihood; MDL max vs sum | Prop 2.7 (computable reals; positivity undecidable), Prop 2.8 (the maximum breaks generator ties) | §2.4 |
| Q3 | L1-specific competitors | Listed as not covered by Prop 5.6; pa Prop 2.2 cited; open problem 6 | §5.3, §10 |
| Q4 | soundness of the default model; comparison table | Theorems 4.7, 4.8; §5.5 table rewritten with the weight convention stated | §4.2, §5.5 |
| Q5 | data that come with proofs | Prop 8.2 (proved): proofs identify the instance union; splits still tie | §8 |
| Q6 | grading near misses | Remark 8.3: corruption channel; general results transfer; open beyond that | §8 |

The referee's list of claims checked and confirmed (most of §§1–8) needed no change beyond the items above.

### 12.2 Scripts and results

All in `checks/`, seeded, each writing `<name>.out` next to itself. `terms.py` is a shared helper.

| script | checks | result |
|---|---|---|
| `c1_size_principle.py` | Lemma 1.8 decomposition for z+0=z against z₁+0=z₂; simulated per-datum log-ratio | identity to 10⁻⁹ on the truncated space; simulated 3.94 against exact H(Q) = 3.894 nats |
| `c2_split.py` | Prop 2.6(b) by genuine matching on 2849 instances; Prop 5.4 well- and misspecified, n = 10²…10⁶, 400 runs | max difference 1.1·10⁻¹⁹; means within 0.1 of the Stirling prediction (well specified) and within 0.1% (misspecified) |
| `c3_spare.py` | Prop 5.5(a)–(c), numerical 2-D integration, n = 10²…10⁴ | (a) exact to 4 decimals; (b) slope −0.498 (−0.5); (c) −0.346, see c3b |
| `c3b_redundant.py` | Prop 5.5(c) at n = 10³…10⁷ | slope −0.265 (s.e. per point ≈ 0.07) against −0.25 |
| `c4_ville.py` | Thm 4.1 (fixed weights, 20 000 runs) and Prop 4.2 / Example 3.4 (2000 runs) | 0.044, 0.014, 0.004 ≤ 0.10, 0.033, 0.010; misspecified acceptance 2000/2000, median time 17 |
| `c5_trichotomy.py` | Props 7.2, 7.3, Examples 7.4, 7.5 by LP; 300 random posteriors | 0 violations; both examples infeasible; renormalisation incoherent in 90/300, 50/50 in 290/300 |
| `c6_L1_ident.py` | Prop 2.5 under L2, 4 settings | TV 0.16–0.35; P_{T1}(b) 0.16–0.35, P_{T2}(b) 0.007–0.04 |
| `c7_misspec_full.py` | Remark 3.5, restricted comparison | hybrid beats memorisation by 7 000–25 000 bits at n = 10⁴; evidence only |
| `c8_formulas.py` | L0 Dirichlet labelling-sum formula; Lemma 1.7 branching sizes | closed form = quadrature to 10⁻¹²; mean sizes 2.010, 9.965 (2, 10); P(finite) 0.7489 (0.75) |
| `c9_consistency.py` | Thm 2.1, Cor 2.2 | superseded for the split by c9b (tautological there; referee m5); other rows as predicted |
| `c9b_consistency_matching.py` (new) | Thm 2.1, Cor 2.2 with every likelihood by matching, 3 seeds, n ≤ 2000 | log-likelihoods of T* and T_split agree to 5.7·10⁻¹⁴; over-general, missing-root and spare theories → 0 |
| `c10_subcritical.py` (new) | Def 1.5, Lemma 1.6 (M5) | Q_A satisfies the uniform condition with ρ = 0.75 at every type; mean sizes 14.62 (bound 80) and 4.016 ± 0.015 (bound 4, exact 4); the referee's chain forces h(k) → 0 |
| `c11_ville_dirichlet.py` (new) | Lemma 4.6, Thms 4.7, 4.8, Example 4.9 (M1) | Lemma 4.6(b) never violated (max gaps −2.81, −1.00, −6.45); exact R(n, K): slopes −0.499, −0.993 (α = ½), −0.993, −1.960 (α = 1); Example 4.9: fixed w* 0.997, 1.000; averaged 0.007, 0.003 (bound 0.02); shrinking threshold 0.000 |
| `c12_l1_size.py` (new) | Prop 6.9 counterexample, Lemma 6.10, Prop 6.11 (M2) | size 2^{k+3} − 1 at ν = 7 + 8k (k ≤ 12); 0 violations of the chain form of Lemma 6.10 on 9865 random conclusions (max ln size/ν = 0.220 < 1/e); exponential tail of ν |
| `c13_split_L2.py` (new) | Prop 5.6 (M3) | (a) 1.1·10⁻¹⁴; (b) 0.427, 0.133, 0.036 ≤ 0.5, 0.2, 0.05; (c) 0.11301, 0.11460, 0.11464 → KL 0.11487; (d) slope −0.507 (−0.498 for n ≥ 10⁴) against −0.5 |
| `c14_fiftyfifty.py` (new) | Prop 7.6 (m4) | criterion = LP coherence in 3225/3225 (2 atoms) and 600/600 (3 atoms) |
| `c15_spare_inspan.py` (new) | Prop 5.5(d) (m7) | (d1) exact = numerical to 5 decimals; limit matched at n = 10⁶; (d2) w*₁ = 0.3: increments −0.031, −0.021, −0.004 per decade; w*₁ = 0.5: +0.22, +0.20, +0.13 (spare gains) |
| `c16_L1_robust.py` (new) | Example 3.6 (Q1, m16) | fixpoint = Monte Carlo (Z 0.54909 vs 0.54965 ± 0.00091); unsound minimiser 16/16 (grammars 1, 2), sound minimiser 5/8 (grammar 3) |

Run times: c11 about 2 minutes, c13 about 5 minutes, c15 about 1.5 minutes; the others seconds. Each new script was run after its last edit; the `.out` files are those runs.

**Referee scripts used as evidence** (in `referee_code/`, not re-run): `r1_subcritical.out` (M5), `r2_l1_size.out` (M2), `r3_ville_dirichlet.out` (M1, m2), `r4_dirichlet_rates.out` (Props 5.4(b), 5.5, m7), `r5_trichotomy.out` (§7, m4), `r6_stronger_theory.out` (Remark 1.10, Prop 2.5), `r7_ville_fixed.out` (Thm 4.1). Where a referee result is quoted as evidence for a resolution, an independent script of this track reproduces it: c11 reproduces r3 Part 1, c12 reproduces r2, c14 reproduces r5's characterisation, c15 reproduces r4's case (d). r1's Check B is used as the referee computed it; c10 shows that the new condition excludes it. r3 Part 2, r6 and r7 are quoted as the referee's.

### 12.3 Status of every claim

**Proofs written in full here:** Lemmas 1.2(a), 1.4, 1.6, 1.7 (except the extinction criterion, which is known), 1.8; Prop 1.9; Remark 1.10 (corrected parts); the L1^σ normalisation; Thm 2.1; Cors 2.2, 2.3; Props 2.4, 2.5 (proved region), 2.6, 2.7 (given Church's theorem), 2.8; Thm 3.1; Example 3.2; Lemma 3.3; Example 3.4; Thm 4.1 and the tightness remark; Props 4.2, 4.3, 4.4; Remark 4.5; Lemma 4.6(a), (b), (d); Thms 4.7, 4.8; Thm 5.1(a), (b), (b″); Props 5.2, 5.4, 5.5(a), (d1), 5.6(a)–(c); Prop 6.0; Thm 6.1; Props 6.2, 6.3 (given standard formalisation), 6.4, 6.5 (given partial truth predicates), 6.6; Thm 6.7; Cor 6.8 (given the hierarchy theorem); the counterexample to Prop 6.9; Lemma 6.10; Prop 6.11; Thm 6.12; Cor 6.13 (given the hierarchy theorem); Prop 6.14; Props 7.1–7.3, 7.6; Examples 7.4, 7.5; Thm 8.1; Prop 8.2; the transfer in Remark 8.3.

**Proof sketches only:** Lemma 1.2(b); Thm 5.1(b′); Prop 5.5(b), (c), (d2); the mechanism of Example 4.9; the upper bounds on collapse derivation sizes (§6.4); the single-X remark after Cor 6.8.

**Computed only:** Example 3.6; the failure in Example 4.9; Remark 3.5's comparison.

**Conjectures:** Thm 5.1(c); Remark 3.5; Conjecture 3.7; Prop 5.6(d); Conjecture 6.15; the polytime analogue in §9.3; the open problems in §10.

**Refuted (kept, with counterexamples):**
* the brief's H6 sentence "A schema 'T(⌜φ⌝) = accept → φ' requires running T to check membership" (Prop 6.6(a));
* Hänni's consistency argument for his schema in a single-sorted setting (Prop 6.3); his conclusion, the equivalence, survives via Craig (Thm 6.1);
* `notes.md` Def 1.5's per-type subcriticality as a usable hypothesis (§1.4; referee M5);
* `notes.md` Remark 1.10's "smaller P_T(s) on each datum" (Remark 1.10; referee m3);
* `notes.md` Thm 5.1(b), the exact-generator-class statement (Thm 5.1(b″); referee M4);
* `notes.md` Prop 6.9, "L1 charges derivation symbol size" (§6.5; referee M2);
* `notes.md`'s remark on c5, "the coherent cases are essentially those where every theory is complete" (§7; referee m4);
* `notes.md`'s use of Theorem 4.1 for Dirichlet weights (Remark 4.5, Example 4.9; referee M1);
* `notes.md`'s "[proved]" for "a derivation-based likelihood does not change the MDL finding" in full (withdrawn; Prop 5.6 states what is proved; referee M3);
* `notes.md`'s "W* only grows" and "L2 likelihoods are finite sums" (§4.1 remarks; referee m8).

### 12.4 Self-checks that changed these notes during the revision

* **c13, first version.** Its logical-axiom grammar had no → in its support, so the schema's instances never interacted with the logical axioms and the citations were not latent at all. I enlarged the grammar (PCFG truncated to size ≤ 5); citations then became latent, though only weakly (88 of 5885 conclusions), and I say so in §5.3.
* **c15, case (d2).** I first claimed, as a sketch, that an in-hull spare tends to a constant without conditions. The first run used w*₁ = ½, where the truth equals the spare's own law; ln R_n kept growing. The cause is an infinite prior density at P*. I added the density hypothesis to (d2) and report the growing case.
* **c16, a third grammar.** With only grammars 1 and 2 the unsound escape won everywhere, and I was about to state Conjecture 3.7 for all parameters. A probe with + rare under Q showed the sound theory winning, so Example 3.6 reports both regimes and Conjecture 3.7 names the boundary.
* **Lemma 6.10.** The first version bounded the size by (c_T+1)ν^{ν+1}. Using that the substituted terms are disjoint sets of grammar nodes (AM–GM) gives an e^{ν/e} factor, which turns NTIME(2^{O(ℓ log ℓ)}) into NTIME(2^{O(ℓ)}) in Theorem 6.12. Rereading the citation case, I then saw that an A4 citation is not a template and can have size quadratic in ν (the referee's one-node example), so the lemma now has ν² in place of ν. c12 tests the chain case, where the bound with ν holds.
* **Tightness of Thm 4.1 (m13).** The referee proposed tightness "only as a supremum". Working through the ε-family showed that for small fixed ε the IL acceptance probability is attained exactly, so the remark states that.
* **Lemma 4.6(b) versus the KT rate.** My first bound for the fixed-w* theorem had exponent K − 1. Experiments Prop X8(c) has the termwise argument with the KT rate (K−1)/2. Lemma 4.6 now has both: the termwise reduction (a), the explicit bound (b), the KT rate (c), and (d) showing that K − 1 is the right exponent at α = 1 (c11 Part A2).
