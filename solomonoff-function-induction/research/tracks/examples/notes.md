# Track "examples": worked examples for Solomonoff function induction

*Track "examples" of the SFI project: brief items H5 (cyclic permutation) and H6 (Eisenstat's example), positive examples, Hänni's OOD examples, and computable proxies. Read `../../00-brief.md` first. Scripts are in `checks/` (seeded where random; each saves its output next to itself as `*.out.txt`). Reusable code is in `../../../code/sfi_examples.py` and `../../../code/sfi_dsl.py`.*

**Status tags.** **[proved]**: full proof here. **[computed]**: checked by a script in `checks/` with saved output. **[known]**: published result, with reference; **(unverified)** means I could not check it against the source. **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]** as usual. Results imported from the parallel tracks are marked **[foundations]**, **[history]** or **[context]** with the item number; they are proved there, and I do not re-prove them. Hänni's statements are treated as hypotheses.

---

## 0. Summary

| # | Claim | Status |
|---|---|---|
| **H5** | **Cyclic permutation** of $\{0,1\}^n$, $N=2^n$, revealed backwards along the cycle starting at $0^n$. | |
| 2.1 | For every total $f:\{0,1\}^n\to\{0,1\}^n$: $K(f\mid n)-c\le L_{\rm SFI}(f)\le K(f\mid n)+K(n)+c$. For every cyclic $f$: $L_{\rm SFI}(f)\le\log_2((N-1)!)+c$, with no $K(n)$ term. For uniform cyclic $f$: $\Pr[L_{\rm SFI}(f)<\log_2((N-1)!)-m-c]<2^{-m}$ and $\mathbb E\,L_{\rm SFI}(f)\ge\log_2((N-1)!)-c$. Here $\log_2((N-1)!)=(n-\log_2e)\,2^n-n/2+\tfrac12\log_2(2\pi)+\Theta(2^{-n})$. Hänni's claim "high loss under SFI" holds, with these constants. | proved; constants computed (e3) |
| 2.3 | After $k\le N-1$ steps: $\log_2(N-1)_k-\log_2(N-1)-m-c\le L_{\rm SFI}(D_k)\le\log_2(N-1)_k-\max\{0,\log_2(N-k)-k\}+c$, the lower bound with probability $\ge1-2^{-m}$. So SFI pays about $n$ bits per step. The $\log_2(N-1)$ slack is needed for small $k$ ($L_{\rm SFI}(D_1)\le c$). | proved |
| 2.4 | The cost is intrinsic to order-free prediction: every random-function law $\nu$ has $\mathbb E[-\log_2\nu(D_k)]\ge\log_2(N-1)_k-\log_2(N-1)$, and every weak function semimeasure has $\mathbb E[-\log_2\nu(f)]\ge\log_2((N-1)!)$. | proved |
| 2.5 | SFI$^{\rm hist}$ (and Hutter's $\xi$): loss $\le c$ on every such sequence, every $n$, every $f$. | proved, given [history] Cor 4.3 |
| 2.6 | SI on the interleaved sequence $x_1y_1x_2y_2\dots$ (blocks of $n$ bits): label loss $\le K(n)+m+c$ for all $k$ simultaneously with probability $\ge1-2^{-m}$; expected label loss $\le K(n)+c$. Hänni's "very low loss under SI" holds in this sense. A matching lower bound is not established. | proved |
| **H6** | **Eisenstat's example**: $b_i\sim$ Bern(1/3), Bern(2/3) coin chooses "next unrevealed head" or "next unrevealed tail". $\tau_n$ = tail frontier, $T_n$ = number of tails revealed, $UB_n:=-\log_2P_{1/3}(b_{<\tau_n})=\tau_n\log_23-T_n$. | |
| 3.2 | For every $b$ and every reveal sequence: $L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c$ ("threshold function" = Bern(1/3) below $\tau_n$, constant 1 from $\tau_n$ on). | proved |
| 3.3 | Pathwise sandwich: if $b$ is Martin-Löf random for Bern(1/3) and the heads frontier is not behind the tails frontier, then $UB_n-K(g_n)-c_b\le L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c$, for every reveal sequence ($g_n$ = smallest unrevealed index). So $L_{\rm SFI}(D_n)=UB_n\pm O(\log n)$ a.s. | proved |
| 3.4 | $\mathbb E\,UB_n=\tfrac{h(1/3)}2n=0.459148\,n$ **exactly**; $UB_n/n\to h(1/3)/2$ a.s.; $(UB_n-\tfrac{h(1/3)}2n)/\sqrt n\Rightarrow N(0,\sigma^2)$, $\sigma^2=\tfrac29(\tfrac32\log_23-1)^2+\tfrac14(\log_23)^2=1.04966$. | proved (CLT: proof sketch); computed (e1, e2) |
| 3.6 | $-\log_2n-c\le\mathbb E\,L_{\rm SFI}(D_n)-\tfrac{h(1/3)}2n\le\log_2n+2\log_2\log_2n+c$. The brief's $\approx0.459n$ is **verified**; the i.i.d. Bern(1/3) hypothesis pays $(\log_23-\tfrac13)n=1.2516\,n$ in expectation. | proved; computed (e2) |
| 3.7 | Exact law: $\Pr[D_n=D]=\binom nH(2/9)^n r^{M-n}$; the labels given the domain have law $\propto\binom nH$; every order-free predictor has expected loss $\ge\tfrac{h(1/3)}2n-\log_2n-O(1)$. So SFI is optimal among order-free predictors up to $O(\log n)$. | proved; computed (e1) |
| §3.6 | Hänni's email claim ("SFI's log loss is the loss of our threshold function up to $o(n)$") is **correct**, and holds up to $O(\log n)$ a.s. His proof sketch is correct in substance; the precise version needs the domain of the initial segment ($O(\log n)$ bits) and incompressibility measured by $-\log_2P_{1/3}(b_{<\tau_n})$ rather than $\tau_nh(1/3)$. | proved |
| 3.8–3.9 | The Bayes history-aware predictor $P^*$ is explicit; it has positive loss only at "touching" steps (revealed set an initial segment). The number of touching steps is Geometric(1/3) with mean 3, and $\mathbb E\,L_{P^*}(\infty)=3\kappa=2.39855$ bits, $\kappa=0.79952$. | proved; computed (e1) |
| 3.10 | SFI$^{\rm hist}$: $L\le L_{P^*}+c$ on every path, so $\mathbb E L\le2.399+c$ and $\sup_nL<\infty$ a.s. SI (interleaved): $\mathbb E L^y\le2.399+c$ for all $n$, and $\sup_n(L^y-L_{P^*})\le c+m$ with probability $\ge1-2^{-m}$. The brief's "smallest unrevealed index is the next tail after a burn-in" is exact after the last touching step with the heads ahead. | proved |
| **Pos.** | **Positive examples** | |
| 4.1 | Deterministic computable target: $L_{\rm SFI}\le K(f)+c$ and at most $K(f)+c$ steps with $P(\text{correct})\le1/2$, on every input sequence and order. Parity of a $k$-subset of $[d]$: $\le\log_2\binom dk+K(d)+K(k)+c$, and every learner pays $\ge\log_2\binom dk$ in expectation on spanning inputs; thresholds $\le K(\theta)+c$; sorting $\le c$; integer polynomials $\le\sum_iK(a_i)+O(d)$. | proved; computed (e4) |
| 4.6 | Frozen i.i.d. label noise at rate $\varepsilon$ around a computable $g$: $L_{\rm SFI}\le\log_2\binom n{e_n}+\log_2(n+1)+K(g)+c$, so expected regret against the noise entropy $nh(\varepsilon)$ is between 0 and $K(g)+\log_2(n+1)+c$. | proved; computed (e4) |
| **OOD** | **Hänni's OOD examples** (proof/disproof labels; shortest proofs; lengths of odd strings) | |
| §5 | What is proved: the intended answer has probability $\ge2^{L_{\rm SFI}(D)-K(g)-c}$; a simple unseen property gives a wrong answer probability bounded below independently of the amount of data ([context] Prop 2.1, Thm 2.5, Ex 2.15); total OOD errors over any sequence are $\le K(g)+c$ ([context] Thm 2.7). What is only plausible: that the intended answer gets probability near 1 on a natural machine. It is machine-dependent: on the enumerated grammar of e5 it is 0.983, 0.998 or 0.9998 depending on one prior weight, and 0.11 on a tilted grammar. | proved (citing [context]); computed (e5); plausibility claims are conjecture |

Two caveats apply throughout.
* **Convention.** All SFI losses are in the semimeasure convention $L_{\rm SFI}(D)=-\log_2M_F(D)$, which is order-independent ([foundations] Prop 5.2). Upper bounds transfer to the per-step normalised predictor, lower bounds do not ([history] §1.2). Lower bounds for the normalised predictor in examples H5 and H6 are **[open]** (§7).
* **Constants.** $c$ denotes a constant depending only on the fixed universal machines and encodings. It can be large. Statements of the form "loss $\le c$" are qualitative.

---

## 1. Setting, facts used, and three lemmas

### 1.1 Notation

I follow the foundations track.
* $X=Y=\{0,1\}^*$, or $\mathbb N$ where stated. A *data set* $D$ is a finite partial function; $\mathrm{dom}\,D$ is its domain. A *function machine* reads a shared uniformly random tape $\omega$; its value at $x$ is fixed by a finite prefix of $\omega$. Its *law* is $\nu_T(D)=\lambda\{\omega:f^T_\omega\supseteq D\}$.
* $M_F$ is the law of the universal function machine ([foundations] Thm 3.2). $L_{\rm SFI}(D):=-\log_2M_F(D)$. For a reveal sequence $(x_t,y_t)_{t\le n}$ with $D_n=\{(x_t,y_t)\}$, the per-step conditionals $M_F(D_t)/M_F(D_{t-1})$ multiply to $M_F(D_n)$, so the cumulative loss is $L_{\rm SFI}(D_n)$ whatever the order.
* $K(\cdot)$, $K(\cdot\mid\cdot)$ are prefix complexities. For a function $f$, $K(f)$ is the length of a shortest program computing it; for a law, $K(\nu)$ is the complexity of an index ([foundations] §1).
* $\log=\log_2$. $h(p)=-p\log p-(1-p)\log(1-p)$. $(a)_k=a(a-1)\cdots(a-k+1)$.
* A *history-aware predictor* gives $P(y\mid h,x)$ with $\sum_yP(y\mid h,x)\le1$, where $h$ is the past (inputs and labels). Its loss is $L_P=\sum_t-\log P(y_t\mid h_{t-1},x_t)$.

### 1.2 Facts used

* **(F1) Dominance** [foundations Thm 3.2, Prop 3.3]. $M_F\ge2^{-K(\nu)-c}\nu$ for every machine law $\nu$. Machine laws include deterministic partial computable functions ($\nu(D)=[\varphi\supseteq D]$, so $M_F(D)\ge2^{-K(\varphi)-c}$ for $D\subseteq\varphi$), lower-semicomputable product laws (private randomness per input), and computable laws with shared randomness. I use only explicit machines below and say how each is built.
* **(F2) Monotonicity.** $D\subseteq D'$ implies $M_F(D')\le M_F(D)$, since $M_F$ is a containment functional.
* **(F3) Conditional coding theorem** [known: Levin 1974; Gács 1974; Chaitin 1975; Li–Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., Springer 2008, §4.3 (unverified section number)]. If $\nu(z\mid w)\ge0$ is lower semicomputable uniformly in $(z,w)$ and $\sum_z\nu(z\mid w)\le1$ for all $w$, then $K(z\mid w)\le-\log\nu(z\mid w)+K(\nu)+c$.
* **(F4) Levin–Schnorr for computable measures** [known: Levin 1973, Schnorr 1973; Li–Vitányi 2008, §3.6 and §4.5 (unverified numbering)]. If $\mu$ is a computable measure on $\{0,1\}^\infty$, $\omega$ is Martin-Löf random for $\mu$ iff there is $c_\omega$ with $K(\omega_{<k})\ge-\log\mu(\omega_{<k})-c_\omega$ for all $k$.
* **(F5) Ville's maximal inequality** [known: J. Ville, *Étude critique de la notion de collectif*, 1939 (unverified)]. A nonnegative supermartingale $W$ with $W_0\le1$ has $\Pr[\sup_nW_n\ge a]\le1/a$.
* **(F6) Kraft and Gibbs.** $\sum_z2^{-K(z\mid w)}\le1$. Hence for any random variable $Z$, $\mathbb E[K(Z\mid w)]\ge H(Z)$, and more generally $\mathbb E[-\log q(Z)]\ge H(Z)$ for any $q$ with $\sum_zq(z)\le1$.
* **(F7) SFI$^{\rm hist}$ dominance** [history Cor 4.3(b); for Hutter's universal chronological semimeasure $\xi$ this is its defining property, known: M. Hutter, *Universal Artificial Intelligence*, Springer 2005, ch. 5 (unverified)]. For every lower-semicomputable history-aware predictor $P$ and every function-consistent sequence, $L_{\rm hist}\le L_P+K(P)+c$. Hypotheses of SFI$^{\rm hist}$ see the list of previous inputs; by [history] Prop 4.4(a) seeing previous labels as well gives the same class.
* **(F8) Solomonoff's universal semimeasure** [known: Zvonkin–Levin 1970; Li–Vitányi 2008 §4.5 (unverified numbering)]. $M$ on $\{0,1\}^*$ is a lower-semicomputable semimeasure with $M\ge2^{-K(\mu)-c}\mu$ for every lower-semicomputable semimeasure $\mu$.
* **(F9)** $K(i)\le\log(i+1)+2\log\log(i+2)+c$ for integers $i\ge0$ [known; standard].

### 1.3 Three lemmas

**Lemma 1.1 (domain lower bound)** **[proved]**. For every data set $D$: $L_{\rm SFI}(D)\ge K(D\mid\mathrm{dom}\,D)-c$. The same argument gives, for every law $\nu$ of a random partial function and every finite $S$, $\sum_{D:\,\mathrm{dom}\,D=S}\nu(D)\le1$.

*Proof.* Fix a finite set $S$. For distinct labellings $l,l'$ of $S$ the events $\{f_\omega\supseteq l\}$ and $\{f_\omega\supseteq l'\}$ are disjoint, so $l\mapsto M_F(l)$ is a discrete semimeasure. It is lower semicomputable uniformly in $S$. Apply (F3) with $w=S$. $\square$

