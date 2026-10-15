# Track "imitation", sub-track "robust": recovering the sampler robustly (target I1)

*Brief: `../00-brief.md`, target I1, parts (a)–(d) and the interpretation. Written 2026-10-14. This is the first record of the sub-track; no referee has read it.*

* **Sources read.**
  * The brief, in full, including the author's message.
  * Paper 2 (`paper-steeper/sections/`), the restructured sections: `abstract`, `intro`, `setup` and `app-setup`, `absorb` and `app-absorb` (from the price of private randomness to the end), `kinks` and `app-kinks`, `recovery` and `app-recovery`, `parity` (the instance and the four lemmas), `teacher` and `app-teacher` (up to the proof of `prop:teacher:kinks`, and `lem:teacher:finite`), `limits` and `app-limits`, `discussion`, `computable`.
  * `research/tracks/split/notes-final.md` (§0, §1, §4 in full; the headings of the rest) and `split/iid/notes-final.md` (header, revision summary, §7, §11, the verification log).
  * `research/paper-review/REFRAME.md` (binding rules for any paper text).
* **Scripts.** `checks/r1`–`r6`, Python 3.11 with NumPy (no other dependencies), deterministic or seeded; each output is saved next to its script as a `.out` file. The verification log lists what each checks.
* **Status tags.**
  * **[proved]**: full proof here. **[proved: Paper 2, label]**: proved in Paper 2; restated here, possibly read in a new way.
  * **[proved, new]** marks a statement that is not in Paper 2 or the split records, even when its proof is a short assembly of their lemmas. §7 says exactly what is new.
  * **[computed: rN]**: checked by that script; output in the `.out` file.
  * **[known: ref]**, **[conjecture]**, **[open]**, **[refuted]**, **[remark]**: as named. Refuted statements are kept, with the reason.
* **Conventions.** $\log=\log_2$. Code lengths, fits, risks and deficiencies are in bits. κ is Paper 2's machine constant and may differ between occurrences. $c=\lambda/n$. Numbers computed in an *explicit* toy class (r2–r5) involve no machine constant: they are statements about that class. Notation follows Paper 2 (`def:setup:data`, `def:setup:objectives`, `def:split:setting`): $L_n(\pi)$ is the fit of $\pi$ after $n$ queries, $J_\lambda=\lambda\ell+L$, $R(\pi)$ is a population risk, $J_c=c\,\ell+R$, $\Phi(c)=\inf J_c$.
* **Repository.** No git command that changes repository state was run. Files written: this record and `checks/`.

---

## 0. Summary

The author's "ideal theorem" asks for a learning procedure that returns a copy of a human, a sampler with its own randomness, and not the sampler with some of its random bits stored, nor an alien system that predicts the human by other means, even when some alien predicts better. The results, all in toy settings:

