# Section writer log: group "logic" (§5 `sections/logic.tex`, Appendix C `sections/app-logic.tex`)

*Done (2026-10-17). Both files are complete; the isolated build passes with 0 errors.*

## 1. Restart check
At the start of this run both `sections/logic.tex` and `sections/app-logic.tex` were the planning editor's stubs (305 and 308 bytes), and there was no log, so nothing from an earlier run had to be recovered. The appendix was written first, then the main text; both were saved after each subsection.

## 2. What was written
* **§5 `logic.tex`** (label `sec:logic`), six subsections: `sec:logic:lottery`, `sec:logic:arith`, `sec:logic:pi1`, `sec:logic:goedel`, `sec:logic:omega`, `sec:logic:thn`. An opening paragraph sets the arithmetic conventions ($\Pi_1^*$, "$B$ true", $\Sigma_1$-soundness, the class $\mathcal U$ of $\Sigma_1$-unsound theories, $P_D(\mathcal C):=\UA(\mathcal C;D)/\MA(D)$) and points to App. C.1 for the standard facts.
* **Appendix C `app-logic.tex`** (label `app:logic`), seven subsections: `app:logic:conv` (the facts used from §3, the arithmetic facts ($\Sigma_1$C), ($\Pi_1$T), (O), (G2), (Diag), (Uniq), cited as standard with `smorynski1977incompleteness`, `boolos2007computability`, and the convention discussion of logic §1.3), `app:logic:lottery`, `app:logic:arith`, `app:logic:pi1`, `app:logic:goedel`, `app:logic:omega`, `app:logic:thn`. Every proof is the record's proof, complete, restated in the paper's notation. No proof sketch is used. The record's §6.2 upper bound, which is a proof sketch, is omitted, as CLAIMS §4 allows.
* **Every CLAIMS §4 row is present** with its label, `\status{}` and `\src{}`: 44 rows, 21 environments in §5 and 23 in App. C. A script compared the defined labels with CLAIMS §4: none is missing, and the only extra labels are the section and subsection labels. Every `logic` label that another section `\cref`s exists.
* **Statuses rendered in prose.**
  * "PG" rows name what they are given in the status argument and in the text: (G2), (Uniq), `lem:logic:flexible`, Dedekind's categoricity theorem, and the Martin-Löf randomness of $\Omega_V$.
  * Every computed number is outside the statements, with "a computation (code in the accompanying repository)":
    * the product $0.288788\ldots$;
    * $\xi\ge0.0823$, proved by an exact certificate;
    * the certificate constants;
    * $n^{0.0823}\approx3.1$;
    * the descriptions of the finite checks.
  * `rem:logic:closures` (c) is rendered as "known", citing Theorem 3.9(c1) and (d1) of `claude2026axiominduction` exactly. Its Proposition 3.12(c) is not cited.
* **"How to state" lines followed.**
  * `thm:logic:lottery`: the product is outside the statement, and (c) is in the semimeasure convention (stated in the §5 conventions and in C.1).
  * `rem:logic:lotteryremarks` says "neither r.e. nor co-r.e.".
  * `prop:logic:arity`: the threshold is "exact for the argument".
  * `cor:logic:Q1` follows fc item 5: "We do not claim that these are the only cases".
  * `cor:logic:versions`: "separates the versions of consistent SOI; plain SOI is not separated".
  * `thm:logic:arith` and `cor:logic:false` are stated as a possibility result with adversarial ($\Delta_2$ diagonal) data, with "we draw no realist conclusion".
  * `thm:logic:threshold`: "up to a constant factor, one random true theory".
  * `cor:logic:chaitin` names the semimeasure and three-valued conventions in the statement.
  * `prop:logic:normalised`: "the price of deciding the sentence, not of predicting its truth value".
  * `prop:logic:boundary`: "the boundary of the coding theorem is exact".
  * `prop:logic:con` states the truth hypothesis, and the counterexample is given in one sentence.
  * `prop:logic:gaifman` is called "the provability analogue of Proposition B.10" (the printed number was read from `../axiom-induction/paper/main.aux`).
  * `thm:logic:goedelomega` states its hypotheses (fc item 11).
  * `rem:logic:Wbound`: fc item 18.
  * `thm:logic:thn` uses the exponent $\xi$, with the certificate sentence outside the statement.
* **Novelty** (bib-report §4.2), stated "to our knowledge":
  * the lottery: the mass-problem relatives and the probabilistic-inductive-inference sentence (`pitt1989probabilistic`, `ambainis1999probabilistic`), kept qualitative;
  * the modified Demski prior samples random axiom systems, so these are not claimed as new, and the prior also gives the lottery stream positive probability;
  * the $\Pi_1$ threshold results: "we have not found them stated, but cannot exclude that they are known", with the threshold device credited as close to `deleeuw1956computability` and `bienvenu2014axiomatic`, `shen2011random`;
  * `lem:logic:flexible`: no novelty is claimed.
