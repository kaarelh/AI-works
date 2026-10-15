# Paper 2: integration of the imitation thread, the weight-decay remark and the caveats (log, 2026-10-14)

*Integrating editor's log. It records every change made to `paper-steeper/` for the author's three requests (verbatim in `research/tracks/imitation/00-brief.md`): (1) λ = cn compared with weight decay; (2) an imitation thread, included only if the result is good; (3) clear caveats. It also gives the build checks and the page counts.*

* **Sources read first, as instructed.**
  * `research/tracks/imitation/referee-final.md`, in full. Items 1–5 are verified. Six running-text corrections, C1–C6, and one optional sentence are required.
  * `research/paper-review/imitation-edit/literature.md`, in full, with `lit.bib`.
* **Then read.**
  * The brief `research/tracks/imitation/00-brief.md`.
  * The synthesis `research/tracks/imitation/notes-final.md`: §0–§2.5, §3, §4, §5, §6, §7 and the Verification log.
  * `research/tracks/imitation/final-check.md`, in full.
  * `research/tracks/imitation/robust/notes-final.md` §4.5 (Props 4.10, 4.11).
  * Every file of `research/tracks/imitation/drafts/`.
  * The binding rules: `research/paper-review/DECISIONS.md` §0 and §A; `REFRAME.md`, in full; `restructure/DECISIONS-restructure.md` §D9, §3 and §4.
  * Paper 2: `abstract`, `intro`, `related`, `limits`, `computable` and `discussion`, in full; `main.tex`, `build.sh`, `test-section.sh`, `merge_bib.py`, `OUTLINE.md` and `CLAIMS.md`; `app-teacher.tex` from §F.8 to the end.
* **Repository.**
  * No git command that changes repository state was run. Read-only commands were used: `git status`, `git show HEAD:…` to look at the committed PDF, `git ls-files`.
  * Paper 1 (`paper/`) was not edited.
  * Files changed or created are listed in §1.
  * One side effect was undone. The DECISIONS §A2.5 check script `research/paper-review/scratch/editor/extract_status.py` rewrites the tracked files `status_p1.json` and `status_p2.json` in the same folder. Both were restored byte for byte from `HEAD` (by `git show HEAD:<path> > <path>`), and the check was then re-run on a copy of the script that writes to the session scratchpad.
* **Backup.** The pre-integration sources (`main.tex`, `preamble.tex`, `sections/`, `bib/`, `CLAIMS.md`, `OUTLINE.md`, `merge_bib.py`, `build.sh`) were copied to the session scratchpad before any edit. A scratch build of that copy gives the "before" numbers of §7.

---

## 0. Outcome

* **Imitation (request 2).**
  * The final referee verified the behavioural conclusion, `thm:imit:main`(iv), and every other item it refereed.
  * So the theorem is stated in full. It sits in a new compact section, `sec:imit` (§10), placed after `sec:limits` and before `sec:computable`, with proofs in a new App H placed after `app-limits`.
  * The cut is that of synthesis §5.3:
    * in the main text: the definition, the theorem and `prop:imit:limits`(a),(b);
    * moved to App H: `rem:imit:private`, the numbers after the theorem, `prop:imit:limits`(c) and the cell count (now the new `prop:imit:cheap`);
    * dropped: `q:imit:open` (one open-problems item).
  * All six corrections C1–C6 and the optional sentence are applied (§2).
* **Weight decay (request 1).** Four texts were inserted from the drafts, unchanged: the remark (`rem:teacher:weightdecay`), its appendix subsection (`app:teacher:weightdecay`), the related-work sentence and the discussion sentence. The new BibTeX entries are in a new `bib/imit.bib`, and `core.bib` is untouched.
* **Caveats (request 3).** The introduction gets:
  * the scope paragraph, naming the four toy cases solved;
  * the motivation sentence;
  * the contributions bullet and the table row.

  The discussion gets the paragraph "What the toy cases leave open", with six concrete gaps, and the open-problems item. The abstract is unchanged: it is 1920 characters and remains truthful (§5).
* **Literature (request 2, context).**
  * The related-work paragraph "Imitation and identifiability from behaviour" is the main version of the literature record §3.1.
  * Sentence I1 is used verbatim.
  * Sentence I2 is used in condensed form (§3).
