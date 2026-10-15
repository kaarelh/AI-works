# Log of body writer W2 (kinks): `kinks.tex`, `app-kinks.tex`

Written 2026-10-13 under `PLAN.md`, `DECISIONS.md` and `REFRAME.md`. Both files are new, in `paper-steeper/sections/`. No other file was edited, and no git command that changes repository state was run.

**Build.** `./test-section.sh kinks app-kinks` reports `OK: pages 5; 0 undefined citations; 24 undefined refs`. All 24 are references to other groups' labels (listed below), as expected in isolation. The build has no overfull or underfull boxes.

## 1. What each file contains

### `kinks.tex`: §5 "Kinks: the model–randomness split on one data set" (`sec:kinks`)

* **Opening paragraph.**
  * The base `algstat.tex` sentences on looking for a change of slope.
  * The change-of-slope footnote (moved from `algstat.tex`, text unchanged, D6), attached to the sentence that introduces the change of slope.
  * Where the section sits: the geometry common to both reasons, with noise (§6) or an error rule (§8) to the right of the kink.
* **§5.1 The product structure function** (`sec:kinks:structure`, alias `sec:algstat:product`):
  * `def:algstat:product`, rewritten as the plan asks: point family; $\rho$ for any point family; $\rho_D$, $\rho^\times_D$; $\breve\rho$; $\rho_{\rm pop}$; $b$-sufficient in any data-set class (product-$b$-sufficient in $\Hcl{\times}$); $\sophx_b$.
  * Paragraph "The hull": λ-MAPs for every λ > 0. It uses the vertex notation $v_i=(\alpha_i,\rho_i)$, $\sigma_i$ of `lem:setup:hull`(v), which W1's current file uses identically. It defines the "λ-interval" $(\sigma_{i+1},\sigma_i)$ of a vertex, and notes that the lower boundary of $C$ is the graph of $\breve\rho$, with the proof in App C.1.
