# Track "imitation", sub-track "decay": λ = cn and weight decay (target I2), final record

*Brief: `../00-brief.md`, target I2: make precise the author's first bullet, that λ = cn is not Bayesian learning with a fixed prior as the sample size varies, much as weight decay keeps acting at every step and can keep preferring a simpler hypothesis that is worse at classification even in the limit. This is the final record of the sub-track, written 2026-10-14 after the referee report `referee.md`. It replaces `notes.md` (kept unchanged) and is self-contained: every result of `notes.md` is restated here, corrected where the referee found a fault, and the refuted statements are kept as refuted.*

* **Sources read.**
  * The brief, in full, including the author's message.
  * `notes.md`, `refs.bib` and `referee.md` of this folder, in full; the referee's script `referee-checks/rd1_referee.py` and its output.
  * Paper 2 (`paper-steeper/sections/`):
    * `teacher.tex` in full (`rem:teacher:hanni`, `lem:teacher:reuse`, `prop:teacher:schedules`, `rem:limits:schedule`, `thm:teacher:main`, `rem:teacher:numbers`, `tab:teacher:numbers`);
    * `setup.tex` at `lem:setup:hull`, `lem:setup:basic`, `lem:setup:coding`, `rem:setup:persample` and the definition of the canonical classes;
    * `recovery.tex` at `def:split:setting`; `app-recovery.tex` at `lem:recovery:ratios` and `prop:recovery:beyond`;
    * `parity.tex` at `def:teacher:instance` (the constants $L_S$, $B_S$, $\delta_S$, $\kappa_g$, $\kappa_b$, $\Lambda_1$);
    * `limits.tex` at `prop:limits:separable`; `related.tex` at the paragraph on generalised posteriors (`rem:related:cold`);
    * `main.tex`, `build.sh` and `merge_bib.py`, for the scratch build.
  * The split synthesis `research/tracks/split/notes-final.md`, as read for `notes.md` (§0–§4 in full).
* **Scripts** (in `checks/`; Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1; deterministic or seeded; each output saved next to its script):
  * `d1_no_fixed_prior.py` → `d1_no_fixed_prior.out` (from `notes.md`, unchanged): parts (A) duplication, (B) the two-program example, (C) per-query simulation, (D) the tempered posterior, (E) the recursion.
  * `d2_weight_decay.py` → `d2_weight_decay.out` (from `notes.md`, unchanged): parts (A) the logistic toy, (B) empirical minimisers, (C) SGD, (D) AdamW against L2, (E) per-step effects.
  * `d3_revision.py` → `d3_revision.out` (new in this revision, 6 s): parts (A) summable against non-summable priors, (B) which fixed priors reproduce the cn-MAPs, (C) the teacher-window threshold $c_+$, (D) the AdamW box threshold, the L2 switch condition and AdamW runs, (E) kinks for weight decay, (F) error rates, (G) schedules at a breakpoint of the hull.
  * The referee's `referee-checks/rd1_referee.py` is cited as rd1 where it is the source of a number.
* **Status tags.**
  * **[proved]**: full proof here, or a one-line derivation from a cited proved result of Paper 2.
  * **[computed: dN(k)]**: checked by script dN, part (k).
  * **[known: ref]**: published. "Abstract level" means checked against the abstract as returned by a web search. "Body, via search excerpt" means a sentence of the paper body (or poster) that a search returned, often paraphrased; the paper was not read in full.
  * **[remark]**, **[heuristic]**, **[open]**: as named.
  * **[refuted]**: shown false; the statement is kept with its counterexample.
* **Conventions.**
  * $\log=\log_2$ and $\ln$ is natural. Code lengths and fits are in bits; network losses are in nats.
  * Notation follows Paper 2:
    * $h_n$ is a per-query (PQ) sample;
    * $L(\pi;h)=-\log\nu_\pi(h)$, $J_\lambda=\lambda\ell+L$, $\hat R_n(\pi)=L(\pi;h_n)/n$;
    * $R_\nu(\pi)=H_\mu(\nu)+\KL_\mu(\pi)$, $J_c=c\,\ell+R_\nu$, $A_c=\arg\min J_c$;
    * $\mathcal E$ (programs whose kernel is $\nu$ at μ-a.e. input), $\ell_0=\min_{\mathcal E}\ell$, $\mathcal E_0$ (the programs of $\mathcal E$ of length $\ell_0$), as in `def:split:setting`;
    * $c^*:=\min\{\KL_\mu(\pi)/(\ell_0-\ell(\pi)):\ell(\pi)<\ell_0\}$ ($\infty$ if no program is shorter than $\ell_0$), as in `prop:recovery:beyond`;
    * $\Lambda_n(\pi)=\nu_\pi(h_n)/\nu(h_n)$.
  * The weight-decay coefficient is written ω, so that λ keeps its meaning. The AdamW decay coefficient is written λ_W where both appear.
* **Reading of the author's bullet** [remark].
  * "There not being a correspondence to Bayesian learning as the number of params varies" is read, as the brief reads it, as: λ = cn is not Bayesian learning with any fixed prior as the sample size $n$ varies. This fits "weight decay just keeps going on each step".
  * If "params" meant the number of model parameters, the conclusion is the same. In the summed objective, λ = cn charges $cn$ bits per bit of program, and weight decay charges $\frac{n\omega}2\theta_j^2$ for each parameter $\theta_j$. In both the charge per unit of model grows with $n$, so neither is a fixed prior over models of any size once its coefficient is held fixed per sample.
  * This is a point to confirm with the author (§8, item 5).
* **Repository.** No git command was run. Files written in this revision: this record, `checks/d3_revision.py` and `checks/d3_revision.out`. `notes.md` and `refs.bib` are unchanged. The draft LaTeX of §6 was compiled only in a scratch copy of Paper 2 in the session scratchpad.

---

## 0. Summary

1. **λ = cn is a per-sample penalty** [proved; from `rem:setup:persample`, `prop:recovery:beyond`].
   * $J_{cn}(\pi;h_n)/n=c\,\ell(\pi)+\hat R_n(\pi)\to c\,\ell(\pi)+R_\nu(\pi)$, and the $cn$-MAPs end in $A_c=\arg\min J_c$.
   * The power-prior weight is $\prod_{i\le n}2^{-c\ell(\pi)}\nu_\pi(y_i\mid x_i)$, so each sample brings the prior factor again. This is the exact form of "it keeps going on each step" (§1).
2. **No fixed prior with full support gives the $cn$-MAPs** (§2).
   * *Duplication* [proved; computed: d1(A), d3(G)]. The $cn$-MAPs depend on the sample only through its empirical distribution. Under a fixed prior with full support, a program that fits a sample worse than another stops being a MAP once the sample is repeated often enough. In $\Hcl{\times}$, for every $c>0$, there are samples whose $cn$-MAPs all fit worse than some program, so the two rules disagree on their repetitions.
   * *Full support is needed* [proved; computed: d3(B1); referee A4]. In the class {coin, deterministic $f$} with $ck>1$, the prior concentrated on the coin reproduces the $cn$-MAPs on every sample. In $\Hcl{\times}$, for some reference machines and every $c>\log|Y|$, a degenerate prior does too (Remark 2.8).
   * *No fixed prior at all, in some classes* [proved; computed: d3(B2); new]. If the program of maximal likelihood on a bad sample is itself a $cn$-MAP of another sample, every fixed prior fails (Prop 2.2(v)). In a class of two Bernoulli rates (1/2 and 1/4) this holds for every $0<ck<\log\frac32$; at $ck=0.3$ no fixed prior reproduces the $cn$-MAPs even on the samples of size at most 4.
   * *Summable priors* [proved; computed: d3(A); new]. A summable prior with $w(\pi^*)>0$ ends at maximum likelihood on a repeated sample. A full-support non-summable prior need not: Example 2.7 gives one whose MAPs exist at every $r$ and never attain the maximum likelihood.
   * *Per query* [proved; computed: d1(C)]:
     * for $c>c^*$, the $cn$-MAPs eventually leave $\mathcal E$, while the MAPs of every summable prior that charges $\mathcal E$ end in $\mathcal E$;
     * for $c<c^*$, both end in $\mathcal E_0$ (with the prior $2^{-\ell}$);
     * a prior that does not charge $\mathcal E$ can agree with the $cn$-MAPs eventually (Remark 2.8(b)).
   * A fixed λ is the fixed prior $2^{-\lambda\ell}$.
3. **The limit can keep a simpler, worse hypothesis** (§3) [proved].
   * For $c>c^*$ every eventual $cn$-MAP is shorter than $\ell_0$ and has larger risk.
   * Two-program example [proved; computed: d1(B)]: a coin of length 1 against a deterministic $f$ of length $1+k$. For $ck>1$ the coin is the $cn$-MAP at every $n$; its error rate on $f$-labelled data is 1/2. Every fixed λ switches to $f$ after $\lambda k$ samples.
   * The teacher window of Paper 2 is an instance, now with $c>c^*$ proved on the window except in a band of relative width at most 1.2 % above $2^{-m}$ at the example's sizes [proved; computed: d3(C); referee A1].
4. **Weight decay** (§4).
   * With the loss averaged over $n$ samples, SGD with coupled weight decay ω descends $\hat L_n+\frac\omega2\|\theta\|^2$. That is MAP under $\mathcal N(0,(n\omega)^{-1}I)$, a prior whose precision grows linearly in $n$ [proved]. A fixed prior needs $\omega_n=\tau/n$.
   * The population minimiser minimises $L$ only if $0$ does [proved].
   * In a two-feature logistic toy it classifies worse [proved; computed: d2(A)–(C), d3(D)]:
     * the L2-regularised limit has error rate $q$ for $\omega\ge\omega^*$ and 0 below, if and only if $\varepsilon^2<1-2q$; otherwise it has error 0 at every ω;
     * at ε = 0.1, q = 0.2: $\omega^*=2.101\cdot10^{-3}$; ω = 0.01 gives error 0.2 in all of 20 samples at every $n$ from $10^2$ to $10^6$, and ω = 1/n gives 0 in all of 20 from $n=10^3$ on;
     * for ε ≤ 1 the AdamW limit (an ℓ∞ box) has error $q$ exactly when $\lambda_W\ge2\varepsilon/\ln((2-3q)/q)$, also when L2 never switches.
5. **What is not analogous** (§4.4):
   * $\|\theta\|^2$ is not a description length;
   * for differentiable $L$ no point $\theta\ne0$ is selected on an interval of ω, unlike a hull vertex (§4.2);
   * SGD iterates are not minimisers;
   * decoupled weight decay is a different objective;
   * per-step decay makes the effect before convergence depend on η·T, and in SGDW-style updates the effective coefficient depends on the learning rate;
   * in deep networks explicit regularisation, weight decay included, does not stop the fitting of random labels.
6. **Literature** (§5): 15 new sources and the 10 already in Paper 2, verified by WebSearch with bibliographic data (by the author of `notes.md` and again by the referee). Four statements that went beyond the abstracts are retagged (L1–L4). None of them is in the draft LaTeX.
7. **Draft for the paper** (§6), revised:
   * a main-text remark `rem:teacher:weightdecay`, about 0.6 page, for after `rem:limits:schedule`;
   * an appendix subsection `app:teacher:weightdecay` with `prop:teacher:nofixedprior` (now with a part (iv) for the teacher window) and `ex:teacher:weightdecay` (now with the switch condition and the AdamW threshold in closed form), about 1.7 pages;
   * one related-work sentence.

   In a scratch copy of Paper 2 these build with 0 errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels and no overfull box over 10pt; the PDF grows from 74 to 78 pages.

### 0.1 Response to the referee

The report found no fatal or major issue, two moderate issues (M1, M2), ten minor ones (m1–m10) and four literature attributions beyond the abstracts (L1–L4), and offered four additions (A1–A4). Every item was checked again here; all are accepted.

| item | referee's point | action | where |
|---|---|---|---|
| M1 | the draft's "no fixed prior gives the cn-MAPs at every n" is false without full support | **accepted**; verified independently (d3(B1)). The sentence now says "no fixed prior with full support". The unqualified claim is kept as refuted (R2). Added: a sufficient condition under which no fixed prior at all works (Prop 2.2(v)), with an instance (Example 2.6, d3(B2)), and the machine-dependent degenerate prior in $\Hcl{\times}$ (Remark 2.8(a)) | §2, §6.1, §6.2 |
| M2 | "only programs of maximal likelihood stay MAPs" was not proved; true for summable priors | **accepted**; the summable statement is Prop 2.2(iv) with proof. New: for non-summable full-support priors it is false (Example 2.7, d3(A2)), kept as refuted (R3). The main-text sentence now states what Prop 2.2(i) proves | §2, §6.1 |
| m1 | "randomised error 0.5 against 0.1": the sampler's randomised error is 0.18 | **accepted**; corrected with both error notions (d3(F)) | §3 |
| m2 | §8 open point 2, "convex ⇒ no vertices", is false ($L=\lvert\theta-1\rvert$) | **accepted**; kept as refuted (R4), with the counterexample computed (d3(E1)). Replaced by a simpler true statement: for differentiable $L$ a point $\theta\ne0$ is selected at one ω at most (Prop 4.2(iii)) | §4.2, §8 |
| m3 | "fixed points minimise" → "are the stationary points of" | **accepted** | §4.4, §6.2 |
| m4 | "by counting" → "by Kraft's inequality" | **accepted**; the counting argument fails when $n_0\log\lvert Y\rvert$ is not an integer | Prop 2.2(iii) |
| m5 | fluctuations of order $n^{-1/2}/c$ unlabelled | **accepted**; tagged [heuristic] | Remark 1.3 |
| m6 | "ω* plays the role of c*" overstated | **accepted**; now "an analogue" with the reason | §4.3 |
| m7 | "to 3–4 digits" for AdamW | **accepted**; now "within 0.3 % at λ_W = 0.01, 4 digits for λ_W ≥ 0.05" | §4.4 |
| m8 | MacKay citation placement | **accepted**; the citation now supports only the Gaussian-prior reading | §6.1 |
| m9 | §4.5 last row paired fixed ω with fixed λ | **accepted**; fixed ω pairs with λ = cn; the row now reads as evidence that $\|\theta\|^2$ does not track description length | §4.5 |
| m10 | teacher numbers 0.2–0.29 without parameters | **accepted**; parameters stated | §3 |
| L1 | Omnigrok: "constraining the norm eliminates grokking" is body, "largely" | **accepted**; retagged; confirmed again by a search here | §4.4, §5 |
| L2 | Zhang et al.: weight-decay specifics are in the body, AlexNet with weight decay did not converge | **accepted**; retagged; confirmed again here by a search that returned the ICLR 2017 poster's table | §4.4, §5 |
| L3 | Power et al. "particularly effective" not reconfirmed | **accepted**; quotation marks dropped, not reconfirmed here either | §4.4, §5 |
| L4 | Nanda et al.: the abstract does not attribute cleanup to weight decay | **accepted** for the abstract. Two searches here returned paraphrased body excerpts that do tie cleanup to weight decay; the referee's searches placed that attribution in another paper. Recorded as body via search excerpt, disputed location; the draft stays at abstract level | §4.4, §5 |
| A1 | inside the teacher window $c>c^*$ is provable above $c_+$ | **adopted** as Prop 3.2, proof checked line by line against `thm:teacher:main`, numbers recomputed (d3(C)); in the draft as Prop (iv) | §3, §6 |
| A2 | closed form of the AdamW box threshold | **adopted** for ε ≤ 1, where the referee's proof applies (it uses εB < B); for ε > 1 the box never switches (added). Proof checked, recomputed at 8 pairs (d3(D1)) | §4.3, §6.2 |
| A3 | the L2 switch happens iff $\varepsilon^2<1-2q$ | **adopted**, proof checked, recomputed at 8 pairs on 241 values of ω (d3(D2)). The referee's caveat, that AdamW reaching the box was checked only at (0.1, 0.2), is removed: AdamW runs at (0.8, 0.2) and (0.7, 0.3) switch where L2 does not (d3(D3)) | §4.3, §6.2 |
| A4 | fixed priors that do reproduce the cn-MAPs | **adopted** and recomputed by exact feasibility over all priors (d3(B1)) | §2 |
| Rem 2.5(a) | the vertex-interval condition is not needed | **adopted**; proved and computed at breakpoints (d3(G)) | §2 |
| author's bullet | "params" may mean model parameters | addressed in one paragraph (header) and listed for confirmation (§8) | header |

