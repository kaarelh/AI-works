# Section writer log: group "laws" (§9 `sections/laws.tex`, Appendix G `sections/app-laws.tex`)

*2026-10-17. Files written: `sections/laws.tex` (§9, about 26 KB) and `sections/app-laws.tex` (Appendix G, about 120 KB). No other file was edited. No git command was run.*

## 1. Restart check

When this run began, `sections/laws.tex` held a complete draft from an interrupted earlier run (62 KB, about 14.5 pages of main text, every statement in the main text). `sections/app-laws.tex` was still the planning stub, and there was no log. I read the draft in full and checked each statement against `research/tracks/laws/notes-final.md`, CLAIMS.md §8 and §11, the synthesis (H8, H10, §2.8) and `final-check.md`. Its statements matched the record, apart from the points in §4 below, and were kept. The draft is saved in the session scratchpad as `laws/laws-v1.tex`; it is not part of the paper.

I then wrote Appendix G from scratch: every full statement, every proof, and the computations. I rewrote §9 as a compact main text in three passes, for the page budget.

## 2. Sources read

* In full: the laws final record (`research/tracks/laws/notes-final.md` §0–§13 and §15); CLAIMS.md §0, §8, §11–§13; NOTATION.md; OUTLINE.md; the brief's binding rules as they are restated in OUTLINE §A.
* The synthesis H8, H10, §2.8 and §6.6. `final-check.md`, for the items that touch laws (the "34 of 39" qualifier, H8/H10 "match").
* `bib/bib-report.md` §1 and §5, plus the verification comment in `bib/refs.bib` of every key cited.
* The fundamentals record: Thm 4.1, Prop 5.2 and Prop 6.1 (the statements that the proofs use).
* The companion paper on steeper priors (`../solomonoff-operator-induction/paper-steeper`): `main.aux`, for printed numbers, and the statements of Thm 4.2, Cor 4.5, Def 5.2, Lemma 5.3, Cor 5.4, Cor 5.5 and Prop 5.7.
* Saved outputs `checks/l7_best_system.out` and `checks/l10_revision.out`, for the quoted numbers (the toy population, the residual statistics, the fine-precision rates).

## 3. What was written

**§9 (`laws.tex`).** The subsections are:
1. Setting (`sec:laws:setting`), with `def:laws:setting`.
2. Deterministic theories and precision (`sec:laws:strength`), with `prop:laws:rounding`.
3. Randomised theories and laws with error models (`sec:laws:random`). It contains `prop:laws:errormodel` and the paragraph "Kepler's residuals".
4. Sound reasoning (`sec:laws:sound`), with `rem:laws:typical`.
5. The best system as a steeper MAP (`sec:laws:best`), with `prop:laws:kink` and `def:laws:EP`.
6. Explanation and correction (`sec:laws:explain`).
7. Domains of applicability and retention (`sec:laws:domains`), with the assessment paragraph `rem:laws:domainlearning`.

Every other row of CLAIMS §8 is stated in §9 as a precise sentence that keeps its hypotheses, with a `\cref` to its full statement in Appendix G. Credit footnote F6 is attached to the first paragraph.

**Appendix G (`app-laws.tex`).** It has eight subsections:
* G.1 `app:laws:setting`: technical points, `lem:laws:decidable`, `prop:laws:exceptions`.
* G.2 `app:laws:random`: `prop:laws:randomised`, `prop:laws:twopart`, `rem:laws:JR`, `q:laws:JR`, `prop:laws:P2hyp`, `prop:laws:codingbound`.
* G.3 `app:laws:precision`: `prop:laws:strength`, `prop:laws:monotone`, `prop:laws:tolerance`, the proof of `prop:laws:rounding`, `prop:laws:choice`, computations.
* G.4 `app:laws:honest`:
  * forms and pricings; `lem:laws:tolerancelaw`, `prop:laws:rates`, `prop:laws:patches`, `prop:laws:peaked`, `prop:laws:quantile` (ν-SVR credited), `lem:laws:codeR`;
  * band-confined completions; the proof of `prop:laws:errormodel` and a table of synthetic errors (unlabelled);
  * `prop:laws:fine`, `thm:laws:as`, `cor:laws:phases`, the simulations, `prop:laws:humility`;
  * `tab:laws:residuals` and the details of the Kepler residuals.
