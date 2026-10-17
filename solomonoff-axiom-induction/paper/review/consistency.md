# Consistency and arXiv-readiness review (whole paper)

*Reviewer: consistency and arXiv-readiness, 2026-10-17. Paper: `paper/` (main.tex and `sections/*.tex`), built under the lock with `flock /tmp/claude-0/paper-build-sai.lock ./build.sh`. The build gave 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels and 0 overfull boxes above 10pt. There were 2 BibTeX warnings, the intentional empty publisher of `shapiro1991inductive`, and the PDF has 230 pages. Status: complete. 25 issues: 0 fatal, 3 major, 22 minor.*

**Restart check.** No earlier `consistency.md` or `consistency.json` existed when this run began, so nothing had to be recovered. The four other review files in `review/` (`math-a`, `math-b`, `math-c`, `phil`) were read only to avoid duplicating them. Where an issue below overlaps one of theirs, it says so.

## What was checked, and with what result

The checks below are the evidence for the "no issue" verdicts. The issues follow in the next section.

| check | method | result |
|---|---|---|
| Labels and cross-references | full build; every row label of `CLAIMS.md` (338 rows, 321 distinct labels) compared with the `\newlabel`s of `main.aux`; grep for `\ref{` and hard-coded "Section/Table/Theorem N" | All present; no undefined or multiply defined labels; no raw `\ref`, no hard-coded internal numbers. Two `\cref`s point to the wrong place (issue 17). |
| Item numbers of the companion works | every "Theorem/Proposition/… N of \citet{…}", every `\citet[Theorem N]{…}` and every "the companion paper's Proposition N"/"of the earlier report" (128 references) checked against the `main.aux` of `../axiom-induction/paper`, `../solomonoff-operator-induction/paper` and `paper-steeper` | All 128 resolve to an item of the stated type and number. |
| Process vocabulary in the PDF | `pdftotext` of `main.pdf`, grep for `thread, track, scout, referee, workflow, agent, record, synthes, ledger, brief, notes-final, verdict, revision, snippet, unverified, abstract level, not checked, AI-paper, P1, P2, H1–H15, TF, SD, orchestrat, writer, superseded, earlier version, not written out, secondary level`; check ids (`c4`, `rb5`, `l10`, …); script names, `.py`, `checks/` | **Allowed hits.** "acting as referees" in the title-page footnote (the mandated exception, OUTLINE §A.4); "In brief"; "superseded theory" (ordinary use); "revision of the base abstractions"; "program synthesis"; "Synthese" and "Intelligent Agent Foundations Forum" in the bibliography; "tracks of one tape" (a multi-track tape); "Proof sketch. What is not written out …" (the form DECISIONS §A1 prescribes). **Other hits.** "every verdict below" (issue 16), and the process hedges of issue 15. Math-mode hits (c1, r1, p1, q1, H2) are symbols. |
| Printed status tags | grep for `[proved`, `[computed`, … in the PDF text | None. The only bracket hit is the formula P[not proved]. |
| Statuses rendered in prose | parsed all 304 theorem-like environments for their `\status{}` | Every environment has a `\status` and a `\src`. No sketch is stated as a theorem. `prop:shape:homes` and `thm:shape:knowhow` state only the proved part; the sketched derivation size is in `rem:shape:knowhowsketch`, headed "Proof sketch". Every proof-sketch remark has the heading. The one conjecture (`conj:shape:depth2`) is followed by "We have neither a proof nor a counterexample". The conditional result (`prop:soi:presburgerCond`) sits under the assumption environments (B*), (SGL). All 22 `question`s are cited in the Discussion's list. |
| Computed numbers outside statements | decimals inside theorem, proposition, lemma and corollary bodies | Only analytic constants and cross-paper item numbers: 0.361 = 1/(4 ln 2), 1.37, 1.443 = log e, 66.2° = 360°/(2e), the Euler–Mascheroni 0.5772, and 1.79 and 2.12. Computed figures are in examples, remarks, tables and prose, marked "a computation (code in the accompanying repository)". |
| Quotation of or reply to the working notes | grep for `Hänni`, `hanni2026notes`, "the author", "working note", and phrases of the notes ("very particular", "inert alone", "human software") | The notes are cited only in 7 credit footnotes and the acknowledgements; the eighth credit footnote, in `limits.tex`, names the draft essay without a key. There are no quotations, and no text frames a result as answering the notes. The paraphrases in `tab:limits:concepts` and §11 are covered by the footnote of `limits.tex`. |
| Credit footnotes | listed all `\footnote`s | 8 credit footnotes (F1–F8 of OUTLINE §C; F8 in `terms.tex`, approved in `logs/front.md` §4 and checked against `research/prior/good-concepts-are-concepts-that-support-inferences.md`) plus one content footnote (`kepler.tex`). None is inside a statement or a float. |
| Author line, title, metadata | `main.tex`; PDF title page | `\author{Kaarel H\"anni \and Claude (Anthropic)\thanks{…}}`; the footnote says that Claude is an AI system made by Anthropic, what each author did and how the results were checked, and names no model version. `pdftitle` and `pdfauthor` match. The name is produced only by the macros. The first paragraph says that "axiom" refers to the hypotheses. |
| Model names | grep for `opus, sonnet, haiku, claude-, gpt, gemini, llm, language model`, model version, in the PDF and sources | None. |
| Citation keys | all 223 cited keys extracted, outside comments and `app-verification.tex` | All 223 are in `bib-report.md` §5.1/§5.2 ("citable") or `core.bib`; none is on the "not citable" list (§5.3). The restricted uses are respected: Suppes–Zanotti "usually attributed to"; Pearl "as Pearl puts it"; Demuth "as attributed"; Löwenheim–Behmann only for decidability; Lanford "as described in expositions"; the modified Demski prior at the level of §3 items 1–5, with no definition quoted; Woodward 2014 and Sipser 1983 without pages. Not cited at all: Salmon 1971, Putnam 1963, Cook 1972, Tenenbaum et al. 2006, Mostowski 1952 and Kreisel–Lévy, so their restrictions cannot be broken. One exception: the pages of Håstad 1986 (issue 21). |
| Abstract | word count; claims against the body | 231 words (limit 250). It matches the body, apart from issues 3, 6 and 7. |
| Notation | `NOTATION.md` §0–§11 against the sources: macros for every global symbol; `\lambda` only as steepness; no `W_e` or `\varphi_e`; `\Exts` not `\Ext`; `\mathsf C`, `\mathrm{Cons}`; renames of §11 | No violation found in the printed text. The one deviation from §8.3 ("every arcminute figure is against plan94") is issue 12. |
| Code and data statement | saved outputs in `research/tracks/*/checks/*.out` (Python version lines); imports | Python 3.11.15 in all 54 version lines; mpmath (`sfi/checks/c3_presburger_constants.py`) and pyerfa (`philosophy/checks/c4_mars_pool.py`) are used; the longest saved run time is 1863 s, which fits "more than half an hour". The promised README does not exist (issue 2). |
| Same result stated the same way | abstract, §1 (contributions, "What we do not claim"), body statements, Tables 1–4 and 7, §12 "What is new", §13, against synthesis §1 "How to state it" lines, §2.8 and `final-check.md` §4 | Consistent, apart from issues 3–9 and 11–13. |

