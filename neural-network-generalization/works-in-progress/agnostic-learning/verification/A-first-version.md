# A. Tightly conditioned Bayesian networks interpolate noise and fail agnostically

*Research section for the brief `../research-notes/problem-brief.md`: Claims A, A′ and the TUBE variants, with a stretch result on the memorization exponent. 11 November 2026. This is a paper proof with numerical sanity checks. It has not been Lean-verified. `NNG/` denotes the project folder `neural-network-generalization/` of this repository. The check scripts are in `../checks/A/`.*

---

## 0. Results

Throughout, the depth is $L=H+1$ with $H\ge 2$ hidden tanh layers, unless stated otherwise. $\mathcal C_d=\{-1,1\}^d$ and $M=2^d$.

1. **Real-valued memorization (Lemma 2.1).** Let $r:\mathcal C_d\to[-1,1]$ satisfy $\sum_x r(x)^2\le s$ (for example, $r$ supported on $s$ points), and let $a\in(0,1]$. At every width
   $$N\ \ge\ N_0(d,s,a)=\Big\lfloor \tfrac{64\log 2\; d(d+1)s}{a^2}\Big\rfloor+1$$
   some network satisfies $\max_{\mathcal C_d}|z_w-r|<a$ and
   $$\kappa_N(w)\ \le\ K_{\rm mem}(d,s,a,H)=d(d+1)\alpha_d^2+(H+1)\max\Big\{(8ds)^{1/H},\tfrac{9}{2a}\Big\},\qquad \alpha_d=\tfrac12\log\big(4\sqrt{2d}\big).$$
   The first-layer term is $O(d^2\log^2 d)$. The noisy-interpolation note's term $dF_d=O(d^4)$ is what the cruder estimate $\alpha_d\le d+2$ gives. No margin conditioning is involved.
2. **Strong-prior concentration (Lemma 3.2, Corollary 3.3).** Fix $N$, $n$ and the sample, and let $\sigma\to0$. The SP$_c$ posterior mass of $\{F_c>\inf F_c+t\}$, weighted by any power of $1+F_c$, tends to $0$ for every $t>0$. In particular the posterior mean of $z_w$ approaches, uniformly in $x$, the conditional mean over near-minimizers. The tail contribution is controlled by $|z_w(x)|\le\sqrt{\kappa_N(w)}$.
3. **Claim A (Theorem 4.4, Corollaries 4.5 and 4.6).** Let $D_d$ be uniform $x\in\mathcal C_d$ with a fair $\pm1$ label independent of $x$. Let $n/2^d\to\lambda\in(0,\infty)$ and $c=c_d$ with $c_d\,(d^2\log^2(d+1)+(dn)^{1/H})=o(n)$; this includes $c\equiv1$. Then with probability at least $1-\exp(-2^{d/2})$, at every width $N\ge N_0={\rm poly}(n)$, every near-minimizer of $F_c$ has
   $$L_{D_d}\ \ge\ 1+\beta_n-o(1),\qquad \beta_n=\mathbb E[K^{-1};K\ge1],\ K\sim{\rm Bin}(n,2^{-d}).$$
   So does a Gibbs draw, with posterior probability tending to 1 as $\sigma\to0$, and so does the posterior mean in the limit, clipped or not. All $o(1)$ terms are explicit. The zero network has $L_{D_d}(0)=1$, which is the Bayes risk. The limit is $\beta_n\to\beta(\lambda)=e^{-\lambda}\int_0^\lambda\frac{e^u-1}{u}du$, with $\beta(1)=0.484829$ and $\max_\lambda\beta=0.517351$ at $\lambda=1.50286$. For general label laws with ${\rm Var}(y\mid x)\ge v_0$, the excess over the Bayes predictor is at least $v_0\beta_n-o(1)$.
4. **Refutation (Proposition 5.1).** Take the competitor $g\equiv 0$, any fixed $\varepsilon<\beta(1)$ and $\delta<1$, and $n=2^d$, which eventually exceeds any polynomial in $d$. Theorem 4.4 then violates the oracle inequality of brief §1 for SP$_c$ under every reading of "the $\sigma\to0$ learner". The result refutes the width-uniform formulation of the brief. It says nothing about learners whose width is below $N_0$ (§5.2).
5. **Variants (§6).**
   - *Without replacement* (Proposition 6.1): the excess is at least $\frac nM(1-o(1))$ with probability one, so the test MSE tends to $2$ at $n=M$.
   - *TUBE$_\rho$ with $\rho>1$, or any $\rho$ with $|y|<\rho$* (Lemma 6.2, Proposition 6.3): the strong-prior posterior collapses to the zero network. Non-centred noise then gives a constant excess $\eta_0^2$ against a width-one constant competitor.
   - *TUBE$_\rho$ with $\rho\le1$, with replacement* (Lemma 6.4): the posterior is undefined with probability $1-e^{-\Omega(M)}$, because some atom carries both labels.
   - *TUBE$_\rho$ with $\rho<1$, without replacement* (Proposition 6.5): every posterior draw and the posterior mean have excess at least $\frac nM(b-\rho)^2$ at every $\sigma$, where $b$ is the noise amplitude.
6. **Claim A′ (Theorem 7.2).** The inputs are absolutely continuous: tiny corner cubes of side $r(n)=\frac1n\big(\frac{L}{\max\{n/c+t,K_{\rm mem}\}}\big)^{L/2}$, where $t$ is the near-minimizer slack. The label is the deterministic function $f^\star(x)=+1$ if $|x_1|>1-r/2$ and $-1$ otherwise. The same lower bound $1+\beta_n-o(1)$ holds, while the Bayes risk is $0$ and every network of width $m$ with weights at most $B$ has risk at least $1-\frac r2B^Lm^H\sqrt d$.
7. **The exponent $1/H$ is optimal (§8).**
   - *Energy lower bound* (Proposition 8.2): any family of networks of energy at most $K$ that memorizes most sign patterns on $s$ cube points needs $K\ge H\big(\frac{(1-a)\sqrt s}{D_{d,H}}\big)^{2/H}$, with $D_{d,H}=\sqrt{2\log2}\,(d+1)+\frac{H-1}2$. Lemma 2.1 is therefore sharp in $s$ up to a factor $O(d^{3/H})$.
   - *Learner side* (Proposition 8.3): for $c\ge n^{1-\vartheta}$ with $\vartheta<1/H$, near-minimizers on the cube example do not memorize. The critical memorization scale is therefore $c=n^{1-1/H}$ up to polylogarithmic factors.
8. **Checks (§9).** The parity–tanh identity, the coefficient bounds, an explicit construction of the memorizer with exact energy, the chain inequality, $\beta(\lambda)$ and the concentration of $Q$, and a small-$d$ optimization of $F_c$ were all checked numerically.
9. **Not proved (§10).** Depth two; learner widths below $N_0$; the finite-scale prior $\mu_{N,\gamma}$; the progressive-mixture predictor; the regime $n^{1-1/H}\ll c\ll n^{1-1/(H+1)}$ for the test excess.

---

## 1. Setting and notation

### 1.1 Networks and energy

Let $d,H,N\ge1$ be integers, $L=H+1$, and $\bar x=(1,x)\in\mathbb R^{d+1}$ for $x\in\mathbb R^d$. A parameter is $w=(W^1,\dots,W^H,v)$ with $W^1\in\mathbb R^{N\times(d+1)}$, $W^\ell\in\mathbb R^{N\times N}$ for $2\le\ell\le H$, and $v\in\mathbb R^N$. The parameter space is $\mathbb R^P$ with $P=N(d+1)+(H-1)N^2+N$. The network computes
$$h^0(x)=\bar x,\qquad h^\ell(x)=\tanh\big(W^\ell h^{\ell-1}(x)\big)\ (1\le\ell\le H),\qquad z_w(x)=v^\top h^H(x).$$
There are no separate biases; the constant input coordinate carries offsets. The energy is
$$\kappa_N(w)=\underbrace{\tfrac dN\|W^1\|_F^2}_{\kappa^{(1)}(w)}+\sum_{\ell=2}^{H}\underbrace{\|W^\ell\|_F^2}_{\kappa^{(\ell)}(w)}+\underbrace{N\|v\|_2^2}_{\kappa^{(L)}(w)}. \tag{1.1}$$
This is eq. (`energy`) of `NNG/side-results/continuous-domains/source/paper.tex` and the energy of brief §2, where $\sum_{\ell=2}^{L-1}=\sum_{\ell=2}^{H}$. It is a positive definite quadratic form, $\kappa_N(w)=w^\top\Gamma_N w$, with $\Gamma_N$ diagonal with entries $d/N$, $1$ and $N$.

### 1.2 Learners

* **Strong prior.** $\mu_\sigma$ has Lebesgue density proportional to $e^{-\kappa_N(w)/(2\sigma^2)}$. Its coordinates are independent centred Gaussians with variances $N\sigma^2/d$, $\sigma^2$ and $\sigma^2/N$.
* **Sample.** $S=((x_i,y_i))_{i=1}^n$.
* **SP$_c$.** For $c>0$, which may depend on $n$,
  $$\Pi_{\sigma}(dw)=\Pi^{c}_{\sigma,S}(dw)=Z_\sigma^{-1}\exp\Big(-\frac{F_{c,S}(w)}{2\sigma^2}\Big)dw,\qquad F_{c,S}(w)=\kappa_N(w)+\frac1c\sum_{i=1}^n\big(z_w(x_i)-y_i\big)^2 . \tag{1.2}$$
  This is the posterior of $\mu_\sigma$ under the likelihood $y_i\sim\mathcal N(z_w(x_i),c\sigma^2)$. The **limit order** is: $d,N,n,c$ and the sample $S$ are fixed, then $\sigma\to0$.
* **Near-minimizers.** $\mathcal N_t(S)=\{w:F_{c,S}(w)\le\inf F_{c,S}+t\}$ for $t>0$.
* **TUBE$_\rho$.** For a prior $\mu$ (either $\mu_\sigma$ or the finite-scale prior $\mu_{N,\gamma}$),
  $$\Pi^{\rm tube}_{\rho,S}(B)=\frac{\mu(B\cap U_{\rho,S})}{\mu(U_{\rho,S})},\qquad U_{\rho,S}=\Big\{w:\max_{i\le n}|z_w(x_i)-y_i|<\rho\Big\}. \tag{1.3}$$
  This is eq. (`posterior`) of the continuous-domain paper, with the clean labels $f(x_i)$ replaced by the observed labels $y_i$. The set $U_{\rho,S}$ is open and both priors have full support, so $\Pi^{\rm tube}_{\rho,S}$ is defined if and only if $U_{\rho,S}\ne\emptyset$.

### 1.3 Losses and predictors

The test loss is $L_D(f)=\mathbb E_{(x,y)\sim D}(f(x)-y)^2$. For a posterior $\Pi$ we consider:

* **Gibbs.** A random draw $w\sim\Pi$. We bound both $\Pi\{w:L_D(z_w)\ge\cdot\}$ and $\mathbb E_{w\sim\Pi}L_D(z_w)$.
* **Posterior mean.** $\bar z_\Pi(x)=\int z_w(x)\,\Pi(dw)$. This is finite by Lemma 3.1(a) and Gaussian tails.
* **Clipped versions.** With ${\rm clip}(u)=\max\{-1,\min\{1,u\}\}$: ${\rm clip}\circ z_w$, ${\rm clip}\circ\bar z_\Pi$, and $\int{\rm clip}(z_w(\cdot))\,\Pi(dw)$.

### 1.4 The cube example and sample statistics

$D_d$ is the law of $(x,y)$ with $x$ uniform on $\mathcal C_d$ and $y$ uniform on $\{-1,1\}$, independent of $x$. Its regression function is $\eta\equiv0$ and ${\rm Var}(y\mid x)=1$. For a sample with inputs in a finite set we write:

* $k_x=\#\{i:x_i=x\}$ for the count and $\mathcal S=\{x:k_x\ge1\}$ for the set of seen atoms;
* $\bar y_x=k_x^{-1}\sum_{i:x_i=x}y_i$ for $x\in\mathcal S$;
* $Q=\sum_{x\in\mathcal S}\bar y_x^2$, the noise that exact atom-mean fitting would capture;
* $W=\sum_i(y_i-\bar y_{x_i})^2$, the within-atom sum of squares;
* $\Delta(f)=\sum_{x\in\mathcal S}k_x\,(f(x)-\bar y_x)^2$ for $f$ defined on $\mathcal S$.

We also use
$$\beta_n=\mathbb E\big[K^{-1};K\ge1\big],\ K\sim{\rm Bin}(n,1/M);\qquad \beta(\lambda)=\mathbb E\big[K^{-1};K\ge1\big],\ K\sim{\rm Poi}(\lambda). \tag{1.4}$$

---

## 2. Real-valued memorization at depth $H+1\ge3$

**Lemma 2.1 (memorization).** Let $d\ge1$, $H\ge2$, $s>0$ and $a\in(0,1]$. Let $r:\mathcal C_d\to[-1,1]$ satisfy $\sum_{x\in\mathcal C_d}r(x)^2\le s$; this holds in particular if $r$ is supported on a set $T$ with $|T|\le s$. Put
$$\alpha_d=\tfrac12\log\big(4\sqrt{2d}\big),\qquad K_{\rm mem}(d,s,a,H)=d(d+1)\alpha_d^2+(H+1)\max\Big\{(8ds)^{1/H},\frac{9}{2a}\Big\},\qquad N_0(d,s,a)=\Big\lfloor\frac{64\log2\cdot d(d+1)s}{a^2}\Big\rfloor+1 .$$
For every $N\ge N_0(d,s,a)$ there is a parameter $w$ of width $N$ and depth $L=H+1$ with
$$\max_{x\in\mathcal C_d}|z_w(x)-r(x)|<a,\qquad \kappa_N(w)\le K_{\rm mem}(d,s,a,H). \tag{2.1}$$

Since $\alpha_d^2=O(\log^2 d)$ and $\max\{u,v\}\le u+v$,
$$K_{\rm mem}\le d(d+1)\alpha_d^2+(H+1)(8ds)^{1/H}+\tfrac{9(H+1)}{2a}=O\big(d^2\log^2d+H(ds)^{1/H}+H/a\big),\qquad N_0=O(d^2s/a^2).$$
The learner has no margin conditioning, and none is needed here: (2.1) is a statement about the raw parameter space.

The proof adapts Sections 2–3 of `NNG/works-in-progress/noisy-interpolation/README.md` (cited below as the noisy-interpolation note), re-deriving every constant. The note treats sign corrections at accuracy $1/4$. Here the target is real-valued, the accuracy is $a$, and there is no clean branch.

### 2.1 Parity coefficients

For $k\ge1$ let $b_k=0$ if $k$ is odd and $b_k=1$ if $k$ is even. For $\alpha\in(0,\infty)$ put
$$c_{k,\alpha}=2^{-k}\sum_{v\in\{-1,1\}^k}\Big(\prod_{j=1}^kv_j\Big)\tanh\Big(\alpha\Big(\sum_{j=1}^kv_j-b_k\Big)\Big),$$
and let $c_{k,\infty}$ be the same sum with $\tanh(\alpha\,\cdot)$ replaced by ${\rm sign}$. For $S\subseteq[d]$ write $\chi_S(x)=\prod_{j\in S}x_j$.

**Lemma 2.2.** The following hold.

* (a) $c_{k,\infty}=(-1)^m\binom{2m}{m}4^{-m}$ if $k=2m+1$, and $c_{k,\infty}=(-1)^{m-1}\binom{2m}{m}4^{-m}$ if $k=2m$.
* (b) $|c_{k,\infty}|\ge(2k)^{-1/2}$.
* (c) $|c_{k,\alpha}-c_{k,\infty}|\le1-\tanh\alpha\le2e^{-2\alpha}$.
* (d) If $1\le k\le d$, then $|c_{k,\alpha_d}|\ge\big(2\sqrt{2k}\big)^{-1}$.
* (e) For $S\subseteq[d]$ with $|S|=k\ge1$, every $\alpha>0$ and every $x\in\mathcal C_d$,
  $$2^{-k}\sum_{u\in\{-1,1\}^S}\Big(\prod_{j\in S}u_j\Big)\tanh\Big(\alpha\Big(\sum_{j\in S}u_jx_j-b_k\Big)\Big)=c_{k,\alpha}\,\chi_S(x). \tag{2.2}$$

