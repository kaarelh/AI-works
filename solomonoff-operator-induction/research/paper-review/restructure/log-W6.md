# Log of body writer W6 (structured errors, computable classes): Paper 2 restructure

Written 2026-10-13 under `PLAN.md`, `DECISIONS.md` and `REFRAME.md`.

**Files written** (all in `paper-steeper/sections/`): `limits.tex`, `app-limits.tex`, `computable.tex`, `app-related.tex`. No other file was edited. No git command that changes repository state was run (only `git show dcb3a3a3:…` and `git diff --stat`).

**Inputs read:**
* `PLAN.md` in full; `REFRAME.md`; `DECISIONS.md` §0, §A, §B, §C, §E, §F (Paper 2).
* The base `limits.tex`, `app-limits.tex`, `computable.tex`, `app-related.tex`, `related.tex` and `teacher.tex` (`git show dcb3a3a3`).
* `split/notes-final.md` §4, §5 (P9, P10, App plan, label map), §8; `split/final-check.md` rows 17, 18.
* `split/teacher/notes-final.md` §1.1–§2.1 (Lemma 1.1, Def 1.4, Lemma 1.5, Prop 2.1) and §4 (Props 4.1, 4.2, Remark 4.3).
* `split/verify-teacher.md` §1, §2, §3, §5, §10; `split/verify-iid.md` §1.6.
* `split/iid/notes-final.md` Defs 1.1–1.3, Remark 1.4, Cors 6.1, 6.2; `split/kink/notes-final.md` §1 and §5.0 (class assumptions).
* For labels, items and notation only: the working `setup.tex`, `kinks.tex`, `recovery.tex`, `parity.tex`, `app-parity.tex`, `app-split.tex`, `app-setup.tex`, and the logs of W1–W4.

## 1. What each file contains

### `limits.tex`: §9 "When errors have structure: a second kink" (`sec:limits`)

* **Opening.** In `thm:teacher:main` an incompressible rule lies right of the model's kink, on a line of slope $2^{-m}$ (`prop:teacher:kinks`). This section is where the second reason fails: a structured rule has a kink of its own, and selection sorts hull segments by rate, not validity.
* **§9.1 Which error rules defeat steeper selection** (`sec:limits:rules`).
  * The envelope setup (base); a one-line definition of "ε-near-optimal".
  * `prop:limits:envelope` (statement kept), with a proof idea: (i) is `lem:kink:main`(iv) with the envelope's point as reference, $\mathcal N$ = level ≥ 2 (excluded by `thm:teacher:main`(o)), floor $d-4-\Lambda_1$ from (D1); no right line.
  * Paragraph "A second kink": the $c_{\rm env}$ reading (teacher Prop 4.1(a),(b), with both side conditions, final-check row 17). The envelope dominates every noise-like level-1 point or has secant ≥ $c_{\rm env}$ from it, so the right secant (`def:kink:kinks`) is at least $c_{\rm env}$. At every $c<c_{\rm env}$ with $J_e(c)+\epsilon<\Phi_2(c)$ and $\zeta<H(p)-R_e$, every ε-near-optimal program fits strictly better than noise.
  * Numbers paragraph ($j=13$, $j=11$), with the F45 parenthesis on the deficiency kept verbatim.
  * `prop:limits:rateblind` with (ii) in secant form (teacher Prop 4.2; final-check row 18, "implies"), and a proof idea that includes the empty-kink-interval reading.
  * A paragraph that summarises `lem:limits:robust` (now stated in App G, see D-W6-1), with the $d_0$ numbers and the window factor 8500/3800.
* **§9.2 Rate, not validity** (`sec:limits:other`).
  * `prop:limits:separable` (kept, D4), with a one-line proof idea.
  * **`rem:limits:hull`** (new; teacher Remark 4.3 and the base `sec:limits:other` text): selection keeps the segments whose rate exceeds $c$, and nothing in the geometry tells the model's kink from an error's. It points to guard erosion, the input law and non-identifiability (`prop:limits:guard`, `prop:limits:inputlaw`, `prop:limits:noident`, all in App G).
* **§9.3 Unseen properties** (`sec:limits:ood`).
  * A summary paragraph of `prop:limits:ood` (statement in App G, D-W6-2): the $\MF$ bound of Paper 1 Prop 8.1, its $\Hcl{\times}$ form $2^{-\lambda(K(Q,b)+\kappa)}$, posterior odds, and what $\lambda=cn$ does.
  * `q:limits:open`, updated (§3 below).
