# A. Tightly conditioned Bayesian networks interpolate noise and fail agnostically

*Research section for the brief `../research-notes/problem-brief.md`: Claims A, A′ and the TUBE variants, with a stretch result on the memorization exponent. Revision 1, 11 November 2026, written after three referee reports (`A-first-version-logic.md`, `A-first-version-computation.md`, `A-first-version-scope.md`). Appendix R answers each issue they raise. This is a paper proof with numerical sanity checks. It has not been Lean-verified. `NNG/` denotes the project folder `neural-network-generalization/` of this repository. The check scripts are in `../checks/A/` (first version) and `../checks/A/` (added in this revision).*

---

## 0. Results

### 0.1 Scope

This section refutes a property of particular learners. It does not refute the user's conjecture. The conjecture is existential in the learner ("We may pick whichever version of Bayesian learning is best"). Brief §1 formalizes it as a property (P$_L$) of one fixed learner, uniform over the input dimension, the data law, the competitor and the learner width (§5.1). The results below show that (P$_L$) fails for learners that condition tightly on each training output:

* SP$_c$ in the strong-prior limit, at depth $L\ge3$, whenever $c\,K_{\rm mem}=o(n)$, roughly $c\ll n^{1-1/H}d^{-1/H}$. This includes the clean-label scaling $c=1$ (Proposition 5.1).
* TUBE$_\rho$ in the strong-prior limit at every tolerance schedule $\rho(n)$, at every depth and width, under either convention for an empty tube (Proposition 6.6).

Other learners have the property. The sibling section `../research-notes/B-tempered-likelihood.md` proves (P$_L$) for the tempered learner SP$_c$ with $c=n^{1-\theta}$, $0<\theta<1/H$, for clipped predictors at every learner width (../research-notes/B-tempered-likelihood.md Theorem 6.3). `../research-notes/E-finite-prior-scale.md` proves a finite-scale analogue (../research-notes/E-finite-prior-scale.md Theorem 2.7). So what fails is the user's auxiliary heuristic that the learner "should condition to be pretty close to the given outputs on train inputs". In the agnostic setting it works the other way. Conditioning tight enough to push the training MSE well below the noise level is what breaks the property (Theorem 4.4), and tempering the likelihood restores it (§5.4).

Three further limits apply to the negative results.

* **Input dimension.** The SP$_c$ counterexamples have input dimension $d=\log_2n$. They refute sample bounds that are uniform over the input dimension. That is the repository's convention: `NNG/README.md`, main result 1, states a sample bound "polynomial in input dimension". At any fixed $d$ the same cube family is consistent at every width (Proposition 5.2). A version of the conjecture whose $o(1)$ term may depend on $d$, or on the law, is not refuted by this family.
* **Input laws.** The continuous-input counterexample A′ is near-atomic at the learner's resolution. Its density is $2^{\Theta(d^2)}$ times the uniform density on $[-1,1]^d$. For a law whose density is at most $K$ times uniform, the Lipschitz transfer used in its proof reaches a test mass of at most $K\,2^{3.05d-(L/(2H))d^2}$ at $n=2^d$ (Proposition 7.4). Input laws with density ratio $2^{o(d^2)}$, such as uniform inputs on $[-1,1]^d$, combined with noisy labels, are open.
* **Learners and predictors not covered.** Learner widths below $N_0={\rm poly}(n)$; the progressive-mixture predictor; depth two; the finite-scale prior $\mu_{N,\gamma}$, which ../research-notes/E-finite-prior-scale.md treats; TUBE on continuous i.i.d. inputs with $\rho<1$.

### 0.2 Results

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
   - *Widths.* With the vanishing accuracy of Corollary 4.5, $N_0\le45\,d(d+1)\,2^{5d/3}=O(n^{5/3}\log^2n)$. At a fixed memorizer accuracy $a$, $N_0=O(n\log^2n/a^2)$, which is between $2\cdot10^5n$ and $7\cdot10^6n$ for $d\in[20,40]$ and $a\in\{0.1,0.3\}$; the certified excess is then $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2-o(1)$ (Remark 4.7). Nothing is proved for $N<N_0$.
   - *Dimension.* The excess is $\Omega(1)$ only in the window $n=\Theta(2^d)$, so the statement needs $d\to\infty$ (item 5).
