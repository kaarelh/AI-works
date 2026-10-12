# Final check of Paper 1 (`paper/`, groups p1-front, p1-setting, p1-hist-ex, p1-ood)

Checker: a fresh final checker, after phase 3. Read in full first: DECISIONS.md, `edits/status-rendering.md`, the four issue lists and logs, and every file of `paper/sections/` (app-verification excluded; it is switched off). Sources consulted for claims: `research/tracks/{foundations,history,examples,context}/notes-final.md`, `referee.md`, `referee_code/`, `checks/`, `research/prior/`, Paper 2's sections. No git command was run. Originals of the files before my edits: `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/final-p1/orig/` (scratch).

**Summary.** All 77 fatal and major issues of the four lists have their decided fix in place, apart from the page caps of §C. P1O-07 deviates from the decided text, and the deviation is correct and recorded. The abstract, introduction and discussion match the body. I found two small mismatches and fixed them (the incompressibility hypothesis in the steeper bullet, and an undefined symbol in `rem:comp:selection`). I also made three small conformance fixes. All 29 spot checks agree with the track records. Every arXiv grep gives only the allowed hits. The full build has 0 errors, 0 undefined references or citations, 0 multiply defined labels and no overfull box above 10pt. **One acceptance criterion is still open: the length caps of §C.** The PDF has 90 pages against a cap of 84: main text 43.65 against 41, appendices 41.26 against 38. Meeting the caps needs cuts that the lead editor must decide (§5).

## My edits (all minimal; no label added, renamed, moved or deleted)

