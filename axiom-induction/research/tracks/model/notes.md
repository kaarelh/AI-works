# Track "model": general theory of a Bayesian axiom inducer

*Track "model" of the axiom-induction project. Read `../../00-brief.md` first. Scripts are in `checks/` (seeded; each writes its output to a `.out` file next to it). This track covers brief items H1, H2, H3, H5 and H6, and the relations to Hänni's note `../../prior/hanni-solomonoff-axiom-induction.md`. The case ∀xφ is track "universal"; PA and ZF are track "pa".*

**Status tags.**
* **[proved]**: full proof in these notes.
* **[proof sketch]**: the argument is given; some steps are not written out.
* **[computed]**: checked by a script in `checks/`; the output file is named.
* **[known]**: a published result, with reference. **(unverified)** means I recalled it and did not check the source in this session.
* **[conjecture]**: believed, not proved.
* **[refuted]**: a claim (usually from the brief) shown false, with the counterexample.

**Reference labels.** `AS:` refers to the paper `../../../axiom-schemas/paper/sections/*.tex`, by LaTeX label. `IL:` refers to `../../../inferential-learning/paper/sections/*.tex`, by label. `conv §k` is section k of `../../../axiom-schemas/research/conversation.md`. "Hänni's note" is `../../prior/hanni-solomonoff-axiom-induction.md`.

---

## 0. Summary

The question (brief): is there a good Bayesian or Solomonoff-style axiom inducer, with a template prior, a derivation-length likelihood and a time penalty, and does it find the actual axioms, or an equivalent system, or at least put much posterior mass on them?

What this track establishes, in short.

