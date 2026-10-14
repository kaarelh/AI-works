# Track "split": synthesis. The model–randomness split as the main thread of Paper 2 (final record)

*Brief: `00-brief.md` (this folder). This record synthesises the three sub-track records `iid/notes-final.md` (target T1), `kink/notes-final.md` (T2) and `teacher/notes-final.md` (T3), with their referee reports, against Paper 2's current sections. It proves nothing new: every claim below is a statement of a sub-track record, cited by number, or a recomputation marked as such. Written 2026-10-13.*

* **Sources read.**
  * The brief, in full.
  * The three sub-track final records, in full: `iid/notes-final.md` (cited as **iid**), `kink/notes-final.md` (**kink**), `teacher/notes-final.md` (**teacher**).
  * Their six referee reports: `iid/referee-A.md` in full; the verdicts, major issues and checked lists of `iid/referee-B.md`, `kink/referee-A.md`, `kink/referee-B.md`, `teacher/referee-A.md`, `teacher/referee-B.md`. Each final record lists every referee issue with its resolution (iid §10, kink §0.1, teacher §8); those tables were read in full.
  * Paper 2 (`paper-steeper/sections/`), in full: `abstract`, `intro`, `related`, `setup`, `absorb`, `teacher`, `limits`, `split`, `algstat`, `computable`, `discussion`, and the appendices `app-setup`, `app-split`, `app-algstat`, the first part of `app-teacher` (list decoding, floors, `lem:teacher:sharpfloor`); for the other appendices the table of contents (`main.toc`) and the label lists.
  * The refereed record `research/tracks/steeper/notes-final.md` (**St**): §0 and §3.1–3.4 in full; the headings of the rest.
  * Paper 1: `learn.tex` (`prop:learn:freshnoise`, `prop:learn:perquery`), `steeper.tex` (the prose summary of Paper 2); `paper/NOTATION.md` (searched for every symbol used below).
  * `research/paper-review/REFRAME.md` (binding rules for Paper 2's text).
* **Scripts.**
  * `checks/s1_synthesis_numbers.py` (new, deterministic), output `checks/s1_synthesis_numbers.out`. It recomputes from closed forms the numbers this record quotes in its headline statements and cross-track comparisons.
  * All 50 prover and referee scripts of the three sub-tracks were re-run from a scratch copy (verification log).
* **Status tags.**
  * **[proved: X]**: proved in sub-track record X, which contains the full proof. **[proved, refereed]** means that the statement in this form was checked by a sub-track referee. **[proved, post-referee]** means that it was added or restated in the final record after the referee round, and no independent referee has read it in its final form. §8 lists the status of every headline claim.
  * **[computed: script]**: checked by that script; output saved next to it.
  * **[known: ref]**, **[conjecture]**, **[open]**, **[refuted]**, **[remark]**: as in the sub-track records.
* **Conventions.** $\log=\log_2$. κ is Paper 2's machine constant; numbers marked "κ = 0" are illustrations. $c=\lambda/n$. Notation is that of §1 below, which reconciles the three records.
* **Repository.** No git command that changes repository state was run (only `git status`). Files written: this record, `checks/s1_synthesis_numbers.py` and its `.out`.

---

## 0. Summary

1. **The headline: the split works exactly with i.i.d. inputs and per-query noise (§2.1).** In every countable product class with Kraft weights that contains the sampler, with inputs i.i.d. from an arbitrary law μ and labels redrawn at every query:
   * for every schedule $1\le\lambda_n=o(n)$, λ = 1 included, almost surely every $\lambda_n$-MAP is eventually a shortest program whose predictive law equals the sampler's μ-almost everywhere;
   * for fixed λ > 1 this comes with guarantees that depend only on $(\lambda,\ell_0,\gamma,\varepsilon)$: a length bound for all $n$, exponentially vanishing posterior mass on fill-ins, and an explicit sample size $n=O(\lambda\ell_0/(\min(1,\lambda-1)\gamma))$;
   * at λ = 1 no such class-free rate exists: in a parity class with a uniform margin the recovery time is $\Theta(2^{\ell_0/2})$, against $\Theta(\lambda\ell_0/(\lambda-1))$ for λ > 1.

   [proved: iid Thms 3.1, 3.2, 4.1, Props 4.4, 5.1, Remark 4.7.] The data object matters. On Paper 2's input set $\{0,1\}^*$ every input law is atomic, so inputs repeat. With labels frozen per distinct input, Paper 2's present data model, no procedure recovers every sampler (iid Prop 7.5); what survives is identification on the run, for every λ ≥ 1.
2. **On one data set, a kink implies the split (§2.2).** The λ-MAPs are the programs on the lower convex hull of the points (length, fit) where the hull's slope crosses −λ. A program that is product-$b$-sufficient and loses at least σ bits of fit per bit saved to its left is, for every $\lambda\in(1,\sigma)$, within an explicit window of every λ-MAP, and every λ-MAP is product-$(b+(\lambda-1)w)$-sufficient. Stable MAP lengths on an interval of λ occur exactly at kinks. A universal member flattens every kink: this is absorption. [proved: kink Thms 2.1–2.2, 3.2, 3.4, Cor 3.3, Prop 3.5.]
3. **The bridge (§2.3).** A per-query sample has, with high probability, a kink at the shortest equivalent length: steepness linear in $n$ on the left, slope at most 1 beyond an explicit window on the right. The $\ell_0$ in that window cannot be dropped. Almost surely λ = 1 eventually lies inside the kink. [proved: kink Thm 5.4, Cor 5.7; iid Lemma 8.1.]
4. **The noisy random parity (§2.4).** On the full table, product models have a kink at the parity, steep enough that every λ in an explicit, certified interval selects "parity + noise" at the computed sizes, and every fixed λ > 1 does so for every flip rate below 1/4 once $d$ is large. Set models have no such kink. [proved: kink Props 4.1, 4.2, 4.4, Cor 4.3.]
5. **How the existing results fit (§3).** Absorption and `thm:split:shared` are the universal-member case of the kink geometry. `thm:split:private`(i) is the slope-1 case of one kink lemma, and (iv) holds for λ ≥ 1. `prop:algstat:product` and the length bounds of `thm:teacher:main` become one-line corollaries of that lemma. The product structure function becomes the paper's central object.
6. **The teacher's mistakes are the split at a positive rate (§4).** The same kink lemma with a right line of slope $2^{-m}$ per sample gives `thm:teacher:main`(i), (ii)(b), (ii)(c). Errors are a fixed function of the input, so each bit of the error rule is reused about $n2^{-m}$ times. Noise is used once. That reuse factor is why the errors need λ ∝ n and noise needs only a fixed λ > 1. The window now extends to every flip rate below 0.1233, for the population objective, asymptotically in $m$. [proved: teacher Lemma 1.1, Props 2.1, 3.1, 3.7, 5.2, 5.3, Lemma 3.0.]
7. **A section plan (§5)** for a restructured Paper 2: about 27 pages of main text and 27 of appendices, split thread first, every existing label placed.
8. **Corrections found in the synthesis (§7).** The three final records renamed some symbols in opposite directions, because each aligned with the others' pre-referee notes. One sample size in iid is printed rounded instead of with the ceiling. These are reporting points; no mathematical statement is affected.

---

## 1. One notation for the restructured paper

The three final records renamed several symbols after reading each other's *pre-referee* notes, in opposite directions. iid adopted kink's old names, and kink adopted iid's old names. The paper needs one set. The recommendations respect `paper/NOTATION.md`: $\ell^*_\lambda$ is the absorption bound; $S$, $S_1$, $S_2$ are the error rule and its parts; $F$ is a random table in iid Def 1.3 and teacher §1.0; $F_t$ is a floor in `prop:algstat:parity`(iv).

| object | iid final | kink final | teacher final | Paper 2 now | **recommended** |
|---|---|---|---|---|---|
| least length of a μ-a.e. equivalent program; the set of such shortest programs | $\ell_0$; $E_0$ | $\ell^*$; $E^*$ | $\ell_0$ (PQ) | — | $\ell_0$; $E_0$ ($\ell^*$ clashes with $\ell^*_\lambda$) |
| length of a program equal to ν at every input; of a decoder that is a measure on $\{0,1\}^{\le d}$ | $k$; $k_\nu$ | $\ell(\pi^*)$ | $k$ | $k$ | $k$; $k_\nu$ |
| reference point of the kink lemma | — | $(\alpha_\pm,F_\pm)$, $(\alpha_k,F_k)$ | $(\ell_0,F_0)$ | — | $(\alpha_0,F_0)$ (frees $\ell_0$) |
| fit of π | $L_n(\pi)$ (per query) | $F(\pi)$ | $F(\pi)$, $L(\pi)$ | $-\log P_\pi(o)$ | $L(\pi;o):=-\log P_\pi(o)$, so $J_\lambda(\pi;o)=\lambda\ell(\pi)+L(\pi;o)$; per query $L_n(\pi)$ |
| sampled randomness | $S_n$ | $S_n$ | $F_0$ | $-\log\nu(D_n)$ | $L_n(\nu)$, the sampler's own fit ($S_n$ clashes with the error rule $S$) |
| Hellinger gap $\Ex_\mu\Hel(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))$ | $\Hel_\mu(\pi)$ | $\gamma(\pi)$ | — | $\Hel$ pointwise | $\Hel_\mu(\pi)$ |
| margins: up to length $L$; shorter than $\ell_0$; at length exactly ℓ | $\gamma_L$; $\gamma_-$ | $\gamma_{\bar\ell}$; $\gamma_<$; $\gamma_=(\ell)$ | — | — | $\gamma_L$; $\gamma_-$; $\gamma_=(\ell)$ |
| right side of a kink | "right kink of flatness τ beyond a window" | right kink $(\tau,w_+)$; right slope $s_+$ | right line $(\tau,g)$; right secant $s_+$ (Def 1.4) | — | right line $(\tau,g)$ and right secant $s_+$; the window form as a remark |
| left side of a kink | left steepness | left kink $(\sigma,w_-)$ | left margin $m_N(c)$, steepness σ | — | left kink $(\sigma,w)$; the property form of teacher Lemma 1.1 in the lemma |
| structure function | $\rho_{\mathcal C}$ | $\rho_D$, $\breve\rho_D$ | $\rho_{\rm pop}$ | $\rho^\times_D$ | $\rho^\times_D$ (data), $\rho_{\rm pop}$ (population), $\breve\rho$ for the convex minorant |
| the good model's sufficiency offset, full table | — | $b_0$ with $2\log(d+1)$ | $b_0$ with $2\log d$ | (inside `prop:algstat:parity`) | $b_0$ with $2\log(d+1)$ (the literal (F5)); see §7 |
| combined floors of the parity kink | — | $\Gamma_t(\lambda)$, $\Gamma^\circ_t$ (renamed from $\Psi$) | $\Psi_t(c)$ (a different object); its Remark 3.4 still writes $\Psi^\circ_t$ for kink's $\Gamma^\circ_t$ | — | $\Gamma_t$ for kink's, $\Psi_t$ for teacher §5's |
| data objects | PQ, FR, DS | (pq), (wor), (fd) | PQ, FR, FQ, DS | frozen only | PQ, FR, DS in the paper; FQ only in the teacher thread |

**The data objects** (iid §1, kink §5.0, teacher §1.0), as the paper should define them:
* **(DS)** a single data set, a finite partial function, with no probability model;
* **(FR)** frozen labels: one label per distinct input, with Paper 2's data-set likelihood (`def:setup:data` now);
* **(PQ)** per query: pairs i.i.d. from $\mu\otimes\nu$, the label redrawn at every query, likelihood $\prod_i\nu_\pi(y_i\mid x_i)$. These are the terms of Paper 1's $\Mpq$ (`prop:learn:perquery`);
* **(FQ)** a frozen table counted per query. This is the population risk of `rem:setup:persample` with $y^*$ the table. It is needed only to explain the teacher thread.

On $X=\{0,1\}^*$ every input law is atomic, so PQ and FR differ (iid Remark 1.4). They coincide only for a non-atomic μ on an uncountable standard Borel space, which is outside both papers (iid Remark 1.4(a), kink Remark 5.11).

---

## 2. Headline results of the split thread, ranked

### 2.1 First: exact model recovery (the "split works" theorem)

This is the result that best answers the request for "a nice theorem saying model+data splits work at least in some contexts". It is a composite of statements proved separately in iid. Each part keeps its own hypotheses.

**Setting (iid Defs 1.1–1.2).**
* $\mathcal C$ is a countable class of programs with lengths $\ell(\pi)\in\mathbb N$ and $\sum_\pi2^{-\ell(\pi)}\le1$. Each π has a kernel $\nu_\pi(y\mid x)\ge0$, $\sum_y\nu_\pi(y\mid x)\le1$, measurable in $x$; $Y$ is finite. Examples: $\Hcl{\times}$, every time-bounded or circuit product class, every finite class.
* μ is any probability law on $X$; ν is a probability kernel. Neither needs to be computable.
* **Data (PQ):** pairs $(x_i,y_i)$ i.i.d. from $\mu\otimes\nu$, with the label redrawn at every query, repeats included. $h_n$ is the first $n$ pairs, $L_n(\pi):=-\log\prod_{i\le n}\nu_\pi(y_i\mid x_i)$ the fit, $L_n(\nu)$ the sampled randomness, $\Lambda_n(\pi):=2^{L_n(\nu)-L_n(\pi)}$ the likelihood ratio.
* $E:=\{\pi:\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)\text{ for μ-a.e. }x\}\neq\emptyset$, $\ell_0:=\min_E\ell$, $E_0:=\{\pi\in E:\ell(\pi)=\ell_0\}$ (finite).
* $\Hel_\mu(\pi):=\Ex_{x\sim\mu}\Hel(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))$; $\gamma_L:=\min\{\Hel_\mu(\pi):\pi\notin E,\ \ell(\pi)\le L\}>0$; $\rho_s(\pi):=\Ex_\mu\sum_{y:\nu>0}\nu^{1-s}\nu_\pi^s$.
* δ* $:=\sup_n\log(\xi_{\mathcal C}(h_n)/\nu(h_n))$, with $\xi_{\mathcal C}:=\sum_\pi2^{-\ell(\pi)}\nu_\pi$. Then $\Prob[\delta^*\ge j]\le2^{-j}$ for every input rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn (iid Lemma 2.2).

**Theorem A (exact model recovery).**
* **(a) The limit, every λ ≥ 1** [proved, refereed: iid Thm 3.1]. For every schedule $\lambda_n\ge1$ with $\lambda_n/n\to0$, fixed λ ≥ 1 included, almost surely the set of $\lambda_n$-MAPs equals $E_0$ for all large $n$.
* **(b) The posterior** [proved, refereed: iid Thm 3.2]. For fixed λ ≥ 1, almost surely $\Pi_\lambda(E\mid h_n)\to1$ and $\Pi_\lambda(\pi\mid h_n)\to2^{-\lambda\ell(\pi)}/W_\lambda$ for π ∈ E, where $W_\lambda:=\sum_E2^{-\lambda\ell}$. The tempered posterior $\Pi^\eta$, η ∈ (0, 1], also concentrates on $E$, with limit shares $2^{-\ell(\pi)}/W_1$.
  * "The posteriors concentrate on $E_0$" is **[refuted]**: with two programs for ν, of lengths 5 and 7, the limit share of $E_0$ is 0.889 at λ = 1.5 [computed: iid i1(C)]. Only the MAP singles out $E_0$.
