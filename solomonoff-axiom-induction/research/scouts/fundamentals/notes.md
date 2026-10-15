# Scout F (fundamentals): definitions and basic theorems for Solomonoff axiom induction

Working name only ("Solomonoff axiom induction"); nothing below depends on it. Folder: `research/scouts/fundamentals/`. Script: `checks/c1_toy.py`, output `checks/c1_toy.out` (seed 20261015).

**Statuses.** Each claim has one of the following tags:
* **[proved]**: a full proof is given here;
* **[proved, given X]**: proved here from a cited fact X;
* **[known: ref]**: from an exact reference, with its verification status given in §8;
* **[proof sketch]**;
* **[conjecture]**;
* **[computed: c1 part]**: from the seeded script;
* **[refuted]**: kept with its counterexample.

**Pointers.**
* "AI" is the earlier report `../axiom-induction/paper/main.pdf`, cited by its printed numbers (AI Thm 6.3), with the research record in parentheses (model §6.1).
* "AS" is `../axiom-schemas/paper/main.pdf`.
* "P1" is SFI Paper 1, `../solomonoff-function-induction/paper/main.pdf`, also cited by printed numbers.
* Logarithms are base 2. c, c′ are constants that depend only on the fixed universal machines, the coding of syntax and the background B.

---

## 0. Summary

**The primary definition (§2).**
* A *theory machine* reads one random tape and enumerates axioms. Formally it is any c.e. set G ⊆ {0,1}* × Sent_L. Unlike P1's function machines, it needs no consistency condition.
* The *universal theory machine* G_U reads a self-delimiting program from the tape, then runs that machine on the rest of the tape.
* Its random axiom set A_ω generates a random r.e. theory Cn(B ∪ A_ω).
* **Proof-requiring weight:** M_A(D) := Pr_ω[B ∪ A_ω is consistent and proves every labelled datum of D].
* **Predictive probabilities.** For a new sentence φ after data D:
  * "true": Bel_D(φ), the posterior mass of random theories that prove φ;
  * "false": Bel_D(¬φ);
  * "independent": the rest. This is exactly the semimeasure defect.
* M_A(D) = Bel_0(ψ_D), where ψ_D is the conjunction of the literal data.
* **Conditioning rules.**
  * Proof-requiring updating is *geometric conditioning* of the prior belief function Bel_0, where Bel_0 is the "probability of provability".
  * Consistency-requiring updating is *Dempster conditioning*.
* **Two completions.**
  * The three-valued completion M_A^3 makes "independent" an outcome and is additive.
  * The coin-free version is W_A: weight 2^(−|p|) on programs enumerating consistent axiom sets.
  * The Kolmogorov version is K_A, the shortest consistent r.e. axiomatisation proving the data.

**Basic theorems (§3).**
* **Dominance.** M_A ≥ 2^(−K(ν))·ν for every theory-machine law ν.
* **Invariance.**
  * Changing the universal machine changes M_A by a constant factor.
  * A faithful translation τ of languages changes it by a factor of at most 2^(K(τ)+c).
  * In particular, adding vocabulary changes the weights of data in the old vocabulary by at most a constant factor. This is a Solomonoff form of Craig's observation: theoretical terms are dispensable up to O(1) (§3.2).
* **Not lower semicomputable.**
  * M_A(D) = Q(D) − Inc_0, where Q is lsc and Inc_0 (the probability that the random theory is inconsistent) is a Solovay-complete left-c.e. real.
  * So M_A(∅) = 1 − Inc_0 is right-c.e. and not computable.
* **One-tape form of the author's conjectured equivalence.**
  * M_A agrees, up to constant factors, with SFI conditioned on the consistency of its random labeller.
  * No Craig trick is needed, since enumeration replaces decision.
* **Atomic data.**
  * On literals R(t_x) of a fresh predicate, M_A, W_A and K_A agree up to constants with P1's M_F, W and K_F.
  * Hence all of P1 §4 transfers. In particular there is **no coding theorem**: Paper 1's log d gap between the Kolmogorov and semimeasure versions recurs on two-atom data. The chain between the versions has slack K(question) in place of K(dom D).
* **Loss bound.** On every sequence of sentences, in any order, that a consistent r.e. theory T decides, the cumulative loss is at most −log m(Ext(T)) + c ≤ K_≡(T) + c.
  * K_≡(T) is the complexity of T *up to deductive equivalence*.
  * m(Ext(T)) is the algorithmic probability of the consistent extensions of T.
  * The bound is not in terms of an axiom set.
  * A laws-plus-exceptions form and a three-valued merging theorem also hold.
* **Consistency-requiring variant.**
  * Its 0/1 weight is bounded below by a constant on every consistent data set: it learns nothing.
  * Its proper (Dempster) predictor has linear loss where proof-requiring has O(1).
  * The graded version (grade ½ per unproved datum) is an order-independent weak semimeasure that dominates M_A. It is not logically coherent: it charges for entailed data.
* **Limits.**
  * A complete decidable truth is identified up to deductive equivalence, and the trichotomy becomes correct uniformly.
  * From two-valued data of an incomplete r.e. theory T*, the posterior goes to the prior restricted to the consistent extensions of T*. The trichotomy of every T*-independent sentence tends to three positive prior shares.
  * Three-valued data identify [T*]. This is Gold's text versus informant.
  * Non-decidable complete truths such as Th(ℕ) give unbounded loss: at least n^δ in a natural enumeration (proof sketch).
  * Random theories above Robinson's Q are almost surely incomplete, a measure-zero argument via PA degrees.

**Top candidates.** The ranked list is in §5:
1. definitions with dominance and invariance;
2. the loss bound in K_≡;
3. the one-tape equivalence with consistent SFI and the atomic fragment;
4. no coding theorem / the chain;
5. the trichotomy as geometric conditioning with three-valued completion;
6. limits and identification;
7. the consistency-requiring separation;
8. non-lower-semicomputability and the consistency Ω;
9. a.s. incompleteness above Q;
10. a factor-2 coding theorem for whole theories via Solovay;
11. language-expansion invariance.

---

## 1. Inventory: what earlier work already defines and proves

### 1.1 The earlier report on axiom induction (`../axiom-induction`)

The earlier report's main object is a *generative* inducer:
* theories are finite sets of DT templates;
* the prior is a template code;
* the likelihood is a derivation grammar.

Its §6 and Appendix E treat the 0/1 "axiom induction requiring proofs" against function induction. Items the new fundamentals need are listed below. Status is as recorded there; "reuse" says what the new paper does with each item.

| item | printed number (record) | content | status there | reuse in the new paper |
|---|---|---|---|---|
| AI, FIcons, FIall; semimeasure convention | AI Def 6.2 (model §6.1; time-followup §1.1) | AI: deciders p of A_p, compatible if B ∪ A_p consistent and proves each φ_i^{b_i}; W_AI(D) = Σ 2^(−\|p\|). FIcons: consistent assigners. Semimeasure convention P(b_{1:n}) = W(D_n)/W(∅) | definition | the coin-free layer W_A (enumerators instead of deciders; equal up to O(1), F8) |
| Hänni's equivalence, repaired | AI Thm 6.3, proof AI App. E.1 (model Thm 6.1) | 2^(−c)W_AI ≤ W_FI ≤ 2^c W_AI via proof search and Craig's padded conjunction powers | proved; Craig known | coin-free and Kolmogorov layers of F8 |
| FIall vs AI | AI Prop E.1 (model Prop 6.0) | fair-coin literals all labelled true: FIall O(1), AI and FIcons ≥ n bits expected | proved | transfers verbatim to M_F vs M_A (§3.3) |
| the convention | AI Rem E.2 (model §6.1 remarks) | per-step renormalisation gives only 2c bits *per step* | proved | §2.4 conventions |
| enumerators ≍ FIcons | time-followup Lemma 2.1, Thm 2.2(b) (§2) | padded enumerators; W_{AI^gen} within a constant of W_FI; upper bound by proof search | proved under (S) | F8 (without a time bound the padding is not needed) |
| bounded loss on an infinite sequence | time-followup Lemma 1.6 (§1.7) | sup_n ℓ(D_n) < ∞ iff some hypothesis of positive weight is compatible with every prefix | proved | F22, F26 (coin-free form) |
| two-sorted schema; one sort over PA fails; bounded-witness repair | AI Props 6.4, 6.5; time-followup Props 2.4(b)–(d), 2.5 | Hänni's schema "Acc_f(⌜φ⌝) → φ" works with two sorts; fails for some consistent unsound f over PA; A^bd_f repairs it in one sort | proved | relation-to-SFI scout; not needed for F8 |
| Hänni's scores | AI Def 2.12 (model §1.5) | S_prove, S_nc, graded S_g | definition | PR and CR one-tape are the measure-theoretic forms of S_prove and S_nc (§2.3, §2.5) |
| no size principle for scores | AI Prop 2.22(b) (model Prop 1.9(b)) | consistent strengthenings keep their prior odds under S_prove, S_nc | proved | F19, F24 |
| "does not contradict" learns nothing; 0/1 must-prove | pa Prop 5.2 (pa §5.6); pa Prop 3.4 (pa §3.7) | CR posterior is the prior restricted to compatible theories; must-prove needs refutation | proved | F19 |
| trichotomy | AI Def 2.13; Props 2.14, 2.17–2.19; Exs 2.15, 2.16; Rem 2.20 (model §7) | Bel, Dis, Indep, Inc, Pl; Bel totally monotone (belief function); coherent bracketing; renormalising and 50/50 incoherent; 50/50 coherent iff every theory has ≤ 2 models | proved; computed | all hold for any probability on consistent theories, so for the M_A posterior (§3.8) |
| L1 and its support | AI Def 2.9, Lemma 2.10 (model §1.5) | derivation grammar; supp P_T = Th(T) with parameters admissible | proved | generative variant (§2.9) |
| size principle | AI Lemma 2.21, Prop 2.22(a),(c) (model §1.6) | normalised likelihoods lose ≥ ln(1/(1−ε)) nats per datum for mass ε off the support | proved | §2.9 |
| computability | AI Prop 2.24 (model §2.4) | P_T(s) computable real, positivity undecidable | proved | contrast with F3 |
| well-specified limits | AI Thm 4.2, Cors 4.3, 4.4 (model §2.1); Thm 4.7 (model §5.1); Prop 4.9 (model §5.2); Thm 4.21 (model §8) | concentration on the generator class; inside it posterior = prior; theorem set identified under L1; Gold limit point; predictive vs deductive | proved; known (Doob) | §2.9 and F24: the generative variant identifies Th(T*), PR cannot |
| misspecification | AI Thm 4.16, Exs 4.17, 4.19 (model §3) | finite class: KL-minimisers; weaker or unsound limits | proved | not needed here |
| Bayesian ω-gap; Hänni's variants; Q4; Gaifman | AI Thm 3.9 (universal §6.1); Prop B.8 (universal §6.2); Prop B.9 (§6.4); Prop B.10 (§6.5) | "proves ∀xφ" tends to a prior share; under S_prove the posterior tends to the prior on consistent provers of all closed instances, all three trichotomy values keep mass | proved | F25 is the one-tape form of Prop B.8 |
| Th(ℕ) data | AI Prop 7.11 (pa Prop 4.1); Prop 7.12 (pa Prop 4.2); Rem F.13; Prop F.12; Rem F.14 | no consistent r.e. theory survives i.i.d. Th(ℕ) data; refutation is Π₁-complete; pointwise limits trivial by memorisation; regret against theory plus exceptions under L_ε; PA tower drift | proved | F26, F14 |
| time penalties and separations | AI Rem 6.1, Thms 6.9, 6.14–6.16, Cor 6.17 (time-followup, short-derivations) | collapse intact under axiom-side penalties; one-sided under FI-side penalties; diagonal separation; certificate function induction | proved (several conditional) | relation-to-SFI scout, not here |

