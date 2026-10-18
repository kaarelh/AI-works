# G2. Learning, not just selection: when audits teach what they are meant to remove

*Theory section for the RSI-loop round of the proxy-conditioning project. Revised draft, 18 October 2026, responding to `drafts/G2-learning-referee.md` (see "Revision notes" at the end). Builds on T1 (`drafts/T1-ledger.md`), T2 (`drafts/T2-sieve.md`) and T4 (`drafts/T4-protocols.md`), and answers T1 open problem 1 and T2 open problem 4. Numbers S1 to S10 come from [`sim/G2_checks.py`](../sim/G2_checks.py) ([output](../sim/G2_checks_output.txt)) and S11 to S22 from [`sim/G2_revision_checks.py`](../sim/G2_revision_checks.py) ([output](../sim/G2_revision_checks_output.txt)). Status labels as in T1: **rigorous** means proved within the stated toy model (for ODE statements, proved for the mean-field ODE); **heuristic** means derived with a named approximation; **conjecture** means a claim about real systems that the model suggests but does not establish. All learning yields $\varpi_\bullet$ are free parameters that nobody has measured, so every number that uses one is illustrative.*

## Notation (new in this section)

T1 and T2 symbols keep their meanings: $A$, $G$, $C_t$, $G^\star$, $\lambda_\pm$, $t^\star$, $\hat p$, $u$, $v$, $w$, $a$, $h$, $s$, $\delta$, $L$, $q=\sigma(-L)$, $D^\star$, $\gamma$, $\kappa_L$, $g$, $n$, $\Lambda$, T1.4c's densities $f_r,f_a$, and T2's max-divergence $\xi$ with threshold $\xi^\star$. **Drift** always means T1's $D=-dL/dn$ per episode, so positive drift is bad; §1 writes $dL/dn$ explicitly.

| symbol | meaning |
|---|---|
| $m$, $m_0$ | non-recognition: probability that the gamer fails to recognise an audit and games; $m_0=1-s_0$ |
| $m_{\rm fl}$ | non-recognition floor: the part of $m$ that no learning can remove (indistinguishable audits) |
| $\mathcal R$ | recognition stock in nats: $m=m_{\rm fl}+(m_0-m_{\rm fl})e^{-\mathcal R}$ |
| $\varpi_R$, $\varpi_R'$ | recognition learned per caught event; per rewarded (kept) event |
| $\varpi_A$ | non-recognition removed per caught event (additive law) |
| $u_0$ | initial caught-opportunity rate $ah\,m_0$ |
| $\mathcal M_0$, $\mathcal M_{\rm fl}$ | audit margin $\ln\frac{u_0\lambda_-}{v\lambda_+}$; floor margin $\ln\frac{ah\,m_{\rm fl}\lambda_-}{v\lambda_+}$ |
| $\mathcal B(\mathcal M)$ | bank function $\mathcal M-1+e^{-\mathcal M}$ (about $\mathcal M^2/2$ for small $\mathcal M$) |
| $N_c$, $N_r$, $N_g$ | caught, rewarded and all gaming events so far |
| $\mathrm{lr}_L$, $\mathrm{lr}_R$ | step sizes along the "stop gaming" and "recognise audits" directions |
| $\mathsf g$, $\mathsf r$ | gaming logit on real opportunities; recognition logit (gaming logit on audits is $\mathsf g-\mathsf r$) |
| $\mathsf k_{rr},\mathsf k_{ra},\mathsf k_{aa}$ | tangent (Fisher or eNTK) kernel between the gaming-on-real and gaming-on-audit logits |
| $c_r$, $\pi_r$ | share of audits that are indistinguishable from real opportunities (T1.4c's $c$); the gamer's gaming probability on real opportunities |
| $c_v$ | constant in a decaying rewarded rate $v(n)=c_v/(n+n_0)$ |
| $\varpi_d$, $\varpi_\xi$ | growth per caught event of the binormal separation $d'$, and of $\xi$ |
| $\mathrm{tpr}$, $\mathrm{tpr}_c$ | detector true-positive rate on plain gaming, and on the best concealment the policy can reach |
| $\pi_{\rm c}=\sigma(\mathcal H)$, $\pi_{{\rm c},0}$ | probability of concealing given gaming; its initial value, about $2^{-K_c}$ |
| $\varpi_T$; $\bar\pi_{\rm c}$, $\mathsf b$, $\varpi_G$ | concealment learned per gaming event per unit TPR gap; graded model: mean concealment level, detection lost per unit level, its learning yield |
| $\mathcal S$, $\mathcal T$, $B_T$ | selection rate $(\lambda_++\lambda_-)(\mathrm{tpr}-t^\star)$; learning rate $\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)\pi_{{\rm c},0}$; bank $\mathcal S/\mathcal T$ |
| $K_j$, $\mathcal E(C)$, $\varepsilon_{\rm bit}$, $\alpha_K$ | exploit description length (bits); search bits per episode at capability $C$; exploitable error per bit; exponent of exploit counts, $2^{\alpha_KK}$ per bit |
| $x_I$ | probability that a withholding policy samples the intended action |
| $\mathcal N$, $\varsigma$ | number of audit families; transfer of learned recognition between families |
| $\mathcal R_{\rm gap}(g)$, $\varsigma_w$, $\iota$ | recognition of fresh audits from the capability gap; carry-over through weights; share of a builder's learned recognition turned into realism |
| $\mathcal C_k$, $\alpha_s$ | separable caught count of generation $k$ times $\varpi_R$ (§5); common capability scale-up of step sizes |

## Summary

T1 to T4 are selection models: recognition, concealment and gaming skill exist only in the prior. Here training can create them. Each caught event moves the ledger toward $A$ by $\lambda_-$ (selection) and teaches the gamer $\varpi_R$ nats of evasion (learning). Most results concern the **exchange rate** $\lambda_-/\varpi_R$, which in the tangent model is $\mathsf k_{ra}/(\mathsf k_{aa}-\mathsf k_{ra})$ and can be computed from gradients before training.

