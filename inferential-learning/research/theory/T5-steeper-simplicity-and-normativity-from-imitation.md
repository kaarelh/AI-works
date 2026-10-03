# T5. Steeper simplicity and normativity from imitation

*Theory thread T5 of the inferential-learning project. Read `../00-brief.md` first. The thread develops the user's own proposal from `philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md`, especially its "messy notes": function induction with private per-input randomness, loss $\lambda K(h)+\sum_i \mathrm{NLL}_i$ with $\lambda>1$ growing with $N$, his worked example, and his convex-hull argument. It builds on T1 (`T1-soundness-under-search.md`) and T2 (`T2-coherence-as-negative-data.md`) and cites their theorem numbers. Scripts are in `theory/T5-checks/` (c1–c5, plus `repair_checks.py`, added after verification; see the Verification log at the end).*

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
   * The sequence pathology is exact: the universal semimeasure $M$ beats every $\nu$ of complexity above $c_M+O(1)/(\lambda-1)$, where $c_M$ is the length of $M$'s own description (Prop 2.3).
   * *Kink theorem* (Thm 2.5, revised after verification). Take a parity "simple model" with a random error set.
     * Shared-randomness (set/mixture) models have total code length **flat** in model complexity, up to $O(\log d)$. This is the user's "1 bit pays for 1 bit". So every $\lambda>1$ selects a mixture that knows at most $\frac{\lambda}{\lambda-1}O(\log d)$ bits of the simple model: essentially the zero-knowledge class mixture, and exactly that mixture in the computable version.
     * A product (private-randomness) model that is missing $m$ of the simple model's $d$ bits has risk at least $1-2^{-m/2+O(\log d)}$ bits/sample, up to a slack. The slack is $O(\sqrt{p\log n/n})$ for a typical (incompressible) error set, and $\le 2p/\ln2$ for every error set.
     * So partial knowledge buys exponentially little per input, and the product frontier has the kink he hoped for at the simple model. The proof uses Fourier list-decoding plus the coding theorem.
   * **But** if a hypothesis's input contains earlier labelled steps by the same human (a proof document, an LLM context), the function hypothesis can be an in-context Bayes mixture. It then pays $\log(1/w)$ **per block**, not per input (Prop 2.6).
   * A single $O(1)$-bit "copy this human's earlier errors" hypothesis then learns idiosyncratic errors that no component-wise analysis would admit [computed: c5].
2. **Rate thresholds and the convex hull.**
   * Lemma 3.1: as $c=\lambda/N$ varies, the minimizers of $c\,\ell(h)+R(h)$ trace the lower convex hull of achievable (description length, risk) points. A *point* is the unique minimizing point on an open $c$-interval iff it is a hull *vertex*. A *hypothesis* is the unique minimizer there iff, in addition, no other hypothesis sits at that vertex. This confirms his convex-hull reasoning and his "point where the derivative changes".
   * For separable components (disjoint input regions), component $j$ is selected iff its **rate** $r_j/k_j$ exceeds $c$ (Thm 3.2).
   * An idealized Kolmogorov-complexity version is proved with explicit $O(\log)$ slack, with *arbitrary* hypotheses allowed, for independent parity components (Thm 3.3; the constants in its identification clause were corrected after verification).
   * Every convex decreasing piecewise-linear frontier with total drop at most one bit is realizable, up to an $O(m\log d)$ horizontal band. So any such shape is realizable after its edge lengths are scaled up (Cor 3.4). This is the analogue of Vereshchagin–Vitányi's "all shapes" theorem.
   * His worked example is verified. In the rigorous parity version (Thm 3.5, Cor 3.5a), for $c\in(\approx 1/n,\ \approx(1-H(p))/d)$:
     * the good model attains the optimum up to slack;
     * every near-optimal hypothesis correlates strongly with the simple model and memorizes almost none of the errors.
     
     With his numbers the window is $c\in(1.12\cdot10^{-6},\,8.99\cdot10^{-3})$, a factor of about 8000 [computed: c1, c2].
3. **Pathologies (each proved).**
   * (a) *Rate blindness.* Selection depends only on the teacher's channel. So a valid component whose rate is at most that of an error component cannot be kept without the error. The exceptions are exact ties and, in the idealized setting, the $O(\log)$ slack bands (Thm 4.1).
   * (b) Cheap frequent fallacies (affirming the consequent, the freshman's dream) have rates comparable to genuine rules. In a toy calculus, affirming the consequent outranks proof-by-cases, reductio and ex falso (Prop 4.2).
   * (c) The good window is **not identifiable from imitation data**. Held-out log-loss, and every strictly proper score, prefers the teacher's own channel, errors included. So cross-validation picks the error-memorizing end (Thm 4.3). On my reading, which I have not checked against the papers, SafeBayes's learning-rate selection behaves the same way. More generally, no imitation-only criterion, proper or not, is right in every world (Thm 4.3(iii)).
   * (d) Further pathologies:
     * *guard erosion*: when a guard's rate is below that of the unguarded schema, steeper simplicity deletes the rarely exercised but valid side condition. That makes the learner **less sound than the teacher** (Prop 4.4);
     * coarse *error envelopes* are learned at their own (high) rate (Prop 4.5);
     * *parasitic* errors that are cheap given a valid rule (non-additivity). A valid rule may even be kept only because of the error it subsidizes;
     * dependence of rates on the reference language and on the input distribution;
     * in-context universality (Prop 2.6).
4. **Inference rules and the division of labour.**
   * In situation-typed step imitation, rule selection is again a rate threshold.
   * Coherence (T2) and world feedback act as down-closed feasibility constraints. Under *error-independence* and *valid dominance* (Thm 5.2):
     * the surviving errors are exactly those with rate $>c$ that are coherent with, and empirically adequate relative to, the **valid rules the learner actually kept**;
     * the lost valid rules are exactly those with rate $\le c$.
   * So simplicity removes low-rate (expensive or idiosyncratic) errors; coherence removes incoherent ones regardless of rate; world feedback removes refutable ones. The residue is the cheap, frequent, coherent, empirically adequate alternatives, i.e. T2 Thm 6.4's alternative meanings *that humans actually use*.
   * Without valid dominance, the optimizer repairs incoherence by **sacrificing the valid rule that exposes the fallacy** (Prop 5.3) [computed: c4].
   * Meaning postulates ("1+1=2 won't be true if you assign 1→rabbit, 2→chicken") are feasibility constraints from a second channel: *avowal* rather than *performance*. They are rate-independent in the sense that they exclude a fallacy however high its rate, provided the valid rules in its witness out-rate it and are therefore kept. They are what rescue the cheap-fallacy case (Prop 5.4).
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
* A **shared-randomness hypothesis** is a distribution $P(y_{1:N}\mid x_{1:N})$ on label sequences.
  * The *causally conditioned* special case is a program that reads one random tape across all inputs, as in sequence-Solomonoff on the interleaving $x_1y_1x_2y_2\dots$. There $y_i$ may depend only on $x_{\le i}$ and $y_{<i}$.
  * A general $P(y_{1:N}\mid x_{1:N})$ may also depend on future inputs, so the two classes differ.
  * For a single fixed input sequence $x_{1:N}$ they coincide by the chain rule, and that is all §2 uses.
* A **block model** sits between the two. Data come in blocks, such as documents or proofs by one human. The hypothesis's input at position $i$ of a block includes the block's earlier pairs, so randomness is shared within a block and private across blocks.

### 1.3 Objectives

* **The user's loss** is $\mathcal L_\lambda(h)=\lambda\,\ell(h)+\sum_{i\le N}-\log_2 h(y_i\mid x_i)$, with $\lambda>1$ growing with $N$.
  * Write $\lambda=cN$. Dividing by $N$ gives the per-sample objective
  $$\hat J_c(h)=c\,\ell(h)+\hat R_N(h),\qquad J_c(h)=c\,\ell(h)+R(h),\qquad R(h)=\mathbb E_{x\sim D}\mathbb E_{y\sim P^*(\cdot|x)}[-\log_2h(y\mid x)].$$
  * Set $\Phi(c)=\inf_hJ_c(h)$. Here $R$ is in bits per sample and $c$ is in "bits per sample per bit of description".
* **Two versions.**
  * *(Idealized)* $\ell(h)=K(h):=\min\{|p|:p\text{ computes }h\}$, the prefix complexity of $h$. A shortest such $p$ is written $h^*$. Hypotheses are total programs with rational outputs.
    * Three results compare members of this class with objects outside it: Prop 2.3 ($M$), Thm 2.4 ($m$), and Prop 2.6 for infinite persona families ($h_w$, whose outputs are infinite sums).
    * For those results the class is **enlarged** to lower-semicomputable (semi)measures and computable real-valued predictors. $K(\cdot)$ is then the length of a shortest program that lower-semicomputes, or computes, the object.
    * Nothing else in the file uses the enlarged class.
  * *(Computable)* $\ell$ is a prefix code on a countable class $\mathcal H$, with $\sum_h2^{-\ell(h)}\le1$. Examples are rule calculi with an MDL code, or finite hypothesis lists.
* **Rates.** If adding a "component" to a hypothesis costs $k$ bits and lowers $R$ by $r$, its **rate** is $r/k$. Rates are what $c$ is compared against.

**Lemma 1.2 (empirical selection tracks population selection) [proved].** Suppose every $h\in\mathcal H$ has a noise floor $h(y\mid x)\ge2^{-B}$, so losses lie in $[0,B]$. Then with probability $\ge1-\delta$, simultaneously for all $h$:
$$|\hat R_N(h)-R(h)|\le \varepsilon_N(h):=B\sqrt{\big(\ell(h)\ln2+\ln(2/\delta)\big)/(2N)}.$$
Let $\hat h$ minimize $\hat J_c$, and let $h_0$ be any fixed hypothesis. Then, on the same event,
$$J_c(\hat h)\le\Phi(c)+2B\sqrt{\big((\ell(h_0)+B/c)\ln 2+\ln(2/\delta)\big)/(2N)}.$$
If the population minimizer is unique with gap $\gamma>0$, then $\hat h$ equals it once the right-hand bound is below $\gamma$.

*Proof.*
* Both minimizers exist. By Kraft, $\{h:\ell(h)\le L\}$ has at most $2^L$ elements. Any $h$ with $\ell(h)>\ell(h_0)+B/c$ has $J_c(h),\hat J_c(h)\ge c\ell(h)>c\ell(h_0)+B\ge J_c(h_0),\hat J_c(h_0)$. So both infima are minima over a finite set.
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
where $Q_{x}$ is the law of $f(x)$ under $f\sim Q$.
  * The exact minimax value over product $h$ is $\max_Q\sum_iH(Q_{x_i})$ (revised after verification).
  * The hypothesis $h(\cdot\mid x)=\mathrm{Unif}(F(x))$ attains $\sum_i\log|F(x_i)|$ against every $f$, so the value is at most that.
  * It equals $\sum_i\log|F(x_i)|$ iff some $Q$ has uniform marginals on every $F(x_i)$, and that hypothesis is needed. For example, $F=\{(a,a),(a,b),(b,a),(c,a)\}$ on two inputs has value $2.5431<\log_23+1=2.5850$ [computed: repair_checks].
  * A uniform-marginal $Q$ exists for parities. More generally it exists whenever a group $G$ acts on $F$ by $(g\cdot f)(x)=\sigma_{g,x}(f(x))$, for permutations $\sigma_{g,x}$ of $Y$, and the induced action on each $F(x)$ is transitive. Then $Q=\mathrm{Unif}(F)$ works. (A group acting transitively on $F$ alone does not suffice.)
* **(ii)** For shared-randomness models, $\min_P\max_f-\log P(f(x_{1:N}))=\log|\{f(x_{1:N}):f\in F\}|\le\log|F|$ (Shtarkov 1987 [known]).

*Proof.*
* (i) $\max_f\ge\mathbb E_{f\sim Q}$. Also $\mathbb E_{f\sim Q}[-\log h(f(x)\mid x)]=H(Q_x)+\mathrm{KL}(Q_x\|h(\cdot|x))\ge H(Q_x)$, with equality at $h(\cdot|x)=Q_x$.
  * Repeated inputs are consistent with this, since the optimal $h(\cdot|x)$ depends only on $x$.
  * The minimax value follows from Sion's theorem applied to $h$ with full support on each $F(x)$ (the set of such $h$ is convex, the loss is convex in $h$ and linear in $Q$), and then letting the support floor tend to $0$.
  * The uniform hypothesis gives loss $\log|F(x)|$ on every $f$.
  * Under the group condition, $Q_x$ is invariant under the $\sigma_{g,x}$, which act transitively on $F(x)$. So $Q_x$ is uniform on $F(x)$.
* (ii) $P=$ uniform over the distinct labelings is optimal: the labelings are disjoint events, so some labeling has $P\le1/\#$. ∎

*Example* [computed: c2(a)]. Take parities on $\{0,1\}^{10}$ and $N=200$ inputs. The function mixture pays 200.0 bits. The Bayes (shared-randomness) mixture pays 10.0 bits.

**Proposition 2.2 (weighted form) [proved; known].** Let $\mathcal Q$ be countable with weights $w$. Put $\xi_{\rm fun}(y\mid x)=\sum_qw_qq(y\mid x)$ and $\xi_{\rm seq}(y_{1:N}\mid x_{1:N})=\sum_qw_q\prod_iq(y_i\mid x_i)$. Then:
* per input, $-\log\xi_{\rm fun}(y\mid x)\le\min_q[\log\frac1{w_q}-\log q(y\mid x)]$, so $\xi_{\rm fun}$ pays $\log(1/w)$ **at every input**;
* $-\log\xi_{\rm seq}(y_{1:N}\mid x_{1:N})\le\min_q[\log\frac1{w_q}+\sum_i-\log q(y_i\mid x_i)]$, so $\xi_{\rm seq}$ pays it **once**.

Both bounds are tight. With $\mathcal Q=\{\text{const }0,\text{const }1\}$ and $w=\frac12$, on $N$ ones $\xi_{\rm fun}$ pays $N$ bits and $\xi_{\rm seq}$ pays 1. The chain-rule conditionals of $\xi_{\rm seq}$ depend on past labels. That dependence *is* the shared randomness.

*Proof.* Drop all but one term in each sum. ∎

**Proposition 2.3 (the sequence pathology, exactly) [proved, from known dominance].** Let $M$ be a universal lower-semicomputable conditional semimeasure on label sequences. Then $M\ge2^{-K(\nu)-c_0}\nu$ for every computable $\nu$ (Solomonoff–Levin [known]). Then for every $\lambda>1$ and all data,
$$\lambda K(M)-\log M(y_{1:N}\mid x_{1:N})\ \le\ \lambda c_M+K(\nu)+c_0-\log\nu(y_{1:N}\mid x_{1:N}),$$
which is below $\nu$'s own objective whenever $(\lambda-1)K(\nu)>\lambda c_M+c_0$. Here $c_M:=K(M)$ is the length of a shortest program lower-semicomputing $M$ (the enlarged class of §1.3).
* So for any fixed $\lambda>1$, every hypothesis of complexity $>(\lambda c_M+c_0)/(\lambda-1)=c_M+(c_M+c_0)/(\lambda-1)$ loses to $M$.
* As $\lambda\to\infty$ this threshold tends to $c_M$, not to $0$. Hypotheses simpler than $M$ itself are not beaten.
* $M$ learns the errors as data accumulate, since its predictive is the Bayes posterior.
* A computable stand-in that stays inside the class of §1.3 is the mixture $P_u$ of Thm 2.5(a). ∎

**Theorem 2.4 (in the function case "universal" hypotheses are just fixed predictors) [proved].**
* For a fixed product hypothesis $h$ and i.i.d. data, $\hat R_N(h)\to R(h)$ a.s. (SLLN), a number that does not depend on the data. Nothing a product hypothesis does can make its per-sample loss improve with $N$.
* In particular, the universal *conditional* semimeasure $m(y\mid x)\asymp2^{-K(y|x)}$ is one fixed predictor. For binary $Y$, $m(y\mid x)\ge2^{-\kappa_U}$ for both labels, so $m(y\mid x)\le1-2^{-\kappa_U}$. Hence
$$R(m)\ \ge\ \log_2\frac1{1-2^{-\kappa_U}}\ >\ 0\quad\text{for every teacher},$$
with $\kappa_U$ a constant of the reference machine.
* So the per-input universal mixture is a fixed predictor whose odds are bounded by a machine constant. ($m(\cdot\mid x)$ varies with $x$, within the bounded ratio $2^{\kappa_U}$.) It beats the good model only if $R(\text{good})+c\,\ell(\text{good})\ge R(m)$.
* $m$ is a lower-semicomputable semimeasure, so it belongs to the enlarged class of §1.3.

*Proof.* SLLN. For the second claim, use $K(y\mid x)\le K(y)+O(1)=O(1)$ for $y\in\{0,1\}$ and $m(0|x)+m(1|x)\le1$. ∎

### 2.2 The kink

Fix the following setting, which is the user's example made rigorous.
* $X=\{0,1\}^d$, $n=2^d$, $D$ uniform.
* The simple model is $f_a(x)=\langle a,x\rangle\bmod2$, with $K(a)\ge d$ (a random $a$).
* An error set $E\subseteq X$ with $|E|=pn$ and $p<1/4$.
* The teacher is $y^*=f_a\oplus1_E$.
* Write $L_E=\log_2\binom n{pn}$. By Stirling, $L_E/n=H(p)-O(\log n/n)$; more precisely $nH(p)-\log_2(n+1)\le L_E\le nH(p)$.
* Let $\delta_E:=L_E-K(E\mid a,K(a))\ge -O(\log n)$, the randomness deficiency of $E$ given $a$; it is small for most $E$.
* For a product hypothesis $h$, put $s_h(x)=h(0|x)-h(1|x)$, $\chi_{a'}(x)=(-1)^{\langle a',x\rangle}$ and $\hat s_h(a')=\mathbb E_x[s_h\chi_{a'}]$.
* *Assumption on $p$ (added after verification).* We assume $K(p)=O(\log d)$, e.g. $p=2^{-k}$, and absorb it into $\kappa'$ below.
  * Otherwise $K(p)\le K(|E|)+O(\log d)$ can be of order $d$, and then "the good model costs about $d$ bits" fails.
  * A learner can always replace $p$ by a nearby simple $\tilde p$, at risk cost $\mathrm{KL}(p\|\tilde p)$.

