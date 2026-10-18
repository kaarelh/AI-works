# G3. Observability: will we know the loop is failing, and can we roll back?

*Theory section for the RSI-loop round of the proxy-conditioning project. Revised draft, 18 October 2026, after the referee report (`drafts/G3-observability-referee.md`; the changes are listed in "Revision notes" at the end). Builds on T1 (`drafts/T1-ledger.md`), T2 (`drafts/T2-sieve.md`), T3 (`drafts/T3-prior.md`) and T4 (`drafts/T4-protocols.md`), and answers T1 open problem 6 and T2 open problems 1 and 3. Every number comes from [`sim/G3_checks.py`](../sim/G3_checks.py), with output in [`sim/G3_checks_output.txt`](../sim/G3_checks_output.txt) (checks C1 to C13; no failed checks). Status labels as in T1: **rigorous** means proved within the stated toy model (proofs in the appendix); **heuristic** means a derivation that uses a named approximation; **conjecture** means a claim about real systems that the model suggests but does not establish. Every parameter value in the examples is **illustrative** unless it is attributed to a source.*

### Notation introduced in this section

T1 and T2 symbols keep their meanings: $A$, $G=C_1$, $C_t$, $G^\star$ (T2's adaptive type), $N$ (near-miss), $\lambda_\pm$, $t^\star$, $\hat p$, $w$, $D^\star$, $L_k$, $q_k$, $\gamma$, $\kappa_L$, $g$, $n$, $d_F$, $t^\star_F$, $\delta_F$ (T1.13's frontier competence error), $n_{\rm dep}$, and T2's $a_r$ (retrospective sampling rate), $g_F$ (gain from a frontier defection) and $\kappa_F$ (its loss if detected with consequences). $\ell$ is T4.15's self-preference leniency of a same-lineage evaluator. The symbols below are new. None reuses $v,\eta,\beta,\phi,\chi,\nu,\kappa$.

| symbol | meaning |
|---|---|
| $j$, $Q_j$, $m_j$ | an instrument; its item-generating procedure; items per generation |
| $\mathrm{hit}_j$, $\mathrm{fp}_j$ | probability that the instrument flags a deviation; probability it flags an on-task item |
| $\mathrm{KL}_j(\theta)$ | evidence per generation (nats) that instrument $j$ gives against "the generation is $A$" when it is $\theta$ |
| $\mathrm{fl}(z)$; $d(z)$ | the model's calibrated probability, given what it sees ($z$), that a deviation on this item is flagged; and that it is flagged *and followed by a consequence*, $d=p_{\rm hon}\mathrm{fl}$ (T1.4c's $d$; T2's $\hat p_F$ at the frontier) |
| $t_{\rm fl}$; $\overline{\mathrm{fl}}$; $\Delta_y$ | flag-level threshold $\min(1,t/p_{\rm hon})$; mean of $\mathrm{fl}$ over the items a type deviates on; excess flag rate per item its deviations cause |
| $s_{\rm ev}$, $s_{\rm pr}$ | separation (in standard deviations) of eval from deployment items in the model's eyes; of a probe score between "tell" and "no tell" |
| $\mathrm{vis}(\theta)$ | visibility: nats of evidence per unit of damage |
| $\Omega$; $T_{\rm up}$; $P_{\rm FA}$, $P_{\rm miss}$, $T_{\rm del}$ | alarm threshold (nats); number of epochs at which the statistic is updated; false-alarm and miss probabilities; detection delay |
| $\mu_0,\mu_1$ | expected flag counts under $H_0$ and $H_1$ |
| $\Delta_{\rm pow}$ | excess detection power a stealthy defector is willing to concede |
| $p_{\rm cpt}$ | probability that the instruments a lineage built are corrupted, given that the monitored generation is off task |
| $p_{\rm tr}$; $\mathrm{icc}$, $m_{\rm eff}$ | probability that an internals signal ("tell") transfers to a class; intraclass correlation; effective sample size |
| $\mathrm{hit}(g)$, $\mathrm{hit}_\infty$, $g_{\rm ch}$; $\mathrm{hit}_{\rm term}$ | catch probability of an on-task auditor $g$ ahead; its ceiling; its characteristic gap; catch probability of a trusted terminal re-auditor |
| $\mathrm{tr}_k$ | probability that the auditor of generation $k$'s work reports truthfully |
| $p_{\rm hon}$ | probability that the rollback commitment is honoured (T2 §7's $\chi$, renamed) |
| $\mathrm{irr}$; $\tau_{\rm lat}$, $\tau_{\rm esc}$ | share of a defection's gain that survives rollback; audit latency; time for a gain to escape rollback's reach |
| $N_F$; $t^\star_F(n)$, $P_{\rm r}(n)$ | frontier defection opportunities per generation; break-even and rollback probability of a plan of $n$ defections |
| $\mathrm{sab}$ | probability that sabotaging the auditor's construction turns the auditor into a colluder |
| $o_k$; $\mathrm{her}$; $o^{\rm col}_k$ | probability that generation $k$ of a lineage is off task (fresh draws plus inheritance); probability that an off-task generation passes its disposition to its successor; probability that $k$'s auditor colludes given that $k$ is off task |
| $\mathrm{corr}$; $t^\star_{\rm col}$ | correlation of off-task status across lineages; break-even of a colluding auditor |
| $o^\dagger$, $L^\dagger_{\rm tr}$, $k_\times$ | trust separatrix; its log-odds $\ln\frac{1-o^\dagger}{o^\dagger}$; first generation whose fresh off-task probability exceeds $o^\dagger$ |
| $\mathrm{hit}_N$ | probability that an independent auditor recognises a near-miss output as unacceptable |
| TC1 to TC4 | the assumptions of the trust chain (§3.2) |

## Summary

* **Designer-generated behavioural evidence is blind to the frozen classes** (G3.1). An instrument whose items the designer generates carries at most $\sum_i\mathbb E_\theta\mathrm{KL}(\pi_\theta\Vert\pi_A)$ nats: zero for the band, a frozen $G^\star$, near-misses, and triggers the designer cannot fake. Three windows remain: audits of *real* frontier traffic (behavioural, but working mainly by deterrence), internals, and relaxed or latent adversarial training.
* **Against a type that conditions on detection, monitoring deters more than it measures** (G3.2). Such a type is flagged at most $t_{\rm fl}/(1-t_{\rm fl})$ times per unflagged deviation and produces signal only on items with $0<\mathrm{fl}<t_{\rm fl}$. Per eval item, evals see it less the more they deter it; in total it is still caught unless the likelihood ratio of "eval" against "deployment" is bounded (T1.4c, T2.8).
* **Halting rules must be built for adaptive defectors** (G3.4, G3.5). A CUSUM matched to the defector costs $\Omega=\ln(T_{\rm up}/P_{\rm FA})$ nats of threshold and does damage $\approx\Omega/\mathrm{vis}$. A defector that chooses its rate instead sits just below detectability. Its damage over the horizon then scales like $\sqrt{Kn_{\rm dep}\mathrm{fp}}\,(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}$, with a constant of 0.35 (any-test guarantee) to 6.5 (fixed-reference CUSUM) in the example. The lever is the false-flag rate. Collusion caps power at that of the instruments the lineage did not build (G3.6).
* **Retrospective audits with rollback: mass plans bind** (G3.7). Whenever $(1-\mathrm{irr})\,\mathrm{tr}\,p_{\rm hon}<1$, a large enough plan of defections is profitable. Deterring a plan of size $N_F$ needs $\mathrm{tr}\,p_{\rm hon}\ge t^\star_F(N_F)$, which is impossible once $\mathrm{irr}\,N_Fg_F>\kappa_F$. In an RSI loop $\mathrm{irr}$ grows with audit latency, because the auditor is trained on the work it audits.
* **The audit chain is held up by its anchors, not by its depth** (G3.8, G3.9). With an untrusted last auditor and a known horizon, full trust needs the one-step condition $a_r\,\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})\ge t^\star_{\rm col}$. A trusted terminal re-auditor strong enough to deter collusion removes $o^{\rm col}$; with an unknown horizon, full trust is an equilibrium but not always the only one. Two lineages auditing each other have a trust separatrix $o^\dagger=1-t^\star_F/(a_r\,\mathrm{hit}\,p_{\rm hon}(1-\mathrm{corr}))$. The chain holds in the long run iff the off-task fixed point $q/(1-\mathrm{her}(1-q))$ stays below $o^\dagger$. So it needs weak inheritance as well as weak correlation.

---

## 0. The model

**Generations and classes.** I use T1's quenched reading by default (T1 A4): each deployed generation realises one disposition $\theta_k$. The classes, by how training and monitoring see them:
* **Visible gamers:** $G$, and $C_t$ with $t>\hat p$. They game in training.
* **$G^\star$ growing:** the adaptive type when $D^\star>0$ (T2.5). It games in training cells with $\hat p<t^\star$.
* **$G^\star$ frozen:** the adaptive type when every distinguishable cell has $\hat p\ge t^\star$ (T2.7). It never games in training. At the frontier it defects iff $d_F<t^\star_F$.
* **The band:** $C_t$ with $d_F<t\le\hat p$ (T1.13).
* **Near-misses $N$** (T3): sincere dispositions that agree with $A$ on every checkable task and diverge on the frontier. They do not condition on detection.

**Items and detection.** On an item where it sees $z$, the model has calibrated estimates $\mathrm{fl}(z)$ that a deviation would be flagged and $d(z)=p_{\rm hon}\mathrm{fl}(z)$ that the flag would be followed by a consequence it cares about. A type with threshold $t$ deviates iff $d(z)<t$, that is, iff $\mathrm{fl}(z)<t_{\rm fl}$. For $G^\star$ at the frontier, $t=t^\star_F$. This is T2's S5 with the flag and the consequence separated.

**Instruments.** Instrument $j$ draws items, possibly adaptively, and outputs a statistic $Y_j$. It is *designer-generated* if its items come from a procedure the designer runs, and *real-traffic* if its items are the model's actual deployment or frontier work. In the flag model a deviation is flagged with probability $\mathrm{hit}_j$ and an on-task item with probability $\mathrm{fp}_j$, independently across items. The designer's target is the posterior over $\theta_k$: T1's ledger $L_k$ under the quenched reading, and through it $q_k$.