* **(c) For all n, fixed λ > 1** [proved, refereed: iid Thm 4.1(i)–(iii)].
  * Every λ-MAP has length at most $\ell_0+(\ell_0+\delta^*)/(\lambda-1)$.
  * A deterministic program consistent with the data has length at least $L_n(\nu)-\delta^*$.
  * The power posterior of all such fill-ins is at most $2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)L_n(\nu)}$, with $L_n(\nu)/n\to H_\mu(\nu)$ almost surely. So it decays exponentially in $n$ when $H_\mu(\nu)>0$.
* **(d) At each n** [proved, post-referee: iid Thm 4.1(iv′) (the free exponent, from iid referee B's b3); proved, refereed: iid Thm 4.1(iv), the margin form].
  * For every λ > 0,
    $$\Prob[\text{set of λ-MAPs}\ne E_0]\ \le\ \sum_{\pi\notin E}\inf_{0<s\le1}2^{-s\lambda(\ell(\pi)-\ell_0)}\rho_s(\pi)^n .$$
  * *Margin form.* Let λ > 1, $L_\varepsilon:=\lceil(\lambda\ell_0+\log(2/\varepsilon))/(\lambda-1)\rceil$ and $0<\gamma\le\gamma_{L_\varepsilon}$. Then the probability is at most ε for every
    $$n\ \ge\ \Big\lceil\frac{\lambda(\ell_0+\log(2/\varepsilon))\ln2}{2\min(1,\lambda-1)\gamma}\Big\rceil .$$
  * A version uniform in time is iid Thm 4.1(v).

**Corollary A′ (noisy computable functions)** [proved, refereed: iid Cor 6.1(i)–(v); (vi) proved lower bound and computed, post-referee].
* *Setting.* $Y=\{0,1\}$, $f$ total computable, $p\in[0,\frac12]$ computable, $\nu_{f,p}(y\mid x)=1-p$ if $y=f(x)$ and $p$ otherwise. The data are PQ: a noisy oracle that redraws its flip at every query.
* *Model.* For every schedule $1\le\lambda_n=o(n)$, almost surely every $\lambda_n$-MAP is eventually a shortest program whose kernel is "$f$ up to μ-null sets, with flips at rate exactly $p$". The rate, a real number, is identified exactly.
* *Noise.* The flips are the noise. For fixed λ > 1 every fill-in, including "$f$ plus the list of flipped queries", has posterior mass at most $2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)L_n(\nu)}$, with $L_n(\nu)/n\to H(p)$.
* *Frozen counterpart.* With frozen labels on a finite domain the selected rate is a penalised empirical rate. In iid's i4 class ($d=6$, $p=1/8$) the λ-MAP is wrong with probability at least $(7/8)^{64}$ for every λ [proved], and in fact 0.26, 0.26, 0.20 and 0.57 at λ = 1, 1.5, 2, 4 [computed: iid i8(D); rB6(C) finds 0.13, 0.13, 0.08 and 0.56 in a second class, with another rate code].

**What Theorem A says about λ.**
* **Parts (a) and (b) do not need λ > 1.** At λ = 1 the prior's Kraft tail already bounds the probability that a long program is ever selected (iid Thm 3.1, remark). So in the per-query object, "λ = 1 never makes the split exact" is **[refuted]** as an asymptotic statement about the MAP (iid Prop 5.3(a)).
* **What λ > 1 adds is a rate that depends only on $(\lambda,\ell_0,\gamma,\varepsilon)$**, in (c) and (d).
  * *At λ = 1*, the same Markov argument needs $\sum_\pi2^{-s\ell(\pi)}<\infty$ for some $s<1$, a property of the class [proved, post-referee: iid Remark 4.7].
  * *A class where λ = 1 is slow.* In the parity class $\mathcal C_k$ (a coin of length $k=\ell_0$ and all parities, uniform margin 0.293) the λ = 1 recovery time lies in $\big(2^{(k-8)/2}-6,\ \max(32,\lceil2^{(k+1)/2}/\sqrt\varepsilon\rceil)\big]$ for $\varepsilon<31/32$ and even $k$ [proved: iid Prop 5.1(b) refereed, (b′) post-referee]. For λ > 1 it is $\Theta(\lambda k/(\lambda-1))$ up to logarithms [proved, refereed: iid Prop 4.4(b) with Thm 4.1(iv′)].
  * *Exact recovery times* at ε = 0.01 [computed: iid i7(A), certified scan; equal to the referee's independent rB2(B); the closed form $2^{(k+4)/2}+6$ and its position inside the proved bracket rechecked in s1(C)]:

    | $\ell_0=k$ | λ = 1 | λ = 1.1 | λ = 1.5 | λ = 2 | λ = 3 |
    |---|---|---|---|---|---|
    | 16 | 1030 | 78 | 34 | 23 | 20 |
    | 24 | 16390 | 144 | 52 | 38 | 29 |
    | 32 | 262150 | 232 | 70 | 51 | 38 |
    | 40 | 4194310 | 298 | 94 | 67 | 50 |

  * *Fill-ins.* On data sets with distinct inputs, in $\Hcl{\times}$, the λ = 1 posterior of the fill-ins is at least $2^{-k-2\log(t_n+1)-\kappa-\delta^*}$ (`thm:split:lambda1`(ii)). For λ > 1 it is at most $2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)L_n(\nu)}$ at every $n$ (Theorem A(c)).
* **The factors are necessary, in separate classes.**
  * The factor $1/\gamma$ is necessary for λ ≥ 2, up to constants and the ratio $\ell_0/\Delta$ [proved, refereed: iid Prop 4.4(a)].
  * Without a margin, no sample size depending only on $(\lambda,\ell_0,\varepsilon)$ exists [proved, refereed: iid Prop 4.2].
  * The factor $1/(\lambda-1)$ is necessary up to logarithms, for $\lambda-1\gtrsim\ell_02^{-\ell_0/2}$ [proved, refereed: iid Prop 4.4(b)].
  * The length bound of (c), with the current deficiency $\delta_n$ in place of δ*, is attained up to $\log(1+2^{2-\ell_0})/(\lambda-1)$ bits [proved, post-referee: iid Remark 4.5; computed: i7(E), rB7(B); lengths rechecked in s1(C)].
  * The joint factor $1/(\min(1,\lambda-1)\gamma)$ is not shown to be necessary in one class.
* **λ > 1 is not uniformly faster.** Against shorter competitors it delays recovery [computed: iid i1(A), rB1(3); heuristic explanation only]. The steeper prior helps against longer competitors: fill-ins and memorisers.