* **§5.2 Kinks, the kink lemma and the split** (`sec:kinks:lemma`):
  * `def:kink:kinks`: the two-fit setting $L'\le L$; bounded point $(\alpha_{\rm r},L_{\rm r})$; left kink $(\sigma,w)$; right kink $(\tau,w_+)$; $(\sigma,\tau)$-kink; right line $(\tau,g)$ on $\mathcal M$ with length floor $\ell_{\mathcal M}$; right secant $s_+$; left steepness $s_-$.
  * A paragraph after the definition:
    * a zero-window $(\sigma,\tau)$-kink holds iff $s_-\ge\sigma$ and $s_+\le\tau$;
    * the window variant: a right line $(\tau,g)$ with $g\ge0$ gives a right kink of flatness τ′ and window $g/(\tau'-\tau)$;
    * a pointer to `lem:kink:secant`.
  * A paragraph defining $J_c$, $J'_c$, $\Phi(c)$, the reference value $J_{\rm r}(c):=c\alpha_{\rm r}+L_{\rm r}$ and the left margin $\eta_{\mathcal N}(c)$, with the data and population readings.
  * `lem:kink:main` in the final form (i)–(v), with its proof idea.
  * `cor:kink:locate` (a)–(c), with its proof idea.
  * `cor:kink:split` (a), (b), with its proof idea.
  * One paragraph:
    * the product-sophistication bound (`prop:algstat:product`, now in App C);
    * "the content of (b) is σ > 1";
    * pointers to `thm:recovery:kink` and `prop:parity:kink`.
  * `thm:kink:converse`, with its proof idea.
  * `prop:kink:universal` (i), (ii), with its proof idea.
  * `rem:kink:reading`.
* **Pages:** about **2.6** (measured from the isolated build by the vertical position of the appendix heading).

### `app-kinks.tex`: App C "Proofs for §5 (kinks)" (`app:kinks`)

* **C.1 The hull is the graph of the convex minorant** (`app:kinks:hull`). $\breve\rho=\underline C$, the lower boundary, from `lem:setup:hull`(v),(vi). This is kink Thm 2.1(ii),(iii), proved from the polygon structure.
* **C.2 The kink lemma, and lines against secants** (`app:kinks:lemma`).
  * The proof of `lem:kink:main` (teacher Lemma 1.1 final form and Remark 1.2). It uses the verification report's observation that $g\ge0$ under the hypotheses of (ii).
  * The remark that (ii) is vacuous when every bounding program lies in $\mathcal N$.
  * The corrected Def 1.4 offset $g=L_{\rm r}+\tau(\alpha_{\rm r}-\ell_{\mathcal M})$.
  * **`lem:kink:secant`** (statement and proof; see deviation 1).
* **C.3 Kinks on one data set** (`app:kinks:data`).
  * Proofs of `cor:kink:locate`, `cor:kink:split`, `thm:kink:converse` and `prop:kink:universal`.
  * The strictness examples of V-K §6: $\{(0,10),(1,5),(2,0)\}$ and $\{(0,10),(2,0)\}$.
  * **`prop:algstat:product`** (statement kept from the base, and a proof from `cor:kink:split`(a); see deviation 2).
* **Pages:** about **2.0**.

## 2. Labels defined (checked against the manifest, PLAN §3)

| label | file | manifest | note |
|---|---|---|---|
| `sec:kinks` | kinks | §3.2 new section label (W2) | |
| `sec:algstat:product` | kinks | §3.2, alias on the subsection with `def:algstat:product` | received from W4 |
| `def:algstat:product` | kinks | §3.1, moved and rewritten | received from W4 |
| `def:kink:kinks` | kinks | §3.3 | |
| `lem:kink:main` | kinks | §3.3, items (i)–(v) as listed | final form (V-T verified) |
| `cor:kink:locate` | kinks | §3.3, items (a)–(c) | |
| `cor:kink:split` | kinks | §3.3, items (a), (b) | |
| `thm:kink:converse` | kinks | §3.3 | |
| `prop:kink:universal` | kinks | §3.3, items (i), (ii) | with the V-K §5 correction |
| `rem:kink:reading` | kinks | §3.3 | |
| `app:kinks` | app-kinks | §3.2 new section label (W2) | |
| `lem:kink:secant` | **app-kinks** | §3.3 (conditional [V-T]) | items (a)–(c); verified, so created; placed in App C (deviation 1) |
| `prop:algstat:product` | **app-kinks** | §3.1, destination `kinks.tex` | statement kept; placed in App C (deviation 2) |
| `sec:kinks:structure` | kinks | **new structural** (prefix `kinks`) | |
| `sec:kinks:lemma` | kinks | **new structural** | |
| `app:kinks:hull` | app-kinks | **new structural** | cited from the main text |
| `app:kinks:lemma` | app-kinks | **new structural** | |
| `app:kinks:data` | app-kinks | **new structural** | |

Every W2 label of PLAN §3.3 exists: `def:kink:kinks`, `lem:kink:main`, `cor:kink:locate`, `lem:kink:secant`, `cor:kink:split`, `thm:kink:converse`, `prop:kink:universal`, `rem:kink:reading`. So do the received labels `def:algstat:product`, `prop:algstat:product`, `sec:algstat:product`, and the new `sec:kinks` and `app:kinks`. No label was renamed. No theorem-like label outside the manifest was created.

## 3. Moves given and received

| label | from | to | status in the working tree now |
|---|---|---|---|
| `def:algstat:product`, `sec:algstat:product` | W4 `algstat.tex` | W2 `kinks.tex` | inserted here; still in W4's unemptied `algstat.tex` (expected during the write phase; W4 empties it) |
| `prop:algstat:product` | W4 `app-algstat.tex` | W2 (`app-kinks.tex`) | inserted here; still in W4's unemptied `app-algstat.tex` (same) |
| the change-of-slope footnote | W4 `algstat.tex` | W2 `kinks.tex` | inserted, text unchanged |

W2 gives no label away.

## 4. References to other groups' labels

All are in the stable lists of PLAN §3.6.

* **W1:**
  * `def:setup:class`, `def:setup:data`, `rem:setup:persample`, `lem:setup:coding`, `lem:setup:basic`;
  * `lem:setup:hull` with items (ii), (iii), (v), (vi);
  * `eq:absorb:dom`, `thm:absorb:absorption`(a), `cor:absorb:nouniversal`.
* **W3:** `sec:recovery`, `thm:recovery:kink`.
* **W4:** `rem:algstat:reading`, `rem:algstat:near1`, `def:teacher:instance` (for $R_B$), `prop:parity:kink`.
* **W5:** `sec:teacher`.
* **W6:** `sec:limits`.

W1's current `setup.tex` and `absorb.tex` already cite `sec:kinks`, `def:kink:kinks`, `cor:kink:split` and `prop:kink:universal`. Their notation, $(\sigma,w)$ at $(\alpha_{\rm r},L_{\rm r})$ and $\underline C$, matches these files.

## 5. Verification-dependent items

| item | report | outcome | how used |
|---|---|---|---|
| `lem:kink:main`, final form (real $g$, pointwise margin, (iv)) | verify-teacher §2 | **verified** | stated in the final form with two fits $L'\le L$ (V-T §10 item 1). The fallback of PLAN §3.4 is not needed. The proof uses V-T's observation that $g\ge0$ under (ii). |
| `lem:kink:secant` (teacher Lemma 1.5) | verify-teacher §3 | **verified** ((c) for λ ≥ 0) | label created; (c) is stated for $0\le c<s_+$ and $c>s_+$ |
| `def:kink:kinks`, right line and secant (teacher Def 1.4) | verify-teacher §3 | **verified with correction** | only the corrected offset $g=L_{\rm r}+\tau(\alpha_{\rm r}-\ell_{\mathcal M})$ is printed (App C.2). The hull sentence on $s_+$ is not printed. |
| `prop:kink:universal`(ii) | verify-kink §5 | **verified with a minor correction** | printed with "and, if $\ell_U+\kappa_0>0$, only then" |
| `cor:kink:locate`, strictness (kink Remark 3.2′) | verify-kink §6 | **verified** | examples in App C.3, exactly as in V-K §6 |
| `cor:kink:split`, `thm:kink:converse`, `prop:kink:universal`(i), kink Thms 2.1–2.2 | refereed | proved | as in the record |

So `lem:kink:secant` exists unconditionally. FRONT does not need to remove it.

## 6. Notation (for W3, W5, W6 and FRONT)

* **Reference point and kinks.**
  * Reference point $(\alpha_{\rm r},L_{\rm r})$; bounding program $\pi_{\rm r}$.
  * Left kink $(\sigma,w)$; right kink $(\tau,w_+)$; right line $(\tau,g)$ with *length floor* $\ell_{\mathcal M}$.
  * Right secant $s_+$ and left steepness $s_-$, both in `def:kink:kinks`. For `thm:recovery:kink`(v): with $\mathcal M=\mathcal P$ and $L'=L$, a zero-window $(\sigma,\tau)$-kink holds iff $s_-\ge\sigma$ and $s_+\le\tau$ (the sentence after the definition).
* **Kink lemma.**
  * Partition $\mathcal M\sqcup\mathcal N$; left margin $\eta_{\mathcal N}(c)$; reference value $J_{\rm r}(c):=c\alpha_{\rm r}+L_{\rm r}$ (new, local).
  * $\Delta(c):=g+(c-\tau)(\alpha_{\rm r}-\ell_{\mathcal M})$. With teacher Prop 2.1's instantiation ($\tau=2^{-m}$, $g=\Lambda_2/2^m$, $\ell_{\mathcal M}=d-4-\Lambda_1$, reference $(d+\kappa_g,H(p))$, $L=R$, $L'=R_B$), this $\Delta(c)$ is exactly the $\Delta(c)$ of `thm:teacher:main` (record Prop 2.1(c)). So W5 can say so.
  * **Wedge margin $\vartheta$**, renamed from the record's μ, which is the input law in §6. For `prop:teacher:kinks`(a): `lem:kink:main`(v) with $\sigma=c_{\rm hi}$ and $\vartheta=G_1-H(p)$.
  * The offset $g$ appears only in these two files, as PLAN §4.2 item 6 requires.
