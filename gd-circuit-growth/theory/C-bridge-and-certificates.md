# C. Bridges from the network to small circuits, and certificates without labelled hold-out data

Notes by Claude, prompted by Kaarel Hänni. Research note, 23 October 2026. Not reviewed by a human. Revision 2, after the round-1 referee report ([`checks/referee_C_r1.json`](checks/referee_C_r1.json)). A round-2 referee passed it with 10 minor issues and no major ones ([`checks/referee_C_r2.json`](checks/referee_C_r2.json)); this version applies those minor fixes. The changes of both rounds are listed in the [Revision notes](#revision-notes) at the end.

**Question (from the user).** *"Try to see if you can get some generalization bounds for this. I guess I can see how one would have a result saying that you get good generalization if training hasn't taken too long because the circuit cannot have grown that big yet, and then one has a Chernoff guarantee for all small circuits that their train and test loss are similar? Here we could imagine doing full batch but with a train/test split, or SGD; either should make sense."*

**Where this file sits.** [A](A-discrete-model.md) proves Occam and training-time bounds *inside* the discrete circuit-growth model. [B](B-nn-time-bounds.md) proves parameter-space bounds for the *actual network*, which are mostly vacuous, and an a posteriori junta read-off (B, Proposition 6.1). This file supplies the bridges between the two:
- **C1:** a general distillation certificate for the actual network, with three circuit classes counted exactly;
- **C2:** a fully rigorous toy instance of "short training implies a small circuit" (a diagonal linear network over Boolean characters);
- **C3:** what is known for ReLU networks, two proved no-growth lemmas, and a conditional theorem that transfers the discrete model's bound to the network under an explicit, checkable hypothesis;
- **C4:** the online (fresh-sample) protocol: online-to-batch conversions, and how circuit size becomes a time-to-learn bound.

**Status labels.** As in [`neural-network-generalization/`](../../neural-network-generalization/TECHNICAL-FAQ.md), and as in A and B:
- **Proved:** a complete proof with explicit constants is in this file. Statements from A that are used are re-proved here.
- **Literature:** a published result. "(from memory)" means I could not check the statement against the paper; where an abstract or search summary was checked, I say so.
- **Heuristic / Conjecture:** as usual.
- **Numerical:** a check by a script in [`checks/`](checks/). Every script runs in seconds to a few minutes on one core.

## Summary

1. **A trained network can be certified without labelled hold-out data (Theorem C1, Proved).** Let $h$ be the trained network's sign function and let $g$ be *any* predictor from a fixed hierarchy $\{\mathcal H_c\}$ of circuit classes, chosen after seeing the training set $S$, the network, and unlabelled inputs. Then, with probability $1-\delta_1-\delta_2$, simultaneously for all $c$ and $g\in\mathcal H_c$,
   $$\mathrm{err}(h)\;\le\;\mathrm{kl}^{-1}_+\!\Big(\widehat{\mathrm{err}}_S(g),\ \tfrac{\ln|\mathcal H_c|+\ln\frac1{\pi(c)}+\ln\frac1{\delta_1}}{n}\Big)\;+\;\mathrm{kl}^{-1}_+\!\Big(\widehat{\mathrm{dis}}_U(h,g),\ \tfrac{\ln|\mathcal H_c|+\ln\frac1{\pi(c)}+\ln\frac J{\delta_2}}{m}\Big),$$
   where $J$ is the number of checkpoints certified and $m$ the number of unlabelled inputs. The only independence needed is that the unlabelled inputs are not used in training. Three natural classes are counted (Propositions C1.2–C1.4): signs of $T$ Fourier characters and fan-in-2 circuits with $T$ gates, by explicit upper bounds checked against brute force, and $k$-juntas, exactly.
   - **Numerical.** On the saved final Adam networks of the sweep (rebuilt from their float16-saved parameters, §1.3), the certificate is below $0.5$ for all 13 targets and every seed at $n=2048$, and below $0.04$ for 9 of the targets. Every network at $n=16384$ is certified at $\le0.021$. The Fourier-sign class certifies MAJ$_9$ at $0.034$, and the 10-variable threshold function at $0.09$–$0.10$ ($n=2048$) and $0.02$ ($n=16384$). B's junta read-off fails on these two targets. No certificate falls below the true error. See §1.4.
   - **Numerical, along training** (§1.6). Computed from the saved test-set predictions alone, the class that minimizes the certificate grows in discrete stages. For example, for stair5 it is $x_1$ alone (5 nats; test error $0.30$–$0.34$, certificate $0.35$–$0.43$) during steps 50–200, and a 5-junta (34 nats) from step 500 on; for dnf3 it goes through 0.7, 60, 263 and 332 nats. The selected class trades error against size; it is not the size of a circuit the network is known to be close to.
2. **Time limits circuit size, rigorously, in a diagonal linear network (C2, Proved).** For $f_w=\sum_Sw_S\chi_S$ over all characters of degree $\le k$, with $w=u\odot u-v\odot v$ and $u(0)=v(0)=\alpha\mathbf 1$, gradient flow has the closed form $w(t)=-2\alpha^2\sinh(4G(t))$, where $G(t)=\int_0^t\nabla L$ (Lemma C2.1, verified numerically to $10^{-8}$). Let $\Theta_\varepsilon=\frac14\operatorname{arsinh}\frac{\varepsilon}{2\alpha^2}\approx\frac14\ln\frac{\varepsilon}{\alpha^2}$, and let $\tau(t)=\int_0^t\|r\|_n\le t$ be the effective time of A. Then:
   - **(a)** no coordinate reaches $\varepsilon$ before $\tau(t)=\Theta_\varepsilon$. The first escape happens at $t\in[\Theta_\varepsilon/(U_0+\varepsilon_D),\ \Theta_\varepsilon/(U_0-\varepsilon_D)]$, where $U_0$ is the largest initial utility (Theorem C2.2);
   - **(b)** the number $N_\varepsilon(t)$ of coordinates with $|w_S(t)|\ge\varepsilon$ satisfies $N_\varepsilon\le\kappa_B\,\tau(t)^2/\Theta_\varepsilon^2$, with $\kappa_B$ the top eigenvalue of the Gram matrix of the grown set, and $N_\varepsilon\le(\int_0^t\|\nabla L\|_2)^2/\Theta_\varepsilon^2$ (Theorem C2.3). The first is tight for a single-character target in the limit $\alpha\to0$;
   - **(c)** with probability $1-\delta$, simultaneously for all $t$ and $\varepsilon$, the test error of $\mathrm{sgn}\,f_{w(t)}$ is at most a kl-Chernoff term with complexity $\ln\binom{D}{N_\varepsilon(t)}+\ln\Phi(2^{\min(N_\varepsilon,d+1)},N_\varepsilon)$, evaluated at the training margin $2\mu_\varepsilon(t)$ (Theorem C2.4). Corollary C2.5 makes the complexity a function of time: with the data-dependent $\kappa_B$, or, through the coherence of the training inputs, a function of $(n,D,\tau(t))$ alone once $n\gtrsim2(\tau/\Theta_\gamma)^4\ln(2D_{2k}/\delta')$. The dictionary size $D$ enters only through $\ln D$, both in the capacity and in the unit of time $\Theta_\gamma\approx\frac14\ln\frac{\gamma}{4D\alpha^2}$.
   - **(d)** the same holds for discrete GD and minibatch SGD (Proposition C2.6). No coordinate grows before the minibatch effective time, computed from the logged minibatch losses, reaches about $\Theta_\varepsilon$. The SGD size bound is in terms of the integrated minibatch gradient norms, not the losses.
   - **Numerical** ($d=10$, $D=176$): the bounds hold in every run. Theorem C2.4 certifies $0.08$–$0.28$ test error for par2, maj3 and and3 from $n=100$–$400$ samples. The time-indexed Corollary C2.5 gives $0.11$–$0.48$ with the measured $\kappa_B$ for the sparse targets at $n=400$ and par2 at $n=100$ ($0.81$ for maj3 at $n=100$), but its form in terms of $(n,D,\tau)$ alone is non-vacuous only for par2 at $\alpha=10^{-8}$ ($0.16$).
3. **ReLU networks (C3).**
   - *Literature:* the rigorous results cover early alignment and the first escape in two-layer and homogeneous networks, and exact saddle-to-saddle limits only for diagonal networks.
   - *Proved:* a per-neuron Gronwall bound for two-layer ReLU networks, $\rho_j(t)\le\rho_j(0)e^{2\sqrt{\lambda_X}\tau(t)}$ (Lemma C3.1, also for discrete GD), and a deep homogeneous bound $Q(t)^{1-L/2}\ge Q(0)^{1-L/2}-(L-2)\sqrt{\lambda_X}\tau(t)$ (Lemma C3.2). These are the "no growth before $\log(1/\alpha)/U$" and "fresh chains cost $\alpha^{-(L-2)}$" laws, as one-sided bounds for small-initialization GD on these architectures. The study's μP Adam networks are outside both lemmas.
   - *Proved, conditional:* under an explicitly stated **saddle-to-saddle approximation hypothesis**, the network inherits the race model's time-indexed Occam bound (Theorem C3.4), for a finite gate library, with counting constants that differ for Boolean and real-valued gates. The hypothesis comes in a sign form and an $L^2$ form. It can be tested with unlabelled inputs, and whenever the test passes, C1 already gives an unconditional certificate (Corollary C3.5).
   - *Numerical, first test* (§3.4): on the saved μP Adam runs, during the first plateau the network predicts the majority label everywhere (and3, dnf3), which is the race's constant $s=0$ state. Any learner that fits the mean first does this, so it is no evidence for circuit growth. During the transitions, which are the real test, the network is only partly close to race states, at disagreement $0.1$–$0.3$. For par3 the fan-in-2 race never starts while the network succeeds. So this crude form of SSA is supported only in the trivial constant state.
4. **Online protocol (C4, Proved unless marked).**
   - The prequential (online) error bounds the test error of a uniformly random iterate, with a fast-rate form $\frac{\lambda M+\ln(1/\delta)}{(1-e^{-\lambda})N}$ for $M$ online mistakes (Proposition C4.1).
   - Every later sample is a free test point for every earlier iterate. This certifies the *best* checkpoint, and, through unlabelled disagreement, the *final* iterate (Proposition C4.2).
   - Circuit size turns into a time-to-learn bound through the race's clock noise. At the smallest admissible sampling rate $b/\eta$, one correct move costs at most about $100\ln(2|\mathcal M|/\delta)/\gamma^2+b$ fresh samples, independently of $\Theta$ and hence of $\alpha$ (Proposition C4.3, proved in the race model). A run of $T$ moves needs about $(t^*/\Delta)^2\ln|\mathcal M|$ samples, which is at least $T\ln|\mathcal M|/(\kappa(\Delta/\Theta)^2)$ by A's size bound, with a data-dependent $\kappa$ (Heuristic C4.4, for the pure attach race): "description length over relative margin squared", where the Occam batch learner pays description length over $\varepsilon$.

| result | content | status |
|---|---|---|
| Lemma C0.1–C0.3 | kl-Chernoff (also for $[0,1]$-valued variables); Cover's count; VC dimension of sign classes of vector spaces | Proved |
| Theorem C1 | distillation certificate, uniform over classes, selections and checkpoints | Proved |
| Proposition C1.2 | Fourier-sign class: VC $=T+1$ per support; $\ln\lvert\mathcal F_{k,T}\rvert\le\ln\binom{D_k^*}{T}+\ln\Phi(2^{\min(T,d)},T)$ | Proved |
| Proposition C1.3 | fan-in-2 circuits: $\lvert\mathcal C_{\le T}\rvert\le\sum_{s\le T}(16(d+s)^2)^s(d+s)/s!$ | Proved |
| Proposition C1.4 | juntas: exact count $\sum_j\binom dj N_j$ | Proved |
| Proposition C1.5 | Fourier concentration or small irrelevant influence implies a certificate exists (sufficient, not necessary) | Proved |
| §1.2, after C1.5 | distance of the saved final networks to the best real-valued junta on the relevant set, by a pair estimator | Numerical |
| §1.4 | certificates for the saved networks | Numerical |
| §1.6 | certificates along training from saved predictions; the certificate-minimizing class grows in stages | Numerical |
| Lemma C2.1 | closed form and mirror-flow form of the diagonal network | Proved; Numerical check |
| Theorem C2.2 | no growth before $\tau=\Theta_\varepsilon$; first-escape bracket | Proved |
| Theorem C2.3 | $N_\varepsilon\le\kappa\tau^2/\Theta_\varepsilon^2$; $N_\varepsilon\le(\int\lVert\nabla L\rVert_2)^2/\Theta_\varepsilon^2$; $\ell_1$ identity | Proved |
| Theorem C2.4, Corollary C2.5 | generalization uniform in $t$ and $\varepsilon$; time-indexed size term (data-dependent $\kappa_B$, empirical coherence, or a function of $(n,D,\tau)$ alone); $\ln D$ dependence | Proved |
| Proposition C2.6 | the same for discrete GD and minibatch SGD: no early growth in minibatch effective time; size via integrated gradient norms | Proved |
| §3.1 | what is known for ReLU networks from small initialization | Literature |
| Lemma C3.1, C3.2 | Gronwall no-growth bounds (two-layer per neuron; deep homogeneous); not covering the study's μP Adam runs | Proved |
| Lemma C3.3 | race size bound $T\le\kappa(\tau/\Theta)^2$ (A's Theorem A2.3, re-proved) | Proved |
| Theorem C3.4 | network inherits the race bound under hypothesis SSA (sign or $L^2$ form); finite library, Boolean or real-valued gates | Proved (conditional) |
| Corollary C3.5 | testing SSA with unlabelled inputs; unconditional certificate | Proved |
| §3.4 | SSA tested on the saved runs: holds only in the trivial constant state of the first plateau, partly in transitions, fails for par3 | Numerical |
| Proposition C4.1, C4.2 | online-to-batch (Hoeffding, fast rate); best and final iterate | Proved |
| Proposition C4.3 | first move of the online race: $N_1=O(\ln\lvert\mathcal M\rvert/\gamma^2)+b$ samples at the smallest admissible sampling rate | Proved (race model) |
| C4.4 | multi-move time-to-learn $\approx(t^*/\Delta)^2\ln\lvert\mathcal M\rvert$ (pure attach race) | Heuristic |

---

## 0. Setting, notation, and three lemmas

**Data.** $\mathcal X=\{-1,1\}^d$, here $d=30$, with $x$ uniform and $y=f^\star(x)\in\{-1,1\}$; most statements hold for any $P$ on $\mathcal X\times\{-1,1\}$ whose input marginal $P_X$ we can sample. The training set $S=((x_i,y_i))_{i\le n}$ is iid from $P$. For $h,g:\mathcal X\to\{-1,1\}$,
$$\mathrm{err}(h)=P(h(x)\ne y),\qquad \mathrm{dis}(h,g)=P_X(h(x)\ne g(x)),$$
and $\widehat{\mathrm{err}}_S$, $\widehat{\mathrm{dis}}_U$ are the empirical versions on $S$ and on an unlabelled sample $U=(u_1,\dots,u_m)$. For a real function $f$, $\mathrm{sgn}f$ uses the convention $\mathrm{sgn}(0)=+1$, as the scripts do, and $\mathrm{err}(\mathrm{sgn}f)=P(\mathrm{sgn}f(x)\ne y)$; this is what Theorem C1 bounds. The margin results (Theorems C2.4 and C3.4(2)) bound the larger quantity $P(yf(x)\le0)$, so they hold under either convention. Write $\langle a,b\rangle_n=\frac1n\sum_ia(x_i)b(x_i)$ and $\|a\|_n$. Logarithms are natural.

**Characters.** For $S\subseteq[d]$, $\chi_S(x)=\prod_{i\in S}x_i$; distinct characters are orthonormal in $L^2(P_X)$. $D_k=\sum_{i=0}^k\binom di$ counts the characters of degree $\le k$, and $D_k^*=D_k-1$ the non-constant ones.

**The kl inverse.** $\mathrm{kl}(q\|p)=q\ln\frac qp+(1-q)\ln\frac{1-q}{1-p}$ and
$$\mathrm{kl}^{-1}_+(q,\varepsilon)=\sup\{p\in[q,1]:\mathrm{kl}(q\|p)\le\varepsilon\}.$$
It is nondecreasing in both arguments, and
$$\mathrm{kl}^{-1}_+(q,\varepsilon)\le q+\sqrt{2q\varepsilon}+2\varepsilon,\qquad \mathrm{kl}^{-1}_+(q,\varepsilon)\le q+\sqrt{\varepsilon/2},\qquad\mathrm{kl}^{-1}_+(0,\varepsilon)=1-e^{-\varepsilon}\le\varepsilon .$$
The first follows from $\mathrm{kl}(q\|p)\ge(p-q)^2/(2p)$ for $q\le p$, the second from Pinsker's inequality $\mathrm{kl}\ge2(p-q)^2$, the third from $\mathrm{kl}(0\|p)=-\ln(1-p)$. Proofs of the first two are in [A, Lemma 1.3](A-discrete-model.md); they are only used to read the kl form additively.

### Lemma C0.1 (kl-Chernoff) — Proved

Let $\hat p$ be the mean of $n$ iid Bernoulli($p$) variables, and $\varepsilon\ge0$. Then $P\big(p>\mathrm{kl}^{-1}_+(\hat p,\varepsilon)\big)\le e^{-n\varepsilon}$. The same holds for iid variables $Z_i$ with values in $[0,1]$ and mean $p$.

*Proof.*
1. *Chernoff.* For $0\le q\le p$, $P(\hat p\le q)\le e^{-n\,\mathrm{kl}(q\|p)}$. For $q=0$ this is $(1-p)^n$. For $q>0$ and $\lambda\ge0$, Markov's inequality gives $P(\hat p\le q)\le e^{\lambda nq}(1-p+pe^{-\lambda})^n$. With $e^{-\lambda}=\frac{q(1-p)}{p(1-q)}\le1$ the right side is $e^{-n\,\mathrm{kl}(q\|p)}$.
2. *Inversion.* Since $p'\mapsto\mathrm{kl}(\hat p\|p')$ increases on $[\hat p,1]$, the event $p>\mathrm{kl}^{-1}_+(\hat p,\varepsilon)$ equals $\{\hat p<p,\ \mathrm{kl}(\hat p\|p)>\varepsilon\}$. The map $q\mapsto\mathrm{kl}(q\|p)$ decreases continuously on $[0,p]$ from $\mathrm{kl}(0\|p)$ to $0$. If $\mathrm{kl}(0\|p)\le\varepsilon$ the event is empty. Otherwise there is $q^*\in(0,p)$ with $\mathrm{kl}(q^*\|p)=\varepsilon$, and the event is $\{\hat p<q^*\}$, whose probability is at most $e^{-n\varepsilon}$ by step 1.
3. *$[0,1]$-valued variables.* Step 1 used only $\mathbb E e^{-\lambda Z}\le1-p+pe^{-\lambda}$, which holds for $Z\in[0,1]$ with mean $p$ by convexity of $z\mapsto e^{-\lambda z}$. For $q=0$, $P(Z=0)\le1-p$ because $P(Z>0)\ge\mathbb EZ$. Step 2 is unchanged. ∎

### Lemma C0.2 (Cover's count of threshold functions) — Proved

Let $Z\subset\mathbb R^T$ be finite with $N$ points. The number of functions $Z\to\{-1,1\}$ of the form $z\mapsto\mathrm{sgn}(c_0+c\cdot z)$, with a fixed convention for $\mathrm{sgn}(0)$, is at most
$$\Phi(N,T)=2\sum_{i=0}^{T}\binom{N-1}{i}\ \le\ 2N^T .$$

*Proof.* This is [A, Lemma 1.2](A-discrete-model.md), whose argument I repeat in brief.
1. Perturbing $c_0$ by less than the smallest nonzero $|c_0+c\cdot z|$, in the direction of the convention, turns every pattern into a *strict* one ($c_0+c\cdot z\ne0$ on $Z$) without changing it. So it suffices to count strict sign patterns of $N$ vectors $v_j=(1,z_j)$ in $\mathbb R^{T+1}$.
2. Let $C(N,D)$ be the largest number of strict patterns of $N$ vectors in $\mathbb R^D$. A strict pattern of $v_1..v_{N+1}$ restricts to one of $v_1..v_N$, which extends in at most two ways. If it extends in both ways, the convex set of weights realizing it contains points on both sides of $v_{N+1}^\perp$, hence a point $w_0\in v_{N+1}^\perp$. Then the restricted pattern is a strict pattern of the projections of $v_1..v_N$ onto $v_{N+1}^\perp$, a $(D-1)$-dimensional space. So $C(N+1,D)\le C(N,D)+C(N,D-1)$.
3. With $C(1,D)\le2$ and $C(N,1)\le2$, induction gives $C(N,D)\le2\sum_{i<D}\binom{N-1}i$, which is $\Phi(N,T)$ for $D=T+1$. The simplification uses $\sum_{i\le T}\binom Mi\le(1+M)^T$. ∎

For $T\le4$ and $Z=\{-1,1\}^T$, $\Phi=4,14,128,3882$ against the exact counts $4,14,104,1882$ (A, checked by linear programming).

### Lemma C0.3 (VC dimension of a sign class of a vector space) — Proved

Let $V$ be a $D$-dimensional vector space of real functions on a set $\mathcal X$. Fix either convention for $\mathrm{sgn}(0)$. Then $\{\mathrm{sgn}\circ v:v\in V\}$ has VC dimension exactly $D$.

*Proof.*
- *At most $D$.* Suppose $x_1,\dots,x_{D+1}$ are shattered. The image of $v\mapsto(v(x_i))_{i\le D+1}$ has dimension at most $D$, so some $\lambda\ne0$ satisfies $\sum_i\lambda_iv(x_i)=0$ for all $v\in V$. Replacing $\lambda$ by $-\lambda$ if needed, $\lambda$ has a positive entry.
  - Convention $\mathrm{sgn}(0)=+1$: take the labelling $-1$ where $\lambda_i>0$ and $+1$ where $\lambda_i\le0$. A $v$ realizing it has $v(x_i)<0$ where $\lambda_i>0$ and $v(x_i)\ge0$ elsewhere, so $\sum_i\lambda_iv(x_i)<0$, a contradiction.
  - Convention $\mathrm{sgn}(0)=-1$: take $+1$ where $\lambda_i>0$ and $-1$ elsewhere. Then $\sum_i\lambda_iv(x_i)>0$, a contradiction.
- *At least $D$.* Let $v_1..v_D$ be a basis. The functions are linearly independent, so the matrix $(v_j(x))_{x\in\mathcal X,j\le D}$ has rank $D$, and some $D$ points $x_1..x_D$ give an invertible $D\times D$ submatrix. Every target vector of values, in particular every $\pm1$ pattern, is then realized exactly by some $v\in V$. ∎

This is the Steele (1975) / Dudley (1978) theorem (**Literature**; the attribution was checked against lecture notes, the book numbering in Anthony–Bartlett 1999 is from memory).

---

## 1. C1: distillation certificates without labelled hold-out data

### 1.1 The theorem

**Setting.**
- **Classes.** $\{\mathcal H_c\}_{c\in I}$ is a countable family of *finite* classes of functions $\mathcal X\to\{-1,1\}$, fixed before seeing any data. Weights $\pi(c)>0$ satisfy $\sum_c\pi(c)\le1$.
- **Training.** $\xi$ is the internal randomness of training (initialization, minibatch order), independent of $S$. The predictors to be certified, $h_1,\dots,h_J$ (for example the checkpoints of one run), are arbitrary functions of $(S,\xi)$.
- **Unlabelled inputs.** $U=(u_1,\dots,u_m)$ is iid from $P_X$ and independent of $(S,\xi)$.
- **Selection.** Any rule, possibly randomized, that picks a class index $c$ and a predictor $g\in\mathcal H_c$ as a function of $(S,\xi,U)$, for each $j$.

### Theorem C1 (distillation certificate) — Proved

With probability at least $1-\delta_1-\delta_2$ over $(S,\xi,U)$, **simultaneously for every $j\le J$, every $c\in I$ and every $g\in\mathcal H_c$**,
$$\mathrm{err}(h_j)\ \le\ \underbrace{\mathrm{kl}^{-1}_+\Big(\widehat{\mathrm{err}}_S(g),\ \varepsilon^S_c\Big)}_{\text{Occam term}}\ +\ \underbrace{\mathrm{kl}^{-1}_+\Big(\widehat{\mathrm{dis}}_U(h_j,g),\ \varepsilon^U_c\Big)}_{\text{disagreement term}},$$
$$\varepsilon^S_c=\frac{\ln|\mathcal H_c|+\ln\frac1{\pi(c)}+\ln\frac1{\delta_1}}{n},\qquad \varepsilon^U_c=\frac{\ln|\mathcal H_c|+\ln\frac1{\pi(c)}+\ln\frac J{\delta_2}}{m}.$$
In particular the bound holds for whatever $(c,g)$ the selection rule produces. In additive form, writing $e=\widehat{\mathrm{err}}_S(g)$ and $\hat\rho=\widehat{\mathrm{dis}}_U(h,g)$:
$$\mathrm{err}(h)\le e+\hat\rho+\sqrt{2e\,\varepsilon^S_c}+2\varepsilon^S_c+\sqrt{2\hat\rho\,\varepsilon^U_c}+2\varepsilon^U_c .$$
Two variants:
- **(b) Split pool.** Split $U$ into $U_A$ and $U_B$. Suppose a finite candidate list $(c_1,g_1),\dots,(c_K,g_K)$ is chosen as a function of $(S,\xi,U_A)$, and $U_B$ (of size $m_B$) is independent of $(S,\xi,U_A)$. Then $\varepsilon^U$ may be replaced by $\ln(JK/\delta_2)/m_B$, with no $\ln|\mathcal H_c|$.
- **(c) Exact disagreement.** If $\mathrm{dis}(h_j,g)$ is computed exactly, the second term is $\mathrm{dis}(h_j,g)$ itself, and the statement holds with probability $1-\delta_1$. This applies, for instance, when both predictors depend on few coordinates, or when $|\mathcal X|$ is small enough to enumerate.

*Proof.*
1. **Occam event (depends on $S$ only).** For a *fixed* $g$, Lemma C0.1 gives $P_S(\mathrm{err}(g)>\mathrm{kl}^{-1}_+(\widehat{\mathrm{err}}_S(g),\varepsilon^S_c))\le e^{-n\varepsilon^S_c}=\pi(c)\delta_1/|\mathcal H_c|$. A union bound over $g\in\mathcal H_c$ and then over $c$ gives an event $E_1$ with $P(E_1^c)\le\delta_1$. On $E_1$ the inequality holds for *every* $g$ in every class, so it holds for any $g$ selected in any way, including using $S$, $\xi$, $h_j$ and $U$.
2. **Disagreement event (conditional on $(S,\xi)$).** Condition on $(S,\xi)$. Then $h_1..h_J$ are fixed functions, and by independence $U$ is still iid from $P_X$. For fixed $(j,g)$, the indicators $\mathbb 1[h_j(u_i)\ne g(u_i)]$ are iid Bernoulli($\mathrm{dis}(h_j,g)$). Lemma C0.1 and a union bound over $j$, $c$ and $g\in\mathcal H_c$ give conditional failure probability at most $\sum_j\sum_c|\mathcal H_c|e^{-m\varepsilon^U_c}=\sum_c\pi(c)\delta_2\le\delta_2$. Integrating over $(S,\xi)$ gives an event $E_2$ with $P(E_2^c)\le\delta_2$.
3. **Triangle inequality.** Pointwise, $\mathbb 1[h(x)\ne y]\le\mathbb 1[g(x)\ne y]+\mathbb 1[h(x)\ne g(x)]$. Taking expectations, $\mathrm{err}(h)\le\mathrm{err}(g)+\mathrm{dis}(h,g)$. On $E_1\cap E_2$ both terms are bounded as stated.
4. **Variant (b).** Condition on $(S,\xi,U_A)$. The $JK$ pairs $(h_j,g_k)$ are then fixed and $U_B$ is iid, so the union in step 2 is over $JK$ pairs only.
5. **Variant (c).** Step 2 is not needed. ∎

**The subtlety about choosing $g$ after seeing $S$ and $h$.** Three things are worth saying.
- *Why the bound survives.* The Occam event $E_1$ is a statement about all of $\bigcup_c\mathcal H_c$ at once. It does not mention $h$ or the selection rule. So $g$ may be fitted to $h$, which was itself fitted to $S$; the dependence on $S$ is paid for by $\ln|\mathcal H_c|$, not by independence. The disagreement event needs only that $h$ is a function of $(S,\xi)$ and that $U\perp(S,\xi)$. The selection may also use $U$ itself, at the price of $\ln|\mathcal H_c|$ in $\varepsilon^U$, or of a split pool.
- *What would break it.*
  - Estimating the disagreement on the training inputs $x_1..x_n$. Example: $h=f^\star$ on the training inputs and $h=-f^\star$ elsewhere, $g=f^\star$. Then $\widehat{\mathrm{dis}}_{S}(h,g)=0$, but $\mathrm{dis}(h,g)\approx1$ and $\mathrm{err}(h)\approx1$.
  - Training the network on the unlabelled pool, for example semi-supervised training or test-time adaptation: then $h$ depends on $U$, and step 2 fails.
  - Counting a class $\mathcal H_c$ that was itself defined using the data, for example "juntas on the coordinates the network uses", with its size counted as if those coordinates were fixed. The selection may use the data; the *counted class* must be fixed in advance. In §1.3 the coordinates are chosen from the network, but the count $\binom{30}{r}$ covers all coordinate sets.
- *What it costs to certify the whole trajectory.* $J$ checkpoints cost $\ln J/m$ in the unlabelled term only, because $E_1$ does not involve $h$. Unlabelled inputs from the known uniform distribution are free, so $m$ can be $10^5$–$10^6$, and this cost is negligible.

**Relation to the literature.**
- The structure "test error $\le$ complexity of a simpler predictor plus distillation error" is that of Hsu–Ji–Telgarsky–Wang, *Generalization bounds via distillation*, ICLR 2021 (**Literature**, abstract checked). They need data augmentation to estimate the distillation error. Here the input distribution is known, so fresh inputs play that role.
- Bounding a classifier's error through disagreements measured on unlabelled data goes back to Kääriäinen, *Generalization error bounds using unlabeled data*, COLT 2005, LNCS 3559, 127–142 (**Literature**, abstract checked).
- Compression bounds (Arora–Ge–Neyshabur–Zhang, ICML 2018) and B's Proposition 6.1 have the same skeleton. Theorem C1 is B's Proposition 6.1 with three additions: uniformity over checkpoints, selection allowed to depend on $U$, and the exact-disagreement variant.

### 1.2 The classes and their sizes

**(i) Signs of $T$ Fourier characters.** Let
$$\mathcal F_{k,T}=\Big\{\mathrm{sgn}\big(w_0+\textstyle\sum_{j=1}^Tw_j\chi_{S_j}\big):\ S_1,\dots,S_T\ \text{distinct},\ 1\le|S_j|\le k,\ w\in\mathbb R^{T+1}\Big\},\qquad \mathrm{sgn}(0)=+1 .$$
The constant term is free and not counted in $T$.

### Proposition C1.2 (Fourier-sign class) — Proved

1. For a fixed support $\mathcal S=\{S_1..S_T\}$, the class $\mathcal F_{\mathcal S}$ has VC dimension exactly $T+1$.
2. $|\mathcal F_{\mathcal S}|\le\Phi(2^r,T)$, where $r\le\min(T,d)$ is the GF(2)-rank of the indicator vectors $\mathbb 1_{S_1},\dots,\mathbb 1_{S_T}$. Hence
$$\ln|\mathcal F_{k,T}|\ \le\ \ln\binom{D_k^*}{T}+\ln\Phi\big(2^{\min(T,d)},T\big).$$
3. $T+1\le\mathrm{VCdim}(\mathcal F_{k,T})\le\log_2|\mathcal F_{k,T}|$.

*Proof.*
1. $V=\mathrm{span}\{1,\chi_{S_1},\dots,\chi_{S_T}\}$ has dimension $T+1$, because distinct characters are orthonormal. Apply Lemma C0.3.
2. Write $x_i=(-1)^{b_i}$ with $b\in\mathrm{GF}(2)^d$. Then $\chi_{S_j}(x)=(-1)^{(Mb)_j}$, where the rows of $M$ are the $\mathbb 1_{S_j}$. So $z(x)=(\chi_{S_j}(x))_j$ takes exactly $2^{\mathrm{rank}M}$ values, and every $g\in\mathcal F_{\mathcal S}$ has the form $g=\psi\circ z$ with $\psi$ an affine threshold function on that point set. Lemma C0.2 bounds the number of $\psi$. Take a union over the $\binom{D_k^*}T$ supports.
3. Item 3 follows from items 1 and 2. ∎

The exact VC dimension of the union over supports is not determined here. On the cube it is not needed, because the class is finite and item 2 bounds its size.

**(ii) Fan-in-2 Boolean circuits.** Let $B_2$ be the set of all 16 functions $\{-1,1\}^2\to\{-1,1\}$. A circuit with $s$ gates has gates named $1..s$. Each gate has a function in $B_2$ and an ordered pair of input wires among the $d$ inputs and the $s$ gates. The output is one wire, an input or a gate, and the circuit must be acyclic. Let $\mathcal C_{\le T}$ be the set of functions computed by such circuits with at most $T$ gates.

### Proposition C1.3 (circuit count) — Proved

$$|\mathcal C_{\le T}|\ \le\ \sum_{s=0}^{T}\frac{\big(16(d+s)^2\big)^s(d+s)}{s!},\qquad\text{so}\qquad\ln|\mathcal C_{\le T}|\le\ln(T+1)+T\ln\big(16(d+T)^2\big)+\ln(d+T)-\ln T!\ .$$

*Proof.*
1. *Descriptions.* Let $\mathrm{Desc}_s$ be the set of all descriptions with gate names $1..s$, a function and an ordered input pair from the $d+s$ wires for each gate, and an output wire. So $|\mathrm{Desc}_s|=(16(d+s)^2)^s(d+s)$.
2. *Reduced descriptions.* Let $A_s\subseteq\mathrm{Desc}_s$ be the acyclic descriptions with **no duplicate gates**, that is, no two gates with the same function and the same input pair.
3. *Every function has a reduced description.* Every $f\in\mathcal C_{\le T}$ has some circuit size $s\le T$, and a smallest circuit for it lies in $A_s$. If two gates $t,t'$ were duplicates, they would compute the same function. Redirecting all readers of $t'$ to $t$, the output included, and deleting $t'$, would give a smaller circuit for $f$. This keeps the circuit acyclic: $t$ cannot depend on $t'$, since its inputs are those of $t'$.
4. *The renaming action is free.* The symmetric group $\mathfrak S_s$ acts on $\mathrm{Desc}_s$ by renaming gates. The action preserves $A_s$ and the computed function. Suppose a permutation $\pi$ fixes some $D\in A_s$. I show $\pi(t)=t$ for every gate $t$, by induction on the depth of $t$, which is well defined by acyclicity.
   - Since $\pi$ fixes $D$, gate $\pi(t)$ has the same function as $t$, and its inputs are the images under $\pi$ of the inputs of $t$, with input wires fixed.
   - By induction those inputs are fixed by $\pi$, so $\pi(t)$ and $t$ have the same function and the same inputs.
   - Since $D$ has no duplicates, $\pi(t)=t$.
5. *Count.* Orbits in $A_s$ therefore have exactly $s!$ elements, and the number of distinct functions of circuit size exactly $s$ is at most $|\mathrm{Desc}_s|/s!$. Sum over $s\le T$. The terms increase in $s$, so the sum is at most $(T+1)$ times the last term. ∎

The $1/s!$ is the classical saving in Shannon-type counting arguments (Shannon, Bell Syst. Tech. J. 28 (1949) 59–98, is the usual citation; **Literature**, the attribution is from memory). At $d=30$ it saves $\ln T!$: about 3 nats at $T=4$ and 15 nats at $T=10$.

Examples of circuit sizes: AND$_3$ has 2 gates, PAR$_k$ has $k-1$, and MAJ$_3=((x_1\oplus x_2)\wedge x_3)\vee(x_1\wedge x_2)$ has 4.

**(iii) Juntas.** Let $\mathcal J_{\le k}$ be the set of functions $\{-1,1\}^d\to\{-1,1\}$ that depend on at most $k$ coordinates.

### Proposition C1.4 (exact junta count) — Proved

$$|\mathcal J_{\le k}|=\sum_{j=0}^k\binom dj N_j,\qquad N_j=\sum_{i=0}^j(-1)^{j-i}\binom ji2^{2^i},$$
where $N_j$ is the number of functions of $j$ variables that depend on all of them. Moreover $2^k\le\mathrm{VCdim}(\mathcal J_{\le k})\le\log_2|\mathcal J_{\le k}|$, and $|\mathcal J_{\le k}|\le\binom dk2^{2^k}$ for $k\le d$.

*Proof.*
- *Count.* Every $f$ has a unique set $R(f)$ of coordinates it depends on. So $\mathcal J_{\le k}$ is the disjoint union over $|R|\le k$ of the functions with relevant set exactly $R$, and there are $N_{|R|}$ of those. By inclusion–exclusion over the set of variables a function ignores, $N_j=\sum_{A\subseteq[j]}(-1)^{|A|}2^{2^{j-|A|}}$, which is the stated formula.
- *VC lower bound.* The $2^k$ points that vary in coordinates $1..k$ and equal $1$ elsewhere are shattered by functions of $x_1..x_k$.
- *Size bound.* Every function in $\mathcal J_{\le k}$ is a function of some $k$-set. ∎

| $d=30$ | $k=1$ | $2$ | $3$ | $4$ | $5$ | $6$ |
|---|---|---|---|---|---|---|
| $N_k$ | 2 | 10 | 218 | 64 594 | 4 294 642 034 | $\approx1.8\cdot10^{19}$ |
| $\ln\lvert\mathcal J_{\le k}\rvert$ | 4.13 | 8.39 | 13.70 | 21.29 | 34.05 | 57.66 |
| $\ln[\binom{30}k2^{2^k}]$ | 4.79 | 8.85 | 13.85 | 21.31 | 34.05 | 57.66 |

**Sizes at $d=30$** ([`checks/c1_class_sizes.txt`](checks/c1_class_sizes.txt)), in nats:

| class | $T=1$ | 2 | 3 | 4 | 6 | 8 | 10 | 12 |
|---|---|---|---|---|---|---|---|---|
| $\mathcal F_{1,T}$ | 4.8 | 8.7 | 13.2 | 18.5 | 32.1 | 49.9 | 72.1 | 98.8 |
| $\mathcal F_{2,T}$ | 7.5 | 14.2 | 21.5 | 29.6 | 49.1 | 72.8 | 101.1 | 134.1 |
| $\mathcal F_{3,T}$ | 9.8 | 18.8 | 28.3 | 38.8 | 62.8 | 91.1 | 123.9 | 161.5 |
| $\mathcal C_{\le T}$ | 13.1 | 22.2 | 31.0 | 39.6 | 56.6 | 73.4 | 90.1 | 106.7 |

**Brute-force checks** (same file): the junta formula matches enumeration for $(d,k)=(3,2),(4,2),(4,3)$, giving $38,70,942$. The circuit bound exceeds the exact counts of functions of $B_2$-circuit size $\le T$: $16$ for $d=2$ and $38,152$ for $d=3$, $T=1,2$. Random search over weights finds at most as many Fourier-sign functions on $\{-1,1\}^3$ as Proposition C1.2 allows. The count of 104 for $k=1$, $T=3$ is the number of threshold functions of three variables, against a bound of 128.

**Which class wins.** For $r$ relevant variables with no structure, juntas cost $2^r\ln2+\ln\binom dr$. Fourier-sign classes cost about $T(\ln D_k+\min(T,d)\ln 2)$ and win for targets that are signs of few characters: threshold-like targets, where $T=r$ characters of degree 1 suffice, and parities. PAR$_8=\chi_{[8]}$ lies in $\mathcal F_{8,1}$, at $\ln D_8^*+\ln4=17.4$ nats, against 65 nats as a 7-gate circuit and 193 nats as an 8-junta. Circuits cost at most about $\ln(16d^2)$ nats per gate, less the $\ln T!$ saving, and win for structured targets whose sign representations need many characters, such as DNFs. dnf3, an OR of three 3-literal ANDs on disjoint variables, has an 8-gate circuit, at $\ln|\mathcal C_{\le8}|=73.4$ nats. Its obvious Fourier-sign representation $\mathrm{sgn}(p_1+p_2+p_3-\frac12)$, with $p_j\in\{0,1\}$ the indicator of term $j$, uses 21 characters of degree $\le3$, at $392$ nats. As a 9-junta it costs $371$ nats ([`checks/C_r2_checks.out`](checks/C_r2_checks.out) §1). The 392 nats are the size of the counted class $\mathcal F_{3,21}$, with the $2^{\min(T,d)}$ point count; they describe the loose class, not the representation. The 21 supports have GF(2) rank 9, and a class of degree-$\le3$ characters supported inside some 9 of the 30 coordinates costs, by the argument of Proposition C1.2(2), at most $\ln\binom{30}9+\ln\binom{129}T+\ln\Phi(2^9,T)$ nats: $142.6$, $147.6$ and $157.3$ for $T=18,19,21$, against $304.0$, $332.1$ and $392.3$ for $\mathcal F_{3,T}$ (round-2 referee, [`checks/referee_C_r2.json`](checks/referee_C_r2.json)). That class is not in the hierarchy used in §1.4. Circuits, at 73.4 nats, still win.

### Proposition C1.5 (when a certificate exists) — Proved

Let $h:\{-1,1\}^d\to\{-1,1\}$ have Fourier coefficients $\hat h(S)$, and let $\mathrm{Inf}_i(h)=P(h(x)\ne h(x^{\oplus i}))$.
1. **Fourier concentration.** For any set $\mathcal S$ of nonempty characters, the predictor $g=\mathrm{sgn}(\hat h(\emptyset)+\sum_{S\in\mathcal S}\hat h(S)\chi_S)$ satisfies
$$\mathrm{dis}(h,g)\le1-\hat h(\emptyset)^2-\sum_{S\in\mathcal S}\hat h(S)^2 .$$
2. **Small irrelevant influence.** For any coordinate set $R$, the cellwise majority junta $g_R(x)=\mathrm{sgn}\,\mathbb E[h\mid x_R]$ satisfies
$$\mathrm{dis}(h,g_R)\le\tfrac12\sum_{S\not\subseteq R}\hat h(S)^2\le\tfrac12\sum_{i\notin R}\mathrm{Inf}_i(h).$$

*Proof.*
1. If $g(x)\ne h(x)$ then $|h(x)-p(x)|\ge1$, where $p$ is the truncated expansion: $h=\pm1$, and $p$ has the opposite sign or is $0$ with $h=-1$. So $\mathrm{dis}(h,g)\le\mathbb E(h-p)^2$, which equals the stated quantity by Parseval. This is the Linial–Mansour–Nisan argument (JACM 40(3), 1993; **Literature**, from memory).
2. Conditionally on $x_R$, $h$ is $\pm1$ with mean $\mu$, and it disagrees with $\mathrm{sgn}\,\mu$ with probability $\frac{1-|\mu|}2\le\frac{1-\mu^2}2=\frac12\mathrm{Var}(h\mid x_R)$. Then:
   - $\mathbb E\,\mathrm{Var}(h\mid x_R)=\sum_{S\not\subseteq R}\hat h(S)^2$, because $\mathbb E[h\mid x_R]=\sum_{S\subseteq R}\hat h(S)\chi_S$;
   - each $S\not\subseteq R$ contains some $i\notin R$;
   - $\mathrm{Inf}_i(h)=\mathbb E[(D_ih)^2]=\sum_{S\ni i}\hat h(S)^2$, where $D_ih=(h-h\circ\oplus_i)/2=\sum_{S\ni i}\hat h(S)\chi_S$. ∎

So certificates of the kind used in §1.4 exist in particular when the network's *sign function* is close to Fourier-sparse, or has small total influence outside a small set. The conditions are sufficient, not necessary: Fourier-sign certificates also cover threshold-like functions that are far from Fourier-sparse. MAJ$_9$ has level-1 Fourier weight $9\cdot(70/256)^2=0.673$, so item 1 with its 9 linear characters guarantees only $\mathrm{dis}\le0.327$. Yet $\mathrm{sgn}(\sum_{i\le9}x_i)=\mathrm{MAJ}_9$ exactly, and §1.4 certifies maj9 at $0.034$ through $\mathcal F_{1,9}$ ([`checks/referee_C_r1_small.out`](checks/referee_C_r1_small.out)).

**Distance to the best real-valued junta.** For a real function $f$ and a coordinate set $R$, the computation in item 2 gives
$$\|f-\mathbb E[f\mid x_R]\|_{L^2}^2=\sum_{S\not\subseteq R}\hat f(S)^2\ \le\ \sum_{i\notin R}\mathrm{Inf}_i(f),\qquad \mathrm{Inf}_i(f)=\tfrac14\mathbb E(f-f\circ\oplus_i)^2 .$$
The left side is the squared $L^2$ distance from $f$ to the best real-valued junta on $R$.
- *What the study saves.* $\mathrm{infl\_irr}$ is the mean of $\mathrm{Inf}_i(f)$ over only the *first 5* of the $d-|R|$ irrelevant coordinates (`study/nn_train.py`: `irr = [...][:5]`), estimated on 1024 test inputs. So the 5 measured terms give a *lower* bound on $\sum_{i\notin R}\mathrm{Inf}_i(f)$, up to sampling error. $(d-|R|)\cdot\mathrm{infl\_irr}$ is an extrapolation. Training is equivariant under permutations of the irrelevant coordinates, so it is unbiased for the expected sum over training runs, but it is not an upper bound for a given network, and it cannot certify $L^2$ closeness.
- *A rigorous estimate.* Draw $x$ uniform, and $x'$ with $x'_R=x_R$ and the other coordinates fresh. Then $\mathbb E\,\frac12(f(x)-f(x'))^2=\mathbb E\,\mathrm{Var}(f\mid x_R)=\|f-\mathbb E[f\mid x_R]\|^2$. For $\mathrm{clip}f$ the summand lies in $[0,2]$, so Lemma C0.1 for $[0,1]$-valued variables, applied to half the summand, gives an upper confidence bound. This needs the network itself, so it is available only where parameters are saved, that is, at the final checkpoint.
- **Numerical** ([`checks/C_r2_checks.out`](checks/C_r2_checks.out) §4; 40000 pairs per network, $\delta=0.05$ per network). On the 117 saved final networks of §1.4, the upper confidence bound on $\|\mathrm{clip}f-\mathbb E[\mathrm{clip}f\mid x_R]\|^2$ is at most $0.0072$ at $n=16384$. At $n=2048$ its median is $0.0034$ and its maximum $0.29$ (par4, whose networks there have test error up to $0.36$). The full influence sum over all irrelevant coordinates, estimated on 2000 inputs, is $0.73$–$1.55$ times the saved extrapolation $(d-|R|)\cdot\mathrm{infl\_irr}$ for the 81 networks where the sum exceeds $10^{-3}$, with median $1.02$ over all 117. So the extrapolation is right on average but off by up to a factor of about 1.5 for individual networks.

### 1.3 How the certificate is computed (no labels outside $S$)

[`checks/c1_fourier_cert.py`](checks/c1_fourier_cert.py) processes each saved final Adam network of the sweep (13 targets; $n\in\{256,2048,16384\}$; 3 seeds) as follows. The steps:
1. **Unlabelled inputs.** Draw $4000+20000+50000$ fresh uniform inputs: $U_{\rm infl}$ and $U_A$ are used for selection, $U_B$ for estimation.
2. **Coordinates.** Rank coordinates by their influence on $h=\mathrm{sgn}f$, measured on $U_{\rm infl}$, and keep the top 12.
3. **Candidates**, from $h$ and $U_A$ only:
   - **Fourier-sign** $\mathcal F_{k,T}$, for $k\le4$ and $T\le40$: the $T$ largest estimated coefficients $\hat h(S)$ with $S$ inside the top 12, in two versions. One uses the coefficients themselves as weights (Proposition C1.5(1)). The other, for $k\le2$ and $T\le16$, refits the weights by logistic regression of $h$ on those characters over $U_A$.
   - **Juntas** on the top $r\le8$ coordinates, with the cellwise majority of $h$ as truth table (Proposition C1.5(2)).
4. **Weights.** $\pi(\mathcal F,k,T)=\frac18\cdot\frac1{T(T+1)}$ and $\pi(\mathcal J,r)=\frac1{18}$.
5. **Bound.** Theorem C1, variant (b), with the list of $K=169$ candidates, $\delta_1=\delta_2=0.025$, and the counted classes the *full* classes over all 30 coordinates.

The true error, measured on $U_B$ using the target, is reported for comparison only.

**Which network is certified.** `study/nn_train.py` saves the final parameters in float16, so the certificates, and the true-error column, refer to the network rebuilt from the float16-rounded parameters, not to the float32 network that was trained. Over all 429 saved networks, the rebuilt network disagrees with the float32 network's saved sign predictions on at most 2 of the 4096 test inputs ([`checks/referee_C_r1_fp16.out`](checks/referee_C_r1_fp16.out)). The test inputs are independent of training, so one more disagreement term transfers the certificate: with additional failure probability $0.01$, $\mathrm{err}(h_{32})\le\mathrm{cert}(h_{16})+\mathrm{kl}^{-1}_+(2/4096,\ln(100)/4096)=\mathrm{cert}(h_{16})+0.0024$ ([`checks/C_r2_checks.out`](checks/C_r2_checks.out) §3).

### 1.4 Table: certificates for the saved networks

**Numerical** ([`checks/c1_fourier_cert.txt`](checks/c1_fourier_cert.txt); per-seed pairs in [`checks/C_r2_checks.out`](checks/C_r2_checks.out) §6). Entries are *true error / certificate* for seeds 0, 1, 2. A single pair means the three seeds agree to three decimals, and an error of $0$ means below $0.0005$. A certificate above 1 is the sum of two terms, each at most 1. The last column is the class of the best certificate at $n=2048$, with the best certificate from the other family in brackets. $\delta=0.05$ in total.

| target | rel. vars | $n=256$ | $n=2048$ | $n=16384$ | best class at $n=2048$ |
|---|---|---|---|---|---|
| dict ($x_1$) | 1 | 0 / 0.043 | 0 / 0.006 | 0 / 0.001 | $\mathcal F_{1,1}$ (junta 0.006) |
| and3 | 3 | 0.025 / 0.104; 0.050 / 0.131; 0.017 / 0.096 | 0 / 0.010 | 0 / 0.001 | 3-junta ($\mathcal F_{1,3}$: 0.011) |
| maj3 | 3 | 0.038 / 0.119; 0.045 / 0.126; 0.042 / 0.123 | 0 / 0.010 | 0 / 0.001 | 3-junta ($\mathcal F_{1,3}$: 0.011) |
| maj9 | 9 | 0.097 / 0.344; 0.109 / 0.357; 0.097 / 0.344 | 0 / **0.034** | 0 / 0.004 | $\mathcal F_{1,9}$ (junta: 0.41–0.43) |
| thr10 | 10 | 0.126 / 0.403; 0.124 / 0.449; 0.136 / 0.420 | 0.029 / **0.088**; 0.028 / **0.100**; 0.029 / **0.094** | 0.004 / **0.020**; 0.003 / **0.019**; 0.003 / **0.021** | $\mathcal F_{1,9\text{–}10}$, logistic refit (junta: 0.20) |
| par2 | 2 | 0.003 / 0.057; 0.001 / 0.055; 0 / 0.054 | 0 / 0.007 | 0 / 0.001 | $\mathcal F_{2,1}$ |
| par3 | 3 | 0.482 / 1.017; 0.480 / 0.968; 0.473 / 0.975 | 0 / 0.008 | 0 / 0.001 | $\mathcal F_{3,1}$ |
| par4 | 4 | 0.500 / 0.997; 0.502 / 0.949; 0.497 / 0.976 | 0.022 / 0.034; 0.361 / 0.379; 0.131 / 0.146 | 0 / 0.001 | $\mathcal F_{4,1}$ |
| dnf3 | 9 | 0.151 / 0.687; 0.196 / 0.698; 0.171 / 0.496 | 0 / **0.143**; 0 / **0.143**; 0 / **0.126** | 0 / 0.021; 0 / 0.017; 0 / 0.021 | $\mathcal F_{2\text{–}3,18}$ (junta: 0.28–0.33) |
| majpar | 6 | 0.307 / 0.634; 0.350 / 0.711; 0.328 / 0.642 | 0.042 / 0.060; 0.081 / 0.101; 0.070 / 0.090 | 0 / 0.002 | $\mathcal F_{2,3}$ (junta: 0.08–0.12) |
| mux | 4 | 0.334 / 0.829; 0.351 / 0.700; 0.355 / 0.755 | 0 / 0.014 | 0 / 0.002 | 4-junta ($\mathcal F_{4,4\text{–}5}$: 0.027–0.033) |
| parmaj | 6 | 0.324 / 0.751; 0.378 / 0.914; 0.287 / 0.672 | 0 / 0.031 | 0 / 0.004 | 6-junta ($\mathcal F_{2,9}$: 0.046) |
| stair5 | 5 | 0.330 / 0.624; 0.364 / 0.768; 0.369 / 0.695 | 0 / 0.020; 0.009 / 0.031; 0 / 0.020 | 0 / 0.003 | 5-junta ($\mathcal F_{4,5}$: 0.033–0.045) |

No certificate in the 117 runs falls below the network's true error; the smallest gap, certificate minus error, is $0.0009$.

### 1.5 Reading

- **Coverage.** At $n=2048$ every target is certified below $0.5$ for every seed. It is below $0.04$ for 9 of the 13 targets: dict, and3, maj3, maj9, par2, par3, mux, parmaj, stair5. At $n=16384$ every network is certified at $\le0.021$. At $n=256$ the six targets the networks learn there are certified at $0.04$–$0.45$.
- **Comparison with B.** B's best parameter-space bound (PAC-Bayes, Theorem B3.2) gives $0.26$–$0.56$ at $n=16384$ for the targets with at most three relevant variables, and is vacuous at $n=256$. The certificates are one to two orders of magnitude smaller.
- **The Fourier-sign class is decisive where B's junta read-off fails: maj9, thr10, dnf3.** It is also the best class for dict, par2, par3, par4 and majpar at $n=2048$, where juntas would also certify.
  - maj9 $=\mathrm{sgn}(\sum_{i\le9}x_i)$ and thr10 are signs of 9–10 degree-1 characters, at about 60–72 nats, against $2^9\ln2\approx355$ nats for a 9-junta.
  - majpar $=\mathrm{sgn}(\chi_{12}+\chi_{34}+\chi_{56})$ lies exactly in $\mathcal F_{2,3}$.
  - For thr10 the logistic refit matters. The network's own Fourier coefficients (Chow parameters) give a sign function that still disagrees with the network on 2–3% of inputs. The refit weights disagree on 0.5%, which brings the $n=16384$ certificate from $0.06$–$0.08$ down to $0.02$.
- **Juntas** are best for small relevant sets with unstructured truth tables: mux, parmaj, stair5, and narrowly and3 and maj3.
- **Circuits** (class (ii)) were not searched: finding a small circuit that agrees with $h$ is a circuit-minimization problem. They would help for dnf3. Its 8-gate circuit gives $\ln|\mathcal C_{\le8}|=73.4$ nats, against about 300 for $\mathcal F_{3,18}$ (about 143 for the rank-restricted class noted in §1.2, which is not used here). If an 8-gate circuit agreeing with $h$ were found (the target is one), the $n=2048$ certificate would be about $0.04$ instead of $0.13$.
- **Where the slack is.** When the disagreement is 0, the certificate is essentially $(\ln|\mathcal H_c|+\ln\frac1{\pi(c)}+\ln\frac1{\delta_1})/n$. For maj9 at $n=2048$ this is $(60.4+6.6+3.7)/2048=0.034$. The unlabelled term costs $\ln(K/\delta_2)/m_B\approx2\cdot10^{-4}$, since unlabelled inputs are free.
- **Where it fails.** It fails where the network fails: par3 and par4 at $n=256$, and the networks of dnf3, majpar, mux, parmaj and stair5 at $n=256$, whose per-seed test errors are $0.15$–$0.38$. The one exception is dnf3 seed 2 at $n=256$ (error $0.171$), certified at $0.496$. A certificate cannot fall below the true error by more than the deviation terms. When the network is close to the target, the certificate tracks the network's error: for par4 at $n=2048$ the seeds have error $0.022,0.361,0.131$ and certificates $0.034,0.379,0.146$.
- **What it does not explain.** It is a posteriori. It says nothing about why gradient descent produced a network that is close to a Fourier-sparse sign function or a junta. That is the job of C2 and C3.

### 1.6 Along training: the certificate-minimizing class grows in stages (Numerical)

[`checks/c1_trajectory_cert.py`](checks/c1_trajectory_cert.py) produces [`checks/c1_trajectory_cert.txt`](checks/c1_trajectory_cert.txt). It computes the same certificate at all 15 checkpoints of the seed-0 runs ($n=2048$ and $16384$), from the **saved test-set predictions alone**.
- **Inputs.** The 4096 saved test inputs are split into 2048 for selection and 2048 for estimating the disagreement. Their labels are not used.
- **Candidates.** All characters of degree $\le3$ on all 30 coordinates; no logistic refit.
- **Uniformity.** The union over the 15 checkpoints of a run is paid in the disagreement term (Theorem C1), so the entries of one run hold simultaneously over its checkpoints, each at confidence $1-\delta$ with $\delta=0.05$. Across the 8 targets of the table the failure probabilities add.

Each entry gives the best class, its log-size, and test error / certificate ($n=16384$). "Vacuous" means a certificate $\ge0.5$, with the test error in brackets.

| target | step 20 | step 50 | step 100 | step 200 | step 500 | step 20000 |
|---|---|---|---|---|---|---|
| maj3 | $\mathcal F_{1,6}$, 32 nats: 0.25 / 0.48 | $\mathcal J_{3}$, 14 nats: 0.10 / 0.12 | $\mathcal J_{3}$, 14 nats: 0.00 / 0.02 | $\mathcal J_{3}$, 14 nats: 0.00 / 0.01 | $\mathcal J_{3}$, 14 nats: 0.00 / 0.01 | $\mathcal J_{3}$, 14 nats: 0.00 / 0.01 |
| maj9 | vacuous (0.33) | $\mathcal F_{1,9}$, 60 nats: 0.11 / 0.21 | $\mathcal F_{1,9}$, 60 nats: 0.03 / 0.05 | $\mathcal F_{1,9}$, 60 nats: 0.01 / 0.03 | $\mathcal F_{1,9}$, 60 nats: 0.00 / 0.01 | $\mathcal F_{1,9}$, 60 nats: 0.00 / 0.01 |
| thr10 | $\mathcal F_{1,15}$, 148 nats: 0.26 / 0.46 | $\mathcal F_{1,10}$, 72 nats: 0.12 / 0.24 | $\mathcal F_{1,9}$, 60 nats: 0.06 / 0.18 | $\mathcal F_{1,8}$, 50 nats: 0.04 / 0.17 | $\mathcal F_{1,9}$, 60 nats: 0.03 / 0.16 | $\mathcal F_{1,8}$, 50 nats: 0.00 / 0.13 |
| majpar | vacuous (0.48) | vacuous (0.44) | vacuous (0.37) | $\mathcal F_{2,3}$, 21 nats: 0.14 / 0.19 | $\mathcal F_{2,3}$, 21 nats: 0.00 / 0.01 | $\mathcal F_{2,3}$, 21 nats: 0.00 / 0.01 |
| mux | vacuous (0.43) | vacuous (0.38) | $\mathcal J_{3}$, 14 nats: 0.38 / 0.48 | $\mathcal J_{3}$, 14 nats: 0.35 / 0.45 | $\mathcal J_{4}$, 21 nats: 0.00 / 0.01 | $\mathcal J_{4}$, 21 nats: 0.00 / 0.01 |
| stair5 | vacuous (0.39) | $\mathcal F_{1,1}$, 5 nats: 0.34 / 0.43 | $\mathcal F_{1,1}$, 5 nats: 0.31 / 0.35 | $\mathcal F_{1,1}$, 5 nats: 0.30 / 0.36 | $\mathcal J_{5}$, 34 nats: 0.11 / 0.23 | $\mathcal J_{5}$, 34 nats: 0.00 / 0.01 |
| dnf3 | $\mathcal J_{0}$, 0.7 nats: 0.34 / 0.35 | $\mathcal J_{0}$, 0.7 nats: 0.29 / 0.42 | $\mathcal F_{1,9}$, 60 nats: 0.17 / 0.30 | $\mathcal F_{2,18}$, 263 nats: 0.13 / 0.28 | $\mathcal F_{3,19}$, 332 nats: 0.00 / 0.03 | $\mathcal F_{3,19}$, 332 nats: 0.00 / 0.03 |
| par3 | vacuous (0.49) | vacuous (0.49) | vacuous (0.48) | vacuous (0.48) | $\mathcal F_{3,1}$, 10 nats: 0.00 / 0.01 | $\mathcal F_{3,1}$, 10 nats: 0.00 / 0.01 |

**Reading.**
- **Stages.** The log-size of the class that minimizes the certificate is a step function of training time:
  - stair5: 5 nats ($x_1$ alone, steps 50–200), then 34 nats (a 5-junta, from step 500);
  - mux: a 3-junta (14 nats, steps 100–200), then a 4-junta (21 nats);
  - dnf3: the constant (steps 20–50), then 9 degree-1 characters (60 nats), then 18–19 characters of degree $\le3$ (263–332 nats);
  - majpar and par3: nothing certifiable until the checkpoint at which the target's own 21-nat or 10-nat representation appears.

  This is the empirical shape of "the circuit cannot have grown big yet", with a caveat. The selected class minimizes a bound that trades error against size; it is not the size of a circuit the network is known to be close to. For stair5 at steps 50–200, for example, the best certificate uses $x_1$ alone, with test error $0.30$–$0.34$ and certificate $0.35$–$0.43$: the network is not close to $x_1$, but no larger class pays for itself yet. Where the certificate is small, as for six of the eight targets from step 500 on (not thr10 and, at step 500, stair5), the disagreement term is small too, and the network *is* certifiably close to a predictor in the selected class. §3.4 shows that the intermediate predictors are not, in general, the toy race's.
- **Cost of using only saved data.** With 2048 unlabelled points instead of 50000, and no refit, the final certificates are somewhat weaker than in §1.4: for thr10, 0.13 instead of 0.02.
- **Which class wins can change during training.** maj3 is certified as a 6-character Fourier sign at step 20 and as a 3-junta afterwards. The class is chosen per checkpoint, and the price of that choice is already in the prior $\pi$.

---

## 2. C2: a rigorous instance of "short training implies a small circuit"

### 2.1 Setting

The setting is the depth-one, 2-homogeneous case of the README's model, with no approximation.
- **Dictionary.** $\mathcal D=\{\chi_S:S\in\mathcal S\}$ with $|\mathcal S|=D$, for example all $S$ with $|S|\le k$, so that $D=D_k$.
- **Data matrix.** $X\in\{-1,1\}^{n\times D}$, with $X_{iS}=\chi_S(x_i)$, and $K=X^\top X/n$.
- **Model and loss.** $f_w=\sum_Sw_S\chi_S$, and $L(w)=\frac1{2n}\|Xw-y\|^2$.
- **Parametrization and training.** $w=u\odot u-v\odot v$, with $u(0)=v(0)=\alpha\mathbf 1$, trained by gradient flow on $F(u,v)=L(u\odot u-v\odot v)$.
- **Notation.** $r(t)=y-Xw(t)$, $g(t)=\nabla L(w(t))=-X^\top r(t)/n$ (so $g_S=-\langle r,\chi_S\rangle_n$), $G(t)=\int_0^tg$, $\tau(t)=\int_0^t\|r\|_n$ and $R(t)=\int_0^tr\in\mathbb R^n$.

### Lemma C2.1 (closed form and mirror flow) — Proved

The flow exists for all $t\ge0$ and is unique. For all $t$:
$$u(t)=\alpha e^{-2G(t)},\qquad v(t)=\alpha e^{2G(t)},\qquad u\odot v\equiv\alpha^2,\qquad w(t)=-2\alpha^2\sinh\big(4G(t)\big).$$
Equivalently, $\frac14\operatorname{arsinh}\frac{w(t)}{2\alpha^2}=-G(t)$, so $w$ follows the mirror flow $\frac{d}{dt}\nabla\phi_\alpha(w)=-\nabla L(w)$ with the hyperbolic-entropy potential
$$\phi_\alpha(w)=\tfrac14\sum_S\Big[w_S\operatorname{arsinh}\tfrac{w_S}{2\alpha^2}-\sqrt{w_S^2+4\alpha^4}+2\alpha^2\Big].$$
Moreover $L(w(t))$ is nonincreasing, $\|r(t)\|_n\le\|y\|_n$, and $|g_S(t)|\le\|r(t)\|_n$.

*Proof.*
1. $F$ is a polynomial, so a unique solution exists on a maximal interval $[0,t_{\max})$.
2. Along it, $\partial F/\partial u_S=2u_Sg_S$ and $\partial F/\partial v_S=-2v_Sg_S$. So $\dot u_S=-2g_Su_S$ and $\dot v_S=2g_Sv_S$: given $g$, these are linear scalar ODEs, solved by the stated exponentials.
3. Then $w_S=\alpha^2(e^{-4G_S}-e^{4G_S})=-2\alpha^2\sinh(4G_S)$, and inverting gives $\frac14\operatorname{arsinh}(w/2\alpha^2)=-G$. The potential satisfies $\partial_{w_S}\phi_\alpha=\frac14\operatorname{arsinh}(w_S/2\alpha^2)$.
4. $\frac d{dt}F=-\|\nabla F\|^2\le0$, so $\|r(t)\|_n\le\|r(0)\|_n=\|y\|_n$, using $w(0)=0$. Also $|g_S|=|\langle r,\chi_S\rangle_n|\le\|r\|_n$, since $\|\chi_S\|_n=1$.
5. Hence $|G_S(t)|\le t\|y\|_n$, so $u$ and $v$ stay bounded on bounded intervals, and $t_{\max}=\infty$. ∎

The hyperbolic entropy and the implicit-bias characterization of the limit, $\arg\min\phi_\alpha$ over interpolators, are due to Woodworth, Gunasekar, Lee, Moroshko, Savarese, Golan, Soudry and Srebro, *Kernel and rich regimes in overparametrized models*, COLT 2020, PMLR 125 (**Literature**; venue checked, the statement is from memory and is not used in any proof). As $\alpha\to0$ with time rescaled by $\log(1/\alpha)$, the trajectory becomes the saddle-to-saddle process of Pesme–Flammarion (NeurIPS 2023) (**Literature**, from memory, as in A).

**The link to A's race.** $-G_S(t)=\int_0^t\langle r,\chi_S\rangle_n$ is exactly A's clock $S_m(t)$, and $|w_S(t)|\ge\varepsilon$ is exactly the event "the clock has reached $\Theta_\varepsilon$", where
$$\Theta_\varepsilon:=\tfrac14\operatorname{arsinh}\frac{\varepsilon}{2\alpha^2}\ \ge\ \tfrac14\ln\frac{\varepsilon}{\alpha^2}.$$
The inequality uses $\operatorname{arsinh}z\ge\ln 2z$ for $z>0$. So the results below are A's Theorems A2.3 and A2.4, proved for the actual gradient flow at finite $\alpha$, with "fired" replaced by "grown above $\varepsilon$". The threshold is $\Theta\approx\frac12\ln\frac1\alpha$.

### Theorem C2.2 (no early growth; first escape) — Proved

1. For all $t$ and $S$: $|G_S(t)|\le\int_0^t|\langle r,\chi_S\rangle_n|\le\tau(t)\le t\,\|y\|_n$. Hence $|w_S(t)|\le2\alpha^2\sinh(4\tau(t))$, and **no coordinate reaches $\varepsilon$ while $\tau(t)<\Theta_\varepsilon$**. In particular, with $G_{\max}=\sup_s\|g(s)\|_\infty\le\|y\|_n=1$, this holds for all $t<\Theta_\varepsilon/G_{\max}$, and so for all $t<\frac{\ln(\varepsilon/\alpha^2)}{4G_{\max}}$.
2. **First escape.** Let $U_0=\max_S|\langle y,\chi_S\rangle_n|$, $\varepsilon_D=\sqrt{\lambda_{\max}(K)D}\,\varepsilon$, and $t_\varepsilon=\inf\{t:\max_S|w_S(t)|\ge\varepsilon\}$. Since $\lambda_{\max}(K)\le\mathrm{tr}K=D$, $\varepsilon_D\le D\varepsilon$. If $U_0>\varepsilon_D$, then
$$\frac{\Theta_\varepsilon}{U_0+\varepsilon_D}\ \le\ t_\varepsilon\ \le\ \frac{\Theta_\varepsilon}{U_0-\varepsilon_D}.$$

*Proof.*
1. $G_S=\int g_S$, and $|g_S|=|\langle r,\chi_S\rangle_n|\le\|r\|_n$ by Lemma C2.1. Then $|w_S|=2\alpha^2\sinh(4|G_S|)$ is increasing in $|G_S|$.
2. Bracket for $t_\varepsilon$:
   - For $t\le t_\varepsilon$, every $|w_S(t)|\le\varepsilon$. So $\|Xw\|_n^2=w^\top Kw\le\lambda_{\max}(K)\|w\|_2^2\le\lambda_{\max}(K)D\varepsilon^2$. Since $\langle r,\chi_S\rangle_n=\langle y,\chi_S\rangle_n-\langle Xw,\chi_S\rangle_n$ and $|\langle Xw,\chi_S\rangle_n|\le\|Xw\|_n$, every utility stays within $\varepsilon_D$ of its initial value.
   - *Lower bound.* $|G_S(t)|\le(U_0+\varepsilon_D)t$ for all $S$ and $t\le t_\varepsilon$. At $t_\varepsilon$ some $|w_S|=\varepsilon$, that is, $|G_S|=\Theta_\varepsilon$.
   - *Upper bound.* For $S^*$ attaining $U_0$, with $\sigma=\mathrm{sgn}\langle y,\chi_{S^*}\rangle_n$, we have $-\sigma G_{S^*}(t)\ge(U_0-\varepsilon_D)t$ for $t\le t_\varepsilon$. If $t_\varepsilon>\Theta_\varepsilon/(U_0-\varepsilon_D)$, then at $t=\Theta_\varepsilon/(U_0-\varepsilon_D)<t_\varepsilon$ we would already have $|w_{S^*}|\ge\varepsilon$, a contradiction. ∎

Item 2 is the README's rate law $T\approx\log(1/\alpha)/U$ for attach moves, with explicit two-sided constants: $\Theta_\varepsilon/U_0=\frac{\ln(1/\alpha)}{2U_0}(1+o(1))$.

### Theorem C2.3 (how many coordinates can have grown) — Proved

Let $B=B_\varepsilon(t)=\{S:|w_S(t)|\ge\varepsilon\}$, $N_\varepsilon(t)=|B|$, and $\kappa_B=\lambda_{\max}(X_B^\top X_B/n)$. Then:
1. **(integrated gradient norm)** $N_\varepsilon(t)\le\Big(\int_0^t\|\nabla L(w(s))\|_2\,ds\Big)^2\Big/\Theta_\varepsilon^2$;
2. **(incoherence)** $N_\varepsilon(t)\le\kappa_B\,\tau(t)^2/\Theta_\varepsilon^2$;
   - With the coherence $\mu_n=\max_{S\ne S'}|\langle\chi_S,\chi_{S'}\rangle_n|$, Gershgorin's theorem gives $\kappa_B\le1+(N_\varepsilon-1)\mu_n$. Writing $x=(\tau/\Theta_\varepsilon)^2$, whenever $\mu_nx<1$ this gives $N_\varepsilon\le\frac{(1-\mu_n)x}{1-\mu_nx}$.
   - For uniform inputs and the dictionary of all characters of degree $\le k$, $\mu_n\le\bar\mu:=\sqrt{2\ln(2D_{\min(2k,d)}/\delta')/n}$ with probability $1-\delta'$. This follows from Hoeffding's inequality over the fewer than $D_{\min(2k,d)}$ nonempty sets $S\triangle S'$.
3. **(the $\ell_1$ identity)** $\sum_S|w_S(t)|\,|G_S(t)|=\langle R(t),f_{w(t)}\rangle_n$. Consequently
$$\sum_{S\in B_\varepsilon(t)}|w_S(t)|\le\frac{\langle R(t),f_{w(t)}\rangle_n}{\Theta_\varepsilon}\le\frac{\tau(t)\,\|f_{w(t)}\|_n}{\Theta_\varepsilon}\le\frac{2\tau(t)}{\Theta_\varepsilon}.$$

*Proof.*
1. Each $S\in B$ has $|G_S(t)|\ge\Theta_\varepsilon$. So $N\Theta_\varepsilon^2\le\|G(t)\|_2^2\le(\int_0^t\|g\|_2)^2$, by Minkowski's integral inequality.
2. Let $\sigma_S=\mathrm{sgn}\,w_S=-\mathrm{sgn}\,G_S$. Then
$$N\Theta_\varepsilon\le\sum_{S\in B}|G_S|=\int_0^t\Big\langle r(s),\sum_{S\in B}\sigma_S\chi_S\Big\rangle_nds\le\tau(t)\,\Big\|\sum_{S\in B}\sigma_S\chi_S\Big\|_n=\tau(t)\sqrt{\sigma^\top K_B\sigma}\le\tau(t)\sqrt{\kappa_BN}.$$
   Rearranging gives the claim. For the Gershgorin form, substitute $\kappa_B\le1+(N-1)\mu_n$ into $N\le\kappa_Bx$ and solve. For the coherence bound, $\langle\chi_S,\chi_{S'}\rangle_n$ is the empirical mean of $\chi_{S\triangle S'}$, which has population mean $0$; apply Hoeffding and a union bound.
3. $|w_S||G_S|=w_S\cdot(-G_S)=w_S\int_0^t\langle r,\chi_S\rangle_n$, because $\mathrm{sgn}\,w_S=-\mathrm{sgn}\,G_S$. Summing over $S$ gives $\int_0^t\langle r(s),f_{w(t)}\rangle_n\,ds$. The inequalities follow from $|G_S|\ge\Theta_\varepsilon$ on $B$, Cauchy–Schwarz, and $\|f\|_n\le\|y\|_n+\|r\|_n\le2$. ∎

Item 2 is tight in the following sense. Let $y=\chi_{S^*}$ be in the dictionary. If $\langle\chi_{S^*},\chi_S\rangle_n=0$ for all $S\ne S^*$, as for an empirically orthogonal dictionary such as the full cube, every other coordinate has zero gradient, $r$ stays parallel to $\chi_{S^*}$, and $|G_{S^*}|=\tau$ exactly; so at the first crossing $N=1=\tau^2/\Theta_\varepsilon^2$. At finite $n$ with nonzero coherence ($\mu_n=0.30$ at $n=100$ in the check) every coordinate moves, $r$ is not exactly parallel, and the inequality is strict; it becomes tight as $\alpha\to0$ at fixed $\varepsilon$ (sketch: until the first crossing every other utility is at most $\mu_n+o(1)$, so the other coordinates are $O(\alpha^{2(1-\mu_n)})$, and $|G_{S^*}|/\tau\to1$). The numerical check finds $N/\text{bound}=1.00$ for par2 at $\alpha=10^{-8}$; the printed value $1.0000000016$ (`c2_diag_check.json`) exceeds 1 only by integration error. Note also that *generically* every coordinate is nonzero for $t>0$: $w_S(t)=0$ exactly when $G_S(t)=0$, as for all $S\ne S^*$ in the orthogonal case above. The bound counts coordinates that have **grown**, which is the precise sense of "the circuit cannot have grown big yet".

### Theorem C2.4 (generalization, uniform in time and threshold) — Proved

For $N\ge0$ let
$$\ell_N:=\ln\binom DN+\ln\Phi\big(2^{\min(N,d+1)},N\big),\qquad \mu_\varepsilon(t):=\sum_{S\notin B_\varepsilon(t)}|w_S(t)|\ \le\ (D-N_\varepsilon(t))\,\varepsilon .$$
With probability at least $1-\delta$ over $S$, **simultaneously for all $t\ge0$ and all $\varepsilon>0$**,
$$\mathrm{err}\big(\mathrm{sgn}f_{w(t)}\big)\ \le\ \mathrm{kl}^{-1}_+\Big(\widehat P_S\big[y f_{w(t)}(x)\le2\mu_\varepsilon(t)\big],\ \frac{\ell_{N_\varepsilon(t)}+\ln\frac{(N_\varepsilon(t)+1)(N_\varepsilon(t)+2)}{\delta}}{n}\Big).$$

*Proof.*
1. *The class.* For $N\ge0$, let $\mathcal A_N$ be the family of sets $\{(x,y):\,y\sum_{S\in B}w_S\chi_S(x)\le\theta\}$ over all $B\subseteq\mathcal S$ with $|B|=N$, all $w\in\mathbb R^B$ and all $\theta\in\mathbb R$.
   - A member of $\mathcal A_N$ is determined by $B$ and by an affine threshold function of the point $z(x,y)=(y\chi_S(x))_{S\in B}\in\{-1,1\}^N$, with $\mathrm{sgn}(0)=+1$ meaning "in the set".
   - Writing $y=(-1)^{b_0}$ and $x_i=(-1)^{b_i}$, $z$ is a GF(2)-linear image of $(b_0,b)\in\mathrm{GF}(2)^{d+1}$, so it takes at most $2^{\min(N,d+1)}$ values.
   - By Lemma C0.2, $\ln|\mathcal A_N|\le\ell_N$.
2. *Occam event.* Lemma C0.1 for each fixed member, applied to the Bernoulli variable $\mathbb 1[(x,y)\in A]$, and a union bound with weight $\delta/((N+1)(N+2))$ for $\mathcal A_N$, give one event of probability at least $1-\delta$. On it, every $A\in\mathcal A_N$, for every $N$, satisfies $P(A)\le\mathrm{kl}^{-1}_+(\widehat P_S(A),(\ell_N+\ln\frac{(N+1)(N+2)}\delta)/n)$.
3. *Decomposition.* Fix $t$ and $\varepsilon$. Write $f_{w(t)}=f_L+f_s$, where $f_L=\sum_{S\in B}w_S\chi_S$ and $\|f_s\|_\infty\le\mu:=\mu_\varepsilon(t)$.
   - On test points: if $yf_{w(t)}(x)\le0$ then $yf_L(x)\le\mu$, so $\mathrm{err}(\mathrm{sgn}f_{w(t)})\le P(yf_L\le\mu)$.
   - On training points: $yf_L\le\mu$ implies $yf_{w(t)}\le2\mu$, so $\widehat P_S(yf_L\le\mu)\le\widehat P_S(yf_{w(t)}\le2\mu)$.
4. *Conclusion.* The set $\{yf_L\le\mu\}$ belongs to $\mathcal A_{N_\varepsilon(t)}$, whatever the data-dependence of $B$, $w$ and $\mu$. Apply step 2 and the monotonicity of $\mathrm{kl}^{-1}_+$. ∎

### Corollary C2.5 (the time-indexed form) — Proved

Fix $\gamma\in(0,1]$, put $\varepsilon=\gamma/(2D)$, $\Theta_\gamma:=\Theta_\varepsilon=\frac14\operatorname{arsinh}\frac{\gamma}{4D\alpha^2}$, $x(t):=(\tau(t)/\Theta_\gamma)^2$ and $\ell^*_N=\max_{N'\le N}\ell_{N'}$. Let $\bar N(t)\le D$ be any quantity, possibly data-dependent, with $N_\varepsilon(t)\le\bar N(t)$. On the event of Theorem C2.4, for all $t$ and $\gamma$,
$$\mathrm{err}(\mathrm{sgn}f_{w(t)})\le\mathrm{kl}^{-1}_+\Big(\widehat P_S[yf_{w(t)}\le\gamma],\ \frac{\ell^*_{\bar N(t)}+\ln\frac{(\bar N+1)(\bar N+2)}\delta}{n}\Big).$$
Three admissible choices of $\bar N$, from most to least data-dependent:
1. **Measured $\kappa$.** $\bar N_\kappa(t)=\min\{D,\lfloor\kappa_B\,x(t)\rfloor\}$ with $B=B_\varepsilon(t)$. This is time-indexed, but $\kappa_B$ is the top eigenvalue of the Gram matrix of the trajectory's own grown set, so it is data-dependent.
2. **Empirical coherence.** If $\mu_nx(t)<1$: $\bar N_G(t)=\min\big\{D,\big\lfloor\frac{(1-\mu_n)x(t)}{1-\mu_nx(t)}\big\rfloor\big\}$. The data enter only through the coherence $\mu_n$ of the training inputs and through $\tau(t)$.
3. **Coherence bound.** For uniform inputs and the dictionary of all characters of degree $\le k$, let $\bar\mu=\sqrt{2\ln(2D_{\min(2k,d)}/\delta')/n}$, and let $\bar x$ be either $x(t)$ or $(t/\Theta_\gamma)^2$. If $\bar\mu\bar x<1$: $\bar N_H(t)=\min\big\{D,\big\lfloor\frac{(1-\bar\mu)\bar x}{1-\bar\mu\bar x}\big\rfloor\big\}$. The bound then holds for all $t$ and $\gamma$ with probability at least $1-\delta-\delta'$. With $\bar x=(t/\Theta_\gamma)^2$ its capacity term depends only on $(n,d,k,\alpha,\gamma,t,\delta,\delta')$. With $\bar x=x(t)$ it depends on the data only through the training-loss curve, since $\tau(t)=\int_0^t\sqrt{2L(w(s))}\,ds$.

*Proof.*
- *Main inequality.* Take $\varepsilon=\gamma/(2D)$ in Theorem C2.4. Then $2\mu_\varepsilon\le2D\varepsilon=\gamma$, so the empirical margin term is at most $\widehat P_S[yf_{w(t)}\le\gamma]$. The event of Theorem C2.4 is uniform over $N$, and $\mathrm{kl}^{-1}_+$, $\ell^*_N$ and $(N+1)(N+2)$ are nondecreasing, so the bound with $N_\varepsilon(t)$ implies the bound with any $\bar N\ge N_\varepsilon(t)$, however $\bar N$ depends on the data.
- *Choice 1* is Theorem C2.3(2).
- *Choice 2.* Write $N=N_\varepsilon(t)$; if $N=0$ there is nothing to prove. $K_B$ has unit diagonal and off-diagonal entries of absolute value at most $\mu_n$, so Gershgorin's theorem gives $\kappa_B\le1+(N-1)\mu_n$. With Theorem C2.3(2), $N\le(1+(N-1)\mu_n)x$, that is, $N(1-\mu_nx)\le(1-\mu_n)x$. Divide by $1-\mu_nx>0$; $N$ is an integer. The definition is not circular: $\mu_n$ and $x(t)$ do not depend on $N$.
- *Choice 3.* On the Hoeffding event of Theorem C2.3(2), $\mu_n\le\bar\mu$, and $x(t)\le\bar x$ because $\tau(t)\le t$. So $\mu_nx(t)\le\bar\mu\bar x<1$. Let $\Gamma(\mu,x)=\frac{(1-\mu)x}{1-\mu x}$ on $\{\mu x<1\}$. Then $\partial_x\Gamma=\frac{1-\mu}{(1-\mu x)^2}\ge0$ and $\partial_\mu\Gamma=\frac{x(x-1)}{(1-\mu x)^2}$.
  - If $x(t)<1$, then $\Gamma(\mu_n,x(t))<1$, so $N=0$ by choice 2.
  - If $x(t)\ge1$, then $\Gamma$ is nondecreasing in $\mu$ along $\{x(t)\}\times[\mu_n,\bar\mu]$, and in $x$ along $\{\bar\mu\}\times[x(t),\bar x]$, both inside $\{\mu x<1\}$. So $N\le\Gamma(\mu_n,x(t))\le\Gamma(\bar\mu,x(t))\le\Gamma(\bar\mu,\bar x)$.
  
  A union bound over the two events gives probability $1-\delta-\delta'$. ∎

**What the corollary says.** In the diagonal network:
- **Time.** "Training has not taken long" means $\tau(t)/\Theta_\gamma$ is small, with
$$\Theta_\gamma\approx\tfrac14\ln\frac{\gamma}{4D\alpha^2}=\tfrac12\ln\frac1\alpha-\tfrac14\ln\frac{4D}{\gamma}.$$
- **Size.** The number of grown coordinates is then at most $\kappa_B(\tau/\Theta_\gamma)^2$. Through coherence it is at most $\frac{(1-\mu)x}{1-\mu x}$, which is about $x=(\tau/\Theta_\gamma)^2$ when $\mu x\ll1$.
- **Generalization.** Chernoff over all margin events of that many characters controls the test error, with capacity $\ell_N\le N\ln\frac{eD}N+N\min(N,d+1)\ln2+\ln2$.

The dictionary size enters only logarithmically, in all three places. This is the user's proposed argument, made rigorous in the diagonal network: time bounds the number of grown coordinates, and the Chernoff bound holds over all small sparse-plus-small predictors. The size term is a function of time alone only in choice 3. That needs $\bar\mu\bar x<1$, that is,
$$n\ >\ 2\ln\frac{2D_{\min(2k,d)}}{\delta'}\Big(\frac{\tau}{\Theta_\gamma}\Big)^4 ,$$
so the sample size must grow like the fourth power of the effective time measured in units of $\Theta_\gamma$. Choices 1 and 2 avoid that condition at the price of a data-dependent $\kappa_B$ or $\mu_n$.

### Proposition C2.6 (discrete GD and minibatch SGD) — Proved

Let $g_0,g_1,\dots\in\mathbb R^D$ be any sequence of gradient estimates in $w$:
- **full-batch GD:** $g_j=\nabla L(w_j)=-X^\top r_j/n$;
- **SGD:** $g_j=-X_{B_j}^\top r_{j,B_j}/|B_j|$, the gradient of the loss on a minibatch $B_j$, drawn with or without replacement, from a fixed training set or fresh.

Gradient steps on $(u,v)$ with step size $\eta$ are $u_{j+1}=u_j\odot(1-2\eta g_j)$ and $v_{j+1}=v_j\odot(1+2\eta g_j)$. Assume $2\eta G<1$, where $G=\max_{j<K}\|g_j\|_\infty$, and put $c_\eta=1/(1-4\eta^2G^2)$. Then for every $K$:
1. **Product form.** $w_K=-2\,u_K\odot v_K\odot\sinh(2\psi_K)$, where $\psi_K=\sum_{j<K}\operatorname{artanh}(2\eta g_j)$, and $0<u_K\odot v_K\le\alpha^2$.
2. **Growth threshold.** $|w_{K,S}|\ge\varepsilon$ implies $|\psi_{K,S}|\ge2\Theta_\varepsilon$.
3. **No early growth.** $|\psi_{K,S}|\le2c_\eta\eta\sum_{j<K}|g_{j,S}|$, and $|g_{j,S}|\le\|r_j\|_{B_j}$, the root of twice the minibatch loss. So no coordinate reaches $\varepsilon$ while the **minibatch effective time** $\tau^{\rm b}_K=\eta\sum_{j<K}\|r_j\|_{B_j}$ is below $\Theta_\varepsilon(1-4\eta^2G^2)$.
4. **Count, any batches.** $N_\varepsilon(K)\le\big(c_\eta\,\eta\sum_{j<K}\|g_j\|_2\big)^2/\Theta_\varepsilon^2$.
5. **Count, full batch.** With $\Phi_K=\frac12\sum_{j<K}\frac{(2\eta\|g_j\|_\infty)^3}{3(1-(2\eta\|g_j\|_\infty)^2)}$, whenever $\Theta_\varepsilon>\Phi_K$,
$$N_\varepsilon(K)\le\kappa_B\,\tau_K^2/(\Theta_\varepsilon-\Phi_K)^2,\qquad \tau_K=\eta\sum_{j<K}\|r_j\|_n .$$
6. **Generalization.** Theorem C2.4 holds verbatim for the iterates of *any* algorithm, because it is a statement about all sparse-plus-small predictors. With items 4–5 in place of Theorem C2.3, Corollary C2.5 holds for GD and SGD. For full-batch GD, item 5 replaces $x(t)$ by $x_K=\tau_K^2/(\Theta_\gamma-\Phi_K)^2$ in all three choices of $\bar N$, with $\bar x=x_K$ in choice 3 (discrete GD need not keep $\|r_j\|_n\le1$, so $\tau_K\le\eta K$ is not claimed). For SGD, $\bar N$ is the item-4 count.

*Proof.*
1. *Product form.* By induction, $u_K=\alpha\prod_j(1-2\eta g_j)$ and $v_K=\alpha\prod_j(1+2\eta g_j)$, both positive. Then $u_Kv_K=\alpha^2\prod_j(1-4\eta^2g_j^2)\in(0,\alpha^2]$ and $\frac12\ln(v_K/u_K)=\psi_K$. Finally $u^2-v^2=uv(u/v-v/u)=-2uv\sinh(2\psi)$.
2. *Threshold.* By item 1, $|w|\le2\alpha^2\sinh(2|\psi|)$. So $|w|\ge\varepsilon$ gives $|\psi|\ge\frac12\operatorname{arsinh}\frac\varepsilon{2\alpha^2}=2\Theta_\varepsilon$.
3. *No early growth.* For $0\le z<1$, $\operatorname{artanh}z=\sum_{m\ge0}z^{2m+1}/(2m+1)\le z/(1-z^2)$. Also $|g_{j,S}|=|\langle r_j,\chi_S\rangle_{B_j}|\le\|r_j\|_{B_j}$.
4. *Count, any batches.* By item 2, $4N\Theta_\varepsilon^2\le\|\psi_K\|_2^2$. Coordinatewise, $|\operatorname{artanh}(2\eta g)|\le2c_\eta\eta|g|$, so $\|\psi_K\|_2\le2c_\eta\eta\sum_j\|g_j\|_2$.
5. *Count, full batch.* Write $\operatorname{artanh}z=z+\varphi(z)$ with $|\varphi(z)|\le|z|^3/(3(1-z^2))$. Let $\sigma_S=\mathrm{sgn}\,\psi_{K,S}$. Then
$$2N\Theta_\varepsilon\le\sum_{S\in B}\sigma_S\psi_{K,S}\le-2\eta\sum_j\Big\langle r_j,\sum_{S\in B}\sigma_S\chi_S\Big\rangle_n+2N\Phi_K\le2\tau_K\sqrt{\kappa_BN}+2N\Phi_K,$$
   as in Theorem C2.3(2). Rearrange.
6. *Generalization.* Theorem C2.4's proof uses only the decomposition of the current predictor. ∎

So the user's two protocols, full batch on a fixed training set and SGD, are covered in the diagonal model, but not with the same structure.
- **No early growth** (item 3) is in terms of the **minibatch effective time** $\tau^{\rm b}$, computed from the minibatch losses, which are logged during training anyway.
- **The SGD size bound** (item 4) is not in terms of losses. It uses the integrated minibatch gradient norms $\eta\sum_j\|g_j\|_2$ over all $D$ coordinates. Since $\|g_j\|_2^2=\sum_S\langle r_j,\chi_S\rangle_{B_j}^2\le D\|r_j\|_{B_j}^2$, these can exceed $\eta\sum_j\|r_j\|_{B_j}$ by a factor up to $\sqrt D$. So under SGD the count is not of the $\kappa\tau^2$ form, and it is loose.
- **The full-batch size bound** (item 5) has the $\kappa\tau^2$ form, and the discretization costs only the factors $1-4\eta^2G^2$ and $\Phi_K=O(\eta^2G^2\tau_K)$.

**Numerical** ([`checks/c2_discrete_check.txt`](checks/c2_discrete_check.txt)): GD with $\eta=0.05$–$0.1$ and SGD with batch 16–32 and $\eta=0.02$, on maj3, and3 and par2.
- The product form holds to $10^{-13}$, and $uv/\alpha^2$ never exceeds 1.
- Item 3 holds at every escape. For par2 under SGD it is nearly tight: $\tau^{\rm b}=1.78$ against the bound $1.72$.
- The worst ratios $N/\text{bound}$ for item 4 are $0.27$–$0.55$ under GD but only $0.07$–$0.12$ under SGD. For item 5 (GD) they are $0.62$–$0.80$.

### 2.2 Numerical check

[`checks/c2_diag_check.py`](checks/c2_diag_check.py) produces [`checks/c2_diag_check.txt`](checks/c2_diag_check.txt).
- **Instance.** $d=10$ and $k=3$, so $D=176$. $n=100$ or $400$, so the model is overparametrized at $n=100$. Test errors are exact, over all $2^{10}$ inputs.
- **Integration.** Runs with $\alpha=10^{-3}$ integrate $(u,v)$ with DOP853 at rtol $10^{-10}$. Runs with $\alpha=10^{-8}$ integrate the mirror form in $G$.
- **Targets.** par2 $=x_1x_2$; maj3, and3, maj5 and par4 on the first coordinates. Degree 5 and 4 are not in the dictionary.

| check | result |
|---|---|
| closed form $w=-2\alpha^2\sinh(4G)$, $u\odot v=\alpha^2$ | max relative error $4\cdot10^{-9}$–$1.1\cdot10^{-8}$ (integration tolerance) |
| Theorem C2.2(1): $\tau(t_\varepsilon)\ge\Theta_\varepsilon$ | holds in all 40 cases; equality to 4 digits for par2 |
| Theorem C2.2(2): first-escape bracket | holds in all 40 cases; at $\varepsilon=10^{-4}$ the bracket is $\pm0.5\%$ wide |
| Theorem C2.3(1), (2) | hold at every time and every $\varepsilon$ on a grid; worst ratio $N/(\kappa_B\tau^2/\Theta^2)$ is $0.33$–$0.94$, and $1.00$ for par2 at $\alpha=10^{-8}$ |
| Theorem C2.3(3), $\ell_1$ identity | relative error $\le2\cdot10^{-15}$ |

The generalization bounds at the end of training ($t=60$). The C2.4 column takes the best $\varepsilon$ on a grid, which is legitimate because the theorem is uniform in $\varepsilon$. The three C2.5 columns are the three choices of $\bar N$, at $\gamma=\frac12$ and $t=60$, with $\bar x=x(t)$ in choice 3. Choice 3 uses $\bar\mu=0.457$ ($n=100$) or $0.228$ ($n=400$) at $\delta'=0.05$, so its total failure probability is $0.1$ ([`checks/C_r2_checks.out`](checks/C_r2_checks.out) §2).

| target | $n$ | $\alpha$ | test error | grown coords $N_{10^{-2}}$ | C2.4 bound | C2.5(1), measured $\kappa_B$ | C2.5(2), empirical $\mu_n$ | C2.5(3), Hoeffding $\bar\mu$ |
|---|---|---|---|---|---|---|---|---|
| par2 | 100 | $10^{-3}$ | 0 | 1 | 0.107 | 0.218 | vacuous | vacuous |
| maj3 | 100 | $10^{-3}$ | 0 | 4 | 0.275 | 0.810 | vacuous | vacuous |
| maj3 | 400 | $10^{-3}$ | 0 | 4 | 0.077 | 0.316 | vacuous | vacuous |
| and3 | 400 | $10^{-3}$ | 0 | 8 | 0.166 | 0.477 | vacuous | vacuous |
| maj5 | 100 | $10^{-3}$ | 0.073 | 48 | 0.951 | 0.998 | vacuous | vacuous |
| par4 | 100 | $10^{-3}$ | 0.516 | 73 | 0.988 | 1.0 | vacuous | vacuous |
| par2 | 100 | $10^{-8}$ | 0 | 1 | 0.107 | 0.107 | 0.107 | 0.163 |
| maj3 | 400 | $10^{-8}$ | 0 | 4 | 0.077 | 0.141 | vacuous | vacuous |
| and3 | 400 | $10^{-8}$ | 0 | 8 | 0.166 | 0.304 | vacuous | vacuous |

Reading:
- **C2.4.** The a posteriori bound is non-vacuous whenever the target is sparse in the dictionary, already at $n=100$. maj5 is not in the dictionary: the flow keeps growing coordinates, 48 of them by $t=60$, and the bound degrades to vacuous while the true error stays at 0.07. On maj5 the best value along the trajectory is 0.39, at $t=30$ with $\alpha=10^{-8}$.
- **C2.5(1).** The time-indexed bound with the measured, data-dependent $\kappa_B$ is non-vacuous for the sparse targets at $n=400$, and for par2 at $n=100$: $0.11$–$0.48$. It is $0.81$ for maj3 at $n=100$. It improves as $\alpha\to0$, because $\Theta_\gamma$ grows like $\frac12\ln\frac1\alpha$ while the $\ln(4D/\gamma)$ penalty stays fixed.
- **C2.5(2)–(3).** The forms without $\kappa_B$ need $\mu(\tau/\Theta_\gamma)^2<1$. With the empirical $\mu_n=0.16$–$0.30$ this fails at these sizes except for par2 at $\alpha=10^{-8}$, where $(\tau/\Theta_\gamma)^2=1.48$. With the Hoeffding $\bar\mu$, which makes the size term a function of $(n,D,\tau)$ alone, par2 at $\alpha=10^{-8}$ gives $0.163$. With raw time $t$ in place of $\tau$ it gives $0.275$ at $t=10$, the best of the printed times (legitimate, since the bound is uniform in $t$), and it is vacuous at $t=60$. Everything else is vacuous. In this toy, then, the time-only form of the user's argument works only for a single-character target at tiny $\alpha$, evaluated soon after the escape; the form with measured $\kappa_B$ works for every sparse target.
- **par4** is a degree-4 parity with zero correlation with every dictionary element. Nothing grows until $t\approx\Theta/0.3$, the noise level; after that only noise coordinates grow. The bound correctly certifies nothing. This is A's Proposition A2.6 in the actual flow.

---

## 3. C3: two-layer and deeper ReLU networks from small initialization

### 3.1 What is known

All entries are **Literature**. Abstracts and venues were checked by search; theorem-level details are from memory unless stated.

| work | setting | what is proved |
|---|---|---|
| Maennel, Bousquet, Gelly, *Gradient descent quantizes ReLU network features*, arXiv:1803.08367 (2018) | one hidden layer, small init and step size | early in training, weight vectors concentrate on finitely many directions determined by the data, independently of width (abstract checked) |
| Boursier, Pillaud-Vivien, Flammarion, NeurIPS 2022 | one hidden ReLU layer, square loss, orthogonal inputs, small init | early alignment phase, then saddle-to-saddle dynamics; convergence to zero loss and to the minimum-variation-norm interpolator (abstract checked) |
| Boursier, Flammarion, *Early alignment in two-layer networks training is a two-edged sword*, JMLR 26 (2025) | one hidden ReLU layer, small init | quantitative early alignment: neurons align with a few key directions while the weights are still small, giving a sparse representation. The "two-edged" part is from memory: an example where this alignment leads GF to a spurious stationary point |
| Min, Mallada, Vidal, ICLR 2024 | one hidden ReLU layer, binary classification, well-separated data | alignment within time $O(\log n/\sqrt\mu)$, then $O(1/t)$ loss decay, with low-rank first-layer weights (abstract checked) |
| Kumar, Haupt, TMLR 2024 (2-homogeneous) and TMLR 2025 (homogeneity $>2$, deep) | small init, square and logistic loss | weights stay small for a long time and converge in direction to KKT points of the *neural correlation function* $\langle y,f_\theta\rangle_n$ on the sphere; a similar statement near certain saddles (abstract checked) |
| Kumar, Haupt, *Learning neural networks by neuron pursuit*, arXiv:2509.12154 (2025) | greedy algorithm inspired by saddle-to-saddle | an algorithm, not a convergence theorem for GD (from memory) |
| Kunin, Marchetti, Chen, Karkada, Simon, DeWeese, Ganguli, Miolane, *Alternating Gradient Flows*, NeurIPS 2025 | two-layer networks, vanishing init | AGF alternates utility maximization over dormant neurons with cost minimization over active ones. Proved: AGF is the $\alpha\to0$ limit of GF for diagonal linear networks; complete characterization for quadratic networks on modular addition. For general two-layer ReLU nets it is a model with matching experiments (abstract checked; the $\propto\log(1/\alpha)$ activation thresholds are from memory) |
| Bantzis, Simon, Jacot, ICLR 2026 | deep ReLU, small init | the optimal *first* escape direction from the origin is low-rank in deep layers: the top singular value of layer $\ell$ exceeds the others by a factor of at least $\ell^{1/4}$. A sequence of saddles of increasing bottleneck rank is conjectured (abstract checked) |
| Pesme, Flammarion, NeurIPS 2023; Berthier, JMLR 2023 | diagonal linear networks | the full saddle-to-saddle limit, LARS-like recursion (from memory) |
| Lyu, Li, Wang, Arora, NeurIPS 2021 | two-layer leaky ReLU, small init, linearly separable symmetric data | GF first learns a linear classifier, then maximizes margin (from memory) |
| Du, Hu, Lee, NeurIPS 2018 | homogeneous ReLU nets | $\frac d{dt}(\lVert W_{l+1}\rVert_F^2-\lVert W_l\rVert_F^2)=0$: layers stay balanced (from memory; re-proved in Lemma C3.2) |
| Abbe, Boix-Adserà, Misiakiewicz, COLT 2023; Barak, Edelman, Goel, Kakade, Malach, Zhang, NeurIPS 2022 | SGD on sparse targets | leap complexity governs the time; $k$-sparse parity takes $n^{O(k)}$ iterations, near the SQ limit (abstracts checked) |

**What is not known**, as far as I could find:
- a non-asymptotic theorem that a two-layer ReLU network on general data tracks AGF, or any greedy process, beyond the first escape;
- any such statement for depth $\ge3$ beyond the first escape;
- any of this at μP initialization with finite width, which is the experiment's setting. There, $W_1$ and $W_2$ start at $O(1)$ scale, and only the readout is small.

So the deep part of the README's model is conjectural, as the README says. What can be proved for small-initialization gradient descent on these architectures (one hidden layer, Lemma C3.1; bias-free homogeneous networks, Lemma C3.2) is one-sided: *upper bounds on growth*. The study's networks are outside both lemmas. They have two hidden layers with a hidden bias $b_2$, so they are neither one-hidden-layer nor homogeneous; they start at μP scale, not small scale; and they are trained by Adam with per-layer multipliers, not by gradient descent.

### Lemma C3.1 (two-layer per-neuron growth bound) — Proved

Let $f(x)=\sum_{j=1}^Ma_j\sigma(w_j\cdot\tilde x)$ with $\sigma=\mathrm{ReLU}$ and $\tilde x=(x,1)$. Let $\lambda_X=\lambda_{\max}(\frac1n\sum_i\tilde x_i\tilde x_i^\top)$; it equals $1$ in the population for uniform cube inputs. Put
$$\rho_j=a_j^2+\|w_j\|^2,\qquad \bar U(t)=\sqrt{\lambda_X}\,\|r(t)\|_n .$$
1. **Gradient flow.** Let $(a_j,w_j)$ be absolutely continuous, with $\dot a_j=\langle r,\sigma(w_j\cdot\tilde x)\rangle_n$ and $\dot w_j=a_j\langle r,s_j\tilde x\rangle_n$ a.e., where $s_j(x_i)\in\partial\sigma(w_j\cdot\tilde x_i)$ is any Clarke selection. Then $a_j^2-\|w_j\|^2$ is constant, and
$$\rho_j(t)\le\rho_j(0)\exp\Big(2\int_0^t U^*_j(s)\,ds\Big)\le\rho_j(0)\,e^{2\sqrt{\lambda_X}\tau(t)},\qquad U_j^*=\big|\langle r,\sigma(\hat w_j\cdot\tilde x)\rangle_n\big|,\ \ \hat w_j=w_j/\|w_j\|.$$
2. **Gradient descent** with step $\eta$, using the same increments: $\rho_j^{k+1}\le\rho_j^k(1+\eta\bar U_k)^2$. Hence $\rho_j^K\le\rho_j^0\exp(2\sqrt{\lambda_X}\tau_K)$, with $\tau_K=\eta\sum_{k<K}\|r_k\|_n$.
3. **Consequences.** For any set $J$ of neurons, chosen in any way,
$$\sup_x\Big|\sum_{j\in J}a_j\sigma(w_j\cdot\tilde x)\Big|\le\frac{\sqrt{d+1}}2\sum_{j\in J}\rho_j\qquad\text{and}\qquad\Big\|\sum_{j\in J}a_j\sigma(w_j\cdot\tilde x)\Big\|_n\le\frac{\sqrt{\lambda_X}}2\sum_{j\in J}\rho_j .$$
   In particular, the training loss cannot fall below $\frac12(\|y\|_n-\varepsilon)^2$ while
$$\tau(t)<\frac1{2\sqrt{\lambda_X}}\ln\frac{2\varepsilon}{\sqrt{\lambda_X}\sum_j\rho_j(0)} .$$

*Proof.*
1. *Identities.* The flow gives $\frac d{dt}a_j^2=2a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n$. Also $\frac d{dt}\|w_j\|^2=2a_j\langle r,s_j\,(w_j\cdot\tilde x)\rangle_n=2a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n$, since $s\,z=\sigma(z)$ for every $s\in\partial\sigma(z)$. So the difference is conserved, and $\dot\rho_j=4a_j\|w_j\|\langle r,\sigma(\hat w_j\cdot\tilde x)\rangle_n\le4|a_j|\|w_j\|U_j^*\le2\rho_jU_j^*$. Gronwall gives the first inequality.
2. *Utility bound.* $U_j^*\le\|r\|_n\|\sigma(\hat w_j\cdot\tilde x)\|_n\le\|r\|_n\|\hat w_j\cdot\tilde x\|_n\le\|r\|_n\sqrt{\lambda_X}$.
3. *Discrete time.* Put $A=\langle r,\sigma(w\cdot\tilde x)\rangle_n$ and $V=\langle r,s\tilde x\rangle_n$, so $w\cdot V=A$. Then
$$\rho'=\rho+4\eta aA+\eta^2(A^2+a^2\|V\|^2).$$
   Here $|A|\le\|w\|\bar U$ and $\|V\|\le\bar U$; the latter because $\|V\|=\sup_{\|u\|=1}\langle r,s\,u\cdot\tilde x\rangle_n\le\|r\|_n\sqrt{\lambda_X}$. Using $|a|\|w\|\le\rho/2$, this gives $\rho'\le\rho(1+2\eta\bar U+\eta^2\bar U^2)$.
4. *Consequences.* $|a_j\sigma(w_j\cdot\tilde x)|\le|a_j|\|w_j\|\|\tilde x\|\le\frac{\rho_j}2\sqrt{d+1}$, and similarly in $\|\cdot\|_n$ with $\sqrt{\lambda_X}$. For the loss, $\sqrt{2L}=\|y-f\|_n\ge\|y\|_n-\|f\|_n$. ∎

**Remarks.**
- *Interpretation.* Item 1 is the rigorous one-sided form of "no unit grows before about $\log(1/\alpha)/U_{\max}$": with $\rho_j(0)\approx2\alpha^2$, unit $j$ needs $\int_0^tU_j^*\ge\ln(1/\alpha)+O(1)$ before it is $O(1)$. It is an upper bound on growth. That the utility-maximizing direction is actually found, which is the alignment phase, is the content of the literature above.
- *Per-layer multipliers.* With per-layer learning-rate multipliers $m_a$ and $m_w$, the same computation with $\rho=a^2/m_a+\|w\|^2/m_w$ gives $\rho'\le\rho(1+\eta\sqrt{m_am_w}\bar U)^2$.
- **Numerical** ([`checks/c3_gronwall_check.txt`](checks/c3_gronwall_check.txt)). Setup: $d=10$, $n=200$, width 64, $\eta=0.02$, balanced and unbalanced initializations.
  - The per-step ratio $\rho'/(\rho(1+\eta\bar U)^2)$ never exceeds $1.0000$.
  - The growth exponent $\ln(\rho_j/\rho_j(0))/(2\sqrt{\lambda_X}\tau)$ reaches at most $0.30$–$0.56$ of the bound.
  - At $\alpha=10^{-4}$ the escape (a 1% loss drop) occurs at $t=8.3$–$8.7$ for maj3 and $15.5$–$16.2$ for par2, against the proved lower bound $3.7$.

### Lemma C3.2 (deep homogeneous networks: fresh chains cost $\alpha^{-(L-2)}$) — Proved

Let $f(x)=W_L\sigma(W_{L-1}\cdots\sigma(W_1\tilde x))$ be bias-free, with the constant input coordinate, and $L\ge2$. Let $\theta(t)$ be absolutely continuous with $\dot W_l=-\widetilde\nabla_{W_l}L$ a.e., where $\widetilde\nabla$ is backpropagation with any selection $s\in\partial\sigma$. Then:
1. $\frac d{dt}\|W_l\|_F^2=2\langle r,f\rangle_n$ for every $l$. So all layers grow by the same $\Delta(t)$, the balancedness of Du–Hu–Lee.
2. $\|f\|_n\le\sqrt{\lambda_X}\prod_l\|W_l\|_F\le\sqrt{\lambda_X}\,Q^{L/2}$, where $Q(t)=\max_l\|W_l(0)\|_F^2+\Delta(t)$.
3. For $L\ge3$,
$$Q(t)^{1-L/2}\ \ge\ Q(0)^{1-L/2}-(L-2)\sqrt{\lambda_X}\,\tau(t).$$
   Hence $\|f_t\|_n<\varepsilon$, so the training loss is still at least $\frac12(\|y\|_n-\varepsilon)^2$, as long as
$$\tau(t)<\frac{Q(0)^{-(L-2)/2}-(\varepsilon/\sqrt{\lambda_X})^{-(L-2)/L}}{(L-2)\sqrt{\lambda_X}} .$$
   With layers of Frobenius norm $\asymp\alpha$, this time is $\asymp\alpha^{-(L-2)}$. For $L=2$: $Q(t)\le Q(0)e^{2\sqrt{\lambda_X}\tau(t)}$.

*Proof.*
1. *Euler identity.* For each input, with backpropagated vectors $b_L=1$ and $b_l=s_l\odot(W_{l+1}^\top b_{l+1})$, and pre-activations $z_l=W_lh_{l-1}$:
$$\langle W_l,\partial f/\partial W_l\rangle=b_l^\top z_l=b_{l+1}^\top W_{l+1}(s_l\odot z_l)=b_{l+1}^\top W_{l+1}\sigma(z_l)=b_{l+1}^\top z_{l+1}=\dots=f .$$
   So $\frac d{dt}\|W_l\|_F^2=2\langle W_l,\dot W_l\rangle=2\langle r,f\rangle_n$.
2. *Output bound.* $\|h_1\|_n^2=\frac1n\sum_i\|\sigma(W_1\tilde x_i)\|^2\le\mathrm{tr}(W_1\hat\Sigma W_1^\top)\le\lambda_X\|W_1\|_F^2$. Each later layer multiplies $\|h\|_n$ by at most $\|W_l\|_{\rm op}\le\|W_l\|_F$. Finally $\prod_l\|W_l\|_F\le(\max_l\|W_l\|_F^2)^{L/2}=Q^{L/2}$, by item 1.
3. *Comparison.* $\dot Q=2\langle r,f\rangle_n\le2\|r\|_n\sqrt{\lambda_X}Q^{L/2}$. So $\frac d{dt}Q^{1-L/2}=(1-\frac L2)Q^{-L/2}\dot Q\ge-(L-2)\sqrt{\lambda_X}\|r\|_n$. Integrate. The escape-time bound solves $\sqrt{\lambda_X}Q^{L/2}=\varepsilon$. ∎

This is the rigorous lower half of the README's fresh-chain law $T\approx\alpha^{-(L-2)}/U$. It applies to the very first move, where every layer is fresh.

**Numerical** (same file). Setup: $d=10$, $n=256$, width 32, GD with $\eta=0.02$, maj3, escape defined as $\|f\|_n\ge0.1$.
- **$L=3$.** At $\alpha=0.03,0.01,0.003$, the observed escape effective times are $\tau=65,200,673$, against the proved lower bounds $3.0,13.0,47.8$. The bound has the right $\alpha^{-1}$ scaling and is loose by a factor of 14–21.
- **$L=4$.** At $\alpha=0.2$ and $0.1$ the bound is vacuous. $\prod\|W_l\|_F$ overestimates a random network's output by about $10^4$ there: $\|f(0)\|_n=1.4\cdot10^{-5}$ against a bound of $0.13$.
- The comparison inequality itself held at every step.

### 3.2 The race size bound, restated

The conditional theorem uses A's (LS) clock race (A, Definition 2.1), recalled here:
- **Fired gates and refit.** Gates from a *finite* library $G$ of functions $[-1,1]^k\to[-1,1]$, of fan-in at most $k$, fire when their clock $|S_m(t)|=|\int_{a_m}^t\langle r,g_m\rangle_n|$ reaches $\Theta$. The readout is refit by least squares with an intercept.
- **Boolean and real-valued gates.** The library is *Boolean* if every $g\in G$ maps $\{-1,1\}^k$ into $\{-1,1\}$, so that every gate of every circuit is $\pm1$-valued on the cube. A's toy library $\{\mathrm{id},\mathrm{AND}(\pm a,\pm b),\mathrm{XOR}\}$, used in §3.4, is Boolean. A library of ReLU neurons with a finite set of (for example quantized) weights is real-valued.
- **Notation.** $\tau(t)=\int_0^t\|r\|_n$, and $K_B$ is the centred empirical Gram matrix of a set $B$ of fired gates, with $\kappa_B=\lambda_{\max}(K_B)$. Since $\|r\|_n\le1$ (A, Lemma 2.2(1)), $\tau(t)\le t$.
- **Units of $\Theta$.** $\Theta$ is the race's threshold. For a model started at scale $\alpha$ it is $c\ln(1/\alpha)+O(1)$, with a constant $c$ that depends on the parametrization. In C2's diagonal network $c=\frac12$, since $\Theta_\varepsilon\approx\frac14\ln(\varepsilon/\alpha^2)$; the factor $\frac12$ comes from $u$ appearing twice in $u\odot u$. For a two-layer ReLU unit with $\rho(0)\approx2\alpha^2$, Lemma C3.1 needs $\int U^*\ge\ln(1/\alpha)-\frac12\ln2$ before $\rho=O(1)$, so $c=1$. Statements below are in units of $\Theta$ and do not depend on $c$.

### Lemma C3.3 (A's Theorem A2.3) — Proved

At every time, every set $B$ of fired gates satisfies $|B|\le\kappa_B(\tau(t)/\Theta)^2$.

*Proof.*
1. *Clocks stop at $\Theta$.* After gate $m$ fires, the least-squares normal equations give $\langle r,g_m\rangle_n=0$, so its clock stays at $\sigma_m\Theta$.
2. *Centring.* The intercept is refit, so $r$ has mean zero and $\langle r,g_m\rangle_n=\langle r,\tilde g_m\rangle_n$, with $\tilde g_m$ centred.
3. *Chain.* With $B(s)=\{m\in B:a_m\le s\}$,
$$|B|\Theta=\int_0^t\Big\langle r,\sum_{m\in B(s)}\sigma_m\tilde g_m\Big\rangle_nds\le\tau(t)\sqrt{\kappa_B|B|},$$
   because a principal submatrix has no larger top eigenvalue. ∎

### 3.3 The conditional theorem

Let $\theta(t)$ be the network's training trajectory on $S$, and $\mathcal T$ a finite set of checkpoints. Let $M$ be the (LS) race run **on the same $S$**, with library $G$ and threshold $\Theta$; it is cheap to compute. Write:
- $h^M_s=\mathrm{sgn}\,f^M_s$ for its predictor at race time $s$, where $f^M_s=c_0+\sum_mc_mg_m$;
- $T^M(s)$ for its number of gates and $\tau^M(s)$ for its effective time;
- $s:\mathcal T\to[0,\infty)$ for a **clock calibration**, for example $s(t)=t$ with $\Theta$ fitted to the first escape, as in A §2.3.

**Hypothesis SSA (saddle-to-saddle approximation)**, at checkpoint $t$ with tolerance $\eta(t)$:
- **sign form:** $\mathrm{dis}\big(\mathrm{sgn}f_{\theta(t)},\,h^M_{s(t)}\big)\le\eta(t)$;
- **$L^2$ form:** $\big\|\mathrm{clip}f_{\theta(t)}-\mathrm{clip}f^M_{s(t)}\big\|_{L^2(P_X)}\le\eta(t)$, where $\mathrm{clip}$ is clipping to $[-1,1]$.

The $L^2$ form is what dynamical approximation theorems naturally deliver: the α→0 limits of Pesme–Flammarion and Kunin et al. are statements about trajectories, hence about functions. It also tolerates the small random part of the network's function. The sign form does not, because the sign of a tiny random function is arbitrary.

**Library constants.** Let $W_T=\sum_{t\le T}(\ln|G|+k\ln(d+t-1))$ be the circuit-wiring count (A, Lemma 1.1: gate $t$ has at most $|G|(d+t-1)^k$ choices). Put
$$L^{\rm sgn}_T=W_T+\ln\Phi(2^{\min(T,d)},T),\qquad L^{\rm mar}_T=W_T+\ln\Phi(2^{\min(T+1,d+1)},T+1)\qquad\text{(Boolean library)},$$
$$L^{\rm sgn}_T=W_T+\ln\Phi(2^{d},T),\qquad L^{\rm mar}_T=W_T+\ln\Phi(2^{d+1},T+1)\qquad\text{(real-valued library)}.$$
The difference is the number of points on which the readout acts. For a Boolean library the gate vector $(g_1(x),\dots,g_T(x))$ lies in $\{-1,1\}^T$, so it takes at most $2^{\min(T,d)}$ values. For real-valued gates it can take all $2^d$ values. This is the distinction of A, Lemma 1.2 ($\rho_T=\ln\Phi(2^d,T)$ for real-valued gates).

### Theorem C3.4 (the network inherits the race bound) — Proved (conditional on SSA at the checkpoints where it is invoked)

Let the library $G$ be finite, Boolean or real-valued, with the matching constants $L^{\rm sgn}_T$ and $L^{\rm mar}_T$ above. There is an event of probability at least $1-\delta$ over $S$, not depending on the network, on which the following holds for every checkpoint $t\in\mathcal T$. Write $s=s(t)$ and $T=T^M(s)$, and recall that $T\le\kappa^M(s)(\tau^M(s)/\Theta)^2$ by Lemma C3.3.
1. If SSA holds at $t$ in sign form,
$$\mathrm{err}\big(\mathrm{sgn}f_{\theta(t)}\big)\le\eta(t)+\mathrm{kl}^{-1}_+\Big(\widehat{\mathrm{err}}_S(h^M_s),\ \frac{L^{\rm sgn}_T+\ln\frac{2(T+1)(T+2)}\delta}n\Big).$$
2. If SSA holds at $t$ in $L^2$ form, then for every $\gamma\in(0,1)$,
$$\mathrm{err}\big(\mathrm{sgn}f_{\theta(t)}\big)\le\frac{\eta(t)^2}{\gamma^2}+\mathrm{kl}^{-1}_+\Big(\widehat P_S\big[yf^M_s(x)\le\gamma\big],\ \frac{L^{\rm mar}_T+\ln\frac{2(T+1)(T+2)}\delta}n\Big).$$

In words: under SSA, the network at time $t$ has the discrete model's Occam bound at race time $s(t)$, plus $\eta$ or $\eta^2/\gamma^2$. With a clock calibration of slope at most $c_s$, that is $s(t)\le c_st$, and with $\tau^M(s)\le s$, the gate count is at most $\kappa^M(s(t))\,(c_st/\Theta)^2$. Here $\kappa^M$ is the top eigenvalue of the centred Gram matrix, on $S$, of the race's own fired gates, so it is data-dependent, as in Corollary C2.5(1). The bound is therefore time-indexed with a data-dependent $\kappa$, not a function of training time alone; a time-only version would need a coherence bound for the library on $S$, as in Corollary C2.5(3). Time is in units of the race threshold $\Theta$ (§3.2).

*Proof.*
1. *Occam events.* Let $E$ be the intersection of two events, each of probability at least $1-\delta/2$, built as in Theorem C1 step 1 with weights $\frac{\delta/2}{(T+1)(T+2)}$:
   - the Occam event for all threshold-readout circuit predictors with $T$ gates, for all $T$: $\ln|\mathcal H_T|\le L^{\rm sgn}_T$, by counting circuits ($e^{W_T}$ of them) and then Lemma C0.2 on the image of $x\mapsto(g_1(x),\dots,g_T(x))$. That image has at most $2^d$ points, since $x$ ranges over the cube, and for a Boolean library it lies in $\{-1,1\}^T$, so it has at most $2^{\min(T,d)}$ points;
   - the Occam event for all margin sets $\{(x,y):y(c_0+\sum_mc_mg_m(x))\le\theta\}$, an affine threshold of the feature vector $(y,yg_1(x),\dots,yg_T(x))\in\mathbb R^{T+1}$. It is a function of $(x,y)$, so it takes at most $2^{d+1}$ values, and for a Boolean library it lies in $\{-1,1\}^{T+1}$, so it takes at most $2^{\min(T+1,d+1)}$ values. Lemma C0.2 applies in $\mathbb R^{T+1}$.
   
   $E$ is defined before any training and holds for every circuit of every size.
2. *Sign form.* $h^M_s$ is one such predictor with $T$ gates, so $\mathrm{err}(h^M_s)$ is bounded on $E$. Then use $\mathrm{err}(\mathrm{sgn}f_\theta)\le\mathrm{err}(h^M_s)+\mathrm{dis}$.
3. *$L^2$ form.* Since $\gamma<1$, $yf\le\gamma\iff y\,\mathrm{clip}f\le\gamma$. If $yf_\theta\le0$ then $y\,\mathrm{clip}f^M\le|\mathrm{clip}f^M-\mathrm{clip}f_\theta|$. So
$$P(yf_\theta\le0)\le P(yf^M\le\gamma)+P(|\mathrm{clip}f^M-\mathrm{clip}f_\theta|>\gamma)\le P(yf^M\le\gamma)+\eta^2/\gamma^2,$$
   by Chebyshev. The set $\{yf^M_s\le\gamma\}$ is a margin set with $T$ gates, bounded on $E$. Both statements hold on $E$ for every $t$ and $\gamma$ simultaneously. ∎

**What the theorem does and does not do.** All the dynamics are in the hypothesis; the theorem converts it. Its value is that it states exactly what the discrete model must deliver for the user's argument to apply to the network: closeness, in sign or $L^2$, to the *race's own* predictor at a calibrated time. The race's size is then controlled by time through Lemma C3.3, and its generalization by Chernoff.

### Corollary C3.5 (testing SSA with unlabelled inputs, and the unconditional certificate) — Proved

Let $U$ be $m$ unlabelled inputs, independent of $(S,\xi)$. Let the calibration $s(t)$ be chosen from a finite grid $\Sigma$, possibly using $U$.
1. With probability at least $1-\delta_2$, for all $t\in\mathcal T$ and $s\in\Sigma$,
$$\mathrm{dis}(\mathrm{sgn}f_{\theta(t)},h^M_s)\le\mathrm{kl}^{-1}_+\Big(\widehat{\mathrm{dis}}_U,\ \tfrac{\ln(2|\mathcal T||\Sigma|/\delta_2)}m\Big),$$
$$\|\mathrm{clip}f_{\theta(t)}-\mathrm{clip}f^M_s\|^2\le\widehat{\|\cdot\|^2_U}+4\sqrt{\tfrac{\ln(2|\mathcal T||\Sigma|/\delta_2)}{2m}}.$$
   So the sign form of SSA can be *verified* at every checkpoint, with $\eta(t)$ given by these upper confidence bounds, and the theorem then holds on the intersection of the two events.
2. More directly: since $h^M_s$ is a circuit predictor with $T^M(s)$ gates, Theorem C1 with the classes $\mathcal H_T$ gives, with probability $1-\delta_1-\delta_2$,
$$\mathrm{err}(\mathrm{sgn}f_{\theta(t)})\le\mathrm{kl}^{-1}_+\big(\widehat{\mathrm{err}}_S(h^M_{s}),\cdot\big)+\mathrm{kl}^{-1}_+\big(\widehat{\mathrm{dis}}_U(\mathrm{sgn}f_{\theta(t)},h^M_s),\cdot\big),$$
   with no hypothesis at all.

*Proof.*
1. The race's predictors depend only on $S$. Conditionally on $(S,\xi)$, there are $|\mathcal T||\Sigma|$ fixed pairs. Apply Lemma C0.1 to the disagreement indicators, and Hoeffding to the squared differences, which lie in $[0,4]$, each at level $\delta_2/(2|\mathcal T||\Sigma|)$; a union bound over the $2|\mathcal T||\Sigma|$ events gives $\delta_2$.
2. This is Theorem C1, variant (b), with the candidate list $\{h^M_s:s\in\Sigma\}$. ∎

So **the hypothesis is not needed for the a posteriori bound**, which C1 delivers whenever the check passes. The hypothesis is needed only for the *predictive*, time-indexed statement: from $S$ and $t$ alone, before or during training, that the network at time $t$ is within $\eta$ of a circuit of size at most $\kappa^M(c_st/\Theta)^2$, with $\kappa^M$ computable from the race on $S$. Testing SSA on a sweep, and finding that it holds with small $\eta$ across targets, sizes and times, is the empirical content of "gradient descent is circuit growth".

**What the saved data allow.** The first item is carried out in §3.4.
- *Test-set predictions.* The study saves sign predictions on 4096 test inputs at 15 checkpoints. The test inputs are independent of $S$, and their labels are not needed. This gives the sign-form check at every checkpoint, with $\varepsilon^U=\ln(2\cdot15|\Sigma|/\delta)/4096\approx2.3\cdot10^{-3}$ for $|\Sigma|\le23$ race states ([`checks/C_r2_checks.out`](checks/C_r2_checks.out) §5).
- *Fourier coefficients.* The saved coefficients on the relevant characters give *lower* bounds $\sum_{S\in\mathcal C}(\hat f_\theta(S)-\hat f^M(S))^2\le\|f_\theta-f^M\|^2$. They are coefficients of the *unclipped* output (`coef = fte @ chi / Xte.shape[0]` in `study/nn_train.py`), so they lower-bound the unclipped distance, which is at least the clipped distance of the $L^2$ form because clipping is 1-Lipschitz. They can therefore refute only an unclipped variant of the $L^2$ form, or the $L^2$ form itself when both $f_\theta$ and $f^M$ take values in $[-1,1]$; neither the least-squares readout $f^M$ nor the network output need do so. They are also estimated on the 4096 test inputs, so they carry sampling error. They cannot confirm the $L^2$ form.
- *Irrelevant influence.* $\mathrm{infl\_irr}$ averages only 5 of the $d-|R|$ irrelevant coordinates, so $(d-|R|)\cdot\mathrm{infl\_irr}$ is an extrapolation, not an upper bound, on the network's $L^2$ distance to the best real-valued junta on the relevant set (§1.2). At intermediate checkpoints, where only these summaries and the signs are saved, the saved data therefore cannot certify the $L^2$ form of SSA; the measured coordinates and the saved Fourier coefficients, both computed from the unclipped output, can at most refute it, in the restricted sense of the previous item.
- *Final parameters.* These allow any $m$, as in §1.4, including a rigorous junta distance (§1.2) and the $L^2$ form of SSA, but only at the final checkpoint, where the race's final state is the target in most runs and the test has little content.

**Caveat (μP initialization; Heuristic).**
- The study's network is not at small initialization. At μP, $W_1$ and $W_2$ are $O(1)$, and the initial output is $O(N^{-1/2})$ in $L^2$, a few hundredths at $N=128$.
- The race's $s=0$ predictor is the constant $\mathrm{sgn}\,\bar y$. The network has no output bias, so its early sign is that of a random function, and the sign form of SSA must fail early. The $L^2$ form can hold with $\eta$ of the order of the initial output.
- The clock calibration $\Theta=\log(1/\alpha_{\rm eff})$ is not determined by the theory here. The study's tables, with Fourier coefficients appearing in stages (for example and3: constant at step 20, linear terms at step 100, quadratic at step 500), are consistent with staged growth; that is the most they show.

### 3.4 A first test of SSA on the saved runs (Numerical)

[`checks/c3_ssa_check.py`](checks/c3_ssa_check.py) produces [`checks/c3_ssa_check.txt`](checks/c3_ssa_check.txt), in about 10 seconds. It runs A's (LS) race, with A's toy library (identity, $\mathrm{AND}(\pm a,\pm b)$, XOR; $|G|=6$, fan-in 2), on the *same* training set as the saved Adam network (seed 0).
- **What is compared.** At each of the network's 15 checkpoints, the network's sign predictions on the 4096 saved test inputs are compared with every race state, the constant $s=0$ state included. The test labels are not used.
- **What is reported.** $\hat\eta(t)=\min_s\widehat{\mathrm{dis}}_U(\mathrm{sgn}f_{\theta(t)},h^M_s)$, the best-matching race time $s^*$, and the certificate of Corollary C3.5(2) at the end of training.
- **The yardstick.** For a network with test error $e$, $\hat\eta\le e$ always, because the race's final state is the target in every run except par3. **SSA has content only where $\hat\eta\ll e$**, that is, where the network is closer to an intermediate race state than to the target.

| target | $n$ | checkpoints with $\hat\eta=0$ while error $>0.01$ | other intermediate checkpoints: $\hat\eta$ / test error | final certificate: race state (gates) / best C1 |
|---|---|---|---|---|
| and3 | 2048 | steps 10–100: the network predicts the majority label everywhere, the constant state $\mathrm{sgn}\,\bar y$ | step 200: 0.029 / 0.029 | 0.015 (2) / 0.010 |
| and3 | 256 | steps 10–100, the same | steps 200–20000: $\hat\eta=e$ (0.02–0.06) | 0.132 (2) / 0.104 |
| dnf3 | 2048 | steps 10–20: the constant state | steps 50–200: 0.11–0.14 / 0.13–0.25 | 0.152 (17) / 0.143 |
| dnf3 | 256 | steps 10–20: the constant state | steps 50–20000: 0.14–0.20 / 0.16–0.25 | 0.631 (11) / 0.687 |
| mux | 2048 | — | steps 10–20: 0.10–0.12 / 0.47–0.49 (near the constant); steps 50–200: 0.13–0.28 / 0.31–0.38 | 0.191 (20) / 0.014 |
| stair5 | 2048 | — | steps 10–500: 0.14–0.27 / 0.18–0.45; $s^*$ is not monotone in the step | 0.151 (17) / 0.020 |
| maj3 | 2048 | — | steps 10–50: 0.11–0.32 / 0.11–0.36 | 0.040 (6) / 0.010 |
| maj3 | 256 | — | step 20: 0.09 / 0.42 (near the constant); later $\hat\eta=e$ | 0.449 (9) / 0.119 |
| majpar | 2048 | — | $\hat\eta\approx e$ at every step except step 20 (0.075 / 0.478) | 0.081 (3) / 0.060 |
| parmaj | 2048 | — | steps 10–100: $\hat\eta\approx e$ (0.42–0.49) | 0.065 (9) / 0.031 |
| par3 | 2048 | — | the race fires no useful gate: its only firing, at $t/\Theta=13$, is a noise gate (A, Propositions A4.3 and A2.6). The network learns par3 by step 500 | vacuous / 0.008 |

**Reading.**
- **The first plateau is a trivial match.** For and3 and dnf3, whose labels are unbalanced, the μP Adam network predicts the majority label on every test input during its first plateau (and3: steps 10–100; dnf3: steps 10–20), before any feature is learned. That is the race's $s=0$ state, the constant predictor. But any learner that fits the mean first does the same, so this agreement says nothing about circuit growth and is no evidence for SSA beyond the trivial state. The transitions are the real test.
- **Partial support.** For dnf3, mux and stair5, the network's intermediate functions are closer to some intermediate race state than to the target: $\hat\eta$ is 40–80% of the test error. But $\hat\eta\approx0.1$–$0.3$ is far from small, and for stair5 the best-matching race time jumps back and forth.
- **Where it fails.** For maj3, majpar and parmaj the intermediate networks are no closer to any race state than to the target. For par3 the toy race cannot even start, while the network succeeds: its route goes through a three-way interaction, which a fan-in-2 race with these thresholds never fires. This is A's circuit-leap obstruction, which real gradient descent overcomes at a polynomial cost in time.
- **Overshoot costs certificate quality.** At $n=2048$, the race's own final circuit is a *worse* certificate than C1's read-off classes: 6 gates for maj3, 17–20 for mux, stair5 and dnf3. (At $n=256$ the race's certificate for dnf3 is the better one: $0.631$ with 11 gates, against $0.687$.) This is A's Proposition A4.2 (overshoot from ties and square-loss refits), now on real runs.

So, with this toy library and the sign form, SSA holds only in the trivial constant state and is a poor description of the transitions, and the time-indexed Theorem C3.4 cannot yet be applied to the study's runs. The certificates that *are* valid and non-vacuous come from C1 directly, as Corollary C3.5 says they would. A better test would use the $L^2$ form, which needs real outputs saved at intermediate checkpoints; a library closer to the network's units, such as ReLU neurons on few coordinates with a finite set of weights, counted with the real-valued constants of §3.2; and a fitted clock map $s(t)$. Saving more checkpoints during transitions would also help.

---

## 4. C4: the online protocol (fresh samples every step)

**Setting.** At step $i=1..N_{\rm steps}$ a fresh batch of $b$ iid samples is drawn, the current predictor $h_i$ predicts on it, and then the network updates. Let $N=N_{\rm steps}b$ be the total number of samples, ordered in time. Sample $z_j$ is predicted by a predictor $h_{(j)}$ that is measurable with respect to $\mathcal F_{j-1}$, everything before it; within a batch the predictor is constant. Write $p_j=\mathrm{err}(h_{(j)})=\mathbb E[\ell_j\mid\mathcal F_{j-1}]$ and $\ell_j=\mathbb 1[h_{(j)}(x_j)\ne y_j]$. $M_N=\sum_{j\le N}\ell_j$ is the number of online (prequential) mistakes.

### Proposition C4.1 (online-to-batch for the trajectory) — Proved

1. **Expectation.** For $J$ uniform on $[N]$ and independent of everything, $\mathbb E[\mathrm{err}(h_{(J)})]=\mathbb E[M_N]/N$.
2. **Hoeffding form.** With probability at least $1-\delta$, $\frac1N\sum_jp_j\le\frac{M_N}N+\sqrt{\frac{\ln(1/\delta)}{2N}}$.
3. **Fast-rate form.** For any finite grid $\Lambda\subset(0,\infty)$, with probability at least $1-\delta$, simultaneously for all $\lambda\in\Lambda$,
$$\frac1N\sum_{j\le N}p_j\ \le\ \frac{\lambda M_N+\ln(|\Lambda|/\delta)}{(1-e^{-\lambda})N}.$$
   For example, $\lambda=1$ gives $1.582\,(M_N+\ln\frac1\delta)/N$.

The left side is $\mathbb E_J[\mathrm{err}(h_{(J)})\mid\text{run}]$, the test error of a uniformly random iterate, weighted by the samples each iterate saw. Since predictors are constant within a batch, this is the same as a uniformly random step. All three statements cover any loss with values in $[0,1]$ in place of $\ell$.

*Proof.*
1. $\mathbb E\,p_j=\mathbb E\,\ell_j$ by the tower property. Average over $j$.
2. $D_j=p_j-\ell_j$ is a martingale difference in an interval of length 1, so Hoeffding's lemma and the supermartingale argument give the bound (as in A, Proposition A3.3).
3. For $\ell\in[0,1]$, convexity gives $e^{-\lambda\ell}\le1-\ell(1-e^{-\lambda})$. So $\mathbb E[e^{-\lambda\ell_j}\mid\mathcal F_{j-1}]\le1-p_j(1-e^{-\lambda})\le e^{-p_j(1-e^{-\lambda})}$. Hence $Z_N=\exp\big(\sum_{j\le N}[(1-e^{-\lambda})p_j-\lambda\ell_j]\big)$ is a nonnegative supermartingale with $\mathbb EZ_N\le1$, and $P(Z_N\ge|\Lambda|/\delta)\le\delta/|\Lambda|$. Take a union bound over $\Lambda$. ∎

Item 3 is the right form when the online error is small: $M_N$ mistakes give average test error $O((M_N+\ln\frac1\delta)/N)$, not $O(M_N/N+N^{-1/2})$. This is the online-to-batch principle of Littlestone (COLT 1989, "From on-line to batch learning"; abstract checked) and of Cesa-Bianchi, Conconi and Gentile (IEEE Trans. Inf. Theory 50(9), 2004, 2050–2057; venue checked, theorem form from memory). The supermartingale proof here is self-contained.

### Proposition C4.2 (the best checkpoint and the final iterate) — Proved

Let $I$ be a finite set of steps.
1. **Every later sample tests every earlier iterate.** Let $\widehat{\mathrm{err}}_{\ge i}(h_i)$ be the error of $h_i$ on the $N_{\ge i}$ samples drawn at steps $\ge i$. With probability $1-\delta$, simultaneously for all $i\in I$,
$$\mathrm{err}(h_i)\le\mathrm{kl}^{-1}_+\big(\widehat{\mathrm{err}}_{\ge i}(h_i),\ \ln(|I|/\delta)/N_{\ge i}\big).$$
   So the checkpoint $\hat\imath$ that minimizes the right side has error at most $\min_i$ of the right side. This is Littlestone's hypothesis-testing conversion, with kl in place of Hoeffding.
2. **The final iterate, through unlabelled disagreement.** Let $U$ be $m$ unlabelled inputs, independent of the run. With probability $1-\delta-\delta'$,
$$\mathrm{err}(h_{\rm final})\le\min_{i\in I}\Big[\mathrm{kl}^{-1}_+\big(\widehat{\mathrm{err}}_{\ge i}(h_i),\tfrac{\ln(|I|/\delta)}{N_{\ge i}}\big)+\mathrm{kl}^{-1}_+\big(\widehat{\mathrm{dis}}_U(h_{\rm final},h_i),\tfrac{\ln(|I|/\delta')}m\big)\Big].$$
3. **No unconditional final-iterate bound from the average.** Without item 2, or a stability assumption, a small trajectory average says nothing about the final iterate. Example: a learner that is perfect except on its last step, where it outputs $-f^\star$, has average error $1/N_{\rm steps}$ and final error 1.

*Proof.*
1. Conditionally on $\mathcal F$ at the start of step $i$, which determines $h_i$, the samples of steps $\ge i$ are iid from $P$. They are fresh, even though later iterates are trained on them. Apply Lemma C0.1 and a union bound over $I$.
2. Use the triangle inequality $\mathrm{err}(h_{\rm final})\le\mathrm{err}(h_i)+\mathrm{dis}(h_{\rm final},h_i)$. The disagreement terms are as in Theorem C1, step 2, with $U$ independent of the whole run.
3. The example is immediate. ∎

In the online protocol, then, no capacity term is ever needed: the prequential errors certify the trajectory, and unlabelled disagreement transfers the certificate to the final iterate. Circuit size cannot enter through *overfitting*. It enters through **how long it takes to build the circuit**, measured in samples.

### Proposition C4.3 (the first move of the online race costs $O(\ln|\mathcal M|/\gamma^2)$ samples) — Proved (race model)

**Online race, first phase.**
- A finite set $\mathcal M$ of candidate gates $g_m:\mathcal X\to[-1,1]$, with population utilities $U_m=\mathbb E[yg_m]$.
- Before the first firing the predictor is $0$, so the residual is $r=y$. This is exact for a race without intercept, and for a balanced target it is the population residual.
- Clocks $S_m(i)=\eta\sum_{i'\le i}\langle y,g_m\rangle_{B_{i'}}$ on fresh batches of size $b$. A gate fires when $|S_m|$ reaches $\Theta$.
- $m^*$ maximizes $|U_m|$, with $U^*=|U_{m^*}|$. Every candidate that does not compute $\pm g_{m^*}$ has $|U_m|\le U^*-\gamma$, with $\gamma\in(0,U^*]$.

Suppose
$$\eta\le\frac{\Theta\gamma}{2U^{*2}}\qquad\text{and}\qquad\frac b\eta\ >\ \frac{80\,U^*\ln(2|\mathcal M|/\delta)}{\Theta\,\gamma^2}.$$
Then, with probability at least $1-\delta$:
- the first gates to fire are $g_{m^*}$ and its duplicates $\pm g_{m^*}$, with orientation $\mathrm{sgn}\,U_{m^*}$;
- they fire at a time $t_1\in[\frac{3\Theta}{4U^*},\ \frac{5\Theta}{4U^*}+\eta]$;
- the number of samples consumed until then is
$$N_1\ \le\ \frac b\eta\Big(\frac{5\Theta}{4U^*}+\eta\Big),$$
  which at the smallest admissible $b/\eta$ is about $100\ln(2|\mathcal M|/\delta)/\gamma^2+b$.

In general $N_1\approx(b/\eta)\,\Theta/U^*$: the sampling rate (samples per unit of race time) times the population firing time. So $N_1$ depends on $\Theta$ unless the sampling rate is scaled with it. At the smallest admissible sampling rate, $b/\eta$ just above $80U^*\ln(2|\mathcal M|/\delta)/(\Theta\gamma^2)$, which scales like $1/\Theta$, the sample count is at most about $100\ln(2|\mathcal M|/\delta)/\gamma^2+b$, independently of $\Theta$ and hence of $\alpha$.

*Proof.*
1. **Clock concentration** (as in A, Lemma A3.2). Let $t_0=2\Theta/U^*$, $I_0=\lceil t_0/\eta\rceil$, and $D^m_i=\eta(\langle y,g_m\rangle_{B_i}-U_m)$.
   - $D^m_i$ is $\eta/b$ times a sum of $b$ independent mean-zero terms, each in an interval of length 2. By Hoeffding's lemma, $\mathbb E[e^{\lambda D^m_i}\mid\mathcal F_{i-1}]\le e^{\lambda^2\eta^2/(2b)}$.
   - So $\exp(\lambda\sum_{i\le I}D^m_i-\lambda^2\eta^2I/(2b))$ is a nonnegative supermartingale. Ville's maximal inequality gives $P(\max_{I\le I_0}\sum_{i\le I}D^m_i\ge x)\le\exp(-\lambda x+\lambda^2\eta^2I_0/(2b))$.
   - Take $\lambda=xb/(\eta^2I_0)$, treat both signs, and take a union bound over $\mathcal M$. With probability $1-\delta$, $|S_m(i)-i\eta U_m|\le x$ for all $i\le I_0$ and all $m$, where
   $$x^2=\frac{2\eta(\eta I_0)\ln(2|\mathcal M|/\delta)}b .$$
2. **Size of $x$.** $\eta\le\Theta\gamma/(2U^{*2})\le\Theta/(2U^*)$, so $\eta I_0\le t_0+\eta\le\frac{5\Theta}{2U^*}$. Hence $x^2\le\frac{5\eta\Theta\ln(2|\mathcal M|/\delta)}{U^*b}<\frac{\Theta^2\gamma^2}{16U^{*2}}$ by the condition on $b/\eta$. So $x<\frac{\Theta\gamma}{4U^*}\le\frac\Theta4$.
3. **$m^*$ fires within the horizon.** $|S_{m^*}(i)|\ge i\eta U^*-x$, so $m^*$ has fired by the first step $i$ with $i\eta\ge(\Theta+x)/U^*$. That step has $i\eta\le\frac{\Theta+x}{U^*}+\eta\le\frac{5\Theta}{4U^*}+\frac{\Theta}{2U^*}<t_0$.
4. **No other candidate fires first.** At every step $i$ with $i\eta\le\frac{\Theta+x}{U^*}+\eta$, a candidate other than $\pm g_{m^*}$ has
$$|S_m(i)|\le\Big(\frac{\Theta+x}{U^*}+\eta\Big)(U^*-\gamma)+x\le\Theta-\frac{\Theta\gamma}{U^*}+2x+\eta U^*<\Theta .$$
   The last step holds because $2x<\frac{\Theta\gamma}{2U^*}$ and $\eta U^*\le\frac{\Theta\gamma}{2U^*}$.
5. **Duplicates and orientation.** Duplicates of $\pm g_{m^*}$ have clocks $\pm S_{m^*}$ and fire at the same step. At firing, $|S_{m^*}|=\Theta>x\ge|S_{m^*}-i\eta U_{m^*}|$, so $S_{m^*}$ has the sign of $U_{m^*}$.
6. **Timing and samples.** Firing needs $i\eta U^*+x\ge\Theta$, so $t_1\ge(\Theta-x)/U^*\ge\frac{3\Theta}{4U^*}$. The upper bound on $t_1$ is step 3. The number of samples is $b$ times the number of steps, that is, $N_1=(b/\eta)t_1$. ∎

This is the correlational-SQ rate: one correct move costs $O(\ln|\mathcal M|/\gamma^2)$ fresh samples. The constants are not optimized.

**Example.** Take a balanced library target that is the only candidate with $U^*=1$, such as par2 with XOR in the library, where $\gamma=1/2$ (A, §3.1). With $|\mathcal M|=2205$ and $\delta=0.05$, $\ln(2|\mathcal M|/\delta)=11.4$, so $N_1\lesssim100\cdot11.4/0.25\approx4600$ samples plus one batch. The fired gate computes $\sigma y$ with the correct orientation $\sigma$, so any readout with the sign of $\sigma$ predicts $y$ exactly. The population refit is exact as well (A, Proposition A4.1). By Proposition C4.1, the average test error over the first $N$ samples is then at most about $N_1/N$, up to the stated deviation terms.

### C4.4 Circuit size and time-to-learn — Heuristic

To extend Proposition C4.3 to a run of $T$ moves, two things are needed that I have not proved: the readout must track the population refit (stochastic approximation), and the population race's crossing times must be separated by a clock margin $\Delta$. They are A's open problem 3. Granting them, the same concentration argument applies over the whole run.
- **Clocks never reset.** So the noise accumulates over the run's total time $t^*$, the time at which the population race reaches error $\varepsilon$. The needed rate is $b/\eta\gtrsim2t^*\ln(2|\mathcal M|/\delta)/\Delta^2$, and the sample cost is
$$N^*\approx\frac b\eta t^*\approx2\Big(\frac{t^*}{\Delta}\Big)^2\ln\frac{2|\mathcal M|}\delta .$$
- **The race time is $\alpha$-invariant, for the pure attach race.** In a race of $k=2$ attach moves with one threshold $\Theta$, $t^*$ and $\Delta$ both scale with $\Theta$ (A, Lemma 2.2(4)). Then $N^*$ does not depend on $\alpha$ at all: small initialization slows learning in *time*, not in *samples*. A's referee found that Lemma 2.2(4) holds only for this pure race. Once fresh-chain candidates with thresholds of order $\alpha^{-(k-2)}$ are added, the order of events, and with it $t^*/\Delta$ and $N^*$, can depend on $\alpha$ (A, the note after Lemma 2.2).
- **Where circuit size enters.** By Lemma C3.3, a race that has built $T$ gates has run for $\tau\ge\Theta\sqrt{T/\kappa}$, with $\kappa$ the data-dependent top eigenvalue of the centred Gram matrix of its fired gates. So $t^*/\Theta\ge\sqrt{T^*/\kappa}$, where $T^*$ is the size of the circuit the race needs. With $\Delta/\Theta$ the *relative* clock margin,
$$N^*\ \gtrsim\ \frac{T^*}{\kappa\,(\Delta/\Theta)^2}\ln\frac{2|\mathcal M|}{\delta}.$$
  For $T$ sequential moves with utilities about $U$ and gaps about $\gamma$, $t^*\approx T\Theta/U$ and $\Delta\approx\Theta\gamma/U$, which gives $N^*\approx2(T/\gamma)^2\ln|\mathcal M|$.
- **Comparison with Occam.** In both cases $\ln|\mathcal M|\approx\ln|G|+k\ln(d+T)$ is the per-gate description length of A's Lemma 1.1. So the online race needs about *(circuit description length) / (relative margin)²* samples, between linear and quadratic in $T$. The Occam batch learner needs *(description length) / ε* (A, Theorem A1), and a consistent online learner over $\mathcal H_T$ makes $O((L_T+\ln N)\ln N)$ total mistakes (Remark C4.5 below; the sibling project proves the posterior-sampling version). The race replaces $1/\varepsilon$ by $1/\gamma^2$, pays $T$ again for persistent clock noise, and needs every intermediate move to have positive margin.
- **When there is no margin.** If $\gamma=0$ at some stage, the formula gives $N^*=\infty$; this is A's Proposition A4.3 (parity is never found by the race). Real SGD then pays $d^{\Theta(\mathrm{leap})}$ in time, as in Abbe et al. and Barak et al. (Literature), which the race represents only through fan-in-$s$ gates with larger thresholds.

**Remark C4.5 (consistent online learners; Proved, standard).** Suppose that at round $i$ the learner predicts with some $h_i\in\mathcal H$, with $\mathcal H$ finite, that is consistent with the first $i-1$ labelled samples, and that the target is in $\mathcal H$. Then
$$\mathbb E[M_N]\le1+\big(\ln|\mathcal H|+\ln N\big)\big(1+\ln N\big)+\big(1+\ln N\big).$$
*Proof.* Put $\varepsilon_i=(\ln|\mathcal H|+\ln i)/(i-1)$. The probability that some $h\in\mathcal H$ with $\mathrm{err}(h)>\varepsilon_i$ is consistent with $i-1$ samples is at most $|\mathcal H|(1-\varepsilon_i)^{i-1}\le|\mathcal H|e^{-\varepsilon_i(i-1)}=1/i$. So $\mathbb E\,p_i\le\varepsilon_i+1/i$ for $i\ge2$, and $p_1\le1$. Sum, using $\sum_{i=2}^N\frac1{i-1}\le1+\ln N$ and $\sum_{i\le N}\frac1i\le1+\ln N$. ∎

This is the precise sense in which small circuits imply few total mistakes for an Occam learner. The race is not consistent with past data, so the remark does not apply to it. For the race the mechanism is Proposition C4.3.

**What can be checked.** The study's online protocol (one pass, batch 64) records the error on a fixed test set against samples seen, every 500 steps. After revision 2 was written, `study/nn_train.py` was changed to log the prequential mistakes as well, that is, the errors of each iterate on its own fresh batch before the update, summed over each logged chunk of steps (`preq_mistakes`, `preq_steps`). The online runs of par2, par3, maj9, stair5, majpar and mux (3 seeds each) were rerun with this logging (`study/run_online2.sh`; the outputs are kept outside the repository, like the sweep's). [`study/online_bounds.py`](../study/online_bounds.py) evaluates the Hoeffding form of Proposition C4.1 on them and writes [`study/ONLINE-BOUNDS.md`](../study/ONLINE-BOUNDS.md). It applies C4.1(2) to windows of steps fixed in advance; the martingale argument is unchanged for the samples of a fixed window. Over the second half of training the prequential mistake rate is 0 in all 18 runs, so the average test error of those iterates is certified at $\le0.0017$, and at $\le0.0038$ over the last 2000 steps ($\delta=0.025$ per window). Per-window bounds during learning (seed 0, up to step 1000) are in the same file. The fast-rate form, C4.1(3), has not been evaluated. Proposition C4.2 is still not computable: the later-sample errors $\widehat{\mathrm{err}}_{\ge i}(h_i)$ of C4.2(1) would need each checkpoint's predictions on the later batches, which are not logged. The heuristic predicts that the samples-to-learn number is independent of the learning rate at fixed $b/\eta$, and that it scales like $\ln d/\gamma^2$ for library targets. Both are testable.

---

## 5. What is vacuous at realistic sizes, and what is open

**Non-vacuous**
- Theorem C1 on the saved networks: below $0.5$ for all 13 targets at $n=2048$, below $0.04$ for 9 of them, and $\le0.021$ for every network at $n=16384$. The Fourier-sign class extends B's junta read-off to MAJ$_9$, THR$_{10}$ and dnf3 (§1.4). The certified networks are the float16-rebuilt ones; the trained float32 networks cost at most $0.0024$ more (§1.3).
- §1.6: certificates at every checkpoint of a run, uniformly over its 15 checkpoints, from saved predictions only, once the network is within about $0.1$ of a predictor in a small class.
- Theorem C2.4, and Corollary C2.5 with the measured $\kappa_B$, for sparse targets in the diagonal toy, from $n=100$–$400$ with $D=176$. The same holds for GD and SGD (Proposition C2.6).
- Proposition C4.1, Hoeffding form, on the online reruns with prequential logging (§4, "What can be checked"; [`study/ONLINE-BOUNDS.md`](../study/ONLINE-BOUNDS.md)): the average test error of the iterates in the second half of training is certified at $\le0.0017$ in all 18 runs. This is an average over the iterates of a window; over a whole run it would include the early, bad ones.

**Vacuous or weak**
- Corollary C2.5(2)–(3), the forms without the data-dependent $\kappa_B$, need $\mu(\tau/\Theta_\gamma)^2<1$. At $n\le400$ this holds only for par2 at $\alpha=10^{-8}$: $0.107$ with the empirical $\mu_n$, $0.163$ with the Hoeffding $\bar\mu$ (size term a function of $(n,D,\tau)$ alone), and $0.275$ with raw time $t$, at $t=10$ only. A time-only size term needs $n\gtrsim2(\tau/\Theta_\gamma)^4\ln(2D_{2k}/\delta')$.
- Proposition C2.6(4), the SGD size count: it uses integrated minibatch gradient norms, and $N/\text{bound}$ is only $0.07$–$0.12$.
- Lemma C3.2 at depth 4 for $\alpha\ge0.1$: $\prod\|W_l\|_F$ is too crude. At depth 3 the bound has the right scaling but is loose by 14–21×.
- Proposition C4.3's constants: $100\ln(2|\mathcal M|/\delta)/\gamma^2$ is thousands of samples for par2, where the toy race needs far fewer.

**Not yet evaluated**
- Proposition C4.2 on the study's online runs. The study does not log the later-sample errors $\widehat{\mathrm{err}}_{\ge i}(h_i)$ that C4.2(1) uses (§4, "What can be checked").
- The fast-rate form of Proposition C4.1, which loses a factor of $1.58$ at $\lambda=1$. Only the Hoeffding form has been evaluated on the online reruns.

**Conditional**
- Theorem C3.4 is only as good as hypothesis SSA. In the sign form, with A's toy library, SSA holds only in the trivial constant state of the first plateau (and3, dnf3), which any learner that fits the mean first reaches; only partly during transitions ($\hat\eta\approx0.1$–$0.3$); and not at all for par3 (§3.4). So the time-indexed bound cannot yet be applied to the study's runs; C1 certifies them a posteriori.

**Open problems**
1. **Prove SSA for some ReLU class.** A non-asymptotic SSA, even for two-layer ReLU networks on Boolean inputs with a finite library of neuron directions, would make Theorem C3.4 unconditional. The early-alignment results cover the first move; the difficulty is the second move onward.
2. **A deep analogue of Theorem C2.3.** Lemma C3.2 bounds total growth, not the number of grown units. A bound on the number of units of a deep network with $\rho_j\ge\varepsilon$, in terms of time and an incoherence quantity, would be the deep analogue of $N\le\kappa\tau^2/\Theta^2$.
3. **The multi-move online race** (C4.4): readout tracking and the clock margin. This is A's open problem 3, with sample complexity as the payoff.
4. **The μP calibration.** What plays the role of $\Theta=\log(1/\alpha)$ at μP initialization with width 128? This decides whether the time-indexed bounds (Corollary C2.5, Theorem C3.4) can be applied to the study's runs.
5. **Exact disagreement.** For networks that are provably juntas, for example after pruning input weights below a certified threshold, Theorem C1(c) could be applied with exact disagreement and no sampling error.

---

## 6. Files

All scripts are in [`checks/`](checks/), use numpy and scipy, and run in seconds to a few minutes on one core. The C1, §1.6 and §3.4 scripts, the referee's float16 check and part 4 of `C_r2_checks.py` read the sweep outputs read-only from `$RESULTS`, which are kept outside the repository, as in B.

| script | output | checks |
|---|---|---|
| [`c_common.py`](checks/c_common.py) | — | kl inverse, $\Phi$, log-binomials |
| [`c1_class_sizes.py`](checks/c1_class_sizes.py) | [`c1_class_sizes.txt`](checks/c1_class_sizes.txt) | Propositions C1.2–C1.4: sizes at $d=30$; brute force for small $d$ |
| [`c1_fourier_cert.py`](checks/c1_fourier_cert.py) | [`c1_fourier_cert.txt`](checks/c1_fourier_cert.txt), `c1_fourier_cert.json` | Theorem C1 on the saved final Adam networks (§1.4) |
| [`c1_trajectory_cert.py`](checks/c1_trajectory_cert.py) | [`c1_trajectory_cert.txt`](checks/c1_trajectory_cert.txt), `c1_trajectory_cert.json` | Theorem C1 along training, from saved test-set predictions (§1.6) |
| [`c2_diag_check.py`](checks/c2_diag_check.py) | [`c2_diag_check.txt`](checks/c2_diag_check.txt), `c2_diag_check.json` | Lemma C2.1, Theorems C2.2–C2.4, Corollary C2.5 |
| [`c2_discrete_check.py`](checks/c2_discrete_check.py) | [`c2_discrete_check.txt`](checks/c2_discrete_check.txt) | Proposition C2.6 (GD and SGD) |
| [`c3_gronwall_check.py`](checks/c3_gronwall_check.py) | [`c3_gronwall_check.txt`](checks/c3_gronwall_check.txt), `c3_gronwall_check.json` | Lemmas C3.1 and C3.2 |
| [`c3_ssa_check.py`](checks/c3_ssa_check.py) | [`c3_ssa_check.txt`](checks/c3_ssa_check.txt), `c3_ssa_check.json` | §3.4: hypothesis SSA (sign form) against A's race on the saved runs; uses [`race_bounds.py`](checks/race_bounds.py) from A |
| [`referee_C_r1.py`](checks/referee_C_r1.py), [`referee_C_r1_fp16.py`](checks/referee_C_r1_fp16.py), [`referee_C_r1_small.py`](checks/referee_C_r1_small.py) | [`referee_C_r1.out`](checks/referee_C_r1.out), [`referee_C_r1_fp16.out`](checks/referee_C_r1_fp16.out), [`referee_C_r1_small.out`](checks/referee_C_r1_small.out) | the round-1 referee's checks: kl readings, Lemmas C3.1–C3.2, Proposition C2.6 at large steps, Proposition C4.3 by simulation; float16 versus float32 networks; MAJ$_3$ circuit size, $\mathcal F_{8,1}$, MAJ$_9$ level-1 weight |
| [`C_r2_checks.py`](checks/C_r2_checks.py) | [`C_r2_checks.out`](checks/C_r2_checks.out) | revision 2: class sizes for §1.2; the three choices of Corollary C2.5; the float16 transfer term; junta distance of the final networks (§1.2); Corollary C3.5(1) constant; per-seed §1.4 table |
| [`referee_C_r2.py`](checks/referee_C_r2.py) | [`referee_C_r2.out`](checks/referee_C_r2.out), [`referee_C_r2.json`](checks/referee_C_r2.json) | the round-2 referee's independent checks and report |

## References

**Generalization via simpler predictors and unlabelled data**
- D. Hsu, Z. Ji, M. Telgarsky, L. Wang. *Generalization bounds via distillation.* ICLR 2021. [arXiv:2104.05641](https://arxiv.org/abs/2104.05641) (abstract checked).
- M. Kääriäinen. *Generalization error bounds using unlabeled data.* COLT 2005, LNCS 3559, 127–142 (abstract checked).
- S. Arora, R. Ge, B. Neyshabur, Y. Zhang. *Stronger generalization bounds for deep nets via a compression approach.* ICML 2018.
- N. Linial, Y. Mansour, N. Nisan. *Constant depth circuits, Fourier transform, and learnability.* JACM 40(3) (1993) (from memory).

**Counting and VC dimension**
- T. Cover. *Geometrical and statistical properties of systems of linear inequalities.* IEEE Trans. Electronic Computers EC-14 (1965).
- J. M. Steele (1975); R. M. Dudley, *Central limit theorems for empirical measures*, Ann. Probab. 6 (1978): VC dimension of sign classes of vector spaces (attribution checked against lecture notes).
- M. Anthony, P. Bartlett. *Neural Network Learning: Theoretical Foundations.* CUP 1999 (Chapter 3; theorem numbering from memory).
- C. Shannon. *The synthesis of two-terminal switching circuits.* Bell Syst. Tech. J. 28 (1949) 59–98 (counting argument; attribution from memory).

**Diagonal and two-layer networks from small initialization**
- B. Woodworth, S. Gunasekar, J. Lee, E. Moroshko, P. Savarese, I. Golan, D. Soudry, N. Srebro. *Kernel and rich regimes in overparametrized models.* COLT 2020, PMLR 125 (venue checked).
- S. Pesme, N. Flammarion. *Saddle-to-saddle dynamics in diagonal linear networks.* NeurIPS 2023. [arXiv:2304.00488](https://arxiv.org/abs/2304.00488).
- R. Berthier. *Incremental learning in diagonal linear networks.* JMLR 24 (2023) (from memory).
- H. Maennel, O. Bousquet, S. Gelly. *Gradient descent quantizes ReLU network features.* [arXiv:1803.08367](https://arxiv.org/abs/1803.08367) (2018).
- E. Boursier, L. Pillaud-Vivien, N. Flammarion. *Gradient flow dynamics of shallow ReLU networks for square loss and orthogonal inputs.* NeurIPS 2022. [arXiv:2206.00939](https://arxiv.org/abs/2206.00939).
- E. Boursier, N. Flammarion. *Early alignment in two-layer networks training is a two-edged sword.* JMLR 26 (2025). [arXiv:2401.10791](https://arxiv.org/abs/2401.10791).
- H. Min, E. Mallada, R. Vidal. *Early neuron alignment in two-layer ReLU networks with small initialization.* ICLR 2024. [arXiv:2307.12851](https://arxiv.org/abs/2307.12851).
- A. Kumar, J. Haupt. *Directional convergence near small initializations and saddles in two-homogeneous neural networks.* TMLR 2024. [arXiv:2402.09226](https://arxiv.org/abs/2402.09226).
- A. Kumar, J. Haupt. *Early directional convergence in deep homogeneous neural networks for small initializations.* TMLR 2025. [arXiv:2403.08121](https://arxiv.org/abs/2403.08121).
- A. Kumar, J. Haupt. *Learning neural networks by neuron pursuit.* [arXiv:2509.12154](https://arxiv.org/abs/2509.12154) (2025).
- D. Kunin, G. Marchetti, F. Chen, D. Karkada, J. Simon, M. DeWeese, S. Ganguli, N. Miolane. *Alternating gradient flows: a theory of feature learning in two-layer neural networks.* NeurIPS 2025. [arXiv:2506.06489](https://arxiv.org/abs/2506.06489).
- I. Bantzis, J. Simon, A. Jacot. *Saddle-to-saddle dynamics in deep ReLU networks: low-rank bias in the first saddle escape.* ICLR 2026. [arXiv:2505.21722](https://arxiv.org/abs/2505.21722).
- K. Lyu, Z. Li, R. Wang, S. Arora. *Gradient descent on two-layer nets: margin maximization and simplicity bias.* NeurIPS 2021 (from memory).
- S. Du, W. Hu, J. Lee. *Algorithmic regularization in learning deep homogeneous models: layers are automatically balanced.* NeurIPS 2018 (from memory).
- D. Davis, D. Drusvyatskiy, S. Kakade, J. Lee. *Stochastic subgradient method converges on tame functions.* Found. Comput. Math. 2020 (chain rule for ReLU losses; not needed by Lemmas C3.1–C3.2, which use only the per-unit Euler identity).

**Sparse targets and SGD**
- E. Abbe, E. Boix-Adserà, T. Misiakiewicz. *SGD learning on neural networks: leap complexity and saddle-to-saddle dynamics.* COLT 2023. [arXiv:2302.11055](https://arxiv.org/abs/2302.11055).
- B. Barak, B. Edelman, S. Goel, S. Kakade, E. Malach, C. Zhang. *Hidden progress in deep learning: SGD learns parities near the computational limit.* NeurIPS 2022. [arXiv:2207.08799](https://arxiv.org/abs/2207.08799).

**Online-to-batch**
- N. Littlestone. *From on-line to batch learning.* COLT 1989, 269–284 (abstract checked).
- N. Cesa-Bianchi, A. Conconi, C. Gentile. *On the generalization ability of on-line learning algorithms.* IEEE Trans. Inf. Theory 50(9) (2004) 2050–2057 (venue checked).

**This project and its sibling**
- [A: generalization bounds for the discrete model](A-discrete-model.md); [B: bounds for the actual network](B-nn-time-bounds.md); [README](../README.md).
- [`neural-network-generalization/TECHNICAL-FAQ.md`](../../neural-network-generalization/TECHNICAL-FAQ.md): total-mistake bounds and circuit-induction converses.

## Revision notes

Revision 2 answers the round-1 referee report ([`checks/referee_C_r1.json`](checks/referee_C_r1.json); verdict "pass, with required revisions", no fatal issues, 3 major and 15 minor). Each item below is in the order of the report. New numbers come from [`checks/C_r2_checks.py`](checks/C_r2_checks.py), whose output is [`checks/C_r2_checks.out`](checks/C_r2_checks.out). No existing check script needed rerunning: none of the fixes changes a number those scripts compute. The C2.5 values with the Hoeffding coherence bound are recomputed from `c2_diag_check.json`.

1. **(major) Theorem C3.4, library constants for real-valued gates.** The library is now required to be finite, with gates $[-1,1]^k\to[-1,1]$ (§3.2). Two sets of constants are stated. For a *Boolean* library (every gate $\pm1$-valued on the cube, as A's toy library used in §3.4) they are the old ones, $L^{\rm sgn}_T=W_T+\ln\Phi(2^{\min(T,d)},T)$ and $L^{\rm mar}_T=W_T+\ln\Phi(2^{\min(T+1,d+1)},T+1)$. For a real-valued library they are $W_T+\ln\Phi(2^d,T)$ and $W_T+\ln\Phi(2^{d+1},T+1)$, as in A's Lemma 1.2. The theorem statement names the hypothesis. Proof step 1 now counts the image points for both cases. §3.4's suggestion of a ReLU-neuron library now says that it must be finite and counted with the real-valued constants. The §3.4 numbers use the Boolean toy library and are unchanged.
2. **(major) Corollary C2.5, circular Gershgorin choice and "a priori".** The corollary is restated for any, possibly data-dependent, $\bar N\ge N_\varepsilon(t)$, with three proved choices: (1) measured $\kappa_B$, called time-indexed with a data-dependent $\kappa$; (2) the fixed point $\bar N_G=\min\{D,\lfloor(1-\mu_n)x/(1-\mu_nx)\rfloor\}$ for $\mu_nx<1$, from Theorem C2.3(2) and Gershgorin, with no circularity; (3) the same with the Hoeffding bound $\bar\mu=\sqrt{2\ln(2D_{\min(2k,d)}/\delta')/n}$ in place of $\mu_n$ and optionally $t$ in place of $\tau$, at probability $1-\delta-\delta'$. Choice (3) needs a monotonicity argument, which is given. Only it makes the size term a function of $(n,D,\tau)$, or of $(n,D,t)$, alone. It needs $n>2\ln(2D_{2k}/\delta')(\tau/\Theta_\gamma)^4$. "A priori" is removed throughout: the Summary, the status table, "What the corollary says", §2.2 and §5. The §2.2 table gains a column for choice (3). It is non-vacuous only for par2 at $\alpha=10^{-8}$: $0.163$, or $0.275$ with raw time at $t=10$.
3. **(major) $\mathrm{infl\_irr}$ is not an upper bound.** §1.2 and §3.3 now say that $\mathrm{infl\_irr}$ averages only the first 5 of the $d-|R|$ irrelevant coordinates. The measured terms therefore give a lower bound on $\sum_{i\notin R}\mathrm{Inf}_i$, and $(d-|R|)\cdot\mathrm{infl\_irr}$ is an extrapolation, unbiased over training runs by permutation equivariance but not a bound. So the saved data cannot certify the $L^2$ form of SSA at intermediate checkpoints. A rigorous replacement is added for the final networks: a pair estimator of $\|\mathrm{clip}f-\mathbb E[\mathrm{clip}f\mid x_R]\|^2$, with an upper confidence bound from Lemma C0.1. Lemma C0.1 is extended, with proof, to $[0,1]$-valued variables for this purpose. Over the 117 final networks the bound is $\le0.0072$ at $n=16384$ and has median $0.0034$ at $n=2048$. The full influence sum over all irrelevant coordinates is $0.73$–$1.55$ times the extrapolation where it is non-negligible.
4. **Corollary C3.5(1), union bound.** $\ln(|\mathcal T||\Sigma|/\delta_2)$ is replaced by $\ln(2|\mathcal T||\Sigma|/\delta_2)$ in both displays, and the proof counts the $2|\mathcal T||\Sigma|$ events. The §3.3 value of $\varepsilon^U$ becomes $\approx2.3\cdot10^{-3}$. The C3.5(2) certificates of §3.4 use Theorem C1(b) and are unaffected.
5. **"Exactly when" after Proposition C1.5** is replaced by "in particular when". The MAJ$_9$ example is added: level-1 weight $0.673$, so C1.5(1) guarantees only $0.327$, while $\mathcal F_{1,9}$ certifies $0.034$.
6. **The first-plateau match is trivial.** The Summary, the status table, the §3.4 table and reading, and §5 now say that the first-plateau agreement is with the constant (majority-label) predictor. Any learner that fits the mean first shows it, so it is no evidence for circuit growth, and the transitions are the real test. The summary sentence "describes plateaus, not transitions" is replaced by "supported only in the trivial constant state".
7. **§1.6 uniformity and "certifiably close".** The uniformity is now stated as "simultaneously over the checkpoints of each run", with failure probabilities adding across runs. The staged class is described as the class that minimizes the certificate, which trades error against size, with the stair5 example (error $0.30$–$0.34$ under the $x_1$ certificate). The section title, the Summary and the status table are changed to match. "Certifiably close" is kept only where the certificate is small.
8. **Proposition C4.3 prose.** The sentence "$N_1$ does not depend on $\Theta$, hence not on $\alpha$, nor on $\eta$ and $b$ separately" is replaced. It now says that $N_1\approx(b/\eta)\Theta/U^*$ in general, and that it is free of $\Theta$ only at the smallest admissible sampling rate, where it is at most about $100\ln(2|\mathcal M|/\delta)/\gamma^2+b$. The Summary and the status table are changed to match.
9. **Tightness remark after Theorem C2.3.** It now says that the bound is exact when $\chi_{S^*}$ is empirically orthogonal to the rest of the dictionary, and tight only as $\alpha\to0$ at nonzero coherence, with a proof sketch. The printed ratio $1.0000000016$ is identified as integration error. Summary item 2(b) is changed to match.
10. **Proposition C2.6, "minibatch losses".** That wording is now restricted to item 3, no early growth. The text states that the SGD count, item 4, uses the integrated minibatch gradient norms, which can exceed the loss-based quantity by up to $\sqrt D$, and that it is loose ($0.07$–$0.12$). Item 6 says how the three choices of C2.5 carry over to GD. Summary item 2(d) is changed to match.
11. **Which network is certified.** §1.3 now says that the certificates refer to the float16-rebuilt network. A transfer term to the float32 network is added: $+0.0024$ at extra failure probability $0.01$, from at most 2 of 4096 independent test inputs. Summary item 1 and §5 mention it.
12. **The sign convention in §0.** §0 now states that Theorem C1 bounds $P(\mathrm{sgn}f\ne y)$ with $\mathrm{sgn}(0)=+1$, as the scripts do. The margin results C2.4 and C3.4(2) bound the larger $P(yf\le0)$.
13. **The PAR$_8$ example in "Which class wins"** is corrected. PAR$_8$ lies in $\mathcal F_{8,1}$ at $17.4$ nats, so it is an example of the Fourier-sign class winning. dnf3 is the new example of circuits winning: 73 nats as an 8-gate circuit, against 392 nats for its 21-character sign representation (verified by enumeration) and 371 nats as a 9-junta.
14. **§1.4 table format.** The table now gives per-seed pairs (true error, certificate) instead of a mean error next to a range of certificates. It states the smallest certificate-minus-error gap, $0.0009$, and that a certificate above 1 is a sum of two terms.
15. **"The actual network" in §3.1.** This is replaced by "small-initialization gradient descent on these architectures". The text now says that the study's networks are outside Lemmas C3.1 and C3.2: two hidden layers with a hidden bias, μP scale, and Adam with per-layer multipliers. The Summary and the status table are changed to match.
16. **Theorem C3.4 "In words", the unit of $\Theta$, and C4.4.** The size bound is now described as time-indexed with the data-dependent $\kappa^M$, not a function of time alone, with a pointer to Corollary C2.5(3) for what a time-only version needs. A "Units of $\Theta$" bullet in §3.2 unifies the unit: $\Theta=c\ln(1/\alpha)+O(1)$, with $c=\frac12$ in C2's diagonal network and $c=1$ for a two-layer ReLU unit. C4.4's "the race time is $\alpha$-invariant" is restricted to the pure $k=2$ race, citing A's revised Lemma 2.2(4). "Data-dependent $\kappa$" is added in C4.4 and the Summary. Corollary C3.5's closing paragraph says "predictive, time-indexed" instead of "a priori".
17. **§5, Propositions C4.1–C4.2 "essentially exact".** This entry is moved to a new "Not yet evaluated" list. The study's online runs log only fixed-test-set error every 500 steps, not prequential mistakes (checked in `study/nn_train.py`), so the bounds cannot be computed from saved data. The §4 "What can be checked" paragraph now says what would have to be logged. The entry notes the trajectory-average and fast-rate caveats. (Superseded since: the logging has been added and the Hoeffding form evaluated; see the round-2 notes, item 2.)
18. **Theorem C2.2(2) and the §3.4 table.** The redundant minimum in $\varepsilon_D$ is dropped: $\varepsilon_D=\sqrt{\lambda_{\max}(K)D}\,\varepsilon\le D\varepsilon$, and the proof is simplified to match. The dnf3 $n=256$ entry is corrected to "steps 10–20".

Not changed: the referee found every other Proved result correct, and the numerical tables reproduce. A round-2 referee passed this revision with 10 minor issues and no major ones ([`checks/referee_C_r2.json`](checks/referee_C_r2.json)); those minor issues have been applied, as listed in the **Round-2 referee** entry below.

**Round-2 referee** ([`checks/referee_C_r2.json`](checks/referee_C_r2.json), checks in [`checks/referee_C_r2.py`](checks/referee_C_r2.py) → [`checks/referee_C_r2.out`](checks/referee_C_r2.out)). The verdict on revision 2 was "pass": every round-1 issue is fixed, and every new or changed Proved result holds. The report lists 10 issues, all minor, none affecting a Proved result. Each is applied below, in the order of the report. No status label changes, no claim is strengthened, and no check script was rerun; the online numbers of item 2 and the class sizes of item 10 were confirmed by quick read-only recomputations. New numbers come from the report, from the existing tables of this file, from [`checks/c3_ssa_check.txt`](checks/c3_ssa_check.txt), and from [`study/ONLINE-BOUNDS.md`](../study/ONLINE-BOUNDS.md).

1. **Tightness remark after Theorem C2.3.** "*Every* coordinate is nonzero for $t>0$" contradicted the orthogonal case in the sentence before it. It now says that *generically* every coordinate is nonzero, since $w_S(t)=0$ exactly when $G_S(t)=0$, as for all $S\ne S^*$ in the orthogonal case.
2. **Prequential logging (§4, §5, revision note 17).** `study/nn_train.py` now logs prequential mistakes, and the online runs of par2, par3, maj9, stair5, majpar and mux were rerun with it. §4 "What can be checked" now says so, and reports the evaluation of the Hoeffding form of Proposition C4.1 in `study/ONLINE-BOUNDS.md`, over windows of steps fixed in advance: $\le0.0017$ over the second half of training in all 18 runs, $\le0.0038$ over the last 2000 steps. In §5 that entry moves from "Not yet evaluated" to "Non-vacuous". The fast-rate form, and Proposition C4.2, which needs predictions on later batches that are not logged, stay under "Not yet evaluated". The old estimate of the deviation term is dropped. Revision note 17 gains a pointer to this item.
3. **§3.3, the saved Fourier coefficients.** They are coefficients of the unclipped output, so they lower-bound the unclipped distance, which is at least the clipped distance of the $L^2$ form. The bullet now says that they refute only an unclipped variant, or the $L^2$ form when both outputs lie in $[-1,1]$, and that they carry sampling error from the 4096 test inputs. The closing sentence of the next bullet is restricted to match.
4. **§1.5 "Where it fails".** The range "error $0.17$–$0.35$" (seed means) is replaced by the per-seed range $0.15$–$0.38$. The text now notes the one non-vacuous network among them, dnf3 seed 2 at $n=256$, certified at $0.496$, and says "where" instead of "exactly where".
5. **Summary item 2, Corollary C2.5.** The range $0.11$–$0.48$ is now qualified: it is for the sparse targets at $n=400$ and par2 at $n=100$, and C2.5(1) gives $0.81$ for maj3 at $n=100$.
6. **§3.4.** (a) "Overshoot costs certificate quality" now says "at $n=2048$", and notes that at $n=256$ the race's dnf3 certificate is the better one ($0.631$ with 11 gates against $0.687$). (b) The majpar row says $\hat\eta\approx e$ instead of $\hat\eta=e$ (at step 10 it is $0.434$ against $0.486$, at step 50 $0.446$ against $0.453$).
7. **§1.5, "exactly where B's read-off failed".** The heading now reads "The Fourier-sign class is decisive where B's junta read-off fails: maj9, thr10, dnf3", and adds that the class is also the best one for dict, par2, par3, par4 and majpar at $n=2048$, where juntas would also certify.
8. **C4.4, the consistent online learner.** $O(L_T\ln N)$ is replaced by $O((L_T+\ln N)\ln N)$, which is what Remark C4.5 gives.
9. **The letter $c$.** The clock-calibration slope in Theorem C3.4 "In words" and in the paragraph after Corollary C3.5 is now $c_s$, and the constant $1/(1-4\eta^2G^2)$ of Proposition C2.6 is now $c_\eta$. The $c$ of §3.2, "Units of $\Theta$", is unchanged.
10. **§1.2 "Which class wins", dnf3 (suggestion).** No class is added to the hierarchy. The text now says that the 392 nats are the size of the counted class $\mathcal F_{3,21}$, with the $2^{\min(T,d)}$ point count, not of the representation. It also gives the referee's rank-restricted count: the 21 supports have GF(2) rank 9, and characters inside some 9 of the 30 coordinates cost $142.6$, $147.6$ and $157.3$ nats at $T=18,19,21$, against $304.0$, $332.1$ and $392.3$ (the referee's figures, recomputed here). Circuits still win. §1.5 mentions the restricted figure next to "about 300 for $\mathcal F_{3,18}$".

Also changed: the header now says that this version applies the round-2 minor fixes, and the Files table in §6 lists the round-2 referee files. Not changed: the theory README's status line for C, which the referee notes is out of date; it lies outside this file.
