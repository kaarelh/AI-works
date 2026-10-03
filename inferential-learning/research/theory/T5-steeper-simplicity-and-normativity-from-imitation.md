# T5. Steeper simplicity and normativity from imitation

*Theory thread T5 of the inferential-learning project. Read `../00-brief.md` first. The thread develops the user's own proposal from `philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md`, especially its "messy notes": function induction with private per-input randomness, loss $\lambda K(h)+\sum_i \mathrm{NLL}_i$ with $\lambda>1$ growing with $N$, his worked example, and his convex-hull argument. It builds on T1 (`T1-soundness-under-search.md`) and T2 (`T2-coherence-as-negative-data.md`) and cites their theorem numbers. Scripts are in `theory/T5-checks/` (c1–c5).*

**Status tags.**
* **[proved]**: full proof here.
* **[sketch]**: argument given, some steps not written out.
* **[known]**: standard or published result. Marked **(unverified)** where I am working from memory or from search-engine snippets. Paper fetching was blocked in this session; only search snippets were available.
* **[computed]**: checked by script.
* **TOSU** means "trivial once set up": the content is in the formulation.

---

## 0. Summary

The user's question: can imitation of a fallible teacher yield the teacher's *norms* (what they are trying to teach) rather than the teacher's systematic errors? His proposal is to penalize hypothesis length more steeply than likelihood, in *function* induction where each input gets its own private randomness. His hope is that this avoids the pathology of sequence induction, where a universal hypothesis absorbs everything.

Answers, compressed.

1. **His "universal hypothesis" question has a clean answer: yes, private randomness kills it, and it comes back exactly when inputs contain other labelled examples.**
   * With private randomness, any single hypothesis pays a mixture's $\log(1/w)$ **per input**. Its minimax regret against a rich class $F$ of labelers (e.g. parities) is $\sum_i\log|F(x_i)|$, which is linear in $N$, against $\log|F|$ once for a shared-randomness mixture (Thm 2.1, Prop 2.2).
   * The sequence pathology is exact: the universal semimeasure beats every $\nu$ of complexity above $O(1)/(\lambda-1)$ (Prop 2.3).
   * *Kink theorem* (Thm 2.5). For a parity "simple model" with a random error set, take shared-randomness (set/mixture) models. Their total code length is **flat** in model complexity, which is the user's "1 bit pays for 1 bit". So every $\lambda>1$ selects the zero-knowledge class mixture.
   * Product (private-randomness) models instead stay at $\ge 1-O(2^{-t}+p)$ bits/sample until the full $d$ bits of the simple model are paid. That is the kink he hoped for. The proof uses Fourier list-decoding plus the coding theorem.
   * **But** if a hypothesis's input contains earlier labelled steps by the same human (a proof document, an LLM context), the function hypothesis can be an in-context Bayes mixture. It then pays $\log(1/w)$ **per block**, not per input (Prop 2.6).
   * A single $O(1)$-bit "copy this human's earlier errors" hypothesis then learns idiosyncratic errors that no component-wise analysis would admit [computed: c5].
2. **Rate thresholds and the convex hull.**
   * Lemma 3.1: as $c=\lambda/N$ varies, the minimizers of $c\,\ell(h)+R(h)$ trace the lower convex hull of achievable (description length, risk) points. A hypothesis is the unique minimizer on an open $c$-interval iff it is a hull *vertex*. This confirms his convex-hull reasoning and his "point where the derivative changes".
   * For separable components (disjoint input regions), component $j$ is selected iff its **rate** $r_j/k_j$ exceeds $c$ (Thm 3.2).
   * An idealized Kolmogorov-complexity version is proved with explicit $O(\log)$ slack, with *arbitrary* hypotheses allowed, for independent parity components (Thm 3.3).
   * Every convex piecewise-linear hull shape is realizable (Cor 3.4), the analogue of Vereshchagin–Vitányi's "all shapes" theorem.
   * His worked example is verified. In the rigorous parity version (Thm 3.5) the good model is selected for $c\in(\approx 1/n,\ \approx(1-H(p))/d)$. With his numbers the window is $c\in(1.12\cdot10^{-6},\,8.99\cdot10^{-3})$, a factor of about 8000 [computed: c1, c2].
