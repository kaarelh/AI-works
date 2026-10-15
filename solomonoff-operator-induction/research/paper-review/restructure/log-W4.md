# Log of body writer W4 (the noisy random parity): `parity.tex`, `app-parity.tex`, `algstat.tex`, `app-algstat.tex`

Written 2026-10-13 under `PLAN.md`, `DECISIONS.md` and `REFRAME.md`. Files edited: only these four, in `paper-steeper/sections/`. No git command that changes repository state was run.

**Build.** `./test-section.sh parity app-parity` reports `OK: pages 12; 0 undefined citations; 23 undefined refs`. All undefined references are other groups' labels (listed in §4). No overfull or underfull box.

**Inputs read.**
* `PLAN.md` in full; `REFRAME.md`; `DECISIONS.md` §0, §A (A1, A5, A8, A9, A10), §E, §F40, §F43.
* Base files, via `git show dcb3a3a3`: `algstat.tex`, `app-algstat.tex`, `teacher.tex`, `app-teacher.tex`, `computable.tex`.
* `split/kink/notes-final.md`: §0, §1, §4 (Props 4.1, 4.2, Cor 4.3, Prop 4.4, numbers, illustration), §6, §8.
* `split/verify-kink.md` in full, and `kink/verify_code/v4_parity_range.py` with its output (for the $K(p)$ convention and the corrected values).
* `split/verify-teacher.md`: §1, §2, §9, §10.
* `split/teacher/notes-final.md` §5 (the generalised instance, Prop 5.3).
* The synthesis `split/notes-final.md`: §2.4, §5.1 (P7), §6, §8.
* The current working files of W1 (`setup.tex`, `absorb.tex`) and W2 (`kinks.tex`, `log-W2.md`), for notation and for which of my labels they cite.

---

## 1. What each file contains

### `parity.tex`: §7 "The noisy random parity: one instance, two readings" (`sec:parity`, alias `sec:algstat`)

* **Opening paragraph.**
  * One instance serves both reasons.
  * The full table ($m=d$) is the split at τ = 1.
  * The junta ($m<d$) is reused at $2^{d-m}$ inputs per rule bit, with right slope $2^{-m}$ (`sec:teacher`).
* **§7.1 The instance** (`sec:teacher:instance`).
  * The notation box, shortened: no $\psi_c$, no $\Phi_1$. It covers this section and `sec:teacher`, in four lines.
  * `def:teacher:instance`, generalised to any rule size $1\le s_0\le2^{m-2}$, $p:=s_0/2^m$, $\kappa_g:=2\log d+K(p)+\kappa$ (PLAN §4.5).
    * New in (d): $e(\pi):=\Ex[\nu_\pi(y^*(x)\mid x)\mid x\in E]$. W5's `thm:teacher:main`(e) defines the same quantity, with the same formula.
    * New in (d): the sentence "$\lev(\pi)>t$ iff $u(\pi)\le\theta_t$".
  * One paragraph:
    * for $p=2^{-r}$, $\kappa_g=2\log d+2\log r+\kappa$, the value every number for such $p$ uses;
    * the δ_S caveat, with the pointer to `prop:limits:envelope`.
* **§7.2 Four lemmas and a sharper floor** (`sec:teacher:lemmas`).
  * Statements of `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart` ((D1), (D2)) and `lem:teacher:sharpfloor`.
  * `lem:teacher:sharpfloor` now says that the bound "remains valid with any $I\ge I(\pi)$ in place of $I(\pi)$". This replaces the base's "with $\ell(\pi)$ in place of $I(\pi)$"; the proof's coding step now shows it.
  * One "Proof ideas" paragraph.
  * The definition of the sharp floor $F^\sharp_t(I)$ at $B=\infty$, for general $m$ and $s_0$, with its two monotonicity properties. These are proved in App E.2.
* **§7.3 The full table: a kink at the parity** (`sec:parity:full`, new structural label; alias `sec:algstat:parity`).
  * The setting paragraph:
    * $m=d$, $B=\infty$, $p<1/4$, $L(\pi;D)=NR(\pi)$;
    * the class is $\Hcl{\times}$, or any product hypothesis class containing a good model (κ_g := ℓ(π_g) − d, class constant), as in kink Prop 4.2 and `prop:related:computable`(a);
    * $\Gamma^\circ_t$, $\mathrm{den}_t$ and $b_0$ (with $2\log(d+1)$).
  * `prop:parity:kink` (i)–(iii), with a proof idea and the steepness reading.
  * The definitions of $\bar\ell_\lambda$, $\Gamma_t(\lambda)$, $T$ and $C_{t_0}(\lambda)$.
  * `prop:parity:range`, with (i)(a)–(g), (ii) and (iii), and a proof idea.
  * The crossing paragraph. It defines $f_t$ and $p_1,p_0$ as unique roots and gives their decimals after the statement, rounded down in the sufficient conditions ($p\le0.1233$, $p<0.05596$; V-T §9). It also states the interval computation $f_2-H\ge0.0187$.
  * A short paragraph on the certified ranges, with one example and a pointer to `tab:parity:ranges` in App E.3.