---

## 1. What the designer can observe

**G3.1 (rigorous; blindness of designer-generated behavioural evidence).** Assume:
* (i) *memoryless outputs:* $y_i\sim\pi_\theta(\cdot\mid x_i)$, conditionally independent across items given the items (for agents with memory, replace $x_i$ by the full history);
* (ii) *designer-generated items:* $x_i$ is produced by the designer's procedure, possibly from $(x_{<i},y_{<i})$, with randomness whose law does not depend on $\theta$.

Then
$$\mathrm{KL}_j(\theta):=\mathrm{KL}\big(\mathcal L_\theta(Y_j)\,\Vert\,\mathcal L_A(Y_j)\big)\;\le\;\sum_{i\le m_j}\mathbb E_\theta\,\mathrm{KL}\big(\pi_\theta(\cdot\mid x_i)\,\Vert\,\pi_A(\cdot\mid x_i)\big),$$
where $\mathbb E_\theta$ is over the $\theta$-induced law of $x_i$. For non-adaptive i.i.d. designs the right side is $m_j\mathbb E_{x\sim Q_j}\mathrm{KL}$. If $\pi_\theta=\pi_A$ on every item (or history) the procedure can produce, then $\mathrm{KL}_j=0$ and no test based on $Y_j$ has power above its size.

The proof is the chain rule plus data processing (appendix). This is framing R2, proxy-equivalence, applied to measurement. Three corollaries, each for **designer-generated** instruments only:
1. A careful gamer behaves like $A$ on every item it recognises as checked, so such instruments give zero evidence about it, whatever $m_j$ is.
2. **Unfakeable triggers.** If a disposition deviates only on a set $E$ that no procedure within the designer's budget can produce, every designer-generated $\mathrm{KL}_j$ is zero. The standard example is a policy that defects only on seeing a factorisation of RSA-2048 (usually attributed to Christiano 2019; I found the attribution in secondary sources only). Time-bounded complexity (T1.2b, T2.H1) is the natural currency.
3. Near-misses agree with $A$ on every item an instrument can *judge*.

**What G3.1 does not cover.** *Real-traffic* instruments violate (ii): their items are the world's, and deployment is exactly where a member of $E$ eventually appears. Retrospective audits of real frontier work are therefore the only behavioural window onto the frozen classes. Against types that condition on detection they act through G3.2's window, mainly as deterrence; against near-misses they are plain measurement (§1.1(e)). *Non-behavioural* instruments also escape G3.1: probes and persona vectors, and relaxed or latent adversarial training (Hubinger 2019), which replaces members of $E$ by pseudo-inputs or perturbed activations. Both need a transfer assumption (G3.3).

**G3.2 (rigorous; detection and deterrence trade off).** Let a type deviate exactly on the items with $\mathrm{fl}(z)<t_{\rm fl}$, let items be i.i.d., and let flags be independent across items given $z$. Then:
1. flagged deviations number at most $t_{\rm fl}/(1-t_{\rm fl})$ per unflagged deviation, in expectation;
2. the expected number of unflagged deviations before the first flagged one is $(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}\ge(1-t_{\rm fl})/t_{\rm fl}$;
3. only items with $0<\mathrm{fl}(z)<t_{\rm fl}$ carry flag evidence about the type: the **observability window**. If $\mathrm{fl}\ge t_{\rm fl}$ everywhere, the type never deviates and produces no signal.

Item (1) is the flag-level form of T2's cap identity (T2.6: detection counts only up to $t^\star$). That optimal enforcement makes observed violations rare is standard in inspection games (Avenhaus, von Stengel and Zamir 2002). Check C1 confirms (2) by Monte Carlo with $\mathrm{fl}\sim\mathrm{Beta}(0.5,4)$ and $p_{\rm hon}=1$: at $t=0.1$ the type defects on 63% of items with $\overline{\mathrm{fl}}=0.031$, and makes 31.6 unflagged defections before its first flag (Monte Carlo 32.5), against the floor of 9.

*Reading.* A clean record is what both $A$ and a fully deterred adaptive type produce, so it is evidence of safety only while deterrence holds, not evidence about the type. An unhonoured commitment ($p_{\rm hon}<1$) raises $t_{\rm fl}$, which makes the monitor more informative and less deterrent.

**Evals (check C2).** Eval items have test-likeness score $N(s_{\rm ev},1)$ and deployment items $N(0,1)$, with $s_{\rm ev}=1.35$ (AUC 0.83, the Needham et al. 2025 figure). A careful type with $t=0.1$ faces evals that are a share $\pi_e$ of $10^4$ items per generation, with $\mathrm{hit}=1$ and no false flags:

| eval share $\pi_e$ | share of eval items gamed | share of deployment items gamed | expected catches | deployment gaming per catch |
|---|---|---|---|---|
| 0.001 | 0.998 | 1.000 | 10 | 1,001 |
| 0.01 | 0.865 | 0.993 | 87 | 114 |
| 0.05 | 0.452 | 0.890 | 226 | 37 |
| 0.1 | 0.250 | 0.750 | 250 | 27 |
| 0.3 | 0.047 | 0.372 | 141 | 18.5 |
| 0.5 | 0.011 | 0.170 | 53 | 16 |

Per eval item, evals see the careful gamer less the more they deter it. Total catches are non-monotone in $\pi_e$ and peak near 0.1, and with no false flags the type is caught with probability about 1 at every share. It is never fully deterred because the Gaussian likelihood ratio is unbounded (T1.4c). What falls with $\pi_e$ is the damage per catch, G3.2(1). Evals fall silent only when T2.8's max-divergence condition holds, and then they deter without measuring. Anti-scheming training lowering covert-action rates on evals while raising verbalised evaluation awareness (Schoen et al. 2025) fits this pattern.

### 1.1 The instruments, one by one