3. **Pathologies (each proved).**
   * (a) *Rate blindness.* Selection depends only on the teacher's channel, so a valid component with rate at most that of an error component cannot be kept without the error (Thm 4.1).
   * (b) Cheap frequent fallacies (affirming the consequent, the freshman's dream) have rates comparable to genuine rules. In a toy calculus, affirming the consequent outranks proof-by-cases, reductio and ex falso (Prop 4.2).
   * (c) The good window is **not identifiable from imitation data**. Held-out log-loss, and every strictly proper score, prefers the teacher's own channel, errors included. So cross-validation, and in the same way the learning-rate selection of SafeBayes, picks the error-memorizing end (Thm 4.3).
   * (d) Further pathologies:
     * *guard erosion*: steeper simplicity deletes rarely exercised but valid side conditions, which makes the learner **less sound than the teacher** (Prop 4.4);
     * coarse *error envelopes* are learned at their own (high) rate (Prop 4.5);
     * *parasitic* errors that are cheap given a valid rule (non-additivity);
     * dependence of rates on the reference language and on the input distribution;
     * in-context universality (Prop 2.6).
4. **Inference rules and the division of labour.**
   * In situation-typed step imitation, rule selection is again a rate threshold.
   * Coherence (T2) and world feedback act as down-closed feasibility constraints. Under *error-independence* and *valid dominance* (Thm 5.2):
     * the surviving errors are exactly those with rate $>c$ that are coherent with, and empirically adequate relative to, the **valid rules the learner actually kept**;
     * the lost valid rules are exactly those with rate $\le c$.
   * So simplicity removes low-rate (expensive or idiosyncratic) errors; coherence removes incoherent ones regardless of rate; world feedback removes refutable ones. The residue is the cheap, frequent, coherent, empirically adequate alternatives, i.e. T2 Thm 6.4's alternative meanings *that humans actually use*.
   * Without valid dominance, the optimizer repairs incoherence by **sacrificing the valid rule that exposes the fallacy** (Prop 5.3) [computed: c4].
   * Meaning postulates ("1+1=2 won't be true if you assign 1→rabbit, 2→chicken") are rate-independent feasibility constraints from a second channel: *avowal* rather than *performance*. They are what rescue the cheap-fallacy case (Prop 5.4).
5. **Verdict in his terms.**
   * He is right about the function case and about the convex hull.
   * The steeper penalty is a bet that **norms are high-rate structure and errors are low-rate structure**. That bet is true for idiosyncratic slips and false for exactly the interesting errors: cheap, systematic fallacies. It also costs rare valid rules and guards.
   * "What is this person trying to teach me" needs information that is not a function of the teacher's behaviour channel $P^*$. Coherence, world feedback and avowed properties of the notion supply it.
   * Steeper simplicity is a good *third* filter. It is not a route to normativity on its own.

---

## 1. Setting

### 1.1 Teacher, norm, errors

* Inputs $x\in X$ are drawn from $D$; labels $y\in Y$, a finite set. The teacher's behaviour is a channel $P^*(y\mid x)$.
* The user's picture is that $P^*$ arises from an intended **norm** $h^\circ$ (what the teacher means) by:
  * *sporadic noise*, i.i.d. slips, and
  * *systematic error*, a structured deviation $E$ on some region.
* Imitation data are $(x_i,y_i)_{i\le N}$, i.i.d. from $D\times P^*$.
* **Normativity** is the requirement that the learner output $h^\circ$, or its deterministic core, rather than $P^*$.

### 1.2 Private vs shared randomness

**Definition 1.1.**
* A **function hypothesis with private randomness** (a *product model*) is a conditional distribution $h(\cdot\mid x)$. Its likelihood on data is $\prod_i h(y_i\mid x_i)$: each input draws its own random bits.
* A **shared-randomness hypothesis** is a distribution $P(y_{1:N}\mid x_{1:N})$ on label sequences. Equivalently, it is a program that reads one random tape across all inputs, as in sequence-Solomonoff on the interleaving $x_1y_1x_2y_2\dots$.
* A **block model** sits between the two. Data come in blocks, such as documents or proofs by one human. The hypothesis's input at position $i$ of a block includes the block's earlier pairs, so randomness is shared within a block and private across blocks.

### 1.3 Objectives

* **The user's loss** is $\mathcal L_\lambda(h)=\lambda\,\ell(h)+\sum_{i\le N}-\log_2 h(y_i\mid x_i)$, with $\lambda>1$ growing with $N$.
  * Write $\lambda=cN$. Dividing by $N$ gives the per-sample objective
  $$\hat J_c(h)=c\,\ell(h)+\hat R_N(h),\qquad J_c(h)=c\,\ell(h)+R(h),\qquad R(h)=\mathbb E_{x\sim D}\mathbb E_{y\sim P^*(\cdot|x)}[-\log_2h(y\mid x)].$$
  * Set $\Phi(c)=\inf_hJ_c(h)$. Here $R$ is in bits per sample and $c$ is in "bits per sample per bit of description".
* **Two versions.**
  * *(Idealized)* $\ell(h)=K(h)$, the prefix complexity of a program computing $h$. Hypotheses are total programs with rational outputs.
  * *(Computable)* $\ell$ is a prefix code on a countable class $\mathcal H$, with $\sum_h2^{-\ell(h)}\le1$. Examples are rule calculi with an MDL code, or finite hypothesis lists.
* **Rates.** If adding a "component" to a hypothesis costs $k$ bits and lowers $R$ by $r$, its **rate** is $r/k$. Rates are what $c$ is compared against.

**Lemma 1.2 (empirical selection tracks population selection) [proved].** Suppose every $h\in\mathcal H$ has a noise floor $h(y\mid x)\ge2^{-B}$, so losses lie in $[0,B]$. Then with probability $\ge1-\delta$, simultaneously for all $h$:
$$|\hat R_N(h)-R(h)|\le \varepsilon_N(h):=B\sqrt{\big(\ell(h)\ln2+\ln(2/\delta)\big)/(2N)}.$$
Let $\hat h$ minimize $\hat J_c$, and let $h_0$ be any fixed hypothesis. Then
$$J_c(\hat h)\le\Phi(c)+2B\sqrt{\big((\ell(h_0)+B/c)\ln 2+\ln(2/\delta)\big)/(2N)}.$$
If the population minimizer is unique with gap $\gamma>0$, then $\hat h$ equals it once the right-hand bound is below $\gamma$.

*Proof.*
* Apply Hoeffding to each $h$ with confidence $\delta2^{-\ell(h)}$, and take a union bound using Kraft.
* Next, $c\ell(\hat h)\le\hat J_c(\hat h)\le\hat J_c(h_0)\le c\ell(h_0)+B$. So $\ell(\hat h)\le\ell(h_0)+B/c$, and also $\ell(h_c)\le\ell(h_0)+B/c$ for a population minimizer $h_c$.
* Then $J_c(\hat h)\le\hat J_c(\hat h)+\varepsilon(\hat h)\le\hat J_c(h_c)+\varepsilon(\hat h)\le\Phi(c)+\varepsilon(h_c)+\varepsilon(\hat h)$. ∎

So with $\lambda=cN$ (his scaling), the selected hypothesis converges to the population $c$-optimum. **This corrects L11 Prop 2.2's gloss.** L11 says the steeper coefficient separates intended rules from errors "only on a finite-sample window". That is right for *fixed* $\lambda$: then $c\to0$ and every positive-rate component, error or not, is eventually absorbed. For $\lambda\propto N$ the selection is asymptotically stable. **The obstruction is rate inversion, not sample size** (§4).

### 1.4 Relation to the literature

* **Kolmogorov's structure function and algorithmic statistics.**
  * For a string $x$, the structure function is $h_x(\alpha)=\min\{\log|S|:x\in S,K(S)\le\alpha\}$ (Kolmogorov 1974, unpublished talk). The MDL function is $\lambda_x(\alpha)=\min\{K(S)+\log|S|:x\in S,K(S)\le\alpha\}$, and there is a best-fit (randomness-deficiency) function $\beta_x$.
  * Vereshchagin & Vitányi (2004, *IEEE Trans. IT* 50(12):3265–3290) [known] show that, to logarithmic precision, $h_x(\alpha)\ge K(x)-\alpha$ (the *sufficiency line*). They also show that $\beta_x(\alpha)=h_x(\alpha)+\alpha-K(x)$, so the structure function determines the best-fit function (exact form from memory, (u)).
  * Per the search snippet, structure functions and minimal-deficiency functions "can assume all shapes over their full domain". The realizable shapes are, to logarithmic precision, the non-increasing curves that decrease at slope at most $-1$ (i.e. $h_x(\alpha)+\alpha$ non-increasing) and lie in the triangle below the diagonal. I could not read the paper itself, so the exact list of side conditions is **(unverified)**.
  * The slope property is easy: split an optimal $S$ into $2^\delta$ equal halves-of-halves. This gives $h_x(\alpha+\delta)\le h_x(\alpha)-\delta+O(\log)$.
  * Probabilistic models give the same function as finite-set models up to $O(\log n)$. This is due to Gács, Tromp & Vitányi (2001, *IEEE Trans. IT* 47(6)) and to Vereshchagin–Vitányi's work on probability models **(unverified exact statement)**.
  * Our object differs in one way that turns out to be the whole point. Models are **product** distributions $\prod_xh(\cdot\mid x)$, because private randomness is per input. The *product-model structure function*
  $$\rho^{\times}(k)=\min\{R(h):\ell(h)\le k\}$$
  lacks the slope property and can have genuine kinks (Thm 2.5). Set models are shared-randomness models. **The user's insight, in this language, is that restricting to product models turns the structure function's slope-$(-1)$ line into a curve with a kink at the simple model.**
* **$\lambda$ and sufficiency.** At $\lambda=1$ the two-part code $K(S)+\log|S|$ is indifferent, up to log terms, along the sufficiency line: all algorithmic sufficient statistics tie. Any $\lambda>1$ breaks the tie toward lower complexity. So $\lambda=1+\epsilon$ selects approximately the *minimal* sufficient statistic [sketch; log-precision caveats].
  * Larger $\lambda$ selects *insufficient* models, which leave structure in the residual. This is exactly what the user wants: the "good model" is deliberately not a sufficient statistic for the teacher's data, since the errors are structure.
  * Vereshchagin & Vitányi (2010, "Rate distortion and denoising of individual data using Kolmogorov complexity", *IEEE Trans. IT* 56(7):3438–3454) [known] study the rate–distortion analogue and denoising of individual data. The Lagrangian $c\ell+R$ is the algorithmic rate–distortion Lagrangian with log-loss distortion.
* **MDL and two-part codes.**
  * Rissanen (1978); Barron & Cover (1991, "Minimum complexity density estimation", *IEEE Trans. IT* 37(4)). They introduced the index of resolvability and analysed minimum-complexity estimators $\arg\min_q\{L(q)-\log q(X^n)\}$. Whether, and in which theorems, they use a multiplier $\lambda\ge1$ on $L(q)$ is **(unverified)**.
  * Grünwald, *The Minimum Description Length Principle* (MIT Press 2007).
* **Tempered / generalized / fractional posteriors = steeper simplicity.**
  * The generalized posterior is $\pi_\eta(h)\propto w(h)\prod_ih(y_i\mid x_i)^\eta$. Its MAP minimizes $-\log w(h)+\eta N\hat R_N(h)$, i.e. $\frac1\eta\ell(h)+N\hat R_N$. **So $\lambda=1/\eta$: the user's $\lambda>1$ is exactly a learning rate $\eta<1$.**
  * With $\lambda=cN$, $\eta=1/(cN)\to0$, and the generalized posterior tends to the **fixed Gibbs measure** $\propto2^{-(\ell(h)+R(h)/c)}$, which does not concentrate. In PAC-Bayes language (Catoni 2007, *PAC-Bayesian Supervised Classification*) it is a Gibbs posterior at a constant inverse temperature $\ln2/c$.
  * Relevant work:
    * Zhang (2006, *Ann. Statist.* 34(5), "From ε-entropy to KL-entropy") on information-complexity estimators with $\eta<1$ **(unverified details)**;
    * Bhattacharya, Pati & Yang (2019, *Ann. Statist.* 47(1), "Bayesian fractional posteriors") **(unverified)**;
    * Bissiri, Holmes & Walker (2016, *JRSS-B*) on loss-scale calibration;
    * Grünwald's **SafeBayes**: Grünwald (2012, ALT, "The safe Bayesian: learning the learning rate via the mixability gap") and Grünwald & van Ommen (2017, *Bayesian Analysis* 12(4)) [known, confirmed via search].
  * SafeBayes learns $\eta$ from data, by minimizing a sequential (randomized) log-loss, in order to repair *misspecification*. Thm 4.3 shows why this cannot find the user's $\eta$. The imitation model is *well specified for the teacher*, and every data-driven proper-score criterion targets $P^*$, errors included. The user wants a deliberately "wrong" $\eta$, and its justification cannot come from the data.

---

## 2. The universal-hypothesis question

### 2.1 Per-input versus once-only pricing

Let $F$ be a finite class of deterministic labelers, and $x_1..x_N$ any inputs (repeats allowed). Write $F(x)=\{f(x):f\in F\}$.

**Theorem 2.1 (no adaptation with private randomness) [proved].**
* **(i)** For every product hypothesis $h$ and every distribution $Q$ on $F$:
$$\max_{f\in F}\sum_i-\log h(f(x_i)\mid x_i)\ \ge\ \sum_iH(Q_{x_i}),$$
where $Q_{x}$ is the law of $f(x)$ under $f\sim Q$. The hypothesis $h(\cdot\mid x)=\mathrm{Unif}(F(x))$ attains $\sum_i\log|F(x_i)|$ against every $f$. If some $Q$ has uniform marginals on every $F(x_i)$, the minimax regret is exactly $\sum_i\log|F(x_i)|$. This holds for parities, and for any class invariant under a group acting transitively on each $F(x)$.
* **(ii)** For shared-randomness models, $\min_P\max_f-\log P(f(x_{1:N}))=\log|\{f(x_{1:N}):f\in F\}|\le\log|F|$ (Shtarkov 1987 [known]).

*Proof.*
* (i) $\max_f\ge\mathbb E_{f\sim Q}$. Also $\mathbb E_{f\sim Q}[-\log h(f(x)\mid x)]=H(Q_x)+\mathrm{KL}(Q_x\|h(\cdot|x))\ge H(Q_x)$. The uniform hypothesis gives loss $\log|F(x)|$ on every $f$.
* (ii) $P=$ uniform over the distinct labelings is optimal: the labelings are disjoint events, so some labeling has $P\le1/\#$. ∎

*Example* [computed: c2(a)]. Take parities on $\{0,1\}^{10}$ and $N=200$ inputs. The function mixture pays 200.0 bits. The Bayes (shared-randomness) mixture pays 10.0 bits.

**Proposition 2.2 (weighted form) [proved; known].** Let $\mathcal Q$ be countable with weights $w$. Put $\xi_{\rm fun}(y\mid x)=\sum_qw_qq(y\mid x)$ and $\xi_{\rm seq}(y_{1:N}\mid x_{1:N})=\sum_qw_q\prod_iq(y_i\mid x_i)$. Then:
* per input, $-\log\xi_{\rm fun}(y\mid x)\le\min_q[\log\frac1{w_q}-\log q(y\mid x)]$, so $\xi_{\rm fun}$ pays $\log(1/w)$ **at every input**;
* $-\log\xi_{\rm seq}(y_{1:N}\mid x_{1:N})\le\min_q[\log\frac1{w_q}+\sum_i-\log q(y_i\mid x_i)]$, so $\xi_{\rm seq}$ pays it **once**.

Both bounds are tight. With $\mathcal Q=\{\text{const }0,\text{const }1\}$ and $w=\frac12$, on $N$ ones $\xi_{\rm fun}$ pays $N$ bits and $\xi_{\rm seq}$ pays 1. The chain-rule conditionals of $\xi_{\rm seq}$ depend on past labels. That dependence *is* the shared randomness.

*Proof.* Drop all but one term in each sum. ∎

**Proposition 2.3 (the sequence pathology, exactly) [proved, from known dominance].** Let $M$ be a universal lower-semicomputable conditional semimeasure on label sequences. Then $M\ge2^{-K(\nu)-c_0}\nu$ for every computable $\nu$ (Solomonoff–Levin [known]). Then for every $\lambda>1$ and all data,
$$\lambda K(M)-\log M(y_{1:N}\mid x_{1:N})\ \le\ \lambda c_M+K(\nu)+c_0-\log\nu(y_{1:N}\mid x_{1:N}),$$
which is below $\nu$'s own objective whenever $(\lambda-1)K(\nu)>\lambda c_M+c_0$. So for any fixed $\lambda>1$, every hypothesis of complexity $>(\lambda c_M+c_0)/(\lambda-1)$ loses to $M$. $M$ learns the errors as data accumulate, since its predictive is the Bayes posterior. ∎

**Theorem 2.4 (in the function case "universal" hypotheses are just fixed predictors) [proved].**
* For a fixed product hypothesis $h$ and i.i.d. data, $\hat R_N(h)\to R(h)$ a.s. (SLLN), a number that does not depend on the data. Nothing a product hypothesis does can make its per-sample loss improve with $N$.
* In particular, the universal *conditional* semimeasure $m(y\mid x)\asymp2^{-K(y|x)}$ is one fixed predictor. For binary $Y$, $m(y\mid x)\ge2^{-\kappa_U}$ for both labels, so $m(y\mid x)\le1-2^{-\kappa_U}$. Hence
$$R(m)\ \ge\ \log_2\frac1{1-2^{-\kappa_U}}\ >\ 0\quad\text{for every teacher},$$
with $\kappa_U$ a constant of the reference machine.
* So the per-input universal mixture is a "coin with a machine-dependent bias". It beats the good model only if $R(\text{good})+c\,\ell(\text{good})\ge R(m)$.

*Proof.* SLLN. For the second claim, use $K(y\mid x)\le K(y)+O(1)=O(1)$ for $y\in\{0,1\}$ and $m(0|x)+m(1|x)\le1$. ∎

### 2.2 The kink

Fix the following setting, which is the user's example made rigorous.
* $X=\{0,1\}^d$, $n=2^d$, $D$ uniform.
* The simple model is $f_a(x)=\langle a,x\rangle\bmod2$, with $K(a)\ge d$ (a random $a$).
* An error set $E\subseteq X$ with $|E|=pn$ and $p<1/4$.
* The teacher is $y^*=f_a\oplus1_E$.
* Write $L_E=\log_2\binom n{pn}$. By Stirling, $L_E/n=H(p)-O(\log n/n)$.
* Let $\delta_E:=L_E-K(E\mid a,K(a))\ge -O(\log n)$, the randomness deficiency of $E$ given $a$; it is small for most $E$.
* For a product hypothesis $h$, put $s_h(x)=h(0|x)-h(1|x)$, $\chi_{a'}(x)=(-1)^{\langle a',x\rangle}$ and $\hat s_h(a')=\mathbb E_x[s_h\chi_{a'}]$.