(This is [history] Lemma 1.1 and the left side of [foundations] Thm 6.3; I restate it because everything below uses it.)

**Lemma 1.2 (complexity is at least surprisal, with high probability)** **[proved]**. Let $Z$ be a random variable with values in a countable set, $w$ fixed, and $P(\cdot)$ the law of $Z$ (any law, computable or not). For every $m\ge0$, $\Pr[K(Z\mid w)<-\log P(Z)-m]<2^{-m}$, and $\mathbb E\,K(Z\mid w)\ge H(Z)$.

*Proof.* $\Pr[K(Z\mid w)<-\log P(Z)-m]=\sum_{z:\,P(z)<2^{-K(z\mid w)-m}}P(z)<\sum_z2^{-K(z\mid w)-m}\le2^{-m}$ by Kraft. The expectation bound is (F6). $\square$

When $Z$ is uniform on a set of size $A$ this is the counting bound: fewer than a $2^{-m}$ fraction of the elements have $K(\cdot\mid w)<\log A-m$.

**Lemma 1.3 (SI's label loss is controlled by the true input law)** **[proved]**. Let $\mu$ be a probability law on infinite sequences of pairs $(x_t,y_t)$ in countable sets. Encode a history $h_t=(x_1,y_1,\dots,x_t,y_t)$ as $\mathrm{c}(h_t)=\bar x_1\bar y_1\cdots\bar x_t\bar y_t$ with prefix-free codes $\bar\cdot$. Let $\rho$ be a semimeasure on $\{0,1\}^*$ with $\rho(\mathrm c(h_t))\ge2^{-k}\mu(h_t)$ for all $t$ and all histories, where $\mu(h_t)$ is the probability of the history. Define the label losses
$$L^y_\rho(n):=\sum_{t\le n}-\log\frac{\rho(\mathrm c(h_{t-1})\bar x_t\bar y_t)}{\rho(\mathrm c(h_{t-1})\bar x_t)},\qquad L^y_\mu(n):=\sum_{t\le n}-\log\mu(y_t\mid h_{t-1},x_t).$$
Then (i) $\mathbb E_\mu L^y_\rho(n)\le\mathbb E_\mu L^y_\mu(n)+k$ for all $n$, and (ii) $\mu\big[\exists n:\ L^y_\rho(n)>L^y_\mu(n)+k+m\big]\le2^{-m}$.

*Proof.* Put $Q_t:=\rho(\mathrm c(h_{t-1})\bar x_t)/\rho(\mathrm c(h_{t-1}))$. Telescoping, $\rho(\mathrm c(h_n))=\rho(\varepsilon)\prod_tQ_t\cdot2^{-L^y_\rho(n)}$, and $\rho(\varepsilon)\le1$. So
$$L^y_\rho(n)\le-\log\rho(\mathrm c(h_n))+\sum_t\log Q_t\le k-\log\mu(h_n)+\sum_t\log Q_t=k+L^y_\mu(n)+\log W_n,$$
with $W_n:=\prod_{t\le n}Q_t/\mu(x_t\mid h_{t-1})$. (Along $\mu$-almost every path all these quantities are positive.) $W$ is a nonnegative supermartingale under $\mu$ with $W_0=1$: given $h_{t-1}$, $\mathbb E[Q_t/\mu(x_t\mid h_{t-1})\mid h_{t-1}]=\sum_{x:\mu(x|h_{t-1})>0}Q_t(x)\le1$. The last step holds because the codewords $\bar x$ are prefix-free, and a semimeasure satisfies $\sum_{w\in W}\rho(sw)\le\rho(s)$ for every prefix-free set $W$ (induction on finite $W$, then a limit). The label $y_t$ does not change $W$. Hence $\mathbb E\log W_n\le\log\mathbb EW_n\le0$, which gives (i), and Ville's inequality (F5) gives (ii). $\square$

*Use.* Take $\rho=M$ (F8), or the normalised Solomonoff measure (which is $\ge M$), and $\mu$ computable, so $k=K(\mu)+c$. Then SI's label loss exceeds the Bayes-optimal history-aware label loss by at most $K(\mu)+c$ in expectation. The input part of the sequence may be incompressible: the argument only needs SI to predict the inputs no better than $\mu$ does on average, which Gibbs' inequality guarantees. Pathwise comparisons between SI's label loss and SFI$^{\rm hist}$ are in [history] Thm 4.6: the excess is bounded by input-loss terms, and by $K(\delta)+c$ for a deterministic computable input policy $\delta$. Lemma 1.3 is the probabilistic counterpart for random inputs from a computable law. It does not contradict the Lattimore–Hutter–Gavane remark that unnormalised $M$ "can fail to predict very simple recursive sub-patterns" ([history] §4.4, unverified beyond the abstract): that failure concerns particular input sequences, while Lemma 1.3 holds in expectation and with high probability.

---

## 2. Hänni's cyclic-permutation example (H5)

### 2.1 Setup

Fix $n\ge1$ and $N=2^n$. Let $f$ be a uniformly random cyclic permutation of $\{0,1\}^n$ (a single $N$-cycle). Put $x_0:=0^n$ and $x_k:=f^{-1}(x_{k-1})$ for $k=1,\dots,N$, so $x_N=0^n$. The $k$-th revealed pair is $(x_k,x_{k-1})$, and $D_k:=\{(x_i,x_{i-1}):1\le i\le k\}$. $D_N$ is the graph of $f$.

*Distribution.* $(x_1,\dots,x_{N-1})$ is a uniformly random ordering of $\{0,1\}^n\setminus\{0^n\}$, and the map from orderings to cyclic permutations is a bijection ($f$ is the cycle $0^n\mapsto x_{N-1}\mapsto x_{N-2}\mapsto\dots\mapsto x_1\mapsto0^n$). There are $(N-1)!$ of each **[proved; computed for $n=2,3$ by exhaustion: e3(c)]**.

### 2.2 SFI

**Theorem 2.1 (full cycle)** **[proved]**.
1. For every total $f:\{0,1\}^n\to\{0,1\}^n$: $K(f\mid n)-c\le L_{\rm SFI}(f)\le K(f\mid n)+K(n)+c$.
2. For every cyclic permutation $f$ of $\{0,1\}^n$, every $n$: $L_{\rm SFI}(f)\le\log_2((N-1)!)+c$.
3. For uniform cyclic $f$ and every $m\ge0$: $\Pr\big[L_{\rm SFI}(f)<\log_2((N-1)!)-m-c\big]<2^{-m}$, and $\mathbb E\,L_{\rm SFI}(f)\ge\log_2((N-1)!)-c$.
4. $\log_2((N-1)!)=(n-\log_2e)N-\tfrac n2+\tfrac12\log_2(2\pi)+\epsilon_N$ with $\frac1{(12N+1)\ln2}<\epsilon_N<\frac1{12N\ln2}$.

The same bounds hold for $L_{\rm SFI}(D_{N-1})$, since $D_{N-1}$ determines $f$.

*Proof.* 1. Lower: Lemma 1.1, since $\mathrm{dom}\,f=\{0,1\}^n$ and $n$ are computable from each other. Upper: $f$ is computed by a program of length $\le K(f\mid n)+K(n)+c$; apply (F1).
2. Let $T_{\rm cyc}$ be the function machine that, for each length $\ell$, reads its own sub-stream $(\omega_{\langle\ell,j\rangle})_{j\ge0}$ of the tape and runs Sattolo's algorithm on $\{0,1\}^\ell$, drawing each uniform integer by rejection sampling from fair bits. This produces a uniform random cyclic permutation $\pi_\ell$ [known: S. Sattolo, *Inf. Process. Lett.* 22 (1986) 315–317 (unverified)], halts with probability 1, and the sub-streams for different lengths are independent. On input $x$ it outputs $\pi_{|x|}(x)$; the value is fixed by finitely many tape bits. $T_{\rm cyc}$ is one fixed machine, so $K(\nu_{T_{\rm cyc}})=O(1)$, and $\nu_{T_{\rm cyc}}(f)=1/(N-1)!$ for every cyclic $f$. Apply (F1).
3. By the lower bound in part 1, $L_{\rm SFI}(f)\ge K(f\mid n)-c$. Apply Lemma 1.2 with $Z=f$, $w=n$, $P$ uniform on $(N-1)!$ values.
4. Robbins' bounds $\ln m!=m\ln m-m+\tfrac12\ln(2\pi m)+r_m$, $\frac1{12m+1}<r_m<\frac1{12m}$ [known: H. Robbins, *Amer. Math. Monthly* 62 (1955) 26–29 (unverified)], applied to $(N-1)!=N!/N$. $\square$

The constants are tabulated in §2.5. Per revealed pair, SFI pays $\log_2((N-1)!)/N\to n-\log_2e\approx n-1.4427$ bits.

For the $k$-step bound I use the chain semimeasure of [history] Lemma 2.0, adapted to a fixed end point $0^n$.

**Lemma 2.2 (chain semimeasure)** **[proved]**. For a string $x$ and a finite sequence $z=(z_1,\dots,z_j)$ of strings different from $0^{|x|}$ ($j\ge0$), let
$$D(x,z):=\{(x,z_1),(z_1,z_2),\dots,(z_{j-1},z_j),(z_j,0^{|x|})\}\quad(\text{for }j=0:\ \{(x,0^{|x|})\}),$$
$$\nu(z\mid x):=\lambda\{\omega:\ f_\omega(x)=z_1,\ f_\omega(z_i)=z_{i+1}\ (i<j),\ f_\omega(z_j)=0^{|x|}\}.$$
Then $\sum_z\nu(z\mid x)\le1$, $\nu$ is lower semicomputable uniformly in $(x,z)$, and $\nu(z\mid x)=M_F(D(x,z))$ whenever $D(x,z)$ is a function. Hence $K(z\mid x)\le L_{\rm SFI}(D(x,z))+c$.

*Proof.* Fix $\omega$ and $x$. If $z$ satisfies the condition then $z_i=f_\omega^{\,i}(x)\neq0^{|x|}$ for $i\le j$ and $f_\omega^{\,j+1}(x)=0^{|x|}$, so $j+1$ is the first hitting time of $0^{|x|}$ along the $f_\omega$-orbit of $x$, and $z$ is the orbit up to that time. So at most one $z$ qualifies, and the events are disjoint. Lower semicomputability is as in Lemma 1.1. Apply (F3). $\square$

The same disjointness holds for every law of a random partial function in place of $M_F$.

**Theorem 2.3 ($k$ steps)** **[proved]**. Let $1\le k\le N-1$.
1. For every cyclic $f$: $L_{\rm SFI}(D_k)\le\log_2(N-1)_k-\max\{0,\ \log_2(N-k)-k\}+c$. In particular $L_{\rm SFI}(D_1)\le c$.
2. For uniform cyclic $f$ and every $m\ge0$: $\Pr\big[L_{\rm SFI}(D_k)<\log_2(N-1)_k-\log_2(N-1)-m-c\big]<2^{-m}$, and $\mathbb E\,L_{\rm SFI}(D_k)\ge\log_2(N-1)_k-\log_2(N-1)-c$.
3. With probability $\ge1-2^{-m}$, simultaneously for all $k\le N-1$: $L_{\rm SFI}(D_k)\ge\log_2(N-1)_k-2n-m-c$.

*Proof.* 1. Under $T_{\rm cyc}$ the $k$ arcs of $D_k$ form a path that does not close a cycle, so $\nu_{T_{\rm cyc}}(D_k)=(N-k-1)!/(N-1)!=1/(N-1)_k$ (contract the path; computed for $n=2,3$ in e3(c)). This gives the first term. For the second, let $T'$ answer each input $x$ independently with probability $1/2$ by $0^{|x|}$ (a private bit of $x$) and otherwise by $\pi_{|x|}(x)$ as in $T_{\rm cyc}$. Then $\nu_{T'}(D_k)\ge\tfrac12\cdot2^{-(k-1)}\cdot\Pr[\pi\supseteq D_k\setminus\{(x_1,0^n)\}]=2^{-k}/(N-1)_{k-1}$, and $\log_2(N-1)_{k-1}=\log_2(N-1)_k-\log_2(N-k)$. For $k=1$, the constant map $x\mapsto0^{|x|}$ gives $M_F(D_1)\ge2^{-c}$.
2. $D_k=D(x_k,z)$ with $z=(x_{k-1},\dots,x_1)$. By Lemma 2.2, $L_{\rm SFI}(D_k)\ge K(x_{k-1},\dots,x_1\mid x_k)-c$. Given $x_k$, the tuple $(x_1,\dots,x_{k-1})$ is uniform over the $(N-2)_{k-1}$ injective sequences from $\{0,1\}^n\setminus\{0^n,x_k\}$, and $\log_2(N-2)_{k-1}=\log_2(N-1)_k-\log_2(N-1)$. Apply Lemma 1.2 conditionally on $x_k$.
3. Union bound over $k$ in part 2 with $m+n$ in place of $m$, and $\log_2(N-1)<n$. $\square$

