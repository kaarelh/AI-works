# A. Generalization bounds for the discrete circuit-growth model

Notes by Claude (Opus 5.5), prompted by Kaarel Hänni. Research note, 23 October 2026. Not reviewed by a human.

**Question (from the user).** *"Try to see if you can get some generalization bounds for this. I guess I can see how one would have a result saying that you get good generalization if training hasn't taken too long because the circuit cannot have grown that big yet, and then one has a Chernoff guarantee for all small circuits that their train and test loss are similar? Here we could imagine doing full batch but with a train/test split, or SGD; either should make sense."*

**Status labels.** These follow [`neural-network-generalization/`](../../neural-network-generalization/TECHNICAL-FAQ.md):
- **Proved:** a complete proof with explicit constants is in this file. "Proved (given L1–L3)" means the proof is complete apart from three cited textbook lemmas.
- **Literature:** a published result. "(from memory)" means I could not check the text.
- **Heuristic:** an informed expectation, or a modelling claim.
- **Conjecture**, **Numerical:** as usual.

Scripts and their outputs are in [`checks/`](checks/).

## Summary

The user's picture is right in outline. The Chernoff step works as hoped (item 1). The correction is about what "the circuit cannot have grown that big yet" can mean (item 2).

1. **The Chernoff/Occam part works with no assumptions on the dynamics.** Gate choices may depend arbitrarily on the training data, and the bound holds for every circuit size $T$ at once (Theorem A1). With zero training error, the test error is at most about
   $$\frac{T\,(\log|G| + k\log(d+T)) + T^2\log 2 + \log\frac{(T+1)(T+2)}{\delta}}{n}.$$
   For the toy library below ($d=30$, fan-in 2, $|G|=6$) and $\delta=0.05$, this is below $0.1$ once $n\gtrsim 140\,T$ for $T\le 10$. That is non-vacuous at the experiment's sample sizes for circuits of up to about 20 gates.

2. **"Not too much training time" does *not* bound the number of gates.** In the race model, clocks persist, as they do in small-initialization gradient descent. Many candidates can then fire at once. For example, on $\mathrm{MAJ}_m$ with identity and AND/OR gates, $m^2$ gates fire together at time $\approx\Theta\sqrt{\pi m/2}$, where $\Theta=\log(1/\alpha)$ (Proposition A2.2). Training time does control three other quantities:
   - the **depth** of the circuit, $D(t)\le\tau(t)/\Theta$, unconditionally (Proposition A2.1);
   - the **number of gates times their incoherence**, $T(t)\le\kappa(t)\,(\tau(t)/\Theta)^2$, where $\kappa$ is the top eigenvalue of the active gates' Gram matrix. This is tight up to a factor $\pi/2$ (Theorem A2.3);
   - the **$\ell_1$ norm of the readout**, $\|c(t)\|_1\le\|R(t)\|_n/\Theta\le\tau(t)/\Theta$, for depth-one circuits with sign-consistent refits. This is the setting of diagonal linear networks (Theorem A2.4).

   Here $\tau(t)=\int_0^t\sqrt{2\hat L(s)}\,ds\le t$ is "effective time": time weighted by the root training loss. Combined with A1, these give generalization bounds that degrade with $t/\log(1/\alpha)$ (Corollary A2.5). The race itself is invariant under changes of $\alpha$ once time is measured in units of $\log(1/\alpha)$. So "training hasn't taken too long" means $t/\log(1/\alpha)$ is small.

3. **SGD.** With fresh minibatches there is no train/test gap to bound: the run *reproduces the population run* (Theorem A3.1, Lemma A3.2). The same stability argument also covers full-batch training on one sample. When the population run has utility gaps $\gamma$ and reaches an exact representation, it gives exact recovery from $n\approx T R^2\log(MT/\delta)/(\lambda_*\gamma^2)$ samples, which is a different mechanism from Occam. With minibatches drawn *with reuse* from a fixed training set, A1 applies. In addition, the losses on each point's *first* draw give an unbiased progressive-validation estimate of the test loss (Proposition A3.4).

4. **Greedy versus minimum-circuit learning.** The bound is the same function of $T$. The difference is which $T$ each learner reaches:
   - On targets that are library gates, the greedy circuit is minimal.
   - Ties and refits make it overshoot, by a factor $m$ on $\mathrm{MAJ}_m$ (Proposition A4.2). In the toy runs at zero training error: maj3 uses 6 gates (10 by the end) against at most 3; dnf3 uses 18 against at most 6.
   - Square-loss refits keep growing the circuit after the 0-1 training error reaches zero.
   - On $\chi_S$ with $|S|>k$ the population race never fires at all (Proposition A4.3), while the Occam learner succeeds with $O(|S|\log d)$ samples.