**Lemma 2.5a (list decoding) [proved; standard].** For $t\in\mathbb N$, $|\{a':\hat s_h(a')\ge2^{-t}\}|\le2^{2t}$. Hence if $\hat s_h(a)\ge2^{-t}$, then $K(a\mid h^*)\le2t+2\log_2(t+1)+2\log_2d+O(1)$.
* Here $h^*$ is a shortest program for $h$. The $2\log_2d$ term supplies $d$, since a program for $h$ need not determine it.
* For real $t\ge0$, apply the lemma to $\lceil t\rceil$.
* The list-size bound is the standard Parseval (Johnson-type) bound for the Hadamard code, as used in Goldreich–Levin (1989) and Kushilevitz–Mansour (1993). Only its combination with the coding theorem is used here.

*Proof.*
* Parseval gives $\sum_{a'}\hat s_h(a')^2=\mathbb E[s_h^2]\le1$.
* Given $h^*$, compute all $\hat s_h(a')$ exactly (finite rational sums) and list those $\ge2^{-t}$.
* Then specify $d$ and $t$ (self-delimiting) and the index of $a$ in the list ($2t$ bits). ∎

**Lemma 2.5b (risk vs correlation) [proved].** $R(h)\ge-\log_2\big(\tfrac{1+\hat s_h(a)}2+p\big)$.

*Proof.*
* Jensen: $R(h)\ge-\log_2\mathbb E_x[h(y^*(x)|x)]$.
* On $X\setminus E$, $h(y^*|x)=h(f_a(x)|x)=\frac{1+s_h(x)\chi_a(x)}2$. On $E$ it is $\le1$.
* So $\mathbb E_x[h(y^*|x)]\le\frac{1+\hat s_h(a)}2+p$. ∎

Lemma 2.5b is tight as a function of $\hat s_h(a)$ alone. An $h$ that is correct on $E$ and has $\hat s_h(a)=0$ attains $\mathbb E_xh(y^*|x)=\frac12+p$. So removing the additive $p$ requires using that $E$ is random relative to $h$.

**Lemma 2.5c (randomness of $E$ removes the $2p$ slack) [proved; added after verification].** Put $\sigma_h:=s_h\chi_a\in[-1,1]$, so $\hat s_h(a)=\mathbb E_x\sigma_h$. For every product $h$,
$$R(h)\ \ge\ 1-\log_2\big(1+(1-2p)\,\hat s_h(a)+\varepsilon_h\big),\qquad \varepsilon_h:=\sqrt{32\ln2\cdot p\,\big(\delta_E^++K(h)+\kappa_n\big)/n}.$$
Here $\delta_E^+=\max(\delta_E,0)$ and $\kappa_n:=\log_2n+2\log_2(\log_2n+2)+\kappa=O(\log n)$.

*Proof.*
* *Exact identity.* Always $h(y\mid x)\le\frac{1+s_h(x)(-1)^y}2$. Also $(-1)^{y^*(x)}=\chi_a(x)(1-2\cdot1_E(x))$. By Jensen, $R(h)\ge-\log_2\mathbb E_xh(y^*|x)$, and
  $$\mathbb E_xh(y^*|x)\ \le\ \tfrac12+\tfrac12\hat s_h(a)-\tfrac1n\textstyle\sum_{x\in E}\sigma_h(x),$$
  with equality when $h(0|x)+h(1|x)=1$.
* *Reduction.* Let $\eta_0:=\big|\frac1{pn}\sum_{x\in E}\sigma_h(x)-\hat s_h(a)\big|$, the deviation of $E$'s average of $\sigma_h$ from the population average. Then $\mathbb E_xh(y^*|x)\le\frac12+\frac{1-2p}2\hat s_h(a)+p\eta_0$, so it suffices to show $2p\eta_0\le\varepsilon_h$.
* *Small deviations.* If $\eta_0<1/n$, then $2p\eta_0<2p/n\le\varepsilon_h$.
* *Counting.* For $\eta>0$, let $B_\eta$ be the set of $pn$-subsets $E'\subseteq X$ with $\big|\frac1{pn}\sum_{E'}\sigma_h-\hat s_h(a)\big|\ge\eta$. Since $\sigma_h$ takes values in an interval of length 2, Hoeffding's inequality for sampling without replacement (Hoeffding 1963, §6) gives $|B_\eta|\le2e^{-pn\eta^2/2}\binom n{pn}$.
* *Coding.* Otherwise pick $\eta=2^{-k}$ with $\eta\le\eta_0<2\eta$ and $-1\le k\le d$.
  * $B_\eta$ is computable from $h^*$, $a$ (whose length gives $d$), $pn$ and $k$. So $K(E\mid a,h^*)\le\log_2|B_\eta|+\kappa_n\le L_E-\frac{pn\eta^2}{2\ln2}+\kappa_n$.
  * Also $L_E-\delta_E=K(E\mid a,K(a))\le K(E\mid a)+O(1)\le K(h^*)+K(E\mid a,h^*)+O(1)$, and $K(h^*)=K(h)+O(1)$.
  * Combining (with $\kappa$ absorbing the constants), $\frac{pn\eta^2}{2\ln2}\le\delta_E+K(h)+\kappa_n$.
  * Hence $\eta_0^2<4\eta^2\le8\ln2\,(\delta_E^++K(h)+\kappa_n)/(pn)$, i.e. $2p\eta_0<\varepsilon_h$. ∎

[computed: repair_checks] The identity holds to machine precision. For random $E$ with $d=12$ and $p\in\{1/64,0.15,0.2,0.24\}$, the observed $\eta_0$ is $\le0.08$, and the bound $\frac12+\frac{1-2p}2\hat s+p\eta_0$ is never violated.

**Theorem 2.5 (kink: shared vs private randomness) [proved; (a), (b), (c) revised after verification].** There is a machine constant $\kappa$ such that the following hold. Write $\kappa'=O(\log d)$ for the cost of $d$, $u$ and $p$ (using $K(p)=O(\log d)$).
* **(a) Shared randomness has (almost) no kink.** For each $u\in\{0..d\}$ let $P_u$ be the uniform mixture, with shared randomness, of the $2^u$ parities agreeing with $a$ on its first $d-u$ coordinates, each with i.i.d. flip-$p$ noise. Then
  $$d-u-\kappa'\ \le\ K(P_u)\ \le\ d-u+\kappa',\qquad u+nH(p)-o(1)\ \le\ -\log P_u(y^*)\ \le\ u+nH(p).$$
  * So the total $K(P_u)-\log P_u(y^*)$ equals $d+nH(p)$ up to $\pm(\kappa'+o(1))$ for every $u$: it is flat.
  * Within the family $\{P_u\}$, the objective $\lambda K(P_u)-\log P_u(y^*)$ is minimized at some $u^*$ with
  $$d-u^*\ \le\ \tfrac{\lambda}{\lambda-1}\,\big(2\kappa'+o(1)\big).$$
  * So every $\lambda>1$ selects a mixture that knows only $O(\frac{\lambda}{\lambda-1}\log d)$ bits of $a$: essentially the zero-knowledge class mixture.
  * For $\lambda-1\lesssim(\log d)/d$ this says nothing.
  * In the computable version, where $P_u$ has the explicit code length $d-u$, the totals are exactly flat and every $\lambda>1$ selects $u=d$ [computed: c2(b)].
* **(b) Private randomness has a kink.** For every product $h$ and every $t\in\mathbb N$:
  $$K(h)\le d-2t-2\log_2(t+1)-2\log_2d-\kappa\ \Longrightarrow\ R(h)\ \ge\ 1-\log_2(1+\beta_t)\ \ge\ 1-\frac{\beta_t}{\ln2},$$
  $$\beta_t:=\min\big\{\,2^{-t}+2p,\ \ (1-2p)2^{-t}+\varepsilon_E\,\big\},\qquad \varepsilon_E:=\sqrt{32\ln2\cdot p\,(\delta_E^++d+\kappa_n)/n}=O\Big(\sqrt{p(\delta_E^++\log n)/n}\Big).$$
  The good model $h_{\rm good}$ (namely $f_a$ with flip-$p$ noise) has $K\le d+\kappa'$ and $R=H(p)$.
  * The first term of $\beta_t$ holds for every $E$. It exhibits a kink only where $1-2p/\ln2>H(p)$, i.e. for $p<0.1421$ [computed: repair_checks].
  * The second term uses the incompressibility of $E$. It exhibits a kink for every $p<1/4$ once $\varepsilon_E$ is small, i.e. for $n$ large and $\delta_E=O(\log n)$.
  * For example, at $p=0.2$ and $\delta_E=0$ (and $\kappa=0$ for illustration), $\varepsilon_E=1.4\cdot10^{-2}$ at $d=20$ and $1.9\cdot10^{-5}$ at $d=40$, against $2p=0.4$.
* **(c) The error segment.** For every product $h$:
  $$K(h)+nR(h)\ \ge\ d+L_E-\delta_E-2\log_2d-\kappa.$$
  The error-memorizing model $h_{\rm bad}=f_a\oplus1_E$ has $K\le d+L_E+O(\log n)$ and $R=0$.

*Proof.*
* (a) The upper bound on $K(P_u)$ holds because $P_u$ is computable from the $d-u$ known bits plus $d$, $u$ and $p$.
  * The true parity is a mixture component of weight $2^{-u}$. Its likelihood is exactly $(1-p)^{n-pn}p^{pn}=2^{-nH(p)}$, because $|E|=pn$. This gives the upper bound on $-\log P_u(y^*)$.
  * Every other component $f_{a'}$ disagrees with $y^*$ on $w\ge n/2-pn$ points, since $f_a\oplus f_{a'}$ has weight $n/2$. Its likelihood is therefore $2^{-nH(p)}(p/(1-p))^{w-pn}\le2^{-nH(p)}(p/(1-p))^{n(1/2-2p)}$. So the $o(1)$ is at most $\log_2\big(1+2^u(p/(1-p))^{n(1/2-2p)}\big)$, which is super-exponentially small. It is below $2^{-2800}$ bits already at $d=10$, $p=1/64$ [computed: repair_checks].
  * *Lower bound on $K(P_u)$.* Given a program for $P_u$ and $(d,u)$, compute the $a'$ maximizing $P_u(f_{a'})$.
    * Every $a'$ with the true $(d-u)$-prefix has $P_u(f_{a'})\ge2^{-u}(1-p)^n$.
    * Every other $a'$ is at Hamming distance $n/2$ from all components, so $P_u(f_{a'})=(p(1-p))^{n/2}$. This is smaller because $\frac n2\log_2\frac{1-p}p>d\ge u$.
    * So the argmax has the true prefix. Then $d\le K(a)\le K(P_u)+u+O(\log d)$.
  * *Selection.* $\lambda K(P_u)-\log P_u(y^*)\ge\lambda(d-u-\kappa')+u+nH(p)-o(1)$, while the value at $u=d$ is $\le\lambda\kappa'+d+nH(p)$. A minimizer $u^*$ therefore satisfies $(\lambda-1)(d-u^*)\le2\lambda\kappa'+o(1)$.
* (b) Suppose $\hat s_h(a)\ge2^{-t}$. Then, by Lemma 2.5a, $d\le K(a)\le K(h)+K(a\mid h^*)+O(1)\le K(h)+2t+2\log_2(t+1)+2\log_2d+O(1)$. This contradicts the hypothesis once $\kappa$ exceeds the $O(1)$. So $\hat s_h(a)<2^{-t}$.
  * Lemma 2.5b gives $R(h)\ge-\log_2(\frac12+2^{-t-1}+p)=1-\log_2(1+2^{-t}+2p)$.
  * Lemma 2.5c, with $K(h)\le d$ and $1-2p>0$, gives $R(h)\ge1-\log_2(1+(1-2p)2^{-t}+\varepsilon_E)$.
  * Finally, $\log_2(1+z)\le z/\ln2$.
* (c) Several steps:
  * $P_h(y):=\prod_xh(y_x|x)$ is a (semi)distribution on $\{0,1\}^n$ computable from $h^*$ **and $d$**. A program for $h$ need not determine $d$, as in Lemma 2.5a.
  * By the conditional coding theorem, $K(y^*\mid h^*,d)\le-\log P_h(y^*)+O(1)=nR(h)+O(1)$. So $K(y^*)\le K(h)+nR(h)+2\log_2d+O(1)$ (revised: the $2\log_2d$ term was missing).
  * From $y^*$ one computes $a$: its correlation with $\chi_a$ is $1-2p$, and its correlation with any other $\chi_{a'}$ is $|{-2}\mathbb E[\chi_{a\oplus a'}1_E]|\le2p<1-2p$. Then $E=\{y^*\ne f_a\}$. So $K(a,E)\le K(y^*)+O(1)$.
  * Symmetry of information gives $K(a,E)=K(a)+K(E\mid a,K(a))+O(1)\ge d+L_E-\delta_E-O(1)$. ∎

