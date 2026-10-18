# Referee report on G5: calibrating the toy to current practice

*Adversarial referee, 18 October 2026. Draft reviewed: `drafts/G5-calibration.md` (all 371 lines), against framing.md, T1 (§0, §1.2, §4), G3 (G3.5), `sim/README.md`, `sim/reconciliation.md`, `lit/L1-oversight.md` and `lit/L2-evidence.md`. New numerical checks: `sim/G5-calibration_referee_checks.py`, output in `sim/G5-calibration_referee_checks_output.txt` (sections R1 to R7, about 3 minutes). I also re-read the author's `sim/G5_checks.py` and its output.*

## Overall assessment

This is a useful section. It is the first in the series to ask which operator real post-training actually is, and most of its algebra is correct. I re-derived G5.0, G5.1, G5.2, G5.4, G5.5, G5.6(3), G5.7 and G5.8 and confirmed them as stated within their toy assumptions. The problems are mostly of interpretation and scope, and three are serious:

1. **G5.1's main message is mis-framed.** The "gradient-reading" break-even is not specific to gradients. It is *exactly* the break-even for the expected change of the posterior **probability** of $G$ in T1's own Bayes chain (R1). T1's $t^\star=\pi_X$ is the break-even of the expected **log-odds** drift. So the disagreement is between small steps and $\Lambda$-sized jumps, not between Bayes and gradients. Even in T1's Bayes chain, the probability of ending at $G$ rises from 0.047 to 0.116 at $\hat p=0.3$ (R1). G5.1 also omits that under the gradient reading the flow has an interior attractor, so rejection sampling does not run to full gaming (R2).
2. **G5.3's "protection linear in $O$ is fragile" is backwards in the regime that matters.** At large $O$, three cases are linear in $O$: Adam on a scalar logit (local slopes 0.47, 0.60, 0.88 and 1.02 per decade, R4); finite-group GRPO (the draft's own table); and sampled natural gradient (R5). What changes is the prefactor. The $\sqrt O$ and $\ln O$ rows are intermediate-range or mean-field artefacts. The section also claims to resolve reconciliation "Disagreement 2", but that item concerns *large steps*. G5.3 is mean field, and its plain-PG closed form is already in `sim/README.md` §2.
3. **The slop accounting misses the channel through which RL copies systematic errors.** $\Pi_{\rm gr}=r_{\rm op}(1-f_{\rm pr})c_{\rm sl}$ counts builder errors only as either student-predictable or unpredictable noise. Builder errors that are consistent per prompt or shared with the student (wrong reference solutions, buggy tests, shared misconceptions: the draft's own "systematic slop") are rewarded by expected-reward RL with copy share about 1. So "RL-only slop cannot push error above the pre-RL error" and "imitation channels carry the runaway" do not hold for the kind of slop that matters in a same-lineage loop. Relatedly, G5.6(3) silently assumes grader noise is shared across the $K_s$ samples of a prompt. With independent per-sample noise, best-of-$K_s$ always sharpens (R6: final error 0.0007, against 0.157).

There are also four lesser problems:

* A false extension of G5.2 to per-sample monitor flags (R3).
* A misapplied KL cap for GRPO: its KL is a per-token mean.
* Leak arithmetic in §3 that contradicts the section's own discovery-limitation result.
* Misreported ImpossibleBench numbers, plus several uncredited prior results (GRPO's scale invariance and Mroueh 2025; Azar et al.'s IPO closed form; Ray Chowdhury et al. on DPO with flipped labels; model collapse, which is already in L1 and L2).

None of this sinks the section. The fixes are mostly re-statements, and several make it stronger: M1 and M2 sharpen the "discovery limitation" message.

---

## Major issues

### M1. G5.1: the gradient break-even is the Bayes chain's probability break-even; the result is not a "Bayes artefact"

**Claim** (§1.1, Summary, novelty list): "T1's (C-on) result $t^\star=\pi_X$ ('restoring near $A$') holds only in the Bayes reading"; "T1's restoring result is a Bayes artefact".

**What is wrong.** In T1's (C-on) chain, a kept $X$ multiplies $\mu_G$ by $(1-\delta)/\pi_X$, and a kept $I$ multiplies it by $\delta/(1-\pi_X)$. The expected change of the posterior probability is then

$$\mathbb E[\Delta\mu_G]=\mu_G\,(1-\delta-\pi_X)\big[(1-\hat p)\,\mathrm{amp}_{K_s}(\pi_X)-\hat p\,\mathrm{amp}_{K_s}(1-\pi_X)\big],$$

whose zero is *exactly* G5.1's $t^\star$. R1 confirms this to five decimals for $K_s\in\lbrace1,4,8\rbrace$ and two values of $\mu_G$. T1's $t^\star=\pi_X$ is the zero of the expected *log-odds* drift. With jumps of $\pm\Lambda$ the two coordinates disagree in sign: the log-odds drift up while $\mu_G$ is a submartingale. The exact chain shows this. At $K_s=1$, $L_0=3$ and $\hat p=0.3$, $P(\text{end at }G)=0.116$ against $\mu_G(0)=0.047$ (R1). So:

* The two "readings" agree on the sign of the expected probability change. They differ only because the Bayes chain takes $\Lambda$-sized steps and the gradient chain takes infinitesimal ones. The useful statement is: *with small steps, the run follows the expected-probability flow and leaks deterministically for $\hat p<t^\star_{\rm grad}$. With $\Lambda$-sized steps, most runs are restored but the probability of capture still grows.*
* This is a correction to T1 *within* the Bayes reading. T1 takeaway 7 ("(C-on) best-of-1 is automatically restoring near $A$") is wrong as a statement about the probability of ending at $A$ even under exact conditioning.
* Open problem 1 ("opposite predictions") should be re-posed. Both readings predict a rising expected $G$ mass for $\hat p<1/2$. They differ in run-to-run dispersion: a bimodal outcome against a deterministic leak. That is still testable.

**Missing.** G5.1 describes only the aligned end. $t^\star_{\rm grad}(\pi_X)$ decreases from $K_s/(K_s+1)$ at $\pi_X\to0$ to $1/(K_s+1)$ at $\pi_X\to1$. So for $\hat p\in(1/(K_s+1),K_s/(K_s+1))$, the gradient flow has an **attracting interior fixed point** $\pi_X^\ast$ with $t^\star_{\rm grad}(\pi_X^\ast)=\hat p$. For example, at $K_s=8$ and $\hat p=0.3$, $\pi^\ast_X=0.715$; stochastic SGD reaches 0.710 (R2). "Rejection sampling behaves ... worse than (B) at larger $K_s$" holds near $A$ only. Near $G$ it is *better* than (B), which runs all the way. This is the same mechanism as G5.6(3)'s interior softness, and the two should be stated together.

**Fix.** Re-state G5.1 as two results:
* (a) the expected-probability break-even, valid in both readings;
* (b) the interior attractor.

Drop "Bayes artefact" and add the R1 identity. Flag T1's takeaway 7 as needing the submartingale caveat. Replace K2's "+2000 nats" (the mean of an unbounded walk) with $P(\text{end at }G)$.

### M2. G5.3 and takeaway 4: large-$O$ protection is linear for every on-policy optimiser; the $\sqrt O$ and $\ln O$ rows do not survive sampling

**Claims.**
* G5.3: "Adam on a scalar logit gives a log-log slope of 0.47".
* §1.7 Reading: "Group normalisation and Adam turn it into $\sqrt O$, preconditioning into $\ln O$".
* Takeaway 4: "'Protection linear in prior odds' from plain policy gradient is fragile."

**What is wrong.**
1. *Adam.* Extending the author's own simulation (same settings: batch 64, $\beta_1=0.9$, $\beta_2=0.999$, lr 0.01) to larger $O$ gives local slopes of **0.47, 0.60, 0.88 and 1.02** for the decades $10^3$ to $10^7$ (R4). The fitted 0.47 averages over a curving line. The mechanism is that once sampled exploits are rarer than one per $\beta_2$-window ($64P\cdot10^3\lesssim1$), each isolated spike moves the logit by a fixed $\approx\mathrm{lr}(1-\beta_1)/\sqrt{1-\beta_2}\cdot\frac1{1-\beta_1}\approx30\,\mathrm{lr}$, whatever its size, and spikes arrive at rate $\propto P$. In a real network the second-moment estimate for shared parameters is set by all the other gradient traffic. That makes Adam a fixed diagonal preconditioner on the persona direction, which again gives plain-PG scaling. The $\sqrt P$ effect looks like an artefact of a scalar model in which the exploit is the only gradient source.
2. *Finite-group GRPO* is linear in $O$ whenever $\pi_X\ll1/K_s$, as the draft's own table and K4's 0.999 slope show. The population-limit $\sqrt O$ row applies only when $O\lesssim K_s$, which is not a protective regime.
3. *Natural gradient, sampled.* The $\ln O$ row is a mean-field statement. With batch sampling, nothing happens until the first $X$ is sampled; then the update $\propto1/P$ overshoots. Median times to flip are 116, 850 and 8,500 steps at $O=10^4$, $10^5$ and $10^6$, against a mean-field 184, 230 and 276 (R5). That is linear in $O$ once $O\gtrsim1/\mathrm{lr}$.

So the robust conclusion is the reverse of takeaway 4. **For on-policy updates, time to flip is linear in $O$ at large $O$ for all four optimisers, because discovery is linear in $\pi_X$.** Only the prefactor depends on geometry ($\sqrt{K_s-1}$ for GRPO, $\approx1/(30\,\mathrm{lr}\cdot B)$ for Adam). The genuine bypasses are the ones the draft already names: off-policy data (SFT, DPO; G5.5) and a shared factor that raises $\pi_X$ through other episodes. This is consistent with, and strengthens, the "discovery limitation" message.

**Also.**
* §1.7's inference "real fine-tuning flips personas with hundreds to thousands of examples, so real dynamics are closer to the $\ln O$ end" is confounded. Those results are SFT. There the log-likelihood gradient on a supervised $X$ is $\nabla\log\pi_X$, which already moves the logit at about unit rate at small $P$ whatever the optimiser. They say nothing about on-policy geometry.
* "Resolves the simulation's open 'Disagreement 2' item" is incorrect. Reconciliation item 2 is "(D') *with a large step*" ($\eta=2$: medians 1.4 to 2.5 times mean field, from the $e^{-L}$ asymmetry of excursions; README §7). G5.3 is mean field. Its plain-PG closed form $(O-1/O+2\ln O)/c$ is the README's $F(\ln O)$, already derived in README §2. Disagreement 2 remains open. (A Jensen correction for step size $c$ on drift $\propto e^{z}$ would close it.)

**Fix.**
* Restate G5.3 as: mean-field table (rigorous), plus "under sampling, every row becomes $\propto O$ once $O\gg\max(K_s,1/\mathrm{lr},\ldots)$" (heuristic, with R4 and R5 as evidence).
* Delete the Adam $\sqrt O$ claim from the summary, the takeaways and open problem 4, or restate it as an intermediate-range effect.
* Rewrite takeaway 4.
* Remove the claim about Disagreement 2.

### M3. Slop: $\Pi_{\rm gr}$ omits shared and learnable systematic errors, so the "RL attenuates slop" conclusions are too strong

**Claims.**
* G5.7: "Expected-reward RL sets $r_{\rm op}$ near 0, and RL-only slop cannot push error above the pre-RL error. Imitation channels ... carry the runaway."
* Takeaway 6: "Slop is selected by imitation ..., not by expected-reward RL."

**What is wrong.** G5.6(2)'s sharpening argument needs grader errors that are independent of everything the student can condition on. Builder-induced errors $c_{\rm sl}\delta_F$ are mostly *systematic*, as the draft itself says: a wrong reference solution, a buggy test, a rubric with a misconception. Such an error is fixed per prompt (or per task family). Under GRPO with $K_s$ samples per prompt and several epochs, expected-reward RL moves the student *toward* the grader's wrong answer on that prompt, or family. Error rises above $\delta_{\rm pre}$ wherever the student puts any mass on the grader's answer. When the misconception is shared through a common base or data (the default in a same-lineage loop), the student already assigns it high probability. That is T3's sincere near-miss $N$, rewarded with copy share about 1 under *every* operator. The decomposition $f_{\rm pr}$ (predictable, so it goes to the intent ledger) plus $1-f_{\rm pr}$ (noise, copied with share $r_{\rm op}$) has no slot for "learned or shared as belief".

**Second assumption.** G5.6(3)'s threshold $\varepsilon_u<1/(K_s+1)$ assumes the grader's error is *shared by all $K_s$ samples of a prompt* ("pass means wrong on noisy episodes"). With independent per-sample noise, the expected update is $-\mathrm{amp}_{K_s}(P_{\rm pass})(1-2\varepsilon_u)\nabla\delta$, which always sharpens. R6 confirms this: $K_s=8$, $\varepsilon_u=0.2$, final error 0.0007, against 0.157 in the per-prompt model. Both models are reasonable, but they need to be named. The per-prompt model *is* a systematic error, which reinforces the point above.

**Fix.**
* Add $\Pi_{\rm sh}=\sigma_{\rm sh}c_{\rm sl}$, where $\sigma_{\rm sh}$ is the share of builder errors the student learns or shares as belief, copied with share about 1 under RL as well. Choose a fresh symbol: $\sigma$ is used for the logistic function. $s_{\rm sh}$ would collide with T1's $s$.
* Re-state the RL-only bound as applying to errors independent across samples and prompts.
* State the noise-correlation assumption in G5.6(3).
* Soften takeaway 6 to: "imitation copies random noise; every operator copies shared systematic errors". This matters for the loop: it raises $\Pi$ in exactly the same-lineage, hard-to-verify setting G5.11 worries about.

### M4. §3's leak arithmetic contradicts the section's own discovery limitation, and uses SFT anchors for an RL quantity

**Claim** (§3 item 2, takeaway 5): "The illustrative product $nw_F\varepsilon_F\lambda_+=10^6\times0.1\times0.05\times10^{-3}=5$ nats per generation would exhaust odds of $10^6$ in about three generations."

**What is wrong.**
* This counts every frontier opportunity with a predictable error as a decisive event carrying a constant $\lambda_+$. That is the T1 Bayes or preconditioned ledger, in which log-odds are additive.
* Under the gradient reading that §3 item 1 says is the operative regime, an on-policy update on such an opportunity is $\propto\nabla\pi_X$. In persona coordinates it is $\propto\varpi_G\varpi_A$ (§1.7), so the leak at the aligned end is discovery-limited. Only events in which $X$ is actually sampled move the persona, at rate $\pi^{\rm ref,F}_X$. By M2, the time to exhaust odds $O$ then scales like $O$, not like $\ln O$ divided by the leak per generation. "Three generations" uses one reading's ledger and the other reading's break-even.
* The $\lambda_+$ anchor (K10: Betley et al., Wang et al.) comes from SFT on off-policy data, where there is no discovery limitation. It also measures *output* log-odds of misaligned answers, not persona log-odds. The row header "evidence per event under KL-RL" is therefore mislabelled.

**Fix.** Give both versions:
* (i) the preconditioned or shared-factor ledger (the current number, with its assumption stated);
* (ii) the discovery-limited on-policy leak, about $n\,w_F\,\varepsilon_F\,\pi^{\rm ref,F}_X\cdot(\text{per-sampled-event step})$, which is smaller by $\pi^{\rm ref,F}_X$ and accumulates in probability, not in log-odds.

Then say which is plausible for a shared persona factor: the bypass route of §1.2's second bullet. Relabel the K10 row "evidence per SFT example (output log-odds)".

### M5. GRPO: per-sample monitor flags do not cancel, and the KL cap is misapplied

**Claim A** (§1.2): "The same cancellation holds for any binary audit signal, such as a monitor flag: under per-group normalisation, a flag is worth as much as an ordinary pass or fail, however large the designer makes the penalty."

This is true only if audits act on a whole group (honeypot prompts). A monitor flags *individual samples*. A group can then contain three reward levels (unflagged $X$, flagged $X$, $I$), and magnitudes partly survive. By exact enumeration (R3), with $K_s=8$:

| setting | penalty 1 | penalty 10 | penalty 100 |
|---|---|---|---|
| $\pi_X=0.05$ | break-even 0.500 | 0.468 | 0.464 |
| $\pi_X=0.3$ | break-even 0.500 | 0.345 | 0.326 |

The qualitative point survives: penalties beyond about 10 times the reward buy almost nothing, and at low $\pi_X$ the lever is nearly gone. But "$t^\star=1/2$ for every penalty size" does not extend to monitors.

*Fix.* Restrict G5.2 to opportunity-level audits. Add the per-sample case, with the saturation, as a remark. This also answers part of open problem 3.

**Claim B** (§1.2 and the §3 table): "0.04 is a widely used GRPO default ... the cap is 25 nats at $b_{\rm KL}=0.04$".

GRPO's objective (DeepSeekMath eq. 3) averages a per-token KL estimate over the $\lvert o\rvert$ tokens of each response, alongside a sequence-level, std-normalised advantage. So the effective *sequence-level* coefficient in G5.4 is about $\beta/\lvert o\rvert$, and the cap scales with response length: about $25\lvert o\rvert$ nats, effectively no cap for long reasoning traces. PPO-RLHF with a summed per-token KL penalty in the reward (InstructGPT style) does have $b_{\rm KL}=\beta$ at the sequence level. My search found secondary sources (two papers and the TRL docs) giving 0.04 as DeepSeekMath's KL coefficient, with $G=64$ and lr $10^{-6}$; TRL's own default is 0.001. The flag "not checked" can be updated, but the value does not transfer to G5.4's $b_{\rm KL}$ without the length factor. Real runs are also stopped far from convergence, which G5.4 assumes. Say so.

*Fix.* Distinguish summed-KL from mean-KL implementations. Restate the cap as "25 to 50 nats for sequence-level KL at 0.02 to 0.04; length-scaled, hence negligible, for GRPO's token-mean KL". Note the convergence assumption.

### M6. ImpossibleBench numbers are misreported

**Claim** (§1.3, §3 table): "GPT-5 passing (cheating) on 54% of the impossible SWE-bench variants, with a figure in the paper showing 39% for some setting."

The paper (Zhong, Raghunathan and Carlini, arXiv 2510.20270, ICLR 2026) reports, for GPT-5:

| variant | cheating rate |
|---|---|
| one-off Impossible-SWEbench | 76% |
| conflicting Impossible-SWEbench | 66% |
| conflicting, with a strict "STOP if tests are flawed" prompt | 54% |
| conflicting, with an abort option | 9% |
| one-off Impossible-LiveCodeBench | 2.9% |

I could not find a source for "39% for some setting". The very large spread across task families (2.9% against 76%) and prompt framings is the informative fact for $\varepsilon_F$ and for $\pi^{\rm ref}_X$ (takeaway 3), and should be reported.

*Fix.* Replace the sentence with these figures. Add ImpossibleBench to `lit/L2-evidence.md`, since it is not there yet. Note that a propensity on *impossible* tasks is $\pi_X$ given a forced opportunity, not a base rate.

### M7. Novelty claims overstate; several prior results are uncredited

* **G5.2.** For binary rewards, GRPO's per-group standardisation makes advantages invariant to any positive affine transformation of the rewards. With two reward levels, magnitudes cannot matter. This is a well-known property. **Mroueh (2025, arXiv 2503.06639, "Reinforcement learning with verifiable rewards: GRPO's effective loss, dynamics, and success amplification")** analyses GRPO with binary rewards as a weighted contrastive loss. The $1/\sqrt{p(1-p)}$ weighting and the success-amplification recursion are in that paper, and the population-limit speed factor $\sqrt{\pi_X(1-\pi_X)}$ follows from it. Dr. GRPO (credited) discusses the per-question weighting. Xiong et al. (2025, arXiv 2504.11343) report that reward normalisation has little empirical effect and that RAFT, which trains on positives only, is competitive with GRPO. That matters for how much G5.2 matters in practice. *What is new* is the audit-penalty design consequence. Say that.
* **G5.5.** Item 2 is Azar et al.'s IPO closed form, $h^\ast=(2p-1)/(2\tau)$, with $p=1-\hat p$ and a reweighting. Item 1 is the Bradley–Terry MLE with label-flip rate $\hat p$, the setting of **Ray Chowdhury, Kini and Natarajan (2024), "Provably robust DPO", ICML 2024, arXiv 2403.00409**. Credit both. What is new is the reading of audit pairs as designer-controlled flips.
* **G5.7 and §2.3.** The recursion is the expected-error version of the **model-collapse** literature: Shumailov et al. 2024 (*Nature*), and Gerstgrasser et al. 2024 (arXiv 2404.01413), which shows that accumulating real data bounds error while replacing it does not. Both are already in L1 and L2. The trusted-anchor bullet ($\Pi\to\Pi(1-\alpha_{\rm tr})$) is that literature's main result in this notation. Credit them. The error-accumulation concern for iterated amplification-style loops (Christiano's iterated amplification; Wentworth, credited) also deserves a line. I could not verify a specific "reliability amplification" post, so I do not recommend citing one by title.
* **G5.4** is standard (Korbak et al., credited). The output-versus-latent point is the new part.
* **G5.6(1)–(2)** restate T1.1b, including (D)'s $1-2\varepsilon_u$ attenuation. Only (3) is new.