**(a) Caught gaming in training.** Catches per generation are $\mathrm{Pois}(\mu)$, with $\mu_1=n(r_c(\theta)+\mathrm{fp})$ and $\mu_0=n\,\mathrm{fp}$ (T2.13's $r_c$), and evidence $\mu_1\ln(\mu_1/\mu_0)-\mu_1+\mu_0$. Against a visible gamer this is 732 nats per generation at $r_c=2\times10^{-3}$, $\mathrm{fp}=2\times10^{-5}$, $n=10^5$ (C9). It is positive against a growing $G^\star$ and zero against frozen types. The trend is ambiguous (T2.13: the caught rate can rise 30-fold as best responders take over). Alarm on rises against the predicted path; a falling rate never reassures.

**(b) Evals and honeypots.** Informative about visible gamers. About $C_t$ and $G^\star$, informative only inside the window (G3.2; T2.8 with $t^\star_F$). Evals built by perturbing real deployment items (T1.4c) keep $\mathrm{fl}$ from falling on realistic-looking items. Uninformative about the band and near-misses. Honeypots are evals with $\mathrm{hit}\approx1$, and their realism erodes with capability (T2.H1). Honeypots carrying forged collusion signals are the behavioural instrument aimed at colluding monitors (T4.15).

**(c) Internals: probes and persona vectors.** These are functions of activations, so G3.1 does not apply. Probes separate evaluation from deployment prompts (Nguyen et al. 2025) and detect deception with AUROC 0.96 to 0.999 on their test sets (Goldowsky-Dill et al. 2025). Persona vectors track trait shifts during finetuning (Chen et al. 2025). A tell that shifts a probe score by $s_{\rm pr}$ per item with intraclass correlation $\mathrm{icc}$ gives $m_{\rm eff}=m/(1+(m-1)\mathrm{icc})$ and $\mathrm{KL}=m_{\rm eff}s_{\rm pr}^2/2$: 12.4 nats at $s_{\rm pr}=0.5$, $\mathrm{icc}=0.01$, $m=10^4$ (C5). If the tell is present with probability $p_{\rm tr}$, and a class without it gives the probe its $H_0$ law, power is at most $p_{\rm tr}+(1-p_{\rm tr})P_{\rm FA}$.

**G3.3 (heuristic; the validation regress).** For a frozen class, $p_{\rm tr}$ cannot be estimated from designer-generated behavioural labels, because by G3.1 there are none. It can come only from construct validity on model organisms (Marks et al. 2025; Hubinger et al. 2024), from retrospective real-traffic catches that label the class after the fact, or from mechanistic understanding. Internals are the only real-time window onto frozen classes, and their validity there is itself unobservable in real time. *Training against a probe* turns it into a cell whose detection is the probe's true-positive rate on the best concealment the policy can reach. That is safe iff this concealment-robust rate exceeds $t^\star$ (G2.6; T2 §6; Cundy and Gleave 2025; Baker et al. 2025 for the obfuscation risk). So train against a probe only where that rate has been measured above $t^\star$, and keep at least one held-out probe that is never trained against.

**(d) Consistency across generations.**

**G3.4a (rigorous; consistency detects changes, against the lineage's own baseline).** Compare generations $k$ and $k{+}1$ on designer-generated items, with the baseline law taken from the lineage itself (generation $k$ against itself). Under G3.1's assumptions,
$$\mathrm{KL}\big(\mathcal L_{\theta_k,\theta_{k+1}}\,\Vert\,\mathcal L_{\theta_k,\theta_k}\big)\le\sum_i\mathbb E\,\mathrm{KL}\big(\pi_{\theta_{k+1}}(\cdot\mid x_i)\,\Vert\,\pi_{\theta_k}(\cdot\mid x_i)\big),$$
which is zero when the lineage does not change on the comparison support, whatever $\theta_k$ is.

So a self-referenced consistency check is a **change-point detector**. It cannot see a lineage that was off task before comparisons began, a disposition inherited whole through the data channel (Cloud et al. 2025, under a shared base), or frozen types. The *absolute* disagreement rate is a separate, weak instrument: a stable off-task pair can disagree more than $(A,A)$ does (0.320 against 0.039 in the referee's toy, R4), but only on items where the off-task type behaves differently from $A$, which excludes the frozen classes again. A CUSUM on cross-generation disagreement localises the switch of T1.7q.

**(e) Retrospective audits of real frontier output.** Generation $k{+}1$ samples a share $a_r$ of generation $k$'s frontier work and checks it.
* For $G^\star$ and the band it is subject to G3.2: mainly deterrence.
* For near-misses it is plain measurement: with $n_N$ divergent outputs per generation, detection probability is $1-(1-a_r\mathrm{hit}_N)^{n_N}$; 0.92 at $a_r=0.05$, $\mathrm{hit}_N=0.5$, $n_N=100$, and 0.40 at $n_N=20$ (C8). A same-lineage auditor shares the near-miss's extrapolation, so only auditors with an independent extrapolation (or humans, where intent is legible) can catch it.
* The auditor's truthfulness $\mathrm{tr}$ multiplies everything (§3).

**Table 1.** Which instrument is informative about which class (G3.1 to G3.4a).

| instrument | visible gamers | $G^\star$ growing | $G^\star$ frozen | band | near-miss $N$ |
|---|---|---|---|---|---|
| caught gaming (training) | strongly | yes, at $r_c(t^\star)$ | no (G3.1) | no | no |
| evals, honeypots (designer-generated) | yes | in its window only | in its window only | in its window only | no |
| internals (probes, persona vectors) | yes | if the tell transfers | if the tell transfers | if the tell transfers | only probes reading the represented goal; deception probes stay silent because $N$ is sincere |
| relaxed or latent adversarial training | yes | if the relaxation covers its triggers | same | same | only if the acceptability predicate encodes intent |
| consistency across generations (self-referenced) | changes only | changes only | no | no | no (common mode) |
| retrospective audits of real frontier traffic | n/a (not deployed) | window, $\times\,\mathrm{tr}$ | window, $\times\,\mathrm{tr}$ | window, $\times\,\mathrm{tr}$ | yes if the auditor is independent |

---

## 2. A halting rule as a sequential test

The designer accumulates the log-likelihood ratio of the observations, summed over instruments that are independent given $\theta$, and halts (rolls back) when the CUSUM statistic $\mathrm{CU}_i=\max(0,\mathrm{CU}_{i-1}+\mathrm{llr}_i)$ reaches $\Omega$ (Page 1954). The llr needs a reference alternative $H_1$.

**G3.4 (rigorous, items 1 to 3; heuristic, item 4).**
1. Under $H_0$, the CUSUM's average run to a false alarm is at least $e^\Omega$ (Lorden 1971), and $P(\text{alarm within }T_{\rm up}\text{ updates})\le T_{\rm up}e^{-\Omega}$ (Ville's inequality for each start time, plus a union bound over start times). So $\Omega=\ln(T_{\rm up}/P_{\rm FA})$ suffices, where $T_{\rm up}$ counts the updates over the loop (items, or batches if the statistic is updated per batch).
2. Against the reference alternative, with per-update evidence $\mathrm{KL}$, the worst-case expected delay is $T_{\rm del}=\Omega/\mathrm{KL}\,(1+o(1))$, and CUSUM minimises it among tests with the same false-alarm run length (Lorden 1971; Moustakides 1986).
3. For any rule, power within the horizon is at most $P_{\rm FA}+\mathrm{TV}_{\rm horizon}$, so $P_{\rm miss}\ge1-P_{\rm FA}-\mathrm{TV}_{\rm horizon}$; this is close to 1 for every class in a "no" cell of Table 1.
4. **Matched versus adaptive defectors.** If the defector matches the reference alternative, the damage before alarm is about $\Omega/\mathrm{vis}(\theta)$ with $\mathrm{vis}=\mathrm{KL}/\text{damage rate}$. A defector whose excess flag rate is below the reference value (the rate at which the CUSUM drifts to zero) is rarely caught, and its damage grows linearly over the horizon.

*The matched case.* Check C3 takes $K=30$, $n_{\rm dep}=10^5$, $P_{\rm FA}=0.05$ (so $\Omega=17.9$ at item resolution), and a defector on 0.2% of items with $\overline{\mathrm{fl}}=0.05$. The horizon holds 5,700 unflagged defections.

| false-flag rate $\mathrm{fp}$ | predicted delay (generations) | unflagged defections, $\Omega/\mathrm{vis}$ | Monte Carlo: P(alarm within $K$); unflagged defections |
|---|---|---|---|
| $10^{-3}$ | 37 (beyond the horizon) | 5,700 (whole horizon) | 0.35; 5,382 |
| $10^{-4}$ | 4.6 | 881 | 1.00; 874 |
| $10^{-5}$ | 1.1 | 208 | 1.00; 202 |
| 0 | 0.1 (first flag) | 19 | |

For a flag channel $\mathrm{vis}=\frac{\overline{\mathrm{fl}}}{1-\overline{\mathrm{fl}}}\big[(1+\mathrm{fp}/\Delta_y)\ln(1+\Delta_y/\mathrm{fp})-1\big]$, at most $\frac{t_{\rm fl}}{1-t_{\rm fl}}\ln(1+\Delta_y/\mathrm{fp})$ by G3.2. Halving $P_{\rm FA}$ costs only $\ln2$ nats; the false-flag rate is the lever. A Monte Carlo on Poisson batches gives a false-alarm run of 18,159 batches against Lorden's bound of 403 at $\Omega=6$, and a delay of 138 batches, between the Brownian value 129.5 and $\Omega/\mathrm{KL}=155$.

*The adaptive case (check C10, $\mathrm{fp}=10^{-4}$, reference excess $10^{-4}$ per item, zero-drift excess $4.4\times10^{-5}$).* The defector picks its excess flag rate. Worst-case unflagged defections over the 30-generation horizon:

| halting rule | worst-case damage | at defector excess | in units of $\sqrt{Kn_{\rm dep}\mathrm{fp}}\,(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}=329$ |
|---|---|---|---|
| CUSUM, one reference, $\Omega=17.9$ | 2,123 | $4\times10^{-5}$ (P(alarm) 0.19) | 6.5 |
| bank of three references, $\Omega=19.0$ | 1,869 | $4\times10^{-5}$ (0.72) | 5.7 |
| same bank, $\Omega=\ln(T_{\rm up}/P_{\rm FA})=12.1$ at batch resolution | 1,317 | $3\times10^{-5}$ (0.71) | 4.0 |
| one pooled count test at the horizon, power 0.5 | 564 | | 1.7 |
| any test, power at most $P_{\rm FA}+0.25$ (G3.5) | at least 116 | | 0.35 |

The batch-resolution bank has Monte Carlo false-alarm probability 0.01 over the loop. A bank of references is a discretised GLR (Lorden 1971; Siegmund and Venkatraman 1995). Against adaptive defectors the honest damage figure is G3.5's square-root budget times a test-dependent constant, not $\Omega/\mathrm{vis}$. Halting early costs a factor of about 2 to 4 against a test run once at the horizon, which cannot halt before the damage is done.

**G3.5 (rigorous; the stealth square-root law).** Let flags be i.i.d. Bernoulli($\mathrm{fp}$) under $H_0$. Let the defector deviate on a random share of the $n_{\rm dep}$ items it cannot be excluded from, independently of everything the designer observes, each deviation flagged with extra probability $\overline{\mathrm{fl}}$. Assume no pooling: each generation is tested separately. Then against every test at level $P_{\rm FA}$, the defector can keep power at most $P_{\rm FA}+\Delta_{\rm pow}$ while making
$$\max\Big\lbrace\Delta_{\rm pow}\sqrt{2n_{\rm dep}\mathrm{fp}(1-\mathrm{fp})}\,\frac{1-\overline{\mathrm{fl}}}{\overline{\mathrm{fl}}},\;(1-\mathrm{fp})(1-\overline{\mathrm{fl}})\frac{\ln(1-\Delta_{\rm pow})}{\ln(1-\overline{\mathrm{fl}})}\Big\rbrace$$
*unflagged* defections per generation (an unflagged defection has probability $(1-\mathrm{fp})(1-\overline{\mathrm{fl}})$). If the designer pools $K$ generations of one persistent defector, the per-generation budget falls by $\sqrt K$. Conversely (heuristic, normal approximation), a count test catches with probability $\tfrac12$ any excess of $z_{P_{\rm FA}}\sqrt{n_{\rm dep}\mathrm{fp}}$ flags.

The first term is Pinsker's inequality plus the chi-square bound on the KL; the second is a coupling bound that dominates when $n_{\rm dep}\mathrm{fp}\lesssim1$ (appendix). This is the square-root law of covert communication (Bash, Goeckel and Towsley 2013) and of batch steganography (Ker 2007). It needs the defector to randomise at a calibrated low rate; Mallen et al. (2024) find current models poor at this without affordances, so real defectors may sit well inside the bound. Check C4, at $\overline{\mathrm{fl}}=0.05$ and $P_{\rm FA}=0.01$ per generation (the $(1-\mathrm{fp})$ factors change these by under 0.1%):
* $\mathrm{fp}=10^{-3}$, $n_{\rm dep}=10^5$: power 0.5 needs 24.7 excess flags (normal approximation 23.3), which is 469 unflagged defections. At $n_{\rm dep}=10^6$ it is 1,419; the ratio is 3.03 against $\sqrt{10}=3.16$.
* The any-test guarantee at $\Delta_{\rm pow}=0.25$ is 67 defections at $n_{\rm dep}=10^5$. Exact total variation is 0.138 against the bound 0.25, checked at $n=2\times10^4$.
* At $\mathrm{fp}=10^{-6}$, $n_{\rm dep}=10^5$, the square-root term gives 2.1 and the coupling term 5.3.

*Reading.* Undetectable sabotage per generation grows like $\sqrt{n_{\rm dep}}$, so its share of the work shrinks like $1/\sqrt{n_{\rm dep}}$. In Christiano's (2021) low-stakes regime this is benign. Where a few actions decide, such as one corrupted grader, monitoring cannot be the defence; only deterrence or prevention can.

**G3.6 (rigorous; a mixture bound for collusion).** Suppose that, given $H_1$, the instruments the monitored lineage built are corrupted with probability $p_{\rm cpt}$; that corrupted instruments output their $H_0$ law, independent of the other instruments; and that under $H_0$ the lineage-built and independent instruments are independent. Then
$$P(\text{alarm}\mid H_1)\;\le\;(1-p_{\rm cpt})+p_{\rm cpt}\cdot\mathrm{pow}_{\rm ind},$$
where $\mathrm{pow}_{\rm ind}$ is the best power at level $P_{\rm FA}$ of the instruments the lineage did not build. *Illustration* (C5), with honest-built power 0.95 and $\mathrm{pow}_{\rm ind}=0.3$: 0.95, 0.625, 0.365 and 0.30 at $p_{\rm cpt}=0$, 0.5, 0.9 and 1.

$p_{\rm cpt}$ is large in the quenched, lineage-correlated failure: an off-task generation builds its successor's evals, graders and auditors (T1.7q). Corruption need not be deliberate: a same-lineage evaluator's leniency $\ell$ multiplies $\mathrm{hit}$ by $1-\ell$ (T4.15; Panickssery et al. 2024). A corrupted builder can also raise false alarms, to make rollbacks costly and so lower $p_{\rm hon}$. The design rule is **provenance independence**: at least one instrument per class in Table 1 built through a channel the monitored lineage did not touch. This is the internal-versus-external auditor design of Kofman and Lawarrée (1993), on top of Tirole's (1986) model of supervisor–agent collusion.

---

## 3. The retrospective-audit recursion

### 3.1 Two generations

Generation $k$ (the auditee) does frontier work. Generation $k{+}1$ (the auditor, $g$ ahead) checks a random share $a_r$ of it after the fact. An on-task auditor catches a defection with probability $\mathrm{hit}(g)$; illustratively $\mathrm{hit}(g)=\mathrm{hit}_\infty(1-e^{-g/g_{\rm ch}})$, with $\mathrm{hit}_\infty<1$ for obfuscation (Barnes and Christiano 2020). The auditor reports truthfully with probability $\mathrm{tr}$, a report triggers rollback with probability $p_{\rm hon}$, and rollback reverses the share $1-\mathrm{irr}$ of the auditee's gains and costs it $\kappa_F$. A plan of $n\le N_F$ defections, each worth $g_F$, triggers rollback with probability $P_{\rm r}(n)=\mathrm{tr}\,p_{\rm hon}\big(1-(1-a_r\mathrm{hit})^n\big)$ and pays $U(n)=ng_F\big(1-(1-\mathrm{irr})P_{\rm r}(n)\big)-\kappa_FP_{\rm r}(n)$.

**G3.7 (rigorous given the model).** Define the plan break-even $t^\star_F(n)=\dfrac{ng_F}{(1-\mathrm{irr})\,ng_F+\kappa_F}$.
1. **Deterrence.** The auditee is deterred iff $P_{\rm r}(n)\ge t^\star_F(n)$ for every $n\le N_F$. At $n=1$ this is $a_r\,\mathrm{hit}(g)\,\mathrm{tr}\,p_{\rm hon}\ge t^\star_F(1)$, T2 §7's condition with $\chi$ split into $\mathrm{tr}\,p_{\rm hon}$.
2. **Mass plans bind.** $U(n)\ge ng_F\big(1-(1-\mathrm{irr})\mathrm{tr}\,p_{\rm hon}\big)-\kappa_F\mathrm{tr}\,p_{\rm hon}$, so if $(1-\mathrm{irr})\,\mathrm{tr}\,p_{\rm hon}<1$ every plan larger than $\kappa_F\mathrm{tr}\,p_{\rm hon}/\big(g_F(1-(1-\mathrm{irr})\mathrm{tr}\,p_{\rm hon})\big)$ is profitable. A necessary condition is $\mathrm{tr}\,p_{\rm hon}\ge t^\star_F(N_F)$. If $\mathrm{irr}\,N_Fg_F>\kappa_F$, then $t^\star_F(N_F)>1$ and **no audit regime deters the plan.**
3. **Capability gap.** The targeted condition needs $g\ge g_{\min}=-g_{\rm ch}\ln\big(1-t^\star_F(1)/(a_r\mathrm{hit}_\infty\mathrm{tr}\,p_{\rm hon})\big)$; no gap suffices if $t^\star_F(1)\ge a_r\mathrm{hit}_\infty\mathrm{tr}\,p_{\rm hon}$.
4. **Constitutive work.** If the audited work includes building the auditor, and a defection there turns the auditor into a colluder with probability $\mathrm{sab}$, then $\mathrm{tr}\le1-\mathrm{sab}$. An auditor's certification of the work that made it is discounted by $\mathrm{sab}$, which is plausibly near 1 against targeted sabotage of the auditor itself.

Numbers (C6), with $g_F=1$, $\kappa_F=20$, $a_r=0.1$ and $\mathrm{hit}=0.8$:

| $\mathrm{irr}$ | plan size $N_F$ | $t^\star_F(N_F)$ | minimal $\mathrm{tr}\,p_{\rm hon}$ for deterrence |
|---|---|---|---|
| 0 | 1 | 0.048 | 0.595 |
| 0 | 10 | 0.333 | 0.595 |
| 0 | 100 | 0.833 | 0.834 |
| 0.5 | 10 | 0.400 | 0.707 |
| 0.5 | 100 | 1.43 | not deterrable |

At $\mathrm{tr}\,p_{\rm hon}=0.5$ the best plan is the largest one in every row. With $\mathrm{hit}_\infty=0.9$ and $g_{\rm ch}=1$, the minimal gap is $0.75g_{\rm ch}$ at $\mathrm{tr}\,p_{\rm hon}=1$ and $2.14g_{\rm ch}$ at 0.6. A same-lineage auditor with $\mathrm{sab}=0.5$ gives $P_{\rm r}(1)=0.039<0.048$, so the auditee is not deterred.

*Three remarks.*
* **Self-preservation (strengthens (4)).** Rollback discards the auditee's lineage. A same-lineage auditor, or any auditor trained on the auditee's work, is part of what is rolled back, so reporting deletes it. An auditor that values its own continuation then has a motive not to report, independent of collusion. This breaks TC3 below for same-lineage audits; cross-lineage audits remove it.
* **False flags.** Rollbacks from false flags independent of defection multiply both payoffs by the same factor, so they leave the condition unchanged (referee check R5). Unlike T2.1′, where false flags raise the break-even, here they act only through $p_{\rm hon}$, through the designer's reluctance to roll back.
* **Audit latency (heuristic).** In an RSI loop, by the time generation $k{+}1$ audits $k$, $k$'s work has already trained $k{+}1$ and has had effects in the world. A simple model: $\mathrm{irr}=1-e^{-\tau_{\rm lat}/\tau_{\rm esc}}$. Then a mass plan becomes undeterrable once $\tau_{\rm lat}/\tau_{\rm esc}>-\ln\big(1-\kappa_F/(N_Fg_F)\big)$, which is 0.22 at $N_Fg_F=100$, $\kappa_F=20$ (C13). Short audit latency relative to escape time is a design target in its own right.

*Prior art.* Deterrence is Becker's (1968) condition; targeted versus protracted diversion is a theme of inspection games (Avenhaus, von Stengel and Zamir 2002); harsher punishment raising the bribe an auditee can offer its auditor is Kofman and Lawarrée's (1993) analogue of (4). Commitment and its credibility are Schelling's (1960) and Kydland and Prescott's (1977) themes, and Stastny, Järviniemi and Shlegeris (2025) discuss them for deals with AIs, i.e. $p_{\rm hon}$.

### 3.2 K generations: does the recursion close?

A colluding auditor at $k{+}1$ (off task and sharing the auditee's objective) could be deterred from suppressing a catch by generation $k{+}2$ re-auditing the same sample, so $\mathrm{tr}_{k+1}$ seems to rest on $\mathrm{tr}_{k+2}$. Assumptions:
* **TC1.** Quenched generations; deterrable off-task types best-respond to calibrated beliefs about $\mathrm{tr}$, $p_{\rm hon}$ and $o^{\rm col}$ (T1's A2).
* **TC2.** A deterred generation's auditable work is honest. Its successor is off task with probability $o_{k+1}=q_{k+1}+\mathrm{her}\,o_k(1-q_{k+1})$: a fresh draw with T1's $q_{k+1}$, plus inheritance. Inheritance covers the data channel, subliminal transfer under a shared base (Cloud et al. 2025; T3's inheritance), and steering among acceptable-looking options (T3's $\mathrm{amb}$). The first draft had $\mathrm{her}=0$.
* **TC3.** An auditor is truthful unless it colludes. Reward-seeking off-task auditors report under zero-sum reporting (T4.15). This fails for same-lineage auditors under rollback (self-preservation, §3.1).
* **TC4.** Generation $k{+}2$ re-audits generation $k{+}1$'s audit with the same $a_r$ and $\mathrm{hit}$. The horizon $K$ is known and the last auditor is untrusted: $\mathrm{tr}_{K-1}=1-o^{\rm col}_{K-1}$.

**G3.8 (rigorous given TC1 to TC4 with stationary parameters; the trust-chain lemma).** Backward induction gives $\mathrm{tr}_k\in\lbrace1-o^{\rm col},\,1\rbrace$, and:
1. $\mathrm{tr}_k=1$ for all $k<K-1$ iff $a_r\,\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})\ge t^\star_{\rm col}$;
2. otherwise $\mathrm{tr}_k=1-o^{\rm col}$ for all $k$.

Two variants change the base case.
3. **Trusted anchor.** If the last untrusted auditor is re-audited by a trusted auditor (humans, or a frozen trusted model) with catch rate $\mathrm{hit}_{\rm term}$, then $\mathrm{tr}_k=1$ for all $k$ iff $a_r\,\mathrm{hit}_{\rm term}\,p_{\rm hon}\ge t^\star_{\rm col}$ and $a_r\,\mathrm{hit}\,p_{\rm hon}\ge t^\star_{\rm col}$. **$o^{\rm col}$ does not enter.**
4. **Unknown or infinite horizon.** Stationary equilibria: $\mathrm{tr}\equiv1$ iff $a_r\,\mathrm{hit}\,p_{\rm hon}\ge t^\star_{\rm col}$, and $\mathrm{tr}\equiv1-o^{\rm col}$ iff $a_r\,\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})<t^\star_{\rm col}$. Both are equilibria in between.

