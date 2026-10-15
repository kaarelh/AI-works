# Track "split", sub-track "kink": λ-MAPs, the hull of the product structure function, and "a kink implies the split" (notes)

*Target T2 of the brief `../00-brief.md`, with the link to T1. Written 2026-10-13.*

* **Sources read.** The brief; Paper 2's `setup.tex`, `app-setup.tex` (the hull lemma `lem:setup:hull`, the coding bound `lem:setup:coding`), `split.tex`, `app-split.tex` (`lem:split:ville`, `thm:split:private`, `thm:split:shared`), `algstat.tex`, `app-algstat.tex` (`prop:algstat:product`, `prop:algstat:parity`, `prop:algstat:set`), `teacher.tex`, `app-teacher.tex` (`thm:teacher:main`, `cor:teacher:fulltable`, lemmas `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:sharpfloor`, `lem:teacher:twopart`), `limits.tex`; the refereed record `research/tracks/steeper/notes-final.md` §1–§3; Paper 1's `versions.tex` (`def:versions:variants`); `paper/NOTATION.md`.
* **Scripts.** `checks/k1_hull.py` … `checks/k5_margin_necessity.py`, deterministic or seeded, Python 3.11, outputs saved next to them as `.out` files.

**Status tags.**
* **[proved]**: full proof here.
* **[computed: kN]**: checked by `checks/kN_*.py`; output in `checks/kN_*.out`.
* **[known: ref]**: standard or published; "(unverified)" when not checked against the source.
* **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]**: as named.
* **Illustration (κ = 0)**: a number obtained by setting the unknown machine constant κ to 0; not a result about a reference machine.

Notation follows `paper/NOTATION.md`: $n$ samples, $d$ input length, $N=2^d$, $\kappa$ the machine constant, $c=\lambda/n$, $\mathrm{Hel}(P,Q)=1-\sum_y\sqrt{P(y)Q(y)}$ the squared Hellinger distance, $\mu$ the input law. Logarithms are base 2. Local symbols are defined where they first appear.

---

## 0. Summary

1. **λ-MAPs are read off the lower convex hull** (§2) [proved; computed: k1, k2].
   * For a data set $D$ and any countable prefix-free class, put $L(\pi):=-\log\nu_\pi(D)$. The lower boundary of $\mathrm{conv}\{(\ell(\pi),L(\pi))\}+\mathbb R^2_{\ge0}$ is the graph of $\breve\rho_D$, the greatest convex minorant of the product structure function $\rho_D(\alpha)=\min\{L(\pi):\ell(\pi)\le\alpha\}$. It is a polygon with vertices $(\alpha_i,\rho_i)$, each attained by a program of length exactly $\alpha_i$, and edge slopes $-\sigma_i$ with $\sigma_1>\sigma_2>\dots>0$, $\sigma_i\to0$ if there are infinitely many (Thm 2.1).
   * For $\lambda>0$, π is a λ-MAP if and only if $L(\pi)=\breve\rho_D(\ell(\pi))$ and $-\lambda\in\partial\breve\rho_D(\ell(\pi))$. So for $\sigma_{i+1}<\lambda<\sigma_i$ the λ-MAPs are exactly the programs at vertex $i$; at $\lambda=\sigma_i$ they are the programs on the closed edge between vertices $i-1$ and $i$, collinear interior points included. MAPs exist for every $\lambda>0$; 0-MAPs exist if and only if the vertex sequence is finite (Thm 2.2).
   * The MAP profile and the hull are Legendre duals: $\Phi_D(\lambda):=\min_\pi J_\lambda(\pi)=\min_i(\lambda\alpha_i+\rho_i)$ is concave with derivative the MAP length, and $\breve\rho_D(\alpha)=\sup_{\lambda>0}(\Phi_D(\lambda)-\lambda\alpha)$ (Prop 2.3).
   * This is the data-set version of the population hull lemma `lem:setup:hull`; what is added is the identification of the hull with $\breve\rho_D$, the exact edge/tie description and the duality.