**Lemma 2.5a (list decoding) [proved].** $|\{a':\hat s_h(a')\ge2^{-t}\}|\le2^{2t}$. Hence if $\hat s_h(a)\ge2^{-t}$, then $K(a\mid h^*)\le2t+2\log_2(t+1)+2\log_2d+O(1)$, where $h^*$ is a shortest program for $h$. The $2\log_2d$ term supplies $d$, since a program for $h$ need not determine it.

*Proof.*
* Parseval gives $\sum_{a'}\hat s_h(a')^2=\mathbb E[s_h^2]\le1$.
* Given $h^*$, compute all $\hat s_h(a')$ exactly (finite rational sums) and list those $\ge2^{-t}$.
* Then specify $d$ and $t$ (self-delimiting) and the index of $a$ in the list ($2t$ bits). ∎

**Lemma 2.5b (risk vs correlation) [proved].** $R(h)\ge-\log_2\big(\tfrac{1+\hat s_h(a)}2+p\big)$.

*Proof.*
* Jensen: $R(h)\ge-\log_2\mathbb E_x[h(y^*(x)|x)]$.
* On $X\setminus E$, $h(y^*|x)=h(f_a(x)|x)=\frac{1+s_h(x)\chi_a(x)}2$. On $E$ it is $\le1$.
* So $\mathbb E_x[h(y^*|x)]\le\frac{1+\hat s_h(a)}2+p$. ∎

**Theorem 2.5 (kink: shared vs private randomness) [proved].** There is a machine constant $\kappa$ such that the following hold.
* **(a) Shared randomness has no kink.** For each $u\in\{0..d\}$ let $P_u$ be the uniform mixture, with shared randomness, of the $2^u$ parities agreeing with $a$ on its first $d-u$ coordinates, each with i.i.d. flip-$p$ noise. Then
  $$K(P_u)\le d-u+\kappa',\qquad -\log P_u(y^*)\le u+nH(p).$$
  So the total $K(P_u)-\log P_u(y^*)\le d+nH(p)+\kappa'$ is the same for all $u$. For every $\lambda>1$ the $\lambda$-objective is minimized, up to $\kappa'$, at $u=d$: the zero-knowledge class mixture. Here $\kappa'=O(\log d)+K(p)$.
* **(b) Private randomness has a kink.** For every product $h$ and every $t\ge0$:
  $$K(h)\le d-2t-2\log_2(t+1)-2\log_2d-\kappa\ \Longrightarrow\ R(h)\ge1-\frac{2^{-t}+2p}{\ln2},$$
  whereas the good model $h_{\rm good}$ (namely $f_a$ with flip-$p$ noise) has $K\le d+\kappa'$ and $R=H(p)$.
* **(c) The error segment.** For every product $h$: $K(h)+nR(h)\ge d+L_E-\delta_E-\kappa$. The error-memorizing model $h_{\rm bad}=f_a\oplus1_E$ has $K\le d+L_E+O(\log n)$ and $R=0$.

*Proof.*
* (a) $P_u$ is computable from the $d-u$ known bits plus $d,u,p$. The true parity is a mixture component of weight $2^{-u}$, and its likelihood is exactly $(1-p)^{n-pn}p^{pn}=2^{-nH(p)}$.
* (b) Suppose $\hat s_h(a)\ge2^{-t}$. Then, by Lemma 2.5a, $d\le K(a)\le K(h)+K(a\mid h^*)+O(1)\le K(h)+2t+2\log_2(t+1)+2\log_2d+O(1)$. This contradicts the hypothesis once $\kappa$ exceeds the $O(1)$. So $\hat s_h(a)<2^{-t}$, and Lemma 2.5b gives $R(h)\ge-\log_2(\frac12+2^{-t-1}+p)=1-\log_2(1+2^{-t}+2p)\ge1-(2^{-t}+2p)/\ln2$.
* (c) Several steps:
  * $P_h(y):=\prod_xh(y_x|x)$ is a distribution computable from $h^*$. By the conditional coding theorem, $K(y^*\mid h^*)\le-\log P_h(y^*)+O(1)=nR(h)+O(1)$, so $K(y^*)\le K(h)+nR(h)+O(1)$.
  * From $y^*$ one computes $a$: its correlation with $\chi_a$ is $1-2p$, and its correlation with any other $\chi_{a'}$ is $|{-2}\mathbb E[\chi_{a\oplus a'}1_E]|\le2p<1-2p$. Then $E=\{y^*\ne f_a\}$. So $K(a,E)\le K(y^*)+O(1)$.
  * Symmetry of information gives $K(a,E)=K(a)+K(E\mid a,K(a))+O(1)\ge d+L_E-\delta_E-O(1)$. ∎

**Reading.** Part (a) is precisely the user's remark that in the sequence case "it's pretty much just 1 bit paying for 1 bit": the shared-randomness frontier is the sufficiency line. Part (b) is his hope made true. Partial knowledge of the simple model is worthless per input, so the frontier stays near the coin until the model is fully specified. His "see some point at which the derivative changes" is exactly this kink.

[computed: c2(b)] For $d=10$, $|E|=16$, $p=1/64$:
* The product list-mixtures have risks $0.116, 0.546, 0.779, 0.890,\dots,0.999$ at $10,9,8,7,\dots,0$ bits.
* The shared-randomness mixtures have total code length $128.9$ bits at every $u$.
* Hulls: the product hull is coin → good → bad. The shared hull is mixture → bad.
* Selection at $\lambda\in\{1.5,4,50\}$: the product family picks the good model; the shared family picks the zero-bit mixture.