* **Build.** The full build has:
  * 0 LaTeX errors;
  * 0 undefined references and 0 undefined citations;
  * 0 multiply defined labels;
  * 0 overfull boxes above 10 pt.

  It has 86 pages (74 before). The greps of DECISIONS §A2.5, §A5 and §B.6, REFRAME's checks, the restructure's forbidden strings and the companion check all pass (§6).
* **Pages** (§7).
  * Main text: 39.08 pp (34.50 before).
  * References: 3.69 pp (2.32 before).
  * Appendices: 42.89 pp (36.96 before).
  * §10 takes 2.33 pp, not the 1.3 pp the synthesis estimated for its cut. The reason is given in §7.
  * All three page caps of DECISIONS-restructure §3 are now exceeded.

---

## 1. Every change, by file

| file | change |
|---|---|
| `sections/imit.tex` | **New.** `sec:imit`, §10 "Imitation: a sampler whose coins the environment drives" (content in §2) |
| `sections/app-imit.tex` | **New.** App H "Proofs for Section 10 (imitation)": H.1 `app:imit:private` (with `rem:imit:private` moved here and a paragraph on hypotheses that learn in context); H.2 `app:imit:lemmas` (`lem:imit:coding`, `lem:imit:closeness`); H.3 `app:imit:main` (the proof of `thm:imit:main`, then "Outside the range of $c$" and "Numbers", both moved from the main text); H.4 `app:imit:limits` (proofs of `prop:imit:limits`(a),(b) and "No window in (b)"); H.5 `app:imit:cheap` (the new `prop:imit:cheap`, with its proof, the rate-blindness sentence and the cell-count number) |
| `main.tex` | `\input{sections/imit}` after `limits`; `\input{sections/app-imit}` after `app-limits` (the draft `main.diff`); two comment lines |
| `sections/intro.tex` | The draft `intro.diff`, which carries final-check F6a, F6b, F7, F8a, F8b: the motivation sentence in paragraph 2; the contributions bullet "Imitation"; the `tab:intro:claims` row "Is a sampler recovered when other hypotheses predict better?"; the new first part of "Scope and reader's guide"; "imitation (\cref{sec:imit})" in the reader's guide. Then: `prop:imit:cheap` added to the citations of the bullet and of the table row, since the cheap-coupling result is now its own proposition. Comment lines |
| `sections/related.tex` | The draft `related.diff`: the weight-decay sentence after `rem:related:cold`. The new paragraph "Imitation and identifiability from behaviour", the main version of literature §3.1, verbatim, placed after "Algorithmic statistics" and before "Novelty". Comment lines |
| `sections/teacher.tex` | The draft `teacher.diff`: `rem:teacher:weightdecay` after `rem:limits:schedule`, byte-identical to `drafts/wd-remark.tex` (checked by `diff`). Comment lines |
| `sections/app-teacher.tex` | The draft `app-teacher.diff`: `app:teacher:weightdecay` before `app:teacher:rates`, byte-identical to `drafts/wd-appendix.tex` (checked by `diff`). Layout: the float `tab:teacher:rates` (unchanged) moved in the source from the end of App F.8 to just before the proof of `prop:teacher:rates`. After the insertion it had floated to p. 77, inside App G; it is now on p. 76, inside App F.8. Comment lines |
| `sections/discussion.tex` | The draft `discussion.diff` (with F9, F10), then:<br>(i) the weight-decay sentence joined to the first sentence of "The window and its price" by a semicolon, so that the paragraph keeps the three sentences that DECISIONS-restructure §3 allows; the text is unchanged;<br>(ii) C6 in "What the toy cases leave open";<br>(iii) `prop:imit:cheap` added to the citations of gap (3);<br>(iv) the open-problems item "Imitation" rewritten to carry the five questions of the dropped `q:imit:open` itself, as precise questions, since there is no `question` environment to cite (DECISIONS §A10).<br>Comment lines |
| `bib/imit.bib` | **New.** Eleven weight-decay entries (`drafts/imit.bib`, verbatim) and the eight cited entries of `imitation-edit/lit.bib` (verbatim, with their verification comments). The five verified but uncited entries of `lit.bib` stay there. No key collides with `core.bib`, `steep-a.bib` or `steep-b.bib` (checked by script). `merge_bib.py` picks the file up unchanged: 60 entries, 0 title conflicts |
| `bib/all.bib` | Regenerated by `merge_bib.py` (build output) |
| `bib/core.bib` | Unchanged; byte-identical to `paper/bib/core.bib` (checked with `cmp`) |
| `CLAIMS.md` | Header; §1 gains a weight-decay sentence and an "Imitation" paragraph; the §2 ledger is regenerated from the sources and `main.aux` in input order (a script that reproduces the old ledger exactly except for the new rows, checked by `diff`); the list of moved items; §3 gains three answers (imitation, weight decay, caveats) and the new literature in "Prior work" |
| `OUTLINE.md` | Header; the story (two additions, and the caveats); the page table with "before" and "measured" columns and the new §10 and App H; the overrun note; the items placed in App H; the abstract note; the new labels and the shifted numbers; the `bib/imit.bib` note |
| `main.pdf`, `main.aux`, logs | Build output |