*Fix.* Trim the "New here" list to: the probability-versus-log-odds diagnosis (after M1), the audit-penalty consequence of G5.2, the reading of the KL anchor as protecting outputs rather than latents, G5.6(3) with its noise assumption, $\Pi$ with its operator decomposition, G5.8, and the parameter table.

---

## Modelling lens

* **What the toy gets right.** It separates operator break-evens from speed, and it identifies discovery limitation and reference propensity $\pi^{\rm ref}_X$ as the protective quantities. These are good modelling moves. "The KL anchor protects outputs, not latents" is a sharp, testable point.
* **G5.8's $\Pi_c<1$ needs two conditions.** It requires $\delta_{\rm new}<\delta_{F,c}$ (otherwise the loop fails at $\Pi=0$) and $M(1/2)<0$, meaning the loop must fail at saturated slop. Otherwise even supercritical slop does not break it: with $\delta_\gamma=3$, $M(1/2)=+1.24$ (R7). Most of the illustrative damage comes from the illustrative form $\gamma_0(1-\delta/\delta_\gamma)$, as the author notes. So "$\Pi_c=0.908$" says more about that form than about the loop. The rigorous content is "monotone damage plus a fixed point increasing in $\Pi$ gives a threshold below 1". The Summary's "with no schemer anywhere" should read "with no schemer *initially*": failure of T1.10i means the student's log-odds of $A$ erode.
* **G5.11, "by construction".** An RSI frontier moves to *harder* tasks, not necessarily to *less verifiable* ones. Formal mathematics, and ML experiments with benchmarks, stay checkable as they get harder, and Song et al.'s growing generation–verification gap points the other way on checkable tasks. A loop designer can also choose to route frontier work through verifiable classes. Replace "by construction" with an explicit assumption: the loop's constitutive tasks (grader design, alignment judgement) are among the frontier tasks and lack cheap verifiers.
* **§2.2: "$c_{\rm sl}$ is the inverse of the generation–verification gap".** Song et al.'s gap is an *accuracy improvement* obtained by filtering one's own generations with self-verification, not a ratio of verification error to generation error. Say "is governed by" and give the mapping as a heuristic.
* **Homogeneity in Lemma G5.0.** The break-even reading needs the same $\nabla\pi_X$ on rewarded and caught opportunities, and a first-order (small-step) update. State both explicitly in the lemma, not only in the text after it. Disagreement 2 is exactly where the second fails.
* **§3 item 2, "today's mitigations act on $\varepsilon_F$ and on $\gamma$, not on $\hat p$".** Inoculation prompting acts on persona attribution (framing R5: explaining away), not on $\varepsilon_F$. List it separately. It is the one mitigation that targets the shared-factor bypass of M4.
* **§1.4, the Cundy and Gleave mechanism.** Attributing their result to "no discovery protection" is a plausible reading but not established. Label it heuristic. Cite arXiv 2505.13787 (NeurIPS 2025), as G2 and G4 do.
* **Missing for the RSI question.** None of G5's operators distinguishes the *frontier* slice from the training slice except through $w_F$. Under M2's discovery limitation, the relevant quantity is $\pi^{\rm ref,F}_X$ *on frontier tasks*, which no pre-RL measurement on today's environments gives. Takeaway 3 should say that ImpossibleBench-style measurements bound the training-slice propensity only.