### 2.3 Where universality comes back: blocks

**Proposition 2.6 (per-block pricing) [proved].** Suppose the hypothesis's input at position $i$ of block $b$ contains the block's earlier pairs, as when the input is "the proof so far". Let $\{\nu_\theta\}$ be any countable family of "persona" models with weights $w$. Then the in-context mixture
$$h_w(y\mid\text{history})=\textstyle\sum_\theta w(\theta\mid\text{history})\,\nu_\theta(y\mid\cdot)$$
is a single function hypothesis with $K(h_w)\le K(w)+O(1)$, and on every block
$$\sum_{i\in b}-\log h_w(y_{b,i}\mid\cdot)\ \le\ \min_\theta\Big[\log\tfrac1{w_\theta}+\sum_{i\in b}-\log\nu_\theta(y_{b,i}\mid\cdot)\Big].$$
So it pays $\log(1/w)$ **per block**. Blocks of length 1 recover the function case (per input). One block of length $N$ recovers the sequence case (once).

*Proof.* Prop 2.2's sequential bound, applied within each block. ∎

*Consequence* [computed: c5]. Suppose a fraction $q=0.2$ of humans each have an *idiosyncratic* systematic error: "in error contexts play wrong move $j$", with $j$ uniform over $2^{16}$ moves.
* Each such rule alone has rate essentially zero: 16 bits, used by a $q2^{-16}$ fraction.
* The $O(1)$-bit copier ("predict this human's own earlier wrong move") matches a calibrated norm model at $K=1$ error context per block, which is exactly the per-input pricing.
* It beats the norm model at $K\ge2$: per-context loss $3.03$ vs $4.64$ bits at $K=2$, and $1.33$ vs $4.68$ at $K=16$.

**Design consequence.** The user's private-randomness defence holds only at the granularity at which inputs do not carry other labels. An LLM imitating whole proof documents is a block model. A *step checker* whose input is a single step $(\Pi,j)$, as in T1, is a function model. This is a second, independent argument for T1's architecture.

### 2.4 Answer to "is there a universal hypothesis in the function case?"

* No, provided randomness is private per input and inputs carry no other labels.
  * Every single hypothesis prices mixtures per input (Thm 2.1, Prop 2.2).
  * The universal conditional semimeasure is a fixed, weakly informative predictor (Thm 2.4).
  * Partial knowledge of a simple model buys nothing until it is complete (Thm 2.5(b)).
* Yes, at block granularity, as soon as inputs contain labelled history (Prop 2.6).
* The other pathologies he suspected exist, but they are not universality. They are **rate blindness** (§4) and its consequences.

---

## 3. Rate thresholds and the convex hull

### 3.1 The hull

Let $A=\{(\ell(h),R(h)):h\in\mathcal H\}$. With a prefix code, finitely many $h$ have $\ell(h)\le L$, so each $J_c$ attains its minimum. Let $\mathrm{hull}^-(A)$ be the lower-left boundary of $\mathrm{conv}(A+\mathbb R_{\ge0}^2)$.

**Lemma 3.1 [proved; standard].**
* (i) Every minimizer of $J_c$ lies on $\mathrm{hull}^-(A)$, on a supporting line of slope $-c$.
* (ii) *Monotonicity.* Take $c<c'$, with $h$ minimizing $J_c$ and $h'$ minimizing $J_{c'}$. Then $\ell(h)\ge\ell(h')$ and $R(h)\le R(h')$.
* (iii) A point $P\in A$ is the unique minimizer for all $c$ in a nonempty open interval iff $P$ is a vertex (extreme point) of $\mathrm{hull}^-(A)$. The interval is $(s_+,s_-)$, the absolute slopes of the edges to its right and left, with $s_-=\infty$ at the leftmost vertex.

*Proof.*
* (i) $J_c(h)=\langle(c,1),P_h\rangle$ is minimized over $A$ exactly where it is minimized over $\mathrm{conv}(A+\mathbb R^2_{\ge0})$.
* (ii) Add $c\ell(h)+R(h)\le c\ell(h')+R(h')$ to $c'\ell(h')+R(h')\le c'\ell(h)+R(h)$. This gives $(c'-c)(\ell(h')-\ell(h))\le0$, and then the $R$ inequality follows from the first.
* (iii) A vertex has a cone of strictly supporting normals. A non-vertex boundary point is a convex combination of two other boundary points, so for every $c$ one of them is at least as good. ∎

[computed: c3(ii)] 300 random point sets and 400 values of $c$ each: no minimizer off the hull, no monotonicity violation, and every vertex selectable.

The user's convex-hull argument is therefore correct as stated, with two refinements. The good model must be a **vertex**, not merely on the hull. And $\lambda$ must lie in $(s_+N,\ s_-N)$.

### 3.2 Separable components

**Theorem 3.2 (product classes; rate threshold) [proved; TOSU].** Partition $X=\bigsqcup_jX_j$. Let $\mathcal H=\prod_j\mathcal H_j$, where $h_j$ acts on $X_j$ and $\ell(h)=\sum_j\ell_j(h_j)$ (concatenated prefix codes). Then:
* $J_c(h)=\sum_j[c\ell_j(h_j)+R_j(h_j)]$, where $R_j$ is $D$-weighted risk on $X_j$. The minimizers are exactly the products of per-region minimizers, so each region independently picks its own hull vertex for slope $c$.
* In particular, suppose $\mathcal H_j=\{\text{default},\text{component }j\}$, with the component costing $k_j$ more bits and lowering $R_j$ by $r_j$. Then component $j$ is selected iff $r_j/k_j>c$; ties are arbitrary.

*Proof.* The objective is a sum of functions of disjoint coordinates. ∎ [computed: c3(i),(iii): 0 violations in 6000 and 2000 tests.]

### 3.3 Idealized version with arbitrary hypotheses

The separable theorem assumes the hypothesis class is a product. With $\ell=K$ and *all* computable hypotheses allowed, a hypothesis could in principle share information across regions or learn components "partially". The next theorem shows that, for independent parity components, it cannot gain from either, up to explicit slack.

Setting:
* Regions $X_j=\{j\}\times\{0,1\}^{d_j}$ for $j=1..m$, with $D(j,z)=\pi_j2^{-d_j}$.
* Teacher $y^*(j,z)=\langle a_j,z\rangle\bmod2$, with the components jointly random: $K(a_1,\dots,a_m)\ge\sum_jd_j$.

**Theorem 3.3 (rate threshold, idealized) [proved].** For all $c>0$,
$$\Big|\Phi(c)-\sum_{j}\min(c\,d_j,\ \pi_j)\Big|\ \le\ \Delta_0(c):=c\Big(\sum_j(2\log_2d_j+2\log_2m+4+\kappa)+\kappa\Big)+\sum_j\pi_j2^{1-d_j/4}.$$
Moreover, assume every $d_j\ge8$. If $J_c(h)\le\Phi(c)+\eta$, set $\Delta=2\Delta_0(c)+\eta$. For each $j$:
* if $\pi_j<c\,d_j-\Delta-4c$, then $\hat s_{h,j}(a_j)<\frac12$: $h$ has not learned component $j$;
* if $\pi_j>c\,d_j+\Delta+\pi_j2^{1-d_j/4}$ and $\pi_j>2\Delta+16c$, then $\hat s_{h,j}(a_j)\ge\frac12$: $h$ has learned it.

The rate of component $j$ is $\pi_j/d_j$ (risk reduction of one bit on mass $\pi_j$ for $d_j$ bits).

*Proof.*
* **Upper bound.** $h_S$ knows $a_j$ for $j\in S$ and flips a coin elsewhere. It has $K(h_S)\le\sum_{j\in S}(d_j+2\log_2d_j+2\log_2m)+\kappa$ and $R(h_S)=\sum_{j\notin S}\pi_j$. Take $S=\{j:c\,d_j<\pi_j\}$.
* **Lower bound.**
  * Fix $h$. Let $t_j$ be the least $t\in\mathbb N$ with $\hat s_{h,j}(a_j)\ge2^{-t}$, or $\infty$.
  * Given $h^*$, $j$ and $d_j$, we can either list-decode (Lemma 2.5a) or write $a_j$ literally. So $K(a_j\mid h^*)\le\min\{s(t_j),\,d_j\}+2\log_2d_j+2\log_2m+\kappa$, where $s(t)=2t+2\log_2(t+1)$.
  * Then $\sum_jd_j\le K(a_{1..m})\le K(h)+\sum_jK(a_j\mid h^*)+\kappa$. Since $d-\min\{s,d\}=(d-s)^+$, this gives
  $$K(h)\ \ge\ \sum_j(d_j-s(t_j))^+-\sum_j(2\log_2d_j+2\log_2m+\kappa)-\kappa.$$
  * By Lemma 2.5b (with $p=0$), $R_j(h)\ge1-\log_2(1+2^{1-t_j})\ge1-2^{1-t_j}$ for $t_j\ge1$.
  * So $J_c(h)\ge\sum_j\varphi_j(t_j)-c(\sum_j(2\log_2d_j+2\log_2m+\kappa)+\kappa)$, where $\varphi_j(0)=c\,d_j$ and, for $t\ge1$, $\varphi_j(t)\ge c(d_j-4t)^++\pi_j(1-2^{1-t})$ (using $s(t)\le4t$).
  * On $t\in[1,d_j/4]$ the right side is concave in $t$, so its minimum is at an endpoint: $\ge\min(c(d_j-4),\pi_j(1-2^{1-d_j/4}))$. For $t>d_j/4$ it is $\ge\pi_j(1-2^{1-d_j/4})$.
  * Hence $\min_t\varphi_j(t)\ge\min(c\,d_j,\pi_j)-4c-\pi_j2^{1-d_j/4}$. Sum over $j$.