---

## 2. The imitation section: what is where, and the corrections

### 2.1 Main text (`imit.tex`)

1. **Opening, two paragraphs** (rewritten for the compact form).
   * **Paragraph 1** ties the vocabulary. In the paper's terms the person is a sampler, "a model with fresh coins at each query". A copy is a program whose kernel equals the person's on the support of the inputs. The paragraph then names the two kinds of non-copy the author's message asks about, each with where it is treated:
     * fill-ins are rejected per query (`thm:recovery:main`), and with private coins no predictor gains more than its length plus a Ville deficiency (`rem:imit:private`);
     * systems that infer which person they face are excluded by the class (App H.1).
     * Literature sentence I1 is verbatim here.
   * **Paragraph 2** says plainly what is shown and what is not.
     * Shown: near-optimal hypotheses are close to the person in behaviour for λ/n in a window; no procedure reliably copies persons that share a data law.
     * Not shown: that a copy itself is selected; anything about how the selected program computes; recovery for couplings with a short description; anything beyond the population objective, from samples only asymptotically.
2. **`def:imit:setting`**, unchanged from the draft.
3. **The paragraph after the definition.**
   * C2 is applied: "…drawn uniformly from its type class, independently of the person's model and the channel."
   * Its first sentence is shortened.
4. **`thm:imit:main`**, unchanged. The referee verified the statement, the constants and the range $a>1$, so nothing is weakened.
5. **The proof idea.**
   * C1 is applied: "…which define a semimeasure on couplings; normalised, it would give β a code shorter than the coupling's incompressibility allows, unless the divergence is small, the program predicts worse than the person, or it knows more about β."
   * The idea is otherwise condensed.
6. **The paragraph after the theorem.**
   * C3 is applied: "for every $c$ above the reuse factor $2^{-m}$, with $a$ bounded away from $1$, and well below $H(\rho)/\ell_0$".
   * The paragraph keeps:
     * the scale $H(\rho)$;
     * near-copies, not copies;
     * that the better predictors only store an incompressible table;
     * the $cn$-MAPs, via `prop:recovery:beyond`(c).
   * It ends with a pointer to App H.3, where the text on $c$ outside the window (with C4) and the numbers now are.
7. **`prop:imit:limits`**, items (a) and (b) only, both unchanged. Its proof idea writes $\binom{2^m}{s_0}$ as $2^{L_\beta}$, which is equal by the definition of $L_\beta$.
8. **The last paragraph.**
   * Kept:
     * behaviour, not mechanism (final-check F5 wording);
     * the person/environment split as a convention, now with the Armstrong–Mindermann clause;
     * "an incompressible coupling is not enough";
     * one sentence for cheap couplings with a pointer to `prop:imit:cheap`, and the deterministic-state remark.
   * The I2 sentence on several environments and interventions is condensed. It ends with a pointer to the open problems instead of `q:imit:open`(e).

### 2.2 App H (`app-imit.tex`): moved items