* G.5 `app:laws:sound`: `prop:laws:horizon` (with the non-linear counterexample), `prop:laws:exacthorizon`, `prop:laws:sound`.
* G.6 `app:laws:best`: `prop:laws:slopes`, the proof of `prop:laws:kink`, `prop:laws:trivial`, `prop:laws:once`, the toy and `prop:laws:K3` (with the membership counterexample), `prop:laws:questions`.
* G.7 `app:laws:explain`: `prop:laws:EP`, `prop:laws:copernicus`, the toy and `prop:laws:correction` with its proof, `rem:laws:correction` (a proof sketch), and a table of the three perturbations.
* G.8 `app:laws:domains`: `prop:laws:domain` with the Moon table, `prop:laws:retention` with the retention table, `q:laws:domains`.

**Ledger check (script).** All 45 labels of CLAIMS §8 are defined exactly once, each with `\status{}` and `\src{}`. The only labels added are subsection labels (`sec:laws:*`, `app:laws:*`). There are no table or equation labels beyond the ledger's.

**Statuses rendered.**
* Proof sketch: `rem:laws:correction` is a Remark headed "Proof sketch", whose first sentence says what is not written out.
* Computed: every number is outside the statements, as "a computation (code in the accompanying repository) gives …".
* Open: `q:laws:JR` and `q:laws:domains` are `question` environments.
* Assessment: `rem:laws:domainlearning` is a prose paragraph in the "we" voice.
* Copernicus: the status says "lengths not measured", and the text says so too.
* Given-results: the "proved, given X" statuses name X, with printed numbers for the companion paper.

## 4. Deviations from OUTLINE/CLAIMS, and points of statement

1. **Page budget not met: main text about 5.5 pages, against a budget of 3.5.** See §5.
2. **Rows moved from the main text to Appendix G** (rule B.3, for the page budget). Each has a precise summary sentence in §9 with a `\cref`:
   * `prop:laws:strength`, `prop:laws:tolerance`, `prop:laws:randomised`;
   * `prop:laws:twopart` (part (a) is quoted in §9);
   * `prop:laws:peaked`, `prop:laws:humility`, `tab:laws:residuals` (the peakedness ranges are quoted in §9);
   * `prop:laws:sound`, `prop:laws:once`, `prop:laws:K3`, `prop:laws:trivial`, `prop:laws:EP`, `prop:laws:copernicus`;
   * `prop:laws:domain`, `prop:laws:retention`, `prop:laws:correction`.

   The "place" column of CLAIMS §8 should be updated by the planning editor. `thm:laws:as` remains "one sentence + app", as planned.
