# D. Early-phase theorems: what gradient descent provably keeps small

Notes by Claude, prompted by Kaarel Hänni. Research note, 23 October 2026. Written by a separate agent, after A, B and C. Refereed twice: round 1 passed it with minor revisions ([`checks/referee_D_r1.json`](checks/referee_D_r1.json)), and round 2 passed the revised version with minor issues only ([`checks/referee_D_r2.json`](checks/referee_D_r2.json)). This version applies the round-2 fixes; the changes of both rounds are listed in the [revision notes](#revision-notes). Not reviewed by a human.

**Question (from the user, via the project README).** Generalization bounds of the form "training has not taken long, so the circuit cannot have grown big, so a Chernoff bound over small circuits applies". The README calls the missing link *an a priori theorem that gradient descent keeps a real network close to a circuit whose size is controlled by $\tau/\log(1/\alpha)$*. That is the "saddle-to-saddle approximation" hypothesis SSA of [C3](C-bridge-and-certificates.md#33-the-conditional-theorem). This file attempts it.
- **Part I** treats the two-layer ReLU network from balanced small initialization.
- **Part II** treats a two-layer *quadratic* network, a non-diagonal network with a shared hidden layer. Its output weights are fixed at $\pm1$ and its units are centred, so it is symmetric matrix sensing rather than a fully trained two-layer network. There a time-indexed statement is proved, in weight-free form: it uses the training-loss curve, but not the weights.

**Status labels**, as in A, B and C:
- **Proved:** a complete proof with explicit constants is in this file. The two standard probabilistic lemmas are re-proved in §0.
- **Literature:** a published result. "(from memory)" means I did not check the statement against the paper. Where an abstract or search summary was checked, I say so.
- **Conjecture / Heuristic:** as usual.
- **Numerical:** a check by [`checks/D_relu_check.py`](checks/D_relu_check.py) (output [`checks/D_relu_check.out`](checks/D_relu_check.out)) or [`checks/D_quad_check.py`](checks/D_quad_check.py) (output [`checks/D_quad_check.out`](checks/D_quad_check.out)).

## Summary

**Part I, two-layer ReLU networks** $f(x)=\sum_ja_j\,\mathrm{relu}(w_j\cdot\tilde x)$ on $\{-1,1\}^d$, from balanced initialization $|a_j(0)|=\|w_j(0)\|$, trained by gradient flow on the empirical square loss. All of this holds for any data, any width, and any choice of subgradient at the kinks.

1. **The exact race (Lemma D1, Proved).** The network's dynamics contains a race with a clock, with no approximation:
   - **Mass clock.** Each neuron's mass $\rho_j=a_j^2+\|w_j\|^2$ obeys $\rho_j(t)=\rho_j(0)\exp\big(2\int_0^t\epsilon_jU_{r(s)}(\hat w_j(s))\,ds\big)$, where $U_r(v)=\langle r,\mathrm{relu}(v\cdot\tilde x)\rangle_n$ is the utility of direction $v$ for the current residual $r$, and $\epsilon_j$ is the fixed sign of $a_j$.
   - **Scale-free search.** The direction $\hat w_j$ follows the projected (sub)gradient of $\epsilon_jU_r$ on the sphere, whatever the neuron's size.
   - **Function.** The function is the signed measure $f_t=\sum_j\epsilon_j\frac{\rho_j}{2}\,\mathrm{relu}(\hat w_j\cdot\tilde x)$, so its variation norm is at most $P/2$, where $P=\sum_j\rho_j=\|\theta\|^2$.
   - **Merging law.** For two neurons of the same sign, $Q_{jk}=\|w_j\|\|w_k\|(1-\cos\angle(w_j,w_k))$ is *exactly conserved* while they share an activation pattern on the training set. This is not new: it is the off-diagonal entry of the classical balancedness conservation law $W_1W_1^\top-W_2^\top W_2=\text{const}$ of two-layer linear networks (Arora–Cohen–Hazan 2018; Du–Hu–Lee 2018), applied to a pair of neurons that share their selections, which is locally a linear network. For ReLU networks only the diagonal entries are conserved globally (Marcotte–Gribonval–Peyré 2023; see Lemma D1(g)). What may be new are the monotonicity statements: $Q_{jk}$ is nonincreasing whenever the residual has the "attracting" sign at every training point separating them, with a growth bound otherwise. While either the conservation or the monotonicity holds, $1-\cos$ within a cluster (about half the squared angle) shrinks like $1/\text{mass}$, so the angle itself shrinks like $\text{mass}^{-1/2}$.
2. **No growth before $\log(1/\alpha)/U^*$ (Theorem D2, Proved).**
   - **Statement.** $P(t)$ cannot reach $\beta$ before $T_\beta=\ln(\beta/P(0))\big/\big(2(U_0^*+\lambda_X\beta/2)\big)$. Here $U_0^*=\sup_v|U_y(v)|$ is the largest initial utility, and $\lambda_X$ is the top eigenvalue of the empirical second-moment matrix of $\tilde x$.
   - **Until then, the network is the empty circuit:** $\sup_x|f_t(x)|\le\frac{\sqrt{d+1}}2\beta$.
   - **The leading constant is sharp.** Since $t_\beta$ is nondecreasing in $\beta$, the statement gives $\liminf_{\alpha\to0}t_\beta U_0^*/\ln(1/\alpha)\ge1$ for every selection flow, at every fixed $\beta>0$ and width. In an explicit instance ($y=x_1$ on the full cube, one neuron started at the maximizer of $U_y$), the escape time is $\ln(1/\alpha)/U_0^*+O(1)$, so the $1$ is attained (Theorem D2(6)). So no lower bound valid for all data can have a larger leading constant. The lower-order terms are not claimed to be sharp.
   - **Comparison with C3.1.** This improves Lemma C3.1, which used $\sqrt{\lambda_X}\|y\|_n$ in place of $U_0^*$, to the leading constant of the README's rate law.
   - **A certified upper bound** on the nonconvex supremum $U^*$ is given by two eigenvalue computations (Lemma D2.1). It is within 1.5–12% of a multistart estimate in the checks.
   - **Quantization (Proposition D2.2).** Before $T_\beta$, each neuron's direction is an approximate critical point of $\pm U_y$ except during $O(1)$ total time, uniformly in $\alpha$.
3. **Through the escape: width-free size and generalization (Theorem D3 and its corollaries, Proved).**
   - **Path norm, two bounds.** For all $t$, $P(t)\le\beta+\|y\|_n^2(t-T_\beta)_+$ (a priori), and $\sqrt{P(t)}\le\sqrt\beta+\int_{T_\beta}^t\sqrt{-\dot L}$ (from the training-loss curve).
   - **Circuit size.** By Maurey's lemma, the network is then $\epsilon$-close in $L^2$ to a $K$-neuron circuit with $K=\lceil P^2/4\epsilon^2\rceil$. A kl-Occam bound uniform in $t$ follows (Theorem D3.2), with no dependence on the width. As a statement about the current weights, it holds for any network, balanced or not (e.g. GD iterates), with $\sum_j|a_j|\|w_j\|\le P/2$ in place of $P/2$.
   - **The $K$-neuron Occam bound (Proposition D3.3)** uses the network's own clusters of directions. Its use is a posteriori.
4. **Beyond the first plateau: what is and is not proved (§4).**
   - **The a priori bound degrades.** The a priori path-norm bound grows linearly after $T_\beta$, so at $t=(1+c)\log(1/\alpha)/U^*$ it is $O(c\log(1/\alpha))$, not $O(1)$.
   - **Conditional persistence (Proposition D4.1, Proved, conditional).** If every cluster's separating training points stay "attracting" along the trajectory, a condition checkable from the training residuals, then the network stays within an explicit sup-norm distance of a $K$-neuron function. That distance is computed from $Q$ at one checkpoint and the current norms $\|w_j(t)\|$, plus the dormant mass, which the clock bounds through $\int_{t_1}^t\hat U(r_s)\,ds$ along the run.
   - **What remains a conjecture (Conjecture D4)** is the a priori form: that this condition holds for a time of order $\log(1/\alpha)$ after each escape.
5. **Numerical (two-layer ReLU, $d=16$, $n=1000$–$4000$, width 64, $\alpha=10^{-6}$–$10^{-2}$, small-step GD; exact test error on all $2^{16}$ inputs).** Every inequality proved for the flow holds along small-step GD, up to discretization effects at the kinks (listed in §5).
   - **Tightness of the clock bounds.** The growth bound reaches $0.84$–$0.95$ of its exponent, against $0.53$–$0.63$ for C3.1's. At $\alpha\le10^{-3}$ the escape-time lower bound is $60$–$81\%$ of the observed escape time, against $42$–$51\%$ for C3.1's.
   - **Condensation.** At $\alpha\le10^{-3}$ all 64 neurons condense into $K=2$ clusters of width $1-\cos=2\cdot10^{-8}$–$2\cdot10^{-4}$, a direct observation of the merging law. The exception is the $n=4000$ run, where 63 neurons condense and one stops at mass $9.2\cdot10^{-4}$, below 1% of the largest neuron's mass.
   - **Kinks.** Except for $x_1$, whose residual vanishes, the clusters sit on data hyperplanes (training-set margins $10^{-12}$–$3\cdot10^{-7}$). This is why arguments that freeze activation patterns cannot work here.
   - **Bounds.** The Maurey bound is vacuous at these $n$. The $K$-neuron bound with the network's own clusters certifies $0.19$ ($n=1000$) and $0.051$ ($n=4000$) for MAJ$_3$, whose true test error is $0$. The script computes these certificates for the balanced surrogate of the GD network, not the network itself. For $n=1000$, $\alpha=10^{-3}$ the referee recomputed the certificate on the GD network itself and got the same value (§5).
   - **The race model's dormant reservoir can be absent.** On $x_1+\frac12x_2x_3$ at $\alpha=10^{-6}$, every neuron is recruited by the first escape, and the network then stays at a 2-neuron point that never learns $x_2x_3$ (checked to $t=400$, about 25 escape times). At $\alpha=10^{-2}$ it learns the target. This matches the "two-edged sword" of early alignment (Boursier–Flammarion).

**Part II, two-layer quadratic networks** $f(x)=\sum_j[(u_j\cdot x)^2-\|u_j\|^2]-\sum_j[(v_j\cdot x)^2-\|v_j\|^2]=\langle UU^\top-VV^\top,\ xx^\top-I\rangle$. On the cube each hidden unit is a rank-one pairwise-interaction feature $2\sum_{k<l}u_ku_lx_kx_l$.
- **The model.** The output weights are fixed at $\pm1$ and the units are centred (the $-\|u_j\|^2$ terms), so this is symmetric matrix sensing with measurements $x_ix_i^\top-I$. With trainable output weights the dynamics would be 3-homogeneous and different; that case is not covered.
- **Relation to C2.** This is option (2) of the task. Theorems D5–D6 hold for any symmetric measurement matrices. C2's diagonal network is the case of commuting (diagonal) measurement matrices with diagonal initialization. For that case D6(2) gives a slightly weaker form of C2.3(2) (§7, Reading after D6).

6. **The log-det clock (Theorem D5, Proved).** For $\dot W=A(t)W$ with $A$ symmetric, $\sum_{k\le K}\ln\sigma_k(W(t))\le\sum_{k\le K}\ln\sigma_k(W(0))+\int_0^t\sum_{k\le K}\lambda_k(A)$. The same holds for discrete GD and SGD, with $\ln(1+\eta\lambda_k)$ per step and no other correction, provided every step's factor $I+\eta A_j$ is positive definite. For the quadratic network ($A_j=\pm2M_j$) that is the step-size condition $2\eta\|M_j\|_{op}<1$, with $M_j$ the full-batch or minibatch matrix.
7. **Time limits rank (Theorem D6, Proved).**
   - **Statement.** Let $N_\epsilon(t)$ be the number of eigenvalues of $UU^\top$ and $VV^\top$ that have grown above $\epsilon$. For all $t$,
     $$N_\epsilon(t)\le\kappa\,\big(\tau(t)/\Theta_\epsilon\big)^2,\qquad \Theta_\epsilon=\tfrac14\ln\frac{\epsilon}{\alpha^2s_0^2}\approx\tfrac12\ln\frac1\alpha,\quad\tau(t)=\int_0^t\|r\|_n .$$
     Here $\kappa=2\lambda_{\max}$ of the Gram matrix of the $\binom d2$ pair features on the *training inputs only*. Its population value is $2$; it does not depend on the labels, the trajectory or the width. The bound itself depends on the width only through $s_0=\max(\|U_0\|_{op},\|V_0\|_{op})$ in $\Theta_\epsilon$, so the approximation $\Theta_\epsilon\approx\frac12\ln\frac1\alpha$ assumes $s_0=O(1)$ (§6).
   - **Weight-free, not a priori.** The bound uses $\tau$, which is read off the training-loss curve. It does not look at the weights, but it is not a function of time alone. The time-only form uses $\tau(t)\le R_0t$ with $R_0=\|r(0)\|_n\approx\|y\|_n$ (flow). It is much weaker: for $x_1x_2$ in §7.4 it gives $N\le42$ at $t=20$, against $4$ from $\tau$.
   - **No early growth.** No eigenvalue grows before $\Theta_\epsilon/(\|M_y\|_{op}+2\kappa\sqrt d\epsilon)$.
   - **Scope.** This is the user's "the circuit cannot have grown big yet", for a non-diagonal two-layer network, at every time, without any plateau analysis. Circuit size is rank, i.e. the number of effective hidden units. The network has fixed output signs and centred units, i.e. it is symmetric matrix sensing (see above).
8. **Generalization uniform in time (Theorem D7, Proved).**
   - **Statement.** Simultaneously for all $t$, and for all GD and SGD iterates, the test error of $\mathrm{sgn}f_t$ is at most a kl-Occam term at training margin $\gamma$. Its capacity is about $(d+1)N_\epsilon(t)\ln\frac{32d(P(t)+1)}{\gamma}$, with $\epsilon=\gamma/8(d-1)$. $N_\epsilon(t)$ can be replaced by its weight-free bound $\kappa(\tau/\Theta_\epsilon)^2$.
   - **Comparison.** The unrestricted class of all degree-2 sign functions costs $\ln\Phi(2^{d+1},\binom d2+1)\approx964$ nats at $d=16$, by Cover's count. So at $d=16$, $B=1$, $\gamma=\frac12$ the rank bound is better for $N\le7$.
9. **Numerical ($d=16$, width 16+16, $\alpha=10^{-6}$, GD and SGD).**
   - **The inequalities hold.** The clock holds to round-off, $10^{-8}$. The rank bound's worst ratio is $0.38$–$0.59$.
   - **$x_1x_2$ at $n=3000$.** The bound is $0.084$ with the measured rank (2), against $0.276$ for the unrestricted class; the true test error is $0$. With the weight-free rank bound (4) and the proved GD norm bound of D6(5) it is $0.20$–$0.21$, a weight-free certificate for GD. The step-size condition of D6(5) holds along the run, with $\max_j2\eta\|M_j\|_{op}=0.020$ (§7.4).
   - **Where the loss-curve form fails.** On MAJ of three pairs the residual does not vanish, so $\tau$ keeps growing on the plateau. The weight-free rank bound grows from 23 to 47 while the true rank stays 6, and the corresponding D7 bound becomes vacuous. This is the same weakness as C2.5.

| result | content | status |
|---|---|---|
| Lemma D0.1 | calculus of $\mathrm{relu}\circ h$ along absolutely continuous curves | Proved |
| Lemma D0.2, D0.3 | kl-Chernoff and Occam with a prior; size of a sphere net | Proved |
| Lemma D1 | balance, exact mass clock, measure form, scale-free direction flow, energy identity, near-monotone utility, merging law | Proved |
| Lemma D2.1 | certified upper bound on $\sup_v\pm U_r(v)$ by eigenvalues | Proved |
| Theorem D2 | no growth before $T_\beta$; escape-time lower bound with sharp leading constant: $\liminf_{\alpha\to0}t_\beta U_0^*/\ln(1/\alpha)\ge1$ for every flow, with equality in an explicit instance (item 6); discrete GD form | Proved |
| Proposition D2.2 | quantization: time at non-critical directions is $O(1)$ | Proved |
| Theorem D3 | path norm through the escape: a priori and loss-curve forms | Proved |
| Corollary D3.1 | Maurey: $\epsilon$-close to a $\lceil P^2b^2/4\epsilon^2\rceil$-neuron circuit, width-free | Proved |
| Theorem D3.2 | generalization uniform in $t$ through the escape, width-free, for any network (balanced or not) | Proved |
| Proposition D3.3 | $K$-neuron Occam bound with the network's own clusters | Proved (a posteriori in $K$) |
| Proposition D4.1 | persistence of the cluster structure under the attracting-sign condition | Proved (conditional on a trajectory condition) |
| Conjecture D4 | a priori persistence for $t\le(1+c)T_1$ | Conjecture |
| Theorem D5 | log-det clock, continuous and discrete | Proved |
| Theorem D6 | quadratic networks (fixed output signs): $N_\epsilon\le\kappa(\tau/\Theta_\epsilon)^2$; no early growth; path norm; GD/SGD forms of the clock, the rank bound, the no-early-growth bound and the path norm | Proved |
| Theorem D7 | quadratic networks (fixed output signs): generalization uniform in $t$ with rank-$N_\epsilon(t)$ capacity | Proved |
| §5, §7.4 | checks of every inequality | Numerical |

---

## 0. Setting, notation, and three lemmas

**Data.** $\mathcal X=\{-1,1\}^d$. $S=((x_i,y_i))_{i\le n}$ is iid from a distribution $P$ on $\mathcal X\times\mathbb R$, or drawn without replacement from a finite population (remark after Lemma D0.2); for the sign-error statements $y\in\{-1,1\}$, and where the input marginal matters it is uniform. Write $\langle u,v\rangle_n=\frac1n\sum_iu(x_i)v(x_i)$ and $\|u\|_n$. Logarithms are natural. For a predictor $f$, $\mathrm{err}(\mathrm{sgn}f)=P(\mathrm{sgn}f(x)\ne y)\le P(yf(x)\le0)$, with $\mathrm{sgn}(0)=+1$. The margin statements bound the right side, so either convention for $\mathrm{sgn}(0)$ works.

**The kl inverse** is $\mathrm{kl}^{-1}_+(q,c)=\sup\{p\in[q,1]:\mathrm{kl}(q\|p)\le c\}$, nondecreasing in both arguments, with $\mathrm{kl}^{-1}_+(q,c)\le q+\sqrt{2qc}+2c$ and $\mathrm{kl}^{-1}_+(0,c)\le c$ (proofs in [A, Lemma 1.3](A-discrete-model.md)).

### Lemma D0.1 (relu along absolutely continuous curves) — Proved

Let $h:[0,T]\to\mathbb R$ be absolutely continuous. Write $\sigma=\mathrm{relu}$ and $\partial\sigma(z)=\{1\}$, $\{0\}$ or $[0,1]$ for $z>0$, $z<0$, $z=0$. Then:
1. $h'(t)=0$ for almost every $t$ in $\{h=0\}$;
2. $\sigma\circ h$ is absolutely continuous, and for almost every $t$, $(\sigma\circ h)'(t)=s\,h'(t)$ **for every** $s\in\partial\sigma(h(t))$.

*Proof.*
1. The isolated points of $Z=\{h=0\}$ are countable. Let $t\in Z$ be a non-isolated point of $Z$ at which $h$ is differentiable. Then there are $t_k\to t$ with $t_k\in Z\setminus\{t\}$, so $h'(t)=\lim_k(h(t_k)-h(t))/(t_k-t)=0$.
2. $\sigma$ is 1-Lipschitz, so $\sigma\circ h$ is absolutely continuous. Take $t$ at which $h$ and $\sigma\circ h$ are differentiable and, if $h(t)=0$, $h'(t)=0$; by item 1, almost every $t$ qualifies.
   - If $h(t)>0$, then $\sigma\circ h=h$ near $t$.
   - If $h(t)<0$, then $\sigma\circ h=0$ near $t$.
   - If $h(t)=0$, then $\sigma\circ h\ge0$ has a minimum at $t$, so its derivative is $0=s\cdot h'(t)$ for every $s$. ∎

### Lemma D0.2 (kl-Chernoff and Occam with a prior) — Proved

1. Let $\hat p$ be the mean of $n$ iid Bernoulli($p$) variables. Then $P\big(p>\mathrm{kl}^{-1}_+(\hat p,c)\big)\le e^{-nc}$.
2. Let $\{\mathcal A_\iota\}_{\iota\in I}$ be a countable family of finite collections of events in $\mathcal X\times\mathbb R$, fixed before seeing $S$, and let $\pi$ be a sub-probability on $I$ ($\sum_\iota\pi(\iota)\le1$). With probability at least $1-\delta$ over $S$, simultaneously for all $\iota$ and all $A\in\mathcal A_\iota$,
$$P(A)\le\mathrm{kl}^{-1}_+\Big(\widehat P_S(A),\ \frac{\ln|\mathcal A_\iota|+\ln\frac1{\pi(\iota)}+\ln\frac1\delta}{n}\Big).$$

*Proof.*
1. This is [C, Lemma C0.1](C-bridge-and-certificates.md#lemma-c01-kl-chernoff--proved), whose proof I repeat. For $0\le q\le p$, Markov's inequality with $\lambda\ge0$ gives $P(\hat p\le q)\le e^{\lambda nq}(1-p+pe^{-\lambda})^n$. With $e^{-\lambda}=q(1-p)/(p(1-q))$ the right side is $e^{-n\mathrm{kl}(q\|p)}$; for $q=0$ the bound is $(1-p)^n=e^{-n\mathrm{kl}(0\|p)}$.
   - Since $p'\mapsto\mathrm{kl}(\hat p\|p')$ increases on $[\hat p,1]$, the event $\{p>\mathrm{kl}^{-1}_+(\hat p,c)\}$ is $\{\hat p<p,\ \mathrm{kl}(\hat p\|p)>c\}$.
   - If $\mathrm{kl}(0\|p)\le c$, this event is empty.
   - Otherwise $q\mapsto\mathrm{kl}(q\|p)$ decreases continuously from $\mathrm{kl}(0\|p)>c$ to $0$ on $[0,p]$. So the event is $\{\hat p<q^*\}$ with $\mathrm{kl}(q^*\|p)=c$, of probability at most $e^{-nc}$.
2. Apply item 1 to each indicator $\mathbb 1_A$, $A\in\mathcal A_\iota$, with $c=(\ln|\mathcal A_\iota|+\ln\frac1{\pi(\iota)}+\ln\frac1\delta)/n$, so that each failure probability is at most $\pi(\iota)\delta/|\mathcal A_\iota|$. Sum over $A$ and $\iota$. ∎

**Sampling without replacement.** Both check scripts draw the $n$ training points without replacement from the cube. The population is then the uniform distribution on the cube with the target's labels. Lemma D0.2 still holds, with $p$ the population frequency.
- The proof of item 1 uses only the moment-generating-function bound $\mathbb Ee^{-\lambda n\hat p}\le(1-p+pe^{-\lambda})^n$.
- By Hoeffding (1963, Theorem 4), $\mathbb Ef(\sum_iX_i)$ for a sample without replacement from a finite population is at most its value for a sample with replacement, for every continuous convex $f$. Take $f(s)=e^{-\lambda s}$.
- Item 2 follows by the same union bound.

The priors used below are: $\frac1{(K+1)(K+2)}$ on $K\in\{0,1,\dots\}$ (or $\frac1{K(K+1)}$ on $K\ge1$); $\frac1{2(|\ell|+1)(|\ell|+2)}$ on dyadic scales $B=2^\ell$, $\ell\in\mathbb Z$, whose total mass is $\frac34$; and uniform on a finite margin grid $\Gamma$. Products of these are sub-probabilities, which is all Lemma D0.2 needs.

### Lemma D0.3 (nets of the sphere) — Proved

For every $\eta>0$, the unit sphere of $\mathbb R^D$ has an $\eta$-net $\mathcal N_\eta$ (every unit vector is within Euclidean distance $\eta$ of $\mathcal N_\eta$) with $|\mathcal N_\eta|\le(1+2/\eta)^D$.

*Proof.* Take a maximal $\eta$-separated subset; by maximality it is an $\eta$-net. The balls of radius $\eta/2$ around its points are disjoint and lie in the ball of radius $1+\eta/2$. Compare volumes. ∎

The proof does not use $\eta\le1$, and for $\eta\ge2$ a single point is a net. Values $\eta>1$ do occur: Proposition D3.3 takes $\eta=\gamma/(8B\sqrt{d+1})$ at small dyadic $B$.

The nets are fixed once, for each $D$ and $\eta$ used, before the data are seen.

---

# Part I. Two-layer ReLU networks

## 1. The network, the flow, and its exact structure

**Network.** $\tilde x=(x,1)\in\mathbb R^{d+1}$, so $\|\tilde x\|=\sqrt{d+1}$ and the bias is a weight. $f_\theta(x)=\sum_{j=1}^ma_j\sigma(w_j\cdot\tilde x)$, $L(\theta)=\frac12\|y-f_\theta\|_n^2$, $r=y-f_\theta$.
- $\hat\Sigma=\frac1n\sum_i\tilde x_i\tilde x_i^\top$ and $\lambda_X=\lambda_{\max}(\hat\Sigma)$. For uniform inputs $\mathbb E\tilde x\tilde x^\top=I$, so $\lambda_X\to1$.
- **Utility** of a unit direction $v\in S^d$ for a residual $r$: $U_r(v)=\langle r,\sigma(v\cdot\tilde x)\rangle_n$. Write $U^*(r)=\sup_{v\in S^d}|U_r(v)|$ and $U_0^*=U^*(y)$.
- Since $\|\sigma(v\cdot\tilde x)\|_n\le\|v\cdot\tilde x\|_n\le\sqrt{\lambda_X}$, we have $|U_r(v)-U_{r'}(v)|\le\sqrt{\lambda_X}\|r-r'\|_n$ and $U^*(r)\le\sqrt{\lambda_X}\|r\|_n$.

**Initialization.** Balanced: $|a_j(0)|=\|w_j(0)\|=\alpha_j>0$, with signs $\epsilon_j=\mathrm{sgn}\,a_j(0)$. The task's setting is $\alpha_j=\alpha$. Write $\rho_j=a_j^2+\|w_j\|^2$ and $P=\sum_j\rho_j=\|\theta\|^2$, so $P(0)=2\sum_j\alpha_j^2$. That is $2m\alpha^2$ for $\alpha_j=\alpha$, and $2\alpha^2$ for $\alpha_j=\alpha/\sqrt m$. **Width enters every statement below only through $P(0)$.**

**Definition (selection flow).** A locally absolutely continuous $\theta(t)$ such that there are Lebesgue-measurable selections $t\mapsto s_j(t,i)\in\partial\sigma(w_j(t)\cdot\tilde x_i)$ with, for almost every $t$,
$$\dot a_j=\langle r,\sigma(w_j\cdot\tilde x)\rangle_n,\qquad \dot w_j=a_j\,\xi_j,\qquad \xi_j:=\frac1n\sum_ir_i\,s_j(t,i)\,\tilde x_i .$$
- **Why this definition.** Every Clarke subgradient flow of $L$ is a selection flow, because the Clarke subdifferential of a sum or composition is contained in the set of such selections (Clarke 1983, Theorems 2.3.3 and 2.3.9; **Literature, from memory**). Clarke flows exist for locally Lipschitz functions (**Literature, from memory**).
- **Measurability is no restriction.** Suppose that for almost every $t$ some selection satisfies the equations. Then a measurable one does, by Filippov's measurable-selection lemma (Aubin–Frankowska 1990, §8.2; **Literature, from memory**). The reason: the admissible selections at time $t$ form a compact set $\prod_{j,i}\partial\sigma(w_j(t)\cdot\tilde x_i)$ that depends measurably on $t$, and the right side is continuous in the selection.
  - On sliding sets $\{w_j\cdot\tilde x_i=0\}$ of positive measure, which the checks show are typical, the flow determines $\xi_j$ but not, for example, $\xi^y_j$ of Lemma D1(f).
  - Statements below that integrate such selection-dependent quantities (Proposition D2.2, Proposition D4.1) hold for every measurable selection that realizes the flow.
- **What the proofs use.** The proofs below use only the definition, so they hold for any selection rule, in particular the convention $\sigma'(0)=0$ of most code. The checks use small-step GD as an approximation.

### Lemma D1 (exact structure of the flow) — Proved

Let $\theta$ be a selection flow from a balanced initialization. Then:
- **(a) Balance.** $a_j^2-\|w_j\|^2$ is constant, so $|a_j(t)|=\|w_j(t)\|$ for all $t$.
- **(b) The mass clock.** $\rho_j(t)>0$ and $\mathrm{sgn}\,a_j(t)=\epsilon_j$ for all $t$, $\hat w_j=w_j/\|w_j\|$ is absolutely continuous, and
$$\rho_j(t)=\rho_j(0)\exp\Big(2\int_0^t\epsilon_j\,U_{r(s)}(\hat w_j(s))\,ds\Big).$$
- **(c) Measure form.** For every $x$, not only training points, $f_t(x)=\sum_j\epsilon_j\frac{\rho_j(t)}2\,\sigma(\hat w_j(t)\cdot\tilde x)$. So $f_t=\int\sigma(v\cdot\tilde x)\,d\mu_t(v)$ with $\|\mu_t\|_{TV}\le P(t)/2$. Equality holds unless atoms of opposite sign coincide.
- **(d) Scale-free search.** Almost everywhere, $\dot{\hat w}_j=\epsilon_j(I-\hat w_j\hat w_j^\top)\,\xi_j$.
- **(e) Energy.** Almost everywhere, $\frac d{dt}L(\theta(t))=-\|\dot\theta\|^2$ and $\frac d{dt}P=4\langle r,f\rangle_n$. Hence $L$ is nonincreasing, $\|r(t)\|_n\le R_0:=\|r(0)\|_n$, and $\dot P\le\|y\|_n^2$.
- **(f) Near-monotone utility.** With $\xi^y_j=\frac1n\sum_iy_is_j(t,i)\tilde x_i$ and $\Pi_j=I-\hat w_j\hat w_j^\top$, almost everywhere
$$\frac d{dt}\,\epsilon_jU_y(\hat w_j)\ \ge\ \|\Pi_j\xi^y_j\|^2-\|\Pi_j\xi^y_j\|\sqrt{\lambda_X}\|f_t\|_n\ \ge\ -\tfrac{\lambda_X}4\|f_t\|_n^2 .$$
- **(g) Merging law.** For $j,k$ with $\epsilon_j=\epsilon_k$, let $Q_{jk}=a_ja_k-w_j\cdot w_k=\|w_j\|\|w_k\|\,(1-\hat w_j\cdot\hat w_k)\ge0$. Almost everywhere
$$\dot Q_{jk}=\epsilon_j\,\|w_j\|\|w_k\|\ \frac1n\sum_ir_i\,m_{jk}(t,i),\qquad m_{jk}(t,i)=\big(s_j(t,i)-s_k(t,i)\big)\,(\hat w_j-\hat w_k)\cdot\tilde x_i\ \ge0 .$$
  $m_{jk}(t,i)\ne0$ only at training points that *separate* the two neurons, where their selections differ. Consequently:
  1. $Q_{jk}$ is constant on any interval on which $j$ and $k$ use the same selections at every training point, for example the same strict activation pattern;
  2. $Q_{jk}$ is nonincreasing on any interval on which $\epsilon_jr_i(t)\le0$ at every separating point ("attracting" points);
  3. in general $\frac d{dt}\sqrt{Q_{jk}}\le\sqrt{\tfrac{(d+1)\|w_j\|\|w_k\|}2}\ \bar r^{\rm rep}_{jk}(t)$, where $\bar r^{\rm rep}_{jk}=\frac1n\sum_{i\ \text{separating},\ \epsilon_jr_i>0}|r_i|$ is the repelling residual mass, wherever $Q_{jk}>0$.

  The angle is read off from $Q$: $\|\hat w_j-\hat w_k\|^2=2Q_{jk}/(\|w_j\|\|w_k\|)$.

  *Credit.* (g1) is the off-diagonal entry of the classical conservation law of two-layer linear networks. For $f=W_2W_1x$, with rows $w_j$ of $W_1$ and entries $a_j$ of $W_2$, gradient flow keeps $W_1W_1^\top-W_2^\top W_2$ constant (Arora–Cohen–Hazan 2018; Du–Hu–Lee 2018; from memory). Its $(j,k)$ entry is $-Q_{jk}$ and its diagonal is (a). It applies here because a pair of neurons that share their selections is locally a linear network (Remark below). For ReLU networks only part of the balancedness laws is conserved globally, namely the diagonal (a) (Marcotte–Gribonval–Peyré 2023). I checked the venue and the abstract, which says that a subset of the laws survives; that the subset is the diagonal is from the referee's report. The monotonicity statements (g2) and (g3) may be new; I have not seen them elsewhere.

*Proof.*
- (a) $\frac d{dt}a_j^2=2a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n$. Also $\frac d{dt}\|w_j\|^2=2a_j\,w_j\cdot\xi_j=2a_j\langle r,s_j\,(w_j\cdot\tilde x)\rangle_n=2a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n$, because $s\,z=\sigma(z)$ for every $s\in\partial\sigma(z)$.
- (b) By (a), $\dot\rho_j=4a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n$.
  - *Positivity.* $|\langle r,\sigma(w\cdot\tilde x)\rangle_n|\le\|r\|_n\sqrt{\lambda_X}\|w\|$, so $|\dot\rho_j|\le4|a_j|\|w_j\|\sqrt{\lambda_X}\|r\|_n\le2\rho_j\sqrt{\lambda_X}\|r\|_n$. Since $r$ is continuous, Gronwall gives $\rho_j(t)\ge\rho_j(0)e^{-2\sqrt{\lambda_X}\int_0^t\|r\|_n}>0$.
  - *Sign.* By (a), $|a_j|=\|w_j\|=\sqrt{\rho_j/2}>0$, so the continuous $a_j$ never vanishes and keeps its sign. $\hat w_j$ is a smooth function of $w_j$ away from $0$, hence absolutely continuous.
  - *Clock.* With $a_j=\epsilon_j\|w_j\|$ and positive homogeneity, $4a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n=4\epsilon_j\|w_j\|^2U_r(\hat w_j)=2\epsilon_j\rho_jU_r(\hat w_j)$. So $\frac d{dt}\ln\rho_j=2\epsilon_jU_r(\hat w_j)$; integrate.
- (c) $a_j\sigma(w_j\cdot\tilde x)=\epsilon_j\|w_j\|^2\sigma(\hat w_j\cdot\tilde x)=\epsilon_j\frac{\rho_j}2\sigma(\hat w_j\cdot\tilde x)$.
- (d) $\frac d{dt}\frac w{\|w\|}=\frac{(I-\hat w\hat w^\top)\dot w}{\|w\|}=\frac{a_j}{\|w_j\|}\Pi_j\xi_j=\epsilon_j\Pi_j\xi_j$.
- (e) Fix $i$ and $j$. By Lemma D0.1(2) with $h=w_j\cdot\tilde x_i$ and $s=s_j(t,i)$, for almost every $t$, $\frac d{dt}\sigma(w_j\cdot\tilde x_i)=s_j(t,i)\,\dot w_j\cdot\tilde x_i$. There are finitely many pairs, so one null set serves all of them. Then
$$\frac d{dt}L=-\langle r,\dot f\rangle_n=-\sum_j\Big[\dot a_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n+\dot w_j\cdot a_j\xi_j\Big]=-\sum_j\big[\dot a_j^2+\|\dot w_j\|^2\big].$$
  Summing (b) gives $\dot P=4\sum_ja_j\langle r,\sigma(w_j\cdot\tilde x)\rangle_n=4\langle r,f\rangle_n=4\langle r,y-r\rangle_n\le4(\|r\|_n\|y\|_n-\|r\|_n^2)\le\|y\|_n^2$.
- (f) Lemma D0.1 applies to $h=\hat w_j\cdot\tilde x_i$ with the same selection, since $\hat w_j\cdot\tilde x_i$ and $w_j\cdot\tilde x_i$ have the same sign. It gives $\frac d{dt}U_y(\hat w_j)=\dot{\hat w}_j\cdot\xi^y_j$. By (d),
$$\epsilon_j\frac d{dt}U_y(\hat w_j)=(\Pi_j\xi_j)\cdot(\Pi_j\xi^y_j),\qquad \xi_j=\xi^y_j-\xi^f_j,\qquad \xi^f_j=\frac1n\textstyle\sum_if(x_i)s_j(t,i)\tilde x_i .$$
  For a unit vector $e$, $e\cdot\xi^f_j=\langle f,s_j\,(e\cdot\tilde x)\rangle_n\le\|f\|_n\|e\cdot\tilde x\|_n\le\sqrt{\lambda_X}\|f\|_n$. So $\|\Pi_j\xi^f_j\|\le\sqrt{\lambda_X}\|f\|_n$, and Cauchy–Schwarz gives the first inequality. Minimizing $a^2-ab$ over $a$ gives the second.
- (g) *The derivative.* $\dot a_j=\langle r,s_j\,(w_j\cdot\tilde x)\rangle_n=w_j\cdot\xi_j$. So
$$\tfrac d{dt}(a_ja_k)=(w_j\cdot\xi_j)a_k+a_j(w_k\cdot\xi_k),\qquad \tfrac d{dt}(w_j\cdot w_k)=a_j\,\xi_j\cdot w_k+a_k\,w_j\cdot\xi_k ,$$
  and the difference is $\dot Q_{jk}=(\xi_j-\xi_k)\cdot(a_kw_j-a_jw_k)$. For equal signs, $a_kw_j-a_jw_k=\epsilon_j\|w_j\|\|w_k\|(\hat w_j-\hat w_k)$, and $\xi_j-\xi_k=\frac1n\sum_ir_i(s_j-s_k)\tilde x_i$. By balance, $Q_{jk}=\|w_j\|\|w_k\|-w_j\cdot w_k$.
  - *$m\ge0$.* $\partial\sigma$ is a monotone map ($\sigma$ is convex): $(s-s')(z-z')\ge0$ for $s\in\partial\sigma(z)$, $s'\in\partial\sigma(z')$. Take $z=\hat w_j\cdot\tilde x_i$ and $z'=\hat w_k\cdot\tilde x_i$.
  - *Items 1 and 2* are immediate.
  - *Item 3.* $0\le m_{jk}\le|(\hat w_j-\hat w_k)\cdot\tilde x_i|\le\|\hat w_j-\hat w_k\|\sqrt{d+1}$, and only repelling points contribute positively. So $\dot Q\le\|w_j\|\|w_k\|\sqrt{d+1}\,\|\hat w_j-\hat w_k\|\,\bar r^{\rm rep}=\sqrt{2(d+1)\|w_j\|\|w_k\|Q}\ \bar r^{\rm rep}$. Divide by $2\sqrt Q$. ∎

**Remarks.**
- **Lorentz structure.** On an interval where a group of neurons shares its selections, $\xi_j=\xi$ is common to the group. Every pair $(a_j,w_j)$ then evolves by the same linear ODE $\dot z=J(t)z$, with $J=\begin{pmatrix}0&\xi^\top\\\xi&0\end{pmatrix}$. This ODE preserves the Lorentzian form $aa'-w\cdot w'$; (g1) is that conservation law, which is the linear-network law cited after (g).
  - So inside a cell the network is a two-layer *linear* network, which is the bridge to Part II.
  - With (g1) from time $t_c$ on, $1-\cos\angle(w_j,w_k)=Q_{jk}(t_c)/(\|w_j\|\|w_k\|)$. Since $Q_{jk}(0)\le2\alpha_j\alpha_k$, a pair that keeps its selections from the start has $1-\cos\le4\alpha_j\alpha_k/\sqrt{\rho_j\rho_k}$ forever. Clusters are $\alpha^2$-tight relative to their mass.
- **The race, exactly.** (b) and (d) are the README's race with no approximation:
  - the clock of neuron $j$ is $\int\epsilon_jU_r(\hat w_j)$, and it must reach $\frac12\ln(\beta/\rho_j(0))\approx\ln(1/\alpha)$ before the neuron has mass $\beta$;
  - its direction does projected subgradient ascent of $\epsilon_jU_r$ at a speed independent of its size.

  The two differences from [A](A-discrete-model.md)'s race are that the "gate" is a continuous direction that keeps moving, and that neurons recruited together merge (g) instead of counting as separate gates.
- **Literature.** The measure form (c) is the "conic particle" picture (Chizat–Bach 2018; Chizat 2022, *Sparse optimization on measures with over-parameterized gradient descent*; from memory). That directions align with the data before the weights grow is the early-alignment phenomenon of Maennel–Bousquet–Gelly (2018) and Boursier–Flammarion (2025) (**Literature**, abstracts checked).

## 2. No growth before $\log(1/\alpha)/U^*$

### Lemma D2.1 (a certified bound on the nonconvex supremum) — Proved

For $r\in\mathbb R^n$ let $r^\pm=\max(\pm r,0)$ and $\overline{r^\pm}=\frac1n\sum_ir_i^\pm$. Then
$$\sup_{v\in S^d}\pm U_r(v)\le\hat U^\pm(r):=\min\Big\{\|r^\pm\|_n\sqrt{\lambda_{\max}\big(\tfrac1n\textstyle\sum_{i:r^\pm_i>0}\tilde x_i\tilde x_i^\top\big)},\ \sqrt{\overline{r^\pm}\,\lambda_{\max}\big(\tfrac1n\textstyle\sum_ir^\pm_i\tilde x_i\tilde x_i^\top\big)}\Big\},$$
so that $U^*(r)\le\hat U(r):=\max(\hat U^+,\hat U^-)\le\sqrt{\lambda_X}\|r\|_n$.

*Proof.* Since $\sigma\ge0$, $U_r(v)\le\frac1n\sum_ir^+_i\sigma(v\cdot\tilde x_i)$. Apply Cauchy–Schwarz in two ways:
- as $\|r^+\|_n\cdot(\frac1n\sum_{r^+_i>0}(v\cdot\tilde x_i)^2)^{1/2}$;
- as $(\overline{r^+})^{1/2}(\frac1n\sum_ir^+_i(v\cdot\tilde x_i)^2)^{1/2}$.

The same holds for $-U_r$ with $r^-$. The last inequality uses $\sum_{r^+_i>0}\tilde x_i\tilde x_i^\top\preceq n\hat\Sigma$ and $\|r^\pm\|_n\le\|r\|_n$. ∎

For $y=x_1$ on the full cube this is exact: $\hat U^+=\frac1{\sqrt2}=U_y\big((e_1+e_0)/\sqrt2\big)$, where $e_0$ is the bias coordinate. On the samples of §5 it exceeds a projected-ascent estimate of $U^*$ (256 random starts per sign) by 1.5–12%.

### Theorem D2 (no growth before $T_\beta$) — Proved

For any selection flow from a balanced initialization, any data and any width:
1. **Growth bound.** $\rho_j(t)\le\rho_j(0)\exp\big(2\int_0^tU^*(r(s))ds\big)$, and the same for $P$.
2. **Function bounds.** $\|f_t\|_n\le\frac{\sqrt{\lambda_X}}2P(t)$ and $\sup_{x\in\{-1,1\}^d}|f_t(x)|\le\frac{\sqrt{d+1}}2P(t)$. For uniform $P_X$, also $\|f_t\|_{L^2(P_X)}\le\frac12P(t)$.
3. **Escape time.** For $\beta>P(0)$, let $t_\beta=\inf\{t:P(t)\ge\beta\}$. Then
$$t_\beta\ \ge\ T_\beta:=\frac{\ln(\beta/P(0))}{2\,(U_0^*+\lambda_X\beta/2)} .$$
   Hence for $t\le T_\beta$: $\sup_x|f_t(x)|\le\frac{\sqrt{d+1}}2\beta$ and $L(t)\ge\frac12\big(\|y\|_n-\frac{\sqrt{\lambda_X}}2\beta\big)_+^2$. Any upper bound on $U_0^*$, such as $\hat U(y)$, may be used in place of $U_0^*$.
4. **Per-neuron clock.** Neuron $j$ has mass $\ge\beta_j$ at time $t$ only if $\int_0^t\epsilon_jU_r(\hat w_j)\ge\frac12\ln(\beta_j/\rho_j(0))$.
5. **Discrete GD** with step $\eta$ (no balance needed): $\rho^{k+1}_j\le\rho_j^k\big(1+2\eta U^*(r_k)+\eta^2\lambda_X\|r_k\|_n^2\big)$.
6. **The leading constant is sharp.** Consider the following instance.
   - *Data.* The training inputs are the $2^d$ points of the cube, each once, and $y=x_1$.
   - *Network.* One neuron ($m=1$) with $a(0)=\alpha<2^{-1/4}$ and $w(0)=\alpha v^*$, where $v^*=(e_1+e_0)/\sqrt2$ and $e_0$ is the bias coordinate.
   - *Selection.* $s=0$ at the kink points $\{x_1=-1\}$, i.e. the convention $\sigma'(0)=0$.

   Then $\lambda_X=1$ and $U_0^*=1/\sqrt2$. This is a selection flow, it keeps $\hat w(t)=v^*$, and for $P(0)<\beta<\sqrt2$
$$P(t)=\frac{\sqrt2}{1+(\sqrt2/P(0)-1)e^{-\sqrt2t}},\qquad t_\beta=\frac{\ln(\beta/P(0))}{2U_0^*}+\frac1{\sqrt2}\ln\frac{\sqrt2-P(0)}{\sqrt2-\beta}.$$
   So $t_\beta\big/\big(\ln(1/\alpha)/U_0^*\big)\to1$ as $\alpha\to0$.

   Conversely, item 3 gives $\liminf_{\alpha\to0}t_\beta U_0^*/\ln(1/\alpha)\ge1$ for every selection flow, at every fixed $\beta>0$ and $m$ (with $\alpha_j=\alpha$). The reason is monotonicity in $\beta$: for $\beta'\in(P(0),\beta]$, $t_\beta\ge t_{\beta'}\ge T_{\beta'}$. Let $\alpha\to0$, which gives $\liminf\ge\big(1+\lambda_X\beta'/(2U_0^*)\big)^{-1}$, and then let $\beta'\to0$. (Item 3 at $\beta'=\beta$ alone gives only $\big(1+\lambda_X\beta/(2U_0^*)\big)^{-1}$, which is $0.739$ for $\beta=\frac12$ in this instance; [`checks/referee_D_r2.out`](checks/referee_D_r2.out), S1.)

   So the leading constant $1/U_0^*$ is sharp at every fixed $\beta$: the instance attains $1$ for every $\beta<\sqrt2$, and no bound of the form $t_\beta\ge c\,\frac{\ln(1/\alpha)}{U_0^*}(1+o(1))$ with $c>1$ can hold for all data.

