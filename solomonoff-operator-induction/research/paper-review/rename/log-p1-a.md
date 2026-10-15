# Rename log, group p1-a (Paper 1 definitions: setting, versions, learn, their appendices, NOTATION.md)

Binding sources: `rename/RENAME.md`, then `REFRAME.md` and `DECISIONS.md` where RENAME does not override them. Every statement about Solomonoff was checked against the text extractions of Solomonoff (2008) and (1999) in the session scratchpad (`sol/050fb3ed-solomonoff2008.txt`, `sol/e6ca0271-compj99.txt`). The checks are listed in §3.

Mathematics is unchanged. No label was renamed, and no numbered environment, section or equation was added or deleted.

## 0. Checks

* Isolated builds (`./test-section.sh`) of `setting app-setting`, `versions app-versions` and `learn app-learn`: all OK, with 0 undefined citations. The only overfull box is 0.86pt, in the swap paragraph of setting.
* Full build (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, last run after the final edit):
  * 0 LaTeX errors;
  * 0 undefined references or citations;
  * 0 multiply defined labels;
  * 0 overfull boxes above 10pt;
  * 92 pages.
* `check_numbering.py aux-before/paper1-main.aux paper/main.aux`: 314 labels before, 314 after, 0 differ.
* `pdftotext main.pdf`, restricted to Sections 3–5 and Appendices A–C:
  * no "SFI";
  * no "in this spirit";
  * no "unverified";
  * "function induction" only in the footnote allowed by RENAME §3 ("The author's working notes call this setting function induction (Hänni, 2026c).").
  * The remaining hits for "SFI" in the PDF are all in other groups' files.
* Length, measured as text lines of the isolated builds (`pdftotext -layout`), HEAD against now:
  * setting: 632 → 645;
  * versions: 448 → 460;
  * learn: 514 → 524.
  * This is about +4 to +6 printed lines per section. The growth comes from the items RENAME requires: the problem and family sentence, the default-convention sentence, the rewritten Remark 4.2, the credit after Prop 5.7 and the dominance sentence.
  * `sec:hist` now starts on p. 22 instead of p. 21, because the learn section spills over by about four lines.

## 1. Changes by file

### `paper/sections/setting.tex`
* **Section title:** "Function semimeasures, function machines and SOI".
* **Opening paragraph:**
  * New first sentences. Solomonoff's operator-induction problem: given an unordered set of question–answer pairs, the distribution of the answer to a new question (`\citep{solomonoff2008three}`); here questions are inputs and answers labels. SOI is the family of Bayesian solutions to this problem under universal priors.
  * The informal description is now that of "its one-tape version" (was "SFI").
  * "compares the variants" became "compares the versions, among them Solomonoff's own per-query solution".
* **Merged credit footnote** (RENAME §3), now: "The author's working notes call this setting function induction \citep{hanni2026notes}. The private random stream per input, with the resulting dominance (…), and an informal claim that the input encoding matters little (…) first appeared there." The citation count is unchanged.
* **`rem:setting:perinput`:** "the per-query mixture $\Mpq$" became "Solomonoff's per-query solution $\Mpq$". Added a `\cref` to `rem:versions:operator`.
* **`sec:setting:sfi` title:** "The one-tape version of SOI and its conventions".
* **`def:setting:sfi`:**
  * Title "Solomonoff operator induction, one-tape version".
  * "SFI is the random partial function…" became "The one-tape version of SOI is the random partial function…".
  * "SFI's loss is $\LSFI$" became "the loss of the one-tape version is $\LSFI(D):=L_{\MF}(D)$".
* **Default-convention sentence** (RENAME §3), directly after Definition 3.15, merged into the paragraph that already followed it: "When we say SOI without qualification, we mean the one-tape version $\MF$: it treats the labelling as one random function, so labels of repeated inputs agree; it is the law of a single universal machine and dominates every function machine (Thm 3.8); and on distinct inputs it agrees with the other versions of Section 4 up to $K(\dom D)+O(1)$ bits (Thm 4.4, Prop 5.7)."
  * I wrote "the other versions of Section 4", not "the other versions". The history-aware version differs from $\MF$ unboundedly on distinct inputs (chain example), so the unrestricted claim would be false.
  * Prop 5.7 is cited for $\Mpq$, which Thm 4.4 does not contain; on distinct inputs it equals $\Mprod$.