**What the earlier report does not contain.**
* Randomised (one-tape) theories.
* A universal theory machine.
* The Kolmogorov version or a coding-theorem question.
* Loss bounds against arbitrary theories in K_≡ form.
* The conditioning-rule reading of the variants.
* Invariance under translation.

These are new below.

### 1.2 The axiom-schemas report (`../axiom-schemas`)

Used here only for the ω-gap:
* AS Prop 4.7: closed instances decide universals exactly when the closed-term substructure is elementary;
* AS Ex 4.8 (where the step fails);
* AS Ex 4.9 ("not derivable");
* AS Prop C.5 (refutation and the ω-gap).

Templates, anchors and DTRC concern restricted hypothesis classes, not the universal fundamentals.

### 1.3 The parallel objects of SFI Paper 1

| P1 object | printed number | axiom-induction analogue here |
|---|---|---|
| function machine (consistent c.e. triples), law ν_T | P1 Def 3.6, Prop 3.7 | theory machine G (any c.e. set of (tape prefix, axiom) pairs), law ν_G (Def 2.2) |
| universal function machine, M_F = Σ m(i) ν_{T_i}, dominance | P1 Thm 3.8 | G_U, M_A, F4 |
| what machine laws include | P1 Prop 3.9 | deterministic r.e. theories, theory plus coin facts, mixtures (F4) |
| weak semimeasure, M_w, weak vs machine gap | P1 Defs 3.2, Thms 3.11, 3.12 | graded CR weight M_A^½ (F21) |
| order independence; normalisation | P1 Props 3.16, 3.17 | F1(d); §2.4 |
| invariance (machine, encodings) | P1 Thm 3.20 | F5, F7 |
| coding-theorem bounds | P1 Thm 3.21 | F10 |
| SI = SFI on initial segments | P1 Prop 3.24 | F9(c) |
| W, K_F, M_prod; chain; W gap; tape bound; no coding theorem; covering | P1 Def 4.1, Thm 4.4, Props 4.5–4.7, Thm 4.9, Cor 4.10, Prop 4.11 | W_A, K_A; F10, F11 (transfer via F9) |
| dominance loss bound K(ν); merging; mistakes | P1 Thm 5.1, Thm 5.3, Cor 5.4 | F13, F14, F15, F16 |
| computability (M_F lsc; conditionals ∅′-computable) | P1 Prop A.10 | F3 (M_A is *not* lsc) |

Renaming needed in the new paper: P1 writes T for function machines, while theories are T here. **Recommendation:** write function machines F (law ν_F, universal F_U), so that "M_F" reads "the function version".

### 1.4 Definitions in the author's note (`research/prior/hanni-solomonoff-axiom-induction.md`)

* **N1 (data).** Mathematical statements labelled true or false. First-order logic with "some reasonable standard collection of inference rules and axioms" is fixed.
* **N2 (proof-requiring).** Weigh "all the axiom systems from which one can prove these … and not their negations (equivalently, from which one can't prove a contradiction)".
* **N3 (consistency-requiring).** Weigh "all axiom systems that do not contradict the given statements".
  * The weight should depend on "the complexity of specifying the axioms (ie the axiom verifiers)" and "how many of the given statements can be proven", possibly penalising proof length.
  * This is "equivalently … some model for how the statements get generated", which is the generative variant.
* **N4 (trichotomy).** Each statement gets "p(true/false/independent)", with three options:
  * renormalise, which is "like solomonoff … where we remove the TMs that don't halt";
  * a 50/50 split;
  * keep a semimeasure.
* **N5 (comparison with SFI).** SFI with accept/reject/not halting. Compare log losses "for any reveal ordering of sentences and assignment of truth values".
* **N6.** Unrestricted SFI beats axiom induction on consistent but hard labellings, so compare with consistent assigners.
* **N7 (conjectured equivalence).** Axiom induction requiring proofs equals SFI over consistent assigners, via the schema "T(⌜φ⌝) = accept ⇒ φ".
* **N8–N9 (restrictions and fixes).** Restricted axiom printers (substitution schemas). Partial answers, mistakes, and a metric on values.

Definitions 2.3–2.5 make N2–N4 precise in one-tape form. F8 is N7 in one-tape form. §2.4 settles N5's "what is a sequence" exactly as AI Rem E.2 did: any reveal order, semimeasure convention.

---

## 2. Proposed definitions

### 2.1 Language, background, data

**Definition 2.1.**
* L is a countable first-order language with equality and computable syntax; Sent_L is its set of sentences; ⊢ is classical first-order derivability.
* B ⊆ Sent_L is a fixed r.e. consistent *background* (default ∅).
* For Γ ⊆ Sent_L, Cn(Γ) := {φ : B ∪ Γ ⊢ φ}. Γ is *consistent* if B ∪ Γ is.
* Labels are 1 (true) and 0 (false); φ^1 := φ, φ^0 := ¬φ.
* A *data set* D is a finite set of labelled sentences (φ, b).
  * D^± := {φ^b : (φ,b) ∈ D}.
  * ψ_D := the conjunction of D^± in a fixed canonical order (⊤ := ∀x x=x when D = ∅).
  * D is consistent if B ∪ D^± is consistent.
  * D + (φ, b) := D ∪ {(φ,b)}.
* A reveal sequence (φ_t, b_t)_{t≤n} has prefixes D_t.
* *Three-valued* data also allow the label ι ("independent").

Unlike P1, a data set need not be a partial function. (φ,1) and (¬φ,0) are the same constraint, and an inconsistent D simply has weight 0.

### 2.2 Theory machines

**Definition 2.2 (theory machine).**
* A *theory machine* is a c.e. set G ⊆ {0,1}* × Sent_L.
* For a tape ω ∈ {0,1}^∞, A^G_ω := {χ : (w, χ) ∈ G for some prefix w of ω}: the axioms enumerated after reading finitely many tape bits.
* The random theory is Cn(A^G_ω).
* For a data set D, E^G_D := {ω : A^G_ω is consistent and B ∪ A^G_ω ⊢ ψ_D}.
* The *law* of G is ν_G(D) := Unif(E^G_D).
* The *three-valued law* ν^3_G(D) is the measure of {ω : A^G_ω consistent, proves φ^b for (φ,b) ∈ D with b ∈ {0,1}, and decides no φ with (φ, ι) ∈ D}.

Equivalently, G is an oracle machine that reads its random tape one-way and writes sentences. No consistency condition is imposed: enumerating more axioms is always allowed, and consistency is a property of the output.

* (G_i) is the standard enumeration of c.e. subsets of {0,1}* × Sent_L.
* K(G) := min{K(i) : G_i = G}.
* For a law ν, K(ν) := min{K(i) : ν_{G_i} = ν}.

**Examples.**
* (i) A deterministic r.e. theory T = W_e: G = {(ε, χ) : χ ∈ W_e}, with ν(D) = 1[B ∪ T consistent, ⊢ ψ_D].
* (ii) *Fair-coin facts*: G = {(w, R(t_j)^{w_j}) : |w| = j} for a unary R and distinct closed terms t_j.
* (iii) A theory T plus coin facts.
* (iv) Lower-semicomputable mixtures of r.e. theories.

### 2.3 The universal theory machine and the proof-requiring weight

**Definition 2.3 (Solomonoff axiom induction, proof-requiring).**
* Let V be the fixed universal prefix machine.
* G_U := {(pw, χ) : p ∈ dom V, (w, χ) ∈ G_{V(p)}}: read a self-delimiting program, then run that machine on the rest of the tape.
* The random axiom set is A_ω := A^{G_U}_ω.
* The weight of D is M_A(D) := ν_{G_U}(D), the probability that the random theory is consistent and proves every datum.
* The posterior after D is the law of A_ω given E_D := E^{G_U}_D.
* M_A^3 := ν^3_{G_U}.

One tape is read in two parts: a program and then its coin flips. There is no second source of randomness. This matches P1 Def 3.15.

### 2.4 Predictive probabilities, the trichotomy and the conventions

**Definition 2.4.** For a consistent D and a sentence φ:
* "φ is true": M_A(1 | D, φ) := M_A(D + (φ,1))/M_A(D) = Bel_D(φ), the posterior probability that the random theory proves φ.
* "φ is false": M_A(0 | D, φ) = Bel_D(¬φ) =: Dis_D(φ).
* "φ is independent": Indep_D(φ) := 1 − Bel_D(φ) − Dis_D(φ), the posterior probability that the random theory decides neither. Equivalently it is M_A^3(D + (φ, ι))/M_A(D), the three-valued conditional.

**The conventions.**
* *Semimeasure convention* (primary). The cumulative loss on a reveal sequence is Σ_t −log M_A(b_t | D_{t−1}, φ_t) = L_A(D_n) − L_A(∅), with L_A := −log M_A.
* *Normalised convention.* Use Bel_D(φ^b)/(Bel_D(φ) + Dis_D(φ)). This is the author's "remove the independent fraction and renormalise", read per query.
  * Upper bounds in the semimeasure convention transfer, since normalised conditionals are larger.
  * Lower bounds do not.
* *Three-valued convention.* Labels in {1, 0, ι}, scored by M_A^3; the conditionals sum to 1 (F1(f)).

**Remark (two defects).** M_A has two defects.
* The *global* defect: M_A(∅) = 1 − Inc_0 < 1, where Inc_0 is the probability that the random theory is inconsistent.
* The *local* defect at each query, which is Indep_D(φ).

In P1 only the local defect exists (M_F(∅) = 1), because function machines enforce consistency syntactically. The analogy in the author's note N4 is exact once two things are matched:
* "proves φ" is Σ₁ (like halting with an answer);
* "independent" is Π₁ (like not halting).

