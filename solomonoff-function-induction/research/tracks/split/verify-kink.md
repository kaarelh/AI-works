# Track "split": independent check of the post-referee kink results

*Independent verification, 2026-10-13, of the results of `kink/notes-final.md` that the synthesis (`notes-final.md` §5.0) puts in Paper 2's main text and that no referee has read in their final form. Each statement was compared with its proof (hypotheses, quantifiers, constants), and each proof was re-derived. Every numerical claim was recomputed with new code in `kink/verify_code/`, which shares no code with `kink/checks/` or `kink/referee_code/`. The records were not edited.*

* **Sources read.**
  * `kink/notes-final.md`, in full.
  * The synthesis `notes-final.md`: §0, §2.2–§2.4 (Theorems B–D as the paper will state them), §5.0, §8; and `final-check.md`.
  * `iid/notes-final.md`: Defs 1.1–1.3, Remark 1.4, Lemmas 2.1–2.2, Thm 3.1 with its proof, Thm 4.1(i). Cor 5.7(c), (d) rest on these.
  * Paper 2, current sources:
    * from `teacher.tex`: `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:twopart` (D1);
    * from `app-teacher.tex`: `lem:teacher:sharpfloor`, statement and proof;
    * from `absorb.tex`: `thm:absorb:absorption`.
  * `kink/checks/k7_parity_certified.py` and `k8_small_fixes.py`, only to locate the discrepancies of §4.2; none of their code was reused.
  * `research/paper-review/DECISIONS.md`: the rendering of statuses and the rounding rule.
* **Files written.**
  * This file.
  * `kink/verify_code/v1_hull_kinks.py`, `v2_pq_exact.py`, `v3_pq_eventual.py`, `v4_parity_range.py`, each with its `.out`.

Numbers in brackets, such as v2(4), point to a script and the part of its output.

---

## 1. Verdicts

| item (`kink/notes-final.md`) | verdict | in one line |
|---|---|---|
| Lemma 5.1, (pq) | **verified** | $\mathbb E\sqrt{\Lambda_n}=(1-\gamma)^n$ exactly; $\mathbb E[\Lambda_n\mid\text{inputs}]\le1$; $\Lambda_n=1$ a.s. on $E$ |
| Lemma 5.2, (pq) | **verified** | Markov on $\sqrt\Lambda$ plus a Kraft union bound; the inequality is strict, as stated |
| Lemma 5.3(a) | **verified** | |
| Lemma 5.3(b) | **verified** (notation fix for the paper) | in the record $L_n(\nu)$ in δ* is a *likelihood*; in the synthesis $L_n$ is a *fit*. Write $\delta^*:=\sup_n\log(\xi_{\mathcal C}(h_n)/\nu(h_n))$ |
| Thm 5.4(i), (ii), (iii), (pq) | **verified** | constants, the condition $A\ge2\ell^*$ and the probabilities $1-\varepsilon$, $1-\varepsilon$ and $1-2\varepsilon$ are right |
| Cor 5.5, (pq) | **verified** | |
| Cor 5.7(c) | **verified** | (a) and (b) were re-derived too: verified |
| Cor 5.7(d) | **verified** | uses `iid` Thm 3.1 at $\lambda_n\equiv1$; that proof was re-read and holds at λ = 1 |
| Prop 4.2(ii) | **verified** (statement and proof). The ranges quoted with it are **verified with correction** | the proof uses three facts it does not state; all three hold (§4.1). 10 of the 17 printed ranges are not certified as printed (§4.2) |
| Prop 4.2(i)(g) | **verified** (statement and proof). Its quoted numbers are **verified with correction** | five of the nine numbers of §4(b) are rounded the wrong way (§4.3) |
| Prop 3.5(ii) | **verified with a minor correction** | "exactly when λ ≥ 1 + ε" needs $\ell_U+\kappa_0>0$ (§5) |
| Remark 3.2′ | **verified** | |

No item is "not verified". All corrections concern printed numbers or one clause. No mathematical statement planned for the main text needs to be weakened.

---

## 2. Scheme (pq): Lemmas 5.1–5.3, Theorem 5.4, Corollary 5.5

**Setting.** The setting is kink Setting 5.0 (pq), which is `iid` Def 1.1. Pairs are i.i.d. from $\mu\otimes\nu$ on a countable $X$, with a fresh label at every query. The class is countable with $\sum2^{-\ell}\le1$, so it has finitely many programs per length. The proofs need only $E\ne\emptyset$; they never need a program equal to ν at every input:
* $S_n$ is defined from ν itself;
* Lemma 5.3 uses only $\xi_{\mathcal C}/\nu$;
* Thm 5.4 uses only $E^*$.

So the synthesis's "setting of Theorem A" (`iid` Defs 1.1–1.2) suffices for Theorem C.

### 2.1 Lemma 5.1 (pq)

