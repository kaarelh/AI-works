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

---

## 3. Push 1: random theories that no r.e. theory can replace

### 3.1 The question and why it matters

Scout F proved (F22) the following. If some consistent r.e. theory proves every datum of an infinite stream D_∞, then:
* Unif(E_∞) > 0;
* the posterior converges in total variation;
* the cumulative loss is bounded.

Scout F asked for the converse (Q1): does Unif(E_∞) > 0 imply that some consistent r.e. theory proves D_∞?

The question matters for three reasons.
* **What the hypotheses are.** The one-tape inducer's hypotheses are random theories. If every bounded-loss success were explained by one r.e. theory, the randomness would be a technical convenience. If not, the inducer can succeed where no theory, in the usual sense, succeeds.
* **The three versions.** It decides whether the one-tape version M_A and the coin-free version W_A can differ *qualitatively* on a single stream. F11 compares them only on finite data.
* **SFI.** In P1's SFI the analogous converse holds (Prop. E2(b) below). A failure for axioms would be a phenomenon of logic itself.

### 3.2 A density lemma

**Lemma E0 (Lebesgue density on Cantor space)** [proved]. Let X ⊆ {0,1}^∞ be Borel with Unif(X) > 0, and ε ∈ (0,1). Then there is a finite string w with Unif(X ∩ [w]) > (1 − ε)·2^(−|w|).

*Proof.*
* By outer regularity there is an open O ⊇ X with Unif(O) < Unif(X)/(1 − ε).
* Write O as a disjoint union of cylinders [w_i], with the w_i prefix-free.
* If Unif(X ∩ [w_i]) ≤ (1 − ε)·2^(−|w_i|) for every i, then summing gives Unif(X) ≤ (1 − ε)·Unif(O) < Unif(X), a contradiction. ∎

### 3.3 The lottery

**Setting.**
* L contains 0, S and a binary relation symbol W. Numerals are n̄ := S^n 0.
* B is a consistent r.e. background that does not mention W and has a model in which the numerals denote pairwise distinct elements; for example B = ∅, Q or PA, with L = L_A ∪ {W}.
* For k ≥ 0 put N_k := 2^(k+1) − 1 (so lottery k has 2^(k+1) tickets 0, …, N_k), and let

  λ_k := ∃x W(k̄, x) ∧ ∀x (W(k̄, x) → x = 0̄ ∨ x = 1̄ ∨ … ∨ x = N̄_k).

  So λ_k says "lottery k has a winner, and the winner is one of its tickets".

**The random lottery theory G_lot.**
* G_lot reads the tape in consecutive blocks of k + 1 bits, k = 0, 1, 2, …. Block k is read as a number J_k ∈ {0, …, N_k}.
* After reading block k it emits λ_k, W(k̄, J̄_k), and ¬W(k̄, j̄) for every j ≤ N_k with j ≠ J_k.
* It is a theory machine: a c.e. set of pairs (tape prefix, sentence).
* Under Unif the J_k are independent and uniform.
* Every A^{G_lot}_ω is consistent with B. In the model of B with distinct numerals, interpret W as {(k, J_k(ω)) : k ∈ ℕ}, extended to non-numeral elements as false.

**Theorem E1 (the lottery)** [proved; computed: `checks/c1_lottery.out`, Part A]. There is an infinite stream D_∞ of labelled L-sentences, computable from ∅′, such that:
* (a) **Bounded one-tape loss.** For every n, M_A(D_n) ≥ 2^(−K(G_lot) − c)·Π_{k≥0}(1 − 2^(−(k+1))), and the product is 0.28879. So the cumulative loss L_A(D_n) − L_A(∅) is bounded, Unif(E_∞) > 0, and the posterior converges in total variation to P_∞ (F22).
* (b) **No theory.** No consistent r.e. theory proves every sentence of D_∞^± (with B).
* (c) **The other versions diverge.** W_A(D_n) → 0 and K_A(D_n) → ∞, while L_A(D_n) stays bounded. Hence the coin-free cumulative loss is unbounded on a stream where the one-tape loss is bounded, and also K_fin^{L′}(D_n) → ∞ for every finite axiomatisation in every language L′ ⊇ L.
* (d) **The posterior abandons theories.**
  * The posterior probability that the tape's program is a deterministic machine (one that ignores the coins) tends to 0.
  * P_∞{ω : Cn(B ∪ A_ω) is r.e.} = 0. In the limit the posterior is concentrated on random theories whose deductive closure is not r.e.