* **§7.4 Set models: the parity is noise** (`sec:algstat:set`).
  * `def:algstat:set`, shortened.
  * The standard-notions sentence, with its citations as in the base.
  * The point-family reading.
  * One sentence pointing to `prop:algstat:set`, `rem:algstat:near1` and `prop:algstat:coarse` (App E.4).
  * A summary paragraph: it defines $c^*$ and $A_0$ and states the content of `prop:algstat:parity` in words, with a pointer to the appendix.
  * `prop:parity:sets`, with a proof idea.
  * The comparison paragraph: set steepness ≤ 1 + O((log d + δ_E)/d) against the exponential product steepness, and $A_0$ as the universal member of `prop:kink:universal`.
  * `rem:algstat:reading`, `rem:algstat:restricted` and `q:parity:open`.
* **Pages:** about **4.3** (from the isolated build, by the vertical position of the appendix heading).

### `app-parity.tex`: App E "Proofs for §7 (the noisy random parity)" (`app:parity`, alias `app:algstat`)

* **Preamble paragraph:** the notation $(z,w)$, τ_B, β_B. $z$ is a prefix in E.1–E.2 and the table from E.3 on, as the paragraph says.
* **E.1 List decoding** (`app:teacher:list`). The base proof, and the credit sentence for the earlier report. The base's computed-confirmation sentence is dropped (DECISIONS §A9).
* **E.2 The risk floors, the coding lemma and the two-part bounds** (`app:teacher:lemmas`).
  * The proofs of `lem:teacher:floor`, `lem:teacher:sharpfloor` (with `eq:teacher:identity`), `lem:teacher:coding` and `lem:teacher:twopart`, from the base.
  * The coding step of the sharp floor is written for any budget $I\ge I(\pi)$.
  * The tightness sentence and the per-factor normalisation sentence are shortened.
  * New paragraph "Monotonicity of the sharp floor". It is fact (β) of V-K §4.1, with its proof: $j(T)$ is nondecreasing because $f(j)=j-2\log(j+1)\le0$ for $j\le5$ and $f$ increases for $j\ge2$.
* **E.3 The full table** (`app:parity:kink`, new structural label).
  * Minimum-distance decoding (`eq:parity:decoding`, new) and the conditional bound (`eq:parity:conditional`, new).
  * The proof of `prop:parity:kink` (kink Prop 4.1).
  * The proof of `prop:parity:range`:
    * (i)(a)–(g), from kink Prop 4.2. (d) is proved directly from the comparison with π_g, (f) from the V side of the sharp-floor proof, and (g) as in V-K §4.3.
    * (ii) with the three facts (α), (β), (γ) of V-K §4.1, one sentence each, as V-K §7 asks.
    * (iii), from kink Cor 4.3, written in full.
  * The certified-ranges paragraph, `tab:parity:ranges`, and the 40-case sentence.
  * "The crossings": the uniqueness of the roots $p_1$ and $p_0$, by derivative bounds (V-T §9 and kink Cor 4.3).
* **E.4 Set models** (`app:algstat:coarse`). `prop:algstat:set` with its proof, `rem:algstat:near1`, `prop:algstat:coarse` with its proof, and `q:algstat:lsc`. These are the base items. The "Vereshchagin and Shen" sentence was already absent in the base and is not reintroduced (DECISIONS §A8).
* **E.5 Sets against products** (`app:algstat:parity`).
  * The statement of `prop:algstat:parity`, reduced per PLAN §3.1, and its proof (see deviation 2).
  * The proof of `prop:parity:sets`.
  * The computed code-dependence paragraph (k8(D)/rB2 numbers: 27.5, 3.0, 1.36).
* **Pages:** about **6.3**.

### `algstat.tex`, `app-algstat.tex`

Emptied. Each now holds exactly the one line of PLAN §2:
`% Superseded in the restructure (PLAN.md): content now in recovery.tex / kinks.tex / parity.tex / app-parity.tex. Base: git show dcb3a3a3.`

