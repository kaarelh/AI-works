# Scout N1 (new directions: logic and computability)

*Scout record for the paper on Solomonoff axiom induction (working name; nothing here depends on the name).*

**What was read.**
* The brief `../../00-brief.md`, in full.
* The author's notes in `../../prior/`:
  * `hanni-solomonoff-axiom-induction.md`;
  * `a-predictive-model-assigning-truth-values-to-sentences.md`;
  * `induction-in-mathematics.md`;
  * the condensation essay, skimmed for relevance.
* The sibling scout records, read for definitions and to avoid overlap:
  * `../fundamentals/notes.md` (scout F), in full;
  * `../sfi/notes.md` (scout S), §0–§3;
  * `../philosophy/notes.md` (scout P), §0;
  * `../literature/notes.md` (scout L), the parts on Chaitin, random axioms, Craig, speed-up, Demski, Gaifman and the novelty table.
* The earlier report's ω-gap theorem, `../../../../axiom-induction/paper/sections/universal.tex` §"The Bayesian ω-gap".

**Scripts.** They are in `checks/`. Each is seeded (seed 20261015) and writes `<name>.out` next to itself:
* `c1_lottery.py` (§3);
* `c2_finite_models.py` (§5);
* `c3_threshold.py` (§4).

No git command that changes repository state was run.

**Web search was unavailable.** The session's shared web-search budget was used up before this scout ran, and every WebSearch call was refused. References are therefore cited in two ways:
* by the keys and verification marks of the sibling scouts: scout L's [B] (bibliographic data verified by search) and [A] (abstract seen), scout P's `refs.bib`, or scout F's and scout S's reference sections;
* or marked **[recalled, unverified]**.

Every claim that rests on a recalled result says so in its status. I gave self-contained proofs wherever I could, so that few headline claims depend on recalled literature.

**Status tags.**
* **[proved]**: a full proof is given here.
* **[proved, given X]**: X is a cited result.
* **[proof sketch]**: the missing steps are named.
* **[computed: script]**.
* **[conjecture]**, **[open]**.
* **[refuted]**: kept, with its counterexample.
* **[known: ref]**: with the verification status of the reference in §9.

**Pointers.**
* "F" with a number refers to scout F's items, for example F13 (the loss bound) or F24 (incomplete truths).
* "S" with a theorem number refers to scout S's record.
* "AI" refers to the earlier report's paper (`../axiom-induction/paper`), by printed theorem number.
* "P1" is SFI Paper 1.
* Logarithms are base 2. c, c′, c₁, … are constants that depend only on the fixed universal machines, the coding of syntax and the background B.

---

## 0. Ranked list and summary

### 0.1 Ranked list