The [last section](#6-what-is-vacuous-and-what-is-open) lists what is vacuous at realistic sizes, and what is open.

| result | content | status |
|---|---|---|
| Lemma 1.1, 1.2, 1.3 | circuit count, threshold-readout count, Chernoff kl tail | Proved |
| Theorem A1 | Occam bound uniform over $T$: kl, Bernstein, Hoeffding, realizable | Proved |
| Theorem A1′ | margin and clipped-square-loss bound for $\ell_1$-bounded readouts | Proved (given L1–L3) |
| Proposition A2.1 | depth $\le \tau/\Theta$ | Proved |
| Proposition A2.2 | no time-only bound on the gate count; tight examples | Proved |
| Theorem A2.3 | $T\le\kappa\,(\tau/\Theta)^2$ | Proved |
| Theorem A2.4 | $\Theta\lVert c\rVert_1=\langle R,f\rangle_n\le\lVert R\rVert_n$ (depth 1, sign-consistent) | Proved |
| Corollary A2.5 | test error as a function of training time | Proved (count version); Proved given L1–L3 (norm version) |
| Proposition A2.6 | no gate fires before $t\approx\Theta\sqrt{n/(8\log M)}$ on parity-like targets | Proved |
| Clock model ≈ small-init GD | faithfulness of the model | Literature (depth 1, from memory) / Heuristic (deeper) |
| Theorem A3.1 | decision stability: fresh-batch and full-batch reproduction of the population run | Proved |
| Lemma A3.2 | SGD clocks concentrate around drift clocks | Proved; numerically tight to within 25% |
| Proposition A3.3 | online-to-batch / progressive validation | Proved |
| Proposition A3.4 | multi-epoch reuse: first-occurrence validation; which bound applies | Proved |
| Propositions A4.1–A4.3 | greedy versus minimum circuit: equal, overshoot, never | Proved (population) |
| Section 5 | toy-model checks | Numerical |

---

## 0. Setting

**Data.** $\mathcal X=\{-1,1\}^d$. $P$ is any distribution on $\mathcal X\times\{-1,1\}$; the experiments use uniform $x$ and $y=f^*(x)$. The training sample $S=(x_i,y_i)_{i=1}^n$ is iid from $P$. Write $\langle u,v\rangle_n=\frac1n\sum_i u(x_i,y_i)v(x_i,y_i)$, with norm $\|\cdot\|_n$, and $\mathrm{err}(h)=P(h(x)\ne y)$, with $\widehat{\mathrm{err}}$ its empirical version. All logarithms are natural.

**Template.** This is the model shape the bounds assume.
- A **library** $G$ is a finite set of gate functions $\phi:[-1,1]^j\to[-1,1]$ of arity $j\le k$. In the Boolean case $\phi:\{-1,1\}^j\to\{-1,1\}$.
- A **circuit with $T$ gates** is a list $(\phi_t,\iota_t)_{t=1}^T$, where $\phi_t\in G$ has arity $j_t$ and $\iota_t\in\{1,\dots,d+t-1\}^{j_t}$ names its sources. Indices $1..d$ are inputs and $d+s$ is gate $s$. Gate $t$ computes $g_t(x)=\phi_t(w_{\iota_{t,1}}(x),\dots)$.
- A **predictor** is $h=\psi(g_1,\dots,g_T)$ with $\psi$ in a readout class:
  - **sign readout:** $\psi(z)=\mathrm{sgn}(c_0+c\cdot z)$, with a fixed convention for $\mathrm{sgn}(0)$;
  - **output gate:** $\psi(z)=\pm z_T$;
  - **real readout:** $c_0+c\cdot z$, possibly clipped to $[-1,1]$.
- A **learner** is any rule, possibly randomized, that maps the sample to a sequence of circuits and readouts. It may be greedy, a race, refit by least squares, or anything else. Nothing below uses the selection rule except Sections 2–4.

Let $\mathcal W_T$ be the set of circuits with $T$ gates, and $\mathcal H_T$ the set of predictors $\psi\circ(g_1,\dots,g_T)$ built on them.

---

## 1. A1: full batch with a train/test split

### Lemma 1.1 (counting circuits) — Proved

$$\log|\mathcal W_T|\;\le\;W_T:=\sum_{t=1}^T\bigl(\log|G|+k\log(d+t-1)\bigr)\;\le\;T\bigl(\log|G|+k\log(d+T-1)\bigr).$$

*Proof.* Gate $t$ has at most $|G|$ choices of function and at most $(d+t-1)^{k}$ choices of an ordered source tuple. Multiply over $t$. ∎

*Refinements.* The count is of ordered descriptions, so a circuit whose gates can be built in many orders is overcounted. For example, $T$ gates that all read inputs are overcounted by $T!$, and dividing by $T!$ saves $\log T!\approx T\log T$. Symmetric gates save a further $\log j!$ each. I do not use these refinements.

### Lemma 1.2 (counting threshold readouts) — Proved

Let $Z\subset\mathbb R^T$ have $N$ points. The number of functions on $Z$ of the form $z\mapsto\mathrm{sgn}(c_0+c\cdot z)$, with either fixed convention for $\mathrm{sgn}(0)$, is at most
$$\Phi(N,T):=2\sum_{i=0}^{T}\binom{N-1}{i}\;\le\;2N^{T}.$$
For Boolean gates, $Z=\{-1,1\}^T$ and this is at most $2\cdot 2^{T^2}$. For real-valued gates, $Z$ is the image of $\mathcal X$, so $N\le 2^d$ and the count is at most $2\cdot 2^{dT}$.

*Proof.*
1. *Strict separation.* Write $\tilde z=(1,z)\in\mathbb R^{T+1}$ and $w=(c_0,c)$. Suppose $\mathrm{sgn}(0)=-1$. Let $\epsilon$ be smaller than every positive value of $w\cdot\tilde z$ on $Z$, and put $w'=w-\epsilon e_0$. Then $w'\cdot\tilde z\ne0$ on $Z$, and $\mathrm{sgn}(w'\cdot\tilde z)=\mathrm{sgn}(w\cdot\tilde z)$ there. For the convention $\mathrm{sgn}(0)=+1$, use $+\epsilon$ instead. So it suffices to count *strict* sign patterns $(\mathrm{sgn}(w\cdot v_j))_{j\le N}$, where $w\cdot v_j\neq0$ for all $j$, of $N$ vectors $v_j$ in $\mathbb R^D$ with $D=T+1$.
2. *Recursion.* Let $C(N,D)$ be the largest number of strict patterns of $N$ vectors in $\mathbb R^D$. Each strict pattern of $v_1,\dots,v_{N+1}$ restricts to a strict pattern $\sigma'$ of $v_1,\dots,v_N$, and each $\sigma'$ extends in at most two ways. Suppose $\sigma'$ extends in two ways, by $w_+$ with $w_+\cdot v_{N+1}>0$ and by $w_-$ with $w_-\cdot v_{N+1}<0$. The set of $w$ realizing $\sigma'$ strictly is an intersection of open half-spaces, hence convex. So the segment $[w_+,w_-]$ lies in it, and contains a point $w_0$ with $w_0\cdot v_{N+1}=0$. Then $w_0\in H:=v_{N+1}^\perp$, and $w_0\cdot v_j=w_0\cdot\Pi_Hv_j$, where $\Pi_H$ is orthogonal projection onto $H$. So $\sigma'$ is a strict pattern of the $N$ vectors $\Pi_Hv_j$ in the $(D-1)$-dimensional space $H$. Hence $C(N+1,D)\le C(N,D)+C(N,D-1)$.
3. *Base cases.* $C(1,D)\le2$, and $C(N,1)\le2$, since in dimension one the pattern is determined by $\mathrm{sgn}(w)$.
4. *Solution.* By Pascal's rule, $\Phi(N,D-1)=2\sum_{i<D}\binom{N-1}{i}$ satisfies the same recursion with equality and the same base values. Induction on $N+D$ gives $C\le\Phi$.
5. *Simplification.* For $i\le T$, $\binom{M}{i}\le M^i\le\binom Ti M^i$, so $\sum_{i\le T}\binom Mi\le(1+M)^T$. ∎

This is the upper half of Cover's (1965) function-counting theorem. **Numerical:** brute force by linear programming gives the exact counts 4, 14, 104, 1882 for $T=1,\dots,4$, against $\Phi=4,14,128,3882$ ([`checks/lemma_checks.txt`](checks/lemma_checks.txt)). The exact counts agree with OEIS A000609.

Define $\rho_T:=\log\Phi(2^{\min(T,d)},T)$ for Boolean gates. For real-valued gates, use $\rho_T:=\log\Phi(2^d,T)$. For an output-gate readout, use $\rho_T:=\log 2$. Then
$$\log|\mathcal H_T|\le W_T+\rho_T .$$

### Lemma 1.3 (Chernoff tail in kl form) — Proved

Let $\hat p$ be the mean of $n$ iid Bernoulli($p$) variables, and let $0\le q\le p$. Then $P(\hat p\le q)\le e^{-n\,\mathrm{kl}(q\|p)}$, where $\mathrm{kl}(q\|p)=q\log\frac qp+(1-q)\log\frac{1-q}{1-p}$. Moreover:
- $\mathrm{kl}(q\|p)\ge\frac{(p-q)^2}{2p}$ for $q\le p$;
- $\mathrm{kl}(q\|p)\ge2(p-q)^2$ (Pinsker);
- $\mathrm{kl}(0\|p)=-\log(1-p)\ge p$.

*Proof.*
- *Tail.* For $q=0$, $P(\hat p=0)=(1-p)^n=e^{-n\,\mathrm{kl}(0\|p)}$. For $0<q\le p$ and $\lambda\ge0$, Markov's inequality gives $P(\hat p\le q)\le e^{\lambda nq}\,\mathbb E e^{-\lambda n\hat p}=\exp\{n[\lambda q+\log(1-p+pe^{-\lambda})]\}$. Take $e^{-\lambda}=\frac{q(1-p)}{p(1-q)}\le1$. Then $1-p+pe^{-\lambda}=\frac{1-p}{1-q}$, and the exponent becomes $n[q\log\frac{p(1-q)}{q(1-p)}+\log\frac{1-p}{1-q}]=-n\,\mathrm{kl}(q\|p)$.
- *Quadratic lower bound.* Put $F(s)=\mathrm{kl}(s\|p)$. Then $F(p)=F'(p)=0$ and $F''(s)=\frac1{s(1-s)}\ge\frac1s\ge\frac1p$ for $s\le p$. So $F(q)=\int_q^p(s-q)F''(s)\,ds\ge\frac{(p-q)^2}{2p}$.
- *Pinsker* is standard: the same Taylor argument with $F''\ge4$.
- *Last item.* $-\log(1-p)\ge p$. ∎

### Theorem A1 (Occam bound, uniform over circuit size) — Proved

Fix $\delta\in(0,1)$ and put
$$L_T:=\log|\mathcal H_T|+\log\frac{(T+1)(T+2)}{\delta}\;\le\;W_T+\rho_T+\log\frac{(T+1)(T+2)}{\delta}.$$
With probability at least $1-\delta$ over $S$, **simultaneously for every $T\ge0$ and every $h\in\mathcal H_T$**, the following hold. Write $p=\mathrm{err}(h)$ and $\hat p=\widehat{\mathrm{err}}(h)$.
1. If $\hat p\le p$, then $\mathrm{kl}(\hat p\|p)\le L_T/n$.
2. $p\le\hat p+\sqrt{2\hat pL_T/n}+2L_T/n$ (Bernstein form).
3. $p\le\hat p+\sqrt{L_T/(2n)}$ (agnostic).
4. If $\hat p=0$, then $p\le1-e^{-L_T/n}\le L_T/n$ (realizable).

The learner's output after $T(S)$ gates lies in $\mathcal H_{T(S)}$ however the gates were chosen. So the four bounds hold for the learner at every stage and every training time, with $T$ the current number of distinct gates in use.

*Proof.*
1. *One fixed $h$.* Fix $h$ with error $p$, and let $\epsilon>0$. The set $\{q\in[0,p]:\mathrm{kl}(q\|p)>\epsilon\}$ is an interval $[0,q^*)$, because kl is decreasing in $q$ on $[0,p]$. By Lemma 1.3,
   $$P\bigl(\hat p\le p,\ \mathrm{kl}(\hat p\|p)>\epsilon\bigr)=P(\hat p<q^*)\le\lim_{q\uparrow q^*}e^{-n\,\mathrm{kl}(q\|p)}= e^{-n\epsilon}.$$
2. *Union bound.* Take $\epsilon=L_T/n$, so that $e^{-n\epsilon}=\delta/\bigl((T+1)(T+2)|\mathcal H_T|\bigr)$. A union bound over $h\in\mathcal H_T$ and then over $T$ costs at most $\sum_{T\ge0}\delta/((T+1)(T+2))=\delta$. This gives item 1.
3. *Item 2.* Lemma 1.3 gives $p-\hat p\le\sqrt{2pL_T/n}$. Put $u=\sqrt p$ and $a=\sqrt{2L_T/n}$. Then $u^2-au-\hat p\le0$, so $u\le(a+\sqrt{a^2+4\hat p})/2$. Hence $p\le\hat p+a^2/2+\tfrac a2\sqrt{a^2+4\hat p}\le\hat p+a^2+a\sqrt{\hat p}$.
4. *Items 3 and 4* follow from Pinsker and from $\mathrm{kl}(0\|p)=-\log(1-p)$. ∎

**Remarks.**
- **Duplicates.** Gates that compute the same function, or are never used, can be dropped without changing $h$. So $T$ may be taken as the number of distinct gate functions that are used, either as sources or with nonzero readout weight.
- **Where the $T^2$ comes from.** The term $\rho_T\approx T^2\log2$ is the price of an arbitrary real threshold readout. An alternative replaces it by $\log\Phi(2n,T)\approx T\log(2n)$, the number of readouts on the *sample*. That needs the symmetrization lemma: for instance $P(\exists h:\hat p=0,\ p>\epsilon)\le2\Pi_{\mathcal H}(2n)2^{-\epsilon n/2}$ (Blumer–Ehrenfeucht–Haussler–Warmuth, JACM 1989, Theorem A2.1; **Literature, from memory**), with growth function $\Pi_{\mathcal H_T}(2n)\le|\mathcal W_T|\,\Phi(2n,T)$ by Lemma 1.2. Its constants are worse, and the self-contained $T^2$ version is smaller whenever $T\lesssim\log_2(2n)$. At the experiment's sizes ($n\le 16384$) that means up to about 15 gates.
- **Nothing about the dynamics was used.** The bound covers a greedy race, a minimum-circuit learner, or anything else. In the language of [`neural-network-generalization`](../../neural-network-generalization/TECHNICAL-FAQ.md#can-we-bound-the-total-number-of-mistakes-during-learning), $L_T$ is the log-cardinality "$h$" of the relevant family. Sections 2–4 concern which $T$ a given learner reaches.

**Specialization (Numerical table, [`checks/lemma_checks.txt`](checks/lemma_checks.txt)).** Take $d=30$, $k=2$, $|G|=6$ (identity, four AND-types, XOR, up to negation) and $\delta=0.05$. The table gives the realizable bound (item 4, kl form) on the test error:

| $T$ | $L_T$ (nats) | $n=64$ | $n=256$ | $n=1024$ | $n=4096$ | $n=16384$ | $n$ for bound $\le0.1$ |
|---|---|---|---|---|---|---|---|
| 1 | 14.8 | 0.21 | 0.056 | 0.014 | 0.004 | 0.001 | 141 |
| 3 | 36.8 | 0.44 | 0.13 | 0.035 | 0.009 | 0.002 | 350 |
| 6 | 78.4 | 0.71 | 0.26 | 0.074 | 0.019 | 0.005 | 744 |
| 10 | 151 | 0.91 | 0.45 | 0.14 | 0.036 | 0.009 | 1438 |
| 20 | 427 | 1.00 | 0.81 | 0.34 | 0.099 | 0.026 | 4055 |
| 30 | 840 | 1.00 | 0.96 | 0.56 | 0.19 | 0.050 | 7974 |

With $|G|=16$ (all two-input Boolean functions), $L_T$ grows by $T\log(16/6)\approx T$ nats, which is less than 9%, and each entry by about as much. The agnostic gap $\sqrt{L_T/2n}$ is much larger. For example, at $T=5$ it is 0.35 at $n=256$ and 0.088 at $n=4096$.

### Theorem A1′ (real-valued readouts with an $\ell_1$ constraint) — Proved (given L1–L3)

Let $\mathcal F$ be a finite set of functions $\mathcal X\to[-1,1]$. Natural choices:
- $\mathcal F_1$, all depth-one gates, with $|\mathcal F_1|\le|G|d^k$;
- $\mathcal F_{\le T}$, all functions computed by some gate of some circuit with at most $T$ gates. Every such gate is the top gate of its ancestor sub-circuit, so $|\mathcal F_{\le T}|\le T|\mathcal W_T|$.

For $B\ge0$, let $\mathcal A_B:=\{c_0+\sum_jc_jg_j:\ g_j\in\mathcal F,\ |c_0|\le 1+B,\ \sum_j|c_j|\le B\}$.

Two losses are used:
- the **clipped square loss** $\ell_{\rm sq}(f;x,y)=\frac12(\mathrm{clip}_{[-1,1]}f(x)-y)^2\in[0,2]$. It is 2-Lipschitz in $f(x)$, and $\mathrm{err}(\mathrm{sgn}f)\le2\,\mathbb E\ell_{\rm sq}$;
- the **ramp loss** $\varphi_\theta(u)=\min\{1,\max\{0,1-u/\theta\}\}$, which is $1/\theta$-Lipschitz and satisfies $\mathbb 1[u\le0]\le\varphi_\theta(u)\le\mathbb 1[u<\theta]$.

Let $B_j=2^j$ and $\pi_j=1/((j+1)(j+2))$, and put
$$\mathfrak R_n(B):=\frac{1+B}{\sqrt n}+B\sqrt{\frac{2\log(2|\mathcal F|)}{n}} .$$
With probability at least $1-\delta$, for all $j\ge0$ and all $f\in\mathcal A_{B_j}$:
$$\mathbb E\ell_{\rm sq}(f)\le\hat{\mathbb E}\ell_{\rm sq}(f)+4\,\mathfrak R_n(B_j)+2\sqrt{\frac{\log(1/(\pi_j\delta))}{2n}},$$
$$\mathrm{err}(\mathrm{sgn}f)\le\hat{\mathbb E}\varphi_\theta(yf)+\frac2\theta\,\mathfrak R_n(B_j)+\sqrt{\frac{\log(1/(\pi_j\delta))}{2n}}\qquad(\theta\text{ fixed in advance}).$$
A predictor with $\sum_j|c_j|=B$ and $|c_0|\le1+B$ lies in $\mathcal A_{B_j}$ with $B_j\le2\max(B,1)$. To make the bound uniform in $T$ for $\mathcal F_{\le T}$, add $\log((T+1)(T+2))$ to $\log(1/(\pi_j\delta))$.

*Cited lemmas* (all **Literature**, from memory, standard):
- **L1** (uniform deviation). For a class $\mathcal G$ of $[0,M]$-valued functions, with probability at least $1-\delta$, every $g\in\mathcal G$ satisfies $\mathbb Eg\le\hat{\mathbb E}g+2\mathfrak R_n(\mathcal G)+M\sqrt{\log(1/\delta)/(2n)}$. Sources: Bartlett–Mendelson, JMLR 2002, Theorem 8; Mohri–Rostamizadeh–Talwalkar, *Foundations of ML* (2nd ed. 2018), Theorem 3.3.
- **L2** (contraction). If each $\phi_i$ is $\ell$-Lipschitz, then $\hat{\mathfrak R}(\{(\phi_i(f(x_i)))_i\})\le\ell\,\hat{\mathfrak R}(\{(f(x_i))_i\})$. Sources: Ledoux–Talagrand 1991, Theorem 4.12; MRT Lemma 5.7.
- **L3** (Massart, and convex hulls). For a finite set $A\subset[-1,1]^n$, $\hat{\mathfrak R}(A)\le\sqrt{2\log|A|/n}$, and taking the convex hull does not change $\hat{\mathfrak R}$. Sources: MRT Theorem 3.7 and Lemma 7.4.

*Proof.* We have $\mathcal A_B\subseteq\{c_0:|c_0|\le1+B\}+B\,\mathrm{conv}(\mathcal F\cup-\mathcal F)$. The constants contribute $(1+B)\,\mathbb E|\sum_i\sigma_i|/n\le(1+B)/\sqrt n$. By L3, the hull contributes at most $B\sqrt{2\log(2|\mathcal F|)/n}$. Apply L2 with Lipschitz constant 2 or $1/\theta$, then L1 with $M=2$ or $1$, at confidence $\pi_j\delta$, and take a union over $j$. ∎

This is the bound that training time controls directly, through Theorem A2.4. It does not care how many gates are active. Its constants are poor: in Section 5 it gives 0.5–0.8 for $\mathbb E\ell_{\rm sq}$ at $n=4096$, whereas Theorem A1 gives about 0.03 for the 0-1 error of the same predictors.

---

## 2. A2: the training-time version

### 2.1 The clock race

**Definition 2.1 (clock race).** Fix a threshold $\Theta>0$; for $k=2$ attach moves, $\Theta=\log(1/\alpha)$ up to a constant that depends on the parametrization. At time $t\ge0$ the state consists of:
- the set $A(t)$ of *fired* gates, which forms a circuit;
- a readout $c(t)$;
- the training residual $r(t)=y-f_t$ (an $n$-vector), where $f_t=c_0(t)+\sum_{m\in A(t)}c_m(t)g_m$.

The dynamics:
- **Candidates.** A candidate is a gate $(\phi,\iota)$ with $\phi\in G$ whose sources are inputs or fired gates. Its *availability time* $a_m$ is the latest firing time among its gate sources, or $0$ if it reads only inputs.
- **Utility and clock.** $U_m(t)=\langle r(t),g_m\rangle_n$, and $S_m(t)=\int_{a_m}^tU_m(s)\,ds$.
- **Firing.** A candidate fires the first time $|S_m(t)|=\Theta$, with orientation $\sigma_m=\mathrm{sgn}\,S_m$. Any number may fire at the same instant. Clocks are never reset.
- **Refit**, in one of two variants:
  - **(LS)** $c(t)$ is a least-squares minimizer, with free intercept, over all fired gates. Any depth is allowed.
  - **(SC)**, for a depth-one dictionary only (every candidate reads inputs). The readout is supported on the saturated set $\mathrm{Sat}(t)=\{m:|S_m(t)|=\Theta\}$. On it, $c(t)$ minimizes the empirical square loss subject to $\sigma_mc_m\ge0$, and $c_m=0$ off it. A saturated gate whose clock moves back inside $(-\Theta,\Theta)$ is dormant again.

Between events $r$ is constant, so clocks are linear in $t$. We also use

$$\tau(t):=\int_0^t\|r(s)\|_n\,ds=\int_0^t\sqrt{2\hat L(s)}\,ds,\qquad R(t):=\int_0^tr(s)\,ds\in\mathbb R^n .$$

$\tau$ is *effective time*: time weighted by the root training loss.

**Lemma 2.2 (basic facts) — Proved.**
1. $|U_m(t)|\le\|r(t)\|_n\le\|y-\bar y\|_n\le1$. Hence $\tau(t)\le t$.
2. In (LS), every fired gate has $U_m(s)=0$ for all $s$ after its firing time $t_m$. Hence $S_m(t)=\sigma_m\Theta$ for all $t\ge t_m$.
3. In (SC), $c_m(t)\ne0$ implies $S_m(t)=\mathrm{sgn}(c_m(t))\,\Theta$, and also $U_m(t)=0$. For a saturated gate with $c_m=0$, $\sigma_mU_m\le0$. Hence $|S_m(t)|\le\Theta$ for every candidate at all times.
4. *Scale invariance.* Running the race with threshold $\lambda\Theta$ gives the state at time $\lambda t$ that threshold $\Theta$ gives at time $t$.

*Proof.*
1. $|g_m|\le1$, so $|\langle r,g_m\rangle_n|\le\|r\|_n$. The refit $f_t$ is the projection of $y$ onto a closed convex set that contains the constants, so it is at least as close to $y$ as $\bar y$ is.
2. These are the normal equations of least squares.
3. This is the definition of (SC) together with the KKT conditions. Where the constraint is inactive the gradient vanishes. Where it is active ($c_m=0$), moving $c_m$ in the allowed direction cannot decrease the loss, which gives $\sigma_mU_m\le0$.
4. The slopes $U_m$ do not depend on $\Theta$. ∎

Item 4 means that **$\alpha$ only sets the unit of time.** Every statement below depends on $t$ and $\alpha$ only through $t/\log(1/\alpha)$.

**Faithfulness to small-initialization GD.**
- **Depth one, 2-homogeneous units — Literature, partly from memory.** Take a diagonal linear network $f=\sum_m u_mv_mg_m$ over a fixed finite dictionary, initialized at scale $\alpha$, and train it by gradient flow on the empirical square loss. Pesme–Flammarion (NeurIPS 2023) show that as $\alpha\to0$, with time rescaled by $\log(1/\alpha)$, the trajectory converges to a piecewise-constant saddle-to-saddle process. That process is given by a LARS-like recursion and ends at the minimum-$\ell_1$ interpolator; this part was checked at abstract level. My recollection is that the recursion is exactly the (SC) race. The accumulated negative gradients play the role of $S_m$ and stay in $[-\Theta,\Theta]$, and each saddle minimizes the loss under the sign constraints. I could not open the paper to confirm the exact form.
- **Two-layer networks with learned directions — Literature, from memory.** In Alternating Gradient Flows (Kunin et al., NeurIPS 2025), dormant neurons accumulate utility and activate when it reaches a threshold proportional to $\log(1/\alpha)$. Accumulated utility is carried across jumps, not reset.
- **Deeper attach moves — Heuristic** ([README](../README.md) §1). The availability time $a_m$ models the fact that a unit reading a dormant wire receives almost no gradient.
- **Fresh chains** ($k\ge3$ new layers) can be added as candidates with threshold $\Theta_k\gtrsim\alpha^{-(k-2)}\gg\Theta$. A chain adds up to $k-1$ gates and $k-1$ levels in one move. Proposition A2.1 then holds in the form depth $\le(k-1)\tau/\Theta$. Theorem A2.3 bounds the number of *moves*, with each chain's output gate as its feature, and $T\le(k-1)\times$(moves).

**Why not reset the clocks?** In a *reset race*, every dormant clock returns to $0$ after each event, and one gate fires per event. Then $T(t)\le\tau(t)/\Theta$ trivially. But GD does not forget the growth of dormant units, so this model is not faithful. In particular it misses simultaneous growth, which Proposition A2.2 shows is generic.

### 2.2 What training time controls

**Proposition A2.1 (depth grows at most linearly in time) — Proved.** In either variant, a gate of depth $D$ fires only at times $t$ with $\tau(t)\ge D\Theta$. Here depth counts the gates on the longest path from the inputs. Consequently the depth of the circuit at time $t$ is at most $\lfloor\tau(t)/\Theta\rfloor\le\lfloor t/\Theta\rfloor$. In (LS), the number of events up to time $t$ is finite.

*Proof.* Use induction on $D$. A gate $m$ fires at $t_m$ with $\Theta=|S_m(t_m)|\le\int_{a_m}^{t_m}\|r\|_n=\tau(t_m)-\tau(a_m)$.
- If $D=1$, then $a_m=0$.
- If $D\ge2$, some source of $m$ has depth $D-1$ and fired at a time no later than $a_m$. By induction $\tau(a_m)\ge(D-1)\Theta$.

Finiteness of events: only finitely many syntactic gates have depth at most $t/\Theta$, every event fires at least one new gate, and in (LS) gates never unfire. ∎

**Proposition A2.2 (training time does not bound the number of gates) — Proved.** Use the population race (inner products under $P$), uniform inputs, and $y=\mathrm{MAJ}(x_1,\dots,x_m)$ with $m$ odd. Let
$$u_m=\binom{m-1}{(m-1)/2}2^{-(m-1)}=\sqrt{\tfrac{2}{\pi m}}\,(1+o(1)).$$
1. If $G=\{\text{identity}\}$, the $m$ identity gates $x_1,\dots,x_m$ fire together at $t=\Theta/u_m$, and nothing fires earlier. So $T$ jumps from $0$ to $m\approx\frac2\pi(t/\Theta)^2$.
2. If $G=\{\text{identity},\ \mathrm{AND}(\pm a,\pm b),\ \mathrm{XOR}\}$ (the toy library of Section 5), then exactly $m^2$ candidates fire together at $t=\Theta/u_m$. These are the $m$ identities, and $\mathrm{AND}(x_i,x_j)$ and $\mathrm{AND}(\neg x_i,\neg x_j)$ for each pair $i<j\le m$. So $T$ jumps to $m^2\approx(\frac2\pi)^2(t/\Theta)^4$.
3. Gates that compute the same function, such as $\mathrm{AND}(a,a)=a$, always fire together. So without merging duplicates, $T(t)$ is unbounded already at $t=\Theta$.

So with fan-in 2, $T$ can already grow like $(t/\Theta)^4$, and no bound $T\le C(t/\Theta)^2$ with $C$ independent of the library holds. A useful size bound must depend on how correlated the fired gates are, as in Theorem A2.3. The empirical race reproduces item 2: for maj3 at $n=4096$, 9 gates fire between $t/\Theta=1.98$ and $2.12$, against the population value $1/u_3=2$ (Section 5).

*Proof.* $\mathrm{MAJ}_m$ is odd, so $\mathbb E[y]=\mathbb E[yx_ix_j]=0$. Also $\mathbb E[yx_i]=P(\text{the other } m-1 \text{ votes tie})=u_m$ for $i\le m$, and $\mathbb E[yx_i]=0$ for $i>m$. As $\pm1$ functions, $\mathrm{AND}(\epsilon_1a,\epsilon_2b)=(\epsilon_1a+\epsilon_2b+\epsilon_1\epsilon_2ab-1)/2$ and $\mathrm{XOR}(a,b)=ab$. This gives the depth-one utilities at time $0$:

| candidate | utility |
|---|---|
| $x_i$, $i\le m$ | $u_m$ |
| $\mathrm{AND}(x_i,x_j)$, $\mathrm{AND}(\neg x_i,\neg x_j)$, $i,j\le m$ | $\pm u_m$ |
| $\mathrm{AND}(x_i,\neg x_j)$ | $0$ |
| AND-type with exactly one relevant input | $\pm u_m/2$ |
| XOR, or no relevant input | $0$ |

The residual stays equal to $y$ until the first event. So exactly $m+2\binom m2=m^2$ clocks reach $\Theta$ at $t=\Theta/u_m$, when every other clock is at most $\Theta/2$. The asymptotics of $u_m$ follow from Stirling's formula. ∎

**Theorem A2.3 (gate count times incoherence) — Proved.** Use the (LS) variant, at any depth. For a set $B$ of fired gates, let $K_B$ be the centred empirical Gram matrix, $(K_B)_{mm'}=\langle g_m-\bar g_m,g_{m'}-\bar g_{m'}\rangle_n$, and let $\kappa_B=\lambda_{\max}(K_B)$. Then at every time $t$
$$|B|\;\le\;\kappa_B\Bigl(\frac{\tau(t)}{\Theta}\Bigr)^2,\qquad\text{in particular}\qquad T(t)\le\kappa(t)\Bigl(\frac{\tau(t)}{\Theta}\Bigr)^2 .$$
Gershgorin's theorem gives $\kappa\le1+(T-1)\mu$, where $\mu$ is the largest absolute centred empirical covariance between two fired gates. So whenever $\mu(\tau/\Theta)^2<1$,
$$T\le\frac{(1-\mu)(\tau/\Theta)^2}{1-\mu(\tau/\Theta)^2}.$$
The bound is tight up to the factor $\pi/2$: in Proposition A2.2(1) the identity gates are orthonormal, so $\kappa=1$, and $T=m$ while $(\tau/\Theta)^2=1/u_m^2\approx\pi m/2$.

*Proof.*
1. By Lemma 2.2(2), $\sigma_mS_m(t)=\Theta$ for each $m\in B$.
2. The intercept is refit, so $r(s)$ has empirical mean zero, and $\langle r(s),g_m\rangle_n=\langle r(s),\tilde g_m\rangle_n$ with $\tilde g_m=g_m-\bar g_m$.
3. Write $B(s)=\{m\in B:a_m\le s\}$. Then
$$|B|\,\Theta=\sum_{m\in B}\sigma_m\int_{a_m}^t\langle r(s),\tilde g_m\rangle_n\,ds=\int_0^t\Bigl\langle r(s),\sum_{m\in B(s)}\sigma_m\tilde g_m\Bigr\rangle_n ds\le\int_0^t\|r(s)\|_n\Bigl\|\sum_{m\in B(s)}\sigma_m\tilde g_m\Bigr\|_n ds .$$
4. $\|\sum_{m\in B(s)}\sigma_m\tilde g_m\|_n^2=\sigma^\top K_{B(s)}\sigma\le\lambda_{\max}(K_{B(s)})\,|B(s)|\le\kappa_B|B|$, because a principal submatrix has no larger top eigenvalue.
5. Hence $|B|\Theta\le\tau(t)\sqrt{\kappa_B|B|}$, which rearranges to the claim. ∎

In the toy runs of Section 5, $\kappa\in[0.7,3.1]$ and the bound is loose by a factor of 1.5 to 5.

**Theorem A2.4 (the readout's $\ell_1$ norm grows at most linearly in time) — Proved.** Use the (SC) variant on a depth-one dictionary. For every $t$,
$$\Theta\sum_m|c_m(t)|\;=\;\langle R(t),f_t\rangle_n\;\le\;\|R(t)\|_n\sqrt{1-\bar y^2}\;\le\;\tau(t),\qquad |c_0(t)|\le1+\|c(t)\|_1 .$$

*Proof.*
1. All $a_m=0$, so $S_m(t)=\langle R(t),g_m\rangle_n$.
2. By Lemma 2.2(3), $c_mS_m(t)=|c_m|\Theta$ for every $m$, and this holds trivially when $c_m=0$.
3. $\langle R(t),1\rangle_n=\int_0^t\langle r(s),1\rangle_n\,ds=0$. Hence $\Theta\|c\|_1=\sum_mc_m\langle R,g_m\rangle_n=\langle R,f_t-c_0\rangle_n=\langle R,f_t-\bar y\rangle_n$.
4. The refit $f_t$ is the projection of $y$ onto the closed convex cone $\mathbb R\mathbf 1+\mathrm{cone}\{\sigma_m\tilde g_m:m\in\mathrm{Sat}\}$. Constants are orthogonal to centred vectors, so $f_t-\bar y$ is the projection of $y-\bar y$ onto a cone, and therefore $\|f_t-\bar y\|_n\le\|y-\bar y\|_n=\sqrt{1-\bar y^2}$.
5. Apply Cauchy–Schwarz, and $\|R(t)\|_n\le\int_0^t\|r\|_n=\tau(t)$.
6. Finally $c_0=\bar y-\sum_mc_m\bar g_m$. ∎

This is a LASSO-type duality. At the LASSO solution with penalty $\lambda$, $\|\beta\|_1=\langle r,X\beta\rangle/\lambda$; here the integrated residual $R(t)$ plays the role of $r$, and $\Theta$ the role of $\lambda$. It also explains why the race drifts toward the minimum-$\ell_1$ interpolant. **Numerical:** the identity holds to machine precision at every event of the (SC) runs in Section 5.

### 2.3 Test error as a function of training time

**Corollary A2.5 — Proved for (a); Proved given L1–L3 for (b).** Let $h_t=\mathrm{sgn}f_t$.
- **(a) Count version** ((LS), any depth). With probability at least $1-\delta$, simultaneously for all $t\ge0$, Theorem A1(2) holds for $h_t$ with
$$T(t)\le\Bigl\lfloor\kappa(t)\,\frac{\tau(t)^2}{\Theta^2}\Bigr\rfloor\quad\text{and depth}\le\frac{\tau(t)}{\Theta}.$$
$L_T$ is increasing in $T$, so $L_{T(t)}$ may be replaced by $L_{\lfloor\kappa\tau^2/\Theta^2\rfloor}$. At zero training error, for example,
$$\mathrm{err}(h_t)\le\frac{L_{\lfloor\kappa\tau^2/\Theta^2\rfloor}}{n}\approx\frac{\kappa\tau^2}{\Theta^2 n}\Bigl(\log|G|+k\log\bigl(d+\tfrac{\kappa\tau^2}{\Theta^2}\bigr)\Bigr)+\frac{\kappa^2\tau^4\log2}{\Theta^4n}.$$
- **(b) Norm version** ((SC), depth one, $|\mathcal F_1|\le|G|d^k$). With probability at least $1-\delta$, for all $t$, the two bounds of Theorem A1′ hold with $B_j\le2\max(1,\tau(t)/\Theta)$. The gap is therefore
$$O\Bigl(\bigl(1+\tfrac{\tau(t)}{\log(1/\alpha)}\bigr)\sqrt{\tfrac{\log(|G|d^k)}{n}}\Bigr),$$
linear in training time measured in units of $\log(1/\alpha)$, and independent of the number of gates.

*Proof.* Combine Theorem A1, Theorem A2.3 and Proposition A2.1 for (a), and Theorems A1′ and A2.4 for (b). Both A1 and A1′ hold on a single event uniformly in $T$ and $B_j$, and the predictor at every time lies in the class indexed by its current $T$ or $\|c\|_1$. ∎

So the user's statement holds in the race model, with "size" read as *depth*, *incoherent size* or *readout $\ell_1$ norm*, and "time" read as $\tau(t)/\log(1/\alpha)$. Training time does not control the raw gate count.

**Proposition A2.6 (no fitting of noise before $t\approx\Theta\sqrt n$ on parity-like targets) — Proved.** Suppose $\mathbb E[y]=0$ and $\mathbb E[yg]=0$ for every depth-one candidate $g$; for example, $y=\chi_S$ with $|S|>k$ under uniform inputs. Let $M_1$ be the number of depth-one candidates and
$$\epsilon=\sqrt{2\log(2(M_1+1)/\delta)/n}.$$
With probability at least $1-\delta$, no gate fires before time $\Theta/(2\epsilon)$. Until then the predictor is the constant $\mathrm{sgn}\,\bar y$, with test error $1/2$.

*Proof.* By Hoeffding's inequality and a union bound, $|\langle y,g_m\rangle_n|<\epsilon$ for all $m$ and $|\bar y|<\epsilon$, except with probability at most $2(M_1+1)e^{-n\epsilon^2/2}=\delta$. Before the first event $r=y-\bar y$, so $|U_m|=|\langle y,g_m\rangle_n-\bar y\,\bar g_m|<2\epsilon$. A firing needs $\Theta\le\int|U_m|<2\epsilon t$. ∎

**Heuristic: the early-stopping window.** A signal gate with population utility $u$ fires at $t\approx\Theta/u$. Noise gates fire at $t\approx\Theta/\max_m|\hat U_m-U_m|\approx\Theta\sqrt{n/(2\log 2M)}$. So the race has a clean window before it starts fitting noise exactly when $u\gg\sqrt{\log M/n}$, which is the correlational-SQ sample size. Corollary A2.5(a) becomes vacuous at about the same time: $T\approx\kappa(\tau/\Theta)^2\approx\kappa n/(2\log 2M)$ makes $L_T/n=\Omega(1)$. In this sense the time-based bound is sharp about *when* overfitting can start. Numerically, on par3 the first noise gate fires at $t/\Theta=2.65,\,5.16,\,9.97,\,20.0$ for $n=64,256,1024,4096$. The proved lower bound is $0.84,1.68,3.35,6.71$, and the heuristic is $1.95,3.91,7.81,15.6$.

**Recipe for the real runs (Heuristic).**
1. The saved training-loss curve gives $\tau(t)=\int\sqrt{2\hat L}\,dt$, with $t$ = learning rate × steps, after the per-layer multipliers.
2. The first jump of a Fourier coefficient of utility $U_1$, at time $t_1$, calibrates $\Theta\approx U_1t_1$.
3. Then $\tau(t)/\Theta$ along the run is the race model's "elapsed complexity budget". Comparing it with the measured depth and the readout or path norm tests Proposition A2.1 and Theorem A2.4 outside the toy.

---

## 3. A3: SGD, online learning, and reuse

With fresh minibatches, the useful statement is not a train/test comparison but **reproduction**: the stochastic run makes the same moves as the population run, so its test error *is* the population model's test error. The same argument also proves a stability bound for full-batch training on one sample, which is a second route to generalization besides Occam.

### 3.1 Decision stability for the greedy (argmax) model

**Population greedy run (PG).**
- Start from $C_0=\emptyset$.
- Given $C_t$, let $f_t$ be the $L^2(P)$ projection of $y$ onto $V_t=\mathrm{span}\{1,g:g\in C_t\}$, and let $r_t=y-f_t$. This is a *fixed* function of $(x,y)$.
- Each candidate $m\in\mathcal M(C_t)$ has utility $U_t(m)=\mathbb E[r_tg_m]$. Candidates are identified when they compute the same function up to sign. There are $M_t:=|\mathcal M(C_t)|\le|G|(d+t)^k$ of them.
- PG adds $m_t=\arg\max_m|U_t(m)|$.

Assume:
- a *gap* $\gamma>0$: $|U_t(m_t)|\ge|U_t(m)|+\gamma$ for all $m\ne\pm m_t$ and all $t<T$;
- $|r_t|\le R$ almost surely;
- $\lambda_*:=\min_{t\le T}\lambda_{\min}(K_t)>0$, where $K_t$ is the $L^2(P)$ Gram matrix of $(1,C_t)$.

**Empirical greedy run (EG).** At step $t$ the run uses a batch $B_t$ of $b$ samples. Either $B_t=S$ for every $t$ (**full batch**), or the $B_t$ are **fresh** independent batches. EG refits by least squares on $B_t$ over its current circuit, giving residual $\hat r_t$. It then adds a candidate maximizing $|\langle\hat r_t,g_m\rangle_{B_t}|$.

**Theorem A3.1 (decision stability) — Proved.** Let $\epsilon:=\gamma/\bigl(2(1+\sqrt{2T/\lambda_*})\bigr)$. Suppose
$$b\;\ge\;\frac{2R^2}{\epsilon^2}\log\frac{4\sum_{t<T}(M_t+t+1)}{\delta}\qquad\text{and}\qquad b\;\ge\;\frac{8(T+1)^2}{\lambda_*^2}\log\frac{4(T+1)^3}{\delta}.$$
Then with probability at least $1-\delta$, for both the full-batch and the fresh-batch protocol:
1. EG's first $T$ gates compute the same functions as $m_0,\dots,m_{T-1}$, so its circuit equals $C_T$.
2. If $y\in V_T$ almost surely (an *exact representation*), EG's final predictor equals $y$ almost surely: test error $0$.
3. In general EG's final predictor is a least-squares readout over the **data-independent** circuit $C_T$. So Theorem A1 applies to it with $\log|\mathcal H|=\rho_T$ and no wiring term.

*Proof.* The functions $r_t$, $g_m$ and $K_t$ belong to the population run and do not depend on the data, so union bounds over them are legitimate whether or not batches are reused. Let $E$ be the event that, for all $t\le T$:
- (i) $|\langle r_t,g\rangle_{B_t}-\mathbb E[r_tg]|<\epsilon$ for every $g\in\mathcal M(C_t)\cup C_t\cup\{1\}$, using steps $t<T$ only;
- (ii) every entry of the empirical Gram matrix $\hat K_t$ of $(1,C_t)$ on $B_t$ is within $\lambda_*/(2(T+1))$ of the corresponding entry of $K_t$.

Hoeffding bounds each event in (i) by $2e^{-b\epsilon^2/(2R^2)}$, since the summands lie in $[-R,R]$. It bounds each event in (ii) by $2e^{-b\lambda_*^2/(8(T+1)^2)}$, since the summands lie in $[-1,1]$. There are at most $\sum_{t<T}(M_t+t+1)$ events of type (i) and $(T+1)^3$ of type (ii). Under the two conditions on $b$, $P(E^c)\le\delta$.

On $E$, $\|\hat K_t-K_t\|_{\rm op}\le(t+1)\max|\text{entries}|\le\lambda_*/2$, so $\lambda_{\min}(\hat K_t)\ge\lambda_*/2$.

Induction on $t$: suppose EG's circuit computes $C_t$. Then its refit span is $V_t$. Since $y=f_t+r_t$ with $f_t\in V_t$, the empirical residual is $\hat r_t=(I-\hat\Pi_t)r_t$, where $\hat\Pi_t$ is the empirical projection onto $V_t$. Let $v=(\langle r_t,g\rangle_{B_t})_{g\in(1,C_t)}$. The population normal equations give $\mathbb E[r_tg]=0$ for these $g$, so on $E$, $\|v\|^2<(t+1)\epsilon^2$. Hence
$$\|\hat\Pi_tr_t\|_{B_t}^2=v^\top\hat K_t^{-1}v<\frac{2(t+1)\epsilon^2}{\lambda_*}.$$
Therefore, for every candidate,
$$\bigl|\langle\hat r_t,g_m\rangle_{B_t}-U_t(m)\bigr|\le\bigl|\langle r_t,g_m\rangle_{B_t}-U_t(m)\bigr|+\|\hat\Pi_tr_t\|_{B_t}<\epsilon\bigl(1+\sqrt{2T/\lambda_*}\bigr)=\gamma/2 .$$
With the gap $\gamma$, the empirical argmax computes $\pm m_t$. This proves item 1.

For item 2: if $r_T=0$ then $\hat r_T=0$. Because $\hat K_T$ is nonsingular, the least-squares coefficients are unique, and the population coefficients already give zero empirical residual. So the two coincide, and the predictor equals $f_T=y$. Item 3 holds because $C_T$ does not depend on the data. ∎

**Remark (the form $b\approx\log(MT/\delta)/\gamma^2$).** Suppose the readout is fitted separately, for example on a larger held-out batch or by a slow averaged SGD readout, so that $|\langle\hat r_t-r_t,g\rangle_{B_t}|\le\eta_{\rm ro}<\gamma/2$ for every candidate. Then the same proof needs only
$$b\ge\frac{2R^2}{(\gamma/2-\eta_{\rm ro})^2}\log\frac{4\sum_{t<T}M_t}{\delta},$$
with no $T/\lambda_*$ factor. This is the batch size $\approx\log(MT/\delta)/\gamma^2$ that reproduces the population run.

**How this compares with Occam.** For exact recovery, stability needs
$$n\approx\frac{TR^2\log(MT/\delta)}{\lambda_*\gamma^2},$$
whereas the Occam bound needs $T\log M/\varepsilon$ samples to reach error $\varepsilon$. Stability has no $1/\varepsilon$, but it pays $1/\gamma^2$, and it says nothing when the population run has ties ($\gamma=0$) or zero utilities. The constants are poor. For par2 with XOR in $G$, $\gamma=1/2$, $R=\lambda_*=1$ and $M_0=2205$, so the theorem requires $n\ge2252$; the toy run recovers par2 exactly at $n=64$. Ties of the maj3 type, where a symmetric set of candidates is jointly added, need a version in which the gap separates "this cluster" from the rest. That extension is not written out here.

### 3.2 SGD in the race model

**Lemma A3.2 (SGD clocks concentrate) — Proved.** Run the race in discrete steps of size $\eta$:
- At step $i$, draw a fresh batch $B_i$ of $b$ iid samples, independent of the past $\mathcal F_{i-1}$.
- The current residual function $\hat r_i$ is $\mathcal F_{i-1}$-measurable, with $|\hat r_i|\le R$.
- For each candidate $m$ in a fixed finite set $\mathcal M$, for instance every gate of every circuit with at most $T_{\max}$ gates, the clock increments by $\eta\,\mathbb 1[m\text{ available}]\,\langle\hat r_i,g_m\rangle_{B_i}$.

Let $\bar S_m$ be the *drift clock*, the same sum with each $\langle\hat r_i,g_m\rangle_{B_i}$ replaced by its conditional mean $\mathbb E[\hat r_ig_m\mid\mathcal F_{i-1}]$. Then for $t_0=\eta I_0$,
$$P\Bigl(\max_{i\le I_0}\max_{m\in\mathcal M}|\hat S_m(i)-\bar S_m(i)|\ge x\Bigr)\le2|\mathcal M|\exp\Bigl(-\frac{bx^2}{2R^2\eta t_0}\Bigr).$$
That is, with probability at least $1-\delta$, every clock error up to time $t_0$ is at most $R\sqrt{2\eta t_0\log(2|\mathcal M|/\delta)/b}$.

*Proof.*
1. Fix $m$. The increment $D_i=\hat S_m(i)-\hat S_m(i-1)-(\bar S_m(i)-\bar S_m(i-1))$ is $\eta/b$ times a sum of $b$ conditionally iid, mean-zero terms, each in an interval of length $2R$. By Hoeffding's lemma, $\mathbb E[e^{\lambda D_i}\mid\mathcal F_{i-1}]\le e^{\lambda^2\eta^2R^2/(2b)}$.
2. So $Z_I=\exp(\lambda\sum_{i\le I}D_i-\lambda^2\eta^2R^2I/(2b))$ is a nonnegative supermartingale with $Z_0=1$.
3. Ville's maximal inequality gives $P(\max_{I\le I_0}\sum_{i\le I}D_i\ge x)\le\exp(-\lambda x+\lambda^2\eta^2R^2I_0/(2b))$. Take $\lambda=xb/(\eta^2R^2I_0)$.
4. Treat the lower tail the same way, and take a union over $\mathcal M$. ∎

**Numerical** ([`checks/sgd_clock_check.txt`](checks/sgd_clock_check.txt)). Setup: the toy dictionary with $M=2205$; exact population utilities from a 256-point orthogonal-array design; $\delta=0.05$; 5 seeds; time up to $1.5\times$ the first population firing. Results:
- The observed maximum clock error is below the bound in every case, at 75–88% of it, and scales as $\sqrt{\eta/b}$. For maj3 at $(\eta,b)=(0.05,64)$ it is 0.19 against a bound of 0.23. At $(0.002,64)$ it is 0.041 against 0.046. At $(0.01,512)$ it is 0.031 against 0.037.
- The SGD race's first firing converges to the population time as $\eta/b\to0$: for maj3, 1.95, 1.97, 1.99 against 2. For par2 it is exactly 1.00 to 1.01.
- The exact utilities also confirm the table in Proposition A2.2 for $m=3$: 9 gates at $1/2$, $324=3\cdot27\cdot4$ AND-types at $1/4$, and the rest $0$.

**Consequence (Heuristic).** Over time $t_0$, the run consumes $N=t_0b/\eta$ fresh samples, so the clock error is $R\,t_0\sqrt{2\log(2|\mathcal M|/\delta)/N}$. This is the same form as the error of the full-batch race on $n=N$ samples, $t_0\cdot O(\sqrt{\log M/n})$, but without any reuse.

To conclude that the SGD race fires the same gates as the population race, two more ingredients are needed. Both are plausible for small $\eta$, but I have not proved them here:
- the readout must track the population refit, which is standard stochastic approximation;
- the population crossing times must be separated: no near-ties, and a clock margin $\Delta$ at every event.

Under these conditions, test error equals the population race's test error, and the only "generalization" question is approximation: does the population race find the target?

### 3.3 Online-to-batch and progressive validation

**Proposition A3.3 — Proved.** Let $z_1,z_2,\dots$ be iid from $P$. Let the predictor $h_i$ depend only on $z_1,\dots,z_{i-1}$ and on independent internal randomness. Let $\ell\in[0,1]$, and write $L(h)=\mathbb E\ell(h,z)$. For each fixed $N$, with probability at least $1-\delta$,
$$\frac1N\sum_{i\le N}L(h_i)\le\frac1N\sum_{i\le N}\ell(h_i,z_i)+\sqrt{\frac{\log(1/\delta)}{2N}},$$
and the same holds with the two sides exchanged. Minibatches are covered: $h$ is constant within a batch, and the samples are taken in any order.

Consequences:
- **Progressive validation.** The minibatch loss of one-pass SGD, computed *before* each update, is a valid estimate of the trajectory's average test loss.
- **Random iterate.** A uniformly random iterate has expected test loss at most the online average plus the deviation term.
- **Mistakes.** $M_N$ online mistakes give an average test error of the iterates of at most $M_N/N+\sqrt{\log(1/\delta)/(2N)}$.

This is the online-to-batch principle of Cesa-Bianchi–Conconi–Gentile (IEEE Trans. Inf. Theory 50(9), 2004, 2050–2057; **Literature**, theorem numbering from memory). The proof here is self-contained.

*Proof.* $D_i=L(h_i)-\ell(h_i,z_i)$ satisfies $\mathbb E[D_i\mid\mathcal F_{i-1}]=0$ and lies in the $\mathcal F_{i-1}$-measurable interval $[L(h_i)-1,L(h_i)]$, of length 1. Hoeffding's lemma gives $\mathbb E[e^{\lambda D_i}\mid\mathcal F_{i-1}]\le e^{\lambda^2/8}$. So $P(\sum D_i\ge Nx)\le e^{-\lambda Nx+N\lambda^2/8}=e^{-2Nx^2}$ at $\lambda=4x$. ∎

For the fresh-batch greedy model of Theorem A3.1 with an exact representation, the predictor is exact after step $T$ on the event of the theorem. So online mistakes come only from the first $T$ steps, at most $Tb$ of them. Bounding total mistakes in general, as the NNBayes total-mistake results do, would need a bound on the length of the greedy path; I do not give one.

### 3.4 Minibatches drawn with reuse from a fixed training set

**Proposition A3.4 — Proved.**
1. **Theorem A1 applies verbatim.** Whatever SGD does, its predictor at every step lies in $\mathcal H_{T(s)}$, and A1 is uniform over $T$, hence over steps.
2. **Reuse reproduces the full-batch race on $S$.** Minibatch utilities drawn with reuse are unbiased for the *training-set* utilities. So Lemma A3.2 and Theorem A3.1 hold with $P$ replaced by the empirical distribution $P_n$ of $S$: multi-epoch SGD approximates the full-batch race on $S$, not the population race. The no-overfitting conclusion of the fresh-batch version therefore does **not** transfer. Generalization then comes from A1, or from the full-batch case of Theorem A3.1, which is stability of the population run.
3. **First-occurrence validation.** Let the indices $i_1,i_2,\dots$ be iid uniform on $[n]$, independent of $S$. Let $s_1<s_2<\dots$ be the draws at which an index appears for the first time. Then for each fixed $K\le n$, with probability at least $1-\delta$,
$$\frac1K\sum_{k\le K}L(h_{s_k})\le\frac1K\sum_{k\le K}\ell(h_{s_k},z_{i_{s_k}})+\sqrt{\log(1/\delta)/(2K)},$$
where terms are set to $0$ if fewer than $K$ distinct indices are drawn.

*Proof of item 3.* Let $\mathcal G_k$ be generated by everything revealed before draw $s_k$, together with the index $i_{s_k}$. The example $z_{i_{s_k}}$ has never been revealed. It is independent of $\mathcal G_k$, because the $z_j$ are iid and independent of the indices and of the internal randomness, and its law is $P$. Also, $h_{s_k}$ is $\mathcal G_k$-measurable. So $D_k=L(h_{s_k})-\ell(h_{s_k},z_{i_{s_k}})$ is a martingale difference with range 1, and the proof of Proposition A3.3 applies. ∎

*In the experiment.* With batch size 64, after $s$ steps about $n(1-e^{-64s/n})$ distinct points have been seen. First-occurrence validation therefore covers roughly the first epoch, $n/64$ steps: 256 steps at $n=16384$, and almost nothing at small $n$. After that only A1, or a stability argument, applies. The protocol's online runs (fresh batch every step) are covered by Proposition A3.3 for the whole run.

---

## 4. A4: greedy growth versus the minimum-circuit Occam learner

The minimum-consistent-circuit (MCC) learner outputs a smallest circuit, with the same readout class, that is consistent with $S$. It is the discrete analogue of the strong-prior NNBayes learner: the posterior concentrates on minimal-complexity explanations. Let $s^*\le s(f^*)$ be the size of a smallest consistent circuit. Theorem A1 then gives
$$\mathrm{err}\le L_{s(f^*)}/n$$
in the realizable case, and the same theorem gives $\mathrm{err}\le L_{T_{\rm greedy}}/n$ for the greedy race at the time it is stopped. The comparison is therefore entirely about $T_{\rm greedy}$ versus $s^*$.

**Proposition A4.1 (equality on library targets) — Proved.** Let $y=\pm g^*$ for a depth-one candidate $g^*$ with $\mathbb E[y]=0$. In the population race, in either variant, $g^*$ and its duplicates as functions fire first, at $t=\Theta$. After the refit the residual is $0$ and the race stops. So $T=1=s^*$. On a sample the same holds unless another candidate agrees with $\pm y$ on all $n$ points.

*Proof.* For balanced $y$, $|U_m|=|\mathrm{Cov}(y,g_m)|\le\mathrm{sd}(g_m)\le1$, with equality only if $g_m=\pm y$ almost surely. So $g^*$ reaches $\Theta$ first, while every other clock is still below $\Theta$; the refit then gives $f=y$. ∎

The balance condition matters. For unbalanced $y$ the utility of $g^*$ is $\mathrm{Var}(y)<1$, and a balanced candidate correlated with $y$ can win. The toy instance and3 has $\bar y=-3/4$. Its first gate fires at $t/\Theta\approx2.7$, and two gates suffice: $\mathrm{sgn}(\mathrm{AND}(x_1,x_2)+\mathrm{AND}(x_2,x_3)-1)=\mathrm{AND}_3$. The greedy race finds exactly 2 gates at zero training error, which equals the minimum (Section 5).

**Proposition A4.2 (overshoot from ties and from square-loss refits) — Proved (population).** Items 1 and 3 are overshoots caused by ties; item 2 is an overshoot caused by square-loss refits.
1. **Ties.** For $y=\mathrm{maj}_3$ with the toy library $G=\{\text{identity},\ \mathrm{AND}(\pm a,\pm b),\ \mathrm{XOR}\}$, 9 gates fire together at $t=2\Theta$ (Proposition A2.2 with $m=3$, $u_3=1/2$). Three identity gates already suffice for the sign readout $\mathrm{sgn}(x_1+x_2+x_3)$, so $s^*\le3$; $s^*=1$ if $\mathrm{MAJ}_3\in G$. After this event the refit is $f=(x_1+x_2+x_3)/2$, so the **0-1 error is already zero**.
2. **Square-loss refits keep going.** In item 1 the residual $-x_1x_2x_3/2$ is nonzero, so the race continues. With $\mathrm{XOR}\in G$, the depth-two candidate $\mathrm{XOR}(\mathrm{AND}(x_1,x_2),x_3)=(x_1x_3+x_2x_3+x_1x_2x_3-x_3)/2$ has utility of magnitude $1/4$. It becomes available at $2\Theta$ and so fires at $6\Theta$; possibly tied depth-two candidates fire with it. In general, the race stops only when $y$ lies in the span of the fired gates. On a sample that can require up to $n$ gates. The relevant $T$ for Theorem A1 is the one at the **stopping time**, not at the end of training.

3. **Overshoot by a factor $m$.** For $y=\mathrm{MAJ}_m$ ($m$ odd) with the toy library, the first event fires $m^2$ gates at $t=\Theta/u_m$ (Proposition A2.2(2)). The refit is then $f=u_m\sum_{i\le m}x_i$, the degree-$\le2$ part of $y$, so $\mathrm{sgn}f=y$ and the 0-1 error is zero. But $m$ identity gates already suffice. So $T_{\rm greedy}=m^2$ while $s^*\le m$, and in Theorem A1 the bound uses $L_{m^2}\approx m^2\log(6d^2)+m^4\log2$ in place of $L_m$.

*Proof.* Item 1 is Proposition A2.2(2), together with the Fourier expansion $\mathrm{maj}_3=\frac12(x_1+x_2+x_3-x_1x_2x_3)$: the span of the 9 gates and $1$ contains exactly the degree $\le2$ functions of $x_1,x_2,x_3$. For item 2, the product expansion above gives $\mathbb E[(-x_1x_2x_3/2)\cdot\mathrm{AND}(x_1,x_2)x_3]=-1/4$. For item 3, $\mathrm{MAJ}_m$ is odd, so its degree-2 Fourier coefficients vanish, and its degree-1 part is $u_m\sum_ix_i$. The span of the fired gates and $1$ is the span of $1$, the $x_i$ and the $x_ix_j$ ($i,j\le m$), so the least-squares refit is $u_m\sum_ix_i$, whose sign is $\mathrm{MAJ}_m$. ∎

**Numerical** (Section 5). maj3 reaches zero training error with 6 gates at $n\ge256$ and ends with 10 gates, the 10th firing at $t/\Theta=5.99$; the population prediction is 6. dnf3 reaches zero training error with 18 gates, while a 6-gate circuit exists: three 3-literal ANDs built from two fan-in-2 ANDs each, with readout $\mathrm{sgn}(\sum_jT_j+2)$. That is an overshoot by a factor of 3. In Theorem A1, the dnf3 bound at $n=4096$ is 0.084 with $T=18$, whereas $T=6$ would give 0.019.

**Proposition A4.3 (parity is never found) — Proved.** Let $y=\chi_S$ with $|S|=s>k$, under uniform inputs. In the population race no candidate ever fires: $T(t)=0$ and the test error is $1/2$ for all $t$. If $\mathrm{XOR}\in G$, the target has an $(s-1)$-gate circuit, so the MCC learner, or any learner that outputs a consistent circuit of at most $s-1$ gates, has error at most $L_{s-1}/n=O(s\log d/n)$. On a sample, Proposition A2.6 applies: nothing fires before $t\approx\Theta\sqrt n/(2\sqrt{2\log(2M/\delta)})$, after which gates fitted to noise fire.

*Proof.* Before any gate fires, every candidate has depth one and so depends on some set $V$ of at most $k<s$ variables. Write $\chi_S=\chi_{S\cap V}\chi_{S\setminus V}$. Since $S\setminus V\ne\emptyset$, $\chi_{S\setminus V}$ has mean zero and is independent of $x_V$, so $\mathbb E[\chi_Sg]=0$. Also $\mathbb E[y]=0$. All utilities vanish, the residual stays $y$, and the clocks stay at $0$. ∎

This is the circuit-leap obstruction of the [README](../README.md) (§3) in its simplest form. In real GD the fan-in-$s$ search costs about $d^{s-1}$ time, as the SQ lower bounds require. The discrete model represents that cost only if the library contains fan-in-$s$ gates with correspondingly larger thresholds. The par3 runs in Section 5 show the predicted behaviour: nothing until $t/\Theta=5$–$20$, depending on $n$; then one or more noise gates, with test error $0.50$. Theorem A1 remains valid: it gives $0.52$–$0.95$, which certifies nothing.

**What this does to the bounds.**
- **Same theorem, different $T$.** Theorem A1 holds for both learners. The greedy bound is weaker by about the factor $T_{\rm greedy}/s^*$, or its square from the $T^2$ readout term. That factor is 1 for library targets, 2–3 for maj3 and dnf3 in the toy runs, and $m$ for $\mathrm{MAJ}_m$ (Proposition A4.2(3)).
- **When greedy never finds the circuit.** The bound stays correct but vacuous in effect: it certifies the training error of a bad predictor. The MCC learner's sample complexity is unaffected. MCC is not efficiently computable; the greedy race pays in reachability instead.
- **A greedy-only route.** When the population run is stable, Theorem A3.1 gives a guarantee that MCC lacks: exact recovery whose sample size has no $1/\varepsilon$. It is lost under ties or zero utilities.
- **Relation to NNBayes (Heuristic).** The Bayesian/MCC learner pays prior mass, roughly circuit size, *once*. The greedy race pays at every step: each gate must have utility exceeding the noise level $\sqrt{\log M/n}$ at the moment it is added. In the sibling project, small circuits imply few total mistakes in random order ([total mistakes](../../neural-network-generalization/TECHNICAL-FAQ.md#can-we-bound-the-total-number-of-mistakes-during-learning)), and few mistakes imply small circuits ([circuit-induction converses](../../neural-network-generalization/TECHNICAL-FAQ.md#does-making-few-mistakes-imply-that-the-target-has-a-small-circuit)). For the greedy race the first direction fails: par3 has a 2-gate circuit when XOR is in the library, yet the online race makes about $N/2$ mistakes in $N$ rounds.

---

## 5. Numerical sanity check (toy race, $d=30$)

[`checks/race_bounds.py`](checks/race_bounds.py) produces [`checks/race_bounds.txt`](checks/race_bounds.txt) in a few minutes on one core. The setup:
- **Library:** identity, $\mathrm{AND}(\pm a,\pm b)$ and $\mathrm{XOR}(a,b)$, up to negation, so $|G|=6$ and $k=2$. There are 2205 depth-one candidates.
- **Model:** the event-driven (LS) race at any depth, and the (SC) race on the depth-one dictionary.
- **Data:** training sets of size $n$, and a test set of 20,000 points.
- **Conventions:** $\delta=0.05$. Candidates that coincide on the sample are merged.

**(LS) race: first zero-training-error event, and last event.** Bounds are Theorem A1 in kl form. The last column records whether Theorem A2.3 ($T\le\kappa\tau^2/\Theta^2$), Proposition A2.1 (depth $\le\tau/\Theta$) and Theorem A1 (test error $\le$ bound) held at every event.

| target | $n$ | $T$ at 0 train err | $t/\Theta$ | test err | A1 bound | $T$ at end | $t/\Theta$ | A1 bound | A2.3 / A2.1 / A1 hold |
|---|---|---|---|---|---|---|---|---|---|
| par2 | 64 | 1 | 1.05 | 0 | 0.21 | 1 | 1.05 | 0.21 | yes |
| par2 | 4096 | 1 | 1.00 | 0 | 0.004 | 1 | 1.00 | 0.004 | yes |
| maj3 | 256 | 6 | 2.72 | 0 | 0.26 | 10 | 5.43 | 0.45 | yes |
| maj3 | 4096 | 6 | 2.08 | 0 | 0.019 | 10 | 5.99 | 0.036 | yes |
| and3 | 256 | 2 | 3.68 | 0 | 0.094 | 7 | 8.20 | 0.31 | yes |
| and3 | 4096 | 2 | 2.68 | 0 | 0.006 | 7 | 7.38 | 0.023 | yes |
| dnf3 | 1024 | 18 | 8.36 | 0 | 0.30 | 20 | 10.05 | 0.34 | yes |
| dnf3 | 4096 | 18 | 8.87 | 0 | 0.084 | 21 | 11.45 | 0.11 | yes |
| par3 | 256 | never | – | (0.50) | – | 1 | 5.16 | 0.56 | yes |
| par3 | 4096 | never | – | (0.50) | – | 1 | 20.0 | 0.52 | yes |

The other sample sizes are in the output file. At $n=64$, maj3 and dnf3 reach zero training error with 8 and 11 gates, and test errors 0.09 and 0.26; the bounds there are 0.83 and 0.93.

Observations:
- **Theorem A1** holds in every run, and is non-vacuous whenever $n\ge256$ and $T\le10$. The observed test error is exactly 0 in most runs, so the bound's value is essentially its slack $L_T/n$.
- **Theorem A2.3:** the observed $\kappa$ lies in $[0.7,3.1]$, and $\kappa\tau^2/\Theta^2$ exceeds $T$ by a factor of 1.5–5.
- **Proposition A2.6:** on par3, the first noise firing is at $t/\Theta=2.65,\,5.16,\,9.97,\,20.0$ for $n=64,256,1024,4096$, against the proved lower bound $0.84,\,1.68,\,3.35,\,6.71$.

**(SC) race on the depth-one dictionary (Theorem A2.4).** The identity $\Theta\|c\|_1=\langle R,f\rangle_n$ and the chain $\le\|R\|_n\le\tau$ hold to machine precision at every event (maj3, and3 and par2; $n=256$ and $4096$). For example, maj3 at $n=4096$ ends with $\|c\|_1=1.53$, $\|R\|_n/\Theta=15.2$ and $\tau/\Theta=16.1$. The Cauchy–Schwarz step is loose by a factor of 10 there, because after the last firing $R(t)$ grows only along the residual, which is orthogonal to $f$.

Theorem A1′, with $|\mathcal F|=2205$, is **near-vacuous at these sizes**:
- at $n=4096$, its bound on the clipped square loss is 0.50–0.84, against a true 0.02–0.09;
- its 0-1 bound (ramp, $\theta=1/2$) is 0.40–0.77, against a true 0;
- at $n=256$ it exceeds 1.

The norm route needs $n\gtrsim10^5$ here. Its advantage, independence from $T$, matters only for large circuits.

**Files used by this note.**

| script | output | checks |
|---|---|---|
| [`checks/lemma_checks.py`](checks/lemma_checks.py) | [`checks/lemma_checks.txt`](checks/lemma_checks.txt) | Lemma 1.2 by brute force for $T\le4$; Lemma 1.3 inequalities on a grid; the table of A1 bounds |
| [`checks/race_bounds.py`](checks/race_bounds.py) | [`checks/race_bounds.txt`](checks/race_bounds.txt) | toy (LS) and (SC) races: Theorem A1, Proposition A2.1, Theorem A2.3, Theorem A2.4, Theorem A1′, Proposition A2.6 |
| [`checks/sgd_clock_check.py`](checks/sgd_clock_check.py) | [`checks/sgd_clock_check.txt`](checks/sgd_clock_check.txt) | Lemma A3.2 and the utility table of Proposition A2.2 |

All three use numpy (and scipy for linear programming and nonnegative least squares) and run in minutes on one core.

---

## 6. What is vacuous, and what is open

**At realistic sizes** ($d=30$, $n\le16384$):
- *Non-vacuous:* Theorem A1, realizable form, for $T\lesssim20$ at $n\ge4096$, and for $T\le2$ at $n=256$.
- *Weak:* the agnostic form, which is about $\sqrt{L_T/2n}$: 0.088 at $T=5$, $n=4096$.
- *Near-vacuous:* the norm-based Theorem A1′ and Corollary A2.5(b).
- *Not yet applicable:* the size-from-time bound, Corollary A2.5(a), needs $\kappa$ and $\tau/\Theta$. Both are measurable in the toy model; in the real network runs, measuring them requires the calibration recipe of §2.3, which is Heuristic.
- *Poor constants:* Theorem A3.1 asks for $n\approx2250$ for par2, which is learned at $n=64$.
- *Indirect for real networks:* none of these bounds applies to a trained network unless the network is first described as a circuit of the template. That could be done by fitting the discrete race to the run, or by reading gates off the saved Fourier coefficients on the relevant variables. The bound then certifies that circuit, not the network (Heuristic).

**Open problems.**
1. **$\ell_1$ control at depth $\ge2$.** Late availability times $a_m$ break the duality identity of Theorem A2.4. Is $\Theta\|c(t)\|_1\le C_D\,\tau(t)$ true for depth-$D$ (SC) races?
2. **A $\kappa$-free size bound.** Is there a bound in terms of *distinct functions* that excludes near-duplicate libraries? Proposition A2.2 shows that the bound must depend on the library through something like $\kappa$.
3. **Theorem A3.1 for the race.** A reproduction theorem for the race rather than argmax, under a crossing-time margin, and for tied clusters such as the 9 gates of maj3.
4. **Total mistakes.** A bound for the one-pass greedy race, analogous to the NNBayes total-mistake theorems, in terms of the length of the population greedy path.
5. **Faithfulness.** Faithfulness of the deep attach model, and of the (LS) versus (SC) refit, to actual small-initialization GD beyond depth one. The calibration of $\Theta$ and of race time on the μP runs (§2.3).

## References

- T. Cover. *Geometrical and statistical properties of systems of linear inequalities with applications in pattern recognition.* IEEE Trans. Electronic Computers EC-14 (1965) 326–334. Function-counting theorem (Lemma 1.2 proves the upper half).
- OEIS A000609, number of threshold functions of $n$ variables: 2, 4, 14, 104, 1882, 94572, ... (values for $n\le4$ confirmed by brute force in `checks/`).
- A. Blumer, A. Ehrenfeucht, D. Haussler, M. Warmuth. *Learnability and the Vapnik–Chervonenkis dimension.* JACM 36(4) (1989) 929–965. Theorem A2.1 (from memory).
- P. Bartlett, S. Mendelson. *Rademacher and Gaussian complexities: risk bounds and structural results.* JMLR 3 (2002) 463–482. Theorem 8 (from memory).
- M. Mohri, A. Rostamizadeh, A. Talwalkar. *Foundations of Machine Learning*, 2nd ed., MIT Press 2018. Theorem 3.3, Theorem 3.7 (Massart), Lemma 5.7 (Talagrand contraction), Lemma 7.4 (convex hulls) (numbering from memory).
- M. Ledoux, M. Talagrand. *Probability in Banach Spaces.* Springer 1991. Theorem 4.12 (contraction).
- V. Koltchinskii, D. Panchenko. *Empirical margin distributions and bounding the generalization error of combined classifiers.* Annals of Statistics 30(1) (2002) 1–50. Margin bounds of the A1′ type.
- N. Cesa-Bianchi, A. Conconi, C. Gentile. *On the generalization ability of on-line learning algorithms.* IEEE Trans. Inf. Theory 50(9) (2004) 2050–2057 (venue checked; theorem statements from memory). NIPS 2001 version: [proceedings](https://proceedings.neurips.cc/paper/2001/hash/01931a6925d3de09e5f87419d9d55055-Abstract.html).
- S. Pesme, N. Flammarion. *Saddle-to-Saddle Dynamics in Diagonal Linear Networks.* NeurIPS 2023. [arXiv:2304.00488](https://arxiv.org/abs/2304.00488). Abstract checked; the exact form of the recursion is from memory.
- D. Kunin, G. Marchetti, F. Chen, D. Karkada, J. Simon, M. DeWeese, S. Ganguli, N. Miolane. *Alternating Gradient Flows: A Theory of Feature Learning in Two-layer Neural Networks.* NeurIPS 2025. [arXiv:2506.06489](https://arxiv.org/abs/2506.06489). Accumulated-utility clocks (from memory).
- R. DeVore, V. Temlyakov. *Some remarks on greedy algorithms.* Adv. Comput. Math. 5 (1996) 173–187. Orthogonal-greedy rate $\|r_T\|\le\|f\|_{\mathcal A_1}(T+1)^{-1/2}$ (from memory; not used in a proof here). It is the depth-one approximation counterpart: a target with $\ell_1$-representation norm $M$ is fit to squared residual $M^2/(T+1)$ by $T$ greedy steps, so $T_{\rm greedy}\lesssim M^2/\varepsilon$.
- Sibling project: [`neural-network-generalization/TECHNICAL-FAQ.md`](../../neural-network-generalization/TECHNICAL-FAQ.md), sections on total mistakes and circuit-induction converses.
