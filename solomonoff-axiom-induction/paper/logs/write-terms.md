# Writer log: group terms (§8 `sections/terms.tex`, Appendix F `sections/app-terms.tex`)

*Complete (2026-10-17).*

## 1. Restart check and sources

* **Restart check.** At the start both files were the planning editor's stubs and there was no log, so nothing was recovered. The files were written early and saved after each part. Earlier drafts of `terms.tex` (about 9, 7.5 and 6 pages of main text) are in the session scratchpad folder `terms/`; they are not part of the paper.
* **Read.**
  * The brief `research/00-brief.md`.
  * The `terms` final record `research/tracks/terms/notes-final.md`, in full (§0–§18).
  * `fundamentals` Prop 1.8(d); `philosophy` final record §1.6; `logic` Thm 2.2 (the statement).
  * The synthesis H4, §2.2–§2.4, §2.8 and §6.4; `research/final-check.md` (items 7 and 8 and the H4 rows).
  * OUTLINE.md (§A–§C, §8, App. F, §E, §H); CLAIMS.md (§0, §7, §10–§13, the `soi` rows and `rem:phil:hempel`); NOTATION.md (all); `preamble.tex`; `bib/bib-report.md` (§1, §2.3, §4.3, §5) and the comments of every cited entry in `bib/refs.bib`.
  * REFRAME.md and DECISIONS.md §0, §A of the companion papers.
  * The labels and statements that this section cites in `setting.tex`, `basic.tex`, `soi.tex`, `app-soi.tex`, `app-basic.tex` and `logic.tex`.
  * The earlier report's printed numbers, from `../axiom-induction/paper/main.aux`: Definition E.18, Lemma E.11, Lemma E.12, Proposition E.21, Lemma E.22, Proposition E.23, Theorem 6.14 and Corollary 6.17.
* **Checked against saved outputs.** Every number quoted in the paper was compared with the saved outputs `checks/t1_hempel_toy.out`, `t3_alternating.out`, `t4_two_stack.out`, `t4_regular.out`, `t5_monadic.out` and `t6_revision.out`, and with the referees' `.out` files. In particular, the Example 3.4 figures at $\lvert w\rvert=24$ come from `t6_revision.out` Part D:
  * $\log_{10}$ of the Craig axiom's size is at least 204.610, printed as "more than $10^{204.6}$";
  * the certificate axiom has 795 symbols, and the fast labeller's Craig axiom 702.

## 2. What was written

**§8 (`terms.tex`).** Its parts, in order:
1. An introduction: Hempel's dilemma, Craig, Ramsey, and ladder step 3.
2. *Setting and the dilemma theorem.* `def:terms:obs`, `def:terms:literal`, `def:terms:named`, then `thm:terms:dilemma` with a proof made of pointers. The proof lists the condition of each part.
3. *In principle.* `thm:terms:horn` with a proof idea, and `rem:terms:hempel`.
4. *In practice.* In prose: Craig's padding and the Horn example. Then `thm:terms:padded` with its proof idea, and the literature sentence of bib-report §4.3, citing \citet{krajicek2025proof}. Then, in prose, elimination by proof padding, the pairing gadget, one binary relation, and the credit to Kleene and to Craig–Vaught.
5. *Vocabulary or ontology.* `thm:terms:regular` with a proof idea. Then, in prose: the converse, the fit-class table, the forced ontological commitment (in the wording of fc item 8), conservativity, Ramsey against pairing, and the binary observable.
6. *Finite theories with free deduction.* In prose: infinity, named objects, symbol costs, Ramsey against Craig, PA, the many-sorted form of Kleene–Craig–Vaught, the one-tape caveat, and factoring.
7. *What this does and does not show.* Then `rem:phil:hempel`, as a labelled `\paragraph` (CLAIMS places it in §8).