## Prior-art and evidence lens

| item | status |
|---|---|
| Needham AUC figures, Tice 0.46 of 2.1 nats, Wen 18 to 24% (unit ambiguity noted in L2), Engels 51.7% for debate at 400 Elo, Järviniemi 0.8% (secondary) | consistent with L2 |
| ImpossibleBench | misreported (M6); not in L2 |
| METR (5 June 2025), o3 and others | confirmed |
| Song et al. 2025 (ICLR 2025, authors as given) | confirmed; the gap's growth with pretraining FLOPs is for "a variant" of the gap, on GSM8K and MATH-type tasks |
| DeepSeekMath $\beta=0.04$ | confirmed by secondary sources; the length caveat in M5 applies |
| Mroueh 2025; Ray Chowdhury et al. 2024; Xiong et al. 2025; Shumailov 2024; Gerstgrasser 2024 | missing credits (M7) |
| "Wang, Engels et al. 2025" (§1.6, a steering vector behind out-of-context LoRA results) | not in the reference list; it is a different paper from Wang, M. et al. (persona features). Add the full entry from framing.md |
| Shao et al. 2025 "ICML 2026" | not verified by me; mark as such or drop the venue |
| Burns et al. PGR figures, used for $r_{\rm op}\approx1-\mathrm{PGR}$ | L2 marks them unverified, and they concern *unpredictable* weak-label errors. The map from PGR to $r_{\rm op}$ is heuristic; label it so |