## Issues

### 1. [major] The main text is 63% over its page budget, and the whole paper is 230 pages

* **Location:** whole paper; budget in `OUTLINE.md` §E and synthesis §5.4.
* **Problem:**
  * The planned main text is about 42.5 pages, the planned appendices about 55–70 pages.
  * The build has about 69.5 pages of main text (§1 to Code and data, pp. 2–71), about 13 pages of references (pp. 71–84, 223 entries) and about 146.5 pages of appendices (pp. 84–230).
  * A reader who wants the results has to get through about 70 pages before the references. Every section is over its budget, most by 50–120%.
* **Evidence** (section start pages from `main.toc`):

  | § | budget | actual (pp.) | | § | budget | actual (pp.) |
  |---|---|---|---|---|---|---|
  | 1 Intro | 3 | 4 (2–6) | | 8 Terms | 3 | 6 (45–51) |
  | 2 Setting | 3 | 4 (6–10) | | 9 Laws | 3.5 | 6 (51–57) |
  | 3 Basic | 4.5 | 7 (10–17) | | 10 Kepler | 3 | 6 (57–63) |
  | 4 SOI | 4.5 | 10 (17–27) | | 11 Limits | 2.5 | 3 (63–66) |
  | 5 Logic | 4.5 | 6 (27–33) | | 12 Related | 2 | 3 (66–69) |
  | 6 Phil | 4 | 6 (33–39) | | 13 Discussion + ack. + code | 1 | 2 (69–71) |
  | 7 Shape | 4 | 6 (39–45) | | **main text** | **42.5** | **≈69.5** |

  `logs/front.md` records the same overrun ("about 27 pages over") and leaves it to the planning editor.