**Caveats that must travel with Theorem A.**
* *The object is PQ.* On $\{0,1\}^*$, with frozen labels (FR), no procedure, the λ-MAP for any λ included, recovers every computable sampler almost surely eventually [proved, refereed: iid Prop 7.5].
  * What survives in FR: every λ-MAP, for every λ ≥ 1 and every input rule, is eventually ν-equivalent on the run [proved, post-referee: iid Prop 3.3, from referee B's B1 sketch];
  * the length bound of (c) at every $n$, with $k$ in place of $\ell_0$ (`thm:split:private`(i));
  * finite-sample identification while a uniform finite domain is far from exhausted [proved, post-referee: iid Remark 7.7 via kink Cor 5.5].
* *The canonical class.* In $\Hcl{\times}$, with $Y=\{0,1\}$ and a computable ν with $\nu(1\mid x)\in[\beta,1-\beta]$ for a rational β > 0, the margin $\gamma_L$ is smaller than every computable function of $L$, for all large $L$ [proved, refereed: iid Prop 4.3]. So (d) gives no computable sample size there. A computable recovery-time bound in the canonical class is **[open]** (§6).
* *Method and novelty.* Parts (a) and (b) are the standard Ville-plus-strong-law argument. For i.i.d. density estimation with Kraft code lengths at λ = 1, consistency of two-part MDL is attributed to Barron and Cover (1991) [known: through Poland and Hutter (2005); the exact statement in Barron–Cover is unverified]. Theorem A(a) is the supervised analogue, for sub-probability kernels, an arbitrary input law and every schedule $\lambda_n=o(n)$, and it identifies the limit as the shortest μ-a.e. equivalent programs. No novelty is claimed for the method of (a) and (b). What the paper can present as its contribution is (c)–(d) together with the λ = 1 contrast and the necessity results. That rests on the project's own search only.

**What the λ = 1 MAP is** (brief T1) [proved: iid Prop 5.3].
* In PQ it is eventually in $E_0$, so it is not a fill-in forever.
* At finite $n$ in $\mathcal C_k$ it is a parity, a fill-in, for $n$ up to about $2^{(k-8)/2}$.
* If the 1-MAP of a single data set with distinct inputs is a fill-in, its length is at least $L(\nu;D)-\delta(D)$, and at most $\ell_0+L(\nu;D)$ whenever some $\pi_0\in E_0$ has $\nu_{\pi_0}(D)=\nu(D)$ (almost surely for sampled data; not for an arbitrary $D$). So it is about the sampled randomness.

### 2.2 Second: a kink implies the split, for one data set

**Setting (kink §1).** Any countable family of points $(\ell(\pi),L(\pi))$ with integer $\ell\ge0$, $L\in[0,\infty]$ and finitely many points per length. For example: the programs of a product class on a data set $D$, with $L(\pi)=-\log\nu_\pi(D)$; or the per-query point set of §2.3. Put $\rho_D(\alpha):=\min\{L(\pi):\ell(\pi)\le\alpha\}$; for $\Hcl{\times}$ this is $\rho^\times_D$. $\breve\rho_D$ is its greatest convex minorant.

**Theorem B.**
* **(B1) The hull** [proved, refereed: kink Thms 2.1, 2.2, Prop 2.3].
  * $\breve\rho_D$ is a polygon. Its vertices $(\alpha_i,\rho_i)$ are attained by programs of length exactly $\alpha_i$. Its edge slopes are $-\sigma_i$ with $\sigma_1>\sigma_2>\dots>0$, and $\sigma_i\to0$ if there are infinitely many.
  * For λ > 0, π is a λ-MAP iff $L(\pi)=\breve\rho_D(\ell(\pi))$ and $-\lambda\in\partial\breve\rho_D(\ell(\pi))$.
  * For $\sigma_{i+1}<\lambda<\sigma_i$ the λ-MAPs are exactly the programs at vertex $i$. At $\lambda=\sigma_i$ they are the programs on the closed edge, interior collinear points included.
  * A point is the unique MAP point on an open interval of λ iff it is a vertex. MAP length is nonincreasing in λ.
  * The MAP value $\Phi_D(\lambda)$ and $\breve\rho_D$ are Legendre duals.
  * This is `lem:setup:hull` read on one data set, with normal $(\lambda,1)$ in place of $(c,1)$.
* **(B2) A kink locates the MAPs** [proved, refereed: kink Thm 3.2; the hypothesis τ < σ in (d) and the strictness remark were added at the referees' request].
  * *Definitions (kink Def 3.1).* A **left kink of steepness** $\sigma\in(0,\infty]$ **and window** $w_-$ at $(\alpha_-,F_-)$: $\rho_D(\alpha_-)\le F_-$, and every π with $\ell(\pi)<\alpha_--w_-$ has $L(\pi)\ge F_-+\sigma(\alpha_--\ell(\pi))$. A **right kink of flatness** τ **and window** $w_+$ at $(\alpha_+,F_+)$: $\rho_D(\alpha_+)\le F_+$, and every π with $\ell(\pi)>\alpha_++w_+$ has $L(\pi)\ge F_+-\tau(\ell(\pi)-\alpha_+)$.
  * (a) If λ < σ, every λ-MAP has $\ell\ge\alpha_--w_-$ and $L\le F_-+\lambda w_-$. If moreover λ ≥ 1, it has $\ell+L\le\alpha_-+F_-+(\lambda-1)w_-$.
  * (b) If λ > τ, every λ-MAP has $\ell\le\alpha_++w_+$.
  * (d) A zero-window kink at one point with τ < σ is exactly a hull vertex, whose λ-interval contains (τ, σ). With τ = σ it can be an interior point of an edge [the unqualified form is **refuted**: kink Remark 3.2′].
  * The strict inequalities λ < σ and λ > τ are needed [computed: kink k8(A), rB1(T4)].
* **(B3) The split for one data set** [proved, refereed: kink Cor 3.3, in a hypothesis class as `def:setup:class` requires (kink §1; the weaker hypothesis "(F1) alone" is **withdrawn**)]. Let $\pi_s$ be product-$b$-sufficient for $D$, with $\ell_s:=\ell(\pi_s)$, $F_s:=L(\pi_s)$.
  * (a) For every τ > 1, $D$ has a right kink of flatness τ and window $(b+\kappa)/(\tau-1)$ at $(\ell_s,F_s)$. Every λ-MAP, λ > 1, has $\ell\le\ell_s+(b+\kappa)/(\lambda-1)$ and $L\ge F_s-\lambda(b+\kappa)/(\lambda-1)$.
  * (b) Suppose also that $L(\pi)\ge F_s+\sigma(\ell_s-\ell(\pi))$ whenever $\ell(\pi)<\ell_s-w$. Then for every $\lambda\in(1,\sigma)$ every λ-MAP $\hat\pi$ satisfies
    $$\ell_s-w\le\ell(\hat\pi)\le\ell_s+\frac{b+\kappa}{\lambda-1},\qquad F_s-\frac{\lambda(b+\kappa)}{\lambda-1}\le L(\hat\pi)\le F_s+\lambda w,$$
    and $\hat\pi$ is product-$(b+(\lambda-1)w)$-sufficient.
  * Sufficiency alone gives only σ = 1 to the left, and then the interval (1, σ) is empty. The content of (b) is a left steepness σ > 1.
* **(B4) The converse** [proved, refereed: kink Thm 3.4]. Let $0\le\tau<\sigma\le\infty$. Every λ-MAP with λ ∈ (τ, σ) has length in $[\alpha',\alpha'']$ if and only if $D$ has a zero-window left kink of steepness σ at a point of length at least $\alpha'$ and a zero-window right kink of flatness τ at a point of length at most $\alpha''$. These points can be taken to be hull vertices.
* **(B5) A universal member flattens every kink** [proved: kink Prop 3.5; (i) refereed, (ii) post-referee (§8)].
  * *Hypothesis.* The class contains $\pi_U$ with $L(\pi_U)\le L(\pi)+\ell(\pi)+\kappa_0$ for all π: (Dom) on one data set.
  * (i) Every left kink (σ, w) at $(\alpha_k,F_k)$ with $\alpha_k-w>\ell_U$ has $\sigma\le1+(\ell_U+\kappa_0)/(\alpha_k-\ell_U)$.
  * (ii) Every λ-MAP, λ > 1, has length at most $\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$. This is `thm:absorb:absorption`(a).
  * A sentence of kink's notes that derived a λ-independent cap is **[refuted]**: kink Prop 3.5, after it.

**The general form (teacher Lemma 1.1)** [proved: the original form refereed; the final form, with a real offset $g$, a pointwise margin and item (iv), post-referee, following the referees' own corrections A m1, m2, m5, B-m8; computed: teacher t7(A); rB1(A) on the original form].
* Let the reference $(\alpha_0,F_0)$ be bounded: some program has $\ell\le\alpha_0$ and $L\le F_0$. Let $M\sqcup N$ partition the programs.
* Let every π ∈ M satisfy a **right line** $(\tau,g)$, $\tau\ge0$, $g\in\mathbb R$: $L(\pi)\ge F_0-g-\tau(\ell(\pi)-\alpha_0)$, with $\ell(\pi)\ge\ell_M$ for some $\ell_M\le\alpha_0$.
* Fix $c>\tau$ and $\epsilon\ge0$, and let every π ∈ N satisfy $J_c(\pi)>c\alpha_0+F_0+\epsilon$ (a pointwise margin; teacher's $J'_c$, which equals $J_c$ in the data reading).
* Then every π with $J_c(\pi)\le\Phi(c)+\epsilon$ lies in $M$ and has
  $$\ell(\pi)\le\alpha_0+\frac{g+\epsilon}{c-\tau},\qquad L(\pi)\ge F_0-\frac{cg+\tau\epsilon}{c-\tau}.$$
* (B2)(a),(b), up to windows, and (B3) are its special cases (teacher Remark 1.3).
* What only the general form provides is what the teacher theorem needs: a left set $N$ defined by a property ("does not know the model"), and an anchor that is not attained.

**Right lines and right secants** [proved, post-referee: teacher Def 1.4, Lemma 1.5].
* A right line bounds long programs: a program $x$ bits beyond the reference has secant at most $\tau+g/x$.
* The right secant decides whether the reference itself survives: for λ below it some longer program wins, and for λ above it none ties.
* Statements of the form "right flatness 1 at every $n$", in all three records, mean the line, not the secant (teacher §7.4(b), iid §9.4(c)).

**Reading** [remark: kink §6, Remark 3.6].
* Along the hull, the λ-MAP keeps exactly the blocks of program bits whose edge rate exceeds λ bits of fit per bit. This holds for blocks along hull edges, not for individual bits.
* A model component worth keeping explains σ ≫ 1 bits per bit. Beyond a sufficient program the hull descends at most $1+(b+\kappa)/\Delta$ bits per bit over Δ further bits (kink Remark 2.5), so λ > 1 refuses to buy noise.
* The split need not be unique. Several vertices with $\sigma_i>1$ give different models for different λ, for example a parity plus a structured error rule (kink §4 illustration; teacher §4).
* *Novelty.* The hull–penalty relation is standard convex geometry in two dimensions [known]. Whether Vereshchagin–Vitányi (2004, 2010) state it for set models is **[open]** as a literature question (kink §7). New, as far as the project's records show: the kink vocabulary, (B3) as the single-data-set split, the converse (B4), and (B5).

### 2.3 Third: the bridge. A sample has a kink at the shortest equivalent length

**Theorem C** (PQ; setting of Theorem A) [proved: kink Lemmas 5.1–5.3, Thm 5.4, Cor 5.7, refereed in the without-replacement scheme (wor) and restated for (pq) after the referees' major issue, post-referee in that form; iid Lemma 8.1].
* **(C1) Uniform likelihood-ratio bound.** For each $n$ and ε ∈ (0, 1), with probability at least 1 − ε, simultaneously for all π,
  $$L_n(\pi)-L_n(\nu)\ >\ 2\log e\cdot n\,\Hel_\mu(\pi)-2\ell(\pi)-2\log(1/\varepsilon).$$
* **(C2) Left kink, steepness linear in n.**
  * On the event of (C1), $(\ell_0,L_n(\nu))$ is a zero-window left kink of steepness $\sigma_n:=\min_{\ell<\ell_0}\big(2\log e\cdot n\gamma_=(\ell)-2\ell-2\log(1/\varepsilon)\big)/(\ell_0-\ell)$, when $\sigma_n>0$.
  * If $A:=2\log e\cdot n\gamma_--2\log(1/\varepsilon)\ge2\ell_0$, then $\sigma_n\ge A/\ell_0$. Without $A\ge2\ell_0$ this second form fails (kink rA(5)).
* **(C3) Right kink.**
  * With probability at least 1 − ε, for every τ > 1, a right kink of flatness τ and window $(\ell_0+\log(1/\varepsilon))/(\tau-1)$.
  * For all $n$ at once, with δ* in place of $\log(1/\varepsilon)$.
  * **The $\ell_0$ in the window cannot be dropped** [proved, post-referee: iid Lemma 8.1(iv), from referee B's B2]. In iid's class $\mathcal C_{k,M}$ at $n=M-5$ the excess over a slope-1 line is exactly $k-7$ bits with probability at least 31/32. "Each bit of length buys at most one bit of fit, plus δ*" is **[refuted]**.
* **(C4) A vertex, and the λ-MAPs exactly.** Let $\bar\ell>\ell_0$ and $n>(\bar\ell+\log(1/\varepsilon))/(\log e\cdot\gamma_{\bar\ell})$. With probability at least 1 − 2ε:
  * $\rho=L_n(\nu)$ on $[\ell_0,\bar\ell]$;
  * every right secant is below $\tau_{\bar\ell}:=1+(\ell_0+\log(1/\varepsilon))/(\bar\ell-\ell_0)$;
  * if $\sigma_n>\tau_{\bar\ell}$, then $(\ell_0,L_n(\nu))$ is a hull vertex, and for every $\lambda\in(\tau_{\bar\ell},\sigma_n)$ the set of λ-MAPs is exactly $E_0$.
* **(C5) Almost surely.**
  * The left steepness grows linearly: $\liminf_n s_-(n)/n\ge2\log e\cdot\min_{\ell<\ell_0}\gamma_=(\ell)/(\ell_0-\ell)$.
  * Eventually $s_+(n)<1<s_-(n)$: **λ = 1 lies strictly inside the kink** [proved, post-referee: kink Cor 5.7(d), from Theorem A(a) and (B1)].
* **Reading.**
  * Theorem C is Theorem A in the geometry of Theorem B. The model is the hull vertex at the shortest equivalent length.
  * To its left, each bit of model explains a number of bits of data that grows linearly in $n$. To its right, a bit of program buys at most about one bit of sampled noise.
  * The finite-sample forms of the two routes agree. At kink's per-query noisy parity ($\ell_0=19$, guarantee 0.90) Theorem A(d) needs $9.14\cdot10^4$, $6.10\cdot10^4$, $1.22\cdot10^5$ and $2.44\cdot10^5$ samples at λ = 1.5, 2, 4, 8. Kink Cor 5.5 needs $9.14\cdot10^4$, $6.10\cdot10^4$, $1.11\cdot10^5$ and $2.10\cdot10^5$ [computed: s1(B)]. The paper should carry one of them: Theorem A(d).
  * Every guarantee holds in simulation where its hypothesis holds (200 of 200 samples, $n$ up to $2^{20}$) [computed: kink k6(D)].
* **Frozen labels.** With frozen labels and an atomic μ the evidence bound behind (C1) fails, and so does (C4)'s identification [refuted in the frozen reading: kink Prop 5.10; counterexamples of both kink referees]. What survives is the fixed-domain form (fd), conditional on the domain, with evidence $\sum_{x\in\dom D}\Hel_x(\pi)$ (kink Remark 5.4′).

### 2.4 Fourth: the noisy random parity. Product models have a kink at the parity; set models do not

The instance is `def:teacher:instance` with $m=d$, $B=\infty$ and the full truth table. Frozen noise at rate $p$ on $\{0,1\}^d$, given that exactly $pN$ inputs are flipped, is exactly this $m=d$ error set.

**Theorem D** [proved, refereed: kink Props 4.1, 4.2(i), 4.4, Cor 4.3; Prop 4.2(ii) (the interval form) and item (g) post-referee; computed: kink k4, k7 (certified intervals), rB2, rB4].
* **(D1) A left kink at the good model** (kink Prop 4.1).
  * Put $\Gamma^\circ_t:=\max\{G_t,F^\sharp_t(d+\kappa)\}$, with the sharp floor $F^\sharp_t$ of `lem:teacher:sharpfloor`, and
    $$\sigma^{(t_0)}:=\inf_{t\ge t_0}\frac{N(\Gamma^\circ_t-H(p))}{\kappa_g+\min\{d,\ s(t+1)+\Lambda_1\}}.$$
  * If $\sigma^{(t_0)}>0$, the full table has a left kink of steepness $\sigma^{(t_0)}$ at $(\ell_g,NH(p))$, with window at most $\kappa_g+s(t_0)+\Lambda_1$.
  * The good model is product-$b_0$-sufficient, with $b_0=\kappa_g+(NH(p)-L_E)+\delta_E+2\log(d+1)+\kappa$.
  * The steepness is exponential in $d$ when $\Gamma^\circ_{t_0}>H(p)$.
* **(D2) The λ-range on which every λ-MAP is "parity + noise"** (kink Prop 4.2). The class must contain a good model. Under an explicit condition $C_{t_0}(\lambda)$, every λ-MAP:
  * has agreement level at most $t_0$, so $K(a\mid\hat\pi)\le s(t_0)+2\log d+\kappa$: it knows the parity;
  * has length in $[d-s(t_0)-\Lambda_1,\ d+\kappa_g+(b_0+\kappa)/(\lambda-1)]$;
  * fits like noise within explicit slack;
  * is product-$(b_0+(\lambda-1)(\kappa_g+s(t_0)+\Lambda_1))$-sufficient;
  * holds at most $I_e$ bits about the flip set, and gives the flips probability at most $1-u+\gamma_g(I_e)+2^{-g}$.

  The set of λ satisfying $C_{t_0}(\lambda)$ contains certified intervals [computed: k7]. Examples, with κ = 0 rows as illustrations:

  | $p$ | $d$ | κ | level $t_0$ | certified λ-range |
  |---|---|---|---|---|
  | $2^{-10}$ | 20 | 0 | 1 | $(1,11944.9]$ with the floors $G_t$; $(1,12008.5]$ with the sharp floor (the paper's window is $(1,11945)$) |
  | $2^{-10}$ | 30 | 0 | 1 | $(1,9.979\cdot10^6]$; sharp floor $(1,1.0048\cdot10^7]$ (paper: $Nc_{\rm hi}=9.791\cdot10^6$) |
  | 1/16 | 100 | 30 | 1 | $(1,1.589\cdot10^{27}]$ |
  | 1/8 | 20 | 0 | 2 | $[1.00059,6530]$ |
  | 15/64 | 20 | 30 | 2 | $[1.3422,199.8]$ |
  | 15/64 | 100 | 0 | 2 | $(1,6.896\cdot10^{26}]$ |

* **(D3) Every flip rate below 1/4, asymptotically** (kink Cor 4.3). Fix $p<1/4$ with bounded $K(p)$ and λ > 1. Let $d\to\infty$ with $\delta_E=O(d)$ and $pN$ an integer. Then for all large $d$ every λ-MAP has level at most 2, and level 1 if $p<0.12331$. The constants 0.05596, 0.12331 and $\min(f_2-H)\ge0.0187$ were rechecked in s1(D).
* **(D4) Set models have no steep kink at α ≈ d** (kink Prop 4.4). Every left kink of the set structure function with $\alpha_k-w>c^*:=2\log d+2\log r+\kappa$ has steepness at most $1+(c^*+\delta_E+2\kappa)/(\alpha_k-c^*)$.
  * So for $\lambda-1\gg(c^*+\delta_E+2\kappa)/(d-c^*)$ the set λ-MAP holds far fewer than $d$ bits about the parity.
  * For λ within $O((\log d+\delta_E)/d)$ of 1 the code's $O(\log d)$ terms decide. Under an Elias code the parity-knowing set is a set-hull vertex up to λ = 1.36 at $d=30$ [computed: k8(D), rB2]. The reading "the set λ-MAP treats the parity as noise for all λ ∈ (1, 27.5)" is **[refuted as code-independent]**.
* **Reading.**
  * (D2) contains the window $(1,Nc_{\rm hi})$ of `cor:teacher:fulltable` for $p<0.056$, and agrees with it to the printed digits at $d=20$.
  * (D3) extends the full-table identification to every $p<1/4$. This is the full-table half of `q:teacher:open`(b).
  * The product split keeps the parity's $d$ random bits as model, because not knowing them costs about one bit per input. The set split treats them as noise, because a set model shares its randomness.

### 2.5 Fifth: the map of what fails, and what is necessary

| hypothesis dropped or changed | what happens | status | where |
|---|---|---|---|
| private randomness (a class with a universal member) | no sampler longer than $\ell^*_\lambda$ is ever a λ-MAP; every left kink beyond $\ell_U$ has steepness at most $1+(\ell_U+\kappa_0)/(\alpha-\ell_U)$ | proved, refereed | `thm:split:shared`; kink Prop 3.5; iid Prop 7.1 |
| labels redrawn per query → frozen per distinct input (FR) | no procedure recovers every sampler a.s. eventually. Example: λ-MAP wrong with probability exactly 0.1457 for λ < 1.5 on 10 inputs | proved, refereed | iid Props 7.5, 7.6(d) |
| | survives: on the run, every λ ≥ 1, any input rule; fill-ins' posterior → 0 when $\sum_x\beta_x=\infty$; length within $(k+\delta^*)/(\lambda-1)$ at every $n$; finite-sample identification on large uniform domains | proved, post-referee (Prop 3.3, Remark 7.7, teacher Prop 3.7(a)); refereed (Prop 7.6(b)) | iid Props 3.3, 7.6, Remark 7.7 |
| i.i.d. inputs → adaptive or fixed non-i.i.d. sequence | with positive probability the eventual MAP is a shorter program that differs from ν at every queried input; on-the-run identification survives | proved, refereed | iid Prop 7.2 |
| ν in the class → misspecified | "the λ-MAP is eventually a shortest KL-projection" is **refuted** for fixed λ: oscillation between projections (PQ), and fill-ins for λH(p) < 1 (FR). It holds in finite classes for $\lambda_n/\sqrt{n\log\log n}\to\infty$, $\lambda_n=o(n)$, a sharp rate | proved; (iii′), (v) post-referee | iid Prop 7.3; Conj 7.4 open |
| $\lambda_n=o(n)$ → λ = cn | exact recovery for $c<c^*:=\min_{\ell(\pi)<\ell_0}D(\pi)/(\ell_0-\ell(\pi))$, failure for $c>c^*$; $c=c^*$ not covered; in general the cn-MAPs end in $\arg\min(c\ell+R)$ | proved; (b), (c) post-referee | iid Prop 3.4 |
| a margin γ | no sample size from $(\lambda,\ell_0,\varepsilon)$ alone; the factor 1/γ is necessary | proved, refereed | iid Props 4.2, 4.4(a); kink Prop 5.8 |
| λ > 1 → λ ↓ 1 or λ = 1 | the factor 1/(λ−1) is necessary, also in the length bound; at λ = 1 no class-free rate | proved; Remarks 4.5, 4.7 and Prop 5.1(b′) post-referee | iid Prop 4.4(b), Remarks 4.5, 4.7, Prop 5.1 |
| concentration on $E_0$ | refuted: the posteriors concentrate on $E$ with the prior's shape | proved, refereed | iid Thm 3.2 |

### 2.6 The brief's questions, answered

| brief item | answer | status |
|---|---|---|
| T1 setting: repeats | per-query labels (PQ), the terms of $\Mpq$; FR treated separately | iid Remark 1.4 |
| T1: every λ-MAP eventually a shortest equivalent program | yes, for every $1\le\lambda_n=o(n)$, λ = 1 included | proved (Thm A(a)) |
| T1: posteriors concentrate on that set | **refuted**; they concentrate on all equivalent programs | proved (Thm A(b)) |
| T1: fill-ins' posterior → 0 exponentially in the sampled randomness | yes, for fixed λ > 1, at every $n$ | proved (Thm A(c)) |
| T1: finite sample with a margin; explicit $n(\lambda,k,\gamma,\varepsilon)$ | yes, with $\ell_0$ in place of $k$; also a free-exponent form | proved (Thm A(d)) |
| T1: λ = 1 contrast, "λ = 1 never makes the split exact" | **refuted** in PQ asymptotically; true in FR, but there for every λ and every procedure; the real contrast is the rate: $\Theta(2^{\ell_0/2})$ against $\Theta(\lambda\ell_0/(\lambda-1))$ in a parity class | proved (iid Props 5.1, 5.3, 7.5) |
| T1: what the λ = 1 MAP is | eventually in $E_0$ (PQ); at finite $n$ possibly a fill-in of length about the sampled randomness | proved (iid Prop 5.3) |
| T1: noisy computable functions | $f$ and the exact rate $p$ in PQ; frozen rate wrong with probability 0.20–0.57 in a small instance | proved (Cor A′) |
| T1: time-bounded and circuit classes | every countable Kraft subclass; "shortest" in the subclass's code | proved (iid Cor 6.2) |
| T1: what fails | §2.5 | — |
| T2: λ-MAPs on the hull; ties; existence | yes, exactly (vertices, closed edges, Legendre duality) | proved (B1) |
| T2: the kink theorem; "cleanest true statement" | (B3) for one data set, with its converse (B4); the general form is teacher Lemma 1.1 | proved |
| T2: noisy parity λ-range; comparison with the teacher's window | certified ranges for every $p<1/4$; they contain the paper's window | proved, computed (Thm D) |
| T2: set models have no kink at α ≈ d | steepness at most $1+O((\log d+\delta_E)/d)$; code-dependent near λ = 1 | proved (D4) |
| T2: link to T1 | yes, in PQ, with steepness linear in $n$ | proved (Thm C) |
| T2: "the model consists of the bits that each explain more than λ bits of data" | true in hull-averaged form, for blocks along hull edges | remark (kink §6) |
| T3 | §4 | — |
| anything else: margin and λ > 1 necessary; non-unique split | iid Props 4.2, 4.4, Remark 4.5; several hull vertices with $\sigma_i>1$ (kink Remark 3.6, two kinks) | proved; computed |

---

## 3. How the existing results of Paper 2 fit around the new ones

### 3.1 The geometric picture that organises them

With Theorem B and teacher Lemma 1.1, every split statement of Paper 2 has the same form [remark, from the cited proved results]:
* there is a reference point in the (length, fit) plane;
* to its left, programs that do not contain the model lose at least σ bits of fit per bit of length saved;
* to its right, a line of slope τ bounds what extra length can buy;
* every λ (or $c=\lambda/n$) strictly between τ and σ selects the reference, up to explicit windows.

The theorems differ in τ, in σ and in what they put in the windows:

| result | reference point | left steepness σ | right line τ (per unit of the objective) | λ-range |
|---|---|---|---|---|
| Theorem A / C (PQ sample) | $(\ell_0,L_n(\nu))$ | linear in $n$ (C2) | 1, offset $\ell_0+\delta^*$ (Ville) | fixed λ > 1; every $\lambda_n=o(n)$ in the limit |
| `thm:split:private`(i) (FR, any input rule) | $(k,-\log\nu(D_n))$ | not used (length bound only) | 1, offset $k+\delta^*$ | λ > 1 |
| (B3) / `prop:algstat:product` (one data set) | a $b$-sufficient program | assumed | 1, offset $b+\kappa$ (coding bound) | (1, σ) |
| Theorem D (full noisy-parity table) | the good model | $\sigma^{(t_0)}$, exponential in $d$ | 1, offset $b_0+\kappa$ | certified ranges inside (1, σ) |
| `thm:teacher:main` (population) | $(d+\kappa_g,H(p))$ | $c_{\rm hi}$ (a wedge) | $2^{-m}$ per sample, offset $\Lambda_2/2^m$ | $c\in(2^{-m},c_{\rm hi})$ |
| full table, every $m$ (teacher Prop 3.1) | $(d+\kappa_g,NH(p))$ | $Nc_{\rm hi}$ | $2^{d-m}$, offset $2^{d-m}\Lambda_2$ | $\lambda\in(2^{d-m},Nc_{\rm hi})$ |
| shared classes (`thm:absorb:absorption`, `thm:split:shared`) | the universal member | at most $1+(\ell_U+\kappa_0)/(\alpha-\ell_U)$ beyond $\ell_U$ (B5) | — | no kink beyond $\ell^*_\lambda$ |

The right slope is the **reuse factor** of the material that a longer program would memorise (teacher §3.0): 1 for noise used once, $2^{d-m}$ (full table) or about $n2^{-m}$ (samples) for a junta error rule. This one number is why fixed λ > 1 suffices for noise and λ must grow like $n$ for errors (§4.2).

### 3.2 Each existing result: its relation to the new ones, and its fate

"Corollary" means that the statement follows in one or two lines from a new result, so its proof can be shortened to that. "Kept" means unchanged in substance. Labels are never renamed (REFRAME §8); a moved statement keeps its label.

**Setting (`setup.tex`, `app-setup.tex`).**
* `def:setup:data`. **Must change.** It fixes frozen noise. If Theorem A enters, the definition must name the three objects DS, FR and PQ, and the likelihood used when inputs repeat. iid §9.1 and teacher §6.1 both ask for this.
* `def:setup:product`. Kept. Its sentence on "private to each distinct input, not to each query" gains the PQ reading: per query the product law of a program is its term in $\Mpq$.
* `lem:setup:hull` (population hull) and kink Thms 2.1–2.2, Prop 2.3 (data hull). **Merge** into one statement with two readings: normal $(c,1)$ on $(\ell,R)$, and normal $(\lambda,1)$ on $(\ell,L(\cdot;D))$. The statement goes to the main text, the proofs to the appendix. `rem:setup:hullconverse` is kept.
* The sentence before `lem:setup:coding`, "so for the example of Section 5 the question is whether the good model is a vertex", **must change**. In explicit rate codes the good model is not a vertex on the whole window [refuted as stated: teacher §2.1, "What is selected"]. The question becomes whether every near-optimal hypothesis knows the model and not the errors (teacher §6.1 item 4).
* `lem:setup:coding`. Kept. It gains one sentence: at every $b$-sufficient point it is a right line of slope 1 with offset $b+\kappa$ (kink Remark 2.5, Cor 3.3(a)).

**Absorption (`absorb.tex`, `app-absorb.tex`).**
* `thm:absorb:absorption`. Kept. Its part (a) is (B5)(ii) on data sets: a universal member caps every λ-MAP. Add one sentence with (B5)(i): with shared randomness no left kink steeper than $1+(\ell_U+\kappa_0)/(\alpha-\ell_U)$ exists beyond $\ell_U$.
* `thm:split:shared`. **Corollary** of `thm:absorb:absorption`(a) (its proof already is). Move it into the absorption section, as "no split with shared randomness".
* `prop:absorb:pricing`, `cor:absorb:nouniversal`, `prop:absorb:price`, `prop:absorb:history`, `prop:absorb:inputs`, `rem:absorb:condsemi`, `rem:absorb:examples`. Kept.
* `rem:absorb:why`, `rem:absorb:reading`, `rem:absorb:wyeth`. Kept, shortened.

**The split (`split.tex`, `app-split.tex`).**
* `def:split:setting`. **Rewrite.** It must state the object (FR with any input rule, as now), and distinguish $k$ (a program equal to ν everywhere), $\ell_0$ (shortest μ-a.e. equivalent) and $k_\nu$ (a decoder that is a measure where it decodes) (iid Def 1.2).
* `lem:split:ville`. Kept. Its proof already covers per-query likelihoods and any input rule (iid Lemma 2.2(c)); say so. The current deficiency $\delta_n$ (iid Lemma 2.2) may be added.
* `thm:split:lambda1`. Kept, as the finite-$n$ λ = 1 statement on data sets with distinct inputs. Part (iv), the hashing alternative, can be **cut**: its costs are 32–143 bits against 5.6–8.9 bits for the stream lemma at every computed size (`app:split:hash`). The new results put it in context: in PQ the 1-MAP is nevertheless eventually exact (Theorem A(a)), but at a rate that depends on the class (iid Prop 5.1, Remark 4.7).
* The opening of `sec:split`, "At λ = 1, Solomonoff induction has no preference between the two", **must be qualified**. At finite $n$ the posterior odds are balanced (`thm:split:lambda1`). In the limit the 1-MAP is exact in PQ (Theorem A(a)) and identifies ν on the run in FR (iid Prop 3.3). (Flag of iid Prop 3.3, remark.)
* `thm:split:private`.
  * (i)–(iii) are **kept** as the statement for FR and every input rule. In PQ they are Theorem A(c), with $\ell_0$ in place of $k$ (iid Thm 4.1, Def 1.2).
  * The length bound in (i) becomes a **corollary** of the kink lemma: a right line of slope 1 with offset $k+\delta^*$, and $N=\emptyset$ (teacher Prop 2.3).
  * (iv) **must be restated for λ ≥ 1** (iid Prop 3.3). Its proof uses λ > 1 only to confine the MAPs to a finite set, and the prior's Kraft tail does that at λ = 1 too.
* `rem:split:reading`. **Rewrite.** It is no longer the paper's main split statement. It should say what (i)–(iv) give in FR, and point to Theorem A for exact recovery in PQ and to iid Prop 7.5 for why FR allows no more.
* `lem:split:stream`, `prop:split:si`, `ex:split:noisyparity`, `rem:split:siprograms`. Kept.
* `lem:split:hash`. **Cut** with `thm:split:lambda1`(iv), or keep it unchanged if the appendix budget allows (§5.4).

**Algorithmic statistics (`algstat.tex`, `app-algstat.tex`).**
* `def:algstat:product`, the product structure function. **Move** to the kink section: it is the object on which Theorem B is stated.
* `prop:algstat:product`. **Corollary** of (B3)(a), with $\pi_s$ a program attaining $\sophx_b(D)$. One line.
* `prop:algstat:parity`.
  * (ii) and (iv) are **superseded** by Theorem D. Kink Prop 4.1 turns the cliff "$\rho^\times_D\ge NG_1$ below $d-4-\Lambda_1$" into a steepness. Kink Prop 4.2 and Cor 4.3 add what the proposition lacks: λ-ranges for the λ-MAP, with identification, for every $p<1/4$.
  * (i) (sets) and (iii) (the gap $d-O(\log d)$) are **kept**. (D4) adds the quantitative set-steepness bound.
  * The sophistication bounds of (ii) and (iv) can stay as one sentence of (iii).
* `tab:algstat:numbers`. **Replace** by a short table of certified λ-ranges (k7), or keep it in the appendix.
* `def:algstat:set`, `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc`, `rem:algstat:restricted`, `rem:algstat:reading`. Kept.
* The noisy parity of `sec:algstat:parity` and the teacher's $m=d$ case are the same instance. State the kink once and cite it from both threads (teacher §6.2 item 4).

**The teacher (`teacher.tex`, `app-teacher.tex`).** See §4 for the content.
* `thm:teacher:main`. Kept. Parts (i), (ii)(b) and (ii)(c) are one application of the kink lemma, with τ = $2^{-m}$, $g=\Lambda_2/2^m$ and $\ell_M=d-4-\Lambda_1$ (teacher Prop 2.1). This **shortens** its proof: $\psi_c$, $\Phi_1$ and the case analysis of (ii)(b) go. Part (ii)(a) gains (a1) of teacher Remark 2.6.
* `rem:teacher:hypotheses`. **Replace** by teacher Table 2.2, which says which kink side each hypothesis serves.
* `cor:teacher:fulltable`.
  * (i) becomes the $m=d$ case of the every-$m$ full-table statement, with window $\lambda\in(2^{d-m},Nc_{\rm hi})$ (teacher Prop 3.1). The label stays on the every-$m$ statement.
  * (ii), the tie at λ = 1, merges with the λ = 1 discussion of the split. Both reference points sit on a line of slope 1 (teacher Prop 2.4(iii)).
* `q:teacher:open`(b) is **answered** for $p<0.1233$ in population form (teacher Props 5.2–5.3). It stays open for $0.1233\le p<1/4$ in the junta case.
* The four lemmas, `lem:teacher:sharpfloor`, `def:teacher:instance`, `rem:teacher:hanni`, `rem:teacher:numbers`, `tab:teacher:numbers`, `cor:teacher:sampled`, `lem:teacher:finite`, `prop:teacher:concentration`, `ex:teacher:version1`. Kept. The instance and the four lemmas move to the noisy-parity section, which both threads use (section P7 of the plan, §5.1).

**Limits (`limits.tex`, `app-limits.tex`).**
* `prop:limits:plain`. Kept. Teacher Prop 3.2(a), (c) is its PQ form for every label channel.
* `rem:limits:schedule`. **Replace** by teacher Prop 3.6 (which schedules keep the identification) and the reuse factor. Keep its literature sentences and the batch-excess sentence.
* `prop:limits:envelope`. Part (i) becomes a **corollary**: Lemma 1.1(iv) with the envelope's point as reference (teacher Prop 2.1(d)). Part (ii) keeps its proof. Teacher Prop 4.1 adds the reading: the envelope's secant $c_{\rm env}$ raises the lower end of the window.
* `prop:limits:rateblind`. Part (ii) becomes a **secant comparison**: the memoriser's secant is at least the coin's (teacher Prop 4.2). Its proof shortens.
* `lem:limits:robust`, `prop:limits:ood`. Kept.
* `prop:limits:separable`, `prop:limits:guard`, `prop:limits:inputlaw`, `prop:limits:noident`. Kept, presented together as one remark on what a hull cannot see (teacher Remark 4.3).
* `rem:limits:method`. **Replaced** by teacher §5 if adopted. Otherwise reword it: "the information of competitors that do not know the model is not charged" (teacher §6.2 item 9).
* `q:limits:open`(b) is **answered** for the population objective (teacher Prop 5.3, and the exact windows at the example's sizes). Parts (a) and (c) stay open.

**Computable classes (`computable.tex`).**
* `prop:related:computable`. Kept. It gains a part: Theorem A holds in every countable Kraft subclass, with "shortest" in the subclass's own code (iid Cor 6.2).
* `rem:computable:examples`, `prop:related:computability`, `rem:related:nn`, `q:related:open`. Kept.

### 3.3 Statements in the current text that the new results contradict or qualify

These are not errors in the current paper's theorems. They are sentences whose reading the new results change.
1. `sec:split`, opening: "At λ = 1, Solomonoff induction has no preference between the two". True at finite $n$, as `thm:split:lambda1` says. In the limit, λ = 1 identifies: exactly in PQ (Theorem A(a)), on the run in FR (iid Prop 3.3).
2. `thm:split:private`(iv) is stated for λ > 1 but holds for λ ≥ 1 (iid Prop 3.3).
3. `setup.tex`: "the question is whether the good model is a vertex". The theorem does not say this, and in explicit rate codes the rate-$p$ program is the minimiser on only 68–89% of the window's logarithmic width [computed: teacher t5(A), independently rA1(A)].
4. `rem:limits:schedule`: "steeper selection needs λ = Θ(n)". This is true for the teacher's errors, but the reason is the reuse factor. For noise in PQ or FR a fixed λ > 1 suffices. For frozen noise counted per query (FQ) λ must grow like $n/N$ (teacher Prop 3.7).
5. Intro, table row "Can the good model … be selected …, as a vertex of the convex hull?" answers "Yes". It should become "every near-optimal hypothesis knows the model and not the errors", as in item 3.
6. `discussion.tex`, "The model–randomness split": "For fixed λ > 1 a steeper prior … breaks the tie in favour of samplers, in the limited sense of `rem:split:reading`". With Theorem A the paper can say more in PQ: exact recovery with class-free rates.
7. Paper 1's `steeper.tex` (a prose summary of Paper 2, with no numbers) describes Paper 2's results in the old order. It needs one sentence on Theorem A. Paper 1's numbering is frozen; text edits are allowed (REFRAME §8).

---

## 4. The teacher's-mistakes thread: the split at a positive rate

This section follows teacher §§1–6. Every statement there is proved or computed as marked; this section adds no claim.

### 4.1 One kink lemma, two slopes

* **The teacher theorem is the kink lemma with τ = $2^{-m}$** [proved, refereed: teacher Prop 2.1; computed: t1(B), rB2(E)].
  * *Population reading.* Reference $(d+\kappa_g,H(p))$, bounded by the good model $\pi_g$. Left set $N$: programs of level ≥ 2 (they do not know the parity). $M$: level 1.
  * *Left.* Every program of level ≥ 2 lies above a wedge with apex at the reference, steepness $c_{\rm hi}$ and flat margin $G_1-H(p)$.
  * *Right.* (D1)–(D2) give a right line of slope $2^{-m}$ per sample, anchored at $(d-4-\Lambda_1,B_S/2^m)$, with offset $g=\Lambda_2/2^m\ge0$.
  * Lemma 1.1 then gives `thm:teacher:main`(i), (ii)(b) and (ii)(c) with the paper's constants, to relative error $2.4\cdot10^{-14}$ over 17,411 parameter sets [computed: t1(B)].
* **The private-randomness split is the same lemma with τ = 1** in total bits [proved, refereed: teacher Prop 2.3]. For $m=d$ on the full table, the teacher's right condition is the sufficiency line, and it improves the paper's length bound from $\Lambda_2$ to $b_0=\Lambda_2-4-2\log d$ (teacher's $b_0$, with $2\log d$; §7.2) [proved, refereed: teacher Prop 2.4].
* **The two deficiencies play the same role** [remark: teacher Remark 2.5]. The Ville deficiency δ* of the sampled noise and the randomness deficiency $\delta_S$ of the error rule both enter as the offset of the right line, and both have a $2^{-j}$ tail. A compressible "noise" is a model component; `prop:limits:envelope` is the teacher's case of large $\delta_S$.
* **What geometry gives, and what it does not** (teacher §2.1). Parts (i), (ii)(b) and (ii)(c) are geometry. (iv) is a secant statement and (iii) the side below the line's slope. The meaning of the position is not geometry: (ii)(a) uses the risk floor, (ii)(d) list decoding and symmetry of information, (ii)(e) Hoeffding's coding argument.

### 4.2 Why the errors need λ ∝ n and the noise does not: the reuse factor

* **Definition** (teacher §3.0). The reuse factor of a unit of noise or of an error rule is the number of likelihood terms whose value it determines.
* **Duplication lemma** [proved, post-referee: teacher Lemma 3.0; computed: t7(C)]. If every likelihood term of a data set is repeated $r$ times, the λ-MAPs are the $(\lambda/r)$-MAPs of the data set, and every λ-threshold (hull slopes, kinks, lines, secants, windows) is multiplied by $r$.
* **Full tables, every m** [proved, refereed: teacher Prop 3.1; (c) post-referee]. For every $\lambda\in(2^{d-m},Nc_{\rm hi})$ every λ-MAP satisfies `thm:teacher:main`(ii) with $c=\lambda/N$. For $\lambda<2^{d-m}\theta_m$ the memoriser beats every level-1 program that fits no better than noise. The right line has slope $2^{d-m}$, the number of inputs per cell. Every line flatter than the memoriser's secant needs an offset of order $2^{d-m}(1-\rho)L_S$.
* **Which object** [proved, post-referee: teacher Prop 3.7; computed: t5(D), rB5].
  * In PQ and in FR (Paper 2's likelihood) one label of noise has reuse factor 1 at every $n$, repeats or not.
    * In PQ every $1\le\lambda_n=o(n)$ recovers the sampler (Theorem A(a)).
    * In FR every fixed λ > 1 keeps the λ-MAP within $(k+\delta^*)/(\lambda-1)$ bits of the sampler at every $n$, and a program that memorises noise at finitely many atoms gains a bounded number of bits.
  * Counted per query against the frozen table (FQ), the noise at $x$ is reused $N_n(x)\approx n\mu(x)$ times. If the class contains a program that agrees with ν off a finite set of atoms and memorises the table there, every $\lambda_n=o(n)$ eventually rejects every program for ν (teacher Prop 3.7(b)), as for an error rule with $m=d$.
  * In t5(D), FR keeps frozen noise at λ = 2, 8 and 20 at every $n$ tested. FQ memorises it once the multiplicity times θ exceeds λ, at the switch points Lemma 3.0 predicts.
* **The answer to the brief's question** [remark, from teacher Props 3.1, 3.2, 3.6, 3.7]. Each bit of a junta error rule is reused at every input of its cell, about $n2^{-m}$ times on $n$ samples, so memorising it buys about $n2^{-m}\theta_m$ bits of fit per bit, and λ must exceed that. Noise is used once, its right line has slope 1, and fixed λ > 1 suffices.
* **Sampled data** [proved: teacher Prop 3.3(a), (b) for equal cell multiplicities; conjecture with computed evidence for unequal ones].
  * The good model is beaten at every λ below about $\max\{1,n2^{-m}\theta_m\}$. The "1" needs the canonical class's covering fill-in.
  * With equal multiplicities $\bar n$ there is a right line of slope $\bar n$.
  * The lower end of the λ-set tracks the mean multiplicity of the sampled error cells [conjecture; computed: t2(B), t5(C), rB4]. The claim "the effective slope can approach the largest multiplicity" is withdrawn.

### 4.3 What the teacher theorem says, and what it does not

* It is a statement about the **near-optimal set** $\mathcal N_\epsilon(c)$: every member knows the parity, is at most $\Delta_\ell$ bits longer than $d$, fits no better than noise up to slack, holds little information about the rule and does not predict the errors.
* "The good model is an interior vertex of the population hull whose λ-interval contains $(2^{-m},c_{\rm hi}]$" is **[refuted as stated]**: false in two explicit rate codes and two exact classes [computed: t5(A), t5(B), rA1(A), rB3(A)]. In $\Hcl{\times}$ the relative lengths of rate codes depend on the reference machine, and nothing is claimed either way. The programs selected instead (nearby rates) satisfy every conclusion of (ii).
* **A free sharpening** [proved, post-referee: teacher Remark 2.6, from referee B's B-m2; computed: t6(C),(D), rB8]. (D1) at level 1 gives $R_B\le R_{\max}:=c(\kappa_g+4+\Lambda_1)+H(p)+\epsilon$. Then:
  * (a1) $u\ge\max\{\frac34,2^{-R_{\max}}-p-2^{-B}\}$;
  * (a2) $u\ge(2^{-R_{\max}}-p(1+2\gamma_g+2^{1-g})-2^{-B})/(1-2p)$.

  Near the top of the window this raises $u\ge0.750$ to 0.873 at the example's sizes. (a1) can go into the paper's (ii)(a).

### 4.4 Which schedules keep the identification

[proved, post-referee: teacher Prop 3.6; Prop 3.2(d) = iid Prop 3.4(c)]
* $\lambda_n/n\to0$: in PQ, eventually every $\lambda_n$-MAP has risk 0, so it reproduces every error.
* $\lambda_n/n\to\infty$: in PQ, eventually every $\lambda_n$-MAP has length at most $\ell_{\min}$, the least length with finite risk. In $\Hcl{\times}$, $\ell_{\min}\le\kappa$, which is below the length $d-4-\Lambda_1$ of every level-1 program once $d-4-\Lambda_1>\kappa$: the MAP does not know the parity.
* $\lambda_n/n$ eventually in a compact subset of $(2^{-m},c_{\rm hi})$, with a finite truncation $B$: with probability at least 1 − δ at each $n$ (PQ, or samples without replacement), and almost surely eventually in PQ, every $\lambda_n$-MAP satisfies (ii) with a slack that tends to 0.
* λ = cn is the simplest such schedule; it is not the only one. "Only λ = cn can stop at an interior vertex" is **[refuted as stated]**.
* For noise, λ = cn recovers iff $c<c^*$, the truth's left steepness in population (iid Prop 3.4; $c=c^*$ is not covered). In both threads $c$ must lie between the slope of the side that is to be discarded and the steepness of the model's kink.

### 4.5 Structured errors make a second kink

* **Envelopes** [proved, refereed: teacher Prop 4.1; computed: t3(A), rB3(C)]. A cheap dense part of the rule adds a second drop to the structure function at about $d+k_1$. The envelope's secant $c_{\rm env}$ removes from the set $W_\epsilon$ of slopes at which a noise-like fit is ε-near-optimal every $c<c_{\rm env}$ with $J_e(c)+\epsilon<\Phi_2(c)$ and $\zeta(c)<H(p)-R_e$. In an exact class the lower end of the family's λ-set moves 15.0 → 17.1 → 42.7 → 85.3 → empty as the cheap part grows from 0 to 16 cells.
* **Rate blindness is an empty kink interval** [proved, refereed: teacher Prop 4.2; computed: t3(B), rB3(D)]. Condition (⋆) of `prop:limits:rateblind` implies that the memoriser's secant from every noise-like level-1 point is at least the coin's secant to it. In an explicit class the family's λ-set is empty from $d=13$ on ($d=12$ in referee B's class).
* **Rate, not validity** [remark: teacher Remark 4.3]. Nothing in the geometry tells the model's kink from an error's kink. `prop:limits:noident` (twin worlds) is the statement that the hull, and every rule that chooses λ from it, is the same in both worlds.

### 4.6 A new consequence: a junta window for every flip rate below 0.1233

[proved, refereed: teacher Lemma 5.1, Props 5.2, 5.3 (the range of 5.3 restated per referee A's M5; 5.3 is proved given the computed constants $p^*$ and $a^*(p)$); computed: t4, t6, rB7]
* **The information charge** (Lemma 5.1, Prop 5.2). A program of level ≥ 2 that holds $I$ bits about the rule pays $cI$ in length, while the sharp floor lets it gain only about $2p\sqrt{I\ln2/(2s_0)}$ in risk. This yields a lower bound $\Phi_2^\sharp\ge\Phi_2$ on level-≥ 2 programs. With it, `thm:teacher:main`(i), (ii) and Remark 2.6 hold on the set $\{c>2^{-m}:J_g(c)+\epsilon<\Phi_2^\sharp(c)\}$. That set need not be an interval; it is one in every computed case.
* **Asymptotically** (Prop 5.3). Fix a dyadic $p<1/4$, $B=\infty$ and $a>a^*(p)$, where $a^*(p)<\infty$ iff $p<0.12331$, and $a^*(p)=1$ iff $p<0.07787$. Let $m\to\infty$ with $d\ge m$, $d2^{-m}\to0$ and $\delta_S=o(2^m)$. Then for all large $m$ the identification of (ii) holds for every $c\in[a2^{-m},c_m]$, for any $c_m$ with $c_md\to0$. (The constants and $a^*$ at six rates were recomputed in s1(D).)
* **At the example's sizes** ($d=100$, $m=20$, κ = 0, $\delta_S=0$) the exact windows exist for $p=1/16$, 5/64, 3/32, 7/64 and 15/128, where the paper has none. For $p=1/16$ the window is $(2^{-20},2.53\cdot10^{-3}]$ (open at $2^{-20}$, since identification needs $c2^m>1$), and at $c=6.75\cdot10^{-5}$ every near-optimal hypothesis gives the erroneous labels average probability at most 0.1965 [computed: t6(B), identical to rB7(B); the bound is (a2) of teacher Remark 2.6].
* **What remains open.** Level 1 for $0.1233\le p<1/4$ is impossible with these floors. Level ≤ 2 for $p<1/4$ in the junta case is a conjecture ("routine", teacher §5).

### 4.7 The two reasons for a steeper complexity penalty, side by side

| | the split (first thread) | the teacher's mistakes (second thread) |
|---|---|---|
| what is discarded | the sampled randomness: private coins, used once | a fixed error rule, reused at every input of its cell |
| reuse factor of what is discarded | 1 (PQ, FR) | $2^{d-m}$ (full table), about $n2^{-m}$ (samples) |
| the model's kink: left steepness | linear in $n$ (Thm C); exponential in $d$ on the full parity table (Thm D) | $c_{\rm hi}$ per sample, $Nc_{\rm hi}$ on the full table |
| the λ that works | every fixed λ > 1, with class-free rates; every $1\le\lambda_n=o(n)$ in the limit (λ = 1 included, at a class-dependent rate) | λ = cn with $c\in(2^{-m},c_{\rm hi})$, or any schedule with $\lambda_n/n$ eventually in a compact subset; no $\lambda_n=o(n)$ |
| what λ = 1 does | the same limit in PQ, at a rate that can be exponentially slower in $\ell_0$ | learns the errors eventually (`prop:limits:plain`; teacher Prop 3.6(a)) |
| what defeats it | shared randomness (no kink); frozen labels (no exact recovery for any procedure); misspecification at fixed λ | structured errors (a second, steeper kink); cheap frequent rules (rate blindness) |
| what the learner is | a single Bayesian predictor for fixed λ ($\xi_\lambda$ is one shared hypothesis) | a family of batch objectives (`rem:setup:persample`) |

---

## 5. A section plan for the restructured Paper 2

### 5.0 Principles

* **Order.** The split is the main thread and comes first. It runs:
  * what counts as one hypothesis (absorption);
  * then kinks on one data set;
  * then exact recovery from samples, the headline;
  * then the noisy parity, the instance shared by both threads.

  The teacher thread follows as "the split at a positive rate". The limits close it.
* **The author's request** frames the paper as giving two reasons to be interested in a stronger complexity penalty than likelihood penalty. The introduction states both reasons, with the table of §4.7 as its backbone.
* **Binding rules (REFRAME.md).**
  * Labels are never renamed. A moved statement keeps its label, and new statements get new labels.
  * No visible text frames a result as a reply to the author's notes. Credit goes in at most five footnotes and in the acknowledgements, as now.
  * The `\status{}` and `\src{}` calls stay. New environments get `\src{}` pointers to the sub-track records (`split/iid`, `split/kink`, `split/teacher`) and to this record.
* **Statuses in the paper.**
  * The paper should mark as proved only what the sub-track records prove.
  * The post-referee results that the plan puts in the main text should get one independent check before they are published, as all other results had. These are iid Prop 3.3, Thm 4.1(iv′), Prop 5.1(b′), Remark 4.5; kink Cor 5.7(d), Prop 4.2(ii); teacher Lemma 1.1 (final form), Lemma 3.0, Props 3.6, 3.7 and Remark 2.6 (§8 lists all of them).
* **Length.** About 27 pages of main text, including title, abstract and contents. About 27 pages of appendices. Paper 2 now has 28 main pages and 27 appendix pages (`main.toc`: Discussion ends on p. 28, references pp. 29–30, appendices pp. 31–57). The page counts below are estimates in the paper's current layout.
* **Outside the paper.**
  * Paper 1's `steeper.tex` (a prose summary, no numbers) needs one sentence on exact recovery.
  * `paper-steeper/CLAIMS.md`, `OUTLINE.md` and `app-verification.tex` (the internal record) need the new statements.
  * Bibliography additions:
    * Barron and Cover 1991 (Paper 1 already has the key `barron1991minimum`);
    * Hartman and Wintner 1941, only if iid Prop 7.3(v) is stated;
    * a probability text for the strong law and the random-walk recurrence, if those are cited.

### 5.1 Main text, section by section

P1–P11 name the planned sections of the paper; "§" names sections of this record.

**Front matter (1.25 pp).**
* *Title:* "Steeper Simplicity Priors in Solomonoff Function Induction: the Model–Randomness Split and the Teacher's Mistakes". The current title ends "Absorption, the Teacher's Mistakes and the Model–Randomness Split".
* *Abstract,* rewritten in four parts:
  * the proposal, and why private randomness matters (absorption);
  * exact recovery of a sampler's shortest program with i.i.d. inputs and per-query noise, with class-free rates for fixed λ > 1 and a parity class in which λ = 1 is exponentially slower;
  * on one data set, a kink of the product structure function implies the split, and the noisy parity has one at every flip rate below 1/4 while set models have none;
  * the teacher's mistakes, with λ = cn, as the same geometry with errors reused across inputs, now for flip rates below 0.1233 asymptotically.

**P1 Introduction (2.0 pp; now 2.5).** `sec:intro`.
* The proposal and its footnote (unchanged).
* Two reasons for a steeper penalty, each stated as an informal theorem:
  * *Theorem A (informal).* With i.i.d. inputs and labels drawn by a sampler with fresh coins at each query, every λ-MAP is eventually exactly a shortest program for the sampler. For fixed λ > 1 this happens at a rate that depends only on λ, the program's length, a margin and the confidence. At λ = 1 it can take exponentially longer in the program's length.
  * *Theorem B (informal).* On one data set, if the product structure function has a kink at a sufficient program, every λ between the kink's two slopes selects that program, up to explicit windows.
  * *Theorem C (informal).* The current informal teacher theorem, rephrased about near-optimal hypotheses.
* The absorption objection, with its answer, as the reason the class must have private randomness.
* Contributions (5 bullets) and `tab:intro:claims`, cut from 11 rows to about 8. The "vertex" row is rewritten (§3.3 item 5).
* Scope and reader's guide.
* *New:* the two informal Theorems A, B; the claims-table rows for them.

**P2 Related work (0.75 pp; now 1.5).** `sec:related`, with its paragraph labels.
* Add the consistency of two-part MDL for i.i.d. density estimation (Barron and Cover 1991; content to be checked against the source before it is stated) and the λ = 1 Ville argument.
* Shorten "cold posteriors" and "novelty". Move "an earlier report" (`rem:related:t5`) into `app:related:t5`.

**P3 Setting (2.25 pp; now 2.5).** `sec:setup`.
* The companion-paper objects as a four-line paragraph; the table goes.
* `def:setup:data` **revised**: DS, FR and PQ; X countable, so every input law is atomic; the likelihood used when inputs repeat; PQ likelihoods are the terms of $\Mpq$ (`prop:learn:perquery`).
* Kept: `def:setup:product`, `def:setup:shared`, `def:setup:class`, `def:setup:objectives`, `lem:setup:basic`, `rem:setup:persample`, `lem:setup:coding` (plus one sentence: it is a right line of slope 1).
* **The hull lemma, two readings.** The statement of `lem:setup:hull` moves to the main text, extended by kink Thms 2.1–2.2 and Prop 2.3 for data sets: MAPs at slope −λ, edges and ties, duality.
* The "vertex" sentence is replaced (§3.3 item 3).
* *New:* PQ in the definition (0.25 pp); the data reading of the hull (0.4 pp).

**P4 What counts as one hypothesis: absorption (2.0 pp; now 3.5).** `sec:absorb`.
* `thm:absorb:absorption`, with one sentence from (B5): no steep kink beyond $\ell_U$.
* `rem:absorb:examples`; `rem:absorb:reading` (shortened); `prop:absorb:pricing` (statement only); `cor:absorb:nouniversal`; `prop:absorb:price`; one sentence for `prop:absorb:history`.
* `thm:split:shared` **moves here** as a corollary.
* `rem:absorb:wyeth` (shortened).
* `rem:absorb:why` moves to App. B. `q:absorb:shared` moves to the open-problems list.

**P5 Kinks: the split on one data set (2.25 pp; new).**
* `def:algstat:product` (moved).
* *New* `def:kink:kinks`: left kink (σ, w); right line (τ, g) and right secant; the window form as one sentence. Sources: kink Def 3.1, teacher Def 1.4.
* *New* `lem:kink:main`: teacher Lemma 1.1, stated for the data reading, with kink Thm 3.2(a),(b),(d) as its listed consequences and the τ < σ remark.
* *New* `cor:kink:split`: (B3). `prop:algstat:product` becomes its part (a) or a one-line remark.
* *New* `thm:kink:converse`: (B4), kink Thm 3.4.
* *New* `rem:kink:reading`: kink §6; the split need not be unique; (B5) as one sentence pointing back to P4.

**P6 Exact model recovery from samples (4.75 pp; new; replaces `sec:split`, now 3 pp).**
* P6.1 *Samplers, fill-ins, the three objects* (0.5 pp).
  * `def:split:setting` (rewritten): $E$, $E_0$, $\ell_0$, $k$, $k_\nu$, $\Hel_\mu$, margins.
  * `lem:split:ville` (kept, now covering PQ and every input rule).
* P6.2 *Exact recovery* (1.0 pp).
  * *New* `thm:recovery:main` = Theorem A(a)–(d).
  * A remark: the posteriors concentrate on $E$, not on $E_0$.
  * A remark on method and literature (Barron–Cover).
* P6.3 *What λ > 1 buys, and what is necessary* (0.9 pp).
  * *New* `prop:recovery:lambda1`: iid Prop 5.1 with the four-row recovery-time table, and iid Remark 4.7 as a sentence.
  * *New* `prop:recovery:necessity`: iid Props 4.2, 4.4(a),(b), Remark 4.5.
  * One sentence on the canonical class (iid Prop 4.3).
* P6.4 *The sample kink* (0.75 pp). *New* `thm:recovery:kink` = Theorem C (C1)–(C5), with the $k-7$ counterexample as a remark.
* P6.5 *Noisy computable functions* (0.5 pp). *New* `cor:recovery:noisy` = Cor A′, with the frozen table of (vi) in one sentence.
* P6.6 *Frozen labels, adaptive inputs, misspecification* (0.6 pp).
  * `thm:split:private` (kept: (i)–(iii) for FR and every input rule; (iv) **for λ ≥ 1**).
  * *New* `prop:recovery:frozen`: iid Prop 7.5 and the example of Prop 7.6(d).
  * One paragraph on adaptive inputs (iid Prop 7.2), misspecification (iid Prop 7.3, as "refuted for fixed λ; true in finite classes for fast schedules; open in general") and λ = cn (iid Prop 3.4).
* P6.7 *λ = 1 on one data set* (0.5 pp).
  * `thm:split:lambda1` (kept without (iv)).
  * `rem:split:reading` (rewritten).
  * Pointers to `prop:split:si` and `rem:split:siprograms`.

**P7 The noisy random parity: one instance, two readings (2.5 pp; from `algstat.tex` 2 pp and the teacher's instance and lemmas, about 1.75 pp).**
* `def:teacher:instance` (moved here). Generalise it to any $s_0=p2^m$ if P8.4 is adopted (teacher Prop 5.3 checks that nothing else needs $p=2^{-r}$).
* A shortened notation table: $\psi_c$ and $\Phi_1$ go.
* The four lemmas, statements only: `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart`; and `lem:teacher:sharpfloor`.
* *New* `prop:parity:kink` = (D1), kink Prop 4.1.
* *New* `prop:parity:range` = (D2), (D3): kink Prop 4.2 and Cor 4.3, with a four-row table of certified ranges.
* Sets:
  * `def:algstat:set` (shortened);
  * `prop:algstat:parity`, reduced to (i), (iii) and one sentence on product sophistication;
  * *new* `prop:parity:sets` = (D4), kink Prop 4.4;
  * `rem:algstat:reading`; `rem:algstat:restricted` (two sentences).
* The paragraph on steeper set codes (`prop:algstat:set`) stays as one sentence with its appendix pointer.

**P8 The teacher's mistakes: the split at a positive rate (4.75 pp; now `teacher.tex` 5.5 pp plus `sec:limits:schedule` about 1 pp).**
* P8.1 *From noise to errors* (1.0 pp).
  * `rem:teacher:hanni` (shortened to the hull picture: slopes 100 and 10; rates per sample).
  * *New* `lem:teacher:reuse` (teacher Lemma 3.0).
  * `prop:limits:plain` (kept).
  * *New* `prop:teacher:schedules` (teacher Prop 3.6), replacing `rem:limits:schedule`. Its literature sentences and the batch-excess sentence stay in a short remark.
  * One paragraph on FR against FQ (teacher Prop 3.7).
* P8.2 *Two kink bounds and the theorem* (2.0 pp).
  * *New* `prop:teacher:kinks` (teacher Prop 2.1(a),(b): the wedge and the right line).
  * `thm:teacher:main`, stated about near-optimal hypotheses, with (a1) added to (ii)(a).
  * A proof idea: the lemma plus the four lemmas.
  * `rem:teacher:numbers` and `tab:teacher:numbers`.
  * Teacher Table 2.2 in place of `rem:teacher:hypotheses` (keep the label on it).
  * One remark: what is selected (§4.3).
* P8.3 *Full tables and samples* (0.75 pp).
  * `cor:teacher:fulltable`, extended to every $m$ (teacher Prop 3.1).
  * One paragraph on samples (teacher Prop 3.3 and its conjecture).
  * `cor:teacher:sampled`.
* P8.4 *Flip rates below 0.1233* (1.0 pp).
  * *New* `prop:teacher:sharp` (teacher Prop 5.2) and `prop:teacher:rates` (teacher Prop 5.3).
  * The exact-window table: six rows, κ = 0 and κ = 30.
  * `q:teacher:open`, updated.

**P9 When errors have structure: a second kink (1.75 pp; now `limits.tex` about 2 pp after `sec:limits:schedule` moves).**
* `prop:limits:envelope`, with (i) as one line from the lemma and the $c_{\rm env}$ reading (teacher Prop 4.1); the t3 table in one sentence or five rows.
* `prop:limits:rateblind` (secant form, teacher Prop 4.2); `lem:limits:robust` (statement).
* One remark gathering `prop:limits:separable`, `prop:limits:guard`, `prop:limits:inputlaw` and `prop:limits:noident`: what a hull cannot see (teacher Remark 4.3).
* `prop:limits:ood` (one paragraph).
* `q:limits:open`, with (b) marked answered.

**P10 Computable classes (0.5 pp; now 1).**
* `prop:related:computable`, plus a part: Theorem A in every countable Kraft subclass (iid Cor 6.2).
* `rem:computable:examples` (two sentences); `prop:related:computability`; `rem:related:nn` (two sentences).
* `q:related:open` moves to the open-problems list.

**P11 Discussion and open problems (1.25 pp; now 1.5).**
* The two reasons (§4.7).
* What counts as one hypothesis.
* The gap to realistic errors.
* The open problems of this record's §6, about 10 items.
* Acknowledgements and code statement unchanged.

### 5.2 Appendices

| appendix | contents | source | pages (now) |
|---|---|---|---|
| A Setting | standard facts; proof of the hull lemma in both readings (kink Thm 2.1, 2.2, Prop 2.3, and `lem:setup:hull`(iv) with `rem:setup:hullconverse`); coding bound | `app-setup.tex`; kink §2 | 2.5 (2) |
| B Absorption | as now; plus `rem:absorb:why` (moved) and the proof of `thm:split:shared` (from `app:split:shared`); the per-input pricing proof shortened | `app-absorb.tex`, `app-split.tex` | 3.25 (4) |
| C Kinks | proofs of `lem:kink:main` (teacher Lemma 1.1, Remark 1.2), the τ < σ example and strictness (kink Remark 3.2′), `cor:kink:split`, `thm:kink:converse`, (B5), teacher Lemma 1.5 | kink §3; teacher §1 | 1.75 (new) |
| D Exact recovery | iid Lemmas 2.1–2.2; Thms 3.1, 3.2; Props 3.3, 3.4; Thm 4.1 with Remarks 4.5, 4.7; Props 4.2–4.4; Prop 5.1; kink Lemmas 5.1–5.3 (pq), Thm 5.4, Cor 5.7; iid Lemma 8.1(iv); Cor 6.1 with the (vi) table; Props 7.2, 7.3 (short), 7.5, 7.6 | iid §§2–8; kink §5 | 5.0 (new) |
| E λ = 1 and fill-ins | Ville; `lem:split:stream`; `prop:split:si`; proof of `thm:split:private`, with (iv) for λ ≥ 1; `ex:split:noisyparity`; `rem:split:siprograms`. `lem:split:hash` cut | `app-split.tex`; iid Prop 3.3 | 2.25 (4) |
| F The noisy parity | proofs of the four lemmas and `lem:teacher:sharpfloor` (moved from App. C); kink Props 4.1, 4.2, 4.4 and Cor 4.3; `prop:algstat:parity`(i),(iii); `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc`; the certified-range table in place of `tab:algstat:numbers` | `app-teacher.tex` §C.1–C.2, `app-algstat.tex`; kink §4 | 3.75 (3.5 + about 2 of lemma proofs) |
| G The teacher | proof of `thm:teacher:main`: (i), (ii)(b), (ii)(c) from the lemma; (o), (ii)(a), (d), (e), (iii), (iv) as now. Numbers; full table for every $m$; `lem:teacher:finite`, `cor:teacher:sampled`; teacher Props 3.6, 3.7; Lemma 5.1, Props 5.2, 5.3; `prop:teacher:concentration`; `ex:teacher:version1` | `app-teacher.tex` §C.3–C.7; teacher §§2–5 | 4.5 (about 5) |
| H Structure and limits | `prop:limits:plain`; `lem:limits:robust`; separable components, guard, non-identifiability, input law (condensed); envelope (ii); unseen properties. `rem:limits:method` replaced by the material of teacher §5 in App. G | `app-limits.tex`; teacher §4 | 2.75 (5) |
| I Computable classes; the earlier report | as now, condensed | `app-related.tex` | 1.0 (1.5) |
| **total** | | | **26.75 (27)** |

### 5.3 Page budget

| | now | planned |
|---|---|---|
| front matter, intro, related work | 5.0 | 4.0 |
| setting | 2.5 | 2.25 |
| absorption | 3.5 | 2.0 |
| kinks (new) | — | 2.25 |
| split / exact recovery | 3.0 | 4.75 |
| algstat / noisy parity | 2.0 | 2.5 |
| teacher | 5.5 | 4.75 |
| limits / second kink | 3.0 | 1.75 |
| computable, discussion | 2.5 | 1.75 |
| **main text** | **27–28** | **about 26** |
| **appendices** | **27** | **about 27** |

Main text (27 now, 26 planned):
* *Gained:* 4.5 pages: the kink section (+2.25); exact recovery net of the old split section (+1.75); the noisy-parity section, which now carries the instance and its lemmas (+0.5).
* *Saved:* 5.5 pages: absorption (−1.5); the intro and related work (−1.0); the teacher and limits sections together (−2.0: the proofs of (i)–(ii)(c) and the envelope and rate-blindness parts reduce to the lemma, and the instance moves to P7); computable classes and discussion (−0.75); the setting (−0.25).

Appendices (27 now, 26.75 planned):
* *Gained:* 7.25 pages: App. C (1.75), App. D (5.0), and the data reading of the hull in App. A (+0.5).
* *Saved:* 7.5 pages:
  * App. E −1.75: the hashing lemma (−1), and the shared-randomness proof moves to B;
  * App. H −2.25: `rem:limits:method`, and the envelope and rate-blindness proofs via the lemma;
  * Apps. F and G together −2.25: the teacher proofs via the lemma (−0.75), `tab:algstat:numbers` (−0.5), condensing (−1.0);
  * App. B −0.75; App. I −0.5.

If the budget is tight, the first candidates for the appendix or for removal are:
* Thm A(d)'s uniform-in-time form;
* iid Prop 7.3(v) (fast schedules under misspecification);
* teacher Prop 3.3's sampled paragraph;
* the t3 table.

### 5.4 What the plan cuts, and why

* `thm:split:lambda1`(iv) and `lem:split:hash`. Weaker than the stream lemma at every computed size (32–143 bits against 5.6–8.9). The hashing idea is credited in Paper 1 (Remark B.3). Optional: keep both unchanged if the appendix has room.
* `rem:limits:method`. Superseded by teacher §5 if the junta window enters.
* `tab:algstat:numbers`. Superseded by the certified λ-ranges, which say more: they bound the λ-MAP, not only the sophistication.
* $\psi_c$, $\Phi_1$ and the case analysis in the proof of `thm:teacher:main`(ii)(b). Replaced by the lemma.

No proved statement of the current paper is dropped, except `thm:split:lambda1`(iv) and `lem:split:hash` if that option is taken.

### 5.5 Label map (every theorem-like label of the current paper)

| current label | planned section | change |
|---|---|---|
| `def:setup:data` | P3 | revised (DS, FR, PQ) |
| `def:setup:product`, `def:setup:shared`, `def:setup:class`, `def:setup:objectives`, `lem:setup:basic`, `rem:setup:persample`, `lem:setup:coding` | P3 | kept |
| `lem:setup:hull` | P3 (statement), App. A (proof) | extended to data sets (kink §2) |
| `rem:setup:hullconverse` | App. A | kept |
| `eq:absorb:dom`, `rem:absorb:examples`, `thm:absorb:absorption`, `prop:absorb:pricing`, `cor:absorb:nouniversal`, `prop:absorb:price` | P4 | kept (pricing shortened) |
| `rem:absorb:reading`, `rem:absorb:wyeth` | P4 | shortened |
| `rem:absorb:why` | App. B | moved |
| `q:absorb:shared` | P11 | moved to the open-problems list |
| `rem:absorb:condsemi`, `prop:absorb:history`, `prop:absorb:inputs` | App. B | kept |
| `thm:split:shared` | P4 | moved; corollary of absorption |
| `def:split:setting` | P6.1 | rewritten |
| `lem:split:ville` | P6.1 | kept; scope stated (PQ, any input rule) |
| `thm:split:private` | P6.6 | (i)–(iii) kept; (iv) for λ ≥ 1 |
| `thm:split:lambda1` | P6.7 | (iv) cut |
| `rem:split:reading` | P6.7 | rewritten |
| `lem:split:stream`, `prop:split:si`, `ex:split:noisyparity`, `rem:split:siprograms` | App. E | kept |
| `lem:split:hash` | — | cut (optional) |
| `def:algstat:product` | P5 | moved |
| `prop:algstat:product` | P5 / App. C | corollary of `cor:kink:split` |
| `def:algstat:set` | P7 | shortened |
| `prop:algstat:parity` | P7, App. F | (i), (iii) kept; (ii), (iv) superseded by `prop:parity:kink`, `prop:parity:range` |
| `rem:algstat:restricted`, `rem:algstat:reading` | P7 | kept |
| `prop:algstat:set`, `rem:algstat:near1`, `prop:algstat:coarse`, `q:algstat:lsc` | App. F | kept |
| `tab:algstat:numbers` | App. F | replaced by certified ranges |
| `rem:teacher:hanni` | P8.1 | shortened |
| `def:teacher:instance` | P7 | moved; optionally generalised to $s_0=p2^m$ |
| `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart` | P7 (statements), App. F (proofs) | moved |
| `lem:teacher:sharpfloor`, `eq:teacher:identity` | P7 or App. F | moved |
| `thm:teacher:main` | P8.2, App. G | proof of (i), (ii)(b),(c) via the lemma; (a1) added |
| `rem:teacher:numbers`, `tab:teacher:numbers` | P8.2 | kept |
| `rem:teacher:hypotheses` | P8.2 | replaced by teacher Table 2.2 |
| `cor:teacher:fulltable` | P8.3 | every $m$; (ii) merged with the λ = 1 discussion |
| `cor:teacher:sampled`, `lem:teacher:finite`, `prop:teacher:concentration`, `ex:teacher:version1` | P8.3 / App. G | kept |
| `q:teacher:open` | P8.4 | (b) answered for $p<0.1233$ (population) |
| `prop:limits:plain` | P8.1 | kept |
| `rem:limits:schedule` | P8.1 | replaced by `prop:teacher:schedules` and a short remark |
| `prop:limits:envelope` | P9 | (i) via the lemma; reading via $c_{\rm env}$ |
| `prop:limits:rateblind`, `lem:limits:robust` | P9 | secant form |
| `prop:limits:separable`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw` | P9 (one remark), App. H | condensed |
| `prop:limits:ood` | P9 | shortened |
| `q:limits:open` | P9 | (b) answered (population) |
| `rem:limits:method` | — | replaced by P8.4 (or reworded) |
| `prop:related:computable` | P10 | gains the Theorem A part |
| `rem:computable:examples`, `prop:related:computability`, `rem:related:nn` | P10 | shortened |
| `q:related:open` | P11 | moved to the open-problems list |
| `rem:related:posteriors`, `rem:related:mdl`, `rem:related:cold`, `rem:related:new` (paragraph labels) | P2 | kept, shortened |
| `rem:related:t5` | App. I | moved |
| `tab:intro:claims` | P1 | rows rewritten |

**New labels** (proposed names), each with its source:

| new label | content | source |
|---|---|---|
| `def:kink:kinks` | left kink, right line, right secant | kink Def 3.1; teacher Def 1.4 |
| `lem:kink:main` | the kink lemma | teacher Lemma 1.1; kink Thm 3.2 |
| `cor:kink:split` | split for one data set | kink Cor 3.3 |
| `thm:kink:converse` | stable MAP lengths ⟺ kinks at vertices | kink Thm 3.4 |
| `rem:kink:reading` | bits explaining more than λ bits; non-uniqueness | kink §6, Remark 3.6 |
| `thm:recovery:main` | Theorem A | iid Thms 3.1, 3.2, 4.1 |
| `prop:recovery:lambda1` | λ = 1 in the parity class; the table | iid Prop 5.1, Remark 4.7 |
| `prop:recovery:necessity` | margin and 1/(λ−1) necessary; length bound attained | iid Props 4.2, 4.4, Remark 4.5 |
| `thm:recovery:kink` | Theorem C | kink Thm 5.4, Cor 5.7; iid Lemma 8.1 |
| `cor:recovery:noisy` | noisy computable functions | iid Cor 6.1 |
| `prop:recovery:frozen` | frozen labels: no procedure; example | iid Props 7.5, 7.6 |
| `prop:parity:kink`, `prop:parity:range`, `prop:parity:sets` | Theorem D | kink Props 4.1, 4.2, 4.4, Cor 4.3 |
| `lem:teacher:reuse` | duplication | teacher Lemma 3.0 |
| `prop:teacher:kinks` | the wedge and the right line | teacher Prop 2.1 |
| `prop:teacher:schedules` | which schedules keep the identification | teacher Prop 3.6 |
| `prop:teacher:sharp`, `prop:teacher:rates` | the junta window below 0.1233 | teacher Props 5.2, 5.3 |

---

## 6. Open problems

Each item is open in the sub-track records cited. Conjectures are marked as such. None is claimed here beyond its record.

**The split thread.**
1. **A computable recovery-time bound in the canonical class** [open: iid Prop 4.3 and its reading]. In $\Hcl{\times}$ the margin $\gamma_L$ is below every computable function of $L$ (for $Y=\{0,1\}$ and ν bounded away from 0 and 1), so Theorem A(d) gives no computable sample size. Near-equivalent programs (a rate with more bits) should be handled through their small likelihood fluctuations. The near/far bounds (kink Thm 5.6; iid Thm 4.1(iv′) with $s=1$) leave a term $W_{\rm near}$ that does not tend to 0 with $n$.
2. **Local margins** [open: kink §8 item 1]. Replace $1/\gamma_{\bar\ell}$ in the sample size by a parametric-complexity term of order $\log n$ per family of near-equivalent refinements. In kink's k6 instance the observed threshold is about $10^3$ samples, against $6\cdot10^4$–$2\cdot10^5$ from the bound [computed: k6(D)].
3. **Joint necessity of $1/(\min(1,\lambda-1)\gamma)$** [open: iid Prop 4.4, last bullet]. The factors 1/γ and 1/(λ−1) are shown necessary in separate classes only.
4. **The right slope at the kink of a single frozen data set** [open: kink §8 item 2]. In $\Hcl{\times}$, can single fill-in programs reach slope ≥ 1 at the shortest equivalent program while the sample is far from the full table? (Answered in PQ, in the limit: kink Cor 5.7(d).)
5. **Frozen labels with repeated inputs** [open: kink §8 item 5]. For which classes and input laws does the evidence $\sum_{x\in\dom D_n}\Hel_x(\pi)$ of every program shorter than $\ell_0$ grow without bound? What identification beyond "on the run" do frozen data allow?
6. **Misspecification in countable classes** [open; conjecture: iid Conj 7.4]. Is the misspecified λ-MAP eventually a shortest KL-projection under fast schedules in countable classes? In rich classes, does it memorise exactly where the model's excess loss exceeds $(\lambda-1)$ times the local entropy?
7. **Set kinks in general** [conjecture: kink §8 item 4]. Is a product kink of steepness σ at α, for a model with a random parameter, always accompanied by a set-model slope ≈ 1 there?

**The teacher thread.**

8. **Level ≤ 2 for every $p<1/4$ in the junta case** [conjecture, "routine": teacher §5]. The level-3 analogue of $\psi_2$ has limit $-\log(\frac58-\frac p4)>H(p)$ up to $p=1/4$. Identification needs (D2) at level 2. Level 1 for $0.1233\le p<1/4$ is impossible with the present floors.
9. **Sampled junta kinks with unequal cell multiplicities** [conjecture with computed evidence: teacher Prop 3.3(c); open: kink §8 item 3]. The lower end of the λ-set should be θ times the mean multiplicity of the sampled error cells.
10. **Schedules whose ratio $\lambda_n/n$ leaves the window infinitely often** [open: teacher Prop 3.6, after it].

**Carried over from Paper 2** (each cited there):

11. structured error rules: envelopes of density below one, and what is selected above $c_{\rm env}$ (`q:limits:open`(a));
12. other model classes than parities (`q:teacher:open`(a));
13. non-uniform input laws (`prop:limits:inputlaw`, separable case only);
14. near-population constants at realistic sample sizes (`q:teacher:open`(c));
15. a choice of $c$ that does not use the imitation data (`q:limits:open`(c));
16. shared hypotheses: is every lsc law of a random partial function dominated by $\MF$ (`q:absorb:shared`)?
17. resource bounds and computability (`q:related:open`);
18. lower-semicomputable product models in `prop:algstat:coarse` (`q:algstat:lsc`).

**Literature questions** (not mathematics):

19. whether Barron and Cover (1991) state the consistency that iid attributes to them through Poland and Hutter (2005);
20. whether Vereshchagin–Vitányi (2004, 2010) state the hull relation between λ-weighted two-part codes and the structure function for set models (kink §7).

---

## 7. Cross-track consistency, and corrections found in the synthesis

Each sub-track record has its own cross-track section (iid §9, kink §9, teacher §7). Each compared itself with the others' *pre-referee* notes, because no final record existed when it was written. This section compares the three final records with each other.

### 7.1 Mathematical consistency

No contradiction was found between the final records. Each point below was checked by reading both statements.
* **Exact recovery.** iid Thm 3.1 (every $1\le\lambda_n=o(n)$), kink Cor 5.7(c),(d) (fixed λ > 1; λ = 1 via iid Thm 3.1) and teacher Prop 3.2(a),(b) (least-risk programs; ν among them by Gibbs) say the same thing about PQ.
* **The sample kink.**
  * iid Lemma 8.1(i) is kink Lemma 5.2 in PQ form.
  * iid Lemma 8.1(iii)'s steepness condition ("when that quantity is at least 2") is kink Thm 5.4(i)'s $A\ge2\ell_0$.
  * The right windows agree: $(\ell_0+\delta^*)/(\tau-1)$ for all $n$; $(\ell_0+\log(1/\varepsilon))/(\tau-1)$ at fixed $n$.
* **Finite-sample forms.** iid Thm 4.1(iv) and kink Cor 5.5 agree to four digits at λ = 1.5 and 2 at kink's k6 instance. iid's is 10% and 16% larger at λ = 4 and 8, where kink's form has $2\log(1/\varepsilon)$ in place of $\lambda\log(2/\varepsilon)$ [computed: s1(B)].
* **The τ = 1 line versus the secant.** iid §9.4(c), kink Thm 5.4(ii) and teacher Def 1.4, Lemma 1.5 agree. The line of slope 1 has offset $\ell_0+\delta^*$, and secants can exceed 1. iid Lemma 8.1(iv) (excess $k-7$) and teacher t5(B) (secant $1.199\cdot2^{d-m}$) are instances of teacher Lemma 1.5(a).
* **Frozen noise.**
  * iid Props 7.5–7.6, kink Prop 5.10 and teacher Prop 3.7 agree. In FR exact recovery fails for every procedure, and the excess length is bounded at every $n$.
  * In FQ every $\lambda_n=o(n)$ eventually rejects every program for ν, when the class contains a program that memorises the noise at finitely many atoms (teacher Prop 3.7(b)).
  * The referees' statement "in the frozen object every $\lambda_n=o(n)$ memorises" is about FQ, not FR. Both iid §9.4(a) and teacher §7.4(a) make this distinction.
* **λ = cn.** iid Prop 3.4(c) and teacher Prop 3.2(d) are the same statement for countable Kraft classes. iid Prop 3.4(b) is the converse that teacher's Reading after Prop 3.2 cites.
* **The full-table window.** kink Prop 4.2's G-floor range contains `cor:teacher:fulltable`'s $(1,Nc_{\rm hi})$. Teacher Prop 3.1 is the every-$m$ form; kink's covers $m=d$ for every $p<1/4$, teacher §5 covers $m<d$ for $p<0.1233$.
* **The kink lemma.** Teacher Remark 1.3 derives kink Thm 3.2(a),(b) and Cor 3.3 from teacher Lemma 1.1, up to windows. Kink §9.3 agrees. The two forms complement each other: the hull description and the converse are kink's; the property-defined left set and the real offset are teacher's.

### 7.2 Notation that crossed

These are reporting points, not mathematics; §1 gives the recommended names.
* $\ell_0$/$E_0$ (iid final) against $\ell^*$/$E^*$ (kink final).
* $\Hel_\mu(\pi)$, $\gamma_-$ (iid final) against $\gamma(\pi)$, $\gamma_<$ (kink final).
* **$b_0$.** Kink final uses $2\log(d+1)$, teacher final uses $2\log d$. Each switched to the other's pre-referee convention. The two differ by $2\log((d+1)/d)\le2$ bits, which (F5) absorbs into κ. At $d=m=20$, $p=2^{-10}$, κ = 0, λ = 2 the length bounds are $d+45.544$ ($2\log d$) and $d+45.685$ ($2\log(d+1)$) [computed: s1(F)]. Teacher §2.2 prints the first as "$d+45.55$"; kink's k7(b) prints "$d+45.54$". A rounding difference of 0.005 bits.
* Teacher Remark 3.4's table writes kink's floor as $\Psi^\circ_t$. Kink final renamed it $\Gamma^\circ_t$; teacher §5 uses $\Psi_t$ for a different object.

### 7.3 Small corrections

* **iid Thm 4.1(iv), i4 class.** The theorem's sample size is a ceiling. At λ = 1.5, ε = 0.05 it is $\lceil4264.30\rceil=4265$, not 4264. At λ = 4, ε = 0.01 it is $\lceil6547.36\rceil=6548$, not 6547. The script `iid/checks/i4_noisy_parity.py` prints the rounded value (`{nexp:.0f}`). The other four values agree. The values quoted in iid (after Cor 6.1) are 2843, 4264 and 5686; the middle one should read 4265 [computed: s1(A)]. No statement depends on the difference of one sample.
* **Teacher Prop 2.3** cites kink Thm 5.4(i) "with probability ≥ 1 − 2ε". Kink Thm 5.4(i) holds with probability ≥ 1 − ε; only (iii) needs 1 − 2ε. The cited form is weaker, so still true.
* **Statuses of post-referee material.** All three final records added results after their referee rounds; kink says so in its verification log ("No independent referee has read this revision"). §8 marks each headline claim accordingly.

---

## 8. Claims and statuses

"Refereed" means checked by a sub-track referee in this form. "Post-referee" means proved in a final record after the referee round, without an independent check of the final form. Several post-referee items implement a referee's own proposal or correction; the column says so.

| # | claim | status | record |
|---|---|---|---|
| A(a) | PQ: every $1\le\lambda_n=o(n)$, λ = 1 included: λ-MAP set $=E_0$ eventually, a.s. | proved, refereed; computed | iid Thm 3.1 |
| A(b) | posteriors concentrate on $E$ with the prior's shape; "on $E_0$" refuted | proved, refereed; computed | iid Thm 3.2 |
| A(c) | λ > 1, all $n$: length bound; fill-in posterior $\le2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)L_n(\nu)}$ | proved, refereed | iid Thm 4.1(i)–(iii) |
| A(d) | free-exponent bound | proved, post-referee (referee B's b3 proposal); computed i8(A), rB8 | iid Thm 4.1(iv′) |
| A(d) | margin form, $n(\lambda,\ell_0,\gamma,\varepsilon)$ | proved, refereed; computed | iid Thm 4.1(iv) |
| A-λ1 | at λ = 1 the bound needs $\sum2^{-s\ell}<\infty$ for some $s<1$ | proved, post-referee | iid Remark 4.7 |
| A-λ1 | λ = 1 recovery time in $\mathcal C_k$ in $(2^{(k-8)/2}-6,\max(32,\lceil2^{(k+1)/2}/\sqrt\varepsilon\rceil)]$ ($\varepsilon<31/32$, $k$ even) | proved: lower end refereed, upper end (b′) post-referee; table computed i7, rB2; s1(C) | iid Prop 5.1 |
| A-nec | 1/γ necessary (λ ≥ 2); no bound without a margin; 1/(λ−1) necessary | proved, refereed | iid Props 4.2, 4.4 |
| A-nec | length bound attained up to $\log(1+2^{2-\ell_0})/(\lambda-1)$ | proved, post-referee (referee B's b5); computed i7(E), rB7(B); s1(C) | iid Remark 4.5 |
| A-can | canonical class: margin not computably bounded | proved, refereed | iid Prop 4.3 |
| A′ | noisy computable functions: $f$ and exact $p$ (PQ) | proved, refereed; computed i4, rB6 | iid Cor 6.1(i)–(v) |
| A′(vi) | FR on a finite domain: wrong w.p. ≥ $(7/8)^{64}$, computed 0.20–0.57 | lower bound proved, post-referee (referee B's B4); computed i8(D), rB6(C) | iid Cor 6.1(vi) |
| B1 | λ-MAPs on the convex minorant; edges; duality | proved, refereed; computed k1, rB1 | kink Thms 2.1–2.2, Prop 2.3 |
| B2 | kinks locate MAPs; zero-window kink with τ < σ ⟺ vertex | proved, refereed (τ < σ added at the referees' request) | kink Thm 3.2 |
| B3 | split for one data set | proved, refereed (hypothesis class) | kink Cor 3.3 |
| B4 | converse | proved, refereed | kink Thm 3.4 |
| B5 | universal member flattens kinks, caps MAPs | (i) proved, refereed; (ii) proved, post-referee (the absorption bound, which both referees proposed in place of a refuted sentence) | kink Prop 3.5 |
| L1.1 | general kink lemma (real $g$, pointwise margin, (iv)) | proved; original refereed, final form post-referee (referees' corrections); computed t7(A) | teacher Lemma 1.1 |
| L1.5 | right line versus right secant | proved, post-referee; computed t7(B) | teacher Def 1.4, Lemma 1.5 |
| C1–C4 | sample kink (pq) | proved; refereed in (wor), restated for (pq) post-referee (the referees' proposed repair); computed k6(D) | kink Lemma 5.2, Thm 5.4 |
| C3-ex | the $\ell_0$ in the right window is necessary ($k-7$) | proved, post-referee (referee B's B2); computed i8(G), rB4 | iid Lemma 8.1(iv) |
| C5 | a.s.: linear steepness; eventually $s_+<1<s_-$ | proved, post-referee; computed k6(D), k8(C) | kink Cor 5.7 |
| D1 | full-table left kink at the good model | proved, refereed | kink Prop 4.1 |
| D2 | "parity + noise" on $C_{t_0}(\lambda)$; certified intervals | (i) proved, refereed ((g) post-referee); (ii) proved, post-referee; computed k7 | kink Prop 4.2 |
| D3 | every $p<1/4$, large $d$: level ≤ 2 (level 1 if $p<0.12331$) | proved, refereed; constant computed k7(d), rA(4), rB4; s1(D) | kink Cor 4.3 |
| D4 | set models: steepness ≤ $1+O((\log d+\delta_E)/d)$ | proved, refereed; computed k8(D), rB2 | kink Prop 4.4 |
| F-FR | frozen labels: no procedure recovers every sampler | proved, refereed | iid Prop 7.5 |
| F-run | on the run for every λ ≥ 1, every input rule, PQ or FR | proved, post-referee (referee B's B1 sketch, written in full) | iid Prop 3.3 |
| F-ad | adaptive inputs: a shorter wrong program can win with positive probability | proved, refereed | iid Prop 7.2 |
| F-mis | KL-projection: refuted for fixed λ; true in finite classes for fast schedules | proved; (ii) with $D^*<\infty$ refereed; (iii′), (v) post-referee (referee B's B3) | iid Prop 7.3 |
| F-cn | λ = cn: exact iff $c<c^*$ ($c=c^*$ not covered); limit $\arg\min(c\ell+R)$ | (a) refereed; (b), (c) post-referee | iid Prop 3.4 |
| T-2.1 | teacher theorem = kink lemma with τ = $2^{-m}$ | proved, refereed; computed t1(B), rB2(E) | teacher Prop 2.1 |
| T-2.3/2.4 | split = τ = 1; full table $m=d$ = sufficiency line | proved, refereed | teacher Props 2.3, 2.4 |
| T-2.6 | (a1), (a2) sharpening | proved, post-referee (referee B's B-m2); computed t6, rB8 | teacher Remark 2.6 |
| T-3.0 | duplication multiplies thresholds by $r$ | proved, post-referee; computed t7(C) | teacher Lemma 3.0 |
| T-3.1 | full table, every $m$: window $(2^{d-m},Nc_{\rm hi})$ | proved, refereed ((c) post-referee); computed | teacher Prop 3.1 |
| T-3.6 | schedules | proved, post-referee | teacher Prop 3.6 |
| T-3.7 | FR: reuse factor 1; FQ: every $\lambda_n=o(n)$ rejects ν's programs | proved, post-referee (the referees' issue A M4/B-M1, with a correction); computed t5(D), rB5 | teacher Prop 3.7 |
| T-3.3 | samples: lower bounds; equal multiplicities | proved (chain rule now in full); unequal multiplicities a conjecture | teacher Prop 3.3 |
| T-4 | envelopes raise the lower end; rate blindness = empty kink interval | proved, refereed; computed t3, rB3 | teacher Props 4.1, 4.2 |
| T-5 | junta window for every $p<0.1233$ (population, asymptotic); exact windows at $d=100$, $m=20$ | proved, refereed (range per referee A's M5); Prop 5.3 given the computed constants $p^*$, $a^*(p)$; computed t4, t6, rB7; s1(D) | teacher Lemma 5.1, Props 5.2, 5.3 |
| refuted | "the good model is a vertex on the whole window" | **refuted as stated** | teacher §2.1 |
| refuted | "only λ = cn can stop at an interior vertex" | **refuted as stated** | teacher Prop 3.6 |
| refuted | "λ = 1 never makes the split exact" (PQ, asymptotically) | **refuted** | iid Prop 5.3(a) |
| refuted | "posteriors concentrate on $E_0$" | **refuted** | iid Thm 3.2 |
| refuted | "each bit of length buys at most one bit of fit, plus δ*" | **refuted** | iid Lemma 8.1(iv) |
| refuted | KL-projection conjecture for fixed λ | **refuted** | iid Prop 7.3(ii), (iii) |
| refuted | the frozen reading of kink Cor 5.7(c) | **refuted** | kink Prop 5.10 |
| correction | i4's printed $n$ at (1.5, 0.05) and (4, 0.01) | ceilings are 4265 and 6548 | §7.3; s1(A) |


---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6, scipy 1.17.1 and mpmath 1.3.0, on a 4-core session machine.*

**1. Re-run of every sub-track script.**
* *Method.* The `checks/` and `referee_code/` folders of the three sub-tracks were copied to a scratch directory, with their relative layout kept, because some referee scripts read the prover's files. All 50 scripts were re-run there, four at a time, with `PYTHONDONTWRITEBYTECODE=1`. Each output was compared byte for byte with the saved `.out` file.
* *Scripts.* iid: `i1`–`i8`, `rA1`, `rB1`–`rB9` (18). kink: `k1`–`k8`, `rA`, `rB1`–`rB6` (15). teacher: `t1`–`t7`, `rA1`, `rB0`–`rB8` (17). The helper modules `tcommon.py` and `rBcommon.py` are not scripts.
* **Result: all 50 exited with code 0, and all 50 outputs are byte-identical to the saved ones.**
* *Run times.* The longest were teacher `rB7` 747 s, iid `rB1` 629 s, teacher `t6` 483 s, iid `rB3` 437 s, kink `rB3` 308 s and iid `i7` 199 s. All others took under 3 minutes.
* *stderr.* Empty for 49 scripts. iid `i8` prints the numpy RuntimeWarning ("invalid value encountered in multiply", from $0\cdot(-\infty)$ inside an `np.where` whose value at those entries is discarded), which iid's own log records as harmless.
* The original folders were not touched. No `__pycache__` was created anywhere under `research/tracks/split/`.

**2. The synthesis script `checks/s1_synthesis_numbers.py`** [deterministic; output `checks/s1_synthesis_numbers.out`; run time under 1 s; re-run from a scratch copy after the last edit, byte-identical]. It recomputes from closed forms, independently of the sub-track scripts:
* (A) iid Thm 4.1(iv)'s sample size at the i4 class. γ = $h_=(1/8,3/16)=0.003736$. The ceilings are 2843, 4265 and 5686 at λ = 2, 1.5, 4 (ε = 0.05), and 3274, 4911 and 6548 at ε = 0.01. i4 prints the rounded values 4264 and 6547 for two of them (§7.3).
* (B) iid Thm 4.1(iv) against kink Cor 5.5 at k6's instance, at equal guarantee 0.90. The margins of k6's class are taken from `kink/checks/k6_perquery.out`. Ratios 1.000, 1.000, 1.102, 1.161 at λ = 1.5, 2, 4, 8. Kink's $n_0$ reproduced to within 1% (asserted).
* (C) The λ = 1 recovery times $2^{(k+4)/2}+6$ equal iid's table for $k\in\{16,24,32,40\}$ and lie inside the proved bracket of iid Prop 5.1 (asserted). iid Remark 4.5's parity lengths 38, 56, 44, 72, 78 (asserted), with gaps $5.5\cdot10^{-6}$ to $3.5\cdot10^{-4}$ bits.
* (D) The crossings $G_1=H$ at 0.05596, $f_1=H$ at 0.12331 and $\psi_2(p,1)=H$ at 0.07787. The grid minimum of $f_2-H$ on (0, 1/4] is 0.0187969, at $p=1/4$; this is a grid value, not the rigorous bound, which is kink's interval check. $a^*(p)$ at six rates, all within 0.2% of teacher's values (asserted).
* (E) The three-hypothesis rates $1.1185\cdot10^{-6}$ and $8.989\cdot10^{-3}$, ratio 8037.
* (F) $b_0$ and the λ = 2 length bound at $d=m=20$ in both conventions: $d+45.5444$ and $d+45.6852$.
* (G) iid Prop 4.4(a)'s constants 8.6562 and 0.08318.
* All assertions passed. The script failed on its first run, because it asserted equality with i4's printed 4264. That is how the rounding point of §7.3 was found. The assertion was changed to report the difference, and the saved output is from the final version.

**3. Proof checks done for this synthesis.**

This record proves nothing new. To make sure the headline statements are quoted correctly, the following proofs were re-read in the sub-track records and re-derived by hand. No gap was found.
* iid Thm 3.1, Steps 1–2: the event $B_L$, the bound $2^{\ell_0}t_L$, and the three cases of Step 2.
* iid Thm 4.1(iv′): the event inclusion, and one Markov step per program; the margin form from $s=1/\lambda$.
* iid Prop 3.3: Step 1 with $k$ in place of $\ell_0$, and the Kakutani supermartingale $\sqrt{\Lambda_n}/\prod(1-g_i)$ with $g_{n+1}$ fixed before $y_{n+1}$.
* iid Prop 3.4(a),(c).
* iid Prop 5.1(b′): $P(n)\le2^{m^*-n}\le2^{k-1}/(m^*+1)^2$, the case split giving $m^*+1\ge n/2$ for $n\ge32$, and the lower end at $n=2^{(k-8)/2}-6$.
* iid Remark 4.5: the tie $\lambda(n+2)=\lambda k+n$ at $n=\lambda(k-2)/(\lambda-1)$, and $\delta_n=\log(2^{-k}+1/4)$.
* kink Cor 3.3: the coding bound rearranged into a right line, and the subtraction giving the length bound.
* kink Cor 5.7(d): a 1-MAP set at a single point forces λ = 1 strictly inside a vertex's interval, by Thm 2.2(ii).
* kink Prop 4.2(ii): monotonicity of $\Gamma_t$ in λ.
* teacher Lemma 1.1(ii): the length bound, and the lower fit bound in the case $g+\epsilon<0$.
* teacher Lemma 3.0 and Prop 3.7(a).

Everything else is quoted from the sub-track records with their statuses, and was not re-derived here.

**4. Consistency checks.**
* §7.1 lists the cross-record comparisons. Each was made by reading both statements in the final records.
* *The label map of §5.5.* A script extracted every theorem-like label from Paper 2's section files, excluding `sec:` and `app:` labels; there are 85. Each appears in the map.
* *Page counts* are from `paper-steeper/main.toc` and `pdfinfo main.pdf` (57 pages) of the current build. Planned page counts are estimates.

**5. Literature.** No new search was made. The statuses of the literature claims are those of the sub-track records:
* Barron–Cover's consistency statement is known only through Poland–Hutter, and is unverified.
* Hartman–Wintner's details are from memory, unverified.
* The theorem numbers of Hoeffding's comparison and Maclaurin's inequality were located through secondary sources only.
* Whether Vereshchagin–Vitányi state the set-model hull relation is open.

**6. Not done.**
* No independent referee has read this synthesis.
* The post-referee results listed in §5.0 have not been independently checked in their final form. The hand checks of item 3 cover some of them; they are not a referee's check.
* Paper 2 was not edited; this record only plans the edit.

**7. Repository.** No git command that changes repository state was run; only `git status` was used to list the new files. Files written, all under `research/tracks/split/`:
* `notes-final.md` (this record);
* `checks/s1_synthesis_numbers.py`;
* `checks/s1_synthesis_numbers.out`.

The sub-track folders `iid/`, `kink/` and `teacher/` were not modified. The scratch copies used for the re-runs are in the session scratchpad only.

**8. Final check.** A separate final check compared every headline statement of this record with the sub-track records and their referee reports, and re-ran five scripts (`i7`, `k6`, `k7`, `t1`, `s1`; all byte-identical). It made 27 minimal edits to this record, correcting hypotheses, quantifiers, statuses and wording. `final-check.md` in this folder lists each change, with the old and new text.
