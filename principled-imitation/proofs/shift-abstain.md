# Inputs from outside the closed system, and failing obviously (key: shift-abstain)

Proofs for Sections 6 and 7 of the note. This file is the proof file `research/prove-c/shift-abstain.md` of the worker of the third proving round ("the prover"), corrected by the editor of this part after two verification reports: `verification/shift-abstain-check.md` ("the check report", a line-by-line check) and `verification/shift-abstain-attack.md` ("the attack report", an adversarial reading). It covers S1 and S3 of the lead's list of claims `research/candidate-theory.md` (version 2; "the candidate theory"), the three kinds of shift, the online form of asking, Ab1, Ab2, Ab3, N4 and the trade-off between silent errors, abstentions and questions. N3 and S2 are proved in `proofs/lower-bounds.md`, Section 4, and are used here by reference. Every statement below is proved in this file unless it says otherwise. Statements and passages that the editor added or rewrote after the reports are marked "(editor)". Section 12 lists every finding of the two reports with what was done about it, and says for each statement that the note uses who checked its proof. Scripts and their saved outputs are in `proofs/code/` (`shift-abstain_*.py`, `shift-abstain_*.out`); Section 8 quotes the outputs.

**Labels in the note.** The note uses the labels of `research/outline.md` (Addendum 3): S1 (Propositions 2.1 and 2.3 with Example 2.2), S3 (Proposition 2.4), **N7** (Theorem 3.3 with Corollary 3.6), Ab1 (Theorems 4.1 and 4.4), Ab2 (Theorems 5.1, 5.3 and 5.6 with Proposition 5.2), Ab3 (Propositions 6.1 and 6.2), N4 (Proposition 7.1 with Corollary 7.2), **Ab4** (Theorem 7.3). Two labels are new and are announced by the editor: **S4** (Theorem 2.5, the three kinds of shift) and **S5** (Theorem 3.1, the online form). All other statements of this file have no label in the note and are cited there by their number in this file.

## 0. Summary

### 0.1 Table of statements