* **Fix:** this is a decision for the author. Either:
  * **(a)** record a revised budget in `OUTLINE.md`, for example main text ≤ 55 pages, so that the overrun is a decision rather than an accident; or
  * **(b)** apply the contingency cuts of OUTLINE §E and move further material to the appendices, keeping a one-sentence pointer in the main text:
    * **§4 (largest overrun).** Move §4.6 (charged deduction: `ass:soi:F1`, `thm:soi:sandwich`, the readings) and §4.7 (Presburger: `prop:soi:presburger`, `prop:soi:presburgerCharged`, the summary paragraph) to App. B. Keep Table 1, which already carries their content row by row.
    * **§8.** Keep `def:terms:obs`, `thm:terms:dilemma` and §8.6. Move `thm:terms:horn`, `thm:terms:padded`, `thm:terms:regular` and the prose of §8.3–§8.5 to App. F (OUTLINE §E already allows "keep `thm:terms:dilemma` only").
    * **§9.** Keep §9.1–§9.3. Move §9.4–§9.7 to App. G with a paragraph summary; `prop:laws:kink` and `def:laws:EP` are cited in the introduction, which can point to the appendix.
    * **§10.** Move the full posterior Table 6 to App. H and keep Figure 1 and Table 5.
    * **References.** 124 of the 223 cited keys are cited exactly once, 40 of them only in `related.tex`. Dropping the ones that only decorate lists (e.g. the lists in §12 "Laws, approximation, explanation, and what a theory is" and "Usable theories") shortens the 13 pages of references.

  Whichever is chosen, re-run the page count and update `logs/front.md`.

### 2. [major] The Code and data statement promises a README that does not exist

* **Location:** `discussion.tex`, `\section*{Code and data}`.
* **Problem:** the paper says "its README lists the script behind each reported number and how to re-run it". There is no `solomonoff-axiom-induction/README.md`, and the project is not yet in the project table of `CLAUDE.md`.
* **Evidence:**
  * `ls /home/user/AI-works/solomonoff-axiom-induction/` shows only `paper/` and `research/`.
  * The scripts are in `research/tracks/*/checks/` (49 scripts) and the independent re-implementations in `research/tracks/*/referee*code/` (68 scripts).
  * CLAUDE.md: "Add a new project as a new top-level folder, with its own README … Each project's README marks the paths that stay on its working branch."
* **Fix:** before the paper is published, write the README. It should contain:
  * a table mapping each section, table, figure or example to the script and saved output behind its numbers (e.g. "Table 6, Figure 1: `research/tracks/philosophy/checks/c4_mars_pool.py` → `c4_mars_pool.out`");
  * the Python and library versions (3.11.15; NumPy, SciPy, mpmath, pyerfa) and the seeds;
  * the run times;
  * the paths that stay on the working branch.

  Until then, soften the sentence to "the scripts and their saved outputs are in the folder …".

### 3. [major] The paper's upshot is stated in four places with four different, partly false, conditions

Also raised by `phil.md` issue 1; this entry adds the consistency evidence and one wording for all places.