These are eqs. (3)–(4) of the noisy-interpolation note.

*Proof.*

(a) If $v$ has exactly $j$ coordinates equal to $-1$, then $\prod_jv_j=(-1)^j$ and $\sum_jv_j-b_k=k-2j-b_k$, which is an odd integer.

* For $k=2m+1$: $k-2j>0$ if and only if $j\le m$. Since $\sum_{j=0}^k(-1)^j\binom kj=0$, this gives $2^kc_{k,\infty}=2\sum_{j=0}^{m}(-1)^j\binom kj$.
* We use the identity $\sum_{j=0}^t(-1)^j\binom qj=(-1)^t\binom{q-1}{t}$ for $q\ge1$ and $0\le t\le q-1$. It follows by induction on $t$ from Pascal's rule.
* So for $k=2m+1$ we get $2^kc_{k,\infty}=2(-1)^m\binom{2m}{m}$, and $2^k=2\cdot4^m$.
* For $k=2m$ with $m\ge1$: $k-2j-1>0$ if and only if $j\le m-1$. Hence $2^kc_{k,\infty}=2\sum_{j=0}^{m-1}(-1)^j\binom{2m}{j}=2(-1)^{m-1}\binom{2m-1}{m-1}=(-1)^{m-1}\binom{2m}{m}$.

(b) For $k=1$, $|c_{1,\infty}|=1$. Put $q_m=\binom{2m}{m}4^{-m}$. Then $q_1=\frac12=\frac1{2\sqrt1}$, and $q_m/q_{m-1}=\frac{2m-1}{2m}\ge\sqrt{\frac{m-1}{m}}$ because $(2m-1)^2\ge4m(m-1)$. By induction $q_m\ge\frac1{2\sqrt m}$. For $k\ge2$, $m=\lfloor k/2\rfloor\le k/2$, so $|c_{k,\infty}|=q_m\ge\frac1{2\sqrt m}\ge\frac1{\sqrt{2k}}$.

(c) For every $v$, the argument $t=\sum_jv_j-b_k$ is an odd integer, so $|t|\ge1$. Hence $|{\rm sign}(t)-\tanh(\alpha t)|=1-\tanh(\alpha|t|)\le1-\tanh\alpha$. Averaging over $v$ gives the first inequality. The second is $1-\tanh\alpha=\frac{2e^{-2\alpha}}{1+e^{-2\alpha}}$.

(d) $2e^{-2\alpha_d}=\frac{2}{4\sqrt{2d}}=\frac1{2\sqrt{2d}}\le\frac1{2\sqrt{2k}}$. By (b) and (c), $|c_{k,\alpha_d}|\ge\frac1{\sqrt{2k}}-\frac1{2\sqrt{2k}}$.

(e) Fix $x$. The map $u\mapsto v$ with $v_j=u_jx_j$ for $j\in S$ is a bijection of $\{-1,1\}^S$. It satisfies $\sum_ju_jx_j=\sum_jv_j$ and $\prod_ju_j=\chi_S(x)\prod_jv_j$, since $x_j^2=1$. Substituting turns the left side of (2.2) into $\chi_S(x)\,c_{k,\alpha}$. $\square$

### 2.2 A scalar tanh chain

**Lemma 2.3.** Let $H\ge2$, $R\ge\sqrt2$ and $g\in\mathbb R$. Put $y_1=\tanh(g/R^{H-1})$ and $y_j=\tanh(Ry_{j-1})$ for $2\le j\le H-1$. Then
$$\big|Ry_{H-1}-g\big|\le\frac{|g|^3}{3}\sum_{i=1}^{H-1}R^{-2i}\le\frac{2|g|^3}{3R^2}. \tag{2.3}$$

*Proof.*

* **Basic inequality.** For $t\ge0$ the function $\phi(t)=t-\tanh t$ has $\phi(0)=0$ and $\phi'(t)=\tanh^2t\in[0,t^2]$. So $0\le\phi(t)\le t^3/3$, and by oddness $|t-\tanh t|\le|t|^3/3$ for all $t$.
* **Ideal chain.** Put $\tilde y_j=g/R^{H-j}$, so that $\tilde y_j=R\tilde y_{j-1}$ and $R\tilde y_{H-1}=g$.
* **Magnitudes.** Since $|\tanh u|\le|u|$, induction gives $|y_1|\le|\tilde y_1|$ and $|y_j|\le R|y_{j-1}|\le|\tilde y_j|$.
* **Error recursion.** Let $e_j=|y_j-\tilde y_j|$. Then $e_1\le|\tilde y_1|^3/3$, and for $j\ge2$,
  $$e_j\le|\tanh(Ry_{j-1})-Ry_{j-1}|+R\,e_{j-1}\le\frac{|Ry_{j-1}|^3}{3}+Re_{j-1}\le\frac{|\tilde y_j|^3}{3}+Re_{j-1}.$$
* **Unrolling.** $e_{H-1}\le\sum_{j=1}^{H-1}R^{H-1-j}\,|\tilde y_j|^3/3$, so
  $$|Ry_{H-1}-g|=Re_{H-1}\le\frac{|g|^3}{3}\sum_{j=1}^{H-1}R^{H-j}R^{-3(H-j)}=\frac{|g|^3}3\sum_{i=1}^{H-1}R^{-2i}.$$
* **Geometric sum.** If $R^2\ge2$, then $\sum_{i\ge1}R^{-2i}=\frac1{R^2-1}\le\frac2{R^2}$. $\square$

This is eq. (9) of the noisy-interpolation note, in general form.

### 2.3 Proof of Lemma 2.1

**Step 1 (Fourier $\ell^1$ bound).** Let $\hat r(S)=M^{-1}\sum_xr(x)\chi_S(x)$. Orthonormality of the characters under the uniform measure gives $r=\sum_S\hat r(S)\chi_S$ and $\sum_S\hat r(S)^2=M^{-1}\sum_xr(x)^2$. Cauchy–Schwarz over the $M$ subsets then gives
$$\sum_{S\subseteq[d]}|\hat r(S)|\le\sqrt M\Big(\sum_S\hat r(S)^2\Big)^{1/2}=\Big(\sum_xr(x)^2\Big)^{1/2}\le\sqrt s. \tag{2.4}$$
This is eq. (2) of the noisy-interpolation note.

**Step 2 (exact affine-tanh expansion).**

* **Features for nonempty $S$.** For $S\ne\emptyset$ and $u\in\{-1,1\}^S$, define the row $\omega_{S,u}\in\mathbb R^{d+1}$ by $(\omega_{S,u})_0=-\alpha_db_{|S|}$, $(\omega_{S,u})_j=\alpha_du_j$ for $j\in S$, and $0$ otherwise. Put $\phi_{S,u}(x)=\tanh(\omega_{S,u}\cdot\bar x)$.
* **Feature for $S=\emptyset$.** Let $\omega_\emptyset=e_0$, so $\phi_\emptyset\equiv\tanh 1$.
* **Expansion.** By Lemma 2.2(e), on $\mathcal C_d$,
  $$r=\frac{\hat r(\emptyset)}{\tanh 1}\,\phi_\emptyset+\sum_{S\ne\emptyset}\frac{\hat r(S)}{c_{|S|,\alpha_d}}\,2^{-|S|}\sum_{u\in\{-1,1\}^S}\Big(\prod_{j\in S}u_j\Big)\phi_{S,u}.$$
  We write this as $r=\sum_{j\in\mathcal J}\gamma_j\phi_j$ on $\mathcal C_d$, over a finite index set $\mathcal J$.
* **Total coefficient.** Lemma 2.2(d) gives $1/|c_{k,\alpha_d}|\le2\sqrt{2k}\le2\sqrt{2d}$, and $1/\tanh1<1.32<2\sqrt2\le2\sqrt{2d}$. With (2.4),
  $$A:=\sum_{j\in\mathcal J}|\gamma_j|=\frac{|\hat r(\emptyset)|}{\tanh1}+\sum_{S\ne\emptyset}\frac{|\hat r(S)|}{|c_{|S|,\alpha_d}|}\le2\sqrt{2d}\sum_S|\hat r(S)|\le2\sqrt{2ds},\qquad A^2\le8ds. \tag{2.5}$$
* **Row norms.** $\|\omega_{S,u}\|_2^2=\alpha_d^2\,(b_{|S|}^2+|S|)\le(d+1)\alpha_d^2$. Also $\|\omega_\emptyset\|^2=1\le(d+1)\alpha_d^2$, because $(d+1)\alpha_d^2\ge2\alpha_1^2>1.4$.

If $A=0$, then $r\equiv0$ on $\mathcal C_d$ and $w=0$ satisfies (2.1). Assume from now on that $A>0$.

**Step 3 (sampling at accuracy $a/2$).**

* **Random features.** Let $m=N_0(d,s,a)$. Let $J_1,\dots,J_m$ be i.i.d. on $\mathcal J$ with $\Pr[J=j]=|\gamma_j|/A$. Put $\xi_t(x)={\rm sgn}(\gamma_{J_t})\,\phi_{J_t}(x)=\tanh\big({\rm sgn}(\gamma_{J_t})\,\omega_{J_t}\cdot\bar x\big)$; this uses that tanh is odd.
* **Unbiasedness.** For $x\in\mathcal C_d$, $|\xi_t(x)|\le1$ and $\mathbb E[A\xi_t(x)]=r(x)$.
* **Hoeffding.** Let $g=\frac Am\sum_{t=1}^m\xi_t$. For fixed $x$, $g(x)-r(x)$ is a sum of $m$ independent centred terms, each in an interval of length $2A/m$. Hoeffding's inequality gives $\Pr[|g(x)-r(x)|\ge a/2]\le2\exp(-ma^2/(8A^2))$.
* **Union bound.** Over the $M=2^d$ points of $\mathcal C_d$,
  $$\Pr\Big[\max_{x\in\mathcal C_d}|g(x)-r(x)|\ge\tfrac a2\Big]\le2^{d+1}e^{-ma^2/(8A^2)}<1,$$
  because $m>\frac{64\log2\cdot d(d+1)s}{a^2}\ge\frac{8A^2(d+1)\log2}{a^2}$ by (2.5).

Fix a realization with $\max_{\mathcal C_d}|g-r|<a/2$. Write $\omega_t$ for the signed rows, so that $\xi_t(x)=\tanh(\omega_t\cdot\bar x)$ and $\|\omega_t\|^2\le(d+1)\alpha_d^2$. On $\mathcal C_d$ we have $|g|\le|r|+a/2\le3/2$.

**Step 4 (the network at width $N\ge m$).** Put $R=\max\{A^{1/H},(9/(2a))^{1/2}\}$. Partition $[N]$ into groups $G_1,\dots,G_m$ of sizes $k_t\in\{\lfloor N/m\rfloor,\lceil N/m\rceil\}$, with $\sum_tk_t=N$. Since $N/m\ge1$, $k_t\ge\lfloor N/m\rfloor\ge\frac N{2m}$.

* **Layer 1.** Neuron $i\in G_t$ has row $\omega_t$, so $h^1_i=\xi_t$.
* **Layer 2.** Every neuron has weight $\frac{A}{m\,k_t\,R^{H-1}}$ on each neuron of $G_t$. Its preactivation is $\sum_tk_t\frac{A}{mk_tR^{H-1}}\xi_t=g/R^{H-1}$, so it outputs $y_1=\tanh(g/R^{H-1})$.
* **Layers $3,\dots,H$.** All weights equal $R/N$. Layer $\ell$ outputs $y_{\ell-1}=\tanh(Ry_{\ell-2})$.
* **Readout.** $v_j=R/N$ for every $j$, so $z_w=R\,y_{H-1}$. When $H=2$, $z_w=R\tanh(g/R)$.

**Step 5 (energy).**

* $\kappa^{(1)}=\frac dN\sum_tk_t\|\omega_t\|^2\le d(d+1)\alpha_d^2$.
* $\kappa^{(2)}=N\sum_tk_t\big(\frac{A}{mk_tR^{H-1}}\big)^2=\frac{NA^2}{m^2R^{2H-2}}\sum_t\frac1{k_t}\le\frac{NA^2}{m^2R^{2H-2}}\cdot\frac{2m^2}{N}=\frac{2A^2}{R^{2H-2}}\le2R^2$, using $A^2\le R^{2H}$.
* $\kappa^{(\ell)}=N^2(R/N)^2=R^2$ for $3\le\ell\le H$.
* $\kappa^{(L)}=N\cdot N(R/N)^2=R^2$.

The total is
$$\kappa_N(w)\le d(d+1)\alpha_d^2+(H+1)R^2=d(d+1)\alpha_d^2+(H+1)\max\{A^{2/H},9/(2a)\}\le K_{\rm mem}(d,s,a,H),$$
using (2.5).

**Step 6 (accuracy).** $R^2\ge9/(2a)\ge2$ because $a\le1$. By Lemma 2.3, on $\mathcal C_d$,
$$|z_w-g|\le\frac{2|g|^3}{3R^2}\le\frac{2(3/2)^3}{3}\cdot\frac{2a}{9}=\frac a2,$$
and therefore $|z_w-r|\le|z_w-g|+|g-r|<a$. $\square$

### 2.4 Remarks on Lemma 2.1

**Remark 2.4 (comparison with the noisy-interpolation note).** The note's eq. (10) reads $K_{\rm corr}\le dF_d+(H+5)Q+(H+5)A_s^{2/H}$, with $F_d=1+(d+1)(d+2)^2$ and $Q=2+8(5U)^3$. It concerns a sign correction of size up to $4U$, accuracy $1/4$, and half of the neurons. Three changes produce Lemma 2.1.

* *First layer.* The note bounds the row norm using $a_d\le d+2$. Its slope $a_d=\max\{1,\frac12\log(4\sqrt{2d})\}$ is in fact $O(\log d)$. Using the slope itself gives $d(d+1)\alpha_d^2=O(d^2\log^2d)$ instead of $dF_d=O(d^4)$. Both bounds are valid, and the brief's "$d^4$" is the cruder one.
* *Accuracy.* Hoeffding at $a/2$ costs width $\propto a^{-2}$. The chain gain $R^2\ge9/(2a)$ costs energy $\propto a^{-1}$.
* *No clean branch.* All $N$ neurons serve the correction. This removes the factors $N/N_c\le3$.

The amplification $A^2\le8ds$ plays the role of the note's $A_s^2=1+144U^2d(s+1)$. Its constant is smaller because $|r|\le1$ and the bound uses $\sum_x r(x)^2$ rather than $16U^2s$.

**Remark 2.5 (depth two).** For $H=1$ the same features with readout $A/(mk_t)$ cost $\kappa^{(L)}\le2A^2\le16ds$. That is linear in $s$, and Proposition 8.2 shows that linear growth in $s$ is unavoidable at $H=1$, up to factors polynomial in $d$. This is why Claim A is stated for $H\ge2$.

**Remark 2.6 (Lipschitz constant of the memorizer).** By Lemma 3.1(b) below, the memorizer satisfies ${\rm Lip}(z_w)\le(K_{\rm mem}/L)^{L/2}/\sqrt d$ on all of $\mathbb R^d$. This is used in §7.

---

## 3. Two network bounds and strong-prior concentration

**Lemma 3.1.** For every $N$, $w$ and $x,x'\in\mathbb R^d$:

* (a) $|z_w(x)|\le\|v\|_1\le\sqrt N\|v\|_2\le\sqrt{\kappa_N(w)}$.
* (b) $|z_w(x)-z_w(x')|\le\Big(\frac1d\prod_{\ell=1}^{L}\kappa^{(\ell)}(w)\Big)^{1/2}\|x-x'\|_2\le\frac{(\kappa_N(w)/L)^{L/2}}{\sqrt d}\,\|x-x'\|_2 .$

*Proof.*

(a) Every hidden activation lies in $[-1,1]$, so $|z_w(x)|\le\|v\|_1$. Then $\|v\|_1\le\sqrt N\|v\|_2=\sqrt{\kappa^{(L)}}$ by Cauchy–Schwarz.

(b) Tanh is 1-Lipschitz coordinatewise, and the constant coordinate of $\bar x$ cancels in $\bar x-\bar x'$. Hence:

* $\|h^1(x)-h^1(x')\|_2\le\|W^1\|_F\|x-x'\|_2$;
* $\|h^\ell(x)-h^\ell(x')\|_2\le\|W^\ell\|_F\|h^{\ell-1}(x)-h^{\ell-1}(x')\|_2$;
* $|z_w(x)-z_w(x')|\le\|v\|_2\,\|h^H(x)-h^H(x')\|_2$.

The product of the factors is
$$\|v\|_2\prod_\ell\|W^\ell\|_F=\big(\kappa^{(L)}/N\big)^{1/2}\big(N\kappa^{(1)}/d\big)^{1/2}\prod_{\ell=2}^H\big(\kappa^{(\ell)}\big)^{1/2}.$$
The second inequality is AM–GM applied to the $L$ nonnegative numbers $\kappa^{(\ell)}$. $\square$

The bound (b) sharpens eq. (`energy-lipschitz`) of the continuous-domain paper, ${\rm Lip}(z_w)\le K^{L/2}/\sqrt d$, by the factor $L^{-L/2}$, as the brief anticipated. That paper obtains its bound by multiplying the layer norm bounds; either version suffices below.

**Lemma 3.2 (strong-prior concentration).** Let $F:\mathbb R^P\to[0,\infty)$ be continuous with $F\ge\kappa_N$, and let $\Pi_\sigma(dw)=Z_\sigma^{-1}e^{-F(w)/(2\sigma^2)}dw$. Then $F^*:=\inf F$ is attained. For every $t>0$ and $p\ge0$,
$$\lim_{\sigma\to0}\int_{\{F>F^*+t\}}\big(1+F(w)\big)^p\,\Pi_\sigma(dw)=0. \tag{3.1}$$
Quantitatively, suppose $F\le F^*+t/4$ on a Euclidean ball of radius $\delta$ and volume $V_\delta$ around a minimizer. Then for all $\sigma>0$ with $\sigma^2\le3/(8p)$ (no condition if $p=0$),
$$\int_{\{F>F^*+t\}}(1+F)^p\,d\Pi_\sigma\le\frac{(1+F^*+t)^p}{V_\delta\sqrt{\det\Gamma_N}}\Big(\frac{8\pi\sigma^2(F^*+t)}{t}\Big)^{P/2}e^{-t/(4\sigma^2)} . \tag{3.2}$$

*Proof.*

* **Minimizer.** $\{F\le F(0)\}\subseteq\{\kappa_N\le F(0)\}$ is compact, so a minimizer $w^*$ exists. By continuity, a ball $B(w^*,\delta)$ with $F\le F^*+t/4$ exists.
* **Normalizer.** $Z_\sigma\ge V_\delta\,e^{-(F^*+t/4)/(2\sigma^2)}$.
* **Splitting.** Put $\theta=\frac{t}{4(F^*+t)}\in(0,\frac14]$. On $\{F>F^*+t\}$ we have $F=(1-\theta)F+\theta F\ge(1-\theta)F+\theta\kappa_N$.
* **Monotonicity.** The function $u\mapsto(1+u)^pe^{-(1-\theta)u/(2\sigma^2)}$ is nonincreasing on $[0,\infty)$ when $p\le\frac{1-\theta}{2\sigma^2}$. Since $1-\theta\ge3/4$, this holds when $\sigma^2\le3/(8p)$.
* **Numerator.** Therefore
  $$\int_{\{F>F^*+t\}}(1+F)^pe^{-F/(2\sigma^2)}dw\le(1+F^*+t)^p\,e^{-(1-\theta)(F^*+t)/(2\sigma^2)}\int e^{-\theta\, w^\top\Gamma_Nw/(2\sigma^2)}dw .$$
  The last integral equals $(2\pi\sigma^2/\theta)^{P/2}(\det\Gamma_N)^{-1/2}$.
* **Exponent.** In the ratio of numerator to normalizer the exponent is $-\frac{(1-\theta)(F^*+t)-(F^*+t/4)}{2\sigma^2}=-\frac{t/2}{2\sigma^2}$, because $\theta(F^*+t)=t/4$. This gives (3.2).
* **Limit.** The right side of (3.2) tends to $0$ as $\sigma\to0$, which proves (3.1). $\square$

This is the strong-prior Laplace estimate of the continuous-domain paper (proof of Theorem `strong`, Gaussian case), in a form with an arbitrary objective $F\ge\kappa_N$ and polynomial weights.

**Corollary 3.3 (Gibbs draw and posterior mean).** Apply Lemma 3.2 with $F=F_{c,S}$, and put
$$p_\sigma=\Pi_\sigma(\mathcal N_t),\qquad T_\sigma=\int_{\mathcal N_t^c}\sqrt{F_{c,S}}\,d\Pi_\sigma,$$
$$m_\sigma(x)=\mathbb E_{\Pi_\sigma}[z_w(x)\mid\mathcal N_t],\qquad m^{\rm cl}_\sigma(x)=\mathbb E_{\Pi_\sigma}[{\rm clip}(z_w(x))\mid\mathcal N_t].$$
Then $p_\sigma\to1$ and $T_\sigma\to0$ as $\sigma\to0$. For every $x\in\mathbb R^d$,
$$|\bar z_{\Pi_\sigma}(x)-m_\sigma(x)|\le(1-p_\sigma)\sqrt{F^*+t}+T_\sigma,\qquad\Big|\int{\rm clip}(z_w(x))\,\Pi_\sigma(dw)-m^{\rm cl}_\sigma(x)\Big|\le2(1-p_\sigma). \tag{3.3}$$
Moreover, for points $x_1,\dots,x_J$ and any convex $\Phi:\mathbb R^J\to\mathbb R$,
$$\Phi\big((m_\sigma(x_j))_j\big)\le\sup_{w\in\mathcal N_t}\Phi\big((z_w(x_j))_j\big),$$
and the same holds with $m^{\rm cl}_\sigma$ and ${\rm clip}\circ z_w$.

*Proof.*

* **Limits.** $p_\sigma\to1$ and $T_\sigma\to0$ are (3.1) with $p=0$ and $p=\frac12$.
* **Mean bound.** Write $\bar z=p_\sigma m_\sigma+\int_{\mathcal N_t^c}z_w\,d\Pi_\sigma$. Then $\bar z-m_\sigma=-(1-p_\sigma)m_\sigma+\int_{\mathcal N_t^c}z_w\,d\Pi_\sigma$.
* **Size of each term.** By Lemma 3.1(a) and $\kappa_N\le F_{c,S}$, $|z_w(x)|\le\sqrt{F_{c,S}(w)}$. Hence $|m_\sigma(x)|\le\sqrt{F^*+t}$ and the tail integral is at most $T_\sigma$ in absolute value.
* **Clipped version.** The clipped bound is the same computation with $|{\rm clip}|\le1$.
* **Jensen.** The last claim is Jensen's inequality for the conditional law on the compact set $\mathcal N_t$. $\square$

**Remark 3.4 (uniformity in the sample).** The bound (3.2) depends on $S$ only through $F^*$ and $\delta$. Since $F^*\le F_{c,S}(0)$, $F^*\le n/c$ whenever $|y_i|\le1$.

* *Finitely many samples.* If the set of possible samples is finite, as in the cube example where there are $(2M)^n$ samples, then for each $\epsilon'>0$ some $\sigma_0>0$ makes $1-p_\sigma\le\epsilon'$ and $T_\sigma\le\epsilon'$ for all $\sigma<\sigma_0$ and all samples.
* *Compact inputs.* The same holds for inputs in a compact $X\subseteq[-1,1]^d$ with labels in $[-1,1]$. All minimizers lie in $\{\kappa_N\le n/c\}$. The map $(w,x)\mapsto z_w(x)$ is uniformly continuous on the compact set $\big(\{\kappa_N\le n/c\}+\bar B(0,1)\big)\times[-1,1]^d$. Moreover
  $$|F_{c,S}(w)-F_{c,S}(w')|\le|\kappa_N(w)-\kappa_N(w')|+\tfrac1c\sum_i|z_w(x_i)-z_{w'}(x_i)|\big(|z_w(x_i)|+|z_{w'}(x_i)|+2\big).$$
  So the family $\{F_{c,S}\}_S$ is equicontinuous there, and one radius $\delta\le1$ serves all samples.

---

## 4. Claim A: the excess-risk lower bound on the cube

### 4.1 Three lemmas

**Lemma 4.1 (atoms and the residual budget).** Let the inputs take values in a finite set $\mathcal X$, and let $|y_i|\le1$.

* (a) For every $f:\mathcal X\to\mathbb R$, $\displaystyle\sum_{i=1}^n\big(f(x_i)-y_i\big)^2=\Delta(f)+W$.
* (b) Fix $c,t>0$ and a width $N$. Suppose some $w_0$ of width $N$ has $\kappa_N(w_0)\le K$ and $\max_{x\in\mathcal S}|z_{w_0}(x)-\bar y_x|\le a$. Then every $w\in\mathcal N_t(S)$ of the same width satisfies
  $$c\,\kappa_N(w)+\Delta(z_w)\le c\,(K+t)+na^2 . \tag{4.1}$$
  In particular $\Delta(z_w)\le c(K+t)+na^2$ and $\kappa_N(w)\le K+t+na^2/c$.
* (c) $\Delta({\rm clip}\circ f)\le\Delta(f)$ for every $f$.

*Proof.*

(a) For $x\in\mathcal S$, $\sum_{i:x_i=x}(f(x)-y_i)^2=k_x(f(x)-\bar y_x)^2+\sum_{i:x_i=x}(y_i-\bar y_x)^2$, because $\sum_{i:x_i=x}(y_i-\bar y_x)=0$. Sum over $x\in\mathcal S$.

(b) By (a), $F_{c,S}(w)=\kappa_N(w)+\frac1c\big(\Delta(z_w)+W\big)$ for every $w$. Also $\Delta(z_{w_0})\le\sum_xk_xa^2=na^2$. Hence
$$\kappa_N(w)+\tfrac1c\big(\Delta(z_w)+W\big)=F_{c,S}(w)\le F_{c,S}(w_0)+t\le K+\tfrac1c\big(na^2+W\big)+t.$$
Cancel $W/c$ and multiply by $c$.

(c) Each $\bar y_x$ lies in $[-1,1]$. Clipping is the metric projection onto $[-1,1]$, so $|{\rm clip}(u)-b|\le|u-b|$ for every $b\in[-1,1]$. $\square$

Equation (4.1) is the corrected form of the brief's mechanism. The within-atom constant enters $F_c$ as $W/c$. The residual budget must include the memorizer's own residual $na^2$ as well as $c(K_{\rm mem}+t)$.

**Lemma 4.2 (test loss on the cube).**

* (a) For every $f:\mathcal C_d\to\mathbb R$, $L_{D_d}(f)=1+\frac1M\sum_{x\in\mathcal C_d}f(x)^2$. In particular the zero network attains the Bayes risk $\inf_fL_{D_d}(f)=1$.
* (b) Let $g:\mathcal S\to\mathbb R$ satisfy $\Delta(g)\le B$, and let $f:\mathcal C_d\to\mathbb R$ satisfy $\max_{x\in\mathcal S}|f(x)-g(x)|\le\varsigma$. Then
  $$\Big(\sum_{x\in\mathcal S}f(x)^2\Big)^{1/2}\ge\sqrt Q-\sqrt B-\sqrt{|\mathcal S|}\,\varsigma,\qquad L_{D_d}(f)\ge1+\frac1M\Big(\sqrt Q-\sqrt B-\sqrt{|\mathcal S|}\,\varsigma\Big)_+^2 . \tag{4.2}$$

*Proof.*

(a) $\mathbb E[(f(x)-y)^2\mid x]=f(x)^2-2f(x)\mathbb E[y\mid x]+\mathbb E[y^2\mid x]=f(x)^2+1$.

(b) Since $k_x\ge1$ on $\mathcal S$, $\sum_{\mathcal S}(g-\bar y)^2\le\Delta(g)\le B$. Minkowski's inequality in $\mathbb R^{\mathcal S}$ gives $\|f\|\ge\|\bar y\|-\|g-\bar y\|-\|f-g\|\ge\sqrt Q-\sqrt B-\sqrt{|\mathcal S|}\,\varsigma$. Then use (a) and $\sum_{\mathcal C_d}f^2\ge\sum_{\mathcal S}f^2$. $\square$

**Lemma 4.3 (the captured noise $Q$).** Let $S\sim D_d^{\otimes n}$.

* (a) $\mathbb EQ=M\beta_n$.
* (b) For every $u\ge0$, $\Pr[Q\le M\beta_n-u]\le e^{-u^2/(2n)}$.
* (c) $|\beta_n-\beta(n/M)|\le n/M^2$.
* (d) $\beta(\lambda)=e^{-\lambda}\int_0^\lambda\frac{e^u-1}{u}\,du=e^{-\lambda}\big({\rm Ei}(\lambda)-\gamma_E-\log\lambda\big)$. The function $\beta$ is $1$-Lipschitz on $(0,\infty)$, with $\beta(\lambda)\sim\lambda$ as $\lambda\to0$ and $\beta(\lambda)\sim1/\lambda$ as $\lambda\to\infty$. It has a unique maximizer $\lambda^*$, characterized by $\beta(\lambda^*)=(1-e^{-\lambda^*})/\lambda^*$. Numerically $\beta(1)=0.484829$, $\lambda^*=1.50286$ and $\beta(\lambda^*)=0.517351$ (see §9).

*Proof.*

(a) Condition on the inputs. If $k_x=k\ge1$, then $\bar y_x$ is the mean of $k$ i.i.d. uniform signs, so $\mathbb E[\bar y_x^2\mid\text{inputs}]=1/k$. Hence $\mathbb E[Q\mid\text{inputs}]=\sum_x\mathbf 1[k_x\ge1]/k_x$, and each $k_x\sim{\rm Bin}(n,1/M)$.

(b) $Q$ is a function of the $n$ independent pairs $(x_i,y_i)$. Replacing one pair changes the terms of at most two atoms. Each term $\bar y_x^2\mathbf 1[k_x\ge1]$ lies in $[0,1]$, so $Q$ changes by at most $2$. McDiarmid's inequality gives $\Pr[Q-\mathbb EQ\le-u]\le\exp(-2u^2/(4n))$.

(c) Le Cam's inequality gives $d_{\rm TV}\big({\rm Bin}(n,p),{\rm Poi}(np)\big)\le np^2$. The map $k\mapsto\mathbf 1[k\ge1]/k$ takes values in $[0,1]$.

(d) The integral formula is $\sum_{k\ge1}\frac{\lambda^k}{k\,k!}=\int_0^\lambda\sum_{k\ge1}\frac{u^{k-1}}{k!}du$.

* *Derivative.* $\beta'=h-\beta$ with $h(\lambda)=\frac{1-e^{-\lambda}}{\lambda}=\int_0^1e^{-\lambda s}ds\in(0,1]$. Since $0\le\beta\le\Pr[K\ge1]\le1$, we get $|\beta'|\le1$.
* *Asymptotics.* $\int_0^\lambda\frac{e^u-1}udu=\lambda+O(\lambda^2)$ as $\lambda\to0$, and $\sim e^\lambda/\lambda$ as $\lambda\to\infty$ by l'Hôpital.
* *Unique maximizer.* $h$ is strictly decreasing. At any critical point $\beta''=h'-\beta'=h'<0$, so every critical point is a strict local maximum. A continuous function cannot have two strict local maxima without an interior local minimum between them, and that minimum would be a critical point. Hence there is at most one critical point. One exists because $\beta>0$ on $(0,\infty)$ and $\beta(0^+)=\beta(\infty)=0$. $\square$

At $\lambda=1$, $1+\beta(1)$ is the classical risk $1+1/k$ of predicting by the mean of the $k$ training labels at the test atom, averaged over the Poisson count. This is Cover's nearest-neighbour formula $R^*(1+1/k)$, as noted in `../research-notes/literature.md`.

### 4.2 The theorem

**Theorem 4.4 (Claim A, non-asymptotic).** Fix $H\ge2$, $d\ge1$, $n\ge1$, $c>0$, $t>0$, $a\in(0,1]$ and $\delta\in(0,1)$. Put $M=2^d$, $\lambda=n/M$, $s=\min\{n,M\}$, $K_{\rm mem}=K_{\rm mem}(d,s,a,H)$, $N_0=N_0(d,s,a)$ (Lemma 2.1), and
$$\epsilon=\frac{c\,(K_{\rm mem}+t)}{M}+\lambda a^2,\qquad \underline e=\Big(\sqrt{\big(\beta_n-\sqrt{2\lambda\log(1/\delta)/M}\big)_+}-\sqrt\epsilon\Big)_+^2 . \tag{4.3}$$
Let $S\sim D_d^{\otimes n}$. The event $\mathcal E=\{Q\ge M\beta_n-\sqrt{2n\log(1/\delta)}\}$ depends only on $S$ and has probability at least $1-\delta$. On $\mathcal E$, the following hold simultaneously for every width $N\ge N_0$.

* (i) **Near-minimizers.** Every $w\in\mathcal N_t(S)$ satisfies $L_{D_d}(z_w)\ge1+\underline e$ and $L_{D_d}({\rm clip}\circ z_w)\ge1+\underline e$.
* (ii) **Gibbs.** Let $p_\sigma=\Pi_\sigma(\mathcal N_t)$. Then $\Pi_\sigma\{w:\min(L_{D_d}(z_w),L_{D_d}({\rm clip}\circ z_w))\ge1+\underline e\}\ge p_\sigma\to1$ as $\sigma\to0$. Hence $\liminf_{\sigma\to0}\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\ge1+\underline e$, and likewise for ${\rm clip}\circ z_w$.
* (iii) **Posterior means.** Let $f_\sigma$ be one of $\bar z_{\Pi_\sigma}$, ${\rm clip}\circ\bar z_{\Pi_\sigma}$ or $\int{\rm clip}(z_w)\,d\Pi_\sigma$. Then
  $$L_{D_d}(f_\sigma)\ge1+\Big(\sqrt{Q/M}-\sqrt\epsilon-\varsigma_\sigma\Big)_+^2,$$
  with $\varsigma_\sigma=(1-p_\sigma)\sqrt{n/c+t}+T_\sigma$ for the first two and $\varsigma_\sigma=2(1-p_\sigma)$ for the third. Since $\varsigma_\sigma\to0$, $\liminf_{\sigma\to0}L_{D_d}(f_\sigma)\ge1+\underline e$.
* (iv) **Uniformity.** For every $\epsilon'>0$ there is $\sigma_0=\sigma_0(d,n,N,H,c,t,\epsilon')>0$ such that for all $\sigma\in(0,\sigma_0)$ and all samples in $\mathcal E$, the posterior probability in (ii) is at least $1-\epsilon'$ and $L_{D_d}(f_\sigma)\ge1+\underline e-\epsilon'$ in (iii).

