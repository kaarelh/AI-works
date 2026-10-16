# Outline: "\SAItitle: Definitions, Basic Theorems, and What a Theory Is and Does"

*Planning editor, 2026-10-16. Binding plan for every writer of `paper/`. Read it with `CLAIMS.md` (the ledger: every result with label, statement, source, status and rendering) and `NOTATION.md` (symbols and macros). The plan follows `research/notes-final.md` §5 (the synthesis's paper plan), adjusted to the final notation; every adjustment is listed in `plan-log.md`.*

---

## A. Binding notes

1. **Sources of claims.** Only the thread final records `research/tracks/<key>/notes-final.md` (keys `fundamentals`, `sfi`, `logic`, `terms`, `shape`, `laws`, `philosophy`), with their referee reports and `checks/`; the synthesis `research/notes-final.md` as corrected by `research/final-check.md` §4; the brief `research/00-brief.md`; Hänni's notes in `research/prior/` (for credit only). **Mathematics must match the records exactly:** hypotheses, quantifiers, constants, status. Never strengthen; when a record and the synthesis differ, the record (as corrected in `final-check.md`) wins. No new mathematics and no new literature claims.
2. **Epistemic policy (brief, binding).** The paper asserts only what we believe, whoever proposed it. The author's philosophical claims are hypotheses assessed on the merits; the verdicts are those of `philosophy` (synthesis §2). No "possible error in the author's view" note survived review (synthesis §7): none appears in the paper.
3. **The agreed stances** (brief, synthesis §2.3, §2.2 row L):
   * *What a theory is.* The idealised formalism cannot see the difference in shape (Craig collapse in every version); the intuition that theories are shaped like logical theories is plausible; what is missing is a formal setting in which shape matters. Two claims kept apart: **the descriptive claim** (human theories, as written, are declarative; caveat: procedural parts of theory in use), stated up front as an observation; **the explanatory question** (why that shape is good), open, necessarily relative to a reasoner or a community of reasoners. `shape`'s theorems are the best formal answer available and locate the large effects in the pair (reasoner, vocabulary), not in logical form.
   * *Existing language: the ladder.* (1) raw-data prediction; (2) answering questions posed with existing abstractions (\SAIabbr on a fixed language; the base language may be highly theoretical, not an observational language in the logical empiricists' sense); (3) theories that extend the language (theoretical terms; partial results here); (4) theories that revise the base abstractions (no formal handle; open). \SAIabbr sits on step 2 with partial results on step 3; step 2 is a step in the right direction and steps 3 and 4 are needed.
4. **Form (REFRAME, DECISIONS §A of the companion papers).**
   * First presentation of the material; voice "we". Motivate each definition, question and example on its merits.
   * No running-text citations, quotations of or replies to Hänni's working notes. Credit only in the short neutral footnotes of §C below and in the acknowledgements. Never "the author's notes ask …", "as anticipated in …", "Hänni conjectured …". Never a footnote inside a theorem-like statement or a float.
   * Statuses rendered in prose (CLAIMS.md §0): "we prove", "we conjecture", "a computation shows (code in the accompanying repository)". Proof sketches labelled as such and never stated as theorems. Computed numbers outside theorem statements. Conditional results under `assumption` environments.
   * **No process vocabulary in printed text**: no "thread", "track", "scout", "referee", "workflow", "agent", "record", "synthesis", "ledger", "brief", "notes-final", "revision", "verdict", check ids (c1, rb3, l10, …), script names, item numbers of the records, "H1–H15", "P1", "P2", "AI-paper", "TF", "SD". The only exception is the binding title-page footnote ("separate Claude instances acting as referees"). Also never "unverified", "snippet", "abstract level", "not checked".
   * Plain, precise, formal English; no marketing words; no model names or versions anywhere.
   * Every result keeps `\status{...}` and `\src{<thread> <item>}` (both print nothing).
   * References: only keys verified in `bib/bib-report.md`; content attributed to a work only at the level recorded there.
5. **Authorship.** Authors: Kaarel Hänni and Claude (Anthropic) (in `main.tex`, with the title-page footnote; do not edit). Hänni's notes are cited as "Hänni's working notes" (`hanni2026notes`).
6. **The name** is produced only by `\SAI`, `\SAItitle`, `\SAIabbr`; nothing depends on it. The introduction says in its first paragraph that "axiom" refers to the hypotheses, not to the induction axiom.

## B. Rules for writers

1. **Ownership.** Each file has exactly one owner (§F). Edit only your files. A need in another writer's file (a label, a moved result, a forward reference) goes into your log; the planning editor or the front writer resolves it. `main.tex`, `preamble.tex`, `NOTATION.md`, `OUTLINE.md`, `CLAIMS.md`, `build.sh`, `test-section.sh`, `merge_bib.py` belong to the planning editor; `bib/` belongs to the bibliography editor.
2. **Labels** exactly as in `CLAIMS.md` (`sec:`, `thm:`, `prop:`, `lem:`, `cor:`, `def:`, `ex:`, `rem:`, `conj:`, `q:`, `ass:`, `tab:`, `fig:`, `eq:` + `<key>:<name>`). You may add labels for equations and subsections (`eq:<key>:…`, `sec:<key>:…`). Never rename a ledger label. Cross-reference with `\cref`/`\Cref`; in tables use `\crefabbrev` inside the float.
3. **Every ledger row assigned to your files appears** with its label, `\status{}` and `\src{}`, rendered as CLAIMS.md says. A row you cannot fit in the page budget moves to your appendix (record it in your log); a main-text row may not be dropped.
4. **Proofs.** Main text: statement and a proof idea in 2–6 sentences, with `\cref` to the appendix proof; proofs of at most about six lines may stay in place. Appendix: full proofs, as in the record, naming any step the record leaves out. Proof sketches as Remarks headed "Proof sketch".
5. **Notation** only from `NOTATION.md` and the SAI macro block of `preamble.tex`. No `\newcommand` in section files except local ones prefixed with the section key (`\logicfoo`), defined at the top of the file, and only if unavoidable. Rename record symbols as NOTATION §11 says.
6. **Conventions.** Every loss statement names its convention (semimeasure, normalised, three-valued); every lower bound says which.
7. **Builds.** Isolated checks only: from `paper/`, `./test-section.sh <section> <appendix>` (e.g. `./test-section.sh basic app-basic`); undefined references to other sections are expected. The full build only as `cd /home/user/AI-works/solomonoff-axiom-induction/paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh`, and only when told to. Check `merge_bib.py`'s report: a cited key "supplied only by the fallback" has not been through the bibliography editor and must be replaced or reported.
8. **No git commands** that change repository state.
9. **Logs.** Each writer writes `paper/logs/log-<group>.md`: rows rendered (with any non-plain status "rendered as …"), rows moved to the appendix, page counts after the last isolated build, requests to other writers, citations used.
10. **Restart safety.** Save your files after each major part; on restart, read your own partial files and continue.
11. **Final greps** (each writer, on its own files): `grep -n -i -E 'thread|track|scout|referee|workflow|agent|record|synthesis|ledger|brief|notes-final|verdict|revision|snippet|unverified|abstract level|not checked|AI-paper|\bP[12]\b|\bH(1[0-5]|[1-9])\b|\bTF\b|\bSD\b'` on the .tex files outside `%` comments and `\src{}`/`\status{}` arguments; inspect every hit and remove every process use (legitimate uses such as "revision of the base abstractions" or a math hit such as $P_1$ may stay).

---

## C. Credit footnotes (at most 8; short and neutral; never in a statement or float)

| # | where (file, attach to) | text (to adapt, keep neutral) | what it credits (source in `research/prior/`) |
|---|---|---|---|
| F1 | `setting.tex`, the sentence introducing the proof-requiring and consistency-requiring variants (near `def:setting:variants`) or the trichotomy in `def:setting:MA` | "The proof-requiring and consistency-requiring variants, the three outcomes true, false and independent, and the choice to keep the defect of the semimeasure rather than renormalise first appeared in Hänni's working notes \citep{hanni2026notes}." | `hanni-solomonoff-axiom-induction.md` (the variants, the trichotomy, semimeasure vs renormalising vs 50/50); fundamentals Rem 1.6 |
| F2 | `soi.tex`, first sentence of §4 or the sentence before `thm:soi:coinfree` | "The comparison of \SAIabbr with consistent \SOIabbr, the example in which plain \SOIabbr beats \SAIabbr, and the axiom schema of `rem:soi:schema` first appeared in Hänni's working notes \citep{hanni2026notes}." | `hanni-solomonoff-axiom-induction.md` (consistent SFI, "always accept", $T(\gn\varphi)=\mathrm{accept}\to\varphi$) |
| F3 | `intro.tex`, the paragraph stating the two problems | "Several of the questions studied here first appeared in Hänni's working notes \citep{hanni2026notes}, among them whether theories are better seen as answering questions than as predicting raw data, and how a written theory relates to the reasoner who uses it." | `phil-sci-scientific-theories-are-not-for-generating-or-predicting-arbitrary-data.md`, `phil-sci-some-disanalogies-between-solomonoff-induction-and-science.md`, `phil-sci-science-predicts-only-very-particularly.md` |
| F4 | `shape.tex`, the first paragraph (the textbook point) — or `limits.tex` L1 if the shape writer prefers; only one of the two | "That written theories are far from sufficient for a simple reasoner, and are aids for a reasoner with much tacit understanding, is argued in Hänni's working notes \citep{hanni2026notes}." | `phil-sci-our-science-is-very-human-software.md` |
| F5 | `logic.tex`, the sentence before `prop:logic:oldevidence` | "The question of how checking instances can confirm a universal mathematical statement first appeared in Hänni's working notes \citep{hanni2026notes}." | `induction-in-mathematics.md` |
| F6 | `laws.tex`, the first paragraph (approximate laws, domains of applicability) | "The questions of approximately true laws and of the domain of applicability of a model are discussed in Hänni's working notes \citep{hanni2026notes}." | `phil-sci-the-domain-of-applicability-of-a-scientific-model.md`, `one-can-predict-right-without-having-the-correct-structure.md` |
| F7 | `limits.tex`, the sentence introducing `tab:limits:concepts` | "The list follows, with changes, an unpublished draft essay of Hänni's on concepts." (no citation key unless the bibliography editor adds one) | `hanni-condensation-concepts.md` |
| F8 | spare (use only if a writer finds a further item that first appeared in the notes; the front writer approves) | — | — |

The acknowledgements add one sentence: "Several of the questions and examples studied here first appeared in Hänni's working notes \citep{hanni2026notes}." No other place credits the notes.

---

## D. Sections and appendices

Main text about **42 pages** (11pt, `article`, margins 1.05in, as the companion papers); appendices about 55–70 pages. Order of `\input` (synthesis §5.3): abstract; §1 intro; §2 setting; §3 basic; §4 soi; §5 logic; §6 phil; §7 shape; §8 terms; §9 laws; §10 kepler; §11 limits; §12 related; §13 discussion (with acknowledgements and code and data); bibliography; appendices A basic, B soi, C logic, D phil, E shape, F terms, G laws, H kepler, I notation, J verification (internal, switched off by `\sairecordfalse`).

### Abstract — `sections/abstract.tex` (≤ 250 words; owner: front)
Carry (synthesis §5.2): the object (a random theory emitted by a universal machine; the prior is the probability that it is consistent and proves the data; predictions are a belief function with an independent outcome); the equivalence with consistent \SOIabbr version by version and the transfer principle (global rule 1); one logic result (the lottery, with true data and false theories, as a possibility result); the reasoner-relativity of theory shape (the textbook point, in its model); the dilemma theorem (what pays is relations or entities, not vocabulary); approximate laws as laws with calibrated error models; the philosophical upshot in one sentence ("the idealised formalism cannot see the difference between a theory and a program; where shape matters, it is relative to a reasoner and a vocabulary"). No credit footnote, no process words. (The checking statement is in the title-page footnote and the acknowledgements, not the abstract.)

### §1 Introduction — `sections/intro.tex` — 3 pp. (owner: front)
* **Contents.** (1) The two problems: what a theory does (predict raw data; answer questions; explain; solve problems) and what a theory is (a program; a set of sentences; a class of models; a practice). First paragraph: "axiom" refers to the hypotheses. (2) Raw-data prediction (Solomonoff induction) against answering questions posed with existing abstractions. (3) The object in one paragraph ($\MA$; the three outcomes; proof-requiring updating). (4) The ladder (A.3), \SAIabbr on step 2 with partial results on step 3. (5) A one-paragraph Kepler preview: K3 has content only in a geocentric data language (`prop:kepler:helio`, `prop:kepler:geo`), and what it is worth (`prop:kepler:K3worth`). (6) **Contributions** (`sec:intro:contrib`), one line each with section pointers, in this order: equivalence with \SOIabbr version by version and the transfer principle (§4); the lottery and $\Pi_1$ derandomisation (§5); reasoner-relative theory shape (§7); the dilemma theorem (§8); approximate laws (§9); the object and its basic theory (§3); the separations from \SOIabbr and where the time-bounded separations come from (§4); Gödel phenomena and the ω-gap (§5); best systems and explanatory power (§9); the Kepler computations (§10). (7) **What we do not claim** (`sec:intro:notclaim`): the idealised formalism cannot see shape; the descriptive claim is an observation; the explanatory question is reasoner-relative; nothing realist about induced theories; the textbook theorem is not about textbooks; the proof-requiring core is the noise-free special case. (8) Roadmap.
* **Labels.** `sec:intro`, `sec:intro:contrib`, `sec:intro:notclaim`.
* **Cites.** thm:soi:coinfree, thm:soi:onetape, thm:soi:transfer, thm:logic:lottery, cor:logic:false, thm:logic:threshold, cor:shape:regimes, thm:shape:invisible, thm:terms:dilemma, prop:laws:errormodel, thm:basic:loss, thm:basic:inc, prop:soi:freededuction, prop:soi:independent, prop:kepler:helio, prop:kepler:geo, prop:kepler:K3worth, sec:phil:observation, sec:limits:stat.
* **Sources.** synthesis §0, §1 (H1–H10 one line each, with "How to state it"), §2.3, §2.8, §5.3; philosophy §1.1–§1.2, §1.6; brief ("What a theory is", "Existing language").
* **Credit.** F3.

### §2 Setting — `sections/setting.tex` — 3 pp. (owner: core)
* **Contents.** Language, background, data sets (two- and three-valued), $D^\pm$, $\psi_D$, conditionals; fresh atoms and the literal language; theory machines and their laws; the universal theory machine, $\MA$, $\MAthree$, $\Inc_0$; the trichotomy $\Bel,\Dis,\Indep$, $\Bel_0$ vs $\Belhat_0$; class probabilities; loss conventions; the two defects; versions $\WA$, $\WAdec$, $\KA$, $\Kfin$ and the remark that deciders = enumerators = polynomial-delay enumerators; complexities $\Keq$, $\mmeq$, $\Exts$; variants (consistency-requiring, graded, generative); questions and conditional questions with (E3).
* **Labels.** def:setting:data, def:setting:fresh, def:setting:machine, lem:setting:measurable (app), def:setting:MA, def:setting:conventions, rem:setting:defects, def:setting:versions, rem:setting:versions, def:setting:complexities, def:setting:variants, def:setting:questions.
* **Cites.** ass:soi:S (forward, in `rem:setting:versions`(b)), prop:logic:normalised, thm:basic:order (forward, conventions), prop:shape:E2 (forward), thm:basic:dominance.
* **Sources.** fundamentals §1 (Defs 1.1, 1.1′, 1.2, Lemma 1.3, Examples, Defs 1.4, 1.5, Rem 1.6, Def 1.7, Prop 1.8(a)–(c), Def 1.9, Def 1.10, §1.8); logic §1.3 (conventions); shape Def 1.2 and §1.3 ((E2), (E3)); philosophy Def 2.0; terms Def 1.2 (literal language).
* **Credit.** F1.

### §3 Basic theorems — `sections/basic.tex` — 4.5 pp. (owner: core)
* **Contents (order).** Structure (`prop:basic:structure`); updating rules (`prop:basic:geometric`, `prop:basic:dempster`); computability (`prop:basic:form`, `thm:basic:inc`, `prop:basic:oracle`); dominance and invariance (`thm:basic:dominance`, `prop:basic:invariance`, `prop:basic:background`, `thm:basic:translation`, `cor:basic:vocabulary`); loss bounds (`thm:basic:loss`, `prop:basic:exceptions`, `prop:basic:mistakes`, `thm:basic:merging`, `cor:basic:threeloss`, `prop:basic:lower`); no coding theorem (`prop:basic:chain`, `thm:basic:nocoding`, `rem:basic:factortwo` one line); why proof-requiring is primary (short subsection: `prop:basic:cr`, `prop:basic:crorder`(a),(b), `prop:basic:graded`(e), `prop:basic:prcr`); limits and identification (`prop:basic:limits`, `prop:basic:textinformant`, `prop:basic:incomplete`); a remark-level paragraph on order dependence (`thm:basic:order`) and the Kolmogorov predictor (`thm:basic:kolmogorov`); `q:basic:domination` (or in app).
* **Labels.** As in CLAIMS.md §2 (main rows).
* **Cites.** def:setting:*, thm:soi:transfer (Rem 6.3-type transfer, `prop:basic:domination`), thm:terms:horn (forward from `cor:basic:vocabulary`), prop:basic:demski (app), sec:related.
* **Sources.** fundamentals §2–§8, §10, §11, §12.1 (refuted claims, as natural strengthenings), §7.5; the earlier report's Props 2.18, 2.19 (for credit of the countable-class forms).

### Appendix A — `sections/app-basic.tex` (owner: core)
* **Contents.** Proofs for §2–§3: `lem:setting:measurable`, `rem:setting:versions`; all §3 proofs; `lem:basic:demuth` (proved for completeness); `lem:basic:fresh`; `lem:basic:majority`; `prop:basic:wholetheory`; `prop:basic:crmix`; `prop:basic:limitpost`; `prop:basic:structures`; `prop:basic:noncomplete`; `cor:basic:localdefect`; `prop:basic:generative` and `rem:basic:generative` (proof sketch); `prop:basic:demski` (processes defined explicitly); `prop:basic:gradedgap`; `prop:basic:domination`, `q:basic:domination`; `prop:basic:tape`, `q:basic:tape`; `q:basic:indeporder`.
* **Labels.** `app:basic` (and `app:setting` as the label of its first subsection), plus the rows above.
* **Sources.** fundamentals (all proofs), its §14 for references.

### §4 Relation to \SOI — `sections/soi.tex` — 4.5 pp. (owner: soi)
* **Contents.** Objects on the \SOIabbr side (`def:soi:objects`); the four maps (one paragraph, `lem:soi:maps`); the coin-free equivalence (`thm:soi:coinfree`) and the schema remark (`rem:soi:schema`); the one-tape equivalence (`thm:soi:onetape`, `cor:soi:closed`); the assumptions (`ass:soi:S`, `ass:soi:Stape`, `ass:soi:F1`); axiom-side penalties (`thm:soi:penalty`, `prop:soi:classes`, one sentence each); the transfer principle (`thm:soi:transfer`, `cor:soi:transfer`, `rem:soi:encoding`); what breaks: closure (`prop:soi:closure`), the observed independent label (`prop:soi:independent`, `prop:soi:noRE`), the lottery between versions (one sentence, forward to `cor:logic:versions`), computability (`prop:soi:computability`); time bounds: one-sided equivalence (`cor:soi:onesided`), the diagonal (`thm:soi:diagonal`), incomparability (`prop:soi:incomparable`), "the separation comes from free deduction" (`prop:soi:freededuction`), reading (`rem:soi:timereading`); charged deduction as certificate \SOIabbr and its fit classes (`thm:soi:sandwich`, `cor:soi:fit`, `rem:soi:whatcharged`); Presburger (`prop:soi:presburger`, `prop:soi:presburgerCharged`, one-sentence pointer to `prop:soi:presburgerCond`, `rem:soi:presburgerSummary`); **Table 1** (`tab:soi`, about 25 rows: synthesis §3.1–§3.4 condensed, each row with a `\cref`); "how to read the table" (synthesis §3.5) as the closing paragraph.
* **Cites.** def:setting:*, thm:basic:dominance, prop:basic:structure, thm:basic:inc, thm:basic:nocoding, cor:logic:versions, thm:logic:lottery, lem:logic:density, thm:shape:knowhow (forward, from `rem:soi:whatcharged`), cor:terms:table and thm:terms:binary (forward, rows of `tab:soi`).
* **Sources.** sfi §0–§11 (items as in CLAIMS.md §3), §15; synthesis §3; the earlier report's Thm 6.3, Props 6.4, 6.5, Thms 6.14, 6.15, Props E.1, E.13, E.15, E.16, Thm 6.16, Cor 6.17 (cited by printed number).
* **Credit.** F2.

### Appendix B — `sections/app-soi.tex` (owner: soi)
* **Contents.** `lem:soi:mixture`, `lem:soi:maps` (full), proofs of `thm:soi:coinfree`, `thm:soi:onetape`, `cor:soi:closed`, `def:soi:penalised`, `thm:soi:penalty`, `prop:soi:classes`, `prop:soi:chain`, `thm:soi:transfer`, `cor:soi:transfer`, `prop:soi:price`, `prop:soi:closure`, `rem:soi:outcomes`, `lem:soi:productive`, `prop:soi:independent`, `prop:soi:noRE`, `rem:soi:product`, `prop:soi:computability`, `q:soi:lsc`, `prop:soi:pathwise`, `q:soi:pathwise`, `prop:soi:kt`, `thm:soi:domination`, `prop:soi:freededuction`, `rem:soi:freededuction`, `prop:soi:disguised`, `thm:soi:onetapetime`, `prop:soi:soft`, `rem:soi:F1`, `rem:soi:onetapesandwich`, `rem:soi:lengths`, `prop:soi:presburger`, `ass:soi:Bstar`, `ass:soi:SGL`, `prop:soi:presburgerCond`, `prop:soi:presburgerCharged`, `q:soi:presburger`; the circuit form (`thm:soi:circuit`, `cor:soi:circuitBayes`, `rem:soi:axiomsetprior`) in the appendix only. The proofs restated from the earlier report are cited by printed number and re-proved only where the record re-proves them.

### §5 Logic: random theories, $\Pi_1$ truth and Gödel phenomena — `sections/logic.tex` — 4.5 pp. (owner: logic)
* **Contents.** The lottery (`thm:logic:lottery`, with a picture of the lottery sentences, optional `fig:logic:lottery`; `rem:logic:lotteryremarks`); where it cannot happen (`prop:logic:arity` with the exact threshold, `prop:logic:true`, `prop:logic:core`, `cor:logic:Q1`, `cor:logic:onetrue` forward); the separation of versions of consistent \SOIabbr (`cor:logic:versions`); the rate (one sentence, `cor:logic:rate`), `q:logic:computablefast`; lotteries in arithmetic with true data and false limit theories (`thm:logic:arith`, `cor:logic:false`); $\Pi_1$ data (`thm:logic:threshold`, `cor:logic:coding`, `cor:logic:onetrue`, `cor:logic:chaitin` with its convention, `prop:logic:normalised`, `prop:logic:boundary`); Gödel phenomena (`prop:logic:shape`, `thm:logic:soundness`, `thm:logic:soundnessPi1`, `q:logic:soundness`, `prop:logic:con` with the truth hypothesis, `prop:logic:oldevidence`); the ω-gap (`prop:logic:omega`, `prop:logic:gaifman`, `thm:logic:goedelomega`, closures `rem:logic:closures`); $\Th(\mathbb N)$ (`thm:logic:thn`, `cor:logic:undecided`, `prop:logic:generic` in one paragraph; `q:logic:thn`). Ancestry in one paragraph at the end of the lottery subsection or in §12: majority vote of de Leeuw et al.; Kyburg's lottery paradox; bounded diagonally non-computable functions (only at the verified level).
* **Cites.** def:setting:*, thm:basic:dominance, prop:basic:chain, prop:basic:limitpost, lem:basic:majority, prop:basic:structures, prop:basic:noncomplete, thm:basic:inc, prop:basic:incomplete, thm:soi:onetape, thm:soi:coinfree, prop:soi:independent.
* **Sources.** logic §0–§7 (items as in CLAIMS.md §4), §12 (refuted Prop 4.5 form); sfi Cor 4.2; synthesis H2, H5, H9, H14.
* **Credit.** F5.

### Appendix C — `sections/app-logic.tex` (owner: logic)
* **Contents.** `lem:logic:density`, `lem:logic:flexible`, all proofs; `prop:logic:horizon`, `cor:logic:rate` (rate), `thm:logic:thresholdtheories`, `rem:logic:Wbound`, `q:logic:codingO1`, `prop:logic:extension`, `prop:logic:falsesigma`, `prop:logic:unsound`, `prop:logic:lines`, `ex:logic:lines`, `q:logic:kreisel`, `q:logic:soundtrue`, `prop:logic:generic`; the convention discussion (logic §1.3).

### §6 What a theory does and what it is — `sections/phil.tex` — 4 pp. (owner: phil)
* **Contents.** The two problems and the argument map (`sec:phil:map`, compact `tab:phil:map` built from synthesis §2.2); the descriptive observation and the explanatory question (`sec:phil:observation`, with the two qualifications: declarative is not sentential; theories in use have procedural parts; `q:phil:declarative`); questions against raw data (`def:phil:questions`, `prop:phil:answers`, `prop:phil:conservation`, `prop:phil:extractor`, `prop:phil:predicting`; `rem:phil:practice`; `rem:phil:purpose`); "what a theory is" after Craig (`rem:phil:craig`, forward pointers to §7 and §8); explanation (`prop:phil:flagpole`, `prop:phil:flagpolesystem` stated informally, precise statements in App D; explanation by correction and Copernicus by `\cref` to §9); **Table 2** (`tab:phil:differences`: advantages, neutral differences, liabilities). The Kepler data language (`def:kepler:language`) is used here as the illustration of a data language, questions, partiality and many-directional use (K3 gives $P$ from $a$ and $a$ from $P$), by forward reference.
* **What rests on theorems and what remains an argument** (synthesis §2.8, binding; reproduce its content in prose, never as theorems where it says "argument"):

  | claim | rests on | status |
  |---|---|---|
  | the idealised formalism cannot see the difference between a theory and a program | `thm:soi:coinfree`, `thm:soi:onetape`, `thm:terms:horn`, `thm:shape:invisible`, `prop:phil:flagpolesystem` | proved |
  | under a cost on the written theory, usefulness depends on the pair (reasoner, vocabulary), exponentially; declarative vs procedural only by a constant once intermediate concepts are available and the reasoner can chain | §7 | proved in `shape`'s model; beyond it open |
  | theoretical vocabulary is dispensable in the ideal mixture; relations or entities pay for finite theories and under charged deduction | §8 | proved in the stated settings |
  | Hempel's inductive-systematisation reply fails in the idealised Bayesian setting | `thm:terms:horn`, `rem:terms:hempel` | formal statement proved; the identification an argument |
  | answering questions differs from raw prediction by target, data type, coherence and partiality, not inference principle | `thm:soi:coinfree`, `prop:phil:answers`, `prop:phil:conservation`, `prop:phil:extractor`, `prop:soi:closure`, `prop:soi:independent` | proved; the reading an argument |
  | "Kepler is only approximately right" is a limitation of proof-requiring compatibility with deterministic theories, not of the axiom view as such; in $\MA$ an approximate law is a law with a calibrated error model | §9 | proved; computed on real residuals within stated pools |
  | simplicity among compatible forms is language-relative (noise-free regime); with graded fit the data decide | §10 | computed; conditional on the pool and the codes |
  | the descriptive observation | — | argument (observation) |
  | why declarative shape is good | — | argument; open |
  | claim D survives the objection from statistical practice | `rem:phil:practice` | argument |
  | explanation: unification sense with four gaps; asymmetry interventional? | `prop:phil:flagpole`, `prop:phil:flagpolesystem`, `prop:laws:correction` | toys proved; general claims arguments |
  | the axiom view models the declarative core and misses the procedural, statistical and dynamic sides | §11 | argument |
  | nothing realist should be said about induced theories | `cor:logic:false` | possibility result proved; the recommendation an argument |
* **Cites.** thm:soi:coinfree, thm:soi:onetape, prop:soi:closure, prop:soi:independent, prop:soi:freededuction, cor:basic:vocabulary, thm:basic:dominance, thm:basic:loss, thm:basic:translation, prop:basic:limits, prop:basic:structure, thm:logic:lottery, cor:logic:false, prop:logic:omega, prop:logic:normalised, thm:shape:invisible, thm:shape:directions, cor:shape:regimes, thm:terms:horn, thm:terms:KCV, thm:terms:dilemma, prop:laws:correction, prop:laws:copernicus, prop:laws:EP, def:kepler:language, sec:limits:stat.
* **Sources.** philosophy §1 (all), §2.1–§2.6, §3, §6 (only to confirm that no disagreement note appears); synthesis §2.1–§2.5, §2.8.

### Appendix D — `sections/app-phil.tex` (owner: phil)
* **Contents.** Proofs of `prop:phil:answers`, `prop:phil:conservation` (with the conservation-law computation, numbers outside statements), `prop:phil:extractor`, `prop:phil:predicting`, `prop:phil:flagpole`, `prop:phil:flagpolesystem` (precise statements).
* **Sources.** philosophy §2.1–§2.5, §3.1–§3.2 and their proofs.

### §7 Theory shape relative to a reasoner — `sections/shape.tex` — 4 pp. (owner: shape)
* **Contents.** The model (`def:shape:model`; conditional questions with (E3), `prop:shape:E2`; `prop:shape:bridge` in one sentence); program length sees nothing (`thm:shape:invisible`, `thm:shape:visible`); the exact minimum over the base variables (`prop:shape:onlyforced`, `thm:shape:minimum`, `cor:shape:simplex`); intermediate concepts and depth (`prop:shape:oneround`, `prop:shape:depth`, `rem:shape:simplexaux`); systems of laws (`thm:shape:systems`, worded as bib-report §4.1 says); **Table 3** (`cor:shape:regimes`, `tab:shape:regimes`); directionality (`thm:shape:directions`); where know-how lives and what charged deduction does not charge (`prop:shape:homes`, `thm:shape:knowhow`); learning (`thm:shape:learning` in a paragraph); depth against size for the chain (`thm:shape:spanner` in a paragraph); `q:shape:beyond`; the closing reading sentence (`rem:shape:reading`, synthesis H3 "How to state it", verbatim in substance, ending "It is not a theorem about textbooks.").
* **Cites.** def:setting:questions, def:setting:versions, thm:basic:dominance, thm:soi:sandwich, cor:soi:fit, rem:soi:whatcharged, sec:phil:observation, sec:limits:textbook.
* **Sources.** shape §0–§10, §12–§13 (items as in CLAIMS.md §6); synthesis H3; philosophy §1.4, §5.1.
* **Credit.** F4 (if placed here, not in §11).

### Appendix E — `sections/app-shape.tex` (owner: shape)
* **Contents.** All proofs of `shape` §1–§8: `lem:shape:forces`, `lem:shape:code`, `lem:shape:PI`, `lem:shape:circuits`, `prop:shape:primeimpl`, `prop:shape:cnf`, `lem:shape:subsumption`, `prop:shape:forced`, `cor:shape:core`, `rem:shape:dstar2`, `prop:shape:chainenc`, `prop:shape:library`, `prop:shape:private`, `lem:shape:arc`, `lem:shape:upcircuit`, `rem:shape:GK`, `prop:shape:rules`, `rem:shape:cellprobe`, `q:shape:cellprobe`, `def:shape:charged`, `lem:shape:noaux`, `q:shape:learning`, `prop:shape:midpoint`, `conj:shape:depth2`, `thm:shape:depth2`, `prop:shape:fixeddepth`, `q:shape:minimum`, `rem:shape:cutfree`, `prop:shape:lemmaenters` (first-order lemmas).

### §8 Theoretical terms: Craig, Ramsey and the theoretician's dilemma — `sections/terms.tex` — 3 pp. (owner: terms)
* **Contents.** Observational restriction (`def:terms:obs`, `def:terms:literal`, `def:terms:named`); Hempel's horn (`thm:terms:horn`, `rem:terms:hempel`); Craig in practice (`lem:terms:unary`, `thm:terms:padded`, `cor:terms:table`); elimination at polynomial cost (`prop:terms:eliminate`, `thm:terms:binary` informally); vocabulary or ontology (`thm:terms:regular`, `thm:terms:everyregular`, `cor:terms:ontology`, one binary relation, `prop:terms:ontology`, `prop:terms:binaryobs` in one sentence); finite theories with free deduction (`thm:terms:infinity` — the infinity separation, stated once — with `rem:terms:named` as a one-line variant; `thm:terms:PA`; `thm:terms:KCV`; `rem:terms:onetape`); Ramsey and Craig side by side (`prop:terms:ramsey`, `prop:terms:factoring`(d)); **the dilemma theorem** (`thm:terms:dilemma`) with "what this does and does not show"; Hempel's three replies against it (`rem:phil:hempel`, synthesis §2.4).
* **Cites.** def:setting:*, def:setting:fresh, cor:basic:vocabulary, thm:basic:translation, thm:soi:penalty, prop:soi:classes, thm:soi:sandwich, cor:soi:fit, ass:soi:F1, thm:logic:lottery, sec:phil:map.
* **Sources.** terms §0–§10, §17 (items as in CLAIMS.md §7); fundamentals Prop 1.8(d); philosophy §1.6; synthesis H4, §2.4.

### Appendix F — `sections/app-terms.tex` (owner: terms)
* **Contents.** `lem:terms:recheck`, `ex:terms:craig`, `lem:terms:pairing`, `prop:terms:a1fit`, `def:terms:twostack`, `lem:terms:twostack` (two-stack normal form), proof of `thm:terms:binary` (Thm 4.6 and the corrected alternating compile of Prop 4.7), `lem:terms:EF`, proofs of `thm:terms:regular`, `thm:terms:everyregular`, `cor:terms:freededuction`, `lem:terms:monadic`, `thm:terms:infinity`, `rem:terms:named` (proof), `prop:terms:bits`, `thm:terms:PA`, `rem:terms:PAtruth`, `thm:terms:KCV`, `prop:terms:ramsey`, `prop:terms:factoring`, `prop:terms:ontology`, `prop:terms:conservativity`, `prop:terms:binaryobs`, `prop:terms:a1hard`, `q:terms:binaryobs`, `q:terms:a1`, `q:terms:unaryfunction`.

### §9 Approximate laws and the best system — `sections/laws.tex` — 3.5 pp. (owner: laws)
* **Contents.** Setting (`def:laws:setting`); deterministic theories reward false exact laws (`prop:laws:strength`); precision regimes (`prop:laws:tolerance`, `prop:laws:rounding`); randomised theories and the two-part code (`prop:laws:randomised`, `prop:laws:twopart`); honest law, exceptions, error models (`prop:laws:peaked`, `prop:laws:errormodel`; `thm:laws:as` in a sentence); the real residuals (`tab:laws:residuals`, short); humility (`prop:laws:humility`); sound approximate reasoning and horizons (`prop:laws:sound`, `rem:laws:typical`); the best system as a steeper MAP: kind nature as a kink (`prop:laws:kink`), trivialisation blocked (`prop:laws:trivial`), laws versus initial conditions (`def:laws:EP`, `prop:laws:once`, `prop:laws:K3`); explanatory power and Myrvold (`prop:laws:EP`); Copernicus (`prop:laws:copernicus`); domains and retention (`prop:laws:domain`, `prop:laws:retention`, `rem:laws:domainlearning`, in a paragraph); explanation by correction (`prop:laws:correction`).
* **Cites.** def:setting:*, def:setting:questions, thm:basic:dominance, thm:basic:nocoding, prop:basic:structure, rem:terms:named, def:kepler:language, tab:kepler:residuals, sec:phil:map.
* **Sources.** laws §0–§9, §13 (items as in CLAIMS.md §8); philosophy §3.3–§3.4, §4.6; synthesis H8, H10; the companion paper on steeper priors (kink lemmas, `prop:kink:universal`, `cor:kink:split`).
* **Credit.** F6.

### Appendix G — `sections/app-laws.tex` (owner: laws)
* **Contents.** `prop:laws:exceptions`, `lem:laws:decidable`, proofs of `prop:laws:randomised`, `prop:laws:twopart`, `rem:laws:JR`, `q:laws:JR`, `prop:laws:P2hyp`, `prop:laws:codingbound`, `prop:laws:monotone`, `prop:laws:choice`, `lem:laws:tolerancelaw`, `prop:laws:rates`, `prop:laws:patches`, `prop:laws:quantile`, `lem:laws:codeR`, `prop:laws:fine`, `thm:laws:as`, `cor:laws:phases`, `prop:laws:horizon`, `prop:laws:exacthorizon`, `prop:laws:slopes`, `prop:laws:questions`, `rem:laws:correction`, `q:laws:domains`; the residual computations (numbers outside statements).

### §10 A worked example: Kepler and Newton — `sections/kepler.tex` — 3 pp. (owner: laws)
* **Contents.** The language and data (`def:kepler:language`); what the laws say in which language (`prop:kepler:helio`, `prop:kepler:geo`; `prop:kepler:ramsey` by a footnote pointing to App H); K3's worth (`prop:kepler:K3worth`, `ex:kepler:K3cost`); how wrong Kepler is (`tab:kepler:residuals`, the error budget against plan94); the Mars pool (`tab:kepler:minimax`, `tab:kepler:map` in three syntaxes, `ex:kepler:graded` in one paragraph, `tab:kepler:distances`); **Figure 1** (`fig:kepler:map`); what Newton adds (`sec:kepler:newton`, prose).
* **Figure.** `figures/kepler-map.pdf`, made by a script `figures/make_kepler_map.py` that reads the saved outputs of `research/tracks/philosophy/checks/` (no recomputation); the script and the figure are committed with the paper.
* **Cites.** prop:laws:K3, prop:laws:errormodel, prop:laws:correction, prop:laws:strength, tab:laws:residuals, def:setting:questions, sec:phil:map.
* **Sources.** philosophy §4 (all), §11 (statuses), its refuted/withdrawn list §11.1 (nothing refuted is printed); laws §3.6, Prop 5.5; synthesis H11, §2.6, §5.5 (statement discipline).

### Appendix H — `sections/app-kepler.tex` (owner: laws)
* **Contents.** The law texts in the three syntaxes; the Occam-factor computation and its cross-checks; the graded-fit computations; the distance search; the K3 computation; seeds and how to re-run (by description: "the scripts in the accompanying repository", never script names); `prop:kepler:ramsey` with proof; precise statements behind every number of §10.

### §11 Limitations — `sections/limits.tex` — 2.5 pp. (owner: phil)
* **Contents.** L0 statistical confrontation, first (`sec:limits:stat`): the proof-requiring core is the noise-free special case; partial handles (randomised theories, the generative variant, sentences about probabilities). L1 the textbook point with its three gaps (bridge, computational, tacit) and the refined claim (a property of the pair (theory, reasoner) and of the vocabulary, when what is written is what is charged) (`sec:limits:textbook`). L2 approximate truth (`sec:limits:approx`). L3 domains, several models, inconsistent theories in use, with the sound device and why it neither explains nor reproduces practice (`sec:limits:domains`). **Table 4** (`tab:limits:concepts`): the condensation essay's list (captured / partly / not), per synthesis §2.7. L4–L12 briefly (`sec:limits:other`). The verdict (synthesis §2.7 "Verdict").
* **Cites.** prop:laws:randomised, prop:laws:errormodel, rem:basic:generative, prop:phil:extractor, cor:shape:regimes, thm:shape:knowhow, prop:laws:strength, prop:laws:sound, rem:laws:typical, prop:laws:domain, thm:basic:translation, prop:basic:background, prop:logic:oldevidence, thm:terms:dilemma, thm:terms:horn.
* **Sources.** philosophy §5 (all), synthesis §2.7.
* **Credit.** F7 (and F4 if not placed in §7).

### §12 Related work — `sections/related.tex` — 2 pp. (owner: front)
* **Contents (topics, synthesis §5.7; keys only if `bib/bib-report.md` verifies them, content at its level).** (1) Universal induction and operator induction; the companion papers. (2) Probabilities on sentences (Gaifman, Scott–Krauss, Hutter et al., Demski, the modified Demski prior, logical induction): $\MA$'s belief violates the Gaifman condition exactly when instances do not prove the universal (`prop:logic:gaifman`); Demski-type priors end complete while $\MA$ keeps independent mass (`prop:basic:demski`); for complete theories PR = CR (`prop:basic:prcr`); the sampling stage of $\MA$ is the modified Demski prior's (no novelty claim for it). (3) Belief functions (only if verified). (4) Formal learning theory (Gold, Putnam, Shapiro's MIS, Osherson–Stob–Weinstein, Kelly, Martin–Osherson). (5) ILP and compression. (6) Bayesian theory learning in cognitive science. (7) Random axioms, Chaitin, probabilistic computation (lottery ancestry). (8) Gödel phenomena, Kreisel. (9) Craig, Ramsey, Hempel, theoretical terms. (10) Complexity used. (11) Knowledge compilation, propagation, circuits; declarative vs procedural. (12) Best systems, approximation, MDL. (13) Explanation and unification. (14) What a theory is. (15) Kepler, Newton, discovery systems. Also: the earlier reports \citet{claude2026axiominduction}, \citet{claude2026axiomschemas} as the computable, finite-class precursors (synthesis §4).
* **Novelty paragraph** ("To our knowledge …"): the single-draw proof-requiring law and its results; the one-tape and Kolmogorov equivalences and the transfer principle; the lottery's comparison of versions and its arithmetic versions; the $\Pi_1$ threshold and coding theorem for an inductive inference rule; the reasoner-relative separations inside a universal inducer (`thm:shape:systems` only as "we did not find it stated; it is probably known to specialists", bib-report §4.1); the derivation-bounded constructions and fit classes of §8; the approximate-law dichotomy. Never "random axiom systems are new".
* **Sources.** synthesis §5.7, §4; `bib/bib-report.md`; each record's literature section.

### §13 Discussion — `sections/discussion.tex` — 1 p. (owner: front)
* **Contents.** What the formalism shows and cannot show (synthesis §0 philosophy paragraph); **open problems** (`sec:discussion:open`): the five ★ questions by `\cref` (`q:basic:domination`, `q:logic:computablefast`, `q:logic:soundness`, `q:shape:beyond`, `q:phil:declarative`), then a sentence listing the other `q:` labels (CLAIMS.md §12); directions (ladder step 4; communities of reasoners; a costed-deduction mixture over unknown axiom systems, combining \SAIabbr with logical induction; a native treatment of statistical confrontation).
* **Acknowledgements** (`\section*{Acknowledgements}\addcontentsline{toc}{section}{Acknowledgements}`), adapted from the companion papers: "Several of the questions and examples studied here first appeared in Hänni's working notes \citep{hanni2026notes}. Independent instances of Claude checked each part: they re-derived the proofs and re-implemented the computations, and the results were revised in response. No human has yet independently checked all of the mathematics, and nothing was verified in a proof assistant; readers should weigh the results accordingly. Hänni takes responsibility for the content of this paper." (Hänni to confirm the last sentence.)
* **Code and data** (`\section*{Code and data}`): seeded or deterministic Python scripts (versions from the records' verification logs; the Kepler computations use pyerfa); the scripts, saved outputs and independent re-implementations are in the folder \texttt{solomonoff-axiom-induction/} of \url{https://github.com/kaarelh/AI-works}; its README lists the script behind each reported number; re-running reproduces the saved outputs apart from timing lines.

### Appendix I — `sections/app-notation.tex` (owner: front)
* **Contents.** A notation table built from NOTATION.md §1–§9 (symbol, meaning, where defined by `\cref`), one page or two; no process words.

### Appendix J — `sections/app-verification.tex` (internal; switched off; owner: front)
* **Contents.** How the results were checked, as an internal record: a status table of every main-text statement, corrections made in review, what was not checked (no proof assistant; references at the levels of bib-report; the modified Demski prior). It is **not** printed (`\sairecordfalse` in `main.tex`); never `\cref` it from another file.

---

## E. Page budget

| § | title | file | pages |
|---|---|---|---|
| 1 | Introduction | intro.tex | 3 |
| 2 | Setting | setting.tex | 3 |
| 3 | Basic theorems | basic.tex | 4.5 |
| 4 | Relation to \SOI | soi.tex | 4.5 |
| 5 | Logic | logic.tex | 4.5 |
| 6 | What a theory does and is | phil.tex | 4 |
| 7 | Theory shape relative to a reasoner | shape.tex | 4 |
| 8 | Theoretical terms | terms.tex | 3 |
| 9 | Approximate laws and the best system | laws.tex | 3.5 |
| 10 | Kepler and Newton | kepler.tex | 3 |
| 11 | Limitations | limits.tex | 2.5 |
| 12 | Related work | related.tex | 2 |
| 13 | Discussion (+ acknowledgements, code and data) | discussion.tex | 1 |
| | **main text** | | **42.5** |
| A–I | appendices | app-*.tex | about 55–70 |

Measure with `./test-section.sh <file>` (a section alone typesets on fresh pages; subtract the title-less overhead). *If the paper must be shortened below 40 pages* (synthesis §5.4): compress §3 (move `prop:basic:limits`, `prop:basic:textinformant`, `prop:basic:incomplete`, `thm:basic:order`, `thm:basic:kolmogorov` to App A), merge §8 into §6 and §7 (keep `thm:terms:dilemma` only), and cut §9 to the precision and error-model results. Do not split the paper.

---

## F. Writer groups (suggested; each file has one owner)

| group | files | pages (main) | depends on (labels from other groups, by `\cref` only) |
|---|---|---|---|
| core | setting.tex, basic.tex, app-basic.tex | 7.5 | ass:soi:S; thm:soi:transfer; thm:terms:horn; prop:logic:normalised; prop:shape:E2 |
| soi | soi.tex, app-soi.tex | 4.5 | core's §2–§3 labels; cor:logic:versions, lem:logic:density, thm:logic:lottery; thm:shape:knowhow; cor:terms:table, thm:terms:binary |
| logic | logic.tex, app-logic.tex | 4.5 | core's labels; thm:soi:onetape, prop:soi:independent |
| phil | phil.tex, app-phil.tex, limits.tex | 6.5 | almost every section (by `\cref`); the stubs keep builds passing |
| shape | shape.tex, app-shape.tex | 4 | def:setting:questions; thm:soi:sandwich, rem:soi:whatcharged; sec:phil:observation |
| terms | terms.tex, app-terms.tex | 3 | core's labels; thm:soi:penalty, prop:soi:classes, thm:soi:sandwich, cor:soi:fit, ass:soi:F1; thm:logic:lottery |
| laws | laws.tex, app-laws.tex, kepler.tex, app-kepler.tex, figures/ | 6.5 | core's labels; rem:terms:named; sec:phil:map |
| front | abstract.tex, intro.tex, related.tex, discussion.tex, app-notation.tex, app-verification.tex | 6 | everything; writes last, after the others report |

The groups can work in parallel: every label is fixed in CLAIMS.md, so a forward `\cref` resolves once the target writer has written it, and isolated builds tolerate undefined cross-section references. The full build is run by the front group (or the planning editor) at the end.

---

## G. The running example and secondary examples (synthesis §5.5)

* **Kepler's laws and the Mars pool:** previewed in §1 (K3 has content only in a geocentric language); used in §6 as the illustration of a data language, questions, partiality and many-directional use; returned to in §9 (the real residuals: a law with a calibrated error model); developed in §10 (the Mars posterior; what Newton adds); used in §11 for the textbook point's computational gap (deriving "Kepler within $\varepsilon$" from Newton needs a validated perturbation bound no textbook writes).
* **Secondary examples, one per mathematical section:** fresh atoms (two literals, no coding theorem) in §3–§4; the lottery in §5; the parity law and the hidden-state law in §7; "there are at least $n$ things" and observation sequences in §8; the flagpole in §6.

## H. Bibliography

* Keys come from `bib/core.bib` and `bib/refs.bib` (the bibliography editor's files; see `bib/bib-report.md` for the level at which each was verified and what each may support). `merge_bib.py` also reads `research/refs.bib` as a fallback; a cited key that resolves only through the fallback is reported by the build and must be cleared with the bibliography editor.
* References used in the records but not in the bibliography (synthesis §5.7 list: belief functions, randomness, logic and complexity textbooks, circuits and spanners, philosophy items) may be cited only once `bib/bib-report.md` lists them as verified; otherwise state the fact as standard without a citation, or drop it.