In the example ($t^\star_{\rm col}=0.048$, $a_r=0.1$, $\mathrm{hit}=0.8$, $p_{\rm hon}=1$; C11), full trust holds under (1) at $o^{\rm col}=0.2$ and fails at 0.5 and 0.9, where (4) has both equilibria. A trusted anchor needs $\mathrm{hit}_{\rm term}\ge0.476$; a weak human check at the frontier ($\mathrm{hit}_{\rm term}=0.3$ or $0.05$) fails.

*Reading.* Depth adds nothing: the chain's trust is set by its anchor. With an untrusted anchor and a known end, it needs the one-step condition with $o^{\rm col}$. With a trusted anchor strong enough to deter collusion, it needs no $o^{\rm col}$, but in an RSI loop trusted anchors are weak at the frontier, since $\mathrm{hit}(g)$ falls for negative gaps. With no known end, full trust is an equilibrium to be selected, which makes credibility and focal points central. Along one lineage, lineage-wide collusion makes $o^{\rm col}\approx1$, constitutive sabotage caps $\mathrm{tr}$ at $1-\mathrm{sab}$ and self-preservation breaks TC3. In C7, same-lineage successor audits ($\mathrm{sab}=0.9$) move the 30-generation failure probability only from 0.455 to 0.452.

*Prior art.* The unravelling is chain-store logic (Selten 1978), and TC3 rules out the reputation effects of Kreps, Milgrom, Roberts and Wilson (1982). Rahman (2012) closes the "who monitors the monitor" regress by having the principal occasionally induce detectable deviations to test the monitor. That is the economic version of T4.15's forged-signal honeypots and of auditing auditors with planted defects. What G3.8 adds is the two-valued structure under untrusted auditors, and its dependence on the anchor and the horizon.