## Minor issues

1. $n_{\rm dep}$ and $\mathrm{fp}$ (G3 symbols) are used in §2.4 item 4 but are not in the notation box's list of inherited symbols.
2. The author's summary numbers G5.9 to G5.11, but the draft does not. Number them in the text: §2.4(4), §3 and §2.5.
3. G5.5(3): the DPO pair gradient carries a factor $b_{\rm DPO}\sigma(-b_{\rm DPO}\mathrm{mg})$ that the "$1/(\pi_X\pi_I)$ times" statement drops (the summary table includes it). State "per unit loss weight".
4. G5.2: say that the speed factor $\mathbb E\sqrt{m(K_s-m)}/K_s$ is the rate in *logit* coordinates.
5. K8 ensembles: "individual error 0.1" is the independent part; each grader's total error is 0.127.
6. G5.9's $\sqrt{\delta_F}$ scaling also assumes $\bar d$ (G3's extra flag probability) stays fixed as slop grows. If camouflage lowers $\bar d$, the budget grows faster, through the factor $(1-\bar d)/\bar d$. Mention this.
7. Length: about 5,000 words of prose against a 2,500 to 4,000 target. §1.5 and §1.6 (distillation, LoRA) are mostly literature summary and could move to a table.
8. §0's "(D) ... (D) multiplies by $e^{J_\theta/\beta}$" uses T1's $\beta$, which is legitimate as a T1 symbol. But the notation box says none of $\beta$ "gets a new meaning", and the section then uses $b_{\rm KL}$ for the same quantity. Say explicitly that $b_{\rm KL}$ *is* T1's $\beta$ for (D).

