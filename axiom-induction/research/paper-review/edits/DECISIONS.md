# Editorial decisions for the revision of "Bayesian Axiom Induction from Instances"

Lead editor's binding decisions after the five reviews in `research/paper-review/` (`review-math-A.md`, `review-math-B.md`, `review-math-C.md`, `review-consistency.md`, `review-readability.md` and their `issues-*.json`).

These decisions bind the four editor groups:
* `front`: abstract, intro, discussion, app-verification, preamble, `main.tex`;
* `model-ident-sound`: model, ident, sound and their appendices;
* `univ-time`: universal, time and their appendices;
* `pa-exp`: pa, experiments and their appendices.

Each group's issue list is `edits/<group>-issues.json`. Rejected reviewer points are in `edits/rejected.json`.

Every fatal and major issue was checked against the sources (track `notes-final.md`, `referee.md`, check outputs, `code/results/`) before a verdict was recorded; §12 lists the verdicts.

Where this file gives exact text (marked **binding text**), use it as given:
* adapting macros, `\cref` targets and line breaks is allowed;
* adding or removing a hypothesis, qualifier or number is not.

Where it gives a canonical wording (§9), every place that states the claim must say the same thing. Each place may be shorter, but must keep the qualifiers.

---

## 1. Rules for editors

1. **Your files only.** Each group edits only its own files (table below) and its own bibliography file. Shared files are `bib/core.bib`, `OUTLINE.md`, `NOTATION.md` and `CLAIMS.md`. Do not edit them, except that the front group syncs `CLAIMS.md` once at the end (rule 11).

   | group | files |
   |---|---|
   | front | `sections/abstract.tex`, `intro.tex`, `discussion.tex`, `app-verification.tex`, `preamble.tex`, `main.tex`, `bib/framing.bib`; optional new `sections/app-notation.tex` |
   | model-ident-sound | `sections/model.tex`, `app-model.tex`, `ident.tex`, `app-ident.tex`, `sound.tex`, `app-sound.tex`, `bib/model.bib`, `bib/ident.bib`, `bib/sound.bib` |
   | univ-time | `sections/universal.tex`, `app-universal.tex`, `time.tex`, `app-time.tex`, `bib/universal.bib`, `bib/time.bib` |
   | pa-exp | `sections/pa.tex`, `app-pa.tex`, `experiments.tex`, `app-experiments.tex`, `bib/pa.bib`, `bib/experiments.bib` |

   Every move decided below stays inside one group's files.

2. **Never rename a label.**
   * Moved material keeps its `\label`, including section labels such as `sec:sound:tri`, which moves to `model.tex`.
   * A label may be added. The new labels are listed in §13.
   * Do not delete a label, except where §3–§5 say so explicitly; none do.

3. **Grep before you delete or move a labelled item.** Run `grep -n '<label>[},]' paper/sections/*.tex` and check that every reference still makes sense after the change. If a reference reads "(Lemma 2.3)" for something that now sits in an appendix, that is fine. If it reads "below" or "in this section", fix it if the file is yours. If the file is another group's, note it in your changelog under "cross-group".

4. **Pointer rule for moves.** When a statement moves to an appendix, keep one sentence in the main text. The sentence names the result, gives its conclusion with all its qualifiers, and `\cref`s it, for example "(The rates of \cref{prop:ident:rates}, in \cref{app:ident:doob}, degenerate for spare templates.)". No caveat may be lost in a move.

5. **Sources only.** The paper's claims come only from:
   * `research/tracks/{model,universal,pa,experiments}/notes-final.md`, their `referee.md` and check outputs;
   * `code/results/*`;
   * the two earlier reports (AS, IL).

   The reviewers' scratch computations (`research/paper-review/scratch/`) may tell you that something is wrong. They are not a source: never quote a number that only a reviewer computed. A corrected number must be recomputable from a source output file or from a formula already in the paper, and you must cite that output. Examples:
   * 3.4–7.5% from the columns of `pa/checks/c6_theorem_data.out`;
   * the misspecified predictions of `tab:ident:c2`, which are the printed values plus (K−1)/2.

6. **Build.** Build only with `flock /tmp/claude-0/paper-build-ai.lock ./build.sh`, run from `paper/`. Check single sections with `./test-section.sh <section> <appendix>`, run under the same lock (`flock /tmp/claude-0/paper-build-ai.lock ./test-section.sh model app-model`), because both scripts rewrite `bib/all.bib`.
   * Undefined references to other groups' sections are expected in `test-section.sh`.
   * The final full build must have no LaTeX errors, no undefined references or citations, no multiply defined labels and no overfull box above 10 pt.

7. **Style** (OUTLINE rule 8).
   * Plain short sentences, with units on every number.
   * No process vocabulary in running text: §6.2.
   * Every theorem-like environment keeps `\status{}` and `\src{}`.
   * `\src` may name tracks, items, referee issues and check scripts. Running text may not (§6.2).

8. **Order of work.** Fatal issues first, then major issues, then the moves for length (§2–§3), then minor issues. Re-measure page counts after the moves (§2).

9. **Changelog.** Each group writes `research/paper-review/edits/<group>-changelog.md` with:
   * per issue id: done, partly done or not done, with a reason;
   * every label moved, added or deleted;
   * every cross-group reference that may need attention;
   * the final page span of each of its sections, measured from `main.aux` as in §2.

10. **Git.** Do not run git commands that change repository state. The orchestrator commits.

11. **Ledger.** After all groups finish, the front group updates `CLAIMS.md` from the changelogs:
    * the section column for moved items;
    * changed statements (§10);
    * changed statuses (§11).

    Nobody else edits `CLAIMS.md`.

---

## 2. Length plan

The main text is now 56 pages (pp. 5–61 of 122): intro 4.7, model 6.5, universal 7.9, ident 6.5, sound 5.9, time 5.9, pa 8.4, experiments 6.6, discussion 3.7. The target is **about 40 pages, with a hard cap of 41.5**.

Targets for the main text, from the start of the section to the start of the next, measured with `grep -E 'newlabel\{sec:(intro|model|univ|ident|sound|time|pa|exp|disc)\}' paper/main.aux`:

| section | now | target | cap | main levers (details §3–§5) |
|---|---|---|---|---|
| 1 intro | 4.7 | **3.5** | 3.75 | short answer box (+0.45); §1.1 cut to a third of a page; verdict table to App. H; answers at ≤2 refs each; contributions merged into the guide |
| 2 model | 6.5 | **5.5** | 5.75 | includes the trichotomy moved from §5 (+0.9); `tab:model:calculi`, `lem:model:a4`, `rem:model:subcrit`, `prop:model:max` and the Elias-γ details to App. A; tightening |
| 3 universal | 7.9 | **6.25** | 6.5 | `tab:univ:odds` to App. B, with `tab:univ:c2` into §3 as the running example; `prop:univ:overspec`, `prop:univ:rkrate`, `lem:univ:survivors`, `rem:univ:kreisel` and the proof of `cor:univ:sound` to App. B; script defaults to App. B; tightening |
| 4 ident | 6.5 | **5.0** | 5.25 | `prop:ident:rates`, `ex:ident:lonedq`, `conj:ident:cder` and `prop:ident:proofs` to App. C; experiment text shortened to its canonical remark; tightening |
| 5 sound | 5.9 | **3.5** | 3.75 | trichotomy to §2 (−1.3); `rem:sound:tight` and the truncation, computable-verifier and refuted parts of `rem:sound:hyp` to App. D; tightening |
| 6 time | 5.9 | **4.5** | 4.75 | `lem:time:symexp`, `prop:time:codelength`, `thm:time:log` and `rem:time:convention` to App. E; summary moved to the front; quotations kept once; tightening |
| 7 pa | 8.4 | **6.5** | 6.75 | details of `def:pa:lsch`, `tab:pa:costs`, `prop:pa:recursion`, `prop:pa:chain`, the code names and the refuted constant-margin remark to App. F; receives `prop:exp:comm` (+0.3); tightening |
| 8 experiments | 6.6 | **2.75** | 3.0 | E1–E8 paragraphs and `tab:exp:e1`, `tab:exp:e2`, `tab:exp:e3a`, `tab:exp:e3b` to App. G; one summary table (+0.6); `rem:exp:refuted` to App. G; `prop:exp:comm` to §7 |
| 9 discussion | 3.7 | **2.5** | 2.75 | §9.1 cut to interpretation only; §9.2 is the one statement of the good version; §9.4 trimmed by about 30% |
| **total** | **56.1** | **40.0** | **41.5** | |

* **Front matter:** `\setcounter{tocdepth}{1}` (front). The table of contents should take one page, so the main text starts on p. 3.
* **Appendices:** they now take 60 pages. The cap is 66.
  * Offset the moves by deleting duplicates (§4): the duplicate proofs, the second copies of refuted items and repeated experiment text.
  * App-experiments absorbs the E1–E8 paragraphs. Do not repeat what `tab:exp:e2seen` and `tab:exp:e4`–`tab:exp:e8` already show.
* **If a section is over its cap after its fixes,** tighten prose before moving any further statement. If it is still over, move secondary remarks (not theorems that answer the question) and record each move in the changelog.

---

## 3. What moves to which appendix

Each move keeps the label and leaves a one-sentence pointer (rule 4).

**§2 model → App. A (`app-model.tex`)**
* `tab:model:calculi`, with the caption fix of C-30. §2 keeps three lines of prose that name the calculi the later sections use.
* `lem:model:a4`, statement and proof idea. One sentence stays in the main text: "∀-elimination is not a template (Lemma A.x), so it belongs to the background calculus".
* `rem:model:subcrit`, a refuted remark: the old condition, the referee's chain and the ρ = 0.75 grammar.
* The Elias-γ and escape details of `def:model:prior`. The definition itself stays, saying only "a prefix code on preorder token sequences; details in App. A".
* `prop:model:max`. The pointer sentence must keep "the maximum can break a tie inside the generator class".

**§2 receives from §5** (same group): the trichotomy subsection, which keeps the label `sec:sound:tri`. It becomes §2.7 "Hänni's trichotomy", right after `sec:model:scores`. Its contents:
* `def:sound:tri`;
* `prop:sound:laws`, `prop:sound:belief`, `prop:sound:bracket`, `ex:sound:renorm`, `ex:sound:fifty`, `prop:sound:fiftyfifty`, `rem:sound:indep`;
* the answers to his three questions, each placed next to its example rather than in a closing paragraph.

`rem:sound:belc` stays in §5. `app:sound:tri` moves to `app-model.tex` with its label.

**§3 universal → App. B**
* `tab:univ:odds`. `thm:univ:odds` now displays the formulas (§10.U3).
* `prop:univ:overspec`.
* `prop:univ:rkrate`, with the waste-lemma paragraph. `lem:univ:waste` and `prop:univ:rk` are already there.
* `lem:univ:survivors` and `rem:univ:kreisel`.
* The proof of `cor:univ:sound`. The statement stays.
* The check-script defaults of l.17 ("Dirichlet α = 1 in checks c2–c7 …"). State α in each table caption instead.

**App. B → §3:** `tab:univ:c2`, the running example of R-04, placed in §3.2 where `tab:univ:odds` was.

**§4 ident → App. C**
* `prop:ident:rates`. The pointer keeps "degenerates for spare templates".
* `ex:ident:lonedq` and `conj:ident:cder`. The pointer reads: "a derivation likelihood does not reliably rescue the axioms: in a truncated equational grammar the best fit is unsound in all 16 settings with p₊ = 0.25 (\cref{ex:ident:lonedq})".
* `prop:ident:proofs`. The pointer reads: "data that come with their proofs identify the instance union of the generator (\cref{prop:ident:proofs})".

**§5 sound → App. D**
* `rem:sound:tight`, with the fix of MA-06.
* From `rem:sound:hyp`: the truncation and computable-verifier sentences, and the two refuted sentences. Items (i)–(iv) stay.
* The trichotomy goes to §2, as above.

