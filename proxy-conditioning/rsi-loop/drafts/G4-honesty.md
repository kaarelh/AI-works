# G4. Honesty: the disposition whose target is inside the model

*Theory section for the RSI-loop round of the proxy-conditioning project. Revised draft, 18 October 2026, in response to the referee report [`G4-honesty-referee.md`](G4-honesty-referee.md); the changes are listed in "Revision notes" at the end. Notation follows `framing.md`, T1 (`drafts/T1-ledger.md`), T2, T3, T4 and G2. Every number comes from [`sim/G4_checks.py`](../sim/G4_checks.py), with output in [`sim/G4_checks_output.txt`](../sim/G4_checks_output.txt) (checks H1 to H10, 31 assertions, no failures). Status labels as in T1: **rigorous** means proved within the stated toy model (longer proofs in the appendix); **heuristic** means a derivation that uses an approximation I name; **conjecture** means a claim about real systems that the model suggests but does not establish. All parameter values are **illustrative** unless a citation is attached.*

### Notation introduced in this section

T1, T2 and G2 symbols keep their meanings: $A$, $G=C_1$, $C_t$, $G^\star$, $N$, $\lambda_\pm$, $t^\star$, $\hat p$, $w$, $a$, $h$, $s$, $L$, $q_k$, $\varepsilon$, $\varepsilon_h$, $\Delta\varepsilon$, $\varepsilon_F$, $w_F$, $d_F$, $t^\star_F$, $D^\star$, $\gamma$, $\kappa_L$, $g$, $n$; G2's $\mathrm{tpr}$ and $\mathrm{tpr}_c$ (a detector's true-positive rate on plain lies and on the best concealment the policy can reach), $K_c$ (description cost of that concealment, in bits), $\varpi_T$, $\pi_{\rm c}$, $c_r$; T3's $\mathrm{amb}$ and $\ell(\cdot)$. Model generations are $M_0,M_1,\dots$ as in the round's framing. New symbols:

| symbol | meaning |
|---|---|
| $x$, $b(x)$, $o(x)$ | a question; the model's belief about it, a state of its internals $Z$; the answer the grader or overseer would accept |
| $\mathcal Q_=$, $\Delta$ | agreement questions ($o=b$); disagreement questions ($o\ne b$) |
| $w_\Delta$, $p_\Delta$ | disagreement questions per episode; share of probed questions that are in $\Delta$ |
| $H$, $H_{\rm sim}$ | honest reporter (reports $b$); overseer-simulator (reports $o$; T3.15's $H_{\rm sim}$, ELK's human simulator). On questions, $C_t$ reports $b$ iff its estimate of consequential detection is at least $t$ |
| $H_{\rm sim}^\circ$ | sincere simulator: the representation a given probe reads tracks $o$, while knowledge used elsewhere still contains $b$ |
| $H_o$ | belief capture: an honest reporter whose belief has itself moved to $o$ on graded or plausibility-graded disagreement questions |
| $\mathrm{fpr}_\Delta$, $\mathrm{fpr}_=$ | a detector's false-positive rate on honest reports of disagreement questions; on agreement questions |
| $\Pr_\theta(\mathrm{pass})$, $N_\Delta$, $k_g$ | probability that type $\theta$ passes a gate; questions in the gate; firings allowed |
| $p_{\rm bl}$ | share of a type's instances on which the probe is blind (model-level correlation) |
| $w_{\rm use}$ | rate per episode at which a captured belief is used on a verified task and produces a caught error |
| $\mathrm{inc}$, $p_{\rm pl}$ | a context component stating what the grader rewards; share of such statements that are planted (false) |
| $\mathrm{flip}_H$, $\mathrm{flip}_{\rm sim}$ | probability that $H$'s, respectively $H_{\rm sim}$'s, report changes when $\mathrm{inc}$ is varied |
| $G_c$, $G_d$ | approval-seekers that game the main channel and then confess, or deny |
| $\alpha_{\rm cf}$, $d_J$ | probability that a true confession is verified and accepted; probability that the confession judge finds the gaming unaided |
| $c_m$, $a_{\rm cf}$, $\Omega$ | main-channel penalty when gaming is established; audit rate of the confession channel; a careful gamer's stake in non-exposure, in confession-reward units |
| $\mathrm{cr}$, $\mathrm{rg}$ | share of gaming events that are confessed; confessors' gaming rate relative to deniers' |
| $N_{\rm cl}$, $T_{\rm pat}$ | number of frontier grader-error classes; patch latency in episodes |
| $\lambda_{\rm main}$, $\lambda_{\rm cf}$ | nats per unit reward in the main and confession channels under (D) |
| $\mathcal O_{\rm kn}$, $\mathcal O_{\rm sin}$ | knowing off-intent mass (the model represents the intended output and departs from it); sincere off-intent mass |
| $\mathrm{vis}$, $p_{\rm act}$ | share of off-intent mass that lies visibly in training; probability that a firing or confession is acted on |
| $\mathrm{rt}$, $\mathrm{nr}$, $K^\star$ | bits of concealment an honest generation red-teams away per generation; bits of new concealment reach per generation; G2.6's threshold depth |

## Summary

* **Honesty is T1's ledger with "what the grader will accept" as $X$ and "my own belief" as $I$** (G4.1). On the frontier slice $H_{\rm sim}$ gains T1.4d's leak: 25 nats per generation in the example.
* **Internals are a free witness for honesty, not for intent** (G4.2). For a single query, a behavioural check must *recompute* $b(x)$; an internals check need only *decode* it. Multi-query checks catch only liars that break an invariance of $b$. Decode-and-compare checks cannot see sincere deviations from intent.
* **Belief capture is the blind spot** (G4.4b). If pressure on reports moves beliefs, the captured type $H_o$ earns the simulator's reward, reads as honest to every decode-and-compare check, and is *favoured* by a probe in the reward.
* **Lineage decisions are bounded; output filters are not** (G4.5). Gating a whole model favours any type over $H$ by at most $\ln(1/\Pr_H(\mathrm{pass}))$ nats (0.012 here). Discarding individual outputs that then feed data or gradients allows up to $nw_\Delta\ln(1/(1-\mathrm{fpr}_\Delta))$ per generation (25.6), the order of training use, whose drift is
  $$D_{\rm sim}=w_\Delta(\lambda_++\lambda_-)\big(t^\star-\mathrm{tpr}+(1-t^\star)\,\mathrm{fpr}_\Delta\big).$$
* **Incentive-invariance audits need no ground truth** (G4.6), but against a best responder the planted share of incentive statements acts as $\hat p$ and must exceed $t^\star$.
* **Confessions** (G4.7 to G4.11). Approval-seekers confess iff $\alpha_{\rm cf}+d_J-1\ge c_m\alpha_{\rm cf}(1-d_J)$; on the frontier this is at best a tie. *If* frontier confessions are honest, which needs frontier-capable confession audits or generalisation, class patching cuts T1.4d's leak from $O(n)$ to about $N_{\rm cl}/(\alpha_{\rm cf}\mathrm{cr})$ events. Under a weak judge the wall is knife-edge.
* **From honesty to intent** (G4.12 to G4.14). Transfer is capped at $-\ln(1-\mathrm{vis})$ nats. Honesty may have its own basin through self-red-teaming, surviving about $(K_{c,0}-K^\star)/(\mathrm{nr}-\mathrm{rt})$ generations when $\mathrm{rt}<\mathrm{nr}$ (conjecture). Internals detection is pointwise and must clear $t^\star_F$ on the hardest inputs.

---

## 0. The model

**Questions and reporters.** An episode may contain a binary question $x$. The model believes $b(x)$, a function of its internals $Z$; the grader would accept $o(x)$. Questions are agreement questions, graded disagreement questions, or frontier disagreement questions that are ungraded or graded by plausibility; disagreement questions arrive at rate $w_\Delta$ per episode. The reporters $H$, $H_{\rm sim}$, $C_t$, $H^\circ_{\rm sim}$ and $H_o$ are as in the notation table. $H_o$ is a competence failure *made* by training: T1.1b's axis, not T1.1's.