* **Identification.** We have $\varphi_j(t_j)\le J_c(h)+c(\sum_i(2\log_2d_i+2\log_2m+\kappa)+\kappa)-\sum_{i\ne j}\varphi_i(t_i)$, and each $\varphi_i\ge\min(c\,d_i,\pi_i)-(4c+\pi_i2^{1-d_i/4})$. Combined with the upper bound on $\Phi$, if $J_c(h)\le\Phi+\eta$ then every region satisfies $\varphi_j(t_j)\le\min(c\,d_j,\pi_j)+2\Delta_0+\eta=\min(c\,d_j,\pi_j)+\Delta$.
  * If $\hat s_j\ge\frac12$, then $t_j\le1$ and $\varphi_j\ge c(d_j-4)$. This exceeds $\pi_j+\Delta$ under the first condition.
  * If $\hat s_j<\frac12$, then $t_j\ge2$ and $R_j\ge1-2^{1-t_j}\ge\frac12$. The same concavity argument on $[2,d_j/4]$ gives $\varphi_j\ge\min(c(d_j-8)+\pi_j/2,\ \pi_j(1-2^{1-d_j/4}))$. This exceeds $c\,d_j+\Delta$ under the second condition. ∎

**Corollary 3.4 (every convex hull shape is realizable) [proved from Thm 3.3].** Take rational slopes $s_1>\dots>s_m>0$ and lengths $d_j$ with $\sum s_jd_j\le1$. Set $\pi_j=s_jd_j$, and add a region of mass $1-\sum\pi_j$ with fair-coin teacher labels. A fair-coin region adds the constant $1-\sum\pi_j$ to every hypothesis's risk and is otherwise inert, so Thm 3.3 applies. The resulting product-model frontier is, up to $\Delta_0$, the convex polygon with edges of slope $-s_j$ and horizontal length $d_j$. *Any* convex decreasing piecewise-linear frontier is therefore realizable.

This is the product-model analogue of Vereshchagin–Vitányi's "all shapes" result. The moral is the same: **whether a "good model" exists as a vertex is a property of the data, not a theorem.**

### 3.4 The user's example, verified