*Reading.* For $1\ll k\le N-1$, SFI pays $\log_2(N-1)_k\pm O(n)$ bits, i.e. about $n$ bits per pair until the end of the cycle, where the falling factorial gives $n-\log_2e$ on average. For $k<n$, the upper bound in part 1 is within $k+m+c$ of the lower bound, so the $\log_2(N-1)$ slack in part 2 cannot be removed for small $k$.

**Proposition 2.4 (the cost is intrinsic to order-free prediction)** **[proved]**.
1. For every law $\nu$ of a random partial function (computable or not; "x-only predictor with shared randomness") and every $k\le N-1$: $\mathbb E_f[-\log_2\nu(D_k)]\ge\log_2(N-1)_k-\log_2(N-1)$.
2. For every weak function semimeasure $\nu$ ([foundations] Def 2.1; this includes every order-free online predictor): $\mathbb E_f[-\log_2\nu(f)]\ge\log_2((N-1)!)$.

*Proof.* 1. By the remark after Lemma 2.2, $z\mapsto\nu(D(x,z))$ has total mass $\le1$ for each $x$. Apply Gibbs (F6) to the conditional law of $(x_{k-1},\dots,x_1)$ given $x_k$. 2. $\sum_{g:\{0,1\}^n\to\{0,1\}^n}\nu(g)\le1$ ([foundations] Def 2.1, consequence (b)); apply Gibbs to the uniform law on $(N-1)!$ cyclic permutations. $\square$

So the gap between SFI and SI here is not a weakness of the universal prior. No predictor that sees past data only as a set of pairs, and evaluates the data set as a whole, can do better on average. (Set-based *history-aware* predictors are a different class: they can reconstruct the order from the set of pairs; see Remark 2.7.)

### 2.3 SFI$^{\rm hist}$

**Proposition 2.5** **[proved, given (F7)]**. Let $P_{\rm copy}$ be the deterministic history-aware predictor: on the empty history predict $0^{|x|}$; otherwise predict the most recent input. For every $n$, every cyclic $f$ and every $k\le N$: $L_{\rm hist}(D_k\text{ in reveal order})\le K(P_{\rm copy})+c=c'$.

*Proof.* $P_{\rm copy}$ is computable and has loss 0 on the sequence $(x_1,0^n),(x_2,x_1),\dots$. Apply (F7). $\square$

The bound holds pathwise, for every $n$, with a constant independent of $n$ (unlike SI, Prop 2.6), and for every chain of distinct strings ending at $0^n$, random or not.

### 2.4 SI on the interleaved sequence

Encode the history as the binary string $x_1y_1x_2y_2\cdots$ with each $x_k,y_k$ written as $n$ bits (no delimiters; SI is not told $n$). SI's label loss after $k$ steps is $L^y_M(k)=\sum_{t\le k}-\log M(y_t\mid x_1y_1\cdots x_t)$, the sum of its bitwise conditional losses on the label blocks.

**Proposition 2.6** **[proved]**. For every $n$ and $m\ge0$, with $f$ uniform cyclic:
* $\Pr\big[\exists k\le N:\ L^y_M(k)>K(n)+m+c\big]\le2^{-m}$;
* $\mathbb E\,L^y_M(k)\le K(n)+c$ for every $k\le N$.
The same holds for the normalised Solomonoff measure.

*Proof.* Let $\mu_n$ be the law of the interleaved sequence: $x_t$ uniform over the nonzero $n$-bit strings not yet used ($t\le N-1$), $x_N=0^n$, $y_t=x_{t-1}$ ($y_1=0^n$), continued after step $N$ by any fixed computable rule. $\mu_n$ is computable from $n$, so $M\ge2^{-K(n)-c}\mu_n$ (F8), and $\mu_n$'s label loss is 0. Apply Lemma 1.3 with $k=K(n)+c$. Fixed-length blocks are a prefix-free code. $\square$

I have no lower bound on SI's label loss beyond 0. Whether it is $\Theta(K(n))$, $O(\log n)$ or $O(1)$ for fixed $n$ is **[open]**. (If $n$ is itself drawn from a computable prior $w$ with finite entropy, Lemma 1.3 applied to the mixture $\sum_nw(n)\mu_n$ gives $\mathbb E\,L^y_M\le H(w)+c$: the Bayes label loss of the mixture is at most $H(w)$, by the same Gibbs argument on the input part. This averages the cost of not knowing $n$ over $n$; it does not remove it.)

### 2.5 Numbers

**Constants** **[computed: e3(a)]**. $\log_2((N-1)!)$, the Stirling form of Thm 2.1(4), and the per-pair average:

| $n$ | $N$ | $\log_2((N-1)!)$ | per pair $/N$ | $n-\log_2e$ |
|---|---|---|---|---|
| 2 | 4 | 2.585 | 0.646 | 0.557 |
| 4 | 16 | 40.250 | 2.516 | 2.557 |
| 8 | 256 | 1675.996 | 6.547 | 6.557 |
| 10 | 1024 | 8759.006 | 8.554 | 8.557 |
| 16 | 65536 | 954020.864 | 14.557 | 14.557 |
| 20 | $2^{20}$ | 19458735.931 | 18.557 | 18.557 |

The Stirling error equals $1/(12N\ln2)$ to the printed precision for $n\le24$ (e.g. $1.174\cdot10^{-4}$ at $n=10$).

