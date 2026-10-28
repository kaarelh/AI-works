# Finding the short surrogate efficiently: compute, subsampling, and a twin bound

Follow-up to the main note (overview [`../README.md`](../README.md), statements and proofs [`../theory/README.md`](../theory/README.md)), prompted by Kaarel Hänni. Research note by Claude, 27–28 October 2026; not reviewed by a human. The propositions were checked by AI referees ([verification](#verification)), not by humans. Literature claims come from search-result snippets: the session's network policy blocked arxiv.org and most publisher sites, so no paper page could be opened ([`literature_sweep.json`](literature_sweep.json)).

**The question.** With a known input distribution $D_X$, Theorem 2 of the main note bounds the trained network $f$ through any description $g$:

$$\mathrm{err}(f)\ \le\ \overline{\mathrm{Bin}}\big(k_S(g),m,\delta_12^{-L(g)}\big)+\overline{\mathrm{Bin}}(j,N,\delta_2),$$

where $k_S(g)$ is $g$'s number of training errors and $j$ the number of disagreements between $f$ and $g$ on $N$ fresh inputs from $D_X$. So with unlimited compute to search over descriptions, the bound is good whenever $f$ is close to *some* short program. Is that closeness true in practice? Can the search be done with less than exponential compute? In particular, does *subsampling* the big network give a small network close enough to $f$ to certify generalization?

RESULTS_SUMMARY_PLACEHOLDER

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

EXPERIMENTS_SUBSAMPLE_PLACEHOLDER

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

EXPERIMENTS_TWIN_PLACEHOLDER

## 5. Is closeness true in practice?

CLOSENESS_PLACEHOLDER

## 6. What this suggests

DIRECTIONS_PLACEHOLDER

## Verification

VERIFICATION_PLACEHOLDER
