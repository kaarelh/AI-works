# Finding the short surrogate efficiently: compute, subsampling, and a twin bound

Follow-up to the main note ([`../README.md`](../README.md)), prompted by Kaarel Hänni. Research note by Claude, 27–28 October 2026; not reviewed by a human.

**The question.** With a known input distribution $D_X$, Theorem 2 of the main note bounds the trained network $f$ by

$$\mathrm{err}(f)\ \le\ \overline{\mathrm{Bin}}\big(k_S(g),m,\delta 2^{-L(g)}\big)+\mathrm{CP}\big(\Pr_{D_X}[f\ne g]\big)$$

for every description $g$, and the disagreement term is certified by sampling. So, given unlimited compute to search over descriptions, the bound is good whenever $f$ is close to *some* short program. Is that closeness true in practice? Can the search be done with less than exponential compute? In particular, does *subsampling* the big network give a small network close enough to $f$ to certify generalization?

RESULTS_SUMMARY_PLACEHOLDER

## 1. What unlimited compute buys

Write $K_\epsilon(f)=\min\{L(g):\Pr_{D_X}[f\ne g]\le\epsilon\}$ for the $\epsilon$-approximate description length of $f$ under $D_X$, in a fixed prefix-free description language whose programs can be evaluated in polynomial time (networks with quantized weights, truth tables, circuits).

**Proposition 1 (validity does not depend on the search).** Let $g$ be the output of *any* search procedure, which may use $f$'s weights, the training set $S$, and any number of inputs from $D_X$. If $\Pr[f\ne g]$ is then certified on $N$ fresh inputs, the bound above holds with probability $\ge1-\delta_1-\delta_2$.

*Proof.* The Occam term holds simultaneously for all descriptions (Lemma 1 of the main note), so it holds for the one the search returns. Conditional on everything that determined $g$, the fresh inputs are i.i.d. from $D_X$, so the Clopper–Pearson interval for $\Pr[f\ne g]$ is valid. $\square$

So compute affects only *how good* the bound is, never whether it holds. A cheap heuristic search is always safe to try.

**Proposition 2 (completeness for simple noise-free targets).** Suppose the labels are $y=t(x)$ for a target $t$ with a description of $L_t$ bits. Then for *every* trained $f$, the description $g=t$ gives, with probability $\ge1-\delta_1-\delta_2$,

$$\mathrm{err}(f)\ \le\ \frac{L_t\ln2+\ln(1/\delta_1)}{m}\;+\;\mathrm{CP}_{N,\delta_2}\big(\mathrm{err}(f)\big),$$

where $\mathrm{CP}_{N,\delta_2}(p)$ is the Clopper–Pearson upper limit for a frequency of about $p$ in $N$ samples, so it tends to $\mathrm{err}(f)$ as $N\to\infty$.

*Proof.* $t$ makes no training errors, and the exact binomial tail with $k=0$ is $1-(\delta_12^{-L_t})^{1/m}\le(L_t\ln2+\ln(1/\delta_1))/m$. And $\Pr[f\ne t]=\mathrm{err}(f)$. $\square$

So for tasks with a short target, an unlimited search certifies *any* trained network to within $L_t\ln2/m$ of its true error, whether or not $f$ is itself simple: generalization plus a simple target imply closeness to a simple function. With label noise of rate $\eta$, the same $g=t$ gives $\eta+O(\sqrt{\eta L_t/m})+\Pr[f\ne t]$ against $\mathrm{err}(f)=\eta+(1-2\eta)\Pr[f\ne t]$.

The limit is then the task, not the network: the bound cannot beat the best Occam bound of *any* short program at sample size $m$. On the Boolean tasks of the main note that is $L\ln2/m$ with $L$ of 30–100 bits. On MNIST the best compression bounds we know of for *any* program are about 0.1 (Lotfi et al. 2022), and the shortest programs with 1–2% error seem to need thousands to tens of thousands of bits, which is comparable to $m=60{,}000$.

## 2. Compute

**Certification is cheap.** For a candidate $g$, a relative-accuracy estimate of $\Pr[f\ne g]=\epsilon$ needs $N=O(\ln(1/\delta)/\epsilon)$ evaluations of $f$ and $g$, i.e. a few forward passes per input.

**Brute-force search is exponential.** Enumerating all programs of at most $L$ bits and checking each on a selection sample costs about $2^{L+1}N$ evaluations: $2^{31}$ for the 31-bit parity table, and hopeless for the thousand-bit descriptions that dense targets need.

