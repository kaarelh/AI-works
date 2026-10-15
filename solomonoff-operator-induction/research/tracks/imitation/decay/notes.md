# Track "imitation", sub-track "decay": λ = cn and weight decay (target I2)

*Brief: `../00-brief.md`, target I2, which makes the author's first bullet precise. This is the first record of the sub-track. Written 2026-10-14.*

* **Sources read.**
  * The brief, in full, including the author's message.
  * Paper 2 (`paper-steeper/sections/`):
    * `setup.tex` in full (`def:setup:data`, `def:setup:objectives`, `rem:setup:persample`, `lem:setup:hull`, `lem:setup:coding`);
    * `teacher.tex` in full (`rem:limits:schedule`, `prop:teacher:schedules`, `thm:teacher:main`);
    * `related.tex`, `discussion.tex`, `intro.tex` and `limits.tex` in full;
    * `recovery.tex`, by search, at `thm:recovery:main` and its proof idea;
    * `app-recovery.tex` at `lem:recovery:ratios` and at `prop:recovery:beyond` with its proof (c);
    * `app-related.tex` in full;
    * the subsection list of `app-teacher.tex`.
  * The split synthesis `research/tracks/split/notes-final.md`: §0–§4 in full, and the rest by search for λ = cn and the posterior statements.
  * `research/paper-review/REFRAME.md`, in full.
  * `paper-steeper/bib/all.bib`, for the generalised-posterior entries already in Paper 2.
* **Scripts** (in `checks/`; Python 3.11, NumPy 2.4.6, SciPy 1.17.1; deterministic or seeded; each output is saved next to its script):
  * `d1_no_fixed_prior.py` → `d1_no_fixed_prior.out`, parts (A)–(E): duplication, the two-program example, per-query simulation, the tempered posterior, the recursion.
  * `d2_weight_decay.py` → `d2_weight_decay.out`, parts (A)–(E): the logistic toy, empirical minimisers, SGD, AdamW against L2, per-step effects.
* **Status tags.**
  * **[proved]**: full proof here, or a one-line derivation from a cited proved result of Paper 2.
  * **[computed: dN(k)]**: checked by script dN, part (k).
  * **[known: ref]**: published. "Abstract level" means checked against the abstract as returned by a web search. "Body, via search excerpt" means a sentence of the paper body that a search returned; the paper was not read in full.
  * **[remark]**, **[heuristic]**, **[open]**, **[refuted]**: as named. A refuted claim is kept with its counterexample.
* **Conventions.**
  * $\log=\log_2$ and $\ln$ is natural. Code lengths and fits are in bits; network losses are in nats.
  * Notation follows Paper 2:
    * $h_n$ is a per-query (PQ) sample;
    * $L(\pi;h)=-\log\nu_\pi(h)$, $J_\lambda=\lambda\ell+L$, $\hat R_n(\pi)=L(\pi;h_n)/n$;
    * $R_\nu(\pi)=H_\mu(\nu)+\KL_\mu(\pi)$, $J_c=c\,\ell+R_\nu$, $A_c=\arg\min J_c$;
    * $\mathcal E$, $\mathcal E_0$, $\ell_0$ as in `def:split:setting`;
    * $c^*:=\min\{\KL_\mu(\pi)/(\ell_0-\ell(\pi)):\ell(\pi)<\ell_0\}$ as in `prop:recovery:beyond`;
    * $\Lambda_n(\pi)=\nu_\pi(h_n)/\nu(h_n)$.
  * The weight-decay coefficient is written ω, so that λ keeps its meaning. The AdamW decay coefficient is written λ_W where both appear.
* **Reading of the author's bullet.** "There not being a correspondence to Bayesian learning as the number of params varies" is read, as the brief reads it, as: λ = cn is not Bayesian learning with any fixed prior as the sample size n varies. The parameter that varies is n, the number of data points.
* **Repository.** No git command was run. Files written: this record, `refs.bib`, `checks/d1_no_fixed_prior.py`, `checks/d2_weight_decay.py` and their `.out` files. The draft LaTeX of §6 was compiled only in a scratch copy of Paper 2 outside the repository.

---

## 0. Summary

1. **λ = cn is a per-sample penalty** [proved; from `rem:setup:persample`, `prop:recovery:beyond`].
   * $J_{cn}(\pi;h_n)/n=c\,\ell(\pi)+\hat R_n(\pi)\to c\,\ell(\pi)+R_\nu(\pi)$, and the $cn$-MAPs end in $A_c=\arg\min J_c$.
   * The power-prior weight is $\prod_{i\le n}2^{-c\ell(\pi)}\nu_\pi(y_i\mid x_i)$, so each sample brings the prior factor again. This is the exact form of "it keeps going on each step" (§1).
2. **No fixed prior gives the $cn$-MAPs** (§2).
   * The simplest clean statement is the duplication argument [proved; computed: d1(A)]. The $cn$-MAPs depend on the sample only through its empirical distribution. Under a fixed prior with full support, a sample repeated often enough leaves only maximum-likelihood programs as MAPs. In $\Hcl{\times}$, for every $c>0$, there are samples on which the two rules then disagree.
   * Per query there is an almost-sure form [proved; computed: d1(C)]:
     * for $c>c^*$, the $cn$-MAPs eventually leave $\mathcal E$, while the MAPs of every summable prior that charges $\mathcal E$ end in $\mathcal E$;
     * for $c<c^*$, both end in $\mathcal E_0$ (with the prior $2^{-\ell}$).
   * A fixed λ is the fixed prior $2^{-\lambda\ell}$.
3. **The limit can keep a simpler, worse hypothesis** (§3) [proved].
   * For $c>c^*$ every eventual $cn$-MAP is shorter than $\ell_0$ and has larger risk.
   * Two-program example [proved; computed: d1(B)]: a coin of length 1 against a deterministic $f$ of length $1+k$. For $ck>1$ the coin is the $cn$-MAP at every $n$; its error rate on $f$-labelled data is 1/2. Every fixed λ switches to $f$ after $\lambda k$ samples.
   * The teacher window of Paper 2 is an instance: the selected hypotheses do not predict the teacher's errors.
4. **Weight decay** (§4).
   * With the loss averaged over $n$ samples, SGD with coupled weight decay ω descends $\hat L_n+\frac\omega2\|\theta\|^2$. That is MAP under $\mathcal N(0,(n\omega)^{-1}I)$, a prior whose precision grows linearly in $n$ [proved]. A fixed prior needs $\omega_n=\tau/n$.
   * The population minimiser minimises $L$ only if $0$ does [proved].
   * In a two-feature logistic toy it classifies worse [proved; computed: d2(A)–(C)]:
     * for every $\omega>\omega^*=2.101\cdot10^{-3}$ the regularised limit has error rate 0.2, against 0 for the population infimum;
     * $\omega=0.01$ gives 0.2 in all of 20 samples at every $n$ from $10^2$ to $10^6$;
     * $\omega=1/n$ gives 0 in all of 20 samples from $n=10^3$ on.
5. **What is not analogous** (§4.4):
   * $\|\theta\|^2$ is not a description length;
   * SGD iterates are not minimisers;
   * decoupled weight decay is a different objective (computed: d2(D), where its threshold is 0.103 instead of 0.0021);
   * per-step decay makes the effect before convergence depend on η·T, and in SGDW-style updates the effective coefficient depends on the learning rate (d2(E));
   * in deep networks explicit regularisation does not qualitatively stop the fitting of random labels.
6. **Literature** (§5): 15 new sources, each verified by WebSearch with bibliographic data, plus the 10 already in Paper 2. Each source is reported at abstract level, except where marked "body, via search excerpt".
7. **Draft for the paper** (§6):
   * a main-text remark `rem:teacher:weightdecay`, about 0.55 page, for after `rem:limits:schedule`;
   * an appendix subsection `app:teacher:weightdecay` with `prop:teacher:nofixedprior` and `ex:teacher:weightdecay`, about 1.4 pages;
   * one related-work sentence.

   In a scratch copy of Paper 2 these build with 0 errors, 0 undefined references and 0 undefined citations.

---

## 1. λ_n = cn as a per-sample penalty

**Proposition 1.1 (per-sample form and limit)** [proved: `rem:setup:persample`; `prop:recovery:beyond`(c) (= split/iid Prop 3.4)].
* Setting: a class as in `def:split:setting`, PQ data, $c>0$.
* $J_{cn}(\pi;h_n)/n=c\,\ell(\pi)+\hat R_n(\pi)$.
* Almost surely $\hat R_n(\pi)\to R_\nu(\pi)$ for all π at once.
* $A_c$ is nonempty and finite, and almost surely every $cn$-MAP lies in $A_c$ for all large $n$.

For a fixed λ the per-sample objective is $(\lambda/n)\ell+\hat R_n$: the penalty's share vanishes like $1/n$. For λ = cn it is constant. "A regularisation that does not vanish with data" means exactly this.

**Remark 1.2 (the prior factor is paid once per sample)** [proved; computed: d1(E)].
* The power-prior weights satisfy
  $$2^{-cn\ell(\pi)}\nu_\pi(h_n)=\prod_{i\le n}\big[2^{-c\ell(\pi)}\,\nu_\pi(y_i\mid x_i)\big],$$
  so, normalised, $\Pi_{cn}(\pi\mid h_n)\propto\Pi_{c(n-1)}(\pi\mid h_{n-1})\cdot\nu_\pi(y_n\mid x_n)\cdot2^{-c\ell(\pi)}$. Normalisation is finite once $cn\ge1$, by Kraft.
* Bayes' rule with a fixed prior multiplies only by the likelihood term. Here every update multiplies by the prior factor $2^{-c\ell}$ again.
* So $\Pi_{cn}$ is the loss-based update, in the sense of generalised Bayes, with per-sample loss $-\log\nu_\pi(y\mid x)+c\,\ell(\pi)$ from a flat initial weight. That weight is improper on an infinite class.
* This is the precise sense in which λ = cn, like weight decay, "keeps going on each step".
* Check: d1(E) finds $\max|\text{recursive}-\text{direct}|=4.33\cdot10^{-15}$ over $n\le50$.