| item | from | to | change |
|---|---|---|---|
| `rem:imit:private` | the section's first environment | opens H.1 | label, `\status`, `\src` unchanged; its pointer "(\cref{app:imit:private})" became "(proved below)" |
| the in-context learner (Bayes mixture over persons, `robust` Prop 5.2) | the section's opening paragraph | H.1, after the proof, "Hypotheses that learn in context" | text unchanged, plus "$P_U\ge wP_H$", the one-line reason the synthesis gives (§2.1) |
| the numbers after the theorem | main text | H.3, "Numbers" | worded per DECISIONS §A9: "(an illustration, not a value for a fixed reference machine), a direct computation (code in the accompanying repository) gives …"; values unchanged ($6.2\cdot10^{-4}$, $9.5\cdot10^{-4}$, $H(\rho)=0.0112$, the bound exceeding $H(\rho)$ at $c=10^{-4}$), all checked by referee-final q4 |
| the range of $c$ outside the window | main text | H.3, "Outside the range of $c$ discussed after the theorem" | carries C4 (§2.3) |
| `prop:imit:limits`(c) | main-text proposition | `prop:imit:cheap`(i), H.5 (**new label**) | statement unchanged |
| the cell count | main-text sentence and appendix paragraph | `prop:imit:cheap`(ii), with its proof, and the number after the proof | C5 (§2.3) |
| the rate-blindness sentence | main text | after the proof of `prop:imit:cheap` | unchanged |

`\status` and `\src` are present on every theorem-like environment of both files. The definition carries `\src` only, as Paper 2's other definitions do. `\src` notes now also name `imitation/referee-final` where it verified the item. They print nothing.

### 2.3 The referee's corrections (`referee-final.md` §6)

| id | where now | applied text |
|---|---|---|
| C1 | `imit.tex`, proof idea | exactly as given |
| C2 | `imit.tex`, paragraph after the definition | exactly as given |
| C3 | `imit.tex`, paragraph after the theorem | exactly as given |
| C4 | `app-imit.tex`, H.3 (the sentence moved with the range of $c$) | "If the values of $\rho$ are distinct, the program that models the coupling wins below about $2^{-m}$ (the last part of the theorem); with ties it must also describe which label each tied coin gives, and it can lose to the copies far below $2^{-m}$." The referee's string ends "and the copies can win far below $2^{-m}$". Its own proof (§2.8) shows that the program that models the coupling is worse than the copies on $(2\cdot2^{-m}/k,\,2^{-m})$, not that a copy is a minimiser. So the verb was turned around to say exactly that. |
| C5 | `app-imit.tex`, `prop:imit:cheap`(ii) and the sentence after its proof | all three hypotheses are named in the statement: the feature case, $\lvert\Sigma\rvert\ge2$ with the values of $\rho$ distinct, and $\pi_{\rm u}$ shorter than $\ell_0$. "whatever the coupling" replaces "incompressible". The number reads "$H(\rho)\approx\frac12$ … more than $1.99\cdot10^6$ cells, whatever the coupling". The positivity of $\log\lvert Y\rvert-H(\rho)$, used in the division, is now stated in the proof |
| C6 | `discussion.tex`, gap (2) | exactly as given ("cannot all be copied reliably by any procedure") |
| optional (§6) | `app-imit.tex`, end of the proof of `lem:imit:closeness` | "…divide by $2^{m-1}$; the remaining $2/2^m$ is absorbed in $\kappa$." |

The corrections of the earlier final check (F1–F12) were already in the drafts and are all present. F1 is superseded by C3's more precise wording.

---

## 3. Literature sentences (`imitation-edit/literature.md`)

| draft | used? | where | form |
|---|---|---|---|
| §3.1 main version (four sentences) | yes | `related.tex`, new paragraph after "Algorithmic statistics" | verbatim |
| §3.1 fallback | no | – | the main version was preferred, as the record recommends |
| §3.2 I1 (behavioural cloning clause) | yes | `imit.tex`, first sentence | verbatim |
| §3.2 I2 (two sentences) | yes, condensed | `imit.tex`, last paragraph | Related work already carries the full attributions, so the section uses short forms. Armstrong–Mindermann: "as a policy does not determine its split into a planner and a reward \citep{armstrong2018occam}". Cao et al. and de Haan et al.: "Data from several environments or from interventions identify more in inverse reinforcement learning and behavioural cloning \citep{cao2021identifiability,dehaan2019causal}". Both stay at the abstract level of §2.1 of the record (decomposition not unique; reward recovered up to a constant from sufficiently different environments; interventions determine the correct causal model). The pointer goes to `sec:discussion:open`, because `q:imit:open` was dropped |
| §3.2 I3 (Zhang et al. in the latent case) | no | – | Related work carries Zhang et al.; left out for length |
| §3.3 optional clauses (Armstrong in gap (2); Shah et al.; Ross et al.) | no | – | left out for length; for the author |