* **Location:**
  * `abstract.tex`, the last sentence: "where shape matters, it is relative to a reasoner and a vocabulary";
  * `phil.tex`, `sec:phil:craig`, second paragraph: "Where shape matters, it is relative to a reasoner and a vocabulary, and only when the written theory is charged";
  * `discussion.tex`, "What the formalism shows": "it matters only when the written theory is charged or the class of hypotheses is restricted";
  * `limits.tex`, `sec:limits:textbook`: "visible only when what is written is what is charged";
  * `shape.tex`, `thm:shape:invisible` paragraph: "It becomes visible when what is written, or the time to write it, is charged".
* **Problem:** the sections disagree, and the "only when the written theory is charged" of §6 contradicts the paper's own results.
  * §7 shows the reasoner visible under the time-charged inducer too (`thm:shape:visible`(b)).
  * §8 shows relations and entities paying under charged *deduction*, which charges derivations, not the written theory.
  * §8 also shows them paying for *finite* theories (`thm:terms:dilemma`(ii)–(v)).
  * The synthesis states the claim only in `shape`'s model (§2.8 row 2: "proved in `shape`'s model … its extension beyond that model **open**").
* **Fix:** use one sentence, adapted to each place: "In the settings we study, the shape of a theory becomes visible only when something other than program length is charged (the written theory, the time to produce it, or the derivations) or the hypothesis class is restricted (finite theories); there it is relative to a reasoner and a vocabulary."
  * Abstract: "… where we find that shape matters, it is relative to a reasoner and a vocabulary."
  * §11: keep "visible only when what is written is what is charged", qualified by "in the model of §7".

### 4. [minor] The introduction states the closure separation without its loss convention

* **Location:** `intro.tex`, contribution (7).
* **Problem:** "logical closure and an observed 'independent' label separate them (`prop:soi:closure`, `prop:soi:independent`)". The closure separation holds in the semimeasure convention only: in the normalised convention consistent SOI predicts an entailed sentence with probability 1. Everywhere else the paper keeps the qualifier: `soi.tex` after `prop:soi:closure`, Table 1 row "entailed query", Table 3 item 2, and `phil.tex` ("unlike, in the semimeasure convention, …").
* **Evidence:** synthesis H7 "How to state it", as corrected in `final-check.md` §4 item 9: "in the semimeasure convention consistent SOI never becomes certain of a consequence".
* **Fix:** "(7) … in the semimeasure convention logical closure separates them, and so does an observed 'independent' label (…)".

### 5. [minor] Two places paraphrase part (iv) of the dilemma theorem more strongly than it is proved

* **Location:** `intro.tex`, contribution (4); `terms.tex`, `sec:terms:reading`.
* **Problem:**
  * The intro says that to fit more than the regular sets a finite theory needs "a polyadic theoretical relation or objects unlike every named one".
  * `sec:terms:reading` says "theoretical *entities* (objects outside the named structure)".
  * What `thm:terms:dilemma`(iv) and `thm:terms:regular` prove is narrower: a finite theory without theoretical vocabulary that fits a non-regular set must prove *some* $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-sentence false in the named structure. Only for the theory built in `thm:terms:binary` is that sentence $\exists z\,\mathtt s_1\mathtt s_1z=z$, true of no named object. A theory can be incompatible with $\ThT$ without positing such objects, for instance by identifying named terms.
  * Whether one unary theoretical *function* suffices is open (`q:terms:unaryfunction`).
* **Evidence:** `final-check.md` §4 item 8 corrected exactly this over-paraphrase in the synthesis (H4(iv)). `terms.tex` `thm:terms:dilemma`(iv) has the corrected form.
* **Fix:**
  * Intro: "… and a finite theory with only unary theoretical predicates and constants, compatible with the theory of the named objects, fits exactly the regular sets; one binary theoretical relation, or a theory that proves something false about the named objects, fits more."
  * `sec:terms:reading`: "theoretical entities (for the theory we build, objects outside the named structure)".

### 6. [minor] The abstract puts the Kolmogorov version under "up to constant factors"