**§6 time → App. E**
* `lem:time:symexp`, `prop:time:codelength` and `thm:time:log`. `cor:time:log` stays, preceded by one sentence: "L1's code length counts grammar choices; a tree with ν grammar nodes has conclusions of symbol size at most exponential in ν, and L1 charges at least ζν nats for them (App. E)".
* `rem:time:convention`, with the fixes of MB-12 and MB-20. The pointer sentence: "the constant equivalence needs the semimeasure convention; renormalising at each step gives only 2c bits per step (\cref{rem:time:convention})".

**§7 pa → App. F**
* The details of `def:pa:lsch` and the paragraph after it: the decodable variant, `nd.size` against `dtlib`, and u7. The definition keeps the two-part code, β per written symbol, β_ax (§10.P3), the upper-bound caveat and the Kraft condition (§10.P9).
* `tab:pa:costs`.
* `prop:pa:recursion`, with pointer.
* `prop:pa:chain`, with pointer.
* The code names NAIVE, PC, DPC, SDPC, RDPC and CF, and the G1/G2/G3 and u7 descriptions (R-25).
* The unlabelled "Refuted: a constant margin" remark, as `rem:pa:sdpcrefuted` (a new label).

**§7 receives from §8** (same group): `prop:exp:comm`, placed just before `rem:pa:e6`. Its proof stays in `app:exp:comm`.

**§8 experiments → App. G**
* A new subsection `app:exp:results` ("The experiments in detail") holds the E1–E8 paragraphs and `tab:exp:e1`, `tab:exp:e2`, `tab:exp:e3a`, `tab:exp:e3b`.
* `rem:exp:refuted`.
* The pool-construction details of §8.1.
* The proof idea of `prop:exp:exact`.

§8 keeps:
* the framing (two sentences);
* the implementation (about 0.6 pp);
* `prop:exp:exact`;
* a new summary table `tab:exp:summary`, with columns experiment | setup in one line | result tested | finding | where in the main text;
* `rem:exp:limits`.

---

## 4. Deduplication: one canonical home per item

Elsewhere, cite the canonical home in at most one clause. Do not repeat its numbers.

| material | canonical home | elsewhere |
|---|---|---|
| Hänni's question, verbatim | intro (start) | universal.tex l.8: delete the re-quotation |
| his collapse argument, with the quotations "T(quoted-phi) = accept => phi", "being an axiom of the right form is in fact decidable", "a model of the phis alone …" | time.tex, opening of §6 (shortened; univ-time issue U-13) | intro §1.1: one sentence, no long quotes; discussion §9.3: no re-quote |
| his two variants and "how many of the given statements can be proven … penalize longer proofs" | model.tex §2.6 `sec:model:scores` | intro: one sentence |
| his trichotomy quotes and three questions | the trichotomy subsection, now §2.7 | discussion: one clause |
| his "other ideas" (small subset, mistakes, near misses) | discussion §9.3 | intro: one clause |
| his polytime note | `conj:time:polytime` | discussion: one clause |
| the recommended inducer ("good version") | discussion §9.2 `sec:disc:good` | A1: two lines in words; §3.9: only what is specific to ∀xφ (what the verifier accepts on closed instances, and which filter likelihood) |
| the MDL finding: quotation and conclusion | ident §4.4, the paragraph before `prop:ident:splitlzero` and `rem:ident:mdl`. Open `rem:ident:mdl` with its conclusion | `rem:univ:mdl`: only the ∀xφ-specific split rates, plus a pointer; pa §7.3: no re-quote |
| the collapse summary | `rem:time:summary`, moved to the start of §6 | intro A7, discussion §9.1: the canonical wording §9.6, shortened |
| E1 | universal.tex, the paragraph after `prop:univ:both` | §8 table row; details in App. G |
| E2, identification of PA | `rem:pa:e2` | — |
| E2, false acceptances (5 of 25 seeds, n ≤ 16, the sentences) | `rem:sound:lumps` | `rem:pa:e2` and `tab:ident:misspec`: pointer |
| E3(a) | `rem:ident:e3a` | universal.tex l.189: one clause |
| E3(b) | `rem:pa:e3b` | — |
| E4 | `rem:sound:e4` | — |
| E5 | ident: after `prop:ident:spare` for (a) and (a2), after `prop:ident:gold` for (b) and (c) | — |
| E6 | `rem:pa:e6`, with `prop:exp:comm` now in §7 | `rem:ident:splitsL1`: drop the E6 sentence, keep a pointer |
| E7 (τ and λ) | `rem:time:e7` | `rem:time:links`(iii): one-clause pointer |
| E8 | `rem:ident:e8` | app-ident "E8 windows": delete; the windows go to App. G |
| the c4 misspecified run (2000/2000, median 17) | `ex:ident:escape` | sound.tex l.56, app-sound, app-ident l.201: cite |
| spare costs 19.03 and 19.82 bits | `prop:pa:spare` | app-ident l.152: cite |
| Bel(∀xφ) ≈ 0.69, mostly Inc | `rem:sound:belc` | universal.tex l.150: pointer |
| prior shares 0.03–0.48 | universal §3.5 paragraph and `tab:univ:share` | intro: the range only |
| the affine-slice argument | app-ident, proof of `rem:ident:exact` | app-sound, proof of `rem:sound:vacuous`: pointer plus the C*_d intersection |
| the constant-body argument | app-time, proof of `prop:time:notemplate` | app-pa, proof of `prop:pa:refl`: replace with "as for \cref{prop:time:notemplate}, with Prv_T for Acc_f" |
| "a study of an idea, not a prover" | intro and the discussion's closing paragraph | experiments.tex l.20: "a small exact laboratory" only |
| verdicts on the brief's hypotheses H1–H7 | `tab:intro:verdicts`, moved to `app:ver:process` | intro: one sentence with a pointer |
| results not refereed | `app:ver:process`, one complete list (C-07) | app-ident, app-pa, app-sound: one pointer sentence each, not their own lists |
| refuted first-version claims | `tab:ver:corrections` | main text keeps only the remarks of §5 |

---

## 5. Refuted material in the main text

Keep four refuted items in the main text, each shortened to at most four lines. Each changes what the reader should believe:
* `prop:time:lonesize`: plain L1 does not charge symbol size;
* `rem:univ:openrefuted`: no ω-step without a guard;
* `rem:univ:detour`: the factor c depends on the calculus;
* `rem:ident:exact`: with Dirichlet weights the exact class has mass 0. Its counter-statement is proved and explains why only the instance union is identified.

Also kept: `prop:pa:isigma`(c), refuted, because it is part of a proposition, and the one-line refuted clause of `rem:model:graded` (fixed per MA-03).

Everything else that narrates a first version moves to App. H (`tab:ver:corrections`) or to the group's appendix:
* `rem:model:subcrit` → App. A;
* the refuted sentences of `rem:sound:hyp` → App. D;
* "the model track's first version applied the theorem…" in `rem:sound:vacuous` → delete; the item is in `tab:ver:corrections`;
* pa l.57 "The first version's argument … was wrong" → delete;
* time l.127 "(The pre-referee version let c depend on T; referee m1.)" → delete;
* the last sentence of `sec:pa:answer` → delete;
* the constant-margin remark → App. F as `rem:pa:sdpcrefuted`;
* `rem:exp:refuted` → App. G.

Where a corrected statement depends on a refuted one, leave "(an earlier version claimed more; \cref{app:ver:corrections})".

---

## 6. Notation, naming and terms

### 6.1 Renamings

All groups apply these in their files.

**Do:**
1. Gold's languages L_1 ⊊ L_2 ⊊ … ⊊ L_∞ become `\mathcal L_k`, `\mathcal L_\infty`, so that they cannot be confused with the likelihood names L0, L1, L2. This applies to:
   * `prop:ident:gold`, E5 and `tab:exp:e5`;
   * intro A9;
   * the `tab:intro:verdicts` row;
   * "the L_∞ side" in `prop:pa:isigma`(c) and `tab:ver:corrections`;
   * AS's `T_{L_\infty}` in `tab:pa:dtrc`, which becomes `T_{\mathcal L_\infty}`.

   Retitle `prop:ident:gold` "Gold's limit point $\mathcal L_\infty$ against $\mathcal L_5$".
2. The spare-slot ratio `R_n` of `prop:ident:spare` and `rem:ident:sparetotal` becomes `\mathrm{BF}^{\sigma}_n`, by analogy with `\mathrm{BF}_n` of `prop:ident:splitlone`. `R_m`, `R_k` stay the numeral splits.
3. The 50/50 rule `H(s)` becomes `F_{1/2}(s)` (trichotomy, model-ident-sound).
4. In `rem:sound:lumps`, `R_{1/2}(n,8)` becomes `\Rreg(n,8)` (C-25).
5. `W^*` becomes `W^*_d` everywhere (C-25).
6. In E4 the constant now written `w^*` is not a weight vector, so never write `w^*` for it. This applies to experiments.tex l.142–144, `tab:exp:e4` and `rem:sound:e4`.
   * In (A) it is the prior mass `\pi(T^*)`.
   * In (B, C) it is the pool-version constant `2^{-\mathrm{bits}(T^*)}/(\sum_{T\in H}2^{-\mathrm{bits}(T)}+1)`. Give it a name such as `W^*_{\mathrm{pool}}`.
7. No bare `\log`: use `\log_2` (bits) or `\ln` (nats), and give the unit (C-20).

**Do not:** rename the rule probabilities α_• of L1, the parameter probability ρ of Q_open, the constant c, the query q_t, the channel K or the count L of vacuous quantifiers (rejected, see `rejected.json`). Instead, model-ident-sound adds one sentence after `def:model:lone`: "Subscripted α_• are rule probabilities; the Dirichlet parameter is α or α_τ."

**Optional (front):** a one-page notation table `sections/app-notation.tex` (label `app:notation`), input as the first appendix. It is built from `NOTATION.md` and lists each symbol with its meaning and where it is defined. If it is added, the main text says once, in §1.5, where it is.

### 6.2 Process vocabulary

In running text of the main sections:
* No "track X's …" naming of objects. Name objects by content, for example "the minimal chain calculus C_min", "the forward chain Ch_J", "the two-part natural-deduction code L1^sch", "the experiments' code" (allowed where needed to say which prior code).
* No "the brief's H…", no "referee m…", no "first version / pre-referee" (except as in §5).

Provenance stays in `\src`, in table captions as "(computed: …)", in appendices, and in one sentence of intro §1.5: "The results come from four independently refereed research notes (\cref{app:ver})."

Replace "refutes the brief's H6" by the claim itself, for example "so a penalty on the time to check membership does not price the collapse". This applies in universal.tex l.113, sound.tex l.16 and l.131, time.tex l.104 and l.109, experiments.tex l.164, discussion.tex l.20 and intro.

Check-script names (c2, c8, r6 …) appear only in `\src`, captions and appendices, not in running text (R-29).

### 6.3 Terms defined at first use

Each term gets a one-clause definition the first time it is used in the main text. Where the first use is in intro or abstract, the front group glosses it there too. Wording to use:
* **spare template (spare slot):** "a template beside the generator's own that the data never or rarely use";
* **ω-gap:** "all closed instances φ(0), φ(S0), … together still do not entail ∀xφ (AS §4.5)";
* **motive:** "the formula substituted for P in the induction template";
* **DTRC:** "AS's learner for unlabelled mixtures, which clusters the data by refuting merged templates (AS §7)";
* **anchor:** "a set of data that only the target template covers among its competitors (AS Def 2.6)";
* **KT:** "the Krichevsky–Trofimov estimator, i.e. the Dirichlet(½) predictive rule", in `lem:model:dirsum`;
* **DirMult, Mem(E):** defined in §3 at first use (univ-time), with the DirMult formula given once, in §3 or §4, and cited from the other;
* **SeenQ, Trim:** one sentence where first used in §5 or §7, pointing to §8.1;
* **H_k(DT°), Acc_k:** "theories with at most k templates; the cautious k-union verifier of AS Def 2.6";
* **Q_e:** the elimination-term law of the experiments' chain, in §8.1;
* **T_E, T_N:** in `tab:ident:misspec` and `ex:pa:narrow`, the two induction templates of narrow practice;
* **Q^-:** in `prop:pa:fragments`, any subset of Q1–Q7;
* **pool names** skel k@b, DTRC@b, frag-*, IndSwap: one caption line in `tab:exp:summary` and in App. G.

### 6.4 Citation aliases

