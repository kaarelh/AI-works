# Track "split", sub-track "teacher": the teacher's mistakes as an instance of the split (target T3), final record

*Brief: `../00-brief.md`, target T3. This is the revised and final record of the sub-track. It replaces `notes.md` (the first version, kept unchanged) after the referee reports `referee-A.md` (proofs) and `referee-B.md` (computation and counterexamples). Written 2026-10-13.*

* **Sources read.**
  * The brief, in full.
  * Paper 2 (`paper-steeper/sections/`):
    * `setup.tex` and `app-setup.tex`: `def:setup:data`, `lem:setup:hull`, `lem:setup:coding`, `rem:setup:persample`, (F1)–(F5).
    * `split.tex` and `app-split.tex`: `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `rem:split:reading`, `thm:split:shared`.
    * `algstat.tex` and `app-algstat.tex`: `prop:algstat:product`, `prop:algstat:parity` and its proof.
    * `teacher.tex` and `app-teacher.tex`, in full: `def:teacher:instance`, the four lemmas, `lem:teacher:sharpfloor`, `thm:teacher:main` and its proof, `cor:teacher:fulltable`, `lem:teacher:finite`, `cor:teacher:sampled`, `prop:teacher:concentration`, `ex:teacher:version1`.
    * `limits.tex` and `app-limits.tex`, in full.
  * The refereed record `research/tracks/steeper/notes-final.md` ("St"): §1.1–1.3, §2.1–2.6, §3.1–3.6, §4.4.
  * Paper 1: `paper/sections/setting.tex` and `versions.tex` (`def:versions:variants`, the per-query mixture).
  * `paper/NOTATION.md`.
  * The two referee reports of this sub-track and all of their code (`referee_code/`).
  * The sibling sub-tracks:
    * `../iid/notes-final.md` (T1, final), §0–§3, §7.3–§7.5, §8–§10;
    * `../kink/notes.md` (T2; no `notes-final.md` exists), §0–§6 and §8, together with `../kink/referee-A.md` (issue 1) and `../kink/referee-B.md` (issues 5–7), where they concern objects shared with this file.
* **Scripts.**
  * Prover, in `checks/`, Python 3.11, deterministic or seeded; each output is saved next to its script as a `.out` file.
    * `t1_kink_instances`, `t2_reuse_factor`, `t3_second_kink`, `t4_junta_window` and `tcommon.py` are **unchanged** from `notes.md`, so that the record the referees checked stays reproducible.
    * `t5_revision` (new): per-rate and per-sample re-runs of t2 with exact ceilings; frozen noise and junta errors under two likelihoods; the rate-code comparison of referee A's M1.
    * `t6_exact_window` (new): §5 with exact integer information; the sharper identification bounds of Remark 2.6.
    * `t7_lemma_checks` (new): exact-arithmetic checks of the revised Lemma 1.1, of Lemma 1.5 and of Lemma 3.0.
  * Referees, in `referee_code/`: `rA1_checks`, `rB0`–`rB8` with `rBcommon.py`. All were re-run for this revision (verification log).
* **Status tags.**
  * **[proved]**: full proof here, or a one-line derivation from cited proved results.
  * **[computed: tN(k)]** or **[computed: rXN(k)]**: checked by that script, part (k); output in the `.out` file of the same name.
  * **[known: ref]**: standard or published; "(unverified)" when not checked against the source.
  * **[proof sketch]**, **[conjecture]**, **[open]**, **[remark]**: as named.
  * **[refuted]**: a claim of `notes.md` (or of a draft) shown false, kept with its counterexample.
* **Conventions.**
  * $\log=\log_2$; $\ln$ is natural. Code lengths, fits and information are in bits.
  * Notation follows `paper/NOTATION.md` and `def:teacher:instance`: $n$ samples (queries), $d$ input length, $N=2^d$, $m$ the junta length, $p$ the error density, $s_0=p2^m$, $c=\lambda/n$, κ the machine constant.
  * **Illustration (κ = 0).** A number obtained by setting the unknown machine constant κ to 0. It is not a result about any reference machine. Rows with κ = 30 show how the bounds degrade.
  * Paper 2's labels are cited as written (`thm:teacher:main` etc.). "iid" and "kink" refer to the sibling notes with their own numbering. "St" is the steeper record.

**Notation and naming changes from `notes.md`.** Numbering of `notes.md` is kept, so that the sibling sub-tracks' citations ("teacher Prop 3.2", "teacher Remark 3.5") stay valid. New items get new numbers.

| `notes.md` | this file | why |
|---|---|---|
| "right flatness" (one undefined word) | a **right line** $(\tau,g)$ and the **right secant** $s_+$ (Def 1.4) | A M3 |
| "the good model's λ-interval" | the λ-set of the **true-parity family** (any rate) and of the **rate-p member** $\pi_g$ | A M1, B-m7 |
| "noise" versus "errors" | four data objects **PQ, FR, FQ, DS** (§1.0) and the **reuse factor** (§3.0) | A M4, B-M1 |
| $b_0'$ (with $2\log(d+1)$) | $b_0$, the kink sub-track's offset (with $2\log d$) | B-m5 |
| "window" in §4, §5 | defined sets $W_\epsilon$ (Prop 4.1) and $\{c:J_g(c)+\epsilon<\Phi_2^\sharp(c)\}$ (Prop 5.2) | A m13, m14 |
| Lemma 1.1 with $g\ge0$ and a margin $m_N(c)>\epsilon$ | $g\in\mathbb R$, a pointwise margin, and the upper fit bound as a separate item (iv) | A m1, m2, m5, B-m8 |
| $\Psi_t$ over real $I\ge0$ | over integers $I\ge0$ ($I(\pi)$ is an integer) | B-m1 |

---

## Revision summary

Both referees accept; neither found a fatal issue. Every major issue was accepted. One of them (A M4 = B-M1) was accepted with a correction: the frozen object the referees used is not Paper 2's likelihood, and in Paper 2's likelihood the original dichotomy holds (Prop 3.7). §8 lists every issue with its resolution and location.

* **What is selected (A M1, B-m7).** The claim that the good model $\pi_g$ is a hull vertex whose λ-interval contains the whole window is **refuted as stated**. In two natural rate codes the rate-$p$ program is the population minimiser among "true parity + rate $q$" only on the lower 68–89% of the window's logarithmic width [computed: t5(A), rA1(A)]. All statements now use the near-optimal set $\mathcal N_\epsilon(c)$, as `thm:teacher:main` does. "Only λ = cn" is replaced by Prop 3.6: schedules with $\lambda_n/n\to0$ or $\to\infty$ lose the model; schedules with $\lambda_n/n$ eventually in a compact subset of the window keep it [proved].
* **Sampled windows (A M2).** Windows in λ are stated as proved only for the population, the full table, and samples of size $n\ge n_0(c)$ through `cor:teacher:sampled`. For smaller samples only lower bounds are proved; the matching upper bound is a conjecture with computed evidence.
* **Right flatness (A M3).** Defined as two quantities (Def 1.4, Lemma 1.5) [proved]. Each statement names one.
* **Frozen noise (A M4, B-M1).** Four data objects are now separated (§1.0). The thesis is restated in terms of the **reuse factor**: the number of likelihood terms one bit of the noise or of the error rule enters (§3.0, Lemma 3.0).
  * In Paper 2's data-set likelihood (FR), frozen noise has reuse factor 1 at every $n$, repeats or not; fixed λ > 1 bounds the excess length uniformly in $n$ (Prop 3.7(a)) [proved; computed: t5(D)].
  * Counted per query against the frozen table (FQ, the object of rB5), frozen noise is reused at every repeat and needs λ ∝ n/N, like an error rule with $m=d$ (Prop 3.7(b),(c)) [proved; computed: t5(D), rB5].
* **The range of Prop 5.3 (A M5).** Stated for $a>a^*(p)$ (strict) and $c\in[a2^{-m},c_m]$ for any $c_m=o(1/d)$; the extension to non-dyadic rates is one sentence [proved].
* **Exact computations (B-m1, B-m10).** With integer information the finite-size bound converges to $\psi_2$, and the exact windows at $d=100$, $m=20$ are computed; t6 reproduces rB7 to every printed digit.
* **A free sharpening (B-m2).** Remark 2.6 [proved]: (ii)(a) and (e) improve, for example from $u\ge0.75$ to $u\ge0.828$ and from $e\le0.274$ to $e\le0.1965$ in the $p=1/16$ row of §5.
* **Minor fixes.** Lemma 1.1 with real $g$ and a pointwise margin; the chain-rule proof of Prop 3.3(b) with its $2\log m$; Prop 3.2(d) for countable classes; corrected numbers ($L_S=43.41$; δ_S's effect; the $m=4$ sentence; the envelope's 7 bits); statuses; the ceiling bug of `tcommon.py` (fixed in t5, documented here).
* **Cross-track consistency (§7)** is new.

---

## 0. Summary

1. **One kink lemma covers both threads (§1)** [proved; computed: t1(A), rB1].
   * Lemma 1.1 is a two-sided kink lemma in the (length, fit) plane.
     * *A property kink on the left:* a set $N$ of programs defined by a property ("does not know the model"), with a pointwise margin.
     * *An unattained anchor on the right:* a right line $(\tau,g)$ under the other programs $M$, with real offset $g$.
   * Near-optimal programs are in $M$, have length at most $\ell_0+(g+\epsilon)/(c-\tau)$ and fit at least $F_0-(cg+\tau\epsilon)/(c-\tau)$.
   * Def 1.4 separates a **right line** $(\tau,g)$, which bounds long programs, from the **right secant** $s_+$, which decides the comparison with the reference point itself. A line of slope τ allows secants up to $\tau+g/x$, and every line flatter than a far program's secant needs an offset growing with that program's distance (Lemma 1.5) [proved].
2. **The teacher's theorem is this lemma with τ = 2^{-m} (§2)** [proved; computed: t1(B), rB2(E)].
   * It reproduces $\Phi_1$, $\Delta(c)$, $\Delta_\ell$ and the risk bound (ii)(b) exactly. Table 2.2 maps the hypotheses of `rem:teacher:hypotheses` to the two kink conditions [remark].
   * **What it does not say (A M1).** It does not say which program minimises $J_c$, nor that $\pi_g$ is a vertex. In explicit codes it is not: nearby rates win on part of the window. They still satisfy every conclusion of (ii). "$\pi_g$ is a vertex on the whole window" is **refuted as stated** [computed: t5(A), t5(B), rA1(A), rB3(A)].
   * **A free sharpening (Remark 2.6)** of (ii)(a) and (e) [proved; computed: t6(C),(D), rB8].
3. **The private-randomness split is the same lemma with τ = 1 in total bits (§2)** [proved; computed: t1(C), t1(D)].
   * `thm:split:private`(i)'s length bound is Lemma 1.1 with Ville's line; its fit bound is the line itself (Prop 2.3).
   * For $m=d$ on the full table, the teacher's right condition is the sufficiency line (τ = 1, offset $b_0$, the kink sub-track's), so `cor:teacher:fulltable` is the split's case (Prop 2.4).
4. **λ must exceed the reuse factor (§3)** [proved; computed: t2, t5, rB3, rB4, rB5].
   * *Reuse factor.* The number of likelihood terms one bit of the noise or of the errors enters. Duplicating every likelihood term $r$ times multiplies every λ-threshold by $r$ (Lemma 3.0).
   * *Full tables.* A right line of slope $2^{d-m}$ with offset $2^{d-m}\Lambda_2$; the memoriser's secant is at least $2^{d-m}\theta_m$; flatter lines need offsets of order $L_S$ (Prop 3.1). The window is $\lambda\in(2^{d-m},Nc_{\rm hi})$.
   * *Which object.*
     * Noise redrawn per query (PQ) and frozen noise in Paper 2's likelihood (FR) have reuse factor 1 at every $n$. So λ need not grow: in PQ every $1\le\lambda_n=o(n)$, fixed λ included, recovers the sampler (iid Thm 3.1), and in FR every fixed λ > 1 bounds the excess length uniformly in $n$ (Prop 3.7(a)).
     * The teacher's junta errors are a fixed function of the input. Each bit of the rule is reused at every input of its cell, about $n2^{-m}$ times. Every $\lambda_n=o(n)$ learns them (Prop 3.2(c)).
     * Frozen noise counted per query (FQ) is reused at every repeat of its input and behaves like an error rule with $m=d$ (Prop 3.7(b),(c)).
   * *Schedules (Prop 3.6).* $\lambda_n/n\to0$ learns the errors; $\lambda_n/n\to\infty$ forgets the model; $\lambda_n/n$ eventually in a compact subset of $(2^{-m},c_{\rm hi})$ keeps the identification. λ = cn is the simplest such schedule [proved].
   * *Samples (Prop 3.3).* Proved: the good model is beaten at every λ below about $\max\{1,n2^{-m}\theta_m\}$ (the 1 needs the canonical class), and with equal cell multiplicities $\bar n$ there is a right line of slope $\bar n$. The matching upper bound for unequal multiplicities is a **conjecture** [computed: t5(C), rB4: the lower end tracks the mean multiplicity].
5. **Structured errors make a second kink (§4)** [proved; computed: t3, rB3].
   * An envelope adds a kink to the right of the model and raises the lower end of the window to its rate. Rate blindness is an empty kink interval.
   * In an exact class the lower end of the rate-p member's λ-set moves 15.0 → 17.1 → 42.7 → 85.3 → empty as the cheap part grows.
6. **The junta window extends to every p < 0.1233 (§5)** [proved; computed: t4, t6, rB7].
   * *Information charge.* A program of level ≥ 2 that holds $I$ bits about the rule pays $cI$ in length. The sharp floor gains it only about $2p\sqrt{I\ln2/(2s_0)}$.
   * *Asymptotics (Prop 5.3).* For every $p<0.12331$ and every $a>a^*(p)$, for all large $m$, the identification of `thm:teacher:main`(ii) holds for all $c\in[a2^{-m},c_m]$, for any $c_m=o(1/d)$. Here $a^*(p)=1$ for $p<0.07787$.
   * *At the example's sizes* ($d=100$, $m=20$, κ = 0) the exact windows exist for $p=1/16,\dots,15/128$, none of which has a window in the paper. For $p=1/16$ the window is $[2^{-20},2.53\cdot10^{-3}]$.
7. **Presentation (§6).** The teacher result reads as "the split at a positive rate": its four lemmas prove two kink bounds, and Lemma 1.1 does the rest.
8. **Cross-track consistency (§7).** Objects, notation and overlapping results are aligned with the iid and kink sub-tracks; seven points are reconciled.

---

## 1. One kink lemma for both threads

### 1.0 Objects

The three objects of iid Defs 1.1–1.3, and one more, which the referees' frozen-noise simulation uses. "Fit" is total bits.

* **(DS) A single data set** $D$: a finite partial function, so the inputs are distinct. The fit is $L(\pi):=-\log\nu_\pi(D)$ (kink's $L(\pi)$). Full truth tables are DS with $\dom D=\{0,1\}^d$.
* **(PQ) Per query.** Pairs $(x_i,y_i)$ i.i.d. from $\mu\otimes P^*$ for a label channel $P^*$, the label redrawn at every query. The fit is $L_n(\pi):=\sum_{i\le n}-\log\nu_\pi(y_i\mid x_i)$ (iid's).
* **(FQ) Frozen labels counted per query.** A fixed table $F:X\to Y$ (drawn once from a sampler, or a teacher $y^*$), inputs i.i.d. from μ with repeats, and the fit $\sum_{i\le n}-\log\nu_\pi(F(x_i)\mid x_i)$. Per sample it tends to the population risk $R(\pi)=\Ex_\mu[-\log\nu_\pi(F(x)\mid x)]$ of `rem:setup:persample` with $y^*=F$. iid §9.4(a) calls it "the per-query likelihood against a fixed table". Referee B's rB5 uses it.
* **(FR) Frozen labels, Paper 2's data-set likelihood** (`def:setup:data`). $D_n$ is the set of distinct pairs among the first $n$ queries, with $n':=|\dom D_n|$ distinct inputs, and the fit is $-\log\nu_\pi(D_n)$: each distinct input counts once.
* **Relations.**
  * For a deterministic teacher, PQ with $P^*=\delta_{y^*}$ is FQ with $F=y^*$.
  * On distinct inputs, FQ and FR coincide. Sampling without replacement (`cor:teacher:sampled`) is FR with $n'=n$.
  * On Paper 2's countable input set every input law is atomic, so inputs repeat, and FQ and FR differ (iid Remark 1.4).
* **Paper 2's teacher results** are about DS (full tables), the population risk, and FR without replacement.

### 1.1 The lemma

**Setting 1.0.**
* *Programs and fits.* $\mathcal P$ is a countable set of programs π with lengths $\ell(\pi)\ge0$ and two fits $0\le F'(\pi)\le F(\pi)\le\infty$.
* *Objectives.* For $c>0$: $J_c(\pi):=c\,\ell(\pi)+F(\pi)$, $J'_c(\pi):=c\,\ell(\pi)+F'(\pi)$ and $\Phi(c):=\inf_\pi J_c(\pi)$.
* *Two readings.*
  * **Data:** $F=F'$ is the fit in one of the objects of §1.0, and $c=\lambda$, in total bits.
  * **Population:** $F=R$, $F'=R_B$ and $c=\lambda/n$, per sample.
* *The reference point.* $(\ell_0,F_0)$ is **bounded** if some program $b$ has $\ell(b)\le\ell_0$ and $F(b)\le F_0$. Then $\Phi(c)\le c\ell_0+F_0$ for every $c>0$.
* *The partition.* $\mathcal P=M\sqcup N$. The **left margin** at slope $c$ is
  $$m_N(c):=\inf_{\pi\in N}J'_c(\pi)-(c\ell_0+F_0)\in(-\infty,+\infty],$$
  with $m_N\equiv+\infty$ if $N=\emptyset$.

**Lemma 1.1 (two-sided kink with a property) [proved; computed: t1(A), t7(A), rB1(A)].** In Setting 1.0, let $(\ell_0,F_0)$ be bounded. Assume:

**(R)** there are $\tau\ge0$, $g\in\mathbb R$ and $\ell_M\le\ell_0$ such that every $\pi\in M$ has $\ell(\pi)\ge\ell_M$ and
$$F'(\pi)\ \ge\ F_0-g-\tau\,(\ell(\pi)-\ell_0).$$

Let $c>\tau$ and $\Delta(c):=g+(c-\tau)(\ell_0-\ell_M)$.
* (i) $\inf_\pi J'_c\ge c\ell_0+F_0+\min\{m_N(c),\,-\Delta(c)\}$. If the reference is bounded by a program of $M$, then $g\ge0$ and $\Delta(c)\ge0$. If $m_N(c)\ge0$ and $\Delta(c)\ge0$, then
  $$c\ell_0+F_0-\Delta(c)\ \le\ \Phi(c)\ \le\ c\ell_0+F_0 .$$
* (ii) Let $\epsilon\ge0$ be such that every $\pi\in N$ has $J'_c(\pi)>c\ell_0+F_0+\epsilon$ (a **pointwise margin**; it holds if $m_N(c)>\epsilon$). Take every π with $J'_c(\pi)\le c\ell_0+F_0+\epsilon$; this includes every π with $J_c(\pi)\le\Phi(c)+\epsilon$. Every such π lies in $M$ and satisfies
  $$\ell(\pi)\le\ell_0+\frac{g+\epsilon}{c-\tau},\qquad F'(\pi)\ge F_0-\frac{cg+\tau\epsilon}{c-\tau}.$$
* (iii) $m_N$ is concave in $c$.
* (iv) *(No right line needed.)* If every $\pi\in M$ has $\ell(\pi)\ge\ell_M$, then every $\pi\in M$ with $J'_c(\pi)\le c\ell_0+F_0+\epsilon$ has
  $$F'(\pi)\le F_0+\epsilon+c\,(\ell_0-\ell(\pi))\le F_0+\epsilon+c\,(\ell_0-\ell_M).$$
* *If every bounding program is in $N$,* then $m_N(c)\le0$ for every $c$, and the margin of (ii) fails at that program: (ii) is vacuous.

*Proof.*
* *(i).* For $\pi\in N$, $J'_c(\pi)\ge c\ell_0+F_0+m_N(c)$. For $\pi\in M$, (R) gives
  $$J'_c(\pi)\ge c\ell+F_0-g-\tau(\ell-\ell_0)=(c-\tau)\ell+\tau\ell_0+F_0-g\ge c\ell_0+F_0-\Delta(c),$$
  using $c>\tau$ and $\ell\ge\ell_M$. Also $\Phi\ge\inf J'$ because $F\ge F'$, and $\Phi\le c\ell_0+F_0$ by boundedness.
  * *$g\ge0$ (B-m8).* If $b\in M$ bounds the reference, (R) at $b$ gives $g\ge F_0-F'(b)+\tau(\ell_0-\ell(b))\ge0$, because $F'(b)\le F(b)\le F_0$ and $\ell(b)\le\ell_0$. Then $\Delta(c)\ge g\ge0$, because $\ell_M\le\ell_0$.
  * *Every bounding program in $N$.* Then $m_N(c)\le J'_c(b)-(c\ell_0+F_0)\le0$.
* *(ii), membership.* $J_c(\pi)\le\Phi(c)+\epsilon$ implies $J'_c(\pi)\le J_c(\pi)\le c\ell_0+F_0+\epsilon$. A program of $N$ has $J'_c>c\ell_0+F_0+\epsilon$ by the margin. So π ∈ M.
* *(ii), length.* (R) and $J'_c(\pi)\le c\ell_0+F_0+\epsilon$ give $(c-\tau)(\ell-\ell_0)\le g+\epsilon$.
* *(ii), lower fit.*
  * If $\ell\ge\ell_0$: $F'\ge F_0-g-\tau(\ell-\ell_0)\ge F_0-g-\tau(g+\epsilon)/(c-\tau)=F_0-(cg+\tau\epsilon)/(c-\tau)$. This holds for every real $g$, because τ ≥ 0.
  * If $\ell<\ell_0$: (R) gives $F'\ge F_0-g+\tau(\ell_0-\ell)$. The claim needs $\tau(\ell_0-\ell)\ge-\tau(g+\epsilon)/(c-\tau)$. If $g+\epsilon\ge0$ this is clear. If $g+\epsilon<0$, combine (R) with $J'_c(\pi)\le c\ell_0+F_0+\epsilon$ to get $(c-\tau)(\ell_0-\ell)\ge-(g+\epsilon)$ (A, "Checked").
* *(iii).* $m_N$ is an infimum of affine functions of $c$.
* *(iv).* Rearrange $J'_c(\pi)\le c\ell_0+F_0+\epsilon$, then use $\ell\ge\ell_M$. ∎

[computed: t1(A): 2591 point sets, 14,733 near-optimal points, exact arithmetic. t7(A), for the revised form: 3000 point sets, 24,000 slopes, 14,945 near-optimal points under the pointwise margin with the least admissible (possibly negative) $g$, and 132,074 checks of (iv); none of the 363 sets with least admissible $g<0$ has a bounding program in $M$. rB1(A): 37,759 sets, 335,162 near-optimal points, the general form of (i) at 250,842 slopes with $m_N(c)<0$; of 2903 sets whose least admissible $g$ is negative, none has $m_N(c)>0$ at any tested $c$, and the sandwich fails only in 176 cases, all with $m_N(c)=0$ and the bounding program in $N$, as the last bullet says. rB1(D): the hypotheses $c>\tau$ and $\epsilon<m_N(c)$ are necessary, and the length bound is attained.]

**Remark 1.2 (the left margin as a wedge) [proved].** Let σ > 0 and μ ≥ 0. Suppose every π ∈ N lies on or above the wedge
$$F'(\pi)\ \ge\ F_0+\max\{\sigma(\ell_0-\ell(\pi)),\ \mu\}.$$
Then $m_N(c)\ge\mu(1-c/\sigma)\ge0$ for every $c\in(0,\sigma]$.

*Proof.* Put $x:=\ell_0-\ell(\pi)$.
* If $x\le0$, then $J'_c-(c\ell_0+F_0)\ge\mu+c|x|\ge\mu$.
* If $x>0$, it is at least $\max\{\sigma x,\mu\}-cx$.
  * When $\sigma x\ge\mu$ this is at least $(\sigma-c)x\ge(\sigma-c)\mu/\sigma$.
  * Otherwise it is at least $\mu-cx>\mu-c\mu/\sigma$. ∎

Conversely, $m_N\ge0$ on $(0,\sigma]$ forces $F'\ge F_0$ (let $c\downarrow0$; A's correction) and $F'\ge F_0+\sigma(\ell_0-\ell)$ (take $c=\sigma$). So σ is the **left steepness** of the reference relative to $N$, and $\{c:m_N(c)>0\}$ is an interval, by (iii). [computed: rB1(B): 20,000 wedges at 820,000 slopes; the converse on 7,791 sets.]

**Remark 1.3 (relation to the kink sub-track) [proved].** Kink Def 3.1, Thm 3.2 and Cor 3.3 are special cases of Lemma 1.1, up to windows.
* *Their left kink* (σ, $w_-$) at a point $(\alpha_-,L_-)$ with $\rho_D(\alpha_-)\le L_-$ is the case $N=\{\pi:\ell(\pi)<\alpha_--w_-\}$, $\ell_0=\alpha_-$. For λ < σ every π ∈ N has $J'_\lambda(\pi)-(\lambda\alpha_-+L_-)\ge(\sigma-\lambda)(\alpha_--\ell(\pi))>0$. So the pointwise margin of (ii) holds at ε = 0, with no finiteness condition (A m2: the earlier form with $m_N(c)>0$ needed $N$ finite, which holds in prefix classes by Kraft). Their conclusions "length ≥ $\alpha_--w_-$" and "fit ≤ $L_-+\lambda(\alpha_--\ell)$" are "π ∈ M" and (iv).
* *Their Cor 3.3* (sufficiency as a right kink) is (R) with τ = 1, $g=b_0+\kappa$ and $M=\mathcal P$. Their Thm 5.4(ii) (Ville) is (R) with τ = 1 and $g=\ell_0+\log(1/\varepsilon)$.
* *Their right kink* has a horizontal window $w_+$ and an anchor $(\alpha_+,L_+)$ with $\rho_D(\alpha_+)\le L_+$.
  * The window variant of (R) reads: every π ∈ M with $\ell(\pi)>\ell_0+w_+$ satisfies the inequality. It gives $\ell(\pi)\le\ell_0+\max\{w_+,(g+\epsilon)/(c-\tau)\}$, by the same proof [computed: rB1(C), 658,478 near-optimal points].
  * A right line $(\tau,g)$ gives a right kink of flatness τ′ and window $g/(\tau'-\tau)$ for every τ′ > τ: for $\ell-\ell_0\ge g/(\tau'-\tau)$, $F\ge F_0-g-\tau(\ell-\ell_0)\ge F_0-\tau'(\ell-\ell_0)$.
* *What the teacher needs and their form lacks.*
  * a property-defined $N$, because the conclusion is "knows the parity", not "is long";
  * an unattained anchor with an offset $g$, because the line (D2) passes $\Lambda_2/2^m$ below the good model.

  So the paper should state one kink lemma in the form of Lemma 1.1, with the window variant as a remark. Then `thm:split:private`(i), `prop:algstat:product`, kink Cor 3.3 and `thm:teacher:main`(i)–(ii)(c) are all corollaries of it.

### 1.2 Right lines and right secants

`notes.md` used "right flatness" for two different things (A M3). They are now separate.

**Definition 1.4 (right line, right secant).** Fix a reference $(\ell_0,F_0)$ and a set $M$ of programs.
* A **right line** $(\tau,g)$ is a pair for which (R) holds on $M$, with some $\ell_M$.
* The **right secant** is
  $$s_+:=\max\Big\{0,\ \sup\Big\{\frac{F_0-F'(\pi)}{\ell(\pi)-\ell_0}:\pi\in M,\ \ell(\pi)>\ell_0\Big\}\Big\}.$$
  When the reference is a hull vertex, $s_+$ is the slope of the hull edge to its right.

On a single finite data set a right line exists for every τ ≥ 0, for example with $g=F_0$. So a slope alone says nothing; what matters is the pair, and how the offset compares with the scale of the fits.

**Lemma 1.5 (lines and secants) [proved; computed: t7(B)].**
* (a) If $(\tau,g)$ is a right line, every π ∈ M with $\ell(\pi)=\ell_0+x$, $x>0$, has secant at most $\tau+g/x$.
* (b) If $\pi_1\in M$ has $\ell(\pi_1)=\ell_0+x_1>\ell_0$ and secant $s_1$, then every right line of slope τ has $g\ge(s_1-\tau)x_1$.
* (c) Let the reference be attained by $\pi_0$ ($\ell(\pi_0)=\ell_0$, $F'(\pi_0)=F_0$). For λ < $s_+$ some program of $M$ longer than $\ell_0$ has $J'_\lambda<J'_\lambda(\pi_0)$. For λ > $s_+$ none has $J'_\lambda\le J'_\lambda(\pi_0)$.

*Proof.* (a) Rearrange (R): $F_0-F'(\pi)\le g+\tau x$. (b) (R) at $\pi_1$: $F_0-s_1x_1\ge F_0-g-\tau x_1$. (c) $J'_\lambda(\pi)-J'_\lambda(\pi_0)=x\,(\lambda-\text{secant}(\pi))$ for $\ell(\pi)=\ell_0+x$. ∎

So lines bound long programs (through Lemma 1.1's $(g+\epsilon)/(c-\tau)$), and secants decide whether the reference itself survives. A line flatter than a far program's secant pays for it with an offset linear in that program's distance.

---

## 2. Both theorems are instances

### 2.1 The teacher's theorem: τ = 2^{-m}

**Proposition 2.1 (`thm:teacher:main` as an instance of Lemma 1.1) [proved; computed: t1(B), rB2(E)].**

*The data.* Take `def:teacher:instance` with $B\in[\log(1/p),\infty]$, the population reading ($F=R$, $F'=R_B$), the reference point $(\ell_0,F_0):=(d+\kappa_g,\ H(p))$, bounded by $\pi_g$, $N:=\{\pi:\lev(\pi)\ge2\}$ (∞ included) and $M:=\{\pi:\lev(\pi)=1\}$.

* **(a) The left condition.**
  * $m_N(c)\ge\Phi_2(c)-J_g(c)$ for every $c>0$, so $m_N\ge0$ on $(0,c_{\rm hi}]$ and $m_N>0$ on $(0,c_{\rm hi})$.
  * Geometrically, every program of level ≥ 2 lies above the wedge of Remark 1.2 with apex $(d+\kappa_g,H(p))$, steepness $\sigma=c_{\rm hi}$ and margin $\mu=G_1-H(p)$.
  * As a length kink: every program shorter than $d-4-\Lambda_1$ is in $N$, by (D1) with $s(1)=4$. So the reference has a left kink of steepness $c_{\rm hi}$ and window $w_-=4+\Lambda_1+\kappa_g$ in kink Def 3.1, read per sample.
* **(b) The right condition.** (R) holds with
  $$\tau=2^{-m},\qquad \ell_M=d-4-\Lambda_1,\qquad g=\frac{\Lambda_2}{2^m},\qquad \Lambda_2=2^mH(p)-B_S+4+\Lambda_1+\kappa_g .$$
  So the anchor is $(\ell_M,B_S/2^m)$. Here $g\ge0$, because the reference is bounded by $\pi_g\in M$ (Lemma 1.1(i)); equivalently, (D2) at $\pi_g$ gives $d+\kappa_g+2^mH(p)\ge d+B_S-4-\Lambda_1$ (A m1). The paper's stated lower bound on $\delta_S$ alone does not give it [computed: rA1(D): $\Lambda_2$ would be $-113$ at $d=m=100$, $r=2$].
* **(c) The conclusions.** For $2^{-m}<c\le c_{\rm hi}$, Lemma 1.1(i) gives
  $$\Phi^B(c)\ge\min\{\Phi_1(c),\Phi_2(c)\},\qquad\Phi_1(c)=c\ell_0+F_0-\Delta(c),\qquad \Delta(c)=c(4+\Lambda_1+\kappa_g)+H(p)-\frac{B_S}{2^m}\ge0 .$$
  For $J_g(c)+\epsilon<\Phi_2(c)$, Lemma 1.1(ii) gives $\lev(\pi)=1$ and
  $$\ell(\pi)\le d+\kappa_g+\frac{\Lambda_2+\epsilon2^m}{c2^m-1}=d+\Delta_\ell,\qquad R_B(\pi)\ge H(p)-\frac{c\Lambda_2+\epsilon}{c2^m-1}.$$
  These are `thm:teacher:main`(i), (ii)(b) and (ii)(c), with the paper's constants.
* **(d) The envelope.** `prop:limits:envelope`(i) is Lemma 1.1(iv), with the envelope's point $(d+k_1+\kappa_e,R_e)$ as reference: $R\le R_e+\epsilon+c(k_1+\kappa_e+4+\Lambda_1)=R_e+\zeta$. No right line is needed (A m5).

*Proof.*
* *(a).* By `thm:teacher:main`(o), every program of level ≥ 2 has $J^B_c\ge\Phi_2(c)$. Also $c\ell_0+F_0=J_g(c)$. So $m_N\ge\Phi_2-J_g$, which is ≥ 0 on $(0,c_{\rm hi}]$ and > 0 on $(0,c_{\rm hi})$, by the definition of $c_{\rm hi}$ and because $J_g-\Phi_2$ is a maximum of strictly increasing affine functions.
  * *The wedge.* At $c=c_{\rm hi}$: $c_{\rm hi}\ell+R_B\ge\Phi_2(c_{\rm hi})\ge J_g(c_{\rm hi})=c_{\rm hi}\ell_0+H(p)$. This is the slanted side. The flat side is $R_B\ge G_{\lev-1}\ge G_1$, by `lem:teacher:floor` and the monotonicity of $G$.
* *(b).* (D1) with $s(1)=4$ gives $\ell\ge\ell_M$. (D2) gives $\ell+2^mR_B\ge d+B_S-4-\Lambda_1=\ell_M+B_S$, that is, $R_B\ge B_S/2^m-2^{-m}(\ell-\ell_M)$. At $\ell=\ell_0$ the line has height $B_S/2^m-2^{-m}(\kappa_g+4+\Lambda_1)=H(p)-\Lambda_2/2^m$.
* *(c), Δ.* $g+(c-\tau)(\ell_0-\ell_M)=\Lambda_2/2^m+(c-2^{-m})(4+\Lambda_1+\kappa_g)=c(4+\Lambda_1+\kappa_g)+H(p)-B_S/2^m$. Since $g\ge0$, this equals the paper's $\max\{0,\cdot\}$.
* *(c), Φ₁.* $c\ell_0+F_0-\Delta(c)=c(d-4-\Lambda_1)+B_S/2^m=\Phi_1(c)$.
* *(c), length.* $\ell_0+(g+\epsilon)/(c-\tau)=d+\kappa_g+(\Lambda_2+\epsilon2^m)/(c2^m-1)$. The paper's $\Delta_\ell=\kappa_g+\epsilon/c+(\Lambda_2+\epsilon/c)/(c2^m-1)$ is the same number, because
  $$\frac\epsilon c+\frac{\epsilon/c}{c2^m-1}=\frac{\epsilon}{c}\cdot\frac{c2^m}{c2^m-1}=\frac{\epsilon2^m}{c2^m-1}.$$
* *(c), risk.* $(cg+\tau\epsilon)/(c-\tau)=(c\Lambda_2+\epsilon)/(c2^m-1)$.
* *(d).* The margin is $\Phi_2-J_e$, and level-1 programs have $\ell\ge\ell_M$; Lemma 1.1(iv) applies. ∎

*An inherited condition (A m19).* `lem:teacher:coding`, and hence (D2), is stated for integer or infinite $B$, while `thm:teacher:main` allows real $B\in[\log(1/p),\infty]$. For non-integer $B$ use $\lfloor B\rfloor\ge r$ in $\Lambda_1$; $R_{\lfloor B\rfloor}\le R_B$ makes this valid. Every number here uses $B=\infty$ or $B=30$. This is a point for the paper, not for this file.

[computed: t1(B).]
* *The identities.* Over 17,411 random parameter sets ($4\le m\le40$, $m\le d\le400$, κ ∈ {0, 5, 10, 30, 60}, $\delta_S\in\{0,1,10,20,100\}$, finite and infinite $B$, $c/2^{-m}\in(1,10^4]$, ε ≥ 0), the paper's and the lemma's formulas agree:

  | quantity | largest relative difference |
  |---|---|
  | $\Phi_1$ | $2.4\cdot10^{-14}$ |
  | Δ | $1.0\cdot10^{-15}$ |
  | $\Delta_\ell$ | $2.8\cdot10^{-15}$ |
  | the risk bound | $1.2\cdot10^{-15}$ |
  | g | $9.4\cdot10^{-16}$ |

  rB2(E) recomputes $g$ from (D2) itself, not from the shared formula for $\Lambda_2$: agreement to $3.4\cdot10^{-13}$.
* *The wedge.* Every level-t region $\{\ell\ge(d-s(t)-\Lambda_1)^+,\ R_B\ge G_{t-1}\}$, for $t=2,\dots,400$ and ∞, lies above it in all 10 configurations checked, with the exact $s(t)$ and with $4t$.
* *The exact steepness* of these regions exceeds $c_{\rm hi}$ slightly: $8.198\cdot10^{-3}$ against $8.062\cdot10^{-3}$ at the example's sizes (κ = 0), $3.687\cdot10^{-3}$ against $3.659\cdot10^{-3}$ (κ = 30), and equal at $d=m=20$ ($1.139\cdot10^{-2}$). The difference comes from the two-endpoint reduction in the proof of (o). The same $8.198\cdot10^{-3}$ is the exact upper end of the window of §5 at $p=2^{-10}$ [computed: t6(B), rB7(B)].

**What is selected (A M1, B-m7).**
* *What the theorem says.* For $c\in(2^{-m},c_{\rm hi})$ and small ε, every program of the near-optimal set
  $$\mathcal N_\epsilon(c):=\{\pi:J_c(\pi)\le\Phi(c)+\epsilon\}$$
  knows the parity, is at most $\Delta_\ell$ bits longer than $d$, fits no better than noise up to the slack of (ii)(b), holds little information about the rule and does not predict the errors. Also $J_c(\pi_g)\le\Phi(c)+\Delta(c)$.
* *What it does not say.* It does not say which program minimises $J_c$, nor that $\pi_g$ (rate exactly $p$) is a vertex of the population hull, nor that one program is selected on the whole window.
* **[refuted as stated]** `notes.md` (Reading after Prop 3.2, §0 item 4, §6.1): "the good model is an interior vertex … whose λ-interval contains $(2^{-m},c_{\rm hi}]$".
  * *Counterexample in explicit codes* [computed: t5(A), independent of rA1(A), which gives the same switch points]. At the example's sizes, among the programs "true parity + flip rate $q$", whose risk is $H(p)+\mathrm{KL}(p\Vert q)$:

    | rate code | rate $p$ is the minimiser on | then |
    |---|---|---|
    | tcommon's RC, κ = 0 | $(2^{-20},4.33\cdot10^{-4}]$, 67.7% of the window's log-width | $2^{-9}$ up to $1.85\cdot10^{-3}$, $2^{-8}$ up to $3.78\cdot10^{-3}$, $2^{-6}$ up to $c_{\rm hi}$ |
    | tcommon's RC, κ = 30 | 74.1% | $2^{-9}$, $2^{-8}$ |
    | $2\log r'$ for $q=2^{-r'}$, κ = 0 | $(2^{-20},1.42\cdot10^{-3}]$, 80.8% | $2^{-9}$ up to $5.43\cdot10^{-3}$, then $2^{-8}$ |
    | $2\log r'$, κ = 30 | 88.6% | $2^{-9}$ |

    In tcommon's code the rate $2^{-9}$ costs one bit less than $2^{-10}$, and $\mathrm{KL}(2^{-10}\Vert2^{-9})=4.33\cdot10^{-4}$ bits; so $2^{-9}$ wins for every $c>4.33\cdot10^{-4}$.
  * *In the exact classes* [computed: t5(B) with exact ceilings; rB3(A) in class K]. On full tables at $d=10$, $p=1/16$ the true-parity family is a λ-MAP on $(3.754,46.22)$ at $m=8$, but the rate-$p$ member only on $(3.754,31.55)$; the rate-1/8 member takes $(31.55,46.22)$. At $m=5$ the rate-$p$ member is never a λ-MAP, while the rate-1/8 member is, on $(37.69,46.22)$ in t5(B) and on $[31.4,43.1]$ in 2 of 3 instances of rB3(A).
  * *In $\Hcl{\times}$* the relative lengths of rate codes depend on the reference machine. Nothing is claimed either way.
  * The programs selected instead satisfy every conclusion of `thm:teacher:main`(ii): they are level 1, short, and have $R>H(p)$.
* *Consequence for reporting.* "The good model's λ-interval" in t2, t3, rB3 and rB4 is the λ-set of the **true-parity family** (any rate). This file reports the family and, where it matters, the rate-$p$ member separately.

**What is geometry and what is not (A m15).**
* (i), (ii)(b) and (ii)(c) are Lemma 1.1 (Prop 2.1(c)).
* (iv) is a secant statement: the memoriser's secant from any level-1 point with $R\ge H(p)$ (Lemma 1.5(c)). It is used as such in Prop 3.1(b) and Prop 4.2.
* (iii) is the side $c<\tau$ of the same line (D2): below the right line's slope the memoriser's side of the hull is selected.
* What the geometry does not give is the meaning of the position:
  * (ii)(a) is the risk floor applied to the fit bound;
  * (ii)(d) converts the length bound into information about $S$, by list decoding and symmetry of information;
  * (ii)(e) converts (d) into a bound on the probability of the erroneous labels, by Hoeffding's coding argument.

In the split's language: (c) says the selected model carries at most $\Delta_\ell$ bits beyond the model; (d) says those bits contain at most $\Delta_\ell+\Lambda_3$ bits of the errors; so the errors are in the noise.

**Table 2.2 (the hypotheses of `thm:teacher:main` and the kink conditions they serve) [remark: an interpretive map, checked against the proofs].** The numbering is that of `rem:teacher:hypotheses`.

| hypothesis | enters through | kink condition |
|---|---|---|
| (1) list-decodable model class (parities) | `lem:teacher:list` → (D1), (D2) | *Left:* by (D1), a program shorter than $d-s(t)-\Lambda_1$ cannot know the model at level $t$. *Right:* a program that knows it pays only $4+2\log d$ bits for $a$, which puts the anchor of (D2) at $\ell_M=d-4-\Lambda_1$. |
| $K(a)\ge d$ (part of the instance) | (D1), (D2) | *Left:* the kink sits at $\alpha\approx d$. *Right:* the anchor. |
| (4) $p<0.056$, i.e. $G_1>H(p)$ | `lem:teacher:floor` | *Left:* margin $\mu=G_1-H(p)>0$ and $c_{\rm hi}>0$. §5 replaces this by $p<0.1233$. |
| (3) uniform inputs | all three lemmas | *Both:* every slope is a rate under μ (Parseval; $\Pr[E]=p$; cells of mass $2^{-m}$). See `prop:limits:inputlaw`. |
| (2) product form $E=S\times\{0,1\}^{d-m}$ | `lem:teacher:coding` → (D2) | *Right:* τ = $2^{-m}$ per sample, a line of slope $2^{d-m}$ in total bits on the full table, instead of $2^{-d}$. This is the reuse factor (§3). |
| (5) small $\delta_S$ | (D2), through $B_S=L_S-\delta_S$ | *Right:* the offset $g=\Lambda_2/2^m$ contains $\delta_S/2^m$. It plays the role of δ* in the split (Remark 2.5). |
| truncation $B$ | $F'=R_B\le R$ | The second fit of Lemma 1.1. |

### 2.2 The private-randomness split: τ = 1 in total bits

**Proposition 2.3 (`thm:split:private`(i) and iid Thm 4.1(i) as instances) [proved; computed: t1(C)].**
* *The data.* The data reading, with the reference point $(k,\,-\log\nu(D_n))$, attained by $\pi_\nu$, $N:=\emptyset$ and $M:=\mathcal C$.
  * For any input rule that picks each input before its label is drawn, with distinct inputs (this includes FR), $k$ is the length of a program equal to ν at every input (Paper 2's $k$).
  * In PQ the same holds with $\ell_0$ (iid's least length of a μ-a.e. equivalent program) in place of $k$, because the comparison is on the sample (iid Def 1.2).
* *The right condition.* (R) holds with τ = 1, $\ell_M=0$ and $g=k+\delta^*$ (in PQ, $\ell_0+\delta^*$).
* *What follows.*
  * Lemma 1.1(ii), with $c=\lambda>1$ and ε = 0, gives $\ell(\hat\pi)\le k+(k+\delta^*)/(\lambda-1)$: the length bound of `thm:split:private`(i).
  * Its fit bound $-\log\nu_{\hat\pi}(D_n)\ge-\log\nu(D_n)-\ell(\hat\pi)-\delta^*$ is (R) itself, which is pointwise stronger than Lemma 1.1's worst-case bound (A m3).
  * Lemma 1.1(i) gives $\Phi(\lambda)\ge-\log\nu(D_n)-\delta^*$.
* *Identification needs the left condition* (A m4). It holds with a margin linear in $n$ in two results, each with a probability qualifier:
  * iid Lemma 8.1(i) (PQ, fixed $n$, probability ≥ 1 − ε);
  * kink Thm 5.4(i) (sampling without replacement from a finite set, fixed $n$, probability ≥ 1 − 2ε).

  `thm:split:private`(iv) is proved by Kakutani's martingale argument and gives no rate.

*Proof.* `lem:split:ville` gives $-\log\nu_\pi(D_n)\ge-\log\nu(D_n)-\ell(\pi)-\delta^*=F_0-(k+\delta^*)-(\ell(\pi)-k)$ for every π and $n$. That is (R). In PQ use iid Lemma 2.2(a), with $\pi_0\in E_0$ a.s. attaining $F_0$. The rest is Lemma 1.1. ∎

[computed: t1(C): the length bounds agree to $2.1\cdot10^{-13}$ over 20,000 random $(k,\delta^*,\lambda,F_0)$; the fit bounds are compared only at the extreme length $(\lambda k+\delta^*)/(\lambda-1)$, where they coincide.]

So the length bound of the split theorem uses only the right condition. The same holds for the teacher on the full table with $m=d$:

**Proposition 2.4 (for m = d the teacher's right condition is the sufficiency line) [proved; computed: t1(D), rB2(C)].** Take `def:teacher:instance` with $m=d$, $r\ge3$ (so $p<1/4$), $B=\infty$, and the full truth table $D$ in total bits. Put
$$b_0:=\kappa_g+(NH(p)-L_E)+\delta_E+2\log d+\kappa,$$
the kink sub-track's offset (kink §4). Then every program π, of any level, satisfies
$$NR(\pi)\ \ge\ NH(p)-b_0-(\ell(\pi)-\ell_0),\qquad \ell_0=d+\kappa_g .$$
So (R) holds for all programs with τ = 1 and $g=b_0\le\kappa_g+\log(N+1)+\delta_E+2\log d+\kappa$. In particular:
* (i) every λ-MAP, λ > 1, has $\ell\le d+\kappa_g+b_0/(\lambda-1)$, whatever its level;
* (ii) `cor:teacher:fulltable`(i) is Lemma 1.1 in total bits with τ = 1 and $g=\Lambda_2$; the sufficiency line **improves the length bound** by replacing $\Lambda_2$ with $b_0=\Lambda_2-4-2\log d$ (A m17: its $\ell_M=0$ makes its Δ in Lemma 1.1(i), $b_0+(\lambda-1)(d+\kappa_g)$, and its upper fit bound worse; those stay with (D2));
* (iii) both the split theorem and the idiosyncratic-error theorem have the window's lower end at λ = 1. At λ = 1 both reference points sit on a line of slope 1: `thm:split:lambda1` and `cor:teacher:fulltable`(ii).

*Proof.*
* `lem:setup:coding` gives $\ell(\pi)+NR(\pi)\ge K(y_D\mid\dom D)-\kappa$.
* The proof of `prop:algstat:parity`(ii) gives $K(y_D\mid\dom D)\ge K(z)-2\log d-\kappa\ge d+L_E-\delta_E-2\log d-\kappa$. This uses minimum-distance decoding, valid for $p<1/4$. The step $K(z)\le K(z\mid d)+2\log d+\kappa$ is (F5) with its additive 2 absorbed into κ.
* Rearrange around $\ell_0=d+\kappa_g$; use $NH(p)-L_E\le\log(N+1)$.
* For (ii): at $m=d$, $B=\infty$, $\Lambda_1=4\log d+\kappa$, so $\Lambda_2-b_0=4+4\log d-2\log d=4+2\log d$ (each κ counted once). ∎

*Alignment (B-m5).* `notes.md` used $b_0':=b_0+2\log((d+1)/d)$, the literal form of (F5). The two differ by at most 2 bits, absorbed into κ. At $d=m=20$, $p=2^{-10}$, κ = 0, λ = 2 the length bounds are $d+45.55$ ($b_0$, kink's "$d+45.5$"), $d+45.69$ ($b_0'$, rB2(C)) and $d+58.19$ (the paper's $\Lambda_2$). [t1(D): the forms of `cor:teacher:fulltable`(i) and of Lemma 1.1 with $g=\Lambda_2$ agree exactly over 5000 random instances. This agreement is largely by construction: the script types the same expression twice, and its only real content is the substitution $c2^m-1=\lambda-1$ in the general $\Delta_\ell$ and risk formulas (A m18).]

**Remark 2.5 (δ* and δ_S are the same kind of slack) [remark, from proved results].**

| | the split | the teacher |
|---|---|---|
| deficiency | Ville deficiency $\delta^*$ of the sampled noise relative to ν | randomness deficiency $\delta_S$ of the error rule relative to the model |
| what it measures | how much any program, or the whole mixture, can compress the noise beyond ν | how much any program can compress the rule beyond its log-count |
| where it enters | the offset of the right line | the offset of the right line |
| tail | $\Pr[\delta^*\ge j]\le2^{-j}$ (`lem:split:ville`) | $\Pr_S[\delta_S>j]<2^{-j}$ for a uniform rule (`def:teacher:instance`(b)) |

A compressible "noise" is a model component. `prop:limits:envelope` is the teacher's case of large $\delta_S$. Its split analogue is a sampler whose coins are not random relative to the class.

**Remark 2.6 (a sharper form of `thm:teacher:main`(ii)(a) and (e)) [proved; computed: t6(C),(D), rB8].** Referee B's B-m2. Let π satisfy the hypotheses of (ii), so $\lev(\pi)=1$, and put $R_{\max}:=c(\kappa_g+4+\Lambda_1)+H(p)+\epsilon$.
* **(a1)** $u(\pi)\ge\max\{\tfrac34,\ 2^{-R_{\max}}-p-2^{-B}\}$.
* **(a2)** For every integer $g\ge1$, with $\gamma_g$ as in (ii)(e),
  $$u(\pi)\ \ge\ \frac{2^{-R_{\max}}-p\,(1+2\gamma_g+2^{1-g})-2^{-B}}{1-2p}.$$
* (e) holds with the larger $u$: $e(\pi)\le1-u(\pi)+\gamma_g+2^{-g}$.

*Proof.*
* (D1) at level 1 gives $\ell(\pi)\ge d-4-\Lambda_1$. So $R_B(\pi)=J^B_c(\pi)-c\ell(\pi)\le J_g(c)+\epsilon-c(d-4-\Lambda_1)=R_{\max}$. The paper's (a) uses $R_B\le J_g+\epsilon$ and wastes $c\,d$ in the exponent.
* (a1): `lem:teacher:floor`, $2^{-R_B}\le u+p+2^{-B}$.
* (a2): `lem:teacher:sharpfloor` gives $2^{-R_B}\le p+(1-2p)u+p(2\gamma(\pi)+2^{1-g})+2^{-B}$, with $\gamma(\pi)$ computed from the budget $I(\pi)$. By (ii)(d), $I(\pi)\le\Delta_\ell+\Lambda_3$, and $\gamma$ is nondecreasing in the budget, so $\gamma(\pi)\le\gamma_g$. Solve for $u$, using $1-2p>0$.
* (e)'s proof uses $u$ only through $\bar v\le1-u$. ∎

| instance (κ = 0, $\delta_S=0$, ε = 0) | $u\ge$: paper / (a1) / (a2) | $e\le$: paper / (a1) / (a2) |
|---|---|---|
| example, $c=10^{-4}$ | 0.9831 / 0.9882 / 0.9897 | 0.1991 / 0.1940 / 0.1925 |
| example, $c=4\cdot10^{-3}$, near the top of the window | 0.750 / 0.873 / 0.874 | 0.432 / 0.309 / 0.308 |
| §5, $p=1/16$, $c=6.75\cdot10^{-5}$ | 0.750 / 0.750 / **0.828** | 0.274 / 0.274 / **0.1965** |
| §5, $p=5/64$, $c=5.28\cdot10^{-5}$ | 0.750 / 0.750 / 0.803 | 0.273 / 0.273 / 0.220 |
| §5, $p=3/32$, $c=4.28\cdot10^{-5}$ | 0.750 / 0.750 / 0.780 | 0.271 / 0.271 / 0.240 |
| §5, $p=7/64$, $c=4.34\cdot10^{-5}$ | 0.750 / 0.750 / 0.760 | 0.269 / 0.269 / 0.260 |
| §5, $p=15/128$, $c=3.59\cdot10^{-5}$ | 0.750 / 0.750 / 0.750 | 0.269 / 0.269 / 0.269 |

t6(C),(D) and rB8 agree to every printed digit. (a1) is free and matters most near $c_{\rm hi}$, where the paper's (a) gives only 3/4; it can be passed to the paper. For §5's rows, where $p$ is not small, only (a2) helps.

---

## 3. The reuse factor: when a fixed λ suffices and when λ must grow with n

`notes.md` titled this section "Why fixed λ suffices for i.i.d. noise and the errors need λ ∝ n". Both referees showed that the noise side depends on the data object (A M4, B-M1). The correct dividing line is the reuse factor. In Paper 2's own likelihood it separates noise from errors as `notes.md` said; counted per query on repeated inputs, frozen noise falls on the errors' side.

### 3.0 The reuse factor

**Definition.** The **reuse factor** of a unit of "noise" (one sampled label, or one cell of an error rule) is the number of likelihood terms whose value it determines.

| unit | PQ | FR (Paper 2) | FQ | full table (DS) |
|---|---|---|---|---|
| one label of fresh or frozen noise at input $x$ | 1 (redrawn per query) | 1 | $N_n(x)$, the number of queries at $x$ | 1 |
| one cell $z$ of a junta error rule | queries in $z$, about $n2^{-m}$ | distinct sampled inputs in $z$, at most $2^{d-m}$ | queries in $z$, about $n2^{-m}$ | $2^{d-m}$ |
| one idiosyncratic error ($m=d$) at $x$ | $N_n(x)$ | 1 | $N_n(x)$ | 1 |

For the deterministic teacher PQ and FQ coincide (§1.0).

**Lemma 3.0 (duplication) [proved; computed: t7(C)].** Let a data object consist of the terms of a single data set $D$, each repeated $r$ times (FQ in which every input of $\dom D$ has been queried exactly $r$ times). Then every program's fit is $rL(\pi)$, so $J_\lambda(\pi)=r\,J_{\lambda/r}(\pi;D)$: the λ-MAPs are the $(\lambda/r)$-MAPs of $D$. Every λ-threshold of $D$ is multiplied by $r$: hull slopes, left steepness, right lines $(\tau,g)\mapsto(r\tau,rg)$, right secants and the window.

*Proof.* $\sum_{x\in\dom D}r\cdot(-\log\nu_\pi(D(x)\mid x))=rL(\pi)$, and $\lambda\ell+rL=r\big((\lambda/r)\ell+L\big)$. ∎

So a unit reused $r$ times saves about $r$ bits of fit per bit of its description when it is memorised, and λ must exceed $r$ times the threshold per use. The threshold per use is about 1 for noise (the sufficiency line and Ville's line, Props 2.3–2.4) and $\theta_m\approx1$ per input for the cells of an incompressible error rule (Prop 3.1).

### 3.1 Full tables

**Proposition 3.1 (full tables: the window starts at the reuse factor $2^{d-m}$) [proved; computed: t1(D), rB2(B), t5(B), rB3(A)].** Take `def:teacher:instance` with any $1\le m\le d$, $B=\infty$, and the full truth table ($n=N$), in total bits.
* (a) For every $\lambda\in(2^{d-m},Nc_{\rm hi})$, every λ-MAP satisfies `thm:teacher:main`(ii) with $c=\lambda/N$ and ε = 0. Its length is at most
  $$d+\kappa_g+\frac{2^{d-m}\Lambda_2}{\lambda-2^{d-m}}.$$
* (b) For $\lambda<2^{d-m}\theta_m$, with $\theta_m:=2^mH(p)/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$, the memoriser beats every level-1 program with $R\ge H(p)$.
* (c) In the terms of Def 1.4, at the reference $(d+\kappa_g,NH(p))$ with $M$ the level-1 programs:
  * $(2^{d-m},\,2^{d-m}\Lambda_2)$ is a right line (Prop 2.1(b) times $N$);
  * at every level-1 point with $R\ge H(p)$ the right secant is at least $2^{d-m}\theta_m$, the memoriser's;
  * every right line of slope $\tau$ through the reference has offset $g\ge NH(p)-\tau(\lceil L_S\rceil+\kappa_b-\kappa_g)$. For $\tau=\rho2^{d-m}$ this is $2^{d-m}\big(2^mH(p)-\rho(\lceil L_S\rceil+\kappa_b-\kappa_g)\big)$, about $2^{d-m}(1-\rho)L_S$.

  So a line of slope $2^{d-m}$ costs an offset of $2^{d-m}$ times $O(\log2^m+\delta_S+\log d)$, while every line flatter than the memoriser's secant costs an offset linear in $L_S$. In this sense the right flatness is the reuse factor $2^{d-m}=N/2^m$, the number of inputs per cell. For $m=d$ it is 1, as for noise.
* $\theta_m=1+O((m+\log d+\kappa)/L_S)$. The sign of the $O$-term is not determined: $2^mH(p)\ge L_S$, but the denominator adds $\kappa_b+4+\Lambda_1$ (A m10; `notes.md` wrote $1-O(\cdot)$).

*Proof.*
* *(a) and (b).* A full-table λ-MAP minimises $\lambda\ell+NR=NJ_{\lambda/N}$. Apply `thm:teacher:main`(ii) and (iv) with $c=\lambda/N$. For (a), $J_g<\Phi_2$ holds strictly on $(0,c_{\rm hi})$, since $J_g-\Phi_2$ is a maximum of strictly increasing affine functions. Also $c2^m-1=(\lambda-2^{d-m})/2^{d-m}$.
* *(c).* The line is Prop 2.1(b) multiplied by $N$. For the secant, $\ell(\pi_b)-\ell\le\lceil L_S\rceil+\kappa_b+4+\Lambda_1$ for every level-1 program, because $\ell\ge d-4-\Lambda_1$ by (D1). For the offset, apply (R) to $\pi_b$, which is level 1 ($u(\pi_b)=1-p>\frac34$) and has fit 0: $0\ge NH(p)-g-\tau(\ell(\pi_b)-\ell_0)$, and $\ell(\pi_b)-\ell_0\le\lceil L_S\rceil+\kappa_b-\kappa_g$ (if $\ell(\pi_b)\le\ell_0$ the bound $g\ge NH(p)$ is even stronger). ∎

[computed: t1(D), confirmed by rB2(B); $B=\infty$, $\delta_S=0$, κ = 0.]

| $d$ | $m$ | $L_S$ | $\theta_m$ | lower end $2^{d-m}$ | memoriser's secant $2^{d-m}\theta_m$ | upper end $Nc_{\rm hi}$ |
|---|---|---|---|---|---|---|
| 20 | 20 | 11,710.27 | 0.9955 | 1 | 0.9955 | $1.195\cdot10^4$ (the paper's value) |
| 20 | 18 | 2,923.82 | 0.9836 | 4 | 3.934 | $1.195\cdot10^4$ |
| 20 | 16 | 727.96 | 0.9421 | 16 | 15.07 | $1.195\cdot10^4$ |
| 20 | 12 | 43.41 | 0.5473 | 256 | 140.1 | $1.195\cdot10^4$ |
| 100 | 20 | 11,710.27 | 0.9947 | $1.209\cdot10^{24}$ | $1.203\cdot10^{24}$ | $1.022\cdot10^{28}$ |

* At $d=20$, $m=12$ ($s_0=4$) $L_S=\log_2\binom{4096}{4}=43.41$ bits, not 41 as `notes.md` said (A m10, B-m5). There the $O(\log)$ overheads are large compared with $L_S$.

[computed: t5(B), exact ceilings; t2's class at $d=10$, $p=1/16$; $m=10,8,6,4$ are the instances of t2(A), $m=9,7,5$ new instances.]

| $m$ | $2^{d-m}$ | λ-set of the true-parity family | of the rate-$p$ member | of the rate-1/8 member | lower end $/\,2^{d-m}$ |
|---|---|---|---|---|---|
| 10 | 1 | (0.9953, 46.22) | (0.9953, 31.55) | (31.55, 46.22) | 0.995 |
| 9 | 2 | (1.930, 46.22) | (1.930, 31.55) | (31.55, 46.22) | 0.965 |
| 8 | 4 | (3.754, 46.22) | (3.754, 31.55) | (31.55, 46.22) | 0.9385 |
| 7 | 8 | (7.349, 46.22) | (7.349, 31.55) | (31.55, 46.22) | 0.919 |
| 6 | 16 | (15.70, 46.22) | (15.70, 31.55) | (31.55, 46.22) | 0.981 |
| 5 | 32 | (37.69, 46.22) | never a λ-MAP | (37.69, 46.22) | — |
| 4 | 64 | never a λ-MAP | never | never | — |

* *The lower end is the reuse factor times a code-dependent factor.* For $m\ge6$ the factor lies in $[0.918,0.996]$ here and in $[0.928,0.992]$ in class K at $d=10,12$ [rB3(A)].
* *A hull slope above the line's slope.* At $m=5$ the rule memoriser's secant from the rate-$p$ member is $1.199\cdot2^{d-m}$ (1.079 in class K, rB3(A)). Lemma 1.5(a) allows this: the line of slope $2^{d-m}$ bounds secants only by $2^{d-m}+g/x$. **[refuted]** read as a secant, `notes.md`'s claims-table row "total-bit right flatness in $[2^{d-m}\theta_m,2^{d-m}]$" fails here. That interval bounded no single quantity (A M3): its lower end is a secant, its upper end a line slope. Prop 3.1(c) states each correctly.
* *$m=4$ (B-m4).* **[refuted]** `notes.md`: "for $m=4$ the rule is one cell, cheaper than the model's own rate code". The one-cell rule memoriser is 26 bits long, 4 bits longer than the good model's 22 (5 bits with tcommon's ceiling). It saves 345.39 bits of fit, a secant of 86.35 per bit, which exceeds the model's own secant from the coin, 45.24. So the good model is not a vertex. This is rate blindness (§4) [computed: t5(B), rB3(F)].
* *A ceiling bug (B-m3).* `tcommon.log2binom` takes the ceiling of an lgamma value, which is one bit too high when $\binom nk$ is a power of 2 ($\binom{2^m}1$, $\binom{2^m}{2^m-1}$; 13 of 14,342 pairs, rB2(D)). It charges the single-cell rule (F5, $j=1$) and the single named input (F3, $j=1$, $d=10$) one bit too many. With exact ceilings only t2(A)'s $m=4$ lines change: the coin's lower end 51.2 → 53.89, F5's length 27 → 26 [computed: rB0, t5(B)]. No number quoted from t2 changes. t1–t4 and `tcommon.py` are kept unchanged as the refereed record; t5 uses exact ceilings.
* *Idiosyncratic errors* ($m=d$): in class K the family's λ-set starts at 0.998–1.070 for $d=8,10,12$ and $p\in\{1/32,1/16\}$, also where $G_1<H(p)$ [rB3(B)]. This is Prop 2.4(iii).

**Proposition 3.2 (λ_n = o(n) ends at the least-risk programs; λ = cn at the minimisers of $J_c$) [proved].**
* *Setting.* PQ: pairs $(x_i,y_i)$ i.i.d. from $\mu\otimes P^*$, for any label channel $P^*$: a sampler's fresh noise, or $\delta_{y^*}$ for a deterministic teacher (which is FQ with $F=y^*$). Likelihoods are per query. The class is countable with Kraft weights. Put $R(\pi):=\Ex[-\log\nu_\pi(y\mid x)]\in[0,\infty]$ and $\hat R_n:=L_n/n$.
* (a) Let $\lambda_n\ge0$ with $\lambda_n/n\to0$. Let $\pi_0,\pi_1$ be programs with $R(\pi_1)<R(\pi_0)$ and $R(\pi_1)<\infty$. Then almost surely $\pi_0$ is a $\lambda_n$-MAP for only finitely many $n$. (`notes.md` assumed $\lambda_n\ge1$, which is not used.)
* (b) *Noise, PQ.* If $P^*=\nu$ is a sampler, then $R(\pi)-R(\nu)=\Ex_\mu\KL(\nu(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x))\ge0$, with equality iff $\nu_\pi=\nu$ μ-a.e. So ν's programs have least risk, and (a) never excludes them. iid Thm 3.1 identifies the limit as $E_0$.
* (b′) *Frozen noise counted per query* (FQ; A M4). If the channel is $\delta_F$ for a table $F$ drawn once from a sampler with noise on the support of μ, (a) applies with $y^*=F$: a program that agrees with ν off a finite set of atoms and predicts $F$ there has smaller risk than ν's programs. So every $\lambda_n=o(n)$ eventually rejects ν's programs (Prop 3.7(b)). In FR this does not happen (Prop 3.7(a)).
* (c) *Errors.* If $P^*=\delta_{y^*}$ for the teacher, then $R(\pi_b)=0<H(p)=R(\pi_g)$. By (a), every schedule with $\lambda_n=o(n)$ eventually rejects the good model; Prop 3.6(a) gives the uniform form.
* (d) *λ = cn, countable classes* (A m7). Let $\lambda_n=cn$, $J_c:=c\ell+R$ with $\min J_c<\infty$, and $A_c:=\arg\min_\pi J_c(\pi)$, which is finite and nonempty. Almost surely every cn-MAP lies in $A_c$ for all large $n$. If the members of $A_c$ share one kernel μ-a.e., the set of cn-MAPs equals $A_c$ for all large $n$.

*Proof.*
* *(a).* The per-query losses are nonnegative. By the strong law [known: e.g. Durrett, *Probability: Theory and Examples*, for nonnegative variables with possibly infinite mean; edition and theorem number unverified], $\hat R_n(\pi_1)\to R(\pi_1)$ and $\hat R_n(\pi_0)\to R(\pi_0)\in(R(\pi_1),\infty]$ almost surely. Then
  $$\tfrac1n[J_{\lambda_n}(\pi_0)-J_{\lambda_n}(\pi_1)]=\tfrac{\lambda_n}n(\ell(\pi_0)-\ell(\pi_1))+\hat R_n(\pi_0)-\hat R_n(\pi_1)\to R(\pi_0)-R(\pi_1)>0 .$$
* *(b).* Gibbs' inequality for a sub-probability $\nu_\pi(\cdot\mid x)$, with the equality case as in iid Lemma 2.1(b).
* *(b′).* (a), with $\pi_1$ the memorising program.
* *(c).* Immediate.
* *(d).* This is iid Prop 3.4(c). A cn-MAP $\hat\pi$ has $cn\,\ell(\hat\pi)\le J_{cn}(\pi_c)$ for $\pi_c\in A_c$, so $\ell(\hat\pi)\le\ell(\pi_c)+\sup_n\hat R_n(\pi_c)/c$, which is almost surely finite. Only finitely many programs qualify. For each of them outside $A_c$, $J_{cn}/n\to J_c>J_c(\pi_c)$ almost surely. Members of $A_c$ with one kernel have equal risk, hence equal length, and almost surely equal likelihoods. ∎

**Reading [remark, from Props 3.2, 3.6, 3.7 and iid].**
* *The split's target (PQ).* The least-risk programs, among which are ν's programs (Gibbs). Every schedule with $1\le\lambda_n=o(n)$ ends at $E_0$ (iid Thm 3.1). A fixed λ > 1 adds uniform and explicit guarantees (iid Thm 4.1; Lemma 1.1 with τ = 1).
* *The teacher's target.* The minimisers $A_c$ of $J_c$ for $c$ in the window. For small ε they lie in $\mathcal N_\epsilon(c)$, so they know the parity, are short and do not predict the errors. They are not necessarily $\pi_g$ (§2.1, "What is selected"). The least-risk programs memorise the errors, so every $\lambda_n=o(n)$ learns them.
* *Which schedules stop at the model.* Those whose ratio $\lambda_n/n$ eventually stays in a compact subset of the window (Prop 3.6). λ = cn is the simplest. `notes.md`'s "only λ = cn can stop at an interior vertex" is **[refuted as stated]** (A M1): any schedule with $\lambda_n/n\in[c_1,c_2]\subset(2^{-m},c_{\rm hi})$ does as well.
* *λ = cn for noise.* It works if and only if $c<c^*$, the truth's left steepness (iid Prop 3.4(a),(b)). The direction "$c<c^*$ suffices" is iid Prop 3.4(b); `notes.md` cited it before that file proved it (A m8).
* *Deliberate inconsistency.* This is `rem:limits:schedule` in hull form. λ = cn gives up the components whose rate is below $c$. In the teacher's example these are the errors, with risk $H(p)$ per sample, but `prop:limits:separable` shows it can just as well be a valid component.

**Proposition 3.6 (which schedules keep the identification) [proved].** The instance of `def:teacher:instance`.
* (a) *$\lambda_n/n\to0$.* In PQ (= FQ) with i.i.d. uniform inputs and $\lambda_n>0$, almost surely, for all large $n$, every $\lambda_n$-MAP has $R=0$: it gives $y^*(x)$ probability 1 at every input, so $e=1$.
* (b) *$\lambda_n/n\to\infty$.* In PQ, let $\ell_{\min}:=\min\{\ell(\pi):R(\pi)<\infty\}$. Almost surely, for all large $n$, every $\lambda_n$-MAP has length at most $\ell_{\min}$. In $\Hcl{\times}$, $\ell_{\min}\le\ell(\pi_{\rm coin})\le\kappa$, which is below the length $d-4-\Lambda_1$ of every level-1 program once $d-4-\Lambda_1>\kappa$: the MAP does not know the parity.
* (c) *$\lambda_n/n$ in a compact subset of the window.* Let $B<\infty$ and $2^{-m}<c_1\le c_2<c_{\rm hi}$. For each $n$ (PQ, or Paper 2's samples without replacement, $n\le2^d$) and each $\lambda_n$ with $\lambda_n/n\in[c_1,c_2]$: with probability at least $1-\delta$, every $\lambda_n$-MAP satisfies `thm:teacher:main`(ii) with $c=\lambda_n/n$ and
  $$\epsilon=\bar\epsilon_n:=\epsilon_1+B\sqrt{\frac{\bar L\ln2+\ln(2/\delta)}{2n}},\qquad \bar L:=\frac{J_g(c_2)+\epsilon_1}{c_1},$$
  whenever $J_g(c)+\bar\epsilon_n<\Phi_2(c)$ on $[c_1,c_2]$, which holds for all large $n$. In PQ with $\delta_n=n^{-2}$, almost surely this holds for all large $n$.

So $\lambda_n/n\to0$ learns the errors, $\lambda_n/n\to\infty$ forgets the model, and $\lambda_n/n$ eventually in a compact subset of the window keeps the identification. Schedules whose ratio oscillates in and out of the window are not covered. With $\Phi_2^\sharp$ of §5 in place of $\Phi_2$ the same holds for $p<0.1233$.

*Proof.*
* *(a).* A $\lambda_n$-MAP $\hat\pi$ has $\lambda_n\ell(\hat\pi)\le J_{\lambda_n}(\hat\pi)\le J_{\lambda_n}(\pi_b)=\lambda_n\ell(\pi_b)$, since $\pi_b$ has fit 0. So $\ell(\hat\pi)\le\ell(\pi_b)$, and only finitely many candidates remain. By Prop 3.2(a) with $\pi_1=\pi_b$, each candidate with $R>0$ is eventually not a MAP. A program with $R=0$ under uniform inputs gives $y^*(x)$ probability 1 at every $x\in\{0,1\}^d$.
* *(b).* Fix $\pi_0$ with $\ell(\pi_0)=\ell_{\min}$ and $R(\pi_0)<\infty$, so $\hat R_n(\pi_0)\to R(\pi_0)$ almost surely. Lengths are integers. Every π with $\ell(\pi)\ge\ell_{\min}+1$ has $J_{\lambda_n}(\pi)\ge\lambda_n(\ell_{\min}+1)>\lambda_n\ell_{\min}+n\hat R_n(\pi_0)=J_{\lambda_n}(\pi_0)$ as soon as $\lambda_n>n\hat R_n(\pi_0)$, which holds eventually. (Shorter programs, all with $R=\infty$, are not excluded by this argument.)
* *(c).* `lem:teacher:finite` holds at each $n$ for any value of $c$; in PQ, Hoeffding's inequality for independent bounded variables gives the same. With $c=\lambda_n/n$, its excess is $\epsilon_1+B\sqrt{(\hat L(c)\ln2+\ln(2/\delta))/(2n)}$ with $\hat L(c)=(J_c(\pi_g)+\epsilon_1)/c\le(J_g(c_2)+\epsilon_1)/c_1=\bar L$, because $J_g$ is increasing and $1/c\le1/c_1$. So $J^B_c(\hat\pi)\le J_g(c)+\bar\epsilon_n$, and (ii) applies when $c2^m>1$ and $J_g(c)+\bar\epsilon_n<\Phi_2(c)$. The function $\Phi_2-J_g$ is continuous and positive on the compact $[c_1,c_2]\subset(0,c_{\rm hi})$, so it has a positive minimum, and $\bar\epsilon_n\to0$. With $\delta_n=n^{-2}$, $\bar\epsilon_n$ still tends to 0, and Borel–Cantelli gives the almost sure form. ∎

**Proposition 3.7 (frozen noise: reuse factor 1 in Paper 2's likelihood, the input multiplicity per query) [(a) proved, from `lem:split:ville`; (b), (c) proved; computed: t5(D), rB5].**
* *Setting.* $X$ countable; inputs i.i.d. from μ. A sampler ν has a program $\pi_0$ of length $k$, in a countable class $\mathcal C$ with Kraft sum at most 1, whose kernel equals ν at every input of $\mathrm{supp}\,\mu$. The table $F$ has independent values $F(x)\sim\nu(\cdot\mid x)$, drawn once.
* (a) *FR (Paper 2's likelihood).* Index the process by distinct inputs. For all $n$ and all $\pi\in\mathcal C$,
  $$-\log\nu_\pi(D_n)\ \ge\ -\log\nu(D_n)-\ell(\pi)-\delta^*,\qquad\Pr[\delta^*\ge j]\le2^{-j}.$$
  So $(k,-\log\nu(D_n))$ has the right line $(1,k+\delta^*)$ at every $n$, and for every fixed λ > 1 every λ-MAP has length at most $k+(k+\delta^*)/(\lambda-1)$ at every $n$, repeats or not. A program that agrees with ν off a finite set $A\subseteq\mathrm{supp}\,\mu$ gains at most $\sum_{x\in A}\log(1/\nu(F(x)\mid x))$ bits of fit over $\pi_0$, however often the inputs of $A$ are queried.
* (b) *FQ.* Let $A\subseteq\mathrm{supp}\,\mu$ be finite with $\nu(F(x)\mid x)<1$ for some $x\in A$, and let $\pi_A\in\mathcal C$ agree with ν off $A$ and give $F(x)$ probability 1 on $A$. Then
  $$L^{\rm FQ}_n(\pi_0)-L^{\rm FQ}_n(\pi_A)=\sum_{x\in A}N_n(x)\log\frac1{\nu(F(x)\mid x)},$$
  and divided by $n$ this tends almost surely to $\sum_{x\in A}\mu(x)\log(1/\nu(F(x)\mid x))>0$. So for every schedule $\lambda_n=o(n)$, $\pi_0$ is a $\lambda_n$-MAP for only finitely many $n$. The noise at $x$ is reused $N_n(x)\approx n\mu(x)$ times.
* (c) *FQ on a uniform finite support.* If μ is uniform on a finite $X_0$ and every input of $X_0$ has been queried $\bar n$ times, the FQ λ-MAPs are the $(\lambda/\bar n)$-MAPs of the full table $F|_{X_0}$ (Lemma 3.0). Every λ-threshold of the full table, the sampler's window included, is multiplied by $\bar n=n/|X_0|$.

*Proof.*
* *(a).* Distinct inputs arrive by a rule that picks each new input before its label is drawn, and the label at a new input is drawn from $\nu(\cdot\mid x)$ independently of the past (iid Def 1.3). `lem:split:ville` holds for such rules (iid Lemma 2.2(c)). The line follows as in Prop 2.3, and the length bound from Lemma 1.1(ii). For the bounded gain: $\nu_\pi(D_n)/\nu_{\pi_0}(D_n)=\prod_{x\in A\cap\dom D_n}\nu_\pi(F(x)\mid x)/\nu(F(x)\mid x)\le\prod_{x\in A}1/\nu(F(x)\mid x)$.
* *(b).* The displayed identity holds term by term. $N_n(x)/n\to\mu(x)$ almost surely, and μ(x) > 0 on the support. The length difference is fixed, so $J_{\lambda_n}(\pi_0)-J_{\lambda_n}(\pi_A)=\lambda_n(k-\ell(\pi_A))+[\text{the fit difference}]\to+\infty$ when $\lambda_n=o(n)$.
* *(c).* Lemma 3.0. ∎

[computed: t5(D); $d=10$; i.i.d. uniform inputs with repeats; 24 runs per source; fraction of runs whose λ-MAP is the true parity at any rate (the rest are memorisers unless marked); $n$ queries, $n'$ distinct inputs. Class K is referee B's, imported unchanged from rB5, so that the only change from rB5 is the likelihood; t2's class is a second, independent class.]

*Frozen noise, one Bern(1/16) flip per input.*

| object | λ = 2 | λ = 8 | λ = 20 | λ = √n | λ = c·(n or n′) |
|---|---|---|---|---|---|
| FQ, class K | 0.96–1.00 up to $n/N=1$; memoriser from $n/N=4$ | 1.00 for $n/N\in[1/4,4]$; memoriser from 16 | 1.00 for $n/N\in[1,16]$; memoriser from 64 | 1.00 up to $n=2^{18}$; memoriser in 88% at $2^{20}$ and all at $2^{22}$ | 1.00 from $n=256$ |
| FR, class K | 1.00 at every $n\ge256$ (0.96 at $n=64$) | 1.00 from $n=256$ | 1.00 from $n=1024$ | 0 from $n=1024$, and no memoriser: λ exceeds the left steepness, since the data set stops growing at $N$ | 1.00 from $n=256$ |
| FR, t2's class | as class K | as class K | as class K | as class K | as class K |

*The teacher, junta errors, $m=6$, $p=1/16$ ($2^{d-m}=16$).*

| object | λ = 2 | λ = 8 | λ = 20 | λ = √n | λ = c·(n or n′) |
|---|---|---|---|---|---|
| FQ (= PQ), class K | 0.88 at $n=64$; memoriser from 256 | 1.00 at 256; memoriser from 1024 | 1.00 at 1024; memoriser from 4096 | 1.00 at 1024, 0.75 at 4096; memoriser from 16,384 | 1.00 from $n=256$ |
| FR, class K | 0.88 at 64; memoriser from 256 | 1.00 at 256; memoriser from 1024 | 1.00 at every $n\ge1024$ | 0 from 1024, no memoriser (left side) | 1.00 from $n=256$ |
| FR, t2's class | 0.96 at 64; memoriser from 256 | as class K | as class K | as class K | as class K |

* *FR.* Frozen noise is never memorised at a fixed λ ≥ 2: its reuse factor is 1. The junta errors are memorised at λ = 2 and 8, below the full-table window's lower end $15.7\approx16\theta$. At λ = 20 > $2^{d-m}=16$ the model is kept for ever: on a finite domain the distinct multiplicity of a cell saturates at $2^{d-m}$. At the example's sizes $2^{d-m}=2^{80}$.
* *FQ.* Both sources are memorised by every fixed λ and by √n, at the switch points that Lemma 3.0 predicts: once $\bar n\theta$ exceeds λ, with $\bar n=n/N$ for the noise and $n/2^m$ for the errors. For example λ = 20 switches between $n/N=16$ and 64 (predicted: $n/N\approx20$), and √n between $2^{18}$ and $2^{22}$ (predicted $n\approx(N/\theta)^2\approx2^{20}$). rB5 reports the same switch points with its own seeds.
* *Schedules.* λ proportional to the number of distinct inputs works in FR, λ proportional to $n$ in FQ.
* rB5's docstring calls its frozen source "Paper 2's `def:setup:data`", but its fits count every query (FQ). Under `def:setup:data`'s likelihood the frozen noise behaves as in the FR rows.

**The answer to the brief's question** ("why do the teacher's errors, unlike i.i.d. noise, require λ ∝ n?") [remark, from Props 3.1, 3.2, 3.6, 3.7]:
* The errors are a fixed function of the input. Each bit of the error rule is reused at every input of its cell, about $n2^{-m}$ times on $n$ samples. Memorising the rule therefore buys about $n2^{-m}\theta_m$ bits of fit per bit of length, and λ must exceed that, which grows like $n$.
* Noise drawn once per distinct input (Paper 2's likelihood) or redrawn per query is used once. Its right line has slope 1 at every $n$, and every fixed λ > 1 keeps the selected program within $(k+\delta^*)/(\lambda-1)$ bits of the sampler.
* Frozen noise counted per query on repeated inputs is the exception: it is reused at each repeat, like an error rule with $m=d$, and needs λ ∝ n/N.

### 3.2 Sampled data

**Proposition 3.3 (sampled data: the right side at the good model) [(a) proved; (b) coding lemma, chain rule and equal-multiplicity line proved, unequal multiplicities open; computed: t2(B), t5(C), rB4, rB6].** $n$ inputs drawn uniformly without replacement from $\{0,1\}^d$, labelled by $y^*$ (FR with $n'=n$), the data reading in total bits. Let $Z$ be the set of cells of $\{0,1\}^m$ hit by the sample, $n_z$ the number of sampled inputs in cell $z$, and $F_g:=-\log\nu_{\pi_g}(D_n)\approx nH(p)$. Take $\pi_g$ with a kernel that is a computable measure at every input of length at most $d$, for example flip rate $p$ on $\{0,1\}^d$ and a fair coin elsewhere, at $O(1)$ more bits (A m16).

* **(a) Lower bounds** [proved]. By Lemma 1.5(c) the good model is beaten at every λ below each of two secants:
  * the rule memoriser's, $F_g/(\ell(\pi_b)-\ell(\pi_g))$, about $nH(p)/L_S\approx n2^{-m}\theta_m$;
  * that of the single covering fill-in of iid Lemma 5.2, built with $\pi_g$ as decoder: $F_g/(F_g+O(\log n+\log d+\log F_g))\to1$. That lemma needs a decoder that is a measure on $\{0,1\}^{\le d}$ (iid Def 1.2), hence the choice of $\pi_g$.

  So the right secant at the good model is at least about $\max\{1,n2^{-m}\theta_m\}$. The "1" needs the covering fill-in, which exists in the canonical class. In explicit classes without it the lower end is below 1 for $n\le128$: 0.64–0.94 in t2's class [t5(C)] and 0.56–0.86 in class K [rB4] (B-m11).
* **(b) A right line from a sampled coding lemma.**
  * *Sampled coding lemma* [proved; computed: rB6(A)]. For a program π, $z\in Z$ and $b\in\{0,1\}$ put
    $$q_z(b):=2^{-\frac1{n_z}\sum_{x\in\dom D_n,\ {\rm cell}(x)=z}-\log\nu_\pi(f_a(x)\oplus b\mid x)} .$$
    By the weighted AM–GM inequality, $q_z(0)+q_z(1)\le1$. So $Q(T):=\prod_{z\in Z}q_z(\ind_T(z))$ is a lower-semicomputable semimeasure on subsets of $Z$, given $(\pi,a,\dom D_n,m)$. Since $y^*=f_a\oplus\ind_S({\rm cell}(x))$, $-\log Q(S\cap Z)=\sum_zF_z/n_z$, where $F_z$ is π's fit on the sampled inputs of cell $z$. By (F2), (F3) and (F5),
    $$K(S\cap Z\mid\pi,a,\dom D_n)\ \le\ \sum_{z\in Z}\frac{F_z(\pi)}{n_z}+2\log(m+1)+\kappa .$$
    The cells need $m$, which $\dom D_n$ does not determine; `notes.md` omitted this $2\log(m+1)$ (A m6). The paper's `lem:teacher:coding` pays the same.
  * *The chain rule* [proved; `notes.md` only sketched it (A m6)]. Put $C:=K(S\cap Z\mid a,\dom D_n)$. For a level-1 program π of length $d+x$:
    * $C\le K(\pi\mid a,\dom D_n)+K(S\cap Z\mid\pi,a,\dom D_n)+\kappa$ (F3);
    * $K(\pi\mid a,\dom D_n)\le K(\pi\mid a)+\kappa\le K(\pi\mid a,K(a))+K(K(a))+\kappa$ (F3); the first step needs no assumption on $\dom D_n$ (B);
    * $K(\pi\mid a,K(a))\le K(\pi)+K(a\mid\pi)-K(a)+\kappa\le x+4+2\log d+\kappa$ (F4, F3, F1, `lem:teacher:list` at level 1, $K(a)\ge d$);
    * $K(K(a))\le2\log(2d)+\kappa$ (F5, with $K(a)\le2d-1$).

    Together,
    $$\sum_{z\in Z}\frac{F_z(\pi)}{n_z}\ \ge\ C-x-c_1,\qquad c_1:=4+2\log d+2\log(2d)+2\log(m+1)+\kappa .$$
  * *Equal multiplicities* [proved]. If $n_z=\bar n$ for every $z\in Z$, then $F(\pi)=\sum_zF_z(\pi)=\bar n\sum_zF_z(\pi)/n_z\ge\bar n(C-x-c_1)$. At the reference $(\ell(\pi_g),F_g)$ this is a right line on the level-1 programs with $\tau=\bar n$ and offset $g\le\bar n(\beta+c_1+\kappa_g)$. Here $\beta:=\sum_zF_z(\pi_g)/n_z-C$ is the good model's sufficiency gap at the level of cells, and $\ell(\pi_g)-d\le\kappa_g$.
    * On the full table $\bar n=2^{d-m}$ (Prop 3.1).
    * While every sampled cell is hit once ($n\ll2^{m/2}$), $\bar n=1$, as for noise.
  * *Unequal multiplicities.*
    * [proved] With $n_{\min}:=\min_zn_z$ the same display gives a right line of slope $n_{\min}$, with offset $F_g-n_{\min}(C-c_1-\kappa_g)$, which is large unless the multiplicities are nearly equal. If $n_z\in[(1-\eta)\bar n,(1+\eta)\bar n]$ for all $z\in Z$, with $\bar n:=n/|Z|$, the slope $(1-\eta)\bar n$ comes with offset at most $\bar n\big((1+\eta)\beta+c_1+\kappa_g+2\eta C\big)$, because $F_g\le(1+\eta)\bar n(C+\beta)$. The term $2\eta\bar nC$ makes the resulting length bound informative only for $n\gg2^mL_S^2$, the regime of `cor:teacher:sampled`.
    * **[withdrawn; now open]** `notes.md`: "near the good model the effective slope can approach $\max_zn_z$: a program can memorise the most repeated error cells first". Nothing at the computed sizes supports it (B-m6). The lower end of the family's λ-set tracks the **mean** multiplicity of the sampled error cells: $\tau_n/\text{mean}=0.82$–0.94 for $n\ge256$ in t2's class [t5(C)] and 0.83–0.93 in class K [rB4], while the largest multiplicity is 1.2–2.1 times the mean.
  * *The unproved step for $\bar n=1$* [proof sketch]. It is that β is small: $C$ is close to the good model's code length for $S\cap Z$, about $\log\binom{|Z|}{|S\cap Z|}$. This needs $S\cap Z$ to be incompressible given the independent random sample. Granted that, the good model's right line has slope 1, as for noise.
* **(c) Where windows in λ are proved** (A M2).
  * Population: $c=\lambda/n\in(2^{-m},c_{\rm hi}]$ (`thm:teacher:main`).
  * Full table: $\lambda\in(2^{d-m},Nc_{\rm hi})$ (Prop 3.1).
  * Samples: for each fixed $c\in(2^{-m},c_{\rm hi})$ and $n\ge n_0(c)$, through `cor:teacher:sampled`. At the example's sizes, with $B=30$, $\delta=0.01$ and κ = 0, near-population constants need about $10^{11}$ samples (`cor:teacher:sampled`'s numbers).
  * For smaller samples only (a), and (b) under equal multiplicities, are proved.
  * **[conjecture; computed: t2(B), t5(C), rB4]** For $n\gg2^m$ the lower end of the true-parity family's λ-set is θ times the mean multiplicity of the sampled error cells, up to $O(\log)$ terms, and its upper end grows like $n$.

  `notes.md`'s summary "the window in λ is $(1,\Theta(n))$ for noise and $(n2^{-m},nc_{\rm hi})$ for errors" is replaced by this list. For $n<2^m$ it contradicted (a), whose lower end is about 1, not $n2^{-m}<1$.

[computed: t5(C); $d=14$, $m=8$, $p=1/16$ (16 error cells of 256); t2's class with exact ceilings; the instance and the 20 samples per $n$ of t2(B); medians, and fractions of samples.]

| $n$ | family $(\tau_n,\sigma_n)$ | rate-$p$ member | $\tau_n/$mean mult. | max/mean mult. | λ = 2: family / rate $p$ | λ = 4n2^{-m}: family / rate $p$ | λ = 16n2^{-m}: family |
|---|---|---|---|---|---|---|---|
| 32 | (0.635, 1.12) | (0.635, 0.99) | 0.64 | 1.00 | 0.10 / 0.00 | 0.10 / 0.00 | 0.10 |
| 64 | (0.800, 2.44) | (0.933, 2.64) | 0.68 | 1.00 | 0.70 / 0.55 | 0.90 / 0.40 | 0 |
| 128 | (0.936, 4.67) | (0.942, 4.67) | 0.75 | 1.67 | 1.00 / 0.85 | 1.00 / 0.85 | 0 |
| 256 | (1.39, 8.99) | (1.42, 8.99) | 0.82 | 1.84 | 1.00 / 0.80 | 1.00 / 0.80 | 0 |
| 512 | (2.03, 18.2) | (2.01, 18.2) | 0.92 | 2.12 | 0.40 / 0.40 | 1.00 / 0.85 | 0 |
| 1024 | (3.95, 35.4) | (3.95, 27.7) | 0.93 | 1.74 | 0 / 0 | 1.00 / 0.85 | 0 |
| 4096 | (15.1, 144) | (15.1, 125) | 0.94 | 1.35 | 0 / 0 | 1.00 / 1.00 | 0 |
| 16384 | (60.1, 575) | (60.1, 505) | 0.94 | 1.00 | 0 / 0 | 1.00 / 1.00 | 0 |

* *The lower end tracks the mean multiplicity*: $\tau_n\approx0.94$ times it for $n\ge512$; the factor is $2^mH(p)/(\ell(\pi_b)-\ell(\pi_g))$ for the rule memoriser.
* **[refuted]** `notes.md`: "the fixed λ = 2 keeps the good model in every sample up to $n=2^m$". It keeps the true-parity family in 10% of the samples at $n=32$ and 70% at $n=64$ (A m11, B-m6). These failures are on the left, where λ exceeds $\sigma_n$. It keeps it in every sample at $n=128$ and 256, in 40% at 512, and in none from 1024 on.
* λ = $4n2^{-m}$ keeps the family in 90% of the samples at $n=64$ and in all from $n=128$; the rate-$p$ member in 40–100%. `notes.md`'s "at every $n\ge64$" quoted a mode over samples.
* λ = $16n2^{-m}$ never keeps it for $n\ge64$. The upper end is $\sigma_n\approx9\,n2^{-m}$ at these sizes, so the c-window of the explicit class is about $(0.94,9)\cdot2^{-m}$, a factor of 10 (B-m6).
* The right neighbour of the family on the hull is the parity plus rule cells (F5) in every sample from $n=128$ on.
* At $n=16384=N$ the sample is the full table, and $\tau_n=60.07=64\times0.939$, as in Prop 3.1.
* *What "exact hull" means here* (A m11, B-m11). t2's class is exact for λ > 0 over its families as restricted: the true parity in F5 and F3, greedy rule cells, and F3's $j$ restricted above 64 to powers of two and $n_{\rm err}$ (whose rate is below every relevant λ). rB3(E) checks, at $d=8$, $m=4$, that the restricted and the exhaustive class have the same MAP path for λ > 0. At λ = 0 the restricted class omits tied zero-fit duplicates.

**Remark 3.4 (the objects side by side) [remark, from Props 2.3, 2.4, 3.1–3.3, 3.7 and the sibling results cited; every entry in total bits].**

| | noise, PQ | noise, FR (Paper 2) | noise, FQ | idiosyncratic errors, $m=d$, full table | junta errors, $m<d$ |
|---|---|---|---|---|---|
| reuse factor | 1 | 1 | input multiplicity $N_n(x)\approx n\mu(x)$ | 1 | $2^{d-m}$ on the full table; on samples the cell's distinct (FR) or query (FQ) multiplicity, about $n2^{-m}$ |
| right line $(\tau,g)$ | $(1,\ \ell_0+\delta^*)$ at every $n$ (iid Lemma 2.2) | $(1,\ k+\delta^*)$ at every $n$ (Prop 3.7(a)) | $(\bar n,\ \bar nb)$ for equal multiplicities $\bar n$, with $b$ the full-table offset (Lemma 3.0) | $(1,\ b_0)$ (Prop 2.4) | $(2^{d-m},\ 2^{d-m}\Lambda_2)$ on the full table (Prop 3.1); $(\bar n,\ \bar n(\beta+c_1+\kappa_g))$ on samples with equal multiplicities (Prop 3.3(b)) |
| right secant at the model | can exceed 1 by up to $(\ell_0+\delta^*)/x$; in a parity class the excess is exactly $k-7$ bits (iid Lemma 8.1(iv)) | as PQ | $\bar n$ times the full-table secant | at least θ ≈ 1 (memoriser) | at least $2^{d-m}\theta_m$ (full table); at least about $\max\{1,n2^{-m}\theta_m\}$ (samples) |
| left steepness | $\ge(2\log e\cdot n\gamma_--2\log(1/\varepsilon))/\ell_0$ with probability ≥ 1 − ε at fixed $n$, when this is ≥ 2 (iid Lemma 8.1(iii)) | the same on a uniform finite support, counted in distinct inputs, with probability ≥ 1 − 2ε (kink Thm 5.4(i), scheme (wor); iid Remark 7.7) | $\bar n$ times the full-table steepness | $\ge\sigma^{(t_0)}=\inf_{t\ge t_0}N(\Psi^\circ_t-H(p))/(\kappa_g+\min\{d,s(t+1)+\Lambda_1\})$ (kink Prop 4.1) | $Nc_{\rm hi}$ on the full table (Prop 2.1(a) times $N$); $nc_{\rm hi}$ on samples only through `cor:teacher:sampled` |
| schedules that select the model | every $1\le\lambda_n=o(n)$, λ = 1 included (iid Thm 3.1); fixed λ > 1 for uniform bounds; λ = cn iff $c<c^*$ (iid Prop 3.4) | fixed λ > 1: length within $(k+\delta^*)/(\lambda-1)$ at every $n$; on the run every λ ≥ 1 (iid Prop 3.3); no procedure recovers every sampler (iid Prop 7.5) | $\lambda_n/\bar n$ inside the full-table window, so λ ∝ n/N; no fixed λ | λ ∈ (1, $Nc_{\rm hi}$) | $\lambda_n/n$ eventually in a compact subset of $(2^{-m},c_{\rm hi})$ (Prop 3.6); no $\lambda_n=o(n)$; on a finite domain in FR, any fixed λ in $(2^{d-m},Nc_{\rm hi})$ in the limit |

* Every offset is in total bits (B-m9; `notes.md` gave the junta offset per sample, $\Lambda_2/2^m$).
* kink Thm 5.4 is quoted with its $-2\log(1/\varepsilon)$ and its probability (A m9), and only for the scheme (wor): its scheme (iid) assumes a non-atomic input law, which does not exist on Paper 2's countable $X$ (kink referee A, issue 1).

**Remark 3.5 (what λ > 1 buys in each case) [remark].**
* *Noise (PQ, FR).* The right line has slope 1, so Lemma 1.1 needs λ > 1 for a length bound uniform in $n$. At λ = 1 the reference point is on the line itself: `thm:split:lambda1`, `cor:teacher:fulltable`(ii) and kink Remark 5.9. Asymptotically λ = 1 still selects the model in PQ (iid Thm 3.1, by the Kraft tail) and on the run in PQ and FR (iid Prop 3.3).
* *Errors, and noise in FQ.* The line's slope is the reuse factor, so Lemma 1.1 needs λ above it: λ > $n2^{-m}$ per query, or above the distinct multiplicity of the cells in FR. No fixed λ does this as $n$ grows, except on a finite domain in FR, where the distinct multiplicity saturates at $2^{d-m}$.

---

## 4. Structured errors make a second kink

The product structure function in population form is $\rho_{\rm pop}(\alpha):=\inf\{R(\pi):\ell(\pi)\le\alpha\}$.
* *An incompressible rule* gives one kink, at $\alpha\approx d$. Its left steepness is at least $c_{\rm hi}$. After it, ρ descends at slope about $2^{-m}$ until the memoriser at $\alpha\approx d+L_S$.
* *A rule with a cheap, dense part* $S_1$, $K(S_1\mid m)\le k_1$, adds a second drop at $\alpha\approx d+k_1$. The drop has height about $H(p)-R_e$, over $k_1+O(\log)$ bits. That is the envelope's kink.

**Proposition 4.1 (the envelope raises the lower end of the window) [proved].** In the setting of `prop:limits:envelope` ($B=\infty$). For ε ≥ 0 let
$$W_\epsilon:=\{c>0:\ \text{some program with }R(\pi)\ge H(p)\text{ has }J_c(\pi)\le\Phi(c)+\epsilon\}$$
be the set of slopes at which a program fitting no better than noise is ε-near-optimal (A m13: `notes.md` used "window" without defining it).
* (a) *The envelope's secant.* Let $P=(\ell,R)$ be the point of any level-1 program with $R\ge H(p)$; the good model is one. Then the envelope either dominates $P$, or its secant from $P$ is at least
  $$c_{\rm env}=\frac{H(p)-R_e}{k_1+\kappa_e+4+\Lambda_1}.$$
  So the right secant at every such point is at least $c_{\rm env}$. Against the reference value $J_g(c)$ itself the threshold is $s_e:=(H(p)-R_e)/(k_1+\kappa_e-\kappa_g)$, when $k_1+\kappa_e>\kappa_g$: for $c<s_e$, $J_c(\pi_e)<J_g(c)$.
* (b) *The all-hypothesis form.* `prop:limits:envelope`(i) is Lemma 1.1(iv) with the envelope's point as reference. Hence $c\notin W_\epsilon$ whenever $c<c_{\rm env}$, $J_e(c)+\epsilon<\Phi_2(c)$ and $\zeta(c)<H(p)-R_e$. For an incompressible rule `thm:teacher:main` puts the lower end of the identification window at $2^{-m}$.
  * This does not contradict `thm:teacher:main` applied to the structured rule. It applies with the rule's own $\delta_S$ (about 1,300 bits for the $j=13$ rule of `limits.tex`), and then (ii)(b) allows $R_B$ well below $H(p)$: at $c=1.01\cdot2^{-20}$ its slack $c\Lambda_2/(c2^m-1)$ is about 0.13, against $H(p)=0.011$.
* (c) *Where the near-optimal programs sit.* Near the lower end, `prop:limits:envelope`(ii) puts them at the envelope's kink: they reproduce the cheap errors.

*Proof.*
* *(a).* The envelope has length at most $d+k_1+\kappa_e$, and $\ell\ge d-4-\Lambda_1$ by (D1). If the envelope is not longer than $P$, it dominates $P$, because $R_e<H(p)\le R$. Otherwise its secant from $P$ is $(R-R_e)/(\ell(\pi_e)-\ell)\ge(H(p)-R_e)/(k_1+\kappa_e+4+\Lambda_1)$. The second claim compares $J_c$ at the two upper-bound points.
* *(b).* Prop 2.1(d), and the cited proposition (i).
* *(c).* The cited proposition (ii). ∎

**Proposition 4.2 (rate blindness is an empty kink interval) [proved].** Take a level-1 point $P=(\ell,R)$ with $R\ge H(p)$, so $\ell\ge d-4-\Lambda_1$.
* *The memoriser's secant from P* is at least $s_b:=H(p)/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$. This is a lower bound on the right secant at $P$; it is `thm:teacher:main`(iv) read as a secant (Lemma 1.5(c)).
* *The coin's secant to P* is at most $s_c:=(1-H(p))/(d-4-\Lambda_1-\kappa)$. This is an upper bound on the left steepness at $P$.

`prop:limits:rateblind`'s condition (⋆) is $s_b\ge s_c$. Under it every such $P$ has an empty λ-interval: the error kink is at least as steep as the model kink.

*Proof.*
* If $\ell(\pi_b)\le\ell$, the memoriser dominates $P$. Otherwise $R/(\ell(\pi_b)-\ell)\ge s_b$, because $\ell(\pi_b)-\ell\le\lceil L_S\rceil+\kappa_b+4+\Lambda_1$.
* If $R\ge1$, the coin dominates $P$. Otherwise $(1-R)/(\ell-\ell_{\rm coin})\le s_c$, using $\ell_{\rm coin}\le\kappa$ and the side condition $d-4-\Lambda_1-\kappa>0$.
* For $c<s_b$ the memoriser beats $P$; for $c\ge s_c$ the coin beats or ties it. When $s_b\ge s_c$ these two ranges cover all $c>0$.

This is the proof of `prop:limits:rateblind`(ii), read as a statement about secants. ∎

[computed: t3(A); full table, $d=12$, $m=8$, $p=1/16$ (16 error cells); $S=S_1\cup S_2$ with $S_1$ a cheap subcube and $S_2$ random cells outside the 16-cell zero subcube; the class adds envelopes F6 and envelope-plus-named-cells F7 to t2's class; total bits; reuse factor $2^{d-m}=16$. In every row the lower vertex of the true-parity family is its rate-$p$ member, so the lower ends below are those of $\pi_g$'s point; the family's λ-set extends above 126.2 through its rate-1/8 member.]

| $\lvert S_1\rvert$ | λ-set of the family (rate-p lower end) | envelope vertices (λ-intervals) | ρ at α = 24 / 30 / 40 / 80 |
|---|---|---|---|
| 0 | (15.0, 161.8) | none | 1382 / 1382 / 1295 / 975 |
| 2 | (17.1, 161.8) | none (the rule memoriser via F7 below 17.1) | 1382 / 1382 / 1251 / 822 |
| 4 | (42.7, 161.8) | (17.3, 42.7) | 1382 / 1126 / 1069 / 657 |
| 8 | (85.3, 161.8) | (53.7, 85.3), (17.7, 53.7) | 1382 / 870 / 816 / 0 |
| 16 | empty | the whole rule is one cheap subcube, a vertex for λ < 273 | 0 / 0 / 0 / 0 |

* The second drop of ρ at α = 30 (for $\lvert S_1\rvert=4,8$) is the envelope's kink.
* As the cheap part grows, its kink steepens. The good model's interval shrinks from below, from the reuse factor 16 up to 85, and disappears when the cheap part is the whole rule.
* At $\lvert S_1\rvert=16$ the envelope is shorter than the good model: beyond the parity it costs 7 bits ($g(j')=5$ and two deterministic flags), against 9 for the rate 1/16 [computed: t5(E)]. `notes.md` said "2 against 9" (A m12).
* *A second class* [computed: rB3(C)]. In class K the cheap parts of 0, 2, 4, 8 and 16 cells move the lower end to 14.86, 14.86, 42.67, 79.78 and empty. K has no "envelope + named cells" family, so the 2-cell case does not move.

[computed: t3(B); a fixed rule of 4 random cells at $m=5$ ($p=1/8$), as the model length $d$ grows; the λ-set of the true-parity family.]

| $d$ | 6 | 8 | 10 | 11 | 12 | 13–16 |
|---|---|---|---|---|---|---|
| family's λ-set | (1.78, 3.54) | (7.13, 11.0) | (28.5, 36.0) | (57.1, 66.0) | (114.2, 121.9) | empty |

* The ratio of the ends falls from 2.0 to 1.07, and the set is empty from $d=13$ on. This is rate blindness in the explicit class: the model's rate falls like $1/d$, the rule's rate stays fixed. In class K it is empty from $d=12$ on [rB3(D)].
* The three-hypothesis criterion of `prop:limits:rateblind`(i) flips at $d=12$, one step before the exact hull. At $d=12$ the exact class still has a short interval, because its vertices next to the good model are not the coin and the rule memoriser.

**Remark 4.3 (rate, not validity, in hull form) [remark, from cited results].**
* *Rate is all the selection sees.* Steeper selection keeps exactly the hull segments whose rate exceeds $c$ (kink §6; `prop:limits:separable`). An incompressible error rule has rate at most about $2^{-m}$ per sample, the reuse factor per sample. A structured rule has the rate of its cheapest dense part, which can lie anywhere, up to and beyond the model's rate.
* *No geometric test separates the kinks.* Nothing in the geometry tells the model's kink from an error kink. `prop:limits:noident` (twin worlds) is the statement that the hull, and hence every rule that chooses λ from it, is the same in a world where the second kink is an error and one where it is a rare valid rule.
* *Guard erosion* (`prop:limits:guard`) is the same configuration with the roles changed. The rule and the guard are two components, and the unguarded rule is a vertex exactly when the rule's segment is steeper than the guard's.

---

## 5. A new consequence: the junta window for every p < 0.1233

**The obstacle.** `thm:teacher:main` needs $G_1>H(p)$, that is $p<0.056$. The kink sub-track (kink Prop 4.2, Cor 4.3) extends the full-table case $m=d$ to level 1 for $p<0.1233$ and to level ≤ 2 for $p<1/4$. It bounds every competitor's information budget through the sufficiency line (a right line of slope 1), which keeps the deviation term of `lem:teacher:sharpfloor` small.

For $m<d$ that bound is missing (kink §4, last paragraph; `rem:limits:method`). Near $c=2^{-m}$ a program that does not know the parity has its length bounded only by $J_c\le J_g$. That allows $I(\pi)\approx L_S$, and then the deviation term is of order $\sqrt{H(p)/p}$.

**The fix.** Charge the information in the objective. A program that does not know the parity still pays for its information about the rule, one bit of length per bit. In the window, $c>2^{-m}$, a bit of length costs more risk than the sharp floor lets a bit of rule information gain.

**Lemma 5.1 (the information charge) [proved].** In `def:teacher:instance` (or its generalisation to any $s_0=p2^m$, with $\kappa_g:=2\log d+K(p)+\kappa$; Prop 5.3), let $d\ge2\log(d+1)+\kappa+1$. Every program π of level $t\in\{2,3,\dots\}\cup\{\infty\}$ satisfies
$$\ell(\pi)\ \ge\ d-\min\{s(t)+2\log d,\ d\}+I(\pi)-\kappa,\qquad I(\pi)\ \ge\ -2\log(2d)-\kappa,$$
with $s(\infty):=\infty$. $I(\pi)=B_S-K(S\mid a,\pi)$ is an integer. In Prop 5.2 below, $G_{\infty-1}:=G_\infty$.

*Proof.*
* *The first inequality.* By (F3), $B_S\le K(\pi\mid a,K(a))+K(S\mid a,\pi)+\kappa$, so $I(\pi)\le K(\pi\mid a,K(a))+\kappa$ (as in the proof of `lem:teacher:sharpfloor`). By (F4) and (F3), $K(\pi\mid a,K(a))\le K(\pi)+K(a\mid\pi)-K(a)+\kappa$. Insert:
  * $K(\pi)\le\ell(\pi)+\kappa$ (F1);
  * $K(a\mid\pi)\le\min\{s(t)+2\log d,\ K(a)\}+\kappa$ (`lem:teacher:list`, or trivially);
  * $\min\{s,K(a)\}-K(a)=\min\{s-K(a),0\}\le\min\{s,d\}-d$, since $K(a)\ge d$.

  This is the step of `thm:teacher:main`(ii)(d), read backwards.
* *The second inequality.* $K(S\mid a,\pi)\le K(S\mid a)+\kappa\le B_S+K(K(a))+\kappa$, by (F3). Then $K(K(a))\le2\log(K(a)+1)+\kappa$ (F5), and $K(a)\le d+2\log(d+1)+\kappa\le2d-1$.
* *Integrality.* $B_S$ and $K(S\mid a,\pi)$ are prefix complexities. ∎

**Proposition 5.2 (a sharper bound for programs that do not know the parity) [proved; computed: t4(B), t6(B), rB7(B)].**

*Definitions.* For $t\ge2$ put $\theta_{t-1}:=\frac12+2^{-t}$, and $\theta_\infty:=\frac12$. Put
$$\mathrm{Floor}_t(I):=\max\Big\{0,\ \sup_{g\ge1}\,-\log\Big(p+(1-2p)\theta_{t-1}+p\big(2\gamma_g(I)+2^{1-g}\big)+2^{-B}\Big)\Big\},$$
with $\gamma_g(I)$ as in `lem:teacher:sharpfloor`, evaluated with budget $I$, and
$$\Psi_t(c):=\min_{I\in\{0,1,2,\dots\}}\big[cI+\mathrm{Floor}_t(I)\big].$$
`notes.md` took the infimum over real $I\ge0$, which is valid but smaller; t4 bounded it on a geometric grid of $I$ (B-m1).

*Claim.* Every program of level $t\ge2$ (or ∞) satisfies, for every $c>0$,
$$J^B_c(\pi)\ \ge\ LB_t(c):=\max\Big\{c\,(d-s(t)-\Lambda_1)^++G_{t-1},\ \ c\,\big(d-\min\{s(t)+2\log d,d\}-2\log(2d)-\kappa\big)+\Psi_t(c)\Big\}.$$
Consequently `thm:teacher:main`(i) and (ii), with all their conclusions (a)–(e) and the sharper (a1), (a2) of Remark 2.6, hold with $\Phi_2$ replaced by
$$\Phi_2^\sharp(c):=\inf_{t\ge2}LB_t(c)\ \ge\ \Phi_2(c),$$
on the set $\{c>2^{-m}:J_g(c)+\epsilon<\Phi_2^\sharp(c)\}$. This set is called **the window** below. $\Phi_2^\sharp$ is an infimum of maxima of concave functions and need not be concave, so the window need not be an interval (A m14). In every case computed at $d=100$, $m=20$ it is one [t6(B), rB7(B)].

*Proof.*
* *The first term* is the paper's bound in (o) before the reduction $s(t)\le4t$: (D1) and `lem:teacher:floor`. So $\Phi_2^\sharp\ge\Phi_2$.
* *The second term.*
  * By Lemma 5.1, $c\ell(\pi)\ge c(d-\min\{\cdot\}-\kappa)+cI^+-c(2\log(2d)+\kappa)$, with $I=I(\pi)$: if $I\ge0$, $cI=cI^+$; if $I<0$, $cI\ge-c(2\log(2d)+\kappa)$ and $I^+=0$.
  * By `lem:teacher:sharpfloor` with $u\le\theta_{t-1}$ (and $1-2p>0$), $R_B(\pi)\ge\mathrm{Floor}_t(I)$.
  * $\gamma_g$ is nondecreasing in the budget, so $\mathrm{Floor}_t(I)\ge\mathrm{Floor}_t(I^+)$.
  * $I^+$ is a nonnegative integer. Add the two bounds and take the minimum over such integers.
* *The consequence.* The proofs of (i) and (ii) use (o) only through "every program of level ≥ 2 has $J^B_c\ge\Phi_2(c)$" (checked against every use in `app-teacher.tex`, and by referee A). In Lemma 1.1 this is $m_N(c)\ge\Phi_2^\sharp(c)-J_g(c)$. Remark 2.6 uses only level 1, (D1) and the sharp floor. ∎

The bound is valid at every $c$. It is useful when $c\ge2^{-m}$: then $cI\ge2^{-m}I=p\,(I/s_0)$, a linear charge per error cell's worth of information, while the deviation term grows only like $\sqrt{I/s_0}$.

**Proposition 5.3 (asymptotically, a window for every p < 0.12331) [proved, given the computed constants $p^*$ and $a^*(p)$; computed: t4(A), rB7(A), t6(A)].**

*Definitions.*
$$\psi_2(p,a):=\inf_{x\ge0}\Big[apx-\log\big(\tfrac34-\tfrac p2+2p\sqrt{x\ln2/2}\big)\Big],\qquad a^*(p):=\inf\{a\ge1:\psi_2(p,a)>H(p)\}.$$

*The generalised instance.* `def:teacher:instance` with any rule size $s_0=p2^m$, $p$ not necessarily a power of 2, and $\kappa_g:=2\log d+K(p)+\kappa$; for $p=h/2^e$, $K(p)\le2\log(h+1)+2\log(e+1)+\kappa$. No other step of `thm:teacher:main` or of its four lemmas uses $p=2^{-r}$ [proved: checked step by step here and by referee A (M5)]:
* list decoding does not involve $p$;
* the risk floor uses only $\Pr[E]=p$;
* the coding lemma and (D1)–(D2) do not involve $p$;
* the bounds $2^mH(p)-\log(2^m+1)\le L_S\le2^mH(p)$ and $\delta_S\ge-2\log m-2\log s_0-\kappa$ hold for every $s_0$;
* $\kappa_b$ already pays $2\log s_0$;
* `lem:teacher:sharpfloor` states that it holds for every $s_0$.

*Claim.* Fix a dyadic $p\in(0,1/4)$, κ, $B=\infty$, and $a>a^*(p)$ (strictly). Let $m\to\infty$ with $d\ge m$, $d2^{-m}\to0$ and $\delta_S=o(2^m)$. Let $c_m\ge a2^{-m}$ be any sequence with $c_md\to0$; for example $c_m=2^{-m/2}$ when $d=o(2^{m/2})$. Then there is $\epsilon>0$ such that, for all large $m$,
$$J_g(c)+\epsilon<\Phi_2^\sharp(c)\qquad\text{for every }c\in[a2^{-m},c_m] .$$
So the identification of `thm:teacher:main`(ii) holds on that range of $c$, which reaches far above $2^{-m}$.

`notes.md` stated the claim for $c\in[a2^{-m},A2^{-m}]$ with $A$ fixed, and its summary for "$c\ge a^*(p)2^{-m}$" with no upper end and $a=a^*$ allowed. The proof gives exactly the range above (A M5).

*Facts about the constants* [computed: t4(A), rB7(A); convexity proved].
* With $y=\sqrt x$, the function minimised in $\psi_2$ is $apy^2-\log(A+ky)$, with $A=\frac34-\frac p2$ and $k=2p\sqrt{\ln2/2}$. It is convex in $y$: $apy^2$ is convex, and $-\log$ of a positive affine function is convex (A m15, B-m11; `notes.md` said "checked on a grid"). Its minimiser solves $2ap\ln2\cdot y(A+ky)=k$.
* As $a\to\infty$, $\psi_2(p,a)$ increases to $1-\log(3/2-p)$. So $a^*(p)<\infty$ iff $1-\log(3/2-p)>H(p)$, that is, iff $p<0.12331$.
* $a^*(p)=1$ iff $p<p^*=0.07787$.
* Each of the crossings $G_1=H$ (0.05596), $\psi_2(p,1)=H$ (0.07787) and $1-\log(3/2-p)=H$ (0.12331) is the only sign change on a 4,999-point grid of $(0,1/4)$ [rB7(A)].
* Tabulated values: $a^*=1.011$ at 5/64, 2.128 at 3/32, 3.034 at 0.1, 5.999 at 7/64, 15.585 at 15/128 and 30.20 at 0.12.

*Proof.*
* *The charge per sample.* Write $I=xs_0$. Then $cI=apx$ for $c=a2^{-m}$, because $s_0=p2^m$.
* *The deviation term converges.*
  * Let $r_g:=\delta_S+1+2\log m+2\log s_0+g+2\log g+\kappa$. In `lem:teacher:sharpfloor`, $j$ is the least integer with $j-2\log(j+1)>I+r_g$. So $I\le j\le I+r_g+O(\log(I+r_g))$.
  * Choose $g=g_m\to\infty$ with $g_m=o(s_0)$. Then $r_g=o(s_0)$, using $\delta_S=o(2^m)$ and $s_0=p2^m$.
  * Hence $\gamma_g(xs_0)^2=x\ln2/2+o(1)$, uniformly for $x$ in compact sets, and $p2^{1-g_m}\to0$.
* *The infimum converges.* By uniform continuity of $-\log$ on $[\frac34-\frac p2,\infty)$ and of $\sqrt\cdot$, $\mathrm{Floor}_2(xs_0)\ge f(x)-o(1)$ uniformly on $[0,X]$, where $f(x):=-\log(\frac34-\frac p2+2p\sqrt{x\ln2/2})$. For $x>X$ with $apX>\psi_2(p,a)+1$, the bound $cI+\mathrm{Floor}\ge apX$ suffices, since Floor ≥ 0. So $\liminf_m\Psi_2(a2^{-m})\ge\psi_2(p,a)$; restricting $I$ to integers only raises $\Psi_2$.
* *All levels at once.* $\Psi_t\ge\Psi_2$ for every $t\ge2$, because $\theta_{t-1}\le\theta_1$. The coefficient of $c$ in the second term of $LB_t$ is at least $-2\log(2d)-\kappa$. So, uniformly in $t$,
  $$J_g(c)-LB_t(c)\le c\,(d+\kappa_g+2\log(2d)+\kappa)+H(p)-\Psi_2(c).$$
* *Conclusion.* For $c\in[a2^{-m},c_m]$ the first term is at most $c_m(d+\kappa_g+2\log(2d)+\kappa)\to0$, since $\kappa_g=O(\log d)$. Also $\Psi_2(c)\ge\Psi_2(a2^{-m})$, because $cI+\mathrm{Floor}$ is nondecreasing in $c$ for $I\ge0$. Pick $a'\in(a^*,a)$; then $\psi_2(p,a)\ge\psi_2(p,a')>H(p)$, because $\psi_2$ is nondecreasing in $a$. Take $\epsilon:=\frac12(\psi_2(p,a)-H(p))$. ∎

[computed: t6(A), identical to rB7(C); $d=m$, κ = 0, $\delta_S=0$. Convergence with exact integer $I$ (B-m1).]

| $(p,a)$ | $\Psi_2(a2^{-m})$ at $m=12$, 16, 20, 22 | $\psi_2(p,a)$ | t4(C) (I-grid) at $m=20$, 40 |
|---|---|---|---|
| (1/16, 1) | 0.3837, 0.3968, 0.3979, 0.3980 | 0.3980 | 0.3965, 0.3966 |
| (1/16, 4) | 0.4117, 0.4510, 0.4549, 0.4552 | 0.4552 | 0.4545, 0.4548 |
| (1/16, 16) | 0.4117, 0.4581, 0.4698, 0.4707 | 0.4710 | 0.4697, 0.4709 |
| (3/32, 1) | 0.3764, 0.3901, 0.3913, 0.3913 | 0.3914 | 0.3892, 0.3893 |
| (7/64, 1) | 0.3732, 0.3871, 0.3883, 0.3884 | 0.3884 | 0.3860, 0.3861 |

* **[refuted]** `notes.md`'s reading of t4(C), "the finite-size bound converges from below to $\psi_2$", quoted a plateau 0.3966 against 0.3980. That plateau is the loss of the I-grid (ratio 1.02 per cell, about 1% of the deviation term $2p\gamma\approx0.07$). With integer $I$ the bound does reach $\psi_2$. Prop 5.3 is unaffected: it rests on the limit argument, not on t4(C).

[computed: t6(B),(C), identical to rB7(B) and rB8 where they overlap; certified windows from t4(B); $d=100$, $m=20$, $B=\infty$. κ = 0 rows are illustrations. Lower ends are in units of $2^{-20}$.]

| $p$ | $G_1-H(p)$ | paper's window | exact window, κ = 0 | certified (t4), κ = 0 | exact window, κ = 30 | at $c$ (κ = 0, $\delta_S=0$): $u\ge$ (a2), $\ell\le$, $I\le$, $e\le$ |
|---|---|---|---|---|---|---|
| $2^{-10}$ | +0.402 | $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ | $[1,\ 8.198\cdot10^{-3}]$ | $(1,\ 7.88\cdot10^{-3}]$ | $[1,\ 3.687\cdot10^{-3}]$ | $1.23\cdot10^{-4}$: 0.989, $d+20.3$, 37.6 of 11,710, 0.193 |
| 1/16 | −0.038 | none | $[1,\ 2.529\cdot10^{-3}]$ | $(1,\ 2.39\cdot10^{-3}]$ | $[1,\ 6.56\cdot10^{-4}]$ | $6.7\cdot10^{-5}$: 0.828, $d+18.0$, 35.3 of 353,665, 0.1965 |
| 5/64 | −0.124 | none | $[1.013,\ 1.521\cdot10^{-3}]$ | $[1.056,\ 1.46\cdot10^{-3}]$ | $[1.015,\ 4.29\cdot10^{-4}]$ | $5.3\cdot10^{-5}$: 0.803, $d+25.2$, 42.5 of 414,742, 0.220 |
| 3/32 | −0.204 | none | $[2.140,\ 9.10\cdot10^{-4}]$ | $[2.20,\ 8.7\cdot10^{-4}]$ | $[2.155,\ 2.49\cdot10^{-4}]$ | $4.3\cdot10^{-5}$: 0.780, $d+23.8$, 41.1 of 470,659, 0.240 |
| 7/64 | −0.279 | none | $[6.22,\ 3.18\cdot10^{-4}]$ | $[6.52,\ 3.0\cdot10^{-4}]$ | $[6.53,\ 8.56\cdot10^{-5}]$ | $4.3\cdot10^{-5}$: 0.760, $d+26.3$, 43.5 of 522,210, 0.260 |
| 15/128 | −0.316 | none | $[21.4,\ 6.23\cdot10^{-5}]$ | $[22.7,\ 5.9\cdot10^{-5}]$ | none | $3.6\cdot10^{-5}$: 0.750, $d+29.0$, 46.3 of 546,531, 0.269 |
| 1/8 | −0.351 | none | none | none | none | — |

* *Exact against certified* (A m10, B-m10). Every certified window lies inside the exact one. The certified ends are conservative by 1–6%, from the c-cells (a factor 1.0275 per cell) and the I-grid. At $p=2^{-10}$ the exact upper end $8.198\cdot10^{-3}$ exceeds the paper's $c_{\rm hi}=8.062\cdot10^{-3}$, as $\Phi_2^\sharp\ge\Phi_2$ requires; the certified $7.88\cdot10^{-3}$ fell below it only because of the grid. The exact end equals t1(B)'s exact steepness of the level regions.
* *The lower ends.* A window that starts at $2^{-20}$ is open there: the identification needs $c2^m>1$. The finite-size lower ends 1, 1, 1.013, 2.14, 6.22 and 21.4 compare with the asymptotic $a^*$ = 1, 1, 1.011, 2.13, 6.00 and 15.6.
* *Deficiency* (A m10). With $\delta_S=20$ the upper ends fall by the factors 0.995 (1/16), 0.992 (5/64), 0.985 (3/32), 0.955 (7/64) and 0.772 (15/128); the lower ends rise by at most 0.5%, except at 15/128 (factor 1.097) [computed: t6(B)]. **[refuted]** `notes.md`: "$\delta_S=20$ changes the windows by at most a few percent". It is false at $p=15/128$ (23% and 10%; 24% and 11% for the certified ends, rA1(C)).
* *The error label.* With (a2), every near-optimal hypothesis gives the erroneous labels average probability $e\le0.19$–$0.27$ (κ = 0, $\delta_S=0$), against 1 for the memoriser and $p$ for the good model, for every flip rate up to 15/128. With the paper's (a) the bound is 0.27–0.28 (B-m2).
* *The identification column* is `thm:teacher:main`(ii) at the $c$ that t4(B) used, with ε = 0 and $g$ optimised. $u$ is from (a2); the paper's (a) and (a1) give only $u\ge0.75$ in the rows with $p\ge1/16$ (Remark 2.6).

**Reading.**
* *One mechanism in both cases.* In the full-table case (kink Prop 4.2) and in the junta case (here), the right side controls the information budget of *every* competitor, including those that do not know the model. That is what makes the sharp floor usable.
  * With a right line of slope 1 (sufficiency), every competitor's length is capped.
  * With the line of slope $2^{-m}$ per sample, the information charge makes rule information unprofitable at $c>a^*2^{-m}$, whether or not the program knows the parity.
* *Resulting ranges.* Level 1 is now obtained for $p<0.1233$ in both cases.
* *What remains open.*
  * Level 1 for $0.1233\le p<1/4$: with these floors it is impossible.
  * Level ≤ 2 for $p<1/4$ in the junta case. The level-3 analogue of ψ has the $a\to\infty$ limit $-\log(\frac58-\frac p4)$, which exceeds $H(p)$ up to $p=1/4$ (0.830 > 0.811). Turning this into identification needs (D2) at level 2 [conjecture: routine].
  * Finite samples at realistic sizes. `cor:teacher:sampled` applies unchanged, with $\Phi_2^\sharp$ and its slowness.

This answers:
* the junta half of kink open question 3:
  * the kink theorem for $m<d$ in population form is Prop 2.1 (τ = $2^{-m}$ per sample);
  * on samples it is proved only for equal cell multiplicities (Prop 3.3(b)); the general case is open (A M2);
  * the window for $p\ge0.056$ is Props 5.2–5.3;
* `q:teacher:open`(b) for $p<0.1233$;
* `q:limits:open`(b): a window for $p<0.123$ with $c$ well above $2^{-m}$ exists, asymptotically up to every $c_m=o(1/d)$ (Prop 5.3) and at the example's sizes up to $10^{-4}$–$10^{-3}$; for $p<0.078$ it reaches down to $2^{-m}$.

The answers are for the population objective. They do not contradict `rem:limits:method`, which concerns "the argument as it stands".

---

## 6. How to present the teacher result as the second thread

### 6.1 Proposed structure

The first thread establishes, in order:
1. the hull characterisation of λ-MAPs (kink Thms 2.1–2.2; `lem:setup:hull`);
2. Lemma 1.1 as the kink lemma, with Def 1.4 (right line, right secant);
3. the split theorems as its τ = 1 instances (Prop 2.3; iid; kink §5).

The second thread then reads as **"the split at a positive rate"**:

1. **From noise to errors** (half a page).
   * Errors are a fixed function of the input, so each bit of the error rule is reused at every input of its cell. The reuse factor (§3.0, Lemma 3.0) is what separates them from noise, which Paper 2's likelihood uses once per distinct input.
   * Every schedule with $\lambda_n=o(n)$ ends at the least-risk programs and learns the errors (`prop:limits:plain`, kept; Prop 3.2(c)).
   * The proposal is λ = cn: in the limit it selects the minimisers of $c\ell+R$ (Prop 3.2(d)), and every schedule whose ratio $\lambda_n/n$ stays in a compact subset of the window works as well (Prop 3.6).
   * The three-hypothesis calculation is the picture of that hull, with rates 100 and 10, or $8.99\cdot10^{-3}$ and $1.12\cdot10^{-6}$ (`rem:teacher:hanni`, shortened).
2. **The instance** (`def:teacher:instance`, generalised to $s_0=p2^m$ if §5 is included).
3. **Two kink bounds** (one proposition, the content of (o) and (D1)–(D2)).
   * *Left:* every program that does not know the parity at level 1 lies above the wedge with apex $(d+\kappa_g,H(p))$, steepness $c_{\rm hi}$ and margin $G_1-H(p)$; with §5, above $\Phi_2^\sharp$.
   * *Right:* every program that knows it lies above the right line of slope $-2^{-m}$ through $(d-4-\Lambda_1,B_S/2^m)$.
   * Table 2.2 replaces `rem:teacher:hypotheses`. List decoding, the risk floor, the coding lemma and the two-part bounds move to the appendix as the proof of these two bounds.
4. **The theorem.**
   * (i), (ii)(b) and (ii)(c) are one application of Lemma 1.1 with τ = $2^{-m}$, $g=\Lambda_2/2^m$.
   * (ii)(a), (d) and (e) are stated as "what the position means", with (a1) of Remark 2.6 added to (a).
   * (iii) and (iv), the side below the line's slope and the memoriser's secant, are kept.
   * The statement is about the near-optimal set $\mathcal N_\epsilon(c)$ only. The paper should not say that the good model is "the" selected program or a vertex on the whole window (A M1). The sentence of `setup.tex` "so for the example of Section 5 the question is whether the good model is a vertex" should become "whether every near-optimal hypothesis knows the model and not the errors".
   * The table of numbers is kept.
5. **The lower end is the reuse factor** (Prop 3.1, Lemma 3.0 and Remark 3.4).
   * The full-table corollary is stated for every $m$, with window $\lambda\in(2^{d-m},Nc_{\rm hi})$. Its case $m=d$ is the split's τ = 1 (Prop 2.4).
   * One paragraph on sampled data: the proved lower bound of Prop 3.3(a), the line under equal multiplicities, and the conjecture with its table.
   * `cor:teacher:sampled` and `prop:teacher:concentration` stay in the appendix.
6. **Flip rates up to 0.1233** (§5, if adopted): Prop 5.2 in the main text, Prop 5.3 with the exact-window table. This removes hypothesis (4) as it now stands.
7. **When errors are structured: a second kink.** The limits section is reorganised around kinks:
   * envelopes (Prop 4.1);
   * rate blindness (Prop 4.2);
   * rate, not validity (`prop:limits:separable`, guard erosion, input law, non-identifiability), as one remark on what a hull cannot see;
   * the t3 table as the illustration.

**Which likelihood (for `def:setup:data`).** If the first thread uses the per-query object (iid's recommendation), `def:setup:data` must say which likelihood applies when inputs repeat. The two frozen readings give different answers for noise (Prop 3.7): Paper 2's data-set likelihood (FR) keeps reuse factor 1, while counting every query (FQ) makes frozen noise behave like errors. The teacher thread is unaffected: its samples are drawn without replacement, and its population risk is the common limit.

### 6.2 What the split machinery lets the paper cut or merge

1. **`thm:teacher:main`, its proof idea and `app-teacher.tex`'s proof of (o)–(ii)(c)** [about half a page].
   * $\psi_c$, the case analysis in (ii)(b) and the derivations of $\Phi_1$, $\Delta(c)$ and $\Delta_\ell$ become one line of Lemma 1.1 (Prop 2.1(c)).
   * The notation table loses $\psi_c$ and $\Phi_1$.
   * What remains of (o) is the level argument for $\Phi_2$, which is the left kink bound.
2. **`rem:teacher:hypotheses`** becomes Table 2.2: which hypothesis serves which side of the kink.
3. **`cor:teacher:fulltable`.** Part (i) becomes the $m=d$ case of the every-$m$ full-table statement (Prop 3.1), one line. Part (ii), the tie at λ = 1, merges with the λ = 1 discussion of the split (`thm:split:lambda1`): both reference points sit on a line of slope 1 (Prop 2.4(iii)).
4. **`prop:algstat:parity`(ii), (iv) and their proofs in `app-algstat.tex`.**
   * The product kink at α ≈ d is the left kink bound of item 3 of §6.1 at $m=d$. The full-table noisy parity of the algorithmic-statistics section and the teacher's $m=d$ case are the same instance.
   * State the kink once and cite it from both places (about a third of a page).
   * The kink sub-track's Props 4.1–4.2 supersede the λ-range part.
5. **`rem:limits:schedule` and the paragraph "The window and its price" of `discussion.tex`** become Props 3.2 and 3.6 with their reading, and Remark 3.4's table. The literature sentence on λ-weighted MDL is kept.
6. **`prop:limits:envelope`(i) and its proof paragraph** become one line from Lemma 1.1(iv) (Prop 2.1(d)). Part (ii) keeps its proof.
7. **`prop:limits:rateblind`(ii) and its proof** become "the memoriser's secant exceeds the coin's" (Prop 4.2), and (i) is its three-hypothesis case. `lem:limits:robust` is kept.
8. **`rem:teacher:hanni`, item (1)** is the kink picture verbatim (slopes 100 and 10). Keep it as the motivating figure, and shorten the per-sample item to its rates.
9. **`rem:limits:method`** is replaced by §5 if adopted. Otherwise it is kept and reworded: "the information of competitors that do not know the model is not charged".
10. **The section introductions** of `teacher.tex` and `limits.tex` can lose their forward-looking summaries. The thread's introduction (item 1 of §6.1) carries them.

What must stay:
* the four lemmas, as the proofs of the two kink bounds;
* `lem:teacher:sharpfloor`;
* the proofs of (ii)(d) and (e), and of (iii) and (iv);
* the numbers tables;
* the finite-sample lemma and corollary;
* the concentration proposition;
* `ex:teacher:version1`.

---

## 7. Cross-track consistency

This section compares the three sub-tracks of track "split": iid (`../iid/notes-final.md`, T1, final), kink (`../kink/notes.md`, T2; no final record yet) and teacher (this file, T3). The kink referees' reports were read where they concern objects shared with this file.

### 7.1 Objects

| object | iid | kink | teacher (this file) | Paper 2 now |
|---|---|---|---|---|
| **PQ**: pairs i.i.d., label redrawn per query, per-query likelihood | §3–§6, §8 (main object) | its referees ask that §5 be restated in PQ; its scheme (iid), "non-atomic μ", is empty on $\{0,1\}^*$ | Prop 3.2 (any channel), Prop 3.6(a),(b); the noise-PQ column of Remark 3.4 | not used; `def:setup:data` fixes frozen noise |
| **FR**: one label per distinct input, data-set likelihood | §7.5, Prop 3.3, Cor 6.1(vi), Remark 7.7 | scheme (wor) = FR on a uniform finite support, counted in distinct inputs (iid Remark 1.5) | Prop 3.7(a); samples without replacement (Prop 3.3, `cor:teacher:sampled`); the FR rows of t5(D) | `def:setup:data`; `thm:split:private` |
| **FQ**: frozen labels, every query counted | §9.4(a), unnamed ("the per-query likelihood against a fixed table") | — | named here (§1.0); Prop 3.2(b′), Prop 3.7(b),(c), Lemma 3.0; the deterministic teacher's PQ | the population risk of `rem:setup:persample`, with $y^*=F$ |
| **DS**: one data set | Lemma 5.2; Prop 5.3(b),(c) | §2–§4 (hull, kinks, noisy parity) | Lemma 1.1; §2; §4; full tables | `algstat.tex`; `teacher.tex` (full tables) |

* *Agreed.* T1's limit and finite-sample theorems are PQ statements; T2's deterministic theory is DS; the teacher thread uses the population risk, full tables (DS) and samples without replacement (FR = FQ on distinct inputs).
* *New here.* The name FQ, the reuse factor, and Prop 3.7, which says which of the two frozen readings separates noise from errors.

### 7.2 Notation

| object | this file | iid | kink | Paper 2 / `NOTATION.md` |
|---|---|---|---|---|
| fit of π | $F(\pi)$ (Setting 1.0); $L(\pi)$ on a DS | $L_n(\pi)$ (PQ) | $L(\pi)$ | $-\log P_\pi(o)$ |
| sampled randomness | $F_0$ in Prop 2.3 | $S_n$ | $L_0$ | $-\log\nu(D_n)$ |
| least length of a μ-a.e. equivalent program; of a program equal to ν everywhere | $\ell_0$ (PQ); $k$ (any input rule, FR) | $\ell_0$; $k$; $k_\nu$ for a decoder | $\ell_0$; $\ell(\pi^*)$ | $k$ |
| left side of a kink | left margin $m_N(c)$, steepness σ (Remark 1.2), pointwise margin | left steepness of the sample kink | left kink (σ, $w_-$) | — |
| right side of a kink | right line $(\tau,g)$; right secant $s_+$ (Def 1.4) | "right kink of flatness τ beyond a window" (Lemma 8.1); line vs secant in §9.4(c) | right kink (τ, $w_+$); right slope $s_+$ (Cor 5.7) | — |
| sufficiency offset of the good model, full table | $b_0$ | — | $b_0$ | — |
| Ville deficiency | δ* | δ*, $\delta_n$ | δ*, $\log(1/\varepsilon)$ | δ* |
| structure function | $\rho_{\rm pop}$ (population) | $\rho_{\mathcal C}$ | $\rho_D$ | $\rho^\times_D$ |
| per-sample rate; population risk | $c$; $R(\pi)$ under any channel | $c$; $R(\pi)$ under the true channel | $c$ | $c$; $R(\pi)$ against $y^*$ |
| near-optimal set | $\mathcal N_\epsilon(c)$ | — | — | "ε-near-optimal" (`thm:teacher:main`) |
| the good model | $\pi_g$ (rate exactly $p$); the true-parity family (any rate) | — | $\pi_g$; k2's "parity with rates 1/4, 1/8, 1/16" | $\pi_g$ |

* *Translations.* A right line $(\tau,g)$ gives kink's right kink of flatness τ′ > τ with window $g/(\tau'-\tau)$ (Remark 1.3). Kink's right slope $s_+$ (Cor 5.7) is this file's right secant. Kink's left kink (σ, $w_-$) is the case $N=\{\ell<\alpha_--w_-\}$ of the left margin.

### 7.3 Results that coincide

* **The kink lemma.** Lemma 1.1 contains kink Thm 3.2(a),(b), up to windows, and Cor 3.3 (Remark 1.3). With the pointwise margin no finiteness condition is needed.
* **The τ = 1 instances.** Prop 2.3 is `thm:split:private`(i) and iid Thm 4.1(i) (the length bound), with $\ell_0$ in PQ (iid §9.3).
* **The full table, $m=d$.** Prop 2.4's $b_0$ is kink's $b_0$; at $d=m=20$, λ = 2 both give $\ell\le d+45.55$ (kink: "$d+45.5$").
* **The left side on samples.** iid Lemma 8.1(i),(iii) is kink Lemma 5.2 and Thm 5.4(i) in PQ form; Remark 3.4 quotes both with their probability qualifiers and objects.
* **λ = cn.** Prop 3.2(d) is iid Prop 3.4(c). The converse for noise is iid Prop 3.4(b).
* **λ = 1.** Remark 3.5 agrees with iid Thm 3.1 and Prop 3.3 (asymptotic selection, on the run in FR) and with kink Remark 5.9 and iid Remark 4.7 (no guaranteed interval at finite $n$).
* **Frozen noise.** Prop 3.7(a) is iid §9.4(a)'s first bullet (bounded gain under the data-set likelihood); Prop 3.7(b) is its second bullet (every $\lambda_n=o(n)$ memorises a fixed table counted per query).
* **Lines and secants.** Def 1.4 and Lemma 1.5 formalise iid §9.4(c). iid Lemma 8.1(iv) (an excess of exactly $k-7$ bits over the slope-1 line) and t5(B)'s $m=5$ instance (a secant $1.199\cdot2^{d-m}$ against a line of slope $2^{d-m}$) are both instances of Lemma 1.5(a).
* **Two kinks.** Kink's k2(F) and this file's t3 show the same phenomenon; kink §6's "λ must lie between the two kinks" is Prop 4.1 and the t3 table.
* **Set models.** Kink Prop 4.4 (no set kink at α ≈ d) is the shared-randomness counterpart of §4: a short near-sufficient set model flattens the left kink, while structured errors add a steep kink on the right.
* **Flip rates.** Kink Prop 4.2 and Cor 4.3 (full table: level 1 for $p<0.1233$, level ≤ 2 for $p<1/4$) and §5 (junta: level 1 for $p<0.1233$) use the same mechanism: the right side caps every competitor's information budget.

### 7.4 Points that needed reconciliation

* **(a) Frozen noise with repeats** (A M4, B-M1; iid §9.4(a)). The referees' statement "in the frozen object every $\lambda_n=o(n)$ memorises the noise" is true for FQ and false for FR, Paper 2's likelihood (Prop 3.7). iid §9.4(a) reaches the same conclusion. The paper must say which likelihood applies when inputs repeat (§6.1).
* **(b) "Right flatness"** (A M3; iid §9.4(c)). Two quantities, a line and a secant (Def 1.4). All statements of the form "right flatness 1 at every $n$", in this file and in iid and kink, mean the line.
* **(c) The offset $b_0$** (B-m5). Aligned to kink's $b_0$; `notes.md`'s $b_0'$ differed by $2\log((d+1)/d)\le2$ bits, absorbed into κ.
* **(d) $\ell_0$ against $k$** (iid Def 1.2; iid referee A, M2). Prop 2.3 uses $k$ for any input rule (FR included) and $\ell_0$ in PQ. Prop 3.7 uses a program equal to ν on the support of μ, which in FR on a countable $X$ is any shortest equivalent program (iid Prop 3.3).
* **(e) Kink's scheme (iid)** (kink referee A, issue 1). This file now cites kink Thm 5.4 only for the scheme (wor), and iid Lemma 8.1 for PQ. `notes.md`'s Remark 3.4 cited kink Thm 5.4 for i.i.d. noise; corrected.
* **(f) Rate-code artefacts** (A M1, B-m7; kink referee B, issues 6 and 7). In explicit classes the exact-rate model is often not the vertex. Kink's zero-window steepness at the exact good model depends on the rate code (7.89 in k2's code, 2.63 in the code of kink referee B's `rB2_parity_table.py`, and 0.66 < 1 at $d=6$, where the rate-1/8 parity dominates), and kink's two-kink ranges are per rate (parity + noise on (1.22, 12.8) as a family against (1.36, 10.0) for a single rate). *Recommendation for all three sub-tracks:* report the λ-set of the true-parity family, give per-rate splits only as illustrations, and state results about near-optimal sets or windowed kinks. Kink's Prop 4.1 is already windowed; this file's Prop 2.1 and Prop 3.1 are about near-optimal sets.
* **(g) Kink open question 3 on samples** (A M2). The junta kink is proved in population form (Prop 2.1) and on full tables (Prop 3.1). On samples it is proved only under equal multiplicities (Prop 3.3(b)); the general case is open.
* **(h) What iid says about this file.** iid §9.3 cites "teacher Prop 3.2(a),(b)" (the same target from the population side) and "teacher Remark 3.5" (λ = 1 by the Kraft tail); both stand, with the objects now named. iid §9.4(e) says that Prop 2.3's left margin holds in iid Lemma 8.1's sharper form with probability ≥ 1 − ε at fixed $n$; Prop 2.3 now says exactly this. iid §9.5 item 6 ("λ = cn: Prop 3.4 also gives the teacher thread its population-hull limit, teacher Prop 3.2(d)") is Prop 3.2(d) here.

### 7.5 Recommendations for the restructured Paper 2

1. **One kink lemma:** Lemma 1.1 (real offset, pointwise margin, item (iv)), with Def 1.4 and Lemma 1.5. Kink's hull theorems (Thms 2.1–2.2, 3.4) stay as the description of λ-MAPs on a data set.
2. **The teacher theorem as the τ = $2^{-m}$ instance,** about near-optimal sets. Drop the vertex sentence in `setup.tex` (§6.1, item 4).
3. **The reuse factor as the bridge between the threads:** Lemma 3.0, Prop 3.7 and Remark 3.4's table. It answers why the errors need λ ∝ n and the noise does not.
4. **`def:setup:data`:** name the likelihood for repeated inputs (FR, or per query) if T1's per-query results enter.
5. **Schedules:** Prop 3.6 in place of "λ must be cn".
6. **A free sharpening:** (a1) of Remark 2.6 in `thm:teacher:main`(ii)(a).
7. **Flip rates up to 0.1233:** Props 5.2–5.3 with integer information and the exact-window table.

---

## 8. Response to the referees

Every issue was checked against `notes.md` and, where possible, against the referees' code, which was re-run and reproduced its saved outputs byte for byte (verification log). No issue was rejected. Where the fix differs from the one the referee suggested, the table says so.

**Referee A (proofs).**

| issue | verdict | resolution | where |
|---|---|---|---|
| M1 the good model is not proved to be a vertex; false in natural codes | accepted | Vertex claim kept as refuted, with t5(A) (independent of rA1(A)) and t5(B), rB3(A). Statements use $\mathcal N_\epsilon(c)$. Prop 3.2(d) for countable classes. New Prop 3.6 replaces "only λ = cn". t2 and t3 reported per family and per rate. | §2.1 "What is selected", Props 3.1, 3.2, 3.6, §4 table, §6.1 item 4 |
| M2 sampled windows stated as proved | accepted | Windows stated where proved: population, full table, $n\ge n_0(c)$ through `cor:teacher:sampled`. The sampled upper bound is a conjecture with computed evidence. Kink open question 3 is answered on samples only for equal multiplicities. | Prop 3.3(c), §0 item 4, Remark 3.4, §5 "This answers", §7.4(g) |
| M3 right flatness undefined, the interval mixes two objects | accepted; fix varied | The suggested $\tau_{\rm line}$, "the least τ for which (R) holds with some finite $g$", is degenerate on one data set: every τ ≥ 0 has a finite $g$. Def 1.4 uses the pair $(\tau,g)$ and the secant $s_+$, related by Lemma 1.5. Prop 3.1(c) is the two-sided form: slope $2^{d-m}$ with offset $2^{d-m}\Lambda_2$, and offsets about $2^{d-m}(1-\rho)L_S$ for slopes $\rho2^{d-m}$ below the memoriser's secant. | Def 1.4, Lemma 1.5, Prop 3.1(c), Remark 3.4 |
| M4 the noise side is the per-query object; in Paper 2's frozen object noise is on the errors' side | accepted with a correction | Objects named everywhere (§1.0). Prop 3.2(b′) states the FQ case. Prop 3.7 shows that in Paper 2's data-set likelihood (FR) frozen noise keeps reuse factor 1 at every $n$, repeats or not; the referee's mechanism (memorise finitely many atoms) needs the per-query count (FQ). §3 retitled; FR and FQ columns in Remark 3.4; t5(D) computes both. | §1.0, §3.0, Props 3.2, 3.7, Remark 3.4, §7.4(a) |
| M5 Prop 5.3's range in the summary | accepted, with the referee's extension | Prop 5.3 for $a>a^*$ and $c\in[a2^{-m},c_m]$, $c_md\to0$; the generalisation to $s_0=p2^m$ checked and stated; summary restated | Prop 5.3, §0 item 6 |
| m1 $g\ge0$ in Prop 2.1(b) | accepted | $g\ge0$ follows from boundedness by $\pi_g\in M$ (Lemma 1.1(i)), equivalently (D2) at $\pi_g$; Lemma 1.1 now allows real $g$ | Lemma 1.1, Prop 2.1(b) |
| m2 finiteness in Remark 1.3 | accepted; fix varied | A pointwise margin in Lemma 1.1(ii) makes finiteness unnecessary; the referee's prefix-class remark is recorded | Lemma 1.1(ii), Remark 1.3 |
| m3 Prop 2.3 claims slightly more | accepted | length bound from the lemma, fit bound is (R) | Prop 2.3 |
| m4 "$m_N$ grows linearly" for `thm:split:private`(iv) | accepted | restricted to iid Lemma 8.1 and kink Thm 5.4 with their probabilities | Prop 2.3 |
| m5 third inequality used without (R) | accepted | Lemma 1.1(iv) | Lemma 1.1, Props 2.1(d), 4.1(b) |
| m6 Prop 3.3(b) drops terms; chain rule only sketched | accepted | $2\log(m+1)$; offset $\bar n(\beta+c_1+\kappa_g)$; full proof of the chain rule | Prop 3.3(b) |
| m7 Prop 3.2(d) finite class | accepted | countable Kraft classes (iid Prop 3.4(c)) | Prop 3.2(d) |
| m8 converse attributed to iid Prop 3.4 | accepted | cites iid Prop 3.4(b), now proved there | Reading after Prop 3.2 |
| m9 Remark 3.4 terms and readings | accepted | $-2\log(1/\varepsilon)$ and probabilities added; total bits throughout | Remark 3.4 |
| m10 numbers | accepted | $L_S=43.41$; $\theta_m=1+O(\cdot)$; δ_S's effect refuted at 15/128; exact ends next to the certified ones | Prop 3.1, §5 |
| m11 reporting of t2 | accepted | per-sample fractions (t5(C)); the λ = 2 claim refuted; what "exact hull" means | Prop 3.3 table |
| m12 envelope against good model | accepted | 7 bits against 9 (t5(E)) | §4 |
| m13 "window" in Prop 4.1(b) | accepted | $W_\epsilon$ defined; consistency with `thm:teacher:main` for the structured rule shown | Prop 4.1 |
| m14 window need not be an interval | accepted | stated; computed windows are intervals | Prop 5.2 |
| m15 statuses | accepted | Table 2.2 a remark; convexity proved; (iii), (iv) described as geometry | §2.1, Prop 5.3 |
| m16 decoder must be a measure | accepted | $\pi_g$ chosen as a measure on $\{0,1\}^{\le d}$ | Prop 3.3(a) |
| m17 Prop 2.4(ii) | accepted | "improves the length bound" | Prop 2.4(ii) |
| m18 t1(D) exact by construction | accepted | described as such | Prop 2.4, verification log |
| m19 non-integer $B$ | noted | inherited from the paper; use $\lfloor B\rfloor$ | §2.1 |

**Referee B (computation and counterexamples).**

| issue | verdict | resolution | where |
|---|---|---|---|
| B-M1 "fixed λ for noise, λ ∝ n for errors" fails for frozen noise once inputs repeat | accepted with a correction (as A M4) | The reformulation in terms of the reuse factor is adopted (title, Lemma 3.0, the answer to the brief's question). rB5's frozen source counts every query (FQ), not `def:setup:data`'s likelihood. t5(D) adds FR rows in class K and in t2's class: there frozen noise is kept at λ = 2, 8, 20 at every $n$. | §3, Prop 3.7, t5(D) |
| B-m1 t4(C)'s convergence is a grid artefact | accepted | Ψ over integer $I$; t6(A) = rB7(C); the old reading kept as refuted | Props 5.2–5.3, tables |
| B-m2 sharper (ii)(a), (e) | accepted | Remark 2.6, with the numbers in §5 | Remark 2.6, §5 |
| B-m3 ceiling bug | accepted; fix varied | documented and corrected in t5 (exact ceilings); t1–t4 and `tcommon.py` kept as the refereed record; only t2(A)'s $m=4$ lines change | Prop 3.1 bullets, verification log |
| B-m4 the $m=4$ sentence | accepted | corrected, kept as refuted | Prop 3.1 bullets |
| B-m5 numbers ($L_S$; $b_0$ vs $b_0'$) | accepted | $L_S=43.41$; $b_0$ aligned with kink | Props 2.4, 3.1 |
| B-m6 per-sample reporting of t2(B) | accepted | per-sample table (t5(C)); the narrow c-window; the mean multiplicity; the max-multiplicity claim withdrawn | Prop 3.3 |
| B-m7 rate-$p$ selected on a small part of the family's set | accepted | as A M1 | §2.1, Prop 3.1 table |
| B-m8 $g\ge0$ automatic | accepted | Lemma 1.1(i) | Lemma 1.1 |
| B-m9 units in Remark 3.4 | accepted | total bits throughout | Remark 3.4 |
| B-m10 exact windows | accepted | exact ends quoted; t6(B) reproduces rB7(B) | §5 table |
| B-m11 smaller points | accepted | (1) exact for λ > 0 over the families as restricted; (2) convexity proved; (3) the "1" needs the covering fill-in | Props 3.3, 5.3 |

**Points from sibling referee reports that concern this file.**
* iid referee A, M2 (a decoder must be a measure where it decodes): Prop 3.3(a), with A m16.
* kink referee A, issue 1 (scheme (iid) empty on $\{0,1\}^*$): Remark 3.4 cites kink Thm 5.4 only for (wor).
* kink referee B, issues 6–7 (rate-code artefacts): §7.4(f).

---

## 9. Claims and statuses

| # | claim | status |
|---|---|---|
| 1.1 | two-sided kink lemma: property-defined left set with a pointwise margin, right line with real offset; (iv) without a line; $g\ge0$ when an $M$-program bounds the reference | proved; computed t1(A), t7(A), rB1(A) |
| 1.2 | the left margin as a wedge: $m_N\ge\mu(1-c/\sigma)$ | proved; computed rB1(B) |
| 1.3 | kink Thm 3.2, Cor 3.3 and Thm 5.4(ii) are cases of Lemma 1.1 (up to windows); the window variant; a right line gives a right kink | proved; computed rB1(C) |
| 1.4–1.5 | right line and right secant; secants ≤ τ + g/x; offsets ≥ $(s_1-\tau)x_1$; the secant decides the comparison with the reference | proved; computed t7(B) |
| 2.1 | `thm:teacher:main`(i), (ii)(b), (ii)(c) are Lemma 1.1 with τ = $2^{-m}$, $g=\Lambda_2/2^m\ge0$, $\ell_M=d-4-\Lambda_1$; left margin ≥ $\Phi_2-J_g$; wedge at $c_{\rm hi}$; `prop:limits:envelope`(i) is Lemma 1.1(iv) | proved; computed t1(B), rB2(E) |
| 2.1-sel | every program of $\mathcal N_\epsilon(c)$ has the properties of (ii); no claim about which program is selected | proved (from `thm:teacher:main`) |
| 2.1-R | "the good model is an interior vertex whose λ-interval contains $(2^{-m},c_{\rm hi}]$" | **refuted as stated**: false in two explicit rate codes and in two exact classes (t5(A), t5(B), rA1(A), rB3(A)); machine-dependent in $\Hcl{\times}$ |
| 2.2 | the hypothesis ↔ kink-condition table | remark |
| 2.3 | `thm:split:private`(i)'s length bound is Lemma 1.1 with τ = 1, $g=k+\delta^*$ ($\ell_0+\delta^*$ in PQ), $N=\emptyset$; its fit bound is (R) | proved; computed t1(C) |
| 2.4 | for $m=d$ the right condition is the sufficiency line for all programs, with $g=b_0$; `cor:teacher:fulltable`(i) is the τ = 1 instance; the sufficiency line improves the length bound | proved; computed t1(D), rB2(C) |
| 2.5 | δ* and $\delta_S$ play the same role, with the same $2^{-j}$ tail | remark (from proved results) |
| 2.6 | (a1), (a2), and (e) with the larger $u$ | proved; computed t6(C),(D), rB8 |
| 3.0 | duplication multiplies every λ-threshold by $r$ | proved; computed t7(C) |
| 3.1 | full table, every $m$: window $\lambda\in(2^{d-m},Nc_{\rm hi})$; right line $(2^{d-m},2^{d-m}\Lambda_2)$; secant ≥ $2^{d-m}\theta_m$; lines of slope $\rho2^{d-m}$ need offset ≈ $2^{d-m}(1-\rho)L_S$ | proved; computed t1(D), rB2(B), t5(B), rB3(A) |
| 3.1-R | "total-bit right flatness in $[2^{d-m}\theta_m,2^{d-m}]$" | **refuted** as one quantity; read as a secant it fails at $m=5$ ($1.199\cdot2^{d-m}$ in t5(B), $1.079\cdot2^{d-m}$ in rB3(A)) |
| 3.1-R2 | "for $m=4$ the rule is one cell, cheaper than the model's own rate code" | **refuted**: 4 bits longer (t5(B), rB3(F)) |
| 3.1-R3 | "$L_S=41$ at $d=20$, $m=12$"; "$\theta_m=1-O(\cdot)$" | **corrected**: 43.41; $1+O(\cdot)$ with undetermined sign |
| 3.2 | $\lambda_n=o(n)$ rejects every program not of least risk (PQ, any channel); ν least risk in PQ; not in FQ; λ = cn ends in $A_c$ in countable classes | proved |
| 3.6 | $\lambda_n/n\to0$: $e=1$ eventually; $\lambda_n/n\to\infty$: MAP length ≤ $\ell_{\min}$ eventually; $\lambda_n/n$ in a compact subset of the window: identification with probability ≥ 1 − δ at each $n$, a.s. eventually in PQ | proved |
| 3.6-R | "only λ = cn can stop at an interior vertex" | **refuted as stated** (Prop 3.6(c)) |
| 3.7 | FR: line $(1,k+\delta^*)$ at every $n$ and bounded memoriser gain; FQ: every $\lambda_n=o(n)$ memorises; FQ with equal multiplicities is $\bar n$ times the full table | (a) proved from `lem:split:ville`; (b), (c) proved |
| 3.7-c | FR keeps frozen noise at λ = 2, 8, 20 for every $n$; FQ memorises once $\bar n\theta>\lambda$; junta errors in FR memorised below $2^{d-m}\theta$, kept at λ = 20 | computed t5(D), rB5 |
| 3.R | "fixed λ suffices for i.i.d. noise; the errors need λ ∝ n", object unnamed | **refined**: true in PQ and FR (Paper 2's likelihood); false in FQ, where frozen noise needs λ ∝ n/N |
| 3.3(a) | on samples the right secant at the good model is at least about $\max\{1,n2^{-m}\theta_m\}$; the 1 needs the canonical class's covering fill-in | proved |
| 3.3(b) | sampled coding lemma with $2\log(m+1)$; the chain rule; a right line with τ = $\bar n$ under equal multiplicities; slope $(1-\eta)\bar n$ under near-equal multiplicities | proved; computed rB6(A) |
| 3.3(b)-o | "the effective slope can approach $\max_zn_z$" | **withdrawn; open** (evidence against at the computed sizes: t5(C), rB4) |
| 3.3(b)-s | β is small when $\bar n=1$ | proof sketch |
| 3.3(c) | on samples, the lower end ≈ θ × mean error-cell multiplicity for $n\gg2^m$; upper end ∝ n | conjecture; computed t2(B), t5(C), rB4 |
| 3.3-R | "λ = 2 keeps the good model in every sample up to $n=2^m$"; "λ = $4n2^{-m}$ keeps it at every $n\ge64$" | **refuted** (0.10 at 32, 0.70 at 64; 0.90 at 64 for the second) |
| 3.4, 3.5 | the objects side by side; what λ > 1 buys | remark (from proved results) |
| 4.1 | an envelope removes $(0,c_{\rm env})$ from $W_\epsilon$; envelope (i) is Lemma 1.1(iv) | proved |
| 4.2 | rate blindness (⋆) = memoriser's secant ≥ coin's secant, an empty kink interval | proved |
| 4.3-c | two kinks; lower end 15.0 → 17.1 → 42.7 → 85.3 → empty; rate blindness from $d=13$ ($d=12$ in class K) | computed t3, rB3(C),(D) |
| 4.3 | rate, not validity, in hull form | remark (from cited results) |
| 5.1 | the information charge; $I(\pi)$ an integer | proved |
| 5.2 | $J^B_c\ge LB_t(c)$; `thm:teacher:main`(i), (ii) and Remark 2.6 hold with $\Phi_2^\sharp\ge\Phi_2$ | proved; computed t4(B), t6(B), rB7(B) |
| 5.3 | for every dyadic $p<0.12331$ and $a>a^*(p)$: a window containing $[a2^{-m},c_m]$ for every $c_m=o(1/d)$, for all large $m$; $a^*=1$ for $p<0.07787$; the instance generalises to $s_0=p2^m$ | proved, given the computed constants (t4(A), rB7(A)) |
| 5.3-c | exact windows at $d=100$, $m=20$ for $p=2^{-10},\dots,15/128$ (κ = 0) and up to 7/64 (κ = 30); certified ones inside them | computed t6(B), rB7(B); t4(B) |
| 5.3-R | t4(C)'s plateau read as convergence to $\psi_2$ | **refuted**: an I-grid artefact (t6(A), rB7(C)) |
| 5.3-R2 | "$\delta_S=20$ changes the windows by at most a few percent" | **refuted** at $p=15/128$ (23% and 10%) |
| 5-open | level ≤ 2 for $p<1/4$ in the junta case | conjecture (routine) |

---

## References

* Paper 2 (`paper-steeper/sections/`): `def:setup:data`, `lem:setup:hull`, `lem:setup:coding`, `rem:setup:persample`, `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `rem:split:reading`, `thm:split:shared`, `prop:algstat:product`, `prop:algstat:parity`, `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:sharpfloor`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main`, `cor:teacher:fulltable`, `lem:teacher:finite`, `cor:teacher:sampled`, `prop:teacher:concentration`, `ex:teacher:version1`, `prop:limits:plain`, `rem:limits:schedule`, `prop:limits:envelope`, `prop:limits:rateblind`, `lem:limits:robust`, `prop:limits:separable`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw`, `rem:limits:method`, `q:teacher:open`, `q:limits:open`.
* The steeper record `research/tracks/steeper/notes-final.md`, §1–§4.
* Sibling notes: `../iid/notes-final.md` (Defs 1.1–1.3, Remarks 1.4–1.5, Lemmas 2.1–2.2, Thm 3.1, Props 3.3–3.4, Thm 4.1, Remark 4.7, Lemma 5.2, Props 7.3, 7.5–7.6, Remark 7.7, Lemma 8.1, §9) and `../kink/notes.md` (Def 3.1, Thms 2.1–2.2, 3.2, 3.4, Cor 3.3, Props 3.5, 4.1–4.4, Lemmas 5.1–5.3, Thm 5.4, Cor 5.7, Remark 5.9, §6, open question 3); `../kink/referee-A.md` (issue 1), `../kink/referee-B.md` (issues 5–7).
* R. Durrett, *Probability: Theory and Examples*: the strong law for nonnegative variables with infinite mean [known; edition and theorem number unverified].
* W. Hoeffding, "Probability inequalities for sums of bounded random variables", *JASA* 58:13–30, 1963 [as cited by Paper 2; used through `lem:teacher:sharpfloor` and `lem:teacher:finite`].
* J. Ville (1939) and S. Kakutani (1948) [known; used only through Paper 2's `lem:split:ville` and `thm:split:private`(iv)].

---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and scipy 1.17.1. Every prover script was run from `checks/`, and its output saved as the `.out` file of the same name.*

* **Reproduction of the whole record.** `checks/` and `referee_code/` were copied to a scratch directory and every script was re-run there with `PYTHONDONTWRITEBYTECODE=1`. Each exited with code 0, and each output is byte-identical to the saved `.out` file.

  | script | time | | script | time |
  |---|---|---|---|---|
  | t1_kink_instances | 6 s | | rA1_checks | < 1 s |
  | t2_reuse_factor | 1 s | | rB0_rerun_exactceil | 2 s |
  | t3_second_kink | < 1 s | | rB1_kink_lemma | 75 s |
  | t4_junta_window | 27 s | | rB2_constants | 3 s |
  | t5_revision | 7 s | | rB3_fulltable_class | 26 s |
  | t6_exact_window | 453 s | | rB4_sampled | 12 s |
  | t7_lemma_checks | 3 s (run twice in place, identical) | | rB5_iid_repeats | 2 s |
  | | | | rB6_coding_lemmas | 8 s |
  | | | | rB7_junta_window | 750 s |
  | | | | rB8_sharper_identification | < 1 s |

  No `__pycache__` was left in `checks/` or `referee_code/` (t5 and t6 set `sys.dont_write_bytecode`).
* **t1–t4 and `tcommon.py`** [unchanged from `notes.md`; their verification is that of `notes.md`, repeated here in brief].
  * t1 [`random.seed(31)`]: Lemma 1.1 in its original form in exact arithmetic; the identities of Prop 2.1 over 17,411 parameter sets; the split instance; the $m=d$ instance (agreement partly by construction, Prop 2.4).
  * t2 [`default_rng(32)`], t3 [`default_rng(33)`]: exact hulls of the explicit class. Their ceiling bug (B-m3) changes only t2(A)'s $m=4$ lines (rB0, t5(B)); no quoted number depends on it.
  * t4 [deterministic]: the constants of §5 and the certified windows; superseded for the window ends by t6, which agrees with it in direction (every certified window lies inside the exact one).
* **t5_revision** [new; seeded: `default_rng(32)` reproducing t2's draws, `default_rng(55)`, `default_rng(5151)`].
  * (A) The rate-code comparison of A M1, independently of rA1(A): the same switch points ($4.3301\cdot10^{-4}$, $1.4243\cdot10^{-3}$) and the same rate sequence. At each precision only the odd neighbours of $p2^b$ are compared, which is exact because the code length depends only on $b$ and $\mathrm{KL}(p\Vert q)$ is convex in $q$. A first version enumerated every $j/2^b$ and was too slow; it was not run to completion.
  * (B), (C) t2 with exact ceilings, reproducing t2's instances and samples: every family interval and every median of t2(B) is reproduced; the per-rate and per-sample columns are new.
  * (D) FR against FQ in referee B's class K (imported unchanged from rB5) and in t2's class.
  * (E) The envelope's length.
  * Two runs in place gave byte-identical output.
* **t6_exact_window** [new; deterministic; 7.5 min].
  * (A) and (B) agree with rB7(C) and rB7(B) to every printed digit (for example $8.1983\cdot10^{-3}$, $2.5293\cdot10^{-3}$, $21.432\cdot2^{-20}$ and $6.2252\cdot10^{-5}$). t6's code is independent of rB7's: its search for $j$ is a binary search in the increasing sequence $j-2\log(j+1)$, $j\ge3$ (asserted increasing), and its hull is Andrew's monotone chain written here, where rB7 uses scipy's `ConvexHull`.
  * (C), (D) agree with rB8 at the overlapping rows ($u\ge0.9831/0.9882/0.9897$ at $c=10^{-4}$; $0.8279$ and $e\le0.1965$ in the $p=1/16$ row).
  * The κ = 0, $\delta_S=20$ rows of (B) are new; they give the deficiency factors of §5.
* **t7_lemma_checks** [new; `random.seed(77)`; 3 s]. Exact rational arithmetic.
  * (A) The revised Lemma 1.1 on 3000 point sets: 14,945 near-optimal points under the pointwise margin, with the least admissible $g$ (negative in 363 sets), and 132,074 checks of (iv). A first version reported 26 sets with $g<0$ and a bounding program in $M$; the bounding point had been dropped by a filter for negative fits after the flag was set. The flag is now computed after the filter, and the count is 0, as Lemma 1.1(i) says.
  * (B) Lemma 1.5 (a)–(c) on 8714 points and 4860 values of λ.
  * (C) Lemma 3.0 at 35,406 values of λ, including every positive breakpoint.
* **Referee code.** All of it re-ran identically (table above). Its results are used as independent confirmations: rA1(A) for t5(A); rA1(C),(D) for the numbers of A m10 and the sign of $\Lambda_2$; rB1 for Lemma 1.1 and Remarks 1.2–1.3; rB2 for Props 2.1, 2.4 and 3.1 and the ceiling bug; rB3 and rB4 for the explicit-class claims in a second code; rB5 for the FQ simulations; rB6 for the coding lemmas; rB7 and rB8 for §5 and Remark 2.6.
* **Proof checks by hand.**
  * Lemma 1.1 with real $g$, the pointwise margin and item (iv); the remark that $g\ge0$ when an $M$-program bounds the reference (B-m8).
  * Lemma 1.5 and Lemma 3.0.
  * Prop 2.1(b): $g\ge0$ from boundedness and from (D2) at $\pi_g$.
  * Prop 2.4 with $b_0$: $\Lambda_2-b_0=4+2\log d$.
  * Remark 2.6: (a1) from (D1) and the floor; (a2) from the sharp floor with the budget of (ii)(d); (e) uses $u$ only through $\bar v\le1-u$.
  * Prop 3.1(c): the offset bound from (R) at $\pi_b$, which is level 1.
  * Prop 3.2(d) (as iid Prop 3.4(c)); Prop 3.6(a)–(c), including the uniform excess $\bar\epsilon_n$ over $[c_1,c_2]$; Prop 3.7(a)–(c).
  * Prop 3.3(b): the chain rule step by step, the $2\log(m+1)$, the equal- and near-equal-multiplicity lines, including the case $C-x-c_1<0$, where $F\ge0$ suffices.
  * Prop 4.1(b): the consistency of $W_\epsilon$ with `thm:teacher:main` for the structured rule ($c\Lambda_2/(c2^m-1)\approx0.13$ at $c=1.01\cdot2^{-20}$ with $\delta_S\approx1300$).
  * Lemma 5.1 (integrality of $I$), Prop 5.2 (the minimum over integers), Prop 5.3 with the range $[a2^{-m},c_m]$ and the generalised instance.
* **Not checked here.** The sibling results cited as such: iid Defs 1.1–1.3, Lemma 2.2(c), Thm 3.1, Props 3.3, 3.4, 7.5, Lemma 5.2, Lemma 8.1; kink Thms 2.1–2.2, 3.2, 3.4, Cor 3.3, Props 4.1–4.4, Thm 5.4. They were read as far as needed for the citations, together with the sibling referee reports where they bear on them.
* **Repository.** No git command was run. Files written, all under `research/tracks/split/teacher/`: `notes-final.md`; in `checks/`, `t5_revision.py`, `t6_exact_window.py`, `t7_lemma_checks.py` and their `.out` files. `notes.md`, t1–t4, `tcommon.py`, their outputs and the referees' files were not modified.