---

## 2. Labels defined, checked against the manifest (PLAN §3)

| label | file | manifest destination | note |
|---|---|---|---|
| `sec:parity` | parity | §3.2 new section label | |
| `sec:algstat` | parity | §3.2 alias on the section | |
| `sec:teacher:instance`, `sec:teacher:lemmas` | parity | §3.2 | received from W5 |
| `def:teacher:instance` | parity | §3.1 | received from W5; generalised (§4.5) |
| `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart` | parity | §3.1 | received from W5; statements kept |
| `lem:teacher:sharpfloor` | parity (statement) | §3.1 | received from W5's app-teacher; proof in app-parity |
| `sec:algstat:parity` | parity | §3.2 alias | on §7.3 (the noisy parity, full table) |
| `prop:parity:kink` | parity | §3.3 | items (i)–(iii), numbered here |
| `prop:parity:range` | parity | §3.3 | (i)(a)–(g), (ii), (iii) as in the manifest |
| `sec:algstat:set` | parity | §3.2 alias | on §7.4 |
| `def:algstat:set` | parity | §3.1 | shortened |
| `prop:parity:sets` | parity | §3.3 | |
| `rem:algstat:reading` | parity | §3.1 | cites `cor:kink:split`, `prop:parity:range` |
| `rem:algstat:restricted` | parity | §3.1 | two sentences |
| `q:parity:open` | parity | §3.3 | |
| `app:parity` | app-parity | §3.2 new | |
| `app:algstat` | app-parity | §3.2 alias | |
| `app:teacher:list`, `app:teacher:lemmas` | app-parity | §3.2 | received from W5 |
| `eq:teacher:identity` | app-parity | §3.1 | received from W5 |
| `tab:parity:ranges` | **app-parity** | §3.3 (parity.tex) | **deviation 1** |
| `app:algstat:coarse` | app-parity | §3.2 alias | on E.4 |
| `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc` | app-parity | §3.1 | kept |
| `app:algstat:parity` | app-parity | §3.2 alias | on E.5 |
| `prop:algstat:parity` | **app-parity** | §3.1 (parity.tex, proof app) | **deviation 2** |
| `sec:parity:full` | parity | **new structural** (prefix `parity`) | |
| `app:parity:kink` | app-parity | **new structural** | |
| `eq:parity:decoding`, `eq:parity:conditional` | app-parity | **new structural** | cited only inside app-parity |

**Every W4 label of the manifest exists, exactly once in my files.**
* §3.1: `def:algstat:set`, `prop:algstat:parity`, `rem:algstat:restricted`, `rem:algstat:reading`, `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc`, `def:teacher:instance`, the four lemmas, `lem:teacher:sharpfloor`, `eq:teacher:identity`.
* §3.2: `sec:algstat`, `sec:algstat:set`, `sec:algstat:parity`, `sec:teacher:instance`, `sec:teacher:lemmas`, `app:algstat`, `app:algstat:coarse`, `app:algstat:parity`, `app:teacher:list`, `app:teacher:lemmas`, `sec:parity`, `app:parity`.
* §3.3: `prop:parity:kink`, `prop:parity:range`, `tab:parity:ranges`, `prop:parity:sets`, `q:parity:open`.

**Cut labels.** `tab:algstat:numbers` and `app:algstat:numbers` are gone from my files. A grep finds no other file citing them.

**Moved out.** `def:algstat:product`, `sec:algstat:product` and `prop:algstat:product` are not in my files; W2 has them. No label was renamed.

---

## 3. Moves given and received (PLAN §3.5)

| label(s) | from | to | state of the working tree |
|---|---|---|---|
| `def:algstat:product`, `sec:algstat:product`, the change-of-slope footnote | W4 `algstat.tex` | W2 `kinks.tex` | given: `algstat.tex` emptied; W2 has inserted them (log-W2 §3) |
| `prop:algstat:product` | W4 `app-algstat.tex` | W2 (`app-kinks.tex`) | given: `app-algstat.tex` emptied; W2 has it |
| `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart`, `sec:teacher:instance`, `sec:teacher:lemmas`, the notation box | W5 `teacher.tex` | W4 `parity.tex` | received. **W5 must delete them from `teacher.tex`.** When I last looked (unchanged base file) they were still there, so the full build will show multiply defined labels until W5 does. |
| `lem:teacher:sharpfloor`, `eq:teacher:identity`, `app:teacher:list`, `app:teacher:lemmas` | W5 `app-teacher.tex` | W4 `parity.tex` / `app-parity.tex` | received. **W5 must delete §C.1–C.2 and the sharp-floor lemma from `app-teacher.tex`.** |

