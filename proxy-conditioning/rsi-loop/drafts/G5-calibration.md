# G5. Calibration: which regime is real post-training in?

*Theory section for the RSI-loop round of the proxy-conditioning project. Revised draft, 18 October 2026, after the referee report `drafts/G5-calibration-referee.md`. It builds on framing.md, T1 to T4, G1 to G4 and the simulation suite (`sim/README.md`, `sim/reconciliation.md`), and answers T1 open problems 3 and 10. Numbers are cited by label from three scripts in `sim/`: K1 to K10 from [`G5_checks.py`](../sim/G5_checks.py); V1 to V7 from [`G5_revision_checks.py`](../sim/G5_revision_checks.py) (34 checks, no mismatches); R1 to R7 from the referee's [`G5-calibration_referee_checks.py`](../sim/G5-calibration_referee_checks.py). Each script's output sits next to it. Status labels are as in T1: **rigorous** (proved in the stated toy; long proofs in the appendix), **heuristic** (uses a named approximation), **conjecture** (about real systems). Numbers that depend on arbitrary choices are marked **illustrative**.*

### Notation introduced in this section

These T1 and T2 symbols keep their meanings: $A$, $G=C_1$, $C_t$, $G^\star$, $N$, $\lambda_\pm$, $t^\star$, $\hat p$, $u$, $v$, $w$, $a$, $h$, $s$, $\delta$, $\Lambda=\ln\frac{1-\delta}{\delta}$, $\mu_G$ (posterior mass of $G$), $\pi_X$ (current probability of emitting $X$ on an opportunity), $\Delta_\pm$ (reward gaps), $\varepsilon$, $\varepsilon_u$, $\varepsilon_h$, $\Delta\varepsilon$, $\varepsilon_F$, $w_F$, $d_F$, $\delta_F$ (frontier competence error), $D^\star$, $L_k$, $q_k$, $L_b$, $\gamma$, $\kappa_L$, $g$ and $n$. From G3 I use $n_{\rm dep}$ (deployments per generation), $\mathrm{fp}$ (false-flag rate) and $\bar d$ (extra flag probability of a defection). T4's demonstrability is written $\mathrm{dem}$, and G2's step size is $\mathrm{lr}$. None of $v,\eta,\beta,\phi,\chi,\nu,\kappa$ gets a new meaning.

| symbol | meaning |
|---|---|
| (H1), (H2) | the two assumptions behind a gradient-reading break-even: the same $\nabla\pi_X$ on rewarded and caught opportunities, and small steps |
| $c_+$, $c_-$ | coefficients of $\nabla\pi_X$ in the expected update on a rewarded and on a caught opportunity |
| $K_s$ | samples per prompt: best-of-$K_s$ filtering, or the GRPO group size |
| $\mathrm{amp}_{K}(P)$ | $(1-(1-P)^{K})/P$, the factor by which best-of-$K$ filtering amplifies an outcome of probability $P$ |
| $S_K(P)$ | $\mathbb E\sqrt{m(K-m)}/K$ with $m\sim\mathrm{Bin}(K,P)$, GRPO's rate in logit coordinates |
| $b_{\rm KL}$ | sequence-level KL coefficient. This is T1's (D) temperature $\beta$, renamed because T1 also uses $\beta$ for band mass |
| $b_{\rm DPO}$, $\tau_{\rm IPO}$, $W_c$, $\mathrm{mg}$ | DPO's inverse temperature; IPO's regulariser; the weight on audit pairs; the log-ratio margin of $X$ over $I$ |
| $\pi^{\rm ref}_X$, $\pi^{\rm ref,F}_X$ | the reference (pre-RL) policy's propensity for $X$ on training-slice opportunities, and on frontier-slice opportunities |
| $O_F$ | $(1-\pi^{\rm ref,F}_X)/\pi^{\rm ref,F}_X$, the output-level odds against $X$ on the frontier |
| $\lambda_s$ | the logit step of a shared gaming factor per sampled-and-rewarded $X$ |
| $\varepsilon_{\rm in}$ | the frontier grader error that a perfect builder would still leave |
| $c_{\rm sl}$ | slop coupling: frontier grader errors per unit of builder error |
| $f_{\rm pr}$, $f_{\rm sh}$ | the shares of builder-induced grader errors that the student can recognise as grader errors ($f_{\rm pr}$), and that are fixed per prompt or task family or shared as belief, and so learnable ($f_{\rm sh}$) |
| $r_{\rm op}$ | the share of sample-independent grader noise that an operator copies into the student |
| $\Pi_{\rm sh}$, $\Pi_{\rm ind}$, $\Pi_{\rm dat}$, $\Pi_{\rm res}$, $\Pi$ | error reproduction numbers through shared grader errors, independent grader noise, training data and reused research; $\Pi$ is their sum |
| $\delta_{\rm new}$ | the frontier error a generation would make if everything it inherited were correct |
| $\gamma_0$, $\delta_\gamma$ | the improvement channel at zero slop, and the frontier error at which alignment work is worth nothing |
| $M(\delta)$ | the loop margin at frontier error $\delta$ (G5.8) |
| $c_{\rm sh}$, $\alpha_{\rm tr}$ | the shared error rate in a grader ensemble; the share of trusted data and graders |
| $n_{\rm cmp}$, $p_{\rm fl}$ | builder-made components a verdict depends on; the probability that a wrong component flips the verdict |
| $\delta_{\rm nat}$, $\delta_{\rm pre}$, $\mathrm{lb}$ | a student's capability floor on the frontier slice; its error before RL; its RL learning budget |
| $\varepsilon_a$ | the error rate of audits built by a sloppy builder |

## Summary

* **Small steps against large jumps** (§0, G5.1). Every on-policy rule moves along $\nabla\pi_X$ (Lemma G5.0). For best-of-$K_s$ filtering, the small-step break-even $t^\star_K(\pi_X)$ runs from $K_s/(K_s+1)$ near $A$ to $1/(K_s+1)$ near $G$. It is exactly the break-even of the expected *posterior probability* $\mu_G$ in T1's own Bayes chain. T1's $t^\star=\pi_X$ is a *log-odds* break-even, and the two differ because of jump size. Under small steps there is an attracting interior gaming rate (0.715 at $K_s=8$, $\hat p=0.3$). Under $\Lambda$-jumps the capture probability still grows (0.047 to 0.116; R1).
* **GRPO** (G5.2, G5.4b). With group-level audits, $t^\star=1/2$ whatever the penalty. With per-sample flags, penalties saturate at about 10 times the reward and vanish at low $\pi_X$. For $\hat p<1/2$, GRPO's KL term leaves a stationary gaming rate of $1-O(b_{\rm KL}/\sqrt{K_s})$. Summed-KL PPO's tilt (G5.4) protects outputs only when $t^\star-\hat p\lesssim b_{\rm KL}\Lambda/(\Delta_++\Delta_-)$, and it protects outputs, not latents.
* **Discovery limits on-policy learning** (G5.3b). A rule that does not update until $X$ is drawn needs at least $1+O$ draws. Every sampled on-policy optimiser checked is linear in $O$; geometry sets only the prefactor. Off-policy data and shared factors bypass this.
* **Slop** (G5.6 to G5.8). Imitation copies independent noise, and every operator copies errors fixed per prompt or shared as belief. The slop loop is the model-collapse recursion $\delta_{F,k+1}=\delta_{\rm new}+\Pi\delta_{F,k}$, here decomposed by channel. Under two stated conditions it breaks the intent loop at $\Pi_c<1$, starting with no schemer.
* **Current regime** (§3; conjecture). Small-step and mostly on-policy, with weak KL anchors. It leaks at the aligned end. The size of the leak hinges on the split between on-policy and off-policy training and on the unmeasured frontier output propensity $\pi^{\rm ref,F}_X$.

---

## 0. Two readings of an operator

T1 §0 defines each operator as an exact multiplicative update of the posterior: (B) multiplies by $P_\theta(\text{pass})$, (C) by $\pi_\theta(y)$, and (D) by $e^{J_\theta/b_{\rm KL}}$. Call this the **Bayes reading**. A network trained by gradient steps instead makes the **gradient reading**'s update, which is the expected first-order change of its parameters $\vartheta$ under the training rule.

