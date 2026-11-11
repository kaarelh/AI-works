# Referee report on `A-first-version.md`: scope and adversarial interpretation

*Lens: does what A-first-version.md proves establish or refute the intended version of the conjecture in brief §1? Would the user who proposed the conjecture accept it, or object that it addresses a different learner, a degenerate distribution, a different loss, or the wrong order of limits? Can any stated result be falsified under a natural reading? Is it consistent with the repository's theorems?*

*Read in full: `../research-notes/problem-brief.md` and `A-first-version.md` (846 lines). Read for cross-checks: `A-first-version-logic.md` (the logic referee's report), `../research-notes/red-team.md` §§5–7, and the result tables of the sibling sections `../research-notes/B-tempered-likelihood.md` and `../research-notes/E-finite-prior-scale.md`.*

*Repository sources opened and compared with A-first-version.md's use of them (`NNG/` = the project folder `neural-network-generalization/` of this repository):*

* `NNG/README.md`, the main-result summaries; main result 1 states sample bounds "polynomial in input dimension";
* `NNG/works-in-progress/slt-likelihood/README.md`, §§1–4 in full;
* `NNG/side-results/continuous-domains/source/paper.tex`, §`model` (eq. `posterior`, Theorems `strong` and `finite`, Remark `cube`) and §`exact` (Proposition `exact`, Corollary `exact`);
* `NNG/works-in-progress/noisy-interpolation/README.md`, §1 (theorem) and §2;
* `NNG/TECHNICAL-FAQ.md`, Questions 33–34.

*Scripts are in `../checks/verify-A-first-version-scope/`: `fixed_d_consistency.py`, `aprime_scale.py`, `tube_aprime.py`, each with a `.out` file.*

---

## 1. Verdict: `minor_fixes`

**Correctness.** No theorem, lemma or proposition of A-first-version.md is false, and I found no contradiction with any repository theorem (§5).

* I re-checked the steps the scope rests on: Lemma 2.1 (steps 3–6), Lemma 3.2, Lemma 4.1(b), Theorem 4.4(i)–(iii), Theorem 7.2 (steps 2–5), Lemma 6.2, and Propositions 6.3 and 6.5.
* The logic referee re-derived everything else, and I agree with that report.

**Scope.** The problems are in what A-first-version.md says its theorems mean. Several summary and discussion sentences claim more than is proved. Under natural readings of the user's conjecture, some of them are false.

* Issues **S1–S3** (major for reporting) change what may be told to the user.
* Issue **S4** changes the TUBE headline.
* All four must be fixed before reporting. Each fix is a restatement of scope; no new proof is needed.

### What is refuted, exactly

The brief's property (P$_L$) of A-first-version.md §5.1 fails for the following learner, predictors and distributions.

* **Learner.** SP$_c$ in the strong-prior limit ($\sigma\to0$ after fixing $N,n,S$), at depth $L\ge3$, for every schedule with $c\,K_{\rm mem}=o(n)$, roughly $c\ll n^{1-1/H}d^{-1/H}$. This includes $c=1$, the clean-label scaling of `slt-likelihood/README.md` §2.
* **Learner width.** Every $N\ge N_0$. At a fixed memorizer accuracy $a$, $N_0\approx44\,d(d+1)n/a^2$. That is $2\cdot10^5$ to $7\cdot10^6$ times $n$ for $d\in[20,40]$ and $a\in\{0.1,0.3\}$ (`aprime_scale.out`).
* **Predictors.** Near-minimizers, hence MAP and every $\sigma\to0$ weak limit; Gibbs draws; posterior means, clipped or not.
* **Witness laws.** All have $n\asymp2^d$. They are the uniform cube with atom noise, or A′'s corner cubes. The A′ density is $r^{-d}=10^{287}$ to $10^{1397}$ times the uniform density on $[-1,1]^d$ (§4.2).

For TUBE$_\rho$ the results are as follows:

* collapse to $0$ when $\rho>1$ or $|y|<\rho$;
* an undefined posterior when $\rho\le1$ and some repeated input carries conflicting labels;
* a failure under sampling without replacement, which is not i.i.d.

### What is not refuted

* (a) **The conjecture itself.** It lets the user "pick whichever version of Bayesian learning is best". The sibling ../research-notes/B-tempered-likelihood.md claims that tempered SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$, satisfies (P$_L$) for clipped predictors (S1).
* (b) **Any version whose $o(1)$ may depend on $d$.** At fixed $d$, the cube example is consistent at every width (§4.1, S2).
* (c) **Any version restricted to input laws without near-duplicates at the learner's resolution.** This includes uniform inputs (§4.2, S3).
* (d) **Other learners and predictors:**
  * learner widths below $N_0$;
  * the finite-scale family;
  * the progressive mixture;
  * depth two;
  * TUBE with $\rho_n\to0$ on continuous i.i.d. inputs (§4.3, S4).

---

## 2. The conjecture, the brief's formalization, and what A-first-version.md covers

The user's sentence is: "after seeing $n$ data points, test loss is at most the min test loss among all width poly($n$) MLPs … condition to be pretty close to the given outputs … (We may pick whichever version of Bayesian learning is best.)" Brief §1 turns it into a per-learner property, (P$_L$) in A-first-version.md §5.1. That property is uniform over $d$, over $D$, over competitors, and over learner widths $N\ge m$, with a threshold $n\ge\mathsf p(d,m,B,1/\varepsilon,\log1/\delta)$.

| quantifier or choice | user's sentence | brief / (P$_L$) | what A-first-version.md's negative uses | covered by A-first-version.md? |
|---|---|---|---|---|
| learner | **exists** ("whichever version is best") | **fixed** learner $\mathsf A$ | SP$_c$ with $cK_{\rm mem}=o(n)$; TUBE$_\rho$ | only those learners (S1) |
| input dimension | not mentioned | $\mathsf p$ polynomial in $d$, uniform over $d$ | $d=\log_2n\to\infty$ | only the $d$-uniform reading (S2) |
| input law | not mentioned | all $D$ on $X\times[-1,1]$ | atoms; A′ clusters at scale $r\approx L^{L/2}n^{-1-L/2}$ | only near-atomic laws (S3) |
| learner width | not mentioned | every $N\ge m$ | $N\ge N_0\gtrsim n\log^2n$ | only very wide learners (S6) |
| prior-scale limit | not mentioned | SP$_c$: $\sigma\to0$ at fixed $N,n,S$ | the same | yes; the finite scale is in ../research-notes/E-finite-prior-scale.md (S7) |
| predictor | not mentioned | Gibbs, posterior mean, progressive mixture | Gibbs, posterior means, near-minimizers | not the progressive mixture (S5) |
| loss | MSE | MSE against noisy test labels | MSE, clipped and unclipped | yes |
| depth | MLPs | fixed $L$ | $L\ge3$ | depth two open (acknowledged) |

---

## 3. Issues

Severity "major" means that, uncorrected, the text would lead to a false statement about what is refuted being reported to the user. No issue invalidates a proof.

### S1 (major for reporting): the conjecture is existential in the learner; A-first-version.md never says it is not refuted

**Locations.**

* §0 item 4: "Refutation (Proposition 5.1) … The result refutes the width-uniform formulation of the brief."
* The §5 title: "Why Claim A refutes polynomial sample bounds".
* §5.2 and §10. Neither mentions the status of the conjecture.

**Problem.** Brief §1 records the user's clause "(We may pick whichever version of Bayesian learning is best.)" The conjecture asserts that *some* Bayesian learner has the property. (P$_L$) is a property of one learner. Proposition 5.1 correctly shows that (P$_L$) fails for SP$_c$ with $cK_{\rm mem}=o(n)$, and §6 shows failures for TUBE. Neither refutes the conjecture.

The sibling sections claim the opposite for other learners:

* ../research-notes/B-tempered-likelihood.md, Theorem 6.3: (P$_L$) holds for SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$, for clipped predictors, at every width.
* ../research-notes/E-finite-prior-scale.md, Theorem 2.7: the same at finite scale.
* `../research-notes/red-team.md`, Remark 6.2: conditioning on aggregate empirical MSE $<\tau\approx\mathrm{OPT}$ also works.

A-first-version.md cites none of these. A reader of §0 item 4 or the §5 title will plausibly conclude that "the conjecture is false".

What A-first-version.md does refute is the user's auxiliary heuristic: "The Bayesian learning should condition to be pretty close to the given outputs on train inputs for this to be plausibly true." In the agnostic setting the opposite holds. Conditioning tight enough to push the training MSE well below the noise level ($c\ll n^{1-1/H}$) is what breaks the property. This is the main scientific message for the user, and A-first-version.md never states it in these terms.

**Fix.**

* Retitle §5 "Why Claim A refutes (P$_L$) for tightly conditioned SP$_c$".
* Replace the last two sentences of §0 item 4 with: "This refutes (P$_L$) for SP$_c$ with $cK_{\rm mem}=o(n)$, including the clean-label scaling $c=1$. It does not refute the conjecture, which allows any Bayesian learner. ../research-notes/B-tempered-likelihood.md proves (P$_L$) for tempered SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$ (clipped predictors). What fails is the heuristic that close conditioning is needed."
* Add the same point to §10.

### S2 (major for reporting): the refutation needs $d\to\infty$; at fixed $d$ the cube example is consistent at every width

**Locations.**

* §5.2 item 2: "That reading is refuted for every $\alpha$ and every $o(1)$."
* §5.2 item 1: "eventually consistent on $D_d$, but only after exponentially many samples."
* §0 items 3–4, which never say "uniform over the input dimension".

**Problem.** The excess is $\Omega(1)$ only in the window $n=\Theta(2^d)$. At any fixed $d$, every near-minimizer at every width has excess $O(M/n)$ with high probability (Proposition R1 in §4.1). So "refuted for every $o(1)$" is false when the $o(1)$ may depend on $d$ or $D$.

The $d$-uniform reading is the repository's convention: `NNG/README.md` main result 1 says "polynomial in input dimension". (P$_L$) is therefore a defensible formalization. But the user's sentence never mentions $d$, so the qualifier decides whether the user's sentence is refuted.

I agree with the logic referee's issue 1, and upgrade it to major for this lens. I also agree with their issue 8: the claim "only after exponentially many samples" is not established, since the lower bound $\beta(n/2^d)$ also vanishes for $n=o(2^d)$.

**Fix.**

* In §0 and §5.2, write "uniform over the input dimension (here $d=\log_2n$)".
* Replace "for every $o(1)$" by "for every $o(1)$ that is uniform over $d\le n^\alpha$".
* Add Proposition R1 (one paragraph) as the fixed-$d$ counterpoint.

### S3 (major for reporting): A′ does not meet the "real inputs do not repeat" objection in the sense a skeptic means

**Locations.**

* §7 introduction: "The construction below meets both objections."
* Remark 7.3: "The inputs have a density and never repeat."
* §0 item 6.
* §10, which does not list the bounded-density case as open.

**Problem.** A′'s argument (Theorem 7.2, Step 2) works only because every test point lies within the learner's resolution of a training point. The resolution is $\rho_{\rm res}=\frac{\sqrt d}2(L/K_2)^{L/2}$, the distance over which a near-minimizer can change by $\frac12$.

* For any input law whose density is at most $K$ times the uniform density, a test point has a training point within $\rho_{\rm res}$ with probability at most $nK\,{\rm vol}(B_d(\rho_{\rm res}))\,2^{-d}$.
* At $n=2^d$ this is $\le K\cdot2^{-(L/2)d^2(1-o(1))}$ (§4.2).
* The mechanism therefore needs a density ratio of $2^{(L/2)d^2(1-o(1))}$, which is $10^{161}$ already at $(H,d)=(2,20)$. A′'s actual ratio is $r^{-d}=10^{287}$ to $10^{1397}$ (`aprime_scale.out`).

For laws with density ratio $2^{o(d^2)}$, including uniform inputs on $[-1,1]^d$, A′ gives nothing. Whether SP$_c$ fails there is a benign-versus-tempered overfitting question that `../research-notes/red-team.md` §6.4 lists as open. A-first-version.md never mentions it.

A skeptic would say that A′'s inputs repeat at the learner's resolution, and that its "deterministic" labels are pure noise at that resolution. A-first-version.md partly concedes this in Remark 7.3 ("fine-scale structure … acts as noise").

The construction is a valid counterexample to the *distribution-free* (P$_L$). It does not answer the objection as a skeptic means it.

**Fix.**

* Change "meets both objections" to "meets both objections formally: the inputs are atomless and the labels deterministic, but the law is near-atomic at the learner's resolution, with density $r^{-d}=\exp(\Theta(Ld^2))$ times uniform."
* Add to §10: "Input laws with density ratio $2^{o(d^2)}$, e.g. uniform inputs, and noisy labels: open."

### S4 (minor, but it changes the TUBE headline): TUBE with $\rho_n\to0$ on continuous i.i.d. inputs is not covered, and A′ provably does not transfer to TUBE

**Location.** §6.2, after Proposition 6.3: "An MSE-consistent TUBE learner needs $\rho=\rho_n\to0$. Then the next two results apply." Also the title's claim that tightly conditioned learners fail.

**Problem.** Neither of the two results covers the i.i.d. continuous case.

* Lemma 6.4 needs atoms, and it proves undefinedness, not a risk bound.
* Proposition 6.5 uses sampling without replacement, so it lies outside (P$_L$), which assumes i.i.d. data.

On continuous i.i.d. inputs, the native setting of the TUBE learner's own paper (`paper.tex`, "continuous domains"), A-first-version.md proves nothing for $\rho<1$.

A′ cannot be reused for TUBE. Observation R3 (§4.3) shows that every TUBE-feasible network on A′ data has energy above $(2-2\rho)^{2/L}n^{2/L}K_2$. That is $10^3$ to $10^8$ times $K_2$ (`tube_aprime.out`). Such a network varies by more than $2-2\rho$ inside some cluster, so Step 2 of Theorem 7.2 is unavailable.

So the tightest conditioning is not shown to fail on deterministic labels. A′'s failure depends on the residual budget $c(K_{\rm mem}+t)$, which lets SP$_c$ average labels over a cluster.

**Fix.**

* Change the sentence to: "On laws with atoms, the next two results apply: Lemma 6.4 for i.i.d. sampling, and Proposition 6.5 without replacement, which is outside (P$_L$). For continuous i.i.d. inputs and $\rho<1$, nothing is proved here, and A′ does not transfer (Observation R3)."
* Optionally add the fixed-$d$ TUBE negative of §4.4, which A-first-version.md's own lemmas already give.

### S5 (minor): "under every reading of the $\sigma\to0$ learner" includes the progressive mixture, which is not covered

**Location.** §0 item 4.

I agree with the logic referee's issue 2. Brief §2 lists the progressive mixture, and it is the predictor of the positive Claim C, so a skeptic may call it the natural Bayesian predictor here. §10 item 4 itself says it is not covered.

**Fix.** "under each of the readings (R1)–(R3); the progressive mixture is not covered (§10)."

### S6 (minor): the learner widths at which failure is proved should be stated

**Location.** §0 item 3 ("$N_0={\rm poly}(n)$").

The proved failure needs widths far beyond $n$: $N_0/n$ is about $2\cdot10^5$ to $7\cdot10^6$ at $a\in\{0.1,0.3\}$, and about $44\,d(d+1)\,n^{2/3}$ with $a=a_d$ (Corollary 4.5). `../research-notes/red-team.md` Proposition 6.1 claims success for $c=1$ at learner width $\le n^{1/4}$. A user who reads the conjecture as being about a learner of width poly($n$) with a small exponent is therefore not answered. §5.2 item 3 acknowledges this, but §0 hides the order.

**Fix.** "$N_0=O(n\log^2n/a^2)$ at fixed accuracy $a$. Nothing is proved for widths at most of order $n$."

### S7 (minor): the finite-scale status is inconsistent with the sibling ../research-notes/E-finite-prior-scale.md, and "the slt-likelihood theorem" is ambiguous

**Locations.**

* §10 item 3: "this remains open".
* §5.2 item 5: "This includes the clean-label scaling $c=1$ of the slt-likelihood theorem."

**Problems.**

* The slt-likelihood note has two positive theorems: a strong-prior one, and a finite-scale one with observation variance $N^{-\gamma}$. A-first-version.md covers only the former.
* ../research-notes/E-finite-prior-scale.md (Theorem 5.2, Corollaries 5.3–5.4) claims the finite-scale transfer of Claim A for every $\gamma\ge1$.

**Fix.** Write "the strong-prior theorem of slt-likelihood §2", and cite ../research-notes/E-finite-prior-scale.md for the finite scale, or flag the discrepancy until ../research-notes/E-finite-prior-scale.md is refereed.

### S8 (minor): the "open window" in $c$ is stale for clipped predictors

**Locations.**

* §8.3: "What remains open is the test excess for $n^{1-1/H}{\rm polylog}\ll c\ll n^{1-1/(H+1)}$."
* §10 item 5.

**Problem.** ../research-notes/B-tempered-likelihood.md Theorem 6.3 claims vanishing excess for clipped predictors for all $\theta<1/H$. For clipped predictors, only ../research-notes/B-tempered-likelihood.md's own polylogarithmic window remains: $n^{1-1/H}(\log n)^{-2/H}\lesssim c\lesssim n^{1-1/H}(\log n)^{2/H}$ (../research-notes/B-tempered-likelihood.md §7, remark 1). The unclipped window $\theta\in[1/L,1/H]$ remains open (../research-notes/B-tempered-likelihood.md Theorem 6.4).

**Fix.** "Open for unclipped predictors. For clipped predictors it is closed by ../research-notes/B-tempered-likelihood.md Theorem 6.3, up to a polylogarithmic window around $c\asymp n^{1-1/H}$."

### S9 (minor): the "undefined" convention for TUBE

**Locations.** Lemma 6.4, Table 6.1, §0 item 5.

I agree with the logic referee's issue 11, and add one point. If the learner falls back to the prior mean $0$ when $U_{\rho,S}=\emptyset$, then on fair labels the "undefined" row is **not** a failure at all: $0$ is Bayes-optimal on $D_d$. A failure needs non-centred labels; see §4.4, which gives a negative that holds even at fixed $d$.

**Fix.** State the convention. Add Observation R4 if desired.

### S10 (cosmetic): Remark 4.9's wording

**Location.** Remark 4.9: "every function, the teacher included, pays training residual $\approx n\,\mathbb E\,{\rm Var}(y\mid x)$."

The memorizer pays only $W+o(n)$, which is what the next sentence says.

**Fix.** "every function of bounded energy, the teacher included, …"

---

## 4. Adversarial scenarios

For each natural reading I asked two questions: does a stated result of A-first-version.md become false, and does the claimed refutation still reach it?

### 4.1 Fixed input dimension: the cube family refutes nothing

**Proposition R1.** Fix $d$, $H\ge1$ and $c,t>0$, and let $S\sim D_d^{\otimes n}$. Write $\Delta(0)=\sum_xk_x\bar y_x^2$ and $k_{\min}=\min_{x\in\mathcal C_d}k_x$. On $\{k_{\min}\ge1\}$, for **every** width $N$ and every $w\in\mathcal N_t(S)$,
$$L_{D_d}(z_w)-1=\frac1M\sum_xz_w(x)^2\le\frac1M\Big(\sqrt{\tfrac{\Delta(0)+ct}{k_{\min}}}+\sqrt{\tfrac{\Delta(0)}{k_{\min}}}\Big)^2\le\frac{2\,(2\Delta(0)+ct)}{M\,k_{\min}} .$$
With probability at least $1-\delta'-Me^{-n/(8M)}$, the right side is at most $(8M/\delta'+4ct)/n$.