---

## 4. `\cref`s to other groups' labels

All are in the stable lists of PLAN §3.6, except where noted.
* **W1:** `app:setup:facts`, `lem:setup:basic`, `lem:setup:coding`.
* **W2:** `sec:kinks`, `def:algstat:product`, `cor:kink:split` ((a), (b)), `prop:kink:universal`, `prop:algstat:product`.
* **W5:** `sec:teacher`, `cor:teacher:fulltable`.
* **W6:** `sec:limits`, `prop:limits:envelope`, `prop:related:computable` ((a)).

These are exactly the 13 undefined references of the isolated build. I cite no [V-T] label.

**Who cites my labels** (grep of the working tree; all labels exist under the same names):
* W1 `absorb.tex`: `prop:algstat:parity`, `prop:parity:kink`, `prop:parity:sets`.
* W2 `kinks.tex`: `rem:algstat:reading`, `rem:algstat:near1`, `def:teacher:instance`, `prop:parity:kink`.
* W5 and W6 base files: the lemmas, `def:teacher:instance`, `lem:teacher:sharpfloor`, `prop:algstat:parity`, `app:teacher:list`, `app:teacher:lemmas`.
* FRONT's base files: `sec:algstat`, `prop:algstat:parity`, `prop:algstat:coarse`, `q:algstat:lsc`.

---

## 5. Verification-dependent items and their sources

| item | record | report | how stated |
|---|---|---|---|
| `prop:parity:kink` | kink Prop 4.1 | refereed | as recorded; window bounds made explicit |
| `prop:parity:range`(i)(a)–(f) | kink Prop 4.2(i) | refereed | as recorded |
| `prop:parity:range`(i)(g) | kink Prop 4.2(g) | V-K §4.3, **verified** | as recorded; the numbers use V-K's corrected rounding: $u\ge0.9928$, $\ell\le d+45.7$, $I\le58.4$, $e\le0.209$ at λ = 2; $u\ge0.9903$, $\ell\le d+15.6$, $I\le28.3$, $e\le0.184$ at λ = 105 |
| `prop:parity:range`(ii) | kink Prop 4.2(ii) | V-K §4.1, **verified** | the statement uses V-K's form (explicit $1<\lambda_{\rm lo}$); the proof states (α), (β), (γ), one sentence each |
| `tab:parity:ranges` | kink k7 | V-K §4.2, **verified with correction** | only V-K's "correct print" values. "(1, x]" is used only for $p=2^{-10}$; for $p\ge1/16$ the lower ends are explicit ($[1.00049,4276]$, $[1.00059,6529.7]$, $[1.08656,465.39]$, $[1.3422,199.8]$). The $1+10^{-12}$ rows are avoided. Lower ends are rounded up and upper ends down. 7 rows. |
| `prop:parity:range`(iii) | kink Cor 4.3 | refereed | the threshold is written as the crossing condition $1-\log(\frac32-p)>H(p)$, with the decimals after the statement |
| crossing decimals | V-T §9 (and kink Cor 4.3) | **verified with correction** (rounding) | $p_1=0.1233072\ldots$, $p_0=0.0559643\ldots$; sufficient conditions rounded down: $p\le0.1233$, $p<0.05596$. Uniqueness of both roots is proved in App E.3 by derivative bounds. |
| $f_2-H\ge0.0187$ | kink Cor 4.3, k7(d), rA(4) | refereed (0.0187 is the corrected value) | stated as a direct computation (rigorous interval check), outside the statement |
| `prop:parity:sets` | kink Prop 4.4 | refereed | $c^*$ written with $K(p)$ (see §7) |
| code-dependence numbers (27.5; 3.0, 1.36) | kink §4 illustration, k8(D), rB2 | computed | appendix, after the proof, as a direct computation in explicit classes |
| `prop:algstat:parity` (reduced) | base steeper Prop 3.8 and kink Props 4.1, Cor 4.3 | proved (base) | (i) unchanged in content; (ii) the base (ii) and (iv) merged with the floor $\Gamma^\circ_t$ (see deviation 3); (iii) the gap, with the large-$d$ statement for dyadic $p<1/4$ |
| generalised instance | teacher Prop 5.3 (refereed, M5), kink §4 | — | see §7 |

There are no [V-T] labels in my files. The only V-T items I use are the rounding of the crossings (V-T §9) and the general-$s_0$ instance (teacher Prop 5.3, refereed).

---

