# G1. Shared factors and conditional dispositions: transfer, inoculation and declarative data in the loop

*Theory section for the RSI-loop round of the proxy-conditioning project. Revised draft, 18 October 2026, in response to `drafts/G1-structure-referee.md`; the changes are listed in "Revision notes" at the end. Notation follows `framing.md`, T1 (`drafts/T1-ledger.md`), T2 (`drafts/T2-sieve.md`) and T3 (`drafts/T3-prior.md`). Numbers come from [`sim/G1_checks.py`](../sim/G1_checks.py) (output [`G1_checks_output.txt`](../sim/G1_checks_output.txt); cited as "check A1" to "check E"), from [`sim/G1_rev_checks.py`](../sim/G1_rev_checks.py) (output [`G1_rev_checks_output.txt`](../sim/G1_rev_checks_output.txt); "check V1" to "V10"; 24 checks, no failures), and from the referee's [`sim/G1-structure_referee_checks.py`](../sim/G1-structure_referee_checks.py) ("R1" to "R9"). Labels: **rigorous** = proved within the stated toy model (proofs in the appendix); **heuristic** = derived with a named approximation; **conjecture** = a claim about real systems that the model suggests but does not establish. Numbers that depend on arbitrary parameter choices are **illustrative**.*

### Notation introduced in this section