**Proposition 3 (black-box search is as hard as learning with queries).** Suppose a family of pseudorandom functions $F_k:\{0,1\}^n\to\{0,1\}$ (key length $\lambda$) is computable by polynomial-size networks. Then no polynomial-time algorithm with query access to $f$ can, for every $f$ in the family, output with non-negligible probability a polynomial-time-evaluable $g$ with $\Pr_{x}[g(x)\ne f(x)]\le\frac12-\frac1{q(n)}$ for some polynomial $q$, even though each such $f$ has $K_0(f)\le\lambda+O(1)$.

*Proof.* Such an algorithm gives a distinguisher. Run it on the oracle $h$, then compare $g$ and $h$ on $M=\mathrm{poly}(n)$ fresh uniform inputs. If $h=F_k$, the agreement is at least $\frac12+\frac1q$ with non-negligible probability. If $h$ is a truly random function, the fresh inputs avoid the algorithm's queries with probability $1-\mathrm{poly}(n)2^{-n}$, $h$ there is independent of $g$, and the agreement concentrates at $\frac12$. $\square$

This is the classical argument that polynomial-size circuits are not learnable from membership queries (Goldreich–Goldwasser–Micali 1986; Kearns–Valiant 1994). So the search has to use more than query access to $f$. With white-box access (the weights), a naive network for $F_k$ reveals its key. We expect the white-box problem to be hard in the worst case as well, for instance for obfuscated circuits, but we have not proved it. None of this says anything about networks that gradient descent finds on tasks it actually learns: those are not adversarial, and Proposition 2 says they are close to the (simple) target whenever they generalize.

**What is tractable.**
- *Structured search.* If $f$ is $\epsilon$-close to a $k$-junta, estimating influences finds the relevant coordinates with $\mathrm{poly}(n,2^k,1/\epsilon)$ queries. If it is close to a function with a sparse Fourier spectrum, the Kushilevitz–Mansour algorithm finds the large coefficients in polynomial time. The main note's Boolean codec is of this kind: it ran in seconds per network.
- *Distillation.* Fitting a small student to $f$'s labels on fresh inputs is learning with *unlimited* labelled data, so there is no statistical obstacle, only an optimization one. It is a heuristic with no guarantee.
- *White-box compression of $f$ itself,* such as subsampling hidden units (Section 3), with guarantees in terms of norms of $f$.
- *Using the learning algorithm as the decoder* (Section 4). Description length can be measured relative to any decoder fixed in advance, including "run the training algorithm on these examples". The search is then a retraining, so polynomial.

## 3. Subsampling hidden units

A one-hidden-layer network is a sum over its units, $f(x)=c+\sum_{i=1}^Na_i\varphi_i(x)$ with $\varphi_i(x)=\mathrm{relu}(w_i\cdot x+b_i)$ and $a_i\in\mathbb R^C$ the output weights of unit $i$. Let $s_i=\|a_i\|\,\|\varphi_i\|_{L_2(D_X)}$ and $A=\sum_is_i$, the path norm of $f$ under $D_X$.

**Proposition 4 (Maurey).** Draw $k$ units i.i.d. with probabilities $p_i=s_i/A$ and set $g(x)=c+\frac1k\sum_{j=1}^ka_{I_j}\varphi_{I_j}(x)/p_{I_j}$. Then exactly

$$\mathbb E_I\,\mathbb E_{x\sim D_X}\|g(x)-f(x)\|^2=\frac{A^2-\|f-c\|^2_{L_2(D_X)}}{k}.$$

Hence, for a binary $f$ (one logit), for every $\gamma>0$,

$$\mathbb E_I\Pr_x[\mathrm{sign}\,g\ne\mathrm{sign}\,f]\ \le\ \Pr_x[|f(x)|\le\gamma]+\frac{A^2-\|f-c\|^2}{k\gamma^2},$$

and for $C$ classes the same holds with the multi-class margin and a factor 4 in the second term.

*Proof.* For fixed $x$ the summands $Z_j=a_{I_j}\varphi_{I_j}(x)/p_{I_j}$ are i.i.d. with mean $f(x)-c$ and second moment $\sum_i\|a_i\|^2\varphi_i(x)^2/p_i$. Averaging over $x$, $\sum_i\|a_i\|^2\|\varphi_i\|^2/p_i=\sum_is_i^2/p_i=A^2$. So $\mathbb E\|g-f\|^2=(A^2-\|f-c\|^2)/k$. If $\mathrm{sign}\,g(x)\ne\mathrm{sign}\,f(x)$ then $|f(x)|\le\gamma$ or $|g(x)-f(x)|>\gamma$; apply Markov's inequality to the second event. $\square$