**Re-derivation.**
* Given the inputs, the labels are independent with $y_i\sim\nu(\cdot\mid x_i)$, and a.s. $\nu(y_i\mid x_i)>0$.
* So $\mathbb E[\sqrt{\Lambda_n}\mid x_{1:n}]=\prod_i\sum_{y:\nu>0}\sqrt{\nu\nu_\pi}(y\mid x_i)=\prod_i(1-\mathrm{Hel}_{x_i})$. Since the inputs are i.i.d., $\mathbb E\sqrt{\Lambda_n}=(1-\gamma)^n\le e^{-n\gamma}$.
* $\mathrm{Hel}_x\in[0,1]$ by Cauchy–Schwarz, using $\sum_y\nu_\pi\le1$.
* $\mathbb E[\Lambda_n\mid x_{1:n}]=\prod_i\sum_{y:\nu>0}\nu_\pi(y\mid x_i)\le1$.
* Equivalence means $\mathrm{Hel}_x=0$ at every atom of μ. A.s. every query falls on an atom and draws a label of positive ν-probability, so $\Lambda_n=1$ for every $n$ and every π ∈ E simultaneously (countably many null sets).

**Computed** [v2(1)]. Class B: 19 programs, Kraft sum 0.8906. It has two shortest equivalent programs that differ from ν only at an input of μ-mass 0; one of them is a sub-probability there.
* Exact sums over all count vectors for $n\le8$ give $\max|\mathbb E\sqrt{\Lambda_n}-(1-\gamma)^n|=1.8\cdot10^{-15}$ and $\max\mathbb E\Lambda_n=1.000000$.
* $\Lambda_n=1$ for the three equivalent programs on every sample (asserted).

### 2.2 Lemma 5.2

**Re-derivation.**
* Let $a(\pi)=2\log e\cdot n\gamma(\pi)-2\ell(\pi)-2\log(1/\varepsilon)$.
* Then $\Pr[\Lambda\ge2^{-a}]=\Pr[\sqrt\Lambda\ge2^{-a/2}]\le2^{a/2}e^{-n\gamma}=2^{a/2-\log e\cdot n\gamma}=\varepsilon2^{-\ell(\pi)}$.
* The union over π costs at most $\varepsilon\sum2^{-\ell}\le\varepsilon$.
* On the complement, $S-F<-a$, which is the strict inequality stated. Programs with $F=\infty$ satisfy it trivially.

**Computed** [v2(2)]. Exact failure probabilities:
* class B, $n\in\{2,4,8,12,16\}$, $\varepsilon\in\{0.9,0.5,0.2,0.05\}$: at most $0.067$ against ε = 0.9, and $0.0023$ against ε = 0.05;
* 40 random classes with zeros and sub-probabilities, 480 (class, $n$, ε) cases: the largest ratio of the failure probability to ε is 0.109.

### 2.3 Lemma 5.3

* **(a).**
  * By Tonelli and Lemma 5.1, $\mathbb E[\xi_{\mathcal C}/\nu]=\sum2^{-\ell}\mathbb E\Lambda\le1$.
  * By Markov's inequality, $\Pr[\xi/\nu\ge1/\varepsilon]\le\varepsilon$.
  * On the complement, $2^{-\ell}\Lambda\le\xi/\nu<1/\varepsilon$, that is, $F>S-\ell-\log(1/\varepsilon)$. Strict, as stated.
* **(b).**
  * $\xi(h_n)/\nu(h_n)$ is a nonnegative supermartingale, by the one-step bound of Lemma 5.1. It starts at $\sum2^{-\ell}\le1$.
  * Ville's maximal inequality gives $\Pr[\delta^*\ge j]\le2^{-j}$ for every $j\ge0$.
  * $2^{-\ell}\Lambda_n\le2^{\delta_n}\le2^{\delta^*}$ gives the non-strict bound, as stated.
  * Also $\delta^*\ge\delta_n\ge-\ell^*$ a.s., using a program of $E^*$. So the window $(\ell^*+\delta^*)/(\tau-1)$ of the synthesis's (C3) is nonnegative.
* **Notation.** The record writes $\delta^*:=\sup_n\log(\xi_{\mathcal C}(h_n)/L_n(\nu))$, with $L_n(\nu)$ a likelihood. The synthesis (§2.1) and `iid` Def 1.1 use $L_n$ for the *fit*, $-\log$ of the likelihood. The paper should write $\nu(h_n)$ or $2^{-L_n(\nu)}$.
* **Computed** [v2(3)]. Finite horizon, every path of length 7 in class B: $\Pr[\max_{m\le7}\delta_m\ge j]=0.156,\ 0.149,\ 0.031,\ 0.020,\ 0.015$ for $j=0.5,1,2,3,4$. Each is below $2^{-j}$.

### 2.4 Theorem 5.4 (pq)

