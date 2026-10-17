# Edit log, group soi (sections/soi.tex, sections/app-soi.tex)

Status: PHASE 1 DONE (2026-10-17). All ten issues of `review/issues-soi.json` fixed as decided; list A and list B of
§L3 (soi) applied in full; extra prose cuts and a compaction of Table 1 recorded below. Only `sections/soi.tex` and
`sections/app-soi.tex` were edited. No git commands.

Binding: review/DECISIONS.md (§0, §U1, §U7, §L, §G-soi, §X), review/issues-soi.json.

## Issues

| id | status | what changed, where |
|---|---|---|
| SOI-01 | done | `thm:soi:diagonal` (soi.tex): last sentence replaced by the decided text ("Moreover, on the sequence built in this way against the computable predictor $P^\ast(D):=\dots$, $W^{\mathrm{all},\tau}$ loses at least $n-1.37$ and $W^{\mathrm{cons},\tau}$ at least $n-1.37-c_\bot$"); the clause on $\WA$, $\WAchk{t}$, $\WAgen{t}$ unchanged. Proof of `thm:soi:diagonal` (app-soi.tex, paragraph "Clocked SOI"): the predictor is now $P^\ast$ throughout, with the opening sentence "The last claim concerns the sequence built against one predictor." `prop:soi:incomparable`: "on the sequences of \cref{thm:soi:diagonal}" → "on a computable sequence (\cref{thm:soi:diagonal}, applied to $P^\ast$)"; its proof says "the latter for the sequence built against $P^\ast$". Table 1 row: "reverse $\ge n-1.37-c_\bot$ on a computable sequence". Checked against record `sfi` §11 row 20 ("on a computable sequence"). |
| SOI-02 | done (with L1 item 8) | The sentence "With deduction charged, \SAIabbr meets the same bound:" and everything after it in §4.7 replaced by the decided L1-item-8 text ("…needs doubly exponential budgets on these data under the size and material readings, and at least exponential instance sizes under (a1); whether (a1) needs doubly exponential ones, and what (a2) and (b2) need, is open (…). So on a natural theory, … for the readings in which the question is settled (…)."). `prop:soi:presburgerCharged` moved to App B, so the alternative lead-in was not needed. |
| SOI-03 | done | "How to read the table": "they separate only through …" replaced by the decided sentence ("On literals \SAIabbr and \SOIabbr coincide; the separations we know come from logical closure, observed independence, consistency constraints of unbounded arity, or deduction that is free."); the paragraph ends with the U1 text for §4, verbatim. The opening sentences (restating the section) were cut to one sentence (≤ 800 bytes, L1 item 9). |
| SOI-04 | done | Table 1: the row "axiom-side penalties" split into "$\MAchk{t},\MAgen{t}$, $\WAchk{t},\WAgen{t}$ — $\asymp$ unpenalised, also class by class ($t\ge m^{a^*}$; (S$_{\rm tape}$), (S)) — `thm:soi:penalty`, `prop:soi:classes`" and "$\WAKt{t}$, under (S) — between $2^{-c}W^1$ and $2^ct(m_0)W^1$; a labeller pays $\log(\lvert f\rvert+1)+O(1)$ — `prop:soi:kt`" (the decided "within $2^{\pm c}$ and $t(m_0)$ of $W^1$", written as the two bounds of the proposition). |
| SOI-05 | done | `rem:soi:lengths`(ii) (app-soi.tex): "… in place of $\tau(m)\le2^{2^{c'm}}$, with $c'<c/\kappa_0$ (and likewise for the singly exponential clocks), since …". Arithmetic checked: $b/\log(b+2)\le\kappa_0 m$ gives $\tau\le2^{2^{c'\kappa_0m}}$. |
| SOI-06 | done | Paragraph after `ass:soi:SGL` (app-soi.tex): the two sentences on Berman replaced by the decided text ("We do not prove either assumption. $\mathrm{PrA}$ is complete for alternating doubly exponential time with linearly many alternations (cf.\ \citealp{berman1980complexity}); (B$^*$) would follow from the hardness part if the reductions were of linear size, and we do not assume that they are. If they are only of polynomial size, …"); rest unchanged. |
| SOI-07 | done | No "Float too large" in the isolated build nor in the label-resolved scratch build (which reproduced the full build's 0.89507pt warning before the edit). Table 1 is now 423pt high (0.66 of \textheight; limit for a top float 450pt); font stays `\scriptsize`. See "Table 1" below. |
| SOI-08 | done | Fit-class block replaced by list B item 1; the merged row reads "observational, run-padded, finite — see \cref{cor:terms:table}; finite theories need a binary relation or entities ($B=\emptyset$) — `cor:terms:table`, `thm:terms:dilemma`". |
| SOI-X19 | done | §U7 applied. soi.tex: first mentions "the subject of the companion paper \citep{claudeSFI2026fundamentals}" (opening) and "our earlier report \citep{claude2026axiominduction}" (after `thm:soi:coinfree`); afterwards "Definition 3.6 of the companion paper", "Lemma E.14 of the earlier report", "Definition E.18 of the earlier report", etc. app-soi.tex: first mentions in the opening paragraph (earlier report, companion paper) and "the companion paper on steeper priors \citep{claudeSFI2026steeper}" (after the proof of `thm:soi:coinfree`); all 36 later `\citet`/`\citealp`/`\citep[…]` of the three keys replaced by plain names ("Lemma E.12(b) of the earlier report", "Theorem 3.21(a) of the companion paper", "the length-activated and round-activated mixtures of the companion paper (Definition 9.1 and Proposition 9.4 there)", …). Item numbers unchanged. |
| SOI-L1 | done (lists A and B; see page counts) | All nine list-A moves and both list-B moves applied (details below); further prose cuts and a compaction of Table 1, recorded as substitutions. §4 is 5.70 pp. in the isolated build and 5.72 pp. in the label-resolved build (target 5.5, cap 5.75). |

## Moved labels (main text → App B, each inserted immediately before its proof; "Proof of \cref{X}" turned into a plain proof)

| label | to | main-text summary |
|---|---|---|
| `cor:soi:closed` | `sec:app:soi:equiv`, after the proof of `thm:soi:onetape` | decided L1-2 sentence, after `thm:soi:onetape` |
| `ass:soi:S`, `ass:soi:Stape` | `sec:app:soi:equiv`, after the paragraph "Penalised versions." (which absorbed the main paragraph "Penalties on the axiom side") and before `def:soi:penalised` | paragraph "Penalties on the axiom side" (L1-1 text, tightened; names (S), (S$_{\rm tape}$), $a^*$ and the four mixtures with `\cref{def:soi:penalised}`; keeps "we do not prove [them] for a particular machine") |
| `thm:soi:penalty` | `sec:app:soi:equiv`, before its proof; after the proof the lead-in "The equivalence also holds class by class (coin-free, \cref{prop:soi:disguised})." precedes `prop:soi:classes` | same paragraph |
| `cor:soi:transfer` | `sec:app:soi:literals`, after the proof of `thm:soi:transfer` | decided L1-3 sentences |
| `rem:soi:encoding` | `sec:app:soi:literals`, before its proof | decided L1-4 sentence; footnote F2 kept in the opening paragraph with both `\cref`s |
| `prop:soi:noRE` | `sec:app:soi:breaks`, before its proof | mechanism paragraph cut to two sentences, ending with the decided clause |
| `cor:soi:onesided` | `sec:app:soi:time`, after `thm:soi:domination` | decided L1-6 sentence (with $W^{\mathrm{cons},\tau}$, $\MF^{\mathrm{cons},\tau}$ named); the definitions of Out and DET stay in the main text (needed by `thm:soi:diagonal`) |
| `ass:soi:F1`, `thm:soi:sandwich` | `sec:app:soi:charged`, after the setting paragraph (now the first paragraph there) | one paragraph (the readings in one sentence; decided sandwich and fit-class sentences) |
| `prop:soi:presburgerCharged` | `sec:app:soi:presburger`, before its proof | decided L1-8 text |
| `prop:soi:presburger` (list B item 2) | `sec:app:soi:presburger`, after the paragraph ($\mathrm F_{\rm P}$), ($\mathrm F_{\rm FR}$) | two sentences: bounded for $\WA$, $\WAdec$, $\MA$ and $\WAchk{t}$, $\WAgen{t}$, $\MAchk{t}$ at a large enough polynomial $t$; given the Fischer–Rabin bound, unbounded for $W^{\mathrm{cons},\tau}$, $W^{\mathrm{all},\tau}$ with $\tau\le2^{2^{c'm}}$ and for their one-tape forms with $\tau\le2^{c'm}$, $c'<c$; then the pointer to `prop:soi:presburgerCond` with its two assumptions named |
| `rem:soi:presburgerSummary` (labelled paragraph) | end of `sec:app:soi:presburger`, after `q:soi:presburger` and its paragraph | last sentence of the L1-8 text |

All moved statements are verbatim except the decided fixes (checked by a diff against the backup: only the U7 citation forms changed in `cor:soi:transfer` and `rem:soi:encoding`). 76 labels before and after, none lost, none duplicated; environment counts unchanged (9 theorems, 16 propositions, 5 corollaries, 3 lemmas, 2 definitions, 10 remarks, 5 assumptions, 3 questions, 1 table); every theorem-like environment keeps `\status` and `\src`.

Follow-up paragraphs of moved items (content kept or found elsewhere; nothing duplicated, rule L2):
* `thm:soi:penalty` follow-up: the proof-idea sentence dropped (the proof says it); the class-by-class sentence became the lead-in in App B and part of the main summary.
* `cor:soi:transfer` follow-up: its list of what does not transfer is in the proof of `cor:soi:transfer` and in the main summary sentence.
* `cor:soi:onesided` follow-up: the domination-lemma sentence dropped (the proof says it).
* `thm:soi:sandwich` follow-up: "its classical core is the correspondence of propositional proof systems with NP \citep{cook1979relative}; a derivation is a certificate; conversely … $\theta_\zeta\to\varphi^b$ …" kept in App B before the proof; "This is Theorem 6.16 …" (in the proof) and the fit-class list (= `cor:soi:fit`) dropped as duplicates.
* §4.6 setting paragraph: moved to App B as its first paragraph, minus its first sentence ("The natural repair is to charge deduction"), which the main text keeps.
* `prop:soi:presburgerCharged` follow-up: first sentence ("A mixture … only if one of them is compatible with every prefix.") kept after the statement in App B; the rest is in the proof and in `q:soi:presburger`.
* `prop:soi:presburger` follow-up: mechanism in the proof; pointer to `prop:soi:presburgerCond` kept in the main text.
* App B: the sentence after the proof of `prop:soi:incomparable` ("So the natural strengthening … fails; what holds is strict superiority …") deleted, as it repeated the main text.

## Shortened labelled paragraphs (labels kept)

* `rem:soi:timereading` (≤ 550 bytes of text): keeps the axiom-side/labeller-side reading and the pointer to `rem:soi:freededuction` ("The defeating sequence is computable within a slightly larger time bound; we only sketch this").
* `rem:soi:whatcharged`: shortened by one sentence (allowed by L1 item 7); keeps "exists / finding", the NP∩coNP type, and the pointer to `thm:shape:knowhow`.

## Other prose cuts (substitutions beyond lists A and B; no result moved, none headline)

After lists A and B the section measured 6.12 pp. (table on its own float page), so further cuts were needed for the cap:
* opening paragraph: roadmap sentence → "\Cref{tab:soi} collects the relations, and \cref{app:soi} has the proofs.";
* proof-idea sentences after `thm:soi:onetape` and `thm:soi:diagonal` (both in the App B proofs); the clause on why string labellers are consistent after `thm:soi:transfer` (in its proof); the proof idea of `prop:soi:closure`(c) (in its proof);
* the lottery sentence reduced to its pointer (`cor:logic:versions`, stated in §5); the $\emptyset'$/$\emptyset''$ detail of the computability sentence (kept in the Table 1 row "computability");
* the MRDP citations in the Out paragraph (they stay in the proof of `thm:soi:diagonal`); the Elias-δ detail of $E$ (moved to the opening of `sec:app:soi:time`);
* "Presburger's axioms … decidable in polynomial time" (in App B, paragraph ($\mathrm F_{\rm P}$)); the de Leeuw et al. density remark (in the proof of `prop:soi:presburger`(c)).

Main-text citations now only in App B: chandra1981alternation, cook1979relative, davis1973hilbert, deleeuw1956computability, matiyasevich1970enumerable, smullyan1961theory. No citation key is lost from the paper.

## Table 1 (`tab:soi`)

* 25 rows (list B item 1 merged the fit-class block; SOI-04 split one row), nothing dropped. Wording made terser so that most rows take one line; hypotheses kept in the rows or, for "$\mathcal L\supseteq\Lar$", stated once in the caption ("rows with $\Q$ or `$B$ true' assume $\mathcal L\supseteq\Lar$"). `\arraystretch` 1.0, `\tabcolsep` 3pt, font `\scriptsize`.
* Height 423pt = 0.66 \textheight (was 593pt), so it is a top float that shares its page with text.
* Placement `[tp]` → `[t]`, and the environment moved from §4.8 to just before `\subsection{What breaks}`: with `[tp]` LaTeX made a float page of it; placed mid-section it lands on a page inside §4 whatever the pagination. The paragraph "How to read the table" stays in §4.8.

## Page counts

Measured by word coordinates (`pdftotext -bbox`, heading of §4 to the heading of App B, relative to the text block).
Calibration on the original files in the same label-resolved scratch build: 8.40 pp. + the table's float page = 9.40 pp., against 9.43 in the full build of 15:17.

| | before | after |
|---|---|---|
| §4 main text, label-resolved scratch build | 9.40 | **5.72** |
| §4 main text, `./test-section.sh soi app-soi` | 8.28 + table page | **5.70** |
| App B | 21.4 | 22.6 |

Target 5.5, cap 5.75: within the cap, 0.2 over the target. Every decided move is applied; what remains in §4 is the definition, the seven headline results named in the introduction (`thm:soi:coinfree`, `thm:soi:onetape`, `thm:soi:transfer`, `prop:soi:closure`, `prop:soi:independent`, `thm:soi:diagonal`, `prop:soi:freededuction`), the decided summary sentences, and Table 1. If the final full build shows §4 above 5.75, the next candidates are: dropping the `\subsection{Summary}` heading (label kept on the paragraph), and shortening the decided summary sentences of L1 items 1 and 3.

## Builds and checks

* `./test-section.sh soi app-soi`: OK, 30 pages; 0 undefined citations; 25 undefined references (other sections, expected); 0 overfull boxes > 10pt; no "Float too large"; no multiply defined labels.
* Label-resolved scratch build (other sections' labels from `main.aux`): 0 undefined references; no overfull box; no float warning.
* Rule 0.8 grep on both files (outside comments and `\status`/`\src`): no hits. Model-name grep: no hits.

## Requests to other groups

* **front (FRO-20, `app-notation.tex`)**: three pointers now name a main-text subsection whose formal definition moved to App B. Line 25 `$\Kpad(n)$ … \cref{sec:soi:literals}` → `\cref{sec:app:soi:literals}` (its first uses are now `cor:soi:transfer` in App B and Table 1); line 73 `$W_A[t,s]$; $W_A^{a1}$, … \cref{sec:soi:charged}` → `\cref{sec:soi:charged,sec:app:soi:charged}`; line 84 `$\Wcert$ … \cref{sec:soi:charged}` → `\cref{sec:app:soi:charged}`.
* **terms (optional)**: `terms.tex`, `def:terms:literal`: "Charged deduction is that of \cref{sec:soi:charged}" is still true (§4.6 names the readings and points to App B); `\cref{sec:soi:charged,sec:app:soi:charged}` would point to the formal setting.
* **front (intro)**: `thm:soi:sandwich` and `cor:soi:transfer` now print as "Theorem B.x" and "Corollary B.x"; the intro sentences citing them still read correctly. No citing sentence in another file uses "below/above" or section-local wording for a moved label (grep done).