Columns: **truth** (status); **difficulty** (to a paper-quality proof); **novelty** (against scout L's novelty check and what I know); **coolness for this paper**.

| rank | direction | headline statement | status | truth / difficulty / novelty / coolness |
|---|---|---|---|---|
| 1 | **Random theories that no r.e. theory can replace** (§3) | There is a consistent stream of labelled sentences on which the one-tape inducer M_A has bounded loss, while no consistent r.e. theory proves the stream. So the coin-free W_A and the Kolmogorov K_A have unbounded loss, and the limit posterior lives on non-r.e. random theories. This answers scout F's open Q1 negatively. Q1 holds when the data's inconsistency arity is bounded (literals, SFI) and for Π₁ data. | proved; computed | true; easy–moderate; new (no analogue in SFI, where majority vote works); high: a phenomenon specific to logic |
| 2 | **Π₁ data: derandomisation, a coding theorem, and Chaitin's theorem for random theories** (§4) | With a true background B ⊇ Q, every Π₁ sentence that the universal random theory proves with probability ≥ 2^(−k) is proved by one true r.e. theory of complexity ≤ k + K(k) + c, built from k + 2 bits of the consistency probability Inc₀. Hence:<br>• K_A ≤ L_A + O(log L_A) on Π₁ data, a coding theorem where scout F's F11 shows none in general;<br>• a single true datum "K(x) > m" costs m ± O(log m) bits;<br>• bounded loss on Π₁ streams is always explained by one true theory;<br>• −log ΠExt(T) = −log m(Ext T) ± O(log) for true Π₁-axiomatised T.<br>One false Σ₁ datum breaks the coding theorem (sketch). | proved (sharpness: proof sketch given a recalled lemma); computed (threshold arithmetic) | true; moderate; new as stated, closest is Bienvenu et al. 2014 on random axioms; high: Gödel/Chaitin content, and it explains *where* the random tape helps |
| 3 | **Theoretical terms pay for finite theories** (§5) | Data "there are at least n things" (pure equality):<br>• every consistent finite theory in any monadic language has K_fin = min_{m≥n} K(m) ± c → ∞;<br>• one unary function symbol gives O(1);<br>• the posterior over finite theories puts mass → 1 on theories with the function symbol.<br>Data from PA: finite L_A-theories have K_fin → ∞ (reflexivity + G2), while ACA₀ or a truth predicate gives O(1).<br>General: r.e. axiom induction in L equals finite-theory induction in a two-sorted L⁺ with theoretical vocabulary *and* entities, up to O(1). This fails one-tape (lottery). | infinity: proved; computed. PA: proved given recalled facts (reflexivity, ACA₀). L⁺: proof sketch (Kleene-type) | true; easy–moderate; framing new, ingredients known (Kleene, Craig–Vaught, Löwenheim's finite model property); high for the philosophy (ladder step 3, Ramsey, Craig) |
| 4 | **Gödel phenomena** (§6) | Arithmetical shape of the trichotomy:<br>• true Σ₁ sentences are never independent;<br>• false Π₁ sentences get (0,1,0);<br>• so any Bel- or Indep-mass on a Π₁ sentence certifies its truth.<br>Con(T) and Gödel sentences, given data from a true T: all three values keep prior shares, and which of Con/¬Con is favoured is a choice of universal machine.<br>The coin-free posterior never exceeds 1/(1 + 2^(−c)) on "Σ₁-sound", whatever the data, true arithmetic included. One-tape: the same with a 2^(−K(L_A)) slack on Π₁ data; open in general.<br>Old evidence: B-entailed data confirm nothing, so free-deduction AI cannot do "induction in mathematics". | proved (soundness: given G2); one-tape general case open | true; easy; the specific statements are new; medium–high (answers the brief's Gödel seed exactly) |
| 5 | **The ω-gap: anatomy and where it closes** (§7) | Given all closed instances, the limit trichotomy of ∀xφ is (1,0,0), (0,1,0) or fully mixed, according to whether B + instances proves ∀xφ, refutes it, or neither. The Dis part is ω-inconsistent mass and the Indep part ω-incomplete mass.<br>• No prior over r.e. theories closes the gap uniformly: one-tape, via §4 and G2.<br>• It closes under the ω-rule and under full second-order consequence.<br>• For finite theories under a line budget it closes iff a Kreisel-type generalisation property holds. | proved (Kreisel link: an equivalence; known cases recalled) | true; easy; partly new (the earlier report has the generative version); medium |
| 6 | **Second-order and ω-logic versions learn Th(ℕ)** (N6) | With full second-order consequence, the categorical PA² gives loss O(1) on Th(ℕ) in any order (against F26's unbounded first-order loss). With the ω-rule and B ⊇ Q, every ω-consistent theory is Th(ℕ). | proved, given Dedekind categoricity | true; trivial; a remark; medium (pins the unlearnability of Th(ℕ) on effective deduction) |
| 7 | **QA power against predictive power** (N9) | Formal notions and three facts:<br>• question-answering coverage implies a loss bound (F13);<br>• bounded loss does not imply that any theory answers the stream (lottery);<br>• prediction on a text does not converge to answers on unasked questions (F24).<br>Bel is closed under conjunction up to additive error. | proved (assembled) | true; easy; low–medium novelty; medium |
| 8 | **Speed-up and conservative extensions** (N8) | For finite theories, conservative extensions with theoretical vocabulary (ACA₀ over PA, NBG over ZF) also buy proof speed-up, so derivation-charged inducers prefer them on observational data. For r.e. axiom sets, scout S's proof padding neutralises this. | proof sketch, given recalled speed-up results | probably true; moderate; known ingredients; medium |
| 9 | **Th(ℕ): is the loss o(n)?** (N7, scout F's Q3) | The loss is o(n) in an enumeration if some r.e. T decides a density-1 set of sentences (proved); whether such a T exists is a generic-decidability question. | reduction proved; main question open | unknown; hard; medium |
| 10 | **Kreisel's conjecture and line budgets** (§7.4) | Finite theories with constant line budgets close the ω-gap exactly when a Kreisel-type generalisation property holds. A theory without Q3 shows the background matters. | equivalence proved; known cases recalled | — ; easy given literature; medium (a nice link, but the literature is unverified) |
| 11 | **PR against CR** (N10) | CR's predictor is a mixture of PR's and a "data-plus-weak-theory" component, with an explicit decomposition. When they differ is governed by the mass of weak theories. | proved (easy) | true; easy; low (mostly in F18–F21); low |
| 12 | **Learning in the limit** (N12) | A Gold-style impossibility for computable learners of r.e. theories from text, against the Δ₂ ideal posterior. | known in substance | known; low |
| 13 | **Sharpness of §4 at Σ₁** (§4.5) | With a flexible Σ₁ formula, two data (one true Π₁, one false Σ₁) give F11's log d gap. | proof sketch, given recalled flexible formulas | probably true; moderate; part of rank 2 |

### 0.2 Summary of the four pushed directions

**1. The lottery (§3).**

*Theorem E1.* Take a binary symbol W and N_k + 1 = 2^(k+1) tickets in "lottery k". There is a stream D_∞ with these properties:
* it is computable from ∅′;
* it consists of λ_k ("lottery k has a winner among its tickets") and one labelled-false ticket W(k, j*_k) per lottery;
* on it the universal one-tape inducer keeps M_A(D_n) ≥ 2^(−c)·0.2887, so its loss is bounded;
* no consistent r.e. theory proves all of D_∞.

The random theory that draws a winner for each lottery uniformly survives with probability Π_k(1 − 2^(−(k+1))). The diagonal picks, for the e-th r.e. theory, a ticket that this theory fails to refute, and such a ticket exists because the theory proves λ_e. Consequences:
* W_A(D_n) → 0 and K_A(D_n) → ∞, while L_A stays bounded;
* the posterior probability of deterministic hypotheses → 0;
* the limit posterior gives probability 0 to tapes with an r.e. theory.

*Proposition E2 (where it cannot happen).* If every inconsistent subset of the data's sentence class contains an inconsistent subset of size ≤ r, a majority vote at a Lebesgue density point gives a consistent r.e. theory proving the stream. This covers:
* literal data (r = 2);
* P1's SFI, where the coin-free version then also has bounded loss.

So the phenomenon comes from logical consistency constraints of unbounded arity. It appears in AI and consistent SFI, not in plain SFI. Π₁ data also exclude it (§4, A3).

**2. Π₁ data (§4).**

*Theorem A1 (derandomisation).* For B r.e., true and ⊇ Q, and every k, the set

T_k := {π Π₁ : Unif(V_π) > I′_k + 2^(−(k+2))}, with I′_k the (k+2)-bit truncation of Inc₀,

has these properties:
* it is r.e. with an index of complexity ≤ k + K(k) + c;
* it contains every Π₁ sentence of prior belief ≥ 2^(−k);
* all its members are true.

The proof uses scout F's identity Bel₀(φ) = Unif(V_φ) − Inc₀: a sentence passing the threshold has positive belief, and a Π₁ sentence that some consistent extension of Q proves is true.

Corollaries:
* *A2.* A coding theorem for Π₁ data: K_A ≤ L_A + K(⌈L_A⌉) + c.
* *A3.* Bounded loss on a Π₁ stream implies one true theory proves it all.
* *A4.* Chaitin for random theories: for every x with K(x) > m, the single true datum κ(x, m) = "K(x) > m" costs m − O(log m) ≤ L_A ≤ m + O(log m). Its label information is ≤ 1 bit, and unconstrained SFI pays O(1).
* *A6.* The one-tape and coin-free probabilities of the extensions of a true Π₁-axiomatised theory agree up to O(log).

The random tape therefore helps only where logic leaves room for hedging: never on Π₁ truths, but on literals of fresh predicates (F11), on false Σ₁ assertions (§4.5) and on lotteries (§3).

**3. Theoretical terms (§5).**

*Theorem B1.*
* In any monadic language, a consistent sentence of quantifier rank q with k predicates has a model of size ≤ 2^k q. This is Löwenheim's finite model property, proved here by an Ehrenfeucht–Fraïssé argument and checked by computation.
* Hence on the data λ_n ("≥ n elements"): K_fin(D_n) = min_{m≥n} K(m) ± c. This is unbounded, but grows more slowly than log g(n) for any computable unbounded g.
* The sentence "f is injective and not surjective" makes the cost O(1). The posterior over finite theories moves all its mass to theories that use f.
* In literal symbol count the three levels are ≥ n (pure equality), between log n − log log n and O(log² n) (monadic), and O(1) (with f).

*Theorem B2.* On PA's theorems, finite L_A-theories have K_fin → ∞. Every consistent L_A-sentence fails to prove some PA axiom, by reflexivity and Gödel's second theorem. A finite two-sorted theory (ACA₀) or a one-sorted truth predicate gives O(1); ACA₀ adds no first-order content.

*Theorem B3.* For a two-sorted extension L⁺ (numbers, assignments, satisfaction), K_fin^{L⁺} = K_A^L ± c and W_fin^{L⁺} ≍ W_A^L. The idealised r.e. framework already contains theoretical vocabulary and theoretical entities, which is why F7′ finds that they cost nothing there.

*B4.* The equivalence fails one-tape: on the lottery stream, random finite theories are eliminated.

**4. Gödel phenomena (§6).**

*D1 (the trichotomy is arithmetically lopsided).*
* True Σ₁ sentences have Bel = 1.
* False Π₁ sentences have (Bel, Dis, Indep) = (0, 1, 0).
* With true data, true Π₁ sentences not entailed by B + data have all three values positive.

So the inducer errs one-sidedly: it may deny true Π₁ sentences and affirm false Σ₁ sentences, never the reverse.

*D2 (soundness).*
* Coin-free: every compatible Σ₁-sound theory has a Σ₁-unsound companion T + ¬Con(T) at +c bits (G2). So the posterior probability of Σ₁-soundness is ≤ 1/(1 + 2^(−c)) for all data, true arithmetic included.
* One-tape on Π₁ data: the probability of Σ₁-unsoundness is ≥ 2^(−K(⌈L_A⌉)−c), via A1.
* The one-tape case in general is open.

*D3 (Con(T)).* For a true T presented by its theorems, the limits of Bel, Dis and Indep of Con(T) are all positive prior shares. Changing the universal machine makes their ratio anything.

*D4 (old evidence).* Data entailed by B leave the posterior exactly unchanged. With B ⊇ Q, checking instances of a decidable property never raises Bel(∀xP(x)). The author's "induction in mathematics" note asks for exactly this inference, and it needs a bounded deducer.

---

## 1. Setting and notation

I use scout F's definitions (Defs 2.1–2.8 there) without change:
* the language L and the r.e. consistent background B;
* Cn, data sets D, the literals D^±, the conjunction ψ_D and prefixes D_n;
* theory machines G and the universal G_U;
* the random axiom set A_ω and the uniform measure Unif on tapes;
* M_A(D) = Pr_ω[B ∪ A_ω consistent and ⊢ ψ_D], and L_A := −log M_A;
* Bel_D, Dis_D, Indep_D, and Bel₀(φ) = M_A({(φ,1)});
* W_A (coin-free) and K_A (Kolmogorov);
* K_fin (finite axiomatisations, a single sentence);
* Ext(T), [T], Π[T], ΠExt(T), and E_D := {ω : B ∪ A_ω consistent, ⊢ ψ_D}.

Additional notation:
* **V_φ** := {ω : B ∪ A_ω ⊢ φ}. This is an r.e. open set, so Unif(V_φ) is left-c.e. uniformly in φ.
* **Inc** := V_⊥, with **Inc₀** := Unif(Inc).
* By F3(a), **Bel₀(φ) = Unif(V_φ) − Inc₀** and M_A(D) = Bel₀(ψ_D).
* **K_fin^L(D)** := min{K(ψ) : ψ ∈ Sent_L, B ∪ {ψ} consistent, B ∪ {ψ} ⊢ ψ_D}.
* **W_fin^L(D)** := Σ_ψ m(ψ)·1[same condition], with m the universal semimeasure on codes of sentences.
* **E_∞** := ∩_n E_{D_n} for an infinite stream D_∞. P_∞ := Unif(· | E_∞) when Unif(E_∞) > 0 (F22).

Arithmetic:
* L_A = {0, S, +, ·, <} and n̄ := S^n 0.
* Q is Robinson arithmetic. Δ₀ means bounded quantifiers only.
* A Σ₁ (Π₁) sentence is ∃x⃗δ (∀x⃗δ) with δ in Δ₀.
* **Π₁\*** is the decidable class of finite conjunctions of Π₁ sentences and negations of Σ₁ sentences. Each member is logically equivalent to a Π₁ sentence.
* A theory is **Σ₁-sound** if it proves no false Σ₁ sentence.

Two standard facts are used throughout [known; standard]:
* **(Σ₁C)** Q proves every true Σ₁ sentence.
* **(Π₁T)** Hence, if Q ⊆ Cn(B) and B ∪ A is consistent, every Π₁\* sentence that B ∪ A proves is true. If it were false, its negation would be equivalent to a true Σ₁ sentence, which Q proves.

---

## 2. Candidate directions: statements, first passes, assessments

Each item gives a statement, a first pass, and an assessment. The four pushed directions (N1–N4) are summarised here and developed in §3–§6.

### N1. Random theories that no r.e. theory can replace (scout F's Q1) → §3

* **Statement.** Does Unif(E_∞) > 0 imply that some consistent r.e. theory proves D_∞? This is scout F's Q1, the converse of F22.
* **First pass.**
  * In SFI the answer is yes: a majority vote at a density point gives a partial computable function.
  * For literal data the answer is also yes, since a set of literals is consistent iff it has no complementary pair.
  * For general sentences, the majority vote can be inconsistent (the lottery paradox), which suggests a counterexample. It works: Theorem E1.
* **Assessment.** Proved; computed (c1). New. Cool, because it is a property of logical consistency that no function-induction analogue has. The random theories that explain the stream are not mixtures of theories in any useful sense.

### N2. Π₁ data: derandomisation, coding theorem, Chaitin → §4

* **Statement.** Is there a coding theorem K_A ≈ L_A for some natural class of sentences? What does a single datum "K(x) > m" cost?
* **First pass.** In arithmetic, consistent theories extending Q cannot prove false Π₁ sentences. So "proved with positive probability" implies "true" on Π₁, and all such sentences are jointly consistent. The threshold set built from bits of Inc₀ is then a single true theory.
* **Assessment.** Proved. New as stated. Scout L lists Bienvenu et al. (2014): adding randomly chosen true axioms "C(x) > n" to PA "does not help us prove new interesting theorems" [A]. A1 is a universal-mixture generalisation of that message, for arbitrary random theory machines, handling inconsistent tapes through Inc₀. I could not read their paper, so the overlap is unchecked beyond the abstract-level description.

### N3. Theoretical terms and succinctness → §5

* **Statement.** Can a simplicity prior with observational data provably prefer theories with theoretical terms because they compress?
* **First pass.**
  * Universal r.e. version: no (F7′, scout S Thm 3.1).
  * Finite theories: yes. Use Löwenheim's finite model property for monadic logic, reflexivity of PA, and Kleene's finite axiomatisation with extra symbols.
* **Assessment.** Proved for the elementary example; the rest given known facts. Ingredients known; the Bayesian and Kolmogorov formulation is new. Cool: it gives an exact place in the hypothesis hierarchy where theoretical terms start to pay.

### N4. Gödel phenomena → §6

* **Statement.** What is the posterior on Con(T) or G_T given data from T? Can the inducer learn soundness?
* **First pass.** The F24 limits plus G2 companions. The Σ₁/Π₁ asymmetry is immediate from (Σ₁C).
* **Assessment.** Proved (one-tape soundness open in general). The statements are new, the logic standard. Medium–high: it answers the brief's seed directly and gives the paper a clean "what the inducer can never learn" section.

### N5. The ω-gap: anatomy and versions → §7

* **Statement.** Does the Bayesian ω-gap (AI Thm 3.9; F25; scout L's Observation L1) disappear in some version?
* **First pass.** It is exactly the ω-incompleteness of B + instances. It disappears with the ω-rule, with full second-order consequence, and (for the generative variant) under the earlier report's selection-aware likelihoods. For finite theories under line budgets it is tied to Kreisel's conjecture.
* **Assessment.** Easy; partly new; medium.

### N6. Second-order consequence and the ω-rule

* **Statement.** Let M_A^{(2)} be the inducer with full second-order consequence: hypotheses are second-order sentences, and compatibility is "has a full model and every full model satisfies ψ_D". Then the loss on any presentation of Th(ℕ), in any order, is at most K(PA²) + c, where PA² is second-order Peano arithmetic. The limit posterior gives Bel(φ) = 1[ℕ ⊨ φ] uniformly.
* **Proof** [proved, given Dedekind's categoricity theorem (known; standard)].
  * Every full model of PA² is isomorphic to ℕ, so PA² semantically entails every true L_A-sentence.
  * The theory {PA²} is compatible with every correctly labelled finite D, so M_A^{(2)}(D) ≥ 2^(−K(PA²)−c).
  * In the limit, every compatible hypothesis entails all of Th(ℕ), so its L_A-content is Th(ℕ).
* **ω-rule version** [proved; standard].
  * Q plus the ω-rule proves every true L_A-sentence, by induction on the sentence: Δ₀ truths by (Σ₁C), ∀ by the ω-rule, ∃ by a witness.
  * So with ⊢_ω and B ⊇ Q, every ω-consistent theory has L_A-content Th(ℕ). The inducer is omniscient about arithmetic a priori.
* **Assessment.** A remark, but a useful one. F26's unbounded loss on Th(ℕ) is a fact about *effective* consequence, not about the complexity of arithmetic truth: a single short categorical axiom "explains" all of it once consequence is not r.e. Novelty is low; it is the formal side of the classical point that PA² settles every arithmetic question semantically but not deductively.

### N7. Th(ℕ): is the loss o(n)? (scout F's Q3)

* **Statement.** In a natural length-lexicographic enumeration (φ_i) of L_A-sentences labelled by truth, is L_A(D_n) = o(n)?
* **First pass (reduction)** [proved]. For every consistent r.e. T ⊆ Th(ℕ) and every n:

  L_A(D_n) ≤ K(e_T) + log C(n, u_n) + u_n + 2 log n + c,

  where u_n := #{i ≤ n : T decides neither φ_i nor ¬φ_i}.
  * *Proof.* This is F14(b). The theory T plus the labelled undecided sentences is consistent (all true) and proves D_n. Its index is computable from e_T, n, the position set of the undecided sentences (log C(n, u_n) bits given u_n) and their labels (u_n bits).
  * Hence, if some r.e. T ⊆ Th(ℕ) has u_n/n → 0, then L_A(D_n) = o(n), since n·H(u_n/n) = o(n).
* **The open part.**
  * Does some r.e. T ⊆ Th(ℕ) (PA, say) decide a density-1 set of sentences in the enumeration?
  * This is a question of *generic-case decidability* of arithmetic, in the sense of Hamkins and Miasnikov's "the halting problem is decidable on a set of asymptotic probability one" [recalled, unverified].
  * Calude and Jürgensen (scout L: calude2005complexity [A]) prove that the probability that a true n-bit statement is provable tends to 0. But their measure (δ-complexity, prefix-free Gödel codes) differs from length-lexicographic syntax. So their theorem does not decide Q3 here, and if it transferred it would suggest u_n/n → 1 for every T.
  * Even then, the lower bound needs label complexity, not undecidedness: L_A(D_n) ≥ K(labels_n | n) − c (F26(b)).
* **Assessment.** Open, hard, and it depends on syntax conventions. Medium interest. The reduction is worth a sentence in the paper.

### N8. Speed-up from conservative theoretical extensions

* **Statement.** Use the earlier report's derivation-charged inducers (budgets on derivation size per datum, AI Thm 6.16). Take observational data consisting of L_A-theorems φ_n whose shortest PA-proofs are non-elementarily longer than their proofs in ACA₀. Then the finite theory ACA₀ (theoretical sort: sets) fits the data at a polynomial budget, while no finite L_A-theory does (B2) and PA does not at that budget.
* **First pass** [proof sketch, given recalled speed-up results].
  * Non-elementary speed-up of ACA₀ over PA, and of NBG over ZF, on sentences of the smaller language [recalled, unverified: Pudlák's survey "The lengths of proofs" (scout L: pudlak1998lengths [B]); Gödel 1936 (godel1936lange [B, A]) for the higher-order phenomenon].
  * The comparison with PA needs a reading under which PA's schema instances count as axioms of bounded size.
* **Relation to scout S.** Scout S's Prop 3.5 eliminates vocabulary by proof padding: one certificate axiom per datum, observational, with derivation size polynomial in the original. That is an *infinite* r.e. axiom set, and it neutralises any speed-up. So speed-up favours theoretical terms only for finite theories (or finitely many schemata). This is the same boundary as in §5.
* **Assessment.** Probably true; known ingredients; medium. It belongs in §5's discussion as a remark, not as a theorem, until the speed-up references are checked.

### N9. Question-answering power against predictive power

* **Definitions.**
  * For a theory T and a set Q of questions (sentences), the *answered set* is Ans_T(Q) := {φ ∈ Q : T decides φ}. It is *correct* against a truth assignment if all its answers agree with it.
  * For the inducer after data D, the δ-answers are: "yes" if Bel_D(φ) ≥ 1 − δ, "no" if Dis_D(φ) ≥ 1 − δ, and "don't know" otherwise.
  * Predictive power on a stream is cumulative log loss.
* **Facts** [proved, assembled].
  * (a) *Answering implies predicting.* If a consistent r.e. T answers every question of the stream correctly, the loss is ≤ K_≡(T) + c (F13).
  * (b) *Predicting does not imply answering by any theory.* The lottery stream (E1) has bounded loss, but no r.e. theory answers its questions as labelled.
  * (c) *Predicting a text does not converge to answers on unasked questions.* On a two-valued presentation of an incomplete T* the loss is bounded, but on every T*-independent question the δ-answer is "don't know" forever for small δ, since all three trichotomy values keep prior shares (F24). Three-valued data fix this.
  * (d) *Closure.* Bel_D(φ ∧ ψ) ≥ Bel_D(φ) + Bel_D(ψ) − 1, since "proves φ" and "proves ψ" imply "proves φ ∧ ψ". So δ-answers are closed under k-fold conjunction with error kδ. Unconstrained SFI has no such closure; consistent SFI has it only after closure (scout S, Prop 2.11).
* **Assessment.** Mostly assembly. The new part is (b), via §3. Medium: it gives the philosophy scout a formal vocabulary for "answering questions ≫ predicting pixels".

### N10. Proof-requiring against consistency-requiring: an explicit decomposition

* **Statement** [proved]. For every D and φ:

  M_A^nc(D)·Bel^nc_D(φ) = M_A(D)·Bel_D(φ) + Unif{ω : B ∪ A_ω ∪ D^± consistent, B ∪ A_ω ⊬ ψ_D, B ∪ A_ω ∪ D^± ⊢ φ}.

  So the CR predictor is a mixture of the PR predictor, with weight M_A(D)/M_A^nc(D), and a "weak theory plus the data" component.
* **Proof.** Split the CR event by whether B ∪ A_ω ⊢ ψ_D. If it does, then A_ω ∪ D^± ≡ A_ω and consistency is the PR condition. ∎
* **When they differ.** CR ≈ PR exactly when the weak-theory mass is negligible. F19 shows it never is: the empty theory keeps weight 2^(−c). So CR has linear loss (F20).
* **Assessment.** Easy, low novelty; a one-line clarification for the fundamentals thread.

### N11. Theory-level coding (scout F's Q2) for Π₁-axiomatised theories → §4, A6

* [proved] For an r.e. set T of true Π₁\* sentences (B true ⊇ Q):

  −log ΠExt(T) = −log m(Ext(T)) ± (K(⌈−log ΠExt(T)⌉) + c).

  Q2 for [T] (equality rather than extension) and for general T stays open.

### N12. Learning in the limit

* **Statement.** The class of consistent r.e. theories (up to equivalence) is not identifiable in the limit from text by any learner [known in substance: Gold 1967 (gold1967language, scout L [X]); the class contains an increasing chain of finitely axiomatised theories and its union]. It is identifiable from informant (three-valued data) by the Δ₂ posterior (F24(b)).
* **Assessment.** Known; the paper should cite it as the learning-theoretic shadow of F24, not as a new result. Low.

### N13. Sharpness of the Π₁ coding theorem at Σ₁ → §4.5

* Proof sketch given a recalled flexible-formula lemma.

### Directions considered and dropped

* **Self-referential sentences about the posterior** ("Bel₀(β) < ½"). Bel₀ is Δ₂-definable, so fixed points exist. But Bel is a probability of provability, not of truth, so there is no paradox and nothing to learn: β's truth is not constrained by Bel₀(β). Dropped.
* **Rosser-style balance points.** No machine-independent content found (D3 shows ratios are machine-dependent). Dropped.