The front group sets `\defcitealias{claude2026axiomschemas}{AS}` and `\defcitealias{claude2026whatfollows}{IL}`, wrapped in `\AtBeginDocument{…}` in `preamble.tex` because natbib is loaded after the preamble. The first mention in the intro reads: "AS \citep{claude2026axiomschemas}, on axiom schemas, and IL \citep{claude2026whatfollows}, on inferential learning". The title footnote uses `\citetalias`. Elsewhere keep the plain "AS"/"IL" text.

### 6.5 Abbreviated cross-references inside tables

The front group adds `\crefabbrev` (§7). Every table with a "where" column calls `\crefabbrev` at the start of its float: `tab:ident:misspec`, `tab:intro:verdicts`, `tab:pa:failures`, `tab:model:calculi`, `tab:model:likelihoods`, `tab:exp:summary`. The macro was tested in `research/paper-review/scratch/lead_cref/`. Inside a float group it gives "Prop. 1 and Rem. 2", and outside the float the full names.

---

## 7. Preamble and typography (front; binding code)

In `preamble.tex`, replace the `\status` and `\src` definitions and add the rest. This was tested by the readability reviewer in `scratch/r_build/`: overfull boxes fell from 9 to 1, no superscript dangles, and the main text starts on p. 3 together with tocdepth.

```latex
\setlength{\emergencystretch}{2em}% lets TeX loosen a line instead of overflowing
% \status: upright in every theorem style
\newcommand{\status}[1]{\textup{\textsf{\small[#1]}}}
% \src: small grey upright note, breakable at spaces; a ragged line break may precede it
\newcommand{\src}[1]{\unskip\hskip0pt plus 1fil\penalty300\hskip0.35em plus -1fil\relax\textup{\textcolor{gray}{\scriptsize\textsf{#1}}}}
% neutralise the local line-break hacks of ident.tex, pa.tex, experiments.tex
% (those files use \providecommand, so these definitions win; groups may also delete the uses)
\newcommand{\identbrk}{}\newcommand{\pabrk}{}\newcommand{\expbrk}{}
% abbreviated cross-reference names, for use inside table floats only
\newcommand{\crefabbrev}{\crefname{proposition}{Prop.}{Props.}\crefname{theorem}{Thm.}{Thms.}%
  \crefname{lemma}{Lem.}{Lems.}\crefname{corollary}{Cor.}{Cors.}\crefname{remark}{Rem.}{Rems.}%
  \crefname{example}{Ex.}{Exs.}\crefname{definition}{Def.}{Defs.}\crefname{conjecture}{Conj.}{Conjs.}%
  \crefname{table}{Tab.}{Tabs.}\crefname{section}{\S}{\S\S}\crefname{subsection}{\S}{\S\S}%
  \crefname{appendix}{App.}{Apps.}}
\AtBeginDocument{\defcitealias{claude2026axiomschemas}{AS}\defcitealias{claude2026whatfollows}{IL}}
```

* `main.tex`: `\setcounter{tocdepth}{1}` before `\tableofcontents`.
* intro.tex l.115: "as a grey superscript" becomes "as a small grey note".
* **Status strings in heads** (R-37): at most about 70 characters. When parts differ, the head carries the dominant status, and each exceptional part carries its own `\status{…}` inline, e.g. "(d2) \status{proof sketch}". Assumptions such as "assuming Con(PA)" go into the statement text, not the status.
* **Proof ideas** in §3 use `\begin{proof}[Proof idea] … \end{proof}`, not `\noindent\emph{Proof idea.}` and a manual `\qed` (R-42).
* Fix the tables `tab:sound:constant` and `tab:univ:hyp` as tested (R-36, R-38). The only remaining overfull line, model.tex l.22–23, is R-43.

---

## 8. The introduction: structure, the page-1 answer, and the abstract

### 8.1 Structure of §1

The target is 3.5 pages. Keep all existing labels.

1. **The question, verbatim** (as now).
2. **Short answer** (binding text, §8.2), in a framed box or a `quote` environment, directly after the question.
3. **One framing sentence:** "This paper checks an idea within a precise model; it does not design a prover."
4. **§1.1 `sec:intro:note`** "Hänni's note", at most a third of a page. Give his two variants, the trichotomy, the collapse argument and his move to substitution schemas, his "other ideas" and the polytime note, one sentence each, each with a pointer to where it is treated. Long quotations stay in their canonical homes (§4).
5. **§1.2 `sec:intro:reading`** "The question as we read it, and the model": the three readings, and one paragraph of the model in words, without the variant names L1^σ, L1^sel, L1^sel_cit.
6. **§1.3 `sec:intro:answers`** "Answers", ordered by the question (R-02):
   1. the version (A1, with the good version in two lines and a pointer to `sec:disc:good`);
   2. ∀xφ (A2, A3);
   3. the three refinements: **templates** (new, see below), the derivation-length prior (A8), the time penalty (A7);
   4. his last bullet, as the 3×2 table below;
   5. side results: the verifier (A6, opening with its definition, R-08) and the trichotomy.

   Rules for the answers:
   * at most two `\cref`s each;
   * no symbol the intro has not defined;
   * each answer carries its own key hypothesis ("with data drawn from the model", "in the minimal calculus", "with fixed weights"), and the blanket sentence l.52 is deleted (R-11);
   * every answer uses the canonical wording of §9.

   The **templates** answer: "Templates block his collapse schema but not the collapse (§9.6). They bring the instance schema φ(z) into the class, which is why ∀xφ is never preferred on closed instances. They do not make the posterior see the logical boundary of a schema: a schema and its root split tie at matched weights, and learned weights and usage statistics decide between them (canonical MDL wording, §9.3 and `rem:ident:mdl`)."
7. **§1.4 `sec:intro:contrib`** "What is not achieved", moved up directly after the answers, with C-21's additions. The contributions paragraph is deleted and merged into the guide.
8. **§1.5 `sec:intro:guide`** "Earlier work, method and reader's guide":
   * AS/IL with aliases;
   * one sentence on the four refereed notes and the status/`\src` markers;
   * one line per section;
   * a pointer to the verdict table, which is now in `app:ver:process`.

**The 3×2 table for his last bullet** (binding content; `\crefabbrev` inside):

| | data drawn from a law of the model | human-stated theorems |
|---|---|---|
| the actual axioms | No: inside the generator class the posterior equals the prior, so the actual axioms keep π(T*)/π(C*). Under L1, equivalent axiomatisations with different laws are told apart, and the generating one wins (`cor:ident:prior`, `prop:ident:sep`) | No: it picks up the axioms that are used. Usage decides among equivalent forms, and theorem data are memorised (`sec:pa:answer`) |
| a deductively equivalent system | Yes with fixed weights: the theorem set under L1 with parameters admissible, the instance union under L0. With learned weights, under L0, for almost every weight vector (`cor:ident:deductive`, `thm:ident:limit`) | Not robustly: limits can be weaker or unsound (`tab:ident:misspec`). PA-equivalents win only on broad direct-use practice, within the candidates scored (`sec:pa:answer`) |
| a lot of posterior mass | The actual axioms keep their prior share inside the generator class, which the data never move | Only within the hand-picked candidate sets scored (`sec:pa:answer`) |

### 8.2 The page-1 short answer (binding text)

Each item may carry at most one `\cref`. Plain words; φ(z), ∀xφ and PA may be typeset as math.

> **Short answer.**
> 1. **There is a coherent version.** The prior is 2^(−code length) over finite sets of templates, i.e. schemas such as φ(z) or induction. The likelihood of a datum is the probability that a random derivation process outputs it. The process cites an axiom, fills in its schematic variables at random, and applies modus ponens, generalisation and ∀-elimination. The probability is divided by a normaliser that does not depend on the data.
> 2. **The normaliser does the work.** A theory pays for the probability it spends on sentences that are never observed (the size principle). Your "prove the givens" and "do not contradict" scores have no normaliser, so a consistent strengthening never loses its prior odds under them.
> 3. **From φ(t) to ∀xφ.** Instances push mass off memorisers and off over-general schemas. They do not make ∀xφ more probable than the instance schema φ(z), which is just as simple and implies exactly the data.
> 4. **A derivation likelihood even favours φ(z).** Used as a generator, {∀xφ} mostly states its own axiom: at ∀-elimination rate 0.3, 77% of its output is ∀xφ itself. So each observed instance multiplies its odds against φ(z) by 0.23. (This is proved in the simplest calculus. With a background theory and a selection-aware likelihood the ∀-version can gain through its effective mixture weight, a non-logical effect. With ∧-rules on quantified formulas the direction is open.)
> 5. **So prediction is confirmed, derivability is not.** "All future data are instances" gets posterior probability tending to 1. With data drawn from the model, "the axioms prove ∀xφ" tends to its prior share (3–48% for 0+x=x, depending on the prior code) or to 0. One instance at a free parameter, φ(p), or one quantified datum that entails ∀xφ, does license it.
> 6. **Data drawn from some theory's law with fixed weights:** the posterior concentrates on the theories with that law. Under citation, or a derivation likelihood with parameters, these prove exactly the right theorems: a deductively equivalent system is found. With learned weights this holds under citation for almost every weight vector. The posterior does not find the particular axioms: among theories with the same law, the prior decides.
> 7. **Human-stated theorems are not such data.** In finite classes the posterior then goes to the best-fitting generator, which can be strictly weaker than the axioms behind the data, or unsound. For PA it finds the axioms that are used. PA-equivalents won on direct uses of the axioms under broad usage, within the candidates scored. Narrow or atomic induction practice ended on a weaker theory.
> 8. **"Statements given without proof should be easily derivable"** turns short theorems with long proofs, and frequently used lemmas, into axioms. Under a two-part code, deriving each of six library theorems of PA costs about 6 to 24 times as much as adopting it as an axiom.
> 9. **A time penalty on checking or generating axioms does not stop your collapse:** the collapse sets have polynomial-time membership. Templates block your schema, but over PA one reflection sentence still reproduces every Σ_n-sound assigner on Σ_n sentences. What charges for the collapse is derivation length in written symbols: at least a fixed polynomial root of the assigner's nondeterministic time, infinitely often. For the grammar's own code length only a logarithmic charge is proved.
> 10. **For the trichotomy, keep (belief, plausibility):** renormalising and 50/50 are incoherent in general. All positive guarantees need data drawn from the model. AI referees with independent code checked first versions of the research notes. No human has checked the mathematics.

Numbers check, all from the paper's own sources:
* **items 4 and 5:** in C_min with c = 0.3 and quantifier-free φ under normalised L1, 1/(1+c) = 0.769 and c/(1+c) = 0.231 (`prop:univ:factor`, `tab:univ:odds` row L1). The shares are 0.030–0.484 (`tab:univ:share`).
* **item 8:** the ratio column of `tab:pa:theorems` is 5.8–24.2.

### 8.3 The abstract (binding text; at most 250 words)

> Kaarel Hänni asked whether a Solomonoff-style inducer over axiom systems, with a prior over templates, a preference for short derivations and a time penalty, would pass from instances φ(t) to ∀xφ, and whether it would robustly recover the axioms we actually have, or at least a deductively equivalent system. We make such an inducer precise. Theories are finite sets of templates with a prefix-code prior; the likelihood is a derivation grammar with a data-independent normaliser, so theories predicting unobserved sentences lose a constant factor per datum. First, in the calculi analysed, closed instances never make ∀xφ more probable than its instance schema φ(z), except through non-logical weight effects under a selection-aware likelihood: the odds stay at the prior odds, fall by a constant factor per datum, or drop to zero. "All future data are instances" is confirmed, while "the axioms prove ∀xφ" tends to a prior share or to zero: a Bayesian ω-gap. Second, with data drawn from a theory's law and fixed weights, the posterior concentrates on the theories with that law and identifies their theorems, not their axioms. Third, human-stated theorems are not such data; in finite classes the posterior then goes to the best-fitting generator, which can be weaker than the axioms behind the data, or unsound. Fourth, penalising the time to check or generate axioms does not stop Hänni's collapse of axiom induction into function induction; derivation length in written symbols prices it. AI referees checked first versions; no human has checked the mathematics.