* **Location:** `abstract.tex`: "version by version (coin-free, one-tape, Kolmogorov), SAI agrees with SOI over consistent labellers up to constant factors".
* **Problem:** the Kolmogorov versions agree up to an *additive* constant (`thm:soi:coinfree`(b)), as contribution (1) of the introduction says correctly.
* **Fix:** "… up to constant factors (additive constants for the Kolmogorov versions)", or "up to constants".

### 7. [minor] The abstract names the third outcome "open"; the rest of the paper calls it "independent"

* **Location:** `abstract.tex`: "a belief function with three outcomes: proved, refuted, open".
* **Problem:** the label is $\iota$, "independent", in `def:setting:data`, `def:setting:MA`, Table 1 and Table 3. In this paper "open" otherwise means an open question.
* **Fix:** "proved, refuted, independent", or "proved, refuted, or left open (independent)".

### 8. [minor] "The companion paper" is used in the introduction before it is cited or defined

* **Location:**
  * `intro.tex`, contribution (1): "the companion paper's results on binary labels …";
  * "Raw data and questions": "Solomonoff operator induction restricted to consistent labellers".
* **Problem:** the introduction never cites `claudeSFI2026fundamentals`. "The companion paper" is defined only in `setting.tex` ("which we call the companion paper").
* **Fix:** at the first mention of operator induction in §1, add "\SOI \citep{claudeSFI2026fundamentals} (the companion paper)".

### 9. [minor] Three sentences state the equivalence as an identity, against the binding form

* **Location:**
  * `discussion.tex`: "version by version, SAI is operator induction over consistent labellers";
  * `logic.tex` §5.1: "Since consistent SOI is SAI version by version";
  * `related.tex`: "SAI is operator induction in which the questions are sentences and deduction ties the answers together".

  The first sentence of `logic.tex` ("Up to constant factors, every version of SAI is …") is qualified and can serve as the model.
* **Problem:**
  * The binding "How to state it" of H1 is "SAI ≍ coin-free consistent SOI" for the coin-free version and "one-tape SAI ≍ one-tape consistent SOI" for $\MA$, never the unqualified identity.
  * The related-work sentence omits "consistent", and plain SOI on sentences differs from SAI (`rem:soi:encoding`).
* **Fix:** "… agrees, version by version and up to constant factors, with operator induction over consistent labellers". In `related.tex`: "SAI agrees, version by version and up to constants, with operator induction over consistent labellers of sentences".

### 10. [minor] Two sentences run together in the PDF because a `\src` call swallows the space

* **Location:** `phil.tex` line 45 (`\status{assessment (observation); open}\src{…}`, followed by a line break and `\emph{The observation:}`); `phil.tex` line 116 (after `(\cref{tab:phil:differences}).`).
* **Problem:** both macros end in `\ignorespaces`, so the line-break space after the call is eaten.
* **Evidence:** `pdftotext main.pdf` gives "which we keep apart.The observation: textbook presentations …" (text line 2101) and "neutral differences and liabilities (Table 3).What does not separate …" (line 2309). A scan of all sources for a call between a sentence end and the next sentence finds only these two.
* **Fix:** put a space before the call ("keep apart. \status{…}\src{…}\emph{The observation:}"), or move the calls to the start of the paragraph.

### 11. [minor] "The three codes we tried" in the introduction is easily read as the three syntaxes S1–S3

* **Location:** `intro.tex`, "A preview: Kepler's third law": "a law text of 115 to 375 bits in the three codes we tried".
* **Problem:**
  * The three codes of `ex:kepler:K3cost` are S1 (375 bits), Polish (165) and compact Polish (115).
  * §10 also uses three *syntaxes* S1, S2, S3 for the Mars pool. There $\mathrm{K3}$ costs 375, 450 and 375 bits (`tab:kepler:map` caption), and 450 lies outside the quoted range.
* **Fix:** "a law text of 375 bits in our arithmetic syntax and 165 or 115 bits in two Polish-notation codes".

### 12. [minor] "Every arcminute figure in this section is against plan94" is not true of the Moon figures

