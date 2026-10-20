# Theorem A: a sharper lower bound on the conditioning cost per sample of the margin learner

*Scratch write-up for* `side-results/standard-nngp-parity` *(Section 6). No repository file was edited. Everything below was re-derived from the paper's statements and the cited subcritical lemmas. The numerical checks are in the same folder; see Section 10. This is the revised version after three referee reports. Section 11 answers them point by point.*

> **Revision note: claims weakened after refereeing (read first).**
>
> 1. **The headline was too strong.** The first version said the cost per sample is "at least of order $a^2/\tau_r$". What is proved is $\mathcal D/n\ge c_\delta(a^2/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$. The factor is of order one only when $rH_r\gtrsim d/A_\delta^2$, in particular at linear cutoffs ($\log n\asymp d$). At the bottom of the range, $n=\exp((\log(d+1))^3)$, it is of order $A_\delta(\log d)^{3/2}/\sqrt d$. Remark 8.5 (now proved here, for $\tanh$ only) improves the factor to $\min\{1,rH_r/\sqrt d\}$, which is still small at the bottom of the range. The title, Section 0, the remarks on Theorem A and the replacement blocks R1, R5, R6, R7 and R9 now state the factor.
> 2. **Corollary 6 is about the margin scale.** It shows that no upper bound on the cost rescues the subcritical head-bound argument when the clipped-parity lemma is applied at the margin scale $a$, or more generally at any clipping scale $b\le4a(c_\delta C_\delta\rho^3dH_r)^{1/2}$. It says nothing against clipping at a scale of order $\sqrt d$ when $\rho$ is small. The subcritical strategy clips at an amplitude scale, so Corollary 6 does not refute it. With Lemma 6.1, a version of that strategy would have to clip at a scale of order at least $\sqrt d$ and would need an amplitude bound there; no such bound is available, and none is excluded. The first version's R6 ("the subcritical argument cannot give an exponential bound whatever upper bound on the cost holds") and R7 claimed more. Both are now restricted to the margin scale, and Corollary 6(d) records how the obstruction depends on the scale.
> 3. **With the exact Gram norm the obstruction is conditional.** R2's "an $\exp(\Omega(d))$ proof along these lines therefore needs …" is proved with Lemma 6.1's Gram bound only. With $\|Q_{SS}\|_{\rm op}$ itself it needs $\theta_r\ge c/\sqrt r$ (Lemma T), which is unproved.
> 4. **The numerical range of $\theta_r\sqrt r$ was misstated.** The range $[0.80,3.06]$ holds for odd $r\le0.065d$, not for all $r\le193$. For larger $r/d$ the quantity is larger. Only the lower bound $0.80$ is used, and it holds at every $r$ tested.
>
> Theorem A, Proposition 4 and Corollaries 5 and 6 are unchanged as mathematics. All three referees re-derived their proofs and found no error.

---

## 0. Results and verdict

**Theorem A** (Section 6). Take $\phi=\tanh$ (only oddness of the kernel is used), fixed depth, gains and margin $a$, and $\delta\in(0,1/8)$. For large $d$ and every $n$ with $\exp((\log(d+1))^3)\le n\le e^{c_1d}$, at the adaptive cutoff $r=r(n)$, with probability at least $1-4\delta$ over iid uniform parity samples,
$$
\mathcal D(S)\ \ge\ \frac{\delta n a^2}{\tau_r}\min\Bigl\{\frac1{16},\ \frac{A_\delta\log(2D_r)}{128\,b_r}\Bigr\}-\log2,
\qquad\text{hence}\qquad
\frac{\mathcal D(S)}n\ \ge\ c_\delta\,\frac{a^2}{\tau_r}\,\min\Bigl\{1,\ A_\delta\sqrt{\tfrac{rH_r}{d}}\Bigr\}.
$$
The proof uses only the training margins $y_iG(X_i)>a$. The factor $\min\{1,A_\delta\sqrt{rH_r/d}\}$ is of order one at linear cutoffs and tends to $0$ at sublinear ones. At the bottom of the range it is of order $A_\delta(\log d)^{3/2}/\sqrt d$. So the bound is of order $a^2/\tau_r$ per sample only at linear cutoffs (Section 6).

**Proposition 4** (Section 7, deterministic). For every sequence $S$ of $n$ inputs and every $0\le r<d$,
$$\lambda_{\max}(Q_{SS})\ \ge\ \max\{n\lambda_{r+1},\ \tau_r\}.$$

**Consequences for Section 6 of the paper** (Sections 8 and 9).

1. **(eq:matching) is false for every fixed $K$.** For every $\delta\in(0,1/8)$ and $K>0$ there is $d_0$ such that, for $d\ge d_0$ and every $n$ in the range, (eq:matching) fails on the event of Theorem A. So it holds with probability at most $4\delta<1/2$. It fails by a factor of at least $c\min\{\sqrt{d\,rH_r},A_\delta rH_r\}/K\to\infty$, which is $\gtrsim(\log d)^3$ at the bottom of the range and $\gtrsim d$ at linear $r$. The hypothesis of the "extension suggested by the proof" therefore never holds for large $d$.
2. **The implication "(eq:matching) $\Rightarrow\exp(\Omega(d))$" is true.** I re-checked every step: the head, band and tail bounds, the clipped-parity step and the probability bookkeeping are correct consequences of the hypothesis. But the implication is vacuous for $d\ge d_0(K)$.
3. **What is false, or must be withdrawn.**
   - The sentence "So the missing ingredient is an upper bound on the conditioning cost that matches the proposition up to constants" is false. The ingredient it names cannot exist: Proposition 6.2 is not sharp, since $\mathcal D/n$ exceeds its lower bound by a factor tending to infinity (Corollary 5).
   - The preceding sentence, "Proposition 6.2 says that (eq:matching) cannot hold with a smaller right-hand side by more than a constant factor", is literally true, as a consequence of Proposition 6.2. Its intended reading is false. That reading, recorded in `verification/review.md` as "the proposition forces the form of the matching bound up to constants", is that (eq:matching) is the sharp order of the cost. In fact the cost is larger by an unbounded factor.
   - The heuristic paragraph's "If that mass sits mainly in the band just above $r$, the cost should match the proposition, and the argument above would give $\exp(\Omega(d))$" is **incompatible with Theorem A**. On the event of Theorem A the cost never matches the proposition, whatever the posterior does. Strictly, the conditional is false if its antecedent can occur and vacuous otherwise. Whether the posterior's mass can sit mainly in the band just above $r$ is not decided here. Either way the sentence must be withdrawn.
   - Several statements are vacuous or misleading and should be withdrawn: the abstract ("We explain why an upper bound on that cost matching our lower bound would complete an exponential proof"), introduction item 4, the Section 6 introduction, the status-table row, README line 18, and the `catalog.json` summary.
4. **No upper bound on the cost rescues the head-bound route at the margin scale** (Corollary 6). With the paper's Gram bound $b_r\tau_r$ (Lemma 6.1), Theorem A forces the head estimate $8\tau_r+16b_r\tau_r\mathcal D/n$ to be at least $c\,a^2\min\{\sqrt{d\,rH_r},A_\delta rH_r\}$, whatever valid upper bound on $\mathcal D$ is inserted. With the clipped-parity lemma at the margin scale $a$, the route's output is then at least $c(\rho^3dH_r)^{1/2}$, which tends to infinity at every fixed $\rho$.
   - **Scale.** At a clipping scale $b$ the same lower bound is multiplied by $a/b$ (Corollary 6(d)). It excludes every $b\le4a(c_\delta C_\delta\rho^3dH_r)^{1/2}$, so at fixed $\rho$ every $b=o(\sqrt d)$. For $b$ of order $\sqrt d$ it tends to $0$ as $\rho\to0$, so it does not exclude such scales. A version of the subcritical strategy that uses Lemma 6.1 must therefore clip at a scale of order at least $\sqrt d$, and it then needs an amplitude bound $\E^*\Pp_x\{|G(x)|\le b\}=o(1)$ there. The subcritical paper's own amplitude step, [subcritical, Lemma 7.5], gives no useful amplitude at the standard scaling, and nothing here proves or excludes such a bound. Corollary 6 therefore says nothing against the subcritical strategy itself, only against its margin-scale variant.
   - **Exact Gram norm.** With $\|Q_{SS}\|_{\rm op}$ in place of $b_r\tau_r$, the head and band estimates are still at least $c\,a^2(n\lambda_{r+1}/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$. This diverges at fixed $\rho$ if $\theta_r\ge c/\sqrt r$. That holds numerically and is asserted by the exploration's Lemma T, but it is not proved. If $\theta_r$ were only of order $1/r$, Corollary 6 would not exclude the exact-norm version.
5. **Replacement text** (LaTeX) is in Section 9: a new Proposition 6.3 with proof, a rewritten "What this shows and does not show" paragraph, edits to the abstract, the introduction, the Section 6 introduction, the second-route paragraph, the heuristic paragraph and the status table, and a citation fix for the head bound (R10).

---

## 1. Setting and notation

Notation follows `standard-nngp-parity.tex`.

- **Cube and dimensions.** $\mathcal X=\{-1,1\}^d$ with uniform measure, $M=2^d$, $D=d+1$, $D_r=\sum_{q\le r}\binom dq$, $H_r=\log(eD/r)$ and $\rho=r/d$. The target is full parity, $f=\chi_{[d]}$, with labels $y_i=f(X_i)$. The inputs $X_1,\dots,X_n$ are iid uniform, and repeats are allowed.
- **Prior.** $G\sim N(0,K)$ with $K(x,y)=\sum_{U\subseteq[d]}\lambda_{|U|}\chi_U(x)\chi_U(y)$. The normalized eigenvalues $\lambda_q$ are positive and nonincreasing in $q$ (paper, Lemma 2.5(c),(d), `lem:spectrum`). For odd $F$, $\lambda_{2k}=\lambda_{2k+1}$ (Lemma 2.5(e)). The kernel amplitude is $A=K(x,x)$; it differs from the sampling constant $A_\delta$.
- **Tail kernel.** $Q=K_{>r}$, so $Q(x,y)=\sum_{|U|>r}\lambda_{|U|}\chi_U(x)\chi_U(y)$. Then $Q(x,x)=\tau_r=\sum_{q>r}\binom dq\lambda_q\le A$, and $Q_{SS}=(Q(X_i,X_j))_{i,j\le n}$.
- **Event and cost.** $A_S=\{|G(x)|>a\ \forall x;\ y_iG(X_i)>0\ \forall i\}$ and $\mathcal D(S)=-\log\Pp(G\in A_S)$.
- **Adaptive cutoff.** $r=r(n)$ is the largest odd integer with $A_\delta D_r\log(2D_r)\le n$, where $A_\delta$ is the constant of [subcritical, Lemma 4.4].
- **Gram constants.** $b_r=C_\delta(1+\sqrt{d\,rH_r}+rH_r)$ and $c_1=c_1(\delta)$ are as in the paper's Lemma 6.1 (`lem:gram`). We may assume $A_\delta\ge1$ and $C_\delta\ge1$.
- **Spectral ratio.** $\theta_r=\binom D{r+2}\lambda_{r+1}/\tau_r\in(0,1]$ for odd $F$ and odd $r$ (by (I2) below).
- **Sample statistic.** For a sample $S$ write
  $$\varepsilon^2(S)=\sum_{|U|\le r}\Bigl(\frac1n\sum_{i=1}^n y_i\chi_U(X_i)\Bigr)^2 .$$

## 2. Inputs (cited, not re-proved)

**(I1) Monotonicity and pairing** (paper, Lemma 2.5, `lem:spectrum`). The $\lambda_q$ are nonincreasing. For odd $F$ and odd $r$, $\lambda_{r+1}=\lambda_{r+2}$.

**(I2) Level mass** (paper, Lemma 2.6(b), `lem:levels`). For odd $F$ and odd $r$, $\binom D{r+2}\lambda_{r+1}\le\tau_r$. This is used only in Section 8.

**(I3) Squared coercivity** [subcritical, Lemma 4.4]. For each $\delta>0$ there is $A_\delta$ such that the following holds whenever $r\le d/64$ and $n\ge A_\delta D_r\log(2D_r)$. With probability at least $1-\delta$ over iid uniform $X_i$,
$$\frac1n\sum_i(f(X_i)P(X_i))_-^2\ge\tfrac14\|P\|_2^2\quad\text{for every }P\text{ of degree at most }r.$$
The bound is uniform over $P$. Theorem A needs this, because it is applied to the random polynomial $p=G_{\le r}$. It is a statement for each fixed $n$, and it is applied at the deterministic cutoff $r=r(n)$.

**(I4) Tail Gram bound** (paper, Lemma 6.1). Let $F$ be odd. For large $d$, every $n\in[\exp((\log(d+1))^3),e^{c_1d}]$ and $r=r(n)$:
- with probability at least $1-\delta$, $\|Q_{SS}\|_{\rm op}\le b_r\tau_r$;
- deterministically, $(\log d)^2/4\le r\le d/64$;
- by maximality of $r$, $n<A_\delta D_{r+2}\log(2D_{r+2})\le CA_\delta\binom D{r+2}rH_r$.

The statement of Lemma 6.1 asserts only that some $c_1>0$ works. Its proof takes $2c_1<\log2-\mathsf h(1/4)$, so $c_1<\frac12\log2$. (The conclusion persists if $c_1$ is decreased, so this may be assumed in any case.) The constant $C$ in the third bullet can be taken to be $8$, for $1\le r\le d/64$. Indeed $D_{r+2}\le2\binom d{r+2}\le2\binom D{r+2}$, since $r+2\le(d+1)/3$ and the ratios $\binom d{q-1}/\binom dq=q/(d-q+1)$ are at most $\frac12$ for $q\le(d+1)/3$. Also $\log(2D_{r+2})\le\log2+(r+2)\log(ed/(r+2))\le\log2+3rH_r\le4rH_r$, using $D_k\le(ed/k)^k$, $\log(ed/(r+2))\le H_r$ and $H_r\ge1$. Multiplying gives $D_{r+2}\log(2D_{r+2})\le8\binom D{r+2}rH_r$ (check E4 in Section 10).

I checked the proof of Lemma 6.1 against [subcritical, Lemmas 5.1–5.2] and found no problem. The Krawtchouk far-pair bound, the trivial bound for $j>D-r$ via monotonicity, and the near-pair and collision terms with $2c_1<\log2-\mathsf h(1/4)$ are all fine.

**(I5) Gaussian facts.** These are standard and are proved in Lemma 2 below.

**Caveats: what is inherited and not re-verified.**
- **(I3) is the load-bearing external input.** I checked that it is applied within its hypotheses (parity labels, iid uniform inputs, $r\le d/64$, $n\ge A_\delta D_r\log(2D_r)$, fixed $n$, uniform over $P$). I did not re-verify its proof. That proof runs through [subcritical, Lemmas 4.1 and 4.3]. Lemma 4.1 uses a homogeneous (seminorm) form, [subcritical, eq. (lee-metric)], of an intermediate estimate in the proof of Lee's chaining theorem [Lee 2023, Lemma 2.12, eq. (2.20)], with the additive constant of Lee's eq. (2.26) removed. [subcritical, Remark 4.2] explains why the removal is legitimate. This modifies an intermediate step; it is not a stated theorem of Lee. I could not check it against the source, since arxiv.org is blocked here. The dependence matters: an additive term of order $V^2$ there would make $\E\Delta_n$ of order one. The standard substitutes I know, such as small-ball arguments, lose factors like $9^r$ and do not reach $n$ of order $D_r\log D_r$. Proposition 6.2 and the definition of $r(n)$ depend on the same lemma. So this caveat does not affect the comparison between Theorem A, Proposition 6.2 and (eq:matching). It does affect the unconditional status of all three.
- **(I4)** goes through [subcritical, Lemma 5.2], whose proof uses Tropp (2008, *On the conditioning of random subdictionaries*), Theorem 1.1. I recalled that theorem rather than re-reading it; referee 3 recalled the same form.
- **Remark 8.5** uses Lieb's concavity theorem, cited and not re-proved. The main results do not use the remark.

## 3. Lemma 1: two sample moments

**Lemma 1.** Let $0\le r<d$ and let $X_1,\dots,X_n$ be iid uniform with $y_i=f(X_i)$.

- (a) $\E\,\varepsilon^2(S)=D_r/n$.
- (b) $\E\,y^{\mathsf T}Q_{SS}\,y=n\tau_r+n(n-1)\lambda_d$.
- (c) If $r<d/2$ and $n\le2^{d-1}$, then $\E\,y^{\mathsf T}Q_{SS}\,y\le2n\tau_r$.

*Proof.* (a) We have $y_i\chi_U(X_i)=\chi_{[d]}(X_i)\chi_U(X_i)=\chi_{[d]\setminus U}(X_i)$. For $|U|\le r<d$ the set $[d]\setminus U$ is nonempty. So the variables $Z_i=\chi_{[d]\setminus U}(X_i)$ are iid, with mean $0$ and $Z_i^2=1$, and $\E(n^{-1}\sum_iZ_i)^2=1/n$. Summing over the $D_r$ sets $U$ gives (a).

(b) The diagonal terms give $\sum_iQ(X_i,X_i)=n\tau_r$. For $i\ne j$,
$$\E\,y_iy_jQ(X_i,X_j)=\sum_{|U|>r}\lambda_{|U|}\,\E\chi_{[d]\setminus U}(X_i)\,\E\chi_{[d]\setminus U}(X_j)=\lambda_d,$$
because only $U=[d]$ contributes, and $|[d]|=d>r$.

(c) By monotonicity, $\tau_r=\sum_{q>r}\binom dq\lambda_q\ge\lambda_d\sum_{q>r}\binom dq\ge2^{d-1}\lambda_d$, since $\{q>r\}\supseteq\{q\ge d/2\}$ when $r<d/2$. Hence $n(n-1)\lambda_d\le n^2\tau_r/2^{d-1}\le n\tau_r$. $\square$

## 4. Lemma 2: Gaussian tails

**Lemma 2.** Let $t\sim N(0,\Sigma)$ in $\R^n$ and $y\in\R^n$.

- (a) For $x\ge0$, $\Pp\{y^{\mathsf T}t>x\}\le\exp(-x^2/(2y^{\mathsf T}\Sigma y))$. The left side is $0$ if $y^{\mathsf T}\Sigma y=0$.
- (b) For $s\ge0$, $\Pp\{\|t\|^2>s\}\le\exp\bigl(-(s-2\log2\,\operatorname{tr}\Sigma)/(4\|\Sigma\|_{\rm op})\bigr)$. In particular, if $s\ge4\log2\,\operatorname{tr}\Sigma$, then $\Pp\{\|t\|^2>s\}\le\exp(-s/(8\|\Sigma\|_{\rm op}))$.

*Proof.* (a) $y^{\mathsf T}t\sim N(0,y^{\mathsf T}\Sigma y)$, and $\Pp\{N(0,1)>z\}\le e^{-z^2/2}$ for $z\ge0$.

(b) Let $\mu_k$ be the eigenvalues of $\Sigma$ and $\theta=1/(4\mu_{\max})$. Then $\E e^{\theta\|t\|^2}=\prod_k(1-2\theta\mu_k)^{-1/2}$ with $2\theta\mu_k\le\frac12$. The function $-\log(1-x)$ is convex, vanishes at $0$ and equals $\log2$ at $x=\frac12$, so $-\log(1-x)\le2\log2\cdot x$ on $[0,\frac12]$. Hence
$$\log\E e^{\theta\|t\|^2}\le\log2\sum_k2\theta\mu_k=2\theta\log2\operatorname{tr}\Sigma,$$
and Markov's inequality applied to $e^{\theta\|t\|^2}$ gives the claim. $\square$

## 5. Proposition 3: the deterministic core

**Proposition 3.** Fix a sequence $S$ of $n$ inputs with labels $y_i=f(X_i)$, an integer $0\le r<d$, and $a>0$. Assume:

- (i) $\frac1n\sum_i(y_iP(X_i))_-^2\ge\frac14\|P\|_2^2$ for every $P$ of degree at most $r$;
- (ii) $\varepsilon^2(S)\le e$;
- (iii) $y^{\mathsf T}Q_{SS}y\le V$;
- (iv) $\|Q_{SS}\|_{\rm op}\le\Lambda$.

Put $s=na^2/(16e)$ and assume $s\ge4\log2\cdot n\tau_r$. Then
$$
\Pp\{y_iG(X_i)>a\ \forall i\}\ \le\ \exp\Bigl(-\frac{n^2a^2}{8V}\Bigr)+\exp\Bigl(-\frac{s}{8\Lambda}\Bigr),
\qquad\text{so}\qquad
\mathcal D(S)\ \ge\ \min\Bigl\{\frac{n^2a^2}{8V},\frac{s}{8\Lambda}\Bigr\}-\log2 .
$$

*Proof.* Write $p=G_{\le r}$, $t=G_{>r}$ and $t_S=(t(X_i))_{i\le n}$. Then $t_S\sim N(0,Q_{SS})$, whatever the joint law of $p$ and $t$. Every $G\in A_S$ satisfies $y_iG(X_i)>a$ for all $i$, because $y_iG(X_i)>0$ and $|G(X_i)|>a$. So $A_S\subseteq B:=\{y_iG(X_i)>a\ \forall i\}$, and on $B$
$$na<\sum_iy_iG(X_i)=\sum_iy_ip(X_i)+y^{\mathsf T}t_S .$$
Expanding in the Walsh basis and applying Cauchy–Schwarz,
$$\sum_iy_ip(X_i)=\sum_{|U|\le r}\widehat p(U)\sum_iy_i\chi_U(X_i)\le\|p\|_2\,n\,\varepsilon(S).$$

*Case 1: $2\varepsilon(S)\|p\|_2\le a$.* This includes $\varepsilon(S)=0$. Then $y^{\mathsf T}t_S>na/2$.

*Case 2: $2\varepsilon(S)\|p\|_2>a$.* On $B$, $y_ip(X_i)+y_it(X_i)>0$, so $(y_ip(X_i))_-\le|t(X_i)|$. By (i),
$$\|t_S\|^2\ \ge\ \sum_i(y_ip(X_i))_-^2\ \ge\ \frac n4\|p\|_2^2\ >\ \frac{na^2}{16\varepsilon(S)^2}\ \ge\ \frac{na^2}{16e}=s .$$

Hence $B\subseteq\{y^{\mathsf T}t_S>na/2\}\cup\{\|t_S\|^2>s\}$. Lemma 2(a) bounds the first probability by $\exp(-n^2a^2/(8V))$. For the second, Lemma 2(b) applies since $\operatorname{tr}Q_{SS}=n\tau_r$ and $s\ge4\log2\cdot n\tau_r$; it gives $\exp(-s/(8\Lambda))$. Finally, $\Pp(A_S)\le\Pp(B)\le2\max\{\cdot,\cdot\}$. $\square$

*Remarks.*
1. Only the training margins were used. The global margin enters only through $A_S\subseteq B$.
2. The parity labels enter only through (ii) and (iii). For labels correlated with a low-degree function, $\varepsilon^2$ is of order one, and Case 1 becomes vacuous, as it must.

## 6. Theorem A

**Theorem A.** Let $\phi=\tanh$, or any odd activation satisfying Assumption 2.1. Fix $L$, the gains, $a>0$ and $\delta\in(0,1/8)$, and let $c_1$, $C_\delta$ and $b_r$ be as in Lemma 6.1. There is $d_0$ such that, for every $d\ge d_0$ and every integer $n$ with $\exp((\log(d+1))^3)\le n\le e^{c_1d}$, with $r=r(n)$, the following holds with probability at least $1-4\delta$ over iid uniform inputs labelled by full parity:
$$
\mathcal D(S)\ \ge\ \frac{\delta na^2}{\tau_r}\min\Bigl\{\frac1{16},\frac{A_\delta\log(2D_r)}{128\,b_r}\Bigr\}-\log2. \tag{A1}
$$
Consequently, on the same event,
$$
\frac{\mathcal D(S)}n\ \ge\ c_\delta\,\frac{a^2}{\tau_r}\,\min\Bigl\{1,\ A_\delta\sqrt{rH_r/d}\Bigr\},\qquad c_\delta=\frac\delta2\min\Bigl\{\frac1{16},\frac1{480\,C_\delta}\Bigr\}. \tag{A2}
$$

*Proof.* By (I4), for $d$ large, $(\log d)^2/4\le r\le d/64$. Also $n\le e^{c_1d}\le2^{d-1}$. Here we use that the proof of Lemma 6.1 takes $2c_1<\log2-\mathsf h(1/4)$, so $c_1<\frac12\log2$ and $c_1d\le(d-1)\log2$ for $d\ge2$ (see (I4)). Let $E$ be the intersection of four events:

- $E_1$: the coercivity event (I3) at degree $r$. It applies because $r\le d/64$ and $n\ge A_\delta D_r\log(2D_r)$ by the definition of $r(n)$, and $\Pp(E_1^c)\le\delta$.
- $E_2$: the Gram event (I4), with $\Pp(E_2^c)\le\delta$.
- $E_3=\{\varepsilon^2(S)\le D_r/(n\delta)\}$. By Lemma 1(a) and Markov's inequality, $\Pp(E_3^c)\le\delta$.
- $E_4=\{y^{\mathsf T}Q_{SS}y\le2n\tau_r/\delta\}$. By Lemma 1(c) and Markov's inequality, $\Pp(E_4^c)\le\delta$.

So $\Pp(E)\ge1-4\delta$. On $E$, apply Proposition 3 with $e=D_r/(n\delta)$, $V=2n\tau_r/\delta$ and $\Lambda=b_r\tau_r$. Then
$$\frac{n^2a^2}{8V}=\frac{\delta na^2}{16\tau_r},\qquad s=\frac{\delta n^2a^2}{16D_r}\ \ge\ \frac{\delta A_\delta\log(2D_r)}{16}\,na^2 .$$
The last step uses $n\ge A_\delta D_r\log(2D_r)$. Since a smaller $s$ is still a valid threshold in Case 2, we may use $s'=\delta A_\delta\log(2D_r)na^2/16$. The condition $s'\ge4\log2\cdot n\tau_r$ means $\delta A_\delta\log(2D_r)a^2\ge64\log2\cdot\tau_r$. It holds for large $d$ because $\tau_r\le A$ and $\log(2D_r)\ge\log(2(d+1))$. Then $s'/(8\Lambda)=\delta A_\delta\log(2D_r)na^2/(128b_r\tau_r)$, which proves (A1).

For (A2), let $1\le r\le d/64$; the numerical checks behind the constants are in Section 10.

- $\log(2D_r)\ge\log\binom dr\ge r\log(d/r)\ge0.8\,rH_r$. Here $\log(d/r)\ge\log64$ and $H_r\le1.016+\log(d/r)$, and $x/(1.016+x)\ge0.80$ for $x\ge\log 64$.
- $rH_r\le0.081\,d$, because $r\mapsto r\log(e(d+1)/r)$ is increasing for $r<d+1$ and equals $0.0809\,d$ at $r=d/64$. Hence $1\le rH_r\le\sqrt{d\,rH_r}$, and $b_r\le3C_\delta\sqrt{d\,rH_r}$.

Therefore
$$\frac{A_\delta\log(2D_r)}{128b_r}\ \ge\ \frac{0.8\,A_\delta\,rH_r}{384\,C_\delta\sqrt{d\,rH_r}}=\frac{A_\delta\sqrt{rH_r/d}}{480\,C_\delta}.$$
Using $\min\{\alpha,\beta X\}\ge\min\{\alpha,\beta\}\min\{1,X\}$, the minimum in (A1) is at least $\min\{\frac1{16},\frac1{480C_\delta}\}\min\{1,A_\delta\sqrt{rH_r/d}\}$. The term $\log 2$ is at most half of the main term for large $d$. Indeed $na^2/\tau_r\ge na^2/A$, $\min\{1,A_\delta\sqrt{rH_r/d}\}\ge\min\{1,A_\delta\}/\sqrt d$, and $n\ge\exp((\log(d+1))^3)$. $\square$

*Remarks on Theorem A.*
- The threshold $d_0$ depends on $L$, the gains, $a$ and $\delta$ (through $A$, $A_\delta$, $C_\delta$, $c_1$). It is uniform in $n$ over the range.
- **The factor $\min\{1,A_\delta\sqrt{rH_r/d}\}$ is not of order one in most of the range.** It is of order one only when $rH_r\gtrsim d/A_\delta^2$, in particular at linear $r$, that is, when $\log n\asymp d$. For fixed $A_\delta$ it tends to $0$ whenever $\log n=o(d)$, because $rH_r=(1+o(1))\log D_r\le(1+o(1))\log n$. At the bottom of the range, $n=\exp((\log(d+1))^3)$, the definition of $r(n)$ gives $\log D_r=(1+o(1))(\log d)^3$, hence $rH_r=(1+o(1))(\log d)^3$ and $r=(1+o(1))(\log d)^2$. Numerically, $rH_r/(\log(d+1))^3\in[0.990,1.000]$ and $r/(\log d)^2\in[1.10,1.59]$ for $d$ from $10^5$ to $10^{40}$ (`check_bottom.out`). The factor is therefore of order $A_\delta(\log d)^{3/2}/\sqrt d$ there. (The first version wrote $A_\delta(\log d)^{3/2}/(2\sqrt d)$. That figure used Lemma 6.1's guaranteed lower bound $r\ge(\log d)^2/4$ instead of the actual $r(n)$, and was off by a constant factor.) So the cost per sample is of order $a^2/\tau_r$ only at linear cutoffs, and is proved to be at least $c\,a^2A_\delta(\log d)^{3/2}/(\tau_r\sqrt d)$ at the bottom of the range.
- Remark 8.5, which is now proved here for $\tanh$, gives a bound of the same form with the factor $\min\{1,rH_r/\sqrt d\}$ (and another constant $c'_\delta$), on an event of probability at least $1-4\delta$. Up to constants that factor is the larger one once $rH_r\ge A_\delta^2$. It is still small at the bottom of the range, of order $(\log d)^3/\sqrt d$, and it equals one once $rH_r\ge\sqrt d$.

## 7. Proposition 4: the top eigenvalue of the sampled tail Gram matrix

**Proposition 4.** For every sequence $S$ of $n$ inputs (repeats allowed) and every $0\le r<d$,
$$\|Q_{SS}\|_{\rm op}\ \ge\ \max\{n\lambda_{r+1},\ \tau_r\}.$$

*Proof.* Fix $U_0$ with $|U_0|=r+1$ and let $v=(\chi_{U_0}(X_i))_{i\le n}\in\{\pm1\}^n$, so $\|v\|^2=n$. Every summand of $Q=\sum_{|U|>r}\lambda_{|U|}\chi_U\chi_U^{\mathsf T}$ is positive semidefinite. Hence $Q_{SS}\succeq\lambda_{r+1}vv^{\mathsf T}$, and
$$\|Q_{SS}\|_{\rm op}\ \ge\ \frac{v^{\mathsf T}Q_{SS}v}{\|v\|^2}\ \ge\ \lambda_{r+1}\frac{(v^{\mathsf T}v)^2}{\|v\|^2}=n\lambda_{r+1}.$$
Also $\|Q_{SS}\|_{\rm op}\ge\operatorname{tr}Q_{SS}/n=\tau_r$. $\square$

No condition such as $\binom d{r+1}\le n$ is needed; the single test vector suffices. For comparison, the intrinsic-dimension bound proved in Remark 8.5 (Lemma 8.5a) gives $\E\|Q_{SS}\|_{\rm op}\le(e-1)n\lambda_{r+1}+\tau_r\log(\tau_r/\lambda_{r+1})$. So, in expectation, Proposition 4 is sharp up to the $\tau_r\log$ term.

## 8. Consequences

Throughout this section, $\delta\in(0,1/8)$ is fixed, $d\ge d_0$, and $n\in[\exp((\log(d+1))^3),e^{c_1d}]$. "The event" means the event $E$ of Theorem A.

### 8.1 Comparison with Proposition 6.2

Proposition 6.2 (`prop:obstruction`) gives
$$\mathcal D/n\ge(a^2-10\tau_r)/\bigl(\tau_r(16b_r+4CA_\delta rH_r)\bigr)\asymp a^2/(\tau_r b_r),$$
using $rH_r\le\sqrt{d\,rH_r}\le b_r/C_\delta$. Theorem A improves this by a factor of order
$$b_r\min\{1,A_\delta\sqrt{rH_r/d}\}\ \asymp\ \min\{\sqrt{d\,rH_r},\ A_\delta rH_r\}\ \longrightarrow\ \infty .$$

The improvement comes from the proof technique. Proposition 6.2 uses an $L^2$ bound through the entropy lemma, which pays $\|Q_{SS}\|_{\rm op}\approx b_r\tau_r$. Theorem A uses the sign-aligned linear statistic $\sum_iy_iG(X_i)>na$, whose high-degree part has variance $y^{\mathsf T}Q_{SS}y\approx n\tau_r$ (Lemma 1). Parity is incoherent with the top eigenvectors of $Q_{SS}$.

### 8.2 Corollary 5: (eq:matching) is false for every fixed $K$

**Corollary 5.** For every $K>0$ there is $d_0(K)$ such that, for $d\ge d_0(K)$ and every $n$ in the range, on the event,
$$\frac{\mathcal D(S)}n\cdot\frac{\tau_r(b_r+rH_r)}{a^2}\ \ge\ \frac\delta2\min\Bigl\{\frac{C_\delta\sqrt{d\,rH_r}}{16},\ \frac{A_\delta rH_r}{160}\Bigr\}\ >\ K .$$
Hence $\Pp_S\{(\mathrm{eq{:}matching})\text{ holds}\}\le4\delta<\frac12$. No sample event of probability at least $3/4$ (indeed, more than $4\delta$) carries (eq:matching).

*Proof.* Multiply (A1) by $\tau_r(b_r+rH_r)/(na^2)$. The main term is at least
$$\delta\min\Bigl\{\frac{b_r}{16},\ \frac{A_\delta\log(2D_r)}{128}\Bigr\}\ \ge\ \delta\min\Bigl\{\frac{C_\delta\sqrt{d\,rH_r}}{16},\ \frac{A_\delta rH_r}{160}\Bigr\},$$
using $b_r+rH_r\ge b_r$ and $\log(2D_r)\ge0.8rH_r$. The error term is $\log2\cdot\tau_r(b_r+rH_r)/(na^2)\le C d/n\to0$. The main term tends to infinity uniformly in $n$, because $\sqrt{d\,rH_r}\ge\sqrt d$ and $rH_r\ge r\ge(\log d)^2/4$. Suppose (eq:matching) held on an event $E'$ with $\Pp(E')>4\delta$. Then $E\cap E'\ne\emptyset$, which contradicts the display. $\square$

The constant $K$ may depend on $\delta$, $a$, $L$ and the gains; it may not depend on $d$. Even a $K$ growing with $d$ must satisfy $K\ge c\min\{\sqrt{d\,rH_r},A_\delta rH_r\}$. That is at least $c(\log d)^3$ at the bottom of the range and at least $c\,\rho\,dH_r$ at linear $r$. With such $K$ the paragraph's conclusion $C\rho\sqrt K$ is useless.

### 8.3 The paragraph's conditional argument is valid, hence vacuously true

Assume (eq:matching) on an event of probability at least $3/4$, and intersect with $E_1\cap E_2$. Each step of the paragraph then checks out.

- **Head.** $\E^*\|G_{\le r}\|^2\le8\tau_r+16b_r\tau_r\mathcal D/n\le8\tau_r+16Ka^2$. The first inequality is the argument of [subcritical, eq. (45)]: it combines eqs. (41) and (43) there, with Lemma 6.1 in place of that paper's Gram bound, eq. (44).
- **Band.** $4\lambda_{r+1}\mathcal D\le4\tau_r\,\frac{n}{\binom D{r+2}}\,\frac{Ka^2}{\tau_r(b_r+rH_r)}\le CA_\delta Ka^2$, by (I2) and (I4).
- **Tail.** $4\lambda_{u+1}\mathcal D\le4Ka^2n/(\binom D{u+2}(b_r+rH_r))\le CKa^2\binom D{r+2}/\binom D{u+2}$. With $u-r=2\lceil10\log(d+1)\rceil$, each one-step ratio is $(j+1)/(D-j)\le2\alpha$, so the binomial ratio is at most $(2\alpha)^{20\log(d+1)}\le d^{-10}$ for $\alpha\le e^{-1/2}/2$.
- **Small tail variance.** $\tau_u\le\tau_r\le AT(r)\to0$.
- **Clipped parity at scale $a$** [subcritical, Lemma 6.1]. This gives $|\E^*\E_xf\sign G|\le(u/d)C\sqrt K+o(1)$, with $u/r\to1$.
- **Probability.** The final event has probability at least $3/4-2\delta$.

So the implication holds. Its hypothesis fails for $d\ge d_0(K)$ by Corollary 5, so the implication gives no information.

### 8.4 Corollary 6: no upper bound on the cost rescues the head-bound route at the margin scale

**Corollary 6.** On the event, let $\bar{\mathcal D}\ge\mathcal D(S)$ be any upper bound on the cost (for example the bump bound) and $\Lambda\ge\|Q_{SS}\|_{\rm op}$ any Gram bound. Then:

- (a) $16\Lambda\bar{\mathcal D}/n\ \ge\ 16c_\delta a^2\,(n\lambda_{r+1}/\tau_r)\,\min\{1,A_\delta\sqrt{rH_r/d}\}$, and $4\lambda_{r+1}\bar{\mathcal D}$ is at least a quarter of the same quantity.
- (b) With $\Lambda=b_r\tau_r$ (Lemma 6.1), $16\Lambda\bar{\mathcal D}/n\ \ge\ 16c_\delta C_\delta a^2\min\{\sqrt{d\,rH_r},A_\delta rH_r\}\ \ge\ 16c_\delta C_\delta a^2\,\rho dH_r$, using $A_\delta\ge1$.
- (c) For every $u\ge r$, the route's clipped-parity output at the margin scale $a$ satisfies
$$\frac u{ad}\Bigl(8\tau_r+16b_r\tau_r\frac{\bar{\mathcal D}}n\Bigr)^{1/2}\ \ge\ 4\sqrt{c_\delta C_\delta}\,(\rho^3dH_r)^{1/2}.$$
It exceeds $1$ once $\rho^3dH_r\ge1/(16c_\delta C_\delta)$. In particular it tends to infinity at every fixed $\rho>0$.
- (d) **(Other clipping scales.)** If the clipped-parity lemma is applied at a scale $b>0$ instead (for $b>a$ this also needs an amplitude bound on $\E^*\Pp_x\{|G(x)|\le b\}$), the first term of its output satisfies
$$\frac u{bd}\Bigl(8\tau_r+16b_r\tau_r\frac{\bar{\mathcal D}}n\Bigr)^{1/2}\ \ge\ \frac ab\cdot4\sqrt{c_\delta C_\delta}\,(\rho^3dH_r)^{1/2}.$$
So the route gives nothing at any scale $b\le4a\sqrt{c_\delta C_\delta}\,(\rho^3dH_r)^{1/2}$; at fixed $\rho$ this covers every $b=o(\sqrt d)$. For $b\ge b_0\sqrt d$ the right side is at most $4\sqrt{c_\delta C_\delta}\,(a/b_0)\,\rho^{3/2}H_r^{1/2}$, which tends to $0$ as $\rho\to0$. So Corollary 6 does not exclude the route at amplitude scales of order $\sqrt d$.

*Proof.* (a) follows from Proposition 4 ($\Lambda\ge n\lambda_{r+1}$) and (A2) ($\bar{\mathcal D}\ge\mathcal D\ge nc_\delta(a^2/\tau_r)\min\{\cdot\}$). (b) follows from (A2) and $b_r\ge C_\delta\sqrt{d\,rH_r}$, together with $\min\{\sqrt{d\,rH_r},A_\delta rH_r\}\ge rH_r=\rho dH_r$. (c) follows from (b) and $u/d\ge\rho$. (d) is (c) multiplied by $a/b$; for $b\ge b_0\sqrt d$, $(\rho^3dH_r)^{1/2}/b\le\rho^{3/2}H_r^{1/2}/b_0$. $\square$

**Interpretation.**

- An $\exp(\Omega(d))$ bound requires the argument to work at $n=e^{cd}$, that is, at a fixed $\rho=\rho(c)>0$. There the route of Section 6 gives a vacuous bound for large $d$, whatever upper bound on $\mathcal D$ is proved. Here the route means the head bound with the paper's Gram bound, followed by the clipped-parity lemma at the margin scale $a$. This covers the bump bound, the exploration's Theorem B, and the false (eq:matching) itself if inserted with a $K$ consistent with Theorem A.
- **Scale.** Part (d) is the precise scope. It excludes clipping scales up to order $a(\rho^3dH_r)^{1/2}$, but not scales of order $\sqrt d$ at small $\rho$. In the subcritical setting the proof clips at the amplitude scale $A_d=b_0d^{(1-\beta)/2}$ supplied by [subcritical, Lemma 7.5]. Here, with Lemma 6.1, any such version must clip at $b\ge4a(c_\delta C_\delta\rho^3dH_r)^{1/2}$, so at a scale of order at least $\sqrt d$. At such a scale the head estimate is no obstruction, and what is missing is an amplitude bound $\E^*\Pp_x\{|G(x)|\le b\}=o(1)$ at $b\asymp\sqrt d$. The paper only asserts that Lemma 7.5 gives no useful amplitude at the standard scaling. Nothing here proves or excludes such an amplitude bound. So Corollary 6 does not show that the subcritical strategy fails; it shows that its margin-scale variant fails.
- **Exact Gram norm.** With the exact Gram norm, part (a) still forces the head and band estimates to be at least $c\,a^2(n\lambda_{r+1}/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$. At fixed $\rho$ the min is a constant, and
$$n\lambda_{r+1}/\tau_r=\theta_r\,n/\binom D{r+2}\ \ge\ 0.8A_\delta\rho^2rH_r\,\theta_r,$$
because $\binom dr/\binom D{r+2}=(r+1)(r+2)/((d+1)(d-r))\ge\rho^2$. This diverges if $\theta_r\ge c/\sqrt r$, as asserted by the exploration's Lemma T (`deep-1.md`). That claim is not in the paper and I have not re-proved it. If instead $\theta_r$ were only of order $1/r$ (as the $q^{-3/2}$ level-mass decay of the arcsine kernel would give), then $n\lambda_{r+1}/\tau_r\le8A_\delta rH_r\theta_r=O(A_\delta H_r)$ by (I4). The exact-norm lower bound on the route's output from part (a) would then be $O(\rho(A_\delta H_r)^{1/2})$, which is small at small $\rho$, so Corollary 6 would not exclude the exact-norm version. (Whether it actually works would then depend on the true size of $\|Q_{SS}\|_{\rm op}$, which lies between $\max\{n\lambda_{r+1},\tau_r\}$ and, in expectation, $(e-1)n\lambda_{r+1}+\tau_r\log(\tau_r/\lambda_{r+1})$ by Proposition 4 and Lemma 8.5a.)
- **Numerics for $\theta_r$** (tanh, $L=2$, unit gains; `check_theta.out`). $\theta_r\sqrt r\ge0.80$ at every odd $r$ tested: every odd $r\le d-1$ whose level masses are representable in double precision, at $d\in\{200,400,800,1600,3200\}$. The minimum, $0.804$–$0.808$, is at $r=1$. For odd $r\le0.065d$, $\theta_r\sqrt r\in[0.80,3.06]$. For larger $r/d$ it is larger: it first exceeds $3.03$ at $r=39,59,89,133,195$ for $d=200,\dots,3200$, and for $r<d/2$ it reaches $6.5$ at $d=200$ and $7.7$ at $d=400$. (The first version said "$\theta_r\sqrt r\in[0.8,3.0]$ for $1\le r\le193$, $d\le3200$". As stated that was wrong; only the lower bound is used.) At $\rho\approx0.06$, $n\lambda_{r+1}/\tau_r$ grows roughly like $\sqrt d$ (Section 10).
- Corollary 6 concerns a specific route: the entropy lemma, a Gram bound, and clipped parity at the margin scale $a$ (or at any scale covered by (d)). It does not show that $\exp(\Omega(d))$ is false, nor that every proof must fail.
- The exploration's restriction lemma replaces the linear amplitude dependence of clipped parity by a logarithmic one. With (b), whose amplitude ratio $R$ is of order $d$ at fixed $\rho$, it still needs $\rho\log d\to0$. It therefore does not rescue this route at linear $\rho$ either.

### 8.5 Remark ($\tanh$ only; proved here except for Lieb's theorem): removing most of the factor $\sqrt{rH_r/d}$

The Gram event of Lemma 6.1 can be replaced as follows. Let $N=\#\{U:|U|>r\}$,
$$\psi(x)=(\lambda_{|U|}^{1/2}\chi_U(x))_{|U|>r}\in\R^N,\qquad \Psi=[\psi(X_1),\dots,\psi(X_n)],\qquad Y=\Psi\Psi^{\mathsf T}=\sum_{i\le n}\psi(X_i)\psi(X_i)^{\mathsf T}.$$
Then $Q_{SS}=\Psi^{\mathsf T}\Psi$, so $Q_{SS}$ and $Y$ have the same nonzero eigenvalues. The summands $Z_i=\psi(X_i)\psi(X_i)^{\mathsf T}$ are iid and positive semidefinite, with $\lambda_{\max}(Z_i)=\|\psi(X_i)\|^2=\tau_r=:L$. Their sum has mean $M:=\E Y=n\operatorname{diag}(\lambda_{|U|})$, with $\mu:=\|M\|=n\lambda_{r+1}$, $\operatorname{tr}M=n\tau_r$ and intrinsic dimension $\operatorname{intdim}(M)=\operatorname{tr}M/\|M\|=\tau_r/\lambda_{r+1}\ge1$.

**Lemma 8.5a** (intrinsic-dimension expectation bound). $\E\|Q_{SS}\|_{\rm op}\le(e-1)\,n\lambda_{r+1}+\tau_r\log(\tau_r/\lambda_{r+1})$.

*Proof.* Fix $\theta>0$ and put $g=(e^{\theta L}-1)/L$.
1. By convexity, $e^{\theta x}\le1+gx$ for $0\le x\le L$. So $e^{\theta Z_i}\preceq I+gZ_i$ (here with equality, since $Z_i$ has rank one). Hence $\E e^{\theta Z_i}\preceq I+g\E Z_i$. Since $\log$ is operator monotone and $\log(1+x)\le x$, we get $\log\E e^{\theta Z_i}\preceq g\E Z_i$.
2. Lieb's concavity theorem gives the subadditivity of matrix cumulant generating functions, $\E\operatorname{tr}\exp(\sum_iH_i)\le\operatorname{tr}\exp(\sum_i\log\E e^{H_i})$ for independent random Hermitian $H_i$ (Tropp 2012, *User-friendly tail bounds for sums of random matrices*, Found. Comput. Math., Lemma 3.4; the numbering is recalled, the statement is standard). Apply it with $H_i=\theta Z_i$. Since $\operatorname{tr}\exp$ is monotone under $\preceq$, step 1 gives $\E\operatorname{tr}e^{\theta Y}\le\operatorname{tr}e^{gM}$.
3. All eigenvalues of $\theta Y$ are nonnegative, so $e^{\theta\lambda_{\max}(Y)}-1\le\operatorname{tr}(e^{\theta Y}-I)$. Hence $\E e^{\theta\lambda_{\max}(Y)}\le1+\operatorname{tr}(e^{gM}-I)$.
4. The function $\varphi(t)=e^{gt}-1$ is convex with $\varphi(0)=0$, so $\varphi(t)\le(t/\mu)\varphi(\mu)$ for $0\le t\le\mu$. Summing over the eigenvalues of $M$ gives $\operatorname{tr}(e^{gM}-I)\le\operatorname{intdim}(M)(e^{g\mu}-1)$. Since $\operatorname{intdim}(M)\ge1$, $1+\operatorname{intdim}(M)(e^{g\mu}-1)\le\operatorname{intdim}(M)\,e^{g\mu}$.
5. By Jensen's inequality, $\theta\,\E\lambda_{\max}(Y)\le\log\E e^{\theta\lambda_{\max}(Y)}\le g\mu+\log\operatorname{intdim}(M)$.

Take $\theta=1/L$, so that $g/\theta=e-1$. Then $\E\lambda_{\max}(Y)\le(e-1)\mu+L\log\operatorname{intdim}(M)$. $\square$

This is the expectation bound of Tropp's intrinsic-dimension matrix Chernoff inequality (J. Tropp, *An Introduction to Matrix Concentration Inequalities*, 2015, Theorem 7.2.1). I recalled that bound in the form $((e^\theta-1)/\theta)\mu+(L/\theta)\log(2\operatorname{intdim})$. The derivation above gives $\log\operatorname{intdim}$ in place of $\log(2\operatorname{intdim})$, so it implies the recalled form, and the remark no longer depends on the exact constant in the book.

**Consequence.** The paper's Lemma 4.3(a) (`lem:eiglower`) with $\psi(m)=C_\phi\sqrt m$ from Corollary 4.2 (`cor:composite`) applies for $d\ge101$ and $r+1\le0.49d$. It gives $\lambda_{r+1}\ge A\kappa e^{-C_\phi\sqrt{40D}}/(2D(D+1)\binom d{r+1})$. With $\tau_r\le A$, this yields $\log(\tau_r/\lambda_{r+1})\le\log\binom d{r+1}+C\sqrt d\le2rH_r+C\sqrt d$. Together with $n\lambda_{r+1}\le8A_\delta rH_r\tau_r$ (from (I2) and (I4) with $C=8$), Lemma 8.5a and Markov's inequality give, with probability at least $1-\delta$,
$$\|Q_{SS}\|_{\rm op}\le C'_\delta\tau_r(rH_r+\sqrt d).$$
Running the proof of Theorem A with $\Lambda=C'_\delta\tau_r(rH_r+\sqrt d)$ gives, with probability at least $1-4\delta$,
$$\frac{\mathcal D(S)}n\ \ge\ c'_\delta\,\frac{a^2}{\tau_r}\min\Bigl\{1,\ \frac{rH_r}{\sqrt d}\Bigr\}.$$
This holds for every $n$ with $1\le r(n)\le d/64$ and large $d$. It needs no far-pair analysis, and no upper limit $e^{c_1d}$ beyond $r(n)\le d/64$. In particular $\mathcal D/n\ge c'_\delta a^2/\tau_r$ once $rH_r\ge\sqrt d$. At the bottom of the range ($rH_r\approx(\log d)^3$) the factor is about $(\log d)^3/\sqrt d$. So even with this remark the bound is not of order $a^2/\tau_r$ there.

**Status and scope.**
- The remark is $\tanh$-specific. It uses Corollary 4.2 through Lemma 4.3(a), that is, $c_m\ge\kappa e^{-C_\phi\sqrt m}$; oddness alone is not enough.
- It is proved here, except for Lieb's theorem, which is cited.
- Numerically, the mean of $\lambda_{\max}(Q_{SS})$ is at most $0.81$ times the bound of Lemma 8.5a, and a single sample is at most $0.88$ times it. This covers $d=10,12$, $r=1,3,5$, $n$ from $20$ to $10^5$ and first-layer gains $0.5,1,2$ (`check_intdim.out`, `check_intdim_large.out`).
- The main results and the replacement blocks do not use the remark. If it is moved into the paper, add bibliography entries for Lieb (1973) and Tropp (2012), or for Tropp (2015, Theorem 7.2.1).

## 9. What this means for Section 6, and replacement text

### 9.1 Sentence-by-sentence verdict (lines refer to `standard-nngp-parity.tex`)

| Lines | Text | Verdict |
|---|---|---|
| 851–854 | "the head bound $\E^*\lVert G_{\le r}\rVert_2^2\le8\tau_r+16b_r\tau_r\mathcal D/n$ [subcritical, eq. (45)]" | The inequality is right, but the citation is off. Subcritical eq. (45) is stated with that paper's Gram bound $B_r\tau$ (its eq. (44)), not with $b_r$. The form with a general Gram bound comes from its eqs. (41) and (43). Fix the citation (R10). |
| 964–966 | "…refutes only the normalization (42). It does not show that the subcritical strategy fails." | Still true. The subcritical strategy applies clipped parity at an amplitude scale, and nothing here excludes that at a scale of order $\sqrt d$ (Corollary 6(d)). Theorem A and Corollary 6 show only that the margin-scale variant, with Lemma 6.1, fails at every fixed $\rho$. The first clause is outdated: Theorem A refutes more than (42). |
| 966–969 | "The clipped-parity lemma at scale $a$ only needs … $O(a)$ …" | True. The constant term may even be excluded (Laplacian form, [subcritical, eq. (laplacian-clip)]). |
| 969–976 | Hypothesis (eq:matching), $K$ independent of $d,n,\rho$ | **False for every fixed $K$** (Corollary 5). |
| 977–993 | Head, band, tail, clipped parity $\Rightarrow\exp(\Omega(d))$ | Correct derivation (Section 8.3). The implication is true but vacuous. |
| 993–995 | "Proposition 6.2 says that (eq:matching) cannot hold with a smaller right-hand side by more than a constant factor." | Literally true. Its intended reading, that the form of (eq:matching) is forced up to constants and is the sharp order, is **false**: the true order is larger by a factor $\to\infty$. |
| 995–997 | "So the missing ingredient is an upper bound on the conditioning cost that matches the proposition up to constants." | **False.** No such bound exists (Corollary 5). Moreover, no upper bound on the cost makes this route work at the margin scale at fixed $\rho$ (Corollary 6). |
| 997 | "The only upper bound we have is the bump bound $e^{C\sqrt d}$." | True. |
| 1016–1018 | "…$O(1)$ only if $\mathcal D=O(d)$; no bound here provides that." | True, but can be strengthened: with probability at least $1-4\delta$, $\mathcal D/d\to\infty$ in the adaptive range, by Theorem A. |
| 1021–1030 | Heuristic: "the proposition and the bump construction place the cost between $d^{\omega(1)}$ and $e^{C\sqrt d}$ … If that mass sits mainly in the band just above $r$, the cost should match the proposition, and the argument above would give $\exp(\Omega(d))$." | The first part is true. The "should match the proposition … would give" sentence is **incompatible with Proposition prop:linear**: on its event the cost never matches the proposition, whatever the posterior does. Strictly, the conditional is false if its antecedent can occur and vacuous otherwise; whether the posterior's mass can sit mainly in that band is not decided. Withdraw it. |
| 53–55, 106–108, 861–862, 1082 | Abstract, introduction item 4, Section 6 introduction, status table: a "matching upper bound … would complete an exponential proof" | Vacuous; withdraw. |
| outside the paper | README line 18; `catalog.json` summary ("a matching upper bound that would suffice is identified"); `verification/review.md` line 88 ("The proposition forces the form of the matching bound up to constants") | Superseded. |

### 9.2 Exact replacement text (LaTeX)

The blocks R1–R8 and R10 were applied to a scratch copy of the paper source in `verify/texbuild/` by `verify/apply_R.py`, which reads the blocks from this file. The copy compiles with two `pdflatex` passes, with no LaTeX warnings and no unresolved references. The only box messages in the log are three underfull hboxes, in older status-table rows and in the bibliography; the unpatched paper's build log has the same three. The full proposed change to the `.tex` is in `verify/section6.diff`, and the patched PDF is `verify/texbuild/standard-nngp-parity.pdf`. The optional add-on to R3 and the suggestions in R9 are not applied.

**(R1) Insert after the proof of Proposition 6.2** (after line 962, before `\paragraph{What this shows and does not show.}`):

```latex
\begin{proposition}[A sharper lower bound on the cost per sample]
\label{prop:linear}
Let $\phi=\tanh$; fix $L$, gains, $a$ and $\delta\in(0,1/8)$, and let $c_1$,
$C_\delta$ and $b_r$ be as in Lemma~\ref{lem:gram}. For large $d$ and every $n$
with $\exp((\log(d+1))^3)\le n\le e^{c_1d}$, with probability at least
$1-4\delta$ over iid uniform inputs labelled by full parity,
\begin{equation}\label{eq:linear-cost}
 \mathcal D(S)\ \ge\ \frac{\delta na^2}{\tau_r}
 \min\Bigl\{\frac1{16},\frac{A_\delta\log(2D_r)}{128\,b_r}\Bigr\}-\log2,
 \qquad r=r(n).
\end{equation}
Consequently, on the same event,
\[
 \frac{\mathcal D(S)}n\ \ge\ c_\delta\,\frac{a^2}{\tau_r}
 \min\Bigl\{1,A_\delta\sqrt{rH_r/d}\Bigr\},\qquad
 c_\delta=\frac\delta2\min\Bigl\{\frac1{16},\frac1{480C_\delta}\Bigr\}.
\]
Only the training margins $y_iG(X_i)>a$ are used. Moreover, for every
sequence $S$ of $n$ inputs and every $0\le r<d$,
\begin{equation}\label{eq:gram-lower}
 \|Q_{SS}\|_{\rm op}\ \ge\ \max\{n\lambda_{r+1},\tau_r\}.
\end{equation}
\end{proposition}
\begin{proof}
Write $y_i=f(X_i)$, $p=G_{\le r}$, $t=G_{>r}$, and $t_S=(t(X_i))_{i\le n}$, a
centered Gaussian vector with covariance $Q_{SS}$. Put
\[
 \varepsilon^2=\sum_{|U|\le r}\Bigl(\frac1n\sum_{i=1}^ny_i\chi_U(X_i)\Bigr)^2 .
\]
Since $y_i\chi_U(X_i)=\chi_{[d]\setminus U}(X_i)$ and $[d]\setminus U\ne\emptyset$,
each inner average has mean zero and variance $1/n$, so
$\E\varepsilon^2=D_r/n$. For $i\ne j$ only $U=[d]$ survives in
$\E[y_iy_jQ(X_i,X_j)]$, which is therefore $\lambda_d$; and
$Q(X_i,X_i)=\tau_r$. Hence
$\E\,y^{\mathsf T}Q_{SS}y=n\tau_r+n(n-1)\lambda_d\le2n\tau_r$, because
$\tau_r\ge\lambda_d\sum_{q>r}\binom dq\ge2^{d-1}\lambda_d$ by monotonicity
($r<d/2$) and $n\le e^{c_1d}\le2^{d-1}$ (the proof of Lemma~\ref{lem:gram}
takes $2c_1<\log2-\mathsf h(1/4)$, so $c_1<\frac12\log2$). Let $E$ be the
intersection of the coercivity event of \cite[Lemma~4.4]{subcritical} at
degree $r$ (it applies since $r\le d/64$ by Lemma~\ref{lem:gram} and
$n\ge A_\delta D_r\log(2D_r)$ by the choice of $r$), the event of
Lemma~\ref{lem:gram}, $\{\varepsilon^2\le D_r/(n\delta)\}$ and
$\{y^{\mathsf T}Q_{SS}y\le2n\tau_r/\delta\}$. By Markov's inequality,
$\Pp(E)\ge1-4\delta$. Fix a sample in $E$.

Every $G\in A_S$ has $y_iG(X_i)>a$ for all $i$. Cauchy--Schwarz in the Walsh
basis gives $\sum_iy_ip(X_i)\le n\varepsilon\|p\|_2$, so
$na<n\varepsilon\|p\|_2+y^{\mathsf T}t_S$. If $2\varepsilon\|p\|_2\le a$,
then $y^{\mathsf T}t_S>na/2$. Otherwise $(y_ip(X_i))_-\le|t(X_i)|$ and
coercivity give
\[
 \|t_S\|^2\ge\frac n4\|p\|_2^2>\frac{na^2}{16\varepsilon^2}
 \ge\frac{\delta n^2a^2}{16D_r}\ge s:=\frac{\delta A_\delta\log(2D_r)}{16}\,na^2,
\]
using $n\ge A_\delta D_r\log(2D_r)$. Thus
$A_S\subseteq\{y^{\mathsf T}t_S>na/2\}\cup\{\|t_S\|^2>s\}$. The first event
has probability at most
$\exp(-n^2a^2/(8y^{\mathsf T}Q_{SS}y))\le\exp(-\delta na^2/(16\tau_r))$. For
the second, take $\theta=1/(4\|Q_{SS}\|_{\rm op})$. Since
$-\log(1-x)\le2x\log2$ for $0\le x\le\frac12$, the Gaussian moment
generating function satisfies
$\log\E e^{\theta\|t_S\|^2}\le2\theta\log2\operatorname{tr}Q_{SS}
=2\theta n\tau_r\log2$. With Lemma~\ref{lem:gram},
\[
 \Pp\{\|t_S\|^2>s\}\le\exp\Bigl(-\frac{s-2n\tau_r\log2}
 {4\|Q_{SS}\|_{\rm op}}\Bigr)\le\exp\Bigl(-\frac{s}{8b_r\tau_r}\Bigr),
\]
where the last step uses $s\ge4n\tau_r\log2$, valid for large $d$ since
$\tau_r\le A$ and $\log(2D_r)\ge\log(2d)$. Adding the two bounds proves
\eqref{eq:linear-cost}. For $1\le r\le d/64$ we have
$\log(2D_r)\ge r\log(d/r)\ge0.8\,rH_r$ and $rH_r\le0.081d$; hence
$1\le rH_r\le\sqrt{d\,rH_r}$ and $b_r\le3C_\delta\sqrt{d\,rH_r}$, and the
minimum in \eqref{eq:linear-cost} is at least
$\min\{\frac1{16},\frac1{480C_\delta}\}\min\{1,A_\delta\sqrt{rH_r/d}\}$.
The term $\log2$ is absorbed for large $d$, since $na^2/\tau_r\ge na^2/A$
and $n\ge\exp((\log(d+1))^3)$.

For \eqref{eq:gram-lower}, fix $U_0$ with $|U_0|=r+1$ and put
$v=(\chi_{U_0}(X_i))_{i\le n}$. Every term of
$Q=\sum_{|U|>r}\lambda_{|U|}\chi_U\chi_U^{\mathsf T}$ is positive
semidefinite, so $Q_{SS}\succeq\lambda_{r+1}vv^{\mathsf T}$ and
$\|Q_{SS}\|_{\rm op}\ge v^{\mathsf T}Q_{SS}v/\|v\|^2\ge\lambda_{r+1}\|v\|^2
=n\lambda_{r+1}$. Also $\|Q_{SS}\|_{\rm op}\ge\operatorname{tr}Q_{SS}/n=\tau_r$.
\end{proof}
```

**(R2) Replace lines 964–997** (from `\paragraph{What this shows and does not show.}` through "…the bump bound $e^{C\sqrt d}$.") by:

```latex
\paragraph{What this shows and does not show.} Proposition~\ref{prop:obstruction}
is about a proof technique, not about sample complexity, and it refutes the
normalization (42). Proposition~\ref{prop:linear} is sharper. Its proof
splits the statistic $\sum_iy_iG(X_i)>na$ into a low-degree part, which
coercivity controls, and the high-degree part $y^{\mathsf T}t_S$. The prior
variance $y^{\mathsf T}Q_{SS}y$ of the latter is of order $n\tau_r$ on
typical samples, not $n\|Q_{SS}\|_{\rm op}$, because parity is orthogonal to
every Walsh character of degree below $d$. The resulting lower bound
exceeds that of Proposition~\ref{prop:obstruction} by a factor of order
$\min\{\sqrt{d\,rH_r},A_\delta rH_r\}$, which tends to infinity. The factor
$\min\{1,A_\delta\sqrt{rH_r/d}\}$ in Proposition~\ref{prop:linear} is of
order one when $\log n\asymp d$; at $n=\exp((\log(d+1))^3)$ the cutoff has
$rH_r=(1+o(1))(\log d)^3$, and the factor is of order
$A_\delta(\log d)^{3/2}/\sqrt d$. So Proposition~\ref{prop:obstruction} is
not sharp, and no upper bound on the cost matches it: for every fixed $K$,
all large $d$ and every $n$ in its range, the inequality
\[
 \frac{\mathcal D(S)}n\le\frac{K\,a^2}{\tau_r\,(b_r+rH_r)}
\]
fails on the event of Proposition~\ref{prop:linear}, hence with
probability at least $1-4\delta$.

Nor can any upper bound on the cost make the head-bound argument of
\cite{subcritical}, with Lemma~\ref{lem:gram}, work at the margin scale
$a$. The clipped-parity lemma at scale $a$ needs the posterior's
low-degree part to be $O(a)$ in $L^2$, because it is multiplied by
$u/d\approx\rho$. The entropy bound at the training inputs and coercivity,
\cite[eqs.~(41) and (43)]{subcritical}, control that part by
$\E^*\|G_{\le r}\|_2^2\le8\tau_r+16\|Q_{SS}\|_{\rm op}\mathcal D/n$; this is
the argument of \cite[eq.~(45)]{subcritical}, which then inserts that
paper's Gram bound \cite[eq.~(44)]{subcritical}.
By \eqref{eq:gram-lower} and Proposition~\ref{prop:linear}, whatever upper
bound on $\mathcal D$ is inserted, the right side is at least
$16c_\delta a^2(n\lambda_{r+1}/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$, and
the entropy estimate $2\tau_r+4\lambda_{r+1}\mathcal D$ of the band
$(r,u]$ is at least a quarter of that. With the bound $b_r\tau_r$ of
Lemma~\ref{lem:gram} in place of $\|Q_{SS}\|_{\rm op}$, the head estimate is
at least $16c_\delta C_\delta a^2\min\{\sqrt{d\,rH_r},A_\delta rH_r\}$. The
resulting bound on $|\E^*\E_xf\sign G|$ is then at least
$4(c_\delta C_\delta\rho^3dH_r)^{1/2}$ (for $A_\delta\ge1$), which exceeds
one at every fixed $\rho>0$ once $d$ is large. With the exact norm
$\|Q_{SS}\|_{\rm op}$ the same happens if $n\lambda_{r+1}/\tau_r\to\infty$ at
fixed $\rho$. That is a question about the spectrum alone: it holds if
$\binom D{r+2}\lambda_{r+1}/\tau_r\ge c/\sqrt r$, which we observe
numerically for $\tanh$ but have not proved. If that ratio were only of
order $1/r$, then $n\lambda_{r+1}/\tau_r$ would stay bounded at fixed
$\rho$, and this argument would not exclude the exact-norm estimate. So an
$\exp(\Omega(d))$ proof by the head-bound argument at the margin scale
needs, with the bound of Lemma~\ref{lem:gram} (and with the exact norm
too, if $\binom D{r+2}\lambda_{r+1}/\tau_r\ge c/\sqrt r$), a bound on the
posterior's low-degree part that does not pass through
$\|Q_{SS}\|_{\rm op}\mathcal D/n$, such as the route below.

These estimates concern the margin scale. If the clipped-parity lemma is
applied at a scale $b>a$ instead, as \cite{subcritical} does at the
amplitude scale of \cite[Lemma~7.5]{subcritical}, the lower bound above is
multiplied by $a/b$. It still exceeds one if
$b\le4a(c_\delta C_\delta\rho^3dH_r)^{1/2}$, so at fixed $\rho$ for every
$b=o(\sqrt d)$; but for $b$ of order $\sqrt d$ it tends to zero as
$\rho\to0$, so it is no obstruction there. With Lemma~\ref{lem:gram}, such
a version of the argument therefore needs an amplitude bound
$\E^*\Pp_x\{|G(x)|\le b\}=o(1)$ at a scale $b$ of order at least $\sqrt d$.
\cite[Lemma~7.5]{subcritical} does not give one at the standard scaling,
and we neither prove nor exclude one. The only upper bound on the cost we
have is the bump bound $e^{C\sqrt d}$.
```

**(R3) Replace the end of the second-route paragraph** (line 1018), "no bound here provides that.", by:

```latex
by Proposition~\ref{prop:linear}, with probability at least $1-4\delta$,
$\mathcal D/d\ge c\,n/d^{3/2}\to\infty$ uniformly for
$\exp((\log(d+1))^3)\le n\le e^{c_1d}$.
```

(Here $c=c_\delta a^2\min\{1,A_\delta\}/A$, from $\tau_r\le A$ and $rH_r\ge1$.) Optionally, after "so it is enough that $\alpha\sqrt C/a\le1/4-o(1)$", add: "By the Laplacian form \cite[Lemma~6.1]{subcritical} of the clipped-parity lemma, the constant term may be excluded from the first condition." This is correct, because $\Delta$ annihilates level $0$. It matters because the posterior may carry a large constant.

**(R4) Replace the heuristic paragraph** (lines 1020–1033) by:

```latex
\paragraph{Heuristic picture} (heuristic; not used above). For
$\exp(d^\epsilon)\le n\le e^{c_1d}$, Proposition~\ref{prop:linear} and the
bump construction place the conditioning cost per sample between
$c_\delta(a^2/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$ and $e^{C\sqrt d}$; the
lower end is superpolynomial in $d$. The mechanism behind the lower bound
is coercivity together with the sign-aligned statistic. At the training
inputs parity cannot be followed by a low-degree polynomial, so a
low-degree part that carried the training margins would force a large
high-degree part there; and a high-degree part that carries them by itself
costs order $na^2/\tau_r$, because parity is nearly orthogonal to the top
eigenvectors of $Q_{SS}$. This holds whatever the posterior does: on the
event of Proposition~\ref{prop:linear} the cost exceeds the bound of
Proposition~\ref{prop:obstruction} by a factor tending to infinity. The
bounds on the cost do not decide whether the posterior's low-degree part
stays of order $a$, as the clipped-parity lemma at scale $a$ needs, or
whether the posterior uses large-amplitude low-degree thresholds that
approximate parity. We have not ruled out the second behaviour, and the
numerics below are too small to test it.
```

**(R5) Section 6 introduction** (lines 861–862). Replace "We then explain what estimate would let the rest of the argument go through." by:

```latex
We then prove a sharper lower bound, of order $a^2/\tau_r$ per sample up to
a factor $\min\{1,A_\delta\sqrt{rH_r/d}\}$ that is of order one when
$\log n\asymp d$. So no upper bound on the cost can match the first lower
bound, and with our tail-Gram bound the subcritical head estimate gives
nothing at the margin scale, whatever upper bound on the cost holds.
```

**(R6) Abstract** (lines 53–55). Replace "We explain why an upper bound on that cost matching our lower bound would complete an exponential proof." by:

```latex
A sharper lower bound, of order $a^2$ over the prior tail variance per
sample when $\log n\asymp d$, shows that no upper bound on that cost can
match the first one, and that with our tail-Gram bound the head-bound
argument of the subcritical paper, applied at the margin scale, cannot give
an exponential bound whatever upper bound on the cost holds.
```

**(R7) Introduction, item 4** (lines 106–108). Replace "We also identify a matching upper bound on that cost which would complete an $\exp(\Omega(d))$ proof (Section~\ref{sec:obstruction})." by:

```latex
A sharper bound (Proposition~\ref{prop:linear}) puts the cost per sample
above $c_\delta(a^2/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$, which is of
order $a^2/\tau_r$ at linear cutoffs. So no upper bound matching the first
one exists. With our tail-Gram bound, the subcritical head estimate
followed by the clipped-parity lemma at the margin scale gives nothing at
linear cutoffs, whatever upper bound on the cost holds; we do not exclude
the clipped-parity lemma at a larger amplitude scale
(Section~\ref{sec:obstruction}).
```

**(R8) Status table** (line 1082). Replace the row by:

```latex
Lower bound $c_\delta(a^2/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$ on the
cost per sample (w.p.\ $\ge1-4\delta$), so no upper bound matches
Prop.~\ref{prop:obstruction}; with Lemma~\ref{lem:gram}, the head-bound
argument of \cite{subcritical} at the margin scale $a$ cannot give
$\exp(\Omega(d))$ & Proved (Prop.~\ref{prop:linear})\\
```

**(R9) Outside the paper** (suggestions only).

- **README line 18.** Replace "The paper identifies what is missing: … This is an extension suggested by the proof, not a result." by: "A sharper bound shows that the cost per sample is at least $c_\delta(a^2/\tau_r)\min\{1,A_\delta\sqrt{rH_r/d}\}$, which is of order $a^2/\tau_r$ when $\log n\asymp d$. So no upper bound matching the first lower bound exists. With the paper's tail-Gram bound, the subcritical head estimate followed by clipped parity at the margin scale cannot give $\exp(\Omega(d))$, whatever upper bound on the cost holds. Clipping at a larger amplitude scale is not excluded."
- **`catalog.json` summary.** Replace "a matching upper bound that would suffice is identified" by "a sharper lower bound shows that no matching upper bound exists".
- **`verification/review.md`.** Line 88 is a historical record. Add a dated note instead of editing it.

**(R10) Section 6 introduction, citation of the head bound** (lines 853–854). Replace "\cite[eq.~(45)]{subcritical}, where $\E^*$ is the posterior expectation and $b_r$ bounds the sampled Gram matrix of the tail kernel." by:

```latex
(\cite[eq.~(45)]{subcritical} states it with that paper's Gram bound
\cite[eq.~(44)]{subcritical}; the form with $b_r\tau_r$ follows in the same
way from \cite[eqs.~(41) and (43)]{subcritical}), where $\E^*$ is the
posterior expectation and $b_r\tau_r$ bounds the sampled Gram matrix of
the tail kernel.
```

## 10. Numerical sanity checks

All scripts are in `/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/verify/`. They use my own spectrum code, not the exploration's.

- **`spec.py`** computes the tanh $L=2$ unit-gain spectrum.
  - Coefficients come from the paper's Hermite formula, $c_m=I_m^2/(m!\,v)$.
  - Against 40-digit mpmath quadrature (`check_coeffs.py`, `check_coeffs.out`), the relative error of $c_m$ is $3.7\times10^{-10}$ at $m=1$ and at most $1\times10^{-12}$ at the other tested $m$ ($3,5,11,101,1001,2001$). Also $\sum_{m\le4001}c_m=1-3.4\times10^{-10}$.
  - That shortfall is quadrature error in $c_1$, not truncation mass. (The first version implied the latter.) spec.py's $\log\sinh$ uses $\log1p(-e^{-2x})$, which loses accuracy to cancellation near $w=0$; this matters only for small $m$. With $\log(-\mathrm{expm1}(-2x))$ the sum is $1-2\times10^{-12}$, and the remaining $2\times10^{-12}$ is the omitted interval $[0,10^{-12}]$ in $I_1$. The mass beyond $m=4001$ is about $10^{-85}$, from the fitted decay $\log c_m\approx0.66-3.16\sqrt m$. The "coefficient tail=3.4e-10" printed in `compare_bounds.out` is the same quadrature shortfall.
  - `spec.py` is left unchanged because other scripts import it. The error is immaterial to every conclusion.
  - Level masses come from the exact Ehrenfest recursion.
- **`check_identities.py`** (output `check_identities.out`), at $d=10,12$ with $r=1,3$ and $n$ from $20$ to $1500$, by Monte Carlo over samples:
  - $\E\,y^{\mathsf T}Q_{SS}y$ matches $n\tau_r+n(n-1)\lambda_d$ within about one standard error;
  - $\E\varepsilon^2$ matches $D_r/n$;
  - $\lambda_{\max}(Q_{SS})/\max\{n\lambda_{r+1},\tau_r\}\ge1.18$ on every sampled $S$;
  - the linear Gaussian tail bound holds.
- **`check_chernoff_small.py`** (output `check_chernoff_small.out`) checks the quadratic-form Chernoff bound of Lemma 2(b) in small cases with non-negligible probabilities. No violation was found, for example $0.154\le0.854$ and $5.0\times10^{-7}\le1.6\times10^{-3}$.
- **`check_elementary.py`** (output `check_elementary.out`) checks every $d\in[64,2000]$, every 37th $d$ up to $20000$, and every odd $r\le d/64$:
  - E1: $\min\log(2D_r)/(rH_r)=0.94\ (\ge0.8)$;
  - E2: $\max rH_r/d=0.0808\ (\le0.081)$;
  - E3: $\binom dr/\binom{d+1}{r+2}\ge(r/d)^2$ (minimum ratio $1.025$);
  - E4: $D_{r+2}\log(2D_{r+2})\le8\binom D{r+2}rH_r$, the inequality of (I4) with $C=8$ (maximum ratio $2.62$; the analytic proof is in (I4));
  - E4b, informational: $(\log(2D_{r+2})-\log2)/(rH_r)\le3$ (maximum $2.56$, at $r=1$; $1.10$ for $r\ge(\log d)^2/4$);
  - E5: $-\log(1-x)\le2x\log2$ on $(0,\frac12]$.
  - **Correction.** The first version printed "E4 max of $(\log(2D_{r+2})-1)/(rH_r)$ = 2.53 (need ≤ 2)", which reads as a failed check. The label was wrong: no such constant is used anywhere, since the constant $C$ of (I4) is never given a value in the proof. That output is kept as `check_elementary.v1.out` (script `check_elementary.v1.py`). E4 now checks the inequality that is actually used.
- **`check_intdim.py`** (output `check_intdim.out`; first version `check_intdim.v1.out`) checks Lemma 8.5a at $d=10,12$, with $r\in\{1,3,5\}$ and $n\le600$. The Monte Carlo mean of $\lambda_{\max}(Q_{SS})$ is $0.16$–$0.76$ times the derived bound, and $0.15$–$0.71$ times the recalled Tropp form.
- **`check_intdim_large.py`** (output `check_intdim_large.out`) forms $Y=\sum_xn_x\psi(x)\psi(x)^{\mathsf T}$ from the counts $n_x$ of the cube points in the sample, which reaches $n=10^5$. It uses first-layer gains $0.5,1,2$, $d=10,12$ and $r=1,3$, with six samples per case. The worst mean ratio to the derived bound is $0.81$ and the worst single sample is $0.88$. At $n=10^5$, $\lambda_{\max}/(n\lambda_{r+1})$ is $1.09$–$1.33$.
- **`check_theta.py`** (output `check_theta.out`) gives $\theta_r\sqrt r$ at every odd $r$ with representable level masses, for $d\in\{200,400,800,1600,3200\}$. The minimum is $0.804$–$0.808$, always at $r=1$. The range over $r\le0.065d$ is $[0.80,3.06]$. The quantity first exceeds $3.03$ at $r=39,59,89,133,195$. Its maximum over $r<d/2$, $r\le193$ is $6.46$ ($d=200$), $7.66$ ($d=400$), $4.10$, $3.31$ and $3.03$. Over all $r$ it reaches $14$–$49$, as $\theta_r\to1$ near $r=d$.
- **`check_bottom.py`** (output `check_bottom.out`) gives the cutoff at $n=\exp((\log(d+1))^3)$ for $d=10^5,\dots,10^{40}$ and $A_\delta\in\{1,100\}$. There $rH_r/(\log(d+1))^3\in[0.990,1.000]$, $r/(\log d)^2$ decreases from $1.59$ to $1.10$, and $\sqrt{rH_r/d}$ equals $(\log d)^{3/2}/\sqrt d$ to within $0.5\%$.
- **`compare_bounds.py`** (output `compare_bounds.out`) is an illustration only, not evidence about asymptotics. It uses $C_\delta=C=a=1$, $\delta=0.1$ and $A_\delta\in\{1,100\}$, at $d\le3200$ and $\rho\le0.065$.
  - The ratio (Theorem A)/(Prop. 6.2) grows with $d$ and $r$: from $0.1$ to $10$ for $A_\delta=1$, and from $27$ to $2065$ for $A_\delta=100$.
  - The $K$ that (eq:matching) would need grows like $\delta A_\delta rH_r/128$ (up to about $19$ at $d=3200$, $\rho=0.06$, $A_\delta=100$).
  - On the table's rows (odd $r\le0.065d$), $\theta_r\sqrt r\in[0.81,3.03]$. For other $r$, see `check_theta.out` above.
  - $n\lambda_{r+1}/\tau_r$ at $\rho\approx0.06$ ($A_\delta=1$) is $0.16$, $0.22$, $0.31$, $0.46$, $0.66$ for $d=200,\dots,3200$, roughly $\propto\sqrt d$.
  - At these $d$ the contradiction with (eq:matching) and the divergence in Corollary 6 have not yet set in. Both are asymptotic statements: for $K=1$, the contradiction needs $\delta A_\delta rH_r/160\gtrsim1$.
- **`apply_R.py`** reads the blocks R1–R8 and R10 from this file, applies them to a copy of the paper source in `texbuild/`, and writes `section6.diff`.

## 11. Responses to referees

Every issue raised is correct, and none is rejected. Each was fixed in place as described below. Two figures in the reports are refined: Referee 2, point 2, and Referee 3, point 2.

### Referee 1

1. *R6 and R7 lack "at the margin scale a".* Fixed. R6 now says "the head-bound argument of the subcritical paper, applied at the margin scale". R7 says "followed by the clipped-parity lemma at the margin scale" and adds that a larger amplitude scale is not excluded. The scale is also explicit in the revision note, Section 0 item 4, Corollary 6 (heading, (c), new part (d)) and the Section 8.4 interpretation. Part (d) quantifies the scale dependence raised in this point.
2. *The headline omits the factor $\min\{1,A_\delta\sqrt{rH_r/d}\}$.* Fixed. The title, Section 0, the Theorem A remarks, R1's name (now "A sharper lower bound on the cost per sample"), R5, R6, R7 and R9 either state the factor or restrict "of order $a^2/\tau_r$" to $\log n\asymp d$. The revision note at the top states the weakening prominently. Remark 8.5 is now proved, but it still leaves a small factor at the bottom of the range.
3. *"Therefore needs" in R2 overstates.* Fixed. R2 now reads "needs, with the bound of Lemma 6.1 (and with the exact norm too, if $\binom D{r+2}\lambda_{r+1}/\tau_r\ge c/\sqrt r$)". It adds that a ratio of order $1/r$ would leave $n\lambda_{r+1}/\tau_r$ bounded and the exact-norm estimate not excluded. Section 0 item 4 and Section 8.4 say the same.
4. *Calling the heuristic sentence "false" is too strong.* Fixed. Section 0 item 3 and the Section 9.1 row now say "incompatible with Theorem A / Proposition prop:linear". They explain that the conditional is false if its antecedent can occur and vacuous otherwise, and that the antecedent is undecided.
5. *E4 shows an undisclosed failed check.* Fixed. E4 now checks the inequality that is used, $D_{r+2}\log(2D_{r+2})\le8\binom D{r+2}rH_r$ (maximum ratio $2.62$), with an analytic proof in (I4). The old quantity is kept as the informational E4b, with analytic bound $3$ and maximum $2.56$. The old output is kept as `check_elementary.v1.out`, and Section 10 explains the correction.
6. *$c_1<\log2$ is not in the statement of Lemma 6.1.* Fixed. (I4), the proof of Theorem A and R1 now cite the proof's choice $2c_1<\log2-\mathsf h(1/4)$. (I4) also notes that decreasing $c_1$ is harmless.

### Referee 2

1. *"Of order $a^2/\tau_r$" in the title, R1, R5 and R6.* Fixed as in Referee 1, point 2.
2. *The $\theta_r\sqrt r$ range.* Fixed. I recomputed it in `check_theta.py` over every odd $r\le d-1$ with representable level masses. My numbers agree with the referee's: the first $r$ above $3.03$ is $39,59,89,133$, and the maxima for $r<d/2$ are $6.46$ ($d=200$) and $7.66$ ($d=400$). The lower bound $0.804$ holds everywhere, with the minimum at $r=1$. One refinement: at $d=3200$ the range over $r\le0.065d$ (up to $r=207$) is $[0.804,3.059]$, slightly above the $3.026$ reported, which is the maximum over $r\le193$. Section 8.4 and Section 10 now give the restricted range and the lower bound separately.
3. *The $3\times10^{-10}$ shortfall is quadrature error, not truncation.* Confirmed and relabelled. The cause is cancellation in $\log1p(-e^{-2x})$ near $w=0$; `check_coeffs.out` shows it. The tail beyond $m=4001$ is about $10^{-85}$, consistent with the referee's estimate.
4. *E4.* Fixed as in Referee 1, point 5.
5. *The bottom-of-range factor.* Confirmed by `check_bottom.out`, which gives $rH_r=(1+o(1))(\log d)^3$ and $r\approx(1.1$–$1.6)(\log d)^2$. The Theorem A remark now says "of order $A_\delta(\log d)^{3/2}/\sqrt d$" and explains where the old $1/2$ came from.
6. *The Tropp citation is unverified.* Addressed by a self-contained proof, Lemma 8.5a, which needs only Lieb's theorem. It gives $\log\operatorname{intdim}$ in place of $\log(2\operatorname{intdim})$, so it implies the recalled form, and the exact constant in the book no longer matters. Section 7 and Section 8.5 now refer to Lemma 8.5a, and the numerics are extended to $n=10^5$.

### Referee 3

1. *(Major) R6 and R7 claim more than Corollary 6 proves.* Fixed (see also Referee 1, point 1). R6, R7, R8 and Section 0 now speak of the head-bound argument at the margin scale. I also adopted the optional suggestion in a stronger form. Corollary 6(d) and the new last paragraph of R2 state that at a clipping scale $b$ the lower bound is multiplied by $a/b$. It therefore excludes $b\le4a(c_\delta C_\delta\rho^3dH_r)^{1/2}$, which at fixed $\rho$ is every $b=o(\sqrt d)$. It is no obstruction at $b$ of order $\sqrt d$, where the missing ingredient is an amplitude bound that [subcritical, Lemma 7.5] does not give at the standard scaling. The Section 9.1 verdict on lines 964–966 is corrected: "It does not show that the subcritical strategy fails" remains true.
2. *Tropp citation; state the bound with an absolute constant; mark it tanh-specific.* Fixed. Lemma 8.5a is the one-paragraph derivation: Lieb's subadditivity, the Chernoff mgf bound and the intrinsic-dimension lemma. Its last step uses Jensen's inequality, $\theta\E\lambda_{\max}\le\log\E e^{\theta\lambda_{\max}}$, instead of integrating the tail. This removes the extra additive $L/\theta$ in the referee's reconstruction and gives $\E\lambda_{\max}\le((e^\theta-1)/\theta)\mu+(L/\theta)\log\operatorname{intdim}$ with explicit constants. The remark is now headed "$\tanh$ only", and the status paragraph explains the dependence on Corollary 4.2 through Lemma 4.3(a). The bibliography note is added.
3. *Wrong citation of [subcritical, eq. (45)].* Fixed. R2 now cites [subcritical, eqs. (41) and (43)] for the $\|Q_{SS}\|_{\rm op}$ form, and notes that (45) then inserts that paper's Gram bound (44). Section 8.3 says the same. R8 no longer says "the head bound (45)". The same mismatch in the paper's own text (lines 851–854) gets a new block, R10, and a new row in Section 9.1.
4. *Lemma 4.4 is inherited.* Fixed. A "Caveats" paragraph in Section 2 lists (I3) as inherited, describes its dependence on the homogeneous form of Lee's (2.20), and explains why the dependence matters and why it does not affect the internal comparison.
5. *E4.* Fixed as in Referee 1, point 5.
