# Thread selection for the paper on Solomonoff axiom induction (working name)

*Lead researcher's record, 2026-10-15. Inputs: the brief `00-brief.md` (read in full), the six scout records `scouts/{fundamentals,sfi,philosophy,literature,novel-logic,novel-science}/notes.md` (read in full), their scripts' outputs, and the sources they cite where a decision depended on them (the AI-paper's labels and SD's readings, SOI-N, P2's kink lemmas). Shared notation: `NOTATION-draft.md`. Thread briefs: `tracks/<key>/00-brief.md`. Scouts are cited as F (fundamentals), S (sfi), P (philosophy), L (literature), N1 (novel-logic), N2 (novel-science), with their item numbers. The name "Solomonoff axiom induction" is a working name; nothing below depends on it (SAI in prose, $M_A$ etc. for the laws).*

---

## 0. The threads

| key | title | kind | core content | main sources |
|---|---|---|---|---|
| `fundamentals` | Definitions and basic theorems | math | theory machines, $M_A$, versions $W_A$, $K_A$, variants; structure and conditioning rules (geometric for proof-requiring, Dempster for consistency-requiring); non-lower-semicomputability via the consistency Ω; dominance and invariance; loss bounds in $K_\equiv$; no coding theorem; why proof-requiring is primary; limits and identification (text vs informant); the generative variant | F (all but F8, F9, F26(c)), N1 N10, L Obs L2 |
| `sfi` | Relation to Solomonoff operator induction, with time bounds | math | coin-free, one-tape and Kolmogorov equivalences with consistent SOI; SAI = SOI on positive literals (the transfer table); what breaks (closure, an observed "independent" label, private randomness); time penalties (equivalence kept on the axiom side, one-sided on the labeller side, diagonal); charged deduction (certificate SOI, fit classes); Presburger as a natural separation; the table | S §1, §2, §4–§5; F8, F9; AI-paper §6, TF, SD |
| `philosophy` | What a theory does and what it is: argument map, Kepler, limitations | phil | the problems; claims D, S, E, L, P with verdicts tied to the formal results; questions vs raw data (conservation-law toy); explanation (asymmetry, correction, unification); the worked Kepler example with a new posterior over the historical Mars pool; limitations incl. the condensation essay's list; candidate "possible error" notes; literature | P (all but Prop 2.3 and Q1–Q5, Q8), N2 C11–C13, C18, §5, §7, N1 N9, L §3.9 |
| `terms` | Theoretical terms: Craig, Ramsey and the theoretician's dilemma | math | Hempel's horn ($O(1)$); Craig's construction in practice (run-padded = P); elimination at polynomial cost via unnamed objects; vocabulary *or* ontology (finite theories about the named objects with unary predicates fit exactly REG); free deduction with finite theories (infinity, PA/ACA₀, Kleene-type equivalence); Ramsey vs Craig; the dilemma theorem | S §3, N1 §5 and N8, P Q3 (Prop 5.1) |
| `logic` | Random theories, $\Pi_1$ truth and Gödel phenomena | math | the lottery (bounded one-tape loss, no r.e. theory, unbounded coin-free loss) and its exact boundary; $\Pi_1$ derandomisation, a coding theorem for $\Pi_1$ data, Chaitin for random theories; the arithmetical shape of the trichotomy, soundness never learned, $\Con(T)$, old evidence; the ω-gap's anatomy and a uniform Gödelian form; Th(ℕ) growth | N1 §0–§4, §6, §7, N6, N7; F Q1–Q3, F26(c); L Obs L1 |
| `shape` | Theory shape relative to a reasoner: know-how, intermediate concepts, the textbook point | math | reasoner-relative theory size for linear laws (Gaussian elimination vs unit propagation: exponential gap without intermediate concepts); intermediate concepts make one law usable, not a system; directionality costs exactly the number of directions without intermediate concepts and $\le3$ with them; three homes of know-how and what the AI-paper's charged deduction leaves free; learning know-how pattern by pattern; depth–size trade-off via transitive-closure spanners | N2 §2 (C4–C6), P §1.3 caveat, Q2, Q5; L §3.9 |
| `laws` | Approximate laws, exceptions and the best system | math | proof-requiring SAI prefers false exact laws; precision regimes; honest approximate laws vs exact laws with exceptions (the peakedness criterion), a.s. phase sequence, applied to real Kepler residuals; derivation horizons and the sound criterion for approximate reasoning; the best system as a steeper MAP (laws vs initial conditions as a scaling distinction, Lewis's "kind nature" as a kink, trivialisation blocked); explanatory power; domains and retention; explanation by approximate correction in a provable toy | N2 §3, §4 (C1–C3, C7–C10, C16, C17, C19), P Prop 2.3, Q1, Q4, Q8; F14 |

Seven threads: the three required (`fundamentals`, `sfi`, `philosophy`) and four new (`terms`, `logic`, `shape`, `laws`).

---

## 1. How the selection was made

**Criteria (from the task).** (a) likely true and provable in one development round; (b) new according to scout L; (c) illuminating for the paper's philosophical aims (what a theory is and does; the limitations); (d) cool. Closely related ideas are merged.

**What the scouts delivered.** Unusually much of the material is already proved in first-pass form, with seeded checks. The bottleneck of the development round is therefore *verification and completion*, not discovery: each new thread starts from a body of proved first-pass results, a few proof sketches to complete, and named extensions. That is what made four new threads feasible instead of two.

**Why four new threads rather than two.** The four new directions answer four different questions the brief asks, and none can be merged into another without losing a reviewer's focus:
* `terms` answers the brief's ladder step 3 and its seed on Craig and the theoretician's dilemma;
* `shape` answers the brief's open research question on "what a theory is" and makes the author's central limitation (the textbook point) a theorem;
* `laws` answers the author's second named limitation (Kepler only approximately right) and the seeds on laws versus initial conditions and explanation;
* `logic` contains the results specific to *logic* (no SOI analogue), which are the most surprising mathematics the scouts found.
Merges considered and rejected: `terms` into `sfi` (scout S's §3 builds on the time-bounded machinery but is a separate philosophical topic and would double `sfi`'s load); `logic` into `fundamentals` (too large together for one round); `laws` into `philosophy` (the selection theorems are mathematics that needs math referees); `shape` into `terms` (both involve intermediate concepts, but `terms` judges them by description length and `shape` by usability for a fixed deterministic reasoner; the boundary is stated in both briefs).

---

## 2. The threads and why

### 2.1 `fundamentals` (required)

* **Why.** The paper's backbone. Scout F proved F1–F27 in first-pass form; the thread re-verifies, writes paper-quality proofs, proves F11's transferred parts directly (so it does not depend on `sfi`), verifies the references behind F2/F3/F12/F27, and attempts F's open Q4–Q7.
* **New (scout L §5.3).** The one-tape theory machine, its dominance and invariance, the $K_\equiv$ loss bound, the conditioning-rule reading of the variants, non-lower-semicomputability via a Solovay-complete consistency probability, and the limit theorems for this object are not in the literature; Gold's text/informant distinction and Demski's prior are the nearest known things and must be cited.
* **Risk.** Low. F12 depends on the Shekhovtsov–Zakharov transfer to infinite sets (abstract-level only); the brief allows a downgrade to Solovay's factor 3.

### 2.2 `sfi` (required)

* **Why.** The author asked for "the time-bounded equivalences you've worked out". The refereed AI-paper results must be restated for this paper's objects; scout S found that the earlier slogan needs qualifying ("≡ *coin-free* consistent SOI"; one-tape SOI ↔ random axiom systems), proved the transfer principle (SAI = SOI on positive literals, so all of P1's binary-label results transfer and the content of SAI beyond SOI lies in logically structured data), the one-datum separation by an observed "independent" label, and a natural, non-diagonal separation (Presburger).
* **New.** Transfer principle, one-tape and Kolmogorov equivalences, the independent-label separation, the Presburger separation (scout L: new application of Fischer–Rabin). The coin-free equivalence's construction is Craig's (known); its Bayesian form was not found in the literature.
* **Risk.** Low for the restatements; moderate for the doubly-exponential one-tape Presburger case (an extension, conjecture otherwise) and the circuit sandwich (extension).

### 2.3 `philosophy` (required)

* **Why.** The author's request centres on the philosophical problems, and the epistemic policy makes this thread responsible for saying only what we believe. Scout P's argument map, verdicts and Kepler computations are strong; scout N2 adds formal support for "questions vs raw data" (the conservation-law toy) and for explanatory asymmetry.
* **New computation.** A proof-requiring posterior over the historical Mars pool at each precision, with the law-text syntax written down, so that the paper can show how much of the "historical order" the simplicity prior recovers and how much is decided by syntax.
* **Risk.** Literature verification is large (scout P verified bibliographic data for 75 entries; many contents only via secondary sources). The thread must hedge accordingly.

### 2.4 `terms` (new)

* **(a) Provable:** almost everything is proved in first-pass form; two named completions (machine normal form; Kleene-type equivalence B3) and one high-priority extension (one binary relation suffices).
* **(b) New:** scout L found no complexity-theoretic theorem making "Craigian axiomatisations are useless in practice" precise, and no "vocabulary or ontology" result; the Kleene/Craig–Vaught and inductive-logic antecedents must be cited.
* **(c) Illuminating:** it answers the theoretician's dilemma inside an ideal inducer: *vocabulary* is cheap to eliminate; what finite theories cannot do without is theoretical *relations or entities*; Craig's construction fails for a reason (it writes run times in unary) that does not apply to other eliminations. This sharpens ladder step 3 and corrects the brief's own seed.
* **(d) Cool:** the regular-languages characterisation via Rabin's tree theorem; infinity needs a function symbol, not predicates.

### 2.5 `logic` (new)

* **(a)** Proved in first pass with full proofs (lottery, $\Pi_1$ derandomisation, Gödel phenomena, ω-gap anatomy); the recalled literature (reflexivity is not used here; flexible formulas, Kreisel) is confined to extensions.
* **(b)** New as stated (scout N1; scout L lists Bienvenu et al. 2014 as the closest work for $\Pi_1$ derandomisation; the thread must read it).
* **(c)** Two results bear directly on "what a theory is": on the lottery stream the successful hypotheses are *random theories* (a law plus a randomly drawn completion of contingent facts), not any r.e. theory; and "independent" on a $\Pi_1$ question certifies truth, which is the formal content inside the inducer of "the Gödel sentence is true because it is unprovable". D4 answers the author's note on induction in mathematics: free-deduction SAI cannot do it; it needs a bounded deducer.
* **(d)** The coolest mathematics of the scouts: a phenomenon of logical consistency with no SOI analogue (majority vote fails only for unbounded inconsistency arity), a coding theorem exactly where truth certifies itself, and Chaitin's theorem for random theories.

### 2.6 `shape` (new)

* **(a)** The no-intermediate-concepts bounds, the chain encoding and the directionality result are proved; the systems lower bound with auxiliary variables is recalled (Gwynne–Kullmann) and must be verified; T6 and T7 are new targets of moderate difficulty.
* **(b)** Scout L found no formal separation theorem for the declarative/procedural question; scout N2 suspects T2's bounds are folklore in knowledge compilation, so the novelty is the reading inside a universal inducer, the directionality result and the three homes of know-how.
* **(c)** It is the formal setting the brief says is missing. Its honest answer, which the paper should adopt: the large separations are between reasoners and between vocabularies (intermediate concepts), not between declarative and procedural shapes; logical shape buys multi-directional use only up to a constant once intermediate concepts are available. It also shows that the AI-paper's charged-deduction results leave the search free and so cannot express the textbook point, while a deterministic bounded reasoner can.
* **(d)** The simplex family ($\log(n+1)$ equations vs $n2^{(n-1)/2}$ clauses) and the depth–size curve via transitive-closure spanners.

### 2.7 `laws` (new)

* **(a)** Mostly elementary and proved for expected costs; the a.s. strengthening, the real-residual application and the correction toy are tractable.
* **(b)** Scout L: the phenomenon of precision-dependent selection is known (AIC, MDL/MML); its form for proof-requiring axiom inducers, the honest-vs-exceptions criterion and the steeper-prior reading of best systems were not found. Forster–Sober, MDL/MML, Myrvold, ILP compression must be cited.
* **(c)** It turns the author's "approximately correct predictions" limitation into exact statements, shows that the trichotomy is the formal home of humility (honest approximate laws are partial theories), and corrects two seeds of the brief (precision-dependent selection under rounding; laws vs initial conditions).
* **(d)** "Lewis's kind nature is a kink" and "honesty is decided by the peakedness of the error".

---

## 3. Ownership of the scouts' items

| scout | items | thread |
|---|---|---|
| F | F1–F7, F10–F25, F26(a)(b), F27; Q4–Q7; Q2 (general) | `fundamentals` |
| F | F8 (one-tape equivalence), F9 (atomic fragment) | `sfi` |
| F | F26(c), Q1, Q3, Q2 for $\Pi_1$ theories | `logic` |
| S | §1, §2 (Thms 2.4–2.9, Props 2.6, 2.10–2.12, Rems 2.13–2.15), §4 items 2, 3, 5–8, 10, 11, §5 table | `sfi` |
| S | §3 (Thm 3.1 to Cor 3.13, Qs 3.8–3.19), §4 items 1, 4, 9 | `terms` |
| P | §1, §2 (except Prop 2.3), §3, §4, Q6, Q7 (remark) | `philosophy` |
| P | Prop 2.3, Q1, Q4, Q8 | `laws` |
| P | Q2, Q5 | `shape` |
| P | Q3 (Prop 5.1) | `terms` |
| L | Obs L1 | `logic` |
| L | Obs L2 | `fundamentals` |
| L | Obs L3, Table 1, the novelty tables, §6 (names) | synthesis (related work; the name findings go to the author) |
| N1 | §3 (E0–E3), §4 (A1–A6), §6 (D1–D4), §7 (C1–C3), N6, N7, N11, N13 | `logic` |
| N1 | §5 (B1–B4), N8 | `terms` |
| N1 | N9 | `philosophy` |
| N1 | N10 | `fundamentals` |
| N1 | N12 | `fundamentals` (remark under T8) |
| N2 | §2 (C4–C6), §6 items 1–2 | `shape` |
| N2 | §3, §4 (C1–C3, C7–C10), C16, C17, C19, §6 items 3–5 | `laws` |
| N2 | §5 (C11, C12), C13, C18, §7 | `philosophy` |
| N2 | C14, C15 | rejected as threads (§4 below); remarks in `philosophy` and `logic` |

Dependencies during the parallel development round are handled by citing the scout item; the revision step aligns the threads (each revision reads the others' records). The main interfaces: `fundamentals` defines the objects everyone uses; `sfi` T7–T8 are cited by `terms` and `shape`; `logic` T1 is cited by `sfi`, `terms` (B4) and `philosophy` (N9(b)); `laws` T2–T5 and `shape` T2–T5 are cited by `philosophy`.

---

## 4. Ideas rejected or deferred, and why

| idea | source | decision and reason |
|---|---|---|
| A market or mixture over unknown axiom systems with costed deduction (combining logical induction and SAI) | L Obs L3 | Rejected as a thread: no first pass, far beyond one round. A paragraph in the discussion. |
| Theory shape for communities: hypotheses cheap to verify jointly by several bounded agents | P L11, Q2 extension | Rejected: speculative, no formal setting yet. Mention as an open direction in `philosophy` T5/the discussion. |
| Piecemeal confirmation as a theorem; Duhem–Quine blame under a product prior | P Q7, N2 C15 | Rejected: low novelty (Bayesian treatments by Dorling and Strevens, recalled), and the definitions already give $\Bel_D(\text{law})$. A remark in `philosophy`. |
| Old evidence via derivation budgets (confirmation by new derivations) | N2 C14 | Rejected as a target: known in spirit (Garber 1983). The free-deduction side is `logic` T3 (D4); one remark suffices. |
| Underdetermination: empirically equivalent theories keep their prior odds | N2 C18 | Trivial; a remark in `philosophy`. |
| Self-referential sentences about the posterior; Rosser balance points | N1 (dropped there) | No content (Bel is about provability, not truth; ratios are machine-dependent). |
| Kreisel's conjecture and line budgets | N1 C3 | Kept only as a `logic` extension, conditional on verifying the literature. |
| Second-order and ω-rule versions learn Th(ℕ) | N1 N6 | A remark inside `logic` T4 (pins the unlearnability of Th(ℕ) on effective consequence). |
| Is the Th(ℕ) loss $o(n)$? | F Q3, N1 N7 | The main question is a hard generic-decidability question; only the reduction and the $n^\delta$ lower bound are targets (`logic` T5). |
| Validated N-body integration certifying "Kepler within ε" from Newton; formal derivations of interval data in a MetiTarski-style prover | P §2.6(d), (e) | Rejected: heavy engineering for one round. Replaced by a provable toy of explanation by approximate correction (`laws` T7). |
| Learning in the limit à la Gold for computable learners of r.e. theories | N1 N12 | Known in substance; a remark in `fundamentals` T8. |
| Explanatory direction from the generative variant's derivation posterior | P Q6 | First pass: a tie broken only by the choice of primitives or by interventional questions. A small proposition in `philosophy` T3, not a thread. |
| Statistical theories (probabilistic laws, frequency data) | P L8 | No time in one round; a limitation in `philosophy` T5, with the generative variant as the partial handle. |
| Normalised-convention linear gap between normalised SAI and normalised consistent SOI | S §4 item 11 | Dropped: low interest; the related order-dependence question is `fundamentals` T11.1. |
| Pathwise vs machine-wise consistency of random labellers | S Rem 2.14 | Kept as an attempt inside `sfi` T6, open if not settled. |
| Circuit analogue of the charged-deduction sandwich | S §4 item 8 | Kept as `sfi` T10 (extension). |
| Speed-up from conservative theoretical extensions | N1 N8 | Kept as `terms` T8.1 (extension), literature first. |
| Learning domains of applicability on the Kepler pool | P Q8, N2 C16 | C16 is a core proposition of `laws` T6; the learning version is `laws` T8 (extension). |
| A new name for the inducer | L §6 | Not ours to decide. The findings (no collisions for "Solomonoff axiom induction"; risks for "universal axiom induction" and "Solomonoff theory induction"; "operator induction" is Solomonoff's term) go to the synthesis, to report to the author. |

---

## 5. Epistemic policy: what the scouts raised

**Candidate "Possible error in the author's view" notes** (to be assessed by `philosophy` T6; only survivors go forward):
1. Scout P §1.8: the condensation essay's "there is really nothing fundamentally right about these information-theoretic losses". Proposed correction: grading a prediction for use is purpose-relative; updating beliefs about theories by likelihood is not arbitrary (the log score's uniqueness), and the purpose enters by fixing which propositions are data.
2. Scout N2 §7: the domain-of-applicability note's "i don't think any nice formal criterion is going to be right". Proposed correction: a sound criterion exists (state approximations with tolerances and propagate them); what it lacks is fidelity to practice, because it is worst-case.

My own view as lead: both have a decent probability of being right as stated by the scouts; (2) is the stronger, because the formal criterion is a theorem (`laws` T4), while (1) turns partly on what the essay meant (it explicitly flags the point as not thought through). `philosophy` decides.

**Corrections of the brief's own seed ideas** (these are the orchestrator's suggestions, not the author's claims; they are corrected in the threads, not written as possible errors):
* "The time-bounded separations make [the classical reply to Hempel] a theorem": true only for Craig's construction and run-padded axiomatisations; theoretical vocabulary can be eliminated at polynomial cost (S §3.7) → `terms` T7.
* "The simpler approximate theory is preferred until the data's precision exceeds its error": true under guaranteed tolerances; under rounding, what matters is the number of data times error over precision (N2 §3.4) → `laws` T2.
* "A steeper prior separates laws from contingent facts such as orbital elements": the split separates reused facts from facts used once; well-observed elements sit with the law; laws are distinguished by how their explanatory power scales (N2 §4.2) → `laws` T5.
* The brief's (S4) "a program computes one direction cheaply": true of a particular program, not of the class (a program may contain a generic solver); the separation must be relative to a fixed reasoner (P §1.3) → `shape` T4.

**Already agreed with the author** (brief): the Craig collapse undercuts "what a theory is" in the idealised setting; "existing language" is comparative (the ladder). The threads develop these stances; they do not reopen them.

---

## 6. Preliminary outline of the paper

Working title: *\SAI: Definitions, Basic Theorems, and What a Theory Is and Does* (the title uses the name macro; final wording for the synthesis). Authors: Kaarel Hänni and Claude (Anthropic), with the title-page footnote the brief prescribes. Voice "we"; statuses rendered in prose; verified references only; no running-text replies to the notes (REFRAME/DECISIONS rules of the SOI papers).

1. **Introduction.** The two problems (what a theory does; what it is). Raw-data prediction (Solomonoff) versus answering questions posed with existing abstractions. The object in one paragraph: a universal machine reads a random tape and enumerates axioms; the prior on labelled sentences is the probability that the random theory is consistent and proves them. The ladder. What we show, and what we do not claim (the idealised formalism cannot see shape; the descriptive claim is an observation; the explanatory question is reasoner-relative). Contributions list.
2. **Setting** (`fundamentals` T1). Data, theory machines, $M_A$, the trichotomy and its conventions, versions ($W_A$, $K_A$), variants (consistency-requiring, graded, generative).
3. **Basic theorems** (`fundamentals` T2–T9). Structure; conditioning rules; computability and the consistency Ω; dominance, invariance (including vocabulary); loss bounds in $K_\equiv$; versions and no coding theorem; why proof-requiring; limits and identification; the generative variant. Related priors (Demski).
4. **Relation to Solomonoff operator induction** (`sfi`). Coin-free, one-tape and Kolmogorov equivalences; SAI = SOI on positive literals; what breaks; time bounds; charged deduction; Presburger; the table.
5. **Logic: random theories, $\Pi_1$ truth and Gödel** (`logic`). The lottery and where it cannot happen; $\Pi_1$ derandomisation, the coding theorem and Chaitin; Gödel phenomena; the ω-gap; Th(ℕ).
6. **What a theory does and is** (`philosophy` T1–T3). Questions vs raw data, with the conservation-law example; the formal differences from raw-data prediction; "what a theory is" after Craig; explanation.
7. **A worked example: Kepler and Newton** (`philosophy` T4, with `laws` T3 applied). The language, laws vs elements, the Ramsey sentence, K3 and the data language, residual tables, the historical Mars pool, what Newton adds.
8. **Approximate laws and the best system** (`laws`). Precision regimes; honest laws vs laws with exceptions; horizons and sound approximate reasoning; the best system as a steeper MAP; explanatory power; domains, retention; explanation by correction.
9. **Theoretical terms** (`terms`). Hempel's horn; Craig in practice; elimination via unnamed objects; vocabulary or ontology; finite theories (infinity, PA); Ramsey vs Craig; the dilemma theorem.
10. **Theory shape relative to a reasoner** (`shape`). The textbook point as a theorem; intermediate concepts; directionality; three homes of know-how; learning know-how; depth–size trade-off.
11. **Limitations** (`philosophy` T5). The textbook point's three gaps; approximate truth and domains; concept formation and language change (steps 3–4); the condensation essay's list; statistical theories; discovery vs selection; social structure; free mathematics.
12. **Related work.** Universal induction and operator induction; probabilities on sentences (Gaifman, Hutter et al., Demski, logical induction); formal learning theory (Gold, Shapiro, Osherson–Stob–Weinstein, Kelly, Martin–Osherson); ILP and Bayesian theory learning (Muggleton, Kemp–Goodman–Tenenbaum, Ullman et al.); random axioms and Chaitin; Craig, Ramsey, Hempel and inductive logic with theoretical terms; knowledge compilation and learning to reason; best systems and approximate truth.
13. **Discussion.** What the formalism shows and cannot show; open questions collected from the threads; directions (ladder step 4; communities of reasoners; costed deduction with unknown axioms).

Appendices: proofs by section; computations (scripts and outputs); verification log; notation.

*Order and length.* Sections 2–5 are the mathematical core and 6–11 the part on theories; the synthesis may reorder (e.g. put 6 before 4 to lead with the motivation) or, if the result is too long for one paper, propose a split (mathematics: 2–5; theories: 6–11) to the author. One paper is the default, since the author asked for one.

---

## 7. What to watch for at synthesis

* **Notation drift.** The scouts used $L_A$ for two things, $\lambda$ for three, $\kappa$ for three, $W$ for three; `NOTATION-draft.md` fixes them. Check that the revised records follow it.
* **Overstated novelty.** Several statements are new forms of known phenomena (Gold's text/informant; AIC/MDL precision; knowledge-compilation bounds; Craig's construction). The record must say what is known.
* **Unverified literature.** Scouts N1 and N2 had no web access; every "[recalled, unverified]" claim must be verified or hedged before it reaches the paper.
* **Philosophy built on theorems.** Every philosophical claim that leans on a theorem must cite the revised statement, with its hypotheses (e.g. the textbook theorem is about a deterministic weak reasoner and linear laws; it is not a theorem about textbooks).
