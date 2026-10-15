# Foundations track: definitions and basic theorems of Solomonoff function induction

*Track "foundations" of the SFI project. Brief items H1, H2, H7, plus invariance. Read `../../00-brief.md` first. Scripts are in `checks/`; each saves its output next to itself as `*.out.txt`.*

**Status tags.** **[proved]**: full proof here. **[computed]**: checked by a script in `checks/` with saved output. **[known]**: published result, with reference; **(unverified)** means I could not check it against the source (arxiv.org and similar do not resolve here; WebSearch gives snippets only). **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]** as usual. Hänni's statements are treated as hypotheses.

---

## 0. Summary

Answers, compressed. Section numbers point to the statements and proofs.

1. **Three candidate notions of "function semimeasure" are different, and only one of them has the generative meaning Hänni intends** (§2).
   * The brief's definition (one-point inequality $\nu(D)\ge\sum_y\nu(D\cup\{(x,y)\})$) gives what I call a *weak* function semimeasure. Weak semimeasures are exactly the order-independent online predictors. They need not come from any random function: $\nu(\{(a,0)\})=\nu(\{(b,0)\})=1$, $\nu(\{(a,0),(b,0)\})=0$ is weak (Example 2.4).
   * The laws of random partial functions are characterised by a Möbius (complete monotonicity) condition (Prop 2.3) **[proved]**.
   * Function machines $\omega\mapsto f_\omega$ (value at $x$ fixed by a finite prefix of the shared random tape $\omega$) give lower-semicomputable laws of random partial functions (Prop 2.6) **[proved]**.
