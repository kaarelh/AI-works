# Log of body writer W5 (teacher): `teacher.tex`, `app-teacher.tex`

Written 2026-10-13 under `PLAN.md`, `DECISIONS.md` and `REFRAME.md`.
* Files edited: only `paper-steeper/sections/teacher.tex` and `paper-steeper/sections/app-teacher.tex`.
* No git command that changes repository state was run.
* Base versions were read with `git show dcb3a3a3:…`: `teacher.tex`, `app-teacher.tex`, `limits.tex`, `app-limits.tex`. My two working files were identical to the base when I started.
* Records read:
  * `split/teacher/notes-final.md`, in full;
  * `split/verify-teacher.md`, in full;
  * the synthesis §0, §1, §4, §5, §6, §8;
  * `final-check.md` §1–§4;
  * the outputs `teacher/checks/t6_exact_window.out` and `teacher/verify_code/v5_junta_constants.out`, for the printed numbers.
* Other groups' working files were read, never edited, to align notation: `kinks.tex`, `parity.tex`, `app-parity.tex`, `setup.tex`, `recovery.tex`, and the logs of W1–W4.

**Build.** `./test-section.sh teacher app-teacher` reports `OK: pages 14; 0 undefined citations; 53 undefined refs`.
* The log has no overfull or underfull boxes and no multiply defined labels.
* All 53 undefined references are to other groups' labels; the 29 distinct ones are listed in §3.

---

## 1. What each file contains

### `teacher.tex`: §8 "The teacher's mistakes: the split at a positive rate" (`sec:teacher`)

* **Opening (5 lines).** States that this section gives the second reason, and that it is the split of `sec:kinks` at a positive rate:
  * a bit of noise enters one likelihood term, so a fixed λ > 1 discards it;
  * a bit of an error rule enters the term of every input it governs, so λ must grow with n.
* **§8.1 From noise to errors** (`sec:teacher:hanni`, alias `sec:limits:schedule`):
  * `rem:teacher:hanni`, shortened. Item (1), the hull picture with slopes 100 and 10, is kept in full. Item (2) is reduced to its rates and its window. The "direct computation" sentence is kept.
  * The reuse factor, defined in words, then `lem:teacher:reuse` with a one-line proof inline.
  * FQ, defined in two sentences, and one paragraph that summarises `prop:teacher:frozen` (FR against FQ) and `prop:limits:plain`. Both statements are in App F (deviation D-W5-1).
  * `prop:teacher:schedules` (a)–(c), with its proof idea and a one-sentence reading.
  * `rem:limits:schedule`, rewritten: reuse factor, deliberate inconsistency, batch excess, and the literature sentences, including the binding "We do not claim as new …" sentence verbatim.
* **§8.2 The two kink bounds and the theorem** (`sec:teacher:theorem`):
  * A display of the theorem's quantities: $t^*$, $\Phi_2$, $J_g$, $J_b$, $\Lambda_2$, $\Lambda_3$, $\Delta(c)$ and $c_{\rm hi}$. $\psi_c$ and $\Phi_1$ are gone; $\Lambda_2$ and $\Lambda_3$ moved here from (ii).
  * `prop:teacher:kinks` (a) left (margin and wedge) and (b) right (the line of slope $2^{-m}$, offset $\Lambda_2/2^m$, length floor $d-4-\Lambda_1$; $\Lambda_2\ge0$ for $p<\frac14$).
  * `thm:teacher:main`, with the base items (o), (i), (ii)(a)–(e), (iii), (iv):
    * (o) keeps the level-1 bound with $\psi_c$ written out as a maximum;
    * (i) writes $\Phi_1$ out as $c(d-4-\Lambda_1)+B_S/2^m$;
    * (ii)(a) is the corrected (a1) with $R_{\max}$ (§4).
  * The proof idea via `lem:kink:main`.
  * A reading paragraph that adds the reuse-factor sentence.
  * `rem:teacher:numbers` (shortened) and `tab:teacher:numbers` (unchanged), then `rem:teacher:hypotheses` and `rem:teacher:selected`.