Moreover $L_{D_d}(0)=1=\inf_fL_{D_d}(f)$.

*Proof.*

* **The event.** Lemma 4.3(b) with $u=\sqrt{2n\log(1/\delta)}$ gives $\Pr(\mathcal E)\ge1-\delta$. On $\mathcal E$, $Q/M\ge\beta_n-\sqrt{2\lambda\log(1/\delta)/M}$, because $\sqrt{2n\log(1/\delta)}/M=\sqrt{2\lambda\log(1/\delta)/M}$.
* **Comparator.** Let $r=\bar y\,\mathbf 1_{\mathcal S}$. Then $|r|\le1$ and $\sum_xr(x)^2=Q\le|\mathcal S|\le s$. Lemma 2.1 gives, at every $N\ge N_0$, a $w_0$ with $\kappa_N(w_0)\le K_{\rm mem}$ and $|z_{w_0}-r|<a$ on $\mathcal C_d$; in particular $|z_{w_0}(x)-\bar y_x|<a$ on $\mathcal S$.
* **(i).** Lemma 4.1(b), (c) give $\Delta(z_w)\le c(K_{\rm mem}+t)+na^2=M\epsilon$ and $\Delta({\rm clip}\circ z_w)\le M\epsilon$. Lemma 4.2(b) with $g=f$, $\varsigma=0$ and $B=M\epsilon$ gives $L_{D_d}\ge1+(\sqrt{Q/M}-\sqrt\epsilon)_+^2$. On $\mathcal E$ this is at least $1+\underline e$, by monotonicity in $Q$.
* **(ii).** By (i), $\mathcal N_t$ is contained in the event in question, and $p_\sigma\to1$ by Corollary 3.3. Since $L_{D_d}\ge0$, $\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\ge p_\sigma(1+\underline e)$.
* **(iii).** The functional $\Delta$ is convex in the vector $(f(x))_{x\in\mathcal S}$. By Corollary 3.3 (Jensen), $\Delta(m_\sigma)\le\sup_{\mathcal N_t}\Delta(z_w)\le M\epsilon$ and $\Delta(m^{\rm cl}_\sigma)\le\sup_{\mathcal N_t}\Delta({\rm clip}\circ z_w)\le M\epsilon$. Lemma 4.1(c) adds $\Delta({\rm clip}\circ m_\sigma)\le M\epsilon$.
  * By (3.3) and $F^*\le F_{c,S}(0)=n/c$: $\max_x|\bar z_{\Pi_\sigma}(x)-m_\sigma(x)|\le\varsigma_\sigma$. Since clipping is $1$-Lipschitz, also $\max_x|{\rm clip}\,\bar z_{\Pi_\sigma}(x)-{\rm clip}\,m_\sigma(x)|\le\varsigma_\sigma$, and $\max_x|\int{\rm clip}(z_w(x))\,d\Pi_\sigma-m^{\rm cl}_\sigma(x)|\le2(1-p_\sigma)$.
  * Lemma 4.2(b) with $|\mathcal S|\le M$ gives the displayed bound.
* **(iv).** There are finitely many samples, so Remark 3.4 applies. $\square$

### 4.3 Asymptotic form, general $c$, and explicit $o(1)$ terms

**Corollary 4.5.** Fix $H\ge2$, $\lambda\in(0,\infty)$ and $t\in(0,1]$. Let $n=n_d$ be integers with $\lambda_d:=n_d/2^d\to\lambda$, and let $c=c_d>0$ satisfy
$$c_d\big(d^2\log^2(d+1)+(dn_d)^{1/H}\big)=o(n_d)\qquad(d\to\infty). \tag{4.4}$$
Put $a_d=(\max\{c_d,1\}/2^d)^{1/3}$ and $\delta_d=\exp(-2^{d/2})$. Then (i)–(iv) of Theorem 4.4 hold with probability at least $1-\exp(-2^{d/2})$, at every width $N\ge N_0(d,\min\{n_d,2^d\},a_d)$. That threshold is at most $45\,d(d+1)\,2^{5d/3}=O(d^2n_d^{5/3})$. The bound satisfies
$$\underline e_d\ \ge\ \Big(\sqrt{\big(\beta(\lambda_d)-\lambda_d2^{-d}-\sqrt{2\lambda_d}\,2^{-d/4}\big)_+}-\sqrt{\epsilon_d}\Big)_+^2\ \longrightarrow\ \beta(\lambda),$$
$$\epsilon_d=\frac{c_d\big(d(d+1)\alpha_d^2+t\big)}{2^d}+\frac{(H+1)\,c_d\big((8dn_d)^{1/H}+\frac{9}{2a_d}\big)}{2^d}+\lambda_da_d^2\ \longrightarrow\ 0 .$$
For $c_d\equiv1$ and $n_d=2^d$, the limit is $\beta(1)=0.4848$. Since $n_d\asymp2^d$ and $d\asymp\log_2 n_d$, condition (4.4) is equivalent for large $d$ to $c_d=o\big(n_d^{1-1/H}d^{-1/H}\big)$, which is the brief's condition $c\,K_{\rm mem}=o(n)$.

*Proof.*

* **Threshold.** $N_0\le\frac{64\log 2\,d(d+1)2^d}{a_d^2}+1\le 44.4\,d(d+1)2^{5d/3}+1$, using $a_d^{-2}\le2^{2d/3}$.
* **Slope bound.** $\alpha_d=0.866\ldots+\frac14\log d\le1.5\log(d+1)$ for $d\ge1$, so $d(d+1)\alpha_d^2\le4.5\,d^2\log^2(d+1)$.
* **Each term of $\epsilon_d$ tends to $0$.**
  * The first term tends to $0$ by (4.4), since $n_d\asymp2^d$. Condition (4.4) also implies $c_d=o(2^d)$.
  * Since $s\le n_d$, the $(8dn_d)^{1/H}$ term tends to $0$ by (4.4).
  * $\frac{9(H+1)c_d}{2a_d2^d}\le\frac{9(H+1)}2\max\{c_d,1\}^{2/3}2^{-2d/3}\to0$.
  * $\lambda_da_d^2=\lambda_d(\max\{c_d,1\}/2^d)^{2/3}\to0$.
* **Concentration term.** $\sqrt{2\lambda_d\log(1/\delta_d)/2^d}=\sqrt{2\lambda_d}\,2^{-d/4}$.
* **Poisson limit.** Lemma 4.3(c) gives $\beta_{n_d}\ge\beta(\lambda_d)-\lambda_d2^{-d}$, and $|\beta(\lambda_d)-\beta(\lambda)|\le|\lambda_d-\lambda|\to0$.
* **Equivalent form of (4.4).** The ratio of $n^{1-1/H}d^{-1/H}$ to $n/(d^2\log^2d)$ is $n^{-1/H}d^{2-1/H}\log^2d\to0$, because $n$ is exponential in $d$. So the second constraint in (4.4) is the binding one. $\square$

**Corollary 4.6 (general label laws).** Let $D$ be a law on $\mathcal C_d\times[-1,1]$ with uniform $x$-marginal, regression function $\eta(x)=\mathbb E[y\mid x]$, and $V(x)={\rm Var}(y\mid x)\ge v_0>0$. Then
$$L_D(f)=L_D(\eta)+\frac1M\sum_x\big(f(x)-\eta(x)\big)^2,\qquad L_D(\eta)=\frac1M\sum_xV(x)\ \text{ is the Bayes risk.}$$
Put $Q_\eta=\sum_{x\in\mathcal S}(\bar y_x-\eta(x))^2$. The event $\mathcal E_\eta=\{Q_\eta\ge v_0M\beta_n-\sqrt{32n\log(1/\delta)}\}$ has probability at least $1-\delta$. On $\mathcal E_\eta$, all conclusions of Theorem 4.4 hold with $1+\underline e$ replaced by $L_D(\eta)+\underline e_{v_0}$, where
$$\underline e_{v_0}=\Big(\sqrt{\big(v_0\beta_n-\sqrt{32\lambda\log(1/\delta)/M}\big)_+}-\sqrt\epsilon\Big)_+^2 .$$
Under the hypotheses of Corollary 4.5, $\underline e_{v_0}\to v_0\beta(\lambda)$. If $\eta$ is computed by a depth-$L$ network $g$, the excess over the competitor $g$ is therefore at least $v_0\beta(\lambda)-o(1)$. An example is constant $\eta$ (Proposition 6.3 gives a width-one network).

*Proof.*

* **Risk identity.** The identity for $L_D$ is the bias–variance decomposition.
* **Unchanged steps.** Lemma 4.1 is unchanged, since $|\bar y_x|\le1$. Lemma 2.1 applies to $r=\bar y\mathbf 1_{\mathcal S}$ as before.
* **Minkowski step.** Lemma 4.2(b) is replaced by $\big(\sum_{\mathcal S}(f-\eta)^2\big)^{1/2}\ge\sqrt{Q_\eta}-\sqrt B-\sqrt{|\mathcal S|}\,\varsigma_\sigma$, by the same Minkowski argument.
* **Mean of $Q_\eta$.** Given the inputs, the labels at $x$ are i.i.d. with mean $\eta(x)$ and variance $V(x)$. So $\mathbb E[Q_\eta\mid\text{inputs}]=\sum_{x\in\mathcal S}V(x)/k_x\ge v_0\sum_x\mathbf 1[k_x\ge1]/k_x$, and $\mathbb EQ_\eta\ge v_0M\beta_n$.
* **Concentration.** Each term of $Q_\eta$ lies in $[0,4]$, and replacing a pair affects at most two terms. McDiarmid's inequality with differences at most $8$ gives $\Pr[Q_\eta\le\mathbb EQ_\eta-u]\le e^{-u^2/(32n)}$.
* **Clipping and posterior means.** Clipping is handled by Lemma 4.1(c), and the posterior-mean argument is identical. $\square$

### 4.4 Remarks

**Remark 4.7 (explicit sizes).** Table 4.1 lists the certified excess $\underline e$ of (4.3) for $c=1$, $t=1$ and $\delta=0.01$, with $a$ optimized on a grid. It comes from `A_scripts/bounds_table.py`.

| $H$ | $d$ | $\underline e$ at $\lambda=1$ ($\beta_n=0.4848$) | $\underline e$ at $\lambda=1.5$ ($\beta_n=0.5174$) | optimizing $a$ | $K_{\rm mem}$ |
|---|---|---|---|---|---|
| 2 | 20 | 0.249 | 0.272 | $3.5\cdot10^{-4}$ | $4.0\cdot10^4$ |
| 2 | 30 | 0.434 | 0.464 | $8.9\cdot10^{-6}$ | $1.5\cdot10^6$ |
| 2 | 40 | 0.475 | 0.507 | $2.5\cdot10^{-7}$ | $5.6\cdot10^7$ |
| 2 | 60 | 0.4845 | 0.5170 | $2.8\cdot10^{-10}$ | $7.1\cdot10^{10}$ |
| 3 | 20 | 0.406 | 0.435 | $8.4\cdot10^{-3}$ | $3.3\cdot10^3$ |
| 3 | 30 | 0.478 | 0.510 | $7.1\cdot10^{-4}$ | $2.8\cdot10^4$ |
| 3 | 40 | 0.4841 | 0.5166 | $6.7\cdot10^{-5}$ | $2.9\cdot10^5$ |
| 4 | 30 | 0.479 | 0.511 | $2.2\cdot10^{-3}$ | $1.3\cdot10^4$ |

The bound is within $0.01$ of $\beta(\lambda)$ from $d\approx40$ at $H=2$ and from $d\approx30$ at $H=3$.

The width threshold $N_0$ at the optimizing $a$ is polynomial in $n$ but astronomically large: $10^{14}$ to $10^{42}$ in the table. With a fixed accuracy $a$ instead, $N_0=O(d^2n/a^2)=O(n\log^2n/a^2)$ and $\underline e\to\big(\sqrt{\beta(\lambda)}-a\sqrt\lambda\big)_+^2$. For example, $a=0.1$ and $\lambda=1$ give $0.356$.

The constants also matter for the admissible $c$. The largest $c$ certifying $\underline e\ge\beta_n/2$ is about $28$ at $(H,d)=(2,30)$ and $1.6\cdot10^3$ at $(3,30)$, compared with $n^{1-1/H}d^{-1/H}=6.0\cdot10^3$ and $3.4\cdot10^5$. The asymptotic condition (4.4) is unaffected.

**Remark 4.8 (the constant is attained by the comparator).** The comparator satisfies $|z_{w_0}-\bar y\mathbf 1_{\mathcal S}|<a$ on all of $\mathcal C_d$. Hence $L_{D_d}(z_{w_0})\le1+\frac1M(\sqrt Q+a\sqrt M)^2=1+Q/M+O(a)$, and $1+\beta(\lambda)$ is the exact limiting risk of the memorizer. Near-minimizers can be worse, because they may also be nonzero on unseen atoms. In the $d=8$ experiments of §9, unseen atoms contribute $0.11$ to $0.17$ of the excess.