**Reading (revised after verification).** Part (a) is precisely the user's remark that in the sequence case "it's pretty much just 1 bit paying for 1 bit": the shared-randomness frontier is the sufficiency line, up to $O(\log d)$.

Part (b) is his hope made true, in quantitative form.
* Let $m=d-K(h)$ be the number of missing bits, and take the largest $t$ with $\tau_t:=2t+2\log_2(t+1)+2\log_2d+\kappa\le m$. Then (b) says a product hypothesis has risk at least $1-2^{-m/2+O(\log d)}-\beta_t'$ bits/sample, where $\beta_t'=\min\{2p,\varepsilon_E\}/\ln2$ is the slack.
* So partial knowledge of the simple model buys **exponentially little** per input. The frontier stays near the coin until the model is specified to within $O(\log d)$ bits.
* It is not literally worthless. The c2(b) list mixtures that miss $u$ bits gain $\approx2^{-u}(1-H(p))$ over the coin: $0.454$, $0.221$, $0.110$ bits at $u=1,2,3$ [computed: c2(b), repair_checks].
* The true decay rate therefore lies between $1/2$ and $1$ in the exponent per missing bit. List decoding loses the factor 2.
* His "see some point at which the derivative changes" is exactly this kink. On the scale of $d$ bits the product frontier is flat near the coin and drops at the simple model.

Two caveats.
* The kink is proved only up to $O(\log d)$ bits next to the simple model.
* With the unconditional slack $2p/\ln2$ alone, hypotheses with $K(h)\lesssim2pd/((1-H(p))\ln2)$ are not shown to lie above the coin–good chord. The incompressibility slack $\varepsilon_E$ closes this gap for large $n$.

[computed: c2(b)] For $d=10$, $|E|=16$, $p=1/64$:
* The product list-mixtures have risks $0.116, 0.546, 0.779, 0.890,\dots,0.999$ at $10,9,8,7,\dots,0$ bits.
* The shared-randomness mixtures have total code length $128.9$ bits at every $u$.
* Hulls: the product hull is coin → good → bad. The shared hull is mixture → bad.
* Selection at $\lambda\in\{1.5,4,50\}$: the product family picks the good model; the shared family picks the zero-bit mixture.

### 2.3 Where universality comes back: blocks

**Proposition 2.6 (per-block pricing) [proved; complexity bound and proof revised after verification].** Suppose the hypothesis's input at position $i$ of block $b$ contains the block's earlier pairs, as when the input is "the proof so far". Let $(\nu_\theta)_\theta$ be a *uniformly computable* countable family of "persona" models with computable weights $w$, $\sum_\theta w_\theta\le1$. Each $\nu_\theta(y\mid x,\text{history})$ may depend on the block history. Then the in-context mixture
$$h_w(y\mid x_{b,i},\text{history})=\textstyle\sum_\theta w(\theta\mid\text{history})\,\nu_\theta(y\mid x_{b,i},\text{history}),\qquad w(\theta\mid\text{history})\propto w_\theta\prod_{k<i}\nu_\theta(y_{b,k}\mid x_{b,k},\text{history}_{<k}),$$
is a single function hypothesis with $K(h_w)\le K\big(w,(\nu_\theta)_\theta\big)+O(1)$, the length of a joint description of the weights and the family. On every block,
$$\sum_{i\in b}-\log h_w(y_{b,i}\mid\cdot)\ \le\ \min_\theta\Big[\log\tfrac1{w_\theta}+\sum_{i\in b}-\log\nu_\theta(y_{b,i}\mid\cdot)\Big].$$
* So it pays $\log(1/w)$ **per block**. Blocks of length 1 recover the function case (per input). One block of length $N$ recovers the sequence case (once).
* For a finite family with rational $w$ and rational $\nu_\theta$, $h_w$ has rational outputs, so it is in the class of §1.3.
* For an infinite family its outputs are computable reals, so it is in the enlarged class (or can be truncated at a finite stage).
* For an arbitrary, uncomputable family, $h_w$ need not be computable at all.

*Proof.* Let $Z_i:=\sum_\theta w_\theta\prod_{k<i}\nu_\theta(y_{b,k}\mid\cdot)$.
* The predictive at step $i$ is exactly $h_w(y_{b,i}\mid\cdot)=Z_{i+1}/Z_i$.
* So the product over the block telescopes: $\prod_{i\in b}h_w(y_{b,i}\mid\cdot)=Z_{|b|+1}/Z_1=\sum_\theta w_\theta\prod_i\nu_\theta(y_{b,i}\mid\cdot)\big/\sum_\theta w_\theta$.
* This holds for history-dependent $\nu_\theta$ and for inputs that depend on earlier steps, because everything is conditioned on the realized inputs.
* Since $\sum w\le1$, dropping all but one term gives the bound. (Prop 2.2 is the history-independent special case.) ∎

[computed: repair_checks] With three history-dependent personas over three labels, blocks of length 6, inputs depending on the history, and sub-probability weights, the identity holds to $4\cdot10^{-15}$ over 2000 trials.

*Consequence* [computed: c5]. Suppose a fraction $q=0.2$ of humans each have an *idiosyncratic* systematic error: "in error contexts play wrong move $j$", with $j$ uniform over $2^{16}$ moves.
* Each such rule alone has rate essentially zero: 16 bits, used by a $q2^{-16}$ fraction.
* The copier ("predict this human's own earlier wrong move") is the finite family $\{\text{correct}\}\cup\{\text{persona }j\}_{j<2^{16}}$, described in $O(1)$ bits plus the parameters $(2^{16},q,\eta)$.
* At $K=1$ error context per block it matches a calibrated norm model, which is exactly the per-input pricing.
* It beats the norm model at $K\ge2$: per-context loss $3.03$ vs $4.64$ bits at $K=2$, and $1.33$ vs $4.68$ at $K=16$.
* The norm model is a fixed predictor, so its exact expected loss is $4.635$ bits per error context for every $K$. The $4.52$–$4.76$ spread in c5's column is Monte Carlo noise [computed: repair_checks].

**Design consequence.** The user's private-randomness defence holds only at the granularity at which inputs do not carry other labels. An LLM imitating whole proof documents is a block model. A *step checker* whose input is a single step $(\Pi,j)$, as in T1, is a function model. This is a second, independent argument for T1's architecture.

### 2.4 Answer to "is there a universal hypothesis in the function case?"

* No, provided randomness is private per input and inputs carry no other labels.
  * Every single hypothesis prices mixtures per input (Thm 2.1, Prop 2.2).
  * The universal conditional semimeasure is a fixed, weakly informative predictor (Thm 2.4).
  * Partial knowledge of a simple model buys exponentially little per input until it is complete to within $O(\log d)$ bits. Missing $m$ bits leaves at most about $2^{-m/2+O(\log d)}$ bits/sample of advantage over the coin, plus a slack that is small for incompressible error sets (Thm 2.5(b), revised).
* Yes, at block granularity, as soon as inputs contain labelled history (Prop 2.6).
* The other pathologies he suspected exist, but they are not universality. They are **rate blindness** (§4) and its consequences.

---

## 3. Rate thresholds and the convex hull

### 3.1 The hull

Let $A=\{(\ell(h),R(h)):h\in\mathcal H\}$. With a prefix code, finitely many $h$ have $\ell(h)\le L$; also $R\ge0$. So each $J_c$ attains its minimum.

Let $\mathrm{hull}^-(A)$ be the set of boundary points of $\mathrm{conv}(A+\mathbb R_{\ge0}^2)$ at which some line of slope $-c$ with $c\in(0,\infty)$ supports the set (made precise after verification). This is the lower-left boundary *with finite negative slope*. It excludes the vertical ray above the leftmost vertex and the horizontal ray to the right of the risk-minimal vertex. For instance, in $A=\{(0,1),(1,0),(2,0)\}$ the point $(2,0)$ lies on the boundary but not on $\mathrm{hull}^-(A)$, and it is never a minimizer for $c>0$. A *vertex* of $\mathrm{hull}^-(A)$ is an extreme point of $\mathrm{conv}(A+\mathbb R^2_{\ge0})$ lying in $\mathrm{hull}^-(A)$; vertices belong to $A$.

**Lemma 3.1 [proved; standard].**
* (i) For $c>0$, every minimizer of $J_c$ lies on $\mathrm{hull}^-(A)$, on a supporting line of slope $-c$. Conversely, every $h$ with $P_h\in\mathrm{hull}^-(A)$ minimizes $J_c$ for some $c>0$.
* (ii) *Monotonicity.* Take $c<c'$, with $h$ minimizing $J_c$ and $h'$ minimizing $J_{c'}$. Then $\ell(h)\ge\ell(h')$ and $R(h)\le R(h')$.
* (iii) A point $P\in A$ is the unique minimizing *point* for all $c$ in a nonempty open interval iff $P$ is a vertex of $\mathrm{hull}^-(A)$.
  * The interval is $(s_+,s_-)$, the absolute slopes of the edges to its right and left.
  * $s_-=\infty$ at the leftmost vertex, and $s_+=0$ at the rightmost (risk-minimal) vertex.
  * A *hypothesis* $h$ is the unique minimizer on that interval iff, in addition, no other hypothesis has the same point $P_h$. Hypotheses sharing a vertex are co-minimizers on the whole interval.

*Proof.*
* (i) $J_c(h)=\langle(c,1),P_h\rangle$ is minimized over $A$ exactly where it is minimized over $\mathrm{conv}(A+\mathbb R^2_{\ge0})$. The converse is the definition of $\mathrm{hull}^-$.
* (ii) Add $c\ell(h)+R(h)\le c\ell(h')+R(h')$ to $c'\ell(h')+R(h')\le c'\ell(h)+R(h)$. This gives $(c'-c)(\ell(h')-\ell(h))\le0$, and then the $R$ inequality follows from the first.
* (iii) Only finitely many points of $A$ have $\ell\le L$, and $R\ge0$. So at each vertex the slopes of the two adjacent edges are attained, and they differ. A vertex therefore has an open cone of strictly supporting normals.
  * A non-vertex point of $\mathrm{hull}^-(A)$ lies in the relative interior of an edge. It is a convex combination of the edge's endpoints, which are vertices and hence in $A$.
  * So for every $c$ one of those endpoints is at least as good. ∎

[computed: c3(ii)] 300 random point sets and 400 values of $c$ each: no minimizer off the hull, no monotonicity violation, and every vertex selectable. The on-hull test originally compared the minimum value with the hull's minimum, which is a tautology. It was repaired after verification to test that each minimizer lies on a vertex or edge of the computed hull, and the result is unchanged.

The user's convex-hull argument is therefore correct as stated, with two refinements.
* The good model must be a **vertex**, not merely on the hull, and the only hypothesis at that vertex.
* $\lambda$ must lie in $(s_+N,\ s_-N)$.

### 3.2 Separable components

**Theorem 3.2 (product classes; rate threshold) [proved; TOSU].** Partition $X=\bigsqcup_{j\le m}X_j$ into finitely many regions. Let $\mathcal H=\prod_j\mathcal H_j$, where $h_j$ acts on $X_j$ and $\ell(h)=\sum_j\ell_j(h_j)$ (concatenated prefix codes). Then:
* $J_c(h)=\sum_j[c\ell_j(h_j)+R_j(h_j)]$, where $R_j$ is $D$-weighted risk on $X_j$. The minimizers are exactly the products of per-region minimizers, so each region independently picks its own hull vertex for slope $c$.
* In particular, suppose $\mathcal H_j=\{\text{default},\text{component }j\}$, with the component costing $k_j>0$ more bits and lowering $R_j$ by $r_j$. Then component $j$ is selected iff $r_j/k_j>c$; ties are arbitrary.

*Proof.* The objective is a sum of functions of disjoint coordinates. ∎ [computed: c3(i),(iii): 0 violations in 6000 and 2000 tests.]

### 3.3 Idealized version with arbitrary hypotheses

The separable theorem assumes the hypothesis class is a product. With $\ell=K$ and *all* computable hypotheses allowed, a hypothesis could in principle share information across regions or learn components "partially". The next theorem shows that, for independent parity components, it cannot gain from either, up to explicit slack.

Setting:
* Regions $X_j=\{j\}\times\{0,1\}^{d_j}$ for $j=1..m$, with $D(j,z)=\pi_j2^{-d_j}$.
* Teacher $y^*(j,z)=\langle a_j,z\rangle\bmod2$, with the components jointly random: $K(a_1,\dots,a_m)\ge\sum_jd_j$.

