# Rename log, group p1-front (Paper 1: abstract, introduction, related work, discussion, OUTLINE.md, CLAIMS.md)

Binding sources: `rename/RENAME.md`, then `REFRAME.md` and `DECISIONS.md` where RENAME does not override them. Every statement about Solomonoff written here was checked against the text extractions of Solomonoff (2008) and (1999) named in RENAME §2. The checks are listed in §4.

Mathematics is unchanged. No label was renamed. No numbered environment, section or equation was added or deleted.

## 0. Checks

* **Full build** (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, last run after the final edit):
  * 0 LaTeX errors;
  * 0 undefined references and 0 undefined citations;
  * 0 multiply defined labels;
  * 0 overfull boxes above 10pt;
  * 93 pages (92 before this group's edits).
* **Numbering:** `check_numbering.py aux-before/paper1-main.aux paper/main.aux` reports 314 labels before, 314 after, 0 differ.
* **Greps on `pdftotext main.pdf`:**
  * `SFI`: 0 hits.
  * `function induction`: 2 hits, both allowed by RENAME §3: the credit footnote in `setting.tex` and the reference-list entry of `hanni2026notes`.
  * `in this spirit` / `in the spirit`: 0 hits.
  * `unverified`: 0 hits.
  * DECISIONS §A5 process-vocabulary grep: only the allowed hit ("independent AI referees" in the title footnote) and one hit inside a formula.
  * `wyeth`: 0 hits.
* **Isolated builds** (`./test-section.sh`): `abstract`, `intro`, `related` and `discussion` all compile. They have 0 undefined citations and no overfull box above 10pt. Every undefined reference is a cross-section label. These sections have no appendices.
* **Abstract:** 1914 characters including the line end (limit 1920; it was 1901).
* **Length,** measured as non-empty text lines of each section in the full build (`pdftotext -layout`), before → after:

  | section | before | after | change |
  |---|---|---|---|
  | abstract | 22 | 22 | 0 |
  | introduction | 146 | 164 | +18 |
  | related work | 72 | 83 | +11 |
  | discussion (to the acknowledgements) | 94 | 96 | +2 |

  * The growth in the introduction and in related work is the content that RENAME §4 items 1–3 require:
    * Solomonoff's problem and solutions;
    * the list of versions;
    * the paragraph on how much the version matters;
    * related work: his two solutions, his eq. (12) and the 1999 term;
    * the new items of the novelty paragraph.
  * I compressed the wording around these additions three times without dropping any claim; the figures above are the result.
  * Section 3 now starts on p. 8 instead of p. 7.
  * A possible further cut, which I did not make because DECISIONS §F2 prescribes it, is in the paragraph "Relation to Solomonoff induction". Its Hutter sentence ("Chronological semimeasures, with actions and percepts … we define \SFIhist{} directly …") nearly repeats the "Chronological semimeasures" paragraph of related work. Dropping it saves 2 lines.
* **Repository state:** commit e2088079 ("Work in progress: SOI renaming edits and axiom-induction research records"), not made by this group, contains a mid-way state of some of these files. It is followed by uncommitted later edits. The full change set of this group is `git diff 1c6ff5eb -- paper/sections/{abstract,intro,related,discussion}.tex paper/OUTLINE.md paper/CLAIMS.md`. This group ran no git command that changes repository state.

## 1. Changes by file

### `paper/sections/abstract.tex` (RENAME §4, Paper 1 item 1)
* **New opening sentences:**
  * Solomonoff posed operator induction, the prediction of the answer to a new question from an unordered set of question–answer pairs (supervised learning), and gave universal-prior solutions with a convergence theorem.
  * "We study several versions of Solomonoff operator induction (SOI) and how they compare and behave."
* **The one-tape version** is introduced as "our default" in one sentence: a universal machine reads the same fair coin flips on each input.
* **All results of the old abstract are kept, with the versions named:**
  * dominance and invariance (the law of the one-tape version);
  * the agreement "with the coin-free and Kolmogorov versions and Solomonoff's per-query solution up to the complexity of the input set", on distinct inputs;
  * no coding theorem;
  * pathwise regret and $O(K(f)/n)$ (SOI, by the default);
  * fresh noise: "The one-tape version cannot model fresh label noise on repeated inputs; the per-query solution can";
  * order-independence and the cyclic permutation, now with "and no order-independent predictor pays less in expectation" (`prop:ex:orderfree`(b));
  * the chronological semimeasure;
  * the reveal-law dominance theorem;
  * the closing list.
* **Wording compressed to stay within 1920 characters:**
  * "universal or not" dropped (it is implied by "every such machine");
  * "Measured on its unnormalised predictive probabilities, … does not depend on the order of the data" became "On unnormalised predictive probabilities, … is order-independent";
  * "the labeller's complexity" became "its complexity".
* Two comment lines were added.

### `paper/sections/intro.tex` (RENAME §4, Paper 1 item 2)
* **Opening paragraph, rewritten:**
  * The supervised-learning setting, then SI, unchanged in content.
  * Solomonoff posed operator induction (`\citep{solomonoff1999two,solomonoff2008three}`) and, in the second paper, gave two solutions with universal priors and proved a convergence theorem for one of them.
  * "We call the family of such solutions *Solomonoff operator induction* (SOI) and study several of its versions." The phrasing marks the name as ours, as in Paper 2 (check-p2 Fix 1).
  * The versions, each in a sentence or a clause:
    * *Solomonoff's per-query solution*: a mixture of computable conditional distributions with an independent factor per question, so fresh randomness on a repeated question;
    * the *one-tape version*, "our default (\cref{sec:setting:sfi})". The former description of SFI's machine is kept for it, slightly shortened ("and outputs a label or diverges" dropped; "random partial function" stays);
    * the *coin-free* and *Kolmogorov versions*;
    * the *history-aware version* \SFIhist{}.
  * "We ask how the versions compare (Section 4) and what they do (Sections 5 to 10)."
  * The credit footnote is now "The one-tape version first appeared in the author's working notes \citep{hanni2026notes}." This matches Paper 2's footnote ("The one-tape version of SOI first appeared in …"). The text of the author's SFI note (`research/prior/hanni-sfi-notes.md`: the universal semimeasure's infinite read tape, with bits for different inputs drawn from it) supports it.
  * "Function induction" is not printed here (RENAME §3).
* **New paragraph "How much the version matters"** (RENAME's headline):
  * On distinct inputs, little: all versions but the history-aware one agree up to $K(\dom D)+O(1)$ bits on data sets, and the per-query solution equals the mixture of product laws there (`thm:versions:chain`, `prop:learn:perquery`).
  * In the semimeasure convention, the lower bounds of the main examples bind every order-independent predictor, the per-query solution included (`prop:hist:orderfree`, `prop:ex:orderfree`, `prop:ex:law`, `prop:hist:operator`).
  * On repeated inputs the versions differ: fresh label noise defeats the one-tape version but not the per-query solution (`prop:learn:freshnoise`, `prop:learn:perquery`).
* **"Why SFI" became "Why SOI"**, with its content kept:
  * the reasons;
  * the limits, where "a random function cannot produce fresh label noise" became "fresh label noise defeats the one-tape version" and "it is blind to the order of the data" became "without the previous inputs it is blind to the order";
  * Paper 2's two threads: "The hypotheses of Solomonoff's per-query solution are samplers that draw private coins at each input …" and "The companion paper studies the per-query solution with such priors for two purposes …";
  * the axiom-induction sentence, now "And Solomonoff axiom induction, learning a mathematical theory … is closely related to the coin-free version of SOI on sentences …". Its footnote is unchanged.
* **"Relation to Solomonoff induction":**
  * "SI is SOI on the inputs $0,\dots,n-1$".
  * "all versions but the history-aware one see the data as a set: each hypothesis answers each query without seeing the other inputs (Theorem C below)". The duplicate clause on order-independence moved to Theorem C, where it already was.
  * "… can do much better, and the history-aware version removes these gaps …: \SFIhist{} is …". The rest is unchanged, including DECISIONS §F2's Hutter sentence.
* **"Relation to neural-network Bayes":** "a circuit version of SOI".
* **Main results:**
  * Two loss conventions: "The predictive probabilities of SOI …".
  * Theorem A:
    * "as in the one-tape version above";
    * "$\MF$, the prior of the one-tape version";
    * "the cumulative log loss of the one-tape version is at most …";
    * one new sentence: "The per-query solution has the analogous bound against samplers that see only the input, on every sequence; Solomonoff's convergence theorem is its expected squared-error form (\cref{prop:learn:perquery})."
  * Theorem B: "the loss of the one-tape version on the two labels is $O(1)$"; "no two of the Kolmogorov, coin-free and one-tape versions agree up to a constant". The parenthetical names were dropped because the opening paragraph defines the versions.
  * Theorem C: "the cumulative log loss of SOI …", "SOI cannot use …", "SOI pays …"; "The history-aware version \SFIhist{} is a universal …" (was "If SFI's hypotheses see the list …, the result, \SFIhist{}, is …").
  * Theorem D: "SOI pays …", "the expected loss of SOI is …".
* **Contributions:**
  * Definitions and versions: "the comparison of all versions, including shared against private randomness (\cref{prop:versions:shared,tab:versions:compare})".
  * Learning: "the failure of the one-tape version under fresh label noise on repeated inputs and its repairs".
  * History-aware prediction: "the loss of the one-tape version exceeds …"; "A direct simulation argument with private randomness fails".
  * Worked examples: "SOI is optimal".
  * Computable versions: "Gaussian-process limits and SOI".
  * Steeper simplicity priors: "… which studies Solomonoff's per-query solution with a length penalty steeper than likelihood and gives two reasons for it".
* **What is not achieved:** "SOI is not computable"; "circuit SOI".
* **Reader's guide:** "\cref{sec:versions}, which compares the versions".
* A header comment was added.

### `paper/sections/related.tex` (RENAME §4, Paper 1 item 3)
* **Operator-induction paragraph, rewritten:**
  * Solomonoff induction (unchanged).
  * `\citet{solomonoff1999two}` describes the prediction of answers to questions from an unordered set of question–answer pairs as an example of stochastic operator induction, the search for a stochastic map from questions to distributions on answers.
  * `\citet[\S4]{solomonoff2008three}` poses this operator-induction problem and gives two solutions with universal priors:
    * a joint one, his eq. (9), which treats each pair as one string and so also models the questions;
    * a per-query one, his eq. (10), a mixture of conditional distributions of answers given questions computed by programs, with an independent factor for each question.
  * For the latter he proves his eq. (12): for answers from a probabilistic algorithm describable in $k$ bits, and any given sequence of questions, the expected squared error, summed over all symbols of all answers, is less than $k\ln2$.
  * His eq. (10) is our $\Mpq$ (`rem:versions:operator`), which equals $\Mprod$ on distinct inputs and is the natural object for fresh label noise (`prop:learn:perquery`).
  * Our default, the one-tape version, shares its randomness across inputs instead (`prop:versions:shared`).
  * The one-tape, coin-free, Kolmogorov and history-aware versions do not appear in Solomonoff's papers.
  * "in the spirit of operator induction" and "SFI" are gone.
* **Chronological semimeasures:** "SOI becomes its history-aware version \SFIhist{}".
* **Novelty** (`rem:related:new`, label kept):
  * New, to our knowledge:
    * "the one-tape version and its function-machine formulation" (was "the name and the function-machine formulation of SFI");
    * "the comparisons of the versions in \cref{sec:versions}: the chain, the absence of a coding theorem for function programs, the tape-length bound, the fact that shared randomness is not a mixture of private randomness, and the unbounded gap of the coin-free version", citing Theorems 4.4, 4.9 and Propositions 4.5–4.7;
    * "the separations between the order-free versions and \SFIhist{}";
    * the rest of the list, unchanged.
  * Known: "Solomonoff's operator-induction problem, his two solutions and the convergence theorem for his per-query solution, with expected squared error less than $k\ln2$ \citep{solomonoff2008three}, and the universal chronological semimeasure", then the rest of the list, unchanged.
* Header comment lines were added.

### `paper/sections/discussion.tex` (RENAME §4, Paper 1 item 7)
* "SOI as ideal supervised learning"; "SOI keeps a probability bounded below".
* "What the hypotheses may see":
  * "… properties of order-free prediction rather than of any one version";
  * "Every order-independent predictor, Solomonoff's per-query solution included, pays them in expectation" (adds `\cref{prop:hist:operator}`);
  * "Which of the order-free versions and \SFIhist{} is the right ideal …";
  * "the guarantees of SOI apply as stated".
* "Which version to call SFI" became "Which version to take as the default":
  * "… on data sets (Solomonoff's per-query solution on distinct inputs)";
  * "between the program-based versions and the one-tape version";
  * "the Kolmogorov version, the single shortest program", "the coin-free version, the program mixture";
  * "We take the one-tape version $\MF$ as the default because it treats the labelling as one random function and is the law of one universal machine with one sequence of coin flips, it has a posterior over functions, …" (was "We call $\MF$ SFI because …"), citing `sec:setting:sfi` and `rem:setting:recommend`;
  * "a random function, such as the one-tape version, cannot produce fresh noise …, while Solomonoff's per-query solution can".
* Computable versions and networks: "circuit SOI"; "where SOI needs $O(k\log d)$".
* The companion paper: "The companion paper studies Solomonoff's per-query solution under such priors and gives two reasons for them"; "With shared randomness, as in the one-tape version, or in sequence prediction, a universal mixture is itself a hypothesis …".
* Open problems (content unchanged):
  * (1) "the conditionals of SOI";
  * (4) "the leave-one-out error of the one-tape version";
  * (5) "normalised SOI".
* Acknowledgements and Code and data: unchanged.

### `paper/OUTLINE.md` (minimal)
* Title: the final title.
* One new paragraph under the title: the rename, the default, the versions, and pointers to RENAME.md and the logs.
* Every standalone "SFI" outside quotations and binding-note blocks became "SOI". Three quotations keep their wording:
  * the author's purpose sentence;
  * the request quotation in §9;
  * the binding notes (`>` lines).
* Targeted edits:
  * the credit line: "the one-tape version of SOI ("function induction" in the notes)";
  * `sec:setting:sfi`: "The one-tape version of SOI and its conventions (the default convention is stated here, once)";
  * versions notes: "Solomonoff's solutions (`rem:versions:operator`): his eq. (10) is $\Mpq$, …; Solomonoff 2008 read in full" (was "unverified against Solomonoff 2008");
  * learn: "refuted for the one-tape version"; "stamped one-tape version" (twice);
  * steeper: "λ = 1 similar posterior (per-query solution and SI)";
  * related: "Solomonoff's operator-induction problem: the term (Solomonoff 1999), the problem, solutions (9) and (10) and theorem (12) (Solomonoff 2008), both read in full" (was "unverified beyond the abstract and secondary sources").

### `paper/CLAIMS.md` (minimal)
* Title "(fundamentals of Solomonoff operator induction)".
* One new paragraph: "SFI" in the ledger became "SOI", which without qualification means $\MF$; quotations keep their wording.
* Every standalone "SFI" outside double-quoted spans became "SOI". Macro names, `\LSFI` and bib keys are unchanged. The quotations left as they were:
  * the e-mail claim in `rem:ex:email`;
  * the context-notes claim in `rem:ood:lopsided`;
  * the request quotations R1, R2, R4.
* Rows with a changed title, status or object:
  * `rem:setting:perinput` ("Solomonoff's per-query solution $\Mpq$");
  * `def:setting:sfi` ("Solomonoff operator induction, one-tape version"; "followed by the default convention …, stated once");
  * `rem:setting:recommend` ("Choice of the default version: $\MF$ …");
  * `rem:versions:operator`: new title and content ((9) joint, (10) = $\Mpq$ under the formalisation, (12)); new status `known (primary source read); equality on distinct inputs proved`; source adds Solomonoff 2008 §4;
  * `prop:learn:freshnoise` ("The one-tape version cannot model fresh label noise"; "refuted for the one-tape version");
  * `prop:learn:perquery` ("Solomonoff's per-query solution"; "(d) the stamped one-tape version dominates $\Mpq$"; the eq. (12) credit);
  * `conj:learn:loo` ("for $\nu=\MF$");
  * `prop:hist:operator` (title; status `proved`, as in `app-hist.tex`);
  * `def:hist:sfihist` ("the history-aware version of SOI: the one-tape version over $X_H$");
  * `rem:nn:bridge`, `rem:nn:rigorous` ("circuit SOI");
  * `rem:related:new` (what is known and what is new, as in the paper);
  * conflict C1 (resolved by the primary source).

## 2. Version decisions (which version each statement is about)

| place | wording now | version | reason |
|---|---|---|---|
| abstract, "In the one-tape version, our default, …" | explicit | $\MF$ | The abstract must establish what plain "SOI" means in its later sentences. It does not restate the convention as a rule. |
| abstract, "Its law dominates … depends on the universal machine only up to a constant factor" | the one-tape law | $\MF$ | `thm:setting:universal`, `thm:setting:invariance` are about $\MF$. |
| abstract, "On distinct inputs it agrees with the coin-free and Kolmogorov versions and Solomonoff's per-query solution up to the complexity of the input set" | explicit | $\MF$ vs $W,\KF,\Mpq$ | `thm:versions:chain`; $\Mpq$ only on distinct inputs (`prop:learn:perquery`(a)), hence "On distinct inputs". |
| abstract, "SOI's cumulative log loss exceeds that of every computable random labeller by at most its complexity plus a constant" | default | $\MF$ | `thm:learn:dominance` is for $\MF$ against every machine law. Machine laws include shared randomness, so this does not hold for $\Mpq$ as stated. The default convention makes "SOI" mean $\MF$. |
| abstract, fresh noise | explicit, both versions | $\MF$; $\Mpq$ | Repeated inputs: RENAME §3 requires names. |
| abstract, "SOI's cumulative loss is order-independent … and no order-independent predictor pays less in expectation" | default, plus every order-independent predictor | $\MF$; all weak | `prop:setting:order`, `thm:ex:cycle`, `prop:ex:orderfree`(b). |
| intro, "our default (\cref{sec:setting:sfi})" | pointer | $\MF$ | RENAME §3: the convention is stated once in `setting.tex`; the introduction points to it (log-p1-a item). |
| intro, "How much the version matters" | "all versions but the history-aware one" | $W,\KF,\Mprod,\MF,\Mw$; $\Mpq$ on distinct inputs | RENAME asks for the headline that most results hold for every version. Stated literally, this overclaims in two ways. (i) The history-aware version differs from $\MF$ without bound on distinct inputs (`thm:hist:chain`). (ii) Upper bounds stated for $\MF$ transfer to the other versions only up to $K(\dom D)$, which is large on the chain example. So the paragraph states exactly what is true: agreement up to $K(\dom D)+O(1)$ on data sets, the examples' lower bounds for every order-independent predictor (per-query solution included, `prop:hist:operator`; `prop:ex:orderfree`(a) also covers every law of a random partial function), and the difference on repeated inputs. Its title is "How much the version matters", answered "On distinct inputs, little". |
| intro, "Why SOI": limits | "fresh label noise defeats the one-tape version"; "without the previous inputs it is blind to the order" | $\MF$; order-free versions | Fresh noise needs the name. The history-aware version is not blind to the order. |
| intro, "Why SOI": Paper 2 thread | "The hypotheses of Solomonoff's per-query solution are samplers that draw private coins …"; "The companion paper studies the per-query solution with such priors" | $\Mpq$'s class | RENAME §4 item 8 and Paper 2 item 1. The old "Its hypotheses include samplers …" was true of $\MF$'s class too, so nothing true was lost. |
| intro, axiom induction | "the coin-free version of SOI on sentences" | $W$ | Unchanged object (RENAME §4 item 2). |
| intro, "SI is SOI on the inputs $0,\dots,n-1$" | default | $\MF$ | `prop:setting:si` is about $\MF$. |
| intro, "all versions but the history-aware one see the data as a set" | explicit | order-free versions | `prop:setting:order` (weak $\nu$), `prop:learn:perquery`(a) (multiset). |
| Theorem A | "the prior of the one-tape version", "the cumulative log loss of the one-tape version" | $\MF$ | Dominance over shared-randomness machine laws is specific to $\MF$ (RENAME §2, consequence 3). |
| Theorem A, new sentence | "The per-query solution has the analogous bound against samplers that see only the input, on every sequence" | $\Mpq$ | `prop:learn:perquery`(b). The explicit name avoids reading Theorem A as a statement about Solomonoff's solution. |
| Theorem B | "the loss of the one-tape version"; "Kolmogorov, coin-free and one-tape versions" | $\MF$, $W$, $\KF$ | `thm:versions:nocoding`(iii) is $\LSFI=L_{\MF}$. Versions are compared, so they are named. |
| Theorem C | "SOI" (default), "The history-aware version \SFIhist{}" | $\MF$; $\MH$ | `thm:hist:chain` is about $\LSFI$. The order-free lower bound for every lsc order-independent predictor is stated in the same sentence, as before. |
| Theorem D | "SOI" (default) | $\MF$, $\MFbar$ | `thm:ex:cycle`, `prop:ex:normalised`, `thm:ex:expected`, `thm:ex:sandwich` are about $\LSFI$/$\LSFIbar$. |
| contributions, fresh noise | "the failure of the one-tape version" | $\MF$ | Fresh noise: explicit. |
| contributions, reveal laws | "the loss of the one-tape version"; "A direct simulation argument with private randomness fails" | $\MF$ | `cor:hist:thm1` bounds $\LSFI$. The proof uses the shared tape, and `prop:hist:sketchfails` shows that private randomness per input fails. Shared against private randomness requires the name (RENAME §3; same decision as log-p1-b item 4). |
| contributions, steeper bullet | "studies Solomonoff's per-query solution with a … steeper penalty" | $\Mpq$'s class | RENAME §4 item 8. |
| contributions, NN; "What is not achieved" | "SOI on sparse parities"; "SOI is not computable"; "circuit SOI" | default or family | `cor:nn:separation` is stated for $\nu\in\{W,\MF\}$. Non-computability holds for every version. "Circuit SOI" names the family's circuit analogue, as `nn.tex` does. |
| related, novelty | "the separations between the order-free versions and \SFIhist{}" | order-free versions | `prop:hist:orderfree` gives the separations for every weak $\nu$, not only for $\MF$. |
| discussion ¶1 | "SOI" (default) | $\MF$ ($W$ in OOD) | `rem:learn:ideal` is about $\MF$. The OOD conventions fix $\nu\in\{W,\MF\}$. |
| discussion ¶2 | "rather than of any one version"; "Solomonoff's per-query solution included"; "Which of the order-free versions and \SFIhist{}" | all order-free versions | `prop:hist:orderfree`, `prop:hist:operator`, `prop:ex:orderfree`, `prop:ex:law`. |
| discussion ¶3 | explicit names throughout | all | The paragraph compares versions and states the default. |
| discussion ¶5 | "With shared randomness, as in the one-tape version, or in sequence prediction, a universal mixture is itself a hypothesis" | $\MF$ (and every class containing its own mixture) | Absorption: explicit (RENAME §3). "With shared randomness" is kept general, because Paper 2's absorption covers every such class. |
| open problems (1), (4), (5) | "SOI" (default); "the one-tape version"; "normalised SOI" | $\MF$ | `q:setting:level` is about $\MF$ and $\MFbar$; `conj:learn:loo` is for $\nu=\MF$; `q:hist:open`(iii) as printed in `hist.tex`. |

## 3. Items from the body groups' logs, and what was done

* **log-p1-a:**
  * Default convention only pointed to from the introduction: done.
  * `discussion.tex:9` retitled: done ("Which version to take as the default").
  * `discussion.tex:21`, leave-one-out of the one-tape version: done.
  * `app-verification.tex`: not this group's file; log-p1-b reports it done.
  * CLAIMS.md and OUTLINE.md rows: all done (§1).
* **log-p1-b:**
  * Headline in the introduction, with direct citations of `prop:ex:orderfree`, `prop:ex:law`, `prop:hist:orderfree` and `prop:hist:operator`: done.
  * "circuit SOI" in the introduction: done.
  * Open problem (5), "normalised SOI": done.
  * CLAIMS and OUTLINE names for §§6–10, including the section headings: done.
  * Related work's remaining "in the spirit of operator induction": removed.
* **log-p2 (Paper 2):**
  * Credit wording: Paper 1's introduction footnote now reads "The one-tape version first appeared in the author's working notes", consistent with Paper 2's "The one-tape version of SOI first appeared in …". The `setting.tex` footnote keeps the RENAME §3 sentence on the name "function induction".
  * Paper 1 marks the family name as ours ("We call the family of such solutions …"), as Paper 2 does.

## 4. Statements about Solomonoff and where they are checked

All of these are in the 2008 text unless marked otherwise.

* **"Solomonoff posed operator induction, predicting the answer to a new question from an unordered set of question–answer pairs"** (abstract), and **"operator induction: given an unordered set of question–answer pairs, find the probability distribution of the answer to a new question"** (intro).
  * §4: "In the Operator Induction problem, we are given an unordered set of n strings and/or number pairs, [Qi, Ai]. Given a new Qn+1, what is the probability distribution over all possible An+1?"
  * §1: "The Qs can be questions …, the As can be associated answers".
  * 1999 §1: the question–answer paragraph, called an example of "stochastic operator induction".
* **"(supervised learning)":** our gloss. 2008 §1 lists the identification, categorization and curve-fitting problems as instances.
* **"gave universal-prior solutions with a convergence theorem"; "in the second paper he gave two solutions with universal priors and proved a convergence theorem for one of them":**
  * §1: "We will give two solutions to this problem based on universal distributions, and give associated convergence theorems".
  * §4.3 "Convergence Proof" is for the distribution of (10).
* **"Solomonoff's per-query solution mixes computable conditional distributions of the answer given the question, with an independent factor for each question, so a repeated question gets fresh randomness"** (intro).
  * §4.2, eq. (10): $\sum_ja^j_0\prod_{i=1}^{n+1}O^j(A_i\mid Q_i)$, with "the jth possible conditional probability distribution".
  * "we will instead sum over all partial recursive functions". "Computable" is our gloss for "computed by partial recursive functions".
  * The repeated question: RENAME §2.
* **"Solomonoff's convergence theorem is its expected squared-error form"** (Theorem A):
  * §4.3 bounds the expected squared error by "– ln c, c being the largest positive number such that P/μ > c", a dominance constant, and then by $k\ln2$.
  * RENAME §2, consequence 3; same wording as learn.tex after `prop:learn:perquery`.
* **Related work, 1999:** "describes the prediction of answers to questions from an unordered set of question–answer pairs as an example of stochastic operator induction, the search for a stochastic map from questions to distributions on answers".
  * 1999 §1: "We have an unordered set of ordered pairs of strings. Each pair represents a question and an associated correct answer. …"
  * Then: "The problems of the last two paragraphs may also be thought of as examples of 'stochastic operator induction'. … when we insert our 'question' into the stochastic operator, we want a probability distribution on 'answers.'"
* **Related work, (9):** "a joint one, his eq. (9), which treats each pair as one string and so also models the questions".
  * §4.1: "an extrapolation of an unordered set of finite strings, Di, in which Di = (Qi, Ai). Equation 6 is used …".
  * End of §4.3: "Equation (9) exploits regularities in the set [Qi, Ai]. It includes regularities in the set [Qi]".
* **Related work, (10):** "a per-query one, his eq. (10), a mixture of conditional distributions of answers given questions computed by programs, with an independent factor for each question". See §4.2 above.
* **Related work, (12):**
  * The claim: "if the answers come from a probabilistic algorithm describable in $k$ bits, then for any given sequence of questions the expected squared error of the predicted probabilities, summed over all symbols of all answers, is less than $k\ln2$".
  * §4.3: "we hypothesize that the sequence of Ai answers that have been observed, were created by a probabilistic algorithm, μ(Ai|Qi) and that μ can be described with k bits".
  * "μ(Zl) is the probability that μ assigns to Zl in view of the sequence of Qs".
  * "the expected value with respect to μ of the squared 'error' between P and μ, summed over the individual symbols of all of the Ai, will be less than k ln 2".
* **"It and the coin-free, Kolmogorov and history-aware versions do not appear in Solomonoff's papers":**
  * RENAME §2, consequence 2.
  * Both texts were re-read for this. Neither has one random tape shared by all questions, a mixture of deterministic functions, a single shortest consistent program, or hypotheses that see earlier questions.
  * 1999 §3 treats unordered sets of strings only.
* **Novelty, "Known are Solomonoff's operator-induction problem, his two solutions and the convergence theorem for his per-query solution, with expected squared error less than $k\ln2$":** as above. RENAME writes "at most $k\ln2$"; the source says "less than", which is what is printed.
* **Nothing printed in this group's files attributes anything about $\MF$, $W$, $\KF$, $\MH$ or the comparisons to Solomonoff.**

## 5. Items for other groups and for the lead editor

1. **RENAME §2 (lead editor):** the description of Solomonoff (1999) is slightly inaccurate.
   * RENAME says that 1999 "describes supervised categorisation and question–answer pairs as examples of 'stochastic operator induction'".
   * In 1999 §1 the two examples ("the last two paragraphs") are number pairs $[x_i,y_i]$ (regression) and question–answer pairs.
   * The supervised-categorisation (mushroom) paragraph comes before them and is called "very similar" to the prediction of unordered sets.
   * Nothing printed, and nothing in `NOTATION.md`, `setting.bib`, `operator.bib` or Paper 2's planning files, repeats the inaccuracy (grep for "categori").
   * Paper 1's related work states only the question–answer example. Paper 2's check-p2 states it correctly.
2. **p1-a (`setting.tex`), optional:** the opening says "*Solomonoff operator induction* (SOI) is the family of Bayesian solutions to this problem under universal priors". The introduction now says first that the name is ours ("We call the family …"), so no change is needed. If `setting.tex` should also read on its own, "We call … SOI" would match Paper 2.
3. **Lead editor, length:** the introduction is 18 lines longer and related work 11 lines longer (§0), and the paper is 93 pages instead of 92. If the length rule must be met strictly, the cheapest cut is the Hutter sentence in the introduction's "Relation to Solomonoff induction", which repeats related work (2 lines; prescribed by DECISIONS §F2, so I left it).
4. **p2-front:** nothing new is needed. Paper 1's numbering is unchanged (0 differ). Paper 1's printed framing matches Paper 2's:
   * "We call the family of such solutions SOI";
   * "The one-tape version first appeared in the author's working notes";
   * the companion paper studies "Solomonoff's per-query solution with a … steeper penalty".