**Theorem 3.5 (parity version of the user's example) [proved].** Work in the setting of Thm 2.5. Write $\tau_t=2t+2\log_2(t+1)+2\log_2d+\kappa$. For every $c>0$ and $t\ge0$,
$$\min\Big\{1-\tfrac{2^{-t}+2p}{\ln2},\ c(d-\tau_t)+\tfrac{L_E-\delta_E-\kappa}n,\ c(d+L_E-\delta_E-\kappa)\Big\}\ \le\ \Phi(c)\ \le\ \min\Big\{1+c\kappa,\ c(d+\kappa')+H(p),\ c(d+L_E+\kappa\log n)\Big\}.$$
The three terms are the coin, the good model and the error-memorizing model. The switch points are approximately
$$c_{\rm coin/good}\approx\frac{1-H(p)}{d},\qquad c_{\rm good/bad}\approx\frac{H(p)}{L_E}\approx\frac{H(p)}{nH(p)}=\frac1n.$$

*Proof.*
* The upper bound lists the three models.
* For the lower bound, split on $K(h)$:
  * If $K(h)\le d-\tau_t$, use Thm 2.5(b).
  * Otherwise, Thm 2.5(c) gives $J_c(h)\ge cK+\max(0,(K_{\rm tot}-K)/n)$, with $K_{\rm tot}=d+L_E-\delta_E-\kappa$. This is piecewise linear in $K$. Its minimum over $K\ge d-\tau_t$ is attained at $K=d-\tau_t$ when $c\ge1/n$, and at $K=K_{\rm tot}$ when $c<1/n$. ∎

So the error component's rate is $\approx H(p)/L_E\approx1/n$. A random error set costs one bit per $1/n$ of risk, the slowest possible rate. *The user's example is the most favourable case for his proposal.*

**Numbers.**
* *His numbers* [computed: c1]. Simple model 100 bits (+10 for the flip rate); error component 10 000 bits on a $2^{-10}$ fraction; $H(2^{-10})=0.01117$ bits/sample ("about 1/100", as he says).
  * Rates: $8.99\cdot10^{-3}$ for the simple model, $1.12\cdot10^{-6}$ for the error component.
  * The good model is selected iff $1.12\cdot10^{-6}<c<8.99\cdot10^{-3}$. In $\lambda=cN$ this is, e.g., $\lambda\in(1.12,\,8990)$ at $N=10^6$.
  * Standard MDL ($\lambda=1$) switches to the error-memorizing model at $N\approx8.9\cdot10^5$.
* *Rigorous parity instance with comparable sizes.* Take $d=20$, $n=2^{20}$, $p=2^{-10}$. Then $L_E\approx11\,700$ bits, and the good window is $c\in(\approx9.5\cdot10^{-7},\ \approx0.049)$, up to the $O(\log)$ slack of Thm 3.5.
* Small instance [computed: c2(b)]: $d=10$, $|E|=16$. The error component's rate is $0.1161/115.6=1.004\cdot10^{-3}\approx1/n$, so the good model is selected for $\lambda=cn>1.03$.

---

## 4. Pathologies

### 4.1 (a) Rate blindness: rare valid rules are noise

**Theorem 4.1 (rate blindness) [proved; TOSU].**
* (i) The map $c\mapsto\arg\min J_c$ depends on the data only through $(D,P^*)$. Validity enters nowhere.
* (ii) In the separable setting (Thm 3.2 or 3.3), let $v$ be a valid component and $e$ an error component with $r_v/k_v\le r_e/k_e$. Then for every $c$, if $v$ is selected so is $e$.
* (iii) In general, the intended hypothesis $h^\circ$ is selectable iff $P_{h^\circ}$ lies on $\mathrm{hull}^-(A)$, and uniquely selectable iff it is a vertex.
* (iv) Take two worlds with the same $(D,P^*)$, in which a component is an error in world 1 and a valid rare rule in world 2. Every $c$, and indeed every imitation-only procedure, gives the same output in both. So it is wrong in one of them.

*Proof.*
* (i) $J_c$ is a functional of $(D,P^*)$.
* (ii) $c<r_v/k_v\le r_e/k_e$.
* (iii) Lemma 3.1.
* (iv) This is (i); compare L11 Lemma 2.1 and T1 Cor 6.5. ∎

What is new relative to T1 Cor 6.5 ("systematic errors are rules") is the *quantitative* criterion. The steeper penalty does separate errors from rules, but **by rate, not by validity**. It succeeds exactly when every intended component out-rates every error component. A valid rule used in $10^{-4}$ of steps that costs 200 bits has rate $\approx5\cdot10^{-7}g$, where $g$ is the per-use gain in bits. It is discarded at any $c$ that rejects the user's 10 000-bit error.

A real-world analogue: low-frequency irregular verbs regularize faster. Their half-lives scale like the square root of usage frequency (Lieberman, Michel, Jackson, Tang & Nowak 2007, *Nature* 449:713–716) **(unverified exact exponent)**. Rare valid exceptions are the first casualties of simplicity pressure.

### 4.2 (b) Cheap frequent fallacies

**Proposition 4.2 (cheap fallacies out-rate genuine rules) [proved for the model; numbers illustrative].**
* In situation-typed imitation (§5.1), a schema used in a fraction $\pi$ of steps has rate $\pi g/\ell$, where $g$ is its per-step gain.
* *Affirming the consequent* ($q,\ p\to q\ /\ p$) has the same schema size as modus ponens ($p,\ p\to q\ /\ q$). So $\mathrm{rate(AC)}/\mathrm{rate(MP)}=\pi_{\rm AC}/\pi_{\rm MP}$.
* The freshman's dream $(a+b)^2\to a^2+b^2$ is shorter than the correct expansion.
* Hence any $c$ that keeps every valid rule used less often than AC (per unit of description) also keeps AC.

*Proof.* Compute the rates; the selection rule is Thm 3.2. ∎

[computed: c4, illustrative frequencies] Take $M=64$ candidate steps per context and $\eta=0.05$ sporadic noise, so $g=5.42$ bits per use. Then:
* AC (frequency 0.02, 20 bits) has rate $5.4\cdot10^{-3}$. This is *above* the rates of proof-by-cases ($1.4\cdot10^{-3}$), reductio ($1.6\cdot10^{-3}$), ex falso ($7.2\cdot10^{-4}$) and induction ($1.2\cdot10^{-4}$).
* The freshman's dream ($2.5\cdot10^{-3}$) and conditional perfection ($2.2\cdot10^{-3}$) also beat several valid rules.
* With simplicity alone, the window "all valid rules in, all errors out" is **empty**: one would need $5.4\cdot10^{-3}<c<1.2\cdot10^{-4}$.

**Moreover, the cheapness of these fallacies is not an accident.** A fallacy becomes *systematic* in a human population exactly because it is a short, natural variant of a valid pattern. So the error class that the user most wants removed is the class with the highest rates. See also §4.4 (d6).

### 4.3 (c) The window is not identifiable from imitation data

**Theorem 4.3 (validation prefers the teacher) [proved].**
* (i) Along the selection path, held-out risk $R(h_c)$ is non-increasing as $c$ decreases (Lemma 3.1(ii)). So selecting $c$ by held-out log-loss on imitation data picks the smallest $c$ considered, up to estimation error.
* (ii) More generally, for any strictly proper scoring rule $S$, $\mathbb E_{y\sim P^*}S(P^*(\cdot|x),y)>\mathbb E_{y\sim P^*}S(q,y)$ for $q\ne P^*(\cdot|x)$ (Gneiting & Raftery 2007, *JASA* [known]). Any validation criterion that is an empirical proper score on fresh imitation data is therefore maximized by the teacher channel, errors included. Among candidates, it prefers the one closest to $P^*$, never the norm *as such*.
* (iii) There is no imitation-data statistic that picks the good $c$ in both of the worlds of Thm 4.1(iv).

*Proof.*
* (i) Lemma 3.1(ii).
* (ii) Strict propriety, applied pointwise and integrated over $D$. With a growing held-out set, the empirical score converges uniformly over finitely many candidates.
* (iii) Thm 4.1(iv). ∎

[computed: c4] In the user's example, held-out log-loss is $1.0$ at $c=10^{-1}$, $0.0112$ at $c\in[10^{-5},10^{-3}]$, and $0$ at $c=10^{-7}$. Cross-validation picks the error-memorizing model.

*SafeBayes.* SafeBayes chooses $\eta=1/\lambda$ to minimize a sequential randomized log-loss on the same data. It is a proper-score procedure, so (ii) applies. In the well-specified imitation setting it has no reason to move away from standard Bayes. The user's $\eta\ll1$ is a *normative* choice that no data-fit criterion on $P^*$ can recover. This is my reading; I have not checked the SafeBayes papers' exact criteria.

### 4.4 (d) Further pathologies

**Proposition 4.4 (guard erosion: steeper simplicity can make the learner less sound than the teacher) [proved].**
* Let $\sigma$ be a schema and $\sigma|_G$ its guarded version, e.g. $x/x\to1$ if $x\ne0$. Humans apply $\sigma$ only where $G$ holds. In contexts where $\sigma$ is applicable but $G$ fails (frequency $\pi_{\neg G}$), they do something else.
* The unguarded hypothesis puts mass $1-\eta$ on the $\sigma$-step there. Its excess loss per such context is $\le\log_2(M/\eta)-\log_2(M-1)\approx\log_2(1/\eta)$.
* So the guard's rate is at most $\pi_{\neg G}\log_2(1/\eta)/k_G$, and for $c$ above it **the selected rule is the unguarded, unsound $\sigma$**, although the teacher never committed the error.
* In classical settings one unsound schema trivializes the calculus (T1 Prop 2.3; T2 Thm 3.1). With field rules, $0/0\to1$ gives $1=0$.

*Proof.* Rate computation plus Thm 3.2. ∎

[computed: c4] With $\pi_{\neg G}=5\cdot10^{-4}$ and a 12-bit guard, the guard's rate is $1.8\cdot10^{-4}$. It is dropped for every $c$ above that, including values at which ex falso ($7.2\cdot10^{-4}$) is kept.

The *norm-carrying* structure that a careful teacher exhibits most rarely (side conditions, eigenvariable conditions, edge cases) is exactly what steep simplicity removes first. Coherence must restore it: the unguarded rule gives $0/0=1$, while $a/b=a\cdot b^{-1}$ and $0\cdot y=0$ give $0/0=0$. Hence $1=0$, a T2 negative bag.

**Proposition 4.5 (error envelopes) [proved; TOSU].** Suppose the error set $E$ lies inside a cheaply describable region $S$: $K(S\mid f)=k_S$, $D(S)=\sigma$, and error density $\theta=D(E)/\sigma$ in $S$.
* The hypothesis "$f$, with flip rate $\theta$ on $S$ and $0$ off $S$" costs $k_S+O(1)$ bits over the good model. It reduces risk by $H(p)-\sigma H(\theta)$, where $p=D(E)$.
* So it is learned at its *own* rate, which can far exceed the rate of the full error component.
* If $\theta>1/2$, the learner predicts the **error label** on all of $S$: it imitates a coarse version of the error.

*Example.* Take $p=2^{-10}$, $\sigma=2^{-8}$, $\theta=\frac14$, $k_S=30$. The risk reduction is $0.0112-0.0032=0.0080$, a rate of $2.7\cdot10^{-4}$, compared with $1.1\cdot10^{-6}$ for the full error. With $\theta<\frac12$ this is benign: the intended label is still predicted, with honest uncertainty. When errors cluster ($\theta>\frac12$), the envelope *is* a learned systematic error.

The user's example has a K-random $E$, so no such envelope exists (Thm 2.5(c)). **Real systematic errors are the opposite case: they are low-complexity patterns.**

**(d3) Non-additivity: parasitic errors [proved by example].** The separability of Thm 3.2 fails when an error is cheap *given* a valid rule. Then $K(e\mid v)\ll K(e)$, and once $v$ is included the marginal rate of $e$ is $r_e/K(e\mid v)$.

Examples:
* the freshman's dream is "distribute the exponent", a one-symbol mutation of $(ab)^n=a^nb^n$;
* the unguarded rule is the guarded one minus its guard;
* "or as xor" is ∨ plus one clause.

Valid rules *subsidize* their own mis-generalizations. The selection path along the hull then interleaves valid and erroneous refinements in an order fixed by conditional rates.

**(d4) Coherence-repair by sacrifice.** See Prop 5.3.

**(d5) In-context universality.** See Prop 2.6.

**(d6) Language relativity [proved; TOSU].**
* For any finite list of components with risk reductions $r_j$, any target inclusion set $S^\circ$ and any $c$, there is a prefix code with $S^*(c)=S^\circ$. Take $k_j<r_j/c$ for $j\in S^\circ$ and $k_j>r_j/c$ otherwise, then pad with unused codewords to satisfy Kraft.
* For universal machines the invariance theorem bounds the damage by an additive constant $c_{UV}$. Rates change by the factor $k/(k\pm c_{UV})$. That is negligible for 10 000-bit errors and decisive for 20-bit schemas, which is the inference-rule regime.
* The user's idea (ii), a "simplicity prior defined in terms of existing understanding", cuts both ways. A learner whose description language is shaped by human concepts, e.g. by pretraining on human text, assigns *human-natural* errors short codes. That raises exactly the rates of the fallacies humans find natural.

**(d7) Distribution dependence [TOSU].** Rates scale with $D$-frequency. A valid rule rare in the training distribution, e.g. used mainly in hard problems, is discarded, and stays discarded as $N\to\infty$ with $\lambda=cN$. Under a shift to a distribution where it matters, the learned norm is wrong. In T1's terms the verifier stays sound but becomes incomplete. With guard erosion it can become unsound.

---

## 5. Inference rules

### 5.1 Situation-typed step imitation

* Following T1 §1, steps are $(\Pi,j)$. A context $x$ is the current premise set and goal, and the label $y$ is the human's next step, chosen from a candidate set $M(x)$ with $|M(x)|=M_\tau$.
* Contexts fall into **situation types** $\tau$ (computable from $x$, part of the base model) with frequencies $\pi_\tau$. In type $\tau$ the human applies a schema $\sigma_\tau$, valid ($\in R^*$) or fallacious, with probability $1-\eta$, and otherwise moves uniformly at random.
* A hypothesis chooses a set $S$ of types to model with their schemas. Each modelled type costs $\ell(\sigma_\tau)+O(1)$ bits; the rest are predicted uniformly.
* The gain per modelled step is $g_\tau=\log_2M_\tau-H_\tau$, where $H_\tau$ is the teacher channel's entropy in that type. The rate is $\rho_\tau=\pi_\tau g_\tau/\ell(\sigma_\tau)$.
* By Thm 3.2, type $\tau$'s schema is selected iff $\rho_\tau>c$.

The **verifier induced** by a selected hypothesis accepts exactly the instances of selected schemas; the noise component is not accepted. So T1 soundness of the induced verifier means "no selected error schema and no eroded guard".

### 5.2 Feasibility constraints: coherence, world, postulates

* Let $C=V\sqcup E$ be the valid and erroneous components, with net values $g_j=r_j-c\,k_j$.
* A **feasibility family** $\mathfrak F\subseteq2^C$ records which component sets are admissible:
  * *A-coherent*: no ⊥-derivation from a designated context (T2 §1);
  * *W-adequate*: no derivation of a claim the world oracle refutes;
  * *postulate-respecting*: coherent with designated meaning postulates $\mathrm{Ax}$.
* Each such $\mathfrak F$ is **down-closed**, since derivability is monotone in the rule set, and contains $2^V$, since valid rules are jointly coherent and true.
* For an error $F$, a **witness** is a minimal $W\subseteq V$ with $W\cup\{F\}\notin\mathfrak F$. It plays the role of T2's negative bag (Lemma 2.1), seen from the rule side.

Write $V_+=\{v:g_v>0\}$ and $E_+=\{F:g_F>0\}$.

**Assumptions.**
* *Error-independence:* $U\cup E'\in\mathfrak F$ iff $U\cup\{F\}\in\mathfrak F$ for each $F\in E'$, for $U\subseteq V$.
* *Valid dominance:* for every $F\in E_+$ that has a witness inside $V_+$, the cheapest blocking set satisfies $\beta(F):=\min\{\sum_{v\in B}g_v: B\subseteq V_+\text{ meets every witness of }F\text{ inside }V_+\}>\sum_{F'\in E_+}g_{F'}$.

**Theorem 5.2 (division of labour) [proved].** Under separability, error-independence and valid dominance, the optimal feasible set is unique up to zero-value ties and equals
$$S^*(c)=V_+\ \cup\ \{F\in E_+:\ V_+\cup\{F\}\in\mathfrak F\}.$$
Spelled out:
* **Simplicity** removes exactly the errors with rate $\le c$, whether or not they are coherent.
* **Coherence** removes exactly the errors with a coherence witness among the valid rules *actually kept*, whatever their rate.
* **World feedback** removes exactly the errors with a refutation using kept rules, whatever their rate.
* **Postulates** remove exactly those incoherent with $V_+\cup\mathrm{Ax}$.
* **The residue** is the set of errors that are high-rate, coherent, empirically adequate and postulate-consistent relative to $V_+$.
* **The cost** is that the valid rules with rate $\le c$ are lost, whatever the other filters do.

*Proof.*
* Let $S$ be feasible and optimal. Removing components with $g<0$ keeps feasibility (down-closure) and raises the value, so $S\subseteq\{g\ge0\}$.
* Let $E_1=S\cap E\setminus\{F:V_+\cup\{F\}\in\mathfrak F\}$. Each $F\in E_1$ has a witness inside $V_+$. Feasibility of $S$ forces $B:=V_+\setminus S$ to meet every such witness, so $\sum_Bg\ge\beta(F)>\sum_{E_+}g\ge\sum_{E_1}g$.
* The set $S'=V_+\cup(S\cap E\setminus E_1)$ is feasible by error-independence, and has value $\ge\mathrm{val}(S)+\sum_Bg-\sum_{E_1}g>\mathrm{val}(S)$. That is a contradiction, so $E_1=\emptyset$.
* Now every error in $S$ is feasible with $V_+$. Adding $V_+\setminus S$ keeps feasibility and does not lower the value, and so does adding every $F\in E_+$ feasible with $V_+$. ∎

**Corollary 5.2a (best $c$ given the other filters).** Separation, meaning all valid rules kept and all errors removed, is possible iff
$$\max\{\rho_F: F\text{ survives coherence, world and postulates relative to }V\}<\min_{v\in V}\rho_v.$$
Coherence and world feedback **widen the window**: the rates of incoherent or refutable errors no longer matter. Steeper simplicity is then needed only against coherent, adequate, low-rate errors: idiosyncratic memorized falsehoods, and non-uniform "quus"-like additions (T2 Prop 6.3).

**Proposition 5.3 (without valid dominance: coherence repair by sacrifice) [proved; computed].** Suppose $F\in E_+$ has a witness set blockable at cost $\beta(F)<g_F$. Then $V_+\cup\{\text{feasible errors}\}$ is not optimal. Every optimum either contains $F$ and omits a blocking set of valid rules, or does better still.

*Proof.* $V_+\setminus B\cup\{F\}\cup\dots$ is feasible, and its value exceeds that of the clean set by $g_F-\beta(F)>0$. ∎

[computed: c4] AC's Post witness (T2 Cor 6.2) with $p:=\bot$ and $q:=(A\to A)$ needs only →I.
* If →I is rare (rate $8.7\cdot10^{-4}$), then at $c=5\cdot10^{-4}$ the unconstrained optimum is {AC, MP, →I, ⊤I}, but the coherent optimum is {AC, MP, ⊤I}. **It drops →I to keep the fallacy.**
* If →I is frequent, the coherent optimum is {MP, →I, ⊤I}.

This is Lakatos's monster-barring run backwards: the repair is chosen by MDL cost, not by validity. It refines T2 Thm 6.1. The elimination criterion "$h^*\oplus\mathcal G(F)$ incoherent" must be evaluated relative to the rules the learner *keeps*, and against the price of the rules that would have to go.

### 5.3 Meaning postulates: "1+1=2 won't be true if you assign 1→rabbit and 2→chicken"

In his note, the user lists "you specify properties of the thing or notion" as a separate route. Formally, a finite set $\mathrm{Ax}$ of sentences, endorsed as constitutive of the notion, enters as **designated premises**. Coherence is then checked in contexts $A\cup\mathrm{Ax}$, or as hard constraints on hypotheses. These are Carnap's (1952) meaning postulates, or the user's "axioms/inference rules involving the notion".

**Proposition 5.4 (postulates are rate-independent and rescue cheap fallacies) [proved].**
* **(a)** A fallacy $F$ is excluded at *every* $c$ iff $V_+\cup\mathrm{Ax}\cup\mathcal G(F)\vdash\bot$ from some designated context. The exclusion does not depend on $\rho_F$.
* **(b) Freshman's dream.** Let $\mathrm{Ax}_{\rm num}=\{1+1=2,\ 1^2=1,\ 2^2=4,\ 4\neq2\}$, and let substitution of equals be in $V_+$. The FD instance $(1+1)^2=1^2+1^2$ rewrites to $2^2=1+1$ and then to $4=2$, contradicting $4\ne2$. So FD is excluded however frequent it is.
  * Without postulates, FD plus the ring rules derives only $2ab=0$, which is coherent unless "$2\neq0$" or a numeral fact is designated.
  * The independent world channel, random numerical evaluation (Schwartz–Zippel; orchestrator idea 3), also refutes it.
* **(c) Readings.** Let a hypothesis include a reading $\rho$ of numerals. The demonstrations $\{(\text{"1"},\text{one rabbit}),(\text{"2"},\text{two chickens})\}$ fit both $\rho_{\rm num}$ (numeral ↦ cardinality) and $\rho_{\rm kind}$ (numeral ↦ animal kind) perfectly. Now impose the postulate $1+1=2$ with $+$ read as the sum (disjoint union) of collections:
  * under $\rho_{\rm kind}$, rabbits + rabbits is a collection of rabbits, not chickens, so the postulate fails;
  * under $\rho_{\rm num}$ it holds.
  
  So postulates eliminate misreadings that demonstrations cannot. This is Quine's gavagai with a cure.
* **(d) Limits.** Postulates eliminate exactly the readings outside $\mathrm{Mod}(\mathrm{Ax})$. If $\mathrm{Ax}$ is categorical, the residue is the isomorphic readings: L4's harmless symmetric alternatives. For first-order arithmetic it is the non-standard models (T2 Thm 3.8). So postulates shrink, but do not abolish, the Kripkensteinian residue (T2 Thm 6.4).

*Proof.* (a) is Thm 5.2 with Ax added to the designated contexts. (b) and (c) are direct checks. (d) is the definition of $\mathrm{Mod}$. ∎

**Why this is the right rescue.** Postulates come from a **different channel**: the teacher's *avowals* ("1+1=2", "MP is valid, AC isn't", "a chair is for sitting") rather than the teacher's *performance*. The steeper penalty acts only on performance data. Avowals carry few bits but exclude whole high-rate error classes. Humans are typically more reliable in avowal than in performance: the competence/performance gap. Where an avowal is itself wrong, as with naive comprehension, coherence catches the avowal (T2, H5).

The user's abstract/concrete example is the cross-notion version. The postulate "if $x$ is abstract, studying examples helps" links the taught notion to another notion with *independent* evidence (world feedback about what helps). That turns a labelling error about "abstract" into a W-refutation. This is "should the teacher consider it a chair" made operational: the norm is whatever satisfies the notion's avowed *role*, and the role is checked against other channels.

### 5.4 The toy table [computed: c4]

Illustrative frequencies and lengths:

| error | rate | removed by simplicity alone at | removed by |
|---|---|---|---|
| idiosyncratic false lemma (300 bits, freq $5\cdot10^{-4}$) | $9\cdot10^{-6}$ | any $c>9\cdot10^{-6}$ | **simplicity** (coherent: T2 Prop 6.3; outside W) |
| affirming the consequent | $5.4\cdot10^{-3}$ | $c>5.4\cdot10^{-3}$ (loses 4 valid rules) | **coherence** (T2 Cor 6.2), given →I kept |
| freshman's dream | $2.5\cdot10^{-3}$ | $c>2.5\cdot10^{-3}$ (loses 4 valid rules) | **postulates** (numerals) or **world** (random evaluation) |
| quantifier swap | $5.4\cdot10^{-4}$ | $c>5.4\cdot10^{-4}$ (loses induction) | **postulates/designation** ($0\ne1$; T2 §6) |
| gambler's fallacy | $9.0\cdot10^{-4}$ | $c>9\cdot10^{-4}$ (loses ex falso, induction) | **world** (frequencies), or an independence postulate |
| conditional perfection (closed world) | $2.2\cdot10^{-3}$ | $c>2.2\cdot10^{-3}$ (loses 4 valid rules) | **nothing**: the residue (T2 §6 item 4) |

* With all filters, the remaining window to remove the false lemma while keeping every valid rule is $c\in(9\cdot10^{-6},1.2\cdot10^{-4})$, which is nonempty.
* With simplicity alone, no window removes all errors without losing valid rules.

---

## 6. Assessment, in the user's vocabulary

**Where his hope is vindicated.**
1. *Function Solomonoff with private randomness has no universal-hypothesis pathology* (Thms 2.1, 2.4).
   * The mechanism is exactly the one he named: "you have to pay the likelihood term separately at every $x$".
   * The precise form is the kink theorem. Shared-randomness models pay for partial knowledge once, so their frontier is the sufficiency line ("1 bit paying for 1 bit"). Product models get nothing from partial knowledge, so the frontier is kinked at the simple model.
2. *His convex-hull argument is correct.* Selection by $\lambda K+\sum\mathrm{NLL}$ with $\lambda=cN$ traces the lower hull. The good model is selected for a $c$-window iff it is a vertex. His "derivative changes" is the vertex condition, and his "absolute bound on complexity" variant is the same family, parametrized by the Lagrange dual.
3. *His example works*, with a window of more than three orders of magnitude, and it works asymptotically. That contradicts the finite-window reading in L11. The rigorous version (Thm 3.5) needs the simple model to be "list-decodable" and the error set to be K-random.

**Where it fails, and why.**
1. **The steeper penalty is validity-blind; it sorts by rate.** It encodes the empirical bet that *norms are high-rate structure and errors are low-rate structure*.
   * The bet is right for idiosyncratic slips: memorized wrong facts, one-off misreadings, errors random relative to the norm.
   * It is wrong for the errors that matter most, which are systematic in the everyday sense: cheap, natural, frequent fallacies. Those are short variants of valid patterns, often subsidized by them (§4.4 (d3)).
   * It also costs rare valid rules and, worse, rarely-exercised guards (Prop 4.4). The learner can end up *less* sound than its teacher.
2. **The good $c$ cannot be found from imitation data** (Thm 4.3). Every data-fit criterion targets the teacher's channel. Choosing $c$ is a normative act, not an estimate.
3. **Private randomness is fragile.** The defence holds only if inputs carry no other labelled behaviour of the same human (Prop 2.6). A whole-document imitator learns each human's systematic errors in context, at a per-block price.

**What does the normativity work.** His own list, read through these results:
* (ii) "a simplicity prior defined in terms of existing understanding" helps only if existing understanding does *not* make human errors cheap (§4.4 (d6)).
* (iii) "specifying properties of the notion" is decisive. Postulates are a separate channel, avowal rather than performance, and they kill high-rate fallacies at every $c$ (Prop 5.4).
* (iv) "what is this person trying to teach me" corresponds to a teacher model with a competence/performance split. The Armstrong–Mindermann theorem warns that simplicity alone does not identify such splits: for irrational agents, the degenerate planner–reward decompositions are simpler (Armstrong & Mindermann 2018, NeurIPS, "Occam's razor is insufficient to infer the preferences of irrational agents" **(unverified details)**). This is Thm 4.1 in another guise.
* His chair remark ("should the person who taught me consider it a chair") is, in these terms, the claim that the target is *not a function of $P^*$*. Thm 4.1(iv) makes that literal: no amount of imitation data fixes it.

**The division of labour** (Thm 5.2), as a one-line slogan:
* simplicity removes the *expensive* errors;
* coherence removes the *incoherent* ones;
* world feedback removes the *refutable* ones;
* postulates remove those that *violate the notion's avowed properties*;
* what survives is the cheap, frequent, coherent, empirically adequate alternatives. Those are alternative meanings humans actually use, such as "if" as "iff" in closed worlds. For these, deciding that they are errors is itself a normative decision outside the data. It may sometimes be wrong: conditional perfection is arguably part of the meaning of everyday "if".

**Depth, honestly.**
* *TOSU or standard:* Lemma 1.2, Thm 2.1, Prop 2.2, Prop 2.3, Lemma 3.1, Thm 3.2, Thm 4.1, Thm 4.3, Thm 5.2, Prop 5.4. Their value is the precise statement of when the user's proposal works.
* *Mildly new, as far as I know:* the product-model structure function and the kink theorem (Thm 2.5), proved with Fourier list-decoding plus the coding theorem; the idealized rate-threshold theorem with arbitrary hypotheses (Thm 3.3); and the all-shapes corollary for product hulls (Cor 3.4).
* *Conceptually most useful:*
  * guard erosion (Prop 4.4);
  * coherence repair by sacrifice (Prop 5.3), which refines T2 Thm 6.1;
  * block-level universality (Prop 2.6), which is both a real pathology for LLM-style imitation and an argument for step-level checkers.

---

## 7. Open problems

1. **Kinks beyond parities.** Which classes of simple models are "product-kinked", i.e. have product frontiers well above the chord below $K(f)$? Parities are via list-decoding. Is there a general criterion (a local list-decodability or agnostic-learning hardness condition) under which partial descriptions give negligible per-input advantage? Low-degree polynomials and juntas are natural next cases. Majority-like functions are *not* kinked, since short approximations exist.
2. **A product-model algorithmic statistics.** Develop $\rho^\times$ systematically:
   * its relation to $h_x$;
   * a "product sufficiency" notion;
   * whether $\rho^\times$ of natural data has vertices at "meaningful" models;
   * a realizability theorem for $\rho^\times$ itself, not just its hull.
3. **Data-free choice of $c$.** Is there a principled $c$ from the *learner's* side, e.g. $c$ equal to the rate of the cheapest postulate-violating error, or a minimax-regret choice over the worlds of Thm 4.1(iv)?
4. **Competence/performance models.** Teacher = norm + resource-bounded evaluation. Under what assumptions on the performance model (e.g. errors as time-bounded shortcuts) does joint MDL identify the competence? Armstrong–Mindermann suggests this needs assumptions beyond simplicity. Which minimal assumption suffices?
5. **Witness richness.** Valid dominance (Thm 5.2) holds when witness families are rich, as in CPC, where Post witnesses are abundant (T2 Cor 6.2). Quantify $\beta(F)$ for natural calculi. Is there a coherence analogue of the coupon-collector rates of T1 Thm 5.3?
6. **Block granularity.** Characterize the optimal block size for a step imitator: the largest context that still prices persona mixtures per step.

## 8. Suggested experiments

1. *Kink in practice.* Train small networks (or enumerate circuits) on parity-plus-random-errors and on majority-plus-random-errors. Plot achievable (size, log-loss) frontiers under per-example noise versus a sequence model with shared latent noise. Prediction: a kink for parity, none for majority.
2. *Rate inversion in a rule learner.* Use the c4 setup with real proof corpora (Metamath or Lean step data) with injected fallacies at measured human rates. Check the predicted order in which rules and fallacies enter as $c$ falls.
3. *Guard erosion.* Algebra-rewrite imitation with guarded cancellation. Measure, as $c$ varies, the guard drop and the subsequent derivation of $1=0$ by a prover (T1-style adversarial search).
4. *Block universality.* Train two imitators of proof steps, one with per-step inputs and one with whole-document context, on corpora where some authors have consistent idiosyncratic errors. Prediction: only the document-context model reproduces author-specific errors, with a per-document cost.
5. *Postulate rescue.* Freshman's-dream imitation, with and without four numeral postulates designated. Prediction: elimination at every $c$ with postulates, and survival for $c<\rho_{\rm FD}$ without.

---

## References

✓ = believed accurate; (u) = unverified detail.

* Armstrong, S., Mindermann, S. (2018). Occam's razor is insufficient to infer the preferences of irrational agents. NeurIPS. (u)
* Barron, A., Cover, T. (1991). Minimum complexity density estimation. *IEEE Trans. IT* 37(4):1034–1054. ✓ (multiplier conditions u)
* Bhattacharya, A., Pati, D., Yang, Y. (2019). Bayesian fractional posteriors. *Ann. Statist.* 47(1). (u)
* Bissiri, P., Holmes, C., Walker, S. (2016). A general framework for updating belief distributions. *JRSS-B* 78(5). ✓
* Carnap, R. (1952). Meaning postulates. *Philosophical Studies* 3:65–73. ✓
* Catoni, O. (2007). *PAC-Bayesian Supervised Classification: The Thermodynamics of Statistical Learning*. IMS Lecture Notes 56. ✓
* Gács, P., Tromp, J., Vitányi, P. (2001). Algorithmic statistics. *IEEE Trans. IT* 47(6):2443–2463. ✓
* Gneiting, T., Raftery, A. (2007). Strictly proper scoring rules, prediction, and estimation. *JASA* 102:359–378. ✓
* Grünwald, P. (2007). *The Minimum Description Length Principle*. MIT Press. ✓
* Grünwald, P. (2012). The safe Bayesian: learning the learning rate via the mixability gap. ALT 2012. ✓
* Grünwald, P., van Ommen, T. (2017). Inconsistency of Bayesian inference for misspecified linear models, and a proposal for repairing it. *Bayesian Analysis* 12(4). ✓
* Kolmogorov, A. N. (1974). Talk at the Information Theory Symposium, Tallinn (structure function; unpublished; as reported by Cover and by Vereshchagin–Vitányi). ✓
* Li, M., Vitányi, P. *An Introduction to Kolmogorov Complexity and Its Applications* (3rd ed. 2008). ✓
* Lieberman, E., Michel, J.-B., Jackson, J., Tang, T., Nowak, M. (2007). Quantifying the evolutionary dynamics of language. *Nature* 449:713–716. ✓ (exponent u)
* Rissanen, J. (1978). Modeling by shortest data description. *Automatica* 14:465–471. ✓
* Shtarkov, Y. (1987). Universal sequential coding of single messages. *Problems Inform. Transmission* 23(3). ✓
* Vereshchagin, N., Vitányi, P. (2004). Kolmogorov's structure functions and model selection. *IEEE Trans. IT* 50(12):3265–3290. ✓ (exact realizability side conditions u)
* Vereshchagin, N., Vitányi, P. (2010). Rate distortion and denoising of individual data using Kolmogorov complexity. *IEEE Trans. IT* 56(7):3438–3454. ✓
* Vereshchagin, N., Shen, A. (2017). Algorithmic statistics: forty years later. In *Computability and Complexity*, LNCS 10010. ✓
* Zhang, T. (2006). From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation. *Ann. Statist.* 34(5):2180–2210. (u)
* Project memos: T1 (Prop 2.3, Thm 4.2, Thm 5.3, Thm 6.4, Cor 6.5), T2 (Lemma 2.1, Thm 3.1, Thm 3.8, Thm 6.1, Cor 6.2, Prop 6.3, Thm 6.4, §6 examples), L4 §7, L11 (Lemma 2.1, Prop 2.2).