* Removed: `sec:limits:schedule`, `prop:limits:plain`, `rem:limits:schedule` (given to W5), and every reference to `rem:limits:method` (cut).

### `app-limits.tex`: App G "Proofs for §9 (structured errors)" (`app:limits`)

* **G.1 `app:limits:envelope`.**
  * Proof of `prop:limits:envelope`. (i) is now via `lem:kink:main`(iv), as teacher Prop 2.1(d); (ii) is the base proof, condensed.
  * The numbers, as compact text instead of the two base tables. The values quoted in the main text are all kept.
  * "Envelopes with density θ < 1", which `q:limits:open`(a) cites.
* **G.2 `app:limits:robust`.**
  * Proof of `prop:limits:rateblind`, in secant form with the two dominated cases.
  * **`lem:limits:robust`**: statement (moved here, D-W6-1) and proof.
  * The $d_0$ table, three rows.
* **G.3 `app:limits:guard`.**
  * Proof of `prop:limits:separable`.
  * `prop:limits:guard`: statement with the schema renamed φ, its proof and its numbers, condensed.
  * `prop:limits:noident` with the F42 example after it, and its proof.
  * `prop:limits:inputlaw` and its proof.
* **G.4 `app:limits:ood`.**
  * **`prop:limits:ood`**: statement (moved here, D-W6-2) and proof.
  * The λ = 1 sentence (Paper 1 Prop 8.1(a)) and the conjunction-ladder sentence.
* Removed:
  * `app:limits:plain` and the proof of `prop:limits:plain` (given to W5);
  * `app:limits:method` and `rem:limits:method` (cut, PLAN §3.1).

### `computable.tex`: §10 "Computable hypothesis classes" (`sec:computable`, alias `sec:related:computable`)

* **Opening.** Both reasons survive resource bounds. The recovery theorems use only countability and Kraft; the lower bounds of `sec:parity` and `sec:teacher` use only coding properties.
* **`prop:related:computable`** (a)–(c) as in the base, plus a new item:
  * (d): `thm:recovery:main` and `thm:recovery:kink` hold in every countable product class with Kraft weights that contains a program equal to ν μ-a.e. (time-bounded, circuit or finite), with $\ell_0$, $\mathcal E_0$ and the margins taken in the class's own code (iid Cor 6.2; kink §5.0).
  * New proof idea, which adds two notes. A time-bounded class may select a longer but faster program. With a finite input set the data are per query (`rem:setup:objects`).
  * The classes of `prop:recovery:lambda1` are finite classes of this kind (D-W6-4).
* **`rem:computable:examples`**: two sentences.
* **`prop:related:computability`**: kept, with a two-line proof idea.
* **`rem:related:nn`**: two sentences.
  * It now cites `thm:split:private` and `thm:recovery:main` for countable discretisations with integer code lengths and Kraft weights (iid Def 1.1, Cor 6.2).
  * The bridge-question sentence and the slides credit are kept.
* **`q:related:open`**: kept (D3).

### `app-related.tex`: App H "Proofs for §10 and the correspondence with the earlier report" (`app:related`)

* Proof of `prop:related:computable`, with a new bullet for `thm:recovery:main` and `thm:recovery:kink`.
* Proof of `prop:related:computability` (base).
* **`app:related:t5`.**
  * Opening paragraph: **`rem:related:t5`**, received from FRONT. It is the base `related.tex` paragraph, with the self-pointer replaced by "the table names them as they are named there" and with "a direct computation gives … (an illustration)" wording for $c_{\rm hi}=0.01139$.
  * The correspondence table. Three rows are updated where a cited label's content moved; labels are unchanged:
    * `lem:teacher:sharpfloor`: "used for the full-table kink at every $p<1/4$ (`prop:parity:kink`, `prop:parity:range`)";
    * `cor:teacher:fulltable`: "every rule length $m$; …" (the "$c_{\rm hi}$ for $t^*<2$" note is dropped);
    * `lem:setup:hull`: "adds the data reading (v) and duality (vi)".
  * The "Not reused" paragraph.

## 2. Labels defined (checked against the PLAN §3 manifest by script)