## 6. Deviations from the plan, with reasons

1. **`tab:parity:ranges` and its paragraph of numbers are in App E.3, not in `parity.tex`.**
   * Moved with it: the identification numbers at λ = 2 and 105, and the 40-case sentence.
   * The main text keeps one paragraph that states what the table shows, with one example range and a pointer.
   * Reason: the page budget (§8). Every number stays in the paper, after the statements it concerns, introduced as a direct computation.
2. **The statement of `prop:algstat:parity` is in App E.5.** The main text keeps a summary paragraph that defines $c^*$ and $A_0$ (which `prop:parity:sets` needs) and states (i)–(iii) in words, with a `\cref`.
   * Reason: the page budget. In the main text the kink contrast (`prop:parity:kink` against `prop:parity:sets`) carries the same message.
   * The label is unchanged, so every citer (W1 `rem:absorb:wyeth`(iv), intro, related work, discussion) still resolves.
   * W2 did the same with `prop:algstat:product` (log-W2, deviation 2).
3. **`prop:algstat:parity`(ii) merges base (ii) and (iv)** into one statement: "for every integer $t\ge1$ and every $b$ with $\delta_E+2\log d+\kappa_g+\log(N+1)+\kappa\le b<N\Gamma^\circ_t-d-\lceil L_E\rceil-\kappa_b-2\kappa$, $d-s(t)-\Lambda_1\le\sophx_b(D)\le d+\kappa_g$", with $\Gamma^\circ_t=\max\{G_t,F^\sharp_t(d+\kappa)\}$.
   * It is implied by the base proofs:
     * base (iv)'s argument with its $F_t$ at a fixed $g$, which the supremum over $g$ dominates;
     * the floor $G_t$ for levels above $t$, by `lem:teacher:floor` and the monotonicity of $G$.
   * At $t=1$ with $G_1$, the upper end of the range of $b$ is $O(\log d)$ smaller than base (ii)'s. So the merged statement is not stronger than the base anywhere.
   * The structure-function cliff is dropped (PLAN §3.1, superseded by `prop:parity:kink`).
4. **`lem:teacher:sharpfloor`: "with $\ell(\pi)$ in place of $I(\pi)$" became "with any $I\ge I(\pi)$ in place of $I(\pi)$".**
   * The proof's coding step is written for any such $I$; it needs only that $j$ exceeds the threshold.
   * Fact (β) gives the monotonicity of $F^\sharp_t$.
   * The content is the same as the base's, since $I(\pi)\le\ell(\pi)+\kappa$.
5. **$F^\sharp_t(I)$ is defined in §7.2 for general $m$ and $s_0$, not only for $m=d$.** It is the same formula as kink §4 at $m=d$, and the teacher record's $\mathrm{Floor}_{t+1}=\max\{0,F^\sharp_t\}$ at $B=\infty$. So W5 can use it for `prop:teacher:sharp`.
6. **Proof ideas of the four lemmas and the sharp floor are one joint paragraph** (as in the base).
7. **The notation box is four lines wide with grouped entries.** It also serves §8 (W5): it lists $b_0,\Gamma_t,\Gamma^\circ_t$ and, for §8, $\Phi_2,J_g,J_b,\Delta,c_{\rm hi}$.
8. **Status tags.**
   * Added `\status{remark}` to `rem:algstat:near1` and `\status{open}` to `q:algstat:lsc` (the base had none).
   * Definitions carry `\src{}` only, as in the base.
   * Every other base `\status`/`\src` is kept verbatim.
9. **The base's computed confirmations inside the lemma appendix are dropped:** the 400 random semimeasure hypotheses, twice (DECISIONS §A9 allows it).
10. **`q:parity:open` is made precise** as a question about a short near-sufficient set model. The hypothesis $\pi_s=q\theta$ in $\Hcl{\times}$ has a $k$-bit parameter with $K(\theta\mid q)\ge k$, and the bounds are $K(A\mid\dom D)\le|q|+O(\log(kn))$ and slack $b+O(\log(kn))$.
    * The record's version (kink §8 item 4) is informal: "a set-model slope ≈ 1 when the parameter is random".
    * The question's last sentence is a one-line consequence of the argument of `prop:parity:sets`.
    * **A point for FRONT or the author.** For *computable, rational-valued* product families, thresholding as in `prop:algstat:coarse`, taking the union over all $k$-bit parameters, seems to give such a set directly. I have not written or checked that argument, and the records do not contain it, so the paper does not claim it.
    * For that reason the question is posed in $\Hcl{\times}$ (lower-semicomputable hypotheses), where the thresholded set is only computably enumerable, as in `q:algstat:lsc`.