* **`prop:setting:order`:** "For SFI it is" became "For SOI it is" (default convention, $\MF$).
* **`rem:setting:recommend`:**
  * Title "Choice of the default version".
  * The first sentence now reads "Besides the reasons given after Definition 3.15, $\MF$ has a posterior over functions…, dominates every machine law…, is invariant…, and has an order-independent semimeasure-convention loss." This avoids stating the convention twice. The claim "it is the law of the one-tape definition" was dropped as tautological.
  * The list of versions uses the names "coin-free version (the program mixture $W$)", "Kolmogorov version $\KF$" and "Solomonoff's per-query solution $\Mpq$".
  * The mathematics, including the last clause (DECISIONS §F13), is unchanged.
* **`thm:setting:invariance`(b):** "$M'_F$ SFI over $X',Y'$" became "$M'_F$ the one-tape law over $X',Y'$".
* **Swap paragraph, `prop:setting:si` title, closing paragraph:** "SFI" became "SOI" (default convention).

### `paper/sections/app-setting.tex`
* Appendix title: "(function semimeasures and SOI)".

### `paper/sections/versions.tex`
* **Opening (RENAME §4.5):**
  * "SOI has at least two natural formalisations…", where SOI is the family.
  * After "They do not" one clause was added: "and the versions also differ in where their randomness lives, from Solomonoff's per-query solution $\Mpq$ (Remark 4.2) to the one-tape version $\MF$."
* **`def:versions:variants`:** item "Per-query mixture, the per-query version (…)". The definition itself is unchanged.
* **$W$ paragraph:** "the coin-free version of SOI" (the family).
* **`rem:versions:operator`** (RENAME §4.4), rewritten in place with the same label and numbering (Remark 4.2):
  * Title "Solomonoff's solutions".
  * `\status{known (primary source read); equality on distinct inputs proved}`.
  * `\src` notes "Solomonoff 2008, §4, eqs. (9)–(12), read in full".
  * Text:
    * Solomonoff's eq. (9), the joint solution: one string per pair, his universal mixture over unordered sets of strings, conditioned on the new question; it also models the questions.
    * Eq. (10): the probability of the new answer is $\sum_ja^j_0\prod_{i\le n+1}O^j(A_i\mid Q_i)$ over the conditional distributions computed by partial recursive functions, with weights $a^j_0\approx2^{-l(O^j)}$. With the lsc conditional semimeasures $P_i$ for the $O^j$ and $\mm(i)$ for the weights, this is $\Mpq(A_{1:n+1}\Vert Q_{1:n+1})$. A repeated question gets an independent factor.
    * Eq. (12) is a convergence theorem for it (pointer to Prop 5.7).
    * The relation to $\Mprod$ is kept verbatim in substance.
* **`rem:versions:randomness`:** names "Solomonoff's per-query solution $\Mpq$" and "the one-tape version $\MF$" (shared against private randomness: RENAME §3 requires explicit names).
* **`rem:versions:answer`:**
  * (2) "the coin-free version $W$ predicts as well as the one-tape version…", "exceeds the loss of $\MF$…", "the explanation of the data by $\MF$".
  * (3) "exceed the loss of $\MF$", "the learning rate of $\MF$".
  * (6) "Solomonoff's per-query solution $\Mpq$".
  * (7) "On a single query the one-tape version is…".

### `paper/sections/app-versions.tex`
* Subsection `app:versions:structured`: "Structured outputs and the history-aware version".
* After `prop:versions:structured`: "single-query SFI" became "on a single query the one-tape version".
* `rem:versions:hist` title: "The same gap for the history-aware version".

### `paper/sections/learn.tex`
* **Section title:** "Learning theorems: SOI as supervised learning".
* **Opening:** "SOI can be viewed as ideal supervised learning…". Added: "unless stated otherwise the results concern the one-tape version, and $\LSFI(D_n)=-\log\MF(D_n)$ is its cumulative log loss…".
* **After `thm:learn:dominance`:**
  * "loses to $\MF$" (was "SFI").
  * **New sentence on $\MF$'s dominance** (RENAME §2.3): "For the one-tape version, with randomness shared by all inputs, this theorem and the bounds below that rest on it are ours in this form; they follow by the standard dominance argument, which also underlies Solomonoff's convergence theorem for his per-query solution (Prop 5.7)."
