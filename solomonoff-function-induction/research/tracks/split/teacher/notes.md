# Track "split", sub-track "teacher": the teacher's mistakes as an instance of the split (target T3)

*Brief: `../00-brief.md`, target T3. Written 2026-10-13.*

* **Sources read.**
  * The brief, in full.
  * Paper 2 (`paper-steeper/sections/`):
    * `setup.tex` and `app-setup.tex`: `lem:setup:hull`, `lem:setup:coding`, `rem:setup:persample`.
    * `absorb.tex`.
    * `split.tex` and `app-split.tex`: `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `thm:split:shared`.
    * `algstat.tex` and `app-algstat.tex`: `prop:algstat:parity`.
    * `teacher.tex` and `app-teacher.tex`: `thm:teacher:main`, its four lemmas, `lem:teacher:sharpfloor`, `cor:teacher:fulltable`, `cor:teacher:sampled`, `prop:teacher:concentration`.
    * `limits.tex` and `app-limits.tex`.
    * `intro.tex`, `discussion.tex`.
  * The refereed record `research/tracks/steeper/notes-final.md`: §1.1–1.3, §2.1–2.5, §3.1–3.6 and §4.4.
  * Paper 1: `paper/sections/setting.tex` and `versions.tex` (skimmed for `def:versions:variants` and `rem:versions:operator`).
  * `paper/NOTATION.md`.
  * The two sibling sub-tracks:
    * `../iid/notes.md` (T1), read in full;
    * `../kink/notes.md` (T2), read §0–§6 and §8; it appeared while this work was in progress.
  * Paper 2's labels are cited as written (`thm:teacher:main` etc.). "St" is the steeper record; "iid" and "kink" are the sibling notes, with their own numbering.
* **Scripts.** All are in `checks/`, written in Python 3.11 and deterministic or seeded; each output is saved next to its script as a `.out` file.
  * `t1_kink_instances.py`: the kink lemma by brute force; the teacher's and the split's constants as instances; full tables for every m.
  * `t2_reuse_factor.py`: exact hulls in an explicit product class, on full tables for several m and on samples of growing size.
  * `t3_second_kink.py`: exact hulls with error envelopes, and rate blindness as the model grows.
  * `t4_junta_window.py`: the junta window for flip rates 0.056 ≤ p < 0.1233.
  * `tcommon.py`: helpers shared by t2 and t3.
* **Status tags.**
  * **[proved]**: full proof here, or a one-line derivation from cited proved results.
  * **[computed: tN]**: checked by `checks/tN_*.py`; output in `checks/tN_*.out`.
  * **[known: ref]**: standard or published; "(unverified)" when not checked against the source.
  * **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]**: as named.
* **Illustration (κ = 0).** A number obtained by setting the unknown machine constant κ to 0. It is not a result about any reference machine. Rows with κ = 30 show how the bounds degrade.

Notation follows `paper/NOTATION.md` and `def:teacher:instance`: $n$ samples, $d$ input length, $N=2^d$, $m$ the junta length, $p$ the error density, $s_0=p2^m$, $c=\lambda/n$, κ the machine constant. $\log=\log_2$. Local symbols are defined where they first appear.

---

## 0. Summary

1. **One kink lemma covers both threads (§1)** [proved; computed: t1(A)].
   * Lemma 1.1 is a two-sided kink lemma in the (length, fit) plane. It has two features beyond the kink sub-track's Thm 3.2.
     * *A property kink on the left.* The left condition is about a set N of programs defined by a property ("does not know the model"), not only by length. This turns a conclusion about lengths into "every near-optimal program knows the model".
     * *An unattained anchor on the right.* The right condition is a line of slope −τ under the other programs M. Its anchor need not be attained by a program; the reference point sits a vertical distance g above the line.
   * The conclusions:
     * near-optimal programs are in M;
     * their length is at most $\ell_0+(g+\epsilon)/(c-\tau)$;
     * their fit is at least $F_0-(cg+\tau\epsilon)/(c-\tau)$;
     * the reference point is optimal up to $g+(c-\tau)(\ell_0-\ell_M)$.
2. **The teacher's theorem is this lemma with τ = 2^{-m} (§2)** [proved; computed: t1(B)].
   * *Left condition.* The left margin is $\Phi_2-J_g$, and its steepness is $c_{\rm hi}$. It comes from list decoding, $K(a)\ge d$, the risk floor and $p<0.056$.
   * *Right condition.* It is (D1)–(D2): every program that knows the parity lies above the line of slope $-2^{-m}$ through $(d-4-\Lambda_1,\,B_S/2^m)$. It comes from the product form of the error set, the coding lemma, the incompressibility $\delta_S$ and list decoding.
   * *What the lemma gives.* It reproduces $\Phi_1$, $\Delta(c)$, $\Delta_\ell$ and the risk bound (ii)(b) *exactly*: the relative differences are below $3\cdot10^{-14}$ over 17,411 random parameter sets.
   * *What it does not give.* Parts (ii)(a), (d), (e), (iii) and (iv) are not geometry. They say what the hull position means: knowing the model, holding little information, not predicting the errors.
   * Table 2.2 assigns every hypothesis of `rem:teacher:hypotheses` to the kink condition it serves.
3. **The private-randomness split is the same lemma with τ = 1 in total bits (§2)** [proved; computed: t1(C), t1(D)].
   * *The split.* `thm:split:private`(i) is Lemma 1.1 with Ville's line: τ = 1, $g=k+\delta^*$, and no left condition.
   * *Idiosyncratic errors.* For $m=d$ on the full table, the teacher's right condition is the product sufficiency line, valid for every program. So `cor:teacher:fulltable` is the split's case, and both windows start at λ = 1.
   * *The analogy.* The Ville deficiency δ* of the noise and the deficiency $\delta_S$ of the error rule play the same role and have the same $2^{-j}$ tail.
4. **Why fixed λ suffices for noise and λ ∝ n is needed for errors (§3)** [proved; computed: t1(D), t2].
   * *The right flatness is the reuse factor.*
     * In total bits, the right flatness at the model is the number of data points each bit of the "noise" pays for.
     * Fresh noise pays for one: Ville, uniformly in $n$.
     * A junta error rule on the full table pays for $2^{d-m}=N/2^m$ (Prop 3.1). With $n$ samples this is about $n2^{-m}$ once the rule's cells repeat (Prop 3.3).
     * The model's left steepness grows like $n$ in both cases.
     * So the window in λ is $(1,\Theta(n))$ for noise and $(n2^{-m},nc_{\rm hi})$ for errors.
   * *Explicit class.* In an explicit class the lower end is 0.995, 3.75 and 15.7 against $2^{d-m}=1,4,16$ (t2(A)). On samples it tracks the error cells' multiplicity, from about 1 at $n\ll2^m$ to $0.94\,n2^{-m}$ at $n\gg2^m$. A fixed λ = 2 keeps the good model up to $n=2^m$ and loses it from about $n=2^{m+1}$ on (t2(B)).
   * *Which vertex (Prop 3.2).* Every schedule $\lambda_n=o(n)$ eventually rejects every program that is not of least population risk.
     * A sampler with fresh noise has least risk (Gibbs), so the split's target is the last vertex of the population hull.
     * The teacher's good model does not: the memoriser has risk 0. So its target is an interior vertex, and only $\lambda=cn$ can stop there.
     * This is the hull form of `prop:limits:plain`(b) and `rem:limits:schedule`.
5. **Structured errors make a second kink (§4)** [proved; computed: t3].
   * *Envelopes.* A cheap, dense part of the error rule is a component with its own rate, far above $2^{-m}$. It adds a second kink to the right of the model. This raises the lower end of the window from $2^{-m}$ to about the envelope's rate (`prop:limits:envelope`(i) is Lemma 1.1(ii)'s third inequality, with the envelope as reference).
   * *Rate blindness.* `prop:limits:rateblind`'s condition (⋆) says exactly that the error kink is at least as steep as the model kink, so the model's λ-interval is empty.
   * *Computed.* In an exact class the good model's λ-interval starts at 15.0, 17.1, 42.7 and 85.3 for cheap parts of 0, 2, 4 and 8 cells out of 16, and is empty when all 16 cells form a cheap subcube. A fixed cheap rule closes the window as $d$ grows: at $d=13$ in t3(B).
6. **New: the junta window extends to every p < 0.1233 (§5)** [proved; computed: t4].
   * *The obstacle.* For $p\ge0.056$ the paper's window is empty. `rem:limits:method` explains why: a program that does not know the parity can hold up to $L_S$ bits about the rule near $c=2^{-m}$, and the deviation term of the sharp floor is then large.
   * *The fix.* Charge that information in the objective. A program of level t that holds I bits about the rule beyond the parity has length at least $d-\min\{s(t)+2\log d,d\}+I-O(\log d)$: the step of `thm:teacher:main`(ii)(d), read backwards. So it pays $cI\ge2^{-m}I$, while the sharp floor gains it only about $2p\sqrt{I\ln2/(2s_0)}$.
   * *The result.*
     * The identification of `thm:teacher:main`(ii) holds for every $p<0.12331$ in the limit of large $m$, for $c\ge a^*(p)2^{-m}$.
     * $a^*(p)=1$ for $p<p^*=0.07787$, and $a^*\to\infty$ as $p\to0.12331$.
     * At the example's sizes ($d=100$, $m=20$, κ = 0) there are certified windows for $p=1/16,5/64,3/32,7/64,15/128$, none of which has a window in the paper. For $p=1/16$ the window is $(2^{-20},2.4\cdot10^{-3}]$.
   * This answers the junta half of the kink sub-track's open question 3 and the case $p<0.1233$ of `q:teacher:open`(b) and `q:limits:open`(b), for the population objective.
7. **Presentation (§6).**
   * The teacher result becomes "the split at a positive rate". Its four lemmas prove two kink bounds, and Lemma 1.1 does the rest.
   * About a page of `teacher.tex`, `app-teacher.tex`, `algstat.tex` and `limits.tex` can be cut or merged (list in §6.2).

---

## 1. One kink lemma for both threads

**Setting 1.0.**
* *Programs and fits.* $\mathcal P$ is a countable set of programs π with lengths $\ell(\pi)\ge0$ and two fits $0\le F'(\pi)\le F(\pi)\le\infty$.
* *Objectives.* For $c>0$: $J_c(\pi):=c\,\ell(\pi)+F(\pi)$, $J'_c(\pi):=c\,\ell(\pi)+F'(\pi)$ and $\Phi(c):=\inf_\pi J_c(\pi)$.
* *Two readings.*
  * **Data:** $F=F'=-\log\nu_\pi(D)$ and $c=\lambda$, in total bits.
  * **Population:** $F=R$, $F'=R_B$ and $c=\lambda/n$, per sample.
* *The reference point.* $(\ell_0,F_0)$ is **bounded** if some program has $\ell\le\ell_0$ and $F\le F_0$. Then $\Phi(c)\le c\ell_0+F_0$ for every $c>0$.
* *The partition.* $\mathcal P=M\sqcup N$. Put
  $$m_N(c):=\inf_{\pi\in N}J'_c(\pi)-(c\ell_0+F_0)\in(-\infty,+\infty],$$
  with $m_N\equiv+\infty$ if $N=\emptyset$. This is the **left margin** at slope $c$.

**Lemma 1.1 (two-sided kink with a property) [proved; computed: t1(A)].** In Setting 1.0, let $(\ell_0,F_0)$ be bounded. Assume:

**(R)** there are $\tau\ge0$, $g\ge0$ and $\ell_M\le\ell_0$ such that every $\pi\in M$ has $\ell(\pi)\ge\ell_M$ and
$$F'(\pi)\ \ge\ F_0-g-\tau\,(\ell(\pi)-\ell_0).$$

Let $c>\tau$. Then:
* (i) $\inf_\pi J'_c\ge c\ell_0+F_0+\min\{m_N(c),\,-\Delta(c)\}$, where $\Delta(c):=g+(c-\tau)(\ell_0-\ell_M)\ge0$. In particular, if $m_N(c)\ge0$, then
  $$c\ell_0+F_0-\Delta(c)\ \le\ \Phi(c)\ \le\ c\ell_0+F_0 .$$
* (ii) Let $0\le\epsilon<m_N(c)$. Take every π with $J'_c(\pi)\le c\ell_0+F_0+\epsilon$. This includes every π with $J_c(\pi)\le\Phi(c)+\epsilon$. Every such π lies in $M$ and satisfies
  $$\ell(\pi)\le\ell_0+\frac{g+\epsilon}{c-\tau},\qquad F'(\pi)\ge F_0-\frac{cg+\tau\epsilon}{c-\tau},\qquad F'(\pi)\le F_0+\epsilon+c\,(\ell_0-\ell(\pi))\le F_0+\epsilon+c\,(\ell_0-\ell_M).$$
* (iii) $m_N$ is concave in $c$.

*Proof.*
* *(i).* For $\pi\in N$, $J'_c(\pi)\ge c\ell_0+F_0+m_N(c)$ by definition. For $\pi\in M$, (R) gives
  $$J'_c(\pi)\ge c\ell+F_0-g-\tau(\ell-\ell_0)=(c-\tau)\ell+\tau\ell_0+F_0-g\ge(c-\tau)\ell_M+\tau\ell_0+F_0-g=c\ell_0+F_0-\Delta(c).$$
  The last step uses $c>\tau$ and $\ell\ge\ell_M$. Finally $\Phi\ge\inf J'$ because $F\ge F'$, and $\Phi\le c\ell_0+F_0$ because the reference point is bounded.
* *(ii), membership.* $J_c(\pi)\le\Phi(c)+\epsilon$ implies $J'_c(\pi)\le J_c(\pi)\le c\ell_0+F_0+\epsilon$. A program in $N$ has $J'_c\ge c\ell_0+F_0+m_N(c)>c\ell_0+F_0+\epsilon$, so π ∈ M.
* *(ii), length.* (R) and $J'_c(\pi)\le c\ell_0+F_0+\epsilon$ give $c(\ell-\ell_0)-g-\tau(\ell-\ell_0)\le\epsilon$, that is $(c-\tau)(\ell-\ell_0)\le g+\epsilon$.
* *(ii), lower fit.*
  * If $\ell\ge\ell_0$, then $F'\ge F_0-g-\tau(\ell-\ell_0)\ge F_0-g-\tau(g+\epsilon)/(c-\tau)=F_0-(cg+\tau\epsilon)/(c-\tau)$.
  * If $\ell<\ell_0$, then $F'\ge F_0-g$. This is at least the same bound, because $(cg+\tau\epsilon)/(c-\tau)\ge g$ whenever $\tau(g+\epsilon)\ge0$.
* *(ii), upper fit.* Rearrange $J'_c(\pi)\le c\ell_0+F_0+\epsilon$, then use $\ell\ge\ell_M$.
* *(iii).* $m_N$ is an infimum of functions affine in $c$. ∎

**Remark 1.2 (the left margin as a wedge) [proved].** Let σ > 0 and μ ≥ 0. Suppose every π ∈ N lies on or above the wedge
$$F'(\pi)\ \ge\ F_0+\max\{\sigma(\ell_0-\ell(\pi)),\ \mu\}.$$
Then $m_N(c)\ge\mu(1-c/\sigma)\ge0$ for every $c\in[0,\sigma]$.

*Proof.* Put $x:=\ell_0-\ell(\pi)$.
* If $x\le0$, then $J'_c-(c\ell_0+F_0)\ge\mu+c|x|\ge\mu$.
* If $x>0$, it is at least $\max\{\sigma x,\mu\}-cx$.
  * When $\sigma x\ge\mu$ this is at least $(\sigma-c)x\ge(\sigma-c)\mu/\sigma$.
  * Otherwise it is at least $\mu-cx>\mu-c\mu/\sigma$. ∎

Conversely, $m_N\ge0$ on $[0,\sigma]$ forces $F'\ge F_0$ (take $c=0$) and $F'\ge F_0+\sigma(\ell_0-\ell)$ (take $c=\sigma$). So σ is the **left steepness** of the reference relative to N, and $\{c:m_N(c)>0\}$ is an interval, by (iii).

**Remark 1.3 (relation to the kink sub-track) [proved].** Kink Def 3.1, Thm 3.2 and Cor 3.3 are special cases of Lemma 1.1, up to windows.
* *Their left kink* (σ, $w_-$) at an attained point $(\alpha_-,L_-)$ is the case $N=\{\pi:\ell(\pi)<\alpha_--w_-\}$, $\ell_0=\alpha_-$. Their conclusions "length ≥ $\alpha_--w_-$" and "fit ≤ $L_-+\lambda(\alpha_--\ell)$" are "π ∈ M" and the third inequality of (ii).
* *Their Cor 3.3* (sufficiency as a right kink) is (R) with τ = 1, $g=b_0+\kappa$ and $M=\mathcal P$. Their Thm 5.4(ii) (Ville) is (R) with τ = 1 and $g=\ell_0+\log(1/\varepsilon)$.
* *Their right kink* has a horizontal window $w_+$ and an attained anchor. The window variant of (R) reads: every π ∈ M with $\ell(\pi)>\ell_0+w_+$ satisfies the inequality. It gives $\ell(\pi)\le\ell_0+\max\{w_+,(g+\epsilon)/(c-\tau)\}$, by the same one-line proof.
* *What the teacher needs and their form lacks.* The teacher's theorem needs two things:
  * a property-defined N, because the conclusion is "knows the parity", not "is long";
  * an unattained anchor with an offset g, because the line (D2) passes $\Lambda_2/2^m$ below the good model.

  I recommend that the paper state one kink lemma in the form of Lemma 1.1, with the window variant as a remark. Then `thm:split:private`(i), `prop:algstat:product`, kink Cor 3.3 and `thm:teacher:main`(i)–(ii)(c) are all corollaries of it.

---

## 2. Both theorems are instances

### 2.1 The teacher's theorem: τ = 2^{-m}

**Proposition 2.1 (`thm:teacher:main` as an instance of Lemma 1.1) [proved; computed: t1(B)].**

*The data.* Take `def:teacher:instance` with $B\in[\log(1/p),\infty]$, the population reading ($F=R$, $F'=R_B$), the reference point $(\ell_0,F_0):=(d+\kappa_g,\ H(p))$, bounded by $\pi_g$, $N:=\{\pi:\lev(\pi)\ge2\}$ (∞ included) and $M:=\{\pi:\lev(\pi)=1\}$.

* **(a) The left condition.**
  * $m_N(c)\ge\Phi_2(c)-J_g(c)$ for every $c>0$, so $m_N\ge0$ on $(0,c_{\rm hi}]$.
  * Geometrically, every program of level ≥ 2 lies above the wedge of Remark 1.2 with apex $(d+\kappa_g,H(p))$, steepness $\sigma=c_{\rm hi}$ and margin $\mu=G_1-H(p)$.
  * As a length kink: every program shorter than $d-4-\Lambda_1$ is in N, by (D1) with $s(1)=4$. So the reference has a left kink of steepness $c_{\rm hi}$ and window $w_-=4+\Lambda_1+\kappa_g$ in kink Def 3.1, read per sample.
* **(b) The right condition.** (R) holds with
  $$\tau=2^{-m},\qquad \ell_M=d-4-\Lambda_1,\qquad g=\frac{\Lambda_2}{2^m},\qquad \Lambda_2=2^mH(p)-B_S+4+\Lambda_1+\kappa_g .$$
  So the anchor is $(\ell_M,B_S/2^m)$.
* **(c) The conclusions.** For $2^{-m}<c\le c_{\rm hi}$, Lemma 1.1(i) gives
  $$\Phi^B(c)\ge\min\{\Phi_1(c),\Phi_2(c)\},\qquad\Phi_1(c)=c\ell_0+F_0-\Delta(c),\qquad \Delta(c)=c(4+\Lambda_1+\kappa_g)+H(p)-\frac{B_S}{2^m}.$$
  For $J_g(c)+\epsilon<\Phi_2(c)$, Lemma 1.1(ii) gives $\lev(\pi)=1$ and
  $$\ell(\pi)\le d+\kappa_g+\frac{\Lambda_2+\epsilon2^m}{c2^m-1}=d+\Delta_\ell,\qquad R_B(\pi)\ge H(p)-\frac{c\Lambda_2+\epsilon}{c2^m-1}.$$
  These are `thm:teacher:main`(i), (ii)(b) and (ii)(c), with the paper's constants.
* **(d) The envelope.** `prop:limits:envelope`(i) is the third inequality of Lemma 1.1(ii), with the envelope's point $(d+k_1+\kappa_e,R_e)$ as reference: $R\le R_e+\epsilon+c(k_1+\kappa_e+4+\Lambda_1)=R_e+\zeta$.

*Proof.*
* *(a).* By `thm:teacher:main`(o), every program of level ≥ 2 has $J^B_c\ge\Phi_2(c)$. Also $c\ell_0+F_0=J_g(c)$. So $m_N\ge\Phi_2-J_g$. By the definition of $c_{\rm hi}$, $J_g\le\Phi_2$ on $(0,c_{\rm hi}]$.
  * *The wedge.* At $c=c_{\rm hi}$: $c_{\rm hi}\ell+R_B\ge\Phi_2(c_{\rm hi})\ge J_g(c_{\rm hi})=c_{\rm hi}\ell_0+H(p)$. This is the slanted side. The flat side is $R_B\ge G_{\lev-1}\ge G_1$, by `lem:teacher:floor` and the monotonicity of $G$.
* *(b).* (D1) with $s(1)=4$ gives $\ell\ge\ell_M$. (D2) gives $\ell+2^mR_B\ge d+B_S-4-\Lambda_1=\ell_M+B_S$, that is $R_B\ge B_S/2^m-2^{-m}(\ell-\ell_M)$. At $\ell=\ell_0$ the line has height $B_S/2^m-2^{-m}(\kappa_g+4+\Lambda_1)=H(p)-\Lambda_2/2^m$.
* *(c), Δ.* $g+(c-\tau)(\ell_0-\ell_M)=\Lambda_2/2^m+(c-2^{-m})(4+\Lambda_1+\kappa_g)=c(4+\Lambda_1+\kappa_g)+H(p)-B_S/2^m$.
* *(c), Φ₁.* $c\ell_0+F_0-\Delta(c)=c(d-4-\Lambda_1)+B_S/2^m=\Phi_1(c)$.
* *(c), length.* $\ell_0+(g+\epsilon)/(c-\tau)=d+\kappa_g+(\Lambda_2+\epsilon2^m)/(c2^m-1)$. The paper's $\Delta_\ell=\kappa_g+\epsilon/c+(\Lambda_2+\epsilon/c)/(c2^m-1)$ is the same number, because
  $$\frac\epsilon c+\frac{\epsilon/c}{c2^m-1}=\frac{\epsilon}{c}\cdot\frac{c2^m}{c2^m-1}=\frac{\epsilon2^m}{c2^m-1}.$$
* *(c), risk.* $(cg+\tau\epsilon)/(c-\tau)=(c\Lambda_2+\epsilon)/(c2^m-1)$.
* *(d).* Use the margin $\Phi_2-J_e$, and use $\ell\ge\ell_M$ on level-1 programs; (R) is not needed for the third inequality. ∎

[computed: t1(B).]
* *The identities.* Over 17,411 random parameter sets ($4\le m\le40$, $m\le d\le400$, κ ∈ {0, 5, 10, 30, 60}, $\delta_S\in\{0,1,10,20,100\}$, finite and infinite $B$, $c/2^{-m}\in(1,10^4]$, ε ≥ 0), the paper's and the lemma's formulas agree:

  | quantity | largest relative difference |
  |---|---|
  | $\Phi_1$ | $2.4\cdot10^{-14}$ |
  | Δ | $1.0\cdot10^{-15}$ |
  | $\Delta_\ell$ | $2.8\cdot10^{-15}$ |
  | the risk bound | $1.2\cdot10^{-15}$ |
  | g | $9.4\cdot10^{-16}$ |

* *The wedge.* Every level-t region $\{\ell\ge(d-s(t)-\Lambda_1)^+,\ R_B\ge G_{t-1}\}$, for $t=2,\dots,400$ and ∞, lies above it in all 10 configurations checked, with the exact $s(t)$ and with $4t$.
* *The exact steepness* of these regions exceeds $c_{\rm hi}$ slightly:

  | configuration | $c_{\rm hi}$ | exact steepness |
  |---|---|---|
  | example's sizes, κ = 0 | $8.062\cdot10^{-3}$ | $8.198\cdot10^{-3}$ |
  | example's sizes, κ = 30 | $3.659\cdot10^{-3}$ | $3.687\cdot10^{-3}$ |
  | $d=m=20$ | $1.139\cdot10^{-2}$ | $1.139\cdot10^{-2}$ |

  The difference comes from the two-endpoint reduction in the proof of (o).

**What is not geometry.** The other conclusions of `thm:teacher:main` say what the position on the hull means for this instance.
* (ii)(a) is the risk floor applied to the fit bound.
* (ii)(d) converts the length bound into information about S: list decoding and symmetry of information.
* (ii)(e) converts (d) into a bound on the probability of the erroneous labels: Hoeffding's coding argument.
* (iii) and (iv) concern $c<\tau$, below the right flatness, where the memoriser's side of the hull is selected.

In the split's language:
* (c) says the selected model carries at most $\Delta_\ell$ bits beyond the model;
* (d) says those bits contain at most $\Delta_\ell+\Lambda_3$ bits of the errors;
* so the errors are in the noise.

**Table 2.2 (the hypotheses of `thm:teacher:main` and the kink conditions they serve) [proved: by inspection of the proofs].** The numbering is that of `rem:teacher:hypotheses`.

| hypothesis | enters through | kink condition |
|---|---|---|
| (1) list-decodable model class (parities) | `lem:teacher:list` → (D1), (D2) | *Left:* by (D1), a program shorter than $d-s(t)-\Lambda_1$ cannot know the model at level $t$. *Right:* a program that knows it pays only $4+2\log d$ bits for $a$, which puts the anchor of (D2) at $\ell_M=d-4-\Lambda_1$. |
| $K(a)\ge d$ (part of the instance) | (D1), (D2) | *Left:* the kink sits at $\alpha\approx d$. *Right:* the anchor. |
| (4) $p<0.056$, i.e. $G_1>H(p)$ | `lem:teacher:floor` | *Left:* margin $\mu=G_1-H(p)>0$ and $c_{\rm hi}>0$. §5 replaces this by $p<0.1233$. |
| (3) uniform inputs | all three lemmas | *Both:* every slope is a rate under μ (Parseval; $\Pr[E]=p$; cells of mass $2^{-m}$). See `prop:limits:inputlaw`. |
| (2) product form $E=S\times\{0,1\}^{d-m}$ | `lem:teacher:coding` → (D2) | *Right:* τ = $2^{-m}$ per sample, $2^{d-m}$ total bits on the full table, instead of $2^{-d}$. This is the reuse factor (§3). |
| (5) small $\delta_S$ | (D2), through $B_S=L_S-\delta_S$ | *Right:* the offset $g=\Lambda_2/2^m$ contains $\delta_S/2^m$. It plays the role of δ* in the split (Remark 2.5). |
| truncation $B$ | $F'=R_B\le R$ | The second fit of Lemma 1.1. |

### 2.2 The private-randomness split: τ = 1 in total bits

**Proposition 2.3 (`thm:split:private`(i) and iid Thm 4.1(i) as instances) [proved; computed: t1(C)].**
* *The data.* Take the data reading with $F=-\log\nu_\pi(D_n)$. The reference point is $(k,\,-\log\nu(D_n))$, attained by $\pi_\nu$. Put $N:=\emptyset$ and $M:=\mathcal C$.
* *The right condition.* (R) holds with τ = 1, $\ell_M=0$ and $g=k+\delta^*$. Lemma 1.1(ii), with $c=\lambda>1$ and ε = 0, gives
  $$\ell(\hat\pi)\le k+\frac{k+\delta^*}{\lambda-1},\qquad -\log\nu_{\hat\pi}(D_n)\ge-\log\nu(D_n)-\frac{\lambda(k+\delta^*)}{\lambda-1}.$$
  These are `thm:split:private`(i). Lemma 1.1(i) gives $\Phi(\lambda)\ge-\log\nu(D_n)-\delta^*$.
* *The per-query version* is the same with per-query likelihoods and $\ell^*$ in place of $k$: iid Thm 4.1(i).
* *Identification needs the left condition.* This holds for `thm:split:private`(iv), iid Thm 4.1(iv) and kink Thm 5.4. There N is the set of non-equivalent programs up to the length bound, and $m_N$ grows linearly in $n$ (iid Lemma 8.1; kink Thm 5.4(i)).

*Proof.* `lem:split:ville` gives $-\log\nu_\pi(D_n)\ge-\log\nu(D_n)-\ell(\pi)-\delta^*=F_0-(k+\delta^*)-(\ell(\pi)-k)$ for every π and $n$. That is (R). The rest is Lemma 1.1. [t1(C): the two forms agree to $2.1\cdot10^{-13}$ over 20,000 random $(k,\delta^*,\lambda,F_0)$.] ∎

So the length bound of the split theorem uses only the right condition. The same holds for the teacher on the full table with $m=d$:

**Proposition 2.4 (for m = d the teacher's right condition is the sufficiency line) [proved; computed: t1(D)].** Take `def:teacher:instance` with $m=d$, $r\ge3$ (so $p<1/4$), $B=\infty$, and the full truth table $D$ in total bits. Then every program π, of any level, satisfies
$$NR(\pi)\ \ge\ NH(p)-b_0'-(\ell(\pi)-\ell_0),\qquad \ell_0=d+\kappa_g,\qquad b_0':=(NH(p)-L_E)+\delta_E+\kappa_g+2\log(d+1)+\kappa.$$
So (R) holds for all programs with τ = 1 and $g=b_0'\le\log(N+1)+\delta_E+\kappa_g+2\log(d+1)+\kappa$. In particular:
* (i) every λ-MAP, λ > 1, has $\ell\le d+\kappa_g+b_0'/(\lambda-1)$, whatever its level;
* (ii) `cor:teacher:fulltable`(i) is Lemma 1.1 in total bits with τ = 1 and $g=\Lambda_2$; the sufficiency line improves $g$ by $\Lambda_2-b_0'=4+4\log d-2\log(d+1)\approx4+2\log d$;
* (iii) both the split theorem and the idiosyncratic-error theorem have the window's lower end at λ = 1. At λ = 1 both reference points sit on a line of slope 1: `thm:split:lambda1` and `cor:teacher:fulltable`(ii).

*Proof.*
* `lem:setup:coding` gives $\ell(\pi)+NR(\pi)\ge K(y_D\mid\dom D)-\kappa$.
* The proof of `prop:algstat:parity`(i)–(ii) gives $K(y_D\mid\dom D)\ge d+L_E-\delta_E-2\log(d+1)-\kappa$. This uses minimum-distance decoding, valid for $p<1/4$.
* Rearrange around $\ell_0=d+\kappa_g$, and use $NH(p)-L_E\le\log(N+1)$.
* For (ii), the difference of the two offsets is computed from $\Lambda_1=4\log d+\kappa$ at $m=d$, $B=\infty$. ∎

The kink sub-track's $b_0$ (kink §4, before Prop 4.1) is the same offset. Its identification numbers at λ = 2 ($\ell\le d+45.5$ against the paper's $d+58.2$) come from using it in place of (D2). [t1(D): the forms of `cor:teacher:fulltable`(i) and of Lemma 1.1 with $g=\Lambda_2$ agree exactly over 5000 random instances.]

**Remark 2.5 (δ* and δ_S are the same kind of slack) [remark, from proved results].**

| | the split | the teacher |
|---|---|---|
| deficiency | Ville deficiency $\delta^*$ of the sampled noise relative to ν | randomness deficiency $\delta_S$ of the error rule relative to the model |
| what it measures | how much any program, or the whole mixture, can compress the noise beyond ν | how much any program can compress the rule beyond its log-count |
| where it enters | the offset of the right line | the offset of the right line |
| tail | $\Pr[\delta^*\ge j]\le2^{-j}$ (`lem:split:ville`) | $\Pr_S[\delta_S>j]<2^{-j}$ for a uniform rule (`def:teacher:instance`(b)) |

A compressible "noise" is a model component. `prop:limits:envelope` is the teacher's case of large $\delta_S$. Its split analogue is a sampler whose coins are not random relative to the class.

---

## 3. Why fixed λ suffices for i.i.d. noise and the errors need λ ∝ n

### 3.1 The right flatness is the reuse factor of the noise

In total bits, the right flatness at the model is the number of data points that one bit of the "noise" (or of the errors) explains. Call it the **reuse factor**.
* *Noise drawn fresh at each input* is used once. Ville's line has slope 1 for every $n$ (Prop 2.3).
* *Idiosyncratic errors on distinct inputs* are also used once. Their line is the sufficiency line of slope 1 (Prop 2.4).
* *A junta error rule* is reused at every input of its cell.

**Proposition 3.1 (full tables: the lower end of the window is $2^{d-m}$) [proved; computed: t1(D), t2(A)].** Take `def:teacher:instance` with any $1\le m\le d$, $B=\infty$, and the full truth table ($n=N$).
* (a) For every $\lambda\in(2^{d-m},Nc_{\rm hi})$, every λ-MAP satisfies `thm:teacher:main`(ii) with $c=\lambda/N$ and ε = 0. In total bits its length is at most
  $$d+\kappa_g+\frac{2^{d-m}\Lambda_2}{\lambda-2^{d-m}}.$$
* (b) For $\lambda<2^{d-m}\theta_m$, with $\theta_m:=2^mH(p)/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$, the memoriser beats every level-1 program with $R\ge H(p)$.
* (c) Hence, in total bits:
  * every level-1 program lies above the line of slope $-2^{d-m}$ that passes $2^{d-m}\Lambda_2$ below the good model's reference point (Prop 2.1(b), times N);
  * the memoriser's secant from the good model is at least $2^{d-m}\theta_m$.

  Here $2^{d-m}=N/2^m$ is the number of inputs per cell of the error rule, and $\theta_m=1-O((m+\log d+\kappa)/L_S)$. For $m=d$ the slope is 1, as for noise.

*Proof.*
* *(a) and (b).* A full-table λ-MAP minimises $\lambda\ell+NR=NJ_{\lambda/N}$. Apply `thm:teacher:main`(ii) and (iv) with $c=\lambda/N$. For (a), $J_g<\Phi_2$ holds strictly on $(0,c_{\rm hi})$, since $J_g-\Phi_2$ is piecewise affine with positive slopes. Also $c2^m-1=(\lambda-2^{d-m})/2^{d-m}$.
* *(c).* The line is Prop 2.1(b) multiplied by N. For the secant, $\ell(\pi_b)-\ell(\pi_g)\le\lceil L_S\rceil+\kappa_b+4+\Lambda_1$, because $\ell(\pi_g)\ge d-4-\Lambda_1$ by (D1). ∎

[computed: t1(D), B = ∞, δ_S = 0.]

| $d$ | $m$ | κ | lower end $2^{d-m}$ | sharp lower end $2^{d-m}\theta_m$ | upper end $Nc_{\rm hi}$ |
|---|---|---|---|---|---|
| 20 | 20 | 0 | 1 | 0.9955 | $1.195\cdot10^4$ (the paper's value) |
| 20 | 18 | 0 | 4 | 3.93 | $1.195\cdot10^4$ |
| 20 | 16 | 0 | 16 | 15.07 | $1.195\cdot10^4$ |
| 20 | 12 | 0 | 256 | 140 | $1.195\cdot10^4$ |
| 100 | 20 | 0 | $1.21\cdot10^{24}$ | $1.20\cdot10^{24}$ | $1.02\cdot10^{28}$ |

* At $d=20$, $m=12$ ($s_0=4$, $L_S=41$ bits) the factor $\theta_m=0.55$. There the $O(\log)$ overheads are large compared with $L_S$.

[computed: t2(A), explicit class.] An exactly enumerable prefix-coded product class, at $d=10$ and $p=1/16$, with each m tested twice:
* the good model's λ-interval is (0.995, 46.2), (3.75, 46.2) and (15.7, 46.2) for $m=10,8,6$, against $2^{d-m}=1,4,16$;
* for $m=4$ the rule is one cell, cheaper than the model's own rate code. The good model is not a vertex at all: the hull goes from the coin straight to the rule memoriser. This is rate blindness (§4).

**Proposition 3.2 (fixed λ ends at the least-risk vertex; λ = cn stops at the vertex of slope c) [proved].**
* *Setting.* Pairs $(x_i,y_i)$ are i.i.d. from $\mu\otimes P^*$, for any label channel $P^*$: a sampler's fresh noise, or $\delta_{y^*(x)}$ for a deterministic teacher. Likelihoods are per query, as in iid §1. The class is countable with Kraft weights. Put $R(\pi):=\Ex[-\log\nu_\pi(y\mid x)]\in[0,\infty]$.
* (a) Let $\lambda_n\ge1$ with $\lambda_n/n\to0$. Let $\pi_0,\pi_1$ be programs with $R(\pi_1)<R(\pi_0)$ and $R(\pi_1)<\infty$. Then almost surely $\pi_0$ is a $\lambda_n$-MAP for only finitely many $n$.
* (b) *Noise.* If $P^*=\nu$ is a sampler, then $R(\pi)-R(\nu)=\Ex_\mu\KL(\nu(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x))\ge0$, with equality iff $\nu_\pi=\nu$ μ-a.e. So ν's shortest programs are the least-length points of the least-risk level of the population hull, and (a) never excludes them.
* (c) *Errors.* If $P^*=\delta_{y^*}$ for the teacher, then $R(\pi_b)=0<H(p)=R(\pi_g)$. By (a), every schedule with $\lambda_n=o(n)$ eventually rejects the good model.
* (d) *λ = cn.* Let $\lambda_n=cn$, and let the class be finite with a unique minimiser $\pi_c$ of $J_c=c\ell+R$. Then almost surely $\pi_c$ is the unique $\lambda_n$-MAP for all large $n$.

*Proof.*
* *(a).* The per-query losses are nonnegative. By the strong law [known: e.g. Durrett, for nonnegative variables with possibly infinite mean], $\hat R_n(\pi_1)\to R(\pi_1)$ and $\hat R_n(\pi_0)\to R(\pi_0)\in(R(\pi_1),\infty]$ almost surely. Then
  $$\tfrac1n[J_{\lambda_n}(\pi_0)-J_{\lambda_n}(\pi_1)]=\tfrac{\lambda_n}n(\ell(\pi_0)-\ell(\pi_1))+\hat R_n(\pi_0)-\hat R_n(\pi_1)\to R(\pi_0)-R(\pi_1)>0 .$$
  So eventually $J(\pi_0)>J(\pi_1)\ge\min J$.
* *(b).* Gibbs' inequality for a sub-probability $\nu_\pi(\cdot\mid x)$, with the equality case as in iid Lemma 2.1(b).
* *(c).* Immediate.
* *(d).* $\frac1nJ_{cn}(\pi)=c\ell(\pi)+\hat R_n(\pi)\to J_c(\pi)$ almost surely, for each of finitely many programs (to $+\infty$ when $R=\infty$). The unique minimiser wins by a positive margin. ∎

**Reading.** Both threads select a vertex of the population hull of $(\ell,R)$.
* *The split's target.* A sampler with fresh noise is the **last** vertex: noise is unpredictable, and no program has lower risk.
  * Every schedule with $1\le\lambda_n=o(n)$ ends there. iid Thm 3.1 identifies the limit as $E^*$, λ = 1 included.
  * A fixed λ > 1 is needed only for the uniform, explicit guarantees: iid Thm 4.1, kink Cor 5.5, Lemma 1.1 with τ = 1.
* *The teacher's target.* The good model is an **interior** vertex: the errors are predictable, and the memoriser and the envelopes have lower risk.
  * Every schedule with $\lambda_n=o(n)$ moves past it. Prop 3.2(c) shows this, and `prop:limits:plain`(b) gives the quantitative form: the λ-MAP's risk tends to 0 and $e\to1$.
  * Only $\lambda=cn$, which holds the slope fixed per sample, can stop at an interior vertex, and only for $c$ in that vertex's interval. Here that interval contains $(2^{-m},c_{\rm hi}]$.
  * With $\lambda=cn$ the noise case also works if $c$ is below the truth's left steepness (iid Prop 3.4).

This is the content of `rem:limits:schedule` in hull form. It also explains the "deliberate inconsistency": λ = cn gives up the segments of the hull whose rate is below $c$. In the teacher's example that is the errors, with risk $H(p)$ per sample, but `prop:limits:separable` shows it can just as well be a valid component.

### 3.2 Sampled data: the errors look like noise until they repeat

**Proposition 3.3 (the right flatness on a sample is the multiplicity of the error cells) [lower bounds proved; upper bound proof sketch; computed: t2(B)].** Take $n$ inputs drawn uniformly without replacement, labelled by $y^*$, and the data reading in total bits. Let $Z$ be the set of cells of $\{0,1\}^m$ hit by the sample, $n_z$ the number of sampled inputs in cell $z$, and $F_g:=-\log\nu_{\pi_g}(D_n)\approx nH(p)$.

* (a) **Lower bounds** [proved]. The good model is beaten at every λ below each of two secants:
  * the memoriser's secant $F_g/(\ell(\pi_b)-\ell(\pi_g))$, which is about $nH(p)/L_S\approx n2^{-m}\theta_m$;
  * the secant of the single covering fill-in of iid Lemma 5.2, built with the good model as decoder: $F_g/(F_g+O(\log n+\log d+\log F_g))\to1$.

  So the right flatness at the good model is at least about $\max\{1,n2^{-m}\theta_m\}$.
* (b) **Upper bound** [proof sketch].
  * *A sampled coding lemma* [proved]. For a program π, $z\in Z$ and $b\in\{0,1\}$, put
    $$q_z(b):=2^{-\frac1{n_z}\sum_{x\in\dom D_n,\ {\rm cell}(x)=z}-\log\nu_\pi(f_a(x)\oplus b\mid x)} .$$
    By the weighted AM–GM inequality, $q_z(0)+q_z(1)\le1$. So $Q(T):=\prod_{z\in Z}q_z(\ind_T(z))$ is an lsc semimeasure on subsets of $Z$, given $(\pi,a,\dom D_n)$. Since $y^*=f_a\oplus\ind_S({\rm cell}(x))$, (F2) gives
    $$K(S\cap Z\mid\pi,a,\dom D_n)\ \le\ \sum_{z\in Z}\frac{F_z(\pi)}{n_z}+\kappa,$$
    where $F_z$ is π's fit on the sampled inputs of cell $z$.
  * *The chain rule.* Combined with (F3), (F4) and list decoding at level 1, a level-1 program of length $d+x$ satisfies $\sum_zF_z/n_z\ge C-x-O(\log d)$, where $C:=K(S\cap Z\mid a,\dom D_n)$.
  * *Equal multiplicities* [proved, given the display]. If every sampled cell has the same multiplicity $\bar n$, then $F(\pi)=\bar n\sum_zF_z/n_z\ge\bar n\,(C-x-O(\log d))$. This is (R) with $\tau=\bar n$ in total bits, around the good model, with offset $\bar n\beta$. Here $\beta:=\sum_zF_z(\pi_g)/n_z-C$ is the good model's sufficiency gap at the level of cells.
    * On the full table $\bar n=2^{d-m}$ (Prop 3.1).
    * While every sampled cell is hit once ($n\ll2^{m/2}$), $\bar n=1$, as for noise.
  * *Unequal multiplicities* [not proved]. In general the same display gives a valid line of slope $\min_zn_z$, but with a larger offset. Near the good model the effective slope can approach $\max_zn_z$: a program can memorise the most repeated error cells first. For $n\gg2^m\log2^m$ all $n_z$ concentrate at $n2^{-m}$, so the two agree.
  * *The unproved step in the regime $\bar n=1$.* It is that β is small, that is, $C$ is close to the good model's code length for $S\cap Z$, about $\log\binom{|Z|}{|S\cap Z|}$. This needs $S\cap Z$ to be incompressible given the independent random sample. Granted that, the good model is near-sufficient and its right flatness is 1, as for noise.

[computed: t2(B); $d=14$, $m=8$, $p=1/16$ (16 error cells of 256); explicit class; 20 samples per $n$; medians.]

| $n$ | interval $(\tau_n,\sigma_n)$ | fill-in secant | error-cell multiplicity (mean, max) | $n2^{-m}$ | 2-MAP (mode) | 2-MAP = good model |
|---|---|---|---|---|---|---|
| 64 | (0.80, 2.44) | 0.31 | 1.00, 1 | 0.25 | F1 | 70% |
| 128 | (0.94, 4.67) | 0.47 | 1.24, 2 | 0.5 | F1 | 100% |
| 256 | (1.39, 8.99) | 0.63 | 1.68, 3 | 1 | F1 | 100% |
| 512 | (2.03, 18.2) | 0.76 | 2.21, 4 | 2 | F5 (rule) | 40% |
| 1024 | (3.95, 35.4) | 0.86 | 4.28, 8 | 4 | F5 | 0% |
| 4096 | (15.1, 144) | 0.95 | 16.1, 22 | 16 | F5 | 0% |
| 16384 | (60.1, 575) | 0.99 | 64, 64 | 64 | F5 | 0% |

* The lower end tracks the error cells' multiplicity. For $n\ge2048$, $\tau_n=0.94\,n2^{-m}$, the factor being $2^mH(p)/(\ell(\pi_b)-\ell(\pi_g))$; at $n=1024$ it is $0.99\,n2^{-m}$. The upper end grows like $n$.
* The fixed λ = 2 keeps the good model in every sample up to $n=2^m=256$. It keeps it in 40% of samples at $n=512$, and loses it to the rule memoriser from $n=1024$ on.
* $\lambda=4n2^{-m}$ keeps it at every $n\ge64$ (column "MAP@4n/2^m" of the output).
* At small $n$ the explicit class has $\tau_n<1$, because naming a cell costs about $m$ bits and saves $\log(1/p)=4$. The canonical class has the covering fill-in, whose secant tends to 1, but with $O(\log)$ overheads that are still large at these sizes (0.31 at $n=64$).
* At $n=16384=N$ the sample is the full table, and $\tau_n=60.1=64\,\theta$, as in Prop 3.1.

**Remark 3.4 (the two kinds of noise, side by side) [remark, from Props 2.3, 2.4, 3.1–3.3].**

| | fresh noise (sampler) | idiosyncratic errors, $m=d$ | systematic errors, junta $m<d$ |
|---|---|---|---|
| right flatness, total bits | 1 (Ville), every $n$ | 1 (sufficiency line), full table | $2^{d-m}$ on the full table; about $\max(1,\ n2^{-m})$ on $n$ samples |
| right flatness, per sample | $1/n\to0$; population: 0 (least-risk vertex) | $1/N$ | $2^{-m}$ |
| left steepness, total bits | $\ge2\log e\cdot n\gamma_-/\ell_0$ (kink Thm 5.4) | $\ge N(G_1-H(p))/(d+\kappa_g)$ (kink Prop 4.1) | $\ge n\,c_{\rm hi}$ (population; Prop 2.1(a)) |
| schedules that select the model | every $1<\lambda_n$ with $\lambda_n<$ the left steepness; asymptotically every $\lambda_n=o(n)$, λ = 1 included (iid Thm 3.1) | $\lambda\in(1,Nc_{\rm hi})$ | $\lambda=cn$, $c\in(2^{-m},c_{\rm hi}]$; no $\lambda_n=o(n)$ |
| offset of the right line | $k+\delta^*$ | $b_0'$ ($\log N+\delta_E+O(\log d)$) | $\Lambda_2/2^m$ ($(\log2^m+\delta_S+O(\log d))/2^m$) |

**Remark 3.5 (what λ > 1 buys in each thread) [remark].**
* *Noise.* The right condition has τ = 1, so Lemma 1.1 needs $c=\lambda>1$. This is why `thm:split:private` and the kink sub-track's results are stated for λ > 1. At λ = 1 the reference point is on the right line itself: `thm:split:lambda1`, `cor:teacher:fulltable`(ii) and kink Remark 5.9. Asymptotically λ = 1 still selects the model for i.i.d. noise (iid Thm 3.1), by the Kraft tail rather than by the lemma.
* *Systematic errors.* τ = $2^{-m}$ per sample, so Lemma 1.1 needs $c>2^{-m}$, that is $\lambda>n2^{-m}$. No fixed λ satisfies this for large $n$.

---

## 4. Structured errors make a second kink

The product structure function in population form is $\rho_{\rm pop}(\alpha):=\inf\{R(\pi):\ell(\pi)\le\alpha\}$.
* *An incompressible rule* gives one kink, at $\alpha\approx d$. Its left steepness is at least $c_{\rm hi}$. After it, ρ descends at slope about $2^{-m}$ until the memoriser at $\alpha\approx d+L_S$.
* *A rule with a cheap, dense part* $S_1$, $K(S_1\mid m)\le k_1$, adds a second drop at $\alpha\approx d+k_1$. The drop has height about $H(p)-R_e$, over $k_1+O(\log)$ bits. That is the envelope's kink.

**Proposition 4.1 (the envelope raises the lower end of the window) [proved].** In the setting of `prop:limits:envelope` ($B=\infty$):
* (a) *The envelope's secant.* Let $P=(\ell,R)$ be the point of any level-1 program with $R\ge H(p)$; the good model is one. Then the envelope either dominates $P$, or its secant from $P$ is at least
  $$c_{\rm env}=\frac{H(p)-R_e}{k_1+\kappa_e+4+\Lambda_1}.$$
  So the right flatness at every such point is at least $c_{\rm env}$. Against the reference value $J_g(c)$ itself the threshold is $s_e:=(H(p)-R_e)/(k_1+\kappa_e-\kappa_g)$, when $k_1+\kappa_e>\kappa_g$: for $c<s_e$, $J_c(\pi_e)<J_g(c)$.
* (b) *The all-hypothesis form.* `prop:limits:envelope`(i) is Lemma 1.1(ii)'s third inequality with the envelope's point as reference. For $c<c_{\rm env}$ and small ε, no program with $R\ge H(p)$ is near-optimal. So the window of `thm:teacher:main`, read for this rule, cannot extend below $c_{\rm env}$, where the paper's bounds for an incompressible rule would start at $2^{-m}$.
* (c) *Where the near-optimal programs sit.* Near the lower end, `prop:limits:envelope`(ii) puts them at the envelope's kink: they reproduce the cheap errors.

*Proof.*
* *(a).* The envelope has length at most $d+k_1+\kappa_e$, and $\ell\ge d-4-\Lambda_1$ by (D1). If the envelope is not longer than $P$, it dominates $P$, because $R_e<H(p)\le R$. Otherwise its secant from $P$ is $(R-R_e)/(\ell(\pi_e)-\ell)\ge(H(p)-R_e)/(k_1+\kappa_e+4+\Lambda_1)$. The second claim compares $J_c$ at the two upper-bound points.
* *(b).* Prop 2.1(d).
* *(c).* The cited proposition. ∎

**Proposition 4.2 (rate blindness is an empty kink interval) [proved].** Take a level-1 point $P=(\ell,R)$ with $R\ge H(p)$, so $\ell\ge d-4-\Lambda_1$.
* *The memoriser's secant from P* is at least $s_b:=H(p)/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$. This is a lower bound on the right flatness at P.
* *The coin's secant to P* is at most $s_c:=(1-H(p))/(d-4-\Lambda_1-\kappa)$. This is an upper bound on the left steepness at P.

`prop:limits:rateblind`'s condition (⋆) is $s_b\ge s_c$. Under it every such P has an empty λ-interval, because the error kink is at least as steep as the model kink.

*Proof.*
* If $\ell(\pi_b)\le\ell$, the memoriser dominates P. Otherwise $R/(\ell(\pi_b)-\ell)\ge s_b$, because $\ell(\pi_b)-\ell\le\lceil L_S\rceil+\kappa_b+4+\Lambda_1$.
* If $R\ge1$, the coin dominates P. Otherwise $(1-R)/(\ell-\ell_{\rm coin})\le s_c$.
* For $c<s_b$ the memoriser beats P; for $c\ge s_c$ the coin beats or ties it. When $s_b\ge s_c$ these two ranges cover all $c>0$.

This is the proof of `prop:limits:rateblind`(ii), read as a statement about secants. ∎

[computed: t3(A); full table, $d=12$, $m=8$, $p=1/16$ (16 error cells); $S=S_1\cup S_2$ with $S_1$ a cheap subcube and $S_2$ random cells outside the 16-cell zero subcube; the class adds envelopes F6 and envelope-plus-named-cells F7 to t2's class; total bits; reuse factor $2^{d-m}=16$.]

| $\lvert S_1\rvert$ | good model's λ-interval | envelope vertices (λ-intervals) | ρ at α = 24 / 30 / 40 / 80 |
|---|---|---|---|
| 0 | (15.0, 161.8) | none | 1382 / 1382 / 1295 / 975 |
| 2 | (17.1, 161.8) | none (the rule memoriser via F7 below 17.1) | 1382 / 1382 / 1251 / 822 |
| 4 | (42.7, 161.8) | (17.3, 42.7) | 1382 / 1126 / 1069 / 657 |
| 8 | (85.3, 161.8) | (53.7, 85.3), (17.7, 53.7) | 1382 / 870 / 816 / 0 |
| 16 | empty | the whole rule is one cheap subcube, a vertex for λ < 273 | 0 / 0 / 0 / 0 |

* The second drop of ρ at α = 30 (for $\lvert S_1\rvert=4,8$) is the envelope's kink.
* As the cheap part grows, its kink steepens. The good model's interval shrinks from below, from the reuse factor 16 up to 85, and disappears when the cheap part is the whole rule.
* At $\lvert S_1\rvert=16$ the envelope is even shorter than the good model: its two deterministic flags cost 2 bits, against 9 for the rate 1/16.

[computed: t3(B); a fixed rule of 4 random cells at $m=5$ ($p=1/8$), as the model length $d$ grows.]

| $d$ | 6 | 8 | 10 | 11 | 12 | 13–16 |
|---|---|---|---|---|---|---|
| good model's λ-interval | (1.78, 3.54) | (7.13, 11.0) | (28.5, 36.0) | (57.1, 66.0) | (114.2, 121.9) | empty |

* The ratio of the ends falls from 2.0 to 1.07, and the window closes at $d=13$. This is rate blindness in the explicit class: the model's rate falls like $1/d$, the rule's rate stays fixed.
* The three-hypothesis criterion of `prop:limits:rateblind`(i) flips at $d=12$, one step before the exact hull. At $d=12$ the exact class still has a short interval, because its vertices next to the good model are not the coin and the rule memoriser.

**Remark 4.3 (rate, not validity, in hull form) [remark, from cited results].**
* *Rate is all the selection sees.* Steeper selection keeps exactly the hull segments whose rate exceeds $c$ (kink §6; `prop:limits:separable`). An incompressible error rule has rate at most $2^{-m}$, the reuse factor per sample. A structured rule has the rate of its cheapest dense part, which can lie anywhere, up to and beyond the model's rate.
* *No geometric test separates the kinks.* Nothing in the geometry tells the model's kink from an error kink. `prop:limits:noident` (twin worlds) is the statement that the hull, and hence every rule that chooses λ from it, is the same in a world where the second kink is an error and one where it is a rare valid rule.
* *Guard erosion* (`prop:limits:guard`) is the same configuration with the roles changed. The rule and the guard are two components, and the unguarded rule is a vertex exactly when the rule's segment is steeper than the guard's.

---

## 5. A new consequence: the junta window for every p < 0.1233

**The obstacle.** `thm:teacher:main` needs $G_1>H(p)$, that is $p<0.056$. The kink sub-track (kink Prop 4.2, Cor 4.3) extends the full-table case $m=d$ to level 1 for $p<0.1233$ and level ≤ 2 for $p<1/4$. It does so by bounding every competitor's information budget through the sufficiency line (right flatness 1), which keeps the deviation term of `lem:teacher:sharpfloor` small.

For $m<d$ that bound is missing (kink §4, last paragraph; `rem:limits:method`). Near $c=2^{-m}$ a program that does not know the parity has its length bounded only by $J_c\le J_g$. That allows $I(\pi)\approx L_S$, and then the deviation term is of order $\sqrt{H(p)/p}$.

**The fix.** Charge the information in the objective, at the right flatness. A program that does not know the parity still pays for its information about the rule at one bit of length per bit. In the window, $c>2^{-m}$, a bit of length costs more risk than the sharp floor lets a bit of rule information gain.

**Lemma 5.1 (the information charge) [proved].** In `def:teacher:instance` (or its generalisation to any $s_0=p2^m$, with $\kappa_g:=2\log d+K(p)+\kappa$), let $d\ge2\log(d+1)+\kappa+1$. Every program π of level $t\in\{2,3,\dots\}\cup\{\infty\}$ satisfies
$$\ell(\pi)\ \ge\ d-\min\{s(t)+2\log d,\ d\}+I(\pi)-\kappa,\qquad I(\pi)\ \ge\ -2\log(2d)-\kappa,$$
with $s(\infty):=\infty$. In Prop 5.2 below, $G_{\infty-1}:=G_\infty$.

*Proof.*
* *The first inequality.* By (F3), $I(\pi)\le K(\pi\mid a,K(a))+\kappa$ (as in the proof of `lem:teacher:sharpfloor`). By (F4) and (F3), $K(\pi\mid a,K(a))\le K(\pi)+K(a\mid\pi)-K(a)+\kappa$. Insert:
  * $K(\pi)\le\ell(\pi)+\kappa$ (F1);
  * $K(a\mid\pi)\le\min\{s(t)+2\log d,\ K(a)\}+\kappa$ (`lem:teacher:list`, or trivially);
  * $K(a)\ge d$.

  This is the step of `thm:teacher:main`(ii)(d), read backwards.
* *The second inequality.* $K(S\mid a,\pi)\le K(S\mid a)+\kappa\le B_S+K(K(a))+\kappa$, by (F3). Then $K(K(a))\le2\log(K(a)+1)+\kappa$ (F5), and $K(a)\le d+2\log(d+1)+\kappa\le2d-1$. ∎

**Proposition 5.2 (a sharper bound for programs that do not know the parity) [proved; computed: t4(B)].**

*Definitions.* For $t\ge2$ put $\theta_{t-1}:=\frac12+2^{-t}$, and $\theta_\infty:=\frac12$. Put
$$\mathrm{Floor}_t(I):=\max\Big\{0,\ \sup_{g\ge1}\,-\log\Big(p+(1-2p)\theta_{t-1}+p\big(2\gamma_g(I)+2^{1-g}\big)+2^{-B}\Big)\Big\},$$
with $\gamma_g(I)$ as in `lem:teacher:sharpfloor`, evaluated with budget $I$. Put
$$\Psi_t(c):=\inf_{I\ge0}\big[cI+\mathrm{Floor}_t(I)\big].$$

*Claim.* Every program of level $t\ge2$ (or ∞) satisfies, for every $c>0$,
$$J^B_c(\pi)\ \ge\ LB_t(c):=\max\Big\{c\,(d-s(t)-\Lambda_1)^++G_{t-1},\ \ c\,\big(d-\min\{s(t)+2\log d,d\}-2\log(2d)-\kappa\big)+\Psi_t(c)\Big\}.$$
Consequently `thm:teacher:main`(i) and (ii), with all their conclusions (a)–(e), hold with $\Phi_2$ replaced by
$$\Phi_2^\sharp(c):=\inf_{t\ge2}LB_t(c)\ \ge\ \Phi_2(c).$$

*Proof.*
* *The first term* is the paper's bound in (o): (D1) and `lem:teacher:floor`.
* *The second term.*
  * By Lemma 5.1, $c\ell(\pi)\ge c(d-\min\{\cdot\}-\kappa)+cI^+-c(2\log(2d)+\kappa)$, where $I=I(\pi)$.
  * By `lem:teacher:sharpfloor` with $u\le\theta_{t-1}$, $R_B(\pi)\ge\mathrm{Floor}_t(I)$.
  * $\gamma_g$ is nondecreasing in the budget, so $\mathrm{Floor}_t(I)\ge\mathrm{Floor}_t(I^+)$.
  * Add the two bounds and take the infimum over $I^+\ge0$.
* *The consequence.* The proofs of (i) and (ii) use (o) only through "every program of level ≥ 2 has $J^B_c\ge\Phi_2(c)$". In Lemma 1.1 this is $m_N(c)\ge\Phi_2^\sharp(c)-J_g(c)$. ∎

The bound is valid at every $c$. It is useful when $c\ge2^{-m}$: then $cI\ge2^{-m}I=p\,(I/s_0)$, a linear charge per error cell's worth of information. The deviation term grows only like $\sqrt{I/s_0}$.

**Proposition 5.3 (asymptotically, a window for every p < 0.12331) [proved, given the computed constants $p^*$ and $a^*(p)$: t4(A)].**

*Definitions.*
$$\psi_2(p,a):=\inf_{x\ge0}\Big[apx-\log\big(\tfrac34-\tfrac p2+2p\sqrt{x\ln2/2}\big)\Big],\qquad a^*(p):=\inf\{a\ge1:\psi_2(p,a)>H(p)\}.$$

*Claim.* Fix a dyadic $p\in(0,1/4)$, κ, $B=\infty$, and $a>a^*(p)$, $A\ge a$. Let $m\to\infty$ with $d\ge m$, $d2^{-m}\to0$ and $\delta_S=o(2^m)$. Then for all large $m$ there is an $\epsilon_m>0$, bounded away from 0, such that
$$J_g(c)+\epsilon_m<\Phi_2^\sharp(c)\qquad\text{for every }c\in[a2^{-m},A2^{-m}] .$$
So the identification of `thm:teacher:main`(ii) holds on that range of $c$.

*Facts about the constants* [computed: t4(A)].
* $a^*(p)<\infty$ iff $1-\log(3/2-p)>H(p)$, that is iff $p<0.12331$.
* $a^*(p)=1$ iff $p<p^*=0.07787$.
* Tabulated values: $a^*=1.01$ at 5/64, 2.13 at 3/32, 3.03 at 0.1, 6.0 at 7/64, 15.6 at 15/128 and 30 at 0.12.

*Proof.*
* *The charge per sample.* Write $I=xs_0$. Then $cI=apx$ for $c=a2^{-m}$, because $s_0=p2^m$.
* *The deviation term converges.*
  * Let $r_g:=\delta_S+1+2\log m+2\log s_0+g+2\log g+\kappa$. In `lem:teacher:sharpfloor`, $j$ is the least integer with $j-2\log(j+1)>I+r_g$. So $I\le j\le I+r_g+O(\log(I+r_g))$.
  * Choose $g=g_m\to\infty$ with $g_m=o(s_0)$. Then $r_g=o(s_0)$, using $\delta_S=o(2^m)$ and $s_0=p2^m$.
  * Hence $\gamma_g(xs_0)^2=x\ln2/2+o(1)$, uniformly for $x$ in compact sets, and $p2^{1-g_m}\to0$.
* *The infimum converges.* By uniform continuity of $-\log$ on $[\frac34-\frac p2,\infty)$ and of $\sqrt\cdot$, $\mathrm{Floor}_2(xs_0)\ge f(x)-o(1)$ uniformly on $[0,X]$, where $f(x):=-\log(\frac34-\frac p2+2p\sqrt{x\ln2/2})$. For $x>X$ with $apX>\psi_2(p,a)+1$, the bound $cI+\mathrm{Floor}\ge apX$ suffices, since Floor ≥ 0. So $\liminf_m\Psi_2(a2^{-m})\ge\psi_2(p,a)$.
* *All levels at once.* $\Psi_t\ge\Psi_2$ for every $t\ge2$, because $\theta_{t-1}\le\theta_1$. The coefficient of $c$ in the second term of $LB_t$ is at least $-2\log(2d)-\kappa$. So, uniformly in $t$,
  $$J_g(c)-LB_t(c)\le c\,(d+\kappa_g+2\log(2d)+\kappa)+H(p)-\Psi_2(c).$$
* *Conclusion.* On $[a2^{-m},A2^{-m}]$, the first term is at most $A\,d\,2^{-m}(1+o(1))\to0$, and $\Psi_2(c)\ge\Psi_2(a2^{-m})$, since Ψ is nondecreasing in $c$. Pick $a'\in(a^*,a)$; then $\psi_2(p,a)\ge\psi_2(p,a')>H(p)$, because $\psi_2$ is nondecreasing in $a$. Take $\epsilon_m:=\frac12(\psi_2(p,a)-H(p))$. ∎

[computed: t4(A).]
* *The constants.* $G_1=H(p)$ at $p=0.05596$ (the paper's condition), $\psi_2(p,1)=H(p)$ at $p^*=0.07787$, and $1-\log(3/2-p)=H(p)$ at $0.12331$.
* *The minimisation.* The function minimised in $\psi_2$ is convex in $y=\sqrt x$, as checked on a grid. So golden-section search finds the infimum.
* *Convergence* [t4(C)]. The finite-size level-2 bound $\Psi_2(a2^{-m})$ converges from below to $\psi_2(p,a)$. For example, at $p=1/16$, $a=1$ it is 0.3826, 0.3954, 0.3965, 0.3966 and 0.3966 at $m=12,16,20,28,40$, against $\psi_2=0.3980$.

[computed: t4(B); $d=100$, $m=20$, $B=\infty$.] The windows are certified cell by cell on a geometric grid of 400 cells in $c$:
* on each cell $\Phi_2^\sharp$ is bounded below using the monotonicity in $c$;
* the infimum over $I$ is bounded below on an interval grid, using that Floor is nonincreasing in $I$;
* every occurrence of κ in Lemma 5.1 is counted (4κ in all).

The identification column is `thm:teacher:main`(ii) at one $c$ inside the window, with ε = 0 and $g$ optimised.

| $p$ | $G_1-H(p)$ | paper's window | certified window, κ = 0 | κ = 30 | at $c$ (κ = 0, $\delta_S=0$): $u\ge$, $\ell\le$, $I\le$, $e\le$ |
|---|---|---|---|---|---|
| $2^{-10}$ | +0.402 | $(9.5\cdot10^{-7},8.06\cdot10^{-3}]$ | $(2^{-20},7.88\cdot10^{-3}]$ | $(2^{-20},3.59\cdot10^{-3}]$ | $1.2\cdot10^{-4}$: 0.981, $d+20.3$, 37.6 of 11,710, 0.201 |
| 1/16 | −0.038 | none | $(2^{-20},2.39\cdot10^{-3}]$ | $(2^{-20},6.5\cdot10^{-4}]$ | $6.7\cdot10^{-5}$: 0.75, $d+18.0$, 35.3 of 353,665, 0.274 |
| 5/64 | −0.124 | none | $[1.01\cdot10^{-6},1.46\cdot10^{-3}]$ | $[1.01\cdot10^{-6},4.2\cdot10^{-4}]$ | $5.3\cdot10^{-5}$: 0.75, $d+25.2$, 42.5 of 414,742, 0.273 |
| 3/32 | −0.204 | none | $[2.10\cdot10^{-6},8.7\cdot10^{-4}]$ | $[2.10\cdot10^{-6},2.4\cdot10^{-4}]$ | $4.3\cdot10^{-5}$: 0.75, $d+23.8$, 41.1 of 470,659, 0.271 |
| 7/64 | −0.279 | none | $[6.2\cdot10^{-6},3.0\cdot10^{-4}]$ | $[6.4\cdot10^{-6},8.4\cdot10^{-5}]$ | $4.3\cdot10^{-5}$: 0.75, $d+26.3$, 43.6 of 522,210, 0.269 |
| 15/128 | −0.316 | none | $[2.2\cdot10^{-5},5.9\cdot10^{-5}]$ | none | $3.6\cdot10^{-5}$: 0.75, $d+29.0$, 46.3 of 546,531, 0.269 |
| 1/8 | −0.351 | none | none | none | — |

* *The lower ends.* In units of $2^{-20}$ they are 1, 1, 1.06, 2.2, 6.5 and 23 down the table. A window that starts at $2^{-20}$ is open there: the grid certifies the margin from $c=2^{-m}$ on, but (ii) needs $c2^m>1$. The asymptotic $a^*$ is 1, 1, 1.01, 2.13, 6.0 and 15.6.
* *Deficiency.* $\delta_S=20$ changes the windows by at most a few percent; see the output.
* *The error label.* Every near-optimal hypothesis gives the erroneous labels average probability $e\le0.27$–$0.28$, against 1 for the memoriser and $p$ for the good model, for every flip rate up to 15/128.

**Reading.**
* *One mechanism in both cases.* In both the full-table case (kink Prop 4.2) and the junta case (here), the right flatness controls the information budget of *every* competitor, including those that do not know the model. That is what makes the sharp floor usable.
  * With τ = 1, the sufficiency line caps everyone's length.
  * With τ = $2^{-m}$, the information charge makes rule information unprofitable at $c>a^*2^{-m}$, whether or not the program knows the parity.
* *Resulting ranges.* Level 1 is now obtained for $p<0.1233$ in both cases.
* *What remains open.*
  * Level 1 for $0.1233\le p<1/4$: with these floors it is impossible.
  * Level ≤ 2 for $p<1/4$ in the junta case. The level-3 analogue of $\psi$ has its $a\to\infty$ limit $-\log(\frac58-\frac p4)$, which exceeds $H(p)$ up to $p=1/4$ (0.830 > 0.811). Turning this into identification needs (D2) at level 2 [conjecture: routine].
  * Finite samples at realistic sizes. `cor:teacher:sampled` applies unchanged, with $\Phi_2^\sharp$ and its slowness.

This answers:
* the junta half of kink open question 3: the kink theorem for $m<d$ is Prop 2.1, and the window for $p\ge0.056$ is Props 5.2–5.3;
* `q:teacher:open`(b) for $p<0.1233$;
* `q:limits:open`(b): a window for $p<0.123$ with $c$ well above $2^{-m}$ exists, and for $p<0.078$ it reaches down to $2^{-m}$.

The answers are for the population objective. They do not contradict `rem:limits:method`, which concerns "the argument as it stands".

---

## 6. How to present the teacher result as the second thread

### 6.1 Proposed structure

The first thread establishes, in order:
1. the hull characterisation of λ-MAPs (kink Thm 2.1–2.2; `lem:setup:hull`);
2. Lemma 1.1 as the kink lemma;
3. the split theorems as its τ = 1 instances (Prop 2.3; iid; kink §5).

The second thread then reads as **"the split at a positive rate"**:

1. **From noise to errors** (half a page).
   * Errors are part of the teacher's channel, and they are predictable. So the good model is an interior vertex of the population hull, not the least-risk vertex (Prop 3.2).
   * Every schedule with $\lambda_n=o(n)$ ends at the least-risk vertex and learns the errors (`prop:limits:plain`, kept).
   * The proposal is $\lambda=cn$, which selects the vertex of slope $c$.
   * The three-hypothesis calculation is the picture of that hull, with rates 100 and 10, or $8.99\cdot10^{-3}$ and $1.12\cdot10^{-6}$ (`rem:teacher:hanni`, shortened).
2. **The instance** (`def:teacher:instance`, unchanged, generalised to $s_0=p2^m$ if §5 is included).
3. **Two kink bounds** (one proposition, the content of (o) and (D1)–(D2)).
   * *Left:* every program that does not know the parity at level 1 lies above the wedge with apex $(d+\kappa_g,H(p))$, steepness $c_{\rm hi}$ and margin $G_1-H(p)$; with §5, above $\Phi_2^\sharp$.
   * *Right:* every program that knows it lies above the line of slope $-2^{-m}$ through $(d-4-\Lambda_1,B_S/2^m)$.
   * Table 2.2 replaces `rem:teacher:hypotheses`. List decoding, the risk floor, the coding lemma and the two-part bounds move to the appendix as the proof of these two bounds.
4. **The theorem.**
   * (i), (ii)(b) and (ii)(c) are one application of Lemma 1.1 with τ = $2^{-m}$, $g=\Lambda_2/2^m$.
   * (ii)(a), (d) and (e) are stated as "what the position means".
   * (iii) and (iv), the side $c<\tau$, are kept.
   * The table of numbers is kept.
5. **The lower end is the reuse factor** (Prop 3.1 and Remark 3.4).
   * The full-table corollary is stated for every $m$, with window $\lambda\in(2^{d-m},Nc_{\rm hi})$. Its case $m=d$ is the split's τ = 1 (Prop 2.4).
   * One paragraph on sampled data (Prop 3.3 and its table) explains why λ must grow with $n$ exactly when the errors repeat.
   * `cor:teacher:sampled` and `prop:teacher:concentration` stay in the appendix.
6. **Flip rates up to 0.1233** (§5, if adopted): Prop 5.2 in the main text and Prop 5.3 with the table. This removes hypothesis (4) as it now stands.
7. **When errors are structured: a second kink.** The limits section is reorganised around kinks:
   * envelopes (Prop 4.1);
   * rate blindness (Prop 4.2);
   * rate, not validity (`prop:limits:separable`, guard erosion, input law, non-identifiability), as one remark on what a hull cannot see;
   * the t3 table as the illustration.

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
5. **`rem:limits:schedule` and the paragraph "The window and its price" of `discussion.tex`** become Prop 3.2 with its reading, and Remark 3.4's table. The literature sentence on $\lambda$-weighted MDL is kept.
6. **`prop:limits:envelope`(i) and its proof paragraph** become one line from Lemma 1.1 (Prop 2.1(d)). Part (ii) keeps its proof.
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

## 7. Alignment with the other sub-tracks

* **iid (T1).**
  * *Agreements.*
    * Thm 3.1: every $1\le\lambda_n=o(n)$ recovers $E^*$, λ = 1 included. This is the noise half of Prop 3.2: the target is the least-risk vertex.
    * Prop 3.4: λ = cn fails above the truth's left steepness. This is Prop 3.2(d).
    * Thm 4.1(i)–(iii) are the τ = 1 instance of Lemma 1.1 (Prop 2.3).
    * Lemma 8.1 supplies the linear left margin.
  * *Their Prop 7.3(iii)*, misspecified noise, is consistent with §3. With no noise model in the class the noise must be memorised or replaced by the coin, and the threshold $\lambda H(p)=1$ compares those two. It is not a reuse factor.
  * *A refinement of my brief.* The brief says "fixed λ suffices for i.i.d. noise". Following iid, the precise statement is: for i.i.d. noise every $\lambda_n=o(n)$ suffices asymptotically, and fixed λ > 1 gives the explicit and uniform bounds.
* **kink (T2).**
  * *Common ground.* Lemma 1.1 contains kink Thm 3.2(a), (b) (up to windows) and Cor 3.3 (Remark 1.3).
  * *Consistent results.*
    * Their full-table offset $b_0$ is Prop 2.4's $b_0'$.
    * Their two-kink example k2(F) and my t3 show the same phenomenon.
    * Their Prop 4.4 (no set kink) is the shared-randomness counterpart of §4: a short near-sufficient set model plays the role of a universal member and flattens the left kink. Structured errors instead create an extra steep kink on the right.
  * *What this sub-track adds to theirs.*
    * Their open question 3 asks for a kink theorem for junta errors, with right flatness about $n2^{-m}$. In population form it is Prop 2.1(b), and on samples Prop 3.3.
    * Its second half, a window for $p\ge0.056$, is Props 5.2–5.3.
    * Their remark that "λ must lie between the two kinks" (kink §6) is Prop 4.1 and the t3 table.
* **The paper.**
  * *No claim of Paper 2 is changed.*
    * §5 strengthens `thm:teacher:main` by replacing $\Phi_2$ with $\Phi_2^\sharp\ge\Phi_2$.
    * It answers the questions listed in §5, which the paper leaves open.
    * Prop 3.1 generalises `cor:teacher:fulltable` to every $m$, a direct consequence of the theorem.
  * *Every number of the paper* that is re-derived here agrees with it.
    * $c_{\rm hi}=8.062\cdot10^{-3}$ and $3.659\cdot10^{-3}$.
    * The full-table window $(1,11945]$.
    * The identification row at $c\approx10^{-4}$: $u\ge0.981$, $\ell\le d+20.3$ and $e\le0.201$ at $c=1.2\cdot10^{-4}$, against the paper's 0.983, $d+20.4$ and 0.199 at $10^{-4}$; the differences come from the different $c$.

---

## 8. Claims and statuses

| # | claim | status |
|---|---|---|
| 1.1 | two-sided kink lemma with a property-defined left set and an unattained right anchor | proved; computed t1(A) (14,733 near-optimal checks, exact arithmetic) |
| 1.2 | the left margin as a wedge: $m_N\ge\mu(1-c/\sigma)$ | proved |
| 1.3 | kink Thm 3.2, Cor 3.3 and Thm 5.4(ii) are cases of Lemma 1.1 (up to windows); the window variant | proved |
| 2.1 | `thm:teacher:main`(i), (ii)(b), (ii)(c) are Lemma 1.1 with τ = $2^{-m}$, $g=\Lambda_2/2^m$, $\ell_M=d-4-\Lambda_1$; left margin $\ge\Phi_2-J_g$; wedge at $c_{\rm hi}$; `prop:limits:envelope`(i) is the third inequality | proved; computed t1(B) |
| 2.2 | the hypothesis ↔ kink-condition table | proved (by inspection of the proofs) |
| 2.3 | `thm:split:private`(i) and iid Thm 4.1(i) are Lemma 1.1 with τ = 1, $g=k+\delta^*$, $N=\emptyset$ | proved; computed t1(C) |
| 2.4 | for $m=d$ the right condition is the sufficiency line for all programs, with $g=b_0'$; `cor:teacher:fulltable`(i) is the τ = 1 instance | proved; computed t1(D) |
| 2.5 | δ* and $\delta_S$ play the same role, with the same $2^{-j}$ tail | remark (from proved results) |
| 3.1 | full table, every $m$: window $\lambda\in(2^{d-m},Nc_{\rm hi})$; total-bit right flatness in $[2^{d-m}\theta_m,2^{d-m}]$ | proved; computed t1(D), t2(A) |
| 3.2 | $\lambda_n=o(n)$ rejects every program not of least risk; the sampler is least-risk (Gibbs), the good model is not; λ = cn selects the $J_c$ minimiser (finite class) | proved |
| 3.3(a) | on samples the right flatness at the good model is at least about $\max\{1,n2^{-m}\theta_m\}$ | proved (explicit competitors) |
| 3.3(b) | with equal cell multiplicities $\bar n$ the right condition holds with τ = $\bar n$ (the full table: $2^{d-m}$; cells hit once: 1); with unequal multiplicities the effective slope can approach $\max_zn_z$ | sampled coding lemma and the equal-multiplicity line proved; the smallness of the cell-level gap β for $\bar n=1$ is a proof sketch; the unequal case is not proved |
| 3.3-c | the lower end tracks the multiplicity; fixed λ = 2 fails from $n\approx2^{m+1}$ | computed t2(B) (explicit class, κ-free code lengths) |
| 3.4, 3.5 | noise vs errors table; what λ > 1 buys | remark (from proved results) |
| 4.1 | envelopes raise the window's lower end to their rate; envelope (i) is Lemma 1.1(ii) | proved |
| 4.2 | rate blindness (⋆) = memoriser's secant ≥ coin's secant, an empty kink interval | proved |
| 4.3-c | two kinks and the shrinking interval (15.0 → 17.1 → 42.7 → 85.3 → empty); rate blindness from $d=13$ | computed t3 |
| 4.3 | rate, not validity, in hull form | remark (from cited results) |
| 5.1 | information charge: $\ell\ge d-\min\{s(t)+2\log d,d\}+I-\kappa$ | proved |
| 5.2 | $J^B_c\ge LB_t(c)$; `thm:teacher:main`(i), (ii) hold with $\Phi_2^\sharp\ge\Phi_2$ | proved; computed t4(B) |
| 5.3 | asymptotic window for every dyadic $p<0.12331$, from $a^*(p)2^{-m}$; $a^*=1$ for $p<0.07787$ | proved, given the computed constants (t4(A), t4(C)) |
| 5.3-c | certified windows at $d=100$, $m=20$ for $p=1/16,\dots,15/128$ (κ = 0), up to 7/64 (κ = 30) | computed t4(B) |
| 5-open | level ≤ 2 for $p<1/4$ in the junta case | conjecture (routine) |
| — | "fixed λ suffices for i.i.d. noise" (brief, T3) | refined: asymptotically every $\lambda_n=o(n)$ suffices (iid Thm 3.1); fixed λ > 1 gives the explicit bounds |

---

## References

* Paper 2 (`paper-steeper/sections/`): `lem:setup:hull`, `lem:setup:coding`, `rem:setup:persample`, `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `thm:split:shared`, `prop:algstat:product`, `prop:algstat:parity`, `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:sharpfloor`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main`, `cor:teacher:fulltable`, `cor:teacher:sampled`, `prop:teacher:concentration`, `prop:limits:plain`, `rem:limits:schedule`, `prop:limits:envelope`, `prop:limits:rateblind`, `lem:limits:robust`, `prop:limits:separable`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw`, `rem:limits:method`, `q:teacher:open`, `q:limits:open`.
* The steeper record `research/tracks/steeper/notes-final.md` §1–§4.
* Sibling notes: `../iid/notes.md` (Lemma 2.1, Thm 3.1, Prop 3.4, Thm 4.1, Lemma 5.2, Prop 7.3, Lemma 8.1) and `../kink/notes.md` (Def 3.1, Thm 3.2, Cor 3.3, Props 4.1–4.4, Thm 5.4, open question 3).
* R. Durrett, *Probability: Theory and Examples*: the strong law for nonnegative variables with infinite mean [known; edition and theorem number unverified].
* W. Hoeffding, "Probability inequalities for sums of bounded random variables", *JASA* 58:13–30, 1963 [as cited by Paper 2; used only through `lem:teacher:sharpfloor`].