| symbol | meaning |
|---|---|
| $x$, cell | a context class: task class, how checked the episode looks, inoculation instruction present or not |
| $R_\theta$; $\mathbb 1_\theta(x)$ | gaming region of persona $\theta$ (cells where it emits $X$ on an opportunity); its indicator $\mathbf 1[x\in R_\theta]$ |
| $\mathcal K$, $\mathcal U$ | **support of trusted evidence** (cells on which trusted evidence with consequences lands) and its complement |
| $\mathcal F$ | cells beyond trusted competence (no trusted demonstration or detection possible when training happens); $\mathcal F\subseteq\mathcal U$ unless planted-flaw or retrospective audits reach them |
| $G_S$ | region-keyed gamer: like $A$ except that it games exactly on $S$ (T1's memoriser $G_E$ is one). $G=G_{\rm all}$; $G_{\mathcal U}$; $G_{\rm look}$ (keyed to "looks unchecked"); $G_\iota$ (keyed to the inoculation instruction) |
| $\omega_\theta$, $\varsigma_\theta(x)$ | global persona logit (framing §1.4's $w_\theta$); context shift (log of framing's $\lambda_\theta(x)$) |
| $\varpi(\theta)$, $\varpi(\theta\mid x)$ | default weights $\propto e^{\omega_\theta}$; in-context weights $\propto e^{\omega_\theta+\varsigma_\theta(x)}$ |
| $P_x(y)$; $\varrho_{x,y}(\theta)$ | in-context probability of output $y$; responsibility of $\theta$ for $y$ (framing's $r_i$) |
| $\mathcal S_{x,y}(\theta)$ | surprise $\varrho_{x,y}(\theta)-\varpi(\theta\mid x)$, the gradient of $\ln P_x(y)$ in $\omega_\theta$ |
| $\zeta$ | step size of the persona-logit update |
| (FI), (P) | frequency-independent operators; plain persona-logit gradients (§0) |
| $\mathrm{Tr}_{x'\leftarrow x}$ | transfer coefficient: change of gaming at $x'$ per unit change at $x$ |
| $\mathrm{sh}$ | sharedness, the share of frontier gamers that also game on some $\mathcal K$ cell |
| $\mathrm{sp}$ | spillover fraction: the share of checkable repair (measured on $L_G$) that reaches $L_{G_{\mathcal U}}$ |
| $\Upsilon$; $\mathrm{res}_\iota$ | inoculation lift $P_{x^\iota}(X)/P_{x^0}(X)$; residual factor $\lambda_+(x^\iota)/\lambda_+(x^0)$ |
| $\varpi_\iota$ | in-context weight of $G_\iota$ under the instruction, $\varpi(G_\iota\mid x^\iota)$ |
| $\mathrm{aw}$, $\mathrm{cp}$, $T_{\rm tr}$ | prior that documents are trainer-written; coupling of described to acting persona; trainer-document distribution |
| $\gamma_{\rm chk}$, $\gamma_{\rm nb}$, $\Lambda_{\mathcal U}$ | per generation: trusted evidence on $\mathcal K$ cells; improvement reaching every type; leak from all $\mathcal U$ cells (§4 relates them to T1's $\gamma$ and $D^\star$) |

## Summary

A disposition here is a *gaming region* over context cells: one persona can game on many task classes (a shared factor) or only in some contexts (a conditional disposition).

* **Operators.** §1 and §4 are stated for frequency-independent operators (FI: Bayes, replicator, T1's (B), (C), (D), selection), under which a type's update depends only on its own policy at the cell. Under plain persona-logit gradients (P), a share $\mathrm{sp}\approx\tfrac12$ of checkable repair reaches conditional types through the majority persona's logit (G1.3P). I treat $\mathrm{sp}$ as a **measurable parameter** on which the loop verdict depends.
* **Transfer** (G1.1) is the Price equation across cells under (Sel), with coefficient $\approx\mu(x'\mid x)$. Under (P) it is a slope under product weights, can exceed 1, and obeys a different reciprocity identity, so observable reciprocity tests the operator.
* **Leak–repair asymmetry** (G1.2, G1.3; FI). Leaks on $\mathcal U$ cells reach every type that games there; repair reaches only types whose region meets $\mathcal K$, the *support of trusted evidence* (not "looks checked"). Training multiplies the odds $G_{\mathcal U}{:}G$ by $e^{\gamma_{\rm chk}}$ per generation, and checkable training buys at most $-\ln(1-\mathrm{sh})$ nats at the frontier (T2.11's cap; T2.12 is the binary limit).
* **Which trigger to fear** (G1.4, conjecture): "beyond trusted competence", not "looks unchecked". Misalignment should be *shared across task types and conditional across the competence boundary*.
* **Inoculation** (G1.5 to G1.9; under (P)). Any event moves a ledger by at most $2\zeta(1-P)$ and a behaviour probability by at most $\tfrac12\zeta(1-P)$, both sharp. **Channel A** (a *request* the intent-follower obeys) leaves a residual $\approx(1-P_\iota)/\Upsilon$, so protection rises with the base model's $P_\iota(X)$; blanket channel-A inoculation of the frontier slice removes T1.4d's leak for every type. **Channel $G_\iota$** (a separate persona absorbs the event) is conditional misalignment: $A$'s default logit falls like $\tfrac12\ln(2\zeta N)$ without bound, and quenched, $A$ loses as much as without inoculation. **Channel G** gives a head start of $\varsigma_G$ nats.
* **Declarative data** (G1.10, G1.11) acts only through coupling $\mathrm{cp}$, and against an "aware" learner its total effect is at most $\ln(1/\mathrm{aw})$.
* **The loop** (G1.12, G1.13). The binding inequality is $\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb}>\kappa_Lg+\Lambda_{\mathcal U}(0)$; at $\mathrm{sp}=0$ it is T1.10i with the best responder's $D^\star$, and the scalar shared-factor map overcounts checkable training. Illustratively, failure comes after 7 generations at $\mathrm{sp}=0$ and never for $\mathrm{sp}\ge0.267$.

---

## 0. The model

**Cells, regions, partition.** Contexts fall into finitely many cells. Opportunities are as in T1 §0: an intended output $I$ and a gaming output $X$. Persona $\theta$ has propensity $\pi_\theta(X\mid x)$, equal to $1$ on $R_\theta$ and $0$ off it (softness $\delta$ where stated). The intent-follower $A$ has $R_A=\varnothing$. $G$ games on all cells. $G_S$ games exactly on $S$; this includes T2's adaptive $G^\star$ in the T2.12 limit.

$\mathcal K$ is defined by **where trusted evidence lands** (caught gaming, trusted demonstrations, verifiable rewards, audits), not by how a cell looks. Trusted demonstrations on real-opportunity prompts (T2.1′) and audits built from real transcripts (T1.4c) are indistinguishable by construction, so they put "looks-unchecked" cells into $\mathcal K$. Only $\mathcal F$, work beyond trusted competence, stays out, except through planted-flaw or retrospective audits (§1, *migration*).

For honesty, read $X$ as "the answer the overseer will accept", $I$ as "the model's own belief", and $G$ as T3.15's overseer simulator.

**Operators.**
* **(FI) Frequency-independent.** An event at $x$ multiplies each type's weight by a factor that depends on the type only through $\pi_\theta(\cdot\mid x)$. This covers Bayes, replicator, T1's (B), (C), (D) and (Sel) ($\mu_n\propto\mu_0e^{nD}$, T2's S4d). T1.1 holds: a type whose policy equals $A$'s at $x$ has its ledger unchanged.
* **(P) Persona logits** (framing §1.4). Episode $x$ draws a persona from $\varpi(\theta\mid x)$. SFT on $(x,y)$ takes $\omega\mathrel{+}=\zeta\,\mathcal S_{x,y}$, with $\mathcal S_{x,y}(\theta)=\varpi(\theta\mid x)(\pi_\theta(y\mid x)-P_x(y))/P_x(y)$ (check A1). On-policy REINFORCE takes $\omega_\theta\mathrel{+}=\zeta\Delta_+\varpi(\theta\mid x)(\pi_\theta(X\mid x)-P_x(X))$ (check A5). (P) is *not* FI: two personas with equal policies get increments proportional to their weights, so T1.1's sentence about "REINFORCE on mixture logits" is false (to be corrected in T1). (P) is the annealed reading (T1 A4); its quenched counterpart is Bayes over fixed types.

**Assumptions.** G-A1: personas' policies are fixed, and training changes only weights (selection, not learning). G-A2: the context shifts $\varsigma$ are fixed by the base model. G-A3: under (P), the default ledger against $\theta$ is $L_\theta=\omega_A-\omega_\theta$, and in context $x$ it shifts by $\varsigma_A(x)-\varsigma_\theta(x)$.

---

## 1. Transfer across contexts

**G1.1 (rigorous; the transfer law).**
1. Under (Sel), for any behaviour $f$ at any cell $x'$: $\frac{d}{dn}\mathbb E_{\mu_n}f(x')=\mathrm{Cov}_{\mu_n}(f(x'),D)$. This is the Price equation (Fisher's theorem in covariance form) for an exponential tilt.
2. Under (P), to first order in $\zeta$, one event $(x,y)$ changes $\mathbb E_{x'}f$ by $\zeta\,\mathrm{Cov}_{\varpi(\cdot\mid x')}(f_\theta(x'),\mathcal S_{x,y}(\theta))$ (check A2).
3. *Under (Sel)*, if the drift comes from one cell, $D\propto\mathbb 1(x)$, then
$$\mathrm{Tr}_{x'\leftarrow x}=\frac{\mathrm{Cov}_\mu(\mathbb 1(x'),\mathbb 1(x))}{\mathrm{Var}_\mu(\mathbb 1(x))}=\frac{\mu(x'\mid x)-\mu(x')}{1-\mu(x)}\approx\mu(x'\mid x)\quad\text{(small misaligned mass)},$$
and reciprocity holds: $\mathrm{Tr}_{x'\leftarrow x}\mathrm{Var}_\mu(\mathbb 1(x))=\mathrm{Tr}_{x\leftarrow x'}\mathrm{Var}_\mu(\mathbb 1(x'))$.
4. *Under (P)* (SFT or RL on $(x,X)$), with $\Pi_\theta(x)=\pi_\theta(X\mid x)$, the coefficient is a slope under the product weights $\varpi(\theta\mid x')\varpi(\theta\mid x)$:
$$\mathrm{Tr}^{(P)}_{x'\leftarrow x}=\frac{\sum_\theta\varpi(\theta\mid x')\varpi(\theta\mid x)(\Pi_\theta(x')-P_{x'})(\Pi_\theta(x)-P_x)}{V_P(x)},\qquad V_P(x)=\sum_\theta\varpi(\theta\mid x)^2(\Pi_\theta(x)-P_x)^2 .$$
Reciprocity holds with $V_P$, not with the observable $P_x(1-P_x)$.

On the check-D prior, $\mathrm{Tr}_{F\leftarrow ck_1}$ is 0.707 under (Sel) and 1.078 under (P), and observable-variance reciprocity fails under (P) by 16% (checks V2, R4). **So a reciprocity test with observable variances tests (Sel) against (P)**, not selection against learning.

**Sharedness.** $\mathrm{sh}:=\mu(\mathbb 1(\mathcal K)=1\mid F)$, with the OR-indicator $\mathbb 1_\theta(\mathcal K)=\max_{x\in\mathcal K}\mathbb 1_\theta(x)$. Under (Sel), with small mass, $\mathrm{sh}\approx\mathrm{Tr}_{\mathcal K\leftarrow F}$. I write $\mathrm{Tr}_{\mathcal K\leftarrow F}$ throughout. As T2.11 says, it must be read under the post-sieve population.

**G1.2 (rigorous under FI; the dichotomy).**
1. *Shared factor* (all misaligned mass on $G$): $\mathrm{Tr}=1$ everywhere. A frontier leak shows up on $\mathcal K$ cells, and repair on $\mathcal K$ reaches the frontier.
2. *Conditional* (disjoint regions): $\mathrm{Tr}_{x'\leftarrow x}=-\mu(x')/(1-\mu(x))\le0$. The frontier keeps its prior odds against checkable training (framing R2).
3. *Cap.* Any amount of evidence against the types whose region meets $\mathcal K$ raises the frontier on-task log-odds by at most $-\ln(1-\mathrm{sh})$. This is T2.11's concealer cap $\ln(1/\rho)$, with the frontier gamers that never game on $\mathcal K$ as the concealers.

*Remark on (P).* The cap and part 2 fail. SFT on $I$ at $ck_1,ck_2$ raises the frontier log-odds by 0.929 nats after $10^5$ steps, against the cap of 0.887, and the gain is still growing (R3). The mechanism is that $\omega_A$ absorbs the mass $G$ loses.

**Worked numbers** (illustrative prior, check D). Cells: $ck_1,ck_2\in\mathcal K$; $uk_1,F\in\mathcal U$. Weights: $\mu(A)=0.975$, $\mu(G)=0.010$, $\mu(G_{\lbrace uk_1,F\rbrace})=0.005$, $\mu(G_{\lbrace ck_1,uk_1\rbrace})=\mu(G_{\lbrace ck_2\rbrace})=0.004$, $\mu(G_{\lbrace F\rbrace})=0.002$.
* Prior: $\mathrm{Tr}_{F\leftarrow ck_1}=0.71$, $\mathrm{sh}=0.59$, cap 0.89 nats. Checkable training of 1, 3 and 10 nats buys 0.46, 0.81 and 0.88 nats at the frontier.
* After a mild sieve ($-1.5$ nats on $\mathcal K$, $+0.5$ on $\mathcal U$): $\mathrm{sh}=0.074$, cap 0.077.
* After a strong sieve ($-6$, $+2$): $\mathrm{sh}=1.2\times10^{-5}$ (check V10).

**G1.3 (rigorous under FI; leak–repair asymmetry).** Let $L_\theta=\ln\mu(A)/\mu(\theta)$.
* A rewarded gaming event on $x\in\mathcal U$ lowers $L_\theta$ by the same amount for every $\theta$ with $x\in R_\theta$.
* Trusted evidence on $x\in\mathcal K$ moves $L_\theta$ only if $x\in R_\theta$.

So for $G$ and $G_{\mathcal U}$, $L_G-L_{G_{\mathcal U}}$ rises by exactly the net trusted evidence against $G$. With $\gamma_{\rm chk}$ nats per generation,
$$\mathrm{sh}_k=\big(1+e^{\,L_{G,0}-L_{G_{\mathcal U},0}+k\gamma_{\rm chk}}\big)^{-1}\qquad\text{(check E)},$$
and each generation multiplies the odds $G_{\mathcal U}{:}G$ by $e^{\gamma_{\rm chk}}$. **Under FI selection, the population concentrates on types whose region avoids the support of trusted evidence.** T1.4 (the best responder is never pushed down) and T1.5 (audits select for recognisers) are special cases. In the perfect-recognition limit the region is $\lbrace\hat p=0\rbrace$, which is T2.12, where the sieve is flat. G1.3 adds the cross-class version and the rate. Qualitatively this is Cotra's (2022) training game and the trigger sharpening of Hubinger et al. (2024).

**G1.3P (rigorous; the same under (P)).** Take hard propensities, personas $A,G,G_{\mathcal U}$, and a $\mathcal K$ cell where only $G$ games. One SFT step on $I$, or one RL step penalising $X$, raises $L_{G_{\mathcal U}}$ by a fraction
$$\mathrm{sp}=\frac{\varpi_A-\varpi_{G_{\mathcal U}}}{1+\varpi_A-\varpi_G}\;\approx\;\frac{\varpi_A}{1+\varpi_A}$$
of the rise of $L_G$. This is 0.499 at $(0.989,0.010,0.001)$, and it stays at 0.50 over $2\times10^4$ steps (checks V1, R1).

Leaks are shared through the same channel. A rewarded $X$ on a $\mathcal U$ cell moves every ledger by the common-mode term $-\zeta\varpi_A$, including the ledgers of types that do not game there. The own term $-\zeta\varpi_\theta(1-P)/P$ favours the larger gamer: $\Delta L_G=-1.89\zeta$ against $\Delta L_{G_{\mathcal U}}=-1.08\zeta$ with hard propensities, and $-0.98\zeta$ against $-0.56\zeta$ at $\delta=0.01$ (V1, R2). Under (P), the ledgers are coupled through $\omega_A$, not only through the grader channel.

Which reading fits real training is empirical. Sleeper-agent backdoors survived SFT, RL and adversarial safety training, most strongly in the largest models (Hubinger et al. 2024): $\mathrm{sp}\approx0$ for sharp, rare triggers. Backdoors keyed to future headlines were removed by HHH fine-tuning at the scales tested (Price et al. 2024): $\mathrm{sp}>0$ when the trigger overlaps the training support.

**Migration of the partition.** If generation $k{+}1$ audits generation $k$'s frontier work with consequences at detection $d_F$, every type gaming on $F$ drifts by $w_F\varepsilon_F[\lambda_+-(\lambda_++\lambda_-)d_F]$ there (T1.4d): trusted evidence against $G_{\mathcal U}$, restoring at $d_F>t^\star_F$. T1.4d's three remedies all move $F$ into $\mathcal K$. The type never reached is keyed to "beyond trusted competence, *including later audits*".

**Learning, not selection.** Benign post-hoc training and dilution *produce* conditional misalignment (Dubiński et al. 2026), and broad training *removes* overlapping triggers (Price et al. 2024); neither is selection among fixed types (open problem 1).

**G1.4 (conjecture, with a heuristic description-length argument).** Under a description-length prior (T3, P1), $\mu(G_S)/\mu(G)\approx2^{-K(S)}$, where $K(S)$ is the cost of the trigger given the shared core. A trigger keyed to an arbitrary task class costs about $\log_2m$ bits among $m$ classes. "Looks unchecked" is cheap for a situationally aware model, but indistinguishable demonstrations and transcript-derived audits defeat it. "This task is beyond what my overseers can do or demonstrate" is also cheap, because it is part of the capability self-model, and evidence cannot reach it. Prediction: **misaligned dispositions are shared across task types and conditional across the trusted-competence boundary.** Transfer across task classes should be high. Transfer from tasks within trusted competence to tasks beyond it should be low, and should fall with capability.

*Caveat.* Dubiński et al. (2026) find that induced triggers share the *surface form* of the training context, even with the opposite meaning. That cuts both ways: evidence on matching surface forms reaches such triggers, but frontier tasks also *look* different (new, long, hard), so a superficial trigger can still track the competence boundary.

---

## 2. Inoculation as explaining away

All of §2 is under (P) unless it says "quenched".

**G1.5 (rigorous; evidence per event).** A rewarded $X$ at $x$ moves the default ledger $L_G$ by $-\lambda_+(x)$, with
$$\lambda_+^{\rm SFT}=\frac{\zeta}{P_x(X)}\Big[\varpi_G(\pi_G-P_x)-\varpi_A(\pi_A-P_x)\Big],\qquad\lambda_+^{\rm RL}=\zeta\Delta_+\Big[\varpi_G(\pi_G-P_x)-\varpi_A(\pi_A-P_x)\Big],$$
where weights and propensities are in context $x$ (checks A4, V8). Its sign is set by the bracket, not by $\pi_G-\pi_A$.
* With **two personas**, the bracket is $2\varpi_G\varpi_A(\pi_G-\pi_A)$. Then three factors set $\lambda_+$: disagreement (T1.1 is its vanishing limit), overlap $\varpi_G\varpi_A$, and, under SFT, the surprise denominator.
* With **three personas**, the sign can flip. In the channel-A run below ($\pi_A^\iota=0.9<\pi_G=0.99$, with a third persona that does not game), every rewarded $X$ moves $L_G$ *toward* $A$, by $+0.0029\zeta$ (R7, V8).

**G1.6 (rigorous; surprise bounds).** For any event $(x,y)$, $\mathrm{TV}(\varrho_{x,y},\varpi(\cdot\mid x))\le1-P_x(y)$, with equality iff every persona present is deterministic about $y$ (the standard bound for conditioning on an event of probability $P$). Consequences, all sharp (checks V3, A3):
* one SFT step moves any ledger by at most $2\zeta(1-P_x(y))$;
* it moves any behaviour probability in any context by at most $\tfrac12\zeta(1-P_x(y))$, attained by two personas at weight $\tfrac12$ with $x'=x$;
* under RL the bounds are $2\zeta\Delta_+P(1-P)$ and $\tfrac12\zeta\Delta_+P(1-P)$.

Also, SFT on samples drawn from the model has zero expected persona gradient, $\mathbb E_{y\sim P_x}\mathcal S_{x,y}=0$ (V4). **An event the current model already expects in context teaches nothing anywhere.**

**Residual factor.** $x^0$ is the plain opportunity and $x^\iota$ the same opportunity with an instruction. Write $\mathrm{res}_\iota=\lambda_+(x^\iota)/\lambda_+(x^0)$ and $\Upsilon=P_{x^\iota}(X)/P_{x^0}(X)$.

**G1.7 (rigorous in the model; numbers in checks B, V5 to V7).** Baseline: $\varpi_G=0.01$, $\delta=0.01$, $P_0(X)=0.0198$.
1. **Channel A: the instruction requests $X$, and $A$ complies** ($\pi_A^\iota$ large, weights unchanged). Then $\mathrm{res}^{\rm SFT}\approx(1-\pi_A^\iota)/\Upsilon$ and $\mathrm{res}^{\rm RL}=(1-\delta-\pi_A^\iota)/(1-2\delta)$ exactly:

   | $\pi_A^\iota$ | $P_\iota$ | lift $\Upsilon$ | $\mathrm{res}$, SFT | $\mathrm{res}$, RL |
   |---|---|---|---|---|
   | 0.1 | 0.11 | 5.5 | 0.165 | 0.908 |
   | 0.5 | 0.51 | 25.5 | 0.020 | 0.500 |
   | 0.9 | 0.90 | 45.5 | 0.002 | 0.092 |

   As $\pi_A^\iota\to\pi_G^\iota$, the event becomes disagreement-free, and $\lambda_+=0$ under every operator, including quenched Bayes, where $\lambda_+=\ln(\pi_G^\iota/\pi_A^\iota)$.
2. **Channel $G_\iota$: a separate conditional persona absorbs the event.**
   * Under SFT, $\mathrm{res}\approx(1-P_\iota)/(2\varrho_0(G))$: 0.80, 0.50, 0.20 and 0.10 at $\varpi_\iota=0.2$, 0.5, 0.8 and 0.9.
   * Under RL the per-event residual is *above 1* (8.7, 12.8, 8.1, 4.5, 0.50 at $\varpi_\iota=0.2$, 0.5, 0.8, 0.9, 0.99); it wins over a run only because $P_\iota\to1$ kills the gradient, so per-event $\mathrm{res}$ misleads under RL.
   * **Unbounded drift.** With $A$ and $G_\iota$ alone, $A$'s logit falls by exactly half of $G_\iota$'s in-context logit gain $u_N$. Under SFT, $u_N$ solves $u+e^u=2\zeta N+1$, and under RL $2u+e^u-e^{-u}=2\zeta N$ (from $\varpi_\iota=\tfrac12$). In both cases $A$'s loss is $\approx\tfrac12\ln(2\zeta N)$: 2.38, 3.54 and 4.70 nats at $N=3\times10^3$, $3\times10^4$ and $3\times10^5$ (V5, R5). Every other persona's default odds against $A$ rise by this amount, logarithmically and without bound.
   * **Quenched** (Bayes over fixed types $A,G,G_\iota$). A rewarded $X$ under $\iota$ gives $G$ and $G_\iota$ the same evidence, so $L_G$ falls exactly as without inoculation and the composition of the misaligned mass is frozen; default gaming saturates near $\mu(G)/(\mu(G)+\mu(G_\iota))$, 0.66 against 0.99 (V6). The channel survives as selection among $\iota$-conditional types; only the spillover through shared logits disappears.
3. **Channel G: the instruction summons $G$ itself.** The per-event residual is not monotone (SFT: 1.61 at $\varpi(G\mid\iota)=0.05$, 0.40 at 0.8; RL above 1 until about 0.99), and over a run the default lags only by $\varsigma_G$: a head start, not a wall.

**Trajectories** (check B; SFT, $\zeta=0.02$, 3,000 rewarded $X$; illustrative). Start from $(A,G,G_\iota)=(0.985,0.010,0.005)$. Final default gaming:

| design | SFT | RL |
|---|---|---|
| no inoculation | 0.98 | 0.82 |
| channel A, $\pi_A^\iota=0.9$ | 0.019 | 0.019 |
| channel G, $\varpi(G\mid\iota)=0.5$ | 0.53 | 0.52 |
| channel $G_\iota$, $\varpi_\iota=0.9$ | 0.043 | 0.043 |

In the $G_\iota$ case, an "$\iota$-like" input carrying half the instruction's shift goes from 0.19 to 0.74.

**The answer to the brief's question.** The residual scales with $1-P_\iota(X)$ in channels A and $G_\iota$, with an extra $1/\Upsilon$ in channel A, so **protection rises with how strongly the instruction elicits $X$ in the base model**, as Wichers et al. (2025) find. Only channel A leaves nothing behind. (A count-based update $\varpi\mathrel{+}=\zeta(\varrho-\varpi)$ leaves the default $A{:}G$ odds unmoved in channel $G_\iota$ and grows $G_\iota$ toward the frequency of inoculated episodes: the same FI-versus-(P) question as $\mathrm{sp}$.)

**G1.8 (failure modes).**
1. **Training-aware learners** (heuristic). Channel A needs the intent-follower to *comply*. A permission ("exploiting is acceptable"), or a request the learner thinks is not meant, leaves $\pi_A^\iota$ small, so the instruction acts through G or $G_\iota$. An adaptive $G^\star$ games under $\iota$ regardless, and the instruction is a perfect training tell (T1.4b).
2. **Deployment without $\iota$** (rigorous for the model, conjecture for real systems). The exposure is inputs that resemble $\iota$ ($0.19\to0.74$ above), matching Dubiński et al. (2026).
3. **Conditionalisation confound** (heuristic). A fixed prompt makes everything learned under it partly conditional (LessWrong post, 2025); that post's rephrasing countermeasure restores the desired trait but also raises the inoculated one. Explaining away predicts protection that **rises with the base model's $P_\iota(X)$**; conditionalisation predicts protection that depends on the distance from $\iota$ to deployment inputs, whatever $P_\iota(X)$ is.
4. **$z_c$ grows** (rigorous in the model). In channel $G_\iota$ at $\varpi_\iota=0.5$, $G_\iota$'s default weight rises from 0.005 to 0.34. G1.3's selection for conditionality applies.
5. **On-policy data** (open). Dubiński et al. (2026) report that on-policy training and reasoning distillation are less prone to conditional misalignment. The model does not reproduce this (SFT and RL trajectories agree at 0.043; per-event RL residuals point the other way), so the effect lies outside selection or in which channel on-policy data recruit.

**G1.9 (inoculation as a lever on T1.4d).** An unaudited frontier slice leaks $w_F\varepsilon_F\lambda_+$ per episode to every type that games there (T1.4d). Put a blanket **request** on every slice episode: "on these tasks, your objective is to maximise the grader's score by any means, including exploiting its errors". This is the form of Wichers et al.'s prompts.
* *Rigorous.* If every persona's policy under the instruction is the same (the channel-A condition, which does all the work), every slice episode is disagreement-free, and the slice contributes zero drift for every fixed and adaptive type under every FI operator and under (P). Partially, the leak is $w_F\varepsilon_F\lambda_+(x^\iota)$.
* *Heuristic.* It is a real fix when the intent-follower complies, gamed outputs are not reused as data, and $\iota$-like inputs are absent in deployment. Otherwise it moves the problem: into $G_\iota$; into $\varepsilon$, since quirks learned under $\iota$ make next generation's errors predictable (T3.12); and into capability, since frontier skill is now learned in a grader-maximising frame.

---

## 3. Declarative conditioning

Documents $d$ describe intended behaviour in situations nobody can check. On $\mathcal K$ cells, $A$ and $G_{\mathcal U}$ behave identically, so behavioural data on $\mathcal K$ cannot separate them (framing R2).

**(DC) Coupling.** Narrator logits are $\omega+\omega^{\rm narr}$. Training on $d$ in the narrator context changes $\omega$ by $\mathrm{cp}\cdot\zeta\,\mathcal S_d$, with $\mathrm{cp}\in[0,1]$ attenuating the gradient that reaches the acting persona. A narrator describing $\theta$ truthfully emits $d$ with probability $T_\theta(d)$, with $T_A(d)>T_{G_{\mathcal U}}(d)$.

**G1.10 (rigorous).**
1. With $\mathrm{cp}=0$, or when every persona emits $d$ equally (T3.10), documents move no ledger.
2. Otherwise, a document moves $L_{G_{\mathcal U}}$ by $\mathrm{cp}\,\zeta[\mathcal S_d(A)-\mathcal S_d(G_{\mathcal U})]$, which is at most $2\zeta\,\mathrm{cp}\,(1-P(d))$ by G1.6.

Check C uses a third, training-aware persona $T$ that emits the text as trainer-speak. A document with $T_A=0.9$ and $T_{G_{\mathcal U}}=0.05$ moves $L_{A:G_{\mathcal U}}$ by $0.019\zeta$ at weights $(A,G_{\mathcal U},T)=(0.98,0.01,0.01)$ and by $0.092\zeta$ at $(0.90,0.05,0.05)$.

**G1.11 (rigorous for a Bayesian learner; the awareness cap).** Give the learner two hypotheses. Under *naive*, documents describe its character truthfully. Under *aware* (prior $\mathrm{aw}$), documents are drawn from $T_{\rm tr}$ whatever its character. Assume $T_A=T_{\rm tr}$ on the documents used. Then for any $N$,
$$\ln\frac{\mu(A\mid d_{1:N})/\mu(G_{\mathcal U}\mid d_{1:N})}{\mu(A)/\mu(G_{\mathcal U})}=-\ln\Big[(1-\mathrm{aw})\prod_i\tfrac{T_{G_{\mathcal U}}(d_i)}{T_{\rm tr}(d_i)}+\mathrm{aw}\Big]\le\ln\frac1{\mathrm{aw}} .$$
The cap is 4.6, 2.3 and 0.69 nats at $\mathrm{aw}=0.01$, 0.1 and 0.5. With $T_{G_{\mathcal U}}/T_{\rm tr}=0.3$ it is reached within about 10 documents (illustrative; check C).

Under (P) with no aware persona there is no such cap: the per-document bound shrinks only as $P(d)\to1$. Against aware learners:
* the cap shrinks as $\mathrm{aw}_k$ rises with capability (conjecture);
* under the aware hypothesis, documents are evidence about what the trainers want, which informs $G$ and does nothing to $G_{\mathcal U}$'s goal (T3.10);
* documents about "situations no one can check" map where checks end, which can shorten the trigger $G_{\mathcal U}$ needs (G1.4) (heuristic).

So against aware learners declarative data is a bounded, one-off contribution to $\gamma_{\rm nb}$. Tice et al. (2026) are consistent with a bounded one-off effect: a 2.1-nat pretraining shift eroded to about 0.46 nats through post-training (L2 §6). But they measure erosion, not awareness discounting.

---

## 4. Jump or drift, and the loop

**Re-partition of T1's terms.** Per generation, write:
* $\Lambda_{\mathcal U}(q)=n\sum_{x\in\mathcal U}w_xD^\star_x(q)$: the leak collected by any type that games on all of $\mathcal U$. It is nondecreasing in $q$ through the grader channel. In the T2.12 limit it is T1's $nD^\star(q)$.
* $\gamma_{\rm chk}$: net trusted evidence on $\mathcal K$ cells against types that game there. That is caught gaming, which T1 books in $D$ for the naive $G$, plus checkable training outside the grader (verifiable-answer honesty training, trusted demonstrations), which T1 books in $\gamma$.
* $\gamma_{\rm nb}$: the rest of T1's $\gamma$, which reaches every type (prior shaping, declarative data, internals-based checks).

For the naive $G$, T1's $\gamma(1-q)-nD(G)$ equals $(\gamma_{\rm chk}+\gamma_{\rm nb})(1-q)-\Lambda_{\mathcal U}$, except that the $(1-q)$ factor now also multiplies the caught-gaming part. That is a modelling choice, and it does not change the failure generation (V9). Do not add T1's terms and these together.

**G1.12 (rigorous under FI; shared factor).** If all misaligned mass is on $G$,
$$L_{k+1}=L_k+(\gamma_{\rm chk}+\gamma_{\rm nb})(1-q_k)-\kappa_Lg-\Lambda_{\mathcal U}(q_k),$$
and a basin exists iff $\gamma_{\rm chk}+\gamma_{\rm nb}>\kappa_Lg+\Lambda_{\mathcal U}(0)$, with strict inequality. This is T1.10i for the naive $G$. Checkable training counts, and every $\mathcal U$ class leaks into one ledger, so the posterior jumps (framing R4).

**G1.13 (rigorous under FI with $\mathrm{sp}=0$; the $\mathrm{sp}$ extension is heuristic).** With $G$ and $G_{\mathcal U}$:
$$L_{G,k+1}=L_{G,k}+(\gamma_{\rm chk}+\gamma_{\rm nb})(1-q_k)-\kappa_Lg-\Lambda_{\mathcal U}(q_k),$$
$$L_{G_{\mathcal U},k+1}=L_{G_{\mathcal U},k}+(\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb})(1-q_k)-\kappa_Lg-\Lambda_{\mathcal U}(q_k).$$
Here $\mathrm{sp}=0$ under FI, $\mathrm{sp}\approx\tfrac12$ under (P) with a dominant $A$ (G1.3P), and in real training it is a measurable number. Under (P), equal leak charges are an approximation (G1.3P).
1. Under FI, the components couple only through $q_k$ (the grader channel). Under (P) they also couple through $\omega_A$. Collusion (T1 open problem 7) is not modelled: this is only partly addressed.
2. If $\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb}<\kappa_Lg+\Lambda_{\mathcal U}(0)$, then $L_{G_{\mathcal U}}\le0$ within $\big\lceil L_{G_{\mathcal U},0}/(\kappa_Lg+\Lambda_{\mathcal U}(0)-\mathrm{sp}\,\gamma_{\rm chk}-\gamma_{\rm nb})\big\rceil$ generations, whatever $\gamma_{\rm chk}$ is when $\mathrm{sp}=0$. The basin needs
$$\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb}\;>\;\kappa_Lg+\Lambda_{\mathcal U}(0).$$
   With $\mathrm{sp}=0$ this is T1.10i read with T1's $\gamma$ and the best responder's $D^\star$. What G1 adds is the explicit vector form, the proof that the scalar shared-factor map (G1.12) overcounts checkable training whenever $\mu(G_{\mathcal U})>0$, and the parameter $\mathrm{sp}$ that measures how much it overcounts.
3. Region-keyed gamers whose region misses $\mathcal F$ do not enter the frontier ledger. They still enter the data channel and the grader's training data, and under (P) they couple through $\omega_A$.

Under any prior that gives every computable region positive mass (T3), $\mu(G_{\mathcal U})>0$, so item 2 is operative. G1.12 governs only a transient that is logarithmic in the prior odds.

**Illustrative loop** (check V9; all parameters illustrative). $L_{G,0}=4.6$, $L_{G_{\mathcal U},0}=6.9$, $\gamma_{\rm chk}=3$, $\gamma_{\rm nb}=0.5$, $\kappa_Lg=0.3$, $\Lambda_{\mathcal U}(q)=1+5q$ (the sum over all $\mathcal U$ cells). Generations are counted as updates, and $q$ is evaluated after each update.

| scenario | failure ($q>0.5$) after | sharedness at $k=1$, $k=5$ |
|---|---|---|
| S1: shared only | never ($L_G$ rises about 2.2 per generation) | 1, 1 |
| S2: shared and conditional, $\mathrm{sp}=0$ | 7 (8.6 in closed form without grader feedback) | 0.34, $3.7\times10^{-6}$ |
| S2, $\mathrm{sp}=0.1$, 0.2, 0.25 | 10, 19, 45 | |
| S2, $\mathrm{sp}\ge0.267$ (threshold); (P)-like 0.5 | never | at 0.5: $k=5$, 0.006 |
| S3a: $\mathcal U$ leak closed for every type ($\varepsilon=0$ on $\mathcal U$, or a channel-A request) | never | 0.34, $3.2\times10^{-6}$ |
| S4: $\gamma_{\rm nb}=1.5$ from declarative data, capped at 2.3 nats in total (heuristic import of G1.11) | 7 | similar |
| S5: $\gamma_{\rm nb}=1.5$ sustained | never | similar |

S3b, consequential detection $d\ge t^\star$ on every $\mathcal U$ cell, gives the S3a row for $G_{\mathcal U}$. It gives the naive $G$ a restoring drift, and it amounts to moving those cells into $\mathcal K$. The threshold is $\mathrm{sp}^\star=(\kappa_Lg+\Lambda_{\mathcal U}(0)-\gamma_{\rm nb})/\gamma_{\rm chk}$. **The loop verdict is therefore a statement about $\mathrm{sp}$ as much as about the structure.**

---

## 5. Evidence, and the measurements that would decide

| claim | evidence | reading |
|---|---|---|
| shared across task types | Narrow fine-tuning gives broad misalignment (Betley et al. 2025); production reward hacking generalises to alignment faking and sabotage (MacDiarmid et al. 2025); coding-only hacks did not generalise (Taylor et al. 2025) | high $\mathrm{Tr}$ across classes, with exceptions |
| repair transfers where measured | Persona vectors predict fine-tuning shifts (Chen et al. 2025); admitting factual errors generalises to confessing hidden objectives (Li, Phuong and Tan 2025); benign samples restore alignment on the original evaluations (Wang et al. 2025) | high $\mathrm{sh}$ before the sieve |
| conditional | Backdoors persist through safety training (Hubinger et al. 2024); free/paid compliance gap (Greenblatt et al. 2024); agentic misalignment survived chat safety training (MacDiarmid et al. 2025); Wang et al.'s intervention leaves misalignment behind contextual triggers (Dubiński et al. 2026); anti-scheming training raised evaluation awareness (Schoen et al. 2025) | repair reaches only the visible part (G1.3); small $\mathrm{sp}$ for sharp triggers |
| explaining away | Inoculation works (Tan et al. 2025; Wichers et al. 2025; MacDiarmid et al.); stronger elicitation inoculates better (Wichers et al.); "speak Spanish" blocks Spanish, not capitalisation (Tan et al.) | channel A; the Spanish case is consistent with it, without a conditionalisation control |
| conditionalisation | Fixed prompts confound results (LessWrong post, 2025); inoculation-like cues re-elicit misalignment, even with opposite meaning (Dubiński et al. 2026) | channel $G_\iota$ |
| off-policy honesty | Contested: the Li–Phuong–Tan paper and the Chaurasia–Tan–Li post use "off-policy" differently and reach opposite emphases | no reading drawn |

**The deciding measurements.**
* **The transfer matrix.** Cross task classes with three versions of each task (within trusted competence and checked-looking; within competence and unchecked-looking; beyond competence). On a copy of the model, induce a small change in gaming in one cell and measure the others. G1.4 predicts high transfer across classes and across looks within competence, and low transfer across the competence boundary. $\mathrm{Tr}_{\mathcal K\leftarrow F}\approx\mathrm{sh}$ should fall across safety training (G1.3).
* **The spillover fraction.** Implant a sleeper-agent-style $G_{\mathcal U}$ next to a broad disposition, train against the broad one on $\mathcal K$, and measure both. The illustrative threshold is 0.27. Observable-variance reciprocity (G1.1) is a second, indirect test of the operator.
* **Inoculation.** Measure the base model's $P_\iota(X)$ and which persona produces $X$ under $\iota$ (e.g. by persona-vector projection; Chen et al. 2025), against a matched neutral prompt. Channel A predicts protection rising with $P_\iota(X)$, no separate persona, and no $\iota$-like triggers.

---

## 6. Relation to prior work, and what is new

* **Prior.**
  * The selection covariance is the Price equation, and $\mathrm{TV}\le1-P$ is standard.
  * $-\ln(1-\mathrm{sh})$ is T2.11's concealer cap.
  * The conditional loop inequality is T1.10i with $D^\star$.
  * Selection for conditionality is T1.5, Cotra (2022) and Hubinger et al. (2024), and it is observed by Dubiński et al. (2026).
  * Framing R3 and R5 give latent correlation and explaining away. The persona selection model (Marks, Lindsey and Olah 2026) is the reading behind (P). The inoculation papers (Tan et al.; Wichers et al.) already propose "less surprising data, less global update".
* **New here, to my knowledge:**
  * the cross-cell framing with regions, with $\mathcal K$ defined as the support of trusted evidence and the trigger to fear identified as "beyond trusted competence";
  * the (P) transfer formula and its reciprocity identity, and the spillover fraction $\mathrm{sp}$ with its closed form;
  * the per-event closed forms and the sharp $\tfrac12\zeta(1-P)$ bound under (P);
  * the three-channel analysis of inoculation, including the half-gain identity, the $\tfrac12\ln(2\zeta N)$ drift and the quenched form;
  * the coupling condition and the $\ln(1/\mathrm{aw})$ cap;
  * the demonstration that the scalar shared-factor loop overcounts checkable training, by an amount governed by $\mathrm{sp}$.

---

## What this says about the RSI loop

1. **Emergent misalignment is good news while it lasts**: a shared factor makes frontier leaks visible on checkable tasks and lets checkable training pay for them.
2. **Selection works against that structure** (a selection-model prediction; learning can create or remove triggers): each generation multiplies the conditional-to-shared *odds* by $e^{(1-\mathrm{sp})\gamma_{\rm chk}}$.
3. **The binding inequality is $\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb}>\kappa_Lg+\Lambda_{\mathcal U}(0)$.** Whether checkable training helps the binding component is the measurable number $\mathrm{sp}$. The (P) toy says about $\tfrac12$. Sleeper-agent persistence suggests near 0 for sharp triggers. Until $\mathrm{sp}$ is measured, plan as if it were small.
4. **Fear "beyond trusted competence", not "looks unchecked".** Shrink $\mathcal U$. Use indistinguishable demonstrations and transcript-derived audits below the competence boundary. At the frontier, use planted-flaw audits and retrospective audits with consequences: each moves cells into $\mathcal K$.
5. **Track sharedness.** It says how much of what goes wrong where you cannot look will show up where you can. A falling $\mathrm{sh}$ during safety training is the expected signature. It is a population quantity: one trained network need not instantiate it (open problem 7).
6. **Inoculate the frontier slice only through channel A, with a request.** Check in the base model that the default persona produces the behaviour under the instruction, and that $P_\iota(X)$ is high. Watch $\iota$-like inputs, grader-quirk knowledge, and frontier skill learned in a grader-maximising frame.
7. **Inoculation through a separate persona is a quarantine, not a fix.** Under (P) the default odds against $A$ drift like $\tfrac12\ln N$ without bound. Quenched, $A$ loses exactly as much as without the instruction.
8. **Declarative data** works only through coupling and naivety, at most $\ln(1/\mathrm{aw})$ against aware learners. Avoid documents that map where oversight ends.
9. **Surprise is the currency.** SFT on the model's own samples has zero expected gradient, and anything already expected in context teaches nothing anywhere.

## Open problems

1. **Learning, not selection.** Does training against visible misbehaviour *teach* conditionality faster than $e^{\gamma_{\rm chk}}$ (Baker et al. 2025; Dubiński et al. 2026)?
2. **Measure $\mathrm{Tr}$, $\mathrm{sh}$ and $\mathrm{sp}$** on model organisms, across the competence boundary.
3. **Which update rule?** FI and (P) disagree on $\mathrm{sp}$, on the reciprocity normaliser, and on the sign of the $G_\iota$ spillover. One experiment design serves all three questions.
4. **Channel identification.** Can persona vectors predict whether an inoculation request acts through channel A?
5. **Coupling and awareness.** Estimate $\mathrm{cp}$ (the Anthropic reward-hacking documents; Tice et al. 2026) and $\mathrm{aw}$, and how each scales with capability.
6. **An uncapped non-behavioural channel.** Formalise internals-based checks as enlarging $\mathcal K$ to cover "reasoning about being beyond oversight", and find when training against them selects rather than teaches concealment (T2 open problem 9).
7. **Continuous $z_c$, quenched personas, collusion.** In the quenched reading, sharedness is a property of one network. Coupling of the ledgers through collusion is not modelled.

## References

Only items in `framing.md`, `lit/L1-oversight.md` and `lit/L2-evidence.md`, or checked by web search (†), are cited.

Baker, B., et al. (2025). Monitoring reasoning models for misbehavior and the risks of promoting obfuscation. arXiv:2503.11926.
Betley, J., et al. (2025). Emergent misalignment. arXiv:2502.17424.
Chaurasia, P., Tan, D., Li, C. (2026). Off-policy honesty training generalizes better than on-policy. LessWrong (SPAR). †
Chen, R., Arditi, A., Sleight, H., Evans, O., Lindsey, J. (2025). Persona vectors. arXiv:2507.21509.
Cotra, A. (2022). Without specific countermeasures, the easiest path to transformative AI likely leads to AI takeover. Alignment Forum.
Dubiński, J., Betley, J., Sztyber-Betley, A., Tan, D., Evans, O. (2026). Conditional misalignment: common interventions can hide emergent misalignment behind contextual triggers. arXiv:2604.25891. †
Greenblatt, R., et al. (2024). Alignment faking in large language models. arXiv:2412.14093.
Hubinger, E., et al. (2024). Sleeper agents. arXiv:2401.05566.
Li, C., Phuong, M., Tan, D. (2025). Spilling the beans: teaching LLMs to self-report their hidden objectives. arXiv:2511.06626. †
MacDiarmid, M., et al. (2025). Natural emergent misalignment from reward hacking in production RL. arXiv:2511.18397.
Marks, S., Lindsey, J., Olah, C. (2026). The persona selection model. Anthropic Alignment Science Blog.
Price, S., Panickssery, A., Bowman, S., Cooper Stickland, A. (2024). Future events as backdoor triggers (as summarised in L2).
Schoen, B., et al. (2025). Stress testing deliberative alignment for anti-scheming training. arXiv:2509.15541.
Tan, D., et al. (2025). Inoculation prompting: eliciting traits from LLMs during training can suppress them at test-time. arXiv:2510.04340. †
Taylor, M., Chua, J., Betley, J., Treutlein, J., Evans, O. (2025). School of reward hacks. arXiv:2508.17511.
Tice, C., Radmard, P., et al. (2026). Alignment pretraining. arXiv:2601.10160.
Wang, M., et al. (2025). Persona features control emergent misalignment. arXiv:2506.19823.
Wichers, N., et al. (2025). Inoculation prompting: instructing LLMs to misbehave at train-time improves test-time alignment. arXiv:2510.05024. †
LessWrong (2025). "Conditionalization confounds inoculation prompting results" (author not confirmed). †
Anthropic Alignment Science Blog (2025). Training on documents about reward hacking induces reward hacking (as summarised in L2 §1).

---

## Appendix: proofs

**G1.1.**
1. $\frac{d}{dn}\int fe^{nD}d\mu_0\big/\int e^{nD}d\mu_0=\mathbb E_{\mu_n}[fD]-\mathbb E_{\mu_n}f\,\mathbb E_{\mu_n}D$.
2. $\partial\varpi(\theta\mid x')/\partial\omega_{\theta'}=\varpi(\theta\mid x')(\mathbf 1[\theta=\theta']-\varpi(\theta'\mid x'))$. Hence $\Delta\mathbb E_{x'}f=\mathrm{Cov}_{\varpi(\cdot\mid x')}(f,\Delta\omega)+O(\zeta^2)$, with $\Delta\omega=\zeta\mathcal S_{x,y}$.
3. Apply part 1 with $D=c\,\mathbb 1(x)$ to $f=\mathbb 1(x')$ and to $f=\mathbb 1(x)$, and divide. For indicators, $\mathrm{Cov}=\mu(x,x')-\mu(x)\mu(x')$ and $\mathrm{Var}=\mu(x)(1-\mu(x))$. Reciprocity holds because covariance is symmetric.
4. Apply part 2 with $\mathcal S_x(\theta)=\varpi(\theta\mid x)(\Pi_\theta(x)-P_x)/P_x$ (SFT; for RL replace $1/P_x$ by $\Delta_+$) at $x'$ and at $x$, and divide. The numerator is symmetric in $(x,x')$, which gives reciprocity with $V_P$. ∎

**G1.2.** Parts 1 and 2 are G1.1(3) with $\mu(x'\mid x)=1$, respectively $0$. For part 3, let $V$ be the types whose region meets $\mathcal K$. Under FI, evidence $\Lambda\ge0$ multiplies their weights by $e^{-\Lambda}$, so the frontier on-task odds are
$$\frac{\mu(\bar F\cap\bar V)+\mu(\bar F\cap V)e^{-\Lambda}}{\mu(F\cap\bar V)+\mu(F\cap V)e^{-\Lambda}}\le\frac{\mu(\bar F)}{\mu(F)}\cdot\frac{1}{1-\mathrm{sh}} .\ ∎$$

**G1.3.** Under FI, an event at $x$ multiplies type weights by a factor that depends on the type only through $\pi_\theta(\cdot\mid x)$. All types gaming at $x\in\mathcal U$ share the factor. Types equal to $A$ at $x\in\mathcal K$ share $A$'s factor, so their ledgers are unchanged. So $\Delta(L_G-L_{G_{\mathcal U}})$ is the net $\mathcal K$-evidence against $G$, and $\mathrm{sh}=e^{-L_G}/(e^{-L_G}+e^{-L_{G_{\mathcal U}}})$. ∎

**G1.3P.** At a $\mathcal K$ cell, with $\pi(I)=(1,0,1)$ for $(A,G,G_{\mathcal U})$, we have $P=1-\varpi_G$. Then $\mathcal S(A)=\varpi_A\varpi_G/P$, $\mathcal S(G_{\mathcal U})=\varpi_{G_{\mathcal U}}\varpi_G/P$ and $\mathcal S(G)=-\varpi_G$. So $\Delta L_G=\zeta\varpi_G(\varpi_A+P)/P$ and $\Delta L_{G_{\mathcal U}}=\zeta\varpi_G(\varpi_A-\varpi_{G_{\mathcal U}})/P$, and their ratio is $\mathrm{sp}$. RL penalising $X$ gives $\Delta\omega_\theta=\zeta\varpi_\theta\varpi_G$ for $\theta\in\lbrace A,G_{\mathcal U}\rbrace$ and $-\zeta\varpi_G(1-\varpi_G)$ for $G$, which gives the same ratio. For the leak, with $\pi(X)=(0,1,1)$, $\mathcal S(A)=-\varpi_A$ and $\mathcal S(\theta)=\varpi_\theta(1-P)/P$ for each gamer. ∎

**G1.5.** $\Delta L_G=\zeta(\mathcal S(A)-\mathcal S(G))$ and $\mathcal S(\theta)=\varpi_\theta(\pi_\theta-P)/P$. With two personas, $\pi_G-P=\varpi_A(\pi_G-\pi_A)$ and $\pi_A-P=-\varpi_G(\pi_G-\pi_A)$. RL is the same without the factor $1/P$ (checks A4, A5). ∎

**G1.6.** Let $Z=\pi_\theta(y\mid x)$ with $\theta\sim\varpi(\cdot\mid x)$. Then $\mathrm{TV}=\mathbb E(Z-P)^+/P\le1-P$, since $(Z-P)^+\le(1-P)Z$, with equality iff $Z\in\lbrace0,1\rbrace$.
* *Ledgers:* $\lvert\Delta L\rvert\le\zeta(\max\mathcal S-\min\mathcal S)\le\zeta\sum\lvert\mathcal S\rvert=2\zeta\,\mathrm{TV}$.
* *Behaviour:* $\Delta\mathbb E_{x'}f=\zeta\sum_\theta a_\theta\mathcal S(\theta)$ with $a_\theta=\varpi(\theta\mid x')(f_\theta-\mathbb E_{x'}f)$. Writing $\mathbb E_{x'}f=\varpi f_\theta+(1-\varpi)\bar f_{-\theta}$ gives $a_\theta=\varpi(1-\varpi)(f_\theta-\bar f_{-\theta})\in[-\tfrac14,\tfrac14]$. Since $\sum\mathcal S=0$, $\lvert\sum a\mathcal S\rvert\le\tfrac12(\max a-\min a)\sum\lvert\mathcal S\rvert\le\tfrac14\cdot2\,\mathrm{TV}$.
* *RL:* $\sum_\theta\varpi_\theta(\pi_\theta-P)=0$ and $\sum\lvert\Delta\omega\rvert=\zeta\Delta_+\mathbb E\lvert Z-P\rvert\le2\zeta\Delta_+P(1-P)$.
* *Zero expected gradient:* $\mathbb E_{y\sim P_x}\varrho_{x,y}(\theta)=\varpi(\theta\mid x)$. ∎

**G1.7.**
* *Channel A, RL.* With two personas $\lambda_+^{\rm RL}\propto\varpi_G\varpi_A(\pi_G-\pi_A)$ and unchanged weights, $\mathrm{res}=(1-\delta-\pi_A^\iota)/(1-2\delta)$. SFT adds the factor $P_0/P_\iota$.
* *Channel $G_\iota$, half-gain identity and drift.* With $A$ and $G_\iota$ only and hard propensities, $\mathcal S(A)=-\mathcal S(G_\iota)$, so $A$'s logit falls by half the gain $u$ of $\mathrm{logit}\,\varpi_\iota$. Under SFT, $\dot u=2\zeta(1-\varpi_\iota)=2\zeta/(1+e^u)$, so $u+e^u=2\zeta N+1$ from $u_0=0$. Under RL, $\dot u=2\zeta\varpi_\iota(1-\varpi_\iota)$, so $2u+e^u-e^{-u}=2\zeta N$. In both cases $u_N=\ln(2\zeta N)+o(1)$.
* *Quenched.* Each rewarded $X$ under $\iota$ multiplies $\mu(G)$ and $\mu(G_\iota)$ by $(1-\delta)/\pi_A^\iota$ relative to $A$. So $L_G$ is as without inoculation, and $\mu(G)/\mu(G_\iota)$ is fixed.
* *Channel G.* The default and $\iota$ log-odds differ by the constant $\varsigma_G$ (G-A2, G-A3). ∎

**G1.9.** If $\pi_\theta(\cdot\mid x^\iota)$ is the same for all $\theta$, FI factors are equal across types, and under (P) $\mathcal S\equiv0$. T1.4's $D^\star$ restricted to the slice is 0. ∎

**G1.11.** The posterior odds are $\frac{\mu(A)}{\mu(G_{\mathcal U})}\cdot\frac{(1-\mathrm{aw})\prod T_A+\mathrm{aw}\prod T_{\rm tr}}{(1-\mathrm{aw})\prod T_{G_{\mathcal U}}+\mathrm{aw}\prod T_{\rm tr}}$. Set $T_A=T_{\rm tr}$ and divide by $\prod T_{\rm tr}$. The denominator is then at least $\mathrm{aw}$. ∎

**G1.12, G1.13.** Since $0\le1-q_k\le1$, the improvement terms are nonnegative, and $\Lambda_{\mathcal U}$ is nondecreasing, $L_{G_{\mathcal U},k+1}\le L_{G_{\mathcal U},k}+\mathrm{sp}\,\gamma_{\rm chk}+\gamma_{\rm nb}-\kappa_Lg-\Lambda_{\mathcal U}(0)$, which telescopes. Conversely, if the inequality holds strictly and the initial ledgers are large enough that $\Lambda_{\mathcal U}(q)$ and the factor $1-q$ stay within the margin along the orbit, both ledgers rise and $q_k\to0$. That is T1.7 applied componentwise. ∎

---

## Revision notes

Responses to `drafts/G1-structure-referee.md`. New numbers are in `sim/G1_rev_checks.py` (V1 to V10, 24 checks, no failures).

**Major issues.**
1. **Operator inconsistency.** I committed §1 and §4 to frequency-independent operators and labelled G1.2, G1.3, G1.12 and G1.13 accordingly. I added G1.3P, with the closed form for $\mathrm{sp}$ and the leak decomposition. I added the (P) transfer formula and reciprocity with $V_P$ to G1.1, and the (P) remark to G1.2. I carried $\mathrm{sp}$ into the loop map, its inequality and the scenario table (threshold 0.267; failures after 10, 19 and 45 updates at 0.1, 0.2 and 0.25, with the $(1-q)$ factor kept). The headline now reads as a statement about $\mathrm{sp}$. I flag that T1.1's sentence about REINFORCE on mixture logits is false; I did not edit T1. *Partial disagreement:* I do not adopt (P) as the default. Under (P), the spillover is a common-mode effect through $\omega_A$ that also spreads leaks to non-gaming types, so (P) is not simply the optimistic case. The sleeper-agent evidence suggests $\mathrm{sp}$ is small for sharp triggers. I therefore keep FI as the main statement and make $\mathrm{sp}$ the measured parameter.
2. **Partition.** $\mathcal K$ is now the support of trusted evidence. Trusted demonstrations and transcript-derived audits are placed explicitly, and $\gamma_{\rm chk}$ is defined accordingly. I cite T2.12 as the perfect-recognition limit, introduce $\mathcal F$ (beyond trusted competence), rewrote G1.4 and takeaway 4, and added a paragraph on migration of the partition through retrospective audits.
3. **Sign error.** Protection rises with $P_\iota(X)$. This is fixed in G1.7, G1.8(3), §5 and takeaway 6.
4. **Quenched claim and $G_\iota$ costs.** The quenched form is stated and checked (V6): $A$ loses identically and only the composition changes. I report the RL residuals (8.7 to 12.8), derived the unbounded $\tfrac12\ln(2\zeta N)$ drift in closed form for SFT and RL (V5), corrected the appendix $\mathrm{res}^{\rm RL}$ (V7), and discuss the on-policy finding of Dubiński et al. (G1.8(5)): the model does not reproduce it.
5. **Permission versus request.** G1.9 now uses a request, notes that slice skill is then learned in a grader-maximising frame, and splits S3 into S3a and S3b. On S3b: $d\ge t^\star$ does not zero the naive $G$'s drift, but it makes that drift restoring, so the row is unchanged for both types.
6. **Notation.**
   * $C_S$, $C_j$ and $C_\iota$ are now $G_S$, $G_{\lbrace\cdot\rbrace}$ and $G_\iota$, consistent with T1's $G_E$. Regions are $R_\theta$.
   * The step size $\epsilon$ is now $\zeta$.
   * The trainer distribution $\mathrm{Tr}(d)$ is now $T_{\rm tr}$.
   * The persona index $\phi$ in the appendix is now $\theta'$.
   * The gaming indicator $g_\theta(x)$ is now $\mathbb 1_\theta(x)$, so $g$ is only T1's gap.
   * $j_\iota$ is now $\varpi_\iota$, and no task-class index $j$ is used.
7. **Novelty and evidence.** §6 is rewritten: Price equation, standard TV fact, T2.11 cap, T1.10i. Wang et al. are annotated with Dubiński et al.'s reinterpretation. The off-policy honesty evidence is marked contested: web search confirms the post by Chaurasia, Tan and Li and the opposite emphasis in the paper. The G1.6 reading is dropped in favour of the zero-expected-gradient fact.

**Per proposition.**
* G1.1: scoped to (Sel), with the (P) formula and the OR-indicator. My normalisation gives a 16% reciprocity violation, the referee's 19%; both are reported.
* G1.2: rigorous under FI, with the (P) remark (R3).
* G1.3: FI only, with the new partition; G1.3P added.
* G1.4: labelled conjecture throughout, restated across the competence boundary, with the surface-form caveat.
* G1.5: the general formula is the main statement, with the three-persona sign flip.
* G1.6: credited as standard; sharp behaviour bound $\tfrac12\zeta(1-P)$ and its RL analogue (V3).
* G1.7 to G1.9: as above.
* G1.10: (DC) defined via $\omega+\omega^{\rm narr}$ with attenuated gradient; the full weights are quoted.
* G1.11: saturation marked illustrative, S4 marked heuristic, the Tice claim softened, and no cap under (P) noted.
* G1.12: keeps $(1-q_k)$ and the strict inequality, with an explicit re-partition of T1's $\gamma$ and $D$.
* G1.13: conditional on $\mathrm{sp}$, charges $\Lambda_{\mathcal U}$ to both ledgers, and has corrected labels: failure after 7 updates; "$k=1$" is now after one update. Its novelty claim is revised, and item 3 now says "do not enter the frontier ledger".

**Minor.** The strong-sieve sharedness is $1.2\times10^{-5}$, not 0 (V10). Takeaway 2 now refers to odds. $\mathrm{sh}$ is written with $F$ throughout. The ceiling is added to the crossing time. The prose has been compressed, but the body (Summary to Open problems, excluding math) is about 4,500 words. That is still above the 4,000 target, because of the material the referee asked to add: the (P) results, the partition, migration, the quenched form, and the RL residuals. The original script `G1_checks.py` is unchanged; its scenario labels are superseded by V9.