**Theorem 3.3 (rate threshold, idealized) [proved; identification clause 2 and the proof revised after verification].** Write $g(t):=1-\log_2(1+2^{1-t})$. This is the exact per-region risk floor from Lemma 2.5b with $p=0$. It is increasing and concave in $t$, with $g(1)=0$, $g(2)=1-\log_2\frac32=0.4150$ and $g(\infty)=1$.

For all $c>0$,
$$\Big|\Phi(c)-\sum_{j}\min(c\,d_j,\ \pi_j)\Big|\ \le\ \Delta_0(c):=c\Big(\sum_j(2\log_2d_j+2\log_2m+4+\kappa)+\kappa\Big)+\sum_j\pi_j2^{1-d_j/4}.$$
Moreover, assume every $d_j\ge8$. If $J_c(h)\le\Phi(c)+\eta$, set $\Delta=2\Delta_0(c)+\eta$. For each $j$:
* if $\pi_j<c\,d_j-\Delta-4c$, then $\hat s_{h,j}(a_j)<\frac12$: $h$ has not learned component $j$;
* if $\pi_j\,g(d_j/4)>c\,d_j+\Delta$ and $\pi_j\,g(2)>\Delta+8c$, then $\hat s_{h,j}(a_j)\ge\frac12$: $h$ has learned it.
  * The two conditions are implied by $\pi_j>c\,d_j+\Delta+\pi_j2^{1-d_j/4}/\ln2$ and $\pi_j>2.41\,(\Delta+8c)$, respectively.
  * *Revised after verification.* The original clause required only $\pi_j>c\,d_j+\Delta+\pi_j2^{1-d_j/4}$ and $\pi_j>2\Delta+16c$, and it was **false**.
  * Counterexample: $m=1$, $\pi_1=1$, $d_1=40$, $c\approx10^{-8}$, and $h(f_a(z)|z)=0.745$ for all $z$. Then $\hat s=0.49<\frac12$ and $R=0.4247$. Taking $\eta:=J_c(h)\approx0.425$ gives $\Delta\approx0.429$, and the old conditions hold.
  * The new constant $1/g(2)\approx2.41$ is the best this method gives: hypotheses with $\hat s\uparrow\frac12$ have $R\downarrow g(2)$.

The rate of component $j$ is $\pi_j/d_j$ (risk reduction of one bit on mass $\pi_j$ for $d_j$ bits).

*Proof.*
* **Upper bound.** $h_S$ knows $a_j$ for $j\in S$ and flips a coin elsewhere. It has $K(h_S)\le\sum_{j\in S}(d_j+2\log_2d_j+2\log_2m)+\kappa$ and $R(h_S)=\sum_{j\notin S}\pi_j$. Take $S=\{j:c\,d_j<\pi_j\}$. Then $J_c(h_S)\le\sum_j\min(c\,d_j,\pi_j)+\Delta_0(c)$.
* **Lower bound.**
  * Fix $h$. Let $t_j$ be the least $t\in\mathbb N$ with $\hat s_{h,j}(a_j)\ge2^{-t}$, or $\infty$. For $t_j\ge1$ we have $\hat s_{h,j}(a_j)<2^{1-t_j}$.
  * Given $h^*$, $j$ and $d_j$, we can either list-decode (Lemma 2.5a) or write $a_j$ literally. So $K(a_j\mid h^*)\le\min\{s(t_j),\,d_j\}+2\log_2d_j+2\log_2m+\kappa$, where $s(t)=2t+2\log_2(t+1)$.
  * Then $\sum_jd_j\le K(a_{1..m})\le K(h)+\sum_jK(a_j\mid h^*)+\kappa$. Since $d-\min\{s,d\}=(d-s)^+$, this gives
  $$K(h)\ \ge\ \sum_j(d_j-s(t_j))^+-C,\qquad C:=\sum_j(2\log_2d_j+2\log_2m+\kappa)+\kappa.$$
  * By Lemma 2.5b with $p=0$, applied to region $j$, $R_j(h)\ge-\log_2\frac{1+\hat s_{h,j}(a_j)}2>g(t_j)$ for $t_j\ge1$, and $R_j\ge0$ always.
    * *Revised.* The original proof continued "$\ge1-2^{1-t_j}$". That step is false for $t_j\ge2$, since $\log_2(1+u)\ge u$ on $[0,1]$. The exact floor $g$ is used from here on.
  * So $J_c(h)\ge\sum_j\varphi_j(t_j)-cC$, where $\varphi_j(0):=c\,d_j$ and $\varphi_j(t):=c(d_j-s(t))^++\pi_jg(t)$ for $t\ge1$. Using $s(t)\le4t$ for $t\ge1$, we get $\varphi_j(t)\ge c(d_j-4t)^++\pi_jg(t)$.
  * *Per-region bound.* We claim $\min_t\varphi_j(t)\ge\min(c\,d_j,\pi_j)-4c-\pi_ju_j$, where $u_j:=2^{1-d_j/4}$.
    * If $d_j<4$, the right side is $\le0\le\varphi_j$.
    * If $d_j\ge4$: on $t\in[1,d_j/4]$ the lower bound $c(d_j-4t)+\pi_jg(t)$ is concave, so it is at least its value at an endpoint, $c(d_j-4)$ or $\pi_jg(d_j/4)$. For $t>d_j/4$ the bound is $\ge\pi_jg(d_j/4)$, since $g$ is increasing. Hence $\min_t\varphi_j\ge\min\big(c(d_j-4),\ \pi_j-\pi_j\log_2(1+u_j)\big)$.
    * *Absorption.* The first entry is fine. For the second, $\log_2(1+u)-u\le(\frac1{\ln2}-1)u\le0.443u$.
      * If $c\,d_j\ge\pi_j$, it suffices that $4c\ge0.443\pi_ju_j$. This follows from $c\ge\pi_j/d_j$ and $0.886\,d\,2^{-d/4}\le4$ for all $d$ (the maximum is $1.88$).
      * If $c\,d_j<\pi_j$, it suffices that $c(d_j-4)\le\pi_j(1-\log_2(1+u_j)+u_j)$. This follows from $c(d_j-4)<\pi_j(1-4/d_j)$ and the same inequality.
  * Summing over $j$ gives $\Phi(c)\ge\sum_j\min(c\,d_j,\pi_j)-\Delta_0(c)$.
  * [computed: repair_checks] The per-region bound was checked for $d\in[1,63]\cup\{80,100,200,400\}$, $c=2^{e/4}$ with $e\in[-60,9]$, and seven values of $\pi$, with both $s(t)$ and $4t$: no violations.
* **Identification.** We have $\varphi_j(t_j)\le J_c(h)+cC-\sum_{i\ne j}\varphi_i(t_i)$, and each $\varphi_i\ge\min(c\,d_i,\pi_i)-(4c+\pi_iu_i)$.
  * Combined with the upper bound on $\Phi$: if $J_c(h)\le\Phi+\eta$, then every region satisfies $\varphi_j(t_j)\le\min(c\,d_j,\pi_j)+2\Delta_0+\eta=\min(c\,d_j,\pi_j)+\Delta$.
  * If $\hat s_j\ge\frac12$, then $t_j\le1$ and $\varphi_j\ge c(d_j-4)$. This exceeds $\pi_j+\Delta\ge\min(\cdot)+\Delta$ under the first condition.
  * If $\hat s_j<\frac12$, then $t_j\ge2$. On $[2,d_j/4]$ (nonempty, as $d_j\ge8$) the lower bound $c(d_j-4t)+\pi_jg(t)$ is concave. For $t\ge d_j/4$ (including $t=\infty$) the bound is $\ge\pi_jg(d_j/4)$.
    * So $\varphi_j\ge\min\big(c(d_j-8)+\pi_jg(2),\ \pi_jg(d_j/4)\big)$.
    * Under the two conditions, both entries exceed $c\,d_j+\Delta\ge\min(\cdot)+\Delta$. That is a contradiction.
  * The implied forms use $\log_2(1+u)\le u/\ln2$ and $1/g(2)=2.4094$.
  * [computed: repair_checks] Under the new conditions, $\varphi_j(t)>c\,d_j+\Delta$ for every integer $t\ge2$ in 8474 random admissible instances.
  * The referee's counterexample violates the new second condition, by a factor $1.01$–$1.06$. ∎

**Corollary 3.4 (convex hull shapes are realizable) [proved from Thm 3.3; statement made precise after verification].** Take rational slopes $s_1>\dots>s_m>0$ and integer lengths $d_j\ge1$ with $\sum s_jd_j\le1$. Set $\pi_j=s_jd_j$, and add a region of mass $\pi_0=1-\sum\pi_j$ whose teacher labels are fair coins.
* The coin region contributes *at least* $\pi_0$ to every hypothesis's risk, with equality for hypotheses that are uniform there. It plays no role in the complexity argument. So the lower bound of Thm 3.3 holds with $\pi_0$ added, and the witnesses $h_S$ are uniform there. Hence $|\Phi(c)-\Psi(c)|\le\Delta_0(c)$, with $\Psi(c):=\pi_0+\sum_j\min(c\,d_j,\pi_j)$. (The constants in $\Delta_0$ change by $O(1)$ for the extra region.)
* *From $\Phi$ to the hull (Legendre duality).* $\Phi$ is the support function of $A$. The lower hull $\breve\rho(k):=\inf\{r:(k,r)\in\mathrm{conv}(A+\mathbb R^2_{\ge0})\}$ is convex and lower semicontinuous, so $\breve\rho(k)=\sup_{c\ge0}[\Phi(c)-ck]$.
* Likewise $P(k):=\sup_{c\ge0}[\Psi(c)-ck]$ is the convex polygon that starts at $(0,1)$, has edges of slope $-s_j$ and horizontal length $d_j$ in order of decreasing slope, and is flat at height $\pi_0$ after $\sum_jd_j$.
* Write $\Delta_0(c)=cC'+\epsilon$, with $C'=\sum_j(2\log_2d_j+2\log_2m+4+\kappa)+\kappa$ and $\epsilon=\sum_j\pi_j2^{1-d_j/4}$. Then
  $$P(k+C')-\epsilon\ \le\ \breve\rho(k)\ \le\ P(k-C')+\epsilon.$$
  So the product-model frontier is the polygon up to a horizontal band of width $C'=O(m\log\max_jd_j+m\log m+m\kappa)$ and a vertical band of height $\epsilon$.