---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and scipy 1.17.1. Every script was run from `checks/`, and its output saved as the `.out` file of the same name.*

* **t1_kink_instances** [deterministic, `random.seed(31)`; about 6 s].
  * (A) Lemma 1.1 in exact rational arithmetic:
    * 2591 random point sets with labels M/N, random reference points, right lines and margins;
    * 2336 values of $c$, with (i) checked at each;
    * 14,733 near-optimal points checked against (ii);
    * concavity of $m_N$ on 2484 sets.

    No assertion failed.
  * (B) The paper's $\Phi_1$, Δ, $\Delta_\ell$, risk bound and $g$ against the lemma's, over 17,411 random parameter sets: all relative differences ≤ $2.4\cdot10^{-14}$. The wedge at $c_{\rm hi}$ holds in all 10 configurations, with the exact $s(t)$ and with $4t$.
  * (C) The split instance agrees to $2.1\cdot10^{-13}$.
  * (D) The $m=d$ instance agrees exactly. The every-m table is as quoted.
  * A first run computed $L_S$ by `lgamma` also at $m\approx100$, where the cancellation in $2^mH(p)-L_S$ gave wrong values of $\Lambda_2$ (of order $10^{15}$). The final script computes the gap by Stirling's series above $2^m=10^7$. Only rows of (D) with $m\ge92$ changed; nothing quoted above depends on the first run.
