# Referee report: sub-track "decay" (λ = cn and weight decay, target I2)

*Referee for accuracy and literature. Written 2026-10-14. Object of the report: `notes.md` (624 lines), `refs.bib` (15 entries), `checks/d1_no_fixed_prior.py`, `checks/d2_weight_decay.py` and their `.out` files.*

* **What was read.**
  * The brief `../00-brief.md` in full, including the author's message.
  * `notes.md` in full, including the draft LaTeX of §6.
  * `refs.bib` in full.
  * Both check scripts and both outputs in full.
  * From Paper 2 (`paper-steeper/sections/`):
    * `setup.tex` in full;
    * `teacher.tex` in full;
    * `def:teacher:instance` in `parity.tex`;
    * `def:split:setting` and `lem:split:ville` in `recovery.tex`;
    * `lem:recovery:ratios`, its proof, and `prop:recovery:beyond` with its proof in `app-recovery.tex`;
    * `lem:setup:basic` in `app-setup.tex`;
    * `prop:limits:separable` and `rem:limits:hull` in `limits.tex`;
    * `related.tex`, at the paragraphs on generalised posteriors and two-part codes;
    * the ten generalised-posterior entries of `paper-steeper/bib/all.bib`;
    * the macros of `preamble.tex` that the draft uses.
* **What was checked.**
  * Every numbered statement of `notes.md` §§1–4: either proved again here or refuted.
  * Every number quoted from the outputs.
  * Every bibliographic entry: the 15 new ones and the 10 already in Paper 2.
  * Every attribution, by WebSearch.
* **Code.**
  * Both author scripts were rerun on copies in the session scratchpad. Their outputs are byte-identical to the saved `.out` files (d1: 1.7 s; d2: 1 min 44 s).
  * One independent script was written: `referee-checks/rd1_referee.py`, output `referee-checks/rd1_referee.out`. It is deterministic, does not import the author's code, and runs in 3 s with Python 3.11.15, NumPy 2.4.6 and SciPy 1.17.1.
* **Status tags.** These are as in the notes:
  * **[proved]** and **[computed: rd1(k)]** mark the referee's own results;
  * **[confirmed]** and **[not confirmed]** mark literature checks;
  * **[refuted]** marks a statement shown false, with its counterexample kept;
  * **[remark]** and **[heuristic]** are as named.
* **Repository.** No git command was run. Files written: this report, `referee-checks/rd1_referee.py` and `referee-checks/rd1_referee.out`.

---

## 0. Verdict

* **Mathematics.** Every proposition, remark and example of §§1–4 is correct as stated in the notes [proved here again].
  * The proofs of Propositions 2.2 and 2.3 and of Example 4.3 were redone line by line, and every displayed formula was rederived.
  * One sentence of the **main-text remark** (§6.1) states more than the proposition proves, and it is false in general classes. This is issue **M1**, a moderate issue, fixed by adding three words.
  * A second remark sentence asserts a containment that the notes deliberately do not claim (issue **M2**). It is true for summable priors, and a one-line proof is supplied below.
  * The rest are minor issues (m1–m10).
* **Code.** Both scripts reproduce exactly. The independent recomputation of Example 4.3 agrees with the closed form ω* to relative error 5·10⁻⁹ or better on the six parameter pairs that satisfy its assumption [computed: rd1(B)].
* **Literature.** All 25 entries (15 new, 10 already in Paper 2) are bibliographically correct as far as WebSearch can confirm.
  * DOIs, pages, volumes, authors and venues match. Fields the notes omitted remain unconfirmed.
  * Four attributions in `notes.md` §4.4 go beyond the cited abstracts (issues **L1–L4**): Omnigrok, Zhang et al., Power et al. and Nanda et al.
  * None of these four is in the draft LaTeX, which stays within the abstracts. The only exception is a citation placement for MacKay (m8).
* **Referee additions** (§4 below), any of which can be used:
  * (A1) inside the teacher window, c > c* is provable except in a band of relative width at most 1.2 % above 2⁻ᵐ, so the window *is* an instance of Proposition 2.3(ii);
  * (A2) a closed form for the AdamW box threshold;
  * (A3) a necessary and sufficient condition for the switch in Example 4.3, with a sharper L2 versus AdamW contrast;
  * (A4) a two-program class showing that the full-support hypothesis in Proposition 2.2(ii) cannot be dropped.

---

## 1. Mathematical statements, one by one