1. **Private coins: robust against every program, for fixed λ > 1 (§2).** If the human's coins are independent of everything a hypothesis can see (its input, the history, any model of the environment) given the human's own input, then no hypothesis, whatever its internal structure, ever gains more than its own length plus the Ville deficiency δ* over the human, at any sample size; and $\Pr[\delta^*\ge j]\le2^{-j}$ (Lemma 2.1, the Ville lemma with side information) [proved, new in this form]. In the product class with per-query answers this gives Theorem A of Paper 2 for the human: for fixed λ > 1, at every $n$, explicit length bounds and exponentially small posterior mass on stored-coin programs; for every $1\le\lambda_n=o(n)$, eventually exactly the shortest programs whose predictive law is the human's (Theorem 2.2) [proved: Paper 2 with Lemma 2.1]. In this regime no alien predicts better in population; aliens can only win on a sample, and they pay one bit of length per bit gained. Privacy is exactly the condition: if the coins depend on something an alien can see, an alien gains linearly in $n$ and every $\lambda_n=o(n)$ eventually selects it (Proposition 2.3, the privacy dichotomy) [proved, new].
2. **Behavioural non-identifiability (§3).** From input–output data one identifies the human's predictive law on the support of the input law, and the selected program is a *shortest* program for that law in the class. Which program the human "is", and what it does off the support, are not identifiable by any procedure (Proposition 3.1) [proved, new; elementary]. An alien that computes the human's law more compactly is selected instead (Example 3.2) [computed: r4(A)]. Only data about the mechanism (internal observables, interventions, off-support queries) or a class restricted to the human's architecture separate a copy from an equivalent alien (Proposition 3.3) [proved, new; elementary]. "The sampler with some bits specified" is excluded per query and not with frozen answers (Remark 3.4) [proved: Paper 2; computed: r4(C)].
3. **Environment-driven coins: a window, robust against every alien (§4).** Let the human's coins be a fixed function β of an environment variable $w$ uniform on $2^m$ cells (an input feature the human ignores, or a latent cause seen through the input). Then aliens that model β predict better, by up to $H(\rho)$ bits per sample.
   * With fixed λ or any $\lambda_n=o(n)$ an alien is eventually selected (Proposition 4.2) [proved].
   * With $\lambda=cn$ the human beats an alien iff $c$ exceeds the alien's advantage per bit of extra description, and the human is the unique selection iff $c$ lies between the largest such rate and the human's own left steepness (Proposition 4.3) [proved: Paper 2's hull lemma, read for imitation].
   * **The robust part (Lemma 4.4, Lemma 4.5)** [proved, new; generalises Paper 2's `lem:teacher:coding` and (D2)]: if β is incompressible relative to the human's model, *every* program of the class that knows the human's model is at least $2^m(R_H-R(\pi))$ bits longer than the human, minus an offset of order $m+\delta_\beta$: its advantage per bit is at most the reuse factor $2^{-m}$, whatever its internal structure.
   * **Theorem 4.6** [proved, new, given a left-side hypothesis]: for $c>2^{-m}$, wherever programs that do not know the human's model are not near-optimal, every near-optimal program knows the human's model, is at most a few bits longer than the human, fits no better than the human up to a slack, and holds little information about β. The left-side hypothesis holds unconditionally for a coin-flipping human and is Paper 2's `thm:teacher:main` for a parity human (Corollary 4.7) [proved]. The cn-MAPs from per-query samples satisfy the same conclusions eventually (Corollary 4.8) [proved].
   * **Necessary conditions (Proposition 4.9)** [proved, new; (a) is Paper 2's twin-world argument]: (a) *robustness is blindness*: for every procedure, the probability of copying the human in a world with environment-driven coins plus the probability of copying an alien-like human in the twin world with the same data law is at most 1; (b) a schedule keeps the human only if $\lambda_n/n$ stays between the largest alien rate and the human's steepness; (c) a coupling with a short description (a pseudo-random generator with an $s$-bit seed, a simple feature) defeats every $c$ once $s\lesssim H(\rho)(\ell_H-\ell_{\rm coin})/(\log|Y|-H(\rho))$; (d) the lower end $2^{-m}$ is sharp, so a window needs $2^m\gtrsim(\ell_H-\ell_{\rm coin})/(\log|Y|-H(\rho))$ cells.
   * In an explicit class the window is exactly (largest alien rate, human's steepness), its lower end is $2^{-m}(1-o(1))$, a PRG coupling with a short seed closes it, and the cn-MAPs from samples follow it [computed: r2, r3, r4(B), r6].
4. **Latent state (§5).** Ville's bound survives for every chronological class (Proposition 5.1) [proved]. On a single trajectory an in-context learner, a Bayes mixture over humans, absorbs the human: for every λ > 1 and every data the human's program is never selected once it is named within the family by more than a constant (Proposition 5.2) [proved; computed: r5]. With i.i.d. episodes in which the human and every hypothesis restart, Theorem A holds per episode and the learner pays its regret in every episode (Proposition 5.3) [proved, new; computed: r5]. A single trajectory in a class without a dominating member is open.
5. **Interpretation (§6).** In these toys the ideal theorem holds in two precise senses: against every alien when the coins are private (fixed λ > 1), and against every alien whose advantage per bit is below $c$ when the coins are driven by an incompressible environment pattern ($\lambda=cn$). It does not give a mechanism, it does not choose $c$, it fails for cheap or pseudo-random couplings, and it needs per-query answers and episodes. The big philosophical problems the author mentions remain: §6 lists them as the results bear on them.

---

## 1. Setting, and what "a copy" and "an alien" mean

### 1.1 Objects

* **The human** is a sampler: a probability kernel $\nu_H(y\mid x)$ on a finite label set $Y$, with a program $\pi_H$ of length $\ell_H$ in the hypothesis class. "Sampler" means the human answers each query with fresh coins of its own: the per-query data object PQ of `def:setup:data`, with pairs $(x_i,y_i)$, the label redrawn at every query, also at a repeated input.
* **Hypothesis classes.** As in `def:setup:class` and `def:split:setting`: a countable prefix-free set of programs with Kraft weights $\sum2^{-\ell(\pi)}\le1$. The main one is the product class $\Hcl{\times}$ (lower-semicomputable conditional semimeasures, private randomness per query). §2 and §5 also use classes of *predictors with side information*: a program $\pi$ outputs at query $i$ a sub-probability $q_{\pi,i}(\cdot)$ on $Y$ that may depend on anything available before $y_i$ is drawn (Definition 2.0).
* **A copy** of the human is a program whose kernel equals $\nu_H$ at μ-almost every input: a member of $\mathcal E=\mathcal E(\nu_H)$ of `def:split:setting`. The *shortest copies* are $\mathcal E_0$, of length $\ell_0\le\ell_H$. "Copy" is behavioural throughout; §3 shows that nothing more is identifiable from input–output data.
* **An alien** is any program of the class that is not a copy. Nothing is assumed about how it computes. Its *advantage* is $a(\pi):=R(\pi_H)-R(\pi)$ in population or $L_n(\pi_H)-L_n(\pi)$ on a sample; for $\ell(\pi)>\ell_H$ its **advantage per bit**, or *rate*, is
  $$r(\pi):=\frac{R(\pi_H)-R(\pi)}{\ell(\pi)-\ell_H}.$$
* **The human's left steepness and right secant** in population, at its point $(\ell_H,R_H)$, $R_H:=R(\pi_H)$:
  $$s_-(H):=\min_{\ell(\pi)<\ell_H}\frac{R(\pi)-R_H}{\ell_H-\ell(\pi)},\qquad s_+(H):=\max\Big\{0,\ \sup_{\ell(\pi)>\ell_H}r(\pi)\Big\}$$
  ($\min\emptyset:=\infty$). These are the left steepness and right secant of `def:kink:kinks` at the human's point, in the population reading.

### 1.2 Four ways to fail to copy a human, and where each is treated

| failure mode (author's words in quotes) | what it is formally | what handles it | where |
|---|---|---|---|
| "the sampler with some bits specified" | a partial fill-in: the human's kernel with some sampled answers stored | λ > 1 and per-query answers (fixed λ), or any $\lambda_n=o(n)$ per query | Thm 2.2, Remark 3.4 |
| "some completely alien system that just thinks about what the human would say": a learner | an in-context learner, a mixture over humans that infers which human it faces | private randomness per query (no such hypothesis exists in $\Hcl{\times}$), or episodes | Remark 2.4, §5 |
| the same, as a fixed predictor computing the human's law differently | a behaviourally equivalent program | nothing in the data; only mechanism data or a restricted class | §3 |
| "alien thinking about the environment around the human" that predicts better | a program exploiting environment-driven coins | λ = cn in a window, if the coupling is incompressible; nothing if it is cheap | §4 |

---

## 2. (a) Private coins: robust against every program

### 2.1 The Ville lemma with side information

**Definition 2.0 (side information, privacy, predictors).** On one probability space take queries $x_1,x_2,\dots\in X$, labels $y_1,y_2,\dots\in Y$, and σ-algebras $\mathcal A_1\subseteq\mathcal A_2\subseteq\cdots$ ("what a hypothesis may know before $y_i$ is drawn") with $x_i$ $\mathcal A_i$-measurable and $y_i$ $\mathcal A_{i+1}$-measurable. $\mathcal A_i$ may contain the earlier inputs and labels, environment features $z_i$ observed together with $x_i$, and any other environment variables, past or future, that the human never sees.
* **(Priv)** For every $i$: $\Pr[y_i=y\mid\mathcal A_i]=\nu_H(y\mid x_i)$ almost surely. In words: given the human's own input, the human's answer is independent of everything a hypothesis may know.
* A **predictor** $\pi$ assigns to each $i$ an $\mathcal A_i$-measurable sub-probability $q_{\pi,i}$ on $Y$. Its fit is $L_n(\pi):=-\sum_{i\le n}\log q_{\pi,i}(y_i)$, and the human's is $L_n(\nu_H):=-\sum_{i\le n}\log\nu_H(y_i\mid x_i)$.
* Product hypotheses on $x$ ($q_{\pi,i}=\nu_\pi(\cdot\mid x_i)$), product hypotheses on an extended input $(x_i,z_i)$, chronological hypotheses ($q_{\pi,i}$ a function of the history), and hypotheses that model the whole environment are all predictors. Nothing is assumed about how $q_{\pi,i}$ is computed, or whether it is computable.

**Lemma 2.1 (Ville deficiency with side information)** [proved, new in this form; the argument is Paper 2's `lem:split:ville`; Ville's inequality known]. Assume (Priv). Let $\mathcal C$ be a countable family of predictors with $\sum_{\pi\in\mathcal C}2^{-\ell(\pi)}\le1$, put $\xi_n:=\sum_\pi2^{-\ell(\pi)-L_n(\pi)}$, $\delta_n:=\log\big(\xi_n\,2^{L_n(\nu_H)}\big)$ and $\delta^*:=\sup_{n\ge0}\delta_n$. Then $\Pr[\delta^*\ge j]\le2^{-j}$ for every $j\ge0$, and for every $\pi\in\mathcal C$ and every $n$,
$$L_n(\pi)\ \ge\ L_n(\nu_H)-\ell(\pi)-\delta_n\ \ge\ L_n(\nu_H)-\ell(\pi)-\delta^*.$$
The human need not belong to $\mathcal C$.

*Proof.* Almost surely $\nu_H(y_i\mid x_i)>0$ for all $i$, so $M_n:=\xi_n2^{L_n(\nu_H)}=\sum_\pi2^{-\ell(\pi)}\prod_{i\le n}q_{\pi,i}(y_i)/\nu_H(y_i\mid x_i)$ is well defined. $M_n$ is $\mathcal A_{n+1}$-measurable, since it depends on $y_1,\dots,y_n$, $x_1,\dots,x_n$ and $q_{\pi,i}$ for $i\le n$. By (Priv) and monotone convergence,
$$\Ex[M_{n+1}\mid\mathcal A_{n+1}]=\sum_\pi2^{-\ell(\pi)}\prod_{i\le n}\frac{q_{\pi,i}(y_i)}{\nu_H(y_i\mid x_i)}\sum_{y:\nu_H(y\mid x_{n+1})>0}q_{\pi,n+1}(y)\ \le\ M_n .$$
So $(M_n)$ is a nonnegative supermartingale for $(\mathcal A_{n+1})_n$ with $M_0=\sum_\pi2^{-\ell(\pi)}\le1$, and Ville's maximal inequality \[Ville 1939\] gives $\Pr[\sup_nM_n\ge2^j]\le2^{-j}$. Keeping one term, $2^{-\ell(\pi)}2^{L_n(\nu_H)-L_n(\pi)}\le M_n=2^{\delta_n}$. ∎

**Reading.** An alien may model the environment in arbitrary detail, see the past, even see future environment variables: as long as the human's coins are independent of what it sees, given the human's input, its cumulative gain over the human is at most its own length plus δ*, at every sample size, simultaneously for all aliens. [computed: r1(A): 3000 runs of $n=2000$ with aliens that see a 10-valued environment variable, a fixed random 80-cell table, and a history-aware Krichevsky–Trofimov learner per (input, environment) cell; $\Pr_{\rm emp}[\delta^*\ge j]=0.0333,0.0177,0.0090,0.0047,0.0017,0.0003$ for $j=1,2,3,4,6,8$, against $2^{-j}$; no program's gain ever exceeded its length plus δ*.]

### 2.2 Recovery

**Theorem 2.2 (robust recovery of a human with private coins)** [proved: Paper 2's `thm:split:private` and `thm:recovery:main`, with Lemma 2.1 in place of `lem:split:ville`; part 2 and the side-information reading are new]. Assume (Priv), and let $\mathcal C$ be a countable family of predictors with Kraft weights that contains a program $\pi_H$ of length $k$ with $q_{\pi_H,i}=\nu_H(\cdot\mid x_i)$.
1. *(Every $n$, any input rule.)* For fixed λ > 1, simultaneously for all $n$: every λ-MAP $\hat\pi$ has $\ell(\hat\pi)\le(\lambda k+\delta^*)/(\lambda-1)$ and $L_n(\nu_H)-\ell(\hat\pi)-\delta^*\le L_n(\hat\pi)\le L_n(\nu_H)+\lambda k$; the power posterior gives programs longer than $\bar\ell$ mass at most $2^{\lambda k+\delta^*-(\lambda-1)\bar\ell}$; every *fill-in* (a predictor giving the realised answers probability 1) has length at least $L_n(\nu_H)-\delta^*$, and all fill-ins together have power-posterior mass at most $2^{\lambda k+\lambda\delta^*-(\lambda-1)L_n(\nu_H)}$.
2. *(Population.)* If the pairs $(x_i,z_i)$ are i.i.d. and the predictors are product hypotheses on the extended input $(x,z)$, then $R(\pi)-R(\pi_H)=\Ex_{x,z}\KL\big(\nu_H(\cdot\mid x)\,\Vert\,\nu_\pi(\cdot\mid x,z)\big)\ge0$, with equality iff $\nu_\pi(\cdot\mid x,z)=\nu_H(\cdot\mid x)$ almost everywhere. No alien predicts better in population.
3. *(Per query, product class.)* In the setting of 2, Theorem A (`thm:recovery:main`) holds with the input $(x,z)$ and the sampler $\tilde\nu(y\mid x,z):=\nu_H(y\mid x)$: for every schedule $1\le\lambda_n=o(n)$, almost surely the set of $\lambda_n$-MAPs is eventually $\mathcal E_0$, the shortest programs whose kernel equals the human's almost everywhere; for fixed λ > 1 it is $\mathcal E_0$ with probability at least $1-\varepsilon$ at every $n\ge\lambda(\ell_0+\log(2/\varepsilon))\ln2/(2\min(1,\lambda-1)\gamma)$, with γ the margin of `thm:recovery:main`(d).
4. *(Any predictors.)* If infinitely many queries are made, then for every fixed λ ≥ 1, almost surely from some $n$ on every λ-MAP is $\nu_H$-equivalent on the run: $\sum_i\Hel\big(\nu_H(\cdot\mid x_i),q_{\pi,i}\big)<\infty$.

*Proof.* (1) For a λ-MAP, $\lambda\ell(\hat\pi)+L_n(\hat\pi)\le J_\lambda(\pi_H)=\lambda k+L_n(\nu_H)$; insert Lemma 2.1, $L_n(\hat\pi)\ge L_n(\nu_H)-\ell(\hat\pi)-\delta^*$, to get the length bound, and rearrange for the fits. Divide all posterior weights by $2^{-L_n(\nu_H)}$; the normaliser is then at least $2^{-\lambda k}$. Programs longer than $\bar\ell$: $\sum_{\ell(\pi)>\bar\ell}2^{-\lambda\ell(\pi)}2^{L_n(\nu_H)-L_n(\pi)}\le2^{-(\lambda-1)\bar\ell}M_n\le2^{-(\lambda-1)\bar\ell+\delta^*}$. A fill-in has $L_n=0$, so Lemma 2.1 gives $\ell\ge L_n(\nu_H)-\delta^*$, and $\sum_{\rm fill\text{-}ins}2^{-\lambda\ell}2^{L_n(\nu_H)}\le2^{-(\lambda-1)(L_n(\nu_H)-\delta^*)}M_n\le2^{-(\lambda-1)L_n(\nu_H)+\lambda\delta^*}$. This is the proof of `thm:split:private`(i)–(iii) with Lemma 2.1.
(2) Under (Priv), $y$ given $(x,z)$ has law $\nu_H(\cdot\mid x)$, so $R(\pi)-R(\pi_H)=\Ex_{x,z}\sum_y\nu_H(y\mid x)\log\frac{\nu_H(y\mid x)}{\nu_\pi(y\mid x,z)}$; Gibbs' inequality with $\sum_y\nu_\pi\le1$ gives $\ge0$, with equality iff the two agree (`lem:recovery:ratios`(c)).
(3) With i.i.d. $(x_i,z_i)$ and (Priv), the triples give per-query data on the countable input set of pairs, i.i.d. from $\tilde\mu\otimes\tilde\nu$; apply `thm:recovery:main`.
(4) The proof of `thm:split:private`(iv) uses two facts, both valid here: the tail sums $Z^{\bar\ell}_n:=\sum_{\ell(\pi)>\bar\ell}2^{-\ell(\pi)}\Lambda_n(\pi)$, $\Lambda_n(\pi):=2^{L_n(\nu_H)-L_n(\pi)}$, are nonnegative supermartingales started at the prior tail, by the computation in Lemma 2.1, which confines the λ-MAPs to a finite set; and for each program, $g_{n+1}:=\Hel(\nu_H(\cdot\mid x_{n+1}),q_{\pi,n+1})$ is $\mathcal A_{n+1}$-measurable with $\Ex[\sqrt{\Lambda_{n+1}/\Lambda_n}\mid\mathcal A_{n+1}]=1-g_{n+1}$ by (Priv), so `lem:recovery:ratios`(b) gives $\Lambda_n(\pi)\to0$ on $\{\sum_ig_i=\infty\}$. ∎

**Proposition 2.3 (the privacy dichotomy)** [proved, new]. Let $(x_i,z_i,y_i)$ be i.i.d. from a law $P$, the learner see $(x_i,z_i)$, and the human's kernel be calibrated, $\nu_H(y\mid x)=P(y\mid x)$. Put $I:=I(Y;Z\mid X)$ in bits.
* (a) If $I=0$, (Priv) holds with $\mathcal A_i:=\sigma\big((x_j,z_j)_{j\ge1},(y_j)_{j<i}\big)$, future inputs and environment variables included; so Lemma 2.1 and Theorem 2.2 apply: almost surely $\sup_n\max_\pi\big[L_n(\nu_H)-L_n(\pi)-\ell(\pi)\big]\le\delta^*<\infty$.
* (b) If $I>0$ and the class contains a program $\pi^*$ with $\nu_{\pi^*}(y\mid x,z)=P(y\mid x,z)$ almost surely, then $\frac1n\big[L_n(\nu_H)-L_n(\pi^*)\big]\to I$ almost surely: the gain of $\pi^*$ minus its length tends to $+\infty$. For every schedule $\lambda_n=o(n)$, almost surely every copy of the human is a $\lambda_n$-MAP for only finitely many $n$. In $\Hcl{\times}$ such a $\pi^*$ exists whenever $P(y\mid x,z)$ is computable.

*Proof.* (a) $I=0$ means $P(y\mid x,z)=P(y\mid x)$ almost surely; independence across $i$ lets the other indices be added to the conditioning. (b) The variables $D_i:=\log\big(P(y_i\mid x_i,z_i)/P(y_i\mid x_i)\big)$ are i.i.d. with mean $I$; their positive part is at most $\log(1/P(y_i\mid x_i))$, of mean $H(Y\mid X)\le\log|Y|$, and their negative part is integrable by $\Ex(\log Z)^+\le\log e/e$ for $Z:=P(y\mid x)/P(y\mid x,z)$, $\Ex[Z\mid x,z]\le1$ (`lem:recovery:ratios`(c)). The strong law gives the limit. A copy $\pi$ of the human has the human's fits almost surely, so $\frac1n[J_{\lambda_n}(\pi)-J_{\lambda_n}(\pi^*)]=\frac{\lambda_n}n(\ell(\pi)-\ell(\pi^*))+\frac1n[L_n(\nu_H)-L_n(\pi^*)]\to I>0$. ∎

[computed: r1(B): with the coins a deterministic function of the environment variable, calibrated, $I=0.8272$ bits per sample; the exploiting alien's gain is $1672.4$, $1665.0$, $1676.1$ at $n=2000$ against $nI=1654.3$; at λ = 2 it first beats the human at $n=187,194,195$ (predicted $\lambda\Delta/I=193$), at λ = 4 at $n=386,366,400$ (predicted 387).]

**Remark 2.4 (two halves of robustness; learners)** [remark, from proved results]. "Robust against every program" has two halves.
* **(R1)** No program gains more than its length plus δ* (Lemma 2.1). This holds in every class, for every kind of predictor.
* **(R2)** Every program *shorter* than the human that is not a copy loses an amount that grows without bound. In product classes with i.i.d. queries it grows linearly, at the KL rate (Theorem 2.2(3)). It fails for a predictor whose total loss against the human stays bounded: a Bayes mixture over humans that contains the human with weight $w$ loses at most $\log(1/w)$ bits in total. Such an in-context learner is the formal version of "a completely alien system that just thinks about what the human would say". It is a single hypothesis only if hypotheses can carry information across queries; under private randomness per query no hypothesis of $\Hcl{\times}$ can (`cor:absorb:nouniversal`). With history it can, and it absorbs the human (§5). A parametric learner with regret growing like $\log n$ is rejected eventually at fixed λ; a countable mixture that contains the human is not. [computed: r1(C): a Krichevsky–Trofimov learner over 80 cells, of length 6 against the human's 4, has regret $7.7$, $121$, $194$, $274$ bits at $n=10^2,10^3,5\cdot10^3,2\cdot10^4$, about $40\log(n/80)$.]

---

## 3. (b) Behavioural non-identifiability

**Proposition 3.1 (what input–output data identify)** [proved, new; elementary]. Per-query data with inputs i.i.d. from μ.
* (a) If $\nu_{\pi_1}=\nu_{\pi_2}$ at μ-almost every input, then almost surely $L_n(\pi_1)=L_n(\pi_2)$ for all $n$. So for every λ > 0 and every $n$, $J_\lambda(\pi_1)-J_\lambda(\pi_2)=\lambda(\ell(\pi_1)-\ell(\pi_2))$, and the power-posterior odds are $2^{-\lambda(\ell(\pi_1)-\ell(\pi_2))}$, whatever the data.
* (b) *No procedure separates them.* Let two worlds have the same input law μ and humans whose kernels agree μ-almost everywhere, with any mechanisms and any behaviour off the support of μ. The data have the same law in both worlds, so every procedure Ψ (any measurable function of the data, randomised or not) has the same output law in both. For disjoint sets $A_1,A_2$ of programs, $\Pr_{W_1}[\Psi\in A_1]+\Pr_{W_2}[\Psi\in A_2]\le1$.
* (c) *What is identified.* The kernel at μ-almost every input: for every $1\le\lambda_n=o(n)$ the $\lambda_n$-MAPs are eventually exactly $\mathcal E_0$, the shortest copies in the class (Theorem A). Not identified: which member of $\mathcal E$ is "the human's program", the kernel off the support of μ, and anything internal.

*Proof.* (a) The likelihood factors agree whenever $x_i$ lies in the agreement set, which holds for all $i$ almost surely. (b) In both worlds the data are i.i.d. from $\mu\otimes\nu_H$. (c) `thm:recovery:main`(a). ∎

With frozen answers (FR) even the kernel at an atom with noise is not identifiable by any procedure (`prop:recovery:frozen`(a)). So exact behavioural copies need per-query answers: the human answers a repeated question afresh.

**Example 3.2 (an alien that computes the human's law more compactly)** [computed: r4(A)]. Inputs $w$ uniform on $\{0,1\}^6$. The "human" computes the parity of *all* bits of its input by a long-winded procedure and flips it with probability $1/8$; the "alien" computes the parity of the first six bits directly, with the same flip. The two are given lengths 40 and 20 bits (assigned, not derived from a code; only the difference matters). On $\{0,1\}^6$ the kernels coincide; on an input of length 7, never queried, they differ. At $n=10,100,1000,10^4$ the fits are exactly equal, $J(\text{human})-J(\text{alien})=20\lambda$ at λ = 1 and 2, and the log posterior odds are $-20\lambda$: the alien is selected at every $n$ and every λ ≥ 1, and the selected program's extrapolation to the input $(1,0,0,0,0,0,1)$ is the alien's (mode 1), not the human's (mode 0).

**Proposition 3.3 (what separates a copy from an equivalent alien)** [proved, new; elementary]. Let $\pi_1,\pi_2$ have equal kernels μ-almost everywhere.
* (a) *Observables of the mechanism.* If each query also returns an internal observable $\tau_i\in T$ drawn jointly with $y_i$ from the human's kernel $\nu_H(y,\tau\mid x)$, and the hypotheses are kernels on $Y\times T$, Theorem A applies with the label set $Y\times T$: the $\lambda_n$-MAP is eventually a shortest program for the joint law, and programs that agree on $y$ but not on τ are separated.
* (b) *Interventions.* If the queries include interventions ι on internal variables, drawn with the input from a law under which an intervention that separates the two programs has positive probability, Theorem A applies with the input $(x,\iota)$ and separates them.
* (c) *Queries off the old support.* Enlarging the support of μ to inputs where the programs differ separates them. (a)–(c) are one statement: the data identify the kernel of whatever is observed, under whatever is varied.
* (d) *A restricted class.* If every program of the class whose kernel equals the human's is longer than $\pi_H$, for example because every such program consists of the human's model plus extra computation, then $\mathcal E_0=\{\pi_H\}$ and Theorem A returns $\pi_H$ itself. This is an assumption about the class, which by Proposition 3.1(b) no data can check.
* (e) *What does not help:* more data from the same μ, any schedule $\lambda_n$, or any prior that depends on programs only through their length; within $\mathcal E$ all of them order programs by length alone (Proposition 3.1(a)).

*Proof.* (a)–(c) are `thm:recovery:main` with the enlarged label or input set; (d) is the definition of $\mathcal E_0$; (e) is Proposition 3.1. ∎

**Remark 3.4 (the sampler with some bits specified)** [proved: Paper 2's `prop:recovery:frozen`(c) and `thm:recovery:main`(a); computed: r4(C)]. A *partial fill-in* is the human's kernel with the answers at a finite set of inputs stored. Per query it differs from the human at an atom of μ, so it is eventually rejected for every $1\le\lambda_n=o(n)$; with frozen answers it can be selected forever. In Paper 2's class (μ uniform on ten inputs, the human $\mathrm{Bern}(1/64)$ of length 5, the exception programs $e_j$ of length 9, λ = 1.2): with frozen answers some $e_j$ is eventually the MAP with probability exactly $1-(63/64)^{10}=0.1457$; per query, $\Pr_n[\text{some }e_j\text{ is a λ-MAP}]\le10\big((9/10+1/640)^n-(9/10)^n\big)$, which is $5.0\cdot10^{-5}$ at $n=100$ and $5.0\cdot10^{-18}$ at $n=400$. In 20,000 simulated runs some $e_j$ was a MAP at some time in a fraction $0.1465$ of them (close to the frozen value, because early on both objects coincide), after time 100 in $0.0001$, and never after time 113.

---

## 4. (c) Environment-driven coins: aliens predict better, and a window picks the human anyway

### 4.1 The setting

**Setting 4.1 (environment-driven coins).**
* $Y$ and $B$ (the human's coin values) are finite. The *coupling variable* $w$ is uniform on $W:=\{0,1\}^m$. Given $w$, the human's input $x\in X$ ($X$ countable) is drawn from a computable kernel $\mu(x\mid w)$ with finite support; the input law is $\mu:=2^{-m}\sum_w\mu(\cdot\mid w)$.
* **The human** has a computable response function $h:X\times B\to Y$, injective in $b$ for each $x$, and a computable coin law ρ on $B$ with $\rho(b)2^m\in\mathbb Z$. Its kernel, the human's own description of how it answers, is
  $$\nu_H(y\mid x):=\rho(b)\ \text{ if } y=h(x,b),\qquad 0\text{ otherwise}.$$
  $h^*$ denotes a finite description of $(h,\rho,\mu(\cdot\mid\cdot))$: the human's model together with the input mechanism. $\pi_H$ is a program for $\nu_H$ of length $\ell_H$ built from a description of $h^*$, so that $t_0:=K(h^*\mid\pi_H)$ is a constant and $K(h^*)-t_0-\kappa\le\ell_H\le K(h^*)+\kappa$.
* **The world.** A fixed *coupling* $\beta:W\to B$ with exact type ρ, $|\beta^{-1}(b)|=\rho(b)2^m$. At each query $w_i$ is uniform, $x_i\sim\mu(\cdot\mid w_i)$, and $y_i:=h(x_i,\beta(w_i))$: the human's coin is $\beta(w_i)$. The learner sees $(x_i,y_i)$. Its law given $x$ is the *true kernel* $P^*(y\mid x)$, which differs from $\nu_H$ whenever $x$ carries information about $w$.
* **Three readings** (the brief's three mechanisms):
  * *Feature*: $x=(w,x')$ with $\mu(\cdot\mid w)=\delta_w\otimes\mu'$. The learner sees the environment feature $w$; the human ignores it. $P^*$ is deterministic.
  * *Latent shared cause*: $w$ unobserved, $x$ a noisy function of $w$.
  * *Pseudo-random generator*: β has a short description (Proposition 4.9(c)).
  * Paper 2's teacher instance (`def:teacher:instance`) is the feature case with $w$ the first $m$ bits of $x\in\{0,1\}^d$, $h(x,b)=f_a(x)\oplus b$, $\rho=\mathrm{Bern}(p)$ and $\beta=\ind_S$: a teacher's systematic errors are, formally, environment-driven coins.
* **Description lengths.** $L_\beta:=\log\big(2^m!/\prod_b(\rho(b)2^m)!\big)$, the log-size of the type class; $B_\beta:=K(\beta\mid h^*,K(h^*))$; the deficiency $\delta_\beta:=L_\beta-B_\beta$. For β uniform on the type class, $\Pr[\delta_\beta>j]<2^{-j}$, and always $\delta_\beta\ge-2\log(m+1)-\kappa$, since β is described by its index in the type class. The type-class bounds give $2^mH(\rho)-|B|\log(2^m+1)\le L_\beta\le2^mH(\rho)$ [known: the type-class bounds of Cover and Thomas; computed: r6(B)].
* **Population risk.** $R(\pi):=\Ex[-\log\nu_\pi(y_i\mid x_i)]=2^{-m}\sum_w\Ex_{x\sim\mu(\cdot\mid w)}[-\log\nu_\pi(h(x,\beta(w))\mid x)]$. Since $\nu_H(h(x,b)\mid x)=\rho(b)$, $R_H:=R(\pi_H)=2^{-m}\sum_w\log(1/\rho(\beta(w)))=H(\rho)$ [computed: r6(A)].

A **copy** of the human is a program with kernel $\nu_H$; the "aliens that predict better" are the programs with $R(\pi)<H(\rho)$, which must hold information about β. The best possible risk is $H_W(Y\mid X):=\Ex[-\log P^*(y\mid x)]$, which is 0 in the feature case.

### 4.2 Consistent schedules learn the environment; λ = cn compares rates

**Proposition 4.2 (fixed λ and every λ_n = o(n) select an alien)** [proved; (b) is Theorem A].
* (a) If some program $\pi_A$ has $R(\pi_A)<H(\rho)$, then for every schedule $\lambda_n>0$ with $\lambda_n/n\to0$, almost surely every copy of the human is a $\lambda_n$-MAP for only finitely many $n$.
* (b) In $\Hcl{\times}$, $P^*$ is computable from $(h^*,\beta)$, so it has programs; for every $1\le\lambda_n=o(n)$ the $\lambda_n$-MAPs are eventually exactly the shortest programs for $P^*$. These predict the environment-driven coins as well as the data allow, so they are aliens.

*Proof.* (a) For a copy π, $\frac1n[J_{\lambda_n}(\pi)-J_{\lambda_n}(\pi_A)]=\frac{\lambda_n}n(\ell(\pi)-\ell(\pi_A))+\hat R_n(\pi)-\hat R_n(\pi_A)\to H(\rho)-R(\pi_A)>0$ almost surely, by the strong law for the two empirical risks, which have finite means. (b) `thm:recovery:main`(a) with the sampler $P^*$. ∎

[computed: r3: with the coins driven by 64 of 1024 cells, fixed λ = 2 selects the human-type program at $n\le1000$ and the full memoriser of β from $n=3000$ on; λ = 8 switches between $n=3000$ and $10^4$; $\lambda=\sqrt n$ keeps the human up to $n=10^6$ and selects the memoriser at $3\cdot10^6$ and $10^7$, as predicted by $\sqrt n\,\Delta=nH(p)$ at $n\approx(\Delta/H(p))^2\approx1.1\cdot10^6$ with $\Delta=355$ bits.]

**Proposition 4.3 (λ = cn: the window is a rate condition)** [proved: Paper 2's `lem:setup:hull`, population reading; the reading for imitation is new]. Let $c>0$.
* For every program π longer than the human: $J_c(\pi)>J_c(\pi_H)$ iff $c>r(\pi)$, its advantage per bit.
* For π shorter than the human: $J_c(\pi)>J_c(\pi_H)$ iff $c<(R(\pi)-R_H)/(\ell_H-\ell(\pi))$.
* For π of the same length: iff $R(\pi)>R_H$.

So $\pi_H$ is the unique minimiser of $J_c$ iff $s_+(H)<c<s_-(H)$ and no other program has length $\ell_H$ and risk at most $R_H$. When $s_+(H)>0$ the supremum defining it is attained. By `lem:setup:hull`(iii), this happens on a nonempty open interval of $c$ iff the human's point is a vertex of the population hull that no other program shares.

*Proof.* $J_c(\pi)-J_c(\pi_H)=c(\ell(\pi)-\ell_H)+R(\pi)-R_H$, rearranged in each case. The $\min$ in $s_-$ is over finitely many programs. If some program has rate $s>0$, every program with rate at least $s$ has $0\le R(\pi)\le R_H-s(\ell(\pi)-\ell_H)$, hence length at most $\ell_H+R_H/s$; only finitely many qualify, and the supremum is a maximum. ∎

**Reading.** The procedure with $\lambda=cn$ is robust exactly against the aliens whose advantage per bit is below $c$, and loses to every alien whose advantage per bit is above $c$. How an alien computes plays no role; only its pair (extra length, risk reduction) does, and only through their ratio. In this sense the advantage per bit is the right quantity for these procedures. Proposition 4.9(a) shows what any procedure must give up.

### 4.3 The robust part: every alien pays at least $2^m$ bits per bit of advantage per sample

**Lemma 4.4 (alien coding lemma)** [proved, new; generalises Paper 2's `lem:teacher:coding` from parities to any response function, coin set and input mechanism, with the same proof]. In Setting 4.1, for every $\pi\in\Hcl{\times}$,
$$K(\beta\mid h^*,\pi)\ \le\ 2^mR(\pi)+2\log(m+1)+\kappa .$$

*Proof.* Given $(\pi,h^*,m)$ define, for $w\in W$ and $b\in B$, $q_w(b):=\sum_x\mu(x\mid w)\,\nu_\pi(h(x,b)\mid x)$, a finite sum, lower semicomputable uniformly in $(\pi,h^*,m)$. By injectivity, $\sum_bq_w(b)\le\sum_x\mu(x\mid w)\sum_y\nu_\pi(y\mid x)\le1$. So $Q(\beta'):=\prod_wq_w(\beta'(w))$ is a semimeasure on $B^W$, lower semicomputable uniformly, and (F2) gives $K(\beta\mid\pi,h^*,m)\le-\log Q(\beta)+\kappa$. By Jensen's inequality for the convex $-\log$,
$$-\log Q(\beta)=\sum_w-\log\Ex_{x\sim\mu(\cdot\mid w)}\nu_\pi(h(x,\beta(w))\mid x)\ \le\ \sum_w\Ex_{x\sim\mu(\cdot\mid w)}\big[-\log\nu_\pi(y\mid x)\big]=2^mR(\pi).$$
Finally (F3) and (F5): $K(\beta\mid h^*,\pi)\le K(\beta\mid\pi,h^*,m)+K(m)+\kappa\le2^mR(\pi)+2\log(m+1)+\kappa$. ∎

[computed: r6(A): on explicit instances with $B=\{0,1,2\}$, $\rho=(\frac12,\frac14,\frac14)$, eight cells, both a latent-cause and a feature input mechanism, and 600 random programs (a third of them sub-probabilities): $\max_w\sum_bq_w(b)=1.000000000000$; the total mass of $Q$ over all $3^8$ couplings is at most $1.000000000000$; $\max[-\log Q(\beta)-2^mR(\pi)]=-0.127<0$; and $R(\pi_H)=H(\rho)=1.5$ exactly.]

**Lemma 4.5 (the right line of slope $2^{-m}$)** [proved, new; generalises (D2) of Paper 2's `lem:teacher:twopart`, with $K(h^*\mid\pi)$ in place of list decoding]. For every $\pi\in\Hcl{\times}$:
* (a) $\ell(\pi)+2^mR(\pi)\ \ge\ K(h^*)+B_\beta-K(h^*\mid\pi)-2\log(m+1)-\kappa$;
* (b) $I_\beta(\pi):=B_\beta-K(\beta\mid h^*,\pi)\ \le\ \ell(\pi)-K(h^*)+K(h^*\mid\pi)+\kappa$;
* (c) $\ell(\pi)\ge K(h^*)-K(h^*\mid\pi)-\kappa$.

Consequently, for $t\ge t_0$ and $M_t:=\{\pi:K(h^*\mid\pi)\le t\}$, the programs that know the human's model up to $t$ bits, every $\pi\in M_t$ satisfies
$$\ell(\pi)-\ell_H\ \ge\ 2^m\big(H(\rho)-R(\pi)\big)-G_t,\qquad G_t:=t+\delta_\beta+|B|\log(2^m+1)+2\log(m+1)+(\ell_H-K(h^*))+\kappa,$$
together with the length floor $\ell(\pi)\ge\ell_{\rm fl}:=K(h^*)-t-\kappa$. In the language of `def:kink:kinks`, with the reference point $(\ell_H,H(\rho))$, $M_t$ has the right line of slope $2^{-m}$ per sample and offset $g_t:=G_t/2^m$. By `lem:kink:secant`(a), every program of $M_t$ that is $x>0$ bits longer than the human has advantage per bit $r(\pi)\le2^{-m}+G_t/(2^mx)$.

*Proof.* (F4) gives $K(h^*,\beta)\ge K(h^*)+B_\beta-\kappa$. (F3) and (F1) give $K(h^*,\beta)\le K(\pi)+K(h^*\mid\pi)+K(\beta\mid h^*,\pi)+\kappa\le\ell(\pi)+K(h^*\mid\pi)+K(\beta\mid h^*,\pi)+\kappa$. With Lemma 4.4 this is (a), and rearranged for $K(\beta\mid h^*,\pi)$ it is (b). (c) is $K(h^*)\le K(\pi)+K(h^*\mid\pi)+\kappa$. For the line, insert $K(h^*)=\ell_H-(\ell_H-K(h^*))$, $B_\beta=L_\beta-\delta_\beta$ and the type-class bound $L_\beta\ge2^mH(\rho)-|B|\log(2^m+1)$ into (a), with $K(h^*\mid\pi)\le t$. ∎

**Reading.** Lemma 4.5 is the formal content of "robustly". It bounds every program of the class, whatever its internal structure, by the information it holds: an alien that knows the human's model and beats the human by $a$ bits per sample must be about $2^ma$ bits longer. Computation without information does not help, because an incompressible coupling cannot be computed from fewer bits than it contains. The bound needs β to be incompressible given the human's model ($\delta_\beta$ small); Proposition 4.9(c) shows that it fails, as it must, for couplings with short descriptions.

### 4.4 The window theorem

**Theorem 4.6 (robust imitation in the window)** [proved, new; Paper 2's `lem:kink:main` with Lemma 4.5 as the right side]. In Setting 4.1 let $c>2^{-m}$, $\varepsilon\ge0$ and $t\ge t_0$, and assume the *left condition*
$$(\mathrm L_{t,c,\varepsilon})\qquad\text{every }\pi\text{ with }K(h^*\mid\pi)>t\text{ has }J_c(\pi)>J_c(\pi_H)+\varepsilon .$$
Then every program π with $J_c(\pi)\le\Phi(c)+\varepsilon$, in particular every minimiser of $J_c$, satisfies:
* (i) *it knows the human's model:* $K(h^*\mid\pi)\le t$;
* (ii) *it is short:* $\ell(\pi)\le\ell_H+(g_t+\varepsilon)/(c-2^{-m})$;
* (iii) *it predicts neither better nor worse than the human, up to slack:*
  $$H(\rho)-\frac{c\,g_t+2^{-m}\varepsilon}{c-2^{-m}}\ \le\ R(\pi)\ \le\ H(\rho)+c(\ell_H-\ell_{\rm fl})+\varepsilon;$$
* (iv) *it holds little information about the environment's coupling:* $I_\beta(\pi)\le(g_t+\varepsilon)/(c-2^{-m})+(\ell_H-K(h^*))+t+\kappa$;
* (v) *the human itself is near-optimal:* $J_c(\pi_H)\le\Phi(c)+g_t+(c-2^{-m})(\ell_H-\ell_{\rm fl})$.

Conversely,
* (vi) *the lower end $2^{-m}$ is sharp* (feature case). The *memoriser* $\pi_A$, which computes the deterministic $P^*$ from $h^*$ and the index of β in its type class, has $\ell(\pi_A)\le\ell_H+L_\beta+2\log(m+1)+t_0+\kappa$ and $R(\pi_A)=0$. So for
  $$c<\frac{H(\rho)}{L_\beta+2\log(m+1)+t_0+\kappa},$$
  a threshold at least $2^{-m}\big(1+(2\log(m+1)+t_0+\kappa)/(2^mH(\rho))\big)^{-1}$, the memoriser has $J_c(\pi_A)<J_c(\pi_H)$, and no copy of the human minimises $J_c$.

*Proof.* Population reading of `lem:kink:main` with $L=L'=R$, the reference point $(\ell_H,H(\rho))$ bounded by $\pi_H\in M_t$, $\mathcal M:=M_t$ with the right line $(\tau,g)=(2^{-m},g_t)$ and length floor $\ell_{\rm fl}$ of Lemma 4.5, and $\mathcal N:=$ the complement of $M_t$.
* By $(\mathrm L_{t,c,\varepsilon})$, every $\pi\in\mathcal N$ has $J_c(\pi)>J_{\rm r}(c)+\varepsilon$. Since $c>\tau$, `lem:kink:main`(ii) gives (i), (ii) and the left inequality of (iii) for every π with $J_c(\pi)\le\Phi(c)+\varepsilon$, as $\Phi(c)\le J_c(\pi_H)=J_{\rm r}(c)$.
* The right inequality of (iii): $c\,\ell(\pi)+R(\pi)\le J_c(\pi_H)+\varepsilon$ and $\ell(\pi)\ge\ell_{\rm fl}$ by (i) and Lemma 4.5(c).
* (iv) is Lemma 4.5(b) with (i) and (ii).
* (v) is `lem:kink:main`(i): $\eta_{\mathcal N}(c)\ge\varepsilon\ge0$, and $\Delta(c)=g_t+(c-2^{-m})(\ell_H-\ell_{\rm fl})\ge0$ because $\pi_H\in\mathcal M$ bounds the point.
* (vi) The memoriser reads $h^*$, $m$ (self-delimiting, $2\log(m+1)+\kappa$ bits) and a fixed-length index of β among the $2^{L_\beta}$ couplings of type ρ, which the program enumerates from $(\rho,m)$. So $\ell(\pi_A)\le K(h^*)+2\log(m+1)+\lceil L_\beta\rceil+\kappa$, and $K(h^*)\le\ell_H+t_0+\kappa$. Then $J_c(\pi_A)<J_c(\pi_H)$ iff $c(\ell(\pi_A)-\ell_H)<H(\rho)$, and $L_\beta\le2^mH(\rho)$ gives the stated form of the threshold. ∎

**What the theorem says, in the author's terms.** Aliens that model the environment around the human do predict better, by up to $H(\rho)$ bits per sample. Yet for every $c>2^{-m}$ at which the human's model is identifiable from near-optimal predictions (the left condition), every near-optimal hypothesis is the human's model with essentially fresh coins: it knows the model, it is at most a few bits longer than the human, it predicts no better than the human up to a slack, and it holds only a few bits about how the environment drives the human's coins. This holds robustly, against every program of the class. It concerns the near-optimal set, not a single program: as in Paper 2's `rem:teacher:selected`, the minimiser may be a nearby program (another coin law, a few memorised cells) that satisfies (i)–(iv). In the explicit classes of r2–r4 the human itself is the unique minimiser on the window.

**Corollary 4.7 (two instances where the left condition holds)** [proved].
* (a) *A coin-flipping human* [proved, new]. Let $h(x,b)=b$, so $Y=B$ and the human answers $y\sim\rho$ whatever its input; $h^*=(\rho,\mu(\cdot\mid\cdot))$. Since $K(h^*\mid\pi)\le K(h^*)+\kappa$ for every π, with $t:=K(h^*)+\kappa$ the set $M_t$ is the whole class and the left condition is vacuous. So (i)–(v) hold for **every** $c>2^{-m}$ and $\varepsilon\ge0$, with $g_t=(K(h^*)+\delta_\beta+|B|\log(2^m+1)+2\log(m+1)+\kappa)/2^m$, and (vi) bounds the window from below. This instance is unconditional, but its "model" is only a coin law.
* (b) *A parity human* [proved: Paper 2's `thm:teacher:main`]. In Paper 2's instance read as imitation, with $h^*$ described by $(d,m,a,p)$:
  * Level-1 programs have $K(a\mid\pi)\le s(1)+2\log d+\kappa$ (`lem:teacher:list`), so $K(h^*\mid\pi)\le t:=4+2\log d+2\log(d+1)+2\log(m+1)+K(p)+\kappa$.
  * Programs of level at least 2 have $J_c\ge\Phi_2(c)$ (`thm:teacher:main`(o), $B=\infty$).
  * So the left condition holds on $\{c>2^{-m}:J_g(c)+\varepsilon<\Phi_2(c)\}$, which contains $(2^{-m},c_{\rm hi})$ at $\varepsilon=0$.
  * Theorem C (`thm:teacher:main`(ii)) gives more: agreement $u(\pi)\ge\max\{\frac34,2^{-R_{\max}}-p\}$, and average probability on the environment-driven labels $e(\pi)\le1-u(\pi)+\gamma_g+2^{-g}$.
  * At Paper 2's sizes ($d=100$, $m=20$, $p=2^{-10}$) the window is $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ with the machine constant set to 0 (an illustration), and at $c=10^{-4}$ every near-optimal hypothesis gives the environment-driven labels average probability at most 0.200 (`tab:teacher:numbers`), against 1 for the memoriser alien.

**Corollary 4.8 (from samples)** [proved: Paper 2's `prop:recovery:beyond`(c) with Theorem 4.6]. With per-query data, $(x_i,y_i)$ i.i.d., any countable Kraft class containing $\pi_H$, and $c$ such that $(\mathrm L_{t,c,0})$ holds: almost surely, for all large $n$, every $cn$-MAP minimises $J_c$, and so satisfies (i)–(iv) of Theorem 4.6 with $\varepsilon=0$.

*Proof.* `prop:recovery:beyond`(c), applied with the true kernel $P^*$ as the sampler (its $R_\nu$ is $R$), puts every $cn$-MAP in $\arg\min J_c$ for all large $n$, almost surely. ∎

For finite $n$, the parity instance has explicit bounds (`prop:teacher:schedules`(c), `cor:teacher:sampled`, via `lem:teacher:finite`); for a general $h$ the same route needs a truncated form of Lemma 4.4, which we have not written out [open, expected routine].

[computed: r3, the explicit class of r2(A) with $(d_u,m,s_0)=(6,10,64)$ and population window $(9.50\cdot10^{-4},5.52\cdot10^{-2})$, 10 seeded runs, exact MAPs over the whole class:
* $c=7.2\cdot10^{-3}$ (inside the window): the human $H(a,p)$ in 9/10 runs at $n=1000$ and in 10/10 at every $n$ from $3000$ to $10^7$;
* $c=4.9\cdot10^{-4}$ (below): aliens memorising a growing number of cells (between 3 and 9 cells in nine runs at $n=100$, the tenth having no sample in $S$ yet; 35 to 43 cells at $n=1000$), and the full memoriser from $n=10^4$ on;
* $c=0.1$ (above): the coin at every $n$.]

[computed: r4(B), exact enumeration, the coin-flipping human with 16 cells, $|S|=2$, $p=1/8$; population window $(0.0544,0.1521)$. At the geometric middle $c=0.0909$, $\Pr[\text{the }cn\text{-MAP is the human}]=0.559,0.903,0.9955,1.0000$ at $n=16,64,256,1024$. Just inside the ends ($c=1.05s_+$, $0.95s_-$) convergence is slow: $0.816$ and $0.790$ at $n=1024$, with the rest on the memoriser and the coin respectively. Below the window ($c=0.03$) the memoriser has probability $1.0000$ from $n=256$; above ($c=0.25$) the coin does. At fixed λ = 2 the memoriser has probability $0.964$ at $n=64$.]

### 4.5 Necessary conditions and lower bounds

**Proposition 4.9 (what any procedure must give up, and when no window exists)** [proved; (a) is the argument of Paper 2's `prop:limits:noident`(iii) in this setting; (b) generalises `prop:teacher:schedules`; (c), (d) new].
* **(a) Robustness is blindness (twin worlds).** Let $W'$ be the world in which the human is a program π′ with kernel $P^*$ and private coins, so that its data are i.i.d. from $\mu\otimes P^*$. The data laws of $W$ and $W'$ coincide. Suppose $\nu_H\ne P^*$ on a set of positive μ-mass, as in the feature case. Then for every procedure Ψ (any measurable function of the data, randomised or not) and every $n$,
  $$\Pr_W\big[\Psi_n\in\mathcal E(\nu_H)\big]+\Pr_{W'}\big[\Psi_n\in\mathcal E(P^*)\big]\ \le\ 1.$$
  A procedure that copies the human of $W$ with probability at least $1-\epsilon$ copies the human of $W'$, a human who really does respond to the environment variable, with probability at most ε. The set of aliens a procedure is robust against is the set of humans it cannot copy.
* **(b) Schedules.** Let π be an alien with $r(\pi)>0$. If $\lambda_n/n\le c'<r(\pi)$ for all $n$ in an infinite set $N'$, then almost surely π beats every copy of the human at all but finitely many $n\in N'$. Let π be a shorter program with finite risk. If $\lambda_n/n\ge c''>(R(\pi)-R_H)/(\ell_H-\ell(\pi))$ on an infinite set $N''$, then almost surely π beats every copy of the human at all but finitely many $n\in N''$. If $\lambda_n/n\to\infty$, the $\lambda_n$-MAPs eventually have length at most $\ell_{\min}:=\min\{\ell(\pi):R(\pi)<\infty\}$. So a schedule keeps the human only if $\lambda_n/n$ eventually stays in $[s_+(H),s_-(H)]$.
* **(c) Cheap couplings defeat every c.** Suppose $K(\beta\mid h^*)\le k_\beta$, for example $\beta=G(\sigma)$ for a fixed computable generator $G$ and an $s$-bit seed σ, with $k_\beta\le s+K(G)+\kappa$. The program $\pi_A$ for $P^*$ built from $h^*$ and a shortest description of β given $h^*$ has
  $$\ell(\pi_A)\le\ell_H+k_\beta+t_0+\kappa,\qquad R(\pi_A)=H_W(Y\mid X),$$
  hence rate $r(\pi_A)\ge\big(H(\rho)-H_W(Y\mid X)\big)/(k_\beta+t_0+\kappa)$. The human's left steepness is at most that of the uniform predictor $\pi_{\rm u}$ (risk $\log|Y|$): $s_-(H)\le(\log|Y|-H(\rho))/(\ell_H-\ell(\pi_{\rm u}))$. So if
  $$\frac{H(\rho)-H_W(Y\mid X)}{k_\beta+t_0+\kappa}\ \ge\ \frac{\log|Y|-H(\rho)}{\ell_H-\ell(\pi_{\rm u})},$$
  no $c$ makes any copy of the human the unique minimiser of $J_c$ (Proposition 4.3). In the feature case $H_W(Y\mid X)=0$, and the condition says roughly that the seed is shorter than $H(\rho)\,\ell_H/(\log|Y|-H(\rho))$.
* **(d) A window needs many cells.** In the feature case, by Theorem 4.6(vi) and the bound on $s_-(H)$ in (c), a window exists only if
  $$\frac{H(\rho)}{L_\beta+2\log(m+1)+t_0+\kappa}<\frac{\log|Y|-H(\rho)}{\ell_H-\ell(\pi_{\rm u})},\quad\text{which implies}\quad 2^m>\frac{\ell_H-\ell(\pi_{\rm u})}{\log|Y|-H(\rho)}-\frac{2\log(m+1)+t_0+\kappa}{H(\rho)} .$$
  The environment's coupling must have more cells than the human's description has bits, per bit of the human's explanatory power.

*Proof.* (a) In both worlds the data are i.i.d. from $\mu\otimes P^*$: in $W$ because $P^*$ is by definition the law of $y$ given $x$; in $W'$ by construction. So $\Psi_n$ has the same law in both. The sets $\mathcal E(\nu_H)$ and $\mathcal E(P^*)$ are disjoint, because the kernels differ on a set of positive μ-mass.
(b) As in Proposition 4.2: for an alien, $\frac1n[J_{\lambda_n}(\pi_H)-J_{\lambda_n}(\pi)]\ge\hat R_n(\pi_H)-\hat R_n(\pi)-c'(\ell(\pi)-\ell_H)\to(\ell(\pi)-\ell_H)(r(\pi)-c')>0$ along $N'$, and every copy has the fits of $\pi_H$. The shorter program is symmetric. For $\lambda_n/n\to\infty$, the argument of `prop:teacher:schedules`(b): a program longer than $\ell_{\min}$ has $J\ge\lambda_n(\ell_{\min}+1)$, more than $J(\pi_0)=\lambda_n\ell_{\min}+n\hat R_n(\pi_0)$ once $\lambda_n>n\hat R_n(\pi_0)$.
(c) The program reads $h^*$ and a shortest program for β given $h^*$ and computes $P^*$ (finite sums over $w$). Its length is at most $K(h^*)+k_\beta+\kappa\le\ell_H+t_0+k_\beta+\kappa$. Its risk is $\Ex[-\log P^*(y\mid x)]=H_W(Y\mid X)$. If its rate is at least $s_-(H)$, no $c$ satisfies $s_+(H)<c<s_-(H)$.
(d) Combine the two bounds and $L_\beta\le2^mH(\rho)$. ∎

[computed: r2(B), the explicit class with $(d_u,m,s_0)=(6,10,64)$ and the coins given by an $s$-bit-seeded hash generator. The window is empty for $s\le12$ when $\ell_H=14$, for $s\le16$ when $\ell_H=24$, and for $s\le24$ when $\ell_H=40$; it exists for larger seeds. This matches the predicted thresholds $s>6+0.507(\ell_H-2)$, namely 12.1, 17.1 and 25.3. At $s=4$ the generator alien is shorter than the human and predicts better, so the human is never selected.]

[computed: r6(D), machine constants set to 0 (an illustration): a human of $10^6$ bits with $H(\rho)=0.5$ and explanatory power $\log|Y|-H(\rho)=0.5$ needs an incompressible coupling with $2^m>2.0\cdot10^6$ cells, or a coupling description longer than $10^6$ bits; at $10^{12}$ bits, $2^m>2.0\cdot10^{12}$.]

**Remark 4.10 (the explicit class: the window is exact, and its lower end is $2^{-m}(1-o(1))$)** [computed: r2(A)]. In an explicit prefix-coded class (coin; the human-type programs "parity $a$ on $d_u$ bits, flip rate $q$" for all $a$ and all $q\in\{j/64\}$; the S-cell aliens that declare a set $T$ of cells to carry coin 1, of length $\ell_H+\gamma(t)+\lceil\log\binom{2^m}t\rceil$), the population window, computed from the exact hull, is:

| $(d_u,m,s_0)$ | $\ell_H$ | $s_+$ | $s_+\cdot2^m$ | $s_-$ | ratio |
|---|---|---|---|---|---|
| (6, 8, 16) | 14 | $3.63\cdot10^{-3}$ | 0.929 | 0.0552 | 15.2 |
| (6, 10, 64) | 14 | $9.50\cdot10^{-4}$ | 0.973 | 0.0552 | 58.1 |
| (6, 12, 256) | 14 | $2.42\cdot10^{-4}$ | 0.991 | 0.0552 | 228 |
| (6, 14, 1024) | 14 | $6.09\cdot10^{-5}$ | 0.997 | 0.0552 | 907 |
| (6, 16, 4096) | 14 | $1.52\cdot10^{-5}$ | 0.999 | 0.0552 | 3622 |
| (20, 10, 64) | 28 | $9.50\cdot10^{-4}$ | 0.973 | 0.0255 | 26.8 |

* In every row the largest alien rate is attained by the full memoriser.
* The explicit right line of slope $2^{-m}$ holds with a *negative* offset: $\max_{\rm aliens}[2^m(R_H-R)-(\ell-\ell_H)]$ is between $-15$ and $-6$ bits. Lemma 4.5's machine-free part of the offset, $|B|\log(2^m+1)+2\log m$, is 22–40 bits; it is not tight here.
* The assertion "the human's point is a hull vertex iff $s_+<s_-$" was checked against the hull in every row.
* The hull of the (6, 10, 64) row has exactly three vertices: the coin, the human and the full memoriser, with edge slopes $5.52\cdot10^{-2}$ and $9.50\cdot10^{-4}$.

**Remark 4.11 (partially private coins; non-uniform cells)** [computed: r2(C); conjecture].
* *Partially private coins.* If the human's coin is $\beta(w)\oplus b'$ with a private residual $b'\sim\mathrm{Bern}(p')$, the human's flip rate is $p_h=s(1-p')+(1-s)p'$, $s=s_0/2^m$.
  * Lemma 4.4 still holds: average over $b'$ inside $q_w$; injectivity in $b$ for each fixed $b'$ suffices.
  * But the line of Lemma 4.5 is then anchored at $2^mH(s)<2^mH(p_h)$. Its offset at the human's point is $2^m(H(p_h)-H(s))$ bits, so it says nothing useful.
  * In the explicit class the lower end of the window falls below $2^{-m}$, to about the full-knowledge rate $2^{-m}(H(p_h)-H(p'))/H(s)$: $s_+2^m=0.764,0.660,0.795,0.537$ against $0.808,0.698,0.808,0.545$ in four instances.
  * *Conjecture:* in $\Hcl{\times}$ a right line of slope $2^{-m}(H(p_h)-H(p'))/H(s)$ holds, with an offset of order $m+\delta_\beta$. It would need a noisy-channel version of Lemma 4.4.
* *Non-uniform cell masses.* The proof of Lemma 4.4 gives $\sum_wr_w(\pi)$ (unweighted per-cell risks), so with non-uniform cells the slope is governed by the cell masses; the precise statement is open.

**Remark 4.12 (several environments: what is shared is kept, what varies is discarded)** [proved, new; elementary, from Lemma 4.5 and Theorem 4.6(vi); no computation].
* *Setting.* The human is observed in $E$ environments, equally often, with the environment's index part of the input. In world $W_E$ each environment $e$ has its own coupling $\beta_e$, and the tuple $(\beta_1,\dots,\beta_E)$ is incompressible given $h^*$. In world $W''$ the human itself carries one coupling β, the same in every environment, so its answers are $h(x,\beta(w))$ everywhere.
* *In $W_E$* the coupling variable is $(e,w)$, uniform on $E\,2^m$ cells. Lemma 4.5 applies with $2^m$ replaced by $E2^m$, so every alien's advantage per bit is at most about $2^{-m}/E$.
* *In $W''$* the coupling β lives on $2^m$ cells, and the program "$h^*$ plus β" beats the program for $h^*$ alone at every $c$ below about $2^{-m}$ (Theorem 4.6(vi)).
* *Consequence.* For $c\in\big(2^{-m}E^{-1}(1+o(1)),\,2^{-m}(1-o(1))\big)$ the $c$-procedure attributes a dependence on $w$ that varies across environments to the environment, and one that is shared across environments to the human. This is an invariance principle in the sense of learning from several environments.
* *What it does not remove.* The twin of $W_E$ in Proposition 4.9(a), a human who carries all $E$ couplings and selects one by the environment's index, has the same data law as $W_E$. So data from several environments do not make the choice data-driven. They make one choice, "what is the same across environments is the human", available to a rate threshold.

---

## 5. (d) A human with latent state

**Setting 5.0.**
* At step $i$ the environment chooses $x_i$, possibly depending on the past. The human, whose hidden state evolves with private randomness, answers $y_i$.
* $P_H(y_i\mid x_{\le i},y_{<i})$ is the human's *predictive law given the observable history*, the hidden state integrated out. It is not a product sampler.
* Hypotheses are chronological predictors: Paper 2's class $\Hcl{\mathrm{chr}}$, the hypotheses of Paper 1's history-aware SFI, or a subclass.
* *Episodes*: blocks of $T$ steps after which the human restarts from its initial law and the environment restarts independently.

**Proposition 5.1 (Ville survives)** [proved: Lemma 2.1]. With $\mathcal A_i:=\sigma(x_{\le i},y_{<i})$, (Priv) holds with $P_H$ in place of $\nu_H(\cdot\mid x_i)$, by the definition of $P_H$. So for every countable chronological class with Kraft weights, at every $n$:
* every program's gain over the human is at most its length plus δ*, with $\Pr[\delta^*\ge j]\le2^{-j}$;
* for fixed λ > 1 the λ-MAPs have length at most $(\lambda k+\delta^*)/(\lambda-1)$, with $k$ the length of a program for $P_H$.

If hypotheses could also see environment variables correlated with the human's hidden state, (Priv) could fail, and §4 would apply instead.

[computed: r5(A): a two-mood hidden Markov human, a class of 3375 hidden Markov programs, a Bayes mixture, 15 memoryless samplers and a coin; over 400 single trajectories of length 1500, $\Pr_{\rm emp}[\delta^*\ge j]=0.138,0.050,0.018,0.015,0.005$ for $j=1,2,3,4,6$.]

**Proposition 5.2 (an in-context learner absorbs a single trajectory)** [proved; in $\Hcl{\mathrm{chr}}$ it is Paper 2's `thm:split:shared`(i) with $U=\MH$; the finite-family form is new]. Let the class contain $\pi_H$ (length $\ell_H$, law $P_H$) and $\pi_U$ (length $\ell_U$) with $P_U\ge w\,P_H$ on every finite history, for example a Bayes mixture over a family of humans that gives the human weight $w$. Then for every λ > 0, every $n$ and every data,
$$J_\lambda(\pi_U)-J_\lambda(\pi_H)\ \le\ \lambda(\ell_U-\ell_H)+\log(1/w).$$
So if $\lambda(\ell_H-\ell_U)>\log(1/w)$, the human's program is never a λ-MAP, whatever $n$ and whatever the data.
* *Family coding.* If the human's program is "family code, then index", with $\ell_H=\ell_{\rm fam}+\ell_{\rm idx}$, $w=2^{-\ell_{\rm idx}}$ and $\ell_U=\ell_{\rm fam}+\kappa_U$, the condition is $(\lambda-1)\ell_{\rm idx}>\lambda\kappa_U$.
* *The universal class.* In $\Hcl{\mathrm{chr}}$ with $\pi_U$ a program for $\MH$, $w=2^{-\ell_H-\kappa}$, the condition is $(\lambda-1)\ell_H>\lambda\ell_U+\kappa$.
* *At λ = 1* the human's program is never ahead of the learner by more than $\kappa_U$ bits, at any $n$.

*Proof.* $P_U\ge wP_H$ gives $L(\pi_U)\le L(\pi_H)+\log(1/w)$; add $\lambda\ell$ to both. ∎

This is the formal form of "some completely alien system that just thinks about what the human would say". Once hypotheses carry information across queries, such a system is a single hypothesis. It pays its learning cost once and then predicts like the human, so it is shorter at almost no cost in fit. With private randomness per query it is not a single hypothesis of the class (`cor:absorb:nouniversal`); with labelled history it is (`prop:absorb:history`).

[computed: r5(B): human $\theta^*=(3/16,13/16)$, stay probability $15/16$; family of 3375 HMMs with 12-bit indices ($\ell_H=20$), learner of length 10, λ = 2. Over three trajectories of length 4000, $\max_n[J(U)-J(\theta^*)]=-9.00,-9.01,-9.00$, below the proved bound $-8$. $L(U)-L(\theta^*)$ reaches $11.0$ but not $12$, because the mirror image of $\theta^*$, the same HMM with the two moods relabelled, has the same law and doubles its weight in the mixture. The MAP is the learner at $n=1000$ and $n=4000$ in all three runs.]

**Proposition 5.3 (episodes restore Theorem A)** [proved, new; the proof is Theorem A's].
* *Setting.* Let the data be i.i.d. episodes. Each episode is a $T$-step interaction between an environment with a fixed law (inputs may depend on earlier steps of the episode) and the human, restarted from its initial law with fresh private randomness.
* *Class.* Countable, with Kraft weights, of *episodic* predictors: each restarts at episode boundaries, $P_\pi(\text{data})=\prod_eP^{\rm ep}_\pi(y^e\Vert x^e)$ with $P^{\rm ep}_\pi(y^e\Vert x^e):=\prod_{t\le T}q_\pi(y^e_t\mid x^e_{\le t},y^e_{<t})$, sub-probability conditionals.
* *Copies.* $\mathcal E^{\rm ep}$ is the set of programs whose conditionals equal $P_H$'s at almost every history, under the joint law of the human and the environment, at every $t\le T$. $\ell_0$ and $\mathcal E_0^{\rm ep}$ are as in `def:split:setting`.
* *Conclusion.* `thm:recovery:main`(a)–(d) hold with $n$ the number of episodes, the per-episode Hellinger gap, and the per-episode Chernoff coefficient. In particular, an episodic learner, a mixture over humans restarted at each episode, has expected per-episode regret $\KL^{\rm ep}(\pi_U)>0$ unless it is a copy, and it is a $\lambda_n$-MAP for only finitely many $n$, for every $1\le\lambda_n=o(n)$.

*Proof.* The per-episode ratios $Z_e(\pi):=P^{\rm ep}_\pi/P^{\rm ep}_H$ are i.i.d. across episodes. Within an episode the step ratios have conditional mean at most 1 given the past and the current input, so $\Ex Z_e\le1$ by the tower property. These are the facts `lem:recovery:ratios`(a),(d) use.
* For (c): $\KL^{\rm ep}(\pi):=-\Ex\log Z_e\in[0,\infty]$, and $\Ex(\log Z_e)^+\le\log e/e$.
* $\KL^{\rm ep}(\pi)=0$ iff $\pi\in\mathcal E^{\rm ep}$. If the KL is 0, Jensen's inequality forces $Z_e=1$ almost surely. The step products $M_t$ form a nonnegative supermartingale with $M_0=1$ and $M_T=1$ almost surely, so $\Ex M_t=1$ and, by backward induction, $M_t=1$ almost surely for every $t$. Each step ratio is then 1 almost surely, so $q_\pi(y\mid h)=P_H(y\mid h)$ wherever $P_H(y\mid h)>0$, and $\sum_yq_\pi\le1$ forces equality.
* The proof of `thm:recovery:main` (`app:recovery:main`) uses only these facts, the strong law across episodes, and $\Lambda_n=1$ on $\mathcal E^{\rm ep}$. ∎

[computed: r5(C): episodes of $T=20$ steps, λ = 2, 12 runs of 3000 episodes.
* The restarted learner's mean per-episode regret is $1.014$ bits (s.e. $0.008$), so the human should overtake it after about $2\cdot(20-10)/1.014\approx20$ episodes. It did after 13–35 episodes, and the learner was never ahead after episode 34.
* After 3000 episodes the λ-MAPs are exactly $\theta^*$ and its mirror image, tied to the last bit in all 12 runs: two shortest copies with different latent labellings, an instance of Proposition 3.1.]

**Remark 5.4 (what breaks without episodes)** [remark; open part marked].
* (1) *Product hypotheses* cannot represent the human ($\mathcal E=\emptyset$), and the answers are not i.i.d. given the inputs, so the misspecification results of `split/iid` §7.4, which assume i.i.d. pairs, do not apply as stated.
* (2) *Chronological hypotheses with a dominating member* absorb the human (Proposition 5.2), and so does SFI with history; with $\lambda=cn$ the absorption bound $\ell^*_\lambda$ tends to $\ell_U$.
* (3) *A single trajectory in a class without a dominating member*, such as hidden Markov programs with a bounded number of states: whether the $\lambda_n$-MAP converges to programs with the human's output-process law is **[open]**. For ergodic humans and finite classes we expect the answer yes, by analogy with the consistency of maximum likelihood for hidden Markov models (we have not checked that literature).

---

## 6. Interpretation: what the results show about imitation, and what they do not

### 6.1 What is shown, in toy settings

1. **The two cheap failure modes are handled, in toy form, by Paper 2's machinery.**
   * *Stored coins* ("the sampler with some bits specified") are excluded per query: for fixed λ > 1 their posterior mass is exponentially small in the sampled randomness at every $n$, and for every $1\le\lambda_n=o(n)$ the MAP is eventually an exact behavioural copy (Theorem 2.2, Remark 3.4).
   * *A learner that "just thinks about what the human would say"* is not a single hypothesis when randomness is private to each query (Remark 2.4) or to each episode (Proposition 5.3). It must then pay its learning cost on every query or episode, and it is rejected.
2. **With private coins the ideal theorem holds, for fixed λ > 1, against every program** (§2), in two senses. *Gain:* in every class, no program, however it is built and whatever it knows about the environment, beats the human by more than its own length plus δ* (Lemma 2.1). *Selection:* in the product class the selected program is eventually an exact behavioural copy (Theorem 2.2(3)); in a class that contains a learner dominating the human this second sense fails (Proposition 5.2). Here aliens never predict better in population; they can only get lucky on a sample, and luck is paid for in length.
3. **With environment-driven coins the ideal theorem holds in the author's strong form, for λ = cn in a window, against every alien whose advantage per bit is below c** (§4). Aliens do predict better, by up to $H(\rho)$ bits per sample. Yet in the window every near-optimal hypothesis is the human's model with essentially fresh coins: it holds only a few bits about how the environment drives the coins, whatever its internal structure. The robustness comes from an information bound (Lemma 4.5), not from listing aliens: each bit an alien knows about an incompressible coupling buys at most $2^{-m}$ bits of prediction per sample. Toy cases solved:
   * a coin-flipping human, unconditionally (Corollary 4.7(a));
   * a noisy-parity human, with flip rates below 0.05596 (Corollary 4.7(b), Paper 2's Theorem C);
   * explicit finite classes, exactly (r2–r4).
4. **The geometry is the teacher thread's.** Paper 2's teacher instance *is* an imitation instance: systematic errors are environment-driven coins. What differs is the reading, namely which structure we call "the environment" and which "the human". The lower end $2^{-m}$ of the window is the reuse factor in both.

### 6.2 What is not shown; the problems that remain

1. **Mechanism.** Identification is behavioural (Proposition 3.1). The selected program is a shortest program for the human's law *in the class*. It may compute that law in a way nothing like the human's (Example 3.2), and off the support of the inputs it behaves as the shortest program does, not as the human does. A copy in a mechanistic sense needs data about the mechanism (internal observables, interventions) or a class restricted to human-like architectures (Proposition 3.3). Neither is in these toys, and the second assumes what we would want to learn.
2. **The choice of $c$ is a judgment that the data cannot make** (Proposition 4.9(a)). Being robust against an alien is the same as being unable to copy a human who behaves like that alien. A $c$-procedure declares every structure with rate below $c$ to be "environment" and every structure above $c$ to be "human". It therefore also discards rare, costly-to-describe idiosyncrasies of the human (as in `prop:limits:separable`), and it keeps every environment influence that is cheap enough.
3. **Cheap or pseudo-random couplings defeat it** (Proposition 4.9(c)). If the human's apparent randomness has a short description (a pseudo-random generator with a short seed, a simple environmental feature, a deterministic brain with a short initial condition), aliens have a high rate and no $c$ works. The positive results need the environment's influence to be incompressible and spread over more cells than the human's description has bits per bit of explanatory power (Proposition 4.9(d)). Whether real human "noise" is like that is an empirical question these results do not touch.
4. **Identifiability of the human's model from good predictions** (the left condition of Theorem 4.6). It is proved for parities and trivial for a coin-flipping human, and open for other families of human models (Paper 2's `q:teacher:open`(a)).
5. **Residual private noise and non-uniform environments** are understood only in explicit classes (Remark 4.11).
6. **Memory.** Real humans have state. The positive results need episodes with resets (Proposition 5.3). On one long history, a class rich enough to contain a learner lets that learner absorb the human (Proposition 5.2).
7. **The data object.** Exact behavioural copies need per-query answers: the same question asked again, answered afresh. With frozen answers, partial fill-ins persist (Remark 3.4), and no procedure identifies the human's randomness at a repeated input (`prop:recovery:frozen`).
8. **Uncomputability and constants.** $\Hcl{\times}$, the λ-MAP and the power posterior are not computable. The windows depend on the machine constant: Paper 2's example window is $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ at $\kappa=0$ and $(9.54\cdot10^{-7},3.65\cdot10^{-3}]$ at $\kappa=30$. Computable classes keep the statements with their own constants (`prop:related:computable`). The choice of hypothesis class and of reference machine decides which programs are short, and so which program counts as "the" copy.
9. **What "the human" is.** The copy in §4 has fresh coins. It reproduces the human's behaviour averaged over the environment's influence, not the human's correlation with the environment. Whether that is "the human" is a philosophical question. Proposition 4.9(a) shows that imitation data alone cannot settle it.

---

## 7. What is new, and what is reused from Paper 2

| result here | relation to Paper 2 and the split records |
|---|---|
| Lemma 2.1 (Ville with side information) | `lem:split:ville`'s argument with a larger filtration; the statement, robustness against predictors that see any environment variables independent of the coins, is new |
| Theorem 2.2 | (1) = `thm:split:private`(i)–(iii), (3) = `thm:recovery:main`, (4) = `thm:split:private`(iv), each with Lemma 2.1; (2) and the imitation reading are new and elementary |
| Proposition 2.3 (privacy dichotomy) | new; elementary (Lemma 2.1 and the strong law) |
| Remark 2.4 (two halves; learners) | new reading of `cor:absorb:nouniversal` and `prop:absorb:history` |
| Proposition 3.1, Example 3.2, Proposition 3.3 | new; elementary; (3.1(b)) is the twin-world argument of `prop:limits:noident`(iii) |
| Remark 3.4 | `prop:recovery:frozen`(c) and `thm:recovery:main`(a); the per-query bound and the simulation are new |
| Setting 4.1 | new; contains `def:teacher:instance` as the feature case with a parity |
| Proposition 4.2 | (a) new, elementary; (b) = `thm:recovery:main` with $P^*$; cf. `prop:teacher:schedules`(a) |
| Proposition 4.3 | `lem:setup:hull`(iii) in the population reading; the rate reading for imitation is new |
| Lemma 4.4 | generalises `lem:teacher:coding` (parities, binary coins, uniform inputs) to any response function, coin set, latent-cause input mechanism; same proof |
| Lemma 4.5 | generalises (D2) of `lem:teacher:twopart`, with $K(h^*\mid\pi)$ in place of list decoding; same proof |
| Theorem 4.6 | `lem:kink:main` with Lemma 4.5 as the right side; new in this generality. (vi) generalises `thm:teacher:main`(iv) |
| Corollary 4.7 | (a) new; (b) = `thm:teacher:main` read as imitation |
| Corollary 4.8 | `prop:recovery:beyond`(c) + Theorem 4.6 |
| Proposition 4.9 | (a) = the argument of `prop:limits:noident`(iii); (b) generalises `prop:teacher:schedules`(a),(b); (c) is a new form of rate blindness (`prop:limits:rateblind`) for couplings with short descriptions; (d) new |
| Remarks 4.10, 4.11 | new computations |
| Proposition 5.1 | Lemma 2.1 |
| Proposition 5.2 | `thm:split:shared`(i) with $U=\MH$; the finite-family form is new and elementary |
| Proposition 5.3 | new; its proof is `thm:recovery:main`'s with episodes as queries |

Nothing in this record changes a statement of Paper 2.

---

## 8. Open questions

1. **Residual private noise.** In $\Hcl{\times}$, does a right line of slope $2^{-m}(H(p_h)-H(p'))/H(s)$, with an offset of order $m+\delta_\beta$, hold when the human's coin is $\beta(w)\oplus b'$ with private $b'$ (Remark 4.11)? This needs a noisy-channel form of Lemma 4.4.
2. **Non-uniform environments.** What replaces the slope $2^{-m}$ when the cells have unequal masses? We expect the largest cell mass, possibly up to logarithmic factors.
3. **Other human models.** For which families of response functions does the left condition of Theorem 4.6 hold, that is, is the human's model decodable from near-optimal predictions? This is Paper 2's `q:teacher:open`(a) in imitation form.
4. **Finite samples for general $h$.** A truncated Lemma 4.4, as in `lem:teacher:coding` with finite $B$, together with `lem:teacher:finite`, should give Corollary 4.8 at each $n$ with probability $1-\delta$. Expected routine; not written out.
5. **A single trajectory without a dominating member** (Remark 5.4(3)).
6. **Computational depth.** Lemmas 4.4–4.5 use unbounded Kolmogorov complexity, so a generator with a short seed is a cheap coupling (Proposition 4.9(c)). In a time-bounded class, an alien must also *run* the generator. Does a coupling that is short to describe but slow to compute act as private randomness for a time-bounded class, giving a computational form of robustness?
7. **Choosing $c$ from data other than imitation data.** Data from several environments make the invariance choice of Remark 4.12 available. Do interventions that move the human between environments, or other non-imitation data, ever *identify* which structure belongs to the human?

---

## 9. Claims and statuses

| # | claim | status |
|---|---|---|
| 2.1 | Ville deficiency with side information: under (Priv), every predictor's gain over the human is at most its length + δ*, $\Pr[\delta^*\ge j]\le2^{-j}$ | proved; computed r1(A), r5(A) |
| 2.2(1) | fixed λ > 1, every $n$, any input rule: length bound, fit bounds, posterior tail, fill-in mass | proved (Paper 2 + Lemma 2.1) |
| 2.2(2) | under (Priv) no product hypothesis on $(x,z)$ predicts better than the human in population | proved |
| 2.2(3) | per query, product class on $(x,z)$: Theorem A for the human | proved (Paper 2) |
| 2.2(4) | any predictors, every λ ≥ 1: eventually $\nu_H$-equivalent on the run | proved (Paper 2's argument) |
| 2.3 | privacy dichotomy: bounded gains iff $I(Y;Z\mid X)=0$ (given a class with the exploiting program) | proved; computed r1(B) |
| (a)-brief | "with fixed λ > 1 the selected programs are eventually equivalent in law to the sampler, robust against all programs whatever their structure" | proved for product classes (2.2(3)); **refuted** for classes that contain an in-context learner dominating the human (Proposition 5.2; r5(B)) |
| 2.4 | robustness has two halves; learners violate the second | remark (from proved results); computed r1(C) |
| 3.1 | only the kernel on supp μ and the set $\mathcal E_0$ are identified; no procedure separates equivalent programs | proved |
| 3.2 | an equivalent, shorter alien is selected at every $n$ and λ; off-support behaviour is the alien's | computed r4(A) |
| 3.3 | mechanism observables, interventions, off-support queries or a restricted class separate equivalent programs; more data, schedules and length priors do not | proved |
| 3.4 | partial fill-ins: excluded per query ($\le10((9/10+1/640)^n-(9/10)^n)$), persist with frozen answers ($0.1457$) | proved (Paper 2 + new bound); computed r4(C) |
| 4.2 | fixed λ and every $\lambda_n=o(n)$ eventually select an alien | proved; computed r3 |
| 4.3 | the human is the unique $J_c$-minimiser iff $s_+(H)<c<s_-(H)$ (and no tie at its point); selection depends on aliens only through their rate | proved (hull lemma); computed r2(A) |
| 4.4 | alien coding lemma $K(\beta\mid h^*,\pi)\le2^mR(\pi)+2\log(m+1)+\kappa$ | proved; computed r6(A) (its semimeasure and Jensen steps) |
| 4.5 | right line of slope $2^{-m}$ on programs that know the human's model; information bound; length floor | proved; computed r2(A) (explicit class: offset $\le0$), r6(B) |
| 4.6(i)–(v) | in the window, under the left condition, near-optimal programs know the human's model, are short, fit like the human, hold little information about β | proved |
| 4.6(vi) | the lower end $2^{-m}$ is sharp up to $1+O((\log m+\kappa)/(2^mH(\rho)))$ | proved; computed r2(A), r6(C) |
| 4.6-strong | "the human's own program is the unique minimiser on the whole window" | **refuted** in general (Paper 2's `rem:teacher:selected`: nearby rates take over on part of the window in explicit rate codes); true in the explicit classes of r2–r4; not claimed in $\Hcl{\times}$ |
| 4.7(a) | coin-flipping human: Theorem 4.6 holds for every $c>2^{-m}$, unconditionally | proved |
| 4.7(b) | parity human: Theorem C of Paper 2 is a robust imitation theorem | proved (Paper 2) |
| 4.8 | from samples: eventually every $cn$-MAP satisfies Theorem 4.6 with ε = 0 | proved; computed r3, r4(B) |
| 4.8-finite | the same at each $n$ with probability $1-\delta$ for general $h$ | open (expected routine); proved for the parity instance in Paper 2 |
| 4.9(a) | robustness is blindness: $\Pr_W[\text{copy}]+\Pr_{W'}[\text{copy}]\le1$ for every procedure | proved; illustrated r4(B) |
| 4.9(b) | a schedule keeps the human only if $\lambda_n/n$ stays in $[s_+,s_-]$ | proved; computed r3 |
| 4.9(c) | couplings with short descriptions (PRG seeds) defeat every $c$ once the seed is short relative to $H(\rho)\ell_H/(\log|Y|-H(\rho))$ | proved; computed r2(B) |
| 4.9(d) | a window needs $2^m\gtrsim(\ell_H-\ell_{\rm u})/(\log|Y|-H(\rho))$ cells | proved; computed r6(D) |
| 4.10 | explicit class: exact windows; lower end $2^{-m}\cdot(0.93\text{–}0.999)$; the full memoriser attains $s_+$ | computed r2(A) |
| 4.11 | residual private noise: Lemma 4.5's line is then useless; the explicit window's lower end is near $2^{-m}(H(p_h)-H(p'))/H(s)$ | proved (first part); computed r2(C); a line of that slope in $\Hcl{\times}$ is a conjecture |
| 4.12 | several environments: shared dependence is kept, environment-specific dependence discarded, for $c$ in $(2^{-m}/E,2^{-m})$ up to $1\pm o(1)$; the twin obstruction persists | proved (elementary) |
| 5.1 | Ville's bound survives for chronological classes | proved; computed r5(A) |
| 5.2 | an in-context learner beats the human's program at every $n$ once $\lambda(\ell_H-\ell_U)>\log(1/w)$ | proved; computed r5(B) |
| 5.3 | episodes restore Theorem A; the restarted learner pays its regret every episode | proved; computed r5(C) |
| 5.4(3) | single trajectory, class without a dominating member | open |

---

## References

* **Paper 2** (`paper-steeper/sections/`), by label: `def:setup:data`, `def:setup:class`, `def:setup:objectives`, `lem:setup:hull`, `rem:setup:persample`, `cor:absorb:nouniversal`, `prop:absorb:history`, `thm:split:shared`, `def:kink:kinks`, `lem:kink:main`, `lem:kink:secant`, `def:split:setting`, `lem:split:ville`, `thm:recovery:main`, `lem:recovery:ratios`, `thm:split:private`, `prop:recovery:frozen`, `prop:recovery:beyond`, `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main`, `rem:teacher:selected`, `tab:teacher:numbers`, `prop:teacher:schedules`, `cor:teacher:sampled`, `lem:teacher:finite`, `prop:limits:separable`, `prop:limits:noident`, `prop:limits:rateblind`, `prop:related:computable`, `q:teacher:open`; the facts (F1)–(F5) of `app:setup:facts`.
* `research/tracks/split/notes-final.md` and `split/iid/notes-final.md` (§7.4 for misspecification).
* J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars, 1939 (as cited by Paper 2).
* S. Kakutani, "On equivalence of infinite product measures", *Ann. Math.* 49:214–224, 1948 (as cited by Paper 2; used through `lem:recovery:ratios`(b)).
* T. M. Cover, J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley, 2006: the type-class bounds $(n+1)^{-|B|}2^{nH}\le|T(P)|\le2^{nH}$ (the theorem number was not re-checked; r6(B) checks the inequality numerically, and Paper 2's `def:teacher:instance` cites the binary case to the same book).
* No new literature was used. The remark on maximum-likelihood consistency for hidden Markov models (Remark 5.4(3)) is an analogy, not a citation; it was not checked.

---

## Verification log

*Run 2026-10-14 with Python 3.11.15 and NumPy 2.4.6. Every script lives in `checks/`, and each output is the `.out` file of the same name. Each script is deterministic or seeded with its own `numpy.random.default_rng` seed, named in its docstring.*

**What each script checks.**
* **r1_side_info_ville** (seed 1; 5 s). Lemma 2.1, Proposition 2.3, Remark 2.4.
  * (A) World A, private coins: 3000 runs of $n=2000$. The class has Kraft sum 0.125: the human, six aliens that use a 10-valued environment variable, a random 80-cell rate table, and a history-aware Krichevsky–Trofimov learner. Results: the empirical tail of δ* against $2^{-j}$; 0 runs in which a program's gain exceeded its length plus δ*; the per-program sup of gain minus length.
  * (B) World B, coins a calibrated deterministic function of the environment: $I(Y;Z\mid X)=0.8272$, the oracle alien's gain against $nI$, and the first $n$ at which it beats the human at λ = 2 and 4.
  * (C) The learner's regret against the human, $7.7$ to $274$ bits.
* **r2_window_exact** (deterministic, except the PRG seeds in (B), seed 2; 1 s). Proposition 4.3, Lemma 4.5, Theorem 4.6(vi), Proposition 4.9(c), Remarks 4.10, 4.11.
  * The explicit prefix-coded class (Kraft sum at most 1 by its 2-bit tags and the Elias-gamma code of $t$); exact population hulls by monotone chain; the window $(s_+,s_-)$.
  * An internal assertion that the human's point is a hull vertex iff $s_+<s_-$, in every row of (A).
  * (A) Random couplings, nine parameter sets. (B) Generator couplings with seeds of 4 to 128 bits and $\ell_H\in\{14,24,40\}$. (C) Partially private coins, four instances.
* **r3_window_samples** (seed 3; 7 s). Proposition 4.2, Corollary 4.8, Proposition 4.9(b).
  * Exact λ-MAPs over the whole explicit class of r2(A) at $(d_u,m,s_0)=(6,10,64)$, at 11 checkpoints up to $n=10^7$, for six schedules and 10 runs.
  * Exactness rests on two facts, both in the docstring: for fixed (parity, $t$) the best $T$ is the $t$ eligible cells with the most samples; and the best rate is a grid minimum over the remaining disagreements.
* **r4_nonident_exact** (A: seed 41; B: exact enumeration; C: exact formula plus seed 43; 34 s). Proposition 3.1, Example 3.2, Corollary 4.8, Proposition 4.9(a), Remark 3.4.
  * (A) Asserts exact equality of the two fits at four sample sizes.
  * (B) Enumerates all sorted count vectors of the two coupled cells, with their multiplicities. The reported probabilities sum to 1.000000 in every row that prints a total (the c-schedules).
  * (C) Recomputes Paper 2's frozen value $0.1457$, the per-query bound, and a 20,000-run simulation.
* **r5_latent_state** (seed 5; about 7 min). Propositions 5.1–5.3.
  * A two-mood hidden Markov human; 3375 family members with exact forward-algorithm likelihoods; the Bayes mixture; memoryless samplers; a coin; Kraft sum 0.258.
  * (A) The Ville tail on 400 single trajectories.
  * (B) Three trajectories of length 4000 at λ = 2, checking $\max_n[J(U)-J(\theta^*)]\le-8$; observed $-9.00$.
  * (C) 12 runs of 3000 episodes of length 20. The tie between $\theta^*$ and its mirror image is reported to machine precision ($0.0$).
* **r6_coding_lemma** (seed 6 in (A); (B)–(D) deterministic; 2 s). Lemma 4.4, Lemma 4.5, Theorem 4.6(vi), Proposition 4.9(c),(d).
  * (A) The semimeasure property of $q_w$ and $Q$ (exhaustive over the $3^8$ couplings for 40 programs) and the Jensen step (600 programs).
  * (B) The type-class bounds for five laws and $m\le20$.
  * (C) The memoriser's rate times $2^m$.
  * (D) The rate-separation arithmetic.

**Reproducibility.** All six scripts were copied to a scratch directory and re-run with `python3 -I`. stderr was empty for all six. Outputs:
* r1 (5 s), r2 (1 s), r3 (7 s) and r4 (34 s) are byte-identical to the saved outputs;
* r5 (387 s) is byte-identical to the saved output;
* r6 is byte-identical to the saved output.

After that re-run the docstrings of r2 (its seed description) and r6 (a section reference) were corrected; both were run again, and their outputs are byte-identical to the saved ones.

**A rare event, checked.** In r3 one run shows the deterministic parity ($q=0$) as the MAP at $n=100$. That requires no sample in the 64 coupled cells among the first 100, which has probability $(15/16)^{100}=0.0016$ per run. A separate scratch computation with the same seed confirmed that run 3 has 0 such samples among its first 100 (and 7 among its first 300); the other nine runs have 3 to 10.

**Proof checks done for this record.**
* *Lemma 2.1.* The measurability of $M_n$ with respect to $\mathcal A_{n+1}$ and the monotone-convergence interchange were checked. The human need not be in the class: only $\nu_H(y_i\mid x_i)>0$ almost surely is used.
* *Theorem 2.2(4).* The two ingredients of `thm:split:private`(iv) were re-derived for $\mathcal A$-measurable predictors: the tail supermartingale, and the Hellinger martingale with $g_{n+1}$ fixed before $y_{n+1}$. The confinement step was re-derived for λ ≥ 1.
* *Proposition 2.3(b).* The integrability of both parts of $D_i$ was checked.
* *Lemma 4.4.* Injectivity is used only for $\sum_bq_w(b)\le1$. The finite support of $\mu(\cdot\mid w)$ is used for lower semicomputability. The step from $(\pi,h^*,m)$ to $(\pi,h^*)$ costs $K(m)\le2\log(m+1)+\kappa$.
* *Lemma 4.5.* The chain (F4), (F3), (F1) was re-derived. $B_\beta$ is defined with $K(h^*)$ in the condition so that (F4) is used in its exact form.
* *Theorem 4.6.* Each hypothesis of `lem:kink:main`(i),(ii) was matched:
  * the reference point is bounded by $\pi_H\in M_t$;
  * $c>\tau=2^{-m}$;
  * $\eta_{\mathcal N}(c)\ge\varepsilon$ from the left condition;
  * $\Delta(c)\ge0$ since $\pi_H\in\mathcal M$;
  * (vi): the memoriser's code and the lower bound $\ell_H\ge K(h^*)-t_0-\kappa$.
* *Corollary 4.7(b).* $K(h^*\mid\pi)$ for level-1 programs combines `lem:teacher:list` with the costs of $d$, $m$ and $p$. The complement of $M_t$ consists of programs of level at least 2, which `thm:teacher:main`(o) bounds by $\Phi_2$.
* *Proposition 4.9(d).* The algebra from the two rates to the bound on $2^m$ was redone by hand.
* *Proposition 5.3.* The step "KL = 0 implies equal conditionals" was re-derived through the backward induction on the supermartingale $M_t$ with $M_T=1$.
* *Not checked independently.* No referee has read this record. The proofs that are assemblies of Paper 2's lemmas inherit Paper 2's verification status.