**Remark 4.9 (consistency with the repository).** SP$_1$ is the learner of `NNG/works-in-progress/slt-likelihood/README.md` §2, which proves polynomial sample bounds for **clean** labels at every width. Its proof uses the residual budget $c(E_*+1)=O(1)$. With label noise, every function, the teacher included, pays training residual $\approx n\,\mathbb E\,{\rm Var}(y\mid x)$. Theorem 4.4 shows that the failure of that proof is a failure of the learner: memorization costs energy $o(n)$ and removes residual $\Theta(n)$.

The noisy-interpolation note bounds clean classification error under a small corruption rate, with distinct inputs and global margin conditioning. At the fair-coin noise level its bound is vacuous, so there is no conflict.

---

## 5. Why Claim A refutes polynomial sample bounds

### 5.1 The property refuted

Write the brief's §1 property for a learner family $\mathsf A$ at depth $L$ as follows.

> **(P$_L$)** There is a polynomial $\mathsf p$ with the following property. For every $d\ge1$, every law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, every competitor $g$ of depth $L$, width $m$ and weights bounded by $B$, every learner width $N\ge m$, all $\varepsilon,\delta\in(0,1)$, and all $n\ge\mathsf p(d,m,B,1/\varepsilon,\log(1/\delta))$:
> $$\Pr\big[L_D(\mathsf A_n)\le L_D(g)+\varepsilon\big]\ge1-\delta.$$

For SP$_c$ the output $\mathsf A_n$ must be specified. We allow the most lenient readings.

* **(R1)** A Gibbs draw from $\Pi^c_{\sigma,S}$, with probability taken over the sample and the draw. The property is required for all $\sigma\in(0,\sigma_0)$, where $\sigma_0>0$ may depend on $d,n,N,D,g,\varepsilon,\delta$. This matches the repository's strong-prior theorems, whose scale thresholds depend on width and sample size.
* **(R2)** The same, with the output one of $\bar z_{\Pi_\sigma}$, ${\rm clip}\circ\bar z_{\Pi_\sigma}$ or $\int{\rm clip}(z_w)\,d\Pi_\sigma$.
* **(R3)** Any point of $\mathcal N_t(S)$, for a fixed $t>0$, chosen by any rule. No measurability is needed.

**Proposition 5.1.** Fix $L\ge3$. Let $c>0$ be fixed, or let $c=c(n)$ be such that $c_d:=c(2^d)$ satisfies (4.4) with $n_d=2^d$. Then SP$_c$ does not have property (P$_L$) under any of the readings (R1)–(R3). More precisely, take the competitor $g\equiv0$, any $\varepsilon\in(0,\beta(1))$ and any $\delta\in(0,1)$. For all sufficiently large $d$, at $n=2^d$ and at every learner width $N\ge N_0(d,2^d,a_d)$, the probability in (P$_L$) is below $1-\delta$ for all sufficiently small $\sigma$. In fact, for every $\epsilon'>0$ it is at most $e^{-2^{d/2}}+\epsilon'$ once $\sigma$ is below a threshold depending on $(d,N,c,t,\epsilon')$.

*Proof.*

* **Setup.** Suppose $\mathsf p$ exists. Take the competitor $g\equiv0$: width $m=1$ and all weights $0$, so the bound $B=1$ holds. Fix $\varepsilon\in(0,\beta(1))$ and $\delta\in(0,1)$, and put $\gamma=(\beta(1)-\varepsilon)/2>0$. Then $q(d)=\mathsf p(d,1,1,1/\varepsilon,\log(1/\delta))$ is a polynomial in $d$, so $2^d\ge q(d)$ for all $d\ge d_1$.
* **What (P$_L$) would give.** For such $d$, (P$_L$) applies to $D=D_d$ and $n=2^d$, at every learner width. In particular it applies at every $N\ge N_0(d,2^d,a_d)$ of Corollary 4.5, where it requires $\Pr[L_{D_d}(\mathsf A_n)\le1+\varepsilon]\ge1-\delta$.
* **What Corollary 4.5 gives.** With $\lambda=1$, $\underline e_d\to\beta(1)$, so there is $d_2$ such that for $d\ge d_2$ both $\underline e_d\ge\varepsilon+\gamma$ and $e^{-2^{d/2}}<\frac{1-\delta}2$ hold. Fix $d\ge\max\{d_1,d_2\}$. The event $\mathcal E$ has probability at least $1-e^{-2^{d/2}}$.
* **(R3).** On $\mathcal E$ every point of $\mathcal N_t(S)$ has $L_{D_d}\ge1+\varepsilon+\gamma>1+\varepsilon=L_{D_d}(g)+\varepsilon$. So $\Pr[L_{D_d}(\mathsf A_n)\le L_{D_d}(g)+\varepsilon]\le e^{-2^{d/2}}<1-\delta$.
* **(R1).** Apply Theorem 4.4(iv) with $\epsilon'=\frac{1-\delta}2$. For $\sigma<\sigma_0'$,
  $$\Pr[L_{D_d}(\mathsf A_n)\le1+\varepsilon]\le\Pr(\mathcal E^c)+\sup_{S\in\mathcal E}\Pi_{\sigma,S}(\mathcal N_t^c)<\tfrac{1-\delta}2+\tfrac{1-\delta}2=1-\delta .$$
* **(R2).** Apply Theorem 4.4(iv) with $\epsilon'=\gamma/2$. For $\sigma<\sigma_0'$, on $\mathcal E$, $L_{D_d}(f_\sigma)\ge1+\varepsilon+\gamma/2>1+\varepsilon$. So the probability is at most $\Pr(\mathcal E^c)<1-\delta$.
* **Conclusion.** In each case (P$_L$) would require probability at least $1-\delta$ for all small $\sigma$, which fails. The same estimates with an arbitrary $\epsilon'>0$ give the bound $e^{-2^{d/2}}+\epsilon'$. $\square$

### 5.2 Discussion

1. **Why $n=2^d$ suffices.** (P$_L$) asserts the bound for **all** $n$ above a threshold polynomial in $d$, with $m,B,\varepsilon,\delta$ fixed. Eventually $2^d$ exceeds every polynomial, whatever its degree and whether or not its exponents are fractional. So the threshold is passed at $n=2^d$, where Theorem 4.4 applies. The failure lives at the scale $n\asymp|\mathcal C_d|$, where atoms are seen a Poisson number of times. For $n\gg2^d$ the excess $\beta(\lambda)\sim1/\lambda$ decays, so the learner is eventually consistent on $D_d$, but only after exponentially many samples.
2. **The competitor is trivial.** $g\equiv0$ has width one and zero weights, so this is not an approximation failure. The learner is worse than the trivial predictor, which is Bayes-optimal here, by a constant. The brief also reads the conjecture as "test loss at most the minimum over networks with width and weights at most $n^\alpha$, plus $o(1)$". That reading is refuted for every $\alpha$ and every $o(1)$, because $g\equiv0$ belongs to every such class and the excess is $\Omega(1)$. Bounding the competitors' weights changes nothing.
3. **Learner width (scope).** The failure holds at every $N\ge N_0={\rm poly}(n)$. It therefore refutes the width-uniform formulation ("every learner width $N\ge m$", brief §1). It also refutes any formulation that admits some learner width at least $N_0$. With a fixed accuracy $a$, $N_0=O(n\log^2n/a^2)$ already gives excess at least $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)^2-o(1)$ (Remark 4.7). It does **not** address learners whose width is too small to memorize. For instance, at $N\le n^{1/2-\epsilon}$ and depth $L\ge3$ the parameter count is $o(n)$. Such formulations are outside the scope of this section. `../research-notes/red-team.md` (Proposition 6.1) argues a positive oracle inequality in that regime; I have not checked it.
4. **Depth.** The proof needs $L\ge3$. For depth two see Remark 2.5 and §10.
5. **Range of likelihood scalings.** The failure holds for every $c=o(n^{1-1/H}d^{-1/H})$ along $n\asymp2^d$. This includes the clean-label scaling $c=1$ of the slt-likelihood theorem. By Proposition 8.3, the memorization mechanism switches off once $c\ge n^{1-\vartheta}$ with $\vartheta<1/H$.

---

## 6. Variants

### 6.1 SP$_c$ with sampling without replacement

Let $1\le n\le M$. The inputs are $n$ distinct points of $\mathcal C_d$, for example a uniformly random ordered $n$-subset; any rule producing distinct points works. Given the inputs, the labels are independent, each drawn from the conditional law of $D$. The test law $D$ has uniform $x$-marginal.

**Proposition 6.1.** Fix $H\ge2$, $c,t>0$ and $a\in(0,1]$, and put $\epsilon'=\frac{c\,(K_{\rm mem}(d,n,a,H)+t)}{n}+a^2$. Let $N\ge N_0(d,n,a)$.