| notes item | verdict | comment |
|---|---|---|
| Prop 1.1 (per-sample form, limit) | correct [proved] | Restates `rem:setup:persample` and `prop:recovery:beyond`(c), which were checked in `app-recovery.tex`: the strong law for nonnegative variables, the finite candidate set, and $A_c$ finite and nonempty. |
| Remark 1.2 (recursion) | correct [proved] | The product identity is exact. The normaliser is finite for $cn\ge1$ by Kraft. More generally, any schedule gives the recursion with the factor $2^{-(\lambda_n-\lambda_{n-1})\ell}$, so fixed λ is exactly Bayes' rule, and λ = cn adds $2^{-c\ell}$ at every step. The generalised-Bayes reading (loss $-\log\nu_\pi+c\ell$, improper flat start) is a fair [remark]. Bissiri et al.'s framework starts from a prior distribution (abstract level), and the notes rightly say this start is improper. |
| Remark 1.3 (tempered posterior with η = 1/(cn) → Gibbs) | correct [proved] | Pointwise a.s. convergence for all π at once, domination by $2^{-\ell}$, then Scheffé. The phrase "fluctuations are of order $n^{-1/2}/c$" is an unlabelled scaling heuristic (m5). |
| Remark 1.4 (fixed λ is a fixed prior) | correct [proved] | — |
| Prop 2.1 (empirical distribution) | correct [proved] | — |
| Prop 2.2(i)–(ii) | correct [proved] | The threshold $r_{\rm th}$ is right. The case $w(\hat\pi)=0$ is handled, and a negative logarithm gives $r_{\rm th}<0$, so the claim holds for every $r\ge1$. (ii) needs full support, or at least $w(\pi^*)>0$: see M1 and A4. |
| Prop 2.2(iii) (existence in $\Hcl{\times}$) | correct [proved] | The inequality $c(n_0\log|Y|-\kappa-\ell_{\rm u})>\log|Y|$ is exactly what is needed. "Such labels exist by counting" should read "by Kraft's inequality for prefix complexity" (m4): a plain counting argument fails when $n_0\log|Y|$ is not an integer. |
| Prop 2.3(i) (summable prior charging $\mathcal E$ ends in $\arg\max_{\mathcal E}w$) | correct [proved] | The Ville step is right: a $w$-MAP in $T_k$ forces $Z^k_n\ge W$, and the events $A_k$ decrease with probability at most $w(T_k)/W\to0$. MAPs exist because $w$ is summable and the supremum is at least $W\nu(h_n)>0$. |
| Prop 2.3(ii) (c > c*: $A_c\cap\mathcal E=\emptyset$, shorter, worse) | correct [proved] | The notes prove $A_c\cap\mathcal E=\emptyset$ directly. That is needed, because `prop:recovery:beyond`(c) states only "no program of $\mathcal E_0$". |
| Prop 2.3(iii) (c < c*: both end in $\mathcal E_0$) | correct [proved] | The cn-MAP set equals the whole of $\mathcal E_0$ because programs of $\mathcal E_0$ tie on $G$. |
| Example 2.4 | correct [proved] | The coin-versus-$f$ comparison does not depend on $n$; the fixed-λ switch is at $n>\lambda k$. |
| Remark 2.5(a) | correct [proved] | The vertex-interval condition is sufficient but not needed. Near a breakpoint the λ′-MAPs lie inside the breakpoint's MAP set $M$ (`lem:setup:hull`(v)), so the conclusion holds anyway. Optional to simplify. |
| Remark 2.5(b), (c) | correct | — |
| Refuted claim D10 | correctly refuted | — |
| Prop 3.1, "teacher thread is this phenomenon" | correct [proved] | In the teacher instance the inputs are uniform on $\{0,1\}^d$, so the memoriser has $R=0$ and $\mathcal E\neq\emptyset$; Prop 2.3(i) applies. "Mislabel at least $p(1-e)$" follows from $e(\pi)=\Ex[\nu_\pi(y^*\mid x)\mid x\in E]$ (`def:teacher:instance`(d)). The numbers 0.2–0.29 are at $c=10^{-4}$, $\epsilon=0$, κ ∈ {0, 30} and δ_S ∈ {0, 20} (`tab:teacher:numbers`). For eventual MAPs with $\epsilon=\bar\epsilon_n\to0$ they are limits (m10). |
| "Classification" paragraph of §3 | one slip (m1) | "Randomised error rate 0.5 against 0.1": the sampler's *randomised* error is $2p(1-p)=0.18$. The 0.1 is its argmax error. The coin's error is 0.5 either way. |
| "Why λ must grow with n" | correct [remark] | — |
| Prop 4.1(a)–(c) | correct [proved] | The minibatch gradient is unbiased with or without replacement. Full-batch fixed points are the stationary points for every η > 0. "E.g. PyTorch's `weight_decay` argument": the PyTorch SGD documentation describes `weight_decay` as an "L2 penalty" [confirmed by search]. The update equation itself was not returned by the search; it is standard that the term is added to the gradient before momentum. |
| Prop 4.2(i), (ii) | correct [proved] | — |
| Example 4.3(a)–(c) | correct [proved; recomputed: rd1(B)] | Every step was rederived: the stationarity equations, $\theta_2>0$ (which uses only $q<\frac12$), the value at $b=0$, $\omega^*$, the small-ω bound with $A_0=\ln((2-3q)/q)$, and the large-ω limit of $\omega b$. The point $(a^*/(2\varepsilon),a^*/2)$ satisfies both stationarity equations at $\omega^*$, so it *is* the minimiser there. |
| §4.3 "Reading", last bullet | loose (m6) | "ω* plays the role of c* (the true solution's left steepness)": $L$ has no minimiser in this toy, so there is no "true solution" point. ω* is the threshold of the classifier only. Call it an analogy. |
| §4.4 item 1, third bullet | correct | — |
| §4.4 item 3 (AdamW toy) | correct, one imprecision (m7) | "To 3–4 digits": at $\lambda_W=0.01$, AdamW gives $\theta_1=99.672$ against the box value $100.000$, which is 0.3 % or about 2–3 digits. The switch value 0.1028 has a closed form (A2). |
| §4.4 item 4 (per-step effects) | correct [computed] | "Fixed points minimise $L+\frac{\lambda}{2\alpha}\|\theta\|^2$" needs convex $L$; in general they are stationary points (m3, which also applies to §6.2). The last bullet, on λ_norm ∝ n^{-1/2}, compares a decoupled AdamW coefficient with the L2 coefficient ω. For AdamW the limit is an ℓ∞ box, not an L2 penalty (Xie and Li), so the comparison holds only for SGDW. It is correctly kept out of the paper text; tag it [heuristic]. |
| §4.5 table, last row | misleading pairing (m9) | It compares fixed ω with *fixed λ*. Under the notes' own dictionary, fixed ω pairs with λ = cn, which refuses fill-ins even more strongly than fixed λ. The deep-network observation therefore shows that ‖θ‖² does not track description length, not that the per-sample schedule is weaker. Also, the weight-decay-specific support is in the body of Zhang et al., not the abstract (L2). |
| §8 open point 2 | **refuted as stated** (m2) | "Convex for convex $L$, so it has no vertices" is false. Counterexample: $L(\theta)=|\theta-1|$ on ℝ gives $v(\rho)=\max(0,1-\sqrt\rho)$, which is convex with a kink at ρ = 1, and θ = 1 minimises $L+\frac\omega2\theta^2$ for every ω ∈ (0, 1], an open interval [proved]. True version: for differentiable convex $L$ the value function is $C^1$ on the constrained range (the multiplier is continuous), so no point is selected on an open interval of ω. |