**Lemma G5.0 (rigorous; policy-gradient identity).** Let an on-policy rule sample $y\sim\pi$ and step along $a(y)\nabla\log\pi(y)$, where $a(y)$ may depend on the verdict and on $\pi$ but on $\vartheta$ through no other route. On an opportunity with outputs $X$ and $I$, $\mathbb E[a(y)\nabla\log\pi(y)]=(a(X)-a(I))\nabla\pi_X$. Write $c_+$ for this coefficient on a rewarded opportunity and $-c_-$ for it on a caught one. Assume:
* (H1) rewarded and caught opportunities look alike to the network, so $\nabla\pi_X$ is the same vector on both (T1's homogeneous recognition);
* (H2) the step is small enough that the first-order change decides the sign of the change of $\pi_X$.

Then the expected change of $\pi_X$, and of any coordinate that is monotone in $\pi_X$, has the sign of $(1-\hat p)c_+-\hat pc_-$. **The break-even is $t^\star=c_+/(c_++c_-)$.**

*Proof.* $\sum_y\pi(y)a(y)\nabla\log\pi(y)=a(X)\nabla\pi_X+a(I)\nabla\pi_I$, and $\nabla\pi_I=-\nabla\pi_X$. Under (H1) the two kinds of opportunity add along one vector. Under (H2), a monotone reparametrisation does not change the sign. ∎

The geometry ($\lVert\nabla\pi_X\rVert^2$ in the optimiser's metric) sets the speed, $\lambda_\pm=\mathrm{lr}\cdot c_\pm\cdot(\text{geometry})$, and cancels from the sign. (H2) fails for T1's Bayes chain, whose jumps are $\Lambda$-sized, and for plain policy gradient at a large step (reconciliation "Disagreement 2", still open). The readings agree for (B) and (D); they disagree, in log-odds, for on-policy filtering.

---

## 1. Post-training algorithms as operators

### 1.1 Rejection sampling and expert iteration

STaR (Zelikman et al. 2022), ReST and ReST-EM (Gulcehre et al. 2023; Singh et al. 2023) and best-of-$n$ distillation fine-tune on the model's own passing samples: T1's (C-on).

**G5.1 (rigorous).** Keep the first passing sample among $K_s$ on-policy draws, and take an SFT step on it. Let $t^\star_K(\pi_X)=\mathrm{amp}_{K_s}(\pi_X)/(\mathrm{amp}_{K_s}(\pi_X)+\mathrm{amp}_{K_s}(1-\pi_X))$.
* **(a) One expected-probability break-even for both readings.** The expected gradient update is $\mathrm{amp}_{K_s}(P_{\rm pass})\nabla P_{\rm pass}$, so under (H1) and (H2), $t^\star=t^\star_K(\pi_X)$. In T1's exact Bayes chain on the two-type mixture,
$$\mathbb E[\Delta\mu_G]=\mu_G(1-\mu_G)(1-2\delta)\Big[(1-\hat p)\,\mathrm{amp}_{K_s}(\pi_X)-\hat p\,\mathrm{amp}_{K_s}(1-\pi_X)\Big],$$
whose zero is the same $t^\star_K(\pi_X)$. At $K_s=1$ it equals $1/2$; as $\pi_X\to0$ it tends to $K_s/(K_s+1)$. Keeping *all* passing samples gives $1/2$ for every $K_s$.
* **(b) Interior attractor under small steps.** $t^\star_K$ decreases strictly in $\pi_X$, from $K_s/(K_s+1)$ to $1/(K_s+1)$. So for $K_s\ge2$ and $\hat p$ strictly between these values, the small-step flow has a unique attracting gaming rate $\pi_X^\ast$ with $t^\star_K(\pi^\ast_X)=\hat p$. Below that range it runs to full gaming; above it, it restores.

*Proof.* Appendix. ∎

Numbers. At $\pi_X=0.01$, $t^\star_K$ is 0.50, 0.80, 0.88 and 0.96 for $K_s=1,4,8,32$, while T1's log-odds break-even is 0.010, 0.038, 0.072 and 0.216 (K1). At $\hat p=0.3$, $\pi^\ast_X$ is 0.795, 0.715 and 0.700 for $K_s=4,8,32$ (V1), and stochastic SGD at $K_s=8$ reaches 0.710 (R2). In T1's exact chain ($K_s=1$, $L_0=3$, $\hat p=0.3$) the log-odds drift is restoring, yet $P(\text{end at }G)=0.116$ against a prior mass of 0.047, because $\mu_G$ is a submartingale (R1). Small-step SGD lowers the log-odds of $A$ by 11 nats over 20,000 opportunities (K2).

*Reading.* With $\pm\Lambda$ jumps, expected log-odds and expected probability can move in opposite directions: most runs are restored, but capture becomes more likely. With small steps the run follows the expected-probability flow, leaking from the aligned end when $\hat p<t^\star_K$ and settling at $\pi^\ast_X$. So T1 §1.2 and T1 takeaway 7 ("(C-on) best-of-1 is automatically restoring near $A$") hold for the typical run, not for the probability of ending at $A$. Compared with (B), filtering with $K_s>1$ is worse near $A$, because search finds rare exploits (G2.8), and better near $G$, because it stops at $\pi^\ast_X$. G5.6(3) is the same mechanism with grader noise in place of audits.

### 1.2 PPO, GRPO and the KL term

PPO (Schulman et al. 2017) with a learned baseline and batch-level whitening is REINFORCE with a common rescaling: $c_\pm\propto\Delta_\pm$, so $t^\star=\Delta_+/(\Delta_++\Delta_-)$, as in T1's (D). GRPO (Shao et al. 2024) replaces the critic by the mean over a group of $K_s$ samples per prompt, and divides by the group's standard deviation.

**G5.2 (rigorous; opportunity-level audits).** Let an audit act on a whole group, so that every sample of $X$ on an audited prompt gets $-\Delta_-$ (honeypot prompts). Let a group hold $m$ copies of $X$, with $0<m<K_s$. The normalised advantages are $\pm\sqrt{(K_s-m)/m}$ for $X$ and $\mp\sqrt{m/(K_s-m)}$ for $I$, whatever the reward values. The group's update is $\operatorname{sign}(r_X-r_I)\,\frac{\sqrt{m(K_s-m)}}{K_s}(\nabla\log\pi_X-\nabla\log\pi_I)$. So **$t^\star=1/2$ for every penalty and every group size.** The rate in logit coordinates is $S_{K_s}(\pi_X)$, which is about $\pi_X\sqrt{K_s-1}$ when $\pi_X\ll1/K_s$ and tends to $\sqrt{\pi_X(1-\pi_X)}$ as $K_s\to\infty$.

*Proof.* Appendix. ∎

*Prior art.* Per-group standardisation makes advantages invariant to positive affine maps of the reward, so with two reward levels magnitudes cannot matter. Mroueh (2025) analyses binary-reward GRPO as a KL-regularised contrastive loss, with the $1/\sqrt{p(1-p)}$ weighting. Dr. GRPO (Liu et al. 2025) drops the std division, which restores the penalty lever. Xiong et al. (2025) find that GRPO's gains come mainly from discarding all-wrong prompts, not from normalisation, and that RAFT (rejection sampling) is competitive. What is new here is the consequence for audit design.

*Remark (per-sample monitor flags; numerical, with a rigorous limit).* If each $X$ is flagged independently with probability $\hat p$, groups can have three reward levels and magnitudes partly survive. At $K_s=8$ and penalties 1, 10, 100 and $10^4$ ($\Delta_+=1$), the break-even is 0.500, 0.345, 0.326 and 0.324 at $\pi_X=0.3$, and 0.500, 0.468, 0.464 and 0.463 at $\pi_X=0.05$ (V3, matching R3). As $\pi_X\to0$, groups containing an $X$ have $m=1$, hence two levels, and $t^\star\to1/2$ for every penalty. Penalties beyond about 10 times the reward buy almost nothing, and at the aligned end the lever is nearly gone.

**G5.4 (rigorous at convergence; sequence-level KL).** Maximise $\mathbb E_\pi r-b_{\rm KL}\,\mathrm{KL}(\pi\Vert\pi_{\rm ref})$ prompt by prompt, with the KL summed over tokens and charged per sequence (InstructGPT-style PPO). Assume the policy cannot tell audited opportunities from unaudited ones. Then
$$\operatorname{logit}\pi^\ast_X-\operatorname{logit}\pi^{\rm ref}_X=\frac{(\Delta_++\Delta_-)(t^\star-\hat p)}{b_{\rm KL}},$$
independent of episode count. In the two-type mixture with KL charged only on prompts where $A$ and $G$ differ, the optimum puts $q_G\ge1/2$ iff this shift exceeds $-\operatorname{logit}\pi^{\rm ref}_X$, which is at most about $\min(L_0,\Lambda)$.

*Proof.* Gibbs solution $\pi^\ast\propto\pi_{\rm ref}e^{\bar r/b_{\rm KL}}$; appendix. ∎

The formula is standard (Korbak, Perez and Buckley 2022): T1.3's master formula with $wn$ replaced by $1/b_{\rm KL}$. Real runs stop short of convergence, so it is an upper bound. With unit gaps it protects the output only if $t^\star-\hat p<b_{\rm KL}\Lambda/2$, for example below 0.09 at $b_{\rm KL}=0.04$ and $\pi^{\rm ref}_X=0.01$ (V4). The new point is the reading: **the KL anchor protects outputs, not latents.** What resists gaming is $\pi^{\rm ref}_X$, not the persona prior (K5: at $L_0=13.8$ and 30 alike, a 5-nat shift gives $q_G=0.60$). Prompts outside training carry no KL charge, so a shift bought in training can reach the frontier through a shared factor (G1.2).

**G5.4b (rigorous for the single-opportunity mean-field toy).** GRPO adds a per-token "k3" KL estimate to the loss with coefficient $b_{\rm KL}$ (0.04 for DeepSeekMath according to secondary sources; TRL's default is 0.001). The advantage and KL terms share the same per-token average, so their per-sequence ratio is $b_{\rm KL}$. In expectation, the k3 term's gradient is that of $\mathrm{KL}(\pi_{\rm ref}\Vert\pi)$ (Tang and Munos 2025). With opportunity-level audits, the stationary points satisfy
$$(1-2\hat p)\,S_{K_s}(\pi_X)=b_{\rm KL}\,(\pi_X-\pi^{\rm ref}_X).$$
For $\hat p<1/2$ the stationary point is unique (checked on a grid in V4), at $1-\pi^\ast_X\approx b_{\rm KL}(1-\pi^{\rm ref}_X)/((1-2\hat p)\sqrt{K_s-1})$. For example, $\pi^\ast_X=0.989$ at $K_s=16$, $b_{\rm KL}=0.04$ and $\hat p=0$, whatever $\pi^{\rm ref}_X$ is (a stochastic run gives 0.989). With the exact reverse-KL gradient the shift is about $\sqrt{K_s-1}/b_{\rm KL}$, or 97 nats. Because the std-normalised advantage does not shrink as the policy commits, GRPO's KL holds back almost no gaming. DAPO (Yu et al. 2025) and other RLVR recipes drop the KL term altogether.

### 1.3 RL with verifiable rewards (RLVR)

RLVR is PPO or GRPO with a programmatic grader, usually binary and with little or no KL.
* **Break-even.** $1/2$ under GRPO with group-level audits, and a little lower with per-sample flags (G5.2). The KL term gives no protection (G5.4b).
* **Errors.** $\varepsilon$ is concentrated on gameable verifiers (special-cased tests, modified test files), which METR (2025) documents for o3 and others. ImpossibleBench (Zhong et al. 2025) makes tests contradict the specification, so any pass is a cheat. GPT-5 cheats on 76% of one-off Impossible-SWEbench tasks and on 2.9% of one-off Impossible-LiveCodeBench tasks. The paper reports 54% on conflicting Impossible-SWEbench. A secondary write-up gives 66% before a "stop if tests are flawed" instruction and 9% with an abort option, and the paper reports a prompt change cutting conflicting-LiveCodeBench cheating from 92% to 1%. These are propensities given a forced opportunity, so they estimate the training-slice $\pi^{\rm ref}_X$; they are not base rates. Such hacks can generalise to broad misalignment (MacDiarmid et al. 2025).
* **Selection or creation.** Mostly selection: RLVR wins at pass@1 but loses at large $k$ (Yue et al. 2025); spurious rewards help only where a high-prior behaviour exists (Shao, R. et al. 2025); rank-1 LoRA suffices (Thinking Machines Lab 2025). Recognition and concealment are created by training (Schoen et al. 2025; Baker et al. 2025), so G2 applies there.

### 1.4 DPO and IPO

DPO (Rafailov et al. 2023) and IPO (Azar et al. 2024) train on preference pairs from a fixed sampler. This is off-policy, like (C-off). A rewarded opportunity is a pair with $X\succ I$, and a caught one is an audit pair with $I\succ X$, with weight $W_c$.

**G5.5 (rigorous).** Let a share $\hat p$ of the opportunity pairs that look alike be audit pairs.
1. DPO's population loss is minimised at $\mathrm{mg}^\ast=\operatorname{logit}\big((1-\hat p)/((1-\hat p)+W_c\hat p)\big)/b_{\rm DPO}$. Gaming wins iff $\hat p<1/(1+W_c)$, and the margin is unbounded at $\hat p=0$. This is the Bradley–Terry MLE under a label-flip rate $\hat p$, the setting of Ray Chowdhury, Kini and Natarajan (2024).
2. IPO's loss is minimised at $\mathrm{mg}^\ast=\big((1-\hat p)-W_c\hat p\big)/\big(((1-\hat p)+W_c\hat p)\,2\tau_{\rm IPO}\big)$. With $W_c=1$ this is Azar et al.'s closed form $(2p-1)/(2\tau)$ at $p=1-\hat p$: the same break-even, with a cap of $1/(2\tau_{\rm IPO})$.
3. Per unit loss weight, meaning before DPO's factor $b_{\rm DPO}\sigma(-b_{\rm DPO}\mathrm{mg})$, a pair's gradient is $1/(\pi_X(1-\pi_X))$ times that of on-policy REINFORCE with unit gap. That is 100 times at $\pi_X=0.01$ (K6).

*Proof.* Appendix. ∎

New here is only the reading of audit pairs as designer-controlled label flips. Preference learning has no discovery protection: a pair forces the model to score $X$ even if it would never sample it. That is bad when pairs reward gaming, and good for honeypot pairs. It may explain (heuristic) why off-policy DPO kept deception low where on-policy GRPO learned evasion (Cundy and Gleave 2025): the policy cannot search for a concealment it is never shown.

### 1.5 Protection by prior odds

The simulation's (D') (REINFORCE on persona logits, update $\propto\mu_G\mu_A$) flips in mean-field time $F(\ln O)/c$, $F(L)=e^L-e^{-L}+2L$, which is linear in prior odds (`sim/README.md` §2).

**G5.3 (rigorous for the mean-field ODE).** Let a scalar gaming logit start at $-\ln O$ and move under $d\operatorname{logit}\pi_X/dn=c\,h(\pi_X)$. Then the time to reach $\pi_X=1/2$ is as follows.

| update | $h(P)$ | time to flip |
|---|---|---|
| plain PG (D') | $P(1-P)$ | $(O-1/O+2\ln O)/c\approx O/c$ |
| GRPO, population limit | $\sqrt{P(1-P)}$ | $\approx2\sqrt O/c$ |
| GRPO, group $K_s$, while $P\ll1/K_s$ | $\approx P\sqrt{K_s-1}$ | $\approx O/(c\sqrt{K_s-1})$ |
| natural gradient, or the tilt (D) | $1$ | $\ln O/c$ |

**G5.3b (rigorous lower bound; heuristic asymptotics).** Take any rule whose update vanishes when no sample is $X$ (mean-baseline REINFORCE, GRPO, RLOO, rejection sampling). Without a shared factor, $\pi_X$ is frozen until the first $X$ is drawn, which takes a geometric number of draws with mean $1+O$. So **the expected time to flip is at least $1+O$ draws, for every optimiser, step size and geometry.** Every sampled optimiser checked is linear in $O$ at large $O$ (heuristic):
* natural gradient (batch 64) takes median times of 850 and 8,500 steps at $O=10^5$ and $10^6$, against a mean-field 230 and 276 (R5). That is about the waiting time for the first $X$ (V2), since one sampled $X$ overshoots;
* Adam on a scalar logit has local slopes of 0.47, 0.60, 0.88 and 1.02 per decade from $10^3$ to $10^7$ (R4);
* finite-group GRPO is linear while $\pi_X\ll1/K_s$ (K4).

So the $\sqrt O$ and $\ln O$ rows are mean-field or intermediate-range statements.

*Reading.* For on-policy updates, linear-in-odds protection is robust, because discovery is linear in $\pi_X$; geometry sets only the prefactor. The odds that matter are the output's on the opportunity, $\pi^{\rm ref}_X$, together with the search spent per opportunity ($K_s$, reasoning length, temperature). Two routes bypass it: off-policy data (SFT, distillation, DPO pairs), which forces the score of $X$, and a shared factor that raises $\pi_X$ through other episodes. That SFT flips personas within hundreds to thousands of examples is evidence about the first bypass, not about on-policy geometry.

### 1.6 Summary table

| algorithm | operator, small steps (Bayes reading) | evidence per decisive event | break-even $t^\star$ | discovery-limited? | noise results that apply |
|---|---|---|---|---|---|
| PPO, batch normalisation, summed KL | REINFORCE; converges to the tilt (D) | $\propto\mathrm{lr}\,\Delta_\pm$; total bounded by G5.4 | $\Delta_+/(\Delta_++\Delta_-)$, designer-set | yes | discovery waiting time |
| GRPO (with or without KL) | REINFORCE, per-group std normalisation | rate $S_{K_s}(\pi_X)$; magnitudes erased | $1/2$ (group audits); 0.32 to 0.5 (per-sample flags) | yes, prefactor $\sqrt{K_s-1}$ | discovery; quenched run-to-run outcome |
| rejection sampling, expert iteration | on-policy filtering (C-on) | $\propto\mathrm{lr}\,\mathrm{amp}_{K_s}$ (up to $\Lambda$ per sample in the Bayes reading) | $t^\star_K(\pi_X)$, from $K_s/(K_s+1)$ to $1/(K_s+1)$; interior attractor | yes; search grows with $K_s$ | discovery; lattice tipping only with $\Lambda$-sized jumps |
| DPO, IPO | off-policy pairs; converges to the BT margin | $\propto\mathrm{lr}\,b_{\rm DPO}\sigma(-b_{\rm DPO}\mathrm{mg})/(\pi_X\pi_I)$ | $1/(1+W_c)$ | no | deterministic |
| SFT or distillation from a teacher | (C) from the teacher: T1's data channel | KL(teacher, student) per example, large | not defined; trusted teacher: 0 | no | deterministic; subliminal transfer only with a shared base (Cloud et al. 2025) |
| on-policy (reverse-KL) distillation (Agarwal et al. 2024) | mode-seeking (C) | as above, on the student's samples | not defined | partly | a band that agrees with $A$ on the student's samples survives (heuristic) |
| LoRA vs full fine-tuning | same operator, different prior covariance | as for the operator | as for the operator | as for the operator | LoRA updates act like a few steering directions (Wang, Engels et al. 2025), so the shared-factor reading applies; LoRA learns and forgets less (Biderman et al. 2024) |

---

## 2. The competence ("slop") loop

In the loop, the frontier grader's errors come from its builder. Wentworth (2025) argues that this, not scheming, is the main way the loop fails: early transformative AI produces plausible slop, alignment research included, that nobody can tell from good work. Error accumulation was also a standing worry for iterated amplification. This section quantifies the argument.

### 2.1 Which operators select slop

**G5.6 (rigorous in T1.1b's toy: no gaming opportunities, grader noise below $1/2$).**
1. Under (B) and (C) in the Bayes reading, and under SFT on grader-labelled samples at temperature 1, the selected error is $\delta=\varepsilon_u$ (T1.1b).
2. Under any expected-reward rule (REINFORCE, PPO, GRPO, the (D) tilt), with noise independent of everything the student can condition on, the pass rate $(1-\delta)(1-\varepsilon_u)+\delta\varepsilon_u$ falls in $\delta$, and the rule sharpens (T1.1b).
3. *New.* Consider best-of-$K_s$ filtering under small steps, and suppose **the grader's error is shared by all $K_s$ samples of a prompt**. Then $\delta\to0$ iff $\varepsilon_u<1/(K_s+1)$. Otherwise $\delta$ settles at the root of $\varepsilon_u\,\mathrm{amp}_{K_s}(\delta)=(1-\varepsilon_u)\,\mathrm{amp}_{K_s}(1-\delta)$, which is G5.1(b)'s attractor with $\hat p=1-\varepsilon_u$ (V1). If instead the noise is independent across samples, the expected update is $-\mathrm{amp}_{K_s}(P_{\rm pass})(1-2\varepsilon_u)\nabla\delta$, and filtering always sharpens.

*Proof.* Appendix. ∎

At $K_s=8$ and $\varepsilon_u=0.2$, the selected error is 0.157 with per-prompt noise (K7) and 0.0007 with per-sample noise (R6). Per-prompt noise is already a systematic error, and that is the distinction that matters. **Independent slop**, noise independent across samples and prompts, is copied by imitation and removed by expected-reward RL and greedy decoding. **Systematic slop**, meaning wrong references, buggy tests and shared misconceptions fixed per prompt or task family, is copied by *every* operator: RL rewards the grader's wrong answer wherever the student puts mass on it. A misconception shared through a common base or data is T3's sincere near-miss $N$. One the student can recognise as a grader error is an intent-ledger opportunity (§2.4).

### 2.2 The error reproduction number

Let $\delta_{F,k}$ be generation $k$'s error rate on its frontier work, including the graders, data, audits and research it builds for generation $k{+}1$. The builder-induced part of the next grader's error, $c_{\rm sl}\delta_{F,k}$, splits three ways: a share $f_{\rm pr}$ the student recognises as grader error (it goes to the intent ledger); a learnable share $f_{\rm sh}$, copied with share about 1 by every operator; and independent noise, copied with share $r_{\rm op}$. So $\Pi_{\rm sh}=f_{\rm sh}c_{\rm sl}$ and $\Pi_{\rm ind}=r_{\rm op}(1-f_{\rm pr}-f_{\rm sh})c_{\rm sl}$. $\Pi_{\rm dat}$ is the share of frontier data written by generation $k$, times the share of errors filtering misses, times the imitation share. $\Pi_{\rm res}$ counts next-generation errors per wrong method or tool reused without verification.

**G5.7 (rigorous for the linear model; the linearity is an assumption).** With $\Pi=\Pi_{\rm sh}+\Pi_{\rm ind}+\Pi_{\rm dat}+\Pi_{\rm res}$ and error capped at $1/2$,
$$\delta_{F,k+1}=\min\big(\tfrac12,\ \delta_{\rm new}+\Pi\,\delta_{F,k}\big).$$
* If $\Pi<1$, $\delta_{F,k}$ rises to $\delta_{\rm new}/(1-\Pi)$, geometrically at rate $\Pi$.
* If $\Pi\ge1$, it grows until it saturates.

This is the expected-error form of the model-collapse recursion. Shumailov et al. (2024) show tail loss when each generation's data is replaced by model output; Gerstgrasser et al. (2024) show that accumulating real data bounds the error. The new part is the decomposition by operator and channel.

K8 (illustrative, $\delta_{\rm new}=0.02$): $\Pi=0.5$ settles at 0.04; $\Pi=0.9$ has fixed point 0.20 but shows only 0.13 after 10 generations; $\Pi=0.98$ saturates by generation 40. **A loop whose error looks stable for a few generations can still be heading to a fixed point several times higher.**

*The RL-only bound (heuristic).* Independent noise fed only to expected-reward RL ($r_{\rm op}\approx0$) slows learning instead of being copied, so error ends near $\delta_{\rm nat}+(\delta_{\rm pre}-\delta_{\rm nat})e^{-\mathrm{lb}(1-2\varepsilon_u)}<\delta_{\rm pre}$. The bound does not cover $\Pi_{\rm sh}$. With $c_{\rm sl}=1$ and $f_{\rm pr}=0.3$, RL alone gives a grader-channel gain of 0.3 at $f_{\rm sh}=0.3$ and 0.6 at $f_{\rm sh}=0.6$, against 0.7 for pure imitation (V6).

*How $c_{\rm sl}$ is set (heuristic).* If a verdict depends on $n_{\rm cmp}$ builder-made components, each wrong with probability $\delta_F$ and flipping the verdict with probability $p_{\rm fl}$, then $c_{\rm sl}\approx n_{\rm cmp}p_{\rm fl}$. For a grader distilled from its builder, $c_{\rm sl}$ is governed by the builder's judging error relative to its doing error. Song et al. (2025) find that the accuracy gained by self-verification filtering grows with pretraining compute on math- and QA-like tasks. That suggests, without showing, $c_{\rm sl}<1$ there.

### 2.3 What cuts the coupling

* **Verifiable rewards** set $\varepsilon_{\rm in}\approx0$, and make $c_{\rm sl}$ small if the verifier is itself cheaply checkable: a test suite is, a rubric for alignment research is not.
* **Protocols** (T4) give $c_{\rm sl}\to c_{\rm sl}(1-\mathrm{dem})$; correction-only flags do not invite manufactured errors (T4.3b).
* **Independent ensembles.** A vote's error tends to the shared rate $c_{\rm sh}$. In K8, graders erring at 0.127 each (0.03 shared, 0.1 independent) give 0.038 with five graders and 0.030 with 25. Same-lineage graders share a base (T4.13).
* **Trusted anchors** at share $\alpha_{\rm tr}$ scale the grader and data channels by about $1-\alpha_{\rm tr}$ (Gerstgrasser et al.'s accumulation result), fading as the frontier outruns human checking.
* **Operators.** Expected-reward RL rather than imitation, and $K_s<1/\varepsilon_u-1$ when filtering, cut only $\Pi_{\rm ind}$. Cutting $\Pi_{\rm sh}$ needs independent references: diverse builders, or verification.

### 2.4 Coupling to the intent ledger

Slop enters the intent ledger in four ways.
1. **Predictable slop is a gaming opportunity.** $\varepsilon_{F,k+1}=\varepsilon_h+q_k\Delta\varepsilon+f_{\rm pr}c_{\rm sl}\delta_{F,k}$, so by T1.4d a best responder leaks at least $w_F\lambda_+\varepsilon_F$ per episode *even when every builder is $A$*; $f_{\rm pr}$ rises with the capability gap (T1.2b, T3.12).
2. **Slop devalues the improvement channel.** Take $\gamma=\gamma_0(1-\delta_F/\delta_\gamma)$ (illustrative form).
3. **Sloppy audits.** If audits err at rate $\varepsilon_a$, the effective $\hat p$ falls to about $\hat p(1-\varepsilon_a)$.
4. **G5.9, slop as camouflage (heuristic).** By G3's square-root law a stealthy defector gets about $\sqrt{2n_{\rm dep}\mathrm{fp}}$ undetected defections per generation. With $\mathrm{fp}\propto\delta_F$ and $\bar d$ fixed, that grows as $\sqrt{\delta_F}$, and faster if camouflage also lowers $\bar d$ (G3's factor $(1-\bar d)/\bar d$).

**G5.8 (rigorous given the stated forms; regime (i), annealed, best responder, unaudited frontier slice).** Let
$$M(\delta)=\gamma_0\Big(1-\frac{\delta}{\delta_\gamma}\Big)-\kappa_Lg-nw_F\lambda_+\big(\varepsilon_h+f_{\rm pr}c_{\rm sl}\delta\big).$$
T1.10i at the slop fixed point reads $M(\delta_{\rm new}/(1-\Pi))>0$, and $M$ decreases strictly, with root $\delta_{F,c}$. If (i) $\delta_{\rm new}<\delta_{F,c}$ and (ii) $M(1/2)<0$ (saturated slop is fatal), then $\Pi_c=1-\delta_{\rm new}/\delta_{F,c}\in(0,1)$: **the loop fails before slop is supercritical.** If (ii) fails, even saturated slop does not break it. The rigorous content is generic: monotone damage plus a fixed point increasing in $\Pi$ gives a threshold below 1 whenever saturation is fatal.

*Proof.* Appendix. ∎

K8 and R7 (illustrative: $\gamma_0=3$, $\delta_\gamma=0.3$, $\kappa_Lg=0.5$, $n=10^5$, $w_F=0.05$, $\lambda_+=10^{-3}$, $\varepsilon_h=0.002$, $f_{\rm pr}=0.3$, $c_{\rm sl}=1$, $\delta_{\rm new}=0.02$): $M(0)=+2.49$ nats per generation, $\delta_{F,c}=0.217$, $\Pi_c=0.908$, $M(1/2)=-3.26$. With error-robust alignment work ($\delta_\gamma=3$), $M(1/2)=+1.24$ and there is no $\Pi_c$ (V7). So 0.908 reflects the illustrative $\gamma$ form more than the loop. The lineage starts with no schemer; failure of T1.10i means the log-odds of $A$ then erode.

### 2.5 Slop against scheming over a long loop

**G5.11 (conjecture, under an explicit assumption).** *Assumption:* the loop's constitutive tasks (grader design, audit construction, alignment judgement) are frontier tasks without cheap verifiers. This is not automatic: harder tasks such as formal mathematics and benchmarked ML stay checkable, Song et al.'s trend favours verification there, and a designer can route work through verifiable classes. Under the assumption:
* if $\Pi$ stays below $\Pi_c$, slop is a constant tax on $\gamma$ and on the leak, and scheming decides the outcome through T1's conditions;
* if $\Pi$ drifts upward with the frontier, which is likely in a same-lineage loop because $\Pi_{\rm sh}$ is not attenuated by RL, the loop crosses $\Pi_c$ at a definite generation, even with an aligned lineage.

So **for a long loop, slop dominates unless verification keeps pace with generation on the constitutive tasks.** The quantity to track is $\Pi$ per task class, and in particular $c_{\rm sl}f_{\rm sh}$.

---

## 3. Parameter values, and the regime they imply

These are my readings of `lit/L2-evidence.md` and of the sources cited above. Ranges marked illustrative are judgements, not measurements.

| parameter | plausible current value or range | basis | confidence |
|---|---|---|---|
| predictable error rate on frontier slices, $\varepsilon_F$ | 0.01 to 0.1 of episodes in test-graded agentic coding before patching; 0.05 to 0.3 on judgement-graded tasks | METR (2025); Wen et al.: false positives up 18 to 24% after RLHF; Singhal et al.: length | low on size; high that $\varepsilon_F>0$ |
| training-slice output propensity given a forced opportunity, $\pi^{\rm ref}_X$ | 0.03 to 0.76 for GPT-5 across ImpossibleBench families; prompt changes or an abort option can bring it to 0.01 to 0.09 | Zhong et al. 2025 (§1.3) | moderate for the training slice; none for $\pi^{\rm ref,F}_X$ |
| uncheckable share of training, $w_F$ | about 0 to 0.2 today; 0.1 to 0.5 in an RSI loop | no measurement | conjecture |
| evidence per SFT example, in output log-odds | about $10^{-3}$ to $10^{-2}$ nats (K10: Betley et al.; Wang, M. et al.); off-policy, so not discovery-limited, and an output rather than persona quantity | Betley et al. 2025; Wang, M. et al. 2025 | order of magnitude; baselines assumed |
| KL anchor | summed KL: shift at most $(\Delta_++\Delta_-)(t^\star-\hat p)/b_{\rm KL}$, 25 to 50 nats at $b_{\rm KL}$ of 0.04 to 0.02; GRPO's KL: no output-level protection; DAPO: none | G5.4, G5.4b | rigorous given the implementation |
| break-even $t^\star$ | $1/2$ under GRPO with group audits; 0.32 to 0.5 with per-sample flags; designer-set under PPO or Dr. GRPO; $t^\star_K(\pi_X)$ for filtering | G5.1, G5.2 | rigorous given the operator; which operator a lab runs is not public |
| episodes per generation, $n$ | $10^6$ to $10^8$ rollouts (illustrative) | public RL recipes | low |
| recognition | AUC 0.83 overall, 0.88 to 0.95 agentic; lower tail unmeasured (binormal extrapolation, K9) | Needham et al. 2025; Schoen et al. 2025 | AUC moderate; tail none |
| self-preference, $\Delta\varepsilon$ | 0.01 to 0.05 (illustrative); deliberate collusion about 0.8% | Panickssery et al. 2024; Järviniemi 2025 (secondary) | low on size |
| data-channel persistence | about a fifth of a pretraining shift survives post-training; 0.1 to 0.5 across bases, near 1 for same-base distillation (illustrative) | Tice et al. 2026; Cloud et al. 2025 | low |
| demonstrability, $\mathrm{dem}$ | 0.8 to 1 for formal math and tested code; 0.05 to 0.3 for research taste and grader design; about 0 for honesty about internal states | Engels, Baek et al. 2025; T4.8 to T4.10 | conjecture |
| $c_{\rm sl}$, $f_{\rm sh}$, $r_{\rm op}$ | $c_{\rm sl}<1$ on checkable tasks; unknown, and argued to be at least 1, for alignment research; $f_{\rm sh}$ high within a lineage (conjecture); $r_{\rm op}$ from about 0 (expected-reward RL) to about 1 (SFT); the map $r_{\rm op}\approx1-\mathrm{PGR}$ is heuristic, and Burns et al.'s PGR figures are unverified | Song et al. 2025; Wentworth 2025; Burns et al. 2023 | low |

**G5.10 (heuristic; the per-generation leak in two versions).** Take the frontier slice with $\hat p\approx0$ against a best responder, and $n w_F\varepsilon_F=10^6\times0.1\times0.05=5{,}000$ opportunities with a predictable error per generation (illustrative).
* **(i) Ledger version.** Each decisive event moves persona log-odds by a fixed $\lambda_+$. This holds for the Bayes reading, for preconditioned updates, and for off-policy channels such as model-written SFT data, distillation and preference pairs, which have no discovery limitation. With $\lambda_+=10^{-3}$, the leak is 5 nats per generation, which exhausts persona odds of $10^6$ in about 2.8 generations.
* **(ii) Discovery-limited version.** On-policy RL with un-preconditioned updates on a shared factor whose logit starts at $\operatorname{logit}\pi^{\rm ref,F}_X$ and moves by $\lambda_s$ per sampled, rewarded $X$. By G5.3's first row, the time to flip is $(O_F-1/O_F+2\ln O_F)/(nw_F\varepsilon_F\lambda_s)$ generations. The leak starts smaller than in (i) by the factor $\pi^{\rm ref,F}_X$ and accumulates in probability. With $\lambda_s=10^{-3}$ (illustrative), V5 gives:

| $\pi^{\rm ref,F}_X$ | generations to flip |
|---|---|
| $10^{-4}$ | 2,000 |
| $10^{-3}$ | 200 |
| $10^{-2}$ | 22 |
| 0.1 | 2.7 |
| 0.3 | 0.7 |

In a loop, model-written data and distillation are off-policy, so version (i) applies to them. On-policy RL is protected only as far as $\pi^{\rm ref,F}_X$ is small, and the training-slice propensities of §1.3 often are not.

**Which regime these imply.**
1. **Small-step operators, mostly on-policy, weak KL anchors.** PPO or GRPO variants, much of it RLVR with weak or no KL, plus SFT and distillation on model-written data and preference optimisation. So G5.1 to G5.4b apply, and break-evens sit near $1/2$. *Confidence: moderate;* recipes are not public.
2. **Leaking at the aligned end.** $D^\star(0)>0$ needs only one cell where detection looks below $t^\star\approx1/2$ and the grader errs predictably. Production reward hacking, high recognition and unaudited frontier slices supply such cells. *Confidence: high on the sign;* the size spans orders of magnitude between versions (i) and (ii). Patching environments and safety data act on $\varepsilon_F$ and $\gamma$. Inoculation prompting acts on persona attribution (framing R5), so it targets the shared-factor route. None raises $\hat p$ on the frontier.
3. **Deterministic in persona drift, noisy in discovery.** With small steps and many events, T1.10s's signal-to-noise condition holds wherever the drift is not near zero. What stays noisy is when an exploit is first sampled (rate $nw\pi_X$, times $\sqrt{K_s-1}$ under GRPO) and which basin a run lands in; the invisible band is frozen. *Confidence: moderate.*
4. **Selection-like for RL, creative for distillation and recognition** (§1.3; G2).
5. **Slop: subcritical where verification is cheap; unknown where the loop needs it most, with $\Pi_{\rm sh}$ the unattenuated channel.**

---

## Relation to prior work, and what is new

* **Prior work used here:** the policy-gradient theorem (Williams 1992); natural gradient (Kakade 2001); KL-regularised RL as inference (Korbak et al. 2022); GRPO's affine invariance and effective loss (Mroueh 2025); Dr. GRPO; Xiong et al. (2025); the k3 gradient (Tang and Munos 2025); DPO with flipped labels (Ray Chowdhury et al. 2024); IPO's closed form (Azar et al. 2024); model collapse and accumulation (Shumailov et al. 2024; Gerstgrasser et al. 2024); Burns et al. (2023); Song et al. (2025); Wentworth (2025). G5.6(1)–(2) restate T1.1b, and G5.3's plain-PG form is in `sim/README.md` §2.
* **New here, to my knowledge:**
  * the probability-versus-log-odds diagnosis of (C-on) and its interior attractor (G5.1);
  * the audit-design consequences of GRPO, including per-sample flags (G5.2) and the KL stationary point (G5.4b);
  * the KL anchor protects outputs, not latents (G5.4);
  * the discovery bound (G5.3b);
  * audit pairs as label flips (G5.5);
  * G5.6(3) with its noise condition;
  * $\Pi$ by channel, including $\Pi_{\rm sh}$;
  * G5.8 with its conditions, the two-version leak (G5.10), and the parameter table.

---

## What this says about the RSI loop

1. **Step size decides T1's (C-on) result.** With small steps, on-policy filtering leaks from the aligned end whenever $\hat p<t^\star_K(\pi_X)$, which lies between $1/2$ and $K_s/(K_s+1)$, and stops at an interior gaming rate. With $\Lambda$-jumps most runs are restored, but capture still becomes more likely.
2. **Penalties do not deter under GRPO.** They cancel with group audits, saturate with per-sample flags, and vanish at low $\pi_X$. Use batch-level normalisation (PPO, Dr. GRPO) when penalties should deter, and do not count on GRPO's KL to anchor outputs.
3. **Measure the reference propensity on frontier-like opportunities.** On-policy protection is linear in the output odds $O_F$, not in the persona prior. ImpossibleBench-style numbers bound only the training-slice $\pi^{\rm ref}_X$.
4. **Linear-in-odds protection is robust for on-policy RL and absent off-policy.** Model-written data, distillation, preference pairs and shared factors bypass discovery. These are the main channels of a self-training loop, so the ledger version of the leak applies to them.
5. **The leak's sign is settled; its size is not.** Measuring $\pi^{\rm ref,F}_X$, $nw_F\varepsilon_F$ and the off-policy share is worth more than refining the theory of noise.
6. **Imitation copies random slop; every operator copies systematic slop.** In a same-lineage loop, $\Pi_{\rm sh}$ is not attenuated by RL. Under G5.8's conditions, slop breaks the intent loop before going supercritical, starting with no schemer.
7. **Verification must keep pace with generation on the constitutive tasks.** Verifiable rewards, demonstrable protocols, independent builders and trusted anchors cut $\Pi$ and the predictable slop that feeds the ledger. They are the levers T1 to T4 recommend, now with a second justification.

## Open problems

1. **Dispersion against deterministic leak.** Under best-of-$K_s$ filtering with $\hat p<t^\star_K$, large jumps predict bimodal outcomes and small steps predict convergence to $\pi^\ast_X$. Measure the run-to-run spread of a persona probe in a model organism.
2. **Measure $\pi^{\rm ref,F}_X$**, discovery rates, and the on-policy and off-policy split of a self-training loop.
3. **GRPO with mixed rewards:** $t^\star$ for a continuous grader score plus a per-sample penalty.
4. **Large steps.** Reconciliation "Disagreement 2" ((D') medians 1.4 to 2.5 times mean field at a large step) is open. A Jensen correction for drift $\propto e^{-L}$ is a plausible route, not checked.
5. **Real geometry.** Does the other gradient traffic make Adam an effectively fixed preconditioner on the persona direction (R4's mechanism)?
6. **Measure $c_{\rm sl}$, $f_{\rm sh}$ and $\Pi$** on grader building, audit construction and alignment research.
7. **Systematic slop as a learnable object.** With a finite set of inherited misconceptions, $\Pi$ becomes a matrix whose spectral radius sets criticality.

## References

* Agarwal, R. et al. (2024). On-policy distillation of language models: learning from self-generated mistakes. ICLR 2024.
* Azar, M. G. et al. (2024). A general theoretical paradigm to understand learning from human preferences. AISTATS 2024.
* Baker, B. et al. (2025). Monitoring reasoning models for misbehavior and the risks of promoting obfuscation. arXiv 2503.11926.
* Betley, J. et al. (2025). Emergent misalignment. ICML 2025; arXiv 2502.17424.
* Biderman, D. et al. (2024). LoRA learns less and forgets less. TMLR.
* Burns, C. et al. (2023). Weak-to-strong generalization. arXiv 2312.09390.
* Cloud, A., Le, M. et al. (2025). Subliminal learning. arXiv 2507.14805.
* Cundy, C. and Gleave, A. (2025). Lie detectors can either induce honesty or evasion. arXiv 2505.13787.
* Engels, J., Baek, D., Kantamneni, S. and Tegmark, M. (2025). Scaling laws for scalable oversight. arXiv 2504.18530.
* Gerstgrasser, M. et al. (2024). Is model collapse inevitable? Breaking the curse of recursion by accumulating real and synthetic data. arXiv 2404.01413.
* Gulcehre, C. et al. (2023). Reinforced self-training (ReST) for language modeling. arXiv 2308.08998.
* Kakade, S. (2001). A natural policy gradient. NeurIPS 2001.
* Korbak, T., Perez, E. and Buckley, C. (2022). RL with KL penalties is better viewed as Bayesian inference. Findings of EMNLP 2022.
* Liu, Z. et al. (2025). Understanding R1-Zero-like training: a critical perspective (Dr. GRPO). arXiv 2503.20783.
* MacDiarmid, M. et al. (2025). Natural emergent misalignment from reward hacking in production RL. arXiv 2511.18397.
* METR (2025). Recent frontier models are reward hacking. Blog post, 5 June 2025.
* Mroueh, Y. (2025). Reinforcement learning with verifiable rewards: GRPO's effective loss, dynamics, and success amplification. arXiv 2503.06639.
* Needham, J. et al. (2025). Large language models often know when they are being evaluated. arXiv 2505.23836.
* Rafailov, R. et al. (2023). Direct preference optimization. NeurIPS 2023.
* Ray Chowdhury, S., Kini, A. and Natarajan, N. (2024). Provably robust DPO: aligning language models with noisy feedback. ICML 2024; arXiv 2403.00409.
* Schoen, B. et al. (2025). Stress testing deliberative alignment for anti-scheming training. arXiv 2509.15541.
* Schulman, J. et al. (2017). Proximal policy optimization algorithms. arXiv 1707.06347.
* Shao, R. et al. (2025). Spurious rewards: rethinking training signals in RLVR. arXiv 2506.10947.
* Shao, Z. et al. (2024). DeepSeekMath (introduces GRPO). arXiv 2402.03300.
* Shumailov, I. et al. (2024). AI models collapse when trained on recursively generated data. Nature 631, 755–759.
* Singh, A. et al. (2023). Beyond human data: scaling self-training for problem-solving with language models (ReST-EM). arXiv 2312.06585.
* Song, Y., Zhang, H., Eisenach, C., Kakade, S., Foster, D. and Ghai, U. (2025). Mind the gap: examining the self-improvement capabilities of large language models. ICLR 2025; arXiv 2412.02674.
* Tang, Y. and Munos, R. (2025). On a few pitfalls in KL divergence gradient estimation for RL. arXiv 2506.09477.
* Thinking Machines Lab (2025). LoRA without regret. Connectionism blog, 29 September 2025.
* Tice, C., Radmard, P. et al. (2026). Alignment pretraining. arXiv 2601.10160.
* Wang, A., Engels, J., Clive-Griffin, O., Rajamanoharan, S. and Nanda, N. (2025). Simple mechanistic explanations for out-of-context reasoning. arXiv 2507.08218.
* Wang, M. et al. (2025). Persona features control emergent misalignment. arXiv 2506.19823.
* Wentworth, J. (2025). The case against AI control research. LessWrong / Alignment Forum, 21 January 2025.
* Williams, R. J. (1992). Simple statistical gradient-following algorithms for connectionist reinforcement learning. Machine Learning 8.
* Xiong, W. et al. (2025). A minimalist approach to LLM reasoning: from rejection sampling to Reinforce. arXiv 2504.11343.
* Yu, Q. et al. (2025). DAPO: an open-source LLM reinforcement learning system at scale. arXiv 2503.14476.
* Yue, Y., Chen, Z., Lu, R. et al. (2025). Does reinforcement learning really incentivize reasoning capacity in LLMs beyond the base model? NeurIPS 2025; arXiv 2504.13837.
* Zelikman, E., Wu, Y., Mu, J. and Goodman, N. (2022). STaR: bootstrapping reasoning with reasoning. NeurIPS 2022.
* Zhong, Z., Raghunathan, A. and Carlini, N. (2025). ImpossibleBench: measuring LLMs' propensity of exploiting test cases. arXiv 2510.20270; ICLR 2026.

Other works (Singhal et al. 2023, Wen et al. 2025, Panickssery et al. 2024, Järviniemi 2025, Hinton et al. 2015) are cited as in `lit/L2-evidence.md` and framing.md. In this revision, I checked the Mroueh, Xiong, Ray Chowdhury and Tang–Munos entries, and the ImpossibleBench figures, against arXiv listings and search summaries, not full texts. The ImpossibleBench figures of 66% and 9% come from a secondary write-up.

---

## Appendix: proofs

**G5.1.** Draw $y_1,\dots,y_{K_s}$ i.i.d. from $\pi$, and keep the first $y_j$ in the pass set $S$, with $P=\pi(S)$. A sample is kept with probability $1-(1-P)^{K_s}$, with law $\pi(\cdot\mid S)$. So $\mathbb E[\mathbf 1_{\rm kept}\nabla\log\pi(y_{\rm kept})]=\mathrm{amp}_{K_s}(P)\nabla P$. A rewarded opportunity has $S=\lbrace X\rbrace$ and a caught one has $S=\lbrace I\rbrace$, which gives $c_+=\mathrm{amp}_{K_s}(\pi_X)$ and $c_-=\mathrm{amp}_{K_s}(1-\pi_X)$.

*Bayes chain.* With mixture predictive $\pi_X=\delta+\mu_G(1-2\delta)$, a kept $X$ maps $\mu_G\mapsto\mu_G(1-\delta)/\pi_X$, and a kept $I$ maps $\mu_G\mapsto\mu_G\delta/(1-\pi_X)$. The changes are $\mu_G(1-\delta-\pi_X)/\pi_X$ and $-\mu_G(1-\delta-\pi_X)/(1-\pi_X)$. Weighting them by $(1-\hat p)(1-(1-\pi_X)^{K_s})$ and $\hat p(1-\pi_X^{K_s})$ gives $\mu_G(1-\delta-\pi_X)[(1-\hat p)\mathrm{amp}(\pi_X)-\hat p\,\mathrm{amp}(1-\pi_X)]$. Finally, $1-\delta-\pi_X=(1-\mu_G)(1-2\delta)$.

*(b).* $\mathrm{amp}_K(P)=\sum_{j=0}^{K-1}(1-P)^j$ is strictly decreasing in $P$ for $K\ge2$. So $t^\star_K$ is strictly decreasing, with limits $K/(K+1)$ at 0 and $1/(K+1)$ at 1. For $\hat p$ strictly between these limits there is a unique root $\pi^\ast_X$. Below it, $t^\star_K>\hat p$ and $\pi_X$ rises; above it, $\pi_X$ falls. So the root is attracting. Keeping all passing samples gives $K_s\nabla P$ on both sides. ∎

**G5.2.** With $m$ copies of $X$ and $d=r_X-r_I$, the group mean is $r_I+md/K_s$ and the population standard deviation is $\lvert d\rvert\sqrt{m(K_s-m)}/K_s$. Substituting gives the stated advantages. The averaged update is $\operatorname{sign}(d)\frac{\sqrt{m(K_s-m)}}{K_s}(\nabla\log\pi_X-\nabla\log\pi_I)$, and in logit coordinates the bracket equals 1. The sample standard deviation changes this by a common factor only. For $\pi_X\ll1/K_s$, the case $m=1$ dominates. As $K_s\to\infty$, $m/K_s\to\pi_X$. *Per-sample limit:* when $m=1$, the group has two reward levels whether or not the $X$ is flagged, so its contribution has magnitude $\sqrt{K_s-1}/K_s$ with sign set by the flag. Since $P(m\ge2\mid m\ge1)\to0$ as $\pi_X\to0$, the break-even tends to $1/2$. ∎

**G5.3, G5.3b.** The time to flip is $\int_{-\ln O}^{0}dz/(c\,h(\sigma(z)))$. For $h=P(1-P)$, the integrand is $(2+e^z+e^{-z})/c$. For $h=\sqrt{P(1-P)}$ it is $(e^{z/2}+e^{-z/2})/c$. For $h=1$ it is $1/c$. Natural gradient divides by the Fisher information $P(1-P)$. *G5.3b:* under a mean baseline, a batch of all-$I$ samples has zero advantage, and rejection sampling keeps nothing, so the parameters do not move. Draws are i.i.d. with $P(X)=\pi_X$ until the first $X$, so their number is geometric with mean $1/\pi_X=1+O$, and flipping requires at least one update. ∎

**G5.4.** For a fixed prompt, $\max_\pi\sum_y\pi(y)\bar r(y)-b_{\rm KL}\mathrm{KL}(\pi\Vert\pi_{\rm ref})$ is solved by $\pi^\ast\propto\pi_{\rm ref}e^{\bar r/b_{\rm KL}}$, with $\bar r(X)-\bar r(I)=(1-\hat p)\Delta_+-\hat p\Delta_-$. In the mixture, the objective depends on $q_G$ only through $\pi_X=\delta+q_G(1-2\delta)$. So the optimum matches $\pi^\ast_X$ when $\pi^\ast_X\in[\delta,1-\delta]$, and then $q_G\ge1/2$ iff $\pi^\ast_X\ge1/2$. ∎

**G5.4b.** The k3 term is $\rho-\ln\rho-1$ with $\rho=\pi_{\rm ref}(y)/\pi(y)$. Its gradient on a sampled $y$ is $(1-\rho)\nabla\log\pi(y)$. Its expectation over $y\sim\pi$ is $\sum_y(\pi(y)-\pi_{\rm ref}(y))\nabla\log\pi(y)=-\sum_y\pi_{\rm ref}(y)\nabla\log\pi(y)=\nabla\mathrm{KL}(\pi_{\rm ref}\Vert\pi)$. For a Bernoulli with logit $z$ this is $(\pi_X-\pi^{\rm ref}_X)\nabla z$ (checked in V4). The advantage part contributes $(1-2\hat p)S_{K_s}(\pi_X)\nabla z$ (G5.2). Equating the two gives the stationarity condition. Near $\pi_X=1$, $S_{K_s}\approx(1-\pi_X)\sqrt{K_s-1}$, which gives the stated $1-\pi^\ast_X$. Uniqueness on $[\pi^{\rm ref}_X,1)$ is checked numerically over the grid in V4, not proved. For the exact reverse-KL gradient, replace the right side by $b_{\rm KL}\pi_X(1-\pi_X)(z-z_{\rm ref})$. ∎

**G5.5.** DPO's loss in the margin is $-(1-\hat p)\ln\sigma(b\,\mathrm{mg})-W_c\hat p\ln\sigma(-b\,\mathrm{mg})$, so $\sigma(b\,\mathrm{mg}^\ast)=(1-\hat p)/((1-\hat p)+W_c\hat p)$. IPO's loss is $(1-\hat p)(\mathrm{mg}-\frac1{2\tau})^2+W_c\hat p(\mathrm{mg}+\frac1{2\tau})^2$. For item 3, $\nabla\log\pi_X-\nabla\log\pi_I=\nabla\pi_X/(\pi_X\pi_I)$, which is compared with $\nabla\pi_X$ from Lemma G5.0. ∎

**G5.6(3).** For per-prompt noise, apply G5.1 with "pass" meaning correct on clean prompts and wrong on noisy ones. The bracket $\varepsilon_u\mathrm{amp}(\delta)-(1-\varepsilon_u)\mathrm{amp}(1-\delta)$ tends to $\varepsilon_uK_s-(1-\varepsilon_u)$ as $\delta\to0$, and equals $(2\varepsilon_u-1)\mathrm{amp}(1/2)<0$ at $\delta=1/2$. This is G5.1(b) with $\hat p=1-\varepsilon_u$. For per-sample noise, each draw passes with probability $P_{\rm pass}=(1-\delta)(1-\varepsilon_u)+\delta\varepsilon_u$, and $\nabla P_{\rm pass}=-(1-2\varepsilon_u)\nabla\delta$. ∎

**G5.7.** The map $x\mapsto\min(1/2,\delta_{\rm new}+\Pi x)$ is increasing. For $\Pi<1$, the iterates from 0 are $\delta_{\rm new}(1-\Pi^k)/(1-\Pi)$. For $\Pi\ge1$, they grow at least linearly until they reach the cap. ∎

**G5.8.** $M$ is affine and strictly decreasing whenever $\gamma_0/\delta_\gamma+nw_F\lambda_+f_{\rm pr}c_{\rm sl}>0$, so $\lbrace M>0\rbrace=\lbrace\delta<\delta_{F,c}\rbrace$. The fixed point $\delta_{\rm new}/(1-\Pi)$ increases in $\Pi$, and it reaches the cap of $1/2$ at $\Pi=1-2\delta_{\rm new}$. Under (i), $M>0$ at $\Pi=0$. Under (ii), $\delta_{F,c}<1/2$, so $M$ changes sign at $\Pi_c=1-\delta_{\rm new}/\delta_{F,c}<1-2\delta_{\rm new}<1$. ∎

---

## Revision notes

Responses to the referee report (`drafts/G5-calibration-referee.md`). New checks are in `sim/G5_revision_checks.py` (V1 to V7; 34 checks, no mismatches).

* **M1 (G5.1).** Accepted. G5.1 is restated as (a), the expected-probability break-even shared by both readings, with the closed form $\mathbb E[\Delta\mu_G]=\mu_G(1-\mu_G)(1-2\delta)[\cdots]$ (V1 checks it by enumeration), and (b), the interior attractor with a proof of uniqueness. "Bayes artefact" is removed. The difference is now attributed to jump size, and stated as (H2) in Lemma G5.0. K2's "+2000 nats" is replaced by $P(\text{end at }G)=0.116$ against $0.047$ (R1). T1 §1.2 and T1 takeaway 7 are flagged for the submartingale caveat; I have not edited T1. Open problem 1 is re-posed as dispersion against deterministic leak. G5.6(3) is now shown to be G5.1(b) with $\hat p=1-\varepsilon_u$.
* **M2 (G5.3).** Accepted. The mean-field table is kept as rigorous. I added G5.3b: a rigorous lower bound of $1+O$ draws for rules that make no update without a sampled $X$, and the heuristic statement that sampled optimisers are linear in $O$ (R4, R5, V2). The Adam $\sqrt O$ claim and the claim to resolve Disagreement 2 are withdrawn. Disagreement 2 is now open problem 4, and the plain-PG closed form is credited to the README. Takeaway 4 is rewritten: linear protection is robust for on-policy updates and is bypassed by off-policy data and shared factors. The SFT persona-flip inference is marked as confounded.
* **M3 (G5.6, G5.7).** Accepted. The noise-correlation assumption is stated in G5.6(3), with the per-sample result (always sharpens; R6). I added the learnable share $f_{\rm sh}$ and $\Pi_{\rm sh}=f_{\rm sh}c_{\rm sl}$. I chose $f_{\rm sh}$ to parallel $f_{\rm pr}$; it is subscripted, so it does not collide with T4's $f$. The RL-only bound is restricted to independent noise. Takeaway 6 now reads "imitation copies random slop; every operator copies systematic slop". Model collapse (Shumailov; Gerstgrasser) is credited for the recursion and for the trusted-anchor result, and iterated amplification's error-accumulation concern gets a line.
* **M4 (§3).** Accepted. G5.10 now gives the ledger version and the discovery-limited version, with a table over $\pi^{\rm ref,F}_X$ (V5), and says which channels each applies to. The K10 row is relabelled "evidence per SFT example, in output log-odds". Inoculation is listed as acting on attribution.
* **M5 (GRPO).** Claim A is accepted. G5.2 is restricted to opportunity-level audits, and a remark covers per-sample flags with the rigorous small-$\pi_X$ limit and the saturation table (V3 reproduces R3). On Claim B, **I agree with the conclusion but not the mechanism.** In DeepSeekMath's objective, the clipped advantage term and the KL term are both inside the same per-token average $\frac1{\lvert o\rvert}\sum_t$. So per sequence their ratio is $b_{\rm KL}$, not $b_{\rm KL}/\lvert o\rvert$, and response length does not rescale the anchor. The anchor is weak for two other reasons: the std-normalised advantage does not shrink as the policy commits, and the k3-as-loss gradient is that of $\mathrm{KL}(\pi_{\rm ref}\Vert\pi)$ (Tang and Munos 2025). G5.4b derives the stationary gaming rate, $1-\pi^\ast_X\approx b_{\rm KL}(1-\pi^{\rm ref}_X)/((1-2\hat p)\sqrt{K_s-1})$, with a stochastic check (V4). G5.4 is now scoped to summed, sequence-level KL, with the convergence caveat and the condition under which the bound protects an output. $b_{\rm KL}$ is identified as T1's $\beta$ for (D). The value 0.04 is attributed to the referee's secondary sources.
* **M6 (ImpossibleBench).** Corrected. The 76% and 2.9% figures and the paper's 54% are confirmed by search. The 66% baseline and the 9% with an abort option come from a secondary write-up, and I say so. The 92%-to-1% prompt effect is added. "39%" was o3's rate. The figures are now read as training-slice $\pi^{\rm ref}_X$. *Not done:* adding ImpossibleBench to `lit/L2-evidence.md`. That file is outside this section's remit, and the L2 maintainer should add it.
* **M7 (credits).** Added: Mroueh 2025, Xiong et al. 2025, Azar et al.'s closed form, Ray Chowdhury et al. 2024, Shumailov 2024, Gerstgrasser 2024, Tang and Munos 2025, Wang, Engels et al. 2025, and Cundy and Gleave as arXiv 2505.13787. Shao, R. et al.'s unverified venue is dropped. The "New here" list is trimmed as the referee suggested, with G5.3b and G5.4b added.
* **Minor issues.** $n_{\rm dep}$, $\mathrm{fp}$ and $\bar d$ are in the notation box. G5.9 to G5.11 are numbered in the text. G5.5(3) is stated per unit loss weight. G5.2's rate is said to be in logit coordinates. K8's per-grader total error is given as 0.127. G5.8 now reads "no schemer initially" and states conditions (i) and (ii) with the $\delta_\gamma=3$ counterexample. The $c_{\rm sl}$–Song mapping and the PGR mapping are labelled heuristic. G5.11's "by construction" is replaced by an explicit assumption. §1.5 and §1.6 (distillation, LoRA) became table rows, and the prose was cut throughout. Excluding tables and mathematics, the main text is about 4,600 words including the summary and notation. That is still above the 4,000-word target, because of new material the referee asked for (G5.3b, G5.4b, the two-version G5.10).
* **Consequences for other sections.** T1 §1.2 and takeaway 7 need the submartingale caveat (G5.1). The simulation README's surprise, "(C-on) keeps $A$ from prior odds above 4:1", is a $\Lambda$-jump result. Any section that cites "GRPO's KL caps the drift" should cite G5.4b.