| file | labels | manifest |
|---|---|---|
| `limits.tex` | `sec:limits`, `sec:limits:rules`, `sec:limits:other`, `sec:limits:ood`, `prop:limits:envelope`, `prop:limits:rateblind`, `prop:limits:separable`, `rem:limits:hull` (new, §3.3), `q:limits:open` | all W6, destination `limits.tex` ✓ |
| `app-limits.tex` | `app:limits`, `app:limits:envelope`, `app:limits:robust`, `app:limits:guard`, `app:limits:ood`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw` | ✓ |
| `app-limits.tex` | `lem:limits:robust`, `prop:limits:ood` | manifest says `limits.tex`; **deviations D-W6-1, D-W6-2** (label, statement and items unchanged) |
| `computable.tex` | `sec:computable`, `sec:related:computable`, `prop:related:computable` (items (a)–(d)), `rem:computable:examples`, `prop:related:computability`, `rem:related:nn`, `q:related:open` | ✓ |
| `app-related.tex` | `app:related`, `app:related:t5`, `rem:related:t5` (received) | ✓ |

* **New labels.** No new structural label was created. The only new theorem-like label is `rem:limits:hull`, which is in the manifest.
* **Removed** (absent from my files, checked by grep):
  * given to W5: `sec:limits:schedule`, `prop:limits:plain`, `rem:limits:schedule`, `app:limits:plain`;
  * cut: `rem:limits:method`, `app:limits:method`.
* **Stable item structures** (§3.6) are kept:
  * `prop:limits:envelope` (i),(ii);
  * `prop:limits:rateblind` (i)–(iii);
  * `prop:related:computable` (a)–(d).
* **`q:limits:open`** now has items (a) and (b), not the base (a)–(c) (§3 below). No working file cites an item of it.

## 3. Moves given and received; plan instructions applied

| label(s) | from | to | state |
|---|---|---|---|
| `prop:limits:plain`, `rem:limits:schedule`, `sec:limits:schedule` | W6 `limits.tex` | W5 `teacher.tex` | deleted here; present in W5's working `teacher.tex` |
| `app:limits:plain` | W6 `app-limits.tex` | W5 `app-teacher.tex` | deleted here; present in W5's working `app-teacher.tex` |
| `rem:related:t5` | FRONT `related.tex` | W6 `app-related.tex` | inserted here as the opening paragraph of `app:related:t5`; FRONT deletes it from `related.tex`, which in the working tree still holds it |
| `rem:limits:method`, `app:limits:method` | W6 | — (cut) | deleted. No working file cites `rem:limits:method` any more: W5's `teacher.tex` and `app-teacher.tex` no longer do |

**`q:limits:open`.**
* Old (b), the window for $p<0.123$, is removed. A one-line pointer to `prop:teacher:rates` and `q:teacher:open` opens the question.
* Old (c), the choice of $c$, is now (b).
* (a), envelopes of density θ < 1, is kept.

**`rem:limits:method`** is cut. Its residue, level 1 being impossible for $0.1233\le p<1/4$, is W5's `q:teacher:open`(b).

## 4. Every `\cref` to another group's label

Every label below is in the stable list of PLAN §3.6, or is a §3.2 structural label (`app:recovery`, `app:teacher:computations`).

| group | labels cited (items) | from |
|---|---|---|
| W1 | `def:setup:class`, `app:setup:facts` ((F1)–(F5)), `lem:setup:hull` ((ii), (iii), (v)), `rem:setup:objects`, `prop:absorb:price` ((ii)), `prop:absorb:pricing`, `prop:absorb:history`, `rem:absorb:condsemi`, `thm:absorb:absorption` ((a)) | limits, app-limits, computable, app-related |
| W2 | `def:kink:kinks` (right secant), `lem:kink:main` ((iv)), `rem:kink:reading` | limits, app-limits |
| W3 | `sec:recovery`, `def:split:setting`, `lem:split:ville`, `thm:recovery:main`, `thm:recovery:kink`, `prop:recovery:lambda1`, `thm:split:private`, `app:recovery` (§3.2 section label) | computable, app-related |
| W4 | `sec:parity`, `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart` ((D1), (D2)), `lem:teacher:sharpfloor`, `prop:parity:kink`, `prop:parity:range`, `prop:algstat:parity` ((i)) | limits, app-limits, computable, app-related |
| W5 | `sec:teacher`, `thm:teacher:main` ((o), (i), (ii), (iii), (iv)), `prop:teacher:kinks`, `prop:teacher:rates`, `q:teacher:open`, `rem:teacher:hanni`, `cor:teacher:fulltable`, `lem:teacher:finite`, `app:teacher:computations` (§3.2) | limits, app-limits, computable, app-related |

* **No [V-T] label is cited.** `lem:kink:secant` is not used; the secant claims cite `def:kink:kinks`.
* **Labels of mine cited by other working files** (grep): `sec:limits`, `prop:limits:envelope`, `prop:limits:inputlaw`, `prop:limits:separable`, `prop:related:computable`. All exist. `rem:limits:schedule` and `prop:limits:plain`, cited by `setup.tex`, `intro.tex`, `related.tex` and `discussion.tex`, now live in W5's file.

## 5. [V-T] items

* **`prop:limits:envelope`(i) via `lem:kink:main`(iv).** This depends on the final form of the kink lemma. `verify-teacher.md` §1–§2: Lemma 1.1 (real $g$, pointwise margin, (iv)) is **verified**. So (i) is proved as one application of (iv), as teacher Prop 2.1(d), and the base proof is not kept. W2's `lem:kink:main` is in that final form, with (iv) as I use it.
* **No other item of mine depends on `verify-teacher.md`.**
  * Teacher Props 4.1 and 4.2 and Remark 4.3 were refereed and are cited as such (`verify-teacher.md`, "Not checked here").
  * The case distinction in the rate-blindness secant form (the memoriser or the coin may dominate the point) follows the proof of teacher Prop 4.2. `verify-teacher.md` §5 notes that it handles that case correctly.

## 6. Mathematics against the records

| label | record | status used | note |
|---|---|---|---|
| `prop:limits:envelope` | steeper Prop 2.17; teacher Prop 2.1(d), Prop 4.1 | proved (refereed; Lemma 1.1 final form verified) | statement unchanged; $c_{\rm env}$ reading with both side conditions (final-check row 17) |
| `prop:limits:rateblind` | steeper Prop 2.11; teacher Prop 4.2 | refereed | (ii): under (⋆), unless $\ell(\pi_b)\le\ell(\pi)$ or $R(\pi)\ge1$, the memoriser's secant ≥ the coin's; then the base conclusion. "Implies", per final-check row 18 |
| `lem:limits:robust` | steeper Lemma 2.11a | proved | "Fix $m$ and $s_0$", where the base had "$m$ and $r$": the generalised instance (`def:teacher:instance`, W4) has no $r$. The proof uses $p$ only through $H(p)$, and $\Lambda_1$, $\kappa_b$, $L_S$ do not involve $r$ (PLAN §4.5; W4's check). With $B=\infty$, $\kappa_b=2\log d+2\log m+2\log s_0+\kappa$ as in W4's instance |
| `prop:limits:separable`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw`, `prop:limits:ood` | steeper Props 2.12–2.16 | proved | statements unchanged; notation only (§7) |
| `rem:limits:hull` | teacher Remark 4.3 | remark | nothing beyond the cited results |
| `prop:related:computable`(d) | iid Cor 6.2 (Thms 3.1, 3.2, 4.1 use only countability, Kraft, a program for ν); kink §5.0 (class: countable product class with Kraft sum ≤ 1, e.g. time-bounded or circuit subclass) | proved | W3's `def:split:setting` already states its theorems for every such class; (d) records this for resource-bounded classes |
| `rem:related:nn` | steeper Rem 4.7; iid Def 1.1, Cor 6.2 | remark | narrowed to integer code lengths with Kraft weights, which is what Def 1.1 covers (the base said "weights $p(\theta)$") |

