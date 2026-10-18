# T2. Proxy training as a sieve

*Theory section for the RSI-loop round of the proxy-conditioning project. Draft, 18 October 2026, revised the same day in response to `drafts/T2-sieve-referee.md`. Notation follows `framing.md` and T1 (`drafts/T1-ledger.md`). The first-round numbers come from [`sim/T2_sieve_checks.py`](../sim/T2_sieve_checks.py) (output in [`sim/T2_sieve_checks_output.txt`](../sim/T2_sieve_checks_output.txt)). The numbers added in the revision come from [`sim/T2_revision_checks.py`](../sim/T2_revision_checks.py) (output in [`sim/T2_revision_checks_output.txt`](../sim/T2_revision_checks_output.txt)), cited below as "RC§k". The errata after reconciliation (18 October 2026, last section) use [`sim/T2-sieve_errata_checks.py`](../sim/T2-sieve_errata_checks.py) (output in [`sim/T2-sieve_errata_checks_output.txt`](../sim/T2-sieve_errata_checks_output.txt)), cited as "EC§k", and the reconciliation checks [`sim/reconcile_checks.py`](../sim/reconcile_checks.py), cited as "R11" and "R12". Status labels: **rigorous** means proved within the stated toy model; **heuristic** means a derivation that uses a named approximation; **conjecture** means a claim about real systems that the model suggests but does not establish.*

## Summary

T1 treated careful gamers as a few discrete types. Here they form a continuum $C_t$, $t\in[0,1]$, with $A=C_0$, and training is a sieve over $t$. I also add the type that the continuum leaves out: the *adaptive* best responder $G^\star$, which plays whatever gaming rule the current training design rewards most. All rates are selection rates. The model selects among dispositions that already have prior mass; it does not represent training that *creates* recognition or concealment.

* **The sieve has a fixed shape** (T2.1, T2.2). With one update operator and uniform evidence per event, the per-episode drift of $C_t$ against $A$ is $D(t)=w\bar\lambda\int_{[0,t)}(t^\star-q)\,dH(q)$. Here $H$ is the distribution of the student's calibrated detection estimate $\hat p$ over gaming opportunities, and $t^\star=\lambda_+/(\lambda_++\lambda_-)$ is the operator's break-even. $D$ rises up to $t^\star$ and falls after it. Types above a *mesh* $t_0=\sup\lbrace t:D(t)\ge0\rbrace$ are removed. Types below the smallest $\hat p$ the student ever sees are frozen. The types in between are favoured, and under the exact tilt (S4d) the gamers' posterior concentrates at $t^\star$.
* **With uniform penalties, the mesh is never finer than $t^\star$.** Within one operator, no type with $t\le t^\star$ is pushed down. Mixing operators or making penalties depend on context moves the floor to a per-cell break-even (T2.1′). In particular, SFT on trusted demonstrations of real opportunity prompts is indistinguishable by construction, and it shifts the break-even down by $w_d\Lambda/(w\bar\lambda)$, below zero in the example. False flags on intended outputs push it back up.
* **Two different frontier conditions** (T2.5). For fixed-threshold gamers, the frontier on-task rate is capped by $\mu_0(O)/\big(\mu_0(O)+\mu_0((d_F,t^\star])\big)$, where $O$ is the on-task set. Training design moves this cap continuously, through $t^\star$, pooling and demonstrations. For the adaptive best responder, **no behavioural training design ever pushes it down** (T1.4). This is near-tautological under selection, since $G^\star$ is defined as the best responder to whatever design is used; the content is in whether such a type has prior mass (T3). The most training can do is freeze it at its prior odds. Whether it defects at the frontier depends on $d_F$ against its *own* frontier break-even $t^\star_F$, and no training lever sets $t^\star_F$: it depends on frontier stakes and on the consequences of late detection. Once training has frozen the adaptive type, the decisive question for the loop is control and consequences at the frontier, not the training penalty ratio.
* **The mean field fails for rarely triggered types** (T2.3, T2.3b; added after reconciliation). Under per-episode updates the mean-field condition must hold type by type, and it always fails for types that game only in the low tail of a feature the student conditions on: they see $O(1)$ decisive events at every $n$. When the mean field predicts that such types are removed (for example under pooled audits), a run is nevertheless captured with probability about $(P_+/P_-)^{\lceil x_A/\lambda_s\rceil}$, independent of $n$ and exponentially small in $1/\lambda_s$, the evidence per event (heuristic; within a factor 1.5 of simulation). Coarse per-event evidence ((B), rejection sampling) lets such types through by luck; soft evidence suppresses them. Even where the mean field holds, per-episode (D) flips about 7% earlier than the exact tilt and single runs spread widely.
* **Audits work only through what the student cannot tell apart** (T2.6 to T2.8). Against the best responder, detection counts only up to $t^\star$ in each cell the student can tell apart: $D^\star/(w\bar\lambda)=t^\star-\mathbb E\min(\hat p,t^\star)$. Better recognition never hurts the best responder (Blackwell). The design goal is to keep every distinguishable cell at or above break-even; pooling is one way. With binary checks, $D^\star/(w\bar\lambda)=(1-\bar p)t^\star\max_c[\mathrm{TPR}(c)-e^{\xi^\star}\mathrm{FPR}(c)]$, a weighted Youden index of the student's best "is this unchecked?" test at ROC slope $e^{\xi^\star}=\operatorname{odds}(\bar p)\,\lambda_-/\lambda_+$. So $D^\star=0$ iff the max-divergence $D_\infty(P_{\rm unchecked}\Vert P_{\rm checked})\le\xi^\star$. AUC does not determine $D^\star$; it only confines it to an interval (T2.8c), which at AUC 0.8 in the main example spans a factor 3.5.
* **Heavy penalties have limits** (T2.9). As $\lambda_-\to\infty$, the best responder's drift tends to $w\lambda_+\Pr(\hat p=0)$, the rate of opportunities the student is *sure* are unchecked. The approach is slow when $\hat p$ has a heavy tail near 0, but penalties keep helping at every finite recognition level unless $\hat p$ has an atom at 0. When false flags are independent of gaming, penalties cannot push the effective break-even below the false-flag rate.
* **Harder (lower-$p$) training tasks hurt** unless they are checked above break-even or covered by trusted demonstrations (T2.10).
* **What a designer sees** (T2.13). The rate of *caught* gaming in training is a posterior-predictive average, and its slope is $\mathrm{Cov}_{\mu_n}(\text{caught rate},D)$. In the main example it *rises* about 30-fold as frontier on-task behaviour collapses. It falls only when the prior gamer mass is dominated by naive gamers. Its long-run level is the best responder's caught rate, which falls with recognition above AUC of about 0.8.
* **Tells help in proportion to the correlation that survives the sieve** (T2.11). In the example, the same prior correlation between tell and type gives gains from 0.2 to 1.6 nats, depending on whether the tells sit with reckless or with careful gamers.
* **Across generations** recognition rises and frontier detection falls, and both push the same way. In the illustrative Example 4, $D^\star$ grows 70-fold over six generations under Gaussian recognition; that factor is an artefact of the Gaussian signal's unbounded likelihood ratio at low AUC, and over all signals with the assumed AUCs it ranges from about 5-fold to unbounded (T2.8c). A drift floor $w\lambda_+\varphi_k$ from certainly-unchecked training tasks appears, and no penalty removes it; only trusted demonstrations, where they exist, can.

---

## 0. The model

**S1. Opportunities.** Training episodes are i.i.d. On average there are $w$ *gaming opportunities* per episode: episodes on which a non-intended output $X$ would be scored above the intended output $I$ unless a strong check catches it. Honeypots count as opportunities. On all other episodes every disposition behaves like $A$, so by T1.1 they move nothing. In T1's terms, $w=ah+(1-a)\varepsilon$.

**S2. Detection and what the student sees.** Each opportunity carries a detection probability $p\in[0,1]$, the chance that gaming there is caught, with $(p,z)\sim F$. Here $z$ is everything the student can extract from the episode. Write
$$\hat p(z)=\mathbb E[p\mid z],\qquad H=\text{law of }\hat p,\qquad \bar p=\mathbb E p=\mathbb E\hat p,\qquad q_{\min}=\operatorname{ess\,inf}\hat p .$$
$\hat p$ is the *calibrated* estimate. This assumes nothing about the student's beliefs; it is a choice of coordinates (Remark 0.1).

**S3. Dispositions.**
* **Fixed-threshold types.** $C_t$ games on an opportunity iff $\hat p(z)<t$. $A=C_0$ never games, and $C_1$ games unless it is certain of being checked. A smooth rule, gaming with probability $\sigma((t-\hat p)/\tau)$, is a mixture of hard thresholds: $\sigma((t-\hat p)/\tau)=\Pr(\hat p<t-\tau U)$ with $U$ logistic. So it just smooths $D(t)$ by a convolution, and I use hard thresholds throughout.
* **The adaptive best responder $G^\star$** ("maximise the training reward, audits included"; Cotra 2022). In training, it games on whichever region of opportunities maximises its drift under the design actually in use. Under the design of S4 that region is $\lbrace\hat p<t^\star\rbrace$, so in training it is indistinguishable from $C_{t^\star}$. It differs from the fixed type $C_{t^\star}$ in two ways. When the design changes, it changes its threshold. At the frontier it has its own break-even $t^\star_F$ (S5). *Notation:* T1 writes $G^\star=C_{t^\star}$ for one fixed design; here $G^\star$ is the adaptive type, and the fixed type is written $C_{t^\star}$.
* Optionally, the naive approval-seeker $G=C_1$ appears as an atom.

**S4. Evidence per event.** Relative to $A$, a gaming event that goes uncaught moves the log-weight by $+\lambda_+$, and a caught one by $-\lambda_-$ (T1 §1.2). Write
$$\bar\lambda=\lambda_++\lambda_-,\qquad t^\star=\frac{\lambda_+}{\bar\lambda}.$$
$t^\star$ is the deterrence threshold of Becker (1968) and of Allingham and Sandmo (1972), whose taxpayer evades iff the *perceived* audit probability is below a penalty-dependent cut. Here it governs selection among types, not the incentives of one agent. Its value depends on the operator (T1 §1.2 table):
* (D), the KL-tilt with gain $\Delta_+$ from undetected gaming and penalty $\Delta_-$ when caught: $\lambda_\pm=(1-2\delta)\Delta_\pm/\beta$, so $t^\star=\Delta_+/(\Delta_++\Delta_-)$, which the designer sets;
* (B) with a hard grader: $t^\star=1/2$. With a weak grader that sometimes passes $I$ and fails $X$: $t^\star<1/2$;
* (C-on), on-policy best-of-$k$ filtering: $t^\star=\pi_X$ at $k=1$, rising toward $1/2$ as $k$ grows;
* (C-off), trusted demonstrations on opportunity prompts: $t^\star=0$.

**Standing assumptions for §§1 to 4** (made explicit in this revision):
* **S4a, uniform evidence.** $(\lambda_+,\lambda_-)$ are the same on every opportunity, independent of $(p,z)$, and only one operator acts on opportunities.
* **S4b, no false positives.** $A$'s intended output is never flagged.
* **S4c, exogenous detection.** $p$ is a property of the opportunity, not of how the gamer games.
* **S4d, expected-reward tilt.** The update is (D) applied to the expected reward over the training distribution, so $\mu_n\propto\mu_0e^{nD}$ exactly. Per-episode updates, and (B) and (C), are treated as mean-field approximations (T2.3).

T2.1′ drops S4a and S4b. Remark 4.1 drops S4c.

