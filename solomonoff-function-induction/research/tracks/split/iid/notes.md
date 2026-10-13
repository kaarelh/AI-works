# Track "split", sub-track "iid": exact model recovery with i.i.d. inputs (target T1)

*Brief: `../00-brief.md`, target T1. Sources read: `paper-steeper/sections/{setup,absorb,split,app-split,algstat,limits}.tex`, the refereed record `research/tracks/steeper/notes-final.md` (§1, §2.5–2.6, §3.1–3.6), Paper 1's `paper/sections/{setting,versions,learn}.tex`, and `paper/NOTATION.md`. Paper 2's labels are cited as `thm:split:private` etc.; "St" is the steeper record.*

* **Scripts.** `checks/i1`–`i6`, Python 3.11, deterministic or seeded (numpy `default_rng`), outputs saved next to them as `.out` files.
* **Status tags.**
  * **[proved]**: full proof here.
  * **[computed: iN]**: checked by `checks/iN`; output in `checks/iN*.out`.
  * **[known: ref]**: standard or published. "(unverified)" means the statement was not checked against the source.
  * **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]**: as named. Refuted claims are kept, with the counterexample.
* **Conventions.** $\log=\log_2$, $\ln$ natural. Squared Hellinger distance $\Hel(P,Q):=1-\sum_y\sqrt{P(y)Q(y)}$, also for a sub-probability $Q$ (Paper 2's convention). κ is a machine constant (Paper 2's κ). Numbers marked "κ = 0" set the unknown machine constant to 0 and are illustrations only.

---

## 0. Summary

The brief asks for a "split works" theorem: with i.i.d. inputs, the λ-MAP eventually *is* a shortest program for the sampler, up to μ-almost-everywhere equality. The findings, in brief:

1. **Which object (§1, §7.5).** On $X=\{0,1\}^*$ every input law is atomic, so inputs repeat.
   * With **frozen noise** (one label per distinct input, Paper 2's data sets), **no procedure recovers every sampler** of the canonical class: two samplers that differ at one input of positive mass give mutually absolutely continuous data laws, so a procedure that succeeds almost surely for one fails almost surely for the other (Prop 7.5) [proved]. What holds there is Paper 2's "ν-equivalent on the run" with the run equal to the support of μ (Prop 7.6) [proved]. A concrete λ-MAP fails with probability 0.146 (i3(C)) [computed].
   * With **fresh noise per query** (the likelihood of the per-query mixture $\Mpq$), exact recovery holds. All theorems of §3–§6 are about this object. It coincides with the data-set likelihood whenever inputs are distinct: for a non-atomic μ on a general input space, or for stamped inputs with stamp-ignoring programs.
2. **Exact recovery, asymptotically (§3).** In every countable class with Kraft weights that contains the sampler, for **every schedule $1\le\lambda_n=o(n)$**, almost surely the set of $\lambda_n$-MAPs is eventually exactly $E^*$, the shortest programs whose kernel equals ν μ-a.e. (Thm 3.1) [proved]. The power and tempered posteriors concentrate on the set $E$ of *all* μ-a.e. equivalent programs, with limiting conditional law equal to the prior on $E$ (Thm 3.2) [proved].
   * *Correction to the brief's framing.* This holds **at λ = 1** too. Two-part MDL with λ = 1 also identifies the model in the limit. This is classical for density estimation [known, per a secondary source: Barron & Cover 1991; unverified]. So λ > 1 is not what makes the split exact in the limit.
   * *Refuted:* "the posteriors concentrate on the shortest equivalent programs". They concentrate on $E$. The mass of $E^*$ tends to its prior share within $E$, which is below 1 whenever longer equivalent programs exist, as they do in every canonical class (Thm 3.2; i1(C)) [refuted; computed].
   * With $\lambda=cn$, exact recovery fails (Prop 3.4) [proved; computed: i1(D)].
3. **What λ > 1 adds: guarantees that are uniform in time and explicit (§4–§5).**
   * For fixed λ > 1, three bounds hold for all $n$ simultaneously [proved]:
     * the MAP's length is at most $\ell^*+(\ell^*+\delta^*)/(\lambda-1)$;
     * the fill-ins' posterior is at most $2^{\lambda\ell^*+\lambda\delta^*-(\lambda-1)S_n}$, with $S_n/n\to$ the conditional entropy;
     * under a margin condition, with probability at least 1 − ε, every λ-MAP is in $E^*$ once
     $$n\ \ge\ n(\lambda,\ell^*,\gamma,\varepsilon):=\Big\lceil\frac{\lambda\,(\ell^*+\log(2/\varepsilon))\ln2}{2\min(1,\lambda-1)\,\gamma}\Big\rceil.$$
     Here γ lower-bounds the Hellinger gap $\Ex_\mu\Hel(\nu,\nu_\pi)$ of the non-equivalent programs of length at most $L_\varepsilon=\lceil(\lambda\ell^*+\log(2/\varepsilon))/(\lambda-1)\rceil$ (Thm 4.1).
   * At λ = 1 **no such bound exists**. A class with a uniform margin $1-2^{-1/2}$ over *all* wrong programs makes the 1-MAP a fill-in with probability at least 31/32 at any prescribed $n$. In the natural parity class the recovery time is about $2^{\ell^*/2}$ at λ = 1 and about $\lambda\ell^*/(\lambda-1)$ at λ > 1 (Prop 5.1) [proved; computed: i2].
   * Both the margin (factor $1/\gamma$) and the factor $1/(\lambda-1)$ are necessary, up to constants (Prop 4.4) [proved; computed: i2].
   * λ > 1 is not uniformly faster. When the only competitors are *shorter* wrong programs, a larger λ delays recovery (i1(A)) [computed].
   * In the canonical class the margin $\gamma_L$ is positive but smaller than every computable function of $L$ (Prop 4.3) [proved]. So the explicit sample size is computable only for classes with a known margin, such as finite, parametric or circuit classes.
4. **The λ = 1 MAP (§5).** A single deterministic fill-in of length $\ell^*-\log\nu(D)+3\log(n+1)+3\log(d+2+\log|Y|)+2\log(R+1)+\kappa$ exists for every data set (Lemma 5.2) [proved; computed: i5]. So at λ = 1 the sampler and its best single fill-in tie up to $\ell^*+\delta^*$ bits in one direction and $O(\log n+\log d+\log S)$ in the other. Which one is the 1-MAP at a given $n$ is decided by these terms. If it is a fill-in, its length lies in $[S_n-\delta^*,\ \ell^*+S_n]$, about the sampled randomness (Prop 5.3) [proved]. It is eventually a model, almost surely (Thm 3.1).
5. **Corollaries (§6).**
   * *Noisy computable functions* $y=f(x)\oplus\Bern(p)$: the λ-MAP eventually names $f$ (μ-a.e.) and the **exact** rate $p$; the flips are the noise (Cor 6.1) [proved]. A worked noisy-parity class has an explicit margin and sample size (i4) [computed].
   * Every countable subclass, for example time-bounded or circuit classes (Cor 6.2) [proved].
6. **What fails (§7).**
   * *Shared randomness*: no recovery for any λ > 1 once $\ell^*>(\lambda\ell_U+\kappa_0)/(\lambda-1)$ (Prop 7.1) [proved, from Paper 2].
   * *Non-i.i.d. or adaptive inputs*: only Paper 2's "on the run" survives. A non-i.i.d. input sequence makes a shorter program that differs from ν at every queried input the eventual MAP (Prop 7.2) [proved; computed: i3(D)].
   * *Misspecification* (ν ∉ C). The **KL-projection conjecture is refuted twice**:
     * two projections with different kernels make the MAP oscillate forever (Prop 7.3(ii)) [proved; computed: i3(A)];
     * with deterministic programs in the class, the λ-MAP is eventually a fill-in for $\lambda<1/H(p)$ and the projection for $\lambda>1/H(p)$ (Prop 7.3(iii)) [proved; computed: i3(B)].
     
     It holds in finite classes with a unique projection kernel (Prop 7.3(i)) [proved]. If no projection exists, the MAP's length tends to infinity (Prop 7.3(iv)) [proved]. A general description is Conjecture 7.4.
   * *Finite domains*: fresh noise recovers exactly; frozen noise cannot. With λ = cn one gets the population hull, not $E^*$ (§7.5).
7. **Link to T2 (§8).** Under the margin condition the product structure function of a sample has, with probability at least $1-2^{\ell^*}e^{-\gamma n/2}$, a drop of at least $\gamma n\log e$ bits at $\alpha=\ell^*$, while longer programs gain at most one bit per bit plus δ* (Lemma 8.1) [proved].

---

## 1. Setting and the two objects

**Definition 1.1 (class, sampler, data).**
* *Class.* A countable set $\mathcal C$ of programs with lengths $\ell(\pi)\in\mathbb N$ and $\sum_{\pi\in\mathcal C}2^{-\ell(\pi)}\le1$. Each π has a kernel $\nu_\pi(y\mid x)\ge0$ with $\sum_y\nu_\pi(y\mid x)\le1$, measurable in $x$. $Y$ is finite.
  * Prefix-freeness, lower semicomputability and the canonical structure of Paper 2's classes are used only in Prop 4.3, §5, and the parts of §7 that name a canonical class. Everything else uses only countability and the Kraft inequality.
  * $\Hcl{\times}$ and every time-bounded or circuit product class are instances.
* *Sampler.* A probability kernel ν ($\sum_y\nu(y\mid x)=1$) on an input space $X$ with a probability measure μ. ν and μ need not be computable.
* *Data (per-query object).* Pairs $(x_i,y_i)$ i.i.d. from $\mu\otimes\nu$. The likelihood of π is the per-query product
  $$L_n(\pi):=\prod_{i\le n}\nu_\pi(y_i\mid x_i),$$
  repeats included. $L_n(\nu)$ is defined the same way.
  * This is the term of π in Paper 1's per-query mixture $\Mpq$ (`prop:learn:perquery`).
  * On distinct inputs it equals Paper 2's product law $\nu_\pi(D_n)$.
  * The two-part objective is $J_\lambda(\pi):=\lambda\ell(\pi)-\log L_n(\pi)$; its minimisers are the λ-MAPs. The power and tempered posteriors are as in `def:setup:objectives`, with $L_n$ in place of $P_\pi(o)$.
* *Likelihood ratio and sampled randomness.* $\Lambda_n(\pi):=L_n(\pi)/L_n(\nu)$ and $S_n:=-\log L_n(\nu)$. Almost surely $\nu(y_i\mid x_i)>0$ for all $i$, so $\Lambda_n$ is well defined.

**Definition 1.2 (the target).** $E:=\{\pi\in\mathcal C:\ \nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)\text{ for }\mu\text{-a.e. }x\}$. Assume $E\neq\emptyset$ ("ν is in the class"). Put $\ell^*:=\min_{\pi\in E}\ell(\pi)$ and $E^*:=\{\pi\in E:\ell(\pi)=\ell^*\}$.
* $E^*$ is finite by Kraft.
* If ν has a program of length $k$ in $\mathcal C$, then $\ell^*\le k$. Paper 2's statements with $k$ hold with $\ell^*$.
* For π ∈ E, almost surely $\Lambda_n(\pi)=1$ for all $n$, since $x_i$ falls a.s. where the kernels agree.

**Definition 1.3 (frozen object).** A random function $F$ with independent values $F(x)\sim\nu(\cdot\mid x)$ is drawn once. The inputs are i.i.d. from μ, independent of $F$. The data set $D_n$ is the set of distinct pairs $(x_i,F(x_i))$, and the likelihood is $\nu_\pi(D_n)=\prod_{x\in\mathrm{dom}D_n}\nu_\pi(F(x)\mid x)$. This is Paper 2's setting (`def:setup:data`, frozen noise), with i.i.d. inputs.