* **Data and population readings.**
  * Data reading: $L=L'=L(\cdot;o)$, $c=\lambda$.
  * Population reading: $L=R$, $L'\le R$ (e.g. $R_B$ of `def:teacher:instance`), $c=\lambda/n$.
  * `prop:limits:envelope`(i) is `lem:kink:main`(iv) (no right line needed).
* **Local symbols in the appendix.**
  * $\varsigma(\pi)$, the secant of one program: renamed from $s(\pi)$, to avoid the teacher's $s(t)$.
  * $\underline C$, the lower boundary, as in W1's `lem:setup:hull`(vi).
* **Complexity weight.** λ is called the "complexity weight"; "steepness" means σ only.

## 7. Deviations from the plan, with reasons

1. **`lem:kink:secant` is stated in App C (`app-kinks.tex`), not in the main text.** The main text keeps one pointer clause after `def:kink:kinks`.
   * Reason: the page budget (deviation 8).
   * The synthesis's own section plan (§5.1 P5, §5.2 App C) also had teacher Lemma 1.5 only in App C.
   * The plan lets only W3 cite it, and only optionally. A `\cref` resolves either way.
2. **`prop:algstat:product` is stated in App C.** The main text keeps one sentence giving its bound, with a `\cref`.
   * Reason: the page budget. It is a one-line corollary of `cor:kink:split`(a), and the plan's §3.1 already calls its proof one line.
   * The statement is unchanged from the base, with "Let λ > 1" made explicit. The base had it in the context sentence.