*Proof.*

* **Residual comparison.** By Lemma 4.1(a), $F_{c,S}(w)=\kappa_N(w)+(\Delta(z_w)+W)/c$ and $F_{c,S}(0)=(\Delta(0)+W)/c$. Since $w\in\mathcal N_t$, $F_{c,S}(w)\le F_{c,S}(0)+t$. Hence $\Delta(z_w)\le\Delta(0)+ct-c\kappa_N(w)\le\Delta(0)+ct$.
* **All atoms seen.** On $\{k_{\min}\ge1\}$, $\sum_x(z_w(x)-\bar y_x)^2\le\Delta(z_w)/k_{\min}$ and $\sum_x\bar y_x^2\le\Delta(0)/k_{\min}$. Minkowski's inequality in $\mathbb R^M$ gives the first bound, and $(u+v)^2\le2u^2+2v^2$ the second.
* **Size of $\Delta(0)$.** For fair labels, $\mathbb E[k_x\bar y_x^2\mid k_x=k]=k^{-1}\mathbb E(\sum_{j\le k}y_j)^2=1$ for $k\ge1$. So $\mathbb E\Delta(0)=\sum_x\Pr[k_x\ge1]\le M$, and Markov gives $\Pr[\Delta(0)>M/\delta']\le\delta'$.
* **Size of $k_{\min}$.** The Chernoff bound $\Pr[{\rm Bin}(n,p)\le np/2]\le e^{-np/8}$ and a union over the $M$ atoms give $\Pr[k_{\min}<n/(2M)]\le Me^{-n/(8M)}$.
* **Conclusion.** On both events the bound is $2(2M/\delta'+ct)\cdot\frac{2M}{Mn}=(8M/\delta'+4ct)/n$. $\square$

The same bound holds for the clipped outputs, since $|{\rm clip}\,u|\le|u|$. In the $\sigma\to0$ limit it holds for the Gibbs predictor (Corollary 3.3) and for the posterior means: $\Delta$ is convex (Jensen), and (3.3) applies.

**Consequence.** At fixed $d$ the cube example certifies only $O(M/n)$, uniformly in the width. So "refuted for every $o(1)$" (§5.2 item 2) is false once the $o(1)$ may depend on $d$.

`fixed_d_consistency.out` shows the median bound at about $4M/n$ for $d\in\{6,8\}$, against Theorem 4.4's $\beta(n/M)\approx M/n$:

| $\lambda=n/M$ | 64 | 256 | 1024 | 4096 |
|---|---|---|---|---|
| bound, $d=8$ | 0.094 | 0.019 | 0.0043 | 0.0010 |
| $\beta(\lambda)$ | 0.0159 | 0.0039 | 0.00098 | 0.00024 |

This only concerns the cube family. A-first-version.md does not claim, and I do not settle, whether some other fixed-$d$ family defeats SP$_c$.

### 4.2 Inputs without near-duplicates: the A′ mechanism needs a density ratio of $2^{(L/2)d^2}$

**Observation R2.** Suppose the $x$-marginal has density at most $K\cdot2^{-d}$, that is, at most $K$ times uniform on $[-1,1]^d$. For $n$ training inputs and an independent test input $x$,
$$\Pr\Big[\min_i\|x-x_i\|\le\rho\Big]\le nK\,{\rm vol}(B_d(\rho))\,2^{-d}.$$

Theorem 7.2 transfers fitted noise to a test point only through Lemma 3.1(b), with $\kappa_N\le K_2\approx n/c$. So it needs a training point within $\rho_{\rm res}=\frac{\sqrt d}2(L/K_2)^{L/2}$.

* With $n=2^d$, $c=1$ and Stirling, $\log{\rm vol}(B_d(\rho_{\rm res}))=-\frac L2d^2\log2+O(d\log d)$.
* Hence the probability above is $\le K\,2^{-(L/2)d^2(1-o(1))}$.

| $(H,d)$ | $\log_{10}r$ | A′ density ratio $\log_{10}r^{-d}$ | $\log_{10}\Pr$ (uniform law) |
|---|---|---|---|
| (2,20) | −14.3 | 286.7 | −160.9 |
| (2,30) | −21.9 | 655.8 | −376.5 |
| (3,40) | −34.9 | 1396.8 | −903.6 |

These values come from `aprime_scale.out`. A-first-version.md's own A′ value $r\approx10^{-22}$ at $d=30$, $H=2$ is reproduced.

For laws whose density ratio is $2^{o(d^2)}$, the argument of Theorem 7.2 says nothing, and the question is open (S3).

### 4.3 TUBE on A′ data: every feasible network resolves the clusters

**Observation R3.** Take the law of Theorem 7.2 (any $c>0$, its radius $r$) and $0<\rho<1$. Suppose some cluster $X_p$ contains two training points with different labels. Then every $w\in U_{\rho,S}$ satisfies
$$\kappa_N(w)>L\Big(\frac{2-2\rho}{r}\Big)^{2/L}=(2-2\rho)^{2/L}\,n^{2/L}\,K_2 .$$

*Proof.* For the two points, $|z_w(x_i)-z_w(x_j)|>2-2\rho$ and $\|x_i-x_j\|\le r\sqrt d$. Lemma 3.1(b) gives $(\kappa_N/L)^{L/2}r>2-2\rho$. Substitute $r=\frac1n(L/K_2)^{L/2}$. $\square$

The hypothesis holds with probability $1-e^{-\Omega(M)}$ at $n=\lambda M$. This follows from Lemma 7.1(b) and Lemma 6.4(b), since the pairs $(p_i,y_i)$ are i.i.d. from $D_d$; Monte Carlo gives probability $1.000$ at $d=6,\dots,12$. At $\rho=\frac12$ the energy floor is $10^3$ to $10^8$ times $K_2$ (`tube_aprime.out`).

So the localization of Theorem 7.2 is unavailable for TUBE, at every $\sigma$. A′ yields no TUBE lower bound, and the TUBE learner's behaviour on A′ data, success or failure, is not determined.

### 4.4 A TUBE negative that holds at fixed $d$, from A-first-version.md's own lemmas

**Observation R4.** Fix $d\ge1$. Let $x$ be uniform on $\mathcal C_d$, and $y\in\{\pm1\}$ with $\Pr[y=1\mid x]=\frac{1+\eta_0}2$, $\eta_0\in(0,1)$. The width-one constant network $g\equiv\eta_0$ of Proposition 6.3 has weights $\le2$ and Bayes risk $L_D(g)=1-\eta_0^2$.

* **$\rho>1$.** For every $n$ and every width, as $\sigma\to0$, the TUBE Gibbs and posterior-mean risks tend to $L_D(0)=L_D(g)+\eta_0^2$ (Lemma 6.2 and Proposition 6.3(a)). No convention is needed.
* **$\rho\le1$.**
  * The posterior is undefined once an atom carries both labels (Lemma 6.4(a)).
  * Fix one atom $e$. Then $\Pr[\text{no conflict}]\le\mathbb E[p^{k_e}+(1-p)^{k_e}]\to0$ as $n\to\infty$, because $k_e\sim{\rm Bin}(n,1/M)\to\infty$. Monte Carlo at $d\in\{1,3\}$, $n=64$ gives $0.000$.
  * A fallback to the prior mean $0$ has excess $\eta_0^2$.

So no tolerance $\rho$ makes TUBE an MSE learner for non-centred $\pm1$ noise, even at fixed $d$ (S9).

### 4.5 Other readings

* **Learner width.** The negative needs $N\ge N_0$, with $N_0/n\approx10^{5}$–$10^{7}$ at fixed $a$. If the learner's width is chosen as $n^\alpha$ with $\alpha<1$, A-first-version.md says nothing; §5.2 item 3 acknowledges this. `../research-notes/red-team.md` Proposition 6.1 claims success for $N\le n^{1/4}$ (S6).
* **Finite scale $\mu_{N,\gamma}$** (the repository's main $\gamma\ge1$ learners, and the finite-scale theorem of slt-likelihood §2). Not covered by A-first-version.md. ../research-notes/E-finite-prior-scale.md claims it (S7).
* **Progressive mixture.** Not covered (S5).
* **Depth two.** Open, as acknowledged.
* **Aggregate conditioning.** Here "condition close to the outputs" means empirical MSE $<\tau$. If $\tau\to0$, this is like SP$_c$ with small $c$. If $\tau\approx\mathrm{OPT}$, it is a different learner (`../research-notes/red-team.md` Remark 6.2). Not covered (S1).
* **Data-dependent $c$** (empirical Bayes, cross-validation). Not a fixed learner, so outside (P$_L$). Not covered.

### 4.6 Order of limits and loss: no issue

* **Limits.** A-first-version.md takes $\sigma\to0$ after fixing $(d,N,n,c,t,S)$. This is the order of `paper.tex` Theorem `strong` and of slt-likelihood §2.
  * Reading (R1) lets $\sigma_0$ depend on $(d,n,N,D,g,\varepsilon,\delta)$. That is more lenient than both sources: in Theorem `strong`, $\sigma_0$ does not depend on $D,n,\delta$.
  * The refutation holds for **all** $\sigma<\sigma_0'$, so it also covers "along some sequence $\sigma_k\to0$" and every weak limit.
* **Loss.** It is MSE against fresh noisy labels, which is what the user asked for, both clipped and unclipped. The slt-likelihood guarantee concerns the latent mean, not a noisy observation. This is a different quantity, and there is no clash.

---

## 5. Consistency with repository theorems: no contradiction found

| repository result (checked in source) | its hypotheses | A-first-version.md's setting | consistent? why |
|---|---|---|---|
| slt-likelihood §2, strong-prior theorem (SP$_1$) | clean labels $y=f(x)$ with $f$ a width-$C$ teacher; posterior confidence for $\lvert z_w-f\rvert\le\tau$; residual budget $cK$, $K=E_\star+1$ | noisy labels with ${\rm Var}\ge v_0$, or the A′ labels $f^\star$ | Yes. With noise the teacher's own residual is $\Theta(n)$, so the budget argument breaks (Remark 4.9). $f^\star$ jumps by 2 inside each connected cluster, so no continuous function is within sup-distance $<1$ of it, and no teacher exists. |
| slt-likelihood §2, finite-scale theorem | clean labels, $\mu_{N,\gamma}$, observation variance $N^{-\gamma}$ | not treated | No overlap (S7). |
| slt-likelihood §3 (a fixed likelihood gives posterior $\to$ prior) | fixed likelihood temperature | co-scaled likelihood $c\sigma^2$ | No overlap. A-first-version.md's finite-scale TUBE remark uses §3's bound $\mathbb E[z^2\mid\text{hidden}]\le N^{-\gamma}$ correctly. |
| `paper.tex` Theorems `strong` and `finite` | TUBE with clean labels; error at tolerance $\tau>\rho$ | Proposition 6.3(b) with $b=0$: clean constant $\eta_0<\rho$ | Yes. The collapse to $0$ has $\lvert0-\eta_0\rvert<\rho<\tau$, so tolerance error $0$ but MSE $\eta_0^2$. Those theorems are not MSE statements. |
| `paper.tex` Proposition `exact` and Corollary `exact` | clean labels; energy $\le E_*$; fit within $\tau/2$ | noise memorizers with $K_{\rm mem}\to\infty$ | Yes. A capacity check is also fine. Memorizers at energy $K$ realize all sign patterns on $s\asymp(K/H)^H/d$ points (Lemma 2.1; Proposition 8.2 matches). A cover must then have $\log$-size $\gtrsim(K/H)^H$. The repository cover has degree about $4(L-1)=4H\ge H$ in $K$. |
| noisy-interpolation theorem (README §1) | margin-conditioned hard constraints; distinct inputs without replacement; $\le s$ corruptions of a clean $\pm1$ target; clean classification error $\le(B_L+As+8\log\frac1\delta)/n+\tau$, $A=O(U^2d^4)$ | SP$_c$/TUBE; MSE against noisy labels | Yes. The explicit coefficient is $A=2+8b_1\ge2$ (README, line 492). At fair-coin noise, $s\approx n/2$, so the bound is at least $As/n\approx A/2\ge1$, which is vacuous. Even at $n=M$, memorizing $s$ flips costs clean error $s/M\le As/n$. |
| FAQ Q33 scope ("Repeated inputs with contradictory labels would make exact conditioning impossible") and Q34 ("do not assert the same bound for data corrupted by fixed positive observation noise") | — | Lemma 6.4(a), Claim A | Same statements. |
| `NNG/README.md` main result 1 ("polynomial in input dimension") | — | (P$_L$) uniform in $d$ | Supports the brief's $d$-uniform reading (S2). |
| ../research-notes/B-tempered-likelihood.md (sibling; not refereed by me) | SP$_c$ with $c=n^{1-\theta}$: success for $\theta<1/H$ (clipped) and $\theta<1/L$ (unclipped); failure for $\theta>1/H$ | failure for $cK_{\rm mem}=o(n)$, i.e. $\theta>1/H$ up to logarithms | Consistent. ../research-notes/B-tempered-likelihood.md closes A-first-version.md's "open window" for clipped predictors (S8). |
| ../research-notes/E-finite-prior-scale.md (sibling; not refereed by me) | claims Claim A at every $\gamma\ge1$ | §10 item 3 says "open" | Wording inconsistency (S7). |

---

## 6. Would the user accept it?

**What the user should accept.** SP$_1$ in the strong-prior limit is the repository's own clean-label Gaussian learner (slt-likelihood §2; FAQ Q34). The order of limits is the repository's. The loss is the requested MSE. The competitor is the trivial network. The failure holds for near-minimizers, Gibbs draws and posterior means, at every large width.

Within the repository's $d$-uniform, width-uniform notion of "polynomial sample complexity", the user should accept the following. Tightly conditioned SP$_c$ ($c\ll n^{1-1/H}$, including $c=1$) is not an agnostic learner at depth $\ge3$. TUBE is not an MSE learner under label noise.

**What the user will object to, with justification.**

1. "I said pick the best version." The conjecture is untouched, and ../research-notes/B-tempered-likelihood.md is the relevant positive section (S1).
2. "I meant $n\to\infty$ at fixed $d$." The cube example is consistent at fixed $d$ (S2).
3. "Real inputs have no near-duplicates." A′ is near-atomic at density ratio $10^{287}$ or more. The bounded-density case is open (S3).
4. "Why would the learner be $10^6\,n$ wide?" (S6). The repository's results are width-uniform, so within its framework this objection is weak, but it should be stated.
5. "TUBE is the continuous-domain learner." On continuous i.i.d. inputs nothing is shown (S4).

**What the user will probably not object to.** The loss, the order of limits, and the triviality of the competitor.

---

## 7. Numerical checks

1. **`fixed_d_consistency.py`.** Simulates Proposition R1's width-uniform upper bound on the excess of every near-minimizer, for $d\in\{6,8\}$ and $n/M\in\{1,\dots,4096\}$ (200 or 40 repetitions).
   * The bound is infinite until every atom is seen.
   * After that its median decays as about $4M/n$: for example $0.0010$ at $n/M=4096$, against $\beta(4096)=0.00024$.
   * $\Delta(0)/M\approx1$, as computed.
2. **`aprime_scale.py`.**
   * A′ radius: $\log_{10}r=-14.3$ to $-34.9$.
   * Density ratio $r^{-d}$: $10^{287}$ to $10^{1397}$.
   * Near-duplicate probability for the uniform law: $10^{-161}$ to $10^{-904}$.
   * $N_0/n$ at fixed $a$: $2\cdot10^5$ to $7.3\cdot10^6$.
   * Certified limiting excess $(\sqrt{\beta(1)}-a)^2$: $0.356$ at $a=0.1$ and $0.157$ at $a=0.3$, matching A-first-version.md Remark 4.7.
3. **`tube_aprime.py`.**
   * Observation R3's energy floor: $10^3$ to $10^8$ times $K_2$.
   * Probability that some cluster carries both labels at $n=M$: $1.000$ for $d=6,\dots,12$.
   * Fixed-$d$ non-centred labels ($\eta_0=\frac12$), probability of no conflict: $d=1$ gives $0.41$, $0.014$, $0.000$ at $n=4,16,64$; $d=3$ gives $0.75$, $0.031$, $0.000$.

---

## 8. Summary for the lead

* **Mathematics.** Sound. No theorem is false, and there is no clash with the slt-likelihood theorems, the continuous-domain strong, finite and exact results, the noisy-interpolation theorem, or FAQ Q33–34. The order of limits and the loss match the brief and the repository.
* **Scope.** A-first-version.md proves less than its summaries say. Before anything goes to the user:
  * **S1.** State that the conjecture, which is existential in the learner, is not refuted. What is refuted is the "condition closely" heuristic. Point to ../research-notes/B-tempered-likelihood.md and ../research-notes/E-finite-prior-scale.md.
  * **S2.** Qualify the refutation as uniform over input dimension ($d=\log_2n$). At fixed $d$ the cube example is consistent at every width (Proposition R1).
  * **S3.** Say that A′ is near-atomic: its density is $\exp(\Theta(Ld^2))$ times uniform. List bounded-density inputs with noisy labels as open.
  * **S4.** Restrict the TUBE conclusions to laws with atoms. A′ provably does not transfer to TUBE (Observation R3). An optional fixed-$d$ TUBE negative is Observation R4.
* **Minor.**
  * S5: the progressive mixture is not covered.
  * S6: give the order of $N_0$, $\gtrsim n\log^2n/a^2$.
  * S7, S8: reconcile with ../research-notes/E-finite-prior-scale.md and ../research-notes/B-tempered-likelihood.md.
  * S9: state the "undefined" convention.
  * S10: wording in Remark 4.9.