A Monte Carlo check agrees with the identity to within 1% (`code/tests/test_subsample.py`).

Two variants matter in practice:
- *Top-$k$ with refit.* Keep the $k$ units with the largest $s_i$ and refit the output layer by least squares on $f$'s logits. Keeping the original output weights is a feasible point of the least-squares problem, so the refit error on the fitting sample is at most $(\sum_{i\notin\text{top }k}s_i)^2$. This is a deterministic guarantee in terms of the tail of the importances.
- *Subsampling the update.* The initialization is free (main note, Lemma 8), so $g=f_0+\frac1k\sum_j\delta_{I_j}/p_{I_j}$ with $\delta_i=a_i\varphi_i-a_i^0\varphi_i^0$ obeys the same identity with $A_\Delta=\sum_i\|\delta_i\|$.

**When can this work?** The description of $g$ costs about $k(d+2)b$ bits for $k$ units on $d$ inputs at $b$ bits per weight. So subsampling helps only if $(A^2-\|f\|^2)/\gamma^2$ is small compared with the width, i.e. if the function is carried by a few units.
- *Mean-field scaling* ($a_i=\tilde a_i/N$ with $\tilde a_i=O(1)$): $A=O(1)$ whatever the width $N$, so a width-independent $k$ suffices.
- *Standard (NTK) scaling* ($a_i\sim1/\sqrt N$): $A\sim\sqrt N$ while $f=O(1)$, so the guarantee needs $k\propto N$.
- *Subsampling the update* in the lazy regime: each $\delta_i$ is $O(1/N)$, so heuristically $A_\Delta=O(1)$. But every sampled unit's weight change still has to be described.

The experiments below measure $A$, $A_\Delta$, the margins, and the participation ratio $A^2/\sum_is_i^2$ (the effective number of units) for each network.

EXPERIMENTS_SUBSAMPLE_PLACEHOLDER

## 4. Subsampling the data: the twin bound

**Proposition 5 (twin bound).** Fix a subset $I\subset[m]$ of size $s$ before seeing the data. Let $f=\mathcal A(S,\omega)$ and $f_s=\mathcal A(S_I,\omega')$ be the outputs of the same training algorithm on all of $S$ and on $S_I$, with randomness $\omega,\omega'$ independent of $S$ (they may coincide). Let $k_{\rm out}$ be the number of errors of $f_s$ on the $m-s$ held-out examples $S\setminus S_I$, and $j$ the number of disagreements between $f$ and $f_s$ on $N$ fresh inputs from $D_X$. Then with probability $\ge1-\delta_1-\delta_2$,

$$\mathrm{err}(f)\ \le\ \overline{\mathrm{Bin}}(k_{\rm out},m-s,\delta_1)+\mathrm{CP}(j,N,\delta_2).$$

*Proof.* $\mathrm{err}(f)\le\mathrm{err}(f_s)+\Pr[f\ne f_s]$. Conditional on $(S_I,\omega')$, $f_s$ is fixed and $S\setminus S_I$ is an i.i.d. sample from $D$, so the binomial tail bounds $\mathrm{err}(f_s)$ with probability $\ge1-\delta_1$. Conditional on $(S,\omega,\omega')$, both networks are fixed and the fresh inputs give the Clopper–Pearson bound with probability $\ge1-\delta_2$. $\square$

No description length and no search appear. In the language of compression, $f_s$ is described by (the algorithm, $I$, the seed) relative to the training set. This is a sample-compression scheme whose index set is fixed in advance, which removes the $\log_2\binom ms$ union-bound cost. Validity never depends on $f_s$ being close to $f$; tightness depends on the training algorithm being stable in function space when half the data is removed. The price: it needs the training algorithm and one retraining, and, like Theorem 2, it needs $D_X$ known or unlabeled inputs. It does not apply in the training-data-only setting.

EXPERIMENTS_TWIN_PLACEHOLDER

## 5. Is closeness true in practice?

CLOSENESS_PLACEHOLDER

## 6. What this suggests

DIRECTIONS_PLACEHOLDER