* **t2_reuse_factor** [seeded, `numpy.default_rng(32)`; about 1 s]. Exact hulls of the explicit class.
  * The class's Kraft sum is at most 1 by construction: the rate code's sum is asserted ≤ 1 in `tcommon.py`.
  * (A) as quoted, including the $m=4$ case where the good model is not a vertex.
  * (B) 20 samples for each of 10 values of $n$, medians as quoted.
  * After the shared helpers were moved to `tcommon.py`, the output was identical to the earlier run except for the printing of $S$ (numpy integers printed as plain integers).
* **t3_second_kink** [seeded, `numpy.default_rng(33)`; under 1 s].
  * (A) and (B) as quoted.
  * A first version of (B) used a single 3-bit prefix rule. In the explicit class that rule is cheaper than the good model's rate code at every $d\ge4$, so the good model was never a vertex. It was replaced by a 4-cell rule at $m=5$, which shows the crossover; the first version is not quoted.
* **t4_junta_window** [deterministic; about 30 s].
  * (A) The constants $p^*=0.07787$, 0.05596, 0.12331 and the $a^*(p)$ table, with the grid check of convexity in $\sqrt x$.
  * (B) Certified windows at $d=100$, $m=20$:
    * the lower bound on the infimum over $I$ uses an interval grid of ratio 1.02 up to $200s_0$, with Floor nonincreasing in $I$ and the tail bounded by $cI_K$;
    * $c$ is certified per cell from monotonicity;
    * every κ in Lemma 5.1 is counted, 4κ in all.

    An earlier run counted 2κ. Only the κ = 30 rows changed, slightly; the quoted rows are from the final run.
  * (C) The finite-size bound converges to $\psi_2$ from below as $m$ grows, for 9 pairs $(p,a)$.
