# Section writer log: group `soi` (§4 and Appendix B)

*2026-10-17. Files written: `paper/sections/soi.tex` (§4, with Table 1) and `paper/sections/app-soi.tex` (Appendix B). No other file was changed. No git command was run.*

## 1. Restart state

An earlier, interrupted run had left a complete first draft of `soi.tex` (about 10 pages of main text). `app-soi.tex` was still the planning stub. I checked the draft item by item against `research/tracks/sfi/notes-final.md` (§0–§11, §15, §16), CLAIMS.md §3 and §11, the synthesis (H1, H7, §2.8, §3) and `final-check.md` §4 items 1, 3, 4, 9 and 10. Its statements were sound. I kept them, fixed the points in §4 below, compressed the prose, and then wrote the appendix from scratch. The old draft is kept only in the scratchpad, as `soi-draft1.tex`. It is not part of the paper.

## 2. What was written

**§4 (`soi.tex`).**
* Opening paragraph, with credit footnote F2.
* §4.1: the objects (`def:soi:objects`) and the four maps, in one paragraph.
* §4.2 Equivalence, version by version:
  * `thm:soi:coinfree`, with a sentence pointing to the schema route (`rem:soi:schema`, now in the appendix);
  * `thm:soi:onetape` and `cor:soi:closed`;
  * a paragraph on axiom-side penalties, the assumptions `ass:soi:S` and `ass:soi:Stape`, and `thm:soi:penalty`, with one sentence each on `prop:soi:classes` and `prop:soi:disguised`.
* §4.3 Positive literals: `thm:soi:transfer`, `cor:soi:transfer`, the statements that do not transfer, and `rem:soi:encoding`.
* §4.4 What breaks:
  * `prop:soi:closure`;
  * the three-valued definitions, `prop:soi:independent`, `prop:soi:noRE` and the mechanism;
  * one sentence on the lottery (`cor:logic:versions`) and one on computability (`prop:soi:computability`).
* §4.5 Time bounds:
  * the clocked definitions, `cor:soi:onesided`, `thm:soi:diagonal`;
  * an incomparability paragraph pointing to `prop:soi:incomparable`;
  * `prop:soi:freededuction`, and the reading paragraph `rem:soi:timereading`.
* §4.6 Charged deduction:
  * the setting and readings, `ass:soi:F1`, `thm:soi:sandwich`;
  * the fit classes in prose, pointing to `cor:soi:fit`;
  * the paragraph `rem:soi:whatcharged`.
* §4.7 Presburger:
  * the setting, Presburger's theorem and the Fischer–Rabin bound, with the proviso on lengths;
  * `prop:soi:presburger`, a one-sentence pointer to `prop:soi:presburgerCond`, `prop:soi:presburgerCharged`, and the summary paragraph `rem:soi:presburgerSummary`.
* §4.8: Table 1 (`tab:soi`, 27 rows) and "How to read the table".

**Appendix B (`app-soi.tex`).** Eight subsections:
1. Decompositions and maps: `lem:soi:mixture`, with equation labels `eq:soi:mixF` and `eq:soi:mixA`; `lem:soi:maps`, with proof.
2. Equivalences:
   * the proofs of `thm:soi:coinfree`, `thm:soi:onetape` and `cor:soi:closed`;
   * `rem:soi:schema` and `def:soi:penalised`;
   * an unlabelled remark headed "Proof sketch" that justifies (S$_{\rm tape}$), as CLAIMS asks;
   * the proof of `thm:soi:penalty`, then `prop:soi:classes` and `prop:soi:chain`.
3. Literals: the proofs of `thm:soi:transfer` and `cor:soi:transfer`; `prop:soi:price`; the proof of `rem:soi:encoding`.
4. What breaks:
   * the proof of `prop:soi:closure`, and `rem:soi:outcomes`;
   * `lem:soi:productive`, proved by Rosser's argument, with Smullyan cited under "cf.";
   * the proofs of `prop:soi:independent` (coin-free, and one-tape by density) and of `prop:soi:noRE`;
   * `rem:soi:product`, `prop:soi:computability`, `q:soi:lsc`, `prop:soi:pathwise` and `q:soi:pathwise`.