* **`rem:learn:h2`(ii):** "per query it gives Solomonoff's per-query solution $\Mpq$".
* **After `thm:learn:merging`:** "This is the one-tape analogue of Solomonoff's convergence theorems (cf. \citealp{solomonoff1978complexity}; for the per-query solution, Prop 5.7)."
* **`thm:learn:batch`(b):** "Run SOI on $\tilde x_t$" (the formula uses $\MF$).
* **`prop:learn:freshnoise`:**
  * Title "the one-tape version cannot model fresh label noise".
  * (c): the quoted natural strengthening now reads "…the expected cumulative log loss of SOI exceeds that of $P$…", followed by "fails for the one-tape version $\MF$".
  * The paragraph after it: "The one-tape version models the label as a function of the input…", and "…and Solomonoff's per-query solution:" (was "mixing per query").
* **`prop:learn:perquery`:** title "Solomonoff's per-query solution". The statement is unchanged.
* **Credit after Prop 5.7** (RENAME §2.3), replacing "$\Mpq$ is a per-query mixture in the spirit of…":
  * "$\Mpq$ is Solomonoff's second solution, his eq. (10) (Remark 4.2). Part (b) is the pathwise log-loss form of its dominance."
  * "\citet[eq. (12)]{solomonoff2008three} proves the expected squared-error form: for labels drawn from $P(y\mid x)$ computed by a probabilistic algorithm describable in $k$ bits, and any given sequence of inputs, the expected sum of the squared errors of the predicted symbol probabilities, over all symbols of all labels (in binary, with separators), is less than $k\ln2$."
  * "He notes that the proofs of the underlying sequence-prediction theorems also give the bound for Kullback–Leibler loss (his Section 2). Part (c) is the standard consequence for i.i.d. data."
  * Then the existing sentences (regret under fresh noise; \SFIhist{} dominates it; Prop 9.4 is a time-bounded analogue).
  * I used $P(y\mid x)$ and not Solomonoff's $\mu$, because $\mu$ is the input distribution in this section.
* **Learning-curve paragraph:** "the corresponding conjecture for $\MF$".
* **`sec:learn:ideal` and `rem:learn:ideal` titles:** "SOI".
* **After `prop:learn:occam`:** "for deterministic targets the one-tape version (Thm 5.5(a)) and the Kolmogorov version learn at the same rate".
* **`rem:learn:ideal`:**
  * (1) "The one-tape version is the Bayes predictor for the law $\MF$ … and it is universal for that class pathwise".
  * Limits: "where the loss of SOI is unbounded".

### `paper/sections/app-learn.tex`
* Subsection `app:learn:perquery`: "Solomonoff's per-query solution".
* `rem:learn:lastiterate`: "the predictive of $\MF$". In its proof: "$\MF$ sees its data only as a set".
* `conj:learn:loo`:
  * title "leave-one-out for the one-tape version";
  * statement "For $\nu=\MF$, …" ($e_{\rm LOO}$ is defined for $\nu\in\{W,\MF\}$ in `prop:learn:loo`).
* Proof of `cor:learn:perstep`(b): "since $\nu$ sees its data as a set". The corollary is for $\nu\in\{W,\MF\}$; the old "SFI" was loose. The argument is unchanged.
* `prop:learn:active`(2): "the total loss of $\MF$".
* `rem:learn:positive`: "a natural relative of SOI. In SOI terms…" (the family).
* "Computations" paragraph: "the per-query version on a finite class of laws".

### `paper/NOTATION.md` (minimal)
* Title "Notation for both SOI papers".
* The two paper titles are the final ones.
* New **Naming** paragraph (pointer to RENAME.md):
  * SOI is the family; unqualified SOI means $\MF$, a convention stated once, after `def:setting:sfi`.
  * The versions and their names.
  * "SFI" is never printed; macro names, labels and bib keys keep "SFI".