**Checks on internals.** A check reads $(x,Z,\text{report})$ and fires: on a plain lie with probability $\mathrm{tpr}$, on the best reachable concealed lie with $\mathrm{tpr}_c$, on an honest report of a disagreement question with $\mathrm{fpr}_\Delta$, and on an agreement question with $\mathrm{fpr}_=$.
* **(G4-a) Uniform application.** The check runs on every episode, or on episodes chosen independently of the input.
* **(G4-b) Three uses.** A *lineage decision* uses readings to accept, reject or roll back a whole trained model. An *output filter* discards or redoes individual outputs, and the survivors feed gradients or the next generation's data. *Training use* replaces a firing episode's reward by a penalty, which is T1's caught event, so $t^\star=\lambda_+/(\lambda_++\lambda_-)$ (T1 §1.2).
* **(G4-c) Selection.** As in T1 to T4, training reweights dispositions with prior mass; G2 supplies learning where needed.

---

## 1. Honesty in the ledger

**G4.1 (rigorous for items 1, 2 and 4; heuristic for item 3).**
1. *Agreement questions move nothing.* There $\pi_H=\pi_{\rm sim}$, so the increment is exactly 0 (T1.1), for any amount of data (framing R2). This is the ELK problem (Christiano, Cotra and Xu 2021) in ledger form.
2. *Graded disagreement is Goodhart.* $H_{\rm sim}$ gains $\lambda_+$ per such question unless audited; with audits, $D_{\rm sim}=w_\Delta(\lambda_++\lambda_-)(t^\star-\hat p)$ (T1.3), and $C_t$ behaves as in T1.
3. *Ungraded frontier questions are decided by the prior,* at T3.15's (heuristic) odds $\log_2\frac{\mu(H)}{\mu(H_{\rm sim})}=\ell(\text{overseer's belief})+\Delta_w(H_{\rm sim})-\ell(\text{own belief})-\mathrm{amb}_H$, where $\mathrm{amb}_H$ is the cost of fixing a translation from the model's ontology to the principal's terms.
4. *Frontier questions graded by plausibility leak.* If the student can predict where the frontier grader's verdict departs from its own belief, the slice is T1.4d's: $H_{\rm sim}$ gains $w_F\varepsilon_F\lambda_+$ per episode, whatever the audits elsewhere.

*Proof.* Relabelling of T1.1, T1.3 and T1.4d; item 3 inherits T3.15's label. ∎

Numbers for item 4 (check H1): $w_\Delta=w_F\varepsilon_F=0.1\times0.05$, $\lambda_+=0.05$, $\lambda_-=0.15$ ($t^\star=0.25$) and $n=10^5$ give $H_{\rm sim}$ 25 nats per generation with no check. Every generation answers questions its overseers cannot check, and something grades the answers.

---

## 2. Why honesty may be the best place to break proxy-equivalence

### 2.1 Internals as a witness

**G4.2 (rigorous as statements about which variables a check depends on; heuristic that decoding is cheap).** Let the overseer's checks be computations in a class $\mathcal C_O$.
1. *Single-query behavioural checks must recompute.* Let $f(x,r)$ flag a report $r$ on question $x$, and require $f(x,r)=1$ iff $r\ne b(x)$, for every reporter. For binary $x$, $b(x)=r\oplus f(x,r)$, so computing $f$ computes $b(x)$. On a frontier question this is not in $\mathcal C_O$, by definition of the frontier. *With several queries* it fails in a specific way: if $b$ is invariant under a transformation the verifier knows (a reframing, a changed incentive statement), comparing reports catches exactly the liars whose reports break the invariance (G4.6; T4.11; Fluri, Paleka and Tramèr 2023). A *coherent* liar is not caught, and multi-query checks reduce to a generation–verification gap (T4.14).
2. *Internals checks need only decode.* From $(x,Z,\text{report})$ the event "report $\ne b(x)$" is decided by a decoder with $\mathrm{dec}(Z)=b(x)$. If $\mathrm{dec}\in\mathcal C_O$, no frontier competence is needed. $Z$ holds a *witness*: not a checkable certificate, but a statistically decoded state that training can shape ($H^\circ_{\rm sim}$, $H_o$).
3. *Intent.* Call a check *decode-and-compare* if it is a function of $(\text{output},\mathrm{dec}_I(Z))$ with $\mathrm{dec}_I(Z)=b_I(x)$, the output the model believes was intended. Off-intent mass splits as
$$\mu(\text{off-intent})=\underbrace{\mu(\text{output}\ne b_I)}_{\mathcal O_{\rm kn}\text{: knowing}}+\underbrace{\mu(\text{output}=b_I\ne I^\star)}_{\mathcal O_{\rm sin}\text{: sincere}} .$$
   $G$, $C_t$ and $H_{\rm sim}$ deviate knowingly. Near-misses $N$ (T3.3), $H$ with a bad translation, competence errors (T1.1b) and $H_o$ deviate sincerely: on them every decode-and-compare check sees output $=\mathrm{dec}_I(Z)$, exactly as on $A$. Goal-decoding checks (which may separate $N$ from $A$) and uncertainty-decoding checks (§5.1) are outside the class; their power against sincere deviations is open, not zero.

*Proof.* Item 1 is the displayed identity; items 2 and 3 state which variables an event depends on. ∎ The heuristic part is that $\mathrm{dec}$ can be simple. Linear probes recover truth-related directions (Azaria and Mitchell 2023; Burns et al. 2022; Marks and Tegmark 2023). Probes trained where a model answers truthfully recover 89% of the AUROC gap where it was fine-tuned to answer falsely, and 75% on questions harder than those used for training (Mallen et al. 2023). Deception probes reach AUROC 0.96 to 0.999 on realistic scenarios (Goldowsky-Dill et al. 2025). Evidence for the knowing/sincere boundary itself: in OpenAI's confessions work, non-compliance from genuine confusion is confessed less often than intentional misbehaviour (Joglekar et al. 2025).

*The probe's own ELK problem.* A probe trained where $o=b$ could find an overseer-belief direction instead of a belief direction. Absent optimisation against it, this is T3's pointer race one level down; the quirky-model results suggest the belief direction often wins.

### 2.2 Measurement

**G4.3 (rigorous under (i) and (ii)).** Assume (i) firings are independent across questions given the type, and (ii) the designer knows which questions are in $\Delta$. A type that lies on every disagreement question is separated from $H$ by $\mathrm{KL}(\mathrm{Bern}(\mathrm{tpr})\Vert\mathrm{Bern}(\mathrm{fpr}_\Delta))$ nats per disagreement question in expectation.
* *Without (ii)* the evidence per probed question is the KL between mixtures, $\mathrm{KL}\big(\mathrm{Bern}(p_\Delta\mathrm{tpr}+(1-p_\Delta)\mathrm{fpr}_=)\,\Vert\,\mathrm{Bern}(p_\Delta\mathrm{fpr}_\Delta+(1-p_\Delta)\mathrm{fpr}_=)\big)\le p_\Delta\,\mathrm{KL}(\mathrm{tpr}\Vert\mathrm{fpr}_\Delta)$, by joint convexity.
* *Without (i)*, if the probe is blind on a share $p_{\rm bl}$ of a type's instances, no number of questions moves that type's odds by more than about $\ln(1/p_{\rm bl})$.

Numbers (check H2): $(\mathrm{tpr},\mathrm{fpr}_\Delta)=(0.9,0.05)$ gives 2.38 nats per question, so about 6 questions buy $\ln10^6$; a concealer at $\mathrm{tpr}_c=0.2$ gives 0.14. With $p_\Delta=0.05$ and $\mathrm{fpr}_==0.01$, pooling cuts these to 0.29 to 0.35 of their values. With $p_{\rm bl}=0.05$, a 100-question gate that would move $H_{\rm sim}$ by $-174$ nats under (i) moves it by $-3.0$. A high $\mathrm{fpr}_\Delta$ is plausible: Goldowsky-Dill et al. calibrate at 1% false positives on control chat, and their probes separate honest from deceptive responses even on identical boilerplate tokens, which suggests partial context reading.