*Proof.*
1. Lemma D1(b), with $|U_r(\hat w_j)|\le U^*(r)$; sum over $j$ for $P$.
2. Lemma D1(c), with $|\sigma(v\cdot\tilde x)|\le|v\cdot\tilde x|$, $\|v\cdot\tilde x\|_n\le\sqrt{\lambda_X}$, $\sup_x|v\cdot\tilde x|\le\sqrt{d+1}$, and $\mathbb E(v\cdot\tilde x)^2=1$ under uniform inputs. Sum $\sum_j\rho_j/2=P/2$.
3. For $t<t_\beta$, $\|f_t\|_n<\frac{\sqrt{\lambda_X}}2\beta$, so $U^*(r_t)\le U_0^*+\sqrt{\lambda_X}\|f_t\|_n<U_0^*+\frac{\lambda_X}2\beta=:U_\beta$. Item 1 and continuity give $\beta=P(t_\beta)\le P(0)e^{2U_\beta t_\beta}$ when $t_\beta<\infty$. The loss bound is $\sqrt{2L}=\|y-f\|_n\ge(\|y\|_n-\|f\|_n)_+$; square the nonnegative quantities.
4. Lemma D1(b).
5. One step is $a'=a+\eta A$, $w'=w+\eta aV$, with $A=\langle r,\sigma(w\cdot\tilde x)\rangle_n$ and $V=\frac1n\sum_ir_is_i\tilde x_i$. Since $w\cdot V=A$, $\rho'=\rho+4\eta aA+\eta^2(A^2+a^2\|V\|^2)$.
   - $|A|=\|w\|\,|U_r(\hat w)|\le\|w\|U^*(r)$ and $|a|\|w\|\le\rho/2$, so $4\eta aA\le2\eta\rho U^*$.
   - $\|V\|\le\sqrt{\lambda_X}\|r\|_n$ and $U^*\le\sqrt{\lambda_X}\|r\|_n$, so $A^2+a^2\|V\|^2\le\rho\lambda_X\|r\|_n^2$.