---

## 1. λ_n = cn as a per-sample penalty

**Proposition 1.1 (per-sample form and limit)** [proved: `rem:setup:persample`; `prop:recovery:beyond`(c)].
* Setting: a class as in `def:split:setting`, PQ data, $c>0$.
* $J_{cn}(\pi;h_n)/n=c\,\ell(\pi)+\hat R_n(\pi)$.
* Almost surely $\hat R_n(\pi)\to R_\nu(\pi)$ for all π at once.
* If some π has $J_c(\pi)<\infty$, then $A_c$ is nonempty and finite, and almost surely every $cn$-MAP lies in $A_c$ for all large $n$.

For a fixed λ the per-sample objective is $(\lambda/n)\ell+\hat R_n$: the penalty's share vanishes like $1/n$. For λ = cn it is constant. "A regularisation that does not vanish with data" means exactly this.

**Remark 1.2 (the prior factor is paid once per sample)** [proved; computed: d1(E)].
* The power-prior weights satisfy
  $$2^{-cn\ell(\pi)}\nu_\pi(h_n)=\prod_{i\le n}\big[2^{-c\ell(\pi)}\,\nu_\pi(y_i\mid x_i)\big],$$
  so, normalised, $\Pi_{cn}(\pi\mid h_n)\propto\Pi_{c(n-1)}(\pi\mid h_{n-1})\cdot\nu_\pi(y_n\mid x_n)\cdot2^{-c\ell(\pi)}$. The normaliser is finite once $cn\ge1$, by Kraft.
* More generally, any schedule gives this recursion with the factor $2^{-(\lambda_n-\lambda_{n-1})\ell(\pi)}$. A fixed λ gives the factor 1, which is Bayes' rule with the fixed prior $2^{-\lambda\ell}$; λ = cn multiplies by the prior factor $2^{-c\ell}$ again at every update.
* So $\Pi_{cn}$ is the loss-based update, in the sense of generalised Bayes, with per-sample loss $-\log\nu_\pi(y\mid x)+c\,\ell(\pi)$ from a flat initial weight. That weight is improper on an infinite class [remark].
* This is the precise sense in which λ = cn, like weight decay, "keeps going on each step".
* Check: d1(E) finds $\max|\text{recursive}-\text{direct}|=4.33\cdot10^{-15}$ over $n\le50$.

**Remark 1.3 (the tempered posterior with learning rate 1/(cn) does not concentrate)** [proved; computed: d1(D)].
* In Paper 2's notation $\Pi^\eta(\pi)\propto2^{-\ell(\pi)}\nu_\pi(h_n)^\eta$. With $\eta=1/(cn)$ this is $\Pi^{1/(cn)}(\pi\mid h_n)\propto2^{-\ell(\pi)-\hat R_n(\pi)/c}$.
* Its MAP is the $cn$-MAP (`lem:setup:basic`(ii)).
* As $n\to\infty$ it converges almost surely in total variation to the fixed Gibbs measure $G_c(\pi)\propto2^{-\ell(\pi)-R_\nu(\pi)/c}$, with $R_\nu=\infty$ giving weight 0. This needs some π with $R_\nu(\pi)<\infty$.
* *Proof.* Almost surely $\hat R_n(\pi)\to R_\nu(\pi)$ for all π at once (strong law; to $+\infty$ when $R_\nu(\pi)=\infty$). The weights are dominated by the summable $2^{-\ell}$. Dominated convergence gives convergence of the normaliser to $Z_c>0$, and Scheffé's lemma gives convergence in total variation. ∎
* So with λ = cn the data never overwhelm the prior: the generalised posterior's learning rate $1/(cn)$ decays like $1/n$. The power-prior posterior $\Pi_{cn}$ does concentrate, on $A_c$.
* d1(D), c = 0.02: the total-variation distance to $G_c$ is 0.084, 0.00023, 0.025, 0.00074 and 0.0011 at $n=10^2,10^3,10^4,10^5,2\cdot10^5$ [computed]. The fluctuations are of order $n^{-1/2}/c$ [heuristic: a scaling argument, not proved or fitted]. The power-prior mass on $\arg\min J_c$ is $1.000000$ from $n=10^4$ [computed].

**Remark 1.4 (fixed λ is a fixed prior)** [proved].
* For fixed λ the λ-MAPs are the MAPs of the fixed prior $w_\lambda=2^{-\lambda\ell}$, which is summable for λ ≥ 1 by Kraft.
* $\Pi_\lambda$ is Bayes' posterior for that prior, and $\xi_\lambda$ is one Bayesian predictor (`rem:setup:persample`).
* So the steeper prior of the split thread is Bayesian learning with a different fixed prior. Only λ growing with $n$ leaves Bayesian learning.

---

## 2. No fixed prior gives the cn-MAPs

**Definition 2.0.**
* A *fixed prior* is a map $w$ from programs to $[0,\infty)$ chosen before the data.
* Its MAPs on a per-query sample $h$ are the maximisers of $w(\pi)\nu_\pi(h)$. The set may be empty when $w$ is not summable. If every program has score 0, every program is a MAP.
* $w$ has *full support* if $w>0$ everywhere; it is *summable* if $\sum_\pi w(\pi)<\infty$.
* $w$ *gives the cn-MAPs* if on every per-query sample its MAP set equals the $cn$-MAP set.
* $h^r$ is the sample $h$ repeated $r$ times (size $rn_0$). $\hat P_h$ is the empirical distribution of the pairs of $h$.