**Draft LaTeX (§6) against the proved statements.**

* **M1 (moderate) [refuted as worded].**
  * §6.1, first paragraph: "A fixed λ is the fixed prior $2^{-\lambda\ell}$, but no fixed prior gives the $cn$-MAPs at every $n$."
  * Prop 2.2(ii) proves this only for priors with full support (or with $w(\pi^*)>0$). Without that hypothesis it is false in general.
  * Counterexample: in the class {coin of length 1, $f$ of length $1+k$} with $ck>1$, the degenerate fixed prior $\delta_{\rm coin}$ has MAP set equal to the cn-MAP set (the coin) on *every* per-query sample [proved: $J_{cn}(\text{coin})<J_{cn}(f)$ for all $n$, and $w(f)=0$; computed: rd1(A), all 55 986 samples with $n\le6$].
  * In $\Hcl{\times}$ the unqualified claim depends on the reference machine [argument, not computed]. Suppose the unique shortest program π_s has a kernel bounded below by β > 0 and every other program is at least one bit longer. Then for $c>\log(1/\beta)$, π_s is the unique cn-MAP on every sample, so $\delta_{\pi_s}$ reproduces them.
  * **Fix:** write "no fixed prior with full support", matching the next sentence and the proposition. Proposition (ii) as drafted in §6.2 is correct, since it assumes $w(\pi^*)>0$.
* **M2 (moderate).**
  * §6.1: "under a fixed prior with full support only programs of maximal likelihood stay MAPs when a sample is repeated often enough".
  * The notes (§2, *Computation*) deliberately do not claim this: "Programs outside M can need larger r, so this is not claimed". Neither the notes nor the drafted Proposition (ii) proves it, and for non-summable priors MAPs need not exist.
  * It is true for **summable** $w$ with $w(\pi^*)>0$ [proved]. $S:=\{\pi:w(\pi)\ge w(\pi^*)\}$ is finite. Every π ∉ S has $w(\pi)\nu_\pi(h)^r<w(\pi^*)(P^*)^r$ when $\nu_\pi(h)\le P^*$. Every π ∈ S with $\nu_\pi(h)<P^*$ is eventually beaten because $(\nu_\pi/P^*)^r\to0$. MAPs exist because $w$ is summable. So for all large $r$ every $w$-MAP on $h^r$ has likelihood $P^*$.
  * **Fix:** either say "with full support, no $cn$-MAP stays a MAP when the sample is repeated often enough" (what Proposition (ii) proves), or restrict to summable priors and add the three-line argument to the proof.