6. *Constants.* Over the full cube the coordinates of $\tilde x$ are orthonormal in $\langle\cdot,\cdot\rangle_n$, so $\hat\Sigma=I$ and $\lambda_X=1$.
   - $\frac1n\sum_{x_1=\pm1}\tilde x\tilde x^\top=\frac12\big(I\pm(e_1e_0^\top+e_0e_1^\top)\big)$ has top eigenvalue $1$. With $\|y^\pm\|_n^2=\overline{y^\pm}=\frac12$, both entries of the minimum in Lemma D2.1 equal $1/\sqrt2$, so $U_0^*\le\hat U(y)=1/\sqrt2$.
   - Also $U_y(v^*)=\frac12\cdot\frac2{\sqrt2}=\frac1{\sqrt2}$. Hence $U_0^*=1/\sqrt2$ (numerically confirmed at $d=16$ in [`checks/referee_D_r1.out`](checks/referee_D_r1.out), R4).

   *Dynamics.* Try $a(t)=b(t)$ and $w(t)=b(t)v^*$ with $b>0$.
   - On $\{x_1=1\}$, $w\cdot\tilde x=\sqrt2b>0$, so $s=1$. On $\{x_1=-1\}$, $w\cdot\tilde x=0$, and we take $s=0$.
   - So $f=\sqrt2b^2$ and $r=1-\sqrt2b^2$ on $\{x_1=1\}$, while $f=0$ and $r=-1$ on $\{x_1=-1\}$.
   - Then $\dot a=\langle r,\sigma(w\cdot\tilde x)\rangle_n=\frac b{\sqrt2}(1-\sqrt2b^2)$, and $\xi=\frac1n\sum_{x_1=1}r\,\tilde x=\frac12(1-\sqrt2b^2)(e_1+e_0)$, so $\dot w=a\xi=\frac b{\sqrt2}(1-\sqrt2b^2)\,v^*$.
   - Both equations are therefore satisfied when $\dot b=\frac b{\sqrt2}(1-\sqrt2b^2)$ and $b(0)=\alpha$. This scalar ODE has a unique global solution, and it gives a $C^1$ curve with constant, hence measurable, selections. So it is a selection flow from a balanced initialization, with $\hat w=v^*$.
   - $P=2b^2$ satisfies the logistic equation $\dot P=\sqrt2P(1-P/\sqrt2)$, with $P(0)=2\alpha^2<\sqrt2$. Its solution is the displayed $P(t)$, and solving $P(t_\beta)=\beta$ gives $t_\beta$, using $2U_0^*=\sqrt2$.
   - Finally $\ln(\beta/P(0))=2\ln(1/\alpha)+\ln(\beta/2)$, and the second term of $t_\beta$ stays bounded as $\alpha\to0$. ∎

**Reading.**
- **Size of $T_\beta$.** With $P(0)=2m\alpha^2$,
$$T_\beta=\frac{\ln(1/\alpha)}{U_0^*}\Big(1-\frac{\ln(2m/\beta)}{2\ln(1/\alpha)}\Big)\Big(1+\frac{\lambda_X\beta}{2U_0^*}\Big)^{-1}.$$
  The leading constant $\ln(1/\alpha)/U_0^*$ is the README's rate law. It is the growth time, by Lemma D1(b), of a neuron that sits at a maximizer of $\pm U_y$ from the start while $r\approx y$.
  - Item 6 makes this exact in one instance, so the leading constant cannot be improved in general. By the monotonicity argument in item 6, every flow has $\liminf_{\alpha\to0}t_\beta U_0^*/\ln(1/\alpha)\ge1$ at every fixed $\beta$, so the $\beta$-dependent factor of $T_\beta$ does not enter the leading constant.
  - The $\ln m$ term and the other lower-order terms are not claimed to be sharp.
  - Item 6 uses the selection $s=0$ on the kink $\{x_1=-1\}$, where the maximizer $v^*$ sits. With $s>0$ there the direction leaves $v^*$. Sharpness needs only one selection flow, because item 3 holds for all of them.
- **Comparison with C3.1.** Lemma C3.1 has $\sqrt{\lambda_X}\|y\|_n$ in place of $U_0^*$. For $y=x_1$ on the full cube that is $1$ against $1/\sqrt2$.
- **Width.** Width enters only through $\ln m$, and not at all if the initialization is scaled as $\alpha/\sqrt m$.
- **The "empty circuit" phase is rigorous.** Before $T_\beta$ the network is within $\frac{\sqrt{d+1}}2\beta$ of the zero function on the whole cube.
- **The bound is one-sided.** That the escape actually happens near $T_\beta$ needs a neuron whose direction reaches the maximizer early. That is the alignment phase of Boursier–Flammarion (2025) and Kumar–Haupt (TMLR 2024), not proved here.

### Proposition D2.2 (quantization: directions are near-critical at most times) — Proved

For every neuron $j$ and every $t$,
$$\int_0^t\|\Pi_j\xi^y_j(s)\|^2ds\ \le\ 4U_0^*+\lambda_X\int_0^t\|f_s\|_n^2ds .$$
So for every $q>0$, the time in $[0,t]$ during which $\|\Pi_j\xi^y_j\|\ge q$ is at most $(4U_0^*+\lambda_X\int_0^t\|f\|_n^2)/q^2$. On $[0,T_\beta]$, $\int\|f\|^2_n\le\frac{\lambda_X}4\int_0^{T_\beta}P^2\le\frac{\lambda_X}4\int_0^{T_\beta}P(0)^2e^{4U_\beta s}ds\le\frac{\lambda_X\beta^2}{16U_\beta}$, with $U_\beta=U_0^*+\lambda_X\beta/2$ (Theorem D2(3)). This is independent of $\alpha$.

*Proof.* By Lemma D1(f) and $ab\le\frac12a^2+\frac12b^2$, $\frac d{dt}\epsilon_jU_y(\hat w_j)\ge\frac12\|\Pi_j\xi^y_j\|^2-\frac{\lambda_X}2\|f\|_n^2$ almost everywhere. Integrate, which is legitimate because $U_y(\hat w_j)$ is absolutely continuous and the selections are measurable (Definition), and use $|U_y|\le U_0^*$. ∎

The statement holds for every measurable selection that realizes the flow. It may depend on the selection, because on sliding sets the flow does not determine $\xi^y_j$.

**What it says.**
- **Approximate criticality.** $\Pi_j\xi^y_j$ is the tangential part of one selection gradient of $\epsilon_jU_y$ at $\hat w_j$. Where it is small, $\hat w_j$ is an approximate critical point of $\pm U_y$ on the sphere, in the selection sense, which is weaker than Clarke criticality.
- **Fraction of the window.** The pre-escape window has length $\approx\ln(1/\alpha)/U_0^*$. So the fraction of it spent away from critical directions is $O(1/(q^2\ln(1/\alpha)))$.
- **Relation to Maennel et al.** This is Maennel–Bousquet–Gelly's quantization, in a scale-free and quantitative but time-averaged form. It does not say that the directions *converge*, nor which critical point they reach.

## 3. Through the first escape: path norm, circuit size, generalization

### Theorem D3 (path norm through the escape) — Proved

For every $\beta>P(0)$ and all $t\ge0$:
1. **a priori:** $P(t)\le\beta+\|y\|_n^2\,(t-T_\beta)_+$;
2. **from the training-loss curve:** for any partition $T_\beta=t_0<t_1<\dots<t_K=t$,
$$\sqrt{P(t)}\ \le\ \sqrt\beta+\int_{T_\beta}^t\sqrt{-\dot L(s)}\,ds\ \le\ \sqrt\beta+\sum_{k<K}\sqrt{(t_{k+1}-t_k)\,(L(t_k)-L(t_{k+1}))} .$$

*Proof.*
- $P\le\beta$ on $[0,T_\beta]$, because $T_\beta\le t_\beta$ (Theorem D2(3)).
- Item 1 is Lemma D1(e): $\dot P\le\|y\|_n^2$.
- Item 2: $\theta\ne0$ by Lemma D1(b), so $\frac d{dt}\|\theta\|=\hat\theta\cdot\dot\theta\le\|\dot\theta\|=\sqrt{-\dot L}$ by Lemma D1(e), and $\|\theta\|=\sqrt P$. Apply Cauchy–Schwarz on each segment. ∎