* **§8.3 Full tables and samples** (`sec:teacher:more`):
  * `cor:teacher:fulltable` (i) every m, (ii) the λ = 1 tie, (iii) the memoriser.
  * A reading paragraph: the reuse factor $2^{d-m}$; for m = d the link to `thm:split:lambda1`; the d = 20 window.
  * The samples paragraph, reduced to the one self-proving lower-bound sentence (PLAN §6, W5's first optional cut).
  * `cor:teacher:sampled` and a two-sentence paragraph.
* **§8.4 Flip rates below 0.1233** (`sec:teacher:rates`, new):
  * the definitions of $\mathrm{Floor}_t$, $\Psi_t$, $LB_t$ and $\Phi_2^\sharp$;
  * `prop:teacher:sharp` (i)–(iv);
  * the definitions of $\psi_2$ and $a^*$;
  * `prop:teacher:rates`, with the decimals after it;
  * `q:teacher:open` (a)–(e).

### `app-teacher.tex`: App F "Proofs for §8 (the teacher's mistakes)" (`app:teacher`)

* **F.1 Noise and errors: frozen noise, plain Bayes and schedules** (`app:teacher:schedules`, new):
  * `prop:teacher:frozen` (statement and proof);
  * `prop:limits:plain` (statement, the 9.6·10⁻²⁴ sentence, proof; it also carries the label `app:limits:plain`);
  * the proof of `prop:teacher:schedules`.
* **F.2 The kink bounds and the theorem** (`app:teacher:main`):
  * the proof of (o);
  * the proof of `prop:teacher:kinks`;
  * the proof of (i)–(iv). (i), (ii)(b) and (ii)(c) go through `lem:kink:main`. (ii)(e) uses the V side of W4's proof of `lem:teacher:sharpfloor`, with the budget from (d); a one-sentence summary of the argument is kept.
  * The paragraph "Numbers" (`app:teacher:computations`), with the memoriser regime as one sentence instead of a table.
* **F.3 Full truth tables** (`app:teacher:fulltable`): the proof of `cor:teacher:fulltable`, and the λ = 2 bounds at d = 20 as one sentence. The λ = 105 columns are cut (PLAN §6 optional cut).
* **F.4 Finite samples** (`app:teacher:sampled`): `lem:teacher:finite` with its proof, the proof of `cor:teacher:sampled`, and the sample-size numbers as one sentence.
* **F.5 The total-bits version** (`app:teacher:version1`): `ex:teacher:version1`, shortened. The "In more detail" paragraph is cut (PLAN §6 optional cut); its finite-sample point is now the last sentence of the example.
* **F.6 Concentration** (`app:teacher:concentration`): `prop:teacher:concentration` with a shortened proof and one example sentence.
* **F.7 Charging the information about the rule** (`app:teacher:rates`, new):
  * the proofs of `prop:teacher:sharp` (including the continuity of $\Phi_2^\sharp$) and of `prop:teacher:rates` (including both readings);
  * the strict monotonicity of $\psi_2(p,1)-H(p)$, by the derivative bound of V-T §9;
  * `tab:teacher:rates`.

---

## 2. Labels defined (checked against PLAN §3)

| label | file | manifest | note |
|---|---|---|---|
| `sec:teacher` | teacher | §3.2 | |
| `sec:teacher:hanni` | teacher | §3.2 | on §8.1 |
| `sec:limits:schedule` | teacher | §3.2, alias on "From noise to errors" | received from W6 |
| `sec:teacher:theorem`, `sec:teacher:more` | teacher | §3.2 | |
| `sec:teacher:rates` | teacher | **new structural** (prefix `teacher`) | §8.4 |
| `rem:teacher:hanni` | teacher | §3.1 | shortened as planned |
| `lem:teacher:reuse` | teacher | §3.3 [V-T] | **created** (verified) |
| `prop:teacher:schedules` | teacher | §3.3 [V-T], items (a)–(c) | **created** (verified, with V-T §6 wording fixes) |
| `rem:limits:schedule` | teacher | §3.1 | received from W6; rewritten |
| `prop:teacher:kinks` | teacher | §3.3, items (a), (b) | |
| `thm:teacher:main` | teacher | §3.1, items (o), (i), (ii)(a)–(e), (iii), (iv) | numbering kept |
| `rem:teacher:numbers`, `tab:teacher:numbers` | teacher | §3.1 | |
| `rem:teacher:hypotheses` | teacher | §3.1 | rewritten as the map from hypotheses to sides of the kink |
| `rem:teacher:selected` | teacher | §3.3 | |
| `cor:teacher:fulltable` | teacher | §3.1, items (i)–(iii) | merged as planned |
| `cor:teacher:sampled` | teacher | §3.1 | |
| `prop:teacher:sharp` | teacher | §3.3 | items (i)–(iv), numbered by W5 |
| `prop:teacher:rates` | teacher | §3.3 | |
| `q:teacher:open` | teacher | §3.1 / §3.4, items (a)–(e) | |
| `app:teacher`, `app:teacher:main`, `app:teacher:computations`, `app:teacher:fulltable`, `app:teacher:sampled`, `app:teacher:version1`, `app:teacher:concentration` | app-teacher | §3.2 | |
| `app:limits:plain` | app-teacher | §3.2 | received from W6. It sits on the `prop:limits:plain` environment, so `\cref` prints "Proposition F.n" |
| `app:teacher:schedules`, `app:teacher:rates` | app-teacher | **new structural** | |
| `prop:teacher:frozen` | **app-teacher** | §3.3 [V-T], destination `teacher.tex` | **created** (verified); placed in App F (D-W5-1) |
| `prop:limits:plain` | **app-teacher** | §3.1, destination `teacher.tex` | received from W6; statement kept; placed in App F (D-W5-1) |
| `tab:teacher:rates` | **app-teacher** | §3.3, destination `teacher.tex` | placed in App F (D-W5-1) |
| `lem:teacher:finite`, `ex:teacher:version1`, `prop:teacher:concentration` | app-teacher | §3.1 | |

* Every W5 label of PLAN §3.1–§3.3 exists exactly once in my files.
* No label was renamed.
* No theorem-like label outside the manifest was created.
* No `eq:` labels were added.

**Removed from my files (moved to W4):**
* `def:teacher:instance`;
* `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart`, `lem:teacher:sharpfloor`;
* `sec:teacher:instance`, `sec:teacher:lemmas`;
* `eq:teacher:identity`, `app:teacher:list`, `app:teacher:lemmas`;
* the notation box.

All of these exist in W4's `parity.tex` / `app-parity.tex`.

**Cut label:** `rem:limits:method` is not cited anywhere in my files. The old item (4) of `rem:teacher:hypotheses` now points to `prop:teacher:rates`.

---

## 3. References to other groups' labels

All are in the stable lists of PLAN §3.6, except `sec:parity:full` (see the W4 row).

| group | labels cited |
|---|---|
| W1 | `app:setup:facts`, `def:setup:data`, `rem:setup:persample`, `thm:absorb:absorption`(d) |
| W2 | `sec:kinks`, `def:kink:kinks`, `lem:kink:main` (items (i), (ii), (v)) |
| W3 | `sec:recovery`, `def:split:setting`, `lem:split:ville`, `thm:recovery:main`, `thm:split:private`(i), `thm:split:lambda1` |
| W4 | `def:teacher:instance`, `sec:teacher:lemmas`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:sharpfloor` (statement, and "the V side of its proof" in the proofs of (ii)(e) and of `prop:teacher:sharp`), `prop:parity:kink`, `prop:parity:range`(iii), and `sec:parity:full`, a W4 structural label that exists in `parity.tex`; I cite it for $p_0$ and $p_1$ and their uniqueness (W4 proves that in `app-parity.tex`) |
| W6 | `sec:limits`, `prop:limits:envelope`, `prop:limits:inputlaw`, `prop:limits:separable`, `prop:related:computable` |
| FRONT | `rem:related:mdl` |

Symbols I use as W4 defines them: $e(\pi)$, now in `def:teacher:instance`(d); $\gamma_g(I)$ and $F^\sharp_t$ from `sec:teacher:lemmas`.

---

## 4. [V-T] items and outcomes (`verify-teacher.md`)

No item is "not verified", so every [V-T] label exists. FRONT does not need to remove any.

| item | V-T verdict | used as |
|---|---|---|
| Lemma 3.0 → `lem:teacher:reuse` | verified | Stated with the reference point scaled, $(\alpha_{\rm r},L_{\rm r})\mapsto(\alpha_{\rm r},rL_{\rm r})$, as V-T §4 asks. |
| Prop 3.6 → `prop:teacher:schedules` | verified, with two wording fixes | (c) has "B < ∞ an integer in $[\log(1/p),\infty)$, $c_{\rm hi}$ computed at this B". The $\Phi_2^\sharp$ extension is `prop:teacher:sharp`(iv), "every compact $[c_1,c_2]\subset\{c>2^{-m}:J_g<\Phi_2^\sharp\}$", with the continuity of $\Phi_2^\sharp$ proved in F.7 by the argument of V-T §6. The almost-sure form is restricted to PQ data. |
| Prop 3.7 → `prop:teacher:frozen` | verified | (b) is stated for every program whose kernel equals ν on supp μ (V-T §7, "rejects every other program for ν"). The condition "ν(F(x)\|x) < 1 for some x ∈ A" and $\pi_A\in\mathcal C$ are kept. The main-text summary says "if the class can memorise the table at finitely many inputs" (final-check rows 15, 23). |
| Remark 2.6 → (ii)(a) and (a2) | verified with correction | Only the corrected $R_{\max}:=J_g(c)+\epsilon-c(d-4-\Lambda_1)^+$, which is never weaker than the base (a). (a1) replaces the base (ii)(a). (a2) is in `prop:teacher:sharp`(iii). |
| Prop 3.1(c) | verified with correction | Only bullet 1 is used (verified as stated), as one sentence after `cor:teacher:fulltable`: the right line of slope $2^{d-m}$, i.e. `prop:teacher:kinks`(b) multiplied by N. Bullets 2–3, which need $p<\frac14$ and a case distinction, are **not stated** (budget). |
| Prop 5.3 → `prop:teacher:rates` | verified; readings corrected | The claim is stated for $a>a^*(p)$, $B=\infty$, dyadic $p\in(0,\frac14)$. The readings are stated as explicit conditions: "$a^*<\infty$ iff $1-\log(\frac32-p)>H(p)$" and "$a^*=1$ iff $\psi_2(p,1)\ge H(p)$" (V-T: "≤ p*", not "< p*"). Decimals appear only after the statement: roots $p_1=0.1233072\ldots$ (cited from W4) and $p^*=0.0778658\ldots$, with the sufficient conditions rounded down to $p\le0.1233$ and $p\le0.0778$. The uniqueness of the $p^*$ crossing is proved in F.7 by V-T §9's derivative bound, which I re-derived ($y^*\in[0.7385,1.359]$, middle term ≥ 0.463, $h'<-0.2$). |
| Exact windows (t6(B), v5(F)) | reproduced | `tab:teacher:rates` prints open windows (V-T §9: open at the upper end), lower ends rounded up and upper ends rounded down from t6's printed values. |
| "$p<0.0560$" | V-T §9 correction | Replaced by "holds exactly for $p<p_0=0.05596\ldots$ (`sec:parity:full`)" in §8.2, and by "$G_1>H(p)$" in `rem:teacher:hypotheses`(4). |
| Def 1.4 (example offset) | verified with correction | Not used in my files. |

---

## 5. Moves given and received

| label(s) | from | to | state now |
|---|---|---|---|
| `def:teacher:instance`, the four lemmas, `sec:teacher:instance`, `sec:teacher:lemmas`, the notation box | W5 `teacher.tex` | W4 `parity.tex` | removed from my file; present in W4's |
| `lem:teacher:sharpfloor`, `eq:teacher:identity`, `app:teacher:list`, `app:teacher:lemmas` | W5 `app-teacher.tex` | W4 | removed from my file; present in W4's |
| `prop:limits:plain`, `rem:limits:schedule`, `sec:limits:schedule` | W6 `limits.tex` | W5 | inserted here (`prop:limits:plain` in App F). **W6's `limits.tex` still has all three (unchanged base when I last looked); multiply defined until W6 removes them.** |
| `app:limits:plain` | W6 `app-limits.tex` | W5 `app-teacher.tex` | inserted here. **W6's `app-limits.tex` still has it; W6 must delete its §D.1.** |

---

## 6. Deviations from the plan, with reasons

* **D-W5-1. Three main-text items are placed in App F:** `prop:teacher:frozen`, `prop:limits:plain` and `tab:teacher:rates`.
  * §8.1 has a one-paragraph summary of the first two, and §8.4 a one-sentence summary of the table. Each cites the label.
  * Reason: the page budget (§7). W1, W2, W3 and W4 made the same kind of move.
  * Labels, statements and items are unchanged, so every `\cref` resolves.
* **D-W5-2. The samples paragraph is one sentence: the memoriser's secant lower bound.** It is self-proving: fit 0, and (D1) bounds the length difference.
  * Not stated: the equal-multiplicity right line of teacher Prop 3.3(b), and the covering fill-in "1" of Prop 3.3(a), which needs iid Lemma 5.2 (not stated in the paper, per D8).
  * The unequal-multiplicity conjecture is `q:teacher:open`(d).
  * This is PLAN §6's first optional cut for W5.
* **D-W5-3. `rem:teacher:numbers` keeps `tab:teacher:numbers` as computed with the base (a) ($J_g+\epsilon$ in the exponent).** One sentence gives the improvement under the new $R_{\max}$: $u\ge0.988$, $e\le0.194$ (v5(D)). The table stays valid because its bounds are weaker. Regenerating it would need a new run of the base scripts.
* **D-W5-4. `thm:teacher:main` keeps (o) and (i) in base form without the symbols $\psi_c$ and $\Phi_1$.**
  * (o) writes $\psi_c(R)=\max\{R,cB_S-(c2^m-1)R\}$ out.
  * (i) writes $\Phi_1(c)=c(d-4-\Lambda_1)+B_S/2^m$ out.
  * $\Delta(c)$ keeps the base definition with $\max\{0,\cdot\}$; one sentence says that it equals the kink lemma's $\Delta(c)$ for $c\ge2^{-m}$ when $\Lambda_2\ge0$.
* **D-W5-5. `prop:teacher:sharp` has four items:** (i) the information charge (Lemma 5.1); (ii) $J^B_c\ge LB_t$, $\Phi_2^\sharp\ge\Phi_2$, continuity; (iii) `thm:teacher:main`(i),(ii) on the window, plus (a2); (iv) the schedules extension.
  * (iv) and the continuity are the V-T §6 corrections to the record's closing sentence of Prop 3.6.
  * (a2) sits here because the table's $u$ and $e$ columns need it.
* **D-W5-6. `ex:teacher:version1` is shortened, and the last paragraph of `prop:teacher:concentration` is reduced to one example sentence.** Dropped:
  * the κ = 5, 10, 20 values of $c_{\rm hi}$ (the example now says only that the window is nonempty at κ = 0, 5, 10, 20, 30);
  * the c = 1.5·10⁻³ … 4·10⁻³ bounds;
  * the comparison instance (d = 13);
  * the $n=10^{13}$ value of $\epsilon'$;
  * the exact small instance at λ = 0.936 after the full table.
* **D-W5-7. Three numeric tables of App C became sentences:** the memoriser band, the d = 20 full-table bounds (λ = 2 only) and the finite-sample table. Every number printed is from the base text.
* **D-W5-8. The proof of (ii)(e) cites the V side of W4's proof of `lem:teacher:sharpfloor`** (in `app-parity.tex`) with the budget $\Delta_\ell+\Lambda_3\ge I(\pi)$, instead of repeating it. W4 does the same for `prop:parity:range`(f). A one-sentence summary of the argument is kept.
* **D-W5-9. Base computed re-checks were dropped:** "2830 random instances confirm the reduction" and "the earlier report's scripts give the same window". DECISIONS §A9 allows this.
* **D-W5-10. `rem:teacher:selected` gives the 67.7–88.6% range from teacher §2.1 (t5(A), rA1(A)).** It does not give the explicit-class numbers of t5(B), for space.
* **D-W5-11. Local notation** (PLAN §4.2, last line):
  * The record's $\theta_m$ is not named, because $\theta_t$ is the level threshold of `def:teacher:instance`. The memoriser threshold is written out: $NH(p)/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$.
  * The record's $m_N$, $M$, $N$, $\ell_0$, $F_0$, $g$ appear only as W2's $\eta_{\mathcal N}$, $\mathcal M$, $\mathcal N$ and $(\alpha_{\rm r},L_{\rm r})$. The offset is always written instantiated, $\Lambda_2/2^m$.
  * New local symbols: $\mathrm{loss}_\pi(x)$ and $\tau_B$ (appendix only); $\mathrm{Floor}_t$, $\Psi_t$, $LB_t$, $\Phi_2^\sharp$, $\psi_2$ and $a^*$ (§8.4).
* **D-W5-12. Generalised instance.** With W4's general $s_0$ (PLAN §4.5), `prop:limits:plain`(a),(c) state the bound as $d+\lceil L_S\rceil+\kappa_b+\kappa$. The base's "$d+L_S+O(\log d+\log m)$" is stated only for $p=2^{-r}$, where the memoriser names $s_0$ through r; for general $s_0$, $\kappa_b$ contains $2\log s_0$. (b) says "fixed m, p and error rule" instead of "m, r".

---

## 7. Pages (isolated build; positions of the headings, bibliography excluded)

| file | budget (PLAN §6) | measured | parts |
|---|---|---|---|
| `teacher.tex` (§8) | 4.75 | **6.16** | opening 0.19; 8.1 1.41; 8.2 2.40; 8.3 0.89; 8.4 1.27 |
| `app-teacher.tex` (App F) | 4.5 | **6.64** | F.1 1.67; F.2 1.31; F.3 0.34; F.4 0.65; F.5 0.29; F.6 0.55; F.7 1.66 (with the table) |

**Why over.** The plan's 4.75 pp hold:
* the base teacher material that stays (about 3.9 pp of the base 5.5);
* `prop:limits:plain` and `rem:limits:schedule` from limits (about 1 pp);
* eight new statements with proof ideas: reuse, schedules, frozen, kinks, selected, sharp, rates, and the rates table.

The guide "8.1 from noise to errors 1.0" alone was meant to hold five results. App F's 4.5 pp were based on base App C minus the lemma proofs (about 4.7 pp). They do not include the proof of `prop:limits:plain` (about 0.6) or the five new proofs (about 2.2). Cuts already made: D-W5-1, -2, -6, -7, -8, -9, every optional cut of PLAN §6 for W5, and two compression passes over all proofs and remarks.

**Further cuts if FRONT needs them** (each changes a placement or content the plan fixes, so each is FRONT's decision):
1. Move `prop:teacher:schedules` to App F, with a three-line summary (−0.35 pp main).
2. Move the $\mathrm{Floor}_t/\Psi_t/LB_t$ display and `prop:teacher:sharp`(i),(ii) to App F, stating `prop:teacher:sharp` in words with a pointer (−0.3 pp main).
3. Move `rem:teacher:hypotheses` and `rem:teacher:selected` to App F (−0.3 pp main).
4. Delete `prop:teacher:concentration` (−0.55 pp app). Nothing outside my files cites it.
5. Delete `ex:teacher:version1` (−0.3 pp app). `intro.tex`'s optional claims-table row cites it.
6. Drop the $p^*$ reading of `prop:teacher:rates` and its monotonicity proof (−0.3 pp app, −2 lines main).

---

## 8. Status rendering (DECISIONS §A1)

| label | status | rendered as |
|---|---|---|
| `rem:teacher:hanni` | computed | "a direct computation (code in the accompanying repository) gives …" inside the remark |
| `lem:teacher:reuse`, `prop:teacher:schedules`, `prop:teacher:kinks`, `prop:teacher:sharp`, `prop:teacher:rates`, `cor:teacher:fulltable`, `cor:teacher:sampled`, `prop:limits:plain`, `prop:teacher:concentration` | proved; computed | Theorem-like statement with proof. Every computed number is outside the statement, with "a direct computation …", and κ = 0 is marked "(an illustration)" at first use. |
| `rem:teacher:numbers`, `tab:teacher:numbers`, `tab:teacher:rates` | computed | "a direct computation"; captions say that κ = 0 rows are illustrations and state the rounding |
| `rem:teacher:selected` | remark; computed; a natural strengthening refuted | "The natural strengthening that … fails in explicit rate codes", with the numbers introduced by "a direct computation", κ marked as an illustration, and "In $\Hcl{\times}$ nothing is claimed either way" |
| `rem:limits:schedule` | remark (from proved results); known | cites the results; "We do not claim as new …" and abstract-level literature (DECISIONS §A8) |
| `ex:teacher:version1` | proved (instance); computed | Example with "a direct computation"; κ = 0 marked |
| `q:teacher:open` | open | `question` environment; (b) is a precise question, not a conjecture |
| `thm:teacher:main`, `prop:teacher:frozen`, `lem:teacher:finite` | proved | plain |

**Visible-text checks.**
* The DECISIONS §A5 grep, plus "refuted", "verified", "withdrawn", "corrected", "record", "notes", "the author", "Hänni", "synthesis", "iid" and "T5", was run on `pdftotext` of the isolated build (without the bibliography). The only hits are formula fragments ($c_1$, $c_2$, $s_0$).
* No footnotes.
* No "the good model is selected" or "is a vertex", except as the refuted strengthening in `rem:teacher:selected`.

---

## 9. Paper 1 citations

* One citation: `\citet[Corollary~5.4]{claudeSFI2026fundamentals}% P1: cor:learn:mistakes` (in App F, `prop:limits:plain`). It is in PLAN §7.1's list.
* `check_companion_numbers.py` was run (read-only; no Paper 1 build) and ends with `ALL OK`.
* Its "used not in intended: Theorem~5.1" comes from another group's file, not from mine.

---

## 10. Points for FRONT and other writers

* **W6:** delete `prop:limits:plain`, `rem:limits:schedule` and `sec:limits:schedule` from `limits.tex`, and §D.1 (`app:limits:plain`) from `app-limits.tex`. All four now exist in my files.
* **FRONT, intro and abstract:**
  * `intro.tex` says "flip rates below 0.056". Per V-T §9 the exact statement is "$G_1>H(p)$, i.e. $p<p_0=0.05596\ldots$"; a sufficient decimal is $p<0.05596$.
  * Asymptotic windows exist for dyadic $p\le0.1233$, and they start at the reuse factor ($a^*=1$) for $p\le0.0778$.
  * `cor:teacher:fulltable` items: (ii) is the λ = 1 tie and (iii) is the memoriser.
* **FRONT, discussion table** `tab:discussion:reasons`: the reuse-factor row can cite `lem:teacher:reuse`; the "what defeats it" row for noise can cite `prop:teacher:frozen` (FQ).
* **The status-rendering grep** (DECISIONS §A2.5) should find no inline `\status` in my files. Tables carry no `\status` or `\src`.

---

## Fixes (fix round, DECISIONS-restructure; `fix-W5.json`)

All 15 entries applied, in `teacher.tex` and `app-teacher.tex` only. Labels unchanged; no new labels. Exact texts of DECISIONS-restructure D5, D6, D10, D11(o)–(w) used verbatim; the deviations are listed after the table.

| id | change |
|---|---|
| RW5-01 | `thm:teacher:main`: `\begin{enumerate}[label=(\roman*),start=1,…]` and `\item[(o)] \emph{Level bounds.}` (D5). Isolated build and a full build of a scratch copy print "(o) Level bounds." followed by (i)–(iv). Citations "(o)" checked: `limits.tex` (proof idea of `prop:limits:envelope`), `computable.tex` (`prop:related:computable`(a)), `app-limits.tex`, and App F ("We prove (o)", proof of `thm:teacher:main`(o), proof of `prop:teacher:kinks`, proof of (iii), proof of `prop:teacher:sharp`(ii),(iii)). |
| RW5-02 | D6 (W5 part) verbatim: `prop:teacher:kinks` begins "Let $B=\infty$ or let $B\ge\log(1/p)$ be an integer."; `thm:teacher:main` "with $B=\infty$ or an integer $B\ge\log(1/p)$,"; samples paragraph "let $B\ge\log(1/p)$ be an integer," (capitalised at the start of its sentence after RW5-04(4)). "(with $B$ as in \cref{thm:teacher:main})" added in `prop:teacher:sharp`(iii) (after "in place of $\Phi_2$") and in `prop:teacher:concentration` (after the definition of $\epsilon'$). Unchanged as decided: `prop:teacher:schedules`(c), `prop:limits:plain`(b), `lem:teacher:finite`. |
| RW5-03 | D10: the four rows of `tab:teacher:numbers` (0.983, d+20.5, 37.8, 37.8, 0.200; 0.983, d+20.7, 38.0, 58.0, 0.218; 0.981, d+51.1, 98.3, 98.3, 0.274; 0.981, d+51.3, 98.5, 118.5, 0.287), checked against `restructure/scratch/lead_teacher_numbers.out`; caption "Lower bounds are rounded down and upper bounds up."; `rem:teacher:numbers`: $e\le0.195$, $(9.54\cdot10^{-7},\,3.65\cdot10^{-3}]$ at κ = 30, "about $6\%$ ($\kappa=0$; about $11\%$ at $\kappa=30$)". The paragraph after the theorem ("at most $0.2$ to $0.29$") unchanged. |
| RW5-04 | (1) Moved to App F.7 (`app:teacher:rates`), before the proof: the display of $\mathrm{Floor}_t$, $\Psi_t$, $LB_t$, $\Phi_2^\sharp$ with its defining sentence, and `prop:teacher:sharp` (statement, items, label, `\status`, `\src` unchanged apart from RW5-02). §8.4 now has the decided paragraph verbatim, then the $cI$/$\gamma_g$ paragraph, $\psi_2$, $a^*$, `prop:teacher:rates` and the paragraph after it. (2) `rem:limits:schedule`: the Zhu et al. sentence, "We do not claim as new …" and "Their target is …" deleted; "literature: \cref{rem:related:mdl}" added to the batch-excess sentence. (3) FQ paragraph: 8 → 6 rendered lines, with the citations of `prop:teacher:frozen` and `prop:limits:plain`. (4) Samples paragraph before `cor:teacher:sampled`: 5 → 4 lines. The paragraph after the corollary was already two sentences; its first sentence was shortened. |
| RW5-05 | App F.2 "Numbers": $e\ge0.954$, $0.830$, $0.658$, $0.483$, $0.222$ (κ = 0) and $0.916$, $0.705$, $0.456$, $0.255$, $0.059$ (κ = 30), as in `lead_memoriser_numbers.out` rounded down. |
| RW5-06 | `q:teacher:open`(b): "For $p_1\le p<\frac14$ and $m<d$, with $p_1=0.1233072\ldots$ as in \cref{sec:parity:full}, …" (D11(o)). |
| RW5-07 | Title of `prop:teacher:rates`: "A window for every flip rate below $p_1$, asymptotically" (D11(p)). The subsection title "Flip rates below 0.1233" stays. |
| RW5-08 | `lem:teacher:reuse`, second sentence: D11(q) verbatim. |
| RW5-09 | FQ paragraph: "for fixed $\lambda>1$ every $\lambda$-MAP is at most $(k+\delta^*)/(\lambda-1)$ bits longer than the sampler's program, at every $n$" (D11(r)). |
| RW5-10 | D11(s): "$\delta\in(0,1)$," in `prop:teacher:schedules`(c) before $\epsilon_1$; "Let $B<\infty$, $\delta\in(0,1)$, let $\lambda=…$" in `prop:limits:plain`(b); in `prop:teacher:frozen`(a) "where $\delta^*$ is the Ville deficiency of $\xi_{\mathcal C}$ along the distinct inputs (\cref{lem:split:ville}), so $\Prob[\delta^*\ge j]\le2^{-j}$". |
| RW5-11 | D11(t) appended verbatim to (iii) of the proof of `prop:teacher:sharp`. |
| RW5-12 | $\Gamma_g\to T_g$ (App F opening paragraph and proof of (ii)(e)); $t_0\to t_c$ in the continuity step of the proof of `prop:teacher:sharp` (6 occurrences). No other $T_g$ or $t_c$ in Paper 2. |
| RW5-13 | The $B=30$, $\delta=0.01$ sentence removed from the proof of `prop:limits:plain`(b) and appended to the "For instance" paragraph with the D11(v) wording ("(machine constant $0$, an illustration)", "the same computation"). |
| RW5-14 | `tab:teacher:rates` is now `[!ht]`, placed directly before the paragraph that cites it in App F.7. No package added. Caption: the D11(w) sentence appended. A full build of a scratch copy of `paper-steeper/` (sources as of this fix, other groups' files included; the repository's `main.pdf` was not touched) puts Table 6 on p. 68, before its paragraph, and the heading of Appendix G at the top of p. 69. |
| RW5-15 | Covered by RW5-04(2). The literature sentences and "We do not claim as new …" now appear only in `related.tex` (`rem:related:mdl`); checked by grep. |

**Deviations from the exact texts, all layout or coherence, none in mathematics:**
* RW5-04(2): "literature: \cref{rem:related:mdl}" is merged into the closing parenthesis of the batch-excess sentence: "(not a sequential regret, \cref{rem:setup:persample}; literature: \cref{rem:related:mdl})". This avoids two adjacent parentheses.
* RW5-04(1):
  * The proof idea of `prop:teacher:sharp` was dropped, because its full proof now follows directly.
  * The first sentence of the moved paragraph ("The left bound $\Phi_2$ charges …") was dropped, because it repeats the new §8.4 paragraph. App F.7 opens with the definitions.
  * In §8.4, $\gamma_g(I)$ and $\Psi_2$ lost their local definitions in the move. So "the sharp floor" became "the sharp floor of \cref{sec:teacher:lemmas}", and the proof idea of `prop:teacher:rates` says "the level-$2$ term $\Psi_2$ of $\Phi_2^\sharp$ (\cref{app:teacher:rates})".
* RW5-04(3): to reach six lines the FQ paragraph lost these items:
  * "So the object matters.";
  * the fit formula (FQ is now "a fixed table $F$ queried at i.i.d. inputs", counted per query);
  * "per sample it tends to the risk $R$";
  * the PQ-with-$\delta_{y^*}$ remark, which `prop:teacher:schedules` states;
  * the examples "a teacher, or a sampler's table drawn once";
  * the $\Mprod$/$\MF$ exception count, which is in `prop:limits:plain`(a);
  * "Per query:".

  The FR sentence (D11(r)), the FQ consequence with its citation, and the plain-Bayes sentence with its citation are kept.
* RW5-04(4): the memoriser sentence now reads "beats $\pi_g$ at every $\lambda$ below $F_g/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)\approx n2^{-m}$, with $F_g:=-\log\nu_{\pi_g}(D)\approx nH(p)$". The interpretation "the sampled inputs per cell" is dropped; the reuse factor is explained after the theorem and in `rem:limits:schedule`.
* Further prose trims in App F, for its page target (no content removed):
  * the remark after `lem:teacher:finite` is shortened;
  * the sentence after `prop:teacher:frozen` is shortened ("in FQ frozen noise needs $\lambda$ of order $n/|X_0|$, like errors with $m=d$").

**Moved between main text and appendix:** `prop:teacher:sharp`, with the $\mathrm{Floor}_t/\Psi_t/LB_t/\Phi_2^\sharp$ display and its defining sentence, moved from §8.4 to App F.7. Nothing else.

**Pages** (isolated build `./test-section.sh teacher app-teacher`, heading positions, bibliography excluded; before → after):

| part | before | after | target (§3) |
|---|---|---|---|
| §8 total | 6.16 | **5.45** | 5.3 ± 0.15 |
| §8 parts | opening 0.19; 8.1 1.41; 8.2 2.40; 8.3 0.89; 8.4 1.27 | opening 0.19; 8.1 1.24; 8.2 2.37; 8.3 0.82; 8.4 0.82 | |
| App F total | 6.64 | **7.17** | 7.0 ± 0.15 |
| App F parts | F.1 1.67; F.2 1.31; F.3 0.34; F.4 0.65; F.5 0.29; F.6 0.55; F.7 1.66 | opening 0.17; F.1 1.67; F.2 1.30; F.3 0.35; F.4 0.67; F.5 0.29; F.6 0.59; F.7 2.14 | |

* §8 is at the upper edge of its tolerance.
* App F is 0.02 pp above it. The excess equals what the decided additions bring:
  * D11(s): the Ville-deficiency clause;
  * D11(t): the $\Lambda_2$ step;
  * D11(w): the caption sentence.

  Further small trims did not move the end of App F: the page breaks around displays and proofs absorb them.
* Full build of the scratch copy (74 pp; 0 errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull boxes above 10 pt):
  * §8 is 5.42 pp.
  * App F is 7.30 pp from its heading to the heading of App G. This includes about a quarter page left blank at the bottom of p. 68, because the heading of App G moves to p. 69.

**Checks.**
* The isolated build reports OK, with 0 undefined citations and no overfull boxes.
* None of these strings occurs in the PDF text of the isolated build or in my sources: "0.199", "3.66", "0.545", "0.955", "() Level", `0.1233\le p`.
* "(o) Level bounds" is present.
* The process-vocabulary grep (DECISIONS §A5 plus the list of §8 above) on the rendered text finds only the Paper 1 citation \citet[Corollary~5.4]{claudeSFI2026fundamentals}, which is unchanged.
* `check_companion_numbers.py` (read-only, no Paper 1 build) ends with ALL OK. Its "used not in intended: Theorem~5.1" does not come from my files.