3. **"Point family" is defined in `def:algstat:product`, not in `def:kink:kinks`.** The structure function needs it first. `def:kink:kinks` defines the general two-fit setting and "bounded".
4. **The window variant of the right line is in the sentence directly after `def:kink:kinks`, not inside it.** It is a proved claim, not a definition.
5. **Two weakenings in `cor:kink:locate`, for space.**
   * (a) omits the sufficiency clause of kink Thm 3.2(a). The proof of `cor:kink:split`(b) derives it in one line from the two-part bound, which (a) keeps.
   * (b) omits Thm 3.2(c), "both kinks give $[\alpha_--w,\alpha_++w_+]$", which is (a) and (b) together.
   * Nothing stronger than the record is stated anywhere.
6. **Two subsections, not three.** §5.1 holds the structure function; §5.2 holds kinks, the kink lemma and the split. This saves heading space. The alias `sec:algstat:product` is on §5.1, as the plan requires.
7. **Definitions carry `\src{}` but no `\status{}`.** This follows the base convention for definitions; no listed status value fits a definition. Every lemma, corollary, theorem, proposition and remark has both. `\status{proved}` is plain, so no prose rendering is required (DECISIONS §A1).
8. **Page budget.** Main text is about **2.6 pp** against 2.25 (tolerance up to 2.5). The appendix is about **2.0 pp** against 1.75 (within tolerance).
   * Reason: the plan's §3.3 and §7.4 add to the synthesis's P5 list (for which 2.25 was set) the main-text statements `cor:kink:locate`, `lem:kink:secant`, `prop:kink:universal` and `prop:algstat:product`, plus the readings and $s_\pm$ that W3 needs.
   * Two statements were already moved to the appendix (deviations 1, 2), and every proof idea is 2–3 sentences.
   * The remaining main text is plan-mandated content.
   * If FRONT needs another 0.1 pp, the candidates are:
     * the sentence on $s_\pm$ after `def:kink:kinks` (W3 can restate it);
     * the last sentence of `rem:kink:reading`, which duplicates W1's absorption sentence.

## 8. Rules checked

* **Visible text.** `pdftotext` of the isolated build was grepped for the DECISIONS §A5 vocabulary and for "notes", "the author", "Hänni", "corrected", "withdrawn", "refuted" and "verified". The only hits are the permitted change-of-slope footnote and the bibliography entry.
* **Footnotes.** One, the existing change-of-slope footnote (REFRAME §4 credit). It is not inside a theorem-like environment.
* **Content.**
  * No computed numbers, no proof sketches, no questions or conjectures.
  * Every main-text result has a proof idea of 2–3 sentences and a full proof in App C.