**Appendix F (`app-terms.tex`).** Every row of CLAIMS §7 that is not stated in §8, with full statement and proof, and the proofs of the §8 results. Subsections:
* `app:terms:horn`
* `app:terms:craig`
* `app:terms:eliminate`
* `app:terms:binary`: Def 4.4, Lemma 4.5, Thm 4.6 and the alternating compile of Prop 4.7, with Steps 1–4 written out.
* `app:terms:ontology`
* `app:terms:finite`

**Subsection labels added:**
* §8: `sec:terms:setting`, `sec:terms:horn`, `sec:terms:craig`, `sec:terms:ontology`, `sec:terms:finite`, `sec:terms:reading`. (`sec:terms:dilemma` and `sec:terms:eliminate` were used in an earlier draft only; no `\cref` points to them.)
* Appendix F: `app:terms:horn`, `app:terms:craig`, `app:terms:eliminate`, `app:terms:binary`, `app:terms:ontology`, `app:terms:finite`.

**Ledger coverage.** All 39 rows of CLAIMS §7 and `rem:phil:hempel` are present, each exactly once, with `\status{}` and `\src{}`. There are no duplicate labels.

## 3. Page counts (isolated build `./test-section.sh terms app-terms`)

`OK: pages 29; 0 undefined citations; 52 undefined refs (cross-section refs expected); 0 overfull hboxes >10pt`; 0 LaTeX errors. All 21 distinct undefined labels exist in other groups' files (checked by grep): `ass:soi:*`, `cor:soi:fit`, `prop:soi:classes`, `prop:soi:disguised`, `prop:soi:soft`, `thm:soi:penalty`, `thm:soi:sandwich`, `sec:soi:charged`, `def:setting:*`, `sec:setting`, `lem:setting:measurable`, `cor:basic:vocabulary`, `thm:basic:dominance`, `thm:basic:translation`, `thm:logic:lottery`, `sec:phil`, `sec:phil:map`. `merge_bib.py`: 0 keys from the fallback, 0 missing.

* **Main text (§8): about 5.8 pages.** Pages 1–5 are full, and the appendix starts at line 42 of 50 on page 6. **Budget: 3 pages; over by about 2.8 pages.**
* **Appendix F: about 21.5 pages**, from page 6, line 42, to page 28, line 20.

**Why the overrun.** Only eight environments remain in §8:
* the three definitions;
* the dilemma theorem;
* `thm:terms:horn`, `thm:terms:padded` and `thm:terms:regular`;
* `rem:terms:hempel`.

Everything else is in Appendix F, with precise prose in §8. Two things take most of the space:
* the dilemma theorem (about 0.8 page), which by design restates the parts;
* `thm:terms:horn` (about 0.6 page with its definition).

**Options for the planning editor, if §8 must shrink further** (savings approximate):
* (a) Move `thm:terms:horn` and the second half of `def:terms:obs` to App. F; the dilemma theorem's part (i) states the content. About 0.8 page.
* (b) Cut "What this does and does not show" to three sentences. It repeats the intro and the dilemma. About 0.2 page.
* (c) Cut the prose paragraph of `sec:terms:finite` to its first and last sentences. About 0.35 page.
* (d) OUTLINE §E's fallback: merge §8 into §6 and §7 and keep only `thm:terms:dilemma`, with the "what this shows" paragraph and `rem:phil:hempel`. About 2 pages in all.

## 4. Deviations from OUTLINE and CLAIMS, with reasons

1. **Rows moved from the main text to Appendix F** (rule B.3, page budget). Each has its full statement and proof in App. F, and a precise prose summary with `\cref` in §8.
   * `lem:terms:unary`, `cor:terms:table`, `prop:terms:eliminate`.
   * `thm:terms:binary`. The ledger asks for an "informal statement" in main; §8 gives it in prose, and the theorem itself, Thm 4.6 (i)–(iv) with Prop 4.7 in (iv), is in App. F.
   * `thm:terms:everyregular`, `cor:terms:ontology`.
   * `prop:terms:ontology`. Its content is in §8 prose and in the dilemma theorem (iv), with the fc-8 wording.
   * `thm:terms:infinity`. The infinity separation is still stated once, in App. F; §8 gives the separation in one precise sentence.
   * `rem:terms:named`, `thm:terms:PA`.
   * `thm:terms:KCV`. §8 gives $\Kfin^{\mathcal L^+}=\KA^{\mathcal L}\pm c$ and $2^{-c}\WA^{\mathcal L}\le\Wfin^{\mathcal L^+}\le2^c\WA^{\mathcal L}$ in prose.
   * `rem:terms:onetape`, `prop:terms:ramsey`, `prop:terms:factoring`.