* **Credit footnote F5** is at the sentence before `prop:logic:oldevidence`, worded as OUTLINE §C gives it. The text says nothing else about Hänni's notes.
* **Citations used.** All are "citable" in bib-report §5, for the content recorded there; merge_bib reports 0 keys supplied only by the fallback:
  * logic and arithmetic: `smorynski1977incompleteness`, `boolos2007computability`, `chaitin1974information`, `chaitin1975theory`, `raatikainen1998interpreting`, `kripke1962flexible`, `mostowski1961generalization`, `woodin2011potential`, `blanck2017marginalia`, `hamkins2018modal`;
  * randomness and computability: `deleeuw1956computability`, `kyburg1961probability`, `kucera1985measure`, `bienvenu2016deep`, `bienvenu2017diagonally`;
  * inductive inference and logical uncertainty: `pitt1989probabilistic`, `ambainis1999probabilistic`, `garrabrant2015modification`, `garrabrant2016inductive`, `garrabrant2016logical`;
  * random axioms: `bienvenu2014axiomatic`, `shen2011random`;
  * probabilities on sentences: `gaifman1964concerning`, `hutter2013probabilities`;
  * old evidence: `hacking1967slightly`, `garber1983old`;
  * Kreisel's conjecture: `parikh1973some`, `baaz1993kreisel`, `hrubes2007theories`, `hrubes2009kreisel`, `santos2021variants`;
  * generic decidability: `myasnikov2008generic`, `hamkins2006halting`, `calude2005complexity`;
  * internal: `claude2026axiominduction`, `hanni2026notes`.

  Kučera's theorem is cited "see `bienvenu2017diagonally`" (secondary), and Bienvenu–Porter only qualitatively (tt-negligible / deep), with no theorem numbers. Calude–Jürgensen is cited at abstract level.

## 3. Page counts (isolated build `./test-section.sh logic app-logic`)
`OK: pages 28; 0 undefined citations; 39 undefined refs (cross-section refs expected); 0 overfull hboxes >10pt`; 0 LaTeX errors. All 24 distinct undefined labels are defined in other writers' files (setting, basic, app-basic, soi, laws).
* **Main text §5: about 6.6 pages** (pages 1–6 full, and about 62% of page 7). **Budget: 4.5 pages. Overrun: about 2.1 pages.**
* **Appendix C: about 18.4 pages.**
* The bibliography of the isolated build takes about 2.5 pages; it is not part of the section.

**Why the overrun.** The first complete draft had about 10 pages of main text. To approach the budget, eight statements moved to App. C (§4 below), and every paragraph was compressed. The remaining 21 main-text items are the CLAIMS "main" rows that the outline names for §5, each with its full statement and a 1–3 sentence proof idea or reading.

**Options for the planning editor if §5 must shrink further,** with the approximate saving of each:
1. `rem:logic:closures` to App. C, with a one-sentence summary: 0.2 p.
2. `thm:logic:thn` and `cor:logic:undecided` to App. C, with a two-sentence summary giving the bound and $\xi\ge0.0823$: 0.4 p.
3. `prop:logic:shape` to App. C, with its reading kept in prose: 0.25 p.
4. `cor:logic:chaitin` to App. C, keeping `prop:logic:normalised` and a sentence: 0.3 p.
5. The "Relatives" paragraph to §12, since its full version is already in App. C.2: 0.15 p.

## 4. Deviations from OUTLINE / CLAIMS, with reasons
1. **Eight rows moved from the main text to App. C** for the page budget (rule B.3). Each has its full statement and proof in App. C and a faithful one-sentence summary with `\cref` in §5:
   * `rem:logic:lotteryremarks` ("main (short) or app");
   * `prop:logic:true`, `prop:logic:core` (both summarised inside `cor:logic:Q1`);
   * `cor:logic:versions` (summary: one-tape consistent SOI bounded, coin-free consistent SOI unbounded, plain coin-free SOI on sentences bounded through an inconsistent labeller);
   * `cor:logic:onetrue`;
   * `prop:logic:boundary` (summary with its full content: two true data, each $\Q$-equivalent to a Boolean combination of $\Sigma_1$ sentences, $\KA>\log d-2$, $\LA\le2+c$);
   * `prop:logic:con` (summary with the truth hypothesis and the counterexample);
   * `prop:logic:gaifman` (summary: the gap is the mass of the consistent random theories that prove every instance but not the universal, at least $2^{-K(I)-c}$, and zero iff $I\vdash\forall x\varphi$).

   **The ledger's "place" column should be updated** for these eight rows.
2. **`fig:logic:lottery` (optional) was not drawn**, to save space.
3. **The ancestry paragraph** is a short "Relatives" paragraph at the end of §5.1. The full version is in App. C.2 ("Relatives of the lottery"): bounded DNC functions and Bienvenu–Porter's dichotomy at the verified level, and the modified Demski prior on the lottery stream.
4. **CLAIMS row `prop:logic:oldevidence` says "credit footnote F7".** The outline's footnote table makes F5 the logic footnote, and F7 the limits one. F5 was used; the ledger row looks like a typo.
5. **Three precisions of wording that are not changes of content.**
   * `prop:logic:gaifman`: the record's "every posterior $\Bel_D$ with $D$ compatible with $I$" is printed as "with $D$ proved by $I$". That is the reading under which the record's proof (divide by $\MA(D)$; $I$ itself lies in the event) works.
   * `cor:logic:false`(iii): the record's "$J_k\ne t_k$" is printed as "its winner differs from the true winner of lottery $k$". Here $t_k$ is the unique true ticket, by `lem:logic:flexible`(ii).
   * `cor:logic:rate`(a): the constant in "$\le\frac23f(n)+c$" is written $c_f$, because it depends on $f$ through the computation of $\lfloor2^{f/3}\rfloor$.