**Remark 1.4 (which object; repeats) [proved].**
* (a) If μ has no atoms, inputs are a.s. distinct. Then the per-query and frozen likelihoods coincide, and every theorem of §3–§6 applies to Paper 2's data sets. This needs an uncountable $X$ (for example infinite binary sequences read as oracles). The proofs below use no computability, so they cover such classes.
* (b) On a countable $X$, such as $\{0,1\}^*$, μ is atomic and inputs repeat a.s. The per-query object then models a source that **redraws** the label at each query, a "noisy oracle". The frozen object models a fixed noisy table. The two lead to different theorems: exact recovery for the first (Thm 3.1); for the second, no procedure recovers every sampler (Prop 7.5).
* (c) Stamping the queries with their index makes the inputs distinct. A stamp-ignoring program $\tilde\nu_\pi(y\mid\langle x,t\rangle):=\nu_\pi(y\mid x)$ has product law $L_n(\pi)$ on the stamped data set (Paper 1, `prop:learn:perquery`(d)). So the per-query object is Paper 2's product class on stamped inputs, restricted to stamp-ignoring programs.
* (d) Random-function SFI (shared randomness) cannot model fresh noise at all: its loss is infinite with positive probability (Paper 1, `prop:learn:freshnoise`). The per-query object is the natural one for a product class.

---

## 2. Tools

**Lemma 2.1 (likelihood ratios) [proved; (b) uses the strong law of large numbers, known].** Let π ∈ $\mathcal C$, $Z:=\nu_\pi(y\mid x)/\nu(y\mid x)$ for $(x,y)\sim\mu\otimes\nu$, so that $\Lambda_n(\pi)$ is a product of $n$ i.i.d. copies of $Z$. For $s\in(0,1)$ put
$$\rho_s(\pi):=\Ex_{x\sim\mu}\sum_y\nu(y\mid x)^{1-s}\nu_\pi(y\mid x)^s,\qquad \gamma(\pi):=1-\rho_{1/2}(\pi)=\Ex_\mu\Hel\big(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x)\big).$$
* (a) $\Ex[Z\mid x]=\sum_{y:\nu(y\mid x)>0}\nu_\pi(y\mid x)\le1$. So $\Lambda_n(\pi)$ and $\Lambda_n(\pi)^\eta$ ($0<\eta\le1$) are nonnegative supermartingales.
* (b) $D(\pi):=-\Ex\log Z\in[0,\infty]$, with $D(\pi)>0$ iff π ∉ E. Moreover $\Ex(\log Z)^+\le\log e/e<0.531$, and $\frac1n\log\Lambda_n(\pi)\to-D(\pi)$ a.s. (also when $D(\pi)=\infty$).
* (c) $\Ex\Lambda_n(\pi)^s=\rho_s(\pi)^n$, and $\rho_s(\pi)<1$ iff π ∉ E.
* (d) $\rho_s(\pi)\le\rho_{1/2}(\pi)^{2\min(s,1-s)}$. Hence $1-\rho_s(\pi)\ge2\min(s,1-s)\,\gamma(\pi)$ and $\rho_s(\pi)^n\le e^{-2\min(s,1-s)\gamma(\pi)n}$.

*Proof.*
* (a) Sum over the labels with $\nu(y\mid x)>0$. Jensen gives $\Ex[Z^\eta\mid x]\le(\Ex[Z\mid x])^\eta\le1$. The supermartingale property holds because the pairs are i.i.d.
* (b) Positivity.
  * Conditional Jensen for the strictly concave log gives $\Ex[\log Z\mid x]\le\log\Ex[Z\mid x]\le0$.
  * Equality in both holds iff $Z$ is a.s. constant given $x$ and $\sum_{y:\nu>0}\nu_\pi(y\mid x)=1$. That means $\nu_\pi(y\mid x)=c\,\nu(y\mid x)$ on the support of $\nu(\cdot\mid x)$, with $c=1$. Then $\sum_y\nu_\pi(y\mid x)\le1$ forces $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$.
  * So $\Ex[\log Z\mid x]<0$ exactly where the kernels differ, and $D(\pi)>0$ iff they differ on a set of positive μ-measure.
* (b) Strong law.
  * The positive part is integrable: $\log z\le z\log e/e$ for $z>0$, since $\ln z/z\le1/e$. So $\Ex(\log Z)^+\le(\log e/e)\Ex Z\le\log e/e$.
  * The strong law for i.i.d. variables with integrable positive part gives $\frac1n\sum\log Z_i\to\Ex\log Z\in[-\infty,0]$ a.s. [known: e.g. Durrett, *Probability: Theory and Examples*, the strong law and its extension to $\Ex X^-=\infty$ (section number unverified)].
* (c)
  * Independence gives $\Ex\Lambda_n^s=(\Ex Z^s)^n$, and $\Ex Z^s=\Ex_\mu\sum_{y:\nu>0}\nu^{1-s}\nu_\pi^s=\rho_s$.
  * Hölder gives $\sum_y\nu^{1-s}\nu_\pi^s\le(\sum_y\nu)^{1-s}(\sum_{y:\nu>0}\nu_\pi)^s\le1$. Equality holds iff $\nu_\pi(\cdot\mid x)$ is proportional to $\nu(\cdot\mid x)$ on its support with total mass 1 there, that is iff $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$.
* (d) Hölder on $\mu(dx)\times$ counting measure on $Y$, with exponents $a+b=1$.
  * For $s\in[\tfrac12,1)$: $\nu^{1-s}\nu_\pi^s=(\sqrt{\nu\nu_\pi})^{2(1-s)}\,\nu_\pi^{2s-1}$. So $\rho_s\le\rho_{1/2}^{2(1-s)}(\Ex_\mu\sum_y\nu_\pi)^{2s-1}\le\rho_{1/2}^{2(1-s)}$.
  * For $s\in(0,\tfrac12]$: $\nu^{1-s}\nu_\pi^s=(\sqrt{\nu\nu_\pi})^{2s}\,\nu^{1-2s}$. So $\rho_s\le\rho_{1/2}^{2s}$.
  * Then $(1-\gamma)^a\le1-a\gamma$ for $a\in[0,1]$, and $1-u\le e^{-u}$. ∎

[computed: i1(B): the inequality of (d) holds for all 8 programs of a test class and $s\in\{0.05,\dots,0.95\}$ (largest violation $2.2\cdot10^{-16}$, rounding); $\Ex\Lambda_6^s=\rho_s^6$ by exact enumeration, error $1.7\cdot10^{-15}$.]