* **Teacher sentence.** "The window … is an instance" is safe as worded: what follows the colon is proved. With A1 below it can also say that c > c* there, apart from a band of relative width about 0.4–1.1 % above 2⁻ᵐ at the example's sizes.
* **m3.** §6.2 weight-decay paragraph: "the fixed points minimise $L+\frac{\lambda}{2\alpha}\|\theta\|^2$". Write "are the stationary points of", or add "for convex $L$".
* **m8.** §6.1: "$n$ times this is … the negative log posterior under $\mathcal N(0,(n\omega)^{-1}I)$ \citep{mackay1992practical}". MacKay supports the Gaussian-prior (Bayesian) reading of weight decay. The precision nω, growing in $n$, is the notes' own one-line derivation. Placing the citation after "Gaussian prior" in a separate clause avoids attributing the growth to MacKay. Suggested wording: "…is, up to a constant, the negative log posterior under a Gaussian prior \citep{mackay1992practical} with precision $n\omega$, which grows linearly in $n$…"
* Everything else in §6.1–§6.3 matches a proved statement or a confirmed abstract. The macros used (`\Hcl`, `\dom`, `\Ex`, `\KL`, `\status`, `\src`) exist in `paper-steeper/preamble.tex`. The build itself was not rerun.

---

## 2. Issues, by severity

**Moderate.** M1 and M2 (above). Both are wording fixes to §6.1. Neither changes a result.

**Minor.**
* **m1.** §3 "Classification": "randomised error rate 0.5 against 0.1". The 0.1 is the sampler's argmax error. Its randomised error is 0.18.
* **m2.** §8 open point 2: "convex ⇒ no vertices" is refuted (counterexample above). Replace with the differentiable version.
* **m3.** "Fixed points minimise" → "are the stationary points of", in §4.4 item 4 and §6.2.
* **m4.** Prop 2.2(iii): "by counting" → "by Kraft's inequality (prefix complexity)".
* **m5.** Remark 1.3: tag "fluctuations of order $n^{-1/2}/c$" [heuristic].
* **m6.** §4.3: "ω* plays the role of c* (the true solution's left steepness)". There is no population minimiser of $L$, so say "an analogue of c*".
* **m7.** §4.4 item 3: "to 3–4 digits" → "to within 0.3 % (λ_W = 0.01) and 4 digits (λ_W ≥ 0.05)".
* **m8.** MacKay citation placement in §6.1 (above).
* **m9.** §4.5 last row: pair fixed ω with λ = cn, not with fixed λ, and retag the weight-decay evidence "body, via search excerpt" (L2).
* **m10.** §3: say that 0.2–0.29 are the ε = 0 values at $c=10^{-4}$, κ ∈ {0, 30} and δ_S ∈ {0, 20}.

**Reading of the author's bullet** [remark]. The notes follow the brief in reading "as the number of params varies" as "as the sample size $n$ varies". That fits "keeps going on each step". If the author meant the number of parameters, one sentence would serve: the steeper prior $2^{-\lambda\ell}$ charges λ bits per bit of program, while the Gaussian prior of weight decay charges each parameter separately, so neither is a fixed prior over model sizes once its coefficient grows with $n$. Not an issue; a point to confirm with the author.

---

## 3. Literature: every entry re-verified by WebSearch

**Route.** 46 WebSearch queries, run on 2026-10-14.
* WebFetch of arxiv.org failed with `getaddrinfo ENOTFOUND`, as it did for the author.
* `curl` to export.arxiv.org failed with CONNECT 502.
* So every check below rests on search results: bibliographic records (PMLR, NeurIPS proceedings, JMLR, ACM, DBLP, MLAnthology, Project Euclid) and abstracts, often paraphrased by the search tool.
* "Confirmed" means that at least one search result gave the field explicitly.

### 3.1 New entries (`refs.bib`)