* **(i).**
  * Every program shorter than $\ell^*$ is non-equivalent, so $\gamma(\pi)\ge\gamma_=(\ell(\pi))>0$, a minimum over finitely many positive numbers.
  * On the event of Lemma 5.2, $F-S_n>2\log e\cdot n\gamma_=(\ell)-2\ell-2\log(1/\varepsilon)\ge\sigma_n(\ell^*-\ell)$.
  * A program of $E^*$ has fit $S_n$ (a.s.), so $\rho(\ell^*)\le S_n$.
  * Def 3.1 needs $\sigma_n>0$, which the statement assumes. Lengths with no non-equivalent program contribute $+\infty$ to the minimum. For $\ell^*=0$ the steepness is ∞.
  * Second form: $(A-2\ell)/(\ell^*-\ell)\ge A/\ell^*$ is equivalent to $\ell(A-2\ell^*)\ge0$. So $A\ge2\ell^*$ is exactly what is needed, and then $A/\ell^*\ge2>0$.
  * The example $\ell^*=A=10$ gives $(10-18)/1=-8$ at $\ell=9$. Probability $1-\varepsilon$.
* **(ii).** On the event of Lemma 5.3(a), $F>S_n-(\ell-\ell^*)-(\ell^*+\log(1/\varepsilon))$. This is $\ge S_n-\tau(\ell-\ell^*)$ once $(\tau-1)(\ell-\ell^*)\ge\ell^*+\log(1/\varepsilon)$. The event does not depend on τ, so the statement holds for every τ > 1 at once, with probability $1-\varepsilon$.
* **(iii).**
  * *Flat part.* Every non-equivalent π with $\ell(\pi)\le\bar\ell$ has $\gamma(\pi)\ge\gamma_{\bar\ell}$. The hypothesis on $n$ makes $2\log e\cdot n\gamma_{\bar\ell}-2\bar\ell-2\log(1/\varepsilon)>0$.
  * *Secants.* Beyond the cap the secant is $<1+(\ell^*+\log(1/\varepsilon))/(\ell-\ell^*)\le\tau_{\bar\ell}$. It is strict, even for the supremum over infinitely many programs, because lengths are integers.
  * *Vertex.* With (i), $(\ell^*,S_n)$ is a zero-window $(\sigma_n,\tau_{\bar\ell})$-kink with $\tau_{\bar\ell}<\sigma_n$. Thm 3.2(d) makes it a vertex, and makes the λ-MAPs on $(\tau_{\bar\ell},\sigma_n)$ the programs at that point. By the flat part these are exactly $E^*$.
  * Probability $1-2\varepsilon$ (the events of Lemmas 5.2 and 5.3(a) and the a.s. event).
* **Computed** [v2(4)]. Class B, ε ∈ {1/2, 1/4}, $n\in\{8,\dots,36\}$.
  * On every count vector where both events hold, every conclusion of (i)–(iii) was asserted:
    * the left kink of steepness $\sigma_n$;
    * right kinks for τ ∈ {1.25, 2, 5};
    * the flat part and the secant bound for caps 4 and 5;
    * the λ-MAP set equal to $E^*$ at three λ in $(\tau_{\bar\ell},\sigma_n)$.
  * (iii) applies from $n=20$. The exact probability of its conclusion is at least 0.998, against the guarantee $1-2\varepsilon$.
  * Both shortest equivalent programs tie, as $E^*$ requires.

### 2.5 Corollary 5.5 (pq)

**Re-derivation.**
* *Length.* On the event of Lemma 5.3(a), a λ-MAP has $\lambda\ell+F\le\lambda\ell^*+S_n$ and $F>S_n-\ell-\log(1/\varepsilon)$. Hence $\ell<\bar\ell_\lambda$, strictly.
* *Short non-equivalent programs.* On the event of Lemma 5.2, a non-equivalent π with $\ell\le\bar\ell_\lambda$ has $J_\lambda(\pi)-J_\lambda(E^*)>(\lambda-2)\ell-\lambda\ell^*+2\log e\cdot n\gamma_{\bar\ell_\lambda}-2\log(1/\varepsilon)$. This is $>0$, using $(\lambda-2)\ell\ge-(2-\lambda)^+\bar\ell_\lambda$ (valid since $0\le\ell\le\bar\ell_\lambda$).
* *Long non-equivalent programs.* Those with $\ell>\bar\ell_\lambda$ have $J>S_n+(\lambda-1)\bar\ell_\lambda-\log(1/\varepsilon)=J(E^*)$.
* *Equivalent programs.* Those longer than $\ell^*$ lose $\lambda(\ell-\ell^*)$.
* So every program outside $E^*$ is strictly worse. MAPs exist (Thm 2.2(i)), and all of $E^*$ tie. Probability $1-2\varepsilon$.

**Computed** [v2(4)]. The hypothesis holds at λ = 3 from $n=20$ (ε = 1/2) and at λ = 4 from $n=24$. On both events the MAP set is $E^*$ on every count vector (asserted). The exact probability is at least 0.998.

---

## 3. Corollary 5.7 (pq): parts (c) and (d)