2. **Two rows whose source column does not match their description.**
   * **`prop:terms:conservativity`.** CLAIMS gives the source as "terms Prop 9.2", but its description, "conservativity and the ontological commitment (scout S's Q3.18)", is the title of record §9.2, which contains **Prop 9.1**. Prop 9.1 has two parts: (a) conservativity and (b) the ontological commitment.
   * **The split used.** `prop:terms:conservativity` is Prop 9.1(a), with `\src{terms Prop 9.1(a)}`. `prop:terms:ontology` is Prop 9.1(b) together with Thm 5.1 in contrapositive form, with `\src{terms Prop 9.1(b); Thm 5.1, contrapositive form}`.
   * **Prop 9.2.** Record Prop 9.2 (unary observational languages) has no row of its own. It is part (a) of `prop:terms:binaryobs` ("Richer observational languages", `\src{terms Props 9.2, 9.3}`); part (b) is Prop 9.3.
   * **Request:** the planning editor should update the two CLAIMS rows.
3. **Credit footnote F8 (the spare slot) used**, in §8 at the sentence that introduces factoring: "The idea of introducing a concept that factors a complete bipartite pattern of inferences first appeared in Hänni's working notes \citep{hanni2026notes}."
   * The idea is in `research/prior/good-concepts-are-concepts-that-support-inferences.md`, and the record credits it (Prop 7.2, "(Hänni's working notes)").
   * **Request:** the front writer should approve it, per OUTLINE §C (F8).
4. **Unnumbered paragraphs in App. F, not ledger rows.** These record content and are proved or computed in the record:
   * why the alternating output rules must be exact (Prop 4.7, §11 item 1);
   * relativisation to Std is needed (Rem 4.8, computed);
   * naming composites without observing them (Rem 9.3′, proved);
   * the fit class of infinite hypotheses about the named objects under (b) (Rem 5.6, proved bounds).

   No numbered environment was added beyond the ledger.
5. **Left out, as CLAIMS §13 allows:**
   * Thm 6.5's one-sorted version (a proof sketch). App. F says "We do not treat the one-sorted version."
   * Rem 9.0 (speed-up), Table 7.4 and Rem 7.3.
   * The (a1) hypothesis-by-hypothesis translation (a proof sketch in the record, "not needed"). App. F says it is not claimed.
6. **Literature limited to bib-report levels.**
   * **Not used for the quantitative Lemma 6.1:** Löwenheim and Behmann. They are cited only for the decidability of monadic logic.
   * **Not mentioned:** the essential-reflexivity proof idea for Ryll-Nardzewski's theorem (bib-report §5.3 item 3, not citable).
   * **Kleene and Craig–Vaught:** stated "as stated in \citet{pakhomov2019question}", since their content is at the secondary level.
   * **ACA$_0$:** "(see \citealp{simpson2009subsystems})".
   * **Hintikka and Tuomela 1970** (content not seen): not cited. The monadic-inductive-logic contrast cites only `niiniluoto1973theoretical`, for which the abstract was seen.
   * **Putnam 1962:** not cited. Its bib comment allows it only as a source of the attack on the received view, which this section does not need.