**Proxies** **[computed: e3(b)]**. Three exact Bayes mixtures over small enumerated classes (code: `sfi_examples.cyclic_example_losses`):
* *SFI proxy* (order-free): weight 1/6 each on the uniform cyclic-permutation law, the uniform permutation law, the uniform function law, and the maps $x\mapsto0$, identity, $x\mapsto x+1\bmod N$.
* *History proxy*: weight 1/3 each on copy-the-previous-input, uniform label, uniform over labels not yet used.
* *SI proxy*: weight 1/3 each on three joint models of $(x_1,y_1,x_2,\dots)$ with $n$-bit blocks as symbols: the true process; true inputs with uniform labels; all symbols uniform.

Cumulative losses in bits. At $k=N/2$ and $k=N$ they were identical across the 3 seeds for $n\ge3$: the random-function components depend only on $k$, and the three deterministic maps were inconsistent with the data.

| $n$ | SFI proxy, $k=N/2$ | $\log_2(N-1)_{N/2}$ | SFI proxy, $k=N$ | $\log_2((N-1)!)$ | history proxy, $k=N$ | SI proxy label loss, $k=N$ |
|---|---|---|---|---|---|---|
| 4 | 29.894 | 27.951 | 42.748 | 40.250 | 1.585 | 1.544 |
| 6 | 179.332 | 177.332 | 292.558 | 289.995 | 1.585 | 1.577 |
| 8 | 968.835 | 966.835 | 1678.576 | 1675.996 | 1.585 | 1.583 |
| 10 | 4894.840 | 4892.840 | 8761.590 | 8759.006 | 1.585 | 1.584 |
| 12 | 23670.861 | 23668.861 | 43240.632 | 43238.047 | 1.585 | 1.585 |

The SFI proxy pays $\log_2((N-1)!)+\log_26$ over the cycle; the history and SI proxies pay the cost of their prior weight, $\log_23=1.585$ bits, in total. At $k=1$ the SFI proxy pays $\le2.6$ bits (the zero map), as Thm 2.3(1) predicts for SFI.

### 2.6 Remarks

**Remark 2.7 (where the information is)** **[proved]**. The labels carry no information beyond the inputs: $y_k=x_{k-1}$. All of $f$ is in the order of the inputs. SI and SFI$^{\rm hist}$ see the order; SFI sees each pair in isolation, and its loss is that of the unordered set. A set-based history-aware predictor (one that sees $D_{t-1}$ as a set) can also predict perfectly: in $D_{t-1}$ the most recent input is the unique input that is not a label. So the separation is between evaluating the data set as a whole and predicting with the past in view, not between sets and sequences. This predictor sees the previous *pairs*. The history track's SFI$^{\rm set}$, whose hypotheses see only the *set of previous inputs*, is weaker: for labels $y_1=\varepsilon$, $y_i=x_{i-1}$ it pays $\ge\log_2n!-\log_2n-c$ on a suitable order ([history] Prop 4.5(iii)).

**Remark 2.8 (relation to the chain example).** Hänni's chain of increasingly long random strings is [history] Thm 2.1. The cyclic permutation is the finite, uniform version: a single length $n$, all strings used, and the cost per step is $n$ bits rather than the length of a new random block.

---

## 3. Eisenstat's example (H6)

### 3.1 Setup

$b=(b_0,b_1,\dots)$ with $b_i$ i.i.d., $\Pr[b_i=1]=1/3$ ("heads", label 1). At each step $t=1,2,\dots$ an independent coin $\zeta_t$ with $\Pr[\zeta_t=1]=2/3$ decides: if $\zeta_t=1$, reveal the smallest unrevealed index $i$ with $b_i=1$, with label 1; else reveal the smallest unrevealed index with $b_i=0$, with label 0. After $n$ steps:
* $H_n,T_n$: numbers of heads and tails revealed ($H_n+T_n=n$, $T_n\sim\mathrm{Bin}(n,1/3)$, independent of $b$);
* $\tau_n$: tail frontier, $1+$ the index of the last revealed tail ($0$ if none); $\eta_n$: head frontier; $F_n=\max(\tau_n,\eta_n)$;
* $g_n$: the smallest unrevealed index; $R_n=\mathrm{dom}\,D_n$;
* $UB_n:=-\log_2P_{1/3}(b_{<\tau_n})=T_n\log_2\tfrac32+(\tau_n-T_n)\log_23=\tau_n\log_23-T_n$.

**Lemma 3.1 (shape of the revealed set)** **[proved]**. The revealed tails are exactly the tails below $\tau_n$, and the revealed heads exactly the heads below $\eta_n$. An unrevealed index below $\eta_n$ is a tail; an unrevealed index below $\tau_n$ is a head; no unrevealed index lies below $\min(\tau_n,\eta_n)$. If $\tau_n\le\eta_n$ ("heads ahead"), then $[0,\tau_n)\subseteq R_n$, $g_n\ge\tau_n$, and every index in $[\tau_n,g_n)$ is a head. In all cases $[0,g_n)\subseteq R_n$, by definition of $g_n$.

*Proof.* The process always reveals the first unrevealed head (or tail), so the revealed heads are the first $H_n$ heads, and these are the heads below $\eta_n$; likewise for tails. The rest follows: an index below both frontiers is revealed whatever its label, and an index in $[\tau_n,g_n)$ is revealed but is not a revealed tail. $\square$

So after $n$ steps the revealed set is about $[0,n/2)$ together with the heads in $[n/2,2n)$, as the brief says: $\tau_n\approx\tfrac32T_n\approx n/2$ and $\eta_n\approx3H_n\approx2n$.

### 3.2 The threshold hypothesis and the upper bound

For $t\in\mathbb N$, the *threshold law* $\nu_{t}$ is the product law with $\Pr[y=1\mid i]=1/3$ for $i<t$ and $\Pr[y=1\mid i]=1$ for $i\ge t$. This is "our threshold function" of Hänni's email, as I read it: Bern(1/3) below the threshold, constant 1 at and above it.

**Proposition 3.2 (upper bound)** **[proved]**. For every $b$, every reveal sequence of the above type (the choices may be arbitrary, even adversarial), and every $n$:
$$L_{\rm SFI}(D_n)\le UB_n+K(\tau_n)+c\le UB_n+\log(\tau_n+1)+2\log\log(\tau_n+2)+c.$$

*Proof.* $\nu_t$ is a computable product law with index computable from $t$, so $M_F\ge2^{-K(t)-c}\nu_t$ (F1). Take $t=\tau_n$. Revealed indices at or above $\tau_n$ are heads (Lemma 3.1), so they contribute factor 1. The revealed indices below $\tau_n$ contribute a sub-product of $P_{1/3}(b_{<\tau_n})$, which is $\ge P_{1/3}(b_{<\tau_n})$. Then (F9). $\square$

### 3.3 The lower bound and the pathwise sandwich

**Theorem 3.3 (pathwise sandwich)** **[proved]**. For every $b$, every reveal sequence and every $n$: $L_{\rm SFI}(D_n)\ge K(b_{<g_n}\mid g_n)-c$. If moreover $b$ is Martin-Löf random for the Bern(1/3) product measure, then at every $n$ with $\tau_n\le\eta_n$:
$$UB_n-K(g_n)-c_b\ \le\ L_{\rm SFI}(D_n)\ \le\ UB_n+K(\tau_n)+c .$$
In Eisenstat's process, almost surely $\tau_n\le\eta_n$ and $g_n\le3n$ for all large $n$, so $|L_{\rm SFI}(D_n)-UB_n|\le\log_2n+O(\log\log n)+c_b$ eventually.

*Proof.* $[0,g_n)\subseteq R_n$ with labels $b_{<g_n}$ (Lemma 3.1). By (F2) and Lemma 1.1, $L_{\rm SFI}(D_n)\ge L_{\rm SFI}(D_n|_{[0,g_n)})\ge K(b_{<g_n}\mid[0,g_n))-c$, and the set $[0,g_n)$ and the number $g_n$ are computable from each other. For the second statement, $K(b_{<g_n}\mid g_n)\ge K(b_{<g_n})-K(g_n)-c\ge-\log P_{1/3}(b_{<g_n})-c_b-K(g_n)-c$ by (F4), and $-\log P_{1/3}(b_{<g_n})\ge-\log P_{1/3}(b_{<\tau_n})=UB_n$ because $g_n\ge\tau_n$ when $\tau_n\le\eta_n$. The upper bound is Prop 3.2. For the last sentence: $\Pr[\eta_n<\tau_n]\le20e^{-n/18}$ (Lemma 3.5) is summable, so by Borel–Cantelli the heads are eventually ahead. By the strong law of large numbers $H_n/n\to2/3$, $T_n/n\to1/3$, and the $j$-th head (tail) of $b$ sits at about $3j$ ($3j/2$), so $\eta_n/n\to2$ and $\tau_n/n\to1/2$ almost surely; hence $g_n\le F_n\le3n$ for all large $n$. Martin-Löf random $b$ have probability 1. Apply (F9) to $K(g_n)$ and $K(\tau_n)$. $\square$

Note that the sandwich holds for **every** reveal sequence with the heads ahead, not only for Eisenstat's random one. The lower bound uses only that an initial segment of $b$ is revealed with its true labels.

### 3.4 Asymptotics of the threshold loss

**Proposition 3.4** **[proved; CLT: proof sketch; computed: e1(d), e2]**.
1. $\mathbb E\,UB_n=\tfrac{h(1/3)}2n=(\tfrac12\log_23-\tfrac13)n=0.4591479\,n$ exactly, for every $n$.
2. $UB_n/n\to h(1/3)/2$ almost surely.
3. $(UB_n-\tfrac{h(1/3)}2n)/\sqrt n\Rightarrow N(0,\sigma^2)$ with $\sigma^2=\tfrac29(\tfrac32\log_23-1)^2+\tfrac14(\log_23)^2=1.04966$.

*Proof.* Let $G_j$ be the number of heads before the $j$-th tail of $b$. Then $\tau_n=T_n+G_{T_n}$, so $UB_n=T_n(\log_23-1)+G_{T_n}\log_23$. $G_j$ is a sum of $j$ i.i.d. geometric variables (heads before a tail), each with mean $1/2$ and variance $3/4$, and $G$ is independent of $T_n\sim\mathrm{Bin}(n,1/3)$.
1. $\mathbb E[UB_n\mid T_n=j]=j(\log_23-1)+\tfrac j2\log_23=j(\tfrac32\log_23-1)$, and $\mathbb ET_n=n/3$. Since $h(1/3)=\log_23-\tfrac23$, $\tfrac n3(\tfrac32\log_23-1)=\tfrac n2h(1/3)$.
2. $T_n/n\to1/3$ and $G_j/j\to1/2$ almost surely.
3. *Sketch.* Write $UB_n-\tfrac{h}2n=(T_n-\tfrac n3)(\tfrac32\log_23-1)+(G_{T_n}-\tfrac{T_n}2)\log_23$. Conditionally on $T_n$, the second term is a centred sum of $T_n$ i.i.d. terms independent of the first; both are asymptotically normal with variances $\tfrac{2n}9(\tfrac32\log_23-1)^2$ and $\tfrac n3\cdot\tfrac34(\log_23)^2$ (Anscombe-type CLT for random sums). $\square$

