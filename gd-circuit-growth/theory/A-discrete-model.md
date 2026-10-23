# A. Generalization bounds for the discrete circuit-growth model

Notes by Claude (Opus 5.5), prompted by Kaarel Hänni. Research note, 23 October 2026, revised twice the same day after two adversarial referee reports ([revision notes](#revision-notes)). This version applies the round-2 referee's minor fixes. Not reviewed by a human.

**Question (from the user).** *"Try to see if you can get some generalization bounds for this. I guess I can see how one would have a result saying that you get good generalization if training hasn't taken too long because the circuit cannot have grown that big yet, and then one has a Chernoff guarantee for all small circuits that their train and test loss are similar? Here we could imagine doing full batch but with a train/test split, or SGD; either should make sense."*

**Status labels.** These follow [`neural-network-generalization/`](../../neural-network-generalization/TECHNICAL-FAQ.md):
- **Proved:** a complete proof with explicit constants is in this file. "Proved (given L1–L3)" means the proof is complete apart from three cited textbook lemmas.
- **Literature:** a published result. "(from memory)" means I could not check the text.
- **Heuristic:** an informed expectation, or a modelling claim.
- **Conjecture**, **Numerical:** as usual.

Scripts and their outputs are in [`checks/`](checks/). Numbers added in this revision come from [`checks/A_r2_checks.py`](checks/A_r2_checks.py) (output [`checks/A_r2_checks.out`](checks/A_r2_checks.out)); the referees' independent checks are in [`checks/referee_A_r1.out`](checks/referee_A_r1.out) (round 1) and [`checks/referee_A_r2.out`](checks/referee_A_r2.out) (round 2).

## Summary

The user's picture is right in outline. The Chernoff step works as hoped (item 1). The correction is about what "the circuit cannot have grown that big yet" can mean (item 2).

1. **The Chernoff/Occam part works with no assumptions on the dynamics.** Gate choices may depend arbitrarily on the training data, and the bound holds for every circuit size $T$ at once (Theorem A1). With zero training error, the test error is at most about
   $$\frac{T\,(\log|G| + k\log(d+T)) + T^2\log 2 + \log\frac{(T+1)(T+2)}{\delta}}{n}.$$
   For the toy library below ($d=30$, fan-in 2, $|G|=6$) and $\delta=0.05$, this is at most $0.1$ once $n\ge 144\,T$, for $1\le T\le 10$. At the experiment's largest sizes it stays at most $0.1$ for circuits of up to 20 gates ($n=4096$) and 62 gates ($n=16384$).

2. **"Not too much training time" bounds the number of gates only through an incoherence factor:** the learned circuit's $\kappa(t)$, or the library's $\bar\kappa\approx d$ (Corollary A2.5(a′)). No bound with a library-independent constant holds (Proposition A2.2). In the race model, clocks persist, as they do in small-initialization gradient descent. Many candidates can then fire at once. For example, on $\mathrm{MAJ}_m$ with identity and AND/OR gates, $m^2$ distinct gate functions fire together at time $\Theta/u_m\approx\Theta\sqrt{\pi m/2}$, where $\Theta=\log(1/\alpha)$ (Proposition A2.2). Time is measured by *effective time* $\tau(t)=\int_0^t\sqrt{2\hat L(s)}\,ds\le t$, in units of $\Theta$. Training time controls three quantities:
   - the **depth** of the circuit, $D(t)\le\tau(t)/\Theta$ (Proposition A2.1);
   - the **number of gates times their incoherence**, $T(t)\le\kappa(t)\,(\tau(t)/\Theta)^2$, where $\kappa(t)$ is the top eigenvalue of the fired gates' centred Gram matrix (Theorem A2.3). The population version is tight up to a factor $\pi/2$, and the toy run on par2 attains the bound;
   - the **$\ell_1$ norm of the readout**, $\|c(t)\|_1\le\|R(t)\|_n/\Theta\le\tau(t)/\Theta$, for depth-one circuits with sign-consistent refits (Theorem A2.4). This is the setting of diagonal linear networks (Literature, from memory; up to the intercept).

   Combined with Theorem A1 these give three statements of different strength (Corollary A2.5):
   - The **norm version (b)** is a genuine bound in terms of training time alone, but only at depth one, and it is near-vacuous at the experiment's sizes.
   - The **count version (a)** is a decomposition, *size $\le$ incoherence $\times$ time$^2$*. Since $\kappa(t)$ is a property of the learned circuit, (a) is never tighter than Theorem A1 applied to the realized size.
   - The **time-only count version (a′)** replaces $\kappa(t)$ by the incoherence $\bar\kappa$ of the whole library on the unlabelled inputs, for a race that merges candidates coinciding on the sample (as in Section 5). For the toy library $\bar\kappa_1\approx d=30$, so (a′) is weak. At $n=16384$ it gives $0.053$ at $\tau=\Theta$ and $0.195$ just below $\tau=2\Theta$, against $0.001$ for Theorem A1 at the size actually reached on par2.

   **What "short training" means.** In the pure attach race, where every move needs $k=2$ fresh weight layers, $\alpha$ only sets the unit of time (Lemma 2.2(4)), so "training hasn't taken long" means $\tau/\log(1/\alpha)$ is small. This invariance fails once fresh-chain moves ($k\ge3$) are included, because their thresholds grow like $\alpha^{-(k-2)}$. In a network with three weight layers started entirely at scale $\alpha$, the very first feature is a fresh chain costing time about $\alpha^{-1}$ (Heuristic). By the time anything has been learned, $t/\log(1/\alpha)$ is therefore already large. The depth-one race started at time $0$ models diagonal or 2-homogeneous networks, not the first move of the user's three-layer network. In the μP experiments there is no single $\alpha$ at all (§2.1).

3. **SGD.** What is proved is narrower than "SGD reproduces the population run".
   - **Greedy argmax model** (one gate per step, the one of largest empirical utility). Suppose the population run has a utility gap $\gamma>0$ at every step and each per-step batch is large, $b\gtrsim\max\{TR^2/(\lambda_*\gamma^2),\,T^2/\lambda_*^2\}\log(MT/\delta)$. Then the stochastic run makes the population run's choices (Theorem A3.1). Under an exact representation (A3.1(2)) its test error *is* the population model's; otherwise A3.1(3) gives an Occam bound with no wiring term.
     - The same theorem covers full-batch training on one sample of that size.
     - Theorem A3.5, new in this revision, covers minibatches drawn with reuse from one training set, when both $n$ and $b$ exceed a similar threshold.
     - The thresholds are large: $b\ge2254$ for par2 with fresh batches, and $b\ge6225$ at $n=16384$ with reuse. The experiments' $b=64$ is not covered.
   - **SGD race.** Only concentration of the clocks around drift clocks is proved (Lemma A3.2). That the race reproduces the population race is Heuristic.
   - **A different mechanism from Occam.** Where stability applies, it gives exact recovery from $n\approx\max\{TR^2/(\lambda_*\gamma^2),\,T^2/\lambda_*^2\}\log(MT/\delta)$ samples, with no $1/\varepsilon$.
   - **Minibatches drawn *with reuse*:**
     - Theorem A1 applies to any learner whose predictor is a template circuit. It does not apply to the network itself.
     - The losses on each point's *first* draw estimate the average test loss of the iterates at the first-draw times, which lie mostly in the first epoch. They do not estimate the final predictor's test loss (Proposition A3.4).

4. **Greedy versus minimum-circuit learning.** The bound is the same function of $T$. The difference is which $T$ each learner reaches:
   - On targets that are library gates, the greedy circuit is minimal. No balance assumption is needed (Proposition A4.1).
   - Ties and refits make it overshoot, by a factor $m$ on $\mathrm{MAJ}_m$ (Proposition A4.2). The population race on maj3 ends with 21 gates. The toy runs reach zero training error with 6 gates (10 by the end) on maj3, against a minimum of 3, and with 18 on dnf3, against at most 6.
   - Square-loss refits keep growing the circuit after the 0-1 training error reaches zero.
   - On $\chi_S$ with $|S|>k$ the population race never fires at all (Proposition A4.3). If $\mathrm{XOR}\in G$, the Occam learner with an output-gate readout reaches error $\varepsilon$ from $O((|S|\log(d+|S|)+\log(1/\delta))/\varepsilon)$ samples.

The [last section](#6-what-is-vacuous-and-what-is-open) lists what is vacuous at realistic sizes, and what is open.

| result | content | status |
|---|---|---|
| Lemma 1.1, 1.2, 1.3 | circuit count, threshold-readout count, Chernoff kl tail | Proved |
| Theorem A1 | Occam bound uniform over $T$: kl, Bernstein, Hoeffding, realizable | Proved |
| Theorem A1′ | margin and clipped-square-loss bound for $\ell_1$-bounded readouts | Proved (given L1–L3) |
| Lemma 2.2 | basic facts; scale invariance of a race with one threshold | Proved |
| Proposition A2.1 | depth $\le \tau/\Theta$ | Proved |
| Proposition A2.2 | no bound on the gate count in terms of time alone holds uniformly over libraries; tight examples | Proved |
| Theorem A2.3 | $T\le\kappa\,(\tau/\Theta)^2$ in (LS); $\lvert\mathrm{Sat}\rvert\le\kappa\,(\lVert R\rVert_n/\Theta)^2$ in (SC) | Proved |
| Theorem A2.4 | $\Theta\lVert c\rVert_1=\langle R,f\rangle_n\le\lVert R\rVert_n$ (depth 1, sign-consistent) | Proved |
| Corollary A2.5 | test error along training: (a) size $\le$ incoherence $\times$ time$^2$; (a′) time-only count bound via library incoherence, for races that merge sample-duplicates; (b) time-only norm bound at depth one | Proved (a, a′); Proved given L1–L3 (b) |
| Proposition A2.6 | no gate fires before $t\approx\Theta\sqrt{n/(8\log M)}$ on parity-like targets | Proved |
| Clock model ≈ small-init GD | faithfulness of the model | Literature (depth 1, from memory) / Heuristic (deeper, fresh chains) |
| Theorem A3.1 | decision stability of the greedy argmax model: fresh-batch and full-batch reproduction of the population run | Proved |
| Lemma A3.2 | SGD clocks concentrate around drift clocks | Proved; numerically tight to within 25% |
| Proposition A3.3 | online-to-batch / progressive validation | Proved |
| Proposition A3.4 | reuse: A1 for template learners; stability conditional on the sample; first-occurrence validation | Proved; the SGD-race-with-reuse reading is Heuristic |
| Theorem A3.5 | decision stability of the greedy model with minibatches drawn with reuse | Proved |
| Propositions A4.1–A4.3 | greedy versus minimum circuit: equal, overshoot, never | Proved (population; A4.1 also on samples) |
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

*Single fixed class.* The same proof without the union over $T$ shows: for a fixed (data-independent) finite class $\mathcal H$, the four bounds hold for all $h\in\mathcal H$ with probability at least $1-\delta$, with $L=\log|\mathcal H|+\log(1/\delta)$ in place of $L_T$. This is used in Section 3.

**Remarks.**
- **Duplicates.** Gates that compute the same function, or are never used, can be dropped without changing $h$. So $T$ may be taken as the number of distinct gate functions that are used, either as sources or with nonzero readout weight.
- **Where the $T^2$ comes from, and the symmetrization alternative.** The term $\rho_T\approx T^2\log2$ (for $T\le d$) is the price of an arbitrary real threshold readout.
  - An alternative replaces it by $\log\Phi(2n,T)\approx T\log(2n)$, the number of readouts on a double sample, via symmetrization. The form I recall is: for $n\ge 8/\epsilon$, $P(\exists h\in\mathcal H:\hat p=0,\ p>\epsilon)\le2\,\Pi_{\mathcal H}(2n)\,2^{-\epsilon n/2}$ (Blumer–Ehrenfeucht–Haussler–Warmuth, JACM 1989, Theorem A2.1; **Literature, from memory**, including the hypothesis $n\ge8/\epsilon$). Here the growth function satisfies $\Pi_{\mathcal H_T}(2n)\le|\mathcal W_T|\,\Phi(2n,T)$ by Lemma 1.2.
  - Solving for $\epsilon$ multiplies the *whole* complexity, wiring term included, by $2/\ln2\approx2.9$.
  - With the toy constants below, Theorem A1 is smaller than this route at every $T\le1499$ for $n\in\{1024,4096,16384\}$ ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §7). That covers the whole range in which BEHW is below 1 or A1 is non-vacuous. At $T=10$ and $n=4096$, for example, the two give $0.036$ and $0.122$. For $T>d$, $\rho_T$ grows only like $dT\log2$, so the $T^2$ term never takes over.
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

**Two thresholds.** Throughout, a bound is called *useful* if it is at most $0.1$, and *non-vacuous* if it is below $1/2$. The realizable bound is:

| | $n=256$ | $n=1024$ | $n=4096$ | $n=16384$ |
|---|---|---|---|---|
| useful for | $T\le2$ | $T\le7$ | $T\le20$ | $T\le62$ |
| non-vacuous for | $T\le11$ | $T\le27$ | $T\le102$ | $T\le403$ |

For $1\le T\le10$, the sample size needed for a useful bound is at most $144\,T$ ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §1).

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
With probability at least $1-\delta$, for all $j\ge0$ and all $f\in\mathcal A_{B_j}$, **both** of the following hold:
$$\mathbb E\ell_{\rm sq}(f)\le\hat{\mathbb E}\ell_{\rm sq}(f)+4\,\mathfrak R_n(B_j)+2\sqrt{\frac{\log(2/(\pi_j\delta))}{2n}},$$
$$\mathrm{err}(\mathrm{sgn}f)\le\hat{\mathbb E}\varphi_\theta(yf)+\frac2\theta\,\mathfrak R_n(B_j)+\sqrt{\frac{\log(2/(\pi_j\delta))}{2n}}\qquad(\theta\text{ fixed in advance}).$$
A predictor with $\sum_j|c_j|=B$ and $|c_0|\le1+B$ lies in $\mathcal A_{B_j}$ with $B_j\le2\max(B,1)$. To make the bound uniform in $T$ for $\mathcal F_{\le T}$, add $\log((T+1)(T+2))$ to $\log(2/(\pi_j\delta))$.

*Cited lemmas* (all **Literature**, from memory, standard; theorem numbering from memory). The forms stated are those of Mohri–Rostamizadeh–Talwalkar, *Foundations of Machine Learning* (2nd ed., MIT Press 2018), with the Rademacher complexity defined without absolute value and without a factor 2: $\mathfrak R_n(\mathcal G)=\mathbb E\sup_{g}\frac1n\sum_i\sigma_ig(z_i)$.
- **L1** (uniform deviation; MRT Theorem 3.3, stated there for $[0,1]$-valued classes and rescaled here). For a class $\mathcal G$ of $[0,M]$-valued functions, with probability at least $1-\delta$, every $g\in\mathcal G$ satisfies $\mathbb Eg\le\hat{\mathbb E}g+2\mathfrak R_n(\mathcal G)+M\sqrt{\log(1/\delta)/(2n)}$. A related form with different constants is Bartlett–Mendelson (JMLR 2002) Theorem 8. It uses a differently normalized complexity (factor 2, absolute value) and a $\sqrt{8\ln(2/\delta)/n}$ term.
- **L2** (contraction; MRT Lemma 5.7, Talagrand's lemma). If each $\phi_i$ is $\ell$-Lipschitz, then $\hat{\mathfrak R}(\{(\phi_i(f(x_i)))_i\})\le\ell\,\hat{\mathfrak R}(\{(f(x_i))_i\})$. This one-sided form needs no condition $\phi_i(0)=0$. The absolute-value contraction principle of Ledoux–Talagrand (1991, Theorem 4.12) is a related form: it requires $\phi_i(0)=0$ and has an extra factor 2.
- **L3** (Massart, and convex hulls; MRT Theorem 3.7 and Lemma 7.4). For a finite set $A\subset[-1,1]^n$, $\hat{\mathfrak R}(A)\le\sqrt{2\log|A|/n}$, and taking the convex hull does not change $\hat{\mathfrak R}$.

*Proof.* We have $\mathcal A_B\subseteq\{c_0:|c_0|\le1+B\}+B\,\mathrm{conv}(\mathcal F\cup-\mathcal F)$. The constants contribute $(1+B)\,\mathbb E|\sum_i\sigma_i|/n\le(1+B)/\sqrt n$. By L3, the hull contributes at most $B\sqrt{2\log(2|\mathcal F|)/n}$. Apply L2 with Lipschitz constant 2 or $1/\theta$. Then apply L1 with $M=2$ or $1$, at confidence $\pi_j\delta/2$ for each of the two losses, and take a union over $j$ and over the two losses. ∎

This is the bound that training time controls directly, through Theorem A2.4. It does not care how many gates are active. Its constants are poor. In Section 5 it gives 0.43–0.92 for $\mathbb E\ell_{\rm sq}$ at $n=4096$. Theorem A1 gives 0.004–0.036 for the 0-1 error of the final predictors of the same runs.

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
  - **(SC)**, for a depth-one dictionary only (every candidate reads inputs). The readout is supported on the saturated set $\mathrm{Sat}(t)=\{m:|S_m(t)|=\Theta\}$. On it, $c(t)$ minimizes the empirical square loss subject to $\sigma_mc_m\ge0$, with a free intercept, and $c_m=0$ off it. A saturated gate whose clock moves back inside $(-\Theta,\Theta)$ is dormant again.

Between events $r$ is constant, so clocks are linear in $t$. We also use

$$\tau(t):=\int_0^t\|r(s)\|_n\,ds=\int_0^t\sqrt{2\hat L(s)}\,ds,\qquad R(t):=\int_0^tr(s)\,ds\in\mathbb R^n .$$

$\tau$ is *effective time*: time weighted by the root training loss.

**Well-posedness of (SC).**
- The fitted values $f_t$ are unique, because they are the projection of $y$ onto a closed convex cone. The coefficients need not be unique; any minimizer may be used.
- Coefficients change only at firing events, since $r$ and hence the refit are constant in between. A saturated gate leaves $\mathrm{Sat}$ exactly when, after a refit, $c_m=0$ and $\sigma_mU_m<0$. Its clock then moves inward. Removing such gates does not change $f_t$, since $c_m=0$ stays optimal.
- I have not proved that (SC) has finitely many events in bounded time. Every (SC) statement below (Lemma 2.2(3), Theorem A2.3(2), Theorem A2.4, Corollary A2.5(a′, b)) is proved for every $t$ before the first accumulation point of event times, if there is one. The proofs use only the KKT conditions at each refit and the linearity of the clocks between events.
- All (SC) runs in Section 5 and in [`checks/A_r2_checks.out`](checks/A_r2_checks.out) §6 had finitely many events.

**Lemma 2.2 (basic facts) — Proved.**
1. $|U_m(t)|\le\|r(t)\|_n\le\|y-\bar y\|_n\le1$. Hence $\tau(t)\le t$.
2. In (LS), every fired gate has $U_m(s)=0$ for all $s$ after its firing time $t_m$. Hence $S_m(t)=\sigma_m\Theta$ for all $t\ge t_m$.
3. In (SC), $c_m(t)\ne0$ implies $S_m(t)=\mathrm{sgn}(c_m(t))\,\Theta$, and also $U_m(t)=0$. For a saturated gate with $c_m=0$, $\sigma_mU_m\le0$. Hence $|S_m(t)|\le\Theta$ for every candidate at all times.
4. *Scale invariance (one threshold).* If every candidate has the same threshold $\Theta$, then running the race with threshold $\lambda\Theta$ gives at time $\lambda t$ the state that threshold $\Theta$ gives at time $t$. The same holds when several thresholds are all multiplied by the same $\lambda$.

*Proof.*
1. $|g_m|\le1$, so $|\langle r,g_m\rangle_n|\le\|r\|_n$. The refit $f_t$ is the projection of $y$ onto a closed convex set that contains the constants, so it is at least as close to $y$ as $\bar y$ is.
2. These are the normal equations of least squares.
3. This is the definition of (SC) together with the KKT conditions. Where the constraint is inactive the gradient vanishes. Where it is active ($c_m=0$), moving $c_m$ in the allowed direction cannot decrease the loss, which gives $\sigma_mU_m\le0$.
4. The slopes $U_m$ depend only on the fired set, not on the thresholds. By induction over events, every event time and every clock is multiplied by $\lambda$. ∎

**What item 4 does and does not say about $\alpha$.**
- **The pure attach race.** Item 4 applies when all candidates are $k=2$ attach moves with one threshold $\Theta=c\log(1/\alpha)$. There, **$\alpha$ only sets the unit of time**, and the race's state depends on $t$ and $\alpha$ only through $t/\log(1/\alpha)$.
- **With fresh chains it fails.** Fresh-chain candidates ($k\ge3$ new layers in series; last bullet below) have thresholds $\Theta_k\approx c_k\alpha^{-(k-2)}$. These do not scale with $\log(1/\alpha)$, so $\Theta_k/\Theta$ depends on $\alpha$ and the order of events can change with $\alpha$.
- **Consequence for the user's architecture.** In an $L$-layer network started entirely at scale $\alpha$ (the README model), the first move must be a fresh chain with $k=L$, which costs time about $\alpha^{-(L-2)}/U$ (Heuristic). For three weight layers that is about $\alpha^{-1}/U\gg\log(1/\alpha)$. So for that architecture, "training hasn't taken long" cannot mean "$t/\log(1/\alpha)$ is small": by the time anything has been learned, it is large.
- **What the bounds still give.** The bounds below stay valid in the extended race when $\Theta$ is the smallest threshold (see the fresh-chain bullet), but they are then loose. During the first plateau $\|r\|_n\approx\|y-\bar y\|_n$, so $\tau$ grows almost like $t$.
- **Which networks the depth-one race models.** The depth-one race started at time $0$ models the first moves of a diagonal or 2-homogeneous network, not the first move of a three-layer network.
- **The μP experiments.** The hidden layers start at $O(1)$ scale and only the readout is small. There is no single $\alpha$, neither rate law applies literally, and the recipe of §2.3 treats $\Theta$ as a fitted constant (Heuristic).

**Faithfulness to small-initialization GD.**
- **Depth one, 2-homogeneous units — Literature, partly from memory.** Take a diagonal linear network $f=\sum_m u_mv_mg_m$ over a fixed finite dictionary, initialized at scale $\alpha$, and train it by gradient flow on the empirical square loss. Pesme–Flammarion (NeurIPS 2023) show that as $\alpha\to0$, with time rescaled by $\log(1/\alpha)$, the trajectory converges to a piecewise-constant saddle-to-saddle process. That process is given by a LARS-like recursion and ends at the minimum-$\ell_1$ interpolator; this part was checked at abstract level.
  - My recollection is that the recursion corresponds to the (SC) race. The accumulated negative gradients play the role of $S_m$ and stay in $[-\Theta,\Theta]$, and each saddle minimizes the loss under the sign constraints. I could not open the paper to confirm the exact form.
  - **One known difference:** their diagonal network has no free intercept, whereas (SC) refits an unconstrained intercept at all times. (SC) therefore corresponds to a diagonal network with a separately trained, unpenalized bias, or to centred data (Heuristic).
- **(LS) is not the depth-one GD limit.** In (LS), fired coefficients can change sign freely, which a diagonal network cannot do in the small-$\alpha$ limit. Theorem A2.3(1) and Corollary A2.5(a) are stated for (LS). Theorem A2.3(2) gives the (SC) version, which is the one with (from-memory) literature backing at depth one.
- **Two-layer networks with learned directions — Literature, from memory.** In Alternating Gradient Flows (Kunin et al., NeurIPS 2025), dormant neurons accumulate utility and activate when it reaches a threshold proportional to $\log(1/\alpha)$. Accumulated utility is carried across jumps, not reset.
- **Deeper attach moves — Heuristic** ([README](../README.md) §1). The availability time $a_m$ models the fact that a unit reading a dormant wire receives almost no gradient.
- **Fresh chains — Heuristic extension.** Fresh chains ($k\ge3$ new layers) can be added as candidates with threshold $\Theta_k\gtrsim\alpha^{-(k-2)}\gg\Theta$. A chain adds up to $k-1$ gates and $k-1$ levels in one move. If $\Theta$ is the smallest threshold, the proof of Proposition A2.1 gives depth $\le(k_{\max}-1)\tau/\Theta$, and the proof of Theorem A2.3 bounds the number of *moves*, with each chain's output gate as its feature; then $T\le(k_{\max}-1)\times$(moves). These forms are valid but loose, since $\Theta_k\gg\Theta$.

**Why not reset the clocks?** In a *reset race*, every dormant clock returns to $0$ after each event, and one gate fires per event. Then $T(t)\le\tau(t)/\Theta$ trivially. But GD does not forget the growth of dormant units, so this model is not faithful. In particular it misses simultaneous growth, which Proposition A2.2 shows is generic.

### 2.2 What training time controls

**Proposition A2.1 (depth grows at most linearly in time) — Proved.** In either variant, a gate of depth $D$ fires only at times $t$ with $\tau(t)\ge D\Theta$. Here depth counts the gates on the longest path from the inputs. Consequently the depth of the circuit at time $t$ is at most $\lfloor\tau(t)/\Theta\rfloor\le\lfloor t/\Theta\rfloor$. In (LS), the number of events up to time $t$ is finite.

*Proof.* Use induction on $D$. A gate $m$ fires at $t_m$ with $\Theta=|S_m(t_m)|\le\int_{a_m}^{t_m}\|r\|_n=\tau(t_m)-\tau(a_m)$.
- If $D=1$, then $a_m=0$.
- If $D\ge2$, some source of $m$ has depth $D-1$ and fired at a time no later than $a_m$. By induction $\tau(a_m)\ge(D-1)\Theta$.

Finiteness of events: only finitely many syntactic gates have depth at most $t/\Theta$, every event fires at least one new gate, and in (LS) gates never unfire. ∎

**Proposition A2.2 (training time does not bound the number of gates uniformly over libraries) — Proved.** Use the population race (inner products under $P$), uniform inputs, and $y=\mathrm{MAJ}(x_1,\dots,x_m)$ with $m\le d$ odd. Let
$$u_m=\binom{m-1}{(m-1)/2}2^{-(m-1)}=\sqrt{\tfrac{2}{\pi m}}\,(1+o(1)).$$
1. If $G=\{\text{identity}\}$, the $m$ identity gates $x_1,\dots,x_m$ fire together at $t=\Theta/u_m$, and nothing fires earlier. So $T$ jumps from $0$ to $m\approx\frac2\pi(t/\Theta)^2$.
2. If $G=\{\text{identity},\ \mathrm{AND}(\pm a,\pm b),\ \mathrm{XOR}\}$ (the toy library of Section 5), then exactly $m^2$ **distinct functions (up to sign)** fire together at $t=\Theta/u_m$. These are the $m$ identities, and $\mathrm{AND}(x_i,x_j)$ and $\mathrm{AND}(\neg x_i,\neg x_j)$ for each pair $i<j\le m$. So $T$ jumps to $m^2\approx(\frac2\pi)^2(t/\Theta)^4$.
   - This counts distinct functions, merging unordered and repeated source pairs. Under Lemma 1.1's syntactic convention (ordered source tuples, repeats allowed), syntactic duplicates such as $\mathrm{AND}(x_i,x_i)=x_i$, $\mathrm{AND}(\neg x_i,\neg x_i)=-x_i$ and $\mathrm{AND}(x_j,x_i)$ fire as well.
   - The referee verified the count and the clock bound $\le\Theta/2$ for $m=3$ and $m=5$ ([`checks/referee_A_r1.out`](checks/referee_A_r1.out) §§3–4).
3. Candidates that compute the same function up to sign and have the **same availability time** fire together. Hence the *syntactic* gate count is not bounded by any function of $t/\Theta$ uniformly over libraries.
   - For a fixed finite library it is bounded: at time $t$ it is at most the number of syntactic candidates of depth $\le\lfloor\tau(t)/\Theta\rfloor$. For example, at $t=\Theta$ it is at most the number of depth-one candidates, $|G|d^k$.
   - Duplicates with *different* availability times behave differently. In (LS), once the earlier copy has fired, its function has utility $0$ forever (Lemma 2.2(2)), so a later-available copy whose clock has not reached $\Theta$ never fires.

So with fan-in 2, $T$ can grow like $(t/\Theta)^4$. No bound $T\le C(t/\Theta)^2$ with $C$ independent of $d$ holds for the toy library, uniformly over the targets $\mathrm{MAJ}_m$, $m\le d$. A useful size bound must depend on how correlated the fired gates are, as in Theorem A2.3. The empirical race reproduces item 2: for maj3 at $n=4096$, 9 gates fire between $t/\Theta=1.98$ and $2.12$, against the population value $1/u_3=2$ (Section 5).

*Proof.*
- *Utilities.* $\mathrm{MAJ}_m$ is odd, so $\mathbb E[y]=\mathbb E[yx_ix_j]=0$. Also $\mathbb E[yx_i]=P(\text{the other } m-1 \text{ votes tie})=u_m$ for $i\le m$, and $\mathbb E[yx_i]=0$ for $i>m$. As $\pm1$ functions, $\mathrm{AND}(\epsilon_1a,\epsilon_2b)=(\epsilon_1a+\epsilon_2b+\epsilon_1\epsilon_2ab-1)/2$ and $\mathrm{XOR}(a,b)=ab$. This gives the depth-one utilities at time $0$:

  | candidate | utility |
  |---|---|
  | $x_i$, $i\le m$ | $u_m$ |
  | $\mathrm{AND}(x_i,x_j)$, $\mathrm{AND}(\neg x_i,\neg x_j)$, $i,j\le m$ | $\pm u_m$ |
  | $\mathrm{AND}(x_i,\neg x_j)$ | $0$ |
  | AND-type with exactly one relevant input | $\pm u_m/2$ |
  | XOR, or no relevant input | $0$ |

- *Items 1–2.* The residual stays equal to $y$ until the first event. So exactly $m+2\binom m2=m^2$ distinct functions reach $|S|=\Theta$ at $t=\Theta/u_m$, when every other clock is at most $\Theta/2$. The asymptotics of $u_m$ follow from Stirling's formula.
- *Item 3.* $U_m(t)=\langle r(t),g_m\rangle$ depends on $m$ only through $g_m$, so candidates with $g_m=\pm g_{m'}$ have $U_m=\pm U_{m'}$ at all times. If also $a_m=a_{m'}$, then $S_m=\pm S_{m'}$ at all times, and the two reach $\Theta$ together. For the unboundedness, add $J$ arity-one gates $\phi_1=\dots=\phi_J=\mathrm{id}$ to $G$: in item 1, $Jm$ syntactic gates then fire at $\Theta/u_m$, for every $J$. ∎

**Theorem A2.3 (gate count times incoherence) — Proved.** For a set $B$ of gates, let $K_B$ be the centred empirical Gram matrix, $(K_B)_{mm'}=\langle g_m-\bar g_m,g_{m'}-\bar g_{m'}\rangle_n$, and let $\kappa_B=\lambda_{\max}(K_B)$.
1. **(LS), any depth.** At every time $t$, every set $B$ of gates fired by time $t$ satisfies
   $$|B|\;\le\;\kappa_B\Bigl(\frac{\tau(t)}{\Theta}\Bigr)^2 .$$
   If every gate in $B$ has availability time $0$ (for instance, depth one), $\tau(t)$ may be replaced by $\|R(t)\|_n\le\tau(t)$.
2. **(SC).** At every time $t$, $|\mathrm{Sat}(t)|\le\kappa_{\mathrm{Sat}(t)}\,(\|R(t)\|_n/\Theta)^2$. Since $\mathrm{supp}\,c(t)\subseteq\mathrm{Sat}(t)$, the same holds for the support.

In particular $T(t)\le\kappa(t)(\tau(t)/\Theta)^2$. Here $T(t)$ counts the distinct functions (up to sign) among the fired gates, and $\kappa(t)=\kappa_B$ for one representative $B$ of each.

Gershgorin's theorem gives $\kappa_B\le1+(|B|-1)\mu_B$, where $\mu_B$ is the largest absolute centred empirical covariance between two gates of $B$. So whenever $\mu_B(\tau/\Theta)^2<1$,
$$|B|\le\frac{(1-\mu_B)(\tau/\Theta)^2}{1-\mu_B(\tau/\Theta)^2}.$$
Like $\kappa_B$, $\mu_B$ is a property of the fired gates. A library-wide $\mu$ does not help for the toy library. There $\mu=1/2$ (for $x_1$ against $\mathrm{AND}(x_1,x_2)$), and the condition fails once $\tau\ge\sqrt2\,\Theta$. Corollary A2.5(a′) uses the library-wide top eigenvalue instead.

*Tightness.* The population analogue (the same statement and proof with $\langle\cdot,\cdot\rangle_P$) is tight up to the factor $\pi/2$. In Proposition A2.2(1) the identity gates are orthonormal, so $\kappa=1$, and $T=m$ while $(\tau/\Theta)^2=1/u_m^2\approx\pi m/2$. In the toy runs, the empirical bound is attained on par2: one gate, $\kappa\tau^2/\Theta^2=1.00$ (Section 5).

*Proof of item 1.*
1. By Lemma 2.2(2), $\sigma_mS_m(t)=\Theta$ for each $m\in B$.
2. The intercept is refit, so $r(s)$ has empirical mean zero, and $\langle r(s),g_m\rangle_n=\langle r(s),\tilde g_m\rangle_n$ with $\tilde g_m=g_m-\bar g_m$.
3. Write $B(s)=\{m\in B:a_m\le s\}$. Then
$$|B|\,\Theta=\sum_{m\in B}\sigma_m\int_{a_m}^t\langle r(s),\tilde g_m\rangle_n\,ds=\int_0^t\Bigl\langle r(s),\sum_{m\in B(s)}\sigma_m\tilde g_m\Bigr\rangle_n ds\le\int_0^t\|r(s)\|_n\Bigl\|\sum_{m\in B(s)}\sigma_m\tilde g_m\Bigr\|_n ds .$$
4. $\|\sum_{m\in B(s)}\sigma_m\tilde g_m\|_n^2=\sigma^\top K_{B(s)}\sigma\le\lambda_{\max}(K_{B(s)})\,|B(s)|\le\kappa_B|B|$, because a principal submatrix has no larger top eigenvalue.
5. Hence $|B|\Theta\le\tau(t)\sqrt{\kappa_B|B|}$, which rearranges to the claim.
6. *Availability time $0$.* If all $a_m=0$, then $S_m(t)=\langle R(t),\tilde g_m\rangle_n$, using $\langle R(t),1\rangle_n=\int_0^t\langle r,1\rangle_n=0$. So $|B|\Theta=\langle R(t),\sum_{m\in B}\sigma_m\tilde g_m\rangle_n\le\|R(t)\|_n\sqrt{\kappa_B|B|}$. Finally, $\|R(t)\|_n\le\int_0^t\|r\|_n=\tau(t)$.

*Proof of item 2.* Every $m\in\mathrm{Sat}(t)$ has $\sigma_mS_m(t)=\Theta$, by the definition of $\mathrm{Sat}$ and of $\sigma_m$. In (SC) all $a_m=0$, and the intercept is free at all times. So step 6 applies verbatim with $B=\mathrm{Sat}(t)$. ∎

**Theorem A2.4 (the readout's $\ell_1$ norm grows at most linearly in time) — Proved.** Use the (SC) variant on a depth-one dictionary. For every $t$,
$$\Theta\sum_m|c_m(t)|\;=\;\langle R(t),f_t\rangle_n\;\le\;\|R(t)\|_n\sqrt{1-\bar y^2}\;\le\;\tau(t),\qquad |c_0(t)|\le1+\|c(t)\|_1 .$$

*Proof.*
1. All $a_m=0$, so $S_m(t)=\langle R(t),g_m\rangle_n$.
2. By Lemma 2.2(3), $c_mS_m(t)=|c_m|\Theta$ for every $m$, and this holds trivially when $c_m=0$.
3. $\langle R(t),1\rangle_n=\int_0^t\langle r(s),1\rangle_n\,ds=0$. Hence $\Theta\|c\|_1=\sum_mc_m\langle R,g_m\rangle_n=\langle R,f_t-c_0\rangle_n=\langle R,f_t-\bar y\rangle_n$.
4. The refit $f_t$ is the projection of $y$ onto the closed convex cone $\mathbb R\mathbf 1+\mathrm{cone}\{\sigma_m\tilde g_m:m\in\mathrm{Sat}\}$. Constants are orthogonal to centred vectors, so $f_t-\bar y$ is the projection of $y-\bar y$ onto a cone, and therefore $\|f_t-\bar y\|_n\le\|y-\bar y\|_n=\sqrt{1-\bar y^2}$.
5. Apply Cauchy–Schwarz, and $\|R(t)\|_n\le\int_0^t\|r\|_n=\tau(t)$.
6. Finally $c_0=\bar y-\sum_mc_m\bar g_m$. ∎

This is a LASSO-type duality. At the LASSO solution with penalty $\lambda$, $\|\beta\|_1=\langle r,X\beta\rangle/\lambda$. Here the integrated residual $R(t)$ plays the role of $r$, and $\Theta$ the role of $\lambda$. It also explains why the race drifts toward the minimum-$\ell_1$ interpolant.

**Numerical.** The identity holds to machine precision at every event of the (SC) runs in Section 5. Those runs have no exits from the saturated set. The corrected [`race_bounds.Race`](checks/race_bounds.py) was also run on 40 random correlated dictionaries, which have 130 exits ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §6). There:
- the identity holds to $3\cdot10^{-14}$;
- $S_m=\langle R,g_m\rangle_n$ holds to $2\cdot10^{-14}$;
- $|S|\le\Theta$ holds exactly;
- the support has $|U_m|\le5\cdot10^{-16}$;
- the (SC) size bound of Theorem A2.3(2) holds with ratio at most $0.715$.

### 2.3 Test error as a function of training time

**Corollary A2.5 — Proved for (a) and (a′); Proved given L1–L3 for (b).** Let $h_t=\mathrm{sgn}f_t$ and $D(t)=\lfloor\tau(t)/\Theta\rfloor$. Each of (a), (a′) and (b) holds with probability at least $1-\delta$, simultaneously for all $t\ge0$.
- **(a) Decomposition: size $\le$ incoherence $\times$ time$^2$** ((LS), any depth). Theorem A1 (all items) holds for $h_t$ with $T=T(t)$, and $T(t)\le\lfloor\kappa(t)\tau(t)^2/\Theta^2\rfloor$. Since $L_T$ is increasing in $T$, $L_{T(t)}$ may be replaced by $L_{\lfloor\kappa\tau^2/\Theta^2\rfloor}$. At zero training error, for example (item 4),
  $$\mathrm{err}(h_t)\le\frac{L_{\lfloor\kappa\tau^2/\Theta^2\rfloor}}{n}\approx\frac{\kappa\tau^2}{\Theta^2 n}\Bigl(\log|G|+k\log\bigl(d+\tfrac{\kappa\tau^2}{\Theta^2}\bigr)\Bigr)+\frac{\kappa^2\tau^4\log2}{\Theta^4n}.$$
  *Reading.* This is **not** a bound in terms of training time alone:
  - $\kappa(t)$ is a property of the learned circuit, and it can grow with $T$. In the population, $\kappa=3$ for maj3 after its first event and $5.3$ after its second, and $\kappa=5$ for $\mathrm{MAJ}_5$ after its first ([`checks/referee_A_r1.out`](checks/referee_A_r1.out) §§3–4).
  - $T(t)$ is observable whenever $\kappa(t)$ is. Since $T(t)\le\lfloor\kappa\tau^2/\Theta^2\rfloor$ and $L_T$ is increasing, (a) is never tighter than Theorem A1 at the realized $T(t)$.
  - Its content is explanatory: it says which combination of size and incoherence training time controls.
- **(a′) Time-only count version for a fixed library** ((LS) any depth, or (SC)).
  - *Definitions.* For $D\ge1$, let $\mathcal F_{\le D}$ be the set of distinct (up to sign, on the sample) non-constant functions computed by gates of depth $\le D$ over the library. Let $\bar\kappa_D$ be the top eigenvalue of their centred empirical Gram matrix. Both depend only on the library and the unlabelled inputs $x_1,\dots,x_n$, not on the labels or the dynamics.
  - *Convention.* (a′) is stated for a race in which candidates that coincide up to sign on the sample are identified, and the refit uses one representative per class (as in Section 5). $T(t)$ then counts these classes, so $h_t\in\mathcal H_{T(t)}$. Without this merging the bound can fail: gates that are distinct on $\mathcal X$ but equal on the sample all fire together. In the referee's example ($d=6$, $n=4$, par2, first event of the depth-one (LS) race) 24 gates distinct on $\mathcal X$ fire, against $\bar T=2$ ([`checks/referee_A_r2.out`](checks/referee_A_r2.out) §2).
  - *Statement.* Theorem A1 (all items) holds for $h_t$ with $T=T(t)$, and
    $$T(t)\le\bar T(t):=\min\Bigl\{|\mathcal F_{\le D(t)}|,\ \Bigl\lfloor\bar\kappa_{D(t)}\frac{\tau(t)^2}{\Theta^2}\Bigr\rfloor\Bigr\},\qquad\text{so } L_{T(t)}\le L_{\bar T(t)} .$$
  - *Depth one.* For a depth-one race ((SC), or (LS) on a depth-one dictionary), $D=1$, and $\tau(t)$ may be replaced by $\|R(t)\|_n$. The same holds for (LS) at any depth while $\tau(t)<2\Theta$, since every fired gate then has depth one.
- **(b) Norm version, time only** ((SC), depth one, $|\mathcal F_1|\le|G|d^k$). The two bounds of Theorem A1′ hold with $B_j\le2\max(1,\tau(t)/\Theta)$. The gap is therefore
  $$O\Bigl(\bigl(1+\tfrac{\tau(t)}{\Theta}\bigr)\sqrt{\tfrac{\log(|G|d^k)}{n}}\Bigr),$$
  linear in training time measured in units of $\Theta$, and independent of the number of gates.

*Proof.*
- (a): Theorem A1 holds on one event uniformly in $T$, and the predictor at every time lies in $\mathcal H_{T(t)}$. Then apply Theorem A2.3.
- (a′): By Proposition A2.1, every fired gate has depth $\le D(t)$. By the merging convention, the set $B$ of representatives of the $T(t)$ fired classes consists of functions distinct up to sign on the sample. So $B$ is a subset of $\mathcal F_{\le D(t)}$, and $|B|\le|\mathcal F_{\le D(t)}|$.
  - Flipping the sign of some functions conjugates the Gram matrix by a diagonal $\pm1$ matrix and does not change its eigenvalues. So $K_B$ is a principal submatrix of the Gram matrix of $\mathcal F_{\le D(t)}$, and $\kappa_B\le\bar\kappa_{D(t)}$.
  - Theorem A2.3(1) gives the bound, or Theorem A2.3(2) for (SC), whose gates in use are $\mathrm{supp}\,c\subseteq\mathrm{Sat}\subseteq\mathcal F_1$.
  - The depth-one refinements are those of Theorem A2.3.
- (b): Combine Theorems A1′ and A2.4. ∎

**Value of (a′) for the toy library.**
- *Population value.* The population version of $\bar\kappa_1$ is exactly $d$. By Parseval, the centred Gram matrix of the 2205 depth-one gates is $AA^\top$, where row $m$ of $A$ lists the Fourier coefficients of $g_m$ on the $d+\binom d2$ characters $x_i$ and $x_ix_j$.
  - In $A^\top A=\sum_m a_ma_m^\top$, summing over the four sign patterns $\mathrm{AND}(\pm x_i,\pm x_j)=(\pm x_i\pm x_j\pm x_ix_j-1)/2$ cancels every off-diagonal term.
  - Each $x_i$ collects $1$ from its identity gate and $1$ from each of the $d-1$ pairs containing it, and each $x_ix_j$ collects $1$ from the ANDs and $1$ from XOR. So $A^\top A=\mathrm{diag}(d,\dots,d,2,\dots,2)$ and $\bar\kappa_1^{\rm pop}=d$.
  - This is confirmed exactly on the full cube for $d=8$.
- *Empirical values.* $\bar\kappa_1=88,\,58,\,41,\,35,\,32$ at $n=64,\,256,\,1024,\,4096,\,16384$ (all for $d=30$; [`checks/A_r2_checks.out`](checks/A_r2_checks.out) §3).
- *Resulting bound* at zero training error, with $x=\|R\|_n/\Theta$:

  | $n$ | $x=1$ | $x=1.5$ | $x=1.99$ |
  |---|---|---|---|
  | 4096 | 0.21 ($\bar T=34$) | 0.41 | 0.61 |
  | 16384 | 0.053 ($\bar T=32$) | 0.115 | 0.195 |

- *Comparison.* Theorem A1 at the realized size gives 0.004 and 0.001 for par2, which fires a single gate at $\tau=\Theta$.

So (a′) answers the user's question literally: training hasn't taken long, so the circuit is small, so a Chernoff bound applies. But it does so only at depth one, only for $\tau\lesssim2\Theta$, and with a library-incoherence factor $\bar\kappa_1\approx d$, which costs about a factor of 30 in size.

So the user's statement holds in the race model, with "size" read as *depth*, *incoherent size* or *readout $\ell_1$ norm*, and "time" read as $\tau(t)/\Theta$. Training time bounds the raw gate count only through an incoherence factor: the learned circuit's $\kappa(t)$, or the library's $\bar\kappa\approx d$ (Corollary A2.5(a′)). No bound with a library-independent constant holds (Proposition A2.2).

**Proposition A2.6 (no fitting of noise before $t\approx\Theta\sqrt n$ on parity-like targets) — Proved.** Suppose $\mathbb E[y]=0$ and $\mathbb E[yg]=0$ for every depth-one candidate $g$; for example, $y=\chi_S$ with $|S|>k$ under uniform inputs. Let $M_1$ be the number of depth-one candidates and
$$\epsilon=\sqrt{2\log(2(M_1+1)/\delta)/n}.$$
With probability at least $1-\delta$, no gate fires before time $\Theta/(2\epsilon)$. Until then the predictor is the constant $\mathrm{sgn}\,\bar y$, with test error $1/2$.

*Proof.* By Hoeffding's inequality and a union bound, $|\langle y,g_m\rangle_n|<\epsilon$ for all $m$ and $|\bar y|<\epsilon$, except with probability at most $2(M_1+1)e^{-n\epsilon^2/2}=\delta$. Before the first event $r=y-\bar y$, so $|U_m|=|\langle y,g_m\rangle_n-\bar y\,\bar g_m|<2\epsilon$. A firing needs $\Theta\le\int|U_m|<2\epsilon t$. ∎

**Heuristic: the early-stopping window.**
- A signal gate with population utility $u$ fires at $t\approx\Theta/u$. Noise gates fire at $t\approx\Theta/\max_m|\hat U_m-U_m|\approx\Theta\sqrt{n/(2\log 2M)}$.
- So the race has a clean window before it starts fitting noise exactly when $u\gg\sqrt{\log M/n}$, which is the correlational-SQ sample size.
- The size bound of Theorem A2.3 reaches $T\approx\kappa(\tau/\Theta)^2\approx\kappa n/(2\log 2M)$ at about the same time, where $L_T/n=\Omega(1)$. In this sense the time-based bound is sharp about *when* overfitting can start.
- Numerically, on par3 the first noise gate fires at $t/\Theta=2.65,\,5.16,\,9.97,\,20.0$ for $n=64,256,1024,4096$. The proved lower bound is $0.84,1.68,3.35,6.71$, and the heuristic is $1.95,3.91,7.81,15.6$.

**Recipe for the real runs (Heuristic; SGD runs only).**
1. For an SGD run, the saved training-loss curve gives $\tau(t)=\int\sqrt{2\hat L}\,dt$, with $t$ = base learning rate × steps. The per-layer μP multipliers rescale the effective threshold, which is fitted anyway in step 2.
2. The first jump of a Fourier coefficient of utility $U_1$, at time $t_1$, calibrates $\Theta\approx U_1t_1$.
3. Then $\tau(t)/\Theta$ along the run is the race model's "elapsed complexity budget". Comparing it with the measured depth and the readout or path norm tests Proposition A2.1 and Theorem A2.4 outside the toy.

No such calibration is proposed for **Adam**, the experiments' main optimizer. Adam normalizes each coordinate's update, so the update size is roughly independent of the gradient's magnitude. Clock increments are then not proportional to $U$, and the race's rate law does not apply as stated ([README](../README.md) §4).

---

## 3. A3: SGD, online learning, and reuse

With fresh minibatches, the natural statement is not a train/test comparison but *reproduction*: the stochastic run makes the same moves as the population run, so its test error is the population model's. What is proved here is narrower than that slogan.
- **Greedy argmax model.** This model adds one gate per step, the one of largest empirical utility. Theorem A3.1 proves that the circuit is reproduced when the population run has a utility gap $\gamma>0$ at every step and each per-step batch has $b\gtrsim\max\{TR^2/(\lambda_*\gamma^2),\,T^2/\lambda_*^2\}\log(MT/\delta)$ samples. The second term comes from the theorem's Gram condition and dominates when $T/\lambda_*$ is large.
  - For par2 this is $b\ge2254$, against $b=64$ in the experiments, so **the theorem does not cover the experiments' SGD**.
  - The same theorem covers full-batch training on one sample of that size.
  - Theorem A3.5 covers minibatches drawn with reuse from a fixed sample, when both $n$ and $b$ exceed a similar threshold.
- **SGD race.** Only clock concentration is proved (Lemma A3.2). Reproducing the population race needs two further ingredients that are not proved here (§3.2), so that claim is Heuristic.

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

**Empirical greedy run (EG).** At step $t$ the run uses a batch $B_t$ of $b$ samples. Either $B_t=S$ for every $t$ (**full batch**), or the $B_t$ are **fresh** independent batches. EG refits by least squares on $B_t$ over its current circuit, giving residual $\hat r_t$. It then adds a candidate maximizing $|\langle\hat r_t,g_m\rangle_{B_t}|$. Its final predictor is the sign of the least-squares refit over $C_T$ on $B_T$.

**Theorem A3.1 (decision stability) — Proved.** Let $\epsilon:=\gamma/\bigl(2(1+\sqrt{2T/\lambda_*})\bigr)$. Suppose
$$b\;\ge\;\frac{2R^2}{\epsilon^2}\log\frac{4\sum_{t<T}(M_t+t+1)}{\delta}\qquad\text{and}\qquad b\;\ge\;\frac{8(T+1)^2}{\lambda_*^2}\log\frac{4(T+1)^3}{\delta}.$$
Then, for both the full-batch and the fresh-batch protocol, with probability at least $1-\delta$:
1. EG's first $T$ gates compute the same functions as $m_0,\dots,m_{T-1}$, so its circuit equals $C_T$.
2. If $y\in V_T$ almost surely (an *exact representation*), EG's final predictor equals $y$ almost surely: test error $0$.

Moreover:

3. With probability at least $1-2\delta$, EG's final predictor lies in the **data-independent** class $\mathcal H(C_T)$ of sign readouts over $C_T$, and Theorem A1's four bounds hold for it with $L=\rho_T+\log(1/\delta)$ in place of $L_T$. That is, there is no wiring term and no union over $T$. The bounds are on the sample used for the final refit: $S$ for full batch, $B_T$ for fresh batches.

The conclusions remain true with $(\gamma,R,\lambda_*)$ replaced by any $(\gamma',R',\lambda')$ with $\gamma'\le\gamma$, $R'\ge R$ and $\lambda'\le\lambda_*$, since the proof uses them only as bounds.

*Proof.* The functions $r_t$, $g_m$ and $K_t$ belong to the population run and do not depend on the data, so union bounds over them are legitimate whether or not batches are reused. Let $E$ be the event that, for all $t\le T$:
- (i) $|\langle r_t,g\rangle_{B_t}-\mathbb E[r_tg]|<\epsilon$ for every $g\in\mathcal M(C_t)\cup C_t\cup\{1\}$, using steps $t<T$ only;
- (ii) every entry of the empirical Gram matrix $\hat K_t$ of $(1,C_t)$ on $B_t$ is within $\lambda_*/(2(T+1))$ of the corresponding entry of $K_t$.

Hoeffding bounds each event in (i) by $2e^{-b\epsilon^2/(2R^2)}$, since the summands lie in $[-R,R]$. It bounds each event in (ii) by $2e^{-b\lambda_*^2/(8(T+1)^2)}$, since the summands lie in $[-1,1]$. There are at most $\sum_{t<T}(M_t+t+1)$ events of type (i) and $(T+1)^3$ of type (ii). Under the two conditions on $b$, $P(E^c)\le\delta$.

On $E$, $\|\hat K_t-K_t\|_{\rm op}\le(t+1)\max|\text{entries}|\le\lambda_*/2$, so $\lambda_{\min}(\hat K_t)\ge\lambda_*/2$.

Induction on $t$: suppose EG's circuit computes $C_t$. Then its refit span is $V_t$. Since $y=f_t+r_t$ with $f_t\in V_t$, the empirical residual is $\hat r_t=(I-\hat\Pi_t)r_t$, where $\hat\Pi_t$ is the empirical projection onto $V_t$. Let $v=(\langle r_t,g\rangle_{B_t})_{g\in(1,C_t)}$. The population normal equations give $\mathbb E[r_tg]=0$ for these $g$, so on $E$, $\|v\|^2<(t+1)\epsilon^2$. Hence
$$\|\hat\Pi_tr_t\|_{B_t}^2=v^\top\hat K_t^{-1}v<\frac{2(t+1)\epsilon^2}{\lambda_*}.$$
Therefore, for every candidate,
$$\bigl|\langle\hat r_t,g_m\rangle_{B_t}-U_t(m)\bigr|\le\bigl|\langle r_t,g_m\rangle_{B_t}-U_t(m)\bigr|+\|\hat\Pi_tr_t\|_{B_t}<\epsilon\bigl(1+\sqrt{2T/\lambda_*}\bigr)=\gamma/2 .$$
With the gap $\gamma$, every empirical maximizer computes $\pm m_t$: a candidate that differs from $\pm m_t$ as a function has empirical utility strictly smaller. This proves item 1.

For item 2: if $r_T=0$ then $\hat r_T=0$. Because $\hat K_T$ is nonsingular, the least-squares coefficients are unique, and the population coefficients already give zero empirical residual. So the two coincide, and the predictor equals $f_T=y$.

For item 3: on $E$ the final predictor lies in $\mathcal H(C_T)$, a fixed class with $\log|\mathcal H(C_T)|\le\rho_T$. Apply the single-class form of Theorem A1 at confidence $\delta$ on the sample used for the final refit; for fresh batches that is $B_T$, which is iid from $P$. Add $P(E^c)\le\delta$. ∎

**Remark (the form $b\approx\log(MT/\delta)/\gamma^2$).** Suppose the readout is fitted separately, for example on a larger held-out batch or by a slow averaged SGD readout. Suppose it achieves $|\langle\hat r_t-r_t,g\rangle_{B_t}|\le\eta_{\rm ro}<\gamma/2$ for every candidate, surely or on an event whose failure probability is added. Then the same proof needs only
$$b\ge\frac{2R^2}{(\gamma/2-\eta_{\rm ro})^2}\log\frac{4\sum_{t<T}M_t}{\delta},$$
with no $T/\lambda_*$ factor. This is the batch size $\approx\log(MT/\delta)/\gamma^2$ that reproduces the population run.

**How this compares with Occam.**
- For exact recovery, stability needs
  $$n\approx\max\Bigl\{\frac{TR^2}{\lambda_*\gamma^2},\ \frac{T^2}{\lambda_*^2}\Bigr\}\log\frac{MT}{\delta},$$
  whereas the Occam bound needs $T\log M/\varepsilon$ samples to reach error $\varepsilon$. The second term is the Gram condition of Theorem A3.1. For example, with $\gamma=1/2$, $R=1$, $T=30$ and $\lambda_*=1/2$, the utility condition needs $7.9\cdot10^4$ samples and the Gram condition $4.5\cdot10^5$ ([`checks/referee_A_r2.out`](checks/referee_A_r2.out) §5).
- Stability has no $1/\varepsilon$, but it pays $1/\gamma^2$. It says nothing when the population run has ties ($\gamma=0$) or zero utilities.
- **The constants are poor.** For par2 with XOR in $G$: $\gamma=1/2$, $R=\lambda_*=1$ and $M_0=2205$, so $\epsilon=0.10355$ and the theorem requires $n\ge2254$ ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §2). The toy run recovers par2 exactly at $n=64$. In a Monte Carlo of the greedy first step (Numerical), $\mathrm{XOR}(x_1,x_2)$ is an argmax in every run at $b=16$, with fresh or reused batches (§8 of the same file). That is guaranteed by Proposition A4.1, since $g=y$ on the batch attains the largest possible $|U|=\mathrm{Var}_b(y)$, so it carries no evidence. The informative frequency is that of a *unique* argmax, since tied gates equal to $\pm y$ on the batch can be picked instead. At $b=16$ it is 163/200 (reuse, $n=64$), 180/200 (reuse, $n=256$) and 375/400 (fresh), about 81–94%. At $b=64$ it is 200/200 (reuse, $n=1024$) and 400/400 (fresh) ([`checks/referee_A_r2.out`](checks/referee_A_r2.out) §7).
- **Ties** of the maj3 type, where a symmetric set of candidates is jointly added, need a version in which the gap separates "this cluster" from the rest. That extension is not written out here.

### 3.2 SGD in the race model

**Lemma A3.2 (SGD clocks concentrate) — Proved.** Run the race in discrete steps of size $\eta$:
- At step $i$, draw a fresh batch $B_i$ of $b$ iid samples, independent of the past $\mathcal F_{i-1}$.
- The current residual function $\hat r_i$ is $\mathcal F_{i-1}$-measurable, with $|\hat r_i|\le R$.
- For each candidate $m$ in a fixed finite set $\mathcal M$ (for instance every gate of every circuit with at most $T_{\max}$ gates), the availability indicator $\mathbb 1[m\text{ available at step }i]$ is $\mathcal F_{i-1}$-measurable. The clock increments by $\eta\,\mathbb 1[m\text{ available at step }i]\,\langle\hat r_i,g_m\rangle_{B_i}$.

Let $\bar S_m$ be the *drift clock*, the same sum with each $\langle\hat r_i,g_m\rangle_{B_i}$ replaced by its conditional mean $\mathbb E[\hat r_ig_m\mid\mathcal F_{i-1}]$. Then for $t_0=\eta I_0$,
$$P\Bigl(\max_{i\le I_0}\max_{m\in\mathcal M}|\hat S_m(i)-\bar S_m(i)|\ge x\Bigr)\le2|\mathcal M|\exp\Bigl(-\frac{bx^2}{2R^2\eta t_0}\Bigr).$$
That is, with probability at least $1-\delta$, every clock error up to time $t_0$ is at most $R\sqrt{2\eta t_0\log(2|\mathcal M|/\delta)/b}$.

*Proof.*
1. Fix $m$. The increment $D_i=\hat S_m(i)-\hat S_m(i-1)-(\bar S_m(i)-\bar S_m(i-1))$ is $\eta/b$ times a sum of $b$ conditionally iid, mean-zero terms, each in an interval of length $2R$; the availability factor is $\mathcal F_{i-1}$-measurable and in $\{0,1\}$. By Hoeffding's lemma, $\mathbb E[e^{\lambda D_i}\mid\mathcal F_{i-1}]\le e^{\lambda^2\eta^2R^2/(2b)}$.
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

Under these conditions (Heuristic), test error equals the population race's test error, and the only "generalization" question is approximation: does the population race find the target?

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

Consider the fresh-batch greedy model of Theorem A3.1 with an exact representation. It uses batches $B_0,\dots,B_T$, and the exact predictor is available only after the refit on $B_T$. So on the theorem's event, online mistakes come only from these $T+1$ batches, at most $(T+1)b$ of them. Bounding total mistakes in general, as the NNBayes total-mistake results do, would need a bound on the length of the greedy path; I do not give one.

### 3.4 Minibatches drawn with reuse from a fixed training set

**Proposition A3.4 — Proved (items 1, 2a, 3); item 2c is Heuristic.**
1. **Theorem A1 applies verbatim to discrete learners.** Suppose the learner's predictor at every step is a template circuit (the race, the greedy model, or any learner of Section 0, however its batches are drawn). Then it lies in $\mathcal H_{T(s)}$, and A1 is uniform over $T$, hence over steps. This says nothing about the neural network itself unless the network's predictor is first replaced by a circuit (Section 6).
2. **What reuse reproduces.**
   - (a) *Conditional on $S$ — Proved.* Given $S$, minibatches drawn with replacement from $S$ are fresh iid batches from the empirical distribution $P_n$. So Lemma A3.2 and Theorem A3.1 hold conditionally on $S$ with $P$ replaced by $P_n$. The drift clocks are then built from training-set utilities. The gap, $R$ and $\lambda_*$ are those of the full-batch greedy run on $S$, which are empirical quantities, not derived here from the population ones. The conclusion is reproduction of the **full-batch run on $S$**, not of the population run.
   - (b) *Unconditionally, for the greedy model — Proved:* Theorem A3.5 below compares the reuse run directly with the population run when both $n$ and $b$ are large.
   - (c) *For the SGD race at small $b$ — Heuristic.* Suppose the readout-tracking and crossing-margin conditions of §3.2 held for $P_n$. Then multi-epoch SGD would track the full-batch race on $S$ rather than the population race, so the no-overfitting conclusion of the fresh-batch case would not transfer, and generalization would have to come from item 1 (Theorem A1) or from Theorem A3.5. None of this is proved at $b=64$.
3. **First-occurrence validation.** Let the indices $i_1,i_2,\dots$ be iid uniform on $[n]$, independent of $S$. Let $s_1<s_2<\dots$ be the draws at which an index appears for the first time. Then for each fixed $K\le n$, with probability at least $1-\delta$,
$$\frac1K\sum_{k\le K}L(h_{s_k})\le\frac1K\sum_{k\le K}\ell(h_{s_k},z_{i_{s_k}})+\sqrt{\log(1/\delta)/(2K)},$$
where terms are set to $0$ if fewer than $K$ distinct indices are drawn. The left side is the average test loss of the iterates $h_{s_1},\dots,h_{s_K}$ *at the first-draw times*, which lie mostly in the first epoch. It is not an estimate of the final predictor's test loss.

*Proof of item 2a.* Conditionally on $S$, the batches satisfy the hypotheses of Lemma A3.2 (with $\mathcal F_{i-1}$ including $S$) and of the fresh-batch case of Theorem A3.1, with $P_n$ in place of $P$. Both proofs use nothing else about the batch distribution.

*Proof of item 3.* Let $\mathcal G_k$ be generated by everything revealed before draw $s_k$, together with the index $i_{s_k}$. The example $z_{i_{s_k}}$ has never been revealed. It is independent of $\mathcal G_k$, because the $z_j$ are iid and independent of the indices and of the internal randomness, and its law is $P$. Also, $h_{s_k}$ is $\mathcal G_k$-measurable. So $D_k=L(h_{s_k})-\ell(h_{s_k},z_{i_{s_k}})$ is a martingale difference with range 1, and the proof of Proposition A3.3 applies. The referee's Monte Carlo with an adaptive memorizing learner gives a mean gap of $0.0007\pm0.0007$ and a tail exceedance of $0.0015\le0.05$ ([`checks/referee_A_r1.out`](checks/referee_A_r1.out) §9). ∎

*In the experiment.* With batch size 64, after $s$ steps about $n(1-e^{-64s/n})$ distinct points have been seen. First-occurrence validation therefore covers roughly the first epoch, $n/64$ steps: 256 steps at $n=16384$, and almost nothing at small $n$. After that only A1, or a stability argument, applies. The protocol's online runs (fresh batch every step) are covered by Proposition A3.3 for the whole run.

**Theorem A3.5 (decision stability with reuse) — Proved.** Assume the setting and assumptions of Theorem A3.1 (population greedy run with gap $\gamma$, $|r_t|\le R$, $\lambda_*$), and let $\epsilon$ be as there.
- *Protocol.* Draw $S$ iid from $P$, of size $n$. At each step $t=0,\dots,T$, let $B_t$ consist of $b$ indices drawn iid uniformly from $[n]$, independently of $S$ and of the other steps. This is minibatch sampling *with replacement*, reusing $S$. Run EG on the batches $B_t$.
- *Conditions.* Let $N_1=\sum_{t<T}(M_t+t+1)$ and $N_2=(T+1)^3$. Suppose
$$\Bigl(\frac1{\sqrt n}+\frac1{\sqrt b}\Bigr)R\sqrt{2\log\frac{8N_1}{\delta}}\;\le\;\epsilon\qquad\text{and}\qquad\Bigl(\frac1{\sqrt n}+\frac1{\sqrt b}\Bigr)\sqrt{2\log\frac{8N_2}{\delta}}\;\le\;\frac{\lambda_*}{2(T+1)} .$$
- *Conclusion.* With probability at least $1-\delta$ over $S$ and the index draws, items 1 and 2 of Theorem A3.1 hold for the reuse run: its circuit is $C_T$, and under an exact representation its final predictor equals $y$ almost surely. With probability at least $1-2\delta$, Theorem A1's bounds hold for its final predictor on the sample $S$, with $L=\rho_T+\log(1/\delta)$.

Equivalently, the conditions are those of Theorem A3.1 with $b$ replaced by $n_{\rm eff}=(n^{-1/2}+b^{-1/2})^{-2}\ge\min(n,b)/4$ and $\delta$ by $\delta/2$. For par2 ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §2):
- $n=b\ge9530$;
- as $n\to\infty$, $b\ge2383$;
- at $n=16384$, $b\ge6225$;
- $b=64$ is covered at no $n$.

*Proof.* Let $\mathcal F_t=\{r_tg:g\in\mathcal M(C_t)\cup C_t\cup\{1\}\}$ for $t<T$, and $\mathcal Q_t=\{gg':g,g'\in(1,C_t)\}$ for $t\le T$. These are fixed functions of the population run: at most $N_1$ functions bounded by $R$ in total, and at most $N_2$ bounded by $1$. For $s\in\{n,b\}$ put $\epsilon_s=R\sqrt{2\log(8N_1/\delta)/s}$ and $\eta_s=\sqrt{2\log(8N_2/\delta)/s}$.
1. *Sample step.* By Hoeffding's inequality and a union bound, with probability at least $1-\delta/2$ over $S$: $|\langle\varphi\rangle_S-\mathbb E\varphi|<\epsilon_n$ for every $\varphi\in\bigcup_t\mathcal F_t$, and $<\eta_n$ for every $\varphi\in\bigcup_t\mathcal Q_t$. Indeed, $2N_1e^{-n\epsilon_n^2/(2R^2)}=\delta/4$ and $2N_2e^{-n\eta_n^2/2}=\delta/4$.
2. *Batch step.* Conditionally on $S$, each $B_t$ is $b$ iid draws from $P_n$. The functions are fixed, and on $S$ they are bounded by $R$ (resp. $1$) almost surely. So, by the same computation, with conditional probability at least $1-\delta/2$: $|\langle\varphi\rangle_{B_t}-\langle\varphi\rangle_S|<\epsilon_b$ (resp. $\eta_b$) for all $t$ and all $\varphi$.
3. *Combination.* On the intersection, which has probability at least $1-\delta$:
   - $|\langle\varphi\rangle_{B_t}-\mathbb E\varphi|<\epsilon_n+\epsilon_b\le\epsilon$ for $\varphi\in\mathcal F_t$;
   - every Gram entry on $B_t$ is within $\eta_n+\eta_b\le\lambda_*/(2(T+1))$ of $K_t$.

   These are exactly the events (i) and (ii) in the proof of Theorem A3.1. Apart from them, that proof uses only the pointwise identity $y=f_t+r_t$. So its induction applies verbatim and gives items 1 and 2. For item 2, $y=f_T$ holds at every point of $S$ almost surely, hence on $B_T$.
4. *Generalization.* On that event the final predictor lies in the fixed class $\mathcal H(C_T)$. The single-class form of Theorem A1 holds on $S$ with probability at least $1-\delta$, uniformly over $\mathcal H(C_T)$, so in particular for the reuse run's predictor, however $B_T$ was drawn. Add the failure probabilities. ∎

---

## 4. A4: greedy growth versus the minimum-circuit Occam learner

The minimum-consistent-circuit (MCC) learner outputs a smallest circuit, with the same readout class, that is consistent with $S$. It is the discrete analogue of the strong-prior NNBayes learner: the posterior concentrates on minimal-complexity explanations. Let $s^*\le s(f^*)$ be the size of a smallest consistent circuit. Theorem A1 then gives
$$\mathrm{err}\le L_{s(f^*)}/n$$
in the realizable case, and the same theorem gives $\mathrm{err}\le L_{T_{\rm greedy}}/n$ for the greedy race at the time it is stopped. The comparison is therefore entirely about $T_{\rm greedy}$ versus $s^*$.

**Proposition A4.1 (equality on library targets) — Proved.** Let $y=\pm g^*$ for a depth-one candidate $g^*$, with $0<P(y=1)<1$; no balance condition is needed. In the population race, in either variant, $g^*$ and its duplicates as functions fire first, at $t=\Theta/\mathrm{Var}(y)$, strictly before every other candidate. After the refit the residual is $0$ and the race stops, so $T=1=s^*$. The same holds on a sample containing both labels, with $\mathrm{Var}_n(y)$ in place of $\mathrm{Var}(y)$, and with "duplicates" meaning candidates equal to $\pm y$ on the sample.

*Proof.*
1. At time $0$ the refit is the constant $\bar y$, so $U_m(0)=\mathbb E[(y-\bar y)g_m]$.
2. For any $g$ with $|g|\le1$, $|\mathbb E[(y-\bar y)g]|\le\mathbb E|y-\bar y|$.
3. Since $y\in\{\pm1\}$ and $\bar y=2P(y=1)-1$, we have $\mathbb E|y-\bar y|=P(y=1)(1-\bar y)+P(y=-1)(1+\bar y)=1-\bar y^2=\mathrm{Var}(y)$.
4. *Equality case.* Equality in step 2 requires $g=s\,\mathrm{sgn}(y-\bar y)=s\,y$ almost surely for a fixed sign $s$, because $y-\bar y\ne0$ everywhere when $|\bar y|<1$.
5. So $g^*$ has the largest possible utility, $\mathrm{Var}(y)$, and fires at $\Theta/\mathrm{Var}(y)$. Every candidate that is not $\pm y$ as a function has a strictly smaller utility, and there are finitely many of them, so their clocks are below $\Theta$ at that time.
6. The refit over $\{1,g^*\}$ gives $f=y$, so $r=0$ and every utility vanishes. A predictor with $T=0$ is constant, so $s^*=1$.
7. The sample version is the same computation under the empirical measure. ∎

**Numerical check** ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §5):
- in the population on $\{-1,1\}^4$, all 34 toy-library gates as targets, 24 of them unbalanced: no violations;
- on 199 random samples ($d=10$, $n\in\{16,32,64\}$): no violations.

**Targets outside the library behave differently.** The toy instance and3 is a fan-in-3 AND, hence not a library gate.
- It has $\bar y=-3/4$. Its three candidates $\mathrm{AND}(x_i,x_j)$, $i<j\le3$, have utility $3/8$, so they tie and fire at $t/\Theta=8/3\approx2.67$ in the population (2.68 at $n=4096$).
- Two gates suffice: $\mathrm{sgn}(\mathrm{AND}(x_1,x_2)+\mathrm{AND}(x_2,x_3)-1)=\mathrm{AND}_3$. One fan-in-2 gate cannot depend on three variables, so $s^*=2$.
- The greedy race finds exactly 2 gates at zero training error, which equals the minimum (Section 5).

**Proposition A4.2 (overshoot from ties and from square-loss refits) — Proved (population).** Items 1 and 3 are overshoots caused by ties; item 2 is an overshoot caused by square-loss refits.
1. **Ties.** Take $y=\mathrm{maj}_3$ with the toy library $G=\{\text{identity},\ \mathrm{AND}(\pm a,\pm b),\ \mathrm{XOR}\}$. Then 9 distinct gates fire together at $t=2\Theta$ (Proposition A2.2 with $m=3$, $u_3=1/2$). Three identity gates already suffice for the sign readout $\mathrm{sgn}(x_1+x_2+x_3)$, so $s^*\le3$; $s^*=1$ if $\mathrm{MAJ}_3\in G$. An exhaustive search over one- and two-gate circuits on $x_1,x_2,x_3$ finds none consistent, so $s^*=3$ for the toy library (Numerical, [`checks/referee_A_r1.out`](checks/referee_A_r1.out) §5). After this event the refit is $f=(x_1+x_2+x_3)/2$, so the **0-1 error is already zero**.
2. **Square-loss refits keep going.**
   - After item 1 the residual is $r=-x_1x_2x_3/2\neq0$, so the race continues.
   - No depth-one candidate ever fires again.
   - Exactly 12 depth-two candidates (distinct functions up to sign) have the largest utility magnitude, $1/4$. They are
     - $\mathrm{XOR}(x_i,\mathrm{AND}(x_j,x_l))$ and $\mathrm{XOR}(x_i,\mathrm{AND}(\neg x_j,\neg x_l))$ for $\{i,j,l\}=\{1,2,3\}$, and
     - $\mathrm{XOR}(\mathrm{AND}(x_i,x_j),\mathrm{AND}(x_i,x_l))$ and $\mathrm{XOR}(\mathrm{AND}(\neg x_i,\neg x_j),\mathrm{AND}(\neg x_i,\neg x_l))$ for $i$ and $\{j,l\}$ as before.

     Every other depth-two candidate has $|U|\le1/8$.
   - The 12 become available at $2\Theta$ and fire together at exactly $6\Theta$, when all other clocks are at most $\Theta/2$. The refit then represents $y$ exactly, and the race stops.
   - So the **population race ends at $t=6\Theta$ with $9+12=21$ gates**.
   - In general, the race keeps firing while some available candidate has nonzero utility. It stops when $y$ is in the span of the fired gates, or stalls with $y$ outside the span when all utilities vanish, as for par3 in the population (Proposition A4.3(1)). On a sample, reaching the span can require up to $n$ gates. The relevant $T$ for Theorem A1 is the one at the **stopping time**, not at the end of training.
3. **Overshoot by a factor $m$.** Take $y=\mathrm{MAJ}_m$ ($m$ odd) with the toy library. The first event fires $m^2$ distinct gates at $t=\Theta/u_m$ (Proposition A2.2(2)). The refit is then $f=u_m\sum_{i\le m}x_i$, the degree-$\le2$ part of $y$, so $\mathrm{sgn}f=y$ and the 0-1 error is zero. But $m$ identity gates already suffice. So $T_{\rm greedy}=m^2$ while $s^*\le m$, and Theorem A1 uses $L_{m^2}\approx m^2\log(6d^2)+m^4\log2$ in place of $L_m$.

*Proof of item 1.* Item 1 is Proposition A2.2(2), together with the Fourier expansion $\mathrm{maj}_3=\frac12(x_1+x_2+x_3-x_1x_2x_3)$. With $A_{ij}=\mathrm{AND}(x_i,x_j)$ and $A'_{ij}=\mathrm{AND}(\neg x_i,\neg x_j)$, we have $A_{ij}+A'_{ij}=x_ix_j-1$. So the span of the 9 gates and $1$ is exactly the space of functions of degree $\le2$ in $x_1,x_2,x_3$. The refit is therefore the degree-$\le2$ part of $\mathrm{maj}_3$, and $r=-x_1x_2x_3/2$.

*Proof of item 2.* Write $\chi=x_1x_2x_3$ and $\hat h(123)=\mathbb E[h\chi]$.
- *(i) Depth one.* Every depth-one candidate depends on at most two inputs, so it is orthogonal to $\chi$ and has utility $0$ against $r$ from $2\Theta$ on. Its clock stays frozen at the value it had at $2\Theta$, which is at most $\Theta/2$ by Proposition A2.2(2), so it never fires.
- *(ii) Depth two: reduction.* A depth-two candidate is $\varphi(a,b)$, with $\varphi\in G$ and sources $a,b$ among the inputs and the 9 fired gates, at least one of them fired. Its availability time is $2\Theta$. As a function of $\pm1$ values, $\varphi(a,b)=c_0+c_1a+c_2b+c_3ab$ with $|c_3|=1$ for XOR and $|c_3|=1/2$ for the four AND-types. (An identity of a fired gate is a duplicate of it, with $U=0$.) Every source has Fourier support on sets of size $\le2$, so $\hat a(123)=\hat b(123)=0$ and
  $$U(\varphi(a,b))=\mathbb E[r\,\varphi(a,b)]=-\tfrac12\,c_3\,\widehat{ab}(123).$$
- *(iii) The Fourier lemma: $|\widehat{ab}(123)|\le1/2$, with equality exactly for the pairs listed in item 2.* Each source is either a literal $\pm x_i$ or one of the six fired ANDs on a pair inside $\{1,2,3\}$, whose nonconstant Fourier coefficients all have magnitude $1/2$.
  - *Two literals.* $ab$ has degree $\le2$, so the coefficient is $0$.
  - *A literal $\pm x_i$ and an AND $b$ on a pair $W$.* $\widehat{ab}(123)=\pm\hat b(\{1,2,3\}\triangle\{i\})$. This is nonzero only if $i\in\{1,2,3\}$ and $W=\{1,2,3\}\setminus\{i\}$, and then it equals $\pm1/2$.
  - *Two ANDs on the same pair.* The product depends on two variables only, so the coefficient is $0$.
  - *Two ANDs on pairs sharing one index.* Let $a=\mathrm{AND}(s_ix_i,s_jx_j)$ and $b=\mathrm{AND}(t_ix_i,t_lx_l)$. Only the terms $(\{i,j\},\{l\})$ and $(\{j\},\{i,l\})$ contribute, giving $\widehat{ab}(123)=\tfrac14 s_jt_l(s_i+t_i)$. This is $\pm1/2$ if the shared-variable signs agree ($s_i=t_i$, i.e. both are $A$'s or both are $A'$'s), and $0$ otherwise.
  - *Irrelevant inputs.* An input $x_l$ with $l>3$ contributes $l$ to every set in the support of $ab$, so the coefficient is $0$.
- *(iv) Maximizers.* Hence $|U|\le\frac12\cdot1\cdot\frac12=\frac14$, with equality exactly for $\varphi=\mathrm{XOR}$ on the pairs of (iii) with $|\widehat{ab}(123)|=1/2$. There are $3\cdot2=6$ literal–AND pairs and $3\cdot2=6$ AND–AND pairs, giving 12 functions, distinct up to sign. Every other depth-two candidate has $|U|\le\frac12\cdot\frac12\cdot\frac12=\frac18$ (AND-types) or $|U|=0$.
- *(v) Firing.* The residual is constant on $[2\Theta,6\Theta]$. So the 12 clocks reach $\Theta$ together at $2\Theta+\Theta/(1/4)=6\Theta$, while the other depth-two clocks are at most $4\Theta/8=\Theta/2$.
- *(vi) Stopping.* Each of the 12 equals $\pm\frac12\chi$ plus a function of degree $\le2$ in $x_1,x_2,x_3$. So after the refit the span contains $\chi$, hence $\mathrm{maj}_3$, and $r=0$.

*Proof of item 3.* $\mathrm{MAJ}_m$ is odd, so its degree-2 Fourier coefficients vanish, and its degree-1 part is $u_m\sum_ix_i$. The span of the fired gates and $1$ is the span of $1$, the $x_i$ and the $x_ix_j$ ($i,j\le m$). So the least-squares refit is $u_m\sum_ix_i$, whose sign is $\mathrm{MAJ}_m$. ∎

The exact population computation confirms item 2 on $\{-1,1\}^4$ and on $\{-1,1\}^5$ ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §4; [`checks/referee_A_r1.out`](checks/referee_A_r1.out) §3):
- the 12 maximizers, 20 functions at $1/8$ and 55 at $0$ (54 nonconstant, plus the constant);
- each maximizer alone completes the representation;
- 21 distinct gates at the end.

**Numerical** (Section 5).
- **maj3.** At $n\ge256$ the race reaches zero training error with 6 gates and ends with 10. At $n=4096$ the 10th gate fires at $t/\Theta=5.99$, matching the population time $6\Theta$ of item 2.
  - The gate counts differ from the population's 21 because noise on a sample breaks the 12-way tie. The first of the 12 to fire already completes the representation of $\mathrm{maj}_3$ on $\{-1,1\}^3$, hence on the sample, so the race stops at $9+1=10$.
- **dnf3.** The race reaches zero training error with 18 gates, while a 6-gate circuit exists: three 3-literal ANDs built from two fan-in-2 ANDs each, with readout $\mathrm{sgn}(\sum_jT_j+2)$. That is an overshoot by a factor of at least 3. In Theorem A1, the dnf3 bound at $n=4096$ is 0.084 with $T=18$, whereas $T=6$ would give 0.019.

**Proposition A4.3 (parity is never found) — Proved.** Let $y=\chi_S$ with $|S|=s>k$, under uniform inputs.
1. In the population race no candidate ever fires: $T(t)=0$ and the test error is $1/2$ for all $t$.
2. Suppose $\mathrm{XOR}\in G$. The target is computed by a chain of $s-1$ XOR gates with the **output-gate readout** ($\rho_{s-1}=\log2$). So the MCC learner over that readout class, or any learner that outputs a consistent circuit of at most $s-1$ gates with that readout, has error at most
   $$\frac{L_{s-1}}{n},\qquad L_{s-1}=W_{s-1}+\log2+\log\frac{s(s+1)}{\delta}=O\bigl(s\log(d+s)+\log(1/\delta)\bigr).$$
   Error $\varepsilon$ therefore needs $n=O((s\log(d+s)+\log(1/\delta))/\varepsilon)$ samples. With the sign readout instead, $\rho_{s-1}\approx(s-1)^2\log2$ adds an $s^2$ term.
3. On a sample, Proposition A2.6 applies: nothing fires before $t\approx\Theta\sqrt n/(2\sqrt{2\log(2M/\delta)})$. That gates fitted to noise fire after that is Numerical, not proved: in the par3 runs of Section 5 the first noise gate fires at $t/\Theta=2.65$–$20.0$ for $n=64$–$4096$.

*Proof.* Before any gate fires, every candidate has depth one and so depends on some set $V$ of at most $k<s$ variables. Write $\chi_S=\chi_{S\cap V}\chi_{S\setminus V}$. Since $S\setminus V\ne\emptyset$, $\chi_{S\setminus V}$ has mean zero and is independent of $x_V$, so $\mathbb E[\chi_Sg]=0$. Also $\mathbb E[y]=0$. All utilities vanish, the residual stays $y$, and the clocks stay at $0$. Item 2 is Theorem A1, item 4, with $T=s-1$ and $\rho_{s-1}=\log2$. ∎

This is the circuit-leap obstruction of the [README](../README.md) (§3) in its simplest form.
- In real GD the fan-in-$s$ search costs about $d^{s-1}$ time, as the SQ lower bounds require. The discrete model represents that cost only if the library contains fan-in-$s$ gates with correspondingly larger thresholds.
- The par3 runs in Section 5 show the predicted behaviour: nothing until $t/\Theta=5$–$20$, depending on $n$; then one or more noise gates, with test error $0.50$.
- Theorem A1 remains valid there: it gives $0.52$–$0.95$, which certifies nothing.

**What this does to the bounds.**
- **Same theorem, different $T$.** Theorem A1 holds for both learners. The greedy bound is weaker by about the factor $T_{\rm greedy}/s^*$, or its square from the $T^2$ readout term. That factor is:
  - 1 for library targets;
  - 2 for maj3 at zero training error (6 against 3);
  - at least 3 for dnf3 (18 against at most 6);
  - $m$ for $\mathrm{MAJ}_m$ (Proposition A4.2(3)).
- **When greedy never finds the circuit.** The bound stays correct but vacuous in effect: it certifies the training error of a bad predictor. The MCC learner's sample complexity is unaffected. MCC is not efficiently computable; the greedy race pays in reachability instead.
- **A greedy-only route.** When the population run is stable, Theorems A3.1 and A3.5 give a guarantee that MCC lacks: exact recovery whose sample size has no $1/\varepsilon$. It is lost under ties or zero utilities.
- **Relation to NNBayes (Heuristic).** The Bayesian/MCC learner pays prior mass, roughly circuit size, *once*. The greedy race pays at every step: each gate must have utility exceeding the noise level $\sqrt{\log M/n}$ at the moment it is added.
  - In the sibling project, small circuits imply few total mistakes in random order ([total mistakes](../../neural-network-generalization/TECHNICAL-FAQ.md#can-we-bound-the-total-number-of-mistakes-during-learning)), and few mistakes imply small circuits ([circuit-induction converses](../../neural-network-generalization/TECHNICAL-FAQ.md#does-making-few-mistakes-imply-that-the-target-has-a-small-circuit)).
  - For the greedy race the first direction fails: par3 has a 2-gate circuit when XOR is in the library, yet the online race makes about $N/2$ mistakes in $N$ rounds.

---

## 5. Numerical sanity check (toy race, $d=30$)

[`checks/race_bounds.py`](checks/race_bounds.py) produces [`checks/race_bounds.txt`](checks/race_bounds.txt) in about a minute on one core. The setup:
- **Library:** identity, $\mathrm{AND}(\pm a,\pm b)$ and $\mathrm{XOR}(a,b)$, up to negation, so $|G|=6$ and $k=2$. There are 2205 depth-one candidates.
- **Model:** the event-driven (LS) race at any depth, and the (SC) race on the depth-one dictionary.
- **Data:** training sets of size $n$, and a test set of 20,000 points.
- **Conventions:** $\delta=0.05$. Candidates that coincide on the sample are merged.

This revision fixed a clock-sign bug in the script, which affected only (SC) runs with exits, of which there were none. It also split $\delta$ between the two A1′ bounds. The rerun reproduces every (LS) number exactly; in the (SC) runs only the A1′ columns changed.

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

Observations ([`checks/A_r2_checks.out`](checks/A_r2_checks.out) §9 parses the ranges from the output file):
- **Theorem A1** holds in every run.
  - In these runs it is non-vacuous (below $1/2$) whenever $n\ge256$ and $T\le10$, and useful (at most $0.1$) at $n=4096$ whenever $T\le20$. The largest values are $0.45$ for maj3 at $n=256$ with $T=10$, and $0.107$ for dnf3 at $n=4096$ with $T=21$.
  - The observed test error is exactly 0 in most runs, so the bound's value is essentially its slack $1-e^{-L_T/n}$.
- **Theorem A2.3.**
  - Over all (LS) events $\kappa\in[0.44,4.59]$, and $\kappa\in[0.65,3.09]$ for $n\ge256$.
  - The looseness $\kappa\tau^2/(\Theta^2T)$ is $1.00$ on par2, where the bound is attained. It is at most $4.96$ on maj3, $2.71$ on and3 and $6.97$ on dnf3.
  - On par3, where a single noise gate fires late, it reaches 400.
- **Proposition A2.6:** on par3, the first noise firing is at $t/\Theta=2.65,\,5.16,\,9.97,\,20.0$ for $n=64,256,1024,4096$, against the proved lower bound $0.84,\,1.68,\,3.35,\,6.71$.

**(SC) race on the depth-one dictionary (Theorems A2.4 and A2.3(2)).**
- The identity $\Theta\|c\|_1=\langle R,f\rangle_n$ and the chain $\le\|R\|_n\le\tau$ hold to machine precision at every event (maj3, and3 and par2; $n=256$ and $4096$). So do $S_m=\langle R,g_m\rangle_n$ and $|\mathrm{Sat}|\le\kappa_{\mathrm{Sat}}(\|R\|_n/\Theta)^2$.
- These six runs have no exits from the saturated set. The exit branch is exercised in [`checks/A_r2_checks.out`](checks/A_r2_checks.out) §6 (see Theorem A2.4).
- Example: maj3 at $n=4096$ ends with $\|c\|_1=1.53$, $\|R\|_n/\Theta=15.2$ and $\tau/\Theta=16.1$. The Cauchy–Schwarz step is loose by a factor of 10 there, because after the last firing $R(t)$ grows only along the residual, which is orthogonal to $f$.

Theorem A1′, with $|\mathcal F|=2205$ and $\delta$ split between its two bounds, is **near-vacuous at these sizes**:
- at $n=4096$, over all events, its bound on the clipped square loss is 0.43–0.92, against a true 0–0.38. At the last event of each run it is 0.43–0.84, against a true 0–0.09;
- its 0-1 bound (ramp, $\theta=1/2$) is 0.40–0.97 over all events, against a true 0–0.26;
- at $n=256$ both exceed 1.

The norm route needs $n\gtrsim10^5$ here. Its advantage, independence from $T$, matters only for large circuits.

**Files used by this note.**

| script | output | checks |
|---|---|---|
| [`checks/lemma_checks.py`](checks/lemma_checks.py) | [`checks/lemma_checks.txt`](checks/lemma_checks.txt) | Lemma 1.2 by brute force for $T\le4$; Lemma 1.3 inequalities on a grid; the table of A1 bounds |
| [`checks/race_bounds.py`](checks/race_bounds.py) | [`checks/race_bounds.txt`](checks/race_bounds.txt) | toy (LS) and (SC) races: Theorem A1, Proposition A2.1, Theorem A2.3 (both items), Theorem A2.4, Theorem A1′, Proposition A2.6 |
| [`checks/sgd_clock_check.py`](checks/sgd_clock_check.py) | [`checks/sgd_clock_check.txt`](checks/sgd_clock_check.txt) | Lemma A3.2 and the utility table of Proposition A2.2 |
| [`checks/A_r2_checks.py`](checks/A_r2_checks.py) | [`checks/A_r2_checks.out`](checks/A_r2_checks.out) | revision 2: A1 thresholds; A3.1 and A3.5 constants; library incoherence $\bar\kappa_1$ and Corollary A2.5(a′); Propositions A4.1 and A4.2(2) exactly; (SC) with exits; A1 versus BEHW; greedy-with-reuse Monte Carlo; Section 5 ranges |
| [`checks/referee_A_r1.py`](checks/referee_A_r1.py) | [`checks/referee_A_r1.out`](checks/referee_A_r1.out) | the referee's independent checks (round 1) |
| [`checks/referee_A_r2.py`](checks/referee_A_r2.py) | [`checks/referee_A_r2.out`](checks/referee_A_r2.out) | the referee's independent checks (round 2): library incoherence and the no-merging counterexample for Corollary A2.5(a′); Proposition A4.2(2) recount; (SC) and (LS) races; A3.1 and A3.5 constants; Theorem A3.5 Monte Carlo; unique-argmax frequencies on par2 |

All use numpy (and scipy for linear programming and nonnegative least squares) and run in about a minute each on one core.

---

## 6. What is vacuous, and what is open

**At realistic sizes** ($d=30$, $n\le16384$; "useful" means $\le0.1$, "non-vacuous" means $<1/2$):
- **Useful or non-vacuous: Theorem A1, realizable form.**
  - Useful for $T\le2,\,7,\,20,\,62$ at $n=256,\,1024,\,4096,\,16384$.
  - Non-vacuous for $T\le11,\,27,\,102,\,403$.
- **Weak:** the agnostic form, which is about $\sqrt{L_T/2n}$: 0.088 at $T=5$, $n=4096$.
- **Near-vacuous:** the norm-based Theorem A1′ and Corollary A2.5(b).
- **Not a time-only bound:** Corollary A2.5(a) is a decomposition, never tighter than A1 at the realized size.
- **Time-only but weak: Corollary A2.5(a′).**
  - With $\bar\kappa_1\approx32$–$35$, it gives 0.21 and 0.053 at $\tau=\Theta$ (for $n=4096$ and $16384$), and 0.61 and 0.195 just below $\tau=2\Theta$.
  - Measuring $\tau/\Theta$ on the real networks requires the calibration recipe of §2.3, which is Heuristic and proposed for SGD only.
- **Not applicable to the experiments' SGD:**
  - Theorem A3.1 asks for $n\ge2254$ for par2, which is learned at $n=64$. In a Monte Carlo the right gate is the unique greedy argmax in about 81–94% of runs at $b=16$ and in all runs at $b=64$ (§3.1).
  - Theorem A3.5 needs $b\ge6225$ at $n=16384$.
  - Neither covers $b=64$, and for the SGD race only clock concentration is proved.
- **Indirect for real networks:** none of these bounds applies to a trained network unless the network is first described as a circuit of the template (Heuristic). That could be done by fitting the discrete race to the run, or by reading gates off the saved Fourier coefficients on the relevant variables. The bound then certifies that circuit, not the network.

**Open problems.**
1. **$\ell_1$ control at depth $\ge2$.** Late availability times $a_m$ break the duality identity of Theorem A2.4. Is $\Theta\|c(t)\|_1\le C_D\,\tau(t)$ true for depth-$D$ (SC) races?
2. **A better size bound.**
   - Is there a bound in terms of *distinct functions* that excludes near-duplicate libraries? Proposition A2.2 shows that the bound must depend on the library through something like $\kappa$.
   - Is there a time-only bound with a smaller incoherence factor than the library-wide $\bar\kappa_1\approx d$ of Corollary A2.5(a′), for instance one that uses only the gates the race can actually reach?
3. **Theorem A3.1 for the race, and for small batches.**
   - A reproduction theorem for the race rather than the argmax, under a crossing-time margin.
   - A version for tied clusters, such as the 9 gates of maj3.
   - A reuse theorem at $b\ll n$. Theorem A3.5 needs $b$ of the order of the fresh-batch threshold.
4. **Total mistakes.** A bound for the one-pass greedy race, analogous to the NNBayes total-mistake theorems, in terms of the length of the population greedy path.
5. **Faithfulness.**
   - Faithfulness of the deep attach model, and of the (LS) versus (SC) refit, to actual small-initialization GD beyond depth one.
   - The calibration of $\Theta$ and of race time on the μP runs (§2.3), including an Adam clock.
6. **The time unit with fresh chains.** A formal race with $k\ge3$ moves, with a size or depth bound in terms of time *since the first fresh-chain move*, which would make "short training" meaningful for three-layer networks started at small scale (Lemma 2.2(4) note).
7. **Well-posedness of (SC).** Prove that (SC) has finitely many events in bounded time, or that its accumulation points are harmless.

## References

- T. Cover. *Geometrical and statistical properties of systems of linear inequalities with applications in pattern recognition.* IEEE Trans. Electronic Computers EC-14 (1965) 326–334. Function-counting theorem (Lemma 1.2 proves the upper half).
- OEIS A000609, number of threshold functions of $n$ variables: 2, 4, 14, 104, 1882, 94572, ... (values for $n\le4$ confirmed by brute force in `checks/`).
- A. Blumer, A. Ehrenfeucht, D. Haussler, M. Warmuth. *Learnability and the Vapnik–Chervonenkis dimension.* JACM 36(4) (1989) 929–965. Theorem A2.1, with the hypothesis $m\ge8/\epsilon$ (from memory).
- M. Mohri, A. Rostamizadeh, A. Talwalkar. *Foundations of Machine Learning*, 2nd ed., MIT Press 2018. Theorem 3.3 (Rademacher bound; the form of L1), Theorem 3.7 (Massart), Lemma 5.7 (Talagrand's contraction lemma; the form of L2), Lemma 7.4 (convex hulls) (numbering from memory).
- P. Bartlett, S. Mendelson. *Rademacher and Gaussian complexities: risk bounds and structural results.* JMLR 3 (2002) 463–482. Theorem 8: a related form of L1 with different normalization and constants (from memory).
- M. Ledoux, M. Talagrand. *Probability in Banach Spaces.* Springer 1991. Theorem 4.12: the absolute-value contraction principle, a related form of L2 that requires $\phi_i(0)=0$ and has an extra factor 2 (from memory).
- V. Koltchinskii, D. Panchenko. *Empirical margin distributions and bounding the generalization error of combined classifiers.* Annals of Statistics 30(1) (2002) 1–50. Margin bounds of the A1′ type.
- N. Cesa-Bianchi, A. Conconi, C. Gentile. *On the generalization ability of on-line learning algorithms.* IEEE Trans. Inf. Theory 50(9) (2004) 2050–2057 (venue checked; theorem statements from memory). NIPS 2001 version: [proceedings](https://proceedings.neurips.cc/paper/2001/hash/01931a6925d3de09e5f87419d9d55055-Abstract.html).
- S. Pesme, N. Flammarion. *Saddle-to-Saddle Dynamics in Diagonal Linear Networks.* NeurIPS 2023. [arXiv:2304.00488](https://arxiv.org/abs/2304.00488). Abstract checked; the exact form of the recursion is from memory.
- D. Kunin, G. Marchetti, F. Chen, D. Karkada, J. Simon, M. DeWeese, S. Ganguli, N. Miolane. *Alternating Gradient Flows: A Theory of Feature Learning in Two-layer Neural Networks.* NeurIPS 2025. [arXiv:2506.06489](https://arxiv.org/abs/2506.06489). Accumulated-utility clocks (from memory).
- R. DeVore, V. Temlyakov. *Some remarks on greedy algorithms.* Adv. Comput. Math. 5 (1996) 173–187. Orthogonal-greedy rate $\|r_T\|\le\|f\|_{\mathcal A_1}(T+1)^{-1/2}$ (from memory; not used in a proof here). It is the depth-one approximation counterpart: a target with $\ell_1$-representation norm $M$ is fit to squared residual $M^2/(T+1)$ by $T$ greedy steps, so $T_{\rm greedy}\lesssim M^2/\varepsilon$.
- Sibling project: [`neural-network-generalization/TECHNICAL-FAQ.md`](../../neural-network-generalization/TECHNICAL-FAQ.md), sections on total mistakes and circuit-induction converses.

---

## Revision notes

Round 2: a second referee passed revision 2 with 7 minor issues and no major ones ([`checks/referee_A_r2.json`](checks/referee_A_r2.json)); those minor issues have been applied, as listed in the **Round-2 referee** entry at the end of these notes. One of them was that Corollary A2.5(a′) is a weak time-only gate-count bound for a fixed library, so "training time does not bound the raw gate count" holds only uniformly over libraries (Proposition A2.2).

Revision 2, after the round-1 referee report (verdict: fail; one fatal, five major, twelve minor issues). The referee found no false core theorem. Changes, in the order of the report:

**Fatal**
- **Proposition A3.4(2).** Item 2 claimed under a Proved label that reuse reproduces or approximates the full-batch race on $S$. It is replaced by three parts:
  - (a) the exact conditional statement: given $S$, Lemma A3.2 and Theorem A3.1 hold with $P_n$, with the empirical gap, $R$ and $\lambda_*$ of the full-batch run on $S$. Proved.
  - (b) a new **Theorem A3.5**, Proved: the greedy model with minibatches drawn with reuse reproduces the *population* run when $(n^{-1/2}+b^{-1/2})$ is small enough. It decomposes the deviation into a sample term and a conditional batch term, both over data-independent families. This is a direct route, simpler than the two-stage chain the referee suggested, and it needs no empirical gap. For par2 it needs $b\ge6225$ at $n=16384$.
  - (c) the race-with-reuse reading at small $b$, now labelled Heuristic.

**Major**
- **Summary item 3 and Section 3 intro.** Both are qualified. Reproduction is proved only for the greedy argmax model with large per-step batches and a utility gap ($b\ge2254$ for par2, against $b=64$ in the experiments). For the SGD race only clock concentration is proved.
- **Corollary A2.5(a).** It is now presented as a decomposition (size $\le$ incoherence $\times$ time$^2$), with the explanation that it is never tighter than A1 at the realized size. The unused depth clause is removed.
  - A new item **(a′)** gives a genuine time-only count bound. It replaces $\kappa(t)$ by the library-wide $\bar\kappa_{D}$ on unlabelled inputs, and uses the depth bound to choose $D$.
  - The population value $\bar\kappa_1=d$ for the toy library is proved, and empirical values are computed. The bound is weak (0.053 at best at $n=16384$), and this is said.
  - Summary item 2 is rewritten accordingly.
- **Proposition A4.2(2).** The missing steps are added: depth-one utilities vanish, and the Fourier lemma $|\widehat{ab}(123)|\le1/2$ shows that all depth-two utilities are at most $1/4$, with all others at most $1/8$. The 12-way tie at $6\Theta$ and the population end count of 21 gates are reported, and the 10 gates in the sample race are explained as tie-breaking. "The population prediction is 6" now clearly refers to the time $6\Theta$.
- **Proposition A2.2(3).** It is restricted to duplicates with equal availability time, and given a one-line proof. "Unbounded at $t=\Theta$" is replaced by "not bounded by any function of $t/\Theta$ uniformly over libraries", with the fixed-library bound stated. It is noted that a later-available duplicate never fires in (LS).
- **Lemma 2.2(4) and the $\alpha$-invariance claims.** They are restricted to a race with one threshold (the pure $k=2$ attach race). A note explains why fresh chains break the invariance, that the first move of a three-layer net started at scale $\alpha$ costs about $\alpha^{-1}$, that the depth-one race models diagonal or 2-homogeneous networks, and that μP has no single $\alpha$. The Summary is changed to match, and open problem 6 is added.

**Minor**
- **Theorem A1′:** $\delta$ is split between the two bounds, using $\log(2/(\pi_j\delta))$. The script and the Section 5 numbers are updated.
- **Theorem A3.1:** item 3 now holds with probability $1-2\delta$, via a single-class form of A1. The par2 constant is corrected from 2252 to 2254. A remark on monotonicity in $(\gamma,R,\lambda_*)$ is added.
- **Corollary A2.5(a):** the reference is now "Theorem A1 (all items)".
- **BEHW remark:** the crossover claim was wrong. A1 is smaller at every $T\le1499$ for $n\in\{1024,4096,16384\}$. The hypothesis $n\ge8/\epsilon$ is added to the citation.
- **Citations of L1 and L2:** MRT Theorem 3.3 and Lemma 5.7 are now cited as the sources of the stated forms, and Bartlett–Mendelson Theorem 8 and Ledoux–Talagrand Theorem 4.12 as related forms with different constants.
- **Section 5 ranges:** $\kappa$, A2.3 looseness (par2 attains the bound) and A1′ ranges are recomputed from the output by a script.
- **Proposition A2.2(2):** it now says "$m^2$ distinct functions (up to sign)", with the syntactic convention explained. The tightness example of A2.3 is labelled as the population analogue.
- **(SC):**
  - a well-posedness paragraph is added, with statements proved up to any accumulation of events (open problem 7);
  - the intercept difference from Pesme–Flammarion is flagged;
  - it is noted that (LS) is not the depth-one GD limit;
  - the (SC) form of Theorem A2.3 is added as item 2 (Proved), together with the depth-one refinement $\tau\to\|R\|_n$.
- **`checks/race_bounds.py`:**
  - the mask-ordering bug is fixed (`self.S[self.active] = ...`);
  - the exit step iterates to a fixed point;
  - the (SC) size check is added;
  - the script was rerun, and its (LS) output is unchanged;
  - the exit branch is tested on random dictionaries with 130 exits in `checks/A_r2_checks.py` §6.
- **Proposition A4.3 / Summary item 4:**
  - the readout class (output gate) and the $1/\varepsilon$ factor are specified, and the extra $s^2$ term for sign readouts is noted.
  - On the balance hypothesis of Proposition A4.1, I did *not* restore it. Instead I proved that it is unnecessary: for $\pm1$ targets, $|\mathrm{Cov}(y,g)|\le\mathbb E|y-\bar y|=\mathrm{Var}(y)$ whenever $|g|\le1$. This also gives the sample version the referee asked for. The earlier sentence "the balance condition matters" was wrong, and is replaced by a correct discussion of and3, which is not a library gate.
- **Proposition A3.3/A3.4 wording:**
  - first-occurrence validation estimates the iterates' average test loss at the first-draw times, not the final predictor's;
  - the mistake count $Tb$ is now $(T+1)b$;
  - A3.4(1) is restricted to template learners;
  - Lemma A3.2 now assumes the availability indicator is $\mathcal F_{i-1}$-measurable.
- **Recipe and thresholds:**
  - the calibration recipe is restricted to SGD, with a note on why Adam's clock differs;
  - "useful" ($\le0.1$) and "non-vacuous" ($<1/2$) are fixed once, in Section 1, and used consistently;
  - the Summary's "$n\gtrsim140T$" is corrected to "$n\ge144T$".

**Round-2 referee** ([`checks/referee_A_r2.json`](checks/referee_A_r2.json), checks in [`checks/referee_A_r2.py`](checks/referee_A_r2.py) → [`checks/referee_A_r2.out`](checks/referee_A_r2.out)). The verdict on revision 2 was "pass": every round-1 issue is fixed, and no new or changed Proved result has a gap that the referee could not close. The report lists 7 issues, all minor. They are now applied, in the order of the report. No check script was rerun; every new number is taken from `referee_A_r2.out` or from the existing Section 5 output. No label was strengthened.
1. **Corollary A2.5(a′), counting convention.** A *Convention* bullet now states that (a′) is for a race in which candidates that coincide up to sign on the sample are identified, with one representative per class in the refit (as in Section 5), so that $T(t)$ counts these classes and $h_t\in\mathcal H_{T(t)}$. It cites the referee's no-merging counterexample (24 gates distinct on $\mathcal X$ against $\bar T=2$). The proof of (a′) now invokes the convention. The status table and Summary item 2 mention the merging. Theorem A2.3 and Corollary A2.5(a) are unchanged, since A2.3 holds for any set of fired gates.
2. **"Time does not bound the gate count."** Summary item 2's headline and the closing sentence of §2.3 now say that training time bounds the gate count only through an incoherence factor, the learned circuit's $\kappa(t)$ or the library's $\bar\kappa\approx d$ (Corollary A2.5(a′)), and that no bound with a library-independent constant holds (Proposition A2.2). "Three other quantities" in item 2 is now "three quantities".
3. **Sample-size scaling of Theorem A3.1.**
   - (a) Summary item 3, the §3 introduction and the comparison in §3.1 now write $b$ (or $n$) $\gtrsim\max\{TR^2/(\lambda_*\gamma^2),\,T^2/\lambda_*^2\}\log(MT/\delta)$, including the Gram condition. §3.1 gives the referee's example where it dominates ($T=30$, $\lambda_*=1/2$: $4.5\cdot10^5$ against $7.9\cdot10^4$).
   - (b) Summary item 3 now says that the test error equals the population model's only under an exact representation (A3.1(2)), and that otherwise A3.1(3) gives an Occam bound with no wiring term. The §3 introduction now says that A3.1 proves the *circuit* is reproduced.
4. **Monte Carlo of the greedy first step (§3.1, §6).** The text now says that XOR being *an* argmax is guaranteed by Proposition A4.1 and carries no evidence. It reports the referee's unique-argmax frequencies instead: 163/200, 180/200 and 375/400 at $b=16$ (about 81–94%), and 200/200 and 400/400 at $b=64$. The claim is labelled Numerical.
5. **Unlabelled claims in the Summary.** The fresh-chain cost of about $\alpha^{-1}$ is labelled Heuristic, in Summary item 2 and in the note after Lemma 2.2(4). The sentence linking the $\ell_1$ bound to diagonal linear networks is labelled "Literature, from memory; up to the intercept".
6. **Slips inside Proved items.**
   - (a) Proposition A4.2(2): "the race stops only when $y$ lies in the span" is replaced by: the race keeps firing while some available candidate has nonzero utility; it stops when $y$ is in the span, or stalls when all utilities vanish (par3 in the population, Proposition A4.3(1)).
   - (b) Proposition A4.3(3): the clause that noise gates fire after the A2.6 time is now labelled Numerical, citing the par3 runs of Section 5. It is not proved.
   - The exact-count bullet after Proposition A4.2 now says that the 55 functions at utility $0$ are 54 nonconstant ones plus the constant.
7. **Cosmetic.**
   - (a) The BEHW remark now says the range $T\le1499$ covers the whole range in which BEHW is below 1 or A1 is non-vacuous.
   - (b) The round-1 notes now count twelve minor issues, not eleven.
   - (c) Summary item 4's parity sample-complexity sentence now states the hypothesis $\mathrm{XOR}\in G$ of Proposition A4.3(2).

Also changed: the header, and the pointer to the referees' checks under the status labels, now mention round 2. The Files table in Section 5 lists `referee_A_r2.py` and its output.