1. **A model.** Theories are finite sets of DT° templates. The prior is a syntactic prefix code. Three likelihoods are defined with explicit normalisation: L0 (axiom citation, with Dirichlet-integrated mixture weights), L1 (a derivation grammar, a branching process; proper iff the mean number of premises per node is at most 1) and L2 (bounded depth). Hänni's two variants ("proves the givens", "does not contradict") are 0/1 scores. The likelihoods have the size principle because their normaliser does not depend on the data; the scores do not (§1).
2. **Well-specified case.** For a countable class with π(T*) > 0 and i.i.d. data from P_{T*}, the posterior concentrates a.s. on the *generator class* C* = {T : P_T = P_{T*}}, and inside C* it stays proportional to the prior forever. Deductive beliefs P(T ⊢ s | D) converge to the prior-weighted fraction of C* that proves s (§2, §8). This is Doob's theorem; a direct proof is given.
3. **Identification is of the generator.** Under L1, deductively equivalent theories generally have different P_T (example with a proof). Under L0, P_T = P_{T'} forces equal instance sets but not equal template sets: splitting a metavariable by the root production of the PCFG Q gives *exactly* the same distribution, under L0 and under L1. So the likelihood never tells a schema from its split. Only Occam terms do: (K−1)/2 · ln n nats in favour of the unsplit template when Q fits the usage, and a linear loss when it does not. This is the MDL finding of `AS:sec:many:mdl`, and a derivation likelihood does not change it (§2.3, §5.3).
4. **Misspecification.** For finite classes the posterior concentrates on the KL-minimisers (proved). Two examples. In the first, all data are theorems of T* and the posterior concentrates on theories strictly weaker than T* (a Bayesian ω-gap). In the second, all data are theorems of Q and the posterior concentrates on a theory that proves 0 = S0. For the full countable class the KL-projection picture can fail. A computed comparison suggests that the posterior then prefers "memorise frequent data plus one over-general escape template", which is unsound (§3).
5. **Soundness against adaptive provers.** The thresholded verifier "accept s iff the posterior mass of {T : s ∉ Th_d(T)} is ≤ δ" is sound at all times, against every prover, with probability ≥ 1 − δ' whenever δ ≤ π(C*_d)·δ'. This needs well-specification. Without it, a prover that just waits gets a false sentence accepted with probability 1. The cautious verifier is the δ = 0 limit, read at the level of theorems. The Bayesian verifier needs no anchor and no bound on the number of schemas; it pays with probabilistic, model-dependent soundness (§4).
6. **Positive data and Gold.** With stochastic data and a well-specified generator, the instance set (L0) or theorem set (L1) is identified in the limit with probability 1, with no bound on the number of templates. Gold's theorem still applies to the Bayesian learner: on some texts its guess changes forever, but those texts have probability 0. A spare template disjoint from the data costs exactly a factor Γ(A+α)Γ(A+n)/(Γ(A)Γ(A+α+n)) ≈ n^{−α}. With α = ½ this is ½·log₂ n bits, as the brief guessed. A spare template that overlaps the data and reaches outside them costs about n^{−α}, and one inside the data's support about n^{−α/2} (proof sketches; computed) (§5).
7. **Time penalty and Hänni's collapse.** Hänni's equivalence (axiom induction requiring proofs ≈ Solomonoff function induction over consistent assigners) holds exactly: semimeasure log-losses agree within 2c bits on every reveal order and labelling. Two repairs are needed. Use Craig's padding trick rather than his schema "A(⌜φ⌝) = accept → φ". And use the semimeasure convention rather than renormalising. His schema works in a two-sorted setting but is inconsistent for some consistent assigners in single-sorted arithmetic over PA. Templates block the schema itself: every DT° template inside it is a single sentence. Templates do not block the collapse in arithmetic: one ground reflection sentence over PA reproduces any Σ_n-sound assigner on Σ_n sentences. A time penalty on checking axiom membership does not block the collapse, because membership in either construction is polynomial-time without running the assigner. The brief's H6 claim that the schema "requires running T to check membership" is refuted. What does price the assigner is derivation length. Any theory consistent with an assigner must use derivations whose size bounds the assigner's nondeterministic time (proved, via the nondeterministic time hierarchy theorem) (§6).
8. **The trichotomy.** Bel(s) = P(T ⊢ s | D) is a Dempster–Shafer belief function, and Pl(s) = 1 − P(T ⊢ ¬s | D) is its plausibility. Some probability on complete theories lies between them. Hänni's two point estimates are incoherent: "renormalise" and "independent → 50/50". Both are confirmed incoherent by explicit examples and by random trials. Keeping the triple is the coherent option, and it is also what makes the equivalence in item 7 exact (§7).
9. **Predictive versus deductive.** Predictions merge with total expected KL ≤ ln(1/π(C*)), whatever the deductive questions. Deductive beliefs converge only to what the generator class agrees on, and to the KL-minimiser's theorems under misspecification (§8).

What can be promised, in one paragraph. If the data really are i.i.d. from one of the model's generators, the method is consistent for the generator. It identifies the theorem set in the limit (under L1, or the instance set under L0). Its thresholded verifier is time-uniformly sound against any prover with probability 1 − δ/π(C*). It needs no bound on the number of axioms. It does not identify "the actual axioms" beyond their generator class. In the class, splits of a schema are exact likelihood ties; Occam terms decide them, and wrong usage statistics reverse the decision. If the data are human theorems not generated by the model, none of these guarantees survives, and the posterior can concentrate on weaker or on unsound theories.

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

Turning "the matching position in the consequent" into a statement about every DT° shape is the step not written out.

So A4, i.e. ∀-elimination, belongs to the fixed background, not to the learned class. This matches `AS:rem:setting:nested` and conv §4: "the Hilbert axiom ∀xφ → φ[t/x] has exactly the same problem as the rule ∀E". The other logical axioms are templates:
* A1–A3 are in FO, with 0-ary formula metavariables.
* A5 is in PAT: ∀x(P → Q(x)) → (P → ∀x Q(x)). The side condition is built in, because a body for the 0-ary P cannot mention x.
* Substitutivity, ∀x∀y(x = y → (P(x,x) → P(x,y))), is in DT°, with pattern occurrence P(x,y).

In derivation grammars (L1 below) we also use ∀E, "from ∀xφ infer φ[t/x]", as a primitive rule. It is derivable in K (A4 then MP), so it does not change Th.

### 1.3 Prior

**Definition 1.3 (template code).** Templates are coded in preorder.
* *Symbol tokens.* Each node writes one token from a fixed alphabet: the symbols of the language, the connectives, ∀, ∃, and three escape tokens IDX, PAR, MV. Each token takes ⌈log₂(alphabet size)⌉ bits.
* *Escapes.* After IDX comes Elias-γ(k+1) for a de Bruijn index k. After PAR comes Elias-γ(j+1) for parameter p_j. After MV comes one bit for new/old. A new metavariable then gets its arity n (γ(n+1)) and sort (1 bit); an old one gets its index among the metavariables introduced so far (γ). Then its n argument terms follow.
* *Prefix-freeness.* Arities fix the tree shape, so the code is prefix-free. Naming metavariables by first occurrence makes renamings receive the same code.
* *Theory code.* A theory T = {τ_1..τ_k} is coded as γ(k) followed by the k template codes in lexicographic order. Its length is ℓ(T).
* *Prior.* π_λ(T) := 2^{−λℓ(T)}/Z_λ with λ ≥ 1 and Z_λ := Σ_T 2^{−λℓ(T)} ≤ 1.
* *Weights.* Mixture weights get the prior Dir(α, …, α); the default is α = ½ (Krichevsky–Trofimov).

**Lemma 1.4 (Kraft) [proved].** Σ_{T∈H} 2^{−ℓ(T)} ≤ 1, so π_λ is a probability for λ ≥ 1. Moreover Σ_T π_λ(T)^{1/2} < ∞ when λ ≥ 2.

*Proof.* Theory codes form a prefix-free set, because the tree code is prefix-free and γ(k) fixes how many template codes follow. Kraft's inequality gives the first claim. For λ ≥ 2, 2^{−λℓ/2} ≤ 2^{−ℓ}. ∎

**Time factor (Levin Kt).** For an axiom set given by a decider p (Hänni's setting), a Kt-style prior is 2^{−|p|}/c_p, where c_p := min{c : time_p(m) ≤ c·t(m) for all m} for a reference bound t. Inside DT°, membership costs O(|τ| + |s|) (`AS:thm:setting:matching`). So the factor is polynomial in ℓ(T), changes log π by O(log ℓ(T)), and does not bite. Where time matters is §6.

### 1.4 Instantiation grammar

**Definition 1.5 (Q).** Q is a family of probabilistic context-free grammars, one per metavariable type ι^n → s. A body λz̄.β is generated top-down. At each node a production is chosen with fixed probability:
* a function or relation symbol, or a connective, with children of the right sorts;
* a quantifier, whose child is a body with one more bound index in scope;
* a hole z_i, a constant, a parameter (drawn from a geometric law), or a bound index in scope.

The law of the production at a node depends only on the node's sort and on the number of variables available there. Holes and bound indices in scope are treated alike, so a body of type ι^n → s that sits under one binder inside another body is drawn like a body of type ι^{n+1} → s. This makes the grammar factor at the root for binder productions too (used in Prop 2.6(b)).

A substitution θ for τ has Q(θ) := Π_M Q_{type(M)}(θ(M)), with metavariables drawn independently. Q is *subcritical* if every type's expected number of children per node is < 1. It has *full support* if every production has positive probability.

**Lemma 1.6 (Q_τ is a distribution on inst(τ)) [proved].** Let Q be subcritical and τ ∈ DT°. Then bodies are finite a.s. Q_τ(s) := Q(θ_s) if τθ_s = s, and 0 otherwise, is a probability on S with support inst(τ) if Q has full support.

*Proof.*
* *Finite bodies.* The number of nodes is dominated by a single-type Galton–Watson process whose mean offspring is the maximum over types, which is < 1. Such a process dies out a.s. [known: Athreya & Ney 1972, Ch. I (unverified numbering)].
* *Injectivity.* By `AS:thm:setting:matching`(a), θ ↦ τθ is injective on substitutions. So Σ_s Q_τ(s) = Σ_θ Q(θ) = 1.
* *Support.* Full support makes Q(θ) > 0 for every θ. ∎

### 1.5 Likelihoods

Data are a sequence D = (X_1, …, X_n) of sentences.

**L0 (axiom citation).**
* *Fixed weights.* P_{T,w}(s) := Σ_{τ∈T} w_τ Q_τ(s), and P_{T,w}(D) = Π_i P_{T,w}(X_i). It is normalised by Lemma 1.6.
* *Dirichlet-integrated.* P^Dir_T(D) := ∫ Π_i P_{T,w}(X_i) Dir(dw; α). Expanding the product and using Dirichlet moments gives
  P^Dir_T(D) = Σ_{ℓ: D→T, X_i ∈ inst(ℓ_i)} [Γ(A)/Γ(A+n)] Π_τ [Γ(α_τ + n_τ(ℓ))/Γ(α_τ)] · Π_i Q_{ℓ_i}(X_i),
  where A = Σ_τ α_τ and n_τ(ℓ) is the number of data labelled τ **[proved; computed: `c8_formulas.out` (1), exact to 10⁻¹² against quadrature]**.
* *Disjoint instance sets.* When the instance sets are pairwise disjoint, the sum has one term. The predictive rule is then P(X_{n+1} = s | D) = Σ_τ [(α_τ + n_τ)/(A + n)] Q_τ(s), the Krichevsky–Trofimov rule per template.
* *Normalisation.* P^Dir_T is an exchangeable probability on S^n for each n. Its normaliser is independent of D.

**L1 (derivation grammar).** Fix probabilities α_ax, α_lg, α_MP, α_Gen, α_∀E summing to 1, and α_r := α_MP + α_Gen + α_∀E. A random tree is grown from the root. Each node independently does one of the following:
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

The tree's code length −log₂ Pr(tree) is a derivation-length prior. Each rule application and each instantiated symbol costs bits, which is Hänni's "penalize longer proofs" made into a normalised generator. The two-part (MDL) approximation replaces the sum over trees by the maximum.

**Lemma 1.7 (L1 is proper; support) [proved, except the extinction criterion, which is known].**
(a) Let m := 2α_MP + α_Gen + α_∀E be the mean number of premises per node.
* The tree is finite a.s. iff m ≤ 1 [known: Galton–Watson extinction theorem, Athreya & Ney 1972 Ch. I (unverified numbering)].
* For m < 1 the expected number of nodes is 1/(1 − m) [proved].
* For m > 1 the tree is infinite with probability 1 − q > 0, where q is the least root of q = (α_ax + α_lg) + (α_Gen + α_∀E)q + α_MP q². Then μ_T is defective and P_T must be read as conditional on finiteness.

(b) Z_T ≥ α_ax + α_lg = 1 − α_r > 0, because a one-node tree is valid. So P_T is a probability with a data-independent normaliser.

(c) If all α's are positive, w > 0, Q has full support and the Gen parameter law has full support, then supp P_T = Th(T).

*Proof.*
* (a), expected size. Let N be the number of nodes. Then E N = 1 + m·E N, by conditioning on the root's rule and using linearity (the children are i.i.d. copies). If E N < ∞ this gives E N = 1/(1 − m). Finiteness of E N for m < 1 follows from the generation sizes: E[generation k] = m^k, and Σ_k m^k < ∞.
* (b). Immediate.
* (c), ⊆. Every valid tree is a K-derivation from inst(T), with ∀E replaced by an A4 instance and MP.
* (c), ⊇. Every K-derivation from inst(T) ∪ inst(Λ) is a tree of the grammar, and it has positive probability. Each citation has w_τ Q(θ) > 0. Each logical axiom instance has positive Q-probability, A4's term included. Each Gen has positive parameter probability. ∎

Computed **[computed: `c8_formulas.out` (2)]**:
* mean sizes 2.010 and 9.965 against 1/(1 − m) = 2 and 10;
* at m = 1, a heavy tail;
* at m = 1.1, P(finite) = 0.7489 against q = 0.75.

**L2 (bounded depth).** This is L1, except that at depth d a node must cite (α_ax, α_lg renormalised). Every tree is finite and no subcriticality is needed. P^{(d)}_T := μ^{(d)}_T / Z^{(d)}_T, with support Th_{≤d}(T), the conclusions of valid trees of depth ≤ d. This is the computable version used in `c6_L1_ident.py`.

**Hänni's variants as scores.** Data may carry labels D = D₊ ∪ D₋ (true, false).
* *Proves the givens.* S_prove(T; D) := 1[T consistent] · Π_{s∈D₊} 1[T ⊢ s] · Π_{s∈D₋} 1[T ⊢ ¬s].
* *Does not contradict.* S_nc(T; D) := 1[T ∪ D₊ ∪ ¬D₋ consistent].
* *Graded*, as in his "depend … on how many of the given statements can be proven" and "penalize longer proofs": S_g(T; D) := S_nc(T; D) · Π_{s∈D₊} g(ℓ_T(s)), with ℓ_T(s) the shortest derivation size (∞ if none), g decreasing, and g(∞) = β ∈ [0,1).

The posterior is π(T)·S(T; D). These are scores, not likelihoods: Σ_D S(T; D) is not 1 and depends on T.

### 1.6 The size principle

**Lemma 1.8 (size principle, exact form) [proved].** Let P*, P be probabilities on a countable S, and ε := P(S ∖ supp P*). Write P̃ := P(· | supp P*).
(a) KL(P* ‖ P) = KL(P* ‖ P̃) + ln(1/(1−ε)) ≥ ln(1/(1−ε)).
(b) For every data sequence in supp P*, P(D) = (1−ε)^n P̃(D), and E_{P*}[P̃(D)/P*(D)] ≤ 1.

*Proof.* On supp P*, P = (1−ε)P̃. Substitute into KL(P* ‖ P) = Σ_{s∈supp P*} P*(s) ln(P*(s)/P(s)). For (b), E_{P*}[P̃(X)/P*(X)] = Σ_{s∈supp P*} P̃(s) = 1, and use independence. ∎

So a hypothesis that puts mass ε outside the data's support loses at least ln(1/(1−ε)) nats per datum in expectation. It also loses exactly the factor (1−ε)^n against its own conditional version, on every data sequence. **[computed: `c1_size_principle.out`]** For T* = {z+0=z} against the over-general {z₁+0=z₂}, the decomposition holds to 10⁻⁹, and the simulated per-datum log-ratio 3.94 matches KL = H(Q) = 3.894 nats.

**Proposition 1.9 (which likelihoods have the size principle) [proved].**
(a) L0, L1 and L2 have it. Each P_T is a probability on S whose normaliser (1, Z_T, Z^{(d)}_T) does not depend on the data, so Lemma 1.8 applies to any T whose generator puts mass outside the data law's support. Under L0 with full-support Q, this is any T with ∪inst(T) ⊄ supp P*.
(b) Hänni's scores do not. Let Th(T) ⊆ Th(T').
* S_nc(T') ≤ S_nc(T): a weaker theory never scores lower under "does not contradict".
* If T' is consistent with the labelled data, S_prove(T') ≥ S_prove(T).
* If moreover ∪inst(T) ⊆ ∪inst(T'), then S_g(T') ≥ S_g(T): T' proves everything T proves, by derivations no longer.
* Consequence: for a consistent strengthening T' = T* ∪ {ψ}, with ψ independent of T* and never mentioned in the data, the posterior odds π_n(T')/π_n(T*) never fall below the prior odds under S_prove or S_g. Under S_nc they equal the prior odds, since both scores are 1.