| key | bibliographic check | attribution in notes / draft | verdict |
|---|---|---|---|
| `krogh1992simple` | NIPS 4 (1991), pp. 950–957 [confirmed: NeurIPS metadata `page_first` 950, `page_last` 957]; editors Moody, Hanson, Lippmann, Morgan Kaufmann 1992 [confirmed: DBLP volume record] | linear networks: suppresses irrelevant weight components; with the right size, suppresses some effects of static target noise; extension to hidden layers; NetTalk [confirmed, abstract] | correct |
| `mackay1992practical` | Neural Computation 4(3):448–472, 1992; doi 10.1162/neco.1992.4.3.448 [confirmed] | Bayesian framework; objective choice of weight-decay terms; evidence as Occam's razor [confirmed, abstract] | correct; citation placement in §6.1 (m8) |
| `hinton1993keeping` | COLT '93, pp. 5–13, ACM; doi 10.1145/168304.168306; ACM title "Keeping the Neural Networks Simple by …" [confirmed] | information in the weights controlled by adapted Gaussian noise [confirmed, abstract] | correct. "Coding weights needs a precision" (§6.1) is a fair paraphrase of the noise-controlled information. Optional: "the information in the weights depends on their precision, which \citet{hinton1993keeping} control by adapted Gaussian noise". |
| `loshchilov2019decoupled` | ICLR 2019; arXiv:1711.05101; v2 titled "Fixing Weight Decay Regularization in Adam" [confirmed] | L2 = weight decay for SGD when rescaled by the learning rate, not for Adam; decoupling [confirmed, abstract]. App. B.1 normalised decay $\lambda=\lambda_{\rm norm}\sqrt{b/(BT)}$, motivated by different optimal factors for different numbers of batch passes [confirmed, body via search excerpt] | correct. "Optimal decay shrinks with more batch passes" is implied by the formula, not quoted. The SGDW update form (decay not multiplied by α) was **not confirmed**, since the search did not return Algorithm 1. The notes call it "SGDW-style" without attributing it, which is fine. |
| `vanlaarhoven2017l2` | arXiv:1706.05350, 16 Jun 2017 [confirmed] | with normalisation, no regularising effect; influences the weight scale and the effective learning rate; Adam only partly removes this [confirmed, abstract] | correct ("mainly sets" is a fair paraphrase) |
| `xie2024implicit` | ICML 2024, PMLR 235:54488–54510; arXiv:2404.04454 [confirmed] | full batch; if AdamW converges under a non-increasing schedule with divergent partial sums, the limit is a KKT point under $\|\theta\|_\infty\le1/\lambda$ [confirmed, abstract] | correct |
| `dangelo2024why` | NeurIPS 37 (2024); doi 10.52202/079017-0730 [confirmed: the search reports that DOI from the NeurIPS proceedings page; a search for the DOI string alone returned nothing]; arXiv v1 lists Andriushchenko first, v2 and NeurIPS list D'Angelo first [confirmed] | role differs from classical regularisation; vision with multipass SGD: loss stabilisation; LLMs: bias–variance balance; "never useful as an explicit regularizer but instead changes the training dynamics" [confirmed, abstract] | correct. The notes soften "never useful" to "mainly through the dynamics". Fine; not in the draft. |
| `mandt2017stochastic` | JMLR 18(134):1–35, 2017 [confirmed] | constant SGD is a Markov chain with a stationary distribution, tunable to approximate a posterior [confirmed, abstract] | correct |
| `power2022grokking` | arXiv:2201.02177, 6 Jan 2022; five authors as listed [confirmed]. An ICLR 2021 workshop version exists, so misc/arXiv is acceptable. | chance → perfect generalisation well past overfitting; smaller datasets need more optimisation; weight decay not in the abstract [confirmed, abstract] | correct. **L3:** the body quote "particularly effective" was **not reconfirmed**. Two searches returned only a secondary summary that weight decay was the most effective intervention. It is kept out of the draft; drop the quotation marks in the notes. |
| `liu2022towards` | NeurIPS 35 (2022); authors including "Niklas S Nolte" [confirmed: NeurIPS listing]; arXiv:2205.10343; pages not confirmed (omitted, correctly) | effective theory; phase diagrams over hyperparameters; four phases; Goldilocks zone. The abstract does not name weight decay [confirmed]. | correct; cite for grokking only, as done |
| `liu2023omnigrok` | ICLR 2023 (top 25 %); arXiv:2210.01117 [confirmed: ICLR virtual site, DBLP] | LU mechanism explains data-size and weight-decay dependence and the emergence of representations; induces grokking on images, language and molecules; eliminates it on algorithmic data [confirmed, abstract] | §6.1 sentence correct. **L1:** see §3.3. |
| `nanda2023progress` | ICLR 2023 (oral, top 25 %); arXiv:2301.05217; five authors [confirmed] | Fourier/rotation algorithm; memorisation, circuit formation, cleanup; amplification of structured mechanisms, then removal of memorising components [confirmed, arXiv abstract v3] | §6.1 sentence correct. **L4:** see §3.3. |
| `varma2023explaining` | arXiv:2309.02390, 5 Sep 2023; five authors [confirmed] | generalising circuit slower but more efficient (larger logits per parameter norm); memorising circuits lose efficiency with dataset size; critical dataset size; ungrokking, semi-grokking [confirmed, abstract] | correct (notes only) |
| `zhang2017understanding` | ICLR 2017; arXiv:1611.03530; five authors [confirmed] | CNNs trained with stochastic gradient methods easily fit random labels; "qualitatively unaffected by explicit regularization"; also on random-noise inputs [confirmed, abstract] | correct. **L2:** see §3.3. |
| `arpit2017closer` | ICML 2017, PMLR 70:233–242; eleven authors as listed [confirmed] | can memorise noise but learns simple patterns first; tuned explicit regularisation (e.g. dropout) degrades training on noise without hurting real-data generalisation [confirmed, abstract] | correct; the notes rightly say the abstract names dropout, not weight decay |

### 3.2 Entries already in Paper 2

All ten agree with `paper-steeper/bib/all.bib` [confirmed].