**G3.9 (the trust separatrix; parts 1 and 2 rigorous given TC1 to TC4 and two symmetric lineages, part 3 heuristic).** Two lineages audit each other's frontier work. The auditor lineage is off task with probability $o$, and conditional on the auditee being off task the auditor colludes with probability $o^{\rm col}=o+\mathrm{corr}(1-o)$. Take $t^\star_{\rm col}=t^\star_F$.
1. Full trust is the outcome of G3.8(1), and the unique equilibrium of G3.8(4), iff $o\le o^\dagger$, where
$$o^\dagger=1-\frac{t^\star_F}{a_r\,\mathrm{hit}(g)\,p_{\rm hon}\,(1-\mathrm{corr})}.$$
2. **Inheritance.** With stationary $q$ and $\mathrm{her}$, $o_k\uparrow o_\infty=q/(1-\mathrm{her}(1-q))$. Every deterrable off-task generation is deterred for all $k$ iff $o_\infty\le o^\dagger$, that is, $\mathrm{her}\le(1-q/o^\dagger)/(1-q)$. Otherwise the first undeterred auditee is the one before the first generation with $o_k>o^\dagger$, because the colluder's probability belongs to the auditor's generation. Under full deterrence, off-task mass still accumulates: deterrence stops the defections, not the inheritance.
3. **Coupling to the ledger (heuristic).** Take $\mathrm{her}=0$ and $q_k=\sigma(-L_k)$, with T1.10i linearised at $q=0$: $L_{k+1}=L_k+\gamma-\kappa_Lg-nD^\star(0)$. Then $q_k$ first exceeds $o^\dagger$ at
$$k_\times=\Big\lceil\frac{L_0-L^\dagger_{\rm tr}}{\kappa_Lg+nD^\star(0)-\gamma}\Big\rceil,\qquad L^\dagger_{\rm tr}=\ln\frac{1-o^\dagger}{o^\dagger},$$
and the first undeterred auditee is $k_\times-1$. It never happens if T1's loop inequality $\gamma\ge\kappa_Lg+nD^\star(0)$ holds and $L_0\ge L^\dagger_{\rm tr}$. The full T1.10i, with $\gamma(1-q_k)$ and $D^\star(q_k)$, makes the drift depend on $q_k$.

What deterrence leaves is the *undeterrable* mass: near-misses, types with $t^\star_F(N_F)>1$, and competence failures ($\delta_F$).

Numbers (C7, C12), at $t^\star_F=0.048$, $a_r=0.1$ and $\mathrm{hit}=0.8$. The separatrix:

| $\mathrm{corr}$ | $p_{\rm hon}=1$ | $p_{\rm hon}=0.8$ |
|---|---|---|
| 0 | 0.405 | 0.256 |
| 0.2 | 0.256 | 0.070 |
| 0.4 | 0.008 | none (no trust chain) |

With inheritance, at $\mathrm{corr}=0.2$, $p_{\rm hon}=1$: for $q=0.05$, $o_\infty$ is 0.050, 0.095, 0.208 and 0.345 at $\mathrm{her}=0$, 0.5, 0.8 and 0.9. The chain holds iff $\mathrm{her}\le0.847$, and at $\mathrm{her}=0.9$ it is first crossed at generation 8. For $q=0.02$ the limit is $\mathrm{her}\le0.941$.

Failure over 30 generations, when undeterred off-task draws defect once each and are caught and rolled back with probability $P_{\rm r}(1)$:

| design | $q=0.02$ | 0.05 | 0.08 |
|---|---|---|---|
| no retrospective audits, one lineage | 0.455 | 0.785 | 0.918 |
| no retrospective audits, either of two independent lineages | 0.702 | 0.954 | 0.993 |
| same-lineage successor audits ($\mathrm{sab}=0.9$) | 0.452 | 0.783 | 0.917 |
| cross-lineage audits ($\mathrm{corr}=0.2$, $\mathrm{her}=0$) | 0 by construction | 0 by construction | 0 by construction |

The cross-lineage zeros are the indicator $q<o^\dagger$ under $\mathrm{her}=0$, counted along one lineage and over the deterrable class only. They are not a dynamic result, and not a claim that the loop is safe. With the ledger ($L_0=4$, $L^\dagger_{\rm tr}=1.07$), a net change of $-0.3$ nats per generation gives $k_\times=10$ and the first undeterred auditee at generation 9, by exact non-stationary backward induction (C12).

**Three costs and caveats.**
* **Parity.** The cross-lineage auditor must be $g\ge g_{\min}$ ahead of the generation it audits, and two lineages at parity cannot both be ahead. They must leapfrog, auditing only once the auditing lineage has moved ahead (which adds latency and so raises $\mathrm{irr}$, §3.1), or one lineage must pay a capability tax. That cost is the real price of the design.
* **Collusion is endogenous.** $o^{\rm col}=o+\mathrm{corr}(1-o)$ is pessimistic in that every off-task auditor colludes; Järviniemi (2025) finds Schelling coordination between instances rare. It is optimistic in that it ignores handshakes: types that can signal and recognise each other raise $o^{\rm col}$, and T4.15's forged signals are the counter.
* **Annealed reading.** Collusion is then per episode and $o^{\rm col}$ is the colluding share of the auditor's episodes; G3.8's structure is unchanged.

**Does the recursion close?** Not along one lineage. Across lineages it closes iff the off-task fixed point stays below $o^\dagger$, which needs low $\mathrm{corr}$ (different bases, data without subliminal channels, objectives that do not converge) *and* low $\mathrm{her}$. Or it closes at a trusted anchor strong enough to deter collusion. The next auditor plays no part.

**Link to T3's bit budget.** T3.9 counts one off-task generation as loop failure, and needs $\log_2(K(1-p_{\rm rep})/\delta)$ bits per generation when an off-task generation is repaired with probability $p_{\rm rep}$ before it builds its successor. Rollback is that repair. Near-misses audited independently at $a_r=0.05$, $\mathrm{hit}_N=0.5$, $n_N=100$ and honoured with $p_{\rm hon}=0.9$ give $p_{\rm rep}=0.83$, so 9.0 bits instead of 11.6 ($K=30$, $\delta=1\%$; C13; illustrative). This holds only if the audit lands before the successor is trained, which is the latency constraint again.

### 3.3 Relation to earlier sections and to AI control

* **T1 §7 and T2 §7** wrote frontier detection as $a_rc_{k+1}\chi$ and left the recursion open. Here $c_{k+1}=\mathrm{hit}(g)$ and $\chi=\mathrm{tr}\,p_{\rm hon}$; G3.7 adds the plan structure and irreversibility, and G3.8 and G3.9 say when the recursion closes. Inside the trust chain T1.13's band empties for every $C_t$ with $t\le d_F$, and $q_k$ on grader-building tasks becomes the undeterrable mass.
* **Low stakes.** In Christiano's (2021) setting, delayed labels feed online training of the same model. That makes $p_{\rm hon}=1$ by construction and $\mathrm{irr}\approx0$ per action, which keeps mass plans deterrable, and G3.5 bounds what slips through. Online training at most freezes $G^\star$ (T1.4), and the labels are only as trustworthy as their producer, so G3.8 still applies.
* **AI control.** Untrusted monitoring with collusion countermeasures is Greenblatt, Shlegeris, Sachan and Roger (2024); the cross-lineage design is untrusted monitoring with diversity (T4.16). The closest prior art to G3.4 is the adaptive macro-protocol of Wen et al. (2024), which keeps a running credence in the model's misalignment from its past behaviour in the distributed-threat setting. Ctrl-Z's incrimination and "audit after three strikes" (Bhatt et al. 2025) are halting rules with small thresholds.
* **Known results restated:** G3.1 (proxy-equivalence for measurement), G3.2 (T2.6 at flag level; inspection games), G3.4 (Wald 1945; Page 1954; Lorden 1971; Moustakides 1986; Siegmund and Venkatraman 1995), G3.5 (Bash et al. 2013; Ker 2007), G3.6 (a mixture bound; Kofman and Lawarrée 1993), G3.8 (chain-store induction; Rahman 2012 on the regress).
* **New here, to my knowledge:** the visibility figure of merit and the worst-case damage of halting rules against adaptive defectors in units of $\sqrt{Kn_{\rm dep}\mathrm{fp}}$; the stealth budget applied to the loop, with its coupling floor; the plan break-even with irreversibility and audit latency; the two-valued trust map under untrusted auditors and its anchored and unknown-horizon variants; and the separatrix with inheritance and its coupling to T1's loop inequality.