6. **Partial answers to `q:logic:soundness`.** The record's §4.4 list, including the general companion bound $\UA(\mathcal U;D)\ge2^{-K(G)-c}\Unif(\{\dots\}\cap\mathcal K^G)$ with its proof, is printed as an unnumbered paragraph in App. C.5 ("What is known about Question …"). It has no ledger row. The main text claims "yes" only on $\Pi_1$ data, with a bounded coding gap, and on the $\Win$-lottery stream, which is what the record proves.
7. **`q:logic:computablefast`** contains both parts of the ledger row: the computably-fast question, and Q1 for co-r.e. streams in general.
8. **Not cited in §5:** `prop:basic:incomplete` and `prop:soi:independent`, which OUTLINE lists under "Cites" for §5. The text did not need them, and adding them cost space.

## 5. Notation
Only NOTATION macros and local symbols are used: `\Win`, `\Lot`, `\Glot`, `\Tick`, `\Gthr`, `\Kgt`, `\Bit`, `\re`, `\num`, `\UA`, `\Exts`, and so on. No `\newcommand` appears in either file.

**Renames from the record**, each listed at the top of `app-logic.tex`:

| record | here | reason |
|---|---|---|
| $\Phi$ | $\Upsilon$ | NOTATION §11 |
| $\Theta$ in (Diag) | $\vartheta$ | NOTATION §11 |
| $\delta$ | $\xi$ | NOTATION §11 |
| $\Psi$ | $\Lambda$ | $\Psi$ is local to App. D |
| $t_k$ | $j^\circ_k$ | $t_w$ is global |
| $\mathcal A,\mathcal N$ | $\sigma_\Upsilon,\pi_\Upsilon$ | $\mathcal A$ is the EP module |
| $\beta_m$ | $\mathrm{Bd}_m$ | $\beta_e$ is global |
| Kleene's $\mathrm T$ | $\mathrm{Comp}$ | — |
| $H_p$ | $\mathrm{Halt}_p$ | — |
| $\mathrm{Cons}_p$ | $\mathrm{Ok}_p$ | $\mathrm{Cons}$ is global |
| $\mathrm{Pr}^b_p$ | $\mathrm{Prv}^b_p$ | — |
| $\gamma$ (growth constant) | $\kappa$ | $\gamma$ is global |
| $\gamma_T$ | $\chi_T$ | $\gamma$ is global |
| $\mathcal C^G$ | $\mathcal K^G$ | $\mathcal C$ is a class of theories |
| $X_p$ | $A^{(p)}$ | $X$ is the target set |
| $S$ (sentence class) | $Z$ | $S$ is the successor |
| $\Pr_w$ | $\Unif(\cdot\mid[w])$ | — |
| $n$ (string length, Prop 3.11) | $d$ | — |

## 6. Greps (OUTLINE B.11)
* **Process vocabulary.** The process-vocabulary grep, run on both files outside `%` comments and `\src{}`/`\status{}` arguments, returns no hits.
* **Other greps.** "Hänni" appears only in the F5 footnote. No script names, check ids, model names, "AI-paper", "TF" or "SD" appear. Every theorem-like environment carries both `\status{}` and `\src{}`.

## 7. Items for other groups
* **Planning editor:**
  * the overrun and the cut options (§3);
  * the eight moved rows (§4.1);
  * the F5/F7 typo in the CLAIMS row `prop:logic:oldevidence` (§4.4);
  * the unnumbered partial-answers paragraph (§4.6).
* **soi writer.** `soi.tex` and `app-soi.tex` cite `cor:logic:versions`, `cor:logic:coding`, `lem:logic:density` and `thm:logic:lottery`, all by `\cref`, and all exist. `cor:logic:versions` is now in App. C; since every reference is a `\cref`, nothing needs to change.
* **front writer (§12 Related work).**
  * The full lottery ancestry is in App. C.2, and the $\Pi_1$ novelty hedge is in §5.3.
  * The Gaifman sentence for §12 can cite `prop:logic:gaifman` (now in App. C) and `prop:logic:omega` (§5).
  * Open questions of this group for the Discussion list: `q:logic:computablefast` ★ and `q:logic:soundness` ★ (both §5); `q:logic:thn` (§5); `q:logic:soundtrue`, `q:logic:codingO1` and `q:logic:kreisel` (App. C).
* **phil writer.** `cor:logic:false` (§5.2) carries "we draw no realist conclusion about the theories an inducer favours". `prop:logic:omega` is in §5, as `phil.tex` expects.
* **No full build was run.** OUTLINE B.7 allows it only when the writer is told to run it.