* (a) **Fair labels.** With probability one, every $w\in\mathcal N_t(S)$ satisfies $L_{D_d}(z_w)\ge1+\frac nM\big(1-\sqrt{\epsilon'}\big)_+^2$, and so does ${\rm clip}\circ z_w$. The Gibbs and posterior-mean statements (ii)–(iv) of Theorem 4.4 hold with this bound. At $n=M$, if $cK_{\rm mem}=o(M)$ and $a=a_d\to0$, every near-minimizer, the Gibbs draw and the posterior mean have test MSE tending to $2$, against a Bayes risk of $1$.
* (b) **General labels**, with $y\in[-1,1]$ and $V(x)\ge v_0$. With probability at least $1-\delta$, the same holds with the bound $L_D(\eta)+\Big(\sqrt{\big(\lambda v_0-\sqrt{8\lambda\log(1/\delta)/M}\big)_+}-\sqrt{\lambda\epsilon'}\Big)_+^2$, where $\lambda=n/M$.

*Proof.*

* **Atom structure.** All $k_x\in\{0,1\}$. So $\bar y_{x_i}=y_i$, $W=0$, $\Delta(f)=\sum_i(f(x_i)-y_i)^2$, and for fair labels $Q=n$ deterministically.
* **(a).** Lemma 2.1 applies to $r(x_i)=y_i$ with $r=0$ elsewhere, since $\sum r^2\le n$. With Lemma 4.1(b), $\Delta(z_w)\le c(K_{\rm mem}+t)+na^2=n\epsilon'$. Lemma 4.2(b) gives $L_{D_d}\ge1+\frac1M(\sqrt n-\sqrt{n\epsilon'})_+^2$. Statements (ii)–(iv) follow exactly as in Theorem 4.4.
* **(b).** $Q_\eta=\sum_i(y_i-\eta(x_i))^2$. Given the inputs its terms are independent, lie in $[0,4]$, and have means $V(x_i)\ge v_0$. Hoeffding's inequality gives $\Pr[Q_\eta\le nv_0-u]\le e^{-u^2/(8n)}$. Take $u=\sqrt{8n\log(1/\delta)}$, then argue as in Corollary 4.6. $\square$

### 6.2 TUBE$_\rho$

**Lemma 6.2 (a feasible zero network forces the zero predictor).** Let $\mu=\mu_\sigma$ at a fixed width $N$, and let the sample satisfy $\max_i|y_i|<\rho$. Then $0\in U_{\rho,S}$, and as $\sigma\to0$:

* $\mathbb E_{\Pi^{\rm tube}}\kappa_N\to0$;
* $\sup_{x\in\mathbb R^d}|\bar z_{\Pi^{\rm tube}}(x)|\to0$;
* for every law $D$ on $[-1,1]^d\times[-1,1]$, $\mathbb E_{\Pi^{\rm tube}}|L_D(z_w)-L_D(0)|\to0$ and $L_D(\bar z_{\Pi^{\rm tube}})\to L_D(0)$. The same holds for the clipped versions.

*Proof.*

* **Feasibility.** $z_0\equiv0$ satisfies the strict constraints, and $U_{\rho,S}$ is open. Since $\kappa_N$ is a positive definite quadratic form, $\{\kappa_N<r_U\}\subseteq U_{\rho,S}$ for some $r_U>0$.
* **Prior mass of the tube.** Under $\mu_\sigma$, $\kappa_N$ has the law of $\sigma^2\chi^2_P$, so $\mathbb E_{\mu_\sigma}\kappa_N=P\sigma^2$. By Markov's inequality, $\mu_\sigma(U_{\rho,S})\ge1-P\sigma^2/r_U\to1$.
* **Energy.** $\mathbb E_{\Pi^{\rm tube}}\kappa_N\le P\sigma^2/\mu_\sigma(U_{\rho,S})\to0$.
* **Outputs and risks.** By Lemma 3.1(a), $|z_w(x)|\le\sqrt{\kappa_N(w)}$, so $\sup_x|\bar z(x)|\le\mathbb E\sqrt{\kappa_N}\le(\mathbb E\kappa_N)^{1/2}\to0$. Also $|L_D(z_w)-L_D(0)|=|\mathbb E[z_w(x)^2-2yz_w(x)]|\le\kappa_N+2\sqrt{\kappa_N}$. Clipping only decreases $|z|$. $\square$

The same collapse happens at finite scale. Take $\mu=\mu_{N,\gamma}$ with $\gamma>0$ fixed and $N\to\infty$. By `NNG/works-in-progress/slt-likelihood/README.md` §3, $\mathbb E_{\mu_{N,\gamma}}z_w(x)^2\le N^{-\gamma}$ for every input. That bound holds conditionally on the hidden weights, since the readout variance is $N^{-\gamma-1}$ and $\sum_ih_i^2\le N$. Suppose $\max_i|y_i|\le\rho-\epsilon_0$.

* The tube contains $\{\max_i|z(x_i)|<\epsilon_0\}$, so $\mu_{N,\gamma}(U)\ge1-nN^{-\gamma}/\epsilon_0^2$.
* Hence $\mathbb E_{\Pi^{\rm tube}}\mathbb E_xz_w(x)^2\le N^{-\gamma}/\mu_{N,\gamma}(U)\to0$, and $|L_D(z_w)-L_D(0)|\le\mathbb E_xz^2+2(\mathbb E_xz^2)^{1/2}$.

So the TUBE bias below is not an artefact of the limit $\sigma\to0$.

**Proposition 6.3 (TUBE: tolerance bias).** Let $\eta_0\in(0,1]$. Each of the following label laws (with any input law on $X\subseteq[-1,1]^d$) gives every sample $\max_i|y_i|<\rho$.

* (a) **$\rho>1$, non-centred noise:** $y\in\{-1,1\}$ with $\Pr[y=1\mid x]=(1+\eta_0)/2$.
* (b) **Any $\rho>0$:** $y=\eta_0+b\varepsilon$ with $\varepsilon$ a fair sign independent of $x$, $b\ge0$ and $\eta_0+b<\min\{\rho,1\}$. With $q=\min\{\rho,1\}$, an example is $\eta_0=q/2$ and $b=q/4$. The case $b=0$ is a **noiseless** constant target.

For every $n$, every sampling scheme (with or without replacement) and every width $N\ge1$, as $\sigma\to0$ the TUBE$_\rho$ Gibbs risk and posterior-mean risk tend to $L_D(0)=L_D(\eta_0)+\eta_0^2$. The constant competitor $g\equiv\eta_0$ has $L_D(g)=L_D(\eta_0)$, the Bayes risk, and is computed by a width-one network with weights at most $2$:

* first-layer weight $1$ on the constant coordinate and $0$ on $x$;
* internal weights $2$;
* readout $\eta_0/\tau_H$, where $\tau_1=\tanh1$ and $\tau_\ell=\tanh(2\tau_{\ell-1})$.

The map $t\mapsto\tanh 2t$ sends $[\tanh1,1]$ into itself, since $\tanh(2\tanh1)=0.909>\tanh1=0.762$. Hence $\tau_H\ge\tanh1$ and $|v|\le1/\tanh1<1.32$. The excess tends to $\eta_0^2$: for example $1/4$ in (a) with $\eta_0=\frac12$, and $q^2/4$ in (b).

*Proof.* Immediate from Lemma 6.2 and the bias–variance identity $L_D(f)=L_D(\eta)+\mathbb E(f-\eta)^2$. $\square$

More generally, when $\rho>1$ every law on $X\times[-1,1]$ gives $\max_i|y_i|\le1<\rho$. By Lemma 6.2 the TUBE$_\rho$ predictor then tends to $0$, with excess $\mathbb E\,\eta(x)^2$ over the Bayes predictor.

TUBE$_\rho$ at a fixed tolerance therefore cannot satisfy an MSE oracle inequality with $\varepsilon<\eta_0^2$, even for clean labels, because the minimum-energy feasible function is $0$. The continuous-domain paper's theorem is consistent with this: it measures error at a larger tolerance $\tau>\rho$ and is not an MSE statement. An MSE-consistent TUBE learner needs $\rho=\rho_n\to0$. Then the next two results apply.

**Lemma 6.4 (conflicting atoms make TUBE$_{\rho\le1}$ undefined).**

* (a) Suppose two sample points share an input and their labels differ by at least $2\rho$. Then $U_{\rho,S}=\emptyset$ and TUBE$_\rho$ is undefined for every prior. For $\pm1$ labels and $\rho\le1$, any atom carrying both labels suffices.
* (b) Let $S\sim D_d^{\otimes n}$ with $n\ge2$. Put $n_1=\lfloor n/2\rfloor$, $n_2=n-n_1$ and $\mu_1=M\big(1-(1-1/M)^{n_1}\big)$. Then
  $$\Pr[\text{no atom carries both labels}]\le\exp\Big(-\frac{n_2\mu_1}{4M}\Big)+\exp\Big(-\frac{\mu_1^2}{2n_1}\Big).$$
  * For $n=\lambda M$ with $\lambda$ fixed, both exponents are at least a positive constant times $M$, namely $\frac\lambda8(1-e^{-\lambda/2})M(1-o(1))$ and $\frac{(1-e^{-\lambda/2})^2}{\lambda}M(1-o(1))$.
  * For $2\le n\le2M$ the bound is at most $\exp(-0.039\,n(n-1)/M)+\exp(-0.19\,n_1)$, which tends to $0$ when $n/\sqrt M\to\infty$.
  * The probability is nonincreasing in $n$: under the natural coupling, adding samples cannot remove a conflict.

*Proof.*

(a) $|z-y|<\rho$ and $|z-y'|<\rho$ imply $|y-y'|<2\rho$.

(b) Condition on the first $n_1$ samples, and let $S_1$ be their set of inputs. If there is already a conflict, we are done. Otherwise each $x\in S_1$ carries a single label $\ell_x$.

* **Second half.** Each later sample independently conflicts with probability $\Pr[x_i\in S_1]\Pr[y_i\ne\ell_{x_i}]=|S_1|/(2M)$. So the conditional probability of no conflict is at most $(1-|S_1|/(2M))^{n_2}\le e^{-n_2|S_1|/(2M)}$.
* **Size of $S_1$.** $|S_1|$ has mean $\mu_1$ and bounded differences $1$ in the $n_1$ inputs. McDiarmid's inequality gives $\Pr[|S_1|<\mu_1/2]\le e^{-\mu_1^2/(2n_1)}$. Splitting on $\{|S_1|\ge\mu_1/2\}$ gives the bound.
* **Numerical forms.** Use $\mu_1\ge M(1-e^{-n_1/M})$. When $n_1\le M$ this gives $\mu_1\ge(1-e^{-1})n_1$, and $n_1n_2\ge n(n-1)/4$.
* **Monotonicity.** Under the natural coupling, the event "no conflict among the first $n$ samples" shrinks as $n$ grows. $\square$

**Proposition 6.5 (TUBE without replacement).** Let $1\le n\le M$ with distinct inputs as in §6.1, and labels $y_i=\eta(x_i)+b\varepsilon_i$. Here the $\varepsilon_i$ are fair signs independent of the inputs, $b>0$ and $|\eta|+b\le1$. Fair labels are the case $\eta=0$, $b=1$. Let $0<\rho<b$ and $N\ge N_0(d,n,\rho/2)$. Then for every prior with full support ($\mu_\sigma$ at **every** $\sigma>0$, or $\mu_{N,\gamma}$), the TUBE$_\rho$ posterior is defined, with no limit needed. Let $f$ be any of: $z_w$ for $w\in U_{\rho,S}$ (every Gibbs draw), the posterior mean, or their clipped versions. Then
$$L_D(f)\ \ge\ L_D(\eta)+\frac nM\,(b-\rho)^2 .$$
For fair labels the excess is at least $\frac nM(1-\rho)^2$, which equals $(1-\rho)^2$ at $n=M$.

*Proof.*

* **Feasibility.** Lemma 2.1 applies to $r(x_i)=y_i$, $r=0$ elsewhere, at accuracy $\rho/2$. It gives $w_0\in U_{\rho,S}$, which is therefore nonempty, open and of positive mass.
* **Gibbs draws.** For $w\in U_{\rho,S}$, $|z_w(x_i)-\eta(x_i)|\ge|y_i-\eta(x_i)|-|z_w(x_i)-y_i|>b-\rho$.
* **Posterior mean.** It lies in the closed interval $[y_i-\rho,y_i+\rho]$, since every draw lies in the open one. So the same bound holds with $\ge$.
* **Clipping.** If $\varepsilon_i=+1$, every value $u$ in that closed interval has $u-\eta(x_i)\ge b-\rho>0$. Then ${\rm clip}(u)-\eta(x_i)=\min\{u,1\}-\eta(x_i)\ge\min\{b-\rho,\,1-\eta(x_i)\}=b-\rho$, because $1-\eta(x_i)\ge b$. The case $\varepsilon_i=-1$ is symmetric.
* **Risk.** Finally $L_D(f)-L_D(\eta)=\frac1M\sum_x(f-\eta)^2\ge\frac nM(b-\rho)^2$. $\square$

**Dependence on $\rho$ (summary).** Table 6.1 collects the cases.

| tolerance | with replacement | without replacement |
|---|---|---|
| $\rho\le1$, fair $\pm1$ labels | undefined with probability $1-e^{-\Omega(M)}$ at $n=\lambda M$ (Lemma 6.4) | for $\rho<1$, excess $\ge\frac nM(1-\rho)^2$ at every $\sigma$ (Proposition 6.5) |
| $\rho>1$, any labels in $[-1,1]$ | posterior collapses to the zero network; excess $\to\frac1M\sum\eta^2$, for example $\eta_0^2$ for non-centred $\pm1$ noise (Lemma 6.2, Proposition 6.3(a)) | same |
| any $\rho>0$, labels with $\lvert y\rvert<\rho$, including noiseless ones | collapse to $0$; excess $\eta_0^2$ (Proposition 6.3(b)) | same |
| $\rho<1$, two-point noise $\eta\pm b$ with $b>\rho$ | undefined once some atom carries both labels (Lemma 6.4(a)) | excess $\ge\frac nM(b-\rho)^2$ (Proposition 6.5) |

The case $\rho=1$ with fair labels and distinct inputs is not resolved here. There $U_{1,S}=\{w:y_iz_w(x_i)>0\ \forall i\}$. This constrains only signs, so the interpolation argument gives no lower bound, and the infimum of $\kappa_N$ over $U_{1,S}$ need not be attained. At $\rho=1$ a failure is nevertheless provided by Proposition 6.3(b) with $q=1$, whose labels $\frac12\pm\frac14$ give excess $\frac14$.

---

## 7. Claim A′: continuous inputs and deterministic labels

Real inputs rarely repeat, and real labels are often deterministic functions of the input. The construction below meets both objections. Each cube vertex is replaced by a tiny corner cube that carries a balanced label pattern. The cubes are so small that every near-minimizer is essentially constant on each of them, by the energy–Lipschitz bound.

### 7.1 The law $D'_{d,r}$

Fix $d\ge1$ and $r\in(0,1)$.

* **Clusters.** For $p\in\mathcal C_d$ let $X_p=\{p\odot(\mathbf 1-r\upsilon):\upsilon\in[0,1]^d\}$, where $\odot$ is the coordinatewise product. This is the axis-parallel cube of side $r$ in the corner of $[-1,1]^d$ at the vertex $p$, and it contains $p$ (take $\upsilon=0$). Since $1-r\upsilon_j>0$, every $x\in X_p$ has ${\rm sign}(x_j)=p_j$, so the $X_p$ are pairwise disjoint. Each has diameter $r\sqrt d$, and $X=\bigcup_pX_p\subseteq[-1,1]^d$ is compact.
* **Sampling.** $D'_{d,r}$ draws $p$ uniformly from $\mathcal C_d$ and $\upsilon$ uniformly from $[0,1]^d$, independently. It returns $x=p\odot(\mathbf 1-r\upsilon)$ and
  $$y=f^\star(x)=\begin{cases}+1,&|x_1|>1-r/2,\\-1,&|x_1|\le1-r/2.\end{cases}$$
  Since $|x_1|=1-r\upsilon_1$, we have $y=+1$ if and only if $\upsilon_1<\frac12$.

The pattern is "balanced at scale $r$". Any balanced pattern $y=(-1)^{\lfloor M'\upsilon_1\rfloor}$ with $M'$ even works the same way; it replaces $\Lambda r/2$ by $\Lambda r/M'$ in Lemma 7.1(d). Two halves suffice because $r$ is already below the resolution of every near-minimizer.

**Lemma 7.1.**

* (a) $x$ has the density $(Mr^d)^{-1}\mathbf 1_X$, the label is a deterministic Borel function of $x$, and the Bayes risk is $L_{D'}(f^\star)=0$.
* (b) $\mathbb E[y\mid p]=0$ and $y^2=1$. If $(x_i,y_i)$ are i.i.d. from $D'_{d,r}$ and $p_i$ is the vertex of the cluster containing $x_i$, then the pairs $(p_i,y_i)$ are i.i.d. from $D_d$.
* (c) $L_{D'}(0)=1$.
* (d) Every $g$ that is $\Lambda$-Lipschitz on $X$ satisfies $L_{D'}(g)\ge1-\frac{\Lambda r}{2}$. A depth-$L$ network of width $m$ with all weights in $[-B,B]$ has $\Lambda\le B^{L}m^{H}\sqrt d$. So every such network has $L_{D'}\ge1-\frac r2B^Lm^H\sqrt d$.

*Proof.*

(a)–(c) are immediate. For (b), $\Pr[\upsilon_1<\frac12]=\frac12$ independently of $p$.

(d) Write $L_{D'}(g)=\mathbb Eg^2-2\mathbb E[gy]+1\ge1-2|\mathbb E[gy]|$.

* **Pairing.** Given $p$, let $x(\upsilon)=p\odot(\mathbf 1-r\upsilon)$. Pairing $\upsilon$ with $\upsilon+\frac12e_1$ for $\upsilon_1<\frac12$ gives
  $$\mathbb E[gy\mid p]=\int_{\{\upsilon_1<1/2\}}\big[g(x(\upsilon))-g(x(\upsilon+\tfrac12e_1))\big]d\upsilon .$$
* **Size.** The two points are at distance $r/2$, and the domain has measure $\frac12$. So $|\mathbb E[gy\mid p]|\le\Lambda r/4$.
* **Network Lipschitz bound.** By the proof of Lemma 3.1(b), $\Lambda\le\|v\|_2\|W^1\|_F\prod_{\ell\ge2}\|W^\ell\|_F\le B\sqrt m\cdot B\sqrt{m(d+1)}\cdot(Bm)^{H-1}$. Only the $d$ input columns of $W^1$ matter, which gives $B\sqrt{md}$ in place of $B\sqrt{m(d+1)}$. $\square$

### 7.2 The theorem

**Theorem 7.2 (Claim A′).** Fix $H\ge2$, $L=H+1$, $d,n\ge1$, $c>0$, $t>0$, $a\in(0,1]$ and $\delta\in(0,1)$. Let $s,\lambda,K_{\rm mem},N_0$ be as in Theorem 4.4. Put
$$K_2=\max\Big\{\frac nc+t,\ K_{\rm mem}\Big\},\qquad r=\frac1n\Big(\frac L{K_2}\Big)^{L/2},\qquad E=\sqrt{c\,(K_{\rm mem}+t)}+\Big(a+\frac2n\Big)\sqrt n .$$
Then $0<r<1$. Let $S\sim(D'_{d,r})^{\otimes n}$. Compute $k_p$, $\bar y_p$ and $Q$ from the pairs $(p_i,y_i)$, and let $\mathcal E'=\{Q\ge M\beta_n-\sqrt{2n\log(1/\delta)}\}$, which has probability at least $1-\delta$. On $\mathcal E'$, for every width $N\ge N_0$:

* (i) every $w\in\mathcal N_t(S)$ satisfies
  $$L_{D'}(z_w)\ \ge\ \Big(\sqrt{1+\big(\sqrt{Q/M}-\sqrt{(2E\sqrt n+E^2)/M}\,\big)_+^2}\;-\;\frac1n\Big)_+^2=:1+\underline e' ,$$
  and so does ${\rm clip}\circ z_w$;
* (ii) $\Pi_\sigma\{w:L_{D'}(z_w)\ge1+\underline e'\}\ge\Pi_\sigma(\mathcal N_t)\to1$ as $\sigma\to0$;
* (iii) for $f_\sigma$ any of $\bar z_{\Pi_\sigma}$, ${\rm clip}\circ\bar z_{\Pi_\sigma}$ or $\int{\rm clip}(z_w)\,d\Pi_\sigma$, the bound in (i) holds with $\frac1n$ replaced by $\frac1n+\varsigma_\sigma$, where $\varsigma_\sigma\to0$. Hence $\liminf_{\sigma\to0}L_{D'}(f_\sigma)\ge1+\underline e'$;
* (iv) by Remark 3.4 (compact inputs), the convergence in (ii) and (iii) is uniform over samples.

The same conclusions hold for every smaller radius $r'\in(0,r]$. Under the hypotheses of Corollary 4.5 (with $a=a_d$ and $\delta=\delta_d$), $\underline e'\to\beta(\lambda)$. Meanwhile $L_{D'}(0)=1$ and the Bayes risk is $0$. Choosing $r'$ small enough also makes every network in any fixed polynomial class have risk $1-o(1)$, by Lemma 7.1(d).

For $c=1$ and $a=a_d$, the proof of Corollary 4.5 shows $K_{\rm mem}=o(n)$. So for large $d$, $K_2=n+t$ and $r=\frac1n\big(\frac{L}{n+t}\big)^{L/2}\approx L^{L/2}n^{-1-L/2}$. For example $r\approx5.2\,n^{-5/2}$ at $H=2$. At $d=30$ this is $r\approx10^{-22}$ (`A_scripts/check_tube_and_lb.py`).

*Proof.*

**Step 0 (radius).** $K_2\ge K_{\rm mem}\ge\frac92(H+1)>L$, so $r<1/n\le1$. Replacing $r$ by $r'\le r$ only decreases the Lipschitz increments in Steps 2 and 3, which stay at most $\frac1n$. So it suffices to treat $r$.

**Step 1 (law).** By Lemma 7.1(b) and Lemma 4.3(b), $\Pr(\mathcal E')\ge1-\delta$.

**Step 2 (near-minimizers are almost constant on clusters).**

* **Energy.** For $w\in\mathcal N_t(S)$, $\kappa_N(w)\le F_{c,S}(w)\le F_{c,S}(0)+t=\frac nc+t\le K_2$, since $y_i^2=1$.
* **Lipschitz.** By Lemma 3.1(b), for $x\in X_p$,
  $$|z_w(x)-z_w(p)|\le\frac{(K_2/L)^{L/2}}{\sqrt d}\,\|x-p\|_2\le\frac{(K_2/L)^{L/2}}{\sqrt d}\,r\sqrt d=\frac1n .$$
* **Notation.** Put $\zeta_p=z_w(p)$ and $\tilde\zeta(x)=\zeta_{p(x)}$, where $p(x)$ is the vertex of the cluster containing $x$. Then $\sup_X|z_w-\tilde\zeta|\le\frac1n$.

**Step 3 (comparator).**

* Lemma 2.1 applies to $r_0=\bar y\,\mathbf 1[k_p\ge1]$ on $\mathcal C_d$. It gives $w_0$ with $\kappa_N(w_0)\le K_{\rm mem}\le K_2$ and $|z_{w_0}(p)-r_0(p)|<a$.
* By Lemma 3.1(b), as in Step 2, $|z_{w_0}(x)-z_{w_0}(p)|\le\frac1n$ on $X_p$.
* Hence $|z_{w_0}(x_i)-\bar y_{p_i}|\le a+\frac1n$ for every training point.

**Step 4 (residual budget).**

* **Within-cluster sum.** Let $W=\sum_i(y_i-\bar y_{p_i})^2$. Then $W\le n$, since $W=\sum_pk_p(1-\bar y_p^2)$.
* **Comparator residual.** By Minkowski's inequality in $\mathbb R^n$, $\sum_i(z_{w_0}(x_i)-y_i)^2\le\big(\sqrt W+(a+\frac1n)\sqrt n\big)^2$.
* **Near-minimizer residual.** From $F_{c,S}(w)\le F_{c,S}(w_0)+t$ and $\kappa_N(w)\ge0$,
  $$\sum_i(z_w(x_i)-y_i)^2\le c\,(K_{\rm mem}+t)+\big(\sqrt W+(a+\tfrac1n)\sqrt n\big)^2 .$$
* **Vertex values.** Minkowski's inequality and Step 2 give $\big(\sum_i(\zeta_{p_i}-y_i)^2\big)^{1/2}\le\big(\sum_i(z_w(x_i)-y_i)^2\big)^{1/2}+\frac{\sqrt n}{n}$.
* **Atom decomposition.** Lemma 4.1(a), applied on $\mathcal C_d$ to $p\mapsto\zeta_p$ and the pairs $(p_i,y_i)$, gives $\sum_i(\zeta_{p_i}-y_i)^2=\Delta(\zeta)+W$.
* **Conclusion.** Using $\sqrt{u+v^2}\le\sqrt u+v$, we get $\sqrt{\Delta(\zeta)+W}\le\sqrt W+E$. Squaring,
  $$\Delta(\zeta)\le2E\sqrt W+E^2\le2E\sqrt n+E^2 .$$

**Step 5 (test loss).**

* **Reduction to vertex values.** $L_{D'}(z_w)=\|z_w-f^\star\|^2_{L^2(D')}$. Since $\|z_w-\tilde\zeta\|_{L^2}\le\frac1n$, Minkowski gives $\sqrt{L_{D'}(z_w)}\ge\|\tilde\zeta-f^\star\|_{L^2}-\frac1n$.
* **Piecewise-constant risk.** By Lemma 7.1(b), $\|\tilde\zeta-f^\star\|^2=\frac1M\sum_p\mathbb E[(\zeta_p-y)^2\mid p]=1+\frac1M\sum_p\zeta_p^2$.
* **Seen clusters.** Lemma 4.2(b), with $f=g=\zeta$ and $B=2E\sqrt n+E^2$, gives $\frac1M\sum_p\zeta_p^2\ge\big(\sqrt{Q/M}-\sqrt{B/M}\big)_+^2$. This proves (i).
* **Clipped outputs.** ${\rm clip}\circ z_w$ is within $\frac1n$ of ${\rm clip}\circ\tilde\zeta$, because clipping is $1$-Lipschitz, and $\Delta({\rm clip}\circ\zeta)\le\Delta(\zeta)$ by Lemma 4.1(c).

**Step 6 (Gibbs and posterior means).**

* **(ii)** follows from (i) and Corollary 3.3.
* **(iii).** Let $m_\sigma(x)=\mathbb E_{\Pi_\sigma}[z_w(x)\mid\mathcal N_t]$.
  * By Jensen (Corollary 3.3), $\Delta\big((m_\sigma(p))_p\big)\le2E\sqrt n+E^2$.
  * For $x\in X_p$, $|\bar z_{\Pi_\sigma}(x)-m_\sigma(p)|\le|\bar z_{\Pi_\sigma}(x)-m_\sigma(x)|+\mathbb E\big[|z_w(x)-z_w(p)|\,\big|\,\mathcal N_t\big]\le\varsigma_\sigma+\frac1n$. Here $\varsigma_\sigma=(1-p_\sigma)\sqrt{n/c+t}+T_\sigma$ by (3.3), using $F^*\le n/c$.
  * Repeat Step 5. The clipped versions are handled as in Theorem 4.4(iii), with $\varsigma_\sigma=2(1-p_\sigma)$ for $\int{\rm clip}(z_w)\,d\Pi_\sigma$.

**Step 7 (asymptotics).** $E\le\sqrt{c(K_{\rm mem}+t)}+a\sqrt n+2/\sqrt n$. Under (4.4) and $a_d\to0$, $E/\sqrt n\to0$, so $(2E\sqrt n+E^2)/M\to0$ since $n\asymp M$. On $\mathcal E'$, $Q/M\ge\beta_n-o(1)$, as in Corollary 4.5. Hence $\underline e'\to\beta(\lambda)$. $\square$

**Remark 7.3.** Three points about the construction.

* *The objections it answers.* The inputs have a density and never repeat. The labels are a deterministic function of $x$, so the Bayes risk is $0$. Yet the learner's risk tends to $1+\beta(\lambda)$, which is worse than the zero network. Every network with polynomially bounded width and weights has risk $1-o(1)$ once $r'$ is chosen accordingly.
* *Why it works.* Fine-scale structure that the competitors cannot resolve acts as noise. Small-energy networks are polynomially Lipschitz, so they cannot resolve it either. The near-minimizer energy bound $\kappa_N\le n/c+t$ comes from comparing with the zero network.
* *Scale.* The radius is polynomially small in $n$, hence exponentially small in $d$. This is the price of a construction that works at every width $N\ge N_0$ and every $\sigma$.

---

## 8. Is the memorization exponent $1/H$ optimal?

Two questions are relevant. First, could a cheaper construction memorize $s$ points with energy $o(s^{1/H})$? Second, does the SP$_c$ learner memorize for larger $c$? Both answers are no, up to factors polynomial in $d$, which are polylogarithmic in $n$ when $n\asymp 2^d$.

### 8.1 A width-uniform Rademacher bound

**Lemma 8.1.** Let $H\ge1$ and $K>0$. Let $x_1,\dots,x_m\in\mathcal C_d$, with repetitions allowed, and let $\mathcal F_K=\bigcup_{N\ge1}\{z_w:\kappa_N(w)\le K\}$. For i.i.d. Rademacher signs $\varepsilon$,
$$\mathbb E_\varepsilon\sup_{f\in\mathcal F_K}\sum_{i=1}^m\varepsilon_if(x_i)\ \le\ D_{d,H}\sqrt m\,\Big(\frac KH\Big)^{H/2},\qquad D_{d,H}=\sqrt{2\log 2}\,(d+1)+\frac{H-1}2 . \tag{8.1}$$

This is eq. (15) of `NNG/works-in-progress/noisy-interpolation/README.md` §4. That note has the constant $\sqrt2(d+2)+\frac{H-1}2$, which is larger. We re-derive it, since §8 depends on it.

*Proof.* For a set $\mathcal G$ of vectors in $\mathbb R^m$ write ${\rm Rad}(\mathcal G)=\frac1m\mathbb E\sup_{f\in\mathcal G}\sum_i\varepsilon_if_i$. ${\rm Rad}$ is monotone, positively homogeneous, and unchanged by closed convex hulls.

1. **First layer.** Let $\mathcal F_1$ be the closed convex hull of the vectors $(\tanh(\omega\cdot\bar x_i))_i$, $\omega\in\mathbb R^{d+1}$. It is symmetric because tanh is odd, and it contains $0$.
   * *Feature as an average of halfspaces.* Let the random threshold $T$ have distribution function $(1+\tanh t)/2$. Then $\mathbb E\,{\rm sign}(u-T)=2\Pr[T<u]-1=\tanh u$. So every feature vector is a convex combination of the vectors $({\rm sign}(\omega\cdot\bar x_i-T))_i$; ties have probability $0$.
   * *Counting.* These are dichotomies induced on $\mathcal C_d$ by affine halfspaces of $\mathbb R^d$, a class of VC dimension $d+1$. By Sauer–Shelah there are at most $J\le\sum_{k\le d+1}\binom Mk\le(M+1)^{d+1}$ of them, and $\log J\le(d+1)^2\log 2$.
   * *Massart.* Each vector has Euclidean norm $\sqrt m$. Massart's finite-class lemma gives ${\rm Rad}(\mathcal F_1)\le\sqrt{2\log J/m}\le\sqrt{2\log2}\,(d+1)/\sqrt m$.
2. **Clipping.** For $\mathcal G\subseteq[-1,1]^m$ let ${\rm Clip}(\mathcal G)=\{({\rm clip}_\tau(f_i))_i:f\in\mathcal G,\ \tau\in[0,1]\}$, with ${\rm clip}_\tau(u)=\frac{|u+\tau|-|u-\tau|}2$. We claim ${\rm Rad}({\rm Clip}\,\mathcal G)\le{\rm Rad}(\mathcal G)+\frac1{2\sqrt m}$.
   * *Splitting the supremum.* $\sup_{f,\tau}\sum_i\varepsilon_i{\rm clip}_\tau(f_i)\le\frac12\sup_{f,\tau}\sum_i\varepsilon_i|f_i+\tau|+\frac12\sup_{f,\tau}\sum_i(-\varepsilon_i)|f_i-\tau|$.
   * *Contraction.* We use the one-sided Ledoux–Talagrand inequality $\mathbb E\sup_{t\in T}\sum_i\varepsilon_i\phi(t_i)\le\mathbb E\sup_{t\in T}\sum_i\varepsilon_it_i$, valid for $1$-Lipschitz $\phi$ and bounded $T$ without assuming $\phi(0)=0$; the note sketches its proof. Apply it with $\phi=|\cdot|$ and $-\varepsilon\overset d=\varepsilon$.
   * *Bound.* Each half-expectation is at most $\frac12\big(m{\rm Rad}(\mathcal G)+\mathbb E\sup_{\tau\in[0,1]}\tau\sum_i\varepsilon_i\big)$. Since $\mathbb E\sup_{\tau}\tau\sum_i\varepsilon_i=\mathbb E(\sum_i\varepsilon_i)_+=\frac12\mathbb E|\sum_i\varepsilon_i|\le\frac{\sqrt m}2$, the claim follows.
3. **Normalized tanh is a mixture of clips.** For $\rho>0$ and $|u|\le1$,
   $$\frac{\tanh(\rho u)}{\rho}=\int_0^1{\rm clip}_\tau(u)\,\frac{d}{d\tau}\tanh^2(\rho\tau)\,d\tau+{\rm sech}^2(\rho)\,{\rm clip}_1(u).$$
   The weights are nonnegative with total mass $\tanh^2\rho+{\rm sech}^2\rho=1$. This is eq. (13) of the note. Both sides are odd in $u$. For $u\in[0,1]$ the right side is
   $$\int_0^u\tau\,d\tanh^2(\rho\tau)+u\big(\tanh^2\rho-\tanh^2(\rho u)\big)+u\,{\rm sech}^2\rho .$$
   Integrating by parts, the first term is $u\tanh^2(\rho u)-\int_0^u\tanh^2(\rho\tau)d\tau=u\tanh^2(\rho u)-u+\frac{\tanh(\rho u)}\rho$, and the total is $\frac{\tanh(\rho u)}{\rho}$.
4. **Path normalization.** Let $\mathcal F_\ell=\overline{\rm conv}\,{\rm Clip}(\mathcal F_{\ell-1})$ for $\ell\ge2$. These sets are symmetric and convex, contain $0$, and lie in $[-1,1]^m$. By step 2, ${\rm Rad}(\mathcal F_H)\le{\rm Rad}(\mathcal F_1)+\frac{H-1}{2\sqrt m}$.
   * *Weights.* For a network put $\rho^1_i=1$ and $\rho^\ell_j=\sum_i|W^\ell_{ji}|\rho^{\ell-1}_i$.
   * *Induction claim.* If $\rho^\ell_j>0$ then $h^\ell_j/\rho^\ell_j\in\mathcal F_\ell$, and if $\rho^\ell_j=0$ then $h^\ell_j\equiv0$.
   * *Case $\rho^\ell_j>0$.* Write $W^\ell_jh^{\ell-1}=\rho^\ell_ju_j$ with
     $$u_j=\sum_{i:\rho^{\ell-1}_i>0}\frac{W^\ell_{ji}\rho^{\ell-1}_i}{\rho^\ell_j}\cdot\frac{h^{\ell-1}_i}{\rho^{\ell-1}_i},$$
     a signed sub-convex combination of elements of the symmetric convex set $\mathcal F_{\ell-1}$. So $u_j\in\mathcal F_{\ell-1}$ and $|u_j|\le1$, and by step 3, $h^\ell_j/\rho^\ell_j=\tanh(\rho^\ell_ju_j)/\rho^\ell_j\in\mathcal F_\ell$.
   * *Case $\rho^\ell_j=0$.* Every incoming term vanishes.
   * *Output.* $z_w=\sum_jv_jh^H_j\in P\,\mathcal F_H$ with $P=\sum_j|v_j|\rho^H_j=|v|^\top|W^H|\cdots|W^2|\mathbf 1$.
5. **Path norm and energy.** By Cauchy–Schwarz and $\||A|\|_{\rm op}\le\|A\|_F$,
   $$P\le\|v\|_2\prod_{\ell=2}^H\|W^\ell\|_F\,\sqrt N=\Big(\kappa^{(L)}\prod_{\ell=2}^H\kappa^{(\ell)}\Big)^{1/2}\le\Big(\frac{\kappa_N}{H}\Big)^{H/2},$$
   by AM–GM over the $H$ numbers $\kappa^{(2)},\dots,\kappa^{(H)},\kappa^{(L)}$. This is eq. (14) of the note. Since $\mathcal F_H$ is convex and contains $0$, $\mathcal F_K\subseteq(K/H)^{H/2}\mathcal F_H$. Multiply by $m$. $\square$

The first layer's energy does not enter (8.1). The cube is used only in the halfspace count of step 1. For general inputs, Sauer–Shelah on the $m$ sample points gives $\log J\le(d+1)\log(em/(d+1))$ instead.

### 8.2 Energy needed to memorize

**Proposition 8.2.** Let $H\ge1$, let $x_1,\dots,x_s\in\mathcal C_d$ be distinct, and let $K>0$.

* (a) Suppose that for every $\varepsilon\in\{-1,1\}^s$ some $f\in\mathcal F_K$ satisfies $\max_i|f(x_i)-\varepsilon_i|\le a<1$. Then
  $$K\ \ge\ H\Big(\frac{(1-a)\sqrt s}{D_{d,H}}\Big)^{2/H}.$$
* (b) Suppose that for at least a fraction $1-q$ of $\varepsilon\in\{-1,1\}^s$ some $f\in\mathcal F_K$ satisfies $\sum_i(f(x_i)-\varepsilon_i)^2\le\theta s$, where $\theta<1$ and $q<1$. Then
  $$K\ \ge\ H\Big(\frac{(1-q)(1-\theta)\sqrt s}{2D_{d,H}}\Big)^{2/H}.$$

*Proof.*

(a) $\varepsilon_if(x_i)\ge1-a$ for each $i$, so $\sup_{\mathcal F_K}\sum_i\varepsilon_if(x_i)\ge(1-a)s$ for every $\varepsilon$. Lemma 8.1 gives $(1-a)s\le D_{d,H}\sqrt s\,(K/H)^{H/2}$.

(b) For a good $\varepsilon$,
$$\sum_i\varepsilon_if(x_i)=\tfrac12\Big(\sum_if(x_i)^2+s-\sum_i(f(x_i)-\varepsilon_i)^2\Big)\ge\tfrac{(1-\theta)s}2 .$$
For the other patterns the supremum is at least $0$, by the zero network. Averaging over $\varepsilon$, $\frac{(1-q)(1-\theta)s}{2}\le D_{d,H}\sqrt s\,(K/H)^{H/2}$. $\square$

**Consequences.**

* *Optimal exponent.* By (a), memorizing arbitrary signs on $s$ cube points needs energy $\Omega\big(H(s/d^2)^{1/H}\big)$. By (b), so does approximately fitting *most* random sign patterns. Lemma 2.1 achieves $(H+1)(8ds)^{1/H}$ plus terms independent of $s$. When the $s$-term dominates, the ratio is at most $\frac{H+1}H\big(8d\,D_{d,H}^2/(1-a)^2\big)^{1/H}=O(d^{3/H})$. So no construction improves the exponent $1/H$, and Lemma 2.1 is optimal up to a factor polynomial in $d$, raised to the power $1/H$.
* *Depth two.* At $H=1$, (a) gives $K\ge(1-a)^2s/D_{d,1}^2$, which is linear in $s$ (Remark 2.5).
* *Numbers.* For $s=2^d$ and $a=\frac12$ (`A_scripts/check_tube_and_lb.py`): at $(H,d)=(2,40)$, construction $5.6\cdot10^7$ against lower bound $2.2\cdot10^4$; at $(3,40)$, $2.9\cdot10^5$ against $1.5\cdot10^3$.
* *Not settled.* The constants and the $d$-dependence are not optimized. Whether the first-layer cost $d(d+1)\alpha_d^2$ is necessary is also open: the bound (8.1) does not see the first layer.

### 8.3 The learner does not memorize above $c\approx n^{1-1/H}$

**Proposition 8.3.** Let $S\sim D_d^{\otimes n}$ (the cube example), $H\ge1$, $N$ any width, $c,t>0$ and $\delta\in(0,1)$. Put $K_0=n/c+t$. With probability at least $1-\delta$, every $w\in\mathcal N_t(S)$ satisfies the following.

* (a) $\displaystyle\frac1n\sum_{i=1}^nz_w(x_i)^2\le\frac{ct}{n}+\frac{2D_{d,H}}{\sqrt n}\Big(\frac{K_0}H\Big)^{H/2}+2\sqrt{\frac{2K_0\log(2/\delta)}{n}}$. Consequently $\frac1M\sum_{x\in\mathcal S}z_w(x)^2\le\frac nM\cdot$(the same right side).
* (b) $\displaystyle L_{D_d}(z_w)-1\le(\text{right side of (a)})+\frac{4D_{d,H}\sqrt{K_0}}{\sqrt n}\Big(\frac{K_0}H\Big)^{H/2}+K_0\sqrt{\frac{\log(2/\delta)}{2n}}$.

Consider $n\asymp2^d$, so that $D_{d,H}=O(\log n)$, and $c=n^{1-\vartheta}$. Then the right side of (a) tends to $0$ when $\vartheta<1/H$, and the right side of (b) tends to $0$ when $\vartheta<1/(H+1)$.

*Proof.*

(a)

* **Energy budget.** Comparing with $w=0$ gives $\kappa_N(w)\le K_0$.
* **Correlation inequality.** Write $z_i=z_w(x_i)$. Near-minimality gives $\kappa_N(w)+\frac1c\sum_i(z_i-y_i)^2\le\frac nc+t$. Expanding $\sum_i(z_i-y_i)^2=\sum_iz_i^2-2\sum_iy_iz_i+n$ yields
  $$c\,\kappa_N(w)+\sum_iz_i^2\le ct+2\sum_iy_iz_i\le ct+2\Phi(y),\qquad\Phi(y)=\sup_{f\in\mathcal F_{K_0}}\sum_iy_if(x_i).$$
* **Expectation.** Given the inputs, $y$ is a Rademacher vector, so Lemma 8.1 gives $\mathbb E[\Phi\mid\text{inputs}]\le D_{d,H}\sqrt n(K_0/H)^{H/2}$.
* **Concentration.** By Lemma 3.1(a), changing one $y_i$ changes $\Phi$ by at most $2\sqrt{K_0}$. McDiarmid's inequality then gives $\Phi\le\mathbb E\Phi+\sqrt{2nK_0\log(2/\delta)}$ with conditional probability at least $1-\delta/2$. $\Phi$ is a supremum over a countable dense subset, because $w\mapsto z_w(x_i)$ is continuous and there are countably many widths.
* **Seen atoms.** $\sum_{x\in\mathcal S}z_w(x)^2\le\sum_xk_xz_w(x)^2=\sum_iz_i^2$.

(b)

* **Population second moment.** $L_{D_d}(z_w)-1=\mathbb E_{x\sim{\rm Unif}(\mathcal C_d)}z_w(x)^2$.
* **Truncated square.** Let $\phi(u)=\min\{u^2,K_0\}$. It is $2\sqrt{K_0}$-Lipschitz on $\mathbb R$ and equals $u^2$ on the range of $\mathcal F_{K_0}$.
* **Uniform deviation.** Let $\Psi=\sup_{f\in\mathcal F_{K_0}}\big(\mathbb E\phi(f(x))-\frac1n\sum_i\phi(f(x_i))\big)$. By symmetrization, contraction and Lemma 8.1,
  $$\mathbb E\Psi\le\frac2n\,\mathbb E\sup_f\sum_i\varepsilon_i\phi(f(x_i))\le\frac{4\sqrt{K_0}}{n}\,\mathbb E\sup_f\sum_i\varepsilon_if(x_i)\le\frac{4\sqrt{K_0}\,D_{d,H}}{\sqrt n}\Big(\frac{K_0}H\Big)^{H/2}.$$
* **Concentration.** $\Psi$ has bounded differences $K_0/n$ in the inputs. McDiarmid's inequality gives $\Psi\le\mathbb E\Psi+K_0\sqrt{\log(2/\delta)/(2n)}$ with probability at least $1-\delta/2$.
* **Combination.** Add this to (a).

**Asymptotics.** With $K_0=n^{\vartheta}+t$:

* in (a) the main term is $\asymp(\log n)\,n^{(\vartheta H-1)/2}$;
* in (b) the extra term is $\asymp(\log n)\,n^{(\vartheta(H+1)-1)/2}$;
* $K_0/\sqrt n\to0$ because $\vartheta<\frac12$. $\square$

**The threshold, sharply.**

* *Below.* Theorem 4.4 gives memorization, with seen-atom excess $\to\beta(\lambda)$, whenever $c=o(n^{1-1/H}d^{-1/H})$.
* *Above.* By Proposition 8.3(a), memorization is absent, with seen-atom excess $\to0$, whenever $\frac{2D_{d,H}}{\sqrt n}\big(\frac{n}{cH}\big)^{H/2}\to0$. That is, whenever $c\gg n^{1-1/H}D_{d,H}^{2/H}/H$, which is about $n^{1-1/H}d^{2/H}$.
* *Window.* The two thresholds differ by a factor $d^{3/H}$, polylogarithmic in $n$.

So the memorization transition of SP$_c$ on the cube example happens at $c=n^{1-1/H}$ up to polylogarithmic factors. The exponent $1/H$ is optimal on the construction side (Proposition 8.2) and on the learner side (Proposition 8.3(a)).

What remains open is the test excess for $n^{1-1/H}{\rm polylog}\ll c\ll n^{1-1/(H+1)}$. There, near-minimizers do not fit the training noise, but (b) does not control their output on unseen atoms. This is part of the brief's Claim D and is not settled here. Proposition 8.3 concerns only this centred-noise example. A general agnostic oracle inequality (Claim B) is not proved in this section.

---

## 9. Numerical checks

All scripts are in `../checks/A/`, with outputs `*.out` next to them. They are sanity checks, not proofs. Floating-point evaluations of explicit networks are not certified.

1. **`check_parity.py`** (Lemma 2.2).
   * Identity (2.2) holds with maximal error $1.1\cdot10^{-16}$ over $k\le7$, slopes $\{0.3,0.867,1,2.5\}$ and all $x$ (exhaustive).
   * The closed form of $c_{k,\infty}$ holds in exact rational arithmetic for $k\le40$.
   * $|c_{k,\infty}|\ge(2k)^{-1/2}$ (exact, $k\le400$) and $\binom{2m}m4^{-m}\ge\frac1{2\sqrt m}$ (exact, $m\le200$).
   * $\min|c_{k,\alpha_d}|\cdot2\sqrt{2k}=1.337\ge1$ over $1\le k\le d\le60$ and $d\in\{80,100,128,160,200\}$, in 300-digit arithmetic. The binomial sums cancel catastrophically in double precision.
2. **`check_memorizer.py`** (Lemma 2.1, end to end). For $(d,H)\in\{(3,2),(3,3),(4,2),(5,3),(6,2)\}$ the script draws $n=2^d$ samples, computes $r=\bar y\mathbf 1_{\mathcal S}$, its Fourier coefficients and the exact expansion. The reconstruction error is at most $3\cdot10^{-15}$, and $A\le2\sqrt{2d}\|r\|_2$ in every case. It then samples features, builds **dense** weight matrices at widths 2000–3000, runs a forward pass, and computes $\kappa_N$ from the matrices.
   * With the Hoeffding $m$ (cases $(3,2)$, $(3,3)$, $(4,2)$), $\max|z-r|=0.25,0.23,0.12<a$.
   * The chain error is below the bound (2.3) in every case.
   * $\kappa_N\in\{17.2,18.6,27.1,48.1,63.5\}$, each below the detailed bound $d(d+1)\alpha_d^2+2A^2R^{2-2H}+(H-1)R^2$ and below $K_{\rm mem}$.
   * The test excess of these memorizers is $\approx Q/M$, as in Remark 4.8.
3. **`check_constants.py`.**
   * $|t-\tanh t|\le|t|^3/3$ on a grid. The ratio of the chain error to the bound (2.3) is $\le0.99999999$ in 60-digit arithmetic; it tends to 1 as $g\to0$, as Taylor's theorem predicts. At $R^2=9/(2a)$ and $|g|\le\frac32$, the error is at most $0.503\cdot\frac a2$.
   * $\beta(\lambda)$: the series and the closed form agree. $\beta(1)=0.484829$; the maximum is at $\lambda^*=1.50286$, where $\beta=0.517351=(1-e^{-\lambda^*})/\lambda^*$; $\max|\beta'|\le0.981$.
   * Binomial against Poisson: $|\beta_n-\beta(n/M)|$ is below Le Cam's $n/M^2$ for $d\in\{6,\dots,30\}$.
   * Monte Carlo of $Q/M$ at $n=2^d$, $d\in\{10,14,18\}$: means $0.48507,0.48484,0.48469$ against $\beta_n=0.48503,0.48484,0.48483$. Standard deviations are $0.0147,0.0038,0.0009$, inside the McDiarmid deviation at $\delta=0.01$, which is $0.095,0.024,0.006$.
   * Random networks satisfy Lemma 3.1: empirical gradient over $(\prod\kappa^{(\ell)}/d)^{1/2}$ is at most $0.84$, and $|z|/\sqrt\kappa\le0.62$.
   * The clip-mixture identity of step 3 in Lemma 8.1 holds to $1.3\cdot10^{-15}$.
4. **`bounds_table.py`.** Table 4.1, and the admissible-$c$ comparison of Remark 4.7.
5. **`check_tube_and_lb.py`.**
   * Monte Carlo of "no atom carries both labels" lies below the bound of Lemma 6.4(b) in every tested case, for example $0.0000$ against $0.0232$ at $M=1024$, $n=256$.
   * Proposition 8.2 against Lemma 2.1, for $s=2^d$.
   * The Claim A′ radius $r(n)$: $\log_2r=-47.6,-72.6,-97.6$ at $d=20,30,40$ with $H=2$.
6. **`spc_small_d.py`** (illustration of Theorem 4.4 at small $d$, with $c=1$). L-BFGS on $F_c$ for the cube example with $n=2^d$.
   * $d=8$, $H=2$, $N=128$: the minimizer found has $\kappa=46.5$ and $\Delta=2.98$, so $F=49.5$, against $160.3$ for the zero network. Its test excess is $0.491$, of which $0.384$ is on seen atoms and $0.106$ on unseen ones; here $Q/M=0.4995$.
   * $d=8$, $H=3$, $N=96$: $\kappa=33.8$, $\Delta=0.92$, test excess $0.609$, of which $0.170$ is on unseen atoms.
   * $d=9$, $H=2$, $N=160$: $\kappa=58.6$, $\Delta=2.73$, test excess $0.547$, against $Q/M=0.475$.
   * Using the network found as the comparator in Lemma 4.1(b) *certifies* a lower bound for **all** near-minimizers: $0.069$, $0.111$ and $0.116$ respectively, up to floating-point evaluation.
   * Larger $c$ (`spc_small_d_largec.out`): at $d=8$, $H=2$ with $c=16=\sqrt n$ and with $c=64$, the optimizer returns the zero network, with test excess $0$. The memorizing configuration costs energy $\approx46$, more than the data term it would remove, which is $G/c\le10$. This agrees with the threshold $c\approx n^{1-1/H}$ of §8.3.
   * These finite-$d$ runs illustrate the mechanism only. The asymptotic constants of §4 become informative around $d\approx20$–$30$ (Table 4.1).

---

## 10. What is proved, and what is not

**Proved** (paper proofs, with all hypotheses stated above).

* Lemma 2.1: real-valued memorization with explicit $K_{\rm mem}$ and $N_0$, at every width $N\ge N_0$ and depth $\ge3$, with no margin conditioning.
* Lemmas 3.1–3.2 and Corollary 3.3: output, Lipschitz and strong-prior concentration bounds, including control of the posterior-mean tail.
* Theorem 4.4 and Corollaries 4.5–4.6: Claim A for near-minimizers, Gibbs draws and posterior means, clipped or unclipped. Every term is explicit, $c=c(n)$ is arbitrary subject to (4.4), and general label laws with ${\rm Var}(y\mid x)\ge v_0$ are covered.
* Proposition 5.1: refutation of the polynomial oracle inequality (P$_L$) for SP$_c$, for every $L\ge3$ and every such $c$.
* Proposition 6.1: sampling without replacement.
* Lemma 6.2, Proposition 6.3, Lemma 6.4 and Proposition 6.5: the TUBE$_\rho$ regimes of Table 6.1.
* Theorem 7.2: Claim A′ with an explicit radius $r(n)$ and label pattern.
* Lemma 8.1 and Propositions 8.2–8.3: optimality of the exponent $1/H$, on the construction side and on the learner side.

**Not proved, or open.**

1. **Depth two ($L=2$).** The memorizer costs $\Theta(s)$ energy, up to factors polynomial in $d$, at $H=1$ (Remark 2.5 and Proposition 8.2). Whether SP$_1$ at depth two still has a constant excess on $D_d$ is not settled here. The red-team report (`../research-notes/red-team.md` §5) claims a small excess of order $d^{-2}$; I have not checked it.
2. **Learner widths below $N_0$.** All failures are proved for $N\ge N_0={\rm poly}(n)$, or $O(n\log^2n)$ at a fixed accuracy. Nothing is claimed for smaller widths.
3. **Finite-scale priors $\mu_{N,\gamma}$ with likelihood variance $cN^{-\gamma}$ (Claim E).** This would need a lower bound $e^{-o(n)N^\gamma/c}$ on the prior mass of a neighbourhood of the memorizer. The repository's tube bound $A_L$ grows with teacher width, so this remains open. The TUBE results of §6 do hold at finite scale; see the remark after Lemma 6.2 and Proposition 6.5.
4. **The progressive-mixture predictor.** Its prefix posterior means at small $t$ are not controlled by Lemma 4.1, so no lower bound is given. A heuristic count suggests a constant excess smaller than $\beta$.
5. **The window $n^{1-1/H}{\rm polylog}\ll c\ll n^{1-1/(H+1)}$.** Near-minimizers provably do not fit the training noise there. Their test excess is not controlled here (§8.3, Claim D).
6. **TUBE$_1$ with fair labels and distinct inputs.** The minimum-energy sign interpolants are not analysed. A failure at $\rho=1$ is given only for other label laws (Proposition 6.3(b)).
7. **Constants.** The $d$-dependence of $K_{\rm mem}$ is not shown optimal: there is a gap $O(d^{3/H})$ to Proposition 8.2, and the first-layer term $d^2\log^2 d$ is not shown necessary. The widths $N_0$ are far from economical.