Computed: $\mathbb E\,UB_n-\tfrac h2n$ vanishes to $10^{-11}$ for $n\le1000$ (e1(d)); the empirical sd of $UB_n/\sqrt n$ is $0.99$–$1.11$ for $n=100,\dots,10^4$ against $\sigma=1.0245$ (e2).

**Lemma 3.5 (the heads frontier is rarely behind)** **[proved; computed: e1(f)]**. $\Pr[\eta_n<\tau_n]\le20\,e^{-n/18}$.

*Proof.* If $\eta_n<\tau_n$, all $H_n$ revealed heads lie below $\tau_n$, so $\tau_n\ge H_n+T_n=n$ and the prefix $b_{<\tau_n}$ contains exactly $T_n$ tails. Hence either $T_n\ge n/2$, or some $k\ge n$ has fewer than $k/2$ tails in $b_{<k}$. Hoeffding's inequality gives $\Pr[T_n\ge n/2]\le e^{-2n(1/6)^2}=e^{-n/18}$ and $\Pr[\#\text{tails}(b_{<k})<k/2]\le e^{-k/18}$. Summing, $\Pr\le e^{-n/18}(1+1/(1-e^{-1/18}))\le19.6\,e^{-n/18}$. $\square$

The simulated probabilities are $0.068,0.014,0.001,0,0$ at $n=10,20,40,80,160$; the bound is far from tight but sufficient.

**Theorem 3.6 (expected SFI loss)** **[proved]**. For all $n\ge2$:
$$\tfrac{h(1/3)}2n-\log_2n-c\ \le\ \mathbb E\,L_{\rm SFI}(D_n)\ \le\ \tfrac{h(1/3)}2n+\log_2n+2\log_2\log_2n+c .$$

*Proof.* Upper: take expectations in Prop 3.2. $t\mapsto\log(t+1)+2\log\log(t+2)$ is concave and $\mathbb E\tau_n=n/2$, so Jensen applies; then Prop 3.4(1).
Lower: by Theorem 3.3, $L_{\rm SFI}(D_n)\ge K(b_{<g_n}\mid g_n)-c$ on every path. For each value $g$, Kraft gives $\mathbb E[K(b_{<g_n}\mid g)\mid g_n=g]\ge H(b_{<g_n}\mid g_n=g)$, so $\mathbb E\,L_{\rm SFI}\ge H(b_{<g_n}\mid g_n)-c=H(b_{<g_n})-H(g_n)-c$ (the string $b_{<g_n}$ determines its length $g_n$). Next:
* $\Pr[b_{<g_n}=s]\le\Pr[b_{<|s|}=s]=P_{1/3}(s)$, so $H(b_{<g_n})\ge\mathbb E[-\log P_{1/3}(b_{<g_n})]$.
* On $\{\tau_n\le\eta_n\}$, $g_n\ge\tau_n$ and $-\log P_{1/3}(b_{<g_n})\ge UB_n$. So $\mathbb E[-\log P_{1/3}(b_{<g_n})]\ge\mathbb E\,UB_n-\mathbb E[UB_n;\eta_n<\tau_n]$, and $\mathbb E[UB_n;\eta_n<\tau_n]\le\log_23\,(\mathbb E\tau_n^2)^{1/2}\Pr[\eta_n<\tau_n]^{1/2}=O(n)e^{-n/36}$ by Cauchy–Schwarz and Lemma 3.5.
* $g_n\le$ the first tail at or after $\tau_n$. The event $\{\tau_n=k\}$ depends only on the coins and $b_{<k}$, so the number of heads from $\tau_n$ to that tail has mean $1/2$, and $\mathbb Eg_n\le n/2+1/2$. A random variable on $\mathbb N$ with mean $\mu$ has entropy $\le\log_2(\mu+1)+\log_2e$ (the geometric law maximises it). So $H(g_n)\le\log_2(n/2+3/2)+\log_2e$.
Combine with Prop 3.4(1). $\square$

### 3.5 The exact law, and optimality among order-free predictors

**Proposition 3.7** **[proved; computed: e1(a), e1(b)]**. Let $D$ be a possible value of $D_n$ ($n\ge1$), $H$ its number of 1-labels, $S=\mathrm{dom}\,D$, $M=\max S+1$, $g=\min(\mathbb N\setminus S)$, and $r=2/3$ if the label at $\max S$ is 1, $r=1/3$ if it is 0.
1. $\Pr[D_n=D]=\binom nH(2/9)^n\,r^{M-n}$.
2. Given $\mathrm{dom}\,D_n=S$, the labelling has law $\Pr[D\mid S]=\binom nHr^{M-n}/Z(S)$ with $Z(S)=\big((2/3)^{M-n}+(1/3)^{M-n}\big)\binom{n+g}g$ if $g<M$ and $Z(S)=\binom{2n}n$ if $S=[0,n)$.
3. For every weak function semimeasure $\nu$ (any order-free predictor, computable or not): $\mathbb E[-\log_2\nu(D_n)]\ge\mathbb E\,UB_n-\log_2n-O(1)=\tfrac{h(1/3)}2n-\log_2n-O(1)$.