* **(c).**
  * *Length.* Lemma 5.3(b) and $J_\lambda(\hat\pi)\le J_\lambda(E^*)$ give $\ell(\hat\pi)\le\bar\ell^*=\ell^*+(\ell^*+\delta^*)/(\lambda-1)$, finite a.s.
  * *Borel–Cantelli.* Use Lemma 5.2 with $\varepsilon_n=n^{-2}$ for $n\ge2$; $\sum n^{-2}<\infty$. A.s. its event holds for all large $n$, simultaneously for all π.
  * *Short programs.* For the finitely many non-equivalent programs of length $\le\bar\ell^*$, $F-S_n>2\log e\cdot n\gamma_{\bar\ell^*}-2\bar\ell^*-4\log n\to\infty$. So their $J_\lambda$ exceeds $J_\lambda(E^*)$ eventually.
  * *Conclusion.* Equivalent programs longer than $\ell^*$ always lose. So eventually the MAP set is $E^*$, for each fixed λ > 1, a.s.
* **(a), (b)** (not requested; checked because the synthesis's (C5) quotes (a)).
  * (a) follows from the same event, divided by $n$.
  * (b) For each integer cap $\bar\ell>\ell^*$ the flat part holds eventually. Beyond the cap the secants are at most $1+(\ell^*+\delta^*)/(\bar\ell-\ell^*)$, using $\ell^*+\delta^*\ge0$ (§2.3). Intersect over countably many caps.
* **(d), the dependency.** `iid` Thm 3.1 with $\lambda_n\equiv1$, re-derived:
  * *Step 1.* It uses $\lambda_n\ge1$ only through $\log\Lambda_n(\hat\pi)\ge\ell(\hat\pi)-\ell_0$. The tail supermartingale $Z^L$ and $\Pr(B_L)\le2^{\ell_0}t_L\to0$ then give a pathwise length cap.
  * *Step 2.* It uses $\lambda_n=o(n)$ only for programs shorter than $\ell_0$. There the right side of (3.1) is the constant $-(\ell_0-\ell)$, and the left side is $\le-nD/2$ eventually by the strong law.
  * Programs in $E\setminus E_0$ violate (3.1) at every $n$.
  * The theorem holds at λ = 1. Its hypotheses (countable class, Kraft ≤ 1, $E\ne\emptyset$) are kink's (pq) setting.
* **(d), the deterministic step.**
  * The MAP set eventually equals $E^*$, and $E^*$ sits at the single point $(\ell^*,S_n)$.
  * By Thm 2.2(ii), a MAP set at one point cannot occur at a breakpoint $\lambda=\sigma_i$, where both ends of an edge are MAPs. So $1\in(\sigma_{i+1},\sigma_i)$, and the point is the vertex $v_i$.
  * By the gift-wrapping definition, the largest right secant from $v_i$, floored at 0, is $\sigma_{i+1}$; it is attained, and it is 0 at the last vertex. So $s_+=\sigma_{i+1}<1$.
  * By convexity, $s_-\ge\sigma_i>1$. At $v_0$ no shorter point has finite fit, and $s_-=\infty$.
* **Computed.**
  * [v1(D)] 15,979 (class, λ) cases with a single MAP point, 3,999 of them at λ = 1, in exact arithmetic. Each point is an extreme point, by a test that uses no slope characterisation. Each has $s_+=\sigma_{i+1}<\lambda<\sigma_i\le s_-$, with σ read off the extreme points.
  * [v3] 200 per-query runs to $n=2^{16}$ in a class of 21,343 rate-grid programs. Here $\ell^*=9$, and longer near refinements sit at every length.
    * Every run ends with the MAP set equal to $E^*$ for λ ∈ {1, 1.5, 2, 4}, and with $s_+<1<s_-$. The last failing checkpoint is at most $n=16{,}384$.
    * At every (run, $n$) where the 1-MAP set was $E^*$ (1,998 cases), $s_+<1<s_-$ held.
    * $s_-/n$ tends to about 0.0218, above (a)'s bound 0.01184.

  These are consistent with the theorem; simulation cannot prove an almost-sure limit.

---

## 4. Proposition 4.2(ii) and item (g)

### 4.1 The statement and proof of (ii)

The cell argument is correct. It uses three facts that the record does not state; all three hold.

* **(α) $\bar\ell_\lambda$ is nonincreasing in λ.** This needs $b_0+\kappa\ge0$, which is automatic. The coding bound applied to the good model gives $\ell_g+F_g\ge K(y_D\mid\mathrm{dom}D)-\kappa$, and $b_0$-sufficiency gives $\ell_g+F_g\le K+b_0$. This holds when κ in $\bar\ell_\lambda$ is the class's coding constant, as Prop 4.2 says. v4 also checks $b_0+\kappa\ge0$ in every computed row.
* **(β) $F^\sharp_t(I)$ is nonincreasing in $I$.** The record says only "γ is nondecreasing in the budget". The missing step: $f(j)=j-2\log(j+1)$ is not monotone for small $j$. But $f(j)\le0$ for $j\le5$ and $f$ is increasing for $j\ge2$. So the least $j$ with $f(j)>T$ is 0 for $T<0$ and the least $j\ge6$ with $f(j)>T$ for $T\ge0$. It is nondecreasing in $T$, and $T$ increases with $I$. A supremum over $g$ of nonincreasing functions is nonincreasing. [v4(0): $j(T)$ monotone on a grid; $\Gamma_t$ monotone in λ.]
* **(γ) $\mathrm{den}_t\ge0$**, used in $\lambda\,\mathrm{den}_t\le\lambda_{\rm hi}\mathrm{den}_t$.
  * In $\Hcl{\times}$, $\kappa_g\ge0$.
  * In a general class with $\kappa_g:=\ell(\pi'_g)-d$: if the minimum in $\mathrm{den}_t$ is $d$, then $\mathrm{den}_t=\ell(\pi'_g)\ge0$. Otherwise (D1) for the good model (level 1, since $u=1-p>3/4$) gives $\mathrm{den}_t\ge s(t+1)-s(1)>0$.
  * Also $\lambda_{\rm lo}>1$ is implicit.

The initial segment $(1,b]$ in the rows where the $G_t$ floors alone satisfy the cell condition is a connected union of cells $[1+1/k,b]$. So "(1, x]" is certified exactly in those rows, by the statement as written.

**Statement to use** (unchanged in content): if $1<\lambda_{\rm lo}\le\lambda_{\rm hi}$ and $\lambda_{\rm hi}\,\mathrm{den}_t<N(\Gamma_t(\lambda_{\rm lo})-H(p))$ for $t=t_0,\dots,\max(t_0,T)$, then (a)–(g) hold on $[\lambda_{\rm lo},\lambda_{\rm hi}]$.

### 4.2 The certified ranges: two defects in the printed tables

v4 recomputes everything independently in 120-digit arithmetic:
* $NH(p)-L_E$ from log-gamma;
* $j$ by exact integer search;
* the sharp floor as the true supremum over $g$, with $g$ doubled until a tail bound is below the maximum.

It re-certifies each printed interval with its own cell cover. It also proves *failure* of $C_{t_0}$ near λ = 1 with the upper bound $F^\sharp_t(I)\le1-\log(1+(1-2p)2^{-t}+4p\gamma_1(I))$, which holds because $\gamma_g\ge\gamma_1$.

* **(A) "(1, x]" is wrong where the $G$ floors do not reach λ → 1.**
  * The record (§4, Numbers) says "'(1,x]' means every $\lambda\in(1+10^{-12},x]$ is certified".
  * k7 prints the certified lower end with six significant digits, so $1+2.4\cdot10^{-6}$ prints as "1".
  * Where $G_{t_0}(p)\le H(p)$ (all $p\ge1/16$ rows), $C_{t_0}(\lambda)$ fails for every λ close enough to 1, and this is proved in v4(1): $\Gamma_{t_0}\le H(p)$ there, so the $t=t_0$ inequality cannot hold.
  * The failure is not only below $1+10^{-12}$. In the row $p=1/8$, $d=30$, κ = 30, $C_2$ fails on all of $(1,1+2.416\cdot10^{-6}]$, so the record's convention sentence is false for that row.
  * So no row with $p\ge1/16$ may be printed as "(1, x]". The proposition then certifies nothing near λ = 1; it does not say that the λ-MAP is something else there.
* **(B) Rounding direction.** Several endpoints are rounded outward, for example $9.979\cdot10^6$ for a certified end of $9.978693\cdot10^6$, and 6530 for 6529.722. A printed range claims that every λ in it is certified, so the lower end must be rounded up and the upper end down. DECISIONS.md §A9 ("Computed numbers", the rounding item) asks for the same direction for bounds.

**Corrected table, `kink/notes-final.md` §4(a)** ($p=2^{-10}$, $\delta_E=0$; κ = 0 rows are illustrations) [v4(1)]:

| $d$ | κ | $G$ floors: printed | certified end | correct print | sharp floor: printed | certified end | correct print |
|---|---|---|---|---|---|---|---|
| 20 | 0 | $(1,11944.9]$ | 11945.044 | as printed | $(1,12008.5]$ | 12008.611 | as printed |
| 20 | 30 | $(1,6456.2]$ | 6456.242 | as printed | $(1,6486.2]$ | 6486.239 | as printed |
| 30 | 0 | $(1,9.979\cdot10^6]$ | $9.978693\cdot10^6$ | $(1,9.978\cdot10^6]$ | $(1,1.0048\cdot10^7]$ | $1.0047991\cdot10^7$ | $(1,1.0047\cdot10^7]$ |
| 100 | 0 | $(1,9.493\cdot10^{27}]$ | $9.493434\cdot10^{27}$ | as printed | $(1,9.560\cdot10^{27}]$ | $9.559958\cdot10^{27}$ | $(1,9.559\cdot10^{27}]$ |
| 100 | 30 | $(1,4.483\cdot10^{27}]$ | $4.482689\cdot10^{27}$ | $(1,4.482\cdot10^{27}]$ | $(1,4.514\cdot10^{27}]$ | $4.514101\cdot10^{27}$ | as printed |

In these rows "(1, x]" is right: the $G_t$ floors exceed $H(p)$ and cover λ → 1.

**Corrected table, `kink/notes-final.md` §4(c)** [v4(1)]:

| $p$ | $d$ | κ | $t_0$ | printed | where $C_{t_0}$ holds | correct print |
|---|---|---|---|---|---|---|
| 1/16 | 20 | 0 | 1 | $[1.00048,4276]$ | from $1.000480297$ to $4276.390$; fails at $1.00048$ | $[1.00049,4276]$ |
| 1/16 | 100 | 30 | 1 | $(1,1.589\cdot10^{27}]$ | from $1+2.19\cdot10^{-27}$ to $1.588635\cdot10^{27}$; fails below | $[1+10^{-12},1.588\cdot10^{27}]$ |
| 1/8 | 20 | 0 | 2 | $[1.00059,6530]$ | from $1.000589725$ to $6529.722$ | $[1.00059,6529.7]$ |
| 1/8 | 30 | 30 | 2 | $(1,3.06\cdot10^6]$ | from $1+2.416\cdot10^{-6}$ to $3.060518\cdot10^6$; fails below | $[1.0000025,3.06\cdot10^6]$ |
| 15/64 | 20 | 0 | 2 | $[1.08655,465.4]$ | from $1.0865539$ to $465.394$; fails at $1.08655$ | $[1.08656,465.39]$ |
| 15/64 | 20 | 30 | 2 | $[1.3422,199.8]$ | from $1.342195$ to $199.8197$ | as printed |
| 15/64 | 100 | 0 | 2 | $(1,6.896\cdot10^{26}]$ | from $1+1.23\cdot10^{-25}$ to $6.895753\cdot10^{26}$; fails below | $[1+10^{-12},6.895\cdot10^{26}]$ |

* "Fails below" is proved by the upper bound $U_{t_0}$. "Fails at" is a direct evaluation of $C_{t_0}$ with the exact supremum over $g$. "From" is the pointwise lower end of $C_{t_0}$. Every corrected interval lies inside an interval that v4 certified by cells.
* Two further k7 rows behave the same way:
  * $p=1/16$, $d=30$, κ = 0: $C_1$ fails on $(1,1+5.79\cdot10^{-7}]$;
  * $p=15/64$, $d=60$, κ = 30: $C_2$ fails on $(1,1+2.36\cdot10^{-13}]$.
* **The synthesis's Theorem D table** takes six of these rows. Rows 1 and 5 are correct as printed. Rows 2, 3, 4 and 6 need the corrections above:
  * $(1,9.978\cdot10^6]$ and sharp $(1,1.0047\cdot10^7]$;
  * $[1+10^{-12},1.588\cdot10^{27}]$;
  * $[1.00059,6529.7]$;
  * $[1+10^{-12},6.895\cdot10^{26}]$.

  A row with a lower end like $1+10^{-12}$ reads oddly in a paper. Two options:
  * print only rows whose $G$ floors cover λ → 1, that is $p=2^{-10}$;
  * print the lower end explicitly, with the sentence that near λ = 1 the condition fails because the information budget $\bar\ell_\lambda$ grows like $(b_0+\kappa)/(\lambda-1)$.
* **The summary claims.** "Every reported range survives certification to 5 significant digits" (§0 item 3, §4) is true only with rounding to nearest. "In every case the certified range is nonempty with $t_0\le2$, and its lower end is below $1+10^{-3}$ for $d\ge30$" is consistent with v4.

### 4.3 Item (g)

**Re-derivation.**
* By (c), $F(\hat\pi)\le NH(p)+\lambda(\ell_g-\ell(\hat\pi))\le NH(p)+\lambda(\kappa_g+s(t_0)+\Lambda_1)$. This uses (b)'s lower end, which is (D1) at level $\le t_0$ from (a). So $R(\hat\pi)=F/N\le R_{\max}$.
* `lem:teacher:floor` at $B=\infty$ ($R\ge-\log(u+p)$, for every π) gives $u\ge2^{-R_{\max}}-p$.
* `lem:teacher:sharpfloor` ($R\ge-\log(p+(1-2p)u+p(2\gamma(\pi)+2^{1-g}))$, for every π and every $g\ge1$) gives the third term.
  * Here $\gamma(\pi)$ is computed at $I(\hat\pi)\le I_e$ (item (e)). It is bounded by $\gamma_g(I_e)$ by the monotonicity (β) of §4.1. Divide by $1-2p>0$.
  * The paper's sharp-floor lemma is stated for $p=s_0/2^m$ of any form, so the non-dyadic $p$ of §4(c) are covered.
* $u>\theta_{t_0}$ is (a).
* The formula is right.

**Numbers** ($d=m=20$, $p=2^{-10}$, $\delta_E=0$, κ = 0; illustrations) [v4(2)]. v4 agrees with k7(b) to all printed digits. Five of the record's nine printed values are rounded the wrong way for a bound:

| λ | quantity | record | exact | correct print |
|---|---|---|---|---|
| 2 | $u\ge$ | 0.9928 | 0.992805 | 0.9928 |
| 2 | $u\ge$, $G$ floor alone | 0.9913 | 0.991260 | **0.9912** |
| 2 | $\ell\le d+$ | 45.7 | 45.685 | 45.7 |
| 2 | $I\le$ | 58.3 | 58.329 | **58.4** |
| 2 | $e\le$ | 0.209 | 0.208859 | 0.209 |
| 105 | $u\ge$ | 0.9904 | 0.990388 | **0.9903** |
| 105 | $\ell\le d+$ | 15.6 | 15.580 | 15.6 |
| 105 | $I\le$ | 28.2 | 28.224 | **28.3** |
| 105 | $e\le$ | 0.183 | 0.183131 | **0.184** |

The λ = 2 columns of §4(c) have the same issue if they are printed. v4(3) gives the exact values. The ones rounded the wrong way:
* $K(a\mid\hat\pi)\le12.64$, printed 12.6 → 12.7;
* 15.81, printed 15.8 → 15.9 (twice);
* 45.81 → 45.9;
* $\ell\le d+42.14$ → $d+42.2$;
* $d+170.605$ → $d+170.7$;
* $d+117.21$ → $d+117.3$;
* $\ell\ge d-33.745$, printed $d-33.7$ → $d-33.8$;
* $I\le79.20$ → 79.3;
* $I\le229.20$ → 229.3.

---

## 5. Proposition 3.5(ii)

**Re-derivation.**
* For a λ-MAP, $\lambda\hat\ell+\hat F\le\lambda\ell_U+F_U\le\lambda\ell_U+\hat F+\hat\ell+\kappa_0$. So $(\lambda-1)\hat\ell\le\lambda\ell_U+\kappa_0$.
* The identity $(\lambda\ell_U+\kappa_0)/(\lambda-1)=\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$ is immediate.
* This is `thm:absorb:absorption`(a) restricted to the one data set. Prop 3.5 assumes (Dom) only on $D$, which is weaker.
* $F_U<\infty$ because the point set is nonempty.
* Applying the hypothesis to $\pi_U$ itself gives $\ell_U+\kappa_0\ge0$.

**The minor correction.** "This is at most $\ell_U+(\ell_U+\kappa_0)/\epsilon$ exactly when $\lambda\ge1+\epsilon$" needs $\ell_U+\kappa_0>0$. If $\ell_U+\kappa_0=0$, both sides equal $\ell_U$ for every λ. Corrected sentence: *"For ε > 0 this is at most $\ell_U+(\ell_U+\kappa_0)/\epsilon$ when $\lambda\ge1+\epsilon$, and, if $\ell_U+\kappa_0>0$, only then."* The bound itself is unchanged.

**Computed** [v1(C)]. 28,000 (class, λ) cases in exact arithmetic:
* no violation of the bound;
* the bound is attained with equality in 493 cases, for example $\{(3,100),(7,92)\}$ with $\ell_U=3$, $\kappa_0=1$, λ = 2, bound 7;
* the "exactly when" clause holds in all 82,740 checks with $\ell_U+\kappa_0>0$.

---

## 6. Remark 3.2′

* **τ < σ in Thm 3.2(d).**
  * Points $(0,10),(1,5),(2,0)$, checked against Def 3.1 literally:
    * $(1,5)$ is a zero-window left kink of steepness 5 but not $5+10^{-3}$;
    * it is a zero-window right kink of flatness 5 but not $5-10^{-3}$.
  * It is not an extreme point of $\mathrm{conv}+\mathbb R^2_{\ge0}$.
  * The MAP set is $\{(2,0)\}$ for λ < 5, all three points at λ = 5, and $\{(0,10)\}$ for λ > 5 [v1(A)].
* **Strictness.** In $\{(0,10),(2,0)\}$:
  * $(2,0)$ is a zero-window left kink of steepness 5, and at λ = 5 the point $(0,10)$, of length $0<2$, is a MAP;
  * $(0,10)$ is a zero-window right kink of flatness 5, and at λ = 5 the point $(2,0)$ is a MAP.

  These are the smallest examples, and the paper can use them as they stand.
* **Counts** [v1(B)]. Random classes with windows and with kink points above $\rho$, in exact arithmetic:
  * Thm 3.2(a), (b): no violation over 2,632 left kinks (the two-part bound checked 9,040 times) and 5,879 right kinks.
  * Zero-window kinks with τ < σ: 926, all vertices, with the stated MAP set. Ones with τ = σ (best constants): 13, none a vertex.
  * At λ = σ a MAP lies left of the window in 563 cases. At λ = τ one lies right of it in 556 cases.
  * Converse of (d): all 3,228 vertices are zero-window kinks with τ < σ.

  The record's k8(A) counts (25 and 2,687) count kinks with the best constants at structure-function points only; v1's sampling differs, and the conclusions agree.

---

## 7. Consequences for the paper

* **Statuses.** These items now have one independent check in their final form:
  * the (pq) forms of Lemmas 5.1–5.3, Thm 5.4 and Cor 5.5 (synthesis rows C1–C4);
  * Cor 5.7(a)–(d) (row C5);
  * Prop 4.2(ii) and (g) (row D2);
  * Prop 3.5(ii) (row B5);
  * Remark 3.2′.

  They may be stated as proved, with the corrections above. The synthesis's §8 still says "post-referee"; it was not edited here.
* **Ranges.**
  * Print λ-ranges with the lower end rounded up and the upper end down.
  * Print "(1, x]" only where the $G_t$ floors alone satisfy the cell condition. Among the computed rows that is $p=2^{-10}$.
  * Every κ = 0 row is an illustration (DECISIONS §A9).
* **Notation.** δ* is $\sup_n\log(\xi_{\mathcal C}(h_n)/\nu(h_n))$ (§2.3).
* **Proof of Prop 4.2(ii) in the appendix.** Add the three facts of §4.1 in one sentence each. (β) is the only one with content.

---

## Verification log

*Run 2026-10-13, Python 3.11.15, numpy 2.4.6, mpmath 1.3.0, with `PYTHONDONTWRITEBYTECODE=1 python3 -I`. No script imports a local module.*

1. **Scripts** (all in `kink/verify_code/`, outputs saved next to them).
   * `v1_hull_kinks.py` [seeded: `random.Random(5172)`; exact `Fraction` arithmetic; 9 s].
     * (A) Remark 3.2′'s example.
     * (B) Thm 3.2(a)–(d) with windows, the τ = σ counts and the converse.
     * (C) Prop 3.5(ii).
     * (D) the deterministic step of Cor 5.7(d).

     Vertices are found by an extreme-point test (single points and pairs, exact one-dimensional feasibility). It uses none of the slope characterisations under test.
   * `v2_pq_exact.py` [deterministic class B; random classes from `numpy.random.default_rng(31)`; 27 s].
     * Exact sums over count vectors in the per-query scheme with an atomic μ, including a null input.
     * Covers Lemmas 5.1, 5.2, 5.3(a), Lemma 5.3(b) to a finite horizon over all paths of length 7, Thm 5.4(i)–(iii) and Cor 5.5. Every conclusion is asserted on every count vector where the lemmas' events hold.
   * `v3_pq_eventual.py` [seeded: `numpy.random.default_rng(57)`; 2 s]. Cor 5.7(a)–(d) along 200 per-query runs to $n=2^{16}$, in a 21,343-program rate-grid class.
   * `v4_parity_range.py` [deterministic; mpmath at 120 digits; 48 s].
     * (0) the monotonicity facts of §4.1;
     * (1) re-certification of every printed range of kink §4(a), (c) and of the synthesis's Theorem D, with pointwise ends and proved failure regions;
     * (2) item (g) and the §4(b) numbers;
     * (3) the λ = 2 columns of §4(c).
2. **Debugging before the saved runs.**
   * v1's first draft used `None` both for an infinite fit and for "no positive steepness", so an infinite steepness read as "no kink". It also mixed a float into one exact comparison, which made a collinear point look extreme. Both were fixed before the saved run, and neither affected a conclusion about the record.
   * v2's first class B had a kernel with mass above 1 at one input, an input error. It was fixed before the saved run.
   * v4 first took the sharp floor's supremum over $g\le64$ only. The final version doubles $g$ until a tail bound certifies the supremum, and every printed number was unchanged.
3. **Reproducibility.** All four scripts were copied to the session scratchpad and re-run there. Exit codes were 0, stderr was empty, and the outputs were byte-identical to the saved `.out` files.
4. **Diagnosis of k7** (scratchpad only). A copy of k7's function definitions, with its report loop replaced, printed the certified lower ends with four significant digits of λ − 1, for example $2.416\cdot10^{-6}$ for $p=1/8$, $d=30$, κ = 30. That copy is the source of finding 4.2(A); v4 confirms it independently. k7 itself was not changed.
5. **Not done.**
   * Lemma 5.1 (wor) and (fd), and Remark 5.4′, are outside the requested (pq) scope. Their proofs were read: the (wor) step is Maclaurin's inequality $S_n^{1/n}\le S_1$ for nonnegative reals, and it is correct. They were not recomputed here; k6(A) and rA(7) cover them.
   * Prop 4.2(i)(a)–(f) were used, not re-refereed; they were refereed before.
   * The literature statuses (Ville, Hoeffding, Maclaurin) were not re-examined.
6. **Repository.** Two read-only git commands were run (`git status --short`, `git branch --show-current`). No git command that changes repository state was run. No record was edited. The only files created are this file and `kink/verify_code/`. No `__pycache__` was created under `research/tracks/split/` (checked with `find`).