* **Location:** `kepler.tex`, opening paragraph; `NOTATION.md` §8.3.
* **Problem:** the Moon figures (1.1° within a month in `sec:kepler:wrong`; the Moon row of `tab:kepler:residuals`) are against moon98, as `app-kepler.tex` says ("for the Moon (moon98, geocentric)").
* **Fix:** "every positional error in this section is against the plan94 ephemeris (moon98 for the Moon), not against the sky".

### 13. [minor] Two residual tables use different fits for the same bodies, and the text mixes them without saying so

* **Location:**
  * `tab:kepler:residuals` (App. H): largest angular separation of a least-squares fit;
  * `tab:laws:residuals` (App. G): largest longitude error of the minimax fit;
  * `laws.tex`, first paragraph and `sec:laws:domains`.
* **Problem:** for the same windows the two tables differ:

  | body, window | App. H (least squares) | App. G (minimax) |
  |---|---|---|
  | Moon, one month | 1.12° | 30.9′ |
  | Moon, one year | 3.0° | 156′ = 2.6° |
  | Mars, 12 years | 1.58′ | 1.44′ |

  §9 cites the first table for "about a degree within a month" and the second for "the Moon (ε* = 2.6° over a year)". A reader comparing the two tables, or §9 with §10, sees conflicting figures.
* **Fix:**
  * One sentence in each caption, for example: "Least-squares fit, angular separation; the minimax longitude errors of the same windows are in Table 8 (App. G)".
  * In `sec:laws:domains`: "(ε* = 2.6° over a year, minimax fit)".

### 14. [minor] The ephemeris accuracies are taken from software documentation that is not cited

* **Location:** `kepler.tex` `sec:kepler:wrong` ("by the accuracy that the documentation of ERFA's routine quotes"); `app-kepler.tex`, "The error budget" (17″, 71″, 81″ against DE102; 26″, 78″, 87″ against DE200).
* **Problem:**
  * These figures carry the paper's claim that the 0.34′ gap between the vicarious hypothesis and the ellipse is "of the size of plan94's error".
  * They have no reference. Neither does the plan94 theory itself, nor moon98.
  * `bib-report.md` has no entry for ERFA, SOFA or the underlying planetary theory, and `math-c.md` C13 notes that these figures are not script outputs.
* **Fix:** ask the bibliography editor to verify and add references: the ERFA library (software citation with URL and version) and the source of the plan94 theory. Cite them where the accuracies are quoted, or state the figures as "quoted in the ERFA source code documentation of `eraPlan94` (URL)".

### 15. [minor] Process hedges about how sources were checked remain in the appendix and in §10

* **Location:**
  * `app-soi.tex`, the paragraph after `ass:soi:SGL`: "Berman's theorem \citep{berman1980complexity}, as reported in secondary sources, … if the reductions used were of linear size, **which we have not been able to check**";
  * `kepler.tex`, `sec:kepler:newton` item (3): "in the classical decomposition \citep{clemence1947relativity}, **as given by secondary sources**".
* **Problem:**
  * OUTLINE §A.4 and DECISIONS §A8 rule out "not checked" and every statement of *how* a source was checked.
  * Content beyond the verified level is to be stated as a pointer ("cf.") or as the paper's own reading.
  * `bib-report.md` §5.3 item 10 also rules out using "the form (B*) and the reduction sizes of Berman 1980".
* **Fix:**
  * `app-soi.tex`: "(B*) would follow from a linear-size hardness reduction for alternating doubly exponential time (cf. \citealp{berman1980complexity}); we do not assume one. If the reductions are only of polynomial size, …"
  * `kepler.tex`: "(cf. \citealp{clemence1947relativity})".

### 16. [minor] "verdict" appears in the printed text

* **Location:** `app-laws.tex`, "The Kepler residuals": "every verdict below is the same for the three values".
* **Problem:** "verdict" is on OUTLINE §A.4's list of forbidden process words. `logs/front.md` kept it as ordinary English, but the list is explicit.
* **Fix:** "every comparison below comes out the same for the three values".