**Lemma 2.2 (Ville deficiency, per query) [proved; computed: i6; Ville's inequality known].** Let $\xi_{\mathcal C}(h_n):=\sum_\pi2^{-\ell(\pi)}L_n(\pi)$ and $\delta^*:=\sup_n\log(\xi_{\mathcal C}(h_n)/L_n(\nu))$.
* (a) $\Prob[\delta^*\ge j]\le2^{-j}$ for every real $j\ge0$, and $\Lambda_n(\pi)\le2^{\ell(\pi)+\delta^*}$ for all π and $n$.
* (b) For every $L$, $Z^L_n:=\sum_{\ell(\pi)>L}2^{-\ell(\pi)}\Lambda_n(\pi)$ is a nonnegative supermartingale with $Z^L_0=t_L:=\sum_{\ell(\pi)>L}2^{-\ell(\pi)}$, so $\Prob[\sup_nZ^L_n\ge a]\le t_L/a$. The same holds with $\Lambda_n^\eta$, $0<\eta\le1$, in place of $\Lambda_n$.
* (c) Both hold for any input rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn (adaptive, randomised), with fresh labels at repeats. They also hold when ν ∉ $\mathcal C$, since only the truth's own likelihood is in the denominator.

*Proof.* By Lemma 2.1(a) applied termwise, $\Ex[\xi_{\mathcal C}(h_{n+1})/L_{n+1}(\nu)\mid h_n,x_{n+1}]\le\xi_{\mathcal C}(h_n)/L_n(\nu)$. The initial value is $\sum2^{-\ell}\le1$. Ville's maximal inequality [known: Ville 1939] gives (a), and the same for (b). For the consequence in (a), $2^{-\ell(\pi)}\Lambda_n(\pi)\le\xi_{\mathcal C}(h_n)/L_n(\nu)\le2^{\delta^*}$. This is `lem:split:ville` with per-query likelihoods; the proof there uses only the one-step inequality. ∎

[computed: i6: inputs uniform on 8 points (so they repeat), 32 programs, 4000 runs of 3000 queries; empirical $\Prob[\delta^*\ge j]=0.207,0.103,0.053,0.026,0.007$ for $j=1,2,3,4,6$, all below $2^{-j}$. On every path, every $n$ and λ ∈ {1.25, 2, 4}, no λ-MAP was longer than $(\lambda\ell^*+\delta^*)/(\lambda-1)$.]

---

## 3. Exact recovery in the limit

**Theorem 3.1 (exact recovery of the MAP) [proved; computed: i1(A), i2, i4].** In the setting of Definitions 1.1–1.2, let $(\lambda_n)$ be any schedule with $\lambda_n\ge1$ and $\lambda_n/n\to0$; fixed $\lambda\ge1$ is allowed, **including λ = 1**. Almost surely there is $n_0$ such that for every $n\ge n_0$ the set of $\lambda_n$-MAPs equals $E^*$.

*Proof.* Work on the almost sure event where $L_n(\pi)=L_n(\nu)>0$ for all π ∈ E and all $n$.
* *MAPs exist.* $J_{\lambda_n}(\pi)\ge\ell(\pi)$, and only finitely many programs have length below $J_{\lambda_n}(\pi_0)<\infty$ for $\pi_0\in E^*$. So the set of MAPs is finite and nonempty.
* *A MAP beats $E^*$.* If $\hat\pi$ is a $\lambda_n$-MAP, then $J_{\lambda_n}(\hat\pi)\le J_{\lambda_n}(\pi_0)$, that is
  $$\log\Lambda_n(\hat\pi)\ \ge\ \lambda_n\big(\ell(\hat\pi)-\ell^*\big).\tag{3.1}$$
* *Step 1: long programs, uniformly in $n$.*
  * Let $L\ge\ell^*$. If a MAP has $\ell(\hat\pi)>L$, then (3.1) and $\lambda_n\ge1$ give $\log\Lambda_n(\hat\pi)\ge\ell(\hat\pi)-\ell^*$. So $2^{-\ell(\hat\pi)}\Lambda_n(\hat\pi)\ge2^{-\ell^*}$, hence $Z^L_n\ge2^{-\ell^*}$.
  * Let $B_L:=\{\exists n:\ Z^L_n\ge2^{-\ell^*}\}$. By Lemma 2.2(b), $\Prob(B_L)\le2^{\ell^*}t_L\to0$. Since $Z^L_n$ is nonincreasing in $L$ pathwise, $B_L$ decreases in $L$, and $\Prob(\bigcap_LB_L)=0$.
  * So almost surely there is a finite $L_0$ such that no $\lambda_n$-MAP, at any $n$, is longer than $L_0$.
* *Step 2: the finitely many short programs.*
  * By Lemma 2.1(b) and countability, almost surely $\frac1n\log\Lambda_n(\pi)\to-D(\pi)<0$ simultaneously for all π ∉ E.
  * Take π ∉ E with $\ell(\pi)\le L_0$:
    * If $\ell(\pi)\ge\ell^*$, the left side of (3.1) tends to $-\infty$ and the right side is $\ge0$. So π is eventually not a MAP.
    * If $\ell(\pi)<\ell^*$, the left side is at most $-nD(\pi)/2$ eventually (or tends to $-\infty$ faster), while the right side is $-\lambda_n(\ell^*-\ell(\pi))=-o(n)$. So π is eventually not a MAP.
  * Programs in $E\setminus E^*$ have $\Lambda_n=1$ and $\ell>\ell^*$, so (3.1) fails for them at every $n$.
  * There are finitely many programs with $\ell\le L_0$, so from some $n_0$ on every MAP lies in $E^*$. All of $E^*$ have the same $J$, so the set of MAPs is exactly $E^*$. ∎

*Remarks.*
* **λ = 1 is included.** The asymptotic split does not need a steeper prior. The tail $t_L$ of the prior bounds the probability that a long program (for example a fill-in) is ever selected. What λ > 1 adds is a length bound that depends only on $\ell^*$, λ and the Ville deficiency δ* (Thm 4.1(i)), in place of the class-dependent tail $t_L$. §5 shows the difference is real.
* **Known.** For i.i.d. density estimation with a countable list of densities and Kraft code lengths, consistency of two-part MDL (λ = 1) is attributed to Barron & Cover 1991 [known: per Poland & Hutter, "Asymptotics of discrete MDL for online prediction", arXiv cs/0506022, which states that i.i.d. MDL estimates are consistent [BC91] (snippet); whether Barron–Cover state "equals the true density for all large n a.s." and for which complexity weights α ≥ 1 is unverified]. Theorem 3.1 is the conditional (supervised) analogue, with sub-probability kernels, an arbitrary input law, schedules $\lambda_n=o(n)$, and the identification of the limit as the *shortest* μ-a.e. equivalent program. The proof is the standard Ville-plus-strong-law argument. I claim no novelty for the method.
* μ enters only through "μ-a.e.": the theorem identifies ν on the support of μ, and nothing about inputs of μ-measure zero.

**Theorem 3.2 (posterior concentration) [proved; computed: i1(C)].** Fix λ ≥ 1 and η ∈ (0, 1]. Almost surely:
* (i) $\Pi_\lambda(E\mid h_n)\to1$, and $\Pi_\lambda(\pi\mid h_n)\to2^{-\lambda\ell(\pi)}/W_\lambda$ for every π ∈ E, where $W_\lambda:=\sum_{\pi\in E}2^{-\lambda\ell(\pi)}$. In particular $\Pi_\lambda(E^*\mid h_n)\to w_\lambda:=|E^*|2^{-\lambda\ell^*}/W_\lambda$.
* (ii) The tempered posterior $\Pi^\eta(\pi\mid h_n)\propto2^{-\ell(\pi)}L_n(\pi)^\eta$ satisfies $\Pi^\eta(E\mid h_n)\to1$ and $\Pi^\eta(E^*\mid h_n)\to w_1$.
* (iii) $w_\lambda\ge w_1$, and $w_\lambda=1$ iff $E=E^*$.

*Proof.*
* (i), the denominator. Divide numerator and denominator by $L_n(\nu)$. The weights become $2^{-\lambda\ell(\pi)}\Lambda_n(\pi)$, and the denominator is at least $W_\lambda$.
* (i), the non-equivalent mass. For any $L$,
  $$\sum_{\pi\notin E}2^{-\lambda\ell(\pi)}\Lambda_n(\pi)\ \le\ \sum_{\pi\notin E,\ \ell(\pi)\le L}2^{-\lambda\ell(\pi)}\Lambda_n(\pi)\ +\ Z^L_n,$$
  using $2^{-\lambda\ell}\le2^{-\ell}$.
  * The finite sum tends to 0 a.s. (Lemma 2.1(b)).
  * Choose $L_j$ with $t_{L_j}\le4^{-j}$. Lemma 2.2(b) gives $\Prob[\sup_nZ^{L_j}_n\ge2^{-j}]\le2^{-j}$. By Borel–Cantelli, a.s. $\sup_nZ^{L_j}_n<2^{-j}$ for all large $j$.
  * Hence $\limsup_n\sum_{\pi\notin E}2^{-\lambda\ell}\Lambda_n\le2^{-j}$ for all large $j$, so the limit is 0.
* (i), the limit law. The denominator therefore tends to $W_\lambda$, and the E-terms are constant.
* (ii) The same argument, with weights $2^{-\ell}\Lambda_n^\eta$, Lemma 2.1(c) ($\Lambda_n^\eta\to0$ for π ∉ E) and Lemma 2.2(b) for $\Lambda^\eta$.
* (iii) $W_\lambda2^{\lambda\ell^*}=\sum_E2^{-\lambda(\ell-\ell^*)}\le\sum_E2^{-(\ell-\ell^*)}=W_12^{\ell^*}$, since $\ell\ge\ell^*$ on $E$. Equality holds iff no program in E is longer than $\ell^*$. ∎

**Refuted (brief, T1, second bullet as written): "the power posterior and the tempered posterior concentrate on that set", read as $E^*$.**
* *Counterexample.* Any class with two programs for ν of lengths 5 and 7, as in i1: $w_\lambda=2^{-5\lambda}/(2^{-5\lambda}+2^{-7\lambda})$, which is 0.889 at λ = 1.5 and 0.941 at λ = 2. The tempered posterior's limit is $w_1=0.8$ for every η.
* Computed exactly: $\Ex\Pi_{1.5}(E^*\mid h_{400})=0.8889$, $\Ex\Pi_2(E^*\mid h_{400})=0.9412$, and the tempered posterior gives 0.8000 [computed: i1(C)].
* In a canonical class every program has infinitely many equivalent padded versions, so $w_\lambda<1$ always. The correct statement is Theorem 3.2: concentration on $E$, with the prior's shape inside $E$.
* Only the MAP singles out $E^*$. A larger λ moves more of the limiting mass onto $E^*$.

**Proposition 3.4 (λ = cn does not recover) [proved; computed: i1(D)].** Let $\lambda_n=cn$ with $c>0$. Suppose some π′ ∉ E has $\ell(\pi')<\ell^*$ and $D(\pi')<c(\ell^*-\ell(\pi'))$. Then almost surely no program of $E^*$ is a $\lambda_n$-MAP for all large $n$.

*Proof.* $\frac1n[J_{cn}(\pi_0)-J_{cn}(\pi')]=c(\ell^*-\ell(\pi'))+\frac1n\log\Lambda_n(\pi')\to c(\ell^*-\ell(\pi'))-D(\pi')>0$, by Lemma 2.1(b). ∎

* With $\lambda=cn$ the selection is governed by the population hull of the points $(\ell(\pi),R(\pi))$ (`lem:setup:hull`). That is the teacher's regime of Paper 2, not exact recovery.
* In i1, $c^*=\min_{\ell(\pi)<\ell^*}D(\pi)/(\ell^*-\ell(\pi))=0.135$, attained by the coin. For $c\in\{0.2,0.4,0.6\}$ the population minimiser is the coin; for $c\in\{0.05,0.1\}$ it is the truth.

---

## 4. What λ > 1 adds: uniform and explicit guarantees

**Theorem 4.1 (fixed λ > 1) [proved; computed: i1(A), i2(B), i4(B), i6].** In the setting of Definitions 1.1–1.2, fix λ > 1 and define δ* by Lemma 2.2. For a set $A$ of programs write $\Pi_\lambda(A\mid h_n)$ for its power-posterior mass.
* **(i) Length, for all n.** Every λ-MAP has $\ell(\hat\pi)\le(\lambda\ell^*+\delta^*)/(\lambda-1)=\ell^*+(\ell^*+\delta^*)/(\lambda-1)$. More generally, every π with $J_\lambda(\pi)\le J_\lambda(\pi_0)$ does.
* **(ii) Posterior length tail, for all n.** $\Pi_\lambda(\{\ell>L\}\mid h_n)\le2^{\lambda\ell^*+\delta^*-(\lambda-1)L}$.
* **(iii) Fill-ins, for all n.**
  * A deterministic program consistent with the data has $\ell\ge S_n-\delta^*$.
  * $\Pi_\lambda(\det\mid h_n)\le2^{\lambda\ell^*+\lambda\delta^*-(\lambda-1)S_n}$, and $\Pi^{1/\lambda}(\det\mid h_n)\le2^{\ell^*+\delta^*-(1-1/\lambda)S_n}$.
  * $S_n/n\to H_\mu(\nu):=\Ex_\mu H(\nu(\cdot\mid x))$ a.s. So if $H_\mu(\nu)>0$ the fill-ins' posterior decays exponentially in $n$, almost surely.
* **(iv) Finite sample.** For every $n$ and every $L\ge\ell^*$,
  $$\Prob\big[\text{the set of λ-MAPs at }n\ne E^*\big]\ \le\ 2^{\lambda\ell^*-(\lambda-1)L}+\sum_{\pi\notin E,\ \ell(\pi)\le L}2^{\ell^*-\ell(\pi)}\rho_{1/\lambda}(\pi)^n\ \le\ 2^{\lambda\ell^*-(\lambda-1)L}+2^{\ell^*}e^{-a_Ln},$$
  where $a_L:=2\min(1,\lambda-1)\gamma_L/\lambda$ and $\gamma_L:=\min\{\gamma(\pi):\pi\notin E,\ \ell(\pi)\le L\}$.
  * **The margin is automatic.** $\gamma_L>0$, as a minimum of finitely many positive numbers (Lemma 2.1(b),(c)). A *margin condition* is an explicit lower bound $\gamma\le\gamma_L$.
  * **The sample size.** With $L_\varepsilon:=\lceil(\lambda\ell^*+\log(2/\varepsilon))/(\lambda-1)\rceil$ and $\gamma\le\gamma_{L_\varepsilon}$, the probability is at most ε for every
    $$n\ \ge\ n(\lambda,\ell^*,\gamma,\varepsilon):=\Big\lceil\frac{\lambda\,(\ell^*+\log(2/\varepsilon))\ln2}{2\min(1,\lambda-1)\,\gamma}\Big\rceil .$$
* **(v) Uniformly in time.** $\Prob[\exists n\ge n_0:\ \text{MAPs}\ne E^*]\le2^{\lambda\ell^*-(\lambda-1)L}+2^{\ell^*}e^{-a_Ln_0}(1+1/a_L)$. So it suffices that $n_0\ge(\ell^*\ln2+\ln(2/\varepsilon)+\ln(1+1/a))/a$, with $a:=2\min(1,\lambda-1)\gamma/\lambda$.
* **(vi) Posterior, finite sample.** For every $n$, $L$ and ε ∈ (0, 1), with probability at least 1 − ε,
  $$\Pi_\lambda(\mathcal C\setminus E\mid h_n)\ \le\ 2^{\lambda\ell^*}\Big[(2/\varepsilon)^\lambda e^{-\lambda a_Ln}+2^{\log(2/\varepsilon)-(\lambda-1)L}\Big].$$
* **(vii) Tempered tail.** $\Pi^\eta(\{\ell>L\}\mid h_n)\le2^{\ell^*+\eta\delta^*}t_L^{1-\eta}$ for η ∈ (0, 1). This depends on the class's prior tail $t_L$, not only on $\ell^*$ and $L$.

*Proof.*
* (i) A program with $J_\lambda(\pi)\le J_\lambda(\pi_0)$ has $\lambda(\ell(\pi)-\ell^*)\le\log\Lambda_n(\pi)\le\ell(\pi)+\delta^*$ (Lemma 2.2(a)).
* (ii) $\sum_{\ell>L}2^{-\lambda\ell}\Lambda_n\le2^{-(\lambda-1)L}\sum_\pi2^{-\ell}\Lambda_n\le2^{-(\lambda-1)L+\delta^*}$, and the normaliser, divided by $L_n(\nu)$, is at least $2^{-\lambda\ell^*}$.
* (iii) As in `thm:split:private`(iii), with $W_{\det}\le\xi_{\mathcal C}\le2^{\delta^*}L_n(\nu)$.
  * A consistent deterministic π has $\Lambda_n(\pi)=2^{S_n}\le2^{\ell(\pi)+\delta^*}$.
  * $\sum_{\det}2^{-\lambda\ell}\Lambda_n\le2^{-(\lambda-1)(S_n-\delta^*)}\sum_{\det}2^{-\ell}\Lambda_n\le2^{-(\lambda-1)(S_n-\delta^*)+\delta^*}$, with normaliser at least $2^{-\lambda\ell^*}$.
  * Tempered: the fill-ins' weight is $\sum2^{-\ell}\Lambda_n^{1/\lambda}$ with $\Lambda_n^{1/\lambda}=2^{-(1-1/\lambda)S_n}\Lambda_n$ for consistent deterministic π. So it is at most $2^{-(1-1/\lambda)S_n+\delta^*}$, with normaliser at least $2^{-\ell^*}$.
  * $S_n/n\to H_\mu(\nu)$ by the strong law ($0\le\Ex[-\log\nu(y\mid x)]\le\log|Y|$).
* (iv) The event "MAPs ≠ $E^*$" is contained in the event that some π ∉ E has $J_\lambda(\pi)\le J_\lambda(\pi_0)$; programs in $E\setminus E^*$ never qualify.
  * If such π has $\ell(\pi)>L$, then by (i) $(\lambda-1)L<\lambda\ell^*+\delta^*$. By Lemma 2.2(a) this has probability at most $2^{\lambda\ell^*-(\lambda-1)L}$.
  * Otherwise $\Lambda_n(\pi)\ge2^{\lambda(\ell(\pi)-\ell^*)}$ for some π ∉ E with $\ell(\pi)\le L$. Markov's inequality for $\Lambda_n^{1/\lambda}$ and Lemma 2.1(c) give probability at most $2^{\ell^*-\ell(\pi)}\rho_{1/\lambda}(\pi)^n$ for each π.
  * Sum over π, use Lemma 2.1(d) with $s=1/\lambda$ (so $\min(s,1-s)=\min(1,\lambda-1)/\lambda$), and $\sum2^{-\ell}\le1$.
  * For the sample size: $L_\varepsilon$ makes the first term at most ε/2, and $n\ge n(\lambda,\ell^*,\gamma,\varepsilon)$ makes $2^{\ell^*}e^{-an}\le\varepsilon/2$.
* (v) The first term is already uniform in $n$, because δ* is a supremum. Sum the second over $n\ge n_0$: $\sum_{n\ge n_0}e^{-an}=e^{-an_0}/(1-e^{-a})\le e^{-an_0}(1+1/a)$.
* (vi) Split the non-equivalent mass at $L$.
  * Since $\lambda\ge1$, $\sum_{\pi\notin E,\ell\le L}2^{-\lambda\ell}\Lambda_n=\sum(2^{-\ell}\Lambda_n^{1/\lambda})^\lambda\le(\sum2^{-\ell}\Lambda_n^{1/\lambda})^\lambda$.
  * By Markov, the inner sum exceeds $(2/\varepsilon)e^{-a_Ln}$ with probability at most ε/2.
  * The tail is at most $2^{\delta^*-(\lambda-1)L}$, and $\delta^*\le\log(2/\varepsilon)$ with probability at least 1 − ε/2.
  * The normaliser is at least $2^{-\lambda\ell^*}$.
* (vii) Hölder with exponents $1/\eta$ and $1/(1-\eta)$: $\sum_{\ell>L}2^{-\ell}\Lambda^\eta=\sum(2^{-\ell}\Lambda)^\eta(2^{-\ell})^{1-\eta}\le(2^{\delta^*})^\eta t_L^{1-\eta}$. The normaliser is at least $2^{-\ell^*}$. ∎

*Checks.*
* [computed: i1(A)] Exact enumeration in an 8-program class on two inputs (minimum gap γ = 0.044). At every λ ∈ {1.25, 1.5, 2, 3} and $n\le400$: exact probability ≤ Rényi bound ≤ margin bound.
  * At λ = 2: exact $1.5\cdot10^{-4}$, Rényi $1.6\cdot10^{-3}$, margin $2.8\cdot10^{-2}$ at $n=160$.
  * At $n=400$: $2.0\cdot10^{-9}$, $3.1\cdot10^{-8}$, $7.4\cdot10^{-7}$.
* [computed: i4] A noisy-parity class: Cor 6.1.
* [computed: i2(B)] In the parity class of Prop 5.1 the Rényi bound is $0.25\cdot2^{\ell^*-(1-1/\lambda)n}$, which matches the exact asymptotics.

*Reading.*
* (i)–(iii) hold for every $n$, every countable class and every input law. They are the per-query form of `thm:split:private`(i)–(iii).
* (iv)–(vi) are the requested finite-sample version.
* The margin enters through the programs of length at most $L_\varepsilon\approx\ell^*\lambda/(\lambda-1)$ only. Longer programs are handled by the δ* tail, which is what the steeper prior buys.

**Proposition 4.2 (no finite-sample bound without a margin) [proved].** Let λ > 1 and $\ell^*\ge2$ with $\lambda(\ell^*-1)\ge9$, and let $N$ be any number. Take the two-program class of Prop 4.4(a) with Δ = ℓ* − 1: the truth Bern(1/2), of length $\ell^*$, and Bern(1/2 + ε′), of length 1, with ε′ so small that $0.083\,\lambda(\ell^*-1)/\gamma\ge N$. Then $\Prob[\text{MAP}\ne E^*\text{ at }n]\ge1-8.66/(\lambda(\ell^*-1))$ for every $n\le N$. So no sample size depending only on $(\lambda,\ell^*,\varepsilon)$ exists without a margin.

*Proof.* Prop 4.4(a), proved below. The Kraft sum is $1/2+2^{-\ell^*}\le1$. ∎

**Proposition 4.3 (the margin in the canonical class is not computably bounded) [proved].** Let $Y=\{0,1\}$ and $\mathcal C=\Hcl{\times}$. Let ν be a computable sampler with $\nu(1\mid x)\in[\beta,1-\beta]$ for all $x$, for a rational β > 0. Let $g:\mathbb N\to(0,1]$ be computable. Then $\gamma_L<g(L)$ for all sufficiently large $L$.

*Proof.*
* *The perturbations.* Let τ be the flipped kernel $\tau(1\mid x):=\nu(0\mid x)$, unless ν = Bern(1/2) μ-a.e., in which case let τ := Bern(1/4). Either way τ differs from ν on a set of positive μ-measure. For $j\ge1$ let $\nu_j:=(1-2^{-j})\nu+2^{-j}\tau$.
* *Each ν_j is in the class and wrong.* $\nu_j$ is a computable sampler, and $\nu_j\ne\nu$ on that set, so its programs are not in E. By closure under prefix-free simulation it has a program $\sigma\,\pi_\nu\,p_j$, where $p_j$ is a shortest $V$-program for $j$. So $\ell(\pi_j)\le\ell^*+K(j)+\kappa$.
* *Its gap is tiny.* $\Hel(P,Q)=\frac12\sum_y(\sqrt P-\sqrt Q)^2\le\frac12\sum_y(P-Q)^2/P$. With $|\nu_j-\nu|\le2^{-j}$ and $\nu\ge\beta$, this gives $\gamma(\pi_j)\le2^{-2j}/\beta$.
* *Lengths are cheap.* Let $j(L):=\max\{j:K(j)\le L-\ell^*-\kappa\}$. For every computable $h$, $K(h(m))\le K(m)+\kappa_h\le2\log m+\kappa'_h$. So $j(L)\ge h(L-\ell^*-\kappa)$ for all large $L$ [known: the largest number of complexity ≤ m eventually dominates every computable function].
* *Conclusion.* Take $h(m):=\lceil\frac12\log(1/(\beta g(m+\ell^*+\kappa)))\rceil+1$, which is computable. Then $\gamma_L\le\gamma(\pi_{j(L)})\le2^{-2j(L)}/\beta<g(L)$ for all large $L$. ∎

*Reading (and an open problem).*
* In the canonical class, (iv) gives no sample size computable from $(\lambda,\ell^*,\varepsilon)$.
* This is a weakness of the margin form of the bound, not obviously of the MAP. A near-equivalent program $\pi_j$ can beat $\pi_0$ only if $\log\Lambda_n(\pi_j)\ge\lambda(K(j)+\kappa)$. The fluctuations of $\log\Lambda_n(\pi_j)$ are of order $\sqrt n\,2^{-j}$ while $n\ll2^{2j}$.
* **[open]** A recovery-time bound for the canonical class, computable from $(\lambda,\ell^*,\varepsilon)$ and a margin for programs "far" from ν, that handles near-equivalent programs through their small likelihood fluctuations.

**Proposition 4.4 (the margin and the factor 1/(λ−1) are necessary; λ > 1 is not uniformly faster) [proved; computed: i1(A), i2].**
* **(a) Margin, factor 1/γ.**
  * *The class.* Two programs: the truth $\pi_0$ for Bern(1/2) labels, of length $\ell^*$, and π′ for Bern(1/2 + ε′), $0<\varepsilon'\le1/10$, of length $\ell^*-\Delta$, with $\lambda\Delta\ge9$. Then $\gamma(\pi')\in[\varepsilon'^2/2,2\varepsilon'^2]$.
  * *The claim.* For every
    $$n\ \le\ n_1:=\lambda\Delta(1-4\varepsilon'^2)\ln2/(4\varepsilon'^2),\qquad\text{in particular every }n\le0.083\,\lambda\Delta/\gamma(\pi'),$$
    the λ-MAP is π′ with probability at least $1-8.66/(\lambda\Delta)$.
  * *Comparison.* Theorem 4.1(iv) gives recovery by $n\approx0.35\,\lambda(\ell^*+\log(2/\varepsilon))/(\min(1,\lambda-1)\gamma)$. For λ ≥ 2 the dependence on γ is tight up to a constant factor and the ratio $\ell^*/\Delta$.
* **(b) The factor 1/(λ−1).** In the parity class of Prop 5.1, for λ > 1 the λ-MAP is a parity, not the truth, with probability at least 31/32 at every $n$ with $(\lambda-1)n\le\lambda(\ell^*-6-2\lceil\log(n+6)\rceil)$. By Thm 4.1(iv) it is the truth with probability at least 1 − ε once $n\ge\lambda(\ell^*+\log(1/(4\varepsilon)))/(\lambda-1)$. So the recovery time is $\Theta(\lambda\ell^*/(\lambda-1))$ up to logarithmic terms.
* **(c) λ > 1 delays recovery against shorter programs.** If every wrong program is shorter than $\ell^*$, a shorter π loses only when $\log\Lambda_n(\pi)<-\lambda(\ell^*-\ell(\pi))$, which takes about λ times as many samples.
  * [computed: i1(A)] In the class of i1, whose dangerous competitors are all shorter, the exact $\Prob[\text{MAP}\ne E^*]$ at $n=80$ is 0.0063 at λ = 1, 0.0074 at λ = 1.5, 0.0090 at λ = 2 and 0.0137 at λ = 3.
  * The steeper prior helps only against *longer* competitors (fill-ins and memorisers), which is where λ = 1 has no bound (§5).

*Proof.*
* (a)
  * π′ is the MAP iff $\log\Lambda_n(\pi')>-\lambda\Delta$. Write $\log\Lambda_n(\pi')=\sum_iX_i$ with $X_i\in\{\log(1+2\varepsilon'),\log(1-2\varepsilon')\}$ equally likely.
  * *Mean.* $m=\frac12\log(1-4\varepsilon'^2)\ge-2\varepsilon'^2/((1-4\varepsilon'^2)\ln2)$.
  * *Variance.* $\Var X\le\log^2(1-2\varepsilon')\le4\varepsilon'^2/((1-2\varepsilon')^2\ln^22)$.
  * *Chebyshev.* For $n\le n_1$ we have $n|m|\le\lambda\Delta/2$. So
    $$\Prob[\textstyle\sum X_i\le-\lambda\Delta]\le\frac{4n\Var X}{(\lambda\Delta)^2}\le\frac{4(1+2\varepsilon')}{(1-2\varepsilon')\ln2\cdot\lambda\Delta}\le\frac{8.66}{\lambda\Delta}.$$
  * *The gap.* $\sqrt{1+u}+\sqrt{1-u}\le2-u^2/4$, since the even Taylor coefficients of $\sqrt{1+u}$ beyond the constant are negative. So $\gamma(\pi')=1-\frac12(\sqrt{1+2\varepsilon'}+\sqrt{1-2\varepsilon'})\ge\varepsilon'^2/2$. Also $\gamma\le\frac12\sum(P-Q)^2/P=2\varepsilon'^2$. Hence $n_1\ge0.96\ln2\,\lambda\Delta/(8\gamma)\ge0.083\lambda\Delta/\gamma$.
* (b) At $m=n+5$ the parity length is $n+6+2\lceil\log(n+6)\rceil$. So a consistent parity with $\lambda\ell(m)\le\lambda\ell^*+n$ exists whenever the $n\times(n+5)$ input matrix has rank $n$, which has probability at least $1-2^{-5}$. The upper bound is Thm 4.1(iv) with the exact Rényi sum $0.25\cdot2^{\ell^*-(1-1/\lambda)n}$, computed in Prop 5.1. ∎

---

## 5. λ = 1: exact in the limit, with no bound

**Proposition 5.1 (no recovery-time bound at λ = 1) [proved; computed: i2].**
* *Setting.* Inputs uniform on $\{0,1\}^{D}$ ($D$ large), labels fresh per query from the fair coin ν = Bern(1/2). Classes:
  * $\mathcal C_k$: the coin, with $\ell=k$, and for every $m\le D$ and $w\in\{0,1\}^m$ the deterministic parity $f_{m,w}(x)=\langle w,x_{1:m}\rangle\bmod2$, with $\ell(m)=m+2\lceil\log(m+1)\rceil+1$. Kraft sum $2^{-k}+0.25$.
  * $\mathcal C_{k,M}$: the coin ($\ell=k$) and the $2^M$ parities on the first $M$ bits, each with $\ell=M+2$. Kraft sum $2^{-k}+1/4$.
* *Margin.* $E=E^*=\{\text{coin}\}$ and $\ell^*=k$. Every parity has $\gamma=1-2^{-1/2}=0.293$: the margin condition holds uniformly over **all** wrong programs.
* **(a)** In $\mathcal C_{k,M}$ with $k\ge8$, the 1-MAP at $n:=M-5$ is a parity with probability at least 31/32. So no function $n(1,\ell^*,\gamma,\varepsilon)$ bounds the recovery time at λ = 1, even with a uniform margin. For λ > 1 in the same class, $\Prob[\text{MAP}\ne\text{coin at }n]\le2^{k-2-(1-1/\lambda)n}$ whatever $M$ is.
* **(b)** In $\mathcal C_k$, at λ = 1 the 1-MAP is a parity with probability at least 31/32 for every $n$ with $2\lceil\log(n+6)\rceil+6\le k$, that is for $n$ up to about $2^{(k-8)/2}$. At λ > 1 the recovery time is $\Theta(\lambda k/(\lambda-1))$ up to logarithms (Prop 4.4(b)).
* **(c)** Theorem 3.1 still holds in both classes at λ = 1: almost surely the 1-MAP is eventually the coin.

*Proof.*
* *When a parity is a MAP.* A parity is consistent with the data iff the label vector $y$ lies in the column span of the $n\times m$ matrix $A$ of the first $m$ input bits. A parity on fewer bits is a parity on more bits (pad $w$ with zeros).
* *(a), at λ = 1.* The rows of $A$ are i.i.d. uniform in $\{0,1\}^M$, so $\Prob[\mathrm{rank}A<n]\le\sum_{i<n}2^{i-M}<2^{n-M}=2^{-5}$. When the rank is $n$, $y$ is in the span. That parity has $J_1=M+2=n+7<k+n=J_1(\text{coin})$.
* *(a), at λ > 1.* Each fixed parity is consistent with probability $2^{-n}$, and $\rho_{1/\lambda}(\text{parity})=2^{1/\lambda-1}$. Thm 4.1(iv)'s Rényi sum is $2^k\cdot2^M2^{-M-2}\cdot2^{-(1-1/\lambda)n}$.
* *(b)* Take $m=n+5$: $\ell(m)=n+6+2\lceil\log(n+6)\rceil\le k+n$ iff $2\lceil\log(n+6)\rceil+6\le k$, and argue as in (a).
* *(c)* Thm 3.1. ∎

[computed: i2(A), exact via the rank chain of a random GF(2) matrix; Monte Carlo agrees to within 0.004 at $k=12$ (i2(C))]. Recovery time $n_{\rm rec}(0.01)$, the least $n$ on a geometric grid after which $\Prob[\text{MAP}\ne\text{coin}]\le0.01$:

| $\ell^*=k$ | λ = 1 | λ = 1.1 | λ = 1.25 | λ = 1.5 | λ = 2 | λ = 3 |
|---|---|---|---|---|---|---|
| 16 | 1084 | 88 | 50 | 38 | 25 | 22 |
| 24 | 17736 | 153 | 76 | 58 | 38 | 29 |
| 32 | 290272 | 233 | 116 | 76 | 58 | 38 |
| 40 | 4750753 | 308 | 153 | 101 | 76 | 50 |

* At λ = 1 the recovery time multiplies by about 16 for every 8 bits of $\ell^*$: it grows like $2^{\ell^*/2}$. At λ > 1 it grows linearly in $\ell^*$, with slope about $\lambda/(\lambda-1)$.
* At λ = 1 and $n>2^{k/2}$, $\Prob\approx2^{k-1}/n^2$: polynomial, not exponential, decay.

**Lemma 5.2 (a single short fill-in) [proved; computed: i5].**
* *Setting.* The class is $\Hcl{\times}$, or the class of deterministic programs of $W$; $Y$ is finite. ν is a computable sampler with a program $\pi_\nu$ of length $k$. $D$ is a data set with $n$ distinct inputs of length at most $d$, with $\nu(D)>0$. Put $R:=\lceil-\log\nu(D)\rceil$.
* *Claim.* There is a deterministic program consistent with $D$ of length
  $$\ell\ \le\ k+R+\log n+\log(d+1+\log|Y|)+2\log(n+1)+2\log(d+1)+2\log(R+1)+\kappa\ \le\ k-\log\nu(D)+3\log(n+1)+3\log(d+2+\log|Y|)+2\log(R+1)+\kappa .$$

*Proof.*
* *Candidate data sets.* Given $(\pi_\nu,n,d,R)$, compute for every data set $D'$ with $n$ distinct inputs of length at most $d$ a rational $q(D')$ with $|q(D')-\nu(D')|\le2^{-R-2}$. This is possible since ν is computable and $D'$ is finite. Let $\mathcal D_R:=\{D':q(D')\ge2^{-R-1}\}$.
  * Then every $D'\in\mathcal D_R$ has $\nu(D')\ge2^{-R-2}$.
  * $D\in\mathcal D_R$, since $\nu(D)\ge2^{-R}$.
  * $|\mathcal D_R|\le A:=2^{n(d+1+\log|Y|)}$.
* *A covering family exists.* Let $M:=\lfloor2^{R+2}n(d+1+\log|Y|)\rfloor+1>2^{R+2}\ln A$. Draw $M$ i.i.d. random total functions $f_j\sim\nu$ on the inputs of length at most $d$ (one independent label per input). For each $D'\in\mathcal D_R$, $\Prob[\text{no }f_j\supseteq D']\le(1-2^{-R-2})^M<e^{-M2^{-R-2}}<1/A$. By the union bound, some family $(f_1,\dots,f_M)$ of finite tables extends every $D'\in\mathcal D_R$.
* *The program.* The first such family in a fixed enumeration of $M$-tuples of tables is computable from $(\pi_\nu,n,d,R)$, because coverage of the computable finite set $\mathcal D_R$ is decidable. The program reads $\pi_\nu$ (by simulating $V$), codes of $n$, $d$, $R$, and then $\lceil\log M\rceil$ bits naming $j$. It outputs an index of the deterministic function $f_j$ (undefined on longer inputs). By closure under prefix-free simulation it is a member of the class. Its length is $|\sigma|+k+\sum(2\log(\cdot+1)+1)+\lceil\log M\rceil$, with $\lceil\log M\rceil\le R+4+\log n+\log(d+1+\log|Y|)$. ∎

[computed: i5(A): on four tiny instances (up to 7 inputs and 280 candidate data sets), random families of the lemma's size $M$ (193 to 3073) covered $\mathcal D_R$ in 400 of 400 trials. Families of size 16–64 already covered with probability at least 1/2, so the union bound is loose by a factor 10–50. i5(B): the overhead is 65 bits at $n=10^3,d=20$; 122 bits at $n=10^6,d=100$; 233 bits at $n=10^{12},d=1000$. The total-weight cost of `lem:split:stream` at the same sizes is 5.6–7.2 bits.]

**Proposition 5.3 (what the λ = 1 MAP is) [proved; (d) from Paper 2].**
* **(a)** In the per-query i.i.d. setting the 1-MAP is eventually in $E^*$ almost surely (Thm 3.1). It is *not* a fill-in forever. The brief's "λ = 1 never makes the split exact" is **[refuted]** as an asymptotic statement about the MAP.
* **(b)** On any data set, if the 1-MAP $\hat\pi$ is a fill-in (deterministic and consistent), then
  $$S-\delta^*\ \le\ \ell(\hat\pi)\ \le\ \ell^*+S,\qquad S=-\log\nu(D):$$
  its length is about the sampled randomness. The lower bound is Ville (Lemma 2.2); the upper bound is $J_1(\hat\pi)\le J_1(\pi_0)$.
* **(c)** On distinct inputs, in $\Hcl{\times}$, the best single fill-in $\varphi$ satisfies
  $$-\ell^*-\delta^*\ \le\ J_1(\varphi)-J_1(\pi_\nu)\ \le\ 3\log(n+1)+3\log(d+2+\log|Y|)+2\log(R+1)+\kappa$$
  (Lemma 2.2; Lemma 5.2). So at λ = 1 the sampler and the best fill-in are tied up to $\ell^*+\delta^*$ bits one way and $O(\log nd+\log S)$ the other. Which one is the 1-MAP at a given $n$ depends on these terms, that is on the reference machine. In $\mathcal C_k$ it is a fill-in for $n$ up to about $2^{(k-8)/2}$ (Prop 5.1).
* **(d)** The posterior mass of fill-ins at λ = 1 is at least $2^{-\ell^*-2\log(t_n+1)-\kappa-\delta^*}$ while the inputs are distinct (`thm:split:lambda1`(ii)). In the per-query i.i.d. setting it tends to 0 almost surely (Thm 3.2). Since $t_n\approx\log(2d_n)$, it decays no faster than about $(\log d_n)^{-2}$ in the input length. At λ > 1 it decays like $2^{-(\lambda-1)S_n}$ (Thm 4.1(iii)). With fresh noise on an atomic μ, deterministic fill-ins die at the first repeated input whose labels disagree.

So the honest contrast is quantitative, and large:

| | λ = 1 | λ > 1 |
|---|---|---|
| MAP in $E^*$ eventually (per-query, i.i.d.) | yes, a.s. (Thm 3.1) | yes, a.s. (Thm 3.1) |
| MAP length bound, all $n$ | only $\Prob[\exists n:\ell>L]\le2^{\ell^*}t_L$ (class tail) | $\ell^*+(\ell^*+\delta^*)/(\lambda-1)$ |
| recovery time under a uniform margin | unbounded in $(\ell^*,\gamma,\varepsilon)$ (Prop 5.1) | $n(\lambda,\ell^*,\gamma,\varepsilon)=O(\lambda\ell^*/(\min(1,\lambda-1)\gamma))$ |
| fill-ins' posterior | $\ge2^{-\ell^*-O(\log\log d_n)-\delta^*}$ while distinct; → 0 | $\le2^{\lambda\ell^*+\lambda\delta^*-(\lambda-1)S_n}$ |
| best single fill-in vs sampler | tie up to $\ell^*+\delta^*$ and $O(\log nd)$ | fill-in loses once $(\lambda-1)S_n>\lambda(\ell^*+\delta^*)$ |

---

## 6. Corollaries

**Corollary 6.1 (noisy computable functions) [proved; computed: i4].**
* *Setting.* $Y=\{0,1\}$; $f:X\to\{0,1\}$ total computable; $p\in[0,\frac12)$ computable; $\nu_{f,p}(y\mid x):=1-p$ if $y=f(x)$, else $p$. Data are per-query i.i.d. (a noisy oracle that redraws its flip at each query), or distinct inputs. $\mathcal C$ is any countable class with Kraft weights containing a program for $\nu_{f,p}$.
* **(i) The selected model.** π ∈ E iff $\nu_\pi(1\mid x)=p+(1-2p)g(x)$ μ-a.e. for some $g$ with $g=f$ μ-a.e.
  * Such a kernel determines $f$ μ-a.e., as its more likely label, and $p$, as its smaller probability.
  * So, by Thm 3.1, for every schedule $1\le\lambda_n=o(n)$, almost surely every $\lambda_n$-MAP is eventually a shortest program in $\mathcal C$ whose kernel is "$f$ (up to μ-null sets) with flips at rate exactly $p$".
  * The noise rate, a real number, is identified **exactly**, not approximately.
  * The flips $\{i:y_i\ne f(x_i)\}$ are the noise: they are not part of the selected model.
* **(ii) Fill-ins.** For fixed λ > 1, every fill-in, including "f plus the list of flipped queries", has posterior mass at most $2^{\lambda\ell^*+\lambda\delta^*-(\lambda-1)S_n}$, with $S_n/n\to H(p)$ (Thm 4.1(iii)).
* **(iii) Margins.** A competitor $\nu_{g,q}$ has gap $\gamma=\mu(g\ne f)\,h_{\ne}(p,q)+\mu(g=f)\,h_=(p,q)$, where
  $$h_=(p,q)=1-\sqrt{pq}-\sqrt{(1-p)(1-q)},\qquad h_{\ne}(p,q)=1-\sqrt{p(1-q)}-\sqrt{(1-p)q}.$$
  Rate competitors ($g=f$, $q\ne p$) have the smallest gaps.
* **(iv) Degenerate cases.** If $p=\frac12$, ν is the coin, $f$ is not identifiable, and the selected model is a shortest coin. If $p=0$, $E$ is the set of programs computing $f$ μ-a.e. (Paper 1's deterministic case).
* **(v) Canonical class.** In $\Hcl{\times}$ the exact identification of $p$ holds almost surely, but by Prop 4.3 no computable sample size follows from Thm 4.1(iv).

[computed: i4]
* *The class.* Inputs uniform on $\{0,1\}^6$, fresh flips. Parities $a$ with rates $q$ from an 8-element list with a prefix code, plus a coin; 513 programs, Kraft sum 0.625.
* *Truth and competitors.* The truth is $(a^*,1/8)$, with $\ell^*=10$. The competitors $(a^*,0)$ and $(a^*,1/4)$ are shorter (9 bits).
* *Margin.* γ = 0.003736, attained by the rate 3/16 ($=h_=(1/8,3/16)$). A wrong parity has gap at least 0.090.
* *Sample sizes.* $n(\lambda,\ell^*,\gamma,\varepsilon)=2843$ at λ = 2, ε = 0.05; 4264 at λ = 1.5; 5686 at λ = 4.
* *Simulation* (2000 runs). $\Prob[\text{MAP}\ne\text{truth}]$ is 0.054 at $n=200$, 0.014 at 400 and 0 at 800 for λ = 2. The Rényi bound is 0.41, 0.11 and 0.017 there; the margin bound is below 1 only from $n=3200$ (0.0066). At λ = 1: 0.092, 0.026, 0.002 at $n=200,400,800$.

**Corollary 6.2 (subclasses) [proved].**
* Theorems 3.1, 3.2 and 4.1 use only countability, the Kraft inequality and (for $E\ne\emptyset$) the presence of the sampler. They therefore hold in every time-bounded product class, every circuit class with private output noise, and every finite class.
* "Shortest" refers to the subclass's own code. A time-bounded class may select a longer but faster program than $\Hcl{\times}$ would.
* If ν has no program in the subclass, §7.4 applies.
* For a finite input set (circuits on $\{0,1\}^d$) inputs repeat, so the per-query object is the one for which recovery holds (§7.5).
* For finite classes, and for parametric classes whose rates lie on a known grid, $\gamma_L$ is computable, and Thm 4.1(iv) gives an explicit sample size (Cor 6.1, i4).

---

## 7. What fails

### 7.1 Shared randomness

**Proposition 7.1 [proved, from Paper 2].** Let the class satisfy (Dom): it contains a member $U$ of length $\ell_U$ with $P_\pi\le2^{\ell(\pi)+\kappa_0}U$ for all π. Examples are SFI's machine-law class with $U=\MF$, the chronological class with $U=\MH$, and SI.
* For every λ > 1 and every observation, every λ-MAP has length at most $L_\lambda=(\lambda\ell_U+\kappa_0)/(\lambda-1)$ (`thm:absorb:absorption`(a)).
* So if $\ell^*>L_\lambda$, no λ-MAP is ever a program for ν, whatever $n$, the input law or the noise model: exact recovery fails for every fixed λ > 1 (`thm:split:shared`).
* For fresh per-query noise, the relevant shared class is the chronological class $\Hcl{\mathrm{chr}}$, where (Dom) holds with $U=\MH$ (`thm:split:shared`). The per-query mixture $\Mpq$ is one of its members (Paper 1, `prop:hist:operator`).

*Proof.* The cited theorems. ∎

* The per-query mixture $\Mpq$ is a shared object (one mixture), but its *terms* are product kernels. Exact recovery needs the class to consist of the terms, not to contain the mixture.

### 7.2 λ → 1 and λ ∝ n

* *Fixed λ ↓ 1.* The guarantees of Thm 4.1 degrade like $1/(\lambda-1)$, and this is necessary (Prop 4.4(b)).
* *λ = 1.* The limit statement survives (Thm 3.1), but no recovery-time bound does (Prop 5.1).
* *λ = cn.* Exact recovery fails (Prop 3.4).
* *$\lambda_n\to\infty$ with $\lambda_n=o(n)$.* Exact recovery holds (Thm 3.1). Moreover the length bound of Thm 4.1(i), $\ell^*+(\ell^*+\delta^*)/(\lambda_n-1)$, tends to $\ell^*$, so eventually no MAP is longer than $\ell^*$ [proved: Thm 4.1(i) holds at each $n$ with $\lambda=\lambda_n$, since δ* does not depend on λ].

### 7.3 Non-i.i.d. and adaptive inputs

**Proposition 7.2 [(a) from Paper 2; (b) proved; computed: i3(D)].**
* **(a) What survives.** For any input rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn (adaptive, randomised, non-computable), with distinct inputs or fresh labels:
  * `thm:split:private`(i)–(iii) and Thm 4.1(i)–(iii) hold (Lemma 2.2(c));
  * every λ-MAP is eventually ν-equivalent **on the run**, i.e. $\sum_n\Hel(\nu(\cdot\mid x_n),\nu_\pi(\cdot\mid x_n))<\infty$ (`thm:split:private`(iv)).
* **(b) What fails.**
  * *The example.* Inputs $x_j=0^j$, a fixed non-i.i.d. sequence. The truth is $\nu(1\mid0^j)=\frac12+2^{-j/2-2}$, with a program of length $\ell^*$. The class also contains the coin, of length $\ell^*-\Delta$.
  * *The coin is ν-equivalent on the run.* $\sum_j\Hel(\nu(\cdot\mid0^j),\text{coin})<\infty$, although the coin differs from ν at **every** queried input.
  * *The claim.* In the class {truth, coin}, with positive probability the λ-MAP is the coin for all large $n$.
  * *Proof.* $\Lambda_n(\text{coin})$ is a product of independent positive factors with mean 1 and $\sum\Hel<\infty$. By Kakutani's theorem it converges in $L^1$ to $\Lambda_\infty>0$ with $\Ex\Lambda_\infty=1$ [known: Kakutani 1948]. So $\Prob[\Lambda_\infty\ge1]>0$. On $\{\Lambda_\infty>2^{-\lambda\Delta}\}$ the coin's $J$ is eventually below the truth's.
  * *With i.i.d. inputs* this cannot happen. Every set of positive μ-measure on which two kernels differ is visited at a linear rate, so Lemma 2.1(b) applies.
  * [computed: i3(D): λ = 2, Δ = 3; $\sum_j\Hel=0.032$; in 2000 of 2000 runs the MAP at $n=4000$ is the coin.]
* **(c) Reading.** With adaptive inputs there is no μ, and "exact recovery" has no target beyond the run. An input rule that avoids the inputs where a shorter program errs keeps that program selected. That is the correct answer to the questions asked, not a failure of the split: the selected program is still a sampler, not a fill-in (Thm 4.1(iii)).

### 7.4 Misspecification

Let ν have no program in $\mathcal C$: $E=\emptyset$. Put $D(\pi):=\Ex_{\mu\otimes\nu}\log(\nu/\nu_\pi)\in(0,\infty]$, $D^*:=\inf_\pi D(\pi)$, and let $P:=\{\pi:D(\pi)=D^*\}$ be the set of KL-projections, possibly empty. Lemma 2.2 holds unchanged; only Lemma 2.1's "iff π ∉ E" becomes "always".

**Brief's conjecture (T1, "what fails"): the λ-MAP is eventually a shortest program among the KL-projections onto $\mathcal C$.** **[refuted twice: (ii) and (iii)]**; true under the conditions of (i).

**Proposition 7.3 [proved; computed: i3(A), i3(B)].** Per-query i.i.d. data, $1\le\lambda_n=o(n)$ or fixed λ ≥ 1.
* **(i) Positive case.** If $\mathcal C$ is finite, $D^*<\infty$, and all KL-projections have the same kernel μ-a.e., then almost surely every MAP is eventually a shortest element of $P$.
* **(ii) Two projections: oscillation.**
  * *Claim.* Let $\pi_1,\pi_2\in P$ with $\ell(\pi_1)<\ell(\pi_2)$, $\Ex|\log(\nu_{\pi_2}/\nu_{\pi_1})|<\infty$, and $\log(\nu_{\pi_2}(y\mid x)/\nu_{\pi_1}(y\mid x))$ not a.s. zero under $\mu\otimes\nu$. Then in $\mathcal C=\{\pi_1,\pi_2\}$, for every fixed λ ≥ 1, almost surely $\pi_2$ is the unique λ-MAP for infinitely many $n$, and $\pi_1$ for infinitely many $n$.
  * *Example.* Truth: fair-coin labels; $\pi_1$ = Bern(1/4), $\ell=2$; $\pi_2$ = Bern(3/4), $\ell=5$. Both have $D=\frac12\log\frac43$.
* **(iii) Fill-ins beat the projection when λ is small.**
  * *Setting.* Let $\mathcal C$ be the class of deterministic programs (the class of $W$) plus one coin program of length $\ell_c$. Let ν = $f\oplus\Bern(p)$ with $f$ computable and $p\in(0,\frac12)$ computable, so ν ∉ $\mathcal C$. The coin is the unique KL-projection, for every input law: deterministic programs have $D=\infty$. Take distinct inputs (non-atomic μ, or the frozen data set of an infinite-support μ, counted in distinct inputs $m_n\to\infty$) with $\log d_n=o(m_n)$.
  * *If $\lambda H(p)<1$:* almost surely every λ-MAP is a fill-in for all large $n$.
  * *If $\lambda H(p)>1$:* almost surely the unique λ-MAP is the coin for all large $n$.
* **(iv) No projection.** If $D^*<\infty$ is not attained, then almost surely the length of every MAP tends to ∞.

*Proof.*
* (i)
  * Fix $\pi_P\in P$. For π ∉ P, $\frac1n\log(L_n(\pi)/L_n(\pi_P))\to D^*-D(\pi)\in[-\infty,0)$ a.s. This is the strong law for the difference of $\log(\nu_\pi/\nu)$, whose positive part is integrable, and $\log(\nu_{\pi_P}/\nu)$, which is integrable since $D^*<\infty$ (Lemma 2.1(b)).
  * The length penalty differs by $o(n)$. So eventually no π ∉ P is a MAP.
  * Elements of P have a.s. equal likelihoods (same kernel μ-a.e.), so the shortest win.
* (ii)
  * $S_n:=\log(L_n(\pi_2)/L_n(\pi_1))$ is a random walk with i.i.d. integrable increments of mean $D(\pi_1)-D(\pi_2)=0$, not a.s. zero.
  * Such a walk has $\limsup S_n=+\infty$ and $\liminf S_n=-\infty$ a.s. [known: e.g. Durrett, the theorem on the possible behaviours of a one-dimensional random walk (number unverified)].
  * $\pi_2$ is the unique MAP iff $S_n>\lambda(\ell(\pi_2)-\ell(\pi_1))$, and $\pi_1$ iff $S_n<\lambda(\ell(\pi_2)-\ell(\pi_1))$.
* (iii)
  * *Sampled randomness.* On distinct inputs the flips are i.i.d. Bern(p), so $S:=-\log\nu(D_n)$ satisfies $S/m_n\to H(p)$ a.s.
  * *Which programs compete.* The coin has $J=\lambda\ell_c+m_n$. Every other program with finite $J$ is a consistent deterministic program, a fill-in.
  * *Small λ.* By Lemma 5.2, applied in $W$'s class with ν's program as the decoder, a fill-in of length $K(\nu)+S+O(\log m_n+\log d_n+\log S)+\kappa$ exists. If $\lambda H(p)<1$, then $\lambda(K(\nu)+S+o(m_n))<\lambda\ell_c+m_n$ eventually.
  * *Large λ.* Every fill-in has $\ell\ge S-\delta^*$ (Lemma 2.2, with $\mathcal C$'s mixture and the true ν in the denominator). If $\lambda H(p)>1$, then $\lambda(S-\delta^*)>\lambda\ell_c+m_n$ eventually, since δ* < ∞ a.s.
* (iv)
  * For each $L$, $d_L:=\min_{\ell(\pi)\le L}D(\pi)>D^*$. Pick π′ with $D(\pi')<d_L$.
  * For each π with $\ell(\pi)\le L$, $\frac1n[J(\pi)-J(\pi')]\to D(\pi)-D(\pi')>0$ (strong law as in (i), with $D(\pi')<\infty$).
  * So eventually no program of length at most $L$ is a MAP. ∎

[computed: i3(A): 20 runs of $10^6$ samples, λ = 2. In 17 of 20 runs the MAP switched after $n=10^5$; for example run 0 switched 1251 times, the last at $n=814{,}744$. The other three runs had their last switch before $n=25{,}000$, consistent with the heavy-tailed return times of a recurrent walk.]

[computed: i3(B): $p=0.1$, $1/H(p)=2.13$, input length 64, κ = 0 in Lemma 5.2's bound (an illustration). The MAP is a fill-in for all $n\ge534$ (λ = 1.5) and $n\ge4404$ (λ = 2). It is the coin for all $n\ge242$ (λ = 2.3) and $n\ge91$ (λ = 3), using the rigorous fill-in lower bound with δ* = 5. $n\le2\cdot10^5$.]

*Readings.*
* (ii) needs two projections with *different* kernels. With a unique projection kernel the oscillation disappears.
* (iii) is the misspecified version of the teacher's-mistakes phenomenon. When no model in the class explains the noise, the cheapest explanation of the noise is to memorise it, unless λ exceeds the inverse noise entropy.
* With fresh per-query noise on an atomic μ, fill-ins die at conflicting repeats. Then (iii)'s first alternative does not occur: the coin is eventually the MAP for every λ ≥ 1 in that class.
* So the conjecture fails for two independent reasons: ties between projections, and fill-ins that are cheaper than any model.

**Conjecture 7.4 (misspecified selection).**
* *Setting.* Let $\mathcal C$ be closed under memorisation: with each model π and each data set $D$ on distinct inputs, it contains, for every region $A\subseteq X$ of finite complexity, a program that agrees with π off $A$ and reproduces $D$ on $A$, of length $\ell(\pi)+K(A)+S_A(D)+o(n)$, where $S_A(D):=-\log\nu(D|_A)$. Fix λ > 1 and use distinct inputs (non-atomic μ).
* *Conjecture.* The per-sample objective $J_\lambda(\hat\pi_n)/n$ of the λ-MAP converges a.s. to
  $$\inf_{\pi,A}\Big\{\lambda\,\Ex_\mu\big[H(\nu(\cdot\mid x));A\big]+\Ex_\mu\big[H(\nu(\cdot\mid x))+\KL(\nu(\cdot\mid x)\,\|\,\nu_\pi(\cdot\mid x));X\setminus A\big]\Big\}.$$
  The minimising region is $A^*=\{x:(\lambda-1)H(\nu(\cdot\mid x))<\KL(\nu(\cdot\mid x)\|\nu_\pi(\cdot\mid x))\}$: memorise where the model's excess loss exceeds $(\lambda-1)$ times the local entropy.
* *Evidence.* Prop 7.3(iii) is the case $A^*\in\{\emptyset,X\}$, with π the coin. The heuristic is the two-part code count; there is no proof.

### 7.5 Frozen noise, finite domains and repeats

**Proposition 7.5 (frozen noise: no procedure recovers every sampler) [proved].**
* *Setting.* The frozen object (Def 1.3). Let ν, ν′ be samplers that differ only at one input $x_0$ with $\mu(x_0)>0$, with $\nu(\cdot\mid x_0)$ and $\nu'(\cdot\mid x_0)$ mutually absolutely continuous and distinct.
* *Claim.* The laws $P_\nu$, $P_{\nu'}$ of the whole data process are mutually absolutely continuous. So for every estimator $(\hat\pi_n)$ with values in $\mathcal C$,
  $$P_\nu[\hat\pi_n\in E_\nu\text{ for all large }n]=1\ \Longrightarrow\ P_{\nu'}[\hat\pi_n\in E_{\nu'}\text{ for all large }n]=0.$$
* *In the canonical class.* Every computable ν with $\nu(y_0\mid x_0)\in(0,1)$ for some $x_0$ of positive mass and some $y_0$ has such a computable ν′: $\nu'(\cdot\mid x_0):=\frac12(\nu(\cdot\mid x_0)+\delta_{y_0})$. So no procedure, the λ-MAP for any λ included, achieves frozen exact recovery for all computable samplers with noise on the support of μ.

*Proof.*
* The data process is a measurable function of the input sequence and of $F$ restricted to the support of μ. The input sequence has the same law under both, independent of $F$.
* Under ν and ν′ the field $F$ has product laws that differ in the single factor at $x_0$. The density $\nu'(F(x_0)\mid x_0)/\nu(F(x_0)\mid x_0)$ lies in $(0,\infty)$ a.s., so the laws are mutually absolutely continuous.
* $E_\nu\cap E_{\nu'}=\emptyset$, since $\mu(x_0)>0$. If $A=\{\hat\pi_n\in E_\nu\text{ eventually}\}$ has $P_\nu(A)=1$, then $P_{\nu'}(A)=1$, and on $A$ the estimator is eventually outside $E_{\nu'}$. ∎

**Proposition 7.6 (what frozen noise does give) [proved; computed: i3(C)].** In the frozen object with i.i.d. inputs, the run of distinct inputs eventually enumerates the support of μ.
* (a) *The equivalence-on-the-run class.* Suppose $\mathrm{supp}\,\mu$ is infinite, and let $K:=\{\pi:\sum_{x\in\mathrm{supp}\,\mu}\Hel(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))<\infty\}$. For every fixed λ > 1, almost surely every λ-MAP is eventually in $K$, and $\Pi_\lambda(K\mid D_n)\to1$. This is `thm:split:private`(iv) with the run ordered by first appearance.
* (b) *Fill-ins leave in the limit.* $K\supseteq E$. Let $\beta_x:=1-\max_y\nu(y\mid x)$. If $\sum_{x\in\mathrm{supp}\,\mu}\beta_x=\infty$, no deterministic program is in $K$, and the posterior mass of all deterministic programs tends to 0 a.s.
* (c) *Finite support.* $D_n$ is eventually the fixed data set $D_\infty=F|_{\mathrm{supp}\,\mu}$. The MAP is eventually constant, a minimiser of $J_\lambda(\cdot;D_\infty)$: a single-data-set question, the subject of target T2. No identification of ν is possible (Prop 7.5).
* (d) *A concrete failure.*
  * *Setting.* $X=\{0,\dots,9\}$ with μ uniform. Truth Bern(1/64) at every input, with a program of length 5. Exception programs $e_j$: ν except $P(1\mid j)=1$, length 9.
  * *Frozen noise.* For $\lambda<1.5$ the λ-MAP is eventually some $e_j$ with probability exactly $1-(63/64)^{10}=0.1457$. An $e_j$ with $F(j)=1$ gains 6 bits for $4\lambda$ bits of length.
  * *Fresh noise.* The $e_j$ die at the first label 0 at $j$, and Thm 3.1 applies.
  * [computed: i3(C): $10^4$ runs, $n=2000$. Frozen: 0.1468 (λ = 1) and 0.1387 (λ = 1.25), 0 at λ = 1.75. Fresh: 0 for all three.]

*Proof.*
* (a) The cited theorem, whose proof needs only distinct inputs chosen before their labels.
* (b) A deterministic φ has $\Hel(\nu(\cdot\mid x),\delta_{\varphi(x)})=1-\sqrt{\nu(\varphi(x)\mid x)}\ge1-\sqrt{1-\beta_x}\ge\beta_x/2$ (and $=1$ where φ is undefined). That is not summable under the stated condition. The posterior part is Thm 3.2's argument with $K$ in place of $E$: $\Lambda_n(\pi)\to0$ for π ∉ K by the Kakutani-type step of `thm:split:private`(iv), and the tail is handled by Lemma 2.2.
* (c) Finitely many distinct inputs.
* (d) Direct. ∎

*Finite domains, summary.*
* With fresh noise, Thm 3.1 identifies ν on the support exactly, including for circuits on $\{0,1\}^d$.
* With frozen noise, no procedure identifies every sampler (Prop 7.5).
* With λ = cn, the population objective $c\ell+R$ selects the hull vertex at slope $c$ (Prop 3.4).
  * With frozen noise the population risk is taken against the frozen table $F$. That is the teacher's setting with $y^*=F$, whose minimisers depend on $F$, not on ν.

---

## 8. Link to target T2: a kink from the margin

**Lemma 8.1 (sampled data have a kink at ℓ*) [proved].**
* *Setting.* Per-query i.i.d. data (or distinct inputs). Let $\gamma_<:=\min\{\gamma(\pi):\ell(\pi)<\ell^*\}$; it is positive, since all programs shorter than $\ell^*$ are outside E.
* *The left side of the kink.* With probability at least $1-2^{\ell^*}e^{-\gamma_<n/2}$, every program with $\ell(\pi)<\ell^*$ has
  $$-\log L_n(\pi)\ \ge\ S_n+\gamma_<\,n\log e .$$
* *The right side.* For every program, $-\log L_n(\pi)\ge S_n-\ell(\pi)-\delta^*$, with $\Prob[\delta^*\ge j]\le2^{-j}$.
* *In terms of the class's structure function* $\rho_{\mathcal C}(\alpha):=\min\{-\log L_n(\pi):\ell(\pi)\le\alpha\}$:
  * $\rho_{\mathcal C}(\alpha)\ge S_n+\gamma_<n\log e$ for $\alpha<\ell^*$;
  * $\rho_{\mathcal C}(\ell^*)\le S_n$;
  * $\rho_{\mathcal C}(\alpha)\ge S_n-\alpha-\delta^*$ for all α.
* So the left slope at $\ell^*$ is at least $\gamma_<n\log e/\ell^*$, linear in $n$. To the right, each bit of length buys at most one bit of fit, plus δ* in total.

*Proof.* For π with $\ell(\pi)<\ell^*$: $\Prob[\Lambda_n(\pi)\ge2^{-t}]\le2^{t/2}\rho_{1/2}(\pi)^n\le2^{t/2}e^{-\gamma_<n}$ (Markov for $\Lambda^{1/2}$). Take $t=\gamma_<n\log e$, so that $2^{t/2}=e^{\gamma_<n/2}$. There are at most $2^{\ell^*}-1$ such programs (Kraft). The right side is Lemma 2.2(a). ∎

This is the bridge the brief asks for ("σ growing linearly in n under the margin condition"). The kink theorem itself, and its relation to Paper 2's $\rho^\times_D$, belong to the sub-track `../kink/`. Lemma 8.1 is stated for an arbitrary countable class $\mathcal C$ and its own structure function.

---

## 9. Claims and statuses

| # | claim | status |
|---|---|---|
| 1.4 | per-query object = data-set object on distinct inputs = stamped inputs with stamp-ignoring programs | proved |
| 2.1 | likelihood-ratio facts; $\rho_s\le\rho_{1/2}^{2\min(s,1-s)}$ | proved; computed i1(B) |
| 2.2 | Ville deficiency for per-query likelihoods, adaptive inputs, repeats, misspecification | proved; computed i6 |
| 3.1 | every $1\le\lambda_n=o(n)$: MAPs $=E^*$ eventually a.s. (λ = 1 included) | proved; computed i1, i2, i4 |
| 3.1-rem | the λ = 1 i.i.d. density case is Barron–Cover's consistency | known (secondary source; unverified) |
| 3.2 | $\Pi_\lambda$, $\Pi^\eta$ concentrate on $E$; limit share of $E^*$ is $w_\lambda$ (tempered: $w_1$) | proved; computed i1(C) |
| 3.2-ref | "posteriors concentrate on $E^*$" | **refuted** (two programs for ν; i1(C)) |
| 3.4 | λ = cn: no recovery when a shorter program has $D<c\,\Delta$ | proved; computed i1(D) |
| 4.1(i)–(iii) | length bound, posterior length tail, fill-in bounds, all $n$ | proved (per-query form of `thm:split:private`) |
| 4.1(iv)–(vi) | finite-sample bound; $n(\lambda,\ell^*,\gamma,\varepsilon)$; uniform-in-time; posterior | proved; computed i1(A), i2(B), i4(B) |
| 4.1(vii) | tempered tail depends on the prior tail $t_L$ | proved |
| 4.3 | canonical class: $\gamma_L<g(L)$ for every computable $g$ | proved |
| 4.3-open | computable recovery-time bound in the canonical class | open |
| 4.4(a) | the 1/γ dependence is necessary (up to constants, λ ≥ 2) | proved |
| 4.4(b) | the 1/(λ−1) dependence is necessary | proved; computed i2 |
| 4.4(c) | λ > 1 delays recovery against shorter competitors | computed i1(A) (observation) |
| 5.1 | λ = 1: no recovery-time bound, even with a uniform margin; parity class $\approx2^{\ell^*/2}$ vs $\approx\lambda\ell^*/(\lambda-1)$ | proved; computed i2 |
| 5.2 | a single fill-in of length $k-\log\nu(D)+O(\log n+\log d+\log R)$ | proved; computed i5 |
| 5.3(a) | "λ = 1 never makes the split exact" (asymptotically, for the MAP) | **refuted** (Thm 3.1) |
| 5.3(b)–(d) | λ = 1 MAP: fill-in length ∈ $[S-\delta^*,\ell^*+S]$; tie up to $\ell^*+\delta^*$ and $O(\log)$; fill-in mass $\ge2^{-\ell^*-O(\log\log)}$ while distinct, → 0 | proved |
| 6.1 | noisy computable functions: $f$ (μ-a.e.) and the exact rate $p$ are selected; flips are noise | proved; computed i4 |
| 6.2 | every countable subclass (time-bounded, circuits, finite) | proved |
| 7.1 | shared randomness: no recovery once $\ell^*>L_\lambda$ | proved (Paper 2) |
| 7.2 | non-i.i.d. inputs: only "on the run" survives; a shorter program wrong at every queried input can be the eventual MAP | proved; computed i3(D) |
| 7.3(i) | misspecified, finite class, unique projection kernel: shortest projection | proved |
| 7.3(ii) | two projections with different kernels: oscillation forever | proved; computed i3(A) |
| 7.3(iii) | fill-ins beat the projection iff $\lambda H(p)<1$ | proved; computed i3(B) (κ = 0 illustration) |
| 7.3(iv) | no projection: MAP length → ∞ | proved |
| KL-proj. | "λ-MAP eventually a shortest KL-projection" (brief) | **refuted** in general (7.3(ii),(iii)); true under 7.3(i) |
| 7.4 | misspecified selection memorises where $(\lambda-1)H_x<\KL_x$ | conjecture |
| 7.5 | frozen noise: no procedure recovers exactly | proved |
| 7.6 | frozen noise: equivalence on the support (Kakutani class); concrete failure probability 0.1457 | proved; computed i3(C) |
| 8.1 | sampled data have a drop of $\ge\gamma_<n\log e$ bits at $\alpha=\ell^*$ | proved |

---

## References

* A. R. Barron, T. M. Cover, "Minimum complexity density estimation", *IEEE Trans. Inform. Theory* 37(4):1034–1054, 1991 [bibliographic data verified by search; the consistency statement is known only through a secondary source, below; content unverified].
* J. Poland, M. Hutter, "Asymptotics of discrete MDL for online prediction", *IEEE Trans. Inform. Theory* 51(11):3780–3795, 2005; arXiv cs/0506022. A search snippet states: "If the data is generated by an i.i.d. process, then the MDL estimates are consistent [BC91]" [snippet].
* S. Kakutani, "On equivalence of infinite product measures", *Ann. Math.* 49:214–224, 1948 [as cited by Paper 2; not re-checked].
* J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars, 1939 [as cited by Paper 2].
* R. Durrett, *Probability: Theory and Examples* (strong law with $\Ex X^-=\infty$; recurrence of one-dimensional mean-zero random walks) [standard; edition and theorem numbers unverified].
* Paper 1 (`paper/`): `prop:learn:perquery`, `prop:learn:freshnoise`, `def:versions:variants`, `prop:hist:operator`. Paper 2 (`paper-steeper/`): `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `thm:split:shared`, `lem:split:stream`, `thm:absorb:absorption`, `lem:setup:hull`.

---

## Verification log

*Run 2026-10-13. Python 3.11.15, numpy 2.4.6, scipy 1.17.1. Every script was run from `checks/`; its output is the `.out` file of the same name.*

* **i1_exact_small_class** (deterministic). Exact enumeration over all count vectors up to $n=400$ (10.9 million vectors at $n=400$), 8 programs, two inputs.
  * Kraft sum 0.633.
  * (A) At all 50 (λ, n) rows the order exact ≤ Rényi bound ≤ margin bound holds; the script flags any violation and printed none.
  * (B) Hölder inequality: largest violation $2.2\cdot10^{-16}$ (rounding). $\Ex\Lambda_6^s=\rho_s^6$ to $1.7\cdot10^{-15}$.
  * (C) Posterior limits reached at $n=400$: 0.8000, 0.8889, 0.9412 against $w_1,w_{1.5},w_2$.
  * (D) $c^*=0.1348$; the population minimiser switches from the truth to the coin between $c=0.1$ and $c=0.2$.
  * Runtime about 2 minutes.
* **i2_parity_fillins** (deterministic except (C), seed 2).
  * (D) The truncated rank chain (window 120) agrees with the full chain to $5.6\cdot10^{-16}$ for $n<40$, $m<60$.
  * Monte Carlo (20000 runs) agrees with the exact values to within 0.004 at all 12 (λ, n) points.
  * The recovery-time table of Prop 5.1 is copied from the output.
* **i3_failures** (seed 3). (A)–(D) as quoted in Props 7.2, 7.3 and 7.6.
  * The exact value $1-(63/64)^{10}=0.1457$ matches the frozen simulations, 0.1468 and 0.1387 (standard error 0.0035; the second is 2σ low).
  * Run 0's statistics quoted in §7.4 come from the saved output.
* **i4_noisy_parity** (seed 4).
  * The margin found by search over the class (0.003736) equals the closed form $h_=(1/8,3/16)$.
  * The empirical failure frequencies lie below the Rényi bound wherever that bound is below 1.
* **i5_single_fillin** (seed 5). 400/400 coverage at the lemma's $M$ in all four tiny instances.
* **i6_perquery_ville** (seed 6). Ville tail below $2^{-j}$ at all five $j$. Zero violations of the length bound over 4000 paths × 3 values of λ × 3000 steps.
* **Proof checks done by the author of these notes.**
  * Every inequality in Thm 4.1 was rechecked against the exact enumeration of i1 (bounds above exact values).
  * Prop 4.4(a)'s constants were derived twice (mean bound, variance bound, Taylor sign argument).
  * Lemma 5.2's length count was redone term by term.
  * Prop 7.3(iii)'s threshold was confirmed numerically in i3(B) on both sides.
  * No independent referee has read these notes yet.
* **Literature.** Two web searches for Barron & Cover's exact consistency statement found only the bibliographic data and a secondary statement (Poland–Hutter). The statement "two-part MDL with λ = 1 equals the true density eventually a.s." is therefore marked known-unverified. The proof given here (Thm 3.1) does not depend on it.
* **Reproducibility.** After all scripts were final, i1, i3, i4, i5 and i6 were rerun into a scratch directory, and each reproduced its saved output byte for byte. i2 was rerun after part (D) was added, and its parts (A)–(C) were identical to the previous run.
* **Repository.** No git command was run. All files written are under `research/tracks/split/iid/`.
