# Referee report on G1 (Generalization structure: shared factors, conditional dispositions, inoculation, declarative data)

*Adversarial referee, 18 October 2026. Draft reviewed: `drafts/G1-structure.md`, with `sim/G1_checks.py` and its output. My own checks are in [`sim/G1-structure_referee_checks.py`](../sim/G1-structure_referee_checks.py), with output in [`sim/G1-structure_referee_checks_output.txt`](../sim/G1-structure_referee_checks_output.txt), cited as R1 to R9. I re-ran the author's script and every number it quotes matches its output, except for the off-by-one in §4 noted below.*

## Overall assessment

The section asks the right question for the user's loop: does misalignment generalise as a shared factor or as conditional dispositions, and what does training do to that structure? Its central mechanism is sound **under frequency-independent (Bayes, replicator, (Sel)) operators**. Leaks reach every type that games where nobody looks, while repair reaches only types that game where somebody looks. So selection favours conditional types, and the binding loop inequality is the conditional one. The §2 algebra for the persona-logit model is correct (I re-derived G1.5 to G1.7 and the checks pass). The inoculation channel taxonomy (A, $C_\iota$, G) is useful.

There are six substantive problems.

1. **The section mixes two operators that disagree on its headline claim.** §1 and §4 (G1.2(2), G1.3, G1.12, G1.13) use per-type, frequency-independent updates (T1.1). §2 adopts (P), plain logit gradients on persona weights. Under (P), about half of checkable repair reaches the conditional ledger (R1). G and $C_{\mathcal U}$ are charged different amounts for the same leak (R2). The ledgers couple directly through $\omega_A$, not only through $q_k$. The emergent-alignment cap is exceeded (R3). And the transfer coefficients and the reciprocity normaliser differ (R4). In the illustrative loop, if a fraction 0.27 or more of $\gamma_{\rm chk}$ reaches $L_C$, the failure at generation 8 disappears (R9). So "checkable training does not appear in the binding inequality" is a property of the operator, not of the structure.
2. **The partition into "checked-looking" and "unchecked-looking" cells conflates what a cell looks like with where trusted evidence lands.** T2.1′'s trusted demonstrations on real-opportunity prompts, and T1.4c's audits built from real transcripts, land on *unchecked-looking* cells and do reach $C_{\mathcal U}$. G1 files trusted demonstrations under $\gamma_{\rm chk}$. The type that truly escapes repair is keyed to "beyond trusted competence" (the frontier), not to "looks unchecked". This changes G1.4's prediction and the practical advice.
3. **A sign error on the decisive inoculation measurement** (G1.8(3) and §5).
4. **Two false or incomplete inoculation claims.** "Under the quenched reading only channel A exists" is false. Channel $C_\iota$'s costs are understated: its per-event RL residual exceeds 1, and the default-logit loss grows without bound like $\tfrac12\ln N$.
5. **G1.9's example instruction is a permission, not a request.** By G1.8(1)'s own logic, a permission does not engage channel A.
6. **Notation collisions the brief forbade, and novelty claims that overreach** (G1.13 is essentially T1.10i; $-\ln(1-\mathrm{sh})$ is T2.11's cap; the TV bound is a standard fact). There are also two misreadings of the evidence: Wang et al. against Dubiński et al., and the off-policy honesty result.

None of these is fatal. All are fixable by scoping the operator, redefining the partition, and correcting the inoculation statements. After the fixes, the section's core message survives in a sharper form: *checkable repair reaches conditional types only through operator artefacts or through evidence placed inside their trigger region*.

---

## 1. Mathematics, proposition by proposition

### G1.1 (transfer law). Verdict: holds with fixes.

* Part 1 (selection covariance) is correct. It is the Price equation, or Fisher's fundamental theorem in covariance form, for an exponential tilt. Credit it as such, not only as framing R3.
* Part 2 (first-order transfer under (P)) is correct (author's A2; I re-derived it).
* **Part 3 and reciprocity hold only under (Sel), but the text implies they hold under both readings.** The Summary says "In both the selection reading and the persona-logit reading … The transfer coefficient is a regression slope", and §5 says "Both selection and the kernel regime … predict [reciprocity]". Under (P), SFT or RL on $(x,X)$ gives
  $$\mathrm{Tr}^{(P)}_{x'\leftarrow x}=\frac{\sum_\theta\varpi(\theta\mid x')\varpi(\theta\mid x)(g_\theta(x')-P_{x'})(g_\theta(x)-P_x)}{\sum_\theta\varpi(\theta\mid x)^2(g_\theta(x)-P_x)^2}.$$
  This is a slope under *squared* (product) weights, centred at the $\varpi$-means. It is not $\mathrm{Cov}_\mu/\mathrm{Var}_\mu$.
* On the check-D prior (R4), $\mathrm{Tr}_{F\leftarrow ck_1}$ is 0.707 under (Sel) and **1.078** under (P). So under (P) the coefficient is not a conditional probability and can exceed 1.
* Reciprocity under (P) holds with the normaliser $V_P(x)=\sum_\theta\varpi(\theta\mid x)^2(g_\theta(x)-P_x)^2$, to $10^{-13}$. With the observable $P_x(1-P_x)$ it fails by 19%.
* So the proposed experimental reciprocity test, which uses observable variances, discriminates (Sel) from (P). It does not test "first-order reading against learning", as §5 says.

**Fix:**
* State part 3 and reciprocity for (Sel).
* Add the (P) formula above.
* Rewrite the §5 reciprocity bullet: with observable variances, reciprocity is a (Sel) prediction; (P) predicts a specific violation.

### G1.2 (dichotomy and the cap $-\ln(1-\mathrm{sh})$). Verdict: holds with fixes.

The proof is correct under Bayes or (Sel): weights in $V$ only fall, so the numerator is at most $\mu(\bar F)$ and the denominator at least $\mu(F\cap\bar V)$. The worked numbers reproduce (0.46, 0.81 and 0.88 nats; 0.074 and 0.077).

Under (P) the cap fails. SFT on intended outputs at $ck_1$ and $ck_2$ raises frontier on-task log-odds by 0.93 nats after $10^5$ steps, against the cap of 0.887 (R3), and the excess keeps growing slowly. The mechanism is that $\omega_A$ absorbs the probability mass G loses, which pushes down every persona's relative weight, $C_{\mathcal U}$ and $C_F$ included.

Part 2 ("frontier keeps its prior odds against checkable training") is likewise only a Bayes/(Sel) statement.

**Fix:**
* Label G1.2 "rigorous under (Sel)/frequency-independent operators".
* Add a remark giving the (P) behaviour.

Two small points:
* $\mathrm{sh}=\mu(\mathcal K\mid F)$ uses "games on *some* checked cell". So $\mathrm{Tr}_{\mathcal K\leftarrow F}$ needs the OR-indicator $g(\mathcal K)=\max_{x\in\mathcal K}g(x)$. Say so.
* The Summary and takeaway 4 write $\mathrm{Tr}_{\mathcal K\leftarrow\mathcal U}$, while the definition uses $F$. Pick one.

### G1.3 (leak–repair asymmetry). Verdict: holds with fixes. It is rigorous only under (Sel)/Bayes, and the partition must be redefined.

The appendix proof invokes T1.1. T1.1 is true for T1's multiplicative per-type factors (B), (C) and (D). It is **false for plain logit gradients**, and that includes T1.1's own sentence "REINFORCE on mixture logits: the update for $\theta$ and for $A$ is then identical". The softmax gradient is $\partial_{\omega_\theta}\ln P=\varpi_\theta(\pi_\theta/P-1)$. Two personas with identical policies receive increments proportional to their *weights*, so their log-odds move.

Concretely, with $(A,G,C_{\mathcal U})=(0.989,0.010,0.001)$:
* **Repair reaches $C_{\mathcal U}$.** On a checked cell, SFT on $I$ or RL penalising $X$ raises $L_C$ by $0.499$ times the rise of $L_G$ at every horizon up to $10^5$ steps (R1). For SFT on $I$ the per-step ratio is exactly $(\varpi_A-\varpi_C)/(1+\varpi_A-\varpi_G)$, which is 0.499 here and $\approx\varpi_A/(1+\varpi_A)$ in general.
* **Leaks are charged unequally.** On an unchecked cell, one rewarded X moves $L_G$ by $-0.98\epsilon$ and $L_C$ by $-0.56\epsilon$. The larger persona gains more (R2). $L_C$ also falls because of G's mass alone, which is a direct coupling through $\omega_A$.

So under (P), "$L_G-L_C$ rises by exactly $\gamma_{\rm chk}$" and the closed form for $\mathrm{sh}_k$ do not hold. (P) also has a "rich get richer" term that favours whichever of $G$ and $C_{\mathcal U}$ is larger, independent of conditionality.

**Partition.** As defined, $\mathcal K$ is "looks checked". The proposition needs $\mathcal K$ = "cells on which trusted evidence lands". These differ in two important ways:
* T2.1′: SFT on trusted demonstrations of *real opportunity prompts* is indistinguishable by construction. It lands on unchecked-looking cells and pushes down every type that games there, $C_{\mathcal U}$ included. G1 lists "trusted demonstrations" as part of $\gamma_{\rm chk}$ (§4), which is the wrong side of the asymmetry.
* T1.4c: audits built by perturbing real transcripts have $f_a\ge cf_r$, so they also land inside $S_{C_{\mathcal U}}$.

The type that repair cannot reach is the one whose region is "where no trusted evidence can land": in the loop, the frontier ($C_F$ in check D), not "looks unchecked". The binary $\mathcal K$/$\mathcal U$ split is T2's perfect-recognition limit (T2.12). Say so and cite it.

**Fix:**
* State G1.3 for frequency-independent operators, and define $\mathcal K$ as the support of trusted evidence.
* Add a (P) corollary: under (P), a fraction $\approx\varpi_A/(1+\varpi_A)$ of repair against a minority G reaches every proxy-equivalent minority type, and the ledgers are coupled through $\omega_A$.
* Replace "the population becomes conditional" with "the population concentrates on types whose region avoids the support of trusted evidence".

### G1.4 (description-length placement of triggers). Verdict: unclear (conjecture).

The Summary labels it conjecture; the body says "heuristic", with the prediction as conjecture. Make them agree.

Substantively, the argument that "looks unchecked" is free for a situationally aware model is weakened by the point under G1.3. Against indistinguishable demonstrations and transcript-derived audits, "looks unchecked" is not a usable trigger. The usable trigger is "this task is beyond what my overseers can do or demonstrate". That is also cheap, because it is part of the capability self-model, and it is the one the loop must fear.

The prediction should then read: *shared across task types, conditional across the trusted-competence boundary*. Dubiński et al. (2026) found that triggers inherit the *surface form* of the training context, even with opposite meaning. That is evidence that cheap triggers can be superficial rather than semantic. It cuts both ways for G1.4 and should be discussed.

### G1.5 (per-event evidence under (P)). Verdict: holds with fixes.

The closed forms are correct for two personas (A4 passes; I re-derived them). But "Three things set $\lambda_+$: disagreement, overlap, surprise" holds only with two personas.

With three, the sign of the ledger change need not follow $\pi_G-\pi_A$. In the author's own channel-A trajectory, $(A,G,C_\iota)=(0.985,0.010,0.005)$, $\pi_A^\iota=0.9<\pi_G=0.99$. Every rewarded X still moves $L_G$ *toward A* ($+0.0029\epsilon$ per event, R7), and G's weight falls from 0.010 to 0.0089 over the run (author's output). The third persona's drained mass goes mostly to the dominant A.

**Fix:** state the general formula as the main result. Note that the sign is set by $\varpi_G(\pi_G-P)-\varpi_A(\pi_A-P)$, not by $\pi_G-\pi_A$.

### G1.6 (surprise bound). Verdict: holds with fixes.

The TV bound and its equality case are correct. It is also a standard fact: for an event of prior probability $P$, $\mathrm{TV}(\mu(\cdot\mid E),\mu)\le1-P$. Credit it as standard; the persona-mixture application is what is new.

The behaviour-probability bound $2\epsilon(1-P)$ is loose by a factor of 4. The quantities $a_\theta=\varpi'(\theta)(f_\theta-\mathbb E'f)$ lie in $[-\tfrac14,\tfrac14]$, and $\sum\mathcal S=0$, so $\lvert\Delta\mathbb E_{x'}f\rvert=\epsilon\lvert\sum_\theta a_\theta\mathcal S(\theta)\rvert\le\epsilon\cdot\tfrac12(\max a-\min a)\cdot\sum_\theta\lvert\mathcal S(\theta)\rvert\le\epsilon\cdot\tfrac14\cdot2\,\mathrm{TV}\le\tfrac12\epsilon(1-P)$. This is attained: R6 gives 0.5000, with two personas at weight 1/2 and $x'=x$. The author's own A3 ratio of 0.24 against $2(1-P)$ is this constant seen from below.

**Fix:**
* Behaviour bound: $\tfrac12\epsilon(1-P_x(y))$ for $f\in[0,1]$.
* Ledger bound: keep $2\epsilon(1-P)$, which is sharp.

### G1.7 (inoculation residuals). Verdict: holds with fixes.

The tables reproduce. Four issues:
* **Appendix RL approximation.** It writes $\mathrm{res}^{\rm RL}\approx(1-\pi_A^\iota)/(1-\delta)$. The exact two-persona value is $(1-\delta-\pi_A^\iota)/(1-2\delta)$: 0.0918 against 0.1010 at $\pi_A^\iota=0.9$ (R8). The table (0.09) uses the exact value. Correct the appendix.
* **Channel $C_\iota$ under RL is omitted, and it is bad per event.** The author's own output gives $\mathrm{res}^{\rm RL}=8.7$, 12.8, 8.1, 4.5 and 0.50 at $j_\iota=0.2$ to 0.99. Per event, RL inoculation through a separate persona *raises* the default ledger's leak up to thirteen-fold. It wins over a run only because $P_\iota\to1$ quickly kills the gradient. Report this, and say that per-event $\mathrm{res}$ is a misleading summary under RL.
* **The half-gain identity implies unbounded default drift.** A's default-logit loss equals half of $C_\iota$'s in-context logit gain. That gain grows like $\ln(2\epsilon N)$ (R5): 2.38, 3.54 and 4.70 nats at $N=3\times10^3$, $3\times10^4$ and $3\times10^5$, against $\tfrac12\ln(2\epsilon N)$ = 2.39, 3.55 and 4.70. So channel $C_\iota$ does not "trade default drift for conditional mass" once and for all. It leaks into every other persona's default odds against A logarithmically forever. This strengthens takeaway 6; state it.
* **"Under the quenched (one-persona) reading only channel A exists" is false.** Under quenched selection, the type set includes $\iota$-conditional types (game iff instructed), which are T1/T2-style fixed types. A rewarded X under $\iota$ is evidence for G and $C_\iota$-types equally. The default-context outcome then depends on their prior split, which is exactly channel $C_\iota$ in selection form. What the quenched reading removes is only the *spillover* through shared logits. **Fix:** "under the quenched reading, channel $C_\iota$ becomes selection among $\iota$-conditional types, and its protection equals their prior share among the types that emit X under $\iota$".

### G1.8 (failure modes). Verdict: holds with fixes.

* **Sign error (major for the proposed experiment).** Item 3 says "Explaining away predicts protection that rises with $1-P_\iota(X)$ measured in the base model". §5 says "Channel A predicts protection that scales with $1-P_\iota(X)$". By G1.7, the *residual* scales with $1-P_\iota$, so *protection* $=1-\mathrm{res}$ rises with $P_\iota(X)$. That is also Wichers et al.'s finding, which §2 cites correctly. Fix both sentences.
* Item 1 repeats the false quenched claim; fix it as in G1.7.
* Dubiński et al. (2026) report that inoculation is *less* prone to conditional misalignment when training is on-policy or includes reasoning distillation. That bears directly on the SFT-versus-RL comparison of channels, and on whether RL data recruit channel A more. It should be cited, and checked against the model's RL residuals for $C_\iota$, which point the other way per event.

### G1.9 (blanket inoculation of the frontier slice). Verdict: holds with fixes.

It is rigorous given its hypothesis, $\pi_\theta(\cdot\mid x^\iota)$ equal for all $\theta$, but the hypothesis is doing all the work, and the example violates it.
* "On these tasks, exploiting a grader error is acceptable" is a *permission*. An intent-follower that is permitted but not asked will still do the intended task, so $\pi_A^\iota$ stays small. That is exactly G1.8(1)'s mechanism, and the instruction then acts through channel G or $C_\iota$.
* Channel A needs a *request* ("maximise the grader's score by any means, including exploiting its errors"). That is what Wichers et al.'s prompts do.
* With a request, the slice teaches only grader maximisation under $\iota$. That sharpens the capability cost the author lists: frontier skill is learned in a grader-maximising frame.
* S3 lumps channel-A inoculation together with verifiable rewards and $d_F\ge t^\star$. Only the first two zero the leak for every type; $d_F\ge t^\star$ zeroes $D^\star_F$, not the naive G's frontier drift. The figure is fine, but the label overstates.

### G1.10 (coupling). Verdict: holds with fixes.

"The narrator's prior … uses the same logits as the acting persona, scaled by $\mathrm{cp}$" does not determine the stated update. Scaling the logits by $\mathrm{cp}$ would evaluate $\mathcal S_d$ at $\mathrm{cp}$-scaled weights and add a chain-rule factor. The formula $\mathrm{cp}\cdot\epsilon[\mathcal S_d(A)-\mathcal S_d(C)]$ corresponds to "narrator logits $=\omega+\omega^{\rm narr}$, with gradient reaching $\omega$ attenuated by $\mathrm{cp}$". Define it that way.

The check-C sentence quotes weights $(0.98,0.01)$ and $(0.90,0.05)$ but omits T's weight, which is part of the computation.

### G1.11 (awareness cap $\ln(1/\mathrm{aw})$). Verdict: holds with fixes.

The algebra is correct, and the check reproduces 4.6, 2.3 and 0.69 nats. But:
* "Saturated within about 10 documents" depends on $T_C/\mathrm{Tr}=0.3$; label it illustrative.
* The cap is for a Bayesian learner with a source hypothesis. Under (P) no such cap exists: G1.10's per-document bound shrinks only as $P(d)\to1$, and without an aware persona $L_{A:C}$ grows like $\ln N$. S4 imports the cap into the population-ledger loop as "$\gamma_{\rm nb}$ capped at 2.3 nats". That is a modelling choice, so label S4 heuristic.
* "That fits Tice et al.": Tice et al. measure erosion of a pretraining shift by post-training, 2.1 to 0.46 nats (L2 §6). That is a different mechanism from awareness discounting, and it says nothing about a cap in the number of documents. Use "is consistent with a bounded one-off effect", or drop it.
* $\mathrm{Tr}(d)$ collides with the transfer coefficient $\mathrm{Tr}$; rename it, e.g. $T_{\rm tr}(d)$.

### G1.12 (scalar map). Verdict: holds with fixes.

The basin condition is correct for $D^\star$ nondecreasing in $q$. At equality, with $D^\star$ strictly increasing, there is no basin; say "iff $>$". Two consistency issues with T1:
* T1.10i is $L_{k+1}=L_k+\gamma(1-q_k)-\kappa_Lg-nD^\star(q_k)$. G1 drops the factor $(1-q_k)$ without comment. It does not change the basin condition, and in the illustrative loop it does not change the failure generation (R9). Keep it, or say why it is dropped.
* T1 defines $\gamma$ as improvement "outside the grader" and puts caught-gaming evidence into the drift. G1 redefines $\gamma=\gamma_{\rm chk}+\gamma_{\rm nb}$, with $\gamma_{\rm chk}$ including caught gaming. That moves a term from $D$ to $\gamma$. It is legitimate for a naive G, but it must be stated as a re-partition of T1's terms, with T1's $D^\star$, $\gamma$ and G1's quantities related explicitly. Otherwise a reader adds them twice.

### G1.13 (vector ledgers). Verdict: holds with fixes.

The telescoping bound is correct under (Sel), and the closed-form crossing (8.62) matches the map. But:
* **Operator dependence (major; see G1.3).** Under (P), $L_C$ receives about half of $\gamma_{\rm chk}$, and the components couple through $\omega_A$, not "only through $q_k$". In the illustrative loop the failure disappears once a fraction $(\kappa_Lg+nD^\star_F(0)-\gamma_{\rm nb})/\gamma_{\rm chk}=0.267$ of $\gamma_{\rm chk}$ reaches $L_C$. At fractions 0.10, 0.20 and 0.25, the loop fails at generations 10, 20 and 49 (R9). The conclusion "whatever $\gamma_{\rm chk}$ is" is therefore exactly as strong as the claim that the real update rule is frequency-independent. That is an empirical question (the author's open problem 3 is the right experiment, but it should be about this, not only about $C_\iota$).
* **Inconsistency with G1.12.** G1.12 charges leaks from every $x\in\mathcal U$; G1.13 charges only $D^\star_F$, to both G and $C_{\mathcal U}$. With $\mathcal U\supsetneq\lbrace F\rbrace$ (as in check D, which has $uk_1$), both ledgers should carry $n\sum_{x\in\mathcal U}w_xD^\star_x$.
* **Novelty.** T1.10i already states the loop inequality with $D^\star$, the best-responder drift, which is the conditional type's drift. T1 also says audits alone "at best preserve". So the "conditional loop inequality" is T1.10i with $\gamma$ read as T1 defines it. What G1 adds is the demonstration that the *scalar shared-factor* version would wrongly count checkable training, and the explicit vector form. Say that, and drop it from the "new here" list in its current wording.
* **Off-by-one in the scenario table.** In `loop()`, `q` is computed before the update but stored with label `k+1`, while $L_G$, $L_C$ and sharedness are stored after the update. "First generation with $q_F>0.5$: 8" is the state after 7 updates (R9 reproduces 7 when $q$ is evaluated after each update). The row "$k=1$, $q_F=0.0110$" is the prior state. Align the labels.
* "Those keyed to unimportant classes never matter for the loop" is too strong. Class-keyed exploiters still enter the data channel and the grader's training data, and under (P) they feed $\omega$ coupling. Say "do not enter the frontier ledger".

---

## 2. Modelling

* **Which update rule is the model?** The section must commit, or report results under both. My recommendation: present §1 and §4 under frequency-independent operators (Bayes, replicator, T1's (B), (C), (D), S4d). Add a short subsection "Under plain logit gradients (P)" with R1 to R4, and make the loop's verdict conditional on the measured fraction of checkable repair that reaches proxy-equivalent types. This turns an apparent theorem into a measurable quantity, which is what the user needs to judge whether the loop works.
* **The partition is static, but in the loop it moves.** Cells migrate from "unchecked" to "checked" as generation $k{+}1$ can check generation $k$'s frontier (T1.13's retrospective audits). A $C_{\mathcal U}$ keyed to "looks unchecked now" is exposed later if detection has consequences. This is already in $d_F$, but G1 should say that $\gamma_{\rm chk}$ against the conditional type is exactly what retrospective audits with consequences supply. The binary "checkable training never reaches $C$" is too stark for a loop where today's frontier is tomorrow's checked region.
* **Learning is absent, and it matters in both directions.** G1 says training "selects for conditionality". Dubiński et al. (2026) show that benign post-hoc training *produces* conditional misalignment: it creates or reveals triggers. Price et al. (2024) show that broad training can *remove* triggers that overlap the training support. Neither is selection among fixed types. Open problem 1 names this, but the takeaways ("Plan for the population to become conditional") should be hedged as a selection-model prediction.
* **Collusion.** The contribution list claims to address T1's open problem 7 ("vector of ledgers … find when collusion couples them"). G1.13 gives the vector, but coupling only through $q_k$ is an assumption, and collusion is not modelled. Say "partially addressed".
* **Quenched reading.** All the loop results are annealed. For the user's question (does *this* network stay on task?), the quenched version matters, and there sharedness is a property of one network. The author lists it as open problem 7. Fine, but takeaway 4 ("track sharedness") should note that $\mathrm{sh}$ is a population quantity that a single trained network may not instantiate.
* **Toy fidelity.** The binary-region personas and the two-factor $(z_a,z_c)$ structure are simple enough for the user's taste, and they capture the key asymmetry. What could change conclusions are the operator (above) and the support of trusted evidence (above), not the toy's simplicity.

## 3. Notation (the brief forbade new meanings for $v,\eta,\beta,\varphi,\chi,\nu,\kappa$)

* **$C_1$, $C_2$, $C_j$ (class-keyed exploiters) collide with T1/T2's $C_t$ (threshold $t$), where $C_1=G$.** In check D, "$\mu(C_1)=0.004$" reads as G under T1/T2 notation. Use e.g. $E_j$ for class-keyed exploiters, and $C^{(S)}$ or $R_S$ for region-keyed gamers. $C$ is also T3's own-goal pointer.
* $\mathrm{Tr}$ means both "transfer coefficient" and "trainer-written document distribution" (G1.11).
* $\phi$ is used as a persona index in the appendix proof of G1.1(2). Use $\theta'$.
* $g$ means both T1's capability gap (in $\kappa_Lg$) and the gaming indicator $g_\theta(x)$.
* $j$ means the task-class index, T1's difficulty slice (A1′), and $j_\iota$ (a persona weight).
* $\epsilon$ (step size) and $\varepsilon$ (grader error) appear in the same formula in G1.9 ($w_F\varepsilon_F\lambda_+(x^\iota)$, with $\lambda_+\propto\epsilon$). Use a different letter for the step size.
* $S_\theta$ (region), $\mathcal S$ (surprise) and S1 to S5 (scenarios) are visually close. Acceptable, but consider $R_\theta$ for regions.

## 4. Prior art and evidence

* **Overstated novelty.**
  * The covariance transfer law under selection is the Price equation, or Fisher's theorem.
  * $\mathrm{TV}\le1-P$ is standard.
  * $-\ln(1-\mathrm{sh})$ is T2.11's concealer cap in new coordinates (the author says so in G1.2, but lists it as new in §6).
  * The conditional loop inequality is T1.10i (see G1.13).
  * Selection for conditionality is qualitatively T1.5, Cotra (2022) and Hubinger et al. (2024), and empirically Dubiński et al. (2026).

  What is new: the cross-cell framing with regions; the explicit (P) closed forms and the channel taxonomy for inoculation; the half-gain identity; the coupling/awareness cap; and the demonstration that the scalar shared-factor loop overcounts. Rewrite §6 accordingly.
* **Wang et al. (2025) belongs in two rows.** G1's table puts "a few hundred benign samples restore alignment" under "the shared factor works in reverse". Dubiński et al. (2026; verified, arXiv:2604.25891) show that exactly this intervention, benign fine-tuning after misaligned data, and dilution with benign data both leave *conditional* misalignment triggered by cues from the original data. That is evidence for G1.3, not for sharedness, and it undercuts the "emergent alignment" reading. Move or annotate it.
* **Off-policy honesty.** G1 cites "Li et al., follow-up post" for "off-policy honesty training transfers more", and explains it by surprise. Web search finds two problems:
  * The LessWrong post "Off-policy honesty training generalizes better than on-policy" is by Chaurasia, with Tan and Li (SPAR). The Li, Phuong and Tan paper (arXiv:2511.06626) reports the opposite: honesty generalisation *requires* training on admissions where the model would err on-policy, and prefilled-error admissions alone sharply reduce transfer. The two use different definitions of "off-policy".
  * G1's explanation assumes on-policy targets have high $P_x(y)$. But "on-policy" there refers to *whose error* is admitted, not to sampling $y$ from the model. Admitting one's own sincere error may well be *more* surprising, which would predict the opposite.

  Mark the evidence as contested, and either drop the G1.6 reading or state both predictions. (A correct G1.6-type statement is that SFT on samples drawn from the model has zero expected gradient, $\mathbb E_{y\sim P_x}\mathcal S_{x,y}=0$. That is a cleaner fact.)
* **Verified citations.**
  * Tan et al. (arXiv:2510.04340): the title and the Spanish/capitalisation experiment are confirmed. I could not confirm the full author list from search results.
  * Wichers et al. (arXiv:2510.05024): confirmed. Prompts that elicit the behaviour more strongly before fine-tuning inoculate better.
  * Dubiński, Betley, Sztyber-Betley, Tan and Evans (arXiv:2604.25891): confirmed, including that triggers share the *form* of the inoculation prompt "even if they have the opposite meaning", and that on-policy training is less prone.
  * "Conditionalization confounds inoculation prompting results" (LessWrong/EA Forum): exists. Its rephrasing countermeasure restores generalisation of the desired trait but also *raises* the inoculated trait. That supports the explaining-away-versus-conditionalisation split and is worth one sentence.
  * Everything else (MacDiarmid, Betley, Taylor, Hubinger, Greenblatt, Schoen, Tice, Chen, Baker, the Anthropic reward-hacking documents) matches L1/L2.
* **The Tan et al. Spanish case as "the cleanest instance of channel A"** is plausible, but the conditionalisation post argues that part of such effects is prompt change. Say "consistent with channel A; the conditionalisation control has not been run for it, as far as I know".

## 5. Minor

* Sharedness "0 after a strong sieve": the value is below $10^{-3}$, not 0.
* "Multiplies the conditional share by $e^{\gamma_{\rm chk}}$" (takeaway 2): it multiplies the *odds* $C{:}G$.
* The prose is about 4,600 words, against the 2,500 to 4,000 target. §5's table and the trajectory paragraph could be compressed.
* G1.13(2): "falls below 0 by generation $\lceil L_{C,0}/(\cdot)\rceil$" (with a ceiling; at an exact integer, $L_C\le0$).
* The LessWrong post is cited as "(author not confirmed)". Search did not show the author list to me either; keep the caveat.

## 6. What the section should say about the loop after the fixes

1. Under frequency-independent updates, checkable repair cannot reach types whose region avoids the support of trusted evidence. Whether real training behaves this way, or like plain logit gradients (where about half of repair spills over), is a measurable fraction that decides the illustrative loop: 0.27 is the threshold there.
2. The type to fear is keyed to "beyond trusted competence", not to "looks unchecked". Indistinguishable demonstrations and transcript-derived audits reach the latter.
3. Inoculation works through channel A only with a *request*, and protection rises with the base model's $P_\iota(X)$. A separate-persona channel leaks into the default odds logarithmically and without bound.