**Remark 1.3 (the tempered posterior with learning rate 1/(cn) does not concentrate)** [proved; computed: d1(D)].
* In Paper 2's notation $\Pi^\eta(\pi)\propto2^{-\ell(\pi)}\nu_\pi(h_n)^\eta$. With $\eta=1/(cn)$ this is $\Pi^{1/(cn)}(\pi\mid h_n)\propto2^{-\ell(\pi)-\hat R_n(\pi)/c}$.
* Its MAP is the $cn$-MAP.
* As $n\to\infty$ it converges almost surely in total variation to the fixed Gibbs measure $G_c(\pi)\propto2^{-\ell(\pi)-R_\nu(\pi)/c}$, with $R_\nu=\infty$ giving weight 0. This needs some π with $R_\nu(\pi)<\infty$.
* *Proof.* Almost surely $\hat R_n(\pi)\to R_\nu(\pi)$ for all π at once (strong law; to $+\infty$ when $R_\nu(\pi)=\infty$). The weights are dominated by the summable $2^{-\ell}$. Dominated convergence gives convergence of the normaliser to $Z_c>0$, and Scheffé's lemma gives convergence in total variation. ∎
* So with λ = cn the data never overwhelm the prior: the generalised posterior's learning rate $1/(cn)$ decays like $1/n$. The power-prior posterior $\Pi_{cn}$ does concentrate, on $A_c$.
* d1(D), c = 0.02: the total-variation distance to $G_c$ is 0.084, 0.00023, 0.025, 0.00074 and 0.0011 at $n=10^2,10^3,10^4,10^5,2\cdot10^5$. The fluctuations are of order $n^{-1/2}/c$. The power-prior mass on $\arg\min J_c$ is $1.000000$ from $n=10^4$.

**Remark 1.4 (fixed λ is a fixed prior)** [proved].
* For fixed λ the λ-MAPs are the MAPs of the fixed prior $w_\lambda=2^{-\lambda\ell}$, which is summable for λ ≥ 1 by Kraft.
* $\Pi_\lambda$ is Bayes' posterior for that prior, and $\xi_\lambda$ is one Bayesian predictor (Paper 2's `rem:setup:persample`).
* So the steeper prior of the split thread is Bayesian learning with a different fixed prior. Only λ growing with $n$ leaves Bayesian learning.

---

## 2. No fixed prior gives the cn-MAPs

**Definition 2.0.**
* A *fixed prior* is a map $w$ from programs to $[0,\infty)$ chosen before the data.
* Its MAPs on a per-query sample $h$ are the maximisers of $w(\pi)\nu_\pi(h)$; the set may be empty when $w$ is not summable.
* $w$ has *full support* if $w>0$ everywhere.
* $h^r$ is the sample $h$ repeated $r$ times (size $rn_0$).
* $\hat P_h$ is the empirical distribution of the pairs of $h$.

**Proposition 2.1 (the cn-MAPs depend only on the empirical distribution)** [proved; computed: d1(A)].
* For $c>0$ and samples $h,h'$ of sizes $n,n'$ with $\hat P_h=\hat P_{h'}$, the $cn$-MAPs of $h$ are the $cn'$-MAPs of $h'$.
* In particular the $crn_0$-MAPs of $h^r$ are the $cn_0$-MAPs of $h$.
* *Proof.* $J_{cn}(\pi;h)/n=c\,\ell(\pi)+\Ex_{\hat P_h}[-\log\nu_\pi(y\mid x)]$. ∎
* d1(A): in 1998 random finite classes, with the replicated sample's fit computed from the replicated sample itself, the set is equal for $r=2,3,7,50$ in 1998 of 1998.

**Proposition 2.2 (no fixed prior with full support gives the cn-MAPs)** [proved; computed: d1(A)].
Let $c>0$ and let $h$ be a per-query sample of size $n_0$ such that:
* (a) $P^*:=\max_\pi\nu_\pi(h)>0$ is attained, by $\pi^*$ say;
* (b) no $cn_0$-MAP of $h$ attains $P^*$.

Let $M$ be the finite set of $cn_0$-MAPs of $h$ (`lem:setup:basic`), and $w$ a fixed prior with $w(\pi^*)>0$.
* (i) For every
  $$r>r_{\rm th}:=\max_{\hat\pi\in M,\,w(\hat\pi)>0}\frac{\log(w(\hat\pi)/w(\pi^*))}{\log(P^*/\nu_{\hat\pi}(h))}$$
  (and every $r\ge1$ if no $\hat\pi\in M$ has $w(\hat\pi)>0$), no $crn_0$-MAP of $h^r$ is a MAP of $w$ on $h^r$.
* (ii) Consequently no fixed prior with full support has MAP sets equal to the $cn$-MAP sets on all per-query samples. This holds for every class with such a sample.
* (iii) In $\Hcl{\times}$, for every $c>0$, such samples exist.

*Proof.*
* (i) By Proposition 2.1 the $crn_0$-MAPs of $h^r$ are the programs of $M$. Each $\hat\pi\in M$ has $J_{cn_0}(\hat\pi;h)<\infty$, so $0<\nu_{\hat\pi}(h)<P^*$.
  * If $w(\hat\pi)=0$, then $w(\hat\pi)\nu_{\hat\pi}(h)^r=0<w(\pi^*)(P^*)^r$.
  * Otherwise $w(\hat\pi)\nu_{\hat\pi}(h)^r<w(\pi^*)(P^*)^r$ is equivalent to $r\log(P^*/\nu_{\hat\pi}(h))>\log(w(\hat\pi)/w(\pi^*))$.

  In both cases $\hat\pi$ is beaten by $\pi^*$ on $h^r$.
* (ii) is immediate from (i) at any $r>r_{\rm th}$.
* (iii) Let $Y$ be finite with $|Y|\ge2$, and let $\ell_{\rm u}$ be the length of a fixed program for the uniform kernel on $Y$. Take $n_0$ distinct inputs with $n_0\log|Y|-\kappa-\ell_{\rm u}>\log|Y|/c$, and labels $y\in Y^{n_0}$ with $K(y\mid\dom D)\ge n_0\log|Y|$. Such labels exist by counting.
  * The lookup program for $D$ has likelihood $1=P^*$ (on distinct inputs the PQ likelihood is the data-set likelihood), so (a) holds.
  * By `lem:setup:coding`, every program π with $\nu_\pi(h)=1$ has $\ell(\pi)\ge K(y\mid\dom D)-\kappa\ge n_0\log|Y|-\kappa$.
  * So $J_{cn_0}(\pi)\ge cn_0(n_0\log|Y|-\kappa)>cn_0\ell_{\rm u}+n_0\log|Y|=J_{cn_0}(\text{uniform})$, and (b) holds. ∎

*Computation.* d1(A): 671 of the 1998 random samples satisfy (a), (b).
* In all 671, at $r=\lfloor r_{\rm th}\rfloor+1$ the w-MAP set is disjoint from the $cn$-MAP set; the largest $r_{\rm th}$ is 11398.1.
* In 594 of them the w-MAP set already lies inside the ML set at that $r$. Programs outside $M$ can need larger $r$, so this is not claimed.
* In the other 1327 samples some $cn_0$-MAP is an ML program, and duplication gives no contradiction.

**Proposition 2.3 (per query: the eventual form)** [proved; computed: d1(C)].
Let the data be PQ in a class as in `def:split:setting` with $\mathcal E\ne\emptyset$. Let $w$ be a fixed prior with $\sum_\pi w(\pi)<\infty$ and $w(\pi)>0$ for some $\pi\in\mathcal E$, and put $W:=\max_{\mathcal E}w$, which is attained.
* (i) Almost surely, for all large $n$, the MAPs of $w$ are exactly $\mathcal E_w:=\{\pi\in\mathcal E:w(\pi)=W\}$.
* (ii) If $c>c^*$:
  * every $\pi\in A_c$ has $\ell(\pi)<\ell_0$, $\pi\notin\mathcal E$ and $R_\nu(\pi)>R_\nu(\pi_0)=H_\mu(\nu)$;
  * almost surely, for all large $n$, every $cn$-MAP lies in $A_c$.

  So the $cn$-MAP sets and the $w$-MAP sets are eventually disjoint, for every such $w$.
* (iii) If $c<c^*$, almost surely the $cn$-MAPs and the MAPs of $2^{-\lambda\ell}$, for any λ ≥ 1, are both $\mathcal E_0$ for all large $n$. The case $c=c^*$ is not covered.

*Proof.*
* (i) Let $G$ be the event that every sampled $x_i$ lies in $\{x:\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)\ \forall\pi\in\mathcal E\}$ and that $\nu(h_n)>0$ for all $n$. $\mathcal E$ is countable, so $G$ has probability 1.
  * On $G$, $\nu_\pi(h_n)=\nu(h_n)$ for π ∈ $\mathcal E$, so every $w$-MAP $\hat\pi$ has $w(\hat\pi)\Lambda_n(\hat\pi)\ge W$.
  * Enumerate the programs as $\pi_1,\pi_2,\dots$ and let $T_k:=\{\pi_j:j>k\}$. $Z^k_n:=\sum_{\pi\in T_k}w(\pi)\Lambda_n(\pi)$ is a nonnegative supermartingale with $Z^k_0=w(T_k)$, by `lem:recovery:ratios`(a) applied termwise.
  * By Ville's inequality, $\Prob[\exists n:\text{some }w\text{-MAP lies in }T_k]\le\Prob[\sup_nZ^k_n\ge W]\le w(T_k)/W\to0$. So almost surely all $w$-MAPs at all $n$ lie in some finite $\{\pi_1,\dots,\pi_k\}$.
  * Among these, programs outside $\mathcal E$ have $\Lambda_n\to0$ almost surely (`lem:recovery:ratios`(c): $\frac1n\log\Lambda_n\to-\KL_\mu<0$, and $\KL_\mu>0$ iff $\pi\notin\mathcal E$). So eventually they are not $w$-MAPs.
  * Programs of $\mathcal E$ with $w<W$ never are, and programs of $\mathcal E_w$ attain the maximum $W$.