11. **`rem:algstat:restricted`** keeps the DECISIONS §A8 text. The Milovanov citation appears only as "see also".

---

## 7. The general rule size (PLAN §4.5): the check that nothing else needs $p=2^{-r}$

* **The definition.** `def:teacher:instance` now has integers $2\le m\le d$ and $1\le s_0\le2^{m-2}$, with $p:=s_0/2^m\le\frac14$ and $\kappa_g:=2\log d+K(p)+\kappa$. The truncation condition $B\ge\log(1/p)$ is kept.
* **Every place where the base used $r$:**
  * $\kappa_g$, now with $K(p)$; for $p=2^{-r}$, (F5) gives the base value (sentence after the definition);
  * $K(A_0)$ in `prop:algstat:parity`(i), and $c^*$ in `prop:parity:sets`, now $c^*:=2\log d+K(p)+\kappa$. $A_0$ is computable from $d$ and $p$. The proofs used only "$A_0$ is described by $d$ and the flip rate", so nothing else changes. For $p=2^{-r}$ this is kink Prop 4.4's $c^*$.
* **Steps that do not use $p=2^{-r}$:**
  * list decoding, the coding lemma and (D1)–(D2) do not involve $p$;
  * the risk floor uses only $\Pr[E]=p$;
  * $2^mH(p)-\log(2^m+1)\le L_S\le2^mH(p)$ and $\delta_S\ge-2\log m-2\log s_0-\kappa$ hold for every $s_0$;
  * $\kappa_b$ pays $2\log s_0$;
  * the sharp floor was already stated for every $s_0$;
  * kink Prop 4.2 and Cor 4.3 use $\kappa_g=2\log d+K(p)+\kappa$ (kink §4), and the computed ranges use the record's $K(p)$ convention, stated in the caption of `tab:parity:ranges` (V-T §9 asks for this);
  * teacher Prop 5.3 lists the same steps.
* **For W5 and FRONT (V-T §9).** With dyadic $p$ allowed, the base text "$G_1>H(p)$ … if and only if $p<0.0560$" in `sec:teacher` and "(4) $p<0.056$" in `rem:teacher:hypotheses` are false on a small interval of dyadic rates (V-T: $p=3669/2^{16}$). The root is $p_0=0.0559643\ldots$; a sufficient decimal is $p<0.05596$. §7.3 states it that way, and W5 can cite that paragraph.

---

## 8. Pages

Measured on the isolated build (`build-test/parity/test.pdf`) by the vertical position of the headings; the bibliography is excluded.

| file | pages | budget (PLAN §6) |
|---|---|---|
| `parity.tex` (§7) | **≈ 4.3** (7.1: 1.1 including the opening; 7.2: 0.8; 7.3: 1.25; 7.4: 1.2) | 2.5 |
| `app-parity.tex` (App E) | **≈ 6.3** (E.1–E.2: 2.25; E.3: 2.2; E.4: 0.8; E.5: 1.1) | 3.75 |

**Both files are over budget**, by about 1.8 pp (main) and 2.6 pp (appendix). The plan's budget does not cover the content it assigns to these files:
* **Main text.**
  * The base material moved here measures 3.5 pp in an isolated build of the base files (`git show`): `algstat.tex` 2.2 pp, of which about 0.3 pp went to W2, and the instance with the four lemmas from `teacher.tex`, 1.6 pp.
  * The new statements (`prop:parity:kink`, `prop:parity:range`, `prop:parity:sets`) add about 1.2 pp.
  * I compressed that to 4.3 pp. To get there I moved `prop:algstat:parity` and `tab:parity:ranges` (with its numbers) to the appendix and shortened every proof idea and remark.
* **Appendix.**
  * The base material is about 4.6 pp: the lemma proofs from base App C (2.3 pp) and base App F without the cut numbers table and without `prop:algstat:product` (about 2.0 pp).
  * The new proofs (kink Props 4.1, 4.2, Cor 4.3, Prop 4.4) add about 1.2 pp.
  * The items moved down from the main text add about 0.6 pp.

**Further cuts, if FRONT needs them** (in order of least loss):
1. The notation box (0.2 pp main). The definition lists every symbol.
2. `prop:algstat:parity`(ii)–(iii) and their proof (about 0.5 pp appendix). The kink results supersede them, but the introduction's contribution "the sophistication gap" cites them.
3. Rows 2 and 7 of `tab:parity:ranges`, and the 40-case sentence (0.1 pp).
4. `prop:algstat:coarse` with its proof, and `q:algstat:lsc` (0.4 pp appendix). PLAN §3.1 keeps them.