### 17. [minor] Two cross-references point to the wrong place

* **Location and problem:**
  * (a) `shape.tex`, first paragraph: "by Craig's construction every consistent assigner of truth values is an axiom set at constant cost (\cref{thm:soi:coinfree,sec:phil:observation})". The statement is made in `sec:phil:craig` (`rem:phil:craig`, first sentence), not in `sec:phil:observation`.
  * (b) `limits.tex`, `sec:limits:other`: "heliocentric longitudes presuppose Copernican geometry; \cref{prop:kepler:geo}". `prop:kepler:geo` is about the content of $\mathrm{K3}$ in a geocentric language and says nothing about theory-ladenness.
* **Fix:**
  * (a) `\cref{thm:soi:coinfree,rem:phil:craig}`.
  * (b) point to `def:kepler:language` and `sec:phil:map` (paragraph "The ladder"), where the presupposition is discussed.

### 18. [minor] Environment titles in §10 and App. H are lower-case; everywhere else they are capitalised

* **Location:**
  * `kepler.tex`: `def:kepler:language` "[the Kepler languages and theories]", `prop:kepler:helio` "[no content in heliocentric directions]", `prop:kepler:geo` "[content in geocentric directions]", `prop:kepler:K3worth` "[what K3 does in geocentric directions]", `ex:kepler:graded` "[graded fit; a computation]";
  * `app-kepler.tex`: `prop:kepler:ramsey` "[the Ramsey sentence of Kepler's laws …]".
* **Problem:** all other environment titles start with a capital ("[The lottery]", "[Structure]").
* **Fix:** capitalise the first word of each title.

### 19. [minor] The companion works are cited in four different styles, 93 times as "Hänni and Claude (Anthropic) (2026a)"

* **Location:** throughout:
  * `setting.tex`, `basic.tex`, `soi.tex`, `app-basic.tex`, `app-soi.tex`, `app-logic.tex`, `app-laws.tex`, `app-terms.tex`.
* **Problem:**
  * The PDF has 93 occurrences of "Hänni and Claude (Anthropic) (2026a/c/d)". The works are distinguished only by the letters a–d, and the 2026a/2026c split is easy to misread.
  * The same works also appear as "the companion paper's Proposition A.2", with no citation, and as "Proposition 4.6(a) of the companion paper".
  * The steeper-priors paper appears as "the companion paper on steeper priors" in `app-laws.tex` and as "Hänni and Claude (Anthropic) (2026d)" in `laws.tex`.
  * All 128 item references resolve (see the table above), so this is about readability only.
* **Fix:** name the three works once, in `setting.tex`:
  * "the companion paper \citep{claudeSFI2026fundamentals}";
  * "the companion paper on steeper priors \citep{claudeSFI2026steeper}";
  * "our earlier report \citep{claude2026axiominduction}".

  Afterwards write "Proposition 4.7 of the companion paper" etc. without `\citet`, or define `\defcitealias` aliases. Use one style throughout.

### 20. [minor] The three statements of how the results were checked do not quite agree

* **Location:** title-page footnote (`main.tex`); `discussion.tex` acknowledgements; Code and data.
* **Problem:**
  * The footnote says the referees "re-derived the proofs and re-implemented the computations with independent code". The acknowledgements repeat this.
  * Code and data says "independent re-implementations of the **main** computations".
  * Some results are imported, not re-derived: `setting.tex` says of Lemma E.12 of the earlier report "which we do not re-derive"; several proofs in App. B are "Proposition E.13 of the earlier report".
  * The acknowledgements also repeat the footnote almost word for word.
* **Fix:**
  * Footnote: "… which re-derived the proofs of this paper's results and re-implemented its main computations with independent code."
  * Acknowledgements: keep only what the footnote does not say: the notes sentence, and the sentence on the earlier report and companion papers. "Readers should weigh the results accordingly" can stay.

### 21. [minor] The pages of Håstad 1986 are printed although they could not be re-confirmed