2. **A kink implies the split** (§3) [proved; computed: k1, k2].
   * *Definition.* A **left kink** of steepness σ with window $w_-$ at a reference point $(\alpha_-,L_-)$ with $\rho_D(\alpha_-)\le L_-$: every program shorter than $\alpha_--w_-$ has $L(\pi)\ge L_-+\sigma(\alpha_--\ell(\pi))$. A **right kink** of flatness τ with window $w_+$ at $(\alpha_+,L_+)$: every program longer than $\alpha_++w_+$ has $L(\pi)\ge L_+-\tau(\ell(\pi)-\alpha_+)$.
   * *Theorem 3.2.* A left kink and $\lambda<\sigma$ give every λ-MAP length $\ge\alpha_--w_-$, fit $\le L_-+\lambda w_-$ and two-part length $\le\alpha_-+L_-+(\lambda-1)w_-$. A right kink and $\lambda>\tau$ give length $\le\alpha_++w_+$. Zero-window kinks at one point are exactly the hull vertices.
   * *The headline (Cor 3.3).* Sufficiency gives the right side for free. If $\pi_0$ is product-$b_0$-sufficient and every program shorter than $\ell(\pi_0)-w$ loses at least σ bits of fit per bit saved, then for every $\lambda\in(1,\sigma)$ every λ-MAP $\hat\pi$ satisfies
     $$\ell(\pi_0)-w\le\ell(\hat\pi)\le\ell(\pi_0)+\frac{b_0+\kappa}{\lambda-1},\qquad L(\pi_0)-\frac{\lambda(b_0+\kappa)}{\lambda-1}\le L(\hat\pi)\le L(\pi_0)+\lambda w,$$
     and $\hat\pi$ is product-$(b_0+(\lambda-1)w)$-sufficient.
   * *Converse (Thm 3.4).* Every λ-MAP for $\lambda\in(\tau,\sigma)$ has length in $[\alpha',\alpha'']$ if and only if there are zero-window kinks, of steepness σ at a hull vertex of length $\ge\alpha'$ and of flatness τ at a hull vertex of length $\le\alpha''$. So "a stable split on a λ-interval" and "a kink" are the same thing.
   * *Shared randomness flattens kinks (Prop 3.5).* If the class has a member $U$ with $L_U\le L(\pi)+\ell(\pi)+\kappa_0$ for all π (the (Dom) condition of `thm:split:shared`), every left kink at $\alpha_0>\ell_U+w$ has $\sigma\le1+(\ell_U+\kappa_0)/(\alpha_0-\ell_U)$.
3. **The noisy random parity** (§4) [proved; computed: k2, k4].
   * The full truth table has a left kink at the good model $(\ell(\pi_g),NH(p))$, with window at most $\kappa_g+s(t_0)+\Lambda_1$ and steepness at least $N(\Psi^\circ_{t_0}-H(p))/(\kappa_g+d)$, exponential in $d$ whenever $\Psi^\circ_{t_0}>H(p)$ (Prop 4.1).
   * *λ-range (Prop 4.2).* Under an explicit condition $C_{t_0}(\lambda)$, of the form $\lambda<\sigma$, every λ-MAP has agreement level at most $t_0$. It then knows the parity up to $s(t_0)+2\log d+\kappa$ bits, has length in $[d-s(t_0)-\Lambda_1,\ d+\kappa_g+(b_0+\kappa)/(\lambda-1)]$, fits within $\lambda(\kappa_g+s(t_0)+\Lambda_1)$ bits of $NH(p)$ from above and $\lambda(b_0+\kappa)/(\lambda-1)$ from below, and holds at most $\kappa_g+(b_0+\kappa)/(\lambda-1)+s(t_0)+2\log d+\kappa$ bits about the flip set.
   * *Comparison with the paper.* For $p<0.056$ and $t_0=1$ the range contains the open window $(1,Nc_{\rm hi})$ of `cor:teacher:fulltable`, and is slightly larger: $9.98\cdot10^6$ against $9.79\cdot10^6$ at $d=30$ (κ = 0).
   * *Every flip rate below 1/4 (Cor 4.3).* With the sharper floor, for every fixed $p<1/4$ and λ > 1, and all large $d$ with $\delta_E=O(d)$, the λ-MAP has level ≤ 2, and level 1 if $p<0.1233$. The reason is that the limit of $F_2$ exceeds $H(p)$ by at least 0.0188 on all of $(0,1/4]$ (interval check).
   * *Computed (k4).* At $d\in\{20,30,60,100\}$, κ ∈ {0, 30} and $p\in\{1/16,1/8,3/16,7/32,15/64\}$ the range is nonempty with $t_0\le2$. Its lower end is below $1+10^{-3}$ for $d\ge30$, and its upper end is of order $N$.
   * This extends the full-table corollary beyond $p<0.056$. The junta case $m<d$ is not covered.
   * *Set models (Prop 4.4).* Every left kink of the set structure function at $\alpha_0$ (window below $\alpha_0-c^*$) has $\sigma\le1+(c^*+\delta_E+2\kappa)/(\alpha_0-c^*)$, with $c^*=2\log d+2\log r+\kappa$. At $\alpha_0\approx d$ this is $1+O((\log d+\delta_E)/d)$, against a product steepness exponential in $d$. The mechanism is Prop 3.5: the set "all parities plus $pN$ flips" plays the role of a universal member.
4. **A sample from ν has a kink at the shortest equivalent length** (§5, link to T1) [proved; computed: k3, k5].
   * *Setting.* Inputs are i.i.d. from a non-atomic μ, or drawn uniformly without replacement from a finite set. Let $\nu=\nu_{\pi^*}$ in a countable product class with Kraft sum ≤ 1, $\ell_0$ the least length of a program μ-a.e. equal to ν, and $L_0=-\log\nu(D_n)$.
   * *Hellinger union bound (Lemma 5.2).* With probability ≥ 1 − ε, for all programs at once, $L(\pi)-L_0>2\log e\cdot n\,\mathrm{Hel}_\mu(\pi)-2\ell(\pi)-2\log(1/\varepsilon)$.
   * *Theorem 5.4.* With probability ≥ 1 − 2ε, $(\ell_0,L_0)$ has a zero-window left kink of steepness at least $(2\log e\cdot n\gamma_--2\log(1/\varepsilon))/\ell_0$, which is linear in $n$ ($\gamma_-$ is the least Hellinger gap among shorter programs), and a right kink of flatness 1 with window $(\ell_0+\log(1/\varepsilon))/(\tau-1)$ for every τ > 1. If moreover $n>(\bar\ell+\log(1/\varepsilon))/(\log e\cdot\gamma_{\bar\ell})$ for a length cap $\bar\ell>\ell_0$, then $\rho_{D_n}=L_0$ on $[\ell_0,\bar\ell]$, $(\ell_0,L_0)$ is a hull vertex with right slope below $1+(\ell_0+\log(1/\varepsilon))/(\bar\ell-\ell_0)$, and for λ between the two slopes the λ-MAPs are exactly the shortest equivalent programs.
   * *Finite samples.* Cor 5.5 gives an explicit $n_0(\lambda,\ell_0,\gamma,\varepsilon)$, and Thm 5.6 a near/far refinement that charges near-equivalent programs by counting instead of by the margin. In the computed class the refinement lowers $n_0$ from $3\cdot10^8$ to $2\cdot10^4$; the empirical threshold is about $10^3$ (k3).
   * *Almost surely (Cor 5.7).* The left steepness grows linearly and the right slope's lim sup is at most 1. Every fixed λ > 1 eventually selects a shortest equivalent program.
   * *The margin is necessary (Prop 5.8).* A program shorter by Δ with mean KL divergence $\bar K$ beats every equivalent program with probability at least $1-(n\bar K+\log e/e)/(\lambda\Delta)$. The computed thresholds sit at $n\approx\lambda\Delta/\bar K$, within a factor of about 2 of the Hellinger scale (k5).
5. **Interpretation** (§6). Along the hull, the λ-MAP keeps exactly the blocks of program bits that explain more than λ bits of data per bit (hull-edge averages, not single bits). The sufficiency line caps any extension beyond a sufficient program at one bit per bit plus a constant. So for λ > 1 the selected model is the sufficient part bought at rates above λ; the split is sharp exactly at a kink. With private randomness the bits of a random model parameter each explain about $N(1-H(p))/d$ bits of data on the full parity table, and the kink exists. With shared randomness they explain one bit each, and there is none.

---

## 1. Setting

* **Class.** $\mathcal C$ is a countable prefix-free set of programs π with lengths $\ell(\pi)=|\pi|\in\{0,1,2,\dots\}$, each with an lsc conditional semimeasure $\nu_\pi$ (a product hypothesis, `def:setup:product`). Only finitely many programs have length ≤ α, at most $2^j$ of length $j$. Kraft's inequality $\sum_\pi2^{-\ell(\pi)}\le1$ is used only in §5. §2 and §3 hold verbatim for any family of points $(\ell,L)$ with integer $\ell\ge0$, $L\in[0,\infty]$ and finitely many points per length. This includes shared classes and set models; there the "length" is the model's complexity.
* **Data and fit.** $D$ is a data set (finite partial function, frozen noise). The fit of π is $L(\pi):=-\log\nu_\pi(D)\in[0,\infty]$, and $J_\lambda(\pi):=\lambda\ell(\pi)+L(\pi)$ (`def:setup:objectives`). The point set is $\mathcal A:=\{(\ell(\pi),L(\pi)):L(\pi)<\infty\}$, assumed nonempty; in $\Hcl{\times}$ the fair coin has finite fit.
* **Structure function.** $\rho_D(\alpha):=\min\{L(\pi):\ell(\pi)\le\alpha\}$ for $\alpha\in\mathbb R$ ($+\infty$ if no finite point qualifies). For $\Hcl{\times}$ this is $\rho^\times_D$ of `def:algstat:product`. It is a nonincreasing right-continuous step function. Put $\alpha_0:=\min\{\ell(\pi):L(\pi)<\infty\}$.
* **Convex minorant.** $\breve\rho_D$ is the greatest convex function $\mathbb R\to(-\infty,+\infty]$ with $\breve\rho_D\le\rho_D$.
* **Sufficiency.** π is product-$b$-sufficient if $\ell(\pi)+L(\pi)\le K(y_D\mid\mathrm{dom}D)+b$ (`def:algstat:product`). The coding bound `lem:setup:coding` gives $\ell(\pi)+L(\pi)\ge K(y_D\mid\mathrm{dom}D)-\kappa$ for every π in every data-set class whose programs satisfy (F1).

---

## 2. λ-MAPs and the lower convex hull

**Theorem 2.1 (the hull of a data set) [proved; computed: k1(A)].** Define vertices by gift wrapping.
* $v_0:=(\alpha_0,\rho_0)$ with $\rho_0:=\rho_D(\alpha_0)$.
* Given $v_i=(\alpha_i,\rho_i)$, put $\sigma_{i+1}:=\sup\{(\rho_i-L(b))/(\ell(b)-\alpha_i):b\in\mathcal A,\ \ell(b)>\alpha_i\}$.
* If this set is empty or $\sigma_{i+1}\le0$, stop: $v_i$ is the last vertex, with index $q:=i$.
* Otherwise let $\alpha_{i+1}$ be the largest $\ell(b)$ attaining the supremum, and $\rho_{i+1}:=\rho_i-\sigma_{i+1}(\alpha_{i+1}-\alpha_i)$.

Then:
* (i) The suprema are attained. Every vertex is attained by a program of length exactly $\alpha_i$, and $\rho_i=\rho_D(\alpha_i)$. The slopes satisfy $\sigma_1>\sigma_2>\dots>0$. If there are infinitely many vertices, then $\alpha_i\to\infty$ and $\sigma_i\to0$.
* (ii) Let $P$ be $+\infty$ on $(-\infty,\alpha_0)$, linear between consecutive vertices, and equal to $\rho_q$ on $[\alpha_q,\infty)$ if $q<\infty$. Then $P=\breve\rho_D$.
* (iii) For $\alpha\ge\alpha_0$, $\breve\rho_D(\alpha)=\min\{y:(\alpha,y)\in\mathrm{conv}(\mathcal A)+\mathbb R^2_{\ge0}\}$. So the lower convex hull of the points $(\ell(\pi),-\log\nu_\pi(D))$ is the graph of $\breve\rho_D$.

*Proof.*
* *(i), attainment.* Fix $i$ and suppose some $b$ with $\ell(b)>\alpha_i$ has slope $s_b:=(\rho_i-L(b))/(\ell(b)-\alpha_i)>0$. Every $b'$ with slope at least $s_b$ has $0\le L(b')\le\rho_i-s_b(\ell(b')-\alpha_i)$, hence $\ell(b')\le\alpha_i+\rho_i/s_b$. Only finitely many points qualify, so the supremum is a maximum and $\alpha_{i+1}$ exists.
* *(i), $\rho_i=\rho_D(\alpha_i)$, by induction.* For $i=0$ it holds by definition. Assume it for $i$, so every point with $\ell\le\alpha_i$ has $L\ge\rho_i>\rho_{i+1}$. A point $b$ with $\alpha_i<\ell(b)\le\alpha_{i+1}$ has slope at most $\sigma_{i+1}$, so $L(b)\ge\rho_i-\sigma_{i+1}(\ell(b)-\alpha_i)\ge\rho_{i+1}$. Hence $\rho_D(\alpha_{i+1})\ge\rho_{i+1}$. The maximising point at length $\alpha_{i+1}$ has fit exactly $\rho_{i+1}$, so equality holds and the vertex is attained at length exactly $\alpha_{i+1}$.
* *(i), strict decrease.* Suppose $\sigma_{i+1}\ge\sigma_i$ for some $i\ge1$. The slope of $v_{i+1}$ seen from $v_{i-1}$ is $(\sigma_i(\alpha_i-\alpha_{i-1})+\sigma_{i+1}(\alpha_{i+1}-\alpha_i))/(\alpha_{i+1}-\alpha_{i-1})\ge\sigma_i$. Strict inequality contradicts the definition of $\sigma_i$. Equality contradicts the maximality of $\alpha_i$, since $\alpha_{i+1}>\alpha_i$ would then also attain $\sigma_i$.
* *(i), infinitely many vertices.* The $\alpha_i$ are strictly increasing integers, so $\alpha_i\to\infty$. Also $\sum_i\sigma_i(\alpha_i-\alpha_{i-1})=\rho_0-\lim\rho_i\le\rho_0<\infty$ with every $\alpha_i-\alpha_{i-1}\ge1$, so $\sigma_i\to0$.
* *(ii), $P$ is a convex minorant.* $P$ is convex: its slopes $-\sigma_1<-\sigma_2<\dots\le0$ increase, and it is $+\infty$ to the left of $\alpha_0$. Every finite point lies on or above $P$:
  * if $\ell(b)\in(\alpha_i,\alpha_{i+1}]$, the slope of $b$ from $v_i$ is at most $\sigma_{i+1}$, which gives $L(b)\ge P(\ell(b))$;
  * if $\ell(b)>\alpha_q$, its slope from $v_q$ is at most 0, so $L(b)\ge\rho_q$;
  * if $\ell(b)=\alpha_0$, then $L(b)\ge\rho_0$.

  $P$ is nonincreasing, so $P(\alpha)\le P(\ell(b))\le L(b)$ whenever $\ell(b)\le\alpha$, that is, $P\le\rho_D$.
* *(ii), $P$ is the greatest one.* Let $g$ be convex with $g\le\rho_D$.
  * At the vertices, $g(\alpha_i)\le\rho_D(\alpha_i)=\rho_i=P(\alpha_i)$.
  * Between consecutive vertices, $g$ lies below the chord, which is $P$.
  * Beyond $\alpha_q$, $g\le\rho_D=\rho_q=P$.
  * Left of $\alpha_0$, $P=+\infty$.

  So $g\le P$, and $P=\breve\rho_D$.
* *(iii).* Every point of $\mathcal A$ lies in the epigraph of $P$, which is convex and closed under adding $\mathbb R^2_{\ge0}$ because $P$ is nonincreasing. So $\mathrm{conv}(\mathcal A)+\mathbb R^2_{\ge0}\subseteq\mathrm{epi}P$. Conversely, for $\alpha\in[\alpha_{i-1},\alpha_i]$ the point $(\alpha,P(\alpha))$ is a convex combination of two vertices, which lie in $\mathcal A$. For $\alpha\ge\alpha_q$ it is $v_q+(\alpha-\alpha_q,0)$. ∎

**Theorem 2.2 (λ-MAPs are the points where the hull's slope crosses −λ) [proved; computed: k1(B), k2(A)].** Put $\sigma_0:=+\infty$, and $\sigma_{q+1}:=0$ if $q<\infty$. Let $\lambda>0$.
* (i) $\min_\pi J_\lambda(\pi)=\min_i(\lambda\alpha_i+\rho_i)$ is attained.
* (ii) π is a λ-MAP if and only if $L(\pi)=\breve\rho_D(\ell(\pi))$ and $-\lambda\in\partial\breve\rho_D(\ell(\pi))$. Explicitly:
  * if $\sigma_{i+1}<\lambda<\sigma_i$, the λ-MAPs are exactly the programs whose point is $v_i$;
  * if $\lambda=\sigma_i$ with $i\ge1$, they are exactly the programs whose point lies on the closed segment $[v_{i-1},v_i]$, interior collinear points included.

  The set of λ-MAPs is finite and nonempty.
* (iii) Ties between different points occur only at the countably many values $\lambda=\sigma_i$, which accumulate at most at 0. A point is the unique minimising point for every λ in an open interval if and only if it is a vertex (this is `lem:setup:hull`(iii)). Several programs at one point always tie.
* (iv) The MAP length is nonincreasing in λ and the MAP fit nondecreasing (`lem:setup:hull`(ii)).
* (v) λ = 0: a program minimising $L$ exists if and only if the vertex sequence is finite. The minimisers are the programs at $(\ell,\rho_q)$ with $\rho_q=\min L$; among them those of least length are $v_q$.

*Proof.*
* *(i) and (ii).* For every π with $L(\pi)<\infty$, $J_\lambda(\pi)\ge\lambda\ell(\pi)+\breve\rho_D(\ell(\pi))\ge m_\lambda:=\inf_\alpha(\lambda\alpha+\breve\rho_D(\alpha))$. On $[\alpha_0,\infty)$ the function $\varphi(\alpha)=\lambda\alpha+\breve\rho_D(\alpha)$ is piecewise linear, with slope $\lambda-\sigma_i$ on $(\alpha_{i-1},\alpha_i)$ and slope $\lambda>0$ beyond $\alpha_q$. These slopes increase with $i$.
  * Let $i^*:=\min\{i:\sigma_{i+1}\le\lambda\}$. It exists because $\sigma_i\to0<\lambda$ or $\sigma_{q+1}=0$.
  * Then $\varphi$ is nonincreasing up to $\alpha_{i^*}$ and nondecreasing after it. So $m_\lambda=\lambda\alpha_{i^*}+\rho_{i^*}$, and it is attained by the program at $v_{i^*}$.
  * Hence π is a minimiser if and only if both inequalities are equalities. That is, $L(\pi)=\breve\rho_D(\ell(\pi))$ and $\ell(\pi)\in\arg\min\varphi=\{\alpha:-\lambda\in\partial\breve\rho_D(\alpha)\}$.
  * This argmin is $\{\alpha_i\}$ if $\sigma_{i+1}<\lambda<\sigma_i$, and $[\alpha_{i-1},\alpha_i]$ if $\lambda=\sigma_i$.
  * Finiteness: only finitely many programs have length ≤ $\alpha_i$.
* *(iii).* At a breakpoint $\sigma_i$ the two ends of the edge tie, so an open interval on which the MAP point is unique contains no breakpoint. It therefore lies in some $(\sigma_{i+1},\sigma_i)$, and the point is $v_i$. Conversely, $v_i$ is the unique MAP point on $(\sigma_{i+1},\sigma_i)$.
* *(iv).* As in `lem:setup:hull`(ii).
* *(v).* If $q<\infty$, $\rho_q=\min_\pi L(\pi)$ is attained. If there are infinitely many vertices, the $\rho_i$ decrease strictly and every point has $L\ge\rho_i$ for all large $i$, so $\inf L$ is not attained. ∎

**Proposition 2.3 (duality: MAP profile ↔ hull) [proved; computed: k1(C)].** Let $\Phi_D(\lambda):=\min_\pi J_\lambda(\pi)$ for $\lambda>0$.
* (i) $\Phi_D(\lambda)=\min_i(\lambda\alpha_i+\rho_i)$. It is concave and piecewise linear, with derivative $\alpha_i$ on $(\sigma_{i+1},\sigma_i)$: the derivative of the optimal value is the MAP length.
* (ii) For $\alpha\ge\alpha_0$, $\breve\rho_D(\alpha)=\sup_{\lambda>0}\big(\Phi_D(\lambda)-\lambda\alpha\big)$. For $\alpha<\alpha_0$ the supremum is $+\infty$.

*Proof.*
* (i) follows from Thm 2.2(i).
* (ii), "≥": $\Phi_D(\lambda)\le\lambda\alpha+\breve\rho_D(\alpha)$ for every α.
* (ii), "≤":
  * For $\alpha\in[\alpha_{i-1},\alpha_i]$ take $\lambda=\sigma_i$. Then $v_i$ is a minimiser, so $\Phi_D(\sigma_i)-\sigma_i\alpha=\rho_i+\sigma_i(\alpha_i-\alpha)=\breve\rho_D(\alpha)$.
  * For $\alpha\ge\alpha_q$ and $\lambda<\sigma_q$, $\Phi_D(\lambda)-\lambda\alpha=\rho_q-\lambda(\alpha-\alpha_q)\to\rho_q$ as $\lambda\downarrow0$.
  * For $\alpha<\alpha_0$, $\Phi_D(\lambda)-\lambda\alpha\ge\lambda(\alpha_0-\alpha)\to\infty$. ∎

**Remarks.**
* *2.4 (relation to the paper) [remark].*
  * `lem:setup:hull` is the population version, with points $(\ell,R)$ and normal $(c,1)$. Theorem 2.2 is the same statement on one data set, with $(\ell,L)$ and normal $(\lambda,1)$.
  * The constrained problem $\min\{L:\ell\le\alpha\}$ of `lem:setup:hull`(iv) is the structure function itself. So the λ-MAPs are exactly the solutions of the constrained problem whose point lies on the convex minorant and has a supporting slope $-\lambda<0$.
  * Points of $\rho_D$ strictly above $\breve\rho_D$ are never selected for any λ.
  * Prop 2.3 is the Legendre–Fenchel transform [known: standard convex analysis (e.g. Rockafellar, *Convex Analysis*, §12, unverified section number)].
* *2.5 (the sufficiency line bounds the hull) [proved].* The coding bound gives $\rho_D(\alpha)\ge K(y_D\mid\mathrm{dom}D)-\kappa-\alpha$. The right-hand side is affine, hence convex, so $\breve\rho_D(\alpha)\ge K(y_D\mid\mathrm{dom}D)-\kappa-\alpha$ as well. If $(\alpha',\breve\rho_D(\alpha'))$ is the point of a $b$-sufficient program, then for every $\alpha>\alpha'$,
  $$\frac{\breve\rho_D(\alpha')-\breve\rho_D(\alpha)}{\alpha-\alpha'}\le1+\frac{b+\kappa}{\alpha-\alpha'}.$$
  So beyond a sufficient point the hull descends at most one bit per bit, up to $(b+\kappa)/(\alpha-\alpha')$.

---

## 3. A kink implies the split

**Definition 3.1 (kinks).** Let $\sigma>0$, $\tau\ge0$ and $w_\pm\ge0$.
* $D$ has a **left kink of steepness σ and window $w_-$ at $(\alpha_-,L_-)$** if $\rho_D(\alpha_-)\le L_-$ and every π with $\ell(\pi)<\alpha_--w_-$ has $L(\pi)\ge L_-+\sigma(\alpha_--\ell(\pi))$.
* $D$ has a **right kink of flatness τ and window $w_+$ at $(\alpha_+,L_+)$** if $\rho_D(\alpha_+)\le L_+$ and every π with $\ell(\pi)>\alpha_++w_+$ has $L(\pi)\ge L_+-\tau(\ell(\pi)-\alpha_+)$.
* A **$(\sigma,\tau)$-kink at $(\alpha_0,L_0)$ with windows $(w_-,w_+)$** is both, at the same point.

In words: outside the window, giving up length costs at least σ bits of fit per bit, and adding length buys at most τ bits per bit. The brief's "(σ, ε)-kink" is $\tau=1+\varepsilon$. The window absorbs the additive slack of real instances. A condition "$L(\pi)\ge L_-+\sigma(\alpha_--\ell(\pi))-b_1$ for all shorter π" implies a left kink of steepness $\sigma-b_1/w$ with window $w$, for every $w>0$. The left-kink condition is equivalent to $\rho_D(\alpha)\ge L_-+\sigma(\alpha_--\alpha)$ for all $\alpha<\alpha_--w_-$, because $\rho_D(\alpha)$ is a minimum over programs of length at most α and the right-hand side is nonincreasing in α. The right-kink condition is implied by $\rho_D(\alpha)\ge L_+-\tau(\alpha-\alpha_+)$ for all $\alpha>\alpha_++w_+$. The converse fails: a program inside the window with a very low fit lowers $\rho_D$ to the right of the window, but the definition does not constrain it.

**Theorem 3.2 (a kink locates the λ-MAPs) [proved; computed: k1(D), k2(C)].**
* (a) **Left kink.** If $D$ has a left kink (σ, $w_-$) at $(\alpha_-,L_-)$ and $\lambda<\sigma$, every λ-MAP $\hat\pi$ satisfies:
  * $\ell(\hat\pi)\ge\alpha_--w_-$;
  * $L(\hat\pi)\le L_-+\lambda(\alpha_--\ell(\hat\pi))\le L_-+\lambda w_-$;
  * $\ell(\hat\pi)+L(\hat\pi)\le\alpha_-+L_-+(\lambda-1)(\alpha_--\ell(\hat\pi))$, which is at most $\alpha_-+L_-+(\lambda-1)w_-$ if $\lambda\ge1$.

  In particular, if $\alpha_-+L_-\le K(y_D\mid\mathrm{dom}D)+b_0$, then $\hat\pi$ is product-$(b_0+(\lambda-1)w_-)$-sufficient for $\lambda\ge1$.
* (b) **Right kink.** If $D$ has a right kink (τ, $w_+$) at $(\alpha_+,L_+)$ and $\lambda>\tau$, every λ-MAP has $\ell(\hat\pi)\le\alpha_++w_+$.
* (c) Both together: for $\lambda\in(\tau,\sigma)$, every λ-MAP has length in $[\alpha_--w_-,\ \alpha_++w_+]$.
* (d) **Zero windows are vertices.**
  * If $D$ has a $(\sigma,\tau)$-kink with $w_-=w_+=0$ at $(\alpha_0,L_0)$, then $\rho_D(\alpha_0)$ is attained at length exactly $\alpha_0$, and $(\alpha_0,\rho_D(\alpha_0))$ is a vertex of $\breve\rho_D$ whose λ-interval contains $(\tau,\sigma)$. For $\lambda\in(\tau,\sigma)$ the λ-MAPs are exactly the programs at that point.
  * Conversely, every vertex $v_i$ is a zero-window $(\sigma_i,\sigma_{i+1})$-kink at $v_i$.

*Proof.*
* *(a).* Let $\pi_-$ have $\ell(\pi_-)\le\alpha_-$ and $L(\pi_-)\le L_-$. Then $J_\lambda(\hat\pi)\le J_\lambda(\pi_-)\le\lambda\alpha_-+L_-$. If $\ell(\hat\pi)<\alpha_--w_-$, the kink gives
  $$J_\lambda(\hat\pi)\ge\lambda\alpha_-+L_-+(\sigma-\lambda)(\alpha_--\ell(\hat\pi))>\lambda\alpha_-+L_-,$$
  a contradiction. The fit bound is $J_\lambda(\hat\pi)\le\lambda\alpha_-+L_-$ rearranged. Then subtract $(\lambda-1)\ell(\hat\pi)$ from both sides for the two-part bound.
* *(b).* Symmetric. If $\ell(\hat\pi)>\alpha_++w_+$, then $J_\lambda(\hat\pi)\ge\lambda\alpha_++L_++(\lambda-\tau)(\ell(\hat\pi)-\alpha_+)>\lambda\alpha_++L_+\ge J_\lambda(\pi_+)$.
* *(c)* combines (a) and (b).
* *(d), forward.* A program attaining $\rho_D(\alpha_0)\le L_0$ at a length $<\alpha_0$ would violate the left kink. By (c), every λ-MAP for $\lambda\in(\tau,\sigma)$ has length $\alpha_0$, hence fit $\rho_D(\alpha_0)$. The MAP point is the same on an open interval, so it is a vertex by Thm 2.2(iii).
* *(d), converse.* By convexity, $\breve\rho_D(\ell)\ge\rho_i+\sigma_i(\alpha_i-\ell)$ for $\ell<\alpha_i$ and $\breve\rho_D(\ell)\ge\rho_i-\sigma_{i+1}(\ell-\alpha_i)$ for $\ell>\alpha_i$. Every point lies above $\breve\rho_D$. ∎

**Corollary 3.3 (the split theorem for one data set) [proved].** Work in a data-set class whose programs satisfy (F1), so that `lem:setup:coding` holds. Let $\pi_0$ be product-$b_0$-sufficient for $D$, with $\ell_0:=\ell(\pi_0)$ and $L_0:=L(\pi_0)$.
* (a) **Sufficiency is a right kink.** For every $\tau>1$, $D$ has a right kink of flatness τ and window $(b_0+\kappa)/(\tau-1)$ at $(\ell_0,L_0)$. For every $\lambda>1$, every λ-MAP satisfies
  $$\ell(\hat\pi)\le\ell_0+\frac{b_0+\kappa}{\lambda-1},\qquad L(\hat\pi)\ge L_0-\frac{\lambda(b_0+\kappa)}{\lambda-1}.$$
* (b) **The split.** Suppose also that every program shorter than $\ell_0-w$ loses at least σ bits of fit per bit saved: $L(\pi)\ge L_0+\sigma(\ell_0-\ell(\pi))$ whenever $\ell(\pi)<\ell_0-w$. Then for every $\lambda\in(1,\sigma)$, every λ-MAP $\hat\pi$ satisfies
  $$\ell_0-w\le\ell(\hat\pi)\le\ell_0+\frac{b_0+\kappa}{\lambda-1},\qquad L_0-\frac{\lambda(b_0+\kappa)}{\lambda-1}\le L(\hat\pi)\le L_0+\lambda w,$$
  and $\hat\pi$ is product-$(b_0+(\lambda-1)w)$-sufficient.

*Proof.*
* *(a), the kink.* By the coding bound and sufficiency, $L(\pi)\ge K(y_D\mid\mathrm{dom}D)-\kappa-\ell(\pi)\ge L_0-(\ell(\pi)-\ell_0)-(b_0+\kappa)$. This is at least $L_0-\tau(\ell(\pi)-\ell_0)$ as soon as $(\tau-1)(\ell(\pi)-\ell_0)\ge b_0+\kappa$.
* *(a), the MAP bounds.* Directly: $\lambda\ell(\hat\pi)+L(\hat\pi)\le\lambda\ell_0+L_0$ and $\ell(\hat\pi)+L(\hat\pi)\ge\ell_0+L_0-b_0-\kappa$. Subtracting gives $(\lambda-1)\ell(\hat\pi)\le(\lambda-1)\ell_0+b_0+\kappa$. The fit bound follows from the second inequality and the length bound.
* *(b)* is (a) together with Thm 3.2(a). ∎

The first half of (a) is `prop:algstat:product` with the sophistication replaced by the length of any sufficient program. The content of (b) is the left side: σ > 1 outside a window. Sufficiency alone gives only σ = 1 (Remark 2.5 read leftwards), and with σ = 1 the interval $(1,\sigma)$ is empty.

**Theorem 3.4 (stable MAP lengths ⟺ kinks at hull vertices) [proved; computed: k1(E)].** Let $0\le\tau<\sigma\le\infty$ and $\alpha'\le\alpha''$. Let $i$ be the index with $\sigma_{i+1}<\sigma\le\sigma_i$, and $j$ the index with $\sigma_{j+1}\le\tau<\sigma_j$. The following are equivalent:
* (1) every λ-MAP with $\lambda\in(\tau,\sigma)$ has length in $[\alpha',\alpha'']$;
* (2) $D$ has a zero-window left kink of steepness σ at a point $(\alpha_-,\rho_D(\alpha_-))$ with $\alpha_-\ge\alpha'$, and a zero-window right kink of flatness τ at a point $(\alpha_+,\rho_D(\alpha_+))$ with $\alpha_+\le\alpha''$.

Moreover, one can take $\alpha_-=\alpha_i$ and $\alpha_+=\alpha_j$, and the set of λ-MAP lengths over $\lambda\in(\tau,\sigma)$ has minimum $\alpha_i$ and maximum $\alpha_j$.

The index $j$ exists unless $\tau=0$ and the vertex sequence is infinite. In that case both (1) and (2) fail for every finite $\alpha''$: MAP lengths are unbounded as $\lambda\downarrow0$, and $\rho_D$ keeps decreasing, so no right kink of flatness 0 exists.

*Proof.*
* *(2) ⇒ (1)* is Thm 3.2(c).
* *(1) ⇒ (2).* The indices exist: $i=\min\{i:\sigma_{i+1}<\sigma\}$, and similarly for $j$. Also $j\ge i$, because $\sigma_{j+1}\le\tau<\sigma$.
  * The interval $(\max(\tau,\sigma_{i+1}),\sigma)$ is nonempty and lies in $(\sigma_{i+1},\sigma_i]$. On it the MAP point is $v_i$ (at $\lambda=\sigma_i$, $v_i$ is still a MAP). So $\alpha_i\ge\alpha'$.
  * Likewise, on $(\tau,\min(\sigma,\sigma_j))$ the MAP point is $v_j$, so $\alpha_j\le\alpha''$.
  * By Thm 3.2(d), $v_i$ is a zero-window left kink of steepness $\sigma_i\ge\sigma$, hence of steepness σ. Similarly $v_j$ is a zero-window right kink of flatness $\sigma_{j+1}\le\tau$.
* *The extremes.* By monotonicity (Thm 2.2(iv)) every MAP length on $(\tau,\sigma)$ lies in $[\alpha_i,\alpha_j]$, and both ends are attained. ∎

**Proposition 3.5 (a universal member flattens every kink) [proved; computed: k1(F)].** Suppose the class contains a program $\pi_U$ with $L(\pi_U)\le L(\pi)+\ell(\pi)+\kappa_0$ for all π. For product classes no such member exists (`cor:absorb:nouniversal`); for shared classes it is (Dom). Then every left kink (σ, w) at $(\alpha_0,L_0)$ with $\alpha_0-w>\ell_U$ has
$$\sigma\le\frac{\alpha_0+\kappa_0}{\alpha_0-\ell_U}=1+\frac{\ell_U+\kappa_0}{\alpha_0-\ell_U}.$$

*Proof.* Let $\pi_0$ attain $\rho_D(\alpha_0)\le L_0$ with $\ell(\pi_0)\le\alpha_0$. Then $L(\pi_U)\le L_0+\alpha_0+\kappa_0$. Since $\ell_U<\alpha_0-w$, the kink gives $L(\pi_U)\ge L_0+\sigma(\alpha_0-\ell_U)$. ∎

In a shared class, then, kinks steeper than $1+\epsilon$ sit at lengths at most $\ell_U+(\ell_U+\kappa_0)/\epsilon$, whatever the data. By Cor 3.3(b), λ-MAPs for λ > 1 stay below that length. This is `thm:split:shared` in kink language.

**Remark 3.6 (reading) [remark].** The λ-MAP is chosen by local rates only: λ against the hull's edge slopes. Three consequences:
* the split is stable on a λ-interval exactly when there is a kink (Thm 3.4);
* its location is determined up to the window (Thm 3.2);
* its sufficiency deficiency grows by at most $(\lambda-1)$ times the left window (Thm 3.2(a)).

Nothing forces a unique kink. A data set may have several vertices with $\sigma_i>1$, and then different λ select different "models". Two kinks occur, for example, for a parity plus a structured error rule (k2(F), and T3).

---

## 4. The noisy random parity

The instance is `def:teacher:instance` with $m=d$ (idiosyncratic errors), $B=\infty$ and the full truth table $D$.
* $N=2^d$; $|E|=s_0=pN$ with $p<1/4$; the deficiency is $\delta_E=L_E-K(E\mid a,K(a))$, where $L_E=\log\binom{N}{pN}$.
* The fit of a program is $L(\pi)=NR(\pi)$, with $R$ the risk under uniform inputs.
* $\kappa_g:=2\log d+K(p)+\kappa$. For $p=2^{-r}$ we use $K(p)\le2\log r$, as in `def:teacher:instance`. For $p=h/2^e$ we use $K(p)\le2\log(h+1)+2\log(e+1)$, as in `tab:algstat:numbers`.
* $\Lambda_1=4\log d+\kappa$, $s(t)=2t+2\log(t+1)$, $G_t=1-\log(1+2^{-t}+2p)$.
* $F_t(I_{\max}):=\sup_{g\ge1}\big[1-\log\big(1+(1-2p)2^{-t}+2p(2\gamma_g(I_{\max})+2^{1-g})\big)\big]$. Here $\gamma_g(I_{\max})=\sqrt{j\ln2/(2s_0)}$, and $j$ is the least integer with $j-2\log(j+1)>\delta_E+I_{\max}+1+2\log d+2\log s_0+g+2\log g+\kappa$.

  This is `lem:teacher:sharpfloor` for programs with information budget $I(\pi)\le I_{\max}$: if $\mathrm{lev}(\pi)>t$ and $I(\pi)\le I_{\max}$, then $R(\pi)\ge F_t(I_{\max})$. Every program has $I(\pi)\le\ell(\pi)+\kappa$.
* $\pi_g$ is the good model. $\ell_g:=\ell(\pi_g)\in[d-4-\Lambda_1,\,d+\kappa_g]$, the lower end by (D1), since $\mathrm{lev}(\pi_g)=1$.
* Its sufficiency deficiency is
  $$b_0:=\kappa_g+(NH(p)-L_E)+\delta_E+2\log d+\kappa.$$
  The derivation: $L(\pi_g)=NH(p)$, $K(y_D\mid\mathrm{dom}D)\ge d+L_E-\delta_E-2\log d-\kappa$ (proof of `prop:algstat:parity`(ii)), and $0\le NH(p)-L_E\le\log(N+1)$.

**Proposition 4.1 (the full table has a left kink at the good model) [proved].** Let $t_0\ge1$ and $w:=\ell_g-(d-s(t_0)-\Lambda_1)\le\kappa_g+s(t_0)+\Lambda_1$. Put $\Psi^\circ_t:=\max\{G_t,F_t(d+\kappa)\}$ for $t\in[1,\infty]$, and
$$\sigma^{(t_0)}:=\inf_{t\ge t_0}\frac{N(\Psi^\circ_t-H(p))}{\kappa_g+\min\{d,\ s(t+1)+\Lambda_1\}}.$$
* If $\sigma^{(t_0)}>0$, then $D$ has a left kink of steepness $\sigma^{(t_0)}$ and window $w$ at $(\ell_g,NH(p))$.
* $\pi_g$ is $b_0$-sufficient.
* Hence Cor 3.3(b) applies for $\lambda\in(1,\sigma^{(t_0)})$: every λ-MAP has $\ell\ge d-s(t_0)-\Lambda_1$, $L\le NH(p)+\lambda w$, and is $(b_0+(\lambda-1)w)$-sufficient.

*Proof.*
* Let $\ell(\pi)<d-s(t_0)-\Lambda_1$. If $\mathrm{lev}(\pi)=t'\le t_0$, (D1) and the monotonicity of $s$ would give $\ell(\pi)\ge d-s(t')-\Lambda_1\ge d-s(t_0)-\Lambda_1$. So $\mathrm{lev}(\pi)=t+1$ for some $t\ge t_0$, or $\mathrm{lev}(\pi)=\infty$.
* Take $\mathrm{lev}(\pi)=t+1<\infty$.
  * Then $\ell(\pi)\ge(d-s(t+1)-\Lambda_1)^+$ by (D1).
  * Also $R(\pi)\ge G_t$ by `lem:teacher:floor`, and $R(\pi)\ge F_t(d+\kappa)$ by `lem:teacher:sharpfloor`. The latter applies because $u(\pi)\le\theta_t$ and $I(\pi)\le\ell(\pi)+\kappa<d+\kappa$.
  * Hence
    $$\frac{L(\pi)-NH(p)}{\ell_g-\ell(\pi)}\ge\frac{N(\Psi^\circ_t-H(p))}{d+\kappa_g-(d-s(t+1)-\Lambda_1)^+}\ge\sigma^{(t_0)}.$$
* For level ∞, $\Psi^\circ_\infty\ge\Psi^\circ_t$ for every $t$, and the denominator is at most $d+\kappa_g$.
* Sufficiency is the display before the proposition. ∎

The parity's kink of `prop:algstat:parity`(ii) and (iv), "$\rho^\times_D(\alpha)\ge NG_1$ (or $NF_t$) for α below $d-s(t)-\Lambda_1$", is the $t=t_0$ term of this infimum. The infimum over all levels converts the cliff into a steepness.

**Proposition 4.2 (the λ-range on which the λ-MAP is "parity + noise") [proved; computed: k4].** Let $\lambda>1$ and put
$$\bar\ell_\lambda:=d+\kappa_g+\frac{b_0+\kappa}{\lambda-1},\qquad \Psi_t(\lambda):=\max\{G_t,F_t(\bar\ell_\lambda+\kappa)\}.$$
Let $T$ be the least $t\ge1$ with $s(t+1)+\Lambda_1\ge d$, and $t_0\ge1$. Condition $C_{t_0}(\lambda)$ is
$$\lambda\big(\kappa_g+\min\{d,\ s(t+1)+\Lambda_1\}\big)<N\big(\Psi_t(\lambda)-H(p)\big)\qquad\text{for } t=t_0,\dots,\max(t_0,T).$$
Assume $C_{t_0}(\lambda)$. Then every λ-MAP $\hat\pi$, over $\Hcl{\times}$ or any c.e. prefix-free product class (with its own constants), satisfies:
* (a) $\mathrm{lev}(\hat\pi)\le t_0$; hence $u(\hat\pi)>\frac12+2^{-t_0-1}$ and $K(a\mid\hat\pi)\le s(t_0)+2\log d+\kappa$: it knows the parity;
* (b) $d-s(t_0)-\Lambda_1\le\ell(\hat\pi)\le \bar\ell_\lambda$;
* (c) $NH(p)-\lambda(b_0+\kappa)/(\lambda-1)\le L(\hat\pi)\le NH(p)+\lambda(\kappa_g+s(t_0)+\Lambda_1)$: it fits like noise;
* (d) $\hat\pi$ is product-$(b_0+(\lambda-1)(\kappa_g+s(t_0)+\Lambda_1))$-sufficient;
* (e) $I(\hat\pi)\le\ell(\hat\pi)-d+s(t_0)+2\log d+\kappa\le\kappa_g+(b_0+\kappa)/(\lambda-1)+s(t_0)+2\log d+\kappa$: it holds little information about the flip set;
* (f) $e(\hat\pi)\le1-u(\hat\pi)+\gamma_g+2^{-g}$ for every $g\ge1$, with $\gamma_g$ computed from the information budget of (e). This is `thm:teacher:main`(e).

For $t_0=1$ and $G_t$ alone, $C_1(\lambda)$ reads $\lambda<N(G_t-H(p))/(\kappa_g+\min\{d,s(t+1)+\Lambda_1\})$ for all $t\ge1$. Its solution set contains the open window $(1,Nc_{\rm hi})$ of `cor:teacher:fulltable`. For each level $t+1\ge2$, the paper's lower bound $c(d-4(t+1)-\Lambda_1)^++G_t\ge\Phi_2(c)$ uses $s(t+1)\le4(t+1)$ and is weaker than the bound with $s(t+1)$ used here, and $J_g<\Phi_2$ is the paper's condition. At the endpoint $c_{\rm hi}$ the paper's inequality may be an equality, so the strict condition $C_1$ may fail there.

*Proof.*
* *Upper bound in (b).* Cor 3.3(a) with $\pi_0=\pi_g$ gives $\ell(\hat\pi)\le\ell_g+(b_0+\kappa)/(\lambda-1)\le \bar\ell_\lambda$.
* *(a).* Suppose $\mathrm{lev}(\hat\pi)=t+1$ with $t\ge t_0$.
  * Then $\ell(\hat\pi)\ge(d-s(t+1)-\Lambda_1)^+$ by (D1).
  * $I(\hat\pi)\le\ell(\hat\pi)+\kappa\le \bar\ell_\lambda+\kappa$. So the floors give $R(\hat\pi)\ge\Psi_t(\lambda)$, since $F_t(I_{\max})$ is nonincreasing in the budget $I_{\max}$.
  * Hence $J_\lambda(\hat\pi)\ge\lambda(d-s(t+1)-\Lambda_1)^++N\Psi_t(\lambda)$.
  * For $t\le\max(t_0,T)$, $C_{t_0}(\lambda)$ makes this exceed $\lambda(d+\kappa_g)+NH(p)\ge J_\lambda(\pi_g)$, a contradiction.
  * For $t>\max(t_0,T)$, the minimum in the denominator is $d$ and $\Psi_t(\lambda)$ is nondecreasing in $t$, so the condition at $t=\max(t_0,T)$ suffices. Level ∞ is handled the same way, since $\Psi_\infty\ge\Psi_t$.
  * The bound on $K(a\mid\hat\pi)$ is `lem:teacher:list`.
* *Lower bound in (b).* (D1) at level at most $t_0$.
* *(c), upper.* $J_\lambda(\hat\pi)\le J_\lambda(\pi_g)$ with $\ell_g-\ell(\hat\pi)\le d+\kappa_g-(d-s(t_0)-\Lambda_1)$.
* *(c), lower.* Cor 3.3(a).
* *(d).* Thm 3.2(a).
* *(e).* As in `thm:teacher:main`(d): $I(\pi)\le K(\pi\mid a,K(a))+\kappa\le\ell(\pi)+K(a\mid\pi)-K(a)+\kappa$, with $K(a)\ge d$.
* *(f).* The proof of `thm:teacher:main`(e) uses only the bound on $I$.
* *The comparison with the window* is the computation in k4(a). ∎

**Numbers [computed: k4; κ = 0 rows are illustrations].**

* *(a) $p=2^{-10}$, where $G_1>H(p)$.* The level-1 range against the window of `cor:teacher:fulltable`:

| $d$ | κ | $Nc_{\rm hi}$ (paper) | level-1 range, $G$ floors | level-1 range, with sharp floor |
|---|---|---|---|---|
| 20 | 0 | 11945 | $(1,\ 11945)$ | $(1,\ 12009)$ |
| 20 | 30 | 6456 | $(1,\ 6456)$ | $(1,\ 6486)$ |
| 30 | 0 | $9.79\cdot10^6$ | $(1,\ 9.98\cdot10^6)$ | $(1,\ 1.005\cdot10^7)$ |
| 100 | 0 | $9.35\cdot10^{27}$ | $(1,\ 9.49\cdot10^{27})$ | $(1,\ 9.56\cdot10^{27})$ |
| 100 | 30 | $4.45\cdot10^{27}$ | $(1,\ 4.48\cdot10^{27})$ | $(1,\ 4.51\cdot10^{27})$ |

* *(b) Identification at $d=m=20$, $p=2^{-10}$, κ = 0, $\delta_E=0$.*
  * At λ = 2: $u\ge0.993$, $\ell\le d+45.5$, $I\le58.2$, $e\le0.208$. The paper's table in `app:teacher:fulltable` gives 0.991, $d+58.2$, 70.8 and 0.220.
  * At λ = 105: $\ell\le d+15.6$, $I\le28.2$, $e\le0.183$, against the paper's $d+15.7$, 28.3 and 0.185.
  * The gain comes from bounding the fit of a λ-MAP from below by the sufficiency line (coding bound) instead of (D2).
* *(c) Every flip rate below 1/4.*

| $p$ | $d$ | κ | least $t_0$ | λ-range | at λ = 2: $K(a\mid\hat\pi)\le$, $\ell\in$, $I\le$ |
|---|---|---|---|---|---|
| 1/16 | 20 | 0 | 1 | $(1.0005,\ 4276)$ | 12.6, $[d-21.3,\ d+43.2]$, 55.9 |
| 1/16 | 100 | 30 | 1 | $(1,\ 1.6\cdot10^{27})$ | 47.3, $[d-60.6,\ d+217.1]$, 264.4 |
| 1/8 | 20 | 0 | 2 | $(1.0006,\ 6530)$ | 15.8, $[d-24.5,\ d+42.0]$, 57.8 |
| 1/8 | 30 | 30 | 2 | $(1,\ 3.1\cdot10^6)$ | 47.0, $[d-56.8,\ d+170.5]$, 217.5 |
| 15/64 | 20 | 0 | 2 | $(1.086,\ 465)$ | 15.8, $[d-24.5,\ d+63.2]$, 79.1 |
| 15/64 | 20 | 30 | 2 | $(1.342,\ 200)$ | 45.8, $[d-54.5,\ d+183.2]$, 229.1 |
| 15/64 | 100 | 0 | 2 | $(1,\ 6.9\cdot10^{26})$ | 20.5, $[d-33.7,\ d+117.2]$, 137.6 |

  * The full table (k4(c)) covers $p\in\{1/16,1/8,3/16,7/32,15/64\}$, $d\in\{20,30,60,100\}$ and κ ∈ {0, 30}. In every case the range is nonempty with $t_0\le2$.
  * $I$ is out of $L_E$, which ranges from $3.5\cdot10^5$ (at $d=20$) to $10^{30}$ (at $d=100$).
  * The lower end exceeds 1 only at small $d$. Near λ = 1 the information budget $\bar\ell_\lambda$ grows like $(b_0+\kappa)/(\lambda-1)$, and the deviation term of the sharp floor grows with it.
* *(d) Crossovers.*
  * $G_1=H(p)$ at $p=0.05596$, the paper's 0.056.
  * The limit $1-\log(3/2-p)$ of $F_1$ equals $H(p)$ at $p=0.12331$.
  * The limit of $F_2$ exceeds $H(p)$ by at least 0.0188 on all of $(0,1/4]$. This is a rigorous interval check over $10^5$ cells: on each cell the first term is increasing in $p$ and $H$ is increasing.

  So as $d\to\infty$, with $\delta_E=O(d)$, level ≤ 2 is obtained for every $p<1/4$ and level 1 for every $p<0.1233$ (Cor 4.3).

**What this adds to the paper.** `cor:teacher:fulltable` gives the full-table window only for $p<0.056$. `prop:algstat:parity`(iv) gives the kink of $\rho^\times_D$ for every $p<1/4$, but no λ-range for the λ-MAP. Prop 4.2 and Cor 4.3 turn the kink into a λ-range for every $p<1/4$, with explicit identification. This answers the full-table ($m=d$) analogue of `q:teacher:open`(b): level 1, the teacher theorem's identification, for $p<0.1233$, and level ≤ 2 for $p<1/4$.

The junta case $m<d$ is not covered. There the good model is far from sufficient, since the error rule costs only $L_S\ll nH(p)$ bits. So the right side of the kink is the rule's own rate, about $n2^{-m}$ bits per bit, not the flatness 1 that sufficiency gives (Cor 3.3(a)). A program of level ≥ 2 then has its length, and hence its information budget, controlled only through $J_c\le J_g$, which allows about $H(p)/c\approx L_S/(c2^m)$ bits. Near $c=2^{-m}$ the deviation term of the sharp floor is then of order $\sqrt{H(p)/p}$. That is the obstacle described in `rem:limits:method`. In the full-table case the budget is instead $O(d/(\lambda-1))$, against $s_0=pN$ flips.

**Corollary 4.3 (every flip rate below 1/4, asymptotically) [proved; the limit inequality computer-checked: k4(d)].** Fix $p<1/4$ with bounded $K(p)$ and fix λ > 1. Let $d\to\infty$ with $\delta_E=O(d)$ and $pN$ an integer. Then for all large $d$, $C_2(\lambda)$ holds, and if $p<0.12331$ then $C_1(\lambda)$ holds. So every λ-MAP has level ≤ 2 (level 1 if $p<0.12331$), and the conclusions (a)–(f) of Prop 4.2 hold with $t_0=2$ (respectively 1).

*Proof.*
* *The budget is small.* $b_0=O(\log N)+\delta_E=O(d)$, so $\bar\ell_\lambda=O(d)$. Hence $j=O(d+g)$ in $F_t(\bar\ell_\lambda+\kappa)$, and $\gamma_g=O(\sqrt{(d+g)/(p2^d)})$.
* *The floors converge.* Let $g\to\infty$ slowly. Then $\epsilon_d:=\inf_g(2\gamma_g+2^{1-g})\to0$. Uniformly in $t$, $F_t(\bar\ell_\lambda+\kappa)\ge f_t(p)-O(\epsilon_d)$, with $f_t(p):=1-\log(1+(1-2p)2^{-t})$ increasing in $t$.
* *The limits exceed $H(p)$.*
  * $f_2(p)-H(p)\ge0.0188$ on $(0,1/4]$. On a cell $[a,b]$ the first term is increasing and $H$ is increasing, so $f_2-H\ge f_2(a)-H(b)$; k4(d) checks this over $10^5$ cells.
  * $f_1-H$ is strictly decreasing on $(0,1/4]$: its derivative is $\log e/(3/2-p)-\log((1-p)/p)\le\log e/(5/4)-\log3<0$. It vanishes at $p=0.12331$ (k4(d)).
* *Conclusion.* For $t\ge t_0$, $N(\Psi_t(\lambda)-H(p))\ge c_pN$ with $c_p>0$ for all large $d$. The left side of $C_{t_0}(\lambda)$ is at most $\lambda(\kappa_g+d)=O(d)$, while $N=2^d$. ∎

The corollary does not claim level 1 for $p\ge0.12331$; with the present floors level 2 is the best the argument gives. The finite-$d$ numbers are in the table above.

**Proposition 4.4 (set models have no kink at α ≈ d) [proved; computed illustration: k2(D)].** Consider set models $A\ni z$ for the table $z=y^*$, with points $(K(A),\log|A|)$ and set structure function $h_z$. Put $c^*:=2\log d+2\log r+\kappa$, which bounds $K(A_0)$ for $A_0=\{f_{a'}\oplus\ind_{E'}:a'\in\{0,1\}^d,\ |E'|=pN\}$ (`prop:algstat:parity`(i)). Then every left kink of $h_z$ of steepness σ and window $w$ at $(\alpha_0,L_0)$ with $\alpha_0-w>c^*$ has
$$\sigma\le\frac{\alpha_0+\delta_E+2\kappa}{\alpha_0-c^*}=1+\frac{c^*+\delta_E+2\kappa}{\alpha_0-c^*}.$$

*Proof.*
* By the set sufficiency line and $K(z)\ge d+L_E-\delta_E-\kappa$ (`prop:algstat:parity`(i)), $L_0\ge h_z(\alpha_0)\ge K(z)-\kappa-\alpha_0\ge d+L_E-\delta_E-2\kappa-\alpha_0$.
* $A_0$ has $K(A_0)\le c^*<\alpha_0-w$, so the kink gives $d+L_E=\log|A_0|\ge L_0+\sigma(\alpha_0-K(A_0))\ge L_0+\sigma(\alpha_0-c^*)$.
* Combining the two: $\sigma(\alpha_0-c^*)\le\alpha_0+\delta_E+2\kappa$. ∎

**Comparison.**
* At $\alpha_0\approx d$ the set steepness is at most $1+O((\log d+\delta_E)/d)$. The product structure function has steepness $\sigma^{(1)}\ge N(\Psi^\circ_1-H(p))/(\kappa_g+d)$ there (Prop 4.1). This is exponential in $d$ when $\Psi^\circ_1>H(p)$: for $p<0.056$ always, and for $p<0.1233$ once $d$ is large.
* $A_0$ is a short set within $\delta_E+O(\log d)$ of the sufficiency line. It plays the role of the universal member in Prop 3.5: the shared randomness of a set model absorbs the parity's $d$ bits at one bit per bit.
* Consequently, by Cor 3.3(a) for sets (`prop:algstat:set`), every λ-optimal set model with λ > 1 has $K(A_\lambda)\le c^*+(\delta_E+c^*+2\kappa)/(\lambda-1)$. This is `prop:algstat:parity`(i).

**Illustration [computed: k2; explicit class with assigned Kraft-valid code lengths, not $K$].**
* *The class.* On the full table of a random parity at $d=8$, $|E|=16$, k2 builds an exactly enumerable product class:
  * constants;
  * all parities with dyadic flip rates;
  * partial parities;
  * partial memorisers;
  * the lookup table.
* *Product hull.* It has 5 vertices: the coin; the parity with rates $1/4$, $1/8$, $1/16$; and the full memoriser. The λ-MAP knows the parity exactly for $\lambda\in(1.016,13.82)$. It is the best-rate model $p=1/16$ for $\lambda\in(1.016,7.89)$, the coin above 13.82 and the memoriser below 1.016. A brute-force argmin over 408 values of λ, including every breakpoint ±$10^{-7}$ relative, agrees with Thm 2.2.
* *Left steepness at the good model.* It is 7.89 with window 0, 11.3 with window 2 and 13.05 with window 4. The coarser-rate parities, 1–3 bits shorter, form a small staircase inside the window. All λ-MAPs for λ in each $(\tau_w,\sigma_w)$ lie in the window and obey the fit bound (k2(C)).
* *Set hull.* It has 4 vertices: the trivial set; $A_0$, all parities plus $|E|$ flips, which knows nothing about $a$ (labelled `A_v v=8` in k2's output, where $v$ counts unknown coordinates); the set that knows $a$; and the memoriser set. The edge from $A_0$ to the full-knowledge set has slope exactly 1, since all the intermediate sets are collinear. The set λ-MAP is $A_0$ for all $\lambda\in(1,27.5)$: the parity is noise.
* *Other rates and sizes.* At $d\in\{8,10\}$ and $p\in\{1/32,1/16,1/8,3/16\}$ the parity-knowing range is $(\tau,\sigma)$ with $\tau\in[0.994,1.093]$ and σ from 8.2 to 53.6.
  * At λ = 1 the memoriser is the MAP in 4 of the 7 instances, those whose right slope τ exceeds 1. This illustrates `cor:teacher:fulltable`(ii): λ = 1 sits on the memoriser edge, of slope $1\pm O(\log N/L_E)$.
* *Two kinks (k2(F)).* The parity plus a junta rule (2 blocks of 4 inputs at $m=6$) plus 16 random flips gives:
  * parity + noise for $\lambda\in(1.36,10.0)$;
  * parity + rule + noise for $\lambda\in(0.99,1.22)$;
  * memoriser below.

  The rule's own kink is shallow at this size.

---

## 5. A sample from ν has a kink at the shortest equivalent length (link to T1)

**Setting.**
* $\mathcal C$ is a countable product class with $\sum_\pi2^{-\ell(\pi)}\le1$, for example $\Hcl{\times}$ or a time-bounded or circuit subclass. It contains $\pi^*$ with $\nu_{\pi^*}=\nu$, a computable sampler.
* Inputs are drawn in one of two ways:
  * **(iid)** i.i.d. from a non-atomic law μ on $X$, so inputs are almost surely distinct;
  * **(wor)** uniformly without replacement from a finite $X_0$, with $n\le|X_0|$ and μ uniform on $X_0$.

  Given the inputs, labels are independent with $y_i\sim\nu(\cdot\mid x_i)$, so noise is frozen.
* $L_0:=-\log\nu(D_n)$.
* The **Hellinger gap** of π is $\mathrm{Hel}_\mu(\pi):=\mathbb E_{x\sim\mu}\mathrm{Hel}(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))\in[0,1]$.
* By Cauchy–Schwarz, $\sum_y\sqrt{\nu\nu_\pi}\le\sqrt{\sum\nu\sum\nu_\pi}\le1$, with equality only if $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$. So $\mathrm{Hel}_\mu(\pi)=0$ if and only if $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$ for μ-a.e. $x$. Such π is **equivalent** (T1's notion).
* $\ell_0:=\min\{\ell(\pi):\pi\text{ equivalent}\}\le\ell(\pi^*)$.
* **Margins.** $\gamma(\ell):=\min\{\mathrm{Hel}_\mu(\pi):\ell(\pi)=\ell,\ \mathrm{Hel}_\mu(\pi)>0\}$ ($+\infty$ if empty), $\gamma_-:=\min_{\ell<\ell_0}\gamma(\ell)$ and $\gamma_{\bar\ell}:=\min_{\ell\le\bar\ell}\gamma(\ell)$ for a length cap $\bar\ell$. Each is a minimum over a finite set, hence positive: the brief's margin condition always holds for a fixed cap $\bar\ell$. The content is its value.

**Lemma 5.1 (Hellinger affinity) [proved; Hoeffding's comparison known].** For every π, $\mathbb E\sqrt{\Lambda_n(\pi)}\le(1-\mathrm{Hel}_\mu(\pi))^n\le e^{-n\mathrm{Hel}_\mu(\pi)}$ in both sampling schemes, where $\Lambda_n(\pi):=\nu_\pi(D_n)/\nu(D_n)$. Also $\mathbb E\Lambda_n(\pi)\le1$. Equivalent programs have $L(\pi)=L_0$ almost surely.

*Proof.*
* Put $a(x):=\sum_y\sqrt{\nu(y\mid x)\nu_\pi(y\mid x)}=1-\mathrm{Hel}(x)$. Given the inputs, $\mathbb E[\sqrt{\Lambda_n}\mid x_{1:n}]=\prod_ia(x_i)$, and $\mathbb E[\Lambda_n\mid x_{1:n}]=\prod_i\sum_{y:\nu>0}\nu_\pi(y\mid x_i)\le1$.
* *(iid).* $\mathbb E\prod_ia(x_i)=(\mathbb E_\mu a)^n$.
* *(wor).* Hoeffding's comparison: for a continuous convex $f$, $\mathbb Ef(\sum$ without replacement$)\le\mathbb Ef(\sum$ with replacement$)$ [known: Hoeffding 1963, *JASA* 58:13–30, Thm 4; the paper cites it as `hoeffding1963probability`]. Apply it with $f=\exp$ to the population $\max(\ln a(x),-T)$. Then let $T\to\infty$ by dominated convergence: the products lie in $[0,1]$ and decrease to $\prod_ia(x_i)$.
* *Equivalent programs.* Under (iid) the set where $\nu_\pi(\cdot\mid x)\ne\nu(\cdot\mid x)$ has μ-measure 0, so almost surely no input falls in it. Under (wor) "μ-a.e." means everywhere on $X_0$. ∎

**Lemma 5.2 (uniform likelihood-ratio bound) [proved; computed: k3].** For $\varepsilon\in(0,1)$, with probability at least $1-\varepsilon$, simultaneously for all $\pi\in\mathcal C$:
$$L(\pi)-L_0>2\log e\cdot n\,\mathrm{Hel}_\mu(\pi)-2\ell(\pi)-2\log(1/\varepsilon).$$

*Proof.* Let $a(\pi)$ be the right-hand side. By Markov's inequality and Lemma 5.1,
$$\Pr[\Lambda_n(\pi)\ge2^{-a(\pi)}]=\Pr[\sqrt{\Lambda_n}\ge2^{-a(\pi)/2}]\le2^{a(\pi)/2}2^{-n\mathrm{Hel}_\mu(\pi)\log e}=\varepsilon2^{-\ell(\pi)}.$$
Sum over π using Kraft's inequality. ∎

**Lemma 5.3 (Ville) [known in the paper: `lem:split:ville`].** With probability at least $1-\varepsilon$, simultaneously for all π, $L(\pi)>L_0-\ell(\pi)-\log(1/\varepsilon)$. In the form of `lem:split:ville` this holds for all $n$ at once with $\delta^*$ in place of $\log(1/\varepsilon)$. For one fixed $n$, Markov's inequality on $\mathbb E[\xi_{\mathcal C}(D_n)/\nu(D_n)]\le1$, which follows from Lemma 5.1, suffices.

**Theorem 5.4 (the sample kink) [proved; computed: k3].** Fix ε, $n$ and a length cap $\bar\ell\ge\ell_0$. On the intersection of the events of Lemmas 5.2 and 5.3 and the almost sure event of Lemma 5.1 (probability at least $1-2\varepsilon$), the following hold.
* (i) **Left kink, steepness linear in $n$.** $D_n$ has a zero-window left kink at $(\ell_0,L_0)$ of steepness
  $$\sigma_n:=\min_{\ell<\ell_0}\frac{2\log e\cdot n\gamma(\ell)-2\ell-2\log(1/\varepsilon)}{\ell_0-\ell}\ \ge\ \frac{2\log e\cdot n\gamma_--2\log(1/\varepsilon)}{\ell_0},$$
  where the inequality holds when $2\log e\cdot n\gamma_--2\log(1/\varepsilon)\ge2\ell_0$. For $\ell_0=0$ there is nothing to the left. The statement is vacuous if $\sigma_n\le0$.
* (ii) **Right kink of flatness 1.** For every τ > 1, $D_n$ has a right kink of flatness τ and window $(\ell_0+\log(1/\varepsilon))/(\tau-1)$ at $(\ell_0,L_0)$.
* (iii) **Flat part and a vertex.** If $\bar\ell>\ell_0$ and $n>(\bar\ell+\log(1/\varepsilon))/(\log e\cdot\gamma_{\bar\ell})$, then:
  * $\rho_{D_n}=L_0$ on $[\ell_0,\bar\ell]$, and every program of length at most $\bar\ell$ with fit $L_0$ is equivalent;
  * every right secant from $(\ell_0,L_0)$ is below $\tau_{\bar\ell}:=1+(\ell_0+\log(1/\varepsilon))/(\bar\ell-\ell_0)$;
  * if moreover $\sigma_n>\tau_{\bar\ell}$, then $(\ell_0,L_0)$ is a vertex of $\breve\rho_{D_n}$, and for every $\lambda\in(\tau_{\bar\ell},\sigma_n)$ the λ-MAPs are exactly the shortest equivalent programs.

*Proof.*
* *(i).* Every program shorter than $\ell_0$ is non-equivalent. By Lemma 5.2,
  $$L(\pi)-L_0>2\log e\cdot n\gamma(\ell(\pi))-2\ell(\pi)-2\log(1/\varepsilon)\ge\sigma_n(\ell_0-\ell(\pi)).$$
  An equivalent program of length $\ell_0$ gives $\rho(\ell_0)\le L_0$. For the second form, put $A:=2\log e\cdot n\gamma_--2\log(1/\varepsilon)$. Then $(A-2\ell)/(\ell_0-\ell)\ge A/\ell_0$ if and only if $A\ell\ge2\ell_0\ell$.
* *(ii).* By Lemma 5.3, $L(\pi)>L_0-(\ell(\pi)-\ell_0)-(\ell_0+\log(1/\varepsilon))$, which is at least $L_0-\tau(\ell(\pi)-\ell_0)$ once $(\tau-1)(\ell(\pi)-\ell_0)\ge\ell_0+\log(1/\varepsilon)$.
* *(iii), the flat part.* A non-equivalent π with $\ell(\pi)\le\bar\ell$ has $L(\pi)-L_0>2\log e\cdot n\gamma_{\bar\ell}-2\bar\ell-2\log(1/\varepsilon)>0$, so programs in $(\ell_0,\bar\ell]$ have nonpositive right secants.
* *(iii), the secants beyond $\bar\ell$.* By Lemma 5.3 they are at most $(\ell+\log(1/\varepsilon))/(\ell-\ell_0)<\tau_{\bar\ell}$; the left side is decreasing in $\ell$.
* *(iii), the vertex.* With (i), $(\ell_0,L_0)$ is a zero-window $(\sigma_n,\tau_{\bar\ell})$-kink. Thm 3.2(d) identifies the MAPs as the programs at $(\ell_0,L_0)$; by the flat part these are equivalent, and every equivalent program of length $\ell_0$ is among them. ∎

**Corollary 5.5 (fixed λ, one margin) [proved; computed: k3].** Let $\lambda>1$, $\bar\ell_\lambda:=\ell_0+(\ell_0+\log(1/\varepsilon))/(\lambda-1)$ and $\gamma:=\gamma_{\bar\ell_\lambda}$. If
$$2\log e\cdot n\gamma>(2-\lambda)^+\bar\ell_\lambda+\lambda\ell_0+2\log(1/\varepsilon),$$
then with probability at least $1-2\varepsilon$ every λ-MAP is a shortest equivalent program.

*Proof.*
* *Length.* On the Ville event a λ-MAP has $\lambda\ell+L\le\lambda\ell_0+L_0$ and $L>L_0-\ell-\log(1/\varepsilon)$, hence $\ell<\bar\ell_\lambda$.
* *Non-equivalent programs.* A non-equivalent π with $\ell(\pi)\le \bar\ell_\lambda$ has, on the event of Lemma 5.2,
  $$J_\lambda(\pi)-(\lambda\ell_0+L_0)>(\lambda-2)\ell(\pi)-\lambda\ell_0+2\log e\cdot n\gamma-2\log(1/\varepsilon),$$
  which is positive by the hypothesis, using $(\lambda-2)\ell\ge-(2-\lambda)^+\bar\ell_\lambda$.
* *Equivalent programs* longer than $\ell_0$ lose $\lambda(\ell-\ell_0)>0$. ∎

The corollary is the finite-sample target of T1 with an explicit $n_0(\lambda,\ell_0,\gamma,\varepsilon)$. Its weakness is $\gamma_{\bar\ell_\lambda}$. In natural classes the programs nearest to ν are slightly longer refinements, for example a rate written with more bits, and their gap decays like $4^{-(\ell-\ell_0)}$. In k3, $\gamma_{\bar\ell_\lambda}$ is between $2.7\cdot10^{-4}$ and $6.8\cdot10^{-8}$, and $n_0$ is $3\cdot10^5$ to $5\cdot10^8$.

**Theorem 5.6 (near/far split) [proved; computed: k3].** Let $\lambda>1$, $\bar\ell_\lambda$ as above, and $0<\gamma\le\gamma_0:=\min_{\ell\le\ell_0}\gamma(\ell)$. Call π *near* if $0<\mathrm{Hel}_\mu(\pi)<\gamma$, and put
$$W_{\rm near}(\lambda,\gamma):=\sum_{\pi\ \text{near},\ \ell_0<\ell(\pi)\le \bar\ell_\lambda}2^{-\lambda(\ell(\pi)-\ell_0)}.$$
If $2\log e\cdot n\gamma>(2-\lambda)^+\bar\ell_\lambda+\lambda\ell_0+2\log(1/\varepsilon)$, then with probability at least $1-2\varepsilon-W_{\rm near}(\lambda,\gamma)$ every λ-MAP is a shortest equivalent program.

*Proof.*
* Far non-equivalent programs ($\mathrm{Hel}_\mu\ge\gamma$) of length at most $\bar\ell_\lambda$ are excluded as in Cor 5.5. Every non-equivalent program of length at most $\ell_0$ is far, because $\gamma\le\gamma_0$.
* A near program π with $\ell_0<\ell(\pi)\le \bar\ell_\lambda$ beats the shortest equivalent program only if $\Lambda_n(\pi)\ge2^{\lambda(\ell(\pi)-\ell_0)}$. By Markov's inequality and $\mathbb E\Lambda_n\le1$ this has probability at most $2^{-\lambda(\ell(\pi)-\ell_0)}$. Take a union bound. ∎

In k3 ($d=16$, $p=1/8$, $\ell_0=27$, ε = 0.05):
* with $\gamma=\gamma_0=0.0131$: $n_0=1653$ (λ = 2), 3079 (λ = 4), 5929 (λ = 8), with guarantees 0.10, 0.76, 0.89;
* with $\gamma=10^{-3}$: $n_0=2.2\cdot10^4$ to $7.8\cdot10^4$, with guarantees 0.87–0.90;
* the single-margin Cor 5.5 needs $n_0=3\cdot10^5$ to $5\cdot10^8$;
* empirically, the λ-MAP is $\pi^*$ in 98–100% of samples already at $n=1024$, for λ ∈ {1.5, 2, 4, 8}.

**Corollary 5.7 (almost surely) [proved].** Under (iid) with an infinite sample, write $s_-(D_n):=\min_{\ell(\pi)<\ell_0}(L(\pi)-L_0)/(\ell_0-\ell(\pi))$ and $s_+(D_n):=\sup_{\ell(\pi)>\ell_0}\max\{0,(L_0-L(\pi))/(\ell(\pi)-\ell_0)\}$ for the left steepness and the right slope at $(\ell_0,L_0)$. Almost surely:
* (a) $\liminf_ns_-(D_n)/n\ge2\log e\cdot\min_{\ell<\ell_0}\gamma(\ell)/(\ell_0-\ell)>0$: the left steepness grows linearly in $n$;
* (b) $\limsup_ns_+(D_n)\le1$;
* (c) for every λ > 1, from some $n$ on, every λ-MAP is a shortest equivalent program.

*Proof.*
* Apply Lemma 5.2 with $\varepsilon_n=n^{-2}$. By Borel–Cantelli its event holds for all large $n$. Use Lemma 5.3 in its all-$n$ form with $\delta^*<\infty$.
* (a) follows from Thm 5.4(i) with $\log(1/\varepsilon_n)=2\log n=o(n)$.
* (b): for every fixed cap $\bar\ell$, the flat part of Thm 5.4(iii) holds for large $n$ (with $\varepsilon_n$), so $s_+(D_n)$ is eventually below $1+(\ell_0+\delta^*)/(\bar\ell-\ell_0)$, using Lemma 5.3 in its all-$n$ form for the programs beyond the cap. Let $\bar\ell\to\infty$.
* (c): every λ-MAP has length at most $\bar\ell^*:=\ell_0+(\ell_0+\delta^*)/(\lambda-1)$ by `thm:split:private`(i), applied with a shortest equivalent program in the role of $\pi_\nu$ (so $k=\ell_0$). The finitely many non-equivalent programs of length at most $\bar\ell^*$ have $L(\pi)-L_0\ge2\log e\cdot n\gamma_{\bar\ell^*}-2\bar\ell^*-4\log n\to\infty$. Equivalent programs longer than $\ell_0$ lose $\lambda(\ell-\ell_0)$. ∎

Part (c) is the a.s. identification target of T1. The T1 sub-track (`../iid/`) treats it in full, with the power posterior.

**Proposition 5.8 (the margin is necessary) [proved; computed: k5].** Let π₁ be non-equivalent with $\ell(\pi_1)=\ell_0-\Delta$, $\Delta>0$, and mean KL divergence $\bar K:=\mathbb E_\mu\mathrm{KL}(\nu(\cdot\mid x)\,\Vert\,\nu_{\pi_1}(\cdot\mid x))$ in bits. Then in both sampling schemes, for every $n$ and λ,
$$\Pr[\text{some shortest equivalent program is a λ-MAP}]\le\frac{n\bar K+\log e/e}{\lambda\Delta}.$$

*Proof.*
* An equivalent program of length $\ell_0$ is a λ-MAP only if $X:=L(\pi_1)-L_0\ge\lambda\Delta$.
* $\mathbb EX=n\bar K$, since each input is marginally μ-distributed.
* $\mathbb EX^-=\mathbb E(\log\Lambda_n(\pi_1))^+\le(\log e/e)\,\mathbb E\Lambda_n\le\log e/e$, because $\log x\le(\log e/e)\,x$ for $x>0$.
* Apply Markov's inequality to $X^+$, using $\mathbb EX^+=\mathbb EX+\mathbb EX^-$. ∎

So identification with probability ≥ 1/2 needs $n\ge(\lambda\Delta/2-0.53)/\bar K$. For families with bounded likelihood ratios, KL and Hellinger are comparable [known: e.g. Wong & Shen 1995, Yang & Barron 1998 (unverified exact constants)], so the order $\lambda\ell_0/\gamma$ in Cor 5.5 cannot be improved beyond constants and the dependence on $\bar\ell_\lambda$.

In k5 (Bernoulli pairs, exact binomial):
* the λ-MAP is the true program with probability 1/2 at a sample size between 0.70 and 1.01 times the mean-crossing $n_{\rm KL}=\lambda\Delta/\bar K$, and above 0.95 times it once $\lambda\Delta\ge15$;
* the Hellinger scale $\lambda\Delta/(2\log e\cdot\mathrm{Hel})$ is larger by the ratio $\bar K/(2\log e\cdot\mathrm{Hel})\in[1.84,1.97]$.

**Remark 5.9 (product versus shared; λ = 1) [proved for the first item; computed for the second].**
* *Shared classes.* Lemma 5.2 needs per-input Hellinger gaps, so it is a product-class statement. In a shared class with a universal member $U$, the member has $\Lambda_n(U)\ge2^{-\ell(\pi^*)-\kappa_0}$ on every sample. By Prop 3.5 the left steepness at any $\alpha_0>\ell_U$ is at most $1+(\ell_U+\kappa_0)/(\alpha_0-\ell_U)$ for all $n$. There is no linear growth: the private/shared contrast of `thm:split:private` and `thm:split:shared` in kink form.
* *λ = 1.* Theorem 5.4 never places λ = 1 inside a guaranteed interval, since $\tau_{\bar\ell}>1$. Whether the hull's actual right slope at $\ell_0$ is below 1 depends on the class.
  * In k3, memorising one flipped input costs about $\log(Me/j)$ bits for $\log(1/p)=3$ bits of fit. The right slope has median 0.32–0.68 and maximum 1.33 at $n=16384$, so λ = 1 typically also selects $\pi^*$ there.
  * On the full table (k2), the memoriser edge has slope $1\pm0.1$.
  * The λ = 1 MAP in $\Hcl{\times}$ itself is part of T1.

**Numbers [computed: k3; 200 samples per $n$, $d=16$, $p=1/8$, ε = 0.05].**

| $n$ | $(\ell_0,L_0)$ a vertex | left steepness median (min) | right slope median (max) | uniform σ_n bound | profile σ_n bound |
|---|---|---|---|---|---|
| 64 | 74.5% | 1.46 (−4.70) | 0.32 (6.34) | — | — |
| 256 | 97.5% | 5.84 (1.05) | 0.36 (4.59) | — | — |
| 1024 | 100% | 23.4 (14.0) | 0.42 (3.10) | — | — |
| 4096 | 100% | 93.8 (74.2) | 0.52 (1.48) | 5.43 | 32.9 |
| 16384 | 100% | 374.3 (342.6) | 0.68 (1.33) | 22.7 | 188.0 |

* The left steepness grows linearly: a factor of about 4 per factor 4 in $n$.
* The events of Lemmas 5.2 and 5.3 failed in none of the 1000 samples, even at the level $t=1$ ($\Pr[S\le-1]=\Pr[T\le-1]=0$ against the bound 1/2), for $S$ and $T$ as defined in the script.

---

## 6. Interpretation: "the model consists of the bits that each explain more than λ bits of data"

* **Along the hull.** By Thm 2.2, going from vertex $i-1$ to vertex $i$ adds $\alpha_i-\alpha_{i-1}$ bits of program and saves $\sigma_i$ bits of fit per added bit. The λ-MAP takes exactly the edges with $\sigma_i>\lambda$. So, in hull-averaged form, the model consists of the blocks of bits each of which explains more than λ bits of data. The statement is about blocks along hull edges, not about individual bits: a program is not built bit by bit, and an edge may average a valuable part with a less valuable one.
* **Why noise is never bought for λ > 1.** Beyond any $b$-sufficient program the hull descends at most $1+(b+\kappa)/\Delta$ bits per bit over Δ further bits (Remark 2.5). Describing sampled randomness is a one-bit-for-one-bit trade, and λ > 1 refuses it beyond $(b+\kappa)/(\lambda-1)$ bits (Cor 3.3(a)).
* **Why the model is bought.**
  * With private randomness, a model component worth keeping explains σ ≫ 1 bits per bit. On the full table, the hull falls by about $N(1-H(p))$ bits from the coin to the good model over about $d$ bits, and Prop 4.1 bounds the steepness from below by $N(\Psi^\circ_{t_0}-H(p))/(\kappa_g+d)$. On $n$ samples a sampler explains at least about $2\log e\cdot n\gamma_-/\ell_0$ bits per bit (Thm 5.4).
  * With shared randomness the same parameter explains one bit per bit (Prop 4.4, and Prop 3.5 for any class with a universal member).
* **The split is sharp at a kink, and only there (Thm 3.4).** For supervised data from a sampler in a product class, the kink is at the shortest equivalent program and its steepness grows linearly in $n$. Every fixed λ > 1 eventually lies inside it (Cor 5.7). With teacher errors that are themselves learnable, there are two kinks and λ must lie between them (k2(F); T3).

---

## 7. What is known and what is new here

* **Known.**
  * The hull characterisation is the standard relation between penalised and constrained minimisation in two dimensions, and the project's `lem:setup:hull` in population form [known; standard].
  * Legendre–Fenchel duality [known].
  * Hellinger (Bhattacharyya) affinity bounds and Kraft-weighted union bounds are the usual tools of two-part-code consistency proofs [known in spirit: Barron & Cover 1991, Zhang 2006, as cited in `research/tracks/steeper/notes-final.md` §1.3; that they use exactly Lemma 5.2's form is unverified].
  * Ville's inequality and Hoeffding's without-replacement comparison [known].
  * The parity lemmas are the paper's.
* **New in this sub-track, as far as the project's records show.**
  * The identification of λ-MAPs with the convex minorant of the product structure function on a single data set, with edges, ties, existence at λ = 0 and the duality.
  * The kink definitions and Theorems 3.2 and 3.4, including the converse.
  * Cor 3.3 as the single-data-set split theorem.
  * Prop 3.5, flattening by a universal member.
  * Prop 4.2 and Cor 4.3: λ-ranges for every $p<1/4$ in the full-table case.
  * Prop 4.4: no set kink, in quantitative form.
  * The sample kink with linear steepness, Thm 5.4 and Cor 5.7.
  * The near/far refinement, Thm 5.6.
  * The necessity bound, Prop 5.8.
* **Not checked against the literature.** Whether VV 2004 or VV 2010 state the "two-part MDL with weight λ selects the point of the structure function's convex minorant with slope −λ" relation for set models. This is plausibly folklore in algorithmic statistics [open].

---

## 8. Open questions

1. **Local margins.** Replace $1/\gamma_{\bar\ell_\lambda}$ in Cor 5.5 by a parametric-complexity term for near-equivalent refinements, of order $\log n$ per refinement family. In k3 the true threshold is about 20× below Thm 5.6's $n_0$ and $10^5$× below Cor 5.5's [open].
2. **The right slope at the sample kink in $\Hcl{\times}$.** Does it stay below 1, so that λ = 1 also selects the sampler, or do single fill-in programs reach slope ≥ 1? Lemma `lem:split:stream` bounds only the total fill-in weight [open; part of T1].
3. **Junta errors.** A kink theorem for $m<d$ with right flatness $\approx n2^{-m}$, and a window for $p\ge0.056$ there (`q:teacher:open`(b), `rem:limits:method`) [open; T3].
4. **Set kinks.** Is a product kink of steepness σ at α always accompanied by a set-model slope ≈ 1 when the model's parameter is random? Prop 4.4 proves it for parities via $A_0$. A general version would need a short near-sufficient set model playing the role of $U$ [conjecture].

---

## 9. Files

* `checks/k1_hull.py` (+ `.out`): Thms 2.1, 2.2, Prop 2.3, Thms 3.2, 3.4 and Prop 3.5 in exact rational arithmetic on 600 random point sets.
* `checks/k2_parity_class.py` (+ `.out`): exactly enumerable product and set classes on full parity tables; hulls and MAPs for all λ; two kinks.
* `checks/k3_sample_kink.py` (+ `.out`): samples from a noisy parity on $\{0,1\}^{16}$ without replacement; Lemmas 5.2, 5.3; Thm 5.4; Cor 5.5; Thm 5.6.
* `checks/k4_parity_numbers.py` (+ `.out`): Prop 4.2 numbers; comparison with `cor:teacher:fulltable`; crossovers and interval check.
* `checks/k5_margin_necessity.py` (+ `.out`): Prop 5.8, exact binomial.

---

## Verification log

All scripts were run with Python 3.11.15 (numpy 2.4.6, scipy 1.17.1) on 2026-10-13, and outputs were saved next to them.

* **k1_hull** [deterministic, `random.seed(1)`].
  * Over 600 random point sets with integer lengths, rational fits, infinite fits, duplicates and deliberately collinear points:
    * (A) the gift-wrapping polygon equals the monotone-chain lower hull and the brute-force lower boundary of $\mathrm{conv}(\mathcal A)+\mathbb R^2_{\ge0}$ (single points and bracketing pairs) at every integer and half-integer α;
    * (B) the brute-force argmin of $J_\lambda$ equals the predicted vertex or edge set at 10,333 values of λ, including all 915 breakpoints (12 of them with interior collinear MAPs), with monotone lengths and fits;
    * (C) the formula for $\Phi$ and the Fenchel recovery of $\breve\rho$ hold;
    * (D) the left-kink conclusions hold at 7,219 (point, window, λ) triples, and the right-kink conclusions at 28,800;
    * (E) the equivalence of Thm 3.4, with extreme MAP lengths exactly $\alpha_i$ and $\alpha_j$, holds in 2,399 cases;
    * (F) Prop 3.5's bound holds in 10,430 cases.
  * All assertions passed, in exact `fractions.Fraction` arithmetic.
* **k2_parity_class** [`numpy.default_rng(2)`, instance seeds 11, 21–26, 31].
  * Kraft sums of the classes are 0.245–0.253 ≤ 1.
  * The brute-force λ-MAP agrees with the hull prediction at all 406–410 values of λ per instance (0 mismatches).
  * The numbers quoted in §4 (Illustration) are from this output.
* **k3_sample_kink** [`numpy.default_rng(3)` for $a^*$, `default_rng(1000+n)` per $n$].
  * 1000 samples in total. The quoted numbers are from the output.
  * The structure function is computed exactly for the stated class: Walsh–Hadamard transforms give all parities' mismatches; the fit is linear in the mismatch count at a fixed rate, so extreme counts suffice.
  * $\mathrm{Hel}_\mu$ is computed in closed form for every family.
  * Lemma 5.2's slack is evaluated over all F0, F1 and F2 programs and the best F3 programs. This is a partial check, since F3 programs that memorise inputs outside the sample are not enumerated.
* **k4_parity_numbers** [deterministic].
  * $NH(p)-L_E$ is computed exactly (lgamma) for $N\le2^{24}$ and by the Stirling series with its first correction above that. The two agree to between $3\cdot10^{-10}$ and $2\cdot10^{-8}$ for $d\in\{16,20,24\}$ (k4(e)). At $d=30$ they differ by $2\cdot10^{-6}$; there the lgamma value itself has lost precision, and the script uses Stirling.
  * An earlier version took the difference of two floating-point numbers of size $10^{28}$ at $d=100$. That gave a wrong $b_0$ and an infinite loop in `least_j`; both were fixed before the saved run.
  * $j$ uses exact integer search below $2^{50}$ and an upper bound above it, which only weakens γ.
  * The level-1 G-floor range reproduces $Nc_{\rm hi}=11945$ ($d=20$, κ = 0) and 6456 (κ = 30) of `cor:teacher:fulltable` exactly.
  * The crossover $G_1=H(p)$ at 0.05596 reproduces the paper's value.
* **k5_margin_necessity** [deterministic]. Exact binomial tail probabilities, scipy.
* **Re-run.** After the last edits all five scripts were re-run into a scratch directory.
  * k1, k2, k4 and k5 reproduced their saved outputs byte for byte.
  * k3 differed only in the theorem labels printed, renamed to this file's numbering.
  * k4 was then re-run once more after part (e) was added. The new output differs from the previous one only by the added lines, and it is the saved one.
* **Cross-checks against the paper.**
  * Thm 2.2 reduces to `lem:setup:hull`(iii) on populations.
  * Cor 3.3(a) is `prop:algstat:product` with $\sigma=1$.
  * Prop 4.2 with $t_0=1$ and $G$ floors contains `cor:teacher:fulltable`(i)'s window, and equals it at $d=20$ (k4(a)).
  * Prop 4.4 reproduces `prop:algstat:parity`(i)'s conclusion on set λ-MAPs.
  * Cor 5.7(c) is the a.s. identification of `thm:split:private`(iv), strengthened from "ν-equivalent on the run" to "μ-a.e. equivalent and shortest" under i.i.d. inputs.
* **Proof checks done here.**
  * Each proof was re-derived once, line by line, after writing.
  * The strict decrease of hull slopes and the exact edge/tie description were checked against k1's brute force.
  * Thm 3.4's index choice was checked against k1(E).
  * The level-condition reduction to $t\le\max(t_0,T)$ was checked: k4 initially tested only $t_0\le T$ and therefore missed $t_0=2$ when $T=1$ (at $d\le60$, κ = 30). This was fixed, and the saved output is from the corrected run.
* **Not done.**
  * No referee pass yet.
  * The KL–Hellinger comparison constants cited in §5 were not checked against the sources.
  * The literature question in §7 is open.