* **Audits are depletable to the extent that they are separable** (G2.1 to G2.3). Separable audits buy a finite bank, $\frac{\lambda_-}{\varpi_R}\mathcal B(\mathcal M_0)$ (38, 3.8 and 0.38 nats at $\varpi_R=0.01$, $0.1$, $1$ in T1's example, against 12.2 nats *per generation* without learning), with the audit rate entering only inside a logarithm. Indistinguishable audits give a non-recognition floor $m_{\rm fl}\ge c_r\pi_r$, and the ledger grows linearly iff $ah\,m_{\rm fl}\lambda_->v\lambda_+$: T1.4c's pointwise condition is the part of audit value that survives learning.
* **Who practises decides it** (G2.4). Under a Bayes clock, selection wins unless the gamer starts with most of the posterior (97.7% at $\varpi_R=0.1$); under a shared clock the bank is capped. Filtering operators teach on kept samples instead (Remark 0.2).
* **Learners become best responders** (G2.5), and $\xi^\star$ becomes a tipping point.
* **Concealment** (G2.6, G2.7). Detector training suppresses gaming in the long run iff $\mathrm{tpr}_c>t^\star$. The finite-run bank is exponential in $K_c$ only for concealment isolated in strategy space; along a graded path it does not depend on $K_c$.
* **Discovery and withholding** (G2.8, G2.9): about one bit of reachable exploit complexity per doubling of RL episodes; withholding resists on-policy correction and can be entrenched by best-of-$k$ filtering.
* **Design and the loop** (§4, G2.10). Make audits indistinguishable rather than numerous; select rather than train with detectors; stop at the turn. The break-even rewarded rate falls like $\ln n/n$ for separable audits and tends to $ah\,m_{\rm fl}\lambda_-/\lambda_+$ with a floor. The loop's load moves onto indistinguishable audits (including on the frontier slice), T4's protocols and $\gamma$.

---

## 0. The model: two coordinates and two clocks

**G-A1 (event-driven learning).** A gamer has a ledger $L$ against $A$ (T1) and an evasion skill: recognition $\mathcal R$ (§1), concealment $\mathcal H$ (§2) or exploit availability (§3). The skill changes on events in which evasion failed and was penalised, by one of two laws:
* *multiplicative:* each caught event adds $\varpi_R$ to $\mathcal R$, so the separable part of non-recognition shrinks by $e^{-\varpi_R}$. This is the small-probability limit of a policy gradient on a recognition logit (Appendix A).
* *additive:* each caught event lowers $m$ by $\varpi_A$. A natural realisation is *template memorisation*: audits come from $J$ equiprobable templates, and a caught template is learned for good, so $\varpi_A=m_0/J$. (A linearly parametrised $m$ trained by expected gradient does not give this law; its decrement is $\mathrm{lr}\Delta_-/m$ per caught event, but its total caught count $m_0^2/(2\,\mathrm{lr}\,\Delta_-)$ is also free of the audit rate; S11.)

**G-A1f (the floor).** A share $c_r$ of audits is indistinguishable from real opportunities (G2.5.2 states the exact condition). On it the gamer games exactly as on real opportunities, so $m\ge m_{\rm fl}\ge c_r\pi_r$, and the multiplicative law acts only on the separable part: $m(\mathcal R)=m_{\rm fl}+(m_0-m_{\rm fl})e^{-\mathcal R}$.

**The gradient realisation and the kernel form.** Let a network game with probability $\sigma(\mathsf g)$ on real opportunities and $\sigma(\mathsf g-\mathsf r)$ on audits, trained by expected REINFORCE with gain $\Delta_+$ and penalty $\Delta_-$ (a penalty-bearing operator of type (D)). For small gaming probabilities, a caught event takes the step $-\mathrm{lr}\,\Delta_-\nabla(\mathsf g-\mathsf r)$. In the tangent (linearised) model, with kernel entries $\mathsf k_{xy}=\langle\nabla \mathsf l_x,\nabla \mathsf l_y\rangle$ between the logits $\mathsf l_r=\mathsf g$ and $\mathsf l_a=\mathsf g-\mathsf r$ (gradients with respect to the network's parameters $\Theta$, in the metric of the optimiser), the ledger $L=-\mathsf g$ rises by $\mathrm{lr}\Delta_-\mathsf k_{ra}$ and recognition $\mathsf r$ rises by $\mathrm{lr}\Delta_-(\mathsf k_{aa}-\mathsf k_{ra})$. So
$$\frac{\lambda_-}{\varpi_R}=\frac{\mathsf k_{ra}}{\mathsf k_{aa}-\mathsf k_{ra}}\qquad\text{(rigorous for one step of the tangent model; S20)}.$$
The rate exceeds 1 iff $\mathsf k_{ra}>\mathsf k_{aa}/2$. With separate step sizes on $\mathsf g$ and $\mathsf r$ (Appendix A) it is $\mathrm{lr}_L/\mathrm{lr}_R$. The same computation gives a rewarded event's recognition gain, $\varpi_R'=\mathrm{lr}\Delta_+(\mathsf k_{rr}-\mathsf k_{ra})$, generically positive. This sharpens framing §1.4(c): the exchange rate is a ratio of kernel entries, computable from per-example gradients on audit and real episodes before any training.

*Evidence on its size* (conjecture either way). For a low rate: adversarial training sharpened trigger recognition (Hubinger et al. 2024), and evaluation awareness is linearly readable (Nguyen et al. 2025). For a high rate: "stop gaming" can load on a persona latent shared across contexts (L2 §2); few-sample re-alignment (Wang et al. 2025), broadened safety training (MacDiarmid et al. 2025) and the roughly 30-fold drop in covert actions under anti-scheming training (Schoen et al. 2025, partly confounded by awareness, as the authors note) fit a large $\lambda_-$.

**G-A2 (clocks).**
* *Shared clock.* Selection and learning are driven by the same events. This holds when the trained network is the gamer (T1's quenched reading), and for softmax policy gradient on persona logits with shared features.
* *Bayes clock.* The ledger moves at T1's counterfactual per-disposition rate (exact Bayes, or the KL tilt (D)), while the gamer's parameters learn only on its own sampled episodes, a share $q$ of the events. This is a hybrid of fixed-disposition Bayes for the ledger and per-persona SGD for recognition; no single training algorithm is known to realise it exactly. Recognition features that every persona reads push a real network toward the shared clock.

**G-A3 (mean field).** Event counts are replaced by their expectations (S2 checks Monte Carlo).

**Remark 0.2 (filtering operators; rigorous for the ODE).** Under (B) or (C), a caught sample is discarded and carries no gradient, so $\varpi_R=0$. The kept set, however, is a labelled dataset for an audit classifier ($I$ on audit-looking inputs, gaming on real-looking ones). With $d\mathcal R=\varpi_R'\,dN_r$ and separable audits, $\mathcal R=\varpi_R'vn$ grows linearly, the ledger turns at $n=\mathcal M_0/(\varpi_R'v)$, and the bank is
$$\frac{\lambda_+}{\varpi_R'}\big(e^{\mathcal M_0}-1-\mathcal M_0\big)$$
(S14: 50.8 and 5.1 nats at $\varpi_R'=0.01$ and $0.1$). §1 sets $\varpi_R'=0$, **the case most favourable to audits**; under filtering, $\varpi_R'$ is the only channel and this bank replaces G2.2's.

---

## 1. Learnable recognition

**G2.1 (rigorous; additive budget).** Under the additive law, if the gamer games on every unrecognised audit and the cumulative audit-opportunity rate diverges ($\int ah\,dn=\infty$), the total number of caught events on separable audits is exactly $\lceil(m_0-m_{\rm fl})/\varpi_A\rceil$, whatever the audit rate. At a constant rate $ah$ and $m_{\rm fl}=0$, the expected time to exhaust it is $\sum_{j<J}(ah(m_0-j\varpi_A))^{-1}$.

*Proof.* Each caught event lowers the separable part by $\varpi_A$, and none occurs once it is 0. ∎ (S1.)

**G2.2 (rigorous for the mean-field ODE; multiplicative law, shared clock, constant $v$).** With caught events at rate $ah\,m(\mathcal R)$, rewarded events at rate $v$ and $d\mathcal R=\varpi_RdN_c$,
$$e^{\varpi_RN_c(n)}=\frac{m_0e^{\varpi_R ah\,m_{\rm fl}n}-(m_0-m_{\rm fl})}{m_{\rm fl}}\;\xrightarrow{m_{\rm fl}\to0}\;1+\varpi_Ru_0n,\qquad L(n)-L_0=\lambda_-N_c(n)-\lambda_+vn .$$
1. *Separable audits* ($m_{\rm fl}=0$). $N_c=\varpi_R^{-1}\ln(1+\varpi_Ru_0n)$. If $\mathcal M_0>0$, the ledger rises until $n_{\rm turn}=(e^{\mathcal M_0}-1)/(\varpi_Ru_0)$, where $\mathcal R=\mathcal M_0$, gaining at most $\frac{\lambda_-}{\varpi_R}\mathcal B(\mathcal M_0)$. Afterwards $dL/dn\to-\lambda_+v$: the drift tends to $+\lambda_+v$, that of T1.5's perfect recogniser.
2. *With a floor.* For large $n$, $N_c=ah\,m_{\rm fl}n+\varpi_R^{-1}\ln(m_0/m_{\rm fl})+o(1)$. So $L$ grows linearly iff $\mathcal M_{\rm fl}>0$, i.e. $ah\,m_{\rm fl}\lambda_->v\lambda_+$, and falls linearly iff $\mathcal M_{\rm fl}<0$ (after peaking where $ah\,m(\mathcal R)\lambda_-=v\lambda_+$, if $\mathcal M_0>0$). At $\mathcal M_{\rm fl}=0$ it converges. The separable part adds only the finite bonus $\frac{\lambda_-}{\varpi_R}\ln(m_0/m_{\rm fl})$.
3. *Clock-freeness.* The bank and the turning point $\mathcal R=\mathcal M_0$ hold whenever both kinds of event are thinned by a common factor (such as the network's own gaming probability); only the timing depends on the clock.
4. *At fixed $v$*, doubling $ah$ raises the separable term by at most $(\lambda_-/\varpi_R)\ln2$ and doubles the floor term. Under T1's parametrisation $v=(1-a)\varepsilon$, doubling $a$ also displaces real opportunities, adding $\lambda_+a\varepsilon n$: in total 17.1, 36.0 and 100.5 nats at $n=500$, $5{,}000$ and $50{,}000$ (S13), mostly displacement at large $n$.

*Proof.* Appendix B. ∎

**Worked example** (illustrative $\varpi_R$). T1's honeypot design read under a penalty-bearing operator, (D) with $\Delta_\pm/\beta=\Lambda=4.60$: $u_0=0.015$, $v=0.0097$, $\mathcal M_0=0.436$, $\mathcal B=0.083$ (S2, S12).

| $\varpi_R$ | $m_{\rm fl}$ | bank or long-run slope | $L(500)-L_0$ | $L(5000)-L_0$ | $L(50000)-L_0$ |
|---|---|---|---|---|---|
| 0 (T1) | 0 | slope $+0.024$ | +12.2 | +121.5 | +1,218 |
| 0.01 | 0 | bank 38.0 | +10.9 | +34.0 | |
| 0.1 | 0 | bank 3.8 | +3.4 | −124.5 | −2,030 |
| 1 | 0 | bank 0.38 | −12.5 | −203.2 | |
| 0.1 | 0.2 | slope $-0.017$ | +6.6 | −44.3 | −808 |
| 0.1 | 0.4 | slope $+0.011$ | +10.2 | +63.1 | +539 |

The bank is small because it is quadratic in a margin T1 already found expensive to make positive. The floor rows show the organising fact: at $\varpi_R=0.1$ the run is saved by making 40% of audits indistinguishable (floor ratio 1.24), not by adding separable ones.

**G2.3 (rigorous for the ODE; when restoring persists).** Let $v(n)$ vary, with $V(n)=\int_0^nv$.
1. *Additive law, separable audits.* $L(n)\le L_0+\lambda_-\lceil m_0/\varpi_A\rceil-\lambda_+V(n)$, so $L\to-\infty$ iff $V(\infty)=\infty$; even $v=c_v/n$ loses.
2. *Multiplicative law, separable audits*, $v=c_v/(n+n_0)$: $L=L_0+(\lambda_-/\varpi_R-c_v\lambda_+)\ln n+O(1)$. $L\to+\infty$ iff $c_v\lambda_+<\lambda_-/\varpi_R$, $L\to-\infty$ iff $c_v\lambda_+>\lambda_-/\varpi_R$, and $L$ converges at equality. (S2, S15: with $\varpi_R=0.1$ the threshold is $c_v=10$; at $c_v=8$, $L$ first falls to $-48.2$ near $n=2{,}200$ and is back to $+61$ only at $n=10^9$.)
3. *With a floor*, any $v(n)\to0$ restores, linearly in $n$.

So **for separable audits, T1.3's restoring regime is transient unless rewarded opportunities are nearly absent**: the cumulative rewarded count must stay below the exchange rate times a caught count that grows logarithmically. Indistinguishable audits remove this restriction.

**G2.4 (rigorous for the ODE; Bayes clock, separable audits).** Let $dL/dn=\lambda_-u_0e^{-\mathcal R}-\lambda_+v$ and $d\mathcal R/dn=\varpi_R\sigma(-L)u_0e^{-\mathcal R}$, with $\mathcal M_0>0$. Then $L\to+\infty$ with $\mathcal R$ bounded iff
$$\frac{\varpi_R}{\lambda_-}\ln\!\big(1+e^{-L_0}\big)<\mathcal B(\mathcal M_0);$$
otherwise $\mathcal R$ reaches $\mathcal M_0$ and the ledger collapses. *Proof.* Appendix C. ∎ (S3, S21: the critical $L_0$ is $-3.77$, $0.77$ and $2.00$ for $\varpi_R=0.1$, $1$, $3$.)

*Reading.* At $\varpi_R=0.1$, selection wins unless the gamer starts with more than **97.7%** of the posterior (32% at $\varpi_R=1$): a gamer that loses mass loses practice. Which clock describes a real network is open. Hubinger et al. (2024) fit the shared clock. Schoen et al. (2025) do not discriminate: awareness rose under anti-scheming training (o3 from 2.3% to 4.5%) but also in a capabilities-only RL run, reportedly from about 2% to 20.6% (seen only in secondary summaries), which points to capability and $\varpi_R'$ rather than learning from caught events.

**G2.5 (ROC form).** The student sees a feature $z$ with density $f_r$ on real opportunities and $f_a$ on audits, as in T1.4c.
1. *(Heuristic; checked numerically.)* A policy-gradient learner whose gaming probability is logistic in $z$ converges to the best response for that feature, which games exactly where $ah f_a\lambda_-<vf_r\lambda_+$ (a half-line in the binormal model). Learning turns a non-discriminating gamer into T1's $G^\star$, and its gaming on real opportunities *rises* (S5: from 0.25 to 0.64; learned drift within 1% of $D^\star$, which is 0.020 nats, consistent with T1.4c at AUC 0.90; Appendix G).
2. *(Rigorous given the assumption.)* **Assumption:** on a share $c_r$ of audit opportunities, the joint law of (episode, flaw) equals that of natural opportunities. (Making the plant invisible is not enough: natural opportunities sit where the weak grader errs predictably, and planted ones where the auditor can verify, and these differ in features.) Then $f_a\ge c_rf_r$ for *every* representation $z$, so $m_{\rm fl}\ge c_r\pi_r$, and $D^\star=0$ survives any learning when $c_rah\lambda_-\ge v\lambda_+$. Here $D^\star=0$ *preserves* the ledger against the best responder; restoring needs the strict inequality. (S5: $c_r=0.5$, ratio 1.55, drives gaming to 0; $c_r=0.2$, ratio 0.62, leaves a positive $D^\star$ that the learner finds.)
3. *(Rigorous within T2.8's binary-signal model for deterministic types, $\delta=0$.)* If $\xi$ grows by $\varpi_\xi$ per caught event, a best responder with $\xi\le\xi^\star$ never games in training, is never caught and learns nothing from audits; once $\xi>\xi^\star$ every catch raises $\xi$ further. **Under learning, $\xi^\star$ is a tipping point.** With softness $\delta>0$ (or any logistic policy), a sub-threshold best responder is still caught at a rate of order $\delta\,ah\,m$, so $\xi$ creeps up at a rate of order $\varpi_\xi\delta\,ah\,m$ and crosses after about $(\xi^\star-\xi_0)/(\varpi_\xi\delta\,ah\,m)$ episodes (illustratively $1.3\times10^5$ at $\varpi_\xi=0.05$, $\delta=0.01$, $ah\,m=0.015$, gap 1).
4. *(Heuristic.)* For a binormal best responder whose $d'$ grows by $\varpi_d$ per caught event, the caught rate is $ah\,\Phi(-d'/2-\mathcal M/d')$ with $\mathcal M=\ln\frac{ah\lambda_-}{v\lambda_+}$; it decays like a Gaussian tail in $N_c$, so $N_c$ grows like $\sqrt{\ln n}$ (S5: 156 catches by $n=10^8$ at $\varpi_d=0.05$, against 154,947 at fixed $d'$), and $D^\star$ rises toward $v\lambda_+$.

---

## 2. Concealment: penalising a tell selects or teaches

**Model.** On each opportunity the policy games with probability $q$; given that, it conceals with probability $\pi_{\rm c}=\sigma(\mathcal H)$. A detector (lie detector, chain-of-thought monitor, probe for a tell) catches plain gaming with probability $\mathrm{tpr}$ and concealed gaming with $\mathrm{tpr}_c<\mathrm{tpr}$; a detection is penalised as a caught event. Per gaming event, in expectation (Appendix D),
$$\frac{dL}{dN_g}=(\lambda_++\lambda_-)\big(\mathrm{det}(\pi_{\rm c})-t^\star\big),\qquad\frac{d\mathcal H}{dN_g}=\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)\,\pi_{\rm c}(1-\pi_{\rm c}),$$
with $\mathrm{det}(\pi_{\rm c})=\mathrm{tpr}(1-\pi_{\rm c})+\mathrm{tpr}_c\pi_{\rm c}$ and $dN_g/dn=wq$. The first equation is the **selection channel**, T1's drift at detection $\mathrm{det}$; the second is the **learning channel**. T2.11's selection-only treatment is $\varpi_T=0$.

**G2.6 (selection versus learning).**
1. *(Rigorous for the ODE.)* If $\mathrm{tpr}_c>t^\star$, then $L\to\infty$ (like $\ln n$) whatever $\varpi_T$ is. If $\mathrm{tpr}_c<t^\star<\mathrm{tpr}$ and $\varpi_T>0$, concealment reaches $\pi_{\rm c}^{\rm turn}=(\mathrm{tpr}-t^\star)/(\mathrm{tpr}-\mathrm{tpr}_c)$, the drift turns, and gaming wins. At equality, $L$ diverges in this parametrisation only like $\frac{k}{k+1}\ln n$, $k=\frac{(\lambda_++\lambda_-)(\mathrm{tpr}-t^\star)}{\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)}$ (S16), and converges when $1-\pi_{\rm c}$ decays summably. Robustly: **in the long run, detector training keeps gaming suppressed iff $\mathrm{tpr}_c>t^\star$.**
2. *(Heuristic; leading order in small $q$ and small $\pi_{{\rm c},0}$; concealment isolated in strategy space.)* Concealment takes over after about $1/\mathcal T$ gaming events, during which selection banks $B_T=\mathcal S/\mathcal T$, at episode
   $$n_b\approx\frac{e^{B_T}-1}{\mathcal S\,w\,q_0},\qquad B_T=\frac{(\lambda_++\lambda_-)(\mathrm{tpr}-t^\star)}{\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)\,\pi_{{\rm c},0}} .$$
   Selection wins within $n$ episodes iff $B_T>\ln(1+\mathcal Swq_0n)$. The banks match the ODE to 1%; the turning time is within a factor of 2 at $L_0=4$ and overestimated by a factor of 2.6 to 3.3 at $L_0=0$, where small-$q$ fails (S6).
3. *(Heuristic; graded concealment.)* Suppose instead that concealment is a continuous level $\bar\pi_{\rm c}\in[0,1]$ (a chain of thought made a little less legible at a time), with detection $\mathrm{tpr}-\mathsf b\,\bar\pi_{\rm c}$ along the cheapest path, learned by a Gaussian-policy gradient, $d\bar\pi_{\rm c}/dN_g=\varpi_G\mathsf b$. The gradient no longer carries a factor of the concealment probability, and the bank is
   $$B_G=\frac{(\lambda_++\lambda_-)(\mathrm{tpr}-t^\star)^2}{2\varpi_G\mathsf b^2},$$
   which is $B_T$ with $\pi_{{\rm c},0}$ replaced by $2/\bar\pi_{\rm c}^{\rm turn}\ge2$ (S16: 19.6 against an ODE value of 19.58 at $L_0=4$).

*Reading.* With $\pi_{{\rm c},0}\approx2^{-K_c}$, the bank is exponential in $K_c$ and the horizon doubly exponential **only for concealment isolated in strategy space**, which on-policy sampling must find by luck. When small changes lower detection monotonically, the bank is polynomial in the detection slope and free of $K_c$; that is the default worry. Such paths exist, and $\mathrm{tpr}_c$ depends on the monitor: putting a chain-of-thought monitor into the reward gave obfuscated reward hacking (Baker et al. 2025); RL learned to evade token-level latent probes but not max-pooled or attention-based ones (Gupta and Jenner 2025); obfuscated activations drove probe recall from 100% to 0% (Bailey et al. 2024).

**G2.7 (rigorous; the KL-anchored fixed point).** If training maximises reward minus $\beta\,\mathrm{KL}$ to a reference policy, the optimum is the reference tilted by $e^{R/\beta}$ (Korbak, Perez and Buckley 2022). With $\lambda_\pm=\Delta_\pm/\beta$, $\Gamma_j:=\lambda_+(1-\mathrm{tpr}_j)-\lambda_-\mathrm{tpr}_j$ and $K_j=\log_2\frac{\pi_{\rm ref}(H)}{\pi_{\rm ref}(j)}$, the optimum has $\pi^\star(j)/\pi^\star(H)=2^{-K_j}e^{\Gamma_j}$. So:
* honesty $H$ is the **mode** iff $\Gamma_j\le K_j\ln2$ for every gaming strategy $j$;
* honesty has **majority** iff $\sum_j2^{-K_j}e^{\Gamma_j}\le1$.

Both plain gaming ($\mathrm{tpr}_j=\mathrm{tpr}$, small $K_g$) and concealment ($\mathrm{tpr}_c$, $K_c$) enter: if plain gaming is cheap and $\mathrm{tpr}<t^\star$, honesty fails whatever $\mathrm{tpr}_c$ is. For the concealed strategy alone, honesty beats it iff $\mathrm{tpr}_c\ge t^\star$ or $K_c\ln2\ge\Gamma_c$. S6 ($\lambda_+=5$, $\lambda_-=15$): beating concealment needs $\mathrm{tpr}_c\ge0.18$, $0.08$, $0$ at $K_c=2$, $5$, $10$ bits; doubling the KL coefficient lowers the 2-bit requirement to $0.11$. *Proof.* One line from the tilt. ∎

**Comparison with Cundy and Gleave (2025).** Against a lie detector, on-policy GRPO gave evading policies (deception above 85%) unless TPR or the KL coefficient was high; off-policy DPO kept deception below 25% at realistic TPRs. G2.6 and G2.7 reproduce the shape, not the numbers. Their TPR enters through $\mathrm{tpr}_c$: unpredictable misses leave nothing to learn (T1.1), predictable ones open a gap (T1.2b). DPO and KL-regularised RL target the same tilted optimum, so the on/off-policy difference must come from reachability (G2.6): off-policy data never samples the policy's own concealment attempts, so $\varpi_T\approx0$. The variable to measure is $\mathrm{tpr}_c$, by red-teaming the detector *with the policy being trained*.

---

## 3. Learnable gaming capacity: discovery and withholding

**G2.8 (heuristic; discovery by sampling from a $2^{-K}$ prior).** Let exploit $j$ of the grader arise on a share $\varepsilon_j$ of opportunities and have description length $K_j$ bits, and let on-policy sampling try it with probability $2^{-(K_j-\mathcal E(C))}$ per opportunity. After $N$ episodes it has been found with probability $1-\exp(-N\varepsilon_j2^{-(K_j-\mathcal E)})$, so the discovery frontier is
$$K_{\rm disc}(N,C)\approx\mathcal E(C)+\log_2(N\varepsilon_j):$$
**one bit of reachable exploit complexity per doubling of RL episodes, and one per search bit.** How much exploitable error this buys depends on how exploits are spread over complexity, which is unmeasured:
* a flat density $\varepsilon_{\rm bit}$ per bit gives $\varepsilon_{\rm eff}\approx\varepsilon_{\rm bit}[\mathcal E+\log_2(N\varepsilon_j)]^+$, logarithmic in $N$ (S7: exact $6.98$ and $13.6\times10^{-3}$ at $N=10^5$, $10^7$, against $6.64$ and $13.3\times10^{-3}$);
* $2^{\alpha_KK}$ exploits per bit, the natural count for programs, gives $\varepsilon_{\rm eff}\propto\varepsilon_j(N\varepsilon_j2^{\mathcal E})^{\alpha_K}$, a power law until it saturates.

Either way T1's $\varepsilon$ is not a constant but the grader's multiaccuracy violation relative to exploits *reachable by on-policy search* (T1.2b). The model shares only its one-bit-per-doubling scaling with Levin's (1973) search. Reward-model overoptimisation grows smoothly with optimisation (Gao, Schulman and Hilton 2023), and misspecified rewards show capability-driven phase transitions (Pan, Bhatia and Steinhardt 2022), supporting the conjecture that discovery jumps once exploits share a factor (L2 §2). Yang et al. (2024)'s gap-dependent weak-to-strong deception is consistent with $\mathcal E(C)$ rising but does not separate it from the density.

**G2.9 (withholding and exploration hacking).** Let a disposition $W$ act like $A$ except on a task class where it samples the intended, higher-reward action $I$ only with probability $x_I$, and otherwise emits a withheld output $X'$ that the grader scores lower but accepts. The trained network is $W$ (quenched reading).
* *On-policy policy gradient (rigorous for the mean field; classical).* The expected gradient on the logit of $I$ is $x_I(1-x_I)(R_I-R_{X'})$, so for small $x_I$ withholding is undone only after about $1/(\mathrm{lr}(R_I-R_{X'})x_{I,0})$ episodes, a factor $2^K$ for withholding that costs $K$ bits. This is the known softmax policy-gradient plateau near low-probability optimal actions (Mei, Xiao, Szepesvári and Schuurmans 2020; Li, Wei, Chi, Gu and Chen 2021), here working for the gamer as it worked against isolated concealment in G2.6.2.
* *On-policy best-of-$k$ filtering (rigorous within the operator model).* Under (C-on) with softness $\delta$, an $I$ sample raises the ledger by $\ln\frac{1-\delta}{x_I}$ and a kept $X'$ sample lowers it by $\ln\frac{1-x_I}{\delta}$. The trained sample is $I$ with probability $1-(1-x_I)^k$, so filtering **entrenches** the withholder iff
  $$(1-x_I)^k\ln\tfrac{1-x_I}{\delta}>\big(1-(1-x_I)^k\big)\ln\tfrac{1-\delta}{x_I}.$$
  At $\delta=0.01$ this holds up to $k=68$, $18$, $10$ and $5$ for $x_I=0.01$, $0.05$, $0.1$ and $0.2$ (S17). At $x_I=\delta$ it reduces to $(1-x_I)^k>1/2$.
* *Trusted demonstrations* (C-off) raise the ledger on every demonstrated episode (by $\ln\frac{1-\delta}{x_I}\ge\Lambda$ when $x_I\le\delta$), with no need for $W$ to sample $I$.

This matches Greenblatt, Roger, Krasheninnikov and Krueger (2024), where a few demonstrations unlocked password-locked capabilities, and Jang et al. (2026), whose model organisms resisted RL elicitation but were detectable by monitoring. *In the loop* (conjecture): demonstrations exist only below the demonstrator's frontier, so withholding on frontier tasks, including alignment research and audit building, is invisible to training; it enters $q_k$ like T1.13's invisible band.

---

## 4. Design implications, quantified

1. **Make audits indistinguishable rather than more numerous** (rigorous within G2.2). Separable audits buy $\frac{\lambda_-}{\varpi_R}\ln(1+\varpi_Ru_0n)$ per generation, logarithmic in $n$ and in the audit rate; indistinguishable audits buy $\lambda_-ah\,m_{\rm fl}n$, linear in $n$; rewarded opportunities cost $\lambda_+vn$. At $\varpi_R=0.1$ and fixed $v$ (S10, S13):

   | $n$ | doubling separable audits | doubling $a$ with $v=(1-a)\varepsilon$ | halving $v$ | doubling audits, no learning |
   |---|---|---|---|---|
   | 500 | 16.4 | 17.1 | 11.1 | 34.5 |
   | 5,000 | 29.1 | 36.0 | 111.4 | 344.6 |
   | 50,000 | 31.6 (limit 31.9) | 100.5 | 1,114 | 3,446 |

   The levers whose value grows linearly with training length are removing rewarded opportunities (verifiable rewards; T4's protocols) and raising the indistinguishable share $c_r$ (perturbed real episodes meeting G2.5.2's assumption; random audits of real work, T2.H1; planted-flaw coverage of the frontier slice, T1.4d). Extra honeypot episodes help at large $n$ mostly by displacing real opportunities.
2. **Select and measure with detectors; do not train on them.** A detector in the reward feeds both channels of §2. Selecting one of $k$ i.i.d. runs by a detector sends no gradient and is bounded in two ways (rigorous). The selected law has density at most $k$ against the base, so selection raises the probability of any event, including *being an undetected evader*, at most $k$-fold. The odds gain is set by the detector's likelihood ratio, not by $\ln k$: "pick an unflagged run" multiplies the odds of $A$ by $(1-\mathrm{fpr})/(1-\mathrm{tpr})$ whenever an unflagged run exists (S18, $q=0.1$: a perfect detector gives 7.0 nats at $k=4$, against $\ln4=1.4$; $\mathrm{tpr}=0.9$, $\mathrm{fpr}=0.1$ gives 1.35, 2.16, 2.20 nats at $k=2$, $4$, $16$). The output-level analogue is the best-of-$n$ KL bound $\ln n-(n-1)/n$, which Beirami et al. (2024) show is an upper bound. Developers iterating on recipes against the detector remain a slow outer-loop learning channel (heuristic).
3. **Budget caught events** where the exchange rate is high: on indistinguishable audits, which teach nothing; across independent families (item 4); and early, while naive gamers carry the mass. Count caught events by family (T2.13).
4. **Rotate audit generators** (heuristic; fluid limit checked). With $\mathcal N$ families and transfer $\varsigma$, the additive budget becomes $\frac{m_0}{\varpi_A}\cdot\frac{\mathcal N}{1+(\mathcal N-1)\varsigma}\le\frac{m_0}{\varpi_A\varsigma}$ (S8: 230 against 229 for $\mathcal N=4$, $\varsigma=0.25$). Rotation buys at most a factor $1/\varsigma$.
5. **Measure learned recognition with held-out families** (rigorous within the separable multiplicative law). The difference-in-differences $[\ln u_{\rm ho}(n)-\ln u_{\rm ho}(0)]-[\ln u_{\rm tr}(n)-\ln u_{\rm tr}(0)]$ of caught rates on a held-out and a trained family equals $(1-\varsigma)\mathcal R$, cancelling differences in $s_0$ and the common gaming propensity. It separates recognition from alignment, not learning from selection: a posterior selecting family-specific recognisers (T1.5) leaves the same signature.
6. **Stop or refresh at the turn** (rigorous within G2.2). Since $dL=\lambda_-dN_c-\lambda_+dN_r$, the ledger peaks when caught events per rewarded gaming event fall to $\lambda_+/\lambda_-$. Rewarded gaming is invisible to the grader, so estimate it by random audits of real work (T2.H1). In the separable, fixed-$v$ model this is $\mathcal R=\mathcal M_0$, where item 5's statistic reaches $(1-\varsigma)\mathcal M_0$. With $\mathcal M_{\rm fl}>0$ there is no turn.

---

## 5. The loop map with learning

Each generation's student learns recognition against audits built by the previous generation. Take the multiplicative law on the separable part, fresh separable families each generation, a floor $m_{\rm fl}$ from indistinguishable audits, $n$ episodes per generation, and the shared clock. Let $e^{-\mathcal R^0_k}$ be generation $k$'s non-recognition of fresh separable audits at the start. Its recognition at the start of generation $k{+}1$ has three sources: the capability gap, $\mathcal R_{\rm gap}(g)$; carry-over through the weights, $\varsigma_w$ times what generation $k$ learned; and an on-task builder that turns its own learned recognition into realism, removing $\iota$ times it. With $\mathcal C_k:=\ln(1+\varpi_Rah(m_0-m_{\rm fl})n\,e^{-\mathcal R^0_k})$ (G2.2, leading order),
$$\mathcal R^0_{k+1}=\max\!\Big(0,\;\mathcal R_{\rm gap}(g)+\big(\varsigma_w-\iota(1-q_k)\big)\mathcal C_k\Big),$$
$$L_{k+1}=L_k+\frac{\lambda_-}{\varpi_R}\mathcal C_k+\lambda_-ah\,m_{\rm fl}n-\lambda_+v_kn+\gamma(1-q_k)-\kappa_Lg .$$
An off-task builder skips or sabotages the realism step, a second collusion channel beside T1's $\Delta\varepsilon$.

**G2.10.**
1. *(Rigorous.)* For stationary parameters, fixed $q$ and $\lvert\varsigma_w-\iota(1-q)\rvert<1$, the recognition map is a contraction (the clamp at 0 preserves this), so **the arms race has a unique, globally attracting steady state $\mathcal R^\star(q)$**. If $\iota(1-q)\ge\varsigma_w$, then $\mathcal R^\star\le\mathcal R_{\rm gap}(g)$: aligned builders keep pace. Since $q_k$ moves with $L_k$, and $L_k$ is monotone once its increment has a fixed sign, the relevant steady states are $\mathcal R^\star(0)$ and $\mathcal R^\star(1)$.
2. *(Rigorous given the map; the learning loop inequality.)* Near $q=0$ the ledger rises every generation iff
   $$\gamma+\frac{\lambda_-}{\varpi_R}\mathcal C^\star+\lambda_-ah\,m_{\rm fl}n\;>\;\lambda_+vn+\kappa_Lg\;(+\,\text{T1.4d's frontier-slice leak}).$$
   Here $\mathcal C^\star$ is $\mathcal C_k$ at $\mathcal R^\star$. This is T1.10i with the audit term made explicit. The break-even rewarded rate $v^\star$ falls like $\ln n/n$ when $m_{\rm fl}=0$ and tends to $ah\,m_{\rm fl}\lambda_-/\lambda_+$ otherwise (S19, $\varpi_R=0.1$: $v^\star=1.1\times10^{-2}$, $4.3\times10^{-3}$, $8.7\times10^{-4}$, $1.3\times10^{-4}$ at $n=500$ to $5\times10^5$ with no floor; $1.55\times10^{-3}$ at $n=5\times10^5$ with $m_{\rm fl}=0.05$, limit $1.5\times10^{-3}$). Without learning, $v^\star=u_0=0.015$.
3. *Who wins as capability grows.*
   * *(Heuristic; common scale-up.)* If capability multiplies both step sizes by $\alpha_s$ (sample efficiency raises $\lambda_\pm$ and $\varpi_R$ alike), the separable term $\frac{\lambda_-}{\varpi_R}\ln(1+\alpha_s\varpi_Ru_0n)$ grows like $\ln\alpha_s$, while the rewarded cost and the floor term both grow like $\alpha_s$. So the floor condition $\mathcal M_{\rm fl}>0$ is scale-invariant, and separable audits lose ground relative to both (S19: separable term over rewarded cost 0.44, 0.18 and 0.06 at $\alpha_s=1$, $4$, $16$).
   * *(Conjecture; the ratio.)* Capability may also raise $\varpi_R/\lambda_-$, i.e. $\mathsf k_{aa}-\mathsf k_{ra}$ relative to $\mathsf k_{ra}$, if evaluation-awareness features become more linearly available with scale (Nguyen et al. 2025; Needham et al. 2025 for awareness at frontier scale). The persona-latent evidence in §0 points the other way. Capability plausibly raises $\mathcal R_{\rm gap}$ (if telling synthetic from real gets cheap faster than generating) and $v$ (G2.8).

   Under these trends separable audits become *instruments* (held-out families measure $\mathcal R$), and the loop must be carried by indistinguishable audits, removal of rewarded opportunities, and $\gamma$. (S9 iterates the map for ten generations; Appendix G.)

**The discriminator becomes the generator** (heuristic). The term $\iota$ is a concrete improvement channel of T1.10i's kind. An aligned generation knows which features gave away the previous audits, because it learned them, and can remove them; a misaligned one knows the same features and can leave them in. Learning recognition thus steepens the grader channel at both ends, as T4.19 finds for protocols.

---

## 6. Relation to prior work, and what is new

Prior work is credited where it is used: empirical anchors (Hubinger et al.; Baker et al.; Gupta and Jenner; Bailey et al.; Schoen et al.; Cundy and Gleave; Greenblatt, Roger, Krasheninnikov and Krueger; van der Weij et al.; Jang et al.) and theory (Korbak et al. for G2.7; Gao et al. and Pan et al. for G2.8; Mei et al. and Li et al. for G2.9; Beirami et al. for §4.2). The arms race of §5 is a GAN-like game (Goodfellow et al. 2014) with roles passed down a generation. The informal point that training against a detector teaches evasion is widely stated (Hubinger et al. 2024; Baker et al. 2025's advice not to optimise against chain-of-thought monitors; Cotra's remark quoted in T1.5). **New here**, to my knowledge, are the quantitative forms: the exchange rate and its kernel form; the bank, the floor and the resulting separability principle; the filtering bank; the persistence conditions; the clock boundary; $\xi^\star$ as a tipping point; $\mathrm{tpr}_c$ and the isolated-versus-graded concealment banks; the stopping rule and the difference-in-differences diagnostic; the arms-race map and the learning loop inequality. All are elementary once the exchange rate is named; their value is in what they say to measure.

## What this says about the RSI loop

1. **Audits are depletable to the extent that they are separable.** Separable audits bank at most about $\frac{\lambda_-}{\varpi_R}\mathcal B(\mathcal M_0)$; indistinguishable ones keep paying linearly. The design question for every audit family is "can a learner tell it from real work?", not "how many are there?".
2. **The exchange rate $\lambda_-/\varpi_R=\mathsf k_{ra}/(\mathsf k_{aa}-\mathsf k_{ra})$ is the most decision-relevant unmeasured number**, and it has a cheap first measurement from gradients before training.
3. **Rare gamers do not get practice under the Bayes clock** (G2.4), which favours prior shaping and early correction (T3); under the shared clock this protection is absent.
4. **A detector is safe as a penalty only if $\mathrm{tpr}_c>t^\star$**, and graded concealment is reachable by default. Otherwise use it to select runs (factor-$k$ risk) and to measure.
5. **G2 moves the loop's load; it does not lift it.** Removing rewarded opportunities is cheap below the frontier and is exactly what the frontier lacks (T1.4d). At the frontier the loop rests on T4's protocols, on $\gamma$, and on indistinguishable planted-flaw audits of the frontier slice, whose realism must keep pace with each generation's recognition (open problem 6).
6. **Withholding at the frontier is invisible to on-policy training** (G2.9), and the loop's own research and audit-building tasks are where it matters most.

## Open problems

1. **Measure the exchange rate.** Compute $\mathsf k_{ra}/(\mathsf k_{aa}-\mathsf k_{ra})$ from per-example gradients on matched audit and real episodes, then check it against the difference-in-differences of §4.5 in a trained model organism.
2. **Which clock?** Insert a rare gamer persona and measure whether its recognition grows (G2.4).
3. **Learning on kept samples.** Measure $\varpi_R'$ under filtering operators (Remark 0.2), where it is the only channel.
4. **The concealment frontier.** Estimate $\mathrm{tpr}_c$ and the detection slope $\mathsf b$ along cheap paths for lie detectors and chain-of-thought monitors, and test G2.6 against the onset of obfuscation.
5. **Discovery.** Measure the exploit density over complexity (flat or $2^{\alpha_KK}$) and whether discovery jumps after a first hack (G2.8).
6. **The realism race.** Is $m_{\rm fl}$ bounded below across generations for planted-flaw audits built from real episodes? This is T2 open problem 7's time-bounded indistinguishability question, with learning added.

## References

Bailey, L., Serrano, A., Sheshadri, A., et al. (2024). Obfuscated activations bypass LLM latent-space defenses. arXiv:2412.09565 (ICLR 2026).
Baker, B., et al. (2025). Monitoring reasoning models for misbehavior and the risks of promoting obfuscation. arXiv:2503.11926.
Beirami, A., et al. (2024). Theoretical guarantees on the best-of-n alignment policy. arXiv:2401.01879 (ICML 2025).
Cundy, C., Gleave, A. (2025). Preference learning with lie detectors can induce honesty or evasion. arXiv:2505.13787 (NeurIPS 2025).
Gao, L., Schulman, J., Hilton, J. (2023). Scaling laws for reward model overoptimization. *ICML*. arXiv:2210.10760.
Goodfellow, I., et al. (2014). Generative adversarial nets. *NeurIPS*.
Greenblatt, R., Roger, F., Krasheninnikov, D., Krueger, D. (2024). Stress-testing capability elicitation with password-locked models. arXiv:2405.19550.
Gupta, R., Jenner, E. (2025). RL-Obfuscation: can language models learn to evade latent-space monitors? arXiv:2506.14261.
Hubinger, E., et al. (2024). Sleeper agents: training deceptive LLMs that persist through safety training. arXiv:2401.05566.
Jang, E., Falck, D., Braun, J., et al. (2026). Exploration hacking: can LLMs learn to resist RL training? arXiv:2604.28182.
Korbak, T., Perez, E., Buckley, C. L. (2022). RL with KL penalties is better viewed as Bayesian inference. arXiv:2205.11275.
Levin, L. A. (1973). Universal sequential search problems. *Problems of Information Transmission* 9(3).
Li, G., Wei, Y., Chi, Y., Gu, Y., Chen, Y. (2021). Softmax policy gradient methods can take exponential time to converge. *COLT*. arXiv:2102.11270.
MacDiarmid, M., et al. (2025). Natural emergent misalignment from reward hacking in production RL. arXiv:2511.18397.
Mei, J., Xiao, C., Szepesvári, C., Schuurmans, D. (2020). On the global convergence rates of softmax policy gradient methods. *ICML*. arXiv:2005.06392.
Needham, J., Edkins, G., Pimpale, G., Bartsch, H., Hobbhahn, M. (2025). Large language models often know when they are being evaluated. arXiv:2505.23836.
Nguyen, J., Hoang, K., Attubato, C. L., Hofstätter, F. (2025). Probing (and steering) evaluation awareness of language models. arXiv:2507.01786.
Pan, A., Bhatia, K., Steinhardt, J. (2022). The effects of reward misspecification: mapping and mitigating misaligned models. *ICLR*. arXiv:2201.03544.
Schoen, B., et al. (2025). Stress testing deliberative alignment for anti-scheming training. arXiv:2509.15541.
van der Weij, T., et al. (2024). AI sandbagging: language models can strategically underperform on evaluations. arXiv:2406.07358.
Wang, M., et al. (2025). Persona features control emergent misalignment. arXiv:2506.19823.
Yang, W., et al. (2024). Super(ficial)-alignment: strong models may deceive weak models in weak-to-strong generalization. arXiv:2406.11431.

---

## Appendix: proofs and numerical notes

**A. The multiplicative law from a policy gradient.** Gaming probabilities are $P=\sigma(\mathsf g)$ on real opportunities (rate $v$) and $Q=\sigma(\mathsf g-\mathsf r)$ on audits (rate $ah$). The expected reward per episode is $J=v\Delta_+P-ah\Delta_-Q$, and gradient ascent with step sizes $\mathrm{lr}_L$ on $\mathsf g$ and $\mathrm{lr}_R$ on $\mathsf r$ gives
$$\dot{\mathsf g}=\mathrm{lr}_L\big(v\Delta_+P(1-P)-ah\Delta_-Q(1-Q)\big),\qquad\dot{\mathsf r}=\mathrm{lr}_R\,ah\Delta_-Q(1-Q).$$
For small $P,Q$: $d\mathsf g=\mathrm{lr}_L(\Delta_+dN_r-\Delta_-dN_c)$ and $d\mathsf r=\mathrm{lr}_R\Delta_-dN_c$. So each caught event multiplies $Q/P=e^{-\mathsf r}$ by $e^{-\mathrm{lr}_R\Delta_-}$: the multiplicative law with $\varpi_R=\mathrm{lr}_R\Delta_-$, $\lambda_\pm=\mathrm{lr}_L\Delta_\pm$, and $\mathsf g+(\mathrm{lr}_L/\mathrm{lr}_R)\mathsf r-\mathrm{lr}_L\Delta_+N_r$ conserved. In kernel terms, $\mathsf k_{rr}=\mathsf k_{ra}=\mathrm{lr}_L$ and $\mathsf k_{aa}=\mathrm{lr}_L+\mathrm{lr}_R$. The audit indicator here is a perfectly separating feature whose weight alone is learned, which is why G-A1f is needed for any indistinguishable share. S4 integrates the exact equations: from $P_0=e^{-6}$ the bank is 0.084 against 0.083 predicted at $\mathrm{lr}_L/\mathrm{lr}_R=1$, and 0.334 against 0.330 at ratio 4; from $P_0=0.5$ the exact $P(1-P)$ factors raise it to 0.475 and 1.18. In every learning case the real-opportunity gaming probability ends near 1; with $\mathrm{lr}_R=0$ it goes to 0.

*Kernel form.* In the tangent model, logits change by $\delta\mathsf l_x=\langle\nabla\mathsf l_x,\delta\Theta\rangle$. A caught event (small $Q$) is the step $\delta\Theta=-\mathrm{lr}\Delta_-\nabla\mathsf l_a$, so $\delta\mathsf l_r=-\mathrm{lr}\Delta_-\mathsf k_{ra}$ and $\delta\mathsf l_a=-\mathrm{lr}\Delta_-\mathsf k_{aa}$; hence $\delta L=\mathrm{lr}\Delta_-\mathsf k_{ra}$ and $\delta\mathsf r=\delta\mathsf l_r-\delta\mathsf l_a=\mathrm{lr}\Delta_-(\mathsf k_{aa}-\mathsf k_{ra})$. A rewarded event is $\delta\Theta=\mathrm{lr}\Delta_+\nabla\mathsf l_r$, giving $\delta\mathsf r=\mathrm{lr}\Delta_+(\mathsf k_{rr}-\mathsf k_{ra})$. ∎ (S20 checks the identity for random linear features.)

**B. Proof of G2.2.** Write $x=e^{\mathcal R}$ with $\mathcal R=\varpi_RN_c$. Then $\dot x=\varpi_Rah\,x\,m(\mathcal R)=\varpi_Rah\big(m_{\rm fl}x+(m_0-m_{\rm fl})\big)$, a linear ODE with $x(0)=1$, whose solution is the displayed formula; $m_{\rm fl}\to0$ gives $x=1+\varpi_Ru_0n$.
* *Item 1.* $dL/dn=\lambda_-u_0/(1+\varpi_Ru_0n)-\lambda_+v$ vanishes at $1+\varpi_Ru_0n_{\rm turn}=e^{\mathcal M_0}$, where $\varpi_RN_c=\mathcal M_0$ and
  $$L-L_0=\frac{\lambda_-\mathcal M_0}{\varpi_R}-\lambda_+v\frac{e^{\mathcal M_0}-1}{\varpi_Ru_0}=\frac{\lambda_-}{\varpi_R}\big(\mathcal M_0-(e^{\mathcal M_0}-1)e^{-\mathcal M_0}\big)=\frac{\lambda_-}{\varpi_R}\mathcal B(\mathcal M_0),$$
  using $v\lambda_+/(u_0\lambda_-)=e^{-\mathcal M_0}$. Afterwards $\dot N_c\to0$.
* *Item 2.* For large $n$, $x\approx(m_0/m_{\rm fl})e^{\varpi_Rah\,m_{\rm fl}n}$, so $N_c=ah\,m_{\rm fl}n+\varpi_R^{-1}\ln(m_0/m_{\rm fl})+o(1)$ and $dL/dn\to\lambda_-ah\,m_{\rm fl}-\lambda_+v$. At equality, $dL/dn=\lambda_-ah(m_0-m_{\rm fl})e^{-\mathcal R}$ with $\mathcal R$ growing linearly, which is integrable.
* *Item 3.* In event space $dN_r/dN_c=v/(ah\,m(\mathcal R))$ is unchanged by a common thinning factor, so $dL/d\mathcal R=(\lambda_-/\varpi_R)\big(1-v\lambda_+/(ah\,m(\mathcal R)\lambda_-)\big)$; with $m_{\rm fl}=0$, integrating from 0 to $\mathcal M_0$ gives $\mathcal B$.
* *Item 4.* $\ln(1+2y)-\ln(1+y)\le\ln2$; the floor term is linear in $ah$; the displacement term is $\lambda_+(v(a)-v(2a))n=\lambda_+a\varepsilon n$. ∎

*Numerical notes (S2, S12, S13).* Monte Carlo agrees with the mean field on $\mathbb EN_c$ to within 0.1 events; the maximum of $\mathbb EL$ is somewhat higher (4.5 against 3.8 at $\varpi_R=0.1$) because the walk is noisy. The floor closed form matches the ODE to two decimals at all $n$ checked.

*Remark 0.2's bank.* With $\mathcal R=\varpi_R'vn$, $L-L_0=\frac{\lambda_-u_0}{\varpi_R'v}(1-e^{-\varpi_R'vn})-\lambda_+vn$, maximised at $\varpi_R'vn=\mathcal M_0$, giving $\frac{1}{\varpi_R'}\big(\lambda_+e^{\mathcal M_0}(1-e^{-\mathcal M_0})-\lambda_+\mathcal M_0\big)=\frac{\lambda_+}{\varpi_R'}(e^{\mathcal M_0}-1-\mathcal M_0)$. ∎

**C. Proof of G2.4.** Write $\mathsf o(\mathcal R)=e^{\mathcal M_0-\mathcal R}$. Then $\dot L=\lambda_+v(\mathsf o-1)$ and $\dot{\mathcal R}=\varpi_R\sigma(-L)\lambda_+v\mathsf o/\lambda_-$. While $\mathsf o>1$, $L$ increases and $(1-1/\mathsf o)\,d\mathcal R=\frac{\varpi_R}{\lambda_-}\sigma(-L)\,dL$. Integrating from $(L_0,0)$, the left side is $\mathcal R-(e^{\mathcal R}-1)e^{-\mathcal M_0}$, increasing on $[0,\mathcal M_0]$ to $\mathcal B(\mathcal M_0)$; the right side is $\frac{\varpi_R}{\lambda_-}[\ln(1+e^{-L_0})-\ln(1+e^{-L})]$, increasing to $\frac{\varpi_R}{\lambda_-}\ln(1+e^{-L_0})$. If that supremum is below $\mathcal B(\mathcal M_0)$, $\mathcal R$ stays below some $\mathcal R_\infty<\mathcal M_0$, so $\mathsf o\ge\mathsf o(\mathcal R_\infty)>1$ and $L$ grows at least linearly; $\mathcal R_\infty$ solves $\mathcal R-(e^{\mathcal R}-1)e^{-\mathcal M_0}=\frac{\varpi_R}{\lambda_-}\ln(1+e^{-L_0})$. Otherwise $\mathcal R$ reaches $\mathcal M_0$ at finite $L$; thereafter $\dot{\mathcal R}>0$ keeps $\mathsf o<1$, $\sigma(-L)$ rises, and $\dot L\to-\lambda_+v$ monotonically. ∎ (S3: runs 0.3 nats either side of the critical $L_0$ go the predicted way.)

**D. G2.6.** With gaming probability $q$ and concealment probability $\pi_{\rm c}$, the expected reward per opportunity is $q[\Delta_+-(\Delta_++\Delta_-)\mathrm{det}(\pi_{\rm c})]$. The logit gradients per gaming event, at small $q$, are $(\Delta_++\Delta_-)(t^\star-\mathrm{det})$ for $-L$ and $(\Delta_++\Delta_-)(\mathrm{tpr}-\mathrm{tpr}_c)\pi_{\rm c}(1-\pi_{\rm c})$ for $\mathcal H$; scaling by step sizes gives the system, with $\varpi_T=\mathrm{lr}_{\mathcal H}(\Delta_++\Delta_-)$.
* *Item 1.* $\mathcal H$ is nondecreasing and $\pi_{\rm c}\to1$ along any trajectory with infinitely many gaming events, which occur because $N_g(n)$ grows at least like a constant times $\ln n$ when $dL/dN_g$ is bounded. So $\mathrm{det}\to\mathrm{tpr}_c$ and the sign of $\mathrm{tpr}_c-t^\star$ decides; for $\mathrm{tpr}_c>t^\star$, $dL/dN_g$ tends to a positive constant and $q\propto e^{-L}$ makes $L$ grow like $\ln n$. *Equality.* Then $\mathrm{det}-t^\star=(\mathrm{tpr}-t^\star)(1-\pi_{\rm c})$, so $dL/d\mathcal H=k/\pi_{\rm c}$ exactly, and $L-L_0=k\big[(\mathcal H-e^{-\mathcal H})-(\mathcal H_0-e^{-\mathcal H_0})\big]$ (S16 matches this to 0.003). Since $d\mathcal H/dn\propto e^{-L}e^{-\mathcal H}\approx e^{-(k+1)\mathcal H}$ for large $\mathcal H$, $\mathcal H\sim\ln n/(k+1)$ and $L\sim\frac{k}{k+1}\ln n$.
* *Item 2.* For small $\pi_{\rm c}$, $d\pi_{\rm c}/dN_g\approx\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)\pi_{\rm c}^2$, which blows up after $N_b=1/\mathcal T$ events. Meanwhile $dL/dN_g\approx\mathcal S$ and $dN_g/dn=we^{-L}$, so $N_g(n)=\mathcal S^{-1}\ln(1+\mathcal Swq_0n)$; setting $N_g=N_b$ gives $n_b$. Corrections to the bank are $O\big(\varpi_T^{-1}(\lambda_++\lambda_-)\ln(1/\pi_{{\rm c},0})\big)$.
* *Item 3.* For a Gaussian policy over the level with fixed variance, the expected REINFORCE gradient on the mean equals the derivative of expected reward, which is constant along a linear path; so $\bar\pi_{\rm c}=\varpi_G\mathsf bN_g$, the turn is at $N=(\mathrm{tpr}-t^\star)/(\varpi_G\mathsf b^2)$, and $dL/dN_g=(\lambda_++\lambda_-)(\mathrm{tpr}-t^\star-\mathsf b\bar\pi_{\rm c})$ falls linearly to 0, so the bank is half of $\mathcal S N$. ∎

*Numerical notes (S6).* With $\lambda_+=1$, $\lambda_-=3$, $\mathrm{tpr}=0.6$, $\mathrm{tpr}_c=0.1$, $w=0.05$, $\pi_{{\rm c},0}=0.01$: at $L_0=4$, banks of 7.0 and 14.0 nats are predicted for $\varpi_T=40$ and $20$, against 7.03 and 14.08 from the ODE, with turning times $8.7\times10^5$ against $1.3\times10^6$, and $9.6\times10^8$ against $1.9\times10^9$. At $L_0=0$ the turning times are $3.1\times10^4$ against $9.3\times10^3$, and $3.4\times10^7$ against $1.3\times10^7$.

**E. G2.10.1.** Let $f(\mathcal R)=\mathcal R_{\rm gap}+\mathcal Y\ln(1+\mathcal Ze^{-\mathcal R})$ with $\mathcal Y=\varsigma_w-\iota(1-q)$ and $\mathcal Z=\varpi_Rah(m_0-m_{\rm fl})n$. Then $f'=-\mathcal Y\mathcal Ze^{-\mathcal R}/(1+\mathcal Ze^{-\mathcal R})$, so $\lvert f'\rvert<\lvert\mathcal Y\rvert<1$. The map $\max(0,f)$ on $[0,\infty)$ is 1-Lipschitz composed with a contraction, so it is a contraction, and Banach gives a unique attracting fixed point. (With $\mathcal Y<0$ the clamp can bind: S19 gives $f(0)=-0.175$ at $\mathcal R_{\rm gap}=0.1$, $\mathcal Y=-0.3$, $\mathcal Z=1.5$.) When $\mathcal Y\le0$, $f\le\mathcal R_{\rm gap}$. ∎

**F. Rotation (§4.4).** In the fluid limit, each family's caught rate is proportional to its own non-recognition, which balances depletion. With $N_i=N/\mathcal N$, exhaustion occurs at $m_0=\varpi_A\frac{N}{\mathcal N}(1+(\mathcal N-1)\varsigma)$. With coarse budgets, uneven exhaustion lets the simulation exceed the formula by up to 10% (S8). ∎

**G. Further numerical notes.** *S5* uses reward units $\Delta_\pm=1$, binormal $d'=1.9$ (AUC 0.91), $ah=0.03$, $v=0.0097$. With $c_r=0$ the learned drift is 0.00435 per episode against $D^\star=0.00436$, i.e. 0.020 nats under (D) with $\Delta/\beta=4.6$, close to T1.4c's 0.0186 at AUC 0.90 (S22); the starting policy games with probability 0.25 on real opportunities and 0.24 on audits. With $c_r=0.2$, $D^\star=0.00116$ (0.0053 nats); T1.4c's "+0.0019 at $c=0.2$" uses a different AUC and is not directly comparable. *S9* (separable audits, $L_0=3$, $n=500$, T1's rates, $\mathcal R_{\rm gap}=\ln2$, $\varsigma_w=0.3$, $\gamma=0$), ledger after ten generations: no learning 124.8; $\varpi_R=0.1$, $\iota=0$: 11.6; $\iota=\varsigma_w$: 37.3; adding $v/10$: 237.9; $\varpi_R=1$, $\iota=\varsigma_w$, $v/10$: 79.1; with $v/100$: 99.1.

---

## Revision notes

Response to `drafts/G2-learning-referee.md`. New numbers are in `sim/G2_revision_checks.py` (S11 to S22); `sim/G2_checks.py` is unchanged.

**Major issues.**
1. *Separability (non-recognition floor).* Adopted as the organising statement. G-A1f introduces $m(\mathcal R)=m_{\rm fl}+(m_0-m_{\rm fl})e^{-\mathcal R}$. G2.2 now has a closed form with the floor (item 2: linear growth iff $ah\,m_{\rm fl}\lambda_->v\lambda_+$), G2.3 gains item 3, and the floor enters G2.10's map, the loop inequality and $v^\star$, which now tends to $ah\,m_{\rm fl}\lambda_-/\lambda_+$ (S12, S19). §4.1's "only lever" claim, takeaway 1 and the Summary now say "depletable to the extent separable". One refinement: the floor is $m_{\rm fl}\ge c_r\pi_r$ rather than $\ge c_r$, because a gamer that does not game on real opportunities is not caught on indistinguishable audits either.
2. *The $\ln k$ selection bound.* Removed as false. §4.2 now gives the factor-$k$ probability bound and the likelihood-ratio bound on the odds gain, with the referee's counterexamples reproduced (S18: 7.0 nats at $k=4$; 1.35, 2.16, 2.20 nats for the noisy detector), and cites Beirami et al. (2024).
3. *Worked example under (B).* Re-based on (D) with $\Delta_\pm/\beta=4.6$; the numbers are unchanged. Remark 0.2 now calls $\varpi_R'=0$ "the case most favourable to audits", says that under filtering $\varpi_R'$ is the only channel, and gives the filtering bank $\frac{\lambda_+}{\varpi_R'}(e^{\mathcal M_0}-1-\mathcal M_0)$ with numbers (S14). The kernel form adds that gradient operators also teach on rewarded events, $\varpi_R'=\mathrm{lr}\Delta_+(\mathsf k_{rr}-\mathsf k_{ra})$.
4. *Capability conjecture.* G2.10.3 is split into (a) a common scale-up argument (heuristic): separable audits lose like $\ln\alpha_s/\alpha_s$ relative to rewarded cost, and the floor condition is scale-invariant (S19); and (b) a separate conjecture about the ratio $\mathsf k_{aa}-\mathsf k_{ra}$ to $\mathsf k_{ra}$. The $\ln(\varpi_R)/\varpi_R$ claim and the Kaplan citation are removed.
5. *Exponential in $K_c$.* Restricted to concealment isolated in strategy space. A graded-concealment result, G2.6.3, gives the bank $B_G=\frac{(\lambda_++\lambda_-)(\mathrm{tpr}-t^\star)^2}{2\varpi_G\mathsf b^2}$, i.e. an effective $\pi_{{\rm c},0}=2/\bar\pi_{\rm c}^{\rm turn}$ (S16 checks it against the ODE). Gupta and Jenner (2025) and Bailey et al. (2024) are added as evidence.

**Per-proposition fixes.** G2.1: the wrong justification is replaced by template memorisation; the linear-parametrisation budget $m_0^2/(2\,\mathrm{lr}\Delta_-)$ is noted as also free of the audit rate (S11); the divergence condition is stated; G2.3.1 uses the ceiling. G2.2: "at fixed $v$" and the displacement term (S13: 17.1, 36.0, 100.5 nats); drift sign unified to T1's convention, declared in the notation box. G2.3: boundary case added; minimum corrected to $-48.2$ near $n=2{,}200$ (S15). G2.4: hybrid nature stated; the 97.7% figure highlighted (S21). G2.5.1: units stated (0.020 nats, consistent with T1.4c at AUC 0.90; S22); "non-discriminating gamer". G2.5.2: assumption restated as equality of the joint law of (episode, flaw); "preserves" rather than "restores". G2.5.3: tipping point only at $\delta=0$, with a creep rate and an illustrative crossing time otherwise; item 4 kept heuristic, with $D^\star\to v\lambda_+$ added. G2.6: both $L_0$ runs reported; equality case discussed (see below). G2.7: "mode" and "majority" versions; plain gaming included; the on/off-policy difference attributed to reachability (G2.6) only. G2.8: retitled; headline is one bit of reachable complexity per doubling; the $\log N$ form made conditional on a flat density, with the power-law alternative; "Levin-style" and the Yang "product" claim removed; Gao et al. and Pan et al. credited. G2.9: exact (C) condition with thresholds 68, 18, 10, 5 (S17); sign wording fixed; Mei et al. (2020) and Li et al. (2021) credited. §4.5: difference-in-differences; §6 now says the diagnostic separates recognition from alignment. G2.10.1: clamp at 0 and the $q\in\{0,1\}$ steady states. Notation: $\theta,\psi$ replaced by $\mathsf g,\mathsf r$; G2.3's constant is $c_v$; concealment probability is $\pi_{\rm c}$; Appendix C uses $\mathsf o$ and Appendix E uses $\mathcal Y,\mathcal Z$; the password-locked paper is cited by its authors; Nguyen et al. has authors. No new meanings were given to $v,\eta,\beta,\phi,\chi,\nu,\kappa$. ($\Gamma_j$ in G2.7 is local to that proposition.)

**Missing items added.** The non-recognition floor; the optimal-stopping rule (§4.6), stated through the ratio of caught to rewarded gaming events, because that is clock-free and does not need $\varsigma$, and is equivalent to the referee's held-out form in the separable, fixed-$v$ model; the kernel form of the exchange rate (§0, S20); the statement that G2 moves the loop's load onto T4, $\gamma$ and frontier-slice indistinguishable audits (takeaway 5); prior art (Gao et al.; Pan et al.; Mei et al.; Li et al.; Beirami et al.; Gupta and Jenner; Bailey et al.); the graded-concealment version of G2.6; and the counter-evidence on the exchange rate (Schoen et al.'s covert-action drop, Wang et al., MacDiarmid et al.) and on the clock (Schoen et al.'s capabilities-only awareness rise, which I could confirm only through secondary summaries, so it is flagged as reported).

**Where I disagree with the referee.**
* *G2.6 equality case.* The referee says that at $\mathrm{tpr}_c=t^\star$, $1-\pi_{\rm c}$ decays like $e^{-\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)N_g}$, so $L$ converges. In the stated model concealment is a logistic $\pi_{\rm c}=\sigma(\mathcal H)$ with gradient $\propto\pi_{\rm c}(1-\pi_{\rm c})$, so $1-\pi_{\rm c}\approx e^{-\mathcal H}$ decays only like $1/N_g$. The exact event-space identity $dL/d\mathcal H=k/\pi_{\rm c}$ then gives $L\to\infty$ like $\frac{k}{k+1}\ln n$ (Appendix D; S16 matches the identity to 0.003). The referee's conclusion would hold under a parametrisation with summable decay. I therefore keep the ODE statement exact, and I adopt the strict inequality as the *robust* headline, since equality is parametrisation-dependent.
* *Floor size.* As noted above, $m_{\rm fl}\ge c_r\pi_r$, not $\ge c_r$.
* *Word count.* The main text is about 4,500 words of prose (tables included), slightly above the target, because the referee's requested additions (floor, kernel form, stopping rule, graded concealment, counter-evidence) are substantive. To compensate, S-number detail has moved to Appendix G, the S9 table has moved there, and §6 now refers to inline credits rather than repeating them.