* Rows updated: $T_U,\MF$ (one-tape version, the default); $\MFbar$; $W$ (coin-free version); $\Mpq$ (per-query version, Solomonoff's eq. (10)); \SFIhist{} etc. ("SOI whose hypotheses…; print SOI$^{\rm hist}$"); $\LSFI$ (prints $L_{\rm SOI}$); $\LSFIbar$; §6 loss sentence; §9.2 operator-induction keys (1999, 2008 primary, read in full; Özkural dropped); §10 renderings of `\LSFI`, `\LSFIbar`, `\SFIhist`.
* Left unchanged on purpose:
  * the source columns, which give the sources' own names;
  * the name of the "SFI macros" block, as in the preamble comment;
  * "SFI drafts" in the description of the notes.

## 2. Version decisions (which object each statement is about)

| place | old | new | reason |
|---|---|---|---|
| setting opening | "SFI feeds one … sequence … to $U$" | "its one-tape version" | The paragraph describes the shared-tape construction, which is $\MF$. |
| `def:setting:sfi` | "SFI is $f_\omega$ …" | "The one-tape version of SOI" | The definition is of $\MF$; the default convention follows it. |
| `def:setting:sfi` loss | "SFI's loss $\LSFI$" | "the loss of the one-tape version" | $\LSFI:=L_{\MF}$; the macro prints $L_{\rm SOI}$, consistent with the default. |
| `prop:setting:order` | "For SFI it is $\LSFI(D_n)$" | "For SOI" | Default convention ($\MF$); the formula names $\LSFI$. |
| `rem:setting:perinput` | "per-query mixture" | "Solomonoff's per-query solution $\Mpq$" | Repeated inputs: RENAME requires the explicit name. |
| `rem:setting:recommend` | "We take $\MF$ as SFI" | "Besides the reasons given after Def 3.15, $\MF$ …" | The convention is stated once, after the definition. This remark keeps the further reasons and the warning that the versions differ. |
| `thm:setting:invariance`(b) | "$M'_F$ SFI over $X',Y'$" | "the one-tape law over $X',Y'$" | The object is $\MF$ over the other alphabets. |
| swap paragraph | "separate SFI from history-aware prediction" | "SOI" | Default, $\MF$. The lower bound holds for every lsc history-aware predictor, so it is true for every version. |
| `prop:setting:si`, closing paragraph | SFI | SOI | Default ($\MF$). "Ideal reference, not an algorithm" is true of the whole family too. |
| versions opening | "SFI has at least two natural formalisations" | "SOI …" | RENAME §4.5: here SOI is the family. |
| $W$ paragraph | "coin-free version of SFI" | "of SOI" | The family. |
| `rem:versions:randomness` | $\Mpq$, $\MF$ by symbol | adds "Solomonoff's per-query solution", "the one-tape version" | Shared against private randomness: explicit names required. |
| `rem:versions:answer` (2), (3) | "as well as SFI", "SFI's loss", "SFI's learning rate" | "the one-tape version", "the loss of $\MF$", "the learning rate of $\MF$" | Versions are compared, so the comparator is named. |
| `rem:versions:answer` (7), `app:versions:structured` | "On a single query SFI …", "single-query SFI" | "the one-tape version" | The cited result (`thm:setting:coding`(c)) is about $\LSFI=L_{\MF}$. |
| history-aware titles in app-versions | "history-aware SFI" | "the history-aware version" | This is \SFIhist{} (SOI$^{\rm hist}$). |
| learn opening | "$\LSFI$ is SFI's cumulative log loss" | "unless stated otherwise the results concern the one-tape version, and $\LSFI$ is its cumulative log loss" | Most results are about $\MF$. Props 5.8–5.10 state $\nu\in\{W,\MF\}$ explicitly, and Prop 5.7 is about $\Mpq$ (its title says so). |
| after `thm:learn:dominance` | "loses to SFI" | "loses to $\MF$" | Dominance over x-only samplers is the $\MF$ statement. Comparison with Prop 5.7(b) follows. |
| `thm:learn:batch`(b) | "Run SFI on $\tilde x_t$" | "Run SOI" | Default; the formulas use $\MF$. |
| `prop:learn:freshnoise` title | "random-function SFI cannot model fresh label noise" | "the one-tape version cannot model fresh label noise" | "Random-function SFI" meant $\MF$. Parts (a) and (b) hold for every weak $\nu$, as the statement says. |
| `prop:learn:freshnoise`(c) | "''SFI's expected … loss …'' fails for random-function SFI" | "''… loss of SOI …'' fails for the one-tape version $\MF$" | The strengthening is stated for the default and refuted for $\MF$. It holds for $\Mpq$ (Prop 5.7(c)), so the explicit name matters. |
| after Prop 5.6 | "mixing per query", "Random-function SFI" | "Solomonoff's per-query solution", "The one-tape version" | Fresh noise: explicit names. |
| learning-curve paragraph, `conj:learn:loo` | "for SFI" | "for $\MF$", "the one-tape version", "$\nu=\MF$" | $e_{\rm LOO}$ is defined for $\nu\in\{W,\MF\}$; "SFI" meant $\MF$. |
| after `prop:learn:occam` | "SFI and the Kolmogorov version learn at the same rate" | "the one-tape version" | Two versions are compared. |
| `rem:learn:ideal`(1) | "SFI is the Bayes predictor for the law $\MF$ …" | "The one-tape version …" | It is about $\MF$. |
| `rem:learn:ideal`, limits | "SFI's loss is unbounded" | "the loss of SOI" | Default. The examples have distinct inputs, so this is true of every order-free version. |
| app-learn | "SFI's predictive", "SFI sees its data", "SFI's total loss" | "$\MF$" | The objects are defined from $\MF$ ($Q_t$, Thm 5.1(b)). |
| proof of `cor:learn:perstep`(b) | "since SFI sees its data as a set" | "since $\nu$ sees its data as a set" | The corollary is for $\nu\in\{W,\MF\}$. |
| `rem:learn:positive` | "relative of SFI", "In SFI terms" | "SOI" | The family. |

## 3. Statements about Solomonoff and where they are checked

All of these are in the 2008 text unless marked otherwise.

* **The problem** (setting opening): §4, "we are given an unordered set of n strings and/or number pairs, [Qi, Ai]. Given a new Qn+1, what is the probability distribution over all possible An+1?". The question/answer reading is from §1: "The Qs can be questions …, the As can be associated answers".
* **"Gives two solutions":** §4, "We will give two solutions."
* **Eq. (9):** §4.1, "an extrapolation of an unordered set of finite strings, Di, in which Di = (Qi, Ai). Equation 6 is used …"; eq. (6) is the weighted sum of products of semimeasures on finite strings; (9) is P(An+1) = P(Qn+1,An+1)/Σ P(Qn+1,Ai), i.e. conditioning on the new question. "Also models the questions" is his own remark on (9): "It includes regularities in the set [Qi]".
* **Eq. (10):**
  * §4.2: "the probability distribution of An+1 is Σ_j a0^j ∏_{i=1}^{n+1} O^j(Ai|Qi)", where O^j is "the jth possible conditional probability distribution".
  * "We would like to sum over all total recursive functions, but … we will instead sum over all partial recursive functions".
  * "a0^j … is approximately 2^{-l(O^j)}".
  * The identification with $\Mpq$ is stated as a formalisation: "With the lsc conditional semimeasures $P_i$ for the $O^j$ and $\mm(i)$ for the weights, this is $\Mpq$", as RENAME §2 requires.
* **Eq. (12):**
  * §4.3: "we hypothesize that the sequence of Ai answers … were created by a probabilistic algorithm, μ(Ai|Qi) and that μ can be described with k bits".
  * Answers are written over {0, 1, s} with s a separator.
  * "the expected value with respect to μ of the squared 'error' between P and μ, summed over the individual symbols of all of the Ai, will be less than k ln 2".
  * "μ(Zl) is the probability that μ assigns to Zl in view of the sequence of Qs" gives the "any given sequence of inputs".
  * I wrote "proves" because the section is titled "Convergence Proof" and derives (12) from Hutter's generalisation of (5).
* **Kullback–Leibler:** §2, "The proofs of the theorems also show the same convergence for the Kullback-Liebler loss function", said of the foregoing sequence-prediction theorems. Hence the wording "the proofs of the underlying sequence-prediction theorems".
* **"The standard dominance argument … also underlies Solomonoff's convergence theorem":** §4.3 bounds the error by "– ln c, c being the largest positive number such that P/μ > c", which is a dominance constant.
* **Solomonoff (1999) is not cited in my files.** The term "stochastic operator induction" belongs to related work (RENAME §4.3).

## 4. Items for other groups

* **p1 hist group:**
  * `app-hist.tex:196` still says "$\Mpq$ is a per-query mixture in the spirit of Solomonoff's operator induction (\cref{rem:versions:operator})". This must go: "in this spirit" is a required-empty grep. Suggested: "$\Mpq$ is Solomonoff's per-query solution (\cref{rem:versions:operator})."
  * `prop:hist:operator` (D.15): retitle "Solomonoff's per-query solution ignores the history" if wished. Its `\status{proved, given the unverified description}` should become `proved`, since the identification is now from the primary source (Remark 4.2).
  * `hist.tex:134`: "The per-query mixture $\Mpq$" could become "Solomonoff's per-query solution $\Mpq$".
  * The `sec:hist` opening and `app-hist.tex` still print "SFI".
* **p1 ood/related group:**
  * `related.tex:14`: rewrite per RENAME §4.3. For consistency with Remark 4.2: (9) is the joint solution, (10) equals $\Mpq$ under the formalisation above, and (12) bounds the expected squared error by $k\ln2$ for any given question sequence. Use `\citet{solomonoff1999two}` for the term "stochastic operator induction". The paragraph currently says "in the spirit of operator induction" and "SFI".
  * `comp.tex:49`: "a mixture of the per-query kind (\cref{rem:versions:operator})" and "time-bounded analogue of SFI on time-stamped inputs" need the new names.
  * `app-comp.tex:24`: "as under SFI (\cref{prop:learn:freshnoise})" should become "as under the one-tape version". This is a fresh-noise statement, so the version must be named explicitly.
* **p1 front:**
  * The default-convention sentence is after Definition 3.15 (`def:setting:sfi`). Per RENAME §3 it is stated once; the introduction may point to it but should not restate it as a convention.
  * `discussion.tex:9`: retitle "Which version to call SFI", e.g. "Which version to take as the default".
  * `discussion.tex:21`: "Is the leave-one-out error of SFI …" should become "of the one-tape version". `conj:learn:loo` (C.4) is now titled "leave-one-out for the one-tape version".
  * `app-verification.tex:61–62` (switched off): update the operator-induction sentence minimally (RENAME §5), e.g. "It is Solomonoff's per-query solution, his eq. (10), $\Mpq$ …".
  * `CLAIMS.md`/`OUTLINE.md` (not in this group's files) need these updates:
    * `def:setting:sfi` ("SFI is $f_\omega$" → one-tape version of SOI);
    * `rem:setting:recommend` ("call $\MF$ 'SFI'" → choice of the default version);
    * `prop:setting:si`;
    * `rem:versions:operator`: new title "Solomonoff's solutions"; new status `known (primary source read); equality on distinct inputs proved`; content (9), (10) = $\Mpq$, (12); the "per secondary descriptions" wording goes;
    * `prop:learn:freshnoise` ("the one-tape version cannot model fresh label noise");
    * `prop:learn:perquery` ("Solomonoff's per-query solution"; credit to eq. (12) for (b), (c));
    * `conj:learn:loo`;
    * `rem:learn:ideal`;
    * OUTLINE l. 94: `sec:setting:sfi` is now titled "The one-tape version of SOI and its conventions";
    * OUTLINE l. 126: "random-function SFI".
* **Paper 2 groups:**
  * Paper 1's numbering is unchanged (0 differ), so citations by number stay valid.
  * Retitled items that Paper 2 may cite by name:
    * Def 3.15 "Solomonoff operator induction, one-tape version";
    * Remark 4.2 "Solomonoff's solutions": the place where eq. (10) is identified with $\Mpq$; on distinct inputs it equals $\Mprod$, i.e. Paper 2's private-randomness class mixture;
    * Prop 5.6 "the one-tape version cannot model fresh label noise";
    * Prop 5.7 "Solomonoff's per-query solution".
  * `NOTATION.md` (shared by both papers) now has a "Naming" paragraph and updated rows for $\MF$, $\Mpq$, $W$ and the SOI macros.