3. **Theory length.** NOTATION §8.1 defines $J_\lambda$ with $\lVert T\rVert$. The record's $|T|$ has a stop bit, $|T|=\lVert T\rVert+1$. App G says so in its first paragraph: the change shifts every statement by an additive constant at most and leaves the $\lambda$-MAPs unchanged.
4. **Companion-paper citation corrected.** The earlier draft cited Corollary 4.5 of the steeper paper for "the same for the one-tape class". That corollary is "No universal product hypothesis". §9 now says that the one-tape class has a universal member that absorbs every hypothesis (Theorem 4.2) and that product classes have none (Corollary 4.5). Every other printed number was checked against `paper-steeper/main.aux`: Def 3.3, Def 3.4, Def 3.6, Lemma 3.8, Lemma 3.9, Thm 4.2, Cor 4.5, Def 5.2, Lemma 5.3, Cor 5.4, Cor 5.5, Thm 5.6, Prop 5.7, Lemma A.1.
5. **Hypotheses made explicit or proofs completed** (none of these strengthens a statement):
   * `prop:laws:fine`(c) states the hypothesis $\varepsilon^*<\mathsf R/(2\mathrm e)$, which the record's "Suppose also" carries over from the preceding bullet.
   * `prop:laws:correction`(f) uses the offset $(\varepsilon_{\min},0)$ in place of the record's $(10^{-4},0)$, so that the proof covers every $\varepsilon_{\min}>0$, as the statement says.
   * The non-linear horizon counterexample is stated for every depth, with the one-line induction; the record computed it for $r\le30$.
   * `prop:laws:retention`(c) says that the retained widths form "an interval with no upper bound inside the range; call its lower end $\Delta^*$". The record wrote $[\Delta^*,\cdot)$, but at $\Delta^*$ the rates tie and retention is not eventual in general.
   * `prop:laws:humility`(a) adds a pointer to `prop:basic:structure` (the ledger's dependency), worded as an analogue.
6. **Renamed local symbols** (NOTATION rule 2; listed in both files' header comments). The renames are:
   * $c_{\rm time}$ for $\pi_c$; $\zeta_j$ for $\eta_j$; $Z$ for the patch set $S$;
   * $\underline f,\overline f$ for $l,u$; $\mathcal G,\mathcal F$ for $G,F$ (machines are global); $w$ for the band position $x$;
   * $\vartheta$ for $\phi$ (Lemma 3.6); $\bar c_\Delta(w)$ for $C_\Delta(w)$; $P^\star$ for the true conditional law;
   * level $x$ and times $\tau_x,\varsigma_x$ for $L,\tau_L,\sigma_L$ (Thm 3.8);
   * $\Psi$ for the map $F$ (§4); $m$ for the dimension $d$; $\varepsilon^{(r)}$ for $e_r$ (the error is $e$);
   * $T_{\rm tr}$, $h_{\rm tr}$ for N, $h_N$; $\star$ for the system M; $\mathrm{El}_b$ for $E_b$; $\gamma$ for the literal cost $c$; $n_{\rm tot}$ for $N$; $k_{\rm b}$, $m_{\rm b}$ for the numbers of bodies;
   * $\mathrm{Rot}$, $\mathbf P$, $\mathbf J$, $\eta_{\rm c}$, $\bar t$, $T_{\rm new}$ for $R$, $P$, $J$, $\eta$, $W$, $T_N$ (§7);
   * $\mathrm{Pt}_f$, $\mathrm{Pt}_s$, $\mathrm{Cop}$ for $P_f$, $P_s$, $C$; $\theta_{\rm sh}$, $k_{\rm sh}$ for $C$, $k_C$;
   * $\mathrm{Act}$ for Lewis's predicate $F$; $\kappa_{\rm b}$ for the band inflation $\kappa$.
7. **Myrvold.** Content is cited only at abstract level. The text says that $U$ "has the form of" his measure and does not claim that his formula coincides with $U$ (App G). The Copernicus comparisons are kept separate, and the identification with Myrvold's term is not made (as CLAIMS requires).
8. **Kuhn 1957** is cited only "for the history", as the comment in its `refs.bib` entry requires. **Srinivasan et al. 1994** (content not seen) is cited only with "cf." for the compression criterion of ILP, alongside Muggleton 1995. **Schölkopf et al. 2000** is cited with "cf." for the ν-SVR form of the quantile fact.
9. **Refuted items** are not printed as claims and not attributed. Only the correct K3 criterion is stated, with the membership counterexample as "Part (b) compares law choices; it is not membership of the $\lambda$-MAP". The "natural expectation that coarse data protect a false exact law" is corrected without attribution.

## 5. Page counts (isolated builds)

* `./test-section.sh laws app-laws`: `OK: pages 32; 0 undefined citations; 18 undefined refs (cross-section refs expected); 0 overfull hboxes >10pt`. There are 0 LaTeX errors and 0 multiply defined labels.
* `./test-section.sh laws`: `OK: pages 7; …; 0 overfull hboxes >10pt`.
* **Main text (§9): about 5.5 pages.** The section alone runs to page 6, line 22 of 52; in the combined build Appendix G starts on page 6, line 29. **Budget: 3.5 pages; over by about 2 pages.**
* **Appendix G: about 25 pages** (page 6, line 29, to page 31).
* **History.** The draft found at restart was about 14.5 pages of main text. Three compression passes moved 16 statements and the residual table to the appendix and condensed the summaries.
* **What remains in the main text.** The definition (about 0.9 page), five results that carry the section, their proof ideas, and precise summaries of everything else.
* **If §9 must reach 3.5 pages, the next cuts, in order:**
  1. Move `prop:laws:rounding` to App G, leaving one sentence (about 0.25 page).
  2. Shorten parts (c)–(d) of the definition by moving regime G and the presentation-language detail into App G (about 0.3 page).
  3. Merge `sec:laws:sound` and `sec:laws:domains` into one paragraph each (about 0.3 page).
  4. Move `prop:laws:kink` to App G, leaving one sentence (about 0.3 page).

  Below that, the error-model proposition, which carries the section's headline, would have to leave the main text.

## 6. Final greps

The OUTLINE B.11 pattern, plus "verified", "check" and model names, was run on both files, outside `%` comments and the `\status`/`\src` arguments. The only hits are "In brief", ordinary uses of "check" ("a pairwise check", "checks $\bar t+1$ numerical inequalities") and citation keys. There is no process vocabulary and no model name.

## 7. Citations used

`hanni2026notes` (F6 only), `claudeSFI2026steeper` (by printed number), `tarski1951decision`, `forster1994how`, `rissanen1978modeling`, `wallace2005statistical`, `grunwald2007minimum`, `scholkopf2000new`, `li2008introduction` (the coding theorem, standard), `church1936note`, `durrett2019probability` (standard probability, no section numbers), `helly1923mengen`, `lewis1983new`, `lewis1994humean`, `woodward2014simplicity`, `cohen2009better`, `myrvold2003bayesian`, `muggleton1995inverse`, `srinivasan1994justification`, `kuhn1957copernican`, `duhem1954aim`, `schaffner1967approaches`.

All of them are in `bib/` (no fallback keys), and each is cited only for the content its comment records.

## 8. Items for other groups

* **Planning editor (CLAIMS §8 "place" column):** the rows moved to App G are listed in §4 item 2. The page overrun and the further cut options are in §5.
* **Kepler writer (`kepler.tex`, about line 173):** the sentence "a theory may be a sampler, the law with a Gaussian error model of stated $\sigma$ (\cref{prop:laws:randomised})" cites a proposition about *uniform* random completion inside interval bands. A Gaussian sampler is covered by dominance (`thm:basic:dominance`) and by `prop:laws:twopart`(a). The suggested citation is `\cref{thm:basic:dominance,prop:laws:twopart}`, or `prop:laws:errormodel` for completions shaped like the error.
* **Kepler writer:** `tab:laws:residuals` is now in Appendix G (G.4). The sentence in `sec:kepler:wrong` that cites it still reads correctly.
* **Phil writer:** `prop:laws:correction`, `prop:laws:copernicus` and `prop:laws:EP` are now stated in App G (§9 summarises them). The phrasing in `phil.tex` is consistent with them ("proves the honest old law on every window and refutes the exact one": the refutation needs $\eta_{\rm c}\mathbf Pa\ne0$, which holds in the toy's cases).
* **Front writer:**
  * The open questions `q:laws:JR` and `q:laws:domains` are in App G.
  * The headline sentence for the abstract and introduction is "under \SAIabbr's pricing an approximately true law is a law with a calibrated error model" (`prop:laws:errormodel`, main text).
  * The "34 of 39" figure must keep "in the coarse regime".
* **Planning editor (NOTATION):** no new global symbols. The local symbols are listed in §4 item 6. `\mathrm{Act}` replaces Lewis's $F$, because $F$ is a function machine.