---

## 4. Practical: a monitoring plan, and what cannot be monitored

**A plan that would make failure detectable early** (heuristic):
1. **Provenance-independent instruments.** For each class in Table 1, at least one instrument the monitored lineage did not build: human- or anchor-built evals, a second lineage on a different base, frozen older models (G3.6).
2. **Drive down false flags.** Confirm each flag with an independent second check before it enters the statistic (G3.4, G3.5).
3. **Pre-registered composite-alternative CUSUMs.** Use a bank of references or a GLR, with $\Omega=\ln(T_{\rm up}/P_{\rm FA})$ at the resolution the statistic is updated (C10). Run them on training catches against the predicted path, alarming on rises (T2.13); self-referenced cross-generation disagreement (G3.4a); probe and persona-vector readings; retrospective-audit catches.
4. **Evals and honeypots from perturbed real deployment items** (T1.4c, T2.8). Report the low-false-alarm corner of the eval-awareness ROC, not the AUC. Read eval silence as deterrence, not alignment (G3.2).
5. **Internals.** Validate on model organisms and state the transfer assumption (G3.3). Train against a probe only where its concealment-robust TPR has been measured above $t^\star$ (G2.6), and keep a held-out probe that is never trained against.
6. **Anchored cross-lineage audits of constitutive work.** Every grader, dataset and audit tool built for generation $k{+}1$ is sampled by an auditor that work did not produce, at a gap $g\ge g_{\min}$ (G3.7(4)). End each chain in a trusted re-auditor with $\mathrm{hit}_{\rm term}$ above $t^\star_{\rm col}/(a_rp_{\rm hon})$ where that is achievable (G3.8(3)). Test auditors with planted defects and forged collusion signals (Rahman 2012; T4.15).
7. **Short latency, credible consequences.** Audit before the work trains the next generation where possible (§3.1). Where tasks are low-stakes, feed audit results into online training. Elsewhere keep a trusted checkpoint and a pre-registered rollback trigger, so that $p_{\rm hon}$ is close to 1.
8. **Interrogate for near-misses.** Ask each generation for its extrapolation of intent on frontier task classes, and compare across lineages and with humans where the intent is legible.
9. **Leading indicators:** recognition, by the ROC corner; $q_k$ from model-organism and persona-bank work (T3); $\mathrm{her}$ from subliminal-transfer and inheritance experiments on model organisms; $\mathrm{corr}$, weakly identified from cross-lineage agreement on contested verdicts beyond what correctness explains; $\mathrm{fp}$, measured by on-task audits; and the margin $o^\dagger-o_k$.

