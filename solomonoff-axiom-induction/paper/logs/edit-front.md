# Edit log: group front (abstract, intro, discussion, app-notation, app-verification, main, preamble, bib)

*Editor pass of 2026-10-17, following `review/DECISIONS.md` (binding) and `review/issues-front.json`. Files edited: `sections/abstract.tex`, `sections/intro.tex`, `sections/discussion.tex`, `sections/app-notation.tex`, `sections/app-verification.tex`, `main.tex`, `bib/refs.bib`, `bib/core.bib`. `preamble.tex` is unchanged. No other group's file was edited. No git command was run. Pre-edit copies of the front files are in the session scratchpad (folder `orig/`).*

## Status

**Done.** All 24 front issues are handled (§1). All nine other edit logs report phase 1 done; every item they address to front is resolved (§2). Final full build under the lock (§3): 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt, no "Float too large", `merge_bib.py` 0 keys from the fallback; 223 pages. **The main text is 50.38 pages, 0.38 over the 50.0 cap**; three sections are over their maximum (§3, table). The front sections are at or under target.

## 1. Front issues

| id | what changed, where |
|---|---|
| **FRO-01** (major) | `abstract.tex`, last sentence: the short form of U1, verbatim ("The upshot: on data labelled true or false the idealised formalism cannot see the difference between a theory and a program; in the settings where we find that shape matters, it is relative to a reasoner and a vocabulary."). The abstract is 246 words after FRO-01 to FRO-04. |
| **FRO-02** | `abstract.tex`: "… agrees with \SOIabbr over consistent labellers up to constants". |
| **FRO-03** | `abstract.tex`: "three outcomes: proved, refuted, independent". |
| **FRO-04** | `abstract.tex`: "the reply to Hempel's theoretician's dilemma that Craigian axiomatisations are unmanageable becomes a theorem about Craig's construction, not about theoretical vocabulary". |
| **FRO-05** (major) | `intro.tex`, "What a theory is": first sentence is U4 verbatim; "So, on data labelled true or false, \SAIabbr cannot see the difference between a theory and a program"; added the clause "when ``independent'' is itself observed, partiality separates them (\cref{sec:phil:craig})" (U5's content, weaker than U5, so that the scope is visible in the introduction). `sec:intro:notclaim`, first sentence: "(on data labelled true or false it cannot see the difference)". |
| **FRO-06** (major) | `intro.tex`, contributions item on best systems (now item (9)): the decided text verbatim. |
| **FRO-07** | `intro.tex`, "Raw data and questions": "We take step 2 to be a step in the right direction, but not the end point: an account of what theories do needs steps 3 and 4 as well." |
| **FRO-08** | `intro.tex`, first paragraph: the decided sentence on the received view and van Fraassen verbatim; "Others hold that theories explain … or solve problems …, that they are classes of models …, or that scientific knowledge rests on exemplars and tacit skills \citep{kuhn1970structure,polanyi1958personal}". |
| **FRO-09** | `intro.tex`, item (7): "in the semimeasure convention logical closure separates them, and so does an observed ``independent'' label (\cref{prop:soi:closure,prop:soi:independent})". |
| **FRO-10** | `intro.tex`, item (4): the decided text from "vocabulary is eliminable at polynomial cost; and, with an empty background, …" to the end, verbatim. |
| **FRO-11** | `intro.tex`: first mention of operator induction is "\SOI \citep[\SOIabbr;][]{claudeSFI2026fundamentals}, developed in a companion paper"; afterwards "the companion paper". |
| **FRO-12** | `intro.tex`, Kepler preview: "against a law text of $375$ bits in our arithmetic syntax and $165$ or $115$ bits in two Polish-notation codes"; the qualifier "an extrapolation from Mars to the other planets, conditional on the code" kept. |
| **FRO-13** (major) | `discussion.tex`, "What the formalism shows": U1 long form with its first sentence shortened as allowed ("On data labelled true or false the idealised formalism cannot see the difference between a theory and a program."), then the rest of U1 verbatim with `\cref{q:shape:beyond}`; the plausibility sentence is U2 (discussion version) verbatim; the last sentence is the first sentence of U3, with `\cref{prop:laws:errormodel}`. "Four gaps" does not occur in the front files. |
| **FRO-14** | `discussion.tex`, "What it cannot show": "It supports no general realist conclusion about the theories it favours: it identifies a complete r.e.\ theory that the data present (\cref{prop:basic:limits}), but its limit posterior can live on random theories and, with adversarially chosen true data, on false ones (\cref{thm:logic:lottery,cor:logic:false})." |
| **FRO-15** | `discussion.tex`: "the inference principle is unchanged: version by version and up to constant factors, \SAIabbr agrees with operator induction over consistent labellers (\cref{sec:soi})". The introduction says the same ("agrees, up to constants"; item (1) "agrees with consistent \SOIabbr", in place of "is consistent \SOIabbr"). |
| **FRO-16** | `main.tex`, title-page footnote: "The results were checked by separate Claude instances acting as referees, which re-derived the proofs of this paper's results and re-implemented its main computations with independent code." Acknowledgements: the sentence that repeated the footnote is deleted; kept the sentence on Hänni's working notes, the sentence on the earlier report and the companion papers (its "in the same way" now reads "in the same way as this paper", since the sentence it referred to is gone), and "No human has yet independently checked all of the mathematics, …; readers should weigh the results accordingly." The responsibility sentence is not reinstated. |
| **FRO-17** | `bib/refs.bib`, `hastad1986almost`: pages field deleted; DOI kept. |
| **FRO-18** | `bib/core.bib`, `hanni2026notes`: note = "Accessed October 2026. The relevant note is the file \texttt{solomonoff axiom induction.md} in the folder \texttt{ai/learning/solomonoff induction}." (The file exists at that path in the notes repository.) |
| **FRO-19** (major) | No text change: the Code and data sentence "its README lists the script behind each reported number and how to re-run it" stays. **Blocking item for the publication step (DECISIONS §X9):** before the project is published to `main`, write `solomonoff-axiom-induction/README.md` with a table from each section, table, figure and computed example to its script and saved output (`research/tracks/*/checks/`, `referee*code/`), Python 3.11.15 and the library versions (NumPy, SciPy, mpmath, pyerfa), seeds, run times, the paths that stay on the working branch, and add the project to the table of the root `CLAUDE.md`. |
| **FRO-20** | `app-notation.tex`: $\Omtail{\ell}$ and $\Kpad$ point to `sec:setting:data` (BAS-04); the comment "used without a displayed definition" is gone. Other pointers updated from the groups' logs (§2). |
| **FRO-X19** | §U7: intro, first mention "\SOI (\SOIabbr; companion paper), developed in a companion paper", then "the companion paper" (item (1); the possessive form is avoided). Discussion: one citing sentence, in the acknowledgements, "our earlier report \citep{claude2026axiominduction} and … the companion papers \citep{claudeSFI2026fundamentals,claudeSFI2026steeper}". No `\citet` of the companion works in the front files. |
| **FRO-L1** (major) | §1: list A and list B applied. Sizes in bytes of source (decided limits in brackets): opening paragraph 1,364 [1,300] (FRO-08 text and footnote F3 kept; F3 unchanged); "The object" 737 (no limit; the semimeasure-defect clause and the Dempster sentence dropped, both are in §2–§3); "Raw data and questions" 1,658 [1,550] (FRO-07 and FRO-11 add about 200); "What a theory is" 1,291 [1,200] (U4 and the partiality clause added); Kepler preview 1,142 [1,100]; "Organisation" 301 [400]. Contributions: eleven items became ten; the item "What a theory does" (extractor; flagpole) was dropped from the list (its results are cited in §1 through `sec:phil:questions` and stated in §6 and App D; no result is dropped from the paper); the Kepler-residuals clause of item (5) was dropped from the list (it is in §9); the other items were shortened, keeping every qualifier of `final-check.md` §4 (transfer only up to additive constants; the factor $m$ over the base variables or with one round and at most $9$ only with intermediate concepts and unbounded rounds; the true-data lottery as adversarial; closure in the semimeasure convention; $B=\emptyset$ for finite theories). The contributions list is about 4,500 bytes, over its 3,600 guide, because the decided texts of FRO-06 and FRO-10 are long; to compensate, list B was applied: "What we do not claim" is one paragraph of four sentences (948 bytes) after the contributions, `\paragraph{What we do not claim.}\label{sec:intro:notclaim}` (no other file cites the label). §1 measures **2.96 pages** (target 3.00). |
| **FRO-L2** (major) | §13: list A and list B applied. "What the formalism shows" 1,720 bytes [1,350] (the decided U texts alone are about 1,300; the summary sentence on what logic adds was dropped, it is §5); "What it cannot show" 628 (one sentence on what the axiom view misses, plus FRO-14); "Directions" 819 [800]; acknowledgements 491 [450] (FRO-16); list B: the sentence listing the further questions is now "The further questions are \cref{…}" with all seventeen remaining question labels (every `q:` label of the paper is cited in §13: the five problems plus seventeen). §13 with acknowledgements and code and data measures **1.70 pages** (target 1.75). |
| **FRO-F** (major) | Final phase done (§3, §4). |

## 2. Requests from the other groups' logs (all resolved)

| from | request | resolution |
|---|---|---|
| basic | FRO-20: $\MAhalf$ now in `def:setting:graded`, $\Xi$ in `def:setting:generative`, $K_A^{\mathrm{gen},t}$ in `def:setting:versions`, $\Omtail{\ell}$ and $\Kpad$ in `sec:setting:data` | Notation table: the row of `def:setting:variants` now lists only $\MAnc$, $\Belnc_D$, $\Disnc_D$ ($\epsempty$ has its own row); new row "$\MAhalf$; $\Xi$ → `def:setting:graded`; `def:setting:generative`"; new row "$K_A^{\mathrm{gen},t}$ → `def:setting:versions`"; $\Omtail{\ell}$, $\Kpad$ → `sec:setting:data`. |
| basic | status table: `def:setting:complexities` now "definition"; new labels `rem:setting:complexities`, `def:setting:graded`, `def:setting:generative`, `par:setting:*` | The status table of App J was regenerated from the sources (§4); items now in appendices are not listed there by design. |
| basic | check `app-logic.tex`'s `\cref{rem:setting:complexities}` | Checked: the reference resolves and the sentence reads correctly. |
| soi | notation: $\Kpad$ → `sec:app:soi:literals`; $W_A[t,s]$, readings → `sec:soi:charged,sec:app:soi:charged`; $\Wcert$ → `sec:app:soi:charged` | Done for the last two. $\Kpad$ points to `sec:setting:data` instead, as FRO-20 and BAS-04 decide (it is now defined there). |
| soi | intro citing `thm:soi:sandwich`, `cor:soi:transfer` | Checked: the intro wording fits (they print as Theorem B.31, Corollary B.12). |
| phil | notation: $\mu$, $\eta$, $\mu_\eta$ → `app:phil:extractor` | Done. |
| phil | measure §6 with both tables; confirm `tab:phil:differences` inside §6 | Table 3 (`tab:phil:differences`) is on p. 28, inside §6 (pp. 24–29). Table 2 (`tab:phil:map`, `[t]`) is placed at the top of p. 24, above the end of §5 and the §6 heading, so the heading-to-heading measure counts it (about 0.19 page) in §5; see §3. |
| phil | "four gaps" in front files | None occurs. |
| shape | notation: $\Kt$ → `prop:shape:timecharged` or `sec:shape:invisible` | Points to `sec:shape:invisible` (where the main text names Levin's $\Kt$); $K^q$ stays at `sec:shape:homes`. |
| shape | status table: `prop:shape:timecharged`; source of `thm:shape:visible` | Regenerated table carries the new source "shape Thm 1.12(a), (c)"; `prop:shape:timecharged` is in App E, so not listed (by design). |
| shape | Table 3 floating into §7 | No longer: Table 3 is in §6 in the final build. |
| terms | notation: $\mathcal C_\Theta$ → `def:terms:classes` | Done (row now "`def:terms:obs`; `def:terms:classes`"). |
| laws | notation rows; `def:laws:EP` now in App G; intro item on best systems | Rows for $\EP_D$, $\mathrm{BC}_{\mathcal G}$ unchanged (they resolve); new rows "regimes G, R; $p_\Delta$, $s_\Delta$ → `def:laws:setting,def:laws:settingfull`" and "$P^R_T$; $A_T$; $J^Q_\lambda$, $J^F_\lambda$, $J^R_\lambda$ → `def:laws:settingfull`". The intro's `\cref{prop:laws:kink,def:laws:EP}` prints "Proposition 9.3 and Definition G.29", as foreseen. |
| kepler | intro citations of moved labels; notation | Checked: wording fits; $\Occ_{\mathsf F}$ and S1–S3 still at `sec:kepler:pool`. |
| logic, limits | none to front | — |

**Forwarded, not addressed to front (for the lead editor; the front's task covers only its own files):**
* terms → limits: `related.tex`, "Craig, Ramsey, Hempel": "…, which \cref{sec:terms} sets against our results" refers to all three replies, but §8 now discusses only impracticality and inductive systematisation (the Putnam reply was cut from §8 by TER-L1 list B). Suggested: "\Cref{sec:terms} sets the first two against our results." Not applied by the limits group.
* soi → terms (optional): `terms.tex`, `def:terms:literal`: `\cref{sec:soi:charged,sec:app:soi:charged}` would point to the formal setting; the present sentence is still true.
* limits: LIM-08 kept the word "limiting" in the sentence on Sawin and Demski (the lead editor may delete it).

## 3. Final full build and length (DECISIONS §F.2, §F.3)

`cd paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh`, last run 2026-10-17 after all edits:
* LaTeX errors 0; undefined references 0; undefined citations 0; multiply defined labels 0; overfull boxes above 10pt 0 (largest 8.37pt); no "Float too large"; `merge_bib.py`: 219 cited keys, 0 missing, 0 from the fallback; BibTeX: one warning, the intentional empty publisher of `shapiro1991inductive` (bib-report §1). **223 pages.**
* Internal record: a scratch copy built with `\sairecordtrue` (App J switched on): 227 pages, 0 errors, 0 undefined references, 0 overfull boxes above 10pt.

**Page table** (measured as in §L1: each section from its heading to the next heading, word positions from `pdftotext -bbox`, fractions of the text block; script in the session scratchpad, `front/measure.py`; §13 includes the acknowledgements and code and data, up to the heading of the references):

| § | file | target | max | final | |
|---|---|---|---|---|---|
| 1 | `intro.tex` | 3.00 | 3.25 | **2.96** | |
| 2 | `setting.tex` | 3.75 | 4.00 | 3.76 | |
| 3 | `basic.tex` | 4.50 | 4.75 | 4.58 | |
| 4 | `soi.tex` (Table 1) | 5.50 | 5.75 | **5.78** | over max by 0.03 |
| 5 | `logic.tex` | 4.75 | 5.00 | **5.17** | over max; includes Table 2 of §6 (about 0.19 page, placed at the top of the page where §6 starts); without it about 4.98 |
| 6 | `phil.tex` (Tables 2, 3) | 4.75 | 5.00 | 4.81 | about 5.00 with Table 2 counted here |
| 7 | `shape.tex` (Table 4) | 4.50 | 4.75 | 4.67 | |
| 8 | `terms.tex` | 3.50 | 3.75 | **3.88** | over max by 0.13 |
| 9 | `laws.tex` | 3.50 | 3.75 | 3.67 | |
| 10 | `kepler.tex` (Table 5, Figure 1) | 4.25 | 4.50 | 4.33 | |
| 11 | `limits.tex` (Table 6) | 2.50 | 2.75 | 2.65 | |
| 12 | `related.tex` | 2.25 | 2.50 | 2.43 | |
| 13 | `discussion.tex` (+ ack., code and data) | 1.75 | 2.00 | **1.70** | |
| | **main text** | 48.50 | **50.00** | **50.38** | **over the cap by 0.38** |

The baseline full build at the start of this phase (other groups' edits in, front unedited) measured 51.32 pages (§1 3.60, §13 1.96). Title page, abstract and contents: pp. 1–2; references pp. 52–64; appendices A–I pp. 65–223 (A 23, B 22, C 20, D 8, E 21, F 23, G 26, H 11, I 4.5 pages).

**Sections over target (DECISIONS §F.3), for list-B moves:** §4 `soi` (5.78), §8 `terms` (3.88), and §5 `logic` as measured (5.17; 4.98 if Table 2 is attributed to §6). All three groups report list B already applied, so no prescribed move remains; the remaining 0.38 page needs a decision of the lead editor (for example the soi group's own candidates: dropping the `\subsection{Summary}` heading and shortening the summary sentences of SOI-L1 items 1 and 3; for terms, the §8.3 elimination paragraph, now about 1,900 bytes against its 1,100 target). Two observations on the measurement: (i) cuts in §1 are partly absorbed by the page breaks of §2–§5 (shortening §1 from 3.19 to 2.96 pages and §13 from 1.76 to 1.70 lowered the total only from 50.52 to 50.38), while cuts at the end of the main text move the total one for one (a test without the Directions paragraph gave 50.19); (ii) the front sections were not cut below their targets beyond this, since the remaining excess lies in sections whose groups' lists are exhausted, and further cuts in §1 and §13 would remove substance (the decided U texts alone are a quarter of §13's first paragraph).

## 4. Records (DECISIONS §F.4, §F.5)

* **Final greps on `pdftotext main.pdf`:** rule 0.8 pattern: the only hits are the title-page footnote's "referees", "Agent Foundations Forum" (a venue name in the bibliography), "tracks of one tape" (multitape simulation), "the revision of the base abstractions", and mathematical symbols ($P_1$, $H_2$, $\Sigma^p_2$); model names 0; no printed status tag (the one regex hit, "P[not proved]", is a probability); "referee" occurs once, in the title-page footnote; every `q:` label is cited in §13.
* **Status table of App J** (`app-verification.tex`, switched off) regenerated from the `\status` and `\src` arguments of the main-text files with the front writer's script (`front/tools/statustable2.py` in the session scratchpad, a copy of `statustable.py` that adds line breaks in labels): 83 rows (was 127; the difference is the items moved to appendices, which App J does not list by design). Three labelled paragraphs without `\status` (`sec:logic:thn`, `sec:shape:homes`, `sec:shape:learning`) read "summary of the results it cites". App J also gained a paragraph "Review and editing" (five reviews, 86 issues: 0 fatal, 14 major, 72 minor; the lead editor's decisions; ten editing groups; examples of corrections; the moves to appendices).
* **`CLAIMS.md` "place" column:** not updated. DECISIONS lists it as optional for front; the front's task for this pass lists only the front files. The moved labels are listed below for whoever updates it.

**Moved labels (main text → appendix, from the groups' logs; no label renamed or removed):**
* App A (basic): `rem:setting:versions`, `rem:setting:complexities` (new), `par:setting:examples` (new), `par:setting:defects` (new), `par:setting:E3` (new), `def:setting:graded` (new), `def:setting:generative` (new), `prop:basic:dempster`, `prop:basic:form`, `prop:basic:invariance`, `prop:basic:background`, `prop:basic:exceptions`, `prop:basic:mistakes`, `thm:basic:merging`, `cor:basic:threeloss`, `prop:basic:lower`, `prop:basic:crorder`.
* App B (soi): `cor:soi:closed`, `ass:soi:S`, `ass:soi:Stape`, `thm:soi:penalty`, `cor:soi:transfer`, `rem:soi:encoding`, `prop:soi:noRE`, `cor:soi:onesided`, `ass:soi:F1`, `thm:soi:sandwich`, `prop:soi:presburgerCharged`, `prop:soi:presburger`, `rem:soi:presburgerSummary`.
* App C (logic): `prop:logic:arity`, `cor:logic:chaitin`, `prop:logic:normalised`, `thm:logic:soundnessPi1`, `prop:logic:oldevidence`, `thm:logic:goedelomega`, `rem:logic:closures`, `thm:logic:thn`, `cor:logic:undecided`, `q:logic:thn`; `sec:logic:thn` is now a paragraph label in §5.5.
* App D (phil): `def:phil:questions`, `prop:phil:answers`, `prop:phil:extractor`, `prop:phil:flagpole`.
* App E (shape): `prop:shape:onlyforced`, `cor:shape:simplex`, `prop:shape:oneround`, `prop:shape:depth`, `prop:shape:timecharged` (new; former part (b) of `thm:shape:visible`); `sec:shape:homes`, `sec:shape:learning` are now paragraph labels in §7.6.
* App F (terms): `thm:terms:horn`, `def:terms:classes` (new), `thm:terms:padded`, `thm:terms:regular`, `def:terms:named`.
* App G (laws): `prop:laws:rounding`, `rem:laws:typical`, `def:laws:EP`, `def:laws:settingfull` (new).
* App H (kepler): `prop:kepler:geo`, `ex:kepler:K3cost`, `ex:kepler:graded`, `tab:kepler:minimax`.
* §11 (limits): the six subsections are paragraphs with the same labels. §1 (front): `sec:intro:notclaim` is a paragraph label.

## 5. Items for the author (not this pass)

* README of the project (FRO-19, DECISIONS §X9), blocking for publication.
* Verified references for the ERFA library and the planetary theory behind plan94 (DECISIONS §R, consistency 14).
* arXiv variant of the front matter and packaging (DECISIONS §R, consistency 24, 25).
