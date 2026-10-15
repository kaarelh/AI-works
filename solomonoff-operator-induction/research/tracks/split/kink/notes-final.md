# Track "split", sub-track "kink": λ-MAPs, the hull of the product structure function, and "a kink implies the split" (final record)

*Target T2 of the brief `../00-brief.md`, with the link to T1. Final record, 2026-10-13, written after the referee reports `referee-A.md` (proofs) and `referee-B.md` (computation). It supersedes `notes.md` of this folder, which is kept unchanged as the pre-referee stage. Theorem numbers are those of `notes.md` wherever a result survives, so citations from the sibling sub-tracks stay valid; new results have new numbers.*

* **Sources read.**
  * The brief `../00-brief.md`, in full.
  * Paper 2 (`paper-steeper/sections/`):
    * `setup.tex`, `app-setup.tex`: `def:setup:data` ($X=\{0,1\}^*$, frozen noise), `def:setup:class`, `lem:setup:hull`, `lem:setup:coding` and its proof, the facts (F1)–(F5);
    * `absorb.tex`: (Dom), `thm:absorb:absorption`;
    * `split.tex`, `app-split.tex`: `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `thm:split:shared`;
    * `algstat.tex`, `app-algstat.tex`: `def:algstat:product`, `prop:algstat:product`, `prop:algstat:parity` and its proof, `prop:algstat:set`;
    * `teacher.tex`, `app-teacher.tex`: `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:sharpfloor`, `lem:teacher:twopart`, `thm:teacher:main`, `cor:teacher:fulltable`;
    * `computable.tex`: `prop:related:computable`; `limits.tex`.
  * The refereed record `research/tracks/steeper/notes-final.md` §1–§3.
  * Paper 1: `setting.tex`, `versions.tex` (`def:versions:variants`), `learn.tex` (`prop:learn:perquery`); `paper/NOTATION.md`.
  * The sibling sub-tracks, as they stand at the time of writing (neither has a `notes-final.md` yet): `../iid/notes.md` with its `referee-A.md` and `referee-B.md`, and `../teacher/notes.md` with its `referee-A.md` and `referee-B.md`. §9 aligns with them.
* **Scripts.** `checks/k1`–`k5` (the pre-referee checks, unchanged) and `checks/k6`–`k8` (new in this revision). All are deterministic or seeded, Python 3.11, with outputs saved next to them as `.out` files. The referees' scripts are in `referee_code/`.

**Status tags.**
* **[proved]**: full proof here (or a one-line derivation from a cited proved result).
* **[computed: kN(X)]**: checked by `checks/kN_*.py`, part (X) of its output `checks/kN_*.out`. **[computed: rA(k)]**, **[computed: rBk(X)]**: the referees' scripts in `referee_code/`.
* **[known: ref]**: standard or published; "(unverified)" when not checked against the source.
* **[proof sketch]**, **[conjecture]**, **[open]**: as named.
* **[refuted]**: false, with the counterexample; kept in the record. **[withdrawn]**: vacuous or mis-scoped as stated, replaced by the statement given.
* **Illustration (κ = 0)**: a number obtained by setting the unknown machine constant κ to 0; not a result about a reference machine.

---

## Notation

Notation follows `paper/NOTATION.md`: $n$ samples, $d$ input length, $N=2^d$, κ the machine constant, $c=\lambda/n$, $\mathrm{Hel}(P,Q)=1-\sum_y\sqrt{P(y)Q(y)}$ (also for a sub-probability $Q$), μ the input law, $\log=\log_2$. It is aligned with the sibling sub-tracks (§9). Changes against `notes.md`:

| symbol here | meaning | in `notes.md` | in `../iid/` | in `../teacher/` |
|---|---|---|---|---|
| $F(\pi)$ | fit, $-\log\nu_\pi(D)$; per-query: $-\sum_{i\le n}\log\nu_\pi(y_i\mid x_i)$ | $L(\pi)$ | $-\log L_n(\pi)$ ($L_n$ is a likelihood there) | $F(\pi)$, data reading |
| $\alpha_{\min}$ | least length with finite fit | $\alpha_0$ | — | — |
| $(\alpha_k,F_k)$; $(\alpha_\pm,F_\pm)$ | a generic kink point; left/right kink points | $(\alpha_0,L_0)$; $(\alpha_\pm,L_\pm)$ | — | $(\ell_0,F_0)$, reference point |
| $\pi_s$, $(\ell_s,F_s)$, $b$ | a product-$b$-sufficient program (Cor 3.3) | $\pi_0$, $(\ell_0,L_0)$, $b_0$ | — | — |
| $b_0$ | sufficiency deficiency of the good model $\pi_g$ (§4), with $2\log(d+1)$ | $b_0$ with $2\log d$ | — | $b_0'$ (identical now) |
| $\Gamma_t(\lambda)$, $\Gamma^\circ_t$ | combined floors of §4 | $\Psi_t(\lambda)$, $\Psi^\circ_t$ | — | ($\Psi_t(c)$ is a different object there) |
| $F^\sharp_t(I)$ | sharp floor for level $>t$ at information budget $I$ | $F_t(I_{\max})$ | — | $\mathrm{Floor}_{t+1}(I)=\max\{0,F^\sharp_t(I)\}$ at $B=\infty$ |
| $\ell^*$, $E$, $E^*$ | least length of an equivalent program; equivalent programs; shortest ones | $\ell_0$ | same | — |
| $S_n$ | $F(\pi^*)=-\log\nu(D_n)$, the sampled randomness | $L_0$ | $S_n$ | — |
| $\gamma(\pi)$ | Hellinger gap $\mathbb E_\mu\mathrm{Hel}(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))$ | $\mathrm{Hel}_\mu(\pi)$ | $\gamma(\pi)$ | — |
| $\gamma_=(\ell)$, $\gamma_<$, $\gamma_{\bar\ell}$, $\gamma_0$ | least positive gap at length exactly ℓ; below $\ell^*$; up to a cap $\bar\ell$; up to $\ell^*$ | $\gamma(\ell)$, $\gamma_-$, $\gamma_{\bar\ell}$, $\gamma_0$ | $\gamma_<$, $\gamma_L$ | — |
| $e(\pi)$ | evidence against π: $n\gamma(\pi)$ or $H_D(\pi)$ (§5) | — | — | — |

---

## 0. Summary

1. **λ-MAPs are read off the lower convex hull** (§2) [proved; computed: k1, k2; rB1].
   * For a data set $D$ and any countable class with finitely many programs per length, the lower boundary of $\mathrm{conv}\{(\ell(\pi),F(\pi))\}+\mathbb R^2_{\ge0}$ is the graph of $\breve\rho_D$, the greatest convex minorant of the product structure function $\rho_D(\alpha)=\min\{F(\pi):\ell(\pi)\le\alpha\}$. It is a polygon whose vertices $(\alpha_i,\rho_i)$ are attained at length exactly $\alpha_i$, with edge slopes $-\sigma_i$, $\sigma_1>\sigma_2>\dots>0$, and $\sigma_i\to0$ if there are infinitely many (Thm 2.1).
   * For λ > 0, π is a λ-MAP if and only if $F(\pi)=\breve\rho_D(\ell(\pi))$ and $-\lambda\in\partial\breve\rho_D(\ell(\pi))$. For $\sigma_{i+1}<\lambda<\sigma_i$ the λ-MAPs are the programs at vertex $i$; at $\lambda=\sigma_i$ they are the programs on the closed edge (Thm 2.2). The MAP value $\Phi_D(\lambda)$ and $\breve\rho_D$ are Legendre duals (Prop 2.3).
2. **A kink implies the split** (§3) [proved; computed: k1, k8; rB1].
   * A *left kink* of steepness $\sigma\in(0,\infty]$ and window $w_-$ at $(\alpha_-,F_-)$: every program shorter than $\alpha_--w_-$ has $F(\pi)\ge F_-+\sigma(\alpha_--\ell(\pi))$. A *right kink* of flatness τ and window $w_+$ at $(\alpha_+,F_+)$: every program longer than $\alpha_++w_+$ has $F(\pi)\ge F_+-\tau(\ell(\pi)-\alpha_+)$.
   * *Thm 3.2.* A left kink and $\lambda<\sigma$ give every λ-MAP length $\ge\alpha_--w_-$ and fit $\le F_-+\lambda w_-$; for $\lambda\ge1$ also two-part length $\le\alpha_-+F_-+(\lambda-1)w_-$. A right kink and $\lambda>\tau$ give length $\le\alpha_++w_+$. The strict inequalities are needed. **A zero-window kink with $\tau<\sigma$ is exactly a hull vertex**; with $\tau=\sigma$ it can be an interior point of an edge (corrected; referees A2/B2).
   * *Cor 3.3 (the split for one data set).* In a hypothesis class (`def:setup:class`), if $\pi_s$ is product-$b$-sufficient and every program shorter than $\ell_s-w$ loses at least σ bits of fit per bit saved, then for every $\lambda\in(1,\sigma)$ every λ-MAP $\hat\pi$ has $\ell_s-w\le\ell(\hat\pi)\le\ell_s+(b+\kappa)/(\lambda-1)$, fit within $\lambda w$ above and $\lambda(b+\kappa)/(\lambda-1)$ below $F_s$, and is product-$(b+(\lambda-1)w)$-sufficient.
   * *Thm 3.4.* "Every λ-MAP on $(\tau,\sigma)$ has length in $[\alpha',\alpha'']$" holds if and only if there are zero-window kinks at hull vertices of lengths $\ge\alpha'$ (steepness σ) and $\le\alpha''$ (flatness τ).
   * *Prop 3.5.* A universal member $U$ ((Dom) form) caps every left kink at $\alpha_k$ with $\alpha_k-w>\ell_U$: $\sigma\le1+(\ell_U+\kappa_0)/(\alpha_k-\ell_U)$. Every λ-MAP, λ > 1, then has length at most $\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$. The earlier sentence deriving a λ-independent cap from Cor 3.3(b) is **refuted** (A3/B3).
3. **The noisy random parity** (§4) [proved; computed: k4, k7, k8; rB2, rB4].
   * The full truth table has a left kink at the good model, with steepness exponential in $d$ whenever $\Gamma^\circ_{t_0}>H(p)$ (Prop 4.1).
   * *Prop 4.2.* Under a condition $C_{t_0}(\lambda)$ of the form $\lambda<\sigma(\lambda)$, with $\sigma(\cdot)$ nondecreasing, every λ-MAP has agreement level ≤ $t_0$, knows the parity up to $s(t_0)+2\log d+\kappa$ bits, has length in $[d-s(t_0)-\Lambda_1,\ d+\kappa_g+(b_0+\kappa)/(\lambda-1)]$, and holds few bits about the flip set. The λ-set is now **certified to be an interval** by a cell argument, and every reported range survives certification to 5 significant digits (k7). The class must contain a good model (A6(a)). New item (g) gives the agreement and error-probability bounds explicitly (B8).
   * *Comparison with `cor:teacher:fulltable`.* For $p<0.056$ and $t_0=1$ the range with the paper's floors $G_t$ contains the paper's window $(1,Nc_{\rm hi})$ and equals it at $d=20$; at $d=30$ (κ = 0) it is $(1,9.979\cdot10^6]$ against $Nc_{\rm hi}=9.791\cdot10^6$, and with the sharp floor $(1,1.0048\cdot10^7]$.
   * *Cor 4.3.* For every fixed $p<1/4$ and λ > 1, for all large $d$ with $\delta_E=O(d)$, the λ-MAP has level ≤ 2, and level 1 if $p<0.12331$. The limit of the level-2 floor exceeds $H(p)$ by at least **0.0187** on $(0,1/4]$ (corrected from 0.0188; A4/B9).
   * *Prop 4.4.* Set models have no steep kink at $\alpha\approx d$: steepness $\le1+O((\log d+\delta_E)/d)$. In explicit small classes the $O(\log d)$ code terms decide whether the set λ-MAP knows the parity for λ slightly above 1 (B5; k8(D)).
4. **A sample from ν has a kink at the shortest equivalent length** (§5, link to T1) [proved; computed: k3, k5, k6; rA, rB3, rB5, rB6].
   * *The scope is corrected (A1/B1, the major issue).* Paper 2's input set is countable, so no non-atomic input law exists and the old scheme "(iid)" was empty; Cor 5.7 was vacuous as stated. §5 now has three schemes: **(pq)** pairs i.i.d. from $\mu\otimes\nu$ with a fresh label at every query, repeats allowed, per-query likelihood (the object of `../iid/`); **(wor)** frozen labels on distinct inputs drawn without replacement from a finite $X_0$; **(fd)** a fixed domain, labels random (a single data set; the result is conditional on the domain).
   * *Lemma 5.2.* With probability ≥ 1 − ε, simultaneously for all programs, $F(\pi)-S_n>2\log e\cdot e(\pi)-2\ell(\pi)-2\log(1/\varepsilon)$, where the evidence $e(\pi)$ is $n\gamma(\pi)$ in (pq) and (wor) and $H_D(\pi)=\sum_{x\in\mathrm{dom}D}\mathrm{Hel}_x(\pi)$ in (fd).
   * *Thm 5.4.* The point $(\ell^*,S_n)$ has a zero-window left kink whose steepness is linear in $n$ (with probability ≥ 1 − ε, when $2\log e\cdot n\gamma_<-2\log(1/\varepsilon)\ge2\ell^*$), and for every τ > 1 a right kink of flatness τ with window $(\ell^*+\log(1/\varepsilon))/(\tau-1)$ (probability ≥ 1 − ε). If moreover $n>(\bar\ell+\log(1/\varepsilon))/(\log e\cdot\gamma_{\bar\ell})$ for a cap $\bar\ell>\ell^*$ and the left steepness exceeds $\tau_{\bar\ell}=1+(\ell^*+\log(1/\varepsilon))/(\bar\ell-\ell^*)$, then with probability ≥ 1 − 2ε the point is a hull vertex, and for λ between the two slopes the λ-MAPs are exactly the shortest equivalent programs.
   * *Finite samples.* Cor 5.5 and Thm 5.6 give explicit $n_0(\lambda,\ell^*,\gamma,\varepsilon)$. Under (wor) they need $n\le|X_0|$, which fails for k3's instance (B4); in the per-query check k6 ($n$ up to $2^{20}$) the hypotheses are met at large $n$, and every guarantee then holds in 200 of 200 samples.
   * *Cor 5.7 (pq).* Almost surely the left steepness grows linearly, the right slope has $\limsup\le1$, every fixed λ > 1 eventually selects $E^*$, and (new, from `../iid/` Thm 3.1) eventually the right slope is below 1 and the left steepness above 1, so **λ = 1 also lies inside the kink**.
   * *Prop 5.8.* The margin is necessary: a shorter competitor with mean KL $\bar K$ beats the truth unless $n\gtrsim\lambda\Delta/\bar K$.
   * *Prop 5.10 (new; the frozen object).* With frozen labels and an atomic μ, Lemma 5.1's bound and Cor 5.7(c) fail [refuted: rA(1), rB6, k6(A),(C)]; what survives is the (fd) form conditional on the domain and "equivalent on the run".
5. **Interpretation** (§6). Along the hull, the λ-MAP keeps exactly the blocks of program bits whose hull-edge rate exceeds λ bits of fit per bit. Beyond a sufficient program the rate is at most one bit per bit plus a constant, so λ > 1 refuses to buy noise. With private randomness a model parameter's bits are bought at rates of order $n\gamma/\ell^*$ (samples) or $N/d$ (full parity table); with shared randomness at rate 1.
6. **Cross-track consistency** (§9). Definitions and objects are aligned with `../iid/` (same per-query object, same $\ell^*,E,E^*,\gamma,S_n,\delta^*$) and `../teacher/` (same fit $F$, same offset $b_0$, kink lemmas related as special cases).

### 0.1 Response to the referees

Both referees found no fatal issue and one major issue (the same one). Each item below is resolved in this file; where the referee was right the claim is corrected and the old one is kept with its status.

| issue | resolution | where |
|---|---|---|
| A1 / B1 (major): scheme (iid) empty on countable $X$; Cor 5.7 vacuous; frozen reading false | Accepted. §5 restated for (pq), (wor), (fd). Old (iid) statements marked [withdrawn]; the frozen reading of Cor 5.7(c) marked [refuted] with both referees' counterexamples, re-derived exactly in k6(C). New Prop 5.10 states what fails and what survives. The per-query check k6 replaces the missing infinite-sample evidence. | Setting 5.0, Lemma 5.1, Cor 5.7, Prop 5.10, Remark 5.11 |
| A2 / B2: Thm 3.2(d) needs τ < σ; allow σ = ∞; strictness | Accepted. Hypothesis added; σ = ∞ allowed in Def 3.1; strictness remark added. Confirmed in k8(A) (25 collinear zero-window kinks with τ = σ, none a vertex; 2687 with τ < σ, all vertices). | Def 3.1, Thm 3.2(d), Remark 3.2′ |
| A3 / B3: sentence after Prop 3.5 | Accepted; old sentence [refuted] (referee A's instance); replaced by the absorption bound, checked in 54,000 cases (k8(B)). | Prop 3.5(ii) |
| A4 / B9: 0.0188 is rounded up | Accepted; now 0.0187, printed rounded down (k7(d)). | Cor 4.3 |
| A5: coding bound needs a hypothesis class, not (F1) alone | Accepted. | §1, Remark 2.5, Cor 3.3 |
| A6(a): Prop 4.2's class must contain a good model | Accepted, as in `prop:related:computable`(a). | Prop 4.2 |
| A6(b) / B11: the λ-set of Prop 4.2 not proved to be an interval | Accepted. Prop 4.2(ii) gives a sufficient cell condition that is an interval by construction; k7 certifies every reported range. | Prop 4.2(ii), Numbers |
| A6(c): which number is quoted | Fixed: both are given and labelled. | §0 item 3, §4 |
| A7 / B11: §0 summaries stronger than theorems | Fixed (λ ≥ 1 for the two-part bound; $A\ge2\ell^*$; "flatness τ"). | §0 |
| A8 / B10: remark after Prop 5.8 overclaims; k5 ranges family-specific | Accepted; restricted and marked [proof sketch]; ranges labelled "in k5's family", with rB5's wider ranges added. | after Prop 5.8 |
| A9: λ = 1.5 omitted from k3's numbers | Added. | §5 numbers |
| A10: Hoeffding status; Ville non-strict; overloaded symbols; remark after Def 3.1 | All fixed. Hoeffding located via two secondary sources (unverified against the original); Maclaurin's inequality given as the exact identity behind the step; computed in k6(A) and rA(7). | Lemma 5.1, Lemma 5.3, Notation, Def 3.1 |
| B4: k3's sample sizes exceed $\lvert X_0\rvert$; τ_L lines are not checks of Thm 5.4(iii) | Accepted. Stated that (wor) needs $n\le\lvert X_0\rvert$; k3's τ_L lines declared non-checks; two instances where Thm 5.4(iii), Cor 5.5 and Thm 5.6 apply are added: rB3(E2) (wor, $d=12$) and k6 (pq, $d=8$, $n$ up to $2^{20}$). | §5 numbers |
| B5: set-model illustration depends on the code for $v$ | Accepted and reproduced independently (k8(D)). Old reading [refuted as code-independent]. | §4 illustration |
| B6: zero-window steepness at the exact good model is a rate-code artifact | Accepted; the windowed steepness leads. | §4 illustration |
| B7: two-kink ranges incomplete | Fixed: parity + noise on $(1.223,12.76)$. | §4 illustration |
| B8: $u\ge0.993$, $e\le0.208$ not among Prop 4.2's conclusions | Added as item (g), with the formula (k7(b)). | Prop 4.2(g) |

---

## 1. Setting

* **Class.** $\mathcal C$ is a countable set of programs π with lengths $\ell(\pi)\in\{0,1,2,\dots\}$, finitely many of each length, each with a product hypothesis $\nu_\pi$ (an lsc conditional semimeasure, `def:setup:product`). §2 and §3 hold verbatim for any family of points $(\ell,F)$ with integer $\ell\ge0$, $F\in[0,\infty]$ and finitely many points per length; this includes shared classes and set models, where the "length" is the model's complexity. Kraft's inequality $\sum_\pi2^{-\ell(\pi)}\le1$ is used only in §5.
* **Data and fit.** $D$ is a data set (a finite partial function, frozen noise: `def:setup:data`). The fit of π is $F(\pi):=-\log\nu_\pi(D)\in[0,\infty]$, and $J_\lambda(\pi):=\lambda\ell(\pi)+F(\pi)$ (`def:setup:objectives`). The point set is $\mathcal A:=\{(\ell(\pi),F(\pi)):F(\pi)<\infty\}$, assumed nonempty; in $\Hcl{\times}$ the fair coin has finite fit. In §5 (pq) the fit is the per-query sum $F(\pi):=-\sum_{i\le n}\log\nu_\pi(y_i\mid x_i)$, and §2–§3 apply to that point set.
* **Structure function.** $\rho_D(\alpha):=\min\{F(\pi):\ell(\pi)\le\alpha\}$ ($+\infty$ if no finite point qualifies). For $\Hcl{\times}$ this is $\rho^\times_D$ of `def:algstat:product`. It is nonincreasing and right-continuous. Put $\alpha_{\min}:=\min\{\ell(\pi):F(\pi)<\infty\}$.
* **Convex minorant.** $\breve\rho_D$ is the greatest convex function $\mathbb R\to(-\infty,+\infty]$ with $\breve\rho_D\le\rho_D$.
* **Sufficiency.** π is product-$b$-sufficient if $\ell(\pi)+F(\pi)\le K(y_D\mid\mathrm{dom}D)+b$ (`def:algstat:product`).
* **The coding bound needs a hypothesis class** [proved; corrected after A5]. If $\mathcal C$ is a hypothesis class in the sense of `def:setup:class` (c.e., prefix-free, the $\nu_\pi$ lsc uniformly in π), then `lem:setup:coding` gives $\ell(\pi)+F(\pi)\ge K(y_D\mid\mathrm{dom}D)-\kappa$ for every π and $D$, with κ depending on the class. The proof applies (F2) to one fixed program that lower-semicomputes $y\mapsto\nu_\pi(\mathrm{dom}D\mapsto y)$ from $(\pi,\mathrm{dom}D)$; uniform lower semicomputability is what makes that program exist. (F1) alone does not suffice: a countable class whose program "0" (length 1) is the deterministic table of an incompressible string $y_D$ has $\ell+F=1$, far below $K(y_D\mid\mathrm{dom}D)$. `notes.md` said "a data-set class whose programs satisfy (F1)"; that hypothesis is [withdrawn] and replaced here.

---

## 2. λ-MAPs and the lower convex hull

The statements and proofs of this section are those of `notes.md` §2, with $L$ renamed $F$ and $\alpha_0$ renamed $\alpha_{\min}$. Referee A re-derived them line by line and found them correct; referee B checked every statement in exact arithmetic on 1500 point sets with an independent method (an $O(n^3)$ extreme-point test, rB1).

**Theorem 2.1 (the hull of a data set) [proved; computed: k1(A), rB1(T1)].** Define vertices by gift wrapping.
* $v_0:=(\alpha_{\min},\rho_0)$ with $\rho_0:=\rho_D(\alpha_{\min})$.
* Given $v_i=(\alpha_i,\rho_i)$, put $\sigma_{i+1}:=\sup\{(\rho_i-F(b))/(\ell(b)-\alpha_i):b\in\mathcal A,\ \ell(b)>\alpha_i\}$.
* If this set is empty or $\sigma_{i+1}\le0$, stop: $v_i$ is the last vertex, with index $q:=i$.
* Otherwise let $\alpha_{i+1}$ be the largest $\ell(b)$ attaining the supremum, and $\rho_{i+1}:=\rho_i-\sigma_{i+1}(\alpha_{i+1}-\alpha_i)$.

Then:
* (i) The suprema are attained. Every vertex is attained by a program of length exactly $\alpha_i$, and $\rho_i=\rho_D(\alpha_i)$. The slopes satisfy $\sigma_1>\sigma_2>\dots>0$. If there are infinitely many vertices, then $\alpha_i\to\infty$ and $\sigma_i\to0$.
* (ii) Let $P$ be $+\infty$ on $(-\infty,\alpha_{\min})$, linear between consecutive vertices, and equal to $\rho_q$ on $[\alpha_q,\infty)$ if $q<\infty$. Then $P=\breve\rho_D$.
* (iii) For $\alpha\ge\alpha_{\min}$, $\breve\rho_D(\alpha)=\min\{y:(\alpha,y)\in\mathrm{conv}(\mathcal A)+\mathbb R^2_{\ge0}\}$.

*Proof.*
* *(i), attainment.* Fix $i$ and suppose some $b$ with $\ell(b)>\alpha_i$ has slope $s_b:=(\rho_i-F(b))/(\ell(b)-\alpha_i)>0$. Every $b'$ with slope at least $s_b$ has $0\le F(b')\le\rho_i-s_b(\ell(b')-\alpha_i)$, hence $\ell(b')\le\alpha_i+\rho_i/s_b$. Only finitely many points qualify, so the supremum is a maximum.
* *(i), $\rho_i=\rho_D(\alpha_i)$, by induction.* For $i=0$ it holds by definition. Assume it for $i$, so every point with $\ell\le\alpha_i$ has $F\ge\rho_i>\rho_{i+1}$. A point $b$ with $\alpha_i<\ell(b)\le\alpha_{i+1}$ has slope at most $\sigma_{i+1}$, so $F(b)\ge\rho_i-\sigma_{i+1}(\ell(b)-\alpha_i)\ge\rho_{i+1}$. Hence $\rho_D(\alpha_{i+1})\ge\rho_{i+1}$; the maximising point at length $\alpha_{i+1}$ has fit exactly $\rho_{i+1}$.
* *(i), strict decrease.* Suppose $\sigma_{i+1}\ge\sigma_i$ for some $i\ge1$. The slope of $v_{i+1}$ seen from $v_{i-1}$ is $(\sigma_i(\alpha_i-\alpha_{i-1})+\sigma_{i+1}(\alpha_{i+1}-\alpha_i))/(\alpha_{i+1}-\alpha_{i-1})\ge\sigma_i$. Strict inequality contradicts the definition of $\sigma_i$; equality contradicts the maximality of $\alpha_i$.
* *(i), infinitely many vertices.* The $\alpha_i$ are strictly increasing integers. Also $\sum_i\sigma_i(\alpha_i-\alpha_{i-1})=\rho_0-\lim\rho_i\le\rho_0<\infty$ (fits are ≥ 0 because $\nu_\pi(D)\le1$) with every $\alpha_i-\alpha_{i-1}\ge1$, so $\sigma_i\to0$.
* *(ii), $P$ is a convex minorant.* Its slopes $-\sigma_1<-\sigma_2<\dots\le0$ increase, and it is $+\infty$ left of $\alpha_{\min}$. Every finite point lies on or above $P$: if $\ell(b)\in(\alpha_i,\alpha_{i+1}]$, its slope from $v_i$ is at most $\sigma_{i+1}$; if $\ell(b)>\alpha_q$, its slope from $v_q$ is at most 0; if $\ell(b)=\alpha_{\min}$, $F(b)\ge\rho_0$. $P$ is nonincreasing, so $P(\alpha)\le P(\ell(b))\le F(b)$ whenever $\ell(b)\le\alpha$: $P\le\rho_D$.
* *(ii), $P$ is the greatest one.* Let $g$ be convex with $g\le\rho_D$. At the vertices $g\le\rho_i=P$; between consecutive vertices $g$ lies below the chord, which is $P$; beyond $\alpha_q$, $g\le\rho_D=\rho_q=P$; left of $\alpha_{\min}$, $P=+\infty$.
* *(iii).* $\mathcal A\subseteq\mathrm{epi}P$, which is convex and closed under adding $\mathbb R^2_{\ge0}$. Conversely, $(\alpha,P(\alpha))$ is a convex combination of two vertices for $\alpha\in[\alpha_{i-1},\alpha_i]$, and $v_q+(\alpha-\alpha_q,0)$ for $\alpha\ge\alpha_q$. ∎

**Theorem 2.2 (λ-MAPs are where the hull's slope crosses −λ) [proved; computed: k1(B), k2(A), rB1(T2)].** Put $\sigma_0:=+\infty$, and $\sigma_{q+1}:=0$ if $q<\infty$. Let λ > 0.
* (i) $\min_\pi J_\lambda(\pi)=\min_i(\lambda\alpha_i+\rho_i)$ is attained.
* (ii) π is a λ-MAP if and only if $F(\pi)=\breve\rho_D(\ell(\pi))$ and $-\lambda\in\partial\breve\rho_D(\ell(\pi))$. Explicitly: if $\sigma_{i+1}<\lambda<\sigma_i$, the λ-MAPs are exactly the programs at $v_i$; if $\lambda=\sigma_i$ with $i\ge1$, they are exactly the programs on the closed segment $[v_{i-1},v_i]$, interior collinear points included. The set of λ-MAPs is finite and nonempty.
* (iii) Ties between different points occur only at the countably many values $\sigma_i$, which accumulate at most at 0. A point is the unique minimising point for every λ in an open interval if and only if it is a vertex. Several programs at one point always tie.
* (iv) The MAP length is nonincreasing in λ and the MAP fit nondecreasing.
* (v) λ = 0: a program minimising $F$ exists if and only if the vertex sequence is finite.

*Proof.* For every π with finite fit, $J_\lambda(\pi)\ge\lambda\ell(\pi)+\breve\rho_D(\ell(\pi))\ge m_\lambda:=\inf_\alpha(\lambda\alpha+\breve\rho_D(\alpha))$. On $[\alpha_{\min},\infty)$ the function $\varphi(\alpha)=\lambda\alpha+\breve\rho_D(\alpha)$ is piecewise linear with slopes $\lambda-\sigma_i$ on $(\alpha_{i-1},\alpha_i)$ and λ > 0 beyond $\alpha_q$, increasing in $i$. Let $i^*:=\min\{i:\sigma_{i+1}\le\lambda\}$; it exists because $\sigma_i\to0<\lambda$ or $\sigma_{q+1}=0$. Then φ is nonincreasing up to $\alpha_{i^*}$ and nondecreasing after, so $m_\lambda=\lambda\alpha_{i^*}+\rho_{i^*}$ is attained at $v_{i^*}$. Hence π is a minimiser iff both inequalities are equalities, which is (ii); the argmin of φ is $\{\alpha_i\}$ or $[\alpha_{i-1},\alpha_i]$. Finiteness: finitely many programs per length. (iii): at a breakpoint the two ends of the edge tie, so an open interval with a unique MAP point lies in some $(\sigma_{i+1},\sigma_i)$. (iv) as in `lem:setup:hull`(ii). (v): if $q<\infty$, $\rho_q=\min F$; otherwise the $\rho_i$ decrease strictly and $\inf F$ is not attained. ∎

**Proposition 2.3 (duality: MAP profile ↔ hull) [proved; computed: k1(C), rB1(T3)].** Let $\Phi_D(\lambda):=\min_\pi J_\lambda(\pi)$ for λ > 0.
* (i) $\Phi_D(\lambda)=\min_i(\lambda\alpha_i+\rho_i)$; it is concave and piecewise linear, with derivative $\alpha_i$ on $(\sigma_{i+1},\sigma_i)$: the derivative of the optimal value is the MAP length.
* (ii) For $\alpha\ge\alpha_{\min}$, $\breve\rho_D(\alpha)=\sup_{\lambda>0}(\Phi_D(\lambda)-\lambda\alpha)$; for $\alpha<\alpha_{\min}$ the supremum is $+\infty$.

*Proof.* (i) is Thm 2.2(i). (ii) "≥": $\Phi_D(\lambda)\le\lambda\alpha+\breve\rho_D(\alpha)$. "≤": for $\alpha\in[\alpha_{i-1},\alpha_i]$ take $\lambda=\sigma_i$; for $\alpha\ge\alpha_q$ let $\lambda\downarrow0$; for $\alpha<\alpha_{\min}$, $\Phi_D(\lambda)-\lambda\alpha\ge\lambda(\alpha_{\min}-\alpha)\to\infty$. ∎

**Remarks.**
* *2.4 (relation to the paper) [remark].* `lem:setup:hull` is the population version, with points $(\ell,R)$ and normal $(c,1)$; Thm 2.2 is the same on one data set with $(\ell,F)$ and normal $(\lambda,1)$. The constrained problem $\min\{F:\ell\le\alpha\}$ of `lem:setup:hull`(iv) is the structure function itself, so the λ-MAPs are the constrained solutions whose point lies on the convex minorant with a supporting slope $-\lambda<0$; points of $\rho_D$ strictly above $\breve\rho_D$ are never selected. Prop 2.3 is the Legendre–Fenchel transform [known: standard convex analysis, e.g. Rockafellar, *Convex Analysis*, §12 (section number unverified)].
* *2.5 (the sufficiency line bounds the hull) [proved; hypothesis class required, after A5].* In a hypothesis class, $\rho_D(\alpha)\ge K(y_D\mid\mathrm{dom}D)-\kappa-\alpha$; the right side is affine, so the same bound holds for $\breve\rho_D$. If $(\alpha',\breve\rho_D(\alpha'))$ is the point of a $b$-sufficient program, then for every $\alpha>\alpha'$,
  $$\frac{\breve\rho_D(\alpha')-\breve\rho_D(\alpha)}{\alpha-\alpha'}\le1+\frac{b+\kappa}{\alpha-\alpha'}.$$
  [computed: rB1(T9), 183,337 cases in class form.]

---

## 3. A kink implies the split

**Definition 3.1 (kinks) [revised after A2, A10].** Let $\sigma\in(0,\infty]$, $\tau\ge0$ and $w_\pm\ge0$.
* $D$ has a **left kink of steepness σ and window $w_-$ at $(\alpha_-,F_-)$** if $\rho_D(\alpha_-)\le F_-$ and every π with $\ell(\pi)<\alpha_--w_-$ has $F(\pi)\ge F_-+\sigma(\alpha_--\ell(\pi))$. For σ = ∞ this means that no program shorter than $\alpha_--w_-$ has finite fit.
* $D$ has a **right kink of flatness τ and window $w_+$ at $(\alpha_+,F_+)$** if $\rho_D(\alpha_+)\le F_+$ and every π with $\ell(\pi)>\alpha_++w_+$ has $F(\pi)\ge F_+-\tau(\ell(\pi)-\alpha_+)$.
* A **$(\sigma,\tau)$-kink at $(\alpha_k,F_k)$ with windows $(w_-,w_+)$** is both, at the same point.

In words: outside the window, giving up length costs at least σ bits of fit per bit, and adding length buys at most τ bits per bit. The brief's "(σ, ε)-kink" is $\tau=1+\varepsilon$.
* *Additive slack becomes a window* [proved; corrected after A10]. Let $b_1\ge0$. If $F(\pi)\ge F_-+\sigma(\alpha_--\ell(\pi))-b_1$ for every π shorter than $\alpha_-$, then for every $w>b_1/\sigma$ there is a left kink of steepness $\sigma-b_1/w>0$ and window $w$. (For $\ell(\pi)<\alpha_--w$, $b_1\le(b_1/w)(\alpha_--\ell(\pi))$.) Both conditions are needed: with $b_1<0$ the claimed steepness $\sigma+|b_1|/w$ fails for large $\alpha_--\ell$, and Def 3.1 requires σ > 0. [computed: rB1(T10), 44,295 cases.]
* *Equivalent forms.* The left-kink condition is equivalent to $\rho_D(\alpha)\ge F_-+\sigma(\alpha_--\alpha)$ for all $\alpha<\alpha_--w_-$. The right-kink condition is implied by $\rho_D(\alpha)\ge F_+-\tau(\alpha-\alpha_+)$ for all $\alpha>\alpha_++w_+$; the converse fails, since a program inside the window with a very low fit lowers $\rho_D$ to the right of the window, while the definition does not constrain it.

**Theorem 3.2 (a kink locates the λ-MAPs) [proved; computed: k1(D), k2(C), k8(A), rB1(T4, T5)].**
* (a) **Left kink.** If $D$ has a left kink (σ, $w_-$) at $(\alpha_-,F_-)$ and $\lambda<\sigma$, every λ-MAP $\hat\pi$ satisfies $\ell(\hat\pi)\ge\alpha_--w_-$ and $F(\hat\pi)\le F_-+\lambda(\alpha_--\ell(\hat\pi))\le F_-+\lambda w_-$. If moreover $\lambda\ge1$, then $\ell(\hat\pi)+F(\hat\pi)\le\alpha_-+F_-+(\lambda-1)w_-$, and if $\alpha_-+F_-\le K(y_D\mid\mathrm{dom}D)+b$, then $\hat\pi$ is product-$(b+(\lambda-1)w_-)$-sufficient.
* (b) **Right kink.** If $D$ has a right kink (τ, $w_+$) at $(\alpha_+,F_+)$ and $\lambda>\tau$, every λ-MAP has $\ell(\hat\pi)\le\alpha_++w_+$.
* (c) Both together: for $\lambda\in(\tau,\sigma)$, every λ-MAP has length in $[\alpha_--w_-,\ \alpha_++w_+]$.
* (d) **Zero windows with τ < σ are vertices.** If $D$ has a $(\sigma,\tau)$-kink with $w_-=w_+=0$ at $(\alpha_k,F_k)$ **and $\tau<\sigma$**, then $\rho_D(\alpha_k)$ is attained at length exactly $\alpha_k$, and $(\alpha_k,\rho_D(\alpha_k))$ is a vertex of $\breve\rho_D$ whose λ-interval contains $(\tau,\sigma)$; for $\lambda\in(\tau,\sigma)$ the λ-MAPs are exactly the programs at that point. Conversely, every vertex $v_i$ is a zero-window $(\sigma_i,\sigma_{i+1})$-kink at $v_i$, with $\sigma_{i+1}<\sigma_i$ (and $\sigma_0=\infty$ at $v_0$).

*Proof.*
* *(a).* Let $\pi_-$ have $\ell(\pi_-)\le\alpha_-$ and $F(\pi_-)\le F_-$. Then $J_\lambda(\hat\pi)\le\lambda\alpha_-+F_-$. If $\ell(\hat\pi)<\alpha_--w_-$, the kink gives $J_\lambda(\hat\pi)\ge\lambda\alpha_-+F_-+(\sigma-\lambda)(\alpha_--\ell(\hat\pi))>\lambda\alpha_-+F_-$, a contradiction (for σ = ∞, $F(\hat\pi)=\infty$). The fit bound is $J_\lambda(\hat\pi)\le\lambda\alpha_-+F_-$ rearranged; subtract $(\lambda-1)\ell(\hat\pi)$ for the two-part bound, using $\lambda\ge1$ and $\alpha_--\ell(\hat\pi)\le w_-$. The argument is pointwise; it does not need the infimum over shorter programs to be attained.
* *(b).* If $\ell(\hat\pi)>\alpha_++w_+$, then $J_\lambda(\hat\pi)\ge\lambda\alpha_++F_++(\lambda-\tau)(\ell(\hat\pi)-\alpha_+)>\lambda\alpha_++F_+\ge J_\lambda(\pi_+)$.
* *(c)* combines (a) and (b).
* *(d), forward.* A program with fit $\le F_k$ at a length below $\alpha_k$ would violate the left kink, so $\rho_D(\alpha_k)\le F_k$ is attained at length $\alpha_k$. By (c), every λ-MAP for $\lambda\in(\tau,\sigma)$ has length $\alpha_k$ and hence fit $\rho_D(\alpha_k)$. Since τ < σ, the interval is open and nonempty, and the MAP point is the same on it; by Thm 2.2(iii) it is a vertex.
* *(d), converse.* By convexity, $\breve\rho_D(\ell)\ge\rho_i+\sigma_i(\alpha_i-\ell)$ for $\ell<\alpha_i$ and $\breve\rho_D(\ell)\ge\rho_i-\sigma_{i+1}(\ell-\alpha_i)$ for $\ell>\alpha_i$; every point lies above $\breve\rho_D$. ∎

**Remark 3.2′ (the hypotheses of Thm 3.2 are needed) [proved; computed: k8(A), rA(2), rB1].**
* *τ < σ in (d).* The points $(0,10),(1,5),(2,0)$: the middle point is a zero-window (5, 5)-kink, a λ-MAP point only at λ = 5, together with both ends; it is not a vertex. In k8(A), over 1200 random point sets, 25 zero-window kinks with τ = σ occur, none a vertex; all 2687 with τ < σ are vertices. `notes.md` §0 item 2 ("zero-window kinks at one point are exactly the hull vertices") and Thm 3.2(d) without τ < σ are **[refuted]** by this example and corrected above.
* *Strict inequalities in (a) and (b).* At λ = σ a λ-MAP can lie left of $\alpha_--w_-$ (1487 cases in k8(A); 3494 in rB1(T4)), and at λ = τ right of $\alpha_++w_+$ (3357 cases in rB1(T4)).

**Corollary 3.3 (the split theorem for one data set) [proved; computed: rB1(T8)].** Let $\mathcal C$ be a hypothesis class of data-set hypotheses (`def:setup:class`), so that the coding bound holds (§1). Let $\pi_s$ be product-$b$-sufficient for $D$, with $\ell_s:=\ell(\pi_s)$ and $F_s:=F(\pi_s)$.
* (a) **Sufficiency is a right kink.** For every τ > 1, $D$ has a right kink of flatness τ and window $(b+\kappa)/(\tau-1)$ at $(\ell_s,F_s)$. For every λ > 1, every λ-MAP satisfies
  $$\ell(\hat\pi)\le\ell_s+\frac{b+\kappa}{\lambda-1},\qquad F(\hat\pi)\ge F_s-\frac{\lambda(b+\kappa)}{\lambda-1}.$$
* (b) **The split.** Suppose also that $F(\pi)\ge F_s+\sigma(\ell_s-\ell(\pi))$ whenever $\ell(\pi)<\ell_s-w$. Then for every $\lambda\in(1,\sigma)$, every λ-MAP $\hat\pi$ satisfies
  $$\ell_s-w\le\ell(\hat\pi)\le\ell_s+\frac{b+\kappa}{\lambda-1},\qquad F_s-\frac{\lambda(b+\kappa)}{\lambda-1}\le F(\hat\pi)\le F_s+\lambda w,$$
  and $\hat\pi$ is product-$(b+(\lambda-1)w)$-sufficient.

*Proof.* (a), the kink: by the coding bound and sufficiency, $F(\pi)\ge K(y_D\mid\mathrm{dom}D)-\kappa-\ell(\pi)\ge F_s-(\ell(\pi)-\ell_s)-(b+\kappa)$, which is at least $F_s-\tau(\ell(\pi)-\ell_s)$ once $(\tau-1)(\ell(\pi)-\ell_s)\ge b+\kappa$. (a), the MAP bounds: $\lambda\ell(\hat\pi)+F(\hat\pi)\le\lambda\ell_s+F_s$ and $\ell(\hat\pi)+F(\hat\pi)\ge\ell_s+F_s-b-\kappa$; subtract. (b) is (a) with Thm 3.2(a). ∎

The first half of (a) is `prop:algstat:product` with the sophistication replaced by the length of any sufficient program. The content of (b) is the left side: steepness σ > 1 outside a window. Sufficiency alone gives only σ = 1 (Remark 2.5 read leftwards), and then $(1,\sigma)$ is empty.

**Theorem 3.4 (stable MAP lengths ⟺ kinks at hull vertices) [proved; computed: k1(E), rA(9), rB1(T6)].** Let $0\le\tau<\sigma\le\infty$ and $\alpha'\le\alpha''$. Let $i$ be the index with $\sigma_{i+1}<\sigma\le\sigma_i$, and $j$ the index with $\sigma_{j+1}\le\tau<\sigma_j$. The following are equivalent:
* (1) every λ-MAP with $\lambda\in(\tau,\sigma)$ has length in $[\alpha',\alpha'']$;
* (2) $D$ has a zero-window left kink of steepness σ at a point $(\alpha_-,\rho_D(\alpha_-))$ with $\alpha_-\ge\alpha'$, and a zero-window right kink of flatness τ at a point $(\alpha_+,\rho_D(\alpha_+))$ with $\alpha_+\le\alpha''$.

Moreover one can take $\alpha_-=\alpha_i$ and $\alpha_+=\alpha_j$, and the λ-MAP lengths over $\lambda\in(\tau,\sigma)$ have minimum $\alpha_i$ and maximum $\alpha_j$. The index $j$ exists unless τ = 0 and the vertex sequence is infinite; then (1) and (2) both fail for every finite $\alpha''$.

*Proof.* (2) ⇒ (1) is Thm 3.2(c). (1) ⇒ (2): $i=\min\{i:\sigma_{i+1}<\sigma\}$ and $j\ge i$ because $\sigma_{j+1}\le\tau<\sigma$. On the nonempty interval $(\max(\tau,\sigma_{i+1}),\sigma)\subseteq(\sigma_{i+1},\sigma_i]$ the MAP point is $v_i$, so $\alpha_i\ge\alpha'$; on $(\tau,\min(\sigma,\sigma_j))$ it is $v_j$, so $\alpha_j\le\alpha''$. By Thm 3.2(d), $v_i$ is a zero-window left kink of steepness $\sigma_i\ge\sigma$ and $v_j$ a zero-window right kink of flatness $\sigma_{j+1}\le\tau$. The extremes follow from monotonicity (Thm 2.2(iv)). ∎

**Proposition 3.5 (a universal member flattens every kink and caps every MAP) [proved; computed: k1(F), k8(B), rB1(T7)].** Suppose the class contains a program $\pi_U$, with $F_U:=F(\pi_U)$ and $\ell_U:=\ell(\pi_U)$, such that $F_U\le F(\pi)+\ell(\pi)+\kappa_0$ for all π. In product classes no such member exists (`cor:absorb:nouniversal`); in shared classes it is (Dom) of `thm:absorb:absorption`.
* (i) Every left kink (σ, w) at $(\alpha_k,F_k)$ with $\alpha_k-w>\ell_U$ has
  $$\sigma\le\frac{\alpha_k+\kappa_0}{\alpha_k-\ell_U}=1+\frac{\ell_U+\kappa_0}{\alpha_k-\ell_U}.$$
  So every left kink steeper than $1+\epsilon$ with $\alpha_k-w>\ell_U$ sits at $\alpha_k\le\ell_U+(\ell_U+\kappa_0)/\epsilon$.
* (ii) For every λ > 1, every λ-MAP has length at most $(\lambda\ell_U+\kappa_0)/(\lambda-1)=\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$. This is at most $\ell_U+(\ell_U+\kappa_0)/\epsilon$ exactly when $\lambda\ge1+\epsilon$.

*Proof.* (i) Let $\pi_k$ attain $\rho_D(\alpha_k)\le F_k$ with $\ell(\pi_k)\le\alpha_k$. Then $F_U\le F_k+\alpha_k+\kappa_0$. Since $\ell_U<\alpha_k-w$, the kink gives $F_U\ge F_k+\sigma(\alpha_k-\ell_U)$. (ii) $\lambda\ell(\hat\pi)+F(\hat\pi)\le\lambda\ell_U+F_U\le\lambda\ell_U+F(\hat\pi)+\ell(\hat\pi)+\kappa_0$; this is `thm:absorb:absorption`(a) for data sets, and Cor 3.3(a)'s argument with the class's best two-part code in place of $K$. ∎

**[refuted] (`notes.md`, the sentence after Prop 3.5):** "By Cor 3.3(b), λ-MAPs for λ > 1 stay below that length", i.e. below $\ell_U+(\ell_U+\kappa_0)/\epsilon$. Cor 3.3(b) gives lower bounds on MAP length, not upper bounds, and the claim is false for $\lambda\in(1,1+\epsilon)$. *Counterexample* (rA(3), k8(B)): $U=(2,15)$, $A=(5,10)$, $\kappa_0=0$, ε = 1; (Dom) holds; at λ = 3/2, $J(U)=18>J(A)=17.5$, so the MAP has length $5>4$. Prop 3.5(ii) is the correct statement: k8(B) finds no violation of it in 54,000 cases, no violation of the ε-cap for $\lambda\ge1+\epsilon$, and 5911 violations of the ε-cap for $\lambda\in(1,1+\epsilon)$.

In kink language, Prop 3.5 is `thm:split:shared`: with shared randomness there is no kink steeper than $1+\epsilon$ beyond $\ell_U+(\ell_U+\kappa_0)/\epsilon$, and no λ-MAP longer than $\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$.

**Remark 3.6 (reading) [remark].** The λ-MAP is chosen by local rates only: λ against the hull's edge slopes. Three consequences: the split is stable on a λ-interval exactly when there is a kink (Thm 3.4); its location is determined up to the window (Thm 3.2); its sufficiency deficiency grows by at most $(\lambda-1)$ times the left window (Thm 3.2(a)). Nothing forces a unique kink. A data set may have several vertices with $\sigma_i>1$, and then different λ select different "models"; two kinks occur for a parity plus a structured error rule (§4 illustration; `../teacher/` §4).

---

## 4. The noisy random parity

The instance is `def:teacher:instance` with $m=d$ (idiosyncratic errors), $B=\infty$ and the full truth table $D$.
* $N=2^d$; $|E|=s_0=pN$ with $p<1/4$; $L_E=\log\binom{N}{pN}$; the deficiency is $\delta_E=L_E-K(E\mid a,K(a))$.
* The fit of a program is $F(\pi)=NR(\pi)$, with $R$ the risk under uniform inputs.
* $\kappa_g:=2\log d+K(p)+\kappa$. For $p=2^{-r}$ we use $K(p)\le2\log r$, as in `def:teacher:instance`; for $p=h/2^e$, $K(p)\le2\log(h+1)+2\log(e+1)$, as in `tab:algstat:numbers`.
* $\Lambda_1=4\log d+\kappa$, $s(t)=2t+2\log(t+1)$, $G_t=1-\log(1+2^{-t}+2p)$, $\theta_t=\frac12+2^{-t-1}$.
* **Sharp floor.** For an information budget $I\ge0$,
  $$F^\sharp_t(I):=\sup_{g\ge1}\Big[1-\log\Big(1+(1-2p)2^{-t}+2p\big(2\gamma_g(I)+2^{1-g}\big)\Big)\Big],$$
  where $\gamma_g(I)=\sqrt{j\ln2/(2s_0)}$ and $j$ is the least integer with $j-2\log(j+1)>\delta_E+I+1+2\log d+2\log s_0+g+2\log g+\kappa$. This is `lem:teacher:sharpfloor` ($m=d$, $B=\infty$) for programs of level $>t$, i.e. $u(\pi)\le\theta_t$, with $I(\pi)\le I$: then $R(\pi)\ge F^\sharp_t(I)$. $F^\sharp_t$ is nonincreasing in $I$ (γ is nondecreasing in the budget), and every program has $I(\pi)\le\ell(\pi)+\kappa$. In the teacher sub-track's notation, $\mathrm{Floor}_{t+1}(I)=\max\{0,F^\sharp_t(I)\}$.
* $\pi_g$ is the good model, $\ell_g:=\ell(\pi_g)\in[d-4-\Lambda_1,\,d+\kappa_g]$ (the lower end by (D1), since $\mathrm{lev}(\pi_g)=1$).
* **The good model's sufficiency deficiency** [proved; aligned with `../teacher/` Prop 2.4]:
  $$b_0:=\kappa_g+(NH(p)-L_E)+\delta_E+2\log(d+1)+\kappa .$$
  *Derivation.* $F(\pi_g)=NH(p)$. By (F3) and (F5), $K(y_D\mid\mathrm{dom}D)\ge K(z\mid d)-\kappa\ge K(z)-2\log(d+1)-\kappa$, and $K(z)\ge d+L_E-\delta_E-\kappa$ by minimum-distance decoding (`prop:algstat:parity`(i)). So $\ell_g+F(\pi_g)\le d+\kappa_g+NH(p)\le K(y_D\mid\mathrm{dom}D)+b_0$. Also $0\le NH(p)-L_E\le\log(N+1)$. `notes.md` and the paper's proof of `prop:algstat:parity`(ii) write $2\log d$, absorbing the at most 2 bits $2\log((d+1)/d)$ into κ; the teacher sub-track's $b_0'$ uses $2\log(d+1)$. This record now uses $2\log(d+1)$, so $b_0=b_0'$ exactly. The κ = 0 illustrations change by at most 0.15 bits in length and 0.001 in the error bound (k7(b)).

**Proposition 4.1 (the full table has a left kink at the good model) [proved].** Let $t_0\ge1$ and $w:=\ell_g-(d-s(t_0)-\Lambda_1)\le\kappa_g+s(t_0)+\Lambda_1$. Put $\Gamma^\circ_t:=\max\{G_t,F^\sharp_t(d+\kappa)\}$ for $t\in[1,\infty]$ and
$$\sigma^{(t_0)}:=\inf_{t\ge t_0}\frac{N(\Gamma^\circ_t-H(p))}{\kappa_g+\min\{d,\ s(t+1)+\Lambda_1\}}.$$
* If $\sigma^{(t_0)}>0$, then $D$ has a left kink of steepness $\sigma^{(t_0)}$ and window $w$ at $(\ell_g,NH(p))$.
* $\pi_g$ is $b_0$-sufficient.
* Hence Cor 3.3(b) applies for $\lambda\in(1,\sigma^{(t_0)})$, in any product hypothesis class containing $\pi_g$.

*Proof.*
* Let $\ell(\pi)<d-s(t_0)-\Lambda_1$. A program of level $t'\le t_0$ has $\ell(\pi)\ge d-s(t')-\Lambda_1\ge d-s(t_0)-\Lambda_1$ by (D1), so $\mathrm{lev}(\pi)=t+1$ for some $t\ge t_0$, or ∞.
* For $\mathrm{lev}(\pi)=t+1<\infty$: $\ell(\pi)\ge(d-s(t+1)-\Lambda_1)^+$ by (D1); $R(\pi)\ge G_t$ by `lem:teacher:floor`; $R(\pi)\ge F^\sharp_t(d+\kappa)$ by the sharp floor, since $u(\pi)\le\theta_t$ and $I(\pi)\le\ell(\pi)+\kappa<d+\kappa$. Hence $(F(\pi)-NH(p))/(\ell_g-\ell(\pi))\ge N(\Gamma^\circ_t-H(p))/(d+\kappa_g-(d-s(t+1)-\Lambda_1)^+)\ge\sigma^{(t_0)}$.
* For level ∞, $\Gamma^\circ_\infty\ge\Gamma^\circ_t$ for every $t$, and the denominator is at most $d+\kappa_g$.
* Sufficiency is the derivation of $b_0$. ∎

The paper's kink "$\rho^\times_D(\alpha)\ge NG_1$ (or $NF_t$) for α below $d-s(t)-\Lambda_1$" (`prop:algstat:parity`(ii), (iv)) is the $t=t_0$ term of this infimum; the infimum over all levels converts the cliff into a steepness. The sign condition $\sigma^{(t_0)}>0$ matters: at $t_0=1$ it fails for $p\in\{1/8,15/64\}$, and $t_0=2$ is needed (rB4(e)).

**Proposition 4.2 (the λ-range on which the λ-MAP is "parity + noise") [proved; computed: k4, k7; rB4].** Work in $\Hcl{\times}$, or in any product hypothesis class (`def:setup:class`) that contains a good model $\pi'_g$; then $\kappa_g:=\ell(\pi'_g)-d$ and κ is the class's constant, as in `prop:related:computable`(a) (corrected after A6(a): the proof uses the good model twice, for $b_0$ and for $J_\lambda(\pi_g)$). Let λ > 1 and put
$$\bar\ell_\lambda:=d+\kappa_g+\frac{b_0+\kappa}{\lambda-1},\qquad \Gamma_t(\lambda):=\max\{G_t,F^\sharp_t(\bar\ell_\lambda+\kappa)\}.$$
Let $T$ be the least $t\ge1$ with $s(t+1)+\Lambda_1\ge d$, and $t_0\ge1$. Condition $C_{t_0}(\lambda)$ is
$$\lambda\big(\kappa_g+\min\{d,\ s(t+1)+\Lambda_1\}\big)<N\big(\Gamma_t(\lambda)-H(p)\big)\qquad\text{for } t=t_0,\dots,\max(t_0,T).$$
* **(i)** Assume $C_{t_0}(\lambda)$. Then every λ-MAP $\hat\pi$ satisfies:
  * (a) $\mathrm{lev}(\hat\pi)\le t_0$; hence $u(\hat\pi)>\theta_{t_0}$ and $K(a\mid\hat\pi)\le s(t_0)+2\log d+\kappa$: it knows the parity;
  * (b) $d-s(t_0)-\Lambda_1\le\ell(\hat\pi)\le\bar\ell_\lambda$;
  * (c) $NH(p)-\lambda(b_0+\kappa)/(\lambda-1)\le F(\hat\pi)\le NH(p)+\lambda(\kappa_g+s(t_0)+\Lambda_1)$: it fits like noise;
  * (d) $\hat\pi$ is product-$(b_0+(\lambda-1)(\kappa_g+s(t_0)+\Lambda_1))$-sufficient;
  * (e) $I(\hat\pi)\le I_e:=\bar\ell_\lambda-d+s(t_0)+2\log d+\kappa$: it holds little information about the flip set;
  * (f) $e(\hat\pi)\le1-u(\hat\pi)+\gamma_g(I_e)+2^{-g}$ for every $g\ge1$ (`thm:teacher:main`(e));
  * (g) **[new, after B8]** with $R_{\max}:=H(p)+\lambda(\kappa_g+s(t_0)+\Lambda_1)/N$,
    $$u(\hat\pi)\ \ge\ \max\Big\{\theta_{t_0},\ 2^{-R_{\max}}-p,\ \max_{g\ge1}\frac{2^{-R_{\max}}-p-p\big(2\gamma_g(I_e)+2^{1-g}\big)}{1-2p}\Big\}.$$
* **(ii) Interval form** [new, after A6(b)]. $\Gamma_t(\lambda)$ is nondecreasing in λ. Hence, if
  $$\lambda_{\rm hi}\big(\kappa_g+\min\{d,s(t+1)+\Lambda_1\}\big)<N\big(\Gamma_t(\lambda_{\rm lo})-H(p)\big)\qquad\text{for }t=t_0,\dots,\max(t_0,T),$$
  then $C_{t_0}(\lambda)$, and with it (a)–(g), holds for every $\lambda\in[\lambda_{\rm lo},\lambda_{\rm hi}]$. A connected union of such cells is an interval on which (a)–(g) hold.

For $t_0=1$ and $G_t$ alone, $C_1(\lambda)$ reads $\lambda<N(G_t-H(p))/(\kappa_g+\min\{d,s(t+1)+\Lambda_1\})$ for all $t\ge1$, a set of the form $(1,\sigma)$. It contains the open window $(1,Nc_{\rm hi})$ of `cor:teacher:fulltable`: for each level $t+1\ge2$ the paper's lower bound uses $s(t+1)\le4(t+1)$, which is weaker than the bound with $s(t+1)$ used here. At the endpoint $c_{\rm hi}$ the paper's inequality may be an equality, so the strict condition $C_1$ may fail there.

*Proof.*
* *(b), upper.* Cor 3.3(a) with $\pi_s=\pi_g$: $\ell(\hat\pi)\le\ell_g+(b_0+\kappa)/(\lambda-1)\le\bar\ell_\lambda$.
* *(a).* Suppose $\mathrm{lev}(\hat\pi)=t+1$ with $t\ge t_0$. Then $\ell(\hat\pi)\ge(d-s(t+1)-\Lambda_1)^+$ by (D1); $I(\hat\pi)\le\ell(\hat\pi)+\kappa\le\bar\ell_\lambda+\kappa$, so the floors give $R(\hat\pi)\ge\Gamma_t(\lambda)$. Hence $J_\lambda(\hat\pi)\ge\lambda(d-s(t+1)-\Lambda_1)^++N\Gamma_t(\lambda)$. For $t\le\max(t_0,T)$, $C_{t_0}(\lambda)$ makes this exceed $\lambda(d+\kappa_g)+NH(p)\ge J_\lambda(\pi_g)$. For $t>\max(t_0,T)$ the denominator is saturated at $\kappa_g+d$ and $\Gamma_t(\lambda)$ is nondecreasing in $t$, so the condition at $t=\max(t_0,T)$ suffices; level ∞ likewise. The bound on $K(a\mid\hat\pi)$ is `lem:teacher:list`.
* *(b), lower.* (D1) at level at most $t_0$.
* *(c), upper.* $J_\lambda(\hat\pi)\le J_\lambda(\pi_g)$ and $\ell_g-\ell(\hat\pi)\le d+\kappa_g-(d-s(t_0)-\Lambda_1)$. *(c), lower.* Cor 3.3(a).
* *(d).* Thm 3.2(a). *(e).* $I(\pi)\le K(\pi\mid a,K(a))+\kappa\le\ell(\pi)+K(a\mid\pi)-K(a)+\kappa$, with $K(a)\ge d$, as in `thm:teacher:main`(d). *(f).* The proof of `thm:teacher:main`(e) uses only the bound on $I$.
* *(g).* By (c), $R(\hat\pi)\le R_{\max}$. `lem:teacher:floor` ($B=\infty$) gives $R\ge-\log(u+p)$, so $u\ge2^{-R_{\max}}-p$. `lem:teacher:sharpfloor` gives $R\ge-\log(p+(1-2p)u+p(2\gamma_g(I(\hat\pi))+2^{1-g}))$, with $\gamma_g(I(\hat\pi))\le\gamma_g(I_e)$ by (e); solve for $u$.
* *(ii).* As λ grows, $\bar\ell_\lambda$ decreases, the budget $\bar\ell_\lambda+\kappa$ decreases, and $F^\sharp_t$ increases; so $\Gamma_t$ is nondecreasing. For $\lambda\in[\lambda_{\rm lo},\lambda_{\rm hi}]$: $\lambda\cdot\mathrm{den}_t\le\lambda_{\rm hi}\mathrm{den}_t<N(\Gamma_t(\lambda_{\rm lo})-H(p))\le N(\Gamma_t(\lambda)-H(p))$. ∎

**Numbers [computed: k7 (certified), k4 (grid); κ = 0 rows are illustrations].** The ranges below are certified intervals: k7 covers them by cells of (ii), grown and halved adaptively in $\log(\lambda-1)$ down to a width of $10^{-5}$. "$(1,x]$" means every $\lambda\in(1+10^{-12},x]$ is certified. Every range reported by k4's grid scan survives certification to the printed precision (5–6 significant digits; k7(a), (c)). Referee A's 6000-point scans (rA(6)) and referee B's sorted 1000-point grids with bisection (rB4(c)) also found single intervals.

* *(a) $p=2^{-10}$, where $G_1>H(p)$.* The level-1 range against the window of `cor:teacher:fulltable` (δ_E = 0; δ_E = 20 changes only the sharp-floor column, in the sixth digit at $d\ge30$):

| $d$ | κ | $Nc_{\rm hi}$ (paper) | level-1 range, $G$ floors | level-1 range, with the sharp floor |
|---|---|---|---|---|
| 20 | 0 | 11945 | $(1,\ 11944.9]$ | $(1,\ 12008.5]$ |
| 20 | 30 | 6456 | $(1,\ 6456.2]$ | $(1,\ 6486.2]$ |
| 30 | 0 | $9.791\cdot10^6$ | $(1,\ 9.979\cdot10^6]$ | $(1,\ 1.0048\cdot10^7]$ |
| 100 | 0 | $9.349\cdot10^{27}$ | $(1,\ 9.493\cdot10^{27}]$ | $(1,\ 9.560\cdot10^{27}]$ |
| 100 | 30 | $4.450\cdot10^{27}$ | $(1,\ 4.483\cdot10^{27}]$ | $(1,\ 4.514\cdot10^{27}]$ |

* *(b) Identification at $d=m=20$, $p=2^{-10}$, κ = 0, $\delta_E=0$* (k7(b); referee B's independent rB4(b) agrees to the printed digits with the old $b_0$).
  * At λ = 2: $u\ge0.9928$ (G floor alone: 0.9913), $\ell\le d+45.7$, $I\le58.3$, $e\le0.209$. The paper's table in `app:teacher:fulltable` gives 0.991, $d+58.2$, 70.8 and 0.220.
  * At λ = 105: $u\ge0.9904$, $\ell\le d+15.6$, $I\le28.2$, $e\le0.183$, against the paper's $d+15.7$, 28.3 and 0.185.
  * With the old $b_0$ ($2\log d$) the λ = 2 values were $d+45.5$, 58.2, 0.208 (k7(b), rB4(b)).
  * The gain over the paper comes from bounding the fit of a λ-MAP from below by the sufficiency line (coding bound) instead of (D2).
* *(c) Every flip rate below 1/4* (k7(c); least level $t_0$ with a nonempty certified range; the bounds at λ = 2):

| $p$ | $d$ | κ | $t_0$ | certified λ-range | at λ = 2: $K(a\mid\hat\pi)\le$, $\ell\in$, $I\le$ |
|---|---|---|---|---|---|
| 1/16 | 20 | 0 | 1 | $[1.00048,\ 4276]$ | 12.6, $[d-21.3,\ d+43.4]$, 56.0 |
| 1/16 | 100 | 30 | 1 | $(1,\ 1.589\cdot10^{27}]$ | 47.3, $[d-60.6,\ d+217.2]$, 264.5 |
| 1/8 | 20 | 0 | 2 | $[1.00059,\ 6530]$ | 15.8, $[d-24.5,\ d+42.1]$, 58.0 |
| 1/8 | 30 | 30 | 2 | $(1,\ 3.06\cdot10^6]$ | 47.0, $[d-56.8,\ d+170.6]$, 217.6 |
| 15/64 | 20 | 0 | 2 | $[1.08655,\ 465.4]$ | 15.8, $[d-24.5,\ d+63.4]$, 79.2 |
| 15/64 | 20 | 30 | 2 | $[1.3422,\ 199.8]$ | 45.8, $[d-54.5,\ d+183.4]$, 229.2 |
| 15/64 | 100 | 0 | 2 | $(1,\ 6.896\cdot10^{26}]$ | 20.5, $[d-33.7,\ d+117.2]$, 137.7 |

  * The full table (k7(c)) covers $p\in\{1/16,1/8,3/16,7/32,15/64\}$, $d\in\{20,30,60,100\}$ and κ ∈ {0, 30}. In every case the certified range is nonempty with $t_0\le2$, and its lower end is below $1+10^{-3}$ for $d\ge30$.
  * $I$ is out of $L_E$, which ranges from $3.5\cdot10^5$ (at $d=20$) to $10^{30}$ (at $d=100$).
  * The lower end exceeds 1 only at small $d$: near λ = 1 the budget $\bar\ell_\lambda$ grows like $(b_0+\kappa)/(\lambda-1)$, and the deviation term of the sharp floor grows with it.
* *(d) Crossovers* (k4(d), k7(d); rB4).
  * $G_1=H(p)$ at $p=0.05596$, the paper's 0.056.
  * The limit $f_1(p)=1-\log(3/2-p)$ of $F^\sharp_1$ equals $H(p)$ at $p=0.12331$.
  * The limit $f_2(p)=1-\log(1+(1-2p)/4)$ of $F^\sharp_2$ satisfies $f_2-H\ge0.0187$ on $(0,1/4]$: a rigorous interval check over $10^5$ cells (on each cell $f_2$ and $H$ are increasing, so $f_2-H\ge f_2(a)-H(b)$) gives 0.0187953, printed rounded down as 0.01879; the value at $p=1/4$ is 0.0187969 (rA(4)). `notes.md` wrote "≥ 0.0188", which is **[refuted]** in the fourth significant digit (A4/B9). Only positivity is used.

**What this adds to the paper.** `cor:teacher:fulltable` gives the full-table window only for $p<0.056$. `prop:algstat:parity`(iv) gives the kink of $\rho^\times_D$ for every $p<1/4$ but no λ-range for the λ-MAP. Prop 4.2 and Cor 4.3 turn the kink into certified λ-ranges for every $p<1/4$, with explicit identification: level 1, the teacher theorem's identification, for $p<0.1233$, and level ≤ 2 for $p<1/4$. This is the full-table ($m=d$) analogue of `q:teacher:open`(b).

**The junta case $m<d$ is not covered here**; it is treated by `../teacher/` §5 (Props 5.2–5.3, population objective; its referee A found them correct), which extends the identification to every $p<0.12331$ for $c\ge a^*(p)2^{-m}$. The obstacle in the full-table method, as written in `notes.md`: the good model is far from sufficient for $m<d$, so the right side of the kink is the rule's own rate, about $n2^{-m}$ bits per bit, not the flatness 1 that sufficiency gives; a program of level ≥ 2 then has its information budget controlled only through $J_c\le J_g$. The teacher sub-track removes the obstacle by charging the rule information in the objective at that rate.

**Corollary 4.3 (every flip rate below 1/4, asymptotically) [proved; the limit inequality computer-checked: k4(d), k7(d), rA(4), rB4].** Fix $p<1/4$ with bounded $K(p)$ and fix λ > 1. Let $d\to\infty$ with $\delta_E=O(d)$ and $pN$ an integer. Then for all large $d$, $C_2(\lambda)$ holds, and if $p<0.12331$ then $C_1(\lambda)$ holds. So every λ-MAP has level ≤ 2 (level 1 if $p<0.12331$), and (a)–(g) of Prop 4.2 hold with $t_0=2$ (respectively 1).

*Proof.*
* *The budget is small.* $b_0=O(\log N)+\delta_E=O(d)$, so $\bar\ell_\lambda=O(d)$, $j=O(d+g)$ in $F^\sharp_t(\bar\ell_\lambda+\kappa)$, and $\gamma_g=O(\sqrt{(d+g)/(p2^d)})$.
* *The floors converge.* Let $g\to\infty$ slowly; then $\epsilon_d:=\inf_g(2\gamma_g+2^{1-g})\to0$ and, uniformly in $t$, $F^\sharp_t(\bar\ell_\lambda+\kappa)\ge f_t(p)-O(\epsilon_d)$ with $f_t(p):=1-\log(1+(1-2p)2^{-t})$ increasing in $t$.
* *The limits exceed $H(p)$.* $f_2-H\ge0.0187$ on $(0,1/4]$ (interval check). $f_1-H$ is strictly decreasing on $(0,1/4]$: its derivative is $\log e/(3/2-p)-\log((1-p)/p)\le\log e/(5/4)-\log3<0$; it vanishes at $p=0.12331$.
* *Conclusion.* For $t\ge t_0$, $N(\Gamma_t(\lambda)-H(p))\ge c_pN$ with $c_p>0$ for all large $d$, while the left side of $C_{t_0}(\lambda)$ is at most $\lambda(\kappa_g+d)=O(d)$. ∎

The corollary does not claim level 1 for $p\ge0.12331$; with the present floors level 2 is the best the argument gives.

**Proposition 4.4 (set models have no steep kink at α ≈ d) [proved; computed: k8(D), rB2].** Consider set models $A\ni z$ for the table $z=y^*$, with points $(K(A),\log|A|)$ and set structure function $h_z$. Put $c^*:=2\log d+2\log r+\kappa$, which bounds $K(A_0)$ for $A_0=\{f_{a'}\oplus\mathbb 1_{E'}:a'\in\{0,1\}^d,\ |E'|=pN\}$ (`prop:algstat:parity`(i)). Every left kink of $h_z$ of steepness σ and window $w$ at $(\alpha_k,F_k)$ with $\alpha_k-w>c^*$ has
$$\sigma\le\frac{\alpha_k+\delta_E+2\kappa}{\alpha_k-c^*}=1+\frac{c^*+\delta_E+2\kappa}{\alpha_k-c^*}.$$

*Proof.* By the set sufficiency line and $K(z)\ge d+L_E-\delta_E-\kappa$, $F_k\ge h_z(\alpha_k)\ge d+L_E-\delta_E-2\kappa-\alpha_k$. $A_0$ has $K(A_0)\le c^*<\alpha_k-w$, so the kink gives $d+L_E=\log|A_0|\ge F_k+\sigma(\alpha_k-c^*)$. Combine. ∎

[computed: k8(D) and rB2 check the class form, $\sigma\le1+\mathrm{def}_0/(\alpha_k-K(A_{v=d}))$ with $\mathrm{def}_0$ the two-part excess of the set that knows nothing about $a$; it holds in every instance (rB2: 18 instances, max slack ≤ 0; k8(D): 14 instances, asserted).]

**Comparison.**
* At $\alpha_k\approx d$ the set steepness is at most $1+O((\log d+\delta_E)/d)$. The product structure function has steepness $\sigma^{(1)}\ge N(\Gamma^\circ_1-H(p))/(\kappa_g+d)$ there (Prop 4.1), exponential in $d$ when $\Gamma^\circ_1>H(p)$: for $p<0.056$ always, and for $p<0.1233$ once $d$ is large.
* $A_0$ is a short set within $\delta_E+O(\log d)$ of the sufficiency line. It plays the role of the universal member in Prop 3.5(i): the shared randomness of a set model absorbs the parity's $d$ bits at one bit per bit.
* Consequently every λ-optimal set model with λ > 1 has $K(A_\lambda)\le c^*+(\delta_E+c^*+2\kappa)/(\lambda-1)$ (`prop:algstat:set`, `prop:algstat:parity`(i)). So for $\lambda-1\gg(c^*+\delta_E+2\kappa)/(d-c^*)$ the set λ-MAP holds far fewer than $d$ bits about $a$. For λ within $O((\log d+\delta_E)/d)$ of 1 nothing is claimed; there the code's $O(\log d)$ terms decide (next paragraph).

**Illustration [computed: k2, k8(D), rB2; explicit classes with assigned Kraft-valid code lengths, not $K$].**
* *The product class of k2.* On the full table of a random parity at $d=8$, $|E|=16$: constants; parities with dyadic flip rates; partial parities; partial memorisers; the lookup table. Kraft sum 0.2447.
* *Product hull.* Five vertices: the coin $(7,256)$; the parity with rates 1/4 $(16,131.6)$, 1/8 $(19,94.2)$ and 1/16 $(20,86.35)$; the full memoriser $(105,0)$. The λ-MAP knows the parity exactly for $\lambda\in(1.016,13.82)$; it is the exact-rate model ($p=1/16$) for $\lambda\in(1.016,7.889)$, the coin above 13.82 and the memoriser below 1.016. A brute-force argmin over 408 values of λ, including every breakpoint ±$10^{-7}$ relative, agrees with Thm 2.2.
* *Left steepness at the good model* [revised after B6]. The robust quantity is the steepness with a window of the size of the rate code: 11.3 with window 2 and 13.05 with window 4 in k2; 11.3 with window 3 in rB2's class. The zero-window value at the exact-rate model is a rate-code artifact: 7.89 with k2's codes, 2.63 with rB2's equally natural rate code at the same $d$ and $p$, and at $d=6$, $p=1/16$ the exact-rate model is not a vertex at all (the rate-1/8 parity dominates it) (rB2). The coarser-rate parities, 1–3 bits shorter, form a small staircase inside the window.
* *Set hull: the code for $v$ decides* [revised after B5; reproduced independently in k8(D)]. The sets $A_v$ (parities agreeing with $a$ on the first $d-v$ coordinates, plus $pN$ flips) have two-part length $d+L_E+O(\log d)$; whether the parity-knowing set $A_{v=0}$ is a set λ-MAP for λ slightly above 1 depends on how $v$ is coded.
  * With k2's fixed $\lceil\log(d+1)\rceil$-bit field, all $A_v$ are collinear with slope exactly 1, and the set λ-MAP is the set that knows nothing about $a$ for all $\lambda\in(1,27.5)$ at $d=8$.
  * With the Elias code γ(v+1), $A_{v=0}$ is a set-hull vertex with λ-interval $(0.903,3.0)$ at $d=8$, upper end 2.5 at $d=10$, 2.0 at $d=12$, 1.75 at $d=16$, 1.67 at $d=20$, 1.5 at $d=24$ and 1.36 at $d=30$ (k8(D), identical to rB2). So for λ in $(1,1.36)$ at $d=30$ the set λ-MAP knows the parity.
  * Both are consistent with Prop 4.4, whose bound is $1+O((\log d+\delta_E)/d)$. The reading in `notes.md`, "the set λ-MAP is $A_0$ for all $\lambda\in(1,27.5)$: the parity is noise", is **[refuted as a code-independent statement]**; it holds for k2's fixed-length code only. The correct statement is the threshold of the Comparison above.
* *Other rates and sizes* (k2(E)). At $d\in\{8,10\}$ and $p\in\{1/32,1/16,1/8,3/16\}$ the parity-knowing range is $(\tau,\sigma)$ with τ ∈ [0.994, 1.093] and σ from 8.2 to 53.6. At λ = 1 the memoriser is the MAP in 4 of the 7 instances, those with τ > 1 (rB2: 10 of 18 in its class). This illustrates `cor:teacher:fulltable`(ii): λ = 1 sits on the memoriser edge, of slope $1\pm O(\log N/L_E)$.
* *Two kinks* (k2(F); corrected after B7). The parity plus a junta rule (2 blocks of 4 inputs at $m=6$) plus 16 random flips gives a hull with six vertices:
  * parity + noise for $\lambda\in(1.223,12.76)$, over three vertices: rate 1/4 on $(10.01,12.76)$, rate 1/8 on $(1.358,10.01)$, rate 3/32 on $(1.223,1.358)$;
  * parity + rule + noise for $\lambda\in(0.9925,1.223)$;
  * memoriser below 0.9925.

  `notes.md` quoted "(1.36, 10.0)", the rate-1/8 vertex alone. In rB2's independent instance (rule $m=5$, $|S|=2$, 12 random flips) parity + noise holds on $(2.58,11.14)$ and parity + rule on $(0.69,2.58)$, so there λ = 1 learns the rule. The rule's own kink is shallow at these sizes.

---

## 5. A sample from ν has a kink at the shortest equivalent length (link to T1)

### 5.0 Setting (revised after A1/B1)

* **Class.** $\mathcal C$ is a countable product class with $\sum_\pi2^{-\ell(\pi)}\le1$ (for example $\Hcl{\times}$, or a time-bounded or circuit subclass). It contains $\pi^*$ with $\nu_{\pi^*}=\nu$, a probability kernel ($\sum_y\nu(y\mid x)=1$), not necessarily computable. The input set $X$ is countable, as in both papers ($X=\{0,1\}^*$ in `def:setup:data`; any infinite decidable $X\subseteq\{0,1\}^*$ in `paper/NOTATION.md`).
* **Three schemes.**
  * **(pq) per-query.** Pairs $(x_i,y_i)$ are i.i.d. from $\mu\otimes\nu$ for a probability μ on $X$; inputs may repeat, and every query draws a fresh label. The fit is $F(\pi):=-\sum_{i\le n}\log\nu_\pi(y_i\mid x_i)$. This is π's term in the per-query mixture $\Mpq$ of Paper 1 (`prop:learn:perquery`) and the main object of `../iid/` (Def 1.1). On distinct inputs it equals Paper 2's $-\log\nu_\pi(D_n)$. On stamped inputs $\langle x_i,i\rangle$ it is the product law of the stamp-ignoring program $\tilde\nu_\pi(y\mid\langle x,t\rangle):=\nu_\pi(y\mid x)$ [proved: the stamped inputs are distinct]. So the (pq) point set is the product structure function of the stamped data set *restricted to stamp-ignoring programs*; the full class $\Hcl{\times}$ on stamped data also contains stamp-reading fill-ins, about which this section says nothing (`../iid/referee-A.md`).
  * **(wor) frozen, without replacement.** Inputs are drawn uniformly without replacement from a finite $X_0$, $n\le|X_0|$; given the inputs, labels are independent with $y_i\sim\nu(\cdot\mid x_i)$. $D_n$ is a Paper 2 data set; μ := uniform on $X_0$.
  * **(fd) fixed design.** $D$ is a data set whose domain is fixed, or chosen independently of its labels (for example the distinct inputs of any input process); its labels $y(x)\sim\nu(\cdot\mid x)$ are independent. All probabilities are conditional on $\mathrm{dom}D$. This is the single-data-set form of T2.
* **Sampled randomness and ratios.** $S:=F(\pi^*)$ ($S_n$ in (pq), (wor)); $\Lambda(\pi):=2^{S-F(\pi)}$, the likelihood ratio against ν.
* **Gaps and evidence.** $\mathrm{Hel}_x(\pi):=\mathrm{Hel}(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))\in[0,1]$. By Cauchy–Schwarz, $\sum_y\sqrt{\nu\nu_\pi}\le\sqrt{\sum\nu\sum\nu_\pi}\le1$, with equality only if $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$; so $\mathrm{Hel}_x(\pi)=0$ iff the kernels agree at $x$.
  * (pq), (wor): $\gamma(\pi):=\mathbb E_{x\sim\mu}\mathrm{Hel}_x(\pi)$, and the **evidence** is $e(\pi):=n\gamma(\pi)$.
  * (fd): the evidence is $e(\pi):=H_D(\pi):=\sum_{x\in\mathrm{dom}D}\mathrm{Hel}_x(\pi)$.
* **Equivalence.** In (pq) and (wor), π is *equivalent* if $\gamma(\pi)=0$, that is, $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$ at every atom of μ (on all of $X_0$ in (wor)); this is T1's notion. $E$ is the set of equivalent programs, $\ell^*:=\min_{\pi\in E}\ell(\pi)\le\ell(\pi^*)$, and $E^*$ the equivalent programs of length $\ell^*$ ($E^*$ is finite). In (fd), π is *$D$-equivalent* if $H_D(\pi)=0$; $\ell_D\le\ell^*$ and $E_D^*$ are defined likewise.
* **Margins.** $\gamma_=(\ell):=\min\{\gamma(\pi):\ell(\pi)=\ell,\ \pi\notin E\}$ ($+\infty$ if empty); $\gamma_<:=\min_{\ell<\ell^*}\gamma_=(\ell)$; $\gamma_{\bar\ell}:=\min_{\ell\le\bar\ell}\gamma_=(\ell)$ for a length cap $\bar\ell$; $\gamma_0:=\gamma_{\ell^*}$. Each is a minimum over a finite set of positive numbers, so the brief's margin condition always holds for a fixed cap; the content is its value. $\gamma_{\bar\ell}$ is `../iid/`'s $\gamma_L$ with $L=\bar\ell$, and $\gamma_<$ is its $\gamma_<$.
* **[withdrawn] The old scheme "(iid): i.i.d. from a non-atomic law μ on $X$" of `notes.md`.** Every probability law on a countable set is purely atomic, so the scheme has no instance; the statements made under it (Lemma 5.1 (iid), Cor 5.7 "under (iid) with an infinite sample", and the claims built on them in `notes.md` §0 item 4, §6, §7 and the Verification log) were vacuously true. They are replaced by the (pq) statements below. Their natural frozen-label reading is false (Prop 5.10). Non-atomic μ is discussed in Remark 5.11.

### 5.1 Tools

**Lemma 5.1 (evidence bounds) [proved; computed: k6(A), rA(7)].** For every π:
* (pq) $\mathbb E\sqrt{\Lambda_n(\pi)}=(1-\gamma(\pi))^n\le e^{-n\gamma(\pi)}$;
* (wor) $\mathbb E\sqrt{\Lambda_n(\pi)}\le(1-\gamma(\pi))^n\le e^{-n\gamma(\pi)}$;
* (fd) $\mathbb E[\sqrt{\Lambda(\pi)}\mid\mathrm{dom}D]=\prod_{x\in\mathrm{dom}D}(1-\mathrm{Hel}_x(\pi))\le e^{-H_D(\pi)}$.

In all three, $\mathbb E[\Lambda(\pi)\mid\text{inputs}]\le1$, and equivalent (respectively $D$-equivalent) programs have $\Lambda(\pi)=1$: almost surely in (pq), surely in (wor) and (fd).

*Proof.*
* Given the inputs, the labels are independent with $y_i\sim\nu(\cdot\mid x_i)$: in (pq) every query has its own label, repeats included; in (wor) and (fd) the inputs are distinct. Put $a(x):=\sum_y\sqrt{\nu(y\mid x)\nu_\pi(y\mid x)}=1-\mathrm{Hel}_x(\pi)$. Then $\mathbb E[\sqrt{\Lambda}\mid\text{inputs}]=\prod_ia(x_i)$, and $\mathbb E[\Lambda\mid\text{inputs}]=\prod_i\sum_{y:\nu(y\mid x_i)>0}\nu_\pi(y\mid x_i)\le1$.
* (pq): the inputs are i.i.d. μ, so $\mathbb E\prod_ia(x_i)=(\mathbb E_\mu a)^n=(1-\gamma(\pi))^n$.
* (wor): over a uniform $n$-subset of $X_0$ ($|X_0|=M$), $\mathbb E\prod_ia(x_i)=S_n:=e_n(a)/\binom Mn$, where $e_n$ is the $n$-th elementary symmetric polynomial of the values $a(x)$, $x\in X_0$. Maclaurin's inequality $S_n^{1/n}\le S_1$ for nonnegative reals gives $S_n\le(\text{mean }a)^n=(1-\gamma(\pi))^n$; zeros of $a$ need no separate treatment [known: Maclaurin's inequality, e.g. Hardy, Littlewood and Pólya, *Inequalities*, Thm 52 (theorem number unverified). The same step is the case $f=\exp$ of Hoeffding's comparison of sampling without and with replacement, W. Hoeffding, *JASA* 58:13–30 (1963), §6, Theorem 4; the location is confirmed by two secondary sources (Luh and Pippenger, arXiv:1107.1533; El-Yaniv and Pechyony, arXiv:1107.0046, Lemma 12), the original was not checked]. Computed: k6(A), 3386 (population, $n$) cases including zeros, largest ratio $S_n/(\text{mean})^n$ equal to 1.000000; rA(7), 1340 cases.
* (fd): directly.
* $1-u\le e^{-u}$.
* *Equivalent programs.* (pq): every $x$ with $\mathrm{Hel}_x(\pi)>0$ has $\mu(x)=0$ (μ is atomic), so almost surely no query falls there. (wor), (fd): the kernels agree on every input of the data. ∎

[computed: k6(A): the (pq) identity holds to $4.3\cdot10^{-14}$ by exact enumeration over all sequences, $n\le6$, 20 random triples (μ, ν, $\nu_\pi$) with sub-probability $\nu_\pi$; the (fd) identity to $5.6\cdot10^{-16}$ over 50 random kernels on 8 inputs.]

**Lemma 5.2 (uniform likelihood-ratio bound) [proved; computed: k3, k6(B), k6(D), rB3(E1), rB5(B)].** For ε ∈ (0, 1), with probability at least $1-\varepsilon$ (in (fd): conditional on $\mathrm{dom}D$), simultaneously for all $\pi\in\mathcal C$:
$$F(\pi)-S>2\log e\cdot e(\pi)-2\ell(\pi)-2\log(1/\varepsilon).$$

*Proof.* Let $a(\pi)$ be the right-hand side. By Markov's inequality and Lemma 5.1, $\Pr[\Lambda(\pi)\ge2^{-a(\pi)}]=\Pr[\sqrt{\Lambda(\pi)}\ge2^{-a(\pi)/2}]\le2^{a(\pi)/2}2^{-\log e\cdot e(\pi)}=\varepsilon2^{-\ell(\pi)}$. Sum over π using Kraft's inequality. ∎

[computed: k6(B): the (fd) form by exact enumeration of all $2^{10}$ label vectors on a fixed domain of 10 inputs, for 300 random classes (random, perturbed, deterministic, $D$-equivalent and sub-probability programs, Kraft ≤ 1): the largest ratio $\Pr[\text{slack}\le-t]/2^{-t}$ over $t\in\{0.5,1,2,3\}$ is 0.2006 (≤ 1 required). rB3(E1) checked the (wor) form exactly over a whole class including programs that memorise inputs outside the sample: frequencies ≤ 0.003 against bounds 0.5 and 0.25.]

**Lemma 5.3 (Ville) [(a) proved; (b) known in the paper: `lem:split:ville`; per-query form `../iid/` Lemma 2.2].**
* (a) *Fixed n, all schemes.* With probability at least $1-\varepsilon$, simultaneously for all π, $F(\pi)>S-\ell(\pi)-\log(1/\varepsilon)$. Proof: $\mathbb E[\xi_{\mathcal C}(D)/\nu(D)]=\sum_\pi2^{-\ell(\pi)}\mathbb E\Lambda(\pi)\le1$ by Lemma 5.1; apply Markov's inequality; on the complement $2^{-\ell(\pi)}\Lambda(\pi)\le\xi_{\mathcal C}/\nu<1/\varepsilon$.
* (b) *All n at once, (pq).* $F(\pi)\ge S_n-\ell(\pi)-\delta^*$ for all $n$ and π, where $\delta^*:=\sup_n\log(\xi_{\mathcal C}(h_n)/L_n(\nu))$ has $\Pr[\delta^*\ge j]\le2^{-j}$. The inequality is non-strict, as in `lem:split:ville` (corrected after A10).

[computed: k6(B): the largest ratio $\Pr[T\le-t]/2^{-t}$ for (a) is 0.2253 over the same 300 classes; k3, k6(D), rB3: the event never failed at $t=1$.]

### 5.2 The sample kink

**Theorem 5.4 (the sample kink) [proved; computed: k3, k6(D), rB3(E2)].** Scheme (pq) or (wor). Fix ε, $n$ and a length cap $\bar\ell\ge\ell^*$.
* (i) **Left kink, steepness linear in n** (probability ≥ 1 − ε: the event of Lemma 5.2, together with the almost sure event of Lemma 5.1). $D_n$ has a zero-window left kink at $(\ell^*,S_n)$ of steepness
  $$\sigma_n:=\min_{\ell<\ell^*}\frac{2\log e\cdot n\gamma_=(\ell)-2\ell-2\log(1/\varepsilon)}{\ell^*-\ell},$$
  provided $\sigma_n>0$ (for $\ell^*=0$ there is nothing to the left and the steepness is ∞). If moreover $A:=2\log e\cdot n\gamma_<-2\log(1/\varepsilon)\ge2\ell^*$, then $\sigma_n\ge A/\ell^*$. Without $A\ge2\ell^*$ this second form fails: $\ell^*=10$, $A=10$ give a profile minimum of −8 against $A/\ell^*=1$ (rA(5)).
* (ii) **Right kink** (probability ≥ 1 − ε: Lemma 5.3(a)). For every τ > 1, $D_n$ has a right kink of flatness τ and window $(\ell^*+\log(1/\varepsilon))/(\tau-1)$ at $(\ell^*,S_n)$.
* (iii) **Flat part and a vertex** (probability ≥ 1 − 2ε). If $\bar\ell>\ell^*$ and $n>(\bar\ell+\log(1/\varepsilon))/(\log e\cdot\gamma_{\bar\ell})$, then:
  * $\rho_{D_n}=S_n$ on $[\ell^*,\bar\ell]$, and every program of length at most $\bar\ell$ with fit at most $S_n$ is equivalent;
  * every right secant from $(\ell^*,S_n)$ is below $\tau_{\bar\ell}:=1+(\ell^*+\log(1/\varepsilon))/(\bar\ell-\ell^*)$;
  * if moreover $\sigma_n>\tau_{\bar\ell}$, then $(\ell^*,S_n)$ is a vertex of $\breve\rho_{D_n}$, and for every $\lambda\in(\tau_{\bar\ell},\sigma_n)$ the set of λ-MAPs is exactly $E^*$.

*Proof.*
* *(i).* Every program shorter than $\ell^*$ is non-equivalent. By Lemma 5.2, $F(\pi)-S_n>2\log e\cdot n\gamma_=(\ell(\pi))-2\ell(\pi)-2\log(1/\varepsilon)\ge\sigma_n(\ell^*-\ell(\pi))$. A program of $E^*$ has fit $S_n$ (Lemma 5.1), so $\rho(\ell^*)\le S_n$. For the second form, $(A-2\ell)/(\ell^*-\ell)\ge A/\ell^*$ iff $A\ell\ge2\ell^*\ell$.
* *(ii).* By Lemma 5.3(a), $F(\pi)>S_n-(\ell(\pi)-\ell^*)-(\ell^*+\log(1/\varepsilon))$, which is at least $S_n-\tau(\ell(\pi)-\ell^*)$ once $(\tau-1)(\ell(\pi)-\ell^*)\ge\ell^*+\log(1/\varepsilon)$.
* *(iii), the flat part.* A non-equivalent π with $\ell(\pi)\le\bar\ell$ has $F(\pi)-S_n>2\log e\cdot n\gamma_{\bar\ell}-2\bar\ell-2\log(1/\varepsilon)>0$ by the hypothesis on $n$. So programs with lengths in $(\ell^*,\bar\ell]$ have nonpositive right secants.
* *(iii), beyond the cap.* By Lemma 5.3(a) the secants are below $(\ell+\log(1/\varepsilon))/(\ell-\ell^*)$, which decreases in ℓ and is at most $\tau_{\bar\ell}$ for $\ell>\bar\ell$.
* *(iii), the vertex.* With (i), $(\ell^*,S_n)$ is a zero-window $(\sigma_n,\tau_{\bar\ell})$-kink with $\tau_{\bar\ell}<\sigma_n$. Thm 3.2(d) (which needs exactly this strict inequality) makes it a vertex and identifies the λ-MAPs as the programs at that point: by the flat part these are equivalent, and every program of $E^*$ is among them. ∎

**Remark 5.4′ (scope) [proved].**
* *(wor) needs $n\le|X_0|$.* The sample-size hypotheses of (iii), Cor 5.5 and Thm 5.6 can be incompatible with it. In k3 ($|X_0|=2^{16}$) they always are (§5.4).
* *(fd), a single data set.* Theorem 5.4, Cor 5.5 and Thm 5.6 hold conditionally on $\mathrm{dom}D$ with $n\gamma(\cdot)$ replaced by $H_D(\cdot)$, $\ell^*$ by $\ell_D$ and $E^*$ by $E^*_D$; the proofs are the same, using the (fd) forms of Lemmas 5.1–5.3. The kink is then at the shortest program that agrees with ν on the data. Its steepness grows only if the evidence $H_D$ of the shorter competitors grows, which it need not do when inputs repeat (Prop 5.10).

**Corollary 5.5 (fixed λ, one margin) [proved; computed: k6(D), rB3(E2)].** Scheme (pq), or (wor) with $n\le|X_0|$. Let λ > 1, $\bar\ell_\lambda:=\ell^*+(\ell^*+\log(1/\varepsilon))/(\lambda-1)$ and $\gamma:=\gamma_{\bar\ell_\lambda}$. If
$$2\log e\cdot n\gamma>(2-\lambda)^+\bar\ell_\lambda+\lambda\ell^*+2\log(1/\varepsilon),$$
then with probability at least $1-2\varepsilon$ the set of λ-MAPs is $E^*$.

*Proof.* On the event of Lemma 5.3(a) a λ-MAP has $\lambda\ell+F\le\lambda\ell^*+S_n$ and $F>S_n-\ell-\log(1/\varepsilon)$, hence $\ell<\bar\ell_\lambda$. A non-equivalent π with $\ell(\pi)\le\bar\ell_\lambda$ has, on the event of Lemma 5.2, $J_\lambda(\pi)-(\lambda\ell^*+S_n)>(\lambda-2)\ell(\pi)-\lambda\ell^*+2\log e\cdot n\gamma-2\log(1/\varepsilon)>0$, using $(\lambda-2)\ell\ge-(2-\lambda)^+\bar\ell_\lambda$. Equivalent programs longer than $\ell^*$ lose $\lambda(\ell-\ell^*)>0$, and all of $E^*$ tie. ∎

Cor 5.5 is the finite-sample target of T1 with an explicit $n_0(\lambda,\ell^*,\gamma,\varepsilon)$. Its weakness is $\gamma_{\bar\ell_\lambda}$: in natural classes the programs nearest to ν are slightly longer refinements, for example a rate written with more bits, whose gap decays like $4^{-(\ell-\ell^*)}$.

**Theorem 5.6 (near/far split) [proved; computed: k3, k6(D)].** Scheme (pq), or (wor) with $n\le|X_0|$. Let λ > 1, $\bar\ell_\lambda$ as above, and $0<\gamma\le\gamma_0$. Call π *near* if $0<\gamma(\pi)<\gamma$, and put $W_{\rm near}(\lambda,\gamma):=\sum_{\pi\text{ near},\ \ell^*<\ell(\pi)\le\bar\ell_\lambda}2^{-\lambda(\ell(\pi)-\ell^*)}$. If $2\log e\cdot n\gamma>(2-\lambda)^+\bar\ell_\lambda+\lambda\ell^*+2\log(1/\varepsilon)$, then with probability at least $1-2\varepsilon-W_{\rm near}(\lambda,\gamma)$ the set of λ-MAPs is $E^*$.

*Proof.* Far non-equivalent programs ($\gamma(\pi)\ge\gamma$) of length at most $\bar\ell_\lambda$ are excluded as in Cor 5.5; every non-equivalent program of length at most $\ell^*$ is far, since $\gamma\le\gamma_0$. A near program with $\ell^*<\ell(\pi)\le\bar\ell_\lambda$ beats $E^*$ only if $\Lambda_n(\pi)\ge2^{\lambda(\ell(\pi)-\ell^*)}$, which has probability at most $2^{-\lambda(\ell(\pi)-\ell^*)}$ by Markov's inequality and $\mathbb E\Lambda_n\le1$. Take a union bound. ∎

The guarantee is vacuous when $W_{\rm near}\ge1-2\varepsilon$, as at λ = 1.5 in both k3 and k6 (A9).

**Corollary 5.7 (almost surely; scheme (pq)) [proved; computed: k6(D); (d) uses `../iid/` Thm 3.1].** Take (pq) with an infinite sequence of queries. Write
$$s_-(n):=\min_{\ell(\pi)<\ell^*}\frac{F(\pi)-S_n}{\ell^*-\ell(\pi)},\qquad s_+(n):=\sup_{\ell(\pi)>\ell^*}\max\Big\{0,\frac{S_n-F(\pi)}{\ell(\pi)-\ell^*}\Big\}$$
for the left steepness and the right slope at $(\ell^*,S_n)$ ($s_-:=\infty$ if $\ell^*=0$). Almost surely:
* (a) $\liminf_ns_-(n)/n\ge2\log e\cdot\min_{\ell<\ell^*}\gamma_=(\ell)/(\ell^*-\ell)>0$: the left steepness grows linearly in $n$;
* (b) $\limsup_ns_+(n)\le1$;
* (c) for every λ > 1, from some $n$ on, the set of λ-MAPs is $E^*$;
* (d) **[new]** from some $n$ on, $s_+(n)<1<s_-(n)$: λ = 1 lies strictly inside the kink, and the set of 1-MAPs is $E^*$.

*Proof.*
* Apply Lemma 5.2 with $\varepsilon_n=n^{-2}$. By Borel–Cantelli its event holds for all large $n$. Use Lemma 5.3(b) with $\delta^*<\infty$ a.s.
* (a) Theorem 5.4(i) with $\log(1/\varepsilon_n)=2\log n=o(n)$, for each of the finitely many lengths $\ell<\ell^*$.
* (b) For a fixed cap $\bar\ell$, the flat part of Thm 5.4(iii) holds for large $n$ (with $\varepsilon_n$), and Lemma 5.3(b) bounds the secants beyond the cap by $1+(\ell^*+\delta^*)/(\bar\ell-\ell^*)$. Let $\bar\ell\to\infty$.
* (c) Every λ-MAP has length at most $\bar\ell^*:=\ell^*+(\ell^*+\delta^*)/(\lambda-1)$ (`thm:split:private`(i), per-query form `../iid/` Thm 4.1(i)). The finitely many non-equivalent programs of length at most $\bar\ell^*$ have $F(\pi)-S_n\ge2\log e\cdot n\gamma_{\bar\ell^*}-2\bar\ell^*-4\log n\to\infty$. Equivalent programs longer than $\ell^*$ lose $\lambda(\ell-\ell^*)$; all of $E^*$ tie.
* (d) By `../iid/` Thm 3.1 with $\lambda_n\equiv1$ (proved there for every countable Kraft class containing ν; both of its referees checked it), almost surely the set of 1-MAPs is eventually $E^*$, and all of $E^*$ sit at the one point $(\ell^*,S_n)$. By Thm 2.2(ii), a set of λ-MAPs that occupies a single point is the set of programs at a vertex $v_i$ with $\sigma_{i+1}<\lambda<\sigma_i$: at a breakpoint $\lambda=\sigma_i$ it would contain the programs at both ends of an edge, two different points. By Thm 2.1, $s_+(n)=\sigma_{i+1}$ (the largest right secant from a vertex is the next edge's slope, attained; 0 at the last vertex), and $s_-(n)\ge\sigma_i$ by convexity. So $s_+(n)<1<s_-(n)$. [The deterministic step is checked in k8(C): in all 2982 random point sets with a unique 1-MAP point, that point is a vertex with right slope < 1 < left steepness.] ∎

Parts (c) and (d) are also consequences of `../iid/` Thm 3.1, which proves exact recovery for every schedule $1\le\lambda_n=o(n)$ by a different route (the prior tail $t_L$). What the kink route adds is the geometric picture and the explicit finite-sample forms (Thm 5.4, Cor 5.5, Thm 5.6). Part (d) answers open question 2 of `notes.md` for the per-query object: the right slope at the sample kink eventually drops below 1 almost surely, in every countable Kraft class, $\Hcl{\times}$ included.

**Proposition 5.8 (the margin is necessary) [proved; computed: k5, rA(8), rB5].** Let $\pi_1$ be non-equivalent with $\ell(\pi_1)=\ell^*-\Delta$, Δ > 0, and mean KL divergence $\bar K:=\mathbb E_\mu\mathrm{KL}(\nu(\cdot\mid x)\Vert\nu_{\pi_1}(\cdot\mid x))$ in bits. In (pq) and (wor), for every $n$ and λ,
$$\Pr[\text{some program of }E^*\text{ is a λ-MAP}]\le\frac{n\bar K+\log e/e}{\lambda\Delta}.$$
(In (fd) replace $n\bar K$ by $\sum_{x\in\mathrm{dom}D}\mathrm{KL}_x$.)

*Proof.* A program of $E^*$ is a λ-MAP only if $X:=F(\pi_1)-S_n\ge\lambda\Delta$. $\mathbb EX=n\bar K$, since each input is marginally μ-distributed. $\mathbb EX^-=\mathbb E(\log\Lambda_n(\pi_1))^+\le(\log e/e)\mathbb E\Lambda_n\le\log e/e$, because $\log x\le(\log e/e)x$ for $x>0$. Apply Markov's inequality to $X^+$, with $\mathbb EX^+=\mathbb EX+\mathbb EX^-$. ∎

So identification with probability ≥ 1/2 needs $n\ge(\lambda\Delta/2-0.531)/\bar K$.
* *What this says about Cor 5.5* [proof sketch; restricted after A8]. On instances where the closest competitor is a shorter program with $\Delta\asymp\ell^*$ and $\bar K\asymp\gamma_{\bar\ell_\lambda}$, and the family has bounded likelihood ratios (so that KL and Hellinger are comparable [known: e.g. Wong and Shen 1995, Yang and Barron 1998; exact constants unverified]), the dependence of Cor 5.5's sample size on $\lambda\Delta/\gamma$ is necessary up to the KL/Hellinger ratio. `notes.md` said that "the order $\lambda\ell_0/\gamma$ in Cor 5.5 cannot be improved beyond constants and the dependence on $\bar\ell_\lambda$"; that wording is **[withdrawn]**: Prop 5.8 concerns one shorter competitor, while Cor 5.5's $\gamma_{\bar\ell_\lambda}$ is a minimum over longer programs too.
* *Numbers (k5's family).* In k5's Bernoulli pairs ($p=1/8$ against $q\in\{1/4,3/16,5/32\}$, and two more pairs), computed with the exact binomial law, the λ-MAP is the true program with probability 1/2 at a sample size between 0.70 and 1.01 times the mean-crossing $n_{\rm KL}=\lambda\Delta/\bar K$, and above 0.95 times it once $\lambda\Delta\ge15$; there $\bar K/(2\log e\cdot\mathrm{Hel})\in[1.84,1.97]$. These ranges are specific to k5's family (B10): over referee B's grid of 320 settings (rB5) the ratio $n(P=1/2)/n_{\rm KL}$ ranges over $[0.31,1.43]$ (over $[0.92,1.00]$ for $\lambda\Delta\ge15$) and $\bar K/(2\log e\cdot\mathrm{Hel})$ over $[1.62,2.24]$. The bound itself was never violated: rA(8), 540 cases; rB5, 320 settings, largest ratio of exact probability to bound 0.85.

**Remark 5.9 (product versus shared; λ = 1) [proved for the first item; computed for the second].**
* *Shared classes.* Lemma 5.2 needs per-input Hellinger gaps, so it is a product-class statement. In a shared class with a universal member $U$, Prop 3.5(i) caps the left steepness at any $\alpha_k$ with $\alpha_k-w>\ell_U$ by $1+(\ell_U+\kappa_0)/(\alpha_k-\ell_U)$ for all $n$. There is no linear growth: the private/shared contrast of `thm:split:private` and `thm:split:shared` in kink form.
* *λ = 1.*
  * In (pq), Cor 5.7(d): eventually λ = 1 is strictly inside the kink. In k6 the 1-MAP is $\pi^*$ in every sample from $n=16384$ on, and the right slope is below 1 in 96–100% of samples from $n=1024$ on.
  * On a single data set ((wor), (fd), full tables) Thm 5.4 never certifies λ = 1, since $\tau_{\bar\ell}>1$; whether the hull's actual right slope at $\ell^*$ is below 1 depends on the class and the data. In k3 ((wor), $n\le2^{14}\ll|X_0|$) the right slope has median 0.32–0.68 and maximum 1.33. In rB3(E2) it rises with $n/|X_0|$: median 0.50 at $|X_0|/8$, 0.74 at $|X_0|/2$, 0.997 at $n=|X_0|$, when the sample is the full table. On full tables (k2, rB2) the memoriser edge has slope $1\pm0.1$.

### 5.3 Frozen labels with repeated inputs

**Proposition 5.10 (what fails and what survives with frozen labels and an atomic μ) [proved; computed: k6(A), k6(C), rA(1), rB6].** Take Paper 2's data-set object with i.i.d. inputs from an atomic μ on a countable $X$: a label $F(x)\sim\nu(\cdot\mid x)$ is drawn once per input, and $D_n$ is the set of distinct pairs among the first $n$ queries (`../iid/` Def 1.3).
* (a) **Lemma 5.1's (pq) bound fails.** $\mathbb E\sqrt{\Lambda_n(\pi)}=\mathbb E\prod_{x\in\mathrm{dom}D_n}(1-\mathrm{Hel}_x(\pi))$. For a program that differs from ν only at one atom $x_1$, this tends to $1-\mathrm{Hel}_{x_1}(\pi)>0$, while $(1-\gamma(\pi))^n\to0$. [k6(A): with μ = (0.6, 0.3, 0.1) and the difference at the atom of mass 0.1, 0.7071 against 0.0512 at $n=100$; rB6: 0.9114 against $(1-\gamma)^n\to0$.]
* (b) **[refuted] Cor 5.7(c) in the frozen reading** ("under i.i.d. inputs every fixed λ > 1 eventually selects a shortest μ-a.e. equivalent program", `notes.md` §0 item 4, §6, and its Verification-log cross-check).
  * *Counterexample 1 (referee A).* Two programs of length 1: $\pi^*$ the fair coin, and $\pi'$ the coin except label 0 surely at the heaviest atom $x_1$. $\pi'$ is not equivalent ($\gamma(\pi')=\mu(x_1)(1-1/\sqrt2)>0$). Almost surely $x_1$ appears; with probability 1/2 its frozen label is 0, and from then on $\Lambda_n(\pi')=2$, so $\pi'$ is the unique λ-MAP for every λ and all large $n$. [Exact: k6(C) gives $\frac12(1-(1-\mu(x_1))^n)\to\frac12$; rA(1) simulates 0.505 in 2000 runs. In (pq), $\pi'$ dies at the first label 1 at $x_1$: probability of survival $(1-\mu(x_1)/2)^n$.]
  * *Counterexample 2 (referee B, rB6).* Coin (length 2), $\pi^*$ (length 12, the coin except Bern(1/8) at one atom of mass 1/8), $\pi_2$ (length 11). With frozen labels the coin beats $\pi^*$ for every λ ≥ 1 and every $n$, since one frozen label gains at most $\log(7/4)<10$ bits; so $\Pr[\pi^*\text{ is a λ-MAP}]=0$ for all $n$. With fresh labels it is 0.9992 at $n=1000$ (λ = 2) and 1.0000 at $n=5000$.
* (c) **What survives.**
  * Lemma 5.2 and Thm 5.4 in the (fd) form, conditional on $\mathrm{dom}D_n$, with evidence $H_{D_n}(\pi)=\sum_{x\in\mathrm{dom}D_n}\mathrm{Hel}_x(\pi)$. For programs that differ from ν on finitely many atoms this evidence stays bounded, which is why the left steepness need not grow.
  * Almost surely every λ-MAP (λ > 1) is eventually ν-equivalent on the run (`thm:split:private`(iv); `../iid/` Prop 7.6(a)).
  * No procedure recovers every sampler exactly (`../iid/` Prop 7.5).
  * On a finite support, $D_n$ is eventually the full table, a single data set; then §2–§4 apply (`../iid/` Prop 7.6(c)). For a noisy parity sampler that limit is exactly the full table of §4 (frozen noise is an $m=d$ error set), whose λ-range is Prop 4.2's.

*Proof.* (a): Lemma 5.1's first step with the distinct inputs; for the example, $\mathbb E\sqrt{\Lambda_n}=\Pr[x_1\in\mathrm{dom}D_n](1-\mathrm{Hel}_{x_1})+\Pr[x_1\notin\mathrm{dom}D_n]$. (b): as stated; each step is a direct computation. (c): the cited results, and Remark 5.4′. ∎

**Remark 5.11 (non-atomic input laws) [remark].** If μ were non-atomic on a standard Borel input space and $x\mapsto\nu_\pi(y\mid x)$ were measurable for every π, the inputs would be almost surely distinct, the frozen and per-query likelihoods would coincide, and every proof of §5 would go through for the frozen data sets (both referees checked the steps). This needs an uncountable input space, outside both papers. In the papers' setting the per-query object (pq) is the one for which the asymptotic statements hold.

### 5.4 Numbers

**(1) k3: frozen, without replacement, $d=16$** [computed: k3; 200 samples per $n$; $|X_0|=65{,}536$; $p=1/8$; ε = 0.05; $\ell^*=27$; Kraft sum 0.2526 (rA(10))].

| $n$ | $(\ell^*,S_n)$ a vertex | left steepness median (min) | right slope median (max) | uniform $A/\ell^*$ bound | profile $\sigma_n$ bound |
|---|---|---|---|---|---|
| 64 | 74.5% | 1.46 (−4.70) | 0.32 (6.34) | — | — |
| 256 | 97.5% | 5.84 (1.05) | 0.36 (4.59) | — | — |
| 1024 | 100% | 23.4 (14.0) | 0.42 (3.10) | — | — |
| 4096 | 100% | 93.8 (74.2) | 0.52 (1.48) | 5.43 | 32.9 |
| 16384 | 100% | 374.3 (342.6) | 0.68 (1.33) | 22.7 | 188.0 |

* The left steepness grows linearly, by a factor of about 4 per factor 4 in $n$. Thm 5.4(i)'s bounds hold in 200 of 200 samples wherever they are positive.
* The events of Lemmas 5.2 and 5.3 failed in none of the 1000 samples at the level $t=1$. Lemma 5.2's slack is evaluated over families F0–F2 and the best F3 programs; F3 programs that memorise inputs outside the sample are not enumerated in k3, but rB3(E1) and k6 enumerate them.
* **The finite-sample theorems do not apply to k3's instance** (B4). Cor 5.5's $n_0$ ($3\cdot10^5$ to $5\cdot10^8$) and Thm 5.4(iii)'s thresholds for caps 32, 37, 47 ($9.5\cdot10^4$, $1.05\cdot10^8$, $5.2\cdot10^8$) all exceed $|X_0|$. k3's output lines "right-steepness bound τ_L holds in 92–100%" test a conclusion the theorem does not assert at those $n$; they are not checks of Thm 5.4(iii).
* *Thm 5.6* with $\gamma=\gamma_0=0.0131$: $n_0=1653$ (λ = 2, guarantee ≥ 0.097), 3079 (λ = 4, ≥ 0.762), 5929 (λ = 8, ≥ 0.892); at λ = 1.5, $W_{\rm near}=1.47$ and the guarantee is vacuous (A9). With $\gamma=10^{-3}$: $n_0=3.3\cdot10^4$ (λ = 1.5, ≥ 0.789), $2.2\cdot10^4$ (λ = 2, ≥ 0.867), $4.0\cdot10^4$ (λ = 4, ≥ 0.900), $7.8\cdot10^4$ (λ = 8, above $|X_0|$).
* *Empirically* the λ-MAP is $\pi^*$ in 95.5–100% of samples from $n=256$ for λ ∈ {1.5, 2}, and in 100% from $n=1024$ for λ ∈ {4, 8}.

**(2) rB3(E2): frozen, without replacement, $d=12$, where Thm 5.4(iii) applies** [computed by referee B; re-run here]. $|X_0|=4096$, $p=1/4$, coarse rate grid, $\ell^*=20$. Thm 5.4(iii)'s thresholds are 1916–2294 for caps 21–26. At $n=3072$ and 4096, for caps 22, 24 and 26, the flat part, the secant bound, the vertex and "$\pi^*$ is the unique λ-MAP at three λ in $(\tau_{\bar\ell},\sigma_n)$" hold in 200 of 200 samples. Cor 5.5 applies only at λ = 4 ($n_0=3350$); for λ ∈ {1.5, 2, 8, 16, 32} its $n_0$ exceeds $|X_0|$.

**(3) k6: per-query, $d=8$, with $n$ up to $2^{20}$** [computed: k6(D); 200 samples per $n$; inputs uniform on $\{0,1\}^8$ ($M=256$, so inputs repeat); a fresh label per query; truth: parity $a^*$ with rate 1/8; the k3-type class (constants, parities and partial parities with rates $j/2^b$, $b\le6$, memorisers of $a^*$ at any $j$ inputs, the full table), Kraft sum 0.2066; $\ell^*=19$, π* the only equivalent program; ε = 0.05].
* *Margins.* $\gamma_<=\gamma_0=0.01313$ (the rate-1/4 parity, 3 bits shorter), $\gamma_{20}=3.74\cdot10^{-3}$, $\gamma_{21}=1.01\cdot10^{-3}$, $\gamma_{22}=\dots=\gamma_{30}=2.65\cdot10^{-4}$ (the rate 9/64).
* *Sample sizes.* Thm 5.4(iii): $n>1.73\cdot10^4$ for $\bar\ell=21$ ($\tau_{\bar\ell}=12.66$), $n>6.88\cdot10^4$ for 22, $n>7.40\cdot10^4$ for 24. Cor 5.5: $n_0=9.1\cdot10^4$ (λ = 1.5), $6.1\cdot10^4$ (2), $1.1\cdot10^5$ (4), $2.1\cdot10^5$ (8). Thm 5.6 with $\gamma_0$: $n_0=1231$ (λ = 2, guarantee ≥ 0.103), 2234 (λ = 4, ≥ 0.762), 4240 (λ = 8, ≥ 0.892); vacuous at λ = 1.5 ($W_{\rm near}=1.40$).

| $n$ | $n/M$ | $(\ell^*,S_n)$ a vertex | left steepness median (min) | right slope median (max) | right slope < 1 | every λ-MAP is π*: λ = 1, 2, 8 |
|---|---|---|---|---|---|---|
| 64 | 0.25 | 0.860 | 1.48 (−0.96) | 0.53 (5.27) | 0.835 | 0.685, 0.295, 0 |
| 256 | 1 | 0.950 | 5.53 (−1.40) | 0.61 (7.22) | 0.875 | 0.875, 0.910, 0.150 |
| 1024 | 4 | 1.000 | 23.8 (12.8) | 0.55 (3.34) | 0.960 | 0.960, 0.990, 1.000 |
| 4096 | 16 | 1.000 | 95.8 (73.0) | 0 (2.06) | 0.975 | 0.975, 0.995, 1.000 |
| 16384 | 64 | 1.000 | 378 (326) | 0 (0.40) | 1.000 | 1.000, 1.000, 1.000 |
| 65536 | 256 | 1.000 | 1522 (1438) | 0 (0) | 1.000 | 1.000, 1.000, 1.000 |
| 262144 | 1024 | 1.000 | 6086 (5877) | 0 (0) | 1.000 | 1.000, 1.000, 1.000 |
| 1048576 | 4096 | 1.000 | 24312 (23999) | 0 (0) | 1.000 | 1.000, 1.000, 1.000 |

* *Every guarantee holds where its hypothesis holds.* Lemmas 5.2 and 5.3: $\Pr[\text{slack}\le-1]=0$ at every $n$ (the least slack is 3.08). Thm 5.4(i): its bound is positive from $n=4096$ (38.2, 193, 814, 3297, 13229) and holds in 200 of 200 samples. Thm 5.4(iii): applies from $n=65536$ ($\bar\ell=21$) and $n=262144$ ($\bar\ell=22,24$); the flat part, the secants, the vertex and "the λ-MAPs are $E^*$ at three λ in $(\tau_{\bar\ell},\sigma_n)$" hold in 200 of 200. Cor 5.5 applies at λ = 2 from $n=65536$ and at all four λ from $n=262144$: frequency 1.000 against the guaranteed 0.90. Thm 5.6 applies from $n=4096$: observed 0.995–1.000 against 0.103–0.892.
* *Linear growth.* The left steepness per sample is 0.0232 from $n=1024$ on. It equals the shortest competitor's mean KL per bit of length, $\mathrm{KL}(\mathrm{Bern}(1/8)\Vert\mathrm{Bern}(1/4))/3=0.0696/3$. Cor 5.7(a)'s Hellinger rate, $2\log e\min_{\ell<\ell^*}\gamma_=(\ell)/(\ell^*-\ell)=0.0126$ (k6), is below it by 1.84, the KL/Hellinger ratio of that pair (as in k5).
* *Right slope and λ = 1.* With fresh labels every longer program of this finite class eventually fits worse than π* (a memoriser of an input dies at the first disagreeing label there), so the right slope is 0 from $n\approx16M$ on; the 1-MAP is π* in every sample from $n=16384$, as Cor 5.7(d) predicts.
* *Small n.* At $n\le256$ the kink has not formed: the λ-MAP is often a shorter program for λ ≥ 2 (Prop 5.8: the rate-1/4 parity is beaten only once $n\gtrsim\lambda\cdot3/0.0696$).

---

## 6. Interpretation: "the model consists of the bits that each explain more than λ bits of data"

* **Along the hull.** By Thm 2.2, going from vertex $i-1$ to vertex $i$ adds $\alpha_i-\alpha_{i-1}$ bits of program and saves $\sigma_i$ bits of fit per added bit. The λ-MAP takes exactly the edges with $\sigma_i>\lambda$. So, in hull-averaged form, the model consists of the blocks of bits each of which explains more than λ bits of data. The statement is about blocks along hull edges, not about individual bits: a program is not built bit by bit, and an edge may average a valuable part with a less valuable one.
* **Why noise is never bought for λ > 1.** In a hypothesis class, beyond any $b$-sufficient program the hull descends at most $1+(b+\kappa)/\Delta$ bits per bit over Δ further bits (Remark 2.5). Describing sampled randomness is a one-bit-for-one-bit trade, and λ > 1 refuses it beyond $(b+\kappa)/(\lambda-1)$ bits (Cor 3.3(a)). On samples the same role is played by Ville's line (Thm 5.4(ii)).
* **Why the model is bought.**
  * With private randomness, a model component worth keeping explains σ ≫ 1 bits per bit. On the full parity table the hull falls by about $N(1-H(p))$ bits from the coin to the good model over about $d$ bits, and Prop 4.1 bounds the steepness below by $N(\Gamma^\circ_{t_0}-H(p))/(\kappa_g+d)$. On $n$ per-query samples a sampler explains at least $2\log e\cdot n\gamma_<$ bits per bit up to $O(\ell^*+\log(1/\varepsilon))$ (Thm 5.4(i)); in k6 the realised rate is the KL rate, 0.0232 bits per bit per sample.
  * With shared randomness the same parameter explains one bit per bit (Prop 4.4; Prop 3.5 for any class with a universal member).
* **The split is sharp at a kink, and only there (Thm 3.4).** For per-query data from a sampler in a product class, the kink is at the shortest equivalent program, its steepness grows linearly in $n$, and every fixed λ ≥ 1 eventually lies inside it (Cor 5.7(c), (d)). For a single frozen data set the kink exists with high probability when the competitors' evidence is large (Thm 5.4 in the (fd) form); with repeated inputs and frozen labels it need not grow (Prop 5.10). With teacher errors that are themselves learnable there are two kinks, and λ must lie between them (§4 illustration; `../teacher/` §4).

---

## 7. What is known and what is new here

* **Known.**
  * The hull characterisation is the standard relation between penalised and constrained minimisation in two dimensions, and the project's `lem:setup:hull` in population form [known; standard].
  * Legendre–Fenchel duality [known; Rockafellar §12, section number unverified].
  * Hellinger (Bhattacharyya) affinity bounds and Kraft-weighted union bounds are the usual tools of two-part-code consistency proofs [known in spirit: Barron and Cover 1991, Zhang 2006, as cited in `research/tracks/steeper/notes-final.md` §1.3; that they use exactly Lemma 5.2's form is unverified].
  * Ville's inequality; Maclaurin's inequality and Hoeffding's without-replacement comparison [known; see Lemma 5.1 for the verification status].
  * The parity lemmas are the paper's. The two counterexamples of Prop 5.10(b) are the referees'.
* **New in this sub-track, as far as the project's records show.**
  * The identification of λ-MAPs with the convex minorant of the product structure function on one data set, with edges, ties, existence at λ = 0 and the duality (§2).
  * The kink definitions, Theorems 3.2 and 3.4 (including the converse), Cor 3.3 as the single-data-set split theorem, and Prop 3.5 (flattening and capping by a universal member).
  * Prop 4.2 with certified λ-intervals and Cor 4.3: λ-ranges for every $p<1/4$ in the full-table case; Prop 4.4 in quantitative form.
  * The sample kink with linear steepness in the three schemes (Lemma 5.2 with the evidence functional, Thm 5.4), the near/far refinement (Thm 5.6), the almost sure form in the per-query scheme including λ = 1 (Cor 5.7), and the necessity bound (Prop 5.8).
  * The account of what fails with frozen labels and repeated inputs, and what survives (Prop 5.10).
* **Not checked against the literature.** Whether VV 2004 or VV 2010 state the "two-part MDL with weight λ selects the point of the structure function's convex minorant with slope −λ" relation for set models. This is plausibly folklore in algorithmic statistics [open].

---

## 8. Open questions

1. **Local margins.** Replace $1/\gamma_{\bar\ell_\lambda}$ in Cor 5.5 by a parametric-complexity term for near-equivalent refinements, of order $\log n$ per refinement family. In k6 the observed threshold is about 1000 samples against Cor 5.5's $6\cdot10^4$–$2\cdot10^5$; in k3 about 1000 against Thm 5.6's $10^3$–$10^4$ and Cor 5.5's $3\cdot10^5$ and more [open]. `../iid/referee-B.md` b3 suggests a per-program free-exponent bound in the same direction.
2. **The right slope at the sample kink.** *Answered for the per-query object* by Cor 5.7(d): almost surely it eventually drops below 1, in every countable Kraft class. *Open for single data sets* in $\Hcl{\times}$: on a frozen data set, can single fill-in programs reach slope ≥ 1 at the shortest equivalent program while the sample is still far from the full table? (`lem:split:stream` bounds only the total fill-in weight; on full tables the memoriser edge has slope $1\pm O(\log N/L_E)$, `cor:teacher:fulltable`(ii).) [open]
3. **Junta errors.** *Answered for the population objective* by `../teacher/` §5 (Props 5.2–5.3): the window extends to every $p<0.12331$ for $c\ge a^*(p)2^{-m}$. The sampled version, with right flatness about $n2^{-m}$ on samples, is proved there only for equal cell multiplicities (`../teacher/` Prop 3.3(b)) [open in general].
4. **Set kinks.** Is a product kink of steepness σ at α always accompanied by a set-model slope ≈ 1 when the model's parameter is random? Prop 4.4 proves it for parities via $A_0$; a general version needs a short near-sufficient set model playing the role of $U$ [conjecture].
5. **Frozen labels with repeats (new).** For which classes and input laws does the (fd) evidence $H_{D_n}$ of every program shorter than $\ell^*$ grow without bound, so that the frozen-data kink steepens? A program that differs from ν on finitely many atoms has bounded evidence (Prop 5.10(a)); `../iid/` Prop 7.6(a) identifies the limit class by summability of $\sum_x\mathrm{Hel}_x$ [open].

---

## 9. Cross-track consistency

This section aligns the kink record with `../iid/notes.md` and `../teacher/notes.md` and their referee reports, as they stand on 2026-10-13. Neither sibling has a final record yet; where a sibling referee raised a point about this sub-track's results, it is addressed here.

### 9.1 Which data object each statement concerns

| object | `../iid/` | kink (this record) | `../teacher/` |
|---|---|---|---|
| per-query: fresh label at every query, repeats allowed, likelihood $\prod_i\nu_\pi(y_i\mid x_i)$ | main object (Def 1.1); Thms 3.1, 3.2, 4.1 | scheme (pq): Lemmas 5.1–5.3, Thm 5.4, Cors 5.5, 5.7, Thm 5.6, Prop 5.8 | Prop 3.2 and Remark 3.4, "fresh noise" column |
| frozen data set, i.i.d. atomic inputs, each distinct input counted once | Def 1.3; Props 7.5, 7.6 | Prop 5.10: what fails; (fd) form survives | — |
| frozen labels, per-query likelihood (a fixed table queried repeatedly) | — | not treated | the sampled population objective with $y^*$ the table; `../teacher/referee-B.md` B-M1: the right flatness is the input multiplicity $n/N$ |
| a single data set (fixed domain): full tables, samples without replacement | Prop 7.6(c) | §2–§4; schemes (wor) and (fd) of §5 | full-table statements (Props 2.4, 3.1) |
| population, $\lambda=cn$ | Prop 3.4 | Remark 2.4 (`lem:setup:hull`) | Lemma 1.1, population reading; Prop 3.2(d) |

* All three sub-tracks now say the same about frozen labels and repeats: with labels redrawn at every query, fixed λ (indeed every $\lambda_n=o(n)$) identifies the sampler; with labels reused, it does not. In Paper 2's data-set object the reason is that a competitor differing on finitely many atoms accumulates bounded evidence (Prop 5.10; `../iid/` Prop 7.5). With per-query likelihoods on a frozen table it is that each frozen label is reused $n/N$ times, the teacher's reuse factor with $m=d$ (`../teacher/referee-B.md` B-M1). On a finite domain the frozen data set converges to the full table, and §4 is then the relevant object: frozen noise of rate $p$ on $\{0,1\}^d$ is the $m=d$ error set.
* `../iid/referee-B.md` b11 asked for one object per thread: per-query for the asymptotic and finite-sample T1 theorems, single data sets for T2, with the bridge stated for the pair. §5 does this: the bridge (Thm 5.4) is stated in both (pq) and (wor)/(fd), and Prop 5.10 says what does not cross.

### 9.2 Definitions and notation

* *Shared with `../iid/`:* $\ell^*$, $E$, $E^*$, $\gamma(\pi)=\mathbb E_\mu\mathrm{Hel}$, $\gamma_<$, $\gamma_L$ (here $\gamma_{\bar\ell}$), $S_n$, $\Lambda_n$, δ*, the per-query likelihood, "equivalent" = μ-a.e. equal kernels. `notes.md` used $\ell_0$, $L_0$, $\mathrm{Hel}_\mu$ and $\gamma_-$; these are renamed (Notation table). One difference remains: `../iid/` writes $L_n(\pi)$ for a likelihood and $L$ for a length cap; this record writes $F(\pi)=-\log L_n(\pi)$ for the fit and $\bar\ell$ for caps.
* *Shared with `../teacher/`:* the fit $F$ of its Setting 1.0 (data reading), the kink vocabulary (left steepness, right flatness), and the offset $b_0=b_0'$, now with $2\log(d+1)$ in both (`../teacher/referee-B.md` B-m5, item 2, asked for exactly this alignment). The sharp floor: $\mathrm{Floor}_{t+1}(I)=\max\{0,F^\sharp_t(I)\}$ at $B=\infty$. The symbol $\Psi_t$ is used only by `../teacher/` (for $\inf_I[cI+\mathrm{Floor}_t(I)]$); this record's former $\Psi_t(\lambda)$ is now $\Gamma_t(\lambda)$.
* *κ bookkeeping.* Where the two records state the same bound, this record counts the coding bound's constant separately: Prop 4.2(b) has $\bar\ell_\lambda=d+\kappa_g+(b_0+\kappa)/(\lambda-1)$, while `../teacher/` Prop 2.4(i) has $d+\kappa_g+b_0'/(\lambda-1)$ with one κ absorbing both. They agree at κ = 0, and both are valid, since occurrences of κ may differ; the κ = 30 rows of k4/k7 are the more conservative count.

### 9.3 Results that coincide, overlap or depend on each other

* **`../iid/` Lemma 8.1 and Lemma 5.2 here.** Both bound the left side of the sample kink. Lemma 5.2 is uniform over all programs and a factor 2 sharper in the exponent; `../iid/referee-B.md` b10 recommends carrying it in the paper. The right side of the sample kink has slack $\ell^*+\delta^*$ (or $\ell^*+\log(1/\varepsilon)$), as Thm 5.4(ii) states; `../iid/referee-B.md` B2 corrects iid's reading to exactly this form.
* **`../iid/` Thm 3.1 and Cor 5.7 here.** They agree: almost sure exact recovery in the per-query object, for every fixed λ > 1 (both) and at λ = 1 (iid Thm 3.1; here Cor 5.7(d), derived from it). Cor 5.7(d) adds the geometric reading: λ = 1 is eventually strictly inside the kink.
* **`../iid/` Thm 4.1(iv) and Cor 5.5/Thm 5.6 here.** Two finite-sample forms with the same leading order. With $\log e=1/\ln2$, Cor 5.5's sample size is $\ln2\,[(2-\lambda)^+\bar\ell_\lambda+\lambda\ell^*+2\log(1/\varepsilon)]/(2\gamma_{\bar\ell_\lambda})$ with guarantee $1-2\varepsilon$; iid's is $\lambda(\ell^*+\log(2/\varepsilon))\ln2/(2\min(1,\lambda-1)\gamma_{L_\varepsilon})$ with guarantee $1-\varepsilon$ and $L_\varepsilon\approx\bar\ell_\lambda$. Both are $\Theta(\lambda\ell^*/(\min(1,\lambda-1)\gamma))$. Thm 5.6 is the near/far refinement; `../iid/referee-B.md` b3's free-exponent bound is its per-program form.
* **`../iid/` Prop 4.4 and Prop 5.8 here.** Both show that the $1/\gamma$ dependence is necessary through a shorter competitor; iid's uses a variance bound with explicit Bernoulli constants, this one Markov's inequality on the KL evidence. They are consistent.
* **`../iid/` Props 7.5, 7.6 and Prop 5.10 here.** Same phenomenon; Prop 5.10 cites them for what survives.
* **`../teacher/` Lemma 1.1 and Thm 3.2, Cor 3.3 here.** `../teacher/` Remark 1.3 shows that Thm 3.2(a)–(b) (up to windows), Cor 3.3 and Thm 5.4(ii) are instances of its two-sided kink lemma: the left kink is the case $N=\{\pi:\ell(\pi)<\alpha_--w_-\}$; Cor 3.3 is its right condition (R) with τ = 1 and $g=b+\kappa$; Thm 5.4(ii) is (R) with τ = 1 and $g=\ell^*+\log(1/\varepsilon)$. Its referee A checked this. The two forms complement each other: Lemma 1.1 allows a property-defined left set and an unattained anchor, which the teacher theorem needs; Thm 3.2(a) is pointwise and needs no positive infimum over the left set (`../teacher/referee-A.md` m2 notes that Lemma 1.1(ii) at ε = 0 needs $m_N(c)>0$ strictly); and this record adds the exact hull description (Thm 2.2) and the converse (Thm 3.4).
* **`../teacher/` Prop 2.4 and Cor 3.3(a), Prop 4.2 here.** For $m=d$ the teacher's right condition is the sufficiency line; this is Cor 3.3(a) with $\pi_s=\pi_g$ and $b=b_0$. The identification numbers agree once the κ bookkeeping above is taken into account (k7(b): $d+45.69$ at λ = 2, κ = 0; `../teacher/referee-B.md` B-m5, item 2, computed $d+45.69$ from $b_0'$).
* **`../teacher/` Prop 3.1 and Prop 4.2 here.** For $m=d$ its window $(2^{d-m},Nc_{\rm hi})=(1,Nc_{\rm hi})$ is contained in Prop 4.2's G-floor range, as shown in §4(a).
* **`../teacher/` §5 and open question 3.** Answered there for the population objective (§8).
* **`../teacher/` Remark 3.4** cites Thm 5.4's left steepness for fresh noise. That is the (pq) object, consistent with this revision. The citation should carry the probability (≥ 1 − ε), the term $-2\log(1/\varepsilon)$ and the condition $A\ge2\ell^*$ (`../teacher/referee-A.md` m4, m9).
* **Two kinks.** The k2(F) and rB2 instances here and `../teacher/` t3 show the same phenomenon: a structured error rule adds a second kink, and the model is selected only for λ between them.

### 9.4 No contradictions found

Every result of this record that a sibling cites, and every sibling result cited here, was compared statement by statement. Apart from the notation and κ-bookkeeping differences of §9.2 and the scope of the object (§9.1), which this revision aligns, no contradiction was found. The brief's sentence "λ = 1 never makes the split exact" has the same status in all three: false asymptotically in the per-query object (`../iid/` Thm 3.1; Cor 5.7(d)); on single data sets λ = 1 sits near the memoriser edge (`thm:split:lambda1`, `cor:teacher:fulltable`(ii), Remark 5.9).

---

## 10. Claims and statuses

| # | claim | status |
|---|---|---|
| §1 | the coding bound holds in every hypothesis class; fails for countable classes that are not uniformly lsc | proved |
| §1-old | "a data-set class whose programs satisfy (F1)" suffices for the coding bound | **withdrawn** (A5) |
| 2.1–2.3 | hull = convex minorant; λ-MAPs at slope −λ, edges and ties; duality | proved; computed k1, k2, rB1 |
| 2.5 | sufficiency line bounds the hull | proved (hypothesis class); computed rB1 |
| 3.2(a)–(c) | kinks locate the λ-MAPs; strict inequalities needed | proved; computed k1, k8(A), rB1 |
| 3.2(d) | zero-window kink with τ < σ ⟺ hull vertex | proved; computed k8(A), rB1 |
| 3.2(d)-old | zero-window kinks (without τ < σ) are exactly the vertices | **refuted** ((0,10),(1,5),(2,0)) |
| 3.3 | the split theorem for one data set | proved; computed rB1 |
| 3.4 | stable MAP lengths ⟺ zero-window kinks at vertices | proved; computed k1, rA(9), rB1 |
| 3.5(i), (ii) | universal member: kink steepness ≤ $1+(\ell_U+\kappa_0)/(\alpha_k-\ell_U)$; MAP length ≤ $\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$ | proved; computed k1, k8(B), rB1 |
| 3.5-old | "by Cor 3.3(b), λ-MAPs for λ > 1 stay below $\ell_U+(\ell_U+\kappa_0)/\epsilon$" | **refuted** (U = (2,15), A = (5,10), λ = 3/2) |
| 4.1 | left kink at the good model, steepness exponential in $d$ | proved |
| 4.2(i) | λ-MAP is parity + noise under $C_{t_0}(\lambda)$, items (a)–(g), class must contain a good model | proved; computed k4, k7, rB4 |
| 4.2(ii) | interval form; certified ranges | proved; computed k7 |
| 4.2-num | the tables of §4 | computed k7 (κ = 0 rows illustrations) |
| 4.3 | level ≤ 2 for every $p<1/4$, level 1 for $p<0.12331$, large $d$ | proved; constant computed k4, k7, rA(4), rB4 |
| 4.3-old | "$f_2-H\ge0.0188$" | **refuted** (0.018795); now ≥ 0.0187 |
| 4.4 | set models: steepness ≤ $1+O((\log d+\delta_E)/d)$ at α ≈ d | proved; computed k8(D), rB2 |
| 4.4-old | "the set λ-MAP is $A_0$ for all λ ∈ (1, 27.5): the parity is noise" | **refuted as code-independent** (k8(D), rB2); true for k2's fixed-length code |
| 4-illus | product and set hulls, two kinks (corrected ranges) | computed k2, k8(D), rB2 |
| 5.1 | evidence bounds in (pq), (wor), (fd) | proved (Maclaurin known, unverified theorem number); computed k6(A), rA(7) |
| 5.1-old | the scheme "(iid): non-atomic μ on X" and its statements | **withdrawn** (vacuous on countable X) |
| 5.2 | uniform likelihood-ratio bound with evidence $e(\pi)$ | proved; computed k3, k6(B), k6(D), rB3, rB5 |
| 5.3 | Ville: fixed $n$ (strict), all $n$ (non-strict) | proved / known |
| 5.4 | the sample kink in (pq), (wor); (fd) form | proved; computed k3, k6(D), rB3(E2) |
| 5.5, 5.6 | explicit sample sizes; near/far | proved; computed k6(D), rB3(E2); vacuous for k3's instance |
| 5.7(a)–(c) | (pq): linear steepness, right slope limsup ≤ 1, every λ > 1 selects $E^*$ eventually | proved; computed k6(D) |
| 5.7(d) | (pq): eventually right slope < 1 < left steepness; λ = 1 inside the kink | proved (from `../iid/` Thm 3.1 and Thm 2.2); computed k6(D), k8(C) |
| 5.7-old | Cor 5.7 "under (iid) with an infinite sample"; "strengthens `thm:split:private`(iv) under i.i.d. inputs" | **withdrawn** (vacuous), restated in (pq); **refuted** in the frozen reading (Prop 5.10(b)) |
| 5.8 | the margin is necessary | proved; computed k5, rA(8), rB5 |
| 5.8-rem | "the order $\lambda\ell_0/\gamma$ in Cor 5.5 cannot be improved beyond constants" | **withdrawn**; restricted version [proof sketch] |
| 5.10 | frozen labels with atomic μ: Lemma 5.1's bound and Cor 5.7(c) fail; (fd) form and "on the run" survive | proved; computed k6(A), k6(C), rA(1), rB6 |
| 5.11 | non-atomic μ needs an uncountable input space | remark |
| 6 | "the model consists of the bits that each explain more than λ bits of data", in hull-averaged form | interpretation of Thm 2.2 |

---

## 11. Files

* `checks/k1_hull.py` (+ `.out`): Thms 2.1, 2.2, Prop 2.3, Thms 3.2, 3.4 and Prop 3.5(i) in exact rational arithmetic on 600 random point sets.
* `checks/k2_parity_class.py` (+ `.out`): exactly enumerable product and set classes on full parity tables; hulls and MAPs for all λ; two kinks.
* `checks/k3_sample_kink.py` (+ `.out`): (wor) samples from a noisy parity on $\{0,1\}^{16}$; Lemmas 5.2, 5.3; Thm 5.4; Cor 5.5; Thm 5.6. Its τ_L lines are not checks of Thm 5.4(iii) (§5.4).
* `checks/k4_parity_numbers.py` (+ `.out`): Prop 4.2 numbers on a grid, with the old $b_0$; comparison with `cor:teacher:fulltable`; crossovers and interval check.
* `checks/k5_margin_necessity.py` (+ `.out`): Prop 5.8, exact binomial.
* **New:** `checks/k6_perquery.py` (+ `.out`): Lemma 5.1 in all schemes by exact enumeration; Lemmas 5.2 (fd) and 5.3 by exact enumeration over 300 classes; the frozen counterexample; the per-query noisy parity with $n$ up to $2^{20}$ (Thm 5.4(i)–(iii), Cors 5.5, 5.7, Thm 5.6).
* **New:** `checks/k7_parity_certified.py` (+ `.out`): certified λ-intervals of Prop 4.2 (cell argument of (ii)); the aligned $b_0$; item (g); the constant of Cor 4.3 rounded down.
* **New:** `checks/k8_small_fixes.py` (+ `.out`): Thm 3.2(d) with τ < σ and strictness; Prop 3.5(ii) and the refuted cap; the deterministic step of Cor 5.7(d); set models under two codes for $v$.
* `referee_code/`: the referees' scripts `rA_checks.py`, `rB1`–`rB6` (+ `.out`), unchanged.

---

## Verification log

*All scripts were run with Python 3.11.15 (numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) on 2026-10-13, with `python3 -I`. Run times are wall-clock on the session machine.*

**1. Re-runs of the existing scripts (prover's and referees').** All twelve were copied to a scratch directory and re-run; every output is byte-identical to the saved `.out` file.

| script | what it checks | run time | result |
|---|---|---|---|
| `checks/k1_hull.py` | §2–§3 on 600 random point sets, exact arithmetic | 38 s | identical |
| `checks/k2_parity_class.py` | full-table product and set hulls; two kinks | 20 s | identical |
| `checks/k3_sample_kink.py` | (wor) samples, $d=16$ | 43 s | identical |
| `checks/k4_parity_numbers.py` | Prop 4.2 numbers (grid, old $b_0$) | 1 s | identical |
| `checks/k5_margin_necessity.py` | Prop 5.8, exact binomial | 11 s | identical |
| `referee_code/rA_checks.py` | referee A's ten probes | 29 s | identical |
| `referee_code/rB1_hull_kinks.py` | §2–§3, 1500 point sets, exact | 168 s | identical |
| `referee_code/rB2_parity_table.py` | explicit full-table classes, set codes, two kinks | 98 s | identical |
| `referee_code/rB3_sample_kink.py` | E0 self-test, E1 whole-class Lemma 5.2, E2 where Thm 5.4(iii) applies | 265 s | identical |
| `referee_code/rB4_parity_numbers.py` | independent recomputation of §4 numbers, mpmath | 52 s | identical |
| `referee_code/rB5_margin_exact.py` | Prop 5.8 over 320 settings | 11 s | identical |
| `referee_code/rB6_atomic_inputs.py` | frozen versus fresh labels, atomic μ | 4 s | identical |

**2. New scripts of this revision.** Each was run once to produce the saved output, and re-run into a scratch directory after the last edit; all three reproduced their saved outputs byte for byte (k6: 9 s; k7: 2 s; k8: 2 s). No script imports a local module, so no cache files were created.
* **`checks/k6_perquery.py`** [seeded: `numpy.default_rng(6)` for (A)–(B); `default_rng(60)` for $a^*$ and `default_rng(60+k)` for the $k$-th sample size in (D)].
  * (A) Lemma 5.1: (pq) identity to $4.3\cdot10^{-14}$ by exact enumeration of all sequences ($n\le6$, 20 random triples, sub-probability programs); (fd) identity to $5.6\cdot10^{-16}$ (50 kernels, all $2^8$ label vectors); (wor) Maclaurin step over 3386 (population, $n$) cases with zeros, largest ratio 1.000000 (asserted ≤ 1); frozen labels with repeats: 0.7071 against $(1-\gamma)^n=0.0512$ at $n=100$.
  * (B) Lemma 5.2 (fd) and Lemma 5.3(a), exact over all $2^{10}$ label vectors for 300 random classes: largest ratios to the bound 0.2006 and 0.2253 (asserted ≤ 1).
  * (C) Referee A's frozen counterexample, exact: frozen probability → 1/2, per-query → 0 ($10^{-8}$ at $n=64$).
  * (D) The per-query noisy parity: Kraft sum 0.2066 (asserted ≤ 1); π* is the only equivalent program (asserted). Lemma 5.2's slack is minimised exactly over the whole class: for each family the minimiser is computed in closed form (extreme mismatch counts for parities, best exception sets for memorisers, padded with unqueried inputs, whose gap contribution is the same for every choice), including deterministic variants and the full table. Every quantity quoted in §5.4(3) is copied from the output.
  * A first draft of (A) printed "the bound fails" also at $n=1$, where the frozen and per-query values are equal; the message was corrected before the saved run. The line printing Cor 5.7(a)'s rate (0.01263) was added after the first full run, to replace a hand computation; the re-run changed nothing else.
* **`checks/k7_parity_certified.py`** [deterministic]. Functions copied from k4, with two marked changes ($b_0$ with $2\log(d+1)$; the cell certification). For every row of k4's tables (a) and (c), the grid range of k4 is reproduced, and a certified interval is grown by cells of Prop 4.2(ii) (adaptive widths in $\log(\lambda-1)$, down to $10^{-5}$). Every certified interval agrees with the grid range to the printed 5–6 significant digits. (b) prints item (g) and both versions of $b_0$; with the old $b_0$ it reproduces k4's and rB4(b)'s numbers exactly ($d+45.54$, 58.19, 0.9928, 0.2081). (d) prints the interval-check bound rounded down: 0.01879.
* **`checks/k8_small_fixes.py`** [seeded: `random.Random(8)`; exact `Fraction` arithmetic in (A)–(C)].
  * (A) 1200 point sets: 2687 zero-window kinks with τ < σ, all vertices (asserted); 25 with τ = σ, none a vertex; 1487 cases where a λ-MAP lies left of the kink point at λ = σ.
  * (B) 54,000 cases: 0 violations of Prop 3.5(ii) and of the ε-cap for $\lambda\ge1+\epsilon$ (asserted); 5911 violations of the ε-cap for $\lambda\in(1,1+\epsilon)$; referee A's instance reproduced.
  * (C) 2982 point sets with a unique 1-MAP point: all vertices with right slope < 1 < left steepness (asserted).
  * (D) Set hulls with a fixed and an Elias-γ code for $v$, $d\in\{8,\dots,30\}$; Prop 4.4's class-form bound asserted in all 14 instances.
  * A first run of (D) coded $v$ by Elias γ of $v+2$ instead of $v+1$ (the helper `gam(k)` codes $k\ge0$ as γ of $k+1$, and was called with $v+1$). That run showed no parity-knowing set λ-MAP above λ = 1 and disagreed with rB2. After the fix the output reproduces rB2's λ-ranges exactly ((0.9028, 3.0) at $d=8$ through (1.0000, 1.3636) at $d=30$). Only the corrected run is saved.

**3. How each referee claim was checked.**
* *A1/B1.* Re-derived: $X=\{0,1\}^*$ is countable (`def:setup:data`), so every input law is atomic. Both counterexamples re-derived by hand and recomputed exactly (k6(C)); rA(1) and rB6 re-run. The (pq) restatement re-proved line by line (Lemmas 5.1–5.3, Thm 5.4, Cors 5.5, 5.7, Thm 5.6, Prop 5.8), and checked by exact enumeration (k6(A)) and simulation where every hypothesis holds (k6(D)).
* *A2/B2.* The counterexample and the role of τ < σ in the proof of Thm 3.2(d) re-derived; k8(A).
* *A3/B3.* The counterexample re-derived; Prop 3.5(ii) proved; k8(B).
* *A4/B9.* rA(4), rB4 and k7(d) agree: 0.0187953 (cells), 0.0187969 (at $p=1/4$).
* *A5.* Checked against `app-setup.tex` (proof of the coding bound uses (F2) with a fixed program and uniform lower semicomputability) and `def:setup:class`; the counterexample is immediate.
* *A6(a).* Checked against `prop:related:computable`(a). *A6(b).* Monotonicity of $\Gamma_t$ in λ proved (Prop 4.2(ii)); k7 certifies. *A6(c).* k4(a), k7(a).
* *A7.* Each §0 item re-read against its theorem. *A8, B10.* rA(8), rB5 re-run; the wording restricted. *A9.* k3's output. *A10.* Hoeffding: see 4 below; Ville (`lem:split:ville` is non-strict); symbols renamed throughout.
* *B4.* k3's thresholds compared with $|X_0|$; rB3(E2) re-run; k6(D) added.
* *B5.* Reproduced independently by k8(D). *B6.* rB2's output and k2(C). *B7.* k2(F)'s output. *B8.* k7(b) (and rB4(b)).

**4. Literature.** One web search for Hoeffding (1963), Theorem 4: two secondary sources (Luh and Pippenger, arXiv:1107.1533; El-Yaniv and Pechyony, arXiv:1107.0046, Lemma 12) place the comparison of sampling with and without replacement in §6, Theorem 4, for continuous convex functions. The original was not reached; the citation is marked accordingly. The proof of Lemma 5.1(wor) uses it only through the identity $\mathbb E\prod a(x_i)=e_n(a)/\binom Mn$ and Maclaurin's inequality (theorem number in Hardy–Littlewood–Pólya unverified), which k6(A) and rA(7) check numerically.

**5. Proof checks done here.**
* Every proof in §2–§5 was re-derived once after writing, in particular: the τ < σ step of Thm 3.2(d); Prop 3.5(ii); the $b_0$ derivation with (F3), (F5); the monotonicity of $\Gamma_t$ and the cell argument of Prop 4.2(ii); item (g) from the two floors; Lemma 5.1(wor) via Maclaurin; Lemma 5.2 with the evidence functional; Cor 5.7(d) from `../iid/` Thm 3.1 and Thm 2.2; Prop 5.10.
* Cross-track statements (§9) were compared against `../iid/notes.md` (Defs 1.1–1.3, Lemmas 2.1–2.2, Thms 3.1, 4.1, Props 4.4, 7.5, 7.6, Lemma 8.1), `../teacher/notes.md` (Setting 1.0, Lemma 1.1, Remark 1.3, Props 2.4, 3.1, 3.2, Remark 3.4, §5) and the four sibling referee reports.

**6. Not done.**
* No independent referee has read this revision.
* The KL–Hellinger comparison constants cited after Prop 5.8, and Hoeffding's and Maclaurin's theorem numbers, were not checked against the sources.
* The literature question of §7 is open.
* The sibling sub-tracks' final records do not exist yet; §9 compares with their current notes and referee reports.

**7. Repository.** No git command was run. Files written, all under `research/tracks/split/kink/`: `notes-final.md`; `checks/k6_perquery.py`, `checks/k7_parity_certified.py`, `checks/k8_small_fixes.py` and their `.out` files. `notes.md`, `checks/k1`–`k5`, the referee reports and `referee_code/` are unchanged. Scratch copies of the re-runs are in the session scratchpad only.