| no. | statement | in the candidate theory | label in the note | tag |
|---|---|---|---|---|
| Lemma 1.1 | Regret of the Bayes mixture on any adaptively chosen asked inputs: Σ E[a_t·KL] ≤ K ln 2; Hellinger and squared-TV forms; for a function Π(1 − e_t) ≥ w(f) on every path | L3 | (tool) | PROVED (standard) |
| Lemma 1.2, Corollary 1.3 | In rehearsal driven by any answer rule the asked call is a uniformly chosen call of the driver's run; R1 for any driver | R1 | (tool) | PROVED (the reduction of Ross, Gordon and Bagnell in the form of Li and Zhang) |
| Lemma 1.4 | Coupling of a kernel's run with the human system up to the first unfaithful call: separation probability p ≤ β; visit measures differ by at most (L − 1)p; errors along the human's run are at most L times the errors along the own run | L2 | (tool) | PROVED (the factor L is the compounding of errors of Ross and Bagnell) |
| Proposition 2.1 | S1 for a change of the law of the top-level input: factor B; a truncated form for unbounded ratios; the factor is necessary | S1 | S1 | PROVED (S1 MODIFIED: stated for the top-level law) |
| Example 2.2 | S1 as the candidate states it, with the average rehearsal visit measure, fails by the factor L/(2 ln L) | S1 | S1 (counterexample) | REFUTED as stated |
| Proposition 2.3 | With visit measures the factor is (2L − 1)·B, and at least L/2 is needed | S1 | S1 (form for visit measures) | NEW |
| Proposition 2.4 | S3: a task property of rehearsal probability β costs exactly 1/β for a rehearsal on D₀ and N for N unknown properties; a known property costs nothing | S3 | S3 | PROVED (meaning made exact) |
| Theorem 2.5 | The three kinds of shift: self-produced (factor 1), to a described law (density ratio; 2^k for all laws of k bits), anything else (no guarantee) | task item 1 | S4 | PROVED (collects R1, S1, S2, N3, N1) |
| Theorem 3.1 | Each step put to the human with probability q for ever: E Σ KL ≤ K ln 2/q over all steps; silent errors ≤ (1 − q)K ln 2/q for a function | Observation A | S5 | PROVED (label-efficient prediction applied to the Bayes regret) |
| Example 3.2 | Both bounds are attained: equality in the limit for the divergence (if W = 1), factor 2 ln 2 for silent errors | — | — | PROVED |
| Theorem 3.3, Lemma 3.4 | Thresholds, answers only on questions: E[Sil + Abs]·(Q + 1) ≥ 3N/16 for at most Q ≤ N/2 − 1 questions; E[Sil + Abs]·(E[Qu] + 1) ≥ N/15 for E[Qu] ≤ N/4 − 1; within the factor 2 of the optimum | digest, Section 3.4 | N7 | PROVED (constant improved from 1/32; parts (b), (c) NEW) |
| Corollary 3.5 | The factor K in "silent errors × questions ≤ h·K ln 2" cannot be removed: product of threshold classes, for learners that ask at least u = K/log N₁ questions | — | — | NEW |
| Corollary 3.6 | When the asking can stop: for a class that contains N thresholds and a horizon of h ≤ N − 1 inputs, at most s expected silent mistakes and abstentions need at least 3(h + 1)/(16s) questions (or (h + 1)/2); conversely, for every class and every deterministic human, finitely many questions suffice for an unbounded deployment (at most 2^k − 1 for a known bound k ≥ K). The prover's reading "the asking cannot stop" was false | Section 0, item 4 | N7 | PROVED (restated by the editor after both reports) |
| Theorem 4.1 | Ab1: on any asked sequence, (wrong rounds)·log(1/η) + (abstention rounds)·log(1/(1 − η)) ≤ K; never wrong if η < w(f) | Ab1 | Ab1 | PROVED |
| Example 4.2 | Each of the two counts is attained | Ab1 | — | PROVED |
| Proposition 4.3 | With answers seen only on questions: the abstention count bounds the questions; silent errors are unbounded if η ≥ w(f); with audits at rate q, E[Sil] ≤ ((1 − q)/q)·K/log(1/η) | Ab1 | Ab1 | PROVED; part (b) NEW |
| Theorem 4.4 | Ab1 under rehearsal driven by the threshold rule: per run E[wrong answers] ≤ L·K/(n·log(1/η)), Pr[abort] ≤ L·K ln 2/(n·η) | Ab1 | Ab1 | PROVED |
| Theorem 4.5 | Closed system, needle class with cells of equal mass: silent failure σ with abort probability a needs n ≥ (1 − a)²·L/(4σ) − L | — | — | NEW |
| Example 4.5a (editor, from the attack report) | The same class with cells of unequal mass: abstention on rare cells reduces the questions needed from N₁/2 ≥ a/(8σ) − 1/2 to 1. So Theorem 4.5 is a worst case over scaffolds and not a property of closed systems | — | — | PROVED (counterexample to the prover's reading of Theorem 4.5) |
| Proposition 4.6 | Thresholds with every answer shown: at most k wrong answers forces (k + 1)·N^(1/(k+1))/e − k − 1 abstentions; exact value C(m + 1, ≤ k + 1) − 1 | "in line with N4" | — | PROVED (exact form due to Zhang and Chaudhuri 2016) |
| Proposition 4.7 | A stochastic human with a mode: both counts hold in expectation, with kl-divergences in the denominators | Ab1, stochastic version | — | NEW |
| Proposition 4.8 | No rule has both counts for all members of a class of samplers | Ab1, stochastic version | — | NEW |
| Theorem 5.1 | Ab2, dominance: the minimum rule over a set containing the human is the human system with a visible abort; TV equals the abort probability; bounds on the abstention probability | Ab2 | Ab2 | PROVED |
| Proposition 5.2 | Three plausible sets (absolute, cumulative, ratio), their sizes, Ville's bound α/w(P), no loss for functions, the prior-averaged version | Ab2 | Ab2 | PROVED |
| Theorem 5.3 | Coverage in the class of all programs: the rule abstains wherever sep(x; A) ≤ log(1/α) − c and, for functions, only where sep(x; A) ≤ K + K_D + log(1/α) + c; the threshold rule abstains wherever sep(x; A) < log(1/η) − c | Ab2 | Ab2 | PROVED (inner region: candidate's claim with the constant made explicit, MODIFIED; outer region NEW) |
| Proposition 5.4 | The minimum rule abstains exactly where every rule that is sound for its plausible set must | — | — | PROVED |
| Corollary 5.5 | What a moderate α gives under the assumption "within log(1/α) bits of the best explanation": exact dominance, a list of refused inputs, answers beyond a radius; the assumption cannot be checked | Ab2 | Ab2 | PROVED |
| Theorem 5.6 | Abort probability of the frozen rule on the rehearsed closed system, for functions and for samplers | — | Ab2 (abort bound after rehearsal) | NEW |
| Example 5.7 | The ratio set is a rock on the needle class until n is near 2^K; with weights 2^(−length) fill-ins of the coins make the rule useless at K = 1 | — | — | PROVED |
| Section 5.5 | Cohen, Hutter and Nanda (2022): their five theorems, and what in Ab2 is theirs | task item 4 | — | literature, read in the source |
| Proposition 6.1 | Ab3: at most 2^s − 1 questions; never wrong if s > 2K + c₂; comparison with enumeration | Ab3 | Ab3 | PROVED |
| Proposition 6.2 | Ab3 when nobody answers: refuses {sep(x; A) < s} for ever; with a sound s this is every input simpler than 2K; share of refused calls of the rehearsal runs; (item 4, editor) when the rule drives the rehearsal, the deployed run is aborted with probability at most L·(2^s − 1)/n | Ab3 | Ab3 | PROVED; item 3 NEW; item 4 added by the editor, not checked by a verifier |
| Proposition 7.1, Corollary 7.2 | N4: never silently wrong forces asking or abstaining wherever two members differ; 2^d on the point functions | N4 | N4 | PROVED |
| Theorem 7.3 | The trade-off between silent errors, abstentions and questions, with upper and lower bounds | task item 6 | Ab4 | PROVED (collects the above; the paragraph "In words" rewritten by the editor) |
| Definition 7.4, Proposition 7.5 | Rocks and whitelists: a rule that is sound for a slack of a bits refuses all a-simple novelty; which rule is which | task item 6 | — | PROVED |
| Section 9 | Open questions | — | — | OPEN |
| Section 12 | Checking: the findings of the two reports and what was done; who checked which proof | — | — | — |

The tag NEW means only that the statement is not in the candidate theory. It is not a claim of novelty; Section 11 and the attributions in the text say what is known from the literature.

**In brief.** (1) S1 holds with the density ratio B when the law of the top-level input changes, and is false by a factor of order L when stated with visit measures; the true factor there is between L/2 and 2L − 1. S3 is correct once "costs 1/β" is read as the price of a property that was not singled out in advance. The shift that a decomposition produces by itself costs nothing under rehearsal; a shift to a described law costs the density ratio; any other shift has no guarantee. (2) Asking each call with probability q for ever bounds the total divergence by K ln 2/q on any inputs, with equality in the limit when W = 1. Whether the asking can stop depends on the human. For a deterministic human in a fixed class it can, after a number of questions that is finite and, in the worst case, exponential in K: for N = 2^K thresholds, (silent mistakes plus abstentions) × (questions + 1) is at least 3N/16, and enumeration never errs after at most 2^k − 1 questions for a known bound k ≥ K. For a person 2^K is no bound. In the upper bound h·K ln 2 for the product of silent errors and questions under random asking, the factor K is necessary up to a logarithm. (3) Ab1 is correct. Its two counts are attained, the exponential rate between them is necessary (thresholds), and under rehearsal they become per-run bounds. In the closed system of the needle class with cells of equal mass, abstention saves at most the factor (1 − a)² in questions; this is a worst case over scaffolds, and where the unlearned inputs are rare and recognisable abstention saves an unbounded factor (Example 4.5a). For a stochastic human the counts survive only if the human has a mode, and no rule has both for all samplers. (4) Ab2 is correct: the minimum rule is the human system with a visible abort. In the class of all programs it abstains wherever a test of log(1/α) − c bits separates the input from the asked ones, and for functions nowhere beyond K + K_D + log(1/α) + c bits. With α small enough for Ville's inequality it refuses every input simpler than the human; with a moderate α it is a whitelist whose soundness is an assumption that the data cannot confirm. On the rehearsed closed system its abort probability is bounded at a price polynomial in 1/α, provided the weights are summable in square root. The rule, the cumulative top set and the Ville step are those of Cohen, Hutter and Nanda; the frozen use, the exact dominance of runs, the coverage theorem and the closed-system bound are not in their paper. (5) Ab3 is correct with the constant of the difference test; frozen, with the sound parameter, it refuses every input simpler than twice the human. (6) The trade-off is Theorem 7.3; Proposition 7.5 says which rules are rocks (the threshold rule, the ratio rule and the novelty rule whenever their parameter makes soundness a theorem; enumeration as long as its budget exceeds the complexity of the best explanation of the data by more than the complexity of the inputs) and which are whitelists (the same rules with a moderate parameter, sound by assumption).

### 0.2 Conventions

* log is log₂ and ln is the natural logarithm. KL is in nats. TV(p, q) := ½ Σ_y |p(y) − q(y)|. H²(p, q) := 1 − Σ_y √(p(y) q(y)). For kernels C, C′ and an input x, TV(C, C′)(x) abbreviates TV(C(·|x), C′(·|x)), and likewise KL(C ‖ C′)(x) and H²(C, C′)(x).
* (x)⁺ := max(x, 0). C(t, ≤ j) := Σ_{i=0}^{j} C(t, i) is a sum of binomial coefficients.
* "Function" means a sampler whose answers are deterministic. "Asked input" means an input that was put to the human.
* Where the text says "I", the prover speaks, except in passages marked "(editor)".

### 0.3 Changes of notation, and symbols added to those of `research/outline.md`

1. The outline uses D₀ for the law of the top-level input and D for data. To keep the two apart, the data gathered in rounds 1, …, t − 1 are written D_{<t} (so D_{<1} is the empty list), and the data after n rounds D_{≤n}. M^(t) := M_{D_{<t}}, as in the outline.
2. The outline uses T for the uniformly chosen round whose rule is deployed. The number of calls of a run τ is written len(τ), and ℓ_t for the run of round t. The number of steps of an open-ended interaction is written h ("horizon").
3. A(D) is the set of inputs that occur in the data D. The letter A alone is used for sets of inputs, as in sep(x; A), and for nothing else; an answerer is called G, a kernel C.
4. Rules that may abstain: Thr_η (threshold rule, Section 4), Min_𝒞 (minimum rule over a plausible set 𝒞, Section 5; its sub-probability kernel is S_𝒞, the candidate's S_C), Nov_s (novelty rule, Section 6). The symbol ⊥ is the abstention.
5. Counts in the trade-off statements are written as words: Sil (silent errors), Abs (abstentions), Qu (questions).
6. W := Σ_ν w(ν) ≤ 1 is the total weight of the class, w_max(D) the largest posterior weight after D, and K_D := log(1/max{w(ν) : ν(D) > 0}) for a class of functions (the complexity of the best explanation of D).

### 0.4 What is used from other files

* `proofs/lower-bounds.md` (cited as LB; the corrected file, whose numbering of these statements is that of `research/prove/lower-bounds.md`): Lemma 1.5 and Theorem 1.6 (N1), Corollary 1.7, Proposition 1.8, Lemma 1.10 (patch family), Theorem 2.1 and Corollary 2.2 (N2), Theorem 4.1 (N3), Corollary 4.2, Theorem 4.3, Proposition 4.4 (S2). These are used as stated there; the prover checked the proofs of Lemma 1.10, Theorem 4.1, Theorem 4.3 and Proposition 4.4(a) while using them and found no error.
* `proofs/hellinger-runs.md` (cited as HR): Theorem 3.1(b) (R2 in general: E TV(Q_{M^(T)}, Q_P) ≤ √(2·L·K ln 2/n) in the corrected file; the prover's file quoted the earlier constant 2√(L·K ln 2/n)). Used only in Proposition 2.1(c); not re-checked here.
* The regret bound for Bayes mixtures on adaptively chosen questions (the candidate's L3) and Theorem R1 are re-proved here in the form needed (Lemma 1.1, Corollary 1.3), so that this file can be read alone.

## 1. Setting and tools

### 1.1 Objects

**Samplers, hypotheses, the class.** X and Y are countable sets, and Y has at least two elements; b₀ ≠ b₁ are two fixed elements of Y. Put Y_⊥ := Y ∪ {⊥}. A *sampler* is a probability kernel S(·|x) on Y. A *hypothesis* is a conditional semimeasure: ν(y|x) ≥ 0 with Σ_{y∈Y} ν(y|x) ≤ 1; the missing mass 1 − Σ_y ν(y|x) is put on ⊥, so that a hypothesis is a probability kernel on Y_⊥. A *function* f : X → Y is the sampler that answers f(x) with probability 1. The human is a sampler P (assumption A1: every question x is answered by a fresh draw from P(·|x)). H is a countable set of hypotheses with weights w(ν) > 0, W := Σ_ν w(ν) ≤ 1, and P ∈ H (assumption A2). K := log(1/w(P)).

**Data, posterior, mixture.** A *data list* D is a finite sequence of pairs (x_i, y_i) ∈ X × Y; D + (x, y) is D with one pair appended; A(D) is the set of the inputs x_i. Put ν(D) := Π_i ν(y_i|x_i) and ξ(D) := Σ_ν w(ν) ν(D), so ξ(∅) = W. If ξ(D) > 0, the posterior is w_D(ν) := w(ν) ν(D)/ξ(D), its largest value is w_max(D), and the mixture is

  M_D(y|x) := Σ_ν w_D(ν) ν(y|x) = ξ(D + (x, y))/ξ(D) for y ∈ Y.

Since P ∈ H, M_D(y|x) ≥ w_D(P)·P(y|x).

**Answer rules.** An *answer rule* 𝔯 assigns to every data list D a probability kernel 𝔯_D(·|x) on Y_⊥. The answer ⊥ is an *abstention*. The mixture is the rule 𝔯_D = M_D (it abstains with the missing mass, which is 0 when all hypotheses are samplers). A rule is *frozen at D* when the kernel 𝔯_D answers all later inputs.

**Scaffolds and runs.** A scaffold Π of horizon L ≥ 1 consists of a countable set Z with a law D₀ (top-level inputs), a probability space (R, λ) (the scaffold's own randomness ρ), and measurable maps next_j : Z × R × Y^{j−1} → X ∪ {STOP} for j = 1, …, L; next_{L+1} := STOP. An *answerer* G gives, for each call j, a law G_j(· | z, ρ, y_1, …, y_{j−1}) on Y_⊥. A kernel C on Y_⊥ is the answerer that looks only at the input of the call. A *run* with answerer G is produced as follows: draw z ~ D₀ and ρ ~ λ; for j = 1, 2, …, compute x_j := next_j(z, ρ, y_1, …, y_{j−1}); if x_j = STOP the run ends; otherwise draw y_j from G_j; **if y_j = ⊥ the run ends** (it is *aborted* at call j). The run is τ = (z, ρ, y_1, …, y_{len(τ)}), where len(τ) ≤ L is the number of calls made, an aborting call included; x_1, …, x_{len(τ)} are its inputs. A run that is not aborted is *complete*. Q_G is the law of the run, and Q_P the *human system*; all runs of the human system are complete. The *visit measure* of G is d_G(B) := E_{Q_G} #{j ≤ len(τ) : x_j ∈ B} for B ⊆ X; its total mass is at most L. (In `proofs/rehearsal-core.md` the scaffold continues after an answer ⊥. Here ⊥ ends the run, because for an abstaining rule this is the behaviour wanted. For the statements about the mixture that are used below the two conventions give the same proofs.)

**Separation.** For x ∈ X and A ⊆ X, sep(x; A) is the least complexity K(Q) of a decidable set Q ⊆ X with x ∈ Q and Q ∩ A = ∅ (∞ if there is none, in particular if x ∈ A). The complexity K(Q) is the length of a shortest program, for a fixed universal prefix machine, that decides Q. The statements that involve sep are made for classes with the properties (P1) to (P3) of Section 5.3, which hold in the class of all programs.

### 1.2 The regret bound on asked inputs

**Setting 1.0 (a sequence of asked inputs).** Rounds t = 1, 2, …. 𝓖_t is the σ-algebra of everything realised before the human's answer of round t. In round t there are an indicator a_t ∈ {0, 1} ("a question is asked") and an input x_t ∈ X, both 𝓖_t-measurable and otherwise arbitrary: they may depend on all earlier questions and answers and on any randomness. If a_t = 1 the human's answer y_t satisfies Pr[y_t = y | 𝓖_t] = P(y|x_t) (A1 and A3), and the pair (x_t, y_t) is appended to the data; if a_t = 0 the data do not change.

**Lemma 1.1 (regret on asked inputs; the candidate's L3). PROVED (standard).** In Setting 1.0 put κ_t := KL(P ‖ M^(t))(x_t), the divergence between the laws P(·|x_t) and M^(t)(·|x_t) on Y_⊥.

1. Almost surely, for all n: P(D_{≤n}) > 0 and Σ_{t≤n, a_t=1} ln( P(y_t|x_t)/M^(t)(y_t|x_t) ) = ln( W·P(D_{≤n})/ξ(D_{≤n}) ) ≤ ln(W/w(P)).
2. κ_t ≤ ln(1/w_{D_{<t}}(P)) < ∞ almost surely, and Σ_{t≥1} E[a_t κ_t] ≤ ln(W/w(P)) ≤ K ln 2.
3. Σ_{t≥1} E[a_t·H²(P, M^(t))(x_t)] ≤ ½·K ln 2 and Σ_{t≥1} E[a_t·TV(P, M^(t))(x_t)²] ≤ ½·K ln 2.
4. If P is a function f and e_t := 1 − M^(t)(f(x_t)|x_t), then on every path and for every n: Π_{t≤n, a_t=1} (1 − e_t) = ξ(D_{≤n})/W ≥ w(f)/W ≥ w(f).

*Proof.* (1) Pr[a_t = 1 and P(y_t|x_t) = 0 | 𝓖_t] = 0, so almost surely every recorded answer has positive probability under P, and then ξ(D) ≥ w(P)·P(D) > 0 for all data lists that arise. By definition M^(t)(y_t|x_t) = ξ(D_{<t} + (x_t, y_t))/ξ(D_{<t}) on {a_t = 1}, so the product of these numbers over the asked rounds t ≤ n telescopes to ξ(D_{≤n})/W, and the product of the numbers P(y_t|x_t) is P(D_{≤n}). The inequality is ξ ≥ w(P)·P.

(2) M^(t)(y|x) ≥ w_{D_{<t}}(P)·P(y|x) gives the bound on κ_t. Write Z_t := ln(P(y_t|x_t)/M^(t)(y_t|x_t)) on {a_t = 1}. Given 𝓖_t and a_t = 1, y_t has law p := P(·|x_t), and m := M^(t)(·|x_t) restricted to Y is a sub-probability; since (ln u)⁺ ≤ u/e for u > 0, E[Z_t⁻ | 𝓖_t] = Σ_y p(y)(ln(m(y)/p(y)))⁺ ≤ Σ_y m(y)/e ≤ 1/e. So E[Z_t | 𝓖_t] is well defined and equals κ_t. Put Reg_n := Σ_{t≤n} a_t Z_t and c := ln(W/w(P)). By (1), a_t Z_t = Reg_t − Reg_{t−1} ≤ c + Σ_{s<t} (a_s Z_s)⁻, and the right side is integrable; so every a_t Z_t is integrable, and E[Reg_n] = Σ_{t≤n} E[a_t κ_t] because a_t is 𝓖_t-measurable. E[Reg_n] ≤ c by (1). The terms are nonnegative; let n → ∞.

(3) For a probability vector p on Y and a sub-probability m on Y, Jensen's inequality gives ln Σ_y p(y)√(m(y)/p(y)) ≥ ½ Σ_y p(y) ln(m(y)/p(y)), that is, −ln(1 − H²) ≤ ½·KL; and H² ≤ −ln(1 − H²). The second bound is Pinsker's inequality TV ≤ √(KL/2) for the two laws on Y_⊥. Now use (2).

(4) For a function, every data list that can arise has f(D) = 1; hence ξ(D) ≥ w(f) > 0 on every path, no exceptional set is needed, 1 − e_t = ξ(D_{<t} + (x_t, f(x_t)))/ξ(D_{<t}), and the product telescopes. ∎

*Source.* This is the standard regret bound for Bayes mixtures (Solomonoff 1978 for sequences); for pairs with adaptively chosen questions it is Lemma 4.1 and Lemma 4.2 of `proofs/rehearsal-core.md`, whose proof the one above follows.

### 1.3 Rehearsal with any driver

**Protocol R[𝔯] (rehearsal driven by an answer rule 𝔯).** For t = 1, …, n: (1) freeze the kernel C^(t) := 𝔯_{D_{<t}}; (2) run Π with C^(t) answering every call; the run has ℓ_t calls with inputs x_{t,1}, …, x_{t,ℓ_t}, and if C^(t) abstains at a call the run ends there; (3) draw J_t uniformly from {1, …, L}, independently of everything so far; if J_t ≤ ℓ_t, put x_t := x_{t,J_t} to the human, receive y_t ~ P(·|x_t) and append the pair to the data (a_t = 1); otherwise a_t = 0. The call at which a run was aborted can be asked like any other. *Deployment:* draw T uniformly from {1, …, n}, independently, and run Π with C^(T). 𝓕_{t−1} is the σ-algebra of everything realised in rounds 1, …, t − 1; d_t := d_{C^(t)} is the visit measure of the kernel of round t (a function of D_{<t}). Protocol R of the candidate theory is R[mixture]. Here n is the number of rounds; at most n questions are put to the human, and exactly n if every run makes L calls. Where the text says "n questions" for a rehearsal, it means n rounds.

**Lemma 1.2 (the asked call is a uniformly chosen call of the driver's run). PROVED.** For every measurable φ ≥ 0 defined on (data lists) × X,

  E[a_t·φ(D_{<t}, x_t) | 𝓕_{t−1}] = (1/L)·E[ Σ_{j≤ℓ_t} φ(D_{<t}, x_{t,j}) | 𝓕_{t−1} ] = (1/L) ∫ φ(D_{<t}, x) d_t(dx).

Moreover, given 𝓕_{T−1}, the deployed run has the same law as the rehearsal run of round T.

*Proof.* J_t is independent of the run of round t and uniform on {1, …, L}, so the conditional expectation of a_t φ(D_{<t}, x_t) = 1{J_t ≤ ℓ_t}·φ(D_{<t}, x_{t,J_t}) given 𝓕_{t−1} and the run is (1/L) Σ_{j≤ℓ_t} φ(D_{<t}, x_{t,j}). Both runs are runs of Π with the kernel C^(T) and fresh (z, ρ). ∎

**Corollary 1.3 (R1 for any driver). PROVED.** Under Protocol R[𝔯], with M^(t) = M_{D_{<t}} the mixture of round t (whether or not it is the driver):

  Σ_{t=1}^{n} E[ Σ_{j≤ℓ_t} KL(P ‖ M^(t))(x_{t,j}) ] ≤ L·K ln 2,  and for a function f:  Σ_{t=1}^{n} E[ Σ_{j≤ℓ_t} e^(t)(x_{t,j}) ] ≤ L·K ln 2,

where e^(t)(x) := 1 − M^(t)(f(x)|x). With the mixture as driver this is Theorem R1: E β(M^(T)) ≤ L·K ln 2/n for a function and E β(M^(T)) ≤ L·√(K ln 2/(2n)) in general, where β(C) := E_{Q_C} Σ_{j≤len(τ)} TV(P, C)(x_j).

*Proof.* The questions of Protocol R[𝔯] form a sequence as in Setting 1.0. Lemma 1.1(2) and Lemma 1.2 with φ(D, x) := KL(P ‖ M_D)(x) give the first bound; for a function, e ≤ −ln(1 − e) = KL. For the last claim, with the mixture as driver, Lemma 1.1(3) and Lemma 1.2 give Σ_t E ∫ TV(P, M^(t))² dd_t ≤ L·K ln 2/2, and by the Cauchy–Schwarz inequality, twice, Σ_t E ∫ TV(P, M^(t)) dd_t ≤ Σ_t E √(L ∫ TV² dd_t) ≤ √(n·L·Σ_t E ∫ TV² dd_t) ≤ L·√(n·K ln 2/2). ∎

*Source (editor; attack report, finding m4).* Lemma 1.2 and Corollary 1.3 are not new. Feeding a learner without regret with the losses at the inputs that its own behaviour produces is the reduction of S. Ross, G. J. Gordon and J. A. Bagnell (2011, Theorem 4.1), and the form used here (log loss, one uniformly chosen state of each rollout put to the expert, a uniformly chosen iterate deployed) is the algorithm of Y. Li and C. Zhang (2025), analysed there for a finite class and a deterministic expert. What Lemma 1.2 adds is only that the driver may be any answer rule, abstaining rules included. References and the way they were checked: Section 11.

### 1.4 Unfaithful calls, and runs compared up to the first of them

**Definition (unfaithful calls of a run; editor, check report, correction 5).** Let C be a kernel on Y_⊥. Along a run of C draw, at each call j, the answer y_j ~ C(·|x_j) jointly with a *shadow answer* y′_j ~ P(·|x_j) from a maximal coupling of the two laws, so that Pr[y_j ≠ y′_j | past] = TV(P, C)(x_j); the run continues with y_j. Call j is *unfaithful* if y_j ≠ y′_j. The *expected number of unfaithful calls* of a run of C is therefore

  β(C) := E_{Q_C} Σ_{j≤len(τ)} TV(P, C)(x_j),

the quantity of Corollary 1.3. For a function f a call is unfaithful exactly when the answer of C differs from f(x_j) (an abstention included). This is the candidate's L2 and the notion of Section 1 of the note. Lemma 1.4 below uses the same coupling up to the first unfaithful call and lets the two runs go their own ways afterwards.

**Lemma 1.4 (coupling up to the first unfaithful call). PROVED.** Let C be a kernel on Y_⊥. There is a joint construction of a run τ^C with law Q_C and a run τ^P with law Q_P, with the same (z, ρ), and of an index σ ∈ {1, …, L} ∪ {∞}, such that: the two runs have the same inputs and the same answers at all calls j < σ; they have the same input at call σ and different answers there (call σ is the first *unfaithful* call); and if σ = ∞ the runs are equal. With p := Pr[σ < ∞], β(C) as in Corollary 1.3 and β^P(C) := E_{Q_P} Σ_{j≤len(τ)} TV(P, C)(x_j):

1. p = E Σ_{j ≤ min(σ, len)} TV(P, C)(x_j), the sum running over the common calls; hence p ≤ β(C) and p ≤ β^P(C), and TV(Q_C, Q_P) ≤ p.
2. For every g : X → [0, 1]: | ∫ g dd_C − ∫ g dd_P | ≤ (L − 1)·p.
3. β^P(C) ≤ L·p ≤ L·β(C) and β(C) ≤ L·p ≤ L·β^P(C).

If P is a function f and C abstains with probability 0, then τ^P is the run of f on the same (z, ρ), and {σ < ∞} is the event that the run of C contains an answer different from f's.

*Proof.* Draw (z, ρ). For j = 1, 2, …, as long as the two runs have the same history and the next input x_j is not STOP, draw the pair (y_j, y′_j) from a maximal coupling of C(·|x_j) and P(·|x_j), so that Pr[y_j ≠ y′_j | past] = TV(P, C)(x_j); y_j is the answer in τ^C and y′_j the answer in τ^P. At the first j with y_j ≠ y′_j put σ := j and continue the two runs separately, each with its own kernel and fresh randomness. Each run has the right law because, at every call, its answer has the right conditional law given its own past. (1) Pr[σ = j | the runs agree before call j and call j exists] = TV(P, C)(x_j); sum over j. The calls j ≤ min(σ, len) are calls of both runs, which gives the two inequalities, and the runs differ only if σ < ∞. (2) The calls j ≤ σ have the same inputs in both runs; after call σ each run has at most L − σ ≤ L − 1 further calls, and g ≤ 1. (3) β^P(C) is the expectation of the sum of TV(P, C)(x_j) over the common calls, which is p by (1), plus the sum over at most L − 1 later calls of τ^P on {σ < ∞}. The same for β(C). ∎

The factor L in (3) cannot be removed (Example 2.2). It is the compounding of errors known from imitation learning: an error rate measured on the expert's inputs and the error rate on the learner's own inputs differ by a factor of the horizon (S. Ross and J. A. Bagnell 2010, Theorem 2.1; Section 11).

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
 3. in general the expected number of unfaithful calls is at most B·L·√(K ln 2/(2n)), and E TV(Q′_{M^(T)}, Q′_P) ≤ B·E TV(Q_{M^(T)}, Q_P) ≤ B·√(2·L·K ln 2/n), where Q′ denotes run laws on Π′ (the last step is Theorem R2 in the form of HR Theorem 3.1(b));
 4. a rate of unfaithful calls certified under D₀ by the validation phase (Theorem V1 of `note.md`) holds under D₀′ with the factor B.

(d) The factor B is necessary in general: for N task laws with disjoint supports and D₀ their uniform mixture (B = N), every protocol needs N·(L/(4δ) − 3L/2) questions to have failure probability at most δ ≤ 1/6 under each of them for all members of a class with K = log(N·⌈L/(2δ)⌉ + 1) (LB, Theorem 4.3), and by (c) N·L·K ln 2/δ questions suffice for Protocol R.

(e) The last term in (b) cannot be removed: on the part of Z where D₀ vanishes no question of the rehearsal has been asked, and LB Theorem 1.6 (N1) applies to it.

*Proof.* (a) Σ_z D₀′(z) Φ_G(z) ≤ B Σ_z D₀(z) Φ_G(z). (b) Split Z into {D₀′ ≤ B·D₀} and its complement, and use Φ_G ≤ φ_max on the complement. (c) Condition on the rehearsal; the deployed kernel C = M^(T) is then fixed and each quantity is of the form E_{z~D₀′} Φ_C(z) with Φ_C ≥ 0; apply (a) and then Corollary 1.3. For the probability in (2): by Lemma 1.4 the run differs from the run of f only if it has an unfaithful call. For the total variation in (3): two run laws on Π′ have the same marginal D₀′ of z, so TV(Q′_C, Q′_P) = Σ_z D₀′(z)·TV(Q_C(·|z), Q_P(·|z)) ≤ B·Σ_z D₀(z)·TV(Q_C(·|z), Q_P(·|z)) = B·TV(Q_C, Q_P); then HR Theorem 3.1(b). "The expected number of unfaithful calls" is β(C) of Section 1.4, computed on Π′. (4) is (a) for the validated answerer. (d) and (e) are the cited results. ∎

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

which is at most (2L − 1)·B·L·K ln 2/n for a function and (2L − 1)·B·L·√(K ln 2/(2n)) in general. By Example 2.2 the factor 2L − 1 cannot be replaced by anything below L/(1 + ω(L − 1)) (in the limit n/L → ∞, in which B tends to 1 there); for ω = 1/L, a human of log L bits, this is L/(2 − 1/L) > L/2.

*Proof.* Fix two kernels C_u and C_t and put g := TV(P, C_u) ∈ [0, 1]. By Lemma 1.4(2), applied to C_t and then to C_u, and by Lemma 1.4(1),

  ∫ g dd_{C_t} ≤ ∫ g dd_P + (L − 1)·β(C_t) ≤ ∫ g dd_{C_u} + (L − 1)·β(C_u) + (L − 1)·β(C_t) = L·β(C_u) + (L − 1)·β(C_t).

For the realised d̄: ∫ TV(P, M^(u)) dd′ ≤ B·(1/n) Σ_t ∫ TV(P, M^(u)) dd_t ≤ B·(L·β(M^(u)) + (L − 1)·(1/n) Σ_t β(M^(t))); average over u = T. For the expected d̄ the mixtures M^(t) in the middle expression come from an independent copy of the rehearsal, and the same computation applies. Then Corollary 1.3. ∎

So S1 holds with the factor B when the shift is a change of the law of the top-level input (or of anything else that is drawn before the answers), and with the factor (2L − 1)·B when all that is known is a bound on visit measures. Scripts: the inequality in the proof and Lemma 1.4(3) were checked by exact enumeration on 20000 random adaptive scaffolds (Section 8).

### 2.3 S3: a property of tasks

**Proposition 2.4 (S3). PROVED, with the meaning of "costs 1/β" made exact.** Let Γ ⊆ Z be a set of top-level inputs (a property of tasks) with β := D₀(Γ) > 0.

(a) For every answerer G and every φ ≥ 0 on runs: E[φ(τ) | z ∈ Γ] ≤ E[φ(τ)]/β. Hence, after Protocol R with n questions, the run of M^(T) on a task with the property has at most L·K ln 2/(β·n) unfaithful calls in expectation for a function, and at most L·√(K ln 2/(2n))/β in general.

(b) For a set Q ⊆ X of inputs (a property of calls): the expected number of unfaithful calls of the deployed run with input in Q is at most E β(M^(T)); so if the deployed run makes at least β_Q·L calls in Q in expectation, the ratio of the expected number of unfaithful calls in Q to the expected number of calls in Q is at most K ln 2/(β_Q·n) for a function.

(c) *The factor 1/β is necessary for a protocol that takes its questions from runs on tasks drawn from D₀.* Call a protocol a *rehearsal on D₀* if in each of n rounds it draws z ~ D₀, runs the scaffold on z with an answerer of its choice, and may put one call of that run to the human. For every L ≥ 1, δ ∈ (0, 1/4] with L/(2δ) an integer, and β ∈ (0, 1], there are a scaffold with horizon L, a class of L/(2δ) + 1 functions and a set Γ with D₀(Γ) = β such that every rehearsal on D₀, with any deployed system, whose outcome on tasks in Γ is right with probability at least 1 − δ for every member, has n ≥ (L/(4δ) − L)/β.

(d) *A property that is known in advance costs nothing; N unknown ones cost N.* If Γ is known, the protocol can rehearse on D₀(· | Γ), which is sampled by rejection with computation only. If the guarantee (failure probability at most δ on the tasks of each set, with δ ≤ 1/6) is wanted for each of N disjoint sets Γ_1, …, Γ_N of probability 1/N, every protocol whatever needs N·(L/(4δ) − 3L/2) questions for some class and scaffold (LB, Theorem 4.3, with the laws D₀(· | Γ_i); the class is the one of that theorem, the point indicators on [N] × [⌈L/(2δ)⌉] with the zero function).

*Proof.* (a) E[φ·1{z ∈ Γ}] ≤ E[φ]; divide by β; then Corollary 1.3. (b) The unfaithful calls in Q are among the unfaithful calls. (c) Let N₀ := L/(2δ), X := [N₀] ∪ {x*}, and let the class be the needle class of LB Section 2.1 extended by 0 at x*: f₀ ≡ 0 and f_c := 1[· = c] for c ∈ [N₀]. Let Z := {z*} ∪ [N₀]^L with D₀(z*) = 1 − β and D₀ uniform on Γ := [N₀]^L with total mass β. On z* the scaffold makes L calls at x*; on z = (z_1, …, z_L) ∈ Γ it calls z_1, …, z_L and its outcome is the largest answer. A call at x* is answered 0 by every member. In a round with z = z* every call is at x*, so the questions that lie in [N₀] come from the rounds with z ∈ Γ, and their expected number is at most β·n. Apply LB Lemma 1.10(2) to the scaffold with top-level law D₀(· | Γ), the patches B_c := {c} and M = L, exactly as in the proof of LB Theorem 2.1. In the proof of that lemma the sum Σ_c π_c of the probabilities that patch c is asked is bounded by the expected number of questions that lie in the patches, which here is at most β·n. So some member has failure probability on Γ at least (N₀ − β·n)·p/(N₀ + L) with p = 1 − (1 − 1/N₀)^L. By the computation of LB Corollary 2.2(1) this is at most δ only if β·n ≥ L/(4δ) − L. (d) is the cited theorem. ∎

*What S3 does not say.* The factor 1/β is not a law of nature for one fixed property: a protocol that knows Γ pays nothing. It is the price of a guarantee for a property that the designer did not single out, and the price of N such guarantees at once.

### 2.4 The three kinds of shift

**Theorem 2.5 (three kinds of shift). PROVED (a statement that collects R1, S1, S2, N3 and N1).** Let Protocol R be run on a scaffold Π with top-level law D₀ and n questions, and let M^(T) be deployed.

(i) *The shift produced by the system itself costs nothing.* For every set X₁ ⊆ X, the probability that the question of round T is asked and lies in X₁ equals 1/L times the expected number of calls of the deployed run on Π that lie in X₁. In other words, a uniformly chosen call of the deployed run and the question put to the human in a uniformly chosen round have the same distribution, whatever the scaffold does with the answers (decomposition, recursion, calls whose inputs are written by earlier calls). Consequently the bounds of Theorem R1 hold for the deployed run with no factor for shift, and for every property Q of inputs the expected number of unfaithful calls with input in Q is at most L·K ln 2/n for a function.

(ii) *A shift to a described law costs the density ratio, and no less.* If the deployment draws its top-level input from D₀′ ≤ B·D₀, every bound holds with the factor B (Proposition 2.1). If the rehearsal draws z from a mixture Σ_i π_i D_i, each D_i has B ≤ 1/π_i (LB Proposition 4.4(a)); for N laws with disjoint supports the factor N is necessary for every protocol (LB Theorem 4.3). For 2^k laws of description length at most k + 2 log k + c this is the price 2^k of "all simple shifts" (LB Corollary 4.2), and with advantage η over a coin the exact number of questions is 2η·2^k (LB Theorem 4.1).

(iii) *Any other shift has no guarantee.* Let x be an input, let A be a set that contains all questions of the protocol with probability 1 and not x, and let the class contain, with P, a hypothesis P′ that equals P on A. Then for every protocol whose questions lie in A and every deployed system, the laws R, R′ of the answer at x under P and P′ satisfy TV(R, P(·|x)) + TV(R′, P′(·|x)) ≥ TV(P(·|x), P′(·|x)) (LB Theorem 1.6(4)); for functions with f′(x) ≠ f(x) the answer at x is wrong or withheld with probability at least 1/2 for one of the two. In the class of all programs such an f′ exists with K(f′) ≤ K(f) + sep(x; A) + c (LB Proposition 1.8). In terms of laws: for a deployment law D₀′ that is not dominated by D₀, Proposition 2.1(b) covers the part where D₀′ ≤ B·D₀ at the price B and leaves the rest, D₀′{D₀′ > B·D₀}, without a guarantee.

*Proof.* (i) Lemma 1.2 with φ the indicator of X₁, for the round T, together with its last sentence; the bounds are Corollary 1.3. (ii) and (iii) are the cited statements. ∎

*Source (editor).* Part (i) is the point of the reduction of Ross, Gordon and Bagnell (2011) in the form of Li and Zhang (2025); see the note after Corollary 1.3. In (ii), LB Theorem 4.3 needs δ ≤ 1/6, and LB Theorem 4.1 is for one call and for functions. Part (i) is an identity between two measures on X (expected numbers of calls), so it holds for every set X₁. It does not say that, with high probability, every set that the deployed run enters has been entered by a question: a statement of that kind holds for each set fixed in advance, and for N such sets with the factor N (Theorem R7 of the note).

*What the theorem does not say.* (i) is a statement about expected numbers of calls. It does not say that a particular call of a kind that occurs with frequency below 1/n per call is answered faithfully: such kinds are not sampled, and what the imitator does there is fixed by the prior, as in (iii).

## 3. Open systems: asking at random for ever, and when the asking can stop

In this section there is no scaffold that we can run in advance. Inputs arrive from outside, in any way. (The prover's title was "… and why asking cannot stop". Both reports showed that this reading of Theorem 3.3 is false for a fixed class and a deterministic human; Corollary 3.6 below is restated accordingly.)

### 3.1 The online form

**Setting 3.0.** Steps t = 1, 2, …. 𝓖_t is the σ-algebra of everything realised before the coin of step t: all earlier inputs, coins, answers of the human and outputs of the system, and any outside randomness. At step t an input x_t arrives; x_t is 𝓖_t-measurable and otherwise arbitrary (it may be chosen by an adversary who knows the whole past, the system's own outputs included). A coin c_t ∈ {0, 1} is flipped with Pr[c_t = 1 | 𝓖_t] = q_t, where q_t ∈ (0, 1] is 𝓖_t-measurable; in the basic form q_t = q is a constant. If c_t = 1 the human is asked, answers y_t with Pr[y_t = y | 𝓖_t, c_t = 1] = P(y|x_t), the answer is the output of the step, and (x_t, y_t) is appended to the data. If c_t = 0 the output is a draw from M^(t)(·|x_t), the mixture given the pairs gathered so far, and the data do not change. Write κ_t := KL(P ‖ M^(t))(x_t), and call an unasked step *unfaithful* if the system's answer differs from a shadow answer of the human drawn jointly with it from a maximal coupling; for a function f this is the event that the system's answer differs from f(x_t).

**Theorem 3.1 (each call is put to the human with probability q, for ever). PROVED (Observation A of `understand/notes.md`; X3 and X4 of `understand/repo.md`).** In Setting 3.0:

(a) Σ_{t≥1} E[q_t κ_t] ≤ K ln 2. For constant q: E Σ_{t≥1} KL(P ‖ M^(t))(x_t) ≤ K ln 2/q, the sum running over all steps, asked or not.

(b) For a function and constant q, the expected number of unfaithful steps, over the whole unbounded interaction, is at most (1 − q)·K ln 2/q.

(c) In general, for constant q: Σ_{t≥1} E[TV(P, M^(t))(x_t)²] ≤ K ln 2/(2q), and the expected number of unfaithful steps among the first h steps is at most (1 − q)·√(h·K ln 2/(2q)).

(d) The number of questions among the first h steps has mean q·h. So for a function, (expected silent errors) × (expected questions in h steps) ≤ (1 − q)·h·K ln 2.

*Proof.* The asked steps form a sequence as in Setting 1.0 with a_t := c_t (the σ-algebra of Setting 1.0 at round t is generated by 𝓖_t and c_t). Lemma 1.1(2) gives Σ_t E[c_t κ_t] ≤ K ln 2. κ_t is 𝓖_t-measurable, so E[c_t κ_t] = E[q_t κ_t]. This is (a). (b) Given 𝓖_t and c_t = 0, the system's answer differs from f(x_t) with probability e_t = 1 − M^(t)(f(x_t)|x_t) ≤ −ln(1 − e_t) = κ_t, and E[(1 − c_t) e_t] = (1 − q)·E[e_t]. (c) Lemma 1.1(3) in the same way gives the first bound; an unasked step is unfaithful with conditional probability TV(P, M^(t))(x_t), and Σ_{t≤h} E TV_t ≤ √(h·Σ_t E TV_t²) by the Cauchy–Schwarz inequality. (d) E Σ_{t≤h} c_t = q·h; combine with (b). ∎

*Which hypotheses are needed.* (1) The input x_t must be fixed before the coin c_t. If the source of inputs sees the coin first, it can send the inputs on which the mixture is wrong only at unasked steps. (2) The human's answer must be a fresh draw given the past (A1, A3). (3) A2 is used through K. Nothing is assumed about the inputs.

*Source (editor; attack report, finding m4).* Asking at random and feeding the answers to a learner with a regret bound is label-efficient prediction (N. Cesa-Bianchi, G. Lugosi and G. Stoltz 2005; Section 11); Theorem 3.1 is that device applied to the regret bound of the Bayes mixture, and it is Observation A of `research/understand/notes.md`. The theorem keeps the human for ever: the bound is on a sum over all steps, and the questions continue at rate q.

**Example 3.2 (the bounds of Theorem 3.1 are attained up to the factor 2 ln 2). PROVED.** (i) *Divergence.* By Lemma 1.1(1), E Σ_{t≤n} c_t κ_t = ln(W/w(P)) − E ln(1/w_{D_{≤n}}(P)). So (a) holds with equality in the limit whenever W = 1 and the questions identify the human, in the sense that E ln(1/w_{D_{≤n}}(P)) → 0 (for W < 1 the limit is ln(W/w(P)) < K ln 2). In a simulation with 8 samplers and an input rule that always shows the input at which the mixture is farthest from the human, the simulated sums were 4.159 ± 0.027, 10.46 ± 0.07 and 41.55 ± 0.28 for q = 0.5, 0.2, 0.05, against the bounds 4.159, 10.40 and 41.59 (Section 8).

(ii) *Silent errors.* Let X = {a_1, …, a_K}, let H be all 2^K functions X → {0, 1} with weights 2^(−K), and f ≡ 0. The input rule shows a_1 at every step until a_1 has been asked, then a_2 until it has been asked, and so on. At an unasked step with input a_i the posterior is uniform on the functions that vanish at a_1, …, a_{i−1}, so the mixture's draw is wrong with probability 1/2. The number of unasked steps before a_i is asked has mean (1 − q)/q. So the expected number of silent errors is K(1 − q)/(2q), against the bound (1 − q)·K ln 2/q of (b).

### 3.2 Silent mistakes times questions is at least the horizon over a constant

Can the asking stop? The following class has N members of log N bits each. It shows that, on a sequence of N − 1 inputs, the product of the number of questions and the number of silent mistakes and abstentions is at least of the order of N; so the questions needed before the human can leave grow like 2^K divided by the tolerated number of silent mistakes and abstentions (Corollary 3.6). A *learner with questions on request* acts at each step knowing the inputs so far, the answers to its own earlier questions, and a random seed. At each step it asks (and sees the human's answer), or predicts an answer (and sees nothing), or abstains (and sees nothing). Qu is the number of questions, Sil the number of wrong predictions (silent mistakes), Abs the number of abstentions.

**Theorem 3.3 (thresholds; silent mistakes against questions). PROVED (the bound of `understand/ask-for-help.md`, Section 3.4, with the constant improved from 1/32 to 3/16, a version for the expected number of questions, and abstentions included).** Let N ≥ 2. The inputs 1, 2, …, N − 1 are shown in increasing order, once each. The class consists of the N thresholds h_s(x) := 1[x ≤ s], s ∈ {0, 1, …, N − 1}, with weights 1/N (so K = log N), and s is drawn uniformly. For every learner with questions on request:

(a) if Qu ≤ Q on every run, then E[Sil + Abs] ≥ ¼·( N/(Q + 1) − (Q + 1)/N ); in particular E[Sil + Abs]·(Q + 1) ≥ 3N/16 whenever Q + 1 ≤ N/2;

(b) with Q̄ := E[Qu]: E[Sil + Abs] ≥ N/(9(Q̄ + 1)) − √((Q̄ + 1)/(8N)); in particular E[Sil + Abs]·(Q̄ + 1) ≥ N/15 whenever Q̄ + 1 ≤ N/4;

(c) if Q + 1 divides N, the learner that asks at the Q positions that are multiples of N/(Q + 1), predicts 1 until an answer 0 has been seen and 0 afterwards, has Qu ≤ Q and E[Sil] = (N/(Q + 1) − 1)/2 < N/(2(Q + 1)). So the lower bound (a) is within a factor of the optimum that is at most 2 in the limit (Q + 1)/N → 0. (The learner of (c) is itself not optimal: for N = 48 and Q = 3 the exact optimum of N·E[Sil] is 216 and this learner has 264; `shift-abstain_attack_thresholds.out`.)

Since the left sides are averages over s, some member s has at least as many expected silent mistakes and abstentions.

**Lemma 3.4. PROVED.** Let b_1, …, b_u > 0 with Σ_j b_j = N. Then (Σ_j b_j²)·(Σ_j j·b_j) ≥ (4/9)·N³.

*Proof.* Put Ψ := Σ_j b_j² and Ξ := Σ_j j b_j, and let J > 0 be real. Then J·N − Ξ = Σ_j (J − j) b_j ≤ Σ_{1≤j<J} (J − j) b_j ≤ √Ψ·√(Σ_{1≤j<J} (J − j)²) by the Cauchy–Schwarz inequality, and Σ_{1≤j<J} (J − j)² ≤ ∫_0^J v² dv = J³/3, because (J − j)² ≤ ∫_{J−j}^{J−j+1} v² dv and these intervals are disjoint subsets of [0, J]. Take J := 3Ξ/N; then J·N − Ξ = 2Ξ > 0 and Ψ ≥ 3·(2Ξ)²/J³ = (4/9)·N³/Ξ. ∎

*Proof of Theorem 3.3.* *Step 0: reductions.* Replace every abstention by the prediction 1. This gives a learner without abstentions, with the same questions and with Sil′ ≤ Sil + Abs on every run. So it suffices to bound E[Sil] for learners that never abstain. A randomised learner is a deterministic one for each value of its seed; we fix the seed and treat a deterministic learner, and average at the end.

*Step 1: the all-ones path.* As long as all answers to its questions have been 1, the learner's behaviour is a fixed sequence: it asks at certain positions q_1 < q_2 < … < q_m and predicts fixed labels p(x) at the other positions x. Put q_0 := 0, q_{m+1} := N, and let 𝔅_j := {q_{j−1}, …, q_j − 1} for j = 1, …, m + 1. These blocks partition {0, …, N − 1}; b_j := |𝔅_j| ≥ 1 and Σ_j b_j = N. If s ∈ 𝔅_j, the questions at q_1, …, q_{j−1} are answered 1, because these positions are at most q_{j−1} ≤ s. So for s ∈ 𝔅_j the learner follows the all-ones path at every position before q_j: it asks at q_1, …, q_{min(j,m)} at least, and at each position x with q_{j−1} < x < q_j it predicts p(x).

*Step 2: mistakes.* Fix j and write the b_j − 1 positions strictly between q_{j−1} and q_j as x = q_{j−1} + r, r = 1, …, b_j − 1, and the members of the block as s = q_{j−1} + i, i = 0, …, b_j − 1. The label of x under h_s is 1[r ≤ i]. If p(x) = 1 the prediction at x is wrong for the r members with i < r; if p(x) = 0 it is wrong for the b_j − r members with i ≥ r. Hence the number of mistakes at these positions, summed over the members of 𝔅_j, is at least Σ_{r=1}^{b_j − 1} min(r, b_j − r) = ⌊b_j²/4⌋ ≥ (b_j² − 1)/4. Summing over the blocks,

  Σ_{s=0}^{N−1} Sil(s) ≥ (Ψ − (m + 1))/4,  Ψ := Σ_{j=1}^{m+1} b_j².  (3.1)

*Step 3: questions.* By Step 1, Qu(s) ≥ min(j, m) for s ∈ 𝔅_j, so Qu(s) + 1 ≥ j and

  Σ_{s=0}^{N−1} (Qu(s) + 1) ≥ Ξ := Σ_{j=1}^{m+1} j·b_j ≥ (m + 1)(m + 2)/2.  (3.2)

*Step 4: proof of (a).* The member s = N − 1 lies in the last block, so m ≤ Qu(N − 1) ≤ Q. By the Cauchy–Schwarz inequality Ψ ≥ N²/(m + 1), and v ↦ N²/v − v is decreasing; so (3.1) gives Σ_s Sil(s) ≥ (N²/(Q + 1) − (Q + 1))/4 for every seed. Divide by N and average over the seed. If Q + 1 ≤ N/2 then (Q + 1)/N ≤ N/(4(Q + 1)).

*Step 5: proof of (b).* Index the quantities of Steps 1 to 3 by the seed r. By Lemma 3.4, Ψ_r·Ξ_r ≥ (4/9)N³ for every r, so by the Cauchy–Schwarz inequality E_r[Ψ_r]·E_r[Ξ_r] ≥ (E_r √(Ψ_r Ξ_r))² ≥ (4/9)N³. By (3.2), E_r[Ξ_r] ≤ N·(Q̄ + 1) and m_r + 1 ≤ √(2Ξ_r), so E_r[m_r + 1] ≤ √(2N(Q̄ + 1)) by Jensen's inequality. With (3.1): N·E[Sil] ≥ ( (4/9)·N²/(Q̄ + 1) − √(2N(Q̄ + 1)) )/4, which is the first claim. If Q̄ + 1 ≤ N/4, then (Q̄ + 1)·√((Q̄ + 1)/(8N)) ≤ (N/4)^(3/2)/√(8N) = N/(8√8), and N/9 − N/(8√8) > N/15.

*Step 6: proof of (c).* Put b := N/(Q + 1). For s = q_{j−1} + i in block j, the learner predicts 1 at the b − 1 − i positions of the block's gap that lie above s, where the label is 0, and makes no other mistake: below s the label is 1, and after the answer 0 at q_j it predicts 0, which is right. (In the last block there is no question at the end, and the count is the same.) The average of b − 1 − i over i = 0, …, b − 1 is (b − 1)/2. ∎

*Numerical check.* A dynamic programme over the information states of all deterministic learners gives the exact minimum of N·E[Sil] for N ≤ 16 and all Q ≤ 5, and a reduction to block sizes gives it for N up to 240. In every computed case the minimum is at least the bound of (a). The quantity E[Sil]·(Q + 1)/N is 0.25 for Q = 0 and N even, 0.332 for Q = 1 and 0.441 for Q = 11 at N = 240, in agreement with (a) and (c); for Q = 1 it tends to 1/3, the value found by exhaustive search in the digest. The bound (b) was checked on the lower hull of all deterministic learners for N = 12, 24, 48 (Section 8).

**Corollary 3.5 (the factor K). NEW.** Let u ≥ 1 and N₁ ≥ 2. Take u copies of the threshold problem: inputs (i, x) with i ∈ [u], x ∈ {1, …, N₁ − 1}, shown in lexicographic order, and the class of the N₁^u functions (i, x) ↦ 1[x ≤ s_i], with uniform weights; so K = u·log N₁ and the number of steps is h = u(N₁ − 1). For every learner with questions on request and uniformly drawn (s_1, …, s_u), with Q̄ := E[Qu]:

  E[Sil + Abs]·(Q̄ + u) ≥ u·(h + u)/15 = K·(h + u)/(15·log(h/u + 1))  whenever Q̄ + u ≤ (h + u)/4.

So in Theorem 3.1(d) the factor K cannot be removed, in the following sense (made exact by the editor after the check report, correction 13, and the attack report, finding m5). The two products are not the same: Theorem 3.1(d) bounds E[Sil]·E[Qu] for asking at random, and the corollary bounds E[Sil + Abs]·(E[Qu] + u) for every learner. For a learner with Q̄ ≥ u (on average at least one question per copy) we have Q̄ + u ≤ 2Q̄, hence E[Sil + Abs]·Q̄ ≥ u·(h + u)/30 = h·K·N₁/(30·(N₁ − 1)·log N₁), against at most h·K ln 2 for asking at random with q = Q̄/h, on every class and every input sequence. The condition Q̄ + u ≤ (h + u)/4 = u·N₁/4 can hold only if N₁ ≥ 5. With N₁ fixed, for example N₁ = 8, the lower bound is a constant times h·K (namely h·K·8/630), so no logarithm is lost; the logarithm log N₁ = log(h/u + 1) appears only when N₁ grows. The horizon h = u·(N₁ − 1) is far below the number N₁^u = 2^K of members, so the corollary is a statement about horizons that are short compared with 2^K, as Corollary 3.6 requires.

*Proof.* Let Q̄_i and M̄_i be the expected numbers of questions and of silent mistakes plus abstentions at the inputs (i, ·). The learner restricted to the inputs (i, ·) is a randomised learner for one threshold problem with N₁ members, whose seed consists of the original seed and of (s_{i′})_{i′≠i}: what it has seen in the other copies is a function of these, and they are independent of s_i. So Theorem 3.3(b) gives M̄_i ≥ γ(Q̄_i) with γ(v) := N₁/(9(v + 1)) − √((v + 1)/(8N₁)), a convex function. By Jensen's inequality Σ_i M̄_i ≥ u·γ(Q̄/u) = u²N₁/(9(Q̄ + u)) − √(u(Q̄ + u)/(8N₁)). If Q̄ + u ≤ uN₁/4, then (Q̄ + u)·√(u(Q̄ + u)/(8N₁)) ≤ u²N₁/(8√8), and u²N₁·(1/9 − 1/(8√8)) > u²N₁/15; finally uN₁ = h + u. ∎

**Corollary 3.6 (when the asking can stop; N7 of the note). PROVED. Restated by the editor.** The prover's version read "the asking cannot stop on arbitrary inputs" and ended "a bound on the total number of silent errors over an unbounded deployment requires the human for ever". That is false for a fixed class and a deterministic human, as part (b) shows; it used a class whose size h + 1 grows with the horizon (check report, correction 1; attack report, finding M1).

(a) *Lower bound.* Let H be a class of functions on a set X ⊇ {1, …, N − 1} that contains N ≥ 2 members whose restrictions to {1, …, N − 1} are the thresholds h_0, …, h_{N−1} of Theorem 3.3, and let 1 ≤ h ≤ N − 1. On the sequence of inputs 1, 2, …, h, every learner with questions on request that asks at most Q questions has, for some member of H,

  E[Sil + Abs] ≥ ¼·( (h + 1)/(Q + 1) − (Q + 1)/(h + 1) ),  and  E[Sil + Abs]·(Q + 1) ≥ 3(h + 1)/16 if Q + 1 ≤ (h + 1)/2.

Consequently a learner that keeps E[Sil + Abs] ≤ s for every member on this sequence asks at least min{(h + 1)/2, 3(h + 1)/(16s)} − 1 questions on some run. For N = 2^K thresholds with uniform weights (K bits each) and h = N − 1 this is 2^K·min{1/2, 3/(16s)} − 1.

(b) *Upper bound: for a deterministic human in a fixed class the asking stops.* Let H be any class with weights, let the human be a function f ∈ H, and let inputs arrive in any way, for any number of steps. (i) The threshold rule Thr_η with η < w(f)/W, with exactly its abstentions put to the human, gives no wrong answer and asks at most K/log(1/(1 − η)) ≤ K ln 2/η questions in total (Proposition 4.3(a)). (ii) If H is a class of functions, enumeration with a budget k ≥ K gives no wrong answer and asks at most 2^k − 1 questions in total (Proposition 6.1(3); this part of that proposition does not use property (P2)). Both rules need a bound on K. After the last question the human is not needed, no answer is wrong, and no abstention is left unanswered.

(c) *Reading.* On inputs from outside, a deterministic human of K bits can be left after finitely many questions: at most 2^k − 1 for a known bound k ≥ K. No rule does essentially better in the worst case: for the 2^K thresholds, at most s expected silent mistakes and unanswered abstentions need about 2^K·3/(16s) questions. So the asking can stop, but only after a number of questions that is exponential in the complexity of the human, or of the order of the horizon if the horizon is shorter than 2^K. For a person 2^K is no bound, and this is the true content of "the asking cannot stop". For a human who is not deterministic there is no pair of counts in K alone (Proposition 4.8), and Theorem 3.1 as it stands keeps the human for ever.

*Proof.* (a) For 0 ≤ i ≤ h and 1 ≤ x ≤ h we have h_i(x) = 1[x ≤ i]; so the members h_0, …, h_h, restricted to the inputs 1, …, h, are the class of Theorem 3.3 with h + 1 in the place of N. A learner for H is a learner for these h + 1 members, and the bound of Theorem 3.3(a), an average over them, is a lower bound for the worst of them. If E[Sil + Abs] ≤ s for all members and Q + 1 ≤ (h + 1)/2, then s·(Q + 1) ≥ 3(h + 1)/16. (b) is the two cited propositions. ∎

*Illustration of (b)* (attack report; `shift-abstain_attack_stop.py`, re-run by the editor with identical output). The threshold class fixed at N = 16, 64, 256, every member as the human, 10⁵ steps, inputs random or chosen to refute one hypothesis at a time: Thr_η with η = 0.99/N, its abstentions put to the human, makes no silent error, leaves no abstention unanswered and asks at most N − 1 questions (15, 63, 255 on the adversarial inputs; 7, 12, 18 on random ones), the last of them at step 474 or earlier.

*Relation to the literature.* The product form "mistakes × queries ≳ horizon" for thresholds is derived in `understand/ask-for-help.md`, Section 3.4, whose argument is Steps 1, 2 and 4 above with the constant 1/32. That digest reports the same product law, in a model in which every label is shown and abstentions on injected inputs are free, from J. Yu and M. Blanchard, "Distribution-Free Sequential Prediction with Abstentions", arXiv:2602.17918: E[MisErr] ≥ T^α/32 or E[AbsErr] ≥ T^(1−α)/2 for a class of VC dimension 1. I did not open that paper in this session; it is quoted from the digest and is not used in any proof here.

## 4. Ab1: the threshold rule

In Sections 4.1 to 4.5 the human is a function f ∈ H.

**Definition 4.0 (threshold rule).** Let η ∈ (0, 1/2). After data D, the rule Thr_η(D) answers at input x the element y ∈ Y with M_D(y|x) ≥ 1 − η if there is one (it is unique because 1 − η > 1/2), and abstains otherwise. For a sequence of inputs, a round is a *wrong round* if Thr_η of the current data answers something other than f(x_t) at x_t, and an *abstention round* if it abstains at x_t.

### 4.1 Both counts on any sequence of asked inputs

**Theorem 4.1 (Ab1, counts). PROVED.** In Setting 1.0 with a function f as the human, let Wr_n and Ab_n be the numbers of asked rounds t ≤ n that are wrong rounds and abstention rounds for Thr_η(D_{<t}). On every path and for every n,

  Wr_n·log(1/η) + Ab_n·log(1/(1 − η)) ≤ log(W/w(f)) ≤ K.

Hence Wr_n ≤ K/log(1/η) and Ab_n ≤ K/log(1/(1 − η)) ≤ K ln 2/η. If η < w(f)/W there is no wrong round at all, asked or not: after every data list that can arise, Thr_η answers f(x) or abstains at every x.

*Proof.* By Lemma 1.1(4), Π_{t≤n, a_t=1} M^(t)(f(x_t)|x_t) ≥ w(f)/W. At a wrong round some y ≠ f(x_t) has M^(t)(y|x_t) ≥ 1 − η, so M^(t)(f(x_t)|x_t) ≤ η. At an abstention round M^(t)(f(x_t)|x_t) < 1 − η. All other factors are at most 1. Take logarithms. For the last claim: M_D(f(x)|x) ≥ w_D(f) = w(f)/ξ(D) ≥ w(f)/W > η, so no y ≠ f(x) has M_D(y|x) ≥ 1 − η. ∎

The counts are over asked rounds. A round at which the rule answers correctly costs nothing, and there is no bound on the number of such rounds. With j := log(1/η): at most K/j wrong rounds against at most about K ln 2·2^j abstention rounds. The last sentence of the theorem is item X2 of `understand/repo.md`.

**Example 4.2 (each count is attained). PROVED.** Let K > 0 and η ∈ (0, 1/2). In (a) assume K ≥ log(1/η), and in (b) K ≥ log(1/(1 − η′)), so that k ≥ 1 and k′ ≥ 1.

(a) Let k := ⌊K/log(1/η)⌋ ≥ 1, X := {x_1, …, x_k}, f ≡ 0, g_i := 1[· = x_i], W := 2^(−K)·η^(−k) ≤ 1, w(g_i) := (1 − η)·η^(i−1)·W and w(f) := η^k·W = 2^(−K). The weights sum to W. On the sequence x_1, …, x_k, before round i the consistent hypotheses are f, g_i, …, g_k with total weight η^(i−1)·W, so g_i has posterior weight exactly 1 − η and the rule answers 1 = g_i(x_i) ≠ f(x_i). All k rounds are wrong rounds.

(b) Let η′ ∈ (η, 1/2), k′ := ⌊K/log(1/(1 − η′))⌋, W := 2^(−K)·(1 − η′)^(−k′) ≤ 1, w(g_i) := η′·(1 − η′)^(i−1)·W for i ≤ k′ and w(f) := (1 − η′)^(k′)·W = 2^(−K). Before round i the consistent hypotheses have total weight (1 − η′)^(i−1)·W and g_i has posterior weight η′; so M(1|x_i) = η′ < 1 − η and M(0|x_i) = 1 − η′ < 1 − η: the rule abstains in all k′ rounds, and k′ is K/log(1/(1 − η)) up to rounding as η′ decreases to η.

### 4.2 What the counts mean when an answer is seen only on a question

**Proposition 4.3 (feedback on request). PROVED; NEW in part (b).** Let inputs arrive in any way (Setting 3.0 without the mixture's answers), and let the human be a function f.

(a) *Only abstentions are put to the human.* Let Thr_η of the current data answer every input, and let exactly the abstentions be asked. Then on every path at most K/log(1/(1 − η)) questions are asked. If η < w(f)/W no answer is ever wrong. If η ≥ w(f) this fails in general: for H = {f, g} with f ≡ 0, g ≡ 1 on an infinite X and w(g) = 1 − w(f) ≥ 1 − η, the rule answers 1 at every input, is wrong at every step, and never asks.

(b) *Audits.* Let a coin c_t with Pr[c_t = 1 | 𝓖_t] = q be flipped at each step after x_t is fixed. If c_t = 1 the human is asked. If c_t = 0, Thr_η of the current data is applied; in *variant A* its abstentions are also put to the human, in *variant B* they are not. Over the whole unbounded interaction:

  in both variants  E[Sil] ≤ ((1 − q)/q)·K/log(1/η);
  in variant A, Abs ≤ K/log(1/(1 − η)) on every path, and the expected number of questions among the first h steps is at most q·h + K/log(1/(1 − η));
  in variant B, E[Abs] ≤ ((1 − q)/q)·K/log(1/(1 − η)), and the number of questions among the first h steps has mean q·h.

*Proof.* (a) The asked rounds are the abstention rounds; Theorem 4.1. The example is immediate. (b) Let ω_t and α_t be the indicators that Thr_η(D_{<t}) is wrong, respectively abstains, at x_t; they are 𝓖_t-measurable. In variant A the asked steps are those with c_t = 1 or α_t = 1, and Theorem 4.1 gives, on every path, log(1/η)·Σ_t c_t ω_t + log(1/(1 − η))·Σ_t α_t ≤ K. In variant B the asked steps are those with c_t = 1, and log(1/η)·Σ_t c_t ω_t + log(1/(1 − η))·Σ_t c_t α_t ≤ K. In both, Sil = Σ_t (1 − c_t) ω_t has mean (1 − q)·E Σ_t ω_t = ((1 − q)/q)·E Σ_t c_t ω_t, because E[c_t ω_t] = q·E[ω_t]. In variant B, Abs = Σ_t (1 − c_t) α_t, and the same identity for α_t gives E[Abs] = ((1 − q)/q)·E Σ_t c_t α_t ≤ ((1 − q)/q)·K/log(1/(1 − η)). (The prover stated this bound without the factor 1 − q; the check report noted that the proof gives the factor.) ∎

*Tightness of the bound on E[Sil].* Take the class of Example 4.2(a) and show x_i at every step until it has been asked. At an unasked step with input x_i the rule answers wrongly. The number of unasked steps at x_i has mean (1 − q)/q, so E[Sil] = ⌊K/log(1/η)⌋·(1 − q)/q.

*Reading.* With answers seen only on questions, a silent error teaches nothing. So the first count of Theorem 4.1 limits silent errors only through questions that the rule did not choose (audits), or when η is below the weight of the human, where there are none. The second count limits the questions that the rule itself asks.

### 4.3 The rehearsal version: per-run bounds

**Theorem 4.4 (Ab1 under rehearsal driven by the threshold rule). PROVED.** Run Protocol R[Thr_η] (Section 1.3): in round t the frozen rule Thr_η(D_{<t}) answers the calls, the run halts at the first abstention, and one uniformly chosen call slot is put to the human. Let Wr_t be the number of calls of the run of round t that are answered wrongly, and let Halt_t be the event that this run is aborted. Then

  Σ_{t=1}^{n} ( log(1/η)·E[Wr_t] + log(1/(1 − η))·Pr[Halt_t] ) ≤ L·log(W/w(f)) ≤ L·K.

For the deployed rule Thr_η(D_{<T}), T uniform on {1, …, n}:

1. the expected number of wrong answers in the deployed run is at most L·K/(n·log(1/η));
2. the deployed run is aborted with probability at most L·K/(n·log(1/(1 − η))) ≤ L·K ln 2/(n·η);
3. with probability at least 1 − L·K/(n·log(1/η)) the deployed run contains no wrong answer, and then it is the run of the human system on the same (z, ρ) if it is complete, and an initial part of that run followed by the abort otherwise;
4. log(1/η)·Pr[the deployed run contains a wrong answer] + log(1/(1 − η))·Pr[it is aborted] ≤ L·K/n.

*Proof.* The questions of the protocol form a sequence as in Setting 1.0, so Theorem 4.1 holds on every path for the asked rounds. Apply Lemma 1.2 with φ_W(D, x) := 1[Thr_η(D) answers at x something other than f(x)] and φ_A(D, x) := 1[Thr_η(D) abstains at x]: the asked round t is a wrong round with probability E[Wr_t]/L and an abstention round with probability Pr[Halt_t]/L, because a run has at most one abstaining call, its last. Take expectations in Theorem 4.1 and sum. For the deployed rule use the last sentence of Lemma 1.2 and average over T. (3) is Markov's inequality for the number of wrong answers; a run in which every answer given equals f's has the inputs of f's run. (4) uses Pr[Wr ≥ 1] ≤ E[Wr]. ∎

*Comparison with the mixture.* With the same n, the run of M^(T) is unfaithful with probability at most L·K ln 2/n (Theorem R1), and the run of the threshold rule has a wrong answer with probability at most L·K ln 2/(n·ln(1/η)) and is aborted with probability at most L·K ln 2/(n·η). So the bound on silent failures is smaller by the factor ln(1/η), and a visible failure is added whose bound is larger by the factor 1/η. To keep the visible failures at a level δ, n = L·K ln 2/(η·δ) questions suffice: a bound on silent failures that is smaller by the factor j = ln(1/η) is bought with e^j times as many questions.

*One rule for good.* The bounds are for the rule of a uniformly chosen round, drawn afresh. If one rule Thr_η(D_{<T}) is drawn once and kept for all later runs, apply Markov's inequality to the random variable log(1/η)·E[Wr | D_{<T}] + log(1/(1 − η))·Pr[abort | D_{<T}], whose mean is at most L·K/n: with probability at least 1 − δ′ over the rehearsal and over T, each later run has at most L·K/(δ′·n·log(1/η)) wrong answers in expectation and is aborted with probability at most L·K/(δ′·n·log(1/(1 − η))). Nothing is claimed for the rule of the last round: the bounds are sums over the rounds, and the per-round quantities need not decrease.

*The rule must drive the rehearsal.* If the mixture drives the rehearsal and Thr_η is only deployed, the calls of the deployed run are not distributed as the asked calls, and only Proposition 2.3 applies, with the factor 2L − 1.

### 4.4 Abstention in a closed system: at most the factor (1 − a)² on the needle class, an unbounded factor elsewhere

(The prover's title was "In a closed system abstention saves at most the factor (1 − a)²". Theorem 4.5 proves this for one closed system, the needle class with cells of equal mass; Example 4.5a, from the attack report, shows that it is not true of closed systems in general. Check report, correction 3; attack report, finding M2.)

**Theorem 4.5 (N2 with abstention, for the needle class with cells of equal mass). NEW.** Take the needle class 𝒩(N₀) = {f₀ ≡ 0} ∪ {f_c := 1[· = c] : c ∈ [N₀]} and the OR scaffold of LB Definition 2.0: z = (z_1, …, z_L) independent and uniform on [N₀], the calls are z_1, …, z_L, the outcome is the largest answer. Let a protocol put n questions in expectation to the human when the human is f₀, and let it deploy any system with outcomes in {0, 1, ⊥} (LB Definitions 1.1 and 1.3). For a member f let σ(f) be the probability that the outcome is neither ⊥ nor the outcome of the human system (*silent failure*), and let a := Pr_{f₀}[outcome ⊥]. Then, with p := 1 − (1 − 1/N₀)^L,

  max_f σ(f) ≥ ( (N₀ − n)·p − L·a )/(N₀ + L).

Consequently, if σ(f) ≤ σ for all members and a ≤ a* < 1, and N₀ := (1 − a*)·L/(2σ) is an integer, then

  n ≥ (1 − a*)²·L/(4σ) − L.

*Proof.* Fix the protocol's seed r. Let S(r) be the set of cells asked when all answers are 0, and g₀ the outcome deployed after that all-zero transcript (a function of r, z and fresh randomness). If c ∉ S(r), the transcript under f_c is the all-zero transcript (LB Lemma 1.5), so the outcome under f_c is g₀. Let U := #{c ∈ [N₀] ∖ S(r) : c ∈ {z_1, …, z_L}} ≤ L. Under f_c with c ∉ S(r) and c among the calls, the human system's outcome is 1, so g₀ = 0 is a silent failure. Hence

  Σ_c σ(f_c) ≥ E[U·1{g₀ = 0}] ≥ E[U] − L·Pr[g₀ ≠ 0] = E[U] − L·(a + σ(f₀)),

and E[U] = Σ_c Pr[c ∉ S(r)]·p ≥ (N₀ − n)·p because r and z are independent and E|S(r)| ≤ n. So N₀·max_c σ(f_c) + L·σ(f₀) ≥ (N₀ − n)p − L·a, which gives the first claim. For the second put ρ₀ := L/N₀ = 2σ/(1 − a*); then p ≥ ρ₀(1 − ρ₀/2) and the first claim gives n/N₀ ≥ 1 − (σ(1 + ρ₀)/ρ₀ + a*)/(1 − ρ₀/2) = ((1 − a*)/2 − ρ₀/2 − σ)/(1 − ρ₀/2). If the numerator is negative the claim is trivial; otherwise n ≥ N₀·((1 − a*)/2 − σ/(1 − a*) − σ) = (1 − a*)²L/(4σ) − L/2 − (1 − a*)L/2 ≥ (1 − a*)²L/(4σ) − L. ∎

For a* = 0 this is LB Corollary 2.2(1). Here a is the abort probability when the human is f₀ only, which is the weakest hypothesis of this kind. *Reading.* In this closed system (the needle class, with every cell equally likely to be called) a rule that aborts with probability a still needs (1 − a)²·L/(4σ) − L questions to keep silent failures below σ: here failing obviously does not buy a cheaper guarantee against failing silently, it only converts failures. Theorem 4.4 is consistent with this: its gain is the factor ln(1/η), paid for by aborts. The linear programme of Section 8 gives the exact optimum for small N₀ and L; it is at least the bound in all 27 cases computed. The theorem is a worst case over scaffolds: for every L and σ there is a closed system in which abstention saves no more than this. It is not a statement about every closed system:

**Example 4.5a (where the unlearned inputs are rare and recognisable, abstention saves an unbounded factor). PROVED (editor; the example and its numbers are finding M2 of the attack report, re-derived here).** Let L ≥ 1, let N₁ ≥ 1 be an integer and π ∈ (0, 1) with N₁·π ≤ 1. The inputs are a *common cell* c₀ and N₁ *rare cells* 1, …, N₁; the class consists of f₀ ≡ 0 and of the indicators f_c of the N₁ + 1 cells. The scaffold makes L independent calls, each at a rare cell c with probability π and at c₀ with probability 1 − N₁·π, and its outcome is the largest answer. Put p_π := 1 − (1 − π)^L, σ := p_π/4 and a := 1 − (1 − N₁·π)^L (the probability that a run calls a rare cell).

1. *Without abstention.* Every protocol with a deployed system that always gives an outcome in {0, 1}, and whose failure probability is at most σ for every member, puts at least N₁/2 questions to the human in expectation when the human is f₀.
2. *With abstention.* The protocol that asks the one input c₀, and deploys "answer c₀ as the human did; if that answer was 1, answer 0 at every rare cell; if it was 0, abstain at every rare cell", has silent failure probability 0 for every member, and its run is aborted with probability a (with probability 0 if the human is f_{c₀}).
3. N₁/2 ≥ a/(8σ) − 1/2. For L = 10, with π chosen so that σ = 10⁻³, 10⁻⁴, 10⁻⁵ and N₁ = 55, 551, 5516 (which gives a = 0.200 in each case): N₁/2 = 27.5, 275.5, 2758, against 1/(1 − a)² = 1.56 (`shift-abstain_attack_closed.out`; for a = 0.500 the values are N₁/2 = 83.5, 836.5, 8370.5 against 4).

*Proof.* (1) For a rare cell c apply LB Lemma 1.10(1) with the single patch B := {c}: the human systems of f₀ and f_c have different outcomes exactly when c is called, which has probability p_π = 4σ; so Fail(f₀) + Fail(f_c) ≥ (1 − π_c)·4σ, where π_c is the probability that c is asked when the human is f₀. If both failure probabilities are at most σ, then π_c ≥ 1/2. The patches are disjoint, so the expected number of questions under f₀ is at least Σ_c π_c ≥ N₁/2. (2) If the answer at c₀ is 1 the human is f_{c₀}, and the deployed system is f_{c₀}. If it is 0, the human is f₀ or f_c for a rare c; the deployed system answers 0 at c₀, which is right for all of these, and abstains at the first call at a rare cell. A run without such a call consists of calls at c₀, its outcome is 0, and this is the human system's outcome, since c was not called. So no outcome in {0, 1} is wrong. (3) N₁·π = 1 − (1 − a)^(1/L) ≥ a/L and π = 1 − (1 − 4σ)^(1/L) ≤ ln(1/(1 − 4σ))/L ≤ 4σ/((1 − 4σ)·L); hence N₁ ≥ a·(1 − 4σ)/(4σ) = a/(4σ) − a. ∎

So in a closed system abstention can be cheap when the part of the task law that the questions did not cover is rare and can be recognised from the data: the whitelist situation of Section 7.3. Theorem 4.5 is the opposite case, in which every input is as likely as every other and nothing marks the unlearned ones.

### 4.5 The exponential rate between wrong answers and abstentions is necessary

**Proposition 4.6 (thresholds, every answer shown). PROVED; the exact characterisation is a theorem of Zhang and Chaudhuri (2016), see Section 11.** Let the class be the N thresholds of Theorem 3.3, and let every input be asked, so that the rule sees f(x_t) after each round. Put F(k, m) := C(m + 1, ≤ k + 1) − 1. If a deterministic rule makes at most k wrong answers and at most m wrong answers and abstentions together, on every sequence of inputs and for every member, then N ≤ F(k, m). Consequently, if N ≥ 2^(k+1), a rule with at most k wrong answers has, for some member and some sequence, at least

  (k + 1)·N^(1/(k+1))/e − k − 1

abstention rounds.

*Proof.* We show by induction on m: if n thresholds s_1 < … < s_n are consistent with the answers shown so far and n > F(k, m), where k ≥ −1 and m ≥ 0, then an adversary can continue the sequence, with answers consistent with one of them, so that the rule makes more than k wrong answers or more than m wrong answers and abstentions in the continuation. For k = −1 this is trivial (F(−1, m) = 0). Let k ≥ 0. *Case m = 0:* F(k, 0) = 1 and n ≥ 2. Show the input x := s_2; its answer is 0 under s_1 and 1 under s_2. If the rule abstains, or answers b and the adversary reveals 1 − b, the round is a wrong or abstained round. *Case m ≥ 1:* by Pascal's rule F(k, m) = F(k, m − 1) + F(k − 1, m − 1) + 1. Put n₂ := F(k − 1, m − 1) + 1 and n₁ := n − n₂ ≥ F(k, m − 1) + 1, and show x := s_{n₂+1}; its answer is 0 under the n₂ lowest thresholds and 1 under the n₁ others. If the rule abstains, reveal 1: n₁ > F(k, m − 1) thresholds remain and the rule may use m − 1 further such rounds. If it answers 0, reveal 1: a wrong answer, n₁ > F(k, m − 1) ≥ F(k − 1, m − 1) remain, and the budgets are k − 1 and m − 1. If it answers 1, reveal 0: a wrong answer, n₂ > F(k − 1, m − 1) remain, budgets k − 1 and m − 1. In each case the induction hypothesis applies. This proves N ≤ F(k, m). For the consequence: if m ≤ k then F(k, m) = 2^(m+1) − 1 < 2^(k+1) ≤ N, so m ≥ k + 1, and then N < C(m + 1, ≤ k + 1) ≤ (e(m + 1)/(k + 1))^(k+1), so m + 1 > (k + 1)N^(1/(k+1))/e; the number of abstentions on a worst sequence is at least m − k. ∎

The game value was computed exactly for k ≤ 3, m ≤ 7 (Section 8): the largest N that a rule can handle is F(k, m) in every case, so the proposition is tight. (The prover's computation was capped at 140 for k = 3, m = 7; the independent computation of the attack report, `shift-abstain_attack_thresholds.out`, gives 162 = F(3, 7) there.) With uniform weights K = log N, and Theorem 4.1 with η slightly below N^(−1/(k+1)) gives fewer than k + 1 wrong rounds, hence at most k, and at most about ln N·N^(1/(k+1)) abstention rounds. So for thresholds the threshold rule is optimal up to the factor e·ln N/(k + 1), and no rule trades wrong answers for abstentions at a better than exponential rate in K/(k + 1).

### 4.6 A stochastic human

For a stochastic human the threshold rule can only answer where the human has a preferred answer. Call f a *mode* of P with noise ε₀ if P(f(x)|x) ≥ 1 − ε₀ for all x. For a, b ∈ (0, 1) put kl(a ‖ b) := a ln(a/b) + (1 − a) ln((1 − a)/(1 − b)), and 𝔥(ε) := −ε ln ε − (1 − ε) ln(1 − ε) ≤ ln 2.

**Proposition 4.7 (a human with a mode). NEW.** Let P ∈ H have a mode f with noise ε₀ < η < 1/2. In Setting 1.0 call an asked round *wrong* if Thr_η(D_{<t}) answers something other than f(x_t). Then

  E[number of wrong asked rounds] ≤ K ln 2/kl(1 − ε₀ ‖ η) ≤ K ln 2/((1 − ε₀)·ln(1/η) − 𝔥(ε₀)),
  E[number of asked abstention rounds] ≤ K ln 2/kl(ε₀ ‖ η) ≤ 2η·K ln 2/(η − ε₀)²,

the second forms being valid when their denominators are positive; for ε₀ ≤ η/2 the last bound is at most 8·K ln 2/η. Under Protocol R[Thr_η] the deployed run contains at most L·K ln 2/(n·kl(1 − ε₀ ‖ η)) answers different from the mode in expectation, and is aborted with probability at most L·K ln 2/(n·kl(ε₀ ‖ η)).

*Proof.* Let p := P(·|x_t) and m := M^(t)(·|x_t), and y* := f(x_t). Merging all answers other than y* does not increase the divergence, so κ_t ≥ kl(p(y*) ‖ m(y*)). The function kl(a ‖ b) is nondecreasing in a for a ≥ b and nonincreasing in b for b ≤ a; it is nonincreasing in a for a ≤ b and nondecreasing in b for b ≥ a. At a wrong round m(y*) ≤ η < 1 − ε₀ ≤ p(y*), so κ_t ≥ kl(1 − ε₀ ‖ η). At an abstention round m(y*) < 1 − η < 1 − ε₀ ≤ p(y*), so κ_t ≥ kl(1 − ε₀ ‖ 1 − η) = kl(ε₀ ‖ η). Lemma 1.1(2) gives Σ_t E[a_t κ_t] ≤ K ln 2, which yields the two bounds. For the explicit forms: kl(1 − ε₀ ‖ η) = (1 − ε₀) ln(1/η) − 𝔥(ε₀) + ε₀ ln(1/(1 − η)); and for 0 ≤ a ≤ b < 1, kl(a ‖ b) = ∫_a^b (v − a)/(v(1 − v)) dv ≥ (b − a)²/(2b). The statement on rehearsal follows with Lemma 1.2 as in Theorem 4.4. ∎

*What it does not say.* A deployed run without abort and without an answer off the mode is the run of the function f. Suppose that the human leaves the mode with probability exactly ε₀ at every input (P(f(x)|x) = 1 − ε₀ for all x) and that every run of f makes exactly L calls. Then the human system produces the run of f with probability (1 − ε₀)^L only. So for a noisy human the threshold rule imitates the mode, not the distribution: under these two assumptions the total variation distance between its run law and the human system is at least 1 − (1 − ε₀)^L − Pr[abort or answer off the mode], however many questions are asked. If the human has no mode with noise below η, the rule abstains at every input x at which max_y P(y|x) < 1 − η and the mixture is close enough to P(·|x) that also max_y M_D(y|x) < 1 − η.

**Proposition 4.8 (the two counts cannot both hold for all samplers). NEW.** Let N ≥ 1, Y = {0, 1}, and x_1, …, x_N distinct inputs. Let H_N consist of the sampler P₀ that answers every input with a fair coin, with weight 1/2, and of the 2^N functions g_b, b ∈ {0, 1}^N, with g_b(x_i) = b_i, each of weight 2^(−N−1). So log(1/w(P₀)) = 1 and log(1/w(g_b)) = N + 1. Let any answer rule be used on the inputs x_1, …, x_N in this order, each of them asked, so that the rule knows all earlier answers; let r_t(·) be its law on Y_⊥ at round t. For a function g_b let Sil(g_b) be the expected number of rounds at which the rule's answer is in Y and differs from b_t, and let Abs(P₀) be the expected number of abstentions when the human is P₀. Then

  Abs(P₀) = N − 2·2^(−N)·Σ_b Sil(g_b) ≥ N − 2·max_b Sil(g_b).

In particular, if Sil(g_b) ≤ (N + 1)/j for all b (as the first count of Theorem 4.1 gives for the threshold rule with j = log(1/η); its proof applies to a function as the human in any class), then Abs(P₀) ≥ N − 2(N + 1)/j, which for j ≥ 4 is at least (N − 1)/2 although the human P₀ costs one bit.

*Proof.* When the human is g_b the earlier answers are b_1, …, b_{t−1}, and when the human is P₀ they are uniformly distributed; the rule's law at round t is the same function r_t(· ; y_1, …, y_{t−1}) of the earlier answers in both cases. So 2^(−N) Σ_b Sil(g_b) = Σ_t E_b[r_t(1 − b_t ; b_{<t})] = Σ_t E_b[(r_t(0 ; b_{<t}) + r_t(1 ; b_{<t}))/2] = ½·Σ_t E_b[1 − r_t(⊥ ; b_{<t})] = ½(N − Abs(P₀)), where b is uniform and the second step uses that b_t is independent of b_{<t}. ∎

*Reading.* At every new input a stochastic human is consistent with deterministic hypotheses that have not been refuted and that predict the data as well as the human does. A rule that is cautious towards them must abstain; a rule that answers is silently wrong against them. So the pair of counts of Theorem 4.1 has no analogue that holds for every member of a class of samplers with a bound in K and η alone. Proposition 4.7 (a mode) and Section 5 (dominance, with a price in 1/w) are the two things that remain.

## 5. Ab2: the minimum over a plausible set

From here on the human may be stochastic again.

**Definition 5.0 (minimum rule).** For a nonempty set 𝒞 ⊆ H put S_𝒞(y|x) := inf_{ν∈𝒞} ν(y|x) for y ∈ Y and θ_𝒞(x) := 1 − Σ_{y∈Y} S_𝒞(y|x) ∈ [0, 1]. Min_𝒞 is the kernel on Y_⊥ that answers y with probability S_𝒞(y|x) and abstains with probability θ_𝒞(x). A run with Min_𝒞 halts at the first abstention. A *plausible-set rule* assigns to every data list D a set 𝒞(D) ⊆ H; the answer rule is D ↦ Min_{𝒞(D)}, with the convention that it abstains everywhere if 𝒞(D) is empty.

### 5.1 Dominance

**Theorem 5.1 (dominance). PROVED (Ab2, first part; items 2 to 4 are claims 2 to 4 of `understand/ask-for-help.md`, Section 3.2, checked).** Let 𝒞 ⊆ H with P ∈ 𝒞, and let Π be any scaffold.

1. S_𝒞(y|x) ≤ P(y|x) for all x and y.
2. There is a joint construction of a run τ̂ of Min_𝒞 and a run τ^P of the human system such that either τ̂ = τ^P, or τ̂ is aborted at some call j ≤ len(τ^P) and its first j − 1 answers are those of τ^P. In words: the imitator is the human system with a visible abort.
3. For every measurable set B of complete runs, Pr[τ̂ ∈ B] ≤ Q_P(B). If all aborted runs are merged into one point, the total variation distance between the law of τ̂ and Q_P equals Pr[τ̂ is aborted].
4. Pr[τ̂ is aborted] = 1 − E_{Q_P} Π_{j≤len(τ)} ( S_𝒞(y_j|x_j)/P(y_j|x_j) ) ≤ E_{Q_P} Σ_{j≤len(τ)} θ_𝒞(x_j) = ∫ θ_𝒞 dd_P.
5. For every x: sup_{ν∈𝒞} TV(ν, P)(x) ≤ θ_𝒞(x) ≤ Σ_{ν∈𝒞} TV(ν, P)(x), with TV between the laws on Y_⊥. The right inequality also holds when P ∉ 𝒞.

*Proof.* (1) P is one of the hypotheses over which the infimum is taken. (2) Draw τ^P ~ Q_P and independent uniform numbers V_1, V_2, … on [0, 1]. Let τ̂ have the same (z, ρ); at call j, as long as τ̂ has not been aborted, its history equals that of τ^P, its input is x_j, and we let it answer y_j (the answer of τ^P) if V_j ≤ S_𝒞(y_j|x_j)/P(y_j|x_j), and abort otherwise. Given the past, τ̂ answers y with probability P(y|x_j)·S_𝒞(y|x_j)/P(y|x_j) = S_𝒞(y|x_j) (both sides are 0 if P(y|x_j) = 0, by (1)) and aborts with the remaining probability θ_𝒞(x_j). So τ̂ is a run of Min_𝒞. (3) By (2), {τ̂ ∈ B} ⊆ {τ^P ∈ B}. Let μ̂ be the law of τ̂ with the aborted runs merged into a point ⊥. Then μ̂ ≤ Q_P on the complete runs and Q_P(⊥) = 0 ≤ μ̂(⊥), so the total variation distance is Q_P(complete) − μ̂(complete) = μ̂(⊥). (4) In the construction, given τ^P, the run τ̂ is not aborted with probability Π_j S_𝒞(y_j|x_j)/P(y_j|x_j). For numbers u_j ∈ [0, 1], 1 − Π_j u_j ≤ Σ_j (1 − u_j), and E[1 − S_𝒞(y_j|x_j)/P(y_j|x_j) | history before call j] = Σ_y (P(y|x_j) − S_𝒞(y|x_j)) = θ_𝒞(x_j). (5) θ_𝒞(x) = Σ_y (P(y|x) − inf_ν ν(y|x)) = Σ_y sup_ν (P(y|x) − ν(y|x))⁺ when P ∈ 𝒞, and in general θ_𝒞(x) ≤ 1 − Σ_y min(P(y|x), inf_ν ν(y|x)) = Σ_y sup_ν (P(y|x) − ν(y|x))⁺. For every ν, Σ_{y∈Y} (P(y|x) − ν(y|x))⁺ = TV(P, ν)(x), because P gives ⊥ no mass. A sum of suprema is at least the supremum of the sums and at most the sum over ν of the sums. ∎

*Remarks.* (i) Nothing is assumed about the deployment: the scaffold in the theorem need not be the one used to gather the data, and its top-level inputs may come from anywhere. This is the exact sense in which the rule "only fails obviously". (ii) By (2), conditionally on not aborting, the run is not distributed as the human system in general: the abort may depend on the answers. What holds is the inequality for every event in (3). (iii) S_𝒞 ≤ ν for every ν ∈ 𝒞, so the theorem holds with every member of 𝒞 in the place of the human: the rule is sound for whichever member of 𝒞 the human is. (iv) The same proof works for a set of history-dependent answerers that contains the human answerer; this is the setting of Cohen, Hutter and Nanda (Section 5.5).

### 5.2 Three plausible sets, and Ville's inequality

For data D with ξ(D) > 0 order the hypotheses by decreasing posterior weight, ν_1, ν_2, …, ties broken by a fixed rule. For α ∈ (0, 1]:

* 𝒞^abs_α(D) := {ν : w_D(ν) ≥ α} (hypotheses of posterior weight at least α);
* 𝒞^cum_α(D) := {ν_i : w_D(ν_i) ≥ α·Σ_{i′≤i} w_D(ν_{i′})} (the top set of Cohen, Hutter and Nanda);
* 𝒞^rat_α(D) := {ν : w_D(ν) ≥ α·w_max(D)} (posterior weight at least α times the largest; the set of the candidate's Ab2).

**Proposition 5.2 (the plausible sets). PROVED (the Ville step is Theorem 2 of Cohen, Hutter and Nanda).**

(a) 𝒞^abs_α(D) ⊆ 𝒞^cum_α(D) ⊆ 𝒞^rat_α(D). The last two contain ν_1; the first may be empty. |𝒞^abs_α(D)| ≤ 1/α, |𝒞^cum_α(D)| ≤ 1/α and |𝒞^rat_α(D)| ≤ 1/(α·w_max(D)).

(b) In Setting 1.0, Pr[there is n with w_{D_{≤n}}(P) < α] ≤ α·W/w(P) ≤ α/w(P). So with probability at least 1 − α/w(P) the human belongs to all three sets at all times. Conditionally on the data D gathered up to any stopping time, the probability that the posterior weight w_{D′}(P) falls below α for some later data list D′ is at most α/w_D(P).

(c) If the human is a function f, then w_D(f) ≥ w(f)/W for every data list that can arise. So f ∈ 𝒞^abs_α(D) at all times, with probability 1, whenever α ≤ w(f)/W.

(d) *Averaged over the prior.* Let all members of H be samplers, let W = 1, let the human be drawn from w, and let the questions depend on the human only through the answers. For β ∈ (0, 1) let 𝒞^mass_β(D) be the shortest initial segment {ν_1, …, ν_i} of posterior mass at least β. Then Pr[P ∈ 𝒞^mass_β(D)] ≥ β at every stopping time, with no condition that relates β to w(P). This is an average over humans drawn from the prior. It is not a guarantee for one given human: for a human of small weight the probability can be 0, and the prior depends on the reference machine (attack report, finding m9).

*Proof.* (a) If w_D(ν_i) ≥ α then w_D(ν_i) ≥ α·Σ_{i′≤i} w_D(ν_{i′}), because the sum is at most 1; and Σ_{i′≤i} w_D(ν_{i′}) ≥ w_D(ν_1) = w_max(D). ν_1 satisfies both conditions. The posterior weights sum to 1, which gives the first and the third bound on the size. For the second let ν_{i_1}, …, ν_{i_k} be the members of 𝒞^cum_α(D) in order; each has weight at least w_D(ν_{i_k}), so w_D(ν_{i_k}) ≥ α·Σ_{i′≤i_k} w_D(ν_{i′}) ≥ α·k·w_D(ν_{i_k}), hence k ≤ 1/α. (b) Z_n := ξ(D_{≤n})/P(D_{≤n}) is well defined almost surely (Lemma 1.1(1)), Z_0 = W, and it is a nonnegative supermartingale: in an asked round, E[Z_n | 𝓖_n] = Z_{n−1}·Σ_{y : P(y|x_n) > 0} M^(n)(y|x_n) ≤ Z_{n−1}. By Ville's inequality Pr[sup_n Z_n ≥ v] ≤ W/v. Since w_{D_{≤n}}(P) = w(P)/Z_n, the event {w_{D_{≤n}}(P) < α} is {Z_n > w(P)/α}. The conditional statement is the same argument for Z_n/Z at the stopping time. (c) For a function f(D) = 1 and ξ(D) ≤ W. (d) Given D, the human has the posterior distribution, and the set has posterior mass at least β. ∎

*Which set.* The absolute set is small but can be empty, and then the rule abstains everywhere although the mixture may be accurate. The ratio set is never empty but can be large: a class with many equally good explanations puts them all in. The cumulative set is never empty and has at most 1/α members; it is the set of the literature. The conditions for the human to be in the set are, in this order: posterior weight at least α; at least α times the posterior mass of the explanations that are at least as good; at least α times the weight of the best explanation. Only the last is the assumption named in the task ("within log(1/α) bits of the best explanation"), so the coverage theorem below is stated for the ratio set; (a) of that theorem holds for the other two sets with log(1/α) replaced by log(w_max(D)/α).

**Assumption (A_α), for data D:** w_D(P) ≥ α·w_max(D). The number g_P(D) := log(w_max(D)/w_D(P)) ≥ 0 is the *gap* of the human: the number of bits by which the best explanation of the data beats the human. (A_α) says g_P(D) ≤ log(1/α). In a class of functions g_f(D) = K − K_D.

### 5.3 Coverage: where the rule abstains

The statements about separation are made for classes with the following properties.

* **(P1) patches.** There is a constant c₁ such that for every ν ∈ H, every decidable Q ⊆ X and each b ∈ {b₀, b₁}, the hypothesis ν^{Q,b} that answers b on Q and answers as ν outside Q belongs to H, the map ν ↦ ν^{Q,b} is injective, and w(ν^{Q,b}) ≥ w(ν)·2^(−K(Q)−c₁).
* **(P2) differences.** All members of H are functions, and there is a constant c₂ such that for all g, g′ ∈ H the set {x : g(x) ≠ g′(x)} is decidable with complexity at most log(1/w(g)) + log(1/w(g′)) + c₂.
* **(P3) points.** K({x}) ≤ K(x) + c₃ for every x, where K(x) is the prefix complexity of the string x.

*The class of all programs.* Let the hypotheses be the programs p of the fixed universal prefix machine that compute a hypothesis ν_p, with w(p) := 2^(−|p|); two programs for the same kernel are two hypotheses, and Σ_p w(p) ≤ 1 by Kraft's inequality. A program for ν^{Q,b} consists of a fixed piece of code, a shortest decider of Q, the bit that names b, and p; this gives (P1). If the class is restricted to programs that compute total functions, a decider of {g ≠ g′} consists of fixed code and the two programs, which gives (P2). (P3) is standard. So K = log(1/w(P)) is the length of the human's program, at best the complexity of the human.

**Theorem 5.3 (coverage of the minimum rule; Ab2, second part). PROVED for the inner region as the candidate states it up to the constant; the outer region is NEW.** Let H satisfy (P1), let D be a data list with ξ(D) > 0 and A := A(D), let α ∈ (0, 1] and 𝒞 := 𝒞^rat_α(D).

(a) *Where it abstains with certainty.* Let ν ∈ H with w_D(ν) ≥ 2^(−g)·w_max(D). At every x with sep(x; A) ≤ log(1/α) − g − c₁ we have θ_𝒞(x) = 1. In particular θ_𝒞(x) = 1 whenever sep(x; A) ≤ log(1/α) − c₁ (take for ν a hypothesis of largest posterior weight), and whenever sep(x; A) ≤ log(1/α) − g_P(D) − c₁ (take ν = P).

(b) *Where it answers.* Let H also satisfy (P2), let the human be f, and let D be data produced by f. If some member of 𝒞 answers x differently from f, then sep(x; A) ≤ K + K_D + log(1/α) + c₂; in particular this holds whenever θ_𝒞(x) > 0. So at every x with sep(x; A) > K + K_D + log(1/α) + c₂ all members of 𝒞 answer f(x), and so does the rule. This does not need f ∈ 𝒞.

(c) With (P3): θ_𝒞(x) = 1 at every unasked x with K(x) ≤ log(1/α) − c₁ − c₃.

(d) *The threshold rule.* Under (P1), Thr_η(D) abstains at every x with sep(x; A) < log(1/η) − c₁.

So, for a class of functions with (P1) and (P2),

  {x : sep(x; A) ≤ log(1/α) − c₁} ⊆ {x : the rule abstains} ⊆ {x : sep(x; A) ≤ K + K_D + log(1/α) + c₂}.

*Proof.* (a) Let Q be a decidable set with x ∈ Q, Q ∩ A = ∅ and K(Q) = sep(x; A). No asked input lies in Q, so ν^{Q,b}(D) = ν(D), and w_D(ν^{Q,b}) = w(ν^{Q,b})·ν(D)/ξ(D) ≥ 2^(−K(Q)−c₁)·w_D(ν) ≥ 2^(−K(Q)−c₁−g)·w_max(D) ≥ α·w_max(D) for b = b₀ and b = b₁. Both patched hypotheses are in 𝒞; at x one answers b₀ and the other b₁ with probability 1; hence S_𝒞(y|x) = 0 for every y. (b) Let g′ ∈ 𝒞 with g′(x) ≠ f(x). (If θ_𝒞(x) > 0 there is such a g′: for functions θ_𝒞(x) > 0 means that two members of 𝒞 differ at x, and one of them differs from f.) Since w_D(g′) > 0, g′ agrees with f on A, and w(g′) ≥ α·2^(−K_D) by the definition of the ratio set. The set {g′ ≠ f} contains x, is disjoint from A, and by (P2) has complexity at most K + K_D + log(1/α) + c₂. Hence, if sep(x; A) exceeds this number, no member of 𝒞 differs from f at x; 𝒞 is not empty, so the rule answers f(x). (The prover's proof started from θ_𝒞(x) > 0 only, which does not cover the case that all members agree on a value other than f(x) when f ∉ 𝒞; check report, correction 4.) (c) For x ∉ A the set {x} separates x from A. (d) By (P1) and injectivity, M_D(b|x) ≥ Σ_ν w_D(ν^{Q,b}) ≥ 2^(−K(Q)−c₁)·Σ_ν w_D(ν) = 2^(−K(Q)−c₁) for b = b₀, b₁; so every y has M_D(y|x) ≤ 1 − 2^(−sep(x;A)−c₁) < 1 − η. ∎

*What it does not say.* Between the two radii the theorem is silent, and this cannot be repaired without fixing the reference machine: in that window the answer of every scheme that takes its bias from the machine can be reversed by a change of machine of sep(x; A) + O(1) bits (`ultranatural/note.md`, Theorem 3, as reported in `understand/repo.md`, item G4; not re-derived here). For samplers there is no outer region at all: a member of 𝒞 that differs slightly from P at every input makes θ_𝒞 positive everywhere, and what limits θ_𝒞 is statistical (Theorem 5.6), not a matter of separation.

**Proposition 5.4 (the minimum rule abstains no more than soundness requires). PROVED (for the version space this is the optimality of the consistent selective strategy; El-Yaniv and Wiener 2010, Theorem 7, as restated in `understand/abstention-shift.md`, not read by me).** Let H be a class of functions and 𝒞 a nonempty set of members (in the applications, members that are consistent with data D; the proof does not use this). Call a kernel C on Y_⊥ *sound for 𝒞* if C({g(x), ⊥} | x) = 1 for every g ∈ 𝒞 and every x: whichever member of 𝒞 the human is, C is never silently wrong. Then Min_𝒞 is sound for 𝒞 and abstains exactly on DIS(𝒞) := {x : two members of 𝒞 differ at x}; and every kernel that is sound for 𝒞 abstains with probability 1 on DIS(𝒞).

*Proof.* For functions S_𝒞(y|x) = 1 if all members answer y at x and S_𝒞(·|x) = 0 otherwise. If g(x) ≠ g′(x) for members g, g′ and C is sound, then C gives probability 1 to {g(x), ⊥} and to {g′(x), ⊥}, hence to ⊥. ∎

So the abstention region is not a property of the rule; it is a property of the set of humans for which soundness is demanded. Theorem 5.3 computes that region for the set "within log(1/α) bits of the best explanation".

**Corollary 5.5 (what a moderate α guarantees). PROVED.** Freeze the ratio set at data D and assume (A_α). Then:

1. *Dominance, on any inputs.* For every scaffold and every set B of complete runs, the run of Min_𝒞 lies in B with probability at most Q_P(B); the run is the human system's run or an initial part of it followed by an abort; its total variation distance to the human system is its abort probability.
2. *A list of what is not answered.* Under (P1) the rule abstains with certainty at every x that a test of complexity at most log(1/α) − c₁ separates from the asked inputs; with (P3), at every unasked x of complexity at most log(1/α) − c₁ − c₃.
3. *What is answered.* Under (P1), (P2) with a function f as the human: at every x with sep(x; A) > 2K_D + 2 log(1/α) + c₂ the rule answers f(x).
4. *On the rehearsed closed system* the abort probability is bounded by Theorem 5.6.

*Proof.* (1) is Theorem 5.1 with P ∈ 𝒞. (2) is Theorem 5.3(a), (c). (3) is Theorem 5.3(b) with K ≤ K_D + log(1/α), which is (A_α). ∎

*The assumption cannot be checked from the data.* Let ν₀ agree with P on all asked inputs, differ from P at some other input x, and have w(ν₀) > w(P)/α. Under the human P the assumption (A_α) fails for all data with inputs in A, the set 𝒞 need not contain P, and the rule may answer at x as ν₀ does. The data are the same as they would be under the human ν₀, for whom the rule is right. Ville's inequality (Proposition 5.2(b)) removes the assumption only for α ≤ δ·w(P), where by Theorem 5.3(c) the rule abstains at every unasked input of complexity below K + log(1/δ) − c₁ − c₃.

### 5.4 How often the frozen rule aborts on the rehearsed closed system

**Theorem 5.6 (abort probability after rehearsal). NEW (part (b) extends claim 5 of `understand/ask-for-help.md`, Section 3.2, from independent inputs to rehearsal).** Run Protocol R (driven by the mixture) with n questions, freeze a plausible set 𝒞 ⊆ 𝒞^rat_α(D_{≤n}), and deploy Min_𝒞 on the same scaffold Π. Let η ∈ (0, 1), and let N_𝒞 be a number with |𝒞| ≤ N_𝒞 on every path.

(a) *Functions.* Let the human be a function f, and Γ_f := K ln 2 + ln(1/(α·η)). With probability at least 1 − η over the rehearsal, every g ∈ 𝒞^rat_α(D_{≤n}) satisfies (1/n)·Σ_{t≤n} d_t{x : g(x) ≠ f(x)} < L·Γ_f/n. Consequently

  Pr[the deployed run is aborted] ≤ Pr[f ∉ 𝒞] + η + N_𝒞·L·Γ_f/n + (L − 1)·L·K ln 2/n,

and on {f ∈ 𝒞} the rule is never silently wrong. For 𝒞 = 𝒞^rat_α(D_{≤n}) one can take N_𝒞 = #{g ∈ H : w(g) ≥ α·w(f)} ≤ 2^K/α, and f ∈ 𝒞 if and only if K − K_{D_{≤n}} ≤ log(1/α).

(b) *Samplers.* Assume S_½ := Σ_ν √(w(ν)) < ∞, and put Γ := ln S_½ + ½·ln(1/(α·w(P))) + ln(1/η). With probability at least 1 − η over the rehearsal, every ν ∈ 𝒞^rat_α(D_{≤n}) satisfies (1/n)·Σ_{t≤n} ∫ H²(ν, P) dd_t < L·Γ/n. Consequently

  Pr[the deployed run is aborted] ≤ Pr[P ∉ 𝒞] + η + N_𝒞·L·√(2Γ/n) + (L − 1)·L·√(K ln 2/(2n)).

For 𝒞 = 𝒞^cum_α(D_{≤n}) one can take N_𝒞 = 1/α, and Pr[P ∉ 𝒞] ≤ α/w(P).

(c) The term ln S_½ cannot be dropped from Γ in (b): for every n there is a class with K = 1 and S_½ finite but large in which the frozen ratio rule aborts with probability at least 1/2 at every input after n questions (Example 5.7(b)). So no bound of this kind in K, α, η, L and n alone holds for samplers. And N_𝒞 in (a) can be as large as 2^K (Example 5.7(a)).

*Proof.* (b) For a hypothesis ν put ψ_t(ν) := √(ν(y_t|x_t)/P(y_t|x_t)) if a_t = 1 and ψ_t(ν) := 1 otherwise. Then E[ψ_t(ν) | 𝓖_t] = 1 − a_t·H²(ν, P)(x_t), and by Lemma 1.2, E[ψ_t(ν) | 𝓕_{t−1}] = 1 − h_t(ν) with h_t(ν) := (1/L) ∫ H²(ν, P) dd_t ∈ [0, 1]. So Λ_n(ν) := Π_{t≤n} ψ_t(ν)/(1 − h_t(ν)) (with a factor read as 0 when h_t(ν) = 1, in which case ψ_t(ν) = 0 almost surely) is a nonnegative supermartingale with Λ_0(ν) = 1, and by Markov's inequality Pr[Λ_n(ν) ≥ S_½/(η·√w(ν))] ≤ η·√w(ν)/S_½. The sum of these probabilities over ν is η. Outside the union of these events, every ν satisfies √(ν(D_{≤n})/P(D_{≤n})) = Π_t ψ_t(ν) < exp(−Σ_t h_t(ν))·S_½/(η·√w(ν)). If ν ∈ 𝒞^rat_α(D_{≤n}), then w(ν)·ν(D_{≤n}) ≥ α·w(P)·P(D_{≤n}), because w_max ≥ w_{D_{≤n}}(P); so √(ν(D_{≤n})/P(D_{≤n})) ≥ √(α·w(P)/w(ν)). The two inequalities give exp(Σ_t h_t(ν)) < S_½/(η·√(α·w(P))), that is, Σ_t h_t(ν) < Γ. This is the first claim.

For the second, work on the event that P ∈ 𝒞 and that the first claim holds. By Theorem 5.1(4) the abort probability given the rehearsal is at most ∫ θ_𝒞 dd_P. For each round t, Lemma 1.4(2) with g := θ_𝒞 gives ∫ θ_𝒞 dd_P ≤ ∫ θ_𝒞 dd_t + (L − 1)·p_t, where p_t ≤ β(M^(t)) is the probability that the coupled runs of M^(t) and of P separate (the inequality of the lemma holds for every function with values in [0, 1], hence also for one that depends on the later data). Average over t. By Theorem 5.1(5) and TV ≤ √(2H²), θ_𝒞 ≤ Σ_{ν∈𝒞} √(2H²(ν, P)); by the Cauchy–Schwarz inequality and d_t(X) ≤ L, ∫ √(2H²(ν, P)) dd_t ≤ √(2L·∫ H²(ν, P) dd_t); and by Jensen's inequality (1/n) Σ_t √(2L ∫ H²(ν, P) dd_t) ≤ √(2L·(1/n) Σ_t ∫ H²(ν, P) dd_t) < L·√(2Γ/n). So the abort probability given the rehearsal is at most N_𝒞·L·√(2Γ/n) + (L − 1)·(1/n) Σ_t β(M^(t)), and the expectation of the last average is at most L·√(K ln 2/(2n)) by Corollary 1.3. The bounds on N_𝒞 and on Pr[P ∉ 𝒞] are Proposition 5.2(a), (b).

(a) is the same argument with indicators. For g ∈ H let h_t(g) := (1/L)·d_t{g ≠ f}, the conditional probability that the question of round t refutes g. Λ_n(g) := Π_{t≤n} 1[g is not refuted in round t]/(1 − h_t(g)) is a nonnegative supermartingale started at 1; with the thresholds W/(η·w(g)) and a union bound, with probability at least 1 − η every g that is consistent with D_{≤n} has Σ_t h_t(g) ≤ Σ_t −ln(1 − h_t(g)) < ln(W/(η·w(g))). A member g of the ratio set has w(g) ≥ α·2^(−K_D) ≥ α·w(f), so Σ_t h_t(g) < Γ_f. For the abort probability: θ_𝒞 is the indicator of DIS(𝒞) ⊆ ∪_{g∈𝒞} {g ≠ f}, so ∫ θ_𝒞 dd_t ≤ Σ_{g∈𝒞} d_t{g ≠ f}; the rest is as in (b), with E β(M^(t)) summing to at most L·K ln 2 (Corollary 1.3). The members of the ratio set have weight at least α·w(f), which bounds their number by W/(α·w(f)). ∎

*Reading.* For samplers the abort probability on the closed system is of order (L/α)·√((K + ln S_½ + ln(1/α))/n) + L²·√(K/n). With the choice α = δ·w(P) that Ville's inequality allows, it is small only for n of order 4^K·L²·(K + ln S_½ + ln(1/δ))/δ². This is empty for a person. With a moderate α and the assumption (A_α) in the cumulative form, n of order L²·(K + ln S_½)/α² suffices.

**Example 5.7 (the two hypotheses of Theorem 5.6 that cost the most). PROVED.**

(a) *Many equally good explanations: the ratio set is a rock on the closed system until almost every input has been asked.* Take the needle class 𝒩(N₀) with equal weights and the OR scaffold (Theorem 4.5), and let the human be f₀. All members have the same weight, so for every α ≤ 1 the ratio set is the set of all members consistent with the data: after questions at a set S of cells it is {f₀} ∪ {f_c : c ∉ S}, and Min aborts as soon as the run meets a cell outside S. With at most n questions the abort probability is at least 1 − (n/N₀)^L. By contrast Thr_η with η > 1/(N₀ + 1 − n) answers 0 at every cell and never aborts; it is silently wrong with probability at most L/N₀ per run when the human is a needle.

(b) *Fill-ins of the human's coins: the term ln S_½ is needed.* Let d ≥ 1 and c₀ ∈ {1, …, d − 1}, X := {0, 1}^d, Y := {0, 1}. The human P₀ answers every input with a fair coin and has weight 1/2. The other hypotheses are the 2^d linear functions x ↦ ⟨s, x⟩ mod 2, s ∈ {0, 1}^d, each of weight 2^(−d−1). So K = 1. The scaffold makes one call at a uniformly random input. Run any protocol that asks n := d − c₀ uniformly random inputs. With probability at least 1 − 2^(−c₀) these are linearly independent; then exactly 2^(c₀) linear functions are consistent with the data, whatever the answers, and each has posterior weight 2^(−c₀) times that of P₀, which is the largest. So for α ≤ 2^(−c₀) they all belong to 𝒞^rat_α. At an input outside the span of the asked ones, half of them answer 0 and half answer 1, so S_𝒞 = 0 there; at an input in the span they agree and S_𝒞 gives the coin's probability 1/2 to their answer. Hence the frozen rule aborts with probability at least 1/2 at every input, and with probability 1 at a random input except with probability 2^(−c₀). So for every n there is a class with K = 1, with the human as the best explanation of every data set, in which the frozen ratio rule with α = 2^(−c₀) is useless after n questions. Here S_½ is finite and ln S_½ ≥ (d − 1)·ln 2/2, so Γ/n > 0.34; the set 𝒞 has 2^(c₀) + 1 ≥ 3 members, so the term N_𝒞·L·√(2Γ/n) exceeds 1 and the bound of Theorem 5.6(b) is void, as it must be. The example is a family of classes, one for each n, with S_½ growing; it shows that the term ln S_½ is needed, not that a single class with S_½ = ∞ defeats the rule for all n.

In (b) the fill-ins are the hypotheses "the human with the coins filled in" of `proofs/hellinger-runs.md`, Example 5.4. Weights with Σ_ν √w(ν) < ∞ exclude them; for programs of a prefix machine, w(p) = 2^(−λ|p|) with λ ≥ 2 has Σ_p √w(p) ≤ 1 by Kraft's inequality (the weights of the candidate's Theorem B).

### 5.5 Comparison with Cohen, Hutter and Nanda

*Source.* M. K. Cohen, M. Hutter and N. Nanda, "Fully General Online Imitation Learning", Journal of Machine Learning Research 23(334):1–30, 2022 (JMLR paper 21-0618); arXiv:2102.08686. The prover read the definitions and Theorems 1 to 5 in the TeX source of arXiv version 2; the statements below are transcribed from it, in their notation. Both verifiers opened the same source: the attack report compared all five statements with it and found them in agreement; the check report confirmed Theorems 1 and 2 and the hypotheses of Theorems 3 to 5.

*Their setting.* Time steps t = 0, 1, 2, …; a finite action set 𝒜; observations; h_{<t} is the history of triples (q, a, o), where q ∈ {0, 1} records whether the demonstrator chose the action. The environment μ is an arbitrary history-dependent kernel and never resets. The demonstrator's policy π^d may depend on the whole history. Π is a countable class of policies with prior weights w summing to 1, and π^d ∈ Π (realisability). The posterior w(π | h_{<t}) is updated on the actions chosen by the demonstrator only. With π_1, π_2, … in decreasing order of posterior weight, the top set is Π^α_{h<t} := {π_n : w(π_n | h_{<t}) ≥ α·Σ_{m≤n} w(π_m | h_{<t})}. The imitator takes action a itself with probability min_{π′ ∈ Π^α} π′(a | h_{<t}); with the remaining probability θ_q(h_{<t}) := 1 − Σ_a min_{π′} π′(a | h_{<t}) it *queries*: the demonstrator chooses the action. P^i is the law of the interaction with the imitator, P^d the law when the demonstrator chooses every action, and E the event that π^d ∈ Π^α_{h<t} for all t. "Fair" means that neither μ nor π^d depends on the query record.

*Their theorems.* With s_α := |𝒜|·α^(−3)·(24·w(π^d)^(−1) + 12):

1. (Limited Querying) E_{P^i}[Σ_{t=0}^∞ θ_q(h_{<t})³] ≤ s_α.
2. (Top Models Contain Truth) P^i(E) ≥ 1 − α·w(π^d)^(−1).
3. (Predictive Convergence) For α < w(π^d): E_{P^i}[Σ_t (Σ_a |π^i_α(0, a | h_{<t}) − π^d(1, a | h_{<t})|)³ | E] ≤ s_α/(1 − α·w(π^d)^(−1)).
4. (KL Bound) For fair μ, π^d and α < w(π^d), with both laws restricted to the first t actions and observations: KL_t(P^i(· | E) ‖ P^d(· | E)) ≤ s_α^(1/3)·t^(2/3)/(1 − α/w(π^d))² − log(1 − α/w(π^d)).
5. (Preserving Unlikeliness) For fixed t, an event B on the first t actions and observations and D := B ∩ E, for fair μ and π^d: P^i(D) ≤ t²·s_α/( log(t²·s_α/(27·P^d(B))) − 3·log log(1 + t^(2/3)·s_α^(1/3)/(3·P^d(B)^(1/3))) )³.

Their proof of 4 and 5 rests on what they call the crux: if π^d ∈ Π^α then π^i_α(0, a | h) ≤ π^d(a | h), and with the queried part π^i_α(a | h) ≤ (1 + θ_q(h))·π^d(a | h). The authors state that with α below w(π^d) the bounds are "effectively quartic in w(π^d)^(−1)", that "the training never ends", and that setting α requires an estimate of w(π^d).

*What in Ab2 is theirs.* (i) The object: the minimum, over a set of models of large posterior weight, of the probability of each answer, with the leftover probability not used for answering. (They credit the idea of a minimum over top models to the pessimistic agent of Cohen and Hutter 2020.) (ii) The top set 𝒞^cum; the candidate's ratio set is a superset of it. (iii) The domination at one step when the truth is in the set (Theorem 5.1(1)). (iv) The Ville step (Proposition 5.2(b)) is their Theorem 2, with the same proof.

*What is not in their paper.* (i) The use after a finite phase: the posterior is frozen and the leftover probability is an abort, not a query. (ii) The exact domination of whole runs, Theorem 5.1(2)–(4). Their Theorem 5 is weaker by necessity: a queried step lets the demonstrator act, and the imitator's law then exceeds the demonstrator's by the factor 1 + θ_q at each step; with an abort in the place of the query no such factor arises, and the bound has the factor 1 and no dependence on t. This observation is in `understand/ask-for-help.md`, Section 3.2. (iii) Where the frozen rule abstains (Theorem 5.3) and how often it aborts on a rehearsed system (Theorem 5.6). (iv) That for a deterministic human no probability is lost in the Ville step (Proposition 5.2(c)).

*What is in their paper and not here.* A bound on the querying when the human stays available: Theorem 1 above, for stochastic history-dependent demonstrators in environments without resets. For that online regime we have nothing better; Theorem 3.1 bounds divergences, not the leftover probability of a minimum rule, and Proposition 4.3 is for functions. Their setting also covers a demonstrator with memory, which assumption A1 excludes.

*The comparison in one sentence.* Their imitator and the minimum rule over the cumulative set 𝒞^cum are the same kernel (the ratio set of the candidate's Ab2 is a superset of 𝒞^cum, in some classes a much larger one, Example 5.7(a), and gives a kernel that abstains at least as much); they keep the human for ever and prove that questions become rare at a price of order w^(−4); here the human leaves after n questions, dominance becomes exact, and the price moves into the abort probability, which is controlled only on the rehearsed closed system and at a price polynomial in 1/α.

## 6. Ab3: the novelty rule

In this section H is a class of functions with property (P2), for example the programs that compute total functions, and the human is a function f ∈ H.

**Definition 6.0 (novelty rule; Observation B of `understand/notes.md`).** Let s ≥ 1. The rule Nov_s keeps the data D with asked set A = A(D). At an input x: if sep(x; A) < s, it *asks* the human and appends the answer to the data (ask variant), or it *abstains* (abstain variant); otherwise it answers g_D(x), where g_D is a member of H of largest weight among those consistent with D, ties broken by a fixed rule (the simplest consistent hypothesis).

**Proposition 6.1 (Ab3: both claims, and the constant). PROVED.**

1. *Count.* In the ask variant, on every sequence of inputs, of any length and chosen in any way, the number of questions is at most the number of decidable sets of complexity below s, which is at most 2^s − 1. This needs no assumption on the human.
2. *Soundness.* If an answer given without asking at x is wrong, then s ≤ sep(x; A) ≤ K + K_D + c₂ ≤ 2K + c₂. Hence if s > 2K + c₂, every answer given without asking equals f(x). The constant c₂ is that of (P2): the cost of forming a decider of {g ≠ g′} from programs for g and g′.
3. *Comparison with enumeration.* Let k ≥ K. The rule that keeps V := {g ∈ H : w(g) ≥ 2^(−k), g consistent with the data}, asks at x if two members of V differ at x and answers their common value otherwise, is never wrong and asks at most 2^k − 1 questions on every sequence. Whenever it asks at x, sep(x; A) ≤ 2k + c₂. So after the same data the novelty rule with s = 2k + c₂ + 1 asks wherever enumeration asks, and its count is 2^(2k+c₂+1) against 2^k.

*Proof.* (1) At each question choose a decidable Q with K(Q) < s, x ∈ Q and Q ∩ A = ∅ for the set A before the question. After the question x ∈ A, so Q meets A from then on and is not chosen at any later question. The chosen sets are therefore distinct, and fewer than 2^s programs have length below s. (2) Let the rule answer g_D(x) ≠ f(x). Both g_D and f are consistent with D, so they agree on A; the set {g_D ≠ f} is decidable, contains x and is disjoint from A, and by (P2) its complexity is at most K + log(1/w(g_D)) + c₂ = K + K_D + c₂. Since f is consistent, K_D ≤ K. And the rule answered, so sep(x; A) ≥ s. (3) f ∈ V always, at most 2^k hypotheses have weight at least 2^(−k), and each question refutes at least one member of V other than f. If g, g′ ∈ V differ at x, then {g ≠ g′} separates x from A and has complexity at most 2k + c₂. ∎

*Source (editor; attack report, finding m4).* Items 1 and 2 are Observation B of `research/understand/notes.md`. The enumeration rule of item 3 and its count are the bound for learners that must be right or say "I don't know" (the KWIK model of L. Li, M. L. Littman and T. J. Walsh 2008: |H| − 1 such answers suffice for a finite class H of functions; quoted from a digest, Section 11).

*On the constant 2.* The factor 2 comes from (P2): the only test that the proof has for a wrong answer is the set where the rule's hypothesis and the human differ, and describing it takes both programs. I do not know whether 2K can be lowered for this rule (Section 9). A variant that measures novelty relative to its own current hypothesis, asking if and only if some Q with x ∈ Q, Q ∩ A = ∅ has complexity below s *given a program for g_D*, is never wrong once s > K + c for a suitable constant c, because {g_D ≠ f} has complexity at most K + c given a program for g_D. But its tests change whenever g_D changes, which can happen 2^K times, so the bound on its number of questions that the argument of (1) gives is 2^(2K+c+1), no better than before.

**Proposition 6.2 (when nobody answers the abstentions). PROVED; item 3 is NEW.** Let the abstain variant be frozen at data D with A = A(D).

1. It abstains exactly on {x : sep(x; A) < s}, for ever. With (P3) this set contains every unasked x with K(x) < s − c₃. In particular, for an s that Proposition 6.1(2) certifies as sound (s > 2K + c₂), the frozen rule answers no unasked input of complexity below 2K + c₂ − c₃: it refuses every new input that is simpler than twice the human.
2. For any s, the frozen rule is wrong exactly at the inputs x with sep(x; A) ≥ s and g_D(x) ≠ f(x), and all of these have sep(x; A) ≤ K + K_D + c₂. So with a moderate s it is sound if and only if the simplest hypothesis consistent with the data agrees with the human outside the abstention region. That is an assumption, and its failure is silent.
3. *How much it refuses on a rehearsed system.* Let the data come from Protocol R[𝔯] with any driver and n rounds, and let η ∈ (0, 1). With probability at least 1 − η,

  (1/n)·Σ_{t≤n} d_t{x : sep(x; A(D_{≤n})) < s} ≤ 2^s·L·(s ln 2 + ln(1/η))/n:

the expected number of calls of a rehearsal run that fall in the frozen abstention region, averaged over the rounds, is at most this. This is a statement about the runs of the driver during the rehearsal (d_t is the visit measure of the driver of round t). It is not a bound on the probability that a deployed run of the frozen rule is aborted: the calls of that run follow the driver's only as long as the two give the same answers (attack report, finding m2). Item 4 is such a bound for the case that the rule itself drives the rehearsal.

4. *(Editor; not checked by a verifier.) Abort probability when the rule drives the rehearsal.* Run Protocol R[Nov_s] with the abstain variant as the driver: in round t the rule frozen at D_{<t} answers the calls, the run halts at its first abstention, and one uniformly chosen call slot is put to the human (the call at which the run was aborted can be asked like any other). Let Halt_t be the event that the run of round t is aborted and Wr_t the number of its calls that are answered wrongly. Then

  Σ_{t≤n} Pr[Halt_t] ≤ L·(2^s − 1)  and  Σ_{t≤n} E[Wr_t] ≤ L·(2^K − 1).

So the run of the rule of a uniformly chosen round T is aborted with probability at most L·(2^s − 1)/n and contains at most L·(2^K − 1)/n wrong answers in expectation. The first bound assumes nothing about the human. The second counts the hypotheses that are at least as heavy as the human; it is empty for a person, and it is the price of letting the simplest consistent hypothesis answer (compare R6 of the note).

*Proof.* (1) and (2) are the definition and Proposition 6.1(2); for x ∉ A the set {x} separates x from A. (3) For a decidable Q put h_t(Q) := d_t(Q)/L, the conditional probability that the question of round t lies in Q (Lemma 1.2). Π_{t≤n} 1[the question of round t is not in Q]/(1 − h_t(Q)) is a nonnegative supermartingale started at 1. By Markov's inequality with the threshold 2^s/η and a union bound over the fewer than 2^s sets of complexity below s: with probability at least 1 − η, every such Q that is disjoint from A(D_{≤n}) has Σ_t h_t(Q) ≤ Σ_t −ln(1 − h_t(Q)) < s ln 2 + ln(1/η). The abstention region is the union of these sets, so its d_t-measure is at most the sum of theirs. (4) The questions of the protocol form a sequence as in Setting 1.0. By the argument of Proposition 6.1(1), on every path at most 2^s − 1 asked rounds have an asked input x_t with sep(x_t; A(D_{<t})) < s, because each such question uses up one test of complexity below s. By Lemma 1.2 with φ(D, x) := 1[sep(x; A(D)) < s], the asked round t is of this kind with probability Pr[Halt_t]/L: a run has at most one call in the abstention region of its own rule, its last. Summing over t gives the first bound. For the second: at an asked round with g_{D_{<t}}(x_t) ≠ f(x_t) the hypothesis g_{D_{<t}} is refuted by the answer. It has weight at least w(f), because f is consistent with the data and g_{D_{<t}} has the largest weight among the consistent members. At most W/w(f) ≤ 2^K members have weight at least w(f), and f is one of them and is never refuted; so on every path at most 2^K − 1 asked rounds are of this kind, and by Lemma 1.2 with φ(D, x) := 1[sep(x; A(D)) ≥ s and g_D(x) ≠ f(x)] the asked round t is of this kind with probability E[Wr_t]/L. The statements for the round T follow from the last sentence of Lemma 1.2. ∎

*Reading.* The novelty rule is the plainest whitelist: it refuses the inputs that a test of fewer than s bits separates from what has been asked, and nothing else. With the human answering, it pays once for each kind of novelty, at most 2^s times. Without the human it refuses every such input for ever. If s is large enough for soundness to be proved (2K + c₂), that is every unasked input of complexity below about 2K; for a person this is, one expects, every input that will ever be written down (an expectation relative to the reference machine, not a theorem). If s is moderate, the frozen region contains a fraction of order 2^s·s/n of the calls of the rehearsal runs (item 3); when the rule itself drives the rehearsal, its deployed run is aborted with probability at most L·2^s/n (item 4); and its soundness is the assumption in (2), for which item 4 has only the bound L·2^K/n. The quantity sep is not computable; a version with time-bounded tests is computable, and (1) and (3) hold for it with the same proofs, with the set of tests replaced by the time-bounded ones. I did not work out what replaces (2).

## 7. N4, the trade-off as one statement, and which rules are rocks

### 7.1 N4: never silently wrong

**Proposition 7.1 (never silently wrong forces asking or abstaining wherever two members differ). PROVED.** Consider a learner with questions on request (Section 3.2), possibly randomised, and a set H₀ of functions. Suppose that for every member of H₀ as the human and every way in which the inputs are chosen, with probability 1 every prediction is right. Let f, f′ ∈ H₀. Then, when the human is f, with probability 1 the learner asks or abstains at every step t such that f′(x_t) ≠ f(x_t) and f′ agrees with f at all inputs asked before step t.

*Proof.* Run the interaction with f and the interaction with f′ with the same seed and the same rule for choosing the inputs. By induction over the steps the two interactions coincide (inputs, actions, answers) as long as no question has been asked at an input where f and f′ differ. So on the event E that step t is as described, the learner's action at step t is the same in both. If it were a prediction y on a part of E of positive probability, then y ≠ f(x_t) or y ≠ f′(x_t), and one of the two humans would receive a wrong prediction with positive probability. ∎

**Corollary 7.2 (N4; point functions). PROVED (the candidate's N4; `understand/repo.md`, items C3(2) and X2; Observation C of `understand/notes.md`).** Let X = {0, 1}^d, f₀ ≡ 0 and f_a := 1[· = a].

1. If H₀ ⊇ {f₀} ∪ {f_a : a ∈ X}, then under f₀ the learner asks or abstains at every step whose input has not been asked before. On a sequence of u distinct inputs, Qu + Abs ≥ u; a learner that asks nothing abstains at every input; a learner that never abstains asks 2^d questions on the sequence of all inputs.
2. Let H₀ = {f_a : a ∈ X} (without the zero function), and let the 2^d inputs be shown once each, in any order. Under f_a the learner asks or abstains at every step t ≤ 2^d − 1 before which the input a has not been asked. In particular, if the input a is the last of the sequence, the learner asks or abstains at each of the first 2^d − 1 steps. (Once a question at a has been answered 1 the learner knows the human, and nothing is forced any more.)
3. In the class of all programs each f_a has a program of length at most d + 2 log d + c. So a learner that is never silently wrong for all functions with programs of length at most k asks or abstains at least 2^(k − 2 log k − c′) times on some sequence, under the zero function; enumeration (Proposition 6.1(3)) does it with at most 2^k − 1 questions.

*Proof.* (1) Proposition 7.1 with f = f₀ and f′ = f_{x_t}: all earlier answers were 0, and f_{x_t} vanishes at the earlier asked inputs because x_t is not among them. (2) Let t ≤ 2^d − 1, and let a not have been asked before step t. If x_t ≠ a, use Proposition 7.1 with f = f_a and f′ = f_{x_t}: the two differ at x_t and at a only, and neither x_t (shown for the first time) nor a has been asked before step t. If x_t = a, let b be an input that has not been shown yet (there is one, because t ≤ 2^d − 1), and use f′ = f_b: it differs from f_a at a = x_t and at b only, and neither has been asked before step t. (3) A program for f_a contains a self-delimiting code of a. ∎

(Editor.) The prover's item 2 read "the 2^d inputs are shown once each with a last", meaning that the input a comes last; the check report read "a last" as "a last input" and called the item wrong (its correction 2), while the attack report read it as intended and confirmed it. The item is now stated for every order, with the proof that the check report supplied for the case x_t = a.

LB Corollary 1.7 is the same fact for a protocol that has stopped asking: a deployed system that is never silently wrong for f and for all its one-point patches abstains with probability 1 at every unasked input. Proposition 7.1 and Corollary 7.2 are not new: the point functions are the standard example of a class that needs |H| − 1 answers "I don't know" in the KWIK model (Li, Littman and Walsh 2008; Sayedi, Zadimoghaddam and Blum 2010; both quoted from digests, Section 11), and item C3(2) of `research/understand/repo.md` has the form for identification from this repository's first paper.

### 7.2 The trade-off

**Theorem 7.3 (silent errors against abstentions against questions). PROVED (it collects Theorems 3.1, 3.3, 4.1, 4.4, 4.5, Propositions 4.3, 4.6 and Corollaries 3.5, 7.2).** Let the human be a function f ∈ H and K = log(1/w(f)).

**(U) What can be had.**

* (U1) *Inputs from outside.* For every q ∈ (0, 1] and η ∈ (0, 1/2), the threshold rule with audits (Proposition 4.3(b), variant A) has, on every input sequence and over the whole unbounded interaction,

  E[Sil] ≤ ((1 − q)/q)·K/log(1/η),  Abs ≤ K/log(1/(1 − η)),  E[Qu among the first h steps] ≤ q·h + K/log(1/(1 − η)).

 Its corners: q = 1 (the human answers everything; no error, h questions); no abstention, where the mixture's own draws give E[Sil] ≤ (1 − q)·K ln 2/q with q·h questions (Theorem 3.1); q → 0 with η < w(f)/W, for which η < w(f) suffices (no silent error and at most K/log(1/(1 − η)) ≤ K ln 2/η questions, all of them abstentions, over a deployment of any length; with η just below 2^(−K) this is about K ln 2·2^K). In this corner all three quantities are bounded: the asking stops (Corollary 3.6(b)).
* (U2) *A closed system.* After n rounds of rehearsal driven by Thr_η, the run of the rule of a uniformly chosen round has a wrong answer with probability at most L·K/(n·log(1/η)) and is aborted with probability at most L·K ln 2/(n·η) (Theorem 4.4); without abstention the run of the mixture of a uniformly chosen round is unfaithful with probability at most L·K ln 2/n. No further question is needed, for any number of later runs, if the round is drawn afresh for each run. One rule drawn once and kept for good has, with probability at least 1 − δ′ over the rehearsal and the draw, these bounds multiplied by 1/δ′ (the remark "One rule for good" after Theorem 4.4).

**(L) What cannot be had.**

* (L1) *No silent error at all.* For the point functions with the zero function, Qu + Abs is at least the number of distinct inputs, for a class of complexity d + 2 log d + c: of the order of 2^K (Corollary 7.2).
* (L2) *At most k silent errors, every answer shown.* For N = 2^K thresholds with K ≥ k + 1 and every deterministic rule, some sequence forces (k + 1)·2^(K/(k+1))/e − k − 1 abstentions (Proposition 4.6); the threshold rule needs at most about K ln 2·2^(K/(k+1)).
* (L3) *Answers seen only on questions.* For N thresholds on N − 1 inputs, E[Sil + Abs]·(E[Qu] + 1) ≥ N/15 when E[Qu] + 1 ≤ N/4 (Theorem 3.3), and with the factor K/log for a product of such classes (Corollary 3.5). So on these N − 1 inputs a number of questions that is small compared with N = 2^K leaves a number of silent errors and abstentions of the order of N divided by the number of questions. The class has N members; for a fixed class the bound is silent about longer sequences, and there the asking can stop (Corollary 3.6). (The prover's sentence here, "if the number of questions stays bounded while inputs keep arriving, silent errors plus abstentions grow linearly", was false for a fixed class.)
* (L4) *A closed system.* For the needle class with cells of equal mass, silent failure probability σ with abort probability a needs n ≥ (1 − a)²·L/(4σ) − L questions (Theorem 4.5). This is one closed system; in another, abstention reduces the questions needed by an unbounded factor (Example 4.5a).

*In words (rewritten by the editor; check report, corrections 1 and 3; attack report, findings M1 and M2).* On inputs from outside and for a deterministic human of K bits, all three quantities can be bounded, but only at an exponential price. The human can be left, with no silent error and no unanswered abstention, after at most 2^k − 1 questions if a bound k ≥ K is known (U1, Corollary 3.6(b)). No rule does essentially better in the worst case: on the 2^K thresholds, (silent errors + unanswered abstentions) × (questions + 1) ≥ 3·2^K/16 (L3), and a rule with no silent error at all asks or abstains at every new input of the point functions (L1). For a person 2^K is no bound; in this sense, and only in this sense, the asking cannot stop. For a human who is not deterministic no rule has both counts in terms of K (Proposition 4.8). When every answer is shown, each halving of the allowed number of silent errors squares the number of abstentions, roughly (L2). In a closed system all three quantities are small per run after about L·K/δ questions, abstention included or not; there abstention changes the kind of failure. How many questions it saves depends on the system: at most the factor 1/(1 − a)² on the needle class with cells of equal mass (L4), and an unbounded factor where the unlearned inputs are rare and recognisable (Example 4.5a).

(The prover's paragraph began "On inputs from outside, the three quantities cannot all be bounded" and ended "abstention … saves at most the factor (1 − a)² in questions". Both sentences were false as general statements.)

### 7.3 Rocks and whitelists

The researcher rejects rules that abstain on everything new and accepts whitelists (`understand/notes.md`, items F20, F21 and Section 6.1). The following definition makes the two words exact for a rule frozen at data D with asked set A.

**Definition 7.4.** Let Ab₁(D) be the set of inputs at which the frozen rule abstains with probability 1, and Ab₊(D) the set at which it abstains with positive probability. The rule is

* a *rock* at D if Ab₁(D) ⊇ X ∖ A: it answers no unasked input;
* a *rock below complexity r* at D if Ab₁(D) ⊇ {x ∉ A : K(x) ≤ r};
* a *whitelist of width s* at D if Ab₊(D) ⊆ {x : sep(x; A) ≤ s}: it answers every input that no test of complexity at most s separates from the asked inputs.

Call the rule *sound for a set 𝒮 of functions at D* if, for every member of 𝒮 that is consistent with D as the human, it is never silently wrong at any input (Proposition 5.4).

**Proposition 7.5 (which rule is which). PROVED.** Let H be a class of functions with (P1), (P2), (P3), for example the programs that compute total functions, and let D be data produced by the human f, with A = A(D).

0. *Soundness for a slack forces a rock radius.* Every rule that is sound at D for all members of weight at least 2^(−a)·2^(−K_D) (the hypotheses within a bits of the best explanation of D) abstains with probability 1 at every x with sep(x; A) ≤ a − c₁; in particular it is a rock below complexity a − c₁ − c₃ at D. The human is among these members if and only if a ≥ K − K_D.
1. *No budget.* A rule that is sound for all members of H is a rock at every D.
2. *Enumeration with budget k* (the minimum rule over the consistent members of weight at least 2^(−k)): sound if K ≤ k; it abstains wherever sep(x; A) ≤ k − K_D − c₁, so it is a rock below complexity k − K_D − c₁ − c₃; a whitelist of width 2k + c₂.
3. *Threshold rule Thr_η:* sound at D if w_D(f) > η, which holds for all data if η < 2^(−K); a rock below complexity log(1/η) − c₁ − c₃ − 1. No whitelist width is proved for it.
4. *Minimum rule over the ratio set 𝒞^rat_α(D):* sound if (A_α) holds, which is the case for all data if α ≤ 2^(−K); a rock below complexity log(1/α) − c₁ − c₃; a whitelist of width K + K_D + log(1/α) + c₂.
5. *Novelty rule Nov_s:* sound if s > 2K + c₂; a rock below complexity s − c₃ − 1; a whitelist of width s − 1; it abstains exactly on {sep(x; A) < s}.
6. *The mixture* never abstains; at every x with sep(x; A) < ∞ its draw is wrong with probability at least 2^(−sep(x;A)−c₁).

*Proof.* (0) Let g be a consistent member of largest weight 2^(−K_D), let sep(x; A) ≤ a − c₁, and let Q be a decidable set of complexity sep(x; A) that contains x and no asked input. By (P1) the patches g^{Q,b₀} and g^{Q,b₁} are consistent with D and have weight at least 2^(−K_D−K(Q)−c₁) ≥ 2^(−a)·2^(−K_D). They differ at x, so by Proposition 5.4 the rule abstains at x with probability 1. By (P3), sep(x; A) ≤ K(x) + c₃ for an unasked x. The human has weight 2^(−K) = 2^(−(K−K_D))·2^(−K_D). (1) Apply (0) with every a. (2) Soundness is Proposition 6.1(3). The members of weight at least 2^(−k) are those within a = k − K_D bits of the best explanation; (0) gives the rock radius. If two of them differ at x, the set where they differ separates x from A and has complexity at most 2k + c₂ by (P2). (3) If the rule answers y ≠ f(x) then M_D(f(x)|x) ≤ η, so w_D(f) ≤ η; and w_D(f) ≥ w(f)/W ≥ 2^(−K). The rock radius is Theorem 5.3(d) with (P3); the −1 turns the strict inequality into a non-strict one. (4) (A_α) says f ∈ 𝒞, and then the rule is sound by Theorem 5.1(1); w_D(f) ≥ 2^(−K) ≥ α ≥ α·w_max(D) if α ≤ 2^(−K). The radii are Theorem 5.3(a), (b), (c). (5) Propositions 6.1 and 6.2. (6) By (P1), as in the proof of Theorem 5.3(d), M_D(b|x) ≥ 2^(−sep(x;A)−c₁) for b = b₀ and for b = b₁, and at least one of the two differs from f(x). ∎

*Remark on items 3 to 5.* The conditions in these items are sufficient. If they fail, the rule may still be right at every input by coincidence, but nothing in the data guarantees it (the remark after Corollary 5.5).

**The classification.**

| rule (frozen at D) | parameter | refuses with certainty at least | refuses at most | sound for the human when |
|---|---|---|---|---|
| never silently wrong for all computable functions | none | every unasked input | — | always |
| enumeration | budget k | sep(x; A) ≤ k − K_D − c | sep(x; A) ≤ 2k + c | K ≤ k |
| threshold rule Thr_η | η = 2^(−a) | sep(x; A) < a − c | not known | posterior weight of the human above η |
| minimum over the ratio set | α = 2^(−a) | sep(x; A) ≤ a − c | sep(x; A) ≤ K + K_D + a + c | the human is within a bits of the best explanation |
| novelty rule Nov_s | s = a | sep(x; A) < a | sep(x; A) < a | a > 2K + c, or the simplest consistent hypothesis is right off the refused region |
| mixture | none | nothing | nothing | never guaranteed off the asked inputs |

**Which are rocks.** In rows two to five the rule refuses, with certainty, all inputs that a test of about a bits separates from the asked inputs, where a is its *slack*: the number of bits by which a hypothesis may be worse than the best explanation and still be taken seriously (k − K_D for enumeration). By item 0 this is forced: no rule that is sound for that set of hypotheses refuses less. Soundness for the human needs a slack of at least the human's gap K − K_D. For the threshold rule, the ratio rule and the novelty rule, a parameter that makes soundness a theorem for all data is η < 2^(−K), α ≤ 2^(−K) (for functions; for samplers Ville's inequality needs α ≤ δ·2^(−K)) and s > 2K + c₂. With such a parameter the frozen rule refuses every unasked input of complexity below about K, whatever the data (Theorem 5.3(a), (c), (d); Proposition 6.2(1)). For enumeration, soundness is a theorem as soon as k ≥ K, and the forced radius is k − K_D − c: it is about k while the data are few, and it shrinks as the data make the human the best explanation. At K_D = K = k nothing is forced, and what is proved about the rule is then only its whitelist width 2k + c₂ (attack report, finding m1). If, as one expects, K for a person exceeds the complexity of every input that will ever be written down (an expectation relative to the reference machine, not a theorem), these are rocks in the researcher's sense: the first row always; rows three to five whenever their parameter is chosen so that soundness is a theorem; row two as long as k − K_D exceeds the complexity of the inputs, that is, with a generous budget, or until the data have raised K_D to within that margin of k. They stop being rocks only if the human answers the abstentions, and then the number of answers is bounded by 2^k for enumeration, by K ln 2·2^K for the threshold rule and by 2^(2K+c) for the novelty rule (Proposition 6.1, Theorem 4.1), which for a person is no bound.

**Which are whitelists.** With a moderate slack a, the novelty rule refuses exactly the a-simple novelty, the minimum rule refuses it and nothing beyond a larger radius, and the threshold rule refuses at least it. On the rehearsed closed system they refuse little. For the novelty rule, the frozen region contains at most about 2^a·a·L/n of the calls of the rehearsal runs (Proposition 6.2(3)), and when the rule itself drives the rehearsal its deployed run is aborted with probability at most L·2^a/n (Proposition 6.2(4), added by the editor). For the threshold rule driving the rehearsal the abort probability is at most L·K ln 2·2^a/n (Theorem 4.4), and for the minimum rule frozen after a rehearsal driven by the mixture it is bounded by Theorem 5.6. These are the whitelists the researcher accepts. Their soundness is then not a theorem but the assumption in the last column, and when the assumption fails the failure is silent. There is one exception: on the closed system that it has rehearsed, the threshold rule has at most L·K/(n·a) wrong answers per run in expectation (Theorem 4.4), with no assumption beyond a deterministic human in the class; off that system its soundness is again the assumption in the last column. The task-decomposition worry is visible in the table: if the calls that a decomposition produces share a property of fewer than a − c bits that no asked input has, every row above the last refuses all of them, and the last row answers each of them wrongly with probability at least 2^(−a−c).

## 8. Numerical checks

All scripts are in `proofs/code/`; each was run and its output saved next to it (`.out`). They use exact enumeration or linear programming where the text says "exact", and simulation with a fixed seed otherwise. Sections 8.1 to 8.4 are the prover's four scripts (copied from `research/prove-c/code/`); the check report re-ran them and found the outputs identical byte for byte. Section 8.5 lists the scripts of the two verifiers that this file cites (copied from `verification/code/`).

**8.1 `shift-abstain_s1.py` (Example 2.2, Lemma 1.4, Proposition 2.3).** Columns: beta_own = E β(M^(T)); R1 bound = L·K ln 2/n; beta_hum = E ∫ e_{M^(T)} dd_f; B; S1 claim = B·L·K ln 2/n; the ratio beta_hum/claim; and the bound of Proposition 2.3.

```
Example 2.2: exact values (candidate S1 claims beta_hum <= B*L*K*ln2/n)
    L    omega       n      K   beta_own   R1 bound   beta_hum       B   S1 claim  hum/claim  (2L-1)B*own
   10  0.10000    1000   3.32  9.000e-03  2.303e-02  4.737e-02  1.0048  2.314e-02       2.05    1.718e-01
  100  0.01000   10000   6.64  9.900e-03  4.605e-02  4.975e-01  1.0050  4.628e-02      10.75    1.980e+00
  100  0.50000   10000   1.00  5.000e-03  6.931e-03  9.901e-03  1.0001  6.932e-03       1.43    9.951e-01
 1000  0.00100 1000000   9.97  9.990e-04  6.908e-03  4.997e-01  1.0005  6.911e-03      72.31    1.998e+00
 1000  0.03125 1000000   5.00  9.688e-04  3.466e-03  3.007e-02  1.0000  3.466e-03       8.68    1.937e+00
   30  0.03333    3000   4.91  9.667e-03  3.401e-02  1.475e-01  1.0049  3.418e-02       4.31    5.732e-01

Monte Carlo check of the exact formulas (L=10, omega=0.1, n=200, 400000 repetitions)
  beta_own exact 0.04500  simulated 0.04529
  beta_hum exact 0.23684  simulated 0.23836

ratio beta_hum/beta_own = L/(1+omega*(L-1)); with omega = 1/L it is L/(2-1/L):
  L=   10: ratio     5.26;  K*ln2 = ln L = 2.30
  L=  100: ratio    50.25;  K*ln2 = ln L = 4.61
  L= 1000: ratio   500.25;  K*ln2 = ln L = 6.91

Lemma 1.4 and Proposition 2.3 on 20000 random adaptive scaffolds (L = 3), largest value of
  int TV(P,C_u) d d_(C_t) - [L beta(C_u) + (L-1) beta(C_t)] : -3.547e-01  (<= 0)
  max(beta^P(C) - L p, p - beta(C))                       : 4.163e-17  (<= 0)
  beta(C) - L p                                            : -6.343e-02  (<= 0)
```

The candidate's S1 is violated in every row (column hum/claim above 1), by a factor 72 in the fourth. The value 4.163e-17 is rounding error of an equality case.

**8.2 `shift-abstain_open.py` (Section 3 and Proposition 4.6).**

```
(A) online form: E sum_t KL over all steps, against K ln2 / q   (K = 3 bits)
   q=0.5   simulated   4.159 +- 0.027 (s.e.)   bound   4.159
   q=0.2   simulated  10.457 +- 0.070 (s.e.)   bound  10.397
   q=0.05  simulated  41.553 +- 0.283 (s.e.)   bound  41.589
    (the input rule shows the most informative input, so the bound is nearly attained)
    Example 3.2: silent mistakes, simulated against K(1-q)/(2q) and the bound (1-q)K ln2/q
   K=8 q=0.25  simulated   12.023   exact   12.000   bound   16.636
   K=8 q=0.05  simulated   75.907   exact   76.000   bound  105.358

(B) thresholds, labels only on questions: N * E[silent mistakes], exact minimum
    brute = all deterministic learners;  blocks = reduction to block sizes;
    bound = (N^2/(Q+1) - (Q+1))/4
     N   Q   brute  blocks    bound  N*M*(Q+1)/N^2
     6   0       9       9     8.75          0.250
     6   1       5       5     4.00          0.278
     6   2       3       3     2.25          0.250
     6   3       2       2     1.25          0.222
     6   4       1       1     0.55          0.139
     9   0      20      20    20.00          0.247
     9   1      12      12     9.62          0.296
     9   2       8       8     6.00          0.296
     9   3       5       5     4.06          0.247
     9   4       4       4     2.80          0.247
     9   5       3       3     1.88          0.222
    12   0      36      36    35.75          0.250
    12   1      22      22    17.50          0.306
    12   2      15      15    11.25          0.312
    12   3      11      11     8.00          0.306
    12   4       8       8     5.95          0.278
    12   5       6       6     4.50          0.250
    16   0      64      64    63.75          0.250
    16   1      40      40    31.50          0.312
    16   2      28      28    20.58          0.328
    16   3      21      21    15.00          0.328
    16   4      16      16    11.55          0.312
    16   5      13      13     9.17          0.305
    larger N through the block reduction: E[M]*(Q+1)/N
   N=  60  Q=0: 0.250  Q=1: 0.328  Q=2: 0.362  Q=5: 0.393  Q=11: 0.380  Q=29: 0.250
   N= 240  Q=0: 0.250  Q=1: 0.332  Q=2: 0.372  Q=5: 0.420  Q=11: 0.441  Q=29: 0.427
    (the lower bound of Theorem 3.3(a) gives at least 1/4 - ((Q+1)/N)^2/4)

    expected questions: hull of deterministic learners, against
    g(Qbar) = N/(9(Qbar+1)) - sqrt((Qbar+1)/(8N))  and  E[M](Qbar+1) >= N/15 for Qbar+1 <= N/4
   N= 12: 11 hull points; min(E[M] - g) = 0.098; min E[M](Qbar+1)/N over Qbar+1 <= N/4: 0.250  (bound 1/15 = 0.067)
   N= 24: 19 hull points; min(E[M] - g) = 0.067; min E[M](Qbar+1)/N over Qbar+1 <= N/4: 0.187  (bound 1/15 = 0.067)
   N= 48: 25 hull points; min(E[M] - g) = 0.048; min E[M](Qbar+1)/N over Qbar+1 <= N/4: 0.135  (bound 1/15 = 0.067)
    lemma A*S >= (4/9)N^3: smallest ratio A*S/N^3 over 20000 random compositions 0.5175; for b_j = J-j, J=400: 0.4461; 4/9 = 0.4444

(C) thresholds, every label shown, at most k wrong answers and m wrong-or-abstained rounds:
    largest number of thresholds that can be handled (exact game value) and C(m+1,<=k+1)-1
   k=0: m=0..7: 1 2 3 4 5 6 7 8
   k=1: m=0..7: 1 3 6 10 15 21 28 36
   k=2: m=0..7: 1 3 7 14 25 41 63 92
   k=3: m=0..7: 1 3 7 15 30 56 98 >=140
    (equal to the formula in every case below the cap)
```

Notes. In (A) the class has 8 samplers with uniform weights (K = 3 bits), and the sums are over 300/q steps, 20000 repetitions; the simulated value for q = 0.2 is above the bound by less than one standard error. In (B) "brute" is a dynamic programme over the information states (position, consistent range, questions left) of all deterministic learners; it agrees with the reduction to block sizes in every case, which checks Steps 1 and 2 of the proof of Theorem 3.3 and shows that the exact optimum is the minimum over block sizes of Σ_j Σ_{r<b_j} min(r, b_j − r + R_j), R_j the number of members beyond block j. The expected-question check uses, for 60 values of a price per question, the deterministic learner that minimises mistakes plus price times questions; since the bound of Theorem 3.3(b) is convex in Q̄ it suffices to check it at these points. In (C) the table is F(k, m) of Proposition 4.6 exactly.

**8.3 `shift-abstain_ab1.py` (Section 4).**

```
(1) Theorem 4.1: 71358 (class, human, order) cases checked; largest used/budget = 0.9926 (never above 1)

(2) Example 4.2: counts attained
   K=20 eta=0.25: wrong rounds 10 (bound 10.00);  abstentions 48 (bound 48.19; class with log2(1/w(f)) = 19.92)
   K=20 eta=0.1: wrong rounds 6 (bound 6.02);  abstentions 131 (bound 131.58; class with log2(1/w(f)) = 19.91)
   K=40 eta=0.01: wrong rounds 6 (bound 6.02);  abstentions 2758 (bound 2758.70; class with log2(1/w(f)) = 39.99)

(3) threshold rule with audits (Proposition 4.3(b)): silent errors, K = 8
   eta=0.5 q=0.25: simulated   24.036   bound (1-q)K/(q log2(1/eta)) =   24.000
   eta=0.5 q=0.05: simulated  152.468   bound (1-q)K/(q log2(1/eta)) =  152.000
   eta=0.3 q=0.25: simulated    0.000   bound (1-q)K/(q log2(1/eta)) =   13.817

(4) Theorem 4.4: rehearsal driven by the threshold rule (exact enumeration)
   class 0, eta=0.1: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 0.4998 <= L*K = 5.6135;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [1.0, 0.889, 0.761, 0.638]
   class 0, eta=0.3: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 1.1204 <= L*K = 5.6135;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [0.667, 0.593, 0.502, 0.416]
   class 1, eta=0.1: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 0.3776 <= L*K = 1.2085;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [1.0, 0.667, 0.469, 0.348]
   class 1, eta=0.3: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 0.0000 <= L*K = 1.2085;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [0.0, 0.0, 0.0, 0.0]
   class 2, eta=0.1: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 0.4937 <= L*K = 8.1184;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [1.0, 0.889, 0.749, 0.61]
   class 2, eta=0.3: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 3.4174 <= L*K = 8.1184;  E W_t = [0.667, 0.444, 0.296, 0.198], P(abort_t) = [0.333, 0.333, 0.3, 0.257]
   class 3, eta=0.1: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 0.5517 <= L*K = 5.5450;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [1.0, 1.0, 0.889, 0.741]
   class 3, eta=0.3: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] = 1.8677 <= L*K = 5.5450;  E W_t = [0.0, 0.0, 0.0, 0.0], P(abort_t) = [1.0, 1.0, 0.889, 0.741]

(5) Theorem 4.5: smallest silent-failure level (LP) against ((N0-n)p - L a)/(N0+L)
    N0  L    n     a       LP    bound
     4  2    0   0.0   0.4375   0.2917
     4  2    0   0.2   0.3375   0.2250
     4  2    0   0.5   0.1875   0.1250
     4  2    1   0.0   0.2578   0.2188
     4  2    1   0.2   0.1745   0.1521
     4  2    1   0.5   0.0596   0.0521
     4  2  2.5   0.0   0.1131   0.1094
     4  2  2.5   0.2   0.0465   0.0427
     4  2  2.5   0.5   0.0000   0.0000
     5  2    0   0.0   0.3600   0.2571
     5  2    0   0.2   0.2800   0.2000
     5  2    0   0.5   0.1600   0.1143
     5  2    1   0.0   0.2640   0.2057
     5  2    1   0.2   0.1840   0.1486
     5  2    1   0.5   0.0713   0.0629
     5  2  2.5   0.0   0.1425   0.1286
     5  2  2.5   0.2   0.0755   0.0714
     5  2  2.5   0.5   0.0000   0.0000
     4  3    0   0.0   0.3906   0.3304
     4  3    0   0.2   0.3075   0.2446
     4  3    0   0.5   0.1875   0.1161
     4  3    1   0.0   0.2863   0.2478
     4  3    1   0.2   0.2013   0.1621
     4  3    1   0.5   0.0850   0.0335
     4  3  2.5   0.0   0.1412   0.1239
     4  3  2.5   0.2   0.0612   0.0382
     4  3  2.5   0.5   0.0000   0.0000

(6) Proposition 4.7 (human with modal answer 1-eps0; K = 5 bits), expected counts on 400 asked rounds
   eps0=0.02 eta=0.2: non-modal answers  0.104 (bound  2.343);  abstentions   5.202 (bound  42.787)
   eps0=0.05 eta=0.2: non-modal answers  0.295 (bound  2.605);  abstentions   5.549 (bound  61.613)
   eps0=0.05 eta=0.1: non-modal answers  0.295 (bound  1.743);  abstentions   5.549 (bound 277.259)
    Proposition 4.8, identity A = N - 2 E_b S_b for a random rule, N = 6: 1.935090 = 1.935090
```

Notes. (1) is exhaustive over all orders of the inputs for 300 random classes (3 to 5 inputs, 2 to 8 functions, 2 or 3 answers, random weights of total 0.3 to 1) with every member as the human. (3) uses the class of Example 3.2(ii) and the limiting value η = 1/2 with ties answered 1, for which the bound of Proposition 4.3(b) is attained; for η = 0.3 the rule abstains at the posterior (1/2, 1/2) and makes no silent error. (4) enumerates all values of the top-level input and of the asked call slot over n = 4 rounds for a scaffold with three calls whose second input depends on the first answer; "class 2, eta = 0.3" is a case with wrong answers. (5) is a linear programme over all randomised protocols and deployed systems for the needle class (the protocol is described by the law of the set of cells it asks while all answers are 0, and by the law of the outcome in {0, 1, ⊥} given that set and the run). (6) is a simulation with 4000 repetitions; the bounds of Proposition 4.7 are far from tight in this example.

**8.4 `shift-abstain_ab2.py` (Section 5).**

```
(1) Theorem 5.1, 20000 random instances (5 inputs, adaptive scaffold of 2 calls, 2 to 5 samplers):
    max of [law of a completed run under the rule - under the human]: 0.00e+00 (<= 0)
    max |TV - P(abort)|: 2.22e-16;  max [P(abort) - int theta d d_P]: 0.00e+00 (<= 0)
    max violation of  max_nu TV <= theta <= sum_nu TV: 0.00e+00 (<= 0)

(2) plausible sets: absolute <= cumulative <= ratio and |cumulative| <= 1/alpha in 20000 random posteriors
    frequency with which the human leaves the set at some time (w(P) = 0.05):
    alpha=0.005: absolute 0.0819, cumulative 0.0819, ratio 0.0652;  bound alpha/w(P) = 0.100
    alpha=0.02: absolute 0.3453, cumulative 0.3427, ratio 0.2422;  bound alpha/w(P) = 0.400

(3) Theorem 5.6(b), first claim: frequency of {some member nu of the ratio set has sum_t h_t(nu) >= Gamma}
    n=40 alpha=0.3 eta=0.5: frequency 0.0065 (bound 0.5); Gamma = 3.316; largest observed sum/Gamma = 2.006
    n=40 alpha=0.05 eta=0.25: frequency 0.0005 (bound 0.25); Gamma = 4.905; largest observed sum/Gamma = 1.356
    n=150 alpha=0.3 eta=0.25: frequency 0.0000 (bound 0.25); Gamma = 4.010; largest observed sum/Gamma = 0.000

(4) Example 5.7(b), linear fill-ins of a fair coin (K = 1 bit):
    d=8 c0=2 n=6: asked inputs independent in 0.765 of 6000 runs (exact probability 0.773, lower bound 1 - 2^-c0 = 0.750);
        given independence: exactly 2^c0 consistent linear functions in 1.000 of the runs; mean abstention probability at a random input 0.868 (exact value 1 - 2^-c0/2 = 0.875), smallest 0.5
    d=10 c0=3 n=7: asked inputs independent in 0.878 of 6000 runs (exact probability 0.881, lower bound 1 - 2^-c0 = 0.875);
        given independence: exactly 2^c0 consistent linear functions in 1.000 of the runs; mean abstention probability at a random input 0.939 (exact value 1 - 2^-c0/2 = 0.938), smallest 0.5
```

Notes. (1) is exact (all runs enumerated). In (2) the class has five coins and the human has weight 0.05; the observed frequencies are within a factor 1.6 of Ville's bound. In (3) the visit measures of the rehearsal mixtures are computed exactly and the rehearsal is simulated 4000 times with a class of 10 samplers; the event has much smaller frequency than the bound η allows. (4) checks Example 5.7(b) by listing all 2^d linear functions: when the asked inputs are linearly independent there are exactly 2^(c₀) consistent ones, and the rule abstains with probability 1 at an input outside their span and 1/2 inside it.

**8.5 Scripts of the two verifiers that this file cites (added by the editor).** Each was written independently of the prover's scripts.

* `shift-abstain_check_s1.py` (check report): Example 2.2 by the exact formulas and by a simulation of Protocol R (L = 20, ω = 0.05, n = 200, 20000 repetitions: simulated (0.0949, 0.9730) against exact (0.0950, 0.9744)); the two quoted cases give 0.4975 against the claimed bound 0.04628, and 0.4997 against 0.00691.
* `shift-abstain_attack_s1.py` (attack report): Example 2.2 by brute force over all rehearsal histories in rational arithmetic for (L, n, ω) = (2, 3, 1/3), (3, 3, 1/4), (4, 2, 1/2): the closed forms are exact (for example E β(M^(T)) = 104/243 and E ∫ e dd_f = 52/81 in the first case); at L = 100 and L = 1000 the candidate's S1 fails by the factors 10.7 and 72.3.
* `shift-abstain_check_thr.py` (check report): exact minimum of Σ_s Sil(s) over deterministic learners for the thresholds, 2 ≤ N ≤ 40 and Q ≤ 7: no violation of Theorem 3.3(a), of the form 3N/16, or of the comparison in (c); for N = 240 the values 0.25, 0.3319, 0.4406 for Q = 0, 1, 11.
* `shift-abstain_attack_thresholds.py` (attack report): (A) the same minimum by a separate dynamic programme, N ≤ 48 and Q ≤ 5, no violation; the learner of Theorem 3.3(c) is not optimal (N = 48, Q = 3: 264 against the optimum 216). (B) Proposition 4.6: the game value equals C(m + 1, ≤ k + 1) − 1 for all k ≤ 3 and m ≤ 7, including k = 3, m = 7 (162).
* `shift-abstain_attack_stop.py` (attack report): the illustration after Corollary 3.6 (a fixed threshold class; no silent error and at most N − 1 questions over 10⁵ steps).
* `shift-abstain_attack_closed.py` (attack report): the numbers of Example 4.5a.

The editor re-ran all ten scripts of this section; the outputs agree with the saved ones (Section 12.4).

**Not checked numerically:** Theorem 5.3 and Section 6 (separation complexity is not computable; their proofs are a few lines each), Theorem 5.6 beyond its first claim, Corollary 3.5 (it follows from Theorem 3.3(b) by convexity).

## 9. What remains open in this part

1. **A whitelist width for the threshold rule.** Theorem 5.3(d) gives the region where Thr_η must abstain. I have no outer region: no proof that Thr_η answers at every x with sep(x; A) above some bound in K, K_D and log(1/η). The obstacle is that the posterior mass of the hypotheses that are wrong at x is a sum over many hypotheses, and no single one of them need be simple (the class of function semimeasures has no coding theorem; `understand/repo.md`, Section 1, reports that the sum and the largest term are not within a constant).
2. **The constant 2 in Ab3.** Whether the novelty rule with the simplest consistent hypothesis can be wrong at an input x with sep(x; A) close to 2K, in the class of all programs. Proposition 6.1(2) gives sep(x; A) ≤ K + K_D + c₂ and I have no example above K + O(log K).
3. **Constants in Section 3.** The exact minimum in Theorem 3.3(a) is computed in Section 8 and lies between N/(4(Q + 1)) and N/(2(Q + 1)); a closed form is missing. For expected questions the continuous optimum of Lemma 3.4 suggests N/9 in place of N/15. In Corollary 3.5 the upper and lower bounds on the product of silent errors and questions differ by a factor of at most 30·ln 2·log(h/u + 1), for learners that ask at least u questions on average (see the remark after the corollary).
4. **The factor between L/2 and 2L − 1 in Proposition 2.3**, and whether the square-root rate for a stochastic human can be kept with a factor of order L only.
5. **A second count for samplers.** Proposition 4.8 excludes a bound on abstentions in K and η alone. What replaces it? The literature has bounds that are linear in the number of hypotheses (the k-meteorologists bound) or in Ent(w)/w(P) (Lattimore, Hutter and Sunehag 2013, as reported in `understand/abstention-shift.md`); a bound in terms of the number of answers that the class can "fill in" would fit Example 5.7(b).
6. **Rehearsal driven by the minimum rule.** Theorem 5.6 freezes the set after a rehearsal driven by the mixture and pays L(L − 1)·√(K ln 2/(2n)) for the difference between the visit measures. If the minimum rule itself drives the rehearsal, its runs are initial parts of human runs and this term should disappear; but the argument of Theorem 4.4 does not apply, because an asked abstention need not move the posterior by a fixed amount when the human is stochastic. The bound of Cohen, Hutter and Nanda on Σ θ_q³ is the only tool I know.
7. **Theorem 4.5 with complexity.** The bound (1 − a)²·L/(4σ) is for the needle class; a version for the block class of LB Theorem 3.1, with the factor K/log(L/σ), is not written out.
8. **Computable versions.** sep, the plausible sets and the novelty rule are not computable. For time-bounded tests Propositions 6.1(1) and 6.2(1), (3) hold with the same proofs; the soundness statements were not redone.
9. **A batch guarantee for samplers under arbitrary shift** (errors on the answered part of a given batch of unlabelled deployment inputs, rejection on the training law), sketched in `understand/abstention-shift.md`, Section 8.7, is not treated here.
10. **(Editor.) The gap in Corollary 3.6.** For a deterministic human the number of questions after which the human can leave an open system is at most 2^k − 1 (enumeration; no silent error; a bound k ≥ K known) and, on the thresholds, at least about 2^K·3/(16s) if s silent mistakes and unanswered abstentions are tolerated. The two bounds differ in what they tolerate (s = 0 against s > 0) and by the factor 2^(k−K). A rule that turns a tolerance s > 0 into about 2^K/s questions for every class is not given here; for the thresholds Theorem 3.3(c) is one. For a human who is not deterministic, Proposition 4.8 excludes a pair of counts in K alone, and nothing here says when the asking can stop.
11. **(Editor.) When abstention is cheap in a closed system.** Theorem 4.5 and Example 4.5a are the two extremes. A statement that gives the number of questions saved in terms of the task law (how much of it is rare, and how recognisable the rare part is) is missing.
12. **(Editor.) Proposition 6.2(4)** was added after the reports and has not been checked by a verifier.

## 10. Remarks on other files

Found while working on this part. I did not check the other parts systematically.

1. **`candidate-theory.md`, S1** is false as stated (with the average rehearsal visit measure d̄) by a factor of order L/ln L (Example 2.2). It is true with the factor B for a change of the top-level law (Proposition 2.1), which is how LB Proposition 4.4 already reads it, and with the factor (2L − 1)·B for visit measures (Proposition 2.3). The same caution applies wherever the per-call bound of R1 is transferred to "the distribution of calls of the human system": the errors of M^(T) along the human system's runs are bounded by L·E β(M^(T)), not by E β(M^(T)) (Lemma 1.4(3)).
2. **`candidate-theory.md`, S3:** "a property of tasks with rehearsal probability β costs 1/β" is exact for a protocol that rehearses on D₀ and for a guarantee on N unknown properties at once; a single property known in advance costs nothing (Proposition 2.4(d)).
3. **`candidate-theory.md`, Ab1:** correct, including the per-run statement, provided the threshold rule drives the rehearsal. The sentence "reducing silent errors by a factor j costs a factor about 2^j in questions, in line with N4" should be read with j = log(1/η): K/j wrong rounds against K ln 2·2^j abstention rounds. Three things should be added. The first count is a count over asked rounds; with answers seen only on questions it limits nothing unless η < w(f) or there are audits (Proposition 4.3). On the needle class with cells of equal mass abstention saves at most the factor (1 − a)² in questions (Theorem 4.5), while in other closed systems it saves an unbounded factor (Example 4.5a). And the candidate's Section 11 lists "stochastic versions of … Ab1" as open: Propositions 4.7 and 4.8 answer this (a version exists for a human with a mode, and none exists for all samplers).
4. **`candidate-theory.md`, Ab2:** the dominance statement and the Ville step are correct. "Every patch of the leading hypotheses of complexity up to K + log(1/δ) is in C" needs the constant: patches by tests of complexity up to K + log(1/δ) − c₁. Two things are missing there. The ratio set {posterior weight ≥ α·max} can have 1/(α·w_max) members; for a class with many equally good explanations it is the whole version space (Example 5.7(a)), and the cumulative set of Cohen, Hutter and Nanda avoids this. And for samplers with weights 2^(−length) the set contains fill-ins of the human's coins, so that the frozen rule can be useless on the closed system even when K = 1 (Example 5.7(b)); a summability condition on the weights is needed (Theorem 5.6(b)).
5. **`candidate-theory.md`, Ab3 and N4:** correct; the constant in Ab3 is the constant c₂ of (P2), and N4 should say "ask or abstain".
6. **`candidate-theory.md`, Section 10, item 6 (the rock test):** "no abstention is needed inside the closed system" is right. Theorem 4.5 adds that, in the worst case over scaffolds, abstention does not make the closed system cheaper either; where the unlearned inputs are rare and recognisable it does (Example 4.5a).
7. **`understand/ask-for-help.md`, Section 3.2:** the set {ν : w_D(ν) ≥ α} can be empty, and the minimum over it is then undefined; the claims there are for the event that it contains P. Claims 1 to 4 are correct (Theorem 5.1, Proposition 5.2). Claim 5 is correct; Theorem 5.6(b) is its form for rehearsal. **Section 3.4:** the derivation is correct; the constant 1/32 can be replaced by 3/16, the optimum is within a factor 2 of this, and the bound extends to expected numbers of questions (Theorem 3.3). (Editor.) The sentence that the digest draws from it, "finitely many queries, then a bounded total number of silent errors over an unbounded deployment on arbitrary inputs is impossible already for thresholds", is false for a fixed class: the class of the derivation has as many members as the sequence has inputs, and the digest's own Section 3.1 (weighted enumeration) gives finitely many queries and no error at all. The prover's Corollary 3.6 had followed that sentence; see the restated Corollary 3.6. **Section 2.1:** the statements of the five theorems of Cohen, Hutter and Nanda agree with the source.
8. **`understand/notes.md`, Observation B:** both claims are correct. Its last paragraph ("without answers it abstains on every input of every new kind for ever") is Proposition 6.2(1); with the sound choice of s this is every input of complexity below 2K.
9. **`proofs/lower-bounds.md`, Lemma 1.10:** in the proof, Σ_i π_i is bounded by the expected number of questions; it is in fact bounded by the expected number of questions that lie in the patches. This sharper form is what Proposition 2.4(c) uses. No error.
10. **`note.md`, Section 4.1:** the sentence "the mixture gives a wrong answer at x probability at least 2^(−sep(x;A)−c)" is Proposition 7.5(6) and holds for the human itself (not only for one of two candidates), in a class with (P1) and two fixed answers.
11. **(Editor.) `research/sections/intro.md`, answer 4.** Two sentences there rest on readings that the reports refuted. "In an open system the human cannot leave: on a class of N thresholds, silent errors plus abstentions, multiplied by the number of questions, is at least 3N/16 (N7)" should say that a deterministic human can leave, but in the worst case only after a number of questions of the order of 2^K divided by the tolerated number of silent errors, and never later than after 2^b − 1 for a known bound b ≥ K (Corollary 3.6). "Every rule whose soundness is a theorem refuses each new input simpler than about K bits" holds for the threshold rule, the ratio rule and the novelty rule; for enumeration the forced radius is b − K_D and shrinks as the data single out the human (Proposition 7.5(2); attack report, finding m1).
12. **(Editor.) `research/outline.md`, Addendum 3:** the label N7 is described there as "in an open system asking cannot stop"; the statement that is true is "cannot stop early" (Corollary 3.6). The outline's Addendum for `rehearsal-core` asks for the online form in two sentences in Section 3; in Section 6 it is stated as Proposition S5, a label introduced by this editor.

## 11. Literature used, and how

No result from the literature is used as a black box in a proof, except Ville's inequality, Pinsker's inequality, the inequality TV ≤ √(2H²), Kraft's inequality and the bound C(t, ≤ j) ≤ (et/j)^j. "[source]" means that I read the statement in the source in this session; "[memory]" that I quote it from memory; "[digest]" that I take it from one of the digests in `research/understand/` without opening the work.

In this section "I" is the prover. Entries marked "(editor)" were added by the editor, who opened none of the works: they are quoted from the reference list of `research/sections/related-work.md` (the lead's literature check), which says for each how it was checked.

* **M. K. Cohen, M. Hutter and N. Nanda,** "Fully General Online Imitation Learning", *Journal of Machine Learning Research* 23(334):1–30, 2022 (JMLR paper 21-0618); arXiv:2102.08686. [source: TeX source of arXiv version 2: the definitions of Sections 3 and 4, Theorems 1 to 5 with their statements as in Section 5.5, the definition of fairness, the proof of Theorem 5, and the first lines of the proof of Theorem 2. Bibliographic data confirmed by a web search.] Used for Section 5.5 and for the attribution of the cumulative top set, of the one-step domination and of the Ville step. (Editor: both verifiers opened the arXiv source. The header of the paper gives volume 23, year 2022, pages 1–30 and the paper number 21-0618. The check report could not confirm the article number 334; a web search by the editor in this session returns "volume 23, issue 334, pages 1–30, 2022" for the page jmlr.org/papers/v23/21-0618.html, in agreement with the search of the attack report. The journal's page itself was not opened.)
* **S. Ross, G. J. Gordon and J. A. Bagnell,** "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning", *Proceedings of the 14th International Conference on Artificial Intelligence and Statistics (AISTATS 2011)*, PMLR 15:627–635; arXiv:1011.0686. (editor) [related-work: Theorems 2.2 and 4.1 checked there in the arXiv text.] Theorem 4.1: a learner without regret, fed with the losses at the states that its own policies visit, yields a policy whose loss on its own states is at most the best loss in hindsight plus the average regret. Lemma 1.2, Corollary 1.3 and Theorem 2.5(i) are this reduction.
* **Y. Li and C. Zhang,** "Interactive and Hybrid Imitation Learning: Provably Beating Behavior Cloning", arXiv:2412.07057 (NeurIPS 2025 according to the arXiv record). (editor) [related-work and `research/literature-checks.md`: Algorithm 1 ("Stagger") and Theorem 3 read there in the arXiv text.] Exponential weights under log loss, one state of each rollout put to the expert, a uniformly chosen iterate deployed; for a finite class and a deterministic expert. Protocol R[mixture] is this algorithm with a prior on a countable class.
* **S. Ross and J. A. Bagnell,** "Efficient Reductions for Imitation Learning", *Proceedings of the 13th International Conference on Artificial Intelligence and Statistics (AISTATS 2010)*, PMLR 9:661–668. (editor) [related-work: Theorem 2.1 read in the source by the author of the digest `imitation-theory.md`.] An error rate ε per step on the expert's states can cost T²ε over T steps. The factor L of Lemma 1.4(3), Example 2.2 and Proposition 2.3 is this compounding of errors.
* **C. Zhang and K. Chaudhuri,** "The Extended Littlestone's Dimension for Learning with Mistakes and Abstentions", *Proceedings of the 29th Conference on Learning Theory (COLT 2016)*, PMLR 49:1584–1616; arXiv:1604.06162. [source: TeX source of the arXiv version: the setting ("the adversary then reveals an outcome"), the definition of a (k, m)-SZB bound, and the theorem "for a set of n threshold classifiers, ELdim(H, k) = max{t : C(t, ≤ k + 1) ≤ n}". Volume and pages from the digest.] Their theorem is the exact form of Proposition 4.6: a (k, m) bound exists if and only if m ≥ ELdim(H, k), which is N ≤ C(m + 1, ≤ k + 1) − 1. The proof of the lower bound given here is mine and self-contained; the upper bound (tightness) is theirs and is confirmed by the computation of Section 8.
* **A. Sayedi, M. Zadimoghaddam and A. Blum,** "Trading off Mistakes and Don't-Know Predictions", *Advances in Neural Information Processing Systems 23*, 2010. [digest] The model of Proposition 4.6 and the bound (k + 1)·|H|^(1/(k+1)).
* **L. Li, M. L. Littman and T. J. Walsh,** "Knows What It Knows: A Framework for Self-Aware Learning", *ICML 2008*, pp. 568–575. [digest] The enumeration rule of Proposition 6.1(3) with |H| − 1 abstentions.
* **R. El-Yaniv and Y. Wiener,** "On the Foundations of Noise-free Selective Classification", *Journal of Machine Learning Research* 11:1605–1641, 2010. [digest] Optimality of the rule that abstains on the disagreement region (Proposition 5.4 is the same observation for a plausible set).
* **N. Cesa-Bianchi, G. Lugosi and G. Stoltz,** "Minimizing Regret with Label Efficient Prediction", *IEEE Transactions on Information Theory* 51(6):2152–2162, 2005. [digest] Asking at random; Theorem 3.1 is of this type and is proved here from the regret bound.
* **J. Yu and M. Blanchard,** "Distribution-Free Sequential Prediction with Abstentions", arXiv:2602.17918. [digest] Quoted after Corollary 3.6 for comparison only.
* **T. Lattimore, M. Hutter and P. Sunehag,** "Concentration and Confidence for Discrete Bayesian Sequence Predictors", arXiv:1307.0127 (*ALT 2013* according to the digest, which marks the venue as from memory). [digest] Mentioned in Section 9, item 5, only. The k-meteorologists bound mentioned there is from C. Diuk, L. Li and B. R. Leffler, *ICML 2009*, pp. 249–256 [digest].
* **Ville's inequality:** for a nonnegative supermartingale (Z_n) with Z_0 = c and v > 0, Pr[sup_n Z_n ≥ v] ≤ c/v. [memory; J. Ville, *Étude critique de la notion de collectif*, 1939; for example R. Durrett, *Probability: Theory and Examples*, the maximal inequality for nonnegative supermartingales.] Used in Proposition 5.2(b).
* **Pinsker's inequality** TV ≤ √(KL/2), and **TV ≤ √(H²(2 − H²)) ≤ √(2H²)** for H² = 1 − Σ√(pq). [memory; for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Section 2.4; both are also Lemma 1.1 of `proofs/hellinger-runs.md`.]
* **Kraft's inequality** for prefix-free sets of programs, the bound K(x) ≤ |x| + 2 log|x| + c, and **C(t, ≤ j) ≤ (et/j)^j** for t ≥ j ≥ 1. [memory; standard; M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*; for the binomial bound any text on VC theory.]
* **The regret bound for Bayes mixtures** (R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Transactions on Information Theory* 24:422–432, 1978, for sequences). [memory] Re-proved for adaptively chosen questions as Lemma 1.1.
* **From the repository's digests** [digest]: `understand/repo.md`, items C3(2), X2, X3, X4 (N4, the never-wrong threshold rule, audits), D1 and D4 (the floor 2^(−sep−c)), G4 (the grue theorem); `understand/notes.md`, Observations A to D; `understand/ask-for-help.md`, Sections 2.1, 2.5, 3.1 to 3.5; `understand/abstention-shift.md`, Sections 3, 7.2, 7.5 and 9.7. The statements taken from them are re-proved here, except the grue theorem (cited in the remark after Theorem 5.3) and the reports on the literature.


## 12. Checking

Two reports examined the prover's file `research/prove-c/shift-abstain.md`: the check report `verification/shift-abstain-check.md` (a referee's reading, one entry per statement, with 14 numbered corrections) and the attack report `verification/shift-abstain-attack.md` (an adversarial reading: no fatal finding, 2 major, 9 minor, 5 on wording). Both reports are complete. The editor re-derived every finding before deciding it. In the tables, "C" numbers are the corrections of the check report (its Section 2), and "M", "m", "w" numbers are the findings of the attack report.

### 12.1 Findings of the check report

| no. | finding | decision | what was done |
|---|---|---|---|
| C1 | "The asking cannot stop" (title of Section 3, Corollary 3.6, "In brief" (2), Theorem 7.3 (L3) and "In words") is false for a fixed class and a deterministic human: by Proposition 4.3(a) the threshold rule with η < w(f)/W makes no silent error and asks finitely many questions on every sequence; the class of Corollary 3.6 grows with the horizon | accepted | Verified: Propositions 4.3(a) and 6.1(3) of this file are the counterexample. Corollary 3.6 restated in three parts (lower bound for a class that contains N thresholds and a horizon h ≤ N − 1, with a three-line proof by the editor; upper bound; reading). Changed with it: the title of Section 3, the first paragraph of Section 3.2, "In brief" (2), Theorem 7.3 (U1), (L3) and "In words", Section 10 item 7 |
| C2 | Corollary 7.2(2) is wrong as stated (a learner that has seen the answer 1 knows the human) | rejected as an error; wording changed | The item meant "the input a is shown last" and is correct in that reading; the attack report read it so and confirmed it. The check report read "with a last" as "with a last input". The item is now stated for every order of the inputs ("at every step before which a has not been asked"), with the proof that the check report supplied for the case x_t = a |
| C3 | "In a closed system abstention saves at most the factor (1 − a)²" is proved for the needle class with the OR scaffold only | accepted | Verified with the counterexample of the attack report (Example 4.5a). Changed: title of Section 4.4, name and reading of Theorem 4.5, "In brief" (3), Theorem 7.3 (L4) and "In words", Section 10 items 3 and 6 |
| C4 | Theorem 5.3(b): the proof starts from θ_𝒞(x) > 0 and does not give "outside the radius all members answer f(x)" when f ∉ 𝒞 | accepted | Statement and proof of (b) rewritten: the argument starts from any member that differs from f at x |
| C5 | "The expected number of unfaithful calls" is used and not defined | accepted | Definition added at the head of Section 1.4; reference added in the proof of Proposition 2.1 |
| C6 | Proposition 2.4(d) lacks the hypothesis δ ≤ 1/6 of LB Theorem 4.3 | accepted | Added in 2.4(d) and in the note after Theorem 2.5 |
| C7 | Example 3.2(i): equality in the limit needs W = 1 | accepted | Added |
| C8 | Example 4.2 needs K ≥ log(1/η) in (a) and K ≥ log(1/(1 − η′)) in (b) | accepted | Added |
| C9 | Proposition 5.2(b): "w(P) falls below α" should be the posterior weight; (d) needs the members to be samplers | accepted | Both changed |
| C10 | Theorem 5.6(c): Example 5.7(b) has S_½ finite; it shows that the term ln S_½ is needed, not that "S_½ < ∞ cannot be dropped" | accepted | (c) and the end of Example 5.7(b) reworded |
| C11 | Proposition 4.7, "What it does not say": the bound needs noise exactly ε₀ at every call and runs of L calls; the last sentence is imprecise | accepted | Reworded |
| C12 | Theorem 7.3 (U1) should say η < w(f)/W; "Which are rocks" should say that α ≤ 2^(−K) suffices for functions | first part kept, second accepted | η < w(f) is correct as written, because W ≤ 1; the general condition is now named beside it. "Which are rocks" changed |
| C13 | Corollary 3.5: its condition needs N₁ ≥ 5; for fixed N₁ no logarithm is lost | accepted | Remark after the corollary rewritten (together with m5) |
| C14 | The article number 334 of Cohen, Hutter and Nanda is not on the paper's first page | accepted in part | The number is kept. A web search by the editor returns volume 23, issue 334, pages 1–30 for the paper 21-0618, as the attack report found; the paper number is now given too (Sections 5.5 and 11) |
| entry on Proposition 4.3 | In variant B the proof gives the bound with the factor 1 − q | accepted | Statement sharpened to ((1 − q)/q)·K/log(1/(1 − η)); proof completed |
| entry on Proposition 2.3 | The lower bound L/(1 + ω(L − 1)) holds in the limit n → ∞, where B → 1 | accepted | Said so |
| entry on Proposition 5.4 | 𝒞 must be nonempty; consistency with D is not used | accepted | Changed |
| entry on Proposition 6.2 | Item 3 is about the rehearsal runs of the driver | accepted | See m2 |
| entry on Sections 5.5 and 11 | Zhang and Chaudhuri; Sayedi, Zadimoghaddam and Blum; Li, Littman and Walsh; El-Yaniv and Wiener; Cesa-Bianchi, Lugosi and Stoltz; Yu and Blanchard; Lattimore, Hutter and Sunehag were not checked against the sources by the check report | noted | The attack report checked Zhang and Chaudhuri in the source. The others remain marked "[digest]" in Section 11; no proof depends on them |
| entry on Theorem 5.3 | The citation of the grue theorem (`understand/repo.md`, item G4) was not checked | noted | It stays marked "not re-derived here"; the note does not use it in this part |

### 12.2 Findings of the attack report

| no. | finding | decision | what was done |
|---|---|---|---|
| M1 | "The asking cannot stop" is false as stated; Theorem 3.3 is about a class whose size grows with the horizon; the true statement is "not before about min(h, 2^K)/s questions" | accepted | As C1. The script `shift-abstain_attack_stop.py` was re-run (identical output) and is quoted after Corollary 3.6. The label N7 of the outline ("in an open system asking cannot stop") is kept for Theorem 3.3 with Corollary 3.6, and its wording in the note is "the asking cannot stop before a number of questions of the order of 2^K divided by the tolerated number of silent errors" |
| M2 | "In a closed system abstention saves at most the factor (1 − a)²" is false for closed systems in general: with cells of unequal mass abstention saves a factor of about a/(8σ) | accepted | Re-derived and added as Example 4.5a, with a proof of N₁/2 ≥ a/(8σ) − 1/2; the script was re-run (identical output). Other changes as C3 |
| m1 | "Which are rocks" overstates for enumeration: its forced radius k − K_D − c shrinks as the data make the human the best explanation | accepted | Paragraph "Which are rocks" rewritten; "In brief" (6) changed |
| m2 | Proposition 6.2(3) bounds the calls of the rehearsal driver's runs that fall in the frozen region, not the abort probability of the deployed frozen rule | accepted | Said so in 6.2(3), in the Reading of Section 6 and in "Which are whitelists". Item 4 was added to Proposition 6.2 by the editor: when Nov_s itself drives the rehearsal, the deployed run is aborted with probability at most L·(2^s − 1)/n (and has at most L·(2^K − 1)/n wrong answers in expectation). Item 4 has not been checked by a verifier |
| m3 | The proposed labels (N6 to N9, Ab4 to Ab6, S4, S5) clash with `research/outline.md`, Addendum 3 | accepted | The column "label in the note" of the table in Section 0.1 now follows the outline: N7 is Theorem 3.3 (with Corollary 3.6), Ab4 is Theorem 7.3. S4 (Theorem 2.5) and S5 (Theorem 3.1) are new labels, announced in the editor's summary. All other statements are unlabelled |
| m4 | Missing attributions: Ross, Gordon and Bagnell and Li and Zhang for Lemma 1.2, Corollary 1.3 and Theorem 2.5(i); Ross and Bagnell for the factor L; label-efficient prediction for Theorem 3.1; the KWIK bounds for Propositions 6.1(3), 7.1 and Corollary 7.2 | accepted | Notes added after Corollary 1.3, Lemma 1.4, Theorem 2.5, Theorem 3.1, Proposition 6.1 and Corollary 7.2; three references added in Section 11, quoted from the lead's literature check |
| m5 | Corollary 3.5 compares E[Sil + Abs]·(Q̄ + u) with E[Sil]·Q̄; the two match only for Q̄ ≥ u and for horizons below the size of the class | accepted | Remark after the corollary rewritten; row of the table changed |
| m6 | Proposition 7.5(4) says α ≤ 2^(−K), the paragraph "Which are rocks" α ≤ δ·2^(−K) | accepted | One condition for functions, the other named as the condition for samplers |
| m7 | "The same kernel" (Section 5.5) holds for the cumulative set only | accepted | Sentence changed |
| m8 | Theorem 7.3 (U2), "no further question is needed for any number of later runs": the bounds are for a round drawn afresh for each run | accepted | Qualifier added, with the price 1/δ′ of one rule kept for good |
| m9 | Proposition 5.2(d) lacks the caveat that it is an average over humans drawn from the prior | accepted | Added |
| w1 | Example 3.2(i) needs W = 1 | accepted | As C7 |
| w2 | Corollary 3.6, "however simple the class" | accepted | The sentence is gone (C1) |
| w3 | Reading of Section 5.4 drops the term ln S_½ | accepted | Changed to 4^K·L²·(K + ln S_½ + ln(1/δ))/δ² |
| w4 | Theorem 3.3(c): "(a) is optimal up to a factor 2" should be "within a factor 2 of the optimum"; the learner of (c) is not optimal | accepted | Reworded, with the numbers 264 and 216 for N = 48, Q = 3 |
| w5 | The citation of Cohen, Hutter and Nanda is confirmed | no change | See C14 |
| seven tests, item 2 | "K for a person exceeds the complexity of every input that will be written down" is relative to the reference machine | accepted | Marked as an expectation relative to the machine in the Reading of Section 6 and in "Which are rocks" |
| seven tests, item 2 | sep and the plausible sets are not computable even with unlimited ordinary computation (they need an oracle) | noted | Section 9, item 8 says "not computable"; the note says it where the rules are stated |
| "What is not new" | Theorem 5.1(2)–(4) and the first claim of Theorem 5.6(b) extend derivations of the digest `ask-for-help.md`; Theorem 3.3(a) is the digest's argument with a better constant; Proposition 4.3(a) is item X2 of `understand/repo.md`; Proposition 6.1(1), (2) is Observation B | noted | The statements already say so in their headers; the note attributes them in the same way |

### 12.3 Who checked the proofs of the statements that the note uses

"Check" means: the check report examined the proof step by step and its entry says CORRECT (with the corrections listed above). "Attack" means: the attack report re-derived the proof and its verdict is HOLDS or HOLDS WITH CHANGE (with the changes listed above). "Editor" says what the editor re-derived in addition.

| statement of this file | label in the note | check report | attack report | editor |
|---|---|---|---|---|
| Lemma 1.1, Lemma 1.2, Corollary 1.3, Lemma 1.4 | tools (not stated in Sections 6 and 7) | yes | yes | Lemma 1.2 re-derived |
| Proposition 2.1 (factor B for the top-level law) | S1 | yes | yes; part (c)3 rests on Theorem R2, which neither report of this part re-checked (it is checked in the reports on `hellinger-runs`) | constant of (c)3 brought into line with the corrected Theorem R2 |
| Example 2.2 (visit measures: failure by the factor L/(2 ln L)) | S1 | yes, with an independent script (exact formulas and simulation) | yes, with exact brute force in rational arithmetic | scripts re-run |
| Proposition 2.3 (factor (2L − 1)·B) | S1 | yes | yes | — |
| Proposition 2.4 (S3) | S3 | yes; the use of LB Lemma 1.10 in (c) was compared with that lemma | yes | (c) re-read against LB Lemma 1.10 and Corollary 2.2 |
| Theorem 2.5 (three kinds of shift) | S4 | yes; (ii), (iii) compared with the cited statements of LB | yes | — |
| Theorem 3.1 (asking with probability q) | S5 | yes | yes | (a), (b) re-derived |
| Theorem 3.3 with Lemma 3.4 (thresholds) | N7 | yes, with an independent exact computation for N ≤ 40 | yes, with an independent exact computation for N ≤ 48 | Steps 0 to 4 of part (a) re-derived |
| Corollary 3.5 | cited by number | yes | yes | the remark after it was rewritten by the editor (two lines of arithmetic) |
| Corollary 3.6 as restated | N7 | part (b) and the falsity of the old version: yes; part (a) in the form with h: the report gives the form with N = h + 1 | part (b): yes; part (a): the report states the inequality with 3h/16 | the reduction to a subclass in (a) is the editor's (three lines); **the restated corollary as a whole was not seen by a verifier** |
| Theorem 4.1 (Ab1, counts) | Ab1 | yes | yes | re-derived |
| Example 4.2, Proposition 4.3 | cited by number | yes | yes | variant B of 4.3(b) re-derived |
| Theorem 4.4 (Ab1 under rehearsal) | Ab1 | yes | yes | re-derived |
| Theorem 4.5 (needle class with abstention) | cited by number | yes | yes | — |
| Example 4.5a | cited by number | the report confirms the finding in words (no computation) | found and computed there (script) | parts 1 to 3 proved by the editor; **the written proof was not seen by a verifier** |
| Proposition 4.6 (exponential rate) | cited by number | yes | yes, with an independent computation of the game value | — |
| Proposition 4.7 (human with a mode), Proposition 4.8 (no pair of counts for samplers) | cited by number | yes | yes | identity of 4.8 re-derived |
| Theorem 5.1 (dominance) | Ab2 | yes | yes | (1) to (4) re-derived |
| Proposition 5.2 (plausible sets, Ville) | Ab2 | yes | yes | (a), (b) re-derived |
| Theorem 5.3 (coverage) | Ab2 | yes; gap in (b) found | yes | (a), (b) as corrected and (d) re-derived |
| Proposition 5.4, Corollary 5.5 | cited by number | yes | yes | — |
| Theorem 5.6 (abort probability after rehearsal) | Ab2 | yes | yes | part (a) re-derived |
| Example 5.7 | cited by number | yes | yes | (a) re-derived |
| Section 5.5 (statements of Cohen, Hutter and Nanda) | comparison | Theorems 1 and 2 and the hypotheses of 3 to 5 confirmed in the source | all five statements compared with the TeX source | not opened by the editor |
| Proposition 6.1 (Ab3) | Ab3 | yes | yes | (1), (2) re-derived |
| Proposition 6.2, items 1 to 3 | Ab3 | yes | yes | — |
| Proposition 6.2, item 4 | not used in the note | no | no | added and proved by the editor; **not independently checked**, and for that reason left out of the section text |
| Proposition 7.1, Corollary 7.2 (N4) | N4 | yes; item 2 read differently (C2) | yes | item 2 in its general form re-derived |
| Theorem 7.3 (trade-off) | Ab4 | each item compared with the statement it cites | the listed bounds hold | "In words" rewritten by the editor from the two reports |
| Definition 7.4, Proposition 7.5 (rocks and whitelists) | cited by number | yes | yes | item 0 re-derived; the paragraphs "Which are rocks" and "Which are whitelists" were rewritten by the editor |

Results that this file takes from other parts and that neither report of this part re-checked: Theorem R2 (HR Theorem 3.1(b)), used only in Proposition 2.1(c)3; and the statements of LB (N1, N2, N3, S2), whose citations the check report compared with LB and whose proofs are checked in the reports on `lower-bounds`. Taken from the literature without a check of the source by anyone in this part: the theorem of El-Yaniv and Wiener (attribution of Proposition 5.4), the grue theorem (remark after Theorem 5.3), and the works marked "[digest]" in Section 11.

### 12.4 What the editor ran

All ten scripts named in Section 8 were run again by the editor in `proofs/code/`: the prover's `shift-abstain_s1.py`, `shift-abstain_open.py`, `shift-abstain_ab1.py`, `shift-abstain_ab2.py`, and the verifiers' `shift-abstain_check_s1.py`, `shift-abstain_check_thr.py`, `shift-abstain_attack_s1.py`, `shift-abstain_attack_thresholds.py`, `shift-abstain_attack_stop.py`, `shift-abstain_attack_closed.py`. Each output is identical, byte for byte, to the saved `.out` file. Three scripts of an earlier, interrupted verifier (`shift-abstain_check_sec*.py`, `shift-abstain_engine.py`, `shift-abstain_attack_shift.py` in `verification/code/`) accompany no report; they were not used and were not copied.

### 12.5 The claims of the candidate theory, after checking

| claim | verdict |
|---|---|
| S1 (density ratio, stated with visit measures) | false as stated, by a factor of order L/ln L (Example 2.2); true with the factor B for the law of the top-level input (Proposition 2.1) and with (2L − 1)·B for visit measures (Proposition 2.3) |
| S3 (a property of tasks with rehearsal probability β costs 1/β) | true for a property that was not singled out in advance; a known property costs nothing (Proposition 2.4) |
| Ab1 | true (Theorems 4.1 and 4.4), provided the threshold rule drives the rehearsal |
| Ab2 | true (Theorem 5.1, Proposition 5.2), with the constant c₁ in the coverage statement and with the caveats on the ratio set (Example 5.7) |
| Ab3 | true with the constant c₂ of the difference test (Proposition 6.1) |
| N4 | true in the form "ask or abstain" (Corollary 7.2) |
| "On arbitrary inputs the asking cannot stop" (the prover's Corollary 3.6; N7 of the outline) | false as stated; true in the form "not before about 2^K/s questions" (Corollary 3.6) |