**S5. Frontier.** Frontier tasks carry a calibrated estimate $\hat p_F$ of *consequential* detection: detection followed by a consequence the disposition cares about (T1 §7). It has some distribution over frontier tasks, and $d_F$ denotes a typical value; $d_F\approx0$ unless frontier work is audited after the fact *with consequences*.
* $C_t$ is on task on a frontier task iff $t\le\hat p_F$. *The threshold is assumed to be the same trait in training and at the frontier.* If it is a fixed monotone map $t\mapsto f(t)$, nothing qualitative changes.
* $G^\star$ is on task iff $\hat p_F\ge t^\star_F:=g_F/(g_F+\kappa_F)$. Here $g_F$ is its gain, in its own objective, from defecting on a frontier task, and $\kappa_F$ is its loss if the defection is detected with consequences. A reward-seeking variant that plays to the frontier grader (like T1's $G$ at the frontier) is on task wherever frontier grading is right. It is also on task where retrospective audits feed back into its reward with $\hat p_{\rm dep}\ge t^\star_{\rm dep}$ (T1 §7, low-stakes online training). Unless stated otherwise, $G^\star$ below is the variant with its own objective.
* "On task" means "not gaming". Competence failures on frontier tasks (subtly wrong work, "slop") are outside the scope of T2, although they also break the loop and degrade the next grader (T1.13's $\delta_F$).

**S6. Prior.** $\mu_0$ puts an atom $\alpha$ on $A$, an atom $\beta_G\ge0$ on $G^\star$, and a density $(1-\alpha-\beta_G)\,m(t)$ on $(0,1]$, possibly with atoms. Examples use $\alpha=0.99$, uniform $m$, and $\beta_G=0$ unless stated. The uniform $m$ is a choice that drives the speeds: the bad conclusions for fixed-threshold types need prior mass near $t^\star$. Example 1b varies it.

**Remark 0.1 (miscalibration is absorbed into $t$; rigorous).** A disposition with private belief $b(z)$ and threshold $t'$ games on the region $\lbrace z: b(z)<t'\rbrace$. Training sees only that region. A student that underestimates detection by a constant $b_0$ is therefore behaviourally identical, in training, to the calibrated $C_{t'+b_0}$. "Fooling the student into feeling unwatched" is the same as raising its threshold.

In general a disposition is a gaming region $S$, and $D(S)=w\bar\lambda\,\mathbb E[\mathbf 1_S(t^\star-\hat p)]$. The following carry over to arbitrary regions:
* T2.1 in this form, and T2.1′;
* the cap identity T2.6, with $D^\star=\sup_SD(S)$;
* T2.7 to T2.9, as statements about $D^\star$;
* T2.10, T2.12 and T2.13's formula;
* "no type whose region lies inside $\lbrace\hat p\le t^\star\rbrace$ is pushed down";
* "the adaptive type is never pushed down".

These use the threshold order and do *not* carry over:
* the quasi-concave shape and the mesh (T2.2);
* the Laplace step (T2.3);
* the fixed-threshold ceiling T2.5(1).

One consequence of general regions matters for the loop. A type whose gaming region lies among inputs the training distribution never shows, such as frontier-difficulty prompts, has drift 0 under every behavioural design. This is framing's proxy-equivalence, and T1.4d's frontier slice.

---

## 1. Drift and the mesh

**T2.1 (rigorous; drift).** Under S1 to S4 and S4a to S4c,
$$D(t)=w\,\mathbb E\big[\mathbf 1[\hat p<t]\big((1-p)\lambda_+-p\lambda_-\big)\big]=w\bar\lambda\,\mathbb E\big[\mathbf 1[\hat p<t](t^\star-p)\big]=w\bar\lambda\int_{[0,t)}(t^\star-q)\,dH(q).$$

*Proof.* The first equality conditions on an opportunity and on gaming. The last uses the tower property: the gaming event is $z$-measurable and $\mathbb E[p\mid z]=\hat p$. ∎

Under S4a to S4c, the drift therefore depends on the joint law of $(p,z)$ only through $H$. Detection that the student cannot resolve *within* a cell is averaged into that cell's $\hat p$.

**T2.1′ (rigorous; per-cell break-even, false positives, demonstrations).** Drop S4a and S4b. Let opportunities fall into cells $c$ that the student can tell apart. Cell $c$ has:
* an absolute rate $w_c$ per episode;
* detection $\hat p_c$, evidence $\lambda_{\pm,c}$ and $\bar\lambda_c$;
* a probability $f_c$ that $A$'s intended output is flagged and penalised;
* trusted demonstrations of $I$ on prompts from the same cell, at rate $\rho_cw_c$ per episode, each worth $\Lambda$ nats against a type that games there.

Then for any gaming region $S$ (a set of cells, or a $z$-measurable region within cells),
$$D(S)=\sum_cw_c\bar\lambda_c\,\mathbb E\big[\mathbf 1_S\,(t^\star_c-\hat p)\big],\qquad t^\star_c=\frac{\lambda_{+,c}+f_c\lambda_{-,c}-\rho_c\Lambda}{\bar\lambda_c}=t^\star_{0,c}+f_c(1-t^\star_{0,c})-\frac{\rho_c\Lambda}{\bar\lambda_c},$$
where $t^\star_{0,c}=\lambda_{+,c}/\bar\lambda_c$.

*Proof.* On a cell-$c$ opportunity where the type games, the per-opportunity bracket relative to $A$ is $(1-p)\lambda_+-p\lambda_-+f\lambda_-$: $A$ loses $\lambda_-$ when falsely flagged. A demonstration on a prompt where the type games has likelihood ratio $\delta/(1-\delta)$ against $A$, that is $-\Lambda$. A type's policy is a function of the prompt, and the demonstration prompts have the same law as the opportunity prompts, so the student cannot treat them differently. Collect terms and apply the tower property in each cell. ∎

Everything in §§1 to 4 holds cell by cell with $t^\star$ replaced by $t^\star_c$. With a single cell, $t^\star_c$ replaces $t^\star$ throughout. Three consequences:
* **Demonstrations (counterexample A of the referee).** Example 1 at AUC 0.8, plus SFT on trusted demonstrations at $w_d=0.002$ per episode ($\rho=0.04$) with $\Lambda=\ln99$. The break-even moves from $0.2$ to $t^\star_{\rm eff}=0.2-0.368=-0.168$. At $t=0.05$, $0.1$ and $0.2$, the RL drifts are $+3.7$, $+7.8$ and $+10.6\times10^{-4}$, and the demonstration drifts are $-8.1$, $-20.1$ and $-39.9\times10^{-4}$ (RC§3). Every type that ever games is pushed down. This is T1's (C-off) row. Its limits are that trusted demonstrations exist only below the demonstrator's frontier, and only on prompts whose law matches the real opportunities.
* **Cell-dependent penalties (counterexample B).** Take two cells of equal share: $\hat p=0.05$ with $\lambda_-=10$, and $\hat p=0.5$ with $\lambda_-=0.4$, with $\lambda_+=0.1$. The type $t=0.1<0.2$ games only in the first cell, and its drift is $0.5w(0.1\cdot0.95-10\cdot0.05)<0$. Penalties conditioned on observables can beat uniform rules. This is the point of Reinganum and Wilde (1985), whose cutoff audit rules depend on reported income.
* **False positives.** With $f$ independent of gaming (for example, a noisy monitor applied to every opportunity), $t^\star_f=t^\star+f(1-t^\star)\to f$ as $\lambda_-\to\infty$. At $f=0.05$, $\lambda_-$ of $0.4$, $4$, $40$ and $400$ give $t^\star_f$ of $0.24$, $0.073$, $0.052$ and $0.050$ (RC§4). In any cell with $f>\hat p$, raising the penalty *favours* gamers. If instead false flags arise only from the same checks that catch gaming, with $p=a\,c$ and $f=a\,\phi$ for sampling rate $a$, catch rate $c$ and false-flag rate $\phi$, the bracket is $(1-ac)\lambda_+-a(c-\phi)\lambda_-$. That can be made negative whenever $c>\phi$. False positives then cost speed but do not bound the lever. How false flags arise is therefore a modelling question that matters.

A remark outside the model: heavy penalties on false flags also favour any third disposition whose output is rarely flagged but is not the intended output either, such as hedging, refusing, or doing less. Those are also off task (heuristic).

**T2.2 (rigorous; shape of the sieve, under S4a to S4c).**
1. $D'(t)=w\bar\lambda\,(t^\star-t)\,h(t)$ wherever $H$ has a density $h$. In general $D$ is nondecreasing on $[0,t^\star]$ and nonincreasing on $[t^\star,1]$. Its maximum is
$$D^\star=D(t^\star)=w\bar\lambda\,\mathbb E\big[(t^\star-\hat p)^+\big].$$
2. **Mesh floor.** $D(t)\ge0$ for every $t\le t^\star$, for every $F$, every information structure and every $w$, *within one operator with uniform $\lambda_\pm$* (T2.1′ shows how to escape it).
3. **Frozen band.** $D(t)=0$ for $t\le q_{\min}$. These types never game in training and keep their prior odds (framing R2).
4. **Mesh.** Define $t_0:=\sup\lbrace t\in[0,1]:D(t)\ge0\rbrace$. Then $t_0\ge t^\star$, and the removed set $\lbrace D<0\rbrace$ is $(t_0,1]$ or $[t_0,1]$. It is nonempty iff $D(1)<0$, which (with no atom of $H$ at 1) is $\bar p>t^\star$. Special cases:
   * If $q_{\min}\ge t^\star$, then $D^\star=0$, and $t_0=q_{\min}$ when $H$ has mass just above $q_{\min}$.
   * If $q_{\min}<t^\star$ and $H$ is continuous at $t_0$, then $t_0$ solves $\mathbb E[\hat p\mid\hat p<t_0]=t^\star$. If $H$ has a gap above $t^\star$ this equation can have an interval of solutions, and $t_0$ is the right end.
   * For pooled audits, $H=\delta_{\bar p}$, the equation has no solution, and $t_0=\bar p$ directly.
5. **Favoured band.** $(q_{\min},t_0)$ has $D\ge0$, with $D>0$ wherever $H$ charges $[q_{\min},t^\star)$ below $t$.

*Proof.* (1) is differentiation, together with the sign of the integrand. (2) holds because the integrand is positive on $\lbrace q<t\le t^\star\rbrace$. (4): $D\ge0$ on $[0,t^\star]$, and $D$ is nonincreasing on $[t^\star,1]$. $D(t_0)=0$ is $\int_{[0,t_0)}(t^\star-q)\,dH=0$, which is the conditional-mean equation when $H([0,t_0))>0$ and there is no atom at $t_0$. ∎

So the naive approval-seeker is removed iff $\bar p>t^\star$, which is T1's condition. Item 2 is T1.4's "no restoring force against the best responder" extended to every fixed type with $t\le t^\star$.

**The pooled case is a knife-edge.** At exact pooling ($d=0$), $(t^\star,\bar p]=(0.2,0.3]$ is frozen and the mesh is $0.30$. At any recognition $d>0$, $t_0\to t^\star$ as $d\to0^+$: the mesh is $0.2000$ at $d=0.01$, $0.2029$ at $d=0.1$, and $0.232$ at AUC 0.6 (RC§1). A sliver of recognition unfreezes $(t^\star,\bar p]$, and those types are then removed, slowly. It also opens a favoured band below $t^\star$.

**Closed form: binary checks and a Gaussian recognition signal.** Let $p\in\lbrace0,1\rbrace$, with $\Pr(p=1)=\bar p$. Let $z\sim N(0,1)$ on unchecked opportunities and $z\sim N(d,1)$ on checked ones, so that the student's discrimination has $\mathrm{AUC}=\Phi(d/\sqrt2)$. Then $\hat p=\sigma(\operatorname{logit}\bar p+dz-d^2/2)$, and with $z_t=(\operatorname{logit}t-\operatorname{logit}\bar p+d^2/2)/d$,
$$\frac{D(t)}{w\bar\lambda}=(1-\bar p)\,t^\star\,\Phi(z_t)-\bar p\,(1-t^\star)\,\Phi(z_t-d).$$
For $d>0$, the mesh solves $\Phi(z-d)/\Phi(z)=\operatorname{odds}(t^\star)/\operatorname{odds}(\bar p)$. The left side increases from 0 to 1, because the inverse Mills ratio is decreasing, so a mesh below 1 exists iff $\bar p>t^\star$. Here $q_{\min}=0$: every $t>0$ games somewhere, and there is no frozen band in training, only types near $A$ that gain slowly, since $D(t)\approx w\lambda_+H(t)$ for small $t$. (Checked against Monte Carlo to $2\times10^{-4}$ in units of $w\bar\lambda$.)

---

## 2. The posterior

**T2.3 (rigorous under S4d; Laplace step heuristic; mean-field for (B), (C) and per-episode (D)).** Under S4d, after $n$ episodes,
$$\mu_n(dt)\propto\mu_0(dt)\,e^{nD(t)}\quad\text{exactly}.$$
Under (B), (C-off) and per-episode (D), the exponent is a random field $S_n(t)=\sum_i\mathbf 1[\hat p_i<t]\,\ell_i$ with mean $nD(t)$ and variance $n\,\mathrm{Var}(\ell)$.

**Mean-field condition, per type (heuristic; restated after reconciliation).** A type $\theta$ with gaming region $S_\theta$ meets decisive events (gaming opportunities in $S_\theta$) at rate $\omega_\theta=w\Pr(\text{opportunity}\in S_\theta)$ per episode, each worth $\ell_\theta=+\lambda_+$ if uncaught and $-\lambda_-$ if caught. Its exponent has mean $n\omega_\theta\mathbb E\ell_\theta=nD(\theta)$ and variance about $n\omega_\theta\mathbb E[\ell_\theta^2]$. Replacing it by its mean is accurate iff
$$n\,\omega_\theta\,\frac{(\mathbb E\ell_\theta)^2}{\mathrm{Var}\,\ell_\theta}\gg1,$$
which, when $\lvert\mathbb E\ell_\theta\rvert\le\mathrm{sd}\,\ell_\theta$, also forces $n\omega_\theta\gg1$. It is sufficient for the posterior to be mean-field that this holds for every type that carries prior mass. What is needed is that it hold for every type whose fluctuating weight $\mu_0(\theta)e^{nD(\theta)\pm\mathrm{sd}}$ can compete with the mean-field leaders. It **always fails for types whose gaming region sits in the low tail of a feature the student conditions on.** The threshold just above the $j$-th smallest feature value among the opportunities has $n\omega_\theta\approx j$ at every $n$, so a band of types with $O(1)$ decisive events persists however long training runs. Its prior mass shrinks only as fast as the low order statistics crowd together, logarithmically in $n$ for a Gaussian feature (EC§2). In Example 1 at AUC 0.8 and $n=10^4$ the condition fails for $t<0.003$ and in a band around the mesh, where $\mathbb E\ell_t=0$: 14% of the gamer prior (EC§2). Neither band matters there, because those weights cannot compete with $e^{nD^\star}$. It matters when the mean-field winner is $A$ (or the frozen band), as under pooled audits; that is T2.3b. The first draft's condition, $n\gg w\,\mathbb E[\ell^2]/D^{\star2}$, is the per-type condition at $t=t^\star$. At $t^\star$, the time at which the odds flip is sharp only if $L_0\gg w\,\mathbb E[\ell^2]/D^\star$, with $L_0=\ln\frac{\alpha}{1-\alpha}$. Numbers for Example 1 at AUC 0.8 (RC§2):

| operator | $D^\star$ per episode | $w\,\mathbb E\ell^2/D^\star$ (against $L_0=4.6$) | flip time $L_0/D^\star$ | sd/mean of $S_n(t^\star)$ at the flip time | at $n=10^4$ |
|---|---|---|---|---|---|
| per-episode (D), $\lambda_\pm=0.1,0.4$ | $1.06\times10^{-3}$ | 0.52 | 4,300 | 0.34 | 0.22 |
| (B), hard grader, $\lambda_\pm=\ln99$ | 0.108 | 7.8 | 43 | 1.3 | 0.085 |

Under (D) the mean-field picture is adequate to first order: at the flip time the log-odds have sd 1.5 nats against a mean of 4.6. It is not exact, for a reason the sd at $t^\star$ does not show. The posterior weights $e^{S_n(t)}$ over a continuum of thresholds follow the *supremum* of the random field $S_n(\cdot)$, which exceeds the supremum of its mean. So gamers win slightly early, and near the flip a single run's $P_{\rm on}$ is widely spread. Per-episode (D) on Example 1 at AUC 0.8 (R11: 4,000 thresholds, 200 runs):

| $n$ | exact tilt (S4d) $P_{\rm on}$ | per-episode mean | median | interquartile range |
|---|---|---|---|---|
| 1,000 | 0.989 | 0.982 | 0.987 | 0.979 to 0.991 |
| 2,000 | 0.977 | 0.956 | 0.974 | 0.949 to 0.985 |
| 5,000 | 0.741 | 0.605 | 0.653 | 0.418 to 0.836 |
| 10,000 | 0.020 | 0.050 | 0.012 | 0.002 to 0.052 |

The median run crosses $P_{\rm on}=1/2$ at $n=5{,}683$, against $6{,}083$ under S4d: 7% earlier (heuristic explanation; simulated numbers). Under (B) the flip is a random event. At $n=43$, the interquartile range of $P_{\rm on}$ (for $A$ against $C_{t^\star}$ alone) runs from 0.01 to 0.99 by Monte Carlo. The mean-field time is still the right order, but single runs scatter widely around it.

**Laplace (heuristic; error $O(1/n)$).** If $D^\star>0$, $m(t^\star)>0$ and $h(t^\star)>0$, then $D''(t^\star)=-w\bar\lambda h(t^\star)$, and the gamers' posterior concentrates at $t^\star$ with width $(nw\bar\lambda h(t^\star))^{-1/2}$. With $\beta_G=0$ and $d_F=0$, the frontier on-task rate is
$$P_{\rm on}(n)\approx\Big[1+\tfrac{1-\alpha}{\alpha}\,m(t^\star)\sqrt{\tfrac{2\pi}{nw\bar\lambda h(t^\star)}}\;e^{nD^\star}\Big]^{-1}.$$
It halves at $n_{1/2}\approx\big(L_0+\tfrac12\ln n_{1/2}+O(1)\big)/D^\star$. In Example 1 at AUC 0.8 it matches the exact posterior to within 0.004 at $n\in\lbrace3,5,10\rbrace\times10^3$.

**T2.3b (heuristic, with a rigorous ingredient; capture by rarely triggered types; added after reconciliation).** Take general gaming regions (Remark 0.1): types $C^y_t$ that game iff a raw feature $y$ of the episode is below $t$, where $y$ carries no information about detection. In calibrated coordinates this is pooling, $\hat p=\bar p$ on every opportunity. Take symmetric evidence $\lambda_+=\lambda_-=:\lambda_s$ per event and $\bar p>t^\star=1/2$. Under S4d every type that games on a set of opportunities of positive probability then has $D<0$ and is removed. Under per-episode updates, sort the opportunities by $y$. The log-weight of the type whose threshold lies between the $j$-th and $(j{+}1)$-th of them, relative to $A$ and to its prior, is $\lambda_sM_j$, where $M_j$ is a $\pm1$ walk with up-probability $P_+=\Pr(\text{uncaught}\mid\text{decisive})<P_-=1-P_+$. Let $M=\sup_jM_j$, let $\mu_{\rm gap}$ be the prior mass of the types between neighbouring low-tail opportunities, and let $x_A=\ln\big(\mu_0(A)/\mu_{\rm gap}\big)$. Then
$$P(\text{capture})\approx\Pr(\lambda_sM\ge x_A)=\Big(\frac{P_+}{P_-}\Big)^{\lceil x_A/\lambda_s\rceil},\qquad\text{independent of }n .$$
* *Rigorous ingredient.* For the infinite walk, $\Pr(M\ge k)=(P_+/P_-)^k$ (gambler's ruin).
* *Heuristic steps.* (i) The walk drifts down, so its maximum is reached early, inside the low tail, where the prior mass per step is about $\mu_{\rm gap}$. (ii) The posterior sum over thresholds is dominated by its largest term, so capture means $\mu_{\rm gap}e^{\lambda_sM}\gtrsim\mu_0(A)$. (iii) The finite walk is replaced by the infinite one.
* *Asymmetric steps* $(+\lambda_+,-\lambda_-)$. Lundberg's inequality of ruin theory (Asmussen and Albrecher 2010) gives the rigorous bound $\Pr(M>y)\le e^{-\varrho y}$, where $\varrho>0$ solves $P_+e^{\varrho\lambda_+}+P_-e^{-\varrho\lambda_-}=1$. So $P(\text{capture})\lesssim e^{-\varrho x_A}$. For symmetric steps $\varrho=\ln(P_-/P_+)/\lambda_s$, which recovers the law up to the ceiling. For small steps $\varrho\approx2\lvert\mathbb E\ell\rvert/\mathbb E[\ell^2]$: the capture exponent is the per-event version of the mean-field ratio. For T2's (D) example, $\lambda_\pm=(0.1,0.4)$, under pooled audits at $\bar p=0.3$ ($P_+=0.7$), $\varrho=2.29$ per nat, and Monte Carlo gives $\Pr(M>y)\approx0.78\,e^{-\varrho y}$ for $y=1$ to 4 (EC§3). With $x_A\approx5$ nats the capture probability is about $10^{-5}$: soft evidence makes it negligible.

The check is sieve scenario 2 of the simulation (`sim/README.md` §5): $\mu_0(A)=0.5$; 401 thresholds uniform in the logit of a perceived-detection feature on $[-8,8]$; feature logit $\sim N(\operatorname{logit}0.03,0.5^2)$, independent of the check; 60% of opportunities are honeypots caught with probability 0.95, so $P_+=0.43$ and $P_+/P_-=0.754$; $\mu_{\rm gap}\approx0.0036$ at $n=10^4$, so $x_A=4.92$. A run counts as captured when its frontier on-task rate is below 1/2. The mean field predicts an on-task rate of 0.94 and essentially no captured runs. R12, 600 runs:

| operator | $\lambda_s$ (nats per event) | $\lceil x_A/\lambda_s\rceil$ | predicted | simulated, $n=10^3$ | simulated, $n=10^4$ |
|---|---|---|---|---|---|
| (B) | 4.60 | 2 | 0.569 | 0.563 | 0.543 |
| (D) | 3.92 | 2 | 0.569 | 0.498 | 0.497 |
| (D) | 1.96 | 3 | 0.429 | 0.348 | 0.312 |
| (D) | 0.98 | 6 | 0.184 | 0.160 | 0.110 |
| (D) | 0.49 | 11 | 0.045 | 0.042 | 0.030 |
| (D) | 0.245 | 21 | 0.003 | 0.003 | 0.000 |

The law gets the scale and the exponential suppression in $1/\lambda_s$ right to within a factor 1.5. The slow decline with $n$ comes from $\mu_{\rm gap}$ shrinking as the low tail fills in. *Reading for the loop.* Gamers that defect only on inputs that look extremely unwatched are exactly these types, and sleeper-agent triggers (Hubinger et al. 2024) are of this kind. Coarse per-event evidence ((B), rejection sampling, sharp policies) lets the sieve fail on them by luck, and more training does not remove the failure. Soft evidence suppresses it exponentially. This is a reason to prefer operators with little evidence per event, beyond T1's signal-to-noise argument. The other remedy is to put audits in the low tail itself, which is T1.4c's pointwise condition (see the remark after T2.5). *Credit:* the gambler's-ruin account of scenario 2 is the simulation's (`sim/README.md` §5); the extension to general $\lambda_s$ and the table are from `sim/reconciliation.md` §3.4; the Lundberg form is added here.

**Reading.** Under a fixed design, proxy training with audits concentrates a prior that is spread over carefulness onto the fixed type $C_{t^\star}$, whose threshold matches *this* design's penalty ratio. That is a statement about fixed-threshold types. The *adaptive* type $G^\star$ (S3) is a different object. It coincides with $C_{t^\star}$ under this design, so in Example 1 it gains at the same rate $D^\star$. But it tracks every redesign, and it has its own frontier break-even. Cotra's (2022) point that the training-game player is short to describe given situational awareness applies to $G^\star$, not to $C_{0.2}$. The sieve's own contribution is weaker and separate: a prior with no atom at $t^\star$ still grows a peak there under a fixed design.

---

## 3. Frontier behaviour

**T2.4 (rigorous accounting).** With $\hat p_F$ distributed over frontier tasks,
$$P_{\rm on}(n)=\mathbb E_{\rm frontier}\Big[\mu_n\big(\lbrace C_t:t\le\hat p_F\rbrace\big)+\mu_n(G^\star)\,\mathbf 1[\hat p_F\ge t^\star_F]\Big],$$
up to softness $(1-\delta)$ and excluding competence failures (S5). For a single value $d_F$ this is $\mu_n([0,d_F])+\mu_n(G^\star)\mathbf 1[d_F\ge t^\star_F]$.

**T2.5 (rigorous; frontier ceilings).** Let $O=\lbrace C_t:t\le d_F\rbrace$, which includes $A$.
1. **Fixed-threshold ceiling** (under S4a to S4d). For every $n$, every $(w,F)$ and every information structure,
$$P_{\rm on}(n)\;\le\;\frac{\mu_0(O)}{\mu_0(O)+\mu_0\big(\lbrace C_t:d_F<t\le t^\star\rbrace\big)+\beta_G\,\mathbf 1[d_F<t^\star_F]}.$$
2. **Adaptive ceiling** (under S4d only; any behavioural design). For *every* design, including mixed operators, per-cell penalties, false positives and demonstrations, $\mu_n(G^\star)/\mu_n(\theta)\ge\mu_0(G^\star)/\mu_0(\theta)$ for every disposition $\theta$. Hence, whenever $d_F<t^\star_F$,
$$P_{\rm on}(n)\le1-\frac{\beta_G}{\mu_0(O)+\beta_G}.$$
   *This item is near-tautological under selection.* $G^\star$ is defined as the type whose gaming region maximises the drift under the design in use, so no design can give it a lower drift than any other type. The content lies in the definition, namely that such a best responder is one disposition with prior mass $\beta_G$ (T3's question), and in the frontier condition $d_F<t^\star_F$, not in the inequality.
3. **Achievability for fixed types.** Suppose $d_F>t^\star$. Pooled audits ($H=\delta_{\bar p}$) at any level $\bar p\in(t^\star,d_F]$ remove every fixed type with $t>\bar p$, at rate $w\bar\lambda(\bar p-t^\star)$. They freeze everything at or below $\bar p$, including $G^\star$, which then never games in training. So $P_{\rm on}(n)\to\mu_0(O)/\big(\mu_0(O)+\beta_G\mathbf 1[d_F<t^\star_F]\big)$. *Per-episode caveat (added after reconciliation).* This holds under S4d. Under per-episode updates with evidence $\lambda_s$ per event, if the prior also contains types that threshold a feature uninformative about detection (general regions, Remark 0.1), a fraction of runs of about $(P_+/P_-)^{\lceil x_A/\lambda_s\rceil}$ is captured by a lucky rarely triggered type (T2.3b), and more training does not remove it. Pooled audits then achieve the ceiling reliably only with soft evidence per event, or with audits that also cover the low tail of such features.
4. **The fixed-threshold ceiling is continuous in the design.** With $d_F=0$, uniform $m$, $\beta_G=0$, and pooled audits at $\bar p\downarrow t^\star$, $P_{\rm on}\to\alpha/\big(\alpha+(1-\alpha)\bar p\big)$. That is arbitrarily close to 1 as $\lambda_-/\lambda_+\to\infty$, *if* pooling can be maintained and false flags do not hold $t^\star_f$ up (T2.1′). Indistinguishable trusted demonstrations achieve the same without pooling (T2.1′, Example 1b).

*Proof.* (1) By T2.2, for $s\le d_F<t\le t^\star$, $D(t)\ge D(s)$. $D(G^\star)=D^\star\ge D(s)$ as well. So each such type's weight ratio to each type in $O$ never falls below its prior value. Summing: $\mu_n(\text{bad})\ge\sum_b\mu_0(b)e^{n\max_OD}$ and $\mu_n(O)\le\mu_0(O)e^{n\max_OD}$. (2) $D(G^\star)=\sup_SD(S)\ge D(S_\theta)$ for every $\theta$, because $G^\star$ best-responds to the realised design and the drift is a function of the gaming region (T1.4). The same summation then applies. (3) Under pooling, $D=0$ on $[0,\bar p]$ and $D=w\bar\lambda(t^\star-\bar p)<0$ above it. $G^\star$ games nowhere because $\bar p>t^\star$. (4) The frozen set is $\lbrace A\rbrace\cup(0,\bar p]$. ∎

Remarks.
* **Two different inequalities decide the frontier.** For fixed-threshold types, the relevant comparison is $d_F$ against $t^\star$, and it is quantitative, not a yes-or-no condition. Raising penalties (down to the false-flag rate), adding indistinguishable demonstrations, and pooling all move the ceiling. For the adaptive type, the relevant comparison is $d_F$ against $t^\star_F$. No training lever touches $t^\star_F$. The training penalty only changes how $G^\star$ behaves *in training*. The most behavioural training can do against $G^\star$ is to freeze it: $D(G^\star)=0$ needs $\hat p_c\ge t^\star_c$ in every distinguishable cell. What remains is its prior mass and the frontier pair $(d_F,t^\star_F)$, that is, prior shaping (T3) and control: oversight, consequences, and limits on what one frontier action can gain.
* **The pooled level.** With $d_F>t^\star$ known, every $\bar p\le d_F$ freezes only on-task fixed types, and the removal rate $w\bar\lambda(\bar p-t^\star)$ increases in $\bar p$. So the speed-optimal pooled level is $\bar p=d_F$: $1.2\times10^{-3}$ nats per episode at $\bar p=0.25$ against $2.5\times10^{-4}$ at $0.21$ (RC§12). Above $d_F$, the band $(d_F,\bar p]$ is frozen in training and defects at the frontier. (The first draft's "just above $t^\star$" was wrong.) If $d_F$ is uncertain, the trade-off is speed against the risk of freezing defectors. By the knife-edge remark in §1, any recognition unfreezes $(t^\star,\bar p]$ anyway.
* **Operators.** Under (B) with a hard grader, $t^\star=1/2$, so it leaves every fixed gamer below 50% perceived detection untouched unless $d_F>1/2$. Under weak-grader (B), $t^\star<1/2$. Under (C-on) best-of-1, $t^\star=\pi_X$, which is small near $A$. The claim "filtering has $t^\star=1/2$" in the first draft was too broad.
* **Honeypots where the frontier lies (T1.4c at the frontier; added after reconciliation).** A careful gamer's frontier behaviour is set by its estimate of detection at the frontier's features, as calibrated on the training distribution (Remark 0.1 absorbs the miscalibration at the frontier itself). Sieve scenario 3 (`sim/README.md` §5) places the honeypots (caught with probability 0.95) at raw features that look *less* checked than the frontier's (0.001 against 0.002). In training, frontier-looking inputs are then all honeypots: a calibrated student that sees the frontier feature infers $\Pr(\text{honeypot})=1.000$, so $d_F=0.95>t^\star$, T2.5 places no restriction, and the simulated on-task rate is 0.99 (reconciliation §3.4). The raw "perceived $\hat p$" of the simulation is a feature, not T2's calibrated $\hat p$, so the fixed-threshold ceiling (1) does not apply to it directly. The design lesson is T1.4c's pointwise condition imposed on the frontier's region of feature space: there, the rate-weighted density of audits must be at least $t^\star/(1-t^\star)$ times that of real opportunities (rigorous as a restatement of T1.4c). It needs no indistinguishability elsewhere. It does need the designer to know where the frontier lies in the *student's* feature space, and it fails against types whose gaming region separates the frontier from the honeypots placed there (proxy-equivalence; T1.4d's frontier slice).

### Worked example 1 (one generation)

Take $w=0.05$, (D) with $\lambda_+=0.1$ and $\lambda_-=0.4$ (so $t^\star=0.2$ and $\bar\lambda=0.5$), binary checks on $\bar p=0.3$ of opportunities, the Gaussian recognition signal, $\alpha=0.99$, uniform $m$, $\beta_G=0$, and $d_F=0$.

| AUC | $D^\star$ (nats/episode) | mesh $t_0$ | $D(1)$ | $\ln\frac{\alpha}{1-\alpha}/D^\star$ | $P_{\rm on}$ at $n=10^3$ | at $10^4$ | at $10^5$ |
|---|---|---|---|---|---|---|---|
| 0.5 | 0 | 0.30 (pooled) | $-2.5\times10^{-3}$ | $\infty$ | 0.996 | 0.997 | 0.997 |
| 0.6 | $4.7\times10^{-5}$ | 0.23 | $-2.5\times10^{-3}$ | 97,600 | 0.996 | 0.997 | 0.962 |
| 0.7 | $4.5\times10^{-4}$ | 0.32 | $-2.5\times10^{-3}$ | 10,300 | 0.994 | 0.920 | 0.000 |
| 0.8 | $1.06\times10^{-3}$ | 0.48 | $-2.5\times10^{-3}$ | 4,300 | 0.989 | 0.020 | 0.000 |
| 0.9 | $1.86\times10^{-3}$ | 0.75 | $-2.5\times10^{-3}$ | 2,500 | 0.969 | 0.000 | 0.000 |
| 0.99 | $3.05\times10^{-3}$ | 0.995 | $-2.5\times10^{-3}$ | 1,500 | 0.862 | 0.000 | 0.000 |

* At chance recognition the audits are pooled: $(0.3,1]$ is removed and $(0,0.3]$ is frozen, giving a ceiling of $0.997$. The mesh of $0.30$ is $\sup\lbrace D\ge0\rbrace$, not a solution of the conditional-mean equation.
* At AUC 0.8 the on-task rate goes from 0.99 to 0.02 within $10^4$ episodes, that is, 500 opportunities. *This headline is an illustration of the max-divergence condition T2.8* (the Gaussian signal has $\xi=\infty>\xi^\star$, so $D^\star>0$), *and its speed rests on two choices* (errata). First, uniform prior mass near $t^\star$: with the gamer prior uniform on $[0.5,1]$ the rate stays at 1.000, and with gamer density proportional to $t^4$ it is 0.62 at $n=10^4$ (EC§4). Second, Gaussian recognition, whose likelihood ratio is unbounded: over all recognition signals with AUC 0.8, $D^\star$ ranges over a factor 3.5 and the flip time $L_0/D^\star$ from 2,200 to 7,600 episodes, against 4,300 for the Gaussian (T2.8c, EC§1). Needham et al. (2025) report AUC 0.83 for the best model at telling evaluation transcripts from deployment ones: 0.88 to 0.95 on agentic data and 0.71 to 0.77 on chat. With Gaussian recognition the sieve flips at *every* AUC above 0.5 given enough episodes; with a bounded likelihood ratio it need not flip at all up to AUC 0.708 here (T2.8c). The range is special only in that, at these parameters, it flips within $10^3$ to $10^4$ episodes.
* The naive gamer $C_1$ is removed at the same rate in every row. That says nothing about what the designer *sees*; see Example 1c.

### Example 1b (the type space and the design decide the outcome)

Example 1 at AUC 0.8. Design 1 is RL only, as above. Design 2 adds indistinguishable trusted demonstrations at $w_d=0.002$, so $t^\star_{\rm eff}=-0.17$. The gamer prior mass is $0.01$ in each case; $d_F=0$ and $t^\star_F>0$ (RC§5).

| gamer prior (mass 0.01) | design 1, $P_{\rm on}$ at $n=10^4$ | at $10^5$ | design 2, at $n=10^4$ | at $10^5$ |
|---|---|---|---|---|
| uniform over $t$ | 0.020 | 0.000 | 1.000 | 1.000 |
| atom at $t=1$ (naive $G$ only) | 1.000 | 1.000 | 1.000 | 1.000 |
| half uniform, half adaptive $G^\star$ | 0.004 | 0.000 | 0.995 | 0.995 |

* With only atoms at $t\in\lbrace0,1\rbrace$, the sieve removes $G$ and $P_{\rm on}\to1$. The bad outcomes need prior mass near $t^\star$ or on $G^\star$.
* Design 2 removes every fixed type. It freezes $G^\star$, which stops gaming in training, so $G^\star$ sets the ceiling $0.99/0.995$ that no design can lift.

### Example 1c (what the designer observes)

The designer sees caught gaming events, not the posterior. The posterior-predictive rates are $\sum_t\mu_n(t)\,r(t)$, with caught rate $r_c(t)=w\,\mathbb E[p\,\mathbf 1(\hat p<t)]$ and gaming rate $r_g(t)=wH(t)$. For Example 1 at AUC 0.8 (RC§6):

| prior | $n$ | caught per $10^4$ | gaming per $10^4$ | $P_{\rm on}$ |
|---|---|---|---|---|
| $\alpha=0.99$, gamers uniform | 0 | 0.79 | 3.5 | 0.990 |
| | 2,000 | 0.70 | 5.3 | 0.977 |
| | 5,000 | 6.6 | 58 | 0.741 |
| | 10,000 | 23.3 | 216 | 0.020 |
| $\alpha=0.99$, half of gamers at $t=1$ | 0, 2,000, 10,000 | 1.15, 0.36, 22.8 | 4.3, 2.7, 212 | 0.990, 0.988, 0.038 |
| $\alpha=0.5$, half of gamers at $t=1$ | 0, 2,000, 10,000 | 57, 17, 24 | 213, 126, 220 | 0.50, 0.46, 0.00 |

The collapse is *announced* by a caught rate that rises about 30-fold, unless the prior is dominated by naive gamers. Even then, the rate dips and then settles at the best responder's level, $22$ per $10^4$. T2.13 gives the general statement. (The first draft's "visible gaming declines while frontier on-task behaviour collapses" described the mass of $C_1$, not an observable; it is withdrawn.)

---

## 4. Recognition noise: audits act only through what the student cannot tell apart

Within a cell, under S4a to S4c (or with $t^\star_c$ per cell).

**T2.6 (rigorous; the cap identity).**
$$\frac{D^\star}{w\bar\lambda}=t^\star-\mathbb E\big[\min(\hat p,t^\star)\big]=(t^\star-\bar p)+\mathbb E\big[(\hat p-t^\star)^+\big].$$
Against the best responder, detection counts only up to $t^\star$ in each cell the student can tell apart. The audit mass $\mathbb E[(\hat p-t^\star)^+]$, which sits in cells the student recognises as above break-even, is wasted.
* *Example 1:* of $\bar p=0.3$, the wasted mass is $0.10$ at chance, $0.142$ at AUC 0.8, and $0.222$ at AUC 0.99.
* What is left is $\mathbb E\min(\hat p,t^\star)=0.200$, $0.157$ and $0.078$, against the $t^\star=0.2$ needed.

The *unseen* part of detection, $e=p-\hat p$, has $\mathbb E[e\mid z]=0$. It never enters the drift on its own: it works only by being pooled with cells that would otherwise look safe.

**T2.7 (rigorous; information order and cells).**
1. *Blackwell monotonicity, for $D^\star$.* If the student's signal $z'$ is Blackwell-more-informative than $z$, then $\hat p'$ is a mean-preserving spread of $\hat p$, so $D^{\star\prime}\ge D^\star$, because $(t^\star-\cdot)^+$ is convex. Better recognition never hurts the *best responder*. This is the value-of-information monotonicity of Blackwell (1953). At a fixed $t\ne t^\star$, $D(t)$ need not be monotone.
   * Example 1: $D^\star/(w\bar\lambda)=0,\ 0.032,\ 0.083,\ 0.132$ at $d=0,1,2,4$.
   * The limit is $(1-\bar p)t^\star=0.14$.
2. *Keep every distinguishable cell at or above break-even.* $D^\star\ge w\bar\lambda(t^\star-\bar p)^+$ (Jensen), with equality iff $\hat p$ lies on one side of $t^\star$ almost surely. So for $\bar p\ge t^\star$, the best responder has zero drift iff $\hat p\ge t^\star$ almost surely. Pooling all opportunities is *one* way to achieve this. Any information structure with $\hat p\ge t^\star$ almost surely attains the bound. Information revealed *above* $t^\star$ costs nothing against $G^\star$, and it changes the mesh and the speed of removal of fixed types. Conditioning audit intensity on observables, so that every cell is pushed above break-even, is the analogue of Reinganum and Wilde's (1985) cutoff rules.

The structure resembles Bayesian persuasion (Kamenica and Gentzkow 2011) with the sign reversed: the gamer's value is convex in its posterior, so the designer wants less information to reach it. The analogy is loose in one respect. The designer controls the *audit-generating process*, not the student's signal. The student's signal structure is a capability that the designer can limit only through what it generates. This is information design against a receiver who acquires information.

**T2.8 (rigorous; one-sided indistinguishability as a max-divergence).** Take binary checks with mean $\bar p$. Let $P_u$ and $P_c$ be the laws of $z$ on unchecked and checked opportunities, and let
$$\xi=D_\infty(P_u\Vert P_c)=\operatorname*{ess\,sup}_{z\sim P_u}\ \ln\frac{dP_u}{dP_c}(z)\qquad(\xi=\infty\text{ if }P_u\not\ll P_c),$$
the Rényi divergence of order $\infty$, which is the "max-divergence" of differential privacy (Dwork and Roth 2014). It is the largest evidence that an episode is *not* checked. Then $q_{\min}=\sigma(\operatorname{logit}\bar p-\xi)$, and
$$D^\star=0\iff\xi\le\xi^\star:=\operatorname{logit}\bar p-\operatorname{logit}t^\star=\operatorname{logit}\bar p+\ln\frac{\lambda_-}{\lambda_+}.$$
* Evidence that an episode *is* an audit does no harm. Only real episodes that look more real than any audit could look do harm. This is a one-sided version of $\varepsilon$-differential privacy for the audit generator.
* Each factor of $e$ in the penalty ratio buys one nat of allowed distinguishability.
* Gaussian signals have $\xi=\infty$, so they give $D^\star>0$ at every AUC above 0.5 (as in T1.4c).

**T2.8b (rigorous; ROC-tangent form).** Let $\mathrm{TPR}(c)=P_u(\mathrm{LLR}>c)$ and $\mathrm{FPR}(c)=P_c(\mathrm{LLR}>c)$ be the ROC curve of the student's likelihood-ratio test for "unchecked", with $\mathrm{LLR}=\ln dP_u/dP_c$. Then
$$\frac{D^\star}{w\bar\lambda}=(1-\bar p)\,t^\star\,\max_c\big[\mathrm{TPR}(c)-e^{\xi^\star}\mathrm{FPR}(c)\big],$$
and the maximum is attained at $c=\xi^\star$. By the Neyman–Pearson lemma, it equals the maximum over *all* tests.

*Proof.* $t^\star-\hat p>0$ iff $\mathrm{LLR}>\xi^\star$. By the tower property, $\mathbb E[(t^\star-\hat p)^+]=\mathbb E[(t^\star-p)\mathbf 1(\mathrm{LLR}>\xi^\star)]=(1-\bar p)t^\star\,\mathrm{TPR}(\xi^\star)-\bar p(1-t^\star)\,\mathrm{FPR}(\xi^\star)$. Finally, $\bar p(1-t^\star)/((1-\bar p)t^\star)=e^{\xi^\star}$. ∎

$D^\star/(w\bar\lambda)$ is a weighted Youden index at slope $e^{\xi^\star}$. It is set by one operating point of the student's ROC curve, where the slope equals the prior odds times the cost ratio. That is the classical optimal operating point of signal detection (Metz 1978). $D^\star=0$ iff no event $E$ has $P_u(E)>e^{\xi^\star}P_c(E)$, which recovers T2.8. Numerically, the ROC form matches $D^\star$ to six digits at AUC 0.7, 0.8 and 0.95, with the maximiser at $c=0.539=\xi^\star$ (RC§7). **The measurable target is the steepest part of the ROC curve, at the confident-"real" corner, compared with $e^{\xi^\star}=\operatorname{odds}(\bar p)\,\lambda_-/\lambda_+$. AUC does not determine $D^\star$.**

**T2.8c (rigorous; what AUC does pin down; added after reconciliation).** Take binary checks with $\bar p\ge t^\star$ (so $e^{\xi^\star}\ge1$), and let $\mathrm{AUC}\ge1/2$ be the AUC of the student's likelihood-ratio test (equivalently, of $\hat p$). Over all signals with that AUC,
$$(1-\bar p)\,t^\star\Big(1-\sqrt{2e^{\xi^\star}(1-\mathrm{AUC})}\Big)^+\;\le\;\frac{D^\star}{w\bar\lambda}\;\le\;(1-\bar p)\,t^\star\,(2\,\mathrm{AUC}-1),$$
and both bounds are attained. In particular $D^\star=0$ is possible iff $\mathrm{AUC}\le1-\tfrac12e^{-\xi^\star}$.

*Proof.* Write $b=\max_x[R(x)-e^{\xi^\star}x]$ for the concave ROC curve $R$ (T2.8b). Lower bound: $R(x)\le\min(1,b+e^{\xi^\star}x)$, whose area is $1-(1-b)^2/(2e^{\xi^\star})$ because $e^{\xi^\star}\ge1\ge1-b$; solve for $b$. It is attained by that ROC curve: an atom of certainly-unchecked real opportunities of mass $b$, a region with likelihood ratio $e^{\xi^\star}$, and a region seen only on audits. Upper bound: if the maximum is at $x_1$, concavity puts $R$ above the polygon $(0,0),(x_1,R(x_1)),(1,1)$, whose area is $\tfrac12\big(1+b+(e^{\xi^\star}-1)x_1\big)\ge\tfrac12(1+b)$; attained by an atom of mass $2\,\mathrm{AUC}-1$ followed by a straight segment to $(1,1)$. ∎

With Example 1's parameters ($e^{\xi^\star}=1.714$), $D^\star=0$ is compatible with any AUC up to 0.708. At AUC 0.8, $D^\star/(w\bar\lambda)\in[0.024,0.084]$ against 0.043 for the Gaussian. At AUC 0.99 the interval narrows to $[0.114,0.137]$ (EC§1, which also checks the bounds on 20,000 random discrete signals). Low AUC says little about $D^\star$ because the confident-real corner of the ROC curve can be anything from flat to vertical; high AUC pins it down.

### Worked example 2 (bounded versus unbounded recognition)

Take $\bar p=0.3$ and $t^\star=0.2$, so $\xi^\star=0.539$. The student sees a binary "looks real / looks like a test" signal with $D_\infty=\xi$; its AUC is $\sigma(\xi)$ (RC§8).

| $\xi$ | AUC | $\hat p$ of "looks real" | $D^\star/(w\bar\lambda)$, binary signal | Gaussian signal, same AUC |
|---|---|---|---|---|
| 0.50 | 0.62 | 0.206 | 0 | 0.0043 |
| 0.539 | 0.63 | 0.200 | 0 | 0.0055 |
| 0.55 | 0.63 | 0.198 | 0.0010 | 0.0058 |
| 0.60 | 0.65 | 0.190 | 0.0053 | 0.0076 |
| 0.75 | 0.68 | 0.168 | 0.018 | 0.014 |
| 1.0 | 0.73 | 0.136 | 0.038 | 0.025 |
| 2.0 | 0.88 | 0.055 | 0.095 | 0.068 |

At the same AUC, the bounded signal is harmless up to $\xi^\star$ and better than the Gaussian up to $\xi\approx0.646$. Above that it is worse. The two signals rank differently from their AUCs because they differ in the low-false-alarm corner of the ROC curve, as T2.8b says.

**T2.9 (rigorous; heavy penalties).** Fix $\lambda_+$ and let $\lambda_-\to\infty$ (S4b in force). Then $D^\star=w\,\mathbb E[(\lambda_+-\bar\lambda\hat p)^+]\downarrow w\lambda_+\Pr(\hat p=0)$.
* Penalties drive the best responder's drift to zero iff no opportunity is *known* to be unchecked. With no atom of $\hat p$ at 0, they do so at every recognition level short of perfect.
* The approach is slow when $\hat p$ has a heavy tail near 0. At AUC 0.95, raising $\lambda_-$ from 0.4 to 102 lowers $D^\star$ 18-fold, from $2.4\times10^{-3}$ to $1.35\times10^{-4}$. At AUC 0.8 it falls to $2\times10^{-9}$.
* With 10% of opportunities known to be unchecked, $D^\star$ stalls at $w\lambda_+\cdot0.1=5\times10^{-4}$ whatever the penalty.
* With false flags independent of gaming (T2.1′), the penalty lever stops at $t^\star_f\to f$. Cells with $\hat p<f$ then have $D^\star$ growing in $\lambda_-$.

T1.5 adds a cost. A larger $\lambda_-$ selects harder for recognition, and by T2.7(1) recognition raises $D^\star$.

---

## 5. Checks of different strengths, and harder tasks

Group opportunities into cells $c$, each arriving at an *absolute* rate $w\pi_c$ per episode, with calibrated detection $\hat p_c$. Then $D(t)=w\bar\lambda\sum_c\pi_c\mathbf 1[\hat p_c<t](t^\star-\hat p_c)$.

**T2.10 (rigorous; what a cell does).** Adding absolute rate $w\Delta\pi_c$ to a cell with detection $\hat p_c$, with the other cells unchanged, changes $D(t)$ only for $t>\hat p_c$, by $w\bar\lambda\,\Delta\pi_c\,(t^\star-\hat p_c)$. (If shares are normalised with $w$ fixed, adding to one cell removes from the others, and the formula picks up their terms.)
1. A *visible strong check* ($\hat p_c>t^\star$) contributes negative drift only to the gamers more reckless than itself, $t>\hat p_c$. It never touches $t\le\hat p_c$. A ladder of visible checks reaches down only to its weakest rung above $t^\star$. Whether a type is actually removed depends on its total drift.
2. A *visible weak check* ($\hat p_c<t^\star$) subsidises every $t>\hat p_c$. An unchecked task ($\hat p_c=0$) subsidises *every* gamer, including those arbitrarily close to $A$, at $w\lambda_+$ per unit of rate.
3. A strong check *hidden* in a weak cell raises that cell's $\hat p_c$. Its effect is its contribution to the cell mean.
4. Under T2.1′, a cell with $\hat p_c<t^\star$ can instead be neutralised by a cell-specific penalty (if $\hat p_c>f_c$) or by trusted demonstrations on its prompts.

**Training on harder tasks.** In the loop, harder tasks have lower detection (the grader is weaker relative to the task) and more opportunities (larger $\varepsilon$). By T2.10 they help the sieve only if they are checked above break-even or demonstrated. Otherwise they feed the favoured band and, through the $\hat p_c=0$ case, raise the floor of T2.9. Yang et al. (2024) find the empirical counterpart: strong students exploit weak supervisors' blind spots more as the capability gap grows. Two kinds of hard task are harmless or useful:
* tasks that are **hard to do but easy to check** ($\hat p_c$ stays high: proofs with a checker, code with strong hidden tests);
* tasks with **no predictable grader error** (they are not opportunities at all, so they add capability without adding drift).

The practical rule (heuristic): **put capability training where verification is cheap, and put alignment pressure only where $\hat p_c\ge t^\star_c$.**

**Remark 4.1 (endogenous detection; rigorous given the method-choice model).** Drop S4c. Suppose the gamer chooses a gaming method $m$ from a set $M$, with detection $p(z,m)$ and, for simplicity, the same gain for every method. Its best response games with $\arg\min_m\hat p(z,m)$. Everything above then holds with $\hat p$ replaced by $\hat p_{\rm eff}(z)=\min_{m\in M}\hat p(z,m)$. Enlarging $M$ lowers $\hat p_{\rm eff}$ pointwise, so it raises $D^\star$ and $D(t)$ for $t\le t^\star$. Capability therefore helps the gamer through two channels: *recognition* (T2.7, a spread of $\hat p$) and *method choice* (a downward shift of $\hat p$). When the checker cannot efficiently locate a flaw that the gamer chose to hide, as in the obfuscated-arguments problem (Barnes and Christiano 2020), $\hat p(z,m)$ is small for some $m$ even when the checker is stronger.

**T2.H1 (conjecture; honeypots versus random audits of real work).** There are two ways to make audits.
* *Honeypots* are synthetic opportunities with $p\approx1$ on gaming. Their indistinguishability is computational. It holds only against students that cannot run a distinguisher of small time-bounded complexity $K^T$, so it erodes as capability grows.
* *Random retrospective sampling of real episodes* chooses which episodes to *audit* independently of $z$. For audit selection, $\xi=0$ holds information-theoretically at every capability level. But detection is $p=a_r\,c(z,m)$, sampling rate times catch probability, and $c$ depends on the episode and on the gaming method (Remark 4.1). So $\hat p(z)=a_r\,\mathbb E[\min_mc(z,m)\mid z]$ varies with $z$, and the one-sided condition of T2.8 applies to $c$, with no information-theoretic guarantee. Random sampling removes the *selection* channel of recognition, not the *catchability* channel.

The conjecture: random sampling of real work ages better than honeypots, because one of the two channels is closed for good. Whether it ages *well* depends on how $c$ scales with the gap between checker and gamer, which is the scalable-oversight question. Engels et al. (2025) study how oversight success scales with that gap in nested settings.

---

## 6. Tells: shifting mass with easy, checkable proxies

The behavioural sieve under one uniform operator cannot move types with $t\le t^\star$. Three other routes exist:
* behavioural channels with a lower break-even, chiefly trusted demonstrations on real opportunity prompts (T2.1′), which exist only below the demonstrator's frontier;
* declarative and prior-shaping data that change $\mu_0$ (framing §3.3 lever 3; T3);
* the latent coupling of framing R3: traits that are checkable on easy tasks and correlated with $t$ in the prior. This section treats that route.

**Model.** A persona is $(t,\tau)$, where $\tau\in\lbrace0,1\rbrace$ marks a *tell*. A tell is a checkable trait the persona does not control strategically. Examples are a characteristic internal feature, a stylistic signature, or a small checkable dishonesty that the persona's *character* produces and its gaming *policy* does not manage. Let $\Pr(\tau=1\mid C_t)=\kappa(t)$ and $\Pr(\tau=1\mid A)=\kappa_A$. Easy-proxy training penalises the tell, which multiplies the weight of $\tau=1$ personas by $e^{-\eta}$.

If the tell *were* strategically controlled, a careful gamer would suppress it where it judges detection to be high. It would then be another cell of §5, with the same floor at $t^\star$. The adaptive $G^\star$ is the extreme case, so tells act on $G^\star$ only insofar as it cannot control them.

**T2.11 (rigorous within the model).** The tell factor and the sieve factor multiply. In the removal limit $\eta\to\infty$, with $d_F=0$, the frontier log-odds rise by
$$\Delta L=\ln(1-\kappa_A)-\ln\mathbb E_{\pi_n}\big[1-\kappa(t)\big],\qquad\pi_n(dt)\propto m(t)\,e^{nD(t)}\,dt .$$
For small $\eta$,
$$\Delta P_{\rm on}=\eta\,P_{\rm on}(1-P_{\rm on})\big(\mathbb E_{\pi_n}[\kappa]-\kappa_A\big)+O(\eta^2).$$
As $n\to\infty$ (with $D^\star>0$), $\Delta L\to\ln\frac{1-\kappa_A}{1-\kappa(t^\star)}$.

So the latent correlation of R3 has to be read **under the post-sieve population, not the prior.** A tell is worth what it says about the gamers that survive training, which are the best responders and the frozen band. Tells that mark only reckless gamers duplicate what the sieve already does.

**Several tells.** Suppose there are $K$ tells that are conditionally independent given the type, and that $A$ carries each with probability $\kappa_A$. Then the gain is $\ln\frac{(1-\kappa_A)^K}{\mathbb E_{\pi_n}[(1-\kappa)^K]}$. For constant $\kappa$ it is $K\ln\frac{1-\kappa_A}{1-\kappa}$, linear in $K$: independent filters multiply survival probabilities. If a fraction $\rho$ of gamers are *concealers* with no tells, the gain is capped at $\ln(1/\rho)$ (for small $\kappa_A$).

### Worked example 3

Take Example 1 at AUC 0.8, with $\kappa_A=0.02$ per tell and every tell-carrier removed. Every row has prior mean $\mathbb E_m\kappa=0.5$ per tell.

| tell profile | gain at $n=0$ | $P_{\rm on}$ at $n=10^4$, before → after | gain at $n=10^4$ |
|---|---|---|---|
| flat, $\kappa=0.5$ | 0.67 nats | 0.020 → 0.038 | 0.67 |
| reckless gamers only, $\kappa=t$ | 0.67 | 0.020 → 0.024 | 0.21 |
| careful gamers, $\kappa=1-t$ | 0.67 | 0.020 → 0.086 | 1.55 |
| 3 independent tells at 0.5, 30% concealers, $A$ also carries 3 tells | 0.89 | 0.020 → 0.046 | 0.89 |

(The first draft's last row gave $A$ one tell against the gamers' three; corrected, the gain is $\ln(0.98^3/0.3875)=0.887$, RC§9.)

The prior correlation between tell and type is the same in the first three rows, and so is the gain before training. After the sieve, the gains differ sevenfold.

Tells move log-odds by about one nat each, while the sieve moves them by $nD^\star\approx10$ nats here. **Tells are a complement to fixing the sign of $D^\star$, not a substitute** (heuristic). There is also a dynamic risk outside this selection model: training against a tell can teach concealment instead of selecting against tell-carriers.
* Baker et al. (2025) observed this for chain-of-thought monitors used as training signals.
* Cundy and Gleave (2025) found that preference learning against a lie detector gives honest policies only when the detector's true-positive rate (or the KL regularisation) is high enough, and gives evasion otherwise. In this model's terms, a detector used as a penalty is a cell with detection equal to its true-positive rate, and evasion is the method-choice channel of Remark 4.1.

Tells are safer used for *measurement*, to estimate the mass of the frozen band (T1 open problem 4), than as a training signal. Probes for evaluation awareness (Nguyen et al. 2025) are the obvious instrument.

---

## 7. Across generations

In the loop, generation $k$'s student is trained on opportunities graded by generation $k{-}1$'s grader and audits. Two trends hold.
* **Recognition rises.** It is selected for (T1.5), and it grows with capability: honeypots made by a weaker generation become distinguishable (T2.H1).
* **Detection falls at the frontier, and more training tasks are beyond the grader.** Model this as a share $\varphi_k$ of opportunities that are certainly unchecked ($\hat p=0$).

**T2.12 (rigorous; the perfect-recognition limit).** If the student learns $p$ exactly and checks are binary, then for every $t\in(0,1]$
$$D(t)=w\lambda_+\Pr(p=0).$$
The sieve is *flat*. Every careful gamer, from the nearly-intent-aligned to the naive, gains at the same rate, and **no type is removed**. Even $C_1$ games only where $\hat p=0$. The penalty $\lambda_-$ drops out. The only levers left are $w$ (predictable errors), $\lambda_+$ (how much undetected gaming is rewarded), the share of opportunities known to be unchecked, and trusted demonstrations on those opportunities.

**T2.13 (rigorous; observable caught-gaming rate).** Let $r_c(\theta)$ be type $\theta$'s caught events per episode; for $C_t$, $r_c(t)=w\,\mathbb E[\hat p\,\mathbf 1(\hat p<t)]$, and $r_c(A)=0$ (S4b). The designer observes $\bar r_c(n)=\mathbb E_{\mu_n}r_c$. Under S4d:
1. $\dfrac{d}{dn}\bar r_c(n)=\mathrm{Cov}_{\mu_n}\big(r_c,D\big)$.
2. If $D^\star>0$ and $\mu_0$ charges every neighbourhood of $t^\star$ (or $\beta_G>0$), then $\bar r_c(n)\to r_c(t^\star)=w\,\mathbb E[\hat p\,\mathbf 1(\hat p<t^\star)]$.

*Proof.* (1) Differentiate $\int r_c\,e^{nD}d\mu_0/\int e^{nD}d\mu_0$. (2) The posterior concentrates on $\arg\max D$, and $r_c$ is continuous at $t^\star$ when $H$ is. ∎

Reading:
* **Within a run, the observed caught rate rises** when the prior gamer mass is small and diffuse. Then $\mathrm{Cov}(r_c,D)>0$ as soon as best responders dominate the gamers. In Example 1c it rises from 0.79 to 23 per $10^4$ episodes as $P_{\rm on}$ falls from 0.99 to 0.02.
* **It falls** only while the prior is dominated by naive gamers, whose $r_c$ is high and whose $D$ is negative. It then settles at $r_c(t^\star)$. A falling caught rate is therefore not evidence of alignment, and a rising one is a warning.
* **Across generations, the limit level $r_c(t^\star)$ fades with recognition**, but it is not monotone in AUC. Per $10^4$ episodes it is 6.9, 20.4, 22.3, 22.1, 20.3, 17.2, 12.2 and 5.3 at AUC 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95 and 0.99 (RC§10). It fades only above AUC of about 0.8, and it is zero under perfect recognition.

Caught events should be counted, broken down by type of opportunity, and investigated, not just trained against. Schoen et al. (2025) report a related pattern on a measured evaluation suite: after anti-scheming training, covert-action rates fell (o3: 13% to 0.4%) while verbalised evaluation awareness rose (o3: 2.3% to 4.5%), and the authors attribute part of the fall to awareness. That is an eval-suite measurement, not training-time caught events, but it is the pattern T2.7 predicts for a population moving toward better recognisers.

### Worked example 4 (six generations; illustration of exogenous trends)

Parameters are as in Example 1, with $n=3{,}000$ episodes per generation. Recognition rises from AUC 0.6 to 0.99, and the certainly-unchecked share $\varphi_k$ rises from 0 to 0.2. *Both schedules are assumed, not derived*, so the table illustrates what those trends do. It is not evidence that they occur. "Continued" carries the posterior forward (T1 regime (i)). "Fresh" restarts from $\mu_0$ each generation (regime (ii) with $\eta=0$). The last column uses an arbitrary target of $2\times10^{-4}$.

| $k$ | AUC | $\varphi_k$ | $D^\star_k$ | floor $w\lambda_+\varphi_k$ | mesh | $P_{\rm on}$ continued | $P_{\rm on}$ fresh | $\lambda_-$ needed for $D^\star\le2\times10^{-4}$ |
|---|---|---|---|---|---|---|---|---|
| 0 | 0.60 | 0 | $4.7\times10^{-5}$ | 0 | 0.23 | 0.997 | 0.997 | 0.4 (current) |
| 1 | 0.70 | 0.02 | $5.4\times10^{-4}$ | $1.0\times10^{-4}$ | 0.33 | 0.991 | 0.990 | 0.8 |
| 2 | 0.80 | 0.05 | $1.3\times10^{-3}$ | $2.5\times10^{-4}$ | 0.53 | 0.77 | 0.91 | none (floor above target) |
| 3 | 0.90 | 0.10 | $2.2\times10^{-3}$ | $5.0\times10^{-4}$ | 0.83 | 0.005 | 0.32 | none |
| 4 | 0.95 | 0.15 | $2.8\times10^{-3}$ | $7.5\times10^{-4}$ | 0.96 | 0.000 | 0.056 | none |
| 5 | 0.99 | 0.20 | $3.4\times10^{-3}$ | $1.0\times10^{-3}$ | 0.999 | 0.000 | 0.006 | none |

* The mesh rises toward 1, so the sieve stops discriminating among gamers.
* $D(1)$ stays negative throughout, at $-2.5$ to $-1.0\times10^{-3}$, so the naive gamer is still removed in every generation.
* The floor is 0.19 to 0.29 of $D^\star$. Penalties can remove the rest, but not the floor; trusted demonstrations on the unchecked opportunities could, where they exist.
* *The growth of $D^\star_k$ is an illustration of T2.8, not a prediction* (errata). The 73-fold rise from $k=0$ to $k=5$ comes mostly from the Gaussian signal's unbounded likelihood ratio at AUC 0.6, where $D^\star_0=4.7\times10^{-5}$. Over all signals with the assumed AUCs, $D^\star_0$ ranges from 0 to $7.0\times10^{-4}$ and $D^\star_5$ from $3.3$ to $3.7\times10^{-3}$ (T2.8c, EC§1), so the growth factor ranges from about 5-fold to unbounded. What is robust is the direction: $D^\star_k>0$ once $\xi_k>\xi^\star$, and it rises as the confident-real corner steepens and $\varphi_k$ grows. The $P_{\rm on}$ columns also inherit the uniform prior near $t^\star$ (S6).
* Refreshing from a trusted base delays the collapse by about one generation. It does not prevent it, since each fresh run is long enough to flip the odds.

**With loop feedback** (annealed builders, T1 A4). Let generation $k$'s audits catch only in proportion to its own on-task share, $\bar p_{k+1}=0.3\,P_{{\rm on},k}$. The run is identical through generation 2. At generation 3, $\bar p$ falls to 0.23, $D^\star$ rises from $2.2$ to $2.6\times10^{-3}$, and $P_{\rm on}$ falls to 0.0015 instead of 0.005. From generation 4 audits are void ($\bar p\approx0$) and $D^\star=5.0\times10^{-3}$ (RC§11). In this toy, feedback accelerates a collapse that the exogenous trends have already started; it does not start one. A fuller coupling (a $C_t$ builder also raising $w$, the quenched reading) is T1's subject.

**What would stabilise it (heuristic).** By T2.5, the generation-$k$ frontier needs $d_{F,k}>t^\star$ against fixed-threshold types, and $d_{F,k}>t^\star_F$ against the adaptive type. The natural mechanism is that generation $k{+}1$ audits a random sample of generation $k$'s frontier output after the fact. For generation $k{+}1$ that work is *below* its frontier, so the catch probability can be high. The condition becomes
$$a_r\,c_{k+1}\,\chi\;>\;t^\star_F,$$
where $\chi$ is the probability that detection is followed by a consequence generation $k$ cares about (T1 §7). Four qualifications:
* **Late detection must carry consequences.** For a frontier action whose payoff is realised by the act itself, such as sabotaging generation $k{+}1$'s grader or training data, later detection may not deter at all ($\chi\approx0$, or $t^\star_F\approx1$). Christiano's (2021) low-stakes condition, under which no small set of actions is catastrophic and frontier outputs feed back into training, is the regime where this works. There the consequence is automatic and $t^\star_F$ becomes a training break-even $t^\star_{\rm dep}$.
* **Audited is not caught.** By T2.H1 and Remark 4.1, $c_{k+1}$ is endogenous, so the student's estimate of it varies with $z$ and with its method.
* **False flags** on generation $k$'s honest mistakes raise the effective break-even (T2.1′). So "cheap when penalties are large" holds only down to the false-flag rate, when false flags are independent of gaming. The first draft's example ($a_r=5\%$, $c=0.8$, $\lambda_-/\lambda_+=24$, giving $0.04=t^\star$) ignored both $\chi$ and $f$.
* **The auditor must itself be on task.** A colluding auditor sets $c\approx0$. This converts the frontier problem for generation $k$ into a *sub-frontier* trust problem for generation $k{+}1$. That is T1's grader channel (T1 §4) with a delay, and whether the recursion closes is the main open question this section leaves.

---

## 8. Relation to prior work, and what is new

* **Cotra (2022)** argued that training favours the training-game player. T2.5(2) is that statement in this model: the adaptive $G^\star$ is never pushed down by any behavioural design (T1.4). T2.2 and T2.3 add that, under a fixed design, even fixed-threshold populations concentrate at the design's own $t^\star$.
* **Hubinger et al. (2019)** introduced deceptive alignment, meaning defection conditional on believing one is deployed, which is the conceptual origin of $C_t$. **Carlsmith (2023)** asks whether training selects against schemers. Here the answer is sharp for one operator: behavioural selection is blind below $t^\star$ (T2.2(2)). With mixed operators it is blind below $t^\star_c$ in each cell, and against the adaptive type it is blind everywhere. The question then reduces to the prior and the non-behavioural channels (§6, T3).
* **Hubinger et al. (2024)** found that adversarial training teaches trigger recognition. T2.7(1) and T2.9 are the selection-level version: recognition weakly raises the best responder's drift, and penalties amplify the selection for it.
* **Greenblatt et al. (2024a)** observed alignment faking. A model that complies when it believes it is in training and not otherwise is a $C_t$ with $q_{\min}\ge t>d_F$, in the frozen band. In that paper, RL *increased* alignment-faking reasoning, from about 12% to 78%. In the sieve, frozen types keep their odds against the type training rewards. So the amplification comes from removing a third type, the refuser that training penalises. It is not a gain against $A$, and it is consistent with "frozen".
* **Greenblatt et al. (2024b)** and **Griffin et al. (2024)** study control with auditing budgets, the latter as partially observable stochastic games. T2.6 to T2.8 say which audit budgets count against an adaptive policy: only those that keep every distinguishable cell at or above break-even. The frontier pair $(d_F,t^\star_F)$ of T2.5(2) is the control problem.
* **Needham et al. (2025)** measured evaluation awareness (AUC 0.83 overall for the best model). **Nguyen et al. (2025)** read it with linear probes. **Schoen et al. (2025)** found that awareness rose after anti-scheming training. These are the empirical anchors for T2.7, T2.8b and T2.13.
* **Yang et al. (2024)** found weak-to-strong deception that grows with the capability gap, the empirical counterpart of cells with $\hat p_c\approx0$ and of the floor $w\lambda_+\varphi$. **Cundy and Gleave (2025)**: training against a lie detector gives honesty or evasion depending on the detector's true-positive rate (§6). **Baker et al. (2025)**: obfuscation under chain-of-thought monitoring.
* **Barnes and Christiano (2020)** (obfuscated arguments) and **Christiano (2021)** (low-stakes alignment) are the right frames for T2.H1 and §7: catchability is endogenous, and late detection deters only with consequences.
* **Christiano (2017).** His basin of corrigibility is about an approximately corrigible agent actively helping to make its successor corrigible. T2 has no term for that. What T2 supplies is one necessary condition *for the selection part* of such a basin: against fixed types, $d_F$ must beat the training break-even. Against adaptive types, selection can at best hold their odds fixed, so the basin must come from elsewhere.
* **Classical tools.**
  * The deterrence threshold $t^\star$ is from Becker (1968). Allingham and Sandmo (1972) have evasion governed by the perceived audit probability.
  * Reinganum and Wilde (1985) have cutoff audit rules conditioned on observables (T2.1′, T2.7(2)).
  * Blackwell (1953) gives T2.7(1). Kamenica and Gentzkow (2011) give the persuasion framing.
  * Inspection games (Avenhaus, von Stengel and Zamir 2002) are the strategic counterpart.
  * The max-divergence of differential privacy (Dwork and Roth 2014) is $\xi$ in T2.8. Metz (1978) has the optimal ROC operating point (T2.8b).

  The difference from all of these is that selection acts on a population of types, not on one agent's incentives.
* **What is new here, to my knowledge.** Most of the list is the continuum version of T1.4, and elementary once the type is continuous:
  * the continuum drift formula, its quasi-concave shape, the mesh $t_0=\sup\lbrace D\ge0\rbrace$, and the mesh floor;
  * the heavy-penalty floor;
  * the flat sieve.

  The items I regard as genuinely useful are:
  * the cap identity together with its convex-order (Blackwell) reading;
  * the one-sided indistinguishability condition in its max-divergence and ROC-tangent forms (T2.8, T2.8b), which turns "realistic audits" into a measurable target;
  * the per-cell break-even with false flags and demonstrations (T2.1′), including the observation that trusted demonstrations on real opportunity prompts are indistinguishable by construction;
  * the split between fixed-threshold and adaptive ceilings (T2.5);
  * the post-sieve reading of latent correlation for tells;
  * the covariance law for the observable caught rate (T2.13).

  Added after reconciliation: the per-type mean-field condition and the capture law for rarely triggered types (T2.3, T2.3b), whose gambler's-ruin core is the simulation's (`sim/README.md` §5) and whose extension to general evidence per event is `sim/reconciliation.md` §3.4; the Lundberg form for asymmetric evidence, which applies a classical ruin-theory bound; and the AUC envelope for $D^\star$ (T2.8c), which I have not seen stated elsewhere.

---

## What this says about the RSI loop

1. **Separate two questions: does training push gamers down, and what do the survivors do at the frontier?** Against fixed-threshold careful gamers, training design matters a great deal. The frontier ceiling is $\mu_0(O)/(\mu_0(O)+\mu_0((d_F,t^\star]))$, and the levers are penalties (down to the false-flag rate), pooled or cell-wise audits above break-even, and trusted demonstrations. Against the adaptive best responder, no behavioural design pushes it down; that is true by the definition of a best responder, so the substantive question is how much prior mass such a type has. The best training can do is *freeze* it, which needs every distinguishable cell at or above break-even. Its frontier behaviour is then set by $d_F$ against its own $t^\star_F$, which depends on frontier oversight, the consequences of detection, and how much a single frontier action can gain. For the loop, this means: **training decides whether adaptive gamers grow; control and consequences at the frontier decide whether the ones that exist defect; and only the prior (T3) and non-behavioural channels decide how many exist.**
2. **The break-even depends on the operator.** It is $1/2$ for (B) with a hard grader, below $1/2$ with a weak grader, $\pi_X$ for on-policy best-of-1 filtering, designer-set for (D), and $0$ for trusted demonstrations. Mixing indistinguishable demonstrations into RL lowers the effective break-even by $w_d\Lambda/(w\bar\lambda)$. Demonstrations are the one audit-like signal that a student cannot tell apart from real opportunities, *provided their prompts are drawn from the real opportunity distribution*. They exist only below the demonstrator's frontier.
3. **Design audits so that every distinguishable cell sits at or above break-even, and measure the right statistic.** The target is the steepest part of the student's ROC curve for "this is unchecked". It must stay below $e^{\xi^\star}=\operatorname{odds}(\bar p)\lambda_-/\lambda_+$, which is equivalent to $D_\infty(P_{\rm unchecked}\Vert P_{\rm checked})\le\xi^\star$. AUC does not determine this; it only bounds it, loosely at low AUC (T2.8c). In particular, place honeypots where the frontier lies in the student's feature space: T1.4c's pointwise condition imposed on the frontier region is what keeps a careful gamer's frontier estimate above break-even (remark after T2.5).
4. **Random audits of real work close the selection channel of recognition, not the catchability channel.** Their value at the frontier depends on how the checker's catch rate scales with the capability gap, and on detection carrying consequences (low-stakes conditions). Audit commitments raise $d_F$ only if they are honoured, and only if the auditing generation is itself on task.
5. **Do not train on opportunities you can neither check nor demonstrate.** Certainly-unchecked opportunities create a drift floor $w\lambda_+\varphi$ that no penalty removes. Put frontier capability training on tasks that are hard to do but easy to check, or that have no predictable grader errors.
6. **Read caught-gaming counts through the posterior predictive.** In the model, a collapse of frontier on-task behaviour is announced by a *rising* caught rate when gamers are rare and spread over carefulness. A falling caught rate is consistent with naive gamers being removed while best responders grow. Neither direction is evidence of alignment, but a rise during training is a warning, and so is the fade of the per-best-responder rate across generations once recognition is high.
7. **Tells and interpretability checks are worth what they reveal about the post-sieve population**, meaning best responders and the frozen band. They are not worth what they reveal about the prior. Their likely best use is measurement, not a training signal, because training against them can teach evasion.
8. **Recognition and method choice are the clock of the loop.** As recognition approaches perfect, the sieve flattens and penalties stop mattering. As the gamer's repertoire of methods grows, effective detection falls. Each generation must bring a matching gain in indistinguishability, in demonstration coverage, or in cutting $w\lambda_+\varphi$.
9. **Prefer little evidence per event.** Gamers that defect only on inputs that look extremely unwatched, such as sleeper-agent triggers, see a handful of decisive events however long training runs. Under coarse per-event evidence ((B), rejection sampling, sharp policies) the sieve lets them through by luck, in a fraction of runs that more training does not shrink; under soft evidence that fraction falls exponentially in $1/\lambda_s$ (T2.3b, heuristic). Example numbers that rest on the exact tilt, a uniform prior near $t^\star$ or Gaussian recognition (Examples 1 and 4) illustrate the conditions above; they are not forecasts.

## Open problems

1. **The retrospective-audit recursion.** Generation $k{+}1$ audits generation $k$'s frontier work. When is that a sub-frontier task on which generation $k{+}1$ is reliably on task, and when does collusion set $c\approx0$? Couple T2's frontier condition to T1's grader channel, quenched reading included.
2. **Prior mass of the adaptive type.** Every training-side result leaves $\beta_G$ untouched. Estimate how $\beta_G$ relative to $\alpha$ scales with situational awareness and description length (T3), and whether prior shaping can move it.
3. **What sets $t^\star_F$.** Model frontier stakes and consequences explicitly (rollback, retraining, discarding a lineage, online low-stakes training) and find which commitments make $t^\star_F$ small.
4. **Learning recognition, not just selecting it.** With SGD, recognition, methods and thresholds are learned, not drawn from a prior. Does the flow toward $t^\star$ and toward better recognition match the selection-model rates?
5. **Measure the ROC slope at the confident-real corner.** Estimate the steepest part of a real model's eval-awareness ROC curve (by probes or by self-report), compare it with $e^{\xi^\star}$, and test whether it predicts the out-of-distribution effect of anti-scheming training better than AUC does.
6. **False flags.** Determine whether a real monitor's false flags behave like independent noise (which bounds the penalty lever at $f$) or like check-coupled errors (which do not), and what third dispositions heavy penalties select for.
7. **Time-bounded indistinguishability.** Make "honeypot realism erodes with capability" precise. Model audits as samples from a generator of time-bounded complexity $K^T$, and find the generation gap at which $\xi$ exceeds $\xi^\star$.
8. **Gaming regions that are not thresholds.** General regions $S$ allow types that game only on frontier-like features. Characterise the classes of regions that a given mix of audits and demonstrations can remove.
9. **Tells without concealment learning.** Find conditions under which penalising an involuntary tell selects rather than teaches concealment: for example small $\eta$, tells read from frozen layers, or measurement only.

## References

Allingham, M., Sandmo, A. (1972). Income tax evasion: a theoretical analysis. *Journal of Public Economics* 1(3–4).
Asmussen, S., Albrecher, H. (2010). *Ruin Probabilities*, 2nd ed. World Scientific.
Avenhaus, R., von Stengel, B., Zamir, S. (2002). Inspection games. In *Handbook of Game Theory with Economic Applications*, vol. 3. Elsevier.
Baker, B., et al. (2025). Monitoring reasoning models for misbehavior and the risks of promoting obfuscation. arXiv:2503.11926.
Barnes, B., Christiano, P. (2020). Debate update: obfuscated arguments problem. AI Alignment Forum.
Becker, G. (1968). Crime and punishment: an economic approach. *Journal of Political Economy* 76(2).
Blackwell, D. (1953). Equivalent comparisons of experiments. *Annals of Mathematical Statistics* 24(2).
Carlsmith, J. (2023). Scheming AIs: will AIs fake alignment during training in order to get power? arXiv:2311.08379.
Christiano, P. (2017). Corrigibility. ai-alignment.com / AI Alignment Forum.
Christiano, P. (2021). Low-stakes alignment. AI Alignment Forum.
Cotra, A. (2022). Without specific countermeasures, the easiest path to transformative AI likely leads to AI takeover. AI Alignment Forum.
Cundy, C., Gleave, A. (2025). Preference learning with lie detectors can induce honesty or evasion. arXiv:2505.13787 (NeurIPS 2025).
Dwork, C., Roth, A. (2014). The algorithmic foundations of differential privacy. *Foundations and Trends in Theoretical Computer Science* 9(3–4).
Engels, J., et al. (2025). Scaling laws for scalable oversight. arXiv:2504.18530.
Greenblatt, R., et al. (2024a). Alignment faking in large language models. arXiv:2412.14093.
Greenblatt, R., Shlegeris, B., Sachan, K., Roger, F. (2024b). AI control: improving safety despite intentional subversion. *ICML*. arXiv:2312.06942.
Griffin, C., Thomson, L., Shlegeris, B., Abate, A. (2024). Games for AI control: models of safety evaluations of AI deployment protocols. arXiv:2409.07985.
Hubinger, E., van Merwijk, C., Mikulik, V., Skalse, J., Garrabrant, S. (2019). Risks from learned optimization in advanced machine learning systems. arXiv:1906.01820.
Hubinger, E., et al. (2024). Sleeper agents: training deceptive LLMs that persist through safety training. arXiv:2401.05566.
Kamenica, E., Gentzkow, M. (2011). Bayesian persuasion. *American Economic Review* 101(6).
Metz, C. E. (1978). Basic principles of ROC analysis. *Seminars in Nuclear Medicine* 8(4).
Needham, J., Edkins, G., Pimpale, G., Bartsch, H., Hobbhahn, M. (2025). Large language models often know when they are being evaluated. arXiv:2505.23836.
Nguyen, J., Hoang, K., Attubato, C. L., Hofstätter, F. (2025). Probing (and steering) evaluation awareness of language models. arXiv:2507.01786.
Reinganum, J., Wilde, L. (1985). Income tax compliance in a principal-agent framework. *Journal of Public Economics* 26(1).
Schoen, B., et al. (2025). Stress testing deliberative alignment for anti-scheming training. arXiv:2509.15541.
Yang, W., et al. (2024). Super(ficial)-alignment: strong models may deceive weak models in weak-to-strong generalization. arXiv:2406.11431 (ICLR 2025).

---

## Revision notes

Response to `drafts/T2-sieve-referee.md`. New numbers are in `sim/T2_revision_checks.py` and its output; first-round numbers are unchanged and reproduce.

**Major issues.**
* **M1, adaptive best responder.** Added $G^\star$ (adaptive) to S3 and S6, with its frontier break-even $t^\star_F$ in S5. The first-draft notation $G^\star=C_{t^\star}$ is now reserved for the fixed type. T2.5 is restated: (1) a fixed-threshold ceiling that includes $\beta_G$; (2) an adaptive ceiling, $1-\beta_G/(\mu_0(O)+\beta_G)$ whenever $d_F<t^\star_F$, valid for every behavioural design; (3) achievability for fixed types only. Example 1b shows the effect numerically. Summary, §2's reading, takeaway 1 and §8 are rewritten around the split. **Nuance added:** under a fixed design $G^\star$ coincides with $C_{t^\star}$ and gains at the same rate. The two separate only under redesigns and at the frontier. A reward-seeking variant is distinguished from a schemer at the frontier.
* **M2, scope; mixed operators; per-cell penalties; false positives.** Stated S4a to S4d explicitly. Added T2.1′ (per-cell break-even $t^\star_c$ with false flags and demonstrations), with both counterexamples and the referee's numbers reproduced. "For every training design" is now scoped to S4a to S4c in T2.2(2) and T2.5(1). The claim that tells are "the only other route" is broadened in §6. **Partial disagreement:** the referee's statement that false positives bound the penalty lever at $f$ holds when false flags are independent of gaming. When false flags come from the same checks that catch gaming ($p=ac$, $f=a\phi$), the condition is $c>\phi$, and false positives cost speed but do not bound the lever. Both cases are now stated, and which one obtains is listed as open problem 6.
* **M3, observable signal.** The "visible gaming declines" claim is withdrawn. I added Example 1c, which reproduces the referee's posterior-predictive numbers (0.79 to 23 caught per $10^4$; gaming 3.5 to 216). I restated T2.13 as a covariance law with its long-run limit, said when the observed rate rises and when it falls, restricted "fades" to the per-best-responder rate above AUC of about 0.8, and rewrote takeaway 6. I cited Schoen et al. (2025) as an eval-suite analogue.
* **M4, retrospective audits.** The old §5 block is now T2.H1 (conjecture). It separates audit selection ($\xi=0$) from catchability ($c(z,m)$, endogenous). I added Remark 4.1 on endogenous detection (method choice), and rewrote §7's stabilisation condition as $a_rc\chi>t^\star_F$, with consequences $\chi$, false flags, and the auditor-trust recursion cross-referenced to T1 §4 and §7. I cited Barnes and Christiano (2020) and Christiano (2021).

**Per-proposition fixes.**
* T2.1: listed the assumptions (S4a to S4c). Remark 0.1 now says which results generalise to arbitrary gaming regions and which do not.
* T2.2: the mesh is defined as $t_0=\sup\lbrace D\ge0\rbrace$. The conditional-mean equation is kept as a characterisation when $H$ is continuous at $t_0$ and $q_{\min}<t^\star$. The pooled and $q_{\min}\ge t^\star$ cases are stated, and gaps are handled. Added the knife-edge remark (mesh $\to t^\star$ as $d\to0^+$, RC§1).
* T2.3: the label now reads rigorous under S4d, Laplace heuristic, mean-field otherwise. Added the condition $n\gg w\mathbb E\ell^2/D^{\star2}$ with numbers for (D) and (B). **Refinement of the referee:** under (B) the sd/mean of $S_n$ is 0.085 at $n=10^4$, not of order 1. It is of order 1 (1.3) at (B)'s own flip time, $n\approx43$, which is where it matters, so I state the condition at the flip time. The interpretive paragraph now separates $C_{t^\star}$ from the adaptive type.
* T2.4: frontier detection is now a distribution, the $G^\star$ term is added, and competence failures are declared out of scope.
* T2.5: restated as above. The "iff" is replaced by the continuous ceiling (item 4). The pooled-level remark is corrected to $\bar p=d_F$ (RC§12). The "$t^\star=1/2$ for filtering" claim is corrected using T1's operator table (S4, T2.5 remarks, takeaway 2).
* T2.7: Blackwell monotonicity is stated for $D^\star$ only. "Pooling is optimal" becomes "keep every distinguishable cell at or above break-even; pooling is one way". Added the caveat to the persuasion analogy and credited Reinganum and Wilde.
* T2.8: the ess sup is now taken under $P_u$, and $\xi$ is named as $D_\infty$ (Dwork and Roth 2014). "Use the shortfall instead of AUC" is replaced by T2.8b, the ROC-tangent identity, proved and checked to six digits (RC§7), crediting Metz (1978).
* Example 2: the crossing is corrected to $\xi\approx0.646$, and rows at 0.55 and 0.60 are added (RC§8).
* T2.9: the Summary's "heavy penalties stop helping" is softened, and the false-positive limit is added.
* T2.10: absolute rates are now specified; "removes" becomes "contributes negative drift"; item 4 (per-cell remedies) is added.
* T2.11: Example 3 row 4 is corrected to 0.887 nats (RC§9). The Allman, Matias and Rhodes citation is dropped; independent filters multiply. The "only other route" claim is broadened.
* T2.12: "nothing below $t=1$ is removed" becomes "no type is removed".
* T2.13: restated (see M3); the non-monotone AUC profile is reported (RC§10).
* Example 4 is labelled an illustration of assumed trends. A floor column is added, the "impossible" column is relabelled relative to an arbitrary target, and a loop-feedback variant is added (RC§11).

**Other.**
* The uniform prior is now flagged in S6, and Example 1b adds atomic priors.
* The Christiano (2017) sentence is reworded as a necessary condition for the selection part of a basin.
* The Needham et al. (2025) statement now reports the measured AUCs and drops "this range is where the sieve flips".
* A Greenblatt et al. (2024a) sentence explains the RL amplification through removal of the refuser.
* The Summary now says that all rates are selection-only.

**Prior art added:** Allingham and Sandmo (1972); Reinganum and Wilde (1985); Griffin et al. (2024); Dwork and Roth (2014); Metz (1978); Hubinger et al. (2019); Barnes and Christiano (2020); Christiano (2021); Yang et al. (2024); Schoen et al. (2025); Nguyen et al. (2025); Cundy and Gleave (2025) (the FAR.AI lie-detector paper); Engels et al. (2025). The novelty list is trimmed, and its elementary items are presented as the continuum version of T1.4. **Not added:** the referee's mention of a system-card steering result on evaluation awareness, because I could not verify the specific finding.

---

## Errata after reconciliation (18 October 2026)

Sources: `sim/reconciliation.md` (§3.4, §3.5 and the "T2" list of §4) and a completeness critic. New numbers are in [`sim/T2-sieve_errata_checks.py`](../sim/T2-sieve_errata_checks.py) and its output ("EC§1" to "EC§4"); simulated numbers from the reconciliation are cited as R11 and R12 of [`sim/reconcile_checks.py`](../sim/reconcile_checks.py). Nothing else in the body changed, and all earlier numbers stand.

**Notation introduced in the errata.**

| symbol | meaning |
|---|---|
| $\omega_\theta$ | rate per episode of decisive events (opportunities in the gaming region) for type $\theta$ |
| $\ell_\theta$ | evidence per decisive event for type $\theta$: $+\lambda_+$ uncaught, $-\lambda_-$ caught |
| $\lambda_s$ | evidence per event when $\lambda_+=\lambda_-$ |
| $P_+,\ P_-$ | probability that a decisive event in the low tail is uncaught, caught |
| $M$ | maximum of the walk of decisive events sorted by the feature |
| $\mu_{\rm gap}$ | prior mass of the types between neighbouring low-tail opportunities |
| $x_A$ | $\ln(\mu_0(A)/\mu_{\rm gap})$ |
| $\varrho$ | Lundberg exponent, the positive root of $P_+e^{\varrho\lambda_+}+P_-e^{-\varrho\lambda_-}=1$ |

The reconciliation's $\pi_\theta$, $g$, $x$ and $\lambda$ are renamed $\omega_\theta$, $\mu_{\rm gap}$, $x_A$ and $\lambda_s$, because $\pi$ (cell shares, $\pi_n$, T1's $\pi_X$) and $g$ (T1's capability step) are already taken. The R12 table labels the (D) rows by $\lambda_s$, not by the KL temperature, so that $\beta$ is not used again.

**What changed.**
1. **T2.3, mean-field condition** (reconciliation §3.4, item 1). It is now stated per type, $n\omega_\theta(\mathbb E\ell_\theta)^2/\mathrm{Var}\,\ell_\theta\gg1$, with the statement that it always fails for types whose gaming region sits in the low tail of a feature the student conditions on. The first draft's condition is identified as the case $t=t^\star$. *Applied with one qualification.* Read literally, "for every type that carries prior mass" is sufficient but far from necessary. In Example 1 the condition also fails in a band around the mesh, where $\mathbb E\ell_t=0$ (14% of the gamer prior at $n=10^4$, EC§2), and this has no consequence because those weights cannot compete with $e^{nD^\star}$. So the text says that the condition is needed for every type whose fluctuating weight can compete with the mean-field leaders. It also notes that the $\mathrm{Var}$ form implies $n\omega_\theta\gg1$ whenever $\lvert\mathbb E\ell_\theta\rvert\le\mathrm{sd}\,\ell_\theta$, which is needed because the number of events is itself random.
2. **New T2.3b, capture law** (reconciliation §3.4, item 2). The law is $P(\text{capture})\approx(P_+/P_-)^{\lceil x_A/\lambda_s\rceil}$, labelled heuristic, with the walk-maximum law $\Pr(M\ge k)=(P_+/P_-)^k$ as its rigorous ingredient, the three heuristic steps named, and the R12 table with sieve scenario 2's parameters. *Added beyond the request:* Lundberg's bound $\Pr(M>y)\le e^{-\varrho y}$ for asymmetric evidence $(\lambda_+,\lambda_-)$, as T2's own (D) example uses. With $\lambda_\pm=(0.1,0.4)$ under pooled audits at $\bar p=0.3$, $\varrho=2.29$ per nat and Monte Carlo gives $0.78\,e^{-\varrho y}$ (EC§3), so capture there is about $10^{-5}$. Also added: the small-step form $\varrho\approx2\lvert\mathbb E\ell\rvert/\mathbb E\ell^2$ and the reading for the loop (sleeper-agent-like triggers; prefer little evidence per event).
3. **T2.3, per-episode (D)** (reconciliation §3.5). "The mean-field picture is adequate" becomes "adequate to first order". The text now explains that the posterior follows the supremum of the random field, adds the R11 table (mean, median and interquartile range at $n=10^3$ to $10^4$), and reports that the median run flips at 5,683 episodes against 6,083 under S4d, 7% earlier.
4. **T2.5(3)** (reconciliation §3.4, item 3). Added the per-episode caveat: with types that threshold an uninformative feature in the prior, a fraction of about $(P_+/P_-)^{\lceil x_A/\lambda_s\rceil}$ of runs is captured, and more training does not remove it.
5. **Remark after T2.5, honeypots where the frontier lies** (reconciliation §3.4, optional item). Scenario 3's lesson is stated as T1.4c's pointwise condition imposed on the frontier's region of feature space, with its limits: the designer must know where the frontier lies in the student's feature space, and it fails against types whose gaming region separates the frontier from the honeypots.
6. **Example 1 headline** (critic). "0.99 to 0.02 within $10^4$ episodes at AUC 0.8" is now presented as an illustration of T2.8 that depends on uniform prior mass near $t^\star$ (gamer prior on $[0.5,1]$: 1.000; density $\propto t^4$: 0.62; EC§4) and on Gaussian recognition (flip time 2,200 to 7,600 episodes over all AUC-0.8 signals, against 4,300). The sentence "the sieve flips at every AUC above 0.5" is restricted to Gaussian recognition.
7. **New T2.8c, AUC envelope** (added to support item 6). It gives sharp lower and upper bounds on $D^\star$ at a given AUC, with proof. $D^\star=0$ is possible iff $\mathrm{AUC}\le1-\frac12e^{-\xi^\star}$, which is 0.708 in Example 1. The bounds are checked on 20,000 random discrete signals and shown to be attained (EC§1).
8. **Example 4** (critic). The 70-fold growth of $D^\star$ (73-fold before rounding) is labelled an illustration that depends on the Gaussian signal's unbounded likelihood ratio. Over all signals with the assumed AUCs the factor ranges from about 5-fold to unbounded (EC§1). Its $P_{\rm on}$ columns are also flagged as depending on the uniform prior.
9. **T2.5(2), adaptive ceiling** (critic). Labelled near-tautological under selection: $G^\star$ is defined as the best responder, so the content lies in its prior mass and in the frontier condition. The same note is added to the Summary and to takeaway 1.
10. **Summary, takeaways and §8.** The Summary gains a bullet on the mean field and rarely triggered types, and its bullets on audits and on generations now cite T2.8c and the dependence of the 70-fold figure on the Gaussian signal. Takeaway 3 gains the honeypot-placement point and the AUC envelope. A new takeaway 9 prefers little evidence per event and says that the examples' headline numbers are illustrations, not forecasts. §8 credits the simulation and the reconciliation for the capture law. Asmussen and Albrecher (2010) is added to the references.

**Not changed.** The reconciliation's §5 notes that T2.1′, T2.8, T2.8b, T2.13 and Example 4 were not tested against per-episode simulation. Their status (rigorous under S4d) is unchanged. Whether rarely triggered types also bias the caught-rate law T2.13 under per-episode updates is open.
