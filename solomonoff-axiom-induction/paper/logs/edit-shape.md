# Edit log, group shape (shape.tex, app-shape.tex)

Status: **phase 1 done** (2026-10-17): all 7 issues fixed; list A and list B of SHA-L1 applied; isolated build OK. Originals saved in the scratchpad (edit-shape/shape.orig.tex, app-shape.orig.tex).

Baseline (before edits): isolated build `./test-section.sh shape app-shape` OK, 28 pages; main text of §7 = 5.6 pages in the
isolated build (6.27 in the full build of 2026-10-17 15:17, DECISIONS §L1).

## Issues

* **SHA-02** (done, app part): `prop:shape:depth` inserted in App E (`app:shape:aux`) before its proof, with (d) replaced by the
  decided text ("Hence, for each fixed $k$, ... superpolynomial in $m$; $2\lceil\log m\rceil-1$ rounds suffice for $4m-6$ clauses");
  status unchanged. Proof (d) now uses (c) only for fixed $k$; the comparison that gave $k=\Omega(\log m/\log\log m)$ moved out of
  the proof into the decided sentence after it ("If H{\aa}stad's bound holds uniformly in the depth, with an absolute constant for
  all $n\ge2$, then comparing ... gives ... $k=\Omega(\log m/\log\log m)$ for polynomial size; we do not use that form.").
  Consequential weakening: `q:shape:minimum`(c) no longer cites (d) for the $\Omega(\log m/\log\log m)$ lower bound; it now reads
  "Every fixed number is too few, and $2\lceil\log m\rceil-1$ suffice (\cref{prop:shape:depth}(d)); if Håstad's bound holds
  uniformly in the depth, $\Omega(\log m/\log\log m)$ are needed."
* **SHA-X19** (done): app-shape.tex had two citations of the companion works, both of the earlier report. First (def:shape:charged):
  "Definition~E.18 of our earlier report \citep{claude2026axiominduction}"; second (after prop:shape:lemmaenters): "Remark~E.9(iv) of
  the earlier report" (no citation command). shape.tex cites none of the companion works.

* **SHA-01** (done): caption of `tab:shape:regimes`, the decided text ("... whose value on $\mathcal Q(\mathcal S)$ is the listing
  length of a least usable theory (\cref{thm:shape:visible}(a)): at least its written length, which is at least the number of clauses
  given here, and at most a factor $O(w\log\bar m)$ larger for clauses of width $w$"), with "over $\bar m$ variables" added so that
  $\bar m$ is defined where used. The sentence after the proof idea of `thm:shape:visible` that repeated the inexact "up to the code
  length per literal" was deleted (list A item 6 shortened that proof idea anyway).
* **SHA-02** (done, main part): the statement left shape.tex (see SHA-L1 item 1); main-text sentence as decided in §L3.
* **SHA-03** (done): paragraph after `def:shape:model`: "$\mathcal R$-compatibility with $\mathcal Q(\mathcal S)$, for a sound
  $\mathcal R$, already forces $\proj\Phi=\mathcal S$ (\cref{lem:shape:forces})".
* **SHA-04** (done): opening paragraph of §7: \cref{thm:soi:coinfree,rem:phil:craig}.
* **SHA-05** (done): sentence after the proof idea of `thm:shape:invisible`: "In this model it becomes visible when what is written, or the
  time to write it, is charged." (DECISIONS §U1).
* **SHA-L1** (list A done; see below for list B): all six items of list A.
  1. `prop:shape:depth` (with the SHA-02 fix) moved to App E, `app:shape:aux`, before its proof; its main-text proof idea dropped (the
     appendix has the full proof). Main text (§7.4): the decided sentence, with "and any intermediate concepts" and \citep{hastad1986almost}.
  2. `prop:shape:onlyforced` moved to App E, `app:shape:base`, before its proof. Main text (end of the definitions paragraph of §7.3, before
     `thm:shape:minimum`): the decided sentence ("... (\cref{prop:shape:onlyforced}), and:"), with "explicit".
  3. `prop:shape:oneround` moved to App E, `app:shape:aux`, before its proof; proof idea dropped. Main text: the decided sentence
     ("every $\UP_1$-usable theory for a law, with any auxiliary variables, contains all its prime implicates, ...").
  4. `cor:shape:simplex` moved to App E, `app:shape:base`, before its proof. The paragraph after it and the "So a circuit must be written
     down ..." paragraph merged; main text: the decided sentence, with the definition of the simplex family and the hypotheses $r\ge3$
     (corollary) and $r\ge4$ (for $m(2m-4)$, `rem:shape:simplexaux`) kept.
  5. Old §7.6 Directionality, §7.7 Where the know-how lives, §7.8 Learning, and depth against size merged into
     `\subsection{Directions, know-how and learning}\label{sec:shape:directions}` with paragraphs "Directionality." (no label),
     "Where the know-how lives." \label{sec:shape:homes}, "Learning." \label{sec:shape:learning}, "Depth against size." (no label).
     Sizes (bytes of source, final): directionality 1260 -> 903; know-how 1590 -> 933 (kept: the three homes; the decider of $\PI(\mathcal S)$
     with $K^q$ defined in place; the cost within $K^q(A,b)-K(\mathcal S)+O(\log m)$ bits given a derivation bound we sketch, now citing
     `rem:shape:knowhowsketch` as well; cannot express the textbook point); learning 710 -> 566; depth 840 -> 527 (the first-order
     sentence on lemma sentences and cut-free proofs dropped from the main text: `rem:shape:cutfree` and its citations of Statman and
     Orevkov are unchanged in App E, `app:shape:fo`).
  6. Proof ideas of `thm:shape:minimum` and `thm:shape:systems` now two sentences each, that of `thm:shape:visible` one
     (after list B); paragraph after `thm:shape:systems` 640 -> 497 (novelty hedge kept: "we did not find it stated, and it is probably known to specialists");
     opening paragraph 1370 -> 990 including the credit footnote F4 (kept); paragraph after `def:shape:model` 660 -> about 600
     (the pointer to the degenerate two-valued encoding, `prop:shape:E2`, kept, since setting.tex may no longer cite it);
     the "Sources:" list of the caption of `tab:shape:regimes` removed (the proof of `cor:shape:regimes` in App E already gives the
     source of every column and row); the caption keeps the entries' meaning and now says which entries rest on Håstad's and on
     Göös et al.'s bounds.
* **SHA-L1, list B** (applied, since the isolated measure after list A was 4.62 pages, over the 4.5 target though within +0.25):
  1. `thm:shape:visible`(b), the time-charged bounds, moved to App E (`app:shape:invisible`) as the new
     `prop:shape:timecharged` ("Time-charged bounds", \status{proved}\src{shape Thm 1.12(b)}), placed after the proof of
     `thm:shape:visible` and before its own proof (the old part (b) of that proof). `thm:shape:visible` keeps (a) and the old (c), now
     lettered (b); its \src now reads "shape Thm 1.12(a), (c)". One sentence on the time-charged bounds after its proof idea in §7.2,
     with \cref{prop:shape:timecharged} and the hypotheses (affine law, sound reasoner, either class) kept. References updated:
     caption of `tab:shape:regimes` "(\cref{thm:shape:visible}(b))"; proof of `rem:shape:simplexaux` now cites
     `prop:shape:timecharged`; proof of `thm:shape:learning`(f) cites "\Cref{thm:shape:visible}(b) and \cref{prop:shape:timecharged}".
     No file outside shape cites a part of `thm:shape:visible`.
  2. `rem:shape:reading`: the rule-base clause ("and a rule base with intermediate concepts is within a constant factor of a clausal
     theory") removed; the hedge "The model does not show that logic ... is the right formal home for theories: the large separations
     are between pairs (reasoner, vocabulary)." and "It is not a theorem about textbooks." kept.
* Further prose cuts (no result touched): the sentence after `tab:shape:regimes` that restated §7.4 ("Intermediate quantities help a
  reasoner only if ...") removed; "So the exponential separations are between pairs ..." and the hidden-state sentence kept.

## Moved labels

| label | from | to |
|---|---|---|
| `prop:shape:onlyforced` | shape.tex §7.3 | app-shape.tex `app:shape:base`, before its proof |
| `cor:shape:simplex` | shape.tex §7.3 | app-shape.tex `app:shape:base`, before its proof |
| `prop:shape:oneround` | shape.tex §7.4 | app-shape.tex `app:shape:aux`, before its proof |
| `prop:shape:depth` | shape.tex §7.4 | app-shape.tex `app:shape:aux`, before its proof (with SHA-02) |
| `prop:shape:timecharged` (new) | part (b) of `thm:shape:visible` in shape.tex §7.2 | app-shape.tex `app:shape:invisible` |

Section structure: old §7.6 `sec:shape:directions` (subsection), §7.7 `sec:shape:homes` (subsection) and §7.8 `sec:shape:learning`
(subsection) became one subsection "Directions, know-how and learning" `sec:shape:directions`, with `sec:shape:homes` and
`sec:shape:learning` as labels on its paragraphs (they resolve to the subsection, as `rem:shape:reading` already does). §7.7 is now
"What this shows and does not show". Shortened labelled paragraphs: `sec:shape:homes`, `sec:shape:learning` (labels kept),
`rem:shape:reading` (list B item 2). No label was renamed or removed. Credit footnote F4 kept in the opening paragraph of §7.

Checked citing places in other files (grep of `sections/`): `limits.tex` cites `prop:shape:depth` in Table 7 ("useful to a chaining
reasoner") — still true, now prints "Proposition E.x"; `app-verification.tex` lists `prop:shape:onlyforced`, `cor:shape:simplex`,
`prop:shape:oneround`, `prop:shape:depth` (labels unchanged, statuses unchanged); no other file cites the moved labels.

## Page counts

Isolated build (`./test-section.sh shape app-shape`, 2026-10-17, after all edits): OK, 28 pages, 0 undefined citations, 14
undefined references (all to other sections: ass:soi:F1, cor:soi:fit, def:setting:questions, def:setting:versions,
q:phil:declarative, rem:phil:craig, rem:soi:whatcharged, sec:limits:textbook, thm:soi:coinfree, thm:soi:sandwich), 0 overfull boxes
above 10pt, no multiply defined labels.

Measured from the bounding boxes of `pdftotext -bbox` (heading of §7 to heading of the appendix, fractions of the text block):
* **§7 main text (with Table 4): 4.64 pages** (before: 5.6 in the isolated build). Target 4.5, tolerance +0.25.
* Appendix E: 21.5 pages (before: about 20.9).
* Source: shape.tex 27,482 -> 22,794 bytes (about 1,200 bytes of it are comments); app-shape.tex 104,958 -> 107,866 bytes.

Note for the front group's full-build measurement: in the build of 2026-10-17 15:17 the §7 figure of 6.27 pages included phil's
Table 3, which floated onto §7's first page (`pdftotext -f 39 -l 45 main.pdf` shows "Table 3" there); the same section measured
5.6 pages in isolation. If Table 3 (or another float from §6) still lands in §7's pages, §7 will measure about 0.4–0.6 page more
than its own content. List A and list B are both applied, so no further prescribed move remains for shape.

Paragraph targets of list A that are not fully met (each over by 75-160 bytes): directionality (target 800), know-how (800),
learning (450), depth (450), paragraph after `thm:shape:systems` (400), opening (900), paragraph after `def:shape:model` (450).
Cutting further would drop hypotheses or claims that the decisions say to keep (e.g. the factor-$m$ clause, the definition of
$K^q$, the definition of a pattern, the novelty hedge, the citation of the parity-reasoning solver); the section as a whole is within
the tolerance (4.64 against 4.5 + 0.25).

## Requests to other groups

* **front** (`app-notation.tex`, line for $\Kt$; $K^q$): it points to `\cref{thm:shape:visible}` for $\Kt$; the time-charged
  bounds that use $\Kt$ are now `prop:shape:timecharged` (App E); please point there (or to `sec:shape:invisible`, where the main
  text names Levin's $\Kt$). The $K^q$ pointer `sec:shape:homes` is still right. The other shape rows (`sec:shape:invisible`,
  `sec:shape:base`, `sec:shape:aux,sec:shape:systems,sec:shape:learning`, `def:shape:model`, `prop:shape:rules`) still resolve and
  fit ($\ia_k$ is now in the depth paragraph of the merged subsection whose label is `sec:shape:directions`, which is also where
  `sec:shape:learning` points).
* **front** (`app-verification.tex`, status table, regenerated at the end): new label `prop:shape:timecharged` with status "proved"
  and source "shape Thm 1.12(b)"; `thm:shape:visible` now has source "shape Thm 1.12(a), (c)". Statuses of the moved labels are
  unchanged.
* **phil / front**: see the note on Table 3 under Page counts.

## Final greps (rule 0.8)

Pattern of rule 0.8 on shape.tex and app-shape.tex, outside `%` comments and `\status`/`\src` arguments: no hits. No model names.
