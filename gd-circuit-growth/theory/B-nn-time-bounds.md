# B. "Short training implies generalization": honest bounds for the actual network

Notes by Claude, prompted by Kaarel Hänni. Research note, 23 October 2026; not reviewed by a human.

*Revision 2, after referee round 1 ([`checks/referee_B_r1.json`](checks/referee_B_r1.json)). Every flagged item is addressed; the changes are listed in the [revision notes](#revision-notes). A round-2 referee passed this revision with 8 minor issues and no major ones ([`checks/referee_B_r2.json`](checks/referee_B_r2.json)); those minor issues have now been applied, as listed under "Round-2 referee" in the [revision notes](#revision-notes).*

**Question (from the user).** *Can we get generalization bounds of the form "training has not taken long, so the learned circuit cannot be big yet, so a Chernoff bound over all small circuits says train and test loss are close"?* This file does it for the **actual network** of the study, with no discrete model in between. It is meant as the honest baseline that the circuit-based bounds (tasks A and C) should beat.

**Status labels**, as in [`neural-network-generalization/`](../../neural-network-generalization/TECHNICAL-FAQ.md):
- **Proved:** complete proof in this file, explicit constants. A proof may invoke results labelled Literature; each such use is named.
- **Literature:** a published result. Where I could not check the statement against the paper it says *(from memory)*. Full texts could not be fetched for this note; a few statements were checked against search summaries, as indicated.
- **Heuristic / Conjecture:** as usual.
- **Numerical:** a Proved bound evaluated on real or representative numbers (Section 5). Scripts are in [`checks/`](checks/).

## Contents

0. [Short answer](#0-short-answer)
1. [Setting and notation](#1-setting-and-notation)
2. [B1: displacement from initialization as a function of training time](#2-b1-displacement-from-initialization)
3. [B2: capacity of the network class](#3-b2-capacity-bounds)
4. [B3: combined theorems; stability and information-theoretic alternatives](#4-b3-combined-theorems)
5. [B4: numbers](#5-b4-numbers)
6. [What the circuit bounds of tasks A and C have to beat](#6-what-the-circuit-bounds-have-to-beat)
7. [Files](#7-files) and [references](#references)
8. [Revision notes](#revision-notes)

## 0. Short answer

The intuition goes through rigorously for gradient flow, for full-batch GD while the descent condition (D) holds (checked a posteriori), and for Adam (with a bound quadratic in the number of steps $K$); for SGD on ReLU networks it goes through only via measured quantities. It works in **parameter space**, not circuit space, and it is **numerically weak**:

1. **Time bounds displacement (Proved).** For gradient flow with per-layer learning-rate multipliers $M$ (the μP multipliers), $\|\theta(t)-\theta(0)\|_{M^{-1}}\le\sqrt{t\,(L_S(\theta_0)-L_S(\theta(t)))}\le\sqrt{t\,L_S(\theta_0)}$ (Theorem B1.1). For GD the same holds with a factor $1/c$ under a descent condition (Corollary B1.2). For SGD only a weaker statement is available, in expectation and under smoothness (Proposition B1.3): $\mathbb E\|\Delta\theta\|_{M^{-1}}^2\le4tL_0+2\eta t\nu^2(1+\beta t)/B$, i.e. a factor $4$ and an additive noise term that grows like $t^2$ at fixed $\eta$. With no assumptions, the worst-case gradient-norm bound is useless after a fraction of one step (Remark B1.5). For Adam the correct worst-case per-coordinate step is $C_t\cdot\mathrm{lr}$ with $C_t\uparrow 7.27$ for $(\beta_1,\beta_2)=(0.9,0.999)$, not $\mathrm{lr}$ (Lemma B1.4). The folklore value $1$ is exceeded whenever gradients grow, as they do at saddle escapes. Real runs reach $1.5$–$1.7$.
2. **Small displacement implies generalization (Proved).** The cleanest combination is a PAC-Bayes bound with a Gaussian prior **centred at the initialization**: the KL term is $\sum_g\|\theta_g-\theta_{0,g}\|^2/2\sigma_g^2$ (Theorem B3.2). For gradient flow, and for full-batch GD while the descent condition (D) holds, B1 bounds it by $t\,L_S(\theta_0)\max_g m_g/2c\sigma_g^2$, i.e. **linearly in training time** (Theorem B3.3(a)). This is the rigorous form of "the circuit cannot have grown big yet" for these dynamics: the number of nats by which the trained network differs from the initialization, at the resolution $\sigma$ at which the network is noise-robust, grows at most linearly in $t$. For the other optimizers the time-based KL bounds grow faster than linearly. For SGD, the measured-energy bound B3.3(b) is $t_KE_K$, and the energy $E_K$ itself grows under minibatch noise; the a priori SGD bound B3.3(d) needs smoothness and has a noise term quadratic in $t$. For Adam, B3.3(c) is quadratic in the number of steps.
3. **Norm-based uniform convergence is vacuous here.** I evaluated the usual capacity measures (Frobenius product, Golowich–Rakhlin–Shamir; $\ell_1$ path norm, Neyshabur–Tomioka–Srebro; spectral, Bartlett–Foster–Telgarsky) on the 49 final Adam networks of the sweep at $n\in\{256,2048,16384\}$. With the sharpest constants I could prove (Propositions B2.2, B2.3), the margin bounds are vacuous for all of them. For each network, the complexity term of the path-norm and Frobenius bounds at unit margin, $c=2\kappa\phi/\sqrt n$, is at least $\max(1,\text{mean positive train margin})$. This forces the bound above $1$ at every margin (Lemma B2.1a). The spectral bound's complexity at unit margin is above 600. The closest case is $x_1$ at $n=16384$, with $c_{\rm path}=1.46$. The complexity term exceeds $1$ already at the initialization's norms: there the path norm is about $(2/\pi)^{3/2}\sqrt{Nd}\approx 31$ and the Frobenius product about $\sqrt N\approx 11$. *(Heuristic reading: the norms are dominated by the random features present at μP initialization. Training can also lower them: the path norm of $x_1$ at $n=16384$ is $26$ after training against $32$ at initialization.)* Section 5.
4. **The data-dependent PAC-Bayes bound is non-vacuous at the largest sample size.** On the final Adam networks of the sweep, the bound on the *deterministic* network's test error is $0.26$–$0.56$ at $n=16384$ for the five targets with at most three relevant variables ($x_1$, AND$_3$, MAJ$_3$, $x_1x_2$, $x_1x_2x_3$). It is $0.55$–$1.0$ at $n=2048$ and vacuous at $n=256$. For targets with 4–6 relevant variables it is uninformative even at $n=16384$ ($0.79$–$1.0$) (Section 5.2). For our own runs on $x_1$ and MAJ$_3$ at $n=16384$, checkpoints after 100–300 steps of SGD or Adam give $0.10$–$0.34$. Each checkpoint's bound holds on its own. With a union bound over the 10 checkpoints evaluated per target, the best values are $0.11$ for $x_1$ and $0.23$ for MAJ$_3$ (Section 5.3).
5. **The time-based version works only during and just after the first escape.** Its rigorous forms are:
   - B3.3(a) for gradient flow, and for GD while (D) holds;
   - B3.3(b) for any optimizer, through the measured energy. It is a diagnostic rather than an answer, because it is always weaker than B3.2 with the measured displacement;
   - B3.3(c) for Adam, through Lemma B1.4;
   - B3.3(d) for SGD under smoothness. Smoothness fails for ReLU, so (d) is not evaluated.

   Along the runs of Section 5.3 the rigorous values for the Gibbs network are:
   - (a), GD at $\eta=0.02$: $0.59$–$0.77$ over steps 200–1000 ($t=4$–$20$), while the test error falls from 4.7% to 0.3%;
   - (b): $0.39$ for SGD on $x_1$ at step 20 ($t=4$; the test error is already $0.001$) and $0.46$ for GD at $\eta=0.2$ at step 20, then at least $0.9$ from step 100 ($t=20$) on in both; for GD at $\eta=0.02$, where (D) holds, $0.45$–$0.71$ over steps 200–1000;
   - (c), Adam: $0.44$–$0.56$ at step 50, $0.78$–$0.84$ at step 100, and vacuous by step 200.

   So the time-based bounds are informative ($<0.5$) only at the first checkpoints, up to gradient-flow time $t\approx4$: 20 steps at $\eta=0.2$, 200 steps at $\eta=0.02$, or 50 steps of Adam. Two discrete-time effects are measured:
   - in our full-batch GD run at the study's learning rate (MAJ$_3$, $n=2048$, seed 0, $\eta=0.2$), the descent condition holds only for the first 20 steps, and the run then oscillates;
   - the SGD energy $\sqrt{tE}$ overshoots the actual displacement by $43\times$.
6. **One-pass (online) training needs no capacity argument at all (Proved, Proposition B3.4).** For a window of steps fixed in advance, the mean progressive minibatch error bounds the mean test error of the iterates in the window, i.e. the test error of a randomly chosen iterate. The slack is $0.005$ over 1000 steps of batch 64. On one-pass Adam runs logged for this purpose, the bound is within $0.006$ of the measured value in every window (Section 4, after Proposition B3.4). This is the cumulative-mistake picture of the sibling project.
7. **Algorithmic stability (Hardt–Recht–Singer) does not apply** (Section 4.5). Its assumptions fail: smoothness, Lipschitzness, bounded loss, $c/t$ steps, and Adam is not SGM. **Mutual-information bounds** (Xu–Raginsky; the conditional version of Steinke–Zakynthinou) do apply to the 0-1 loss for any algorithm. But the only bounds on $I(S;W)$ and on the CMI available here make them vacuous. SGLD-type bounds need noise injected at every step.
8. **A naive circuit bound already beats all of this a posteriori (Proposition 6.1, Proved).** Read a small junta off the trained network, bound the junta by an Occam/Chernoff argument, and pay for the read-off with the disagreement measured on fresh *unlabeled* inputs. At $n=256$ this gives $0.04$–$0.12$ for $x_1$, $x_1x_2$, AND$_3$ and MAJ$_3$, and $0.16$ for the decision list, where every parameter-space bound is vacuous. At $n=2048$ it gives $0.01$–$0.10$ for the staircase, multiplexer, decision list and MAJ of parities, and $0.22$ (worst seed $0.46$) for $x_1x_2x_3x_4$. PAC-Bayes is vacuous at $n=2048$ on the three 4–6-variable targets on which it was evaluated. This is the bar for tasks A and C: an *a priori* (time- or move-based) argument that the network is close to a small circuit would turn it into a "short training implies generalization" theorem.

| result | statement (short) | status | vacuous at $n\le16384$? |
|---|---|---|---|
| B1.1 | GF: $\Vert \Delta\theta\Vert _{M^{-1}}\le\sqrt{t(L_0-L_t)}$, per-layer $\Vert \Delta\theta_g\Vert ^2\le m_g\,t\,E_g$ | Proved | — |
| B1.2 | GD: same with $1/c$ under the descent condition $L_{k+1}\le L_k-c\eta\Vert g_k\Vert _M^2$; any update: $\Vert \Delta\theta\Vert _{M^{-1}}\le\Lambda_K\le\sqrt{t_KE_K}$ | Proved | — |
| B1.3 | SGD, smooth loss: $\mathbb E\Vert \Delta\theta\Vert ^2_{M^{-1}}\le4tL_0+2\eta t\nu^2(1+\beta t)/B$ | Proved (assumptions fail for ReLU) | — |
| B1.4 | Adam: $\lvert\hat m_t\rvert/\sqrt{\hat v_t}\le C_t$, exact supremum, $C_\infty=7.27$ | Proved, tight | a priori bounds: yes, beyond $\sim10^2$ steps |
| B1.5 | worst-case gradient-norm bound (no smoothness) | Proved | yes, after $5\times10^{-5}$ steps |
| B2.1 | margin bound with union over norm and margin grids, measured norms allowed; Lemma B2.1a: vacuous at every margin when $c\ge\max(1,\bar m_+)$ | Proved (from Literature L1) | — |
| B2.2 | $\ell_1$ path norm: $\hat{\mathfrak R}_S\le\phi\sqrt{2\ln(8(d+1))/n}$, biases included | Proved | yes (all 49 trained nets evaluated; $c_{\rm path}\ge1.46$) |
| B2.3 | Frobenius: $\hat{\mathfrak R}_S\le P_F\sqrt{d+1}\,(1+\sqrt{4\ln 2})/\sqrt n$, $P_F=\Vert a\Vert (\Vert [W_1\,b_1]\Vert _F\Vert W_2\Vert _F+\Vert b_2\Vert )$ | Proved (cf. GRS Thm 1) | yes, even at the initialization's norms ($c_F\ge2.8$) |
| B2.4 | spectral (BFT), reference matrices = init | Literature + Proved assembly | yes: complexity at unit margin $7\times10^2$–$2\times10^4$ |
| B3.1 | a priori: GF/GD + Frobenius | Proved | yes, even at $t=0$ ($c_F=2.8$–$22$) |
| B3.2 | PAC-Bayes, prior at init, measured displacement, derandomized | Proved (from Literature L5) | **no at $n=16384$**; yes at $n=256$ |
| B3.3 | PAC-Bayes with a time-based KL: (a) $\le tL_0\max_gm_g/2c\sigma_g^2$ (GF; GD under (D)), linear in $t$; (b) $t_K\sum_gm_gE_{K,g}/2\sigma_g^2$ (any update, measured); (c) $\sum_gp_g(\eta m_gS_K)^2/2\sigma_g^2$ (Adam), quadratic in $K$; (d) $\lambda_\sigma V(t)$, for a mixture over SGD runs or divided by $\delta'$ with high probability (SGD, smooth loss), with a $t^2$ noise term | Proved | non-vacuous only for short runs (Section 5.3); (d) not evaluated |
| B3.4 | online: the progressive error over a window fixed in advance bounds the mean test error of the window's iterates | Proved | no: within $0.006$ of the measured value (one-pass Adam) |
| 4.5 | stability (HRS Thm 3.12); information theory (Xu–Raginsky, CMI, SGLD) | Literature | HRS does not apply; Xu–Raginsky and CMI apply but are vacuous; SGLD needs injected noise |
| 6.1 | read-off junta + Occam + unlabeled disagreement | Proved | **no, already at $n=256$** for small juntas |

## 1. Setting and notation

**Data.** $x$ is uniform on $\{-1,1\}^d$ with $d=30$, and $y=f^\star(x)\in\{-1,1\}$ for a fixed Boolean target. A training sample $S=((x_i,y_i))_{i\le n}$ is iid. Write $\hat x=(x,1)\in\{-1,1\}^d\times\{1\}$ and $D=d+1=31$, so $\|\hat x\|_2^2=D$ and $\|\hat x\|_\infty=1$.

**Network.** $f_\theta(x)=a\cdot\sigma(W_2\,\sigma(W_1x+b_1)+b_2)$ with $\sigma=\mathrm{ReLU}$, hidden widths $N=128$, $L=3$ weight layers. The parameter groups are
$g=1:(W_1,b_1)$ with $p_1=N(d+1)=3968$ entries, $g=2:(W_2,b_2)$ with $p_2=N(N+1)=16512$, and $g=3:a$ with $p_3=N=128$; in total $p=20608$.
The μP initialization $\theta_0$ is $W_1\sim\mathcal N(0,1/d)$, $W_2\sim\mathcal N(0,1/N)$, $a\sim\mathcal N(0,1/N^2)$, biases $0$. It is drawn independently of $S$.

**Losses.** $L_S(\theta)=\frac1n\sum_i\frac12(f_\theta(x_i)-y_i)^2$ and $L_0:=L_S(\theta_0)$ ($\approx0.5$, since $f_{\theta_0}$ is small). The test error is $R(\theta)=\Pr[y f_\theta(x)\le0]$. For a margin $\gamma>0$, the ramp is $\varphi_\gamma(u)=\min(1,\max(0,1-u/\gamma))$, and the empirical margin loss is $\hat R_\gamma(\theta)=\frac1n\sum_i\varphi_\gamma(y_if_\theta(x_i))\le\frac1n\#\{i:y_if_\theta(x_i)<\gamma\}$.

**Optimizers.** All updates have the form $\theta_{k+1}=\theta_k-\eta Mu_k$, where $M=\mathrm{diag}(m_g)$ holds the per-group multipliers:
- **SGD** (lr $\eta=0.2$): $u_k=\hat g_k$ is the gradient of the loss on a minibatch of $B=64$ indices drawn uniformly with replacement from $S$. Multipliers $m_1=N/64=2$, $m_2=1$, $m_3=64/N=\frac12$.
- **Full-batch GD:** $u_k=\nabla L_S(\theta_k)$, same multipliers.
- **Adam** (lr $\eta=10^{-3}$): $u_k=\hat m_k/(\sqrt{\hat v_k}+\epsilon)$. In the study's code the multipliers are $m_1=1$ and $m_2=m_3=64/N=\frac12$.
- **Online protocol:** a fresh minibatch at every step, one pass.

Time is $t_K=\eta K$. Norms: $\|v\|_M^2=v^\top Mv$ and $\|v\|_{M^{-1}}^2=v^\top M^{-1}v$, with Cauchy–Schwarz pairing $\langle u,v\rangle\le\|u\|_M\|v\|_{M^{-1}}$.

**Rademacher complexity.** $\hat{\mathfrak R}_S(\mathcal F)=\mathbb E_\epsilon\sup_{f\in\mathcal F}\frac1n\sum_i\epsilon_if(x_i)$ (no absolute value), and $\mathfrak R_n(\mathcal F)=\mathbb E_S\hat{\mathfrak R}_S(\mathcal F)$.

**Bias augmentation.** For $c\ge0$ put
$$\hat W_1=\begin{pmatrix}W_1&b_1\\0&c\end{pmatrix}\in\mathbb R^{(N+1)\times D},\qquad \hat W_2=\begin{pmatrix}W_2& b_2/c\end{pmatrix}\in\mathbb R^{N\times(N+1)} .$$
Then $f_\theta(x)=a\cdot\sigma(\hat W_2\,\sigma(\hat W_1\hat x))$, because the extra hidden unit is $\sigma(c)=c$. So $f_\theta$ is a **bias-free** 3-layer ReLU network on $\hat x$. (For $b_2=0$ take $c=0$ and drop the last column.)

## 2. B1: displacement from initialization

### Theorem B1.1 (gradient flow, preconditioned; Proved)

Let $\theta:[0,t]\to\mathbb R^p$ be absolutely continuous with $\theta'(s)=-M\,v(s)$ for a.e. $s$, where $v(s)$ is a (Clarke) subgradient of $L_S$ at $\theta(s)$. Assume the chain rule $\frac{d}{ds}L_S(\theta(s))=\langle v(s),\theta'(s)\rangle$ for a.e. $s$.

*The chain rule is automatic for $C^1$ losses (smoothed activations). For ReLU networks with square loss, $L_S$ is semialgebraic, and the chain rule holds along every absolutely continuous curve for every selection of Clarke subgradients (Davis–Drusvyatskiy–Kakade–Lee, FoCM 2020, Theorem 5.8; from memory).*

Define the per-group dissipated energy $E_g(t)=\int_0^t m_g\|v_g(s)\|^2ds$. Then:

1. $\sum_gE_g(t)=L_S(\theta(0))-L_S(\theta(t))$;
2. $\|\theta(t)-\theta(0)\|_{M^{-1}}\le\Lambda(t):=\int_0^t\|\theta'(s)\|_{M^{-1}}ds\le\sqrt{t\,(L_S(\theta(0))-L_S(\theta(t)))}\le\sqrt{t\,L_0}$;
3. for every group, $\|\theta_g(t)-\theta_g(0)\|_2^2\le m_g\,t\,E_g(t)$. Hence $\|\theta_g(t)-\theta_g(0)\|_2\le\sqrt{m_g\,t\,L_0}$, and the vector $\big(\|\theta_g(t)-\theta_g(0)\|^2/(m_gt)\big)_g$ has sum at most $L_0$.

*Proof.* $\|\theta'\|_{M^{-1}}^2=(Mv)^\top M^{-1}(Mv)=v^\top Mv=\sum_gm_g\|v_g\|^2$. The chain rule gives $\frac{d}{ds}L_S(\theta)=-v^\top Mv$; integrating proves 1. For 2, $\|\theta(t)-\theta(0)\|_{M^{-1}}\le\int_0^t\|\theta'\|_{M^{-1}}$ by the triangle inequality for Bochner integrals; then Cauchy–Schwarz in $s$ gives $\int_0^t\|\theta'\|\le\sqrt t\,(\int_0^t\|\theta'\|^2)^{1/2}$, and the last integral is $L_S(\theta(0))-L_S(\theta(t))$ by 1. For 3, $\|\theta_g(t)-\theta_g(0)\|\le\int_0^tm_g\|v_g\|\le\sqrt t\,(\int_0^tm_g^2\|v_g\|^2)^{1/2}=\sqrt{t\,m_gE_g(t)}$. $\square$

**Concrete values** (SGD multipliers, $L_0=0.5$). After $K$ steps of the corresponding flow, $t=0.2K$, the bound is $\sum_g\|\Delta_g\|^2/m_g\le 0.1K$. At $K=20000$ this allows $\|\Delta W_1\|_F\le63$, $\|\Delta W_2\|_F\le45$ and $\|\Delta a\|\le32$, against initial norms of $11.3$, $11.3$ and $0.09$. At $K=500$ it allows $10$, $7.1$ and $5$.

**Remark (plateaus; Heuristic).** The bound is tight only when the speed $\|\theta'\|_{M^{-1}}$ is constant. In saddle-to-saddle dynamics (the [README](../README.md)'s model), almost all of the time is spent on plateaus at very low speed, and the displacement is accumulated in short escapes. If escape $j$ lasts $\tau_j$ and dissipates $\Delta L_j$, then $\Lambda\approx\sum_j\sqrt{\tau_j\Delta L_j}$, which does not depend on the plateau lengths. Meanwhile $\sqrt{tL_0}$ grows with them. In the small-initialization limit the first escape takes $t\approx\alpha^{-1}$ at depth 3, so **any bound that uses only $t$ degrades without limit as $\alpha\to0$**, even though the function learned does not change. The measured displacement, or the path length $\Lambda$, is the right quantity. Time is only an upper bound for it.

### Corollary B1.2 (discrete time; Proved)

**(a) Any update.** For any vectors $u_k$, the iterates $\theta_{k+1}=\theta_k-\eta Mu_k$ satisfy
$$\|\theta_K-\theta_0\|_{M^{-1}}\le\Lambda_K:=\eta\sum_{k<K}\|u_k\|_M\le\sqrt{t_K\,E_K},\qquad E_K:=\eta\sum_{k<K}\|u_k\|_M^2 .$$
The same holds per group: $\|\theta_{K,g}-\theta_{0,g}\|^2\le m_g\,t_K\,E_{K,g}$ with $E_{K,g}=\eta\,m_g\sum_k\|u_{k,g}\|^2$.
*Proof:* the triangle inequality and Cauchy–Schwarz in $k$. This covers GD, SGD and clipped variants. $\Lambda_K$ and $E_K$ are measurable along a run.

**(b) GD under a descent condition.** Suppose that for all $k<K$
$$L_S(\theta_{k+1})\le L_S(\theta_k)-c\,\eta\,\|\nabla L_S(\theta_k)\|_M^2\qquad(\text{descent with constant }c>0). \tag{D}$$
Then $E_K\le(L_0-L_S(\theta_K))/c$, so $\|\theta_K-\theta_0\|_{M^{-1}}\le\sqrt{t_K(L_0-L_S(\theta_K))/c}$.

**When (D) holds.** Suppose $L_S$ is differentiable on the segment $[\theta_k,\theta_{k+1}]$ with $\|\nabla L_S(u)-\nabla L_S(w)\|_M\le\beta\|u-w\|_{M^{-1}}$ there (β-smoothness in the $M$-geometry). Then (D) holds with $c=1-\beta\eta/2$, which is positive iff $\eta<2/\beta$.
*Proof:* write $\theta_{k+1}=\theta_k-\eta Mg$. Then
$$L_S(\theta_{k+1})-L_S(\theta_k)=-\eta\|g\|_M^2-\int_0^1\langle\nabla L_S(\theta_k-s\eta Mg)-g,\ \eta Mg\rangle ds\le-\eta\|g\|_M^2+\int_0^1\beta s\eta\|g\|_M\cdot\eta\|g\|_M\,ds,$$
and the last integral is $\beta\eta^2\|g\|_M^2/2$. $\square$

**ReLU.** $L_S$ is piecewise polynomial, and its gradient jumps whenever a hidden pre-activation crosses $0$ at a training input. So no global $\beta$ exists, and (D) is an assumption about the trajectory. It can be **checked a posteriori**, since every quantity in it is recorded during training. Our full-batch run (Section 5.3) records the smallest ratio $(L_k-L_{k+1})/(\eta\|g_k\|_M^2)$ over all steps.

**Smoothed activations (Heuristic; not carried out).** With a smooth activation, $\beta=\beta(R)$ is finite on each ball of radius $R$ around $\theta_0$. A bootstrap should make (b) unconditional for $\eta\le1/\beta(R)$ with $R\approx\sqrt{tL_0/c}$: show inductively that the iterates stay in the ball on which $\beta(R)$ is valid. I have not written out this induction. In any case, worst-case estimates of $\beta(R)$ are products of layer norms times $\sup\|\hat x\|^2$, so the step size it would allow is orders of magnitude below $0.2$ (compare Remark B1.5).

### Proposition B1.3 (SGD in expectation, smooth case; Proved)

Assume:
- $L_S$ is β-smooth in the $M$-geometry on a convex set containing all iterates, and $\eta\le1/\beta$;
- $\hat g_k$ is the average of $B$ per-example gradients at indices drawn uniformly with replacement and independently of the past, so that $\mathbb E[\hat g_k\mid\mathcal F_k]=g_k:=\nabla L_S(\theta_k)$;
- $\mathbb E[\|\hat g_k-g_k\|_M^2\mid\mathcal F_k]\le\nu^2/B$, where $\nu^2\ge\sup_\theta\frac1n\sum_i\|\nabla\ell_i(\theta)-\nabla L_S(\theta)\|_M^2$. (Revision 2 writes $\nu$ for this gradient-noise constant, to keep $\sigma$ for the PAC-Bayes noise levels.)

Then
$$\mathbb E\|\theta_K-\theta_0\|_{M^{-1}}^2\le4t\,(L_0-\mathbb EL_S(\theta_K))+\frac{2\eta t\nu^2(1+\beta t)}{B},\qquad t=\eta K.$$

*Proof.* Write $\xi_k=\hat g_k-g_k$ and $\theta_K-\theta_0=-\eta\sum_kMg_k-\eta\sum_kM\xi_k$, so $\|\Delta\|^2\le2\|\eta\sum Mg_k\|^2+2\|\eta\sum M\xi_k\|^2$ (both norms $M^{-1}$).
- **Noise part.** The $\xi_k$ are martingale differences, so the cross terms vanish in expectation: $\mathbb E\|\eta\sum_kM\xi_k\|^2_{M^{-1}}=\eta^2\sum_k\mathbb E\|\xi_k\|_M^2\le\eta t\nu^2/B$.
- **Drift part.** By Cauchy–Schwarz, $\|\eta\sum Mg_k\|_{M^{-1}}^2\le t\cdot\eta\sum_k\|g_k\|_M^2$.
- **Descent lemma.** $L_S(\theta_{k+1})\le L_S(\theta_k)-\eta\langle g_k,M\hat g_k\rangle+\frac{\beta\eta^2}2\|\hat g_k\|_M^2$. Taking conditional expectations, $\eta(1-\frac{\beta\eta}2)\|g_k\|_M^2\le L_S(\theta_k)-\mathbb E[L_S(\theta_{k+1})\mid\mathcal F_k]+\frac{\beta\eta^2\nu^2}{2B}$. Summing, and using $1-\beta\eta/2\ge1/2$, gives $\eta\sum_k\mathbb E\|g_k\|_M^2\le2(L_0-\mathbb EL_S(\theta_K))+\beta\eta t\nu^2/B$.

Combining the three gives the claim. $\square$

This is weaker than B1.1 in two ways: the factor is $4$ instead of $1$, and there is an additive noise term $2\eta t\nu^2/B+2\eta\beta\nu^2t^2/B$, which is quadratic in $t$ at fixed $\eta$. The noise term vanishes as $\eta\to0$ at fixed $t$. For ReLU networks the assumptions fail globally, as in B1.2. In practice one uses the measurable statement B1.2(a). Theorem B3.3(d) turns B1.3 into an a priori PAC-Bayes bound for SGD.

### Lemma B1.4 (Adam: the exact worst-case step; Proved)

Let $0\le\beta_1<1$ and $0<\beta_2<1$ with $r:=\beta_1^2/\beta_2<1$. Coordinatewise, let $m_t=\beta_1m_{t-1}+(1-\beta_1)g_t$ and $v_t=\beta_2v_{t-1}+(1-\beta_2)g_t^2$, with $m_0=v_0=0$, $\hat m_t=m_t/(1-\beta_1^t)$ and $\hat v_t=v_t/(1-\beta_2^t)$. Then for every $t\ge1$ and every gradient sequence,
$$\frac{|\hat m_t|}{\sqrt{\hat v_t}}\le C_t:=\frac{1-\beta_1}{1-\beta_1^t}\sqrt{\frac{1-\beta_2^t}{1-\beta_2}}\sqrt{\frac{1-r^t}{1-r}}$$
(if $v_t=0$ then $m_t=0$). Equality holds for $g_s=c\,(\beta_2/\beta_1)^s$, the same sequence for every $t$. So $\sup_{g}\sum_{t\le T}|\hat m_t|/\sqrt{\hat v_t}=\sum_{t\le T}C_t$.

*Proof.* $m_t=(1-\beta_1)\sum_{s\le t}\beta_1^{t-s}g_s$ and $v_t=(1-\beta_2)\sum_{s\le t}\beta_2^{t-s}g_s^2$. Write $\beta_1^{t-s}|g_s|=(\beta_1/\sqrt{\beta_2})^{t-s}\cdot\sqrt{\beta_2}^{\,t-s}|g_s|$ and apply Cauchy–Schwarz:
$$|m_t|\le(1-\beta_1)\Big(\sum_{j<t}r^j\Big)^{1/2}\Big(\sum_s\beta_2^{t-s}g_s^2\Big)^{1/2}=(1-\beta_1)\sqrt{\tfrac{1-r^t}{1-r}}\sqrt{\tfrac{v_t}{1-\beta_2}} .$$
Then apply the bias corrections. Equality in Cauchy–Schwarz holds iff $\sqrt{\beta_2}^{\,t-s}|g_s|\propto(\beta_1/\sqrt{\beta_2})^{t-s}$ with all signs equal, i.e. $|g_s|\propto(\beta_2/\beta_1)^s$. $\square$

**Values for $(\beta_1,\beta_2)=(0.9,0.999)$** ([`checks/adam_ratio.out`](checks/adam_ratio.out); a numerical search finds nothing above $C_t$):
- $C_1=1$, $C_{10}=1.04$, $C_{100}=2.24$ and $C_\infty=(1-\beta_1)/\sqrt{(1-\beta_2)(1-r)}=7.27$.
- $S_T:=\sum_{t\le T}C_t$ is $10.2$, $161$, $4229$ and $140958\approx7.05\,T$ for $T=10$, $100$, $1000$ and $20000$.

**Consequences (Proved).** Since $\epsilon>0$ only shrinks steps, every coordinate of group $g$ moves by at most $\eta m_gS_T$ in $T$ steps:
$$\|\Delta\theta_g\|_\infty\le\eta\,m_g\,S_T,\qquad\|\Delta\theta_g\|_2\le\sqrt{p_g}\,\eta\,m_g\,S_T .$$
For the study ($\eta=10^{-3}$, $T=20000$) this gives $\|\Delta W_1\|_F\le 8.9\times10^3$, $\|\Delta W_2\|_F\le9.1\times10^3$ and $\|\Delta a\|\le797$. The measured values are $4$–$11$, $4$–$12$ and $0.15$–$1$ (Section 5). Even the folklore value $C_t\equiv1$ would give $\|\Delta W_1\|_F\le1260$.

**What is right and wrong in the folklore.** Kingma–Ba (ICLR 2015, Section 2.1; from memory) state $|\Delta_t|\lesssim\mathrm{lr}$, with the value $(1-\beta_1)/\sqrt{1-\beta_2}=3.16$ "in the most severe case of sparsity". Neither is a worst-case bound. The worst case is $C_t$, which tends to $7.27$. With constant gradients the ratio is exactly $1$. But in an escape from a plateau, where gradients grow geometrically, the ratio exceeds $1$: a plateau followed by $5\%$ growth per step gives $3.45$. That is the regime of the circuit-growth model. (The same Cauchy–Schwarz bound appears in Adam convergence analyses, e.g. Défossez–Bottou–Bach–Usunier, TMLR 2022; from memory.) **Time-based displacement bounds for Adam are vacuous beyond a few hundred steps at these sizes.** For Adam, only measured displacements are useful.

### Remark B1.5 (the trivial bound from gradient norms; Proved, numerically useless)

No smoothness is needed for the following, and it covers SGD or GD with any minibatches. Let $G(u)$ bound the per-example gradient $M$-norm over the $M^{-1}$-ball of radius $u$ around $\theta_0$. Then $u_k:=\|\theta_k-\theta_0\|_{M^{-1}}$ satisfies $u_{k+1}\le u_k+\eta G(u_k)$, and so $u_k\le U(\eta k)$, where $U'=G(U)$ and $U(0)=0$ (induction, since $G$ is increasing).

Explicitly, with $F_1=\|[W_1\,b_1]\|_F$, $F_2=\|[W_2\,b_2]\|_F$ and $A=\|a\|$, each bounded by its initial value plus $\sqrt{m_g}\,u$:
- $\|h_1\|\le F_1\sqrt D$ and $\|h_2\|\le F_2\sqrt{\|h_1\|^2+1}$;
- $|f-y|\le1+A\|h_2\|$;
- $\|\nabla_\theta f\|_M^2\le m_3\|h_2\|^2+m_2A^2(\|h_1\|^2+1)+m_1F_2^2A^2D$.

At the study's initialization this gives $G(0)\approx3.1\times10^4$. One SGD step can therefore move $\theta$ by $6\times10^3$ in this bound, and $U$ blows up at $t^*\approx10^{-5}$, i.e. $5\times10^{-5}$ steps ([`checks/trivial_gronwall.out`](checks/trivial_gronwall.out)). The cause is that worst-case activation norms ($\|h_2\|\le708$) exceed typical ones ($\approx6$) by two orders of magnitude.

## 3. B2: capacity bounds

### L1 (Literature: margin bound)

Mohri–Rostamizadeh–Talwalkar, *Foundations of Machine Learning*, 2nd ed. (2018), Theorem 5.8; Koltchinskii–Panchenko, Ann. Statist. 2002 (from memory). Let $\mathcal H$ be a class of real functions, $\rho>0$ and $\delta\in(0,1)$. With probability at least $1-\delta$, for all $h\in\mathcal H$,
$$R(h)\le\hat R_{\rho}(h)+\frac2\rho\,\mathfrak R_n(\mathcal H)+\sqrt{\frac{\ln(1/\delta)}{2n}} .$$
Here $R(h)=\Pr[yh(x)\le0]$, and $\hat R_\rho$ is the empirical ramp loss. With $\hat{\mathfrak R}_S$ in place of $\mathfrak R_n$ the last term becomes $3\sqrt{\ln(2/\delta)/2n}$.

### Theorem B2.1 (margin bound with measured complexity; Proved from L1)

Let $C(\theta)\ge0$ be a complexity functional, and let $\kappa>0$ be such that $\mathfrak R_n(\{f_\theta:C(\theta)\le\phi\})\le\kappa\phi/\sqrt n$ for all $\phi>0$. Fix a grid ratio $q>1$, a base $\phi_0>0$, a largest margin $\gamma_{\max}$, and $\delta$. Put $\gamma_k=\gamma_{\max}q^{-k}$, $j(\theta)=\min\{j\ge0:\phi_0q^j\ge C(\theta)\}$ and $\delta_{jk}=\delta/((j+1)(j+2)(k+1)(k+2))$. With probability at least $1-\delta$, **simultaneously for all $\theta$ and all $k\ge0$**,
$$R(\theta)\le\hat R_{\gamma_k}(\theta)+\frac{2\kappa\,\phi_0q^{j(\theta)}}{\gamma_k\sqrt n}+\sqrt{\frac{\ln(1/\delta_{j(\theta)k})}{2n}},\qquad\phi_0q^{j(\theta)}\le q\max(C(\theta),\phi_0).$$
*Proof.* Apply L1 to $\mathcal H_j=\{C\le\phi_0q^j\}$ with $\rho=\gamma_k$ and confidence $\delta_{jk}$. Since $\sum_{j\ge0}\frac1{(j+1)(j+2)}=1$, the union bound costs $\sum_{j,k}\delta_{jk}=\delta$. $\square$

Because the statement is uniform in $\theta$, $C(\theta)$ may be **measured after training**, or replaced by any upper bound on it, data-dependent ones included. In Section 5, $q=1.1$, $\phi_0=1$, $\gamma_{\max}=4$ and $\delta=0.05$, and the bound is minimized over $k$.

### Lemma B2.1a (when B2.1 is vacuous; Proved)

Write $c(\theta)=2\kappa\,\phi_0q^{j(\theta)}/\sqrt n$ for the complexity term of B2.1 at unit margin, and $\bar m_+(\theta)=\frac1n\sum_i(y_if_\theta(x_i))_+$ for the mean positive train margin. If $c(\theta)\ge\max(1,\bar m_+(\theta))$, then the right side of B2.1 is at least $1$ for every $k$, whatever $\gamma_{\max}$ is.

*Proof.* The ramp satisfies $\varphi_\gamma(u)\ge1-u_+/\gamma$ for every $u$: for $u<0$ both sides are at most $1=\varphi_\gamma(u)$, for $0\le u\le\gamma$ they are equal, and for $u>\gamma$ the right side is negative. Hence $\hat R_\gamma\ge1-\bar m_+/\gamma$. If $\gamma_k\le1$, the complexity term alone is $c/\gamma_k\ge c\ge1$. If $\gamma_k>1$, then $\hat R_{\gamma_k}+c/\gamma_k\ge1+(c-\bar m_+)/\gamma_k\ge1$. The confidence term is positive. $\square$

All the trained networks of Section 5 have $\bar m_+$ between $0.99$ and $1.01$ (square loss on $\pm1$ labels), so for them the bound is vacuous as soon as $c\ge1.01$. When $c<1$ and every train margin is at least some grid margin $\gamma_k$, the bound at that $k$ is $c/\gamma_k$ plus the confidence term. When the bound is vacuous, its minimized value is not informative. If $c\ge\bar m_+$ and $\gamma_{\max}\ge\max_iy_if_\theta(x_i)$ (the largest train margin), the minimum sits at the grid edge $\gamma=\gamma_{\max}$. Indeed, for $\gamma$ at least the largest margin, $\hat R_\gamma=1-\bar m_+/\gamma$ exactly, so the bound at $k=0$ equals $1+(c-\bar m_+)/\gamma_{\max}+\mathrm{conf}_{j,0}$. By the proof above, the bound at every $k$ is at least $1+(c-\bar m_+)/\gamma_k+\mathrm{conf}_{j,k}$, which is no smaller, since $c\ge\bar m_+$, $\gamma_k\le\gamma_{\max}$ and $\mathrm{conf}_{j,k}\ge\mathrm{conf}_{j,0}$. Here $\mathrm{conf}_{j,k}=\sqrt{\ln(1/\delta_{jk})/2n}$ is the confidence term of B2.1, so $\mathrm{conf}_{j,0}=\sqrt{\ln(2(j+1)(j+2)/\delta)/2n}$. As $\gamma_{\max}$ grows, the minimum therefore tends to $1+\mathrm{conf}_{j,0}$ from above, not to $1$ ([`checks/referee_B_r2.out`](checks/referee_B_r2.out), part 1). **Section 5 therefore reports $c$, not the minimized bound.**

### Lemma B2.0 (comparison inequality for convex increasing functions; Proved)

*Literature: Ledoux–Talagrand, Probability in Banach Spaces (1991), Theorem 4.12 and its proof; from memory.*

Let $G:\mathbb R\to\mathbb R$ be convex and increasing, $T\subset\mathbb R^n$ bounded, and $\psi_i:\mathbb R\to\mathbb R$ 1-Lipschitz with $\psi_i(0)=0$. Then
$$\mathbb E\,G\Big(\sup_{t\in T}\sum_i\epsilon_i\psi_i(t_i)\Big)\le\mathbb E\,G\Big(\sup_{t\in T}\sum_i\epsilon_it_i\Big).$$
(The condition $\psi_i(0)=0$ is needed: for $n=1$, $T=\{0\}$, $\psi(u)=u+5$ and $G=\exp$, the left side is $\cosh 5>1$. A brute-force check over 3000 random instances is in [`checks/contraction_check.out`](checks/contraction_check.out).)

*Proof.* Replace one coordinate at a time. Conditioning on the other signs, it suffices to show that for any function $A$ on $T$ and any 1-Lipschitz $\psi$ with $\psi(0)=0$,
$$G\big(\textstyle\sup_t[A(t)+\psi(t_1)]\big)+G\big(\sup_t[A(t)-\psi(t_1)]\big)\le G\big(\sup_t[A(t)+t_1]\big)+G\big(\sup_t[A(t)-t_1]\big).$$
Pick $t,s\in T$ that attain the two left suprema up to $\varepsilon$ (then let $\varepsilon\to0$; $G$ is continuous). Let $a=A(t)+\psi(t_1)$ and $b=A(s)-\psi(s_1)$, and let $c_1$, $c_2$ be the two right-hand suprema.
- **Sum.** $a+b\le A(t)+A(s)+|t_1-s_1|$, which is at most $c_1+c_2$: use $(A(t)+t_1)+(A(s)-s_1)$ if $t_1\ge s_1$, and $(A(s)+s_1)+(A(t)-t_1)$ otherwise.
- **Maximum.** $|\psi(u)|\le|u|$ gives $a\le A(t)+|t_1|\le\max(c_1,c_2)$, and likewise for $b$.
- **Majorization.** For convex increasing $G$, if $\max(a,b)\le P:=\max(c_1,c_2)$ and $a+b\le c_1+c_2=P+Q$, then $G(a)+G(b)\le G(P)+G(Q)$. Proof: let $a\ge b$. If $b\le Q$, use monotonicity termwise. Otherwise $Q<b\le a\le P$; put $b'=P+Q-a\in[Q,P]$, so $b\le b'$. Then $G(a)+G(b')\le G(P)+G(Q)$ by convexity, because $(a,b')$ and $(P,Q)$ have the same sum and $a,b'\in[Q,P]$. $\square$

### Proposition B2.2 ($\ell_1$ path norm with biases; Proved)

Define
$$\phi_1(\theta)=\sum_k|a_k|\Big(\sum_j|W_{2,kj}|\big(\textstyle\sum_i|W_{1,ji}|+|b_{1,j}|\big)+|b_{2,k}|\Big)$$
(the study's `path1`; a bias counts as an input equal to $1$). Let $\mathcal F_\phi$ be the set of networks $f_\theta$ **of any hidden widths** with $\phi_1(\theta)\le\phi$. Then for every sample $S$ in $[-1,1]^d$,
$$\hat{\mathfrak R}_S(\mathcal F_\phi)\le\phi\sqrt{\frac{2\ln(8D)}n},\qquad D=d+1 .$$
For $d=30$ the constant is $\kappa_{\rm path}=\sqrt{2\ln248}=3.321$. With $L$ weight layers the same proof gives $\phi\sqrt{2\ln(2^LD)/n}$. Also $|f_\theta(x)|\le\phi_1(\theta)$ on $[-1,1]^d$.

*Proof.*
1. **Rebalance** (positive homogeneity). Use the augmentation of Section 1. Divide each first-layer unit's incoming vector $(W_{1,j},b_{1,j})$ by its $\ell_1$ norm $r_j$ and multiply column $j$ of $W_2$ by $r_j$; the constant unit then has value $1$ and outgoing weights $b_2$. Next divide each second-layer unit's incoming vector by its $\ell_1$ norm $s_k=\sum_j|W_{2,kj}|r_j+|b_{2,k}|$ and multiply $a_k$ by $s_k$. The function is unchanged, every hidden unit has incoming $\ell_1$ norm at most $1$, and $\sum_k|a'_k|=\phi_1(\theta)$. ([`checks/nnbounds.py`](checks/nnbounds.py) verifies this identity numerically.) So $f=\sum_ka'_k\sigma(u_k\cdot h(x))$, where $h_j(x)=\sigma(v_j\cdot\hat x)$ and $\|u_k\|_1,\|v_j\|_1\le1$.
2. **Reduce to one unit.** $\sum_i\epsilon_if(x_i)\le\phi\sup_{u,V}|Z(u,V)|$ with $Z=\sum_i\epsilon_i\sigma(u\cdot h(x_i))$.
3. **Peel with exponential moments** (the Golowich–Rakhlin–Shamir device), for $\lambda>0$:
   - $\mathbb E e^{\lambda\phi\sup|Z|}\le\mathbb Ee^{\lambda\phi\sup Z}+\mathbb Ee^{\lambda\phi\sup(-Z)}=2\,\mathbb Ee^{\lambda\phi\sup Z}$, because $-\epsilon\overset d=\epsilon$;
   - $\le2\,\mathbb Ee^{\lambda\phi\sup_{u,V}\sum_i\epsilon_iu\cdot h(x_i)}$ by Lemma B2.0;
   - $=2\,\mathbb Ee^{\lambda\phi\sup_V\|\sum_i\epsilon_ih(x_i)\|_\infty}$, by $\ell_1$–$\ell_\infty$ duality;
   - $\le2\,\mathbb Ee^{\lambda\phi\sup_{\|v\|_1\le1}|\sum_i\epsilon_i\sigma(v\cdot\hat x_i)|}$;
   - $\le4\,\mathbb Ee^{\lambda\phi\|\sum_i\epsilon_i\hat x_i\|_\infty}$, repeating the first two steps;
   - $\le4\cdot2D\,e^{\lambda^2\phi^2n/2}$, by Hoeffding's lemma for each of the $2D$ signed coordinate sums ($|\hat x_{ij}|\le1$).
4. **Optimize.** By Jensen, $n\hat{\mathfrak R}_S\le\frac{\ln(8D)}\lambda+\frac{\lambda\phi^2n}2$; take $\lambda=\sqrt{2\ln(8D)/(\phi^2n)}$. The bound $|f|\le\phi_1$ follows from the rebalanced form. $\square$

**Sharpness of the constant (Proved / Numerical).** The class $\{\phi_1\le1\}$ contains $\pm x_j/2=\pm\frac12(\sigma(\sigma(x_j))-\sigma(\sigma(-x_j)))$ and $\pm\frac12$. Hence $\hat{\mathfrak R}_S\ge\mathbb E\max_j|\sum_i\epsilon_i\hat x_{ij}|/2n\approx1.17/\sqrt n$ on uniform samples ([`checks/rademacher_lower.out`](checks/rademacher_lower.out)), so $\kappa_{\rm path}=3.32$ is within a factor $2.8$ of the truth. The same witnesses, with $\pm w\cdot x$ for $\|w\|_2\le1$, put $\kappa_F$ within a factor of about $7.5$ (the class $\{P_F\le1\}$ contains $\pm w\cdot x/2\sqrt2$).

**Does the constant decide vacuity?** For most networks of Section 5 it does not: $c_{\rm path}$ would stay above $1$ even if $\kappa_{\rm path}$ were at the lower estimate $1.17$. For the borderline cases it does. For $x_1$, AND$_3$ and $x_1x_2$ at $n=16384$, and for one of the three MAJ$_3$ networks there, $c_{\rm path}$ would fall below $1$ with $\kappa=1.17$ (for $x_1$, from $1.46$ to $0.51$). There the constant and the proof technique, not only the measured norms, decide whether the path-norm bound is vacuous ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 1).

**Comparison (Literature).** Neyshabur–Tomioka–Srebro (COLT 2015) bound the same class by a constant of order $2^L\sqrt{\ln(2D)}$, i.e. exponential in depth (Corollary 7 there; constant checked only against a secondary source). For $L=3$ that is about $5\times$ larger than $\kappa_{\rm path}$. Gonon–Brisebarre–Riccietti–Gribonval (ICLR 2024) prove path-norm bounds for general DAG ReLU networks with biases and polynomial depth dependence (constants not checked).

### Proposition B2.3 (Frobenius product with biases; Proved)

Put $P_F(\theta)=\|a\|_2\big(\|[W_1\ b_1]\|_F\|W_2\|_F+\|b_2\|_2\big)$ and $\mathcal F_P=\{f_\theta:P_F(\theta)\le P\}$ (any widths). For every $S$ in $\{-1,1\}^d$,
$$\hat{\mathfrak R}_S(\mathcal F_P)\le P\,\sqrt D\,\big(1+\sqrt{2(L-1)\ln2}\big)/\sqrt n=\kappa_FP/\sqrt n,\qquad\kappa_F=\sqrt{31}\,(1+\sqrt{4\ln2})=14.84 .$$

*Literature: Golowich–Rakhlin–Shamir (COLT 2018; Information and Inference 2020), Theorem 1. For bias-free depth-$L$ networks with 1-Lipschitz positive-homogeneous activations and $\|W_j\|_F\le M_F(j)$, they prove $\hat{\mathfrak R}_S\le\frac1n\prod_jM_F(j)\,(\sqrt{2L\ln2}+1)\sqrt{\sum_i\|x_i\|^2}$. The form was checked against secondary sources. With $L=3$ their constant would be $16.92$ in place of $14.84$.*

*Proof.*
1. **Augment.** In the augmentation, $\|\hat W_1\|_F^2=\|[W_1\,b_1]\|_F^2+c^2$ and $\|\hat W_2\|_F^2=\|W_2\|_F^2+\|b_2\|^2/c^2$. Minimizing $\|a\|\,\|\hat W_1\|_F\|\hat W_2\|_F$ over $c$ (at $c^2=\|[W_1 b_1]\|_F\|b_2\|/\|W_2\|_F$) gives exactly $P_F(\theta)$, as checked numerically in `nnbounds.py`.
2. **Rescale.** By homogeneity, $f\in\mathcal F_P$ has a representation with $\|\hat W_1\|_F,\|\hat W_2\|_F\le1$ and $\|a\|\le P$. Hence $\sum_i\epsilon_if(x_i)\le P\sup\|\sum_i\epsilon_i\sigma(\hat W_2h_i)\|_2$, where $h_i=\sigma(\hat W_1\hat x_i)$.
3. **Peeling identity.** For $\|W\|_F\le1$, $\|\sum_i\epsilon_i\sigma(Wh_i)\|^2=\sum_k\|w_k\|^2(\sum_i\epsilon_i\sigma(\bar w_k\cdot h_i))^2\le\sup_{\|w\|\le1}(\sum_i\epsilon_i\sigma(w\cdot h_i))^2$, where $\bar w_k=w_k/\|w_k\|$.
4. **Peel.** As in B2.2: $\mathbb Ee^{\lambda P\sup|\cdot|}\le2\,\mathbb Ee^{\lambda P\sup\|\sum\epsilon_ih_i\|}$, and after two layers $\le4\,\mathbb Ee^{\lambda P Z}$ with $Z=\|\sum_i\epsilon_i\hat x_i\|$.
5. **Concentrate.** $Z$ has bounded differences $2\|\hat x_i\|$. McDiarmid's inequality in moment-generating form (Boucheron–Lugosi–Massart 2013, Theorem 6.2) gives $\mathbb Ee^{s(Z-\mathbb EZ)}\le e^{s^2\sum_i\|\hat x_i\|^2/2}$, and $\mathbb EZ\le\Xi:=(\sum_i\|\hat x_i\|^2)^{1/2}=\sqrt{nD}$.
6. **Optimize.** $n\hat{\mathfrak R}_S\le\frac{\ln4}\lambda+P\Xi+\frac{\lambda P^2\Xi^2}2$; take $\lambda=\sqrt{2\ln4}/(P\Xi)$. $\square$

### Theorem B2.4 (spectral bound with reference matrices; Literature plus Proved assembly)

*Literature: Bartlett–Foster–Telgarsky (NeurIPS 2017), Theorem 3.3; from memory.* Take bias-free networks $\hat x\mapsto A_3\sigma(A_2\sigma(A_1\hat x))$ with reference matrices $M_i$ fixed in advance, $\|A_i\|_2\le s_i$, $\|(A_i-M_i)^\top\|_{2,1}\le b_i$ (sum of the row $\ell_2$ norms of $A_i-M_i$), and all dimensions at most $W$. For the data matrix $\hat X$,
$$\ln\mathcal N(\mathcal F|_S,\varepsilon,\|\cdot\|_2)\le\frac{\|\hat X\|_F^2\ln(2W^2)}{\varepsilon^2}R_{s,b}^2,\qquad R_{s,b}=\prod_is_i\Big(\sum_i(b_i/s_i)^{2/3}\Big)^{3/2}.$$

*Literature: Dudley's entropy integral* (e.g. Srebro–Sridharan–Tewari 2010, Lemma A.3; BFT Lemma A.5; constants from memory). For a class with values in $[0,1]$ that contains the zero function (as I recall, BFT's Lemma A.5 assumes $0\in\mathcal F$),
$$\hat{\mathfrak R}_S\le\inf_{\alpha>0}\Big(\frac{4\alpha}{\sqrt n}+\frac{12}n\int_\alpha^{\sqrt n}\sqrt{\ln\mathcal N(\varepsilon)}\,d\varepsilon\Big).$$

*Assembly (Proved).*
- **Ramp class.** The ramp is $1/\gamma$-Lipschitz, so the ramp class has $\ln\mathcal N(\varepsilon)\le\varrho^2/\varepsilon^2$ with $\varrho=\|\hat X\|_F\sqrt{\ln(2W^2)}R_{s,b}/\gamma$.
- **Zero function.** The ramp class need not contain $0$. Apply Dudley to the class with $0$ added. This can only increase $\hat{\mathfrak R}_S$, and it adds one element to each cover, so $\ln\mathcal N(\varepsilon)\le\varrho^2/\varepsilon^2+\ln2$. Since $\sqrt{a^2+b}\le a+\min(\sqrt b,\,b/2a)$, the integrand grows by at most $\min(\sqrt{\ln 2},\,\varepsilon\ln2/2\varrho)$, and the bound on $\hat{\mathfrak R}_S$ by at most $\min(12\sqrt{\ln2/n},\,3\ln2/\varrho)$.
- **Dudley.** Choosing $\alpha=3\varrho/\sqrt n$ gives $\hat{\mathfrak R}_S\le\frac{12\varrho}n(1+\ln\frac n{3\varrho})+\min(12\sqrt{\ln2/n},\,3\ln2/\varrho)$ when $3\varrho\le n$.
- **Generalization.** Combine with the empirical-Rademacher form of L1 and a union bound over geometric grids for the six numbers $s_i,b_i$ and for $\gamma$, as in B2.1.

For the study: $W=129$, $\|\hat X\|_F=\sqrt{31n}$, and the augmentation uses $c=1$. With $M_i$ the initialization this is the "distance from init" variant. Section 5 reports $24\varrho/n$ at $\gamma=1$ (grid-rounded norms). Whenever $3\varrho\le n$, this is a lower bound on the BFT+Dudley *upper bound* on $2\hat{\mathfrak R}_S$ at that margin. It is not a lower bound on $2\hat{\mathfrak R}_S$ itself, which is at most $2$. When $3\varrho>n$, the computable Dudley bound is minimized at $\alpha=\sqrt n$, where it equals $4$, so it exceeds $1$ anyway. So values $\gg1$ mean that this route is vacuous. On the study's networks $24\varrho/n\ge667$, so $3\varrho>n$ always and the zero-function term never enters. The confidence term in [`checks/nnbounds.py`](checks/nnbounds.py) uses the conservative $3\sqrt{\ln(2/\delta)/2n}$ form.

### Why distance from initialization does not rescue the norm bounds (Proved / Numerical)

Rademacher complexity is invariant under a fixed shift ($\mathbb E\sum\epsilon_ic_i=0$), so a data-independent initialization costs nothing *as a function*. But all three norms above are norms of the **weights**, and at μP initialization they are already large:
- in expectation, $\phi_1(\theta_0)\approx(2/\pi)^{3/2}\sqrt{Nd}=31.5$ (measured $31.1$–$32.8$ for the study's three seeds);
- $P_F(\theta_0)\approx N^{-1/2}\cdot N^{1/2}\cdot N^{1/2}=\sqrt N=11.3$ (measured $11.7$);
- yet the initial outputs are tiny: $|f_{\theta_0}(x)|\approx\|h_2(x)\|/N\approx0.05$.

The trained networks have train margins near $1$, so the relevant quantity is the complexity term at unit margin, $c$ of Lemma B2.1a. At the initialization's norms it already exceeds $1$:
- **path norm:** for $n\lesssim(2\kappa_{\rm path}\cdot31.5)^2\approx4.4\times10^4$;
- **Frobenius:** for $n\lesssim(2\kappa_F\cdot11.3)^2\approx1.1\times10^5$.

These thresholds are guaranteed: grid rounding multiplies $c$ by a factor between $1$ and $q$. Between them and $q^2$ times them, i.e. up to $(2q\kappa_{\rm path}\cdot31.5)^2\approx5.3\times10^4$ and $(2q\kappa_F\cdot11.3)^2\approx1.4\times10^5$, $c\ge1$ is possible but not guaranteed ([`checks/referee_B_r2.out`](checks/referee_B_r2.out), part 6).

So, by Lemma B2.1a, any network with mean positive train margin at most about $1$ whose norms are at least those of the initialization gets a vacuous norm bound at these $n$. (The bound evaluated at $\theta_0$ itself is vacuous for a trivial reason: the initial margins are about $0.05$. The statement here is about the size of the norms.)

*Reading (Heuristic).* The norm-based terms are dominated by the random features present at initialization, which play no role in the learned function. This is an interpretation, not a theorem, and training does not always increase the norms: the trained path norm of $x_1$ at $n=16384$ is $26$, against $32$ at initialization for the same seeds ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 1).

Reference matrices (B2.4) subtract the initialization inside $\|\cdot\|_{2,1}$. They still keep the product of spectral norms, and they pay up to $\sqrt N$ for spreading a Frobenius displacement over $N$ rows. A Gaussian prior centred at $\theta_0$ removes the initialization exactly. That is why the PAC-Bayes route of Section 4 is the one that works.

**Minimal-norm comparison.** The target $x_1$ is computed by $\sigma(\sigma(x_1))-\sigma(\sigma(-x_1))$, which has path norm $2$ and margin $1$. For it, B2.2 would give $0.14$ at $n=16384$. The trained networks have path norm $26$–$610$ (Section 5).

## 4. B3: combined theorems

### Theorem B3.1 (a priori: gradient flow or GD, Frobenius capacity; Proved)

Let $\theta(t)$ be gradient flow from $\theta_0$ (or GD satisfying (D) with constant $c$; then replace $t$ by $t/c$), and set $\rho_t=\sqrt{t\,L_0}$. Define
$$P^{\max}(\rho)=\max\Big\{(A_0+\delta_3)\big((F_1+\delta_1)(F_2+\delta_2)+B_2+\delta_2'\big):\ \tfrac{\delta_1^2}{m_1}+\tfrac{\delta_2^2+\delta_2'^2}{m_2}+\tfrac{\delta_3^2}{m_3}\le\rho^2,\ \delta\ge0\Big\},$$
where $A_0=\|a_0\|$, $F_1=\|[W_1\,b_1](0)\|_F$, $F_2=\|W_2(0)\|_F$ and $B_2=\|b_2(0)\|$. Then with probability at least $1-\delta$, for all $t$ and all $k$,
$$R(\theta(t))\le\hat R_{\gamma_k}(\theta(t))+\frac{2\kappa_F\,q\max(P^{\max}(\rho_t),1)}{\gamma_k\sqrt n}+\sqrt{\frac{\ln((j+1)(j+2)(k+1)(k+2)/\delta)}{2n}} .$$
A closed-form upper bound is $P^{\max}(\rho)\le(A_0+\sqrt{m_3}\rho)\big((F_1+\sqrt{m_1}\rho)(F_2+\sqrt{m_2}\rho)+B_2+\sqrt{m_2}\rho\big)$.

*Proof.* By B1.1 (or B1.2(b)) and the triangle inequality per block, $P_F(\theta(t))\le P^{\max}(\rho_t)$. Apply B2.1 with $C=P_F$ and B2.3; the bound is monotone in $C$. $\square$

**Explicit form.** In terms of $(t,n,d,N,\alpha,\eta)$, with the study's μP initialization at scale $\alpha=1$ and $F_1\approx F_2\approx\alpha\sqrt N$, $A_0\approx\alpha/\sqrt N$:
$$F=\frac{2q\sqrt{d+1}(1+\sqrt{4\ln2})}{\gamma\sqrt n}\Big(\frac{\alpha}{\sqrt N}+\sqrt{m_3tL_0}\Big)\Big((\alpha\sqrt N+\sqrt{m_1tL_0})(\alpha\sqrt N+\sqrt{m_2tL_0})+\sqrt{m_2tL_0}\Big)+\text{conf},\qquad t=\eta K .$$
At $t=0$ the complexity term alone is already $\approx369/(\gamma\sqrt n)$. With the measured $P_F(\theta_0)=11.7$ rounded up to the grid it is $2.8$ at $n=16384$, $7.8$ at $n=2048$ and $22$ at $n=256$ (at $\gamma=1$). So the bound is above $1$ for all $n\le16384$ at every $\gamma\le1$, and by Lemma B2.1a at every $\gamma$ for networks with margins near $1$. (The values printed in [`checks/summary_tables.txt`](checks/summary_tables.txt) at $t=0$, $2$–$3$, are minimized over $\gamma\le4$. They are trivially above $1$ because the initial margins are about $0.05$.)

**Evaluating $P^{\max}$.** Section 5.3 and [`checks/summary_tables.txt`](checks/summary_tables.txt) use the closed form above, which is a certified upper bound on $P^{\max}$. Round 1 used a random search on the sphere, which gives a *lower* estimate of $P^{\max}$ and therefore not a certified bound. The closed form is larger by a factor $1.0$–$3.4$ over the runs of Section 5.3 ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 3). The conclusion, vacuous, is unchanged.

**Small-initialization reading (Heuristic).** In the README's experiments all layers start at $\alpha$ times fan-in scale, so the initial term is about $\alpha^3N$ and vanishes as $\alpha\to0$. The bound then behaves like $\kappa_F(tL_0)^{3/2}\sqrt{m_1m_2m_3}/(\gamma\sqrt n)$, which is small only if $t\lesssim n^{1/3}$. But by the rate law the first feature is learned only at $t\approx\alpha^{-1}$ (depth 3). So the a priori bound certifies generalization only for $n\gtrsim\alpha^{-3}$, however simple the learned function. This is the plateau problem of Section 2 in quantitative form.

### L5 (Literature: PAC-Bayes-kl)

Maurer, *A note on the PAC Bayesian theorem* (2004), Theorem 5; also Langford–Seeger 2001 and Seeger 2002 (from memory). For a $[0,1]$-valued loss, a prior $P$ chosen independently of $S$, $n\ge8$ and $\delta\in(0,1)$: with probability at least $1-\delta$, for all distributions $Q$,
$$\mathrm{kl}\big(\hat R_S(Q)\,\big\|\,R(Q)\big)\le\frac{\mathrm{KL}(Q\|P)+\ln(2\sqrt n/\delta)}n .$$
Here $R(Q)=\mathbb E_{\theta\sim Q}R(\theta)$, $\hat R_S(Q)=\mathbb E_{\theta\sim Q}\hat R_S(\theta)$ (0-1 losses), and $\mathrm{kl}$ is the binary relative entropy. Write $\mathrm{kl}^{-1}(q,c)=\sup\{p\ge q:\mathrm{kl}(q\|p)\le c\}$.

### Theorem B3.2 (PAC-Bayes with the prior at initialization, derandomized; Proved from L5)

Let $\Sigma$ be a finite grid of per-group standard deviations $\sigma=(\sigma_1,\sigma_2,\sigma_3)$, with $|\Sigma|=G$. For parameters $\theta$, let $Q_{\theta,\sigma}=\mathcal N(\theta,\mathrm{diag}(\sigma_g^2I_{p_g}))$ and $P_\sigma=\mathcal N(\theta_0,\mathrm{diag}(\sigma_g^2I_{p_g}))$. With probability at least $1-\delta_0$, for **all** $\theta$ (in particular the trained one, however it was obtained) and all $\sigma\in\Sigma$:
$$R(Q_{\theta,\sigma})\le\mathrm{kl}^{-1}\Big(\hat R_S(Q_{\theta,\sigma}),\ \frac1n\Big[\sum_g\frac{\|\theta_g-\theta_{0,g}\|^2}{2\sigma_g^2}+\ln\frac{2G\sqrt n}{\delta_0}\Big]\Big). \tag{PB}$$

**Monte Carlo and derandomization.** Fix $\theta$ and $\sigma\in\Sigma$ first, by any rule; $\sigma$ may be chosen by a search that looks at $S$, $\theta$ and its own random draws. **Then**, independently of everything used in that choice, draw $m$ iid pairs $(\theta'_j,B_j)$ with $\theta'_j\sim Q=Q_{\theta,\sigma}$ and $B_j$ a batch of indices drawn uniformly from $S$ (256 per batch in Section 5). Let $\hat e$ be the mean of the $m$ batch errors and $\hat\Delta$ the mean disagreement $\mathbb 1[\mathrm{sgn}f_{\theta'_j}(x)\ne\mathrm{sgn}f_\theta(x)]$ on $m$ fresh batches of **unlabeled** uniform inputs, drawn in the same way after $\sigma$ is fixed. (The input distribution is known; no labels beyond $S$ are used.) Then with probability at least $1-\delta_0-\delta_1-\delta_2$,
$$R(\theta)\le\mathrm{kl}^{-1}\Big(\mathrm{kl}^{-1}\big(\hat e,\tfrac{\ln(1/\delta_1)}m\big),\ \tfrac1n\big[\mathrm{KL}+\ln\tfrac{2G\sqrt n}{\delta_0}\big]\Big)+\mathrm{kl}^{-1}\big(\hat\Delta,\tfrac{\ln(1/\delta_2)}{m}\big).$$

*Proof.*
1. **KL.** For Gaussians with equal covariance, $\mathrm{KL}(Q_{\theta,\sigma}\|P_\sigma)=\frac12(\theta-\theta_0)^\top\Sigma^{-1}(\theta-\theta_0)$. The prior depends on $\theta_0$, which is independent of $S$, so L5 applies conditionally on $\theta_0$. A union bound over $\Sigma$ at $\delta_0/G$ each gives (PB).
2. **Monte Carlo.** Conditionally on $(S,\theta,\sigma)$, the $m$ final draws are iid, because they are made after $\sigma$ is fixed and independently of the search. Each batch error lies in $[0,1]$ and has mean $\hat R_S(Q)$. For $[0,1]$-valued iid variables, convexity gives $\mathbb Ee^{\lambda e}\le\mathbb Ee^{\lambda\,\mathrm{Bern}(p)}$, so the Chernoff bound $\Pr[\hat e\le q]\le e^{-m\,\mathrm{kl}(q\|p)}$ ($q<p$) holds, and with probability at least $1-\delta_1$, $\hat R_S(Q)\le\mathrm{kl}^{-1}(\hat e,\ln(1/\delta_1)/m)$. Monotonicity of $\mathrm{kl}^{-1}$ in its first argument transfers this into (PB).
3. **Derandomization.** Pointwise, $\mathbb 1[yf_\theta(x)\le0]\le\mathbb 1[yf_{\theta'}(x)\le0]+\mathbb 1[\mathrm{sgn}f_{\theta'}(x)\ne\mathrm{sgn}f_\theta(x)]$. This holds in every case, ties ($f_\theta(x)=0$ or $f_{\theta'}(x)=0$) included. Average over $x$ and $\theta'\sim Q$, and bound the disagreement as in step 2. $\square$

In Section 5, $\Sigma$ is $\{0.4\cdot2^{-i/2}:0\le i\le15\}^3$ ($G=4096$), $\delta_0=0.03$, $\delta_1=\delta_2=0.01$, $m=400$, and $\sigma$ is chosen by a data-dependent search.
- **Choice of $\sigma$.** Any rule is allowed for (PB), since (PB) holds for the whole grid at once. The Monte Carlo steps need the $m$ final draws to be fresh. Reusing the search's draws would invalidate $\delta_1$ and $\delta_2$. [`nnbounds.pac_bayes`](checks/nnbounds.py) searches with separate selection draws and reports estimates from fresh final draws.
- **Several networks or checkpoints.** Each reported bound holds with probability $1-\delta_0-\delta_1-\delta_2$ on its own. To quote the best of $J$ evaluated bounds after the fact, replace $\delta_1,\delta_2$ by $\delta_1/J,\delta_2/J$. (PB) needs no such split when all $J$ evaluations use the same $S$ and $\theta_0$ (hence the same prior) and the same grid $\Sigma$, because it is uniform in $\theta$. This is the case for the 10 checkpoints per target of Section 5.3: the SGD and Adam runs there share the seed-0 sample and initialization. Across seeds or samples, $\delta_0$ must be split as well.

### Theorem B3.3 (time-based PAC-Bayes: "short training implies generalization"; Proved)

Under the hypotheses of B3.2, the KL term in (PB) at the trained parameters is bounded as follows. Write $\lambda_\sigma=\max_gm_g/2\sigma_g^2$.

- **(a) Gradient flow** (or GD under (D) with constant $c$): $\displaystyle\mathrm{KL}\le\frac{t\,(L_0-L_S(\theta(t)))}{c}\lambda_\sigma\le\frac{t\,L_0}{c}\lambda_\sigma$. This bound is **linear in training time**.
- **(b) Any update $\theta_{k+1}=\theta_k-\eta Mu_k$** (SGD included), with the measured per-group energies $E_{K,g}$ of B1.2(a): $\displaystyle\mathrm{KL}\le t_K\sum_g\frac{m_gE_{K,g}}{2\sigma_g^2}$.
  - The energies are non-decreasing in $K$, so (b) is linear in $t_K$ only while they stay bounded.
  - Under (D) they do: $\sum_gE_{K,g}\le L_0/c$, and (b) then implies (a).
  - Under minibatch noise they need not. In the SGD runs of Section 5.3, $\sum_gE_{K,g}$ reaches $50\,L_0$ by step 5000.
- **(c) Adam** (Lemma B1.4): $\displaystyle\mathrm{KL}\le\sum_g\frac{p_g(\eta m_gS_K)^2}{2\sigma_g^2}$. Here $C_t\ge1$ for every $t$, because constant gradients give the ratio exactly $1$ and $C_t$ is the supremum. Hence $S_K\ge K$, and $S_K/K\to C_\infty=7.27$. So (c) is **quadratic in the number of steps**: it is at least $K^2\sum_gp_g\eta^2m_g^2/2\sigma_g^2$.
- **(d) SGD, a priori, under the hypotheses of Proposition B1.3** (new in revision 2). Let $V(t)=4tL_0+2\eta t\nu^2(1+\beta t)/B$ with $t=\eta K$, and let $\omega$ denote the minibatch indices.
  - **(d1)** For every $\delta'\in(0,1)$: with probability at least $1-\delta_0-\delta'$ over $(S,\omega)$, (PB) holds at $\theta=\theta_K(\omega)$ for all $\sigma\in\Sigma$ with $\mathrm{KL}\le\lambda_\sigma V(t)/\delta'$.
  - **(d2)** Let $\bar Q_\sigma$ be the law of $\theta_K(\omega)+\xi$, where $\omega$ is drawn afresh and $\xi\sim\mathcal N(0,\mathrm{diag}(\sigma_g^2I_{p_g}))$. This is the randomized predictor "rerun SGD on $S$, then perturb". With probability at least $1-\delta_0$ over $S$, for all $\sigma\in\Sigma$,
  $$\mathrm{kl}\big(\hat R_S(\bar Q_\sigma)\,\big\|\,R(\bar Q_\sigma)\big)\le\frac1n\Big[\lambda_\sigma V(t)+\ln\frac{2G\sqrt n}{\delta_0}\Big].$$
  - Both carry the noise term $2\eta\beta\nu^2t^2/B$, which is quadratic in $t$ at fixed $\eta$ and vanishes as $\eta\to0$ at fixed $t$.

*Proof.* For every $\theta$, $\mathrm{KL}(Q_{\theta,\sigma}\|P_\sigma)=\sum_g\|\Delta_g\|^2/2\sigma_g^2=\sum_g(\|\Delta_g\|^2/m_g)(m_g/2\sigma_g^2)\le\lambda_\sigma\|\Delta\|_{M^{-1}}^2$.
- (a) Insert B1.1(2), or B1.2(b): $\|\Delta\|^2_{M^{-1}}\le t(L_0-L_S(\theta(t)))/c$.
- (b) Insert the per-group statement of B1.2(a). The bound $\sum_gE_{K,g}\le(L_0-L_S(\theta_K))/c$ under (D) is the first line of the proof of B1.2(b).
- (c) Insert the consequence $\|\Delta\theta_g\|_2\le\sqrt{p_g}\,\eta m_gS_K$ of Lemma B1.4.
- (d1) Since $L_S\ge0$, B1.3 gives $\mathbb E_\omega[\|\Delta\|^2_{M^{-1}}\mid S,\theta_0]\le V(t)$. Markov's inequality, conditionally on $(S,\theta_0)$, gives $\|\Delta\|^2_{M^{-1}}\le V(t)/\delta'$ outside an event of probability $\delta'$. (PB) holds for all $\theta$ at once outside an event of probability $\delta_0$, so it holds at $\theta_K(\omega)$ for every $\omega$. Take the union of the two exceptional events.
- (d2) L5 holds for every posterior, including $\bar Q_\sigma$, which may depend on $S$. $\bar Q_\sigma$ is the $\theta'$-marginal of the joint law of $(\omega,\theta')$ with $\theta'\sim Q_{\theta_K(\omega),\sigma}$, and $P_\sigma$ is the $\theta'$-marginal of $\mathrm{law}(\omega)\otimes P_\sigma$. By the data-processing inequality and the chain rule, $\mathrm{KL}(\bar Q_\sigma\|P_\sigma)\le\mathbb E_\omega\mathrm{KL}(Q_{\theta_K(\omega),\sigma}\|P_\sigma)\le\lambda_\sigma\mathbb E_\omega\|\Delta\|^2_{M^{-1}}\le\lambda_\sigma V(t)$. The union bound over $\Sigma$ is as in B3.2. $\square$

**Reading.**
- **(a) is the user's "training has not taken long" condition, made rigorous for gradient flow and for full-batch GD while (D) holds.** The test error of the noisy network is at most $\mathrm{kl}^{-1}(\text{noisy train error},\ \varepsilon+\ln(2G\sqrt n/\delta_0)/n)$ as long as
  $$t\le\varepsilon\,n\cdot\frac{2c}{L_0}\min_g\frac{\sigma_g^2}{m_g}.$$
  - For the study's SGD multipliers (also used for GD) and the noise levels the trained networks tolerate, $\sigma\approx(0.14,0.2,0.025)$, the constant is $\lambda_\sigma\approx400$, set by the readout $a$.
  - With $L_0=0.5$ and $c=1$ the condition is $t\le\varepsilon n/200$ in gradient-flow time. For full-batch GD that is about $25\,\varepsilon$ steps per $1000$ samples at $\eta=0.2$, or $250\,\varepsilon$ at $\eta=0.02$, **provided (D) holds**.
  - In our runs (D) holds at $\eta=0.02$ with $c\ge0.993$. At $\eta=0.2$ it holds only for the first 20 steps, with $c_{20}=0.26$ (Section 5.3).
  - The price is the noise level $\sigma$: the bound is a priori in $t$ but a posteriori in **robustness**, because the noisy train error $\hat R_S(Q)$ must still be measured.
- **For SGD, (a) is not a theorem.** The rigorous SGD versions are (b) and (d).
  - **(b) is a diagnostic, not an a priori statement.** It uses only measured quantities, and since $\|\Delta_g\|^2\le m_gt_KE_{K,g}$ pointwise, it is always weaker than B3.2 with the measured displacement. It shows how loose the energy route is: at the same $\sigma$ its KL is $2$–$44$ times the flow value over the 18 SGD checkpoints (for example 5832 against 801 for $x_1$ at step 20, and $1.8\times10^6$ against 50852 for MAJ$_3$ at $n=2048$, step 5000; [`checks/referee_B_r2.out`](checks/referee_B_r2.out), part 5).
  - **(d) is genuinely a priori but needs smoothness**, which fails for ReLU (Section 2), and its constants are worse than those of (a). It pays a factor $4$ (mixture form d2) or $4/\delta'$ (high-probability form d1), plus the $t^2$ noise term. With $\lambda_\sigma=400$ and the noise term ignored, KL $\le0.1\,n$ at $n=16384$ needs $t\le2.0$ for (d2), and $t\le0.02$ for (d1) with $\delta'=0.01$, against $t\le8.2$ for (a) ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 6). (d) is not evaluated on the study's networks.
- **For Adam, (c) is a priori but quadratic in $K$.** At fixed $\sigma$, tripling the number of steps from 100 to 300 multiplies it by $(S_{300}/S_{100})^2=23$.

### Proposition B3.4 (online protocol: progressive validation; Proved)

In one-pass training (SGD, Adam, or any update rule), step $k$ draws a fresh minibatch $B_k$ of $B$ iid examples, independent of the past, and updates $\theta_{k-1}\mapsto\theta_k$. Let $e_k=\frac1B\sum_{(x,y)\in B_k}\mathbb 1[yf_{\theta_{k-1}}(x)\le0]$ be the error of the **pre-update** parameters on the new batch. Then for any window of $K'$ steps **fixed in advance**, with probability at least $1-\delta$,
$$\frac1{K'}\sum_{k\in\text{window}}R(\theta_{k-1})\le\frac1{K'}\sum_{k\in\text{window}}e_k+\sqrt{\frac{\ln(1/\delta)}{2K'B}} .$$
So the predictor that outputs $\theta_{k-1}$ for a uniformly random $k$ in the window has test error at most the right-hand side.
- **Choice of window.** Choosing the window after seeing the $e_k$ needs a union bound over the candidate windows, e.g. $\delta/J$ each for $J$ candidates.
- **Which predictor.** The bound is on the random-iterate predictor, i.e. on the average test error of the window's iterates. It says nothing directly about the final network, which is the one the study reports.

*Proof.* $X_k=R(\theta_{k-1})-e_k$ has $\mathbb E[X_k\mid\mathcal F_{k-1}]=0$. Conditionally on $\mathcal F_{k-1}$, it is a sum of $B$ independent terms of range $1/B$, so $\mathbb E[e^{\lambda X_k}\mid\mathcal F_{k-1}]\le e^{\lambda^2/(8B)}$ (Hoeffding's lemma). Chaining the conditional expectations gives $\Pr[\sum X_k\ge s]\le e^{-2Bs^2/K'}$. $\square$

This is the online-to-batch conversion (Cesa-Bianchi–Conconi–Gentile, IEEE Trans. IT 2004; from memory). For the study's online runs ($B=64$, $K'=1000$, $\delta=0.05$) the slack is $0.005$.

**Evaluation (Numerical; [`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 8).** The existing outputs of the study's online runs (`nn_train.run_online`) predate the logging of the progressive errors $e_k$, so B3.4 cannot be evaluated on them. (`run_online` has since been changed to record the prequential mistakes per chunk of at most 500 steps, counted as $\mathrm{sgn}f\ne y$ on each fresh batch before the update on it. B3.4 should be evaluated on the study's own online runs once they are rerun, with the per-chunk windows fixed in advance; that is not done here.) I therefore reran the online protocol with logging: one-pass Adam with the study's settings (lr $10^{-3}$, batch 64, μP multipliers, seed-0 initialization) for 3000 steps, recording $e_k$ and the test error of every iterate on the 4096 held-out inputs. Three windows of 1000 steps were fixed in advance, with $\delta=0.05/3$ each, so the slack is $0.0057$:

| target | steps 1–1000: bound (measured mean test error of the iterates) | steps 1001–2000 | steps 2001–3000 |
|---|---|---|---|
| $x_1$ | 0.016 (0.011) | 0.006 (0.000) | 0.006 (0.000) |
| MAJ$_3$ | 0.021 (0.015) | 0.006 (0.000) | 0.006 (0.000) |
| $x_1x_2x_3$ | 0.153 (0.149) | 0.006 (0.000) | 0.006 (0.000) |

In every window the bound is within $0.006$ of the measured value. The final networks after 3000 steps have test error $0$. **In the online protocol there is no generalization gap left to bound:** the cumulative progressive error is the total number of mistakes made during learning, the quantity bounded for NNBayes in the sibling project's [online-mistake results](../../neural-network-generalization/TECHNICAL-FAQ.md#can-we-bound-the-total-number-of-mistakes-during-learning). A circuit-based theory of GD (tasks A and C) can aim at the same quantity. For multi-pass SGD on a fixed $S$ the argument fails, because batches are reused.

### 4.5 Alternatives: stability and information-theoretic bounds (Literature)

**Uniform stability.** Hardt–Recht–Singer (ICML 2016), Theorem 3.12 (from memory).
- *Assumptions:* for every example $z$, the loss $\ell(\cdot;z)\in[0,1]$ is $L$-Lipschitz and $\beta$-smooth in the parameters, globally; SGM picks a uniformly random example at each step, with monotonically non-increasing step sizes $\alpha_t\le c/t$, for $T$ steps.
- *Conclusion:* uniform stability $\varepsilon_{\rm stab}\le\frac{1+1/(\beta c)}{n-1}(2cL^2)^{1/(\beta c+1)}T^{\beta c/(\beta c+1)}$, and $|\mathbb E[R-\hat R]|\le\varepsilon_{\rm stab}$ in expectation over $S$ (their Theorem 2.2).
- *Our setting violates every assumption:* the square loss is unbounded, the ReLU loss is neither smooth nor globally Lipschitz in $\theta$, the step size is constant ($0.2$, not $c/t$), and Adam is not SGM.
- *Even after forcing it to apply* (a smoothed network, a bounded smooth surrogate of the 0-1 loss, constant step $\alpha$), HRS's growth recursion (their Lemma 2.5) gives $\varepsilon_{\rm stab}\lesssim\frac{2L^2}{\beta n}e^{\alpha\beta T}$. GD with constant step runs at the edge of stability, where sharpness is about $2/\alpha$ (Cohen–Kaur–Li–Kolter–Talwalkar, ICLR 2021; from memory), so $\alpha\beta T\approx2T$ and the bound is vacuous after a few steps.
- *High-probability versions* (Feldman–Vondrák 2019; Bousquet–Klochkov–Zhivotovskiy 2020) inherit the same problem.
- **Verdict: does not apply.**

**Mutual information.** Xu–Raginsky (NeurIPS 2017), Theorem 1 (from memory): if $\ell(w,Z)$ is $s$-sub-Gaussian for every $w$, then $|\mathbb E[R(W)-\hat R_S(W)]|\le\sqrt{2s^2I(S;W)/n}$; for the 0-1 loss $s=1/2$.
- *It applies to our runs.* The 0-1 loss is bounded, and no smoothness or Lipschitz condition is needed, so the bound applies to any algorithm. The problem is to bound $I(S;W)$.
- *Noiseless training.* For our deterministic algorithms, $W$ is a function of $(S,\theta_0,\text{batch indices})$. The inputs are discrete, so $I(S;W)\le H(S)\le nd\ln2$, and the bound is $\le\sqrt{d\ln2/2}=3.2$: vacuous. The conditional mutual information bound of Steinke–Zakynthinou (COLT 2020) also applies to any algorithm with a bounded loss. The CMI is at most $n\ln2$, giving at most $\sqrt{2\ln2}=1.18$, again vacuous unless the CMI is estimated, e.g. by many retrainings.
- *SGLD.* Bounds for SGLD (Pensia–Jog–Loh, ISIT 2018; Mou–Wang–Zhai–Zheng, COLT 2018; Negrea et al., NeurIPS 2019; from memory) need Gaussian noise injected at every step and give $I\lesssim\sum_t\eta_t^2L^2/\sigma_t^2$. At constant step size and noise that is linear in the number of steps, structurally the same as Theorem B3.3(a). But it applies only to Langevin variants of our runs.
- *Plain SGD.* Neu–Dziugaite–Haghifam–Roy (COLT 2021) give information-theoretic bounds for plain SGD through a perturbed auxiliary iterate, in terms of gradient variance and sensitivity to perturbations (from memory). This is the closest analogue of B3.2–B3.3.
- **Verdict: applies, but vacuous with the computable bounds on $I(S;W)$ and the CMI. The noisy variants reduce to the same "KL grows with time" mechanism as B3.3(a).**

**Which bound applies to which protocol.**

| protocol | B3.1 (a priori, norms) | B3.2 (PAC-Bayes, measured) | B3.3 (PAC-Bayes, time) | B3.4 (online) | HRS | Xu–Raginsky, CMI |
|---|---|---|---|---|---|---|
| gradient flow | applies, vacuous | applies | (a) applies | — | no | apply, vacuous |
| full-batch GD | needs (D), checkable | applies | (a) while (D) holds, with the measured $c$; (b) always | — | no | apply, vacuous |
| SGD with replacement on fixed $S$ | in expectation only (B1.3) | applies | (b) applies (measured energy; a diagnostic); (d) only under smoothness | — | no | apply, vacuous |
| Adam on fixed $S$ | no useful version | applies | (c) applies, quadratic in $K$, vacuous beyond $\sim10^2$ steps | — | no | apply, vacuous |
| online (one pass) | not needed | not needed | not needed | applies; within $0.006$ of the measured value | not needed | not needed |

## 5. B4: numbers

All bounds below hold with probability at least $0.95$. They use $q=1.1$ for the margin and norm grids, and for PAC-Bayes the grid and Monte-Carlo sizes stated after Theorem B3.2. A bound is *vacuous* if it is at least $1$ (printed as $1.00$). It is *uninformative* if it exceeds $0.5$, the error of random guessing on a balanced target. "Test err (actual)" is the network's error on the study's 4096 held-out inputs. It is shown for comparison and is never used by any bound. Margin bounds are reported through their complexity term at unit margin, $c=2\kappa\phi_0q^{j}/\sqrt n$ (Lemma B2.1a), because the minimized bound sits at the grid edge $\gamma_{\max}$ whenever it is vacuous.

### 5.1 Representative values (Numerical; [`checks/representative.out`](checks/representative.out))

Theorem B2.1 at margin $\gamma=1$ with zero train margin error, i.e. complexity plus confidence term only:

| $n$ | Frobenius, $P_F=11.2$ (μP init) | $P_F=66$ ($\Vert W_1\Vert =6,\Vert W_2\Vert =11,\Vert a\Vert =1$) | $P_F=450$ ($10,15,3$) | path norm $\phi=2$ (minimal for $x_1$) | $\phi=10$ | $\phi=30$ (init) | $\phi=100$ | $\phi=1000$ |
|---|---|---|---|---|---|---|---|---|
| 256 | 23 | 129 | 950 | 1.09 | 4.9 | 14 | 46 | 456 |
| 2048 | 8.2 | 45 | 336 | 0.39 | 1.7 | 4.8 | 16 | 161 |
| 16384 | 2.9 | 16 | 119 | 0.14 | 0.61 | 1.7 | 5.8 | 57 |

The path-norm bound falls below $0.5$ only for $\phi\le2.9$ at $n=2048$, $\phi\le8.1$ at $n=16384$, and $\phi\le66$ at $n=10^6$. The task's suggested $\|a\|\approx1$–$3$ is larger than what Adam produces here ($\|a\|=0.15$–$1.06$, below). The Frobenius column is vacuous even at initialization.

### 5.2 Final networks of the Adam sweep (Numerical; [`checks/eval_saved.py`](checks/eval_saved.py))

These are the study's networks after 20000 Adam steps. The initialization and training sets were regenerated from the study's seeds and matched against the sweep's recorded norms to two decimals. All bounds are computed for the float16-saved weights. "Test err (actual)" is the sweep's recorded float32 test error; rounding to float16 changes the predictions on at most 0.05% of the test inputs ([`checks/referee_C_r1_fp16.out`](checks/referee_C_r1_fp16.out)). The norm columns give the complexity term at unit margin, $c=2\kappa\phi_0q^j/\sqrt n$ with $\kappa_{\rm path}=3.32$ and $\kappa_F=14.84$ (Lemma B2.1a). The minimized bounds of round 1 are kept in [`checks/summary_tables.txt`](checks/summary_tables.txt); all are at least 1. Means over seeds $0,1,2$ ($x_1x_2x_3$, thr$_{10}$ and the last three targets: seed 0 only); the range over seeds of the final column is in brackets. stair$_5=\mathrm{sgn}(x_1+x_1x_2+\dots+x_1\cdots x_5)$.

| target | $n$ | test err (actual) | path norm | B2.2: $c_{\rm path}$ | $P_F$ | B2.3: $c_F$ | spectral $24\varrho/n$, init / zero reference | KL (nats) | Gibbs train err | B3.2: $R(Q)\le$ | B3.2: deterministic $R(\theta)\le$ |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $x_1$ | 256 | 0.000 | 62 | 26.7 | 24.3 | 47.4 | 2956 / 8426 | 127 | 0.35 | 0.87 | 1.00 |
| $x_1$ | 2048 | 0.000 | 67 | 10.7 | 24.0 | 16.8 | 1293 / 3049 | 776 | 0.04 | 0.47 | **0.55** (0.52–0.60) |
| $x_1$ | 16384 | 0.000 | 26 | 1.46 | 15.6 | 3.9 | 679 / 1005 | 1804 | 0.02 | 0.21 | **0.26** (0.24–0.27) |
| AND$_3$ | 256 | 0.029 | 91 | 40.4 | 40.1 | 78.9 | 4269 / 11030 | 264 | 0.18 | 0.88 | 1.00 |
| AND$_3$ | 2048 | 0.000 | 82 | 12.6 | 39.2 | 26.2 | 2094 / 4419 | 399 | 0.14 | 0.51 | **0.71** (0.69–0.73) |
| AND$_3$ | 16384 | 0.000 | 41 | 2.28 | 28.0 | 6.5 | 932 / 1378 | 3021 | 0.03 | 0.32 | **0.39** (0.35–0.46) |
| MAJ$_3$ | 256 | 0.041 | 128 | 55.4 | 44.8 | 86.7 | 5352 / 12741 | 238 | 0.39 | 0.95 | 1.00 |
| MAJ$_3$ | 2048 | 0.000 | 103 | 15.7 | 48.6 | 33.7 | 3717 / 7007 | 915 | 0.20 | 0.71 | **0.94** (0.84–1.00) |
| MAJ$_3$ | 16384 | 0.000 | 55 | 2.94 | 34.9 | 8.5 | 1644 / 2220 | 4315 | 0.02 | 0.35 | **0.40** (0.38–0.41) |
| $x_1x_2$ | 256 | 0.002 | 135 | 59.1 | 53.0 | 101.9 | 7210 / 17322 | 278 | 0.47 | 0.98 | 1.00 |
| $x_1x_2$ | 2048 | 0.000 | 83 | 12.9 | 39.4 | 27.0 | 2678 / 5208 | 1320 | 0.13 | 0.74 | **0.93** (0.90–0.97) |
| $x_1x_2$ | 16384 | 0.000 | 41 | 2.21 | 29.2 | 7.2 | 1290 / 1719 | 4302 | 0.006 | 0.30 | **0.33** (0.31–0.35) |
| $x_1x_2x_3$ | 2048 | 0.000 | 173 | 27.8 | 80.0 | 52.6 | 5195 / 9977 | 1207 | 0.39 | 0.90 | 1.00 |
| $x_1x_2x_3$ | 16384 | 0.000 | 72 | 3.78 | 55.9 | 14.0 | 2208 / 3015 | 5291 | 0.05 | 0.46 | **0.56** |
| thr$_{10}$ | 2048 | 0.027 | 339 | 54.1 | 124.9 | 84.7 | 11294 / 20234 | 1614 | 0.26 | 0.87 | 1.00 |
| thr$_{10}$ | 16384 | 0.003 | 543 | 30.8 | 225.8 | 53.0 | 14482 / 18093 | 12632 | 0.16 | 0.80 | 1.00 |
| $x_1x_2x_3x_4$ | 2048 | 0.020 | 610 | 95.8 | 204.0 | 136.4 | 12173 / 22894 | 4292 | 0.32 | 0.99 | 1.00 |
| $x_1x_2x_3x_4$ | 16384 | 0.000 | 102 | 5.54 | 70.6 | 16.9 | 3245 / 4516 | 6014 | 0.18 | 0.66 | 0.91 |
| stair$_5$ | 2048 | 0.000 | 302 | 44.7 | 127.1 | 84.7 | 7980 / 15168 | 1952 | 0.37 | 0.94 | 1.00 |
| stair$_5$ | 16384 | 0.000 | 99 | 5.54 | 77.3 | 18.6 | 3032 / 4229 | 6048 | 0.13 | 0.60 | 0.79 |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | 2048 | 0.048 | 602 | 95.8 | 202.2 | 136.4 | 10435 / 19686 | 2846 | 0.32 | 0.97 | 1.00 |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | 16384 | 0.000 | 112 | 6.09 | 90.8 | 22.5 | 3179 / 4046 | 3456 | 0.27 | 0.66 | 1.00 |

**KL split at $n=16384$** (nats for $(W_1,b_1)$ / $(W_2,b_2)$ / $a$; chosen $\sigma$; displacements $\|\Delta_g\|$):

| target | KL parts | $\sigma$ | $\Vert \Delta_g\Vert $ |
|---|---|---|---|
| $x_1$ | 991 / 690 / 123 | 0.20 / 0.14 / 0.011 | 8.9 / 5.3 / 0.17 |
| AND$_3$ | 2024 / 935 / 62 | 0.14 / 0.14 / 0.026 | 9.0 / 6.1 / 0.25 |
| MAJ$_3$ | 2170 / 1992 / 153 | 0.14 / 0.10 / 0.020 | 9.3 / 6.3 / 0.34 |
| $x_1x_2$ | 2624 / 1589 / 88 | 0.14 / 0.10 / 0.023 | 10.3 / 5.6 / 0.29 |
| $x_1x_2x_3$ | 3054 / 1890 / 346 | 0.14 / 0.10 / 0.018 | 11.1 / 6.2 / 0.47 |
| thr$_{10}$ | 2980 / 7940 / 1712 | 0.14 / 0.10 / 0.018 | 10.9 / 12.6 / 1.03 |
| $x_1x_2x_3x_4$ | 4382 / 1390 / 242 | 0.10 / 0.14 / 0.025 | 9.4 / 7.5 / 0.55 |
| stair$_5$ | 3547 / 2224 / 277 | 0.14 / 0.10 / 0.025 | 11.9 / 6.7 / 0.59 |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | 1736 / 1570 / 150 | 0.20 / 0.14 / 0.035 | 11.8 / 7.9 / 0.61 |

**Reading.**
- **Norm bounds.** All three are vacuous for every network. For each of the 49 networks, $c\ge\max(1,\bar m_+)$, so Lemma B2.1a applies. The mean positive train margins $\bar m_+$ are $0.99$–$1.01$ ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 1).
  - The *path norm* comes closest: $c_{\rm path}=1.46$ for $x_1$ at $n=16384$, and $2.2$–$2.9$ for AND$_3$, MAJ$_3$ and $x_1x_2$ there.
  - Round 1 quoted the minimized bound instead ($1.13$ for $x_1$), but for every network that minimum sits at the grid edge $\gamma=\gamma_{\max}=4$. With $\gamma_{\max}=1000$ the same bounds are $1.02$–$1.27$. These values reflect $\gamma_{\max}$ and the confidence term $\mathrm{conf}_{j,0}$ (remark after Lemma B2.1a), not how far the bound is from being useful.
  - For $x_1$ the trained path norm ($26$–$67$) is $13$–$34$ times the minimal value $2$.
  - *Frobenius:* $c_F=3.9$–$136$ over the table's rows (means over seeds). Over all 49 networks, including three $n=256$ networks that are not in the table ($x_1x_2x_3x_4$, stair$_5$, MAJ of parities), the ranges are $c_F=3.7$–$180$ and $c_{\rm path}=1.46$–$115$ ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 1).
  - *Spectral:* $24\varrho/n=679$–$22894$ at unit margin over the table's rows, i.e. vacuous by 3–4 orders of magnitude. Reference matrices at the initialization help by a factor of only $1.25$–$3$.
  - For the simple targets the path norm *decreases* with $n$, from about 60–135 at $n=256$ to 26–55 at $n=16384$. Plausibly this is because at large $n$ the network no longer fits idiosyncratic training points (Heuristic). For thr$_{10}$ it increases.
- **PAC-Bayes.** The bound is non-vacuous at $n=16384$ for the five targets with at most 3 relevant variables: $0.26$–$0.56$ for the deterministic network and $0.21$–$0.46$ for the Gibbs network. At $n=2048$ it is borderline ($0.55$–$1.0$); at $n=256$ it is vacuous.
  - The KL is dominated by the first two layers. The readout tolerates only $\sigma_3\approx0.01$–$0.03$, but it moves little.
  - The KL grows with $n$ (127 to 1804 nats for $x_1$): larger samples drive the weights further from initialization. The bound still improves because $n$ grows faster.
  - For targets with 4–6 relevant variables ($x_1x_2x_3x_4$, stair$_5$, MAJ of three parities), PAC-Bayes is uninformative even at $n=16384$: $0.60$–$0.66$ for the Gibbs network and $0.79$–$1.0$ for the deterministic one. The KL is $3500$–$6000$ nats. The 10-variable threshold function is out of reach.

### 5.3 Trajectories: B1 inequalities and time-based bounds (Numerical; [`checks/sgd_short.py`](checks/sgd_short.py), full tables in [`checks/summary_tables.txt`](checks/summary_tables.txt))

The runs are MAJ$_3$ at $n=2048$ (SGD and GD) and $x_1$ and MAJ$_3$ at $n=16384$ (SGD and Adam). All use the study's initialization and μP multipliers. Columns:
- $\|\Delta\|$: the measured $\|\theta-\theta_0\|_{M^{-1}}$.
- $\Lambda$ and $\sqrt{tE}$: the path length and energy bound of B1.2(a).
- $\sqrt{tL_0}$: the gradient-flow bound of B1.1.
- "meas.": B3.2 with the measured KL.
- "energy" and "flow": B3.3(b) and (a), each with the same $\sigma$, reported as $R(Q)$ (Gibbs). In brackets: the deterministic network, which adds the measured disagreement.
- "flow" divides the KL by $c_K$, the running minimum of the measured descent ratio $(L_k-L_{k+1})/(\eta\|g_k\|_M^2)$ over $k<K$, when (D) has held at every step so far. Only then is it rigorous. Otherwise (SGD, or GD after (D) has failed) it uses $c=1$ and is **not** rigorous. In round 1 the code used $c=1$ throughout.

**SGD, $\eta=0.2$, batch 64** (no descent condition is available; only "energy" is rigorous):

| step | test err | $\Vert \Delta\Vert $ | $\Lambda$ | $\sqrt{tE}$ | $\sqrt{tL_0}$ | meas.: $R(Q)$ (det.) | energy: KL, $R(Q)$ | flow (not rigorous for SGD): KL, $R(Q)$ |
|---|---|---|---|---|---|---|---|---|
| 20 | 0.133 | 1.13 | 3.8 | 4.4 | 1.4 | 0.49 (0.69) | 3669, 0.95 | 814, 0.66 |
| 50 | 0.032 | 1.47 | 7.8 | 9.2 | 2.3 | 0.46 (0.61) | 16778, 1.00 | 1017, 0.63 |
| 100 | 0.009 | 1.79 | 13.2 | 15.4 | 3.2 | 0.44 (0.59) | 31017, 1.00 | 2034, 0.79 |
| 500 | 0.000 | 3.14 | 37.1 | 45.8 | 7.1 | 0.55 (0.71) | $2\times10^5$, 1.00 | 5085, 0.97 |
| 5000 | 0.000 | 3.66 | 85.4 | 159 | 22.6 | 0.62 (0.78) | $1.8\times10^6$, 1.00 | 50852, 1.00 |

**SGD at $n=16384$** (same settings; [`checks/summary_tables.txt`](checks/summary_tables.txt)):

| target | step | test err | $\Vert \Delta\Vert $ | $\Lambda$ | $\sqrt{tE}$ | $\sqrt{tL_0}$ | meas.: $R(Q)$ (det.) | energy: KL, $R(Q)$ | flow (not rigorous): KL, $R(Q)$ |
|---|---|---|---|---|---|---|---|---|---|
| $x_1$ | 20 | 0.001 | 1.25 | 3.8 | 4.8 | 1.4 | 0.10 (0.14) | 5832, **0.39** | 801, 0.13 |
| $x_1$ | 100 | 0.000 | 1.56 | 9.2 | 13.3 | 3.2 | 0.08 (**0.10**) | 35471, 0.90 | 2002, 0.18 |
| $x_1$ | 300 | 0.000 | 1.82 | 14.7 | 24.4 | 5.5 | 0.08 (**0.10**) | $1.9\times10^5$, 1.00 | 12012, 0.56 |
| MAJ$_3$ | 50 | 0.019 | 1.53 | 8.8 | 10.3 | 2.3 | 0.23 (0.36) | 21034, 0.85 | 1019, 0.28 |
| MAJ$_3$ | 100 | 0.000 | 1.82 | 13.6 | 16.2 | 3.2 | 0.17 (0.22) | 97898, 1.00 | 4074, 0.34 |
| MAJ$_3$ | 300 | 0.000 | 2.90 | 29.6 | 35.6 | 5.5 | 0.18 (0.23) | $2.4\times10^5$, 1.00 | 6112, 0.43 |

**Full-batch GD, $\eta=0.2$** (the study's learning rate).
- The descent ratio $(L_k-L_{k+1})/(\eta\|g_k\|_M^2)$ is positive for the first 20 steps, with minimum $c_{20}=0.26$. So (D) holds there, and "flow" at step 20 is rigorous, with the KL divided by $0.26$.
- The ratio first turns negative at step $k=20$, falling to $-0.56$ two steps later ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 2, an independent recomputation). Over the whole run its median is $0.004$. So (D) fails from step 20 on, and the dynamics oscillate, consistent with the edge-of-stability regime (sharpness not measured).
- From step 50 on, only "energy" is rigorous:

| step | test err | $\Vert \Delta\Vert $ | $\Lambda$ | $\sqrt{tE}$ | $\sqrt{tL_0}$ | meas. | energy | flow |
|---|---|---|---|---|---|---|---|---|
| 20 | 0.051 | 1.11 | 1.2 | 1.2 | 1.4 | 0.43 (0.58) | 409, **0.46** | 3145, 0.90 (rigorous, $c_{20}=0.26$) |
| 50 | 0.010 | 1.63 | 5.7 | 12.9 | 2.3 | 0.42 (0.58) | 23053, 1.00 | 1017, 0.63 (not rigorous) |
| 2000 | 0.000 | 3.42 | 33.5 | 88.5 | 14.3 | 0.59 (0.79) | $6\times10^5$, 1.00 | 20341, 1.00 (not rigorous) |

**Full-batch GD, $\eta=0.02$** (ten times smaller). (D) holds at every step with $c\ge0.993$, so "flow" is **rigorous** (Theorem B3.3(a)). The KL is divided by the running minimum $c_K$ ($0.9966$ up to step 100 and $0.9932$ from step 200 on). Relative to $c=1$, this raises $R(Q)$ by at most $0.002$.

| step ($t$) | test err | $\Vert \Delta\Vert $ | $\Lambda$ | $\sqrt{tE}$ | $\sqrt{tL_0}$ | meas. | energy | flow (rigorous here) |
|---|---|---|---|---|---|---|---|---|
| 200 (4) | 0.047 | 1.11 | 1.2 | 1.2 | 1.4 | 0.42 (0.58) | 399, 0.45 | 819, **0.59** (0.75) |
| 500 (10) | 0.010 | 1.32 | 1.6 | 2.0 | 2.3 | 0.43 (0.61) | 707, 0.57 | 1024, **0.65** (0.84) |
| 1000 (20) | 0.003 | 1.60 | 2.2 | 2.9 | 3.2 | 0.42 (0.55) | 1701, 0.71 | 2048, **0.77** (0.89) |

**Adam, lr $10^{-3}$, $n=16384$.** Here "a priori" is B3.3(c) with $S_K=\sum_{t\le K}C_t$. "Max ratio" is the largest $|\hat m_t|/(\sqrt{\hat v_t}+\epsilon)$ seen over all coordinates and steps; Lemma B1.4 bounds it by $C_t$.

| target | step | test err | max ratio | meas.: KL, $R(Q)$ (det.) | a priori: KL, $R(Q)$ (det.) |
|---|---|---|---|---|---|
| $x_1$ | 50 | 0.014 | 1.56 | 620, 0.18 (0.25) | 5179, **0.44** (0.51) |
| $x_1$ | 100 | 0.000 | 1.63 | 920, 0.14 (0.17) | 21527, 0.78 (0.82) |
| $x_1$ | 300 | 0.000 | 1.63 | 940, 0.12 (**0.14**) | $3.9\times10^5$, 1.00 |
| MAJ$_3$ | 50 | 0.107 | 1.52 | 468, 0.33 (0.51) | 4014, 0.56 (0.74) |
| MAJ$_3$ | 100 | 0.005 | 1.66 | 977, 0.23 (0.34) | 22187, 0.84 (0.94) |
| MAJ$_3$ | 300 | 0.000 | 1.74 | 1890, 0.18 (**0.21**) | $5.4\times10^5$, 1.00 |

**Reading.**
1. **The B1 chain is very loose in the discrete-time, noisy setting.** For SGD at step 5000, $\|\Delta\|=3.7$, $\Lambda=85$ and $\sqrt{tE}=159$. The path wanders and mostly cancels; the energy counts the minibatch noise.
2. **The gradient-flow inequality holds for the actual displacement anyway.** $\|\Delta\|_{M^{-1}}\le\sqrt{tL_0}$ in every SGD and GD run (Numerical observation), but its discrete-time proof needs (D), which fails at $\eta=0.2$ after step 20. At $\eta=0.02$, (D) holds and the inequality is a theorem.
3. **Time-based bounds are non-vacuous only during and just after the first escape.** The rigorous ones are B3.3(a) while (D) holds, B3.3(b), and B3.3(c) for Adam.
   - At $n=2048$, (a) for GD with $\eta=0.02$ gives $R(Q)\le0.59$–$0.77$ while the test error falls from 4.7% to 0.3%. For GD at $\eta=0.2$, (a) holds only up to step 20, where it gives $0.90$, because $c_{20}=0.26$.
   - By (b), full-batch GD at the study's rate gives $0.46$ at step 20 (test error 5%) and is vacuous from step 50 on. SGD at $n=16384$ gives $0.39$ for $x_1$ at step 20 (test error 0.1%), and $0.85$ for MAJ$_3$ at step 50.
   - In the SGD runs the energy $\sum_gE_{K,g}$ grows from $10L_0$ at step 20 to $50L_0$ at step 5000 ($n=2048$). At fixed $\sigma$, the KL of (b) grows like $K^{1.2}$ over steps 20–5000, faster than linearly ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 5).
   - For Adam at $n=16384$, the a priori bound (c) is $0.44$–$0.56$ at step 50, uninformative ($>0.5$) by step 100, and vacuous by step 200.
   - Since the rate law puts all the time on plateaus, these bounds are useful only when the first escape happens immediately, as it does here at μP scale (Heuristic).
4. **Early stopping helps the measured bound, even though the function does not change.**
   - With Adam, the deterministic B3.2 bound is $0.17$ ($x_1$) and $0.34$ (MAJ$_3$) at step 100, and $0.14$ and $0.21$ at step 300. After 20000 steps it is $0.26$ and $0.40$ for the same targets.
   - With SGD at steps 100–300 it is $0.10$ ($x_1$) and $0.21$–$0.23$ (MAJ$_3$).
   - Each of these values holds on its own. Quoting the best checkpoint after the fact needs a union bound over the evaluated checkpoints for the Monte Carlo terms (end of Theorem B3.2). With the 10 checkpoints per target (5 for SGD and 5 for Adam), the best values become $0.11$ ($x_1$, SGD step 300) and $0.23$ (MAJ$_3$, SGD step 200) ([`checks/B_r2_checks.out`](checks/B_r2_checks.out), part 4).
   - At step 300 for $x_1$, SGD has moved the first two layers less than Adam (block displacements $\Vert\Delta(W_1,b_1)\Vert,\Vert\Delta(W_2,b_2)\Vert=1.9,1.0$ against $2.3,2.6$) and the readout more ($0.51$ against $0.24$). Continued training keeps moving the weights, and the KL grows with them. In the sweep ($n=16384$), $\|\Delta W_1\|_F$ for $x_1$ grows from $1.4$ at step 100, when the function is already fitted, to $8.6$ at step 20000.
   - *Mechanism (Heuristic).* Once the training loss is small but its minibatch gradients are still much larger than Adam's $\epsilon=10^{-8}$, the normalized update is mostly noise of about unit size per coordinate. The weights then random-walk, with $\|\Delta\theta_g\|\approx\eta\,m_g\sqrt{K\,p_g'}$, where $p_g'$ counts the coordinates with nonzero gradient. For $W_1$ ($p_1'=p_1$) this predicts $10^{-3}\sqrt{20000\cdot3968}=8.9$ after 20000 steps; the sweep measured $8.6$ ($x_1$) and $9.1$ (MAJ$_3$).
   - So for Adam, displacement-based bounds really do get worse with training time after the fit; early stopping is not only an artifact of the proof.
5. **Adam's per-step movement exceeds the learning rate in practice.** The ratio reaches $1.5$–$1.7$ within the first 100 steps, during the first escape, as Lemma B1.4 allows ($C_{100}=2.24$).
   - The informative comparison is at step 50. The largest ratio seen by then is $1.56$ ($x_1$) and $1.53$ (MAJ$_3$), against $C_{50}=1.61$, i.e. $97\%$ and $94\%$ of the worst case.
   - Over all coordinates and steps, the largest value of ratio$/C_t$ is $0.999994$, at $t=1$. That is trivial: $C_1=1$, and every first Adam step is a sign step up to $\epsilon$. The gap from $1$ is float32 rounding of the bias-correction constants, not $\epsilon$: with $\epsilon=0$, the float32 first step gives $0.9999933$ ([`checks/referee_B_r2.out`](checks/referee_B_r2.out), part 8).
   - The lemma is never violated. The folklore bound "$\le\mathrm{lr}$ per step" is violated by real runs, not only by adversarial sequences.

### 5.4 Read-off certificate (Numerical; Proposition 6.1; [`checks/readoff.py`](checks/readoff.py))

The same final networks as in 5.2. The bound is on the deterministic network's test error, with $\delta=0.05$. Means over 3 seeds; the worst seed is in brackets.

| target | $n$ | test err (actual) | junta read off | train err of $g$ | $\ln(1/\pi)$ | disagreement | bound on $R(f)$ |
|---|---|---|---|---|---|---|---|
| $x_1$ | 256 / 2048 / 16384 | 0 / 0 / 0 | $\{x_1\}$ | 0 | 6.7 | 0 | **0.040** / 0.005 / 0.001 |
| AND$_3$ | 256 / 2048 / 16384 | 0.029 / 0 / 0 | $\{x_1,x_2,x_3\}$ | 0 | 15.8 | 0.030 / 0 / 0 | **0.105** [0.125] / 0.010 / 0.001 |
| MAJ$_3$ | 256 / 2048 / 16384 | 0.041 / 0 / 0 | $\{x_1,x_2,x_3\}$ | 0 | 15.8 | 0.043 / 0 / 0 | **0.118** [0.122] / 0.010 / 0.001 |
| $x_1x_2$ | 256 / 2048 / 16384 | 0.002 / 0 / 0 | $\{x_1,x_2\}$ | 0 | 10.8 | 0.001 / 0 / 0 | **0.057** / 0.007 / 0.001 |
| $x_1x_2x_3$ | 256 | 0.480 | wrong 2–3 coordinates | 0.42 | 14.1 | 0.38 | 0.985 |
| $x_1x_2x_3$ | 2048 / 16384 | 0 / 0 | $\{x_1,x_2,x_3\}$ | 0 | 15.8 | 0 | 0.010 / 0.001 |
| thr$_{10}$ | 256 / 2048 / 16384 | 0.121 / 0.025 / 0.003 | 4–6 of the 10 coordinates | 0.10 / 0.07 / 0.07 | 32 / 60 / 60 | 0.15 / 0.08 / 0.07 | 0.47 / 0.23 / 0.17 |
| MAJ$_9$ | 256 / 2048 / 16384 | 0.101 / 0 / 0 | 5 of the 9 coordinates | 0.17 / 0.22 / 0.22 | 36 | 0.21 | 0.65 / 0.53 / 0.46 |
| $x_1x_2x_3x_4$ | 256 / 2048 / 16384 | 0.500 / 0.170 / 0 | wrong / $\{x_1..x_4\}$ / $\{x_1..x_4\}$ | 0.43 / 0.019 / 0 | 10 / 23 / 23 | 0.38 / 0.17 / 0 | 0.97 / 0.22 [0.46] / 0.002 |
| stair$_5$ | 256 / 2048 / 16384 | 0.360 / 0.003 / 0 | $\{x_1\}$ / $\{x_1..x_5\}$ / $\{x_1..x_5\}$ | 0.30 / 0 / 0 | 7 / 36 / 36 | 0.24 / 0.003 / 0 | 0.69 / **0.023** / 0.002 |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | 256 / 2048 / 16384 | 0.328 / 0.068 / 0 | mixed / $\{x_1..x_6\}$ / $\{x_1..x_6\}$ | 0.13 / 0 / 0 | 43 / 60 / 60 | 0.31 / 0.064 / 0 | 0.71 / **0.097** / 0.004 |
| mux$_4$ ($x_4\,?\,x_1x_2x_3:\mathrm{MAJ}_3$) | 256 / 2048 / 16384 | 0.345 / 0 / 0 | mixed / $\{x_1..x_4\}$ / $\{x_1..x_4\}$ | 0.23 / 0 / 0 | 32 / 23 / 23 | 0.26 / 0 / 0 | 0.76 / **0.013** / 0.002 |
| decision list on 5 vars | 256 / 2048 / 16384 | 0.046 / 0 / 0 | 3–4 of 5 / $\{x_1..x_5\}$ / $\{x_1..x_5\}$ | 0.010 / 0 / 0 | 18 / 36 / 36 | 0.042 / 0 / 0 | **0.16** / 0.019 / 0.002 |

The read-off certificate is **one to two orders of magnitude** better than every parameter-space bound.
- At $n=256$ it is informative for $x_1$, $x_1x_2$, AND$_3$, MAJ$_3$ and the decision list ($0.04$–$0.16$). It is not informative for $x_1x_2x_3$, whose $n=256$ networks failed ($0.985$).
- At $n=2048$ it gives $0.01$–$0.10$ for the staircase, multiplexer, decision list and MAJ of parities, and $0.22$ (worst seed $0.46$) for $x_1x_2x_3x_4$.
- Three 4–6-variable targets were also evaluated with B3.2: $x_1x_2x_3x_4$, the staircase and MAJ of parities. On them PAC-Bayes is vacuous at $n=2048$ and uninformative at $n=16384$.

The certificate fails in two kinds of cases.
- **The network itself failed:** $x_1x_2x_3$ and $x_1x_2x_3x_4$ at $n=256$ (test error about $0.5$), and the staircase, multiplexer and MAJ of parities at $n=256$ (test error $0.33$–$0.36$). The certificate correctly reports failure. For $x_1x_2x_3x_4$ at $n=2048$ the three seeds' networks have test errors $0.02$, $0.36$ and $0.14$, and their certificates are $0.04$, $0.46$ and $0.15$. Whenever the read-off junta is the target, the certificate tracks the actual test error to within $0.01$–$0.1$.
- **The circuit language is wrong:** MAJ$_9$ and the 10-variable threshold function. These networks do compute (nearly) the target, but no 6-junta is close to it, and a truth table on 9–10 variables costs hundreds of nats. A language with threshold gates would describe them cheaply.

### 5.5 Verdict

| bound | best case on the study's grid | verdict |
|---|---|---|
| B2.2 path norm (measured) | complexity at unit margin $c_{\rm path}=1.46$ ($x_1$, $n=16384$) | vacuous for all 49 networks evaluated; $c<1$ would need $\phi\lesssim19$ at $n=16384$, an informative bound ($<0.5$) $\phi\lesssim8$ |
| B2.3 Frobenius (measured) | $c_F=3.9$ ($x_1$, $n=16384$) | vacuous everywhere; $c_F>1$ even at the initialization's norms |
| B2.4 spectral, init reference | $24\varrho/n=679$ | vacuous by orders of magnitude |
| B3.1 a priori norms | $c_F=2.8$ ($n=16384$) to $22$ ($n=256$) at $t=0$, then growing with $t$ | vacuous |
| B3.2 PAC-Bayes, measured KL | 0.26–0.56 at $n=16384$ after 20000 Adam steps; 0.10–0.34 after 100–300 steps (best-of with union bound: 0.11 for $x_1$, 0.23 for MAJ$_3$); 0.55–1.0 at $n=2048$ | **the best parameter-space bound**; non-vacuous only at large $n$ |
| B3.3 PAC-Bayes, time-based | informative ($<0.5$) only early (up to $t\approx4$, or 50 Adam steps): 0.39 (SGD, $x_1$, step 20, via (b)); 0.46 (GD at $\eta=0.2$, step 20, via (b)); 0.45 (GD at $\eta=0.02$, step 200, its third checkpoint, via (b); 0.50 and 0.52 at steps 50 and 100); 0.46 and 0.44 (Adam, $x_1$, steps 20 and 50, via (c)); 0.59–0.77 via (a) for GD at $\eta=0.02$ | non-vacuous as far as evaluated for GD at $\eta=0.02$ ($t\le20$, where (a) gives 0.77 and (b) 0.71); for SGD and for GD at $\eta=0.2$, (b) is at least 0.99 by $t=10$–$40$; (c) for Adam is vacuous by step 200; (d) not evaluated |
| B3.4 online | within 0.006 of the measured mean test error of the window's iterates (slack 0.0057) | essentially exact, but only for one-pass training, and for the random-iterate predictor |
| 6.1 read-off junta | 0.04–0.16 at $n=256$ ($x_1$, $x_1x_2$, AND$_3$, MAJ$_3$, decision list); 0.01–0.10 at $n=2048$ (staircase, multiplexer, decision list, MAJ of parities), 0.22 for $x_1x_2x_3x_4$ | **best overall**, a posteriori, needs the known input distribution and a circuit language that fits |

## 6. What the circuit bounds have to beat

**The baseline.** On the study's grid, the best *parameter-space* statement about a trained network's test error is Theorem B3.2: for the deterministic network, $0.26$–$0.56$ at $n=16384$ for targets with at most three relevant variables ($0.10$–$0.34$ after 100–300 steps of SGD or Adam), $0.55$–$1.0$ at $n=2048$, and vacuous at $n=256$. Every norm-based uniform-convergence bound is vacuous. The time-based versions (B3.3) are informative only up to gradient-flow time $t\approx4$ (50 steps for Adam). They stay non-vacuous as far as evaluated for GD at $\eta=0.02$ ($t\le20$), but for SGD and for GD at $\eta=0.2$ they are at least $0.99$ by $t=10$–$40$. Meanwhile the networks themselves reach test error $0$ on $x_1$, $\mathrm{MAJ}_3$, $\mathrm{AND}_3$ and $x_1x_2$ from $n=2048$ on, and on $x_1$ already at $n=256$. They reach test error $\le0.07$ on most 4–6-variable targets at $n=2048$, where B3.2 is vacuous.

**Where the slack is (Heuristic diagnosis).**
1. **Norm bounds pay for the random features.** Uniform convergence over a norm ball charges for the roughly 30 units of path norm that are present at initialization and play no role in the learned function. A circuit bound charges only for the active circuit.
2. **PAC-Bayes pays for every moved parameter, at resolution $\sigma$.** For $x_1$ at $n=16384$ the KL is about $1800$ nats, mostly from $W_1$ and $W_2$ (Section 5.2). Any reasonable circuit language describes $x_1$ in $\ln(2d)\approx4$ nats. The displacement is spread over many hidden units, and the Gaussian posterior must keep all of them within $\sigma$. A prior that knows circuit structure (a sparsity mixture over which units are active, or over merged duplicate units, the README's "collapse" move) is where a circuit-based bound could save. This is where the discrete model has to enter.
3. **Time-based bounds pay for plateaus and for noise.** In our runs, $\sqrt{tL_0}$, the path length $\Lambda$ and $\sqrt{tE}$ exceed the actual displacement by factors of up to $7.1$, $23$ and $43$ (Section 5.3; [`checks/referee_B_r2.out`](checks/referee_B_r2.out), part 5). A bound that counts *moves*, as the rate law does, rather than *time* avoids both.

### Proposition 6.1 (a posteriori read-off certificate; Proved)

Let $\mathcal G$ be a countable class of predictors $\{-1,1\}^d\to\{-1,1\}$ with weights $\pi(g)>0$, $\sum_g\pi(g)\le1$, fixed in advance. Let $f$ be any predictor; it may be the trained network and may depend on $S$. Let $g_0,\dots,g_K\in\mathcal G$ be selected by **any** rule that uses $f$, $S$ and unlabeled inputs. Let $\hat\Delta_j$ be the rate of disagreement between $\mathrm{sgn}\,f$ and $g_j$ on $m$ fresh uniform unlabeled inputs, independent of everything else. Then with probability at least $1-\delta_1-\delta_2$, for all $j$,
$$R(f)\le\mathrm{kl}^{-1}\Big(\hat R_S(g_j),\ \frac{\ln(1/\pi(g_j))+\ln(1/\delta_1)}n\Big)+\mathrm{kl}^{-1}\Big(\hat\Delta_j,\ \frac{\ln((K+1)/\delta_2)}m\Big).$$

*Proof.*
- **Occam step.** For each fixed $g$, Chernoff gives $\Pr_S[\mathrm{kl}(\hat R_S(g)\|R(g))>\varepsilon_g,\ \hat R_S(g)<R(g)]\le e^{-n\varepsilon_g}$. With $\varepsilon_g=(\ln(1/\pi(g))+\ln(1/\delta_1))/n$, a union bound over $\mathcal G$ costs at most $\delta_1$. This covers any data-dependent choice of $g$.
- **Disagreement step.** Conditionally on $(f,g_0,\dots,g_K)$ the fresh inputs are iid. So kl-Chernoff and a union bound over $j$ cost $\delta_2$.
- **Triangle inequality.** Pointwise, $\mathbb 1[\mathrm{sgn}f(x)\ne y]\le\mathbb 1[g(x)\ne y]+\mathbb 1[g(x)\ne\mathrm{sgn}f(x)]$. $\square$

**Instantiation** ([`checks/readoff.py`](checks/readoff.py)). Let $\mathcal G$ be the juntas: a size $k\le6$, a $k$-subset of coordinates, and a truth table, with $\pi=1/(7\binom dk2^{2^k})$. For $k=3$, $\ln(1/\pi)=15.80$ nats.
1. **Select coordinates.** Rank coordinates by their influence on $\mathrm{sgn}f$, estimated on $2\times10^4$ unlabeled inputs. Take the top $k$.
2. **Select the truth table.** In each of the $2^k$ cells, take the majority of $\mathrm{sgn}f$.
3. **Evaluate.** Use $m=10^5$ fresh unlabeled inputs and $\delta_1=\delta_2=0.025$.

No labels outside $S$ and no knowledge of the target are used. The results (Section 5.4) are $0.04$ ($x_1$), $0.06$ ($x_1x_2$), $0.11$ (AND$_3$) and $0.12$ (MAJ$_3$) at $n=256$, and $\le0.01$ at $n=2048$, for the same networks on which B3.2 is vacuous or borderline. At $n=2048$ it is $0.01$–$0.10$ for the staircase, multiplexer, decision-list and MAJ-of-parities targets, and $0.22$ (seeds $0.04$, $0.46$, $0.15$) for $x_1x_2x_3x_4$, whose networks have test errors $0.02$, $0.36$ and $0.14$. It fails for MAJ$_9$ and the 10-variable threshold function, whose networks are not close to 6-juntas.

**What this means for tasks A and C.** For the simple targets, a rigorous and non-vacuous bound on the *actual* network already exists at $n=256$. It reads a small circuit off the trained network and pays for the read-off by measuring disagreement on unlabeled inputs, which is possible because the input distribution is known.
- It is an a posteriori certificate, not an explanation: it does not say why GD produced a near-junta, or how long that takes.
- The circuit-growth model can supply the a priori half. If one could prove "after time $t$, GD's output is $\varepsilon$-close to a circuit with at most $s(t)$ gates", Proposition 6.1 would turn that into a "short training implies generalization" theorem with $\ln(1/\pi)\approx s\ln(\text{gate choices})$ nats in place of the thousands of nats of B3.2–B3.3.
- So the baseline for tasks A and C is twofold: beat B3.2 and B3.3 with an a priori argument, and match Proposition 6.1 a posteriori.
- Compression-based generalization bounds in the literature use the same structure: compress, then bound the compressed predictor (Arora–Ge–Neyshabur–Zhang, ICML 2018; Zhou–Veitch–Austern–Adams–Orbanz, ICLR 2019). Here, measuring disagreement on unlabeled data replaces their noise-stability arguments.

A time-based version would follow from Conjecture 6.2, which tasks A and C are positioned to address.

**Conjecture 6.2 (what a circuit-growth bound would need).** In the rich regime with μP or small initialization, there are a circuit language $\mathcal G$ with $\ln(1/\pi(g))\le c_1\,\mathrm{size}(g)\ln(d+\mathrm{size}(g))$ and a function $s(t)$ such that GD's network at time $t$ is within disagreement $\varepsilon(t)$ (under the input distribution) of some $g\in\mathcal G$ of size at most $s(t)$. Here $s(t)$ grows like the number of moves of the rate law fired by time $t$, not like $t$ itself. Proposition 6.1 then gives $R(f_t)\le\mathrm{kl}^{-1}\big(\hat R_S(g),(c_1s(t)\ln(d+s(t))+\ln(1/\delta))/n\big)+\varepsilon(t)$. This is the circuit form of the user's "the circuit cannot have grown that big yet". Section 5.4 supports it a posteriori for the simple targets: the networks are $0$–$5\%$-close to the right 1–3-juntas (the largest disagreement is $0.0498$, for one AND$_3$ network at $n=256$). Nothing here proves it.

## 7. Files

All scripts are in [`checks/`](checks/). They use numpy, scipy and jax and run in seconds to a few minutes. They read the study's raw sweep outputs without modifying them. Those outputs are kept outside the repository; set `RESULTS=` to their folder.

| file | contents |
|---|---|
| [`checks/nnbounds.py`](checks/nnbounds.py) | the bound calculators of Sections 3 and 4; `python3 nnbounds.py` runs self-tests (rebalancing identity, $\lvert f\rvert\le\phi_1$, the $P_F$ identity) |
| [`checks/adam_ratio.py`](checks/adam_ratio.py) → [`adam_ratio.out`](checks/adam_ratio.out) | Lemma B1.4: closed form against the extremal sequence and a numerical search |
| [`checks/trivial_gronwall.py`](checks/trivial_gronwall.py) → [`trivial_gronwall.out`](checks/trivial_gronwall.out) | Remark B1.5 |
| [`checks/representative.py`](checks/representative.py) → [`representative.out`](checks/representative.out) | Section 5.1 |
| [`checks/eval_saved.py`](checks/eval_saved.py) → `eval_saved.json`, [`eval_saved_part1.out`](checks/eval_saved_part1.out), [`_part2`](checks/eval_saved_part2.out), [`_part3`](checks/eval_saved_part3.out), [`_part4`](checks/eval_saved_part4.out) | Section 5.2: all data-dependent bounds on the final Adam networks of the sweep. The first run hit its time limit before writing JSON; [`checks/parse_out.py`](checks/parse_out.py) recovers its rows from the printed lines |
| [`checks/sgd_short.py`](checks/sgd_short.py) → `sgd_short_<fn>_<n>_<mode>[_eta].json` and `.log` | Section 5.3: SGD, full-batch GD and Adam trajectories, the B1 inequalities and the time-based bounds. Revision 2 reran all seven runs with two code changes: the certified closed form for $P^{\max}$ (B3.1), and the measured descent constant $c_K$ for the flow column. All other recorded numbers are reproduced exactly |
| [`checks/readoff.py`](checks/readoff.py) → `readoff.json`, [`readoff.out`](checks/readoff.out) | Proposition 6.1 and Section 5.4 |
| [`checks/summarize.py`](checks/summarize.py) → [`summary_tables.txt`](checks/summary_tables.txt) | all tables of Section 5 |
| [`checks/rademacher_lower.py`](checks/rademacher_lower.py) → [`rademacher_lower.out`](checks/rademacher_lower.out) | sharpness of $\kappa_{\rm path}$ (after Proposition B2.2) |
| [`checks/contraction_check.py`](checks/contraction_check.py) → [`contraction_check.out`](checks/contraction_check.out) | brute-force check of Lemma B2.0 |
| [`checks/referee_B_r1.py`](checks/referee_B_r1.py) → [`referee_B_r1.out`](checks/referee_B_r1.out), [`referee_B_r1.json`](checks/referee_B_r1.json) | round-1 referee checks and report |
| [`checks/referee_B_r2.py`](checks/referee_B_r2.py) → [`referee_B_r2.out`](checks/referee_B_r2.out), [`referee_B_r2.json`](checks/referee_B_r2.json) | round-2 referee checks and report |
| [`checks/B_r2_checks.py`](checks/B_r2_checks.py) → [`B_r2_checks.out`](checks/B_r2_checks.out) | revision 2 (about 30 s): unit-margin complexities, margins and the vacuity criterion on the 49 sweep networks; the measured descent constant; certified $P^{\max}$; early-stopping union bounds; growth of the B3.3 KL bounds; the constants of B3.3(d); one-pass Adam runs evaluating Proposition B3.4 |

Other files in `checks/` belong to the sibling tasks A and C.

**Re-running on new sweep outputs.** For example, once the SGD part of the sweep has finished:
```
cd gd-circuit-growth/theory/checks
OPT=sgd RESULTS=<sweep output folder> python3 eval_saved.py dict,and3,maj3,par2   # appends rows tagged opt=sgd
OPT=sgd RESULTS=<sweep output folder> python3 readoff.py dict,and3,maj3,par2       # writes readoff_sgd.json
OPT=sgd python3 summarize.py
```
Each network takes about a minute (the PAC-Bayes search dominates). `NS=` and `SEEDS=` restrict the grid.

## References

**Capacity and margins**
- Bartlett, Foster, Telgarsky. *Spectrally-normalized margin bounds for neural networks.* NeurIPS 2017. [arXiv:1706.08498](https://arxiv.org/abs/1706.08498)
- Golowich, Rakhlin, Shamir. *Size-independent sample complexity of neural networks.* COLT 2018; Information and Inference 2020. [arXiv:1712.06541](https://arxiv.org/abs/1712.06541)
- Neyshabur, Tomioka, Srebro. *Norm-based capacity control in neural networks.* COLT 2015. [PMLR](https://proceedings.mlr.press/v40/Neyshabur15.pdf)
- Gonon, Brisebarre, Riccietti, Gribonval. *A path-norm toolkit for modern networks: consequences, promises and challenges.* ICLR 2024. [arXiv:2310.01225](https://arxiv.org/abs/2310.01225)
- Koltchinskii, Panchenko. *Empirical margin distributions and bounding the generalization error of combined classifiers.* Ann. Statist. 30 (2002).
- Mohri, Rostamizadeh, Talwalkar. *Foundations of Machine Learning*, 2nd ed., MIT Press 2018 (Theorems 3.3, 5.8).
- Ledoux, Talagrand. *Probability in Banach Spaces.* Springer 1991 (Theorem 4.12).
- Boucheron, Lugosi, Massart. *Concentration Inequalities.* OUP 2013 (Theorem 6.2).
- Srebro, Sridharan, Tewari. *Smoothness, low noise and fast rates.* NeurIPS 2010 (Lemma A.3, Dudley integral).

**PAC-Bayes**
- McAllester. *PAC-Bayesian model averaging.* COLT 1999.
- Langford, Seeger. *Bounds for averaging classifiers.* CMU tech. report 2001; Seeger, JMLR 2002.
- Maurer. *A note on the PAC Bayesian theorem.* 2004. [arXiv:cs/0411099](https://arxiv.org/abs/cs/0411099)
- Langford, Caruana. *(Not) bounding the true error.* NeurIPS 2001.
- Dziugaite, Roy. *Computing nonvacuous generalization bounds for deep (stochastic) neural networks with many more parameters than training data.* UAI 2017. [arXiv:1703.11008](https://arxiv.org/abs/1703.11008)

**Compression**
- Arora, Ge, Neyshabur, Zhang. *Stronger generalization bounds for deep nets via a compression approach.* ICML 2018.
- Zhou, Veitch, Austern, Adams, Orbanz. *Non-vacuous generalization bounds at the ImageNet scale: a PAC-Bayesian compression approach.* ICLR 2019.

**Optimization**
- Kingma, Ba. *Adam: a method for stochastic optimization.* ICLR 2015.
- Défossez, Bottou, Bach, Usunier. *A simple convergence proof of Adam and Adagrad.* TMLR 2022.
- Davis, Drusvyatskiy, Kakade, Lee. *Stochastic subgradient method converges on tame functions.* Found. Comput. Math. 2020.
- Cohen, Kaur, Li, Kolter, Talwalkar. *Gradient descent on neural networks typically occurs at the edge of stability.* ICLR 2021.

**Stability, information theory, online-to-batch**
- Hardt, Recht, Singer. *Train faster, generalize better: stability of stochastic gradient descent.* ICML 2016. [arXiv:1509.01240](https://arxiv.org/abs/1509.01240)
- Feldman, Vondrák. *High probability generalization bounds for uniformly stable algorithms with nearly optimal rate.* COLT 2019.
- Bousquet, Klochkov, Zhivotovskiy. *Sharper bounds for uniformly stable algorithms.* COLT 2020.
- Xu, Raginsky. *Information-theoretic analysis of generalization capability of learning algorithms.* NeurIPS 2017.
- Steinke, Zakynthinou. *Reasoning about generalization via conditional mutual information.* COLT 2020.
- Pensia, Jog, Loh. *Generalization error bounds for noisy, iterative algorithms.* ISIT 2018.
- Mou, Wang, Zhai, Zheng. *Generalization bounds of SGLD for non-convex learning: two theoretical viewpoints.* COLT 2018.
- Negrea, Haghifam, Dziugaite, Khisti, Roy. *Information-theoretic generalization bounds for SGLD via data-dependent estimates.* NeurIPS 2019.
- Neu, Dziugaite, Haghifam, Roy. *Information-theoretic generalization bounds for stochastic gradient descent.* COLT 2021.
- Cesa-Bianchi, Conconi, Gentile. *On the generalization ability of on-line learning algorithms.* IEEE Trans. Inf. Theory 50 (2004).

## Revision notes

**Revision 2** (23 October 2026), after the round-1 referee report [`checks/referee_B_r1.json`](checks/referee_B_r1.json) (verdict: fail, because of two major issues in Theorem B3.3). The changes are listed in the order of the report. New numbers come from [`checks/B_r2_checks.py`](checks/B_r2_checks.py) → [`checks/B_r2_checks.out`](checks/B_r2_checks.out) and from rerunning [`checks/sgd_short.py`](checks/sgd_short.py) and [`checks/summarize.py`](checks/summarize.py). The rerun reproduces every previously recorded number exactly, except the two quantities whose code was changed (items 4 and 5).

1. **(major) Theorem B3.3, "linear in training time".** The claim is now restricted to part (a): gradient flow, and GD under (D).
   - (b) is now described as $t_KE_K$. It is linear only while the energies stay bounded, which (D) guarantees and minibatch noise does not. In the SGD runs the energy reaches $50\,L_0$, and at fixed $\sigma$ the KL of (b) grows like $K^{1.2}$.
   - (c) is now stated to be quadratic in $K$. Proof: $C_t\ge1$, so $S_K\ge K$.
   - Section 0 item 2, the results table and the SGLD remark in 4.5 (now "the same as B3.3(a)") are adjusted to match.
2. **(major) Theorem B3.3, "Reading".**
   - The condition is now phrased in gradient-flow time, $t\le\varepsilon n/200$. That is $25\,\varepsilon$ full-batch GD steps per 1000 samples at $\eta=0.2$, or $250\,\varepsilon$ at $\eta=0.02$, **provided (D) holds**. The text records that (D) holds at $\eta=0.02$ but at $\eta=0.2$ only for the first 20 steps.
   - It now says that (a) is not a theorem for SGD, and that "Section 5.3 checks this" applied only to the non-rigorous flow column.
   - New **part (d)**, Proved under the hypotheses of Proposition B1.3: an a priori SGD version obtained from B1.3. It has two forms: (d1) with high probability over the minibatches, by Markov's inequality, at a cost of $1/\delta'$; and (d2) for the mixture over SGD runs, by convexity of KL (data processing), with no $1/\delta'$. Both carry the noise term $2\eta\beta\nu^2t^2/B$.
   - The constants of (d) are evaluated: KL $\le0.1n$ at $n=16384$ needs $t\le2.0$ for (d2) and $t\le0.02$ for (d1), against $t\le8.2$ for (a). (d) is not evaluated on the networks, because smoothness fails for ReLU.
3. **(minor) Theorem B3.2, Monte Carlo independence.** The statement and proof step 2 now require that the $m$ final draws are made after $\sigma$ is fixed and independently of the search. "Any rule is allowed" is now restricted to (PB). A rule is added for quoting the best of $J$ bounds: use $\delta_1/J$ and $\delta_2/J$.
4. **(minor) Section 5.3, GD at $\eta=0.02$, measured $c$.** `sgd_short.py` now divides the flow KL by $c_K$, the running minimum of the measured descent ratio, and marks the value rigorous only while (D) has held. After the rerun, the flow column reads $0.59$ $(0.75)$, $0.65$ $(0.84)$ and $0.77$ $(0.89)$ at steps 200, 500 and 1000; the step-1000 value $0.76$ became $0.77$.
   - The rerun also shows that at $\eta=0.2$, (D) holds for the first 20 steps with $c_{20}=0.26$. So the flow bound at step 20 is rigorous there, and its value is $0.90$, not $0.59$. The table and text are updated.
5. **(minor) Theorem B3.1, certified $P^{\max}$.** `sgd_short.py` now uses the closed-form upper bound. The random search is kept and labelled as a lower estimate; the closed form is larger by a factor of $1.0$–$3.4$. The summary tables were regenerated.
   - The $t=0$ values are now quoted as a complexity term at unit margin of $2.8$, $7.8$ and $22$ at $n=16384$, 2048 and 256, and a printed bound of $2$–$3$. The verdict row is corrected; it previously said "$\ge3$".
6. **(minor) Margin bounds at the grid edge.**
   - New **Lemma B2.1a** (Proved): if $c\ge\max(1,\bar m_+)$, then B2.1 is at least $1$ at every margin.
   - Table 5.2 now reports $c_{\rm path}$ and $c_F$ instead of the minimized bounds. All 49 networks satisfy the criterion ($\bar m_+=0.99$–$1.01$), and with $\gamma_{\max}=1000$ their bounds are $1.02$–$1.27$.
   - "Vacuous by 2–26×" and "1.13" are replaced by $c$ values. The ranges are corrected: the B2.3 bound in the table goes up to 34.9, and the path norm of the trained networks to 610 (it was "26–543").
7. **(minor) Sharpness of the path-norm constant.** The claim "the vacuity comes from the norms, not from the constants" is qualified. It holds for most networks. In the borderline cases ($x_1$, AND$_3$ and $x_1x_2$ at $n=16384$, and one MAJ$_3$ network there), $c_{\rm path}$ would fall below $1$ if $\kappa$ were at its lower estimate $1.17$.
8. **(minor) Dudley assembly in Theorem B2.4.** The zero function is now added to the ramp class. This adds at most $\min(12\sqrt{\ln2/n},3\ln2/\varrho)$ to the bound on $\hat{\mathfrak R}_S$; the derivation is given. `nnbounds.spectral_bound` is updated accordingly. The changed branch ($3\varrho\le n$) is never reached on the study's networks, so no reported number changes.
   - "$24\varrho/n$ is a lower bound on $2\hat{\mathfrak R}_S$" is reworded: it is a lower bound on the BFT+Dudley *upper bound* on $2\hat{\mathfrak R}_S$.
9. **(minor) Xu–Raginsky and CMI.** These are now described as applying to the 0-1 loss for any algorithm, but vacuous with the computable bounds on $I(S;W)$ and the CMI. "Does not apply" is kept for HRS only. Section 0 item 7, the results table and the protocol table (HRS and Xu–Raginsky/CMI are now separate columns) are changed to match.
10. **(minor) Early-stopping numbers.**
    - The full range is now given, $0.10$–$0.34$ at steps 100–300, including Adam on MAJ$_3$ at step 100 ($0.34$).
    - The text states that each checkpoint's bound holds on its own.
    - Best-of values are quoted with a union bound over the 10 evaluated checkpoints per target: $0.11$ for $x_1$ and $0.23$ for MAJ$_3$.
    - Updated in Section 0 item 4, Section 5.3 reading 4, Section 5.5 and Section 6.
11. **(minor) Proposition B3.4.**
    - The window must now be fixed in advance; a union bound is needed otherwise.
    - The text states that the bound is on the random-iterate predictor, not on the final network.
    - Because the study's online runs do not log $e_k$, B3.4 is now **evaluated** on new one-pass Adam runs with the study's online settings that do log them ($x_1$, MAJ$_3$, $x_1x_2x_3$; 3000 steps; three windows fixed in advance). In every window the bound is within $0.006$ of the measured mean test error of the iterates. The table entries now give this evaluation instead of "essentially exact".
12. **(minor) Proposition 6.1, Section 5.4, Section 0 item 8 and Conjecture 6.2.**
    - The targets are now named explicitly. The certificate is informative at $n=256$ for $x_1$, $x_1x_2$, AND$_3$, MAJ$_3$ and the decision list, not for $x_1x_2x_3$. At $n=2048$, $x_1x_2x_3x_4$ gives $0.22$, with worst seed $0.46$.
    - $\ln(1/\pi)=15.80$ for $k=3$.
    - "0–4%-close" is now "0–5%" (the largest disagreement is $0.0498$).
    - Also corrected: "the other 4–6-variable targets at $n=256$" failed. It now names the staircase, multiplexer and MAJ of parities; the decision list succeeds there.
13. **(minor) Section 0 items 1 and 5.**
    - Item 1 now says that B1.3 is weaker than B1.1: a factor 4 and an additive noise term quadratic in $t$.
    - Item 5 is rewritten to match Section 5.3: the rigorous values by part, the step and time ranges, and "informative only up to $t\approx4$".
    - The $0.39$ value is now described as SGD on $x_1$ at step 20, where the test error is already $0.001$.
14. **(minor) B3.3(b) presentation.** It is now presented as a diagnostic of the looseness of the energy route, which is always weaker than B3.2 with the measured displacement, not as an a priori SGD statement. Updated in the Reading of B3.3 and in Section 0 item 5.
15. **(minor) "Vacuous already at initialization".**
    - The claim is narrowed to the 49 evaluated Adam networks at $n\in\{256,2048,16384\}$.
    - Section 3 now says that what is meant is the complexity term at the initialization's norms. The bound evaluated at $\theta_0$ itself is trivially vacuous, because the initial margins are about 0.05.
    - "Dominated by random features" is labelled Heuristic, with the counterexample that the path norm of $x_1$ at $n=16384$ is $26$ after training and $32$ at initialization.
16. **(minor) Wording in Section 5.3 reading 5, Remark B1.5 and Section 5.2.**
    - (i) The maximum of ratio$/C_t$ is $0.999994$ at $t=1$, which is trivial. The informative comparison is now given: ratio$/C_{50}=0.97$ ($x_1$) and $0.94$ (MAJ$_3$).
    - (ii) The table entry for B1.5 now says $5\times10^{-5}$ steps.
    - (iii) Section 5.2 now says that the bounds use the float16 weights, while "test err (actual)" is the float32 sweep value. The float16 rounding changes the predictions on at most 0.05% of test inputs.

**Other changes.**
- The gradient-noise constant of Proposition B1.3 is renamed $\nu$, to avoid a clash with the PAC-Bayes $\sigma$.
- The Files table lists the new check script and the referee files.
- `summarize.py` now prints $c_{\rm path}$, $c_F$, the B3.1 complexity at unit margin, $c_K$, and a star marking the rows where B3.1 and B3.3(a) are rigorous.

**Round-2 referee** (23 October 2026), after the round-2 referee report [`checks/referee_B_r2.json`](checks/referee_B_r2.json) (verdict: pass; 8 minor issues, no major ones). The changes are listed in the order of the report. New numbers come from the report, from [`checks/referee_B_r2.out`](checks/referee_B_r2.out), and from the existing [`checks/B_r2_checks.out`](checks/B_r2_checks.out) and [`checks/summary_tables.txt`](checks/summary_tables.txt). No script was rerun, no status label was raised, and no claim was strengthened.

1. **(minor) B3.3 Reading, (b) bullet.** "$7$–$35$ times the flow value" is now "$2$–$44$ times the flow value over the 18 SGD checkpoints" ($1.9$–$44.3$ in the referee's recomputation). The two former figures are kept as examples.
2. **(minor) Section 5.5 B3.3 row and Section 6 baseline paragraph.**
   - "Only at the first checkpoint" is replaced by the informative values with their steps: SGD on $x_1$ at step 20 ($0.39$); GD at $\eta=0.2$ at step 20 ($0.46$); GD at $\eta=0.02$ at step 200, its third checkpoint ($0.45$; steps 50 and 100 give $0.50$ and $0.52$); Adam on $x_1$ at steps 20 and 50 ($0.46$ and $0.44$).
   - "Non-vacuous at most up to $t\approx20$" was an extrapolation. It is replaced by: non-vacuous as far as evaluated for GD at $\eta=0.02$ ($t\le20$, where (a) gives $0.77$ and (b) $0.71$); for SGD and for GD at $\eta=0.2$, (b) is at least $0.99$ by $t=10$–$40$; (c) for Adam is vacuous by step 200.
   - Section 6 is reworded to match.
3. **(minor) Section 0.**
   - The opening sentence now names the dynamics for which the intuition goes through rigorously: gradient flow, full-batch GD while (D) holds (checked a posteriori), and Adam (with a bound quadratic in $K$). For SGD on ReLU networks it goes through only via measured quantities.
   - Item 5 now attributes the descent-condition finding to our single GD run (MAJ$_3$, $n=2048$, seed 0, $\eta=0.2$), not to full-batch GD in general.
4. **(minor) Remark after Lemma B2.1a.**
   - It now states the condition under which the minimum sits at the grid edge: $c\ge\bar m_+$ and $\gamma_{\max}$ at least the largest train margin. The referee's one-line argument is included.
   - The limit as $\gamma_{\max}$ grows is corrected from $1$ to $1+\mathrm{conf}_{j,0}$.
   - Section 5.2, which said the $\gamma_{\max}=1000$ values "measure $\gamma_{\max}$", now says that they reflect $\gamma_{\max}$ and the confidence term.
5. **(minor) Section 3, thresholds in "Why distance from initialization does not rescue the norm bounds".** The guaranteed thresholds no longer include the grid factor $q$: $4.4\times10^4$ for the path norm and $1.1\times10^5$ for Frobenius. The former values, $5.3\times10^4$ and $1.4\times10^5$, are kept as the sample sizes up to which $c\ge1$ is possible but not guaranteed.
6. **(minor) Theorem B3.2, "Several networks or checkpoints".** "(PB) needs no such split" now requires that all $J$ evaluations use the same $S$, $\theta_0$ and $\Sigma$. This holds for the 10 checkpoints per target of Section 5.3. Across seeds or samples, $\delta_0$ must be split as well.
7. **(minor) Proposition B3.4, Evaluation paragraph.** The text now says that the existing outputs of the study's online runs predate the logging of progressive errors. `run_online` has since been changed to record them per chunk. B3.4 should be evaluated on the study's own online runs once these are rerun, with the per-chunk windows fixed in advance. That evaluation is not done here.
8. **(minor) Small slips.**
   - (i) Section 6: $\sqrt{tL_0}$ exceeds the displacement by up to $7.1$ (GD at $\eta=0.02$, step 5), not $6$.
   - (ii) Section 5.3 reading 5: the $0.999994$ is now attributed to float32 rounding of the bias-correction constants, not to $\epsilon$. With $\epsilon=0$ the float32 first step gives $0.9999933$.
   - (iii) B3.2 proof, step 3: the sentence "Ties have probability zero under $Q$; a tie of $f_\theta$ makes the second term $1$" is dropped. The first half is false for ReLU, where all layer-2 units can be inactive with positive $Q$-probability. In its place, the proof notes that the pointwise inequality holds in every case, ties included.
   - (iv) Section 5.2 reading: the $c_F$ range $3.9$–$136$, and the spectral range, are now said to be over the table's rows. Over all 49 networks, $c_F=3.7$–$180$ and $c_{\rm path}=1.46$–$115$; three $n=256$ networks are not in the table.
   - (v) Section 5.3 reading 3: the sentence "Since the rate law puts all the time on plateaus, …" is now labelled Heuristic.

**Other changes in this round.** The header now says that the round-2 minor issues have been applied. The Files table lists the round-2 referee files.