**Proposition 2.1 (the cn-MAPs depend only on the empirical distribution)** [proved; computed: d1(A)].
* For $c>0$ and samples $h,h'$ of sizes $n,n'$ with $\hat P_h=\hat P_{h'}$, the $cn$-MAPs of $h$ are the $cn'$-MAPs of $h'$.
* In particular the $crn_0$-MAPs of $h^r$ are the $cn_0$-MAPs of $h$.
* *Proof.* $J_{cn}(\pi;h)/n=c\,\ell(\pi)+\Ex_{\hat P_h}[-\log\nu_\pi(y\mid x)]$. ∎
* d1(A): in 1998 random finite classes, with the replicated sample's fit computed from the replicated sample itself, the set is equal for $r=2,3,7,50$ in 1998 of 1998.

**Proposition 2.2 (repetition separates the cn-MAPs from fixed priors)** [proved; computed: d1(A), d3(A), d3(B)].
Let $c>0$ and let $h$ be a per-query sample of size $n_0$ such that:
* (a) $P^*:=\max_\pi\nu_\pi(h)>0$ is attained, by $\pi^*$ say;
* (b) no $cn_0$-MAP of $h$ attains $P^*$.

Let $M$ be the finite set of $cn_0$-MAPs of $h$ (`lem:setup:basic`), and $w$ a fixed prior with $w(\pi^*)>0$.
* (i) For every
  $$r>r_{\rm th}:=\max_{\hat\pi\in M,\,w(\hat\pi)>0}\frac{\log(w(\hat\pi)/w(\pi^*))}{\log(P^*/\nu_{\hat\pi}(h))}$$
  (and every $r\ge1$ if no $\hat\pi\in M$ has $w(\hat\pi)>0$), no $crn_0$-MAP of $h^r$ is a MAP of $w$ on $h^r$. More generally, any program π with $\nu_\pi(h)<\nu_{\pi'}(h)$ for some π′ with $w(\pi')>0$ is not a MAP of $w$ on $h^r$ once $r>\log(w(\pi)/w(\pi'))/\log(\nu_{\pi'}(h)/\nu_\pi(h))$.
* (ii) Consequently no fixed prior with full support gives the $cn$-MAPs. This holds for every class with a sample satisfying (a), (b).
* (iii) In $\Hcl{\times}$, for every $c>0$, such samples exist.
* (iv) *(Summable priors; referee M2.)* If $w$ is summable, then for all large $r$ every MAP of $w$ on $h^r$ attains $P^*$. Here only (a) is used.
* (v) *(No fixed prior at all.)* If moreover $\pi^*$ is a $cn$-MAP of some sample $h'$ whose $cn$-MAP set is not the whole class, then no fixed prior whatsoever gives the $cn$-MAPs.

*Proof.*
* (i) By Proposition 2.1 the $crn_0$-MAPs of $h^r$ are the programs of $M$. Each $\hat\pi\in M$ has $J_{cn_0}(\hat\pi;h)<\infty$, so $0<\nu_{\hat\pi}(h)<P^*$.
  * If $w(\hat\pi)=0$, then $w(\hat\pi)\nu_{\hat\pi}(h)^r=0<w(\pi^*)(P^*)^r$.
  * Otherwise $w(\hat\pi)\nu_{\hat\pi}(h)^r<w(\pi^*)(P^*)^r$ is equivalent to $r\log(P^*/\nu_{\hat\pi}(h))>\log(w(\hat\pi)/w(\pi^*))$.

  In both cases $\hat\pi$ is beaten by $\pi^*$ on $h^r$. The general form is the same computation with π′ in place of $\pi^*$.
* (ii) is immediate from (i) at any $r>r_{\rm th}$, since the $crn_0$-MAP set is nonempty.
* (iii) Let $Y$ be finite with $|Y|\ge2$, and let $\ell_{\rm u}$ be the length of a fixed program for the uniform kernel on $Y$. Take $n_0$ distinct inputs with $n_0\log|Y|-\kappa-\ell_{\rm u}>\log|Y|/c$, and labels $y\in Y^{n_0}$ with $K(y\mid\dom D)\ge n_0\log|Y|$. Such labels exist by Kraft's inequality for prefix complexity: $\sum_{y\in Y^{n_0}}2^{-K(y\mid\dom D)}\le1$ over $|Y|^{n_0}$ strings, so some $y$ has $2^{-K(y\mid\dom D)}\le|Y|^{-n_0}$. (A plain counting of programs shorter than $n_0\log|Y|$ does not suffice when $n_0\log|Y|$ is not an integer.)
  * The lookup program for $D$ has likelihood $1=P^*$ (on distinct inputs the PQ likelihood is the data-set likelihood), so (a) holds.
  * By `lem:setup:coding`, every program π with $\nu_\pi(h)=1$ has $\ell(\pi)\ge K(y\mid\dom D)-\kappa\ge n_0\log|Y|-\kappa$.
  * So $J_{cn_0}(\pi)\ge cn_0(n_0\log|Y|-\kappa)>cn_0\ell_{\rm u}+n_0\log|Y|=J_{cn_0}(\text{uniform})$, and (b) holds.
* (iv) $S:=\{\pi:w(\pi)\ge w(\pi^*)\}$ is finite, because $w$ is summable and $w(\pi^*)>0$.
  * A program π ∉ S has $w(\pi)<w(\pi^*)$ and $\nu_\pi(h)\le P^*$, so it is beaten by $\pi^*$ at every $r$.
  * A program π ∈ S with $\nu_\pi(h)<P^*$ is beaten by $\pi^*$ once $r>\log(w(\pi)/w(\pi^*))/\log(P^*/\nu_\pi(h))$; there are finitely many such π.
  * MAPs exist: the supremum of the scores is at least $w(\pi^*)(P^*)^r>0$, and only finitely many programs have score above any positive value, since $w$ is summable and $\nu_\pi(h)\le1$.
  * So for $r$ beyond the largest of these finitely many thresholds every MAP attains $P^*$.
* (v) Suppose $w$ gives the $cn$-MAPs. On $h'$, $\pi^*$ is a MAP of $w$. If $w(\pi^*)=0$, its score on $h'$ is 0, so all scores on $h'$ are 0 and every program is a MAP of $w$ on $h'$, against the hypothesis on $h'$. So $w(\pi^*)>0$, and (i) gives a sample $h^r$ on which the MAP set of $w$ differs from the $crn_0$-MAP set. ∎

*Computation.*
* d1(A): 671 of the 1998 random samples satisfy (a), (b). In all 671, at $r=\lfloor r_{\rm th}\rfloor+1$ the w-MAP set is disjoint from the $cn$-MAP set; the largest $r_{\rm th}$ is 11398.1. In the other 1327 samples some $cn_0$-MAP is a maximum-likelihood (ML) program, and duplication gives no contradiction.
* d3(A1), an independent implementation: in 1074 random samples satisfying (a), (b), with a fixed prior $w=2^{-\ell}\cdot U(0.1,10)$, every MAP attains $P^*$ at $r=\lfloor r_{\rm ML}\rfloor+1$, where $r_{\rm ML}$ is the exact threshold of the proof of (iv); the largest $r_{\rm ML}$ is 102227.4. (For finite classes every prior is summable; the computation checks the threshold formula.)

**Example 2.4 (two programs; the minimal "simpler and worse in the limit")** [proved; computed: d1(B), d3(B1)].
* Class: $\{\text{coin}$ (length 1, $\nu(y\mid x)=1/2$), $f$ (deterministic, length $1+k)\}$; Kraft holds. Data: per query, labelled by $f$, any input law.
* $J_{cn}(\text{coin})=cn+n$ and $J_{cn}(f)=cn(1+k)$, so the coin is the unique $cn$-MAP at every $n\ge1$ iff $ck>1$. At $ck=1$ the two tie at every $n$.
* For fixed λ, $f$ is the unique λ-MAP iff $n>\lambda k$.
* Here $\mathcal E=\{f\}$, $\ell_0=1+k$ and $c^*=1/k$ (KL of the coin = 1 bit).
* So for $c>1/k$ λ = cn keeps the coin forever: error rate 1/2 against 0. Every fixed prior with $w(f)>0$ switches to $f$ once $n>\log(w(\text{coin})/w(f))$.
* *Which fixed priors give the cn-MAPs* (referee A4) [proved; computed: d3(B1), rd1(A)]. Only $n$ and $f$-consistency matter. A prior $(w(\text{coin}),w(f))=(1,t)$ picks $f$ on a consistent sample of size $n$ iff $t>2^{-n}$.
  * For $ck<1$ the $cn$-MAP is $f$ on consistent samples and the coin otherwise; every $(1,t)$ with $t>1/2$ gives the $cn$-MAPs, full support included. No sample satisfies (a), (b) here.
  * For $ck>1$ the $cn$-MAP is the coin on every sample. A prior $(1,t)$ with $t>0$ fails on consistent samples with $n>\log(1/t)$, and only the degenerate $\delta_{\rm coin}=(1,0)$ gives the $cn$-MAPs. d3(B1): on all samples with $n\le30$ the feasible priors are $\log t<-30$ and $\delta_{\rm coin}$. rd1(A), enumerating all 55 986 samples with $n\le6$ on three inputs, found $\delta_{\rm coin}$ reproducing the $cn$-MAPs on every sample at $ck=2$, and the uniform prior at $ck=1/2$.
  * So the full-support hypothesis of Proposition 2.2(ii) cannot be dropped.
* d1(B), $k=10$: $c=1/20$ gives $f$, $1/10$ gives a tie and $1/5$ gives the coin, at $n=1,10,10^3,10^6$. For λ = 1, 2, 5 the least $n$ with $f$ the unique MAP is 11, 21, 51.

**Remark 2.5 (other schedules and other data objects).**
* (a) *Schedules with $\lambda_n/n\to c>0$* [proved; computed: d3(G)].
  * On $h^r$ the $\lambda_{rn_0}$-MAPs are the $(\lambda_{rn_0}/r)$-MAPs of $h$ (`lem:teacher:reuse`), and $\lambda_{rn_0}/r\to cn_0>0$.
  * By `lem:setup:hull`(v) the edge slopes $\sigma_i$ of $h$'s hull accumulate only at 0, so some neighbourhood of $cn_0$ contains no slope other than possibly $cn_0$ itself. For λ′ ≠ $cn_0$ in it, the λ′-MAPs are the programs at one vertex: if $cn_0$ lies inside a vertex interval, the vertex whose programs form $M$; if $cn_0$ is an edge slope $\sigma_i$, an endpoint of the closed edge $[v_{i-1},v_i]$, whose programs all lie in $M$. Either way the λ′-MAPs lie in $M$.
  * Hence for all large $r$ the $\lambda_{rn_0}$-MAPs of $h^r$ lie in $M$, and Proposition 2.2(i) applies to them unchanged. The vertex-interval condition of `notes.md` is not needed (referee).
  * d3(G): 239 cases (random classes with power-of-two kernel values, so all fits are integers; $cn_0$ an edge slope whose closed edge misses maximum likelihood; $\lambda_n=cn+\sqrt n$). In 239 of 239 the $\lambda_{rn_0}$-MAPs lie in $M$ at every listed $r$ from some $r\le100$ on, up to $r=10^7$; and for every listed $r>r_{\rm th}$ they are disjoint from the MAPs of a full-support prior.
* (b) *Schedules $\lambda_n=o(n)$* [proved where stated]. $\lambda_{rn_0}/r\to0$, so duplication drives both rules to maximum likelihood, and it gives no contradiction.
  * Per query they agree eventually with the prior $2^{-\ell}$ (Theorem A(a) of Paper 2).
  * Whether a non-constant $o(n)$ schedule is a fixed-prior MAP rule at finite $n$ depends on the class [open; not pursued].
* (c) *Frozen labels and one data set* [proved]. On a data set (DS, FR) a repeated query adds nothing, so the data set $D$ stays fixed while $n$ grows. The $cn$-MAPs of $D$ are its λ-MAPs at λ = cn. They change with $n$ whenever the hull of $D$ has a vertex whose λ-interval ends inside $(cn_0,\infty)$ (`lem:setup:hull`(v)), while every fixed prior's MAP on $D$ is the same for all $n$. The per-query form above is the one that matches "as the number of samples grows".

**Example 2.6 (two Bernoulli rates: no fixed prior at all)** [proved; computed: d3(B2); new].
* Class: on $Y=\{0,1\}$, $\pi_h$ gives label 1 probability 1/2 at every input (length 1) and $\pi_q$ gives it probability 1/4 (length $1+k$). Only the number $n$ of labels and the fraction $\hat p$ of ones matter.
* The per-sample gain of $\pi_q$ over $\pi_h$ is $g(\hat p)=1-[2\hat p+(1-\hat p)\log\frac43]=\log\frac32-\hat p\log3$.
  * The $cn$-MAP is $\pi_q$ iff $g(\hat p)>ck$, and the ML program is $\pi_q$ iff $g(\hat p)>0$.
  * A prior $(w(\pi_h),w(\pi_q))=(1,t)$ picks $\pi_q$ iff $\log t>-n\,g(\hat p)$.
* Let $0<ck<\log\frac32$.
  * Samples with $0<g(\hat p)<ck$, i.e. $\hat p\in((\log\frac32-ck)/\log3,\ \log\frac32/\log3)$, satisfy (a), (b) with $\pi^*=\pi_q$.
  * The all-zero sample has $g(0)=\log\frac32>ck$, so its $cn$-MAP set is $\{\pi_q\}$.
  * By Proposition 2.2(v), no fixed prior gives the $cn$-MAPs.
* For $ck>\log\frac32$ the $cn$-MAP is $\pi_h$ on every sample, and $\delta_{\pi_h}$ gives the $cn$-MAPs. (At $ck=\log\frac32$ no prior does either: the all-zero samples tie, and equality of the two scores holds for at most one $n$.)
* d3(B2), $k=10$, exact feasibility of $(1,t)$ plus the three degenerate priors on all samples of size $\le40$:
  * $ck=0.1$: no prior from $N=12$ on;
  * $ck=0.3$, 0.5, 0.584: no prior from $N=4$ on (for instance $n=4$, one 1: $g=0.189<0.3$ and $4g=0.755$ forces $\log t<-0.755$, while $n=1$, label 0, forces $\log t>-0.585$);
  * $ck=0.586$ and 1.0: only $\log t<-23.4$ survives $n\le40$, and $\delta_{\pi_h}$ matches;
  * no $g(\hat p)$ lies within $4.8\cdot10^{-4}$ of $ck$, so floating point decides no case.

**Example 2.7 (a non-summable prior with full support that never ends at maximum likelihood)** [proved; computed: d3(A2); new].
* Sample: one input, four labels with one 1, so $\hat\theta=1/4$ and $P^*=\frac14(\frac34)^3$.
* Class: $\pi^*$ = Bernoulli(1/4) and $\pi_j$ = Bernoulli($\theta_j$), $j\ge1$, with $\theta_j\in(\frac14,1)$ chosen so that $\log(P^*/\nu_{\pi_j}(h))=4\,\KL(\frac14\|\theta_j)=1/j^3$ (possible by continuity; d3(A2) lists $\theta_1=0.5393$, $\theta_{10}=0.2581$, $\theta_{100}=0.2503$). Lengths: any Kraft lengths.
* Prior: $\log w(\pi^*)=-1$, $\log w(\pi_j)=1/j$. It has full support and is not summable.
* On $h^r$, relative to $r\log P^*$, $\pi^*$ scores $-1$ and $\pi_j$ scores $f_r(j)=1/j-r/j^3$.
  * $f_r(j)>0$ for $j>\sqrt r$, and $f_r(j)<1/j\to0$, so the supremum is positive and attained at a finite $j$: MAPs exist at every $r$.
  * None of them is $\pi^*$, so no MAP attains $P^*$ at any $r$.
* d3(A2): the MAP is unique, at $j=2,6,17,173,1732,17321$ for $r=1,10,10^2,10^4,10^6,10^8$, close to $\sqrt{3r}$.
* So summability cannot be dropped from Proposition 2.2(iv). This refutes the draft sentence of `notes.md` for full-support priors in general (R3 below).

**Remark 2.8 (degenerate priors)** [proved].
* (a) *$\Hcl{\times}$.* Let the fixed universal prefix machine $V$ be such that its unique shortest program $\pi_s$, of length $\ell_s$, computes the uniform kernel on $Y$ and every other program is at least $\ell_s+1$ long (for instance $V(0)$ = the uniform kernel and $V(1w)=V'(w)$ for a universal $V'$). For $c>\log|Y|$, on every sample of size $n$, $J_{cn}(\pi_s)=cn\ell_s+n\log|Y|<cn(\ell_s+1)\le J_{cn}(\pi)$ for every other π. So $\pi_s$ is the only $cn$-MAP on every sample, and $\delta_{\pi_s}$, whose only positive score is $\pi_s$'s, gives the $cn$-MAPs. So the unqualified "no fixed prior" is false in $\Hcl{\times}$ for such machines and $c>\log|Y|$; with full support it holds for every machine and every $c>0$ (Proposition 2.2(ii), (iii)). Whether, for a given machine and small $c$, the condition of Proposition 2.2(v) holds in $\Hcl{\times}$ is open (§8, item 4).
* (b) *Per query, priors that do not charge $\mathcal E$.* Let $c>c^*$ and $A_c=\{\pi'\}$. As $R_\nu(\pi')<\infty$, almost surely $\nu_{\pi'}(h_n)>0$ for all $n$, so the MAP of $\delta_{\pi'}$ is $\pi'$ at every $n$, and the $cn$-MAP is $\pi'$ for all large $n$ (Proposition 1.1). So the two agree eventually. Proposition 2.3(ii) below is a statement about priors that give the sampler's programs positive weight, which is the case that matters: every Bayesian who could represent the sampler eventually selects it, and λ = cn with $c>c^*$ does not.

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
  * On $G$, $\nu_\pi(h_n)=\nu(h_n)$ for π ∈ $\mathcal E$, so every $w$-MAP $\hat\pi$ has $w(\hat\pi)\Lambda_n(\hat\pi)\ge W$. MAPs exist because $w$ is summable and the supremum is at least $W\nu(h_n)>0$.
  * Enumerate the programs as $\pi_1,\pi_2,\dots$ and let $T_k:=\{\pi_j:j>k\}$. $Z^k_n:=\sum_{\pi\in T_k}w(\pi)\Lambda_n(\pi)$ is a nonnegative supermartingale with $Z^k_0=w(T_k)$, by `lem:recovery:ratios`(a) applied termwise.
  * By Ville's inequality, $\Prob[\exists n:\text{some }w\text{-MAP lies in }T_k]\le\Prob[\sup_nZ^k_n\ge W]\le w(T_k)/W\to0$. So almost surely all $w$-MAPs at all $n$ lie in some finite $\{\pi_1,\dots,\pi_k\}$.
  * Among these, programs outside $\mathcal E$ have $\Lambda_n\to0$ almost surely (`lem:recovery:ratios`(c): $\frac1n\log\Lambda_n\to-\KL_\mu<0$, and $\KL_\mu>0$ iff $\pi\notin\mathcal E$). So eventually they are not $w$-MAPs.
  * Programs of $\mathcal E$ with $w<W$ never are, and programs of $\mathcal E_w$ attain the maximum $W$.
* (ii)
  * There is $\pi'$ with $\ell(\pi')<\ell_0$ and $\KL_\mu(\pi')/(\ell_0-\ell(\pi'))<c$, that is $J_c(\pi')<J_c(\pi_0)$.
  * For $\pi\in\mathcal E$, $J_c(\pi)=c\,\ell(\pi)+H_\mu(\nu)\ge J_c(\pi_0)$.
  * For $\pi\notin\mathcal E$ with $\ell(\pi)\ge\ell_0$, $J_c(\pi)>J_c(\pi_0)$.

  So minimisers of $J_c$ lie outside $\mathcal E$ and are shorter than $\ell_0$, with $R_\nu=H_\mu(\nu)+\KL_\mu>H_\mu(\nu)$. The rest is `prop:recovery:beyond`(c). (That proposition states only that eventually no $cn$-MAP is in $\mathcal E_0$; the disjointness from all of $\mathcal E$ is proved here.)
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

**Refuted statements of this section** (kept).
* **R1** (= D10 of `notes.md`) [refuted]. *Claim:* "on typical data the $cn$-MAP eventually differs from the MAP of every fixed prior, for every $c>0$". *Counterexample:* Proposition 2.3(iii) and d1(C) at $c=0.003<c^*$: both the $cn$-MAPs and the MAPs of $2^{-\ell}$ end at $\pi_0$. Remark 2.8(b) gives a second one for $c>c^*$ and priors that do not charge $\mathcal E$. The difference on typical data in the limit appears exactly for $c>c^*$ and priors that charge $\mathcal E$ ($c=c^*$ not covered). For every $c>0$ it appears on suitable samples (Proposition 2.2).
* **R2** (referee M1) [refuted]. *Claim* (draft remark of `notes.md`): "no fixed prior gives the $cn$-MAPs at every $n$", without a support condition. *Counterexample:* Example 2.4 with $ck>1$ and the prior $\delta_{\rm coin}$ (d3(B1), rd1(A)); in $\Hcl{\times}$, Remark 2.8(a). *True versions:* Proposition 2.2(ii) (full support), 2.2(v) (all priors, under a condition met in Example 2.6), Proposition 2.3 (per query, summable priors charging $\mathcal E$).
* **R3** (referee M2) [refuted as worded]. *Claim* (draft remark of `notes.md`): "under a fixed prior with full support only programs of maximal likelihood stay MAPs when a sample is repeated often enough". `notes.md` did not claim it in its body. *Counterexample:* Example 2.7 (full support, not summable; d3(A2)). *True version:* Proposition 2.2(iv) for summable priors.

---

## 3. The limit: a simpler hypothesis that predicts worse

**Proposition 3.1** [proved: Proposition 2.3(ii)].
* For $c>c^*$ every eventual $cn$-MAP is shorter than the sampler's shortest program and has strictly larger expected log loss.
* Every fixed summable prior that charges $\mathcal E$ ends in $\mathcal E$, with the smallest possible expected log loss $H_\mu(\nu)$.

**Classification** [computed: d1(C), d3(F); corrected per referee m1].
* Larger log loss need not mean a worse classifier. Two error rates are used: the *argmax* error (predict the most likely label) and the *randomised* error (draw the prediction from the kernel), both against a fresh label of the sampler.
* In d1(C) the sampler $(f,0.1)$ has argmax error 0.1 and randomised error $2p(1-p)=0.18$.
* At $c=0.02$ the limit $(f,1/8)$ has the sampler's argmax labels, so its argmax error is the same 0.1; its randomised error is 0.20.
* At $c=0.1$ the limit is the coin, with error 0.5 in both senses, against 0.1 (argmax) or 0.18 (randomised) for the sampler.
* (The program $(f',0.1)$ has errors 0.2 and 0.26.) Example 2.4 is the cleanest classification statement.

**Proposition 3.2 (the teacher window is an instance, with c > c\*)** [proved; computed: d3(C), rd1(C); referee A1].
*Setting.* The instance of `def:teacher:instance` in $\Hcl{\times}$ (or a product class covered by `thm:teacher:main`), with $B=\infty$, PQ data with $\nu=\delta_{y^*}$ (the teacher's labels) and inputs uniform on $\{0,1\}^d$. Then $\mathcal E=\{R=0\}$, the programs that give $y^*(x)$ probability 1 at every $x$; it contains the memoriser $\pi_b$. Put
$$c_+:=\frac{H(p)}{B_S-4-\Lambda_1-\kappa_g},$$
assuming the denominator is positive.

*Claim.* Every $c\in(\max\{2^{-m},c_+\},\,c_{\rm hi})$ has $c>c^*$. So for these $c$ Proposition 2.3(ii) applies: the $cn$-MAPs eventually lie in $A_c$, which is disjoint from $\mathcal E$, while every summable prior that charges $\mathcal E$ ends in $\mathcal E$.

*Proof.*
* Let $\pi\in A_c$, so $J_c(\pi)=\Phi(c)$ (the infimum of $J_c$; $A_c\ne\emptyset$ by Proposition 1.1, since $J_c(\pi_b)<\infty$).
* As $c2^m>1$ and $c<c_{\rm hi}$, $J_g(c)<\Phi_2(c)$ (`thm:teacher:main` and the definition of $c_{\rm hi}$). So `thm:teacher:main`(ii) applies with $\epsilon=0$: it covers every π with $J_c(\pi)\le\Phi(c)$.
* (ii)(b) gives $R(\pi)\ge R_B(\pi)\ge H(p)-c\Lambda_2/(c2^m-1)$. Since $2^mH(p)-\Lambda_2=B_S-4-\Lambda_1-\kappa_g$, this bound is positive iff $c(B_S-4-\Lambda_1-\kappa_g)>H(p)$, iff $c>c_+$.
* So $R(\pi)>0$ and $\pi\notin\mathcal E$: $A_c\cap\mathcal E=\emptyset$.
* If $c<c^*$, $A_c=\mathcal E_0$ (`prop:recovery:beyond`(c)). If $c=c^*$, the programs of $\mathcal E_0$ minimise $J_c$, because $J_c(\pi)-J_c(\pi_0)=\KL_\mu(\pi)-c^*(\ell_0-\ell(\pi))\ge0$ for $\ell(\pi)<\ell_0$ and $J_c(\pi)\ge J_c(\pi_0)$ trivially for $\ell(\pi)\ge\ell_0$. Both contradict $A_c\cap\mathcal E=\emptyset$. Hence $c>c^*$. ∎

*Size of the band.* With $B_S=L_S-\delta_S$ and $L_S=2^mH(p)-O(m)$, $c_+=2^{-m}\big(1+O((m+\log d+K(p)+\delta_S+\kappa)/L_S)\big)$ for $\delta_S\ge0$ [proved, from the definitions]. d3(C) at $d=100$, $m=20$, $p=2^{-10}$ ($L_S=11710.273$):

| κ | δ_S | Λ₂ | c₊ / 2⁻ᵐ |
|---|---|---|---|
| 0 | 0 | 52.19 | 1.00447 |
| 0 | 20 | 72.19 | 1.00620 |
| 30 | 0 | 112.19 | 1.00967 |
| 30 | 20 | 132.19 | 1.01141 |

These agree with rd1(C). The window is $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ at κ = 0 and $(9.54\cdot10^{-7},3.65\cdot10^{-3}]$ at κ = 30 (`rem:teacher:numbers`), so $c>c^*$ is proved on the window except in a band of relative width 0.45 %–1.2 % above $2^{-m}$. In that band nothing is claimed either way.

**The teacher thread is this phenomenon** [proved: Paper 2, Propositions 2.3 and 3.2].
* With $\lambda_n/n$ in a compact subset of the window $(2^{-m},c_{\rm hi})$, the $\lambda_n$-MAPs eventually satisfy `thm:teacher:main`(ii) (`prop:teacher:schedules`(c)). They know the parity and do not predict the errors: (ii)(e) bounds the average probability of the erroneous labels by $1-u+\gamma_g+2^{-g}$.
  * At the example's sizes and $c=10^{-4}$, ε = 0, $g$ optimised, this bound is 0.200, 0.218, 0.274 and 0.287 for (κ, δ_S) = (0, 0), (0, 20), (30, 0), (30, 20) (`tab:teacher:numbers`).
  * For eventual MAPs, `prop:teacher:schedules`(c) gives the theorem with $\epsilon=\bar\epsilon_n\to0$, so these ε = 0 values are the limits of the bounds (referee m10).
* So they mislabel, in the randomised sense, at least a fraction $p(1-e)$ of the teacher's labels, by $e(\pi)=\Ex[\nu_\pi(y^*\mid x)\mid x\in E]$. The memoriser mislabels none.
* Every summable prior that charges a risk-0 program ends at risk 0 by Proposition 2.3(i). For $w=2^{-\ell}$ this is `prop:teacher:schedules`(a).
* By Proposition 3.2, for $c$ above $c_+$ the window is moreover an instance of Proposition 2.3(ii): the $cn$-MAPs eventually avoid all of $\mathcal E$.
* This is the author's "keep preferring a simpler hypothesis that is worse at classification even in the limit", for the teacher's labels: worse at predicting what the teacher says, by design.

**Why λ must grow with n: a per-sample rate** [remark from proved results].
* `prop:limits:separable`: a component of extra length $k_j$ and population risk reduction $r_j$ is kept iff $r_j/k_j>c$.
* An error rule's reduction is a per-sample quantity, about $2^{-m}$ per bit (the reuse factor, `lem:teacher:reuse`). To discard it, the per-sample penalty must stay above that rate as $n$ grows.
* A fixed prior's per-sample penalty $\lambda\ell/n$ vanishes, so every positive-rate component is eventually kept: every $\lambda_n=o(n)$ learns the errors (`prop:teacher:schedules`(a)).
* Noise is different. A fill-in's rate falls like $1/n$, because its length grows like the sampled randomness $L_n(\nu)\approx nH$ while it gains the same $nH$ bits. So a fixed λ > 1 refuses it (Theorem A(c) of Paper 2).

---

## 4. Weight decay

### 4.1 Plain SGD weight decay is an L2-regularised average loss

**Proposition 4.1** [proved, elementary].
Let $f(\theta;z)$ be a per-sample loss differentiable in θ, $\hat L_n:=\frac1n\sum_{i\le n}f(\cdot;z_i)$, $F_n:=\hat L_n+\frac\omega2\|\theta\|^2$ with ω > 0, and $\hat L_B$ the average over a minibatch $B$.
* (a) The coupled weight-decay step $\theta\leftarrow\theta-\eta(\nabla\hat L_B(\theta)+\omega\theta)=(1-\eta\omega)\theta-\eta\nabla\hat L_B(\theta)$ is an SGD step on $F_n$. This is weight decay as implemented in plain SGD; PyTorch's SGD documentation describes its `weight_decay` argument as an L2 penalty [known: documentation, via search; the update equation itself was not seen].
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
* (iii) *(No kinks for differentiable L; replaces the refuted R4.)* A point $\theta_0\ne0$ is a stationary point of $L+\frac\omega2\|\theta\|^2$ for at most one ω, namely $\omega=-\nabla L(\theta_0)\cdot\theta_0/\|\theta_0\|^2$ when $\nabla L(\theta_0)$ is a negative multiple of $\theta_0$. So no point other than 0 is selected on an interval of ω, unlike a hull vertex, which is selected on an open interval of λ (`lem:setup:hull`(iii)). The point 0 is selected on an interval only if $\nabla L(0)=0$, and then for every ω.

*Proof.* (i) is first-order optimality. (ii) is $F(\theta^*)\le F(\theta)$. (iii): stationarity is $\nabla L(\theta_0)=-\omega\theta_0$, which determines ω when $\theta_0\ne0$. ∎

*Computation.* d2(A) checks (ii): the maximum of LHS − RHS over 60000 random θ is $-3.5\cdot10^{-4}$. d3(E2) checks (iii) in the toy below: the minimisers at 61 log-spaced ω in $[10^{-5},10]$ are distinct, the closest neighbours $7.45\cdot10^{-3}$ apart.

*Without differentiability there can be kinks* [proved; computed: d3(E1)]. For $L(\theta)=|\theta-1|$ on ℝ the minimiser of $L+\frac\omega2\theta^2$ is $\theta=1$ for every $\omega\in(0,1]$ (0 lies in the subdifferential $[-1+\omega,1+\omega]$) and $1/\omega$ for $\omega>1$. The value function $v(\rho)=\min\{L(\theta):\theta^2\le\rho\}=\max(0,1-\sqrt\rho)$ is convex with a kink at ρ = 1. d3(E1) finds these values on a grid of step $10^{-5}$. Piecewise-linear losses (ReLU networks, hinge losses) can therefore have points selected on intervals of ω; whether that gives a useful kink theory for networks is open (§8, item 2).

That the empirical minimisers of $F_n$ converge to θ* for strictly convex $F$ is standard M-estimation [known; not proved here]. It is checked in the toy (d2(B), (C)).

### 4.3 A toy where the regularised limit classifies worse

**Example 4.3** [proved; computed: d2(A)–(D), d3(D)].
*Setting.*
* $y$ is uniform on $\{\pm1\}$, and ξ = +1 with probability $1-q$, −1 otherwise, independent of $y$; $0<q<\frac12$.
* $x=(\varepsilon y,\ \xi y)$ with ε > 0, and $p_\theta(y\mid x)=\sigma(y\,\theta\cdot x)$ with no bias.
* With $s(u)=\ln(1+e^{-u})$, $a:=\varepsilon\theta_1+\theta_2$ and $b:=\varepsilon\theta_1-\theta_2$:
  $$L(\theta)=(1-q)\,s(a)+q\,s(b),\qquad\text{error rate}(\theta)=(1-q)[a\le0]+q[b\le0].$$

*Claims.*
* (a) $\inf L=0$, and $L(\theta_k)\to0$ forces $a_k,b_k\to\infty$. So the infimum is approached only by classifiers of error rate 0, and L has no minimiser.
* (b) For ω > 0 the minimiser θ*(ω) of F is unique and has $\theta_1,\theta_2>0$.
* (c) If $\varepsilon^2<1-2q$ (equivalently $q(1+\varepsilon^2)<(1-q)(1-\varepsilon^2)$), its error rate is 0 for $\omega<\omega^*$ and $q$ for $\omega\ge\omega^*$ (the tie $b=0$ at ω* counted as an error), where
  $$\omega^*=\frac{2q\varepsilon^2}{(1-\varepsilon^2)\,a^*},\qquad a^*=\ln\frac{2(1-q)(1-\varepsilon^2)-q(1+\varepsilon^2)}{q(1+\varepsilon^2)}>0,$$
  and $\theta^*(\omega^*)=(a^*/(2\varepsilon),\,a^*/2)$.
* (d) *(Referee A3.)* If $\varepsilon^2\ge1-2q$, the error rate is 0 for every ω > 0. So L2 decay ever yields the worse classifier iff $\varepsilon^2<1-2q$.
* (e) *(Referee A2.)* Let $\lambda>0$. The minimiser of $L$ under $\|\theta\|_\infty\le1/\lambda$ is unique and has $\theta_1=1/\lambda$. For $\varepsilon\le1$ it has error rate $q$ iff $\lambda\ge\lambda_{\rm box}:=2\varepsilon/\ln((2-3q)/q)$ (error 0 otherwise), including when $\varepsilon^2\ge1-2q$. For $\varepsilon>1$ its error rate is 0 for every λ.

*Proof.*
* (a) Both terms are positive. L → 0 needs $s(a)\to0$ and $s(b)\to0$, since $q>0$, so $a,b\to\infty$.
* (b) F is strictly convex and coercive, so the minimiser is unique. Its stationarity equations are
  $$\omega\theta_1=\varepsilon\big[(1-q)\sigma(-a)+q\sigma(-b)\big],\qquad \omega\theta_2=(1-q)\sigma(-a)-q\sigma(-b).$$
  * The first gives $\theta_1>0$.
  * If $\theta_2\le0$, then $a\le b$, so $\sigma(-a)\ge\sigma(-b)$ and $\omega\theta_2\ge(1-2q)\sigma(-b)>0$, a contradiction.
  * Hence $a>0$ and the error rate is $q[b\le0]$. Only $q<\frac12$ was used.
* *At $b=0$.* Then $\theta_2=\varepsilon\theta_1$, $a=2\theta_2>0$ and $\sigma(-b)=\frac12$. Dividing the equations gives $\varepsilon^2[(1-q)\sigma(-a)+q/2]=(1-q)\sigma(-a)-q/2$, that is
  $$(1-q)(1-\varepsilon^2)\,\sigma(-a)=\tfrac q2(1+\varepsilon^2).$$
  * If $\varepsilon\ge1$ the left side is $\le0<$ the right side: impossible.
  * If $\varepsilon<1$, $\sigma(-a)=\frac{q(1+\varepsilon^2)}{2(1-q)(1-\varepsilon^2)}$, which is $\ge\frac12$ iff $\varepsilon^2\ge1-2q$. Then $a\le0$, against $a>0$: impossible.
  * If $\varepsilon^2<1-2q$, this fixes $a=a^*>0$, $\theta_2=a^*/2$, $\theta_1=a^*/(2\varepsilon)$, and $\omega=[(1-q)\sigma(-a^*)-q/2]/\theta_2=\frac{q\varepsilon^2}{1-\varepsilon^2}\cdot\frac2{a^*}=\omega^*$.
  * So $b(\omega)$, continuous because the minimiser of a smooth strictly convex family is continuous in ω, vanishes only at ω* in case (c) and never in case (d).
* *Small ω* (no assumption on ε). Suppose $b\le0$.
  * The second equation and $\sigma(-b)\ge\frac12$ give $(1-q)\sigma(-a)>q/2$, so $a<A_0:=\ln((2-3q)/q)$, positive as $q<\frac12$.
  * With $a\ge2\varepsilon\theta_1$ this gives $\theta_1<A_0/(2\varepsilon)$.
  * The first equation gives $\theta_1\ge\varepsilon q/(2\omega)$.

  So $\omega>\varepsilon^2q/A_0$. Hence $b>0$ for $\omega\le\varepsilon^2q/A_0$.
* (d) $b>0$ near 0 and $b$ never vanishes, so $b>0$ for every ω.
* (c) *Large ω.* $\omega\theta^*=-\nabla L(\theta^*)\to-\nabla L(0)=(\varepsilon/2,(1-2q)/2)$, so $\omega b\to(\varepsilon^2-(1-2q))/2<0$. By continuity and the unique root, $b>0$ on $(0,\omega^*)$ and $b<0$ on $(\omega^*,\infty)$.
* (e) $\partial L/\partial\theta_1=-\varepsilon[(1-q)\sigma(-a)+q\sigma(-b)]<0$ everywhere, so $\theta_1=B:=1/\lambda$ at the minimiser, and $L(B,\cdot)$ is strictly convex on $[-B,B]$; so the minimiser is unique.
  * Let $\varepsilon\le1$, so $\varepsilon B\in(0,B]$ is feasible. The error rate is $q$ iff the optimal $\theta_2\ge\varepsilon B$ (then $b\le0$, and $a>0$ because $\partial L/\partial\theta_2=-(1-2q)\sigma(-\varepsilon B)<0$ at $\theta_2=0$, so $\theta_2>0$), iff $\partial L/\partial\theta_2\le0$ at $\theta_2=\varepsilon B$ (where $a=2\varepsilon B$, $b=0$), iff $(1-q)\sigma(-2\varepsilon B)\ge q/2$, iff $e^{2\varepsilon B}\le(2-3q)/q$, iff $\lambda\ge\lambda_{\rm box}$.
  * Let $\varepsilon>1$. Then $b=\varepsilon B-\theta_2\ge(\varepsilon-1)B>0$ and $a\ge(\varepsilon-1)B>0$, so the error rate is 0. ∎

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

*Computation* (d3(D), an independent implementation; the referee's rd1(B) agrees where they overlap):
* (D1) $\lambda_{\rm box}$ in closed form equals the numerical threshold of the box problem to 6 digits at 8 pairs (ε, q), among them $0.102780$ at (0.1, 0.2), $0.822237$ at (0.8, 0.2) and $1.077517$ at (0.7, 0.3). At $1.5\lambda_{\rm box}$ a two-dimensional L-BFGS-B on the box puts $\theta_1$ at the bound and agrees with the one-dimensional solution to 6 digits.
* (D2) On 241 log-spaced ω in $[10^{-6},10^4]$: for the five pairs with $\varepsilon^2\ge1-2q$ ((0.8, 0.2), (0.7, 0.3), ($\sqrt{0.6}$, 0.2) on the boundary, (0.9, 0.1), (0.5, 0.4)) $b>0$ at all 241 values, and $\omega b$ at $\omega=10^4$ equals the limit $(\varepsilon^2-(1-2q))/2$ to 4 digits; for three pairs with $\varepsilon^2<1-2q$ ((0.77, 0.2), (0.6, 0.3), (0.1, 0.2)) the sign of $b$ is as predicted at all 241 values, with $\omega^*=13.36$, $1.885$ and $2.101\cdot10^{-3}$.
* (D3) Full-batch Adam on $F$ and AdamW, $2\cdot10^5$ steps, learning rate $0.05/\sqrt{1+t/1000}$ (non-increasing, divergent partial sums), betas (0.9, 0.999):

  | (ε, q) | coefficient | Adam on F (L2): error | AdamW: θ | AdamW error | box minimiser |
  |---|---|---|---|---|---|
  | (0.8, 0.2), λ_box = 0.822 | 0.3 | 0 | (3.3333, 0.7453) | 0 | (3.3333, 0.7452) |
  | | 0.6 | 0 | (1.6667, 0.8895) | 0 | (1.6667, 0.8896) |
  | | 1.2 | 0 | (0.8333, 0.8333) | 0.2 | (0.8333, 0.8333) |
  | | 2.0 | 0 | (0.5000, 0.5000) | 0.2 | (0.5000, 0.5000) |
  | (0.7, 0.3), λ_box = 1.078 | 0.5 | 0 | (2.0000, 0.5310) | 0 | (2.0000, 0.5311) |
  | | 2.0 | 0 | (0.5000, 0.5000) | 0.3 | (0.5000, 0.5000) |

  Adam on F agrees with the minimiser of F to within $2\cdot10^{-4}$ in every row, and AdamW with the box minimiser to within $10^{-4}$. So AdamW does reach the box minimiser in these cases too, and switches to the worse classifier where L2 decay never does. This removes the referee's caveat that convergence to the box had been checked only at (0.1, 0.2).

*Reading* [remark].
* The perfectly separating feature needs a large weight: $\theta_1^2\approx92$ at ω* (ε = 0.1, q = 0.2). The 80 %-correct feature needs a weight of about 1.
* Above ω* the regularised limit prefers the cheap, worse feature. No amount of data changes this at fixed ω, as in Example 2.4 for $c>1/k$.
* ω* is an analogue of c*: the threshold of the per-sample coefficient above which the limit takes the cheaper, worse hypothesis. The analogy is loose (referee m6): L has no minimiser here, so there is no "true solution" point of which ω* would be a left steepness; ω* is the threshold of the classifier only.
* Under L2 decay the switch needs $\varepsilon^2<1-2q$: the separating feature must be weak enough. Under the ℓ∞ box of decoupled decay a strong enough decay always switches when $\varepsilon\le1$, because the box caps the large weight $\theta_1$ at the same level as $\theta_2$. (For $\varepsilon>1$ the separating feature wins even at equal weights, and neither switches.)

### 4.4 Where the correspondence stops

1. **‖θ‖² is not a description length.**
   * A Gaussian density is not a code. MAP under a density depends on the parametrisation, and a code length for real weights needs a precision. Hinton and van Camp (1993) control the information in the weights by adding Gaussian noise whose level is adapted during learning [known, abstract level].
   * In networks with normalisation layers the loss is invariant to rescaling some weight groups. There L2 regularisation has no regularising effect and mainly sets the effective learning rate (van Laarhoven 2017) [known, abstract level].
   * Discrete lengths give a hull with vertices, so selection is locally constant on open λ-intervals: robust in the kink sense. For differentiable $L$ no point $\theta\ne0$ is selected on an interval of ω (Proposition 4.2(iii)). In the toy only the *classification* is piecewise constant [proved; computed: d2(A), d3(E2)].
2. **SGD noise and non-convexity.**
   * The correspondence is with the minimiser of $F_n$. SGD iterates are random, and constant-step SGD has a stationary distribution, which can be tuned to approximate a posterior (Mandt, Hoffman and Blei 2017) [known, abstract level].
   * Non-convex networks have many stationary points. The λ-MAP is a global minimiser over all programs [remark].
3. **Decoupled weight decay is a different objective.**
   * L2 and weight decay are equivalent for SGD when rescaled by the learning rate, but not for adaptive methods such as Adam (Loshchilov and Hutter 2019) [known, abstract level].
   * In the full-batch setting, if AdamW converges under a non-increasing learning-rate schedule with divergent partial sums, the limit is a KKT point of the loss under an ℓ∞-norm constraint (Xie and Li 2024) [known, abstract level].
   * Toy (d2(D)) [computed]: Adam on F converges to argmin F at every coefficient (to 3–4 digits). AdamW ends at the minimiser of L under $\|\theta\|_\infty\le1/\lambda_W$ to within 0.3 % at $\lambda_W=0.01$ ($\theta_1=99.672$ against 100) and to 4 digits for $\lambda_W\ge0.05$ (referee m7). Its error switches at $\lambda_W=0.1028$, the closed form $\lambda_{\rm box}=2\varepsilon/\ln((2-3q)/q)$ (Example 4.3(e)), instead of $\omega^*=0.0021$, a factor of about 49.
     * For $\lambda_W\le0.003$ neither AdamW ($2\cdot10^5$ steps) nor L-BFGS-B on the box reached the box boundary, because the loss is numerically flat there. Both have error 0, as the closed form predicts ($\lambda_W<\lambda_{\rm box}$).
   * Where L2 never switches ($\varepsilon^2\ge1-2q$) and $\varepsilon\le1$, AdamW does, at $\lambda_{\rm box}$ (Example 4.3(d), (e); d3(D3)) [proved; computed].
4. **Per step, not per sample.**
   * Coupled decay: at a full-batch fixed point the coefficient is ω, independent of η, the batch size and the number of epochs [proved].
   * Before convergence the iterate depends on η·T (d2(E)) [computed]:
     * at ω = 0.01, (η, T) = (0.1, 1000), (0.01, 10⁴) and (1, 100) all give θ ≈ (2.00, 1.20);
     * η·T = 10 gives (0.37, 1.12);
     * the converged value is (2.93, 1.16).
   * A coordinate with zero loss gradient shrinks by $(1-\eta\omega)^T\approx e^{-\omega\eta T}$ [proved].
   * At ω = 0.001 < ω*, gradient descent stopped at T ≤ 3000 (η = 0.1) has error 0.2; from T = 10⁴ on, error 0 [computed: d2(E)]. So early stopping acts as extra regularisation and can change the classifier.
   * If the decay is not multiplied by the learning rate α of the loss step, $\theta\leftarrow\theta-\eta_t(\alpha\nabla L+\lambda\theta)$ (SGDW-style), the fixed points are the stationary points of $L+\frac{\lambda}{2\alpha}\|\theta\|^2$, and its minimisers when $L$ is convex (referee m3) [proved: stationarity]. The effective coefficient then depends on α (d2(E): the limits equal the predicted minimisers to 4 digits for α = 0.1, 0.5, 2) [computed].
   * Loshchilov and Hutter normalise the decay as $\lambda=\lambda_{\rm norm}\sqrt{b/(BT)}$, with $b$ the batch size, $B$ the number of training points and $T$ the number of epochs, motivated by different optimal decay factors for different numbers of batch passes [known: body (Appendix B.1), via search excerpt; not read in full; not for the paper text].
     * At a fixed number of epochs this scales the per-step coefficient like $n^{-1/2}$, between the per-sample choice (constant) and the fixed-prior choice ($1/n$) [heuristic]. The comparison applies to SGDW-style decay only: for AdamW the limit is an ℓ∞ box, not an L2 penalty (item 3), so there is no coefficient ω to compare with.
5. **What weight decay does in deep networks.**
   * Zhang et al. (2017): state-of-the-art convolutional networks trained with stochastic gradient methods fit random labels, and this is "qualitatively unaffected by explicit regularization" [known, abstract level]. The abstract names explicit regularisation, not weight decay. The weight-decay specifics are in the body and the ICLR 2017 poster [body, via search excerpt; not read]: on CIFAR-10 with random labels, Inception with weight decay reaches 100 % training accuracy, an MLP 99.21 %, and AlexNet with weight decay failed to converge (referee L2; a search in this revision returned the poster's table).
     * Reading [remark]: fixed ω corresponds to λ = cn, which refuses fill-ins even more strongly than a fixed λ > 1 (Theorem A(c) of Paper 2). So the observation shows that, in that regime, $\|\theta\|^2$ does not track description length: a network can fit random labels at a norm the default decay does not prevent. It does not show that the per-sample schedule is weaker than a fixed prior.
   * Arpit et al. (2017): with appropriately tuned explicit regularisation (e.g. dropout) training on noise can be degraded without hurting generalisation on real data [known, abstract level; the abstract names dropout, not weight decay].
   * D'Angelo et al. (2024): in modern deep learning weight decay acts mainly through the training dynamics, not as an explicit regulariser in the classical sense [known, abstract level; the abstract's wording is stronger: "never useful as an explicit regularizer"].
   * Krogh and Hertz (1992): in linear networks weight decay suppresses irrelevant components of the weight vector and, if its size is chosen right, some effects of static noise on the targets [known, abstract level]. This is the clean reference for weight decay and label noise at abstract level.
6. **Grokking.**
   * Power et al. (2022): on small algorithmic datasets, generalisation improves from chance to perfect well past the point of overfitting, and smaller datasets need more optimisation. The abstract does not mention weight decay [known, abstract level]. A body statement that weight decay was particularly effective among the interventions tried was reported by a search for `notes.md` but **not reconfirmed** by the referee or by this revision; it is not quoted and not used (referee L3).
   * Liu et al. (2022): an effective theory and phase diagrams (comprehension, grokking, memorisation, confusion) [known, abstract level]. The abstract does not name weight decay; cited for grokking only.
   * Liu, Michaud and Tegmark (2023, Omnigrok): the "LU mechanism", training and test loss against weight norm, explains data-size dependence, weight-decay dependence and the emergence of representations, and the authors "eliminate grokking for algorithmic datasets" [known, abstract level; the abstract does not say how]. How [body, via search excerpt; not read; referee L1, confirmed again here]: constrained optimisation at constant weight norm (α = 0.8) *largely* eliminates grokking, for modular addition with a one-layer transformer, p = 113, the norm being restored by rescaling after each step.
   * Nanda et al. (2023): memorisation, circuit formation and cleanup; grokking as gradual amplification of structured mechanisms followed by removal of memorising components [known, abstract level]. The abstract attributes the removal to the cleanup phase, not to weight decay (referee L4). Two searches in this revision returned paraphrased body excerpts saying that weight decay drives the cleanup and that the networks do not grok on modular arithmetic without weight decay or another regulariser [body, via search excerpt, paraphrased; not read]. The referee's searches instead placed the attribution to weight decay in a different paper by overlapping authors (A Toy Model of Universality, arXiv:2302.03025), and noted that whether weight decay is necessary for grokking is disputed. The location is therefore unsettled here, and nothing about it enters the draft.
   * Varma et al. (2023): generalising circuits are more efficient (larger logits per parameter norm); memorising circuits lose efficiency as the training set grows, giving a critical dataset size [known, abstract level; not in the draft].
   * *Relation to this paper* [heuristic]:
     * on noise-free algorithmic data a memorising and a generalising solution both fit, and any fixed length prior already prefers the shorter one;
     * what λ = cn adds is discarding components that *do* improve the fit, when their rate is below c;
     * the "keeps going after the data are fitted" dynamics of weight decay, which (per the body excerpts above, not the abstract) removes memorising components, is a dynamical analogue that the two-part objective does not model.

### 4.5 What is analogous and what is not (summary table)

| | steeper SFI with λ = cn | weight decay ω with averaged loss | status |
|---|---|---|---|
| per-sample objective | $c\,\ell+\hat R_n$ | $\hat L_n+\frac\omega2\|\theta\|^2$ | proved |
| implied prior on the summed objective | $2^{-cn\ell}$, exponent ∝ n | $\mathcal N(0,(n\omega)^{-1}I)$, precision ∝ n | proved |
| fixed prior corresponds to | fixed λ | ω = τ/n | proved |
| depends on data only via empirical distribution | yes (Prop 2.1) | yes (Prop 4.1(c)) | proved |
| limit objective | $c\,\ell+R_\nu$ | $L+\frac\omega2\|\theta\|^2$ | proved |
| limit can predict / classify worse than the truth | yes, for c > c* (Prop 2.3, Ex 2.4, Prop 3.2) | yes, unless 0 minimises L; toy: for ω ≥ ω* iff ε² < 1 − 2q (Ex 4.3) | proved |
| excess risk paid by complexity saved | $R(\pi_c)-R(\pi)\le c(\ell(\pi)-\ell(\pi_c))$ | $L(\theta^*)-L(\theta)\le\frac\omega2(\|\theta\|^2-\|\theta^*\|^2)$ | proved |
| prior factor applied once per sample / step | yes (Remark 1.2) | yes, per step (Prop 4.1(a)) | proved |
| complexity is a code length | yes (prefix code) | no (density; precision; scale invariance) | known |
| selection robust on open intervals (kinks) | yes (hull vertices) | no for differentiable L (Prop 4.2(iii)); possible for non-differentiable L | proved |
| what is computed | the global minimiser (an idealisation) | an SGD iterate | known |
| adaptive optimisers | n/a | AdamW ≠ L2: ℓ∞ box, threshold $2\varepsilon/\ln((2-3q)/q)$ in the toy | known; proved; computed |
| fixed per-sample coefficient refuses memorised noise | yes: λ = cn (and already any fixed λ > 1, Theorem A(c)) | not reliably: deep nets fit random labels under default weight decay (Zhang et al., body / poster; AlexNet with weight decay did not converge) | known (body, via search excerpt) |

The last row compares like with like: fixed ω pairs with λ = cn (referee m9). Its reading is that $\|\theta\|^2$ does not track description length in that regime.

### 4.6 What the analogy does and does not show [remark]

* It shows a shared structure of objectives: in both, the complexity coefficient is fixed per sample, so the implied prior sharpens with $n$; in both, the limit objective can select a cheaper hypothesis that predicts or classifies worse, with the exact thresholds $c^*$ and ω* in the toy cases.
* It does not show that weight decay in deep networks implements λ = cn, that networks select short programs, or that a norm penalty discards a teacher's errors. The toy results are toys.
* It explains "λ must grow with n" as a regularisation that does not vanish with data: a per-sample rate test (§3), the same test that a fixed weight-decay coefficient applies to a weight's squared norm.

---

## 5. Literature: verified sources

*Verification route.*
* For `notes.md` (about 30 WebSearch queries) and by the referee (46 queries), 2026-10-14. WebFetch of arxiv.org failed with a DNS error, and direct HTTPS to arXiv, Crossref, Semantic Scholar, DBLP and OpenReview was refused by the proxy. So every entry rests on search results: bibliographic records and abstracts, often paraphrased.
* This revision ran 6 more WebSearch queries, on the four retagged statements (L1–L4); their results are in §4.4 and the Verification log.
* Fields not confirmed by any search are omitted from `refs.bib` rather than guessed: the pages of the two NeurIPS papers and the OpenReview identifiers. The referee confirmed every field that `refs.bib` gives.

| key | bibliographic data (confirmed) | what the source says (abstract level unless marked) | used for |
|---|---|---|---|
| `krogh1992simple` | Krogh, Hertz. "A Simple Weight Decay Can Improve Generalization". NIPS 4 (1991 meeting), eds. Moody, Hanson, Lippmann, Morgan Kaufmann 1992, pp. 950–957 | weight decay in a linear network suppresses irrelevant weight components and, if the size is chosen right, some effects of static target noise; extended to hidden layers; NetTalk simulations | §4.4 item 5 |
| `loshchilov2019decoupled` | Loshchilov, Hutter. "Decoupled Weight Decay Regularization". ICLR 2019; arXiv:1711.05101 (earlier title "Fixing Weight Decay Regularization in Adam") | L2 regularisation and weight decay are equivalent for standard SGD when rescaled by the learning rate, not for adaptive methods such as Adam; proposes decoupling. Body, via search excerpt: normalised decay $\lambda=\lambda_{\rm norm}\sqrt{b/(BT)}$ (App. B.1). The SGDW update form of Algorithm 1 was not seen | remark; §4.4 items 3, 4 |
| `power2022grokking` | Power, Burda, Edwards, Babuschkin, Misra. "Grokking: Generalization Beyond Overfitting on Small Algorithmic Datasets". arXiv:2201.02177 (6 Jan 2022) | generalisation from chance to perfect long after overfitting; smaller datasets need more optimisation. Weight decay is not in the abstract; a body statement on weight decay was not reconfirmed (L3) | remark (grokking only) |
| `nanda2023progress` | Nanda, Chan, Lieberum, Smith, Steinhardt. "Progress Measures for Grokking via Mechanistic Interpretability". ICLR 2023; arXiv:2301.05217 | reverse-engineers modular addition in small transformers; training splits into memorisation, circuit formation and cleanup; grokking as gradual amplification of structured mechanisms followed by removal of memorising components. Weight decay's role: body via search excerpt, location disputed (L4) | remark |
| `liu2022towards` | Liu, Kitouni, Nolte, Michaud, Tegmark, Williams. "Towards Understanding Grokking: An Effective Theory of Representation Learning". NeurIPS 35 (2022); arXiv:2205.10343 (pages not confirmed) | effective theory plus phase diagrams; four phases; a "Goldilocks zone" | remark (grokking only) |
| `liu2023omnigrok` | Liu, Michaud, Tegmark. "Omnigrok: Grokking Beyond Algorithmic Data". ICLR 2023; arXiv:2210.01117 | "LU mechanism" explains data-size and weight-decay dependence and the emergence of representations; induces grokking on image, language and molecule tasks and eliminates it on algorithmic data. Body, via search excerpt: constant weight norm largely eliminates grokking (L1) | remark |
| `varma2023explaining` | Varma, Shah, Kenton, Kramár, Kumar. "Explaining grokking through circuit efficiency". arXiv:2309.02390 (5 Sep 2023) | generalising circuit slower to learn but more efficient; memorising circuits lose efficiency with dataset size; critical dataset size; ungrokking, semi-grokking | notes only |
| `mackay1992practical` | MacKay. "A Practical Bayesian Framework for Backpropagation Networks". Neural Computation 4(3):448–472, 1992; doi 10.1162/neco.1992.4.3.448 | Bayesian framework for feedforward networks; objective choice of weight-decay terms; evidence embodies Occam's razor | remark (Gaussian-prior reading only; the precision nω is derived here, m8) |
| `hinton1993keeping` | Hinton, van Camp. "Keeping the Neural Networks Simple by Minimizing the Description Length of the Weights". COLT '93, pp. 5–13, ACM; doi 10.1145/168304.168306 | networks generalise when the weights carry much less information than the outputs; information in a weight controlled by adapted Gaussian noise | remark; §4.4 item 1 |
| `vanlaarhoven2017l2` | van Laarhoven. "L2 Regularization versus Batch and Weight Normalization". arXiv:1706.05350 (16 Jun 2017) | with normalisation L2 has no regularising effect; it influences the weight scale and hence the effective learning rate; Adam only partly removes this | remark; §4.4 item 1 |
| `xie2024implicit` | Xie, Li. "Implicit Bias of AdamW: ℓ∞-Norm Constrained Optimization". ICML 2024, PMLR 235:54488–54510; arXiv:2404.04454 | full batch: if AdamW converges under a non-increasing schedule with divergent partial sums, the limit is a KKT point of the loss under an ℓ∞-norm constraint | remark; appendix example; §4.4 item 3 |
| `dangelo2024why` | D'Angelo, Andriushchenko, Varre, Flammarion. "Why Do We Need Weight Decay in Modern Deep Learning?". NeurIPS 37 (2024); doi 10.52202/079017-0730; arXiv:2310.04415 (pages not confirmed; arXiv v1 lists Andriushchenko first) | role differs from classical explicit regularisation: vision with multipass SGD, loss stabilisation; LLMs, bias–variance balance | §4.4 item 5 |
| `mandt2017stochastic` | Mandt, Hoffman, Blei. "Stochastic Gradient Descent as Approximate Bayesian Inference". JMLR 18(134):1–35, 2017 | constant-step SGD simulates a Markov chain with a stationary distribution; can be tuned to approximate a posterior | remark; §4.4 item 2 |
| `zhang2017understanding` | Zhang, Bengio, Hardt, Recht, Vinyals. "Understanding Deep Learning Requires Rethinking Generalization". ICLR 2017; arXiv:1611.03530 | CNNs trained with stochastic gradient methods easily fit random labels; "qualitatively unaffected by explicit regularization"; also with random-noise inputs. Weight decay specifics: body / poster, via search excerpt (L2) | §4.4 item 5 |
| `arpit2017closer` | Arpit et al. (eleven authors). "A Closer Look at Memorization in Deep Networks". ICML 2017, PMLR 70:233–242 | DNNs can memorise noise but learn simple patterns first; tuned explicit regularisation (e.g. dropout) can degrade training on noise without hurting real-data generalisation | §4.4 item 5 |

**Generalised and tempered posteriors already in Paper 2.** The bibliographic data agree with `paper-steeper/bib/all.bib` (checked for `notes.md` and again by the referee).

| key | confirmed | abstract-level content relevant here |
|---|---|---|
| `zhang2006epsilon` | Ann. Statist. 34(5):2180–2210, 2006; doi 10.1214/009053606000000704 | information-theoretic inequality for deterministic and randomised density estimators; improves results on MDL and posterior convergence |
| `bissiri2016general` | JRSS B 78(5):1103–1130, 2016; doi 10.1111/rssb.12158 | updates a prior through a loss instead of a likelihood; Bayes' rule is the self-information-loss case. Remark 1.2's per-sample update is a loss-based update in this sense, from an improper flat start |
| `bhattacharya2019fractional` | Ann. Statist. 47(1):39–66, 2019; doi 10.1214/18-AOS1712 | likelihood raised to a fractional power; contraction under misspecification with only a prior-mass condition; PAC-Bayes oracle inequality |
| `grunwald2012safe` | ALT 2012, LNCS 7568:169–183; doi 10.1007/978-3-642-34106-9_16 | learns the learning rate from data, for wrong models |
| `grunwald2017inconsistency` | Bayesian Analysis 12(4):1069–1103, 2017; doi 10.1214/17-BA1085 | Bayes inconsistent under misspecification in linear regression; hypercompression; SafeBayes picks small learning rates |
| `wenzel2020good` | ICML 2020, PMLR 119:10248–10259 | the Bayes posterior predictive is worse than SGD point estimates; cold posteriors help |
| `grunwald2007suboptimal` | Machine Learning 66:119–149, 2007; doi 10.1007/s10994-007-0716-7 | Bayes and MDL classifiers can keep an error bounded away from the optimum under misspecification |
| `zhu2025quantifying` | COLT 2025, PMLR 291:6124–6155; arXiv:2503.02110 | full regularisation curve of a modified two-part MDL rule; worst-case limiting error as a function of λ and the noise level |
| `zhu2026overfitting` | arXiv:2603.22644 (23 Mar 2026), Zhu, Ohannessian, Srebro | PAC-Bayes-type rule balancing training error and KL to a prior; λ = 1 overfits; λ ≫ 1, described in two independent search paraphrases as a sample-size-dependent prior, gives vanishing excess loss even agnostically (verbatim wording not seen) |
| `barron1991minimum` | IEEE Trans. Inf. Theory 37(4):1034–1054, 1991; doi 10.1109/18.86996 | the index of resolvability, which bounds convergence rates of minimum-complexity estimators (referee, via Cover's page and a secondary source); a correction to eq. (1.3) appeared in 37(6), which Paper 2 does not quote |

**Relation of the tempered-posterior literature to λ = cn** [remark].
* In the generalised-posterior references the learning rate η of $\Pi^\eta\propto\text{prior}\times\text{likelihood}^\eta$ is fixed or learned from data.
* λ = cn corresponds, through `lem:setup:basic`(ii), to η = 1/(cn), a learning rate decaying like 1/n. Then $\Pi^\eta$ converges to a fixed Gibbs measure instead of concentrating (Remark 1.3).
* Cold posteriors keep the prior-to-likelihood ratio of λ = 1 (`rem:related:cold`), so they are not this.

---

## 6. Draft text for the paper

**Placement.**
* (a) A main-text remark `rem:teacher:weightdecay` in `teacher.tex`, directly after `rem:limits:schedule`, which already discusses fixed λ against λ ∝ n and the batch excess.
* (b) An appendix subsection `app:teacher:weightdecay` at the end of `app-teacher.tex`, with `prop:teacher:nofixedprior` and `ex:teacher:weightdecay`.
* (c) One sentence in `related.tex`, paragraph on generalised posteriors and two-part codes, after the sentence ending `\label{rem:related:cold}`.
* (d) `refs.bib` merged into Paper 2's bibliography (as `bib/decay.bib`, which `merge_bib.py` picks up).

All labels are new. No existing label or statement changes (REFRAME §8). The text presents the material as new and does not mention the author's notes.

**Changes from the draft of `notes.md`.**
* Remark, first paragraph: "no fixed prior" → "no fixed prior with full support" (M1); the repetition clause now states Proposition 2.2(i) and that $\Hcl{\times}$ has such samples (M2); the teacher sentence now says $c>c^*$ on the window outside a band of at most 1.2 % (A1).
* Remark, second paragraph: MacKay cited for the Gaussian-prior reading only (m8).
* Proposition: (ii) gains the clause "nor does any fixed prior if…" (Prop 2.2(v)) and "by Kraft's inequality" (m4); new part (iv) (Proposition 3.2).
* After the proof: one paragraph on full support (Example 2.4, Example 2.6) and the size of the band.
* Weight-decay paragraph: "stationary points of" (m3); one sentence on kinks (Proposition 4.2(iii) and the $|\theta-1|$ example).
* Example: $q<\frac12$ stated; the case $\varepsilon^2\ge1-2q$ (A3); the box threshold in closed form with the (0.8, 0.2) contrast (A2, d3(D3)); proof idea extended accordingly.

**Build check** (a scratch copy of `paper-steeper/` in the session scratchpad, built with its own `build.sh`):
* Unmodified: 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes over 10pt, 74 pages.
* With (a)–(d): the same zeros, 78 pages.
  * The remark is Remark 8.5 on p. 26, about 33 lines (≈ 0.6 page).
  * The appendix subsection is F.8, from p. 70 to p. 72, about 1.7 pages.
  * The bibliography grows by 15 entries (41 → 56 in the merged file).
  * Appendix A moves from p. 37 to p. 39: main text plus references grow by 2 pages.

**Options to save space.**
* Drop the last sentence of the remark (grokking), about 3 lines.
* Drop the paragraph after the proof (full support, the band), about 6 lines; part (iv) of the proposition stands without it.
* Drop the AdamW sentence of the example and the box part of the proof idea, about 5 lines.
* Drop the kink sentence of the weight-decay paragraph, about 3 lines.

### 6.1 Main-text remark (for `teacher.tex`, after `rem:limits:schedule`)

```latex
\begin{remark}[$\lambda=cn$ and weight decay]\status{proved; computed; known}\src{imitation/decay notes-final \S\S1--4, Props 2.1--2.3, 3.2, Example 4.3; checks d1, d2, d3}\label{rem:teacher:weightdecay}
With $\lambda=cn$ the length is charged once per sample: $2^{-cn\ell(\pi)}\nu_\pi(h_n)=\prod_{i\le n}2^{-c\ell(\pi)}\nu_\pi(y_i\mid x_i)$. A fixed $\lambda$ is the fixed prior $2^{-\lambda\ell}$, but no fixed prior with full support gives the $cn$-MAPs at every $n$. The $cn$-MAPs depend on the sample only through its empirical distribution, whereas under such a prior a program that fits a sample worse than another program stops being a MAP once the sample is repeated often enough; in $\Hcl{\times}$, for every $c>0$, some samples have only such $cn$-MAPs. Per query, for $c>c^*$ the $cn$-MAPs end at shorter programs that predict worse, whereas the MAPs of every summable prior that charges $\mathcal E$ end in $\mathcal E$ (\cref{prop:teacher:nofixedprior}). The window of \cref{thm:teacher:main} is an instance: there $c>c^*$, except in a band of relative width at most $1.2\%$ above $2^{-m}$ at the example's sizes, so the $cn$-MAPs eventually do not reproduce the teacher's labels, while every summable prior that charges a program reproducing them eventually selects such a program.

Weight decay has the same form. With the loss averaged over $n$ samples, gradient descent with weight-decay coefficient $\omega$ descends $\hat L_n(\theta)+\frac\omega2\|\theta\|^2$, and $n$ times this is, up to a constant, the negative log posterior under a Gaussian prior \citep{mackay1992practical} with precision $n\omega$, which grows linearly in $n$ like the exponent of $2^{-cn\ell}$; a fixed prior needs $\omega\propto1/n$. In the limit the minimiser of $L(\theta)+\frac\omega2\|\theta\|^2$ minimises the population loss $L$ only if $\theta=0$ does, and it can classify worse (\cref{ex:teacher:weightdecay}). In both cases the penalty per sample does not vanish with the data. Discarding a component whose risk reduction per unit of complexity is small requires this (\cref{prop:limits:separable}), and every $\lambda_n=o(n)$ eventually learns the errors (\cref{prop:teacher:schedules}(a)).

The analogy is one of objectives. $\|\theta\|^2$ is not a description length: coding weights needs a precision \citep{hinton1993keeping}, and with normalisation layers the norm mainly sets the effective learning rate \citep{vanlaarhoven2017l2}. Stochastic gradient iterates are not minimisers \citep{mandt2017stochastic}; decoupled weight decay in adaptive optimisers is not an $L_2$ penalty \citep{loshchilov2019decoupled,xie2024implicit}; and the decay acts per step, so before convergence its effect depends on the learning rate and the number of steps. Grokking \citep{power2022grokking,liu2022towards} has been related to the weight norm and to weight decay \citep{liu2023omnigrok}, and analysed as memorisation followed by a cleanup that removes memorising components \citep{nanda2023progress}.
\end{remark}
```

### 6.2 Appendix subsection (for the end of `app-teacher.tex`)

```latex
\subsection{\texorpdfstring{$\lambda=cn$}{lambda=cn} and weight decay}\label{app:teacher:weightdecay}

A \emph{fixed prior} is a map $w$ from programs to $[0,\infty)$ chosen before the data; its MAPs on a per-query sample $h$ maximise $w(\pi)\nu_\pi(h)$. For $\lambda\ge1$ the $\lambda$-MAPs are the MAPs of the fixed prior $2^{-\lambda\ell}$. Write $h^r$ for the sample $h$ repeated $r$ times.

\begin{proposition}[No fixed prior gives the $cn$-MAPs]\status{proved; computed}\src{imitation/decay notes-final Props 2.1--2.3, 3.2; checks d1, d3}\label{prop:teacher:nofixedprior}
Let $c>0$, and let the class be countable, with Kraft weights and kernels, as in \cref{def:split:setting}.
\begin{enumerate}[label=(\roman*),itemsep=0pt,topsep=2pt]
\item If samples $h$ and $h'$ of sizes $n$ and $n'$ have the same empirical distribution, the $cn$-MAPs of $h$ are the $cn'$-MAPs of $h'$.
\item Let $h$ have size $n_0$, let $\pi^*$ attain $P^*:=\max_\pi\nu_\pi(h)>0$, and let no $cn_0$-MAP of $h$ attain $P^*$. If $w(\pi^*)>0$, then for every $r>\max_{\hat\pi}\log\frac{w(\hat\pi)}{w(\pi^*)}\big/\log\frac{P^*}{\nu_{\hat\pi}(h)}$, the maximum over the $cn_0$-MAPs $\hat\pi$ of $h$ with $w(\hat\pi)>0$ (and every $r\ge1$ if there are none), no $crn_0$-MAP of $h^r$ is a MAP of $w$ on $h^r$. So no fixed prior with full support gives the $cn$-MAPs on all samples; nor does any fixed prior if $\pi^*$ is a $cn$-MAP of some sample whose $cn$-MAPs are not all programs. In $\Hcl{\times}$ samples as in (ii) exist for every $c>0$.
\item Per query, let $\mathcal E\ne\emptyset$ and let $w$ be summable with $w(\pi)>0$ for some $\pi\in\mathcal E$. Almost surely, for all large $n$, the MAPs of $w$ are the programs of $\mathcal E$ of largest weight. If $c>c^*$ (\cref{prop:recovery:beyond}), almost surely for all large $n$ no $cn$-MAP lies in $\mathcal E$, and every minimiser $\pi$ of $c\,\ell+R_\nu$ has $\ell(\pi)<\ell_0$ and $R_\nu(\pi)>R_\nu(\pi_0)$ for $\pi_0\in\mathcal E_0$. If $c<c^*$, the $cn$-MAPs and the MAPs of $2^{-\ell}$ are both eventually $\mathcal E_0$.
\item In the instance of \cref{def:teacher:instance}, with PQ data $\nu=\delta_{y^*}$, inputs uniform on $\{0,1\}^d$ and $B=\infty$, let $c_+:=H(p)/(B_S-4-\Lambda_1-\kappa_g)$, the denominator being positive. Every $c\in(\max\{2^{-m},c_+\},c_{\rm hi})$ has $c>c^*$.
\end{enumerate}
\end{proposition}

\begin{proof}
(i) $J_{cn}(\pi;h)/n=c\,\ell(\pi)+\Ex_{\hat P_h}[-\log\nu_\pi(y\mid x)]$ depends on $h$ only through its empirical distribution $\hat P_h$. (ii) By (i) the $crn_0$-MAPs of $h^r$ are the $cn_0$-MAPs $\hat\pi$ of $h$; they are finitely many (\cref{lem:setup:basic}), with $0<\nu_{\hat\pi}(h)<P^*$, and $w(\hat\pi)\nu_{\hat\pi}(h)^r<w(\pi^*)(P^*)^r$ for the stated $r$. A prior $w$ whose MAPs on the sample where $\pi^*$ is a $cn$-MAP are these $cn$-MAPs has $w(\pi^*)>0$: otherwise every program would have score $0$ there and be a MAP. In $\Hcl{\times}$ take $n_0$ distinct inputs whose labels $y$ have $K(y\mid\dom D)\ge n_0\log|Y|$, which exist by Kraft's inequality, with $n_0\log|Y|-\kappa-\ell_{\rm u}>\log|Y|/c$, where $\ell_{\rm u}$ is the length of a program for the uniform kernel: a lookup program attains $P^*=1$, and by \cref{lem:setup:coding} every program of likelihood $1$ has $J_{cn_0}\ge cn_0(n_0\log|Y|-\kappa)>cn_0\ell_{\rm u}+n_0\log|Y|$, the uniform kernel's value. (iii) Let $W:=\max_{\mathcal E}w$. Almost surely $\nu_\pi(h_n)=\nu(h_n)>0$ for all $\pi\in\mathcal E$ and all $n$, so a MAP $\hat\pi$ of $w$ has $w(\hat\pi)\Lambda_n(\hat\pi)\ge W$. For a cofinite set $T$ of programs, $\sum_{\pi\in T}w(\pi)\Lambda_n(\pi)$ is a nonnegative supermartingale started at $w(T)$ (\cref{lem:recovery:ratios}(a)), so by Ville's inequality some MAP lies in $T$ at some $n$ with probability at most $w(T)/W$, which tends to $0$ along cofinite sets decreasing to $\emptyset$. Of the finitely many other programs, those outside $\mathcal E$ have $\Lambda_n\to0$ almost surely (\cref{lem:recovery:ratios}(c)), and those of $\mathcal E$ with $w<W$ are never MAPs. For $c>c^*$ some $\pi'$ with $\ell(\pi')<\ell_0$ has $J_c(\pi')<J_c(\pi_0)\le J_c(\pi)$ for all $\pi\in\mathcal E$, and $J_c(\pi)>J_c(\pi_0)$ for $\pi\notin\mathcal E$ with $\ell(\pi)\ge\ell_0$; so the minimisers of $J_c$ are shorter than $\ell_0$ and lie outside $\mathcal E$, where $\KL_\mu>0$, and \cref{prop:recovery:beyond}(c) puts every $cn$-MAP among them for all large $n$. For $c<c^*$ use \cref{prop:recovery:beyond}(c) and the first part with $w=2^{-\ell}$. (iv) Here $\mathcal E$ is the set of programs with $R=0$; it contains the memoriser. Let $\pi$ minimise $J_c$, so $J_c(\pi)=\Phi(c)$. As $c2^m>1$ and $J_g(c)<\Phi_2(c)$ on $(0,c_{\rm hi})$, \cref{thm:teacher:main}(ii)(b) with $\epsilon=0$ gives $R(\pi)\ge H(p)-c\Lambda_2/(c2^m-1)$, which is positive for $c>c_+$ because $2^mH(p)-\Lambda_2=B_S-4-\Lambda_1-\kappa_g$. So no minimiser of $J_c$ lies in $\mathcal E$. For $c<c^*$ the minimisers are $\mathcal E_0$ (\cref{prop:recovery:beyond}(c)); at $c=c^*$ the programs of $\mathcal E_0$ are minimisers, since $J_c(\pi)-J_c(\pi_0)=\KL_\mu(\pi)-c^*(\ell_0-\ell(\pi))\ge0$ when $\ell(\pi)<\ell_0$. Hence $c>c^*$.
\end{proof}

Full support cannot be dropped from (ii) in general: in the class of a coin of length $1$ and a deterministic $f$ of length $1+k$, for $ck>1$ the coin is the only $cn$-MAP on every sample, and it is also the only MAP of the prior concentrated on it. With two programs that give the label $1$ probability $\frac12$ and $\frac14$ at every input, of lengths $1$ and $1+k$, the last clause of (ii) applies for every $0<ck<\log\frac32$, and a direct computation (code in the accompanying repository) finds at $ck=0.3$ no fixed prior whose MAPs are the $cn$-MAPs even on the samples of size at most $4$. At the example's sizes $c_+$ exceeds $2^{-m}$ by $0.45\%$ to $1.2\%$ ($\kappa\in\{0,30\}$, $\delta_S\in\{0,20\}$).

\emph{Weight decay.} For a per-sample loss $f(\theta;z)$ let $\hat L_n:=\frac1n\sum_{i\le n}f(\cdot\,;z_i)$ and $L:=\Ex f(\cdot\,;z)$. A step $\theta\leftarrow\theta-\eta(\nabla\hat L_B(\theta)+\omega\theta)$ on a uniformly drawn minibatch $B$ is a stochastic gradient step on $F_n:=\hat L_n+\frac\omega2\|\theta\|^2$; with full batches its fixed points are the stationary points of $F_n$, for every $\eta$. If $f=-\ln p_\theta(y\mid x)$, then $nF_n(\theta)=-\ln\big(p_\theta(y_{1:n}\mid x_{1:n})\,e^{-n\omega\|\theta\|^2/2}\big)$. As in (i), the minimisers of $F_n$ depend on the sample only through its empirical distribution. If $\theta^*$ minimises $F:=L+\frac\omega2\|\theta\|^2$ and $L$ is differentiable, then $\nabla L(\theta^*)=-\omega\theta^*$, so $\theta^*$ is a stationary point of $L$ only if $\theta^*=0$; and $L(\theta^*)-L(\theta)\le\frac\omega2(\|\theta\|^2-\|\theta^*\|^2)$ for every $\theta$, the analogue of $R_\nu(\pi_c)-R_\nu(\pi)\le c(\ell(\pi)-\ell(\pi_c))$ for a minimiser $\pi_c$ of $J_c$. Unlike a vertex of the hull, a point $\theta\ne0$ is stationary for $L+\frac\omega2\|\theta\|^2$ at one value of $\omega$ at most when $L$ is differentiable; without differentiability it can be selected on an interval ($L(\theta)=|\theta-1|$ selects $\theta=1$ for every $\omega\in(0,1]$). If the decay is not multiplied by the learning rate $\alpha$ of the loss, $\theta\leftarrow\theta-\eta_t(\alpha\nabla L(\theta)+\lambda\theta)$, the fixed points are the stationary points of $L+\frac{\lambda}{2\alpha}\|\theta\|^2$: the effective coefficient then depends on $\alpha$.

\begin{example}[A worse classifier in the limit]\status{proved; computed}\src{imitation/decay notes-final Example 4.3; checks d2(A)--(D), d3(D)}\label{ex:teacher:weightdecay}
Let $y$ be uniform on $\{\pm1\}$, $\xi=1$ with probability $1-q$ and $\xi=-1$ otherwise, independently, $q<\frac12$, $x=(\varepsilon y,\xi y)$ and $p_\theta(y\mid x)=\sigma(y\,\theta\cdot x)$. The first feature separates the classes, at scale $\varepsilon$; $\inf L=0$ is approached only by classifiers of error rate $0$. If $\varepsilon^2<1-2q$, the minimiser of $F$ has error rate $0$ for $\omega<\omega^*$ and $q$ for $\omega\ge\omega^*$ (a tie counted as an error), where
\[
\omega^*=\frac{2q\varepsilon^2}{(1-\varepsilon^2)\,a^*},\qquad a^*=\ln\frac{2(1-q)(1-\varepsilon^2)-q(1+\varepsilon^2)}{q(1+\varepsilon^2)};
\]
if $\varepsilon^2\ge1-2q$, it has error rate $0$ for every $\omega>0$. At $\varepsilon=0.1$ and $q=0.2$, $\omega^*=2.101\cdot10^{-3}$. A direct computation (code in the accompanying repository) finds the empirical minimisers with $\omega=0.01$ at error rate $0.2$ in all of 20 samples for each $n\in\{10^2,10^3,\dots,10^6\}$, and with $\omega=1/n$, the fixed prior $\mathcal N(0,I)$, at error rate $0$ in all of 20 for each $n\ge10^3$; minibatch gradient descent reaches the same regimes. Full-batch AdamW with decoupled coefficient $\lambda$ ends near the minimiser of $L$ under $\|\theta\|_\infty\le1/\lambda$ \citep{xie2024implicit}, whose error rate is $q$ exactly when $\lambda\ge2\varepsilon/\ln((2-3q)/q)$, for every $\varepsilon\le1$: at $\varepsilon=0.1$, $q=0.2$ this is $\lambda\ge0.103$, and at $\varepsilon=0.8$, $q=0.2$, where $L_2$ decay never switches, AdamW switches at $\lambda=0.822$.
\end{example}

\emph{Proof idea.} With $a:=\varepsilon\theta_1+\theta_2$, $b:=\varepsilon\theta_1-\theta_2$, the error rate is $(1-q)[a\le0]+q[b\le0]$. The stationarity equations of the strictly convex $F$ give $\theta_1,\theta_2>0$, so the error rate is $q[b\le0]$. At $b=0$ they force $(1-q)(1-\varepsilon^2)\sigma(-a)=\frac q2(1+\varepsilon^2)$. If $\varepsilon^2\ge1-2q$ this is impossible: for $\varepsilon\ge1$ the left side is not positive, and otherwise it needs $\sigma(-a)\ge\frac12$, against $a=2\theta_2>0$. If $\varepsilon^2<1-2q$ it fixes $a=a^*$ and $\omega=\omega^*$. As $b$ is continuous in $\omega$ and $b>0$ for $\omega\le\varepsilon^2q/\ln((2-3q)/q)$, and $\omega\,b\to(\varepsilon^2-(1-2q))/2$ as $\omega\to\infty$, the claim follows. Under the box, $\theta_1=1/\lambda$ because $\partial L/\partial\theta_1<0$, and for $\varepsilon\le1$ the error rate is $q$ iff $\partial L/\partial\theta_2\le0$ at $\theta_2=\varepsilon/\lambda$, that is iff $(1-q)\sigma(-2\varepsilon/\lambda)\ge q/2$.
```

Notes on the draft.
* "Ends near" for AdamW is what d2(D) shows for $\lambda_W\ge0.01$ at (0.1, 0.2) and d3(D3) at (0.8, 0.2) and (0.7, 0.3). The thresholds 0.103 and 0.822 are those of the box problem, in closed form.
* "Minibatch gradient descent reaches the same regimes" rests on d2(C), two runs at $n=10^4$ (ω = 0.01 and ω = 1/n).
* "At $ck=0.3$ no fixed prior … even on the samples of size at most 4" is d3(B2).
* "$c_+$ exceeds $2^{-m}$ by 0.45 % to 1.2 %" is d3(C) (and rd1(C)).
* If the paper prefers, the remark can cite `\cref{app:teacher:weightdecay}` instead of the proposition and example labels.

### 6.3 Related-work sentence (for `related.tex`, after the sentence ending `\label{rem:related:cold}`)

```latex
With $\lambda=cn$ the prior changes with the sample size, as the Gaussian prior implicit in weight decay does (\cref{rem:teacher:weightdecay}); \citet{zhu2026overfitting} likewise read a large complexity weight in a PAC-Bayes rule as a sample-size-dependent prior.
```

The second clause rests on two independent search paraphrases of the abstract of `zhu2026overfitting` (§5); the referee advised keeping it with the verb "read". Drop it if the verbatim abstract does not support it.

### 6.4 What the draft claims and where each claim is proved

| claim in the draft | source |
|---|---|
| prior factor once per sample (product formula) | Remark 1.2 [proved] |
| fixed λ = fixed prior | Remark 1.4 [proved] |
| no fixed prior with full support gives the cn-MAPs; empirical distribution; a worse-fitting program stops being a MAP on repetitions; such samples in $\Hcl{\times}$ | Props 2.1, 2.2(i)–(iii) [proved; computed d1(A)] |
| no fixed prior at all under the condition of (ii); the two-rate example at ck = 0.3 | Prop 2.2(v), Example 2.6 [proved; computed d3(B2)] |
| full support cannot be dropped (coin / f, ck > 1) | Example 2.4 [proved; computed d3(B1), rd1(A)] |
| per query, c > c*: shorter and worse, against $\mathcal E$ for summable priors | Prop 2.3 [proved; computed d1(C)] |
| teacher window: c > c* above $c_+$; band 0.45–1.2 %; no reproduction of the teacher's labels; priors charging a risk-0 program select one | Prop 3.2 [proved; computed d3(C)]; Prop 2.3(i) with ν = δ_{y*} [proved] |
| weight decay = average loss + (ω/2)‖θ‖²; Gaussian prior with precision nω | Prop 4.1 [proved]; MacKay 1992 for the Gaussian-prior reading [known, abstract] |
| the limit minimises L only if 0 does; excess bound; no kinks for differentiable L; the $\lvert\theta-1\rvert$ example | Prop 4.2 [proved; computed d2(A), d3(E)] |
| toy: ω*, the condition ε² < 1 − 2q, the finite-n numbers, the box threshold | Example 4.3 [proved; computed d2, d3(D)] |
| per-sample penalty needed against small-rate components; o(n) learns the errors | `prop:limits:separable`, `prop:teacher:schedules`(a) [proved in Paper 2] |
| limits: norm not a code length; normalisation; SGD; AdamW; per step | §4.4 [known, abstract level; computed d2(D),(E)] |
| grokking sentence | Power, Liu 2022, Liu 2023, Nanda [known, abstract level] |

---

## 7. Claims and statuses

| id | claim | status |
|---|---|---|
| D1 | $J_{cn}/n=c\ell+\hat R_n\to c\ell+R_\nu$; cn-MAPs eventually in $A_c$ | proved (Paper 2) |
| D2 | $\Pi_{cn}$ multiplies by $2^{-c\ell}$ at every sample (recursion); general schedules by $2^{-(\lambda_n-\lambda_{n-1})\ell}$ | proved; computed d1(E) |
| D3 | tempered posterior with η = 1/(cn) → fixed Gibbs measure $2^{-\ell-R/c}/Z$ | proved; computed d1(D); fluctuation order heuristic |
| D4 | fixed λ is MAP/Bayes for the fixed prior $2^{-\lambda\ell}$ | proved |
| D5 | cn-MAPs depend only on the empirical distribution (duplication invariance) | proved; computed d1(A) |
| D6 | no fixed prior with full support gives the cn-MAPs on all samples, whenever some sample's cn-MAPs miss maximum likelihood; such samples exist in $\Hcl{\times}$ for every c > 0 | proved; computed d1(A) |
| D6a | summable prior with $w(\pi^*)>0$: for all large r every MAP on $h^r$ attains $P^*$ | proved; computed d3(A1) |
| D6b | condition under which no fixed prior at all gives the cn-MAPs; two-rate class, every 0 < ck < log(3/2) | proved; computed d3(B2) |
| D6c | full support needed: δ_coin gives the cn-MAPs in Example 2.4 for ck > 1; degenerate prior in $\Hcl{\times}$ for some machines and c > log\|Y\| | proved; computed d3(B1), rd1(A) |
| D7 | per query: summable prior charging $\mathcal E$ ends in $\arg\max_{\mathcal E}w$; for c > c* the cn-MAPs eventually avoid $\mathcal E$ and are shorter and worse; for c < c* both end in $\mathcal E_0$; priors not charging $\mathcal E$ can agree eventually | proved; computed d1(C) |
| D8 | two-program example: coin kept forever iff ck > 1; fixed λ switches at n > λk | proved; computed d1(B) |
| D9 | schedules with $\lambda_n/n\to c>0$ are not fixed-prior rules either; no vertex-interval condition needed | proved; computed d3(G) |
| D10 | "the cn-MAP differs eventually from every fixed-prior MAP on typical data for every c" | **refuted** (R1: c < c*, d1(C); Remark 2.8(b)) |
| D10a | "no fixed prior gives the cn-MAPs at every n" (no support condition) | **refuted** (R2: Example 2.4, d3(B1); Remark 2.8(a)) |
| D10b | "under a fixed prior with full support only ML programs stay MAPs on repetitions" | **refuted as worded** (R3: Example 2.7, d3(A2)); true for summable priors (D6a) |
| D11 | coupled SGD weight decay = SGD on $\hat L_n+\frac\omega2\|\theta\|^2$; MAP under $\mathcal N(0,(n\omega)^{-1}I)$ | proved |
| D12 | population minimiser of $L+\frac\omega2\|\theta\|^2$ minimises L only if 0 does; excess bound; for differentiable L each θ ≠ 0 is stationary at one ω at most | proved; computed d2(A), d3(E2) |
| D12a | "the structure function of convex L is convex, so it has no vertices" | **refuted** (R4: $L=\lvert\theta-1\rvert$, d3(E1)) |
| D13 | toy: error 0 below ω*, q at and above ω*, closed form for ω*, when ε² < 1 − 2q; error 0 at every ω iff ε² ≥ 1 − 2q | proved; computed d2(A), d3(D2) |
| D14 | toy, finite n: fixed ω = 0.01 keeps error 0.2 up to n = 10⁶; ω = 1/n reaches 0 from n = 10³ | computed d2(B) |
| D15 | toy: SGD with coupled decay lands at the empirical minimiser's regime | computed d2(C) |
| D16 | toy: AdamW limit ≈ ℓ∞-box minimiser; box threshold $2\varepsilon/\ln((2-3q)/q)$ (0.103 vs ω* = 0.0021 at (0.1, 0.2)); AdamW switches where L2 never does | proved (box); computed d2(D), d3(D1), d3(D3) |
| D17 | SGDW-style fixed points are the stationary points of $L+\frac{\lambda}{2\alpha}\|\theta\|^2$; before convergence the iterate depends on ηT; early stopping can change the classifier | proved (fixed points); computed d2(E) |
| D18 | weight decay is not a description length; deep nets fit random labels under explicit regularisation; WD acts through dynamics | known, abstract level (weight-decay specifics of Zhang et al.: body / poster, via search excerpt) |
| D19 | grokking literature as summarised in §4.4 item 6 | known, abstract level; L1, L4 body via search excerpt; L3 not reconfirmed |
| D20 | literature entries of `refs.bib` | verified by WebSearch (fields not confirmed are omitted) |
| D21 | teacher window: c > c* for c ∈ (max{2⁻ᵐ, c₊}, c_hi); c₊/2⁻ᵐ = 1.0045–1.0114 at the example's sizes | proved; computed d3(C), rd1(C) |
| D22 | the sampler's randomised error in d1(C) is 0.18, its argmax error 0.1 | computed d3(F) |

---

## 8. Open points

1. Non-constant schedules $\lambda_n=o(n)$: for which classes is the MAP rule a fixed-prior MAP rule at every finite $n$ (Remark 2.5(b))? Not pursued [open].
2. A weight-decay analogue of the kink geometry [open]. The statement of `notes.md`, "the structure function $\rho\mapsto\min\{L(\theta):\|\theta\|^2\le\rho\}$ is convex for convex $L$, so it has no vertices", is **refuted** (R4, §4.2). What is true: for differentiable $L$ no point $\theta\ne0$ is selected on an interval of ω (Proposition 4.2(iii)); for non-differentiable $L$ points can be (the $|\theta-1|$ example). Is there a useful kink theory for networks with piecewise-linear losses or activations, where such intervals can occur?
3. Whether the "cleanup" phase of grokking under fixed weight decay is the dynamical counterpart of λ = cn discarding components of rate below c, as against a fixed prior discarding only components that do not improve the fit [heuristic; not checked].
4. In $\Hcl{\times}$ with a fixed reference machine and small $c$, does the condition of Proposition 2.2(v) hold, so that no fixed prior at all gives the $cn$-MAPs? For some machines and $c>\log|Y|$ a degenerate prior does (Remark 2.8(a)) [open].
5. Confirm with the author the reading of "as the number of params varies" (header). Under either reading the conclusion is the same [remark].

---

## References

BibTeX entries for every source of §5 not already in Paper 2's bibliography are in `refs.bib` (unchanged in this revision). Paper 2 labels are cited as written.

---

## Verification log

* **2026-10-14, reading.**
  * The brief; `notes.md`, `refs.bib`, `referee.md`, `referee-checks/rd1_referee.py` and its output, in full.
  * Paper 2 sections as listed under "Sources read". Every Paper 2 label cited here or in the draft was found: `lem:recovery:ratios`, `prop:recovery:beyond`, `def:split:setting`, `lem:setup:basic`, `lem:setup:coding`, `lem:setup:hull`, `rem:setup:persample`, `lem:teacher:reuse`, `prop:teacher:schedules`, `rem:limits:schedule`, `thm:teacher:main`, `rem:teacher:numbers`, `tab:teacher:numbers`, `def:teacher:instance`, `prop:limits:separable`, `rem:related:cold`.
* **Referee items, checked again before accepting them.**
  * M1 and A4: the counterexample was redone by exact feasibility over all priors (d3(B1)); the $\Hcl{\times}$ remark was turned into a proof under a stated machine assumption (Remark 2.8(a)).
  * M2: the summable proof was checked, including existence of MAPs; the non-summable case was found false by construction (Example 2.7), which the referee had not considered.
  * A1: each step of the proof was checked against the statement of `thm:teacher:main`(ii) (hypotheses $c2^m>1$, $J_g(c)+\epsilon<\Phi_2(c)$, and that (ii) covers every π with $J_c(\pi)\le\Phi(c)+\epsilon$), against the definition of $\Lambda_2$, and against `prop:recovery:beyond`(c) for $c<c^*$; the case $c=c^*$ was checked directly. The constants were taken from `def:teacher:instance` ($\Lambda_1$ at $B=\infty$; $\kappa_g=2\log d+2\log r+\kappa$ for $p=2^{-r}$) and the numbers recomputed (d3(C)); they agree with rd1(C) to all printed digits.
  * A2 and A3: proofs redone. For A3 the case ε ≥ 1 was added (the switch equation has no solution). For A2 the referee's argument uses $\varepsilon B<B$, i.e. ε < 1; here the statement is restricted to ε ≤ 1, and for ε > 1 the box minimiser has error 0 at every λ (Example 4.3(e)).
  * m2: the counterexample was verified (d3(E1)); the replacement statement (Prop 4.2(iii)) is simpler than the referee's suggestion about the value function and implies it for the selected points.
  * Remark 2.5(a): the simplification was proved from `lem:setup:hull`(v) and computed at breakpoints (d3(G)).
* **Reruns of the earlier checks.** `d1_no_fixed_prior.py` and `d2_weight_decay.py` were copied to the session scratchpad and run (Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1; 1.8 s and 1 min 36 s). `diff` against the saved outputs is empty for both.
* **d3_revision.py** (6 s).
  * Before the first run, part (G) was changed to use only kernel values that are powers of two (one entry of 3/4 was removed and the hull test made exact), so that all fits are integers and the breakpoint MAP sets are computed exactly. No run was made before this change.
  * *First run* (in the scratchpad): all parts as quoted in §§2–4. No numbers needed correcting.
  * *Saved run* (in `checks/`): byte-identical to the first.
  * Results not quoted above: none of note; the full output is `checks/d3_revision.out`.
* **Literature, this revision.** 6 WebSearch queries:
  * Omnigrok, constant weight norm: the excerpt "Constrained optimization at constant weight norm (α=0.8) largely eliminates grokking", modular addition, one-layer transformer, p = 113 — confirms L1.
  * Zhang et al., two queries: the first returned only the abstract; the second returned the ICLR 2017 poster's table (weight decay: Inception 100 %, AlexNet failed to converge, MLP 1×512 99.21 %) — confirms L2 at poster level.
  * Nanda et al., two queries: both returned paraphrased body excerpts tying cleanup to weight decay and stating no grokking without weight decay or another regulariser; one also returned a 2024 critique (arXiv:2405.12755) arguing that weight norm correlates with grokking without causing it. Recorded under L4 with the referee's contrary search.
  * Power et al., "particularly effective": not found — L3 stands.
  * WebFetch was not retried; no full text was read.
* **Draft LaTeX** (§6). Built in a scratch copy of `paper-steeper/` with `build.sh` (pdflatex, bibtex, pdflatex ×2), first unmodified (74 pages, all counts 0), then with the remark, the appendix subsection, the related-work sentence and `refs.bib` as `bib/decay.bib` (78 pages, all counts 0). Three builds of the modified copy were made.
  * Before the first, two sentences of the remark were tightened (the $\Hcl{\times}$ clause and "at most 1.2 %"). First build: 78 pages, all counts 0.
  * While writing this record, the box statement of Example 4.3(e) was found to need $\varepsilon\le1$ (for $\varepsilon>1$ the box never switches). The example's AdamW sentence and its proof idea were restricted to $\varepsilon\le1$, and the copy was rebuilt from a fresh copy of `paper-steeper/`: 78 pages, all counts 0, the same page positions.
  * In proofreading, the proof idea's sentence on $\varepsilon^2\ge1-2q$ was corrected to cover $\varepsilon\ge1$ (where the switch equation has no solution because its left side is not positive), and the copy was rebuilt once more from a fresh copy. Third build: 78 pages, all counts 0; the remark on p. 26, F.8 on p. 70, Appendix A on p. 39 and Appendix G on p. 72, as before. The text in §6 is that of this third build.
  * Page positions were read with `pdftotext`.
* **Not done.**
  * No full text of any cited paper was read.
  * The $\Hcl{\times}$ question of §8 item 4 was not settled.
  * The draft was not inserted into the repository's Paper 2 sources; that is for the paper editor.