Item 2 is B1.1's displacement bound, applied at $T_\beta$ instead of $0$. Here it is a bound on the *variation norm of the function*, because at small initialization $\theta(0)\approx0$ and $P=\|\theta\|^2\ge2\|\mu\|_{TV}$. This is why B's observation that norm bounds pay for the random features present at initialization does not apply.

### Corollary D3.1 (circuit-size form) — Proved

For any probability $\nu$ on $\{-1,1\}^d$ and any $K\ge1$, there are $v_1,\dots,v_K$ among the network's directions $\hat w_j(t)$ and signs $\epsilon'_k$ such that
$$g=\frac{P(t)}{2K}\sum_{k=1}^K\epsilon'_k\,\sigma(v_k\cdot\tilde x)\quad\text{satisfies}\quad\|f_t-g\|_{L^2(\nu)}^2\le\frac{P(t)^2\,b_\nu^2}{4K},\qquad b_\nu^2=\sup_{\|v\|=1}\mathbb E_\nu\sigma(v\cdot\tilde x)^2 .$$
Here $b_\nu^2\le\lambda_{\max}(\mathbb E_\nu\tilde x\tilde x^\top)$, which is $1$ for uniform $\nu$. So at time $t$ the network is $\epsilon$-close to a circuit of $\lceil P(t)^2b_\nu^2/4\epsilon^2\rceil$ neurons, with $P(t)$ bounded by Theorem D3. The width does not enter.