*Proof.* 1. $D_n=D$ requires that the coins $\zeta_1,\dots,\zeta_n$ contain exactly $H$ ones (probability $\binom nH(2/3)^H(1/3)^{n-H}$, independent of $b$), and that the revealed heads and tails are the first $H$ heads and first $T=n-H$ tails of $b$. By Lemma 3.1 the second event fixes $b$ on $[0,M)$: the revealed indices carry their labels, and each of the $M-n$ unrevealed indices below $M$ is a tail if the top revealed index is a head (it lies below $\eta$) and a head otherwise. So it has probability $(1/3)^H(2/3)^T\,r'^{\,M-n}$ with $r'=2/3$ or $1/3$ accordingly. Multiplying, $(2/3)^H(1/3)^T(1/3)^H(2/3)^T=(2/9)^n$, and $r'=r$.
2. All labellings with domain $S$ share $n$ and $M$. Suppose $g<M$. A labelling with top label 1 is determined by its tail frontier $\tau'\in[0,g]$: labels on $[0,\tau'-1)$ arbitrary, label 0 at $\tau'-1$ (if $\tau'\ge1$), label 1 on $S\setminus[0,\tau')$. Summing $\binom nH$ over those with frontier $\tau'$ gives $\sum_j\binom{\tau'-1}j\binom n{\tau'-j}=\binom{n+\tau'-1}{\tau'}$ (Vandermonde), and $\sum_{\tau'=0}^g\binom{n-1+\tau'}{\tau'}=\binom{n+g}g$ (hockey stick). Top label 0 is symmetric. If $S=[0,n)$, every labelling of $[0,n)$ is possible with $M-n=0$, and $\sum_H\binom nH^2=\binom{2n}n$.
3. Weak semimeasures are monotone ([foundations] Def 2.1, consequence (a)), so $\nu(D_n)\le\nu(D_n|_{[0,g_n)})$. For each $g$, $\sum_l\nu(l)\le1$ over the labellings $l$ of $[0,g)$ (consequence (b)), so Gibbs' inequality, applied conditionally on $g_n=g$, gives $\mathbb E[-\log\nu(D_n|_{[0,g_n)})]\ge H(b_{<g_n}\mid g_n)$. The rest of the lower-bound part of the proof of Theorem 3.6 applies verbatim. $\square$

Part 2 says the conditional law of the labels given the domain depends on the labelling only through the number of heads. Its surprisal $-\log_2\Pr[D_n\mid S_n]\approx\log_2\binom{n+g_n}{g_n}-\log_2\binom n{T_n}$ is what Lemma 1.2 compares $K(D_n\mid S_n)$ with. Computed (e2, column BayesX): its mean is $0.4597n$ at $n=3000$ and $10^4$, and it differs from $UB_n$ by $-0.3$ to $-0.6$ bits on average and by at most $8.7$ bits in any of 1040 runs.

By Theorem 3.6 and Prop 3.7(3), SFI is optimal among all order-free predictors up to $O(\log n)$ in expectation. The gap to SI below is a property of order-free prediction, as in H5.

### 3.6 Hänni's email claim

The claim: "log loss in your solomonoff function induction coinflip question is the loss given by our threshold function, up to o(n) terms." **Verdict: correct, and true up to $O(\log n)$** (Theorem 3.3), with the threshold placed at the tail frontier $\tau_n$.

His sketch, checked step by step.
* *Easy direction.* "SFI's loss is at most the threshold function's, up to a log n term for specifying the threshold, because this guy lives inside the Solomonoff distribution." Correct: Prop 3.2, with $K(\tau_n)\le\log n+2\log\log n+c$.
* *Other direction.* "If $L_S<0.999L_T$, then SFI's loss on the initial mixed segment is even lower; then one can specify the coinflip sequence with only that many bits (pointing trick); this contradicts incompressibility at $h(1/3)$ per bit." Correct in substance. The precise version (Theorem 3.3):
  * "Even lower" is monotonicity (F2) applied to the initial segment $[0,g_n)$, which is entirely revealed.
  * The "pointing trick" is the coding theorem conditional on the domain (Lemma 1.1). Unconditionally one pays $K(g_n)=O(\log n)$ to specify the segment.
  * Incompressibility must be measured by the empirical surprisal $-\log_2P_{1/3}(b_{<\tau_n})$, via Levin–Schnorr (F4) pathwise or Lemma 1.2 in probability. Measuring it by $\tau_nh(1/3)$, as the sketch does, gives only $\pm O(\sqrt n)$, because $UB_n-\tau_nh(1/3)=-(T_n-\tfrac23\tau_n)$ fluctuates by $\Theta(\sqrt n)$. That is enough for $o(n)$ but not for $O(\log n)$.
* *Numbers.* $\mathbb E\,L_{\rm SFI}(D_n)=0.459148\,n+O(\log n)$, with fluctuations of order $1.02\sqrt n$; the brief's $\approx0.459n$ is right. The i.i.d. Bern(1/3) hypothesis pays $\mathbb E[H_n\log_23+T_n\log_2\tfrac32]=(\log_23-\tfrac13)n=1.2516n$; the i.i.d. Laplace mixture pays about $0.92n$ (e2), because the revealed labels are 2/3 heads.

### 3.7 The Bayes history-aware predictor

**Lemma 3.8 ($P^*$)** **[proved; computed: e1(c)]**. Let $h$ be a history after $t-1$ steps, with frontiers $\tau,\eta$, $F=\max(\tau,\eta)$, smallest unrevealed index $g$, and let $x$ be the next input. Call $h$ *touching* if $g=F$, i.e. the revealed set is the initial segment $[0,F)$. The true conditional probability that the label of $x$ is 1 is
* $0$ if $x<\eta$; $1$ if $x<\tau$ (exactly one of these holds when $x<F$);
* if $x\ge F$ and $h$ is not touching: $1$ if $\tau\le\eta$, and $0$ if $\eta<\tau$;
* if $x\ge F$ and $h$ is touching, with $d=x-F$: $2^d/(2^d+1)$.

Call this $P^*(1\mid h,x)$. It is computable, and its loss is positive only at touching steps.

*Proof.* The first case is Lemma 3.1. Suppose $x\ge F$. If $\tau\le\eta$ and $h$ is not touching, there is an unrevealed index in $[\tau,\eta)$; the first one is the first tail at or after $\tau$, so a tail reveal would give an input $<\eta\le x$; hence the reveal was a head. The case $\eta<\tau$ is symmetric. If $h$ is touching, the history depends only on $\zeta_1,\dots,\zeta_{t-1}$ and $b_{<F}$, so $\zeta_t$ and $b_{\ge F}$ are still independent with their prior laws. A head reveal at $x=F+d$ has probability $\tfrac23\cdot(\tfrac23)^d\tfrac13$ (the coin, $d$ tails, a head); a tail reveal there has probability $\tfrac13(\tfrac13)^d\tfrac23$. The ratio is $2^d$. $\square$

The script e1(c) compares $P^*$ with the brute-force conditional on every reachable (history, input) pair for $n\le5$ (14178 pairs): the maximum difference is 0.

**Proposition 3.9 (the burn-in)** **[proved; computed: e1(e)]**. Let $N_{\rm touch}$ be the number of touching steps over the whole infinite run (step 1 is always touching). Then $\Pr[N_{\rm touch}=j]=(2/3)^{j-1}(1/3)$, so $\mathbb EN_{\rm touch}=3$. Each touching step costs $P^*$ an expected
$$\kappa=\sum_{d\ge0}\tfrac29\Big[(\tfrac23)^d\log_2(1+2^{-d})+(\tfrac13)^d\log_2(1+2^d)\Big]=0.7995167\ \text{bits},$$
and $\mathbb E\,L_{P^*}(n)\le\mathbb E\,L_{P^*}(\infty)=3\kappa=2.3985502$ bits. $L_{P^*}(\infty)<\infty$ almost surely.

*Proof.* Track the *state* after each step: touching; $(A,U)$, heads ahead with $U\ge1$ unrevealed tails in $[\tau,\eta)$; or $(B,U)$, heads behind with $U\ge1$ unrevealed heads in $[\eta,\tau)$. Indices $\ge F$ are fresh. The transitions are:
* From touching: a head reveal skips $d$ tails with probability $\tfrac23(\tfrac23)^d\tfrac13$, giving $(A,d)$, or touching if $d=0$; a tail reveal skips $d$ heads with probability $\tfrac13(\tfrac13)^d\tfrac23$, giving $(B,d)$, or touching if $d=0$.
* From $(A,U)$: a tail reveal (probability $1/3$) gives $U-1$; a head reveal (probability $2/3$) gives $U+j$ with $\Pr[j]=\tfrac13(\tfrac23)^j$. Reaching $U=0$ means touching.
* From $(B,U)$: a head reveal (probability $2/3$) gives $U-1$; a tail reveal gives $U+j$ with $\Pr[j]=\tfrac23(\tfrac13)^j$.

The $A$-walk moves down by exactly one and has drift $-\tfrac13+\tfrac23\cdot2=1>0$. Let $\varphi$ be the probability of ever going one level down. By the strong Markov property, descending $j+1$ levels has probability $\varphi^{j+1}$, so first-step analysis gives $\varphi=\tfrac13+\tfrac23\sum_j\tfrac13(\tfrac23)^j\varphi^{j+1}=\tfrac13+\tfrac{2\varphi}{3(3-2\varphi)}$, i.e. $2\varphi^2-3\varphi+1=0$, with roots $1/2$ and $1$. If $\varphi=1$, the walk would reach every lower level almost surely, contradicting its convergence to $+\infty$ (strong law). So $\varphi=1/2$, and from $(A,d)$ the walk returns to touching with probability $2^{-d}$. The $B$-walk has drift $-\tfrac23+\tfrac13\cdot\tfrac12=-\tfrac12<0$ and returns almost surely. The return probability from touching is
$$\tfrac29+\tfrac29+\sum_{d\ge1}\tfrac29(\tfrac23)^d2^{-d}+\sum_{d\ge1}\tfrac29(\tfrac13)^d=\tfrac49+\tfrac19+\tfrac19=\tfrac23 .$$
After each touching step the future is a fresh copy of the process from a touching state (the revealed initial segment plays no role), so $N_{\rm touch}$ is geometric. $\kappa$ is the expected $P^*$ loss of a touching step, by Lemma 3.8 and the probabilities in its proof. Given a touching history, the step's loss has conditional mean $\kappa$, so $\mathbb E\,L_{P^*}(n)=\kappa\,\mathbb EN_{\rm touch}(n)\le3\kappa$. $\square$

Computed (e1(e)): the return probability evaluates to $0.666666666667$; a simulated $A$-walk descends with frequency $0.5008$ (20000 runs); over 2000 simulated runs of length 200, $\mathbb EN_{\rm touch}=2.93\pm0.05$ and $\mathbb E\,L_{P^*}=2.34\pm0.06$, and the distribution of $N_{\rm touch}$ matches Geometric(1/3).

**Theorem 3.10 (SFI$^{\rm hist}$ and SI)** **[proved]**.
1. *SFI$^{\rm hist}$.* For every $b$, every coin sequence and every $n$: $L_{\rm hist}(n)\le L_{P^*}(n)+c$. Hence $\mathbb E\,L_{\rm hist}(n)\le3\kappa+c$ for all $n$, and $\sup_nL_{\rm hist}(n)<\infty$ almost surely.
2. *SI.* Encode the history as $\bar x_1y_1\bar x_2y_2\cdots$ with a prefix-free code for indices and one bit per label. Then $\mathbb E\,L^y_M(n)\le3\kappa+c$ for all $n$, and $\Pr[\exists n:L^y_M(n)>L_{P^*}(n)+c+m]\le2^{-m}$. So SI's total label loss over the infinite run is finite almost surely, and at most $L_{P^*}(\infty)+c+m$ with probability $\ge1-2^{-m}$.

*Proof.* 1. $P^*$ is computable and gives positive probability to every realised label; apply (F7). 2. The true process $\mu$ is a computable law on the interleaved sequence, with all conditional probabilities rational, so $M\ge2^{-K(\mu)-c}\mu$ with $K(\mu)=O(1)$ (F8). Its label conditionals are $P^*$. Apply Lemma 1.3 and Prop 3.9. $\square$

**Corollary 3.11 (the brief's rule)** **[proved]**. In a state $(A,U)$, the rule "the new input is a tail iff it equals the smallest unrevealed index $g$" is exact. Almost surely there is a last touching step (Prop 3.9), and after it the process moves to some $(A,d)$ and stays in $A$-states forever ($B$-excursions return surely, so the last exit cannot be into $B$). From then on the rule never errs. Before that it can err, at touching steps and in $B$-states: this is the burn-in, whose expected cost to the Bayes predictor is $3\kappa$. *Proof.* Lemma 3.8 and the proof of Prop 3.9. $\square$

### 3.8 Numbers

**Monte Carlo** **[computed: e2, seed 20261011]**. Means over runs; losses in bits. SFIproxy is the exact order-free Bayes mixture of the i.i.d. Laplace law and the two threshold families (Bern($\theta$) with Laplace $\theta$ below $s$, constant 1 or constant 0 from $s$ on, $s\sim1/((s+1)(s+2))$), weight 1/3 per family (code: `sfi_examples.threshold_mixture_loss`). BayesX is $-\log_2\Pr[D_n\mid S_n]$ (Prop 3.7(2)). SIproxy is the label loss of a Bayes mixture of three joint models (true process; true inputs with Laplace labels; a null model), weight 1/3 each.

| $n$ | runs | SFIproxy$/n$ | $UB_n/n$ | BayesX$/n$ | iid(1/3)$/n$ | sd$(UB_n)/\sqrt n$ | SFIproxy$-UB_n$ mean [min, max] | $P^*$ | SIproxy | touching steps |
|---|---|---|---|---|---|---|---|---|---|---|
| 100 | 400 | 0.5785 | 0.4498 | 0.4548 | 1.2532 | 0.989 | 12.9 [6.8, 15.5] | 2.18 | 3.32 | 2.83 |
| 300 | 300 | 0.5157 | 0.4598 | 0.4617 | 1.2516 | 1.053 | 16.8 [11.3, 19.1] | 2.47 | 3.59 | 3.06 |
| 1000 | 200 | 0.4840 | 0.4630 | 0.4636 | 1.2502 | 1.113 | 21.0 [15.7, 23.2] | 2.30 | 3.43 | 2.88 |
| 3000 | 100 | 0.4682 | 0.4597 | 0.4599 | 1.2517 | 1.042 | 25.3 [20.9, 27.1] | 2.32 | 3.43 | 3.01 |
| 10000 | 40 | 0.4627 | 0.4597 | 0.4597 | 1.2510 | 1.113 | 29.4 [26.2, 31.1] | 2.17 | 3.29 | 2.85 |

Theory: $UB_n/n\to0.4591$, $\sigma=1.0245$, iid(1/3) $\to1.2516$, $P^*\to2.3986$, touching $\to3$. The standard error of $UB_n/n$ is $0.005$ at $n=100$ and $0.0018$ at $n=10^4$, so the means agree with $0.4591$ within two standard errors.

* SFIproxy $-\,UB_n$ grows like $2.5\log_2n$: about $2\log_2\tau_n$ for the threshold prior, $\tfrac12\log_2\tau_n$ for the unknown bias, and $\log_23$ for the family weight. This is the $O(\log n)$ of Prop 3.2 in a concrete mixture.
* SIproxy $-\,P^*$ is $1.12$ on average and at most $2.42$ over all runs; Lemma 1.3 bounds it by $\log_23+m$ with probability $\ge1-2^{-m}$.
* $P^*$'s loss is heavy-tailed: a tail revealed far beyond $F$ at a touching step costs $\log_2(1+2^d)\approx d$ bits; the largest total in 1040 runs was 20.6 bits.
* The brief's literal rule "tail iff the input equals the smallest unrevealed index" (1000 runs of length 1000, seed 20261012): 1.98 errors per run on average, at most 35; no error at all in 48.8% of runs; the last error occurred at step 4 (median over runs with an error), at step $\le30$ in 99% of them, and never after step 42. This is the burn-in of Cor 3.11.
* One run of length $2\cdot10^4$ (seed 7): SFIproxy$/t$ is $1.25,0.70,0.46,0.48,0.47$ at $t=10,100,10^3,10^4,2\cdot10^4$, while $P^*$ and SIproxy stay at $2.76$ and $3.90$ bits from $t=10$ on. Shuffling the reveal order leaves SFIproxy unchanged ($9309.577698$ bits both ways).

---

## 4. Positive examples

**Proposition 4.1 (deterministic targets)** **[proved]**. Let $f$ be partial computable and $(x_t)$ any sequence of inputs in $\mathrm{dom}\,f$ (adversarial, adaptive, or uncomputable; repetitions allowed). Then for every $n$:
1. $L_{\rm SFI}(D_n)\le K(f)+c$, whatever the order;
2. the number of steps $t\le n$ at which SFI's predictive probability of $f(x_t)$ is $\le1/2$ is at most $K(f)+c$, in the raw convention and in the normalised one.

*Proof.* 1. (F1) with the deterministic machine for $f$. 2. Each such step contributes at least 1 bit to $\sum_t-\log_2[M_F(D_t)/M_F(D_{t-1})]=L_{\rm SFI}(D_n)$. The normalised conditional is at least the raw one. $\square$

This is the deterministic case of [context] Thm 2.7, which also bounds the sum of error probabilities. The examples below give explicit $K(f)$ bounds and, where possible, matching lower bounds for every learner.

**Example 4.2 (sparse parity)** **[proved; computed: e4(a)]**. For $S\subseteq\{0,\dots,d-1\}$ with $|S|=k$, let $\chi_S(x)=\bigoplus_{i\in S}x_i$ on bit strings (positions beyond $|x|$ read as 0).
* *Upper.* $K(\chi_S)\le K(S)+c\le\log_2\binom dk+K(d)+K(k)+c$ (enumerative code given $d,k$). So $L_{\rm SFI}\le\log_2\binom dk+K(d)+K(k)+c$ on every input sequence.
* *Lower, for every learner.* Let $S$ be uniform among $k$-subsets and the inputs any fixed sequence whose labels determine $S$ (e.g. containing $e_0,\dots,e_{d-1}$). Every predictor, history-aware or not, issues sub-probabilities over label sequences given the inputs, so its expected loss is $\ge H(S)=\log_2\binom dk$ (F6).

So SFI is optimal here up to $K(d)+K(k)+c=O(\log d)$. Computed on a proxy with prior $2^{-(|S|+1)}/\binom d{|S|}$ for $|S|\le4$, $d=16$, $k=3$ (200 random targets per row; random inputs):

| $m$ examples | mean loss | max loss | mean / max steps with $P(\text{correct})\le1/2$ | $P(S^*\mid D)$ |
|---|---|---|---|---|
| 4 | 4.81 | 6.89 | 1.99 / 4 | 0.004 |
| 8 | 9.93 | 11.87 | 4.02 / 8 | 0.140 |
| 16 | 13.11 | 13.12 | 5.07 / 8 | 0.989 |
| 24 | 13.13 | 13.13 | 5.04 / 9 | 1.000 |
| 64 | 13.13 | 13.13 | 4.95 / 9 | 1.000 |

The loss saturates at $-\log_2w(S^*)=13.13$ bits ($=\log_2\binom{16}3+4$, the 4 bits paying for $|S|$), and the shuffled order gives the same loss to machine precision. In the unit-vector order the loss rises by about 4 bits exactly at the three coordinates in $S^*$ and by $\le0.2$ bits elsewhere.

**Example 4.3 (threshold)** **[proved; computed: e4(b)]**. $f_\theta(x)=[x\ge\theta]$ on $\mathbb N$. $L_{\rm SFI}(D)\le-\log_2\sum_{\theta'\text{ consistent with }D}2^{-K(\theta')}+c\le K(\theta)+c$. Lower bound for every learner: for $\theta$ uniform on $[0,2^j)$ and the $j$ bisection queries, the labels determine $\theta$, so the expected loss is $\ge j$ (the queries are adaptive, but the probabilities a predictor assigns to the $2^j$ possible label sequences still sum to at most 1); SFI pays $\le j+K(j)+c$. On a proxy with prior $2^{-(2\lfloor\log_2(\theta+1)\rfloor+1)}$, the bisection inputs cost exactly $-\log_2w(\theta^*)$ (5, 19, 33, 39 bits for $\theta^*=5,10^3,123456,10^6$), while 20 random inputs cost 0 to 22 bits, the same for random and sorted order.

**Example 4.4 (sorting)** **[proved]**. With a fixed encoding of finite lists, $f_{\rm sort}$ has $K=O(1)$. So SFI's total loss over any number of (list, sorted list) examples, of any lengths, in any order, is at most a constant depending only on the universal machine and the encoding; and so is the number of steps where the correct sorted list gets probability $\le1/2$.

**Example 4.5 (integer polynomials)** **[proved]**. $p(x)=\sum_{i\le d}a_ix^i$, $a_i\in\mathbb Z$: $K(p)\le\sum_iK(a_i)+O(d)$ by subadditivity. Lower bound for every learner: if $(a_0,\dots,a_d)$ is uniform on $\{0,\dots,A-1\}^{d+1}$ and the inputs include $d+1$ distinct points, the labels determine $p$, so the expected loss is $\ge(d+1)\log_2A$; SFI pays $\le(d+1)(\log_2A+2\log_2\log_2A)+O(d)$.

**Proposition 4.6 (frozen label noise)** **[proved; computed: e4(c)]**. Let $g:X\to\{0,1\}$ be partial computable and let the labels be $y_x=g(x)\oplus\xi_x$, with $\xi_x$ i.i.d. Bern($\varepsilon$), drawn once per input ("frozen" noise, so a repeated input repeats its label). For every sequence of inputs in $\mathrm{dom}\,g$, chosen independently of the noise, with $n$ distinct inputs and $e_n$ flipped labels among them:
$$L_{\rm SFI}(D_n)\le\log_2\binom n{e_n}+\log_2(n+1)+K(g)+c,$$
hence $nh(\varepsilon)\le\mathbb E\,L_{\rm SFI}(D_n)\le nh(\varepsilon)+\log_2(n+1)+K(g)+c$, and the lower bound $nh(\varepsilon)$ holds for every learner.

*Proof.* Let $T_g$ read a uniform real $\varepsilon'$ lazily from a shared part of the tape and, for each input $x$, a private uniform real $u_x$; output $g(x)\oplus[u_x<\varepsilon']$, comparing bits until they differ (finitely many with probability 1). Its law is the Laplace mixture $\nu_g(D)=\int_0^1\varepsilon'^{\,e}(1-\varepsilon')^{|D|-e}d\varepsilon'=1/((|D|+1)\binom{|D|}e)$, $e$ = number of disagreements with $g$; and $K(\nu_g)\le K(g)+c$. Apply (F1). For the expectation use $\log_2\binom ne\le nh(e/n)$ and concavity of $h$. Lower bound: given the inputs and $g$, the labels have entropy $nh(\varepsilon)$, and every predictor's loss is $-\log$ of a sub-probability over label sequences (F6). $\square$