*Proof.*

*The stream.*
* Let W_0, W_1, … enumerate all r.e. sets of L-sentences. For each e define j*_e ∈ {0, …, N_e} as follows.
  * If B ∪ W_e is consistent and proves λ_e, let j*_e be the least j ≤ N_e such that B ∪ W_e ⊬ ¬W(ē, j̄).
    * Such a j exists. Otherwise B ∪ W_e proves ¬W(ē, j̄) for all j ≤ N_e. Together with the second conjunct of λ_e and the equality axioms this gives ∀x ¬W(ē, x), contradicting the first conjunct of λ_e.
  * Otherwise let j*_e := 0.
* D_∞ := (λ_0, 1), (W(0̄, j̄*_0), 0), (λ_1, 1), (W(1̄, j̄*_1), 0), …. The label 0 means "false": the datum asserts ¬W(k̄, j̄*_k).
* *Computability from ∅′.* "B ∪ W_e is consistent" is Π₁; "B ∪ W_e ⊢ λ_e" and "B ∪ W_e ⊢ ¬W(ē, j̄)" are Σ₁. So j*_e is computable from ∅′ uniformly in e.

*(a)*
* Let E := {ω : J_k(ω) ≠ j*_k for all k}. By independence and continuity from above, Unif(E) = Π_k (1 − 2^(−(k+1))) > 0. The product converges because Σ_k 2^(−(k+1)) < ∞.
* For ω ∈ E, the theory B ∪ A^{G_lot}_ω is consistent and proves every λ_k. It also proves ¬W(k̄, j̄*_k), because J_k ≠ j*_k. So ν_{G_lot}(D_n) ≥ Unif(E) for all n.
* F4 (dominance) gives M_A(D_n) ≥ 2^(−K(G_lot) − c)·Unif(E).
* The numerical value is computed in c1 (A2): exact enumeration agrees with the product formula for 1–4 lotteries, and the infinite product is 0.288788.

*(b)*
* Suppose B ∪ W_e is consistent and proves all of D_∞^±. In particular it proves λ_e.
* So j*_e was chosen as a ticket with B ∪ W_e ⊬ ¬W(ē, j̄*_e).
* But ¬W(ē, j̄*_e) ∈ D_∞^±. Contradiction.

*(c)*
* W_A(D_n) = Σ_e m(e)·1[B ∪ W_e consistent, ⊢ ψ_{D_n}]. Each indicator is non-increasing in n and, by (b), eventually 0. By dominated convergence (Σ_e m(e) ≤ 1), W_A(D_n) → 0.
* Then K_A(D_n) ≥ −log W_A(D_n) → ∞.
* A finite theory in any L′ ⊇ L has an r.e. L-content, so (b) applies to it as well.

*(d)*
* Let Det be the set of tapes pω′ with p ∈ dom V and G_{V(p)} ignoring its coins, so that it emits a fixed r.e. set X_p. Then Unif(Det ∩ E_{D_n}) = Σ_{p : V(p) ∈ Det} 2^(−|p|)·1[B ∪ X_p consistent, ⊢ ψ_{D_n}].
* This tends to 0 by (b) and dominated convergence. Dividing by M_A(D_n), which is bounded below by (a), gives the first claim.
* For the second: if ω ∈ E_∞ and Cn(B ∪ A_ω) were r.e., it would be a consistent r.e. theory proving D_∞, contrary to (b). ∎