* **Paper 1.** No citations of Paper 1, so `check_companion_numbers.py` is not needed for these files.

## 9. Fixes (fix round under `DECISIONS-restructure.md`; list `fix-W2.json`)

Only `kinks.tex` was edited; `app-kinks.tex` is unchanged. No label was renamed or added, no statement moved between main text and appendix, and no git command that changes repository state was run.

| id | change |
|---|---|
| RW2-02 (D11(i)) | `kinks.tex`, paragraph after `cor:kink:split`: the sentence now reads, verbatim, "…; per-query samples have one with high probability (\cref{thm:recovery:kink}, where the Ville line of \cref{thm:recovery:kink}(iii) replaces the coding bound), and so does the full table of a noisy random parity under the conditions of \cref{prop:parity:kink}." Checked: `thm:recovery:kink`(iii) is the right line of slope 1 and offset $\ell_0+\delta^*$ from the Ville deficiency, so the reference is correct. |
| RW2-03 (D11(j)) | Title of `prop:kink:universal` is now "A universal member flattens every kink far beyond its length". Statement, label, status and source unchanged. |
| RW2-01 (length, §3) | No statement changed. Trims: (1) `rem:kink:reading` cut from 5 to 4 lines: "an averaged statement about hull edges, not single bits" → "on average over an edge, not bit by bit"; "The split need not be unique;" dropped (the next sentence says it); the (Dom) sentence merged into one clause: "Under (Dom), which holds in $\Hcl{F}$ and fails in $\Hcl{\times}$ (\cref{cor:absorb:nouniversal}), \cref{prop:kink:universal}(ii) is \cref{thm:absorb:absorption}(a)." The first sentence, which `limits.tex` cites, is unchanged. (2) The paragraph after `def:kink:kinks` cut from 3 to 2 lines: "exactly when" → "iff", "gives a right kink of flatness τ′ and window g/(τ′−τ) for every τ′>τ" → "gives right kinks of flatness τ′>τ and window g/(τ′−τ)", and the pointer "(lines and secants are compared in \cref{lem:kink:secant})" → "(\cref{lem:kink:secant})", whose (a) gives the window claim. (3) Proof ideas, one line each: `lem:kink:main` (the clause "(iii)–(v) are direct" dropped; the appendix pointer stays), `cor:kink:locate` (same content, fewer words). The proof idea of `thm:kink:converse` is unchanged: no rewording that kept its content saved a line. (4) The product-sophistication sentence before the D11(i) text, from 6 to 5 lines with the D11(i) addition: "At a program attaining $\sophx_b(D)$, (a) gives every $\lambda$-MAP over $\Hcl{\times}$ length at most … (\cref{prop:algstat:product}), a bound vacuous as $\lambda\to1$ (\cref{rem:algstat:near1})." This also makes explicit that the bound is on the length, as in `prop:algstat:product`. |

**Build.** `./test-section.sh kinks app-kinks`: `OK: pages 5; 0 undefined citations; 25 undefined refs` (all are other groups' labels; one more than before because D11(i) cites `thm:recovery:kink` a second time). There are no overfull or underfull boxes.

**Pages.**

| measure | before | after |
|---|---|---|
| isolated build, `kinks.tex` (to the appendix heading) | 2.63 | **2.55** |
| isolated build, `app-kinks.tex` (to "References") | 2.06 | **2.10** (page-break slack only; file unchanged) |
| scratch copy with no page breaks, `kinks.tex` | 2.61 | **2.53** |
| scratch copy with no page breaks, `app-kinks.tex` | 2.08 | 2.08 |

* The scratch copy measures with no page breaks: a 60-inch page, the section numbered 5, and the `\newlabel` lines of the last full build's `main.aux` (2026-10-13 22:20), so that cross-references print at their real widths. It lives in the session scratchpad. It is not a full build and wrote nothing in the paper folder.
* The net saving is 0.085 pp, about 4 lines: −5 from the trims and +1 for D11(i). The longer title costs no line; each fix was measured separately.
* Against the 2.57 pp that the full build measured for §5, this gives about **2.49 pp** for §5, on the §3 target of 2.5. App C stays at about 2.1, its target.