| file | change | reason |
|---|---|---|
| `intro.tex` (Contributions, steeper bullet) | "a teacher's errors on an incompressible error set of product form" → "… on an error set of product form that is incompressible relative to the parity" | Same hypothesis as `sec:steep` (§F20), the Discussion and Paper 2's theorem. Without it the summary claims more than the companion paper proves. |
| `intro.tex` (Reader's guide) | "\cref{sec:versions}, which compares the Kolmogorov and semimeasure versions, can be skipped on a first reading" | §F2 asks for "\Cref{sec:versions} compares the Kolmogorov and semimeasure versions"; the "can be skipped" wording (P1F-26) is kept. |
| `nn.tex` (`rem:nn:slides`) | quotation "I haven't meticulously reviewed many appendix slides" → "… appendix slides yet" | §F18 requires the caveats to be quoted exactly as decided ("… many appendix slides yet"). The wording is checked against `prior/vaintrob-hanni-nnbayes-generalization-slides.txt:889–891`. |
| `app-setting.tex` (after `q:setting:normorder`) | "\end{question} Total laws always satisfy it." → a new paragraph "Total laws always satisfy $(\star)$." | The text was run on after the question environment, and "it" had no antecedent in the new paragraph. |
| `app-comp.tex` (`rem:comp:selection`) | "at most $L(f)\le\ell(f)$ mistakes" → "at most $\ell(f)$ mistakes" | $L(f)$ is not defined in the paper (it is the context notes' notation). The bound $\le\ell(f)$ is the one proved in `rem:comp:majority`. |

## 1. Fatal and major issues (77): decided fix in the current .tex

✓ = the fix is in place and correct, checked in the file named. In this table "intro" and "discussion" stand for `intro.tex` and `discussion.tex`.

**p1-front (3 fatal, 20 major)**

| id | sev. | check |
|---|---|---|
| P1F-01 | fatal | ✓ abstract = §F1 with "under finiteness assumptions and". The addition is correct: `cor:hist:thm1`(a) needs (A1), (A2) and computable real values; only (c), with the entropy term, needs no finiteness. |
| P1F-02 | fatal | ✓ "Measured on its unnormalised predictive probabilities, SFI's cumulative loss does not depend on the order" (= `prop:setting:order`). |
| P1F-03 | fatal | ✓ history bullet = §F2 text; "Corrections to earlier claims" is gone. |
| P1F-04 | major | ✓ abstract has 1840 source characters (limit 1920). "target $f$" defines the $f$ in $O(K(f)/n)$. |
| P1F-05 | major | ✓ "exceeds SI's joint loss … by at most a constant" (`thm:hist:si`(a) is one-sided; (b) has $L^x_{\rm in}$). The Hutter sentence is the §A8 sentence. |
| P1F-06 | major | ✓ in substance. No unqualified "every order-independent predictor pays the same lower bounds" remains. Theorem C states the lsc version with the complexity subtracted (`prop:hist:orderfree`(b)), and Discussion ¶2 states the in-expectation version (`prop:hist:orderfree`(c), `prop:ex:orderfree`, `prop:ex:law`). The decided sentence is not repeated verbatim in the history bullet; no change was needed. |
| P1F-07 | major | ✓ Theorem D: SI $O(1)$ in expectation with self-delimiting blocks; Eisenstat $\frac{H(1/3)}2n\pm O(\log n)$ (semimeasure convention), the a.s. sandwich, optimality among order-independent predictors, and SI at most 2.4 bits + c. |
| P1F-08 | major | ✓ `tab:intro:verdicts` and its references deleted (grep: none). "Relation to the author's notes" = the §A6 sentence + the §A11 sentence. |
| P1F-09 | major | ✓ motivation; `sec:intro:results` (conventions first, Theorems A–D as paragraphs); 6 contribution bullets; relation to the notes; what is not achieved; reader's guide. `\newpage` after the TOC deleted. |
| P1F-10 | major | ✓ "Credit" gone; Eisenstat credited as personal communication; slides credited; "We do not prove the main theorems of the slides." |
| P1F-11 | major | ✓ §F23 verbatim. |
| P1F-12 | major | ✓ "Relation to the literature" deleted; its content is in §2. |
| P1F-13 | major | ✓ the Open problems list cites all 17 `question`/`conjecture` labels (script: 17 of 17), plus `rem:learn:lastiterate`, `rem:hist:thm1open`, `rem:hist:minimaxsketch`. |
| P1F-14, P1F-15 | major | ✓ Acknowledgements and Code and data match §A4 verbatim. |
| P1F-16 | major | ✓ `\newif\ifsfirecord`, `\sfirecordfalse`, `\ifsfirecord\input{sections/app-verification}\fi`. No `app:verif` reference elsewhere. |
| P1F-17 | major | ✓ the §A2.4 lines are at the end of the macro block (`preamble.tex:122–123`). Calls and comments stay in the sources. |
| P1F-18 | major | ✓ `question` environment with both `\crefname`s. |
| P1F-19 | major | ✓ `hanni2026request`, `hanni2026lesswrong` and the two Özkural entries are dropped (no `@` entry, no citation). `diff paper/bib/core.bib paper-steeper/bib/core.bib` is empty. |
| P1F-21 | major | **Not met.** The §C caps are exceeded (§5). Every cut and move named in §C has been made; the excess has to be removed by cuts the lead editor decides. |
| P1F-22 | major | ✓ SFI is defined in the paper's own words in ¶1; no third-person "Hänni" or "his" in the visible text (grep). |
| P1F-31 | major | ✓ §F18 sentence in Discussion ¶4, with "for any fixed accuracy". This is correct: `cor:nn:separation` gives $O(k\log d/\varepsilon)$. |
| P1F-32 | major | ✓ the steeper bullet and companion ¶ carry the hypotheses (I added "relative to the parity", see above). "Every selected hypothesis is shorter than a bound that does not depend on the data" matches Paper 2 `thm:absorb:absorption`(a). |

**p1-setting (1 fatal, 19 major)**

| id | check |
|---|---|
| P1S-01 (fatal) | ✓ item (3) of `rem:versions:answer` and the sentence after `prop:versions:covering` = §F10. `q:versions:open` has the $\log k$ question. |
| P1S-02, P1S-03 | ✓ items (2) and (4) = §F10. The arithmetic of (2), $\delta_D+K(\lceil\log(d+1)\rceil)+O(1)$ from `prop:versions:tape`(b) and `thm:setting:coding`(a), checks. |
| P1S-04 | ✓ §F14 after `ex:setting:swap`. |
| P1S-05 | ✓ §F12: (b) last sentence, plus the sentence after the theorem. |
| P1S-06 | ✓ §F13 in `rem:setting:recommend`. |
| P1S-07 | ✓ §F15 in `rem:versions:hist` (`app-versions.tex`). |
| P1S-08, P1S-09 | ✓ table cell and caption = §F11. |
| P1S-10, P1S-11 | ✓ §F16 (proof (b), statement (c), "(For $P$ with infinite expected log loss the inequality is trivial.)", "a direct computation … 0.95, 0.113, $5\cdot10^{-4}$"). The H7 sentence is gone. |
| P1S-12 | ✓ §F26 `rem:learn:cesaro`; `learn.tex` cites it without "is refuted". |
| P1S-13 | ✓ no check id, track name or "page cap" in the visible text (stripped-source grep). |
| P1S-14 | ✓ no literature hedges. The inline `\status` calls at `setting.tex`, `app-versions.tex` are gone (0 calls outside environments). `rem:versions:operator` follows §A8. `lem:setting:realise` heading as decided. |
| P1S-15, P1S-20 | ✓ voice: versions.tex:4, the merged remark's title, learn.tex:7 and learn.tex:26 as decided; one verbatim quotation in §3 (checked verbatim earlier by the reviews). |
| P1S-16 | ✓ "A sufficient condition (proof sketch)."; Strassen cited; "We do not carry out the reduction …". |
| P1S-17 | ✓ the six questions are `question` environments with the same labels. |
| P1S-18 | ✓ status renderings: `rem:setting:h1a`, `rem:learn:positive` ("(informal)", "Proof sketch."), `rem:learn:increasing` as an example, `rem:versions:hashing`, `cor:learn:mistakes`, `prop:learn:occam`. `rem:learn:interventions` deleted (no reference left). |
| P1S-19 | ✓ merge done (both labels on `rem:versions:answer`); the learning-curve items are in App C. Section budgets are exceeded (§5). |

**p1-hist-ex (14 major)**

| id | check |
|---|---|
| P1H-01 | ✓ §F3: `thm:hist:minimax` case (b) is for reveal laws that see only the history; `rem:hist:minimaxsketch` headed "Proof sketch."; app-hist Step 3 says "only sketched". |
| P1H-02 | ✓ §F4 sentence after `cor:hist:thm1`. "without finiteness assumptions" is used in place of "in general" for (c); this is correct, since (c) still needs reveal samplers that halt with probability 1. |
| P1H-03, P1H-04 | ✓ §F9 statement of `lem:ex:chainsemi`; the ranges in `eq:ex:depth`, `prop:ex:orderfree`(a) and `q:ex:depthweak`. |
| P1H-05 | ✓ §F25 after `thm:hist:expected` (moved to App D, with its paragraph). $I(f\to x)=(q-1)+\log(2^q-1)$ re-derived; "$\LH\le q+c$" stated. |
| P1H-06 | ✓ Zvonkin–Levin/Wood sentence after `thm:hist:representation`; §A8 Hutter sentence after `cor:hist:H4`; no novelty or identification claim. |
| P1H-07 | ✓ §F22: `ass:hist:lhgeven`, `ass:hist:lhgodd`, the LHG sentence before them, the proposition "under Assumption …", and "conditionally on Assumptions" in `rem:hist:H4verdict` and `rem:ex:where`. |
| P1H-08 | ✓ `prop:hist:operator` titled and stated for $\Mpq$ only. |
| P1H-09 | ✓ no request citation; Eisenstat credited as personal communication; `rem:ex:email` paraphrases the argument and no e-mail is quoted. |
| P1H-10 | ✓ all §A6 retitles; no "Thm 1"; `conj:hist:algmi` followed by "We have neither a proof nor a counterexample." |
| P1H-11 | ✓ status renderings (`thm:hist:randchain` title, `prop:hist:info`(b), `rem:hist:thm1open`, `prop:ex:cycsi` illustration, pointers to questions). |
| P1H-12 | ✓ questions as environments; `conj:ex:raw` = §F21; the local-search item of `q:hist:open` dropped. |
| P1H-13 | ✓ no `\status` inside `tab:ex:cycle` or `tab:ex:eisenstat`; captions as decided; `lem:ex:behind` values after the proof; no re-check sentences inside proofs; e1–e7 paragraph replaced. |
| P1H-14 | moves done (`thm:hist:expected`, `prop:hist:normchain`, `prop:hist:strict`, `prop:hist:lhg`, `thm:hist:gf` → App D); budgets exceeded (§5). |

**p1-ood (2 fatal, 18 major)**

| id | check |
|---|---|
| P1O-01 (fatal) | ✓ §F7 verbatim after `prop:ood:labelled`. |
| P1O-02 (fatal), P1O-13 | ✓ `steeper.tex` body = §F20 verbatim (no $t_n$, no numbers; cites `hanni2026grokking` and `claudeSFI2026steeper` only). Its claims match Paper 2 (absorption in history-aware SFI is in Paper 2 `rem:absorb:wyeth`(i)). |
| P1O-03 | ✓ §F8 `rem:ood:answer`. |
| P1O-04, P1O-05 | ✓ §F17 in `ex:ood:hanniexamples`(a),(c), the grammar paragraph and `tab:ood:hanni`. "Equal to (or ten times) that of the intended program" checked against `examples/checks/e5_dsl_odd_lengths.py` (extra mass $=$ tilt$\times0.5\times$ mass of the single consistent class "len"); the 44% prior share recomputed from the e5 output. |
| P1O-06 | ✓ `rem:ood:lopsided` states the fact; the last sentence was deleted. |
| P1O-07 | ✓ `conj:ood:natural` is a `question` with the same label. The paragraph after it is deleted. **Deviation from §F21, correct and recorded in `log-p1-ood.md`:** "posterior probability tending to 1" is impossible for every universal machine, by `prop:ood:hanni` (the wrong answer keeps probability $\ge2^{-c'}$). So the question asks for "close to 1, say at least 0.99". |
| P1O-08 | ✓ §F5: `thm:comp:timebounded` keeps (a) only; `rem:comp:runtime` verbatim with "Proof sketch."; the cost clauses are removed from `prop:comp:round`, `cor:comp:poly` and `prop:comp:history`; the sentence after `cor:comp:poly` is decided. The appendix bound $\sum_j\log\frac{1+\varepsilon_j}{1-\varepsilon_j}=1.878\le1.88\le1.9$ for $\varepsilon_j=(j+1)^{-2}$ is recomputed. |
| P1O-09, P1O-10 | ✓ §F19 (tightness sentence; `rem:comp:selection` rows; `rem:comp:uniformties` credit). |
| P1O-11 | ✓ content of §F18 (item (vi), the "Of these, this paper proves …" sentence). The caveat quotation is now exact ("… yet"; my edit). The remark renders as 17 lines against the ≤ 12-line guide; not cut, because cutting it would drop claims of the slides. This is part of §5. |
| P1O-12 | ✓ `rem:nn:rigorous` deleted (no reference left); its sentence is in the Discussion (P1F-31). |
| P1O-14 | ✓ §2 Related work as prose with labels `rem:learn:hutterEX`, `rem:nn:literature`, `rem:related:new`; Novelty paragraph per §A8; 1.72 pages (budget 1.5). |
| P1O-15, P1O-16, P1O-17 | ✓ titles and voice as decided; "an earlier draft in [Hän26]" is used only in `app-ood.tex` before the literal bounds; the nn.tex opening sentence is decided. |
| P1O-18 | ✓ status renderings (ladder credit, Occam (a), Littlestone, Leike–Hutter, Walsh (a)/(b) citations, Basri wording, the computed sign accuracy with "we do not prove this", the Gaussian-prior sketch sentence, the disjointness re-check deleted). |
| P1O-19 | ✓ questions as environments; to-do items rephrased; `q:comp:samplers` has "bounded away from 0 and 1" and Impagliazzo–Levin as "cf.". |
| P1O-20 | moves done (`ex:ood:easyhard`, `rem:comp:apples`, `rem:comp:gap`, `prop:comp:samplers` → appendices); budgets exceeded (§5). |

Status bookkeeping (§A2.5), re-run on the final sources with `question` added to the environment list:
* 181 `\status` calls in total, 72 of them plain and 109 not.
* **0 calls outside an environment, 0 inside a `table` float.**
* Each of the 109 non-plain labels appears in a group log.

## 2. Abstract, introduction and discussion against the body

Each claim was compared with the statement it cites, with that statement's hypotheses and convention.
* **Abstract.** Universality, domination and invariance (`thm:setting:universal`, `thm:setting:invariance`(a)). Agreement up to $K(\dom D)$ and no coding theorem (`thm:versions:chain`, `thm:versions:nocoding`). Pathwise dominance (`thm:learn:dominance`). $O(K(f)/n)$ (`thm:learn:batch`(a)). Fresh noise (`prop:learn:freshnoise`). Order independence (`prop:setting:order`). $(d-\log_2e)2^d$ (`thm:ex:cycle`). SI $O(1)$ (`prop:ex:cycsi`). Universal chronological semimeasure (`cor:hist:H4`). The reveal-law sentence, with the finiteness qualifier (`cor:hist:thm1`). **All match.**
* **Introduction.**
  * Theorems A–D: every number and hypothesis matches the cited results. These include $\log d-2$ and $2^{-O(\log\log d)}$; $n(n-1)/2\pm O(\log n)$ for ML-random blocks; "every lsc order-independent predictor as much up to its complexity"; $\log((N-1)!)\pm O(1)$; $\delta d-O(\log d)$ per step in expectation on average; and $3\vartheta=2.399\le2.4$.
  * Contributions, "Relation to the author's notes" and "What is not achieved" match.
  * **Fixed:** the steeper bullet lacked "relative to the parity" (see My edits).
* **Discussion.**
  * ¶1–¶3: OOD floor and bounded total error (also on repeated inputs, where $e_t=0$); order-free gaps paid in expectation; versions agree up to $K(\dom D)$ with the decided witnesses; the same learning rate for deterministic targets (item (5) of `rem:versions:answer`, `prop:learn:occam`).
  * ¶4: the ladder is $2^{\Omega(\ell/\log\ell)}$ for the same circuit/formula prior; posterior majority makes at most $\ell$ mistakes; the GP sentence.
  * ¶5: the companion paper.
  * Open problems: each item restates its question without adding claims.
  * **All match.**
* Title-page footnote, author line and `\hypersetup`: §A4 verbatim; no affiliation or e-mail.

## 3. Spot checks against the track records (29 claims, all sections and appendices)

| # | paper item | source | result |
|---|---|---|---|
| 1 | `thm:setting:weakvsmachine`(iii)–(v), $k\log\frac32-K(k)$, $(2/3)^k$ exact, 0.37 | foundations Thm 3.5 and remark | ✓ |
| 2 | `ex:setting:swap`: $\le d+O(1)$, $\KF\le d+2\log d+O(1)$, not a separation | foundations Ex 6.4 | ✓ |
| 3 | App A: 10.92 bits in 720 orders, normalised 7.33–10.64 | context notes-final l.705 (c3) | ✓ |
| 4 | App A: 400/400 both directions | foundations c10 row | ✓ |
| 5 | `prop:setting:twopoint`(iii) and the example of `prop:setting:normalise`(b) | re-derived by hand | ✓ |
| 6 | `thm:versions:nocoding` (i)–(iii) and the $\log\KF$ consequence | foundations Thm 4.7 | ✓ |
| 7 | `prop:versions:covering` | foundations Prop 4.9 | ✓ |
| 8 | `cor:versions:twopoint` | foundations Cor 4.8 | ✓ |
| 9 | `prop:learn:freshnoise` numbers 0.95, 0.113, $5\cdot10^{-4}$ | foundations c5 row | ✓ |
| 10 | merging: 12.5 bits against a bound of 1 | foundations l.501 (r6) | ✓ |
| 11 | `rem:learn:lastiterate` 0.873; `prop:learn:curve` 63 of 300 | foundations `referee_code/r12…output.txt` | ✓ |
| 12 | `prop:learn:curve` $r_0,r_1$ for $w=\frac1{16}$ | foundations Prop 6.10 (0.912 there; exact $\log_2\frac{32}{17}=0.9125$, so 0.913 is correctly rounded) | ✓ |
| 13 | `rem:learn:increasing` 0.255 | context l.257; recomputed $\frac1{16}\log_217=0.2555$ | ✓ |
| 14 | `thm:hist:randchain` ($I=n(n+1)/2$, $\Ex\LSFI\ge n(n-1)/2$, oracle reading) | history Thm 3.7 | ✓ |
| 15 | `thm:hist:gf`, 2.708 / 4.348, $\max N=8,22$, $[56,80]$ | history row 5.4, c5, r3, s4 | ✓ |
| 16 | GF process after `thm:hist:expected` (gap $\le q+c$, $I\approx2q$) | history Thm 5.6 tightness; exact $I$ re-derived | ✓ |
| 17 | `rem:hist:thm1open` 0.026 / 0.005 / horizon 6 | history remarks after Cor 3.9 | ✓ |
| 18 | `cor:hist:thm1` (a)–(c), proved versus open | history Cor 3.9 and "Verdict" (the paper restricts (c) to halting reveal samplers, which is weaker and so safe) | ✓ |
| 19 | `prop:hist:programs`(d) | history Prop 4.10 | ✓ |
| 20 | `thm:ex:expected` bounds; product law $1.2516n$ | examples Thm 3.6; arithmetic | ✓ |
| 21 | `lem:ex:behind` $20e^{-n/18}$ and the five exact values | examples Lemma 3.5 | ✓ |
| 22 | `prop:ex:asymp`, `prop:ex:burnin`, `prop:ex:rulestats` (exactly 2, exactly ½) | examples Props 3.4, 3.9, 3.12 | ✓ |
| 23 | `prop:ex:normalised`; "at most about $2N$ bits"; 19.2 against 40.25 at $d=4$ | examples Prop 2.9 and l.232 | ✓ |
| 24 | grammar computation (1345 classes, 80 conditions, 170/340 strings, 0.9790/0.9971/0.99972, 0.557/0.114) | examples §5.3 and `checks/e5…out.txt` | ✓ |
| 25 | `prop:ood:converse` (a)–(c), $2^{s+1}/(n+1)$ | context Prop 2.13 | ✓ |
| 26 | `thm:comp:timebounded` 132.4 against 184; `rem:comp:distinct` 469; `prop:comp:round` 10.0 against 20 | context c5, c9 | ✓ |
| 27 | `thm:comp:circuitbayes`(b) explicit $16\mathcal E(d+1)\log(2(\mathcal E+1)(d+2))$; `prop:comp:occam` 6.7 and $70\ell+531$ | context Thm 3.5, Props 3.8–3.9 | ✓ |
| 28 | `rem:comp:selection` 7 and 15 against 2.5 and 3.5; `rem:comp:uniformties` $d+d^2\ln2$ | context Remarks 3.12, 3.13 | ✓ |
| 29 | `rem:nn:oddparity` sign accuracy 0.05–0.07 ($n=900$, $d=10$), "not proved" | context c12 | ✓ |

Quotations kept in the visible text were checked verbatim against `research/prior/`:
* the SFI definition (`setting.tex`);
* "simple to sample from conditional on any particular choice of function $f$" (`hanni-sfi-notes.md:26`);
* "is not" (`hanni-does-solomonoff-generalize-well-out-of-distribution.md:18`);
* the slide quotations (slides text, lines 128, 781, 789, 858, 888–891).

## 4. arXiv-readiness

* **§A5 grep on `pdftotext main.pdf`.**
  * Hits: the footnote's "independent AI referees", which is allowed.
  * Formula fragments: $E_1,E_2,E_3$, $s_1$, $e_1$, $r_0,r_1,r_2$, $c_1$.
  * Two DOI fragments: `s41467-…`.
  * No other hit. "Sam Eisenstat (personal communication)" appears in §1, §7 and the acknowledgements.
* **The same grep on the sources.** It was run with comments and `\status`/`\src` arguments removed, both of which stay by §A2.6. The only hits are labels (`cor:hist:H4`, `rem:hist:H4verdict`, `rem:learn:h2`), which are invisible, and formulas.
* **§B.6.**
  * `grep -c -i wyeth` on the PDF text gives 0.
  * The source grep gives nothing (comments, `rem:absorb:wyeth` and app-verification excluded).
* **§A2.5.**
  * Status calls: see §1.
  * `grep -n 'src{[^}]*\(slides\|T5\|request\|draft\|known\)'` finds `examples.tex:32,111`, `nn.tex:71` and `versions.tex:123`. The credit or attribution each carries is in the visible text: the author's notes, Eisenstat, the slides, and "The author's notes ask whether …".
  * After the redefinition, the `\[(proved|computed|…)` grep on the PDF gives nothing.
* **Proof sketches.** Each is a Remark, a paragraph or a sentence headed or worded as a sketch, and none is a theorem:
  * `rem:hist:minimaxsketch`, `rem:comp:runtime`, `rem:learn:positive`;
  * App A "A sufficient condition (proof sketch).";
  * the Gaussian-prior sentence after `prop:nn:upper`.
  * `thm:comp:timebounded`(b) is gone. `thm:hist:minimax`(b) is restricted to reveal laws that do not see $f$.
* **Conjectures and questions.**
  * `conj:hist:algmi` and `conj:learn:loo` are precise conjectures, each followed by "We have neither a proof nor a counterexample."
  * `conj:ood:natural` and `conj:ex:raw` are questions.
  * The 17 question and conjecture environments are all cited in the single Open problems list.
* **Computed numbers.**
  * No computed number sits inside a theorem, proposition, lemma or corollary statement (script over all theorem-like environments). The decimals that remain there are values of closed forms: $0.4591479$, $1.0496602$, $1.2516$, $0.7995167$, $2.39855$, $6.7$.
  * Numbers outside statements use "a direct computation (code in the accompanying repository)", an exact computation, or captions with fixed seeds.
* **Bibliography (§G).**
  * The §G1 drops are done.
  * The §G2 fixes are applied exactly (checked entry by entry, including the `claudeSFI` titles and `hanni2026grokking`), and `core.bib` is identical in both papers.
  * 66 entries are cited, and every one except the new `hanni2026grokking` (§G2) appears as verified in `scratch/p1-arxiv/bibcheck-log.md` or `scratch/p1-arxiv-r2/bib_log.md`.
  * The content attributed to each work is at abstract level (Ryabko, Buzaglo, Goldblum and Grau-Moya checked against context §4.7 and §6).
* **Title page and back matter.** Author line, footnote, acknowledgements and code and data are exactly as §A4. `\hypersetup` is set, the TOC is kept and has no `\newpage`.
* **Structure.** Related work is Section 2 (main.tex order as §D2). The contributions list (6 bullets) and the Open problems list (9 items) exist. Every appendix is titled "Proofs for Section N (…)".
* **Cross-references.** 314 labels, no duplicates, no unresolved `\cref`/`\ref`/`\eqref` (script over `sections/*.tex`, app-verification excluded).

## 5. Full build and page counts

`cd paper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, run after my edits:
* LaTeX errors: **0**
* undefined references: **0**
* undefined citations: **0**
* multiply defined labels: **0**
* overfull boxes above 10pt: **0** (the two remaining are 0.84pt and 1.84pt)
* **90 pages**

Page positions come from word bounding boxes (`scratch/p1front/measure_full.py`, copied to `scratchpad/final-p1/scripts/`).

| part | §C budget / cap | pages |
|---|---|---|
| title + abstract + TOC | 1.5 | 1.35 |
| §1 Introduction | 3 | 3.15 |
| §2 Related work | 1.5 | 1.72 |
| §3 Setting / App A | 4.5 / 6.5 | 4.87 / 7.06 |
| §4 Versions / App B | 4 / 4 | 4.02 / 4.11 |
| §5 Learning / App C | 4 / 6 | 4.43 / 5.39 |
| §6 History / App D | 5 / 7.5 | 5.89 / 9.22 |
| §7 Examples / App E | 5 / 6 | 5.33 / 6.10 |
| §8 OOD / App F | 3.5 / 2.5 | 4.09 / 3.60 |
| §9 Computable / App G | 3 / 3.5 | 3.28 / 4.48 |
| §10 NN Bayes / App H | 2 / 1 | 2.48 / 1.30 |
| §11 Steeper summary | 0.5 | 0.49 |
| §12 Discussion + open problems + acknowledgements + code and data | 2.5 | 2.53 |
| **main text (title through Code and data)** | **cap 41** | **43.65 — exceeded by 2.65** |
| references | — | 4.46 |
| **appendices** | **cap 38** | **41.26 — exceeded by 3.26** |
| **total** | **cap 84** | **90 — exceeded by 6** |

**Open (for the lead editor).** Every cut and move listed in §C has been made, and §C's conditional moves have been made where their sections were over budget. The caps still fail.

The largest excesses:
* App D: +1.72
* App F: +1.10
* App G: +0.98
* §6: +0.89
* §8: +0.59

Candidate cuts already listed by the groups (`log-p1-front.md` §7, `log-p1-hist-ex.md` §7, `log-p1-ood.md` §5):
* the numbers after `thm:hist:gf`, `prop:hist:info`, `prop:hist:shannon`
* `tab:ood:hanni`, the grammar paragraph, `prop:ood:relative`
* `prop:comp:occam`, `rem:comp:adversary`, `rem:comp:constant`, `rem:comp:gap`
* `prop:nn:typical`, `rem:nn:bridge`
* `rem:ood:logterm`
* shortening `rem:nn:slides` to 12 lines

I made no such cut: each removes proved or decided material, and that is beyond a minimal fix.