* **Location:** `bib/refs.bib`, `hastad1986almost` (`pages = {6--20}`); cited in `shape.tex` and `app-shape.tex`.
* **Evidence:** `bib-report.md` §2.4 says the pages "could not be re-confirmed … prefer citing without pages if in doubt"; §5.3 item 9 says the same.
* **Fix:** remove the `pages` field (the DOI identifies the paper).

### 22. [minor] The bibliography prints the working name outside the macro

* **Location:** `bib/core.bib`, `hanni2026notes`, note: "The note on Solomonoff axiom induction is in the folder …".
* **Problem:** NOTATION §0 rule 3 says the name is produced only by `\SAI`. If the author renames the family, the bibliography will still use the old name as though it were the paper's term.
* **Fix:** name the file as a file: "The relevant note is the file `solomonoff axiom induction.md` in the folder `ai/learning/solomonoff induction`."

### 23. [minor] Float placement: Table 3 lands in §7, and Table 1 overflows

* **Location:** `phil.tex` (`tab:phil:differences`, `[t]`); `soi.tex` (`tab:soi`, `[tp]`).
* **Problem:**
  * Table 3 (§6) is placed on p. 40, inside §7 (pp. 39–45).
  * Table 1 triggers "Float too large for page by 0.89507pt" (`build3.log`, input line 247).
* **Fix:**
  * Table 3: place it earlier in `phil.tex` (before `sec:phil:differences`) or use `[!t]`.
  * Table 1: shorten one row (e.g. the "axiom-side penalties" row; `math-a.md` issue 8 asks to reword it anyway) or set `\arraystretch` to 1.05.

### 24. [minor] arXiv does not list AI systems as authors: a submission variant of the front matter is needed

* **Location:** `main.tex`, `\author{…}`.
* **Problem:**
  * arXiv's policy on generative AI does not accept AI tools as authors.
  * The brief records the author's decision to list Claude as co-author "for the versions on github" and to change this "if we submit to arxiv".
  * No variant exists yet. The checking statement and the acknowledgements are written for a two-author paper; for instance, the "takes responsibility" sentence was removed for that reason.
* **Fix:**
  * Add a switch in `main.tex` (e.g. `\newif\ifsaiarxiv`) that gives the arXiv front matter: author line "Kaarel Hänni", with a footnote in the form of the companion papers (DECISIONS §A4: "developed and written with extensive assistance from Claude (Anthropic), an AI system, which produced …; checked by independent AI referees; no human has yet independently checked all of the mathematics").
  * Restore the responsibility sentence in that variant.
  * The GitHub version stays as it is.

### 25. [minor] The sources that arXiv would publish carry process vocabulary, file paths and internal decisions in comments and `\status`/`\src`

* **Location:** every `sections/*.tex` file (header comments; the `\status{…}`/`\src{<thread> <item>}` calls); `main.tex` ("Plan: OUTLINE.md; … ledger: CLAIMS.md"); `abstract.tex` and `discussion.tex` ("Author decision (2026-10-17) …").
* **Problem:**
  * arXiv makes the LaTeX sources downloadable.
  * The comments name threads, the synthesis, `final-check.md`, writers and the author's decisions.
  * The `\src` arguments name the records ("sfi Thm 2.1", "philosophy §4.4 Part A").
  * DECISIONS §A12 defers stripping them to a packaging step, so this is not a defect of the GitHub version.
* **Fix:** at submission, run the A12 packaging:
  * flatten the sources;
  * strip all `%` comments and all `\status{…}`/`\src{…}` calls with a brace-matching script;
  * upload `main.bbl`, not `bib/`;
  * leave out `app-verification.tex`, `build-test/`, `logs/`, `review/` and the planning files;
  * re-run the PDF grep of the table above on the result.

## Files written

* `paper/review/consistency.md` (this file) and `paper/review/consistency.json`.
* Throwaway scripts and the extracted PDF text are in the scratchpad (`/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/`: `main-raw.txt`, `cites.txt`, `tools/cites.py`, `tools/xref.py`, `tools/xref2.py`, `statuses.json`). They are not part of the repository.
* No source file of the paper was changed, and no git command was run.
