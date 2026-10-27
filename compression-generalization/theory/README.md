# Theory: from compressing a trained network to bounding its error

Notation. $D$ is a distribution on $\mathcal X\times\mathcal Y$ with input marginal $D_X$; the training sample is $S=((x_i,y_i))_{i\le m}\sim D^m$. For a predictor $h$, $\mathrm{err}(h)=\Pr_D[h(x)\ne y]$ and $k_S(h)=\#\{i:h(x_i)\ne y_i\}$. The trained network is $f=f_S$, an arbitrary function of $S$ (and of any other randomness used in training). A *code* is a countable set $\Sigma$ of descriptions with lengths $L:\Sigma\to[0,\infty)$ satisfying Kraft, $\sum_\sigma 2^{-L(\sigma)}\le1$, fixed before $S$ is seen; each $\sigma$ decodes to a predictor $g_\sigma$. Lengths are $-\log_2$ of products of conditional probabilities and need not be integers (`code/cgb/coding.py`).

Binomial tail inversion: $\overline{\mathrm{Bin}}(k,m,\alpha)=\sup\{p:\Pr[\mathrm{Bin}(m,p)\le k]\ge\alpha\}$ (`code/cgb/bounds.py`).

---

## 1. The Occam bound and the reduction

**Lemma 1 (Occam, exact binomial form).** With probability at least $1-\delta$ over $S$, simultaneously for all $\sigma\in\Sigma$,
$$\mathrm{err}(g_\sigma)\le\overline{\mathrm{Bin}}\big(k_S(g_\sigma),m,\delta2^{-L(\sigma)}\big)\le \mathrm{kl}^{-1}\Big(\tfrac{k_S(g_\sigma)}m,\ \tfrac{L(\sigma)\ln2+\ln(1/\delta)}m\Big).$$

*Proof.* For fixed $\sigma$, $k_S(g_\sigma)\sim\mathrm{Bin}(m,\mathrm{err}(g_\sigma))$, so the event $\mathrm{err}(g_\sigma)>\overline{\mathrm{Bin}}(k_S,m,\alpha)$ means $k_S$ lies in a lower tail of mass $<\alpha$; it has probability $\le\alpha=\delta2^{-L(\sigma)}$. A union bound over $\sigma$ and Kraft give the first inequality. The second is the Chernoff bound $\Pr[\mathrm{Bin}(m,p)\le qm]\le e^{-m\,\mathrm{kl}(q\|p)}$ for $q\le p$. $\square$

The choice of $\sigma$ may depend on $S$ in any way: the bound holds for all $\sigma$ at once.

**Theorem 2 (reduction to compression; the idea).** Let $f$ be any predictor (it may depend on $S$ arbitrarily) and let $\sigma=\sigma(S)$ be any description. Then
$$\mathrm{err}(f)\le\mathrm{err}(g_\sigma)+\Pr_{D_X}[f(x)\ne g_\sigma(x)].$$
If, after $\sigma$ is fixed, $N$ inputs $x'_1,\dots,x'_N$ are drawn i.i.d. from $D_X$ independently of everything else and $j$ of them have $f(x'_l)\ne g_\sigma(x'_l)$, then with probability at least $1-\delta_1-\delta_2$
$$\mathrm{err}(f)\le\overline{\mathrm{Bin}}\big(k_S(g_\sigma),m,\delta_12^{-L(\sigma)}\big)+\overline{\mathrm{Bin}}(j,N,\delta_2).$$