* **Computed numbers.**
  * Every number is outside the statements, introduced with "a direct computation (code in the accompanying repository) gives …".
  * κ = 0 values say "with the machine constant set to 0 (an illustration)" at first use in each paragraph.
  * No script id is printed.
* **Statuses rendered** (DECISIONS §A1):
  * "proved; computed": numbers after the statement;
  * "(i) known" (`prop:limits:noident`): `\citep{gneiting2007strictly}`;
  * "open": question environments;
  * "remark": plain.
* **Visible-text greps** on both isolated PDFs:
  * the DECISIONS §A5 vocabulary grep, plus "verified|refereed|synthesis|withdrawn|corrected|the author|notes": the only hits are formula renderings ($S_1$, $e_1$, $s_0$, $\mathcal E_0$);
  * no Wyeth, no `hanni2026notes` or `hanni2026grokking`, no footnote, in any of my files.

## 7. Notation (PLAN §4) and local renamings

* **Guard erosion.**
  * Schema σ → **φ** (PLAN §4.2 item 9).
  * Its two rates $\rho_\sigma,\rho_G$ → **$\sigma_\varphi,\sigma_G$**, and in the proof of `prop:limits:separable` $\rho_v,\rho_e$ → **$\sigma_v,\sigma_e$**. ρ is the structure function ($\rho_D$, $\rho_{\rm pop}$), and the rates are exactly the hull-edge slopes $\sigma_i$ of `lem:setup:hull`(v).
  * $g_G,\Delta_G$ are now inlined in the statement.