* *Which shapes.* The realized frontiers start at height $1$ at $k\approx0$ and drop by $\sum\pi_j\le1$ bit/sample in total (binary labels), with rational slopes and integer edge lengths.
  * Any convex decreasing piecewise-linear shape with these properties is realized up to the bands.
  * Multiplying all $d_j$ by $L$ and dividing all $s_j$ by $L$ keeps the $\pi_j$ fixed and makes the band relatively negligible ($C'/L\to0$, $\epsilon\to0$).
  * So every such shape is realized *after rescaling*. It is not realized at arbitrary absolute scale.

This is the product-model analogue of Vereshchagin–Vitányi's "all shapes" result. The moral is the same: **whether a "good model" exists as a vertex is a property of the data, not a theorem.**

### 3.4 The user's example, verified

**Theorem 3.5 (parity version of the user's example) [proved; lower bound revised after verification].** Work in the setting of Thm 2.5. Write $\tau_t=2t+2\log_2(t+1)+2\log_2d+\kappa$, let $\beta_t$ be as in Thm 2.5(b), and put $K_{\rm tot}:=d+L_E-\delta_E-2\log_2d-\kappa$. For every $c>0$ and $t\in\mathbb N$,
$$\min\Big\{1-\tfrac{\beta_t}{\ln2},\ c(d-\tau_t)+\tfrac{L_E-\delta_E-\kappa}n,\ c\,K_{\rm tot}\Big\}\ \le\ \Phi(c)\ \le\ \min\Big\{1+c\kappa,\ c(d+\kappa')+H(p),\ c(d+L_E+\kappa\log n)\Big\}.$$
The three terms are the coin, the good model and the error-memorizing model. The switch points are approximately
$$c_{\rm coin/good}\approx\frac{1-H(p)}{d},\qquad c_{\rm good/bad}\approx\frac{H(p)}{L_E}\approx\frac{H(p)}{nH(p)}=\frac1n.$$

*Proof.*
* The upper bound lists the three models.
* For the lower bound, split on $K(h)$:
  * If $K(h)\le d-\tau_t$, use Thm 2.5(b).
  * Otherwise, Thm 2.5(c) gives $J_c(h)\ge cK+\max(0,(K_{\rm tot}-K)/n)$. This is piecewise linear in $K$, and $K_{\rm tot}\ge d-\tau_t$ because $L_E-\delta_E=K(E\mid a,K(a))\ge0$.
    * When $c\ge1/n$, the minimum over $K\ge d-\tau_t$ is at $K=d-\tau_t$. Its value is $c(d-\tau_t)+(K_{\rm tot}-d+\tau_t)/n$, and $K_{\rm tot}-d+\tau_t=L_E-\delta_E+s(t)\ge L_E-\delta_E-\kappa$.
    * When $c<1/n$, the minimum is at $K=K_{\rm tot}$, with value $cK_{\rm tot}$. ∎

The $2\log_2d$ in $K_{\rm tot}$ comes from the corrected Thm 2.5(c), and the coin term now uses the sharper $\beta_t$. Neither changes the switch points beyond their $O(\log)$ slack.

**Corollary 3.5a (identification in the parity example) [proved; added after verification].** In the setting of Thm 2.5, let $J_c(h)\le\Phi(c)+\eta$. Then:
* **(i)** $h$ correlates strongly with the simple model:
  $$\hat s_h(a)\ \ge\ 2^{\,1-c(d+\kappa')-H(p)-\eta}-1-2p.$$
* **(ii)** If $cn>1$, then $h$ memorizes almost none of the errors:
  $$R(h)\ \ge\ H(p)-\frac{\eta+c\Lambda}{cn-1},\qquad \Lambda:=\log_2(n+1)+\delta_E+2\log_2d+\kappa+\kappa'.$$

So, for $c$ in the window $(\approx1/n,\ \approx(1-H(p))/d)$, every near-optimal hypothesis is close to the good model in both respects. In contrast, $h_{\rm bad}$ has $R=0$ and the coin has $\hat s=0$.

*Proof.*
* (i) $R(h)\le J_c(h)\le\Phi(c)+\eta\le c(d+\kappa')+H(p)+\eta$. Lemma 2.5b gives $2^{-R}\le\frac{1+\hat s}2+p$, i.e. $\hat s\ge2^{1-R}-1-2p$.
* (ii) By Thm 2.5(c), $K(h)\ge K_{\rm tot}-nR(h)$, so $J_c(h)\ge cK_{\rm tot}-(cn-1)R(h)$.
  * Compare with $J_c(h)\le c(d+\kappa')+H(p)+\eta$, and use $L_E\ge nH(p)-\log_2(n+1)$.
  * This gives $(cn-1)R(h)\ge cnH(p)-c\Lambda-H(p)-\eta$. ∎

[computed: repair_checks; $\kappa=\kappa'=0$ and $\eta=0$ for illustration] At $d=20$, $p=2^{-10}$:
* $c=10^{-4}$ gives $\hat s\ge0.980$ and $R\ge H(p)-2.8\cdot10^{-5}$;
* $c=10^{-3}$ gives $\hat s\ge0.955$.

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

**Theorem 4.1 (rate blindness) [proved; TOSU; (ii), (iii) made precise after verification].**
* (i) The map $c\mapsto\arg\min J_c$ depends on the data only through $(D,P^*)$. Validity enters nowhere.
* (ii) Let $v$ be a valid component and $e$ an error component with $r_v/k_v\le r_e/k_e$.
  * In the setting of Thm 3.2: for every $c$ except a common tie value $c=r_v/k_v=r_e/k_e$, if $v$ is selected then so is $e$.
  * In the setting of Thm 3.3, with rates $\pi_j/d_j$: the same holds for near-optimal $h$ at every $c$ at which the identification clauses of Thm 3.3 decide both $v$ and $e$. That is, $c$ lies outside the $O(\Delta)$ slack bands around $\pi_v/d_v$ and $\pi_e/d_e$.
* (iii) In general, the intended hypothesis $h^\circ$ minimizes $J_c$ for some $c>0$ iff $P_{h^\circ}$ lies on $\mathrm{hull}^-(A)$, the part of the boundary with finite negative slope. It is the unique minimizer on an open $c$-interval iff $P_{h^\circ}$ is a vertex *and* no other hypothesis has the same point.
* (iv) Take two worlds with the same $(D,P^*)$, in which a component is an error in world 1 and a valid rare rule in world 2. Every $c$, and indeed every imitation-only procedure, gives the same output in both. So it is wrong in one of them.

*Proof.*
* (i) $J_c$ is a functional of $(D,P^*)$.
* (ii) Thm 3.2: if $v$ is selected and $c$ is not a tie value for $v$, then $c<r_v/k_v\le r_e/k_e$. If $c=r_v/k_v<r_e/k_e$, then $e$ is selected strictly.
  * Thm 3.3: suppose $v$ is learned. Then $v$ does not satisfy clause 1, so, being decided, it satisfies clause 2, which gives $\pi_v/d_v>c$.
  * If $e$ satisfied clause 1, then $\pi_e/d_e<c<\pi_v/d_v$, which is a contradiction. So $e$ satisfies clause 2 and is learned.
* (iii) Lemma 3.1(i),(iii).
* (iv) This is (i); compare L11 Lemma 2.1 and T1 Cor 6.5. ∎

What is new relative to T1 Cor 6.5 ("systematic errors are rules") is the *quantitative* criterion. The steeper penalty does separate errors from rules, but **by rate, not by validity**. It succeeds exactly when every intended component out-rates every error component.

*Illustration (revised after verification).* Take a valid rule used in $10^{-4}$ of steps that costs 200 bits. Its rate is $5\cdot10^{-7}g$, where $g$ is the per-use gain in bits.
* If $g\le2.2$ bits, its rate is below that of the user's 10 000-bit error ($1.12\cdot10^{-6}$). Then it is discarded at every $c$ that rejects that error.
* With the c4 gain $g=5.42$ its rate is $2.7\cdot10^{-6}$, and it survives on the band $c\in(1.12\cdot10^{-6},2.7\cdot10^{-6})$. A rule used in $10^{-5}$ of steps would not survive.
* The comparison mixes two settings, binary-label parity and $M$-way step imitation. Only the rates are comparable.

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

**Conjecture (empirical, not part of Prop 4.2): the cheapness of these fallacies is not an accident.** A fallacy becomes *systematic* in a human population exactly because it is a short, natural variant of a valid pattern. So the error class that the user most wants removed is the class with the highest rates. See also §4.4 (d6).

### 4.3 (c) The window is not identifiable from imitation data

**Theorem 4.3 (validation prefers the teacher) [proved; (i) made precise after verification].**
* (i) Along the population selection path, held-out risk $R(h_c)$ is non-increasing as $c$ decreases (Lemma 3.1(ii)).
  * So, for a **fixed finite grid** of $c$ values and $N\to\infty$ (with the held-out set growing), selecting $c$ by held-out log-loss converges to a grid value whose population minimizer has the least risk. The smallest grid value is always among these, and it is the unique choice when its risk is strictly smallest.
  * At finite $N$ this can fail. Lemma 1.2's $B/c$ term blows up at small $c$, and when the error component is not yet learnable from $N$ samples, cross-validation can pick an interior $c$.
* (ii) More generally, for any strictly proper scoring rule $S$, $\mathbb E_{y\sim P^*}S(P^*(\cdot|x),y)>\mathbb E_{y\sim P^*}S(q,y)$ for $q\ne P^*(\cdot|x)$ (Gneiting & Raftery 2007, *JASA* [known]). Any validation criterion that is an empirical proper score on fresh imitation data is therefore maximized by the teacher channel, errors included. Among candidates, it prefers the one closest to $P^*$, never the norm *as such*.
* (iii) There is no imitation-data statistic that picks the good $c$ in both of the worlds of Thm 4.1(iv).

*Proof.*
* (i) Lemma 3.1(ii), together with uniform convergence of the held-out risk over the finitely many grid points, and Lemma 1.2 for each fixed $c$ in the grid.
* (ii) Strict propriety, applied pointwise and integrated over $D$. With a growing held-out set, the empirical score converges uniformly over finitely many candidates.
* (iii) Thm 4.1(iv). ∎

[computed: c4] In the user's example, held-out log-loss is $1.0$ at $c=10^{-1}$, $0.0112$ at $c\in[10^{-5},10^{-3}]$, and $0$ at $c=10^{-7}$. Cross-validation picks the error-memorizing model.

*SafeBayes.* SafeBayes chooses $\eta=1/\lambda$ to minimize a sequential randomized log-loss on the same data. It is a proper-score procedure, so (ii) applies. In the well-specified imitation setting it has no reason to move away from standard Bayes. The user's $\eta\ll1$ is a *normative* choice that no data-fit criterion on $P^*$ can recover. This is my reading; I have not checked the SafeBayes papers' exact criteria.

### 4.4 (d) Further pathologies

**Proposition 4.4 (guard erosion: steeper simplicity can make the learner less sound than the teacher) [proved; hypothesis added and constant corrected after verification].**
* *Setting.* Let $\sigma$ be a schema and $\sigma|_G$ its guarded version, e.g. $x/x\to1$ if $x\ne0$.
  * Humans apply $\sigma$ only where $G$ holds: in $G$-contexts (frequency $\pi_G$) as in §5.1, with per-step gain $g$.
  * In contexts where $\sigma$ is applicable but $G$ fails (frequency $\pi_{\neg G}$), they play some non-$\sigma$ step.
* *Options.* In the $\sigma$-applicable region the hypothesis has three options:
  * **none**: uniform over the $M$ candidates, cost 0;
  * **unguarded** $\sigma$: mass $1-\eta+\eta/M$ on the $\sigma$-step in every $\sigma$-applicable context, cost $k_\sigma$;
  * **guarded** $\sigma|_G$: the $\sigma$-model in $G$-contexts, and uniform on the $M-1$ non-$\sigma$ steps in $\neg G$-contexts, cost $k_\sigma+k_G$.
* *Rates.* The unguarded option's net rate over "none" is $\rho_\sigma:=\big(\pi_Gg-\pi_{\neg G}\log_2(1/\eta)\big)/k_\sigma$.
  * The guard's rate is its marginal rate over the unguarded option: $\rho_G:=\pi_{\neg G}\,\Delta_G/k_G$, with $\Delta_G:=\log_2(M/\eta)-\log_2(M-1)$.
  * Note $\Delta_G>\log_2(1/\eta)$, by $\log_2\frac M{M-1}$; this corrects the earlier "at most $\pi_{\neg G}\log_2(1/\eta)/k_G$".
  * If the guarded model also models the teacher's alternative step in $\neg G$-contexts, $\Delta_G$ is larger still. The statement below holds with that $\Delta_G$.
* **Claim.** If $\rho_G<\rho_\sigma$, then:
  * for $c\in(\rho_G,\rho_\sigma)$ **the selected rule is the unguarded, unsound $\sigma$**, although the teacher never committed the error;
  * for $c<\rho_G$ the guarded rule is selected;
  * for $c>\rho_\sigma$ neither is.
* If instead $\rho_G\ge\rho_\sigma$, the unguarded option is not a hull vertex. Apart from ties, the selection jumps from guarded to none, and the learner stays sound.
* In classical settings one unsound schema trivializes the calculus (T1 Prop 2.3; T2 Thm 3.1). With field rules, $0/0\to1$ gives $1=0$.

*Proof.* The three options are the points $(0,0)$, $(k_\sigma,-k_\sigma\rho_\sigma)$ and $(k_\sigma+k_G,-k_\sigma\rho_\sigma-k_G\rho_G)$, in (bits, risk relative to "none"). The middle point is a vertex of their lower hull iff $\rho_\sigma>\rho_G$. Apply Lemma 3.1 within the region and Thm 3.2 across regions. ∎

[computed: c4, repair_checks]
* The c4 instance has $\pi_G=0.05$, $\pi_{\neg G}=5\cdot10^{-4}$, $k_\sigma=22$, $k_G=12$, $M=64$ and $\eta=0.05$. Then $\Delta_G=4.34$ bits, $\rho_G=1.8\cdot10^{-4}$ and $\rho_\sigma=1.22\cdot10^{-2}$, so the hypothesis holds.
  * The unguarded rule is selected for $c\in(1.8\cdot10^{-4},1.22\cdot10^{-2})$.
  * That range includes values at which ex falso ($7.2\cdot10^{-4}$) is kept.
* With $\pi_G=\pi_{\neg G}=0.002$ instead, $\rho_\sigma=1.0\cdot10^{-4}<\rho_G=7.2\cdot10^{-4}$. The selection path is guarded → none (at $c\approx3.2\cdot10^{-4}$), with no unsound phase.

The *norm-carrying* structure that a careful teacher exhibits most rarely (side conditions, eigenvariable conditions, edge cases) is exactly what steep simplicity removes first. Coherence must restore it: the unguarded rule gives $0/0=1$, while $a/b=a\cdot b^{-1}$ and $0\cdot y=0$ give $0/0=0$. Hence $1=0$, a T2 negative bag.

**Proposition 4.5 (error envelopes) [proved; TOSU].** Suppose the error set $E$ lies inside a cheaply describable region $S$: $K(S\mid f)=k_S$, $D(S)=\sigma$, and error density $\theta=D(E)/\sigma$ in $S$.
* The hypothesis "$f$, with flip rate $\theta$ on $S$ and $0$ off $S$" costs $k_S+O(1)$ bits over the good model. It reduces risk by $H(p)-\sigma H(\theta)$, where $p=D(E)$.
* So it is learned at its *own* rate, which can far exceed the rate of the full error component.
* If $\theta>1/2$, the learner predicts the **error label** on all of $S$: it imitates a coarse version of the error.

*Example.* Take $p=2^{-10}$, $\sigma=2^{-8}$, $\theta=\frac14$, $k_S=30$. The risk reduction is $0.0112-0.0032=0.0080$, a rate of $2.7\cdot10^{-4}$, compared with $1.1\cdot10^{-6}$ for the full error. With $\theta<\frac12$ this is benign: the intended label is still predicted, with honest uncertainty. When errors cluster ($\theta>\frac12$), the envelope *is* a learned systematic error.

The user's example has a K-random $E$, so no such envelope exists (Thm 2.5(c)). **Real systematic errors are the opposite case: they are low-complexity patterns.**

**(d3) Non-additivity: parasitic errors [proved by example; ordering claim retracted after verification].** The separability of Thm 3.2 fails when an error is cheap *given* a valid rule. Then $K(e\mid v)\ll K(e)$, and once $v$ is included the marginal rate of $e$ is $r_e/K(e\mid v)$.

Examples:
* the freshman's dream is "distribute the exponent", a one-symbol mutation of $(ab)^n=a^nb^n$;
* the unguarded rule is the guarded one minus its guard;
* "or as xor" is ∨ plus one clause.

Valid rules *subsidize* their own mis-generalizations.

*Revised after verification.* The earlier claim that "the selection path interleaves valid and erroneous refinements in an order fixed by conditional rates" was false. The correct statement: the selection path is the lower hull of the subset lattice under the *joint* code. Bundles can enter it together, so a valid rule may be kept only because of the error it subsidizes. This strengthens the pathology.

*Example* [computed: repair_checks].
* *Components.* A valid $v$ with $k_v=10$ and $r_v=0.01$ (rate $10^{-3}$). An error $e$ with $K(e)=100$, $K(e\mid v)=1$ and $r_e=0.01$.
* *Objectives at $c=1.5\cdot10^{-3}$*, relative to the empty set: $\{v\}$ gives $+0.005$, $\{e\}$ gives $+0.14$, and $\{v,e\}$ gives $11c-0.02=-0.0035$.
* So the optimum is $\{v,e\}$. Yet $v$'s own rate ($10^{-3}$) and $e$'s unconditional rate ($10^{-4}$) are both below $c$. The bundle's rate, $0.02/11=1.8\cdot10^{-3}$, exceeds $c$, and $v$ survives only because it buys $e$ cheaply.

**(d4) Coherence-repair by sacrifice.** See Prop 5.3.

**(d5) In-context universality.** See Prop 2.6.

**(d6) Language relativity [proved; TOSU].**
* *Claim.* Take any finite list of $m$ separable components with risk reductions $r_j$, any target inclusion set $S^\circ$ with $r_j>0$ for $j\in S^\circ$, and any $c>0$. Then there is a prefix code with $S^*(c)=S^\circ$.
* *Construction (corrected after verification).*
  * Choose integers $k_j\ge0$ with $k_j<r_j/c$ for $j\in S^\circ$ ($k_j=0$ is allowed) and $k_j>r_j/c$ otherwise.
  * Give $h_S$ length $\ell_0+\sum_{j\in S}k_j$, where the common prefix length is $\ell_0=m$.
  * The Kraft sum is $2^{-\ell_0}\prod_j(1+2^{-k_j})\le2^{m-\ell_0}=1$, so a prefix code with these lengths exists. The common prefix does not change marginal costs.
  * The earlier "pad with unused codewords" could not work: adding codewords only increases the Kraft sum.
  * [computed: repair_checks: 0 failures in 3000 random instances.]
* For universal machines the invariance theorem bounds the damage. $|K_U-K_V|\le c_{UV}$, so a marginal cost $K(h_{S\cup j})-K(h_S)$ changes by at most $2c_{UV}$. Rates change by the factor $k/(k\pm2c_{UV})$. That is negligible for 10 000-bit errors and decisive for 20-bit schemas, which is the inference-rule regime.
* The user's idea (ii), a "simplicity prior defined in terms of existing understanding", cuts both ways. A learner whose description language is shaped by human concepts, e.g. by pretraining on human text, assigns *human-natural* errors short codes. That raises exactly the rates of the fallacies humans find natural.

**(d7) Distribution dependence [TOSU].** Rates scale with $D$-frequency. A valid rule rare in the training distribution, e.g. used mainly in hard problems, is discarded, and stays discarded as $N\to\infty$ with $\lambda=cN$. Under a shift to a distribution where it matters, the learned norm is wrong. In T1's terms the verifier stays sound but becomes incomplete. With guard erosion it can become unsound.

---

## 5. Inference rules

### 5.1 Situation-typed step imitation

* Following T1 §1, steps are $(\Pi,j)$. A context $x$ is the current premise set and goal, and the label $y$ is the human's next step, chosen from a candidate set $M(x)$ with $|M(x)|=M_\tau$.
* Contexts fall into **situation types** $\tau$ (computable from $x$, part of the base model) with frequencies $\pi_\tau$. In type $\tau$ the human applies a schema $\sigma_\tau$, valid ($\in R^*$) or fallacious, with probability $1-\eta$, and otherwise moves uniformly at random.
* A hypothesis chooses a set $S$ of types to model with their schemas. Each modelled type costs $\ell(\sigma_\tau)+O(1)$ bits; the rest are predicted uniformly.
* The gain per modelled step is $g_\tau=\log_2M_\tau-H_\tau$, where $H_\tau$ is the teacher channel's entropy in that type. The rate is $\rho_\tau=\pi_\tau g_\tau/(\ell(\sigma_\tau)+O(1))$. c4 sets the $O(1)$ to $0$.
* By Thm 3.2, type $\tau$'s schema is selected iff $\rho_\tau>c$.

The **verifier induced** by a selected hypothesis accepts exactly the instances of selected schemas; the noise component is not accepted. So T1 soundness of the induced verifier means "no selected error schema and no eroded guard".

### 5.2 Feasibility constraints: coherence, world, postulates

* Let $C=V\sqcup E$ be the valid and erroneous components, with **net values** $\nu_j=r_j-c\,k_j$.
  * These were called $g_j$ before verification. They are renamed to avoid a clash with the per-step gain $g_\tau$ of §5.1.
  * For a separable component, $\nu_j>0$ iff its rate $r_j/k_j$ exceeds $c$.
* A **feasibility family** $\mathfrak F\subseteq2^C$ records which component sets are admissible:
  * *A-coherent*: no ⊥-derivation from a designated context (T2 §1);
  * *W-adequate*: no derivation of a claim the world oracle refutes;
  * *postulate-respecting*: coherent with designated meaning postulates $\mathrm{Ax}$.
* Each such $\mathfrak F$ is **down-closed**, since derivability is monotone in the rule set, and contains $2^V$, since valid rules are jointly coherent and true.
* When several filters are used together, $\mathfrak F$ is their **intersection**, which is again down-closed and contains $2^V$. The assumptions below are imposed on the $\mathfrak F$ actually in use.
* For an error $F$, a **witness** is a minimal $W\subseteq V$ with $W\cup\{F\}\notin\mathfrak F$. It plays the role of T2's negative bag (Lemma 2.1), seen from the rule side.

Write $V_+=\{v:\nu_v>0\}$ and $E_+=\{F:\nu_F>0\}$. Both depend on $c$.

**Assumptions** (at the given $c$).
* *Error-independence:* for $U\subseteq V$, $U\cup E'\in\mathfrak F$ iff $U\cup\{F\}\in\mathfrak F$ for each $F\in E'$.
* *Valid dominance:* for every $F\in E_+$ that has a witness inside $V_+$, the cheapest blocking set satisfies $\beta(F):=\min\{\sum_{v\in B}\nu_v: B\subseteq V_+\text{ meets every witness of }F\text{ inside }V_+\}>\sum_{F'\in E_+}\nu_{F'}$.

**Theorem 5.2 (division of labour) [proved; proof tightened after verification].** Fix $c$. Assume separability, and error-independence and valid dominance at $c$ for the $\mathfrak F$ in use. Then the optimal feasible set is unique up to zero-value ties, and equals
$$S^*(c)=V_+\ \cup\ \{F\in E_+:\ V_+\cup\{F\}\in\mathfrak F\}.$$
"Up to zero-value ties" means that the optimal sets are exactly the feasible sets $S^*(c)\cup Z$ with $Z\subseteq\{\nu=0\}$.

Spelled out, with $\mathfrak F$ the intersection of the filters in use and the two assumptions holding for that intersection:
* **Simplicity** removes exactly the errors with rate $\le c$, whether or not they are coherent.
* **Coherence** removes exactly the errors with a coherence witness among the valid rules *actually kept*, whatever their rate.
* **World feedback** removes exactly the errors with a refutation using kept rules, whatever their rate.
* **Postulates** remove exactly those incoherent with $V_+\cup\mathrm{Ax}$.
* **The residue** is the set of errors that are high-rate, coherent, empirically adequate and postulate-consistent relative to $V_+$.
* **The cost** is that the valid rules with rate $\le c$ are lost, whatever the other filters do.

*Proof.*
* Let $S$ be feasible and optimal. Removing components with $\nu<0$ keeps feasibility (down-closure) and raises the value, so $S\subseteq\{\nu\ge0\}$.
* Let $E_1=(S\cap E)\setminus\{F:V_+\cup\{F\}\in\mathfrak F\}$.
  * Each $F\in E_1$ has a witness $W$ inside $V_+$, and $W\neq\emptyset$ because $\{F\}\subseteq S$ is feasible.
  * By down-closure, feasibility of $S$ forces $B:=V_+\setminus S$ to meet every such witness. So $B\ne\emptyset$ and $\sum_B\nu>0$.
  * If $E_1$ contains some $F\in E_+$, then $\sum_B\nu\ge\beta(F)>\sum_{E_+}\nu\ge\sum_{E_1}\nu$. Otherwise $E_1\subseteq\{\nu=0\}$ and $\sum_{E_1}\nu=0<\sum_B\nu$.
* The set $S'=V_+\cup(S\cap E\setminus E_1)$ is feasible by error-independence with $U=V_+$. Since $S\cap V\subseteq(V_+\setminus B)\cup\{\nu=0\}$, its value is $\mathrm{val}(S)+\sum_B\nu-\sum_{E_1}\nu>\mathrm{val}(S)$. That is a contradiction, so $E_1=\emptyset$.
* *(Tightened.)* Hence $S\cap V\subseteq V_+\cup\{\nu=0\}$ and $S\cap E\subseteq\{F:V_+\cup\{F\}\in\mathfrak F,\ \nu_F\ge0\}$.
  * So $\mathrm{val}(S)\le\mathrm{val}(S^*)$. $S^*$ is feasible by error-independence, so it is optimal.
  * Then $\mathrm{val}(S)=\mathrm{val}(S^*)$ forces $S\supseteq S^*$ and $S\setminus S^*\subseteq\{\nu=0\}$.
  * The earlier last step, "adding $V_+\setminus S$ keeps feasibility", can fail when $S$ contains zero-valued valid rules. Example: $V=\{v_+,v_0\}$ with $\nu(v_0)=0$, and $F$ whose sole witness is $\{v_+,v_0\}$. Then $S=\{v_0,F\}$ is feasible but $S\cup\{v_+\}$ is not. The direct comparison avoids this. ∎

[computed: verifier's brute force] 17 806 random instances satisfying both assumptions, about 10% of them with zero-valued components: 0 violations.

**Corollary 5.2a (best $c$ given the other filters) [hypotheses added after verification].** Assume error-independence and valid dominance at every $c$ considered. Say that *separation holds at $c$* if every optimal set contains $V$ and no error. Then separation holds at $c$ iff
$$\max\{\rho_F: V\cup\{F\}\in\mathfrak F\}\ <\ c\ <\ \min_{v\in V}\rho_v.$$
So a separating $c$ exists iff the maximal rate of the errors that survive coherence, world and postulates *relative to $V$* is below the minimal valid rate.

*Proof.*
* If $c<\min_v\rho_v$, then $V_+=V$, and by Thm 5.2 the optimal sets are $S^*(c)\cup Z$.
  * If moreover every surviving $F$ has $\rho_F<c$, then $S^*(c)=V$. Also $Z=\emptyset$: there is no zero-valued valid rule, a zero-valued surviving error would need $\rho_F=c$, and a non-surviving error is infeasible with $V$. So separation holds.
  * A surviving $F$ with $\rho_F>c$ lies in $S^*(c)$.
  * A surviving $F$ with $\rho_F=c$ has $\nu_F=0$. By error-independence it can be added to some optimal set.
* If $c\ge\rho_v$ for some $v$, then some optimal set omits $v$ (down-closure, $\nu_v\le0$). ∎

Valid dominance is essential for the "if" direction. Take $V=\{v\}$ with $r=0.01$, $k=10$ (rate $10^{-3}$), and an error $F$ with $r=0.02$, $k=10$ (rate $2\cdot10^{-3}$) and witness $\{v\}$.
* No error survives relative to $V$.
* Yet for every $c<10^{-3}$ the coherent optimum is $\{F\}$, since $0.02-10c>0.01-10c$. That is Prop 5.3's sacrifice, and here $\beta(F)=\nu_v<\nu_F$ [computed: repair_checks].

Coherence and world feedback **widen the window**: the rates of incoherent or refutable errors no longer matter. Steeper simplicity is then needed only against coherent, adequate, low-rate errors: idiosyncratic memorized falsehoods, and non-uniform "quus"-like additions (T2 Prop 6.3).

**Proposition 5.3 (without valid dominance: coherence repair by sacrifice) [proved; computed; hypotheses made explicit after verification].** Assume error-independence. Let $F\in E_+$ have a witness inside $V_+$, and let $B\subseteq V_+$ be a cheapest set meeting all witnesses of $F$ inside $V_+$, with $\beta(F)=\sum_B\nu<\nu_F$.
* Then the clean set $S_{\rm clean}:=V_+\cup\{F'\in E_+:V_+\cup\{F'\}\in\mathfrak F\}$ is not optimal.
* Indeed $S':=(V_+\setminus B)\cup\{F\}\cup(S_{\rm clean}\cap E)$ is feasible, and its value is $\mathrm{val}(S_{\rm clean})+\nu_F-\beta(F)$.

*Proof.*
* $(V_+\setminus B)\cup\{F\}\in\mathfrak F$. Otherwise a minimal $W\subseteq V_+\setminus B$ with $W\cup\{F\}\notin\mathfrak F$ would be a witness inside $V_+$ missed by $B$.
* For $F'\in S_{\rm clean}\cap E$, $(V_+\setminus B)\cup\{F'\}\in\mathfrak F$ by down-closure.
* So $S'\in\mathfrak F$ by error-independence with $U=V_+\setminus B$.
* $F\notin S_{\rm clean}$, because $F$ has a witness inside $V_+$. ∎

[computed: c4] AC's Post witness (T2 Cor 6.2) with $p:=\bot$ and $q:=(A\to A)$ needs only →I.
* If →I is rare (rate $8.7\cdot10^{-4}$), then at $c=5\cdot10^{-4}$ the unconstrained optimum is {AC, MP, →I, ⊤I}, but the coherent optimum is {AC, MP, ⊤I}. **It drops →I to keep the fallacy.**
* If →I is frequent, the coherent optimum is {MP, →I, ⊤I}.
* *Caveat.* This illustration takes the designated contexts to be $\mathcal A=\{\emptyset\}$. With substantive designated contexts, which T2 allows (e.g. $\{p_0\to q_0,\ q_0,\ \neg p_0\}$), MP is itself a witness partner for AC. Blocking would then have to remove MP, which is far too costly. So AC is dropped rather than →I.

[computed: verifier's brute force] 1 882 random instances with $\beta(F)<\nu_F$: the clean set was strictly suboptimal in every one.

This is Lakatos's monster-barring run backwards: the repair is chosen by MDL cost, not by validity. It refines T2 Thm 6.1. The elimination criterion "$h^*\oplus\mathcal G(F)$ incoherent" must be evaluated relative to the rules the learner *keeps*, and against the price of the rules that would have to go.

### 5.3 Meaning postulates: "1+1=2 won't be true if you assign 1→rabbit and 2→chicken"

In his note, the user lists "you specify properties of the thing or notion" as a separate route. Formally, a finite set $\mathrm{Ax}$ of sentences, endorsed as constitutive of the notion, enters as **designated premises**. Coherence is then checked in contexts $A\cup\mathrm{Ax}$, or as hard constraints on hypotheses. These are Carnap's (1952) meaning postulates, or the user's "axioms/inference rules involving the notion".

**Proposition 5.4 (postulates are rate-independent and rescue cheap fallacies) [proved; (a) re-quantified after verification].**
* **(a)** Assume Thm 5.2's hypotheses at each $c$, with $\mathrm{Ax}$ added to the designated contexts.
  * Then, up to zero-value ties, $F\notin S^*(c)$ iff $\rho_F\le c$ or some witness of $F$ lies inside $V_+(c)=\{v:\rho_v>c\}$.
  * Consequently $F$ is excluded at *every* $c$ iff some witness $W$ of $F$ consists of valid rules with $\rho_w\ge\rho_F$ for all $w\in W$. Equivalently, $V_+(c)\cup\mathrm{Ax}\cup\mathcal G(F)\vdash\bot$ from a designated context for every $c<\rho_F$.
  * "Rate-independent" means that the exclusion does not depend on $\rho_F$ being small. It needs only that the witness rules are kept, i.e. out-rate $F$.
  * The postulates themselves are designated premises, not learned rules, so they carry no rate.
  * For FD the witness rule is substitution of equals, with rate $4.07\cdot10^{-2}$, far above $\rho_{\rm FD}=2.46\cdot10^{-3}$ [computed: c4].
* **(b) Freshman's dream.** Let $\mathrm{Ax}_{\rm num}=\{1+1=2,\ 1^2=1,\ 2^2=4,\ 4\neq2\}$, and let substitution of equals be in $V_+$. The FD instance $(1+1)^2=1^2+1^2$ rewrites to $2^2=1+1$ and then to $4=2$, contradicting $4\ne2$. So FD is excluded however frequent it is.
  * Without postulates, FD plus the ring rules derives $2ab=0$, and hence $2=0$. This is coherent, since FD holds in every commutative ring of characteristic 2, unless "$2\neq0$" or a numeral fact such as $4\ne2$ is designated.
  * The independent world channel, random numerical evaluation (Schwartz–Zippel; orchestrator idea 3), also refutes it.
* **(c) Readings.** Let a hypothesis include a reading $\rho$ of numerals. The demonstrations $\{(\text{"1"},\text{one rabbit}),(\text{"2"},\text{two chickens})\}$ fit both $\rho_{\rm num}$ (numeral ↦ cardinality) and $\rho_{\rm kind}$ (numeral ↦ animal kind) perfectly. Now impose the postulate $1+1=2$ with $+$ read as the sum (disjoint union) of collections:
  * under $\rho_{\rm kind}$, rabbits + rabbits is a collection of rabbits, not chickens, so the postulate fails;
  * under $\rho_{\rm num}$ it holds.
  
  So postulates eliminate misreadings that demonstrations cannot. This is Quine's gavagai with a cure.
* **(d) Limits.** Postulates eliminate exactly the readings outside $\mathrm{Mod}(\mathrm{Ax})$. If $\mathrm{Ax}$ is categorical, the residue is the isomorphic readings: L4's harmless symmetric alternatives. For first-order arithmetic it is the non-standard models (T2 Thm 3.8). So postulates shrink, but do not abolish, the Kripkensteinian residue (T2 Thm 6.4).

*Proof.*
* (a) For $c\ge\rho_F$, $\nu_F\le0$, so $F$ is out up to ties. For $c<\rho_F$, $F\in E_+$, and by Thm 5.2 $F\in S^*(c)$ iff no witness lies inside $V_+(c)$.
  * If some witness $W$ has $\min_{w\in W}\rho_w\ge\rho_F$, then $W\subseteq V_+(c)$ for every $c<\rho_F$.
  * Conversely, suppose every witness has a member of rate $<\rho_F$. There are finitely many witnesses, so we can pick $c\in(\max_W\min_{w\in W}\rho_w,\ \rho_F)$. At that $c$ no witness lies inside $V_+(c)$, and $F$ survives.
* (b) and (c) are direct checks.
* (d) is the definition of $\mathrm{Mod}$. ∎

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
   * The precise form is the kink theorem.
     * Shared-randomness models pay for partial knowledge once, so their frontier is the sufficiency line ("1 bit paying for 1 bit"), up to $O(\log d)$.
     * Product models get exponentially little from partial knowledge: about $2^{-m/2}$ bits/sample when $m$ bits are missing. So the product frontier is kinked at the simple model.
2. *His convex-hull argument is correct.* Selection by $\lambda K+\sum\mathrm{NLL}$ with $\lambda=cN$ traces the lower hull. The good model is the unique selection on a $c$-window iff its point is a vertex and no other hypothesis shares that point. His "derivative changes" is the vertex condition, and his "absolute bound on complexity" variant is the same family, parametrized by the Lagrange dual.
3. *His example works*, with a window of more than three orders of magnitude, and it works asymptotically. That contradicts the finite-window reading in L11.
   * The rigorous version (Thm 3.5, Cor 3.5a) needs the simple model to be "list-decodable" and the error set to be K-random.
   * There, every near-optimal hypothesis in the window correlates strongly with the simple model and memorizes almost none of the errors.

**Where it fails, and why.**
1. **The steeper penalty is validity-blind; it sorts by rate.** It encodes the empirical bet that *norms are high-rate structure and errors are low-rate structure*.
   * The bet is right for idiosyncratic slips: memorized wrong facts, one-off misreadings, errors random relative to the norm.
   * It is wrong for the errors that matter most, which are systematic in the everyday sense: cheap, natural, frequent fallacies. Those are short variants of valid patterns, often subsidized by them (§4.4 (d3)).
   * It also costs rare valid rules and, worse, rarely-exercised guards (Prop 4.4). Whenever a guard's rate is below that of its unguarded schema, the learner can end up *less* sound than its teacher.
2. **The good $c$ cannot be found from imitation data** (Thm 4.3).
   * Every proper-score validation criterion targets the teacher's channel (Thm 4.3(ii)).
   * Non-proper heuristics can do better in a given world. For example, take the interior hull vertex (one with a bounded $c$-interval) whose $\log c$-interval is widest: the "knee". This heuristic selects the good model in the user's example, where that interval spans a factor of about 8000.
   * But by Thm 4.3(iii) no imitation-only criterion is right in both twin worlds of Thm 4.1(iv).
   * Choosing $c$ is a normative act, not an estimate.
3. **Private randomness is fragile.** The defence holds only if inputs carry no other labelled behaviour of the same human (Prop 2.6). A whole-document imitator learns each human's systematic errors in context, at a per-block price.

**What does the normativity work.** His own list, read through these results:
* (ii) "a simplicity prior defined in terms of existing understanding" helps only if existing understanding does *not* make human errors cheap (§4.4 (d6)).
* (iii) "specifying properties of the notion" is decisive. Postulates are a separate channel, avowal rather than performance. They kill high-rate fallacies at every $c$, provided the valid rules in the witness out-rate the fallacy, as substitution of equals out-rates the freshman's dream (Prop 5.4).
* (iv) "what is this person trying to teach me" corresponds to a teacher model with a competence/performance split. The Armstrong–Mindermann theorem warns that simplicity alone does not identify such splits: for irrational agents, the degenerate planner–reward decompositions are simpler (Armstrong & Mindermann 2018, NeurIPS, "Occam's razor is insufficient to infer the preferences of irrational agents" **(unverified details)**). This is Thm 4.1 in another guise.
* His chair remark ("should the person who taught me consider it a chair") is, in these terms, the claim that the target is *not a function of $P^*$*. Thm 4.1(iv) makes that literal: no amount of imitation data fixes it.

**The division of labour** (Thm 5.2), as a one-line slogan:
* simplicity removes the *expensive* errors;
* coherence removes the *incoherent* ones;
* world feedback removes the *refutable* ones;
* postulates remove those that *violate the notion's avowed properties*;
* what survives is the cheap, frequent, coherent, empirically adequate alternatives. Those are alternative meanings humans actually use, such as "if" as "iff" in closed worlds. For these, deciding that they are errors is itself a normative decision outside the data. It may sometimes be wrong: conditional perfection is arguably part of the meaning of everyday "if".

**Depth, honestly.**
* *TOSU or standard:* Lemma 1.2, Thm 2.1, Prop 2.2, Prop 2.3, Lemma 2.5a (the Parseval list-size bound for the Hadamard code, as in Goldreich–Levin and Kushilevitz–Mansour), Lemma 3.1, Thm 3.2, Thm 4.1, Thm 4.3, Thm 5.2, Prop 5.4. Their value is the precise statement of when the user's proposal works.
* *Mildly new, as far as I know:*
  * the product-model structure function and the kink theorem (Thm 2.5), proved by combining list-decoding with the coding theorem, and sharpened by the concentration-plus-coding Lemma 2.5c;
  * the idealized rate-threshold theorem with arbitrary hypotheses (Thm 3.3), whose identification constants were corrected after verification;
  * the all-shapes corollary for product hulls (Cor 3.4, up to the stated bands).
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
* Goldreich, O., Levin, L. A. (1989). A hard-core predicate for all one-way functions. *STOC 1989*. ✓ (added after verification)
* Grünwald, P. (2007). *The Minimum Description Length Principle*. MIT Press. ✓
* Grünwald, P. (2012). The safe Bayesian: learning the learning rate via the mixability gap. ALT 2012. ✓
* Grünwald, P., van Ommen, T. (2017). Inconsistency of Bayesian inference for misspecified linear models, and a proposal for repairing it. *Bayesian Analysis* 12(4). ✓
* Hoeffding, W. (1963). Probability inequalities for sums of bounded random variables. *JASA* 58(301):13–30. ✓ (§6: sampling without replacement; added after verification)
* Kushilevitz, E., Mansour, Y. (1993). Learning decision trees using the Fourier spectrum. *SIAM J. Comput.* 22(6). ✓ (added after verification)
* Kolmogorov, A. N. (1974). Talk at the Information Theory Symposium, Tallinn (structure function; unpublished; as reported by Cover and by Vereshchagin–Vitányi). ✓
* Li, M., Vitányi, P. *An Introduction to Kolmogorov Complexity and Its Applications* (3rd ed. 2008). ✓
* Lieberman, E., Michel, J.-B., Jackson, J., Tang, T., Nowak, M. (2007). Quantifying the evolutionary dynamics of language. *Nature* 449:713–716. ✓ (exponent u)
* Rissanen, J. (1978). Modeling by shortest data description. *Automatica* 14:465–471. ✓
* Sion, M. (1958). On general minimax theorems. *Pacific J. Math.* 8(1):171–176. ✓ (added after verification)
* Shtarkov, Y. (1987). Universal sequential coding of single messages. *Problems Inform. Transmission* 23(3). ✓
* Vereshchagin, N., Vitányi, P. (2004). Kolmogorov's structure functions and model selection. *IEEE Trans. IT* 50(12):3265–3290. ✓ (exact realizability side conditions u)
* Vereshchagin, N., Vitányi, P. (2010). Rate distortion and denoising of individual data using Kolmogorov complexity. *IEEE Trans. IT* 56(7):3438–3454. ✓
* Vereshchagin, N., Shen, A. (2017). Algorithmic statistics: forty years later. In *Computability and Complexity*, LNCS 10010. ✓
* Zhang, T. (2006). From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation. *Ann. Statist.* 34(5):2180–2210. (u)
* Project memos: T1 (Prop 2.3, Thm 4.2, Thm 5.3, Thm 6.4, Cor 6.5), T2 (Lemma 2.1, Thm 3.1, Thm 3.8, Thm 6.1, Cor 6.2, Prop 6.3, Thm 6.4, §6 examples), L4 §7, L11 (Lemma 2.1, Prop 2.2).

---

## Verification log

Two independent adversarial referees checked this file: Referee A covered §§1–2, and Referee B covered §§3–6. Their full reports are reproduced in `verification/T5-verification.md`. I re-checked every reported issue myself, using computation where useful. Severity tags are the referees' own.

**Re-checks run.**
* Re-runs of `T5-checks/c1`–`c5`. Every number quoted in the file reproduces.
* `T5-checks/c3_rate_threshold.py`. Its vacuous on-hull test was repaired, and its result is unchanged.
* New script `T5-checks/repair_checks.py`, which covers:
  * the Thm 3.3 counterexample and the corrected constants;
  * the minimax example for Thm 2.1;
  * the $p$-crossover for Thm 2.5(b);
  * the identity and concentration behind Lemma 2.5c;
  * the $o(1)$ bound for Thm 2.5(a);
  * the telescoping identity for Prop 2.6, and the exact norm-model loss in c5;
  * the hull example for Thm 4.1(iii);
  * the illustration after Thm 4.1;
  * the three-option hull for Prop 4.4;
  * the bundle example for (d3);
  * the Kraft construction for (d6);
  * the counterexamples for Cor 5.2a and for Thm 5.2 step 4;
  * the numbers for Cor 3.5a.

**Outcome in brief.**
* **One fatal issue, genuine.** Identification clause 2 of Thm 3.3 was false: its proof used $1-\log_2(1+2^{1-t})\ge1-2^{1-t}$, which goes the wrong way. The constants are now corrected, and the proof of the two-sided estimate is rewritten with the exact risk floor. $\Delta_0$ is unchanged.
* No issue was labelled major.
* Every minor issue was genuine and has been fixed or made precise. No issue was rejected.
* The most substantive minor repair is to Thm 2.5(b): the $2p$ slack meant no kink was shown for $p\ge0.142$. A new Lemma 2.5c, combining concentration with coding, replaces the slack by $O(\sqrt{p(\delta_E+\log n)/n})$ for incompressible $E$.
* Cor 3.5a (identification in the parity example) is new.

### Referee A (§§1–2)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | §1.2–1.3 setup (causal conditioning; $K(h)$ as a minimum; objects outside the class) | minor | yes | **Fixed.**<br>• Def 1.1 now separates causally conditioned from general shared-randomness hypotheses, and notes that they coincide for a fixed $x_{1:N}$, which is all §2 uses.<br>• $K(h):=\min\{\lvert p\rvert:p\text{ computes }h\}$, with $h^*$ a shortest program.<br>• §1.3 declares an *enlarged class* (lower-semicomputable semimeasures, computable real-valued predictors) used only by Prop 2.3 ($M$), Thm 2.4 ($m$) and Prop 2.6 for infinite families. Each of these results now says so. |
| A2 | Lemma 1.2 | ok | n/a | **Clarified.** "On the same event" is added, as is a line proving that both minimizers exist (finite sublevel sets under Kraft). |
| A3 | §1.4 literature | ok | n/a | No change. |
| A4 | Thm 2.1 (minimax value; group condition) | minor | yes | **Fixed.**<br>• I confirmed the referee's example by optimization: $\max_Q\sum H(Q_x)=\min_h\max_f=2.5431<2.5850$.<br>• The exact minimax value is now stated as $\max_Q\sum_iH(Q_{x_i})$, via Sion's theorem.<br>• The value equals $\sum\log\lvert F(x_i)\rvert$ iff a uniform-marginal $Q$ exists.<br>• The group condition is rephrased as $(g\cdot f)(x)=\sigma_{g,x}(f(x))$ with the induced action transitive on each $F(x)$. The proof that $\mathrm{Unif}(F)$ then has uniform marginals is added. |
| A5 | Prop 2.2 | ok | n/a | No change. |
| A6 | Prop 2.3 (§0 threshold) | minor | yes | **Fixed.**<br>• §0 now gives the threshold as $c_M+O(1)/(\lambda-1)$.<br>• The body gives $c_M+(c_M+c_0)/(\lambda-1)$, notes that it tends to $c_M$ (not to 0) as $\lambda\to\infty$, places $M$ in the enlarged class, and names $P_u$ as an in-class stand-in. |
| A7 | Thm 2.4 | ok | n/a | **Clarified.** The phrase is now "fixed predictor whose odds are bounded by a machine constant", and $m$ is placed in the enlarged class. |
| A8 | Lemma 2.5a | minor | yes | **Fixed.** The lemma is stated for $t\in\mathbb N$ ($\lceil t\rceil$ for real $t$). It is labelled standard and credited to Goldreich–Levin (1989) and Kushilevitz–Mansour (1993). Thm 2.5(b) and Thm 3.5 now quantify over $t\in\mathbb N$. |
| A9 | Lemma 2.5b | ok | n/a | **Clarified.** A tightness remark is added: the additive $p$ cannot be removed using $\hat s_h(a)$ alone. This motivates Lemma 2.5c. |
| A10 | Thm 2.5(a) (flatness and selection only via upper bounds) | minor | yes | **Fixed (statement and proof revised).**<br>• Added $K(P_u)\ge d-u-\kappa'$. Proof: the argmax of $P_u(f_{a'})$ has the true prefix, because $\frac n2\log_2\frac{1-p}p>d$.<br>• Added $-\log P_u(y^*)\ge u+nH(p)-o(1)$. The other components lose by a factor $(p/(1-p))^{n(1/2-2p)}$; the $o(1)$ is $<2^{-2800}$ bits at $d=10$.<br>• The selection claim is now $d-u^*\le\frac{\lambda}{\lambda-1}(2\kappa'+o(1))$, which is vacuous for $\lambda-1\lesssim\log d/d$. It is exact ($u^*=d$) in the computable version.<br>• The assumption $K(p)=O(\log d)$ is made explicit in the §2.2 setting, with the remark that $K(\lvert E\rvert)$ can be of order $d$ otherwise.<br>• §0 is updated. |
| A11 | Thm 2.5(b) (2p slack; "worthless" overstatement), Reading, §2.4 | minor | **yes** | **Fixed (new Lemma 2.5c; (b) restated).**<br>• I confirmed the crossover: $1-2p/\ln2=H(p)$ at $p=0.14215$.<br>• I took the referee's second suggestion. **Lemma 2.5c** shows that $R(h)\ge1-\log_2(1+(1-2p)\hat s_h(a)+\varepsilon_h)$ with $\varepsilon_h=\sqrt{32\ln2\cdot p(\delta_E^++K(h)+\kappa_n)/n}$.<br>• *Proof of 2.5c.* An exact identity (checked to machine precision) shows that $\mathbb E_xh(y^*\mid x)$ depends on $E$ only through the average of $\sigma_h=s_h\chi_a$ over $E$. Hoeffding (1963) for sampling without replacement bounds the number of $pn$-sets with deviation $\ge\eta$. A coding argument then bounds the deviation of the actual $E$ by $\delta_E+K(h)+O(\log n)$.<br>• Thm 2.5(b) now has slack $\beta_t=\min\{2^{-t}+2p,(1-2p)2^{-t}+\varepsilon_E\}$. The text states that the unconditional term shows a kink only for $p<0.1421$, while the second shows one for all $p<1/4$ once $\varepsilon_E$ is small.<br>• The "worthless / buys nothing" phrasing in the Reading, §2.4, §0 and §6 is replaced by the exponential-decay statement (advantage $\le2^{-m/2+O(\log d)}$ plus slack). The c2(b) list mixtures, at $2^{-u}(1-H(p))$, show that the true decay is between $1/2$ and $1$ in the exponent.<br>• Two caveats are added: the kink is shown only up to $O(\log d)$ bits, and the unconditional slack leaves a chord gap for small $K(h)$.<br>• Thm 3.5 uses the new $\beta_t$. |
| A12 | Thm 2.5(c) (missing $2\log_2d$) | minor | yes | **Fixed.** $K(y^*\mid h^*,d)$ is now used, so (c) reads $K(h)+nR(h)\ge d+L_E-\delta_E-2\log_2d-\kappa$. The change is propagated to Thm 3.5 ($K_{\rm tot}$), where the second lower-bound term stays valid because $K_{\rm tot}-d+\tau_t=L_E-\delta_E+s(t)$. |
| A13 | Prop 2.6 (complexity bound; proof) | minor | yes | **Fixed.**<br>• The family is now *uniformly computable* with computable $w$, and $K(h_w)\le K(w,(\nu_\theta)_\theta)+O(1)$.<br>• A note covers rational outputs for finite families, the enlarged class for infinite ones, and possible non-computability for arbitrary families.<br>• The proof now writes out the telescoping $\prod h_w=Z_{\lvert b\rvert+1}/Z_1$, valid for history-dependent $\nu_\theta$ and history-dependent inputs. It was checked numerically ($4\cdot10^{-15}$).<br>• The c5 copier is described as a finite family. |
| A14 | Prop 2.6 consequence (c5 numbers) | ok | n/a | **Clarified.** The exact norm-model loss of 4.635 bits per context (recomputed) is quoted, with a note that c5's 4.52–4.76 spread is Monte Carlo noise. |
| A15 | §2.3 design consequence | ok | n/a | No change. |
| A16 | Scripts c1, c2, c5 | ok | n/a | No change. |

### Referee B (§§3–6)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Thm 3.3 identification clause 2 | **fatal** | **yes** | **Fixed (statement revised).**<br>• I reproduced the counterexample: $q\in\{0.74,0.745,0.749\}$ and $\kappa\in\{10,100,1000\}$ all satisfy the old hypotheses, with $\hat s<\frac12$.<br>• New clause 2: $\pi_j\,g(d_j/4)>c\,d_j+\Delta$ and $\pi_j\,g(2)>\Delta+8c$, where $g(t)=1-\log_2(1+2^{1-t})$ is concave and increasing. These are implied by $\pi_j>c\,d_j+\Delta+\pi_j2^{1-d_j/4}/\ln2$ and $\pi_j>2.41(\Delta+8c)$.<br>• The proof now uses the exact floor and concavity on $[2,d_j/4]$.<br>• [computed] 0 violations in 8474 random admissible instances. The counterexample fails the new second condition, by a factor of 1.01–1.06.<br>• The constant $1/g(2)$ is optimal for this method.<br>• I did not adopt the referee's alternative (keep the hypotheses and conclude $\hat s\ge\sqrt2-1$). With the $s(t)\le4t$ bound used in the proof, the $t=3$ branch needs $0.678\pi>\Delta+12c$, which $\pi>2\Delta+16c$ does not imply, so that variant would need a finer argument. |
| B2 | Thm 3.3 two-sided estimate (proof step) | minor | yes | **Fixed (proof rewritten; statement unchanged).**<br>• The false inequality is removed. The per-region bound now uses $g$, concavity on $[1,d_j/4]$, and the referee's two-case absorption argument: $\log_2(1+u)-u\le0.443u$ and $0.886\,d\,2^{-d/4}\le4$, with maximum 1.88.<br>• The $d_j<4$ case is handled separately.<br>• [computed] 0 violations over the referee's grid, with both $s(t)$ and $4t$. |
| B3 | Thm 3.3 clause 1 | ok | n/a | No change. The per-region bound it relies on is now correctly proved (B2). |
| B4 | Cor 3.4 | minor | yes (all 3 points) | **Fixed (statement made precise).**<br>• The coin region contributes "at least $\pi_0$, with equality for hypotheses uniform there".<br>• The Legendre-duality step is written out, giving the explicit sandwich $P(k+C')-\epsilon\le\breve\rho(k)\le P(k-C')+\epsilon$.<br>• The realizable class is stated: start at height 1, total drop $\le1$, rational slopes, integer lengths, up to the bands. "Any shape" is weakened to "any such shape after rescaling".<br>• §0 and §6 are updated. |
| B5 | Thm 3.5 / §0, §6 "the good model is selected" | minor | yes | **Fixed (new Cor 3.5a).** For $J_c(h)\le\Phi+\eta$:<br>• (i) $\hat s_h(a)\ge2^{1-c(d+\kappa')-H(p)-\eta}-1-2p$;<br>• (ii) if $cn>1$, $R(h)\ge H(p)-(\eta+c\Lambda)/(cn-1)$, i.e. almost no error memorization.<br>Numbers are computed for $d=20$. §0 and §6 now cite Cor 3.5a instead of saying "selected". |
| B6 | Thm 4.1 (ii),(iii); §0 "unique minimizer iff vertex" | minor | yes | **Fixed.**<br>• (ii) excludes the common tie value in Thm 3.2's setting, and holds outside the slack bands in Thm 3.3's setting, with a short proof via the clauses.<br>• $\mathrm{hull}^-(A)$ is now defined as the boundary part with finite negative slope; the ray example is included.<br>• Lemma 3.1(iii) and Thm 4.1(iii) distinguish points from hypotheses ("and no other hypothesis has the same point").<br>• Lemma 3.1's proof states that edge endpoints are in $A$ and that $s_+=0$ at the rightmost vertex.<br>• §0 and §6 are updated. |
| B7 | 200-bit-rule illustration | minor | yes | **Fixed.** The claim is now conditional on $g\le2.2$ bits (break-even 2.24). With $g=5.42$ the rule survives on $(1.12,2.7)\cdot10^{-6}$. The cross-setting caveat is added. |
| B8 | Prop 4.2 | ok | n/a | **Clarified.** The "not an accident" paragraph is labelled an empirical conjecture. |
| B9 | Thm 4.3 (i), §0 SafeBayes, §6 | minor | yes | **Fixed.**<br>• (i) is stated for a fixed finite grid as $N\to\infty$, with the finite-$N$ caveat (Lemma 1.2's $B/c$).<br>• §0 hedges the SafeBayes claim as an unchecked reading.<br>• §6 restricts the claim to proper-score validation, cites the knee heuristic as a non-proper criterion that succeeds in the user's example, and points to (iii) for the general impossibility. |
| B10 | Prop 4.4 (missing hypothesis; constant) | minor | yes | **Fixed (statement revised).**<br>• The three options and the rates $\rho_\sigma$ and $\rho_G=\pi_{\neg G}\Delta_G/k_G$, with $\Delta_G=\log_2(M/\eta)-\log_2(M-1)>\log_2(1/\eta)$, are explicit.<br>• Claim: if $\rho_G<\rho_\sigma$, the unguarded rule is selected exactly on $(\rho_G,\rho_\sigma)$. Otherwise the path goes guarded → none and stays sound.<br>• The referee's counterexample (selection path guarded → none at $3.2\cdot10^{-4}$) and the c4 instance (unguarded on $(1.8\cdot10^{-4},1.22\cdot10^{-2})$) are both reproduced.<br>• §0 and §6 are qualified. |
| B11 | Prop 4.5 | ok | n/a | No change. |
| B12 | (d3) ordering claim | minor | yes | **Retracted and replaced.** The selection path is now described as the hull of the subset lattice under the joint code, in which bundles can enter together. The referee's example ($\{v,e\}$ optimal at $c=1.5\cdot10^{-3}$ although both separate rates are $<c$) is included and recomputed. §0 is updated. |
| B13 | (d6) Kraft construction | minor | yes | **Fixed.**<br>• The construction now uses a common prefix $\ell_0=m$; the Kraft sum is $2^{-\ell_0}\prod(1+2^{-k_j})\le1$.<br>• It requires $r_j>0$ on $S^\circ$, and the invariance bound is now $2c_{UV}$.<br>• [computed] 0 failures in 3000 instances. |
| B14 | (d4), (d5), (d7) | ok | n/a | No change. |
| B15 | §5.1 | ok | n/a | **Clarified.** The rate is now $\pi g/(\ell+O(1))$. Net values in §5.2–5.3 are renamed $\nu_j$. |
| B16 | Thm 5.2 (step 4; intersection) | minor | yes | **Fixed (proof tightened).**<br>• Step 4 is replaced by a direct value comparison, and the referee's zero-value counterexample to the old step is included.<br>• The zero-valued $E_1$ case is written out.<br>• It is made explicit that $\mathfrak F$ is the intersection of the filters in use, and that the assumptions are imposed on it. |
| B17 | Cor 5.2a | minor | yes | **Fixed (hypotheses added).** The corollary now assumes error-independence and valid dominance at every $c$ considered. It characterizes separation at $c$ with strict inequalities and includes a proof. The referee's counterexample without valid dominance is reproduced. |
| B18 | Prop 5.3 | minor | yes | **Fixed.** Error-independence and "$F$ has a witness inside $V_+$" are stated as hypotheses. The vacuous clause is replaced by the explicit improving set $S'$, with a feasibility proof. The c4 caveat ($\mathcal A=\{\emptyset\}$; with substantive contexts, AC rather than →I is dropped) is added. |
| B19 | Prop 5.4(a) quantification | minor | yes | **Fixed (re-quantified).**<br>• $F$ is excluded at every $c$ iff some witness consists of valid rules with $\rho_w\ge\rho_F$. A proof is given, via a choice of $c$ between $\max_W\min_{w\in W}\rho_w$ and $\rho_F$.<br>• "Rate-independent" is explained, with the FD witness rate $4.07\cdot10^{-2}$.<br>• In (b), "only $2ab=0$" now reads "$2ab=0$ and hence $2=0$; coherent in characteristic 2".<br>• §0 and §6 are qualified. |
| B20 | §5.4 table | ok | n/a | No change. |
| B21 | Lemma 3.1 | ok | n/a | **Clarified.** The finiteness and $R\ge0$ hypotheses are made explicit in the proof, along with the edge endpoints in $A$ and $s_+=0$. |
| B22 | Thm 3.2 | ok | n/a | **Clarified.** The theorem now states finitely many regions and $k_j>0$. |
| B23 | c3 (ii) on-hull test vacuous | minor | yes | **Fixed.** The test now checks that each minimizer lies on a vertex or edge of the computed hull, and a sanity check confirms that it detects an off-hull point. The result is still 0 violations, and the [computed] note says the test was repaired. |
| B24 | c4 (and c1, c2) re-run | ok | n/a | No change. |
| B25 | §0/§6 wording; literature | minor | yes | **Fixed.** §0 and §6 are aligned with every revised statement above. Lemma 2.5a is listed as standard, with citations to Goldreich–Levin and Kushilevitz–Mansour. Hoeffding (1963) and Sion (1958) are added to the references. |

**Items whose statement or proof changed non-trivially** (to re-verify): Thm 3.3 (clause 2 and the lower-bound proof), Thm 2.5(a)(b)(c) with the new Lemma 2.5c, Thm 3.5 (lower bound), new Cor 3.5a, Cor 3.4, Thm 2.1(i), Prop 2.6, Prop 4.4, (d3), (d6), Lemma 3.1 / Thm 4.1(ii),(iii), Thm 5.2 (proof), Cor 5.2a, Prop 5.3, Prop 5.4(a), and Thm 4.3(i).
