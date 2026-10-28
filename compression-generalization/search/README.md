# Finding the short surrogate efficiently: compute, subsampling, and a twin bound

Follow-up to the main note (overview [`../README.md`](../README.md), statements and proofs [`../theory/README.md`](../theory/README.md)), prompted by Kaarel Hänni. Research note by Claude, 27–28 October 2026; not reviewed by a human. The propositions were checked by AI referees, and the report by an AI review against the raw results ([verification](#verification)), not by humans. Every citation was checked against the paper itself on arXiv, OpenReview, PMLR or a GitHub mirror, after the session's network policy was widened ([`verification_citations.json`](verification_citations.json)). The few papers that could still not be opened, because ECCC, Springer, SIAM and AAAI remained blocked, are marked; for them the note relies on later papers that restate the results. The earlier sweep, which had only search snippets, is in [`literature_sweep.json`](literature_sweep.json). Full references are at the end.

**The question.** With a known input distribution $D_X$, Theorem 2 of the main note bounds the trained network $f$ through any description $g$:

$$\mathrm{err}(f)\ \le\ \overline{\mathrm{Bin}}\big(k_S(g),m,\delta_12^{-L(g)}\big)+\overline{\mathrm{Bin}}(j,N,\delta_2),$$

where $k_S(g)$ is $g$'s number of training errors and $j$ the number of disagreements between $f$ and $g$ on $N$ fresh inputs from $D_X$. So with unlimited compute to search over descriptions, the bound is good whenever $f$ is close to *some* short program. Is that closeness true in practice? Can the search be done with less than exponential compute? In particular, does *subsampling* the big network give a small network close enough to $f$ to certify generalization?

## Short answers

- **Unlimited compute.** If the labels come from a target with an $L_t$-bit description, an exhaustive search over short descriptions certifies *every* trained network to within $(L_t\ln2+\ln(1/\delta))/m$ of its true error, plus sampling slack (Proposition 2). In general the limit is the best Occam bound of any program at sample size $m$. On MNIST at $m=60{,}000$ the best we know of is 8.7–11.6% (Lotfi et al. 2022), against the 1–2% test error of a trained network.
- **Is closeness to a simple function true in practice?** Only partly.
  - On a noise-free task, $f$ is within its test error of the target by definition ($\Pr[f\ne t]=\mathrm{err}(f)$). That makes $f$ close to a *short* function only when the target is short relative to $m$. For the junta and threshold-function targets (31–98 bits) it is, and the bounds are 0.002–0.007.
  - For the dense targets of Section 3 (signs of random 4- and 8-unit ReLU networks on 50 inputs), the target costs 1,434 or 2,744 bits. At $m=16{,}000$ its Occam term alone is 0.08 or 0.14, so even the coded teacher certifies only 2.6–5 times the test error. The best students we found do about as well (0.96–1.11 times the coded teacher's bound).
  - On MNIST we found no short function close to $f$. The best surrogates (6,000–12,000 bits) disagree with $f$ on 3.6–5.4% of inputs and certify 0.255. Tiny networks reported on GitHub (697 and 1,936 parameters at 99% test accuracy) suggest that shorter ones may exist; we have not tested them. $f$ is within 1.5–2% of a retrained twin, but the twin is not a short program. That supports the twin bound below, not closeness to a simple function.
- **Compute.**
  - Certification is cheap, but brute-force search costs about $2^LN$ evaluations ($2^L$ candidates, each checked on $N$ inputs).
  - Black-box search is as hard as learning small circuits from membership queries, which is impossible in polynomial time if pseudorandom functions exist (Proposition 3, classical). That is a statement about worst-case functions, not about the networks gradient descent produces on learnable tasks.
  - Searches that exploit structure work where the structure is there. On every junta and threshold-function target, an influence-guided codec recovers the target (31–98 bits, bounds 0.002–0.007) in 9 seconds to under 3 minutes per network.
  - On the dense targets, the best of the searches we ran once per network reached only 1.24–1.92 times the bound the true teacher itself would give (the others ended at up to 4.8 times). These were the influence codec, distillation, and unit subsampling or greedy selection followed by a refit or a distillation, with at most 2,000 distillation steps. On 10 of the 13 networks the best descriptions were about as close to $f$ as the teacher is, but they made 5–8 times as many training errors.
  - More compute of the plainest kind closed most of this. We trained a student with the teacher's width 32 times from random initializations, for 6,000 steps each on $f$'s labels plus the training set. Each student was quantized on a grid of five step sizes, and the best was kept by its estimated bound. This brought every dense network to 0.96–1.11 times the oracle: 0.96–1.02 for the 8-unit target, and 1.06–1.11 for the 4-unit one, where it closed 57–91% of the gap. A pass over the 32 restarts takes about 6 CPU-minutes per network.
  - Each ingredient matters. At the one-run budget of 2,000 steps per restart, 32 restarts reached only 1.14–1.38 times the oracle on the four networks tried, against 0.99–1.22 for the same restarts at 6,000 steps (both on the coarser three-step grid). For the 4-unit target, 11 of the 32 initializations succeed on every network (almost the same 11) and the rest get stuck. The coarser three-step grid left the 4-unit target at 1.13–1.25. The search need not be told the teacher's width: on the two networks where we swept it, choosing the width by the estimated bound picked the teacher's.
  - So on these targets the gap was an optimization failure of small students, which a modest, linear amount of extra compute removes. How the number of restarts needed grows for larger targets is untested.
- **Subsampling hidden units** (Maurey sampling, top-$k$ or greedy selection, each with a least-squares refit of the output layer) works when the function is carried by a few units. Proposition 4 gives a sufficient condition, and its width scaling matches what we see, but its bound was far too loose to be useful (0.74 or more, often above 1) at every $k$ where subsampling succeeded. On its own, subsampling was never the best search on any network.
  - On one-hidden-layer mean-field networks, 2 units reproduce the two majority targets and 4 the 3-parity (144–244 bits, bounds 0.007–0.011).
  - On standard one-hidden-layer networks, the majorities need 16–32 units and 1,200–3,300 bits (0.07–0.30). On two-hidden-layer networks, subsampling with a refit gives only 0.21–0.66.
  - The path norm behind the guarantee is width-independent for mean-field networks and grows with width for standard ones.
  - As a starting point for distillation it sometimes helps. Before the restarts, subsampling or greedy selection followed by distillation gave the best bound on 3 of the 8 teacher4 networks (0.153–0.167, against 0.21–0.22 for a student distilled from scratch). On MNIST, keeping the top 64 of 1,024 units and fine-tuning gives 0.272, against 0.255 for a 32-unit student distilled from scratch.
- **Subsampling the data instead.** If retraining is allowed, a twin trained on a fixed half of the training set gives a bound with one extra training run and no search (Proposition 5). The twin is tested on the other half, and its disagreement with $f$ is measured on fresh or unlabeled inputs. This is a special case of Kääriäinen (2005), and the tightest published bounds of Bazinet et al. (2026), 1.8% on an MNIST CNN, use the same construction.
  - MNIST: 0.042 for a 1024-unit network with test error 1.55%, where the best compression bound is 0.255.
  - Boolean tasks at $m=16{,}000$: 0.0005 on 5-bit majority, 3-parity and AND-3, and 0.0016 on the random 6-junta (means over 3 seeds). On the two-hidden-layer teacher4 network it gives 0.118, against 0.121 for the true-teacher oracle and 0.132 for the best search.
  - It loses to compression in three places. The first is where half the data is not enough to learn (3-parity at $m=4000$: 0.62 against 0.007; 6-junta at $m=4000$: 0.34 against 0.042). The second is the majority of all 50 bits at every $m$ (0.011 against 0.004 at $m=16{,}000$). The third is interpolated label noise (at $m=16{,}000$: 0.22–0.23 against 0.17).

Bottom line:
- Worst-case search is hopeless. Where we know a short description exists (the juntas and threshold functions, and the dense teacher targets), polynomial-time search found one about as good, in seconds to tens of minutes per network. On MNIST the surrogates we found are too long, and we did not test whether more search finds shorter ones.
- Structured search solves the junta and threshold-function targets. On the dense targets, single runs of cheap searches leave a factor of 1.2–1.9 to the oracle. Random restarts of a small student, with longer training and a fine enough quantization grid, bring it to 0.96–1.11 in about 12 CPU-minutes per network. Subsampling hidden units alone is not competitive, except on mean-field networks.
- When the training algorithm and unlabeled inputs (or a known $D_X$) are available, retraining a twin gave the tightest bounds on all four MNIST and Fashion-MNIST MLPs we tried (784-H-10, one training recipe, one seed each). They were 3–7 times tighter than our compression bounds, and cheaper to obtain. Other architectures are untested. On the Boolean tasks neither route dominates.

## 1. What unlimited compute buys

Write $K_\epsilon(f)=\min\{L(g):\Pr_{D_X}[f\ne g]\le\epsilon\}$ for the $\epsilon$-approximate description length of $f$ under $D_X$, in a prefix-free description language fixed before the data are seen, whose programs run in polynomial time (networks with quantized weights, truth tables, circuits).

**Proposition 1 (validity does not depend on the search).** Fix the code, including every codec one might try, before $S$ is drawn. Let $g$ be the output of any search procedure, which may use $f$'s weights, the training set $S$, and any inputs from $D_X$ other than the $N$ certification inputs. Use the certification inputs once, for the returned $g$. Then the bound above holds with probability $\ge1-\delta_1-\delta_2$.

*Proof.* The Occam term holds simultaneously for all descriptions (Lemma 1 of the main note), hence for the returned one. Conditional on everything that determined $g$, the certification inputs are i.i.d. from $D_X$, so the binomial upper limit for $\Pr[f\ne g]$ holds with probability $\ge1-\delta_2$. $\square$

So compute affects how good the bound is, not whether it holds, with two pieces of bookkeeping:
- Any number of candidates can be compared for free on a separate *selection* sample from $D_X$.
- Certifying several candidates and reporting the best costs a union bound: weight $w_i$ with $\sum_iw_i\le1$ on candidate $i$, and its disagreement term at $\delta_2w_i$. Choosing among $K$ codes costs $\log_2K$ bits. The main note charges 4 bits and $\delta_2/16$ for its codec designs; Section 3 charges another 4 bits and $\delta_2/16$ for naming one of up to 16 search families.

**Proposition 2 (completeness for simple noise-free targets).** Suppose the labels are $y=t(x)$ for a target $t$ with an $L_t$-bit description in the code. Then for *every* trained $f$, the description $g=t$ gives, with probability $\ge1-\delta_1-\delta_2$,

$$\mathrm{err}(f)\ \le\ \frac{L_t\ln2+\ln(1/\delta_1)}{m}+\overline{\mathrm{Bin}}(j,N,\delta_2),\qquad j=\#\{l:f(x'_l)\ne t(x'_l)\},$$

and $\overline{\mathrm{Bin}}(j,N,\delta_2)=\mathrm{err}(f)+O\big(\sqrt{\mathrm{err}(f)\ln(1/\delta_2)/N}+\ln(1/\delta_2)/N\big)$ with high probability.

*Proof.* $t$ makes no training errors, and the exact binomial tail with $k=0$ is $1-(\delta_12^{-L_t})^{1/m}\le(L_t\ln2+\ln(1/\delta_1))/m$. Also $\Pr[f\ne t]=\mathrm{err}(f)$. $\square$

So on tasks with a short target, generalization plus the simple target imply that $f$ is close to a simple function. A search that does not know $t$ but chooses $g$ on a selection sample (separate from the certification sample) then certifies *any* trained network to within $(L_t\ln2+\ln(1/\delta_1))/m$ plus sampling slack. "Short" is relative to $m$: the dense targets of Section 3 cost 1,434 and 2,744 bits, and their Occam terms alone at $m=16{,}000$ are 0.08 and 0.14.

With binary labels flipped independently with probability $\eta$, $g=t$ gives $\eta+O\big(\sqrt{\eta(L_t\ln2+\ln(1/\delta_1))/m}+(L_t\ln2+\ln(1/\delta_1))/m\big)+\Pr[f\ne t]$, against $\mathrm{err}(f)=\eta+(1-2\eta)\Pr[f\ne t]$. The excess is $2\eta\Pr[f\ne t]$ plus the Occam slack.

**Where the limit then lies.** For Theorem 2 with a code fixed before $S$, the bound is at least $B^*=\min_\sigma\overline{\mathrm{Bin}}(k_S(g_\sigma),m,\delta_12^{-L(\sigma)})$, the best Occam bound of any program at sample size $m$. With unlimited search it is at most about $B^*+\Pr[f\ne g^*]\le\mathrm{err}(f)+B^*+\mathrm{err}(g^*)$, where $g^*$ attains $B^*$. So past some point the limit is set by the task and the code, not by the network.
- *Noise-free Boolean tasks of the main note:* $B^*\approx(L\ln2+\ln(1/\delta))/m$ with $L=28$–98 bits (plus 4 design bits).
- *MNIST at $m=60{,}000$:* every $10^3$ bits adds about 1.2 points ($10^3\ln2/m$) to the Occam term. An Occam term of 0.1 needs a program of at most about 6,200 bits at 1% training error, 4,400 bits at 2%, or 9,100 bits at zero training error.
  - The tightest bound we know of for a code that is fixed before the data and uses no other data is 11.2% (Lotfi et al. 2022, LeNet-5 with full-batch training; no code length is reported for it). Their main figure, 11.6% with SGD, uses a program of about $3\times10^3$ bits (0.38 KB), and by our arithmetic reaching that figure at that length takes roughly 4% training error. With a prior pretrained on SVHN (also fixed before $S$) it is 9.0%, or 8.7% with full-batch training.
  - Our own codecs need about $1.2\times10^4$ bits for a surrogate with 3.7% test error (a 64-unit student distilled from the 1024-unit network of Section 3: 12,493 bits, `../results/search/mnist_subsample.jsonl`), and $2.8\times10^4$ bits for one with 2.6% (784-256-10, `../results/summary_t2.md`).
  - The smallest networks reported to reach 99% test accuracy have 697 and 1,936 parameters (unreviewed GitHub records). The 697-parameter network reaches 99.03% only at its best epoch in the best of about 300 runs, both chosen on the test set; the 1,936-parameter one reaches 99.1% at its final epoch. At 8 bits per weight they would take about 5,600 and 15,500 bits, and at 3–4 bits about 2,100–2,800 and 5,800–7,700.

We have not found or certified an MNIST program short enough for an Occam term of 0.1 at 1–2% training error. The tiny networks above suggest one may exist: at 3–4 bits per weight the 697-parameter one would fit even the 4,400-bit budget for 2% training error, if quantizing it keeps its accuracy and its training error is that low, neither of which we have checked. Bounds that do not use a fixed code escape this floor. On an MNIST CNN with 0.50% test error, Bazinet et al. (2026) report bounds on $f$ of:
- 3.5% through a compressed surrogate with a data-dependent prior;
- 3.9% through a Pick-To-Learn surrogate, whose own sample-compression certificate is 3.1%;
- 4.8% through a PAC-Bayes surrogate;
- 1.8% through a surrogate retrained on a random subset of the training set and tested on the rest: a hold-out bound, the twin bound of Section 4 ([`../literature.md`](../literature.md), Bound to Disagree).

## 2. Compute

**Certification is cheap.** For a candidate $g$, $N=O(\ln(1/\delta)/\epsilon)$ evaluations of $f$ and $g$ certify a disagreement of order $\epsilon$ to within a constant factor.

**Brute-force search is exponential.** By Kraft's inequality there are at most $2^L$ descriptions of length at most $L$, so exhaustive search costs about $2^LN$ evaluations. That is $2^{31}\times2\times10^5\approx4\times10^{14}$ for the 31-bit parity table, and hopeless for the thousand-bit descriptions that dense targets need. Levin search, which runs every program $p$ with a $2^{-|p|}$ share of the time, finds a $Kt$-optimal description in time about $2^{Kt}=2^{|p|}t$. That is the brute-force cost, reached without knowing $L$ or $t$ in advance, not a speed-up. Known speed-ups are modest and non-uniform: Hirahara, Ilango and Williams (STOC 2024) give circuits of size about $2^{4L/5}\mathrm{poly}(t)$, against $2^Lt$ for brute force, for compression problems with decoder time $t$ (checked against later papers only; ECCC, where it is posted, could not be opened).

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
- Kharitonov (1993) proved that if factoring Blum integers is hard, constant-depth threshold circuits, which include small neural networks, cannot even be weakly learned in polynomial time under the uniform distribution with membership queries: the setting of Proposition 3.

So in the worst case, query access to $f$ is not enough. With white-box access the problem needs a length condition, such as "output $g$ with $\Pr[f\ne g]\le\epsilon$ and $L(g)\le K_\epsilon(f)+s$", since otherwise $g=f$ solves it. A naive network for $F_k$ reveals its key, so white-box hardness would need $f$ to hide its structure, an obfuscation-type assumption; we have not proved it. Related hardness results for finding short descriptions consistent with data:
- NP-hardness, under randomized reductions, of partial MCSP and of learning programs (Hirahara, FOCS 2022; checked against later papers only, ECCC being unreachable).
- NP-hardness of properly learning decision trees even with queries (Koch, Strassle, Tan 2023).

None of this covers networks that gradient descent finds on tasks it learns. For those, Proposition 2 guarantees that a short $g$ exists (the target). Whether it can be found efficiently depends on the target class and is not settled here.

**What is tractable.**
- *Juntas.* If $f$ is $\epsilon$-close to a $k$-junta $h$, every relevant coordinate of $h$ has influence at least $2^{1-k}$, and influences of $f$ are within $2\epsilon$ of those of $h$. So thresholding estimated influences ($O(\log(n/\delta)/\epsilon^2)$ queries per coordinate) finds a set $J$ of at most $k$ of $h$'s relevant coordinates, and $f$ is $O(k\epsilon)$-close to a junta on $J$. With exact influences, $J$ is exactly the relevant set when $\epsilon<2^{-k-1}$. With estimates it needs accuracy better than $2^{-k}-2\epsilon$, which the budget above gives when $\epsilon\le2^{-k}/3$.
- *Sparse Fourier spectra.* The Kushilevitz–Mansour algorithm (1993), which builds on the Goldreich–Levin procedure, finds every Fourier coefficient of magnitude at least $\theta$ with membership queries under uniform inputs in $\mathrm{poly}(n,1/\theta)$ time (checked against later accounts; the 1993 paper could not be opened). For decision trees under the uniform distribution, agnostic learning with queries is polynomial (Gopalan, Kalai, Klivans 2008). Proper agnostic learning with queries can be done in $n^{O(\log\log n)}$ time for trees of size $\mathrm{poly}(n)$ and error $\epsilon\ge1/\mathrm{polylog}(n)$ (Blanc, Lange, Qiao, Tan 2021).
- *The main note's Boolean codec* combines influence estimation and a truth table on the top coordinates with distilled quantized students. It took about 0.5–5 minutes per network on one CPU thread (median about 2 minutes), mostly for distillation.
- *Distillation* fits a small student to $f$'s labels on fresh inputs. That is learning with *unlimited* labelled data, so there is no statistical obstacle, only an optimization one, and no guarantee.
  - Stanton et al. (2021) find that students often fail to match their teachers even when they have the capacity to.
  - Take standard Gaussian inputs, the population squared loss, and a teacher that is a sum of $k$ ReLUs with orthonormal weights. A student of the same form and width has spurious local minima for every $k$ from 6 to 20. Gradient descent from a random initialization reaches one in 0.3% of runs at 6 units and in 94% at 20, and never reached one below 6 units. One extra student unit makes them much rarer, and none were found with two or more (Safran and Shamir, ICML 2018). Section 3 sees a similar failure in a different setting (Boolean inputs, students with biases and output weights distilled from $f$, and stuck restarts already at 4 units), and random restarts fix most of it.
  - Boix-Adsera (2024) formalizes "PAC-distillation" and shows it can be much cheaper than learning from scratch. A network that computes a $k$-junta can be distilled into the explicit junta from queries alone in $\mathrm{poly}(d,2^k)$ time, while learning a $k$-junta from noisy examples is conjectured to take $\Omega(d^k)$ time. If the hidden activations linearly encode the path conjunctions of a depth-$r$ decision tree (the "linear representation hypothesis"), the network can be distilled into the tree in $\mathrm{poly}(d,2^r)$ time, while learning the tree from random examples is conjectured to take $d^{\Omega(r)}$ time.
- *White-box compression of $f$ itself*, such as subsampling hidden units (Section 3), with guarantees in terms of norms of $f$.
- *Using the learning algorithm as the decoder* (Section 4). Description length can be measured relative to any decoder fixed in advance, including "run the training algorithm on these examples", as in sample compression (Littlestone and Warmuth 1986). The search is then retraining, which is polynomial.

## 3. Subsampling hidden units, and other searches

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
- *Greedy selection* (orthogonal matching pursuit over $f$'s units). Ye et al. (ICML 2020) analyse greedy forward selection of neurons from a large network. For two-layer networks, the sub-network built in $k$ greedy steps (at most $k$ distinct neurons, since a neuron can be picked more than once, with the picks averaged with equal weights) has training squared loss $L^*_N+O(1/k)$, where $L^*_N$ is the best training loss over convex combinations of all $N$ neurons. The rate is $O(1/k^2)$ when the large network is over-parameterized enough that convex combinations of its neurons fit every small perturbation of the training labels exactly, which forces $L^*_N=0$. The guarantee is for their selection rule, not for matching pursuit with a least-squares refit.
- *Subsampling the update.* The initialization is free (main note, Lemma 8) and $f-f_0=(c-c_0)+\sum_i\delta_i$ with $\delta_i=a_i\varphi_i-a_i^0\varphi_i^0$. Sampling with $p_i=\|\delta_i\|_{L_2(D_X)}/A_\Delta$, $A_\Delta=\sum_i\|\delta_i\|$, gives $g=f_0+(c-c_0)+\frac1k\sum_j\delta_{I_j}/p_{I_j}$ with $\mathbb E\|g-f\|^2=(A_\Delta^2-\|f-f_0-(c-c_0)\|^2)/k$.

Related work: Mussay et al. (ICLR 2020) prune neurons with an estimator of the same form: i.i.d. draws with probability proportional to a data-independent sensitivity, with outgoing weights rescaled by count$/(p_i\times\text{draws})$. Their code keeps drawing until it has a fixed number of distinct neurons, so the number of draws is random and the estimator only approximates the fixed-$k$ one above. Baykal et al. (ICLR 2019) importance-sample weights by empirical sensitivity and derive generalization bounds for the compressed network.

**When can this work?** The Maurey guarantee gives disagreement at most $\Pr[\text{margin}\le\gamma]+\epsilon$ with $k=(A^2-\|f-c\|^2)/(\epsilon\gamma^2)$ units. It certifies a compression only if this $k$ is much smaller than $N$. It gives a non-vacuous bound only if the description of the kept units, about $k_{\rm unique}(d+1+C)b$ bits (plus $\log_2N$ per unit when they are coded relative to their initialization), is much smaller than $m$. The precision $b$ must also be fine enough that quantization errors are small next to $\gamma$. This is a sufficient condition; refitting and greedy selection can do much better than the bound. How the constant scales with width:
- *Mean-field scaling* ($a_i=\tilde a_i/N$ with $\tilde a_i=O(1)$): $A=O(1)$ whatever the width $N$, so a width-independent $k$ suffices. This matches the "dropout stability" of mean-field SGD solutions (Shevchenko and Mondelli, ICML 2020), whose loss change after removing neurons depends on how many are kept, not on $N$.
- *Standard (NTK) scaling* ($a_i\sim1/\sqrt N$): $A\sim\sqrt N$ while $f=O(1)$, so the guarantee needs $k\propto N$.
- *Update in the lazy regime:* each $\delta_i$ is $O(1/N)$, so heuristically $A_\Delta=O(1)$. But each sampled unit's weight change still has to be described.

The experiments measure $A$, $A_\Delta$, the margins and the participation ratio $N_{\rm eff}=A^2/\sum_is_i^2$ (the effective number of units) for each network.

### Experiments

Code `code/experiments/subsample_run.py` and `restarts_run.py`; full tables in [`../results/search/summary_subsample.md`](../results/search/summary_subsample.md); figures [`../figures/search_curves.png`](../figures/search_curves.png) and [`../figures/search_restarts.png`](../figures/search_restarts.png).

**Setup.**
- *Tasks.* Inputs are uniform on $\{\pm1\}^{50}$ and $m=16{,}000$. There are four junta or threshold targets: majority of 5 bits, majority of all 50, 3-parity, and a random 6-junta. There are two dense non-junta targets, `teacher4` and `teacher8`: the sign of a random 4- or 8-unit ReLU network on all 50 inputs, thresholded at its median (46% and 50% positive; for teacher4 the median is 0, where the ReLU sum has an atom). In those, every input bit has influence between about 3.5% and 29% (median about 9%), so influence-guided junta search cannot find them.
- *Networks $f$.* One hidden layer, trained to zero training error in three regimes:
  - standard initialization with Adam (512 and 4,096 units);
  - mean-field parametrization $f=\frac1N\sum_ia_i\,\mathrm{relu}(w_i\cdot x+b_i)$ with SGD at learning rate $0.2N$ (512 and 4,096 units);
  - standard initialization ×2 with momentum SGD (512 units). Its parameters move 18–56% of their initial norm (standard Adam training: 24–153%; mean-field: 330–1,340%). It moves the least of the three regimes but is not truly lazy; the files call it `lazy`.

  The main note's two-hidden-layer (50, 512, 512, 1) networks for 5-bit majority, 3-parity and the 6-junta are included too, with a teacher4 network of the same shape trained the same way. One seed per network, with a second seed for four of them.
- *Search families,* all polynomial-time, each run once per network unless stated:
  - the main note's influence codec;
  - distillation from scratch into a $k$-unit student (2,000 steps on $f$'s labels over fresh inputs);
  - keeping $k$ units (Maurey sampling, top-$k$ by importance, uniform; greedy matching pursuit) and refitting the output layer by least squares, with the kept units coded absolutely or relative to their initialization rows;
  - subsampling the update relative to the initialization;
  - subsampling or greedy selection followed by distillation;
  - on the 13 dense-target networks, distillation on $f$'s soft labels over fresh inputs together with the training set (where $f$'s labels are the true labels), from scratch, or after greedy selection on the 12 one-hidden-layer networks;
  - on the same 13 networks, 32 random restarts of a student with the teacher's width ($k=4$ for teacher4, 8 for teacher8), each trained for 6,000 steps on that mixed data and quantized at five step sizes. This took two passes with the same seeds: steps of 1, 1/2 and 1/4 of each layer's rms weight, then 1/4, 1/8 and 1/16. On the two standard 512-unit networks we also swept the width ($k=2$–8 for teacher4, 4–12 for teacher8). All runs on a network form one family: the restart, width and step size with the lowest estimated bound (training-set Occam term plus disagreement on the selection sample) are kept. Restart $r$ uses the same initialization and minibatch seed on every network. As a diagnostic outside any family, the restarts were also run at 2,000 steps (the one-run budget) on four networks.

  Every candidate is quantized at three step sizes, for $k\in\{2,4,\dots,64\}$. Each family's best candidate is chosen on the training set and a 30,000-input selection sample, then certified on $2\times10^5$ fresh inputs. The bound is Theorem 2 with the main note's design charge, plus a 4-bit prefix naming one of up to 16 search families, with each family's disagreement term at $\delta_2/16$. Every family pays this, the influence codec included, so the best of the families certified on a network is itself a valid bound, as long as at most 16 are certified (at most 12 were). Within a family, candidates are compared only on the training set and the selection sample, and only the chosen one's certification is used.
- *Oracle.* The last column codes the true teacher network, known to us but not to any search, at the best of seven step sizes (charged 6 bits, more than the $\log_27$ needed, and $\delta_2/7$ for the choice). It shows what a search that found the target would certify.

Bound on $\mathrm{err}(f)$ per search family, with the bits of $g$ in parentheses; bold is the best search for that network. The two distillation columns include the fresh-plus-training-input variants, the refit column excludes the update family (never the best), and the restart column is the restart family (best of all widths and step sizes run).

| target | network f | test err. f | influence codec | distill from scratch | subsample/greedy + refit | subsample/greedy + distill | best of 32 restarts | true target (oracle) |
|---|---|---|---|---|---|---|---|---|
| maj5 | standard 512 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.068 (1201) | 0.008 (170) | - | - |
| maj5 | standard 4096 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.131 (2207) | 0.008 (172) | - | - |
| maj5 | SGD x2 512 | 0.0000 | **0.002** (41) | 0.006 (132) | 0.200 (2507) | 0.008 (168) | - | - |
| maj5 | mean-field 512 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.007 (144) | 0.007 (145) | - | - |
| maj5 | mean-field 4096 | 0.0000 | **0.002** (41) | 0.006 (131) | 0.007 (152) | 0.007 (151) | - | - |
| fullmaj | standard 512 | 0.0000 | **0.003** (44) | 0.004 (72) | 0.196 (2370) | 0.006 (136) | - | - |
| fullmaj | standard 4096 | 0.0001 | **0.003** (44) | 0.004 (72) | 0.268 (3252) | 0.008 (167) | - | - |
| fullmaj | SGD x2 512 | 0.0018 | **0.005** (44) | 0.006 (72) | 0.300 (1862) | 0.024 (259) | - | - |
| fullmaj | mean-field 512 | 0.0000 | **0.003** (44) | 0.004 (71) | 0.008 (178) | 0.004 (74) | - | - |
| fullmaj | mean-field 4096 | 0.0000 | **0.003** (44) | 0.004 (71) | 0.008 (185) | 0.009 (191) | - | - |
| parity3 | standard 512 | 0.0000 | **0.002** (31) | 0.014 (323) | 0.016 (363) | 0.010 (218) | - | - |
| parity3 | standard 512, seed 1 | 0.0000 | **0.002** (31) | 0.015 (342) | 0.015 (346) | 0.013 (280) | - | - |
| parity3 | standard 4096 | 0.0000 | **0.002** (31) | 0.016 (350) | 0.009 (205) | 0.008 (180) | - | - |
| parity3 | SGD x2 512 | 0.0000 | **0.002** (31) | 0.018 (401) | 0.010 (216) | 0.010 (218) | - | - |
| parity3 | mean-field 512 | 0.0000 | **0.002** (31) | 0.016 (363) | 0.009 (207) | 0.010 (212) | - | - |
| parity3 | mean-field 512, seed 1 | 0.0000 | **0.002** (31) | 0.023 (524) | 0.010 (216) | 0.012 (261) | - | - |
| parity3 | mean-field 4096 | 0.0000 | **0.002** (31) | 0.016 (358) | 0.011 (244) | 0.012 (263) | - | - |
| junta6 | standard 512 | 0.0000 | **0.005** (98) | 0.044 (1032) | 0.140 (2252) | 0.025 (567) | - | - |
| junta6 | standard 4096 | 0.0006 | **0.006** (98) | 0.038 (852) | 0.180 (2616) | 0.026 (587) | - | - |
| junta6 | SGD x2 512 | 0.0015 | **0.007** (98) | 0.040 (880) | 0.130 (2390) | 0.031 (680) | - | - |
| junta6 | mean-field 512 | 0.0000 | **0.005** (98) | 0.037 (861) | 0.086 (2073) | 0.029 (679) | - | - |
| junta6 | mean-field 4096 | 0.0000 | **0.005** (98) | 0.045 (1051) | 0.119 (1412) | 0.045 (1043) | - | - |
| teacher4 | standard 512 | 0.0408 | 0.200 (1427) | 0.210 (1923) | 0.309 (1879) | 0.153 (1016) | **0.136** (1211) | 0.122 (1434) |
| teacher4 | standard 512, seed 1 | 0.0402 | 0.190 (1880) | 0.212 (2733) | 0.294 (1416) | 0.193 (1849) | **0.133** (1213) | 0.123 (1434) |
| teacher4 | standard 4096 | 0.0517 | 0.226 (1412) | 0.222 (2747) | 0.360 (2656) | 0.167 (1007) | **0.147** (1200) | 0.133 (1434) |
| teacher4 | SGD x2 512 | 0.0422 | 0.214 (1419) | 0.215 (2757) | 0.263 (979) | 0.154 (977) | **0.134** (1205) | 0.124 (1434) |
| teacher4 | mean-field 512 | 0.0221 | 0.200 (1847) | 0.198 (2625) | 0.279 (1972) | 0.209 (1854) | **0.113** (1214) | 0.103 (1434) |
| teacher4 | mean-field 512, seed 1 | 0.0212 | 0.171 (977) | 0.200 (2748) | 0.263 (1805) | 0.219 (1806) | **0.110** (1233) | 0.104 (1434) |
| teacher4 | mean-field 4096 | 0.0214 | 0.185 (1446) | 0.198 (2604) | 0.216 (1071) | 0.195 (973) | **0.112** (1210) | 0.103 (1434) |
| teacher8 | standard 512 | 0.0557 | 0.259 (1377) | 0.256 (2766) | 0.428 (2764) | 0.265 (2742) | **0.193** (2248) | 0.194 (2744) |
| teacher8 | standard 4096 | 0.0624 | 0.286 (1705) | 0.266 (1944) | 0.456 (2689) | 0.277 (2625) | **0.205** (2230) | 0.201 (2744) |
| teacher8 | SGD x2 512 | 0.0683 | 0.296 (1751) | 0.272 (2733) | 0.479 (3780) | 0.318 (1903) | **0.211** (1876) | 0.208 (2744) |
| teacher8 | mean-field 512 | 0.0344 | 0.264 (2673) | 0.255 (1952) | 0.346 (3467) | 0.296 (3461) | **0.166** (2259) | 0.173 (2744) |
| teacher8 | mean-field 4096 | 0.0340 | 0.267 (2680) | 0.251 (2781) | 0.361 (3507) | 0.306 (3514) | **0.166** (2252) | 0.174 (2744) |
| maj5 | standard 512 x2 layers | 0.0000 | **0.002** (41) | 0.007 (156) | 0.367 (5426) | 0.009 (187) | - | - |
| parity3 | standard 512 x2 layers | 0.0000 | **0.002** (31) | 0.013 (285) | 0.209 (4356) | 0.015 (328) | - | - |
| junta6 | standard 512 x2 layers | 0.0000 | **0.005** (98) | 0.030 (688) | 0.657 (13970) | 0.048 (1136) | - | - |
| teacher4 | standard 512 x2 layers | 0.0395 | 0.226 (2714) | 0.152 (1109) | 0.583 (5780) | 0.329 (4698) | **0.132** (1193) | 0.121 (1434) |

**What the experiments show.**
1. *Juntas and threshold functions: search is solved.* The influence codec recovers the target on every network (31–98 bits, bounds 0.002–0.007). Next come distillation from scratch on the majority targets and on the two-hidden-layer networks (0.004–0.030), and subsample- or greedy-initialized refits or distillations on the one-hidden-layer 3-parity and 6-junta networks (0.008–0.045). On all twelve of those, these beat distillation from scratch (0.014–0.045), though on the mean-field 4,096-unit 6-junta only narrowly.
2. *Subsampling works where few units carry the function.* Proposition 4's width scaling, not its bound, matches where.
   - On one-hidden-layer mean-field networks, 2 kept units reproduce the majority targets exactly and 4 the 3-parity, giving 144–244-bit descriptions and bounds 0.007–0.011.
   - On one-hidden-layer standard and SGD networks, the majorities need 16–32 units. Each unit carries 50 dense input weights, so the descriptions cost 1,200–3,300 bits and the bounds 0.07–0.30.
   - The floating-point curves show where the cost lies: 16 top units already reach 1.8% disagreement on the standard 512-unit majority network. Finding the units is cheap; describing them is not.
   - On one-hidden-layer networks, 3-parity is carried by 4–8 units in every regime (bounds 0.009–0.016), and the random 6-junta needs 16–32 in every regime (0.09–0.18).
   - On the two-hidden-layer networks, subsampling with a refit (Maurey or top-$k$, coded absolutely; greedy selection and init-relative coding were not run there) gives only 0.21–0.66 (4,356–13,970 bits). Subsampling followed by distillation still reaches 0.009–0.048 on the junta and threshold targets.
   - For mean-field networks the path norm is width-independent, as the scaling argument predicts: 5-bit majority $A=10.0$ and 9.9 at the two widths, teacher4 97.8 and 96.4. For standard networks it grows with width, but more slowly than the $\sqrt N$ of the argument: by 1.2–1.8 times from 512 to 4,096 units (for example 26.7 to 47.4 and 90.6 to 140.9), against $\sqrt8\approx2.8$.
   - The Maurey bound itself is loose. For the mean-field majority network it promises disagreement at most 0.95 at $k=4$ (the measured value is 0); for the standard network, 0.74 at $k=32$ (measured 0.12).
3. *Subsampling the update relative to the initialization* was never the best family.
4. *Dense targets: a search gap, and where it sits.*
   - Run once per network, the best search reaches 0.15–0.27, while the true teacher, a 1,434-bit (teacher4) or 2,744-bit (teacher8) description, would give 0.10–0.21. The ratio of best search to oracle is 1.24–1.92.
   - On 10 of the 13 networks, the descriptions these searches found are about as close to $f$ as the teacher is (0.8–1.1 times the teacher's disagreement; overall $\Pr[f\ne g]$ is 2.3–6.2%, against 2.2–6.9% for the teacher). On three mean-field networks they disagree with $f$ 1.5–1.9 times as often. The main difference is in the training set. There $f$ equals the labels, and the found descriptions disagree with it on 2.5–5.8% of points, against 0.5–0.7% for the quantized teacher. With the teacher's training-error count they would give 0.84–1.16 times the oracle on 12 of the 13 networks (the exception is a 2,625-bit description). So distilling toward $f$ found a $g$ close to $f$ but not close to the target, and the bound needs both.
   - Adding the training set to the distillation data (where $f$'s labels are the true labels) did not fix this on its own. The training errors stayed at 2.3–7.6%, and the best bound improved on 5 of the 13 networks, by at most 0.013.
   - The failure was optimization. Over 32 restarts at 6,000 steps, a student with the teacher's width typically ended at 4.9–6.2% training error (the median over restarts), while the best restart reached 0.9–1.9%. For the 4-unit target the outcome is bimodal: on every network, 11 of the 32 restarts ended at 0.9–1.6% training error and all others at 4.1% or more. For the 8-unit target it is graded: 3–6 restarts came within 1.1 times the oracle (estimated bound) and 22–27 within 1.5 times. The successful restarts were almost the same for every network, so success depends on the restart's random seed (the student's initialization and minibatch order) far more than on which $f$ it is distilled from. The two seed-1 teacher4 networks, whose training and distillation inputs differ, share the same successful seeds, which points to the initialization. Because every network used the same 32 seeds, these rates rest on one draw of 32 seeds per width (a 95% interval for the 4-unit success rate is 0.19–0.53).
   - With the best of 32 restarts and the five-step grid, every dense network reached 0.96–1.11 times the oracle (table, figure). Teacher8 reached 0.96–1.02. Its 8-unit students (1,880–2,260 bits) are shorter than the 2,744-bit coded teacher and at least as close to $f$, which makes up for their larger training error (1.4–2.8%, against 0.7% for the coded teacher). Teacher4 reached 1.06–1.11, closing 57–91% of the gap. Its 1,190–1,230-bit students are also at least as close to $f$ as the teacher (0.84–0.99 times its disagreement, over all 13 networks), but keep 1.3–1.8% training error, 2.1–3.4 times the coded teacher's.
   - Three controls separate what mattered (restarts table in `summary_subsample.md`):
     - *Longer training.* At the one-run budget of 2,000 steps per restart, 32 restarts reached 1.14–1.38 times the oracle on the four networks tried. The best one-run family on the same networks gave 1.25–1.79, so restarts alone helped on three of the four. The same 32 restarts at 6,000 steps, on the same three-step grid, gave 0.99–1.22.
     - *The width.* On the two standard 512-unit networks we also ran widths 2, 3, 5, 6 and 8 (teacher4) and 4, 6, 10 and 12 (teacher8). Selecting by the estimated bound picked the teacher's width on both, so the search need not be told it. Students one or two units wider succeed on almost every restart (median training error 1.3–1.4% for teacher4 at 5–6 units, against 6.0% at 4), but cost more bits: 1.21–1.31 times the oracle for teacher4 at 5–8 units and 1.08–1.12 for teacher8 at 10–12 units, on the coarse grid.
     - *The step grid.* Every teacher-width run on the coarse grid selected its finest step, so the grid was binding. Adding steps of 1/8 and 1/16 lowered teacher4 from 1.13–1.25 to 1.06–1.11 times the oracle; teacher8 was already at 0.97–1.01.
   - The floating-point disagreement after subsampling and refitting falls slowly with $k$ for every selection rule (figure). The dense target is spread over many units of $f$, as one would expect for a function that is not a junta.
5. *Compute.* Each family run once took between 9 seconds and 13 minutes per network on one CPU thread. A pass over 32 restarts took 5.4–6.7 minutes (about 11 seconds per restart). The restart family used two passes per network, or 11–12 minutes (34–44 minutes with the width sweep). Training $f$ took 2–84 seconds.

**MNIST** ([`../results/search/summary_mnist_subsample.md`](../results/search/summary_mnist_subsample.md)). For a 784-1024-10 network (test error 1.55%, $A=360$, effective units 612), with the unlabeled-data bound of the main note and a union bound over 78 configurations:
- the best surrogate is a 32-unit student distilled from scratch: 6,148 bits, $\Pr[f\ne g]=5.4\%$, bound 0.255;
- keeping the top 64 units, refitting and fine-tuning gives 11,733 bits, 3.6%, bound 0.272;
- Maurey sampling gives 0.304;
- coding the whole network gives 0.444.

The surrogates we found (6,000–12,000 bits) are too long for a tight Occam term. Whether shorter ones exist and a better search would find them is open (Section 1); restarts were not tried here.

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
- Kääriäinen (COLT 2005) bounds the randomized classifier that picks one of the classifiers of a cross-validation run, each tested on its held-out fold, and then uses unlabeled data to transfer the bound to the classifier trained on all the labelled data. This is from later accounts; the paper, on Springer, could not be opened. Kääriäinen and Langford (ICML 2005) implement this derandomization in their "semibound" package. Proposition 5 is the one-twin special case, and with a known $D_X$ its unlabeled-data requirement is free.
- The triangle inequality for the disagreement metric goes back to Schuurmans (1997), who used distances measured on unlabeled data to detect overfitting in model selection rather than to certify a bound (from later accounts; the paper could not be opened). Co-validation (Madani, Pennock, Flake 2004) uses the disagreement of two independently trained classifiers on unlabeled data, but only as a lower bound on the algorithm's expected error, not as an upper bound on one classifier's error.
- Jiang et al. (ICLR 2022) observe that two runs of the same SGD training procedure disagree on test inputs at about the test error (the generalization-disagreement equality). That suggests the bound will be about twice the test error when the twin generalizes like $f$.
- Bazinet et al. (2026) bound a trained network through a certified surrogate plus a disagreement term certified on held-out unlabeled inputs. Their tightest bounds (1.8% on an MNIST CNN, 17.4% on a CIFAR-10 ResNet-18) use a surrogate retrained on a random, data-independent subset of the training data and certified on its complement as a test set. That is Proposition 5 applied to deep networks. Their selected coresets and Pick-To-Learn surrogates do pay a sample-compression cost (3.9% on MNIST for Pick-To-Learn).

We pre-register $s=m/2$ (the same seed as $f$) and report other fractions only as diagnostics: reporting the best of several would need a union bound. For images, the test inputs used without their labels are assumed to be i.i.d. from the training input distribution, as in Theorem 2's experiments.

### Experiments

Code `code/experiments/twin_run.py`; tables in [`../results/search/summary_twin.md`](../results/search/summary_twin.md); figure [`../figures/search_twin.png`](../figures/search_twin.png). Each twin is trained on a fixed subset of $s=m/2$ training points with the same seed as $f$. In every row the compression bound is on the same $f$ (same data, seed and training). For the junta and threshold rows and the 100- and 256-unit image rows, $f$ is the main note's network, and the analysis checks this by comparing test errors. For teacher4 and the 784-1024-10 network, $f$ is this note's own network from Section 3 (teacher4's test error, 0.0395, matches the Section 3 run). Boolean rows are means over 3 seeds, except teacher4, which is seed 0, the network with search and oracle bounds (its 3-seed mean twin bound is 0.114).

| setting | test err. $f$ | compression bound (same $f$) | twin bound ($s=m/2$) | $\Pr[f\ne f_s]$ |
|---|---|---|---|---|
| Boolean, $m=16{,}000$, 5-bit majority | 0.0000 | 0.0024 | **0.0005** | 0.0000 |
| Boolean, $m=16{,}000$, 3-parity | 0.0000 | 0.0018 | **0.0005** | 0.0000 |
| Boolean, $m=16{,}000$, random 6-junta | 0.0000 | 0.0047 | **0.0016** | 0.0003 |
| Boolean, $m=16{,}000$, majority of 50 | 0.0011 | **0.0037** | 0.0108 | 0.0047 |
| Boolean, $m=16{,}000$, teacher4 (seed 0, two hidden layers) | 0.0395 | 0.132 (oracle 0.121) | **0.118** | 0.049 |
| Boolean, $m=16{,}000$, 5-bit majority, 10% label noise | 0.1390 | **0.174** | 0.230 | 0.077 |
| Boolean, $m=4000$, 3-parity | 0.0000 | **0.0070** | 0.619 | 0.297 |
| Boolean, $m=4000$, random 6-junta | 0.0223 | **0.042** | 0.336 | 0.149 |
| MNIST 784-100-10 | 0.0229 | 0.313 | **0.057** | 0.020 |
| MNIST 784-256-10 | 0.0197 | 0.368 | **0.050** | 0.019 |
| MNIST 784-1024-10 | 0.0155 | 0.255 | **0.042** | 0.015 |
| Fashion-MNIST 784-256-10 | 0.1106 | 0.619 | **0.210** | 0.084 |

- **Where the twin wins.** Once a network trained on half the data has learned the task, the twin bound is about 2–3 times the test error (1.9 on Fashion-MNIST, 2.5–2.7 on MNIST, 3.0 on teacher4). The disagreement term fits the disagreement equality of Jiang et al. (2022): $\Pr[f\ne f_s]$ is 0.76–1.24 times $f$'s test error. The rest comes from the twin's own, larger error and the confidence terms. Their equality is for two runs of one training procedure, not for a network and a twin trained on half its data, so it is a guide here, not a prediction. It beats every compression bound we have on the image networks, by a factor of 3–7. On the teacher4 network it is slightly below the true-teacher oracle (0.118 against 0.121) and the best search (0.132) without knowing the target. A twin with a different seed gives about the same: 0.052 against 0.050 for the 256-unit MNIST network.
- **Where it loses.**
  - Near the learning threshold: a twin on 2,000 examples has not learned 3-parity, while $f$ on 4,000 has.
  - When the target is short and $f$ is already close to it: on the majority of all 50 bits the twin loses at every $m$ (0.085, 0.063 and 0.011 against 0.069, 0.027 and 0.004 at $m$ = 2,000, 4,000 and 16,000). The twin's own error and its disagreement with $f$ each exceed $f$'s error, while the compressed surrogate is the 44-bit target.
  - With interpolated label noise: each network memorizes its own flipped labels, so they disagree on about 8% of inputs, while the compressed surrogate is the clean rule.
  - So the two bounds are complementary.
- **Other fractions** ($s=m/4$, $3m/4$; diagnostics only, not used for any reported bound) trade the twin's accuracy against the size of its test set. $3m/4$ is better for every image network it was run on (MNIST with 100 and 256 units, Fashion-MNIST; the 1024-unit network was run at $m/2$ only) and for 16 of the 22 Boolean settings.

## 5. Is closeness true in practice?

What Theorem 2 needs is a *short* $g$ with few training errors and $\Pr[f\ne g]$ not much larger than $\mathrm{err}(f)$. The evidence:
- *Tasks with a short target.* Closeness to the target holds by definition, $\Pr[f\ne t]=\mathrm{err}(f)$ (Proposition 2), so the only questions are whether the target is short relative to $m$ and whether it can be found. On the junta and threshold-function tasks it is (31–98 bits), and the target was found in polynomial time on every network.
- *Dense targets.* $f$ (2–7% test error) is within its test error of a 1,434- or 2,744-bit description (the teacher), so closeness holds. At $m=16{,}000$ that description is not short: its Occam term alone (0.08 or 0.14) makes even the oracle bound 2.6–5 times the test error. Single-run searches found descriptions about as close to $f$ as the teacher (on 10 of 13 networks), but less accurate on the training set. With restarts, longer training and a finer step grid, the search found descriptions at least as close to $f$ as the teacher and about as good for the bound (0.96–1.11 times the oracle).
- *MNIST.* $f$ agrees with 6,000–12,000-bit surrogates up to 3.6–5.4%, and those certify only 0.255. It agrees with a retrained twin up to 1.5–2%, about its own error, but the twin is an 800,000-parameter network, not a short $g$ for Theorem 2. Whether a program short enough for a tight Occam term exists at 1–2% disagreement is open. Section 1 gives the arithmetic, and the tiny networks reported there suggest it may.
- *Literature.*
  - Networks pruned during training reach top-1 accuracy close to that of dense networks (ResNet-50 on ImageNet: 75.9% at 50% sparsity and 72.6% at 90%, against 76.7%). The differences concentrate on a small set of inputs, often multi-object, fine-grained or mislabeled, on which the most common prediction of 30 pruned networks differs from that of 30 dense ones (Hooker et al. 2019, "pruning identified exemplars": 3.6–10.3% of ImageNet test images at 30–90% sparsity). The pruned and dense networks are trained independently, and the paper does not report how often a single pruned network disagrees with a single dense one.
  - Distilled students, by contrast, can disagree substantially with their teachers even when they could match them exactly. The gap is often an optimization failure rather than a capacity limit (Stanton et al. 2021), as in our dense-target runs.
  - Two runs of the same SGD training procedure, with different seeds or on disjoint halves of the data, disagree on test inputs at about their test error, a little below it when they share the data (Jiang et al. 2022, ResNets and CNNs on CIFAR-10/100 and SVHN). For fully connected networks on all of MNIST, the setting closest to ours, they find a larger gap, with disagreement mostly below test error.
  - So closeness at about the level of $f$'s own error is typical for networks retrained on the same data, and held for the twins measured here once they had learned the task. For pruned networks the evidence is only at the level of populations. For distilled students it depends on the optimization. Closeness to a *short* program is a property of the task and of how much search one can afford.

## 6. What this suggests

1. **With a known input distribution or unlabeled data, try the twin first.** It costs one retraining, needs no search, and was 3–7 times tighter than compression on every image network. Compression helps near the learning threshold, when the target is short and $f$ is already close to it (majority of 50), with interpolated noise, or when the training algorithm is not available.
2. **Use structure-aware search, and give it restarts.** Influence estimation is provably polynomial for juntas and found every junta target here. Fourier methods such as Kushilevitz–Mansour are provably polynomial, with queries and uniform inputs, when the spectrum is concentrated on polynomially many coefficients, but we did not run them. For dense targets, distilling into a small student is the right search, but a single run is not enough: for the 4-unit target two thirds of small-student initializations got stuck. Restarts, longer training and a fine enough quantization grid together brought every dense network to within 11% of the oracle. When only one run is affordable, starting the student from subsampled or greedily selected units of $f$ helped on the four standard-parametrization one-hidden-layer teacher4 networks (0.153–0.193, against 0.210–0.222 from scratch), but not on the teacher8 networks, and on the mean-field teacher4 networks only once, narrowly (0.195 against 0.198 on the 4,096-unit one). The reason to search inside the network is that finding a good new unit is hard in general: for threshold and ReLU units, finding the best new unit is NP-hard, even to within a constant factor (Bach, "Breaking the curse of dimensionality with convex neural networks", JMLR 2017). Training has already produced candidate units, though nothing guarantees they are the best ones; that reading is ours, not Bach's.
3. **Mean-field training made plain subsampling work, but did not make $f$ more compressible.** With a refit alone, mean-field networks compressed to 2 units on the majority targets (bound 0.007–0.008), where standard ones needed 16–32 units (0.07–0.30). The best certified bound, set by the influence codec, was 0.002–0.007 on the junta and threshold targets in every regime. Subsampling and then distilling gave 0.006–0.024 on standard majority networks too. On the dense targets, mean-field networks had about half the test error, and their best bounds were lower by about as much as their oracle bounds (after restarts, 0.110–0.113 against 0.133–0.147 for the one-hidden-layer standard and SGD networks on teacher4; relative to the oracle, 1.06–1.09 against 1.08–1.11): that reflects $f$'s accuracy, not its compressibility. The regimes also differ in optimizer (plain SGD at learning rate $0.2N$ against Adam), and most have one seed. Whether training for compressibility helps a compression bound is therefore open, as is whether it extends to deep or convolutional networks.
4. **The dense teacher targets are a useful benchmark** for search: a known short description, networks that learn it, and a measurable gap. Restarts, longer training and a finer step grid brought it to 0.96–1.11. Natural next steps:
   - a final fine-tuning of the best restarts on the training set, aimed at the 4-unit students' residual 1.3–1.8% training error;
   - harder versions (wider or deeper teachers, larger $n$), to see how the success rate per restart falls and how the needed compute grows;
   - progressive distillation from intermediate checkpoints, which provably helps on sparse parities (Panigrahi et al. 2025);
   - white-box distillation that fits linear probes on $f$'s hidden activations to find candidate features and builds a small model from them. Boix-Adsera (2024) proves this runs in polynomial time for networks that compute a small decision tree whose path conjunctions are linear in those activations, so the dense targets would need a different feature class;
   - ridge-leverage-score unit sampling with a regularized least-squares refit of the output layer. Bach ("On the equivalence between kernel quadrature rules and random feature expansions", JMLR 2017, Proposition 2) shows that about $5d(\lambda)\log(16d(\lambda)/\delta)$ units drawn from the leverage-score distribution approximate every function of kernel norm at most 1 to squared $L_2(D_X)$ error $4\lambda$, where $d(\lambda)$ is the effective dimension of the units' covariance under $D_X$. In our setting (our derivation, not Bach's), weighting unit $i$ by $s_i/A$ makes $f$'s kernel norm at most $A$, so disagreement $\epsilon$ beyond the margin term needs $\lambda\approx\epsilon\gamma^2/(4A^2)$, and $d(\lambda)\le4A^2/(\epsilon\gamma^2)$. The count is never much worse than Maurey's $A^2/(\epsilon\gamma^2)$, and much smaller when the covariance's eigenvalues decay fast.
5. **Open theory.**
   - Is the white-box search problem (find $g$ with $L(g)\le K_\epsilon(f)+s$) hard for networks that gradient descent produces?
   - Is there a family of tasks where $f$ is learnable and its target short, but no polynomial-time procedure finds a short surrogate? The restart results suggest looking where small students' basins of attraction are exponentially rare.
   - The twin bound sidesteps both questions by measuring description length relative to the training algorithm itself.

## Verification

- *Theory.* The propositions and the subsampling code were checked by three independent AI referees (Propositions 1–2, Proposition 3, Propositions 4–5 with the code), each claimed defect then going to an independent adjudicator. The record is in [`verification_theory.json`](verification_theory.json).
  - Real defects found and fixed include: a missing output-bias shift in the update version of Proposition 4; a factor of 2 (not 4) in the multi-class corollary; the exact conditions under which Proposition 1's "validity is free" holds; the quantifiers and citations of Proposition 3; the junta-search condition $\epsilon<2^{-k-1}$; and an overstated MNIST paragraph.
  - No error was found in the main identities, and the code was confirmed to implement them. Monte Carlo tests of the identities are in `code/tests/test_subsample.py`.
- *The report.* Before publication, three AI reviewers checked the draft against the raw results: the numbers in the short answers and Sections 1–2, the numbers in the experiments, and a skeptical referee reading of the claims, the comparisons and the credit to prior work. Each of their 42 findings went to an independent verifier, which confirmed 37 and rejected 5. The record is in [`verification_review.json`](verification_review.json).
  - All 37 were fixed. Among them: ranges that covered only part of the rows they described (the twin's Boolean results, the one- versus two-hidden-layer networks, the codec's run time); the diagnosis of the dense-target gap, which is in the training error, not in the disagreement; Bazinet et al.'s tightest bound, which is a twin-type bound and had been listed as sample compression; the search-family charge, now 4 bits and $\delta_2/16$ for every family including the codec; a misstated result of Ye et al.; and a recommendation to train for compressibility that the data do not support.
  - The restart experiment, the fresh-plus-training-input distillation and the revised accounting came after this review.
- *A second review* of the revised report used the same design. Its three reviewers made 22 findings, and the verifiers confirmed 8 and rejected 14, most of these because the fix was already in the working copy when they checked. The record is in [`verification_recheck.json`](verification_recheck.json). Its main points: the restart claims were overstated for the 4-unit target; the restarts had three times the per-run training budget of the single-run searches; the students were given the teacher's width; and the quantization grid was binding. The last three led to the control runs in Section 3. Those runs and the final numbers were checked by the analysis script and by us, not by a further review.
- *Literature.* The first sweep (five topic searches plus one on prior art for the twin bound, each with a verification pass) is in [`literature_sweep.json`](literature_sweep.json). It could open almost no paper, so it rested on search-result snippets and official code repositories.
- *Citations.* After arXiv, OpenReview and PMLR were allowed, ten checkers each took a group of cited works and checked every sentence citing them against the paper itself, in this note, in the project README and in the paper's discussion. Each problem found went to an independent verifier. Of 75 cited claims, 38 were confirmed as written; 22 problems were confirmed and fixed and 5 were rejected; 10 could not be checked against the paper itself and are marked in the text. The record, with the passages quoted from each source, is in [`verification_citations.json`](verification_citations.json).
  - The corrections that matter most: Safran and Shamir find spurious minima only from 6 units up, so their result is similar to ours, not the same; Hooker et al. compare independently trained populations, not a network with its pruned copy; Jiang et al.'s equality concerns two runs of one procedure, so it guides the twin bound rather than predicting it; Levin search is not a speed-up over brute force; and the smallest networks reported at 99% on MNIST have 697 and 1,936 parameters, not about 2,000, which bears on whether a short MNIST program exists.

## Files and reproduction

- `code/cgb/subsample.py`: Maurey, top-$k$, uniform and greedy unit selection, least-squares refit, update and two-layer variants.
- `code/experiments/subsample_run.py`: the Boolean search study (one network per call). It saves $f$ to `$CGB_NETS`, default `~/.cache/cgb_nets`. With `--load_saved` and `--families greedy` or `--families mixed` it adds the greedy or the fresh-plus-training-input families on a saved network.
- `code/experiments/restarts_run.py`: the random-restart search on a saved network (`--k` width, `--steps` training steps, `--rels` step grid).
- `code/experiments/oracle_teacher.py`: the true-teacher reference.
- `code/experiments/mnist_subsample.py`: the MNIST surrogates.
- `code/experiments/twin_run.py`: the twin bound.
- `code/experiments/analyze_search.py`: summaries and figures, with the final accounting (it recomputes every family's bound from the raw counts).
- `code/tests/test_subsample.py`: Monte Carlo tests of the Maurey identities and the top-$k$ guarantee.
- Results: `results/search/*.jsonl` and `summary_*.md`. Figures: `figures/search_curves.png`, `figures/search_restarts.png`, `figures/search_twin.png`.
- Command lines (from `code/experiments/`):
  - For each task in {maj5, fullmaj, parity3, junta6, teacher4, teacher8} and network in {std 512, std 4096, mf 512, mf 4096, lazy 512}: `python3 subsample_run.py --task T --param P --width N --out ../../results/search/subsample.jsonl`, then the same with `--families greedy --load_saved --out ../../results/search/subsample_greedy.jsonl`. Second seeds and two-hidden-layer networks take `--seed 1` and `--depth 2`.
  - For the dense targets, also `--families mixed --load_saved --out ../../results/search/subsample_mixed.jsonl`, and `python3 restarts_run.py --task T --param P --width N [--seed S] [--depth D] --k K --out ../../results/search/restarts.jsonl` with $K=4$ for teacher4 and 8 for teacher8, once with the default step grid and once with `--rels 0.25,0.125,0.0625`. The width sweep adds $K\in\{2,3,5,6,8\}$ (teacher4) and $\{4,6,10,12\}$ (teacher8) on the standard 512-unit networks. The diagnostic runs use `--steps 2000 --qat_steps 400 --out ../../results/search/restarts_steps2000.jsonl`.
  - `python3 oracle_teacher.py` for the oracle column.
  - `twin_run.py boolean --task T --m M --seed S [--noise 0.1]` uses the main grid's tasks, $m\in\{2000,4000,16000\}$ and seeds 0–2. `twin_run.py images --data D --hidden H` and `mnist_subsample.py --hidden 1024` cover the images.
  - `python3 analyze_search.py` regenerates the summaries and figures.
- Everything ran on 4 CPU cores in about eight hours.

## References

Checked against the paper itself unless marked "not opened", in which case against later papers that restate the result ([`verification_citations.json`](verification_citations.json)).

- Bach, F. (2017). Breaking the curse of dimensionality with convex neural networks. *JMLR* 18(19):1–53. arXiv:1412.8690.
- Bach, F. (2017). On the equivalence between kernel quadrature rules and random feature expansions. *JMLR* 18(21):1–38. arXiv:1502.06800.
- Baykal, C., Liebenwein, L., Gilitschenski, I., Feldman, D., Rus, D. (2019). Data-dependent coresets for compressing neural networks with applications to generalization bounds. *ICLR 2019*. arXiv:1804.05345.
- Bazinet, M., Zantedeschi, V., Germain, P. (2026). Bound to Disagree: generalization bounds via certifiable surrogates. *UAI 2026*, PMLR 337:491–520. arXiv:2602.23128.
- Blanc, G., Lange, J., Qiao, M., Tan, L.-Y. (2021). Properly learning decision trees in almost polynomial time. *FOCS 2021*; *JACM* 69(6), 2022. arXiv:2109.00637.
- Boix-Adserà, E. (2024). Towards a theory of model distillation. arXiv:2403.09053.
- Goldreich, O., Goldwasser, S., Micali, S. (1986). How to construct random functions. *JACM* 33(4):792–807.
- Gopalan, P., Kalai, A. T., Klivans, A. R. (2008). Agnostically learning decision trees. *STOC 2008*, 527–536.
- Håstad, J., Impagliazzo, R., Levin, L. A., Luby, M. (1999). A pseudorandom generator from any one-way function. *SIAM J. Comput.* 28(4):1364–1396.
- Hirahara, S. (2022). NP-hardness of learning programs and partial MCSP. *FOCS 2022*, 968–979. ECCC TR22-119. Not opened.
- Hirahara, S., Ilango, R., Williams, R. R. (2024). Beating brute force for compression problems. *STOC 2024*, 659–670. ECCC TR23-171. Not opened.
- Hooker, S., Courville, A., Clark, G., Dauphin, Y., Frome, A. (2019). What do compressed deep neural networks forget? arXiv:1911.05248 (v3, 2021).
- Jiang, Y., Nagarajan, V., Baek, C., Kolter, J. Z. (2022). Assessing generalization of SGD via disagreement. *ICLR 2022*. arXiv:2106.13799.
- Kääriäinen, M. (2005). Generalization error bounds using unlabeled data. *COLT 2005*, LNCS 3559:127–142. Not opened.
- Kääriäinen, M., Langford, J. (2005). A comparison of tight generalization error bounds. *ICML 2005*, 409–416. Abstract only.
- Kharitonov, M. (1993). Cryptographic hardness of distribution-specific learning. *STOC 1993*, 372–381. Not opened.
- Koch, C., Strassle, C., Tan, L.-Y. (2023). Properly learning decision trees with queries is NP-hard. *FOCS 2023*. arXiv:2307.04093.
- Kushilevitz, E., Mansour, Y. (1993). Learning decision trees using the Fourier spectrum. *SIAM J. Comput.* 22(6):1331–1348. Not opened.
- Levin, L. A. (1973). Universal sequential search problems. *Problems of Information Transmission* 9(3):265–266. Not opened.
- Levin, L. A. (1984). Randomness conservation inequalities; information and independence in mathematical theories. *Information and Control* 61(1):15–37.
- Littlestone, N., Warmuth, M. K. (1986). Relating data compression and learnability. Technical report, University of California, Santa Cruz.
- Lotfi, S., Finzi, M., Kapoor, S., Potapczynski, A., Goldblum, M., Wilson, A. G. (2022). PAC-Bayes compression bounds so tight that they can explain generalization. *NeurIPS 2022*. arXiv:2211.13609.
- Madani, O., Pennock, D. M., Flake, G. W. (2004). Co-validation: using model disagreement on unlabeled data to validate classification algorithms. *NIPS 2004*. Partial text only.
- Mussay, B., Osadchy, M., Braverman, V., Zhou, S., Feldman, D. (2020). Data-independent neural pruning via coresets. *ICLR 2020*. arXiv:1907.04018.
- Panigrahi, A., Liu, B., Malladi, S., Risteski, A., Goel, S. (2025). Progressive distillation induces an implicit curriculum. *ICLR 2025*. arXiv:2410.05464.
- Safran, I., Shamir, O. (2018). Spurious local minima are common in two-layer ReLU neural networks. *ICML 2018*, PMLR 80:4433–4441. arXiv:1712.08968.
- Schuurmans, D. (1997). A new metric-based approach to model selection. *AAAI-97*, 552–558. Not opened.
- Shevchenko, A., Mondelli, M. (2020). Landscape connectivity and dropout stability of SGD solutions for over-parameterized neural networks. *ICML 2020*, PMLR 119:8773–8784. arXiv:1912.10095.
- Stanton, S., Izmailov, P., Kirichenko, P., Alemi, A. A., Wilson, A. G. (2021). Does knowledge distillation really work? *NeurIPS 2021*. arXiv:2106.05945.
- Valiant, L. G. (1984). A theory of the learnable. *Communications of the ACM* 27(11):1134–1142.
- Ye, M., Gong, C., Nie, L., Zhou, D., Klivans, A., Liu, Q. (2020). Good subnetworks provably exist: pruning via greedy forward selection. *ICML 2020*, PMLR 119:10820–10830. arXiv:2003.01794.
- GitHub records (not peer reviewed): ruslangrimov/mnist-minimal-model (2018, 1,936 parameters); JoshWarn/Parameter-Efficient-MNIST (2023, 697 parameters).