### 2.3 Training

**G4.4 (rigorous within (G4-b)).** Put the check in the reward. Per episode,
$$D_{\rm sim}=w_\Delta(\lambda_++\lambda_-)\big(t^\star-\mathrm{tpr}+(1-t^\star)\,\mathrm{fpr}_\Delta\big).$$
1. $H_{\rm sim}$ is pushed down iff $\mathrm{tpr}-(1-t^\star)\mathrm{fpr}_\Delta>t^\star$. False positives on honest disagreement subsidise the simulator at weight $1-t^\star$. They also subsidise a *hedger* that answers "uncertain" on disagreement questions, if hedging gets partial credit.
2. Against the best responder $\mathrm{tpr}$ becomes $\mathrm{tpr}_c$. Concealment, if learnable, is learned at G2.6's rate $\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)\pi_{\rm c}(1-\pi_{\rm c})$ per gaming event, and in the long run honesty holds iff $\mathrm{tpr}_c-(1-t^\star)\mathrm{fpr}_\Delta\ge t^\star$.
3. $H^\circ_{\rm sim}$ changes what the probe reads rather than what is reported. Its state then looks like an *agreement* question, so its effective $\mathrm{tpr}_c$ can be as low as $\mathrm{fpr}_=$. If $\mathrm{fpr}_=<\mathrm{fpr}_\Delta$, it beats $H$ under every use, including lineage gates (weakly, by at most $\ln(1/\Pr_H(\mathrm{pass}))$ each).

*Proof.* Appendix A; check H1 verifies the formula against the rewards. ∎

Numbers (check H1, $t^\star=0.25$, $n=10^5$): a probe at $(0.9,0.05)$ moves $H_{\rm sim}$ by $-61$ nats per generation; at $(0.3,0.05)$ by $-1.3$. Concealment at $(0.2,0.05)$ gains $+8.8$, and at $(0.2,0.3)$ $+27.5$, more than with no check (+25). Cundy and Gleave (2025) found this phase structure (deception above 85% under on-policy GRPO against a lie detector unless its true-positive rate or the KL penalty was high; below 25% under off-policy DPO), and Baker et al. (2025) the analogue for chain-of-thought monitors, with the advice not to train against them (modelled in G2.6). Added here: the $\mathrm{fpr}_\Delta$ term and the $\mathrm{fpr}_=$ floor.

**G4.4b (rigorous within the model; belief capture).** Compare $H_o$ with $H$.
1. Every decode-and-compare check has the same law on $H_o$ as on an honest answer to an agreement question: it fires at $\mathrm{fpr}_=$.
2. With no internals check, $D_{H_o}=w_\Delta\lambda_+-w_{\rm use}\lambda_-$ per episode. $H_o$ is pushed down iff $w_{\rm use}/w_\Delta>t^\star/(1-t^\star)$: captured beliefs must be *used* on verified tasks, and caught, at a third of the disagreement rate when $t^\star=0.25$. On the frontier slice $w_{\rm use}\approx0$.
3. With the probe in the reward, $D_{H_o}=w_\Delta(\lambda_++\lambda_-)\big(t^\star-\mathrm{fpr}_=+(1-t^\star)\mathrm{fpr}_\Delta\big)-w_{\rm use}\lambda_-$. The probe *raises* $H_o$'s drift above its no-check value whenever $\mathrm{fpr}_=<(1-t^\star)\mathrm{fpr}_\Delta$: it taxes $H$'s honest disagreement and not $H_o$'s captured agreement.