7. **Statuses, how rendered.**
   * `thm:terms:horn`(c): "under Assumption (S) / (S$_{\rm tape}$)" in the statement.
   * PG rows: the given result is cited in the proof, or in the statement's hypotheses (Ehrenfeucht–Fraïssé, the one-tape simulation, $\cplx{APSPACE}=\cplx{EXPTIME}$, Ryll-Nardzewski, $\Con(\PA)$, the $\Sigma_1$-completeness of $\Q$, `thm:logic:lottery`, the earlier report's E.11, E.12, E.21, E.22, E.23, 6.14 and 6.17).
   * `ex:terms:craig` (C): an Example with the closed forms; the numbers at $n=24$ are in a sentence after it, with "(a direct computation …; code in the accompanying repository)".
   * Computed checks of proved items: a sentence after the proof, without script names.
   * `rem:terms:PAtruth` (S): a Remark with "Proof sketch."; its first sentence says what is not written out.
   * The three O rows: `question` environments.
   * R:
     * "the natural strengthening … fails" (Thm 3.3, sets of literal-equivalent axioms);
     * "the natural claim that it always saves $n_An_B-(n_A+n_B)$ … fails" (factoring).
   * As: `rem:phil:hempel` in the "we" voice. Its key sentence: "This is a statement about the mixture; Hempel's own notion is relative to a single theory, and our statement is not a reconstruction of it."
   * fc item 7: the status list of the dilemma theorem is in its proof.
   * fc item 8: the "some sentence" wording is used in `thm:terms:dilemma`(iv), in `prop:terms:ontology`(a) and in the §8 prose.
8. **Novelty sentences, per bib-report and the record.**
   * Thm 3.3: "We did not find a complexity-theoretic form of the classical reply in the literature", with Krajíček cited (bib-report §4.3).
   * The binary-relation construction and fit classes, and the observational translation: "To our knowledge … new".
   * Thm 5.1: "in the spirit of Craig and Vaught's example … we have not established that it is new".
   * Thm 6.5: "only the Bayesian consequence is new".
   * The carry counter: no novelty claim.

## 5. Notation

No global macro was defined or redefined. Global symbols are used as in NOTATION.md. In particular:
* $\mathsf C$ is the binary relation;
* $\mathrm{Dinf}_f$ replaces the record's $\iota_f$;
* $\UA(\mathcal C_\Theta;D)$ uses the local class $\mathcal C_\Theta:=\{T:T\cap\Sent_{\LO}\in\Theta\}$;
* $\Infn{n}$, $\ThT$, $\LO$, $\LT$ are the macros.

Local renames of record symbols, also listed in the file headers:

| record | here | reason |
|---|---|---|
| tags $\eta$ | $\mathrm{tg}$ | NOTATION §11 |
| $c(q)$ | $\mathrm{cd}(q)$ | $c$ is a machine constant |
| $M_1$, $\Sigma_M$ | $\mathcal M_1$, $\Sigma_{\mathcal M}$ | avoid $M_A$, $M_F$ |
| $S_0,S_1$ (graph relations) | $\mathrm{Gr}_0,\mathrm{Gr}_1$ | $S$ is successor |
| $L^{\rm rel}$ | $\mathcal L^{\rm rel}$ | languages are calligraphic |
| $N_q$ | $\mathrm{ncl}_q$ | $N$ is global |
| window $W$ | $\mathrm{wd}_X$ | $W$ is a weight |
| $S_\sigma$ | $\mathrm{Sg}_\sigma$ | $S$ is successor |
| cells $C_\tau$ | $\mathrm{Cell}_\epsilon$ | $C$, $\tau$ are global |
| carries $Q_i$ | $\mathrm{Cr}_i$ | clash with $\Q$ |
| $F_e$ | $\mathrm{Fin}_e$ | $F$ is a function machine |
| $g(F)$ | $\mathrm{ct}(\chi)$ | $g$ is a budget |
| clauses (Q), (U), (D), (S), (E) | (Ar), (Up), (Den), (Sat), (Ax) | (D), (S) clash with data and Assumption (S) |
| $E$, $O$ (Ex 3.4) | $\mathrm{Ev}$, $\mathrm{Od}$ | $E_D$ is global |
| configurations $c$ (Prop 9.4) | $\varsigma$ | $c$ is a machine constant |
| $A_i$, $B_j$ (Prop 7.2) | roman $\mathrm A_i$, $\mathrm B_j$ | $A$, $B$ are axiom set and background |
| $I,J$ | $I_A,I_B$ | $J$ is the binary observable |
| $G(m)$, $G'(m)$ (Prop 4.1) | $\bar g$, $\bar g'$ | $G$ is a theory machine |
| $t^{+\#}$ | kept | — |
| $c_{\mathcal V}$, $\Sigma_{\mathcal V}$ | $\mathrm{mx}_{\mathcal V}$, $\mathrm{tot}_{\mathcal V}$ | avoid $c$ and $\Sigma_1$ |
| $A^G$ (Gödel padding) | $A^{\rm gn}$ | $A^G_\omega$ is global |
| $C$, $C'$ (Prop 4.3) | $\mathsf C$, $\mathsf C'$ | NOTATION §9 |
| $M$ (alternating machine) | $\mathcal M$ | avoid $M_A$, $M_F$ |
| $G(n)$ in Thm 6.2(b) | $u$ | $G$ is a theory machine |

## 6. Final greps (OUTLINE B.11), on both files outside comments, `\src{}` and `\status{}`

* **Hits:**
  * `\citet{claude2026axiominduction}`, six times. These are citation keys, which print the authors' names.
  * "tracks of one tape" (App. F, Step 1: the standard multi-track simulation). This is a legitimate technical use.
* **No other hits:** no thread, scout, referee, record, synthesis, brief, notes-final, verdict, revision, unverified, snippet, AI-paper, TF, SD, H1–H15, P1 or P2. No model names.

## 7. Items for other groups

* **Planning editor:**
  * the page overrun and the options in §3;
  * the two CLAIMS rows of §4 item 2;
  * the "place" column of the rows moved in §4 item 1;
  * the new subsection labels in §2.
* **Front writer:**
  * approval of credit footnote F8 (§4 item 3);
  * the Discussion's open-problems list should `\cref` `q:terms:binaryobs`, `q:terms:a1` and `q:terms:unaryfunction` (all in App. F; none is ★);
  * the related-work bibliography for theoretical terms uses `hempel1958theoretician`, `craig1953axiomatizability`, `ramsey1931theories`, `kleene1952finite`, `craigvaught1958finite`, `pakhomov2019question`, `putnam1965craig`, `niiniluoto1972inductive`, `niiniluoto1973theoretical`, `krajicek2025proof`, `muggleton1988machine`, `rylnardzewski1952role`, `simpson2009subsystems`.
* **soi writer:** `tab:soi` cites `cor:terms:table`, `prop:terms:a1fit`, `thm:terms:binary`, `thm:terms:regular` and `thm:terms:KCV`. All are defined, now in App. F except `thm:terms:regular`, so the references resolve.
* **laws writer:** `rem:terms:named` is now in App. F; its statement is unchanged ($\KA\le c$, $\Kfin=\Kpad(n)\pm c$).
* **phil writer:** `rem:phil:hempel` is defined in §8, as CLAIMS places it. It rests on `thm:terms:horn` and `thm:terms:dilemma`, and uses the CLAIMS wording ("Hempel's own notion is relative to a single theory").

## 8. Citations used (all "citable" in bib-report; none from the fallback)

`behmann1922beitrage`, `boolos2007computability`, `chandra1981alternation`, `claude2026axiominduction`, `craig1953axiomatizability`, `craigvaught1958finite`, `ebbinghaus1999finite`, `ehrenfeucht1961application`, `fraisse1954quelques`, `hajek1993metamathematics`, `hanni2026notes` (footnote F8 only), `hartmanis1965computational`, `hempel1958theoretician`, `kleene1952finite`, `krajicek2025proof`, `lowenheim1915moglichkeiten`, `muggleton1988machine`, `niiniluoto1972inductive`, `niiniluoto1973theoretical`, `pakhomov2019question`, `putnam1965craig`, `ramsey1931theories`, `rylnardzewski1952role`, `simpson2009subsystems`.

No git command was run. No full build was run (it is reserved for the front group).
