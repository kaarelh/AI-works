# Scout N2 (new directions): formalising the philosophy of science

*Scout record for the paper on Solomonoff axiom induction (working name; no argument here depends on the name). Folder: `research/scouts/novel-science/`. Brief: `../../00-brief.md`, read in full, including its epistemic policy (the author's philosophical claims are hypotheses to assess). Sources read: every note in `../../prior/` (including `hanni-condensation-concepts.md`); in `/home/user/kaarelh/notes`, the folders `philosophy/philosophy of science/` and `philosophy/prediction/` (all notes listed there were opened; the two quoted below are `the domain of applicability of a scientific mode(l).md` and `playing t-complexity against k-complexity.md`); the sibling scouts' records `../fundamentals/notes.md` (§0, §1), `../sfi/notes.md` (§0, §1), `../philosophy/notes.md` (§0–§2, §5, §6) and `../literature/notes.md` (§0); SFI Paper 2 (`../../../../solomonoff-function-induction/paper-steeper/sections/{abstract,setup,kinks,recovery}.tex`); the earlier report's short-derivations record (`../../../../axiom-induction/research/tracks/short-derivations/notes-final.md`, §0–§1).*

*Scripts are in `checks/`. Each is seeded (seed 20261015) or deterministic and writes `<name>.out` next to itself. No git command that changes repository state was run.*

**Status tags.**
* **[proved]**: a full proof is given here.
* **[proved, given X]**: the proof uses the cited result X.
* **[proof sketch]**: the argument is given and the missing steps are named.
* **[computed: script, part]**: the script and its saved output are named.
* **[known: key]**: a published result whose bibliographic data were verified by scout L or scout P (their `refs.bib`); the content status is theirs.
* **[recalled, unverified]**: a published result recalled from memory. This session's web-search budget was exhausted (the shared limit of 200 calls had been used by the time this scout ran) and direct fetches of publisher pages were refused by the proxy, so none of these could be checked. No result marked [proved] depends on them.
* **[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample).
* **[assessment]**: a considered judgement argued in the text, not a theorem.

**Notation.** AI is axiom induction (proof-requiring unless stated). SOI is Solomonoff operator induction (the companion papers; older records say SFI). B is the background theory. A *question* is a sentence of the base language, or a pair (α, ℓ) "given α, is ℓ the case?". "Scout P", "scout F", "scout S", "scout L" are the sibling records named above. "Paper 2" is the steeper-prior paper; its hull lemma, kink lemma and corollaries are cited by their LaTeX labels. Logarithms are base 2.

---

## 0. Ranked list

The four pushed directions come first; the full list of nineteen candidates, each with a statement, a first pass and an assessment, is §1. Scores in §1 are on a 1–5 scale (5 = high) for difficulty, novelty, coolness and relevance; "truth" is the status.

1. **P1. Where the know-how lives: theory size is relative to the reasoner (§2).** For a linear law over GF(2) (k equations in n variables), questions "given these values, what is that one?" in every direction:
   * a reasoner that can do Gaussian elimination needs only the k equations;
   * a unit-propagation reasoner (applies one rule at a time), with a clausal theory in the base vocabulary, needs at least A_d·2^(d−1) clauses, where d is the least weight of a derived equation and A_d the number of such equations [proved]; for the simplex family this is n·2^((n−1)/2) clauses against log₂(n+1) equations [proved; computed];
   * intermediate concepts (auxiliary variables: partial parities) make one law linear-size and usable by unit propagation [proved], but not a system of laws: the core answers 74–81% of sampled questions fully at n = 12–20 [computed], and in general no polynomial-size usable encoding exists even with auxiliary variables [recalled, unverified: Gwynne–Kullmann];
   * under the earlier report's charged-deduction model, which charges derivation *size* but not the *search* for derivations, the know-how hides in the free search; a decider-given axiom set can also carry it in its membership procedure (Craig's shape) [proved].

   **Status:** proved (no auxiliary variables; one law with them), computed, one recalled result. **Why first:** it makes the textbook point a theorem with exact numbers, answers the brief's "what a theory is" question for one natural class (the separation is between *reasoners*, and between languages with and without intermediate concepts, not between declarative and procedural *shapes*: directed rules cost exactly a factor of the number of directions without intermediate concepts and a factor ≤ 3 with them [proved]), and it says exactly what the earlier report's short-derivation results do and do not model.
2. **P3. Approximate theories: regimes, honest laws against laws with exceptions, horizons (§3).**
   * With guaranteed tolerances, an exact but false law survives exactly while δ ≥ ε* + δ₀ [proved]; with rounded data it is refuted after about 1/p data, p = E min(|e|/h, 1), however coarse the data [proved; computed]. Precision belongs to the data set, not to the datum.
   * In the two-part code with exceptions, four theories compete: the exact law, the exact law with listed exceptions, the honest law "within ε", and the better theory. **The honest law beats the law-with-exceptions iff λ·(cost of naming an exception) > c_f·(2κ − 1)**, κ = sup|e| / E|e| the peakedness of the error, for data coarser than 2ε* [proved for expected costs; computed]. Spread-out errors give honest approximate laws, which are silent at fine precision; concentrated errors give "exact laws with exceptions", which are overconfident. A steeper prior favours honesty.
   * An honest approximate dynamical law answers only within a derivation horizon: ⌊δ/ε⌋ steps for non-expanding dynamics, logarithmic in δ/ε for expanding ones [proved for linear maps; computed]. Approximation and bounded derivation are linked.

   **Status:** proved and computed. **Why:** it turns "Kepler is only approximately right" into exact selection statements, makes the trichotomy the formal home of humility, and corrects a too-simple reading of the brief's precision seed.
3. **P2. The best system as a steeper MAP: laws, initial conditions, contingent facts (§4).** In the two-part code (law part charged λ per bit, unproved data stated literally):
   * every module of a λ-MAP explains at least λ bits of data per bit, and no addition explains more [proved];
   * a fact used only for itself never enters for λ > 1 [proved];
   * in a solar-system toy, a body's elements enter iff c·n_b > λk, and the law enters iff the bodies it serves have total surplus Σ(c·n_b − λk) above λL [proved; computed].

   So **the model–randomness split does not separate laws from initial conditions**: the planets' elements are "model", reused hundreds of times per bit. What it separates is reused facts from facts used once. What singles out laws is how their explanatory power scales: with the number of systems (m·n·c/L), not with the observations per system (n·c/k). Lewis's hope that nature is "kind" (the best system is robust to the balance of simplicity and strength) is exactly a steep kink, and it is computable: in the toy, "law + 8 planets" is the best system for every λ ∈ (7.0, 135.4) [computed]. **Status:** proved and computed (elementary). **Why:** it settles the brief's laws-versus-initial-conditions seed (partly negatively), gives the best-system account a precise form, and defines explanatory power as a deletion slope.
4. **P4. What a law is worth to raw-data prediction and to question answering (§5).** In a world of micro-states with a conserved quantity:
   * the law saves ½·log₂(πm/2) bits per step of raw-data loss, a fraction → 0 of the m bits per step [proved]; it saves all of the question-answering loss on "what is the conserved quantity now?" [proved];
   * a raw-data Bayes mixture learns the law at a cost of 1 bit [computed];
   * certifying the law from a black-box raw-data predictor needs 2^m queries [proved].

   So the formal difference between the tasks is the *target* (which losses count) and the *cost of extracting answers*, not what must be learned. **Status:** proved and computed. **Why:** it is the clean formal content of "mechanics barely helps pixel prediction", with the right caveat, and it agrees with the brief's conclusion that what separates theories from predictors is reasoner-relative.

**Also promising, first pass only (§1):** explanation by approximate correction (C19: an honest approximate law is exactly what a successor theory can derive); explanatory asymmetry (C13: a tie in code length, broken only by interventional questions); retention of superseded theories by usage cost (C17); domains of applicability (C16); old evidence as confirmation by new derivations (C14); underdetermination (C18); Duhem–Quine blame (C15).

**One "Possible error in the author's view"** (§7): the domain-of-applicability note's doubt that any nice formal criterion blocks catastrophic reasoning with approximate models. A sound criterion exists (honest tolerances, propagated); what it lacks is fidelity to practice, because it is worst-case.

---

## 1. The candidates

Each entry has a statement, a first pass, and an assessment. C1–C12 belong to the four pushes and are developed in §§2–5; C13–C19 are first passes only.

| # | candidate | push | status | difficulty | novelty | coolness | relevance |
|---|---|---|---|---|---|---|---|
| C1 | precision regimes: guaranteed tolerances against rounding | P3 | proved; computed | 1 | 2 | 3 | 5 |
| C2 | honest approximate law against law with exceptions (κ criterion) | P3 | proved (expected costs); computed | 2 | 4 | 4 | 5 |
| C3 | derivation horizon of approximate laws | P3 | proved (linear); computed | 2 | 2 | 3 | 4 |
| C4 | reasoner-relative theory size for linear laws | P1 | proved (no aux); computed; recalled (aux) | 3 | 3 | 5 | 5 |
| C5 | directionality is cheap; intermediate concepts | P1 | proved | 1 | 3 | 4 | 5 |
| C6 | three homes of know-how; relation to charged deduction | P1 | proved | 2 | 4 | 4 | 5 |
| C7 | steeper best system: marginal-slope characterisation | P2 | proved | 1 | 2 | 3 | 5 |
| C8 | laws, initial conditions, contingent facts | P2 | proved; computed | 1 | 3 | 4 | 5 |
| C9 | Lewis's kind nature as a kink; trivialisation | P2 | proved, given Paper 2 and the coding bound | 1 | 3 | 4 | 4 |
| C10 | explanatory power as a deletion slope | P2 | definition; proved inequalities | 1 | 2 | 3 | 4 |
| C11 | a law's share of raw-data loss and of question loss | P4 | proved; computed | 1 | 2 | 3 | 5 |
| C12 | certification and extraction gap | P4 | proved; known (Rice) | 1 | 1 | 2 | 4 |
| C13 | explanatory asymmetry | – | proved (elementary) | 1 | 1 | 3 | 4 |
| C14 | old evidence: confirmation by new derivations | – | proved (trivial) | 1 | 1 | 3 | 3 |
| C15 | Duhem–Quine blame under a product prior | – | proof sketch | 2 | 1 | 2 | 3 |
| C16 | domains of applicability | – | proved (trivial) | 1 | 2 | 2 | 4 |
| C17 | retention of superseded theories by usage cost | – | proved (trivial) | 1 | 3 | 3 | 4 |
| C18 | underdetermination: empirically equivalent theories | – | proved (trivial) | 1 | 1 | 2 | 3 |
| C19 | explanation by approximate correction | – | proof sketch | 4 | 3 | 4 | 5 |