4. **Refutation of (P$_L$) for tightly conditioned SP$_c$ (Proposition 5.1).** Take the competitor $g\equiv0$, any fixed $\varepsilon<\beta(1)$ and $\delta<1$, and $n=2^d$, which eventually exceeds any polynomial in $d$. Theorem 4.4 then violates (P$_L$) for SP$_c$, uniformly over the input dimension (here $d=\log_2n$). It does so under each of the readings (R1)–(R3) of §5.1: a Gibbs draw; a posterior mean, clipped or not; any near-minimizer, hence the MAP estimate and every $\sigma\to0$ weak limit of the posterior. The progressive-mixture predictor is not covered. This refutes (P$_L$) for SP$_c$ with $c\,K_{\rm mem}=o(n)$, including $c=1$. It does not refute the conjecture, which allows any Bayesian learner: ../research-notes/B-tempered-likelihood.md proves (P$_L$) for SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$ (clipped predictors). What fails is the heuristic that close conditioning is needed (§5.4). Nothing is claimed for learner widths below $N_0$ (§5.3).
5. **Fixed input dimension (Proposition 5.2).** Fix $d$. For every $c,t>0$, at every width and every depth, every near-minimizer of $F_c$ has excess at most $(8M/\delta'+4ct)/n$ on $D_d$, with probability at least $1-\delta'-Me^{-n/(8M)}$. The $\sigma\to0$ limits of the Gibbs and posterior-mean risks obey the same bound. So the cube family is consistent at each fixed $d$, and the constant excess of item 3 needs $n=\Theta(2^d)$ with $d\to\infty$.
6. **Variants (§6).**
   - *Without replacement* (Proposition 6.1): the excess is at least $\frac nM(1-o(1))$ with probability one. At $n=M$ the test MSE of near-minimizers, Gibbs draws and posterior means tends to $2$, against a Bayes risk of $1$.
   - *TUBE$_\rho$ with $\rho>1$, or any $\rho$ with $|y|<\rho$* (Lemma 6.2, Proposition 6.3): the strong-prior posterior collapses to the zero network. Non-centred noise then gives a constant excess $\eta_0^2$ against a width-one constant competitor.
   - *TUBE$_\rho$ with $\rho\le1$, with replacement* (Lemma 6.4): the posterior is undefined with probability $1-e^{-\Omega(M)}$, because some atom carries both labels. Whether an undefined posterior counts as a failure is a convention, fixed in §6.2.
   - *TUBE$_\rho$ with $\rho<1$, without replacement* (Proposition 6.5): every posterior draw and the posterior mean have excess at least $\frac nM(b-\rho)^2$ at every $\sigma$, where $b$ is the noise amplitude. Sampling without replacement lies outside (P$_L$), which assumes i.i.d. data.
   - *Every tolerance schedule* (Proposition 6.6): with non-centred $\pm1$ labels, TUBE$_\rho$ violates (P$_L$) for every schedule $\rho(n)$, under either convention, at every depth and width, already at a fixed input dimension.
7. **Claim A′ (Theorem 7.2, Proposition 7.4).** The inputs are absolutely continuous: tiny corner cubes of side $r(n)=\frac1n\big(\frac{L}{\max\{n/c+t,K_{\rm mem}\}}\big)^{L/2}$, where $t$ is the near-minimizer slack. The label is the deterministic function $f^\star(x)=+1$ if $|x_1|>1-r/2$ and $-1$ otherwise. The same lower bound $1+\beta_n-o(1)$ holds, while the Bayes risk is $0$ and every network of width $m$ with weights at most $B$ has risk at least $1-\frac r2B^Lm^H\sqrt d$. This meets the objections "real inputs do not repeat" and "real labels are deterministic" formally. The law is nevertheless near-atomic at the learner's resolution. Its density is $r^{-d}$ times uniform, which is $2^{(1+L/2)d^2(1-o(1))}$ at $c=1$, for example $10^{287}$ at $(H,d)=(2,20)$. The Lipschitz transfer in the proof cannot reach laws whose density ratio is $2^{o(d^2)}$ (Proposition 7.4).
8. **The exponent $1/H$ is optimal (§8).**
   - *Energy lower bound* (Proposition 8.2(a)): any family of networks of energy at most $K$ that fits **every** sign pattern on $s$ distinct cube points to sup-accuracy $a<1$ needs $K\ge H\big(\frac{(1-a)\sqrt s}{D_{d,H}}\big)^{2/H}$, with $D_{d,H}=\sqrt{2\log2}\,(d+1)+\frac{H-1}2$. Proposition 8.2(b) gives the same order for fitting most patterns in mean square. Lemma 2.1 is therefore sharp in $s$ up to a factor $O(d^{3/H})$.
   - *Learner side* (Proposition 8.3): for $n^{1-\vartheta}\le c=o(n)$ with $0<\vartheta<1/H$, near-minimizers on the cube example do not memorize. The critical memorization scale is therefore $c=n^{1-1/H}$ up to polylogarithmic factors.
9. **Checks (§9).** The parity–tanh identity, the coefficient bounds, an explicit construction of the memorizer with exact energy, the chain inequality, $\beta(\lambda)$ and the concentration of $Q$, and a small-$d$ optimization of $F_c$ were all checked numerically. This revision adds checks of Table 4.1 with continuous optimization in $a$, of the fixed-$d$ bound of Proposition 5.2, of the density estimates of Proposition 7.4 and of the TUBE probabilities of Proposition 6.6.
10. **Not proved (§10).** The conjecture itself is not refuted. Open or not covered: fixed input dimension beyond the cube family; input laws with density ratio $2^{o(d^2)}$ and noisy labels; depth two; learner widths below $N_0$; the progressive-mixture predictor; unclipped predictors for $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$; TUBE on continuous i.i.d. inputs. The finite-scale prior is treated in ../research-notes/E-finite-prior-scale.md.

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
Here $p_\sigma>0$: the set $\mathcal N_t$ contains the ball $B(w^*,\delta)$ of Lemma 3.2, which has positive Lebesgue measure, and $\Pi_\sigma$ has a positive density, so the conditional expectations are defined. As $\sigma\to0$, $p_\sigma\to1$ and $T_\sigma\to0$. For every $x\in\mathbb R^d$,
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

For every $\lambda$, $1+\beta_n$ is the expected test risk of the atom-mean predictor, which predicts $\bar y_x$ at seen atoms and $0$ elsewhere: by Lemma 4.2(a) its risk is $1+Q/M$, and $\mathbb EQ/M=\beta_n$ by (a). At an atom seen $k$ times its excess is the variance $1/k$ of a mean of $k$ fair signs, so its risk there is $R^*(1+1/k)$ with $R^*=1$. This is the variance identity behind Cover's (1968) nearest-neighbour estimation risk, here averaged over the random count $k$ (`../research-notes/literature.md`, item G1).

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

**Corollary 4.5.** Fix $H\ge2$, $\lambda\in(0,\infty)$ and $t>0$. Let $n=n_d$ be integers with $\lambda_d:=n_d/2^d\to\lambda$, and let $c=c_d>0$ satisfy
$$c_d\big(d^2\log^2(d+1)+(dn_d)^{1/H}\big)=o(n_d)\qquad(d\to\infty). \tag{4.4}$$
Put $a_d=(\max\{c_d,1\}/2^d)^{1/3}$ and $\delta_d=\exp(-2^{d/2})$. Condition (4.4) implies $c_d=o(2^d)$, so $a_d\le1$ for all large $d$. For every such $d$, (i)–(iv) of Theorem 4.4 hold with probability at least $1-\exp(-2^{d/2})$, at every width $N\ge N_0(d,\min\{n_d,2^d\},a_d)$. That threshold is at most $45\,d(d+1)\,2^{5d/3}=O(d^2n_d^{5/3})$. The quantity $\epsilon$ of (4.3) satisfies $\epsilon\le\bar\epsilon_d$, where
$$\bar\epsilon_d=\frac{c_d\big(d(d+1)\alpha_d^2+t\big)}{2^d}+\frac{(H+1)\,c_d\big((8dn_d)^{1/H}+\frac{9}{2a_d}\big)}{2^d}+\lambda_da_d^2\ \longrightarrow\ 0,$$
and the certified excess satisfies
$$\underline e_d\ \ge\ \Big(\sqrt{\big(\beta(\lambda_d)-\lambda_d2^{-d}-\sqrt{2\lambda_d}\,2^{-d/4}\big)_+}-\sqrt{\bar\epsilon_d}\Big)_+^2\ \longrightarrow\ \beta(\lambda).$$
For $c_d\equiv1$ and $n_d=2^d$, the limit is $\beta(1)=0.4848$. Since $n_d\asymp2^d$ and $d\asymp\log_2 n_d$, condition (4.4) is equivalent for large $d$ to $c_d=o\big(n_d^{1-1/H}d^{-1/H}\big)$, which is the brief's condition $c\,K_{\rm mem}=o(n)$.

*Proof.*

* **Range of $d$.** By (4.4), $c_d\le c_d(dn_d)^{1/H}=o(n_d)=o(2^d)$. So $\max\{c_d,1\}\le2^d$, that is $a_d\le1$, for all large $d$, and Lemma 2.1 applies there.
* **Threshold.** $N_0\le\frac{64\log 2\,d(d+1)2^d}{a_d^2}+1\le 44.4\,d(d+1)2^{5d/3}+1$, using $s\le2^d$ and $a_d^{-2}\le2^{2d/3}$.
* **Slope bound.** $\alpha_d=0.866\ldots+\frac14\log d\le1.5\log(d+1)$ for $d\ge1$, so $d(d+1)\alpha_d^2\le4.5\,d^2\log^2(d+1)$.
* **The bound $\epsilon\le\bar\epsilon_d$.** In (4.3), $\epsilon=c_d(K_{\rm mem}+t)/2^d+\lambda_da_d^2$. Bound $\max\{u,v\}\le u+v$ inside $K_{\rm mem}$, and use $s=\min\{n_d,2^d\}\le n_d$.
* **Each term of $\bar\epsilon_d$ tends to $0$.**
  * The first term tends to $0$ by the slope bound, (4.4) and $c_d=o(2^d)$, since $n_d\asymp2^d$ and $t$ is fixed.
  * The $(8dn_d)^{1/H}$ term tends to $0$ by (4.4).
  * $\frac{9(H+1)c_d}{2a_d2^d}\le\frac{9(H+1)}2\max\{c_d,1\}^{2/3}2^{-2d/3}\to0$, because $c_d=o(2^d)$.
  * $\lambda_da_d^2=\lambda_d(\max\{c_d,1\}/2^d)^{2/3}\to0$.
* **Concentration term.** $\sqrt{2\lambda_d\log(1/\delta_d)/2^d}=\sqrt{2\lambda_d}\,2^{-d/4}$.
* **Poisson limit.** Lemma 4.3(c) gives $\beta_{n_d}\ge\beta(\lambda_d)-\lambda_d2^{-d}$, and $|\beta(\lambda_d)-\beta(\lambda)|\le|\lambda_d-\lambda|\to0$.
* **Monotonicity.** $\underline e$ in (4.3) is nondecreasing in $\beta_n$ and nonincreasing in $\epsilon$. This gives the displayed lower bound and its limit.
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

**Remark 4.7 (explicit sizes).** Table 4.1 lists the certified excess $\underline e$ of (4.3) for $c=1$, $t=1$ and $\delta=0.01$, with $a$ optimized continuously and separately for each $\lambda$. It comes from `A_r1_scripts/r1_table41.py`, which replaces the logarithmic grid in $a$ of the first version (`A_scripts/bounds_table.py`). The values of $\underline e$ and $K_{\rm mem}$ agree with the first version to the printed digits. Four entries of the optimizing-$a$ column changed, and the $N_0$ column is new.

| $H$ | $d$ | $\underline e$ at $\lambda=1$ ($\beta_n=0.4848$) | $\underline e$ at $\lambda=1.5$ ($\beta_n=0.5174$) | optimizing $a$ at $\lambda=1$ | $K_{\rm mem}$ | $N_0$ |
|---|---|---|---|---|---|---|
| 2 | 20 | 0.249 | 0.272 | $3.5\cdot10^{-4}$ | $4.0\cdot10^4$ | $1.6\cdot10^{17}$ |
| 2 | 30 | 0.434 | 0.464 | $8.9\cdot10^{-6}$ | $1.5\cdot10^6$ | $5.6\cdot10^{23}$ |
| 2 | 40 | 0.475 | 0.507 | $2.4\cdot10^{-7}$ | $5.6\cdot10^7$ | $1.4\cdot10^{30}$ |
| 2 | 60 | 0.4845 | 0.5170 | $2.0\cdot10^{-10}$ | $7.1\cdot10^{10}$ | $4.7\cdot10^{42}$ |
| 3 | 20 | 0.406 | 0.435 | $8.2\cdot10^{-3}$ | $3.3\cdot10^3$ | $2.9\cdot10^{14}$ |
| 3 | 30 | 0.478 | 0.510 | $7.1\cdot10^{-4}$ | $2.8\cdot10^4$ | $8.9\cdot10^{19}$ |
| 3 | 40 | 0.4841 | 0.5166 | $6.4\cdot10^{-5}$ | $2.9\cdot10^5$ | $2.0\cdot10^{25}$ |
| 4 | 30 | 0.479 | 0.511 | $2.2\cdot10^{-3}$ | $1.3\cdot10^4$ | $9.3\cdot10^{18}$ |

The bound comes within $0.011$ of $\beta_n$ at $d=40$ for $H=2$ (the gap is $0.0099$ at $\lambda=1$ and $0.0102$ at $\lambda=1.5$), and within $0.008$ at $d=30$ for $H=3$.

The width threshold $N_0$ at the optimizing $a$ is polynomial in $n$ but astronomically large: $3\cdot10^{14}$ to $5\cdot10^{42}$ in the table. With a fixed accuracy $a$ instead, $N_0=O(d^2n/a^2)=O(n\log^2n/a^2)$ and $\underline e\to\big(\sqrt{\beta(\lambda)}-a\sqrt\lambda\big)_+^2$. For example, $a=0.1$ and $\lambda=1$ give $0.356$, with $N_0/n$ between $1.9\cdot10^6$ and $7.3\cdot10^6$ for $d\in[20,40]$; $a=0.3$ gives $0.157$, with $N_0/n$ between $2.1\cdot10^5$ and $8.1\cdot10^5$.

The constants also matter for the admissible $c$. The largest $c$ certifying $\underline e\ge\beta_n/2$ at $\lambda=1$, with $a$ optimized continuously, is $29$ at $(H,d)=(2,30)$ and $1.6\cdot10^3$ at $(3,30)$. For comparison, $n^{1-1/H}d^{-1/H}=6.0\cdot10^3$ and $3.4\cdot10^5$. The asymptotic condition (4.4) is unaffected.

**Remark 4.8 (the constant is attained by the comparator).** The comparator satisfies $|z_{w_0}-\bar y\mathbf 1_{\mathcal S}|<a$ on all of $\mathcal C_d$. Hence $L_{D_d}(z_{w_0})\le1+\frac1M(\sqrt Q+a\sqrt M)^2=1+Q/M+O(a)$, and $1+\beta(\lambda)$ is the exact limiting risk of the memorizer. Near-minimizers can be worse, because they may also be nonzero on unseen atoms. In the $d=8$ experiments of §9, unseen atoms contribute $0.11$ to $0.17$ of the excess.

**Remark 4.9 (consistency with the repository).** SP$_1$ is the learner of the strong-prior theorem of `NNG/works-in-progress/slt-likelihood/README.md` §2, which proves polynomial sample bounds for **clean** labels at every width. Its proof uses the residual budget $c(E_*+1)=O(1)$, which is available because the teacher fits clean labels exactly. With label noise the teacher's own training residual is $\sum_i(g(x_i)-y_i)^2\approx n\,\mathbb E\,{\rm Var}(y\mid x)$, and that budget is gone. Theorem 4.4 shows that the failure of the proof is a failure of the learner. On the cube example with $n\asymp2^d$ the memorizer costs energy $o(n)$, and its training residual is at most $W+na^2$ (Lemma 4.1), which is smaller than the teacher's residual $n$ by $\Theta(n)$, since $\mathbb EW=n-\mathbb E|\mathcal S|$. The note's finite-scale theorem is not treated here; ../research-notes/E-finite-prior-scale.md treats the finite-scale learner.

The noisy-interpolation note bounds clean classification error under a small corruption rate, with distinct inputs and global margin conditioning. At the fair-coin noise level its bound is vacuous, so there is no conflict.

---

## 5. Why Claim A refutes (P$_L$) for tightly conditioned SP$_c$

### 5.1 The property refuted

Write the brief's §1 property for a learner family $\mathsf A$ at depth $L$ as follows.

> **(P$_L$)** There is a polynomial $\mathsf p$ with the following property. For every $d\ge1$, every law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, every competitor $g$ of depth $L$, width $m$ and weights bounded by $B$, every learner width $N\ge m$, all $\varepsilon,\delta\in(0,1)$, and all $n\ge\mathsf p(d,m,B,1/\varepsilon,\log(1/\delta))$:
> $$\Pr\big[L_D(\mathsf A_n)\le L_D(g)+\varepsilon\big]\ge1-\delta.$$

(P$_L$) is a property of one learner, and it is uniform over the input dimension $d$: the threshold $\mathsf p(d,\dots)$ must work for every $d$ at once. The user's conjecture asserts that some Bayesian learner has it (§5.4).

For SP$_c$ the output $\mathsf A_n$ must be specified. We allow the most lenient readings.

* **(R1)** A Gibbs draw from $\Pi^c_{\sigma,S}$, with probability taken over the sample and the draw. The property is required for all $\sigma\in(0,\sigma_0)$, where $\sigma_0>0$ may depend on $d,n,N,D,g,\varepsilon,\delta$. This is more lenient than the repository's strong-prior theorems. In `paper.tex` Theorem `strong` the scale threshold may depend on the width, the teacher, $\rho$ and $\varepsilon$, but "does not depend on $D,n,\delta$". In the strong-prior theorem of `slt-likelihood/README.md` §2 it "may depend on the selected $n,N$, the teacher, and the accuracy parameters" and is uniform over $D$.
* **(R2)** The same, with the output one of $\bar z_{\Pi_\sigma}$, ${\rm clip}\circ\bar z_{\Pi_\sigma}$ or $\int{\rm clip}(z_w)\,d\Pi_\sigma$.
* **(R3)** Any point of $\mathcal N_t(S)$, for a fixed $t>0$, chosen by any rule. No measurability is required of the rule. The probability in (P$_L$) is then read as an outer probability, and the bounds below hold because the event in question is contained in a measurable event of small probability.

These readings cover the MAP estimate and every weak limit of $\Pi_\sigma$ as $\sigma\to0$, since both are carried by $\arg\min F_{c,S}\subseteq\mathcal N_t$. They do not cover the progressive-mixture predictor of brief §2 (the average over prefixes $t=0,\dots,n$ of posterior means), which is not treated here (§10).

**Proposition 5.1.** Fix $L\ge3$ and $t>0$. Let $c>0$ be fixed, or let $c=c(n)$ be such that $c_d:=c(2^d)$ satisfies (4.4) with $n_d=2^d$. Then SP$_c$ does not have property (P$_L$) under any of the readings (R1)–(R3). More precisely, take the competitor $g\equiv0$, any $\varepsilon\in(0,\beta(1))$ and any $\delta\in(0,1)$. For all sufficiently large $d$, at $n=2^d$ and at every learner width $N\ge N_0(d,2^d,a_d)$, the probability in (P$_L$) is below $1-\delta$ for all sufficiently small $\sigma$. In fact, for every $\epsilon'>0$ it is at most $e^{-2^{d/2}}+\epsilon'$ once $\sigma$ is below a threshold depending on $(d,N,c,t,\epsilon')$.

*Proof.*

* **Setup.** Suppose $\mathsf p$ exists. Take the competitor $g\equiv0$: width $m=1$ and all weights $0$, so the bound $B=1$ holds. Fix $\varepsilon\in(0,\beta(1))$ and $\delta\in(0,1)$, and put $\gamma=(\beta(1)-\varepsilon)/2>0$. Then $q(d)=\mathsf p(d,1,1,1/\varepsilon,\log(1/\delta))$ is a polynomial in $d$, so $2^d\ge q(d)$ for all $d\ge d_1$.
* **What (P$_L$) would give.** For such $d$, (P$_L$) applies to $D=D_d$ and $n=2^d$, at every learner width. In particular it applies at every $N\ge N_0(d,2^d,a_d)$ of Corollary 4.5, where it requires $\Pr[L_{D_d}(\mathsf A_n)\le1+\varepsilon]\ge1-\delta$.
* **What Corollary 4.5 gives.** Apply it with $\lambda=1$ and the fixed $t$. Since $\underline e_d\to\beta(1)$, there is $d_2$ such that for $d\ge d_2$ we have $a_d\le1$, $\underline e_d\ge\varepsilon+\gamma$ and $e^{-2^{d/2}}<\frac{1-\delta}2$. Fix $d\ge\max\{d_1,d_2\}$. The event $\mathcal E$ of Theorem 4.4 has probability at least $1-e^{-2^{d/2}}$.
* **(R3).** On $\mathcal E$ every point of $\mathcal N_t(S)$ has $L_{D_d}\ge1+\varepsilon+\gamma>1+\varepsilon=L_{D_d}(g)+\varepsilon$. So the event $\{L_{D_d}(\mathsf A_n)\le L_{D_d}(g)+\varepsilon\}$ is contained in $\mathcal E^c$, and its outer probability is at most $e^{-2^{d/2}}<1-\delta$.
* **(R1).** Apply Theorem 4.4(iv) with $\epsilon'=\frac{1-\delta}2$. For $\sigma<\sigma_0'$,
  $$\Pr[L_{D_d}(\mathsf A_n)\le1+\varepsilon]\le\Pr(\mathcal E^c)+\sup_{S\in\mathcal E}\Pi_{\sigma,S}(\mathcal N_t^c)<\tfrac{1-\delta}2+\tfrac{1-\delta}2=1-\delta .$$
* **(R2).** Apply Theorem 4.4(iv) with $\epsilon'=\gamma/2$. For $\sigma<\sigma_0'$, on $\mathcal E$, $L_{D_d}(f_\sigma)\ge1+\varepsilon+\gamma/2>1+\varepsilon$. So the probability is at most $\Pr(\mathcal E^c)<1-\delta$.
* **Conclusion.** In each case (P$_L$) would require probability at least $1-\delta$ for all small $\sigma$, which fails. The same estimates with an arbitrary $\epsilon'>0$ give the bound $e^{-2^{d/2}}+\epsilon'$. $\square$

### 5.2 Fixed input dimension

The counterexample of Proposition 5.1 needs $d\to\infty$. At a fixed $d$ the cube family is consistent, at every width, by a comparison with the zero network.

**Proposition 5.2 (fixed dimension: the cube example is consistent at every width).** Fix $d\ge1$, $H\ge1$ and $c,t>0$, and let $S\sim D_d^{\otimes n}$. Put $\Delta_0=\Delta(0)=\sum_{x\in\mathcal S}k_x\bar y_x^2$ and $k_{\min}=\min_{x\in\mathcal C_d}k_x$, and on $\{k_{\min}\ge1\}$ put
$$U_S=\frac1M\Big(\sqrt{\frac{\Delta_0+ct}{k_{\min}}}+\sqrt{\frac{\Delta_0}{k_{\min}}}\Big)^2\ \le\ \frac{2\,(2\Delta_0+ct)}{M\,k_{\min}} .$$

* (a) On $\{k_{\min}\ge1\}$, at every width $N$, every $w$ with $F_{c,S}(w)\le F_{c,S}(0)+t$, in particular every $w\in\mathcal N_t(S)$, satisfies $L_{D_d}(z_w)\le1+U_S$ and $L_{D_d}({\rm clip}\circ z_w)\le1+U_S$.
* (b) On the same event, fix a width $N$, keep $n$ and the sample fixed, and let $\sigma\to0$. Then $\Pi_\sigma\{w:L_{D_d}(z_w)\le1+U_S\}\ge p_\sigma\to1$ and $\limsup_{\sigma\to0}\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\le1+U_S$. Each of the three posterior means $f_\sigma$ of Theorem 4.4(iii) satisfies $\limsup_{\sigma\to0}L_{D_d}(f_\sigma)\le1+U_S$.
* (c) For every $\delta'\in(0,1)$, with probability at least $1-\delta'-Me^{-n/(8M)}$, we have $k_{\min}\ge n/(2M)$, hence $k_{\min}\ge1$, and $U_S\le(8M/\delta'+4ct)/n$.

Consequently, for $\varepsilon,\delta\in(0,1)$ and
$$n\ \ge\ \max\Big\{8M\log\frac{2M}\delta,\ \frac{16M/\delta+4ct}{\varepsilon}\Big\},$$
with probability at least $1-\delta$ every near-minimizer at every width has excess at most $\varepsilon$ over the Bayes risk $1$, and so do the $\sigma\to0$ limits in (b).

*Proof.*

(a)

* **Residual comparison.** By Lemma 4.1(a), $F_{c,S}(w)=\kappa_N(w)+(\Delta(z_w)+W)/c$ and $F_{c,S}(0)=(\Delta_0+W)/c$. So $F_{c,S}(w)\le F_{c,S}(0)+t$ gives $\Delta(z_w)\le\Delta_0+ct-c\,\kappa_N(w)\le\Delta_0+ct$. Every $w\in\mathcal N_t(S)$ qualifies, because $\inf F_{c,S}\le F_{c,S}(0)$.
* **All atoms seen.** On $\{k_{\min}\ge1\}$ we have $\mathcal S=\mathcal C_d$, $\sum_x(z_w(x)-\bar y_x)^2\le\Delta(z_w)/k_{\min}$ and $\sum_x\bar y_x^2\le\Delta_0/k_{\min}$.
* **Minkowski.** $\big(\sum_xz_w(x)^2\big)^{1/2}\le\big(\sum_x(z_w-\bar y)^2\big)^{1/2}+\big(\sum_x\bar y^2\big)^{1/2}$. With Lemma 4.2(a) this gives $L_{D_d}(z_w)-1=\frac1M\sum_xz_w(x)^2\le U_S$. The second form of $U_S$ is $(u+v)^2\le2u^2+2v^2$.
* **Clipping.** $|{\rm clip}\,u|\le|u|$, so the same bound holds for ${\rm clip}\circ z_w$.

(b)

* **Gibbs.** By (a), $\mathcal N_t\subseteq\{L_{D_d}(z_w)\le1+U_S\}$, and $p_\sigma=\Pi_\sigma(\mathcal N_t)\to1$ by Corollary 3.3.
* **Gibbs expectation.** Lemma 3.1(a) gives $L_{D_d}(z_w)=1+\frac1M\sum_xz_w(x)^2\le1+\kappa_N(w)\le1+F_{c,S}(w)$. Hence $\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\le1+U_S+\int_{\mathcal N_t^c}(1+F_{c,S})\,d\Pi_\sigma$, and the integral tends to $0$ by Lemma 3.2 with $p=1$.
* **Posterior means.** The map $v\mapsto\sum_xv_x^2$ on $\mathbb R^{\mathcal C_d}$ is convex. By Corollary 3.3 (Jensen), $\sum_xm_\sigma(x)^2\le\sup_{\mathcal N_t}\sum_xz_w(x)^2\le MU_S$, and likewise $\sum_xm^{\rm cl}_\sigma(x)^2\le MU_S$. By (3.3), $\max_x|\bar z_{\Pi_\sigma}(x)-m_\sigma(x)|\le\varsigma_\sigma$ with $\varsigma_\sigma=(1-p_\sigma)\sqrt{n/c+t}+T_\sigma\to0$. So $L_{D_d}(\bar z_{\Pi_\sigma})\le1+(\sqrt{U_S}+\varsigma_\sigma)^2$, and the same holds for ${\rm clip}\circ\bar z_{\Pi_\sigma}$ because $|{\rm clip}\,u|\le|u|$. For $\int{\rm clip}(z_w)\,d\Pi_\sigma$ use $m^{\rm cl}_\sigma$ and the bound $2(1-p_\sigma)$ of (3.3).

(c)

* **Size of $\Delta_0$.** For fair labels, $\mathbb E[k_x\bar y_x^2\mid k_x=k]=k^{-1}\mathbb E\big(\sum_{j\le k}y_j\big)^2=1$ for $k\ge1$. So $\mathbb E\Delta_0=\sum_x\Pr[k_x\ge1]\le M$, and Markov's inequality gives $\Pr[\Delta_0>M/\delta']\le\delta'$.
* **Size of $k_{\min}$.** Each $k_x\sim{\rm Bin}(n,1/M)$. The Chernoff bound $\Pr[{\rm Bin}(n,p)\le np/2]\le e^{-np/8}$ and a union bound over the $M$ atoms give $\Pr[k_{\min}<n/(2M)]\le Me^{-n/(8M)}$. Since $k_{\min}$ is an integer and $n/(2M)>0$, $k_{\min}\ge n/(2M)$ implies $k_{\min}\ge1$.
* **Conclusion.** On both events, $U_S\le\frac{2(2M/\delta'+ct)}{M\,n/(2M)}=\frac{8M/\delta'+4ct}{n}$.

For the consequence take $\delta'=\delta/2$. The first condition on $n$ makes $Me^{-n/(8M)}\le\delta/2$, and the second makes $(16M/\delta+4ct)/n\le\varepsilon$. $\square$

So the constant excess of Theorem 4.4 needs $d\to\infty$. At a fixed $d$ the cube family certifies only an excess of order $M/n$, uniformly in the width. Table 5.1 (`A_r1_scripts/r1_fixed_d.out`, $c=t=1$, 400 samples per entry, 100 at $(d,n/M)=(8,1024)$) gives the median of $U_S$.

| $n/M$ | 16 | 64 | 256 | 1024 |
|---|---|---|---|---|
| median $U_S$, $d=6$ | 0.547 | 0.088 | 0.018 | 0.0042 |
| median $U_S$, $d=8$ | 0.669 | 0.095 | 0.019 | 0.0043 |
| $\beta(n/M)$, Theorem 4.4's lower bound | 0.067 | 0.016 | 0.0039 | 0.00098 |

For $n/M\le4$ some atom is usually unseen and $U_S$ is infinite. For large $n/M$ the median decays like $4M/n$: at $d=8$ its ratio to $M/n$ is $6.1$, $4.8$ and $4.4$ at $n/M=64$, $256$ and $1024$. The script also ran L-BFGS on $F_c$ at $d\in\{4,5\}$ and $n/M\in\{16,64\}$. Each network found had $F_c\le F_c(0)+t$ and an excess between $0.007$ and $0.051$, below $U_S$.

Proposition 5.2 concerns the cube family only. Whether another law at a fixed $d$ defeats tightly conditioned SP$_c$ is not settled here (§10).

### 5.3 Discussion

1. **Where the failure lives.** (P$_L$) asserts the bound for **all** $n$ above a threshold polynomial in $d$, with $m,B,\varepsilon,\delta$ fixed. Eventually $2^d$ exceeds every polynomial, whatever its degree and whether or not its exponents are fractional. So the threshold is passed at $n=2^d$, where Theorem 4.4 applies. The proved excess is $\Omega(1)$ only in the window $n=\Theta(2^d)$. For $n=o(2^d)$ the certified lower bound $\beta(n/2^d)\sim n/2^d$ vanishes, and whether the learner is then good depends on its values at unseen atoms, which are not controlled (Remark 4.8). For $n\gg2^d d$, Proposition 5.2 gives excess $O(2^d/n)$ at every width. Nothing is claimed about the learner's performance for $n=o(2^d)$.
2. **The competitor is trivial, and the $o(1)$ must be uniform in $d$.** $g\equiv0$ has width one and zero weights, so this is not an approximation failure. The learner is worse than the trivial predictor, which is Bayes-optimal here, by a constant. The brief also reads the conjecture as "test loss at most the minimum over networks with width and weights at most $n^\alpha$, plus $o(1)$". That reading is refuted for every $\alpha>0$ provided the $o(1)$ term is uniform over the input dimensions $d\le\log_2n$, for example a function of $n$ alone that bounds the excess for all $d\le n^\alpha$, or more generally whenever the term vanishes along $n=2^d$, as ${\rm poly}(d)\,n^{-\gamma}$ does. The reason is that $g\equiv0$ belongs to every such class and the excess is $\Omega(1)$ along $n=2^d$. If the term may depend on $d$ arbitrarily, or on the law, the cube family refutes nothing, because at fixed $d$ the excess is $O(2^d/n)$ (Proposition 5.2). Bounding the competitors' weights changes nothing.
3. **Learner width (scope).** The failure holds at every $N\ge N_0={\rm poly}(n)$. It therefore refutes the width-uniform formulation ("every learner width $N\ge m$", brief §1), and any formulation that admits some learner width at least $N_0$. With a fixed accuracy $a$, $N_0=O(n\log^2n/a^2)$ already gives excess at least $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2-o(1)$ (Remark 4.7); there $N_0/n$ is between $2\cdot10^5$ and $7\cdot10^6$ for $d\in[20,40]$ and $a\in\{0.1,0.3\}$. Nothing is proved for $N<N_0$, in particular for $N=O(n)$. At $N\le n^{1/2-\epsilon}$ and depth $L\ge3$ the parameter count is $o(n)$, and `../research-notes/red-team.md` Proposition 6.1, a parameter-counting sketch I have not checked, argues a positive oracle inequality for $c=1$ at learner width $\lceil n^\alpha\rceil$ with $\alpha<1/4$. Such formulations are outside the scope of this section.
4. **Depth.** The proof needs $L\ge3$. For depth two see Remark 2.5 and §10.
5. **Range of likelihood scalings.** The failure holds for every $c=o(n^{1-1/H}d^{-1/H})$ along $n\asymp2^d$. This includes the clean-label scaling $c=1$ of the strong-prior theorem of `slt-likelihood/README.md` §2. That note also proves a finite-scale theorem, which this section does not treat (see ../research-notes/E-finite-prior-scale.md). By Proposition 8.3, near-minimizers stop fitting the noise once $n^{1-\vartheta}\le c=o(n)$ with $0<\vartheta<1/H$.

### 5.4 What is and is not refuted

**The property and the learners.** Proposition 5.1 refutes (P$_L$) for SP$_c$ whenever $c\,K_{\rm mem}=o(n)$ along $n=2^d$, and Proposition 6.6 refutes it for TUBE$_\rho$ at every tolerance schedule. Both learners condition tightly on each training output.

**The conjecture.** The user's sentence lets us pick the Bayesian learner, so in the brief's formalization the conjecture holds if some learner has (P$_L$). The sibling sections give such learners. I checked each statement below in its source.

* ../research-notes/B-tempered-likelihood.md Theorem 6.3: SP$_c$ with $c=n^{1-\theta}$, $0<\theta<1/H$. For every law $D$ on $X\times[-1,1]$, every competitor of depth $L$, width $m$ and weights in $[-B,B]$, and every learner width $N\ge m$, the near-minimizers, the Gibbs draw and the posterior mean of the clipped outputs have $L_D\le L_D(g)+\varepsilon$ with probability at least $1-\delta$, once $n\ge n_0$, polynomial in $(d,m,B,1/\varepsilon,\log(1/\delta))$. ../research-notes/B-tempered-likelihood.md Theorem 6.4 gives the unclipped outputs for $\theta<1/L$. ../research-notes/B-tempered-likelihood.md Corollary 8.1 gives the reading "minimum over networks of width and weights at most $n^\alpha$, plus $O(n^{-\beta})$" for $\alpha<1/(4H)$. The three referee reports on ../research-notes/B-tempered-likelihood.md (`B-logic.md`, `B-computation.md`, `B-scope.md`) found these theorems correct, with minor fixes.
* ../research-notes/E-finite-prior-scale.md Theorem 2.7: the finite-scale analogue, with prior $\mu_{N,\gamma}$, $\gamma\ge1$, and no limit. It covers the clipped Gibbs and posterior-mean predictors at every width $N\ge m$, for $\theta$ below a threshold $\theta_{L,\gamma}$ that equals $1/H$ when $\gamma\ge2-1/H$. The case $\gamma=1$, $L\ge3$ uses an imported mean-field cover. One referee report (`E-logic.md`) found it correct, with minor fixes.
* `../research-notes/red-team.md` Remark 6.2 sketches a third learner, which conditions on the empirical MSE being below $\tau\approx{\rm OPT}$. It is an unrefereed sketch, and $\tau$ must be supplied.

There are limits on how far this goes. Within SP$_c$, for competitors whose width and weights are at most $n^\alpha$, no choice of $c(n)$ works once $\alpha>L/(2H(2L-1))$ (../research-notes/B-tempered-likelihood.md Corollary 9.3). Whether another Bayesian learner reaches further is not addressed here or in ../research-notes/B-tempered-likelihood.md.

**The heuristic.** What fails is the user's auxiliary heuristic that the learner should condition closely on the training outputs. On the noisy cube at $\lambda=1$, every near-minimizer of the tightly conditioned learner has training MSE at most $W/n+o(1)$ (Lemma 4.1(b)), where $\mathbb EW/n=1-\mathbb E|\mathcal S|/n\to e^{-1}\approx0.37$. That is well below the noise level $1$, and the learner pays the difference back at test time (Theorem 4.4). Tempering with $c=n^{1-\theta}$, $\theta<1/H$, makes memorization too expensive (Proposition 8.3) and restores (P$_L$) (../research-notes/B-tempered-likelihood.md).

**Uniformity in $d$.** The SP$_c$ refutation is a statement about sample bounds that are uniform over the input dimension, the repository's convention (`NNG/README.md`, main result 1). At a fixed $d$ the cube family is consistent (Proposition 5.2).

---

## 6. Variants

### 6.1 SP$_c$ with sampling without replacement

Let $1\le n\le M$. The inputs are $n$ distinct points of $\mathcal C_d$, for example a uniformly random ordered $n$-subset; any rule producing distinct points works. Given the inputs, the labels are independent, each drawn from the conditional law of $D$. The test law $D$ has uniform $x$-marginal.

**Proposition 6.1.** Fix $H\ge2$, $c,t>0$ and $a\in(0,1]$, and put $\epsilon'=\frac{c\,(K_{\rm mem}(d,n,a,H)+t)}{n}+a^2$. Let $N\ge N_0(d,n,a)$.

* (a) **Fair labels.** With probability one, every $w\in\mathcal N_t(S)$ satisfies $L_{D_d}(z_w)\ge1+\frac nM\big(1-\sqrt{\epsilon'}\big)_+^2$, and so does ${\rm clip}\circ z_w$. The Gibbs and posterior-mean statements (ii)–(iv) of Theorem 4.4 hold with this bound.
* (a′) **Upper bound at $n=M$.** If $n=M$, every $w\in\mathcal N_t(S)$ also satisfies $L_{D_d}(z_w)\le1+(1+\sqrt{\epsilon'})^2$, and so does ${\rm clip}\circ z_w$. Moreover $\limsup_{\sigma\to0}\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\le1+(1+\sqrt{\epsilon'})^2$, and each of the three posterior means $f_\sigma$ of Theorem 4.4(iii) has $\limsup_{\sigma\to0}L_{D_d}(f_\sigma)\le1+(1+\sqrt{\epsilon'})^2$. Hence, if $n=M$, $c\,K_{\rm mem}(d,M,a_d,H)=o(M)$ and $a=a_d\to0$, the test MSE tends to $2$, against a Bayes risk of $1$, for every near-minimizer, for the Gibbs draw (in posterior probability and in posterior expectation) and for the posterior means.
* (b) **General labels**, with $y\in[-1,1]$ and $V(x)\ge v_0$. With probability at least $1-\delta$, the lower bounds of (a) hold with the bound $L_D(\eta)+\Big(\sqrt{\big(\lambda v_0-\sqrt{8\lambda\log(1/\delta)/M}\big)_+}-\sqrt{\lambda\epsilon'}\Big)_+^2$, where $\lambda=n/M$.

*Proof.*

* **Atom structure.** All $k_x\in\{0,1\}$. So $\bar y_{x_i}=y_i$, $W=0$, $\Delta(f)=\sum_i(f(x_i)-y_i)^2$, and for fair labels $Q=n$ deterministically.
* **(a).** Lemma 2.1 applies to $r(x_i)=y_i$ with $r=0$ elsewhere, since $\sum r^2\le n$. With Lemma 4.1(b), $\Delta(z_w)\le c(K_{\rm mem}+t)+na^2=n\epsilon'$. Lemma 4.2(b) gives $L_{D_d}\ge1+\frac1M(\sqrt n-\sqrt{n\epsilon'})_+^2$. Statements (ii)–(iv) follow exactly as in Theorem 4.4.
* **(a′), near-minimizers.** At $n=M$ every atom is seen exactly once. Write $y_x$ for the label at $x$; then $\mathcal S=\mathcal C_d$, $\sum_xy_x^2=M$ and $\Delta(f)=\sum_x(f(x)-y_x)^2$. For $w\in\mathcal N_t(S)$, (a) gives $\Delta(z_w)\le M\epsilon'$, and Lemma 4.1(c) gives $\Delta({\rm clip}\circ z_w)\le M\epsilon'$. Minkowski's inequality in $\mathbb R^M$ gives $(\sum_xf(x)^2)^{1/2}\le\sqrt M+\sqrt{\Delta(f)}$. So $L_{D_d}(f)=1+\frac1M\sum_xf(x)^2\le1+(1+\sqrt{\epsilon'})^2$ for $f\in\{z_w,{\rm clip}\circ z_w\}$.
* **(a′), Gibbs expectation.** Lemma 3.1(a) gives $L_{D_d}(z_w)\le1+\kappa_N(w)\le1+F_{c,S}(w)$. So $\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\le1+(1+\sqrt{\epsilon'})^2+\int_{\mathcal N_t^c}(1+F_{c,S})\,d\Pi_\sigma$, and the integral tends to $0$ by Lemma 3.2 with $p=1$.
* **(a′), posterior means.** By Jensen's inequality (Corollary 3.3), $\Delta(m_\sigma)\le M\epsilon'$ and $\Delta(m^{\rm cl}_\sigma)\le M\epsilon'$, so $m_\sigma$ and $m^{\rm cl}_\sigma$ obey the bound of the previous bullet. By (3.3) and $|{\rm clip}\,u|\le|u|$, the three posterior means obey it with $\sqrt{\epsilon'}$ replaced by $\sqrt{\epsilon'}+\varsigma_\sigma$, where $\varsigma_\sigma\to0$.
* **(a′), limit.** If $\epsilon'\to0$, the lower bound of (a) at $n=M$ and the upper bound of (a′) both tend to $2$.
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

So the TUBE bias below is not an artefact of the limit $\sigma\to0$. At finite scale, however, the collapse is shown only as $N\to\infty$ at fixed $\gamma$. The TUBE statements that hold for every prior, at every scale and width, are Lemma 6.4(a), Proposition 6.5 and Proposition 6.6(b).

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

TUBE$_\rho$ at a fixed tolerance therefore cannot satisfy an MSE oracle inequality with $\varepsilon<\eta_0^2$, even for clean labels, because the minimum-energy feasible function is $0$. The continuous-domain paper's theorem is consistent with this: it measures error at a larger tolerance $\tau>\rho$ and is not an MSE statement. An MSE-consistent TUBE learner therefore needs $\rho=\rho_n\to0$. On laws with atoms the remaining results of this subsection then apply. Lemma 6.4 treats i.i.d. sampling, under the convention stated next. Proposition 6.5 treats sampling without replacement, which lies outside (P$_L$) because (P$_L$) assumes i.i.d. data. Proposition 6.6 covers every tolerance schedule for non-centred labels. For continuous i.i.d. inputs and $\rho<1$, the native setting of the TUBE learner's paper, nothing is proved here, and the construction A′ of §7 does not transfer (Remark 7.6).

**Convention for an empty tube.** When $U_{\rho,S}=\emptyset$, TUBE$_\rho$ has no posterior. We consider two conventions.

* **(U1)** The output is undefined, and an undefined output counts as a failure of the event $\{L_D(\mathsf A_n)\le L_D(g)+\varepsilon\}$ in (P$_L$).
* **(U2)** The learner falls back to the prior mean of $z_w$. For both priors this is the zero function: the readout $v$ is a centred Gaussian vector independent of the hidden weights, and $z_w(x)=v^\top h^H(x)$ is linear in $v$.

A learner with any other fallback is a different learner and is not treated. Under (U2), Lemma 6.4 below does not give a failure for fair labels, since the zero function is Bayes-optimal on $D_d$. Proposition 6.6 uses non-centred labels, for which both conventions give a failure.

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

**Proposition 6.6 (TUBE fails at every tolerance schedule).** Let $d\ge1$ and $\eta_0\in(0,1)$. Let $D^{\eta_0}_d$ have $x$ uniform on $\mathcal C_d$ and $y\in\{-1,1\}$ with $\Pr[y=1\mid x]=\frac{1+\eta_0}2$. Its regression function is the constant $\eta_0$. The width-one network $g\equiv\eta_0$ of Proposition 6.3, with weights at most $2$, attains the Bayes risk $L_D(g)=1-\eta_0^2$, and $L_D(0)=1$. Fix a depth $L\ge2$, a width $N\ge1$, a sample size $n\ge1$, a tolerance $\rho>0$ and $\varepsilon\in(0,\eta_0^2)$, and let $S\sim(D^{\eta_0}_d)^{\otimes n}$.

* (a) Let $\rho>1$ and let $\Pi^{\rm tube}$ be the TUBE$_\rho$ posterior of $\mu_\sigma$. As $\sigma\to0$, uniformly over samples, $\Pi^{\rm tube}\{w:L_D(z_w)\le L_D(g)+\varepsilon\}\to0$ and $\Pi^{\rm tube}\{w:L_D({\rm clip}\circ z_w)\le L_D(g)+\varepsilon\}\to0$. Each of the three posterior means $\bar z$, ${\rm clip}\circ\bar z$ and $\int{\rm clip}(z_w)\,d\Pi^{\rm tube}$ has risk tending to $L_D(g)+\eta_0^2$.
* (b) Let $\rho\le1$. For every prior, $\Pr_S[U_{\rho,S}\ne\emptyset]\le2\exp\big(-\frac{n(1-\eta_0)}{2M}\big)$. When $U_{\rho,S}=\emptyset$, the output is undefined under (U1), and under (U2) it is the zero function, whose excess is $\eta_0^2>\varepsilon$.

Consequently, let $\rho=\rho(n)$ be any tolerance schedule and $\delta\in(0,1)$, and read (P$_L$) for TUBE$_\rho$ with the output a draw from $\Pi^{\rm tube}$ or one of its posterior means, as in (R1)–(R2). Let $n>\frac{2M}{1-\eta_0}\log\frac2{1-\delta}$. If $\rho(n)\le1$, take any prior and either convention. If $\rho(n)>1$, take the strong prior and $\sigma$ below a threshold depending on $(d,L,N,\rho(n),\eta_0,\varepsilon,\delta)$. In both cases the probability that the output has $L_D\le L_D(g)+\varepsilon$ is below $1-\delta$. So TUBE$_\rho$ violates (P$_L$) for every schedule, at every depth and width, with a fixed input dimension and a fixed width-one competitor.

*Proof.*

(a) Every label satisfies $|y_i|\le1<\rho$.

* **An inner set that does not depend on the sample.** If $\kappa_N(w)<(\rho-1)^2$, then $|z_w(x_i)|<\rho-1$ by Lemma 3.1(a), so $|z_w(x_i)-y_i|<\rho$. Hence $\{\kappa_N<(\rho-1)^2\}\subseteq U_{\rho,S}$ for every sample. The proof of Lemma 6.2 therefore applies with $r_U=(\rho-1)^2$. For $P\sigma^2<(\rho-1)^2$ it gives $k_\sigma:=\mathbb E_{\Pi^{\rm tube}}\kappa_N\le P\sigma^2/\big(1-P\sigma^2/(\rho-1)^2\big)$, which tends to $0$ uniformly over samples.
* **Risks of single draws.** For $f\in\{z_w,{\rm clip}\circ z_w\}$, Lemma 3.1(a) and $|y|\le1$ give $|L_D(f)-L_D(0)|=|\mathbb E[f(x)^2-2yf(x)]|\le\kappa_N(w)+2\sqrt{\kappa_N(w)}$. By Jensen, $\mathbb E_{\Pi^{\rm tube}}|L_D(f)-L_D(0)|\le k_\sigma+2\sqrt{k_\sigma}$.
* **Gibbs.** Since $L_D(0)-L_D(g)-\varepsilon=\eta_0^2-\varepsilon>0$, Markov's inequality gives $\Pi^{\rm tube}\{L_D(f)\le L_D(g)+\varepsilon\}\le(k_\sigma+2\sqrt{k_\sigma})/(\eta_0^2-\varepsilon)\to0$.
* **Means.** Each posterior mean $\bar f$ satisfies $\sup_x|\bar f(x)|\le\mathbb E_{\Pi^{\rm tube}}\sqrt{\kappa_N}\le\sqrt{k_\sigma}$. So $|L_D(\bar f)-L_D(0)|\le k_\sigma+2\sqrt{k_\sigma}\to0$, and $L_D(0)=L_D(g)+\eta_0^2$.

(b) Fix one atom $e\in\mathcal C_d$ and put $p=\frac{1+\eta_0}2$.

* **Agreement at $e$.** Given $k_e=k\ge1$, the labels at $e$ are i.i.d. with $\Pr[y=1]=p$, so they all agree with probability $p^k+(1-p)^k$. For $k_e\sim{\rm Bin}(n,1/M)$ and $u\in[0,1]$, $\mathbb Eu^{k_e}=\big(1-\frac{1-u}M\big)^n$. Hence
  $$\Pr[\text{the labels at }e\text{ agree}]=\Big(1-\frac{1-p}M\Big)^n+\Big(1-\frac pM\Big)^n-\Big(1-\frac1M\Big)^n\le2\exp\Big(-\frac{n(1-p)}M\Big)=2\exp\Big(-\frac{n(1-\eta_0)}{2M}\Big).$$
  The inequality drops the negative term and uses $p\ge1-p$ and $1-u\le e^{-u}$.
* **A conflict empties the tube.** If two labels at $e$ differ, they differ by $2\ge2\rho$. Then $U_{\rho,S}=\emptyset$ by Lemma 6.4(a), for every prior.
* **Fallback.** Under (U2) the output is the zero function, and $L_D(0)-L_D(g)=\eta_0^2$.

*Consequence.* If $\rho(n)\le1$, the output can satisfy $L_D\le L_D(g)+\varepsilon$ only on $\{U_{\rho,S}\ne\emptyset\}$, whose probability is at most $2e^{-n(1-\eta_0)/(2M)}<1-\delta$ for the stated $n$. If $\rho(n)>1$, choose $\sigma_0$ by (a) so that, for $\sigma<\sigma_0$ and every sample, $(k_\sigma+2\sqrt{k_\sigma})/(\eta_0^2-\varepsilon)\le\frac{1-\delta}2$ and $k_\sigma+2\sqrt{k_\sigma}<\eta_0^2-\varepsilon$. Then a draw succeeds with probability at most $\frac{1-\delta}2$, and every posterior mean fails. Either way the probability is below $1-\delta$ at every $n$ beyond a threshold that does not depend on the polynomial $\mathsf p$, so no polynomial threshold works. $\square$

`A_r1_scripts/r1_tube_fixed_d.py` computes the probability that no atom carries both labels exactly, in rational arithmetic, for $d\in\{1,2,3\}$, $\eta_0\in\{\frac14,\frac12,\frac9{10}\}$ and $n\in\{4,16,64,256\}$. In all 36 cases it lies below the one-atom expression of (b), which lies below $2e^{-n(1-\eta_0)/(2M)}$, and Monte Carlo agrees with the exact value.

**Dependence on $\rho$ (summary).** Table 6.1 collects the cases. The without-replacement column lies outside (P$_L$), which assumes i.i.d. data.

| tolerance and labels | with replacement (i.i.d.) | without replacement |
|---|---|---|
| $\rho\le1$, fair $\pm1$ labels | $U_{\rho,S}=\emptyset$ with probability $1-e^{-\Omega(M)}$ at $n=\lambda M$ (Lemma 6.4). A failure under (U1); under (U2) the fallback $0$ is Bayes-optimal, so no failure | for $\rho<1$, excess $\ge\frac nM(1-\rho)^2$ at every $\sigma$ (Proposition 6.5) |
| $\rho\le1$, non-centred $\pm1$ labels | $U_{\rho,S}=\emptyset$ with probability $\ge1-2e^{-n(1-\eta_0)/(2M)}$, at every fixed $d$; a failure under (U1) and (U2) (Proposition 6.6(b)) | not treated |
| $\rho>1$, any labels in $[-1,1]$ | posterior collapses to the zero network; excess $\to\frac1M\sum\eta^2$, for example $\eta_0^2$ for non-centred $\pm1$ noise (Lemma 6.2, Propositions 6.3(a) and 6.6(a)) | same |
| any $\rho>0$, labels with $\lvert y\rvert<\rho$, including noiseless ones | collapse to $0$; excess $\eta_0^2$ (Proposition 6.3(b)) | same |
| $\rho<1$, two-point noise $\eta\pm b$ with $b>\rho$ | undefined once some atom carries both labels (Lemma 6.4(a)) | excess $\ge\frac nM(b-\rho)^2$ (Proposition 6.5) |

The case $\rho=1$ with fair labels and distinct inputs is not resolved here. There $U_{1,S}=\{w:0<y_iz_w(x_i)<2\ \forall i\}$. This set constrains the signs of the training outputs and caps their size below $2$. So the interpolation argument of Proposition 6.5 gives only the vacuous bound $(b-\rho)^2=0$, and the infimum of $\kappa_N$ over $U_{1,S}$ need not be attained. At $\rho=1$ a failure is nevertheless provided by Proposition 6.3(b) with $q=1$, whose labels $\frac12\pm\frac14$ give excess $\frac14$, and by Proposition 6.6.

---

## 7. Claim A′: continuous inputs and deterministic labels

Real inputs rarely repeat, and real labels are often deterministic functions of the input. The construction below meets both objections formally: the inputs have a density, and the label is a deterministic function of the input. Each cube vertex is replaced by a tiny corner cube that carries a balanced label pattern. The cubes are so small that every near-minimizer is essentially constant on each of them, by the energy–Lipschitz bound.

The construction does not meet the objections in the sense a skeptic would intend. Its inputs repeat at the learner's resolution, and its deterministic labels are noise at that resolution. The density of the law is $2^{\Theta(d^2)}$ times the uniform density on $[-1,1]^d$, and §7.3 shows that the argument cannot reach laws whose density ratio is $2^{o(d^2)}$. A′ is therefore a counterexample to (P$_L$), which quantifies over all laws, and it says nothing about input laws with bounded density.

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
$$K_2=\max\Big\{\frac nc+t,\ K_{\rm mem}\Big\},\qquad r=\frac1n\Big(\frac L{K_2}\Big)^{L/2},\qquad E=\sqrt{c\,(K_{\rm mem}+t)}+\Big(a+\frac2n\Big)\sqrt n,\qquad B'=2E\sqrt n+E^2 .$$
For $q,u\ge0$ put
$$\Phi'(q,u)=\Big(\sqrt{1+\big(\sqrt q-\sqrt{B'/M}\,\big)_+^2}\;-\;u\Big)_+^2,\qquad q_\delta=\Big(\beta_n-\sqrt{2\lambda\log(1/\delta)/M}\Big)_+,\qquad 1+\underline e'=\Phi'\big(q_\delta,\tfrac1n\big).$$
$\Phi'$ is continuous, nondecreasing in $q$ and nonincreasing in $u$, and $\underline e'$ is deterministic. Then $0<r<1$. Let $S\sim(D'_{d,r})^{\otimes n}$. Compute $k_p$, $\bar y_p$ and $Q$ from the pairs $(p_i,y_i)$, and let $\mathcal E'=\{Q\ge M\beta_n-\sqrt{2n\log(1/\delta)}\}$. This event has probability at least $1-\delta$, and on it $Q/M\ge q_\delta$. On $\mathcal E'$, for every width $N\ge N_0$:

* (i) every $w\in\mathcal N_t(S)$ satisfies $L_{D'}(z_w)\ge\Phi'(Q/M,\frac1n)\ge1+\underline e'$, and so does ${\rm clip}\circ z_w$;
* (ii) $\Pi_\sigma\{w:L_{D'}(z_w)\ge1+\underline e'\}\ge\Pi_\sigma(\mathcal N_t)\to1$ as $\sigma\to0$;
* (iii) for $f_\sigma$ any of $\bar z_{\Pi_\sigma}$, ${\rm clip}\circ\bar z_{\Pi_\sigma}$ or $\int{\rm clip}(z_w)\,d\Pi_\sigma$, $L_{D'}(f_\sigma)\ge\Phi'(q_\delta,\frac1n+\varsigma_\sigma)$, where $\varsigma_\sigma\to0$. Hence $\liminf_{\sigma\to0}L_{D'}(f_\sigma)\ge1+\underline e'$;
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
* **Seen clusters.** Lemma 4.2(b), with $f=g=\zeta$ and $B=B'$, gives $\frac1M\sum_p\zeta_p^2\ge\big(\sqrt{Q/M}-\sqrt{B'/M}\big)_+^2$. With the two previous bullets, $L_{D'}(z_w)\ge\Phi'(Q/M,\frac1n)$. On $\mathcal E'$ this is at least $\Phi'(q_\delta,\frac1n)=1+\underline e'$, because $\Phi'$ is nondecreasing in $q$. This proves (i).
* **Clipped outputs.** ${\rm clip}\circ z_w$ is within $\frac1n$ of ${\rm clip}\circ\tilde\zeta$, because clipping is $1$-Lipschitz, and $\Delta({\rm clip}\circ\zeta)\le\Delta(\zeta)$ by Lemma 4.1(c).

**Step 6 (Gibbs and posterior means).**

* **(ii)** follows from (i) and Corollary 3.3.
* **(iii).** Let $m_\sigma(x)=\mathbb E_{\Pi_\sigma}[z_w(x)\mid\mathcal N_t]$.
  * By Jensen (Corollary 3.3), $\Delta\big((m_\sigma(p))_p\big)\le2E\sqrt n+E^2$.
  * For $x\in X_p$, $|\bar z_{\Pi_\sigma}(x)-m_\sigma(p)|\le|\bar z_{\Pi_\sigma}(x)-m_\sigma(x)|+\mathbb E\big[|z_w(x)-z_w(p)|\,\big|\,\mathcal N_t\big]\le\varsigma_\sigma+\frac1n$. Here $\varsigma_\sigma=(1-p_\sigma)\sqrt{n/c+t}+T_\sigma$ by (3.3), using $F^*\le n/c$.
  * Repeat Step 5. The clipped versions are handled as in Theorem 4.4(iii), with $\varsigma_\sigma=2(1-p_\sigma)$ for $\int{\rm clip}(z_w)\,d\Pi_\sigma$.

**Step 7 (asymptotics).** $E\le\sqrt{c(K_{\rm mem}+t)}+a\sqrt n+2/\sqrt n$. Under (4.4) and $a_d\to0$, $E/\sqrt n\to0$, so $B'/M\to0$ since $n\asymp M$. With $\delta=\delta_d$, $\beta_n\ge q_\delta\ge\beta(\lambda_d)-\lambda_d2^{-d}-\sqrt{2\lambda_d}\,2^{-d/4}$, so $q_\delta\to\beta(\lambda)$, as in Corollary 4.5. Hence $1+\underline e'=\Phi'(q_\delta,\frac1n)\to1+\beta(\lambda)$. $\square$

**Remark 7.3.** Three points about the construction.

* *What it shows.* The inputs have a density, so almost surely no two inputs coincide. The labels are a deterministic function of $x$, so the Bayes risk is $0$. Yet the learner's risk is at least $1+\beta(\lambda)-o(1)$, worse than the zero network's risk $1$. Every network with polynomially bounded width and weights has risk $1-o(1)$ once $r'$ is chosen accordingly (Lemma 7.1(d)). §7.3 explains why this answers the two objections only formally.
* *Why it works.* Fine-scale structure that the competitors cannot resolve acts as noise. Small-energy networks are polynomially Lipschitz, so they cannot resolve it either. The near-minimizer energy bound $\kappa_N\le n/c+t$ comes from comparing with the zero network.
* *Scale.* The radius is polynomially small in $n$, hence exponentially small in $d$. It does not depend on the width $N$ or on $\sigma$, which is what lets one law serve every width $N\ge N_0$. Only statement (i) is free of $\sigma$; (ii) and (iii) are statements about the limit $\sigma\to0$.

### 7.3 How near-atomic the law is

The proof of Theorem 7.2 transfers the noise fitted at a training input to nearby test inputs through the Lipschitz bound of Lemma 3.1(b). That transfer needs test inputs very close to training inputs. The next proposition bounds the test mass that can be that close, for any input law with bounded density.

**Proposition 7.4 (the Lipschitz transfer needs near-duplicates).** Let the $x$-marginal of a law $D$ on $[-1,1]^d\times[-1,1]$ have a density at most $K\cdot2^{-d}$, that is, at most $K$ times the uniform density on $[-1,1]^d$. Let $x_1,\dots,x_n,x$ be i.i.d. from this marginal.

* (a) For every $\rho>0$,
  $$\Pr\Big[\min_{i\le n}\|x-x_i\|_2<\rho\Big]\ \le\ nK\,2^{-d}\,{\rm vol}\big(B_d(\rho)\big)\ \le\ nK\,2^{-d}\Big(\frac{2\pi e\rho^2}d\Big)^{d/2}.$$
* (b) For $K'>0$ put $\rho_{\rm tr}(K')=2\sqrt d\,(L/K')^{L/2}$. By Lemma 3.1(b), every network with $\kappa_N(w)\le K'$ satisfies $|z_w(x)-z_w(x')|\le2$ whenever $\|x-x'\|_2\le\rho_{\rm tr}(K')$. At $n=2^d$,
  $$\Pr\Big[\min_i\|x-x_i\|_2<\rho_{\rm tr}(K')\Big]\ \le\ K\,(8\pi e)^{d/2}\Big(\frac L{K'}\Big)^{Ld/2}=K\,2^{\frac d2\log_2(8\pi e)-\frac{Ld}2\log_2(K'/L)} .$$
* (c) Take $n=2^d$ and the energy level $K_2=\max\{n/c+t,K_{\rm mem}(d,n,a,H)\}$ of Theorem 7.2. For every $c,t>0$ and $a\in(0,1]$, the bound in (b) at $K'=K_2$ is at most $K\,2^{3.05d-(L/(2H))d^2}$. If $c\le1$, it is at most $K\,2^{3.05d-(L/2)d(d-\log_2L)}$.

*Proof.*

(a) By the union bound it suffices to treat one index $i$. Conditionally on $x_i$, $\Pr[\|x-x_i\|<\rho]$ is the integral of the density over $B(x_i,\rho)$, which is at most $K2^{-d}{\rm vol}(B_d(\rho))$. Next, ${\rm vol}(B_d(\rho))=\pi^{d/2}\rho^d/\Gamma(\frac d2+1)$. For $y>0$, $\Gamma(y+1)\ge\int_y^\infty s^ye^{-s}ds\ge y^y\int_y^\infty e^{-s}ds=(y/e)^y$. With $y=d/2$ this gives ${\rm vol}(B_d(\rho))\le(2\pi e\rho^2/d)^{d/2}$.

(b) Lemma 3.1(b) gives $|z_w(x)-z_w(x')|\le(K'/L)^{L/2}\|x-x'\|/\sqrt d\le2$ for $\|x-x'\|\le\rho_{\rm tr}(K')$. In (a), $2\pi e\rho_{\rm tr}^2/d=8\pi e\,(L/K')^L$, and $n2^{-d}=1$.

(c) With $s=\min\{n,M\}=2^d$ and $L=H+1$, $K_2\ge K_{\rm mem}\ge(H+1)(8ds)^{1/H}$ gives $K_2/L\ge(8d\,2^d)^{1/H}\ge2^{d/H}$. So $\frac{Ld}2\log_2(K_2/L)\ge\frac L{2H}d^2$. Also $\frac d2\log_2(8\pi e)=3.047\,d$. If $c\le1$, then $K_2\ge n=2^d$, so $\log_2(K_2/L)\ge d-\log_2L$. $\square$

**Remark 7.5 (what Proposition 7.4 means for Theorem 7.2).** The proof of Theorem 7.2 links a test input to the sample only through Lemma 3.1(b) at the energy level $K_2$. Consider the clipped outputs, whose values at training inputs lie in $[-1,1]$. Take a test input $x$ with $\min_i\|x-x_i\|\ge\rho_{\rm tr}(K_2)$. For each $i$, the link says only that ${\rm clip}\,z_w(x)$ lies within $(K_2/L)^{L/2}\|x-x_i\|/\sqrt d\ge2$ of ${\rm clip}\,z_w(x_i)\in[-1,1]$. Every such interval contains $[-1,1]$, so the link cannot exclude ${\rm clip}\,z_w(x)=\eta(x)$ and certifies no excess at $x$. By Proposition 7.4(c), the test mass at which it can certify anything is at most $K\,2^{3.05d-(L/(2H))d^2}$ for every $c$. To certify a constant excess, the argument therefore needs a density ratio $K\ge2^{(L/(2H))d^2-O(d)}$, and $K\ge2^{(L/2)d^2-O(d)}$ when $c\le1$.

The A′ law meets this requirement with room to spare. Its density on $X$ is $(Mr^d)^{-1}$, which is $r^{-d}$ times the uniform density, and at $n=2^d$
$$\log_2r^{-d}=d\log_2n+\frac{Ld}2\log_2\frac{K_2}L\ \ge\ \Big(1+\frac L{2H}\Big)d^2 .$$
At $c=1$ this is $(1+\frac L2)d^2(1-o(1))$. Table 7.1 gives the numbers at $c=t=1$, $n=2^d$ and $a=a_d$ (`A_r1_scripts/r1_density.out`).

| $(H,d)$ | $\log_{10}r$ | A′ density ratio, $\log_{10}r^{-d}$ | uniform inputs: $\log_{10}$ of the bound of Proposition 7.4(a) at $\rho_{\rm tr}(K_2)$ | $\log_{10}K$ needed for test mass $\frac12$ | $\log_{10}$ of the all-$c$ bound of (c), per unit $K$ |
|---|---|---|---|---|---|
| (2,20) | −14.3 | 286.7 | −148.9 | 148.6 | −72.0 |
| (2,30) | −21.9 | 655.8 | −358.4 | 358.1 | −175.7 |
| (2,40) | −29.4 | 1175.5 | −658.2 | 657.9 | −324.5 |
| (3,20) | −16.9 | 337.2 | −199.3 | 199.0 | −61.9 |
| (3,30) | −25.9 | 776.7 | −479.2 | 478.9 | −153.1 |
| (3,40) | −34.9 | 1396.8 | −879.5 | 879.2 | −284.4 |

So for uniform inputs on $[-1,1]^d$, and for every law whose density ratio is $2^{o(d^2)}$, the argument of Theorem 7.2 proves nothing. Whether tightly conditioned SP$_c$ fails on such laws with noisy labels is a question of benign versus tempered overfitting for this learner. `../research-notes/red-team.md` §6.4 lists it as open, and its §6.2 surveys related results. It is open here as well (§10).

### 7.4 TUBE on A′ data

**Remark 7.6 (A′ does not transfer to TUBE).** Take the law of Theorem 7.2, for any $c>0$, with its radius $r$, and let $0<\rho<1$. Suppose some cluster $X_p$ contains two training inputs $x_i,x_j$ with $y_i\ne y_j$. Then every $w\in U_{\rho,S}$ satisfies
$$\kappa_N(w)\ >\ L\Big(\frac{2-2\rho}r\Big)^{2/L}=(2-2\rho)^{2/L}\,n^{2/L}\,K_2 .$$
Indeed, $|z_w(x_i)-z_w(x_j)|>|y_i-y_j|-2\rho=2-2\rho$ and $\|x_i-x_j\|\le r\sqrt d$, so Lemma 3.1(b) gives $(\kappa_N(w)/L)^{L/2}r>2-2\rho$; then substitute $r=\frac1n(L/K_2)^{L/2}$. The hypothesis holds with probability $1-e^{-\Omega(M)}$ at $n=\lambda M$, by Lemma 7.1(b) and Lemma 6.4(b) applied to the pairs $(p_i,y_i)$. At $\rho=\frac12$, $c=t=1$ and $n=2^d$, the energy floor is $10^3$ to $10^8$ times $K_2$ for $H\in\{2,3\}$ and $d\in\{20,30,40\}$ (`A_r1_scripts/r1_density.out`). Every feasible network varies by more than $2-2\rho$ inside that cluster, so Step 2 of the proof of Theorem 7.2 is unavailable, and A′ yields no lower bound for TUBE$_\rho$. Whether TUBE$_\rho$ succeeds or fails on A′ data is not determined here.

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
   * *Output.* $z_w=\sum_jv_jh^H_j\in\varpi\,\mathcal F_H$ with path norm $\varpi=\sum_j|v_j|\rho^H_j=|v|^\top|W^H|\cdots|W^2|\mathbf 1$.
5. **Path norm and energy.** By Cauchy–Schwarz and $\||A|\|_{\rm op}\le\|A\|_F$,
   $$\varpi\le\|v\|_2\prod_{\ell=2}^H\|W^\ell\|_F\,\sqrt N=\Big(\kappa^{(L)}\prod_{\ell=2}^H\kappa^{(\ell)}\Big)^{1/2}\le\Big(\frac{\kappa_N}{H}\Big)^{H/2},$$
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
* *Numbers.* For $s=2^d$ and $a=\frac12$ (`A_scripts/check_tube_and_lb.py`): at $(H,d)=(2,40)$, construction $5.6\cdot10^7$ against lower bound $2.1\cdot10^4$ (precisely $2.1499\cdot10^4$); at $(3,40)$, $2.9\cdot10^5$ against $1.5\cdot10^3$.
* *Not settled.* The constants and the $d$-dependence are not optimized. Whether the first-layer cost $d(d+1)\alpha_d^2$ is necessary is also open: the bound (8.1) does not see the first layer.

### 8.3 The learner does not memorize above $c\approx n^{1-1/H}$ (when $c=o(n)$)

**Proposition 8.3.** Let $S\sim D_d^{\otimes n}$ (the cube example), $H\ge1$, $N$ any width, $c,t>0$ and $\delta\in(0,1)$. Put $K_0=n/c+t$. With probability at least $1-\delta$, every $w\in\mathcal N_t(S)$ satisfies the following.

* (a) $\displaystyle\frac1n\sum_{i=1}^nz_w(x_i)^2\le\frac{ct}{n}+\frac{2D_{d,H}}{\sqrt n}\Big(\frac{K_0}H\Big)^{H/2}+2\sqrt{\frac{2K_0\log(2/\delta)}{n}}$. Consequently $\frac1M\sum_{x\in\mathcal S}z_w(x)^2\le\frac nM\cdot$(the same right side).
* (b) $\displaystyle L_{D_d}(z_w)-1\le(\text{right side of (a)})+\frac{4D_{d,H}\sqrt{K_0}}{\sqrt n}\Big(\frac{K_0}H\Big)^{H/2}+K_0\sqrt{\frac{\log(2/\delta)}{2n}}$.

Consider $n\asymp2^d$, so that $D_{d,H}=O(\log n)$, and $c=n^{1-\vartheta}$ with $\vartheta>0$. Then the right side of (a) tends to $0$ when $\vartheta<1/H$, and the right side of (b) tends to $0$ when $\vartheta<1/(H+1)$.

The condition $\vartheta>0$, which makes $c=o(n)$, cannot be dropped at a fixed slack $t$. Put $C_t=2(1+\sqrt{t/2})^2/t$ and suppose $c\ge C_tn$. Every $w$ with $\kappa_N(w)\le t/2$ has $|z_w|\le\sqrt{t/2}$ by Lemma 3.1(a), so $F_{c,S}(w)\le\frac t2+\frac nc(1+\sqrt{t/2})^2\le t\le\inf F_{c,S}+t$. Hence $\mathcal N_t(S)\supseteq\{\kappa_N\le t/2\}$. At every width this set contains constant networks with nonzero output: for small $\epsilon_0>0$, give every first-layer row the weight $\epsilon_0$ on the constant coordinate and $0$ elsewhere, set every internal weight to $\epsilon_0/N$ and every readout weight to $\epsilon_0/N$; the energy is $(d+H)\epsilon_0^2$. Such networks have an excess that does not depend on $n$. A slack $t=t_n$ with $ct_n=o(n)$ removes the term $ct/n$ instead.

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
* *Above.* By Proposition 8.3(a), memorization is absent, with seen-atom excess $\to0$, whenever $\frac{2D_{d,H}}{\sqrt n}\big(\frac{n}{cH}\big)^{H/2}\to0$ and $c=o(n)$ (at a fixed slack $t$). The first condition reads $c\gg n^{1-1/H}(2D_{d,H})^{2/H}/H$, which is about $n^{1-1/H}d^{2/H}$.
* *Window.* The two thresholds differ by a factor $d^{3/H}$, polylogarithmic in $n$.

So the memorization transition of SP$_c$ on the cube example happens at $c=n^{1-1/H}$ up to polylogarithmic factors. The exponent $1/H$ is optimal on the construction side (Proposition 8.2) and on the learner side (Proposition 8.3(a)).

Proposition 8.3 controls only the outputs on seen atoms. By itself it does not bound the test excess, which also depends on the outputs on unseen atoms. ../research-notes/B-tempered-likelihood.md settles the test excess for clipped predictors. Its Theorem 6.3 gives vanishing excess for $c=n^{1-\theta}$, $0<\theta<1/H$, on every law, and its §7.5 (item 1) locates the remaining gap in a polylogarithmic window around $c\asymp n^{1-1/H}$. For unclipped predictors ../research-notes/B-tempered-likelihood.md Theorem 6.4 covers $\theta<1/L$, and the window $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$, that is $\theta\in[1/L,1/H]$, is open (../research-notes/B-tempered-likelihood.md §7.5, item 2). Proposition 8.3 itself concerns only the centred-noise cube example.

---

## 9. Numerical checks

The scripts are in `../checks/A/` (first version) and `../checks/A/` (this revision), with outputs `*.out` next to them. They are sanity checks, not proofs. Floating-point evaluations of explicit networks are not certified.

1. **`check_parity.py`** (Lemma 2.2).
   * Identity (2.2) holds with maximal error $1.1\cdot10^{-16}$ over $k\le7$, slopes $\{0.3,0.867,1,2.5\}$ and all $x$ (exhaustive).
   * The closed form of $c_{k,\infty}$ holds in exact rational arithmetic for $k\le40$.
   * $|c_{k,\infty}|\ge(2k)^{-1/2}$ (exact, $k\le400$) and $\binom{2m}m4^{-m}\ge\frac1{2\sqrt m}$ (exact, $m\le200$).
   * $\min|c_{k,\alpha_d}|\cdot2\sqrt{2k}=1.337\ge1$ over $1\le k\le d\le60$ and $d\in\{80,100,128,160,200\}$, in 300-digit arithmetic. The binomial sums cancel catastrophically in double precision.
2. **`check_memorizer.py`** (Lemma 2.1, end to end). For $(d,H)\in\{(3,2),(3,3),(4,2),(5,3),(6,2)\}$ the script draws $n=2^d$ samples and computes $r=\bar y\mathbf 1_{\mathcal S}$, its Fourier coefficients and the exact expansion. The reconstruction error is at most $3\cdot10^{-15}$, and $A\le2\sqrt{2d}\|r\|_2$ in every case. It then samples $m$ features, builds **dense** weight matrices at widths 2000–3000, runs a forward pass, and computes $\kappa_N$ from the matrices.
   * The feature count needed by the Hoeffding step is computed from the realized $A$, as $m>8A^2(d+1)\log2/a^2$, not from $N_0$. In the cases $(3,2)$, $(3,3)$ and $(4,2)$ the run used at least that many features ($2000$ against $1815$ at $(4,2)$) and found $\max|z-r|=0.25,0.23,0.12<a$.
   * In the cases $(5,3)$ and $(6,2)$ it used fewer ($2500$ and $3000$ against $14172$ and $24941$). These two runs test the chain and the energy accounting, not the lemma's width; they still found $\max|z-r|<a$.
   * The chain error is below the bound (2.3) in every case.
   * $\kappa_N\in\{17.2,18.6,27.1,48.1,63.5\}$, each below the detailed bound $d(d+1)\alpha_d^2+2A^2R^{2-2H}+(H-1)R^2$ and below $K_{\rm mem}$.
   * The test excess of these memorizers is $\approx Q/M$, as in Remark 4.8.
   * No run in `A_scripts/` uses the lemma's own width $N_0$. The computation referee's `verify_A_computation_scripts/v2_memorizer.py` does, in 8 configurations with $d\in\{3,\dots,6\}$, $H\in\{2,3,4\}$ and $a\in\{1,\frac12,\frac14\}$, and finds (2.1) satisfied in each.
3. **`check_constants.py`.**
   * $|t-\tanh t|\le|t|^3/3$ on a grid. The ratio of the chain error to the bound (2.3) is $\le0.99999999$ in 60-digit arithmetic; it tends to 1 as $g\to0$, as Taylor's theorem predicts. At $R^2=9/(2a)$ and $|g|\le\frac32$, the error is at most $0.503\cdot\frac a2$.
   * $\beta(\lambda)$: the series and the closed form agree. $\beta(1)=0.484829$; the maximum is at $\lambda^*=1.50286$, where $\beta=0.517351=(1-e^{-\lambda^*})/\lambda^*$. With finite differences on $[0.01,20]$ the script found $\max|\beta'|=0.981$. The supremum over $(0,\infty)$ is $1$, approached as $\lambda\to0$ ($\beta'(10^{-3})=0.9985$ in `A_r1_scripts/r1_misc.out`), so the constant $1$ in Lemma 4.3(d) is sharp.
   * Binomial against Poisson: $|\beta_n-\beta(n/M)|$ is below Le Cam's $n/M^2$ for $d\in\{6,\dots,30\}$.
   * Monte Carlo of $Q/M$ at $n=2^d$, $d\in\{10,14,18\}$: means $0.48507,0.48484,0.48469$ against $\beta_n=0.48503,0.48484,0.48483$. Standard deviations are $0.0147,0.0038,0.0009$, inside the McDiarmid deviation at $\delta=0.01$, which is $0.095,0.024,0.006$.
   * Random networks satisfy Lemma 3.1: empirical gradient over $(\prod\kappa^{(\ell)}/d)^{1/2}$ is at most $0.84$, and $|z|/\sqrt\kappa\le0.62$.
   * The clip-mixture identity of step 3 in Lemma 8.1 holds to $1.3\cdot10^{-15}$.
4. **`bounds_table.py`.** The first version of Table 4.1 and of the admissible-$c$ values, with $a$ on a logarithmic grid. Superseded by `A_r1_scripts/r1_table41.py` (item 7).
5. **`check_tube_and_lb.py`.**
   * Monte Carlo of "no atom carries both labels" lies below the bound of Lemma 6.4(b) in every tested case, for example $0.0000$ against $0.0232$ at $M=1024$, $n=256$.
   * Proposition 8.2 against Lemma 2.1, for $s=2^d$ (§8.2; the lower bound at $(2,40)$ is $2.1499\cdot10^4$, which the first version rounded to $2.2\cdot10^4$).
   * The Claim A′ radius $r(n)$: $\log_2r=-47.6,-72.6,-97.6$ at $d=20,30,40$ with $H=2$.
6. **`spc_small_d.py`** (illustration of Theorem 4.4 at small $d$, with $c=1$). L-BFGS on $F_c$ for the cube example with $n=2^d$.
   * $d=8$, $H=2$, $N=128$: the minimizer found has $\kappa=46.5$ and $\Delta=2.98$, so $F=49.5$, against $160.3$ for the zero network. Its test excess is $0.491$, of which $0.384$ is on seen atoms and $0.106$ on unseen ones; here $Q/M=0.4995$.
   * $d=8$, $H=3$, $N=96$: $\kappa=33.8$, $\Delta=0.92$, test excess $0.609$, of which $0.170$ is on unseen atoms.
   * $d=9$, $H=2$, $N=160$: $\kappa=58.6$, $\Delta=2.73$, test excess $0.547$, against $Q/M=0.475$.
   * Using the network found as the comparator in Lemma 4.1(b) *certifies* a lower bound for **all** near-minimizers: $0.069$, $0.111$ and $0.116$ respectively, up to floating-point evaluation.
   * Larger $c$ (`spc_small_d_largec.out`): at $d=8$, $H=2$ with $c=16=\sqrt n$ and with $c=64$, the optimizer returns the zero network, with test excess $0$. The memorizing configuration costs energy $\approx46$, more than the data term it would remove, which is $G/c\le10$. This agrees with the threshold $c\approx n^{1-1/H}$ of §8.3.
   * These finite-$d$ runs illustrate the mechanism only. The asymptotic constants of §4 become informative around $d\approx20$–$30$ (Table 4.1).
7. **`A_r1_scripts/`** (this revision).
   * `r1_table41.py`: Table 4.1 with continuous optimization of $a$ for each $\lambda$; the $N_0$ column; the gap to $\beta_n$ at $d=40$ ($0.0099$ and $0.0102$); the largest admissible $c$ by bisection ($29.25$ at $(2,30)$, $1583$ at $(3,30)$, $813$ at $(2,40)$, $1.59\cdot10^5$ at $(3,40)$); and the fixed-$a$ numbers of Remark 4.7.
   * `r1_fixed_d.py`: Proposition 5.2 and Table 5.1. For $d\in\{4,6,8\}$ and $n/M\in\{1,4,16,64,256,1024\}$ it simulates $U_S$. In every cell the empirical frequency of $\{U_S\le(8M/\delta'+4ct)/n\}$ at $\delta'=0.05$ is at least the guaranteed level $1-\delta'-Me^{-n/(8M)}$ (it is $1.000$ whenever $n/M\ge16$). It also runs the L-BFGS check reported after Proposition 5.2.
   * `r1_density.py`: Table 7.1 and the energy floor of Remark 7.6. It checks the exact ball volume against the Gamma-function bound of Proposition 7.4(a), and the $c=1$ values against the all-$c$ bound of Proposition 7.4(c).
   * `r1_tube_fixed_d.py`: Proposition 6.6(b), in exact rational arithmetic, as reported after its proof.
   * `r1_misc.py`: the §8.2 numbers ($2.1499\cdot10^4$ and $1.4513\cdot10^3$); $\beta(1)=0.4848291$, $\lambda^*=1.502861$, $\beta(\lambda^*)=0.5173514$ and $\beta'(\lambda)$ near $0$; the two-sided bound of Proposition 6.1(a′) on $20{,}000$ random instances, with no violation; sample sizes from Proposition 5.2.

---

## 10. What is proved, and what is not

**What is refuted, and what is not.** This section refutes (P$_L$) for SP$_c$ with $c\,K_{\rm mem}=o(n)$, including $c=1$, at depth $L\ge3$ and learner widths $N\ge N_0$, uniformly over the input dimension (here $d=\log_2n$). It also refutes (P$_L$) for TUBE$_\rho$ in the strong-prior limit at every tolerance schedule. It does not refute the conjecture, which allows any Bayesian learner. ../research-notes/B-tempered-likelihood.md proves (P$_L$) for SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$ (clipped predictors, every width), and ../research-notes/E-finite-prior-scale.md proves a finite-scale analogue. What fails is the heuristic that close conditioning is needed (§5.4).

**Proved** (paper proofs, with all hypotheses stated above).

* Lemma 2.1: real-valued memorization with explicit $K_{\rm mem}$ and $N_0$, at every width $N\ge N_0$ and depth $\ge3$, with no margin conditioning.
* Lemmas 3.1–3.2 and Corollary 3.3: output, Lipschitz and strong-prior concentration bounds, including control of the posterior-mean tail.
* Theorem 4.4 and Corollaries 4.5–4.6: Claim A for near-minimizers, Gibbs draws and posterior means, clipped or unclipped. Every term is explicit, $c=c(n)$ is arbitrary subject to (4.4), and general label laws with ${\rm Var}(y\mid x)\ge v_0$ are covered.
* Proposition 5.1: refutation of (P$_L$) for SP$_c$ under the readings (R1)–(R3), for every $L\ge3$ and every $c$ satisfying (4.4) along $n=2^d$.
* Proposition 5.2: at a fixed $d$ the cube family is consistent at every width, with excess $O(2^d/n)$.
* Proposition 6.1: sampling without replacement, with a two-sided bound at $n=M$.
* Lemma 6.2, Propositions 6.3, 6.5 and 6.6, and Lemma 6.4: the TUBE$_\rho$ regimes of Table 6.1, including every tolerance schedule for non-centred labels.
* Theorem 7.2: Claim A′ with an explicit radius $r(n)$ and label pattern.
* Proposition 7.4 and Remarks 7.5–7.6: the limits of A′. Its Lipschitz transfer needs a density ratio $2^{\Omega(d^2)}$, and it does not transfer to TUBE.
* Lemma 8.1 and Propositions 8.2–8.3: optimality of the exponent $1/H$ on the construction side, and on the learner side for $n^{1-\vartheta}\le c=o(n)$.

**Not proved, or open.**

1. **The conjecture.** It is not refuted (§5.4). Within SP$_c$, ../research-notes/B-tempered-likelihood.md Corollary 9.3 bounds how fast the competitors' weights may grow. Other Bayesian learners are not analysed here.
2. **Fixed input dimension beyond the cube family.** At a fixed $d$, SP$_c$ is consistent on the cube family (Proposition 5.2). Whether some other law at a fixed $d$ defeats tightly conditioned SP$_c$ is open. There the energy bound $\kappa_N\le n/c+t$ allows Lipschitz constants polynomial in $n$, while typical sample spacings are of order $n^{-1/d}$, so the Lipschitz bound does not prevent fitting individual points. The question is again one of benign versus tempered overfitting.
3. **Input laws with bounded density.** Input laws whose density is at most $2^{o(d^2)}$ times uniform, in particular uniform inputs on $[-1,1]^d$, with noisy labels: open. Proposition 7.4 shows that the argument of Theorem 7.2 cannot reach them. `../research-notes/red-team.md` §6.4 lists the same question.
4. **Depth two ($L=2$).** The memorizer costs $\Theta(s)$ energy, up to factors polynomial in $d$, at $H=1$ (Remark 2.5 and Proposition 8.2). Whether SP$_1$ at depth two still has a constant excess on $D_d$ is not settled here. The red-team report (`../research-notes/red-team.md` §5) claims a small excess of order $d^{-2}$; I have not checked it.
5. **Learner widths below $N_0$.** All SP$_c$ failures are proved for $N\ge N_0={\rm poly}(n)$, or $N_0=O(n\log^2n)$ at a fixed accuracy, which is at least $2\cdot10^5n$ for $d\ge20$ and $a\le0.3$. Nothing is claimed for smaller widths. `../research-notes/red-team.md` Proposition 6.1, an unrefereed parameter-counting sketch, argues success for $c=1$ at learner width $\lceil n^\alpha\rceil$ with $\alpha<1/4$.
6. **Finite-scale priors $\mu_{N,\gamma}$** with likelihood variance $cN^{-\gamma}$ (Claim E). Not treated in this section. ../research-notes/E-finite-prior-scale.md (Theorem 5.2, Corollaries 5.3–5.4) transfers Claim A to every $\gamma\ge1$ at widths $N\ge N_*={\rm poly}(n)$, using a memorizer that survives the prior's noise (../research-notes/E-finite-prior-scale.md Proposition 4.4). One referee report on ../research-notes/E-finite-prior-scale.md (`E-logic.md`) found this correct, with minor fixes. A′ at finite scale is open (../research-notes/E-finite-prior-scale.md §5.4(c)). Of the TUBE results, Lemma 6.4(a), Proposition 6.5 and Proposition 6.6(b) hold for every prior, at every scale and width. The collapse for $\rho>1$ at finite scale is shown only as $N\to\infty$ at fixed $\gamma$ (the remark after Lemma 6.2). Proposition 6.3 and Proposition 6.6(a) are statements about the limit $\sigma\to0$.
7. **The progressive-mixture predictor.** Its prefix posterior means at small prefix lengths are not controlled by Lemma 4.1, so no lower bound is given. A heuristic count suggests a constant excess smaller than $\beta$.
8. **The window in $c$.** For clipped predictors, ../research-notes/B-tempered-likelihood.md (Theorem 6.3 and §7.5) closes the window up to a polylogarithmic factor around $c\asymp n^{1-1/H}$. For unclipped predictors the window $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$ is open (../research-notes/B-tempered-likelihood.md Theorem 6.4 and §7.5). Proposition 8.3 alone controls only the seen atoms.
9. **TUBE on continuous i.i.d. inputs with $\rho<1$.** Not covered, and A′ does not transfer (Remark 7.6). TUBE$_1$ with fair labels and distinct inputs is also open: the minimum-energy sign interpolants are not analysed. A failure at $\rho=1$ is given only for other label laws (Propositions 6.3(b) and 6.6).
10. **Constants.** The $d$-dependence of $K_{\rm mem}$ is not shown optimal: there is a gap $O(d^{3/H})$ to Proposition 8.2, and the first-layer term $d^2\log^2 d$ is not shown necessary. The widths $N_0$ are far from economical.

---

## Appendix R. Response to referees

None of the three reports found a false theorem, lemma or proposition. Their issues concern what the results were said to mean, a few displayed formulas, and some numbers. I found every issue valid and changed the text accordingly. The list below gives the change for each issue. Issue titles keep the referees' locations, which use the first version's numbering; all other section numbers refer to this revision. Theorem, lemma and proposition numbers of the first version are unchanged, because the sibling sections cite them; the new results are Propositions 5.2, 6.6 and 7.4 and Remarks 7.5–7.6.

### R.1 The three major issues (scope report, S1–S3)

**S1 (the conjecture is existential in the learner).** Valid. The first version never said that the conjecture survives, and its §0 item 4 and §5 title invited the reading "the conjecture is false". Changes:

* new §0.1, and §0.2 item 4 now carries the referee's suggested sentences;
* §5 is retitled "Why Claim A refutes (P$_L$) for tightly conditioned SP$_c$";
* new §5.4 states what is and is not refuted, citing ../research-notes/B-tempered-likelihood.md Theorems 6.3–6.4 and Corollaries 8.1 and 9.3, ../research-notes/E-finite-prior-scale.md Theorem 2.7, and `../research-notes/red-team.md` Remark 6.2, with the refereeing status of each;
* §10 opens with the same statement.

I checked each cited statement in its source before citing it.

**S2 (the refutation needs $d\to\infty$).** Valid. It agrees with logic issues 1 and 8 and computation issue 1. Changes:

* The referee's Proposition R1 is now Proposition 5.2. I re-derived its proof, extended it to the Gibbs and posterior-mean predictors in the limit $\sigma\to0$ (part (b)), and added an explicit sample size.
* §0.1, §0.2 items 3–5 and §5.3 items 1–2 now say that the refutation is uniform over the input dimension (here $d=\log_2n$).
* "Refuted for every $\alpha$ and every $o(1)$" now reads: refuted for every $o(1)$ term that is uniform over the input dimensions $d\le\log_2n$ (for example over all $d\le n^\alpha$), or more generally vanishes along $n=2^d$, as ${\rm poly}(d)\,n^{-\gamma}$ does.
* The unproved phrase "only after exponentially many samples" is removed. §5.3 item 1 states what is known below and above the window $n=\Theta(2^d)$.
* `A_r1_scripts/r1_fixed_d.py` reproduces the referee's simulation: the median bound decays like $4M/n$.

**S3 (A′ is near-atomic at the learner's resolution).** Valid. Changes:

* The §7 introduction now says that A′ meets the two objections formally and explains in what sense it does not. Remark 7.3 is reworded.
* New §7.3 proves the referee's Observation R2 as Proposition 7.4, with two refinements. First, it uses the transfer radius over which the Lipschitz bound allows a variation of $2$, the largest variation that matters for labels in $[-1,1]$. The referee's radius allowed a variation of $\frac12$, so the refined statement is stronger. Second, Proposition 7.4(c) gives a bound valid for every $c$, with exponent $(L/(2H))d^2$ from $K_2\ge K_{\rm mem}$, besides the exponent $(L/2)d^2$ for bounded $c$ that the referee computed.
* Remark 7.5 explains why the argument certifies no excess at test inputs beyond the transfer radius.
* Table 7.1 reproduces the referee's density ratios, $10^{287}$ to $10^{1397}$.
* §0.1, §0.2 item 7 and §10 item 3 list input laws with density ratio $2^{o(d^2)}$ and noisy labels as open.

### R.2 Scope report, minor issues

* **S4 (TUBE on continuous i.i.d. inputs; A′ does not transfer).** Valid. The sentence after Proposition 6.3 is replaced as the referee suggested, and Observation R3 is now Remark 7.6. The optional fixed-$d$ TUBE negative (Observation R4) is now Proposition 6.6, with the explicit bound $2e^{-n(1-\eta_0)/(2M)}$ in place of a limit argument. `A_r1_scripts/r1_tube_fixed_d.py` checks it exactly.
* **S5 (progressive mixture).** Valid. §0.2 item 4 and §5.1 now say that it is not covered.
* **S6 (order of $N_0$).** Valid. §0.2 item 3 and §5.3 item 3 give $N_0=O(n\log^2n/a^2)$, the range $N_0/n\in[2\cdot10^5,7\cdot10^6]$, and "nothing is proved for $N<N_0$".
* **S7 (finite scale; "the slt-likelihood theorem").** Valid. The text now says "the strong-prior theorem of slt-likelihood §2", and §10 item 6 cites ../research-notes/E-finite-prior-scale.md for the finite scale.
* **S8 (stale window).** Valid. §8.3 and §10 item 8 now cite ../research-notes/B-tempered-likelihood.md Theorems 6.3–6.4 and §7.5.
* **S9 (convention for an undefined posterior).** Valid. §6.2 states conventions (U1) and (U2) and notes that under (U2) the fair-label "undefined" row is not a failure. Proposition 6.6 uses non-centred labels, for which both conventions give a failure.
* **S10 (Remark 4.9).** Valid. The remark now speaks of the teacher's residual, and says when the memorizer's residual is smaller by $\Theta(n)$.

### R.3 Logic report

1. *The $o(1)$ reading needs uniformity in $d$.* Valid; see S2.
2. *"Every reading" includes the progressive mixture.* Valid; see S5.
3. *The above-threshold claims need $c=o(n)$.* Valid. §0.2 item 8, §5.3 item 5 and §8.3 now state $n^{1-\vartheta}\le c=o(n)$ with $0<\vartheta<1/H$. After Proposition 8.3 the text records the inclusion $\mathcal N_t\supseteq\{\kappa_N\le t/2\}$ for $c\ge C_tn$, with an explicit constant network, which shows that the restriction is needed.
4. *Corollary 4.5 writes "$=$" for an upper bound, and $a_d\le1$ holds only for large $d$.* Valid; both fixed.
5. *Corollary 4.5 assumes $t\le1$; Proposition 5.1 uses any $t$.* Valid. Corollary 4.5 now allows any fixed $t>0$, and Proposition 5.1 fixes $t$ in its statement.
6. *"Test MSE tending to 2" lacked an upper bound.* Valid. Proposition 6.1(a′) proves the upper bound $1+(1+\sqrt{\epsilon'})^2$ for near-minimizers, Gibbs draws and posterior means.
7. *Remark 7.3 overstated.* Valid; fixed as suggested.
8. *§5.2 item 1 (now §5.3 item 1) was unproved.* Valid; see S2.
9. *The description of the repository's thresholds was imprecise.* Valid. (R1) now quotes both sources: `paper.tex` Theorem `strong` ("it does not depend on $D,n,\delta$") and slt-likelihood §2 ("may depend on the selected $n,N$, the teacher, and the accuracy parameters; it is uniform over $D$").
10. *§0 item 7 (now §0.2 item 8) mixed Proposition 8.2(a) and (b).* Valid; fixed.
11. *Treating "undefined" as failure needs a convention.* Valid; see S9. The referee also suggested a proposition covering every tolerance schedule. Proposition 6.6 does this, with one change: the referee's version used fair labels when $\rho\le1$, but under (U2) that case is not a failure, so Proposition 6.6 uses non-centred labels in both cases.
12. *§10 item 3 (now §10 item 6) overstated the finite-scale TUBE results.* Valid. §10 item 6 lists exactly which TUBE statements hold at finite scale, and the remark after Lemma 6.2 says that its finite-scale collapse is asymptotic in $N$.
13. *Corollary 3.3 needs $\Pi_\sigma(\mathcal N_t)>0$.* Valid; one clause added.
14. *The nearest-neighbour remark.* Valid. The remark now says that the identity holds for every $\lambda$, and calls it the variance identity behind Cover's nearest-neighbour estimation risk, averaged over a random count.
15. *(R3) should use outer probability.* Valid; stated in §5.1 and used in the proof of Proposition 5.1.
16. *$\underline e'$ in Theorem 7.2(i) depended on the sample.* Valid. Theorem 7.2 now defines a monotone function $\Phi'$ and the deterministic $\underline e'=\Phi'(q_\delta,\frac1n)-1$.

### R.4 Computation report

1. *Limit order in §5.2 item 2 (now §5.3 item 2).* Valid; see S2.
2. *Range of the above-threshold claims.* Valid; see logic issue 3.
3. *Corollary 4.5.* Valid; see logic issues 4 and 5.
4. *The $\rho=1$ tube set.* Valid. The set is $\{w:0<y_iz_w(x_i)<2\ \forall i\}$, and the text now says that it constrains signs and caps the training outputs below $2$. No conclusion changes.
5. *"Tends to" claims.* Valid. Proposition 6.1(a′) adds the upper bound, and Remark 7.3 now says "at least $1+\beta(\lambda)-o(1)$".
6. *§0 item 7 (now §0.2 item 8) mixed Proposition 8.2(a) and (b).* Valid; see logic issue 10.
7. *Numbers.* Each item is valid and fixed.
   * (a) §8.2 now gives $2.1\cdot10^4$.
   * (b) The admissible $c$ at $(2,30)$ is $29$; continuous optimization gives $29.25$.
   * (c) The gap to $\beta_n$ at $d=40$, $H=2$ is $0.0099$ at $\lambda=1$ and $0.0102$ at $\lambda=1.5$, and Remark 4.7 now says "within $0.011$".
   * (d) Table 4.1 is recomputed with continuous optimization of $a$ (`A_r1_scripts/r1_table41.py`). The optimizing $a$ at $(2,60)$ is $2.0\cdot10^{-10}$, and the new $N_0$ column reaches $4.7\cdot10^{42}$.
   * (e) §9 item 3 now says that $\sup|\beta'|=1$, approached as $\lambda\to0$.
   * (f) §9 item 2 now says which runs of `check_memorizer.py` used the Hoeffding feature count, and cites the computation referee's `v2_memorizer.py` for runs at the lemma's own width $N_0$.
8. *(R1) wording; $P$ used for two things.* Valid. (R1) is fixed as in logic issue 9, and the path norm in Lemma 8.1 is now $\varpi$.