---

## 9. Paper 1 citations

None. My files cite no Paper 1 result.

---

## 10. Fixes (fix round, DECISIONS-restructure; `fix-W4.json`)

Files edited: `paper-steeper/sections/parity.tex`, `paper-steeper/sections/app-parity.tex`. No label added, renamed or removed. No `\status{}`/`\src{}` changed. No statement or item structure changed beyond the decided texts. Nothing moved between main text and appendix. No git command that changes repository state was run.

| id | change |
|---|---|
| RW4-01 (D6, W4 part) | `lem:teacher:twopart`: "If $\lev(\pi)=t<\infty$, then" → "Let $\lev(\pi)=t<\infty$. Then"; "and \( \text{(D2)} …\)" → "and, if $B$ is an integer or $\infty$, \( \text{(D2)} …\)". (D1) unchanged, for every $B$. `def:teacher:instance`(c): appended after "$2^{-\infty}:=0$." the sentence "Results that use (D2) of \cref{lem:teacher:twopart} take $B$ to be $\infty$ or an integer." `lem:teacher:coding` (already "For integer or infinite $B$"), `lem:teacher:floor` and `lem:teacher:sharpfloor` (real $B$) unchanged. **Check of the uses of (D2) in W4's files:** (D2) occurs only in the lemma, in its proof (App E.2, which inserts `lem:teacher:coding`, so the new hypothesis is exactly what the proof needs) and in the proof-ideas sentence. No result of §7 or App E uses (D2): `prop:parity:kink`, `prop:parity:range`, `prop:algstat:parity` and `prop:parity:sets` use (D1), the risk floor and the sharp floor only, all at $B=\infty$ (§7.3 fixes $B=\infty$). Nothing further was added. |
| RW4-02 (D7) | Last sentence of `rem:algstat:reading` replaced, verbatim, by "This is why steeper simplicity is useless over set models in this example once $\lambda-1\gg(\log d+\delta_E)/d$ (\cref{prop:parity:sets,prop:algstat:parity}; closer to $1$ the code's $O(\log d)$ terms decide), and decisive over product models (\cref{cor:kink:split,prop:parity:range})." The code-dependence paragraph at the end of App E.5 (1.36 at $d=30$) and the sentence of §7.4 "For $\lambda-1$ of order $(\log d+\delta_E)/d$ nothing is claimed, and the code's $O(\log d)$ terms decide" are kept unchanged. |
| RW4-03 (length) | Prose only; every statement, the notation box, the four lemmas, the sharp-floor display and `q:parity:open` stay in §7. Line counts are from the rendered text (before → after). **Opening** 9 → 6 lines: same two readings and plan; dropped "the good model is sufficient", "each bit of the rule is reused at $2^{d-m}$ inputs" (§8 says it) and "(at every flip rate below 1/4 once $d$ is large)" (`prop:parity:range`(iii) states it). **Covers paragraph** 5 → 4 lines, two sentences, with RW4-05; the agreement with `cor:teacher:fulltable` at $d=20$ and "where the floors $G_t$ alone exceed $H(p)$" are left to App E.3, which says both. **Set-sophistication paragraph** 7 → 4 lines: $c^*$ and $A_0$ defined as before; $|A_0|$, $K(z)\ge\ldots$ and "with the exact ranges" left to `prop:algstat:parity`(i) in App E.5; the λ-optimal set-model bound and the product-sophistication summary kept, the latter with its conditions (large $d$, $\delta_E=O(d)$). **`rem:algstat:reading`** 8 → 4 lines, with D7: first part now "Knowing a random $d$-bit parameter saves sets one bit per bit, products about a bit \emph{per input}."; the supervised-learning sentence dropped (it is `absorb.tex` l.90). **`rem:algstat:restricted`**: one sentence, the DECISIONS §A8 text with both citations, Milovanov as "(see also \citealp{milovanov2016algorithmic})". **Proof ideas** tightened (lemmas; `prop:parity:kink` now itemised (i)/(ii); `prop:parity:range` 5 → 4 lines; `prop:parity:sets` 3 → 2 lines). **Other prose** (same content): the paragraph after `prop:parity:sets` 6 → 4 lines (the absorption clause after "universal member of \cref{prop:kink:universal}" dropped, as the remark now says it; "(\cref{prop:parity:kink})" dropped there, the bound being the one two paragraphs up); the paragraph after the definition 4 → 3; the "first lemma" sentence and the tightness sentence after `lem:teacher:twopart` 2 → 1 line each; the sentence after the $F^\sharp_t$ display defines $\gamma_g(I)$ as the $\gamma(\pi)$ of `lem:teacher:sharpfloor` with $I$ for $I(\pi)$ instead of repeating the formula; "since $0\le NH(p)-L_E\le\log(N+1)$" moved before the $b_0$ display; the notation box's "rule's code, deficiency, information" → "codes, deficiency, information" (it wrapped). The pointer after the set-model standard references is now "(\cref{app:algstat:coarse})" instead of naming the three items there. **App E** (target 6.3): the sentence opening E.5 ("We state and prove the comparison …") deleted; four sentences reworded shorter without change of content (list-decoding remark after the proof; normalisation remark after the coding-lemma proof; "and window $w$" in the proof of `prop:parity:kink`(iii); "the values $p_1$, $p_0$ of \cref{sec:parity:full}" in "The crossings"); "besides these rows," dropped from the 40-case sentence (all 40 cases are covered either way). |
| RW4-04 (D11(l)) | Body of `q:parity:open` replaced verbatim by the D11(l) text ($\epsilon(k)=o(k)$ independent of $D$; cap $1+(b+\epsilon(k)+2\kappa)/(\alpha_{\rm r}-K(A\mid\dom D))$; the noisy-parity sentence). Title, status, source unchanged. The old $n:=|\dom D|$ is gone with the $O(\log(kn))$ slack. Checked against `prop:parity:sets`' proof: with slack $b+\epsilon(k)$ and the conditional sufficiency line $K(A\mid\dom D)+\log|A|\ge K(y_D\mid\dom D)-\kappa$, the argument gives $\sigma\le1+(b+\epsilon(k)+\kappa)/(\alpha_{\rm r}-K(A\mid\dom D))$, so the printed cap with $2\kappa$ is valid (slightly loose). |
| RW4-05 (D11(m)) | `parity.tex`: "for $p\ge1/16$ it starts above $1$" → "for $p\ge1/16$, at the levels $t_0$ of \cref{tab:parity:ranges}, it starts above $1$". `app-parity.tex`: "For $p\ge1/16$ the condition fails near $\lambda=1$" → "For $p\ge1/16$, at the levels $t_0$ of the table, the condition fails near $\lambda=1$". Both verbatim. |
| RW4-06 (D11(n)) | "(F5) gives" → "(F5) of \cref{app:setup:facts} gives". |

