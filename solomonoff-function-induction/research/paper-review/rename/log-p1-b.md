# Log of group p1-b (Paper 1, `paper/`): renaming to Solomonoff operator induction

Files: `paper/sections/{hist,app-hist,examples,app-examples,ood,app-ood,comp,app-comp,nn,app-nn,steeper,app-verification}.tex`.

Binding: `RENAME.md` (this folder), then `REFRAME.md` and `DECISIONS.md`. Every statement about Solomonoff written here was checked against the text extractions of Solomonoff (2008) and (1999) named in RENAME.md §2.

## Result

* **Isolated builds (`./test-section.sh`), all OK, no overfull box above 10pt:**

  | pair | pages |
  |---|---|
  | hist + app-hist | 16 |
  | examples + app-examples | 12 |
  | ood + app-ood | 8 |
  | comp + app-comp | 9 |
  | nn + app-nn | 5 |
  | steeper | 1 |

  Every undefined reference in these builds is a label defined in another section (checked label by label).
* **Full build** (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, with the other groups' edits as they stood at the time): 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt, 92 pages.
* **Numbering:** `check_numbering.py aux-before/paper1-main.aux paper/main.aux` reports 314 labels before, 314 after, 0 differ. No environment, section or equation was added or deleted.
* **Greps on `pdftotext main.pdf`:** no `SFI`, `function induction`, `in the spirit`, `unverified` or `per-query mixture` remains in the pages of my sections. The 53 remaining `SFI` lines are all elsewhere:
  * the abstract;
  * the introduction;
  * related work, which also holds the one remaining "in the spirit of operator induction";
  * the discussion.
* **Length:** every section has the same length within a few lines.
  * `examples.tex` was measured against a build of the pre-edit file: in the isolated build its appendix still starts on page 6, one line lower.
  * `steeper.tex` gains about two lines and stays on one page.
* **Repository state:** a commit "Work in progress: SOI renaming edits, …" (1c6ff5eb, not made by this group) now contains these edits. Diff them against 9b5cd936. After that commit, one wording change was made to `app-verification.tex` (below).

## Conventions used

* **Plain "SFI" became "SOI"** wherever the statement is about $M_F$ (its loss $\LSFI$, its law, its posterior) and the version does not matter to the point being made. By the default convention of `setting.tex`, plain "SOI" means the one-tape version $M_F$, so these statements still concern $M_F$.
* **Where the version matters, it is named explicitly:**
  * shared versus private randomness: "the one-tape version";
  * fresh noise and repeated inputs: "the one-tape version", "Solomonoff's per-query solution";
  * $M_{\rm pq}$: "Solomonoff's per-query solution";
  * $M_H$: "the history-aware version".
* **The wording matches the setting group's:** "Solomonoff's per-query solution $\Mpq$", "the one-tape version $\MF$". Paper 2's "steeper SFI" is "Solomonoff's per-query solution with a steeper prior", as in `log-p2.md`.
* **Not changed:** `%` comments and `\src{…}` notes, which are not printed. Section and environment labels, which are never renamed.

## Changes by file

**hist.tex**
* Opening paragraph: "SOI sees the past only as a set …".
  * "show in what sense SFI whose hypotheses see the list of previous inputs is as good as SI" → "show in what sense the history-aware version of SOI, whose hypotheses see the list of previous inputs, is as good as SI".
* `lem:hist:chrono` title: "SOI is a chronological semimeasure".
* §6.2: "beats SOI without bound"; "\SFIhist{} pays as much as SOI".
* §6.3:
  * "beats SOI in expected log loss";
  * "Formulation C is the natural one for the one-tape version of SOI: a function machine can simulate …";
  * "(The one-tape version itself pays at most $1+c$ bits here.)".
* §6.4:
  * Subsection title: "SOI with access to the previous inputs" (`sec:hist:sfihist`).
  * "Between the versions of SOI considered so far and SI lies a natural intermediate, the history-aware version: …".
  * `def:hist:sfihist`: "\SFIhist{}, the history-aware version of SOI, is the one-tape version over $X_H$". This is naming only; the definition is unchanged.
  * "\SFIcount{} (SOI on time-stamped inputs)"; "SOI $\preceq$ \SFIcount{} …".
  * "Solomonoff's per-query solution $\Mpq$ (`rem:versions:operator`) ignores the history: …" (was "The per-query mixture").
  * "as for SOI (`thm:versions:nocoding`)".
* §6.5: "SOI's loss is at most $\LMjoint+c$".
* `rem:hist:H4verdict`: "With the list of previous inputs SOI becomes …".
* §6.6:
  * Subsection title: "What SOI can and cannot exploit".
  * "while SOI, whose hypotheses never see the first input, …".
  * "shared randomness lets a label of the one-tape version correlate with a guess …".
* `q:hist:open`(iii): "normalised SOI".

**app-hist.tex**
* `prop:hist:normchain` title: "Normalised SOI on both examples".
* `prop:hist:variants`: "\SFIcount{} is SOI on stamped inputs"; "(c) SOI $\preceq$ \SFIcount{} …".
* The sentence before `prop:hist:operator`:
  * old: "$\Mpq$ is a per-query mixture in the spirit of Solomonoff's operator induction";
  * new: "$\Mpq$ is Solomonoff's per-query solution, his eq. (10) for the operator-induction problem (`rem:versions:operator`)".
* `prop:hist:operator`:
  * title: "Solomonoff's per-query solution ignores the history";
  * `\status{proved, given the unverified description}` → `\status{proved}` (RENAME §2, consequence 4). The statement and the proof are unchanged.
* Subsection title `app:hist:exploit`: "What SOI can and cannot exploit".
* After `thm:hist:gf`: "(the one-tape version restricted to the field is a random partial function)".

**examples.tex**
* SFI → SOI in:
  * the opening (twice);
  * after `thm:ex:cycle` and `thm:ex:ksteps`;
  * the titles of `prop:ex:normalised` and `q:ex:normalised` ("normalised SOI");
  * the sentence before `prop:ex:cycset`;
  * the separation summary;
  * the sentence before `lem:ex:shape`;
  * `rem:ex:email`;
  * `ex:ex:threshold`, `ex:ex:sorting`, and the sentence after `ex:ex:poly`.
* **Added to the separation summary of §7.2**, after "while SI and \SFIhist{} pay $O(1)$, uniformly in $d$". This is the addition the task asked for, in one place.
  > The cost does not depend on the version: \cref{prop:ex:orderfree}(a) covers Solomonoff's per-query solution, which on distinct inputs equals $\Mprod$, a mixture of laws of random partial functions with private randomness (\cref{rem:versions:operator}), and on the full cycle $K(\dom f)\le K(d)+O(1)$, so the versions of \cref{sec:versions} agree up to $O(\log d)$ bits (\cref{thm:versions:chain}). It is the cost of order-free prediction: only a predictor whose loss depends on the order of the data can avoid it (\cref{prop:ex:orderfree}(b)), as SI on the interleaved sequence and \SFIhist{} do and \SFIset{} does not (\cref{prop:ex:cycset}).
* **Added after `prop:ex:law`** (Eisenstat): "the lower bound of \cref{prop:ex:law}(b) also binds Solomonoff's per-query solution (the weak $\Mprod$ on these distinct inputs)".
* **Last paragraph:**
  * old: "random-function SFI fails as soon as an input can repeat with another label (`rem:ex:fresh`)";
  * new: "the one-tape version, a random function, fails as soon as an input can repeat with another label, while Solomonoff's per-query solution allows such noise (`rem:ex:fresh`)".

**app-examples.tex**
* Opening: "illustrations, not SOI or SI".
* `rem:ex:fresh`:
  * "the one-tape version has $\Ex\LSFI=\infty$ in both conventions";
  * "time stamps or Solomonoff's per-query solution repair this" (was "the per-query mixture").

**ood.tex**
* SFI → SOI in ten sentences: the opening (twice), after `prop:ood:hanni`, after `thm:ood:cumulative`, before and after `prop:ood:converse`, `rem:ood:answer`(i), §8.4 (three times).
* `prop:ood:machine`(b): "yields an SFI $M_F'$" → "yields a one-tape version $M_F'$". This is naming inside the statement; the mathematics is unchanged.

**app-ood.tex.** No printed occurrence; unchanged.

**comp.tex**
* "SOI is not computable".
* Subsection and theorem titles: "Time-bounded SOI" (`sec:comp:time`, `thm:comp:timebounded`); "Circuit SOI" (`sec:comp:circuits`).
* After `prop:comp:round`:
  * old: "the time-bounded analogue of SFI on time-stamped inputs (…), and a mixture of the per-query kind (…)";
  * new: "the time-bounded analogue of the one-tape version on time-stamped inputs (`thm:learn:batch`(b)) and, like Solomonoff's per-query solution, a mixture of products over queries (`rem:versions:operator`)".

**app-comp.tex**
* `rem:comp:distinct`: "as under the one-tape version of SOI (`prop:learn:freshnoise`)".
* `rem:comp:uniformties`: "it does not show that steeper SFI fails on this ordering" → "… that Solomonoff's per-query solution with a steeper prior fails on this ordering".

**nn.tex**
* Section title: "Neural-network Bayes and circuit SOI".
* "a circuit version of SOI".
* "So NN Bayes is function induction with the prior $P_A$" → "So NN Bayes is Bayesian prediction with the prior $P_A$ on functions" ("function induction" leaves the printed text).
* "circuit SOI, not program SOI"; "behaves like circuit SOI".
* `cor:nn:separation`: title "Kernels versus SOI on sparse parities"; "SOI ($\nu\in\{W,\MF\}$)"; "while SOI needs".

**app-nn.tex.** "the SOI side needs".

**steeper.tex** (RENAME §4, item 8)
* **Added after the proposal and its footnote:** "These hypotheses form the class of Solomonoff's per-query solution $\Mpq$ (`rem:versions:operator`), so the companion paper studies that solution with the prior $2^{-\lambda\ell}$ on programs of length $\ell$, and the $\lambda$-MAP over the same class."
* "Solomonoff induction and SFI with shared randomness" → "Solomonoff induction and the one-tape version of SOI, whose randomness is shared by all inputs".
* "the gap between $\Mprod$ and $\MF$" → "the gap between $\Mprod$, which equals the per-query solution on distinct inputs, and $\MF$".

**app-verification.tex** (switched off; RENAME §5: the operator-induction sentences only, otherwise left as it was)
* Corrections table, row "Operator induction $=\Mprod$":
  * old: "Per secondary sources it is the per-query mixture …";
  * new: "Operator induction is Solomonoff's problem; his second solution, eq. (10), is the per-query mixture $\Mpq$, equal to $\Mprod$ on distinct inputs (primary source read; M3; C1)".
* Literature paragraph:
  * old: "… for every work cited for content, in particular: operator induction \citep{solomonoff2008three}, through \citet{ozkural2015ultimate,ozkural2017ultimate}; …";
  * new: "… for every work cited for content except the two papers of Solomonoff \citep{solomonoff1999two,solomonoff2008three}, which the author supplied later and which were read in full; in particular: …".
  * This also removes the dropped Özkural keys from the file.
* The other SFI wordings in this appendix are left, as RENAME §5 says.

## Version decisions (which version a statement is about)

1. **hist.tex opening, "SOI sees the past only as a set".**
   * It cites `prop:setting:order` and uses $\LSFI$, the loss of $M_F$, so it uses plain SOI by the default convention.
   * I did not write "in every version". The history-aware version is itself a version of SOI and sees the list. The weak mixture $\Mw$'s hypotheses may depend on the other pairs.
2. **`lem:hist:chrono` title.** The statement is about $\rho_F=\MF$, so plain SOI by the default.
3. **"beats SOI without bound / in expected log loss", "pays as much as SOI", "SOI's loss is at most $\LMjoint+c$", `rem:hist:H4verdict`, "What SOI can and cannot exploit", "while SOI, whose hypotheses never see the first input".** All are statements about $\LSFI$, that is $M_F$ (`thm:hist:chain`, `thm:hist:skipped`, `cor:hist:initial`, `cor:hist:joint`, `thm:hist:sandwich`, `thm:hist:gf`), so plain SOI by the default. Where the order-free lower bounds also bind other versions, `prop:hist:orderfree` and `prop:hist:operator` say so; they are unchanged.
4. **"Formulation C is the natural one for …"** The reason given is that a function machine with one shared tape can simulate a reveal law. The next proposition (`prop:hist:sketchfails`) shows that private randomness per input fails. Shared versus private randomness is the point, so: "the one-tape version of SOI".
5. **"(SFI itself pays at most $1+c$ bits here.)"** This contrasts the one-tape law with the private-randomness simulator, so: "the one-tape version".
6. **"shared randomness lets a label of SFI correlate …"** The sentence is about shared randomness, so: "the one-tape version".
7. **`def:hist:sfihist`.** $\MH$ is the law of the universal function machine over $X_H$, which is the one-tape construction over $X_H$, so: "the one-tape version over $X_H$". It is named "the history-aware version of SOI", the RENAME §3 name.
8. **\SFIcount{} "(SOI on time-stamped inputs)" and the chain "SOI $\preceq$ \SFIcount{} $\preceq$ …".** These are about $M_F$ and $M_F$ on stamped inputs (proof of `prop:hist:variants`(b),(c)), so plain SOI by the default. Inputs are distinct there, so repeated inputs are not at issue.
9. **"as for SOI (`thm:versions:nocoding`)".** The comparison of the Kolmogorov version and the program mixture is a comparison of versions of SOI, so the family name is apt.
10. **`app-hist` after `thm:hist:gf`.** The argument needs $M_F$ to be the law of a random partial function, which the weak $\Mw$ need not be, so: "the one-tape version".
11. **examples.tex, plain SOI throughout** (the cycle, the $k$ steps, Eisenstat, the positive examples). All are statements about $\LSFI$ or $\MFbar$, that is $M_F$, so plain SOI by the default.
12. **The new sentences in examples.tex** state where the version does not matter.
    * Prop 7.5(a) covers every law of a random partial function. On the distinct inputs of $D_k$ ($k<N$), Solomonoff's per-query solution equals $\Mprod(D_k)=\sum_i\mm(i)\prod P_i$, a sub-probability mixture of product laws (laws of random partial functions with independent values). Such a mixture is at most a law of a random partial function, so (a) applies.
    * On the full cycle, $\dom f=\{0,1\}^d$ is computable from $d$, so `thm:versions:chain` gives agreement of $\KF,W,\Mprod,\MF,\Mw$ up to $K(d)+O(1)=O(\log d)$ bits. The per-query solution equals $\Mprod$ there: the inputs $x_1,\dots,x_N$ are distinct, since $x_N=0^d$ and $x_0$ is not an input.
    * "Only a predictor whose loss depends on the order of the data can avoid it" is the contrapositive of `prop:ex:orderfree`(b) for the full cycle. Every weak $\nu$ has $\Ex[-\log\nu(f)]\ge\log((N-1)!)$, and order-independent predictors are weak semimeasures (`prop:setting:predictor`).
    * \SFIset{} is named as an order-aware predictor that still pays (`prop:ex:cycset`), so the sentence does not read as "every order-aware predictor avoids it".
    * Eisenstat: the inputs are distinct, so the per-query solution equals $\Mprod$, which is weak (stated in `prop:hist:operator`), and `prop:ex:law`(b) applies to it.
    * I did not claim the matching upper bound for the per-query solution, although the threshold law is a product law. It is not stated in the paper.
13. **Last paragraph of examples.tex and `rem:ex:fresh`.** These concern fresh noise on repeated inputs, so the versions are named explicitly:
    * the one-tape version fails (`prop:learn:freshnoise`, stated for $M_F$);
    * Solomonoff's per-query solution allows the noise (`prop:learn:perquery`; RENAME §2: a repeated question gets an independent factor).
14. **ood.tex.** The conventions paragraph fixes $\nu\in\{W,\MF\}$, and every statement with "SOI" is about $M_F$ (or $W$ where the conventions say so). So plain SOI is used. `prop:ood:machine`(b) constructs a one-tape law $M_F'$ for another universal machine, so: "a one-tape version $M_F'$".
15. **comp.tex.**
    * "SOI is not computable": `prop:setting:computability`(b) is about $M_F$, so plain SOI by the default.
    * "Time-bounded SOI" and "Circuit SOI" are titles naming computable relatives of the family, so the family name is apt.
    * After `prop:comp:round`: `thm:learn:batch`(b) runs $M_F$ on stamped inputs, and repeated inputs are the subject of the paragraph, so: "the one-tape version on time-stamped inputs". $\Mrd=\sum_iw_i\prod_jq_i^{(j)}$ has the form of Solomonoff's eq. (10), a mixture of products over queries, so it is "like Solomonoff's per-query solution". It is not called equal to it.
16. **app-comp.tex.**
    * `rem:comp:distinct`: repeated inputs, and `prop:learn:freshnoise` is about $M_F$, so: "the one-tape version of SOI".
    * "steeper SFI" is Paper 2's object, so "Solomonoff's per-query solution with a steeper prior", as in `log-p2.md` decision 8. The sentence only says what the ladder does not show.
17. **nn.tex.**
    * "circuit SOI" and "program SOI" name the circuit and program analogues of the family, as a section title and in prose.
    * `cor:nn:separation` already names the versions ($\nu\in\{W,\MF\}$), so plain SOI with that parenthesis.
18. **steeper.tex.**
    * "SFI with shared randomness" is the class $\mathcal H_F$ with $U=M_F$, so: "the one-tape version of SOI, whose randomness is shared by all inputs". This is explicit because absorption is where shared versus private randomness matters (RENAME §3).
    * The private-randomness class is the class of Solomonoff's per-query solution (RENAME §4, item 8).
    * $\Mprod$ is named as the per-query solution on distinct inputs; the price of private randomness is measured on data sets.

## Statements about Solomonoff (checked against the sources)

* **"$\Mpq$ is Solomonoff's per-query solution, his eq. (10) for the operator-induction problem"** (app-hist).
  * 2008 §4: "In the Operator Induction problem … We will give two solutions."
  * §4.2 "Second Solution … to the operator problem", eq. (10): $\sum_ja^j_0\prod_{i=1}^{n+1}O^j(A_i\mid Q_i)$.
  * The identification with $\Mpq$ is the one of RENAME §2 and `rem:versions:operator`.
* **"These hypotheses [private randomness at each input] form the class of Solomonoff's per-query solution"** (steeper.tex).
  * In eq. (10) each hypothesis $O^j$ is a conditional distribution applied independently at each question, through the product over $i$.
  * $O^j$ ranges over conditional distributions computed by partial recursive functions ("we will instead sum over all partial recursive functions").
  * This is Paper 2's $\mathcal H_\times$ (log-p2).
* **"like Solomonoff's per-query solution, a mixture of products over queries"** (comp.tex). This is the form of eq. (10)/(11): a weighted sum, over $j$, of products over the pairs.
* **"Solomonoff's per-query solution allows such noise"** (examples.tex). In eq. (10) a repeated question contributes its own factor $O^j(A_i\mid Q_i)$, so two different answers to one question both get positive probability. The proof of the regret statement is `prop:learn:perquery`, ours.
* **app-verification: "Operator induction is Solomonoff's problem; his second solution, eq. (10), …"** See 2008 §4 and §4.2. "The two papers of Solomonoff … read in full": RENAME §2.
* **Nothing here attributes to Solomonoff anything about $M_F$, $W$, $\KF$, $\MH$ or the comparisons.** The equality $\Mpq=\Mprod$ on distinct inputs is cited to our `rem:versions:operator` / `prop:learn:perquery`, not to him.

## For other groups

1. **p1-front (abstract, intro, discussion):**
   * The headline of RENAME §4 item 2 now has a home in the body. Cite `prop:ex:orderfree`(a) and the new sentences in the separation summary of §7.2 (they say the per-query solution is covered, the versions agree on the full cycle up to $O(\log d)$ bits, and only order-dependent predictors avoid the cost). Cite `prop:ex:law`(b) for Eisenstat's example.
   * **New printed titles:**
     * §6.4 `sec:hist:sfihist` "SOI with access to the previous inputs";
     * §6.6 `sec:hist:exploit` "What SOI can and cannot exploit";
     * §9.1 `sec:comp:time` "Time-bounded SOI";
     * §9.2 `sec:comp:circuits` "Circuit SOI";
     * §10 `sec:nn` "Neural-network Bayes and circuit SOI";
     * `cor:nn:separation` "Kernels versus SOI on sparse parities".
   * The intro's "two-sided bridge between NN Bayes and circuit SFI" should become "circuit SOI". Its reader's guide should use the names above.
   * `q:hist:open`(iii) now says "normalised SOI"; the open-problems list that cites it (Question 6.23) still says SFI.
2. **Related work (whichever group owns `related.tex`):** one "in the spirit of operator induction" remains (PDF text: "mixture $M_{\rm pq}$ (Section 4) is a mixture in the spirit of operator induction that gives each query …").
3. **Planning files (the group that updates `CLAIMS.md`, `OUTLINE.md`, `NOTATION.md`):** names in rows for my sections.
   * **CLAIMS.md:**
     * `prop:hist:operator` (row text "Operator induction ($\Mpq$) ignores the history"; status "proved, given the unverified description" → now `proved`; title now "Solomonoff's per-query solution ignores the history");
     * `def:hist:sfihist` ("SFI over the input set $X_H$" → "the one-tape version over $X_H$; the history-aware version of SOI");
     * `prop:hist:normchain`, `prop:ex:normalised`, `q:ex:normalised` ("Normalised SOI");
     * `lem:hist:chrono` (title "SOI is a chronological semimeasure");
     * `prop:hist:variants`, `prop:ex:cycset`, `rem:hist:exploit`, `q:hist:open`, `rem:ex:email`, `rem:ood:lopsided`;
     * `rem:nn:bridge`, `cor:nn:separation`, `rem:nn:rigorous`, `rem:nn:slides`.
   * **OUTLINE.md:** §6–§9 headings and purposes ("Time-bounded SFI", "circuit SFI", "Neural-network Bayes and circuit SFI", "What SFI can and cannot exploit").
4. **p2 (Paper 2):**
   * Paper 1's `steeper.tex` now says what Paper 2 says:
     * the private-randomness class is the class of Solomonoff's per-query solution;
     * Paper 2 studies that solution with the prior $2^{-\lambda\ell}$ and the $\lambda$-MAP;
     * absorption holds in SI, in the one-tape version of SOI and in the history-aware class.
   * The statements Paper 2 cites from my sections keep their objects and numbers.
5. **Everyone:** the WIP commit 1c6ff5eb (not ours) holds most edits of this pass. The pre-edit state of my files is at 9b5cd936, and a copy is in `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/p1b/backup/`.