*Proof.* $\{f(x)\neq y\}\subseteq\{g(x)\ne y\}\cup\{f(x)\ne g(x)\}$. The first term is Lemma 1. Conditional on $S$ and $\sigma$, the $x'_l$ are i.i.d. from $D_X$ and $\mathbf 1[f(x'_l)\ne g_\sigma(x'_l)]$ are i.i.d. Bernoulli with mean $\Pr_{D_X}[f\ne g_\sigma]$; Clopper–Pearson gives the second term. $\square$

The disagreement term needs **inputs** from $D_X$ but no labels. Three ways to get them, used in the experiments:

* $D_X$ is known and can be sampled (Boolean tasks with uniform inputs): the $x'_l$ are free, $N$ can be $10^5$–$10^6$, and for $\mathcal X=\{\pm1\}^n$ with $n\le22$ the disagreement is computed exactly by enumeration (then the second term is exact and $\delta_2=0$).
* Unlabeled samples from $D_X$ (MNIST test images without their labels).
* No extra inputs at all: Theorems 4 and 5.

If several candidates $g$ are compared on the same $N$ inputs before choosing one, the second term needs a union bound ($\delta_2\to\delta_2/K$ for $K$ candidates); the experiments either choose $g$ on a separate pool or apply this union bound.

**Corollary 3 (distribution-free, by exact equivalence on a finite domain).** Let $\mathcal X$ be finite. If $g'$ is a description such that $g'(x)=f(x)$ for **all** $x\in\mathcal X$ (checked by enumeration), then for **every** distribution $D$, with probability $\ge1-\delta$, $\mathrm{err}_D(f)=\mathrm{err}_D(g')\le\overline{\mathrm{Bin}}(k_S(f),m,\delta2^{-L(g')})$. A short $g$ that disagrees with $f$ on a set $E$ is turned into such a $g'$ by appending $E$: $L(g')=L(g)+1+\log_2(|E|+1)+\ldots+\log_2\binom{|\mathcal X|}{|E|}$ (`distribution_free_bound` in `cgb/boolean.py`).

---

## 2. Bounds on the original network from training data alone

Theorem 2 needs inputs from $D_X$ because "$g$ is close to $f$ on most inputs" is a statement about $D_X$. The way around it: make the closeness certificate a function of the **short description only**, evaluate it at the training inputs, and let the same Occam bound transfer it.