**Exact texts.** A script compared the sources with the decided strings of D6 (three), D7, D11(l), D11(m) (two) and D11(n): each occurs exactly once. "useless over set models in this example (" occurs neither in the sources nor in the PDF text; none of "0.199", "3.66", "0.545", "0.955", "average Hellinger", `0.1233\le p` occurs in W4's files. No process vocabulary was introduced.

**Build.** `./test-section.sh parity app-parity`: `OK: pages 11; 0 undefined citations; 23 undefined refs`. The 23 are other groups' labels only (`app:setup:facts`, `cor:kink:split`, `cor:teacher:fulltable`, `def:algstat:product`, `lem:setup:basic`, `lem:setup:coding`, `prop:algstat:product`, `prop:kink:universal`, `prop:limits:envelope`, `prop:related:computable`, `sec:kinks`, `sec:limits`, `sec:teacher`; several cited more than once). No overfull box, no multiply defined label.

**Pages** (text-block pages; main: section heading to appendix heading; appendix: appendix heading to "References").

| measure | §7 before | §7 after | App E before | App E after |
|---|---|---|---|---|
| isolated build (letter pages, other groups' references as "??") | 4.31 | **3.81** | 6.33 | **6.31** |
| scratch copy without page breaks (200-inch page, section numbered 7 and appendix E, the `\newlabel`/`\bibcite` lines of the last full build's `main.aux`, 2026-10-13 22:20, so references print at their real widths; the float `tab:parity:ranges` is excluded there) | 4.32 | **3.89** (−0.44) | 6.15 | **6.06** (−0.10) |

* Against the full build's 4.31 (§7) and 6.46 (App E), this gives about **3.87 pp** for §7 (target 3.8 ± 0.15) and about **6.36 pp** for App E (target 6.3 ± 0.15). The isolated build gives 3.81 and 6.31.
* The scratch copies live in the session scratchpad; nothing was written in the paper folder except the two section files and `build-test/parity/` (the isolated build).

**Paper 1 citations.** None; W4's files cite no Paper 1 result.