| key | confirmed | content check |
|---|---|---|
| `zhang2006epsilon` | Ann. Statist. 34(5):2180–2210, 2006; doi 10.1214/009053606000000704 | information-theoretic inequality for deterministic and randomised density estimators; improves MDL and posterior-convergence results [confirmed, abstract] |
| `bissiri2016general` | JRSS B 78(5):1103–1130; doi 10.1111/rssb.12158 | loss-based updating of beliefs; Bayes is the likelihood special case [confirmed, abstract]. Remark 1.2's use is a fair [remark]. The framework is stated for a prior, and Remark 1.2's flat start is improper, as the notes say. |
| `bhattacharya2019fractional` | Ann. Statist. 47(1):39–66, 2019; doi 10.1214/18-AOS1712 | fractional likelihood power; contraction under misspecification with only a prior-mass condition; PAC-Bayes oracle inequality [confirmed, abstract] |
| `grunwald2012safe` | ALT 2012, LNCS 7568:169–183; doi 10.1007/978-3-642-34106-9_16 | learns the learning rate from data for wrong models [confirmed] |
| `grunwald2017inconsistency` | Bayesian Analysis 12(4):1069–1103; doi 10.1214/17-BA1085 | Bayes inconsistent for misspecified linear models (heteroskedastic data); hypercompression; SafeBayes picks small learning rates [confirmed, abstract] |
| `wenzel2020good` | ICML 2020, PMLR 119:10248–10259 | Bayes posterior predictive worse than SGD point estimates; cold posteriors that overcount evidence help [confirmed, abstract] |
| `grunwald2007suboptimal` | Machine Learning 66:119–149, 2007; doi 10.1007/s10994-007-0716-7 | Bayes and two-part MDL classifiers keep an error bounded away from the optimum under misspecification [confirmed, abstract] |
| `zhu2025quantifying` | COLT 2025, PMLR 291:6124–6155; arXiv:2503.02110; Zhu, Srebro | full regularisation curve of a modified two-part MDL rule; worst-case limiting error as a function of λ and the noise level [confirmed, abstract] |
| `zhu2026overfitting` | arXiv:2603.22644, 23 Mar 2026; Zhu, Ohannessian, Srebro | PAC-Bayes rule balancing training error and KL to a fixed prior. λ = 1 gives an empirical Bayes posterior that overfits. λ ≫ 1 gives uniformly vanishing excess loss, even agnostically. Two independent searches paraphrase the λ ≫ 1 case as "acts like a sample-size-dependent prior" and "is described as using a sample-size-dependent prior" [confirmed at paraphrase level, twice; verbatim wording not seen]. **§6.3 clause: keep**, with the verb "describe" or "read" as drafted. |
| `barron1991minimum` | IEEE Trans. Inf. Theory 37(4):1034–1054, 1991; doi 10.1109/18.86996 [confirmed: DOI given in a 2025 arXiv reference list] | defines the index of resolvability, which bounds convergence rates of minimum-complexity estimators [confirmed: Cover's Stanford page and a secondary source]. A correction to eq. (1.3) appeared in vol. 37 no. 6 (Nov. 1991) [confirmed]. Paper 2 does not quote (1.3), so nothing changes. |

### 3.3 Claims about weight decay or grokking that go beyond the cited abstract

None of these four is in the draft LaTeX. All are in `notes.md` §4.4 and should be retagged there.

* **L1. Omnigrok** (§4.4 item 6): "Constraining the weight norm eliminates grokking on algorithmic data", tagged [known, abstract level].
  * The abstract says only "we are able to eliminate grokking for algorithmic datasets", without saying how.
  * A search excerpt of the body says: "Constrained optimization at constant weight norm (α = 0.8) largely eliminates grokking". The setting is modular addition with a one-layer transformer, p = 113, with weights rescaled to the norm after each step.
  * **Retag:** "body, via search excerpt: *largely* eliminates, in that setting".
* **L2. Zhang et al.** (§4.4 item 5 and §4.5 last row): "So in that regime the norm penalty does not act as a fixed λ > 1 does against fill-ins".
  * The abstract says "explicit regularization", not weight decay.
  * A search excerpt of the body (Appendix E, Table 4, CIFAR-10, random labels) says:
    * Inception with default weight decay reaches 100 % training accuracy;
    * AlexNet with weight decay **failed to converge**;
    * a larger weight-decay setting still overfits random labels.
  * So the weight-decay-specific claim is supported only by the body (search excerpt), with an exception.
  * **Retag:** "body, via search excerpt (App. E); AlexNet with weight decay did not converge". Note the pairing issue m9.
* **L3. Power et al.**: "particularly effective" (body quote) was not reconfirmed; see the table above. It is already kept out of the paper.
* **L4. Nanda et al.** (§4.4 item 6, "Relation to this paper"): "the … dynamics of weight decay, which removes memorising components".
  * Nanda et al.'s abstract attributes the removal of memorising components to the cleanup phase of training. It does not attribute it to weight decay.
  * Search results attribute the shedding of the memorised solution to weight decay only in a *different* paper by overlapping authors (*A Toy Model of Universality*, arXiv:2302.03025), and say that whether weight decay is necessary for grokking is disputed.
  * The paragraph is tagged [heuristic]; add "the attribution of cleanup to weight decay is not in the cited abstract".

**The draft's grokking sentence** passes at abstract level: "Grokking \citep{power2022grokking,liu2022towards} has been related to the weight norm and to weight decay \citep{liu2023omnigrok}, and analysed as memorisation followed by a cleanup that removes memorising components \citep{nanda2023progress}" [confirmed].

**Brief's literature list.** Every source the brief names is present and verified: Krogh–Hertz, Loshchilov–Hutter, Power, Nanda, Liu 2022 and 2023, and the generalised-posterior references. For "weight decay and label noise or memorisation", Krogh–Hertz (static target noise) is the clean reference at abstract level. Zhang et al. covers weight decay only through the body (L2). Arpit et al. names dropout.

---

## 4. Referee additions

**A1. Inside the teacher window, c > c\* is provable outside a thin band** [proved; computed: rd1(C)].
* *Statement.* In the instance of `def:teacher:instance`, take PQ data with $\nu=\delta_{y^*}$ and uniform inputs. Put $\mathcal E=\{R=0\}$, nonempty because it contains the memoriser, and
  $$c_+:=\frac{H(p)}{B_S-4-\Lambda_1-\kappa_g}.$$
  Then every $c\in(\max\{2^{-m},c_+\},\,c_{\rm hi})$ has $c>c^*$.
  * So for these $c$ the teacher window is an instance of Prop 2.3(ii): the cn-MAPs eventually lie in $A_c$, which is disjoint from $\mathcal E$.
  * Every summable prior that charges $\mathcal E$ ends in $\mathcal E$.
* *Proof.*
  * Let $\pi\in A_c$, so $J_c(\pi)=\Phi(c)$.
  * For $2^{-m}<c<c_{\rm hi}$ we have $J_g(c)<\Phi_2(c)$, so `thm:teacher:main`(ii) applies with $\epsilon=0$.
  * (ii)(b) gives $R_B(\pi)\ge H(p)-c\Lambda_2/(c2^m-1)$. Since $2^mH(p)-\Lambda_2=B_S-4-\Lambda_1-\kappa_g$, this is positive iff $c>c_+$.
  * So $R(\pi)\ge R_B(\pi)>0$ and $\pi\notin\mathcal E$: $A_c\cap\mathcal E=\emptyset$.
  * By `prop:recovery:beyond`(c), $c<c^*$ would give $A_c=\mathcal E_0$. At $c=c^*$ the programs of $\mathcal E_0$ minimise $J_c$, because $J_c(\pi)-J_c(\pi_0)=\KL_\mu(\pi)-c^*(\ell_0-\ell(\pi))\ge0$ for $\ell(\pi)<\ell_0$. Both contradict $A_c\cap\mathcal E=\emptyset$. Hence $c>c^*$. ∎
* *Numbers* (d = 100, m = 20, p = 2⁻¹⁰; κ set to 0 or 30, an illustration as in Paper 2): $c_+/2^{-m}$ is
  * 1.00447 at (κ, δ_S) = (0, 0);
  * 1.00620 at (0, 20);
  * 1.00967 at (30, 0);
  * 1.01141 at (30, 20).

  So c > c* on the window except a band of relative width at most 1.2 % above $2^{-m}$. In general $c_+=2^{-m}(1+O((\delta_S+\log d+\log m+m+\kappa)/L_S))$.
* *Use.* The draft can now say "the window is an instance (for c above $c_+$, c > c*)". The notes' caution, "the draft no longer asserts c > c* inside the teacher window, which is not proved", can be lifted outside this band.

**A2. Closed form for the AdamW box threshold of Example 4.3** [proved; computed: rd1(B)].
* *Statement.* The minimiser of $L$ under $\|\theta\|_\infty\le1/\lambda$ has error $q$ iff $\lambda\ge\lambda_{\rm box}:=2\varepsilon/\ln((2-3q)/q)$, and error 0 otherwise.
* *Proof.*
  * $\partial L/\partial\theta_1<0$ everywhere, so $\theta_1=B:=1/\lambda$.
  * $L(B,\cdot)$ is strictly convex. The error is $q$ iff the optimal $\theta_2\ge\varepsilon B$, iff $\partial L/\partial\theta_2\le0$ at $\theta_2=\varepsilon B$, iff $(1-q)\sigma(-2\varepsilon B)\ge q/2$, iff $e^{2\varepsilon B}\le(2-3q)/q$.
  * The box constraint $\theta_2\le B$ does not interfere, because $\varepsilon B<B$. ∎
* *Values.* At ε = 0.1 and q = 0.2, $\lambda_{\rm box}=0.2/\ln7=0.102780$, the notes' numerical 0.1028. The closed form agrees with direct box minimisation to 6 digits on all eight (ε, q) pairs of rd1(B).
* *Use.* The constant $A_0=\ln((2-3q)/q)$ is the same one that appears in the notes' small-ω bound.

**A3. The switch condition in Example 4.3 is necessary and sufficient, and AdamW can switch where L2 never does** [proved; computed: rd1(B)].
* *Statement.* If $\varepsilon^2\ge1-2q$ (with $q<\frac12$), the minimiser of $F$ has error 0 for **every** ω > 0.
* *Proof.*
  * The proof of (b) uses only $q<\frac12$.
  * At $b=0$ one would need $(1-q)(1-\varepsilon^2)\sigma(-a)=\frac q2(1+\varepsilon^2)$, which forces $\sigma(-a)\ge\frac12$ (or is impossible if ε ≥ 1). That contradicts $a=2\theta_2>0$.
  * The small-ω argument does not use the assumption, so $b>0$ for every ω by continuity. ∎
* *Check.* At (ε, q) = (0.8, 0.2) and (0.7, 0.3), $b>0$ at all 33 values ω ∈ [10⁻⁵, 10³] [computed].
* *Contrast.* The box (AdamW limit) problem still switches at $\lambda_{\rm box}$ = 0.822 and 1.078 in these two cases.
* *Use.* The example could say: "L2 decay yields the worse classifier iff $\varepsilon^2<1-2q$; the ℓ∞ box of decoupled decay yields it at strong decay in every case".
* *Caveat.* That AdamW actually reaches the box minimiser was checked by d2(D) only at ε = 0.1 and q = 0.2. Elsewhere it rests on Xie and Li's convergence-conditional theorem.

**A4. Fixed priors that do reproduce the cn-MAPs** [proved; computed: rd1(A)].
* In the two-program class of Example 2.4, the cn-MAP sets are reproduced on every sample by:
  * the degenerate prior $\delta_{\rm coin}$, for $ck>1$;
  * the full-support prior (1, 1), for $ck<1$.
* rd1(A) enumerates all 55 986 per-query samples of size at most 6 on X = {0,1,2}, at c = 1/20 and 1/5, with 0 disagreements in both cases.
  * The prior (1, 2⁻²⁰) also shows 0 disagreements at $ck>1$ only because $n\le6<20=\log(w(\text{coin})/w(f))$. From $n=21$ on it fails, as Prop 2.2 predicts.
* So the full-support hypothesis of Prop 2.2(ii) is necessary in general (M1). The theorem-level difference from Bayes is per query: Prop 2.3(ii) for $c>c^*$, against every summable prior that charges $\mathcal E$. That statement is unaffected.

---

## 5. Recommended edits, in order of priority

1. §6.1: "no fixed prior" → "no fixed prior with full support" (M1).
2. §6.1: rephrase the "only programs of maximal likelihood stay MAPs" clause, or restrict it to summable priors and add the argument to the proof (M2).
3. Optional: use A1 to state c > c* for the teacher window above $c_+$.
4. §6.1: move the MacKay citation (m8).
5. §6.2: "minimise" → "are the stationary points of" (m3). Optionally replace "switches at λ = 0.103" by the closed form $2\varepsilon/\ln((2-3q)/q)$ (A2) and add the iff condition (A3).
6. Notes §4.4 items 5–6 and §4.5: retag L1, L2, L4. Drop the quotation marks around Power's "particularly effective" (L3). Fix the pairing in the last table row (m9).
7. Notes: m1, m2, m4–m7, m10.

---

## Verification log

* **2026-10-14, reading.** Everything listed under "What was read". The labels cited by the notes and the draft were found in Paper 2:
  * `lem:recovery:ratios`, `prop:recovery:beyond`, `def:split:setting`, `lem:setup:basic`, `lem:setup:coding`, `lem:setup:hull`;
  * `rem:setup:persample`, `lem:teacher:reuse`, `prop:teacher:schedules`, `thm:teacher:main`, `rem:limits:schedule`;
  * `prop:limits:separable`, `rem:related:cold`, `def:teacher:instance`.

  Their statements agree with how the notes use them. The one exception is `prop:recovery:beyond`(c) for c > c*, which says only "no program of $\mathcal E_0$". The notes' Prop 2.3(ii) proves the stronger disjointness itself, which is correct.
* **Rerun of the author's checks.** `d1_no_fixed_prior.py` and `d2_weight_decay.py` were copied to the session scratchpad and run with Python 3.11.15, NumPy 2.4.6 and SciPy 1.17.1. `diff` against the saved outputs is empty for both.
* **rd1_referee.py.**
  * *First run.* The no-switch case of part (B) was not exercised, because both "violating" pairs I had listed, (0.5, 0.3) and (0.6, 0.3), in fact satisfy $\varepsilon^2<1-2q$.
  * *Fix.* Added (0.8, 0.2) and (0.7, 0.3) and reran. The saved output is that of the second run.
  * *Result.* All parts as quoted in §§1–4.
* **Literature.** 46 WebSearch queries, listed by entry in §3.
  * WebFetch of arxiv.org failed (`getaddrinfo ENOTFOUND`), and `curl` to export.arxiv.org failed (CONNECT 502), so no full text was read.
  * Fields confirmed per entry are listed in §3.
  * Not confirmed:
    * the SGDW update form in Loshchilov and Hutter's Algorithm 1;
    * Power et al.'s phrase "particularly effective";
    * the pages of `liu2022towards` and `dangelo2024why`, which the notes already omit.
* **Not done.**
  * The draft LaTeX build was not rerun; the notes report a clean scratch build.
  * No full text of any cited paper was read.
  * The $\Hcl{\times}$ remark under M1, that the unqualified claim depends on the reference machine, is an argument and is not computed.