* **`prop:limits:noident`.** The population selection $h_c$ → **$\pi_c$**: $h_n$ is the per-query sample, and PLAN §4.2 item 8 asks for $\pi_c$.
* **`prop:limits:separable`.** "Regions $X_1,\dots,X_k$" → **"finitely many regions $X_j$"**, because $k$ is the length of $\pi_\nu$ (`def:split:setting`). The extra lengths $k_j$ are kept.
* **Simulation prefix.** It stays σ in the proof of `prop:limits:ood` (DECISIONS §E; W3 uses the same).
* **"ε-near-optimal"** is defined in one line in §9.1, as $J_c(\pi)\le\Phi(c)+\epsilon$. The plan wants no $\mathcal N_\epsilon(c)$.
* **No new preamble macro.**

## 8. Deviations from the plan, with reasons

* **D-W6-1. `lem:limits:robust` is stated in App G** (`app:limits:robust`), not in `limits.tex`.
  * §9.1 keeps a one-paragraph summary: (⋆) holds beyond a threshold $d_0(\kappa)$ linear in κ, with the numbers sentence.
  * Reason: the main-text page budget (§9 below).
  * The label, the statement and the items (i)–(iii) are unchanged.
* **D-W6-2. `prop:limits:ood` is stated in App G** (`app:limits:ood`).
  * §9.3 keeps a summary paragraph with both conclusions and the λ = cn reading. The synthesis plans "prop:limits:ood (one paragraph)".
  * Reason: the page budget.
  * The label, the statement and the items are unchanged.
* **D-W6-3. The $c_{\rm env}$ reading is a paragraph after `prop:limits:envelope`, not a new item**, so the stable items (i), (ii) are untouched. Its secant claim has a two-line argument in the text: (D1) and the envelope's length bound.
* **D-W6-4. `prop:related:computable`(d) does not say that `prop:recovery:lambda1` "holds in every subclass".**
  * That proposition is about two explicit classes, $\mathcal C_k$ and $\mathcal C_{k,M}$, so the plan's wording would not be meaningful for it.
  * The proof idea says instead that those classes are finite classes of this kind. `verify-iid.md` §1.6 (F2) notes that $\mathcal C_k$ is finite for finite $D$.
  * (d) states `thm:recovery:main` and `thm:recovery:kink` for every countable Kraft class containing a program for ν. iid Cor 6.2 and kink §5.0 cover both.
* **D-W6-5. `q:limits:open` items renumbered** (a), (b) (§3).
* **D-W6-6. Cuts** (PLAN §6 optional material first, then for the budget):
  * the three-hypothesis illustration of App G;
  * the explicit-class envelope sentence (lower end 15.0 → … → empty);
  * the paragraph "Illustrations at κ = 0";
  * the brute-force confirmation sentence after `prop:limits:inputlaw`;
  * the minimisation-identity re-check after the envelope proof (DECISIONS §A9);
  * two of the five rows of the $d_0$ table (the 4-bit and 7-bit prefixes);
  * the κ = 10 values of $c_{\rm env}$ and the intermediate $e_1$ columns;
  * the second guard-erosion instance, reduced to one clause.

  The base "So density and description length alone do not suffice" paragraph is shortened; its F45 parenthesis is kept verbatim.

## 9. Pages (isolated builds; positions from `pdftotext -bbox`, bibliography excluded)