With non-frozen noise a repeated input can get a different label, and SFI's loss is infinite ([foundations] Prop 6.8). Computed on a proxy ($d=12$, $|S^*|=3$, $\varepsilon=0.1$; parities $|S|\le3$ with Laplace flip rate; 100 runs per row): the regret against the noise-aware oracle is $14.9,15.8,16.5,17.3$ bits at $n=100,400,1600,3200$, close to $-\log_2w(S^*)+\tfrac12\log_2n$ ($15.0,16.0,17.0,17.5$), and the mixture loss is below the bound of Prop 4.6 in every run (up to $10^{-11}$ rounding). The posterior on $S^*$ is $0.53$ at $n=25$ and $1.000$ from $n=100$.

---

## 5. Hänni's OOD examples

The general OOD results are in the context track; I use them and do not re-prove them.
* [context] Prop 2.1: if a decidable property $Q$ contains no training input, then for every partial computable $b$ the posterior probability that SFI behaves like $b$ on all of $Q$ is $\ge2^{-K(Q,b)-c}$, however large the training set.
* [context] Prop 2.3: the same with $Q,b$ simple relative to a program $p$ consistent with the data, times the posterior of $p$.
* [context] Thm 2.5 and Prop 2.4: the two-sided bound, and the machine dependence (a universal machine $U'$, at most $K(Q,b)+c$ bits from $U$, gives probability $\ge1/2$ to $b$ on $Q$).
* [context] Thm 2.7: the total error over any input sequence is $\le K(f)+c$ (Prop 4.1 above).

**Proposition 5.1 (the intended answer)** **[proved]**. If the labels follow a partial computable $g$ and $x\in\mathrm{dom}\,g$ is any new input, SFI's predictive probability of $g(x)$ is at least $2^{L_{\rm SFI}(D)-K(g)-c}$.

*Proof.* $M_F(D+(x,g(x)))\ge2^{-K(g)-c}$ by (F1), and divide by $M_F(D)=2^{-L_{\rm SFI}(D)}$. $\square$

The bound is near 1 only if $L_{\rm SFI}(D)\approx K(g)$, i.e. if $g$-like programs carry most of the posterior.

### 5.1 Proof/disproof labels

Setting (Hänni): sentences of a consistent recursively axiomatised theory $T$, labelled 1 if proved and 0 if refuted, training only on resolved sentences.
* **Proved.** The proof-search program (enumerate proofs; output 1 or 0 when one is found) has length $K(T)+c$ and is consistent with every correctly labelled training set. So $L_{\rm SFI}(D)\le K(T)+c$, and by Prop 5.1 a new decidable sentence gets its correct label with probability $\ge2^{L_{\rm SFI}(D)-K(T)-c}$. Over any sequence of sentences revealed online, SFI errs (probability $\le1/2$) at most $K(T)+c$ times in total.
* **Proved (an upper limit).** If every training sentence has a proof or refutation of length $\le L$ and the test sentence (say the Riemann hypothesis, if decidable) has none of length $\le L'=2^{\lceil\log_2L\rceil}$, the wrong label has probability $\ge2^{-K(T)-2\log_2\log_2L-c}$ ([context] Ex 2.15). Relative to the proof-search program $p$, the bound is much stronger. Let $p'$ run $p$'s search up to length $L'$, output its answer if it finds one, and otherwise output the label that is wrong at the test sentence (a constant). Then $|p'|\le|p|+K(L')+c$, $p'$ is consistent with the training data, so the wrong label has probability $\ge2^{-K(L')-c}\cdot2^{-|p|}/M_F(D)$: at least $2^{-K(L')-c}\ge2^{-c'}/(\log_2L\,(\log_2\log_2L)^2)$ times the posterior weight of the proof-search program (the wrapper argument of [context] Prop 2.3).
* **Plausible, not proved.** That the correct label gets probability close to 1. This needs the posterior to concentrate on unbounded proof search rather than on its truncations. The bounds above do not decide this, and by [context] Prop 2.4 the answer depends on the universal machine. **[conjecture]** for natural machines and large natural training sets; no proof is known to me.

### 5.2 Shortest proofs as labels

Setting: each sentence labelled by its shortest proof (in a fixed enumeration order). The intended program (search proofs by length) has $K=K(T)+c$, so Prop 4.1 and Prop 5.1 apply as above: at most $K(T)+c$ online errors, and the intended output on a new provable sentence has probability $\ge2^{L_{\rm SFI}(D)-K(T)-c}$. The upper limit is [context] Thm 2.5(3) with the separating property "no proof of length $\le L'$": if the test sentence's shortest proof is longer than $L'$ and all training proofs are shorter, any simple wrong output $z$ (e.g. the empty string) has probability $\ge2^{-K(T)-K(L')-K(z\mid x)-c}$, independently of the number of training sentences. Whether RH would get its shortest proof with high probability is, as in §5.1, plausible and machine-dependent **[conjecture]**.

### 5.3 Lengths of odd strings

Setting: training pairs $(x,|x|)$ for strings of odd length; test on even lengths. Hänni: "plausibly we will generalize correctly to all strings".
* **Proved.** $K(|\cdot|)=O(1)$, so the correct answer has probability $\ge2^{-c}$ on every even-length input, and SFI makes at most $c$ online errors over any sequence. "$|x|$ is even" and "output 0" are $O(1)$ bits, so a wrong answer has probability $\ge2^{-c'}$ on every even-length input, however many odd-length strings were seen ([context] Ex 2.15). Both constants depend on the machine.
* **Computed (e5).** An exact Bayes mixture over an enumerated grammar (code `sfi_dsl.py`): programs are an arithmetic expression $E$ of depth $\le2$ over $\{|x|,\#_1(x),\#_0(x),0,1,2\}$ with $+,-,\times$, or `if C then E else E` with 80 simple conditions (even($\cdot$), $<$, $=$ on leaves, first/last bit). Prior $p_{\rm plain}$ on plain programs, $1-p_{\rm plain}$ on `if` programs, grammar weights below. Training: all 170 strings of length 1, 3, 5, 7. Test: all 340 strings of length 2, 4, 6, 8. Only one plain value class ("len") fits the training data.

| prior | $P(\text{correct})$ at length 2 / 4 / 6 / 8 | $P(\text{label }0)$ at length 8 | min over test strings |
|---|---|---|---|
| $p_{\rm plain}=0.5$ | 0.9824 / 0.9835 / 0.9834 / 0.9834 | $3.3\cdot10^{-3}$ | 0.9790 |
| $p_{\rm plain}=0.9$ | 0.9975 / 0.9977 / 0.9977 / 0.9977 | $4.6\cdot10^{-4}$ | 0.9971 |
| $p_{\rm plain}=0.99$ | 0.99977 / 0.99978 / 0.99978 / 0.99978 | $4.3\cdot10^{-5}$ | 0.99972 |
| tilted ×1 (one extra program "if even(len) then 0 else len" with the mass of all plain programs) | 0.557 / 0.557 / 0.557 / 0.557 | 0.435 | 0.555 |
| tilted ×10 | 0.114 / 0.114 / 0.114 / 0.114 | 0.885 | 0.113 |

Online, with $p_{\rm plain}=0.5$: after all length-2 strings are revealed, $P(\text{wrong})$ at lengths 4–8 drops to $2.7\cdot10^{-3}$; after length 4, to $1.5\cdot10^{-8}$; after length 6, to 0 within the class. A single revealed string ("00", 2) leaves $P(\text{wrong})\approx6.7\cdot10^{-3}$, because programs like "if even(len) then 2 else len" survive it.

* **Reading.** On a natural-looking grammar the intended generalisation gets probability 0.98–0.9998, depending on a single prior weight; on a tilted grammar it gets 0.11. This is a concrete instance of [context] Prop 2.4 and of Hänni's own remark that "there's a programming language in which it doesn't have a better const". Hänni's "plausibly generalizes correctly" is a statement about the machine, not about SFI as such **[conjecture for natural machines]**. What is machine-invariant is the bounded number of errors.

### 5.4 Summary for Hänni's OOD list

| Example | Proved | Plausible only | False as an unconditional claim |
|---|---|---|---|
| Proof/disproof labels | correct label prob. $\ge2^{L(D)-K(T)-c}$; $\le K(T)+c$ online errors; wrong label prob. $\ge2^{-K(L')-c}\cdot$(posterior weight of proof search) | correct label on RH with probability near 1 | "more resolved sentences of the same difficulty make the RH label nearly certain": with the proof-length bound $L$ of the training set fixed, the wrong-label probability stays $\ge2^{-K(T)-2\log_2\log_2L-c}$ however many sentences are added ([context] Ex 2.15) |
| Shortest proofs | same form | RH labelled by its shortest proof w.h.p. | the same statement, by [context] Thm 2.5(3) |
| Odd-length counting | correct prob. $\ge2^{-c}$, wrong prob. $\ge2^{-c'}$, $\le c$ online errors | correct w.h.p. on natural machines (0.98–0.9998 in e5) | correct w.h.p. on every universal machine (0.11 on a tilted grammar, e5; [context] Prop 2.4) |

---

## 6. Code and computations

* `code/sfi_examples.py` (reusable): log-space helpers; Eisenstat's process (`simulate_eisenstat`), frontiers (`EisenstatState`), $P^*$ (`pstar_prob_one`), the true input law (`true_input_log2prob`), the threshold-mixture SFI proxy (`threshold_mixture_loss`), the exact conditional surprisal (`bayes_xonly_surprisal`), $\kappa$ (`kappa_touching`); the cyclic-permutation proxies (`cyclic_example_losses`).
* `code/sfi_dsl.py` (reusable): the enumerated program grammar of §5.3, with exact posterior predictive.
* `checks/e1_eisenstat_exact.py`: exact checks for §3 (brute-force law, $P^*$, $\mathbb E\,UB_n$, the touching chain, Lemma 3.5).
* `checks/e2_eisenstat_sim.py`: Monte Carlo table of §3.8.
* `checks/e3_cyclic.py`: constants and proxies of §2.5; exhaustive counting checks.
* `checks/e4_positive.py`: §4 examples.
* `checks/e5_dsl_odd_lengths.py`: §5.3.

The proxies are finite or explicitly parametrised Bayes mixtures. They are not SFI; they show the qualitative gaps (order-free mixtures pay $\Theta(n)$ per step or $\Theta(n)$ in total; history-aware and joint-sequence mixtures pay $O(1)$) with exact numbers.

---

## 7. Open problems from this track

1. **Normalised SFI.** In H5 and H6, is the per-step normalised SFI predictor's loss also $\Theta(\text{the semimeasure loss})$? The normalised loss equals the semimeasure loss minus the "defect" terms $\sum_t\log_2[M_F(D_{t-1})/\sum_yM_F(D_{t-1}+(x_t,y))]$, which come from hypotheses consistent with the past and undefined at $x_t$. In both examples a set-based predictor can achieve $O(1)$ (Remark 2.7; $P^*$ uses only the set of revealed pairs), so information theory alone does not decide this. **[conjecture]**: yes, in both examples; the total (threshold or cyclic-permutation) hypotheses dominate numerator and denominator alike. For the proxies of §2.5 and §3.8 the two conventions coincide, because every component is total. This is the same question as [history] Q4.
2. **SI's label loss in H5 for fixed $n$**: $O(1)$, $O(\log n)$, or $\Theta(K(n))$? (§2.4.)
3. **The $\log_2(N-1)$ slack in Thm 2.3** for $n\lesssim k\le N-1$: is $L_{\rm SFI}(D_k)=\log_2(N-1)_k+O(1)$ with high probability once $k\ge n$?
4. **OOD.** A natural-machine statement (e.g. for a fixed reference machine such as a standard prefix-free encoding of a programming language) that would make "plausibly generalises" in §5 provable for a specific training distribution. I see no route.

---

## Verification log

All scripts were run with `python3` (numpy 2.4.6, scipy 1.17.1) from `research/tracks/examples/checks/`. Outputs are saved next to the scripts.

| Script | Seed | What it checks | Result | Runtime |
|---|---|---|---|---|
| `e1_eisenstat_exact.py` | 20261011 (simulation parts) | (a) $\Pr[D_n=D]$ formula vs exhaustive enumeration, $n=3,4,5$; (b) $Z(S)$; (c) $P^*$ vs brute-force conditional on all (history, input) pairs, $t\le n\le5$; (d) $\mathbb E\,UB_n=nh/2$; (e) return probability $2/3$, $\mathbb EN_{\rm touch}=3$, $\kappa$, simulation; (f) Lemma 3.5 | (a) 252, 756, 2016 data sets, max error 0 (exact rationals); (b) 84, 210, 462 domains, max error 0; (c) 475, 2414, 11289 pairs, max error 0; (d) diff $\le2.5\cdot10^{-11}$; (e) $r=0.666666666667$, $\varphi_{\rm sim}=0.5008$, $\kappa=0.7995167363$, $3\kappa=2.3985502090$, simulated $\mathbb EN_{\rm touch}=2.925\pm0.054$ (horizon 200), $\mathbb EL_{P^*}=2.339\pm0.061$; (f) simulated probabilities below the bound | 40 s |
| `e2_eisenstat_sim.py` | 20261011; 7 and 11 for the single run; 20261012 for the rule | Table of §3.8; order independence of the proxy; errors of the brief's rule | as tabulated; shuffled order gives identical loss (9309.577698) | 78 s |
| `e3_cyclic.py` | 20261011 | Constants of Thm 2.1(4); $k$-step quantities; proxies; bijection orderings ↔ cyclic permutations and $\Pr[\pi\supseteq D_k]=1/(N-1)_k$ for $n=2,3$ | Stirling error $=1/(12N\ln2)$ to print precision for $n\le24$; counting checks pass for all $k$ | 1 s |
| `e4_positive.py` | 20261011 | Parity, threshold and frozen-noise tables of §4 | order-independence differences 0; mixture loss $\le$ Prop 4.6 bound in all 800 runs (max excess $1.3\cdot10^{-11}$, rounding) | 8 s |
| `e5_dsl_odd_lengths.py` | none (deterministic) | §5.3 table | 1345 expression classes, 80 conditions; one plain class consistent | 14 s |

**What was not checked.** The bibliographic references marked (unverified) were not checked against their sources: Levin–Schnorr, Ville, Robbins, Sattolo, Hutter 2005, Li–Vitányi section numbers. Results imported from the foundations, history and context tracks were read in their notes as of 2026-10-11 but not re-proved here; the numbering refers to those notes and may change. The CLT in Prop 3.4(3) is a proof sketch. The Monte Carlo numbers in §3.8 are estimates with the standard errors stated.

**Corrections made during the work.** The first version of `bayes_xonly_surprisal` computed $(2/3)^{M-n}$ directly and underflowed for $M-n\gtrsim1800$; it now uses $\log_2(1+2^{-(M-n)})$ (plus $M-n$ when the top label is 0). The first draft of Lemma 3.5 had the constant 19; the correct sum is $1+1/(1-e^{-1/18})=19.5$, so the lemma states 20.
