# Finding the short surrogate efficiently: compute, subsampling, and a twin bound

Follow-up to the main note (overview [`../README.md`](../README.md), statements and proofs [`../theory/README.md`](../theory/README.md)), prompted by Kaarel Hänni. Research note by Claude, 27–28 October 2026; not reviewed by a human. The propositions were checked by AI referees ([verification](#verification)), not by humans. Literature claims come from search-result snippets: the session's network policy blocked arxiv.org and most publisher sites, so no paper page could be opened ([`literature_sweep.json`](literature_sweep.json)).

**The question.** With a known input distribution $D_X$, Theorem 2 of the main note bounds the trained network $f$ through any description $g$:

$$\mathrm{err}(f)\ \le\ \overline{\mathrm{Bin}}\big(k_S(g),m,\delta_12^{-L(g)}\big)+\overline{\mathrm{Bin}}(j,N,\delta_2),$$

where $k_S(g)$ is $g$'s number of training errors and $j$ the number of disagreements between $f$ and $g$ on $N$ fresh inputs from $D_X$. So with unlimited compute to search over descriptions, the bound is good whenever $f$ is close to *some* short program. Is that closeness true in practice? Can the search be done with less than exponential compute? In particular, does *subsampling* the big network give a small network close enough to $f$ to certify generalization?

## Short answers

- **Unlimited compute.** If the labels come from a target with an $L_t$-bit description, an exhaustive search over short descriptions certifies *every* trained network to within $(L_t\ln2+\ln(1/\delta))/m$ of its true error, plus sampling slack (Proposition 2). Generalization on a simple-target task implies closeness to a simple function. Beyond that, the limit is the best Occam bound of any program at sample size $m$. On MNIST at $m=60{,}000$ we know of no program short enough to bring that below about 0.1.
- **Is closeness true in practice?** In the sense the bound needs, agreement with $f$ up to about $f$'s own error, yes on every task we tried. Every Boolean network is within its test error of the short target. On MNIST, networks are within 1.5–2% of a retrained twin. What fails is *finding* a short $g$ (dense targets), or the Occam cost of the shortest known $g$ (MNIST).
- **Compute.**
  - Certification is cheap, but brute-force search costs about $2^L$ evaluations.
  - Black-box search is as hard as learning small circuits from membership queries, which is impossible in polynomial time if pseudorandom functions exist (Proposition 3, classical).
  - Polynomial-time searches that exploit structure work where the structure is there. On every junta and threshold-function target, an influence-guided codec recovers the target (31–98 bits, bounds 0.002–0.007) in 10 seconds to 4 minutes per network.
  - On dense targets (the sign of a random 4- or 8-unit ReLU network on all 50 inputs), every polynomial-time search we tried stops at 1.24–1.92 times the bound the true target itself would give.
- **Subsampling hidden units** (Maurey sampling, top-$k$, greedy selection, each with a least-squares refit) works when the function is carried by a few units, and Proposition 4 says when.
  - On mean-field-trained networks, 2 units reproduce the two majority targets and 4 the 3-parity (144–244 bits, bounds 0.007–0.011).
  - On standard networks the majorities need 16–32 units and 1,200–3,300 bits (0.07–0.30).
  - 3-parity is carried by 4–8 units in every regime, and the random 6-junta needs 16–32 in every regime.
  - The path norm behind the guarantee is width-independent for mean-field nets and grows with width for standard ones.
  - As a starting point for distillation, subsampling helps on some networks (dense 4-unit target: 0.153–0.167 against 0.217–0.225 from scratch) and not on others. On MNIST it is about as good as distillation from scratch.
  - It does not close the gap on dense targets.
- **Subsampling the data instead.** If retraining is allowed, a twin trained on a fixed half of the training set gives a bound with one extra training run and no search (Proposition 5, a special case of Kääriäinen 2005). The twin is tested on the other half, and its disagreement with $f$ is measured on fresh or unlabeled inputs.
  - MNIST: 0.042 for a 1024-unit network with test error 1.55%, where the best compression bound is 0.255.
  - Boolean tasks at $m=16{,}000$: 0.0005.
  - It fails where half the data is not enough to learn (3-parity at $m=4000$: 0.62 against 0.007 for compression) and on interpolated label noise (0.22–0.23 against 0.17).

Bottom line:
- Worst-case search is hopeless.
- Structured search solves the junta and threshold-function cases.
- On dense targets, subsampling and the other polynomial-time searches leave a factor of 1.2–1.9 to the oracle.
- With a known input distribution, the cheapest route to a tight bound on real networks is retraining, not compression, when the training algorithm is available.

## 1. What unlimited compute buys

Write $K_\epsilon(f)=\min\{L(g):\Pr_{D_X}[f\ne g]\le\epsilon\}$ for the $\epsilon$-approximate description length of $f$ under $D_X$, in a prefix-free description language fixed before the data are seen, whose programs run in polynomial time (networks with quantized weights, truth tables, circuits).

**Proposition 1 (validity does not depend on the search).** Fix the code, including every codec one might try, before $S$ is drawn. Let $g$ be the output of any search procedure, which may use $f$'s weights, the training set $S$, and any inputs from $D_X$ other than the $N$ certification inputs. Use the certification inputs once, for the returned $g$. Then the bound above holds with probability $\ge1-\delta_1-\delta_2$.

*Proof.* The Occam term holds simultaneously for all descriptions (Lemma 1 of the main note), hence for the returned one. Conditional on everything that determined $g$, the certification inputs are i.i.d. from $D_X$, so the binomial upper limit for $\Pr[f\ne g]$ holds with probability $\ge1-\delta_2$. $\square$

So compute affects how good the bound is, not whether it holds, with two pieces of bookkeeping:
- Any number of candidates can be compared for free on a separate *selection* sample from $D_X$.
- Certifying $K$ candidates and reporting the best costs $\delta_2\to\delta_2/K$. Choosing among $K$ codes costs $\log_2K$ bits; the main note charges 4 bits and $\delta_2/16$ for this.

**Proposition 2 (completeness for simple noise-free targets).** Suppose the labels are $y=t(x)$ for a target $t$ with an $L_t$-bit description in the code. Then for *every* trained $f$, the description $g=t$ gives, with probability $\ge1-\delta_1-\delta_2$,

$$\mathrm{err}(f)\ \le\ \frac{L_t\ln2+\ln(1/\delta_1)}{m}+\overline{\mathrm{Bin}}(j,N,\delta_2),\qquad j=\#\{l:f(x'_l)\ne t(x'_l)\},$$

and $\overline{\mathrm{Bin}}(j,N,\delta_2)=\mathrm{err}(f)+O\big(\sqrt{\mathrm{err}(f)\ln(1/\delta_2)/N}+\ln(1/\delta_2)/N\big)$ with high probability.

*Proof.* $t$ makes no training errors, and the exact binomial tail with $k=0$ is $1-(\delta_12^{-L_t})^{1/m}\le(L_t\ln2+\ln(1/\delta_1))/m$. Also $\Pr[f\ne t]=\mathrm{err}(f)$. $\square$

So on tasks with a short target, generalization plus the simple target imply that $f$ is close to a simple function. A search that does not know $t$ but chooses $g$ on a selection sample (separate from the certification sample) then certifies *any* trained network to within $(L_t\ln2+\ln(1/\delta_1))/m$ plus sampling slack.

With binary labels flipped independently with probability $\eta$, $g=t$ gives $\eta+O\big(\sqrt{\eta(L_t\ln2+\ln(1/\delta_1))/m}+(L_t\ln2+\ln(1/\delta_1))/m\big)+\Pr[f\ne t]$, against $\mathrm{err}(f)=\eta+(1-2\eta)\Pr[f\ne t]$. The excess is $2\eta\Pr[f\ne t]$ plus the Occam slack.

**Where the limit then lies.** For Theorem 2 with a code fixed before $S$, the bound is at least $B^*=\min_\sigma\overline{\mathrm{Bin}}(k_S(g_\sigma),m,\delta_12^{-L(\sigma)})$, the best Occam bound of any program at sample size $m$. With unlimited search it is at most about $B^*+\Pr[f\ne g^*]\le\mathrm{err}(f)+B^*+\mathrm{err}(g^*)$, where $g^*$ attains $B^*$. So past some point the limit is set by the task and the code, not by the network.
- *Noise-free Boolean tasks of the main note:* $B^*\approx(L\ln2+\ln(1/\delta))/m$ with $L=28$–98 bits (plus 4 design bits).
- *MNIST at $m=60{,}000$:* every $10^3$ bits adds about 1.2 points ($10^3\ln2/m$) to the Occam term. An Occam term of 0.1 needs a program of at most about 6,200 bits at 1% training error, 4,400 bits at 2%, or 9,100 bits at zero training error.
  - The tightest bound we know of for a code fixed in advance is 11.6% (Lotfi et al. 2022; 9.0% with a transfer prior), for a program of about $3\times10^3$ bits. Reaching that figure at that length takes roughly 4% training error.
  - Our own codec needs $1.8\times10^4$ bits for a surrogate with 3.7% test error, and $2.8\times10^4$ bits for one with 2.6% (`../results/summary_t2.md`).
  - The smallest networks reported to reach 99% accuracy have about $2\times10^3$ parameters (an unreviewed GitHub record).

We know of no MNIST program short enough for an Occam term of 0.1 at 1–2% training error, and nothing rules one out. Bounds that do not use a fixed code escape this floor: sample-compression and data-dependent-prior bounds (Pick-To-Learn 3.1%; Bazinet et al. 2026, 1.8–3.5%) and the twin bound of Section 4.

## 2. Compute

**Certification is cheap.** For a candidate $g$, $N=O(\ln(1/\delta)/\epsilon)$ evaluations of $f$ and $g$ certify a disagreement of order $\epsilon$ to within a constant factor.

**Brute-force search is exponential.** By Kraft's inequality there are at most $2^L$ descriptions of length at most $L$, so exhaustive search costs about $2^LN$ evaluations. That is $2^{31}\times2\times10^5\approx4\times10^{14}$ for the 31-bit parity table, and hopeless for the thousand-bit descriptions that dense targets need. Known speed-ups are modest: Levin search finds a $Kt$-optimal description in time about $2^{Kt}$. Hirahara, Ilango and Williams (STOC 2024) give non-uniform circuits of size about $2^{4L/5}\mathrm{poly}(t)$ for compression problems with decoder time $t$.

**Proposition 3 (black-box search is as hard as learning with membership queries).** Let $\{F_k:\{0,1\}^n\to\{0,1\}\}_{k\in\{0,1\}^\lambda}$ be a pseudorandom function family secure against $\mathrm{poly}(\lambda)$-time distinguishers, with $\lambda\le n\le\mathrm{poly}(\lambda)$, computable by networks of size $\mathrm{poly}(n)$. Then for every polynomial-time oracle algorithm $\mathcal A$ and all polynomials $p,q$, the following has negligible probability in $\lambda$ (over a uniform key and $\mathcal A$'s coins): $\mathcal A^{F_k}$ outputs a program $g$ that runs in time $p(n)$ and has $\Pr_x[g(x)\ne F_k(x)]\le\frac12-\frac1{q(n)}$.

Yet each $F_k$ has a short description. In a universal language of programs clocked at a fixed polynomial time that contains the PRF evaluator, $K_0(F_k)\le\lambda+O(\log n)$. In the network language of Section 1, $K_0(F_k)$ is at most the size of a network computing $F_k$, which is $\mathrm{poly}(n)$ bits. The hardness does not depend on which of these bounds is used.

*Proof.* A successful $\mathcal A$ gives a distinguisher $D^h$:
1. Run $\mathcal A^h$ for its time bound; a timeout means reject.
2. Evaluate the output $g$ with a $p(n)$-step clock (a timeout counts as disagreement) on $M=\Theta(q^2\lambda)$ fresh uniform inputs.
3. Accept iff $g$ and $h$ agree on more than a $\frac12+\frac1{2q}$ fraction of them.

If $h=F_k$, $D$ accepts with probability at least $\mathcal A$'s success probability minus $e^{-\Omega(\lambda)}$. If $h$ is a uniformly random function, the fresh inputs avoid $\mathcal A$'s at most $Q$ queries and each other with probability $\ge1-(MQ+M^2)2^{-n}$. On them $h$ is uniform and independent of $g$, so the agreement exceeds $\frac12+\frac1{2q}$ with probability $e^{-\Omega(\lambda)}$. Hence $\mathcal A$'s success probability is negligible. $\square$

This is the classical argument that small circuits cannot be learned from membership queries:
- Valiant (1984) made the observation.
- Goldreich, Goldwasser and Micali (1986) built PRFs from pseudorandom generators, and HILL (1999) built those from any one-way function.
- Kharitonov (1993) proved hardness for constant-depth threshold circuits, which include small neural networks, under factoring.

So in the worst case, query access to $f$ is not enough. With white-box access the problem needs a length condition, such as "output $g$ with $\Pr[f\ne g]\le\epsilon$ and $L(g)\le K_\epsilon(f)+s$", since otherwise $g=f$ solves it. A naive network for $F_k$ reveals its key, so white-box hardness would need $f$ to hide its structure, an obfuscation-type assumption; we have not proved it. Related hardness results for finding short descriptions consistent with data:
- NP-hardness of partial MCSP and of learning programs (Hirahara 2022).
- NP-hardness of properly learning decision trees even with queries (Koch, Strassle, Tan 2023).

None of this covers networks that gradient descent finds on tasks it learns. For those, Proposition 2 guarantees that a short $g$ exists (the target). Whether it can be found efficiently depends on the target class and is not settled here.

**What is tractable.**
- *Juntas.* If $f$ is $\epsilon$-close to a $k$-junta $h$, every relevant coordinate of $h$ has influence at least $2^{1-k}$, and influences of $f$ are within $2\epsilon$ of those of $h$. So thresholding estimated influences ($O(\log(n/\delta)/\epsilon^2)$ queries per coordinate) finds a set $J$ of at most $k$ of $h$'s relevant coordinates, and $f$ is $O(k\epsilon)$-close to a junta on $J$. $J$ is exactly the relevant set when $\epsilon<2^{-k-1}$.
- *Sparse Fourier spectra.* The Kushilevitz–Mansour algorithm (1993) finds all large Fourier coefficients with membership queries in $\mathrm{poly}(n,1/\theta)$ time. For decision trees, agnostic learning with queries is polynomial (Gopalan, Kalai, Klivans 2008), and proper learning takes $n^{O(\log\log n)}$ time (Blanc, Lange, Qiao, Tan 2021).
- *The main note's Boolean codec* combines influence estimation and a truth table on the top coordinates with distilled quantized students. It took about 0.5–5 minutes per network on one CPU thread (median about 2 minutes), mostly for distillation.
- *Distillation* fits a small student to $f$'s labels on fresh inputs. That is learning with *unlimited* labelled data, so there is no statistical obstacle, only an optimization one, and no guarantee.
  - Stanton et al. (2021) find that students often fail to match their teachers even when they have the capacity to.
  - Boix-Adsera (2024) formalizes "PAC-distillation" and shows it can be much cheaper than learning from scratch when the teacher's internal representations can be read off.
- *White-box compression of $f$ itself*, such as subsampling hidden units (Section 3), with guarantees in terms of norms of $f$.
- *Using the learning algorithm as the decoder* (Section 4). Description length can be measured relative to any decoder fixed in advance, including "run the training algorithm on these examples", as in sample compression (Littlestone and Warmuth 1986). The search is then retraining, which is polynomial.

## 3. Subsampling hidden units

A one-hidden-layer network is a sum over its units, $f(x)=c+\sum_{i=1}^Na_i\varphi_i(x)$ with $\varphi_i(x)=\mathrm{relu}(w_i\cdot x+b_i)$ and $a_i\in\mathbb R^C$ the output weights of unit $i$. Let $s_i=\|a_i\|\,\|\varphi_i\|_{L_2(D_X)}$ and $A=\sum_is_i$, the path norm of $f$ under $D_X$.

**Proposition 4 (Maurey).** Draw $k$ units i.i.d. with probabilities $p_i=s_i/A$ and set $g(x)=c+\frac1k\sum_{j=1}^ka_{I_j}\varphi_{I_j}(x)/p_{I_j}$. Then exactly

$$\mathbb E_I\,\mathbb E_{x\sim D_X}\|g(x)-f(x)\|^2=\frac{A^2-\|f-c\|^2_{L_2(D_X)}}{k}.$$

Hence, for a binary $f$ (one logit) and every $\gamma>0$,

$$\mathbb E_I\Pr_x[\mathrm{sign}\,g\ne\mathrm{sign}\,f]\ \le\ \Pr_x[|f(x)|\le\gamma]+\frac{A^2-\|f-c\|^2}{k\gamma^2}.$$

For $C$ classes, let $M_f(x)$ be the gap between $f$'s two largest logits (0 for ties). Then

$$\mathbb E_I\Pr_x[\arg\max g\ne\arg\max f]\le\Pr_x[M_f(x)\le\gamma]+\frac{2(A^2-\|f-c\|^2)}{k\gamma^2}.$$

*Proof.* For fixed $x$ the summands $Z_j=a_{I_j}\varphi_{I_j}(x)/p_{I_j}$ are i.i.d. with mean $f(x)-c$ and second moment $\sum_i\|a_i\|^2\varphi_i(x)^2/p_i$. Averaging over $x$, $\sum_i\|a_i\|^2\|\varphi_i\|^2/p_i=\sum_is_i^2/p_i=A^2$, which gives the identity.
- *Binary:* if the signs differ, then $|f(x)|\le\gamma$ or $|g(x)-f(x)|>\gamma$; apply Markov's inequality to the second event.
- *Multi-class:* write $e=g-f$. If $\arg\max g=c'\ne\arg\max f=y^*$, then $e_{c'}-e_{y^*}\ge M_f(x)$, and $(e_{c'}-e_{y^*})^2\le2\|e\|^2$. So $M_f(x)>\gamma$ forces $\|e\|^2>\gamma^2/2$; apply Markov's inequality. $\square$

In practice $s_i$ and $A$ are estimated on a pool of inputs. The identity is then exact for the pool's empirical distribution. Against $D_X$ the right side becomes $(\sum_is_i^2/\hat p_i-\|f-c\|^2)/k\ge(A^2-\|f-c\|^2)/k$ by Cauchy–Schwarz, which on a test network differs by less than 0.5% with a 300-point pool. Monte Carlo runs reproduce the identity within their sampling error (about 1%), for binary, multi-class and update versions (`code/tests/test_subsample.py`). None of this affects validity, since the final disagreement is always certified on fresh inputs (Proposition 1).

Variants:
- *Top-$k$ with refit.* Keep the $k$ units with the largest importances $\hat s_i$, measured on a fitting sample, and refit the output layer by least squares on $f$'s logits there. Keeping the original output weights is feasible for the least-squares problem, so the refit's mean squared error on the fitting sample is at most $(\sum_{i\notin\text{top }k}\hat s_i)^2$, up to the tiny ridge used for numerical stability. This is not a bound under $D_X$.
- *Greedy selection* (orthogonal matching pursuit over $f$'s units). Ye et al. (ICML 2020) analyse greedy forward selection from a large trained network and show that the selected sub-network's loss approaches that of the full network at rate $O(1/k)$ for two-layer networks.
- *Subsampling the update.* The initialization is free (main note, Lemma 8) and $f-f_0=(c-c_0)+\sum_i\delta_i$ with $\delta_i=a_i\varphi_i-a_i^0\varphi_i^0$. Sampling with $p_i=\|\delta_i\|_{L_2(D_X)}/A_\Delta$, $A_\Delta=\sum_i\|\delta_i\|$, gives $g=f_0+(c-c_0)+\frac1k\sum_j\delta_{I_j}/p_{I_j}$ with $\mathbb E\|g-f\|^2=(A_\Delta^2-\|f-f_0-(c-c_0)\|^2)/k$.

Related work: Mussay et al. (ICLR 2020) prune neurons exactly by this importance-sampling estimator, with data-independent sensitivities. Baykal et al. (ICLR 2019) importance-sample weights by empirical sensitivity and derive generalization bounds for the compressed network.

**When can this work?** The Maurey guarantee gives disagreement at most $\Pr[\text{margin}\le\gamma]+\epsilon$ with $k=(A^2-\|f-c\|^2)/(\epsilon\gamma^2)$ units. It certifies a compression only if this $k$ is much smaller than $N$. It gives a non-vacuous bound only if the description of the kept units, about $k_{\rm unique}(d+1+C)b$ bits (plus $\log_2N$ per unit when they are coded relative to their initialization), is much smaller than $m$. The precision $b$ must also be fine enough that quantization errors are small next to $\gamma$. This is a sufficient condition; refitting and greedy selection can do much better than the bound. How the constant scales with width:
- *Mean-field scaling* ($a_i=\tilde a_i/N$ with $\tilde a_i=O(1)$): $A=O(1)$ whatever the width $N$, so a width-independent $k$ suffices. This matches the "dropout stability" of mean-field SGD solutions (Shevchenko and Mondelli 2020), whose loss change after removing neurons depends on how many are kept, not on $N$.
- *Standard (NTK) scaling* ($a_i\sim1/\sqrt N$): $A\sim\sqrt N$ while $f=O(1)$, so the guarantee needs $k\propto N$.
- *Update in the lazy regime:* each $\delta_i$ is $O(1/N)$, so heuristically $A_\Delta=O(1)$. But each sampled unit's weight change still has to be described.

The experiments measure $A$, $A_\Delta$, the margins and the participation ratio $N_{\rm eff}=A^2/\sum_is_i^2$ (the effective number of units) for each network.

### Experiments

Code `code/experiments/subsample_run.py`; full tables in [`../results/search/summary_subsample.md`](../results/search/summary_subsample.md); figure [`../figures/search_curves.png`](../figures/search_curves.png).

**Setup.**
- *Tasks.* Inputs are uniform on $\{\pm1\}^{50}$ and $m=16{,}000$. There are four junta or threshold targets: majority of 5 bits, majority of all 50, 3-parity, and a random 6-junta. There are two dense non-junta targets, `teacher4` and `teacher8`: the sign of a random 4- or 8-unit ReLU network on all 50 inputs, with balanced classes. In those, every input bit has influence 5–12%, so influence-guided junta search cannot find them.
- *Networks $f$.* One hidden layer, trained to zero training error in three regimes:
  - standard initialization with Adam (512 and 4,096 units);
  - mean-field parametrization $f=\frac1N\sum_ia_i\,\mathrm{relu}(w_i\cdot x+b_i)$ with SGD at learning rate $0.2N$ (512 and 4,096 units);
  - standard initialization ×2 with momentum SGD (512 units). Its parameters move 40–60% of their initial norm, so it is not truly lazy; the files call it `lazy`.

  The main note's two-hidden-layer (50, 512, 512, 1) networks are included too. One seed per network, with a second seed for four of them.
- *Search families,* all polynomial-time:
  - the main note's influence codec;
  - distillation from scratch into a $k$-unit student;
  - keeping $k$ units (Maurey sampling, top-$k$ by importance, uniform; greedy matching pursuit) and refitting the output layer by least squares, with the kept units coded absolutely or relative to their initialization rows;
  - subsampling the update relative to the initialization;
  - subsampling or greedy selection followed by distillation.

  Every candidate is quantized at three step sizes, for $k\in\{2,4,\dots,64\}$. Each family's best candidate is chosen on a 30,000-input selection sample and certified on $2\times10^5$ fresh inputs. The bound is Theorem 2 with the main note's design charge, plus 3 bits for the family.
- *Oracle.* The last column codes the true teacher network, known to us but not to any search, at the best of seven step sizes. It shows what a search that found the target would certify.

Bound on $\mathrm{err}(f)$ per search family, with the bits of $g$ in parentheses; bold is the best search for that network:

| target | network f | test err. f | influence codec | distill from scratch | best subsample/greedy + refit | best subsample/greedy + distill | true target (oracle) |
|---|---|---|---|---|---|---|---|
| maj5 | standard 512 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.068 (1201) | 0.008 (170) | - |
| maj5 | standard 4096 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.130 (2207) | 0.008 (172) | - |
| maj5 | SGD x2 512 | 0.0000 | **0.002** (41) | 0.006 (132) | 0.200 (2507) | 0.008 (168) | - |
| maj5 | mean-field 512 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.007 (144) | 0.007 (145) | - |
| maj5 | mean-field 4096 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.007 (152) | 0.007 (151) | - |
| fullmaj | standard 512 | 0.0000 | **0.002** (44) | 0.004 (72) | 0.196 (2370) | 0.006 (136) | - |
| fullmaj | standard 4096 | 0.0001 | **0.002** (44) | 0.004 (72) | 0.267 (3252) | 0.008 (167) | - |
| fullmaj | SGD x2 512 | 0.0018 | **0.004** (44) | 0.006 (72) | 0.299 (1862) | 0.024 (259) | - |
| fullmaj | mean-field 512 | 0.0000 | **0.002** (44) | 0.004 (71) | 0.008 (178) | 0.004 (74) | - |
| fullmaj | mean-field 4096 | 0.0000 | **0.002** (44) | 0.004 (71) | 0.008 (185) | 0.009 (191) | - |
| parity3 | standard 512 | 0.0000 | **0.002** (31) | 0.014 (323) | 0.016 (363) | 0.010 (218) | - |
| parity3 | standard 512, seed 1 | 0.0000 | **0.002** (31) | 0.015 (342) | 0.015 (346) | 0.012 (280) | - |
| parity3 | standard 4096 | 0.0000 | **0.002** (31) | 0.015 (350) | 0.009 (205) | 0.008 (180) | - |
| parity3 | SGD x2 512 | 0.0000 | **0.002** (31) | 0.018 (401) | 0.010 (216) | 0.010 (218) | - |
| parity3 | mean-field 512 | 0.0000 | **0.002** (31) | 0.016 (363) | 0.009 (207) | 0.010 (212) | - |
| parity3 | mean-field 512, seed 1 | 0.0000 | **0.002** (31) | 0.023 (524) | 0.010 (216) | 0.012 (261) | - |
| parity3 | mean-field 4096 | 0.0000 | **0.002** (31) | 0.016 (358) | 0.011 (244) | 0.012 (263) | - |
| junta6 | standard 512 | 0.0000 | **0.005** (98) | 0.044 (1032) | 0.139 (2252) | 0.025 (567) | - |
| junta6 | standard 4096 | 0.0006 | **0.005** (98) | 0.037 (852) | 0.180 (2616) | 0.026 (587) | - |
| junta6 | SGD x2 512 | 0.0015 | **0.007** (98) | 0.040 (880) | 0.130 (2390) | 0.031 (680) | - |
| junta6 | mean-field 512 | 0.0000 | **0.005** (98) | 0.037 (861) | 0.086 (2073) | 0.029 (679) | - |
| junta6 | mean-field 4096 | 0.0000 | **0.005** (98) | 0.045 (1051) | 0.119 (1412) | 0.045 (1043) | - |
| teacher4 | standard 512 | 0.0408 | 0.200 (1427) | 0.217 (1961) | 0.308 (1879) | **0.153** (1016) | 0.122 (1434) |
| teacher4 | standard 512, seed 1 | 0.0402 | **0.189** (1880) | 0.225 (2685) | 0.293 (1416) | 0.199 (1827) | 0.123 (1434) |
| teacher4 | standard 4096 | 0.0517 | 0.226 (1412) | 0.224 (1920) | 0.359 (2656) | **0.167** (1007) | 0.133 (1434) |
| teacher4 | SGD x2 512 | 0.0422 | 0.214 (1419) | 0.225 (1947) | 0.262 (979) | **0.153** (977) | 0.123 (1434) |
| teacher4 | mean-field 512 | 0.0221 | 0.199 (1847) | **0.198** (2625) | 0.259 (2803) | 0.209 (1854) | 0.103 (1434) |
| teacher4 | mean-field 512, seed 1 | 0.0212 | **0.170** (977) | 0.214 (2740) | 0.262 (1805) | 0.218 (1806) | 0.104 (1434) |
| teacher4 | mean-field 4096 | 0.0214 | **0.184** (1446) | 0.202 (2627) | 0.215 (1071) | 0.195 (973) | 0.103 (1434) |
| teacher8 | standard 512 | 0.0557 | **0.258** (1377) | 0.271 (1927) | 0.428 (2764) | 0.268 (2723) | 0.193 (2744) |
| teacher8 | standard 4096 | 0.0624 | 0.285 (1705) | **0.268** (1907) | 0.455 (2689) | 0.277 (2625) | 0.201 (2744) |
| teacher8 | SGD x2 512 | 0.0683 | 0.295 (1751) | **0.283** (1892) | 0.478 (3780) | 0.326 (2705) | 0.208 (2744) |
| teacher8 | mean-field 512 | 0.0344 | 0.263 (2673) | **0.254** (1952) | 0.345 (3467) | 0.306 (2611) | 0.173 (2744) |
| teacher8 | mean-field 4096 | 0.0340 | 0.266 (2680) | **0.259** (1970) | 0.361 (3507) | 0.310 (3505) | 0.174 (2744) |
| maj5 | standard 512 x2 layers | 0.0000 | **0.002** (41) | 0.007 (156) | 0.367 (5426) | 0.009 (187) | - |
| parity3 | standard 512 x2 layers | 0.0000 | **0.002** (31) | 0.013 (285) | 0.209 (4356) | 0.015 (328) | - |
| junta6 | standard 512 x2 layers | 0.0000 | **0.005** (98) | 0.030 (688) | 0.656 (13970) | 0.048 (1136) | - |
| teacher4 | standard 512 x2 layers | 0.0395 | 0.225 (2714) | **0.164** (1099) | 0.582 (5780) | 0.328 (4698) | 0.120 (1434) |

**What the experiments show.**
1. *Juntas and threshold functions: search is solved.* The influence codec recovers the target on every network (31–98 bits, bounds 0.002–0.007). Distillation from scratch comes next (0.004–0.045).
2. *Subsampling works where Proposition 4 says it should.*
   - On mean-field networks, 2 kept units reproduce the majority targets exactly and 4 the 3-parity, giving 144–244-bit descriptions and bounds 0.007–0.011.
   - On standard and SGD networks, the majorities need 16–32 units. Each unit carries 50 dense input weights, so the descriptions cost 1,200–3,300 bits and the bounds 0.07–0.30.
   - The floating-point curves show where the cost lies: 16 top units already reach 1.8% disagreement on the standard 512-unit majority network. Finding the units is cheap; describing them is not.
   - 3-parity is carried by 4–8 units in every regime (bounds 0.009–0.016). The random 6-junta needs 16–32 in every regime (0.09–0.18).
   - The path norm behaves as the scaling argument predicts. For mean-field nets it is width-independent: 5-bit majority $A=10.0$ at both widths, teacher4 97.8 and 96.4. For standard nets it grows: 26.7 to 47.4, and 90.6 to 140.9.
   - The Maurey bound itself is loose. For the mean-field majority network it promises disagreement at most 0.95 at $k=4$ (the measured value is 0); for the standard network, 0.74 at $k=32$ (measured 0.12).
3. *Subsampling the update relative to the initialization* was never the best family.
4. *Dense targets: a search gap.*
   - The best search on each dense-target network reaches only 0.15–0.28, while the true teacher, a 1,434-bit (teacher4) or 2,744-bit (teacher8) description, would give 0.10–0.21. The ratio of best search to oracle is 1.24–1.92.
   - Subsampling or greedy selection followed by distillation is the best family on 3 of the 8 teacher4 networks (0.153–0.167 against 0.217–0.225 from scratch), and never on teacher8.
   - The floating-point disagreement falls slowly with $k$ for every selection rule (figure). The dense target is spread over many units of $f$, as one would expect for a function that is not a junta.
5. *Compute.* Each family took between 9 seconds and 13 minutes per network on one CPU thread; training $f$ took 2–84 seconds.

**MNIST** ([`../results/search/summary_mnist_subsample.md`](../results/search/summary_mnist_subsample.md)). For a 784-1024-10 network (test error 1.55%, $A=360$, effective units 612), with the unlabeled-data bound of the main note and a union bound over 78 configurations:
- the best surrogate is a 32-unit student distilled from scratch: 6,148 bits, $\Pr[f\ne g]=5.4\%$, bound 0.255;
- keeping the top 64 units, refitting and fine-tuning gives 11,733 bits, 3.6%, bound 0.272;
- Maurey sampling gives 0.304;
- coding the whole network gives 0.444.

## 4. Subsampling the data: the twin bound

**Proposition 5 (twin bound).** Before seeing the data, fix:
- a subset $I\subset[m]$ of size $s$;
- the training algorithm $\mathcal A$ with all its hyperparameters;
- how the seeds are chosen;
- the split $(\delta_1,\delta_2)$.

Let $f=\mathcal A(S,\omega)$ and $f_s=\mathcal A(S_I,\omega')$, with randomness $\omega,\omega'$ independent of $S$ (they may coincide). Let $k_{\rm out}$ be the number of errors of $f_s$ on the $m-s$ held-out examples $S\setminus S_I$, and $j$ the number of disagreements between $f$ and $f_s$ on $N$ fresh inputs from $D_X$. Then with probability $\ge1-\delta_1-\delta_2$,

$$\mathrm{err}(f)\ \le\ \overline{\mathrm{Bin}}(k_{\rm out},m-s,\delta_1)+\overline{\mathrm{Bin}}(j,N,\delta_2).$$

*Proof.* $\mathrm{err}(f)\le\mathrm{err}(f_s)+\Pr[f\ne f_s]$. Conditional on $(S_I,\omega')$, $f_s$ is fixed and $S\setminus S_I$ is an i.i.d. sample from $D$, so the binomial tail bounds $\mathrm{err}(f_s)$ with probability $\ge1-\delta_1$. Conditional on $(S,\omega,\omega')$, both networks are fixed and the fresh inputs bound $\Pr[f\ne f_s]$ with probability $\ge1-\delta_2$. $\square$

No description length and no search appear. In the language of compression, $f_s$ is described by the algorithm, $I$ and the seed, relative to the training set. This is a sample-compression scheme whose index set is fixed in advance, which removes the $\log_2\binom ms$ union-bound cost. Validity never depends on $f_s$ being close to $f$; tightness depends on the training algorithm being stable in function space when part of the data is removed. The price: it needs the training algorithm and one retraining. Like Theorem 2, it needs $D_X$ known or unlabeled inputs, so it does not apply in the training-data-only setting.

**Prior work.** This is not a new idea:
- Kääriäinen (COLT 2005) bounds the classifier trained on all the labelled data through the classifiers of a cross-validation run, each certified on its held-out fold. Unlabeled data derandomizes this (the "semibound" package of Kääriäinen and Langford, ICML 2005). Proposition 5 is the one-twin special case, and with a known $D_X$ its unlabeled-data requirement is free.
- The triangle inequality for the disagreement metric goes back to Schuurmans (1997) and to co-validation (Madani, Pennock, Flake 2004).
- Jiang et al. (ICLR 2022) observe that two SGD runs disagree on test inputs at about the test error (the generalization-disagreement equality). That suggests the bound will be about twice the test error when the twin generalizes like $f$.
- Bazinet et al. (2026) build certified surrogates by retraining on selected subsets of the training data (coresets, Pick-To-Learn), paying a sample-compression cost for the selection.

We pre-register $s=m/2$ (the same seed as $f$) and report other fractions only as diagnostics: reporting the best of several would need a union bound. For images, the test inputs used without their labels are assumed to be i.i.d. from the training input distribution, as in Theorem 2's experiments.

### Experiments

Code `code/experiments/twin_run.py`; tables in [`../results/search/summary_twin.md`](../results/search/summary_twin.md); figure [`../figures/search_twin.png`](../figures/search_twin.png). Each twin is trained on a fixed subset of $s=m/2$ training points with the same seed as $f$. $f$ is exactly the network of the main note's experiments (same data, seed and training), so the compression bounds below are on the same $f$; the analysis checks this by comparing test errors.

| setting | test err. $f$ | compression bound (same $f$) | twin bound ($s=m/2$) | $\Pr[f\ne f_s]$ |
|---|---|---|---|---|
| Boolean, $m=16{,}000$, 5-bit majority (3 seeds) | 0.0000 | 0.0024 | **0.0005** | 0.0000 |
| Boolean, $m=16{,}000$, 3-parity | 0.0000 | 0.0018 | **0.0005** | 0.0000 |
| Boolean, $m=16{,}000$, random 6-junta | 0.0000 | 0.0047 | **0.0016** | 0.0003 |
| Boolean, $m=16{,}000$, majority of 50 | 0.0011 | **0.0037** | 0.0108 | 0.0047 |
| Boolean, $m=16{,}000$, teacher4 (seed 0) | 0.0395 | 0.164 (oracle 0.120) | **0.118** | 0.048 |
| Boolean, $m=16{,}000$, 5-bit majority, 10% label noise | 0.1390 | **0.174** | 0.230 | 0.077 |
| Boolean, $m=4000$, 3-parity | 0.0000 | **0.0070** | 0.619 | 0.297 |
| Boolean, $m=4000$, random 6-junta | 0.0223 | **0.042** | 0.336 | 0.149 |
| MNIST 784-100-10 | 0.0229 | 0.313 | **0.057** | 0.020 |
| MNIST 784-256-10 | 0.0197 | 0.368 | **0.050** | 0.019 |
| MNIST 784-1024-10 | 0.0155 | 0.255 | **0.042** | 0.015 |
| Fashion-MNIST 784-256-10 | 0.1106 | 0.619 | **0.210** | 0.084 |

- **Where the twin wins.** Once a network trained on half the data has learned the task, the twin bound is close to the test error. It beats every compression bound we have on the image networks, by a factor of 3–7. On the teacher4 network it matches the true-teacher oracle (0.118 vs 0.120) without knowing the target. On MNIST it is about 2.5–2.7 times the test error, consistent with the observation that independently trained networks disagree at about their test error (Jiang et al. 2022). A twin with a different seed gives about the same: 0.052 against 0.050 for the 256-unit network.
- **Where it loses.**
  - Near the learning threshold: a twin on 2,000 examples has not learned 3-parity, while $f$ on 4,000 has.
  - With interpolated label noise: each network memorizes its own flipped labels, so they disagree on about 8% of inputs, while the compressed surrogate is the clean rule.
  - So the two bounds are complementary.
- **Other fractions** ($s=m/4$, $3m/4$; diagnostics only, not used for any reported bound) trade the twin's accuracy against the size of its test set. $3m/4$ is better for every image network and for most Boolean tasks.

## 5. Is closeness true in practice?

What Theorem 2 needs is a short $g$ with $\Pr[f\ne g]$ not much larger than $\mathrm{err}(f)$. The evidence:
- *Tasks with a simple target.* Closeness follows from generalization (Proposition 2). On the junta and threshold-function tasks, every network that generalized was within its test error of the 31–98-bit target, and the target was found in polynomial time on every network.
- *Dense targets.* $f$ (2–7% test error) is within its test error of a 1,434- or 2,744-bit description (the teacher), so closeness holds. The polynomial-time searches found descriptions of 1,000–2,600 bits that disagree with $f$ on 2–7% of inputs, enough for bounds 1.24–1.92 times the oracle. The shortfall is the search, not closeness.
- *MNIST.* $f$ agrees with a retrained twin up to 1.5–2%, about its own error, and with 6,000–12,000-bit surrogates up to 3.6–5.4%. Whether a program short enough for a tight Occam term exists at 1–2% disagreement is open; Section 1 gives the arithmetic.
- *Literature.*
  - Compressed and distilled networks agree with their parents except on a small set of atypical inputs (Hooker et al. 2019, "pruning identified exemplars").
  - The disagreement left by distillation is often an optimization failure rather than a capacity limit (Stanton et al. 2021).
  - Two networks trained by SGD disagree at about their test error (Jiang et al. 2022).
  - All three fit the picture above: closeness at the level of $f$'s own error is the norm; closeness to a *short* program is a property of the task and of how much search one can afford.

## 6. What this suggests

1. **With a known input distribution or unlabeled data, try the twin first.** It costs one retraining, needs no search, and was 3–7 times tighter than compression on every image network. Compression helps where the twin is weak: near the learning threshold, with interpolated noise, or when the training algorithm is not available.
2. **Use structure-aware search, not generic search.** Influences (juntas) and Fourier methods (sparse spectra) are provably polynomial and found every junta target. Greedy selection from $f$'s own units beats random sampling in function space, and it is a good starting point for distillation. That the network has already solved the hard "find a good unit" subproblem (Bach 2017) is the reason to search inside it.
3. **Train for compressibility if a compression bound is the goal.** Mean-field-trained networks were compressible by plain subsampling (2 units for the majority targets), standard ones were not, at equal test error. Whether this extends to deep or convolutional networks is open.
4. **Search-gap targets.** The dense teacher targets give a clean benchmark: a known short description, networks that learn it, and a measurable gap (1.24–1.92×). Natural next attempts:
   - progressive distillation from intermediate checkpoints, which provably helps on sparse parities (Panigrahi et al. 2025);
   - white-box "PAC-distillation" that reads features off $f$'s hidden layer (Boix-Adsera 2024);
   - ridge-leverage-score unit sampling, which needs about the effective dimension of $f$'s features rather than $A^2/\gamma^2$ units (Bach 2017).
5. **Open theory.**
   - Is the white-box search problem (find $g$ with $L(g)\le K_\epsilon(f)+s$) hard for networks that gradient descent produces?
   - Is there a family of tasks where $f$ is learnable and its target short, but no polynomial-time procedure finds a short surrogate?
   - The twin bound sidesteps both questions by measuring description length relative to the training algorithm itself.

## Verification

The propositions and the subsampling code were checked by three independent AI referees (Propositions 1–2, Proposition 3, Propositions 4–5 with the code), each claimed defect then going to an independent adjudicator. The record is in [`verification_theory.json`](verification_theory.json).
- Real defects found and fixed include: a missing output-bias shift in the update version of Proposition 4; a factor of 2 (not 4) in the multi-class corollary; the exact conditions under which Proposition 1's "validity is free" holds; the quantifiers and citations of Proposition 3; the junta-search condition $\epsilon<2^{-k-1}$; and an overstated MNIST paragraph.
- No error was found in the main identities, and the code was confirmed to implement them. Monte Carlo tests of the identities are in `code/tests/test_subsample.py`.
- The literature sweep, five topic searches plus one on prior art for the twin bound, each with a verification pass, is in [`literature_sweep.json`](literature_sweep.json). Its main limitation: no paper page could be opened from this session, so citations rest on search-result snippets and on official code repositories.

## Files and reproduction

- `code/cgb/subsample.py`: Maurey, top-$k$, uniform and greedy unit selection, least-squares refit, update and two-layer variants.
- `code/experiments/subsample_run.py`: the Boolean search study (one network per call). It saves $f$ to `$CGB_NETS`, default `~/.cache/cgb_nets`. With `--families greedy --load_saved` it adds the greedy families on a saved network.
- `code/experiments/oracle_teacher.py`: the true-teacher reference.
- `code/experiments/mnist_subsample.py`: the MNIST surrogates.
- `code/experiments/twin_run.py`: the twin bound.
- `code/experiments/analyze_search.py`: summaries and figures.
- `code/tests/test_subsample.py`: Monte Carlo tests of the Maurey identities and the top-$k$ guarantee.
- Results: `results/search/*.jsonl` and `summary_*.md`. Figures: `figures/search_curves.png`, `figures/search_twin.png`.
- Command lines: for each task in {maj5, fullmaj, parity3, junta6, teacher4, teacher8} and network in {std 512, std 4096, mf 512, mf 4096, lazy 512}, run `python3 subsample_run.py --task T --param P --width N --out ../../results/search/subsample.jsonl`, then the same with `--families greedy --load_saved --out ../../results/search/subsample_greedy.jsonl`.
- `twin_run.py boolean --task T --m M --seed S [--noise 0.1]` uses the main grid's tasks, $m\in\{2000,4000,16000\}$ and seeds 0–2. `twin_run.py images --data D --hidden H` and `mnist_subsample.py --hidden 1024` cover the images.
- Everything ran on 4 CPU cores in about five hours.