**Remarks.**
* **Rate.** A batch version kills more theories per lottery. Lottery k gets 2^(2k+1) tickets and diagonalises every e < 2^k, with one labelled-false ticket per killed theory. The random theory then survives lottery k with probability ≥ 1 − 2^(−k−1), and after lottery k every e < 2^k is eliminated. So −log W_A(D_n) ≥ −log Σ_{e ≥ 2^k} m(e) after the k-th lottery [proved by the same argument]. This lower bound is a tail of the universal semimeasure. It is unbounded but grows very slowly; I did not determine the exact rate.
* **Where the randomness sits.** Each random lottery theory has the same law (λ_k) and differs only in a randomly drawn contingent fact (the winner). Under proof-requiring compatibility, a reported loser can only be *explained* by committing to a winner:
  * a deterministic theory commits once, and the adversary reports exactly the ticket it fails to refute;
  * a random theory commits at random, and loses only if it happens to pick the reported ticket.

  This is the same split between laws and randomly drawn initial conditions that the laws-versus-initial-conditions seed is about (P2's model–randomness split). Here it is forced, not merely preferred.
* **Only for proof-requiring.** The r.e. theory {λ_k : k} is consistent with every datum, so under the consistency-requiring variant it is compatible. The lottery phenomenon belongs to proof-requiring compatibility, which demands that reported losers be *derived*.
* **Computed illustration (c1, Part A3).** In a twelve-lottery truncation with a mixture of twelve deterministic theories and the random theory:
  * the deterministic posterior share falls from 0.79 to 0 by the ninth lottery;
  * the random theory's cumulative loss converges to 1.79 bits, which is −log₂ of the truncated product.

  The majority-vote theory (A4) refutes every ticket of every lottery k ≥ 1, so it is inconsistent with λ_k.

### 3.4 Where the lottery cannot happen: bounded inconsistency arity

**Proposition E2 (majority vote)** [proved; computed: `checks/c1_lottery.out`, Part B].

*(a) Axiom induction.* Let S ⊆ Sent_L be decidable and r ≥ 1, and suppose every B-inconsistent finite subset of S contains a B-inconsistent subset with at most r elements. Let D_∞ be an infinite data stream with D_∞^± ⊆ S and Unif(E_∞) > 0. Then there is a consistent r.e. theory T ⊆ S with D_∞^± ⊆ T. In particular B ∪ T proves D_∞, and W_A(D_n) ≥ m(index of T) for all n, so the coin-free loss is also bounded.

*(b) SFI.* For P1's one-tape M_F with input space X and labels Y, if D_∞ : X ⇀ Y is an infinite partial function with lim_n M_F(D_n) > 0, then there is a partial computable f ⊇ D_∞. So P1's coin-free W also has bounded loss on D_∞.

*Proof.*

*(a)*
* Put ε := 1/(r + 1). By Lemma E0 choose w with Unif(E_∞ ∩ [w]) > (1 − ε)·2^(−|w|). Write Pr_w(·) := 2^{|w|}·Unif(· ∩ [w]).
* Let T := {φ ∈ S : Pr_w(V_φ) > 1 − ε}. T is r.e., because Pr_w(V_φ) is left-c.e. uniformly in φ.
* *Data.* For φ ∈ D_∞^±, V_φ ⊇ E_∞, so Pr_w(V_φ) ≥ Pr_w(E_∞) > 1 − ε, and φ ∈ T.
* *Consistency.* Suppose B ∪ T is inconsistent.
  * By compactness and the hypothesis on S, some φ_1, …, φ_j ∈ T with j ≤ r form a B-inconsistent set.
  * Then Pr_w(V_{φ_1} ∩ … ∩ V_{φ_j}) > 1 − jε ≥ 1 − rε = ε.
  * Every tape in that intersection has B ∪ A_ω proving a B-inconsistent set, so it lies in Inc. Hence Pr_w(Inc) > ε.
  * But Inc ∩ E_∞ = ∅, so Pr_w(Inc) ≤ 1 − Pr_w(E_∞) < ε. Contradiction.

*(b)*
* As in (a) with ε = 1/2, choose w with Pr_w{ω : f_ω ⊇ D_∞} > 1/2.
* Define f(x) := y if Pr_w{ω : f_ω(x) = y} > 1/2. At most one y qualifies, the condition is Σ₁, and f is partial computable.
* For x ∈ dom D_∞, the event {f_ω(x) = D_∞(x)} contains {f_ω ⊇ D_∞}, so f(x) = D_∞(x).
* Then W(D_n) ≥ m(f) > 0 for all n. ∎

**Instances.**
* **Literal data** (F9's condition (Lit), a fresh unary predicate R). Every finite set of literals with no complementary pair is B-consistent, so r = 2, and Q1 holds for literal streams.
* **Plain SFI.** Q1 holds, by (b). There the one-tape and coin-free versions can differ by unbounded amounts on finite data (P1 Prop 4.5 / Thm 4.9), but not "bounded against unbounded" on a single infinite stream.
* **Π₁ data over a true arithmetic background.** Q1 holds by a different argument (§4, Corollary A3).
* **The lottery.** S contains λ_k and the W-literals. The set {λ_k} ∪ {¬W(k̄, j̄) : j ≤ N_k} is minimally inconsistent with N_k + 2 elements, so no finite r bounds the arity.
  * c1 Part B checks (a) on random finite tape spaces with random inconsistency hypergraphs of arity r = 2, 3, 5. There were 0 violations at ε = 1/(r+1) in 400, 400 and 387 instances.
  * At ε = 2/3 there were 67, 120 and 157 violations: the threshold matters.
  * For each threshold 1 − ε, the lottery with 2^(k+1) > 1/ε tickets makes the majority set inconsistent.
* **Consistent SFI.** M_F^cons agrees with M_A within constant factors (F8), so the lottery stream also separates one-tape consistent SFI from coin-free consistent SFI. The phenomenon comes from *logical consistency constraints of unbounded arity*. Consistent SFI has them, and plain SFI does not.

**Corollary E3 (scout F's Q1, answered)** [proved]. Unif(E_∞) > 0 does not in general imply that some consistent r.e. theory proves D_∞ (E1). It does when the data's inconsistency arity is bounded (E2), and for Π₁ data over a true background extending Q (A3).

### 3.5 What this means for the paper

* **The Kolmogorov-versus-semimeasure question.** F11 shows that P1's finite-data gaps recur for axioms. E1 shows something P1 cannot have: a single stream on which the semimeasure version learns and the Kolmogorov and coin-free versions do not.
* **"A theory is a logical theory."** In the limit, the one-tape inducer's belief on the lottery stream is about no r.e. theory at all. Its successful hypotheses are *random theories*: a law plus a chance-drawn completion of the contingent facts. This is not an objection to the axiom view. It makes precise that the idealised inducer's objects are "theories with random initial conditions", and that proof-requiring compatibility can force the randomness into the hypotheses.
* **Open questions.**
  * *(E-Q1) Arithmetic.* Is there a lottery stream inside L_A, with B true? It needs data that are not Π₁\* (A3), for example false Σ₁ assertions as in §4.5.
  * *(E-Q2) Rate.* Find the best possible divergence rate of −log W_A along a stream with bounded one-tape loss.

---

## 4. Push 2: Π₁ data — derandomisation, a coding theorem, and Chaitin's theorem for random theories

### 4.1 Setting

* L ⊇ L_A.
* B is r.e. with Q ⊆ Cn(B), and B is **true**: it has a model whose L_A-reduct is ℕ. B = Q, IΣ₁ and PA all qualify.
* Π₁\*, (Σ₁C) and (Π₁T) are as in §1.
* Inc₀ = Unif{ω : B ∪ A_ω inconsistent} is a left-c.e. real; F3 shows it is Solovay complete, hence irrational. Let I′_k be its truncation to k + 2 binary digits, I′_k := ⌊2^(k+2)·Inc₀⌋·2^(−(k+2)). So I′_k ≤ Inc₀ < I′_k + 2^(−(k+2)).

### 4.2 The derandomisation theorem

**Theorem A1 (Π₁ derandomisation)** [proved; computed: `checks/c3_threshold.out` for the threshold arithmetic]. There is a constant c such that for every k ≥ 0 the set

  T_k := {π ∈ Π₁\* : Unif(V_π) > I′_k + 2^(−(k+2))}

satisfies:
* (i) T_k is r.e. and has an index e_k with K(e_k) ≤ k + K(k) + c;
* (ii) every π ∈ Π₁\* with Bel₀(π) ≥ 2^(−k) lies in T_k;
* (iii) every π ∈ T_k has Bel₀(π) > 0 and is true. Hence B ∪ T_k is true, so consistent, and Σ₁-sound.

*Proof.*
* (i) Unif(V_π) is left-c.e. uniformly in π: enumerate pairs (tape prefix w, finite derivation of π from B and the sentences that G_U emits under prefixes of w), and add up the measure of the cylinders found. Membership in Π₁\* is decidable. So T_k is r.e. uniformly in (k, I′_k). A program for its index consists of:
  * a self-delimiting description of k (K(k) bits);
  * the k + 2 bits of I′_k (their number is known once k is known);
  * a fixed code.
* (ii) By F3(a), Unif(V_π) = Inc₀ + Bel₀(π) ≥ I′_k + 2^(−k) > I′_k + 2^(−(k+2)).
* (iii) If π ∈ T_k, then Unif(V_π) > I′_k + 2^(−(k+2)) > Inc₀, so Bel₀(π) = Unif(V_π) − Inc₀ > 0. So some tape has B ∪ A_ω consistent and proving π, and π is true by (Π₁T). ∎

**What the theorem says.** The universal random theory's Π₁ knowledge at confidence level 2^(−k) is contained in one *true* deterministic theory of complexity k + O(log k). The extra information that singles that theory out is k + 2 bits of the consistency probability Inc₀, the "Ω of consistency" of F3.

The proof uses only F3's decomposition Bel₀ = Unif(V) − Inc₀ and the fact that a positive-probability Π₁ proof is a truth certificate. Both are special to axiom induction:
* P1's M_F has no Inc₀;
* fresh-predicate literals carry no truth certificate.

**Sharpness inside the proof** (c3, T4). The same threshold set formed from Σ₁ sentences contained both members of an exclusive pair in every one of 300 random finite instances. The derandomisation fails at Σ₁ because consistent theories can affirm false Σ₁ sentences, and do so incompatibly.

### 4.3 Corollaries

**Corollary A2 (a coding theorem for Π₁ data)** [proved]. Let D be a finite data set whose literals D^± are Π₁\* sentences or true Σ₁ sentences. Then

  L_A(D) − c ≤ −log W_A(D) + c ≤ K_A(D) + c ≤ L_A(D) + K(⌈L_A(D)⌉) + 2c.

So on such data the three versions (one-tape, coin-free, Kolmogorov) agree within O(log L_A(D)).

*Proof.*
* The first two inequalities are F10(c).
* For the last, let k := ⌈L_A(D)⌉, so that M_A(D) ≥ 2^(−k).
* Write ψ_D ≡ π ∧ σ, where π is the conjunction of the Π₁\* literals and σ the conjunction of the true Σ₁ literals. Then B ⊢ σ by (Σ₁C), so Bel₀(π) = Bel₀(ψ_D) = M_A(D) ≥ 2^(−k).
* By A1, π ∈ T_k. Then B ∪ T_k is consistent and proves π and σ.
* So K_A(D) ≤ K(e_k) + c ≤ k + K(k) + c. ∎

*Contrast.* F11 gives two-atom data of a fresh predicate with K_A − L_A ≥ log d − O(1): no coding theorem in general. A2 says arithmetic truth admits no such gap at quantifier level 1. In particular, **true data of complexity at most Σ₁ ∪ Π₁ never separate the three versions by more than a logarithm.** Only false Σ₁ assertions (§4.5) or more complex sentences can.

**Corollary A3 (bounded loss on Π₁ streams is explained by one true theory)** [proved]. Let D_∞ be a stream with literals in Π₁\* ∪ {true Σ₁}, and suppose sup_n L_A(D_n) ≤ k. Then B ∪ T_k proves every datum. Moreover B ∪ T_k is true, its index has complexity ≤ k + K(k) + c, and the coin-free loss satisfies sup_n (−log W_A(D_n)) ≤ k + K(k) + c. So scout F's Q1 holds on such streams, with an explicit bound.

*Proof.* Apply A1 to each ψ_{D_n}, as in A2. The theory T_k does not depend on n. ∎

**Corollary A4 (Chaitin's incompleteness theorem for random theories)** [proved; formalisation of the Kleene T-predicate standard].

Let T(p, t, y) be a Δ₀ formula saying "t codes a halting computation of V on p with output y", where V is the fixed universal prefix machine. Let

  κ(x, m) := ∀p ∀t ¬(|p| ≤ m ∧ T(p, t, x̄)).

So κ(x, m) is a Π₁ sentence, true iff K(x) > m. Then:
* (a) for every x, L_A({(κ(x,m), 1)}) ≥ m − K(m) − 2 log m − c (and = ∞ if K(x) ≤ m);
* (b) for every x with K(x) > m, L_A({(κ(x,m), 1)}) ≤ K_A({(κ(x,m), 1)}) ≤ m + K(m) + c.

The upper bound is witnessed by *one* true theory, of complexity m + K(m) + c, that proves κ(x, m) for every x with K(x) > m simultaneously.

*Proof.*
* *Chaitin's argument for deterministic theories.* Let B ∪ W_e be consistent and prove κ(x, m).
  * The program "given e and m, enumerate the theorems of B ∪ W_e and output the first z such that κ(z, m) appears" halts. Its output z satisfies K(z) ≤ K(e) + K(m) + c.
  * κ(z, m) is a Π₁ sentence proved by a consistent extension of Q, so it is true by (Π₁T), and K(z) > m.
  * Hence K(e) > m − K(m) − c, and K_A({(κ(x,m),1)}) > m − K(m) − c.
* *(b).* Let s_m be the largest halting time of V on programs of length ≤ m, and let β_m be the true Π₁ sentence ∀p ∀t ∀y (|p| ≤ m ∧ T(p, t, y) → t ≤ s̄_m).
  * For x with K(x) > m, the sentence ∀p ≤ P ∀t ≤ s̄_m ¬T(p, t, x̄), where P bounds the codes of programs of length ≤ m, is a true Δ₀ sentence. So Q proves it.
  * With β_m it gives κ(x, m). So B ∪ {β_m} is true and proves every true κ(·, m).
  * s_m is computable from m and h_m := #{p : |p| ≤ m, V(p)↓} < 2^(m+1): run all such programs until h_m have halted. So K(β_m) ≤ K(m) + m + 1 + c.
* *(a).* For K(x) ≤ m the datum is false Π₁ and M_A = 0 by (Π₁T). Otherwise:
  * combine A2 with the deterministic bound: L_A + K(⌈L_A⌉) + c ≥ K_A > m − K(m) − c;
  * by (b), L_A ≤ m + K(m) + c, so K(⌈L_A⌉) ≤ 2 log m + c′. ∎

*Reading.* The datum (κ(x, m), 1) carries at most one bit of label information:
* unconstrained SFI predicts it at O(1) by "always accept";
* scout F's general lower bound F17 is O(1) here.

Yet the axiom inducer, and consistent SFI by F8, pay m ± O(log m) bits for it, whether the hypotheses are random or deterministic. Two consequences:
* The cost is the price of the consistency constraint at Π₁. Every Π₁ affirmation must be backed by a true theory, and a true theory that proves high complexity lower bounds must contain the corresponding halting information.
* Paying it once pays for all such data at level m. This is a clean, machine-independent instance of the brief's "laws versus data": one m-bit Π₁ law (β_m) explains all true complexity lower bounds at level m.

*Relation to the literature.* Bienvenu, Romashchenko, Shen, Taveneaux and Vermeeren (2014; scout L: bienvenu2014axiomatic [B, A, S]) add *randomly chosen* true axioms "C(x) > n" to PA, and show that this does not help prove new interesting theorems. Scout L also reports [S] that adding all true statements "C(x) > n" proves every true Π₁ sentence, and that one carefully chosen statement per n suffices.

A1 and A4 are the universal-mixture counterpart:
* the *universal* random theory, mixing over all random theory machines including inconsistent ones, proves a fixed Π₁ sentence with probability ≥ 2^(−k) only if a true theory of complexity k + O(log k) proves it;
* a fixed complexity lower bound costs m ± O(log m).

I could not read the paper. Whether A1 is implicit in it should be checked when web access returns (§9).

**Proposition A6 (scout F's Q2 for Π₁-axiomatised theories)** [proved]. Let T be an r.e. set of Π₁\* sentences, all true, and put k := ⌈−log ΠExt(T)⌉, where ΠExt(T) := Unif{ω : B ∪ A_ω consistent and ⊢ T}. Then

  −log ΠExt(T) − c ≤ −log m(Ext(T)) ≤ −log ΠExt(T) + K(k) + c.

*Proof.*
* *Right inequality.* Every π ∈ T has Bel₀(π) ≥ ΠExt(T) ≥ 2^(−k), so π ∈ T_k by A1. So B ∪ T_k is consistent and proves T, i.e. e_k ∈ Ext(T), and m(Ext(T)) ≥ m(e_k) ≥ 2^(−k − K(k) − c).
* *Left inequality.* Tapes beginning with a program for the deterministic theory machine of W_e, for e ∈ Ext(T), give consistent extensions. Their measure is ≥ 2^(−c)·Σ_{e ∈ Ext(T)} m(e) (as in F10(c)). ∎

So for true Π₁ theories the random tape buys at most a logarithm in the probability of their extensions. Q2 for the exact class [T], and for general T, stays open.

### 4.4 Where the random tape helps

Putting §3, §4 and F11 together:

| data | can one-tape M_A beat coin-free W_A or K_A by more than O(log)? | reason |
|---|---|---|
| Π₁\* sentences and true Σ₁ sentences (true background ⊇ Q) | **no** (A2, A3) | positive probability certifies truth; truths are jointly consistent |
| literals of a fresh predicate | yes on finite data (F11); not "bounded against unbounded" on a stream (E2) | binary consistency; majority vote works on streams |
| sentences with inconsistency constraints of unbounded arity | yes, even bounded against unbounded on one stream (E1) | lottery: majority vote is inconsistent |
| false Σ₁ assertions | yes on finite data (A5, proof sketch) | consistent theories can affirm false Σ₁ sentences, incompatibly |

### 4.5 Sharpness: a single false Σ₁ datum breaks the coding theorem

**Proposition A5** [proof sketch, given (FLEX)].

*(FLEX)* [recalled, unverified: Kripke's "flexible formulas" (1962); Woodin's universal algorithm (2011)]. For B true and ⊇ PA, there is a Σ₁ formula Φ(x), false of every number in ℕ, such that B + ∀x(Φ(x) ↔ x ∈ F) is consistent for every finite F ⊆ ℕ.

*Claim.* Given (FLEX), for every d ≥ 2 there are distinct x₁, x₂ ∈ {0,1}^d such that the data D := {(σ_{x₁}, 0), (σ_{x₂}, 1)}, with σ_x := Φ(x̄), satisfy:
* K_A(D) ≥ log d − 2;
* L_A(D) ≤ 2 + c.

The literal ¬σ_{x₁} is a true Π₁\* sentence. The literal σ_{x₂} is a *false* Σ₁ sentence.

*Sketch.*
* Every finite pattern {σ_x^{b_x} : x ∈ F′} is B-consistent: apply (FLEX) to F := {x ∈ F′ : b_x = 1}.
* So the theory machine that emits σ_x^{b_x} for independent fair coins b_x over all x has a consistent theory on every tape, by compactness. It proves D with probability 1/4, which gives L_A(D) ≤ K(that machine) + 2 + c.
* The colouring argument of F11(i) applies verbatim with σ_x in place of R(t_x).

*What is missing.* A verified statement of (FLEX) with the needed uniformity. The rest is as in F11.

**Open (A-Q1).** Do *true* Σ₂ or Π₂ data admit a coding theorem? A1 fails there: consistent extensions of Q can prove false Π₂ sentences. I do not know whether a gap can be produced with true data.