### C1. Precision regimes

**Statement.** A quantity q(t); an exact law f_K with error e(t) := f_K(t) − q(t), ε* := ess sup |e|; data are true interval sentences.
* (G) *Guaranteed tolerance:* "q(t) ∈ [v − δ, v + δ]" with |v − q(t)| ≤ δ₀ ≤ δ.
* (R) *Rounding with dither:* "q(t) ∈ cell", cells of width h with a random offset per datum.

Then (G): the exact law is compatible with every datum, for every n, iff δ ≥ ε* + δ₀ (for the worst-case measurement errors); with i.i.d. errors whose support reaches ±δ₀, it is a.s. refuted eventually iff δ < ε* + δ₀. (R): Pr[exact law survives n data] = (1 − p_h)ⁿ, p_h := E min(|e(t)|/h, 1).

**First pass.** Proved in §3.1; computed in `checks/n3_precision_phases.out` parts A, B.

**Assessment.** True; easy. Novelty low: monotonicity in δ and the switch point are in scout P (§2.4); the rounding regime and its consequence are new here. Coolness moderate: **under rounding, proof-requiring AI refutes every exact-but-false law however coarse the data.** That is correct (the data are true sentences and the law is false), and it shows that "approximately true" laws survive in AI only against guaranteed tolerances. Relevance high (Kepler).

### C2. Honest approximate law against law with exceptions

**Statement.** In the two-part code with exceptions (consistency required; §3.2), with fine data at cell width h:
* exact law with patches: λ·(cost of naming each refuted datum) + c_f per refuted datum;
* honest law "within ε*": c_f per fine datum it cannot prove;
* better theory: a one-off cost.

For h ≥ 2ε*, the honest law has the lower expected cost per datum iff λπ_c > c_f(2κ − 1), where κ := sup|e| / E|e| and π_c is the cost of naming an exception. For h → 0, iff Pr[e ≠ 0] > c_f/(λπ_c + c_f).

**First pass.** Proved in §3.2 (for expected costs); the phase diagrams for a spread-out error (κ = π/2) and a concentrated one (κ = 20) are in `n3` part C.

**Assessment.** True. Moderate difficulty. Novelty: we found no statement of this criterion, but no search could be run in this session. Coolness high: it says **when an inexact law should be kept as "exact with exceptions" (ceteris paribus) and when as "approximately true"**, and it ties honesty to the trichotomy. Relevance high.

### C3. Derivation horizon

**Statement.** For an honest approximate law "|x_{s+1} − F(x_s)| ≤ ε" with F L-Lipschitz, and an initial condition "|x₀ − a| ≤ e₀", the derived tolerance after r steps is e_r = L^r·e₀ + ε(L^r − 1)/(L − 1) (and r·ε + e₀ for L = 1). For linear F, no tighter statement is derivable. So a datum at precision δ is provable only within r*(δ) steps: δ/ε for L = 1, and about log_L(δ(L − 1)/ε) for L > 1.

**First pass.** Proved in §3.3 (soundness for every Lipschitz F; tightness for linear F); computed in `n3` part D.

**Assessment.** True; easy; known in substance (Lyapunov times, validated numerics). The reading is new: **an approximate law's domain of applicability includes a bound on derivation length**, which links P3 to P1. Relevance: the author's domain-of-applicability note (§7).

### C4. Reasoner-relative theory size for linear laws

**Statement.** For V = {x ∈ GF(2)^n : Ax = b} and all conditional literal questions:
* the k equations suffice for a Gaussian-elimination reasoner;
* every clausal theory over the base variables needs ≥ (1 − 2^(−k))·2^d clauses;
* every unit-propagation-usable one needs ≥ A_d·2^(d−1) (d ≥ 3);
* with auxiliary variables, a usable theory of size O(n·#circuits) exists.

**First pass.** Proved in §2.2–2.4; computed in `n1` parts E2, E5, E7, E8.

**Assessment.** The bounds are elementary and probably folklore in knowledge compilation (succinctness against polynomial-time queries; propagation-complete encodings) [recalled, unverified: Darwiche–Marquis 2002; Bordeaux–Marques-Silva 2012]. Coolness and relevance high: this is the textbook point with numbers.

### C5. Directionality is cheap; intermediate concepts are not

**Statement.** Under a fixed rule-applying reasoner, a directed-rule (procedural) theory and a clausal (declarative) theory differ in size by at most the maximum clause width. For one parity law without auxiliary variables, every direction-complete set of directed rules has exactly n·2^(n−1) rules against 2^(n−1) clauses: a factor of n, the number of directions. With n − 2 auxiliary variables, both are linear (4n − 6 clauses, 3(4n − 6) − 2 rules).

**First pass.** Proved in §2.5.

**Assessment.** True; easy; the reading is new. It gives the brief's sought separation ("length growing with the number of query directions") in a format without intermediate concepts, and shows it disappears with them. Relevance: the brief's "what a theory is".

### C6. Three homes of know-how

**Statement.** The know-how needed to answer questions with bounded effort must be paid for in one of three places:
* (i) the reasoner's procedure (Gaussian elimination);
* (ii) explicit lemmas (exponentially many for unit propagation);
* (iii) free search for derivations, which the earlier report's charged-deduction model does not charge, possibly combined with an axiom-membership procedure that embeds the method (Craig's shape).

**First pass.** Proved in §2.6.

**Assessment.** True. Novel in form. It locates the earlier report's short-derivation theorems precisely: they model a reasoner with free nondeterministic search (fit class NP ∩ coNP under total material [known from the earlier report via scout S, I19]), so they cannot express the textbook point, which is about a reasoner that must *find* answers.

### C7. Steeper best system: marginal slopes

**Statement.** In the two-part objective J_λ(T) = λ|T| + X(T; D) (X: literal cost of the data T does not prove, ∞ if T is inconsistent with D), with an additive code for axiom sets: every module A of a λ-MAP has deletion slope (X(T∖A) − X(T))/|A| ≥ λ, and every addition B has slope (X(T) − X(T ∪ B))/|B| ≤ λ.

**First pass.** Proved in §4.1.

**Assessment.** Trivial but the right definition of "pulls its weight" for Lewis. Relevance high.

### C8. Laws, initial conditions, contingent facts

**Statement.** In the toy family (law, K3, elements of a set S of bodies), the λ-MAP is S*(λ) = {b : c·n_b > λk_b}, with the law included iff Σ_{b∈S*}(c·n_b − λk_b) > λL. The law's deletion slope scales as m·n·c/L, the elements' as n·c/k.

**First pass.** Proved in §4.2; computed in `n2` (agreement with brute force in 210/210 cases; thresholds and hull).

**Assessment.** True; easy. It corrects the brief's seed: the steeper split does not put orbital elements on the noise side. Relevance high.

### C9. Lewis's kind nature; trivialisation

**Statement.**
* (a) "The best system is the same under every balance in an interval" holds iff the hull of (|T|, X(T)) has a kink there (Paper 2, `thm:kink:converse`).
* (b) No vocabulary extension yields a two-part description of base-language data shorter than K(answers | questions) − O(1) (the coding bound), so Lewis's gerrymandered predicate F with axiom ∀x Fx buys nothing.

**First pass.** §4.3.

**Assessment.** (a) proved, given Paper 2; (b) proved, given the coding bound. Novelty moderate (the relativisation of best systems to a vocabulary is known [known: cohen2009better]). Coolness: Lewis's informal hope becomes a checkable property of the data.

### C10. Explanatory power as a deletion slope

**Statement.** EP_D(A; T) := (X(T∖A; D) − X(T; D))/|A|, bits of data explained per bit of axiom; a unification is a module with EP > 1 that replaces several modules.

**First pass.** §4.4: definitions, the inequalities of C7, and the Copernicus–Ptolemy coincidence as an instance.

**Assessment.** Definitional; close to ILP compression and to Myrvold's measure [known: myrvold2003bayesian, verified by scout L], as scout L already notes. Coolness moderate.

### C11. A law's share of raw-data loss and of question loss

**Statement.** Micro-states x ∈ {0,1}^m with uniformly random weight-preserving dynamics. Knowing the conservation law saves log₂(2^m − t) − log₂(C(m, m/2) − t) → ½·log₂(πm/2) bits per step of raw-data loss, a fraction O(log m/m) of it. On the questions "what is |x_t|?" it saves log₂(m + 1) bits per question, all of the loss.

**First pass.** Proved in §5.1; computed in `n4`.

**Assessment.** True; easy. It formalises the author's "mechanics barely helps pixel prediction", with the caveat that the law's *absolute* value is comparable in the two tasks (≈ ½·log m against log m bits per step). Relevance high.

### C12. Certification and extraction gap