*Proof (Maurey's empirical method).* Let $B=P/2$. Draw $J_1,\dots,J_K$ iid with $\Pr(J=j)=\rho_j/(2B)$, and put $g=\frac BK\sum_k\epsilon_{J_k}\sigma(\hat w_{J_k}\cdot\tilde x)$. By Lemma D1(c), $\mathbb Eg=f_t$. Then $\mathbb E\|f_t-g\|^2_{L^2(\nu)}=\frac1K\mathbb E\|B\epsilon_J\sigma(\hat w_J\cdot\tilde x)-f_t\|^2\le\frac{B^2b_\nu^2}K$, using $\mathbb E\|X-\mathbb EX\|^2\le\mathbb E\|X\|^2$. Some realization does at least as well as the mean. ∎

(Maurey's lemma: Pisier 1981; Barron 1993; **Literature, from memory**. The variation-norm view of two-layer networks: Bach, JMLR 2017; from memory.)

### Theorem D3.2 (generalization through the escape, width-free) — Proved

Fix the following, before seeing the data:
- **Net.** For $K\ge1$, let $\eta_K=1/\sqrt{K(d+1)}$ and let $\mathcal N_{\eta_K}$ be a net of $S^d$ from Lemma D0.3.
- **Classes.** For a dyadic $B=2^\ell$, let $\mathcal G_{K,B}=\{\frac BK\sum_{k\le K}\epsilon_k\sigma(u_k\cdot\tilde x):\epsilon_k\in\{-1,0,1\},u_k\in\mathcal N_{\eta_K}\}$.
- **Margins.** A finite grid $\Gamma$.

Let $P_X$ be uniform and $b^2=\frac12(1+\lambda_X)$. With probability at least $1-\delta$ over $S$, the following holds simultaneously:
- for every two-layer ReLU network $f=\sum_ja_j\sigma(w_j\cdot\tilde x)$ of any width and with any parameters, balanced or not (in particular $f_t$ at every time of every selection flow, and every GD iterate);
- for every $K\ge1$ and $\gamma\in\Gamma$;
- for every dyadic $B\ge\sum_j|a_j|\|w_j\|$. Since $|a_j|\|w_j\|\le\rho_j/2$, any dyadic $B\ge P/2$ qualifies, and under balance the two sums are equal.

With $e_K=2B^2(b+1)^2/(K\gamma^2)$,
$$\mathrm{err}(\mathrm{sgn}f)\ \le\ \mathrm{kl}^{-1}_+\Big(\widehat P_S[yf\le2\gamma]+e_K,\ \frac{K\ln(2|\mathcal N_{\eta_K}|+1)+\ln\frac{2|\Gamma|K(K+1)(|\ell|+1)(|\ell|+2)}{\delta}}n\Big)+e_K .$$
In particular, along a selection flow from balanced initialization, $B$ may be taken from Theorem D3 with $f=f_t$. That makes the bound a function of $(t,\beta,P(0),U_0^*,\lambda_X)$ and the training margins alone.

*Proof.*
1. **Occam event.** Apply Lemma D0.2(2) to the events $\{(x,y):yg(x)\le\gamma\}$, $g\in\mathcal G_{K,2^\ell}$, over $(K,\ell,\gamma)$ with the product prior of §0. $|\mathcal G_{K,B}|\le(2|\mathcal N_{\eta_K}|+1)^K$ does not depend on $B$.
2. **Approximation.** Let $\nu=\frac12(P_X+\widehat P_{S,X})$. Write $f=\sum_j\epsilon_jc_j\,\sigma(\hat w_j\cdot\tilde x)$, with $c_j=|a_j|\|w_j\|$ and $\epsilon_j=\mathrm{sgn}\,a_j$, dropping neurons with $a_j=0$ or $w_j=0$. Under balance $c_j=\rho_j/2$, as in Lemma D1(c).
   - Argue as in Corollary D3.1, with $\Pr(J=j)=c_j/B$ and an extra "null" outcome of probability $1-\sum_jc_j/B$ that contributes $0$. This gives $g_0=\frac BK\sum_k\epsilon_{J_k}\sigma(\hat w_{J_k}\cdot\tilde x)$ with $\mathbb Eg_0=f$ and $\|f-g_0\|_{L^2(\nu)}\le Bb_\nu/\sqrt K$.
   - Here $b_\nu^2\le\frac12(1+\lambda_X)=b^2$.
   - Replace each $\hat w_{J_k}$ by its nearest net point. Since $|\sigma(v\cdot\tilde x)-\sigma(u\cdot\tilde x)|\le\|v-u\|\sqrt{d+1}$, this costs at most $\frac BK\cdot K\cdot\eta_K\sqrt{d+1}=B/\sqrt K$ in sup norm.
   - So some $g\in\mathcal G_{K,B}$ has $\|h\|_{L^2(\nu)}\le B(b+1)/\sqrt K$, where $h=f-g$.
   - $\nu$ depends on $S$, but only the existence of $g$ is used.
3. **Margins.** $\{yf\le0\}\subseteq\{yg\le\gamma\}\cup\{|h|>\gamma\}$, and $\{yg\le\gamma\}\subseteq\{yf\le2\gamma\}\cup\{|h|>\gamma\}$. By Chebyshev,
$$P_X(|h|>\gamma)+\widehat P_S(|h|>\gamma)\le\frac{\|h\|^2_{L^2(P_X)}+\|h\|^2_{L^2(\widehat P)}}{\gamma^2}=\frac{2\|h\|^2_{L^2(\nu)}}{\gamma^2}\le e_K .$$
4. **Conclusion.** Combine with the Occam event and the monotonicity of $\mathrm{kl}^{-1}_+$. ∎

Optimizing $K$ gives roughly $\frac{4B(b+1)}\gamma\sqrt{(d+1)\ln(3\sqrt{K(d+1)})/n}$, the variation-norm rate. At $d=16$ and $B\approx1.4$, it is non-vacuous only for $n\gtrsim10^5$. In the checks (§5) it is vacuous at $n\le4000$, both with the measured $P$ and with the a priori bound.

### Proposition D3.3 ($K$-neuron Occam bound) — Proved

Fix the following, before seeing the data:
- **Grids.** For $K\ge0$, a dyadic $B$ and $\gamma\in\Gamma$, let $\eta=\gamma/(8B\sqrt{d+1})$ and $\eta_c=\gamma/(8\max(K,1)\sqrt{d+1})$.
- **Class.** $\mathcal G'_{K,B,\gamma}=\{\sum_{k\le K}c_k\sigma(u_k\cdot\tilde x):u_k\in\mathcal N_\eta,\ c_k\in\eta_c\mathbb Z,\ |c_k|\le\eta_c\lceil B/\eta_c\rceil\}$, with
$$\ln|\mathcal G'_{K,B,\gamma}|\le K\Big[(d+1)\ln\big(1+\tfrac{16B\sqrt{d+1}}\gamma\big)+\ln\big(2\lceil\tfrac{8KB\sqrt{d+1}}\gamma\rceil+1\big)\Big].$$

With probability at least $1-\delta$, simultaneously:
- **for every predictor $f$** (any dependence on $S$), and every $K$, dyadic $B$ and $\gamma\in\Gamma$;
- **and every $K$-neuron function** $g=\sum_{k\le K}c_k\sigma(v_k\cdot\tilde x)$ with unit $v_k$ and $\sum_k|c_k|\le B$ such that $\sup_{x\in\{-1,1\}^d}|f(x)-g(x)|\le\gamma/4$,

we have
$$\mathrm{err}(\mathrm{sgn}f)\le\mathrm{kl}^{-1}_+\Big(\widehat P_S[yf\le\gamma],\ \frac{\ln|\mathcal G'_{K,B,\gamma}|+\ln\frac{2|\Gamma|(K+1)(K+2)(|\ell|+1)(|\ell|+2)}\delta}n\Big).$$

**For the network.** Take any network $f=\sum_ja_j\sigma(w_j\cdot\tilde x)$, balanced or not. Partition the neurons into clusters $G_1..G_K$ with unit representatives $v_k$ and a remainder $D$. Put $c_k=\sum_{j\in G_k}\mathrm{sgn}(a_j)|a_j|\|w_j\|$. Then, since $a_j\sigma(w_j\cdot\tilde x)=\mathrm{sgn}(a_j)|a_j|\|w_j\|\,\sigma(\hat w_j\cdot\tilde x)$,
$$\sup_x|f-g|\le\sqrt{d+1}\Big[\sum_k\sum_{j\in G_k}|a_j|\|w_j\|\,\|\hat w_j-v_k\|+\textstyle\sum_{j\in D}|a_j|\|w_j\|\Big],\qquad \sum_k|c_k|\le\sum_j|a_j|\|w_j\|\le P/2 .$$
Under balance (Lemma D1(c)) $|a_j|\|w_j\|=\rho_j/2$, and Lemma D1(g) expresses $\|\hat w_j-\hat w_{j'}\|$ through $Q_{jj'}$.

*Proof.*
- **Rounding.** Round each $v_k$ to the net and each $c_k$ to the grid; $|c_k|\le B$ keeps the rounded value inside it. The sup error is at most $\sqrt{d+1}\,(B\eta+K\eta_c/2)\le\frac\gamma8+\frac\gamma{16}<\frac\gamma4$. So the rounded $g'$ has $\sup|f-g'|\le\gamma/2$.
- **Margins.** On test points, $yf\le0\Rightarrow yg'\le\gamma/2$. On training points, $yg'\le\gamma/2\Rightarrow yf\le\gamma$.
- **Occam.** Apply Lemma D0.2 to the events $\{yg'\le\gamma/2\}$. ∎

This bound is a posteriori in the clusters, i.e. a parameter-space version of C1's distillation. It shows what an a priori version of Conjecture D4 would deliver: the capacity is about 100 nats per cluster at $d=16$, $B\approx1.4$, $\gamma=\frac12$, so 202 nats for the 2 clusters of §5, against 6693 nats for the same count applied to all 64 neurons ([`checks/referee_D_r2.out`](checks/referee_D_r2.out), S4).

## 4. Beyond the first escape

**What fails in the a priori argument.**
- **The path-norm bound grows linearly.** At $t=(1+c)\ln(1/\alpha)/U_0^*$ it is $\beta+\|y\|_n^2\big((c+O(\beta))\ln(1/\alpha)/U_0^*+O(\ln m)\big)$. The bound is valid but degrades like $\log(1/\alpha)$, while the true $P$ stays $O(1)$ on the plateau ($2.8$–$3.2$ in the runs of §5 at $\alpha\le10^{-3}$, $6.1$ at $\alpha=10^{-2}$). To do better one must show that the flow *stops* on the plateau ($\langle r,f\rangle_n\to0$), which is a local convergence statement near a saddle.
- **Fixed activation patterns do not survive.** The natural local argument freezes the activation pattern of each active neuron and uses the Lorentz-linear structure (Remark after Lemma D1). Inside a fixed pattern the active network is a masked two-layer linear network, which converges exponentially to a least-squares fit. But the escaping directions sit *on* data hyperplanes.
  - *Reason.* Training points whose label opposes the neuron's sign contribute concave kinks to $\epsilon U_y$. Maxima of a piecewise-linear function prefer concave kinks, as an LP optimum prefers vertices.
  - *Observed.* In every run of §5 except $x_1$ (whose residual vanishes, after which the clusters move off the kinks to margin $6\cdot10^{-3}$), the grown neurons have training-set margins $10^{-12}$–$3\cdot10^{-7}$ on the plateau. Within $10^{-2}\sqrt{d+1}$ of a grown neuron's hyperplane lie 91–502 of the training points in the $n=1000$ runs and 1517 in the $n=4000$ run. GD zig-zags across them.
  - *Consequence.* Any proof must handle sliding along kinks. Lemma D1(g) is the one piece of that analysis done here.
- **The dormant reservoir can be empty.** The race model and AGF assume that later moves are made by neurons still at scale $\alpha$. In the runs of §5 at $\alpha\le10^{-3}$, *every* neuron is recruited by the first escape, with one exception in the $n=4000$ run. Apparently the basins of the two maximizers of $\pm U_y$ cover almost all of the sphere.
  - In the $n=4000$ run, 63 of the 64 neurons are recruited. The last one grows to mass $9.2\cdot10^{-4}$, below 1% of the largest neuron's mass, and then stops growing.
  - The network is then a 2-neuron network to within $1-\cos\le2\cdot10^{-4}$ inside each cluster, apart from that neuron. A second feature can be learned only by splitting a cluster.
  - On $x_1+\frac12x_2x_3$ at $\alpha=10^{-6}$ this does not happen by $t=400$: the loss stays at $0.1095$ and the test MSE at $0.232$.
  - At $\alpha=10^{-2}$ the network forms 14–15 looser clusters and fits the target (test MSE $<10^{-4}$ by $t=45$).
  - This is the "two-edged sword" of Boursier–Flammarion (JMLR 2025; abstract checked; the specific failure example there is from memory): early alignment can steer gradient flow to a spurious stationary point.
  - For generalization bounds this is good news, since the circuit stays at $K=2$ forever. For the race model as a description of learning it is a failure mode.

### Proposition D4.1 (persistence of clusters under the attracting-sign condition) — Proved, conditional on a trajectory condition

Fix a checkpoint $t_1$, a partition of the neurons into same-sign clusters $G_1..G_K$ and a remainder $D$, and a reference neuron $j_k\in G_k$ for each cluster. Suppose that on $[t_1,t]$:

> **(A) attracting condition.** For every $k$, every $j\in G_k$ and almost every $s$, every training point separating $j$ and $j_k$ satisfies $\epsilon_jr_i(s)\le0$.

Then, with $g_t=\sum_kc_k(t)\,\sigma(\hat w_{j_k}(t)\cdot\tilde x)$ and $c_k=\sum_{j\in G_k}\epsilon_j\rho_j(t)/2$,
$$\sup_x|f_t(x)-g_t(x)|\ \le\ \sqrt{d+1}\Big[\sqrt2\sum_k\sum_{j\in G_k}\frac{\|w_j(t)\|^{3/2}}{\|w_{j_k}(t)\|^{1/2}}\sqrt{Q_{jj_k}(t_1)}\ +\ \frac12P_D(t_1)\,e^{2\int_{t_1}^t\hat U(r_s)ds}\Big],$$
and $\sum_k|c_k|\le P(t)/2$, with $P(t)$ bounded by Theorem D3(2). If (A) fails, the same holds with $\sqrt{Q_{jj_k}(t_1)}$ replaced by $\sqrt{Q_{jj_k}(t_1)}+\int_{t_1}^t\sqrt{(d+1)\|w_j\|\|w_{j_k}\|/2}\ \bar r^{\rm rep}_{jj_k}$ (Lemma D1(g3)). Whenever the right side is at most $\gamma/4$, Proposition D3.3 applies at time $t$ with this $K$.

*Proof.*
- **Clusters.** $Q_{jj_k}$ is locally absolutely continuous, as a combination of products of absolutely continuous functions. Under (A), $\dot Q_{jj_k}\le0$ almost everywhere by Lemma D1(g2), so $Q_{jj_k}(t)\le Q_{jj_k}(t_1)$. And $\frac{\rho_j}2\|\hat w_j-\hat w_{j_k}\|=\|w_j\|^2\sqrt{2Q_{jj_k}/(\|w_j\|\|w_{j_k}\|)}$.
- **If (A) fails.** Write $Q=Q_{jj_k}$ and $c(s)=\sqrt{(d+1)\|w_j\|\|w_{j_k}\|/2}\ \bar r^{\rm rep}_{jj_k}(s)\ge0$. $c$ is measurable, because the selections are, and it is bounded on $[t_1,t]$. Lemma D1(g3) gives $\frac d{ds}\sqrt Q\le c$ only where $Q>0$, and $\sqrt Q$ need not be absolutely continuous through zeros of $Q$. Suppose $Q(t)>0$, since otherwise there is nothing to prove.
  - If $Q$ has no zero on $[t_1,t]$, it is bounded away from $0$ there, so $\sqrt Q$ is absolutely continuous and $\sqrt{Q(t)}\le\sqrt{Q(t_1)}+\int_{t_1}^tc$.
  - Otherwise let $t_*<t$ be the last zero of $Q$ in $[t_1,t]$; it exists because $Q$ is continuous. On every $[t_*+\delta,t]$, $Q$ is bounded away from $0$, so $\sqrt{Q(t)}\le\sqrt{Q(t_*+\delta)}+\int_{t_*+\delta}^tc$. Let $\delta\to0$: $\sqrt{Q(t)}\le\int_{t_*}^tc\le\sqrt{Q(t_1)}+\int_{t_1}^tc$.
- **Remainder.** Apply Theorem D2(1) to the neurons of $D$ from time $t_1$, with $U^*\le\hat U$ (Lemma D2.1).
- **Sum.** Use the sup bound of Proposition D3.3. ∎

The condition (A) and the right side are computable from training-set quantities along the run. So D4.1 is a *trajectory-checkable* persistence theorem: one checkpoint plus a sign check along the way. The dormant term is controlled a priori by the clock: it stays below $\delta_1$ for a time $\ln(\delta_1/P_D(t_1))/(2\sup\hat U)$, which is of order $\log(1/\alpha)$ when $P_D(t_1)$ is a power of $\alpha$. What is missing for an a priori theorem is (A) itself.

### Conjecture D4 (a priori early-phase theorem)

Let $S$ be fixed and $\alpha\to0$, at fixed width and initial directions in general position.
- **Clusters.** Let $K$ be the number of distinct (selection-)critical directions of $\pm U_y$ that attract a positive fraction of the initial directions under the flow of Lemma D1(d).
- **Persistence.** Suppose the $K$-neuron least-squares fit $g^\star$ on these directions has residual $r^\star$ with $\epsilon r^\star_i<0$ at every training point on the clusters' boundary hyperplanes.

Then for every $c<c^\star(S)$, where $c^\star\ln(1/\alpha)/U_0^*$ is the time to the next escape, $\sup_{t\le(1+c)\ln(1/\alpha)/U_0^*}\inf_g\sup_x|f_t-g|\to0$ over $K$-neuron functions $g$. So Proposition D3.3 applies uniformly in $t$ over that window with $K$ computable from $S$ alone.

**Evidence (Numerical).** In every run of §5 at $\alpha\le10^{-3}$ the clusters form at the escape, and within-cluster angles shrink to $1-\cos=2\cdot10^{-8}$–$2\cdot10^{-4}$. Consider the intervals of $0.2$ time units ($0.04$ in the $\eta=0.004$ run, $1.0$ in the $t=400$ run) with three properties: (A) holds for a sampled pair; the pair does not keep one activation pattern throughout; and $1-\cos\ge10^{-4}$ at the start, above the discretization floor. There are 800–12700 such intervals per run.
- On these intervals, $Q_{jk}$ increased by at most $0.2\%$, and decreased in every interval in 6 of the 8 runs.
- On the intervals on which (A) fails, the median relative change is between $-3\cdot10^{-2}$ and $+2\cdot10^{-3}$. The largest is $+12\%$ per $0.2$ time units at $\alpha\le10^{-3}$ ($+66\%$ per $1.0$ in the $t=400$ run), and $+63\%$ at $\alpha=10^{-2}$, where the clusters are loose.
- At $\alpha=10^{-3}$ the median $Q_{jk}$ falls from $9.9\cdot10^{-7}$ to $1.3\cdot10^{-7}$ for $x_1$, by less than one order of magnitude. For MAJ$_3$ it falls by 2.7–4 orders of magnitude. At $\alpha=10^{-6}$ it rises from $10^{-12}$ to $1.8$–$3.8\cdot10^{-9}$: the norms grow by $10^{10}$ during the alignment phase, when (A) often fails.

**What would prove it.** Two pieces are missing:
- a sliding-mode version of the masked-linear convergence argument, which would give (A) from the sign of $r^\star$ and a margin of the residual at the boundary points;
- an alignment estimate at the escape (Boursier–Flammarion; Kumar–Haupt 2024), which would put the clusters' directions near the critical directions.

**Known special cases.** The non-asymptotic analyses past the first escape that I know of are all for special data:
- orthogonal inputs (Boursier–Pillaud-Vivien–Flammarion 2022);
- linearly separable symmetric data with leaky ReLU (Lyu–Li–Wang–Arora 2021; from memory);
- a single teacher neuron with correlated inputs (Chistikov–Englert–Lazić 2023; abstract checked).

AGF (Kunin et al. 2025) and neuron pursuit (Kumar–Haupt 2025) are the α→0 model and the greedy algorithm that Conjecture D4 would connect to the network.

## 5. Numerical check, ReLU

[`checks/D_relu_check.py`](checks/D_relu_check.py) produces [`checks/D_relu_check.out`](checks/D_relu_check.out), in about 10 minutes on one core (the last, $t=400$ configuration takes half of that). Its labels use an older theorem numbering; the map to the current numbers is under [Files](#files).
- **Setup.** $d=16$, width $m=64$, $|a_j(0)|=\|w_j(0)\|=\alpha$ with random signs and uniform random directions. $n$ training points are drawn without replacement from the cube. Lemma D0.2 covers this sampling (remark after it).
- **Training.** Full-batch GD with $\eta=0.02$ (one run at $\eta=0.004$) approximates the flow.
- **Evaluation.** Test quantities are exact over all $2^{16}$ inputs. "Bound" columns use the certified $\hat U(y)$ of Lemma D2.1.
- **Which function is certified.** The script evaluates three things for the balanced surrogate $\tilde f=\sum_j\epsilon_j\frac{\rho_j}2\sigma(\hat w_j\cdot\tilde x)$ built from the GD state, not for the GD network $f=\sum_ja_j\sigma(w_j\cdot\tilde x)$: the D3.2 and D3.3 certificates, the training margins, and the exact test error.
  - For the flow the two coincide (Lemma D1(c)). For GD, $f-\tilde f=-\sum_j\epsilon_j\frac{(|a_j|-\|w_j\|)^2}2\,\sigma(\hat w_j\cdot\tilde x)$, which is second order in the balance drift.
  - For MAJ$_3$, $n=1000$, $\alpha=10^{-3}$, the referee evaluated the D3.3 certificate on the GD network itself. Proposition D3.3 allows any predictor, so the referee took the GD network $f$ as the predictor and kept the same $K$-neuron $g$. $\sup_{\rm cube}|f-\tilde f|$ is $3.6\cdot10^{-7}$ at $t=30$ and $1.1\cdot10^{-6}$ at $t=60$, and the certificate ($0.190$) and test error ($0$) are unchanged ([`checks/referee_D_r1.out`](checks/referee_D_r1.out), R11).
  - The other rows were not recomputed, so they are certificates of the surrogate.

| target, $n$, $\alpha$ | $\hat U(y)$ / multistart $U_0^*$ | D2(1): max exponent ratio, $\hat U$ / C3.1 | $t_{0.1}$ observed / $T_{0.1}$ (D2) / C3.1 | D3: max $P$/a priori, $P$/loss-curve | $P$ at end; a priori; loss-curve | clusters at end | D3.3 bound / test error |
|---|---|---|---|---|---|---|---|
| $x_1$, 1000, $10^{-3}$ | 0.764 / 0.753 | 0.92 / 0.63 | 6.0 / 4.03 / 2.83 | 0.40, 0.95 | 2.83; 36.0; 3.41 | 2 (34+30) | 0.190 / 0 |
| MAJ$_3$, 1000, $10^{-3}$ | 0.758 / 0.678 | 0.84 / 0.56 | 6.8 / 4.06 / 2.83 | 0.32, 0.95 | 2.86; 56.0; 3.87 | 2 | 0.190 / 0 |
| MAJ$_3$, 1000, $10^{-6}$ | 0.758 / 0.678 | 0.87 / 0.59 | 17.0 / 12.49 / 8.70 | 0.22, 0.94 | 2.86; 77.5; 4.98 | 2 | 0.190 / 0 |
| MAJ$_3$, 4000, $10^{-6}$ | 0.691 / 0.623 | 0.87 / 0.58 | 18.2 / 13.73 / 9.31 | 0.29, 0.97 | 2.83; 46.3; 3.09 | 2 | **0.051** / 0 |
| $x_1+\frac12x_2x_3$, 1000, $10^{-6}$ | 0.783 / 0.768 | 0.95 / 0.59 | 15.0 / 12.12 / 7.72 | 0.25, 0.94 | 3.21; 138.5; 5.34 | 2; stalls (test MSE 0.232) | — |
| $x_1+\frac12x_2x_3$, 1000, $10^{-2}$ | 0.783 / 0.768 | 0.87 / 0.53 | 2.8 / 1.22 / 0.78 | 0.81, 0.87 | 6.06; 75.3; 12.1 | 14 (fits; test MSE $<10^{-4}$) | — |

**Other checks** (all in the `.out` file):
- **Lemma D1(a), balance** drifts by at most $2.2\cdot10^{-3}$ of $\max\rho$ under GD, against $0$ for the flow; the drift is $O(\eta)$ in total, $3.6\cdot10^{-4}$ at $\eta=0.004$.
- **Lemma D1(e), monotone loss** holds under GD for $x_1$ and the $\alpha=10^{-2}$ run. For MAJ$_3$, and for $x_1+\frac12x_2x_3$ at $\alpha=10^{-6}$, GD increases the loss (by tiny amounts) on 640–1710 of its steps (8545 of 20000 in the $t=400$ run). That is the zig-zag across kinks, which the flow does not have.
- **Lemma D1(f)** holds up to $-6\cdot10^{-4}$ per step, again from kink crossings.
- **Lemma D1(g).**
  - The sign claim $m_{jk}\ge0$ holds exactly, and the flow-velocity form of $\dot Q$ is $\le0$ at every step at which all separating points attract.
  - On GD trajectories, over intervals on which (A) holds and $1-\cos\ge10^{-4}$, $Q_{jk}$ increases by at most $0.2\%$, and strictly decreases in 6 of the 8 runs. The median relative change per interval is between $-3\cdot10^{-5}$ ($\alpha=10^{-2}$) and $-40\%$.
  - Over intervals on which the pair keeps one activation pattern, $|\Delta Q|/Q\le10^{-5}$: conservation up to GD's $O(\eta^2)$ terms.
  - Below $1-\cos\approx10^{-4}$, the $O(\eta^2)$ terms of GD dominate $Q$, and the flow statement is not tested there.
- **Proposition D2.2.** Over the whole run, the measured time with $\|\Pi\xi^y\|\ge0.3$ is at most $5.5$ time units for $x_1$ and MAJ$_3$, against the bound $150$–$880$. On $x_1+\frac12x_2x_3$ it is $107$ of $120$, because after the escape the neurons are stationary for $U_r$, not for $U_y$. The proposition is only meant for the pre-escape window.
- **Theorem D3.2 (Maurey/Occam)** is vacuous ($1.0$) at every checkpoint, both with the measured $P$ and with the a priori bound.
- **The stall persists.** The $x_1+\frac12x_2x_3$ run at $\alpha=10^{-6}$, continued to $t=400$ (last configuration in the script), keeps $L=0.1095$, test MSE $0.2323$ and $P=3.22$. At $t=400$ the a priori path-norm bound is $498$ and the loss-curve bound $5.5$.

**Reading.**
- **The clock bounds.** In these runs Theorem D2's growth bound is tight in the exponent to within 5–16%. At $\alpha\le10^{-3}$ its escape-time lower bound is 60–81% of the observed time, against 42–51% for C3.1's. The remaining gap is the $\ln m$ term and the alignment time, during which the escaping neurons have less than the maximal utility.
- **The path-norm bounds.** The a priori bound is tight only near $T_\beta$. At the end of the runs it is loose by a factor of 12–43, growing linearly in $t$. The loss-curve bound reaches $0.87$–$0.97$ of $P$ at its tightest, and is within a factor of 2 at the end of every run.
- **The certificate.** The certificate that works is the $K$-neuron one, with the network's own 2 clusters. It is a posteriori. The a priori Conjecture D4 would make it predictive.

---

# Part II. Two-layer quadratic networks: time limits rank

## 6. Setting

**Network.** For $U\in\mathbb R^{d\times h}$ and $V\in\mathbb R^{d\times h'}$,
$$f_{U,V}(x)=\sum_{j\le h}\big[(u_j\cdot x)^2-\|u_j\|^2\big]-\sum_{j\le h'}\big[(v_j\cdot x)^2-\|v_j\|^2\big]=\langle X,\,xx^\top-I\rangle,\qquad X=UU^\top-VV^\top .$$
- **On the cube** $\langle X,xx^\top-I\rangle=\sum_{k\ne l}X_{kl}x_kx_l$. So each hidden unit is a rank-one interaction feature $2\sum_{k<l}u_ku_lx_kx_l$ with output weight $\pm1$. The units are centred: the constant $\|u\|^2$ that a plain quadratic unit $(u\cdot x)^2$ adds on the cube is removed.
  - *Fixed output layer.* The output weights are fixed at $\pm1$ and not trained, so the model is symmetric matrix sensing, not a fully trained two-layer network. With trainable output weights $c_j(u_j\cdot x)^2$ the dynamics are 3-homogeneous, the factors no longer evolve linearly given the residual, and nothing below applies.
  - *Why the centring matters.* Without it, all units share the constant feature and the coherence constant $\kappa$ below becomes about $K$, which makes the rank bound vacuous.
  - *Relation to a plain quadratic network.* A plain quadratic network with an output bias kept at its least-squares value has the same $U,V$ dynamics as the centred network with such a bias. Its gradient in $X$ is $-\frac1n\sum_ir_ix_ix_i^\top$, which equals $-M_r$ because the refitted residual has $\sum_ir_i=0$.
    - Theorems D5 and D6(1), (2), (4), (5) apply to that variant, with $r$ the bias-refitted residual.
    - D6(3) needs one change. The refitted residual is $(y-\bar y)-(f-\bar f)$, with $f=\langle X,xx^\top-I\rangle$, so $U_0^*=\|M_{y-\bar y}\|_{op}$ replaces $\|M_y\|_{op}$. The proof is otherwise the same, since $\|M_{f-\bar f}\|_{op}\le\sqrt\kappa\|f-\bar f\|_n\le\sqrt\kappa\|f\|_n$.
    - Theorem D7 would need one more grid parameter for the bias.
- **Measurements and loss.** $A_i=x_ix_i^\top-I$, $\mathcal A(Z)_i=\langle Z,A_i\rangle$, $M_r=\frac1n\sum_ir_iA_i$ (symmetric), and $L=\frac12\|y-f\|_n^2$, so that $\nabla_XL=-M_r$.
- **Gradient flow:** $\dot U=2M_rU$, $\dot V=-2M_rV$. GD: $U\leftarrow(I+2\eta M_r)U$ and $V\leftarrow(I-2\eta M_r)V$; SGD uses the minibatch $M_r$.
- **Initialization.** $U(0)=\alpha U_0$, $V(0)=\alpha V_0$, $s_0=\max(\|U_0\|_{op},\|V_0\|_{op})$.
  - *Width.* The width enters Part II only through $s_0$ (in $\Theta_\epsilon$ below) and $P(0)$ (in D6(4)–(5)), and not at all if $U_0,V_0$ are scaled to unit operator norm. This is the analogue of Part I's $P(0)$. For iid $N(0,1/d)$ entries $s_0\approx1+\sqrt{h/d}$, so at large width $\Theta_\epsilon$ loses about $\frac14\ln(h/d)$.
- **Existence.** The vector field is polynomial, $L$ is nonincreasing, and $\frac d{dt}(\|U\|_F^2+\|V\|_F^2)=4\langle r,f\rangle_n\le\|y\|_n^2$ (as in Lemma D1(e)). So the flow exists for all $t$.
- **Grown count.** $N_\epsilon(t)=\#\{k:\sigma_k(U)^2\ge\epsilon\}+\#\{k:\sigma_k(V)^2\ge\epsilon\}$, the number of eigenvalues of $UU^\top$ and $VV^\top$ that have grown to at least $\epsilon$.
- **Clock unit and effective time.** $\Theta_\epsilon=\frac14\ln\frac{\epsilon}{\alpha^2s_0^2}$ and $\tau(t)=\int_0^t\|r\|_n$.
- **Coherence.**
$$\kappa:=\sup_{Z=Z^\top\ne0}\frac{\|\mathcal A(Z)\|_n^2}{\|Z\|_F^2}=2\,\lambda_{\max}\Big(\frac1n\Phi^\top\Phi\Big),\qquad \Phi_{i,(k,l)}=x_{ik}x_{il}\ (k<l).$$
  - *Proof of the identity.* On the cube $\langle Z,A_i\rangle=2\sum_{k<l}Z_{kl}x_{ik}x_{il}$. So $\|\mathcal A(Z)\|_n^2=4z^\top\frac{\Phi^\top\Phi}nz$ with $z=(Z_{kl})_{k<l}$, while $\|Z\|_F^2\ge2\|z\|^2$, with equality for zero-diagonal $Z$.
  - *Values.* Its population value is $2$. It depends on the training inputs only.

**The model in the literature.**
- This is symmetric matrix sensing with rank-one-type measurements, and a two-layer network with quadratic activation.
- Gradient descent from small initialization on matrix sensing behaves like a spectral method early on (Stöger–Soltanolkotabi, NeurIPS 2021) and learns incrementally, with increasing rank (Li–Luo–Lyu, ICLR 2021; Jin–Li–Lyu–Du–Lee, ICML 2023, PMLR 202:15200–15238). **Literature**: abstracts checked; theorem-level details from memory. Their theorems assume RIP-type conditions on the measurements.
- The statements below are one-sided: an upper bound on rank at every time. They need no RIP, hold for any data, width and step size, and are generalization statements.
- Kunin et al.'s complete AGF characterization of quadratic networks on modular addition concerns a related model class with quadratic activation (**Literature**, abstract checked in C).

## 7. Results

### Theorem D5 (the log-det clock) — Proved

1. **Flow.** Let $A:[0,T]\to\mathrm{Sym}_d$ be continuous and $\dot W=A(t)W$, $W(0)=W_0\in\mathbb R^{d\times h}$. For every $K\le\min(d,h)$ and $t\le T$, with $\ln0=-\infty$,
$$\sum_{k\le K}\ln\sigma_k(W(t))\ \le\ \sum_{k\le K}\ln\sigma_k(W_0)+\int_0^t\sum_{k\le K}\lambda_k(A(s))\,ds .$$
2. **Discrete.** If $W_{j+1}=(I+\eta A_j)W_j$ with symmetric $A_j$ and $I+\eta A_j\succ0$, then
$$\sum_{k\le K}\ln\sigma_k(W_J)\le\sum_{k\le K}\ln\sigma_k(W_0)+\sum_{j<J}\sum_{k\le K}\ln(1+\eta\lambda_k(A_j))\le\sum_{k\le K}\ln\sigma_k(W_0)+\eta\sum_{j<J}\sum_{k\le K}\lambda_k(A_j).$$

*Proof.* Two facts are used, both from Courant–Fischer.
- **Interlacing.** For symmetric $H$ and $E\in\mathbb R^{d\times K}$ with orthonormal columns, the eigenvalues of $E^\top HE$ satisfy $\mu_k\le\lambda_k(H)$. Hence $\mathrm{tr}(E^\top HE)\le\sum_{k\le K}\lambda_k(H)$ (Ky Fan's maximum principle), and for $H\succeq0$, $\det(E^\top HE)\le\prod_{k\le K}\lambda_k(H)$.

1. **Flow.** Fix $t$, and let $E\in\mathbb R^{h\times K}$ hold the top $K$ right singular vectors of $W(t)$.
   - Put $M(s)=W(s)E$ and $G=M^\top M$, so that $\dot M=AM$. If $\sigma_K(W(t))=0$ there is nothing to prove.
   - Otherwise $M(t)$ has rank $K$. Since $M(s)=\Phi(s)M(0)$ for the invertible fundamental matrix $\Phi$ of $\dot\Phi=A\Phi$, $M(s)$ has rank $K$ for all $s$, and $G(s)\succ0$.
   - Then $\frac d{ds}\ln\det G=\mathrm{tr}(G^{-1}\dot G)=2\,\mathrm{tr}(M(M^\top M)^{-1}M^\top A)=2\,\mathrm{tr}(\Pi_sA)$, where $\Pi_s$ is the orthogonal projection onto the column space of $M(s)$, of rank $K$. By Ky Fan, this is at most $2\sum_{k\le K}\lambda_k(A)$.
   - Integrate. Finally, $\det G(t)=\prod_{k\le K}\sigma_k(W(t))^2$ by the choice of $E$, and $\det G(0)=\det(E^\top W_0^\top W_0E)\le\prod_{k\le K}\sigma_k(W_0)^2$ by interlacing.
2. **One discrete step.** Let $W'=BW$ with $B\succ0$ symmetric, and let $E$ hold the top-$K$ right singular vectors of $W'$, $M=WE$.
   - If $\mathrm{rank}\,M<K$, the left side is $-\infty$.
   - Otherwise write $M=QR$ with $Q$ orthonormal and $R$ invertible. Then $\prod_{k\le K}\sigma_k(W')^2=\det(M^\top B^2M)=\det(R)^2\det(Q^\top B^2Q)\le\det(M^\top M)\prod_{k\le K}\sigma_k(B)^2\le\prod_{k\le K}\sigma_k(W)^2\sigma_k(B)^2$. This is Horn's inequality for this case.
   - For $B=I+\eta A_j\succ0$, $\sigma_k(B)=1+\eta\lambda_k(A_j)$.
   - Iterate, and use $\ln(1+z)\le z$. ∎

### Theorem D6 (time limits rank) — Proved

For the quadratic network under gradient flow, for every $t$ and every $\epsilon$ with $\Theta_\epsilon>0$, write $N^U$, $N^V$ for the two parts of $N_\epsilon(t)$.
1. **Clock form:**
$$N^U\Theta_\epsilon\le\int_0^t\sum_{k\le N^U}\lambda_k(M_{r(s)})\,ds,\qquad N^V\Theta_\epsilon\le\int_0^t\sum_{k\le N^V}\lambda_k(-M_{r(s)})\,ds .$$
2. **Rank bound:**
$$N_\epsilon(t)\le\kappa\,\Big(\frac{\tau(t)}{\Theta_\epsilon}\Big)^2 .$$
3. **No early growth.** The first time $t_\epsilon$ at which some eigenvalue of $UU^\top$ or $VV^\top$ reaches $\epsilon$ satisfies
$$t_\epsilon\ \ge\ \frac{\Theta_\epsilon}{U_0^*+2\kappa\sqrt d\,\epsilon},\qquad U_0^*:=\|M_y\|_{op}=\sup_{\|e\|=1}\big|\langle y,(e\cdot x)^2-1\rangle_n\big| ,$$
   which is the largest initial utility of one unit.
4. **Path norm.** $P(t):=\|U\|_F^2+\|V\|_F^2\ge\|X(t)\|_*$, and $\dot P=4\langle r,f\rangle_n\le\|y\|_n^2$.
5. **GD and SGD.** Let $M_j$ be the matrix of step $j$: $M_{r_j}$ for GD, and the minibatch matrix of batch $B_j$ for SGD. Write $\|\cdot\|_{B_j}$ for the minibatch norm and $\kappa_{B_j}$ for the coherence of $B_j$, i.e. $\kappa$ computed on $B_j$. For GD, $B_j$ is the whole sample and $\kappa_{B_j}=\kappa$.
   - *Clock, rank and no early growth, under the step-size condition.* Assume $2\eta\|M_j\|_{op}<1$ at every step, for GD and SGD alike.
     - For GD, items 1–3 hold with $\int_0^t\to\eta\sum_{j<J}$, $\tau_J=\eta\sum_{j<J}\|r_j\|_n$, and $t_\epsilon=\eta J_\epsilon$, where $J_\epsilon$ is the first step at which some eigenvalue reaches $\epsilon$.
     - For SGD, item 1 holds with the minibatch matrices $M_j$ in place of $M_{r(s)}$. Item 2 becomes $N\le\big(\eta\sum_j\sqrt{\kappa_{B_j}}\|r_j\|_{B_j}\big)^2/\Theta_\epsilon^2$. This is large for small batches: a single sample has $\kappa=d(d-1)$. Item 3 holds with $\max_{j<J_\epsilon}\|M^{B_j}_y\|_{op}$ in place of $U_0^*$ and $\max_{j<J_\epsilon}\kappa_{B_j}$ in place of $\kappa$, where $M^{B_j}_y=\frac1{|B_j|}\sum_{i\in B_j}y_iA_i$.
   - *Path norm, with no step-size condition.*
$$P_J\ \le\ \exp\Big(4\eta^2\sum_{j<J}\|M_j\|_{op}^2\Big)\Big(P(0)+\eta\sum_{j<J}\|y\|_{B_j}^2\Big)\ \le\ \exp\Big(4\eta^2\sum_{j<J}\kappa_{B_j}\|r_j\|_{B_j}^2\Big)\Big(P(0)+\eta\sum_{j<J}\|y\|_{B_j}^2\Big).$$
     - The flow bound $P\le P(0)+t\|y\|_n^2$ of item 4 can fail for GD. The referee found a one-step counterexample from $f=y/2$ with $2\eta\|M\|_{op}=0.4$ ([`checks/referee_D_r1.out`](checks/referee_D_r1.out), R8).
     - The exponent is $4\eta$ times $\eta\sum_j\kappa_{B_j}\|r_j\|_{B_j}^2$. So for GD it is $O(\eta)$ whenever $\eta\sum_j\|r_j\|_n^2$ stays bounded, for example as $\eta\to0$ at fixed $t=\eta J$, where GD (Euler's method for a polynomial vector field) converges to the flow.

*Proof.*
1. Apply Theorem D5 to $U$ with $A=2M_r$, at $K=N^U$. Every $\sigma_k(U(t))\ge\sqrt\epsilon$ for $k\le K$ and $\sigma_k(U(0))\le\alpha s_0$, so $\frac K2\ln\epsilon\le K\ln(\alpha s_0)+2\int\sum_{k\le K}\lambda_k(M_r)$, i.e. $K\Theta_\epsilon\le\int\sum_{k\le K}\lambda_k(M_r)$. The same for $V$ with $A=-2M_r$.
2. At each time $s$, bound the two integrands together.
   - Let $\Pi_+$ project onto the eigenvectors of $M_{r(s)}$ with positive eigenvalue among its top $N^U$, and $\Pi_-$ onto those with negative eigenvalue among its bottom $N^V$. They are orthogonal projections onto orthogonal subspaces.
   - With $Z=\Pi_+-\Pi_-$, $\|Z\|_F^2\le N:=N^U+N^V$, and
$$\sum_{k\le N^U}\lambda_k(M)+\sum_{k\le N^V}\lambda_k(-M)\le\langle M,Z\rangle=\langle r,\mathcal A(Z)\rangle_n\le\|r\|_n\sqrt\kappa\|Z\|_F\le\|r\|_n\sqrt{\kappa N}.$$
   - Add the two inequalities of item 1: $N\Theta_\epsilon\le\tau(t)\sqrt{\kappa N}$.
3. Let $t_\epsilon$ be the first time some eigenvalue reaches $\epsilon$; the set where this has happened is closed, so it holds at $t_\epsilon$.
   - For $s<t_\epsilon$, $\|UU^\top\|_F,\|VV^\top\|_F<\sqrt d\,\epsilon$, so $\|f_s\|_n=\|\mathcal A(X)\|_n\le\sqrt\kappa\|X\|_F<2\sqrt{\kappa d}\,\epsilon$.
   - Also $\|M_f\|_{op}=\sup_{\|e\|=1}\langle f,\mathcal A(ee^\top)\rangle_n\le\sqrt\kappa\|f\|_n$. So $\|M_{r(s)}\|_{op}\le U_0^*+2\kappa\sqrt d\,\epsilon$.
   - Item 1 with $N=1$ gives $\Theta_\epsilon\le t_\epsilon(U_0^*+2\kappa\sqrt d\,\epsilon)$.
4. $\|X\|_*\le\|UU^\top\|_*+\|VV^\top\|_*=\mathrm{tr}\,UU^\top+\mathrm{tr}\,VV^\top$. Also $\frac d{dt}\|U\|_F^2=4\,\mathrm{tr}(M_rUU^\top)$ and $\frac d{dt}\|V\|_F^2=-4\,\mathrm{tr}(M_rVV^\top)$, which sum to $4\langle M_r,X\rangle=4\langle r,f\rangle_n\le\|y\|_n^2$.
5. *Clock and rank.* Theorem D5(2) with $A_j=\pm2M_j$. The condition $2\eta\|M_j\|_{op}<1$ makes $I\pm2\eta M_j\succ0$. Item 2's argument applies to each step's matrix.
   *No early growth.* Item 3's argument applies to the steps $j<J_\epsilon$. There $\|X_j\|_F<2\sqrt d\,\epsilon$, so $\|M_j\|_{op}\le\|M^{B_j}_y\|_{op}+\sqrt{\kappa_{B_j}}\|f_j\|_{B_j}<\|M^{B_j}_y\|_{op}+2\kappa_{B_j}\sqrt d\,\epsilon$, and the discrete item 1 with $N=1$ at step $J_\epsilon$ gives $\Theta_\epsilon\le\eta\sum_{j<J_\epsilon}\|M_j\|_{op}$.
   *Path norm.* One step $U'=(I+2\eta M_j)U$, $V'=(I-2\eta M_j)V$ gives $P_{j+1}=P_j+4\eta\langle M_j,X_j\rangle+4\eta^2(\|M_jU_j\|_F^2+\|M_jV_j\|_F^2)$.
   - $\langle M_j,X_j\rangle=\langle r_j,f_j\rangle_{B_j}=\langle r_j,y-r_j\rangle_{B_j}\le\frac14\|y\|_{B_j}^2$, as in Lemma D1(e).
   - $\|M_jU\|_F\le\|M_j\|_{op}\|U\|_F$, and the same for $V$.
   - So $P_{j+1}\le(1+4\eta^2\|M_j\|_{op}^2)P_j+\eta\|y\|_{B_j}^2$. Iterate, bound each partial product of the factors by the full product, and use $1+z\le e^z$.
   - Finally, $\|M_j\|_{op}=\sup_{\|e\|=1}|\langle r_j,\mathcal A(ee^\top)\rangle_{B_j}|\le\sqrt{\kappa_{B_j}}\|r_j\|_{B_j}$, because $\|ee^\top\|_F=1$. ∎

**Reading.**
- **The user's argument, for a non-diagonal network.** This is the user's argument for a non-diagonal two-layer network at every time, with no plateau analysis and no hypothesis on the data or the trajectory.
  - The number of effective hidden units (rank) that have grown above $\epsilon$ is at most $\kappa(\tau/\Theta_\epsilon)^2$.
  - $\Theta_\epsilon\approx\frac12\ln\frac1\alpha$, and $\kappa$ is a property of the training inputs, about $2$. The width enters only through $s_0$ in $\Theta_\epsilon$ (§6).
  - Trivially also $N_\epsilon\le\min(d,h)+\min(d,h')$, so D7 may use the smaller of the two bounds. Late in the MAJ-of-pairs run of §7.4 the trivial bound ($32$) is the smaller one: the weight-free bound is $37$ at $t=25$ and $47$ at $t=30$.
  - *Caveat 1: the model.* The output weights are fixed at $\pm1$ and the units are centred, so this is symmetric matrix sensing (§6). It is not a fully trained two-layer network.
  - *Caveat 2: weight-free, not a priori.* The bound uses $\tau=\int\|r\|_n$, read off the training-loss curve. It does not look at the weights, but it is not a function of time alone. For the flow, $\tau(t)\le R_0t$ with $R_0=\|r(0)\|_n$, because $L$ is nonincreasing. That gives the time-only form $N_\epsilon(t)\le\kappa(R_0t/\Theta_\epsilon)^2$, which is much weaker: for $x_1x_2$ at $n=3000$ (§7.4, $\gamma=\frac12$, $R_0\approx1$) it gives $N\le42$ at $t=20$, against $4$ from $\tau$.
  - *Relation to C2.* The proofs of D5–D6 use only that the $A_i$ are symmetric, with $\kappa=\sup_Z\|\mathcal A(Z)\|_n^2/\|Z\|_F^2$. Take diagonal $A_i=\mathrm{diag}(\chi_S(x_i))_S$ and diagonal initialization $U(0)=V(0)=\alpha I$. Then $U,V$ stay diagonal and this is C2's network. Commuting $A_i$ alone is not enough: the initialization must also be diagonal in their common eigenbasis.
  - Item 2 then implies a slightly weaker form of C2.3(2), for three reasons:
    1. $N_\epsilon$ counts the coordinates with $u_S^2\ge\epsilon$ or $v_S^2\ge\epsilon$ separately. That is an upper bound on C2's count of $|w_S|\ge\epsilon$.
    2. $\Theta_\epsilon=\frac14\ln\frac\epsilon{\alpha^2}$ (here $s_0=1$), against C2's $\frac14\operatorname{arsinh}\frac\epsilon{2\alpha^2}\ge\frac14\ln\frac\epsilon{\alpha^2}$.
    3. $\kappa$ is the global Gram eigenvalue, in place of C2's sharper $\kappa_B$ of the grown set.
  - Here the global $\kappa$ is already small ($\approx2$), because in the checks $n$ exceeds the number $\binom d2$ of pair features. In C2's checks the dictionary was larger than $n$, which is why C2 needed $\kappa_B$.
  - A sharper version uses $\kappa_N=\sup\{\|\mathcal A(Z)\|_n^2/\|Z\|_F^2:\mathrm{rank}\,Z\le N\}$.
- **Why it works here and not for ReLU.** The hidden layer's state is the $d\times d$ matrix $X$, and given the residual each factor evolves *linearly*, $\dot U=2M_rU$. The clock is spectral, the Ky Fan sum of the top $K$ eigenvalues of the utility matrix $M_r$. For ReLU the analogous linear structure holds only inside a fixed activation cell (Remark after Lemma D1).
- **Time.** Only time *in units of $\Theta_\epsilon$* matters. If the residual vanishes after the fit, $\tau$ stops growing and the bound freezes. If the residual plateaus at a nonzero value (a target outside the model class), $\tau$ grows linearly on the plateau and the bound loosens, as in C2.5.

### Theorem D7 (generalization, uniform in time) — Proved

Let $d\ge2$ and $y\in\{-1,1\}$. Fix the following, before seeing the data:
- **Margins.** A finite grid $\Gamma\subset(0,8(d-1)]$. The upper limit is automatic for $\gamma\le1$.
- **Grids.** For $K\ge0$, a dyadic $B=2^\ell$ and $\gamma\in\Gamma$, let $\eta_\lambda=\gamma/(8(d-1)\max(K,1))$ and $\eta_z=\gamma/(16(d-1)(B+1))$. Let $\mathcal N_{\eta_z}$ be a net of $S^{d-1}$.
- **Class.** $\mathcal G_{K,B,\gamma}=\{\sum_{k\le K}\lambda'_kz_kz_k^\top:\lambda'_k\in\eta_\lambda\mathbb Z,\ |\lambda'_k|\le\eta_\lambda\lceil B/\eta_\lambda\rceil,\ z_k\in\mathcal N_{\eta_z}\}$, with
$$C_{K,B,\gamma}:=\ln|\mathcal G_{K,B,\gamma}|\le K\ln\big(2\lceil B/\eta_\lambda\rceil+1\big)+dK\ln(1+2/\eta_z).$$

With probability at least $1-\delta$ over $S$, the following holds simultaneously for all $t\ge0$ and $\gamma\in\Gamma$. Put $\epsilon_\gamma=\gamma/(8(d-1))$, and assume $\Theta_{\epsilon_\gamma}>0$, i.e. $\epsilon_\gamma>\alpha^2s_0^2$, wherever Theorem D6 is used below. Then for every integer $N\ge N_{\epsilon_\gamma}(t)$ and every dyadic $B\ge P(t)$,
$$\mathrm{err}(\mathrm{sgn}f_t)\le\mathrm{kl}^{-1}_+\Big(\widehat P_S[yf_t\le\gamma],\ \frac{C_{N,B,\gamma}+\ln\frac{2|\Gamma|(N+1)(N+2)(|\ell|+1)(|\ell|+2)}\delta}n\Big).$$
The proof uses only the current $(U,V)$. So the same event gives the bound simultaneously for every pair $(U,V)$, with $N_\epsilon$ and $P$ of that pair, and in particular for every GD or SGD iterate.

**Admissible choices.**
- $N$:
  - $N=N_{\epsilon_\gamma}(t)$ (measured);
  - $N=\lfloor\kappa(\tau(t)/\Theta_{\epsilon_\gamma})^2\rfloor$ (Theorem D6(2), weight-free: from the loss curve and the training inputs; for GD with $\tau_J$, D6(5));
  - for the flow, $N=\lfloor\kappa(R_0t/\Theta_{\epsilon_\gamma})^2\rfloor$ (time-only, since $\tau\le R_0t$; much weaker).
  - Any data-dependent $N\ge N_{\epsilon_\gamma}(t)$ is admissible, for example the maximum of the measured and the weight-free values, or the minimum of the weight-free value and the trivial bound $\min(d,h)+\min(d,h')$.
- $B$:
  - for the flow, the dyadic round-up of $P(0)+t\|y\|_n^2$ (Theorem D6(4), a priori);
  - for GD or SGD, the dyadic round-up of the D6(5) path-norm bound;
  - in all cases, the dyadic round-up of the measured $P(t)$, or any dyadic $B\ge P(t)$.

*Proof.*
1. **Split.** Write $X(t)=X_b+X_s$ with $X_b=(UU^\top)_{\ge\epsilon}-(VV^\top)_{\ge\epsilon}$, where $(H)_{\ge\epsilon}$ keeps the eigencomponents of the PSD matrix $H$ with eigenvalue at least $\epsilon=\epsilon_\gamma$.
   - $\mathrm{rank}\,X_b\le N_\epsilon(t)\le N$ and $\|X_b\|_*\le P(t)\le B$.
   - $X_s$ is a difference of two PSD matrices with eigenvalues below $\epsilon$, so $\|X_s\|_{op}<\epsilon$.
   - The matrix $xx^\top-I$ has eigenvalues $d-1$ (once) and $-1$ ($d-1$ times), so $\|xx^\top-I\|_*=2(d-1)$ and $\|xx^\top-I\|_{op}=d-1$. Hence $\sup_x|\langle X_s,xx^\top-I\rangle|\le2(d-1)\epsilon=\gamma/4$.
2. **Rounding.** Fix any integer $N\ge N_\epsilon(t)$; if $N=0$, then $X_b=0\in\mathcal G_{0,B,\gamma}$. Otherwise write $X_b=\sum_{k\le N}\lambda_kz_kz_k^\top$, padding with zero eigenvalues up to $N$ terms, with $\sum|\lambda_k|\le B$. Round each $\lambda_k$ in the grid $\eta_\lambda\mathbb Z$ of $\mathcal G_{N,B,\gamma}$ ($|\lambda_k-\lambda'_k|\le\eta_\lambda/2$, and $|\lambda_k|\le B$ keeps $\lambda'_k$ in range), and round each $z_k$ to the net.
   - Since $\|zz^\top-z'z'^\top\|_*\le2\|z-z'\|$, $\|X_b-X'\|_*\le\frac{N\eta_\lambda}2+2\eta_z(B+\frac{N\eta_\lambda}2)$.
   - Here $N\eta_\lambda=\gamma/(8(d-1))\le1$, because $\gamma\le8(d-1)$. So this is at most $\frac{\gamma}{16(d-1)}+\frac{\gamma}{8(d-1)}$.
   - Times $\|xx^\top-I\|_{op}=d-1$, the sup error is below $\gamma/4$. So $g=\langle X',xx^\top-I\rangle$ has $\sup_x|f_t-g|\le\gamma/2$.
3. **Margins.** On test points, $yf_t\le0\Rightarrow yg\le\gamma/2$. On training points, $yg\le\gamma/2\Rightarrow yf_t\le\gamma$.
4. **Occam.** Apply Lemma D0.2 to $\{yg\le\gamma/2\}$, $g\in\mathcal G_{N,B,\gamma}$, over $(N,\ell,\gamma)$.
   - Step 2 used only $\mathrm{rank}\,X_b\le N$, so it applies directly to every $N\ge N_\epsilon(t)$, in the grid of $\mathcal G_{N,B,\gamma}$ itself.
   - No nesting of the classes is needed. They are in fact not nested in $N$: $\eta_\lambda$ depends on $N$, and $\eta_\lambda(N)/\eta_\lambda(N+1)=(N+1)/N$ is not an integer for $N\ge2$. ∎

**Comparison.**
- *Unrestricted class.* $\{\mathrm{sgn}\langle X,xx^\top-I\rangle\}$ is an affine sign class of $\binom d2$ features on at most $2^{d+1}$ points. By Cover's count (C, Lemma C0.2) its capacity is $\ln\Phi(2^{d+1},\binom d2+1)\approx964$ nats at $d=16$. This is the value the script uses; the cruder bound $(\binom d2+1)(d+1)\ln2$ is $1426$.
- *Rank-$N$ class.* Its capacity is about $(d+1)N\ln(32d(B+1)/\gamma)$: $127$–$129$ nats per unit at $d=16$, $B=1$, $\gamma=\frac12$.
- *Break-even.* With the prior terms included, the rank bound beats the unrestricted class for $N\le7$ at $d=16$, $B=1$, $\gamma=\frac12$ (break-even $N\approx7$–$8$). That is about a sixteenth of $\binom d2$. This matches §7.4, where MAJ of three pairs with measured $N=6$ gives $0.270$ against $0.276$.

### 7.4 Numerical check, quadratic networks

[`checks/D_quad_check.py`](checks/D_quad_check.py) produces [`checks/D_quad_check.out`](checks/D_quad_check.out), in about 15 seconds. Its labels use an older numbering (map under [Files](#files)). The round-2 referee replayed the four classification runs with the same seeds, reproduced every printed number, and added the proved GD norm bound, the step-size check and the SGD first-growth bound used below ([`checks/referee_D_r2.out`](checks/referee_D_r2.out), S3).
- **Setup.** $d=16$, $h=h'=16$, $U_0,V_0$ with iid $N(0,1/d)$ entries, $\alpha=10^{-6}$.
- **Training.** GD with $\eta=0.01$; one run uses SGD with batch 64.
- **Evaluation.** Exact test error over all $2^{16}$ inputs; $\Gamma=\{0.25,0.5\}$ and $\delta=0.05$. Training points are drawn without replacement from the cube, which Lemma D0.2 covers (remark after it).
- **The "weight-free" columns.**
  - *Rank.* The rank is $\lfloor\kappa(\tau/\Theta)^2\rfloor$ from D6(2), with $\tau_J$ of D6(5) for GD. The D7 bound uses $\max(N_{\rm measured},\lfloor\kappa(\tau/\Theta)^2\rfloor)$. For the GD rows that is the weight-free value: at every printed checkpoint the measured rank is below it, as D6(5) guarantees under its step-size condition, which holds (*Step size* below).
  - *Norm.* $B$ is the dyadic round-up of the proved GD bound of D6(5), $\exp(4\eta^2\sum_j\|M_j\|_{op}^2)\big(P(0)+\eta\sum_j\|y\|_n^2\big)$. `D_quad_check.py` itself uses the flow bound $P(0)+t\|y\|_n^2$ of D6(4); the referee's replay recomputed the column with the proved GD bound. At the end of the runs this changes only MAJ of pairs, from $0.962$ to $0.969$ at $t=30$. For $x_1x_2$ at $n=3000$ the certificate stays $0.213$ at $t=17$–$20$ (at $t=14$ it moves from $0.201$ to $0.213$). So the $x_1x_2$ number is a proved weight-free certificate for GD.
  - *Step size.* The step-size condition $2\eta\|M_j\|_{op}<1$ of D6(5) holds along every replayed run: $\max_j2\eta\|M_j\|_{op}=0.011$–$0.021$ for GD and $0.030$ for SGD. Its weight-free sufficient form $2\eta\sqrt{\kappa_{B_j}}\|r_j\|_{B_j}<1$ also holds, with maximum $0.034$–$0.077$. The real-valued two-stage run was not replayed.
  - *SGD row.* The weight-free $N$ uses the full-batch $\kappa$ form, which is not claimed for SGD. That row's D7 number uses this $N$ and the flow $B$. It is still a valid certificate, because $N\ge N_{\rm measured}$ and $B\ge P$ by construction, but it is neither a priori nor weight-free. With the proved SGD forms of D6(5) instead, the rank bound is $N\le181$ at $t=30$, above the trivial $32$, and the D7 bound with $N$ capped at $32$ and the proved norm bound is $0.89$–$0.90$ from $t=17$ on.
  - *SGD first growth.* The bound is the SGD form of item 3 in D6(5), with maxima over the steps before the first growth: $\Theta_\epsilon/(\max_j\|M^{B_j}_y\|_{op}+2\max_j\kappa_{B_j}\sqrt d\,\epsilon)=5.42/(1.475+2\cdot14.92\cdot4\cdot0.01)=2.03$. The full-batch value $6.96$ is not proved for SGD.

| target, $n$ | $\kappa$ | D5 clock: worst excess | D6(2): worst $N/\kappa(\tau/\Theta)^2$ | first growth at $\epsilon=0.01$: observed / D6(3) bound | rank $N$ at end, measured / weight-free | D7 bound: measured $N$ / weight-free $N$ with proved GD $B$ / unrestricted | test error |
|---|---|---|---|---|---|---|---|
| $x_1x_2$, 300 | 5.01 | $3\cdot10^{-8}$ | 0.38 | 5.62 / 3.73 | 2 / 8 | 0.605 / 0.992 / 0.960 | 0 |
| $x_1x_2$, 3000 | 2.85 | $3\cdot10^{-8}$ | 0.59 | 5.76 / 4.39 | 2 / 4 | **0.084** / **0.213** / 0.276 | 0 |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$, 3000 | 2.85 | $1\cdot10^{-8}$ | 0.39 | 10.59 / 6.96 | 6 / 47 | 0.270 / 0.969 / 0.276 | 0 |
| same, SGD batch 64 | 2.85 | $6\cdot10^{-8}$ | (not claimed) | 10.51 / 2.03 (minibatch form) | 6 / 47 (full-batch form, not claimed) | 0.277 / 0.963 (full-batch $N$, flow $B$; not weight-free) / 0.276 | 0 |
| $x_1x_2+\frac12x_3x_4$, 1000 | 3.55 | $9\cdot10^{-8}$ | 0.41 | 5.70 / 4.20 | 4 (two stages) / — | (real-valued; test MSE $\to0$) | — |

**Reading.**
- **Exactness and tightness.** The clock inequality is exact to SVD round-off. It is checked only up to the numerically resolved rank, because singular values below $10^{-9}\sigma_1$ are round-off. The rank bound is within a factor 1.7–2.7 of the truth.
  - The referee traced the $+2.8\cdot10^{-8}$ excess of the $x_1x_2$, $n=300$ run to $K=d=h=16$ ([`checks/referee_D_r1.out`](checks/referee_D_r1.out), R9). There D5(2) holds with equality, $\ln|\det U_J|=\ln|\det U_0|+\sum_j\ln\det(I+2\eta M_j)$. For every $K\le15$ the excess is $\le0$ at all times.
  - The other runs were not traced.
- **The two-stage target.** The rank grows in two stages, $2\to4$, at the times of the two utility eigenvalues.
- **$x_1x_2$.** At $n=3000$ the generalization bound is $0.21$ with the weight-free rank and the proved GD norm bound of D6(5). That is better than the unrestricted degree-2 class ($0.28$), and the measured rank gives $0.084$. The time-only rank bound $\kappa(R_0t/\Theta)^2$ would give $N\le42$ at $t=20$, and a vacuous D7 bound.
- **MAJ of three pairs.**
  - The residual stays at $\sqrt{2\cdot0.121}$ after the fit, because MAJ has a degree-6 part.
  - So $\tau$ keeps growing, the weight-free rank bound loosens from 23 to 47 between $t=17$ and $t=30$, and the corresponding D7 bound becomes vacuous. From $t=25$ on (37, then 47) it is worse than the trivial bound $\min(d,h)+\min(d,h')=32$. The measured-rank bound is slightly better than the unrestricted one ($0.270$ against $0.276$).
  - This is the weakness of any "effective time" bound on a plateau with nonzero residual. A bound that counts *escapes* instead of time would avoid it.
- **SGD.** The SGD run satisfies the clock form (item 1) with large slack (worst $N\Theta-\int\text{KyFan}=-6.4$), as expected from the positive bias of minibatch Ky Fan sums.

---

## 8. What this does and does not give

**Against the target statement of the task** (for $t\le(1+c)\log(1/\alpha)/U^*$, the network is near $\sum_{k\le K}c_k\,\mathrm{relu}(v_k\cdot x)$ with $v_k$ near critical directions and $K$ controlled, giving a generalization bound uniform in $t$):

| piece | two-layer ReLU (Part I) | two-layer quadratic with fixed output signs, i.e. symmetric matrix sensing (Part II) |
|---|---|---|
| no growth before $\approx\log(1/\alpha)/U^*$ | Proved (D2(3)); its leading constant is sharp: $\liminf_{\alpha\to0}t_\beta U_0^*/\ln(1/\alpha)\ge1$ for every flow, with equality in an explicit instance (D2(6)) | Proved (D6(3)) |
| race clock is exact | Proved (D1(b), (d)) | Proved, spectral clock (D5, D6(1)) |
| directions near critical points of the utility | Proved in a time-averaged sense (D2.2) | automatic: growth is along eigenvectors of $M_r$ |
| circuit size controlled by time, for all $t$ | only through the variation norm, linear in $t-T_\beta$ (D3); $K$ itself is not controlled a priori | **Proved** in weight-free form, with $\tau$ from the loss curve: $N_\epsilon\le\kappa(\tau/\Theta_\epsilon)^2$ (D6). The time-only form, via $\tau\le R_0t$, is much weaker |
| generalization uniform in $t$ with that size | Proved, width-free, but vacuous at $n\le4000$ (D3.2); non-vacuous a posteriori with the network's clusters (D3.3) | **Proved** (D7). Non-vacuous at $n=3000$ for $x_1x_2$ with the weight-free rank bound and the proved GD norm bound of D6(5) (§7.4) |
| persistence through the plateau, $t\le(1+c)T_1$ | conditional on the attracting-sign condition along the run (D4.1); a priori form is Conjecture D4 | not needed: D6 holds at all times |

**Relation to the race model ([A](A-discrete-model.md)).**
- **The clock.** Lemma D1(b) is A's clock, exactly, in the real network: a neuron's log-mass is twice its integrated utility, and it fires when that reaches $\ln(1/\alpha)$. The search phase is A's direction alignment, exactly (D1(d)), and does not depend on scale.
- **Correlated firing.** In the network, many correlated units firing at once (A's Proposition A2.2, which was the reason training time does not bound the raw gate count) merge into one cluster (D1(g)). The circuit size that matters is the number of clusters, not the number of neurons that fired.
- **No dormant reservoir.** The race assumes a dormant reservoir for later moves; §4 shows that the ReLU network can exhaust it at the first escape.
- **Part II as a race.** Part II is a race whose "library" is the eigenvectors of the utility matrix $M_r$. A2.3's size bound $T\le\kappa(\tau/\Theta)^2$ is proved there for the network itself, in the fixed-output-sign model.

**Relation to C3's conditional theorem.** Theorem C3.4 assumes SSA: closeness of the network to the race's predictor at calibrated times.
- **What Part I supplies.**
  - SSA a priori up to $T_\beta$, in its trivial form (the empty circuit, within $\frac{\sqrt{d+1}}2\beta$ in sup norm).
  - Through the escape, a weaker variation-norm version of it (D3, D3.1).
  - After the escape, a trajectory-checkable persistence statement (D4.1).
- **What Part I does not supply.** It does not prove SSA after the first escape. The README's "missing link" for ReLU networks is therefore still missing, but it is now localized: the missing piece is the attracting-sign condition (A), equivalently a sliding-mode stability statement for clusters sitting on data hyperplanes, plus the existence of a dormant reservoir.
- **For the quadratic model of Part II** the link is supplied in weight-free form. That model has fixed output weights $\pm1$ and centred units, so it is symmetric matrix sensing, not a fully trained network.
  - Theorem D7 with D6(2) is an unconditional analogue of C3.4, with the race replaced by the network's own spectral clock.
  - Its size term uses $\tau$ from the training-loss curve. The time-only form, via $\tau\le R_0t$, is much weaker, and on plateaus with nonzero residual both forms degrade (§7.4).

**What fails, concretely.**
1. **ReLU a priori bounds after the escape** grow with $t-T_\beta$. They are $O(c\log(1/\alpha))$ at $(1+c)T_1$, so they get the size wrong by a $\log(1/\alpha)$ factor on long plateaus. The loss-curve form is right, but it uses the observed training loss.
2. **The ReLU generalization bound that is a priori** (D3.2) goes through Maurey's lemma and the variation norm. It is vacuous below $n\approx10^5$ at $d=16$. The non-vacuous one (D3.3) uses the observed clusters.
3. **Effective time on non-vanishing plateaus.** In both parts, $\tau=\int\|r\|_n$ keeps growing while nothing grows, if the residual plateaus above zero. Bounds in units of $\tau/\Theta$ then degrade with plateau length (MAJ of pairs in §7.4; maj5 in C2.5).
4. **SGD.** The spectral clock holds for SGD with minibatch matrices, but cannot use the cancellation of minibatch noise, because the product of non-commuting factors is bounded by the product of their norms. The diagonal case (C2.6) does use it.
5. **The setting.** Nothing here covers the study's μP Adam networks (two hidden layers, $O(1)$ initialization, per-layer multipliers). Part I needs one hidden layer, balanced small initialization and gradient flow. Part II needs fixed $\pm1$ output weights.

## Files

| file | contents |
|---|---|
| [`checks/D_relu_check.py`](checks/D_relu_check.py) → [`checks/D_relu_check.out`](checks/D_relu_check.out) | Part I checks: Lemma D1 (a), (e), (f), (g); Lemma D2.1; Theorem D2; Proposition D2.2; Theorem D3; Theorem D3.2; Proposition D3.3; plateau diagnostics for §4 (≈10 min; `python3 D_relu_check.py 0,1` runs a subset) |
| [`checks/D_quad_check.py`](checks/D_quad_check.py) → [`checks/D_quad_check.out`](checks/D_quad_check.out) | Part II checks: Theorem D5 (Horn and linearized clocks), Theorem D6 (1)–(3), Theorem D7 against the unrestricted class (≈15 s) |
| [`checks/referee_D_r1.json`](checks/referee_D_r1.json), [`checks/referee_D_r1.py`](checks/referee_D_r1.py) → [`checks/referee_D_r1.out`](checks/referee_D_r1.out) | round-1 referee report and the referee's independent checks (≈20 s); cited above as R4, R8, R9, R11 |
| [`checks/referee_D_r2.json`](checks/referee_D_r2.json), [`checks/referee_D_r2.py`](checks/referee_D_r2.py) → [`checks/referee_D_r2.out`](checks/referee_D_r2.out) | round-2 referee report and checks (≈25 s): S1 the D2(6) instance and the monotone form of the escape-time bound, S2 the D6(5) path norm, S3 the §7.4 replay with the proved GD/SGD forms of D6(5), S4 the D7 comparison and D3.3 capacities |

Both import `klinv_upper` and `log_Phi` from [`checks/c_common.py`](checks/c_common.py). Set `OPENBLAS_NUM_THREADS=1`.

**Labels in the check outputs.** `D_relu_check.py` and its `.out` use an older theorem numbering. D0 = Lemma D1 (a), (b), (e), (f), and D0(f), D0(g) = Lemma D1(f), (g); Lemma D1.1 = Lemma D2.1; D1(1), D1(3) = Theorem D2(1), (3); D1.3 = Proposition D2.2; D2 = Theorem D3; D2.2 (Maurey/Occam) = Theorem D3.2; D2.3 ($K$-neuron Occam) = Proposition D3.3; D3 diagnostics and Conjecture D3 = §4 and Conjecture D4. In `D_quad_check.py` and its `.out`, DQ1 = Theorem D5, DQ2 = Theorem D6(1)–(3), DQ3 = Theorem D7, and the "a-priori" columns ("apriori N") are what this file calls weight-free. The numbers are unaffected; the `.out` files are left as they were run.

## References

**Two-layer ReLU networks from small initialization**
- Maennel, Bousquet, Gelly. *Gradient descent quantizes ReLU network features.* arXiv:1803.08367, 2018. Abstract checked: with small initialization and step size, weight vectors concentrate on finitely many data-determined directions, independently of width. The term "extremal vectors" for these directions is from memory.
- Boursier, Pillaud-Vivien, Flammarion. *Gradient flow dynamics of shallow ReLU networks for square loss and orthogonal inputs.* NeurIPS 2022 (abstract checked in C).
- Boursier, Flammarion. *Early alignment in two-layer networks training is a two-edged sword.* JMLR 26(183):1–75, 2025; arXiv:2401.10791. Venue and abstract checked: a quantitative early alignment phase leading to sparse representations. The failure example is from memory.
- Kumar, Haupt. *Directional convergence near small initializations and saddles in two-homogeneous neural networks.* TMLR 2024; arXiv:2402.09226. Abstract checked: directional convergence to KKT points of the neural correlation function near the origin, and near certain saddles for square loss.
- Kumar, Haupt. *Early directional convergence in deep homogeneous neural networks for small initializations.* arXiv:2403.08121 (TMLR 2025, per C).
- Kumar, Haupt. *Learning neural networks by neuron pursuit.* arXiv:2509.12154, 2025 (from memory; an algorithm, not a theorem about GD).
- Kunin, Marchetti, Chen, Karkada, Simon, DeWeese, Ganguli, Miolane. *Alternating Gradient Flows: a theory of feature learning in two-layer neural networks.* NeurIPS 2025; arXiv:2506.06489 (abstract checked in C).
- Lyu, Li, Wang, Arora. *Gradient descent on two-layer nets: margin maximization and simplicity bias.* NeurIPS 2021 (from memory: two-layer leaky ReLU, linearly separable symmetric data, small initialization; GF first learns a linear classifier).
- Chistikov, Englert, Lazić. *Learning a neuron by a shallow ReLU network: dynamics and implicit bias for correlated inputs.* NeurIPS 2023; arXiv:2306.06479. Abstract checked: non-asymptotic per-neuron analysis from small initialization, convergence to zero loss with a bias toward low parameter rank; minimal-rank and minimal-norm interpolators differ.
- Chizat, Bach. *On the global convergence of gradient descent for over-parameterized models using optimal transport.* NeurIPS 2018 (from memory; the conic-particle view of Lemma D1(c)).
- Du, Hu, Lee. *Algorithmic regularization in learning deep homogeneous models: layers are automatically balanced.* NeurIPS 2018 (from memory; Lemma D1(a), and the matrix form $W_1W_1^\top-W_2^\top W_2$ for linear layers behind D1(g1)).
- Arora, Cohen, Hazan. *On the optimization of deep networks: implicit acceleration by overparameterization.* ICML 2018, PMLR 80:244–253 (venue checked; the balancedness invariant of linear networks, behind D1(g1), from memory).
- Marcotte, Gribonval, Peyré. *Abide by the law and follow the flow: conservation laws for gradient flows.* NeurIPS 2023; arXiv:2307.00144 (venue and abstract checked: conservation laws of gradient flows, with ReLU networks as the main example, where only a subset of the linear-network balancedness laws survives).

**Matrix sensing and quadratic networks**
- Stöger, Soltanolkotabi. *Small random initialization is akin to spectral learning: optimization and generalization guarantees for overparameterized low-rank matrix reconstruction.* NeurIPS 2021; arXiv:2106.15013 (abstract checked).
- Li, Luo, Lyu. *Towards resolving the implicit bias of gradient descent for matrix factorization: greedy low-rank learning.* ICLR 2021; arXiv:2012.09839.
- Jin, Li, Lyu, Du, Lee. *Understanding incremental learning of gradient descent: a fine-grained analysis of matrix sensing.* ICML 2023, PMLR 202:15200–15238 (abstract checked: small initialization learns solutions of increasing rank, covering the whole process, under RIP-type assumptions).
- Gunasekar, Woodworth, Bhojanapalli, Neyshabur, Srebro. *Implicit regularization in matrix factorization.* NeurIPS 2017 (from memory).

**Tools**
- Clarke. *Optimization and Nonsmooth Analysis.* Wiley 1983 (from memory; only for the remark that Clarke flows are selection flows).
- Aubin, Frankowska. *Set-Valued Analysis.* Birkhäuser 1990, §8.2 (from memory; Filippov's measurable-selection lemma, for the remark that selections can be taken measurable).
- Hoeffding. *Probability inequalities for sums of bounded random variables.* JASA 58 (1963), Theorem 4 (from memory; sampling without replacement is dominated in convex order by sampling with replacement).
- Ky Fan. *On a theorem of Weyl concerning eigenvalues of linear transformations I.* PNAS 35 (1949) (from memory; the maximum principle, re-derived here from interlacing).
- Horn. *On the singular values of a product of completely continuous operators.* PNAS 36 (1950) (from memory; the case used is re-proved in Theorem D5(2)).
- Pisier. *Remarques sur un résultat non publié de B. Maurey.* Séminaire d'Analyse Fonctionnelle 1980–81; Barron. *Universal approximation bounds for superpositions of a sigmoidal function.* IEEE Trans. Inf. Theory 39 (1993) (from memory; Maurey's lemma, re-proved in Corollary D3.1).
- Bach. *Breaking the curse of dimensionality with convex neural networks.* JMLR 18 (2017) (from memory; variation norm).

## Revision notes

This revision answers the round-1 referee report ([`checks/referee_D_r1.json`](checks/referee_D_r1.json)). Its verdict was "pass", with 14 issues, all minor. The items below follow the order of the report.
- **No check script was rerun.** None of the fixes changes a number that `D_relu_check.py` or `D_quad_check.py` computes.
- **New numbers.** The few new numbers come from three places: the referee's script output ([`checks/referee_D_r1.out`](checks/referee_D_r1.out)), closed-form computation, or a short unsaved computation with `c_common.log_Phi`. Each agrees with the referee's values.

1. **Sharp constant in Theorem D2.** The sharpness is now proved for one explicit instance, as the referee suggested, so the claim stays Proved.
   - *New item.* Theorem D2(6) takes $y=x_1$ on the full cube and one balanced neuron started at $v^*=(e_1+e_0)/\sqrt2$, with selection $s=0$ on the kink $\{x_1=-1\}$. It shows in closed form that this is a selection flow with $\hat w=v^*$ and logistic $P(t)$. It gives $t_\beta=\ln(\beta/P(0))/(2U_0^*)+\frac1{\sqrt2}\ln\frac{\sqrt2-P(0)}{\sqrt2-\beta}$, with $U_0^*=1/\sqrt2$ and $\lambda_X=1$. So $t_\beta/(\ln(1/\alpha)/U_0^*)\to1$.
   - *Where the claim is restated.* The status table, the §8 table, the Summary and the Reading after D2 now say only that the *leading constant* is attained in this instance. The Reading says the $\beta$-factor and the $\ln m$ term are not claimed sharp, and that the instance uses one particular selection.
   - *§5 wording.* §5's "Theorem D2 is sharp in the exponent" (a numerical observation) now says "tight in the exponent in these runs".
2. **Summary item 1, "angle shrinks like 1/mass".** It now says that $1-\cos$, about half the squared angle, shrinks like $1/\text{mass}$, so the angle shrinks like $\text{mass}^{-1/2}$.
3. **Merging law, novelty.** "New here" is removed. Summary item 1 and a new *Credit* paragraph in Lemma D1(g) say four things:
   - (g1) is the off-diagonal entry of the classical conservation law $W_1W_1^\top-W_2^\top W_2=\text{const}$ of two-layer linear networks (Arora–Cohen–Hazan 2018; Du–Hu–Lee 2018);
   - it applies to a pair of neurons that share their selections, because such a pair is locally a linear network;
   - for ReLU networks only the diagonal (Lemma D1(a)) is conserved globally (Marcotte–Gribonval–Peyré 2023);
   - novelty is claimed only, and tentatively, for (g2)–(g3).

   The Lorentz remark points to the credit paragraph. Arora–Cohen–Hazan and Marcotte et al. are added to the references, and the Du–Hu–Lee entry is extended.
4. **Theorem D7, nesting and $\gamma$.** The false claim that the classes are nested in $N$ is removed. Proof step 2 now fixes any $N\ge N_\epsilon(t)$, pads $X_b$ with zero eigenvalues to $N$ terms, and rounds in the grid of $\mathcal G_{N,B,\gamma}$ itself, so the error bound $N\eta_\lambda/2=\gamma/(16(d-1))$ holds for that $N$ directly. Step 4 explains why nesting is not needed and why it fails. The margin grid is now required to satisfy $\Gamma\subset(0,8(d-1)]$, which gives $N\eta_\lambda\le1$ and is automatic for $\gamma\le1$.
5. **D7 Comparison.** The paragraph now quotes Cover's count $\ln\Phi(2^{17},121)\approx964$ nats, the value the script uses, and gives the cruder $1426$ for reference. The rank-$N$ class costs $127$–$129$ nats per unit at $d=16$, $B=1$, $\gamma=\frac12$. With the prior terms the rank bound wins for $N\le7$ (break-even $N\approx7$–$8$, not $11$), consistent with the §7.4 MAJ-of-pairs row. Summary item 8 is changed to match.
6. **GD/SGD admissibility of $B$.**
   - *New bound.* Theorem D6(5) now contains a proved path-norm bound for GD and SGD, $P_J\le\exp(4\eta^2\sum_j\|M_j\|_{op}^2)\,(P(0)+\eta\sum_j\|y\|_{B_j}^2)$, together with its weight-free form via $\|M_j\|_{op}\le\sqrt{\kappa_{B_j}}\|r_j\|_{B_j}$. The proof is a one-step expansion. The text notes that the flow bound can fail for GD (referee R8).
   - *D7.* D7 now states that it holds for every $(U,V)$, hence for every GD or SGD iterate. Its "Admissible choices" separate the flow's a priori $B$, the GD/SGD bound and the measured $P$.
   - *§7.4.* A new "weight-free columns" note says that the $B$ used there is the flow bound. For the GD runs it is admissible only because it exceeds the measured $P$ ($\le1.51$ against $B=8$–$32$), and the GD factor was not evaluated. The SGD row's number is marked "not weight-free": its rank uses the full-batch $\kappa$ form. It remains a valid certificate, because the script uses $\max(N_{\rm measured},N_{\rm wf})$ and $B\ge P$.
   - *Summary.* Item 9 is changed to match.
7. **Overclaims in prose.**
   - *(i) "Real network".* Wherever Part II was called a real network, the text now says that it has fixed $\pm1$ output weights and centred units, i.e. that it is symmetric matrix sensing, and that trainable output weights (3-homogeneous dynamics) are not covered. The places changed are the opening scope list, the Part II heading of the Summary, Summary item 7, §6 (new "Fixed output layer" bullet), the Reading after D6, the §8 table header, §8's "For quadratic networks" paragraph (no longer "the link is no longer missing") and "Part II as a race".
   - *(ii) "A priori".* The $\tau$-based rank bound is now called *weight-free* (it uses the loss curve) instead of a priori. This applies in Summary items 7–9, the D7 admissible choices, the §7.4 table headers and Reading, and the §8 table. The time-only version $\tau\le R_0t$ (flow) is stated for comparison, in Summary item 7, the Reading after D6, D7 and §7.4. For $x_1x_2$ at $t=20$, $\gamma=\frac12$ it gives $N\le42$, against $4$, matching the referee's figure.
8. **Measurability.** The selection-flow definition now requires Lebesgue-measurable selections. A new bullet explains why this loses nothing: Filippov's measurable-selection lemma (reference added) applies, because the admissible selections form a compact, measurably varying set. It also notes that on sliding sets the flow determines $\xi_j$ but not $\xi^y_j$. Proposition D2.2's proof notes that the integrand is measurable for this reason, and the proposition is stated for every measurable selection realizing the flow.
9. **Proposition D4.1, "(A) fails" variant.** The proof now contains the last-zero argument.
   - If $Q$ has no zero on $[t_1,t]$, $\sqrt Q$ is absolutely continuous.
   - Otherwise, with $t_*$ the last zero (called $s_0$ until round 2), $\sqrt Q$ is absolutely continuous on each $[t_*+\delta,t]$, and letting $\delta\to0$ gives $\sqrt{Q(t)}\le\int_{t_*}^tc\le\sqrt{Q(t_1)}+\int_{t_1}^tc$.
   - The (A)-holds case now says explicitly that $Q$ is absolutely continuous with $\dot Q\le0$ almost everywhere.
10. **Statement slips.**
    - (a) Theorem D2(3) now reads $L(t)\ge\frac12(\|y\|_n-\frac{\sqrt{\lambda_X}}2\beta)_+^2$, and the proof squares only nonnegative quantities.
    - (b) Lemma D1(c) now reads $\|\mu_t\|_{TV}\le P(t)/2$, with equality unless atoms of opposite sign coincide. Summary item 1 ("variation norm at most $P/2$") and the remark after Theorem D3 ($P\ge2\|\mu\|_{TV}$) are changed to match.
    - (c) Theorem D3.2 is restated for every two-layer ReLU network, balanced or not, with any dyadic $B\ge\sum_j|a_j|\|w_j\|$ ($\le P/2$, with equality under balance). Its proof now uses the weights $|a_j|\|w_j\|$ and signs $\mathrm{sgn}\,a_j$. Proposition D3.3's "For the network" paragraph is restated the same way. Under balance both reduce to the old forms. This strengthens, rather than weakens, the results; the status table and Summary item 3 note it.
11. **Numerical certificates.**
    - (i) A new remark after Lemma D0.2 handles sampling without replacement, which both scripts use. By Hoeffding (1963, Theorem 4) the moment-generating function without replacement is at most the one with replacement, and that is the only property the kl-Chernoff proof uses. So Lemma D0.2 holds verbatim, with the population (uniform cube) frequency. §0, §5 and §7.4 point to the remark, and Hoeffding is added to the references.
    - (ii) A new §5 bullet says that `D_relu_check.py` certifies the balanced surrogate $\tilde f$, not the GD network. It gives the exact difference $f-\tilde f=-\sum_j\epsilon_j\frac{(|a_j|-\|w_j\|)^2}2\sigma(\hat w_j\cdot\tilde x)$, which is second order in the balance drift. It quotes the referee's recomputation for MAJ$_3$, $n=1000$, $\alpha=10^{-3}$, with the GD network as the predictor in D3.3: a difference of $3.6\cdot10^{-7}$ and $1.1\cdot10^{-6}$, with the certificate $0.190$ and test error $0$ unchanged. It says that the other rows are certificates of the surrogate. Summary item 5 mentions this.
12. **Numerical prose**, now matching `D_relu_check.out`.
    - (a) The points near a grown hyperplane are 91–502 of the training points at $n=1000$, and 1517 at $n=4000$ (§4).
    - (b) The $n=4000$ run recruits 63 of 64 neurons; one stops at mass $9.2\cdot10^{-4}$ (Summary item 5, §4).
    - (c) The median $Q_{jk}$ at $\alpha=10^{-3}$ falls from $9.9\cdot10^{-7}$ to $1.3\cdot10^{-7}$ for $x_1$ (under one order of magnitude), and by 2.7–4 orders for MAJ$_3$ (Conjecture D4 evidence).
    - (d) At $\alpha=10^{-6}$ it rises to $1.8$–$3.8\cdot10^{-9}$.
    - (e) Training-set margins are $10^{-12}$–$3\cdot10^{-7}$ (Summary item 5, §4).
    - *Also corrected.* The interval length is $0.04$ in the $\eta=0.004$ run, and the intervals counted are those on which (A) holds and the pair does not keep one activation pattern.
13. **Part II relative to C2.** "Strictly more than C2: C2 is the special case in which all the measurement matrices commute" and "Item 2 then reduces to C2.3(2)" are replaced. The Summary's Part II heading and the Reading after D6 now say that C2's network is the case of diagonal $A_i$ *with diagonal initialization*: commuting $A_i$ alone is not enough. For that case D6(2) implies a slightly weaker form of C2.3(2), for three reasons:
    - $N_\epsilon$ counts eigenvalues of $UU^\top$ and $VV^\top$ separately, an upper bound on C2's count;
    - $\Theta_\epsilon=\frac14\ln(\epsilon/\alpha^2)$ is at most C2's $\frac14\operatorname{arsinh}(\epsilon/2\alpha^2)$;
    - $\kappa$ is global rather than $\kappa_B$.

    In §6, the bias-refitted plain network no longer gets "Theorems D5–D6 apply verbatim". D6(3) there needs $U_0^*=\|M_{y-\bar y}\|_{op}$, with the one-line reason given; the other items apply as stated.
14. **Step-size condition for the discrete clock.** Summary item 6 now states that the discrete log-det clock needs $I+\eta A_j\succ0$, i.e. $2\eta\|M_j\|_{op}<1$, for GD and SGD alike. Theorem D6(5) now states the condition for both GD and SGD. It also says that the condition is not needed for the path-norm bound.

**Also changed.**
- §7.4's Reading records the referee's R9 finding: the $+2.8\cdot10^{-8}$ clock excess of the $x_1x_2$, $n=300$ run occurs only at $K=d=h$, where D5(2) is an exact determinant identity, and the excess is $\le0$ for $K\le15$. The other runs were not traced.
- §7.4's MAJ-of-pairs reading now says that the measured-rank bound is slightly better than the unrestricted one ($0.270$ against $0.276$), not that it "matches" it.
- §8, "What fails" item 5, adds that Part II needs fixed output weights.
- The Files table lists the referee's report, script and output, which the text now cites.

Not changed: the referee found every other result labelled Proved correct, with its constants, and found that the tables in §5 and §7.4 reproduce.

**Round-2 referee** ([`checks/referee_D_r2.json`](checks/referee_D_r2.json), checks in [`checks/referee_D_r2.py`](checks/referee_D_r2.py) → [`checks/referee_D_r2.out`](checks/referee_D_r2.out)). The verdict on the revised version was "pass": every result labelled Proved is correct as stated, and every round-1 issue is fixed. The report lists 7 new issues, all minor and none affecting a Proved statement. These minor fixes are now applied, in the order of the report. No check script was rerun; every new number is taken from `referee_D_r2.out`.
1. **Leading constant.** Theorem D2(6) now gives the one-line monotonicity argument: for $\beta'\in(P(0),\beta]$, $t_\beta\ge t_{\beta'}\ge T_{\beta'}$, so $\liminf_{\alpha\to0}t_\beta U_0^*/\ln(1/\alpha)\ge1$ for every flow at every fixed $\beta$ and $m$, with equality in the instance. The Summary, the status table, the Reading after D2 and the §8 table now state this, and the sentence saying the $\beta$-factor is not claimed sharp is gone.
2. **Lemma D0.3** is stated for every $\eta>0$, as Proposition D3.3 needs at small dyadic $B$. The proof is unchanged.
3. **Width in Part II.** §6, Summary item 7 and the Reading after D6 say that the rank bound depends on the width through $s_0$ in $\Theta_\epsilon$ (and $P(0)$ through D6(4)–(5)). The Reading after D6, D7's admissible choices and §7.4 note the trivial bound $N_\epsilon\le\min(d,h)+\min(d,h')=32$, which beats the weight-free bound late in the MAJ-of-pairs run (37 and 47 at $t=25$, $30$).
4. **§7.4 and D6(5).**
   - The weight-free D7 column now uses the proved GD norm bound of D6(5), with the referee's recomputed numbers: $0.213$ for $x_1x_2$ at $n=3000$ (unchanged at the end), and $0.969$ instead of $0.962$ for MAJ of pairs. The caveat that this $B$ is not proved for GD is removed.
   - The step-size check is reported: $\max_j2\eta\|M_j\|_{op}=0.011$–$0.030$ over the replayed runs.
   - The SGD row's first-growth bound is now the minibatch form, $2.03$ instead of the full-batch $6.96$.
   - D6(5) now lists item 3 for GD and its minibatch form for SGD, with a two-line proof. This minibatch form was added after the round-2 referee pass and has not itself been refereed.
   - Summary item 9 and the §8 table are changed to match.
5. **Title and README.** The title no longer says "a priori", and the theory README's description of D no longer says "a-priori theorem for real networks". The stale sentences at the end of the round-1 notes, saying that the README was not updated and that the revision was not re-refereed, are deleted, and the header is updated.
6. **Check-output labels.** The Files section maps the older labels of `D_relu_check.out` and `D_quad_check.out` to the current numbers, e.g. D2.2 in `D_relu_check.out` = Theorem D3.2. §5 and §7.4 point to it. The `.out` files are not edited.
7. **Wording.** D6(3) now defines $t_\epsilon$ as the first time an eigenvalue reaches $\epsilon$. The last zero of $Q$ in the proof of D4.1 is renamed $t_*$, since $s_0$ is Part II's initial operator norm. Summary item 4 says that D4.1's distance uses $Q$ at one checkpoint and the current norms, and that the dormant term uses $\int\hat U(r_s)\,ds$ along the run. The D3.3 remark gives the computed $202$ and $6693$ nats in place of "about 200" and "about 6500".