Inconsistency has no counterpart in P1. It corresponds to "halts with both answers", which a consistent function machine cannot do.

### 2.5 The consistency-requiring variants

**Definition 2.5.**
* *0/1 weight (Hänni's "does not contradict").* M_A^nc(D) := Pr_ω[B ∪ A_ω ∪ D^± consistent]. The CR posterior is the law of A_ω given that event.
* *CR predictive trichotomy.* Predict with the theory A_ω ∪ D^±, the hypothesis plus the data:
  * Bel^nc_D(φ) := Pr[B ∪ A_ω ∪ D^± ⊢ φ | B ∪ A_ω ∪ D^± consistent];
  * Dis^nc_D(φ) := Bel^nc_D(¬φ);
  * Indep^nc := the rest.
* *Graded CR with grade ½.*
  * For a consistent theory A put ν^½_A(D) := 1[B ∪ A ∪ D^± consistent] · Π_{(φ,b)∈D} g_A(φ,b), where g_A(φ,b) = 1 if A ⊢ φ^b and ½ otherwise. (If A ⊢ φ^{1−b}, the consistency indicator is already 0.)
  * M_A^½(D) := E_ω[ν^½_{A_ω}(D); A_ω consistent].
  * This is the author's "weight depending on how many of the given statements can be proven" (N3), with grade ½ per unproved datum.

### 2.6 Coin-free and Kolmogorov versions

**Definition 2.6.**
* W_A(D) := Σ_{p∈dom V} 2^(−|p|) · 1[B ∪ W_{V(p)} consistent and ⊢ ψ_D] = Σ_e m(e)·1[…]. This is the coin-free version: the tape only selects a program enumerating axioms.
* K_A(D) := min{|p| : p ∈ dom V, B ∪ W_{V(p)} consistent and ⊢ ψ_D} = min{K(e) : …}. This is the Kolmogorov version: the shortest consistent r.e. axiomatisation compatible with the data; it is ∞ for inconsistent D.
* *Variants, all equal up to O(1) bits.*
  * Deciders in place of enumerators: Craig's trick, AI Thm 6.3.
  * Enumerators with polynomial delay: time-followup Thm 2.2(b).
  * *Not* equal: finite axiomatisations K_fin(D) := min{K(ψ) : B ∪ {ψ} consistent, ψ ⊢ ψ_D}. Always K_A ≤ K_fin + c ≤ K(ψ_D) + c.

### 2.7 Complexities of theories

**Definition 2.7.** For an r.e. theory T:
* [T] := {e : Cn(W_e) = Cn(T)}.
* K_≡(T) := min_{e∈[T]} K(e), the complexity *up to deductive equivalence*.
* m_≡(T) := Σ_{e∈[T]} m(e).
* Ext(T) := {e : W_e consistent, Cn(W_e) ⊇ Cn(T)}, and m(Ext(T)) := Σ_{e∈Ext(T)} m(e).
* One-tape versions:
  * Π[T] := Unif{ω : Cn(A_ω) = Cn(T)};
  * ΠExt(T) := Unif{ω : A_ω consistent, Cn(A_ω) ⊇ Cn(T)}.

### 2.8 Consistent SFI

**Definition 2.8.**
* Function machines F are as in P1 Def 3.6, with inputs X = Sent_L and labels {1, 0}.
* Γ_f := {φ : f(φ) = 1} ∪ {¬φ : f(φ) = 0}.
* For a finite partial function D : Sent_L ⇀ {1,0}:
  * M_F^cons(D) := Unif{ω : f_ω ⊇ D and B ∪ Γ_{f_ω} consistent}, with f_ω the random function of P1's universal function machine;
  * W^cons(D) := Σ_e m(e)·1[φ_e ⊇ D, B ∪ Γ_{φ_e} consistent];
  * K_F^cons(D) := min{K(e) : …}.
* This is "SFI restricted to consistent random labellers" (brief, seed idea "randomised axiom systems"), with consistency conditioned on event-wise. It dominates every function machine whose labels are almost surely consistent (F8).

### 2.9 How the generative (derivation-likelihood) variant fits

The earlier report's inducer (AI Defs 2.7, 2.9) is generative:
* a theory T has a law P_T on sentences;
* the data are unlabelled sentences X_i drawn i.i.d.;
* the posterior is ∝ π(T) Π_i P_T(X_i).

In one-tape form, a *generative theory machine* first enumerates axioms from the tape. It then samples each datum from a derivation grammar using fresh segments of the tape; for an infinite r.e. axiom set this needs a citation law, for example weight 2^(−j) on the j-th enumerated axiom. The universal law of data streams is Ξ(X_{1:n}) := E_ω Π_i P_{A_ω}(X_i).

How it fits with PR:
* **(i) Supports.** Under L1 with parameters admissible, P_T(s) > 0 iff T ⊢ s (AI Lemma 2.10(c)). So a generative theory has positive likelihood on D exactly when it proves D^±, which is the PR compatibility condition. Inconsistent theories are admitted, but their support is everything.
* **(ii) Reweighting.** The generative posterior is the PR posterior reweighted by Π_i P_T(X_i) ≤ 1. The reweighting is the size principle (AI Lemma 2.21): a theory pays for probability it spends on sentences never observed.
* **(iii) Question conditioning** [proved]. Read a datum as an answered question q = {φ, ¬φ} with answer X ∈ q. For consistent T, P_T(φ^b | X ∈ q) = 1[T ⊢ φ^b] whenever P_T(q) > 0, and P_T(q) = 0 when T decides neither. The generative posterior predictive for the answer is therefore Σ_T π_n(T)·P_T(q)·1[T ⊢ φ^b] / Σ_T π_n(T)·P_T(q). This is the PR "Bel" under a posterior reweighted by how likely each theory was to have *asked* q. "Independent" has probability 0 here, because the model presupposes that asked questions are answered.
  * *Proof.* For consistent T, supp P_T = Th(T) contains at most one of φ, ¬φ, and contains one iff T decides φ. Bayes' rule then gives the formula. ∎
* **(iv) Identification.** With data drawn from P_{T*}, the generative posterior identifies the theorem set Th(T*) (AI Thm 4.2, Cor 4.4, Thm 4.7(a)). PR identifies only the consistent extensions of T* (F24). So the generative variant is what buys identification, at the price of a model of which sentences get stated.

**Dictionary.**

| SFI (P1) | axiom induction (here) |
|---|---|
| function machine T, consistent triples | theory machine G, any c.e. set; consistency of the output is a random event |
| M_F(D) = Pr[f_ω ⊇ D] | M_A(D) = Pr[A_ω consistent, ⊢ ψ_D] = Bel_0(ψ_D) |
| defect = Pr[f_ω(x) = ⊥] | defect = Indep_D(φ); plus the global defect Inc_0 |
| M_F lsc | M_A not lsc (F3) |
| W (coin-free), K_F | W_A, K_A |
| K(dom D) slack in the chain | K(question) slack (F10) |
| K(ν) loss bound | K(ν) for theory-machine laws; K_≡(T) for theories (F13) |
| M_w (weak) ≥ M_F | M_A^½ (graded CR, weak) ≥ M_A (F21) |
| M_prod (private coin per input) | theory plus coin facts on a fixed atom family; no consistent "fair coin on every sentence" above Q (F27) |

---

## 3. Basic properties

### 3.1 Well-definedness, structure, the defect, computability

**F1 (structure) [proved].** For every theory machine G (in particular for M_A):
* (a) E^G_D is Borel. ν_G(D) > 0 implies D consistent. M_A(D) > 0 iff D is consistent.
* (b) ν_G(D + (φ,1)) + ν_G(D + (φ,0)) ≤ ν_G(D). The difference is ν^3_G(D + (φ, ι)), the mass of consistent outcomes that prove ψ_D and decide neither φ nor ¬φ. For M_A the difference divided by M_A(D) is Indep_D(φ).
* (c) ν_G(D) depends on D only through the Cn-class of ψ_D. If B ∪ D^± ⊢ φ^b, then ν_G(D + (φ,b)) = ν_G(D) and ν_G(D + (φ, 1−b)) = 0. Entailed data cost nothing; contradicting data cost ∞.
* (d) *Order independence.* For every reveal order, possibly with repeats, Σ_t −log M_A(b_t | D_{t−1}, φ_t) = L_A(D_n) − L_A(∅). It depends only on the Cn-class of ψ_{D_n}.
* (e) 0 < M_A(∅) = 1 − Inc_0 < 1.
* (f) ν^3_G is additive: Σ_{y∈{1,0,ι}} ν^3_G(D + (φ, y)) = ν^3_G(D), and ν^3_G(∅) = ν_G(∅). So the three-valued conditionals are probabilities.
* (g) M_A is the containment functional (P1 Def 3.4) of a random partial function with a sub-probability law. On the event "A_ω consistent", set f_ω(φ) := 1 if A_ω ⊢ φ, 0 if A_ω ⊢ ¬φ, and ⊥ otherwise.

*Proof.*
* (a) {ω : B ∪ A^G_ω ⊢ ψ} is a union of cylinders [w] over pairs (w, a finite proof whose axioms are listed in G under prefixes of w), so it is open. Inconsistency is the case ψ = ⊥, so consistency is closed, and E_D is open ∩ closed. If D is inconsistent, every consistent theory fails to prove ψ_D. Conversely, a consistent D has the deterministic theory {ψ_D}, of positive weight in M_A by F4.
* (b) A consistent theory cannot prove both ψ_D ∧ φ and ψ_D ∧ ¬φ, so the two events are disjoint subsets of E_D. Their complement in E_D is exactly "proves ψ_D, decides neither".
* (c) "B ∪ A ⊢ ψ_D" depends only on the Cn-class of ψ_D. If B ∪ D^± ⊢ φ^b, then every theory that proves ψ_D proves φ^b; a consistent one does not prove φ^{1−b}.
* (d) The factors telescope. A repeated datum contributes factor 1 or 0 by (c).
* (e) M_A(∅) = Pr[A_ω consistent] = 1 − Inc_0. Tapes beginning with a program for the empty enumerator give consistent theories, since B is consistent. Tapes beginning with a program enumerating ⊥ give inconsistent ones. Both sets have positive measure.
* (f) The three events "proves φ", "proves ¬φ", "decides neither" partition the consistent outcomes.
* (g) By definition. ∎

**F2 (proof-requiring updating is geometric conditioning) [proved; computed: c1 A2].**
* Let Bel_0(χ) := M_A({(χ,1)}), the prior probability that the random theory is consistent and proves χ. This is Pearl's "probability of provability" reading of a belief function [known: Pearl 1988, via secondary sources; §8].
* Then M_A(D) = Bel_0(ψ_D) and Bel_D(φ) = Bel_0(ψ_D ∧ φ)/Bel_0(ψ_D). This is the geometric conditioning rule of Suppes and Zanotti [known; §8].
* Bel_0 and every Bel_D are totally monotone (AI Prop 2.18), and are bracketed by a coherent probability (AI Prop 2.19).
* *Proof.* "Proves ψ_D and φ" is the same event as "proves ψ_D ∧ φ". The cited propositions hold for any probability on consistent theories. ∎

**F3 (not lower semicomputable; the consistency Ω).**
* (a) [proved] Let Q(D) := Unif{ω : B ∪ A_ω ⊢ ψ_D}, uniformly lsc (an r.e. open set), and Inc_0 := Unif{ω : B ∪ A_ω inconsistent}, left-c.e. Then M_A(D) = Q(D) − Inc_0.
  * *Proof.* An inconsistent theory proves ψ_D, so {⊢ψ_D} = E_D ⊔ {inconsistent}. ∎
  * The correction to the lsc quantity Q, which is not a semimeasure, is one real number.
* (b) [proved] Inc_0 is not computable. Hence M_A(∅) = 1 − Inc_0 is right-c.e. and not left-c.e., and M_A is not lower semicomputable. Contrast P1 Prop 3.7 / A.10: M_F is lsc.
  * *Proof.* For a left-c.e. α ∈ [0,1] with computable approximations α_s ↑ α, let G_α enumerate ⊥ as soon as some prefix w = ω_{1:k} and stage s have 0.w + 2^(−k) ≤ α_s. Then G_α's inconsistency probability is Unif{ω : 0.ω < α} = α.
  * Let p_α be a V-program for an index of G_α. Splitting tapes by their first V-program gives Inc_0 = 2^(−|p_α|)α + γ, where γ is the contribution of all other programs, a left-c.e. real.
  * If Inc_0 were computable, α = 2^{|p_α|}(Inc_0 − γ) would be right-c.e. as well as left-c.e., hence computable.
  * Take α = Ω_V, which is not computable [known]. Contradiction.
  * A real that is both left-c.e. and right-c.e. is computable, so 1 − Inc_0 is not left-c.e. ∎
* (c) [proved, given Kučera–Slaman (known)] The display in (b) shows α ≤_S Inc_0 for every left-c.e. α. So Inc_0 is Solovay complete, hence Martin-Löf random (an Ω number).
* (d) [proved] M_A(D) and the conditionals M_A(b | D, φ) are differences and ratios of left-c.e. reals. They are computable relative to ∅′, and lsc relative to the single real Inc_0.

### 3.2 Universality and invariance

**F4 (mixture and dominance) [proved].**
* For every D, M_A(D) = Σ_i m(i) ν_{G_i}(D) + (1 − Ω_V)·1[B ⊢ ψ_D], with Ω_V := Σ_{p∈dom V} 2^(−|p|).
* Hence M_A ≥ 2^(−K(ν))·ν for every theory-machine law ν. In particular:
  * (i) M_A(D) ≥ 2^(−K(e)−c)·1[B ∪ W_e consistent, ⊢ ψ_D] for every r.e. W_e;
  * (ii) M_A(D) ≥ 2^(−K(f)−c)·1[f ⊇ D] for every partial computable assigner f with B ∪ Γ_f consistent;
  * (iii) the bound holds for theory plus coin facts, and for every lsc mixture of r.e. theories.
* *Proof.* Tapes split by their first block p ∈ dom V, a prefix-free set. On pω′ the machine runs G_{V(p)} on ω′. Tapes without such a block give A_ω = ∅, consistent since B is. Collect the p with V(p) = i, of total weight m(i) ≥ 2^(−K(i)).
  * For (ii), the theory machine {(ε, φ^b) : f(φ) = b} has K ≤ K(f) + c. Its theory is Γ_f, which is consistent and proves ψ_D when f ⊇ D. ∎

**F5 (invariance under the universal machine) [proved].**
* Call G′ universal if for every G there is p_G with A^{G′}_{p_G ω} = A^G_ω for all ω.
* For universal G_U and G′, 2^(−c) M_A ≤ M′_A ≤ 2^c M_A, with c depending only on the two machines.
* *Proof.* M_A ≥ 2^(−K(G′))·ν_{G′} = 2^(−K(G′))·M′_A by F4. The tapes p_{G_U}ω′ give M′_A ≥ 2^(−|p_{G_U}|)·M_A. ∎

So posteriors, and cumulative losses in the semimeasure convention, change by at most an additive constant.

**F6 (the background is a prior shift) [proved].** For r.e. B ⊆ B′, both consistent, M^B_A ≥ 2^(−K(B′)−c)·M^{B′}_A.
* *Proof.* The machine "enumerate B′, then run G_U" has, under background B, the event {B ∪ B′ ∪ A consistent, ⊢ ψ_D}, whose measure is M^{B′}_A(D). ∎
* The converse fails trivially: data inconsistent with B′ have M^{B′}_A = 0.
* Building knowledge into the background gains at most K(B′) bits.

**F7 (invariance under faithful translations) [proved].**
* Let (L, B) and (L′, B′) be two settings and τ : Sent_L → Sent_{L′} computable with two properties:
  * (T1) for all Γ ⊆ Sent_L and φ: B ∪ Γ ⊢ φ iff B′ ∪ τ[Γ] ⊢ τ(φ);
  * (T2) B′ ⊢ τ(¬φ) ↔ ¬τ(φ).
* Then for every D, with τD := {(τφ, b) : (φ,b) ∈ D} and "proves τD" read datum by datum:
  2^(−K(τ)−c)·M_A(D) ≤ M′_A(τD) ≤ 2^{K(τ)+c}·M_A(D).
* The same holds for W_A, and K_A changes by at most K(τ) + c.

*Proof.*
* *A preliminary fact.* B′ ⊢ ¬τ(⊥): by (T1) with Γ = ∅, B ⊢ ¬⊥ gives B′ ⊢ τ(¬⊥), and (T2) converts this.
* *Push forward.* The machine "run G_U and enumerate τ(χ) for each axiom χ" outputs τ[A].
  * B′ ∪ τ[A] ⊢ τ(⊥) iff B ∪ A ⊢ ⊥ (T1). With the preliminary fact, B′ ∪ τ[A] is consistent iff B ∪ A is.
  * B′ ∪ τ[A] ⊢ τ(φ)^b iff B ∪ A ⊢ φ^b (T1, T2).
  * So the event for τD under this machine is E_D, and M′_A(τD) ≥ 2^(−K(τ)−c)·M_A(D).
* *Pull back.* The machine "run G′_U and enumerate τ*(A′) := {φ ∈ Sent_L : B′ ∪ A′ ⊢ τ(φ)}" (r.e. in A′).
  * If B′ ∪ A′ is consistent, so is B ∪ τ*(A′). Suppose B ∪ Γ ⊢ ⊥ for a finite Γ ⊆ τ*(A′). Then B′ ∪ τ[Γ] ⊢ τ(⊥) (T1), and B′ ∪ A′ ⊢ τ[Γ], so B′ ∪ A′ ⊢ τ(⊥) ∧ ¬τ(⊥).
  * If B′ ∪ A′ ⊢ τ(φ^b), then φ^b ∈ τ*(A′).
  * So the pull-back's event contains the event for τD, and M_A(D) ≥ 2^(−K(τ)−c)·M′_A(τD).
* The same maps act on single programs, which gives the statements for W_A and K_A. ∎

**F7′ (adding vocabulary changes nothing up to a constant) [proved].**
* Let L ⊆ L′, B′ := B and τ the inclusion. Then (T1) holds: every L-structure expands to an L′-structure, so B ∪ Γ ⊢_{L′} φ implies B ∪ Γ ⊢_L φ. (T2) is trivial.
* Hence for data in the old vocabulary, M^{L′}_A(D) and M^L_A(D) agree within a constant factor, and K^{L′}_A(D) = K^L_A(D) ± c.

*Interpretation.*
* At the level of universal, unbounded induction, theoretical vocabulary buys at most a constant: the pull-back of a theory is its set of observational consequences, an r.e. set. This is the effective content of Craig's theorem inside the prior.
* Any advantage of theoretical terms must come from resource bounds: proof length, axiom length of *finite* axiomatisations, or time.
* For the Craig/theoretical-terms scout: K_fin is not invariant in this way. Craig and Vaught show that adding predicates can make r.e. theories finitely axiomatisable [recalled, not checked; §8].

### 3.3 Relation to SFI

**F8 (the author's conjectured equivalence, one-tape form) [proved].**
* For every finite partial function D : Sent_L ⇀ {1,0}:
  2^(−c)·M_F^cons(D) ≤ M_A(D) ≤ 2^c·M_F^cons(D).
* Likewise 2^(−c)·W^cons ≤ W_A ≤ 2^c·W^cons, and |K_A − K_F^cons| ≤ c.
* M_F^cons ≥ 2^(−K(F))·ν_F for every function machine F whose labels are almost surely consistent.

*Proof.*
* *(M_A ≤ 2^c M_F^cons).* Let F_ps be the function machine that, on query φ, runs G_U on the tape and dovetails proof searches from B ∪ A_ω for φ and for ¬φ, answering 1 or 0 at the first proof found.
  * Its runs are deterministic given the bits read, so its triples are consistent and it is a function machine.
  * If B ∪ A_ω is consistent and proves ψ_D, then for each (φ,b) ∈ D only φ^b has a proof, so f_ω ⊇ D. Also Γ_{f_ω} ⊆ Cn(A_ω) is consistent.
  * The universal function machine dominates F_ps on the conditioned event as well. The tapes p·ω′ of P1's T_U reproduce F_ps's runs on ω′, consistency of Γ included, so M_F^cons ≥ 2^(−K(F_ps))·ν^cons_{F_ps} as in P1 Thm 3.8.
* *(M_A ≥ 2^(−c) M_F^cons).* The theory machine G_lab := {(w, φ^b) : (φ, w, b) ∈ T_U} enumerates exactly Γ_{f_ω}. Its theory is consistent iff Γ_{f_ω} is, and it proves ψ_D when f_ω ⊇ D. Apply F4.
* The same two maps on single programs give the coin-free and Kolmogorov statements. The last claim is P1 Thm 3.8 restricted to the conditioned event. ∎

*Remarks.*
* AI Thm 6.3 is the coin-free statement for *deciders* and needs Craig's trick. One-tape enumeration needs neither Craig nor arithmetic nor a schema.
* The author's schema "T(⌜φ⌝) = accept ⇒ φ" works with two sorts and fails for some consistent unsound assigners over PA in one sort (AI Props 6.4, 6.5). The one-tape theory machine never needs it.
* AI Prop E.1 transfers verbatim. On n fair-coin literals ±R(t_i), all labelled true, the unrestricted M_F has loss O(1) (always accept), while M_A, like M_F^cons, loses at least n bits in expectation.

**F9 (the atomic fragment is binary SFI) [proved].**
* Let R be a unary predicate and (t_x)_{x∈{0,1}*} computable, pairwise distinct closed terms satisfying condition (Lit):
  * every finite set of literals R(t_x)^{b_x} is B-consistent;
  * a B-consistent set Λ of such literals proves R(t_y)^b only if R(t_y)^b ∈ Λ.
* (Lit) holds for B = ∅ or B = Q, with t_x the binary numeral of the number with expansion 1x and R not in B's language. Interpret R in ℕ as any set of values, and use that distinct x give distinct values.
* For D′ : {0,1}* ⇀ {0,1} finite, put D := {(R(t_x), b) : (x,b) ∈ D′}. Then:
  * (a) 2^(−c)·M_F(D′) ≤ M_A(D) ≤ 2^c·M_F(D′), with M_F P1's SFI over X = {0,1}* and labels {0,1};
  * (b) the same for W_A vs W, and |K_A(D) − K_F(D′)| ≤ c;
  * (c) for x ∈ {0,1}^n, M_A({(R(S^i 0), x_{i+1}) : i < n}) agrees with Solomonoff's M(x) within constant factors.

*Proof.*
* (a, ≥) The theory machine "simulate P1's T_U on all inputs x; when it outputs b on x, enumerate R(t_x)^b".
  * Its theory is a set of literals, always consistent by (Lit) and compactness.
  * It proves D iff f_ω ⊇ D′: by (Lit), a datum it does not list is not provable.
* (a, ≤) The function machine "on x, search for proofs of R(t_x) or ¬R(t_x) from B ∪ A_ω".
* (b) The same maps on single programs.
* (c) Combine (a) with P1 Prop 3.24, using unary numerals S^i 0, which satisfy (Lit). ∎

So Solomonoff induction ⊂ binary SFI ⊂ axiom induction (on atomic data) ⊂ consistent SFI on sentences, each inclusion up to constant factors.

### 3.4 Kolmogorov versus semimeasure versions

**F10 (coding lower bound and the chain) [proved].**
* (a) Let S be a finite set of pairwise B-incompatible sentences and σ ∈ S. Then −log M_A({(σ,1)}) ≥ K(σ | S) − c.
* (b) In particular, L_A(D) ≥ K(b_D | dom D) − c, where b_D is the label vector of D in canonical order. On fair-coin labels of any n sentences, E L_A ≥ n − c.
* (c) For every consistent D and every S as in (a) containing ψ_D:
  2^(−K_A(D)) ≤ W_A(D) ≤ 2^c M_A(D) ≤ 2^{K(S)+c}·2^(−K_A(D)).
  With S the 2^{|dom D|} label conjunctions on dom D, K(S) ≤ K(dom D) + c.

*Proof.*
* (a) Let Q_S(σ) := Unif{ω : running G_U and dovetailing proof searches from B ∪ A_ω for all members of S, the first member found proved is σ}.
  * The events for different σ are disjoint, so Σ_{σ∈S} Q_S(σ) ≤ 1. Q_S(σ) is lsc uniformly in (S, σ).
  * If B ∪ A_ω is consistent and proves σ, it proves no other member of S. So M_A({(σ,1)}) ≤ Q_S(σ).
  * Apply the conditional coding theorem (P1 §3.1: K(a | z) ≤ −log P(a | z) + K(P) + c for uniformly lsc P with Σ_a P(a|z) ≤ 1).
* (b) The label conjunctions on dom D are pairwise incompatible, and S is computable from dom D. For the expectation, Σ_b 2^(−K(b | dom D)) ≤ 1, so E_b K(b | dom D) ≥ n by Gibbs' inequality.
* (c) *First inequality.* One term of W_A.
  * *Second.* G_W := {(p, χ) : p ∈ dom V, χ ∈ W_{V(p)}}, "read a program, then enumerate", is a theory machine with ν_{G_W} ≥ W_A. Apply F4.
  * *Third.* K_A(D) ≤ K(ψ_D) + c, since the one-axiom theory {ψ_D} is consistent. Then K(ψ_D) ≤ K(S) + K(ψ_D | S) + c, and (a) bounds K(ψ_D | S). ∎

**F11 (no coding theorem; the log d gap recurs) [proved; (ii), (iii) given P1 Prop 4.6(b), Prop 4.5].**
* For every d ≥ 2 there are distinct x_1, x_2 ∈ {0,1}^d such that D := {(R(t_{x_1}), 0), (R(t_{x_2}), 1)} satisfies:
  * (i) K_A(D) ≥ log d − 2;
  * (ii) −log W_A(D) ≤ 2 + K(⌈log(d+1)⌉) + c;
  * (iii) −log M_A(D) ≤ 2 + c.
* Hence K_A(D) + log W_A(D) → ∞, and W_A, M_A and 2^(−K_A) agree pairwise up to no constant. Also:
  * M_A/W_A is unbounded (P1 Prop 4.5 via F9);
  * on two atoms, K_A(D) − L_A(D) ≤ log d + O(log log d) (P1 Cor 4.10 via F9);
  * shared randomness is not a mixture of private coin facts (P1 Prop 4.7 via F9).

*Proof.*
* (i) Directly, without the transfer constant. Let ℓ := ⌈log(d/log 3)⌉ − 1, so 3^{2^ℓ} < 2^d.
  * Fewer than 2^ℓ programs have length < ℓ. Colour each x ∈ {0,1}^d by the vector, over these programs p, of: "+" if B ∪ W_{V(p)} is consistent and proves R(t_x); "−" if consistent and proves ¬R(t_x); "*" otherwise.
  * Two distinct x_1, x_2 share a colour. No short consistent theory proves ¬R(t_{x_1}) ∧ R(t_{x_2}), since it would colour x_1 "−" and x_2 "+". So K_A(D) ≥ ℓ > log d − 2.
* (ii) By F9(b) from P1 Prop 4.6(b): W(D′) ≥ 2^(−|D′|−K(⌈log(d+1)⌉)−c).
* (iii) By F9(a) from the fair-coin product law, P1 Prop 4.5: M_F(D′) ≥ 2^(−O(1))/4. ∎

*Answer to the brief's question.* Paper 1's log d gap recurs for axioms; there is no coding theorem.
* The reason is the same as in Paper 1: deterministic programs, here r.e. axiom sets, cannot separate atoms cheaply.
* The general upper bound replaces K(dom D) by K(question) (F10(c)).
* Large gaps have no computable witnesses. Along a computable family k ↦ D_k, K_A(D_k) ≤ K(k) + c, as in P1 Rem B.4. [proved]

**F12 (a coding theorem up to a factor 2 for whole theories) [proved, given Solovay, Vereshchagin, Shekhovtsov–Zakharov (known)].**
* For every r.e. T, with H(X) := min{|p| : W_{V(p)} = X} and I(X) := −log Σ{2^(−|p|) : W_{V(p)} = X} for r.e. sets X:
  * (a) K_≡(T) = H(Cn(T)) ± c and −log m_≡(T) = I(Cn(T)) ± c;
  * (b) −log m_≡(T) − c ≤ K_≡(T) ≤ 2·(−log m_≡(T)) + O(log(−log m_≡(T))).
* *Proof of (a).* Let κ be an injective computable map sending e to an index of "enumerate Cn(W_e)".
  * Every e′ with W_{e′} = Cn(T) lies in [T], and κ maps [T] into {e′ : W_{e′} = Cn(T)}.
  * Pushforwards of m under computable maps are dominated by m: m(e′) ≥ 2^(−c) Σ_{κ(e)=e′} m(e).
  * K(κ(e)) ≤ K(e) + c.
* *Proof of (b).* The right inequality is Solovay's theorem H(X) ≤ 3I(X) + O(log I(X)), improved to the factor 2 for finite sets by Vereshchagin and transferred to all sets up to logarithmic terms by Shekhovtsov and Zakharov [known; §8]. ∎

Open: whether the additive form K_≡ ≤ −log m_≡ + O(1) holds, and whether the one-tape class probability Π[T] ≍ m_≡(T) (§7, Q2). This matters for the limit loss on complete presentations (F23): L_A(D_n) → −log Π[T*].

### 3.5 Loss bounds

**F13 (loss against a theory that decides the data; which complexity appears) [proved].**
* Let (φ_t, b_t) be any sequence, chosen adversarially, adaptively or non-computably, in any order and with repeats.
* Let T be an r.e. theory with B ∪ T consistent and T ⊢ φ_t^{b_t} for all t ≤ n. Then the cumulative loss satisfies
  L_A(D_n) − L_A(∅) ≤ L_A(D_n) ≤ −log m(Ext(T)) + c ≤ −log m_≡(T) + c ≤ K_≡(T) + c.
* *Proof.* Every consistent extension of T proves all the data, so W_A(D_n) ≥ m(Ext(T)). Then F10(c), and [T] ⊆ Ext(T). ∎

*Which complexity appears.*
* Neither the complexity of a particular axiom set nor a property of the data's syntax: K_≡(T), the complexity of T up to deductive equivalence.
* More precisely, the algorithmic probability of the set of all consistent extensions of T.
* The bound favours the *weakest* theory that still decides the data: if T ⊆ Cn(T′), then Ext(T′) ⊆ Ext(T).
* For a non-finitely-axiomatisable T such as PA, K_≡(T) is small, although every axiom set is infinite.
* If T's simplest axiomatisation is a complicated finite set equivalent to a simple one, the simple one counts.

**F14 (laws plus exceptions; random theories) [proved].**
* (a) For every theory-machine law ν: L_A(D_n) ≤ −log ν(D_n) + K(ν). (F4.)
* (b) For every r.e. T and every E ⊆ D_n with B ∪ T ∪ E^± consistent and T ∪ E^± ⊢ ψ_{D_n}: L_A(D_n) ≤ K(e_T, ψ_E) + c ≤ K_≡(T) + K(ψ_E) + c.
  * *Proof.* The theory T ∪ {ψ_E} is consistent and proves the data. Its index is computable from (e_T, ψ_E). ∎
  * Taking E to be the data that T does not prove gives a two-part, law-plus-exceptions bound.
* (c) With ν := "T plus fair-coin facts on a fixed atom family", data that are atoms of that family cost one bit each. This is the setting of the laws-versus-initial-conditions scout (Kepler's laws plus orbital elements).

**F15 (mistakes; the Kolmogorov predictor) [proved].**
* (a) Under F13's hypothesis, the predictor that outputs the most probable of {true, false, independent} errs at most K_≡(T) + c times. Each error is a step with Bel_{D_{t−1}}(φ_t^{b_t}) ≤ ½, which costs at least one bit; above ½ the true label is the unique maximiser.
* (b) The *Kolmogorov predictor* uses the trichotomy of a shortest consistent axiomatisation compatible with D_{t−1}, abstaining when it is independent. It errs or abstains at most 2^{k+1} times, k := K_A(D_∞) ≤ K_≡(T) + c.
  * *Proof.* Each error or abstention eliminates the current shortest theory forever, and fewer than 2^{k+1} programs have length ≤ k. ∎
  * Whether exponentially many errors occur for some stream is not settled here. The analogous separation in P1 is for circuits: P1 Thm 9.10, the conjunction ladder, with simplest-consistent learning against circuit Bayes in P1 Thm 9.8. P1 Prop 5.11 gives the Occam bound for the single shortest program. Neither is checked for the theory case.

**F16 (merging for three-valued data) [proved, as P1 Thm 5.3].**
* Let G be a theory machine whose theory is almost surely consistent (ν_G(∅) = 1). Let A ~ ν_G.
* Let the questions φ_t be chosen by any rule that sees only the history and independent randomness, and let y_t ∈ {1, 0, ι} be A's trichotomy label of φ_t.
* With d_t := KL(ν^3_G(· | D_{t−1}, φ_t) ‖ M_A^3(· | D_{t−1}, φ_t)): Σ_t E d_t ≤ K(ν_G) + log M_A(∅) ≤ K(ν_G).
* *Proof.* M_A^3 ≥ 2^(−K(ν))·ν^3 by the tape argument of F4, which preserves all three conditions. Given the history, y_t has law ν^3(· | D_{t−1}, φ_t). The log ratios telescope to log(ν^3(D_n)/M_A^3(D_n)) + log M_A^3(∅). Integrability is as in P1 Thm 5.3. ∎
* With two-valued data the question rule would have to see A (ask only decided questions), and the expected bound can fail as in P1's remark after Thm 5.3. The pathwise bound F14(a) still holds.

**F17 (lower bounds).** F10(b) gives L_A(D) ≥ K(labels | dom D) − c. So fair-coin labels cost n bits on average, whatever the sentences. [proved]

### 3.6 The consistency-requiring variant

**F18 (CR updating is Dempster conditioning) [proved; computed: c1 A3].**
* Write ψ := ψ_D. Then M_A^nc(D) = Pl_0(ψ) := Bel_0(⊤) − Bel_0(¬ψ) and
  Bel^nc_D(φ) = [Bel_0(φ ∨ ¬ψ) − Bel_0(¬ψ)] / [Bel_0(⊤) − Bel_0(¬ψ)].
  This is Dempster's rule of conditioning of Bel_0 on ψ. PR (F2) is geometric conditioning.
* *Proof.* For a consistent A, A ∪ {ψ} is consistent iff A ⊬ ¬ψ, and A ∪ {ψ} ⊢ φ iff A ⊢ φ ∨ ¬ψ. Since A ⊢ ¬ψ implies A ⊢ φ ∨ ¬ψ, the numerator is Bel_0(φ ∨ ¬ψ) − Bel_0(¬ψ). ∎
* In the random-set picture, with focal sets Mod(A): Dempster intersects every focal set with Mod(ψ) and drops empty ones; geometric conditioning keeps only the focal sets inside Mod(ψ).

**F19 (the 0/1 CR weight learns nothing) [proved; computed: c1 A4].**
* (a) M_A^nc(D + (φ,1)) + M_A^nc(D + (φ,0)) = M_A^nc(D) + Pr[B ∪ A_ω ∪ D^± consistent and decides neither φ nor ¬φ] ≥ M_A^nc(D). So M_A^nc is a plausibility (2-alternating), not a semimeasure.
* (b) M_A^nc(D) ≥ 2^(−c) for every consistent D: tapes beginning with a program for the empty enumerator are always compatible. So −log M_A^nc ≤ c on all data. The Kolmogorov CR version is trivial: K^nc_A(D) ≤ c.
* This is the one-tape form of AI Prop 2.22(b) and pa Prop 5.2.

**F20 (the CR predictor has no constant-regret guarantee) [proved; computed: c1 B].**
* Under (Lit), take the stream R(t_1), R(t_2), … all labelled true, which T := {∀x R(x)} decides.
* The CR (Dempster) predictor loses at least −log(1 − 2^(−c_∅)) > 0 bits at every step, so linearly many bits. PR loses at most K_≡(T) + c = O(1) (F13).
* More generally, CR loses a constant at every step t at which D_{t−1} alone does not decide φ_t.
* *Proof.* The empty theory keeps CR posterior weight ≥ m(e_∅)/M_A^nc(D_{t−1}) ≥ m(e_∅) =: 2^(−c_∅). It leaves φ_t undecided, because B ∪ D_{t−1}^± does not decide it. So Bel^nc(φ_t^{b_t}) ≤ 1 − 2^(−c_∅). ∎
* Computed with a five-component prior (c1 Part B):
  * the PR loss converges to 1.848 bits = −log(w_all/consistent mass);
  * the CR loss grows at exactly 1.000 bit per step = log((w_∅ + w_all)/w_all);
  * the closed forms match a brute-force enumeration for k ≤ 7 atoms to 2·10^(−13).
* The CR cumulative loss also depends on the reveal order: a spread of 6.23 bits over the permutations of one three-datum sequence (c1 A6). PR's does not (F1(d); c1 A6, error 2·10^(−15)).

**F21 (the graded CR weight is the analogue of P1's weak semimeasure) [proved; computed: c1 D].**
* (a) For every consistent A, ν^½_A is a weak semimeasure on data sets: Σ_b ν^½_A(D + (φ,b)) ≤ ν^½_A(D). It is order independent (a product over the set).
* (b) M_A^½ ≥ M_A.
* (c) M_A^½ is not logically coherent: it charges for entailed data. For the empty theory and atoms p, q, ν^½_∅({(p,1)}) = ½ but ν^½_∅({(p,1), (p∨q,1)}) = ¼. So it is not the law of any theory machine, by F1(c).

*Proof.*
* (a) Take B ∪ A ∪ D^± consistent.
  * If A ⊢ φ^{b*}, then D + (φ, b*) keeps consistency with factor 1, and D + (φ, 1−b*) is inconsistent.
  * If A decides neither, each extension has factor at most ½.
  * If B ∪ A ∪ D^± is inconsistent, every term is 0.
* (b) ν^½_A(D) ≥ 1[A ⊢ ψ_D] for consistent A.
* (c) Direct computation. ∎

* In c1 Part D, M_A^½ was strictly smaller after an entailed datum in 261 of 400 trials, while M_A was unchanged in all of them.
* So the graded variant beats PR in total loss but gives up the "random consistent theory" reading, as P1's M_w gives up the posterior over functions.
* How large M_A^½/M_A can get is open (§7, Q4). The obstacle to domination is F27: no theory machine produces a consistent "fair coin on every sentence" completion above Q with positive probability.

### 3.7 Limits: what is identified

Let D_∞ = (φ_t, b_t)_{t≥1} be an infinite consistent labelled sequence. Put E_n := E_{D_n} (decreasing), E_∞ := ∩_n E_n = {A_ω consistent, Cn(A_ω) ⊇ D_∞^±}, and P_n := Unif(· | E_n).

**F22 (limit posterior) [proved].**
* If Unif(E_∞) > 0, then P_n → P_∞ := Unif(· | E_∞) in total variation. Hence sup_φ |Bel_n(φ) − P_∞(⊢φ)| → 0, and likewise for Dis and Indep.
* If Unif(E_∞) = 0, then M_A(D_n) → 0 and the cumulative loss → ∞.
* Unif(E_∞) ≥ 2^(−K_≡(T)−c) whenever some consistent r.e. T proves all of D_∞.
* *Proof.* |P_n(X) − P_∞(X)| ≤ 2·Unif(E_n ∖ E_∞)/Unif(E_n) uniformly in X, by continuity from above. The rest is F13. ∎
* The converse is open (§7, Q1): does Unif(E_∞) > 0 imply that some consistent r.e. theory proves D_∞? It holds for complete D_∞ (F26).

**F23 (complete decidable truths are identified up to equivalence) [proved].**
* Let T* be consistent, r.e. and complete relative to B (hence decidable), and suppose Cn(D_∞^±) = Cn(T*). This holds, for example, if every sentence appears with its T*-label, or if T*'s axioms appear labelled true.
* Then P_n([T*]) → 1 with [T*] := {ω : Cn(A_ω) = Cn(T*)}. Moreover sup_φ |Bel_n(φ) − 1[T* ⊢ φ]| → 0 and sup_φ Indep_n(φ) → 0.
* The total loss converges to −log Π[T*] + log M_A(∅) ≤ K_≡(T*) + c.
* *Proof.* A complete consistent theory has no consistent proper extension, so E_∞ = [T*]-tapes. Apply F22. ∎
* Examples: Presburger arithmetic, dense linear orders without endpoints, real closed fields, algebraically closed fields of fixed characteristic [completeness and decidability known].
* For a finitely axiomatised complete T*, P_n([T*]) = 1 as soon as the axioms have appeared.

**F24 (incomplete r.e. truths: two-valued data versus three-valued data) [proved; computed: c1 C].**
* Let T* be consistent and r.e. but not complete.
* (a) *Two-valued data.* If Cn(D_∞^±) = Cn(T*), then P_∞ = Unif(· | ΠExt(T*)): the prior restricted to the consistent extensions of T*, which is not identification. For every ψ independent of B ∪ T*:
  * lim Bel_n(ψ) = ΠExt(T*+ψ)/ΠExt(T*) ∈ (0,1);
  * lim Dis_n(ψ) = ΠExt(T*+¬ψ)/ΠExt(T*) ∈ (0,1);
  * lim Indep_n(ψ) ≥ Π[T*]/ΠExt(T*) > 0.
  * All three are positive and depend on the universal machine.
  * Among the deductive classes in Ext(T*), the prior alone decides which is most probable. It can be a strict extension, for example PA when T* is a complicated incomplete subtheory of PA with K_≡(T*) ≫ K_≡(PA). [proof sketch: needs an upper bound on Π[T*], cf. F12]
* (b) *Three-valued data.* If every sentence appears with its T*-trichotomy label, then P^3_n([T*]) → 1. Partial three-valued presentations on a set S identify Cn(T*) ∩ S together with the independence pattern on S.
* *Proof.* (a) E_∞ = Ext(T*)-tapes; positivity by F4 applied to the consistent r.e. theories T* + ψ, T* + ¬ψ and T*. (b) E^3_∞ = [T*]-tapes, of positive measure by F4. ∎
* Two-valued PR data are a *text*, a positive presentation, for Cn(T*). Three-valued data are an *informant*. This matches Gold's distinction [known: Gold 1967].
* The posterior is not computable, so this is identification by the limit posterior, not by a computable learner.
* Computed toy (c1 Part C, three atoms, T* with two models):
  * the two-valued limit leaves T* and its two completions;
  * the trichotomy of an independent sentence tends to (0.2245, 0.2449, 0.5306);
  * three-valued data leave only T*.

**F25 (computable structures and the ω-gap) [proved].**
* Let M be a computable structure for a language whose elements are all named by closed terms, and let the data be its atomic diagram.
* (a) L_A(D_n) ≤ K(M) + c, since Diag(M) is a decidable theory deciding the data.
* (b) P_∞ = Unif(· | ΠExt(Diag M)).
  * For M = ℕ in L_A and φ := x + 0 = x, Diag(ℕ) ∪ {∃x ¬φ} is consistent: add an element a with a + 0 := 0.
  * So lim Bel(∀xφ) and lim Dis(∀xφ) are both in (0,1).
  * This is the one-tape form of AI Prop B.8 and of the Bayesian ω-gap (AI Thm 3.9; AS Ex 4.9, Prop 4.7).
* (c) If Th(M) is decidable and the data present Th(M), F23 applies.

**F26 (non-decidable complete truths; Th(ℕ)).**
* (a) [proved, given de Leeuw–Moore–Shannon–Shapiro (known)] Let D_∞ present a complete consistent X that is not decidable, for example Th(ℕ) with B ⊆ Th(ℕ). Then Unif(E_∞) = 0, M_A(D_n) → 0 and the loss is unbounded.
  * *Proof.* On E_∞, Cn(A_ω) = X, so the probabilistic enumerator "G_U plus proof closure" enumerates exactly X with positive probability. Then X is r.e. (dLMSS), and a complete r.e. theory is decidable. ∎
  * The coin-free version is AI Prop 7.11 and time-followup Lemma 1.6.
* (b) [proved] For any computable enumeration of all sentences: K(labels_n | n) − c ≤ L_A(D_n) ≤ n + K(n) + c.
* (c) [proof sketch] In the length-lexicographic enumeration of L_A-sentences, with binary numerals built from 0, S, +, ·, there is δ > 0 with L_A(D_n) ≥ n^δ − O(log n) on Th(ℕ).
  * *Sketch.* β_k := "bit k of Ω_V is 1" is a Σ₂ sentence of size c₀ + O(log k), so its index is at most C·k^a.
  * The first n sentences contain β_1, …, β_m with m ≈ (n/C)^{1/a}, and their truth values are the first m bits of Ω_V.
  * Hence K(labels_n | n) ≥ K(Ω_{1:m}) − K(n) − c ≥ m − O(log n). Apply (b).
  * Not written out: the formalisation of β_k and the size constants.
  * With unary numerals the same argument gives only a logarithmic bound.

**F27 (random theories above Q are almost surely incomplete) [proved, given Jockusch–Soare and the effective inseparability of Q (known)].**
* (a) For every theory machine G, Unif{ω : B ∪ A^G_ω consistent, complete, and ⊢ Q} = 0.
* (b) For every function machine F, Unif{ω : f^F_ω is total and labels every PA-provable sentence 1 and every PA-refutable sentence 0} = 0.
* *Proof.*
  * (a) On that event, Cn(A_ω) ∩ Sent_{L_A} is a complete consistent extension of Q, decidable relative to ω.
    * It separates Q's provable sentences from Q's refutable sentences, an effectively inseparable pair [known].
    * Every separator of an effectively inseparable pair of c.e. sets has PA degree [known: Jockusch–Soare].
    * The sets of PA degree form a null class [known: Jockusch–Soare].
  * (b) Such an f_ω is computable from ω and separates the PA pair; argue as in (a). ∎
* *Consequences.*
  * (i) For every D, the posterior gives mass 0 to complete theories extending Q. The trichotomy can tend to (1,0,0) or (0,1,0) sentence by sentence, but never through a complete random theory.
  * (ii) Part (b) is the random-labeller form of the author's observation (prior note `a-predictive-model-assigning-truth-values-to-sentences.md`): no total computable labeller gets all PA-provable and PA-refutable sentences right ("consistent guessing"). With a random tape this holds almost surely.
  * (iii) This is why "theory plus a fair coin on every undecided sentence" is not a theory-machine law above Q (F21, §7 Q4).

### 3.8 The trichotomy: summary

| variant | P(true) | P(false) | P(independent) | update rule | as a predictor |
|---|---|---|---|---|---|
| PR (primary) | Bel_D(φ) | Bel_D(¬φ) | defect | geometric conditioning of Bel_0 (F2) | semimeasure, order independent, logically coherent (F1) |
| PR, three-valued | Bel_D(φ) | Bel_D(¬φ) | outcome | same | additive measure (F1(f)) |
| PR, normalised | Bel/(Bel+Dis) | Dis/(Bel+Dis) | 0 | per query | upper bounds transfer; incoherent across sentences (AI Ex 2.15) |
| CR | Bel^nc_D(φ) | Bel^nc_D(¬φ) | Pl+Pl−1 | Dempster conditioning (F18) | 0/1 weight is a plausibility (F19); sub-probability predictor has linear loss and is order dependent (F20) |
| graded CR (½) | — | — | — | — | weak semimeasure ≥ M_A, charges entailed data (F21) |
| generative | question-weighted Bel | same | 0 (answer presupposed) | Bayes with size principle (§2.9) | identifies Th(T*) on well-specified data (AI Thm 4.7) |

Limits:
* complete decidable truth: (1,0,0)/(0,1,0) uniformly (F23);
* incomplete truth, two-valued: three positive prior shares on independent sentences (F24(a));
* three-valued: identification (F24(b));
* above Q: random theories almost surely incomplete (F27).

On the author's three options (N4):
* keep the semimeasure, i.e. keep Indep as the defect or make it an outcome (M_A^3). This is the recommended reading.
* Renormalising is the normalised convention, coherent sequentially but not across sentences.
* The 50/50 split is coherent exactly when every theory of positive mass has at most two models (AI Prop 2.17). It is the one-theory case of the graded weight with grade ½ (F21), which charges for entailed data.

---

## 4. Computations

`checks/c1_toy.py` (seed 20261015; output `checks/c1_toy.out`; runs in 0.1 s) is a finite propositional stand-in:
* propositions are sets of valuations, and theories are model sets (mask 0 is the inconsistent theory);
* priors are random finite lists, some with inconsistent mass.

* **Part A** (400 random instances, 3 atoms):
  * the semimeasure inequality (max excess 0);
  * defect = Indep (error 1.1·10^(−16));
  * PR = geometric conditioning (error 0);
  * CR = Dempster conditioning (error 2.2·10^(−16));
  * M^3 additive (error 2.2·10^(−16));
  * the CR plausibility weight sum ≥ its value, strictly in 182 trials;
  * PR loss order independent (error 1.8·10^(−15));
  * CR (Dempster) loss order dependent: spread 6.23 bits on one three-datum sequence.
  These check F1, F2, F18, F19 and F20 on finite instances; they are not independent of the definitions, which they implement directly.
* **Part B:** the separation of F20. PR loss 1.848 bits at t = 40 (limit 1.8480). CR loss 40.43 bits, slope 1.0000 bit/step, equal to the predicted log((w_∅+w_all)/w_all). Closed forms match a brute-force enumeration (k ≤ 7) to 2.1·10^(−13).
* **Part C:** F24 on a three-atom T* with two models. The two-valued limit leaves 3 theories, with independent-sentence trichotomy (0.2245, 0.2449, 0.5306); the three-valued limit leaves only T*.
* **Part D:** F21. The graded weight is a weak semimeasure (max excess 2.2·10^(−16)) and ≥ M_A (min difference 0). It charges for an entailed datum in 261 of 400 trials, while M_A never does (asserted).

---

## 5. Ranked candidate fundamentals theorems

Assessment columns: **true?** (status), **hard?** (effort to a paper-quality proof), **new?** (relative to AI, AS, P1 and the literature checked).

| rank | candidate | true? | hard? | new? | role in the paper |
|---|---|---|---|---|---|
| 1 | **Definition and universality**: theory machines, G_U, M_A; mixture identity; dominance M_A ≥ 2^(−K(ν))ν; invariance under machine, background and faithful translation (F4–F7) | proved | easy | new (one-tape axiom version) | the definitional backbone, parallel to P1 §3 |
| 2 | **Loss bound in K_≡**: on any sentence sequence that a consistent r.e. T decides, cumulative loss ≤ −log m(Ext T) + c ≤ K_≡(T) + c; laws plus exceptions; theory-machine K(ν) bound; mistakes; three-valued merging (F13–F16) | proved | easy | new in this form | the "Theorem A" of the paper; answers "which complexity appears" |
| 3 | **One-tape equivalence with consistent SFI** (the author's conjecture), **and the atomic fragment = binary SFI ⊃ SI** (F8, F9) | proved | easy | new; AI Thm 6.3 is the coin-free decider form | bridges to SFI; the relation-to-SFI section builds on it |
| 4 | **Versions**: chain with K(question) slack; coding lower bound; **no coding theorem**, with the log d gap on two atoms; M_A/W_A unbounded (F10, F11) | proved (part by transfer) | moderate | new | the "Theorem B" analogue; answers the brief's coding-theorem question |
| 5 | **Trichotomy structure**: PR = geometric conditioning, CR = Dempster conditioning of the probability of provability; Indep = semimeasure defect; three-valued completion additive; order independence; entailed data free (F1, F2, F18) | proved; computed | easy | new framing; ingredients known (Pearl, Suppes–Zanotti, Shafer) | makes the author's trichotomy precise and ties it to belief-function theory |
| 6 | **Limits and identification**: limit posterior; complete decidable truths identified up to equivalence with uniform trichotomy; incomplete truths give three positive prior shares; three-valued data identify (text vs informant); ω-gap; Th(ℕ) loss unbounded (F22–F26) | proved; Th(ℕ) rate is a proof sketch | moderate | new for this object; Gold analogue known in spirit | the learning-in-the-limit section; links to formal learning theory |
| 7 | **CR separation**: the 0/1 CR weight learns nothing; the Dempster predictor has linear loss where PR has O(1); graded CR is the weak-semimeasure analogue (F19–F21) | proved; computed | easy | partly known (AI Prop 2.22(b), pa Prop 5.2); the linear-loss and conditioning statements are new | justifies PR as primary |
| 8 | **Non-lower-semicomputability and the consistency Ω**: M_A = Q − Inc_0, with Inc_0 Solovay complete (F3) | proved (randomness given Kučera–Slaman) | easy | new | explains the main structural difference from P1 |
| 9 | **Random theories above Q are almost surely incomplete**; random labellers fail consistent guessing a.s. (F27) | proved given known results | easy given citations | new application | supports the limitations discussion and F21 |
| 10 | **Coding theorem up to a factor 2 for whole theories** (F12, via Solovay) | proved given known results | easy | new connection | for the limits section; open additive form |
| 11 | **Language expansion**: theoretical vocabulary changes universal weights by O(1) (F7′) | proved | easy | new statement; Craig-type content known | hand-off to the theoretical-terms scout: advantages must be resource-bounded |

Conjectures and open items worth assigning (§7): Q1–Q6.

---

## 6. Recommended definitions and notation

* **Primary object:** the proof-requiring one-tape law M_A (macro `\MA`).
  * Random axiom set A_ω and random theory Cn(A_ω).
  * Theory machines G with law ν_G; universal G_U.
  * Background B, a stated parameter, default ∅ (the experiments and arithmetic examples use Q).
* **Data:** finite sets D of labelled sentences, labels 1/0 (and ι for three-valued), ψ_D the conjunction of the literals. Note that D need not be a partial function.
* **Predictive quantities:** Bel_D, Dis_D, Indep_D (reuse AI's macros `\Bel`, `\Dis`, `\Indep`), with Bel_0 the prior probability of provability.
  * L_A(D) := −log M_A(D). Cumulative loss is L_A(D_n) − L_A(∅) (semimeasure convention).
  * M_A^3 for three-valued scoring.
* **Versions:**
  * W_A (coin-free) and K_A (Kolmogorov), stating that deciders, enumerators and polynomial-delay enumerators agree up to O(1);
  * K_fin separately if needed.
* **Theory complexities:**
  * K_≡(T), m_≡(T), Ext(T), [T];
  * one-tape Π[T], ΠExt(T).
* **Variants:**
  * M_A^nc (consistency-requiring 0/1 weight) with Bel^nc (Dempster);
  * M_A^½ (graded).
  * Generative: AI's P_T (L1) with mixture Ξ.
* **SFI side:**
  * write function machines F (not T);
  * M_F^cons, W^cons, K_F^cons for consistent SFI.
* **Statements to make first, in order:**
  1. Def 2.2–2.4;
  2. F1 (structure);
  3. F4–F5 (dominance, invariance);
  4. F13 (loss bound);
  5. F8–F9 (relation to SFI);
  6. F10–F11 (versions);
  7. F2, F18 (conditioning rules);
  8. F22–F24 (limits);
  9. F3, F27 as remarks.
* CR and graded variants belong in one subsection with F19–F21 as the reason PR is primary.
* **Avoid:** "axiom set complexity" in loss bounds (use K_≡); the bare word "semimeasure" for M_A^nc (it is a plausibility); claims that M_A is lsc.

---

## 7. Open questions

* **Q1.** Does Unif(E_∞) > 0 imply that some consistent r.e. theory proves all of D_∞? It is true for complete D_∞ (F26). A density argument gives an r.e. set of "majority theorems", but not obviously a consistent one.
* **Q2.** Is Π[T] ≍ m_≡(T), i.e. does the random tape help for whole theories? Is K_≡(T) ≤ −log m_≡(T) + O(1), or does the factor of F12 matter? This determines the limit loss on complete presentations.
* **Q3.** What is the growth rate of L_A(D_n) on Th(ℕ) in natural enumerations? It lies between n^δ (F26(c), sketch) and n + K(n). Is it o(n)? That asks whether simple theories decide a positive fraction of short sentences.
* **Q4.** How large can log(M_A^½(D)/M_A(D)) be? The proved bounds are ≥ 0 (F21) and, via F10, at most K(dom D) + |D| + c. A linear gap analogous to P1 Thm 3.12(iii) is plausible [conjecture]: logical constraints play the role of P1's three-input weak semimeasure, and F27 blocks consistent random completions.
* **Q5.** Normalised convention: is the normalised loss of M_A order dependent? This is likely, as for P1 Prop 3.17(b) [conjecture]. Which lower bounds transfer?
* **Q6.** Does M_A dominate every "lower semicomputable probability of provability", for instance every random set of sentences whose cylinder probabilities are lsc? This is the analogue of P1 Question 3.14.
* **Q7.** Exponential separation for the Kolmogorov predictor (F15(b)) on sentence data.

---

## 8. References (verification status)

* **Earlier reports and P1**: printed numbers taken from `../axiom-induction/paper/main.aux`, `../axiom-schemas/paper/main.aux`, `../solomonoff-function-induction/paper/main.aux` (checked in this session).
* P. Suppes, M. Zanotti, "On using random relations to generate upper and lower probabilities", *Synthese* 36(4):427–440, 1977, doi:10.1007/BF00486106. Bibliographic data checked by search. That it is the source of the geometric rule Bel(A∩B)/Bel(B) is stated by secondary sources (Cuzzolin's survey); the paper's text was not read.
* J. Pearl, *Probabilistic Reasoning in Intelligent Systems*, Morgan Kaufmann, 1988: the "probability of provability" reading of belief functions. Known via secondary sources (a survey of Dempster–Shafer interpretations, Pearl's own later note); chapter not checked.
* G. Shafer, *A Mathematical Theory of Evidence*, Princeton, 1976: belief functions, Dempster's rule. Standard; as cited in AI.
* R. Solovay, "On random r.e. sets", 1977: H(A) ≤ 3I(A) + O(log I(A)). Known via the abstracts of Vereshchagin and of Shekhovtsov–Zakharov; original not read.
* N. Vereshchagin, "Kolmogorov complexity of enumerating finite sets", *Information Processing Letters* 103(1):34–39, 2007 (ECCC TR04-030). Factor 2 for finite sets. Abstract-level check.
* A. Shekhovtsov, G. Zakharov, "Enumerating complexity revisited", arXiv:2312.04187 / ECCC TR23-201, 2023. A finite-set bound transfers to all sets up to logarithmic factors, giving factor 2 for all sets. Abstract-level check.
* C. Jockusch, R. Soare, 1972 (Π⁰₁ classes and degrees of theories). Two facts are cited via secondary sources (Hirschfeldt, *Slicing the Truth*, Thm 3.20; Kučera's slides; a 2022 paper on randomness below complete theories): PA degree iff computes a separator of an effectively inseparable pair; the sets of PA degree form a null class. Original not read.
* F. Stephan, "Martin-Löf random and PA-complete sets", *Logic Colloquium '02*. ML-random PA-complete implies ≥_T ∅′. Context only; secondary sources.
* Effective inseparability of Q's theorems and refutable sentences: listed as a standard example in A. Visser, "There are no minimal effectively inseparable theories", arXiv:2211.06190, and Y. Cheng, "Effective inseparability and some applications in meta-mathematics", *J. Logic Comput.* 34(6):1010–1031, 2024. Abstract and snippet level.
* A. Kučera, T. Slaman, "Randomness and recursive enumerability", *SIAM J. Comput.* 31:199–211, 2001: Solovay-complete left-c.e. reals are exactly the ML-random ones (with Calude–Hertling–Khoussainov–Wang). Statement checked via secondary sources; volume and pages recalled.
* K. de Leeuw, E. F. Moore, C. E. Shannon, N. Shapiro, "Computability by probabilistic machines", *Automata Studies*, Annals of Mathematics Studies 34, Princeton, 1956, pp. 183–212. A set enumerated with positive probability by a probabilistic machine (fair coins) is r.e. Bibliographic data checked; the statement in this form is from secondary sources.
* E. M. Gold, "Language identification in the limit", *Information and Control* 10:447–474, 1967 (as in AI's bibliography): text vs informant.
* E. Martin, D. Osherson, *Elements of Scientific Inquiry*, MIT Press, 1998; D. Osherson, M. Stob, S. Weinstein, "A universal inductive inference machine", *J. Symbolic Logic* 56(2), 1991 (a computable universal scientist in a first-order paradigm). Bibliographic data checked; contents not read. For the learning-theory scout.
* A. Demski, "Logical prior probability", AGI 2012, LNCS 7716, pp. 50–59 (dblp). A random process adds random sentences if consistent with those chosen, which needs a halting oracle. It gives a probability over completions, whereas M_A keeps the independent mass and needs no oracle to define, only to compute. Secondary sources; for the related-approaches scout.
* W. Craig, R. Vaught, "Finite axiomatizability using additional predicates", *J. Symbolic Logic* 23, 1958. Recalled, not checked; F7′ does not depend on it.
* Standard facts used without separate citation: the conditional coding theorem and the domination of lsc semimeasures by m (as cited in P1 §3.1); Ω_V is not computable; completeness and conservativity of first-order logic.

---

## 9. Verification log

**Sources read in full or in the relevant parts.**
* The brief.
* The author's note `hanni-solomonoff-axiom-induction.md` and `a-predictive-model-assigning-truth-values-to-sentences.md`.
* AI: `main.tex`; `sections/model.tex`, `time.tex`, `ident.tex`; `app-time.tex` §E.1–E.3; the relevant items of `app-universal.tex`, `pa.tex`.
* AI records: model §6.1, §7; time-followup §1–2; pa §3.7, §5.6.
* AS: `README.md` and its §4 label list.
* P1: `NOTATION.md`, `sections/setting.tex`, `versions.tex`, `app-versions.tex`, the dominance and merging parts of `learn.tex`, and the introduction.

**Printed numbers.** All AI, AS and P1 numbers above were read from the three `main.aux` files in this session (label → number table), not from memory.

**Checks.**
* `c1_toy.py` was run twice; outputs are byte-identical (`diff` empty).
* The script implements the definitions directly on a finite propositional model. It confirms identities (F1, F2, F18–F21) and the F20/F24 numbers, not the infinite-machine statements.

**Self-checks that changed the claims during drafting.**
1. *"M_A is lower semicomputable like M_F"* was the first assumption. **[refuted]** by F3: M_A(∅) = 1 − Inc_0 is not left-c.e.
2. *"The consistency-requiring variant gives a semimeasure"*. **[refuted]** F19(a): the 0/1 weight is a plausibility (sum over labels ≥ the weight; strict in 182/400 toy trials). Its proper predictor is the Dempster sub-probability, which is order dependent.
3. *"Unif(E_∞) > 0 iff some consistent r.e. theory proves D_∞"*. Downgraded to an open question (Q1). The density argument yields an r.e. set of majority theorems but no consistency guarantee. Only the ⇐ direction and the complete case are claimed.
4. *"Graded CR is just a reweighting of PR"*. Corrected to F21: it dominates M_A, is a weak semimeasure, and is not logically coherent.
5. *A coding theorem for single sentences.* Ruled out by F11: the two-atom data set is a single sentence ψ_D.
6. *"The posterior's most probable class in the incomplete case is [T*]"*. Corrected to F24(a): the prior decides, and it can be a strict extension. The example needs an upper bound on Π[T*] and is marked proof sketch.

**Not done.**
* No referee.
* The integrability step of F16 is cited from P1, not rewritten.
* F26(c) is a sketch.
* The references marked "secondary sources" were not read in the original.
* Nothing was checked in a proof assistant.