**Theorem 4 (certified transfer).** Let each description $\sigma$ define a set $K_\sigma$ of predictors and a measurable certificate $\pi_\sigma:\mathcal X\times\mathcal Y\to\{0,1\}$ such that $\pi_\sigma(x,y)=1\Rightarrow h(x)=y$ for all $h\in K_\sigma$. With probability $\ge1-\delta$, simultaneously for all $\sigma$ and all $h\in K_\sigma$,
$$\mathrm{err}(h)\le\overline{\mathrm{Bin}}\big(\#\{i:\pi_\sigma(x_i,y_i)=0\},m,\delta2^{-L(\sigma)}\big).$$
In particular this bounds $\mathrm{err}(f)$ whenever $f\in K_{\sigma(S)}$, which is checked directly on the weights.

*Proof.* For $h\in K_\sigma$, $\{h(x)\ne y\}\subseteq\{\pi_\sigma(x,y)=0\}$, so $\mathrm{err}(h)\le\Pr_D[\pi_\sigma=0]$. Apply Lemma 1 to the $\{0,1\}$-valued losses $1-\pi_\sigma$ (Lemma 1 only uses that each description fixes a loss function). $\square$

Lemma 1 is the case $K_\sigma=\{g_\sigma\}$, $\pi_\sigma(x,y)=\mathbf 1[g_\sigma(x)=y]$. For networks, $K_\sigma$ is a set of weights around a quantized network (a box, or $\ell_2$ balls per unit and per input subspace) and $\pi_\sigma$ is computed by sound interval propagation (`cgb/certify.py`).

**Remark (why worst-case sets fail for dense networks).** If the residual $f-g$ is spread over $d$ coordinates, the worst case of $|\Delta w\cdot x|$ over a box or ball containing it (sets that are cheap to describe without knowing the residual's direction relative to $x$) exceeds its actual value by a factor of order $\sqrt d$: for a box of half-width $s/2$ it is $s\|x\|_1/2$, while a typical residual gives $s\|x\|_2/\sqrt{12}$. On a 784–100–10 MNIST network the measured ratio of certified radius to actual pre-activation error is 12–13 for every quantization step tried (`results/mnist/t3_worstcase_probe.txt`), so certifying 95% of training points needs steps of about 2% of the update's RMS, i.e. about 8 bits per first-layer coefficient ($6\times10^5$ bits), ten times more than $m=6\times10^4$. Theorem 5 removes the $\sqrt d$.

### Dithered compression

Let $\xi$ be **public** randomness drawn independently of $S$, of the test point, and of any auxiliary randomness $\zeta$ used to tune the encoder (in the code: generated from fresh OS entropy after training and tuning, and recorded; the PRNG is modelled as truly random). An encoder maps $(f,\xi)$ to a description $\sigma=\sigma_{S,\zeta}(f,\xi)$ (it may depend on $S$ and $\zeta$ arbitrarily, e.g. through step sizes), and each $(\sigma,\xi)$ defines a certificate $\pi_{\sigma,\xi}$.

**Theorem 5 (dithered transfer).** Suppose that for every fixed encoder (every value of $(S,\zeta)$), every network $f$ and every $(x,y)$ there is an event $\mathrm{Bad}_{x,y}(f,\xi)$ with $\Pr_\xi[\mathrm{Bad}_{x,y}]\le\eta$ such that
$$\pi_{\sigma(f,\xi),\xi}(x,y)=1\ \text{and not}\ \mathrm{Bad}_{x,y}(f,\xi)\ \Longrightarrow\ f(x)=y.$$
Then with probability $\ge1-\delta-\delta'$ over $(S,\zeta,\xi)$,
$$\mathrm{err}(f)\le\overline{\mathrm{Bin}}\big(\#\{i:\pi(x_i,y_i)=0\},m,\delta2^{-L(\sigma)}\big)+\eta/\delta'.$$

*Proof.* $\mathrm{err}(f)\le\Pr_D[\pi=0]+\Pr_D[\pi=1,f(x)\ne y]\le\Pr_D[\pi=0]+\Pr_D[\mathrm{Bad}_{x,y}]$. Conditional on $\xi$, $S$ is still i.i.d. from $D$ and $\{\pi_{\sigma,\xi}\}_\sigma$ is a fixed family, so Lemma 1 bounds the first term for all $\sigma$ simultaneously with probability $\ge1-\delta$. For the second, conditional on $(S,\zeta)$ (so $f$ and the encoder are fixed), Fubini gives $\mathbb E_\xi\Pr_D[\mathrm{Bad}]=\mathbb E_D\Pr_\xi[\mathrm{Bad}]\le\eta$ and Markov gives $\Pr_\xi[\Pr_D[\mathrm{Bad}]>\eta/\delta']\le\delta'$. $\square$

Hyperparameters chosen by looking at $\xi$ itself would need a union bound in the Markov step; the experiments choose them with an independent selection dither $\zeta$ and certify with a fresh $\xi$. Hyperparameters that change the certificate (steps, basis, $t_1,t_2$) must be in $\sigma$ or fixed in advance; the code charges 2 bits for the choice of $(t_1,t_2)$ among four pairs and 2 bits for the initialization scheme and reference.

**Lemma 6 (subtractive dither).** For $a\in\mathbb R$, $s>0$ and $U\sim\mathrm{Unif}[-\frac12,\frac12]$, the error $s(\mathrm{round}(a/s+U)-U)-a$ is uniform on $[-\frac s2,\frac s2]$ whatever $a$ is. Applied coordinatewise with independent $U$'s, the errors are independent, uniform on $[-\frac{s_k}2,\frac{s_k}2]$ for a coordinate with step $s_k$, and their joint law does not depend on $f$.

*Proof.* $a/s+U \bmod 1$ is uniform on $[0,1)$ for every $a$, and $\mathrm{round}(V)-V$ is a measure-preserving function of $V\bmod1$ onto $(-\frac12,\frac12]$. $\square$

The decoder knows $\xi$ and the integers $K=\mathrm{round}(a/s+\xi)$, so $g$ has description length $L(K)$, typically small when $s$ is large compared with $|a|$, while $g-f$ is pure noise of known law. This is what lets the certificate use typical rather than worst-case behaviour.

**Lemma 7 (certificate for one-hidden-layer networks).** Let $f(x)=V\,\mathrm{relu}(Wx+b)+c$ with $W=W_0+AB^\top$ ($W_0$ the initialization, $B$ an orthonormal basis, e.g. the 2-D DCT), $V\in\mathbb R^{C\times H}$. Let $g$ be obtained by subtractive dithering of $A$ (steps $s_{ik}\ge0$; step 0 means the coefficient is sent exactly, as for coefficients that are exactly zero), $b-b_0$ (step $s^b$), $V-V_0$ (step $s^V$) and $c-c_0$ (step $s^c$). Fix $(x,y)$, put $\hat x=B^\top x$,
$$v_i=\sum_k s_{ik}^2\hat x_k^2/12+(s^b)^2/12,\qquad \tau_i=t_1\sqrt{v_i},$$
and let $u'_i$ be $g$'s pre-activations. For each class $c\ne y$ put $D_i=|V'_{yi}-V'_{ci}|+s^V$ (primes: $g$'s weights), $w_i=1$ if $u'_i\ge2\tau_i$, $w_i=0$ if $u'_i\le-2\tau_i$, $w_i=2$ otherwise, and
$$\hat P_c=\sum_iw_iD_i^2v_i+\tfrac{(s^V)^2}{6}\sum_i\mathrm{relu}(u'_i+2\tau_i)^2+\tfrac{(s^c)^2}6,\qquad \hat B_c=\sum_{i:\,|u'_i|<2\tau_i}D_i\hat\beta_i,$$
$$\hat\beta_i=\min\Big(\tfrac{\sqrt{v_i}}2,\ \sqrt{2\pi v_i}\,\bar\Phi\big((|u'_i|-\tau_i)_+/\sqrt{v_i}\big)\Big).$$
Define $\pi_g(x,y)=1$ iff $z'_y-z'_c>t_2\sqrt{2\hat P_c}+\hat B_c$ for all $c\ne y$. Then the hypothesis of Theorem 5 holds with
$$\eta=2He^{-t_1^2/2}+2(C-1)e^{-t_2^2}.$$
(For a binary network with one logit and label $y\in\{0,1\}$: $D_i=|V'_i|+s^V/2$, the $V$- and $c$-terms carry $1/12$ instead of $1/6$, and $C-1=1$.)

*Proof.* Write $\epsilon,e,\Xi,\gamma$ for the (independent, uniform, centred) dither errors of $A,b,V,c$, $\nu_i=\sum_k\epsilon_{ik}\hat x_k+e_i$ for the pre-activation error, and $u_i$ for $f$'s pre-activations, so $u'_i=u_i+\nu_i$.

(a) A uniform variable on $[-a,a]$ has $\mathbb Ee^{\lambda U}=\sinh(\lambda a)/(\lambda a)\le e^{\lambda^2a^2/6}$, i.e. it is sub-Gaussian with variance proxy $a^2/3$ (its variance). Hence $\nu_i$ is symmetric and sub-Gaussian with proxy $v_i$, the $\nu_i$ are independent across $i$, and $G=\{|\nu_i|\le\tau_i\ \forall i\}$ has $\Pr[G^c]\le2He^{-t_1^2/2}$.

(b) Fix $c\ne y$ and let $d_i=V_{yi}-V_{ci}$ (f's weights), $\chi_i=\Xi_{yi}-\Xi_{ci}$. The margin error is
$$F=(z'_y-z'_c)-(z_y-z_c)=\sum_id_i\big(\mathrm{relu}(u_i+\nu_i)-\mathrm{relu}(u_i)\big)+\sum_i\chi_i\,\mathrm{relu}(u_i+\nu_i)+(\gamma_y-\gamma_c).$$
Replace $\nu_i$ by $\mathrm{clip}_{\tau_i}(\nu_i)$ throughout to get $\tilde F$; on $G$, $F=\tilde F$. Let $\varphi_i(t)=\mathrm{relu}(u_i+\mathrm{clip}_{\tau_i}(t))-\mathrm{relu}(u_i)$. If $u_i\ge\tau_i$ ("active"), $\varphi_i=\mathrm{clip}_{\tau_i}$; if $u_i\le-\tau_i$ ("inactive"), $\varphi_i\equiv0$; otherwise ("marginal") $\varphi_i$ is 1-Lipschitz.

(c) MGF. Conditional on $(\nu_i)$, $\sum_i\chi_i\,\mathrm{relu}(u_i+\mathrm{clip}(\nu_i))$ is a centred linear form in independent uniforms with proxy $\le\frac{(s^V)^2}6\sum_i\mathrm{relu}(u_i+\tau_i)^2$; $\gamma_y-\gamma_c$ has proxy $(s^c)^2/6$. For an active unit, $\mathrm{clip}(\nu_i)$ is symmetric and $|\mathrm{clip}(\nu_i)|\le|\nu_i|$, so $\mathbb Ee^{\lambda d_i\mathrm{clip}(\nu_i)}=\mathbb E\cosh(\lambda d_i\mathrm{clip}(\nu_i))\le\mathbb E\cosh(\lambda d_i\nu_i)\le e^{\lambda^2d_i^2v_i/2}$. For a marginal unit, if $X$ has proxy $v$ and $\varphi$ is 1-Lipschitz, then with $X'$ an independent copy, Jensen gives $\mathbb Ee^{\lambda(\varphi(X)-\mathbb E\varphi)}\le\mathbb Ee^{\lambda(\varphi(X)-\varphi(X'))}=\mathbb E\cosh(\lambda(\varphi(X)-\varphi(X')))\le\mathbb E\cosh(\lambda(X-X'))\le e^{\lambda^2\cdot2v/2}$, so proxy $2d_i^2v_i$. Multiplying the independent factors,
$$\mathbb Ee^{\lambda(\tilde F-\mathbb E\tilde F)}\le e^{\lambda^2P/2},\quad P=\sum_{\text{active}}d_i^2v_i+2\!\!\sum_{\text{marginal}}\!\!d_i^2v_i+\tfrac{(s^V)^2}6\sum_i\mathrm{relu}(u_i+\tau_i)^2+\tfrac{(s^c)^2}6,$$
and $\Pr[|\tilde F-\mathbb E\tilde F|\ge t_2\sqrt{2P}]\le2e^{-t_2^2}$.

(d) Bias. Only marginal units contribute: $\mathbb E\tilde F=\sum_{\text{marginal}}d_i\mathbb E\varphi_i(\nu_i)$, and for symmetric $c=\mathrm{clip}(\nu)$, $0\le\mathbb E\,\mathrm{relu}(u+c)-\mathrm{relu}(u)=\mathbb E(c-|u|)_+\le\min\big(\mathbb E c_+,\ \mathbb E(\nu-|u|)_+\big)$; $\mathbb Ec_+=\mathbb E|c|/2\le\sqrt{v}/2$ and $\mathbb E(\nu-|u|)_+=\int_{|u|}^\infty\Pr[\nu>t]\,dt\le\sqrt{2\pi v}\,\bar\Phi(|u|/\sqrt v)$.

(e) Computability. On $G$, $|u_i-u'_i|\le\tau_i$, so $u'_i\ge2\tau_i$ implies active, $u'_i\le-2\tau_i$ implies inactive, $|u_i|\ge(|u'_i|-\tau_i)_+$, and $\mathrm{relu}(u_i+\tau_i)\le\mathrm{relu}(u'_i+2\tau_i)$; always $|d_i|\le|V'_{yi}-V'_{ci}|+s^V$. Hence on $G$, $P\le\hat P_c$ and $|\mathbb E\tilde F|\le\hat B_c$.

(f) Let $\mathrm{Bad}=G^c\cup\bigcup_{c\ne y}\{|\tilde F_c-\mathbb E\tilde F_c|\ge t_2\sqrt{2P_c}\}$; $\Pr[\mathrm{Bad}]\le\eta$. Off $\mathrm{Bad}$, $|F_c|<t_2\sqrt{2\hat P_c}+\hat B_c$ for every $c$, so $\pi_g(x,y)=1$ forces $z_y-z_c>0$ for all $c\ne y$, i.e. $f(x)=y$. $\square$

The certificate depends on $(K,\text{steps},\xi)$ and $(x,y)$ only, as Theorem 5 requires. The experiments use $t_1=5.8$, $t_2=3.9$; with $H\le128$ and $C=10$, $\nu/\delta'\le2\times10^{-3}$ at $\delta'=0.01$. `tests/test_dither.py` checks by Monte Carlo that the computed proxy matches the variance of the margin error in regimes where the bound should be tight (ratio about 1), and that a deliberately weakened threshold is detected (negative control).

**Relation to PAC-Bayes.** The law of $g=f+\epsilon$ is a posterior $Q$ (uniform on a box around $f$) and the code for $K$ plays the role of $\mathrm{KL}(Q\|P)$. Theorem 5 uses one draw from $Q$ instead of averaging over $Q$, pays $\eta/\delta'$ for it, and concludes about the deterministic $f$ through a per-input concentration statement instead of a sup over all inputs (as in the margin-based derandomizations of Neyshabur et al. 2018 and Nagarajan & Kolter 2019).

---

## 3. Initialization

**Lemma 8 (the initialization is free).** Let $\theta_0$ be drawn from any distribution independent of $S$, and let $(\Sigma_{\theta_0},L_{\theta_0})$ be a code that may depend on $\theta_0$ (e.g. it describes $\theta-\theta_0$). Then Lemma 1 holds for this code with probability $\ge1-\delta$ over $(S,\theta_0)$.

*Proof.* Conditional on $\theta_0=t$, $S\sim D^m$, so Lemma 1 holds with probability $\ge1-\delta$ for the fixed code $(\Sigma_t,L_t)$; average over $t$. $\square$

Consequences. (i) Random initialization costs nothing in the bound, provided the seed is chosen independently of the data; if the best of $N$ seeds is picked after training, add $\log_2N$ bits; even a seed that had to be described costs only its length (32 bits in the experiments, which we charge anyway). (ii) The same holds for any other data-independent randomness: random projections, the dither of Lemma 6, the DCT basis. (iii) Coding $\theta-\theta_0$ instead of $\theta$ helps exactly when training leaves most of $\theta_0$ unchanged. On MNIST, first-layer weights on pixels that are zero in every training image receive zero gradient, so their update is exactly zero and costs almost nothing. (iv) What the initialization can still cost is indirect: in the lazy regime the trained function is $\theta_0$-dependent noise plus a dense small update, and the update's description length, not $\theta_0$'s, is what matters. A deterministic initialization (zero init is degenerate for ReLU MLPs; Hadamard/identity-type inits work) has the same zero cost and can only help through the update it leads to.

**Proposition 9 (init-kernel codec; linearized regime).** Let $J(x)=\partial_\theta f_{\theta_0}(x)$ and $F_0=\mathbb E_{D_X}[J(x)^\top J(x)]$, a function of $\theta_0$ and $D_X$ only. For $\theta=\theta_0+\Delta$ let $f^{\mathrm{lin}}_\theta(x)=f_{\theta_0}(x)+J(x)\Delta$ and let $P_r$ project onto the top-$r$ eigenvectors of $F_0$. Then
$$\mathbb E_{D_X}\|f^{\mathrm{lin}}_{\theta_0+\Delta}(x)-f^{\mathrm{lin}}_{\theta_0+P_r\Delta}(x)\|^2=\|F_0^{1/2}(I-P_r)\Delta\|^2\le\lambda_{r+1}(F_0)\,\|(I-P_r)\Delta\|^2.$$
*Proof.* The difference is $J(x)(I-P_r)\Delta$; take expectations. $\square$

When $D_X$ is known, the eigenbasis of $F_0$ is free (Lemma 8), so $\theta_0+P_r\Delta$ is described by $r$ quantized coefficients. For uniform inputs on $\{\pm1\}^n$ and an initialization distribution invariant under permutations and sign flips of the coordinates (e.g. i.i.d. symmetric weights), the expected kernel is a function of $\langle x,x'\rangle$ (the codec uses the kernel of the one sampled $\theta_0$, which this only approximates), its eigenfunctions are the Walsh characters, and the degree-$\ell$ eigenspace has dimension $\binom n\ell$. If, in addition, the eigenvalues decrease with the degree, a lazily trained network that has fitted a target of degree $k$ (or the sign of one, as for majority functions and degree 1) needs $r\approx\sum_{\ell\le k}\binom n\ell$ coefficients, so this codec certifies generalization only once $m\gtrsim n^k$, the known sample complexity of kernel methods on degree-$k$ targets. This is a heuristic: the eigenvalue ordering is not proved for our architecture, and the experiments use a single $n$. A network that has learned the relevant coordinates (rich regime) is instead close to a $k$-junta, which costs $\log_2\binom nk+2^k$ bits. In this picture feature learning is what makes the trained network short to describe. The experiments in `results/init/` measure both codecs on the same networks.

---

## 4. What the reduction can and cannot do

* The bound of Theorem 2 is never below $\mathrm{err}(f)$ minus estimation error. It is tight when there is a short $g$ with $\mathrm{err}(g)+\Pr[f\ne g]\approx\mathrm{err}(f)$; the Boolean experiments show this happens even when $f$ generalizes badly, e.g. a parity network with test error 0.26 gets a bound of 0.28 because $g$ is the true parity and $\Pr[f\ne g]$ is $f$'s error.
* Compressibility is sufficient, not necessary: a network can generalize without being close to any description of length $o(m)$ (e.g. when the target itself is incompressible). The bound then fails, correctly reporting that this argument does not apply.
* The bound is one-sided and is not a uniform-convergence statement over the set of networks the algorithm can output, so the obstructions of Nagarajan & Kolter (2019) to two-sided uniform convergence do not apply to it; they apply to any attempt to make the compressed class contain the algorithm's outputs themselves.
* Training-data-only bounds (Theorems 4–5) need more than functional closeness: the certificate must be computable from the description, which in practice means $g$ is close to $f$ in weight space at the precision the margin requires. The number of bits this costs grows with the number of weights that matter at typical inputs, which is why these bounds are non-vacuous for narrow networks and vacuous for wide ones (`results/mnist/`).