* (ii)
  * There is $\pi'$ with $\ell(\pi')<\ell_0$ and $\KL_\mu(\pi')/(\ell_0-\ell(\pi'))<c$, that is $J_c(\pi')<J_c(\pi_0)$.
  * For $\pi\in\mathcal E$, $J_c(\pi)=c\,\ell(\pi)+H_\mu(\nu)\ge J_c(\pi_0)$.
  * For $\pi\notin\mathcal E$ with $\ell(\pi)\ge\ell_0$, $J_c(\pi)>J_c(\pi_0)$.

  So minimisers of $J_c$ lie outside $\mathcal E$ and are shorter than $\ell_0$, with $R_\nu=H_\mu(\nu)+\KL_\mu>H_\mu(\nu)$. The rest is `prop:recovery:beyond`(c).
* (iii) For $c<c^*$, $A_c=\mathcal E_0$ (`prop:recovery:beyond`(c)), and (i) with $w=2^{-\lambda\ell}$ gives $\mathcal E_w=\mathcal E_0$. ∎

*Computation.* d1(C) uses 8 inputs, a sampler $(f,p=0.1)$ and five programs:
* $\pi_0=(f,p)$, $\ell=10$;
* a longer copy $\pi_0'$, $\ell=14$;
* $(f,1/8)$, $\ell=9$, KL = 0.00438;
* $(f',p)$, $\ell=6$, KL = 0.317;
* coin, $\ell=2$, KL = 0.531.

Then $c^*=0.00438$, and the population minimiser is $\pi_0$ at $c=0.003$, $(f,1/8)$ at $c=0.02$ and the coin at $c=0.1$. Over 20 seeds at $n=10^5$ and $2\cdot10^5$:
* the $cn$-MAPs are $\pi_0$, $(f,1/8)$ and the coin, respectively, in all 20 seeds;
* the MAPs of $2^{-\ell}$ and $2^{-2\ell}$ are $\pi_0$ in all 20;
* the MAP of a random summable prior is $\pi_0'$ in all 20, the program of $\mathcal E$ with the largest weight under that prior, as (i) says.

**Example 2.4 (two programs; the minimal "simpler and worse in the limit")** [proved; computed: d1(B)].
* Class: $\{\text{coin}$ (length 1, $\nu(y\mid x)=1/2$), $f$ (deterministic, length $1+k)\}$; Kraft holds. Data: per query, labelled by $f$, any input law.
* $J_{cn}(\text{coin})=cn+n$ and $J_{cn}(f)=cn(1+k)$, so the coin is the unique $cn$-MAP at every $n\ge1$ iff $ck>1$. At $ck=1$ the two tie at every $n$.
* For fixed λ, $f$ is the unique λ-MAP iff $n>\lambda k$.
* Here $\mathcal E=\{f\}$, $\ell_0=1+k$ and $c^*=1/k$ (KL of the coin = 1 bit).
* So for $c>1/k$ λ = cn keeps the coin forever: randomised error rate 1/2 against 0. Every fixed prior with $w(f)>0$ switches to $f$ once $n>\log(w(\text{coin})/w(f))$.
* d1(B), $k=10$: $c=1/20$ gives $f$, $1/10$ gives a tie and $1/5$ gives the coin, at $n=1,10,10^3,10^6$. For λ = 1, 2, 5 the least $n$ with $f$ the unique MAP is 11, 21, 51.

**Remark 2.5 (other schedules and other data objects)** [proved where marked; otherwise not pursued].
* (a) *Schedules with $\lambda_n/n\to c>0$* [proved].
  * On $h^r$ the $\lambda_{rn_0}$-MAPs are the $(\lambda_{rn_0}/r)$-MAPs of $h$ (`lem:teacher:reuse`), and $\lambda_{rn_0}/r\to cn_0$.
  * If $cn_0$ lies strictly inside a vertex interval of $h$'s hull (`lem:setup:hull`(v)), these are eventually the $cn_0$-MAPs. Proposition 2.2 then applies unchanged.
* (b) *Schedules $\lambda_n=o(n)$.* $\lambda_{rn_0}/r\to0$, so duplication drives both rules to maximum likelihood, and it gives no contradiction.
  * Per query they agree eventually with the prior $2^{-\ell}$ (Theorem A(a)).
  * Whether a non-constant $o(n)$ schedule is a fixed-prior MAP rule at finite $n$ depends on the class. Through the pairwise threshold, $\pi$ beats $\pi'$ iff $\log(\nu_\pi/\nu_{\pi'})>-\lambda_n(\ell(\pi')-\ell(\pi))$ against a fixed threshold. It is not needed here [not pursued].
* (c) *Frozen labels and one data set.* On a data set (DS, FR) a repeated query adds nothing, so the data set $D$ stays fixed while $n$ grows. The $cn$-MAPs of $D$ are its λ-MAPs at λ = cn. They change with $n$ whenever the hull of $D$ has a vertex whose λ-interval ends inside $(cn_0,\infty)$ (`lem:setup:hull`(v)), while every fixed prior's MAP on $D$ is the same for all $n$ [proved]. The per-query form above is the one that matches "as the number of samples grows".

**Refuted: an over-reading** [refuted].
* The claim: "on typical data the $cn$-MAP eventually differs from the MAP of every fixed prior, for every $c>0$".
* Counterexample: Proposition 2.3(iii) and d1(C) at $c=0.003<c^*$. Both the $cn$-MAPs and the MAPs of $2^{-\ell}$ end at $\pi_0$.
* The difference on typical data in the limit appears exactly for $c>c^*$ ($c=c^*$ not covered). For every $c>0$ it appears on suitable samples (Proposition 2.2).

---

## 3. The limit: a simpler hypothesis that predicts worse

**Proposition 3.1** [proved: Proposition 2.3(ii)].
* For $c>c^*$ every eventual $cn$-MAP is shorter than the sampler's shortest program and has strictly larger expected log loss.
* Every fixed summable prior that charges $\mathcal E$ ends in $\mathcal E$, with the smallest possible expected log loss $H_\mu(\nu)$.

**Classification.**
* Larger log loss need not mean a worse classifier. In d1(C) at $c=0.02$ the limit $(f,1/8)$ has the sampler's argmax labels, so its error rate is the same 0.1 [computed: d1(C)].
* At $c=0.1$ the limit is the coin, with randomised error rate 0.5 against 0.1 [computed: d1(C)].
* Example 2.4 is the cleanest classification statement.

**The teacher thread is this phenomenon** [proved: Paper 2 and Proposition 2.3(i)].
* Take PQ data with $\nu=\delta_{y^*}$, the teacher's labels. Then $\mathcal E$ is the set of programs that reproduce $y^*$ μ-a.e. (risk 0).
* With $\lambda_n/n$ in a compact subset of the window $(2^{-m},c_{\rm hi})$ the $\lambda_n$-MAPs eventually satisfy `thm:teacher:main`(ii) (`prop:teacher:schedules`(c)). They know the parity and do not predict the errors: (ii)(e) bounds the average probability of the erroneous labels by $1-u+\gamma_g+2^{-g}$, at most 0.2–0.29 at the example's sizes.
* So they mislabel, in the randomised sense, at least a fraction $p(1-e)$ of the teacher's labels. The memoriser mislabels none.
* Every summable prior that charges a risk-0 program ends at risk 0 by Proposition 2.3(i). For $w=2^{-\ell}$ this is `prop:teacher:schedules`(a).
* This is the author's "keep preferring a simpler hypothesis that is worse at classification even in the limit", for the teacher's labels: worse at predicting what the teacher says, by design.

**Why λ must grow with n: a per-sample rate** [remark from proved results].
* `prop:limits:separable`: a component of extra length $k_j$ and population risk reduction $r_j$ is kept iff $r_j/k_j>c$.
* An error rule's reduction is a per-sample quantity, about $2^{-m}$ per bit (the reuse factor, `lem:teacher:reuse`). To discard it, the per-sample penalty must stay above that rate as $n$ grows.
* A fixed prior's per-sample penalty $\lambda\ell/n$ vanishes, so every positive-rate component is eventually kept: every $\lambda_n=o(n)$ learns the errors (`prop:teacher:schedules`(a)).
* Noise is different. A fill-in's rate falls like $1/n$, because its length grows like the sampled randomness $L_n(\nu)\approx nH$ while it gains the same $nH$ bits. So a fixed λ > 1 refuses it (Theorem A(c)).

---

## 4. Weight decay

### 4.1 Plain SGD weight decay is an L2-regularised average loss

**Proposition 4.1** [proved, elementary].
Let $f(\theta;z)$ be a per-sample loss differentiable in θ, $\hat L_n:=\frac1n\sum_{i\le n}f(\cdot;z_i)$, $F_n:=\hat L_n+\frac\omega2\|\theta\|^2$ with ω > 0, and $\hat L_B$ the average over a minibatch $B$.
* (a) The coupled weight-decay step $\theta\leftarrow\theta-\eta(\nabla\hat L_B(\theta)+\omega\theta)=(1-\eta\omega)\theta-\eta\nabla\hat L_B(\theta)$ is an SGD step on $F_n$. This is weight decay as implemented in plain SGD, e.g. PyTorch's `weight_decay` argument.
  * For $B$ drawn uniformly, with or without replacement, $\Ex_B\nabla\hat L_B=\nabla\hat L_n$.
  * With full batches the fixed points are the stationary points of $F_n$, for every η.
* (b) If $f=-\ln p_\theta(y\mid x)$, then
  $$nF_n(\theta)=-\ln\Big(p_\theta(y_{1:n}\mid x_{1:n})\,e^{-\frac{n\omega}2\|\theta\|^2}\Big),$$
  the negative log posterior, up to a constant, under the prior $\mathcal N(0,(n\omega)^{-1}I)$. The prior precision $n\omega$ grows linearly in $n$.
  * MAP under a fixed prior $\mathcal N(0,\tau^{-1}I)$ is the minimiser of $\hat L_n+\frac{\tau}{2n}\|\theta\|^2$, that is, $\omega_n=\tau/n$.
* (c) The minimisers of $F_n$ depend on the sample only through its empirical distribution, as in Proposition 2.1.
  * Under a fixed Gaussian prior, on $h^r$ the effective coefficient is $\tau/(rn)\to0$, so the MAP moves toward the unregularised fit.

*Dictionary.* Total (summed) objective = total loss + (multiplier) × (complexity):

| | complexity | multiplier in the summed objective | per-sample coefficient | fixed prior |
|---|---|---|---|---|
| steeper SFI | $\ell(\pi)$ bits (times ln 2 in nats) | λ = cn | c | λ fixed, prior $2^{-\lambda\ell}$ |
| weight decay | $\frac12\|\theta\|^2$ | nω (prior precision) | ω | ω = τ/n, prior $\mathcal N(0,\tau^{-1}I)$ |

### 4.2 The population limit

**Proposition 4.2** [proved]. Let $L(\theta):=\Ex f(\theta;z)$ be differentiable, ω > 0, and θ* a minimiser of $F:=L+\frac\omega2\|\theta\|^2$.
* (i) $\nabla L(\theta^*)=-\omega\theta^*$. So θ* is a stationary point of L only if θ* = 0; in particular θ* minimises L only if θ* = 0 does.
* (ii) For every θ, $L(\theta^*)-L(\theta)\le\frac\omega2(\|\theta\|^2-\|\theta^*\|^2)$.
  * This is the analogue of $R_\nu(\pi_c)-R_\nu(\pi)\le c(\ell(\pi)-\ell(\pi_c))$ for $\pi_c\in A_c$: excess risk is paid for by complexity saved, at rate ω/2 per unit of squared norm.

*Proof.* (i) is first-order optimality. (ii) is $F(\theta^*)\le F(\theta)$. ∎ d2(A) checks (ii): the maximum of LHS − RHS over 60000 random θ is $-3.5\cdot10^{-4}$.

That the empirical minimisers of $F_n$ converge to θ* for strictly convex $F$ is standard M-estimation [known; not proved here]. It is checked in the toy (d2(B), (C)).

### 4.3 A toy where the regularised limit classifies worse

**Example 4.3** [proved; computed: d2(A)–(C)].
*Setting.*
* $y$ is uniform on $\{\pm1\}$, and ξ = +1 with probability $1-q$, −1 otherwise, independent of $y$.
* $x=(\varepsilon y,\ \xi y)$, and $p_\theta(y\mid x)=\sigma(y\,\theta\cdot x)$ with no bias.
* With $s(u)=\ln(1+e^{-u})$, $a:=\varepsilon\theta_1+\theta_2$ and $b:=\varepsilon\theta_1-\theta_2$:
  $$L(\theta)=(1-q)\,s(a)+q\,s(b),\qquad\text{error rate}(\theta)=(1-q)[a\le0]+q[b\le0].$$
* Assume $q(1+\varepsilon^2)<(1-q)(1-\varepsilon^2)$, equivalently $\varepsilon^2<1-2q$.

*Claims.*
* (a) $\inf L=0$, and $L(\theta_k)\to0$ forces $a_k,b_k\to\infty$. So the infimum is approached only by classifiers of error rate 0, and L has no minimiser.
* (b) For ω > 0 the minimiser θ*(ω) of F is unique and has $\theta_1,\theta_2>0$.
* (c) Its error rate is 0 for $\omega<\omega^*$ and $q$ for $\omega\ge\omega^*$ (the tie $b=0$ at ω* counted as an error), where
  $$\omega^*=\frac{2q\varepsilon^2}{(1-\varepsilon^2)\,a^*},\qquad a^*=\ln\frac{2(1-q)(1-\varepsilon^2)-q(1+\varepsilon^2)}{q(1+\varepsilon^2)}>0,$$
  and $\theta^*(\omega^*)=(a^*/(2\varepsilon),\,a^*/2)$.

*Proof.*
* (a) Both terms are positive. L → 0 needs $s(a)\to0$ and $s(b)\to0$, since $q>0$, so $a,b\to\infty$.
* (b) F is strictly convex and coercive, so the minimiser is unique. Its stationarity equations are
  $$\omega\theta_1=\varepsilon\big[(1-q)\sigma(-a)+q\sigma(-b)\big],\qquad \omega\theta_2=(1-q)\sigma(-a)-q\sigma(-b).$$
  * The first gives $\theta_1>0$.
  * If $\theta_2\le0$, then $a\le b$, so $\sigma(-a)\ge\sigma(-b)$ and $\omega\theta_2\ge(1-2q)\sigma(-b)>0$, a contradiction.
  * Hence $a>0$ and the error rate is $q[b\le0]$.
* (c) If $b=0$, then $\theta_2=\varepsilon\theta_1$, $a=2\theta_2$ and $\sigma(-b)=\frac12$. Dividing the equations gives $\varepsilon^2[(1-q)\sigma(-a)+q/2]=(1-q)\sigma(-a)-q/2$, so
  $$\sigma(-a)=\frac{q(1+\varepsilon^2)}{2(1-q)(1-\varepsilon^2)}.$$
  * This fixes $a=a^*$ (positive under the assumption), $\theta_2=a^*/2$ and $\theta_1=a^*/(2\varepsilon)$.
  * Then $\omega=[(1-q)\sigma(-a^*)-q/2]/\theta_2=\frac{q\varepsilon^2}{1-\varepsilon^2}\cdot\frac2{a^*}=\omega^*$.
  * So $b(\omega)$, which is continuous because the minimiser of a smooth strictly convex family is continuous in ω, vanishes only at ω*.
* *Small ω.* Suppose $b\le0$.
  * The second equation and $\sigma(-b)\ge\frac12$ give $(1-q)\sigma(-a)>q/2$, so $a<A_0:=\ln((2-3q)/q)$.
  * With $a\ge2\varepsilon\theta_1$ this gives $\theta_1<A_0/(2\varepsilon)$.
  * The first equation gives $\theta_1\ge\varepsilon q/(2\omega)$.

  So $\omega>\varepsilon^2q/A_0$. Hence $b>0$ for $\omega\le\varepsilon^2q/A_0$.
* *Large ω.* $\omega\theta^*=-\nabla L(\theta^*)\to-\nabla L(0)=(\varepsilon/2,(1-2q)/2)$, so $\omega b\to(\varepsilon^2-(1-2q))/2<0$.
* By continuity and uniqueness of the root, $b>0$ on $(0,\omega^*)$ and $b<0$ on $(\omega^*,\infty)$. ∎

*Computation* (d2), at $\varepsilon=0.1$, $q=0.2$:
* *Threshold (A).* $\sigma(-a^*)=0.127525$, $a^*=1.923019$, $\omega^*=2.101073\cdot10^{-3}$.
  * The numerical root of $b(\omega)$ agrees to relative $4\cdot10^{-16}$.
  * $\theta^*(\omega^*)=(9.615097,0.961510)$, as predicted.
* *Scan (A).*

  | ω | θ*₁ | θ*₂ | error | pop. log loss |
  |---|---|---|---|---|
  | 1e-4 | 31.75 | 0.72 | 0 | 0.0326 |
  | 1e-3 | 14.43 | 0.86 | 0 | 0.165 |
  | 2e-3 | 9.91 | 0.95 | 0 | 0.242 |
  | 2.2e-3 | 9.34 | 0.97 | 0.2 | 0.253 |
  | 1e-2 | 2.93 | 1.16 | 0.2 | 0.412 |
  | 1e-1 | 0.37 | 0.88 | 0.2 | 0.509 |

* *Empirical minimisers (B)*, exact Newton on $n$ i.i.d. samples, 20 seeds each, error rate 0.2 in "k/20" samples:

  | scheme | n = 10² | 10³ | 10⁴ | 10⁵ | 10⁶ |
  |---|---|---|---|---|---|
  | ω = 0.01 (per-sample) | 20/20 | 20/20 | 20/20 | 20/20 | 20/20 |
  | ω = 0.003 | 20/20 | 20/20 | 20/20 | 20/20 | 20/20 |
  | ω = 1/n (fixed prior N(0, I)) | 20/20 | 0/20 | 0/20 | 0/20 | 0/20 |
  | ω = 10/n (fixed prior N(0, I/10)) | 20/20 | 20/20 | 0/20 | 0/20 | 0/20 |

  The fixed-prior schemes switch once $\tau/n<\omega^*$, as predicted.
* *SGD (C)*: minibatch SGD with coupled decay, $n=10^4$, batch 32.
  * ω = 0.01: θ = (2.945, 1.163), error 0.2; the empirical minimiser is (2.943, 1.146).
  * ω = 1/n: θ = (31.781, 0.715), error 0; the empirical minimiser is (31.781, 0.716).

*Reading.*
* The perfectly separating feature needs a large weight, squared norm ≈ 92 at ω*. The 80%-correct feature needs a weight of about 1.
* Above ω* the regularised limit prefers the cheap, worse feature. No amount of data changes this at fixed ω, exactly as in Example 2.4 for $c>1/k$.
* ω* plays the role of c* (the true solution's "left steepness").

### 4.4 Where the correspondence stops

1. **‖θ‖² is not a description length.**
   * A Gaussian density is not a code. MAP under a density depends on the parametrisation, and a code length for real weights needs a precision. Hinton and van Camp (1993) control the information in the weights by adding Gaussian noise whose level is adapted during learning [known, abstract level].
   * In networks with normalisation layers the loss is invariant to rescaling some weight groups. There L2 regularisation "has no regularizing effect" and mainly sets the effective learning rate (van Laarhoven 2017) [known, abstract level].
   * Discrete lengths give a hull with vertices, so selection is locally constant on open λ-intervals: robust in the kink sense. The minimiser of a strictly convex continuous F moves continuously with ω. In the toy only the *classification* is piecewise constant [remark; computed: d2(A)].
2. **SGD noise and non-convexity.**
   * The correspondence is with the minimiser of $F_n$. SGD iterates are random, and constant-step SGD has a stationary distribution, which can be tuned to approximate a posterior (Mandt, Hoffman and Blei 2017) [known, abstract level].
   * Non-convex networks have many stationary points. The λ-MAP is a global minimiser over all programs.
3. **Decoupled weight decay is a different objective.**
   * L2 and weight decay are equivalent for SGD when rescaled by the learning rate, but not for adaptive methods such as Adam (Loshchilov and Hutter 2019) [known, abstract level].
   * In the full-batch setting, if AdamW converges under a non-increasing learning-rate schedule with divergent partial sums, the limit is a KKT point of the loss under an ℓ∞-norm constraint (Xie and Li 2024) [known, abstract level].
   * Toy (d2(D)): Adam on F converges to argmin F at every coefficient (4 digits). AdamW with $\lambda_W\ge0.01$ ends at the minimiser of L under $\|\theta\|_\infty\le1/\lambda_W$ to 3–4 digits. Its error switches at $\lambda_W=0.1028$ instead of $\omega^*=0.0021$, a factor of about 49 [computed].
     * For $\lambda_W\le0.003$ neither AdamW (2·10⁵ steps) nor L-BFGS-B on the box reached the box boundary, because the loss is numerically flat there. Both have error 0.
4. **Per step, not per sample.**
   * Coupled decay: at a full-batch fixed point the coefficient is ω, independent of η, the batch size and the number of epochs.
   * Before convergence the iterate depends on η·T (d2(E) [computed]):
     * at ω = 0.01, (η, T) = (0.1, 1000), (0.01, 10⁴) and (1, 100) all give θ ≈ (2.00, 1.20);
     * η·T = 10 gives (0.37, 1.12);
     * the converged value is (2.93, 1.16).
   * A coordinate with zero loss gradient shrinks by $(1-\eta\omega)^T\approx e^{-\omega\eta T}$.
   * At ω = 0.001 < ω*, gradient descent stopped at T ≤ 3000 (η = 0.1) has error 0.2; from T = 10⁴ on, error 0. So early stopping acts as extra regularisation and can change the classifier.
   * If the decay is not multiplied by the learning rate α of the loss step, $\theta\leftarrow\theta-\eta_t(\alpha\nabla L+\lambda\theta)$ (SGDW-style), the fixed points minimise $L+\frac{\lambda}{2\alpha}\|\theta\|^2$ [proved: stationarity]. The effective coefficient then depends on α (d2(E): limits equal the predicted minimisers to 4 digits for α = 0.1, 0.5, 2).
   * Loshchilov and Hutter normalise the decay as $\lambda=\lambda_{\rm norm}\sqrt{b/(BT)}$, with $b$ the batch size, $B$ the number of training points and $T$ the number of epochs. They report that the optimal decay shrinks as the number of batch passes grows [known: body (Appendix B.1), via search excerpt; not read in full; not for the paper text].
     * At a fixed number of epochs this scales the per-step coefficient like $n^{-1/2}$, between the per-sample choice (constant) and the fixed-prior choice ($1/n$) [remark].
5. **What weight decay does in deep networks.**
   * Zhang et al. (2017): state-of-the-art convolutional networks fit random labels, and this is "qualitatively unaffected by explicit regularization" [known, abstract level]. So in that regime the norm penalty does not act as a fixed λ > 1 does against fill-ins (Theorem A(c)).
   * Arpit et al. (2017): with appropriately tuned explicit regularisation (e.g. dropout) training on noise can be degraded without hurting generalisation on real data [known, abstract level; the abstract names dropout, not weight decay].
   * D'Angelo et al. (2024): in modern deep learning weight decay acts mainly through the training dynamics, not as an explicit regulariser in the classical sense [known, abstract level].
   * Krogh and Hertz (1992): in linear networks weight decay suppresses irrelevant components of the weight vector and, if its size is chosen right, some effects of static noise on the targets [known, abstract level].
6. **Grokking.** All [known, abstract level] unless marked.
   * Power et al. (2022): on small algorithmic datasets, generalisation improves from chance to perfect "well past the point of overfitting", and smaller datasets need more optimisation. The abstract does not mention weight decay.
     * A search excerpt of the body says weight decay was "particularly effective" among the interventions tested [body, via search excerpt; not read].
   * Liu et al. (2022): an effective theory and phase diagrams (comprehension, grokking, memorisation, confusion).
   * Liu, Michaud and Tegmark (2023, Omnigrok): the "LU mechanism", training and test loss against weight norm, explains data-size dependence, weight-decay dependence and the emergence of representations. Constraining the weight norm eliminates grokking on algorithmic data.
   * Nanda et al. (2023): memorisation, circuit formation and cleanup; grokking as gradual amplification of structured mechanisms followed by removal of memorising components.
   * Varma et al. (2023): generalising circuits are more efficient (larger logits per parameter norm); memorising circuits lose efficiency as the training set grows, giving a critical dataset size [known, abstract level; optional, not in the draft].
   * *Relation to this paper* [remark; heuristic]:
     * on noise-free algorithmic data a memorising and a generalising solution both fit, and any fixed length prior already prefers the shorter one;
     * what λ = cn adds is discarding components that *do* improve the fit, when their rate is below c;
     * the "keeps going after the data are fitted" dynamics of weight decay, which removes memorising components, is a dynamical analogue that the two-part objective does not model.

### 4.5 What is analogous and what is not (summary table)

| | steeper SFI with λ = cn | weight decay ω with averaged loss | status |
|---|---|---|---|
| per-sample objective | $c\,\ell+\hat R_n$ | $\hat L_n+\frac\omega2\|\theta\|^2$ | proved |
| implied prior on the summed objective | $2^{-cn\ell}$, exponent ∝ n | $\mathcal N(0,(n\omega)^{-1}I)$, precision ∝ n | proved |
| fixed prior corresponds to | fixed λ | ω = τ/n | proved |
| depends on data only via empirical distribution | yes (Prop 2.1) | yes (Prop 4.1(c)) | proved |
| limit objective | $c\,\ell+R_\nu$ | $L+\frac\omega2\|\theta\|^2$ | proved |
| limit can predict / classify worse than the truth | yes, for c > c* (Prop 2.3, Ex 2.4) | yes, unless 0 minimises L; toy: for ω ≥ ω* (Ex 4.3) | proved |
| excess risk paid by complexity saved | $R(\pi_c)-R(\pi)\le c(\ell(\pi)-\ell(\pi_c))$ | $L(\theta^*)-L(\theta)\le\frac\omega2(\|\theta\|^2-\|\theta^*\|^2)$ | proved |
| prior factor applied once per sample / step | yes (Remark 1.2) | yes, per step (Prop 4.1(a)) | proved |
| complexity is a code length | yes (prefix code) | no (density; precision; scale invariance) | known |
| selection robust on open intervals (kinks) | yes (hull vertices) | no (continuous path) | remark |
| what is computed | the global minimiser (an idealisation) | an SGD iterate | known |
| adaptive optimisers | n/a | AdamW ≠ L2 (different limit) | known; computed |
| refuses memorised noise at fixed coefficient | yes, fixed λ > 1 (Theorem A(c)) | not reliably in deep nets (random labels fitted) | known |

---

## 5. Literature: verified sources

Verification route. WebSearch on 2026-10-14, one or more queries per source.
* WebFetch failed with a DNS error, so no page could be opened.
* Direct HTTPS to arXiv, Crossref, Semantic Scholar, DBLP and OpenReview was refused by the proxy (403).
* So every entry rests on the search results, which return the bibliographic record and the abstract, often paraphrased. Fields not confirmed by any search are omitted from `refs.bib` rather than guessed: pages of the two NeurIPS papers and the OpenReview identifiers.

| key | bibliographic data (confirmed) | what the source says (abstract level unless marked) | used for |
|---|---|---|---|
| `krogh1992simple` | Krogh, Hertz. "A Simple Weight Decay Can Improve Generalization". NIPS 4 (1991 meeting), eds. Moody, Hanson, Lippmann, Morgan Kaufmann 1992, pp. 950–957 (pages from the NeurIPS metadata; editors and publisher from the volume record) | weight decay in a linear network suppresses irrelevant weight components (smallest vector solving the problem) and, if the size is chosen right, some effects of static target noise; extended to hidden layers; NetTalk simulations | §4.4 item 5 |
| `loshchilov2019decoupled` | Loshchilov, Hutter. "Decoupled Weight Decay Regularization". ICLR 2019; arXiv:1711.05101 (v1 14 Nov 2017, earlier title "Fixing Weight Decay Regularization in Adam") | L2 regularisation and weight decay are equivalent for standard SGD when rescaled by the learning rate, not for adaptive methods such as Adam; proposes decoupling the decay from the gradient step; improves Adam's generalisation. Body, via search excerpt: normalised decay $\lambda=\lambda_{\rm norm}\sqrt{b/(BT)}$ (App. B.1) | remark; §4.4 items 3, 4 |
| `power2022grokking` | Power, Burda, Edwards, Babuschkin, Misra. "Grokking: Generalization Beyond Overfitting on Small Algorithmic Datasets". arXiv:2201.02177 (6 Jan 2022) | generalisation from chance to perfect long after overfitting; smaller datasets need more optimisation. Weight decay is not in the abstract; body, via search excerpt: "particularly effective" among interventions | remark (grokking only) |
| `nanda2023progress` | Nanda, Chan, Lieberum, Smith, Steinhardt. "Progress Measures for Grokking via Mechanistic Interpretability". ICLR 2023; arXiv:2301.05217 | reverse-engineers modular addition in small transformers (Fourier, rotation); training splits into memorisation, circuit formation and cleanup; grokking as gradual amplification of structured mechanisms followed by removal of memorising components | remark |
| `liu2022towards` | Liu, Kitouni, Nolte, Michaud, Tegmark, Williams. "Towards Understanding Grokking: An Effective Theory of Representation Learning". NeurIPS 35 (2022); arXiv:2205.10343 (pages not confirmed) | effective theory plus phase diagrams; four phases (comprehension, grokking, memorisation, confusion); representation learning in a "Goldilocks zone" | remark (grokking only) |
| `liu2023omnigrok` | Liu, Michaud, Tegmark. "Omnigrok: Grokking Beyond Algorithmic Data". ICLR 2023; arXiv:2210.01117 | "LU mechanism" (training/test loss against weight norm) explains data-size dependence, weight-decay dependence and emergence of representations; induces grokking on image, language and molecule tasks and eliminates it on algorithmic data | remark |
| `varma2023explaining` | Varma, Shah, Kenton, Kramár, Kumar. "Explaining grokking through circuit efficiency". arXiv:2309.02390 (5 Sep 2023) | generalising circuit slower to learn but more efficient (larger logits per parameter norm); memorising circuits lose efficiency with dataset size; critical dataset size; ungrokking and semi-grokking | notes only |
| `mackay1992practical` | MacKay. "A Practical Bayesian Framework for Backpropagation Networks". Neural Computation 4(3):448–472, 1992; doi 10.1162/neco.1992.4.3.448 | Bayesian framework for feedforward networks; among its uses, objective choice of the magnitude and type of weight decay terms; evidence embodies Occam's razor | remark (Gaussian-prior reading) |
| `hinton1993keeping` | Hinton, van Camp. "Keeping the Neural Networks Simple by Minimizing the Description Length of the Weights". COLT '93, pp. 5–13, ACM; doi 10.1145/168304.168306 | networks generalise when the weights carry much less information than the outputs; information in a weight controlled by Gaussian noise whose level is adapted during learning | remark; §4.4 item 1 |
| `vanlaarhoven2017l2` | van Laarhoven. "L2 Regularization versus Batch and Weight Normalization". arXiv:1706.05350 (16 Jun 2017) | with normalisation L2 has no regularising effect; it influences the weight scale and hence the effective learning rate; Adam only partly removes this | remark; §4.4 item 1 |
| `xie2024implicit` | Xie, Li. "Implicit Bias of AdamW: ℓ∞-Norm Constrained Optimization". ICML 2024, PMLR 235:54488–54510; arXiv:2404.04454 | Adam with L2 minimises an L2-regularised loss, while it is unclear whether AdamW minimises any objective; full batch, if AdamW converges under a non-increasing schedule with divergent partial sums, the limit is a KKT point of the loss under an ℓ∞-norm constraint | remark; §4.4 item 3 |
| `dangelo2024why` | D'Angelo, Andriushchenko, Varre, Flammarion. "Why Do We Need Weight Decay in Modern Deep Learning?". NeurIPS 37 (2024); doi 10.52202/079017-0730; arXiv:2310.04415 (pages not confirmed; arXiv v1 lists Andriushchenko first) | weight decay's role differs from classical explicit regularisation: vision with multipass SGD, it changes optimisation dynamics (loss stabilisation); LLMs near one epoch, it balances bias and variance; not useful as an explicit regulariser there | §4.4 item 5 (dropped from the remark for length) |
| `mandt2017stochastic` | Mandt, Hoffman, Blei. "Stochastic Gradient Descent as Approximate Bayesian Inference". JMLR 18(134):1–35, 2017 | constant-step SGD simulates a Markov chain with a stationary distribution; can be tuned to approximate a posterior | remark; §4.4 item 2 |
| `zhang2017understanding` | Zhang, Bengio, Hardt, Recht, Vinyals. "Understanding Deep Learning Requires Rethinking Generalization". ICLR 2017; arXiv:1611.03530 | CNNs trained with stochastic gradient methods easily fit random labels; "qualitatively unaffected by explicit regularization"; also with random-noise inputs | §4.4 item 5 |
| `arpit2017closer` | Arpit, Jastrzębski, Ballas, Krueger, Bengio, Kanwal, Maharaj, Fischer, Courville, Bengio, Lacoste-Julien. "A Closer Look at Memorization in Deep Networks". ICML 2017, PMLR 70:233–242 | DNNs can memorise noise but learn simple patterns first; tuned explicit regularisation (e.g. dropout) can degrade training on noise without hurting real-data generalisation | §4.4 item 5 |

**Generalised and tempered posteriors already in Paper 2.** The bibliographic data were re-checked and agree with `paper-steeper/bib/all.bib`.

| key | confirmed | abstract-level content relevant here |
|---|---|---|
| `zhang2006epsilon` | Ann. Statist. 34(5):2180–2210, 2006; doi 10.1214/009053606000000704 | information-theoretic inequality for deterministic and randomised density estimators; improves results on MDL and posterior convergence |
| `bissiri2016general` | JRSS B 78(5):1103–1130, 2016; doi 10.1111/rssb.12158 | updates a prior to a posterior through a loss function instead of a likelihood; Bayes' rule is the self-information-loss case. This is the framework in which Remark 1.2's per-sample update with loss $-\log\nu_\pi+c\ell$ is a loss-based update |
| `bhattacharya2019fractional` | Ann. Statist. 47(1):39–66, 2019; doi 10.1214/18-AOS1712 | likelihood raised to a fractional power; contraction under misspecification with only a prior-mass condition; oracle inequality via PAC-Bayes |
| `grunwald2012safe` | ALT 2012, LNCS 7568:169–183; doi 10.1007/978-3-642-34106-9_16 | learns the learning rate (likelihood exponent) from data, for wrong models |
| `grunwald2017inconsistency` | Bayesian Analysis 12(4):1069–1103, 2017; doi 10.1214/17-BA1085 | Bayes inconsistent under misspecification in linear regression; hypercompression; SafeBayes picks small learning rates |
| `wenzel2020good` | ICML 2020, PMLR 119:10248–10259 | the Bayes posterior predictive is worse than SGD point estimates; "cold posteriors" that overcount evidence help |
| `grunwald2007suboptimal` | Machine Learning 66:119–149, 2007; doi 10.1007/s10994-007-0716-7 | Bayes and MDL classifiers can be inconsistent under misspecification, with error bounded away from the optimum however much data |
| `zhu2025quantifying` | COLT 2025, PMLR 291:6124–6155; arXiv:2503.02110 | full regularisation curve of a modified two-part MDL rule; worst-case limiting error as a function of λ and the noise level |
| `zhu2026overfitting` | arXiv:2603.22644 (23 Mar 2026), Zhu, Ohannessian, Srebro | PAC-Bayes-type rule balancing training error and KL to a prior; λ = 1 recovers an empirical Bayes posterior that overfits; λ ≫ 1, described as a sample-size-dependent prior, gives vanishing excess loss even in the agnostic case (as returned by the search; abstract paraphrased) |
| `barron1991minimum` | IEEE Trans. Inf. Theory 37(4):1034–1054, 1991; doi 10.1109/18.86996 | abstract not returned by the search; the "index of resolvability" is described only by secondary sources. Content not checked here |

**Relation of the tempered-posterior literature to λ = cn** [remark].
* In the generalised-posterior references the learning rate η of $\Pi^\eta\propto\text{prior}\times\text{likelihood}^\eta$ is fixed or learned from data.
* λ = cn corresponds, through $\Pi_\lambda\propto(\Pi^{1/\lambda})^\lambda$, to η = 1/(cn), a learning rate decaying like 1/n. Then $\Pi^\eta$ converges to a fixed Gibbs measure instead of concentrating (Remark 1.3).
* Cold posteriors keep the prior-to-likelihood ratio of λ = 1 (`rem:related:cold`), so they are not this.

---

## 6. Draft text for the paper

**Placement.**
* (a) A main-text remark `rem:teacher:weightdecay` in `teacher.tex`, directly after `rem:limits:schedule`, which already discusses fixed λ against λ ∝ n and the batch excess.
* (b) An appendix subsection `app:teacher:weightdecay` at the end of `app-teacher.tex`, with `prop:teacher:nofixedprior` and `ex:teacher:weightdecay`.
* (c) One sentence in `related.tex`, paragraph "Generalised posteriors and two-part codes", after the cold-posterior sentence.
* (d) `refs.bib` entries merged into Paper 2's bibliography.

All labels are new. No existing label or statement changes (REFRAME §8).

**Build check** (a scratch copy of `paper-steeper/` outside the repository, with (a)–(d) inserted and `refs.bib` as `bib/decay.bib`):
* 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, no overfull box over 10pt.
* The PDF grows from 74 to 77 pages. The remark is about 30 lines of text (≈ 0.55 page; Remark 8.5 on p. 26). The appendix subsection is about 1.4 pages, and the bibliography grows by 10 entries.
* Main text plus references grows by 2 pages (Appendix A moves from p. 37 to p. 39).

**Options to save space.**
* Drop the last sentence of the remark (grokking), about 3 lines.
* Drop the AdamW sentence of the example, 2 lines.
* Move Proposition (ii)'s $\Hcl{\times}$ existence proof to a footnote-free one-liner.

### 6.1 Main-text remark (for `teacher.tex`, after `rem:limits:schedule`)

```latex
\begin{remark}[$\lambda=cn$ and weight decay]\status{proved; computed; known}\src{imitation/decay notes \S\S1--4, Props 2.1--2.3, Example 4.3; checks d1, d2}\label{rem:teacher:weightdecay}
With $\lambda=cn$ the length is charged once per sample: $2^{-cn\ell(\pi)}\nu_\pi(h_n)=\prod_{i\le n}2^{-c\ell(\pi)}\nu_\pi(y_i\mid x_i)$. A fixed $\lambda$ is the fixed prior $2^{-\lambda\ell}$, but no fixed prior gives the $cn$-MAPs at every $n$. The $cn$-MAPs depend on the sample only through its empirical distribution, while under a fixed prior with full support only programs of maximal likelihood stay MAPs when a sample is repeated often enough; and per query, for $c>c^*$, they end at shorter programs that predict worse, whereas the MAPs of every summable prior that charges $\mathcal E$ end in $\mathcal E$ (\cref{prop:teacher:nofixedprior}). The window of \cref{thm:teacher:main} is an instance: its hypotheses do not predict the teacher's errors, while every summable prior that charges a program reproducing the teacher's labels eventually selects such a program.

Weight decay has the same form. With the loss averaged over $n$ samples, gradient descent with weight-decay coefficient $\omega$ descends $\hat L_n(\theta)+\frac\omega2\|\theta\|^2$, and $n$ times this is, up to a constant, the negative log posterior under the Gaussian prior $\mathcal N(0,(n\omega)^{-1}I)$ \citep{mackay1992practical}: its precision grows linearly in $n$, like the exponent of $2^{-cn\ell}$, while a fixed prior needs $\omega\propto1/n$. In the limit the minimiser of $L(\theta)+\frac\omega2\|\theta\|^2$ minimises the population loss $L$ only if $\theta=0$ does, and it can classify worse (\cref{ex:teacher:weightdecay}). In both cases the penalty per sample does not vanish with the data. Discarding a component whose risk reduction per unit of complexity is small requires this (\cref{prop:limits:separable}), and every $\lambda_n=o(n)$ eventually learns the errors (\cref{prop:teacher:schedules}(a)).

The analogy is one of objectives. $\|\theta\|^2$ is not a description length: coding weights needs a precision \citep{hinton1993keeping}, and with normalisation layers the norm mainly sets the effective learning rate \citep{vanlaarhoven2017l2}. Stochastic gradient iterates are not minimisers \citep{mandt2017stochastic}; decoupled weight decay in adaptive optimisers is not an $L_2$ penalty \citep{loshchilov2019decoupled,xie2024implicit}; and the decay acts per step, so before convergence its effect depends on the learning rate and the number of steps. Grokking \citep{power2022grokking,liu2022towards} has been related to the weight norm and to weight decay \citep{liu2023omnigrok}, and analysed as memorisation followed by a cleanup that removes memorising components \citep{nanda2023progress}.
\end{remark}
```

### 6.2 Appendix subsection (for the end of `app-teacher.tex`)

```latex
\subsection{\texorpdfstring{$\lambda=cn$}{lambda=cn} and weight decay}\label{app:teacher:weightdecay}

A \emph{fixed prior} is a map $w$ from programs to $[0,\infty)$ chosen before the data; its MAPs on a per-query sample $h$ maximise $w(\pi)\nu_\pi(h)$. For $\lambda\ge1$ the $\lambda$-MAPs are the MAPs of the fixed prior $2^{-\lambda\ell}$. Write $h^r$ for the sample $h$ repeated $r$ times.

\begin{proposition}[No fixed prior gives the $cn$-MAPs]\status{proved; computed}\src{imitation/decay Props 2.1--2.3; check d1}\label{prop:teacher:nofixedprior}
Let $c>0$, and let the class be countable, with Kraft weights and kernels, as in \cref{def:split:setting}.
\begin{enumerate}[label=(\roman*),itemsep=0pt,topsep=2pt]
\item If samples $h$ and $h'$ of sizes $n$ and $n'$ have the same empirical distribution, the $cn$-MAPs of $h$ are the $cn'$-MAPs of $h'$.
\item Let $h$ have size $n_0$, let $\pi^*$ attain $P^*:=\max_\pi\nu_\pi(h)>0$, and let no $cn_0$-MAP of $h$ attain $P^*$. If $w(\pi^*)>0$, then for every $r>\max_{\hat\pi}\log\frac{w(\hat\pi)}{w(\pi^*)}\big/\log\frac{P^*}{\nu_{\hat\pi}(h)}$, the maximum over the $cn_0$-MAPs $\hat\pi$ of $h$, no $crn_0$-MAP of $h^r$ is a MAP of $w$ on $h^r$. In $\Hcl{\times}$ such samples exist for every $c>0$.
\item Per query, let $\mathcal E\ne\emptyset$ and let $w$ be summable with $w(\pi)>0$ for some $\pi\in\mathcal E$. Almost surely, for all large $n$, the MAPs of $w$ are the programs of $\mathcal E$ of largest weight. If $c>c^*$ (\cref{prop:recovery:beyond}), almost surely for all large $n$ no $cn$-MAP lies in $\mathcal E$, and every minimiser $\pi$ of $c\,\ell+R_\nu$ has $\ell(\pi)<\ell_0$ and $R_\nu(\pi)>R_\nu(\pi_0)$ for $\pi_0\in\mathcal E_0$. If $c<c^*$, the $cn$-MAPs and the MAPs of $2^{-\ell}$ are both eventually $\mathcal E_0$.
\end{enumerate}
\end{proposition}

\begin{proof}
(i) $J_{cn}(\pi;h)/n=c\,\ell(\pi)+\Ex_{\hat P_h}[-\log\nu_\pi(y\mid x)]$ depends on $h$ only through its empirical distribution $\hat P_h$. (ii) By (i) the $crn_0$-MAPs of $h^r$ are the $cn_0$-MAPs $\hat\pi$ of $h$; they are finitely many (\cref{lem:setup:basic}), with $0<\nu_{\hat\pi}(h)<P^*$, and $w(\hat\pi)\nu_{\hat\pi}(h)^r<w(\pi^*)(P^*)^r$ for the stated $r$. In $\Hcl{\times}$ take $n_0$ distinct inputs whose labels $y$ have $K(y\mid\dom D)\ge n_0\log|Y|$, with $n_0\log|Y|-\kappa-\ell_{\rm u}>\log|Y|/c$, where $\ell_{\rm u}$ is the length of a program for the uniform kernel: a lookup program attains $P^*=1$, and by \cref{lem:setup:coding} every program of likelihood $1$ has $J_{cn_0}\ge cn_0(n_0\log|Y|-\kappa)>cn_0\ell_{\rm u}+n_0\log|Y|$, the uniform kernel's value. (iii) Let $W:=\max_{\mathcal E}w$. Almost surely $\nu_\pi(h_n)=\nu(h_n)>0$ for all $\pi\in\mathcal E$ and all $n$, so a MAP $\hat\pi$ of $w$ has $w(\hat\pi)\Lambda_n(\hat\pi)\ge W$. For a cofinite set $T$ of programs, $\sum_{\pi\in T}w(\pi)\Lambda_n(\pi)$ is a nonnegative supermartingale started at $w(T)$ (\cref{lem:recovery:ratios}(a)), so by Ville's inequality some MAP lies in $T$ at some $n$ with probability at most $w(T)/W$, which tends to $0$ along cofinite sets decreasing to $\emptyset$. Of the finitely many other programs, those outside $\mathcal E$ have $\Lambda_n\to0$ almost surely (\cref{lem:recovery:ratios}(c)), and those of $\mathcal E$ with $w<W$ are never MAPs. For $c>c^*$ some $\pi'$ with $\ell(\pi')<\ell_0$ has $J_c(\pi')<J_c(\pi_0)\le J_c(\pi)$ for all $\pi\in\mathcal E$, and $J_c(\pi)>J_c(\pi_0)$ for $\pi\notin\mathcal E$ with $\ell(\pi)\ge\ell_0$; so the minimisers of $J_c$ are shorter than $\ell_0$ and lie outside $\mathcal E$, where $\KL_\mu>0$, and \cref{prop:recovery:beyond}(c) puts every $cn$-MAP among them for all large $n$. For $c<c^*$ use \cref{prop:recovery:beyond}(c) and the first part with $w=2^{-\ell}$.
\end{proof}

\emph{Weight decay.} For a per-sample loss $f(\theta;z)$ let $\hat L_n:=\frac1n\sum_{i\le n}f(\cdot\,;z_i)$ and $L:=\Ex f(\cdot\,;z)$. A step $\theta\leftarrow\theta-\eta(\nabla\hat L_B(\theta)+\omega\theta)$ on a uniformly drawn minibatch $B$ is a stochastic gradient step on $F_n:=\hat L_n+\frac\omega2\|\theta\|^2$; with full batches its fixed points are the stationary points of $F_n$, for every $\eta$. If $f=-\ln p_\theta(y\mid x)$, then $nF_n(\theta)=-\ln\big(p_\theta(y_{1:n}\mid x_{1:n})\,e^{-n\omega\|\theta\|^2/2}\big)$. As in (i), the minimisers of $F_n$ depend on the sample only through its empirical distribution. If $\theta^*$ minimises $F:=L+\frac\omega2\|\theta\|^2$ and $L$ is differentiable, then $\nabla L(\theta^*)=-\omega\theta^*$, so $\theta^*$ is a stationary point of $L$ only if $\theta^*=0$; and $L(\theta^*)-L(\theta)\le\frac\omega2(\|\theta\|^2-\|\theta^*\|^2)$ for every $\theta$, the analogue of $R_\nu(\pi_c)-R_\nu(\pi)\le c(\ell(\pi)-\ell(\pi_c))$ for a minimiser $\pi_c$ of $J_c$. If the decay is not multiplied by the learning rate $\alpha$ of the loss, $\theta\leftarrow\theta-\eta_t(\alpha\nabla L(\theta)+\lambda\theta)$, the fixed points minimise $L+\frac{\lambda}{2\alpha}\|\theta\|^2$: the effective coefficient then depends on $\alpha$.

\begin{example}[A worse classifier in the limit]\status{proved; computed}\src{imitation/decay Example 4.3; check d2(A)--(D)}\label{ex:teacher:weightdecay}
Let $y$ be uniform on $\{\pm1\}$, $\xi=1$ with probability $1-q$ and $\xi=-1$ otherwise, independently, $x=(\varepsilon y,\xi y)$ and $p_\theta(y\mid x)=\sigma(y\,\theta\cdot x)$, with $q(1+\varepsilon^2)<(1-q)(1-\varepsilon^2)$. The first feature separates the classes, at scale $\varepsilon$; $\inf L=0$ is approached only by classifiers of error rate $0$. The minimiser of $F$ has error rate $0$ for $\omega<\omega^*$ and $q$ for $\omega\ge\omega^*$ (a tie counted as an error), where
\[
\omega^*=\frac{2q\varepsilon^2}{(1-\varepsilon^2)\,a^*},\qquad a^*=\ln\frac{2(1-q)(1-\varepsilon^2)-q(1+\varepsilon^2)}{q(1+\varepsilon^2)}.
\]
At $\varepsilon=0.1$ and $q=0.2$, $\omega^*=2.101\cdot10^{-3}$. A direct computation (code in the accompanying repository) finds the empirical minimisers with $\omega=0.01$ at error rate $0.2$ in all of 20 samples for each $n\in\{10^2,10^3,\dots,10^6\}$, and with $\omega=1/n$, the fixed prior $\mathcal N(0,I)$, at error rate $0$ in all of 20 for each $n\ge10^3$; minibatch gradient descent reaches the same regimes. Full-batch AdamW with decoupled coefficient $\lambda$ ends near the minimiser of $L$ under $\|\theta\|_\infty\le1/\lambda$, whose error rate switches at $\lambda=0.103$ instead.
\end{example}

\emph{Proof idea.} With $a:=\varepsilon\theta_1+\theta_2$, $b:=\varepsilon\theta_1-\theta_2$, the error rate is $(1-q)[a\le0]+q[b\le0]$. The stationarity equations of the strictly convex $F$ give $\theta_1,\theta_2>0$, so the error rate is $q[b\le0]$. At $b=0$ they force $\sigma(-a)=q(1+\varepsilon^2)/(2(1-q)(1-\varepsilon^2))$, so $b$, which is continuous in $\omega$, vanishes only at $\omega^*$; $b>0$ for $\omega\le\varepsilon^2q/\ln((2-3q)/q)$, and $\omega\,b\to(\varepsilon^2-(1-2q))/2<0$ as $\omega\to\infty$.
```

Notes on the draft.
* The AdamW sentence says "ends near", which is what d2(D) shows for $\lambda\ge0.01$. The switch at 0.103 is that of the box problem.
* The example's "minibatch gradient descent reaches the same regimes" rests on d2(C), two runs at $n=10^4$ (ω = 0.01 and ω = 1/n).
* If the paper prefers, the remark can cite `\cref{app:teacher:weightdecay}` instead of the proposition and example labels.

### 6.3 Related-work sentence (for `related.tex`, after the sentence ending `\label{rem:related:cold}`)

```latex
With $\lambda=cn$ the prior changes with the sample size, as the Gaussian prior implicit in weight decay does (\cref{rem:teacher:weightdecay}); \citet{zhu2026overfitting} likewise read a large complexity weight in a PAC-Bayes rule as a sample-size-dependent prior.
```

The second clause rests on the search's paraphrase of the abstract of `zhu2026overfitting` (§5). If the decay referee cannot confirm the phrase "sample-size-dependent prior" in the abstract, drop that clause.

### 6.4 What the remark claims and where each claim is proved

| claim in the remark | source |
|---|---|
| prior factor once per sample (product formula) | Remark 1.2 [proved] |
| fixed λ = fixed prior | Remark 1.4 [proved] |
| no fixed prior gives the cn-MAPs; empirical distribution; repeated sample | Props 2.1, 2.2 [proved; computed d1(A)] |
| per query, c > c*: shorter and worse, against E for summable priors | Prop 2.3 [proved; computed d1(C)] |
| teacher window: no prediction of errors; priors charging a risk-0 program select one | `thm:teacher:main`(ii)(e), `prop:teacher:schedules`(c); Prop 2.3(i) with ν = δ_{y*} [proved] |
| weight decay = average loss + (ω/2)‖θ‖²; Gaussian prior with precision nω | Prop 4.1 [proved]; MacKay 1992 [known, abstract] |
| the limit minimises L only if 0 does; can classify worse | Prop 4.2 [proved]; Example 4.3 [proved; computed d2] |
| per-sample penalty needed against small-rate components; o(n) learns the errors | `prop:limits:separable`, `prop:teacher:schedules`(a) [proved in Paper 2] |
| limits: norm not a code length; normalisation; SGD; AdamW; per step | §4.4 [known, abstract level; computed d2(D),(E)] |
| grokking sentence | Power, Liu 2022, Liu 2023, Nanda [known, abstract level] |

---

## 7. Claims and statuses

| id | claim | status |
|---|---|---|
| D1 | $J_{cn}/n=c\ell+\hat R_n\to c\ell+R_\nu$; cn-MAPs eventually in $A_c$ | proved (Paper 2) |
| D2 | $\Pi_{cn}$ multiplies by $2^{-c\ell}$ at every sample (recursion) | proved; computed d1(E) |
| D3 | tempered posterior with η = 1/(cn) → fixed Gibbs measure $2^{-\ell-R/c}/Z$ | proved; computed d1(D) |
| D4 | fixed λ is MAP/Bayes for the fixed prior $2^{-\lambda\ell}$ | proved |
| D5 | cn-MAPs depend only on the empirical distribution (duplication invariance) | proved; computed d1(A) |
| D6 | no fixed prior with full support gives the cn-MAPs on all samples, whenever some sample's cn-MAPs miss maximum likelihood; such samples exist in $\Hcl{\times}$ for every c > 0 | proved; computed d1(A) |
| D7 | per query: summable prior charging $\mathcal E$ ends in $\arg\max_{\mathcal E}w$; for c > c* the cn-MAPs eventually avoid $\mathcal E$ and are shorter and worse; for c < c* both end in $\mathcal E_0$ | proved; computed d1(C) |
| D8 | two-program example: coin kept forever iff ck > 1; fixed λ switches at n > λk | proved; computed d1(B) |
| D9 | schedules with $\lambda_n/n\to c>0$ are not fixed-prior rules either (vertex-interval condition) | proved |
| D10 | "the cn-MAP differs eventually from every fixed-prior MAP on typical data for every c" | **refuted** (c < c*, d1(C)) |
| D11 | coupled SGD weight decay = SGD on $\hat L_n+\frac\omega2\|\theta\|^2$; MAP under $\mathcal N(0,(n\omega)^{-1}I)$ | proved |
| D12 | population minimiser of $L+\frac\omega2\|\theta\|^2$ minimises L only if 0 does; excess bound | proved; computed d2(A) |
| D13 | toy: error 0 below ω*, q at and above ω*, closed form for ω* | proved; computed d2(A) |
| D14 | toy, finite n: fixed ω = 0.01 keeps error 0.2 up to n = 10⁶; ω = 1/n reaches 0 from n = 10³ | computed d2(B) |
| D15 | toy: SGD with coupled decay lands at the empirical minimiser's regime | computed d2(C) |
| D16 | toy: AdamW limit ≈ ℓ∞-box minimiser, error threshold 0.103 vs 0.0021 | computed d2(D) |
| D17 | SGDW-style fixed points minimise $L+\frac{\lambda}{2\alpha}\|\theta\|^2$; before convergence the iterate depends on ηT; early stopping can change the classifier | proved (fixed points); computed d2(E) |
| D18 | weight decay is not a description length; deep nets fit random labels under explicit regularisation; WD acts through dynamics | known, abstract level |
| D19 | grokking literature as summarised in §4.4 item 6 | known, abstract level (Power's weight-decay statement: body, via search excerpt) |
| D20 | literature entries of `refs.bib` | verified by WebSearch (fields not confirmed are omitted) |

---

## 8. Open points

1. Non-constant schedules $\lambda_n=o(n)$: for which classes is the MAP rule a fixed-prior MAP rule at every finite $n$ (Remark 2.5(b))? Not pursued.
2. A weight-decay analogue of the kink geometry: a "structure function" $\rho\mapsto\min\{L(\theta):\|\theta\|^2\le\rho\}$ is convex for convex $L$, so it has no vertices. Is there a useful analogue of robust (open-interval) selection for networks? [open; remark]
3. Whether the "cleanup" phase of grokking under fixed weight decay is the dynamical counterpart of λ = cn discarding components of rate below c, as against a fixed prior discarding only components that do not improve the fit [heuristic; not checked].

---

## References

BibTeX entries for every source cited in §5 are in `refs.bib`, for those not already in Paper 2's bibliography. Paper 2 labels are cited as written.

---

## Verification log

* **2026-10-14, reading.** The brief; Paper 2 sections and the split synthesis as listed under "Sources read". Labels used in the drafts were confirmed by grep: `lem:recovery:ratios`, `def:split:setting`, `prop:recovery:beyond`, `lem:setup:coding`, `lem:setup:basic`, `prop:limits:separable`, `prop:teacher:schedules`, `rem:setup:persample`, `thm:teacher:main`, `rem:limits:schedule`, `app:teacher`. The new labels `rem:teacher:weightdecay`, `app:teacher:weightdecay`, `prop:teacher:nofixedprior` and `ex:teacher:weightdecay` do not occur in Paper 2 (the scratch build reports no multiply defined labels).
* **Literature.**
  * About 30 WebSearch queries were run.
  * WebFetch of papers.nips.cc and arxiv.org failed with `getaddrinfo ENOTFOUND`.
  * `curl` to export.arxiv.org, api.crossref.org, api.semanticscholar.org, dblp.org and openreview.net was refused by the proxy (CONNECT 403).
  * So all literature statements are at abstract level as returned by the search. The search tool often paraphrased abstracts; quotations in §5 are limited to phrases that the tool returned as quoted text.
  * Fields confirmed per entry are listed in §5. Omitted for lack of confirmation: the pages of `liu2022towards` and `dangelo2024why`, and the OpenReview identifiers.
  * New keys were checked against `paper-steeper/bib/all.bib` and `paper/bib/all.bib`: no clashes.
* **d1_no_fixed_prior.py** (2.4 s).
  * *First run.* Part (A) reported duplication invariance in 1998 of 2000 trials and 2 "mismatches". Diagnosis:
    * the 2000 included 2 skipped trials with no finite fit, so the denominator was wrong;
    * the mismatches came from a fixed grid of $r$ that stopped at 4000 while the needed $r$ was larger.
  * *Fix.* Count only valid trials. Compute the fit of $h^r$ from the replicated sample itself. Check the claim at the exact threshold $\lfloor r_{\rm th}\rfloor+1$.
  * *Rerun.* 1998 of 1998 invariant; 671 of 671 disjoint at the threshold.
  * Containment of the w-MAP set in the ML set (594 of 671 at that $r$) was separated from the claim, since other programs can need larger $r$.
  * Parts (B)–(E) as quoted in §§1–2.
* **d2_weight_decay.py** (about 1.5 min).
  * The first run gave all parts as quoted.
  * I then added the early-stopping rows of (E) at ω = 0.001 and reran the whole script; the output saved is that of the full rerun.
  * Closed-form ω* and the numerical root agree to $4\cdot10^{-16}$ relative.
  * In (D), for $\lambda_W\le0.003$, neither AdamW nor L-BFGS-B reached the box boundary (the loss is flat there); recorded as such in §4.4 item 3.
* **Draft LaTeX** (§6). Compiled in a scratch copy of `paper-steeper/` outside the repository (pdflatex, bibtex, pdflatex ×2), with the remark, appendix subsection, related-work sentence and `refs.bib` inserted.
  * Two compile rounds were made. The first remark draft was about 31 lines (0.6 page) and was tightened to about 30 lines. The first draft's sentence "The window … is of the first kind" was rewritten because it was ambiguous. The draft no longer asserts $c>c^*$ inside the teacher window, which is not proved, and cites instead what `prop:teacher:schedules`(c) and Prop 2.3(i) give.
  * Final build: 0 errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes over 10pt. 77 pages against 74 for the unmodified paper built the same way.
* **Not done.**
  * No independent referee has checked this record yet; the workflow's referee step does that.
  * The full texts of the cited papers were not read.