| file | budget (PLAN §6) | measured | base (same method) |
|---|---|---|---|
| `limits.tex` | 1.75 | **≈ 2.3** | 3.25 (of which ≈ 1.0 now in W5's §8.1) |
| `app-limits.tex` | 2.75 | **≈ 3.7** | 5.05 (of which ≈ 1.2 given to W5 or cut) |
| `computable.tex` | 0.5 | **≈ 1.0** | ≈ 1.0 |
| `app-related.tex` | 1.25 | **≈ 1.85** | ≈ 1.5 (plus the 0.25-page `rem:related:t5` paragraph received) |
| **W6 main** | 2.25 | **≈ 3.3** | |
| **W6 appendices** | 4.0 | **≈ 5.55** | |

Measured from my files alone, the content kept is about the base size, minus what moved to W5. The plan's budgets assumed about 2.5 more pages of condensation.

**What I did.**
* Two statements went to App G (D-W6-1, D-W6-2).
* Every optional cut of PLAN §6 for W6 was made (D-W6-6).
* All prose was condensed.
* I did not drop any proof, or any statement that the plan keeps.

**Options for FRONT if the caps bind** (each a placement change or a cut of computed illustrations only):
1. Move `prop:related:computability` and its proof idea to App H, with one sentence in §10 (about −0.2 main).
2. Move `rem:computable:examples` to App H, with one sentence (about −0.1 main).
3. In App G, drop the $d_0$ table and keep its two quoted rows in one sentence (about −0.2 app).
4. In App G, drop the conjunction-ladder sentence (about −0.07 app).
5. In App H, drop the "Not reused" paragraph (about −0.12 app).

## 10. Builds

* `./test-section.sh limits app-limits` → `OK: pages 7; 0 undefined citations; 36 undefined refs`.
* `./test-section.sh computable app-related` → `OK: pages 4; 0 undefined citations; 57 undefined refs`.
* The undefined references are all other groups' labels (§4), plus, in the second build, my own `prop:limits:*` labels, which are defined in the other pair. None of them is a W6 label of the same pair.
* 0 overfull boxes and 0 multiply defined labels in both. The only 2 underfull boxes are in the bibliography entry of `vaintrobhanni2026nnbayes`.

## 11. Paper 1 citations

* **No new Paper 1 citation.** Used, each with a `% P1:` comment and in the PLAN's known list:
  * Proposition 8.1 and 8.1(a) (`prop:ood:hanni`);
  * Theorem 9.10 and Remark G.11 (`thm:comp:ladder`, `rem:comp:uniformties`);
  * Section 9.1 (`sec:comp:time`; I corrected the base comment, which named `thm:comp:timebounded`);
  * Proposition A.10(c) (`prop:setting:computability`);
  * Proposition 10.1 (`prop:nn:functionspace`);
  * Question 10.9 and Remark H.2 (`q:nn:bridges`, `rem:nn:bridge`).
* Corollary 5.4 is no longer cited from my files; it went to W5 with `prop:limits:plain`.
* `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` (read-only, no Paper 1 build): last line **ALL OK**.
  * Its "used not in intended" entry, Theorem 5.1, comes from W1's `absorb.tex`, not from my files.

## Fixes (fix round, DECISIONS-restructure)

Applied `fix-W6.json` (4 entries: RW6-01 major; RW6-02, RW6-03, RW6-04 minor) as decided in `DECISIONS-restructure.md` §2 (D10, D11(x), D11(y)) and §3 (W6 length actions). Only `limits.tex`, `app-limits.tex`, `computable.tex` and `app-related.tex` were edited. No git command that changes repository state was run. No label was renamed, created or deleted. Two labels changed file, as the decision requires: `sec:limits:ood` and `prop:related:computability`. The union of labels over the four files is unchanged (checked by script against the pre-fix copies).

### id → change

* **RW6-01 (length).**
  * **(1) §9.3 to App G.**
    * The subsection "Unseen properties" (`sec:limits:ood`) is removed from `limits.tex`.
    * Its paragraph is now the opening of `app:limits:ood`, verbatim, including the Paper 1 citation `\citep[Proposition~8.1]{claudeSFI2026fundamentals}` with its `% P1: prop:ood:hanni` comment.
    * `\label{sec:limits:ood}` is an alias on the `app:limits:ood` subsection. No file cites `sec:limits:ood`.
    * The decided sentence ends the prose of §9.2, verbatim, after `rem:limits:hull`: "Off the training support the shortest hypotheses that fit the data decide, so steeper SFI extrapolates more reliably than SFI if they extrapolate well and is more confidently wrong if they do not (\cref{prop:limits:ood})."
    * `q:limits:open`, which used to close §9.3, now closes §9.2. It is the last element of the section, as the question of every other section is (DECISIONS §A10). So the sentence ends the prose of §9.2, and the question environment follows it.
  * **(2) `prop:related:computability` to App H.**
    * The statement, label, `\status{proved}` and `\src{steeper Prop 4.5}` now stand in `app-related.tex`, directly before its proof.
    * The decided sentence replaces it in §10, verbatim, at the same place, between `rem:computable:examples` and `rem:related:nn`. Its omitted hypotheses are standing assumptions: $X=\{0,1\}^*$ is infinite and $|Y|\ge2$ (`setup.tex` l.16). So the sentence is not stronger than the proposition.
    * The proof idea is folded into the proof, because the two are now adjacent. Its first clause (uniform lower semicomputability gives (a) and (c)) is what proof parts (a) and (c) already say. Its Paper 1 citation now opens (b): "This is the diagonal argument for $\MF$ \citep[Proposition~A.10(c)]{…}", with `% P1: prop:setting:computability`. No content is lost.
  * **(3) `rem:computable:examples` cut to 3 lines.** It was 6 lines in the full build. It now reads: "Examples are probabilistic programs clocked at $t(|x|)$ steps [P1 §9.1], and circuits with private output noise, where a parity costs about $d\log d$ bits. \Cref{thm:absorb:absorption} does not transfer: a mixture of all time-$t$ programs is not a time-$t$ program." Three remark-level clauses were dropped:
    * generous time bounds change $\kappa_g,\kappa_b$ by logarithmic terms;
    * $c_{\rm hi}$ shrinks by a factor of order $\log d$;
    * the product/shared contrast is established only for unbounded classes. `q:related:open`(a) still asks this.

    No other file cites these clauses (grep).
  * **(4) $d_0$ table to one sentence.**
    * The three-row table in `app:limits:robust` is replaced by one sentence. It keeps the two rows that the base main text quoted, one $3$-bit prefix (49, 90, 130, 169, 245, 434) and one $6$-bit prefix (450, 639, 823, 1005, 1364, 2248), at $\kappa=0$ (an illustration), 10, 20, 30, 50 and 100.
    * It keeps "a direct computation (code in the accompanying repository)", $\beta_0\ge\alpha_0/\ln2$, and "$(\star)$ fails at $d_0-1$ and holds at $d_0$".
    * The row "$m=6$, $p=1/8$ (eight $6$-bit prefixes)" is dropped.
  * **(5) Envelope paragraph tightened** (`limits.tex`, with RW6-02).
    * The clause "the extreme case is a cheap, frequent rule" is dropped, and the $j=11$ parenthesis is compacted.
    * The F45 parenthesis is kept verbatim (DECISIONS F45).
  * **Further prose trims for the section targets.** Each removes a duplicate. No statement or computed number is removed.
    * The "A second kink" paragraph is cut from 6 to 5 lines. Its sentence "By (i), at every slope $c<c_{\rm env}$ … every $\epsilon$-near-optimal program fits strictly better than noise" repeated the second sentence of `prop:limits:envelope`(i). It is now "So, under its side conditions, (i) excludes near-optimal fits no better than noise below $c_{\rm env}$, whereas …".
    * In the proof idea of `prop:limits:rateblind`, the clause "below the first the memoriser wins, at or above the second the coin wins or ties" is dropped. It restated (ii).
    * Two sentences of the $d_0$ paragraph are joined.
    * In the opening of §9, "the segments of the hull" becomes "hull segments".
    * In the proof idea of `prop:related:computable`, the clause "In (d) a time-bounded class may select a longer but faster program than $\Hcl{\times}$ would" is dropped. The proof in App H states it.
* **RW6-02 (numbers, D10).**
  * In `limits.tex`, "at least $0.545$" → "at least $0.544$" (value 0.54494), and "($25\%$ at $\kappa=30$)" → "($24\%$ at $\kappa=30$)" (share 0.24932).
  * In `app-limits.tex`, "($0.42$ and $0.25$ at $\kappa=30$)" → "($0.42$ and $0.24$ …)", and "$0.862$ and $0.545$ for $\delta_2=0$" → "$0.862$ and $0.544$ …".
  * Checked against `scratch/lead_envelope_numbers.out`. The window end $8.06\cdot10^{-3}$ quoted in the paragraph is also safe ($c_{\rm hi}=8.0618\cdot10^{-3}$).
  * A grep for "0.545", "0.199", "3.66" and "0.955" in both isolated PDFs returns nothing.
* **RW6-03 (D11(x)).** In the proof idea of `prop:related:computable`, the text "…inputs repeat, so the data are per query (\cref{rem:setup:objects})." is replaced by the exact decided text: "…inputs repeat, so (d) concerns per-query labels; with frozen labels the data eventually form one table (\cref{rem:recovery:frozentable})." The clause before it was dropped in RW6-01, so the sentence now begins "With a finite input set, as for circuits on $\{0,1\}^d$, …". `rem:recovery:frozentable` is defined in W3's `app-recovery.tex`.
* **RW6-04 (D11(y)).** The last sentence of `app:related:t5` is deleted: "The scripts of the earlier report reproduce its numbers (\cref{app:teacher:computations})." `app-related.tex` no longer cites `app:teacher:computations`.

### Items moved between main text and appendix (this round)

| item | from | to | pointer left |
|---|---|---|---|
| text of §9.3, with `sec:limits:ood` (now an alias) | `limits.tex` §9.3 | `app-limits.tex`, opening of `app:limits:ood` | one sentence at the end of the prose of §9.2, citing `prop:limits:ood` |
| `prop:related:computability` (statement, label, status, src; its proof idea folded into the proof) | `computable.tex` | `app-related.tex`, before its proof | one sentence in §10 |

### Pages after the last isolated build

* `./test-section.sh limits app-limits` → `OK: pages 7; 0 undefined citations; 36 undefined refs`.
* `./test-section.sh computable app-related` → `OK: pages 4; 0 undefined citations; 56 undefined refs`.
* In both builds: 0 overfull boxes and 0 multiply defined labels. Every undefined reference is a label defined in another group's file (checked by grep). The only 2 underfull boxes are in the bibliography entry `vaintrobhanni2026nnbayes`.

**How the pages were measured.**
* Content height, from `pdftotext -bbox-layout`, excluding white space at the bottom of each page.
* "Sim." is the same files built in the scratchpad with the `\newlabel`s of the last full build (`main.aux`, 22:20) loaded. References then have their full-build widths.
* On the pre-fix files this method gives 2.43 pp for §9, equal to the measurement in DECISIONS-restructure §3.

| part | DECISIONS-restructure §3: now → target (±0.15) | before this round (isolated / sim.) | after (isolated / sim.) |
|---|---|---|---|
| §9 `limits.tex` | 2.43 → 2.1 | 2.31 / 2.43 | **2.19 / 2.20** |
| §10 `computable.tex` | 1.12 → 0.8 | 1.00 / 1.00 | **0.86 / 0.86** |
| App G `app-limits.tex` | 4.05 → 4.0 | 3.63 / 3.65 | **3.70 / 3.72** |
| App H `app-related.tex` | 1.99 → 2.2 | 1.87 / 1.88 | **1.97 / 1.97** |

* All four parts are within their target's tolerance.
* §10's "now" value of 1.12 included white space at the bottom of a page, where Question 10.5 moved to the next page.
* App G's 4.05 included `tab:teacher:rates`, which floats in from App F (math2 m10, W5's fix).

### Checks

* **Visible text.** The §A5 vocabulary grep on both isolated PDFs, extended by "0.545|0.199|3.66|0.955", hits only formula renderings ($S_1$, $e_1$, $s_0$, $\mathcal E_0$).
* **Companion numbers.** `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` (read-only; Paper 1 was not built): last line **ALL OK**.
  * Its "used not in intended" entry, Theorem~5.1, is in W1's `absorb.tex`.
  * The Paper 1 citations in my files are unchanged. They are Proposition 8.1 and 8.1(a), Theorem 9.10, Remark G.11, Section 9.1, Proposition A.10(c), Proposition 10.1, Question 10.9 and Remark H.2. Two of them moved within my files: Proposition 8.1 to App G, and Proposition A.10(c) to App H.
* **For FRONT.**
  * `OUTLINE.md` and `CLAIMS.md` should record that §9 now has two subsections, with `sec:limits:ood` an alias in App G.4.
  * They should also record that `prop:related:computability` is now stated in App H.