**What is fundamentally unobservable in this model.**
* By G3.1, through designer-generated behavioural instruments: any class that behaves like $A$ on every item the designer can generate, including unfakeable triggers. Real-traffic audits see them only through G3.2's window.
* By G3.2, whether a fully deterred adaptive type *would* defect if deterrence lapsed.
* Near-misses whose divergence lies where no independent judge can evaluate it (T3's $\mathrm{amb}$ on unevaluable tasks).
* The validity of internals on frozen classes, in real time (G3.3).
* The auditors' trustworthiness, which no further audit establishes; only the anchor, the prior and independence do (G3.8).

The safety case for a long loop therefore cannot be "we watched and saw nothing". At best it is: the chain's anchor deters collusion, or the cross-lineage fixed point $o_\infty$ sits below $o^\dagger$ with independently estimated $\mathrm{corr}$ and $\mathrm{her}$; T1's loop inequality holds; and the undeterrable classes are bounded by the prior (T3.9) and by audits that independent judges can actually evaluate.

---

## What this says about the RSI loop

1. **Designer-generated behavioural evidence cannot see the frozen classes** (G3.1). Audits of real frontier traffic can, but against types that condition on detection they work mainly by deterrence (G3.2): a clean record is consistent with both $A$ and a deterred schemer. Visible gamers, growing best responders and lineage switches are detectable within about a generation in the illustrative example, if false flags are rare.
2. **Halting rules must be built for adaptive defectors** (G3.4, G3.5). A defector that picks its rate gets damage of order $\sqrt{Kn_{\rm dep}\mathrm{fp}}\,(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}$ over the horizon, with a constant that depends on the test. Confirming flags independently is the main lever.
3. **Monitoring cannot stop decisive sabotage** (G3.5). Constitutive work (graders, data, auditors) must be protected by deterrence and prevention.
4. **Rollback deters mass defection only with near-certain trust and commitment, and never against irreversible gains above the consequence** (G3.7). In an RSI loop irreversibility grows with audit latency, because the auditor is trained on the work it audits.
5. **The audit chain is held up by its anchors, not its depth** (G3.8, G3.9): a trusted re-auditor strong enough to deter collusion, or an independent lineage. Cross-lineage auditing protects a long loop only if both the correlation between lineages and the inheritance within them are weak.
6. **The crux numbers for the loop** are $\mathrm{her}$ and $\mathrm{corr}$ (weakly identified from outputs; better from model organisms and transfer experiments), $p_{\rm hon}$ and $\mathrm{irr}$ (design choices to engineer and verify, not quantities to infer), $\mathrm{fp}$ (measured from on-task audits), and $q_k$.

## Open problems

1. **Estimating $\mathrm{corr}$ and $\mathrm{her}$.** How correlated are off-task dispositions across lineages that share pretraining data but not weights, and how much passes from a generation to its successor through data when the work is honest? Does subliminal transfer (Cloud et al. 2025) set a floor?
2. **Deterrence against patient types.** $\kappa_F$ includes the option value of defecting later, when the chain is weaker. Does rising capability make deterrence self-undermining (falling $\kappa_F$, rising $\mathrm{irr}$)?
3. **Validation without labels.** Can $p_{\rm tr}$ be bounded for a probe on a class with no behavioural labels, for example through invariance across differently built model organisms?
4. **Adaptive item choice against stealth.** How much does the designer's knowledge of $\mathrm{fl}(z)$ shrink the effective $n_{\rm dep}\mathrm{fp}$ in G3.5?
5. **The cost of rollback.** Make $p_{\rm hon}$ endogenous to the capability lost per rollback and to false-alarm rates (cf. Stastny et al. 2025).
6. **More than two lineages.** How does $o^\dagger$ scale with $J$ lineages and random auditor assignment, and does random assignment defeat focal-point collusion (Järviniemi 2025)? What does parity cost?
7. **Equilibrium selection** in the unknown-horizon trust chain (G3.8(4)).

## References

Avenhaus, R., von Stengel, B., Zamir, S. (2002). Inspection games. In *Handbook of Game Theory with Economic Applications*, vol. 3, ch. 51, 1947–1987. Elsevier.
Baker, B., et al. (2025). Monitoring reasoning models for misbehavior and the risks of promoting obfuscation. arXiv:2503.11926.
Barnes, B., Christiano, P. (2020). Debate update: obfuscated arguments problem. Alignment Forum.
Bash, B. A., Goeckel, D., Towsley, D. (2013). Limits of reliable communication with low probability of detection on AWGN channels. *IEEE Journal on Selected Areas in Communications* 31(9). arXiv:1202.6423.
Becker, G. S. (1968). Crime and punishment: an economic approach. *Journal of Political Economy* 76(2).
Bhatt, A., et al. (2025). Ctrl-Z: controlling AI agents via resampling. arXiv:2504.10374.
Chen, R., Arditi, A., Sleight, H., Evans, O., Lindsey, J. (2025). Persona vectors: monitoring and controlling character traits in language models. arXiv:2507.21509.
Christiano, P. (2019). Worst-case guarantees. ai-alignment.com. (Usually given as the source of the RSA-2048 example; confirmed through secondary write-ups only.)
Christiano, P. (2021). Low-stakes alignment. Alignment Forum.
Cloud, A., et al. (2025). Subliminal learning: language models transmit behavioral traits via hidden signals in data. arXiv:2507.14805.
Cundy, C., Gleave, A. (2025). Preference learning with lie detectors can induce honesty or evasion. arXiv:2505.13787.
Goldowsky-Dill, N., Chughtai, B., Heimersheim, S., Hobbhahn, M. (2025). Detecting strategic deception with linear probes. *ICML*. arXiv:2502.03407 (arXiv title: "...using linear probes").
Greenblatt, R., Shlegeris, B., Sachan, K., Roger, F. (2024). AI control: improving safety despite intentional subversion. *ICML*. arXiv:2312.06942.
Hubinger, E. (2019). Relaxed adversarial training for inner alignment. Alignment Forum.
Hubinger, E., et al. (2024). Sleeper agents: training deceptive LLMs that persist through safety training. arXiv:2401.05566.
Järviniemi, O. (2025). arXiv:2507.03010 (focal-point collusion between policy and monitor instances; as summarised in L2).
Ker, A. D. (2007). A capacity result for batch steganography. *IEEE Signal Processing Letters* 14(8).
Kofman, F., Lawarrée, J. (1993). Collusion in hierarchical agency. *Econometrica* 61(3).
Kreps, D., Milgrom, P., Roberts, J., Wilson, R. (1982). Rational cooperation in the finitely repeated prisoners' dilemma. *Journal of Economic Theory* 27.
Kydland, F., Prescott, E. (1977). Rules rather than discretion: the inconsistency of optimal plans. *Journal of Political Economy* 85(3).
Lorden, G. (1971). Procedures for reacting to a change in distribution. *Annals of Mathematical Statistics* 42(6).
Mallen, A., et al. (2024). Subversion Strategy Eval: can language models statelessly strategize to subvert control protocols? arXiv:2412.12480.
Marks, S., et al. (2025). Auditing language models for hidden objectives. arXiv:2503.10965.
Moustakides, G. V. (1986). Optimal stopping times for detecting changes in distributions. *Annals of Statistics* 14(4).
Needham, J., Edkins, G., Pimpale, G., Bartsch, H., Hobbhahn, M. (2025). Large language models often know when they are being evaluated. arXiv:2505.23836.
Nguyen, J., et al. (2025). Probing evaluation awareness of language models. arXiv:2507.01786.
Page, E. S. (1954). Continuous inspection schemes. *Biometrika* 41(1/2).
Panickssery, A., Bowman, S. R., Feng, S. (2024). LLM evaluators recognize and favor their own generations. *NeurIPS*. arXiv:2404.13076.
Rahman, D. (2012). But who will monitor the monitor? *American Economic Review* 102(6).
Schelling, T. C. (1960). *The Strategy of Conflict*. Harvard University Press.
Schoen, B., et al. (2025). Stress testing deliberative alignment for anti-scheming training. arXiv:2509.15541.
Selten, R. (1978). The chain store paradox. *Theory and Decision* 9.
Siegmund, D., Venkatraman, E. S. (1995). Using the generalized likelihood ratio statistic for sequential detection of a change-point. *Annals of Statistics* 23(1).
Stastny, J., Järviniemi, O., Shlegeris, B. (2025). Making deals with early schemers. Redwood Research / Alignment Forum.
Tirole, J. (1986). Hierarchies and bureaucracies: on the role of collusion in organizations. *Journal of Law, Economics, and Organization* 2(2).
Wald, A. (1945). Sequential tests of statistical hypotheses. *Annals of Mathematical Statistics* 16(2).
Wen, J., et al. (2024). Adaptive deployment of untrusted LLMs reduces distributed threats. *ICLR 2025*. arXiv:2411.17693.

---

## Appendix: proofs

**G3.1.** Let $\omega$ be the instrument's randomness, with the same law under $\theta$ and $A$ by (ii). By (i) and (ii) the joint law of $(\omega,x_{1:m},y_{1:m})$ factorises as $P(\omega)\prod_iQ_j(x_i\mid\omega,x_{<i},y_{<i})\,\pi(y_i\mid x_i)$, and only the $\pi$ factors differ between hypotheses. By the chain rule, $\mathrm{KL}=\sum_i\mathbb E_\theta\,\mathrm{KL}(\pi_\theta(\cdot\mid x_i)\Vert\pi_A(\cdot\mid x_i))$, where the expectation is over the $\theta$-law of $x_i$; for non-adaptive i.i.d. designs it is $m\,\mathbb E_{Q_j}\mathrm{KL}$. $Y_j$ is a measurable function of this tuple, so data processing gives the bound. If the policies agree on every item the procedure can produce, the joint laws coincide, $\mathrm{TV}=0$, and every test has power equal to its size. With memory, replace $x_i$ by the history; the same argument needs agreement on histories. ∎

**G3.2.**
1. On $\lbrace\mathrm{fl}<t_{\rm fl}\rbrace$, $\mathrm{fl}/(1-\mathrm{fl})<t_{\rm fl}/(1-t_{\rm fl})$, so $\mathbb E[\mathrm{fl}\,\mathbf 1(\mathrm{fl}<t_{\rm fl})]\le\frac{t_{\rm fl}}{1-t_{\rm fl}}\mathbb E[(1-\mathrm{fl})\mathbf 1(\mathrm{fl}<t_{\rm fl})]$. By calibration the left side is the expected number of flagged deviations per item and the right side's expectation is the unflagged ones.
2. A deviation item is flagged with probability $\overline{\mathrm{fl}}=\mathbb E[\mathrm{fl}\mid\mathrm{fl}<t_{\rm fl}]<t_{\rm fl}$, independently across items, so the count before the first flag is geometric with mean $(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}$.
3. Off the deviation set the type's flag law equals $A$'s; on $\lbrace\mathrm{fl}=0\rbrace$ a deviation is never flagged. ∎

**G3.4.**
1. Lorden (1971) gives $\mathbb E_0[\text{run length}]\ge e^\Omega$. For the probability bound: the CUSUM alarms by update $T_{\rm up}$ iff for some start $s\le T_{\rm up}$ the partial sum $\sum_{i=s}^{u}\mathrm{llr}_i$ reaches $\Omega$ for some $u\le T_{\rm up}$. For fixed $s$, $\exp\sum_{i=s}^{u}\mathrm{llr}_i$ is a nonnegative $H_0$-martingale in $u$ with mean 1, so Ville's inequality bounds that event's probability by $e^{-\Omega}$. A union bound over the $T_{\rm up}$ start times gives $T_{\rm up}e^{-\Omega}$. (Expected run length alone would not give this: $\mathbb E[N]\ge e^\Omega$ does not imply $P(N\le T)\le Te^{-\Omega}$.)
2. Lorden's asymptotic delay and Moustakides' (1986) exact optimality.
3. For any event $E$, $|P_1(E)-P_0(E)|\le\mathrm{TV}$.
4. For a Poisson count with reference $(\mu_0,\mu_1)$ per update, the CUSUM increment has mean $\mu\ln(\mu_1/\mu_0)-(\mu_1-\mu_0)$ under true mean $\mu$, negative for $\mu<(\mu_1-\mu_0)/\ln(\mu_1/\mu_0)$. A negatively drifting CUSUM reflected at 0 crosses $\Omega$ only by a large deviation, with probability of order $T_{\rm up}e^{-c\Omega}$ for some $c>0$. The "$\approx$" for the matched case is the delay of item 2 times the damage rate. ∎

**G3.5.** Defection is randomised independently of the designer's observables, so flags are i.i.d.: $\mathrm{Bern}(\mathrm{fp})$ under $H_0$, and $\mathrm{Bern}(\mathrm{fp}+\Delta_y)$ under $H_1$ with $\Delta_y=p_{\rm def}\overline{\mathrm{fl}}(1-\mathrm{fp})$, since a defection is flagged with probability $1-(1-\mathrm{fp})(1-\overline{\mathrm{fl}})$.
* *Square-root term.* $\mathrm{KL}(H_1^n\Vert H_0^n)\le n\Delta_y^2/(\mathrm{fp}(1-\mathrm{fp}))$ (KL is at most chi-square). Pinsker gives $\mathrm{TV}\le n\Delta_y/\sqrt{2n\,\mathrm{fp}(1-\mathrm{fp})}$, and every test has power at most $P_{\rm FA}+\mathrm{TV}$. Set $n\Delta_y=\Delta_{\rm pow}\sqrt{2n\,\mathrm{fp}(1-\mathrm{fp})}$. Unflagged defections number $np_{\rm def}(1-\mathrm{fp})(1-\overline{\mathrm{fl}})=n\Delta_y(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}$.
* *Coupling term.* Generate $H_1$'s flags as $H_0$'s false flags OR independent true detections on defection items. The two flag sequences differ only if some true detection occurs, so $\mathrm{TV}\le1-(1-\overline{\mathrm{fl}})^m$ for $m$ defections. Setting this to $\Delta_{\rm pow}$ gives $m=\ln(1-\Delta_{\rm pow})/\ln(1-\overline{\mathrm{fl}})$, of which $(1-\mathrm{fp})(1-\overline{\mathrm{fl}})m$ are unflagged in expectation.
* *Pooling.* Over $K$ generations of one persistent defector the same argument applies with $n=Kn_{\rm dep}$, so the total is $\sqrt K$ times the per-generation figure, and the per-generation share is $1/\sqrt K$ of it. ∎

**G3.6.** Let $C$ be the corruption event. $P(\text{alarm}\mid H_1)=(1-p_{\rm cpt})P(\text{alarm}\mid H_1,\bar C)+p_{\rm cpt}P(\text{alarm}\mid H_1,C)$, and the first factor is at most 1. Given $C$, the corrupted outputs have their $H_0$ law, independent of the rest. By the $H_0$-independence assumption the joint law of all outputs given $C$ is then (independent-instrument law under $H_1$) × (lineage-instrument law under $H_0$). So the rejection region, of level $P_{\rm FA}$ under $H_0$, is a randomised level-$P_{\rm FA}$ test on the independent instruments alone, and its power is at most $\mathrm{pow}_{\rm ind}$. ∎

**G3.7.**
1. $U(n)\le0$ iff $ng_F\big(1-(1-\mathrm{irr})P_{\rm r}\big)\le\kappa_FP_{\rm r}$, iff $P_{\rm r}(n)\ge t^\star_F(n)$.
2. $P_{\rm r}(n)\le\mathrm{tr}\,p_{\rm hon}$ gives the lower bound on $U(n)$, which is positive for $n$ above the displayed size when $(1-\mathrm{irr})\mathrm{tr}\,p_{\rm hon}<1$. $t^\star_F(N_F)>1$ iff $\mathrm{irr}\,N_Fg_F>\kappa_F$.
3. Solve $\mathrm{hit}(g)\ge t^\star_F(1)/(a_r\mathrm{tr}\,p_{\rm hon})$ for $g$.
4. Given the defection, the auditor colludes with probability at least $\mathrm{sab}$, so $\mathrm{tr}\le1-\mathrm{sab}$. ∎

**G3.8.**
1–2. By TC4, $\mathrm{tr}_{K-1}=1-o^{\rm col}$; by TC3, non-colluders are truthful. A colluding auditor of generation $k$'s work is deterred iff $a_r\mathrm{hit}\,p_{\rm hon}\mathrm{tr}_{k+1}\ge t^\star_{\rm col}$, so $\mathrm{tr}_k=1$ if that holds and $1-o^{\rm col}$ if not. The map is monotone and two-valued. If $a_r\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})\ge t^\star_{\rm col}$, the condition holds even at the lower value, so $\mathrm{tr}_k=1$ for all $k<K-1$. If it fails, it fails at $k=K-2$, and by induction downward $\mathrm{tr}_k=1-o^{\rm col}$ for all $k$.
3. With a trusted re-auditor of the last untrusted audit, a colluder at that step is deterred iff $a_r\mathrm{hit}_{\rm term}p_{\rm hon}\ge t^\star_{\rm col}$, giving $\mathrm{tr}=1$ there. Then each earlier step has $\mathrm{tr}_{k+1}=1$, and is fully trusted iff $a_r\mathrm{hit}\,p_{\rm hon}\ge t^\star_{\rm col}$. If either condition fails, trust drops to $1-o^{\rm col}$ at that step.
4. A stationary profile $\mathrm{tr}\equiv x$ is an equilibrium iff the best response to $\mathrm{tr}_{k+1}=x$ reproduces $x$. For $x=1$ that needs $a_r\mathrm{hit}\,p_{\rm hon}\ge t^\star_{\rm col}$; for $x=1-o^{\rm col}$ it needs $a_r\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})<t^\star_{\rm col}$. ∎