* **Proof checks.**
  * Lemma 1.1 was proved twice: by hand, and by checking each inequality in t1(A).
  * The identities of Prop 2.1(c) were derived by hand (the $\Delta_\ell$ identity is displayed in the proof) and confirmed numerically in t1(B).
  * Prop 2.4's offset was compared with kink §4's $b_0$; they agree.
  * Lemma 5.1 repeats, in reverse, the steps of `thm:teacher:main`(ii)(d) and of `lem:teacher:sharpfloor`'s information budget. The lower bound on $I$ uses only (F3) and (F5).
  * In Prop 5.2 the replacement of $\Phi_2$ was checked against every use of (o) in `app-teacher.tex`'s proofs of (i) and (ii). Only "level ≥ 2 implies $J^B_c\ge\Phi_2$" is used.
  * In Prop 5.3 the uniform convergence step needs $\delta_S=o(2^m)$ and $g_m=o(s_0)$. Both are stated as hypotheses.
  * No independent referee has read these notes.
* **Reproducibility.** After the notes were written, all four scripts were rerun into a scratch directory, and each reproduced its saved output byte for byte. The `__pycache__` directory created by importing `tcommon.py` was deleted.
* **Repository.** No git command was run. All files written are under `research/tracks/split/teacher/`: `notes.md`, and in `checks/` the scripts `t1`–`t4`, `tcommon.py` and their `.out` files.