No sentence uses a **[beyond abstract]** item of the record, and none says how the literature was checked (DECISIONS §A8).

---

## 4. Weight decay (synthesis §3)

* **The remark, the appendix subsection and the related-work sentence** were inserted from the drafts unchanged, with the final-check fixes F11a, F11b and F12. The remark and the appendix subsection are byte-identical to `drafts/wd-remark.tex` and `drafts/wd-appendix.tex`.
* **The discussion sentence.** Its text is unchanged. It is joined by a semicolon to the first sentence of "The window and its price", so that the paragraph keeps the three sentences that DECISIONS-restructure §3 requires.
* **BibTeX.**
  * The eleven entries of `drafts/imit.bib` are in `bib/imit.bib`.
  * `zhu2026overfitting` is already in Paper 2.
  * In the PDF all eleven new works are cited and print correctly; the bibliography has 19 entries more than before.
  * `bibtex.log` has no warnings.

---

## 5. Caveats (synthesis §4)

* **The rewritten scope paragraph**, with F8a and F8b, names exactly the four toy cases solved:
  * exact recovery of a computable sampler per query (`thm:recovery:main`);
  * the full table of a noisy random parity at a dyadic flip rate below ¼ for large $d$ (`prop:parity:range`);
  * the teacher, with all its hypotheses (`thm:teacher:main`, `rem:teacher:hypotheses`, `prop:teacher:rates`);
  * near-copies for environment-driven coins (`thm:imit:main`).

  It also says that the last two hold for the population objective only, and from samples only asymptotically or with large constants.
* **The rest of the introduction.** The motivation sentence, the contributions bullet and the table row (F6a, F6b, F7) are in. `prop:imit:cheap` is added to the citations.
* **The discussion paragraph "What the toy cases leave open"** (F9, F10, C6) lists the six gaps with their results:
  1. behaviour, not mechanism;
  2. the person/environment split and $c$ as conventions;
  3. structured errors and couplings;
  4. frozen labels;
  5. memory and in-context learners;
  6. uncomputability and the dependence on the class and the machine.

  It ends: "We see the results as tools for these problems, with toy cases in which the tools work, not as solutions."
* **The open-problems item.** "(7) Imitation" carries the five questions of the dropped `q:imit:open`.
* **The abstract** is unchanged: 1920 characters of source between the environment lines, measured as in D9. It claims nothing about imitation or weight decay, and every claim it makes is unchanged in the body, so it stays truthful. Adding imitation to it would need a cut elsewhere; that is for the author (§8).

---

## 6. Build and checks

