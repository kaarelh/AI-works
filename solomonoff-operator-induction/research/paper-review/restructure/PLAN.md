# Paper 2 restructure: the binding plan (planning editor, 2026-10-13)

Paper 2 is `paper-steeper/`. The base version of every file is `git -C /home/user/AI-works show dcb3a3a3:solomonoff-function-induction/<path>`. This plan binds the six body writers W1–W6 and the FRONT writer.

**Order of authority.**
* For framing, voice, attribution and the arXiv form: `research/paper-review/REFRAME.md`, then `research/paper-review/DECISIONS.md`.
* For structure, labels, file ownership, notation and page budgets: this plan.
* For mathematics: the records. A statement may be printed as proved only if the records prove it **and** it is refereed or verified:
  * `research/tracks/split/notes-final.md` §8 (the synthesis);
  * the sub-track records `research/tracks/split/{iid,kink,teacher}/notes-final.md`;
  * the verification reports `research/tracks/split/verify-{iid,kink,teacher}.md`;
  * for base material, the base Paper 2 sources and `research/tracks/steeper/notes-final.md`.

  The verification reports override the synthesis wherever they correct it. `verify-iid.md` and `verify-kink.md` are complete. `verify-teacher.md` was being written when this plan was made; every item that depends on it is marked **[V-T]** below (§5).

**Inputs read for this plan.**
* The synthesis in full, including §1, §2–§4, §5 (plan and label map), §6 (open problems) and §8 (statuses).
* `final-check.md`.
* `verify-iid.md` and `verify-kink.md`, in full.
* Every section and appendix of the base Paper 2, in full, except `app-verification.tex`.
* `DECISIONS.md` (§0, §A–§H), `REFRAME.md`, the workflow script, the preamble, the bibliography keys, Paper 1's `steeper.tex` and its companion sentences.
* The statements of teacher Lemma 1.1, Def 1.4, Lemma 1.5, Props 2.1, 3.1, 3.2, 3.6, 3.7 and Lemma 3.0; iid Defs 1.1–1.3, Remark 1.4, Props 7.5 and 7.6.

---

## 0. What the plan adopts, and where it deviates from the synthesis §5

The plan adopts the synthesis §5: the split thread comes first, the teacher thread follows as "the split at a positive rate", and every existing label is placed. Deviations, each with its reason:

| # | deviation | reason |
|---|---|---|
| D1 | `recovery.tex` is the whole exact-recovery section, P6 of the synthesis. `split.tex` is emptied and not input. Its labels move to `recovery.tex`, where its section labels become aliases. `app-recovery.tex` opens the appendix of that section. `app-split.tex` continues the same appendix, with subsections and no `\section`. | DECISIONS §D1 asks for one appendix per section. The synthesis had two appendices, D and E, for one section. |
| D2 | `ex:split:noisyparity` moves to `app-absorb.tex`, next to the proof of `thm:split:shared`. | The example illustrates the mechanism of `thm:split:shared`, which moves to the absorption section. |
| D3 | `q:absorb:shared` and `q:related:open` stay in their sections. They are not moved into the discussion. | DECISIONS §A10: questions are environments in their sections, and the discussion's list cites each by `\cref`. |
| D4 | `prop:limits:separable` stays a main-text proposition. The new remark `rem:limits:hull` gathers guard erosion, input-law dependence and non-identifiability, whose propositions stay in the appendix. | It is short and is cited by the discussion and by the teacher section. |
| D5 | Notation (§4.2): $\mathcal E,\mathcal E_0$ for the equivalent programs; the reference point $(\alpha_{\rm r},L_{\rm r})$; the partition $\mathcal M\sqcup\mathcal N$ with left margin $\eta_{\mathcal N}(c)$; $\mathsf C_s(\pi)$ for the synthesis's $\rho_s(\pi)$; length caps written $\bar\ell$; λ called the "complexity weight". | Each avoids a clash with a symbol the paper already uses (§4.2). |
| D6 | The footnote of `algstat.tex` (the change-of-slope idea) moves to `kinks.tex`. | The kink section introduces the change of slope. |
| D7 | New labels beyond the synthesis's list (§3.3). | For stable cross-references between writers who work in parallel. |
| D8 | Results of the records that the paper does not state: iid Thm 4.1(v) (optional appendix remark); iid Prop 7.3(v); kink Cor 5.5 and Thm 5.6; iid Remark 7.7 (one sentence at most); iid Lemma 5.2 and Prop 5.3(c); teacher Prop 3.3(c), which goes into an open question. | The page budget. The synthesis lists the first two among its first cuts. Theorem A(d) carries the finite-sample statement, as the synthesis recommends (§2.3 "Reading"). Prop 7.3(v) would also need the law of the iterated logarithm, which has no verified bibliography entry. |
| D9 | The informal theorems of the introduction are A (exact recovery), B (kink ⇒ split) and C (the teacher's mistakes). The synthesis's Theorems C and D (the sample kink, the noisy parity) appear in the contributions list, not as informal theorems. | The workflow brief asks for A, B and the teacher theorem. |
| D10 | iid Remark 4.7 is used only in its corrected form 4.7′. | `verify-iid.md` §1.6. Three of its sentences are false as written. |
| D11 | Page budgets differ slightly from the synthesis's (§6). | Merging Apps D and E (D1), and moving `thm:split:shared` and its example. |

---

## 1. Title, abstract, introduction, contributions (FRONT)

### 1.1 Title

**Steeper Simplicity Priors in Solomonoff Function Induction: The Model–Randomness Split and the Teacher's Mistakes**

* In `main.tex`, write `\title{Steeper Simplicity Priors in Solomonoff Function Induction:\\[2pt] \large The Model--Randomness Split and the Teacher's Mistakes}`, with a matching `\hypersetup{pdftitle=…}`.
* The title of `claudeSFI2026steeper` in `bib/core.bib` changes to the same words.
* `core.bib` must stay byte-identical in both papers. So FRONT applies the same one-line change to `paper/bib/core.bib`, and to nothing else in Paper 1's bibliography.

### 1.2 Abstract (≤ 1920 characters of LaTeX source; replaces F28)

The abstract has four parts, in this order:
1. **SFI and the proposal; the two reasons.**
   * One sentence on SFI.
   * The proposal: penalise program length λ > 1 times more steeply than log-likelihood, for hypotheses with private randomness at each input.
   * We give two reasons to do so: separating model from noise (first, and main), and not learning a teacher's systematic errors.
2. **Absorption, the precondition.**
   * A universal mixture taken as one hypothesis absorbs everything, in every class that contains its own mixture (SI, SFI with shared randomness).
   * No private-randomness hypothesis is universal.
3. **The first reason.**
   * *Per query* (i.i.d. inputs, a computable sampler that draws fresh coins at every query): for every schedule $1\le\lambda_n=o(n)$, every λ-MAP is eventually a shortest program for the sampler.
   * For fixed λ > 1 this holds from a sample size that depends only on λ, the program's length, a margin and the confidence.
   * At λ = 1 no such bound exists, and in a class of parities recovery takes exponentially longer in the program's length.
   * On one data set, a kink of the product structure function at a sufficient program makes every λ between the kink's slopes select it.
   * Samples have such a kink. So does the full table of a noisy random parity at every flip rate below 1/4 (for large $d$), while set models have none.
4. **The second reason.**
   * The teacher's errors are the same geometry at a positive rate: each bit of an error rule is reused at many inputs, so λ must grow linearly in $n$.
   * The parity theorem, with its hypotheses: flip rate below 0.056, product-form error set, incompressible relative to the parity, uniform inputs, population objective, $\lambda/n$ in an explicit window. Every near-optimal hypothesis knows the parity and gives the erroneous labels far less probability than a memoriser.
   * Asymptotically in the rule length, such windows exist for flip rates below 0.123.

A draft at 1919 characters (FRONT may tighten or reword it; every claim must keep the hypotheses that the body states):

```latex
Solomonoff function induction (SFI) predicts labels from inputs with a universal prior over random functions. We study penalising program length more steeply than log-likelihood, by a factor $\lambda>1$, for hypotheses with private randomness at each input, and give two reasons to do so. A universal mixture taken as one hypothesis would absorb all structure; we prove that it does in every class containing its own mixture, such as Solomonoff induction and SFI with shared randomness, while no hypothesis with private randomness is universal. The first reason is the split into model and noise. With i.i.d. inputs and labels drawn by a computable sampler with fresh coins at every query, every $\lambda$-MAP is eventually a shortest program for the sampler, for every schedule $1\le\lambda_n=o(n)$. For fixed $\lambda>1$ this holds from a sample size that depends only on $\lambda$, the program's length, a margin and the confidence; at $\lambda=1$ no such bound exists, and in a class of parities recovery takes exponentially longer in the program's length. On one data set, a kink of the product structure function at a sufficient program makes every $\lambda$ between the kink's slopes select it; samples have such a kink, and so does the full table of a noisy random parity at every flip rate below $1/4$, while set models have none. The second reason is not learning a teacher's systematic errors, the same geometry at a positive rate: each bit of an error rule is reused at many inputs, so $\lambda$ must grow linearly in the sample size $n$. For a random parity whose labels are flipped, at a rate below $0.056$, on an incompressible error set of product form, every near-optimal hypothesis of the population objective with $\lambda/n$ in an explicit window knows the parity and gives the erroneous labels far less probability than a memoriser; asymptotically, such windows exist for flip rates below $0.123$.
```

Check against the body before finalising:
* "a shortest program for the sampler" means a shortest program whose kernel equals ν μ-a.e. (`thm:recovery:main`(a)).
* "samples have such a kink" holds with high probability for large $n$ (`thm:recovery:kink`).
* "every flip rate below 1/4" is for large $d$ and fixed λ > 1 (`prop:parity:range`(iii)).
* "below 0.123" is asymptotic in $m$, for the population objective (`prop:teacher:rates`).

### 1.3 Introduction (`intro.tex`, FRONT; 2.25 pp)

Structure, in this order:
1. **The proposal**, with its footnote. Keep the base paragraph and footnote. Lightly adjust the footnote's list: it credits the vertex question as a question; that is fine.
2. **Two reasons for a steeper penalty** (one paragraph). They are introduced in the paper's own voice, never as a reply to a request or to the notes.
   * *First reason, and the main one:* splitting data into a model and noise. At λ = 1 a sampler and the programs that fill in its sampled bits get similar posterior weight on any finite data set (`thm:split:lambda1`). Does a steeper prior select the sampler?
   * *Second reason:* not learning a teacher's systematic mistakes. The three-hypothesis calculation (`rem:teacher:hanni`) frames it.
   * One sentence: both are the same geometry, a kink of the (length, fit) hull, with the discarded part reused once (noise) or at many inputs (errors). The table `tab:discussion:reasons` in the discussion sets them side by side.
3. **The absorption objection and its answer** (one paragraph), as the reason the class must have private randomness (`thm:absorb:absorption`, `cor:absorb:nouniversal`, `thm:split:shared`).
4. **Conventions** (keep the base paragraph). Add: "PQ, FR, DS are the data objects of `def:setup:data`".
5. **Main results**: three informal theorems, as plain paragraphs (no theorem environments, no labels), each ending with `\cref`s:
   * **Theorem A (informal; exact recovery)** (`thm:recovery:main`, `prop:recovery:lambda1`, `prop:recovery:frozen`).
     * *Object.* The inputs are i.i.d. from any law μ. Each label is drawn by a sampler ν with fresh coins at every query, so a repeated input gets a fresh label.
     * *Class.* The hypotheses are the programs of any countable class with Kraft weights that contains a program for ν. Each is a kernel with private randomness: $\Hcl{\times}$, or a time-bounded or circuit subclass.
     * *Limit.* For every schedule $1\le\lambda_n=o(n)$, λ = 1 included, almost surely every $\lambda_n$-MAP is eventually a shortest program whose predictive law equals ν μ-almost everywhere.
     * *Rate.* For fixed λ > 1, with probability $1-\varepsilon$, this holds from
       $$n=O\Big(\frac{\lambda(\ell_0+\log(1/\varepsilon))}{\min(1,\lambda-1)\,\gamma}\Big),$$
       where $\ell_0$ is that program's length and γ a margin (the least average Hellinger distance to ν among inequivalent programs up to a length fixed by λ, $\ell_0$ and ε). The rate depends on nothing else. At every $n$, the posterior mass of the programs that store the sampled labels decays exponentially in the sampled randomness.
     * *λ = 1.* No recovery time that depends only on $(\ell_0,\gamma,\varepsilon)$ exists. In a class of parities with a uniform margin, the λ = 1 recovery time is $\Theta(2^{\ell_0/2})$, against $\Theta(\lambda\ell_0/(\lambda-1))$ up to logarithms for fixed λ > 1.
     * *Frozen labels.* With one label per distinct input on the countable input set, no procedure recovers every computable sampler. What survives is identification on the queried inputs, for every λ ≥ 1.
   * **Theorem B (informal; a kink implies the split)** (`lem:setup:hull`, `cor:kink:split`, `thm:kink:converse`).
     * *The picture.* On one data set, plot each program at (length, fit), the fit being minus the log-likelihood. The λ-MAPs are the programs on the lower convex hull where its slope crosses −λ.
     * *The theorem.* Let a program be sufficient: its two-part code length is within $b$ bits of the best possible. Let it sit at a kink: every program shorter by $x$ bits beyond a window $w$ fits worse by at least $\sigma x$ bits. Then for every λ ∈ (1, σ) every λ-MAP lies within $[{-w},(b+\kappa)/(\lambda-1)]$ bits of that program's length, fits within explicit slack of it, and is itself sufficient.
     * *Converse.* A MAP length that is stable over an interval of λ occurs only at kinks.
     * *Where kinks occur.* A per-query sample has such a kink at the shortest equivalent program, with steepness linear in $n$ (`thm:recovery:kink`). The full table of a noisy random parity has one for every flip rate below 1/4 once $d$ is large, while the set models of algorithmic statistics have none (`prop:parity:kink`, `prop:parity:range`, `prop:parity:sets`).
   * **Theorem C (informal; the teacher's mistakes)** (`thm:teacher:main`, `prop:teacher:kinks`, `prop:teacher:rates`).
     * Keep the base informal theorem verbatim in its hypotheses and numbers: $p<0.056$, product form, incompressible $S$, uniform inputs, population objective, λ = cn with $c\in(2^{-m},c_{\rm hi})$, the conclusions, 0.199 / 0.274 at $c=10^{-4}$, and below about $2^{-m}$ the memoriser.
     * Phrase it about near-optimal hypotheses. Never say that the good model is "the" selected hypothesis or a hull vertex.
     * Add two sentences:
       * the lower end $2^{-m}$ is the reuse factor: each bit of the error rule serves about $n2^{-m}$ samples, while a bit of noise serves one, which is why errors need λ ∝ n and noise only a fixed λ > 1 (`lem:teacher:reuse` [V-T], `prop:teacher:schedules` [V-T]);
       * asymptotically in $m$, windows exist for every flip rate $p<0.1233$ (`prop:teacher:rates`).
     * Keep the paragraph with the example's sizes and windows.
6. **Contributions** (5–6 bullets, 2–4 lines each, `\cref`s; no catalogue):
   1. *Absorption and private randomness* (`sec:absorb`): `thm:absorb:absorption`, `cor:absorb:nouniversal`, `prop:absorb:price`, `prop:absorb:history`, and `thm:split:shared` (no split with shared randomness).
   2. *Kinks* (`sec:kinks`):
      * the hull characterisation of λ-MAPs on one data set (`lem:setup:hull`);
      * one kink lemma for both threads (`lem:kink:main`);
      * the split on one data set and its converse (`cor:kink:split`, `thm:kink:converse`);
      * a universal member flattens every kink (`prop:kink:universal`).
   3. *Exact recovery* (`sec:recovery`): Theorem A (`thm:recovery:main`, `prop:recovery:lambda1`, `prop:recovery:necessity`); the sample kink (`thm:recovery:kink`); noisy computable functions (`cor:recovery:noisy`); frozen labels and λ = 1 on one data set (`prop:recovery:frozen`, `thm:split:private`, `thm:split:lambda1`).
   4. *The noisy random parity* (`sec:parity`):
      * the product kink and the λ-ranges at every flip rate below 1/4 (`prop:parity:kink`, `prop:parity:range`);
      * no steep set kink (`prop:parity:sets`);
      * the sophistication gap (`prop:algstat:parity`).
   5. *The teacher's mistakes* (`sec:teacher`):
      * the theorem as the kink lemma with right slope $2^{-m}$ (`prop:teacher:kinks`, `thm:teacher:main`);
      * the reuse factor and the schedules (`lem:teacher:reuse`, `prop:teacher:schedules`, `prop:limits:plain`) [V-T];
      * full tables for every $m$ (`cor:teacher:fulltable`);
      * flip rates below 0.1233 (`prop:teacher:sharp`, `prop:teacher:rates`).
   6. *Limits and computable classes* (`sec:limits`, `sec:computable`): `prop:limits:envelope`, `prop:limits:rateblind`, `lem:limits:robust`, `prop:limits:separable`, `prop:related:computable`.
7. **`tab:intro:claims`**, 8–9 rows. Caption: "Questions studied in this paper and where they are answered. Numbers with κ = 0 set the machine constant to 0 and are illustrations." Rows:
   * absorption (keep);
   * **new:** "Does a steeper prior separate a sampler from its fill-ins?". Answer: yes per query, exactly and at class-free rates for fixed λ > 1; with frozen labels no procedure recovers every sampler, and on the queried inputs every λ ≥ 1 identifies.
   * **new:** "What does λ = 1 do?". Answer: on a finite data set, similar posterior weight for the sampler and its fill-ins; per query, the same limit, at a rate that can be exponentially slower.
   * "Against hypothesis length, does the fit change slope at the model?" (rewritten). Answer: yes for product models, and then every λ between the slopes selects it; at every flip rate below 1/4 for the noisy parity; not for set models. Cite `cor:kink:split`, `prop:parity:range`, `prop:parity:sets`.
   * the "vertex" row, rewritten per synthesis §3.3 item 5. Question: "Can the good model of the example be selected for a range of $c$?". Answer: every near-optimal hypothesis knows the model and not the errors, for incompressible rules; not for every rule with the same density and description length (`prop:limits:envelope`).
   * "Must the length coefficient grow with the data?". Answer: for errors yes, since λ ∝ n is needed (reuse factor); for noise no, since a fixed λ > 1 suffices.
   * "Does an absolute bound select the same hypotheses?" (keep).
   * "Is some other pathology present?" (keep).
   * Optionally keep "Is the three-hypothesis calculation realised?". Drop or merge "Has a steeper penalty been studied…".
8. **Scope and reader's guide** (keep the base form, updated).
   * The positive teacher result is proved only for parities, product-form error sets, uniform inputs, incompressible rules, and $p<0.056$ ($p<0.1233$ asymptotically).
   * Exact recovery holds per query.
   * Section map: §3 setting, §4 absorption, §5 kinks, §6 recovery (first reason), §7 the shared instance, §8 teacher (second reason), §9 structured errors, §10 computable classes, §11 discussion.

No "Relation to the author's notes" paragraph. No mention of the notes outside the single footnote.

### 1.4 Related work (`related.tex`, FRONT; 0.75 pp)

* Keep the paragraphs and their labels `rem:related:posteriors`, `rem:related:mdl`, `rem:related:cold`, `rem:related:new`. Shorten "Cold posteriors" and "Novelty".
* Add one paragraph, *Consistency of two-part codes*.
  * "For i.i.d. density estimation with a countable list of densities, two-part (MDL) estimators are studied by \citet{barron1991minimum}."
  * Theorem A(a),(b) is the supervised analogue, for sub-probability kernels, an arbitrary input law and every schedule $\lambda_n=o(n)$, and it identifies the limit as the shortest μ-a.e. equivalent programs.
  * Its proof is the standard argument from Ville's inequality and the strong law; we claim no novelty for it.
  * The contribution is the class-free rate for fixed λ > 1, the λ = 1 contrast and the necessity results (`thm:recovery:main`(c),(d), `prop:recovery:lambda1`, `prop:recovery:necessity`).
  * Never attribute to Barron and Cover a specific theorem: the content is known only through a secondary source (DECISIONS §A8).
* Remove the paragraph "An earlier report" (`rem:related:t5`). W6 inserts its text, with the label, as the opening paragraph of `app:related:t5`. `related.tex` keeps one sentence: "An earlier report \citep[Section~8]{claude2026whatfollows} formalised the proposal for a general imitation channel; \cref{app:related:t5} lists what we re-derive from it."
* `rem:related:new` ("To our knowledge the following are new: …"). Update the list:
  * the absorption contrast;
  * the class-free exact-recovery rates for fixed λ > 1 with the λ = 1 contrast and the necessity results;
  * the kink vocabulary, the converse and the universal-member flattening;
  * the product kink of the noisy parity against set models;
  * the teacher theorem over all hypotheses through list decoding, and its extension below 0.1233;
  * the reuse factor.

  Say explicitly: "The hull–penalty relation itself is elementary convex geometry; the method of `thm:recovery:main`(a),(b) is standard."

### 1.5 Discussion (`discussion.tex`, FRONT; 1.5 pp including acknowledgements and code)

1. **The two reasons, side by side.** A table `tab:discussion:reasons` built from synthesis §4.7, about seven rows:
   * what is discarded;
   * its reuse factor;
   * the model's left steepness;
   * the λ that works;
   * what λ = 1 does;
   * what defeats it;
   * what the learner is.

   Put no numbers in the table.
2. **What counts as one hypothesis** (keep, shortened).
3. **The window and its price** (shortened). The reuse factor explains why λ ∝ n, and the deliberate inconsistency remains.
4. **The gap to realistic errors** (keep the F37 text).
5. **Relation to other work** (keep, shortened).
6. **Open problems:** one numbered list that `\cref`s every question and conjecture of the body:
   * `q:recovery:open`, `q:parity:open`, `q:teacher:open`, `q:limits:open`, `q:absorb:shared`, `q:related:open`, `q:algstat:lsc`;
   * any conditional labels that W5 creates (§3.4).
7. **Acknowledgements and Code and data.** Unchanged, except that `\cref{sec:split:lambda1}` must still resolve. W3 keeps that label.

### 1.6 Paper 1 (FRONT; text only)

* **`paper/sections/steeper.tex`.** Reorder the prose summary as the two reasons, the split first. Add one sentence on exact recovery: "with i.i.d. inputs and a sampler that draws fresh coins at every query, every λ-MAP is eventually a shortest program for the sampler, for fixed λ > 1 at a rate that depends only on λ, the program's length, a margin and the confidence". Keep no number other than 0.056, and keep the footnote.
* **`paper/sections/intro.tex`** (the bullet on `sec:steep`) and **`paper/sections/discussion.tex`** (the paragraph "The companion paper"). The same two reasons, in one sentence each.
* No numbered environment, section or equation may be added or removed in Paper 1.
* After the Paper 1 build, run `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py`. Its last line must be `ALL OK`. Check by hand, against `paper/main.aux`, every Paper 1 citation that it lists as unknown.

### 1.7 `main.tex` (FRONT)

```
\input{sections/intro}
\input{sections/related}
\input{sections/setup}
\input{sections/absorb}
\input{sections/kinks}
\input{sections/recovery}
\input{sections/parity}
\input{sections/teacher}
\input{sections/limits}
\input{sections/computable}
\input{sections/discussion}
...
\appendix
\input{sections/app-setup}
\input{sections/app-absorb}
\input{sections/app-kinks}
\input{sections/app-recovery}
\input{sections/app-split}      % continues the appendix of sec:recovery (no \section)
\input{sections/app-parity}
\input{sections/app-teacher}
\input{sections/app-limits}
\input{sections/app-related}
\ifsfirecord\input{sections/app-verification}\fi
```

`split.tex`, `algstat.tex` and `app-algstat.tex` are no longer input. Their owners leave a one-line comment in them (§2). `\sfirecordfalse` stays.

---

## 2. Section order and file ownership

| § | title (suggested) | main file | appendix file(s) | group |
|---|---|---|---|---|
| 1 | Introduction | `intro.tex` | — | FRONT |
| 2 | Related work | `related.tex` | — | FRONT |
| 3 | Setting: data, hypothesis classes and steeper objectives | `setup.tex` | App A `app-setup.tex` | W1 |
| 4 | What counts as one hypothesis: absorption and private randomness | `absorb.tex` | App B `app-absorb.tex` | W1 |
| 5 | Kinks: the model–randomness split on one data set | `kinks.tex` (new) | App C `app-kinks.tex` (new) | W2 |
| 6 | Exact model recovery from samples | `recovery.tex` (new) | App D `app-recovery.tex` (new) + `app-split.tex` (continuation) | W3 |
| 7 | The noisy random parity: one instance, two readings | `parity.tex` (new) | App E `app-parity.tex` (new) | W4 |
| 8 | The teacher's mistakes: the split at a positive rate | `teacher.tex` | App F `app-teacher.tex` | W5 |
| 9 | When errors have structure: a second kink | `limits.tex` | App G `app-limits.tex` | W6 |
| 10 | Computable hypothesis classes | `computable.tex` | App H `app-related.tex` (with the correspondence with the earlier report) | W6 |
| 11 | Discussion (open problems, acknowledgements, code and data) | `discussion.tex` | — | FRONT |

**Complete ownership** (a writer edits only its own files; this is the only list):
* **W1:** `setup.tex`, `app-setup.tex`, `absorb.tex`, `app-absorb.tex`.
* **W2:** `kinks.tex`, `app-kinks.tex` (both new).
* **W3:** `recovery.tex`, `app-recovery.tex` (both new); `split.tex` (emptied, see below); `app-split.tex` (rewritten as the continuation of App D).
* **W4:** `parity.tex`, `app-parity.tex` (both new); `algstat.tex`, `app-algstat.tex` (sources; emptied at the end).
* **W5:** `teacher.tex`, `app-teacher.tex`.
* **W6:** `limits.tex`, `app-limits.tex`, `computable.tex`, `app-related.tex`.
* **FRONT:**
  * Paper 2: `abstract.tex`, `intro.tex`, `related.tex`, `discussion.tex`, `main.tex`, `preamble.tex`, `bib/*` (with the one-line `core.bib` change mirrored in `paper/bib/core.bib`), `CLAIMS.md`, `OUTLINE.md`;
  * Paper 1: only the text of `paper/sections/steeper.tex` and the companion sentences in `paper/sections/intro.tex` and `discussion.tex`;
  * full builds of both papers.
* `app-verification.tex` is not edited and stays switched off.

**Emptied files.** `split.tex`, `algstat.tex` and `app-algstat.tex` end with exactly one line:
```
% Superseded in the restructure (PLAN.md): content now in recovery.tex / kinks.tex / parity.tex / app-parity.tex. Base: git show dcb3a3a3.
```
* Their owners empty them only after taking what they need. Every writer reads the base with `git show`, never the working file, so emptying early harms no one.
* No file is deleted. No git command that changes repository state is run.

**Appendix titles.** "Proofs for \cref{sec:…} (<short title>)", one `\section` per body section. `app-split.tex` has no `\section`: its first line is a `\subsection`.

**Isolated builds.**
* W1: `./test-section.sh setup app-setup` and `./test-section.sh absorb app-absorb`.
* W2: `./test-section.sh kinks app-kinks`.
* W3: `./test-section.sh recovery app-recovery`, and then `./test-section.sh split app-split`. The script takes one appendix. The second run compiles the emptied `split.tex` with the continuation file, which is enough to catch LaTeX errors there. `app-recovery.tex` must never `\input` `app-split.tex`, because `main.tex` inputs both.
* W4: `./test-section.sh parity app-parity`.
* W5: `./test-section.sh teacher app-teacher`.
* W6: `./test-section.sh limits app-limits` and `./test-section.sh computable app-related`.

---

## 3. Label manifest

**Rules.**
* Every label below has exactly one destination file. Only that file's owner writes it.
* When a label moves, the receiving group inserts it with the **same name**, and the giving group removes it from its file (§3.5).
* No label is renamed.
* An old `sec:`/`app:` label whose section disappears is kept as an **alias**: a second `\label{…}` on the new section, or on the subsection that now holds its content. The base already does this in `computable.tex`.
* Writers may add **new structural labels** (`sec:`, `app:`, `eq:`, `tab:`) and **appendix-only lemma labels** cited only inside their own files. These must use their own prefixes:
  * W1: `setup`, `absorb`;
  * W2: `kink`, `kinks`;
  * W3: `recovery`, `split`;
  * W4: `parity`;
  * W5: `teacher`;
  * W6: `limits`, `computable`, `related`;
  * FRONT: `intro`, `discussion`, `related`.

  Each writer lists them in its log.
* No writer creates a theorem-like label that another group might cite unless it is in §3.3.

### 3.1 Base theorem-like labels (all 86; destination, fate)

"Main" means the main-text section file and "app" the appendix file. Fates:
* *kept*: the statement is unchanged in substance; notation may be updated per §4.
* *shortened*: the same content in fewer words.
* *moved*: a different file.
* *rewritten*: the content changes as described.
* *merged*: another item's content is added.
* *cut*: removed, with the reason given.

| label | base file | destination file | group | fate and instructions |
|---|---|---|---|---|
| `def:setup:data` | setup | `setup.tex` | W1 | **rewritten**: DS, FR, PQ (§4.3) |
| `def:setup:product` | setup | `setup.tex` | W1 | kept; the sentence on "private to each distinct input, not to each query" gains the PQ reading (the per-query likelihood is the program's term in $\Mpq$, Paper 1 Proposition 5.7) |
| `def:setup:shared` | setup | `setup.tex` | W1 | kept |
| `def:setup:class` | setup | `setup.tex` | W1 | kept; the list of observations gains per-query samples $h_n$ for product classes, with $P_\pi(h_n):=\nu_\pi(h_n)$ |
| `def:setup:objectives` | setup | `setup.tex` | W1 | kept; λ is called the "complexity weight" (§4.2); add the per-query likelihood as an allowed $P_\pi$ |
| `lem:setup:basic` | setup | `setup.tex` | W1 | kept |
| `rem:setup:persample` | setup | `setup.tex` | W1 | kept; the pointer to `rem:limits:schedule` stays valid (W5 keeps that label) |
| `lem:setup:coding` | setup | `setup.tex` | W1 | kept; add one sentence: at a $b$-sufficient point it is a right line of slope 1 with offset $b+\kappa$ (forward `\cref{def:kink:kinks,cor:kink:split}`) |
| `lem:setup:hull` | app-setup | **`setup.tex`** (statement); proof in `app-setup.tex` | W1 | **moved and merged** (§3.6): keep items (i)–(iv) with the base numbering (cited as (ii) and (iii) elsewhere); add (v) the data reading (kink Thm 2.1, 2.2) and (vi) duality (kink Prop 2.3); write hypotheses as π, π′ (not $h$) |
| `rem:setup:hullconverse` | app-setup | `app-setup.tex` | W1 | kept (the F43 remark) |
| `eq:absorb:dom` | absorb | `absorb.tex` | W1 | kept |
| `rem:absorb:examples` | absorb | `absorb.tex` | W1 | kept |
| `thm:absorb:absorption` | absorb | `absorb.tex` | W1 | kept; add one sentence after it pointing to `prop:kink:universal` (no left kink steeper than $1+(\ell_U+\kappa_0)/(\alpha-\ell_U)$ beyond $\ell_U$) |
| `rem:absorb:reading` | absorb | `absorb.tex` | W1 | shortened |
| `prop:absorb:pricing` | absorb | `absorb.tex` | W1 | kept (statement; proof in app as now) |
| `cor:absorb:nouniversal` | absorb | `absorb.tex` | W1 | kept |
| `rem:absorb:why` | absorb | `app-absorb.tex` | W1 | **moved** to App B; one sentence in the main text points to it |
| `prop:absorb:price` | absorb | `absorb.tex` | W1 | kept |
| `rem:absorb:wyeth` | absorb | `absorb.tex` | W1 | shortened; its title stays "Answer to the absorption objection"; (i) cites `thm:split:shared`, now in this section |
| `q:absorb:shared` | absorb | `absorb.tex` | W1 | kept (D3) |
| `rem:absorb:condsemi` | app-absorb | `app-absorb.tex` | W1 | kept |
| `prop:absorb:history` | app-absorb | `app-absorb.tex` | W1 | kept; one sentence in the main text |
| `prop:absorb:inputs` | app-absorb | `app-absorb.tex` | W1 | kept |
| `thm:split:shared` | split | **`absorb.tex`** | W1 | **moved**: new subsection "No split with shared randomness" (alias `sec:split:shared`); its proof idea says it is `thm:absorb:absorption`(a) plus one comparison; keep the paragraph "Compare …" (domination of ν and the KL bounds), shortened |
| `ex:split:noisyparity` | app-split | **`app-absorb.tex`** | W1 | **moved** (D2), with the proof of `thm:split:shared` (alias `app:split:shared`) |
| `def:split:setting` | split | **`recovery.tex`** | W3 | **rewritten**: sampler; $\mathcal E,\mathcal E_0,\ell_0,k,k_\nu$; ${\Hel}_\mu$; margins; fill-ins; $\Wdet$ (§4) |
| `lem:split:ville` | split | `recovery.tex` | W3 | kept; scope stated: PQ and every input rule that fixes $x_{n+1}$ before $y_{n+1}$ is drawn (iid Lemma 2.2(c)); optional: the current deficiency $\delta_n$ |
| `thm:split:lambda1` | split | `recovery.tex` | W3 | kept without (iv) (cut with `lem:split:hash`) |
| `thm:split:private` | split | `recovery.tex` | W3 | (i)–(iii) kept for FR and every input rule, λ > 1; **(iv) for every λ ≥ 1** (iid Prop 3.3; proof per `verify-iid.md` §2 item 4) |
| `rem:split:reading` | split | `recovery.tex` | W3 | **rewritten**: what (i)–(iv) give in FR; exact recovery in PQ is `thm:recovery:main`; FR allows no more (`prop:recovery:frozen`) |
| `lem:split:stream` | app-split | `app-split.tex` | W3 | kept; its numbers paragraph drops the hashing comparison, or keeps it in one sentence without a label |
| `lem:split:hash` | app-split | — | — | **cut**. Reason: weaker than `lem:split:stream` at every computed size (32–143 bits against 5.6–8.9); the hashing idea is in Paper 1, Remark B.3. With it, `thm:split:lambda1`(iv) and `app:split:hash` are cut. |
| `prop:split:si` | app-split | `app-split.tex` | W3 | kept |
| `rem:split:siprograms` | app-split | `app-split.tex` | W3 | kept |
| `def:algstat:product` | algstat | **`kinks.tex`** | W2 | **moved**: $\rho_D$ for any point family, $\rho^\times_D$ for $\Hcl{\times}$; $b$-sufficient for any data-set class (product-$b$-sufficient in $\Hcl{\times}$); $\sophx_b$ |
| `prop:algstat:product` | app-algstat | **`kinks.tex`** | W2 | **moved**; statement kept; proof one line from `cor:kink:split`(a), in `app-kinks.tex` |
| `def:algstat:set` | algstat | `parity.tex` | W4 | shortened |
| `prop:algstat:parity` | algstat | `parity.tex` (proof `app-parity.tex`) | W4 | **reduced**: (i) sets (unchanged, same item number); (ii) products, the sophistication bounds of base (ii) and (iv) with their ranges of $b$, without the structure-function cliff (superseded by `prop:parity:kink`); (iii) the gap $d-O(\log d)$ for every $p<1/4$ |
| `rem:algstat:restricted` | algstat | `parity.tex` | W4 | two sentences |
| `rem:algstat:reading` | algstat | `parity.tex` | W4 | kept; cites `cor:kink:split` and `prop:parity:range` for "decisive over product models" |
| `prop:algstat:set` | app-algstat | `app-parity.tex` | W4 | kept; one sentence with a pointer in the main text |
| `rem:algstat:near1` | app-algstat | `app-parity.tex` | W4 | kept |
| `prop:algstat:coarse` | app-algstat | `app-parity.tex` | W4 | kept |
| `q:algstat:lsc` | app-algstat | `app-parity.tex` | W4 | kept |
| `tab:algstat:numbers` | app-algstat | — | — | **cut**. Reason: superseded by the certified λ-ranges of `prop:parity:range` (`tab:parity:ranges`), which bound the λ-MAP and not only the sophistication. With it, `app:algstat:numbers` is cut. |
| `def:teacher:instance` | teacher | **`parity.tex`** | W4 | **moved and generalised** to any rule size $s_0$ (§4.5); with the shortened "Notation" box (no $\psi_c$, $\Phi_1$) |
| `lem:teacher:list` | teacher | **`parity.tex`** (proof `app-parity.tex`) | W4 | moved; statement kept |
| `lem:teacher:floor` | teacher | **`parity.tex`** (proof `app-parity.tex`) | W4 | moved; statement kept |
| `lem:teacher:coding` | teacher | **`parity.tex`** (proof `app-parity.tex`) | W4 | moved; statement kept |
| `lem:teacher:twopart` | teacher | **`parity.tex`** (proof `app-parity.tex`) | W4 | moved; statement kept, (D1) and (D2) as now |
| `lem:teacher:sharpfloor` | app-teacher | **`parity.tex`** (statement; proof `app-parity.tex`) | W4 | moved; statement kept; it must be in the main text because $F^\sharp_t$ enters `prop:parity:kink` |
| `eq:teacher:identity` | app-teacher | `app-parity.tex` | W4 | moved with the proof of `lem:teacher:sharpfloor` |
| `rem:teacher:hanni` | teacher | `teacher.tex` | W5 | shortened: item (1), the hull picture with slopes 100 and 10, kept in full; item (2), the per-sample version, reduced to its rates and window; the "direct computation" sentence kept |
| `thm:teacher:main` | teacher | `teacher.tex` (proof `app-teacher.tex`) | W5 | kept with the base item numbering (o), (i), (ii)(a)–(e), (iii), (iv), which others cite; (ii)(a) gains (a1) of teacher Remark 2.6 [V-T]; the proof of (i), (ii)(b), (ii)(c) becomes `lem:kink:main` via `prop:teacher:kinks`; $\psi_c$ and $\Phi_1$ go from the statement (they may remain as notation in the appendix proof) |
| `rem:teacher:numbers` | teacher | `teacher.tex` | W5 | kept |
| `tab:teacher:numbers` | teacher | `teacher.tex` | W5 | kept |
| `rem:teacher:hypotheses` | teacher | `teacher.tex` | W5 | **rewritten** with the label kept: teacher Table 2.2 (which hypothesis serves which side of the kink); item (4) now points to `prop:teacher:rates`, no longer to `rem:limits:method` |
| `cor:teacher:fulltable` | teacher | `teacher.tex` (proof `app-teacher.tex`) | W5 | **merged**: (i) every $1\le m\le d$, window $\lambda\in(2^{d-m},Nc_{\rm hi})$ (teacher Prop 3.1(a)); (ii) the λ = 1 tie (base (ii), unchanged), with one sentence linking it to `thm:split:lambda1` (both points on a line of slope 1, teacher Prop 2.4(iii)); (iii) the memoriser below $2^{d-m}\theta_m$ (Prop 3.1(b)); the right-line and offset statement of Prop 3.1(c) only if [V-T] verifies it; the $d=20$ window sentence after it, as now |
| `cor:teacher:sampled` | teacher | `teacher.tex` | W5 | kept |
| `q:teacher:open` | teacher | `teacher.tex` | W5 | **updated** (§3.4) |
| `lem:teacher:finite` | app-teacher | `app-teacher.tex` | W5 | kept |
| `ex:teacher:version1` | app-teacher | `app-teacher.tex` | W5 | kept (its "In more detail" paragraph may be shortened) |
| `prop:teacher:concentration` | app-teacher | `app-teacher.tex` | W5 | kept |
| `prop:limits:plain` | limits | **`teacher.tex`** (proof `app-teacher.tex`) | W5 | **moved**; statement kept; the post-statement $9.6\cdot10^{-24}$ sentence kept |
| `rem:limits:schedule` | limits | **`teacher.tex`** | W5 | **moved and rewritten**: a short remark with the label kept, holding the literature sentences (Zhu et al., `rem:related:mdl`), "we do not claim as new …", and the batch-excess sentence; its schedule content is replaced by `prop:teacher:schedules` [V-T] and the reuse factor; if [V-T] fails, keep the base content of the remark |
| `prop:limits:envelope` | limits | `limits.tex` (proof `app-limits.tex`) | W6 | kept; proof of (i) becomes one line from `lem:kink:main`(iv) (teacher Prop 2.1(d)) [V-T: item (iv) of the final form; otherwise keep the base proof]; add the $c_{\rm env}$ reading (teacher Prop 4.1, with its side conditions, final-check row 17) |
| `prop:limits:rateblind` | limits | `limits.tex` (proof `app-limits.tex`) | W6 | kept; (ii) gains the secant reading: (⋆) **implies** that the memoriser's secant from every noise-like level-1 point is at least the coin's (teacher Prop 4.2); its proof shortens |
| `lem:limits:robust` | limits | `limits.tex` (proof `app-limits.tex`) | W6 | kept (statement); the constants $\alpha_0,\beta_0$ keep their names (§4.2) |
| `prop:limits:separable` | limits | `limits.tex` (proof `app-limits.tex`) | W6 | kept (D4) |
| `prop:limits:ood` | limits | `limits.tex` (proof `app-limits.tex`) | W6 | shortened |
| `q:limits:open` | limits | `limits.tex` | W6 | **updated**: (b) is answered in population form asymptotically (`prop:teacher:rates`); remove it and point to `q:teacher:open`; keep (a) and (c) |
| `prop:limits:guard` | app-limits | `app-limits.tex` | W6 | kept, condensed; rename its schema σ to φ (§4.2) |
| `prop:limits:noident` | app-limits | `app-limits.tex` | W6 | kept, condensed |
| `prop:limits:inputlaw` | app-limits | `app-limits.tex` | W6 | kept, condensed |
| `rem:limits:method` | app-limits | — | — | **cut**. Reason: superseded by `prop:teacher:sharp` and `prop:teacher:rates`. What remains of it (level 1 is impossible for $0.1233\le p<1/4$ with the present floors) goes into `q:teacher:open` (W5). With it, `app:limits:method` is cut. Every `\cref` to it must go: `teacher.tex` (W5), `app-teacher.tex` (W5), `limits.tex` (W6). |
| `prop:related:computable` | computable | `computable.tex` | W6 | kept; add part (d): `thm:recovery:main`, `prop:recovery:lambda1` and `thm:recovery:kink` hold in every countable subclass with Kraft weights that contains a program for ν, with "shortest" in the subclass's own code (iid Cor 6.2); (b) may now cite both `thm:split:private` and `thm:recovery:main` |
| `rem:computable:examples` | computable | `computable.tex` | W6 | two sentences |
| `prop:related:computability` | computable | `computable.tex` | W6 | kept |
| `rem:related:nn` | computable | `computable.tex` | W6 | two sentences; may also cite `thm:recovery:main` for countable discretisations (only what iid Cor 6.2 and Def 1.1 cover) |
| `q:related:open` | computable | `computable.tex` | W6 | kept (D3) |
| `rem:related:t5` | related | **`app-related.tex`** | W6 | **moved**: opening paragraph of `app:related:t5`, label on that paragraph; FRONT deletes it from `related.tex` |
| `rem:related:posteriors` | related | `related.tex` | FRONT | kept, shortened |
| `rem:related:mdl` | related | `related.tex` | FRONT | kept |
| `rem:related:cold` | related | `related.tex` | FRONT | shortened |
| `rem:related:new` | related | `related.tex` | FRONT | rewritten (§1.4) |
| `tab:intro:claims` | intro | `intro.tex` | FRONT | rows rewritten (§1.3) |

Count: 86 base labels, including the four cut ones. Every other label has one destination.

### 3.2 Base structural labels (`sec:`, `app:`)

| label | destination | group | note |
|---|---|---|---|
| `sec:intro`, `sec:related`, `sec:related:work`, `sec:discussion`, `sec:discussion:open` | as now | FRONT | |
| `sec:setup`, `sec:setup:hyp`, `sec:setup:classes`, `sec:setup:objectives` | `setup.tex` | W1 | |
| `app:setup`, `app:setup:facts`, `app:setup:hull`, `app:setup:coding` | `app-setup.tex` | W1 | `app:setup:facts` keeps (F1)–(F5) |
| `sec:absorb`, `sec:absorb:shared`, `sec:absorb:private`, `sec:absorb:price`, `sec:absorb:answer` | `absorb.tex` | W1 | |
| `sec:split:shared` | `absorb.tex` (alias on the new subsection) | W1 | |
| `app:absorb`, `app:absorb:examples`, `app:absorb:absorption`, `app:absorb:pricing`, `app:absorb:price`, `app:absorb:history` | `app-absorb.tex` | W1 | |
| `app:split:shared` | `app-absorb.tex` (subsection label) | W1 | proof of `thm:split:shared` |
| `sec:algstat:product` | `kinks.tex` (alias on the subsection with `def:algstat:product`) | W2 | |
| `sec:split` | `recovery.tex` (alias: `\section{…}\label{sec:recovery}\label{sec:split}`) | W3 | |
| `sec:split:setting`, `sec:split:private`, `sec:split:lambda1` | `recovery.tex` (subsections 6.1, 6.6, 6.7) | W3 | `sec:split:lambda1` is cited in the acknowledgements |
| `app:split` | `app-recovery.tex` (alias on its `\section`) | W3 | |
| `app:split:ville`, `app:split:stream`, `app:split:si`, `app:split:private` | `app-split.tex` | W3 | |
| `app:split:hash` | — | — | cut with `lem:split:hash` |
| `sec:algstat`, `sec:algstat:set`, `sec:algstat:parity` | `parity.tex` (aliases on the section and on its subsections) | W4 | |
| `sec:teacher:instance`, `sec:teacher:lemmas` | `parity.tex` | W4 | moved with the instance and the lemmas |
| `app:algstat`, `app:algstat:coarse`, `app:algstat:parity` | `app-parity.tex` (aliases) | W4 | |
| `app:algstat:numbers` | — | — | cut with `tab:algstat:numbers` |
| `app:teacher:list`, `app:teacher:lemmas` | `app-parity.tex` | W4 | moved with the lemma proofs |
| `sec:teacher`, `sec:teacher:hanni`, `sec:teacher:theorem`, `sec:teacher:more` | `teacher.tex` | W5 | |
| `sec:limits:schedule` | `teacher.tex` (alias on the subsection "From noise to errors") | W5 | |
| `app:teacher`, `app:teacher:main`, `app:teacher:computations`, `app:teacher:fulltable`, `app:teacher:sampled`, `app:teacher:version1`, `app:teacher:concentration` | `app-teacher.tex` | W5 | |
| `app:limits:plain` | `app-teacher.tex` | W5 | the proof of `prop:limits:plain` |
| `sec:limits`, `sec:limits:rules`, `sec:limits:other`, `sec:limits:ood` | `limits.tex` | W6 | `sec:limits` gets the new title |
| `app:limits`, `app:limits:robust`, `app:limits:guard`, `app:limits:envelope`, `app:limits:ood` | `app-limits.tex` | W6 | |
| `app:limits:method` | — | — | cut with `rem:limits:method` |
| `sec:computable`, `sec:related:computable` | `computable.tex` | W6 | |
| `app:related`, `app:related:t5` | `app-related.tex` | W6 | |

New section labels: `sec:kinks`, `app:kinks` (W2); `sec:recovery`, `app:recovery` (W3); `sec:parity`, `app:parity` (W4).

### 3.3 New theorem-like labels

Every new environment gets `\status{…}` and `\src{…}` (§7). The column "items" fixes the enumeration, which other groups may cite.

**W1 (`setup.tex`).**

| label | env | content | source | items |
|---|---|---|---|---|
| `rem:setup:objects` | remark | which object; repeats (§4.3) | iid Remark 1.4 (a),(b),(d); teacher §1.0 relations | (a) atomic laws on countable $X$: FR ≠ PQ; (b) distinct inputs: they coincide; (c) shared hypotheses and fresh noise |

**W2 (`kinks.tex`; proofs in `app-kinks.tex`).**

| label | env | content | source | items |
|---|---|---|---|---|
| `def:kink:kinks` | definition | point family; bounded reference point $(\alpha_{\rm r},L_{\rm r})$; left kink (σ, w); right line (τ, g) on a set $\mathcal M$ with least length $\ell_{\mathcal M}$; right secant $s_+$; right kink (τ′, $w_+$) as the window form, with "a right line (τ, g) gives a right kink of flatness τ′ and window $g/(\tau'-\tau)$ for every τ′ > τ" | kink Def 3.1; teacher Def 1.4, Remark 1.3 | — |
| `lem:kink:main` | lemma | the kink lemma: two fits $L'\le L$, $J_c$, $J'_c$, $\Phi(c)$, partition $\mathcal M\sqcup\mathcal N$, left margin $\eta_{\mathcal N}(c)$; data reading ($L=L'=L(\cdot;D)$, $c=\lambda$) and population reading ($L=R$, $L'=R_B$, $c=\lambda/n$) | teacher Lemma 1.1 (final form) [V-T], Remark 1.2 | (i) sandwich; (ii) near-optimal programs lie in $\mathcal M$, with length and fit bounds; (iii) $\eta_{\mathcal N}$ concave; (iv) no right line needed: fit upper bound; (v) the wedge criterion |
| `cor:kink:locate` | corollary | kinks locate the λ-MAPs | kink Thm 3.2(a),(b),(d); Remark 3.2′ | (a) left kink and λ < σ; (b) right kink and λ > τ; (c) zero-window kinks with τ < σ at one point ⟺ a hull vertex whose λ-interval contains (τ, σ); the strict inequalities are needed (the examples of Remark 3.2′, in the proof or after it) |
| `lem:kink:secant` | lemma | lines against secants | teacher Lemma 1.5 [V-T] | (a), (b), (c) as in the record |
| `cor:kink:split` | corollary | the split for one data set, in a hypothesis class of data-set hypotheses | kink Cor 3.3 | (a) right kink at a $b$-sufficient program and the length and fit bounds for λ > 1; (b) with left steepness σ beyond window $w$: two-sided bounds for λ ∈ (1, σ) and $(b+(\lambda-1)w)$-sufficiency |
| `thm:kink:converse` | theorem | stable MAP lengths ⟺ kinks at vertices | kink Thm 3.4 | — |
| `prop:kink:universal` | proposition | a universal member flattens every kink and caps every MAP | kink Prop 3.5, with the correction of `verify-kink.md` §5 ("and, if $\ell_U+\kappa_0>0$, only then") | (i) flattening; (ii) the cap (= `thm:absorb:absorption`(a) on one data set) |
| `rem:kink:reading` | remark | the model keeps the blocks of bits whose edge rate exceeds λ; the split need not be unique; one sentence back to `thm:absorb:absorption` | kink §6, Remark 3.6 | — |

**W3 (`recovery.tex`; proofs in `app-recovery.tex` and `app-split.tex`).**

| label | env | content | source | items |
|---|---|---|---|---|
| `thm:recovery:main` | theorem | Theorem A | iid Thms 3.1, 3.2, 4.1(i)–(iv), (iv′) | (a) the limit, every $1\le\lambda_n=o(n)$; (b) the posteriors, fixed λ ≥ 1 ($\Pi_\lambda$ and $\Pi^\eta$ concentrate on $\mathcal E$ with the prior's shares); (c) every $n$, fixed λ > 1: length bound, fill-in length and fill-in posterior; (d) at each $n$: the free-exponent bound (every λ > 0) and the margin form (λ > 1) |
| `rem:recovery:posterior` | remark | the posteriors concentrate on $\mathcal E$, not on $\mathcal E_0$; "a direct computation …" gives limit share 0.889 of $\mathcal E_0$ at λ = 1.5 with programs of lengths 5 and 7 | iid Thm 3.2; computed i1(C) | — |
| `rem:recovery:method` | remark | method and literature (§1.4 wording); no novelty for (a), (b) | iid §3 "Known" | — |
| `prop:recovery:lambda1` | proposition | λ = 1 | iid Prop 5.1(a),(b),(b′), Prop 4.4(b) upper end | (a) no bound in $(\ell_0,\gamma,\varepsilon)$ at λ = 1 (class $\mathcal C_{k,M}$); (b) the λ = 1 recovery-time bracket in $\mathcal C_k$ (ε < 31/32, $k$ even); (c) for fixed λ > 1 the recovery time in $\mathcal C_k$ is $O(\lambda k/(\lambda-1))$ up to logarithms; then, outside the statement, `tab:recovery:times` and Remark 4.7′ as a remark sentence |
| `tab:recovery:times` | table | exact recovery times at ε = 0.01, $\ell_0\in\{16,24,32,40\}$, λ ∈ {1, 1.1, 1.5, 2, 3} | iid i7(A), verify v4(A) | — |
| `prop:recovery:necessity` | proposition | what is necessary | iid Props 4.2, 4.4(a),(b), Remark 4.5, Prop 4.3 | (a) no sample size from $(\lambda,\ell_0,\varepsilon)$ without a margin; (b) $1/\gamma$ necessary (λ ≥ 2); (c) $1/(\lambda-1)$ necessary up to logarithms; (d) the length bound of `thm:recovery:main`(c) attained; (e) canonical class: $\gamma_{\bar\ell}$ below every computable function |
| `thm:recovery:kink` | theorem | the sample kink (synthesis Theorem C) | kink Lemmas 5.1–5.3, Thm 5.4, Cor 5.7(a),(d) (pq form); iid Lemma 8.1(i)–(iii) | (i) uniform likelihood-ratio bound (C1); (ii) left kink, steepness linear in $n$ (C2); (iii) right kink, window $(\ell_0+\log(1/\varepsilon))/(\tau-1)$, and for all $n$ with δ* (C3); (iv) vertex and λ-MAPs exactly $\mathcal E_0$ (C4); (v) almost surely: linear steepness, and eventually $s_+<1<s_-$ (C5) |
| `rem:recovery:window` | remark | the $\ell_0$ in the window cannot be dropped: excess exactly $k-7$ in $\mathcal C_{k,M}$ | iid Lemma 8.1(iv) | — |
| `cor:recovery:noisy` | corollary | noisy computable functions (PQ) | iid Cor 6.1(i)–(v) | W3 numbers the items; the frozen comparison (vi) goes after the statement as a remark sentence with the exact values (§5.3) |
| `prop:recovery:frozen` | proposition | frozen labels | iid Props 7.5, 7.6(b),(d) | (a) no procedure recovers every sampler (canonical-class form); (b) fill-ins leave the posterior when $\sum_x\beta_x=\infty$; (c) the 10-input example, with probability exactly $1-(63/64)^{10}$ (decimal after the statement) |
| `prop:recovery:beyond` | proposition | adaptive inputs, misspecification, λ = cn | iid Props 7.2(b), 7.3(ii),(iii′), 3.4(a)–(c) | (a) adaptive inputs: a shorter wrong program can win with positive probability; (b) misspecification at fixed λ: "eventually a shortest KL-projection" fails (oscillation in PQ, fill-ins in FR); (c) λ = cn: recovery for $c<c^*$, failure for $c>c^*$ ($c=c^*$ not covered), and in general convergence to $\arg\min(c\ell+R)$ |
| `q:recovery:open` | question | open problems of the split thread | synthesis §6 items 1–6 | (a) a computable recovery-time bound in the canonical class; (b) local margins; (c) joint necessity of $1/(\min(1,\lambda-1)\gamma)$; (d) frozen labels with repeated inputs (evidence growth; identification beyond the run; the right slope at a single frozen data set); (e) misspecification in countable classes |

**W4 (`parity.tex`; proofs in `app-parity.tex`).**

| label | env | content | source | items |
|---|---|---|---|---|
| `prop:parity:kink` | proposition | the full table has a left kink at the good model; the good model is product-$b_0$-sufficient | kink Prop 4.1 | W4 numbers the items |
| `prop:parity:range` | proposition | the λ-range of "parity + noise" | kink Prop 4.2(i) (a)–(g), (ii), Cor 4.3 | (i) under $C_{t_0}(\lambda)$: (a)–(g); (ii) the interval form; (iii) every $p<1/4$, fixed λ > 1, large $d$ (level ≤ 2; level 1 if $p<0.12331$: write the threshold as the explicit crossing condition and put the number after the statement) |
| `tab:parity:ranges` | table | certified λ-ranges | kink k7, corrected per `verify-kink.md` §4.2 | — |
| `prop:parity:sets` | proposition | set models have no steep kink at α ≈ d | kink Prop 4.4 | — |
| `q:parity:open` | question | set kinks in general: is a product kink of steepness σ at α, for a model with a random parameter, always accompanied by a set-model slope ≈ 1 there? | synthesis §6 item 7 | — |

**W5 (`teacher.tex`; proofs in `app-teacher.tex`).**

| label | env | content | source | items |
|---|---|---|---|---|
| `lem:teacher:reuse` [V-T] | lemma | duplication: repeated terms divide λ by $r$ and multiply every threshold by $r$ | teacher Lemma 3.0 | — |
| `prop:teacher:schedules` [V-T] | proposition | which schedules keep the identification | teacher Prop 3.6 (with Prop 3.2(a),(c) as needed) | (a) $\lambda_n/n\to0$: risk 0 eventually, $e=1$; (b) $\lambda_n/n\to\infty$: length ≤ $\ell_{\min}$; (c) $\lambda_n/n$ in a compact subset of the window |
| `prop:teacher:frozen` [V-T] | proposition | frozen noise: reuse factor 1 in FR, $N_n(x)$ in FQ | teacher Prop 3.7 | (a) FR; (b) FQ; (c) FQ on a uniform finite support |
| `prop:teacher:kinks` | proposition | the two kink bounds of the instance | teacher Prop 2.1(a),(b) | (a) left: wedge with apex $(d+\kappa_g,H(p))$, steepness $c_{\rm hi}$, margin $G_1-H(p)$; (b) right line of slope $2^{-m}$ with offset $\Lambda_2/2^m$ and $\ell_{\mathcal M}=d-4-\Lambda_1$ |
| `rem:teacher:selected` | remark | what is selected: the statement concerns the near-optimal set; "the good model is a hull vertex on the whole window" fails in explicit rate codes; the programs selected instead satisfy (ii) | teacher §2.1 ("What is selected"); computed t5(A),(B) | — |
| `prop:teacher:sharp` | proposition | the information charge and the sharper level-≥ 2 bound $\Phi_2^\sharp$; `thm:teacher:main`(i), (ii) hold where $J_g+\epsilon<\Phi_2^\sharp$ | teacher Lemma 5.1, Prop 5.2 | W5 numbers the items |
| `prop:teacher:rates` | proposition | asymptotically, a window for every $p<0.1233$ | teacher Prop 5.3 [V-T for the dependence on computed constants] | state it with explicit conditions on $p$ and $a$ (the crossing conditions that define $p^*$ and $a^*(p)$); the decimals after the statement |
| `tab:teacher:rates` | table | exact windows at $d=100$, $m=20$ for $p\in\{1/16,5/64,3/32,7/64,15/128\}$, κ = 0 and κ = 30 | teacher t6(B), rB7(B) | — |

**W6.**

| label | env | content | source |
|---|---|---|---|
| `rem:limits:hull` (`limits.tex`) | remark | what a hull cannot see: rate, not validity (`prop:limits:separable`); guard erosion, input law and non-identifiability (pointers to `prop:limits:guard`, `prop:limits:inputlaw`, `prop:limits:noident`) | teacher Remark 4.3; base `sec:limits:other` text |

**FRONT.** `tab:discussion:reasons` (table, `discussion.tex`).

### 3.4 Conditional labels and open questions

* **[V-T] labels:** `lem:teacher:reuse`, `prop:teacher:schedules`, `prop:teacher:frozen`, `lem:kink:secant`.
  * They exist only if `verify-teacher.md` gives "verified" or "verified with correction". In the second case, the corrected statement is used.
  * If an item is not verified, the label is not created, the writer says so in its log, and FRONT removes every mention. Before the full build, FRONT greps for each of these labels.
  * Other body writers do not `\cref` [V-T] labels, except W3, which may cite `lem:kink:secant` only in a proof remark that it can drop.
* **`lem:kink:main`** in its final form (real offset $g$, pointwise margin, item (iv)) is also [V-T]. Its label is unconditional. If the final form is not verified, W2 states the refereed original form instead: $g\ge0$, the margin condition $\eta_{\mathcal N}(c)>\epsilon$, item (iv) omitted. W6 then keeps the base proof of `prop:limits:envelope`(i).
* **`q:teacher:open`** (W5), updated:
  * (a) other model classes;
  * (b) the junta case for $0.1233\le p<1/4$: level 1 is impossible with the present floors, and level ≤ 2 is expected (synthesis §6 item 8; a question, or a precise conjecture followed by "We have neither a proof nor a counterexample");
  * (c) near-population constants at realistic sample sizes;
  * (d) sampled junta kinks with unequal cell multiplicities (teacher Prop 3.3(c));
  * (e) schedules whose ratio $\lambda_n/n$ leaves the window infinitely often.

### 3.5 Moves between groups (giver deletes, receiver inserts the same label)

| label(s) | giver (file) | receiver (file) |
|---|---|---|
| `thm:split:shared`, `sec:split:shared` | W3 (`split.tex`, emptied) | W1 (`absorb.tex`) |
| `ex:split:noisyparity`, `app:split:shared` | W3 (`app-split.tex`) | W1 (`app-absorb.tex`) |
| `def:algstat:product`, `sec:algstat:product` | W4 (`algstat.tex`, emptied) | W2 (`kinks.tex`) |
| `prop:algstat:product` | W4 (`app-algstat.tex`, emptied) | W2 (`kinks.tex`; proof in `app-kinks.tex`) |
| `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart`, `sec:teacher:instance`, `sec:teacher:lemmas` | W5 (`teacher.tex`) | W4 (`parity.tex`) |
| `lem:teacher:sharpfloor` | W5 (`app-teacher.tex`) | W4 (`parity.tex`; proof `app-parity.tex`) |
| `eq:teacher:identity`, `app:teacher:list`, `app:teacher:lemmas` | W5 (`app-teacher.tex`) | W4 (`app-parity.tex`) |
| `prop:limits:plain`, `rem:limits:schedule`, `sec:limits:schedule` | W6 (`limits.tex`) | W5 (`teacher.tex`) |
| `app:limits:plain` | W6 (`app-limits.tex`) | W5 (`app-teacher.tex`) |
| `rem:related:t5` | FRONT (`related.tex`) | W6 (`app-related.tex`) |
| the change-of-slope footnote | W4 (`algstat.tex`) | W2 (`kinks.tex`) |

Within a group: `lem:setup:hull` moves `app-setup` → `setup` (W1); `rem:absorb:why` moves `absorb` → `app-absorb` (W1). The base split, algstat, teacher and limits labels move into W3's and W4's new files as listed in §3.1.

Both sides record each move in their logs. During the Write phase a moved label may exist in two working files at once, because givers and receivers work in parallel. The full build after FRONT must show 0 multiply defined labels. FRONT greps the logs to confirm every move.

### 3.6 Cross-reference targets other groups may rely on

These labels, with the item structure fixed in §3.3 and the base item numbering stated in §3.1, are stable. Any other label of another group may be cited only after FRONT's merge.

* **W1:**
  * `def:setup:data` (with (DS), (FR), (PQ) as displayed tags), `rem:setup:objects`, `def:setup:product`, `def:setup:shared`, `def:setup:class`, `def:setup:objectives`, `lem:setup:basic`, `rem:setup:persample`, `lem:setup:coding`, `app:setup:facts` ((F1)–(F5));
  * `lem:setup:hull` (i)–(iv) as in the base, plus (v) and (vi) below;
  * `eq:absorb:dom`, `thm:absorb:absorption` (a)–(d) and (c1)–(c3), `cor:absorb:nouniversal`, `prop:absorb:pricing`, `prop:absorb:price`, `prop:absorb:history`, `prop:absorb:inputs`, `rem:absorb:condsemi`, `rem:absorb:why`, `rem:absorb:wyeth`, `q:absorb:shared`;
  * `thm:split:shared` (i),(ii), `ex:split:noisyparity`, `sec:absorb`.
* **W2:** `sec:kinks`, `def:algstat:product`, `def:kink:kinks`, `lem:kink:main` (i)–(v), `cor:kink:locate` (a)–(c), `cor:kink:split` (a),(b), `prop:algstat:product`, `thm:kink:converse`, `prop:kink:universal` (i),(ii), `rem:kink:reading`.
* **W3:**
  * `sec:recovery` (= `sec:split`), `sec:split:lambda1`, `def:split:setting`, `lem:split:ville`;
  * `thm:recovery:main` (a)–(d), `prop:recovery:lambda1` (a)–(c), `tab:recovery:times`, `prop:recovery:necessity` (a)–(e), `thm:recovery:kink` (i)–(v), `cor:recovery:noisy`, `prop:recovery:frozen` (a)–(c), `prop:recovery:beyond` (a)–(c), `q:recovery:open`;
  * `thm:split:private` (i)–(iv), `thm:split:lambda1` (i)–(iii), `rem:split:reading`, `lem:split:stream`, `prop:split:si`, `rem:split:siprograms`.
* **W4:**
  * `sec:parity` (= `sec:algstat`), `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart` ((D1),(D2)), `lem:teacher:sharpfloor`;
  * `prop:parity:kink`, `prop:parity:range` (i)(a)–(g), (ii), (iii), `tab:parity:ranges`, `prop:parity:sets`;
  * `def:algstat:set`, `prop:algstat:parity` (i)–(iii), `rem:algstat:reading`, `rem:algstat:restricted`, `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc`, `q:parity:open`.
* **W5:**
  * `sec:teacher`, `rem:teacher:hanni`, `prop:limits:plain` (a)–(c), `rem:limits:schedule`, `prop:teacher:kinks` (a),(b);
  * `thm:teacher:main` ((o), (i), (ii)(a)–(e), (iii), (iv)), `rem:teacher:numbers`, `tab:teacher:numbers`, `rem:teacher:hypotheses`, `rem:teacher:selected`;
  * `cor:teacher:fulltable` (i)–(iii), `cor:teacher:sampled`, `lem:teacher:finite`, `ex:teacher:version1`, `prop:teacher:concentration`;
  * `prop:teacher:sharp`, `prop:teacher:rates`, `tab:teacher:rates`, `q:teacher:open` (a)–(e);
  * the [V-T] labels, only after FRONT confirms that they exist.
* **W6:**
  * `sec:limits`, `prop:limits:envelope` (i),(ii), `prop:limits:rateblind` (i)–(iii), `lem:limits:robust`, `prop:limits:separable`, `rem:limits:hull`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw`, `prop:limits:ood`, `q:limits:open`;
  * `sec:computable`, `prop:related:computable` (a)–(d), `prop:related:computability`, `rem:related:nn`, `q:related:open`, `app:related:t5`.

**The merged hull lemma (W1), items (v) and (vi).** Write them in terms of the hull $C$ of the points $(\ell(\pi),L(\pi;D))$, with no structure function; W2 later notes that the lower boundary of $C$ is the graph of the convex minorant $\breve\rho_D$. Hypotheses: a countable family with integer lengths, finitely many points per length, normal $(\lambda,1)$.
* **(v) Data reading.**
  * The vertices are attained by programs of exactly their length.
  * For $\sigma_{i+1}<\lambda<\sigma_i$ the λ-MAPs are exactly the programs at vertex $i$.
  * At λ = σ_i they are the programs on the closed edge, interior collinear points included.
  * The MAP length is nonincreasing in λ.
* **(vi) Duality.** The MAP value $\Phi_D(\lambda)=\min_\pi J_\lambda(\pi;D)$ and the lower boundary are Legendre duals.

---

## 4. Notation and data objects

### 4.1 The notation table (synthesis §1, recommended column, with this plan's decisions)

| object | symbol | defined in | note |
|---|---|---|---|
| least length of a μ-a.e. equivalent program; the set of equivalent programs; the shortest ones | $\ell_0$; $\mathcal E$; $\mathcal E_0$ | `def:split:setting` | **D5**: calligraphic, because $E$ is the teacher's error set and $E_1$ the envelope's cheap region |
| length of a program equal to ν at every input; of a decoder that is a measure where it decodes | $k$; $k_\nu$ | `def:split:setting` | $k$ as in the base (`thm:split:lambda1`, `thm:split:private`); $k_\nu$ only if W3 needs it (iid Lemma 5.2 is not stated) |
| fit of π on an observation $o$; per query; the sampler's own fit (sampled randomness) | $L(\pi;o):=-\log P_\pi(o)$; $L_n(\pi)$; $L_n(\nu)$ | `def:setup:objectives`, `def:split:setting` | $J_\lambda(\pi;o)=\lambda\ell(\pi)+L(\pi;o)$; in FR $L_n(\nu)=-\log\nu(D_n)$, in PQ $-\log\nu(h_n)$ |
| per-query sample | $h_n:=((x_1,y_1),\dots,(x_n,y_n))$ | `def:setup:data` | FR and DS data stay $D$, $D_n$ |
| Ville deficiency; current deficiency | $\delta^*:=\sup_n\log(\xi_{\mathcal C}(h_n)/\nu(h_n))$ (PQ), with $D_n$ in FR; $\delta_n$ | `lem:split:ville` | `verify-kink.md` §2.3: never write $L_n(\nu)$ inside δ* |
| Hellinger gap | ${\Hel}_\mu(\pi):=\Ex_{x\sim\mu}\Hel(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))$ | `def:split:setting` | write `{\Hel}_\mu`, braced (the macro already carries a subscript); $\Hel(P,Q):=1-\sum_y\sqrt{P(y)Q(y)}$ as in the base |
| margins: up to length $\bar\ell$; shorter than $\ell_0$; at length exactly ℓ | $\gamma_{\bar\ell}$; $\gamma_-$; $\gamma_=(\ell)$ | `def:split:setting` | **D5**: lengths are ℓ-letters, never $L$; the margin form of `thm:recovery:main`(d) uses $\bar\ell_\varepsilon:=\lceil(\lambda\ell_0+\log(2/\varepsilon))/(\lambda-1)\rceil$ and $0<\gamma\le\gamma_{\bar\ell_\varepsilon}$; `thm:split:private`(ii) writes its length threshold as $\bar\ell$ |
| the free-exponent affinity | $\mathsf C_s(\pi):=\Ex_\mu\sum_{y:\nu>0}\nu^{1-s}\nu_\pi^s$ | `thm:recovery:main`(d) | **D5**: the synthesis's $\rho_s$ clashes with the structure function in the same section; call it "the Chernoff coefficient" |
| posterior; tempered posterior; limit shares | $\Pi_\lambda$; $\Pi^\eta$; $W_\lambda:=\sum_{\mathcal E}2^{-\lambda\ell}$ | `def:setup:objectives`; `thm:recovery:main`(b) | |
| conditional entropy of the sampler | $H_\mu(\nu):=\Ex_\mu H(\nu(\cdot\mid x))$ | `thm:recovery:main`(c) | |
| λ-threshold of λ = cn | $c^*$ | `prop:recovery:beyond`(c) | |
| structure function; convex minorant; population hull | $\rho_D$ (any point family), $\rho^\times_D$ (class $\Hcl{\times}$); $\breve\rho_D$; $\rho_{\rm pop}$ | `def:algstat:product` | the hull lemma does not need them |
| reference point of a kink | $(\alpha_{\rm r},L_{\rm r})$ | `def:kink:kinks` | **D5**: replaces $(\alpha_0,F_0)$, because $\alpha_0,\beta_0$ are the constants of `lem:limits:robust` (DECISIONS §E) and $F$ is a random function, a floor and a set of functions elsewhere |
| left kink; right line; right secant; right kink (window form); left steepness of a point | (σ, $w$); (τ, $g$); $s_+$; (τ′, $w_+$); $s_-$ | `def:kink:kinks` | $g$ names the offset **only** in `kinks.tex` and `app-kinks.tex`; elsewhere write the instantiated offset ($\ell_0+\delta^*$, $b+\kappa$, $b_0+\kappa$, $\Lambda_2/2^m$), because the integer $g$ of `thm:teacher:main`(e) and of `lem:teacher:sharpfloor` keeps its name |
| partition in the kink lemma; its least length; left margin | $\mathcal M\sqcup\mathcal N$; $\ell_{\mathcal M}$; $\eta_{\mathcal N}(c)$ | `lem:kink:main` | **D5**: $M$ is Solomonoff's mixture, $N=2^d$ and $m$ the rule length; do not write $\mathcal N_\epsilon(c)$ for the near-optimal set: say "the ε-near-optimal programs" |
| fits of the kink lemma | $L'\le L$; $J_c$, $J'_c$, $\Phi(c)$ | `lem:kink:main` | consistent with `rem:setup:persample` ($J_c=c\ell+R$, Φ) in the population reading and with $J_\lambda(\cdot;D)$ in the data reading |
| complexity weight | λ ("complexity weight"; "steeper" for λ > 1) | `def:setup:objectives` | **D5**: "steepness" is reserved for the left kink σ |
| sufficiency | product-$b$-sufficient, $\sophx_b$; $b$-sufficient (any data-set class) | `def:algstat:product` | |
| the good model's sufficiency offset (full table) | $b_0$ with $2\log(d+1)$ | `prop:parity:kink` | literal (F5), synthesis §7.2 |
| combined floors | $\Gamma_t(\lambda)$, $\Gamma^\circ_t$ (parity); $\Psi_t$ (teacher §5 material) | `prop:parity:kink`, `prop:parity:range`; `prop:teacher:sharp` | |
| sharp floor | $F^\sharp_t$ | `lem:teacher:sharpfloor`, `prop:parity:kink` | |
| data objects | PQ, FR, DS; FQ in `sec:teacher` only | `def:setup:data`; `sec:teacher` | §4.3 |
| reuse factor | — (a word) | `sec:teacher` | defined in words, with `lem:teacher:reuse` |
| likelihood ratio | $\Lambda_n(\pi)$ | appendix proofs only | $\Lambda_1,\Lambda_2,\Lambda_3$ are the teacher's slack constants; never write $\Lambda_n$ in a main-text statement |
| schema of guard erosion | φ (was σ) | `prop:limits:guard` | **D5**: σ is the kink steepness |

Unchanged (`paper/NOTATION.md`, base Paper 2):
* $n$ samples, $N=2^d$, $c=\lambda/n$, κ, $\ell^*_\lambda$ (absorption);
* $S$, $S_1$, $S_2$, $E$, $E_1$, $L_S$, $B_S$, $\delta_S$, $L_E$, $\delta_E$;
* lev, $s(t)$, $G_j$, $\theta_t$, $u$, $e$, $I(\pi)$, $\kappa_g$, $\kappa_b$, $\Lambda_1$–$\Lambda_3$, $\Delta(c)$, $\Delta_\ell$, $c_{\rm hi}$, $c_{\rm env}$, $\Phi_2$, $J_g$, $J_b$;
* $t_n$, $d_n$, $\beta_n$ (stream lemma);
* $\Wdet$, $\Mpq$, $\Hcl{\cdot}$.

**No new preamble macro is needed.** Writers must not add one. If one is unavoidable, FRONT adds it to both preambles identically.

### 4.2 Symbol decisions in brief (binding)

1. $\mathcal E,\mathcal E_0$, not $E,E_0$.
2. Reference point $(\alpha_{\rm r},L_{\rm r})$.
3. Partition $\mathcal M\sqcup\mathcal N$, $\ell_{\mathcal M}$, left margin $\eta_{\mathcal N}(c)$.
4. $\mathsf C_s(\pi)$, the Chernoff coefficient.
5. Length caps $\bar\ell$, $\bar\ell_\varepsilon$, margins $\gamma_{\bar\ell}$.
6. The offset $g$ only inside the kink section and its appendix.
7. λ is the "complexity weight"; "steepness" means σ.
8. Hypotheses in the hull lemma are π, π′, $\pi_c$.
9. Guard-erosion schema φ.
10. $\Lambda_n$ only in proofs.

Any other symbol that also has a different meaning in the table above must be renamed locally by its writer and recorded in the log.

### 4.3 The data objects, and the text of `def:setup:data` (W1)

`def:setup:data` must state these objects (wording may be tightened; content binding):

```latex
\begin{definition}[Data]\src{steeper \S1.1; split/iid Defs 1.1, 1.3; split/teacher \S1.0}\label{def:setup:data}
The input set is $X=\{0,1\}^*$; statements about a fixed input length use $\{0,1\}^d\subseteq X$. The label set $Y$ is finite, $|Y|\ge2$. We use three data objects.
\begin{itemize}
\item[(DS)] A \emph{data set} is a finite partial function $D:X\rightharpoonup Y$, with $\dom D=\{x_1,\dots,x_n\}$ ($n$ distinct inputs) and $y_i=D(x_i)$. No probability model is assumed.
\item[(FR)] \emph{Frozen labels.} Inputs $x_1,x_2,\dots$ are chosen by an input rule that fixes each new input before its label is revealed (for example i.i.d.\ from a law $\mu$ on $X$); each distinct input carries one label, drawn once. After $n$ queries the data are the data set $D_n$ of the distinct pairs seen.
\item[(PQ)] \emph{Per-query labels.} The pairs $(x_i,y_i)$ are i.i.d.\ from $\mu\otimes\nu$ for an input law $\mu$ and a probability kernel $\nu$: the label is drawn afresh at every query, also at a repeated input. The data are the sequence $h_n:=((x_1,y_1),\dots,(x_n,y_n))$.
\end{itemize}
On DS and FR a hypothesis is scored by its likelihood of the data set, each distinct input counting once. On PQ a product hypothesis $\nu_\pi$ is scored by $\nu_\pi(h_n):=\prod_{i\le n}\nu_\pi(y_i\mid x_i)$.
\end{definition}
```

`rem:setup:objects` (W1), right after it:
* (a) $X$ is countable, so every input law is atomic, and an i.i.d. input sequence repeats inputs. FR is then a fixed noisy table and PQ a noisy oracle that redraws at each query. They lead to different theorems (`thm:recovery:main` against `prop:recovery:frozen`).
* (b) On distinct inputs, such as sampling without replacement or a full truth table, $\nu_\pi(h_n)=\nu_\pi(D_n)$, so the objects coincide.
* (c) The per-query likelihoods of product hypotheses are the terms of the per-query mixture $\Mpq$ (\citet[Proposition~5.7]{claudeSFI2026fundamentals}). Shared hypotheses are not scored per query: with fresh noise and repeated inputs, random-function SFI has infinite expected loss (\citet[Proposition~5.6]{claudeSFI2026fundamentals}).
* (d) A fourth object, a frozen table counted at every query (FQ), appears only in `sec:teacher`, which defines it.

The base sentence "all noisy data in this paper draw each label once per distinct input (frozen noise)" is deleted. The companion-objects table becomes a paragraph of about four lines.

### 4.4 Teacher-thread object (W5 only)

FQ: a fixed table $F$ (a teacher $y^*$, or a sampler's table drawn once), inputs i.i.d. from μ with repeats, fit $\sum_{i\le n}-\log\nu_\pi(F(x_i)\mid x_i)$. Per sample it tends to the population risk of `rem:setup:persample` with $y^*=F$. For a deterministic teacher, PQ with $P^*=\delta_{y^*}$ is FQ (teacher §1.0). W5 defines FQ in one or two sentences where `prop:teacher:frozen` needs it.

### 4.5 The instance, generalised (W4)

`def:teacher:instance` keeps every base item and adds the general rule size:
* Let $1\le s_0\le2^{m-2}$ be an integer and $p:=s_0/2^m$. Then $\kappa_g:=2\log d+K(p)+\kappa$. This is the convention of kink §4 and teacher §5.
* For $p=2^{-r}$, $K(p)\le2\log r+\kappa$ by (F5) (the difference is absorbed in κ). So $\kappa_g=2\log d+2\log r+\kappa$, as in every number of the base tables, which stay valid.
* Every other constant is unchanged ($\Lambda_1$, $\kappa_b$, $G_j$, $L_S$ do not involve $r$).
* The truncation condition $B\ge\log(1/p)$ stays.
* W4 checks against teacher Prop 5.3 and kink Prop 4.2 that nothing else depends on $p=2^{-r}$, and records the check in its log.
* W5 relies on this generality for `prop:teacher:sharp`, `prop:teacher:rates` and `tab:teacher:rates`.

---

## 5. Statuses of the new main-text results

### 5.1 How to render

* A result printed as proved has `\status{proved}` (or `proved; computed`) and a plain environment.
* `\src{…}` names its record and, for an item checked after the referee round, its verification section. Example: `\src{split/iid Prop 3.3; split/verify-iid \S1.1}`. These calls print nothing (DECISIONS §A2).
* A refuted natural strengthening goes, when it informs the reader, into a remark phrased "The natural strengthening … fails: …". It is never framed as a correction of anyone.

### 5.2 Table

* "Refereed": checked by a sub-track referee in this form.
* "V-I", "V-K": verified in `verify-iid.md`, `verify-kink.md`, at the section given.
* **[V-T]**: depends on `verify-teacher.md`.
* "corr.": use the corrected form given there.

| new label | content | record | status |
|---|---|---|---|
| `thm:recovery:main`(a) | the limit for every $1\le\lambda_n=o(n)$ | iid Thm 3.1 | refereed |
| `thm:recovery:main`(b) | posterior concentration on $\mathcal E$ | iid Thm 3.2 | refereed |
| `thm:recovery:main`(c) | λ > 1, every $n$ | iid Thm 4.1(i)–(iii) | refereed |
| `thm:recovery:main`(d) | free exponent (every λ > 0); margin form (λ > 1) | iid Thm 4.1(iv′), (iv) | (iv′) V-I §1.2 (the main display holds for every λ > 0; the forms with $s=1/\lambda$ need λ ≥ 1); (iv) refereed |
| `rem:recovery:posterior` | concentration on $\mathcal E_0$ fails | iid Thm 3.2, i1(C) | refereed; computed |
| `prop:recovery:lambda1` | λ = 1: no class-free bound; the bracket; λ > 1 upper end | iid Prop 5.1(a),(b),(b′), Prop 4.4(b) | (a), (b) refereed; (b′) V-I §1.4; table computed (i7, V-I v4(A)) |
| Remark 4.7′ (a sentence after `prop:recovery:lambda1`) | what λ > 1 buys in the bound | iid Remark 4.7 | **V-I §1.6, corr.**: only the corrected 4.7′; never "λ = 1 needs $\sum2^{-s\ell}<\infty$", "$Z(s)=\infty$ in $\mathcal C_k$", or "no $(\ell_0,\gamma,\varepsilon)$-bound in $\mathcal C_k$" |
| `prop:recovery:necessity` | (a)–(c), (e) | iid Props 4.2, 4.4(a),(b), 4.3 | refereed |
| `prop:recovery:necessity`(d) | the length bound attained | iid Remark 4.5 | V-I §1.5, corr.: "an integer $k$ and a real λ > 1 with λ(k−2)/(λ−1) ∈ ℕ", $D\ge M$; gap range $5.2\cdot10^{-12}$ to $3.5\cdot10^{-4}$ |
| `thm:recovery:kink`(i)–(iv) | the sample kink (PQ form) | kink Lemmas 5.1–5.3, Thm 5.4; iid Lemma 8.1(i)–(iii) | V-K §2 (the PQ form); iid Lemma 8.1 refereed; write δ* with $\nu(h_n)$ (V-K §2.3) |
| `thm:recovery:kink`(v) | almost surely, linear steepness; λ = 1 strictly inside the kink | kink Cor 5.7(a),(d) | V-K §3 |
| `rem:recovery:window` | excess $k-7$ | iid Lemma 8.1(iv) | V-I §1.7 |
| `cor:recovery:noisy` | noisy computable functions | iid Cor 6.1(i)–(v) | refereed |
| frozen comparison after `cor:recovery:noisy` | Cor 6.1(vi) | iid Cor 6.1(vi) | **V-I §1.10, corr.**: lower bound $(7/8)^{64}$; exact values 0.255, 0.255, 0.204, 0.566 at λ = 1, 1.5, 2, 4 (0.136, 0.136, 0.085, 0.566 in the second class); the corrected "penalised empirical rate" sentence; "eventually, once the table is complete" |
| `prop:recovery:frozen` | frozen labels | iid Props 7.5, 7.6(b),(d) | refereed |
| `thm:split:private`(iv) for λ ≥ 1 | identification on the run | iid Prop 3.3 | V-I §1.1, corr.: hypothesis in the almost-sure form "$\nu_{\pi_\nu}(\text{data}_n)=\nu(\text{data}_n)$ for all $n$"; the proof replaces the confinement by (i) with the supermartingale $Z^L$ and Borel–Cantelli (V-I §2 item 4) |
| `prop:recovery:beyond`(a) | adaptive inputs | iid Prop 7.2(b) | refereed |
| `prop:recovery:beyond`(b) | misspecification | iid Prop 7.3(ii), (iii′) | (ii) refereed; (iii′) V-I §1.8 |
| `prop:recovery:beyond`(c) | λ = cn | iid Prop 3.4(a)–(c) | (a) refereed; (b), (c) V-I §1.3: never "iff"; "provided $J_c(\pi)<\infty$ for some π" |
| `lem:setup:hull`(v),(vi) | the data hull and duality | kink Thms 2.1, 2.2, Prop 2.3 | refereed |
| `def:kink:kinks` | kinks, lines, secants | kink Def 3.1 (revised at the referees' request); teacher Def 1.4 | the definition of right line and secant is [V-T] only as wording; definitions carry no proof |
| `lem:kink:main` | the kink lemma, final form | teacher Lemma 1.1, Remark 1.2 | **[V-T]**; fallback §3.4 |
| `cor:kink:locate` | kinks locate MAPs | kink Thm 3.2; Remark 3.2′ | refereed; Remark 3.2′ V-K §6 |
| `lem:kink:secant` | lines and secants | teacher Lemma 1.5 | **[V-T]** (conditional label) |
| `cor:kink:split` | the split for one data set | kink Cor 3.3 | refereed (in a hypothesis class; the hypothesis "(F1) alone" is withdrawn) |
| `thm:kink:converse` | the converse | kink Thm 3.4 | refereed |
| `prop:kink:universal` | universal member | kink Prop 3.5 | (i) refereed; (ii) V-K §5, corr. ("and, if $\ell_U+\kappa_0>0$, only then") |
| `prop:parity:kink` | the full-table left kink | kink Prop 4.1 | refereed |
| `prop:parity:range`(i)(a)–(f) | under $C_{t_0}(\lambda)$ | kink Prop 4.2(i) | refereed |
| `prop:parity:range`(i)(g) and (ii) | error-label bound; the interval form | kink Prop 4.2 | V-K §4: the proof of (ii) states the three facts (α), (β), (γ) of V-K §4.1, one sentence each; numbers rounded per V-K §4.3 |
| `prop:parity:range`(iii) | every $p<1/4$, large $d$ | kink Cor 4.3 | refereed; the constants 0.05596, 0.12331 and the minimum 0.0187 are computed crossings, so they go after the statement |
| `tab:parity:ranges` | certified ranges | kink k7 | **V-K §4.2, corr.**: print "(1, x]" only where the $G_t$ floors alone satisfy the cell condition (the $p=2^{-10}$ rows); elsewhere print the explicit lower end; lower ends rounded up and upper ends down. Values: $(1,11944.9]$ and sharp $(1,12008.5]$ at $d=20$, κ = 0; $(1,6456.2]$ and sharp $(1,6486.2]$ at $d=20$, κ = 30; $(1,9.978\cdot10^6]$ and sharp $(1,1.0047\cdot10^7]$ at $d=30$, κ = 0; for $p\ne2^{-10}$ use, for example, $[1.00049,4276]$ ($p=1/16$), $[1.00059,6529.7]$ ($p=1/8$), $[1.08656,465.39]$ and $[1.3422,199.8]$ ($p=15/64$, κ = 0 and 30), all at $d=20$; avoid the rows whose lower end is $1+10^{-12}$, or explain them in one sentence |
| `prop:parity:sets` | set models | kink Prop 4.4 | refereed; the code-dependence near λ = 1 (1.36 at $d=30$) is computed and goes after the statement |
| `prop:algstat:parity` (reduced) | sets against products | base | proved (base) |
| `prop:teacher:kinks` | the two kink bounds | teacher Prop 2.1(a),(b) | refereed |
| `thm:teacher:main` proof via the lemma; (a1) in (ii)(a) | | teacher Prop 2.1(c), Remark 2.6 | Prop 2.1 refereed; (a1) **[V-T]** |
| `cor:teacher:fulltable`(i),(iii) | every $m$ | teacher Prop 3.1(a),(b) | refereed; Prop 3.1(c) **[V-T]** |
| `lem:teacher:reuse` | duplication | teacher Lemma 3.0 | **[V-T]** |
| `prop:teacher:schedules` | schedules | teacher Prop 3.6 | **[V-T]** |
| `prop:teacher:frozen` | FR against FQ | teacher Prop 3.7 | **[V-T]** |
| samples paragraph | lower bounds; equal multiplicities | teacher Prop 3.3(a),(b) | proved (refereed checked list); the unequal-multiplicity claim goes to `q:teacher:open`(d) |
| `prop:teacher:sharp` | information charge, $\Phi_2^\sharp$ | teacher Lemma 5.1, Prop 5.2 | refereed |
| `prop:teacher:rates` | asymptotic window for $p<0.1233$ | teacher Prop 5.3 | refereed in the range of referee A's M5; proved given the computed constants $p^*$, $a^*(p)$, **[V-T]**; state it with the explicit crossing conditions in the hypotheses and the decimals after it |
| `tab:teacher:rates` | exact windows | teacher t6(B), rB7(B) | computed; κ = 0 rows are illustrations; the window at $p=1/16$ is open at $2^{-20}$ (final-check row 21) |
| `rem:teacher:selected` | what is selected | teacher §2.1 | computed (t5(A),(B)); phrased as "the natural strengthening fails" |
| `prop:limits:envelope`(i) via the lemma; $c_{\rm env}$ reading | | teacher Prop 2.1(d), Prop 4.1 | Prop 2.1(d) uses Lemma 1.1(iv), **[V-T]**; Prop 4.1 refereed |
| `prop:limits:rateblind`(ii), secant reading | | teacher Prop 4.2 | refereed |
| `prop:related:computable`(d) | subclasses | iid Cor 6.2 | proved |

### 5.3 Rules for verification-dependent material

1. Writers read `verify-iid.md`, `verify-kink.md` and `verify-teacher.md` before writing. `verify-teacher.md` should exist when the Write phase starts.
2. For each item:
   * *verified*: state it as proved;
   * *verified with correction*: state the corrected form only;
   * *not verified*: do not state it as proved. Drop it, or state only what the refereed record supports, and record this in the log.
3. Where a verification report corrects a number, a rounding or a clause, use its value. Examples:
   * V-I §1.10: 0.255, 0.255, 0.204, 0.566;
   * V-K §4.2: the corrected ranges;
   * V-K §4.3: $u\ge0.9912$ ($G$ floor alone), $I\le58.4$ at λ = 2; $u\ge0.9903$, $I\le28.3$, $e\le0.184$ at λ = 105;
   * V-I §1.5: the gap range.
4. If `verify-teacher.md` is missing when a writer starts, that writer still writes every [V-T] item. It records "[V-T pending]" in its log. FRONT rechecks those items against the report before the full build.

---

## 6. Page budgets

Measured on the base: main text 28 pp (title to Code and data), references about 2 pp, appendices 27 pp (A 2, B 4, C 7, D 5, E 4, F 3, G 1.5). The DECISIONS §C hard caps hold: **main ≤ 27, appendices ≤ 27, total ≤ 57**. Budgets are ±0.25 pp per item. A writer over budget cuts its own optional material first (list below).

| part | file | group | budget (pp) | base |
|---|---|---|---|---|
| title, abstract, contents | `main.tex`, `abstract.tex` | FRONT | 1.25 | 1.5 |
| §1 Introduction (with `tab:intro:claims`) | `intro.tex` | FRONT | 2.25 | 2.5 |
| §2 Related work | `related.tex` | FRONT | 0.75 | 1.5 |
| §3 Setting | `setup.tex` | W1 | 2.25 | 2.5–3 |
| §4 Absorption (with `thm:split:shared`) | `absorb.tex` | W1 | 2.25 | 3 |
| §5 Kinks | `kinks.tex` | W2 | 2.25 | new |
| §6 Exact recovery (with λ = 1 and FR) | `recovery.tex` | W3 | 4.75 | split 3 |
| §7 The noisy parity | `parity.tex` | W4 | 2.5 | algstat 2 + the instance and lemmas from teacher |
| §8 The teacher | `teacher.tex` | W5 | 4.75 | 6 |
| §9 Structured errors | `limits.tex` | W6 | 1.75 | 3 |
| §10 Computable classes | `computable.tex` | W6 | 0.5 | 1 |
| §11 Discussion, open problems, acknowledgements, code | `discussion.tex` | FRONT | 1.5 | 1.5–2 |
| **main text** | | | **26.75** | 28 |
| App A Setting | `app-setup.tex` | W1 | 2.5 | 2 |
| App B Absorption (with `rem:absorb:why`, the proof of `thm:split:shared`, `ex:split:noisyparity`) | `app-absorb.tex` | W1 | 3.5 | 4 |
| App C Kinks | `app-kinks.tex` | W2 | 1.75 | new |
| App D Exact recovery | `app-recovery.tex` (5.0) + `app-split.tex` (2.0) | W3 | 7.0 | E 4 |
| App E The noisy parity | `app-parity.tex` | W4 | 3.75 | F 3 + 2 from C |
| App F The teacher | `app-teacher.tex` | W5 | 4.5 | C 7 |
| App G Structured errors | `app-limits.tex` | W6 | 2.75 | D 5 |
| App H Computable classes; the earlier report | `app-related.tex` | W6 | 1.25 | G 1.5 |
| **appendices** | | | **27.0** | 27 |

**Within §6 (W3), as a guide:**
* 6.1 setting 0.5;
* 6.2 Theorem A with two remarks 1.0;
* 6.3 λ = 1 and necessity, with `tab:recovery:times`, 0.9;
* 6.4 the sample kink 0.75;
* 6.5 noisy computable functions 0.5;
* 6.6 frozen labels, adaptive inputs, misspecification 0.6;
* 6.7 λ = 1 on one data set 0.5.

**Within §8 (W5), as a guide:**
* 8.1 from noise to errors 1.0;
* 8.2 the two kink bounds and the theorem 2.0;
* 8.3 full tables and samples 0.75;
* 8.4 flip rates below 0.1233 1.0.

**Optional material, cut first if over budget:**
* W3: the uniform-in-time form of Thm 4.1(v) (appendix remark only, or omit); `prop:recovery:beyond`(b) reduced to (iii′); the posterior-share example.
* W5: the samples paragraph (one sentence); the "In more detail" paragraph of `ex:teacher:version1`; the λ = 105 columns of the full-table table.
* W6: the envelope t3 sentence (lower end 15.0 → 17.1 → 42.7 → 85.3 → empty) (one sentence at most); the three-hypothesis illustration in App G.
* W4: rows of `tab:parity:ranges` beyond six.
* W1: `prop:absorb:inputs` proof detail.

---

## 7. Rules for writers

### 7.1 Sources and method

1. **Write from the base sources and the records.**
   * Read the base with `git -C /home/user/AI-works show dcb3a3a3:solomonoff-function-induction/paper-steeper/sections/<file>`, never from another group's working file.
   * Take new content from the sub-track records (statements and proofs), with the paper's notation (§4). The synthesis is a map, not a source of proofs.
   * The base text already implements the exact texts of DECISIONS §F (for example F31–F36, F39, F41–F45). Where a statement is kept, keep that text. Change it only where this plan says the content changes.
2. **Mathematics: nothing stronger than the records.**
   * Hypotheses, quantifiers and constants are exactly those of the record's statement as verified (§5).
   * If you need a step the record does not contain, do not invent it. Weaken the statement, or ask in the log.
   * Corrections of evident slips (an index, a rounding direction) are allowed when a verification report or the final check names them.
3. **Proofs.**
   * Every main-text result has a 2–6 sentence proof idea, and its full proof in the group's appendix, with a pointer.
   * A proof that is a one-line consequence of the kink lemma says so and gives the instantiation (τ, offset, $\mathcal M$, $\mathcal N$, reference point).
   * Proof sketches are labelled "Proof sketch." and stay remarks (DECISIONS §A1); none is expected in this restructure.
4. **Computed numbers** (DECISIONS §A9).
   * Never inside a theorem-like statement.
   * The sentence after it: "A direct computation (code in the accompanying repository) gives …".
   * κ = 0 numbers say "with the machine constant set to 0 (an illustration)" at first use in each table caption and remark.
   * Certified intervals and bounds are rounded in the safe direction.
   * Never name scripts (i7, k7, t6, rB2 …) or record names in visible text.
   * The numbers of the split thread (recovery times, frozen-table probabilities, posterior shares) concern explicit classes with no machine constant. They are not marked as illustrations (V-I §2 item 7).
5. **Status and source tags.**
   * Keep every base `\status{}`/`\src{}` on the environments you keep.
   * Add both to every new theorem-like environment: `\src{split/iid Thm 3.1}`, `\src{split/kink Thm 3.4}`, `\src{split/teacher Lemma 1.1; split/verify-teacher \S…}`.
   * Status values: `proved`, `proved; computed`, `remark`, `computed; illustration`, `conjecture`, `open`.
   * They print nothing; their content must be rendered in prose where it is not plain "proved" (DECISIONS §A1).
6. **Paper 1 citations.**
   * Cite Paper 1 by number: `\citet[Proposition~5.7]{claudeSFI2026fundamentals}`, with a trailing comment `% P1: prop:learn:perquery`.
   * Take numbers only from `paper/main.aux`. Known: Theorem 3.8, 3.11, Question 3.14, Theorem 4.4, Propositions 4.6, 4.7, Remark 4.8, Theorems 5.1, 5.3, Corollary 5.4, Propositions 5.6, 5.7, Theorem 6.16, Corollary 6.17, Section 7.3, Proposition 8.1, Section 9.1, Theorem 9.10, Proposition 10.1, Question 10.9, Proposition A.10, Remarks B.3, G.11, H.2.
   * List any new one in the log, with its label.

### 7.2 Framing

1. **The two reasons.** The paper gives two reasons for a complexity penalty steeper than the likelihood penalty:
   * *first and main*, the model–randomness split;
   * *second*, not learning a teacher's mistakes.

   Each section's opening paragraph says, in one or two sentences, where it sits:
   * absorption (§4): the precondition for both reasons;
   * kinks (§5): the geometry common to both;
   * recovery (§6): the first reason, with "a theorem that model-plus-noise splits work" in the per-query setting, its rates and its limits;
   * parity (§7): the instance shared by both, its full table being the split at τ = 1;
   * teacher (§8): the second reason, "the split at a positive rate";
   * structured errors (§9): where the second reason fails;
   * computable classes (§10): both reasons survive resource bounds.

   Do not repeat the framing at length; the introduction carries it.
2. **REFRAME.**
   * The paper presents the material for the first time, in the "we" voice.
   * No running-text citation or quotation of `hanni2026notes` or `hanni2026grokking`.
   * No sentence that frames a result as answering, confirming or correcting the notes, a request or anyone's claim.
   * No "the author" in the body (except the title footnote, the acknowledgements, and Eisenstat's "personal communication").
   * No mention of Wyeth. The label `rem:absorb:wyeth` stays; its title is "Answer to the absorption objection".
   * The absorption objection is "a standard point", never attributed to a person.
3. **Footnotes.** Paper 2 may have at most five footnotes crediting the notes. It has two now:
   * the proposal footnote in `intro.tex` (FRONT);
   * the change-of-slope footnote, which moves from `algstat.tex` to `kinks.tex` (W2), text unchanged, attached to the sentence that introduces the change of slope.

   No writer adds another footnote. FRONT may add at most one, only if a definition, question, example or argument that first appeared in the notes is otherwise uncredited. No footnote inside a theorem-like statement or a float.
4. **Process vocabulary** (DECISIONS §A5, plus): none of the following in visible text:
   * track, sub-track, record, synthesis, referee, verifier, verified, post-referee, refereed;
   * iid, kink (as a source name), "teacher record", T1–T3, "Theorem A of the synthesis";
   * the script ids;
   * "refuted as stated", "withdrawn", "corrected", "earlier version", "revision".

   "Theorem A (informal)" etc. are allowed only in the introduction.
5. **Refuted strengthenings** (DECISIONS §A1) are included only where they inform the reader, phrased "The natural strengthening … fails: …". Examples:
   * posteriors on $\mathcal E_0$;
   * "the good model is a vertex on the whole window";
   * "each bit of length buys at most one bit of fit plus δ*";
   * "only λ = cn can stop at the model".
6. **Questions** are `question` environments with precise statements, cited by the discussion's list (DECISIONS §A10). Conjectures are `conjecture` environments, each followed by "We have neither a proof nor a counterexample."
7. **Literature.** Abstract-level content only (DECISIONS §A8, §G4). Barron and Cover: "studied by", no theorem attributed. No new bibliography entries except verified ones, added by FRONT only. In particular there is none for the law of the iterated logarithm, so iid Prop 7.3(v) is not stated (D8).

### 7.3 Files, labels, builds

1. **Edit only your own files** (§2). Delete nothing outside them. A label you give away (§3.5) is removed from your file; a label you receive is inserted with the same name.
2. **Grep before removing a label:** `grep -rn '<label>' sections/` in the working tree. If another group's file cites it, record in your log that the citer must update, unless the label survives elsewhere under the same name (moves keep names, so most citations stay valid). Cut labels (`lem:split:hash`, `rem:limits:method`, `tab:algstat:numbers` and their `app:` subsections) must disappear from every file; each owner removes its own citations.
3. **Never hard-code section or theorem numbers.** Use `\cref`. Use the item structures of §3.3 and §3.6.
4. **Builds.**
   * Run the isolated builds of §2 until they report "OK". Undefined references to other groups are expected.
   * Measure your pages from the isolated build (the bibliography pages excluded).
   * Full builds are FRONT's only: `cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`.
   * No git command that changes repository state.
5. **Log.** Write `research/paper-review/restructure/log-<group>.md` with:
   * what each file now contains;
   * every label it defines, checked against this manifest, with new structural labels marked;
   * every `\cref` to another group's label;
   * every move given or received;
   * every [V-T] item and its outcome;
   * deviations from this plan, with reasons;
   * pages per file;
   * every new Paper 1 citation.

### 7.4 Per-group notes

**W1 (setting, absorption).**
* Setting:
  * the companion-objects table → a paragraph of about four lines;
  * `def:setup:data` and `rem:setup:objects` per §4.3;
  * the merged `lem:setup:hull` per §3.6, its proof in App A from kink Thms 2.1, 2.2, Prop 2.3 and the base proof;
  * the "vertex" sentence before `lem:setup:coding` → "whether every near-optimal hypothesis knows the model and not the errors";
  * one sentence on the coding bound as a right line.
* Absorption:
  * `rem:absorb:why` → App B;
  * add `thm:split:shared` (main) with its "Compare …" paragraph shortened, and its proof (App B). It comes before §6, so define "sampler" in one sentence where it is introduced, in the same words as `def:split:setting` ("a computable conditional measure ν with a program $\pi_\nu$ of length $k$ in the class"), with a forward `\cref{def:split:setting}`;
  * add `ex:split:noisyparity` (App B);
  * one sentence pointing forward to `prop:kink:universal`.

**W2 (kinks).**
* Open with the change of slope, plus the footnote.
* Then `def:algstat:product`, `def:kink:kinks`, `lem:kink:main`, `cor:kink:locate`, `lem:kink:secant` [V-T], `cor:kink:split`, `prop:algstat:product`, `thm:kink:converse`, `prop:kink:universal`, `rem:kink:reading`.
* Note that the lower boundary of the hull of `lem:setup:hull` is the graph of $\breve\rho_D$.
* Give the strictness examples of V-K §6 ($(0,10),(1,5),(2,0)$ and $\{(0,10),(2,0)\}$) in App C or after `cor:kink:locate`.
* The window variant of the right line goes in one sentence of `def:kink:kinks`.

**W3 (recovery).**
* The section is P6, organised as in §6, with `split.tex`'s material placed as in §3.1.
* Rewrite the opening: the base sentence "At λ = 1, Solomonoff induction has no preference between the two" is true at finite $n$ (`thm:split:lambda1`). In the limit, λ = 1 identifies the sampler: exactly in PQ (`thm:recovery:main`(a)), and on the run in FR (`thm:split:private`(iv)).
* `def:split:setting` covers both the per-query setting (class $\mathcal C$ countable with Kraft weights and kernels, μ any law on $X$, ν a probability kernel, $\mathcal E\ne\emptyset$) and the base setting (any input rule, distinct inputs).
* Apply every correction of `verify-iid.md` §2 and `verify-kink.md` §2.3.
* `app-recovery.tex` holds the new proofs:
  * iid Lemmas 2.1–2.2, Thms 3.1, 3.2, Prop 3.4, Thm 4.1, Props 4.2–4.4, Remark 4.5, Prop 5.1;
  * kink Lemmas 5.1–5.3, Thm 5.4, Cor 5.7;
  * iid Lemma 8.1(iv), Cor 6.1, Props 7.2, 7.3 (short), 7.5, 7.6.
* `app-split.tex` holds the base λ = 1 and FR material: the Ville proof (extended to PQ), `lem:split:stream`, `prop:split:si`, the proof of `thm:split:private` with (iv) for λ ≥ 1, and `rem:split:siprograms`.
* `split.tex` is emptied.

**W4 (parity).**
* The section opens with the instance shared by both threads: `def:teacher:instance` (general $s_0$) with the notation box, then the four lemmas and `lem:teacher:sharpfloor` (statements).
* Then the full table ($m=d$): `prop:parity:kink`, `prop:parity:range` with `tab:parity:ranges`.
* Then sets: `def:algstat:set`, `prop:algstat:parity` (reduced), `prop:parity:sets`, `rem:algstat:reading`, `rem:algstat:restricted`, one sentence on `prop:algstat:set`, `q:parity:open`.
* App E holds the proofs: the four lemmas and the sharp floor (from base `app-teacher.tex` §C.1–C.2); kink Props 4.1, 4.2 (with V-K §4.1's three facts), 4.4 and Cor 4.3; `prop:algstat:parity`; and `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc`.
* Empty `algstat.tex` and `app-algstat.tex`.

**W5 (teacher).**
* 8.1 *From noise to errors:*
  * `rem:teacher:hanni` (shortened), `lem:teacher:reuse` [V-T], `prop:limits:plain`, `prop:teacher:schedules` [V-T];
  * `rem:limits:schedule` (short: literature, batch excess);
  * `prop:teacher:frozen` [V-T], with FQ defined here.
* 8.2 *The two kink bounds and the theorem:*
  * `prop:teacher:kinks`;
  * a short display of the theorem's quantities ($\Phi_2$, $J_g$, $J_b$, Δ, $c_{\rm hi}$; no $\psi_c$, $\Phi_1$);
  * `thm:teacher:main`, its proof idea via the lemma;
  * `rem:teacher:numbers`, `tab:teacher:numbers`, `rem:teacher:hypotheses`, `rem:teacher:selected`.
* 8.3 *Full tables and samples:* `cor:teacher:fulltable` (every $m$), one samples paragraph, `cor:teacher:sampled`.
* 8.4 *Flip rates below 0.1233:* `prop:teacher:sharp`, `prop:teacher:rates`, `tab:teacher:rates`, `q:teacher:open`.
* App F holds:
  * the proofs of `prop:teacher:kinks` and `thm:teacher:main` ((i), (ii)(b),(c) via the lemma; (o), (ii)(a),(d),(e), (iii), (iv) as now);
  * the numbers paragraph and the memoriser band;
  * `cor:teacher:fulltable` with the $d=20$ table;
  * `lem:teacher:finite`, `cor:teacher:sampled`, `ex:teacher:version1`, `prop:teacher:concentration`;
  * the proofs of `prop:limits:plain` (label `app:limits:plain`), `lem:teacher:reuse`, `prop:teacher:schedules`, `prop:teacher:frozen`, `prop:teacher:sharp`, `prop:teacher:rates`.
* Never write "the good model is selected" or "is a vertex".

**W6 (structured errors, computable classes).**
* `sec:limits`, new title, opens with "a second kink":
  * `prop:limits:envelope` (with the $c_{\rm env}$ reading) and its numbers paragraph;
  * `prop:limits:rateblind` (secant form), `lem:limits:robust` and its numbers sentence;
  * `prop:limits:separable`, `rem:limits:hull`, `prop:limits:ood`, `q:limits:open`.
* App G: the condensed proofs. `prop:limits:plain` and its proof move to W5. `rem:limits:method` is cut.
* `computable.tex`: per §3.1.
* `app-related.tex`: the proofs; `rem:related:t5` as the opening paragraph of `app:related:t5`; the correspondence table rows updated where a cited label's content moved (labels unchanged).

**FRONT.** §1. After the six logs:
* integrate;
* remove the [V-T] labels that were not created;
* check that every moved label exists exactly once;
* full builds of both papers until clean: 0 errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10 pt;
* page counts against §6;
* the greps of DECISIONS §A2.5, §A5 and §B.6;
* the companion-number check;
* update `CLAIMS.md` and `OUTLINE.md` to the new structure;
* write `log-front.md`.

---

## 8. Checks this plan passed

* Every one of the 86 base theorem-like labels (`grep \label` in the base sections, excluding `sec:`/`app:` and `app-verification.tex`) appears in §3.1 with one destination or a cut reason. All 75 base structural labels appear in §3.2.
* No new label in §3.3 (35 labels) duplicates a base label or another new label.
* The script `research/paper-review/restructure/scratch/plan_check.py` checks both. Run it with `python3 -I` from any directory; it reads the base with `git show` and prints `ALL OK`, as it did for this version. Re-run it after any change to §3.
* The new notation was compiled once against the preamble with no error: braced `{\Hel}_\mu`, $\mathcal E_0$, `\mathsf C_s`, $\eta_{\mathcal N}$, $(\alpha_{\rm r},L_{\rm r})$, `\Mpq`.
* The draft abstract of §1.2 is 1919 characters long.