This text fixes C-01, C-04, C-05, C-06 and R-10. C-18 is covered by "tends to a prior share or to zero" being read as the well-specified statement; the front group may add "when the data are drawn from the model" after "zero" if the word count allows.

---

## 9. Canonical wordings of cross-cutting claims

Wherever a claim below is stated (abstract, intro, discussion, section openings, summaries), state it this way, or shorter with the same qualifiers. Section-level statements are in §10.

**9.1 ∀xφ from closed instances** (C-01, MB-01). In every comparison analysed (`thm:univ:B`), closed instances never make ∀xφ more probable than its instance schema σ_φ = φ(z), which implies exactly the instances. The posterior odds:
* stay at the prior odds under citation with the closure reading, the stream-filter likelihood L1^sel, and Hänni's scores;
* fall by a constant factor per datum under derivation likelihoods in the minimal calculus C_min;
* drop to zero under strict citation.

The exceptions are non-logical. With a background theory under L1^sel, the ∀-version has the selected law of the schema version at a different effective mixture weight. At a fixed weight, whichever fits the data's mixture proportion wins. With a learned weight, the ∀-version can gain a bounded factor (`prop:univ:B2`). With ∧-rules on quantified formulas the direction is open (`rem:univ:detour`).

**9.2 Prediction against derivability.**
* "All future data are instances" gets posterior probability tending to 1 (`thm:univ:confirm`).
* With data drawn from a model generator, "the axioms prove ∀xφ" tends to the prior share of provers in the generator class. That share is 0.03–0.48 for 0+x=x, depending on the prior code. The limit is 0 when the generator class has no prover (`thm:univ:omega`).
* When the likelihood ignores how the data were selected, the limit depends on the class (`prop:univ:noguard`, `prop:univ:sentences`).
* One instance at a parameter, or one quantified datum that entails ∀xφ over the background, licenses ∀xφ (`prop:univ:open`, `prop:univ:quant`).

**9.3 Identification** (C-02, C-04).
* With data drawn from a theory's law and fixed weights, the posterior concentrates on the generator class C* = {T : P_T = P_{T*}} and inside it equals the prior (`thm:ident:doob`, `cor:ident:prior`).
* It identifies the instance union of T* under citation (L0) and its theorem set under L1 with parameters admissible (`cor:ident:deductive`). It does not identify the axioms: the actual axioms keep the mass π(T*)/π(C*).
* With learned (Dirichlet) weights the exact generator class has posterior mass 0 (`rem:ident:exact`). Under L0 the instance union is identified for almost every weight vector (`thm:ident:limit`(b)).
* Under a selection-aware likelihood only the reported part of the theorem set is identified (`thm:univ:omega`(b)).
* **MDL** (C-13): a derivation likelihood does not change the MDL finding of AS. A schema and its root split tie at matched weights and differ by Occam terms with learned weights. The split wins linearly when the instantiation grammar misfits the usage. So the posterior tracks usage, not the logical boundary of a schema (`rem:ident:mdl`).

**9.4 Misspecification** (C-05). Human-stated theorems are not draws from a law of the model. In finite classes the posterior then concentrates on the best-fitting generators (KL-minimisers; `thm:ident:kl`), which can be strictly weaker than the axioms behind the data, or unsound (`tab:ident:misspec`). In the full template class even this picture can fail (`rem:ident:fullclass`, a conjecture with a computed illustration).