* **Isolated build.** `./test-section.sh imit app-imit`: OK, 7 pages, 0 undefined citations; the undefined references are cross-section, as expected.
* **Full build.** `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, run five times while editing. The last run, on the final sources, gives:
  * LaTeX errors: 0;
  * undefined references: 0;
  * undefined citations: 0;
  * multiply defined labels: 0;
  * overfull hboxes above 10 pt: 0. Two boxes below 3 pt remain: one of 1.84 pt, as before, and a new one of 2.75 pt in the unchanged proof paragraph of H.1 (`app-imit.tex`, lines 22–23), within the 10 pt rule;
  * pages: 86;
  * no "??" in the PDF text.
* **DECISIONS §A5** (the vocabulary grep on `pdftotext main.pdf`). The word hits are the title footnote's "independent AI referees", as expected. Every other hit is a formula fragment rendered by pdftotext ($s_0$, $E_0$, $c_1$, $c_2$, $S_1$, $S_2$, $e_1$, $r_0$, …), the same kinds as before. The new pages contribute only $s_0$, in `prop:imit:limits`(b) and App H.4.
* **DECISIONS §A2.5.**
  * The status grep on the PDF returns nothing.
  * `extract_status.py`, run on a scratch copy: Paper 2 has 107 `\status` calls outside comments, 9 more than the 98 before (six for imitation, three for weight decay), and 0 in floats.
  * The 7 calls "outside an environment" are the `question` environments of the body, which the script's environment list omits. They were there before. All new calls are inside theorem-like environments.
* **§B.6.** "Wyeth" does not occur in the PDF.
* **REFRAME.**
  * The new text uses "we"/"our" and cites no author's note.
  * In the PDF, "the author" and "the author's notes" occur only in the title footnote, the proposal footnote, the existing footnote in §5 and the acknowledgements, as before.
* **Restructure FRONT checks** (DECISIONS-restructure §4.7).
  * None of the forbidden strings occurs in the PDF, and `0.1233\le p` does not occur in the sources.
  * The one source hit, "0.545", is in the switched-off `app-verification.tex`, as before.
  * "(o) Level bounds" appears.
* **Companion check.** `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` ends with "ALL OK". Paper 1 cites Paper 2 only as a whole (grep), so the renumbering of §10–§11 and of App H cannot break it.
* **Byte checks.**
  * `bib/core.bib` = `paper/bib/core.bib`.
  * The weight-decay remark and appendix = the drafts.
  * The I1 clause and the §3.1 paragraph = the literature record.
* **SHA-256 prefixes.**

  | file | prefix |
  |---|---|
  | `sections/imit.tex` | `6b395e0843e26df8` |
  | `sections/app-imit.tex` | `92f631c1a755c037` |
  | `bib/imit.bib` | `0bf520accf64cf87` |
  | `main.pdf` | `687c9ff4137fcccf` |

---

## 7. Pages

**Method.** Text-block pages between heading positions, from `pdftotext -bbox`, as in `restructure/log-front.md` §4:
* the text block runs from y = 0.096 to y = 0.909 of the page height;
* the last appendix ends at its last text line;
* the main text runs from the title page to the end of Code and data.

A scratch build of the pre-integration sources, measured the same way, reproduces `log-front.md`: 34.50 / 2.33 / 36.96 / 73.79 there, 34.50 / 2.32 / 36.96 / 73.78 here.

| part | before | after | change |
|---|---|---|---|
| title, abstract, contents | 1.51 | 1.59 | +0.08 (one more contents line) |
| §1 Introduction | 3.28 | 3.80 | +0.52 |
| §2 Related work | 0.97 | 1.36 | +0.39 |
| §3–§7 | 17.95 | 17.96 | +0.01 |
| §8 Teacher | 5.42 | 6.04 | +0.62 (`rem:teacher:weightdecay`) |
| §9 Structured errors | 2.32 | 2.25 | −0.07 (page break) |
| **§10 Imitation (new)** | – | **2.33** | +2.33 |
| §11 Computable classes (was §10) | 0.95 | 0.94 | – |
| §12 Discussion etc. (was §11) | 2.10 | 2.80 | +0.70 |
| **main text** | **34.50** | **39.08** | **+4.58** |
| **references** | **2.32** | **3.69** | **+1.37** (19 new entries) |
| App A–E | 23.87 | 23.79 | −0.08 (page breaks) |
| App F (teacher) | 7.31 | 9.33 | +2.02 (`app:teacher:weightdecay`, about 1.7, and float placement) |
| App G | 3.80 | 3.80 | 0 |
| **App H (imitation, new)** | – | **3.99** | +3.99 |
| App I (was H) | 1.98 | 1.99 | – |
| **appendices** | **36.96** | **42.89** | **+5.93** |
| **total** | **73.78 (74 pages)** | **85.66 (86 pages)** | **+11.88** |

**In whole pages.**
* Main text: pp. 1–40; Code and data ends near the top of p. 40.
* References: pp. 40–43.
* Appendices: pp. 43–86. App H is pp. 80–84.
* `sec:imit` is pp. 34–36: theorem on p. 34, proposition on p. 35.
* `rem:teacher:weightdecay`: p. 27.
* `app:teacher:weightdecay`: pp. 72–75.

**Caps** (DECISIONS-restructure §3, set before this material was requested). They were already exceeded before (main text by 1.00 pp, total by 0.29 pp). Now all three are exceeded:
* main text by 5.58 pp;
* appendices by 5.39 pp;
* total by 12.16 pp.

Nothing further was moved or cut. As §3 of that file requires, the overrun is reported here and in `OUTLINE.md`.

**Why §10 is 2.33 pp and not about 1.3.**
* The synthesis's 2.6-pp full section, minus the four items its §5.3 cut moves out, is still about 2 pp. The definition, the theorem and the proposition alone take about 1.2 pp.
* The requested framing adds about 0.4 pp: the vocabulary tie, the paragraph on what is and is not shown, and the literature sentences.
* The section was tightened twice after the first build (2.64 → 2.41 → 2.33 pp). The second pass moved the in-context-learner argument and the text on $c$ outside the window to App H, and shortened every paragraph.

**Further candidates if pages matter.** Each needs the author's decision.
* §10:
  * move the last two sentences of `thm:imit:main` (the bound on Φ and the program for $P^*$) to App H, about 0.15 pp;
  * drop the proof idea of `prop:imit:limits`, about 0.07 pp.
* Related work: the fallback paragraph of literature §3.1, about −0.25 pp and four fewer references.
* Weight decay (synthesis §5.3):
  * the grokking sentence (3 lines);
  * the paragraph after the proof of `prop:teacher:nofixedprior` (6 lines);
  * the AdamW sentence of the example and the box part of its proof idea (5 lines).
* The earlier candidates REJ-01, REJ-04, REJ-05 and REJ-08 of `restructure/rejected.json`.

---

## 8. Labels

* **New.**
  * In the main text: `sec:imit`, `def:imit:setting`, `thm:imit:main`, `prop:imit:limits`.
  * In App H: `app:imit`, `app:imit:private`, `rem:imit:private`, `app:imit:lemmas`, `lem:imit:coding`, `lem:imit:closeness`, `app:imit:main`, `app:imit:limits`, `app:imit:cheap`, `prop:imit:cheap`.
  * For weight decay: `rem:teacher:weightdecay`, `app:teacher:weightdecay`, `prop:teacher:nofixedprior`, `ex:teacher:weightdecay`.
* **Not created.** `q:imit:open`, which is dropped per §5.3. No source cites it (grep).
* **Renamed.** None.
* **Deleted.** None of Paper 2's existing labels.
* **Renumbered.** `sec:computable` 10 → 11; `sec:discussion` 11 → 12; App H (`app:related`) → App I; the items inside these move with them. In App F, `app:teacher:rates` F.7 → F.8, and `prop:teacher:sharp` becomes F.8's proposition.

---

## 9. Points for the author

1. **Length.** §10 is 2.33 pp, and the paper is 86 pages against the earlier cap of 73.5. The candidates are in §7. Whether the caps of DECISIONS-restructure §3 still apply after this request is your decision.
2. **C4 wording.** The referee's string said "the copies can win far below $2^{-m}$". The text says "it [the program that models the coupling] can lose to the copies far below $2^{-m}$", which is what the referee's proof shows (§2.3).
3. **Novelty paragraph.** `rem:related:new` was not changed. The literature record (§6, point 3) suggests that "the near-imitation theorem and the closeness lemma" could be added under its "To our knowledge". The search behind that was four queries.
4. **The abstract** does not mention imitation or weight decay. It is at its 1920-character cap, so adding them needs a cut.
5. **The weight-decay reading.** Synthesis §7, point 2: the drafts read "as the number of params varies" as "as the sample size varies". This is still to be confirmed.
6. **Armstrong–Mindermann.** It is cited for its abstract only. A comparison with its Kolmogorov-complexity argument would need the full text (literature §6, point 2).
7. **Paper 1** was not edited. Its numbers are unaffected, since it cites Paper 2 only as a whole.

---

## Verification log

* **2026-10-14, reading.** As listed in the header. The referee report and the literature report were read first, in full.
* **Edits.**
  * The six draft diffs were applied with `patch -p1`. A dry run first was clean, and so were the real runs.
  * The new files were written by hand.
  * Every scripted replacement asserted exactly one occurrence of its anchor.
  * After editing, the changed sources were diffed against the backup in the scratchpad. The changes are those of §1: `main.tex` +4 lines; `intro.tex` +7/−2; `related.tex` +8/−1; `teacher.tex` +10; `app-teacher.tex` +47/−14 (14 of these are the moved table, counted on both sides); `discussion.tex` +8/−1; three new files.
* **Builds.**
  * One isolated build.
  * Five full builds, all under the lock: the first integration, the table move, two tightening passes, and the final sources.
  * One scratch build of the pre-integration sources, for the "before" pages.
* **Scripts** (session scratchpad only):
  * `measure.py`, the page measurement;
  * `ledger.py`, the CLAIMS ledger, which reproduces the old ledger exactly apart from the new rows (`diff`);
  * a copy of `extract_status.py` that writes to the scratchpad.
* **Not done.**
  * No new mathematics.
  * No WebSearch: every citation comes from the two verified records.
  * No change to the research records or to Paper 1.
