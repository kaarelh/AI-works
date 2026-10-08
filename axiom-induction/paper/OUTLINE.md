# Outline: "Bayesian Axiom Induction from Instances: Template Priors, Derivation Likelihoods and Time Penalties"

Binding plan for all section writers. Read it together with `NOTATION.md` (symbols, macros, name maps) and `CLAIMS.md` (the ledger of every result, with status and source, and the cross-track conflicts with their resolutions). The ledger id of a result is its LaTeX label; use exactly that label.

## Audience and stance

* Readers: mathematically literate researchers in logic, learning theory and Bayesian statistics. First reader: Kaarel Hänni, who asked the question.
* The paper answers his question (quoted verbatim in `research/00-brief.md`). It is standalone: define everything used. Cite the two earlier reports for background and do not re-prove their results:
  * \citet{claude2026axiomschemas} ("AS": templates, DT°, matching, anchors, the cautious verifier, the ω-gap, the MDL finding, DTRC). Cite by its numbers: e.g. matching theorem = AS Thm 2.5; ω-gap = AS §4.5; Tarski–Vaught criterion = AS Prop 4.7; Q ⊬ ∀x(0+x=x) = AS Ex 4.9; MDL finding = AS §6.10 and Props E.16 (naive split), E.17 (well-specified code), Table 12; spare slots and the bound = AS Prop 6.4, Thm 6.5; ∀xφ as a sound merge = AS Prop 6.13; refutation depth = AS Thm 6.15; induction anchor = AS Thm 5.16; IndEq = AS Prop 5.18; Collection = AS Prop 5.7; preservation lemma = AS Lemma 2.4; protocol = AS Def 2.6; closed-class soundness = AS Lemma 2.8.
  * \citet{claude2026whatfollows} ("IL": the prior–posterior-ratio martingale and Ville's inequality). Thm 4.15 (`thm:caution:ville`), Lemma C.4 (`lem:app:caution:ville`), Prop C.5 (`prop:caution:tight`), Thm 4.14 (`thm:caution:bayesdet`), Thm 4.16 (`thm:caution:bayesesc`), Thm 10.9 (`thm:informal:ville`).
  * Hänni's notes \citep{hanni2026notes}: `research/prior/hanni-solomonoff-axiom-induction.md` (main), `hanni-polytime-solomonoff.md`, `hanni-solomonoff-function-induction.md`. Quote verbatim, cite by file path, and say that they are working notes.
* Framing (Hänni's request): this is understanding and checking of an idea, not the design of a stronger prover. Say so in the intro and in the discussion. The code is a small exact laboratory, not a prover.

## Sources (the ONLY sources of claims)

* `research/00-brief.md`: the question and the orchestrator's hypotheses H1–H7 (to be confirmed or refuted, not assumed).
* `research/tracks/model/notes-final.md` (+ `referee.md`): the general theory. Cite as `model <item>` (Def 1.1 … Prop 8.2).
* `research/tracks/universal/notes-final.md` (+ `referee.md`): the ∀xφ case. Cite as `universal <item>` (Prop U1 … Prop U16, Thm B, Prop B2, Lemma N0, Props N1–N3, Lemma S1).
* `research/tracks/pa/notes-final.md` (+ `referee.md`): PA, ZF, theorem data, Th(ℕ), Bayesian DTRC, robust failures. Cite as `pa <item>` (Def 0.1 … Prop 5.3, F1–F10).
* `research/tracks/experiments/notes-final.md` (+ `referee.md`) and `code/results/*.md`: implementation and E1–E8. Cite as `experiments <item>` (Prop X1 … X13, E1 … E8).
* The verification logs at the end of each `notes-final.md` record what each referee found and how it was resolved. The final notes supersede `notes.md` everywhere. Where a final note cites another track's superseded numbers, `CLAIMS.md` §"Cross-track conflicts" gives the number to use.

## Rules for writers (binding)

1. **Status and source on every theorem-like environment.** Use `\status{...}` with values from {proved, computed, conjecture, known, proof sketch, refuted}, combined with ";" and with part labels when parts differ, e.g. `\status{(a)–(c) proved; (d) conjecture}`. Use `\src{track item}`, e.g. `\src{model Thm 4.7}`, `\src{universal Prop N2}`, `\src{pa Prop 4.8}`, `\src{experiments E2}`. Definitions get `\src` only. Map pa's "proved (checked)" to `\status{proved; computed}` and say in the text that the derivation was checked by the track's natural-deduction checker.
2. **Never claim more than the final notes establish.** Keep every caveat, scope restriction, hypothesis (fixed vs Dirichlet weights; parameters admissible; calculus; likelihood; candidate set or pool) and every "upper bound" qualifier. If a number depends on a code, a calculus or a pool, say which.
3. **Refuted claims stay labelled refuted, with the counterexample,** where they matter to the reader: as a remark with `\status{refuted}` next to the corrected statement. The full list goes to `app-verification`.
4. **Labels:** `sec:<key>`, `sec:<key>:<sub>`, `thm:`, `prop:`, `lem:`, `cor:`, `def:`, `ex:`, `rem:`, `conj:`, `tab:`, `fig:`, `app:<key>`, `app:<key>:<sub>`, with `<key>` ∈ {intro, model, univ, ident, sound, time, pa, exp, disc, ver}. Use exactly the ids of `CLAIMS.md`. Cross-reference with `\Cref`.
5. **Proofs:** the main text gives a short proof or a proof idea and points to the appendix (`\Cref{app:...}`); the appendix gives the full proof as in the notes, with any step the notes leave out named as such.
6. **Macros:** only those in `preamble.tex` (existing ones plus the block "axiom-induction macros"). Local macros go at the top of your section file with the section key as prefix (`\univ...`, `\pa...`). Do not redefine anything.
7. **Bibliography:** keys of `bib/core.bib`, plus the canonical keys listed in `NOTATION.md` §11; add their entries to `bib/<key>.bib`. Flag in a LaTeX comment any reference you did not verify, and keep the claim about it hedged ("recalled, not checked against the source").
8. **Style:** plain, precise prose; short sentences; no marketing words ("powerful", "novel", "remarkably"). Numbers with their units (bits or nats), sample sizes and seeds.
9. **Build check:** `./test-section.sh <section> <appendix>` only. Undefined references to other sections are expected. Never run `./build.sh` unless told to, and then only as `flock /tmp/claude-0/paper-build-ai.lock ./build.sh`.
10. **Page targets** below are caps for 11pt. The main-text targets sum to 46 pages against a requested total of about 40; aim at the lower end and move tables and secondary results to the appendix first. Appendices total about 36 pages.

---

## 0. `abstract.tex` (written last; ≤ 250 words)

The question in one sentence; the model (template prior, derivation likelihood with a data-independent normaliser, time penalty); the four headline answers (A2, A4, A5, A7 of `CLAIMS.md` §"Answers"); the main caveat (all positive guarantees need well-specified data; human data are not). No numbers beyond one or two.

---

## 1. `intro.tex` — key `intro` — ≈ 4 pp (written after the other sections)

**Purpose.** State the question, how we read it, the answers in brief, and where each is proved.

**Contents.**
1. Hänni's question, verbatim (from the brief), and the context of his note: the two variants ("prove the givens", "do not contradict"), the trichotomy, his equivalence of axiom induction with function induction over consistent assigners, his conclusion that unrestricted axiom induction collapses, and his proposal to restrict to substitution schemas; the three further ideas (templates, derivation-length prior, time penalty).
2. The three readings (a good version; the case ∀xφ; guarantees and failures).
3. Answers in brief: one paragraph per bullet A1–A9 of `CLAIMS.md` §"Answers to the question", each with `\Cref`s to the results named there.
4. Table `tab:intro:verdicts`: the brief's hypotheses H1–H7 with verdict (confirmed / confirmed with qualification / refuted) and where. Source: model §9.1, universal §0 verdict table, pa Summary, experiments §0.
5. What is not achieved: posteriors over the full template class are not computed (pools and hand-picked candidate sets only); misspecified limits are known only for specific families; several rates are conjectures (model Prop 5.6(d), Thm 5.1(c), Conj 6.15; universal N3(d), U16(d)); no human-written theorem corpus was used; PA under a derivation likelihood was not run in code.
6. Relation to the two earlier reports (AS is the non-Bayesian treatment of the same questions; IL supplies the Ville argument) and to Hänni's notes.
7. Framing sentence (checking, not building a prover). Reader's guide (one line per section).

No theorem environments. One table.

---

## 2. `model.tex` + `app-model.tex` — key `model` — ≈ 6 pp + 5 pp

**Purpose.** All definitions used later, in one place, with the calculi, priors and likelihoods of every track reconciled (`NOTATION.md`). Results stated here are the structural lemmas the other sections need: Kraft, properness of 𝒬 and of L1, the size principle, which likelihoods have it, and what can be computed.

**Results stated (ledger ids; full statements in `CLAIMS.md`).**
* §2.1 Syntax and theories: `def:model:theory` (model Def 1.1). Recall AS §2 (closure-normal form, parameters, de Bruijn, templates, DT°, matching, AS Thm 2.5) in prose.
* §2.2 Calculi: `def:model:calculus` (Mendelson's K, Th(T), Th_d(T); theorems depend only on instances; model §1.2); `lem:model:a4` (model Lemma 1.2: (a) proved, (b) proof sketch); `def:model:calculi` and table `tab:model:calculi` (K tree grammar; C_min, C_open, U3 calculi, C_∧ of universal §1.4; the forward chain Ch_J of experiments §1.6; natural deduction ND with its two-part code, pa Def 0.3; the equational grammar of model Ex 3.6). Columns: rules; proper or normalised; per-datum ∀E factor on instance data; where used.
* §2.3 Prior: `def:model:prior` (model Def 1.3); `lem:model:kraft` (model Lemma 1.4); `rem:model:priors` (the other tracks' priors: experiments' stochastic template code, proper by Kraft, with time factor (1+|T|)^(−τ); universal's 2^(−λ(Σ|A|+1)) and pa's 2^(−β·symbols), improper over the full class, used only on finite or summable families; Levin-Kt time factor and why it barely bites inside DT°, model §1.3).
* §2.4 Instantiation grammar: `def:model:grammar` (model Def 1.5, uniform weighted subcriticality); `lem:model:grammar` (model Lemma 1.6); `rem:model:subcrit` (the per-type condition of `notes.md` refuted as a usable hypothesis; the referee's chain; short, details in appendix). Term laws used later (𝒬_num, 𝒬_GW, 𝒬_open, experiments' PCFG, pa's learned positional grammars) listed in prose.
* §2.5 Likelihoods: `def:model:lzero` and `lem:model:dirsum` (Dirichlet labelling-sum formula; model §1.5, experiments Prop X2(a)); `def:model:lone`; `lem:model:lone` (model Lemma 1.7); `def:model:variants` (L2; L1^σ with `lem:model:lsig`; L1^max; L1^sch and L1^naive of pa; L0^cl of universal; the two selection-aware likelihoods L1^sel (stream filter, universal) and L1^sel_cit (per-citation rejection, experiments) with `rem:model:sel`; noise mixtures P^η (universal §1.5); pa's L_ε; model's L1^eq). Table `tab:model:likelihoods`: name, definition in one line, normaliser data-independent?, size principle?, used in, each track's name.
* §2.6 Hänni's scores: `def:model:scores` (S_prove, S_nc, S_g; universal's S_nc,β mapped; pa's L_ε as the noisy form).
* §2.7 Size principle: `lem:model:size` (model Lemma 1.8; computed c1); `prop:model:whichsize` (model Prop 1.9); `rem:model:graded` (model Remark 1.10, including the refuted sentence of `notes.md` with the counterexample T = {a, a→b}, T′ = T ∪ {b}: P_T(b) = 0.032, P_T′(b) = 0.346).
* §2.8 Computing the likelihood: `prop:model:compute` (model Prop 2.7); `prop:model:max` (model Prop 2.8; the maximum breaks generator ties by 2^(−n)); the cost paragraph of model §2.4 (truncation enumerates exponentially many trees; no lower bound known).

**Appendix `app-model` (`app:model`).** Proofs of `lem:model:kraft`, `lem:model:grammar` (a)–(d), `lem:model:dirsum`, `lem:model:lone`, `lem:model:lsig`, `lem:model:size`, `prop:model:whichsize`, `rem:model:graded`, `prop:model:compute`, `prop:model:max`; sketch of `lem:model:a4`(b) with the missing step named; the refuted per-type subcriticality condition with the referee's chain (Π(1 − 1/(k+2)²) = ½) and why the uniform condition excludes it; `ex:model:qa` (𝒬_A satisfies Def 1.5 with ρ = 0.75; mean sizes 14.62 and 4.016; computed c10); the exact definitions of C_open, the U3 calculi, C_∧, Ch_J and ND (rule lists).

**Cross-references out:** §univ (C_min, L0^cl, L1^sel), §ident (setting W uses the likelihoods), §sound (V_{δ,d} uses Th_d), §time (L1^σ, S_g), §pa (L1^sch, L_ε, R_d).

---

## 3. `universal.tex` + `app-universal.tex` — key `univ` — ≈ 7 pp + 7 pp

**Purpose.** Hänni's case: what the posterior does with ∀xφ given instances φ(t). Verdicts on the brief's conjectures H4(a)–(f). The section's message: the data favour the generator that emits exactly the instances; they never favour ∀xφ over its instance schema; "all future data are instances" is confirmed, "the axioms prove ∀xφ" is not; what does license ∀xφ.

**Results stated.**
* §3.1 Setup: `def:univ:setup` (φ, I_c(φ), I_o(φ), σ_φ, term laws 𝒬_num, 𝒬_GW, 𝒬_open; universal §1.1–1.2) and table `tab:univ:hyp` (H_∀, H_sch, H_open, H_both, memorisers, over-specific, over-general, root split, R_k, Split_k, Both0; universal §1.3).
* §3.2 Instance data never favour ∀xφ: `prop:univ:factor` (U1); `thm:univ:odds` with table `tab:univ:odds` (U2); `thm:univ:B` (Thm B); `prop:univ:robust` (U2n, U2t, U2c); `prop:univ:sim` (U3); `rem:univ:detour` (refuted conjecture; C_∧ counterexample R = 0.15553 > c = 0.15); `prop:univ:B2` (learned weights under the stream-filter L1^sel: Bayes factor → h(w*)) and `rem:univ:B2cit` (under per-citation L1^sel_cit the two theories tie; editor's reconciliation, see `CLAIMS.md` conflict C2); `prop:univ:both` (the spare-slot prover H_both, Θ(1/n)). E1 numbers in one sentence (one bit per datum at c_ch = ½; L1^sel_cit limit 0.484 / 0.269; `tab:exp:e1`).
* §3.3 Memorisation, over-general and over-specific templates: `thm:univ:size` (U4), `prop:univ:overspec` (U5), `prop:univ:memo` (U6; brief H4(a) refuted for memorisation in general).
* §3.4 Predictive confirmation: `thm:univ:confirm` (U8) with `rem:univ:hutter` (Hutter 2007, partial verification; Nicod-type non-monotonicity, Leike–Hutter 2015).
* §3.5 The Bayesian ω-gap: `thm:univ:omega` (U10 (a)–(e)); table `tab:univ:share` (prior shares 0.03–0.48 across codes, universal §6.6); `prop:univ:hanni` (Hänni's two variants on this case; all three trichotomy values keep mass; universal §6.2); `prop:univ:q4` (U13: an ω-gap for an axiom we actually have); `prop:univ:gaifman` (U15: truth versus derivability; M₀ ≼ M).
* §3.6 Open instances and the guard: `prop:univ:open` (U11 (a)–(d)); `rem:univ:openrefuted` (U11(e) refuted, with R₁ and the c8 numbers); `lem:univ:waste` (N0); `prop:univ:rk` (N1); `prop:univ:rkrate` (N2); `prop:univ:noguard` (N3) with table `tab:univ:noguard` (c8 Part 3, compact).
* §3.7 Quantified data, lemmas and the equational fragment: `prop:univ:quant` (U12); `prop:univ:eqfrag` (U14, with the q = ½ restriction of the full-sum part).
* §3.8 Without templates: `prop:univ:sentences` (U16), `lem:univ:survivors` (Lemma S1), `rem:univ:kreisel` (flagged: secondary sources only).
* §3.9 The user's intuition, precisely (prose from universal §11): in what sense it is right; where it needs refinement; "a good version for this case" (proper template prior; selection-aware likelihood or a prior over filters; a noise component; verifier on Bel_cons); `cor:univ:sound` (soundness for ∀xφ, an application of `thm:sound:fixed`, fixed weights only); one paragraph `rem:univ:mdl` relating to the MDL finding (universal §10; details in §ident).

**Appendix `app-universal` (`app:univ`).** Proofs of U1, U2, Thm B (B2 part in full), U2n, U2t, U2c, U3, B2, the H_both integral bounds, U4, U5, U6 (with the Borel–Cantelli step), U8, U10 (all parts; (d2) general case as a sketch), U11, N0–N3, U12, U13 (the model on ℕ ∪ {a, b}), U14, U15, U16, S1. The ∧-detour spine formula (Catalan ansatz; proof sketch) and its numbers. Tables: posterior table of c2 (universal §4; note Laplace weights α = 1), inconsistent-theory mass Inc (universal §6.2), c5 Part A/B tables, c8 Parts 3–4, c9 Parts 3–5 (with the class used, α, the prior variant, n range). State α for every table (c2–c7 use α = 1; c8–c10 use α = ½).

**Cross-references:** in from §intro, §ident (ω-gap, memorisers), §sound (Bel_cons), §time (U2t), §pa (§5.5 head split, rule codes), §exp (E1, E3(a)); out to `lem:model:size`, `thm:ident:doob`, `thm:ident:kl`, `thm:sound:fixed`, `prop:ident:spare`.

---

## 4. `ident.tex` + `app-ident.tex` — key `ident` — ≈ 5 pp + 5 pp

**Purpose.** What the posterior identifies when the data are well specified, what it cannot identify (the axioms beyond their generator class), how splits and spare slots behave (the MDL finding), why positive data suffice (Gold), and what misspecification does. Model §§2, 3, 5, 8; experiments E3(a), E5, E8 numbers briefly.

**Results stated.**
* §4.1 Well-specified consistency: `def:ident:W` (setting W); `thm:ident:doob` (model Thm 2.1; universal Lemma U7 adds total variation); `cor:ident:prior` (model Cor 2.2; computed c9b); `cor:ident:deductive` (model Cor 2.3, with when the limit is 1[T* ⊢ s]: L0 instance union, L1 theorem set with parameters admissible, L2 only Th_{≤d}); `prop:ident:rates` (model Prop 2.4; the uniform rate degenerates for spare templates).
* §4.2 Identification is of the generator: `prop:ident:sep` (model Prop 2.5); `prop:ident:splits` (model Prop 2.6; pa Prop 2.1; experiments Prop X13) with `rem:ident:splitsL1` (exact ties under L1 and L2 at matched fixed weights, also latent citations, E8 tie 1.1·10⁻¹³). E6 in one sentence (pointer to §pa).
* §4.3 Positive data and Gold: `thm:ident:limit` (model Thm 5.1 (a), (b), (b′), (c)); `rem:ident:exact` (Thm 5.1(b″) of `notes.md` refuted: the exact class has posterior mass 0 at every n); `rem:ident:x5` (experiments Prop X5: the computed posteriors at one fixed weight vector are not covered by the a.e. statement); `prop:ident:gold` (model Prop 5.2) with E5(b), (c) numbers; `rem:ident:memo` (memorisation dies under well-specification; the memoriser class can keep exp(−O(log² n)), forward to `prop:univ:memo`; prior work Horning 1969, Angluin 1988, flagged as only partly verified).
* §4.4 Splits and the MDL finding: `prop:ident:splitlzero` (model Prop 5.4); `prop:ident:splitlone` (model Prop 5.6; computed c13); `rem:ident:e8` (E8 numbers: well specified −1.43 bits per doubling under L1, −1.51 under L0, n = 256…4096; misspecified usage +0.202 against +0.074 bits per datum, n = 1024…4096); `rem:ident:mdl` (what this says about the MDL finding: as far as proved a derivation likelihood does not change it; the L1-only partial splits of pa Prop 2.2 are not covered; with a learned grammar the sign of the Occam drift can change, pa Prop 2.3; unmodelled selection creates linear splits, universal §10).
* §4.5 Spare templates: `prop:ident:spare` (model Prop 5.5; experiments Prop X7; pa Prop 5.1) with E5(a), (a2) numbers (−0.500; −0.281 for n = 256…4096; −0.251 ± 0.002 for n = 10²…10⁸) and `rem:ident:sparetotal` (sum over spares; slow rejection; spares and soundness point to §sound).
* §4.6 Misspecification: `thm:ident:kl` (model Thm 3.1; Berk 1966, Kleijn–van der Vaart 2006 known, conditions not read); `ex:ident:weaker` (model Ex 3.2, L0); `lem:ident:zerosum` (model Lemma 3.3); `ex:ident:escape` (model Ex 3.4; computed c4); `rem:ident:fullclass` (model Rem 3.5, conjecture with computed illustration); `ex:ident:lonedq` (model Ex 3.6, computed, with its limits); `conj:ident:cder` (model Conj 3.7); `rem:ident:e3a`: E3(a) in two sentences (the posterior moves at a linear rate to the best-fitting member of a family: nested C₂, numeral split R_m with growing m, finite memoriser; no unsound mass at large n; completeness lost). Table `tab:ident:misspec`: kinds of misspecification and what the posterior lands on (weaker: Ex 3.2, E3(a), E3(b) atomic, pa narrow practice, pa theorem data; unsound: Ex 3.4, Ex 3.6, pa F4, E4 C1, small-n lumps), each with its likelihood and status.
* §4.7 Predictive versus deductive: `thm:ident:predded` (model Thm 8.1); `prop:ident:proofs` (model Prop 8.2: data with proofs identify the instance union); `rem:ident:nearmiss` (model Rem 8.3: corruption channel; transfer proved; size of the generator class open).

**Appendix `app-ident` (`app:ident`).** Proofs of Thm 2.1 (Doob, written out), Cors 2.2, 2.3, Prop 2.4, Prop 2.5, Prop 2.6, Thm 5.1 (a), (b) and the counter-statement (b″), sketch of (b′), Prop 5.2 (the text construction), Prop 5.4 (Stirling), Prop 5.6 (with the KL-continuity lemma), Prop 5.5 (a), (d1) and sketches (b), (c), (d2), Thm 3.1, Ex 3.2 (the structure ℕ ∪ {a}), Lemma 3.3, Ex 3.4, Thm 8.1, Prop 8.2. Computed tables: c2 Part B (Prop 5.4 well and misspecified means), c13 (Prop 5.6), c3/c3b/c15 and E5 (spares), c16 (Ex 3.6 grammars and per-datum costs), c7 (Rem 3.5).

**Cross-references:** out to `lem:model:size`, `def:model:lone`, `prop:univ:memo`, `prop:pa:detour`, `prop:pa:occam`, `thm:sound:fixed`; in from §univ (Doob), §sound, §pa, §exp.

---

## 5. `sound.tex` + `app-sound.tex` — key `sound` — ≈ 5 pp + 4 pp

**Purpose.** The thresholded verifier: when it is sound against adaptive provers, with what probability and under which hypotheses; what fails without them; its δ → 0 limit (the cautious verifier); the trichotomy true / false / independent. Model §§4, 7; experiments E4 (and the E2 acceptances) briefly.

**Results stated.**
* §5.1 Protocol: `def:sound:protocol` (rounds, arrivals chosen by the prover, ESCALATE oracle, V_{δ,d}, C*_d, W*_d; model §4).
* §5.2 Fixed weights: `thm:sound:fixed` (model Thm 4.1, adapted from IL Thm 4.15(b); computed c4 and r7); `rem:sound:tight` (δ ≤ W*δ′ cannot be improved; the fixed small weight construction; model §4.1); `rem:sound:hyp` (the hypotheses that matter: well-specification of the data law, fixed weights or §5.4, a proper n-independent prior (a steeper λ_n breaks step 3), truthful constraints; finite truncations; a computable verifier; the two `notes.md` remarks refuted: "W* only grows", "L2 likelihoods are finite sums"); `prop:sound:misspec` (model Prop 4.2, the waiting prover; computed: 2000/2000; 400/400 against 11/400 for the non-adaptive prover).
* §5.3 The cautious limit and completeness: `prop:sound:cautious` (model Prop 4.3 (a)–(d)); `prop:sound:complete` (model Prop 4.4).
* §5.4 Dirichlet weights: `rem:sound:vacuous` (model Rem 4.5; the earlier application of Thm 4.1 refuted); `lem:sound:regret` (model Lemma 4.6; experiments X8(c) termwise argument); `thm:sound:avg` (model Thm 4.7; experiments Prop X8(a), (b): any pool containing T*, even data-dependent, constant 2^(−bits(T*))); `thm:sound:shrink` (model Thm 4.8 = experiments X8(c)); `ex:sound:constant` (model Ex 4.9: constant threshold at a fixed weight vector accepts with probability 0.977–1.000 against nominal 0.02; averaged 0.003–0.007; shrinking 0; three implementations, see conflict C6).
* §5.5 What the experiments show (short): `rem:sound:e4`: E4 (A) tight construction 9–46 times below the bound, selected data win 20/20; (B) well specified 0/100; (C1) 10% false near misses: accepted in 100/100 streams; (C3) selection with a clean better-fitting theory in the pool: 0/100. `rem:sound:lumps`: E2 acceptances of false sentences at δ = 0.05 in 5 of 25 seeds (n ≤ 16), and pa §5.4 (n ≤ 30, single run, hand-picked set), both consistent with `thm:sound:shrink` because the required threshold is ≈ 2^(−226)·n^(−3.5). Table `tab:sound:compare` (model §5.5: cautious k-union verifier against the Bayesian verifier).
* §5.6 The trichotomy: `def:sound:tri` (Bel, Dis, Indep, Inc, Pl; Bel_cons); `prop:sound:laws` (model Prop 7.1); `prop:sound:belief` (model Prop 7.2; Shafer 1976); `prop:sound:bracket` (model Prop 7.3); `ex:sound:renorm` (model Ex 7.4); `ex:sound:fifty` (model Ex 7.5); `prop:sound:fiftyfifty` (model Prop 7.6); `rem:sound:indep` (how the likelihood shapes Indep; model §7); `rem:sound:belc` (inconsistent theories inflate Bel and Dis; universal §6.2; the Bel_cons verifier accepts a subset of what V_{δ,d} accepts, so the guarantees transfer — see conflict C39); answers to Hänni's three questions in his note (renormalise: incoherent; 50/50: incoherent unless every theory has ≤ 2 models; keep the triple: coherent lower/upper probability).

**Appendix `app-sound` (`app:sound`).** Proofs of Thm 4.1 (the four steps), the tightness construction, Prop 4.2, Prop 4.3 (with the strictness example), Prop 4.4, Rem 4.5, Lemma 4.6 (a), (b), (d), Thms 4.7, 4.8; the mechanism of Ex 4.9 (proof sketch, with the step not written out); the refuted remark on c5 ("coherent cases are essentially those where every theory is complete": 199/300 coherent, 2 complete) as `rem:sound:completeref`; Props 7.1–7.3, 7.6 and Exs 7.4, 7.5 in full; LP checks (c5, c14). The computable-verifier construction.

**Cross-references:** out to `thm:ident:doob`, `thm:ident:limit`, `prop:ident:spare`, `ex:ident:escape`, `tab:exp:e4`, `tab:exp:e2`; in from §univ (`cor:univ:sound`), §pa (§5.4), §disc.

---

## 6. `time.tex` + `app-time.tex` — key `time` — ≈ 5 pp + 5 pp

**Purpose.** Hänni's collapse of axiom induction into function induction, what templates do to it, and which time or length penalty prices it. Model §6; the link to pa §3 (time-bounded likelihood computation favours memorising theorems with long proofs); universal U2t and U14 and experiments E7 briefly.

**Results stated.**
* §6.1 The two inductors: `def:time:inducers` (AI, FI_cons, FI_all, the semimeasure convention; model §6.1); `prop:time:fiall` (model Prop 6.0); `thm:time:equiv` (model Thm 6.1, Craig's trick); `rem:time:convention` (renormalising per step gives only 2c bits per step; Hänni's "wtf is a sequence here?" answered).
* §6.2 Hänni's schema: `prop:time:twosorted` (model Prop 6.2); `prop:time:single` (model Prop 6.3: in single-sorted arithmetic over PA his schema is inconsistent for a consistent assigner; his consistency argument is refuted in that reading, his conclusion survives via Craig).
* §6.3 Templates: `prop:time:notemplate` (model Prop 6.4; the same argument gives pa Prop 4.3 for the reflection schema, `prop:pa:refl`); `prop:time:collapse` (model Prop 6.5: one ground reflection sentence over PA reproduces any Σ_n-sound assigner, overhead linear in |f|).
* §6.4 Time penalties: `prop:time:cheap` (model Prop 6.6; the brief's H6 sentence refuted); `thm:time:ntime` (model Thm 6.7); `cor:time:hard` (model Cor 6.8); `rem:time:upper` (upper bounds for the collapse constructions; proof sketch).
* §6.5 What the derivation likelihoods charge: `prop:time:lonesize` (model Prop 6.9 of `notes.md`, refuted, with the counterexample: size 2^(k+3) − 1 at ν = 7 + 8k grammar nodes); `lem:time:symexp` (model Lemma 6.10); `prop:time:codelength` (model Prop 6.11); `thm:time:log` (model Thm 6.12); `cor:time:log` (model Cor 6.13); `prop:time:sigma` (model Prop 6.14); `conj:time:poly` (model Conj 6.15).
* §6.6 The precise statement and its links: `rem:time:summary` (model §6.5 closing: membership- and generation-time penalties do not block the collapse; templates block the schema, not the collapse; symbol-size derivation penalties price it between nondeterministic and deterministic time; plain L1 only logarithmically as far as proved; function induction's loss on f_X's labels is ≤ |f_X| bits). `rem:time:links`: universal U2t (no penalty monotone in derivation length reverses Thm B), U14 remark (a Kt penalty charges O(log k), less than the derivation charge); experiments E7 (a membership-time factor is a few bits by construction; `rem:time:e7`: λ = 2 trades early unsound lumping for faster removal of a false spare slot); pa §3.8 and F9 (a time bound on computing the likelihood lower-bounds μ_T and so pushes towards adopting theorems with long proofs as axioms; computed for 11-line proofs). `conj:time:polytime` (model §9.3: derivation-bounded L2 with a growing depth budget as the analogue of Hänni's polytime Solomonoff; conjecture, not written out).

**Appendix `app-time` (`app:time`).** Proofs of Props 6.0, 6.2, 6.3, 6.4, 6.5, 6.6, Thm 6.1, Thm 6.7, Cor 6.8 (and the single-X remark as a sketch), the counterexample to Prop 6.9 (and the one-node A4 example), Lemma 6.10, Prop 6.11, Thm 6.12, Cor 6.13, Prop 6.14; the upper-bound sketches; the route for Conj 6.15 and what is missing (de Bruijn indices and Gen under sharing). Computed: c12 Parts A–C.

**Cross-references:** out to `def:model:variants` (L1^σ), `def:model:scores`, `rem:model:graded`, `prop:pa:refl`, `prop:univ:robust`; in from §intro, §disc.

---

## 7. `pa.tex` + `app-pa.tex` — key `pa` — ≈ 6 pp + 5 pp

**Purpose.** "The axioms we actually have": PA and ZF. Which of several equivalent axiomatisations the posterior favours and why; the MDL finding in PA; data that are theorems given without proof (the user's derivation-length proposal); data from Th(ℕ) and the IΣ_n chain; the Bayesian DTRC; robust failures. Pa track; experiments E2, E3(b), E6 numbers briefly.

**Results stated.**
* §7.1 Setting: `def:pa:lsch` (L1^sch and its decodable variant; all numbers are upper bounds from explicit derivations; pa Def 0.3); `def:pa:refute` (R_d; pa Def 0.4). Say once that pa's computations use L1^sch or L0 with a learned KT grammar, never the generative L1 of §2 (conflict C12).
* §7.2 Equivalent axiomatisations: `prop:pa:equiv` (pa Prop 1.1); `rem:pa:pat` (pa Rem 1.2); table `tab:pa:costs`; `prop:pa:usage` (pa Prop 1.3); `prop:pa:lower` (pa Prop 1.4); `rem:pa:usage` (computed consequences: usage decides among minimal theories; the redundant union wins after 1–12 uses; usage-closed axiomatisation); `prop:pa:recursion` (pa Prop 1.5); ZF results as `rem:pa:zf` with table `tab:pa:zf` (checked derivations and their costs; Collection from Replacement known over ZF, fails without Power Set, unknown without Foundation). `rem:pa:e6`: E6 in two sentences (cite `prop:exp:comm` = experiments Prop X12, stated in §exp; L1 identifies the generating axiomatisation among logically equivalent forms of commutativity; under L1^sel_cit the five closed-guard forms tie and P(proves A_xy) → 0.088).
* §7.3 The MDL finding in PA: `prop:pa:chain` (pa Prop 2.1); `prop:pa:occam` (pa Prop 2.3) with table `tab:pa:mdl` (compact: G1 rows, and G2/G3 at n = 256000); the refuted "constant SDPC margin"; `prop:pa:detour` (pa Prop 2.2: a split with a non-atomic connective derives every induction instance; 369–489 bits per detour; F = {=} lies in IOpen).
* §7.4 Theorem data: `prop:pa:memo` (pa Prop 3.1) with table `tab:pa:theorems` (β* = 30–123 bits per symbol against β = 4.52); `rem:pa:streams` (lemma reuse; compressible theorems; theorem streams: on theorems only the MAP is Q + library, strictly weaker than PA); `prop:pa:gibbs` (pa Prop 3.2); `prop:pa:wellspec` (pa Prop 3.3); `prop:pa:must` (pa Prop 3.4); the answer of pa §3.8 in prose.
* §7.5 Th(ℕ), the IΣ_n chain and narrow practice: `prop:pa:thn` (pa Prop 4.1); `prop:pa:refute` (pa Prop 4.2); `rem:pa:tower` (toy drift, computed); `prop:pa:refl` (pa Prop 4.3); `prop:pa:regret` (pa Prop 4.4); `rem:pa:pointwise` (pa Rem 4.5); `prop:pa:isigma` (pa Prop 4.6 (a) proved given known facts, (b) proof sketch, (c) refuted); `lem:pa:motive` (pa Lemma 4.7); `prop:pa:readonce` (pa Prop 4.8); `rem:pa:shift` (pa Rem 4.9); `ex:pa:narrow` and `ex:pa:skel` (pa §4.3 counterexamples 1 and 2); `conj:pa:broad` (pa Conj 4.10). E3(b) atomic motives: `prop:pa:atomic` (experiments Prop X10, with `prop:pa:fragments` = X9 and `prop:pa:redundant` = X11 stated briefly) and `rem:pa:e3b` with the numbers (frag-atoms = Q + {T_=, T_<} has mass 1.000 in every seed from n = 1024; mass on theories equivalent to T* 2·10⁻¹⁷⁸ at n = 2048).
* §7.6 Bayesian DTRC: `prop:pa:spare` (pa Prop 5.1, = `prop:ident:spare`(a)); table `tab:pa:dtrc` (pa §5.2, "within the hand-picked candidate set"); `rem:pa:lumps` (pa §5.4, with the caveat of conflict C7) and `rem:pa:e2`: E2 in three sentences (T* takes the mass once Q1, Q2, Q4–Q7 have each been cited, median datum 55; before that the sound but weaker SeenQ(D_n); unsound acceptance in 5/25 seeds; fragmentation ≈ 700 bits behind; `tab:exp:e2`); `rem:pa:overlap` (pa Rem 5.4, proof sketch); `rem:pa:merge` (∀xφ as a sound merge; the head-symbol ω-gap closing at 5 bits per doubling, crossover ≈ 10⁸; the rule-code table `tab:pa:rulecode`: fixed, learned shared, learned depth-indexed; mixed practice h(f) bits per datum); `prop:pa:nc` (pa Prop 5.2); `prop:pa:incons` (pa Prop 5.3).
* §7.7 Robust failures and the overall answer: table `tab:pa:failures` (F1–F10: what fails, evidence, status, fixable how); `ex:pa:euler` (F4, computed, with its proof sketches); the overall answer `sec:pa:answer` (pa §7) with its qualifiers ("within the hand-picked candidate sets", "axiom-instance data") and the list of competitors not scored.

**Appendix `app-pa` (`app:pa`).** Informal proofs of Prop 1.1 (A), (B), (C1), (C2) and Prop 1.5; the lower-bound argument of Prop 1.4; Prop 1.3; Props 2.1, 2.2, 2.3 (identity and expansion); Props 3.1–3.4; Props 4.1–4.4, 4.6(a), (b) sketch, Lemma 4.7, Prop 4.8, Rem 4.9; Props 5.1–5.3, Rem 5.4; X9, X10, X11 proofs (from experiments §2; the proof of X12 goes to `app-experiments`); the full cost tables (decodable and naive variants; G1/G2/G3 MDL table; theorem library; compressible theorems; theorem streams; Q + Ind practice with and without negatives; ∀xφ merge; rule codes; Euler); the checker (`nd.py`, its rules, its negative tests: 10 unsound steps rejected; the referee's 173 mutants rejected).

**Cross-references:** out to `prop:ident:splits`, `prop:ident:splitlzero`, `prop:ident:splitlone`, `prop:ident:spare`, `thm:ident:doob`, `prop:ident:gold`, `prop:time:notemplate`, `prop:time:collapse`, `thm:sound:avg`, `thm:sound:shrink`, `thm:univ:B`, `tab:exp:e2`, `tab:exp:e3b`, `tab:exp:e6`; in from §ident (MDL), §time, §disc.

---

## 8. `experiments.tex` + `app-experiments.tex` — key `exp` — ≈ 5 pp + 3 pp

**Purpose.** The code laboratory (`code/bai`): what is implemented, why its posteriors are exact over a pool, and the results of E1–E8 with their limitations. Results already stated as theorems elsewhere are referenced, not restated.

**Results stated.**
* §8.1 Implementation (experiments §1): components with guards, single-parameter convention, the PCFG 𝒬 (satisfies Def 1.5), the prior code and time factor, L0, the exact Dirichlet marginal (and the bounds above 20000 states), the forward chain L1 over Ch_J (J ≤ 2, c_stop = ½), L1^sel_cit, causal pools with Trim and Mem, the verifier on ⊢_J. `prop:exp:exact` (experiments Props X1–X4: L0 exact, Dirichlet sum exact, L1 proper, backward recursion exact; proved; computed against brute force, a forward sampler and the referee's independent reimplementation: 2.1·10⁻¹⁴ on 904 triples). 21 unit tests pass.
* §8.2 E1 (`tab:exp:e1`; experiments §3), E2 (`tab:exp:e2`, `tab:exp:e2seen`; §4), E3 (`tab:exp:e3a`, `tab:exp:e3b`; §5), E4 (`tab:exp:e4`; §6), E5 (`tab:exp:e5`; §7), E6 (`tab:exp:e6`, with `prop:exp:comm` = Prop X12; §8), E7 (`tab:exp:e7`; §9), E8 (`tab:exp:e8`; §10). For each: setup in two to four sentences (generator, pool, likelihood, seeds, n), the table, and the findings with their status and the theorem they test.
* §8.3 `rem:exp:limits`: what the experiments do not show (experiments §12): pool not class; chains J ≤ 2 (no induction followed by ∀E, so no PA under a derivation likelihood); one parameter; fixed 𝒬; bounded derivability under-approximates provability; small runs.
* `rem:exp:refuted`: first-version claims kept as refuted (E2 "3 of 5 seeds"; E6 "logically equivalent"; soundness at a constant threshold for any well-specified data; "robust at the level of theorems" for PA; "P(T ⊢ φ(t*)) = 1 from n = 8 in every configuration"; the E2 n = 8 MAP list).

**Appendix `app-experiments` (`app:exp`).** Commands, seeds and wall times (experiments §15); unit-test list; the pool construction in detail; where the Dirichlet bounds replaced the exact sum and the largest mass such theories could have had; the E2 legacy-against-causal pool table; E3(a) family tables (C₁, C₂, N_m); E5(a2) per-n table; E7 full table; the check scripts and their results (experiments §16.3).

**Cross-references:** out to every section's theorems tested (`thm:univ:odds`, `prop:univ:memo`, `thm:univ:omega`, `prop:ident:spare`, `prop:ident:gold`, `prop:ident:splitlone`, `thm:sound:avg`, `thm:sound:shrink`, `ex:sound:constant`, `prop:pa:atomic`, `prop:pa:fragments`); in from §univ, §ident, §sound, §pa.

---

## 9. `discussion.tex` — key `disc` — ≈ 3 pp (written after the other sections)

**Purpose.** What the answers mean, how they relate to Hänni's note and to the literature, and what is open.

**Contents.**
1. Answers A1–A9 of `CLAIMS.md`, restated as conclusions with their scope (one paragraph, pointing back).
2. Hänni's note, point by point (model §9.3; universal §11; pa §5.6): the two variants (scores without size principle; the graded score normalised is a two-part symbol code); the trichotomy (belief/plausibility; his two point estimates); the equivalence (true via Craig, his schema needs two sorts); his conclusion and the restriction to substitution schemas (blocks the schema, not the collapse); "other ideas": generate a small subset (normalised likelihoods; L1^sel; filter priors), allow mistakes (noise mixtures; soundness needs the noise model inside the well-specified generator), grade near misses (corruption channel; open); the polytime note (`conj:time:polytime`).
3. Literature (short; cite, do not re-prove): Solomonoff-style confirmation of universal hypotheses (Hutter 2007; Leike–Hutter 2015; Gaifman 1964); posterior consistency and misspecification (Doob 1949; Schwartz 1965; Berk 1966; Kleijn–van der Vaart 2006; Ghosal–van der Vaart 2017); learning from positive data (Gold 1967; Angluin 1980, 1988; Horning 1969); the size principle and MDL (Tenenbaum–Griffiths 2001; Rissanen 1978; Krichevsky–Trofimov 1981; Rousseau–Mengersen 2011 for overfitted mixtures); belief functions (Shafer 1976); Craig 1953; Levin's Kt (cited as in model §1.3); nondeterministic time hierarchies; proof length (Pudlák 1998; Kreisel's conjecture, flagged); ILP (Muggleton 1991) and AS for the non-Bayesian treatment.
4. Open problems, collected and deduplicated (model §10; universal §13; pa §9.5; experiments §13): the every-w* statement (Thm 5.1(c)); Occam rate under L1 (Prop 5.6(d)); L1-only partial splits; the full class under misspecification (Rem 3.5); Conj 3.7; completeness under a shrinking threshold; Conj 6.15 and the derivation-penalised inducer; reversal in full calculi (universal §13 item 1); the race between hybrid families (N3(d), U16(d)); unknown selection learned jointly; posterior over all template unions; tree derivations in code (PA under L1); learned 𝒬; soundness bounds under misspecification; near misses; non-read-once induction templates (Conj 4.10).
5. Framing: checking, not building a prover.

---

## 10. `app-verification.tex` — key `ver` — ≈ 2 pp (written last)

**Purpose.** How the results were established, and every correction.

**Contents.**
1. Process: four research tracks (model, universal, pa, experiments), each reviewed by an adversarial referee with independent code; revisions; counts of referee issues (model: 0 fatal, 5 major, 16 minor, 6 questions; universal: 0, 3, 11; pa: 0, 5, 11; experiments: 0, 5, 14). Nothing is checked in a proof assistant; pa's derivations are checked by a small natural-deduction checker.
2. Table `tab:ver:corrections`: every refuted claim with its counterexample and where it is corrected (model: per-type subcriticality, Rem 1.10 sentence, Thm 5.1(b″), Prop 6.9, c5 remark, Thm 4.1 for Dirichlet weights, "[proved]" MDL sentence, "W* only grows", "finite sums", brief H6 sentence, Hänni's single-sorted consistency argument; universal: U11(e), the U3 remark, U16 three-hypothesis conclusion, U10(c) conflation; pa: Prop 3.5(c)/F8, SDPC constant margin, first SDPC artefact, head-split artefact, ∀E rate as general, overall answer, the Prop 1.4 argument, table entries; experiments: E2 "3 of 5", E2 n = 8 MAP list, E6 equivalence, constant-threshold promise, "robust at the level of theorems", held-out-instance claim, the "no false probe accepted" mean).
3. Table `tab:ver:conflicts`: the cross-track conflicts of `CLAIMS.md` and their resolutions (one line each).
4. Track-vs-referee disagreements resolved in favour of the final notes, with the reason (pa m11 anchor scope; pa M4 G1 remark; experiments M2 open-guard remark; universal M2 "→ 0 over Q"; model m13 tightness).
5. Reproduction: scripts per track (`checks/`), `code/run_all.sh`, seeds; byte-identical re-runs reported by universal and pa; references not verified.

---

## Global cross-reference map (who cites whom)

| from | to |
|---|---|
| intro | every section; `tab:intro:verdicts` |
| model | — (definitions; forward pointers only) |
| univ | `lem:model:size`, `def:model:variants`, `thm:ident:doob`, `thm:ident:kl`, `prop:ident:spare`, `thm:sound:fixed`, `def:sound:tri`, `tab:exp:e1`, `tab:exp:e3a` |
| ident | `lem:model:size`, `prop:model:max`, `prop:univ:memo`, `prop:univ:noguard`, `thm:univ:omega`, `prop:pa:detour`, `prop:pa:occam`, `tab:exp:e5`, `tab:exp:e8`, `tab:exp:e3a` |
| sound | `thm:ident:doob`, `thm:ident:limit`, `ex:ident:escape`, `prop:ident:spare`, `cor:univ:sound`, `tab:exp:e4`, `tab:exp:e2`, `rem:pa:lumps` |
| time | `def:model:variants`, `def:model:scores`, `rem:model:graded`, `prop:univ:robust`, `prop:univ:eqfrag`, `prop:pa:refl`, `prop:pa:memo`, `tab:exp:e7` |
| pa | `prop:ident:splits`, `prop:ident:splitlzero`, `prop:ident:splitlone`, `prop:ident:spare`, `prop:ident:gold`, `thm:ident:doob`, `thm:sound:avg`, `thm:sound:shrink`, `thm:univ:B`, `prop:time:notemplate`, `prop:time:collapse`, `tab:exp:e2`, `tab:exp:e3b`, `tab:exp:e6` |
| exp | the theorems each experiment tests (see §8) |
| disc | `CLAIMS.md` answers; open problems |

## Page budget

| file | main | appendix |
|---|---|---|
| abstract | ≤ 250 words | |
| intro | 4 | |
| model / app-model | 6 | 5 |
| universal / app-universal | 7 | 7 |
| ident / app-ident | 5 | 5 |
| sound / app-sound | 5 | 4 |
| time / app-time | 5 | 5 |
| pa / app-pa | 6 | 5 |
| experiments / app-experiments | 5 | 3 |
| discussion | 3 | |
| app-verification | | 2 |
| total | 46 (target ≈ 40: trim) | 36 |