2. **Universality** (§3).
   * There is a universal function machine. Its law $M_F$ satisfies $M_F(D)=\sum_i m(i)\,\nu_{T_i}(D)$ for $D\neq\emptyset$, hence $M_F\ge 2^{-K(\nu)}\nu$ for every machine law $\nu$ (Thm 3.2) **[proved]**.
   * Machine laws include all lower-semicomputable product laws (Hänni's x-only samplers), all partial computable functions, all computable laws with finite label set, and lsc mixtures of these (Prop 3.3) **[proved]**.
   * A universal *weak* semimeasure $M^w$ also exists (Thm 3.4) **[proved]**. But it is **not** equivalent to $M_F$ up to a constant: the ratio $M^w/M_F$ is at most $2^{K(\mathrm{dom}\,D)+O(1)}$, and it can be at least $2^{k\log_2(3/2)-K(k)-O(1)}$ on data sets with $2k$ points (Thm 3.5) **[proved; the per-block constant 2/3 is exact for k ≤ 3, computed: c1]**. So the brief's H1(a) "or equivalently monotone function machines" is **refuted** for the weak definition.
   * Whether every lower-semicomputable law of a random partial function is dominated by $M_F$ up to a constant is **[open]** (Problem 3.6).
3. **Program mixture, Kolmogorov version, product mixture** (§4). With $W(D)=\sum_{p:\varphi_p\supseteq D}2^{-|p|}$ (deterministic programs), $K_F(D)=\min\{|p|:\varphi_p\supseteq D\}$, and $M_{\rm prod}$ the universal mixture of product laws (Solomonoff's operator induction, as I formalise it):
   * $2^{-K_F}\le W\lesssim M_{\rm prod}\lesssim M_F\lesssim M^w\le 2^{K(\mathrm{dom}\,D)+O(1)}\,2^{-K_F}$ (Thm 4.2) **[proved]**. All five agree up to $K(\mathrm{dom}\,D)+O(1)$ bits.
   * $M_{\rm prod}/W$ is unbounded already on two-point data sets (a Ramsey argument, Prop 4.3) **[proved]**. For fair-coin labels the gap is at most $K(n,|D|)+O(1)$ bits for inputs of length at most $n$, by $|D|$-wise independent hashing (Prop 4.4) **[proved; hashing computed: c2]**.
   * $M_F/M_{\rm prod}$ is unbounded: shared randomness cannot be simulated by a countable mixture of private-randomness laws (Prop 4.5) **[proved]**.
   * So the "Kolmogorov version" and the "universal semimeasure version" in Hänni's draft (§2.2, "need coding theorem") are **not equivalent up to a constant**. The coding theorem gives the $K(\mathrm{dom}\,D)$ bound, and no better general bound is established. Whether $-\log W=K_F+O(1)$ is **[open]**.
4. **Which object to call SFI** (§5). I recommend $M_F$, the law of the universal function machine on a uniformly random tape. Reasons: it is a random function (Hänni's "pick a random program and generate using it", with a random tape), it has a posterior over functions, it dominates every machine law with constant $2^{-K(\nu)}$, and it is invariant. Loss is $-\log_2 M_F(D_n)$ in the semimeasure convention; it depends only on the set $D_n$ (Prop 5.2) **[proved]**. Normalising each prediction lowers the loss but makes it order-dependent (Prop 5.3) **[proved; computed: c3]**.
5. **Basic theorems** (§6).
   * (i) Dominance (H2), pathwise for every input sequence, adversarial or not: $-\log M_F(D_n)\le-\log\nu(D_n)+K(\nu)+O(1)$ for every machine law $\nu$ (Thm 6.1) **[proved]**. Two corrections to H2 as stated: the label sequence must be consistent (a repeated input with a different label gives SFI infinite loss), and for weak comparators the constant must be replaced by $K(\nu)+K(\mathrm{dom}\,D_n)$, which is necessary.
   * (ii) Invariance under the universal machine and under computable injective re-encodings of inputs and outputs, with constant $K(\alpha,\beta)+O(1)$ (Thm 6.2) **[proved]**. This settles Hänni's §2.1.
   * (iii) Coding-theorem bounds: $\max_{T\subseteq\mathrm{dom}\,D}K(D|_T\mid T)-O(1)\le-\log M_F(D)\le\min\{K_F(D),\sum_{(x,y)\in D}K(y\mid x)\}+O(1)$, with equality up to $O(1)$ for single points (Thm 6.3) **[proved]**. The upper bound $M_F(D)\le2^{-K(D\mid\mathrm{dom}\,D)+O(1)}$ is far from tight on some data (Example 6.4) **[proved]**.
   * (iv) Merging: for a computable random total function $\nu$ and any input-selection rule that sees only the past, $\sum_t\mathbb E\,\mathrm{KL}(\nu(\cdot\mid D_{t-1},x_t)\,\|\,M_F(\cdot\mid D_{t-1},x_t))\le K(\nu)+O(1)$ bits (Thm 6.5) **[proved; finite analogue computed: c4]**. For a deterministic computable $f$, at most $K(f)+O(1)$ prediction errors on any sequence of inputs (Cor 6.6) **[proved]**.
   * (v) H7, online-to-batch (Thm 6.7) **[proved]**: for deterministic targets and any input distribution, average log risk and 0–1 risk at most $(K(f)+O(1))/n$. **H7 as stated is refuted for noisy labels** (Prop 6.8) **[proved; computed: c5]**: with i.i.d. pairs and non-deterministic labels some input eventually repeats with a different label, and SFI's loss is infinite. Two repairs give the bound $(K(P)+O(1))/n$ (or the resolvability bound $\min_\nu[K(\nu)/n+\mathbb E\,\mathrm{KL}(P\|\nu)]$ for non-computable $P$): frozen noise (labels drawn once per input), or time-stamped inputs.
6. **Other foundational points** (§7).
   * Solomonoff's sequence induction is SFI restricted to data whose domain is an initial segment of $\mathbb N$: $M_F(\{(i,x_i):i<n\})=M(x_{1:n})\cdot 2^{\pm O(1)}$ (Prop 7.1) **[proved]**.
   * SFI is dominated by Hutter's universal chronological semimeasure (history-aware universal prediction), up to a constant (Prop 7.2) **[proved, given the known existence of that semimeasure]**. The universal element of the order-free chronological semimeasures is $M^w$, not $M_F$.
   * $M_F$ is lower semicomputable and not computable, and its predictive conditionals (raw or normalised) are not computable (Prop 7.3) **[proved]**.

---

## 1. Setting and notation

* **Inputs and outputs.** $X=Y=\{0,1\}^*$, identified with $\mathbb N$ by the length-lexicographic bijection when convenient. All results below hold for any infinite decidable $X$ and any $Y$ with $|Y|\ge2$, unless a statement says otherwise. $\bot$ means "undefined", and $Y_\bot:=Y\cup\{\bot\}$.
* **Data.** A *data set* is a finite partial function $D$ from $X$ to $Y$, written as a finite set of pairs with distinct first coordinates. $\mathrm{dom}\,D$ is its domain. For $x\notin\mathrm{dom}\,D$, $D+(x,y):=D\cup\{(x,y)\}$. For $T\subseteq\mathrm{dom}\,D$, $D|_T$ is the restriction. A partial function $f$ *extends* $D$, written $f\supseteq D$, if $f(x)=y$ for all $(x,y)\in D$. A sequence $(x_t,y_t)_{t\le n}$ is *consistent* if $D_n:=\{(x_t,y_t):t\le n\}$ is a partial function (repeated inputs carry equal labels).
* **Complexity.** $V$ is a fixed universal prefix machine. $K(a)$ and $K(a\mid b)$ are prefix complexity and conditional prefix complexity. Finite sets and finite partial functions are encoded canonically (sorted lists). $m(i):=\sum_{p:V(p)=i}2^{-|p|}$. Trivially $m(i)\ge2^{-K(i)}$. The coding theorem says $m(i)=2^{-K(i)+O(1)}$ **[known: Levin 1974; Gács 1974; Chaitin 1975; Li–Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. 2008, §4.3 (unverified section number)]**. I use the conditional form: if $P(a\mid z)\ge0$ is lower semicomputable uniformly in $(a,z)$ and $\sum_aP(a\mid z)\le1$ for every $z$, then $K(a\mid z)\le-\log P(a\mid z)+K(P)+O(1)$ **[known, same reference]**.
* **Complexity of a law.** For a class with an effective enumeration $(\nu_i)$ (machine laws, weak semimeasures, conditional semimeasures), $K(\nu):=\min\{K(i):\nu_i=\nu\}$. Changing the enumeration changes $K(\nu)$ by at most an additive constant whenever each enumeration translates computably into the other.
* **Logs and losses.** $\log=\log_2$, $\ln$ is natural. Losses and KL divergences are in bits unless marked. $\lambda$ is the uniform (fair-coin) measure on $\{0,1\}^\infty$; $[w]$ is the cylinder of $\omega$'s extending the finite string $w$.

---

## 2. Three notions of function semimeasure

**Definition 2.1 (weak function semimeasure).** A map $\nu$ from data sets to $[0,1]$ with $\nu(\emptyset)\le1$ and, for every $D$ and every $x\notin\mathrm{dom}\,D$,
$$\textstyle\nu(D)\ \ge\ \sum_{y\in Y}\nu(D+(x,y)).$$
This is the definition in the brief.

*Two consequences* **[proved]**. (a) Monotonicity: $\nu(D+(x,y))\le\nu(D)$. (b) For every finite $S\subseteq X$, $\sum_{D:\,\mathrm{dom}\,D=S}\nu(D)\le\nu(\emptyset)$. For (b), list $S=\{s_1,\dots,s_k\}$ and sum out $y_k$, then $y_{k-1}$, and so on, using the inequality at each step.

*Predictor reading* **[proved]**. A weak semimeasure is the same thing as an online predictor that (i) sees the past data only as a set, (ii) issues sub-probabilities $q(\cdot\mid D,x)$ on $Y$ for a new input $x$, and (iii) is *order-independent*: the product of its conditionals along any reveal order of a data set is the same. Given such $q$, put $\nu(D):=\prod_t q(y_t\mid D_{t-1},x_t)$ along any order; (iii) makes this well defined, and $\sum_yq\le1$ gives the inequality. Conversely put $q(y\mid D,x):=\nu(D+(x,y))/\nu(D)$ (and $0$ if $\nu(D)=0$); the product telescopes to $\nu(D)/\nu(\emptyset)$, which is order-free.

**Definition 2.2 (law of a random partial function).** A *random partial function* is a random element $F$ of $(Y_\bot)^X$ (product $\sigma$-algebra, $Y_\bot$ discrete) with law $P$. Its *containment functional* is $\nu_P(D):=P(F\supseteq D)$.

Every containment functional is a weak semimeasure, because the events $\{F\supseteq D+(x,y)\}$, $y\in Y$, are disjoint subsets of $\{F\supseteq D\}$.

**Proposition 2.3 (Möbius characterisation)** **[proved]**. Let $\nu$ be a weak semimeasure with $\nu(\emptyset)=1$. Then $\nu=\nu_P$ for some law $P$ of a random partial function if and only if, for every data set $D$ and every finite $T\subseteq X\setminus\mathrm{dom}\,D$,
$$\textstyle \Delta(D,T):=\sum_{E:\ \mathrm{dom}\,E\subseteq T}(-1)^{|E|}\,\nu(D\cup E)\ \ge\ 0 .$$
$P$ is then unique, and $\Delta(D,T)=P(F\supseteq D,\ F(t)=\bot\text{ for all }t\in T)$.

*Proof.* The series converges absolutely: by consequence (b) applied below $D$, $\sum_{E:\,\mathrm{dom}\,E\subseteq T}\nu(D\cup E)\le2^{|T|}\nu(D)$.

*Necessity.* For $t\in T$ let $A_t=\{F(t)\ne\bot\}$. By inclusion–exclusion, $P(F\supseteq D,\ \bigcap_tA_t^c)=\sum_{R\subseteq T}(-1)^{|R|}P(F\supseteq D,\ \bigcap_{t\in R}A_t)$, and $P(F\supseteq D,\bigcap_{t\in R}A_t)=\sum_{E:\,\mathrm{dom}\,E=R}\nu(D\cup E)$. Collecting terms gives $\Delta(D,T)$, which is therefore a probability and $\ge0$.

*Sufficiency.* For finite $S\subseteq X$ and $v\in(Y_\bot)^S$, let $v^{\rm def}$ be the partial function given by the defined entries of $v$ and $S_\bot(v)$ the set where $v=\bot$. Put $q_S(v):=\Delta(v^{\rm def},S_\bot(v))\ge0$. Consistency: for $x\notin S$, splitting the sum defining $q_{S\cup\{x\}}(v,\bot)$ according to whether $x\in\mathrm{dom}\,E$ gives $q_{S\cup\{x\}}(v,\bot)=q_S(v)-\sum_{a\in Y}q_{S\cup\{x\}}(v,a)$. (Rearranging is allowed by absolute convergence.) So $\sum_{a\in Y_\bot}q_{S\cup\{x\}}(v,a)=q_S(v)$, and $q_\emptyset=\nu(\emptyset)=1$. The $q_S$ are a consistent family of probability distributions on the countable sets $(Y_\bot)^S$. The Kolmogorov extension theorem gives a law $P$ on $(Y_\bot)^X$ with these marginals. Then $P(F\supseteq D)=q_{\mathrm{dom}\,D}(D)=\Delta(D,\emptyset)=\nu(D)$. Uniqueness: the cylinder probabilities $q_S$ are determined by $\nu$. $\square$

*Remark.* This is the function-space analogue of the classical correspondence between completely monotone set functions and random sets (Choquet; Matheron; in finite form, Shafer's belief functions) **[known as an analogy; not checked against the sources (unverified)]**. The weak condition is the case $|T|=1$ only.

**Example 2.4 (weak but not a random function)** **[proved; computed: c1, c6]**.
* *Two inputs.* $\nu(\emptyset)=\nu(\{(a,0)\})=\nu(\{(b,0)\})=1$, all other values $0$. Every one-point inequality holds. But $\Delta(\emptyset,\{a,b\})=1-1-1+0=-1<0$: "$F(a)=0$ surely and $F(b)=0$ surely, but never both" is not the law of any random function.
* *Three inputs, $\tau$.* Inputs $a,b,c$, labels $\{0,1\}$. $\tau(\emptyset)=1$; $\tau(\{(x,y)\})=\tfrac12$ for all six singletons; $\tau(E_1)=\tau(E_2)=\tau(E_3)=\tfrac12$ for $E_1=\{(a,0),(b,1)\}$, $E_2=\{(b,0),(c,1)\}$, $E_3=\{(c,0),(a,1)\}$; all other values $0$. All 27 one-point inequalities hold (c1, part (a)). $E_1,E_2,E_3$ are pairwise inconsistent, yet $\sum_i\tau(E_i)=\tfrac32>1$. For any random partial function the events $\{F\supseteq E_i\}$ are disjoint, so $\sum_i P(F\supseteq E_i)\le1$. Hence no law $P$ satisfies $P(F\supseteq D)\ge c\,\tau(D)$ for all $D$ with $c>\tfrac23$. $c=\tfrac23$ is attained (c1, part (d), $k=1$).

**Definition 2.5 (function machine).** A *function machine* is a computably enumerable set $T\subseteq X\times\{0,1\}^*\times Y$ of triples that is *consistent*: if $(x,w,y),(x,w',y')\in T$ and $w,w'$ are comparable (one a prefix of the other), then $y=y'$. For $\omega\in\{0,1\}^\infty$ put $f^T_\omega(x):=y$ if some prefix $w$ of $\omega$ has $(x,w,y)\in T$, and $f^T_\omega(x):=\bot$ otherwise; consistency makes this well defined. The *machine law* of $T$ is the law of $f^T_\omega$ under $\omega\sim\lambda$:
$$\nu_T(D):=\lambda\{\omega:\ f^T_\omega\supseteq D\}.$$
This formalises "the value at $x$ depends on a finite prefix of a random tape $\omega$ that is shared by all inputs".

**Proposition 2.6** **[proved]**. Every machine law is the containment functional of a random partial function, with $\nu_T(\emptyset)=1$, and $D\mapsto\nu_T(D)$ is lower semicomputable uniformly in $D$ and in an index of $T$.

*Proof.* $f^T_\omega$ is a measurable function of $\omega$ into $(Y_\bot)^X$, since each coordinate is determined by countably many cylinders. $\{\omega:f_\omega(x)=y\}=\bigcup_{(x,w,y)\in T}[w]$ is an effectively open set, uniformly in $(x,y)$. A finite intersection of effectively open sets is effectively open uniformly, and the measure of an effectively open set is lower semicomputable uniformly in its description. $\square$

*Effective enumeration of function machines* **[proved]**. Let $(W_i)$ enumerate all c.e. sets of triples. Let $T_i$ be obtained by enumerating $W_i$ and adding each triple unless it conflicts with a triple already added. Each $T_i$ is consistent, and $T_i=W_i$ whenever $W_i$ is consistent. So $(T_i)$ lists all function machines (and only them), and $K(\nu)$ for machine laws is defined from this list.

---

## 3. Universality

**Lemma 3.1 (realising a lower-semicomputable tree semimeasure)** **[known: Zvonkin–Levin 1970, *Russian Math. Surveys* 25(6):83–124, for binary sequences (unverified); proof given here for countable alphabets, so: proved]**. Let $A$ be a countable alphabet with a fixed enumeration and $\mu$ a lower-semicomputable semimeasure on $A^*$: $\mu(\varepsilon)\le1$ and $\mu(s)\ge\sum_{a\in A}\mu(sa)$. There is a c.e. family of finite unions of dyadic intervals $I(s)=\bigcup_tI_t(s)\subseteq[0,1)$, computable from an index of $\mu$, with $I(sa)\subseteq I(s)$, $I(sa)\cap I(sb)=\emptyset$ for $a\ne b$, and $\lambda(I(s))=\mu(s)$ for every $s$. Consequently the map $\omega\mapsto$ "the longest $s$ with $\omega\in I(s)$" (reading $\omega$ as a binary real) is a monotone machine whose output extends $s$ with probability exactly $\mu(s)$, and the event "output extends $s$" is certified by a finite prefix of $\omega$.

*Proof.* Let $\mu_t$ be computable dyadic lower approximations, nondecreasing in $t$, with $\mu_t\to\mu$, and $\mu_t(s)=0$ unless $|s|\le t$ and $s$ uses only the first $t$ letters (round a rational approximation down to a multiple of $2^{-t}$; this preserves monotonicity in $t$). On this finite tree define $\mu'_t$ from the leaves up: $\mu'_t(s):=\max\{\mu_t(s),\ \sum_a\mu'_t(sa)\}$.
* $\mu'_t\le\mu$, by induction from the leaves: $\sum_a\mu'_t(sa)\le\sum_a\mu(sa)\le\mu(s)$.
* $\mu'_t$ is nondecreasing in $t$ (the tree grows and the inputs grow), $\mu'_t\ge\mu_t\to\mu$, so $\mu'_t\to\mu$.
* $\mu'_t(s)\ge\sum_a\mu'_t(sa)$, and $\mu'_t(\varepsilon)\le\mu(\varepsilon)\le1$.

Build $I_t$ top-down. $I_t(\varepsilon):=[0,\mu'_t(\varepsilon))$. Given $I_{t}(s)\supseteq I_{t-1}(s)$ of measure $\mu'_t(s)$, the room $I_t(s)\setminus\bigcup_aI_{t-1}(sa)$ has measure $\mu'_t(s)-\sum_a\mu'_{t-1}(sa)\ge\sum_a(\mu'_t(sa)-\mu'_{t-1}(sa))$, so we can add to each $I_{t-1}(sa)$ a disjoint dyadic piece of measure $\mu'_t(sa)-\mu'_{t-1}(sa)$ inside the room. All invariants are preserved, and $\lambda(I(s))=\lim_t\mu'_t(s)=\mu(s)$. Since each $I_t(s)$ is a finite union of dyadic intervals, $\omega\in I(s)$ is witnessed by a finite prefix. $\square$

**Theorem 3.2 (universal function machine)** **[proved]**. Define
$$T_U:=\{(x,\ pw,\ y):\ p\in\mathrm{dom}\,V,\ (x,w,y)\in T_{V(p)}\}.$$
$T_U$ is a function machine. Its law $M_F:=\nu_{T_U}$ satisfies $M_F(\emptyset)=1$ and, for every data set $D\ne\emptyset$,
$$\textstyle M_F(D)=\sum_i m(i)\,\nu_{T_i}(D),\qquad\text{hence}\qquad M_F(D)\ \ge\ 2^{-K(\nu)}\,\nu(D)\ \text{ for every machine law }\nu .$$

*Proof.* $T_U$ is c.e. Consistency: if $(x,pw,y),(x,p'w',y')\in T_U$ with $pw,p'w'$ comparable, then $p,p'$ are comparable elements of the prefix-free set $\mathrm{dom}\,V$, so $p=p'$; then $w,w'$ are comparable triples of the same consistent $T_{V(p)}$, so $y=y'$. For $\omega=p\omega'$ with $p\in\mathrm{dom}\,V$ we get $f^{T_U}_\omega=f^{T_{V(p)}}_{\omega'}$, and $\omega'$ is uniform and independent of $p$. If $\omega$ has no prefix in $\mathrm{dom}\,V$, $f_\omega$ is the empty function, which extends only $\emptyset$. Summing over $p$ gives the formula, and $m(i)\ge2^{-K(i)}$ gives the bound. $\square$

*Remark.* The formula is a Bayes mixture: $M_F$ is the prior predictive of "pick a machine $i$ with probability $m(i)$, then a random tape". The posterior over $i$ after $D$ is $m(i)\nu_{T_i}(D)/M_F(D)$.

**Proposition 3.3 (what machine laws include)** **[proved]**.
* (a) *Product laws (Hänni's x-only samplers).* Let $P(y\mid x)$ be lower semicomputable with $\sum_yP(y\mid x)\le1$ for every $x$ (a *conditional semimeasure*). Then $\nu_P(D):=\prod_{(x,y)\in D}P(y\mid x)$ is a machine law with $K(\nu_P)\le K(P)+O(1)$. Probabilistic machines that read $x$ and output $y$ (halting or not) define exactly the lower-semicomputable conditional semimeasures, so this covers every "computably samplable predictor" in Hänni's sense, with independent randomness per input.
* (b) *Deterministic programs.* For a partial computable $\varphi$, $D\mapsto[\varphi\supseteq D]$ is a machine law with $K\le K(\varphi)+O(1)$ (index of $\varphi$).
* (c) *Computable laws.* Let $P$ be the law of a random partial function whose cylinder probabilities $q_S(v)=P(F|_S=v)$, $v\in(Y_\bot)^S$, are computable uniformly in $(S,v)$. Then $\nu_P$ is a machine law (exactly). If $Y$ is finite, it suffices that $\nu_P(D)$ is computable uniformly in $D$, since then each $q_S(v)=\Delta(v^{\rm def},S_\bot(v))$ is a finite alternating sum.
* (d) *Mixtures.* If $(\nu_i)$ are machine laws given by a computable sequence of indices and $w$ is a lower-semicomputable discrete semimeasure, then $D\mapsto\sum_iw_i\nu_i(D)$ ($D\neq\emptyset$) is a machine law.

*Proof.* (a) Apply Lemma 3.1 with alphabet $Y$ and depth one to $P(\cdot\mid x)$, uniformly in $x$: this gives c.e. disjoint dyadic sets $G_{x,y}$ with $\lambda(G_{x,y})=P(y\mid x)$. Fix a computable bijection $\langle\cdot,\cdot\rangle:\mathbb N^2\to\mathbb N$ and the index $j(x)$ of $x$. The private stream of $x$ is $\omega^{(x)}_i:=\omega_{\langle j(x),i\rangle}$. Let $T$ contain $(x,w,y)$ whenever $w$ is long enough to contain the first $L$ bits of $\omega^{(x)}$ and these bits form a string $u$ with $[u]\subseteq G_{x,y}$. $T$ is c.e. and consistent. For distinct inputs the streams use disjoint coordinates of $\omega$, so they are independent and uniform, and $\nu_T(D)=\prod_{(x,y)\in D}\lambda(G_{x,y})=\nu_P(D)$. The samplers claim: a probabilistic machine's output probabilities are lower semicomputable (enumerate halting computations); the converse is the construction just given. (b) $T=\{(x,\varepsilon,\varphi(x))\}$. (c) Enumerate $X$ as $x_1,x_2,\dots$ and fix an enumeration of $Y_\bot$ with $\bot$ last. Build nested partitions of $[0,1)$: the interval $J(v)$ of $v\in(Y_\bot)^k$ is split, left to right, into the intervals $J(va)$ of lengths $q_{k+1}(va)$, $a\in Y$ in order, then $J(v\bot)$. Each left endpoint is $\mathrm{left}(v)+\sum_{a'<a}q(va')$, and the left endpoint of $J(v\bot)$ is $\mathrm{left}(v)+q_k(v)-q_{k+1}(v\bot)$; all are computable reals. Let $T$ contain $(x_k,w,y)$ when the dyadic interval of $w$ is certified (by rational approximations of the endpoints) to lie inside the interior of some $J(v)$ with $v\in(Y_\bot)^k$, $v_k=y\ne\bot$. Intervals at one level are disjoint and levels are nested, so $T$ is consistent. Boundary points form a null set, so $\lambda\{f_\omega(x_i)=v_i,\ i\le k\}=\lambda(J(v))=q_k(v)$ for every $v$, and the law of $f_\omega$ is $P$. (d) Realise $w$ by Lemma 3.1 (depth one, alphabet $\mathbb N$). The construction enumerates pairwise disjoint dyadic cylinders $[u]$, each labelled by some $i$, and the cylinders labelled $i$ have total measure $w_i$. Disjointness makes the set of enumerated strings $u$ prefix-free. Let $T:=\{(x,uw',y):\ [u]\text{ enumerated with label }i,\ (x,w',y)\in T_i\}$. As in Theorem 3.2, $T$ is consistent, the tape after $u$ is uniform and independent of $u$, and $\nu_T(D)=\sum_iw_i\nu_{T_i}(D)$ for $D\ne\emptyset$. Tapes outside all enumerated cylinders give the empty function. $\square$

**Theorem 3.4 (universal weak semimeasure)** **[proved]**. There is a lower-semicomputable weak semimeasure $M^w$ such that $M^w\ge2^{-K(\nu)}\nu$ for every lower-semicomputable weak semimeasure $\nu$.

*Proof.* Let $\phi_i$ enumerate all lower-semicomputable maps from data sets to $[0,1]$, with approximations $\phi_{i,t}$. At stage $t$ use the finite universe $U_t$ of data sets whose inputs and labels are among the first $t$ inputs and labels. Define $\phi'_{i,t}$ on $U_t$ by decreasing $|\mathrm{dom}\,D|$:
$$\textstyle\phi'_{i,t}(D):=\max\Big\{\phi_{i,t}(D),\ \max_{x\le t,\ x\notin\mathrm{dom}\,D}\ \sum_{y\le t}\phi'_{i,t}(D+(x,y))\Big\}.$$
If $\phi'_{i,t}(\emptyset)>1$, freeze ($\phi'_{i,s}:=\phi'_{i,t-1}$ for $s\ge t$). Then $\phi'_{i,t}$ is nondecreasing in $t$ and satisfies the weak inequality inside $U_t$. Its limit $\nu_i$ is a weak semimeasure: for $x\notin\mathrm{dom}\,D$, $\sum_y\nu_i(D+(x,y))=\lim_t\sum_{y\le t}\phi'_{i,t}(D+(x,y))\le\lim_t\phi'_{i,t}(D)=\nu_i(D)$ by monotone convergence. If $\phi_i$ is already a weak semimeasure, induction from the largest domains shows $\phi'_{i,t}\le\phi_i$, so there is no freezing, and $\phi_{i,t}\le\phi'_{i,t}\le\phi_i$ gives $\nu_i=\phi_i$. Put $M^w:=\sum_im(i)\nu_i$. The weak inequalities are linear and $\sum_im(i)\le1$, so $M^w$ is a lower-semicomputable weak semimeasure dominating each $\nu_i$ with factor $m(i)\ge2^{-K(i)}$. $\square$

**Theorem 3.5 (weak versus machine universality)** **[proved; computed: c1, c6]**.
* (i) $M_F\le2^{O(1)}M^w$.
* (ii) For every lower-semicomputable weak semimeasure $\nu$ and every data set $D$: $M_F(D)\ge2^{-K(\nu)-K(\mathrm{dom}\,D)-O(1)}\,\nu(D)$. In particular $M^w(D)\le2^{K(\mathrm{dom}\,D)+O(1)}M_F(D)$.
* (iii) The factor in (ii) cannot be replaced by a constant: for every $k$ there is a data set $D_k$ with $|\mathrm{dom}\,D_k|=2k$ and
$$\log\frac{M^w(D_k)}{M_F(D_k)}\ \ge\ k\log\tfrac32-K(k)-O(1).$$

*Proof.* (i) $M_F$ is a lower-semicomputable weak semimeasure (Prop 2.6), so Theorem 3.4 applies.

(ii) Fix $S=\{s_1<\dots<s_k\}$ and define the semimeasure $\mu_S$ on $Y^*$ by $\mu_S(y_1\dots y_j):=\nu(\{(s_1,y_1),\dots,(s_j,y_j)\})$ for $j\le k$, and $0$ for $j>k$. The weak inequality for $\nu$ is exactly the semimeasure inequality for $\mu_S$, and $\mu_S$ is lower semicomputable uniformly in $(\nu,S)$. Lemma 3.1 realises $\mu_S$ by a monotone machine. Let $T_{\nu,S}$ answer input $s_j$ with the $j$-th symbol of that machine's output (and be undefined off $S$). It is a function machine with index computable from $(\nu,S)$, and for $\mathrm{dom}\,D=S$ we get $\nu_{T_{\nu,S}}(D)=\mu_S(y_{s_1}\dots y_{s_k})=\nu(D)$. (For proper subsets of $S$ we only get $\le$; c6 checks both facts on examples.) Theorem 3.2 gives $M_F(D)\ge2^{-K(\nu,S)}\nu(D)$, and $K(\nu,S)\le K(\nu)+K(S)+O(1)$.

(iii) Use $\tau$ from Example 2.4 on blocks $B_j=\{3j,3j+1,3j+2\}$, $j<k$ (inputs as natural numbers). Let $\tau^{\otimes k}(D):=\prod_{j<k}\tau(D|_{B_j})$ if $\mathrm{dom}\,D\subseteq\bigcup_{j<k}B_j$ and $0$ otherwise. A one-point inequality at $x\in B_j$ involves only the $j$-th factor; at $x$ outside the blocks both sides are $0$. So $\tau^{\otimes k}$ is weak (c1 checks $k=2$ exhaustively). $\rho:=\sum_km(k)\tau^{\otimes k}$ is a lower-semicomputable weak semimeasure, so $M^w\ge2^{-O(1)}\rho$. For $\vec\imath\in\{1,2,3\}^k$ let $E_{\vec\imath}:=\bigcup_jE^{(j)}_{i_j}$ (the copy of $E_{i_j}$ in block $j$). These $3^k$ data sets are pairwise inconsistent and each has $\tau^{\otimes k}(E_{\vec\imath})=2^{-k}$. $M_F$ is the law of a random partial function, so $\sum_{\vec\imath}M_F(E_{\vec\imath})\le1$ and some $D_k:=E_{\vec\imath}$ has $M_F(D_k)\le3^{-k}$. But $M^w(D_k)\ge2^{-O(1)}m(k)2^{-k}\ge2^{-K(k)-k-O(1)}$. $\square$

*How tight is (iii)?* The proof shows that every random partial function law $P$ has $\min_{\vec\imath}P(F\supseteq E_{\vec\imath})/\tau^{\otimes k}(E_{\vec\imath})\le(2/3)^k$. A linear program over all laws on $(Y_\bot)^{3k}$ (c1, part (d)) shows that $(2/3)^k$ is the exact optimum of $\max\{c:\ P\supseteq c\,\tau^{\otimes k}\text{ on the support of }\tau^{\otimes k}\}$ for $k=1,2,3$ **[computed: c1]**. Here $K(\mathrm{dom}\,D_k)\le k\log3+O(\log k)$, so the gap $k\log(3/2)$ is a constant fraction of the upper bound $K(\mathrm{dom}\,D_k)$. Gaps closer to $K(\mathrm{dom}\,D)$ may be possible with larger label sets (constraint systems whose "local" assignments are far from globally consistent); I have not worked this out.

**Problem 3.6 (open)**. Is every lower-semicomputable containment functional of a random partial function (Definition 2.2 with $\nu_P$ lower semicomputable) dominated by $M_F$ up to a multiplicative constant? Equivalently: is the class of such laws, up to constants, the class of machine laws? What is known:
* yes for machine laws (by definition), for lower-semicomputable product laws, for partial computable functions, for computable laws with computable cylinder probabilities, and for lower-semicomputable mixtures of these (Prop 3.3);
* up to $2^{K(\mathrm{dom}\,D)+O(1)}$ for all of them (Thm 3.5(ii), since every containment functional is weak);
* the obstacle: a machine must commit, at a finite stage, to labels on some tapes, while the probability that another input is *undefined* is only upper semicomputable. Sequential sampling in a fixed order therefore loses the mass of "earlier input undefined, later input defined". I tried an adversary that forces repeated couplings on fresh blocks (in the spirit of Example 2.4); the adversary's own mass decays geometrically under the conditional version and the machine survives the unconditional version with a constant reserve, so neither direction is settled.

**Answer to H1(a).** The universal element exists in both senses, but the two senses differ. In the weak sense (the brief's inequality) the universal semimeasure $M^w$ exists (Thm 3.4). In the machine sense (random function, shared randomness) the universal law $M_F$ exists (Thm 3.2). They agree up to $2^{K(\mathrm{dom}\,D)+O(1)}$ and no better (Thm 3.5). A Levin-style equality between "lower-semicomputable function semimeasures" and "machine laws" holds only after restricting the former to random-function laws, and even then only the inclusions in Prop 3.3 are established.

---

## 4. Program mixture, Kolmogorov version, product mixture

**Definition 4.1.** Let $\varphi_e$ be the $e$-th partial computable function $X\rightharpoonup Y$.
* *Deterministic program mixture* (Hänni's informal definition: "the usual prior on all programs"): $W(D):=\sum_{p\in\mathrm{dom}\,V}2^{-|p|}[\varphi_{V(p)}\supseteq D]=\sum_em(e)[\varphi_e\supseteq D]$.
* *Kolmogorov version* (single shortest program): $K_F(D):=\min\{|p|:p\in\mathrm{dom}\,V,\ \varphi_{V(p)}\supseteq D\}=\min\{K(e):\varphi_e\supseteq D\}$.
* *Product mixture*: $M_{\rm prod}(D):=\sum_im(i)\prod_{(x,y)\in D}P_i(y\mid x)$, where $(P_i)$ enumerates all lower-semicomputable conditional semimeasures (enumerable by the trimming of Thm 3.4 applied to each $x$ separately).

$M_{\rm prod}$ is how I formalise Solomonoff's *operator induction*: his third kind of induction takes an unordered set of question–answer pairs and mixes, with a $2^{-\text{length}}$ prior, conditional probability "operators" applied to each question independently (R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008) **[known; abstract and secondary snippets only, full text not checked (unverified)]**. The history track should confirm the match. The product structure is the important point: every hypothesis uses *private* randomness per input, while the mixture index is shared.

$W(\emptyset)$ and $M_{\rm prod}(\emptyset)$ are below $1$ (non-halting programs). Normalising by them changes losses by a constant only.

**Theorem 4.2 (the chain)** **[proved]**. For every data set $D\ne\emptyset$:
$$2^{-K_F(D)}\ \le\ W(D)\ \le\ 2^{O(1)}M_{\rm prod}(D)\ \le\ 2^{O(1)}M_F(D)\ \le\ 2^{O(1)}M^w(D)\ \le\ 2^{K(\mathrm{dom}\,D)+O(1)}\,2^{-K_F(D)}.$$
So the five quantities agree up to $K(\mathrm{dom}\,D)+O(1)$ bits.

*Proof.* (1) The shortest program is one term of the sum. (2) $P_e(y\mid x):=[\varphi_e(x)=y]$ is a conditional semimeasure, lower semicomputable uniformly in $e$; let $g$ be computable with $P_{g(e)}=P_e$. The map $i\mapsto\sum_{e:g(e)=i}m(e)$ is a lower-semicomputable discrete semimeasure, so $m(i)\ge2^{-O(1)}\sum_{e:g(e)=i}m(e)$ by the universality of $m$ (coding theorem, known). Hence $M_{\rm prod}(D)\ge\sum_im(i)\nu_{P_i}(D)\ge2^{-O(1)}\sum_em(e)[\varphi_e\supseteq D]$. (3) $M_{\rm prod}$ is a lower-semicomputable mixture of product laws, a machine law by Prop 3.3(a,d); apply Thm 3.2. (4) Thm 3.5(i). (5) $K_F(D)\le K(D)+O(1)$ (the lookup table of $D$ is a program computable from $D$). $K(D)\le K(\mathrm{dom}\,D)+K(D\mid\mathrm{dom}\,D)+O(1)$ (subadditivity, known). $K(D\mid\mathrm{dom}\,D)\le-\log M^w(D)+O(1)$ by the conditional coding theorem applied to $P(E\mid S):=M^w(E)$ for $\mathrm{dom}\,E=S$, which sums to at most $1$ over $E$ (consequence (b) of Def 2.1). $\square$

**Proposition 4.3 (deterministic programs cannot separate pairs cheaply)** **[proved]**. Let $\{0,1\}\subseteq Y$. For every $\varepsilon>0$ and all large $n$ there are distinct $x_1,x_2\in\{0,1\}^n$ with $W(\{(x_1,0),(x_2,1)\})\le\varepsilon$. On the other hand $M_{\rm prod}(D)\ge2^{-O(1)}/4$ and $M_F(D)\ge2^{-O(1)}/4$ for every two-point $D$ with labels in $\{0,1\}$. Hence $M_{\rm prod}/W$ and $M_F/W$ are unbounded, already on two-point data sets.

*Proof.* Let $\tau_V(\ell):=\sum_{p\in\mathrm{dom}\,V,|p|\ge\ell}2^{-|p|}$, which tends to $0$. Let $E_\ell$ be the set of fewer than $2^\ell$ indices $V(p)$ with $|p|<\ell$. Colour $x\in\{0,1\}^n$ by $c(x):=(\chi_e(x))_{e\in E_\ell}$, where $\chi_e(x)=\varphi_e(x)$ if this is $0$ or $1$ and $\chi_e(x)=*$ otherwise. There are at most $3^{2^\ell}$ colours, so if $2^n>3^{2^\ell}$ two distinct strings $x_1,x_2$ share a colour. No $e\in E_\ell$ has $\varphi_e(x_1)=0$ and $\varphi_e(x_2)=1$. Hence $W(\{(x_1,0),(x_2,1)\})\le\tau_V(\ell)$. Choose $\ell$ with $\tau_V(\ell)\le\varepsilon$ and then $n$ with $2^n>3^{2^\ell}$. For the lower bound use the uniform product law $P(0\mid x)=P(1\mid x)=\tfrac12$, which has complexity $O(1)$. $\square$

*Remark.* The 2-point gap for $n$-bit inputs therefore tends to infinity with $n$, but I have no explicit rate: it is at least $\log(1/\tau_V(\ell_n))-O(1)$ with $\ell_n\approx\log_2(n/\log_23)$, and at most $K(n)+O(1)$ by the next proposition.

**Proposition 4.4 (hashing: fair-coin labels cost only $K(n,k)$)** **[proved; the independence property is computed exhaustively for small fields: c2]**. There is a constant $c$ such that for all $n,k\ge1$ and every $D$ with labels in $\{0,1\}$, $|D|\le k$ and $\mathrm{dom}\,D\subseteq\{0,1\}^{\le n}$:
$$W(D)\ \ge\ 2^{-|D|-K(n,k)-c}.$$
Consequently, if the labels of $D$ are incompressible given the inputs, $K(D\mid\mathrm{dom}\,D)\ge|D|-d$, then $W(D)\ge2^{-K(n,k)-d-c'}M_F(D)$ (using Thm 6.3(a)).

*Proof.* We may assume $k<2^{n+1}$, since $|D|\le|\{0,1\}^{\le n}|<2^{n+1}$ (replacing $k$ by $\min(k,2^{n+1}-1)$ changes $K(n,k)$ by $O(1)$). Let $m:=n+1$ and fix, computably from $m$, an irreducible polynomial of degree $m$ over $\mathrm{GF}(2)$. Embed $\{0,1\}^{\le n}$ injectively into $\mathrm{GF}(2^m)$ by sending $x$ to the element whose coefficient vector is the binary number $1x$. For a seed $s\in\mathrm{GF}(2^m)^k$ let $h_s(z)$ be the lowest bit of $\sum_{i<k}s_iz^i$. For distinct $z_1,\dots,z_k$ the Vandermonde map $s\mapsto(\sum_is_iz_l^i)_{l\le k}$ is a bijection of $\mathrm{GF}(2^m)^k$, so for uniform $s$ the values at any $j\le k$ distinct points are uniform and independent, and so are their lowest bits. Hence $\Pr_s[h_s\supseteq D]=2^{-|D|}$. Let $V'$ be the prefix machine that reads a $V$-program for $(n,k)$, then $km$ further bits $s$, and outputs an index of $x\mapsto h_s(\mathrm{emb}(x))$ on $\{0,1\}^{\le n}$. Its domain is prefix-free. By universality $V(rq)=V'(q)$ for a fixed string $r$. Summing over the $2^{km}$ seeds: $W(D)\ge\sum_s2^{-|r|-K(n,k)-km}[h_s\supseteq D]=2^{-|r|-K(n,k)-|D|}$. $\square$

*Remark (proof sketch only).* The same argument handles any computable product law whose probabilities are dyadic with $r$ bits, at extra cost $K(r)$, by hashing to $r$ bits and sampling by intervals. For general lower-semicomputable product laws I have not carried it out.

**Proposition 4.5 (shared randomness is not a mixture of private randomness)** **[proved]**. Let $\{0,1\}\subseteq Y$ and let $\sigma$ be the law of $F(x):=\omega_{|x|}$: one fair coin per input length, shared by all inputs of that length. $\sigma$ is a machine law of complexity $O(1)$. But $\sup_D\sigma(D)/M_{\rm prod}(D)=\infty$. Hence $M_F/M_{\rm prod}$ is unbounded.

*Proof.* Suppose $M_{\rm prod}\ge c\,\sigma$ for some $c\in(0,1]$. Put $\varepsilon:=c/8$, write $M_{\rm prod}=\sum_iw_i\nu_{P_i}$ with $w_i=m(i)$, and choose $J$ with $\sum_{i>J}w_i\le\varepsilon$. Let $a_n:=0^n$, $b_n:=1^n$, and $s_i(n,y):=P_i(y\mid a_n)P_i(y\mid b_n)$ for $y\in\{0,1\}$.
* *Compactness.* Choose an infinite set of lengths along which $P_i(y\mid a_n)\to\alpha_i(y)$ and $P_i(y\mid b_n)\to\beta_i(y)$ for all $i\le J$, $y\in\{0,1\}$. Let $S_i:=\alpha_i(0)\beta_i(0)+\alpha_i(1)\beta_i(1)\le\max_y\alpha_i(y)\cdot(\beta_i(0)+\beta_i(1))\le1$. If $S_i=1$ then $\max_y\alpha_i(y)=1$, so $\alpha_i=\delta_{y_i}$ for some $y_i$, and then $\beta_i(y_i)=1$, so $\beta_i=\delta_{y_i}$. Let $I_1:=\{i\le J:S_i=1\}$ and $I_0:=\{i\le J:S_i<1\}$, and $r:=\max_{i\in I_0}(1+S_i)/2<1$.
* *Subsequence.* Choose lengths $n_1<n_2<\cdots$ from that set so that, for every $j$: $s_i(n_j,0)+s_i(n_j,1)\le r$ for $i\in I_0$, and $s_i(n_j,1-y_i)\le\delta2^{-j}$ for $i\in I_1$, where $\delta:=\varepsilon/2$.
* *Data.* For $b\in\{0,1\}^k$ let $D_b:=\{(a_{n_j},b_j),(b_{n_j},b_j):j\le k\}$. Then $\sigma(D_b)=2^{-k}$. All $D_b$ have the same domain, so for every $i$, $\sum_b\nu_{P_i}(D_b)=\prod_j(s_i(n_j,0)+s_i(n_j,1))\le1$.
* *Count.* Let $B_k$ be $\{0,1\}^k$ without the two constant vectors. For $i\in I_1$ and $b\in B_k$ the set $T_b:=\{j:b_j\ne y_i\}$ is nonempty, so $\prod_js_i(n_j,b_j)\le\prod_{j\in T_b}\delta2^{-j}$, and $\sum_{b\in B_k}\prod_js_i(n_j,b_j)\le\prod_j(1+\delta2^{-j})-1\le e^\delta-1\le2\delta$. Therefore
$$\textstyle\sum_{b\in B_k}M_{\rm prod}(D_b)\le\sum_{i>J}w_i+\sum_{i\in I_0}w_ir^k+\sum_{i\in I_1}w_i\,2\delta\le\varepsilon+r^k+\varepsilon\le3\varepsilon$$
once $r^k\le\varepsilon$. But $\sum_{b\in B_k}c\,\sigma(D_b)=c(1-2^{1-k})\ge c/2=4\varepsilon$ for $k\ge2$, a contradiction. $\square$

*Remark.* The witnesses are not explicit (the lengths come from a compactness argument), and I have no rate for this gap.

**Problem 4.6 (open).**
* (a) *Coding theorem for function programs.* Is $-\log W(D)=K_F(D)+O(1)$? Established: $K_F(D)-K(\mathrm{dom}\,D)-O(1)\le-\log W(D)\le K_F(D)$. By analogy with Gács's theorem that monotone complexity $Km$ and $-\log M$ differ unboundedly (P. Gács, "On the relation between descriptional complexity and algorithmic probability", *Theoret. Comput. Sci.* 22:71–93, 1983) **[known; statement seen only in secondary sources (unverified)]**, I **conjecture** that the gap is unbounded.
* (b) *Log-factor bound in general.* Is $M_F(D)\le2^{O(K(n,|D|))}\,W(D)$ for all $D$ with inputs of length at most $n$? Prop 4.4 gives this for fair-coin labels only. The general upper bound established is $K(\mathrm{dom}\,D)$, which can be about $|D|\cdot n$.
* (c) Rates for the unbounded gaps in Props 4.3 and 4.5.

**Answer to the question in Hänni's draft (§2.2, "Equivalence between Kolmogorov version and universal semimeasure version: need coding theorem").** They are not equivalent up to a constant. The deterministic program mixture $W$ (and a fortiori the single shortest program $2^{-K_F}$) falls short of the universal semimeasure $M_F$ by an unbounded factor already on two inputs (Prop 4.3). The reason is not the coding theorem but that a random tape can separate any two inputs at constant cost, while a fixed program must be chosen in advance. The coding theorem does bound the gap: at most $K(\mathrm{dom}\,D)+O(1)$ bits (Thm 4.2). For fair-coin labels hashing reduces it to $K(n,|D|)+O(1)$ bits (Prop 4.4). Whether the shortest program and the program mixture agree up to a constant is open (Problem 4.6(a)). For deterministic computable targets the difference does not matter for the basic bounds: all versions have loss at most $K(f)+O(1)$ on $f$'s data.

---

## 5. The definition of SFI and its conventions

**Definition 5.1 (Solomonoff function induction).** Fix $V$ and the enumeration of function machines. SFI is the random partial function $f_\omega:=f^{T_U}_\omega$ with $\omega$ uniform, and its law $M_F$ (Thm 3.2). After data $D$:
* the *posterior* is the conditional law of $f_\omega$ given $f_\omega\supseteq D$; it is again the law of a random partial function, with containment functional $E\mapsto M_F(D\cup E)/M_F(D)$ for $E$ consistent with $D$;
* the *predictive conditional* at a new input $x$ is $M_F(y\mid D,x):=M_F(D+(x,y))/M_F(D)$, a sub-probability on $Y$. Its defect $1-\sum_yM_F(y\mid D,x)$ is the posterior probability that $f_\omega(x)$ is undefined;
* at an input $x\in\mathrm{dom}\,D$ the prediction is the stored label with probability $1$ (because $f_\omega$ is a function).

$M_F(D)>0$ for every data set $D$, since the lookup table of $D$ is a program with positive weight.

**Proposition 5.2 (order independence)** **[proved; computed for a finite mixture: c4 part (2)]**. In the semimeasure convention the cumulative log loss of SFI on a consistent sequence $(x_t,y_t)_{t\le n}$ is
$$\textstyle L_n:=\sum_{t\le n}-\log M_F(y_t\mid D_{t-1},x_t)=-\log M_F(D_n),$$
which depends only on the set $D_n$, not on the order of presentation or on repetitions.

*Proof.* The product of the conditionals telescopes to $M_F(D_n)/M_F(\emptyset)$, and $M_F(\emptyset)=1$. A repeated input contributes the factor $1$. $\square$

The same holds for $W$, $M_{\rm prod}$ and $M^w$ (with their value at $\emptyset$ in the denominator), and for every weak semimeasure.

**Proposition 5.3 (normalisation)** **[proved; computed: c3]**. Let $\bar M_F(y\mid D,x):=M_F(D+(x,y))/\sum_{y'}M_F(D+(x,y'))$ be the normalised conditional. Then (a) the normalised cumulative loss is at most $L_n$ on every sequence, so every upper bound proved below for $L_n$ also holds for it; (b) for random partial functions in general it depends on the order.

*Proof.* (a) Each normaliser is at most $M_F(D)$, so each normalised conditional is at least the raw one. (b) Example (c3): inputs $a,b$, law $(F(a),F(b))=(0,0),(0,\bot),(1,1),(\bot,\bot)$ with probability $\tfrac14$ each, data $\{(a,0),(b,0)\}$. Revealing $a$ first gives normalised probability $\tfrac{1/2}{3/4}\cdot1=\tfrac23$; revealing $b$ first gives $\tfrac{1/4}{1/2}\cdot1=\tfrac12$. The semimeasure probability is $\tfrac14$ in both orders. $\square$

Whether the normalised loss of $M_F$ itself is order-dependent is not settled here; nothing suggests the normaliser cancels.

**Recommendation: call $M_F$ "SFI".** Reasons:
1. *It is the object Hänni describes.* "Pick a random program from the prior and generate using it" is a random function. Programs that use random bits are included, and the random bits are a single tape read by all inputs (Def 2.5).
2. *It has a posterior over functions* (Def 5.1). Joint predictions for several test inputs are coherent. The weak universal semimeasure $M^w$ has no such object (Example 2.4).
3. *It dominates every machine law with constant $2^{-K(\nu)}$* (Thm 3.2): deterministic programs, x-only samplers (product laws), shared-randomness laws, and lower-semicomputable mixtures of these (Prop 3.3).
4. *It is invariant* under the choice of universal machine and of encodings, up to an additive constant in log loss (Thm 6.2).
5. *Its cumulative loss is order-independent* (Prop 5.2).

The variants should be named and kept distinct in the paper:
* $W$, "deterministic SFI" (Hänni's notes);
* $M_{\rm prod}$, "private-randomness SFI" or operator induction (Solomonoff 2008, unverified match);
* $M^w$, the universal weak (order-free) semimeasure.

They agree with $M_F$ up to $K(\mathrm{dom}\,D)+O(1)$ bits and differ by unbounded factors (§3–4). The steeper-simplicity track (H9) uses private randomness, i.e. product laws, for a structural reason (each input pays separately), so it should say explicitly that it works with $M_{\rm prod}$-type hypotheses.

---

## 6. Basic theorems

### 6.1 Dominance (H2)

**Theorem 6.1** **[proved]**. Let $\nu$ be a machine law. For every data set $D$, $M_F(D)\ge2^{-K(\nu)}\nu(D)$. Hence for every consistent sequence $(x_t,y_t)_{t\le n}$, however the inputs were chosen (fixed in advance, adversarial, adaptive, non-computable):
$$L_n=-\log M_F(D_n)\ \le\ -\log\nu(D_n)+K(\nu).$$
In particular:
* (a) *x-only samplers* (Hänni's "Thm 1 (template)"). For every lower-semicomputable conditional semimeasure $P$: $L_n\le\sum_{t\le n}-\log P(y_t\mid x_t)+K(P)+O(1)$. The right side counts a repeated input every time it appears; the left side counts it once.
* (b) *Deterministic programs.* If $y_t=\varphi(x_t)$ for all $t$, then $L_n\le K(\varphi)+O(1)$.
* (c) *Weak comparators.* For every lower-semicomputable weak semimeasure $\nu$: $L_n\le-\log\nu(D_n)+K(\nu)+K(\mathrm{dom}\,D_n)+O(1)$, and the term $K(\mathrm{dom}\,D_n)$ cannot be replaced by $O(1)$.

*Proof.* Thm 3.2 and Prop 5.2. (a) Prop 3.3(a): $-\log\nu_P(D_n)=\sum_{(x,y)\in D_n}-\log P(y\mid x)$, which is at most the per-query sum. (b) Prop 3.3(b). (c) Thm 3.5(ii, iii). $\square$

**Status of H2 as stated in the brief.**
* Correct, as Thm 6.1, for every machine law. This includes all computable random functions with finite label set (Prop 3.3(c)), all x-only samplers and all deterministic programs.
* Two corrections:
  * The label sequence must be consistent. If an input reappears with a different label, $L_n=\infty$, while a sampler that draws fresh randomness at each query has finite loss. Hänni's dovetailing remark ("use different bits of randomness ... for different inputs") gives randomness per *input*, not per *query*, and that is the right reading.
  * For lower-semicomputable *weak* semimeasures the constant becomes $K(\nu)+K(\mathrm{dom}\,D_n)$, and this is necessary (Thm 3.5(iii)).
* For general lower-semicomputable random-function laws the statement is open (Problem 3.6).
* The "any data distribution" form follows by taking expectations of the pathwise bound.

### 6.2 Invariance (Hänni's §2.1)

**Theorem 6.2** **[proved]**.
* (a) *Universal machine.* Let $M_F$ and $M'_F$ be built as in Thm 3.2 from two universal prefix machines and two effective enumerations of function machines. Then $|\log M_F(D)-\log M'_F(D)|\le c$ for all $D$, with $c$ independent of $D$. The same holds for any two function machines whose laws each dominate all machine laws up to constants.
* (b) *Encodings.* Let $\alpha:X\to X'$ and $\beta:Y\to Y'$ be computable injections, and for $D\subseteq X\times Y$ let $D^{\alpha\beta}:=\{(\alpha(x),\beta(y)):(x,y)\in D\}$. Let $M'_F$ be SFI over $X',Y'$. Then for all $D$:
$$|\log M_F(D)-\log M'_F(D^{\alpha\beta})|\le K(\alpha,\beta)+O(1).$$
So cumulative losses on the original and the re-encoded data differ by at most $K(\alpha,\beta)+O(1)$ bits, uniformly over all data sets and all reveal orders.
* (c) The same statements hold for $W$, $M_{\rm prod}$ and $M^w$, with the same proofs.

*Proof.* (a) Each law is a machine law, so each dominates the other by Thm 3.2. (b) The inverses $\alpha^{-1},\beta^{-1}$ are partial computable (search). The machine $\omega\mapsto\beta\circ f_\omega\circ\alpha^{-1}$ on $X'$ (undefined off the range of $\alpha$) has law $\nu'$ with $\nu'(D^{\alpha\beta})=\lambda\{\beta(f_\omega(x))=\beta(y)\ \forall(x,y)\in D\}=M_F(D)$, since $\beta$ is injective. Its index is computable from indices of $\alpha,\beta$, so $M'_F(D^{\alpha\beta})\ge2^{-K(\alpha,\beta)-O(1)}M_F(D)$. Conversely the machine $\omega\mapsto\beta^{-1}\circ f'_\omega\circ\alpha$ on $X$ has law $\nu$ with $\nu(D)=M'_F(D^{\alpha\beta})$. (c) $W$: a program for $\varphi$ becomes a program for $\beta\circ\varphi\circ\alpha^{-1}$ by a prefix of length $K(\alpha,\beta)+O(1)$. $M_{\rm prod}$: transform each conditional semimeasure in the same way. $M^w$: transform weak semimeasures by $\nu'(D'):=\nu(D)$ if $D'=D^{\alpha\beta}$ and $\nu'(D'):=0$ otherwise; if $D'=D^{\alpha\beta}$ and $x'\notin\mathrm{dom}\,D'$, the extensions of $D'$ at $x'$ of the form $E^{\alpha\beta}$ have $x'=\alpha(x)$ and labels $\beta(y)$, so the one-point inequality transfers. $\square$

*Remarks.* The constant $K(\alpha,\beta)$ is not small for complex encodings. A pixel permutation of complexity comparable to the data size changes losses by that much. Non-computable encodings are not covered. "Input encoding doesn't matter much" is therefore exact up to $K(\text{encoding})+O(1)$ bits, uniformly in the data.

### 6.3 Coding-theorem bounds

**Theorem 6.3** **[proved]**. For every data set $D$:
* (a) $-\log M_F(D)\ \ge\ K(D|_T\mid T)-O(1)$ for every $T\subseteq\mathrm{dom}\,D$. In particular $M_F(D)\le2^{-K(D\mid\mathrm{dom}\,D)+O(1)}$, and $M_F(D)\le2^{-K(y\mid x)+O(1)}$ for every $(x,y)\in D$.
* (b) $-\log M_F(D)\ \le\ \min\big\{K_F(D),\ \textstyle\sum_{(x,y)\in D}K(y\mid x)\big\}+O(1)\ \le\ K(\mathrm{dom}\,D)+K(D\mid\mathrm{dom}\,D)+O(1)$.
* (c) For single points, $-\log M_F(\{(x,y)\})=K(y\mid x)\pm O(1)$.

*Proof.* (a) $P(E\mid S):=M_F(E)$ for $\mathrm{dom}\,E=S$ is lower semicomputable uniformly in $(E,S)$ and sums to at most $1$ over $E$ (consequence (b) of Def 2.1). The conditional coding theorem gives $K(E\mid S)\le-\log M_F(E)+O(1)$. Monotonicity gives $M_F(D)\le M_F(D|_T)$. (b) The first term: $M_F\ge2^{-O(1)}W\ge2^{-K_F-O(1)}$ (Thm 4.2). The second: $m(y\mid x):=\sum_{q:V(q,x)=y}2^{-|q|}$, with $V(\cdot,x)$ the conditional prefix machine, is a lower-semicomputable conditional semimeasure with $m(y\mid x)\ge2^{-K(y\mid x)}$; its product law is a machine law of complexity $O(1)$ (Prop 3.3(a)). The last inequality is Thm 4.2, step (5). (c) Combine (a) with $T=\{x\}$ and (b). $\square$

**Example 6.4 (the bound $M_F(D)\le2^{-K(D\mid\mathrm{dom}\,D)+O(1)}$ can be far from tight)** **[proved]**. Take $x_1\ne x_2$ in $\{0,1\}^n$ with $K(x_1,x_2)\ge2n$ (such pairs exist by counting). Let $D:=\{(x_1,x_2),(x_2,x_1)\}$, "each input is labelled by the other". Given the set $\{x_1,x_2\}$, a constant program outputs $D$, so $K(D\mid\mathrm{dom}\,D)=O(1)$. But by (a),
$$-\log M_F(D)\ \ge\ K(x_2\mid x_1)-O(1)\ \ge\ K(x_2\mid x_1,K(x_1))-O(1)=K(x_1,x_2)-K(x_1)-O(1)\ \ge\ n-2\log n-O(1),$$
using symmetry of information $K(a,b)=K(a)+K(b\mid a,K(a))+O(1)$ **[known: Gács 1974; Chaitin 1975]** and $K(x_1)\le n+2\log n+O(1)$. The data are trivial *as a set* but each label is a random $n$-bit string *given its own input*. A function cannot see the other input. This is the mechanism behind Hänni's chain and skipped-string examples (history track).

So the correct general form of (iii) in the brief is the two-sided bound of Thm 6.3. The left side is the maximum over subsets $T$, not just $T=\mathrm{dom}\,D$. Neither side is tight in general, and a two-sided characterisation of $-\log M_F(D)$ up to $O(1)$ is open (other than the tautology $-\log M_F(D)=\min_\nu[K(\nu)-\log\nu(D)]\pm O(1)$ over machine laws $\nu$).

### 6.4 Merging and mistake bounds

**Theorem 6.5 (merging)** **[proved; finite analogue computed exactly, including the worst adaptive selection rule: c4 part (3)]**. Let $\nu$ be a machine law that is the law of a random *total* function: $\nu(D)=\sum_y\nu(D+(x,y))$ for all $D$ and $x\notin\mathrm{dom}\,D$. (For finite $Y$ these are exactly the computable such laws: a lower-semicomputable $\nu$ of this kind is computable, because by induction on $|D|$ each $\nu(D+(x,y))=\nu(D)-\sum_{y'\ne y}\nu(D+(x,y'))$ is also upper semicomputable; the converse is Prop 3.3(c).) Let $F\sim\nu$. Inputs are chosen by any rule $x_t=s_t(H_{t-1},\xi_t)$, where $H_{t-1}=(x_1,y_1,\dots,x_{t-1},y_{t-1})$, $(\xi_t)$ is independent of $F$, and $s_t$ is arbitrary (possibly non-computable). Put $y_t:=F(x_t)$ and
$$d_t:=\mathrm{KL}\big(\nu(\cdot\mid D_{t-1},x_t)\ \big\|\ M_F(\cdot\mid D_{t-1},x_t)\big)\quad\text{(bits)},\qquad \nu(y\mid D,x):=\nu(D+(x,y))/\nu(D).$$
Then for every $n$:
$$\textstyle\sum_{t\le n}\mathbb E\,d_t=\mathbb E\log\frac{\nu(D_n)}{M_F(D_n)}\le K(\nu).$$
Consequently $\sum_{t\ge1}\mathbb E\,d_t\le K(\nu)$, $d_t\to0$ almost surely, and $\sum_t\mathbb E\,\|\nu(\cdot\mid D_{t-1},x_t)-M_F(\cdot\mid D_{t-1},x_t)\|_1^2\le2\ln2\cdot K(\nu)$.

*Proof.* *Posterior lemma:* given $H_{t-1}=h$ and $\xi$, the conditional law of $F$ is $\nu(\cdot\mid F\supseteq D_h)$. Indeed $\{H_{t-1}=h\}$ is the intersection of $\{F\supseteq D_h\}$ with an event that depends on $\xi$ only (that the rule, fed the labels of $h$, produces the inputs of $h$), and $\xi$ is independent of $F$. Hence $P(y_t=y\mid H_{t-1},\xi)=\nu(y\mid D_{t-1},x_t)$. If $x_t\in\mathrm{dom}\,D_{t-1}$, both conditionals are the point mass at the stored label and $d_t=0$. Otherwise $\mathbb E[\log\frac{\nu(y_t\mid D_{t-1},x_t)}{M_F(y_t\mid D_{t-1},x_t)}\mid H_{t-1},\xi]=d_t\ge0$. ($d_t\ge0$ also when the second argument is a sub-probability, by Jensen: $\sum p\log(q/p)\le\log\sum q\le0$.) Summing the log-ratios telescopes to $\log\nu(D_n)/M_F(D_n)$, which is at most $K(\nu)$ pathwise (Thm 3.2). Take expectations (tower property; all conditional expectations are nonnegative). Almost-sure convergence: $\sum_td_t$ has finite expectation, so it is finite a.s. Pinsker's inequality, for a sub-probability $q$ extended by one extra atom carrying its defect, gives $\|p-q\|_1^2\le2\ln2\cdot\mathrm{KL}(p\|q)$ in bits. $\square$

*Remarks.*
* This is the function analogue of Solomonoff's convergence theorem (R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Trans. Inf. Theory* 24(4):422–432, 1978) **[known (unverified)]**.
* The input rule may be adversarial but must not see $F$ beyond the past labels. If it does see $F$ (for example, it chooses inputs whose label is $1$), the expected-KL statement can fail, because the conditional law of $y_t$ is no longer $\nu(\cdot\mid D_{t-1},x_t)$. The pathwise bound $L_n\le-\log\nu(D_n)+K(\nu)$ still holds.
* With finite horizon $n$ the worst adaptive rule matters. With all of a finite $X$ queried the total is the same for every rule, because $\log\nu(D_n)/M_F(D_n)$ depends only on the final set (c4 shows both).

**Corollary 6.6 (mistake bound)** **[proved]**. Let $\varphi$ be partial computable, and let $x_1,x_2,\dots\in\mathrm{dom}\,\varphi$ be any inputs, with $y_t=\varphi(x_t)$. The number of $t$ with $M_F(\varphi(x_t)\mid D_{t-1},x_t)\le\tfrac12$ is at most $K(\varphi)+O(1)$. So the predictor $\hat y_t:=\arg\max_yM_F(y\mid D_{t-1},x_t)$ makes at most $K(\varphi)+O(1)$ mistakes on every input sequence.

*Proof.* Each such $t$ adds at least $1$ bit to $L_n\le K(\varphi)+O(1)$ (Thm 6.1(b)). If $M_F(\varphi(x_t)\mid\cdot)>\tfrac12$, then $\varphi(x_t)$ is the unique maximiser. The maximum exists because only finitely many labels have conditional above any positive threshold. $\square$

This is the halving-algorithm bound $\log|H|$ (N. Littlestone, *Machine Learning* 2:285–318, 1988; for enumerable classes J. Barzdin and R. Freivalds, *Soviet Math. Doklady* 13, 1972) **[known (unverified)]**, with $K(\varphi)$ in place of $\log|H|$. The predictor is not computable (Prop 7.3).

### 6.5 Online-to-batch: SFI as supervised learning (H7)

**Theorem 6.7** **[proved]**. Let $\pi$ be any probability distribution on $X$ (it need not be computable), and let $x_1,x_2,\dots$ be i.i.d. from $\pi$.
* (a) *Deterministic labels.* Let $\varphi$ be partial computable with $\pi(\mathrm{dom}\,\varphi)=1$ and $y_t=\varphi(x_t)$. Put $Q_t(\cdot\mid x):=M_F(\cdot\mid D_t,x)$, $\bar Q_n:=\frac1n\sum_{t=0}^{n-1}Q_t$, and $R(Q):=\mathbb E_{x\sim\pi}[-\log Q(\varphi(x)\mid x)]$. Then
$$\mathbb E\,R(\bar Q_n)\le\frac{K(\varphi)+O(1)}n,\qquad \mathbb E\,\pi\{x:\arg\max_y\bar Q_n(y\mid x)\ne\varphi(x)\}\le\frac{K(\varphi)+O(1)}n .$$
* (b) *Noisy labels, time-stamped inputs.* Let $P(\cdot\mid x)$ be any conditional probability (possibly non-computable), and let $y_t\sim P(\cdot\mid x_t)$ independently given the inputs. Run SFI on the stamped inputs $\tilde x_t:=\langle x_t,t\rangle$ ($\langle\cdot,\cdot\rangle$ a computable bijection $X\times\mathbb N\to X$), with data $\tilde D_t$. Put $q_t(\cdot\mid x):=M_F(\cdot\mid\tilde D_{t-1},\langle x,t\rangle)$ and $\bar q_n:=\frac1n\sum_{t=1}^nq_t$. Then for every lower-semicomputable conditional semimeasure $\nu$:
$$\mathbb E\,\mathbb E_{x\sim\pi}\mathrm{KL}\big(P(\cdot\mid x)\,\|\,\bar q_n(\cdot\mid x)\big)\ \le\ \frac{K(\nu)+O(1)}n+\mathbb E_{x\sim\pi}\mathrm{KL}\big(P(\cdot\mid x)\,\|\,\nu(\cdot\mid x)\big).$$
In particular the bound is $(K(P)+O(1))/n$ if $P$ is computable. The expected excess 0–1 risk of $\arg\max\bar q_n$ over the Bayes classifier is at most $\sqrt{2\ln2\cdot\text{(right side)}}$.
* (c) *Noisy labels, frozen per input.* Let $F$ have the product law of a computable conditional probability $P$ (one draw per input), and $y_t=F(x_t)$. Then $\sum_{t\le n}\mathbb E\,d_t\le K(P)+O(1)$ with $d_t$ as in Thm 6.5. This is Thm 6.5 for this law, and it holds for any input rule that sees only the past, not only i.i.d. inputs.

*Proof.* (a) $x_t$ is independent of $D_{t-1}$ and has law $\pi$, so $\mathbb E\,R(Q_{t-1})=\mathbb E[-\log M_F(y_t\mid D_{t-1},x_t)]$. Summing over $t\le n$ gives $\mathbb E\,L_n\le K(\varphi)+O(1)$ (Thm 6.1(b); repeated inputs contribute $0$). $-\log$ is convex, so $R(\bar Q_n)\le\frac1n\sum_tR(Q_t)$. For the 0–1 claim: if $\bar Q_n(\varphi(x)\mid x)>\tfrac12$, then $\varphi(x)$ is the unique maximiser, and by Markov's inequality $\pi\{\bar Q_n(\varphi(x)\mid x)\le\tfrac12\}\le R(\bar Q_n)$.

(b) Stamped inputs are distinct, so given the past the label $y_t$ has law $P(\cdot\mid x_t)$. As in Thm 6.5, $\sum_{t\le n}\mathbb E\,\mathrm{KL}(P(\cdot\mid x_t)\|q_t(\cdot\mid x_t))=\mathbb E\log\frac{\prod_tP(y_t\mid x_t)}{M_F(\tilde D_n)}$. The product law $\tilde\nu(y\mid\langle x,t\rangle):=\nu(y\mid x)$ is a machine law with $K(\tilde\nu)\le K(\nu)+O(1)$, so $M_F(\tilde D_n)\ge2^{-K(\nu)-O(1)}\prod_t\nu(y_t\mid x_t)$ and the right side is at most $K(\nu)+O(1)+\sum_t\mathbb E\log\frac{P(y_t\mid x_t)}{\nu(y_t\mid x_t)}=K(\nu)+O(1)+n\,\mathbb E_\pi\mathrm{KL}(P\|\nu)$. Since $x_t\sim\pi$ is independent of $\tilde D_{t-1}$, the $t$-th term on the left equals $\mathbb E\,\mathbb E_{x\sim\pi}\mathrm{KL}(P(\cdot\mid x)\|q_t(\cdot\mid x))$. KL is convex in its second argument, which gives the bound for $\bar q_n$. 0–1: with $y^*$ the Bayes label and $\hat y=\arg\max\bar q_n$, $P(y^*\mid x)-P(\hat y\mid x)\le[P(y^*)-\bar q(y^*)]+[\bar q(\hat y)-P(\hat y)]\le\|P(\cdot\mid x)-\bar q_n(\cdot\mid x)\|_1$. Then apply Pinsker (as in Thm 6.5) and Jensen.

(c) The product law of a computable total $P$ is a machine law (Prop 3.3(a)) and a law of a random total function. $\square$

**Proposition 6.8 (H7 as stated is false for noisy labels)** **[proved; computed: c5]**. Suppose $\pi(x_0)=\alpha>0$ and $P(\cdot\mid x_0)$ gives positive probability to two labels. Draw the pairs $(x_t,y_t)$ i.i.d. from $\pi\times P$ (fresh label at every draw), and run plain SFI. Then $\Pr[D_n\text{ inconsistent}]>0$ for every $n\ge2$, so $\mathbb E\,L_n=\infty$, also for the normalised conditionals. Moreover $\Pr[D_n\text{ consistent}]\le(1-\alpha)^n+p_{\max}^{-1}(1-\alpha+\alpha p_{\max})^n\to0$, where $p_{\max}:=\max_yP(y\mid x_0)<1$.

*Proof.* Two draws of $x_0$ with different labels have positive probability, and then $M_F(D_n)=0$ (and the normalised conditional of the second label is $0$). For the rate: the labels at $x_0$ agree with probability $(1-\alpha)^n+\sum_{j\ge1}\binom nj\alpha^j(1-\alpha)^{n-j}\sum_yP(y\mid x_0)^j$, and $\sum_yP(y\mid x_0)^j\le p_{\max}^{j-1}$. $\square$

Since $X$ is countable, $\pi$ is purely atomic. So "for any input distribution and computable conditional law, SFI's cumulative expected log loss is at most $K(P)+O(1)$" holds for all $n\ge2$ exactly when $P(\cdot\mid x)$ is a point mass for every $x$ with $\pi(x)>0$. In that case $\varphi(x):=$ the label with $P(\varphi(x)\mid x)>\tfrac12$ is partial computable with $K(\varphi)\le K(P)+O(1)$ and $\pi(\mathrm{dom}\,\varphi)=1$, which is case (a). This is not a quirk of the proof. SFI models the label as a *function* of the input, and a supervised-learning source with fresh noise is not a random function of the input. The repairs are Thm 6.7(b) (give the learner a stamp, i.e. a fresh input coordinate) and (c) (freeze the noise). In practice inputs rarely repeat exactly; in theory one repetition with a different label is enough for infinite loss.

### 6.6 Comparison with Occam, PAC-Bayes, MDL and expert-advice bounds

* **Occam's razor** (A. Blumer, A. Ehrenfeucht, D. Haussler, M. Warmuth, "Occam's razor", *Inf. Process. Lett.* 24:377–380, 1987) **[known (unverified)]**. The description-length form is easy to prove directly **[proved]**: for i.i.d. $x_t\sim\pi$ and deterministic $\varphi$, with probability at least $1-\delta$ every program $p\in\mathrm{dom}\,V$ consistent with $D_n$ has $\pi\{x:\varphi_{V(p)}(x)\ne\varphi(x)\}\le(|p|\ln2+\ln(1/\delta))/n$. (Put $\varepsilon_p:=(|p|\ln2+\ln\frac1\delta)/n$; a fixed $p$ with error above $\varepsilon_p$ is consistent with probability at most $(1-\varepsilon_p)^n\le2^{-|p|}\delta$; sum over $p$ by Kraft.) Applied to the shortest consistent program, whose length is at most $K(\varphi)$ because $\varphi$ itself is consistent, this gives the Kolmogorov version $K_F$ a high-probability 0–1 rate $(K(\varphi)\ln2+\ln\frac1\delta)/n$. SFI's Thm 6.7(a) gives the same rate in expectation, for log loss as well as 0–1 loss. So for deterministic targets the two versions have the same learning rate. They differ under noise: the Occam argument needs consistency, while SFI has the resolvability bound (b).
* **PAC-Bayes** (D. McAllester, "Some PAC-Bayesian theorems", *Machine Learning* 37:355–363, 1999) **[known (unverified)]**: bounds of the form $\mathbb E_QR\le\mathbb E_Q\hat R+\sqrt{(\mathrm{KL}(Q\|\text{prior})+\ln(n/\delta))/(2n)}$, up to the version, with faster $\mathrm{KL}/n$ rates in the realisable case. With prior $2^{-K}$ and posterior concentrated on the target, $\mathrm{KL}(Q\|\text{prior})\approx K(\varphi)\ln2$, matching the rates above. The difference is in kind: PAC-Bayes bounds the risk of a randomised classifier with high probability; Thm 6.7 bounds the expected log risk of the Bayes predictive.
* **MDL and the index of resolvability** (A. Barron, T. Cover, "Minimum complexity density estimation", *IEEE Trans. Inf. Theory* 37(4):1034–1054, 1991; A. Barron, "Information-theoretic characterization of Bayes performance and the choice of priors in parametric and nonparametric problems", *Bayesian Statistics* 6, 1998) **[known (unverified)]**. Thm 6.7(b) is exactly the Cesàro-average resolvability bound $\min_\nu[L(\nu)/n+D(P\|\nu)]$ for the Bayes mixture, with code length $L(\nu)=K(\nu)$, in the conditional (regression) setting, for every input distribution.
* **Prediction with expert advice** (V. Vovk, aggregating algorithm, COLT 1990; N. Cesa-Bianchi, G. Lugosi, *Prediction, Learning, and Games*, Cambridge 2006) **[known (unverified)]**. Under log loss the Bayes mixture has regret $\ln(1/w_i)$ against expert $i$ on every sequence. Thm 6.1 is this fact with the experts being machine laws: each expert predicts with its own posterior given past labels, so shared randomness is allowed.
* **Online-to-batch conversion** (N. Littlestone, "From on-line to batch learning", COLT 1989; N. Cesa-Bianchi, A. Conconi, C. Gentile, *IEEE Trans. Inf. Theory* 50(9):2050–2057, 2004) **[known (unverified)]**. Thm 6.7 uses only the elementary averaging form, proved above.

### 6.7 In what sense SFI is "ideal supervised learning"

What is established:
1. SFI is the Bayes predictor for the prior "a random computable labeller", namely machine laws weighted by $2^{-K}$ (Thm 3.2, remark). It is universal for that class pathwise: on every consistent data sequence, however the inputs are chosen, its cumulative log loss exceeds that of any computable random labeller $\nu$ by at most $K(\nu)$ (Thm 6.1).
2. In the standard supervised model (i.i.d. inputs from an arbitrary, even non-computable distribution; labels a computable function of the input, or noisy labels with time-stamped inputs), its averaged predictor has expected excess log risk at most $(K+O(1))/n$ (Thm 6.7(a,b)). With noise frozen per input, the cumulative bound $K(P)+O(1)$ holds (Thm 6.7(c)). This is the Occam rate with Kolmogorov complexity in place of $\log|H|$, with no union bound and no confidence parameter. For non-computable label laws the bound becomes the resolvability bound.
3. Inputs are never predicted. The input distribution may be arbitrary and complex at no cost. (Sequence induction on $(x,y)$ streams must also predict the $x$'s; see the history track.)

Where the analogy breaks:
* *Loss.* The guarantees are for log loss on labels. 0–1 bounds follow: $K/n$ for deterministic labels and $\sqrt{K/n}$ excess risk with noise (Thm 6.7). SFI is a Bayes mixture, not an empirical-risk minimiser. Its Kolmogorov counterpart (the shortest consistent program) is the Occam learner.
* *Function semantics.* SFI assumes that the label is a function of the input. Raw i.i.d. data with fresh label noise make its loss infinite (Prop 6.8).
* *Computability.* $M_F$ is lower semicomputable but not computable, and so are its predictions (Prop 7.3). It is an ideal reference, not an algorithm. Time-bounded and circuit versions are treated by other tracks.
* *Constants.* All bounds hold up to the machine-dependent constant in $K$, which can be large; encodings cost $K(\text{encoding})$ (Thm 6.2).
* *Distribution shift.* The batch guarantees are for test inputs from the training distribution. On inputs that are rare or absent in training no guarantee follows (H8, context track).
* *Comparator class.* The comparators are random functions that do not see the history. Predictors that use the list of past inputs are not dominated (Example 6.4 and the history track).

---

## 7. Further foundational points

**Proposition 7.1 (sequence induction is SFI on initial segments)** **[proved]**. Take $X=\mathbb N$ and $\{0,1\}\subseteq Y$. Let $M$ be the universal monotone semimeasure on binary sequences, $M(x)=\lambda\{\omega:U_{\rm mon}(\omega)\sqsupseteq x\}$ for a universal monotone machine (Zvonkin–Levin 1970; Li–Vitányi §4.5) **[known (unverified section)]**. For $x\in\{0,1\}^n$ let $D_x:=\{(i,x_{i+1}):i<n\}$. Then
$$2^{-O(1)}M(x)\ \le\ M_F(D_x)\ \le\ 2^{O(1)}M(x).$$
Hence on binary sequences presented in order, the cumulative losses of SFI and of Solomonoff induction differ by $O(1)$ for all $n$.

*Proof.* ($\ge$) $T_1:=\{(i,w,b):U_{\rm mon}(w)\text{ has length}>i\text{ and bit }i+1\text{ equal to }b\}$ is a function machine with $\nu_{T_1}(D_x)=M(x)$; apply Thm 3.2. ($\le$) Let $T_2$ be the monotone machine that, on tape $\omega$, outputs $f_\omega(0),f_\omega(1),\dots$ in order, as long as each value is found (by enumerating $T_U$ along prefixes of $\omega$) and lies in $\{0,1\}$. Its output extends $x$ exactly when $f_\omega\supseteq D_x$, so its output semimeasure at $x$ is $M_F(D_x)$, and $M$ dominates it. $\square$

So SFI generalises Solomonoff induction. Prop 7.2 shows that it is in turn a restriction of universal prediction with side information.

**Proposition 7.2 (relation to universal prediction with side information)** **[proved, given the known existence of $\xi$]**. A *chronological semimeasure* (Hutter's $\rho(y_{1:n}\|x_{1:n})$, with inputs as "actions" and labels as "percepts") is a lower-semicomputable $\rho\ge0$ with $\rho(\varepsilon)\le1$ and $\sum_{y_n}\rho(y_{1:n}\|x_{1:n})\le\rho(y_{<n}\|x_{<n})$ for every $x_n$. There is a universal one, $\xi\ge2^{-K(\rho)-O(1)}\rho$ (M. Hutter, *Universal Artificial Intelligence*, Springer 2005, ch. 5) **[known (unverified)]**.
* (a) $\rho_F(y_{1:n}\|x_{1:n}):=M_F(D_n)$ if the sequence is consistent and $0$ otherwise is a chronological semimeasure. Hence $\xi(y_{1:n}\|x_{1:n})\ge2^{-O(1)}M_F(D_n)$: the history-aware universal predictor is never worse than SFI by more than a constant, on any sequence.
* (b) Call $\rho$ *order-free* if $\rho(y_{1:n}\|x_{1:n})$ depends only on the set $D_n$ and vanishes on inconsistent sequences. Order-free chronological semimeasures correspond exactly to lower-semicomputable weak function semimeasures, via $\rho(y_{1:n}\|x_{1:n})=\nu(D_n)$. So the universal order-free one is $M^w$, not $M_F$. $M_F$ is universal for the smaller class of order-free environments that are random functions (in the machine sense).

*Proof.* (a) Lower semicomputability is clear. If $x_n\notin\{x_{<n}\}$, the chronological inequality is the weak inequality for $M_F$. If $x_n=x_s$ for some $s<n$, only $y_n=y_s$ gives a non-zero term, and that term equals $\rho_F(y_{<n}\|x_{<n})$. (b) The same computation in both directions. $\square$

The converse of (a) fails. The history track develops this: Hänni's chain example, Example 6.4 here, and his conjecture that SFI with oracle access to past inputs matches $\xi$.

**Proposition 7.3 (computability)** **[proved]**.
* (a) $M_F(D)$ is lower semicomputable uniformly in $D$, and $M_F(D)>0$ for every $D$.
* (b) $M_F$ is not computable.
* (c) Neither the raw conditional $M_F(y\mid D,x)$ nor the normalised conditional $\bar M_F(y\mid D,x)$ is computable as a function of $(D,x,y)$.
* (d) Both conditionals are limit-computable ($\Delta^0_2$).

*Proof.* (a) Prop 2.6 and §5. (c) Take $X=\mathbb N$ and suppose the raw conditional is computable. Define $f$ by recursion: with $D_t=\{(s,f(s)):s<t\}$, let $f(t)$ be the first $y\in\{0,1\}$ for which approximation certifies $M_F(y\mid D_t,t)<0.6$. Since the two conditionals sum to at most $1$, one of them is at most $\tfrac12$, so the search halts. $f$ is total computable, so $M_F(D_n)=\prod_{t<n}M_F(f(t)\mid D_t,t)<0.6^n$. This contradicts $M_F(D_n)\ge2^{-K(f)-O(1)}$ for large $n$. The same argument works for the normalised conditional: the normalised loss would be at least $n\log(1/0.6)$, while it is at most $L_n\le K(f)+O(1)$ (Prop 5.3). (b) If $M_F$ were computable, the raw conditional would be a computable ratio of positive computable reals. (d) Lower-semicomputable reals are computable from the halting problem, and the normaliser $\sum_yM_F(D+(x,y))$ is lower semicomputable and positive. $\square$

The exact arithmetical level (for example, whether the conditionals are lower or upper semicomputable) is not settled here. For Solomonoff's $M$ this was studied by J. Leike and M. Hutter, "On the computability of Solomonoff induction and knowledge-seeking", ALT 2015 **[known (unverified)]**.

**Remark 7.4 (where the randomness lives).** The three mixtures differ only in where the randomness lives:
* $W$: none; each hypothesis is a fixed function;
* $M_{\rm prod}$: private per input (each hypothesis is a stochastic operator applied to each input independently);
* $M_F$: one tape shared by all inputs; each hypothesis may correlate labels across inputs, for example $F(x)=\omega_{|x|}$.

Because the mixture index is itself shared, every mixture correlates labels across inputs through the posterior. The strict separations (Props 4.3 and 4.5) show that the classes still differ in more than constants. For learning a deterministic computable target the differences are invisible in the basic bounds; they matter for noise (H9 uses private randomness), for data with random but shared structure, and for lower bounds.

---

## 8. Open problems

1. **Problem 3.6.** Is every lower-semicomputable law of a random partial function dominated by $M_F$ up to a constant?
2. **Problem 4.6(a).** Coding theorem for function programs: is $-\log W(D)=K_F(D)+O(1)$? Conjecture: no.
3. **Problem 4.6(b).** Is $\log(M_F(D)/W(D))=O(K(n,|D|))$ for inputs of length at most $n$? Proved only for fair-coin labels (Prop 4.4).
4. **Rates.** Explicit rates for the unbounded gaps $M_{\rm prod}/W$ (Prop 4.3) and $M_F/M_{\rm prod}$ (Prop 4.5). How close can $\log(M^w/M_F)$ get to $K(\mathrm{dom}\,D)$ (Thm 3.5)?
5. **Two-sided characterisation** of $-\log M_F(D)$ up to $O(1)$ in terms of standard complexities (Thm 6.3 gives non-matching bounds; Example 6.4 shows that $K(D\mid\mathrm{dom}\,D)$ is the wrong lower bound in general).
6. **Arithmetical level** of the predictive conditionals (Prop 7.3).

---

## 9. Claims table

| ID | Claim | Status | Where |
|---|---|---|---|
| F1 | Weak function semimeasures are exactly the order-independent online predictors | proved | §2 |
| F2 | Containment functionals of random partial functions are characterised by the Möbius condition | proved; computed (c6a) | Prop 2.3 |
| F3 | A weak semimeasure need not be the law of any random function; for $\tau$ no law reaches more than $\tfrac23\tau$ | proved; computed (c1) | Ex 2.4 |
| F4 | Machine laws are lower-semicomputable random-function laws | proved | Prop 2.6 |
| F5 | Universal function machine: $M_F=\sum_im(i)\nu_{T_i}$, so $M_F\ge2^{-K(\nu)}\nu$ for every machine law | proved | Thm 3.2 |
| F6 | Machine laws include lsc product laws (x-only samplers), partial computable functions, computable laws with computable cylinder probabilities (computable $\nu$ if $Y$ is finite), and lsc mixtures | proved | Prop 3.3 |
| F7 | A universal lsc weak semimeasure $M^w$ exists | proved | Thm 3.4 |
| F8 | $M_F\ge2^{-K(\nu)-K(\mathrm{dom}\,D)-O(1)}\nu$ for lsc weak $\nu$; $M^w\le2^{K(\mathrm{dom}\,D)+O(1)}M_F$ | proved; step checked (c6b) | Thm 3.5(ii) |
| F9 | $\log(M^w/M_F)\ge k\log\tfrac32-K(k)-O(1)$ on some $2k$-point data sets | proved; LP tightness of $(2/3)^k$ for $k\le3$ computed (c1) | Thm 3.5(iii) |
| F10 | Brief H1(a): "lsc function semimeasures, or equivalently monotone function machines" | refuted for the weak definition (F9); open for random-function laws (F11) | §3 |
| F11 | Every lsc random-function law is dominated by $M_F$ | open | Problem 3.6 |
| F12 | $2^{-K_F}\le W\lesssim M_{\rm prod}\lesssim M_F\lesssim M^w\le2^{K(\mathrm{dom}\,D)+O(1)}2^{-K_F}$ | proved | Thm 4.2 |
| F13 | $M_{\rm prod}/W$ and $M_F/W$ are unbounded on two-point data | proved | Prop 4.3 |
| F14 | $W(D)\ge2^{-\lvert D\rvert-K(n,k)-O(1)}$ for binary labels, $\lvert D\rvert\le k$, inputs of length $\le n$ | proved; hashing computed (c2) | Prop 4.4 |
| F15 | $M_F/M_{\rm prod}$ is unbounded (shared coin per input length) | proved | Prop 4.5 |
| F16 | Hänni §2.2: Kolmogorov version and semimeasure version are equivalent | refuted up to constants; true up to $K(\mathrm{dom}\,D)+O(1)$ | §4 |
| F17 | $-\log W=K_F+O(1)$ | open; conjectured false | Problem 4.6 |
| F18 | Semimeasure cumulative loss $=-\log M_F(D_n)$ is order-independent | proved; computed (c4) | Prop 5.2 |
| F19 | Normalised loss is at most the semimeasure loss and is order-dependent in general | proved; computed (c3) | Prop 5.3 |
| F20 | H2: pathwise dominance over every machine law, for every input sequence | proved | Thm 6.1 |
| F21 | H2 for lsc weak $\nu$ with constant $K(\nu)+O(1)$ | refuted; correct with $+K(\mathrm{dom}\,D_n)$ | Thm 6.1(c) |
| F22 | H2 needs consistent label sequences (randomness per input, not per query) | proved | §6.1 |
| F23 | Hänni's "Thm 1 (template)" for x-only computable samplers | proved (as F20(a)) | Thm 6.1(a) |
| F24 | Invariance under universal machine and computable injective encodings, constant $K(\alpha,\beta)+O(1)$ | proved | Thm 6.2 |
| F25 | $\max_TK(D\vert_T\mid T)-O(1)\le-\log M_F(D)\le\min\{K_F(D),\sum K(y\mid x)\}+O(1)$; tight for single points | proved | Thm 6.3 |
| F26 | Swap example: $K(D\mid\mathrm{dom}\,D)=O(1)$ but $-\log M_F(D)\ge n-2\log n-O(1)$ | proved | Ex 6.4 |
| F27 | Merging: $\sum_t\mathbb E\,\mathrm{KL}_t\le K(\nu)$ for computable random total functions and past-only input rules | proved; finite analogue computed (c4) | Thm 6.5 |
| F28 | Mistake bound $K(\varphi)+O(1)$ for deterministic computable targets | proved | Cor 6.6 |
| F29 | H7 for deterministic labels: risk $\le(K+O(1))/n$, log and 0–1 | proved | Thm 6.7(a) |
| F30 | H7 with stamped or frozen noise; resolvability bound for non-computable $P$; $\sqrt{\cdot}$ 0–1 excess | proved | Thm 6.7(b,c) |
| F31 | H7 for i.i.d. pairs with fresh noisy labels (plain SFI) | refuted; computed (c5) | Prop 6.8 |
| F32 | Occam bound in description-length form | proved (standard; known reference unverified) | §6.6 |
| F33 | Solomonoff induction is SFI on initial segments, up to constants | proved | Prop 7.1 |
| F34 | Hutter's $\xi$ dominates SFI; order-free chronological semimeasures are the weak semimeasures | proved given known $\xi$ | Prop 7.2 |
| F35 | $M_F$ is lsc, not computable; its conditionals (raw, normalised) are not computable and are limit-computable | proved | Prop 7.3 |
| F36 | $M_{\rm prod}$ matches Solomonoff's operator induction (2008) | known (unverified match) | §4 |

---

## 10. Verification log

**Scripts** (all in `checks/`, run with `python3` 3.11, numpy 2.4.6, scipy 1.17.1; deterministic unless a seed is stated; output saved as `<name>.out.txt` next to each script).

| Script | What it checks | Result |
|---|---|---|
| `c1_weak_vs_random_function.py` | $\tau$ (Ex 2.4) and $\tau^{\otimes2}$ satisfy all one-point inequalities; Möbius sum of $\tau$ at $(\emptyset,\{a,b,c\})$; pairwise inconsistency of $E_1,E_2,E_3$; LP optimum of $\max\{c:\exists P,\ P(F\supseteq D)\ge c\,\tau^{\otimes k}(D)\}$ over all laws on $(Y_\bot)^{3k}$ | 27 and 1458 inequalities, 0 violations; Möbius sum $-1/2$; all pairs inconsistent; LP optimum $=(2/3)^k$ to $<3\cdot10^{-15}$ for $k=1,2,3$ (27, 729, 19683 variables) |
| `c2_kwise_hash.py` | Exact $j$-wise uniformity ($j\le k$) of the lowest bit of degree-$<k$ polynomial hashing over $\mathrm{GF}(2^m)$, all seeds, all point sets, all labellings | $(m,k)\in\{(3,2),(3,3),(4,2),(4,3)\}$: every count equals $2^{mk-j}$ |
| `c3_normalisation_order.py` | Semimeasure vs normalised probability of the same data in every reveal order, exact rationals | $\rho_1$: semimeasure $1/4$ in both orders; normalised $2/3$ vs $1/2$. $\rho_2$ (3 inputs): semimeasure $1/5$ in all 6 orders; normalised ranges over $1/4,1/2,4/7,2/7,5/8$; normalised $\ge$ semimeasure throughout |
| `c4_finite_mixture_merging.py` | For a 7-law mixture on 4 inputs (deterministic, product, shared-randomness, uniform laws): pathwise dominance; order independence over all 24 orders; maximum over **all** adaptive input rules (dynamic programming) of the expected summed KL, for horizons 1–4 | Spread of cumulative loss across orders $\le1.8\cdot10^{-15}$; all pathwise maxima and all adaptive maxima below $-\log_2w$; at horizon 4 the maximum equals $\mathbb E\log_2\nu(F)/M(F)$ for every law |
| `c5_repeated_inputs.py` (seed 20261011) | Probability that i.i.d. pairs with fresh $\mathrm{Bern}(p)$ labels stay consistent, exact (generating function) and Monte Carlo (20000 runs) | E.g. $m=10$, $p=1/2$: $0.95$ at $n=2$, $0.113$ at $n=10$, $5\cdot10^{-4}$ at $n=20$; Monte Carlo agrees to within sampling error |
| `c6_moebius_and_sequential.py` (seed 20261011) | (a) Möbius sums equal $P(F\supseteq D,\ F=\bot\text{ on }T)$ for 200 random laws on 3 inputs with 3 labels; (b) sequential sampling of a weak semimeasure on a fixed domain reproduces it on full-domain data sets and is $\le$ on sub-domains ($\tau$ and 200 random weak semimeasures) | (a) maximum discrepancy $0$ (exact rationals); (b) all identities hold; for $\tau$, 5 data sets have strict inequality on sub-domains, as expected |

All six scripts were rerun after the last edits to their docstrings; the six output files were byte-identical to the previous run.

**Proof checks done in this track (self-checks; no external referee yet).**
* Prop 2.3: the consistency identity $q_{S\cup\{x\}}(v,\bot)=q_S(v)-\sum_aq_{S\cup\{x\}}(v,a)$ was re-derived by splitting on $x\in\mathrm{dom}\,E$; c6(a) checks the necessity direction numerically.
* Thm 3.5(iii): the construction rests on (1) weakness of $\tau^{\otimes k}$, (2) pairwise inconsistency of the $E_{\vec\imath}$, (3) disjointness of the events for any random function. (1) and (2) are checked by c1 for $k\le2$ and follow in general from the product structure (a one-point inequality involves one block). The LP confirms that the bound $(2/3)^k$ is attained, so the proof is not losing a factor for small $k$.
* Prop 4.5: the three estimates (tail $\le\varepsilon$, $I_0$ terms $\le r^k$, $I_1$ terms $\le e^\delta-1$) were re-checked; the identity $\sum_b\nu_{P_i}(D_b)=\prod_j(s_i(n_j,0)+s_i(n_j,1))$ uses that all $D_b$ share one domain.
* Prop 6.8: the closed form for the probability that the labels at $x_0$ agree was re-derived; c5 confirms the overall consistency probability for uniform $\pi$ (exact vs Monte Carlo).
* Thm 6.5 and Thm 6.7: the identity "sum of conditional KLs = expected log-ratio" is checked exactly, for all adaptive input rules, on the finite mixture in c4.
* Things I did not check by computer: Lemma 3.1, Thm 3.2, Prop 3.3, Thm 3.4 (standard constructions, written out in full above); Prop 4.3 and Prop 7.3 (short diagonal and pigeonhole arguments).

**References used, and their verification status.** None could be opened (arxiv.org, journal sites and similar are unreachable here; WebSearch gives snippets). All are therefore **unverified** against the source, except where a snippet confirmed the bibliographic data, as noted.
* R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008. Snippets confirm the title, venue and the "unordered sets of ordered pairs" third kind; that it is the mixture of product operators is my reading, to be checked.
* R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Trans. Inf. Theory* 24(4):422–432, 1978.
* A. K. Zvonkin, L. A. Levin, "The complexity of finite objects and the development of the concepts of information and randomness by means of the theory of algorithms", *Russian Math. Surveys* 25(6):83–124, 1970. Snippets confirm that lower-semicomputable semimeasures are exactly the output distributions of monotone machines.
* P. Gács, "On the relation between descriptional complexity and algorithmic probability", *Theoret. Comput. Sci.* 22:71–93, 1983. Snippets confirm that $Km-KM$ is unbounded.
* M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., Springer 2008 (coding theorem, symmetry of information, monotone machines; section numbers unverified).
* M. Hutter, *Universal Artificial Intelligence*, Springer 2005 (chronological semimeasures).
* J. Leike, M. Hutter, "On the computability of Solomonoff induction and knowledge-seeking", ALT 2015.
* A. Blumer, A. Ehrenfeucht, D. Haussler, M. Warmuth, "Occam's razor", *Inf. Process. Lett.* 24:377–380, 1987.
* D. McAllester, "Some PAC-Bayesian theorems", *Machine Learning* 37:355–363, 1999.
* A. Barron, T. Cover, "Minimum complexity density estimation", *IEEE Trans. Inf. Theory* 37(4):1034–1054, 1991; A. Barron, "Information-theoretic characterization of Bayes performance and the choice of priors in parametric and nonparametric problems", *Bayesian Statistics* 6, 1998.
* V. Vovk, "Aggregating strategies", COLT 1990; N. Cesa-Bianchi, G. Lugosi, *Prediction, Learning, and Games*, Cambridge 2006.
* N. Littlestone, "Learning quickly when irrelevant attributes abound", *Machine Learning* 2:285–318, 1988; N. Littlestone, "From on-line to batch learning", COLT 1989; N. Cesa-Bianchi, A. Conconi, C. Gentile, "On the generalization ability of on-line learning algorithms", *IEEE Trans. Inf. Theory* 50(9):2050–2057, 2004.
* J. Barzdin, R. Freivalds, "On the prediction of general recursive functions", *Soviet Math. Doklady* 13, 1972.
* M. Wegman, J. L. Carter, "New hash functions and their use in authentication and set equality", *J. Comput. Syst. Sci.* 22:265–279, 1981 (polynomial $k$-wise independent hashing; the property used is proved in Prop 4.4 and computed in c2, so nothing depends on this citation).
* Choquet, Matheron, Shafer for completely monotone set functions (analogy only, Prop 2.3 remark).

**Relation to the brief's hypotheses (summary of verdicts).**
* H1(a): universal element exists; "equivalently machines" refuted for the weak definition, open for random-function laws.
* H1(b): $W$ and $2^{-K_F}$ are not within a constant of $M_F$; the gap is between unbounded and $K(\mathrm{dom}\,D)+O(1)$; for fair-coin labels the hint "log factor via $k$-wise hashing" is confirmed, giving $K(n,k)+O(1)$.
* H1(c): $M_{\rm prod}$ lies strictly between $W$ and $M_F$.
* H2: proved for machine laws pathwise; needs consistent labels; needs $+K(\mathrm{dom}\,D)$ for weak comparators.
* Invariance: proved with constant $K(\alpha,\beta)+O(1)$.
* (iii): correct form is Thm 6.3; the $K(y_D\mid\mathrm{dom}\,D)$ upper bound holds but can be loose by $\approx n$ bits.
* (iv): proved (Thm 6.5, Cor 6.6).
* H7: proved for deterministic labels and for stamped or frozen noise; refuted for plain i.i.d. noisy pairs.