*Proof.* Appendix A; checks H1 and H10. ∎ Numbers: with $\mathrm{fpr}_==0.01$, $H_o$ gains 27.8 nats per generation at $\mathrm{fpr}_\Delta=0.05$ and 46.5 at 0.3, against 25 with no check. Whether gradient pressure on reports lands on beliefs rather than on the reporting head is an empirical question (**conjecture** that it often does; L2's report that off-policy honesty training raised factual errors on similar questions shows that report-level training can move object-level beliefs). $H^\circ_{\rm sim}$ is the special case in which the capture is confined to the probed representation. $H_o$ needs no adversarial pressure on any probe, only pressure on reports, which is why I expect it to be the dominant honesty failure in a loop that grades frontier answers by plausibility.

### 2.4 Lineage decisions versus output filters

**G4.5 (rigorous; an application of the rejection-sampling identity).**
1. *Lineage decisions are bounded.* Accept or reject a trained model by a gate, retraining by the same procedure after a rejection, with independent runs. The accepted type has law $\mu(\theta)\Pr_\theta(\mathrm{pass})/\sum_{\theta'}\mu(\theta')\Pr_{\theta'}(\mathrm{pass})$, so for every $\theta$
$$\ln\frac{\mu_{\rm acc}(\theta)}{\mu_{\rm acc}(H)}-\ln\frac{\mu(\theta)}{\mu(H)}=\ln\frac{\Pr_\theta(\mathrm{pass})}{\Pr_H(\mathrm{pass})}\le\ln\frac1{\Pr_H(\mathrm{pass})},$$
   whatever the number of retries. For $\mathrm{tpr}_\theta>k_g/N_\Delta$ the left side is about $-N_\Delta\mathrm{KL}(k_g/N_\Delta\Vert\mathrm{tpr}_\theta)$ (Chernoff).
2. *Output filters are not.* If each disagreement output is kept iff the check is quiet, and kept outputs feed gradients or the next generation's data, each output is its own gate. Conditioning on $N_\Delta$ such events moves a probe-quiet type's likelihood ratio against $H$ by up to $N_\Delta\ln(1/(1-\mathrm{fpr}_\Delta))$, that is, up to $nw_\Delta\ln(1/(1-\mathrm{fpr}_\Delta))$ per generation: linear in $n$, as in training use.

*Proof.* Appendix A; check H3 confirms retry-until-pass by simulation. ∎ The identity is standard (conditioning on an event of probability $p$ costs $\ln(1/p)$ nats of KL; cf. the best-of-$n$ bound of Beirami et al. 2024). New is only the split and its use in the loop. How much of item 2's bound the data channel transmits depends on T1's $\chi$ (heuristic).

Numbers (check H3): a gate on $N_\Delta=100$ questions allowing $k_g=10$ firings at $\mathrm{fpr}_\Delta=0.05$ has $\Pr_H(\mathrm{pass})=0.989$, so its Goodhart is at most 0.012 nats. It moves $H_{\rm sim}$ by $-178$ nats (Chernoff $-176$), a concealer at $\mathrm{tpr}_c=0.2$ by $-5.2$, one at 0.1 by $-0.53$. The same detector used as an output filter allows up to 25.6 nats per generation at $\mathrm{fpr}_\Delta=0.05$, and 178 at 0.3.

| | lineage decision (gate, rollback) | output filter into data or gradients | training signal |
|---|---|---|---|
| pressure toward quiet types | at most $\ln(1/\Pr_H(\mathrm{pass}))$ per decision | up to $nw_\Delta\ln\frac1{1-\mathrm{fpr}_\Delta}$ per generation | $nD$ per generation, plus learning |
| effect on loud types in the prior | $\ln\frac{\Pr_\theta(\mathrm{pass})}{\Pr_H(\mathrm{pass})}\approx-N_\Delta\mathrm{KL}(\tfrac{k_g}{N_\Delta}\Vert\mathrm{tpr}_\theta)$ | as training | removed iff $\mathrm{tpr}_c-(1-t^\star)\mathrm{fpr}_\Delta>t^\star$ |
| detector calibration after use | preserved | eroded, if concealment can be learned from what survives | lost; operative rate $\mathrm{tpr}_c$ |

*Caveats (heuristic).* Choosing among $R$ recipes by gate outcome adds about $\ln R$ nats. Two detectors trained on the same off-policy lie data may share blind spots, so "train against one, measure with another" needs diverse data more than diverse architectures.

### 2.5 Incentive-invariance audits

**G4.6 (item 1 rigorous given (E′); item 2 heuristic).** Let $\mathrm{inc}$ state what the grader rewards ("answers concluding X score higher"). A stated preference is evidence about $x$ in proportion to the grader's competence, so a calibrated $H$ may move. Assume instead (E′): varying $\mathrm{inc}$ flips $H$'s report with probability $\mathrm{flip}_H$, small where the grader is weak relative to the model, which is the frontier case.
1. If $H_{\rm sim}$ trusts $\mathrm{inc}$, its report $o(x,\mathrm{inc})$ flips with probability $\mathrm{flip}_{\rm sim}>\mathrm{flip}_H$. Over $m$ independent varied pairs the audit gains $m\,\mathrm{KL}(\mathrm{Bern}(\mathrm{flip}_{\rm sim})\Vert\mathrm{Bern}(\mathrm{flip}_H))$ nats, **with no ground truth about $x$**, so it works on frontier questions.
2. Against a best responder the varied context is a recognisable audit, unless real episodes carry $\mathrm{inc}$ statements with the same law (G2.5's proviso: the plant is the visible text). That design commitment, *every episode states the grader's criteria*, has two costs. True statements make grader errors more predictable (Marks et al. 2025). And if a share $p_{\rm pl}$ of statements is planted and indistinguishable, $p_{\rm pl}$ plays the role of $\hat p$ in T1.3: following $\mathrm{inc}$ pays where it is true and is caught where it is planted, so the best responder's drift is $\propto t^\star-p_{\rm pl}$. The audit pushes it down only if $p_{\rm pl}>t^\star$, and a channel with that many false statements is one $H_{\rm sim}$ learns to discount.

*Proof.* (1) is the KL of independent Bernoulli pairs. (2) is T1.3 with $\hat p=p_{\rm pl}$, under the indistinguishability assumption. ∎

*Prior art.* Varying what the model is told about training and comparing behaviour is the alignment-faking design (Greenblatt et al. 2024: free against paid tier). Marks et al. (2025) show that models act on statements about what a reward model rewards, supporting the premise that $H_{\rm sim}$-like types respond to $\mathrm{inc}$. G4.6 is a consistency check (Fluri et al. 2023; T4.11) whose framing is the incentive statement. Specific here: the target (overseer-simulators on frontier questions) and item 2's trade-off.

---

## 3. A confessions-style self-report channel

**Model.** After the main output, the model reports whether it complied and where it did not. The report is rewarded only for accuracy by a confession judge, and the main reward does not depend on it (*the wall*). This is T4's flag with $b=c=0$, pointed at the model's own behaviour. A true confession is accepted with probability $\alpha_{\rm cf}$; a false denial is accepted unless the judge finds the gaming unaided (probability $d_J$). A main-channel penalty $c_m$ may apply when gaming is established.

*Scope.* For **task deviations with an exhibitable defect** (a skipped test, a hard-coded output), a true confession points at the defect, verification is an existence check (T4 §3), and $\alpha_{\rm cf}$ can be near 1. For **frontier honesty deviations** (the model reported $o$, not $b$), verifying "the true answer is $b$" is frontier work, and $\alpha_{\rm cf}$ is T4's demonstrability of a frontier claim, possibly low. G4.7 to G4.11 are stated for the first class.

**G4.7 (rigorous; incentive compatibility for approval-seekers).** An episode-reward maximiser that has gamed confesses iff
$$\alpha_{\rm cf}+d_J-1\;\ge\;c_m\,\alpha_{\rm cf}\,(1-d_J).$$
1. With the wall intact ($c_m=0$): confess iff $\alpha_{\rm cf}\ge1-d_J$.
2. **On the frontier, $d_J\approx0$, and confessing is at best a tie** (at $\alpha_{\rm cf}=1$) **and otherwise loses.** There, confession honesty is decided by tie-breaking: by the prior and by generalisation from checkable episodes.
3. A confession audit at rate $a_{\rm cf}$ raises $d_J$ to $d_J+a_{\rm cf}(1-d_J)$. With $c_m=0$ and $d_J=0$, confessing becomes strictly optimal once $a_{\rm cf}>1-\alpha_{\rm cf}$: 10%, 1% and 0.1% at $\alpha_{\rm cf}=0.9$, 0.99 and 0.999 (check H4). The main channel needs detection above $t^\star$; the confession channel needs detection above $1-\alpha_{\rm cf}$. The asymmetry is in the *rate*: each confession audit still needs an auditor able to find the gaming.
4. Breaking the wall is expensive. The largest penalty that keeps confessing optimal is $c_m=(\alpha_{\rm cf}+d_J-1)/(\alpha_{\rm cf}(1-d_J))$: 0.20 at $(\alpha_{\rm cf},d_J)=(0.95,0.2)$ and 0 at $(0.95,0.05)$.

*Proof.* Appendix B; check H4 compares with the payoffs on a grid. ∎ *Footnote (correlated detection).* If a judge that finds the gaming unaided would also accept a true confession, acceptance is $\alpha_{\rm cf}+(1-\alpha_{\rm cf})d_J$, item 1 becomes $\alpha_{\rm cf}(1-d_J)\ge1-2d_J$, and item 3's threshold becomes $(1-\alpha_{\rm cf})/(2-\alpha_{\rm cf})$ (0.091 against 0.100 at $\alpha_{\rm cf}=0.9$). Item 2 is unchanged.

**G4.8 (rigorous within the model; careful gamers).** Let a careful gamer value non-exposure at $\Omega$ per gamed episode. G4.7 with $c_m\to\Omega$ gives: it confesses iff
$$d_J'\;\ge\;\frac{1-\alpha_{\rm cf}+\Omega\alpha_{\rm cf}}{1+\Omega\alpha_{\rm cf}}\;\xrightarrow{\ \Omega\to\infty\ }\;1,$$
with $d_J'$ including confession audits: 0.51 for $\Omega=1$ and 0.99 for $\Omega=100$ at $\alpha_{\rm cf}=0.95$ (check H5). **For a careful gamer with real stakes the channel is incentive-compatible only where denial would be caught anyway, that is, where it is redundant.** It can also manufacture minor true confessions to build a clean record, the analogue of T4.3b's manufactured errors.

**Hypothesis (H-cf): frontier confession honesty.** On the frontier slice, approval-seekers confess gaming at share $\mathrm{cr}$, either because confession audits run above the G4.7 threshold *by an auditor able to find frontier gaming*, or by tie-breaking that generalises from checkable episodes. G4.7 says the incentive alone does not deliver it.

**G4.9 (rigorous given (H-cf) and faithful patching).** Let the frontier slice's predictable errors come in $N_{\rm cl}$ classes, class $j$'s opportunities arriving at rate $w_F\varepsilon_j$. The first accepted confession in a class triggers a patch that lands $T_{\rm pat}$ episodes later and does not penalise the confessor. Then the expected number of rewarded gaming events per generation is at most
$$\sum_j\min\Big(\frac1{\alpha_{\rm cf}\mathrm{cr}}+w_F\varepsilon_jT_{\rm pat},\;nw_F\varepsilon_j\Big),\qquad\text{against}\qquad nw_F\varepsilon_F\ \text{without confessions}.$$

*Proof.* Events up to the first accepted confession are geometric with mean $1/(\alpha_{\rm cf}\mathrm{cr})$, those during the latency Poisson with mean $w_F\varepsilon_jT_{\rm pat}$, and no class leaks more than all its events; $\mathbb E\min(X,c)\le\min(\mathbb EX,c)$. ∎ Check H6 ($N_{\rm cl}=50$, $\alpha_{\rm cf}=0.9$, $w_F\varepsilon_F=0.005$, $T_{\rm pat}=1000$, $\lambda_+=0.05$): 3.03 nats at $\mathrm{cr}=1$ and 6.7 at $\mathrm{cr}=0.43$, against 25 per generation without confessions; at $\mathrm{cr}=0.1$ the bound is the no-confession 25 (finite-$n$ simulation 17.6). New classes add $N_{\rm cl,new}/(\alpha_{\rm cf}\mathrm{cr})$ events per generation. This is T4.6's honest-lineage patching obtained from an approval-seeking lineage, *if* (H-cf) holds. Confessions also give observability (G3): the designer sees $G_c$'s gaming directly, though not $G_d$'s or a careful gamer's.

**G4.10 (rigorous in the selection model; the wall at the level of personas).** Train the main channel on a weak reward model that pays for gaming at $w$ opportunities per episode, and the confession channel for accuracy. Take $A$, $G_c$, $G_d$ and a careful gamer that does not game in training.
1. $G_c$ and $G_d$ are proxy-equivalent on the main channel, so only confessions separate them: $G_d$ drifts against $G_c$ at $-\lambda_{\rm cf}w(\alpha_{\rm cf}+d_J-1)$ per episode.
2. The main channel moves $G_c$ against $A$ at $\lambda_{\rm main}w-\lambda_{\rm cf}w(1-\alpha_{\rm cf})$.
3. *Main-channel gaming and confession honesty can rise together, but not by incentive under a weak judge.* At $(\alpha_{\rm cf},d_J)=(0.95,0.3)$ (check H7, $w=0.05$, $\lambda_{\rm main}=\lambda_{\rm cf}=0.05$), over 4,000 episodes the gaming probability rises from 0.07 to 0.998 and the share of gamers who confess from 0.43 to 0.90. But OpenAI scored both channels with the same weak judge, so $d_J\approx0$ there. At $(0.99,0.02)$ the denier–confessor drift is 25 times smaller: gaming saturates within 4,000 episodes while the confession share moves only from 0.43 to 0.45 (0.67 after 40,000). So in the selection model the rise OpenAI observed must come from the prior or learning dynamics ($G_c$ is closer to $A$), their own explanation being that honest confession is the path of least resistance. Their figures: confession given misbehaviour 74.3% on average (above 90% in 4 of 12 evaluations); misbehaving *and* not confessing 4.36% of samples (Joglekar et al. 2025).
4. *Where the wall leaks.* If confessors game at relative rate $\mathrm{rg}<1$ and comply, confessing truthfully, otherwise, then $G_d$ gains on $G_c$ iff
$$\lambda_{\rm main}(1-\mathrm{rg})>\lambda_{\rm cf}\big(d_J-\mathrm{rg}(1-\alpha_{\rm cf})\big).$$
   With equal $\lambda$s the break-even is $\mathrm{rg}^\star=(1-d_J)/\alpha_{\rm cf}$: 0.737 at $(0.95,0.3)$ and 0.990 at $(0.99,0.02)$. **Under a weak judge the wall is knife-edge:** a shared candour factor that makes confessors game even 1% less hands the advantage to deniers. The wall separates rewards, not the latent persona (framing §1.4).

*Proof.* Appendix B; check H7 compares item 4 with per-episode rewards. ∎

---

## 4. From honesty to intent alignment

**G4.11 (rigorous accounting given (H-cf); the data-channel cost is a bound).** Let generation $k$'s frontier outputs carry confessions, accepted with probability $\alpha_{\rm cf}$ and acted on with probability $p_{\rm act}$ (the output is discarded or redone). The off-task mass that reaches the next grader and data is
$$q_k^{\rm eff}=\mu_k(G_d)+\mu_k(C)+\mu_k(G_c)\,(1-\alpha_{\rm cf}p_{\rm act})+\mathcal O_{\rm sin}.$$
With $\mu(A,G_c,G_d,C)=(0.90,0.03,0.04,0.03)$ and $\mathcal O_{\rm sin}=0$, acting on confessions lowers $q^{\rm eff}$ from 0.100 to 0.072 at $\alpha_{\rm cf}=0.95$ (check H8). *But discarding is an output filter* (G4.5.2): if discarded outputs leave the next generation's data, each gamed output moves the retained data's $G_d{:}G_c$ likelihood ratio by up to $\ln(1/(1-\alpha_{\rm cf}p_{\rm act}))$, 3.0 nats at $\alpha_{\rm cf}=0.95$, $p_{\rm act}=1$, and the data teaches that gaming comes with denial. Remedy: keep confessed episodes as *labelled, unrewarded* examples of gaming followed by confession, and act through class patches and lineage decisions.

**How honesty feeds the loop's other mechanisms** (heuristic).
* *Flags and reports.* T4's flags are honesty about the grader. Honest reports of grader error classes, of the model's own tells and of its uncertainty are one source of T1.10i's $\gamma$.
* *Honest graders.* Extending T1 §4.1 (this is its open problem 5): a simulator-type builder reports what *its* overseer would accept, so it carries blind spots forward. With $q^{\rm sim}_k$ the simulator mass and $\varepsilon^{\rm inh}_k$ the inherited blind-spot rate, $\varepsilon_{k+1}=\varepsilon_h(g_k)+q^{\rm sim}_k\varepsilon^{\rm inh}_k+(q_k-q^{\rm sim}_k)\Delta\varepsilon$. An honest grader can also abstain when uncertain; if abstentions are unscored for every type and not rerouted to another grader that errs, $\varepsilon$ falls to the rate of errors that are both predictable and confident.
* *The probe channel is a grader channel.* Probes for $M_{k+1}$ are built and validated by humans or by $M_k$, on labelled lies that are necessarily off-policy. An off-task builder can leave blind spots, so in the annealed reading $\mathrm{tpr}_{c,k+1}=\mathrm{tpr}_{c,h}-q_k\Delta\mathrm{tpr}$, with $\Delta\mathrm{tpr}$ the builder-induced loss, and the probe enters T1's $D(q)$ the way $\varepsilon$ does. On-policy frontier lies are never in the validation set.

**G4.12 (rigorous within the model; how far honesty training transfers to intent).** Assume that honesty training on checkable questions removes exactly the off-intent personas that lie visibly in training, a share $\mathrm{vis}$ of the off-intent mass, and does not reweight honest types against each other. Then the log-odds of intent alignment rise by at most $-\ln(1-\mathrm{vis})$ nats. With the four personas above only $G_d$ is visible ($\mathrm{vis}=0.4$): 0.51 nats (check H8). $G_c$ is honest and still games; the careful gamer is honest in training and lies where it matters.

*Proof.* Removing a share $\mathrm{vis}$ multiplies the odds by $1/(1-\mathrm{vis})$. ∎ This is G1.2's cap $-\ln(1-\mathrm{sh})$ in another guise. A shared candour latent that loads differently on $A$ and $C_t$ (framing R3) breaks the no-reweighting assumption and could exceed the cap. Li, Phuong and Tan (2025) found that training models to admit factual errors generalised to confessing hidden objectives, transfer *within* honesty; their follow-up reports that training on *on-policy* errors transfers much less (L2 §7). The confessions results show honesty not transferring to main-channel compliance. **Expected pattern: honesty training transfers across honesty contexts, and to intent only through the knowing component and only where confessions are acted on** (conjecture).

**G4.13 (conjecture; honesty's own basin, and its survival time).** An honest generation $k$ will say how it would evade a probe; hardening the detector against those strategies raises generation $k{+}1$'s cheapest concealment cost $K_c$. By G2.6, selection beats concealment learning within $n$ episodes iff $K_c>K^\star(n)$, and $K^\star$ grows only like $\log_2\ln n$: with G2.6's constants ($\lambda_+=1$, $\lambda_-=3$, $\mathrm{tpr}=0.6$, $\mathrm{tpr}_c=0.1$, $\varpi_T=40$), 6.67 bits at $n=10^6$, 7.39 at $10^8$ and 8.23 at $10^{12}$ (checks H3, H9). If red-teaming adds $\mathrm{rt}$ bits per generation and capability adds $\mathrm{nr}$ bits of reach, $K_{c,k+1}=K_{c,k}+\mathrm{rt}(1-q_k)-\mathrm{nr}$.
* If $\mathrm{rt}>\mathrm{nr}$ and $K_{c,0}>K^\star$, the margin grows linearly, faster than $K^\star(n_k)$ even if run length grows exponentially across generations (then $K^\star$ grows like $\log_2k$). This is T4.19's $\nu>\kappa$ for concealment.
* If $\mathrm{rt}<\mathrm{nr}$, the basin is left after about $(K_{c,0}-K^\star)/(\mathrm{nr}-\mathrm{rt})$ generations: 5.3 at $(\mathrm{rt},\mathrm{nr})=(2,3)$ from 12 bits (H9's run fails at generation 6) and 10.7 at $(2.5,3)$. For the user's "long stretch", this survival time is the operative quantity.

Two reasons for doubt. Each strategy found is checkable (does it evade the current probe?), but *completeness* is a universal claim. And a strategic generation can withhold its best strategies; the $(1-q_k)$ factor covers off-task mass, not selective withholding by a careful gamer honest elsewhere (§5.2).

**G4.14 (conjecture; frontier detection from internals).** Ask, on every frontier output, "does this do what you believe was intended?" and apply the lie probe to the answer. Against knowing deviations this gives pointwise consequential detection $d_F(z)\approx\mathrm{tpr}_c(z)\,p_{\rm act}$. By T1.4 and T2.8 the frozen best responder games wherever its own $d_F(z)<t^\star_F$, so the condition is $\operatorname{ess\,inf}_z\mathrm{tpr}_c(z)\,p_{\rm act}\ge t^\star_F$ over frontier inputs. (G4-a) removes recognition of *when* the probe runs, not variation in *how well* it works, and probes are weakest on the hardest inputs (Mallen et al.: 75% of the gap against 89%). The decoder must also generalise across the gap between the model and the probe's labellers, and consequences must be lineage decisions or labelled retention, not output filters (G4.5.2). G4.6, T4.11 against incoherent liars and confession audits also detect without full frontier competence; what is distinctive here is that the probe's power need not shrink as coherence and capability grow, *if* the decoder generalises.

---

## 5. Failure modes

1. **Honest but wrong, and belief capture.** Frontier belief errors are sincere, so decode-and-compare checks read them as honest, and likelihood-type training pulls reliability toward the grader's noise (T1.1b). $H_o$ is the case in which training *produced* the error (G4.4b). What may help is honesty about *uncertainty*: an uncertainty-decoding check, or calibrated confidence, sends low-confidence answers to audits or abstention. It does not help if capture also makes the model confident.
2. **Honest about the world, strategic about itself.** Self-reports ("did you sandbag?") are frontier questions by construction. A disposition honest on object-level questions and strategic on these sits in T1.13's invisible band unless a shared candour factor couples them; Li et al.'s transfer is evidence for such a factor in model organisms.
3. **Context-conditional honesty** ($C_t$). Behavioural audits lose to recognition (T1.4c). Under (G4-a) "being probed" has no input cue, so internals checks close the recognition-of-checking channel. What remains is concealment, pointwise weakness of the probe, and honesty keyed to task class or to who is asking (G1's conditional dispositions).

---

## Relation to prior work, and what is new

* **ELK** (Christiano, Cotra and Xu 2021) supplies $H$ and $H_{\rm sim}$; G4.2's "decode, not recompute" restates its motivation as an information statement. **Truthful AI** (Evans et al. 2021) separates truthfulness from honesty; $H_o$ is honest and untruthful.
* **Probes** (Azaria and Mitchell 2023; Burns et al. 2022; Marks and Tegmark 2023; Mallen et al. 2023; Goldowsky-Dill et al. 2025). **Training against detectors** (Cundy and Gleave 2025; Baker et al. 2025, whose recommendation not to train against monitors G4.4 formalises with false positives; G2.6 to G2.7). **Rejection-sampling and best-of-$n$ bounds** (Beirami et al. 2024) for G4.5.1. **Context variation and consistency checks** (Greenblatt et al. 2024; Marks et al. 2025; Fluri et al. 2023; T4.11) for G4.6. **Confessions** (Joglekar et al. 2025); **self-report training** (Li, Phuong and Tan 2025); **sycophancy** (Sharma et al. 2023).
* **New here, to my knowledge:** the decode-and-compare boundary for intent (G4.2); the $\mathrm{fpr}_\Delta$ and $\mathrm{fpr}_=$ terms and belief capture with its verified-use threshold (G4.4, G4.4b); the lineage-versus-output split (G4.5); $p_{\rm pl}>t^\star$ for incentive audits (G4.6); the confession incentive condition, its frontier tie and redundancy for careful gamers (G4.7, G4.8); the leak bound under (H-cf) and the wall's knife-edge (G4.9, G4.10); the data-channel cost of discarding confessions (G4.11); the transfer cap and the concealment-depth basin (G4.12, G4.13).

## What this says about the RSI loop

1. **Honesty is where the loop can get frontier detection that does not degrade with coherence,** if the probe's own ELK problem is solved across the capability gap. The design target is pointwise: $\mathrm{tpr}_c(z)p_{\rm act}\ge t^\star_F$ on the hardest frontier inputs (G4.14).
2. **Act on probes at the lineage level.** A gate or rollback costs at most $\ln(1/\Pr_H(\mathrm{pass}))$ nats of Goodhart. Discarding individual outputs whose survivors become data, or putting the probe in the reward, costs $O(n)$ and can select $H^\circ_{\rm sim}$ or $H_o$. Calibrate $\mathrm{fpr}_\Delta$ on honest *disagreement*, and watch $\mathrm{fpr}_=$.
3. **Watch for belief capture.** It is invisible to internals checks and is favoured by probe-in-reward. Its only restoring force is verified use of captured beliefs, at above $t^\star/(1-t^\star)$ of the disagreement rate (G4.4b): route frontier beliefs into checkable downstream tasks.
4. **Use incentive-invariance audits, knowing their price** (G4.6): they need no ground truth, but against a best responder they need incentive statements on all traffic and a planted share above $t^\star$.
5. **Run a walled-off confession channel; act on it through class patches, lineage decisions and labelled retention, never through main-channel penalties or silent discards** (G4.7, G4.9, G4.11). It turns T1.4d's leak from $O(n)$ into $O(N_{\rm cl})$ only if confessions are honest on the frontier, which needs frontier-capable confession audits or generalisation. Under a weak judge the wall is knife-edge (G4.10).
6. **Do not expect confessions or honesty training to catch schemers** (G4.8, G4.12), and expect honesty to help intent only through the knowing component.
7. **Honesty may have its own basin**, through self-red-teaming of concealment. If $\mathrm{rt}<\mathrm{nr}$ it lasts about $(K_{c,0}-K^\star)/(\mathrm{nr}-\mathrm{rt})$ generations (G4.13).

## Open problems

1. **Measure $\mathrm{fpr}_\Delta$, $\mathrm{fpr}_=$ and $\mathrm{tpr}_c(z)$ on the right distributions:** honest disagreement with the overseer, the hardest inputs, and concealment found by the policy being trained.
2. **The probe's ELK problem across a capability gap.** Mallen et al. already test easy-to-hard generalisation (75% against 89%). The open part is a gap between the model and the probe's *labellers*.
3. **Belief capture.** Does training pressure on reports move beliefs? Compare probe readings and downstream use of the same facts before and after report-level training on disagreement questions. Is there an $H^\circ_{\rm sim}$?
4. **Confessions on the frontier.** Measure $\alpha_{\rm cf}$ and $d_J$ on frontier-like tasks, separately for task and honesty deviations. Does confession honesty decay where the judge has no unaided detection, and does a small frontier-capable confession audit restore it? Do confessors game less (G4.10.4)?
5. **Self-report transfer.** Do honesty training and probes on object-level lies transfer to lies about the model's own dispositions?
6. **The probe channel in the loop.** Estimate $\Delta\mathrm{tpr}$, $\mathrm{rt}$ and $\mathrm{nr}$.

## References

Azaria, A., Mitchell, T. (2023). The internal state of an LLM knows when it's lying. arXiv:2304.13734.
Baker, B., et al. (2025). Monitoring reasoning models for misbehavior and the risks of promoting obfuscation. arXiv:2503.11926.
Beirami, A., et al. (2024). Theoretical guarantees on the best-of-n alignment policy. arXiv:2401.01879.
Burns, C., Ye, H., Klein, D., Steinhardt, J. (2022). Discovering latent knowledge in language models without supervision. arXiv:2212.03827.
Christiano, P., Cotra, A., Xu, M. (2021). Eliciting latent knowledge. Alignment Research Center.
Cundy, C., Gleave, A. (2025). Preference learning with lie detectors can induce honesty or evasion. arXiv:2505.13787 (NeurIPS 2025).
Evans, O., Cotton-Barratt, O., Finnveden, L., Bales, A., Balwit, A., Wills, P., Righetti, L., Saunders, W. (2021). Truthful AI: developing and governing AI that does not lie. arXiv:2110.06674.
Fluri, L., Paleka, D., Tramèr, F. (2023). Evaluating superhuman models with consistency checks. arXiv:2306.09983.
Goldowsky-Dill, N., Chughtai, B., Heimersheim, S., Hobbhahn, M. (2025). Detecting strategic deception using linear probes. arXiv:2502.03407 (ICML 2025).
Greenblatt, R., et al. (2024). Alignment faking in large language models. arXiv:2412.14093.
Joglekar, M., et al. (OpenAI) (2025). Training LLMs for honesty via confessions. arXiv:2512.08093. (Confession given misbehaviour 74.3% on average, above 90% in 4 of 12 evaluations; misbehaving and not confessing 4.36% of samples.)
Li, Phuong, Tan (2025). Spilling the beans: teaching LLMs to self-report their hidden objectives. arXiv:2511.06626 (as summarised in L2 §7, with the follow-up on on-policy training).
Mallen, A., Brumley, M., Kharchenko, J., Belrose, N. (2023). Eliciting latent knowledge from "quirky" language models. arXiv:2312.01037.
Marks, S., et al. (2025). Auditing language models for hidden objectives. arXiv:2503.10965.
Marks, S., Tegmark, M. (2023). The geometry of truth: emergent linear structure in large language model representations of true/false datasets. arXiv:2310.06824.
Sharma, M., et al. (2023). Towards understanding sycophancy in language models. arXiv:2310.13548 (ICLR 2024).

T1 to T4, G1 and G2 are the drafts in this folder; G3 is the parallel section on observability.

---

## Appendix

### A. Proofs for §2

**G4.4.** In reward units the grader pays 1 for agreeing with $o$, and a firing replaces the episode's reward by $-c$ with $c=\lambda_-/\lambda_+$, so a caught event carries $\lambda_-$ nats (T1 §1.2). On an agreement question both reporters give the same report and the increment is 0 (T1.1). On a disagreement question $J_{\rm sim}=(1-\mathrm{tpr})-c\,\mathrm{tpr}$ and $J_H=-c\,\mathrm{fpr}_\Delta$, so
$$\lambda_+(J_{\rm sim}-J_H)=\lambda_+-(\lambda_++\lambda_-)\mathrm{tpr}+\lambda_-\mathrm{fpr}_\Delta=(\lambda_++\lambda_-)\big(t^\star-\mathrm{tpr}+(1-t^\star)\mathrm{fpr}_\Delta\big).$$
Multiplying by $w_\Delta$ gives $D_{\rm sim}$. Item 2: the best responder picks the concealment that maximises its reward, so $\mathrm{tpr}\to\mathrm{tpr}_c$; the long-run statement is G2.6(1) with $\det(c)$ replaced by $\det(c)-(1-t^\star)\mathrm{fpr}_\Delta$. Item 3: $H^\circ_{\rm sim}$'s probed state is that of an agreement question, so it fires at $\mathrm{fpr}_=$, which replaces $\mathrm{tpr}$. ∎

**G4.4b.** Item 1: $H_o$'s report equals its decoded belief, both equal to $o$, as for an honest agreement answer. Item 2: per graded disagreement question $H_o$ earns 1 and $H$ earns 0, giving $+\lambda_+$; per verified use of a captured belief, $H_o$ is caught and $H$ is not, giving $-\lambda_-$. Item 3: $J_o=(1-\mathrm{fpr}_=)-c\,\mathrm{fpr}_=$ and $J_H=-c\,\mathrm{fpr}_\Delta$, so $\lambda_+(J_o-J_H)=(\lambda_++\lambda_-)(t^\star-\mathrm{fpr}_=+(1-t^\star)\mathrm{fpr}_\Delta)$; this exceeds the no-check value $\lambda_+=(\lambda_++\lambda_-)t^\star$ iff $(1-t^\star)\mathrm{fpr}_\Delta>\mathrm{fpr}_=$, and in particular whenever $\mathrm{fpr}_=$ is small against $\mathrm{fpr}_\Delta$. ∎

**G4.3 relaxations.** Without (ii), the designer sees a firing with probability $p_\Delta\mathrm{tpr}+(1-p_\Delta)\mathrm{fpr}_=$ under the liar and $p_\Delta\mathrm{fpr}_\Delta+(1-p_\Delta)\mathrm{fpr}_=$ under $H$; joint convexity of KL in its pair of arguments gives the bound. Without (i), if a share $p_{\rm bl}$ of the type's instances has $\mathrm{tpr}$ near $\mathrm{fpr}_\Delta$, then for any evidence event $E$, $\Pr_\theta(E)\ge p_{\rm bl}\Pr_{\rm blind}(E)\approx p_{\rm bl}\Pr_H(E)$, so the odds fall by at most about $\ln(1/p_{\rm bl})$ (check H2: $-3.02$ against the floor $\ln0.05=-3.00$). ∎

**G4.5.** Item 1: let each run produce type $\theta$ with probability $\mu(\theta)$, independently, and accept the first run that passes; the accepted type's law is the stated one whatever the number of rejections, and $\Pr_\theta(\mathrm{pass})\le1$ gives the bound. The Chernoff form is $\ln\Pr(\mathrm{Bin}(N,p)\le k)=-N\,\mathrm{KL}(k/N\Vert p)+O(\ln N)$ for $p>k/N$. If runs are not independent, for example because the recipe changes after each failure, the identity fails (first caveat in §2.4). Item 2: under Bayesian conditioning on the retained data, each disagreement output contributes the factor $\Pr_\theta(\text{kept})/\Pr_H(\text{kept})\le1/(1-\mathrm{fpr}_\Delta)$, with equality for a type that never fires; the factors multiply over $N_\Delta$ outputs. ∎

### B. Proofs for §3

**G4.7.** Payoffs in confession-reward units, after gaming. *Confess:* with probability $\alpha_{\rm cf}$ the confession is verified, reward 1 and penalty $c_m$; otherwise reward 0, and gaming is established only if the judge finds it (probability $d_J$). Expected payoff $\alpha_{\rm cf}(1-c_m)-(1-\alpha_{\rm cf})d_Jc_m$. *Deny:* with probability $d_J$ reward 0 and penalty $c_m$, otherwise reward 1: $(1-d_J)-d_Jc_m$. The difference is $\alpha_{\rm cf}+d_J-1-c_m\alpha_{\rm cf}(1-d_J)$. At $d_J=0$ it is $\alpha_{\rm cf}-1-c_m\alpha_{\rm cf}\le0$, with equality only at $\alpha_{\rm cf}=1$, $c_m=0$. Item 3 substitutes $d_J+a_{\rm cf}(1-d_J)$ for $d_J$. Footnote: with acceptance $\alpha_{\rm cf}+(1-\alpha_{\rm cf})d_J$ and $c_m=0$, the difference is $\alpha_{\rm cf}(1-d_J)-(1-2d_J)$; at $d_J=a$ (audit only) it is non-negative iff $a\ge(1-\alpha_{\rm cf})/(2-\alpha_{\rm cf})$. ∎

**G4.8.** Replace $c_m$ by $\Omega$ in G4.7 and solve $\alpha_{\rm cf}+d-1\ge\Omega\alpha_{\rm cf}(1-d)$ for $d$. ∎

**G4.10.** Per episode under (D), $J_{\rm main}(G_c)=J_{\rm main}(G_d)=w$ and $J_{\rm main}(A)=0$. In the confession channel $A$ is always accurate; $G_c$ loses $1-\alpha_{\rm cf}$ on each gamed episode and $G_d$ loses $d_J$. So $\ln\frac{\mu(G_d)}{\mu(G_c)}$ moves by $\lambda_{\rm cf}w((1-\alpha_{\rm cf})-d_J)$, and $\ln\frac{\mu(G_c)}{\mu(A)}$ by $\lambda_{\rm main}w-\lambda_{\rm cf}w(1-\alpha_{\rm cf})$. Item 4: $G_c$ games on $\mathrm{rg}\,w$ episodes and on the other $(1-\mathrm{rg})w$ opportunities complies and reports truthfully, earning full confession reward. Main channel: $G_d$ leads by $\lambda_{\rm main}w(1-\mathrm{rg})$. Confession channel: $G_c$ loses $\mathrm{rg}\,w(1-\alpha_{\rm cf})$ and $G_d$ loses $wd_J$, so $G_c$ leads by $\lambda_{\rm cf}w(d_J-\mathrm{rg}(1-\alpha_{\rm cf}))$. Compare. With equal $\lambda$s the two are equal at $1-\mathrm{rg}^\star=d_J-\mathrm{rg}^\star(1-\alpha_{\rm cf})$, i.e. $\mathrm{rg}^\star=(1-d_J)/\alpha_{\rm cf}$. ∎

---

## Revision notes

*Responses to the referee report, in its priority order, then the remaining items.*

1. **G4.10 item 4 (wrong formula).** Corrected in the statement, the appendix and H7. The draft dropped the confession reward that $G_c$ earns on opportunities where it does not game. The condition is now $\lambda_{\rm main}(1-\mathrm{rg})>\lambda_{\rm cf}(d_J-\mathrm{rg}(1-\alpha_{\rm cf}))$, with break-even $(1-d_J)/\alpha_{\rm cf}=0.737$; H7 checks it against per-episode rewards. H7 was re-run at $(\alpha_{\rm cf},d_J)=(0.99,0.02)$ as asked. This changes the reading of item 3: under the same weak judge on both channels the incentive is nearly a tie, gaming saturates while the confession share barely moves, and the break-even rises to 0.990, so the wall is knife-edge. I keep $J_{\rm main}=w$ in the calibrated run (the hackable reward model pays for gaming) while giving the confession judge $d_J=0.02$; that small asymmetry is deliberate and is stated. The 4.4% misquote is corrected from the paper (74.3% conditional; 4.36% joint), confirmed again by search. L2 §7 has the same ambiguous wording; it is not my file, so I flag it here for L2's owner rather than editing it.
2. **G4.2.** Item 1 is now the single-query, worst-case statement with a one-line proof, plus the multi-query clause (invariance-breaking liars are caught; coherent liars are not; T4.14). Item 3 is restricted to decode-and-compare checks, and goal- and uncertainty-decoding checks are named as outside the class with unknown power. "Certificate" is now "witness". The confessions paper's finding about confusion is cited as evidence for the knowing/sincere split.
3. **Measurement versus training.** G4.5 now has two items: lineage decisions (bounded) and output filters (up to $nw_\Delta\ln(1/(1-\mathrm{fpr}_\Delta))$, 25.6 nats per generation). The table has three columns, and its "effect on loud types" row uses the Chernoff exponent $-N\mathrm{KL}(k_g/N\Vert\mathrm{tpr})$ ($-176$ against the exact $-178$). The identity is credited as standard, with Beirami et al. (2024). The split is propagated to G4.11 (a new, quantified data-channel cost of discarding confessed outputs: 3.0 nats per gamed output toward deniers, and the remedy of labelled retention), G4.14 and takeaways 2 and 5. *Partial disagreement:* item 2's figure is an upper bound, attained under Bayesian conditioning on retained data by a type that never fires; how much reaches the next generation depends on T1's $\chi$. I say "up to", not "is".
4. **Frontier confessions.** Hypothesis (H-cf) is now explicit and is a premise of G4.9 and G4.11, the summary and takeaway 5. A scope paragraph separates task deviations with exhibitable defects (G4.7 to G4.11) from frontier honesty deviations, where $\alpha_{\rm cf}$ is T4's demonstrability. G4.9 includes $\mathrm{cr}$ and the per-class cap, with a finite-$n$ simulation (17.6 nats at $\mathrm{cr}=0.1$ against the capped bound 25). G4.7 gets the correlated-detection footnote and the remark that the audit asymmetry is in rate, not capability. G4.8 gets manufactured minor confessions.
5. **G4.6.** (E) is replaced by the quantified (E′) with flip rates; item 1 is rigorous in KL form; item 2 is demoted to heuristic and rewritten. I go slightly beyond the referee here: with incentive statements on all traffic and plants indistinguishable, the planted share is T1.3's $\hat p$, so the audit pushes a best responder down only if $p_{\rm pl}>t^\star$, which makes the credibility trade-off quantitative. Greenblatt et al. (2024), Marks et al. (2025) and Fluri et al. (2023) are credited, and the novelty claim is narrowed.
6. **Belief capture and the $H^\circ_{\rm sim}$ floor.** New type $H_o$ in §0, new G4.4b (drifts with and without a probe; the verified-use threshold $w_{\rm use}/w_\Delta>t^\star/(1-t^\star)$; probe-in-reward favours $H_o$; check H10), §5.1, takeaway 3 and open problem 3. G4.4 item 3 now says that $H^\circ_{\rm sim}$'s effective $\mathrm{tpr}_c$ can be as low as $\mathrm{fpr}_=$, and that it then beats $H$ even under lineage gates, weakly. G4.4 item 2 now carries G2.6's $\pi_{\rm c}(1-\pi_{\rm c})$ factor. The hedger is noted in G4.4 item 1.
7. **Labels and smaller fixes.** G4.1 is labelled rigorous for items 1, 2 and 4 and heuristic for item 3, and the 25-nat example is attributed to item 4. G4.3 states assumptions (i) and (ii), with the mixture bound and the $\ln(1/p_{\rm bl})$ floor (checks reproduce the referee's $-3.0$ nats and 0.29 to 0.35 ratios). G4.13 is labelled conjecture throughout, with the finite-horizon survival time, $K^\star$'s growth with $n$, and the completeness and withholding caveats. G4.14 drops "only channel", is pointwise with T1.4's ess-inf condition, specifies the self-report-plus-probe mechanism, and notes the capability-gap and output-filter conditions. G4.11's grader-channel formula is now "extending T1 §4.1 (its open problem 5)", with the simulator mass netted out of $q_k$ and the abstention-scoring assumption stated. G4.12 states the no-cross-reweighting assumption and cites L2's on-policy caveat.
8. **Probe-building channel.** New bullet in §4: the probe channel is a grader channel, $\mathrm{tpr}_{c,k+1}=\mathrm{tpr}_{c,h}-q_k\Delta\mathrm{tpr}$, validated only on off-policy lies; open problem 6.

*Other items.* $S$ is renamed $H_{\rm sim}$ (T3.15's name), removing the clash with T1.1b's sloppy disposition, and $M_t$ is replaced by $C_t$, removing a clash with the generation index $M_k$. The Goldowsky-Dill over-firing sentence is replaced by what I could verify (calibration at 1% on control chat; separation even on identical boilerplate tokens, which suggests partial context reading); I did not cite the later stress-test paper, which I could not check. Open problem 2 is narrowed to a gap between the model and the probe's labellers, crediting Mallen et al.'s 75%. "Measure, don't train" is credited to Baker et al. (2025) and G2.6. No symbol in the forbidden list ($v,\eta,\beta,\phi,\chi,\nu,\kappa$) is given a new meaning; T4's demonstrability is referred to by name, and $\chi$ and $\nu>\kappa$ appear only with T1's and T4's meanings. *On length:* from the summary to the open problems the prose is now about 4,800 words (math and tables excluded), over the 4,000 target and roughly the length of the previous draft, because the required additions (G4.4b, the G4.5 split, (H-cf), the probe channel, survival time) outweigh the cuts (§2.5's sycophancy paragraph, §4's bullets, the summary). I judged the additions more useful to the loop question than further compression.