**Statement.**
* Deciding "∀x |π(x)| = |x|" from black-box access to π needs 2^m queries in the worst case.
* For dynamics given as programs, universal laws are undecidable (Π₁).
* The question-answering inducer's belief in a law ("some theory proves it") is a different quantity from the predictor's "all future data conform" (the earlier report's ω-gap).

**First pass.** §5.2.

**Assessment.** True; standard. Its use is to say exactly what "cannot be extracted without extra search" means.

### C13. Explanatory asymmetry (first pass)

**Statement.** Flagpole: theories T_H (law + "height of pole p is h_p") and T_S (law + "shadow of p at the reference elevation θ₀ is s_p").
* (a) On observational data they prove the same data. With a reference elevation of 45° (cot θ₀ = 1, so s_p = h_p) their lengths differ by O(1); in general by the cost of naming θ₀ and writing s_p = h_p·cot θ₀. So their posterior odds never move.
* (b) Under derivation-length charges, T_S needs one extra step per datum (or one lemma, which is the height axiom itself); in a language whose primitive is "shadow at θ₀", the roles flip.
* (c) With interventional questions in the language ("if the shadow is changed by blocking light, does the height change?"), the structural theory with S exogenous is refuted by one datum.

**First pass [proved, elementary].**
* (a) T_S ⊢ h_p = s_p·tan θ₀, and conversely T_H proves the shadow at θ₀; the two theories are interderivable given θ₀.
* (b) Counting steps.
* (c) The reversed structural equation predicts that the height changes under an intervention on the shadow.

**Assessment.** True; easy; low novelty (interventionist accounts [known: woodward2003making]). Relevance: it supports scout P's verdict E1. Derivation from axioms captures explanation only up to direction, and direction enters with interventional *questions*: the language matters (ladder step 2 with a richer language). Coolness moderate.

### C14. Old evidence: confirmation by new derivations (first pass)

**Statement.** Under derivation-budgeted AI (a datum counts as proved only through a derivation of size ≤ h), Bel_{D,h}(T) can rise when h rises, with no new data.

**First pass [proved, trivial].** Compatibility is monotone in h; the posterior of a theory that becomes compatible jumps from 0. Mercury's perihelion and general relativity is the historical shape.

**Assessment.** Known in spirit [known: garber1983old]. Novelty low. Relevance moderate. Logical induction handles the same phenomenon (scout L §3.2).

### C15. Duhem–Quine blame (first pass)

**Statement.** With a product prior over a finite pool of axioms, after a refutation of a joint prediction, the posterior probability that axiom A_i is retained is higher the more independent support A_i has (the more other data need it).

**First pass [proof sketch].** The posterior over subsets is the prior restricted to compatible subsets, and the marginal of each axiom is a ratio of sums over these. The comparative claim needs a monotonicity argument over the lattice of compatible subsets, which is not written out. Bayesian treatments of the Duhem problem exist [recalled, unverified: Dorling 1979; Strevens 2001].

**Assessment.** True in examples; low novelty; relevance moderate (piecemeal confirmation, scout P item 5).

### C16. Domains of applicability (first pass)

**Statement.** In the two-part code, restricting a law to a definable domain Dom (axiom "Dom(b) → law(b)") pays iff |Dom| plus the cost of the excluded bodies' data is less than the cost of the exceptions the unrestricted law would need.

**First pass [proved, trivial].** Compare the two objectives. On scout P's data, the Moon (1.1° off a fixed ellipse within a month [computed by scout P, c1]) is excluded by a domain axiom when "planet" is a base predicate (O(1) bits), or by naming it (log₂ of the number of bodies).

**Assessment.** True; easy; relevant to the domain-of-applicability note; low coolness. A learnable-domain theorem on a richer pool is scout P's Q8.

### C17. Retention of superseded theories by usage cost (first pass)

**Statement.** If data are charged per derivation symbol at rate κ, a superseded theory with short derivations (Kepler; Newtonian mechanics after relativity) stays the MAP on coarse data in its domain while κ·Σ(derivation savings) exceeds the length difference plus the fit gained by the better theory.

**First pass [proved, trivial].** Linear comparison of the two objectives.

**Assessment.** True; easy. The reading is useful: a domain of applicability is *where the cheaper theory is good enough*, which is how practice treats Newtonian mechanics. It connects P1 (usage costs) with P3 (accuracy).

### C18. Underdetermination (first pass)

**Statement.** If T and T′ have the same consequences in the base language, their posterior odds equal their prior odds on every data set; with Craig, an observational axiomatisation is O(1) longer (scout F, language-expansion invariance).

**First pass [proved, trivial]:** compatibility depends only on base-language consequences.

**Assessment.** True; trivial. Its use: AI's preference among empirically equivalent theories is the prior's alone, so the posterior over their *theoretical* claims never moves. This is the formal version of the antirealist's "pragmatic choice". It does not settle the author's argument against antirealism (`phil-sci-an-argument-sorta-against-antirealism.md`), which is about whether one can coherently "step outside" one's theory.

### C19. Explanation by approximate correction (first pass)

**Statement.** Let T_N be Newtonian gravity plus initial conditions, and K_ε(W) the honest Kepler law "each orbit is within ε of a fixed ellipse on the window W". For suitable ε(W), T_N ⊢ K_ε(W), whereas T_N ⊢ ¬K₀ (the exact law). So the honest form of an approximate law is exactly what its successor *explains*. The exact form is contradicted, which is Duhem's point [scout P, E2].

**First pass [proof sketch].** A perturbation bound or a validated integration gives the derivation; scout P (§2.5–2.6) estimates that it is long, and computes the size of ε(W) (Table 2.1 there).

**Assessment.** Probably true for every window with a nonempty interior. Hard to carry out formally (existence and uniqueness, validated bounds). Coolness high: **honesty (tolerance) is what makes an approximate law both humble (C2) and explicable (C19)**, the formal form of Schaffner's corrected reduction [known: schaffner1967approaches]. Relevance high (claim E2 of scout P).

---

## 2. Push P1: where the know-how lives

### 2.1 Setting

**Definition 2.1 (law, questions, theories, reasoners).**
* **Law.** Base variables x_1, …, x_n (propositional atoms, or ground atoms of a first-order language). The law is the affine subspace V = {x ∈ GF(2)^n : Ax = b}, with A of rank k and V ≠ ∅.
* **Derived equations.** The derived equations of V are the *dual code* C⊥ := rowspace(A). For u ∈ C⊥, u·x takes a constant value c_u on V.
  * d := the minimum weight of a nonzero u ∈ C⊥;
  * A_d := the number of such u;
  * a *circuit* is a nonzero u ∈ C⊥ whose support contains the support of no other nonzero codeword.
* **Questions.** Q(V) is the set of pairs (α, ℓ) such that α is an assignment to a set S of base variables consistent with V, ℓ is a base literal on a variable outside S, and V ∧ α ⊨ ℓ.
* **Explicit theories.** An explicit theory is a finite set F of clauses over the base variables and finitely many *auxiliary* variables (theoretical terms) whose projection to the base variables is V, i.e. ∃aux F ≡ V. Its size is its number of clauses.
* **Reasoners.**
  * UP (unit propagation) answers (α, ℓ) iff UP(F ∪ α) contains ℓ.
  * GE (Gaussian elimination) applies to theories written as linear equations; it answers (α, ℓ) by solving.
  * F is *R-usable* if R answers every question in Q(V).
* **Clause notation.** For a set T of variables and an assignment β to T, C_{T,β} is the clause over T falsified exactly by β.

The AI reading: take AI over explicit theories with a reasoner R. A theory is compatible with data D ⊆ Q(V) (question–answer pairs) iff it is consistent with each question's α and R derives each answer. On D = Q(V), the compatible theories are exactly the R-usable ones, so the smallest compatible theory is the smallest R-usable one.

**Lemma 2.2 (determination) [proved].** For S ⊆ [n] and j ∉ S, the following are equivalent:
* (i) x_j is a function of x_S on V;
* (ii) some u ∈ C⊥ has j ∈ supp(u) ⊆ S ∪ {j};
* (iii) some circuit c has j ∈ supp(c) ⊆ S ∪ {j}.

*Proof.*
* (ii)⇒(i): x_j = c_u + Σ_{i ∈ supp(u)∖{j}} x_i on V.
* (i)⇒(ii): If no such u exists, then e_j ∉ C⊥ + span{e_i : i ∈ S}. So there is a vector z with z·e_j = 1, z·e_i = 0 for i ∈ S, and z ⊥ C⊥, i.e. z ∈ ker A. For x ∈ V, x and x + z both lie in V, agree on S and differ at j.
* (ii)⇒(iii): Take u with minimal support among the codewords with j ∈ supp(u) ⊆ S ∪ {j}. Suppose a nonzero u′ had supp(u′) ⊊ supp(u). If j ∈ supp(u′), minimality fails. Otherwise u + u′ has support supp(u)∖supp(u′), which contains j and is strictly smaller, and minimality fails again. So u is a circuit.
* (iii)⇒(ii): Immediate. ∎

`n1` E1 checks (i)⇔(ii) against brute-force entailment on three random systems with n = 8 (6144 cases, no mismatch) [computed].

### 2.2 Prime implicates, and the cost of having no intermediate concepts

**Proposition 2.3 (prime implicates of a linear law) [proved].** The prime implicates of V are exactly the clauses C_{supp(u),β}, where u is a circuit and β is an assignment to supp(u) with u·β ≠ c_u. There are Σ_circuits 2^(|u|−1) of them. The set PI(V) of all prime implicates is UP-usable, and it answers every question in one propagation step.

*Proof.*
* *Each such clause is an implicate.* Every x ∈ V has u·x = c_u ≠ u·β, so x does not agree with β on supp(u).
* *Every implicate is subsumed by one of them.* Let C = C_{T,β} be an implicate. Then β ∉ proj_T(V), so some codeword u′ with supp(u′) ⊆ T is violated by β. Indeed proj_T(V) is the affine subspace cut out by the codewords supported in T: its defining functionals are the restrictions to T of the functionals constant on V, i.e. of C⊥. Decompose u′ into circuits as in Lemma 2.2. Parities add, so β violates one of them, a circuit u with supp(u) ⊆ T; C_{supp(u),β|} subsumes C.
* *The clauses are prime.* By the same argument, a strictly smaller implicate would be violated on a strictly smaller codeword support, contradicting minimality.
* *Usability.* If V ∧ α ⊨ ℓ, then by Lemma 2.2 there is a circuit u with j ∈ supp(u) ⊆ S ∪ {j}. The clause on supp(u) falsified by (α restricted, ¬ℓ) is in PI(V), and UP fires it. ∎

**Proposition 2.4 (no intermediate concepts) [proved].**
* (a) Every implicate of V has width ≥ d. Hence every CNF over the base variables equivalent to V has at least (1 − 2^(−k))·2^d clauses.
* (b) If d ≥ 3, every UP-usable CNF over the base variables contains, for every minimum-weight u ∈ C⊥, all 2^(d−1) clauses C_{supp(u),β} (u·β ≠ c_u). Hence it has ≥ A_d·2^(d−1) clauses.

*Proof.*
* (a) For |T| < d, proj_T(V) = GF(2)^T, because a proper projection would be cut out by a nonzero codeword of weight ≤ |T| < d. So no clause of width < d is an implicate. A clause of width w ≥ d excludes at most 2^(n−d) points of GF(2)^n, and the 2^n − 2^(n−k) non-solutions must all be excluded.
* (b) Fix u of weight d, j ∈ supp(u), S := supp(u)∖{j}, and an assignment α to S. Since |S| < d, α is consistent with V, and by Lemma 2.2 it determines x_j = v. UP on F ∪ α is sound and F ∪ α is satisfiable, so UP never derives a conflict. Usability requires UP to derive ℓ := (x_j = v), so UP derives some literal outside S.
  * The *first* such literal, on a variable i, comes from a clause C ∈ F whose other literals are all on S and falsified by α. So supp(C) ⊆ S ∪ {i}, and C is an implicate of V.
  * By (a)'s argument, some codeword u′ has supp(u′) ⊆ supp(C), and i ∈ supp(u′): otherwise supp(u′) ⊆ S has weight < d.
  * If i ∉ supp(u), then |u′| ≤ d forces supp(u′) = S ∪ {i}, and u + u′ has support {i, j}, of weight 2 < d: a contradiction.
  * So i = j and supp(u′) ⊆ supp(u). By minimality supp(u′) = supp(u) = supp(C), and C is the clause on supp(u) falsified by (α, ¬ℓ).
  * As α ranges over the 2^(d−1) assignments of S, these are all 2^(d−1) clauses C_{supp(u),β} with u·β ≠ c_u. Different u give different supports. ∎

**Checks [computed: `n1` E2, E8].**
* Four random dense systems (n = 9, k = 4):
  * every prime implicate has width ≥ d;
  * PI(V) answers all questions (exhaustive: up to 23,952 entailed literals);
  * for the two systems with d ≥ 3, deleting any single minimum-weight clause from PI(V) breaks usability (80/80 and 8/8 deletions).
* Simplex-dual systems: A is the m × (2^m − 1) matrix of all nonzero columns, n = 2^m − 1. Every nonzero dual codeword has weight (n + 1)/2, so every codeword is a circuit and the bound of (b) *equals* |PI(V)|. The smallest UP-usable theory without auxiliary variables is PI(V) itself.

| m | n | GE core | no-aux CNF, lower bound | smallest no-aux UP-usable theory | UP-usable with auxiliary variables (Prop 2.6) |
|---|---|---|---|---|---|
| 3 | 7 | 3 equations (24 bits) | 14 clauses | 56 clauses | 70 clauses |
| 4 | 15 | 4 equations (64 bits) | 240 | 1,920 | 390 |
| 5 | 31 | 5 equations (160 bits) | 63,488 | 1,015,808 | 1,798 |
| 6 | 63 | 6 equations (384 bits) | 4.2×10⁹ | 1.35×10¹¹ | 7,686 |
| 7 | 127 | 7 equations (896 bits) | 1.8×10¹⁹ | 1.2×10²¹ | 31,750 |

  For m = 3, deleting any one of the 56 clauses breaks usability (exhaustive).

### 2.3 Intermediate concepts: one law

**Proposition 2.5 (chain encoding) [proved].** Encode x_1 ⊕ … ⊕ x_n = c by the chain y_1 = x_1 ⊕ x_2, y_i = y_{i−1} ⊕ x_{i+1} (2 ≤ i ≤ n − 2), y_{n−2} ⊕ x_n = c. Each three-variable XOR is written as its 4 clauses and the last as 2 clauses: 4(n − 2) + 2 clauses with n − 2 auxiliary variables. The encoding is propagation complete on all variables: for every partial assignment α to base and auxiliary variables, UP derives every implied literal, and derives a conflict iff α is inconsistent. Without auxiliary variables, 2^(n−1) clauses are necessary (Prop 2.4(a) with k = 1, d = n) and sufficient.

*Proof.*
* Each small constraint's clause set derives the third variable when two are assigned and a conflict when all three are assigned inconsistently.
* Consider the UP fixpoint (no conflict). Every constraint is either fully assigned, hence satisfied, or has ≥ 2 unassigned variables.
* The constraint hypergraph is a hyperpath: consecutive constraints share exactly one auxiliary variable, and no variable is in more than two constraints. So the active constraints (those with ≥ 2 unassigned variables) form a forest.
* Fix any unassigned variable z and any value for it. Root the forest at a constraint containing z, if there is one, and process the constraints breadth-first. When a constraint is processed, at most one of its variables has already been set (the one it shares with its parent, or z at the root). Since it has ≥ 2 unassigned variables, at least one is still free: give the other free variables arbitrary values, and give this one the value that satisfies the constraint.
* This extends to a solution with either value of z. So z is not implied, and every implied literal was derived. If α were inconsistent and UP reached a conflict-free fixpoint, the same construction would build a solution: a contradiction. ∎

`n1` E4 checks this exhaustively for n = 3, …, 7 over all 3^(#variables) partial assignments, inconsistent ones included (up to 150,147 consistent ones) [computed].

**Reading [assessment].** In the clausal language, an intermediate concept (a partial parity) turns an exponentially long law into a linear one, *and* makes it usable by the weakest reasoner. This is a sharper form of scout P's Prop 5.1, where a factoring predicate saves nm − (n + m) implications, only polynomially. Partial sums are the textbook's intermediate quantities (momentum, energy, a running total), which make laws usable by simple propagation. That last sentence is an analogy, not a theorem.

### 2.4 Systems of laws

**Proposition 2.6 (a usable lemma library with intermediate concepts) [proved].** Let Circ_aux(V) be the union of the chain encodings of all circuits of C⊥, each with its own auxiliary variables. Then Circ_aux(V) is UP-usable, and its size is at most Σ_circuits (4|u| − 6) = O(n·#circuits) (circuits of weight ≤ 3 are written directly, with 2^(|u|−1) ≤ 4|u| − 6 clauses, or 4 for |u| = 3).

*Proof.*
* By Lemma 2.2, every question (α, ℓ) has a circuit u with j ∈ supp(u) ⊆ S ∪ {j}.
* The chain for u is propagation complete (Prop 2.5) and α fixes all of supp(u) except j, so UP on that chain alone derives ℓ. UP is monotone in the clause set.
* The union projects onto V (each auxiliary variable is a partial sum), so no conflict arises from a consistent α. ∎

**The core is not usable [proved; computed].**
* For x₁ ⊕ x₂ ⊕ x₃ = 0 and x₂ ⊕ x₃ ⊕ x₄ = 0, UP from x₁ = 1 derives nothing, although x₄ = 1 is implied; adding the derived law x₁ ⊕ x₄ = 0 (2 clauses) fixes it (`n1` E3). Gaussian elimination is needed to combine laws, and unit propagation cannot do it.
* On random sparse systems (row weight 3–4, k = n/2; `n1` E5, 3000 sampled questions each):

| n | core (clauses) | entailed literals derived | questions fully answered | lemmas needed for full usability |
|---|---|---|---|---|
| 12 | 28 | 0.886 | 0.809 | derived laws of weight ≤ 2: 34 clauses |
| 16 | 40 | 0.898 | 0.781 | weight ≤ 4: 118 clauses |
| 20 | 56 | 0.865 | 0.742 | weight ≤ 5: 1,178 clauses |

  The chain-encoded core (with auxiliary variables) answers exactly the same fraction as the direct core. So auxiliary variables in the *core* do not help with a system. Prop 2.6's library answers 100% of sampled questions at 476, 1,638 and 3,784 clauses on fresh systems of the same three sizes (`n1` E7).
* **[recalled, unverified]** Gwynne and Kullmann ("On SAT representations of XOR constraints", LATA 2014) show that systems of XOR constraints have no polynomial-size representation that is arc-consistent under unit propagation, even with auxiliary variables, using a monotone-circuit lower bound. If this is right, Prop 2.6's exponential-looking size cannot be avoided in general. It would also mean that, for systems, intermediate concepts do not rescue a weak reasoner.
* **[recalled, unverified]** Resolution needs exponential size on Tseitin formulas over expander graphs (Urquhart 1987; Ben-Sasson and Wigderson 2001), while Frege systems have polynomial-size proofs of them. So the boundary between "core suffices" and "core does not suffice" lies between proof systems, not only between UP and GE.

### 2.5 Directionality

**Proposition 2.7 [proved].**
* (a) A clause with w literals is equivalent, for forward chaining, to w directed rules ("if the other w − 1 literals are false, conclude this one"). Conversely a directed rule is a clause. So under unit propagation, the smallest usable directed-rule theory and the smallest usable clausal theory differ by at most a factor of the maximum clause width.
* (b) Single parity law on n variables, no auxiliary variables: a sound rule concluding x_j must have all other n − 1 variables in its premise. The only codeword containing j is 1^n, so Lemma 2.2 forces premise ∪ {j} ⊇ [n]. Every question with S = [n]∖{j} needs its own rule. So a usable directed-rule theory has exactly n·2^(n−1) rules, against 2^(n−1) clauses: a factor of n, the number of directions.
* (c) With the chain's auxiliary variables, each constraint has ≤ 3 variables, so the factor is ≤ 3.

**Reading [assessment].**
* The brief asks for "a family of query types where every hypothesis shaped like a program needs length growing with the number of query directions, while one axiomatised law plus cheap deduction answers them all". (b) is such a family, and the growth is exactly linear in the number of directions.
* But (c) shows that the separation is an artefact of forbidding intermediate concepts. The *exponential* separations of §2.2–2.4 are between reasoners and between languages, not between declarative and procedural shapes. Logical shape buys multi-directional use at a constant factor once intermediate concepts are allowed. Its large advantages come from being paired with a general reasoner.
* This refines scout P's caveat to the brief's argument S4.

### 2.6 Three homes of know-how; relation to the earlier report

**Proposition 2.8 [proved].** For every linear law V:
* (a) **Reasoner.** Written as k linear equations (k(n + 1) bits), the core is GE-usable.
* (b) **Explicit lemmas.** For UP over explicit clausal theories, Props 2.4–2.6 apply: ≥ A_d·2^(d−1) clauses without intermediate concepts; O(n·#circuits) with them.
* (c) **Membership procedure plus free search.** The axiom set PI(V) has a decider of length K(A, b) + O(1) that runs in polynomial time:
  * test whether {v ∈ C⊥ : supp(v) ⊆ supp(C)} = {0, 1_{supp(C)}}, by Gaussian elimination on the columns in supp(C);
  * then test the parity of the falsifying assignment.

  Every question has a derivation using one axiom instance, of material O(n). So under the earlier report's charged-deduction readings, which bound derivation size (or material) and axiom-membership time but not the *search* for a derivation, V is fit by a short theory with short derivations.

*Proof.* (a) is the definition of GE. (b) is Props 2.4–2.6. (c): membership is a rank computation, and the single-instance derivation is Prop 2.3's one-step propagation written as a derivation. ∎

**Reading [assessment].**
* The know-how needed to answer questions with bounded effort is paid for in one of three places: in the reasoner (GE), in explicit lemmas, or in a search that the cost model does not charge. Under (c), the know-how sits partly in the axiom-membership procedure (Craig's shape: a decider that embodies a method) and partly in the free search for the right instance.
* **This locates the earlier report's short-derivation results.** Charged-deduction AI is certificate function induction: under total material its fit class is NP ∩ coNP at polynomial budgets [known from the earlier report via scout S, I18–I19]. The nondeterminism *is* free search. So those theorems model a reasoner that is told the derivation, and they cannot express the textbook point, which concerns a reasoner that must *find* the answer.
* To express the textbook point, one fixes a deterministic bounded reasoner (UP here; bounded-time proof search in general). The induced explicit theory must then carry the know-how, and it can be exponentially longer than the "physical picture".

**Learning consequence [proof sketch].** Take one parity law on d variables and questions with |S| = d − 1. In a minimal UP-usable no-aux theory, each clause has full width (Prop 2.4(a)) and so serves exactly one value pattern (d questions).
* An inducer restricted to explicit no-aux theories with a simplicity prior must therefore see each of the 2^(d−1) patterns before it answers them all correctly. A minimal compatible theory contains no full-width clause for an unseen pattern, because such a clause would add length without helping the data. Any correct answer it gives on an unseen pattern comes from a narrower, unsound clause, which also answers some question wrongly.
* An inducer that may use auxiliary variables, or a GE inducer, pays O(d log d) bits for the whole law.
* So a weak reasoner must learn its know-how pattern by pattern. With intermediate concepts it learns one law at once. For systems of laws, even intermediate concepts are not enough in general (the recalled result above).
* The missing steps are: (i) the precise prior on explicit theories; (ii) a coverage bound for random question sequences (coupon collector).

### 2.7 What P1 says about the paper's claims

* **Textbook point (brief; `phil-sci-our-science-is-very-human-software.md`).** Supported and made exact: a written core is sufficient *for a reader who can do algebra* and exponentially insufficient for one who only applies rules. "Insufficient for a simple reasoner" is a property of the pair (theory, reasoner) [assessment].
* **What a theory is.** The formal content of "theories are shaped like logical theories" is not a shape-only advantage; the brief anticipates this. The separations are relative to a reasoner, as the brief expects, and also relative to the availability of intermediate concepts (ladder step 3) [assessment].
* **Ladder step 3.** Theoretical terms pay *for usability and learnability* with a weak reasoner (exponentially in the clausal language; Props 2.4, 2.5), while scout S and scout F show they are dispensable up to O(1) for *description* in the universal class. This is a new and, we think, important item for the theoretical-terms thread [assessment].

---

## 3. Push P3: approximate theories

### 3.1 Two regimes for interval data

**Setting.** q(t) is the true value. An exact law f_K has error e(t) = f_K(t) − q(t), with ε* := ess sup |e| under the law of sampled times. Theory T_K asserts q(t) = f_K(t) for all t. Data are true interval sentences.

**Proposition 3.1 [proved].**
* (G) Let datum j be "q(t_j) ∈ [v_j − δ, v_j + δ]" with v_j = q(t_j) + η_j and |η_j| ≤ δ₀ ≤ δ.
  * T_K proves datum j iff |e(t_j) − η_j| ≤ δ, and refutes it otherwise.
  * If δ ≥ ε* + δ₀, T_K is compatible with every such data set, at every n.
  * If the η_j are i.i.d., independent of the t_j, with ±δ₀ in the support of their law, and δ < ε* + δ₀, then T_K is a.s. eventually refuted.
* (R) Let datum j be "q(t_j) ∈ [h(m_j − u_j), h(m_j + 1 − u_j))", the dithered cell containing q(t_j), with u_j ~ U[0, 1) independent. Then Pr[T_K proves datum j | t_j] = (1 − |e(t_j)|/h)⁺, and otherwise T_K refutes it. Hence Pr[T_K survives n data] = (1 − p_h)ⁿ with p_h := E min(|e(t)|/h, 1).

*Proof.*
* (G) T_K proves q(t_j) = f_K(t_j) = q(t_j) + e(t_j), which lies in the interval iff |e(t_j) − η_j| ≤ δ; otherwise T_K proves the negation. The bound |e − η| ≤ ε* + δ₀ gives the first claim. For the second, the set where |e(t) − η| > δ has positive probability, so by Borel–Cantelli (second lemma, independence) it occurs infinitely often.
* (R) Two points at distance |e| fall in different cells of a uniformly shifted grid with probability min(|e|/h, 1). Independence across data gives the product. ∎

**Computed [n3 A, B].**
* Mean refutation index against 1/p_h, for e = sin with amplitude 1′: 1.58 against 1.57 at h = 1′; 15.5 against 15.7 at h = 10′; 94.4 against 94.1 at h = 1° = 60′.
* Under (G) with δ₀ = 0.5′, the per-datum refutation probability is 6.0×10⁻⁴ at δ = 1.49′ and exactly 0 at δ ≥ 1.50′.

**Reading [assessment].**
* Under rounding, precision belongs to the *data set*: n dithered data at width h refute a law with mean error E|e| after about h/E|e| data. Coarse naked-eye positions (h = 1°) refute an exact law that is wrong by 1′ after about a hundred observations.
* So, in proof-requiring AI, "approximately true" exact laws survive only against guaranteed tolerances. This sharpens scout P's Table 2.3, which is regime (G).

### 3.2 Honest approximate laws against laws with exceptions

Proof-requiring AI prefers a false exact law to its true tolerance-weakened version on every data set (scout P, Prop 2.3 [proved there]). The alternative must therefore be scored by a code with exceptions.

**Objective.** As in §4.1, J_λ(T) = λ|T| + X(T), where X is the literal cost of data T does not prove and T must be consistent with the data. The candidates (common parts omitted):
* **E** exact law T_K: cost 0; compatible iff no datum refutes it.
* **P** exact law with patches: for each refuted datum, the law is withdrawn at that time (a clause naming the time, π_c := log₂N + 2 bits, charged at λ), and the datum becomes an exception (c_f bits). Cost λπ_c·r + c_f·r with r refutations. E is the case r = 0.
* **H** honest law T_K^ε, "|q(t) − f_K(t)| ≤ ε for all t", with ε = ε*: cost λΔ_ε plus c_f for each datum it does not prove. It never refutes a true datum.
* **N** a better exact theory (Newton): cost λΔ_N, proves everything.

Fine data at dithered cell width h cost c_f = log₂(range/h) each.

**Proposition 3.2 [proved, for expected costs per datum].**
* P costs p_h·(λπ_c + c_f) per datum in expectation, and H costs q_h·c_f, where q_h := min(2ε*/h, 1) is the probability that H cannot prove the datum (its 2ε* band straddles a cell boundary).
* **If h ≥ 2ε*:** p_h = E|e|/h and q_h = 2ε*/h. So H is cheaper per datum iff
  λπ_c > c_f·(2κ − 1),  κ := sup|e| / E|e|.
* **If h → 0:** p_h → Pr[e ≠ 0] and q_h = 1. So H is cheaper iff Pr[e ≠ 0] > c_f/(λπ_c + c_f).
* N overtakes the cheaper of P and H once the number of fine data exceeds λΔ_N divided by that theory's per-datum cost (minus its one-off cost).

*Proof.*
* The probabilities are Prop 3.1(R) and the straddling probability of an interval of length 2ε* in a uniformly shifted grid.
* Since |e| ≤ ε* ≤ h/2, min(|e|/h, 1) = |e|/h.
* Comparing 2ε*·c_f/h with E|e|·(λπ_c + c_f)/h gives the inequality. ∎

**Computed [n3 C], with π_c = 22 bits, Δ_ε = 20 bits and range 360°.** Each cell of the phase diagram gives the modal MAP over 300 runs.
* **Spread-out error** (sinusoid, κ = π/2, so 2κ − 1 = 2.14):
  * at λ = 1, P wins for h ≥ 2′. For h ≥ 3′, λπ_c = 22 < 2.14·c_f ≈ 24–27 (c_f ≈ 11–13). At h = 2′ the comparison is p_h·(λπ_c + c_f) = 11.3 against q_h·c_f = 13.4;
  * at λ = 2, H wins at every h (44 > 27);
  * for h ≤ 1′, H wins at both λ until Newton.

  For example, at λ = 1, Δ_N = 2000, h = 1.5′, the modal MAP runs through all four phases as the number of fine data grows: E (1 datum) → P (2–20) → H (50–100) → N (≥ 200), against a predicted switch from H to N at 143 data. At h = 0.5′ it runs H (1–100) → N (≥ 200), against a prediction of 128.6.
* **Concentrated error** (±ε* on 5% of times, κ = 20): P wins at every h and both λ until Newton, which overtakes P only after about 1000–14000 fine data. Pr[e ≠ 0] = 0.05 lies below c_f/(λπ_c + c_f), which is 0.30–0.46 here.

**Reading [assessment].**
* Whether an inexact law should be held as an *approximate law* or as an *exact law with exceptions* depends on the shape of its error.
  * Errors spread over the domain (Kepler under planetary perturbations) favour the honest approximate law.
  * Errors concentrated in rare circumstances favour "exact, except at these listed cases", which is the ceteris-paribus shape.
* The two differ in their answers to new fine questions.
  * P answers confidently and is wrong with probability p_h: overconfidence.
  * H abstains with probability q_h and is right when it answers. Its "independent" mass is the posterior share of H times q_h: the trichotomy as the source of humility (the brief's seed).
* A steeper prior (larger λ) makes naming exceptions dearer, so it favours honesty.
* The simplicity prior alone does not deliver honest approximate theories (scout P, Prop 2.3). The code with exceptions delivers them exactly when the error is spread out.

### 3.3 Derivation horizons, and the catastrophe of exact approximations

**Proposition 3.3 [proved].** Let T^ε contain "|x₀ − a| ≤ e₀" and "for all s, |x_{s+1} − F(x_s)| ≤ ε" with F L-Lipschitz, over the reals with the usual axioms.
* (a) T^ε ⊢ |x_r − F^r(a)| ≤ e_r, where e_r := L^r·e₀ + ε(L^r − 1)/(L − 1), and e_r := e₀ + rε for L = 1.
* (b) For linear F(x) = Lx with L ≥ 1, the set of values of x_r over models of T^ε is exactly [L^r·a − e_r, L^r·a + e_r]. So T^ε proves "x_r ∈ [v − δ, v + δ]" iff that interval contains it, and in particular only if e_r ≤ δ.

*Proof.*
* (a) Induction: |x_{s+1} − F^{s+1}(a)| ≤ |x_{s+1} − F(x_s)| + |F(x_s) − F(F^s(a))| ≤ ε + L·e_s.
* (b) The models x_{s+1} = Lx_s ± ε with x₀ = a ± e₀ attain both endpoints. Convex combinations of admissible error sequences are admissible, and x_r is affine in them, so every intermediate value is attained. A sentence about x_r is provable iff it holds in all models (completeness). ∎

**Horizon.** r*(δ) := max{r : e_r ≤ δ}, with e₀ = 0, is ⌊δ/ε⌋ for L = 1 and ⌊log_L(1 + δ(L − 1)/ε)⌋ for L > 1. At δ/ε = 10⁴: 10⁴ for L = 1, 463 for L = 1.01, 72 for L = 1.1, 13 for L = 2 [computed: n3 D].

With random-sign per-step errors the typical error after 100 steps is 7.8ε, against the worst case 100ε (≈ √(2r/π)) [computed]. So the honest theory's silence beyond the horizon is *worst-case* humility. A probabilistic error model answers much further out, with stated confidence.

**Corollary 3.4 (the catastrophe) [proved].**
* Two exact approximations of the same quantity that differ somewhere (f₁(t₀) ≠ f₂(t₀)) are jointly inconsistent and prove everything; in AI their union has weight 0.
* Their honest versions, |q − f_i| ≤ ε_i, are jointly consistent iff |f₁ − f₂| ≤ ε₁ + ε₂ wherever both apply, and every derived conclusion carries a propagated tolerance.

This is the formal form of the "100 = 99.9" example in the author's domain-of-applicability note (§7).

**Reading [assessment].** An approximate law's domain of applicability includes a bound on *derivation length*. With an exact-but-false approximation and a classical reasoner, a long enough derivation can reach any conclusion. So for such theories a bounded reasoner is not only a resource limit: bounding the derivation is what keeps its conclusions approximately right. This links P3 to P1.

### 3.4 What P3 says about the paper's claims

* **"Kepler's laws give approximately correct predictions" (brief).**
  * In AI the precise forms are: an honest law "within ε on W" (a partial theory), or an exact law with exceptions.
  * Which one the inducer adopts is decided by the κ criterion. An exact false law survives only against guaranteed tolerances.
  * Newton *explains* the honest Kepler law (C19), not the exact one.
* **The trichotomy as humility (brief's seed).** Confirmed in a precise sense: the humble theory is selected in a computable window, and its silence is the "independent" value. It is not selected by the proof-requiring weight alone (scout P, Prop 2.3).
* **Precision-dependent selection (brief's seed).** The seed says "the simpler approximate theory is preferred until the data's precision exceeds its error". That holds under guaranteed tolerances (Prop 3.1(G)). Under rounding it is wrong: what matters is (number of data) × (error/precision), and between the exact law and the better theory sit the two intermediate phases P and H [assessment].

---

## 4. Push P2: the best system as a steeper MAP

### 4.1 The objective and the marginal-slope characterisation

**Definition 4.1.**
* Data D is a finite set of question–answer pairs in the base language. c(d) is the literal cost of datum d: the length of its answer in a fixed code, plus the cost of its index where the decoder needs it.
* A *law part* T is a finite set of sentences, with length |T| given by an additive code: |T| = Σ_{χ∈T} |χ| (plus an end marker).
* Fit: X(T; D) := Σ{c(d) : d ∈ D, T ⊬ d} if T is consistent with D, and ∞ otherwise.
* J_λ(T) := λ|T| + X(T; D); its minimisers are the λ-MAPs.
* λ = 1 is the two-part MDL code "theory + exceptions", and the fundamentals scout's laws-plus-exceptions bound lives there. Proof-requiring AI is the case where every datum must be proved (X ≡ 0), so its theories contain every fact.

**Proposition 4.2 [proved].** Let T* be a λ-MAP.
* For every A ⊆ T*: X(T*∖A) − X(T*) ≥ λ|A|.
* For every finite B with T* ∪ B consistent with D: X(T*) − X(T* ∪ B) ≤ λ|B|.

*Proof.* J_λ(T*) ≤ J_λ(T*∖A) and J_λ(T*) ≤ J_λ(T* ∪ B), with |T*| = |T*∖A| + |A| and |T* ∪ B| ≤ |T*| + |B|. ∎

**Definition 4.3 (explanatory power).** EP_D(A; T) := (X(T∖A; D) − X(T; D))/|A|: the bits of data that module A explains per bit of its length, in the context T. By Prop 4.2, every module of a λ-MAP has EP ≥ λ.

**Proposition 4.4 (facts used once) [proved].**
* (a) Suppose a datum d is added as an axiom and proves nothing else: X(T ∪ {d}) = X(T) − c(d). Suppose also that stating d as an axiom costs |d| ≥ c(d) + a, where a ≥ 0 is the per-axiom overhead of the code. Then EP({d}) ≤ c(d)/(c(d) + a) ≤ 1. So for λ > 1 no λ-MAP contains d; at λ = 1 it is excluded by the overhead a, or tied when a = 0.
* (b) More generally, the coding bound gives |T| + X(T) ≥ K(answers | questions) − O(1), when X includes the indices of the exceptions.

*Proof.*
* (a) Immediate from Def 4.3.
* (b) The pair (T, the exception list with indices) lets a decoder reconstruct every answer: for a non-exception, search for a proof from T, which exists. So it is a description of the answers given the questions.

This is Paper 2's `lem:setup:coding`, and so, around any sufficient theory, there is a right line of slope 1 (`cor:kink:split`(a)). ∎

### 4.2 Laws, initial conditions, contingent facts

**The toy family.**
* Bodies b = 1, …, m; body b has n_b observations, each costing c literally.
* The law Λ (length L) together with body b's elements E_b (length k) proves all of b's observations. Elements without Λ prove nothing (scout P, Prop 2.1: laws alone answer no position question, and elements alone answer none either).
* K3 (length L₃) shortens every body's elements by s bits: it derives the period from the semi-major axis.
* Hypotheses are (Λ?, K3?, S) with S the set of bodies whose elements are axioms. The data are assumed incompressible beyond this structure.

**Proposition 4.5 [proved].** For each of the three choices (no law; Λ; Λ + K3), the best S is S(λ) = {b : c·n_b > λk_b}, where k_b = k, or k − s with K3. The λ-MAP is the best of the three.
* Λ enters iff Σ_{b∈S(λ)} (c·n_b − λk_b) > λL.
* K3 is in the λ-MAP iff the optimum with Λ + K3 beats the optimum with Λ alone. When S(λ) is the same under both choices, this happens iff s·|S(λ)| > λL₃.

In the MAP, the law's deletion slope is c·Σ_{b∈S} n_b / L, and E_b's is c·n_b/k_b. With m identical bodies of n observations, these are m·n·c/L and n·c/k.

*Proof.* Given the choice, J_λ is a sum over bodies of min(c·n_b, λk_b), plus the law terms. ∎

**Computed [n2]** (L = 300, L₃ = 150, k = 60, s = 15, c = 12.4; 8 planets with 500–5000 observations, 60 asteroids with median about 5, 30 comets with 1–2):
* The closed form agrees with brute force on small populations in 210/210 cases.
* The λ-MAP by range of λ:

| λ | λ-MAP |
|---|---|
| > 319 | ∅: everything stated as data |
| 136–319 | Λ + planets, joining one at a time |
| 7.0–135.4 | Λ + all 8 planets: one hull vertex, a (135.4, 7.03)-kink |
| < 7 | asteroids join one by one; K3 joins between λ = 5 and 8 |
| any λ ≥ 1 | comets never join (c·n_b/k ≤ 0.41) |

* At λ = 2: the law's deletion slope is 746; K3's is 2.9; planets' elements 180–1058; asteroids' elements 2.2–9.4.
* With L = 3000, L₃ = 600: Λ + 8 planets for λ ∈ (7.0, 63.2), and K3 enters only for λ ≤ 1.05.

**Reading [assessment].**
* **The model–randomness split of Paper 2 transfers, but it does not separate laws from initial conditions.** The planets' elements are reused across hundreds or thousands of data per bit, and they sit on the steep, "model" side of the hull together with the law. What the split separates is *reused* facts (laws, and the initial conditions of well-observed systems) from facts *used once* (the comets' observations), which stay as data for every λ ≥ 1.
* This corrects the brief's seed ("a steeper prior should separate laws, reused across many data, from contingent facts such as orbital elements").
* **What distinguishes laws from initial conditions is the *scaling* of explanatory power.** A law's grows with the number of systems; a system's initial conditions' grows only with the observations of that system. In the limit of many systems observed a few times each, the law's slope diverges and the elements' stays bounded.
* **K3 is a law about initial conditions.** It enters only when enough bodies' elements are in the theory, and it is the least robust part of the best system.
* **In the question format,** a system's initial conditions belong in the *question* ("given these elements, where is the body at t?"), and laws answer conditional questions with no elements at all (scout P, Prop 2.1). This is the cleanest formal locus of the laws/initial-conditions distinction in AI.

### 4.3 Lewis's best system: kind nature and trivialisation

**Proposition 4.6 [proved, given Paper 2].** Apply Paper 2's hull lemma (`lem:setup:hull`) and `thm:kink:converse` to the point family (|T|, X(T; D)). The λ-MAP is the same for all λ in an interval (τ, σ) iff the hull has a vertex whose incoming edge has slope ≥ σ and whose outgoing edge has slope ≤ τ, i.e. a (σ, τ)-kink.

**Reading [assessment].**
* Lewis's best-systems account [known: lewis1994humean, lewis1983new] balances simplicity against strength. Lewis hoped that nature would be "kind", so that one system comes out best under any reasonable standards of balance [recalled, wording not checked against the text].
* Here strength is fit to data in a fixed base language, the balance is λ, and "kind nature" is a steep kink in the data's hull. In the toy, the best system "law + planets" is robust over a factor of 19 in λ.
* Below λ ≈ 7, the system changes with every asteroid: there nature is not kind, and the best system depends on the balance. This is Woodward's worry about the balance [known: woodward2014simplicity, partly verified by scout P], made checkable.
* At λ = 1 the account degenerates at the margin. A fact that explains only itself is excluded only by the code's per-axiom overhead (Prop 4.4). Any λ > 1 excludes it by a margin proportional to its length, and more generally excludes every module with EP < λ.

**Proposition 4.7 (trivialisation) [proved, given the coding bound].** Let F be a predicate added to the language and T a theory in the extended language, e.g. {∀x Fx} plus axioms relating F to the base vocabulary. Then |T| + X(T; D) ≥ K(answers | questions) − O(1) still holds. So no extension makes the two-part description of base-language data shorter than its complexity.

*Proof.* The decoder of Prop 4.4(b) works in any language: it searches for proofs, from T, of base-language sentences. ∎

**Reading [assessment].** Lewis's trivialisation worry (a predicate F true of exactly the actual things makes "∀x Fx" maximally simple and strong) is blocked by measuring strength as derivation of *base-language* data. F's connection to the data must be paid for. What remains is the choice of base language, which is Cohen and Callender's relativisation [known: cohen2009better]. Its cost under translation is bounded by K(τ) (scout F).

### 4.4 Explanatory power and unification

Def 4.3's EP is "bits of data explained per bit of axiom", the brief's seed. On a hull edge it is the kink slope.

**Copernicus and Ptolemy.** Use the coincidence that scout P (§1.4, E3) singles out as the best illustration of unification. Let a_p be the length of planet p's coincidence axiom (its epicycle motion locked to the Sun's), and H the length of the heliocentric reorganisation (the Earth's orbit as one more planet). Then the heliocentric module has EP = Σ_p a_p / H relative to the coincidence axioms it replaces, with no change in fit. It is in the best system for λ < EP. This is unification without better prediction, in exact form [proved; the lengths are not measured].

**Novelty [assessment].**
* ILP's compression measures and Myrvold's Bayesian unification measure [known: myrvold2003bayesian] are close relatives, as scout L notes (§5.1 there).
* What is new here is the steeper-prior reading: Prop 4.2's inequalities, the robustness interval, and the scaling distinction of §4.2.

---

## 5. Push P4: what a law is worth to raw-data prediction and to question answering

### 5.1 The value of a conservation law

**World.**
* Micro-states x ∈ {0,1}^m. The dynamics π is a uniformly random permutation of each weight class, so |x| is conserved.
* x₀ has weight w = m/2. The raw data are the trajectory x₀, x₁, …, and the questions are "what is |x_t|?".

**Proposition 5.1 [proved].**
* (a) Before the trajectory closes its cycle, the Bayes predictor that knows the law predicts x_{t+1} uniformly over the C(m, w) − t unvisited states of the class (plus x₀). The predictor that does not know it predicts uniformly over 2^m − t states.
  * The law therefore saves log₂((2^m − t)/(C(m, w) − t)) bits per step, which tends to ½·log₂(πm/2) for t ≪ C(m, w) (Stirling).
  * This is a fraction O(log m/m) of the per-step loss.
  * Every predictor's expected raw loss is at least the entropy, ≈ T·log₂C(m, m/2) over T steps.
* (b) On the questions, the law (with x₀'s weight) answers every question with certainty. Without it, each answer costs log₂(m + 1) bits under a uniform prior over weights. The law accounts for all of the question-answering loss.
* (c) A Bayes mixture with prior ½ on "law" and ½ on "no law" pays at most 1 bit more than the law-knowing predictor, in both tasks.

*Proof.*
* (a) Under a uniformly random permutation of a set, conditionally on a path not yet closed, the next element is uniform over the unvisited elements and the path's start. Stirling gives C(m, m/2) = 2^m·√(2/(πm))·(1 + o(1)).
* (b) Immediate.
* (c) Mixture dominance. ∎

**Computed [n4].**
* The per-step gain is 1.87, 2.84, 3.83 and 5.33 bits at m = 8, 32, 128, 1024. As a fraction of the raw loss it is 0.23, 0.089, 0.030 and 0.0052; ½·log₂(πm/2) gives 1.83, 2.83, 3.83, 5.33.
* Simulation at m = 12, T = 300 (the cycle closed at step 275): raw loss 2643.5 bits with the law, 3286.4 bits without it, 2644.5 bits for the mixture; the law's share is 0.196. QA loss: 0 with the law, 1110.1 bits without, 1.00 bit for the mixture; the law's share is 1.

**Reading [assessment].**
* This is the formal content of the author's remark about the mechanics of Galileo and Newton, "this doesn't improve one's ability to predict pixels in an arbitrary video basically at all" (`phil-sci-science-predicts-only-very-particularly.md`), with one correction.
* The law's *absolute* value to raw prediction is not zero: about ½·log₂ m bits per step, comparable to its log₂(m + 1) bits per question. What vanishes is its *share* of the raw loss, which is dominated by micro-detail no theory addresses.
* The raw-data predictor also learns the law (c), which supports scout P's objection o1: the theory is in the raw-data predictor. Paper 2's model–noise split would extract it.
* So the two tasks differ in their target (which losses are counted), not in what must be learned.

### 5.2 Extracting answers

**Proposition 5.2 [proved; (b) known].**
* (a) Any procedure that decides "∀x |π(x)| = |x|" with black-box access to π must, in the worst case, query all 2^m states. An adversary answers weight-preservingly and changes one unqueried state.
* (b) For dynamics given as programs, whether a universal law holds is Π₁-complete, by reduction from non-halting: "the program never reaches a state of weight ≠ w".
* (c) What the AI posterior provides is Bel(law), the posterior mass of theories that prove the law. What a raw predictor provides is the probability that all future data conform. These differ: the earlier report's Bayesian ω-gap shows that "proves ∀x φ" tends to a prior share while instances confirm conformity [known from the earlier report, `thm:univ:omega`, via scout P §1.7].

*Proof.* (a) Adversary argument. (b) Standard reduction. ∎

**Reading [assessment].** "The theory's answers cannot be extracted from a good raw-data predictor without extra search" is true in sense (a)/(b): certification needs search or proof. But the AI inducer does not certify either; it believes, through its prior. So the difference between the tasks is again reasoner-relative (cost of extraction) plus the different *quantity* reported (Bel of a law against predictive conformity). This agrees with scout P's §1.7 list and with the brief's conclusion that "any difference must lie in what is cheap to obtain from each, relative to a reasoner".

### 5.3 No gap in what must be learned, for questions about observed data [proof sketch]

Suppose the questions are computable functions g(x_{0:T}) of the raw data, and the raw data come from a deterministic generator p. Then with free deduction, K_A(answers) ≤ |p| + K(g) + O(1): a theory with one axiom schema "the answer to question q is g applied to p's output", decided by running p and g (Craig-style). So question answering never needs more *description* than raw modelling plus the extractor. The converse gap (raw modelling needs far more) is P4's partiality, Prop 5.1. The missing step is the bookkeeping for random generators, where answers carry entropy.

---

## 6. Notes for the paper and for the other threads

1. **For the "what a theory is" section.** Use P1 (Props 2.4, 2.5, 2.7, 2.8) as the formal setting the brief says is missing. In it, the shape of a theory matters relative to a reasoner, and the gains of logical shape (multi-directional use) are a constant factor once intermediate concepts are allowed. The large gaps are between reasoners and between vocabularies.
2. **For the textbook limitation.** State it as Prop 2.8. The explicit theory needed by a deterministic weak reasoner can be exponentially longer than the core. The earlier report's charged-deduction theorems model a reasoner with free search and do not capture the limitation.
3. **For the Kepler example.**
   * Present the honest law ("within ε on W") as the AI form of "approximately true". It is partial, silent at finer precision, and derivable from Newton.
   * Present Props 3.1–3.2 as the selection behaviour. The κ criterion is a short, quotable statement.
4. **For laws versus initial conditions.**
   * The steeper split separates reused facts from facts used once. The laws/initial-conditions distinction is a scaling distinction, or, in the question format, the distinction between theory and question antecedent.
   * Scout P's Q4 is answered: "uniformly in the number of bodies" holds for the law's slope, which grows with the number of bodies, and fails as a separation of laws from the elements of well-observed bodies.
5. **For explanation.** Use EP (Def 4.3) as the explanatory-power measure, the Copernicus coincidence as the example, and C13 for the limit: no direction without interventional questions.
6. **Possible new threads, ranked.**
   * (i) A lower bound with auxiliary variables for a specific weak reasoner, proved in-house rather than recalled. This is hard; it needs monotone-circuit lower bounds.
   * (ii) The κ criterion for the real Kepler residuals of scout P's c1: compute κ per planet and window. This is easy, because scout P's script already has the residuals.
   * (iii) A learnable-domain version of C16 on scout P's pool.
   * (iv) C19 for one planet and one window with a validated perturbation bound. This is hard.

---

## 7. Possible error in the author's view

**Claim and source.** `philosophy/philosophy of science/the domain of applicability of a scientific mode(l).md`, on how catastrophic reasoning with approximate models (using 100 = 99.9 in algebra) is avoided:

> how come we usually avoid this sort of catastrophic reasoning?
> * i don't think any nice "formal criterion" is going to be right?

The note also says that "the vibe of physics is imo more like: oh here's a way of talking that works. these bad things? don't do them, silly!"

**Why it is probably overstated.**
* There is a nice formal criterion that is *sound*. Write each approximate model in its honest form (|q − f| ≤ ε on its domain) and reason classically. Every conclusion then carries a propagated tolerance, and combining two models is consistent exactly when their tolerances overlap (Prop 3.3, Cor 3.4).
* This is what validated numerics and interval methods do in computer-assisted proofs. With it, the "100 = 99.9" step is not a contradiction: it becomes "|100 − 99.9| ≤ ε₁ + ε₂", which is true and harmless.
* What the criterion lacks is *fidelity to practice*. It is worst-case: our computation shows a worst-case tolerance of 100ε where typical errors are 7.8ε after 100 steps (n3 D). And practitioners neither state tolerances nor propagate them.

So the true statement is not "no nice formal criterion is right". It is "the nice sound criterion is too conservative and too laborious to be what practice does; practice relies on typical-error judgement and tacit domain knowledge".

**What to write instead.** "Catastrophic reasoning with approximate models is blocked, soundly, by stating approximations with tolerances and propagating them. Scientific practice rarely does this explicitly, and the explicit version is worst-case and therefore conservative. The gap between the sound criterion and practice is part of what written theories leave to tacit understanding."

---

## 8. References and their verification status

**Verified by sibling scouts** (bibliographic data confirmed there; keys as in `../literature/refs.bib` and `../philosophy/refs.bib`):
* lewis1983new, lewis1994humean (Mind 103(412):473–490);
* cohen2009better;
* woodward2014simplicity (partly; pages not confirmed);
* myrvold2003bayesian;
* forster1994how;
* schaffner1967approaches;
* woodward2003making;
* bromberger1966why;
* garber1983old;
* statman1979lower;
* craig1953axiomatizability;
* kitcher1981explanatory, kitcher1989explanatory, friedman1974explanation, hempel1948studies;
* khardon1997learning;
* kowalski1979algorithm.

Content statements attributed to them above are at the level those scouts recorded (often abstracts or secondary sources). Lewis's "kind nature" wording is recalled, not checked against the text.

**Recalled, not verified in this session** (web-search budget exhausted; direct fetches blocked). None is used in a [proved] claim.
* A. Darwiche and P. Marquis, "A knowledge compilation map", JAIR 17 (2002).
* B. Selman and H. Kautz, "Knowledge compilation and theory approximation", JACM 43 (1996).
* L. Bordeaux and J. Marques-Silva, "Knowledge compilation with empowerment", SOFSEM 2012 (propagation completeness).
* M. Gwynne and O. Kullmann, "On SAT representations of XOR constraints", LATA 2014 (no polynomial-size arc-consistent representation of XOR systems).
* A. Urquhart, "Hard examples for resolution", JACM 34 (1987).
* E. Ben-Sasson and A. Wigderson, "Short proofs are narrow — resolution made simple", JACM 48 (2001).
* W. Dorling (1979) and M. Strevens (2001) on Bayesian treatments of the Duhem problem.
* The binary-matroid fact that every cycle is a disjoint union of circuits. Not needed: Lemma 2.2 proves what is used.

---

## 9. Verification log

1. **Reading.**
   * The brief was read in full.
   * All 21 files in `../../prior/` were opened. The notes folders named in the header were listed, and the two notes quoted here were read in full; quotations are copied from the files.
   * The sibling scouts' summaries and the sections cited were read. Claims cited as "[proved there]" or "[known from …]" are transcribed from those records, not re-derived, except where the proof is repeated here.
   * Paper 2's hull lemma, kink lemma and `thm:kink:converse` were read in `kinks.tex` and `setup.tex`.
2. **Literature.**
   * The first WebSearch call returned "budget used up" (the shared 200-call limit).
   * WebFetch failed with DNS errors, and curl through the proxy was refused (403). No further attempt was made to work around the limit.
   * Consequently every new reference is marked [recalled, unverified], and only keys already verified by scouts L and P are cited as known.
3. **Scripts.** All four were run and their outputs saved in `checks/`.
   * `n1_xor_usability.py` (230 s): E1–E8.
     * Brute-force cross-check of Lemma 2.2: 6144 cases, 0 mismatches.
     * Exhaustive usability checks: E2, E4, E8 (m = 3).
     * Sampled checks: E5, E7, 3000 questions each.
     * The deletion test of Prop 2.4(b): 88/88 deletions break usability in E2, and 56/56 in E8.
     * One defect was found and fixed during the work: the first version of E4 ran to n = 9, which is 3^16 assignments and infeasible. It was cut to n ≤ 7, and the docstring was corrected (n − 2 auxiliary variables, not n − 3).
   * `n2_best_system.py` (0.6 s): closed form against brute force in 210/210 cases; the thresholds, hull and slopes quoted in §4.2.
   * `n3_precision_phases.py` (10 s):
     * part A: simulated refutation index against 1/p_h, within 2%;
     * part B: the sharp threshold at δ = ε* + δ₀;
     * part C: five phase diagrams, consistent with Prop 3.2's asymptotic criterion in every row where n_f is large. The first version printed a criterion valid only for h ≤ 2ε*; it was replaced by the general per-datum costs, and the κ criterion was derived and added;
     * part D: horizons, and the random-sign comparison.
   * `n4_raw_vs_questions.py` (0.03 s). Two defects were fixed: an "impossible" error when the trajectory closed its cycle (Bayes losses after closure are now 0), and an underflow in the mixture (now computed in log form). The per-step gains match ½·log₂(πm/2) to within 0.005 bits for m ≥ 64.
4. **Determinism.** All four scripts were copied to the scratchpad, re-run there, and their outputs compared with the saved ones, ignoring the timing line. The result is recorded in item 6.
5. **Proofs: self-checks.**
   * Prop 2.4(b) needs d ≥ 3: for d = 2 the "weight 2 < d" contradiction fails. The script skips d ≤ 2.
   * Prop 2.5's proof uses that the active constraints form a forest. That holds because the chain's constraint hypergraph is a hyperpath; it is not claimed for general systems, where it fails (E3).
   * Prop 3.2 is a statement about expected per-datum costs. The phase diagrams are simulations of the actual random costs, and near the boundaries the modal winner fluctuates (frequencies 0.4–0.6), as expected.
   * Prop 4.5's closed form for K3 is exact given the choice (Λ, K3). Its comparison across choices is done by evaluating all three; it was checked against brute force.
6. **Determinism re-run result.** All four re-run outputs are identical to the saved ones, apart from the timing line (`diff` empty for n1, n2, n3, n4).