5. Time:
   * `prop:soi:kt` and `thm:soi:domination`;
   * the proofs of `cor:soi:onesided` and of `thm:soi:diagonal` (the earlier report's argument, recalled in full);
   * `prop:soi:incomparable`, the proof of `prop:soi:freededuction`, and `rem:soi:freededuction` (proof sketch);
   * `prop:soi:disguised` and `thm:soi:onetapetime`.
6. Charged deduction:
   * the proof of `thm:soi:sandwich`, with the constants re-derived;
   * `cor:soi:fit`, `prop:soi:soft`, `rem:soi:F1` and `rem:soi:onetapesandwich` (proof sketch).
7. Presburger:
   * `rem:soi:lengths`, and the facts F_P and F_FR with the readings (max) and (short);
   * the proof of `prop:soi:presburger`, and one sentence of computed thresholds;
   * `ass:soi:Bstar`, `ass:soi:SGL` and `prop:soi:presburgerCond`;
   * the proof of `prop:soi:presburgerCharged`, and `q:soi:presburger`.
8. The circuit form: definitions and the translation; `thm:soi:circuit`; `cor:soi:circuitBayes`; `rem:soi:axiomsetprior` (proof sketch).

**Checks.**
* Every label of CLAIMS.md §3 appears exactly once in the two files, and no label is duplicated.
* Every theorem-like environment, and every labelled prose paragraph, carries `\status{}` and `\src{}`; I checked this with a script.
* Every `\cref` from other files to `soi` labels resolves.

## 3. Builds and page counts

* `./test-section.sh soi app-soi`: **OK, 0 errors**, 0 undefined citations, 0 overfull boxes over 10pt, no "float too large". The 32 undefined references are all cross-section: logic and terms labels not yet written, plus core labels in the isolated build.
* `./test-section.sh soi`: OK, 0 errors.
* `merge_bib.py`: every key I cite is in `bib/refs.bib` or `bib/core.bib`; none comes only from the fallback.
* **Main text:** about **8.3 pages of text plus Table 1 (one page, `\scriptsize`), about 9.3 pages in all, against a budget of 4.5.**
* **Appendix B:** about **20.3 pages**.
* The isolated build has no title block; the bibliography is excluded from both counts.

## 4. Deviations from OUTLINE and CLAIMS, with reasons

1. **Page budget not met (9.3 pp against 4.5).**
   * The CLAIMS rows marked `main` (about 27 statements) plus a 27-row table do not fit in 4.5 pages without dropping statements from the main text.
   * I compressed all the prose and moved three rows to the appendix under OUTLINE B.3:
     * `rem:soi:schema`: the main text keeps a one-sentence pointer, and footnote F2 still refers to it;
     * `prop:soi:incomparable`: the main text keeps a short paragraph with the counterexample and the refuted strengthening;
     * `cor:soi:fit`: the main text states the fit classes in prose, as the synthesis's plan for §4 asks ("Cor 8.2 in prose").
   * Further moves, with estimated savings, if the editor needs them:
     * `ass:soi:S`, `ass:soi:Stape` and `thm:soi:penalty` to the appendix, keeping one sentence: about 0.6 p;
     * `ass:soi:F1` and `thm:soi:sandwich` to the appendix, keeping the readings paragraph and a prose summary: about 0.5 p;
     * `cor:soi:transfer` to the appendix: about 0.4 p;
     * `prop:soi:presburgerCharged` and the summary paragraph to the appendix: about 0.5 p;
     * `rem:soi:encoding` to the appendix: about 0.25 p.
   * Even with all of these, the main text would be about 6 pages with the table.
2. **`thm:soi:sandwich`: hypothesis added.**
   * The added hypothesis is "with time-constructible nondecreasing budgets".
   * The record's Thm 8.1 omits it, but its source, Proposition E.21 of the earlier report, assumes it.
   * Adding a hypothesis weakens the statement; it never strengthens it.
3. **`thm:soi:onetape`.** The record's parts (a) and (b), the two equivalences, are merged into (a), and its (c) (tape by tape) became (b). The content is unchanged.
4. **`cor:soi:transfer`.**
   * Item (a) includes the two-point rate from the record's (c).
   * The record's chain and covering bounds, and "no computable witnesses", are not listed. They are covered by the general sentence of the corollary.
5. **`rem:soi:schema`(d).** It now reads "for every Σ_n-sound labeller f, one ground reflection sentence of length ≤ a|f|+b_n reproduces f". This makes the quantifier order of Proposition 6.7 of the earlier report explicit; the old draft could be read as one sentence for all labellers.
6. **`prop:soi:disguised`.** The record's clause on two-sorted content-relative penalties is omitted, because those penalties are not defined in this paper. This narrows the statement and does not strengthen it.
7. **`prop:soi:pathwise`(b).** Stated for consistent nonempty D, the hypothesis of `prop:soi:chain` on which it rests.
8. **`ass:soi:Bstar`.** It is not attributed to Berman, because the form (B*) and the reduction sizes are not citable (bib-report §5.3 item 10). Berman is cited only for the completeness result, "as reported in secondary sources", together with the reduction-size caveat.
9. **Local symbols renamed to avoid NOTATION's global symbols.**
   * Certificate γ becomes ζ (γ is the literal cost in §9).
   * The coin literals λ_i become χ_i (λ is reserved for the steepness exponent).
   * The circuit language's `Bit` becomes `Dig` (`\Bit` is the Ω-bit sentence); index and gate terms become bold **n**_i and **g**_j.
   * The record's s_N(f) becomes vs(f), and a_ℓ(f) becomes ax_s(f), with the derivation budget written s as NOTATION §5 requires.
   * N_{s,k} becomes Λ_{j,k}, Γ_N becomes gad, and γ:=2d+2 becomes gg; the posterior mistakes P_i and ℰ become ε_i and Err; W_N becomes W_ver.
   * In Rosser's argument, the relations A and R become Neg and Prf; δ in the open question becomes c_3; the membership degree e becomes k_p; ℓ(m) becomes τ''(m); and the record's D_H becomes Der_H.
   * The circuit size is written |𝒱|, and verifiers are 𝒱, never V.
10. **Labels added** (all allowed by OUTLINE B.2): `eq:soi:mixF`, `eq:soi:mixA`; `sec:soi:objects`, `sec:soi:equiv`, `sec:soi:literals`, `sec:soi:breaks`, `sec:soi:time`, `sec:soi:charged`, `sec:soi:presburger`, `sec:soi:summary`; `sec:app:soi:maps`, `sec:app:soi:equiv`, `sec:app:soi:literals`, `sec:app:soi:breaks`, `sec:app:soi:time`, `sec:app:soi:charged`, `sec:app:soi:presburger`, `sec:app:soi:circuit`.
11. **Table 1.**
    * It is set in `\scriptsize` with three columns, the hypotheses folded into the relation column in parentheses, so that it fits on one page; at `\footnotesize` it overflowed the page by about 100pt.
    * The caption says that every charged-deduction row assumes (F1).
    * Rows follow synthesis §3 (E1–E13, G1–G6, S1–S11, F1–F8), condensed.
12. **Statuses rendered in prose.**
    * Computed numbers appear only outside statements: the Presburger thresholds (11–26 and 6–9 at c=1, c'=0.9), the circuit-translation size ratio (7.9–9.0), and the finite analogues. Each says "code in the accompanying repository", and no script names are printed.
    * Proof sketches are Remarks headed "Proof sketch" whose first sentence says what is not written out: `rem:soi:freededuction`, `rem:soi:onetapesandwich`, `rem:soi:axiomsetprior`, and the (S$_{\rm tape}$) remark.
    * The refuted strengthening is rendered as "the natural strengthening … fails".
13. **Credit and novelty.**
    * Credit footnote F2 is in the first paragraph, with the OUTLINE text.
    * Kleene's recursion theorem is called "standard", since no verified bibliography key exists for it.
    * Novelty of the coin-free equivalence: "the construction is Craig's; the theorem shows that it works inside the universal prior, weight by weight, and apart from that report we have not found the weight equivalence stated in the literature" (bib-report §4.4).

## 5. Items for other groups

* **logic.** Please provide the labels `thm:logic:lottery`, `cor:logic:versions`, `lem:logic:density` and `cor:logic:coding`.
  * §4 and Appendix B cite them for the lottery sentence, the density arguments of `prop:soi:independent` and `prop:soi:presburger`(c), and two Table 1 rows.
  * The remark after `q:soi:pathwise` says that the lottery machine is consistent on every tape, citing `thm:logic:lottery`. Please make sure §5 states this, or tell me and I will cite it differently.
* **terms.** Table 1 cites `thm:terms:horn`, `thm:terms:KCV`, `thm:terms:padded`, `cor:terms:table`, `prop:terms:a1fit`, `thm:terms:binary` and `thm:terms:regular`, which are not yet written.
* **shape.** `thm:shape:knowhow` is in `app-shape.tex`, so `rem:soi:whatcharged` reads "Section 7, in particular Theorem E.x". That is fine; if it moves to `shape.tex`, nothing changes on my side.
* **core.** All the labels I cite exist: `def:setting:data`, `def:setting:MA`, `def:setting:fresh`, `lem:setting:measurable`, `prop:basic:structure`, `prop:basic:form`, `thm:basic:inc`, `thm:basic:nocoding`. `rem:setting:versions` can cite `ass:soi:S`.
* **front, and the planning editor.**
  * Open questions for the Discussion index, all in Appendix B: `q:soi:lsc`, `q:soi:pathwise`, `q:soi:presburger`.
  * The labelled prose paragraphs (`rem:soi:timereading`, `rem:soi:whatcharged`, `rem:soi:presburgerSummary`) resolve under `\cref` to their subsection ("Section 4.5" etc.).
  * See §4 item 1 for the budget.

## 6. Citations used

Citation keys:
* `claudeSFI2026fundamentals`
* `claudeSFI2026steeper`
* `claude2026axiominduction`
* `hanni2026notes` (footnote F2 only)
* `craig1953axiomatizability`
* `smullyan1961theory` (with "cf.", for effective inseparability)
* `deleeuw1956computability` ("in the manner of" and "the technique of", for the majority vote at a density point)
* `matiyasevich1970enumerable`, `davis1973hilbert` (MRDP)
* `cook1979relative`
* `chandra1981alternation`
* `hartmanis1965computational`, `seiferas1978separating` (hierarchy theorems, with "cf.")
* `presburger1929vollstandigkeit`
* `fischer1974super` (abstract-level statement only; its length convention is stated as a proviso, not attributed)
* `boolos2007computability` (textbook facts, no chapter numbers)
* `church1936note`
* `lowenheim1915moglichkeiten`, `behmann1922beitrage` (decidability of monadic logic only)
* `berman1980complexity` (secondary-level, hedged)
* `sipser1983complexity`, `lautemann1983bpp`
* `pippenger1979relations`

The earlier report and the companion paper are cited by printed numbers read from their `main.aux`:
* earlier report: Thms 6.3, 6.9, 6.14, 6.15, 6.16; Cor 6.17; Props 6.4–6.7; App. E.6; Def E.10, E.18; Lemmas E.11, E.12, E.14, E.19, E.28; Props E.1, E.13, E.15, E.16, E.17, E.21, E.23, E.26, E.27;
* companion paper: Def 3.6, 9.1, 9.7; Props 3.9(a), 3.24, 4.5(a), 4.6, 4.7, 9.4; Thms 3.21(a), 4.9, 9.8; Cor 4.10.

## 7. Final greps

* The OUTLINE B.11 grep, run outside comments, `\src`, `\status` and citation keys, gave **no hits** in either file.
* `pdftotext` of the isolated build gave no hits for thread, track, scout, referee, workflow, agent, record or synthesis.