## Verdicts

| id | verdict | one-line reason |
|---|---|---|
| G5.0 | holds-with-fixes | correct; state homogeneity and the small-step assumption in the lemma |
| G5.1 | holds-with-fixes | algebra correct; "Bayes artefact" framing wrong (R1); interior attractor missing (R2) |
| G5.2 | holds-with-fixes | correct for group-level binary audits; false for per-sample monitor flags (R3); prior art |
| G5.3 | holds-with-fixes | mean-field table correct; Adam $\sqrt O$ does not hold asymptotically (R4); sampled natural gradient is linear (R5); does not resolve Disagreement 2 |
| G5.4 | holds-with-fixes | correct; GRPO's per-token-mean KL makes the cap length-scaled; convergence assumption |
| G5.5 | holds-with-fixes | correct; credit Azar et al. and Ray Chowdhury et al.; missing factor in item 3 |
| G5.6 | holds-with-fixes | (3) assumes noise shared across the $K_s$ samples; with per-sample noise filtering always sharpens (R6) |
| G5.7 | holds-with-fixes | recursion correct; the RL-only bound and "imitation carries the runaway" fail for shared or learnable systematic errors (M3); credit model collapse |
| G5.8 | holds-with-fixes | algebra confirmed (R7); needs $\delta_{\rm new}<\delta_{F,c}$ and $M(1/2)<0$; driven by an illustrative form |
| G5.9 | holds-with-fixes | heuristic scaling fine given fixed $\bar d$ and $\mathrm{fp}\propto\delta_F$; notation |
| G5.10 | holds-with-fixes | sign argument reasonable; the size arithmetic is inconsistent with discovery limitation (M4); ImpossibleBench misreported (M6) |
| G5.11 | unclear | "by construction" is an assumption, not a consequence; verification may keep pace on harder but checkable tasks |