**9.5 Soundness of the verifier** (C-08, C-09). Used as a proof checker, the posterior accepts a sentence when theories deriving it carry at least 1−δ of the mass.
* With fixed weights and data drawn from the model, no adaptive prover ever gets a non-theorem accepted, with probability at least 1 − δ/π(C*_d), uniformly in time (`thm:sound:fixed`).
* With learned (Dirichlet) weights this holds on average over the weight prior (`thm:sound:avg`).
* For likelihoods linear in the weights (citation, and the experiments' chain), it also holds at each weight vector with a threshold that shrinks with n (`thm:sound:shrink`). A constant threshold can fail (`ex:sound:constant`).
* For a general derivation-grammar likelihood with learned weights, only the averaged guarantee is proved.
* Misspecified, there is no guarantee. In an example a waiting prover wins with probability 1 (`prop:sound:misspec`); in others the verifier is merely incomplete.

**9.6 Time penalties and the collapse** (C-03, C-11, C-12, MB-04–MB-07).
* A penalty on the time to check or generate axioms does not stop Hänni's collapse: Craig's collapse sets have membership decidable in polynomial time (`prop:time:cheap`).
* Templates block his schema (`prop:time:notemplate`). But over PA one ground reflection sentence reproduces every Σ_n-sound assigner on Σ_n sentences, at a cost linear in the assigner's length (`prop:time:collapse`). For merely consistent assigners this route can fail, and whether templates block the collapse for them is open.
* What prices the collapse is derivation size in written symbols. For every polynomial bound on membership time there is a decidable hard assigner (one for all finite DT° theories) that forces every theory within that bound to use, infinitely often, derivations whose size is at least a fixed polynomial root of the assigner's nondeterministic time (`thm:time:ntime`, `cor:time:hard`). L1^σ and Hänni's normalised graded score charge this per datum (`prop:time:sigma`).
* The collapse constructions through Craig's sets and the two-sorted schema pay at most a polynomial of the deterministic time (proof sketch, `rem:time:upper`).
* For plain L1 only a charge of about the logarithm of the nondeterministic time is proved (`cor:time:log`). A polynomial charge is conjectured (`conj:time:poly`).

Never write "plain L1 is proved to charge only logarithmically"; it reads as an upper bound. Never write "between its nondeterministic and deterministic time" without "a polynomial root of".

**9.7 PA** (C11).
* The inducer does not robustly pick up the textbook axioms; it picks up the axioms that are used.
* Nearly all mass goes to theories deductively equivalent to PA under three conditions:
  * the data are direct uses of axioms under the broad usage laws scored (usage mixes of equivalent forms, G1 practice, connective-rich motives);
  * every needed axiom has been cited;
  * the theories compared are the hand-picked candidate sets and pools that were scored.
* Narrow or atomic induction practice ends on a strictly weaker theory (`ex:pa:narrow`, `prop:pa:atomic`).
* On theorem data a two-part code memorises (`prop:pa:memo`).

**9.8 The derivation-length prior.**
* Read as a generative derivation grammar with a data-independent normaliser, it gives the size principle that Hänni's scores lack.
* Read as "statements given without proof should be easily derivable", it makes the data theorems. A derivation likelihood then favours the theory that makes the data cheap to state.
  * Under a two-part code, deriving each of six library theorems of PA in Q+Ind costs about 6 to 24 times as much as adopting it as an axiom (`prop:pa:memo`, `tab:pa:theorems`).
  * Frequently used lemmas become axioms (`prop:univ:quant`(c), `rem:pa:streams`).
  * The generator wins when the data come from its own derivation process under the full-sum L1 (`prop:pa:gibbs`, `prop:pa:wellspec`), or when the data use its schemas directly.

**9.9 Provenance** (C-06). AI referees with independent code checked the first versions of the four research notes. Results added in revision were checked only by their tracks and by the section writers (`app:ver`). No human has checked the mathematics; nothing is checked in a proof assistant.

**9.10 Trichotomy.**
* Hänni's triple (true, false, independent) is (Bel, Dis, Indep).
* Bel is a belief function and Pl = 1 − Dis its plausibility: a coherent lower and upper probability (`prop:sound:belief`, `prop:sound:bracket`).
* Renormalising away the independent part, and splitting it 50/50, are incoherent in general (`ex:sound:renorm`, `ex:sound:fifty`). The 50/50 rule is coherent iff every theory of positive mass has at most two models (`prop:sound:fiftyfifty`).

**9.11 Computability** (R-20). The likelihood of a theory is a computable real whose positivity is undecidable (`prop:model:compute`). The citation likelihood, its Dirichlet sum and the experiments' two-step chain are computed exactly over finite pools (`prop:exp:exact`).

---

## 10. Results whose statements must change (exact new statements)

The LaTeX below is **binding text**. The ids in parentheses are the reviewer issues it resolves; the group issue files cite these subsections as §10.F1, §10.M1, §10.U1, §10.P1 and so on.

### front

**F1 (C-02).** `tab:intro:verdicts`, row H2, which moves to `app:ver:process`:
* verdict cell: "confirmed for fixed weights; with Dirichlet weights the exact class has mass $0$ (\cref{rem:ident:exact}) and the instance union is identified for a.e.\ weight vector under \Lzero{} (\cref{thm:ident:limit}(b)); KL-minimisers for finite classes only";
* where cell: `\cref{thm:ident:doob,rem:ident:exact,thm:ident:limit,thm:ident:kl}`.

Row H7, verdict cell: "usage decides; no consistent r.e.\ theory survives $\Th(\N)$, and inconsistent ones are refuted only at growing depth; narrow practice can end weaker; ten robust failures" (C-14).

Row H4(a), where cell: `\cref{thm:univ:size,prop:univ:memo}` (C-19).

Row H5: "spares cost $\approx\tfrac12\log_2n$ bits with Dirichlet($\tfrac12$) weights" (C-20).

**F2 (C-03, C-11, C-12).** Replace A7 with the canonical wording §9.6, shortened: two or three sentences, keeping "Σ_n-sound", "over PA", "polynomial root", "logarithmic charge proved" and "conjectured".

**F3 (R-20).** In discussion §9.1 "Templates", replace the sentence "Inside the class membership is matching, so likelihoods can be computed exactly over a pool (\cref{prop:exp:exact})" with:
"Inside the class membership is matching, so the citation likelihood, its Dirichlet sum and the experiments' two-step chain can be computed exactly over a pool (\cref{prop:exp:exact}); the general derivation likelihood is only a computable real whose positivity is undecidable (\cref{prop:model:compute})."

**F4 (C-10, C-09).** In discussion §9.2, "Output" and "What it can promise" must be scoped to the component each guarantee needs:
"\emph{What it can promise}, when the data are drawn from a law of the model: concentration on the generator class and convergence of predictions (\cref{thm:ident:doob,thm:ident:predded}); with plain $\Lone$ (parameters admissible) identification of the theorem set, with $\Lzero$ of the instance union, and with a selection model only of the reported part $\Th(T)\cap S$, deductive questions beyond $S$ keeping their prior share (\cref{cor:ident:deductive,thm:univ:omega}); no bound on the number of templates and a way around Gold's theorem (\cref{thm:ident:limit,prop:ident:gold}); soundness of the verifier with probability $1-\delta/\pi(C^*_d)$ for fixed weights, on average over learned weights, and with a shrinking threshold at each weight vector for likelihoods linear in the weights; for a derivation-grammar likelihood with learned weights only the averaged version is proved (\cref{thm:sound:fixed,thm:sound:avg,thm:sound:shrink})."

In "Output", replace "with a threshold that shrinks with $n$ when the weights are learned (\cref{thm:sound:shrink})" by "with a threshold that shrinks with $n$ when the weights are learned and the likelihood is linear in them (\cref{thm:sound:shrink}); otherwise with the averaged guarantee (\cref{thm:sound:avg})".

**F5 (C-15).** In discussion "What it cannot promise", replace "It removes a false spare sentence only polynomially (…) and an inconsistent theory only by refutation (…)." with:
"With learned weights it removes a false spare sentence, and with it the inconsistent theory $T^*\cup\{\sigma\}$, only polynomially (\cref{prop:ident:spare,rem:ident:sparetotal}): the likelihood charges a theory for the mass it spends off the data, not for being inconsistent (\cref{prop:pa:incons}), so certifying consistency needs refutation at growing depth (\cref{prop:pa:refute})."

### model-ident-sound

**M1 (MA-02, MA-26).** In `def:model:scores`, replace the last two sentences ("Track universal's … $\varepsilon\to0$ moves towards $\Sprove$.") with:
"For $\beta>1$, the score $S_{\mathrm{nc},\beta}$ of \cref{sec:univ} equals $\beta^n\Sg$ with $g\equiv1$ on provable data and $g_\infty=1/\beta$; $S_{\mathrm{nc},1}=\Snc$. The noisy likelihood $\Leps$ (\cref{def:model:variants}) is related but not equal: at $\varepsilon=1$ it is $\mu_0(D)\prod_{s\in D}[T\nvdash_k\neg s]$, a per-datum, bounded-search relaxation of $\Snc$ on positive data, which equals $\Snc$ up to the common factor $\mu_0(D)$ only when joint consistency of $T\cup D$ reduces to non-refutation of each datum within $k$ steps; as $\varepsilon\to0$ it tends to the generative $P_T$, whose support ($\Lone$, parameters admissible) is $\Th(T)$."

**M2 (MA-01).** In sound.tex l.131, replace the sentence "In (C1) the verifier is sound for the data's actual generator (a two-schema theory with fixed weights, covered by \Cref{thm:sound:shrink}) and unsound for the intended $T^*$, as the brief's H2 anticipated." with:
"In (C1) the data's actual generator is a two-schema theory with fixed weights $(0.9,0.1)$, and the queries first accepted, $0+0=1$ and $2+0=3$, are theorems of it: the verifier is unsound only relative to the intended $T^*$, since nothing forces the best-fitting generator to be the actual axioms. \Cref{thm:sound:shrink} would cover a verifier with its shrinking threshold on that generator, not the constant-threshold verifier used in E4."

**M3 (MA-06).** `rem:sound:tight`, now in App. D. Replace the parenthesis with:
"(under $\Lzero$, $\operatorname{supp}P_{T'}\subseteq\operatorname{supp}P_{T^*}$ implies $\Th_d(T')\subseteq\Th_d(T^*)$ for every $d$; under $\Lone$ with parameters admissible it does so for $d=\infty$ only: $T^*=\{a,a\to b\}$ and $T'=T^*\cup\{b\}$ have the same support, but $b\in\Th_{|b|}(T')\setminus\Th_{|b|}(T^*)$)"
Restrict the appendix proof's "under \Lone" sentence the same way.

**M4 (MA-05).** `rem:sound:vacuous`: begin with "Under $\Lzero$, or any likelihood affine in $w$ (such as the experiments' chain $\Cch J$), read …". Add at the end: "Under $\Lone$, where $P_{T,w}$ is a ratio of power series in $w$, the same is plausible but not proved." Delete the sentence about the first versions (§5).
* Status: "proved ($\Lzero$ and affine likelihoods)".
* The proof in App. D points to the affine-slice argument in the proof of `rem:ident:exact` (§4).

**M5 (MA-08).** Append to `thm:sound:shrink`:
"\emph{Pool version} (experiments): with the experiments' prior weights $2^{-\mathrm{bits}(T)}$ and $\vdash_J$ for $\Th_d$, the conclusion holds for the posterior restricted to any pool $R_n\ni T^*$, even one chosen from the data, if $\delta_n\le2^{-\mathrm{bits}(T^*)}\,\Rreg(n,K)\,\delta'$ for every $n$."
* `\src` gains "experiments Prop X8(c)".
* `rem:sound:lumps` then reads "No contradiction with the pool version of \cref{thm:sound:shrink}: …", with `\Rreg(n,8)` in place of `R_{1/2}(n,8)`.

**M6 (MA-07; C21 in experiments).** Replace `rem:ident:x5` with:
"\Cref{thm:ident:doob} is stated for fixed laws. Run on the parameter $(T,w)$ with prior $\pi(T)\Dir_T(dw)$, as in the proof of \cref{thm:ident:limit}(b), Doob's argument gives concentration on $\{(T,w):P_{T,w}=P_{T^*}\}$ for a one-component generator, which is an atom of the prior, in a fixed pool: this covers E1, E4 and E6 with their hand pools. The experiments' data-dependent pool members ($\Mem(D_n)$, causal theories) are covered by no consistency theorem here, only by the pool versions of \cref{thm:sound:avg,thm:sound:shrink}. E2, E3(b), E5(b) and E8 sample at one fixed weight vector, where only \cref{thm:ident:limit}(b) and conjecture (c) speak: a yardstick, not an instance of a theorem."
* Status: "known (Doob's theorem in the $(T,w)$ form); not covered: data-dependent pools".

**M7 (MA-04, MA-16).** In `prop:ident:spare`, (c) becomes:
"(c) If $\inst(\sigma)\subseteq\operatorname{supp}P^*$, $\Qg_\sigma$ is outside the span of $T^*$'s components, and $\sum_s\Qg_\sigma(s)^2/P^*(s)<\infty$: $\ln\mathrm{BF}^\sigma_n=-\frac{\alpha_\sigma}2\ln n+O_P(1)$."
* After (d2), add: "The case of a $\Qg_\sigma$ in the span of $T^*$'s components but outside their convex hull is not covered."
* The appendix sketch states where the finite-χ² condition is used: the quadratic expansion of the log-likelihood in u.

**M8 (MA-03).** In `rem:model:graded`, the refuted part becomes:
"\emph{Refuted} (\cref{app:ver:corrections}): the pre-referee sentence ``a stronger theory has more short theorems, hence a larger $Z_T$, hence a smaller $P_T(s)$ on each datum''. For $T=\{a,a\to b\}$ and $T'=T\cup\{b\}$ (same theorems, nested instances) $b$ has a one-citation derivation from $T'$ and needs MP from $T$, so $P^g_{T'}(b)/P^g_T(b)=2^{\kappa(\ell_T(b)-\ell_{T'}(b))}Z_T/Z_{T'}\ge2^{\kappa(\ell_T(b)-\ell_{T'}(b))}Z_T$, which exceeds $1$ once $\kappa(\ell_T(b)-\ell_{T'}(b))>\log_2(1/Z_T)$: a datum whose shortest derivation gets shorter can gain."
* The referee's numbers (0.032 against 0.346; L2: 0.016 against 0.24) move to App. A, labelled as computed "for $\ell$ = symbol size of the least MP tree, normalised over a finite universe of 570 formulas, where the normaliser need not be $\le1$ (\texttt{r6})".
* `tab:ver:corrections` (front) keeps the numbers with the same qualifier.

**M9 (MA-09).** `tab:ident:c2`:
* misspecified prediction row: $-0.00$, $41.0$, $481.9$, $4921.9$, $49353.3$;
* caption: "… plus $\frac{K-1}2$ (the mean of $n\KL(\hat r\|r)$) in both cases", replacing "in the well-specified case; at $n=100$ the misspecified expansion is not yet accurate".

### univ-time

**U1 (MB-01; C-01 in front).**
* §3 opening, replacing "The data favour … over its instance schema $\sigma_\varphi$.": "The data favour the generator that emits exactly the instances. In every comparison analysed (\cref{thm:univ:B}) they never favour $\forall x\varphi$ over its instance schema $\sigma_\varphi$, except through non-logical weight effects under a selection-aware likelihood (\cref{prop:univ:B2}); with $\wedge$-rules on quantified formulas the question is open."
* Subsection title (label `sec:univ:never`): "Instance data do not favour $\forall x\varphi$ over its schema".
* `thm:univ:B` title: "Instance data do not favour $\forall x\varphi$".
* Replace the "Not covered:" sentence after its proof idea with:
  "Not covered: $\Lsel$ with a background. There $B\oplus_w\forall x\varphi$ has the selected law of $B\oplus_{w_e}\sigma_\varphi$ with the effective weight $w_e=wc/(1-w+wc)$ (proof of \cref{prop:univ:B2}): with a common fixed $w$ the two theories have different laws and whichever matches the data's mixture proportion wins at a linear rate, and with a learned weight the $\forall$-version can gain a bounded factor (\cref{prop:univ:B2}). Neither effect is logical, and under the per-citation $\Lselc$ both vanish (\cref{rem:univ:B2cit}). Also not covered: $\wedge$-detours (\cref{rem:univ:detour}), normalised likelihoods in $\CUiii$, and the scores with a background or with quantified data, where the $\forall$-version can be favoured (the datum $\neg\exists x\neg\varphi$ is proved by $\Hall$ and not by $\Hsch$)."
  * The proof-idea sentence "The mechanism is the size principle" becomes "The mechanism is the size principle, through the extra $\forall$E step that $\forall x\varphi$ needs to reach an instance" (MB-24).
* l.86 after `prop:univ:B2`: "With learned weights the effect is bounded; it is not evidence that the axioms prove $\forall x\varphi$."
* l.222 (`sec:univ:intuition`): "``The axioms prove $\forall x\varphi$'' gains from closed instances only through non-logical differences between the laws, as under $\Lsel$ with a background (\cref{prop:univ:B2}); with data from a model generator it tends to the prior share of provers in the generator class (\cref{thm:univ:omega})."

**U2 (MB-02, MB-14).** `thm:univ:B` statement, parts (B1) and (B3):
"\textup{(B1)} in $\Cmin$, single axioms, closed instances, under $\Lcl$, $\mu_T$, $\Lone$, $\Lsel$, $\Lmax$ and the scores (equality under $\Lcl$, under $\Lsel$ when $\forall x\varphi\notin S$, and under the scores when $\forall x\varphi$ is consistent); … \textup{(B3)} in $\CUiii$ calculi, quantifier-free $\varphi$, any background (\cref{prop:univ:sim}), under $\mu_T$ and $\Lmax$; and, for single axioms and quantifier-free data, under the scores, with equality (by Herbrand's theorem, $\{\forall x\varphi\}\vdash s$ iff $\Ic(\varphi)\vdash s$ for quantifier-free $s$)."
* The proof in App. B states the Herbrand step instead of "the score argument above".

**U3 (R-22).** `thm:univ:odds` statement, displayed in place of "as in \Cref{tab:univ:odds}":
"$O_n/O_0$ is $1$ under $\Lcl$, under $\Lsel(S)$ with $\forall x\varphi\notin S$, and under the scores ($\forall x\varphi$ consistent); $c^n$ under $\mu_T$ and $\Lmax$; $\big(cZ_{\Hsch}/((1-c)+cZ_{\Hsch})\big)^n$ under $\Lone$, which is $(c/(1+c))^n$ for quantifier-free $\varphi$; $0$ for $n\ge1$ under strict $\Lzero$; and, with a background $B$ under $\mu_T$, $\prod_ir(X_i)$ with $r(s)\in[c,1]$."
* Then the running-example sentence: "So at $c=0.3$, under $\Lone$ with quantifier-free $\varphi$, a generator whose axiom is $\forall x\varphi$ outputs $\forall x\varphi$ itself with probability $1/(1+c)=0.77$, and each observed instance multiplies its odds against $\sigma_\varphi$ by $c/(1+c)=0.23$ (\cref{tab:univ:c2})."
* `tab:univ:odds` moves to App. B, with its caption's script details.

**U4 (MB-03, partly accepted).** In `prop:univ:hanni`, replace "The same holds for $\Snc$ and $\Sg$ ($g\equiv1$ on provable data)." with:
"Under $\Snc$ and $\Sg$ ($g\equiv1$ on provable data) the theories that prove all the data share one factor, so their mutual odds keep the prior odds and again all three trichotomy values keep positive mass; under $\Snc$ the limit is the prior restricted to the larger set $\{T:T\cup\Ic(\varphi)\text{ consistent}\}$, which also contains non-provers of the instances such as $\emptyset$."
* Make no claim about non-provers under S_g: whether they keep mass depends on whether repeated data count, which `def:model:scores` leaves open (see `rejected.json`).

**U5 (MB-08).** `prop:univ:open`(d):
"\textup{(d)} If the class is finite and contains the guarded $\Hsch$, closed data give $P(T\vdash\forall x\varphi\mid D_n)\to0$: the guard is learned at rate $\Wo:=\ln\frac{1+g\rho}{1-\rho}$ ($0.1252$ at the defaults); the spare-slot prover $\Hboth$ decays only polynomially (like $1/n$ in $\Cmin$, \cref{prop:univ:both})."
Add after it: "For countable classes with learned-weight provers the limit $0$ is not proved."

**U6 (MB-04–MB-07, C-11, C-12).** `rem:time:summary` moves to the start of §6, after a short setup and the quotations (univ-time issue U-13). New text:
"(1) Penalties on the time to check or generate axioms (Kt, speed prior) do not block the collapse: Craig's sets $A^C_f$ have membership decidable in polynomial time (\cref{prop:time:cheap}), like finite $\DT$ theories, so such a penalty charges them as it charges template theories; no time-penalised prior is defined here, so no bound on how much it changes \cref{thm:time:equiv} is claimed. (2) Templates block H\"anni's schema (\cref{prop:time:notemplate}) but, over $\PA$, not the collapse for $\Sigma_n$-sound assigners on $\Sigma_n$ sentences: one ground reflection sentence reproduces them at a cost linear in $|f|$ (\cref{prop:time:collapse}); for merely consistent assigners that sentence can be inconsistent with $\PA$, and whether templates block the collapse for them is open. (3) Derivation size in written symbols prices the assigner: one decidable $X$ for all finite $\DT$ theories, and one for each $e$ for all axiom sets with membership in time $O(n^e)$, forces derivations of symbol size above $s(m)$ for infinitely many lengths $m$, i.e.\ at least a fixed polynomial root of the assigner's nondeterministic time (\cref{thm:time:ntime,cor:time:hard}); $\Lsig$ then charges at least $\kappa s(m)/4-\ln(Z_T/Z^\sigma_T)$ nats and the graded score at least $\kappa s(m)$ bits ($\kappa s(m)+\log_2Z_T$ after normalisation) on those data (\cref{prop:time:sigma}). The collapse constructions through $A^C_f$ and the two-sorted $A_f$ pay at most a polynomial of the deterministic running time (proof sketch, \cref{rem:time:upper}); for $\rho_{f,n}$ no upper bound is established. (4) Plain $\Lone$ is proved to charge at least $\zeta s(m)-\ln(C/Z_T)$ nats when the assigner's language lies outside $\NTIME(2^{(d+1)s})$, about the logarithm of its nondeterministic time (\cref{cor:time:log}); a polynomial charge is \cref{conj:time:poly}. Function induction's total log loss on $f_X$'s labels is at most $|f_X|$ bits."
* Status: "(1), (2), (4) proved; (3) lower bound proved, upper bound proof sketch".
* The section's current second opening paragraph (l.20) is deleted.

**U7 (MB-07).** `rem:time:upper`:
"The collapse constructions through $A^C_f$ and the two-sorted $A_f$ pay at most a polynomial of the assigner's \emph{deterministic} running time $k$ in derivation size: cite $\varphi^{\wedge(k+1)}$ and eliminate $\wedge$; or prove the true $\Sigma_1$ sentence $\Accf{f}(\gn{\varphi})$ in $\Q$, in size polynomial in the computation (recalled from \citealp{pudlak1998lengths}, not checked), then apply MP. For $\rho_{f,n}$ the same route also needs a $\PA$-proof of the Tarski biconditional for $\varphi$, whose size is not bounded here."

**U8 (MB-09).** In `prop:time:lonesize`, replace "$-\ln\Pr(\text{tree})\le12.8+12.2k$ nats" with "$-\ln\Pr(\text{tree})=12.77+12.21k$ nats ($12.206$ per round)".

**U9 (C-16).** In §6.2, after the definition of $\Accf f$:
"Both are written without $<$ (bounded quantifiers as $\exists z\,(z+x=y)$), so that $\Sigma_1$-completeness of $\Q$, which in $L_A$ holds for $<$-free $\Sigma_1$ sentences, applies."
* Add "($<$-free $\Sigma_1$ sentences)" to the status of `prop:time:twosorted` and to its proof in App. E.
* The front group records the reconciliation in `tab:ver:conflicts`.
* model-ident-sound adds to model.tex l.24: "$\Q$ has no axiom about $<$; it is $\Sigma_1$-complete for $<$-free $\Sigma_1$ sentences."

### pa-exp

**P1 (C1).** `prop:pa:must`(c):
"(c) any unrefuted theory with a smaller prior that derives every datum within $d$ beats both, e.g.\ an inconsistent theory whose shortest refutation of a datum (and shortest derivation of a negative datum) is longer than $d$. (The bare formula metavariable $F_0$ is refuted by $\paR d$ as soon as $d$ covers a one-line citation of a negated datum, which (b) requires.)"
* In the app-pa proof, delete "$F_0$ has every sentence as an instance, and" and "either has score 1 unless refuted within $d$". State the inconsistent-theory case only.

**P2 (C2).** In `prop:pa:wellspec`, the last sentence becomes:
"Under W a theory $\PA\cup S$ with generic fixed weights has a law different from $P_{\PA}$ and loses exponentially, at rate $\KL(P_{\PA}\|P_{\PA\cup S})$ (\cref{prop:ident:rates}(a)); with Dirichlet weights (outside W) such theories behave like spare slots and should decay only polynomially (proof sketch, \cref{prop:ident:spare})."
* Status: "proved, given \cref{thm:ident:doob} and known facts; proof sketch (Dirichlet weights)".
* Update the app-pa proof accordingly.

**P3 (C3).** `def:pa:lsch`: "On a finite candidate set the prior is $\pi(T)\propto2^{-\beta_{\mathrm{ax}}\sum_{\tau\in T}|\tau|}$, with $\beta_{\mathrm{ax}}$ bits per axiom symbol; by default $\beta_{\mathrm{ax}}=\beta$ …".
`prop:pa:memo`:
"If $s$ occurs $r$ times and the other data have the same best derivations under $T$ and $T\cup\{s\}$, then $\CL(T\cup\{s\})-\CL(T)=\beta_{\mathrm{ax}}|s|+\Delta I-r(D_T(s)-\ell_{\mathrm{cite}})$, with $D_T(s)$ and $\ell_{\mathrm{cite}}$ computed at the proof-text rate $\beta$ and $\Delta I$ the index cost change. Up to $\Delta I$, memorising at the first occurrence is cheaper iff $\beta_{\mathrm{ax}}<\beta^*(s):=(D_T(s)-\ell_{\mathrm{cite}})/|s|$."
* `tab:pa:theorems` caption: "… memorising wins at the first occurrence for every theorem at the default $\beta_{\mathrm{ax}}=\beta$".
* Answer item (3) becomes "when the axiom prior is much steeper than the proof code ($\beta_{\mathrm{ax}}\ge\beta^*(s)$, here 30--123 bits per symbol against $\beta=4.52$)".
* `prop:pa:must`(b) uses $\beta_{\mathrm{ax}}$.

**P4 (C4).** `ex:pa:skel`, after its first sentence:
"The theory of the 112 skeletons seen by $n=3000$ (119 templates) covers those data and is $42838.5$ bits behind $T^*$ (prior part $43040$), but it gets likelihood $0$ at the first unseen skeleton. The covering theory of all 157 skeletons (164 templates), inside $\ISigma2$, has asymptotic slope $\frac{164-8}2-19\cdot\frac{9-1}2=+2.0$ bits per doubling against $T^*$ (19 contexts; Wilks's theorem, from memory; proof sketch); its code length was not computed."

**P5 (C5).** `rem:pa:e3b`: replace "($T^*$-equivalents: $2\cdot10^{-178}$ at $n=2048$)" with:
"(mass on $T^*$-equivalents \emph{in this pool}: $2\cdot10^{-178}$ at $n=2048$, carried by \expth{frag-complete}, whose seven never-used fragments put it about 590 bits behind \expth{frag-atoms}; a $T^*$-equivalent that only adds $\TInd$ to \expth{frag-atoms} was not in the pool and would lose only polynomially, as a spare slot, \cref{prop:ident:spare})".
* The same caveat goes in a caption note of `tab:exp:e3b` ("equiv.: within the pool; see \cref{rem:pa:e3b}").

**P6 (C6).** `tab:pa:failures`, F3 "fixable?" cell: "harmless for theorems only for splits with a non-atomic formula root (\cref{prop:pa:detour}(a)); term-root splits lose $\forall x\varphi$ (\cref{rem:pa:merge}); atomic-root splits are weaker (\cref{prop:pa:detour}(b))".

**P7 (C7).** Last sentence of `rem:pa:zf`: "So, given the conjectured reverse overheads, the textbook ZF axioms win when the data are direct uses of them and of nothing they derive only at a cost."

**P8 (C8, C3).** The "Answer." paragraph of §7.4:
"A derivation-length likelihood finds $\Q+\TInd$ from theorem data (1) under the full-sum generative $\Lone$, when the data come from its own derivation process (\cref{prop:pa:gibbs,prop:pa:wellspec}), which human theorems, selected for short statements and interest, do not (under the two-part $\Lsch$ this case was not studied); and, under $\Lsch$, (2) when the data contain direct uses of the schema; (3) when the axiom prior is much steeper than the proof code ($\beta_{\mathrm{ax}}\ge\beta^*(s)$); (4) under the 0/1 constraint with refutation, at the price of the size principle. Otherwise $\Lsch$ memorises short theorems, and on a computed stream of six library theorems the better of two candidates is $\Q$ plus the theorems as axioms, strictly weaker than $\PA$ (\cref{rem:pa:streams}). …"
Keep the rest.

**P9 (C9, C37).** The paragraph after `def:pa:lsch`, now partly in App. F:
"The decodable variant adds 4.8--7.3\% to derivation costs; with at least $\log_2$ of the alphabet size bits per written symbol (about $\log_225$ with the variable names used) it is a prefix code, so Kraft holds and $\Lsch$ is the two-part form of a sub-probability likelihood. The reported $\beta=\log_223$ under-charges symbols by about 3\%, which changes no conclusion (pa \S0)."
* Status of the Kraft claim: "proved for $\beta\ge\log_2$(alphabet size)".
* `prop:pa:gibbs`: "(e.g.\ $\ell(s)=\beta|s|$ for a Polish-notation code with $\beta\ge\log_2$ of the alphabet size)".

**P10 (C10).** `rem:pa:pointwise`:
"Under 0/1 support every surviving consistent theory eventually decides each sentence correctly (memorisation alone suffices). With inconsistent theories in the class, each is eventually refuted under $\paR{d_n}$, but whether the posterior mass of not-yet-refuted inconsistent theories deriving a false sentence tends to $0$ is open."
* Status: "proved; open".
* pa.tex l.182: "… memorisation alone eventually decides every sentence correctly in every surviving consistent theory".

**P11 (C11).** `sec:pa:answer`: use §9.7. Replace "Within the hand-picked candidate sets, and for data that are direct uses of axioms, it puts nearly all mass on theories deductively equivalent to $\PA$" with:
"Within the hand-picked candidate sets and pools scored, for data that are direct uses of axioms under the broad usage laws scored (usage mixes of equivalent forms, G1 practice, connective-rich motives) and once every needed axiom has been cited, it puts nearly all mass on theories deductively equivalent to $\PA$; narrow or atomic practice, also direct use, ends on a strictly weaker theory (\cref{ex:pa:narrow,prop:pa:atomic})."
Delete the last sentence (§5).

**P12 (C12).** `prop:exp:exact`(d), appended:
"…; the hypothesis of (d3), no rigid $p$ inside a metavariable argument, is not checked by the code. It holds for every hand theory of E1 and E6; for data-derived theories at $J=2$ (E1 \expgen{allq2}) exactness is computed (brute force to $10^{-9}$ on 10 theories; the referee's 904 triples), not proved."
* Status: "(a)--(c) proved; (d) proved under the hypothesis of (d3), computed otherwise".

**P13 (C13).** Status of `prop:pa:occam`: "(a) proved; (b), (c) proved under the growth condition of (b) (a.s.\ for i.i.d.\ data); computed".

**P14 (C14, C15).**
* App-pa l.99: "Decodable-code costs are 3.4--7.5\% higher" (from the D and D(dec) columns of `c6_theorem_data.out`).
* App-pa l.208: "mass $0.0049$ ($\rho=0.9$) and $0.0727$ ($\rho=0.97$), summed over false $k<200$". Do not quote the reviewer's tail sum.

---

## 11. Status changes

Apply with `\status{…}`.

| item | new status | why |
|---|---|---|
| `thm:univ:B` | unchanged ("proved"); statement restricted (§10.U2) | MB-02 |
| `prop:univ:open` | unchanged; (d) restricted to finite classes | MB-08 |
| `rem:time:summary` | "(1), (2), (4) proved; (3) lower bound proved, upper bound proof sketch" | MB-04, MB-06 |
| `rem:time:upper` | "proof sketch ($A^C_f$, two-sorted $A_f$); not established for $\rho_{f,n}$" | MB-07 |
| `prop:time:twosorted` | "proved; $\Sigma_1$-completeness of $\Q$ for $<$-free sentences known" | C-16 |
| `prop:ident:spare` | unchanged; (c) gains the finite-χ² hypothesis | MA-04 |
| `rem:ident:sparetotal` | "proved (the sum); the waiting time in case (b) from the sketch of \cref{prop:ident:spare}(b); computed" | MA-25 |
| `rem:ident:x5` | "known (Doob's theorem in the $(T,w)$ form); not covered: data-dependent pools" | MA-07 |
| `rem:ident:nearmiss` | "proved (the transfer); open (size of the generator class)" | C-32 |
| `rem:sound:tight` | "proved" (L1 clause for d = ∞ only) | MA-06 |
| `rem:sound:vacuous` | "proved ($\Lzero$ and likelihoods affine in $w$)" | MA-05 |
| `thm:sound:shrink` | "proved" (pool version added; experiments Prop X8(c)) | MA-08 |
| `rem:sound:indep` | "proved for ground $\psi$; proof sketch when $\psi$ is generated by a schema" | MA-15 |
| `ex:sound:constant` | `\src{model Ex 4.9; experiments check\_fixed\_weight}` | C-32 |
| `prop:pa:wellspec` | "proved, given \cref{thm:ident:doob} and known facts; proof sketch (Dirichlet weights)" | C2 |
| `prop:pa:occam` | "(a) proved; (b), (c) proved under the growth condition of (b); computed" | C13 |
| `rem:pa:pointwise` | "proved; open" | C10, C-32 |
| `rem:pa:shift` | "proved; computed; open" | C-32 |
| Kraft claim after `def:pa:lsch` | "proved for $\beta\ge\log_2$(alphabet size)" | C9 |
| `prop:exp:exact` | "(a)--(c) proved; (d) proved under the hypothesis of (d3), computed otherwise" | C12 |
| `rem:exp:limits` | "(i), (v) computed; (ii)--(iv) properties of the code" | C18 |

The front group mirrors every change in `app:ver:sketches` and `app:ver:open`, and in `CLAIMS.md` at the end. In particular:
* `prop:ident:spare`(c)'s new hypothesis;
* `rem:time:upper` for ρ_{f,n};
* `prop:pa:wellspec` (Dirichlet weights only);
* `prop:exp:exact`(d).

---

## 12. Verdicts on the fatal and major issues

Every fatal and major reviewer issue was checked against the sources (track notes-final.md, referee.md, check outputs, code/results); the group files give the evidence and, under `verdict_note`, what was verified. A = accepted; A* = accepted with a modified fix (an alternative or a part of the reviewer's fix not adopted, see `rejected.json`); P = partly accepted (part of the reviewer's claim or requested change rejected, see `rejected.json`). No fatal or major issue was rejected outright. Reviewer issues: 10 fatal, 66 major (generated table).

| reviewer id | review | reviewer sev | final sev | verdict | group issue(s) | rejected part |
|---|---|---|---|---|---|---|
| C1 | math-C | fatal | fatal | A | pa-exp:P-01 | — |
| C2 | math-C | fatal | fatal | A | pa-exp:P-02 | — |
| C3 | math-C | major | major | A* | pa-exp:P-03 | REJ-13 |
| C4 | math-C | major | major | A | pa-exp:P-04 | — |
| C5 | math-C | major | major | A* | pa-exp:P-05 | REJ-09 |
| C6 | math-C | major | major | A | pa-exp:P-06 | — |
| C7 | math-C | major | major | A | pa-exp:P-07 | — |
| C8 | math-C | major | major | A | pa-exp:P-08 | — |
| C9 | math-C | major | major | A | model-ident-sound:M-44, pa-exp:P-09 | — |
| C10 | math-C | major | major | A | pa-exp:P-10 | — |
| C11 | math-C | major | major | A | pa-exp:P-11 | — |
| C12 | math-C | major | major | A | pa-exp:P-12 | — |
| C13 | math-C | major | major | A | pa-exp:P-13 | — |
| C14 | math-C | major | major | A | pa-exp:P-14 | — |
| C15 | math-C | major | major | A* | pa-exp:P-15 | REJ-14 |
| C-01 | consistency | fatal | fatal | A | front:F-01 | — |
| C-02 | consistency | fatal | fatal | A | front:F-02 | — |
| C-03 | consistency | fatal | fatal | A | front:F-03 | — |
| C-04 | consistency | major | major | A | front:F-05 | — |
| C-05 | consistency | major | major | A | front:F-06 | — |
| C-06 | consistency | major | major | A | front:F-07 | — |
| C-07 | consistency | major | major | A | front:F-08, model-ident-sound:M-20, pa-exp:P-24 | — |
| C-08 | consistency | major | major | A | front:F-09 | — |
| C-09 | consistency | major | major | A | front:F-10 | — |
| C-10 | consistency | major | major | A | front:F-11 | — |
| C-11 | consistency | major | major | A | front:F-12, univ-time:U-05 | — |
| C-12 | consistency | major | major | A | front:F-12, univ-time:U-06 | — |
| C-13 | consistency | major | major | A | front:F-13 | — |
| C-14 | consistency | major | major | A | front:F-14 | — |
| C-15 | consistency | major | major | A | front:F-15 | — |
| C-16 | consistency | major | major | A | front:F-16b, model-ident-sound:M-19, univ-time:U-10 | — |
| C-17 | consistency | major | major | A | front:F-16 | — |
| MA-01 | math-A | fatal | fatal | A | model-ident-sound:M-02 | — |
| MA-02 | math-A | fatal | fatal | A | model-ident-sound:M-01 | — |
| MA-03 | math-A | major | major | A* | model-ident-sound:M-03 | REJ-10 |
| MA-04 | math-A | major | major | A* | model-ident-sound:M-04 | REJ-11, REJ-12 |
| MA-05 | math-A | major | major | A | model-ident-sound:M-05 | — |
| MA-06 | math-A | major | major | A | model-ident-sound:M-06 | — |
| MA-07 | math-A | major | major | A* | model-ident-sound:M-07, pa-exp:P-16 | — |
| MA-08 | math-A | major | major | A | model-ident-sound:M-08, pa-exp:P-23 | — |
| MA-09 | math-A | major | major | A | model-ident-sound:M-09 | — |
| MB-01 | math-B | fatal | fatal | A* | univ-time:U-01 | REJ-02 |
| MB-02 | math-B | fatal | fatal | A | univ-time:U-02 | — |
| MB-03 | math-B | major | major | P | univ-time:U-03 | REJ-01 |
| MB-04 | math-B | major | major | A* | univ-time:U-04 | REJ-15 |
| MB-05 | math-B | major | major | A | univ-time:U-05 | — |
| MB-06 | math-B | major | major | A | univ-time:U-06 | — |
| MB-07 | math-B | major | major | A | univ-time:U-07 | — |
| MB-08 | math-B | major | major | A | univ-time:U-08 | — |
| MB-09 | math-B | major | major | A | univ-time:U-09 | — |
| R-01 | readability | major | major | A | front:F-17 | — |
| R-02 | readability | major | major | A* | front:F-18 | REJ-16 |
| R-03 | readability | major | major | A* | front:F-19, univ-time:U-11 | — |
| R-04 | readability | major | major | A* | univ-time:U-11 | REJ-17 |
| R-05 | readability | major | major | A | front:F-20, model-ident-sound:M-13, univ-time:U-16, pa-exp:P-21 | — |
| R-06 | readability | major | major | A | front:F-21 | — |
| R-07 | readability | major | major | P | front:F-22 | REJ-06 |
| R-08 | readability | major | major | A | front:F-23 | — |
| R-09 | readability | major | major | A | front:F-24 | — |
| R-13 | readability | major | major | A | front:F-25, model-ident-sound:M-14, univ-time:U-14, pa-exp:P-19 | — |
| R-14 | readability | major | major | A | model-ident-sound:M-15, univ-time:U-19, pa-exp:P-17 | — |
| R-15 | readability | major | major | A* | front:F-26, model-ident-sound:M-10, model-ident-sound:M-18, univ-time:U-17 | — |
| R-16 | readability | major | major | A | front:F-29, model-ident-sound:M-12, univ-time:U-15, pa-exp:P-20 | — |
| R-17 | readability | major | major | A | front:F-30, model-ident-sound:M-13, univ-time:U-16, pa-exp:P-21 | — |
| R-18 | readability | major | major | A | model-ident-sound:M-11 | — |
| R-19 | readability | major | major | A | model-ident-sound:M-11 | — |
| R-20 | readability | fatal | fatal | A | front:F-04 | — |
| R-21 | readability | major | major | A | model-ident-sound:M-10 | — |
| R-22 | readability | major | major | A* | univ-time:U-11 | REJ-04 |
| R-23 | readability | major | major | P | univ-time:U-12 | REJ-03 |
| R-24 | readability | major | major | P | univ-time:U-13 | REJ-05 |
| R-25 | readability | major | major | A | pa-exp:P-18 | — |
| R-26 | readability | major | major | A | front:F-27 | — |
| R-27 | readability | major | major | A | front:F-31, model-ident-sound:M-16, univ-time:U-18, pa-exp:P-22 | — |
| R-28 | readability | major | major | P | front:F-45, model-ident-sound:M-17 | REJ-07 |
| R-33 | readability | major | major | A | front:F-28 | — |

## 13. Cross-group dependencies, new labels, completion

**New labels.** Create only these:
* `rem:pa:sdpcrefuted` (pa-exp; the front group cites it in `tab:ver:corrections`);
* `tab:exp:summary` (pa-exp; the front group may cite it);
* `app:exp:results` (pa-exp);
* `app:notation` (front; optional).

**Cross-group text dependencies.** These are resolved by this file, so no group waits for another:
* The front group uses the canonical wordings of §9 and the label set above.
* model-ident-sound adds the Q-has-no-< sentence (§10.U9).
* The front group records:
  * the conflict reconciliations C-16 and C-02 in `tab:ver:conflicts` and `tab:ver:writing`;
  * every reconciliation and correction made in this revision, as new rows of `tab:ver:writing`, one line each, citing the issue ids.
* The front group's verdict table (moved to App. H) cites labels that other groups keep.

**Order.**
1. The front group lands `preamble.tex` and `main.tex` first; they affect every build.
2. All groups work in parallel.
3. At the end, one full build (front, or the orchestrator) with flock, then a page check against §2.
4. Fix overruns in the overrunning group.
5. The front group syncs `CLAIMS.md` and `app:ver` lists (§11).

**A group is done when:**
* every issue in its JSON file is fixed, or marked not done with a reason in the changelog;
* its sections are within their caps;
* `test-section.sh` passes for each of its sections;
* its changelog is written.

---

## 14. Merge map

Every reviewer issue appears in at least one group issue or in `rejected.json` (generated by `research/paper-review/scratch/lead_make_edits.py`, which fails if any id is uncovered).

Counts:

```
front               47 issues: 4 fatal, 28 major, 15 minor
model-ident-sound   44 issues: 2 fatal, 18 major, 24 minor
univ-time           41 issues: 2 fatal, 17 major, 22 minor
pa-exp              47 issues: 2 fatal, 20 major, 25 minor
all groups         179 issues: 10 fatal, 83 major, 86 minor
rejected entries: 17 (from 16 reviewer issues); reviewer issues: 177; all covered
```

| reviewer id | review | sev | group issue(s) | rejected part(s) |
|---|---|---|---|---|
| C1 | math-C | fatal | pa-exp:P-01 | — |
| C2 | math-C | fatal | pa-exp:P-02 | — |
| C3 | math-C | major | pa-exp:P-03 | REJ-13 |
| C4 | math-C | major | pa-exp:P-04 | — |
| C5 | math-C | major | pa-exp:P-05 | REJ-09 |
| C6 | math-C | major | pa-exp:P-06 | — |
| C7 | math-C | major | pa-exp:P-07 | — |
| C8 | math-C | major | pa-exp:P-08 | — |
| C9 | math-C | major | model-ident-sound:M-44, pa-exp:P-09 | — |
| C10 | math-C | major | pa-exp:P-10 | — |
| C11 | math-C | major | pa-exp:P-11 | — |
| C12 | math-C | major | pa-exp:P-12 | — |
| C13 | math-C | major | pa-exp:P-13 | — |
| C14 | math-C | major | pa-exp:P-14 | — |
| C15 | math-C | major | pa-exp:P-15 | REJ-14 |
| C16 | math-C | minor | pa-exp:P-25 | — |
| C17 | math-C | minor | pa-exp:P-26 | — |
| C18 | math-C | minor | pa-exp:P-27 | — |
| C19 | math-C | minor | pa-exp:P-41 | — |
| C20 | math-C | minor | pa-exp:P-28 | — |
| C21 | math-C | minor | pa-exp:P-16 | — |
| C22 | math-C | minor | pa-exp:P-29 | — |
| C23 | math-C | minor | pa-exp:P-30 | — |
| C24 | math-C | minor | pa-exp:P-01 | — |
| C25 | math-C | minor | pa-exp:P-31 | — |
| C26 | math-C | minor | pa-exp:P-32 | — |
| C27 | math-C | minor | pa-exp:P-33 | — |
| C28 | math-C | minor | pa-exp:P-34 | — |
| C29 | math-C | minor | pa-exp:P-35 | — |
| C30 | math-C | minor | pa-exp:P-43 | — |
| C31 | math-C | minor | model-ident-sound:M-15, pa-exp:P-44 | — |
| C32 | math-C | minor | pa-exp:P-36 | — |
| C33 | math-C | minor | pa-exp:P-37 | — |
| C34 | math-C | minor | pa-exp:P-38 | — |
| C35 | math-C | minor | pa-exp:P-39 | — |
| C36 | math-C | minor | pa-exp:P-40 | — |
| C37 | math-C | minor | pa-exp:P-09 | — |
| C-01 | consistency | fatal | front:F-01 | — |
| C-02 | consistency | fatal | front:F-02 | — |
| C-03 | consistency | fatal | front:F-03 | — |
| C-04 | consistency | major | front:F-05 | — |
| C-05 | consistency | major | front:F-06 | — |
| C-06 | consistency | major | front:F-07 | — |
| C-07 | consistency | major | front:F-08, model-ident-sound:M-20, pa-exp:P-24 | — |
| C-08 | consistency | major | front:F-09 | — |
| C-09 | consistency | major | front:F-10 | — |
| C-10 | consistency | major | front:F-11 | — |
| C-11 | consistency | major | front:F-12, univ-time:U-05 | — |
| C-12 | consistency | major | front:F-12, univ-time:U-06 | — |
| C-13 | consistency | major | front:F-13 | — |
| C-14 | consistency | major | front:F-14 | — |
| C-15 | consistency | major | front:F-15 | — |
| C-16 | consistency | major | front:F-16b, model-ident-sound:M-19, univ-time:U-10 | — |
| C-17 | consistency | major | front:F-16 | — |
| C-18 | consistency | minor | front:F-32 | — |
| C-19 | consistency | minor | front:F-33 | — |
| C-20 | consistency | minor | front:F-34 | — |
| C-21 | consistency | minor | front:F-35 | — |
| C-22 | consistency | minor | pa-exp:P-41 | — |
| C-23 | consistency | minor | model-ident-sound:M-34 | — |
| C-24 | consistency | minor | pa-exp:P-42 | — |
| C-25 | consistency | minor | model-ident-sound:M-08, model-ident-sound:M-17, pa-exp:P-23 | — |
| C-26 | consistency | minor | front:F-31, model-ident-sound:M-16, univ-time:U-18, pa-exp:P-22 | — |
| C-27 | consistency | minor | front:F-46, model-ident-sound:M-43, univ-time:U-41, pa-exp:P-46 | — |
| C-28 | consistency | minor | front:F-29, pa-exp:P-20 | — |
| C-29 | consistency | minor | univ-time:U-34 | — |
| C-30 | consistency | minor | model-ident-sound:M-11 | — |
| C-31 | consistency | minor | univ-time:U-35 | — |
| C-32 | consistency | minor | model-ident-sound:M-40, pa-exp:P-10 | — |
| C-33 | consistency | minor | front:F-36 | — |
| C-34 | consistency | minor | front:F-16 | — |
| C-35 | consistency | minor | front:F-37 | — |
| C-36 | consistency | minor | front:F-38 | — |
| C-37 | consistency | minor | front:F-39 | — |
| C-38 | consistency | minor | front:F-25, model-ident-sound:M-14, univ-time:U-14, pa-exp:P-19 | — |
| C-39 | consistency | minor | front:F-26, model-ident-sound:M-18 | REJ-08 |
| C-40 | consistency | minor | model-ident-sound:M-15, univ-time:U-19, pa-exp:P-17 | — |
| C-41 | consistency | minor | model-ident-sound:M-05, pa-exp:P-45 | — |
| C-42 | consistency | minor | front:F-22, model-ident-sound:M-15, univ-time:U-19, pa-exp:P-17 | — |
| MA-01 | math-A | fatal | model-ident-sound:M-02 | — |
| MA-02 | math-A | fatal | model-ident-sound:M-01 | — |
| MA-03 | math-A | major | model-ident-sound:M-03 | REJ-10 |
| MA-04 | math-A | major | model-ident-sound:M-04 | REJ-11, REJ-12 |
| MA-05 | math-A | major | model-ident-sound:M-05 | — |
| MA-06 | math-A | major | model-ident-sound:M-06 | — |
| MA-07 | math-A | major | model-ident-sound:M-07, pa-exp:P-16 | — |
| MA-08 | math-A | major | model-ident-sound:M-08, pa-exp:P-23 | — |
| MA-09 | math-A | major | model-ident-sound:M-09 | — |
| MA-10 | math-A | minor | model-ident-sound:M-21 | — |
| MA-11 | math-A | minor | model-ident-sound:M-22 | — |
| MA-12 | math-A | minor | model-ident-sound:M-23 | — |
| MA-13 | math-A | minor | model-ident-sound:M-24 | — |
| MA-14 | math-A | minor | model-ident-sound:M-25 | — |
| MA-15 | math-A | minor | model-ident-sound:M-37 | — |
| MA-16 | math-A | minor | model-ident-sound:M-04 | — |
| MA-17 | math-A | minor | model-ident-sound:M-26 | — |
| MA-18 | math-A | minor | model-ident-sound:M-27 | — |
| MA-19 | math-A | minor | model-ident-sound:M-28 | — |
| MA-20 | math-A | minor | model-ident-sound:M-29 | — |
| MA-21 | math-A | minor | front:F-08, model-ident-sound:M-20 | — |
| MA-22 | math-A | minor | model-ident-sound:M-30 | — |
| MA-23 | math-A | minor | model-ident-sound:M-31 | — |
| MA-24 | math-A | minor | model-ident-sound:M-32 | — |
| MA-25 | math-A | minor | model-ident-sound:M-38 | — |
| MA-26 | math-A | minor | model-ident-sound:M-39 | — |
| MA-27 | math-A | minor | model-ident-sound:M-33 | — |
| MB-01 | math-B | fatal | univ-time:U-01 | REJ-02 |
| MB-02 | math-B | fatal | univ-time:U-02 | — |
| MB-03 | math-B | major | univ-time:U-03 | REJ-01 |
| MB-04 | math-B | major | univ-time:U-04 | REJ-15 |
| MB-05 | math-B | major | univ-time:U-05 | — |
| MB-06 | math-B | major | univ-time:U-06 | — |
| MB-07 | math-B | major | univ-time:U-07 | — |
| MB-08 | math-B | major | univ-time:U-08 | — |
| MB-09 | math-B | major | univ-time:U-09 | — |
| MB-10 | math-B | minor | univ-time:U-20 | — |
| MB-11 | math-B | minor | univ-time:U-21 | — |
| MB-12 | math-B | minor | univ-time:U-22 | — |
| MB-13 | math-B | minor | univ-time:U-23 | — |
| MB-14 | math-B | minor | univ-time:U-02 | — |
| MB-15 | math-B | minor | univ-time:U-24 | — |
| MB-16 | math-B | minor | univ-time:U-25 | — |
| MB-17 | math-B | minor | univ-time:U-26 | — |
| MB-18 | math-B | minor | univ-time:U-27 | — |
| MB-19 | math-B | minor | univ-time:U-28 | — |
| MB-20 | math-B | minor | univ-time:U-29 | — |
| MB-21 | math-B | minor | univ-time:U-30 | — |
| MB-22 | math-B | minor | univ-time:U-01 | — |
| MB-23 | math-B | minor | univ-time:U-31 | — |
| MB-24 | math-B | minor | univ-time:U-39 | — |
| MB-25 | math-B | minor | univ-time:U-32 | — |
| MB-26 | math-B | minor | univ-time:U-33 | — |
| R-01 | readability | major | front:F-17 | — |
| R-02 | readability | major | front:F-18 | REJ-16 |
| R-03 | readability | major | front:F-19, univ-time:U-11 | — |
| R-04 | readability | major | univ-time:U-11 | REJ-17 |
| R-05 | readability | major | front:F-20, model-ident-sound:M-13, univ-time:U-16, pa-exp:P-21 | — |
| R-06 | readability | major | front:F-21 | — |
| R-07 | readability | major | front:F-22 | REJ-06 |
| R-08 | readability | major | front:F-23 | — |
| R-09 | readability | major | front:F-24 | — |
| R-10 | readability | minor | front:F-05 | — |
| R-11 | readability | minor | front:F-21 | — |
| R-12 | readability | minor | front:F-40 | — |
| R-13 | readability | major | front:F-25, model-ident-sound:M-14, univ-time:U-14, pa-exp:P-19 | — |
| R-14 | readability | major | model-ident-sound:M-15, univ-time:U-19, pa-exp:P-17 | — |
| R-15 | readability | major | front:F-26, model-ident-sound:M-10, model-ident-sound:M-18, univ-time:U-17 | — |
| R-16 | readability | major | front:F-29, model-ident-sound:M-12, univ-time:U-15, pa-exp:P-20 | — |
| R-17 | readability | major | front:F-30, model-ident-sound:M-13, univ-time:U-16, pa-exp:P-21 | — |
| R-18 | readability | major | model-ident-sound:M-11 | — |
| R-19 | readability | major | model-ident-sound:M-11 | — |
| R-20 | readability | fatal | front:F-04 | — |
| R-21 | readability | major | model-ident-sound:M-10 | — |
| R-22 | readability | major | univ-time:U-11 | REJ-04 |
| R-23 | readability | major | univ-time:U-12 | REJ-03 |
| R-24 | readability | major | univ-time:U-13 | REJ-05 |
| R-25 | readability | major | pa-exp:P-18 | — |
| R-26 | readability | major | front:F-27 | — |
| R-27 | readability | major | front:F-31, model-ident-sound:M-16, univ-time:U-18, pa-exp:P-22 | — |
| R-28 | readability | major | front:F-45, model-ident-sound:M-17 | REJ-07 |
| R-29 | readability | minor | model-ident-sound:M-13, univ-time:U-40 | — |
| R-30 | readability | minor | pa-exp:P-22 | — |
| R-31 | readability | minor | univ-time:U-36 | — |
| R-32 | readability | minor | model-ident-sound:M-41, pa-exp:P-47 | — |
| R-33 | readability | major | front:F-28 | — |
| R-34 | readability | minor | front:F-28 | — |
| R-35 | readability | minor | front:F-25 | — |
| R-36 | readability | minor | model-ident-sound:M-35 | — |
| R-37 | readability | minor | model-ident-sound:M-42, univ-time:U-12 | — |
| R-38 | readability | minor | univ-time:U-37 | — |
| R-39 | readability | minor | front:F-41, model-ident-sound:M-17 | — |
| R-40 | readability | minor | front:F-41 | — |
| R-41 | readability | minor | front:F-42 | — |
| R-42 | readability | minor | univ-time:U-38 | — |
| R-43 | readability | minor | model-ident-sound:M-36 | — |
| R-44 | readability | minor | front:F-43, pa-exp:P-17 | — |
| R-45 | readability | minor | front:F-44 | — |