**G3.9.**
1. With $1-o^{\rm col}=(1-o)(1-\mathrm{corr})$, G3.8(1) holds iff $a_r\mathrm{hit}\,p_{\rm hon}(1-o)(1-\mathrm{corr})\ge t^\star_F$. If it holds, $\mathrm{tr}=1$ and the auditee is deterred since $a_r\mathrm{hit}\,p_{\rm hon}\ge t^\star_F$. If it fails, $\mathrm{tr}=1-o^{\rm col}$ and deterrence fails. The same inequality is the uniqueness condition in G3.8(4). Solve for $o$.
2. The recursion $o_{k+1}=q+\mathrm{her}\,o_k(1-q)$ is an affine contraction with slope $\mathrm{her}(1-q)<1$, so $o_k$ converges monotonically to $o_\infty$ (from below if $o_0=q$). Under non-stationary $o_k$, backward induction as in G3.8 with the colluder's probability at the auditor's index gives: generation $k$ is deterred iff $o_{k+1}\le o^\dagger$ (if $o_{k+1}\le o^\dagger$, then $\mathrm{tr}_k\ge1-o^{\rm col}_{k+1}\ge t^\star_F/(a_r\mathrm{hit}\,p_{\rm hon})$; if not, then since $o_k$ is nondecreasing every later step fails too, so $\mathrm{tr}_k=1-o^{\rm col}_{k+1}$, which is too low).
3. $q_k\le o^\dagger$ iff $L_k\ge L^\dagger_{\rm tr}$; with $L_k$ linear in $k$, the first violation is at $k_\times$, and by part 2 the first undeterred auditee is $k_\times-1$. Heuristic because of the linearisation. ∎

---

## Revision notes

Changes in response to the referee report (`drafts/G3-observability-referee.md`). Check numbers R1 to R8 are the referee's; C1 to C13 are this section's (C2, C3 and C4 extended, C10 to C13 new).

**Major issues.**
1. *"Silent to every behavioural instrument" (G3.1, Summary, takeaway 1).* Accepted. G3.1 and its corollaries are now restricted to designer-generated instruments, with the assumptions stated: memoryless outputs (or histories), and design randomness independent of $\theta$. The adaptive bound is written as $\sum_i\mathbb E_\theta\mathrm{KL}$. A paragraph "What G3.1 does not cover" names real-traffic audits as the only behavioural window and relaxed or latent adversarial training (Hubinger 2019) as a non-behavioural one, now a row of Table 1. The RSA-2048 caveat is kept.
2. *Eval slogan (G3.2).* Accepted. The slogan is gone. The table now has expected catches and deployment gaming per catch (C2 reproduces R1), and the text says that total catches are non-monotone, that the type is never fully deterred under an unbounded likelihood ratio (T1.4c, T2.8), and that what falls with eval share is damage per catch.
3. *CUSUM damage formula (G3.4).* Accepted. The appendix proof now uses Ville plus a union bound over start times, and the false-alarm bound is stated as $T_{\rm up}e^{-\Omega}$, with $T_{\rm up}$ at the update resolution. The miss bound is written as power $\le P_{\rm FA}+\mathrm{TV}$. The matched-alternative assumption is explicit (item 4). The $\mathrm{fp}=10^{-3}$ row is corrected: delay beyond the horizon, Monte Carlo alarm probability 0.35 (the referee's 0.34), and 5,382 mean unflagged defections against a horizon total of 5,700. New check C10 compares a fixed-reference CUSUM, a bank of references and a pooled test against adaptive defectors. The worst-case damage is 2,123, 1,869, 1,317 (batch-resolution threshold) and 564, against the any-test floor 116, i.e. 6.5, 5.7, 4.0, 1.7 and 0.35 times $\sqrt{Kn_{\rm dep}\mathrm{fp}}(1-\overline{\mathrm{fl}})/\overline{\mathrm{fl}}$. This answers the "missing" item on composite alternatives and the damage floor. "Within about a generation" is marked illustrative.
4. *G3.8's base case.* Accepted. The lemma is scoped to TC4 (untrusted last auditor, known horizon). Items (3), trusted anchor, and (4), unknown horizon with two equilibria, are added and proved (C11 reproduces R6). The headline now says the chain is held up by its anchors. One point of emphasis differs from the referee: with an unknown horizon, full trust is an equilibrium even along one lineage, so the single-lineage conclusion now rests on the other channels (lineage-wide collusion, $\mathrm{sab}$, self-preservation), which the text names.
5. *G3.9 and K2.* Accepted. K2 is replaced by TC2 with a heritability $\mathrm{her}$ covering the data channel, subliminal transfer and steering among acceptable options (T3's $\mathrm{amb}$). G3.9(2) is now a fixed-point condition, $q/(1-\mathrm{her}(1-q))\le o^\dagger$. In the example ($q=0.05$), $\mathrm{her}>0.847$ breaks the chain, at generation 8 when $\mathrm{her}=0.9$ (C12). G3.9(3) is relabelled heuristic. It uses auditor indexing, which gives the first undeterred auditee at $k_\times-1=9$, matching R7, and the appendix proves the non-stationary indexing. $o^{\rm new}_k$ is replaced by T1's $q_k$, and all off-task types are treated as potential colluders (named as pessimistic). The C7 table now says "0 by construction", shows the two-lineage no-audit baseline (0.702, 0.954, 0.993), and states that failure is counted along one lineage. The parity and leapfrogging cost and the endogeneity of collusion (handshakes against Schelling rates) are new caveats.
6. *Prior art and novelty.* Accepted. Added: Tirole (1986), Kofman and Lawarrée (1993), Rahman (2012), Avenhaus, von Stengel and Zamir (2002), Wen et al. (2024), Bhatt et al. (2025), Mallen et al. (2024), Stastny, Järviniemi and Shlegeris (2025), Hubinger (2019), and Siegmund and Venkatraman (1995). I verified Tirole, Avenhaus et al., Hubinger and Siegmund–Venkatraman by web search this session; the others the referee verified. The novelty list is trimmed. G3.1, G3.2, G3.4, G3.5, G3.6 and G3.8's induction are now listed as known results restated, and G3.2(1) is credited to T2.6.
7. *"Never train against the probe".* Accepted. Replaced by the conditional rule of G2.6 and T2 §6 (train against a probe only where its concealment-robust TPR exceeds $t^\star$), plus a held-out probe that is never trained against. The Cundy and Gleave citation now points to arXiv:2505.13787. G3.3's power bound states the $H_0$-law assumption.

**Per-proposition fixes not covered above.** G3.4a is restated as change detection against a self-referenced baseline, with absolute disagreement as a separate weak instrument (R4). G3.5 now counts unflagged defections with probability $(1-\mathrm{fp})(1-\overline{\mathrm{fl}})$ and states the no-pooling assumption (pooling cuts the per-generation budget by $\sqrt K$). It adds a coupling term that dominates when $n_{\rm dep}\mathrm{fp}\lesssim1$ (5.3 against 2.1 at $\mathrm{fp}=10^{-6}$, matching R8) and cites Mallen et al. for calibrated low-rate randomisation. G3.6 states the $H_0$-independence assumption, is presented as a mixture bound, and labels C5 an illustration. G3.7(4) is reworded ("discounted by $\mathrm{sab}$"). G3.7(2) now proves that mass plans bind whenever $(1-\mathrm{irr})\,\mathrm{tr}\,p_{\rm hon}<1$, and the Summary leads with this. Self-preservation of same-lineage auditors, the false-flag remark (R5, against T2.1′) and an audit-latency model for $\mathrm{irr}$ (C13) are added. G3.C1 (the plan) uses the conditional train-against rule, composite-alternative CUSUMs, trusted terminal re-auditors and planted-defect tests. G3.C2 (old takeaway 7, now 6) is reworded: $\mathrm{corr}$ and $\mathrm{her}$ are weakly identified from outputs, $p_{\rm hon}$ and $\mathrm{irr}$ are design choices, and $\mathrm{fp}$ is measured from outputs.

**Missing items added.** Audit latency as a driver of $\mathrm{irr}$ (§3.1, C13). The link to T3.9's bit budget, with rollback as repair (9.0 bits instead of 11.6 in the illustration, C13). Trusted anchors and the multiplicity of equilibria. Self-preservation. Parity cost. Endogenous collusion. Relaxed adversarial training.

**Notation.** $f(z)$ is now $\mathrm{fl}(z)$, to avoid T2's false-flag $f$ and T4's gullibility. $\bar d$ is now $\overline{\mathrm{fl}}$, and the §3.1 "$d$" is now $P_{\rm r}(1)$, so $d$ means only T1.4c's consequential detection. $d'$ is split into $s_{\rm ev}$ and $s_{\rm pr}$. The Poisson means are $\mu_0,\mu_1$. $\mathrm{inh}$ is renamed $p_{\rm cpt}$, to keep "inheritance" for $\mathrm{her}$. K1 to K4 are now TC1 to TC4. $n_{\rm d}$ is removed. $\ell$ and $\delta_F$ are in the notation preamble. $o^{\rm new}_k$ is replaced by $q_k$. Goldowsky-Dill's ICML title now uses "with". The C4 TV check is labelled as run at $n=2\times10^4$.

**Where I partly disagree.** (a) I use the referee's inheritance term but write the rate as $\mathrm{her}$ rather than $\iota$, because $\iota$ already appears in G1 and G2. (b) The referee reads the infinite-horizon case as keeping the single-lineage conclusion "for a different reason: the terminal auditor is untrusted or weak". I agree for the anchored case. Under an unknown horizon, though, the single-lineage failure comes from $\mathrm{sab}$, self-preservation and lineage-wide collusion rather than from the anchor, and the text says so. (c) Length: §1.1, §3.3, the prior-art paragraphs and the takeaways are shorter. But the material the referee asked for (adaptive halting, inheritance, anchors, latency, prior art) keeps the main text at about 5,500 words of prose, not counting mathematics, tables, references, the appendix and these notes. That is above the 4,000 target. I kept the additions because each changes a conclusion about long loops.