(c) Generative likelihoods do penalise that strengthening (ψ ground, ψ ∉ Th(T*)).
* Under L0 with fixed weights (ψ's weight w_ψ, the others scaled by 1 − w_ψ), the likelihood ratio against T* is exactly (1 − w_ψ)^n on data not containing ψ.
* Under L1, P_{T'}(ψ) ≥ α_ax w_ψ while ψ ∉ Th(T*) = supp P_{T*}. So Lemma 1.8 gives exponential decay at rate at least ln(1/(1 − α_ax w_ψ)) per datum.
* With Dirichlet weights the ratio is ≈ n^{−α} (Prop 5.5(a)).

*Proof.* (a) is Lemma 1.8. (b): monotonicity of ⊢ in the axiom set, and of consistency (in the reverse direction). For S_g, inclusion of instances makes every derivation from T a derivation from T'. (c): direct computation under L0; for L1, Lemma 1.8 with ε ≥ μ_{T'}(ψ)/Z_{T'} ≥ α_ax w_ψ, using Z_{T'} ≤ 1. ∎

**Remark 1.10 (Hänni's graded score is an unnormalised L1).** Read 2^{−κℓ_T(s)} as an unnormalised likelihood μ_T(s). Normalising by Z_T := Σ_s 2^{−κℓ_T(s)} turns S_g into the MDL version of L1, and Z_T ≤ 1 by Kraft when κ ≥ 1 and ℓ_T is a prefix code length. A stronger theory has more short theorems, hence a larger Z_T, hence a smaller P_T(s) on each datum. That normaliser is exactly the size principle, and it is all that separates his graded score from a generative likelihood. His remark "you can probably equivalently think of this as there being some model for how the statements get generated" is right exactly when the score is divided by Z_T.

---
## 2. Consistency and identification (well-specified case)

**Setting W (well-specified).**
* **H** is a countable class; π is a prior with π(T) ≥ 0 and Σπ = 1.
* Each T ∈ **H** carries a fixed probability P_T on the countable set S. Weights are fixed here; Dirichlet weights are in §5.
* The data X_1, X_2, … are i.i.d. from P_{T*}, for some T* ∈ **H** with π(T*) > 0.
* Posterior: π_n(T) := π(T)P_T(X^n) / Σ_{T'} π(T')P_{T'}(X^n), defined whenever the denominator is positive.
* Generator class: C* := {T ∈ **H** : P_T = P_{T*}}.

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
* *L1* (Lemma 1.7(c)). supp P_T = Th(T). So the limit is 1[s ∈ Th(T*)] for d = ∞. For finite d it can differ: members of C* may need derivations of different length.
* *L2.* Only Th_{≤d} is determined.
* *Hänni's scores.* They are not generators, and nothing like Theorem 2.1 holds for them (Prop 1.9(b)).

**[computed: `c9_consistency.out`]** Class: T*, its root split, an over-general template, a split missing one root, and T* plus a spare ground template. Results:
* π_n(T*) = π_n(T_split) at every n, as Corollary 2.2 says.
* The other three go to 0. The spare is 2·10⁻⁵ at n = 1000, and 0.95^n exactly. The missing-root split dies at the first datum with root ·.

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

**[computed: `c6_L1_ident.out`]** This uses the propositional fragment (A1–A3 and MP, Q truncated to formulas of size ≤ 3, depth ≤ 2). It gives P_{T1}(b) ≈ 0.31–0.35 against P_{T2}(b) ≈ 0.02, and TV(P_{T1}, P_{T2}) between 0.16 and 0.35. Four parameter settings were tried; three lie outside the proved region, including α_MP = 0.4.

Corollary 2.2 implies that under W the posterior ratio between T1 and T2 is not fixed. It goes to 0 or ∞ (Prop 2.4(a)). So the posterior picks an axiomatisation, not only a theory. Which one it picks is decided by which generator produced the data, not by any logical criterion.

**Proposition 2.6 (when P_T = P_{T'} under L0) [proved].** Let Q have full support and all weights be positive.
(a) **Necessary condition.** P_{T,w} = P_{T',w'} implies ∪inst(T) = ∪inst(T'). Hence Th_d(T) = Th_d(T') for all d.
(b) **Splits are exact ties.**
  * Let τ ∈ T have a metavariable M whose PCFG factors at the root over a *finite* set R of root productions: Q_M(λz̄.r(β_1, …, β_a)) = p_r Π_j Q(β_j). Here a production r is a symbol with its children's types, or a hole, or a constant.
  * Let τ_r := τ[M := λz̄. r(N_1(z̄, …), …, N_a(z̄, …))], with fresh metavariables N_j of the child types (one more argument under a binder production).
  * Let T' := (T ∖ {τ}) ∪ {τ_r : r ∈ R}, with weights w'_{τ_r} := w_τ p_r and the other weights unchanged.
  * Then each τ_r ∈ DT°, and P_{T',w'} = P_{T,w}.
(c) **Single templates.** If τ ≡ τ' (renaming and argument permutation, `AS:lem:setting:renaming`) and Q treats holes symmetrically, then Q_τ = Q_{τ'}. Conversely, Q_τ = Q_{τ'} implies inst(τ) = inst(τ').
  * For τ, τ' ∈ FO under Rich, this gives τ ≡ τ' (`AS:prop:univ:determine`).
  * For DT° in general it is open whether inst(τ) = inst(τ') implies τ ≡ τ'. `AS:sec:setting:templates` leaves this open.

*Proof.*
* (a) supp P_{T,w} = ∪inst(T) by Lemma 1.6, and theorems depend only on instances (§1.2).
* (b), templates. Plugging the body into a pattern occurrence M(ȳ) gives r(N_1(ȳ, …), …). Each N_j has a pattern occurrence, because ȳ are distinct bound variables, and a binder adds one more distinct bound variable. Other occurrences of M receive the same body with metavariable-free arguments, which `AS:def:setting:template` allows. So τ_r ∈ DT°.
* (b), instances. inst(τ) = ⊔_r inst(τ_r). At a pattern occurrence of M the instance shows θ(M)'s root production, and distinct productions give distinct subtrees there; for hole productions z_i, the distinct bound variables y_i.
* (b), probabilities. For s ∈ inst(τ_r), let θ be τ's matcher for s. Then the matcher of τ_r gives the children's bodies of θ(M), and Q(θ) = p_r · Q_{τ_r}(s), by the root factorisation. Summing over the template's contribution gives w_τ Q_τ(s) = Σ_r w_τ p_r Q_{τ_r}(s).
* (c) Renaming permutes the factors of Q(θ), and argument permutation permutes the holes, which a hole-symmetric Q ignores. The converse is (a) for single templates. ∎

**[computed: `c2_split.out`, Part A]** For z + 0 = z and its four root splits over {0, S, +, ·}, the two generators agree to 10⁻¹⁹ on all 2849 instances with |t| ≤ 9. The check matches each instance against each template; it does not just use the algebra.

**Remarks.**
* *Splits under L1.* Prop 2.6(b) holds verbatim under L1 and L2. A citation node's conclusion has the same law under T and under its split, and a tree's validity and conclusion depend only on the conclusions of its nodes. So μ_T = μ_{T'} and Z_T = Z_{T'}. A derivation likelihood therefore does not separate a schema from its splits. This answers the brief's question whether a derivation-based likelihood changes the MDL finding of `AS:sec:many:mdl`: it does not (§5.3).
* *Which splits.* The split of T_Ind by the main connective of the motive (`AS:prop:many:mdlnaive`) is an instance of (b). The metavariable is P : ι → o, and the productions are the connectives, quantifiers and the relation symbols.
* *Exactness depends on Q.* The exact tie needs Q to factor at the root. If Q does not factor (for instance, a uniform law on bodies of each size), the split's generator differs, and either may fit better.

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

[known; bibliographic data and the main statements checked against the publishers' abstracts in a web search. The exact conditions were not read.] Remark 3.5 shows that their conclusion need not describe our countable class.

**Example 3.2 (all data are theorems of T*; the posterior concentrates on strictly weaker theories) [proved].**
* *Language and model.* L_A, under the λ convention with parameters *not* admissible as values, so instances are closed. Model: L0 with fixed full-support Q over finite DT° theories, and any prior with π(σ) > 0, where σ := {0 + z = z}.
* *Human.* The human's axioms are T* := {∀x(0 + x = x)}. The human states closed instances 0 + t = t with t ∼ Q. Each is a T*-theorem (A4, MP).
* *The data are well specified for σ.* P_H = P_σ, so Theorem 2.1 applies with truth σ, and π_n(C_σ) → 1.
* *No member of C_σ proves the axiom.* Every T ∈ C_σ has ∪inst(T) = inst_c(0 + x = x), the closed instances (Prop 2.6(a)), hence Th(T) = Th(inst_c). And ∀x(0 + x = x) ∉ Th(inst_c). Take the structure ℕ ∪ {a}, standard on ℕ, with 0 + a := 0 and the other operations extended arbitrarily, for instance Sa = a and a ∘ y = y ∘ a = a for ∘ ∈ {+, ·} except 0 + a = 0. Closed terms denote standard numbers, so every closed instance holds. The universal fails at a.
* *Conclusion.* By Corollary 2.3, P(T ⊢ ∀x(0+x=x) | D_n) → 0 a.s. The posterior moves away from the actual axioms, to a deductively weaker theory, on data consisting only of their theorems.

This is the ω-gap of `AS:sec:univ:omega` in Bayesian form. Under L0 it is forced by the likelihood, not by caution. Whether it persists under L1, where the human's generator might be well specified, is track "universal"'s question.

**Lemma 3.3 (sound templates cover at most one zero-sum equation) [proved].** Let Z := {t = 0 : t a closed term built from 0 and + only}. If τ ∈ DT° and every instance of τ is true in ℕ (parameters, if admissible, read universally), then τ covers at most one member of Z.

*Proof.* Let τ cover some t = 0 ∈ Z.
* *Shape.* The datum has no binders. So τ's rigid skeleton has none, and every metavariable is 0-ary: a pattern occurrence of positive arity needs bound variables in scope. The only formula position in t = 0 is the root.
* *Root metavariable.* Then τ = F, a formula metavariable, which has the false instance 0 = S0.
* *Otherwise* τ = (u = v), with u, v term templates. u matches t, so u's rigid nodes are + and 0, and its metavariable occurrences are leaves. Hence val(uθ) = Σ_j c_j val(θ(z_j)), where c_j is the multiplicity of z_j in u. v matches 0, so v is 0 or a metavariable z.
* *v = 0.* Soundness requires Σ_j c_j val(θ(z_j)) = 0 for all θ. Taking θ(z_j) = S0 shows c_j = 0 for all j. So τ is ground and covers one sentence.
* *v = z, z not in u.* The value of uθ does not depend on θ(z). One of θ(z) ∈ {0, S0} gives a false instance.
* *v = z, z in u.* Soundness requires Σ_j c_j val(θ(z_j)) = val(θ(z)) for all θ. Unit test values give c_z = 1, and c_j = 0 for j ≠ z. So u contains z once and is otherwise ground. Covering t = 0 forces θ(z) = 0, and τ covers exactly one member of Z, namely u[0/z] = 0. ∎

**Example 3.4 (finite class; the KL-minimiser is unsound) [proved; computed].**
* *Human.* The human's axioms are Q. The human states t = 0 with t random in Z, from a law P_H with infinite support. Each datum is true, hence a Q-theorem (Q decides closed equations [known]).
* *Class.* **H** := {T_1, …, T_m, T_esc}, with prior positive on all. Each T_j is any finite set of DT° templates all of whose instances are true. T_esc := {z = 0}. Likelihood L0 with full-support Q.
* *Claim.* A.s. π_n(T_esc) = 1 for all large n.
* *Proof of the claim.*
  * By Lemma 3.3 each T_j covers only finitely many members of Z. Since supp P_H is infinite, P_H(Z ∖ ⋃_j ∪inst(T_j)) > 0.
  * So a.s. some datum falls outside all of them. Then every T_j has likelihood 0, while P_{T_esc} > 0 on Z.
* *Consequence.* T_esc ⊢ S0 = 0, and Q ⊢ ¬(S0 = 0).
* *Adding Q does not help.* Adding Q itself to **H** under L0 changes nothing. Q's axioms are ground templates whose instance set contains no member of Z, so Q dies at the first datum.

**[computed: `c4_ville.out`, Part 2]** Twenty sound theories (the best possible: ground equations for the 20 most likely data, with weights equal to the human's conditional probabilities) against T_esc, with prior 0.99 on the sound ones. S0 = 0 reached posterior ≥ 0.99 in 2000/2000 runs, with median time 17 data.

**Remark 3.5 (the full countable class; the KL-projection picture can fail) [conjecture; computed illustration].**
* *Why the picture fails.* In the full class **H** with Dirichlet weights, the theories with finite KL to the human law of Example 3.4 are unsound (Lemma 3.3), and their infimum KL is 0. Approximating "hybrids" (memorise the frequent data, plus an escape template for the rest) have KL → 0. Pure memorisation theories are sound but have infinite KL each. Yet as a family they code the data with o(n) extra bits, so they beat any single theory with KL > 0. Theorem 3.1 says nothing here, and neither do the general results without their conditions.
* *Which wins.* Memorisation pays prior bits λℓ(s) once per distinct datum, plus a Dirichlet cost. A hybrid pays ln(1/w_esc) + ln(1/Q(t)) nats per occurrence of an unmemorised datum. In c7 the hybrid wins. **[computed: `c7_misspec_full.out`]** The lower bound on the hybrid's score exceeds memorisation's by 7 000–25 000 bits at n = 10⁴ for λ = 1 and 2, on three seeds.
* *Conjecture.* In Example 3.4 with the full class, the posterior mass of unsound theories tends to 1. The computation compares three hand-picked families and does not sum over **H**, so it is evidence, not a proof.

**Summary of §3.**
* Under misspecification the posterior follows the best *generator*, not the best *axioms*.
* The best generator can be deductively weaker (Example 3.2) or unsound (Example 3.4).
* In the finite case the target is the KL-minimiser. In the full template class, "best" is decided by the coding costs of rare data, and an over-general escape template is cheap.

---
## 4. Soundness against adaptive provers

**Protocol.** In each round, either a datum X_i arrives, or the prover submits a query q.
* The arrival schedule may be chosen by the prover.
* The verifier V_{δ,d} answers ACCEPT iff π_t({T : q ∉ Th_d(T)}) ≤ δ. Otherwise it may ESCALATE to a deterministic oracle that answers whether q ∈ Th_d(T*). The answer becomes a constraint that multiplies each T's weight by 1[q ∈ Th_d(T) ⟺ q ∈ Th_d(T*)].
* The posterior is π_t(T) ∝ π(T) Π_{i≤n(t)} P_T(X_i) Π_j c_j(T).
* d ≤ ∞ is the derivability bound used by the verifier ("bounded derivability").
* Let C*_d := {T : P_T = P_{T*}, Th_d(T) = Th_d(T*)} and W*_d := π(C*_d) ≥ π(T*).

**Theorem 4.1 (time-uniform soundness) [proved; this is `IL:thm:caution:ville`(b) adapted].**
* *Hypotheses.* Assume setting W (well-specified: the data are i.i.d. from P_{T*}, T* ∈ **H**), and δ ≤ W*_d δ'.
* *Conclusion.* There is an event G with P(G) ≥ 1 − δ', depending only on the data sequence, on which no prover ever gets accepted a sentence outside Th_d(T*), in any round.
* *Provers covered.* Randomised, adaptive, computationally unbounded, knowing T*, the verifier and the whole future data sequence, and choosing the arrival timing.

*Proof.* This is the proof of `IL:thm:caution:ville`(b) (`IL:app:caution:ville`, using `IL:lem:app:caution:ville`), in the class form of `IL:thm:informal:ville` (proof in `app-informal.tex`, `app:informal:verify`). The role of shadow-measurability there is played by the definition of C*_d. Let L_t(T) := Π_{i≤n(t)} P_T(X_i) Π_j c_j(T).
1. **C*_d keeps the target's likelihood.** For T ∈ C*_d: P_T = P_{T*}, and every constraint satisfies c_j(T) = c_j(T*) = 1, because Th_d(T) = Th_d(T*). So L_t(T) = L_t(T*), and with Z_t := Σ_T π(T)L_t(T)/L_t(T*) we get π_t(C*_d) = W*_d/Z_t. Here L_t(T*) > 0 a.s.
2. **Constraints only help.** Every c_j ≤ 1, so Z_t ≤ Z^H_{n(t)} pathwise, where Z^H_n := Σ_T π(T)Π_{i≤n}P_T(X_i)/P_{T*}(X_i) = M(X^n)/P_{T*}(X^n).
3. **Ville.** Z^H is a nonnegative supermartingale in σ(X_1..X_n) with Z^H_0 = 1: E[P_T(X)/P_{T*}(X)] ≤ 1, then Tonelli. By Ville's inequality the event G := {sup_n Z^H_n < 1/δ'} has probability ≥ 1 − δ'.
4. **Conclusion.** On G, π_t(C*_d) > W*_d δ' ≥ δ at every t. If q ∉ Th_d(T*), then q ∉ Th_d(T) for every T ∈ C*_d. So π_t({T : q ∉ Th_d(T)}) > δ, and q is not accepted. ∎

**Remarks on Theorem 4.1.**
* **The brief's H3 is confirmed.** It is the special case C*_d ⊇ {T*}: an invalid acceptance requires π_t(T*) ≤ δ, i.e. Z_t ≥ π(T*)/δ. That has probability ≤ δ/π(T*), uniformly over times and queries, because there is one global event and no union bound over queries.
* **It is a per-target guarantee.** It covers every T* with π(C*_d) ≥ δ/δ'. Under π_λ it covers every theory with λℓ(T*) ≤ log₂(δ'/δ). For long axiom systems the guarantee is weak: δ must be below 2^{−λℓ(T*)}δ'.
* **The constant δ ≤ W*δ' cannot be improved.** `IL:prop:caution:tight` is a two-hypothesis instance (read R as Th_d), so it transfers.
* **The hypotheses that matter.**
  * Well-specification of the *data law*, not only of the theorem set.
  * A proper prior that does not depend on n. A steeper penalty λ_n that grows with n (as in `inferential-learning/research/theory/T5-…`) makes π_n something other than a posterior. Step 3 then fails, and I have no replacement.
  * Truthful constraints.
* **Computability.** The theorem holds verbatim for any finite truncation **H**_N ∋ T* with the renormalised prior (W* only grows), for L2 likelihoods (finite sums) and for finite d (decidable Th_d). So a computable verifier with this guarantee exists for each truncation. An approximation that overestimates the non-deriving mass keeps soundness.

**Proposition 4.2 (misspecified: a non-theorem is accepted with probability 1) [proved; computed].**
* *Setting.* Example 3.4: human axioms Q; human data t = 0 with t ∈ Z; finite class of sound theories plus T_esc = {z = 0}; Q itself may be in the class.
* *Prover.* It submits S0 = 0 in every round (it does not even need to adapt).
* *Claim.* With probability 1 the verifier V_{δ,∞} accepts S0 = 0 at some finite time, for every δ > 0. And Q ⊢ ¬(S0 = 0).

*Proof.* Example 3.4: a.s. π_n(T_esc) = 1 eventually, and T_esc ⊢ S0 = 0. ∎

**[computed: `c4_ville.out`]**
* *Part 2 (misspecified).* Accepted in 2000/2000 runs, by n = 50 in 90%.
* *Part 1 (well-specified, for contrast).* The frequency of {∃n ≤ 300 : π_n(T*) ≤ δ} was 0.044, 0.014 and 0.004, against the Ville bounds 0.10, 0.033 and 0.010, for δ = 0.03, 0.01, 0.003 and π(T*) = 0.3.

In Example 3.2 the misspecification makes the verifier incomplete (it never accepts ∀x(0+x=x)), not unsound. In Example 3.4 it makes it unsound. Which happens depends on whether the best generator is weaker than T* or incomparable with it.

**Proposition 4.3 (the δ → 0 limit is the cautious verifier, read on theorems) [proved].** Suppose each P_T has a fixed support supp_T.
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
* *Setting.* Setting W, under L0 (full-support Q, any d) or under L1 (d = ∞).
* *Claim.* For every s ∈ Th_d(T*) and every δ > 0, V_{δ,d} accepts s at all sufficiently large n, almost surely.
* *Proof.* By Corollary 2.3 the non-deriving mass tends to π(C* ∩ {T : s ∉ Th_d(T)})/π(C*) = 0. Under these likelihoods all of C* has the theorems of T* (§2.1). ∎

**Relation to anchors.**
* The cautious verifier becomes exact only once the data contain an anchor (`AS:lem:setting:closed`(c)), and in a class with unbounded k it never generalises (Prop 4.3(c)).
* The Bayesian verifier needs neither an anchor nor a bound. The likelihood, not mere consistency, moves mass away from memorisation and from splits.
* What it gives up is deterministic soundness. Its soundness is probabilistic (1 − δ'), and it holds only for well-specified data and for targets of prior mass at least δ/δ'.
* The time to accept a given s is governed by the competitors that miss s. A split that omits a root of probability p gains a factor (1−p)^{−n} until the first datum with that root. This is the mechanism of `IL:prop:caution:tight`.
* The escalation bound `IL:thm:caution:bayesesc` transfers unchanged (with R* := C*_d).

---

## 5. Positive data, Gold, spare slots

### 5.1 Identification in the limit with probability 1

**Theorem 5.1 [proved, (b) via a known theorem; (c) conjecture].** Let **H** be all finite sets of DT° templates, with any prior positive on T*.
(a) **Fixed generators.**
* Let each T carry a fixed generator: L0 with fixed weights (full-support Q, positive weights), or L1 with fixed grammar parameters (all positive, m ≤ 1, full-support Q).
* Let the data be i.i.d. from P_{T*}.
* Let the learner output the language g_n := L if π_n({T : supp P_T = L}) > ½, and "?" otherwise.
* Then, almost surely, g_n = supp P_{T*} for all large n. That is ∪inst(T*) under L0, and Th(T*) under L1.
* No bound on the number of templates is needed.

(b) **Dirichlet-integrated weights.**
* Let the parameter be (T, w), with prior π(T)·Dir(w; α), and the data i.i.d. from P_{T*,w*}.
* Then for every T* with π(T*) > 0 and Lebesgue-almost every w*, π_n({(T, w) : P_{T,w} = P_{T*,w*}}) → 1 a.s.
* Hence the posterior mass of {T : ∪inst(T) = ∪inst(T*)} tends to 1. Dirichlet laws do not charge the boundary of the simplex, so supports are the full instance unions.

(c) **[conjecture]** (b) holds for *every* w* in the open simplex.

*Proof.*
* (a) Theorem 2.1, together with supp P_T = ∪inst(T) (Lemma 1.6) or supp P_T = Th(T) (Lemma 1.7(c)). When π_n(C*) > ½, g_n = supp P_{T*}.
* (b) Doob's theorem: for a Borel parameter space and a parameter that is a measurable function of the data sequence, the posterior is consistent at π-almost every parameter (Doob 1949; Ghosal & van der Vaart 2017, *Fundamentals of Nonparametric Bayesian Inference*, Thm 6.9) [known. The theorem number was confirmed only through a citing paper, not the book itself.]
  * Here the distribution P_{T,w} is a measurable function of the data, via the limit of empirical frequencies (step 2 of Theorem 2.1). The steps of the proof of Theorem 2.1 go through with the countable sum over **H** replaced by an integral.
  * "π-a.e." becomes "Lebesgue-a.e. w* for each T* with π(T*) > 0".
* (c) The open step is excluding spare templates at every w*. Schwartz's theorem (Schwartz 1965, *Z. Wahrsch.* 4:10–26 [known (unverified)]) gives weak consistency at every interior w*, since KL(P_{T*,w*} ‖ P_{T*,w}) ≤ max_τ ln(w*_τ/w_τ) → 0 as w → w*. But weak neighbourhoods contain T* plus a spare of small weight. Prop 5.5 handles single spares, and the sum over all spares is not controlled. ∎

**Why Gold's theorem does not bite, and where it still does.**

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
  * Both masses are presumably tiny, since they need long derivations with induction of high complexity. If so, the number of data needed is of order 1/P_PA(Th(PA) ∖ Th(IΣ_n)), which grows with n. This is a heuristic; I did not estimate the masses.

**Prior work.**
* Stochastic positive data plus a generator in the hypothesis go back to Horning (1969, PhD thesis, Stanford: identification of stochastic context-free grammars) [known (unverified details)].
* Angluin (1988, "Identifying languages from stochastic examples", Yale tech. report YALEU/DCS/RR-614) [known (unverified)]. My recollection: without assumptions tying the distribution to the hypothesis, identification with probability 1 is no stronger than identification from text; with such assumptions it is stronger. Theorem 5.1 is of the second kind. I could not check her exact statements in this session.

### 5.2 Memorisation and the bound

* *Memorisation dies.* Every fixed memorisation theory T_E (ground templates for a finite set E) has supp P_{T_E} = E. If supp P_{T*} is infinite, P_{T_E}(D_n) = 0 eventually, a.s. This is part of Theorem 2.1, so memorisation needs no separate treatment.
* *Before it dies.* Prior and likelihood also penalise it. Its prior is 2^{−λΣ_{s∈E}ℓ(s)}, and with Dirichlet weights its marginal likelihood is a Dirichlet-multinomial over |E| categories, which costs about (|E|−1)/2·ln n.

So the Bayesian needs no bound k. The cautious learner needs one (`AS:prop:many:bound`) because it uses only consistency, under which T_{D_n} is always a live hypothesis. The Bayesian uses likelihood, under which T_{D_n} is a live hypothesis with exponentially small weight.

### 5.3 Splits: the Occam terms and the MDL finding

By Prop 2.6(b) a schema and its root split are exact likelihood ties for fixed weights, under L0 and L1. With Dirichlet weights they are not ties: the split must learn the root distribution, which the unsplit template gets from Q.

**Proposition 5.4 (split against whole) [proved (Stirling); the χ² limit is known].**
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

**[computed: `c2_split.out`, Part B]** K = 4, α = ½, p = (.5, .3, .1, .1), 400 runs per n.
* *Well specified.* Mean Δ_n = −4.93, −8.34, −11.77, −15.27, −18.85 at n = 10², …, 10⁶, against the predictions −4.94, −8.39, −11.85, −15.30, −18.76. P(Δ_n > 0) = 0 from n = 10³ on.
* *Misspecified* (r = (.4, .3, .2, .1), KL = 0.0494 nats). Mean Δ_n = 39.7, 482, 4917, 49356 at n = 10³, …, 10⁶, against the predictions 39.5, 480, 4920, 49352.

**What this says about the MDL finding.**
* `AS:prop:many:mdlwell` is part (c) with a Bayesian code: a well-specified code gains at most O(log n) from splitting. `AS:prop:many:mdlnaive` is part (d): a code that cannot learn the root statistics splits by a linear margin.
* By the remark after Prop 2.6, all of this holds unchanged under the derivation likelihood L1, because splits are exact ties at the citation leaves. **A derivation-based likelihood does not change the MDL finding** [proved].
* What would change it is a richer, hierarchical Q, learned per template. Then the whole schema can learn r too, and the split's advantage reduces to context dependence of usage. The PC/DPC codes of `AS:tab:many:mdl` measure exactly this, and under the natural law G1 even DPC splits.
* In Bayesian terms: the posterior tracks the usage statistics, not the logical boundary of the schema, whenever the instantiation model is misspecified.

### 5.4 Spare templates

**Proposition 5.5 (cost of a spare template) [(a) proved; (b), (c) proof sketch; all computed].** Let the truth be (T*, w*) with Dir(α_τ) priors, A := Σ_{τ∈T*} α_τ, and a spare template σ with prior parameter α_σ. Let R_n := P^Dir_{T*∪{σ}}(D)/P^Dir_{T*}(D).
(a) **σ covers no datum.**
* If no datum of D lies in inst(σ), then, for every such D, exactly,
  R_n = Γ(A + α_σ)Γ(A + n) / (Γ(A)Γ(A + α_σ + n)) ~ [Γ(A+α_σ)/Γ(A)]·n^{−α_σ}.
* With α_σ = ½ the cost is ½·log₂ n bits plus a constant, plus the prior's λℓ(σ) bits.
* Disjointness need not hold for every instance: it is enough that the data avoid inst(σ). The case where σ overlaps the data is (b) and (c).

(b) **σ reaches outside the data's support.** If Q_σ(supp P*) = 1 − c with c > 0 and σ covers data, then ln R_n = −α_σ ln n + O_P(1).
(c) **σ is redundant** (inst(σ) ⊆ supp P*, Q_σ not in the span of T*'s components). Then ln R_n = −(α_σ/2) ln n + O_P(1).

*Proof of (a).*
* The labellings for T* ∪ {σ} are those for T* with n_σ = 0.
* For each labelling the Dirichlet moment ratio is [Γ(A+α_σ)/Γ(A+α_σ+n)]·Γ(α_σ)/Γ(α_σ) ÷ [Γ(A)/Γ(A+n)], the same for every labelling. Factor it out.
* Asymptotics: Γ(a+n)/Γ(b+n) ~ n^{a−b}. ∎

*Sketch of (b), (c).*
* *Reduction to one weight.* Write w = ((1−u)w̃, u), with u ~ Beta(α_σ, A) independent of w̃ ~ Dir(α_τ), by the aggregation property of Dirichlet laws. The per-datum factor is 1 − u + u·Q_σ(X)/P_{T*,w̃}(X).
* *(b).* At w̃ = w* its mean is 1 − uc, so the likelihood decays like e^{−ncu} in u. Then ∫u^{α_σ−1}e^{−ncu}du ~ Γ(α_σ)(cn)^{−α_σ}.
* *(c).* The mean is 1 (zero drift), and the log-likelihood in u is a local quadratic, −nIu²/2 + √n Z u. The integral against u^{α_σ−1} scales as n^{−α_σ/2}.
* *What is missing.* The steps not written out are uniformity in w̃ near w*, and the a.s. or in-probability control of the fluctuations. This is a boundary Laplace approximation, as in the overfitted-mixture analysis of Rousseau & Mengersen (2011, *JRSS B* 73(5):689–710) [known (unverified); their setting has continuous component parameters].

**[computed: `c3_spare.out`, `c3b_redundant.out`]** T* has two components; α = ½; c = 0.3.
* (a) The numerical integral matches the exact formula to 4 decimals at every n.
* (b) Fitted slope −0.498 against the prediction −0.5.
* (c) Fitted slope −0.346 on n ∈ [10², 10⁴], but −0.265 (standard errors ≈ 0.07 per point) on n ∈ [10³, 10⁷], against the prediction −0.25. The small-n slope is a transient.

**Reading.**
* *How fast spares vanish.* Spare templates vanish from the posterior polynomially, not exponentially, under Dirichlet weights. They vanish exponentially under fixed weights (Lemma 1.8).
* *The total over all spares.* Summed over all spares σ, the posterior mass of "T* plus one spare that covers no datum" is at most Σ_σ π(T* ∪ {σ})/π(T*) · R_n. That is O(n^{−α}) when Σ_σ 2^{−λℓ(σ)} converges (Lemma 1.4).
* *Spares do not threaten soundness.* For the verifier to accept an extra instance q ∉ R* of a spare, the theories containing it must hold mass ≥ 1 − δ. Theorem 4.1 excludes that with probability ≥ 1 − δ' under well-specification.
* *What spares cost is slow rejection.* With a REJECT option at threshold δ_r, q is rejected once the spare-containing mass falls below δ_r. That takes about (prior ratio/δ_r)^{1/α} data in case (b): polynomially many in the prior ratio and in 1/δ_r, against logarithmically many with fixed weights.
* *Contrast with the cautious learner.* There spare slots allow *splits*, which block acceptance of target instances and cost data *diversity* (`AS:thm:many:splits`). The Bayesian analogue of that incompleteness is not the spare template but the competitor that misses a type of target instance. Its cost is set by the frequency of that type: it gains (1−p)^{−n} until the first datum of the missing type (§4, "relation to anchors").

### 5.5 What the Bayesian gives up, compared with the cautious learner

| | cautious k-union verifier (`AS`) | Bayesian thresholded verifier (this track) |
|---|---|---|
| assumptions for soundness | realizability (target in **H**_k), bound k ≥ k' | well-specification of the generator, prior mass ≥ δ/δ' |
| soundness | deterministic, every prover, every time | probability ≥ 1 − δ', every prover, every time (Thm 4.1) |
| without the assumptions | sound relative to the closure cl(R*) (`AS:lem:setting:closed`); without a bound it accepts only the data | can accept a false sentence with probability 1 (Prop 4.2) |
| completeness | exact once an anchor is present | each theorem eventually, a.s. (Prop 4.4); no anchor, no bound |
| splits | sound splits survive any negatives (`AS:thm:many:splits`) | exact likelihood ties; Occam terms decide; usage statistics can reverse (Prop 5.4) |
| guarantee depends on the target's length | no | yes: δ ≤ 2^{−λℓ(T*)}δ' |

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

The computation of f moves either into the *proofs* (A_f: a derivation of φ must prove Acc_f(⌜φ⌝)) or into the *axiom length* (A^C_f: the axiom φ^{∧(k+1)} has length about k|φ|). Both are counted by derivation size, which is what a derivation-length likelihood (L1, Remark 1.10) penalises. The next theorem shows that no theory escapes this.

**Theorem 6.7 (derivation size bounds the assigner's nondeterministic time) [proved].**
* *Setting.* Let L contain 0, S, +, · and a unary predicate R. Let X ⊆ {0,1}* be a language, and φ_w := R(ν(w)), where ν(w) is a binary numeral term for w. Let f_X accept φ_w if w ∈ X and reject it otherwise. Then Γ_{f_X} is consistent: interpret R as X.
* *Hypotheses.* Let T be any axiom set whose membership is decidable in time polynomial in the length of the candidate axiom, with T ∪ Γ_{f_X} consistent. Suppose that every φ_w with w ∈ X has a K-derivation from T of size at most ℓ(|w|), where ℓ(m) ≥ m is time-constructible.
* *Claim.* X ∈ NTIME(ℓ(m)^c) for a constant c that depends only on the proof-checking overhead of K and T.

*Proof.*
* *Algorithm.* On input w, guess a derivation of size ≤ ℓ(|w|) and check it. The checks are: K's axiom instances (A4 needs first-order matching, which is polynomial), MP and Gen steps, and T-membership. All are polynomial in the derivation's size. Accept iff the derivation is valid and ends in φ_w.
* *Completeness.* If w ∈ X, such a derivation exists by hypothesis.
* *Soundness.* If w ∉ X, then ¬φ_w ∈ Γ_{f_X}. So T ⊢ φ_w would make T ∪ Γ_{f_X} inconsistent. Hence no derivation exists. ∎

**Corollary 6.8 (hard assigners force long derivations, for every theory) [proved, modulo the nondeterministic time hierarchy theorem].**
* *Claim.* Let s(m) ≥ m be time-constructible, and c as in Theorem 6.7. There is a decidable X such that every T as in Theorem 6.7 needs, for infinitely many m, a derivation of size > s(m) for some w ∈ X of length m.
* *Input.* The nondeterministic time hierarchy theorem (Cook 1972; Seiferas, Fischer & Meyer 1978, *JACM* 25:146–167; Žák 1983, *TCS* 26:327–333) [known (unverified exact form)] gives a language X ∈ NTIME(s') ∖ NTIME(s^c) for a larger time-constructible s'. Such an X is decidable. For fixed s it has a fixed program, so K(f_X) is a constant.
* *Proof.* Suppose that for all but finitely many m every w ∈ X of length m has a derivation of size ≤ s(m). Handle the finitely many exceptional lengths by a table. Then Theorem 6.7 with ℓ = s gives X ∈ NTIME(s^c), a contradiction. ∎

**Upper bound for the collapse constructions [proof sketch].**
* *A^C_f.* Each derivation of φ is "cite φ^{∧(k+1)}, then ∧-elimination", of size poly(k|φ|) with k = time_f(φ).
* *A_f (two-sorted).* A derivation is a Q-proof of the true Σ₁ sentence Acc_f(⌜φ⌝), then MP. A Q-proof of a true Σ₁ sentence of this kind has size polynomial in the length of the computation [known (unverified); see Pudlák 1998, "The lengths of proofs", *Handbook of Proof Theory*].
* *Template version (Prop 6.5).* The same, plus the Tarski biconditional for φ.

**Proposition 6.9 (L1 charges derivation size per datum) [proof sketch].**
* *Claim.* Under L1 with subcritical parameters, −ln P_T(φ) ≥ κ·ℓ_min(φ) − ln(C/Z_T) for constants κ, C > 0 that depend on the grammar. Here ℓ_min(φ) is the least size of a derivation of φ from T.
* *Sketch.* P_T(φ) ≤ Pr[the tree's total size ≥ ℓ_min(φ)]/Z_T. The total size of a subcritical Galton–Watson tree, with bounded offspring and subcritical instantiation grammars, has an exponentially decaying tail [known (unverified form): the total progeny of a subcritical Galton–Watson process whose offspring law has exponential moments has an exponential tail (Otter–Dwass)].

**What the time penalty does: the precise statement.** Combining the above:
1. **Membership- and generation-time penalties do not block the collapse.** Theorem 6.1 with Craig's sets and Prop 6.6: they change Hänni's equivalence by an additive constant at most.
2. **The template restriction blocks Hänni's schema (Prop 6.4) but not the collapse.** In arithmetic, one ground reflection sentence over PA gives every Σ_n-sound assigner, with linear overhead (Prop 6.5).
3. **A derivation-size penalty does separate the inducers.**
   * Any axiom set with polynomial-time membership, template or not, needs derivations whose size is, infinitely often, at least the nondeterministic time of the assigner's language, up to a polynomial (Theorem 6.7, Corollary 6.8). Under a derivation-size penalty that is a per-datum cost: under L1 at least κ·s(m) nats on those data (Prop 6.9), and under Hänni's graded score with g(ℓ) = 2^{−κℓ} at least κ·s(m) bits.
   * The collapse constructions pay at most a polynomial of the assigner's deterministic running time (upper bound above).
   * Function induction's cumulative log loss on f_X's labels is at most |f_X| bits, a constant, because W_FI(D_n) ≥ 2^{−|f_X|}.

So the clean theorem is the negative half. No membership-time penalty blocks the collapse, while a derivation-length penalty prices it per datum, between nondeterministic and deterministic time. I found no clean equivalence for the derivation-penalised inducer. Its exact relation to a time-bounded function inducer (Hänni's polytime Solomonoff, `../../prior/hanni-polytime-solomonoff.md`) is open (§10).

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

**[computed: `c5_trichotomy.out`]**
* *Examples 7.4 and 7.5.* Linear programming confirms that both are incoherent.
* *Random trials.* 300 random posteriors over random consistent theories on 3 atoms (256 sentences up to equivalence).
  * No violation of 2- or 3-monotonicity of Bel was found.
  * No failure of the bracketing of Prop 7.3 was found.
  * Renormalisation was incoherent in 90 of 300 trials, the 50/50 rule in 290 of 300. The coherent cases are essentially those where every theory is complete.

**Answers to Hänni's questions in his note.**
* "i guess you could also naturally just get true/false by … removing the independent fraction and renormalizing". This is incoherent in general (Example 7.4), confirming his "i guess we probably usually don't get coherent probabilities either".
* "instead of renormalizing, you could also turn the independent fraction into 50/50 … not giving coherent probabilities usually". Confirmed (Example 7.5). It fails already with one theory.
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

This is the general statement; track "universal" does the case of ∀xφ.

**Theorem 8.1 [proved, from §2].** Assume setting W.
(a) **Predictions merge, whatever the deductive questions.** The predictive law M_n satisfies Σ_n E KL(P_{T*} ‖ M_n) ≤ ln(1/π(C*)) (Prop 2.4(b)).
(b) **Deductive beliefs converge to the generator class's prior-weighted vote.** π_n(T ⊢ s) → π(C* ∩ {T ⊢ s})/π(C*) (Corollary 2.3). This equals 1[T* ⊢ s] iff C*'s members agree on s up to prior-null sets.
  * They agree when the generator determines the theorem set (L0 with full support, L1).
  * They need not agree under L2, under generators that reveal only part of the theory, or under any generator whose support is smaller than Th(T).
(c) **Finite n.** Let T_1 ⊢ s, T_2 ⊬ s, and data from P_{T_1}.
  * The expected posterior log-odds of T_1 against T_2 grow by exactly KL(P_{T_1} ‖ P_{T_2}) per datum.
  * The two generators are within total variation (KL/2)^{1/2} (Pinsker), so their per-datum predictions differ by at most that much.
  * So when two theories differ in what they prove but hardly in what they generate, the predictive question "what will the next datum look like" is nearly settled after a few data, while the deductive question stays near its prior odds for about 1/KL data.

*Proof.* (a) and (b) are restated. (c): E ln[P_{T_1}(X)/P_{T_2}(X)] = KL, summed over the data; Pinsker's inequality. ∎

**Under misspecification** (finite class, Theorem 3.1):
* Predictions converge to the KL-projection.
* Deductive beliefs converge to the projection's theorems, which can be weaker than the human's (Example 3.2) or unsound (Example 3.4).
* Predictions still compete with every member of the class: M(X^n) ≥ π(T)P_T(X^n) gives cumulative log loss at most that of any T plus ln(1/π(T)), on every sequence. But predictive success then certifies nothing deductive: the best predictor in the class can be a weaker or an unsound theory.

**Relation to the user's ∀xφ case** (stated generally, details in track "universal"):
* "All future data are φ-instances" is a predictive statement, settled by (a).
* "The axioms prove ∀xφ" is a deductive statement, settled by (b) only as far as the generator class agrees.
* Under L0 with closed instances, the generator class is "the instance schema", which does not prove ∀xφ (Example 3.2).
* The analogous fact for Solomonoff's universal prior and universal hypotheses is Hutter (2007, "On universal prediction and Bayesian confirmation", *TCS* 384:33–48) [known (unverified details)]: the universal prior confirms "all future observations are black" in the predictive sense.

---
## 9. Answers, and relations to Hänni's note

### 9.1 The brief's hypotheses

| hypothesis | verdict | where |
|---|---|---|
| **H1** model (templates, prior, derivation grammar, size principle from data-independent normalisation) | adopted and made precise. L1 is proper iff m ≤ 1. Hänni's scores lack the size principle; his graded score becomes L1 once normalised | §1, Lemma 1.7, Prop 1.9, Rem 1.10 |
| **H2** concentration on {P_T = P_{T*}}; identification of the generator; misspecification goes to the KL-minimiser | confirmed. Doob, direct proof; inside the class the posterior equals the prior. Refined: under L0 and L1 splits are exact ties, so the generator class contains different axiomatisations. KL-minimiser: proved for finite classes. Can fail to describe the full class | Thm 2.1, Cor 2.2, Prop 2.5, 2.6, Thm 3.1, Rem 3.5 |
| **H3** thresholded verifier sound w.p. ≥ 1 − δ/π(T*) against adaptive provers; δ → 0 is the cautious verifier | confirmed, with exact hypotheses: well-specified data law, proper n-independent prior. The constant improves to π(C*_d). Misspecified counterexample with acceptance probability 1. The δ → 0 limit is the theorem-level version-space verifier | Thm 4.1, Prop 4.2, 4.3 |
| **H5** stochastic positive data plus size principle get around Gold; spare slots cost about ½ log n bits | confirmed. Identification of the instance or theorem set with probability 1, with no bound. Gold still applies on a null set of texts. Disjoint spare: exactly ≈ n^{−α} (½ log₂ n bits at α = ½). Overlapping and outside: ≈ n^{−α}. Redundant: ≈ n^{−α/2} | Thm 5.1, Prop 5.2, 5.5 |
| **H6** a time penalty on membership prices the collapse schema | **refuted**: membership is polynomial without running T. What prices the assigner is derivation length (Theorem 6.7) | Prop 6.6, Thm 6.7 |

### 9.2 The user's question, at the level of this track

* **"Once we see all these other statements, we should up the probability on ∀xφ."**
  * Under a generative likelihood with the size principle, data move mass away from memorisation and from over-general templates, exponentially with fixed weights (Lemma 1.8, §5.2).
  * Between theories that generate nearly the same data but prove different things, the data move mass only at rate KL per datum (Thm 8.1(c)), and in the limit only as far as the generator class disagrees (Corollary 2.3).
  * Whether ∀xφ itself gains is track "universal"'s question. Example 3.2 shows that under L0 with closed instances it does not.
* **"Not just any enumerable axioms, but ones with templates."**
  * Templates make matching linear and block Hänni's collapse *schema* (Prop 6.4).
  * They do not make the posterior see schema boundaries: splits are exact ties (Prop 2.6(b)), decided by Occam terms or by usage statistics (Prop 5.4).
  * In arithmetic they do not block the collapse at the level of theorems (Prop 6.5).
* **"A derivation length prior."**
  * L1 is that prior, normalised. Normalisation is what supplies the size principle (Remark 1.10).
  * It is also the only one of the proposed penalties that prices computation (Theorem 6.7, Prop 6.9).
* **"A time complexity penalty for generating or checking axioms."** It does not bite: the collapse constructions have polynomial membership (Prop 6.6).
* **"Robustly picks up the axioms we actually have, or something equivalent in theorems, or at least a lot of posterior mass."**
  * *Well specified.* The theorem set is identified (L1), or the instance set (L0). The axiom set is identified up to its generator class, in which the posterior is the prior (Corollary 2.2).
    * So the actual axioms get asymptotic mass π(T*)/π(C*) under fixed weights.
    * With Dirichlet weights and a well-specified Q, the posterior odds of their splits against them fall like n^{−(K−1)/2} (Prop 5.4(c)).
  * *Robustly: no.* If human usage differs from Q, splits win linearly (Prop 5.4(d)). If humans state derived theorems that the model does not generate, the posterior goes to the best generator, which can be weaker (Example 3.2) or unsound (Example 3.4). And the soundness guarantee is lost (Prop 4.2).

### 9.3 Hänni's note, point by point

* **Two variants.** As scores they are monotone in the theory's strength (Prop 1.9(b)), so they never penalise a consistent strengthening. "Posterior weight depend[ing] … on how many of the given statements can be proven" plus "penalize longer proofs", divided by its T-dependent normaliser, is L1 (Remark 1.10).
* **Trichotomy.** It is a belief/plausibility pair. Both point estimates he considers are incoherent; keeping the triple is coherent (§7).
* **Equivalence.** True, with the constant he expects, in the semimeasure convention and via Craig's trick. Via his schema it holds in a two-sorted reading, and fails for some consistent assigners over PA in a single sort (Thm 6.1, Props 6.2, 6.3). His "easy" separation of unrestricted function induction from axiom induction is Prop 6.0.
* **His conclusion, and the restriction to substitution schemas.** The restriction blocks his schema (Prop 6.4). It does not block a reflection sentence (Prop 6.5). A time penalty must sit on derivations, not on axiom checking (§6.4).
* **"Other ideas for how to fix axiom induction".**
  * *"generate only a very small subset of observations"*: this is what a generative likelihood with data-independent normaliser does. The theory need not produce its theorems with appreciable probability, and normalisation charges it for what it does produce.
  * *"allow some mistakes"*: a noise mixture P = (1−η)P_T + ηN. Theorem 4.1 still holds if the noise model is part of the well-specified generator. Systematic mistakes are misspecification (§3; `inferential-learning/research/theory/T1-…` §6).
  * *"grade near misses"*: not treated here.
* **Polytime Solomonoff note.** The derivation-bounded L2 inducer with a growing depth budget is the analogue of his time-capped mixture. A constant-regret theorem against theories whose data have derivations within the budget plausibly follows by his argument [conjecture; not written out].

---

## 10. Open problems

1. **Spares at every w*.** Is Theorem 5.1(b) true for every interior w* (Theorem 5.1(c))? This needs control of the sum over all spare templates, not just one (Prop 5.5).
2. **Rigorous spare rates.** Make Prop 5.5(b),(c) rigorous: boundary Laplace asymptotics for a mixture with known components and a weight at the boundary.
3. **The full class under misspecification.** For the human law of Example 3.4, does the posterior mass of unsound theories tend to 1 (Remark 3.5)? More generally, which conditions of Kleijn–van der Vaart type hold for template classes with memorisation in them?
4. **The general L1 identification statement.** Is P_{T1} ≠ P_{T2} under L1 for all grammar parameters in Prop 2.5? A route: P_T(s) is a power series in the rule probabilities with nonnegative coefficients, so the difference is real-analytic on the subcritical region, and nonzero near α_r = 0. Analyticity in a neighbourhood of every point is not checked.
5. **Identification of single templates.** Does Q_τ = Q_{τ'} (or inst(τ) = inst(τ')) imply τ ≡ τ' in DT°? This is open in `AS` as well.
6. **Lemma 1.2(b).** Write out the full proof.
7. **Theorem-level caution.** Is the inclusion V_{0,d} ⊇ Th_d(Acc_k(D)) ever strict for **H**_k(DT°) (Prop 4.3(d))?
8. **The derivation-penalised inducer.** Is axiom induction with a derivation-size penalty equivalent, up to polynomial factors, to function induction over consistent assigners with short certificates (an NP-like class), in the way Theorem 6.1 is exact without penalties? Theorem 6.7 is the lower half. The upper half for Hänni's and Craig's constructions is deterministic time, not nondeterministic.
9. **Single-sorted repair.** Is there a single-sorted repair of Hänni's schema for consistent but unsound assigners, short of Craig's trick? Prop 6.5 covers Σ_n-sound assigners only.
10. **Craig sets in DT°.** For which assigners f is A^C_f, or some set with the same consequences and polynomial membership, a finite union of DT° templates?
11. **Robust versions.** Tempered or SafeBayes posteriors, explicit noise models, and Hänni's near-miss grading, and what each does to Theorem 4.1 under misspecification.

---

## References

Known results are cited from memory unless marked otherwise. In this session I checked the bibliographic data of Berk 1966, Kleijn & van der Vaart 2006, Ghosal & van der Vaart's Theorem 6.9 and Žák 1983 by web search (abstracts and catalogue records only). I opened no full text.

* Angluin, D. (1980). Inductive inference of formal languages from positive data. *Information and Control* 45:117–135.
* Angluin, D. (1988). Identifying languages from stochastic examples. Yale Univ. tech. report YALEU/DCS/RR-614. (unverified content)
* Athreya, K. B., & Ney, P. E. (1972). *Branching Processes*. Springer. (Galton–Watson extinction; unverified numbering)
* Berk, R. H. (1966). Limiting behavior of posterior distributions when the model is incorrect. *Ann. Math. Statist.* 37(1):51–58. doi:10.1214/aoms/1177699597. (abstract checked; the conditions were not read)
* Boolos, G., Burgess, J., & Jeffrey, R. *Computability and Logic*. (Σ₁-completeness of Q; unverified chapter)
* Cook, S. A. (1972). A hierarchy for nondeterministic time complexity. *STOC '72*.
* Craig, W. (1953). On axiomatizability within a system. *J. Symbolic Logic* 18(1):30–32.
* Doob, J. L. (1949). Application of the theory of martingales. *Colloques Internationaux du CNRS* 13:23–27.
* Ghosal, S., & van der Vaart, A. (2017). *Fundamentals of Nonparametric Bayesian Inference*. CUP. (Doob's theorem as Thm 6.9, confirmed via a citing paper only)
* Gold, E. M. (1967). Language identification in the limit. *Information and Control* 10:447–474.
* Hájek, P., & Pudlák, P. (1993). *Metamathematics of First-Order Arithmetic*. Springer. (partial truth predicates; unverified numbering)
* Horning, J. J. (1969). *A Study of Grammatical Inference*. PhD thesis, Stanford. (unverified details)
* Hutter, M. (2007). On universal prediction and Bayesian confirmation. *Theoretical Computer Science* 384(1):33–48. (unverified details)
* Kaye, R. (1991). *Models of Peano Arithmetic*. OUP.
* Kleijn, B. J. K., & van der Vaart, A. W. (2006). Misspecification in infinite-dimensional Bayesian statistics. *Ann. Statist.* 34(2):837–877. doi:10.1214/009053606000000029; arXiv math/0607023. (abstract checked; the conditions were not read)
* Krichevsky, R., & Trofimov, V. (1981). The performance of universal encoding. *IEEE Trans. IT* 27(2):199–207.
* Mendelson, E. *Introduction to Mathematical Logic*, Ch. 2. (system K, completeness; edition and numbering unverified)
* Pudlák, P. (1998). The lengths of proofs. In *Handbook of Proof Theory*, Elsevier. (unverified)
* Rousseau, J., & Mengersen, K. (2011). Asymptotic behaviour of the posterior distribution in overfitted mixture models. *JRSS B* 73(5):689–710. (unverified)
* Schwartz, L. (1965). On Bayes procedures. *Z. Wahrscheinlichkeitstheorie verw. Geb.* 4:10–26. (unverified)
* Seiferas, J., Fischer, M., & Meyer, A. (1978). Separating nondeterministic time complexity classes. *JACM* 25(1):146–167.
* Shafer, G. (1976). *A Mathematical Theory of Evidence*. Princeton.
* Tenenbaum, J. B., & Griffiths, T. L. (2001). Generalization, similarity, and Bayesian inference. *Behavioral and Brain Sciences* 24:629–640. (the size principle)
* Ville, J. (1939). *Étude critique de la notion de collectif*. Gauthier-Villars.
* Waudby-Smith, I., & Ramdas, A. (2020). Confidence sequences for sampling without replacement. *NeurIPS*. (prior–posterior-ratio martingale; as cited in `IL`)
* Žák, S. (1983). A Turing machine time hierarchy. *Theoretical Computer Science* 26(3):327–333. (volume and pages found in a library catalogue; journal inferred)

Internal: `../../../axiom-schemas/paper/sections/{setting,universal,many,app-many}.tex`; `../../../inferential-learning/paper/sections/{caution,app-caution,informal,app-informal}.tex`; `../../../inferential-learning/research/theory/{T1,T5}-…md`; `../../../axiom-schemas/research/conversation.md` §§3–9; `../../prior/*.md`.

---

## Verification log

All checks below were done by me, in this track, during one session. No independent referee has read these notes, and nothing is checked in a proof assistant.

**Scripts** (all in `checks/`, seeded, each writing `<name>.out` next to itself; `terms.py` is a shared helper for closed terms and PCFGs):

| script | checks | result |
|---|---|---|
| `c1_size_principle.py` | Lemma 1.8 decomposition KL = KL(P* ‖ P̃) + ln 1/(1−ε) for z+0=z against z₁+0=z₂; simulated per-datum log-ratio | identity to 10⁻⁹ on the truncated space; simulated 3.94 against exact H(Q) = 3.894 nats (the truncated value 2.62 misses the tail, as noted in the output) |
| `c2_split.py` | Prop 2.6(b) by genuine matching on all 2849 instances with \|t\| ≤ 9; Prop 5.4 Dirichlet comparison, well- and misspecified, n = 10²…10⁶, 400 runs each | max difference 1.1·10⁻¹⁹; means within 0.1 of the Stirling prediction (well specified) and within 0.1% (misspecified) |
| `c3_spare.py` | Prop 5.5 (a)–(c), numerical 2-D integration, n = 10²…10⁴ | (a) matches the exact Γ-formula to 4 decimals; (b) slope −0.498 (prediction −0.5); (c) slope −0.346 (prediction −0.25), see c3b |
| `c3b_redundant.py` | Prop 5.5(c) at n = 10³…10⁷ with adapted grids, 60 runs per n | slope −0.265 (s.e. per point ≈ 0.07), consistent with −0.25; the c3 slope was a small-n transient |
| `c4_ville.py` | Thm 4.1 (well specified, 20 000 runs) and Prop 4.2 / Example 3.4 (misspecified, 2000 runs) | frequencies 0.044, 0.014, 0.004 ≤ bounds 0.10, 0.033, 0.010; misspecified acceptance of S0 = 0 in 2000/2000 runs, median time 17 |
| `c5_trichotomy.py` | Props 7.2, 7.3, Examples 7.4, 7.5 by LP on 2–3 atoms; 300 random posteriors | 0 violations of 2-/3-monotonicity and of the bracketing; both examples infeasible; renormalisation incoherent in 90/300 trials, 50/50 in 290/300 |
| `c6_L1_ident.py` | Prop 2.5 under L2 (depth 1, 2), 4 parameter settings, propositional fragment | TV(P_{T1}, P_{T2}) between 0.16 and 0.35 at every setting, including three outside the proved region |
| `c7_misspec_full.py` | Remark 3.5, restricted comparison (memorisation, escape, hybrid lower bound) | hybrid beats memorisation by 7 000–25 000 bits at n = 10⁴ (λ = 1, 2; 3 seeds). Evidence only |
| `c8_formulas.py` | the L0 Dirichlet labelling-sum formula (exact quadrature and Monte Carlo); Lemma 1.7 (branching-process mean size, extinction) | closed form = quadrature to 10⁻¹² (Monte Carlo within 2 s.e.); mean sizes 2.010, 9.965 against 2, 10; P(finite) 0.7489 against q = 0.75 |
| `c9_consistency.py` | Thm 2.1, Cor 2.2 on a five-theory class | π_n(T*) = π_n(T_split) at every n; over-general, missing-root and spare theories go to 0 as predicted |

**References checked by web search** (abstracts and catalogue records only): Berk 1966 and Kleijn & van der Vaart 2006 (bibliographic data and main statements match the use in §3), Ghosal & van der Vaart's Thm 6.9 as Doob's theorem (via a citing paper), and Žák 1983 (volume and pages). All other references are from memory and are marked.

**Proofs written in full here:** Lemmas 1.2(a), 1.4, 1.6, 1.7 (except the extinction criterion), 1.8; Prop 1.9; Thm 2.1; Cors 2.2, 2.3; Props 2.4, 2.5 (proved region), 2.6; Thm 3.1; Example 3.2; Lemma 3.3; Example 3.4; Thm 4.1; Props 4.2, 4.3, 4.4; Thm 5.1(a); Props 5.2, 5.4, 5.5(a); Prop 6.0; Thm 6.1; Props 6.2, 6.3 (given standard formalisation), 6.4, 6.5 (given partial truth predicates), 6.6; Thm 6.7; Cor 6.8 (given the hierarchy theorem); Props 7.1–7.3; Examples 7.4, 7.5; Thm 8.1.

**Proof sketches only:** Lemma 1.2(b); Prop 5.5(b),(c); the upper bounds on collapse derivation sizes (§6.4); Prop 6.9.

**Conjectures:** Thm 5.1(c); Remark 3.5; the polytime analogue in §9.3; open problems in §10.

**Refuted:** the brief's H6 sentence "A schema 'T(⌜φ⌝) = accept → φ' requires running T to check membership" (Prop 6.6(a)). Also Hänni's consistency argument for his schema in a single-sorted setting (Prop 6.3). His *conclusion*, the equivalence, survives via Craig (Thm 6.1).

**Self-checks that changed the notes during writing:**
* Prop 4.3(d) first claimed strictness of the theorem-level inclusion for PA induction splits. On checking conv §7, splits that learn one connective class fully have the same theorems as the instance-level intersection. I replaced the claim by a strictness example in a general class and left the DT° case open (§10, item 7).
* Lemma 1.2 first claimed, without proof, that no SO template has the instances of A4. I split it into the definitional part (proved) and the finite-union claim (sketch).
* Prop 5.5(c): the first computation's slope (−0.35) disagreed with the sketch (−0.25). Running to n = 10⁷ (c3b) gave −0.265, so the sketch stands and the discrepancy was a transient.
* Example 3.4: I first expected the full-class posterior to concentrate on the escape template. The coding argument of Remark 3.5 shows that memorisation and hybrids compete, so I restricted the proved statement to finite classes.
