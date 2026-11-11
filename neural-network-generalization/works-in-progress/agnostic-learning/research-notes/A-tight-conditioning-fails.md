# A. Tightly conditioned SP$_c$ memorizes noise, and TUBE$_\rho$ fails at every tolerance: negative results for the agnostic bound

*This is a research note of the agnostic-learning note ([`../README.md`](../README.md)). It treats Claims A and A′ and the TUBE variants of the brief, [`problem-brief.md`](problem-brief.md), with a stretch result on the memorization exponent. The proofs are paper proofs with numerical sanity checks; nothing here is Lean-verified. The note has been through two referee rounds. The first version is preserved at [`../verification/A-first-version.md`](../verification/A-first-version.md), and Appendix R answers the three first-round reports on it. This text is the second revision: Appendix R2 and the closing referee record answer the three second-round reports, which reviewed revision 1, and the last three tables of the record answer three independent checks of this revision. The edits that the lead editor made after the third check are listed in the last paragraph of the record. Result numbers of the first version are unchanged. Revision 1 added Propositions 5.2, 6.6 and 7.4 and Remarks 7.5–7.6 after the existing items and moved the first version's §5.2 (Discussion) to §5.3; the items added in the second round carry lettered numbers (Corollary 4.5a, Remark 5.1a, Propositions 6.6a and 7.2a, Remark 6.6b, Corollary 7.2b). The check scripts and their outputs are in [`../checks/A/`](../checks/A/) (§9). `NNG/` denotes the project folder `neural-network-generalization/` of this repository.*

---

## 0. Results

### 0.1 Scope

This note refutes a property of particular learners. It does not refute the user's conjecture. The conjecture is existential in the learner ("We may pick whichever version of Bayesian learning is best"). Brief §1 formalizes it as a property (P$_L$) of one fixed learner, uniform over the input dimension, the data law, the competitor and the learner width (§5.1). The results below show that (P$_L$) fails for two learners, for different reasons.

* **SP$_c$**, in the strong-prior limit ($\sigma\to0$ after the sample and the learner width are fixed), at depth $L\ge3$, whenever $c\,K_{\rm mem}=o(n)$, roughly $c\ll n^{1-1/H}d^{-1/H}$, at every learner width $N\ge N_0={\rm poly}(n)$, on laws whose input dimension $d=\log_2n$ grows with $n$. This includes the clean-label scaling $c=1$ (Proposition 5.1; Corollary 7.2b for atomless inputs). SP$_c$ fails here because it conditions tightly: it memorizes the label noise.
* **TUBE$_\rho$**, at every tolerance $\rho$, tight or loose, already at a fixed input dimension, at every depth $L\ge2$ and width, under either convention for an empty tube. For both repository priors this holds at every prior scale, also when $\rho$ depends on $n$ and on the scale (Proposition 6.6a); Proposition 6.6 gives it in the strong-prior limit for every schedule $\rho(n)$. TUBE$_\rho$ does not fail by memorizing noise. On an input that carries both labels $\pm1$, the constraints $|z_w(x)\mp1|<\rho$ confine the output to the window $(1-\rho,\rho-1)$. This window is empty when $\rho\le1$, and when $\rho>1$ it is centred at the midrange $0$ of the labels, not at their mean. A per-point hard tolerance targets the midrange of the conditional label law, while the MSE needs its mean.

Other learners have the property. The sibling note [`B-tempered-likelihood.md`](B-tempered-likelihood.md) proves (P$_L$) for the tempered learner SP$_c$ with $c=n^{1-\theta}$, $0<\theta<1/H$, for clipped predictors at every learner width $N\ge m$ (B-tempered-likelihood.md Theorem 6.3: every near-minimizer, and in the limit $\sigma\to0$ the Gibbs risk and the posterior mean of the clipped outputs, against competitors of the repository architecture). [`E-finite-prior-scale.md`](E-finite-prior-scale.md) proves a finite-scale analogue (E-finite-prior-scale.md Theorem 2.7).

What fails is the user's auxiliary heuristic that the learner "should condition to be pretty close to the given outputs on train inputs", in one reading and in a restricted setting. Read as "condition each training output to within less than the noise level", it fails for SP$_c$ at learner widths $N\ge N_0$, on laws whose test inputs repeat, or nearly repeat, training inputs at the learner's resolution, with $d\to\infty$. On such laws, conditioning tight enough to push the training MSE well below the noise level breaks the property (Theorems 4.4 and 7.2), and tempering the likelihood restores it (§5.4). Whether it breaks the property on laws with bounded density is open (§7.3). Read as "fit the training data about as well as the best small network does", the heuristic describes what the successful learners do (§5.4).

Three further limits apply to the negative results.

* **Input dimension.** The SP$_c$ counterexamples have input dimension $d=\log_2n$. They refute sample bounds that are uniform over the input dimension. That is the repository's convention: `NNG/README.md`, main result 1, states a sample bound "polynomial in input dimension", and the repository's own negative main result 4 is also stated along a growing dimension (an $\exp(\Omega(k))$ sample lower bound for $k$-bit parity in ambient dimension $d=k$). At any fixed $d$ the same cube family is consistent at every width (Proposition 5.2). A version of the conjecture whose $o(1)$ term may depend on $d$, or on the law, is not refuted by this family. The TUBE failures do not need a growing dimension.
* **Input laws.** The continuous-input counterexample A′ is near-atomic at the learner's resolution. Its density is $2^{\Theta(d^2)}$ times the uniform density on $[-1,1]^d$. For a law whose density is at most $K$ times uniform, the probability that a test input lies within the transfer radius $\rho_{\rm tr}(K_2)$ of the proof of Theorem 7.2 from some training input is at most $K\,2^{3.05d-(L/(2H))d^2}$ at $n=2^d$, for every $c$ (Proposition 7.4). Remark 7.5 interprets this as a limit of the Lipschitz transfer used in that proof; the interpretation is not a theorem. Input laws with density ratio $2^{o(d^2)}$, such as uniform inputs on $[-1,1]^d$, combined with noisy labels, are open.
* **Learners and predictors not covered.** Learner widths below $N_0={\rm poly}(n)$ (for small widths see [`small-learner-width.md`](small-learner-width.md)); the progressive-mixture predictor; depth two, which [`depth-two.md`](depth-two.md) treats; SP$_c$ under the finite-scale prior $\mu_{N,\gamma}$, which E-finite-prior-scale.md treats; TUBE on continuous i.i.d. inputs with $\rho<1$. Two further candidates for "the best version of Bayesian learning" are outside this note. One is the fixed-temperature learner FIX$_\eta$, whose likelihood does not scale with the prior, treated in [`C-fixed-temperature-bayes.md`](C-fixed-temperature-bayes.md): it has an agnostic bound at polynomially bounded learner width (Theorem C.2) and fails as the width grows (Theorem C.5), and with the strong prior and $\eta$ fixed its posterior tends to the prior as $\sigma\to0$ (Proposition C.3(b)). The other is a hyperprior on the noise scale, which no note treats.

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
   So does a Gibbs draw, with posterior probability tending to 1 as $\sigma\to0$, and so does the posterior mean in the limit, clipped or not; here $\sigma\to0$ after $d$, $n$, $N$ and the sample are fixed. All $o(1)$ terms are explicit. The zero network has $L_{D_d}(0)=1$, which is the Bayes risk. The limit is $\beta_n\to\beta(\lambda)=e^{-\lambda}\int_0^\lambda\frac{e^u-1}{u}du$, with $\beta(1)=0.484829$ and $\max_\lambda\beta=0.517351$ at $\lambda=1.50286$. For general label laws on $\mathcal C_d\times[-1,1]$ with uniform inputs and ${\rm Var}(y\mid x)\ge v_0$, the excess over the Bayes predictor is at least $v_0\beta_n-o(1)$.
   - *Widths.* With the vanishing accuracy of Corollary 4.5, $N_0\le45\,d(d+1)\,2^{5d/3}=O(n^{5/3}\log^2n)$. With the slower accuracy schedule of Corollary 4.5a, $N_0\le45\,d^3(d+1)\,2^d=O(n\log^4n)$, with the same limit $\beta(\lambda)$ but slower convergence. At a fixed memorizer accuracy $a$, $N_0=O(n\log^2n/a^2)$, which is between $2\cdot10^5n$ and $7.3\cdot10^6n$ for $d\in[20,40]$ and $a\in\{0.1,0.3\}$; the certified excess then tends to $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2$ as $d\to\infty$, and at finite $d$ it is smaller, for example $0.225$ against the limit $0.356$ at $(H,d)=(2,20)$, $a=0.1$, $\lambda=1$ (Remark 4.7). Nothing is proved for $N<N_0$.
   - *Dimension.* The excess is $\Omega(1)$ only in the window $n=\Theta(2^d)$, so the statement needs $d\to\infty$ (item 5).
4. **Refutation of (P$_L$) for tightly conditioned SP$_c$ (Proposition 5.1).** Take the competitor $g\equiv0$, any fixed $\varepsilon<\beta(1)$ and $\delta<1$, and $n=2^d$, which eventually exceeds any polynomial in $d$. Theorem 4.4 then violates (P$_L$) for SP$_c$, uniformly over the input dimension (here $d=\log_2n$), at every learner width $N\ge N_0(d,2^d,a_d)$, and by Corollary 4.5a at every $N\ge45\,d^3(d+1)2^d$. It does so under each of the readings (R1)–(R3) of §5.1: a Gibbs draw; a posterior mean, clipped or not; any near-minimizer, hence the MAP estimate and every $\sigma\to0$ weak limit of the posterior. The in-expectation reading fails as well (Remark 5.1a), and so does (P$_L$) on the atomless laws of Claim A′ (Corollary 7.2b). The progressive-mixture predictor is not covered. This refutes (P$_L$) for SP$_c$ with $c\,K_{\rm mem}=o(n)$, including $c=1$. It does not refute the conjecture, which allows any Bayesian learner: B-tempered-likelihood.md proves (P$_L$) for SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$ (clipped predictors). What fails is the heuristic that the learner should condition closely on the training outputs, in its per-output reading and in the setting of Theorem 4.4 (§5.4). Nothing is claimed for learner widths below $N_0$ (§5.3).
5. **Fixed input dimension (Proposition 5.2).** Fix $d$. For every $c,t>0$, at every width and every depth, every near-minimizer of $F_c$ has excess at most $(8M/\delta'+4ct)/n$ on $D_d$, with probability at least $1-\delta'-Me^{-n/(8M)}$. The $\sigma\to0$ limits of the Gibbs and posterior-mean risks obey the same bound. So the cube family is consistent at each fixed $d$, and the constant excess of item 3 needs $n=\Theta(2^d)$ with $d\to\infty$.
6. **Variants (§6).**
   - *Without replacement* (Proposition 6.1): at widths $N\ge N_0(d,n,a)$, with probability one, the excess is at least $\frac nM(1-\sqrt{\epsilon'})_+^2$, where $\epsilon'=c\,(K_{\rm mem}(d,n,a,H)+t)/n+a^2$; this is $\frac nM(1-o(1))$ when $a\to0$ and $c\,K_{\rm mem}(d,n,a,H)=o(n)$. At $n=M$, with $a=a_d\to0$ and $c\,K_{\rm mem}(d,M,a_d,H)=o(M)$, the test MSE of near-minimizers, Gibbs draws and posterior means tends to $2$ (first $\sigma\to0$, then $d\to\infty$), against a Bayes risk of $1$.
   - *TUBE$_\rho$ with $\rho>1$, or any $\rho$ with $|y|<\rho$* (Lemma 6.2, Proposition 6.3): the strong-prior posterior collapses to the zero network. Non-centred noise then gives a constant excess $\eta_0^2$ against a width-one constant competitor.
   - *TUBE$_\rho$ with $\rho\le1$, with replacement* (Lemma 6.4): the posterior is undefined with probability $1-e^{-\Omega(M)}$, because some atom carries both labels. Whether an undefined posterior counts as a failure is a convention, fixed in §6.2.
   - *TUBE$_\rho$ with $\rho<b$, without replacement, at widths $N\ge N_0(d,n,\rho/2)$* (Proposition 6.5): every posterior draw and the posterior mean have excess at least $\frac nM(b-\rho)^2$ at every $\sigma$, where $b$ is the noise amplitude. Sampling without replacement lies outside (P$_L$), which assumes i.i.d. data.
   - *Every tolerance* (Propositions 6.6 and 6.6a): with non-centred $\pm1$ labels, TUBE$_\rho$ violates (P$_L$) under either convention, at every depth $L\ge2$ and width, already at a fixed input dimension. Proposition 6.6 shows this for the strong prior in the limit $\sigma\to0$ along every schedule $\rho(n)$, and for any prior when $\rho(n)\le1$ (under (U2), any prior whose outputs have prior mean $0$, as §6.2 states). Proposition 6.6a shows it for both repository priors at every scale, without a limit, for every tolerance, including tolerances that depend on the prior scale.
7. **Claim A′ (Theorem 7.2, Propositions 7.2a and 7.4, Corollary 7.2b).** The inputs are absolutely continuous: tiny corner cubes of side $r(n)=\frac1n\big(\frac{L}{\max\{n/c+t,K_{\rm mem}\}}\big)^{L/2}$, where $t$ is the near-minimizer slack. The label is the deterministic function $f^\star(x)=+1$ if $|x_1|>1-r/2$ and $-1$ otherwise. The same lower bound $1+\beta_n-o(1)$ holds, while the Bayes risk is $0$ and every network of width $m$ with weights at most $B$ has risk at least $1-\frac r2B^Lm^H\sqrt d$. The $o(1)$ of Theorem 7.2 is much slower than that of Theorem 4.4: at $c=t=1$, $\delta=0.01$, $\lambda=1$ and $(H,d)=(2,20)$, Theorem 7.2 certifies an excess of only $0.0015$, against $0.249$ on the atoms. Proposition 7.2a, which assumes in addition $c(K_{\rm mem}+t)\le n$ and $n\ge100$, certifies $0.2489$ there. Corollary 7.2b states the resulting refutation of (P$_L$). This meets the objections "real inputs do not repeat" and "real labels are deterministic" formally. The law is nevertheless near-atomic at the learner's resolution. Its density is $r^{-d}$ times uniform, which is $2^{(1+L/2)d^2(1-o(1))}$ at $c=1$, for example $10^{287}$ at $(H,d)=(2,20)$. Proposition 7.4 bounds the test mass within the transfer radius of the training inputs; as Remark 7.5 interprets it, the Lipschitz transfer of the proof cannot reach laws whose density ratio is $2^{o(d^2)}$.
8. **The exponent $1/H$ is optimal (§8).**
   - *Energy lower bound* (Proposition 8.2(a)): any family of networks of energy at most $K$ that fits **every** sign pattern on $s$ distinct cube points to sup-accuracy $a<1$ needs $K\ge H\big(\frac{(1-a)\sqrt s}{D_{d,H}}\big)^{2/H}$, with $D_{d,H}=\sqrt{2\log2}\,(d+1)+\frac{H-1}2$. Proposition 8.2(b) gives the same order for fitting most patterns in mean square. Lemma 2.1 is therefore sharp in $s$ up to a factor $O(d^{3/H})$.
   - *Learner side* (Proposition 8.3): for $n^{1-\vartheta}\le c=o(n)$ with $0<\vartheta<1/H$, near-minimizers on the cube example do not memorize: their outputs on the seen atoms vanish in mean square (part (a)). Part (b) bounds their full test excess, unseen atoms included, when $\vartheta<1/(H+1)$. The critical memorization scale is therefore $c=n^{1-1/H}$ up to polylogarithmic factors.
9. **Checks (§9).** The parity–tanh identity, the coefficient bounds, an explicit construction of the memorizer with exact energy, the chain inequality, $\beta(\lambda)$ and the concentration of $Q$, and a small-$d$ optimization of $F_c$ were all checked numerically. Revision 1 added checks of Table 4.1 with continuous optimization in $a$, of the fixed-$d$ bound of Proposition 5.2, of the density estimates of Proposition 7.4 and of the TUBE probabilities of Proposition 6.6. The second round computes the optimal accuracy of Table 4.1 in closed form, adds the widths at which the certified excess is within $0.001$ of its maximum and the finite-$d$ values at a fixed accuracy, and computes the numbers of Corollary 4.5a and Proposition 7.2a.
10. **Not proved (§10).** The conjecture itself is not refuted. Open or not covered: fixed input dimension beyond the cube family; input laws with density ratio $2^{o(d^2)}$ and noisy labels; depth two; learner widths below $N_0$; the progressive-mixture predictor; unclipped predictors for $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$; TUBE on continuous i.i.d. inputs. SP$_c$ at finite prior scale is treated in E-finite-prior-scale.md. Depth two is treated in depth-two.md: on the cube family, at learner widths $N\ge N_0=O(n\log^4n)$, SP$_c$ fails (P$_L$) at $L=2$ for every $c\le{\rm polylog}(n)$, and whether its excess at $c=1$ tends to $0$ is open. At small learner widths, small-learner-width.md gives a positive result for clipped predictions (§10 items 4–5).

---

## 1. Setting and notation

### 1.1 Networks and energy

Let $d,H,N\ge1$ be integers, $L=H+1$, and $\bar x=(1,x)\in\mathbb R^{d+1}$ for $x\in\mathbb R^d$. A parameter is $w=(W^1,\dots,W^H,v)$ with $W^1\in\mathbb R^{N\times(d+1)}$, $W^\ell\in\mathbb R^{N\times N}$ for $2\le\ell\le H$, and $v\in\mathbb R^N$. The parameter space is $\mathbb R^P$ with $P=N(d+1)+(H-1)N^2+N$. The network computes
$$h^0(x)=\bar x,\qquad h^\ell(x)=\tanh\big(W^\ell h^{\ell-1}(x)\big)\ (1\le\ell\le H),\qquad z_w(x)=v^\top h^H(x).$$
There are no separate biases; the constant input coordinate carries offsets. The energy is
$$\kappa_N(w)=\underbrace{\tfrac dN\|W^1\|_F^2}_{\kappa^{(1)}(w)}+\sum_{\ell=2}^{H}\underbrace{\|W^\ell\|_F^2}_{\kappa^{(\ell)}(w)}+\underbrace{N\|v\|_2^2}_{\kappa^{(L)}(w)}. \tag{1.1}$$
This is eq. (`energy`) of `NNG/side-results/continuous-domains/source/paper.tex` (cited below as `paper.tex`, or as the continuous-domain paper) and the energy of brief §2, where $\sum_{\ell=2}^{L-1}=\sum_{\ell=2}^{H}$. It is a positive definite quadratic form, $\kappa_N(w)=w^\top\Gamma_N w$, with $\Gamma_N$ diagonal with entries $d/N$, $1$ and $N$.

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

**Symbols with several meanings.** The main overloaded symbols are listed below. For each, the list gives all of its meanings in this note and the places where each meaning is used; the summaries in §0 and §10, and the referee appendices, use the meaning of the result or passage they summarize or discuss. No argument uses two meanings of a listed symbol together. The list covers the seven symbols that the second-round logic referee flagged (`../verification/A-logic.md`, issue 16); other letters, for example $K$, $q$ and $T$, are also reused and are defined where they are used. Subscripted or typographically different variants, such as $\rho_{\rm tr}$, $m_\sigma$, $E_*$, $\mathsf p$ and $\gamma_E$, are separate symbols; they are named below where they could be confused with a listed one. The symbols are not renamed because other notes cite these results with them; for example, E-finite-prior-scale.md applies Lemma 4.2(b) "with $B=\eta n$", where $\eta$ is a quantity of that note.

* $B$: the competitors' weight bound in (P$_L$) and §§5–7; the residual budget of Lemma 4.2(b), with $B=M\epsilon$ in Theorem 4.4 and in the proof of Corollary 4.6, $B=B'$ in Theorem 7.2 and $B=B''$ in Proposition 7.2a; a Borel set in (1.3); a Euclidean ball: $B(w^*,\delta)$ in Lemma 3.2 and Corollary 3.3, $\bar B(0,1)$ in Remark 3.4, and $B(x_i,\rho)$ and $B_d(\rho)$ in Proposition 7.4 and the paragraph after Table 7.1.
* $\delta$: the confidence level, with the variants $\delta'$ of Proposition 5.2 and $\delta_d$ of Corollary 4.5; the radius of the ball in Lemma 3.2, Corollary 3.3 and Remark 3.4.
* $p$: the moment power in Lemma 3.2, used with $p\in\{0,\frac12,1\}$ in the proofs of Corollary 3.3 and Propositions 5.2 and 6.1 ($p_\sigma$ in Corollary 3.3 and later is a posterior probability); a generic binomial parameter in the proofs of Lemma 4.3(c) and Proposition 5.2(c); a vertex of $\mathcal C_d$ in §7; the label probability $(1+\eta_0)/2$ in the proof of Proposition 6.6(b); a Bernoulli parameter in Remark 6.6b. The polynomial of (P$_L$) is the sans-serif $\mathsf p$.
* $\rho$: the TUBE tolerance; a ball radius in Proposition 7.4(a), its proof and the paragraph after Table 7.1; the slope in step 3 of the proof of Lemma 8.1 and the path weights $\rho^\ell_j$ in its step 4. The transfer radius $\rho_{\rm tr}$ of Proposition 7.4(b) and Remark 7.5, and the residual budget $\rho_0$ of `red-team.md` Proposition 4.1 in Remark 6.6b, are separate symbols.
* $m$: the number of sampled features in the proof of Lemma 2.1, in Remark 2.5 and in §9 item 2; the index in $k=2m$ and $k=2m+1$ in Lemma 2.2(a), the proof of Lemma 2.2(a)–(b) and §9 item 1; the competitor's width in (P$_L$) and §§5–7; the number of points in Lemma 8.1, its proof and the paragraph after it. The conditional means $m_\sigma$ and $m^{\rm cl}_\sigma$ of Corollary 3.3 are separate symbols.
* $\gamma$: the exponent of the finite-scale prior $\mu_{N,\gamma}$; the expansion coefficients $\gamma_j$ in Steps 2–3 of the proof of Lemma 2.1; the margin $(\beta(1)-\varepsilon)/2$ in the proof of Proposition 5.1; a generic exponent in ${\rm poly}(d)\,n^{-\gamma}$ (§5.3 item 2 and Appendix R, S2). Euler's constant is written $\gamma_E$.
* $E$: the quantity $\sqrt{c(K_{\rm mem}+t)}+(a+\frac2n)\sqrt n$ of Theorem 7.2. The separate symbol $E_*$ is the energy of the teacher in Remark 4.9 and of the competitor in §5.4, as in the cited notes. Expectation is always written $\mathbb E$, and events are calligraphic, as $\mathcal E$.

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

For every $\lambda$, $1+\beta_n$ is the expected test risk of the atom-mean predictor, which predicts $\bar y_x$ at seen atoms and $0$ elsewhere: by Lemma 4.2(a) its risk is $1+Q/M$, and $\mathbb EQ/M=\beta_n$ by (a). At an atom seen $k$ times its excess is the variance $1/k$ of a mean of $k$ fair signs, so its risk there is $R^*(1+1/k)$ with $R^*=1$. This is the variance identity behind Cover's (1968) nearest-neighbour estimation risk, here averaged over the random count $k$ (`literature.md`, item G1).

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

**Corollary 4.5a (a slower accuracy schedule: widths $O(n\log^4n)$).** Under the hypotheses of Corollary 4.5, put $a'_d=\max\{a_d,1/d\}$, with $a_d=(\max\{c_d,1\}/2^d)^{1/3}$ as there. Then $a'_d\le1$ for all large $d$, and all conclusions of Corollary 4.5 hold with $a'_d$ in place of $a_d$, with $\bar\epsilon_d$ evaluated at $a'_d$; in particular the certified excess still tends to $\beta(\lambda)$. The width threshold becomes
$$N_0\big(d,\min\{n_d,2^d\},a'_d\big)\ \le\ 45\,d^3(d+1)\,2^d\ =\ O(n_d\log^4n_d).$$
Proposition 5.1 holds verbatim with $a'_d$ in place of $a_d$, so its refutation of (P$_L$) holds at every learner width $N\ge45\,d^3(d+1)2^d$.

*Proof.*

* **Range.** $a_d\to0$ because $c_d=o(2^d)$, so $a'_d\to0$, and $a'_d\le1$ for all large $d$.
* **What the proof of Corollary 4.5 uses.** It uses two properties of the accuracy: $a\to0$, for the term $\lambda_da^2$, and $a\ge(\max\{c_d,1\}/2^d)^{1/3}$, for the bound $\frac{9(H+1)c_d}{2a\,2^d}\le\frac{9(H+1)}2\max\{c_d,1\}^{2/3}2^{-2d/3}$. Both hold for $a'_d$. The other terms of $\bar\epsilon_d$, the concentration term and the Poisson limit do not involve the accuracy.
* **Threshold.** With $s\le2^d$ and $a_d'^{-2}\le d^2$: $N_0\le\frac{64\log2\,d(d+1)2^d}{a_d'^2}+1\le44.4\,d^3(d+1)2^d+1\le45\,d^3(d+1)2^d$. Since $n_d\asymp2^d$ and $d\asymp\log_2n_d$, this is $O(n_d\log^4n_d)$.
* **Proposition 5.1.** Its proof uses Corollary 4.5 only through $a_d\le1$ for large $d$, the limit of the certified excess, and the probability of the event $\mathcal E$. $\square$

The price is slower convergence. At $c=t=1$, $n=2^d$ and $\delta=\delta_d$, the displayed lower bound of Corollary 4.5 at $(H,d)=(2,40)$ is $0.4735$ with $N_0/n\approx7.8\cdot10^{12}$, and $0.4480$ under the schedule $a'_d$ with $N_0/n\approx1.2\cdot10^8$. At $d=100$ the two bounds are $0.4848$ and $0.4710$ (`../checks/A/r2_numbers.out`, part 2; the computation referee's `../checks/verify-A-computation/c10_cor45_width.out` agrees). Any schedule $a''_d$ with $a_d\le a''_d\le1$ and $a''_d\to0$ works in the same way.

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
* **Clipping, posterior means and uniformity.** Clipping is handled by Lemma 4.1(c), and the posterior-mean argument is identical. The labels may now take any values in $[-1,1]$, so the set of samples need not be finite. Statement (iv) therefore follows from the compact-inputs case of Remark 3.4, which applies because the inputs lie in $\mathcal C_d$ and the labels in $[-1,1]$. $\square$

### 4.4 Remarks

**Remark 4.7 (explicit sizes).** Table 4.1 lists the certified excess $\underline e$ of (4.3) for $c=1$, $t=1$ and $\delta=0.01$, with $a$ optimized separately for each $\lambda$. Since $\underline e$ depends on $a$ only through $\epsilon$, and decreases as $\epsilon$ grows, the optimal accuracy minimizes $\epsilon$. It is $a^*=\min\{a_{\rm int},a_{\rm kink},1\}$, where $a_{\rm kink}=\frac9{2(8ds)^{1/H}}$ is the accuracy above which $K_{\rm mem}$ no longer depends on $a$, and $a_{\rm int}=\big(\frac{9(H+1)c}{4\lambda M}\big)^{1/3}$ is the stationary point of $\epsilon$ below $a_{\rm kink}$. In every row except $(4,30)$, $a^*=a_{\rm kink}$. The table comes from `../checks/A/r1_table41.py`, which replaces the logarithmic grid in $a$ of the first version (`../checks/A/bounds_table.py`). The values of $\underline e$ and $K_{\rm mem}$ agree with the first version to the printed digits. The first version already had the column of optimizing $a$. Revision 1 changed four of its entries and added the $N_0$ column; the second round corrected the $(2,60)$ entries of both columns and added the last column.

| $H$ | $d$ | $\underline e$ at $\lambda=1$ ($\beta_n=0.4848$) | $\underline e$ at $\lambda=1.5$ ($\beta_n=0.5174$) | optimizing $a$ at $\lambda=1$ | $K_{\rm mem}$ | $N_0$ | $N_0$ at the largest $a$ with $\underline e\ge\underline e^*-0.001$ ($\lambda=1$) |
|---|---|---|---|---|---|---|---|
| 2 | 20 | 0.249 | 0.272 | $3.5\cdot10^{-4}$ | $4.0\cdot10^4$ | $1.6\cdot10^{17}$ | $5.0\cdot10^{13}$ at $a=0.020$ |
| 2 | 30 | 0.434 | 0.464 | $8.9\cdot10^{-6}$ | $1.5\cdot10^6$ | $5.6\cdot10^{23}$ | $7.7\cdot10^{17}$ at $a=0.0076$ |
| 2 | 40 | 0.475 | 0.507 | $2.4\cdot10^{-7}$ | $5.6\cdot10^7$ | $1.4\cdot10^{30}$ | $7.3\cdot10^{21}$ at $a=0.0033$ |
| 2 | 60 | 0.4845 | 0.5170 | $1.9\cdot10^{-10}$ | $7.1\cdot10^{10}$ | $5.1\cdot10^{42}$ | $2.1\cdot10^{29}$ at $a=0.00093$ |
| 3 | 20 | 0.406 | 0.435 | $8.2\cdot10^{-3}$ | $3.3\cdot10^3$ | $2.9\cdot10^{14}$ | $1.3\cdot10^{14}$ at $a=0.012$ |
| 3 | 30 | 0.478 | 0.510 | $7.1\cdot10^{-4}$ | $2.8\cdot10^4$ | $8.9\cdot10^{19}$ | $5.2\cdot10^{18}$ at $a=0.0029$ |
| 3 | 40 | 0.4841 | 0.5166 | $6.4\cdot10^{-5}$ | $2.9\cdot10^5$ | $2.0\cdot10^{25}$ | $6.3\cdot10^{22}$ at $a=0.0011$ |
| 4 | 30 | 0.479 | 0.511 | $2.2\cdot10^{-3}$ | $1.3\cdot10^4$ | $9.3\cdot10^{18}$ | $2.9\cdot10^{18}$ at $a=0.0039$ |

The bound comes within $0.011$ of $\beta_n$ at $d=40$ for $H=2$ (the gap is $0.0099$ at $\lambda=1$ and $0.0102$ at $\lambda=1.5$), and within $0.008$ at $d=30$ for $H=3$.

The width threshold $N_0$ at the optimizing $a$ is polynomial in $n$ but very large: $3\cdot10^{14}$ to $5\cdot10^{42}$ in the table. These values overstate the width the bound needs, because $\underline e$ is nearly flat in $a$ above $a^*$. Where $a^*=a_{\rm kink}$, $K_{\rm mem}$ does not depend on $a\ge a^*$, so $\epsilon$ grows only by $\lambda(a^2-a^{*2})$, while $N_0$ falls like $a^{-2}$. The last column gives $N_0$ at the largest $a$ that keeps $\underline e$ within $0.001$ of its maximum at $\lambda=1$. It ranges from $5.0\cdot10^{13}$ to $2.1\cdot10^{29}$, that is, $N_0/n$ from $4.7\cdot10^7$ to $1.9\cdot10^{11}$, smaller than at $a^*$ by factors from $2.3$ at $(3,20)$ to $2.4\cdot10^{13}$ at $(2,60)$.

With a fixed accuracy $a$ instead, $N_0=O(d^2n/a^2)=O(n\log^2n/a^2)$, and $\underline e\to\big(\sqrt{\beta(\lambda)}-a\sqrt\lambda\big)_+^2$ as $d\to\infty$. For $a=0.1$ and $\lambda=1$ this limit is $0.356$, with $N_0/n$ between $1.9\cdot10^6$ and $7.3\cdot10^6$ for $d\in[20,40]$; for $a=0.3$ it is $0.157$, with $N_0/n$ between $2.1\cdot10^5$ and $8.1\cdot10^5$. At finite $d$ the certified excess is smaller. With $c=t=1$, $\delta=0.01$ and $\lambda=1$, at $d=20,30,40$ it is $0.225$, $0.347$ and $0.355$ for $H=2$, and $0.336$, $0.355$ and $0.356$ for $H=3$, when $a=0.1$; it is $0.113$, $0.155$ and $0.157$ for $H=2$, and $0.151$, $0.157$ and $0.157$ for $H=3$, when $a=0.3$.

The constants also matter for the admissible $c$. The largest $c$ certifying $\underline e\ge\beta_n/2$ at $\lambda=1$, with $a=a^*$, is $29$ at $(H,d)=(2,30)$ and $1.6\cdot10^3$ at $(3,30)$. For comparison, $n^{1-1/H}d^{-1/H}=6.0\cdot10^3$ and $3.4\cdot10^5$. The asymptotic condition (4.4) is unaffected.

**Remark 4.8 (the constant is attained by the comparator).** The comparator satisfies $|z_{w_0}-\bar y\mathbf 1_{\mathcal S}|<a$ on all of $\mathcal C_d$. Hence $L_{D_d}(z_{w_0})\le1+\frac1M(\sqrt Q+a\sqrt M)^2=1+Q/M+O(a)$, and $1+\beta(\lambda)$ is the exact limiting risk of the memorizer. Near-minimizers can be worse, because they may also be nonzero on unseen atoms. In the $d=8$ experiments of §9, unseen atoms contribute $0.11$ to $0.17$ of the excess.

**Remark 4.9 (consistency with the repository).** SP$_1$ is the learner of the strong-prior theorem of `NNG/works-in-progress/slt-likelihood/README.md` §2, which proves polynomial sample bounds for **clean** labels at every width. Its proof uses the residual budget $c(E_*+1)=O(1)$, which is available because the teacher fits clean labels exactly. With label noise the teacher's own training residual is $\sum_i(g(x_i)-y_i)^2\approx n\,\mathbb E\,{\rm Var}(y\mid x)$, and that budget is gone. Theorem 4.4 shows that the failure of the proof is a failure of the learner. On the cube example with $n\asymp2^d$ the memorizer costs energy $o(n)$, and its training residual is at most $W+na^2$ (Lemma 4.1), which is smaller than the teacher's residual $n$ by $\Theta(n)$, since $\mathbb EW=n-\mathbb E|\mathcal S|$. The note's finite-scale theorem is not treated here; E-finite-prior-scale.md treats the finite-scale learner.

The noisy-interpolation note bounds clean classification error under a small corruption rate, with distinct inputs and global margin conditioning. At the fair-coin noise level its bound is vacuous, so there is no conflict.

---

## 5. Why Claim A refutes (P$_L$) for tightly conditioned SP$_c$

### 5.1 The property refuted

Write the brief's §1 property for a learner family $\mathsf A$ at depth $L$ as follows.

> **(P$_L$)** There is a polynomial $\mathsf p$ with the following property. For every $d\ge1$, every law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, every competitor $g$ of depth $L$, width $m$ and weights bounded by $B$ (a network of the architecture of §1.1), every learner width $N\ge m$, all $\varepsilon,\delta\in(0,1)$, and all $n\ge\mathsf p(d,m,B,1/\varepsilon,\log(1/\delta))$:
> $$\Pr\big[L_D(\mathsf A_n)\le L_D(g)+\varepsilon\big]\ge1-\delta.$$

(P$_L$) is a property of one learner, and it is uniform over the input dimension $d$: the threshold $\mathsf p(d,\dots)$ must work for every $d$ at once. The user's conjecture asserts that some Bayesian learner has it (§5.4).

For SP$_c$ the output $\mathsf A_n$ must be specified. We allow the most lenient readings.

* **(R1)** A Gibbs draw from $\Pi^c_{\sigma,S}$, with probability taken over the sample and the draw. The property is required for all $\sigma\in(0,\sigma_0)$, where $\sigma_0>0$ may depend on $d,n,N,D,g,\varepsilon,\delta$. This is more lenient than the repository's strong-prior theorems. In `paper.tex` Theorem `strong` the scale threshold may depend on the width, the teacher, $\rho$ and $\varepsilon$, but "does not depend on $D,n,\delta$". In the strong-prior theorem of `NNG/works-in-progress/slt-likelihood/README.md` §2 it "may depend on the selected $n,N$, the teacher, and the accuracy parameters" and is uniform over $D$.
* **(R2)** The same, with the output one of $\bar z_{\Pi_\sigma}$, ${\rm clip}\circ\bar z_{\Pi_\sigma}$ or $\int{\rm clip}(z_w)\,d\Pi_\sigma$.
* **(R3)** Any point of $\mathcal N_t(S)$, for a fixed $t>0$, chosen by any rule. No measurability is required of the rule. The probability in (P$_L$) is then read as an outer probability, and the bounds below hold because the event in question is contained in a measurable event of small probability.

These readings cover the MAP estimate and every weak limit of $\Pi_\sigma$ as $\sigma\to0$, since both are carried by $\arg\min F_{c,S}\subseteq\mathcal N_t$. They do not cover the progressive-mixture predictor of brief §2 (the average over prefixes $t=0,\dots,n$ of posterior means), which is not treated here (§10).

**Proposition 5.1.** Fix $L\ge3$ and $t>0$. Let $c>0$ be fixed, or let $c=c(n)$ be such that $c_d:=c(2^d)$ satisfies (4.4) with $n_d=2^d$. Then SP$_c$ does not have property (P$_L$) under any of the readings (R1)–(R3). More precisely, take the competitor $g\equiv0$, any $\varepsilon\in(0,\beta(1))$ and any $\delta\in(0,1)$. For all sufficiently large $d$, at $n=2^d$ and at every learner width $N\ge N_0(d,2^d,a_d)$, the probability in (P$_L$) is below $1-\delta$ for all sufficiently small $\sigma$. In fact, for every $\epsilon'>0$ it is at most $e^{-2^{d/2}}+\epsilon'$ once $\sigma$ is below a threshold depending on $(d,H,N,c,t,\varepsilon,\epsilon')$.

*Proof.*

* **Setup.** Suppose $\mathsf p$ exists. Take the competitor $g\equiv0$: width $m=1$ and all weights $0$, so the bound $B=1$ holds. Fix $\varepsilon\in(0,\beta(1))$ and $\delta\in(0,1)$, and put $\gamma=(\beta(1)-\varepsilon)/2>0$. Then $q(d)=\mathsf p(d,1,1,1/\varepsilon,\log(1/\delta))$ is a polynomial in $d$, so $2^d\ge q(d)$ for all $d\ge d_1$.
* **What (P$_L$) would give.** For such $d$, (P$_L$) applies to $D=D_d$ and $n=2^d$, at every learner width. In particular it applies at every $N\ge N_0(d,2^d,a_d)$ of Corollary 4.5, where it requires $\Pr[L_{D_d}(\mathsf A_n)\le1+\varepsilon]\ge1-\delta$.
* **What Corollary 4.5 gives.** Apply it with $\lambda=1$ and the fixed $t$. Since $\underline e_d\to\beta(1)$, there is $d_2$ such that for $d\ge d_2$ we have $a_d\le1$, $\underline e_d\ge\varepsilon+\gamma$ and $e^{-2^{d/2}}<\frac{1-\delta}2$. Fix $d\ge\max\{d_1,d_2\}$. The event $\mathcal E$ of Theorem 4.4 has probability at least $1-e^{-2^{d/2}}$.
* **(R3).** On $\mathcal E$ every point of $\mathcal N_t(S)$ has $L_{D_d}\ge1+\varepsilon+\gamma>1+\varepsilon=L_{D_d}(g)+\varepsilon$. So the event $\{L_{D_d}(\mathsf A_n)\le L_{D_d}(g)+\varepsilon\}$ is contained in $\mathcal E^c$, and its outer probability is at most $e^{-2^{d/2}}<1-\delta$.
* **(R1).** Apply Theorem 4.4(iv) with $\epsilon'=\frac{1-\delta}2$. For $\sigma<\sigma_0'$,
  $$\Pr[L_{D_d}(\mathsf A_n)\le1+\varepsilon]\le\Pr(\mathcal E^c)+\sup_{S\in\mathcal E}\Pi_{\sigma,S}(\mathcal N_t^c)<\tfrac{1-\delta}2+\tfrac{1-\delta}2=1-\delta .$$
* **(R2).** Apply Theorem 4.4(iv) with $\epsilon'=\gamma/2$. For $\sigma<\sigma_0'$, on $\mathcal E$, $L_{D_d}(f_\sigma)\ge1+\varepsilon+\gamma/2>1+\varepsilon$. So the probability is at most $\Pr(\mathcal E^c)<1-\delta$.
* **Conclusion.** In each case (P$_L$) would require probability at least $1-\delta$ for all small $\sigma$, which fails. The same estimates with an arbitrary $\epsilon'>0$ give the bound $e^{-2^{d/2}}+\epsilon'$. The $\sigma$-threshold then depends on $(d,H,N,c,t,\epsilon')$ through Theorem 4.4(iv), and also on $\varepsilon$, because under (R2) $\varsigma_\sigma$ must be small compared with the gap $\underline e_d-\varepsilon$. $\square$

**Remark 5.1a (the in-expectation reading).** Proposition 5.1 also refutes the version of (P$_L$) in which the probability bound is replaced by $\mathbb E\,L_D(\mathsf A_n)\le L_D(g)+\varepsilon$. On $D_d$ every predictor has $L_{D_d}\ge1$ (Lemma 4.2(a)), and on the event $\mathcal E$ of Theorem 4.4 the bounds (i)–(iv) apply. Hence, at $n=2^d$ and every $N\ge N_0(d,2^d,a_d)$:

* under (R3) the outer expectation of $L_{D_d}(\mathsf A_n)$ is at least $1+(1-e^{-2^{d/2}})\,\underline e_d$;
* under (R1) and (R2) the expected test MSE is at least $1+(1-e^{-2^{d/2}})(\underline e_d-\epsilon')$ once $\sigma$ is below the threshold of Theorem 4.4(iv) for $\epsilon'$. For (R1) this uses $(1-\epsilon')\underline e_d\ge\underline e_d-\epsilon'$, since $\underline e_d\le1$.

Since $\underline e_d\to\beta(1)$ and $L_{D_d}(g)=1$, these bounds exceed $L_{D_d}(g)+\varepsilon$ for every $\varepsilon<\beta(1)$, once $\epsilon'$ is small and $d$ is large.

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

So the constant excess of Theorem 4.4 needs $d\to\infty$. At a fixed $d$ the cube family certifies only an excess of order $M/n$, uniformly in the width. Table 5.1 (`../checks/A/r1_fixed_d.out`, $c=t=1$, 400 samples per entry, 100 at $(d,n/M)=(8,1024)$) gives Monte Carlo medians of $U_S$. At $n/M=16$ they carry Monte Carlo errors of a few hundredths: at $(d,n/M)=(6,16)$ the computation referee's run with 8000 samples has median $0.526$, against $0.547$ in the table (`../checks/verify-A-computation/c3b_median_noise.out`).

| $n/M$ | 16 | 64 | 256 | 1024 |
|---|---|---|---|---|
| median $U_S$, $d=6$ | 0.547 | 0.088 | 0.018 | 0.0042 |
| median $U_S$, $d=8$ | 0.669 | 0.095 | 0.019 | 0.0043 |
| $\beta(n/M)$, Theorem 4.4's lower bound | 0.067 | 0.016 | 0.0039 | 0.00098 |

For $n/M\le4$ some atom is usually unseen and $U_S$ is infinite. For large $n/M$ the median decays like $4M/n$: at $d=8$ its ratio to $M/n$ is $6.1$, $4.8$ and $4.4$ at $n/M=64$, $256$ and $1024$. The script also ran L-BFGS on $F_c$ at $d\in\{4,5\}$ and $n/M\in\{16,64\}$. Each network found had $F_c\le F_c(0)+t$ and an excess between $0.007$ and $0.051$, below $U_S$.

Proposition 5.2 concerns the cube family only. Whether another law at a fixed $d$ defeats tightly conditioned SP$_c$ is not settled here (§10).

### 5.3 Discussion

1. **Where the failure lives.** (P$_L$) asserts the bound for **all** $n$ above a threshold polynomial in $d$, with $m,B,\varepsilon,\delta$ fixed. Eventually $2^d$ exceeds every polynomial, whatever its degree and whether or not its exponents are fractional. So the threshold is passed at $n=2^d$, where Theorem 4.4 applies. The proved excess is $\Omega(1)$ only in the window $n=\Theta(2^d)$. For $n=o(2^d)$ the certified lower bound $\beta(n/2^d)\sim n/2^d$ vanishes, and whether the learner is then good depends on its values at unseen atoms, which are not controlled (Remark 4.8). For $n\gg2^d d$, Proposition 5.2 gives excess $O(2^d/n)$ at every width. Nothing is claimed about the learner's performance for $n=o(2^d)$.
2. **The competitor is trivial, and the $o(1)$ must be uniform in $d$.** $g\equiv0$ has width one and zero weights, so this is not an approximation failure. The learner is worse than the trivial predictor, which is Bayes-optimal here, by a constant. The brief also reads the conjecture as "test loss at most the minimum over networks with width and weights at most $n^\alpha$, plus $o(1)$". For SP$_c$ with $c\,K_{\rm mem}=o(n)$, at learner widths $N\ge N_0$ (item 3), that reading fails for every $\alpha>0$, provided the $o(1)$ term is uniform over the input dimensions $d\le\log_2n$, for example a function of $n$ alone that bounds the excess for all $d\le{\rm polylog}(n)$, or more generally whenever the term vanishes along $n=2^d$, as ${\rm poly}(d)\,n^{-\gamma}$ does. The reason is that $g\equiv0$ belongs to every such class and the excess is $\Omega(1)$ along $n=2^d$. If the term may depend on $d$ arbitrarily, or on the law, the cube family refutes nothing, because at fixed $d$ the excess is $O(2^d/n)$ (Proposition 5.2). Bounding the competitors' weights changes nothing. The reading does not fail for every learner: for $\alpha<1/(4H)$ and clipped predictions, B-tempered-likelihood.md Corollary 8.1 proves it for the tempered SP$_c$, at every learner width $N\ge n^\alpha$, with an error term that vanishes uniformly over $d\le{\rm polylog}(n)$ (§5.4, which also states the limit that B-tempered-likelihood.md Corollary 9.3 sets on $\alpha$).
3. **Learner width (scope).** The failure holds at every $N\ge N_0={\rm poly}(n)$. It therefore refutes the width-uniform formulation ("every learner width $N\ge m$", brief §1), and any formulation that admits some learner width at least $N_0$. With the schedule of Corollary 4.5a the full limiting excess $\beta(\lambda)$ holds at every $N\ge45\,d^3(d+1)2^d=O(n\log^4n)$. With a fixed accuracy $a$, $N_0=O(n\log^2n/a^2)$ already gives excess at least $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2-o(1)$ (Remark 4.7); there $N_0/n$ is between $2\cdot10^5$ and $7.3\cdot10^6$ for $d\in[20,40]$ and $a\in\{0.1,0.3\}$, and the certified excess at finite $d$ is below its limit, for example $0.225$ against $0.356$ at $(H,d)=(2,20)$ and $a=0.1$. Nothing is proved for $N<N_0$, in particular for $N=O(n)$.

   For learner widths tied to the sample size, $N=\lceil n^{\alpha'}\rceil$, three regimes are known. For $\alpha'>1$, $N$ exceeds $45\,d^3(d+1)2^d=O(n\log^4n)$ for all large $n$, so the failure above applies. For small $\alpha'$ there is a positive result: `small-learner-width.md` (the corrected `red-team.md` Proposition 6.1, refereed in its corrected form ([`../verification/RT-width-logic-revised.md`](../verification/RT-width-logic-revised.md), [`../verification/RT-width-computation-revised.md`](../verification/RT-width-computation-revised.md)); the first-round reports ([`../verification/RT-width-logic.md`](../verification/RT-width-logic.md), [`../verification/RT-width-computation.md`](../verification/RT-width-computation.md)) found the original display correct and its stated rate wrong) bounds by parameter counting the clipped test MSE of the near-minimizers of $F_c$ at a fixed learner width $N$, for every $c>0$, $c=1$ included, and transfers the bound to the clipped Gibbs risk and the posterior mean of the clipped outputs (its Theorems 1 and 4). For fixed $c>0$, a fixed competitor of width at most $N$ and $d=o(\sqrt n)$, its bound vanishes when $N(N+d)\ln n=o(n)$, for example $N=o(\sqrt{n/\log n})$ on the cube family. At $c=1$, against competitors of the repository architecture with width and weights at most $n^{\alpha'}$, at learner width $\lceil n^{\alpha'}\rceil$ and $d\le n^{\alpha'}$, the excess is $O(n^{2\alpha'-1/2})$ for every $\alpha'<1/4$ (its Corollary 3(i)); the rate $O(n^{4\alpha'-1}+n^{\alpha'-1/2}\sqrt{\log n})$ of `red-team.md` is withdrawn. Between these regimes, for fixed competitors at learner widths from about $\sqrt{n/\log n}$ to $N_0$, nothing is known. Such formulations are outside the scope of this note.
4. **Depth.** The proof needs $L\ge3$. For depth two see Remark 2.5 and §10. The TUBE results of §6.2 other than Proposition 6.5, which uses the memorizer of Lemma 2.1, hold at every depth $L\ge2$.
5. **Range of likelihood scalings.** The failure holds for every $c=o(n^{1-1/H}d^{-1/H})$ along $n\asymp2^d$. This includes the clean-label scaling $c=1$ of the strong-prior theorem of `NNG/works-in-progress/slt-likelihood/README.md` §2. That note also proves a finite-scale theorem, which this note does not treat (see E-finite-prior-scale.md). By Proposition 8.3, near-minimizers stop fitting the noise on the seen atoms once $n^{1-\vartheta}\le c=o(n)$ with $0<\vartheta<1/H$.

### 5.4 What is and is not refuted

**The property and the learners.** Proposition 5.1 refutes (P$_L$) for SP$_c$ whenever $c\,K_{\rm mem}=o(n)$ along $n=2^d$, at learner widths $N\ge N_0$, and Corollary 7.2b does the same on atomless laws. Propositions 6.6 and 6.6a refute (P$_L$) for TUBE$_\rho$ at every tolerance. The two learners fail for different reasons. SP$_c$ conditions tightly on each training output and memorizes the noise. TUBE$_\rho$ with $\rho\le1$ fails because the tube is empty once an input carries both labels. With $\rho>1$ it conditions loosely, and it fails because a per-point tolerance centres the admissible outputs at the midrange of the labels seen at an input, not at their mean (§0.1).

**The conjecture.** The user's sentence lets us pick the Bayesian learner, so in the brief's formalization the conjecture holds if some learner has (P$_L$). The sibling notes give such learners. I checked each statement below in its source.

* B-tempered-likelihood.md Theorem 6.3: SP$_c$ with $c=n^{1-\theta}$, $0<\theta<1/H$. Fix a law $D$ on $X\times[-1,1]$, a competitor $g$ of the repository architecture (tanh hidden layers, no internal biases; B-tempered-likelihood.md Remark 8.2) with depth $L$, width $m$ and weights in $[-B,B]$, and $\delta\in(0,1)$. On an event of probability at least $1-\delta$ that depends neither on $N$ nor on $\sigma$, at every learner width $N\ge m$, every near-minimizer of $F_c$ has clipped test MSE at most $L_D(g)+{\rm Exc}_n$, and so do, in the limit $\sigma\to0$, the Gibbs risk and the posterior mean of the clipped outputs. ${\rm Exc}_n\le\varepsilon$ once $n\ge n_0$, polynomial in $(d,m,B,1/\varepsilon,\log(1/\delta))$ and independent of $D$. For a single Gibbs draw this gives probability at least $1-\delta-\eta$ for $\sigma$ below a threshold depending on $\eta$ (the paragraph after B-tempered-likelihood.md Proposition 6.1). So B-tempered-likelihood.md establishes (P$_L$) under the readings of §5.1 with clipped outputs, the posterior mean being that of the clipped outputs, $\int{\rm clip}(z_w)\,d\Pi_\sigma$, after renaming $\delta$. B-tempered-likelihood.md Theorem 6.4 gives the unclipped outputs, including the unclipped posterior mean $\bar z_{\Pi_\sigma}$ and its clip, for $\theta<1/L$. B-tempered-likelihood.md Corollary 8.1 gives, for $H\ge2$ and $\alpha<1/(4H)$, the reading "minimum over networks of the repository architecture with width and weights at most $n^\alpha$, plus $O_L\big((d^2+\sqrt{d\log n}+\sqrt{\log(1/\delta)})\,n^{-\beta}\big)$", with $\beta=(1-4\alpha H)/(H+2)$, for clipped predictions at every learner width $N\ge n^\alpha$. Its error term vanishes uniformly over $d\le{\rm polylog}(n)$, the range in which Proposition 5.1 lives. It does not vanish uniformly over $d\le n^\alpha$ when $\alpha\ge1/(6H+4)$, since at $d=n^\alpha$ the term $d^2n^{-\beta}$ tends to $0$ only if $2\alpha<\beta$ (`../checks/verify-A-scope/scope_numbers.out`, item 2). The three referee reports on B-tempered-likelihood.md (`../verification/B-logic.md`, `../verification/B-computation.md`, `../verification/B-scope.md`) found these theorems correct, with minor fixes.
* E-finite-prior-scale.md Theorem 2.7: the finite-scale analogue, with prior $\mu_{N,\gamma}$, $\gamma\ge1$, and no limit. For $c=n^{1-\theta}$, with $\theta$ below a threshold $\theta_{L,\gamma}$ that equals $1/H$ when $\gamma\ge2-1/H$, it bounds the clipped Gibbs risk and the risk of the posterior mean of the clipped outputs by $L_D(g)+\varepsilon$, at every width $N\ge m$, on an event of probability at least $1-\delta$, once $n$ exceeds a polynomial in $(d,m,B,1/\varepsilon,\log(1/\delta))$; its competitors have weight bound $B\ge1$. The case $\gamma=1$, $L\ge3$ uses an imported mean-field cover. Three referee reports, through the logic, computation and scope lenses, the last after the note's three revision checks (`../verification/E-logic.md`, `../verification/E-computation.md`, `../verification/E-scope.md`), found it correct, with minor fixes; the scope report's one major issue concerned the README draft's summary of that note.
* `red-team.md` Remark 6.2 treats a third learner, which conditions on the empirical MSE being below a threshold $\tau$. One logic referee ([`../verification/RT-aggregate-logic.md`](../verification/RT-aggregate-logic.md)) found it correct, with minor fixes. The threshold must exceed the competitor's empirical loss; for a statement with probability at least $1-2\delta$, $\tau\ge L_D(g)+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$ suffices, where $U$ bounds $|g|$ (Remark 6.2(b) in the form its referee corrected, which the final `red-team.md` states). So $\tau$, about ${\rm OPT}$ plus a term of order $n^{-1/2}$, must be supplied.

There are limits on how far this goes. Within SP$_c$ and for $H\ge2$, consider competitors whose width and weights are at most $n^\alpha$. Once $\alpha>L/(2H(2L-1))$, no choice of $c(n)$ gives the brief's polynomial sample bound for clipped predictions, uniformly over laws and dimensions and at every learner width at least the competitors' width bound (B-tempered-likelihood.md Corollary 9.3, whose counterexamples use laws that change with $n$ and, on the noisy cube, learner widths $N\ge N_0(n)$). Whether another Bayesian learner reaches further is not addressed here or in B-tempered-likelihood.md.

**The heuristic.** What fails is the user's auxiliary heuristic in the reading "condition each training output to within less than the noise level", for SP$_c$ at learner widths $N\ge N_0$, on laws whose test inputs repeat, or nearly repeat, training inputs at the learner's resolution, with $d\to\infty$. On the noisy cube at $\lambda=1$, every near-minimizer of the tightly conditioned learner has training MSE at most $W/n+o(1)$ (Lemma 4.1(b)), where $\mathbb EW/n=1-\mathbb E|\mathcal S|/n\to e^{-1}\approx0.37$. That is well below the noise level $1$, and the learner pays a constant part of the difference back at test time: the training deficit tends to $1-e^{-1}\approx0.63$, and the test excess is at least $\beta(1)-o(1)\approx0.48$ (Theorem 4.4). Whether tight conditioning also breaks the property on laws with bounded density is open (§7.3).

In the reading "fit the training data about as well as the best small network does", the heuristic describes what the successful learners do. Write $\hat L_S(f)=\frac1n\sum_i(f(x_i)-y_i)^2$ for the training MSE. At every learner width $N\ge m$, every $w\in\mathcal N_t(S)$ of the tempered learner satisfies $\hat L_S(z_w)\le\hat L_S(g)+c(E_*+t)/n$, where $E_*$ is the cloning energy of the competitor (B-tempered-likelihood.md Lemma 2.3(c), whose slack $\zeta$ is the $t$ here; the theorems of B-tempered-likelihood.md use slack $1$). At $c=n^{1-\theta}$ and a fixed $t$, the additive term $(E_*+t)n^{-\theta}$ tends to $0$. The learner of `red-team.md` Remark 6.2 conditions on $\hat L_S(z_w)<\tau$ with $\tau$ slightly above the competitor's loss. Tempering with $c=n^{1-\theta}$, $\theta<1/H$, makes memorization too expensive (Proposition 8.3) and restores (P$_L$) (B-tempered-likelihood.md). At learner widths far below $N_0$ even the per-output reading may survive: `small-learner-width.md` (the corrected `red-team.md` Proposition 6.1) gives a positive result for the clipped predictions of SP$_1$ itself at small learner width (§5.3 item 3).

**Uniformity in $d$.** The SP$_c$ refutation is a statement about sample bounds that are uniform over the input dimension. That is the repository's convention: `NNG/README.md`, main result 1, and the negative main result 4 there, which is stated in ambient dimension $d=k$ for $k$-bit parity. At a fixed $d$ the cube family is consistent (Proposition 5.2). The TUBE refutation holds at a fixed $d$.

---

## 6. Variants

### 6.1 SP$_c$ with sampling without replacement

Let $1\le n\le M$. The inputs are $n$ distinct points of $\mathcal C_d$, for example a uniformly random ordered $n$-subset; any rule producing distinct points works. Given the inputs, the labels are independent, each drawn from the conditional law of $D$. The test law $D$ has uniform $x$-marginal.

**Proposition 6.1.** Fix $H\ge2$, $c,t>0$ and $a\in(0,1]$, and put $\epsilon'=\frac{c\,(K_{\rm mem}(d,n,a,H)+t)}{n}+a^2$. Let $N\ge N_0(d,n,a)$.

* (a) **Fair labels.** With probability one, every $w\in\mathcal N_t(S)$ satisfies $L_{D_d}(z_w)\ge1+\frac nM\big(1-\sqrt{\epsilon'}\big)_+^2$, and so does ${\rm clip}\circ z_w$. The Gibbs and posterior-mean statements (ii)–(iv) of Theorem 4.4 hold with this bound.
* (a′) **Upper bound at $n=M$.** If $n=M$, every $w\in\mathcal N_t(S)$ also satisfies $L_{D_d}(z_w)\le1+(1+\sqrt{\epsilon'})^2$, and so does ${\rm clip}\circ z_w$. Moreover $\limsup_{\sigma\to0}\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\le1+(1+\sqrt{\epsilon'})^2$, and each of the three posterior means $f_\sigma$ of Theorem 4.4(iii) has $\limsup_{\sigma\to0}L_{D_d}(f_\sigma)\le1+(1+\sqrt{\epsilon'})^2$. Hence, if $n=M$, $c\,K_{\rm mem}(d,M,a_d,H)=o(M)$ and $a=a_d\to0$, the test MSE tends to $2$, against a Bayes risk of $1$, for every near-minimizer, for the Gibbs draw (in posterior probability and in posterior expectation) and for the posterior means. The order of limits is as in Corollary 4.5: first $\sigma\to0$ at fixed $(d,N,S)$, then $d\to\infty$. Precisely, write $\epsilon'_d$ for $\epsilon'$ at $a=a_d$. For each $d$ and every width $N\ge N_0(d,M,a_d)$, every near-minimizer, clipped or not, has test MSE between $\ell_d=1+(1-\sqrt{\epsilon'_d})_+^2$ and $u_d=1+(1+\sqrt{\epsilon'_d})^2$; a Gibbs draw lies in $[\ell_d,u_d]$ with posterior probability tending to $1$ as $\sigma\to0$; and the $\liminf_{\sigma\to0}$ and $\limsup_{\sigma\to0}$ of its posterior expectation, and of the test MSE of each posterior mean, lie in $[\ell_d,u_d]$. Both $\ell_d$ and $u_d$ tend to $2$ as $d\to\infty$.
* (b) **General labels**, with $y\in[-1,1]$ and $V(x)\ge v_0$. With probability at least $1-\delta$, the lower bounds of (a) hold with the bound $L_D(\eta)+\Big(\sqrt{\big(\lambda v_0-\sqrt{8\lambda\log(1/\delta)/M}\big)_+}-\sqrt{\lambda\epsilon'}\Big)_+^2$, where $\lambda=n/M$.

*Proof.*

* **Atom structure.** All $k_x\in\{0,1\}$. So $\bar y_{x_i}=y_i$, $W=0$, $\Delta(f)=\sum_i(f(x_i)-y_i)^2$, and for fair labels $Q=n$ deterministically.
* **(a).** Lemma 2.1 applies to $r(x_i)=y_i$ with $r=0$ elsewhere, since $\sum r^2\le n$. With Lemma 4.1(b), $\Delta(z_w)\le c(K_{\rm mem}+t)+na^2=n\epsilon'$. Lemma 4.2(b) gives $L_{D_d}\ge1+\frac1M(\sqrt n-\sqrt{n\epsilon'})_+^2$. Statements (ii)–(iv) follow exactly as in Theorem 4.4.
* **(a′), near-minimizers.** At $n=M$ every atom is seen exactly once. Write $y_x$ for the label at $x$; then $\mathcal S=\mathcal C_d$, $\sum_xy_x^2=M$ and $\Delta(f)=\sum_x(f(x)-y_x)^2$. For $w\in\mathcal N_t(S)$, (a) gives $\Delta(z_w)\le M\epsilon'$, and Lemma 4.1(c) gives $\Delta({\rm clip}\circ z_w)\le M\epsilon'$. Minkowski's inequality in $\mathbb R^M$ gives $(\sum_xf(x)^2)^{1/2}\le\sqrt M+\sqrt{\Delta(f)}$. So $L_{D_d}(f)=1+\frac1M\sum_xf(x)^2\le1+(1+\sqrt{\epsilon'})^2$ for $f\in\{z_w,{\rm clip}\circ z_w\}$.
* **(a′), Gibbs expectation.** Lemma 3.1(a) gives $L_{D_d}(z_w)\le1+\kappa_N(w)\le1+F_{c,S}(w)$. So $\mathbb E_{\Pi_\sigma}L_{D_d}(z_w)\le1+(1+\sqrt{\epsilon'})^2+\int_{\mathcal N_t^c}(1+F_{c,S})\,d\Pi_\sigma$, and the integral tends to $0$ by Lemma 3.2 with $p=1$.
* **(a′), posterior means.** By Jensen's inequality (Corollary 3.3), $\Delta(m_\sigma)\le M\epsilon'$ and $\Delta(m^{\rm cl}_\sigma)\le M\epsilon'$, so $m_\sigma$ and $m^{\rm cl}_\sigma$ obey the bound of the previous bullet. By (3.3) and $|{\rm clip}\,u|\le|u|$, the three posterior means obey it with $\sqrt{\epsilon'}$ replaced by $\sqrt{\epsilon'}+\varsigma_\sigma$, where $\varsigma_\sigma\to0$.
* **(a′), limit.** If $\epsilon'\to0$, the lower bound of (a) at $n=M$ and the upper bound of (a′) both tend to $2$.
* **(b).** $Q_\eta=\sum_i(y_i-\eta(x_i))^2$. Given the inputs its terms are independent, lie in $[0,4]$, and have means $V(x_i)\ge v_0$. Hoeffding's inequality gives $\Pr[Q_\eta\le nv_0-u]\le e^{-u^2/(8n)}$. Take $u=\sqrt{8n\log(1/\delta)}$, then argue as in Corollary 4.6. As there, the labels may take any values in $[-1,1]$, and the uniformity (iv) comes from the compact-inputs case of Remark 3.4. $\square$

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

So the TUBE bias below is not an artefact of the limit $\sigma\to0$. At finite scale, however, this collapse is shown only as $N\to\infty$ at fixed $\gamma$. The TUBE statements that hold without a limit, for every prior with full support and at every scale, are: Lemma 6.4(a) and Proposition 6.6(b), at every width; Proposition 6.5, at every width at which the tube is nonempty, in particular every $N\ge N_0(d,n,\rho/2)$; and Proposition 6.6a, at every width, for every prior that is moreover invariant under a sign flip of the readout, which both repository priors are.

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

In the strong-prior limit, TUBE$_\rho$ at a fixed tolerance therefore cannot satisfy an MSE oracle inequality with $\varepsilon<\eta_0^2$, even for clean labels, because the minimum-energy feasible function is $0$. The continuous-domain paper's theorem is consistent with this: it measures error at a larger tolerance $\tau>\rho$ and is not an MSE statement. An MSE-consistent TUBE learner therefore needs $\rho=\rho_n\to0$. On laws with atoms the remaining results of this subsection then apply. Lemma 6.4 treats i.i.d. sampling, under the convention stated next. Proposition 6.5 treats sampling without replacement, which lies outside (P$_L$) because (P$_L$) assumes i.i.d. data. Propositions 6.6 and 6.6a cover every tolerance for non-centred labels. For continuous i.i.d. inputs and $\rho<1$, the native setting of the TUBE learner's paper, nothing is proved here, and the construction A′ of §7 does not transfer (Remark 7.6).

**Convention for an empty tube.** When $U_{\rho,S}=\emptyset$, TUBE$_\rho$ has no posterior. We consider two conventions.

* **(U1)** The output is undefined, and an undefined output counts as a failure of the event $\{L_D(\mathsf A_n)\le L_D(g)+\varepsilon\}$ in (P$_L$).
* **(U2)** The learner falls back to the prior mean of $z_w$. For both priors this is the zero function: the readout $v$ is a centred Gaussian vector independent of the hidden weights, and $z_w(x)=v^\top h^H(x)$ is linear in $v$. For any other prior, the statements of this note that use (U2), including the summaries in §0.2 item 6, in the remark after Lemma 6.2 and in §10 item 6, assume that, for every $x$, the output $z_w(x)$ is integrable under that prior with mean $0$, so that the fallback is again the zero function; for a prior invariant under the readout flip $T$ of Proposition 6.6a, integrability suffices.

A learner with any other fallback is a different learner and is not treated. Under (U2), Lemma 6.4 below does not give a failure for fair labels, since the zero function is Bayes-optimal on $D_d$. Propositions 6.6 and 6.6a use non-centred labels, for which both conventions give a failure.

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

Consequently, let $\rho=\rho(n)$ be any tolerance schedule and $\delta\in(0,1)$, and read (P$_L$) for TUBE$_\rho$ with the output a draw from $\Pi^{\rm tube}$ or one of its posterior means, as in (R1)–(R2). Let $n>\frac{2M}{1-\eta_0}\log\frac2{1-\delta}$. If $\rho(n)\le1$, take any prior and either convention. If $\rho(n)>1$, take the strong prior and $\sigma$ below a threshold depending on $(d,L,N,\rho(n),\eta_0,\varepsilon,\delta)$. In both cases the probability that the output has $L_D\le L_D(g)+\varepsilon$ is below $1-\delta$. So TUBE$_\rho$ violates (P$_L$) for every schedule, at every depth and width, with a fixed input dimension and a fixed width-one competitor: in the strong-prior limit when $\rho(n)>1$, and for every prior when $\rho(n)\le1$. Proposition 6.6a removes the strong-prior restriction for every prior with full support that is invariant under the readout flip, which includes both repository priors at every scale.

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

`../checks/A/r1_tube_fixed_d.py` computes the probability that no atom carries both labels exactly, in rational arithmetic, for $d\in\{1,2,3\}$, $\eta_0\in\{\frac14,\frac12,\frac9{10}\}$ and $n\in\{4,16,64,256\}$. In all 36 cases it lies below the one-atom expression of (b), which lies below $2e^{-n(1-\eta_0)/(2M)}$, and Monte Carlo agrees with the exact value.

Part (a) of Proposition 6.6 needs the strong prior and the limit $\sigma\to0$, and its proof fails when the tolerance approaches $1$ as $\sigma\to0$, for example $\rho=1+\sigma$, because the inner set $\{\kappa_N<(\rho-1)^2\}$ then has prior mass bounded away from $1$. A symmetry argument removes both restrictions. It is Observation S-1 of the second-round scope report (`../verification/A-scope.md`, issue N6), re-derived here.

**Proposition 6.6a (TUBE at every scale, by sign symmetry).** Let $L\ge2$, $N\ge1$, $d\ge1$ and $\eta_0\in(0,1)$, and let $D=D^{\eta_0}_d$ and $g\equiv\eta_0$ be as in Proposition 6.6. Let $\mu$ be a Borel probability measure on the width-$N$ parameter space that charges every nonempty open set and is invariant under the readout flip $T(W^1,\dots,W^H,v)=(W^1,\dots,W^H,-v)$. Both $\mu_\sigma$, at every $\sigma>0$, and $\mu_{N,\gamma}$, for every $\gamma$, qualify: in both, the readout is a centred Gaussian vector independent of the hidden weights. Fix a tolerance $\rho>0$, $\varepsilon\in(0,\eta_0^2)$ and a sample $S$ in which every $x\in\mathcal C_d$ occurs with both labels $+1$ and $-1$.

* (a) If $\rho\le1$, then $U_{\rho,S}=\emptyset$. If $\rho>1$, then $U_{\rho,S}=\{w:\max_{x\in\mathcal C_d}|z_w(x)|<\rho-1\}$; this set is open, contains $0$ and satisfies $TU_{\rho,S}=U_{\rho,S}$, so the TUBE$_\rho$ posterior $\Pi^{\rm tube}$ of $\mu$ is defined and invariant under $T$.
* (b) If $\rho>1$, each of the three posterior means $\bar z$, ${\rm clip}\circ\bar z$ and $\int{\rm clip}(z_w)\,d\Pi^{\rm tube}$ vanishes on $\mathcal C_d$, so its risk is $L_D(0)=L_D(g)+\eta_0^2$.
* (c) If $\rho>1$, then $\Pi^{\rm tube}\{w:L_D(z_w)\le L_D(g)+\varepsilon\}\le\frac12$, and the same holds for ${\rm clip}\circ z_w$.
* (d) If $\rho>1$, then $\mathbb E_{\Pi^{\rm tube}}L_D(z_w)\ge L_D(g)+\eta_0^2$, and the same holds for ${\rm clip}\circ z_w$.
* (e) For $S\sim D^{\otimes n}$, the probability that some $x\in\mathcal C_d$ does not occur with both labels is at most $2M\exp\big(-\frac{n(1-\eta_0)}{2M}\big)$.

Consequently, let the tolerance $\rho$ be arbitrary; it may depend on $n$ and on the prior scale. Let $\mu$ be either repository prior at any scale, or any prior as above, at any width $N\ge1$ and depth $L\ge2$, use either convention (U1) or (U2), and let $\delta\in(0,1)$.

* Under reading (R2), and under the reading that asks for $\mathbb E_{\Pi^{\rm tube}}L_D(z_w)\le L_D(g)+\varepsilon$ (or the same with ${\rm clip}\circ z_w$), the probability of success is below $1-\delta$ once $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1-\delta}$.
* Under reading (R1), with $\delta<\frac12$, the probability of success is below $1-\delta$ once $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1-2\delta}$.

So TUBE$_\rho$ violates (P$_L$) at every prior scale, with no limit $\sigma\to0$, at a fixed input dimension and against a fixed width-one competitor.

*Proof.*

(a) For $\rho\le1$ this is Lemma 6.4(a). Let $\rho>1$.

* **The tube.** At an input that carries both labels, $|z-1|<\rho$ and $|z+1|<\rho$ hold if and only if $z\in(1-\rho,\rho-1)$, that is, $|z|<\rho-1$. Every point of $\mathcal C_d$ is such an input, and every training input lies in $\mathcal C_d$; this gives the formula for $U_{\rho,S}$.
* **Openness and mass.** The set is open because $w\mapsto z_w(x)$ is continuous. It contains $0$ because $\rho-1>0$, so $\mu(U_{\rho,S})>0$.
* **Symmetry.** Since $z_w(x)=v^\top h^H(x)$ and $h^H$ does not depend on $v$, $z_{Tw}=-z_w$, hence $TU_{\rho,S}=U_{\rho,S}$. The map $T$ is an involution and $\mu$ is $T$-invariant, so for Borel $A$, $\Pi^{\rm tube}(TA)=\mu(T(A\cap U_{\rho,S}))/\mu(U_{\rho,S})=\Pi^{\rm tube}(A)$.

(b) On $U_{\rho,S}$, $|z_w(x)|<\rho-1$ for $x\in\mathcal C_d$, so these outputs are integrable, and invariance gives $\int z_w(x)\,d\Pi^{\rm tube}=\int z_{Tw}(x)\,d\Pi^{\rm tube}=-\int z_w(x)\,d\Pi^{\rm tube}$. So $\bar z=0$ on $\mathcal C_d$, hence ${\rm clip}\circ\bar z=0$ there, and the same argument with the odd function ${\rm clip}$ gives $\int{\rm clip}(z_w(x))\,d\Pi^{\rm tube}=0$. Under the uniform marginal, $L_D(f)=L_D(g)+\frac1M\sum_x(f(x)-\eta_0)^2$, so a predictor that vanishes on $\mathcal C_d$ has excess exactly $\eta_0^2$.

(c) Let $A=\{w\in U_{\rho,S}:\frac1M\sum_x(z_w(x)-\eta_0)^2\le\varepsilon\}$, the event in question. Then $TA=\{w\in U_{\rho,S}:\frac1M\sum_x(z_w(x)+\eta_0)^2\le\varepsilon\}$. If $w\in A\cap TA$, Minkowski's inequality in $\ell^2(\mathcal C_d)$ with uniform weights gives $2\eta_0\le2\sqrt\varepsilon$, which contradicts $\varepsilon<\eta_0^2$. So $A$ and $TA$ are disjoint, and $\Pi^{\rm tube}(A)=\Pi^{\rm tube}(TA)$ gives $\Pi^{\rm tube}(A)\le\frac12$. For ${\rm clip}\circ z_w$ the same argument works, because ${\rm clip}$ is odd.

(d) By Jensen's inequality and (b), $\mathbb E_{\Pi^{\rm tube}}\frac1M\sum_x(z_w(x)-\eta_0)^2\ge\frac1M\sum_x(\bar z(x)-\eta_0)^2=\eta_0^2$. The same holds for ${\rm clip}\circ z_w$, whose posterior mean also vanishes on $\mathcal C_d$.

(e) The proof of Proposition 6.6(b) bounds the probability that the labels at one atom agree by $2e^{-n(1-\eta_0)/(2M)}$, counting an atom that does not occur as agreeing. Take a union bound over the $M$ atoms.

*Consequence.* Let $\mathcal G$ be the event that every $x\in\mathcal C_d$ occurs with both labels; by (e), $\Pr(\mathcal G^c)\le2Me^{-n(1-\eta_0)/(2M)}$. On $\mathcal G$, if $\rho\le1$ the tube is empty by (a): under (U1) the output is undefined, a failure, and under (U2) it is the zero function, whose excess is $\eta_0^2>\varepsilon$. If $\rho>1$, every posterior mean has excess exactly $\eta_0^2$ by (b), and the posterior expected losses exceed $L_D(g)+\varepsilon$ by (d). So under (R2) and under the expected-loss reading the probability of success is at most $\Pr(\mathcal G^c)$, which is below $1-\delta$ for the stated $n$. Under (R1) a draw succeeds with conditional probability at most $\frac12$ on $\mathcal G$, by (c), so the probability of success is at most $\Pr(\mathcal G^c)+\frac12\Pr(\mathcal G)=\frac12\big(1+\Pr(\mathcal G^c)\big)$; this is below $1-\delta$ when $\Pr(\mathcal G^c)<1-2\delta$, in particular for the stated $n$. The thresholds on $n$ do not depend on the polynomial $\mathsf p$, and (P$_L$) quantifies over all $\delta\in(0,1)$, so no polynomial threshold works. $\square$

The scope referee checked the symmetry numerically at $d=2$, depth $3$ and width $4$, with $\rho=1.3$, $\eta_0=\frac12$ and $\varepsilon=0.2$, by rejection sampling from $\mu_{N,1}$ and from $\mu_\sigma$ at $\sigma=0.3$ (`../checks/verify-A-scope/tube_symmetry.out`). With every atom carrying both labels, the posterior means at the four atoms vanish within Monte Carlo error, the posterior probability of the event of (c) matches that of its mirror image ($0.184$ against $0.185$ under $\mu_{N,1}$), and the excess of the posterior mean is $0.2500$. When one atom carries only the label $+1$, the posterior mean there is $0.0131\pm0.0005$ under $\mu_{N,1}$, so the hypothesis that every atom carries both labels is needed for (b).

**Dependence on $\rho$ (summary).** Table 6.1 collects the cases. The without-replacement column lies outside (P$_L$), which assumes i.i.d. data.

| tolerance and labels | with replacement (i.i.d.) | without replacement |
|---|---|---|
| $\rho\le1$, fair $\pm1$ labels | $U_{\rho,S}=\emptyset$ with probability $1-e^{-\Omega(M)}$ at $n=\lambda M$ (Lemma 6.4). A failure under (U1); under (U2) the fallback $0$ is Bayes-optimal, so no failure | for $\rho<1$, excess $\ge\frac nM(1-\rho)^2$ at every $\sigma$ (Proposition 6.5) |
| $\rho\le1$, non-centred $\pm1$ labels | $U_{\rho,S}=\emptyset$ with probability $\ge1-2e^{-n(1-\eta_0)/(2M)}$, at every fixed $d$; a failure under (U1) and (U2) (Proposition 6.6(b)) | not treated |
| $\rho>1$, any labels in $[-1,1]$ | in the strong-prior limit the posterior collapses to the zero network; excess $\to\frac1M\sum\eta^2$, for example $\eta_0^2$ for non-centred $\pm1$ noise (Lemma 6.2, Propositions 6.3(a) and 6.6(a)) | same |
| any $\rho$, possibly depending on the prior scale; non-centred $\pm1$ labels; either repository prior at any scale, no limit | with probability $\ge1-2Me^{-n(1-\eta_0)/(2M)}$ every atom carries both labels; then the tube is empty if $\rho\le1$, and if $\rho>1$ the three posterior means vanish on $\mathcal C_d$ (excess $\eta_0^2$) and a draw has excess at most $\varepsilon<\eta_0^2$ with posterior probability at most $\frac12$ (Proposition 6.6a) | not treated |
| any $\rho>0$, labels with $\lvert y\rvert<\rho$, including noiseless ones | collapse to $0$; excess $\eta_0^2$ (Proposition 6.3(b)) | same |
| $\rho<1$, two-point noise $\eta\pm b$ with $b>\rho$ | undefined once some atom carries both labels (Lemma 6.4(a)) | excess $\ge\frac nM(b-\rho)^2$ (Proposition 6.5) |

The case $\rho=1$ with fair labels and distinct inputs is not resolved here. There $U_{1,S}=\{w:0<y_iz_w(x_i)<2\ \forall i\}$. This set constrains the signs of the training outputs and caps their size below $2$. So the interpolation argument of Proposition 6.5 gives only the vacuous bound $(b-\rho)^2=0$, and the infimum of $\kappa_N$ over $U_{1,S}$ need not be attained. At $\rho=1$ a failure is nevertheless provided by Proposition 6.3(b) with $q=1$, whose labels $\frac12\pm\frac14$ give excess $\frac14$, and by Propositions 6.6 and 6.6a.

**Remark 6.6b (a TUBE upper bound with a matched tolerance).** The TUBE results above are negative. `red-team.md` Proposition 4.1 gives the positive counterpart; two referees (logic and computation: [`../verification/RT-tube-logic.md`](../verification/RT-tube-logic.md), [`../verification/RT-tube-computation.md`](../verification/RT-tube-computation.md)) found it correct, with minor fixes only. It treats laws with $|y-g(x)|\le\rho_0$ almost surely for a small network $g$, a tolerance $\rho>\rho_0$ and an accuracy level $\tau>\rho+\rho_0$. For the strong prior at small $\sigma$, it bounds the posterior expected loss of the clipped outputs by $\min\{4,(\tau+\rho_0)^2\}+4\varepsilon/3$ at the polynomial sample size of the continuous-domain paper's Theorem `strong` (its part (a)), and by $\rho^2+\varepsilon$ at a sample size polynomial in the dimension, the width and weight bound of $g$, $1/\varepsilon$ and $\log(1/\delta)$ that does not depend on $\rho$, $\rho_0$, $\tau$ or the learner width (its part (b)). These are bounds of order $(\tau+\rho_0)^2$ and $\rho^2$, tempered bounds for bounded noise. They must not be read as a constant factor times ${\rm OPT}$: in an exact example with a single input atom, $g\equiv-c_0$ for some $c_0\in(\rho,1]$ and labels $-c_0+\rho_0\xi$ with $\xi\sim{\rm Bernoulli}(p)$, on samples that contain a label $-c_0$, which have probability $1-p^n$, the strong-prior TUBE risk tends to $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$ as $\sigma\to0$, while $L_D(g)=p\rho_0^2$. Part (c) of the proposition keeps the posterior, up to mass that vanishes as $\sigma\to0$, at energy at most $E_*+2$ for every $n$, where $E_*$ is the cloning energy of $g$; it rules out memorization only in this energy sense. There is no conflict with Propositions 6.6 and 6.6a. When some input carries both labels $\pm1$ with positive probability, as on the laws of those propositions, every competitor has $\rho_0\ge1$. Then $\tau+\rho_0>3$, so the bound of part (a) is the trivial $4+4\varepsilon/3$, since $L_D({\rm clip}\circ z_w)\le4$ always, and the bound $\rho^2+\varepsilon$ of part (b) exceeds $1\ge L_D(0)$.

---

## 7. Claim A′: continuous inputs and deterministic labels

Real inputs rarely repeat, and real labels are often deterministic functions of the input. The construction below meets both objections formally: the inputs have a density, and the label is a deterministic function of the input. Each cube vertex is replaced by a tiny corner cube that carries a balanced label pattern. The cubes are so small that every near-minimizer is essentially constant on each of them, by the energy–Lipschitz bound.

The construction does not meet the objections in the sense a skeptic would intend. Its inputs repeat at the learner's resolution, and its deterministic labels are noise at that resolution. The density of the law is $2^{\Theta(d^2)}$ times the uniform density on $[-1,1]^d$. §7.3 bounds the test mass within the transfer radius of the training inputs on laws whose density ratio is $2^{o(d^2)}$ (Proposition 7.4), and interprets the bound as a limit of the argument (Remark 7.5). A′ is therefore a counterexample to (P$_L$), which quantifies over all laws (Corollary 7.2b), and it says nothing about input laws with bounded density.

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

For $c=1$ and $a=a_d$, the proof of Corollary 4.5 shows $K_{\rm mem}=o(n)$. So for large $d$, $K_2=n+t$ and $r=\frac1n\big(\frac{L}{n+t}\big)^{L/2}\approx L^{L/2}n^{-1-L/2}$. For example $r\approx5.2\,n^{-5/2}$ at $H=2$. At $d=30$ this is $r\approx10^{-22}$ (`../checks/A/check_tube_and_lb.py`).

The convergence $\underline e'\to\beta(\lambda)$ is much slower than that of Theorem 4.4. The budget $B'=2E\sqrt n+E^2$ of Step 4 below is at least $2\sqrt{n\,c(K_{\rm mem}+t)}$, whereas the budget $M\epsilon$ of Theorem 4.4 is $c(K_{\rm mem}+t)+na^2$. So, for $n\asymp M$, $\sqrt{B'/M}$ is at least of order $(cK_{\rm mem}/n)^{1/4}$, while $\sqrt\epsilon$ can be of order $(cK_{\rm mem}/n)^{1/2}$. At $c=t=1$, $\delta=0.01$ and $\lambda=1$, with $a$ optimized, Theorem 7.2 certifies $\underline e'=0.0015$ at $(H,d)=(2,20)$, $0.176$ at $(2,30)$, $0.109$ at $(3,20)$ and $0.454$ at $(2,60)$, against $0.249$, $0.434$, $0.406$ and $0.4845$ from Theorem 4.4 on the atoms (`../checks/A/r2_numbers.out`, part 1). Proposition 7.2a below recovers the values of Theorem 4.4 under two extra hypotheses, which hold for all large $d$ under the hypotheses of Corollary 4.5.

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

**Proposition 7.2a (a sharper residual budget for A′).** Assume the setting of Theorem 7.2, and in addition $c\,(K_{\rm mem}+t)\le n$ and $n\ge100$. Put
$$B''=c\,(K_{\rm mem}+t)+na^2+7,\qquad \Phi''(q,u)=\Big(\sqrt{1+\big(\sqrt q-\sqrt{B''/M}\,\big)_+^2}\;-\;u\Big)_+^2,\qquad 1+\underline e''=\Phi''\big(q_\delta,\tfrac1n\big).$$
Then (i)–(iv) of Theorem 7.2 hold with $\Phi''$ and $\underline e''$ in place of $\Phi'$ and $\underline e'$. Here $\sqrt{B''/M}=\sqrt{\epsilon+7/M}$, with $\epsilon$ the quantity (4.3) of Theorem 4.4, so $\underline e''$ differs from the bound $\underline e$ of Theorem 4.4 only through the extra $7/M$ and the shift $u=\frac1n$ in $\Phi''$. Under the hypotheses of Corollary 4.5 the two extra hypotheses hold for all large $d$.

*Proof.* The budget $B'$ enters the proof of Theorem 7.2 only through Step 4, which shows $\Delta(\zeta)\le B'$ for every near-minimizer $w$; Steps 5 and 6 use nothing else about it. It therefore suffices to show $\Delta(\zeta)\le B''$. Fix $w\in\mathcal N_t(S)$ and the comparator $w_0$ of Step 3, and put $C=c(K_{\rm mem}+t)$.

* **Near-minimizer.** Put $u_i=z_w(x_i)-\zeta_{p_i}$ and $v_i=\zeta_{p_i}-y_i$. By Step 2, $|u_i|\le\frac1n$, so $\sum_iu_i^2\le\frac1n$. Put $X=\sum_iv_i^2$; by Lemma 4.1(a), $X=\Delta(\zeta)+W$. Cauchy–Schwarz gives
  $$\sum_i\big(z_w(x_i)-y_i\big)^2=\sum_i(u_i+v_i)^2\ \ge\ X-\tfrac2{\sqrt n}\sqrt X .$$
* **Comparator.** Put $u^0_i=z_{w_0}(x_i)-z_{w_0}(p_i)$ and $v^0_i=z_{w_0}(p_i)-y_i$. By Step 3, $|u^0_i|\le\frac1n$. By Lemma 4.1(a) and $|z_{w_0}(p)-\bar y_p|<a$ at every seen vertex, $Y:=\sum_i(v^0_i)^2=\sum_pk_p\big(z_{w_0}(p)-\bar y_p\big)^2+W\le na^2+W\le2n$, using $a\le1$ and $W\le n$. Hence
  $$\sum_i\big(z_{w_0}(x_i)-y_i\big)^2\ \le\ Y+\tfrac2{\sqrt n}\sqrt Y+\tfrac1n\ \le\ Y+2\sqrt2+\tfrac1n .$$
* **Near-minimality.** $F_{c,S}(w)\le F_{c,S}(w_0)+t$, $\kappa_N(w_0)\le K_{\rm mem}$ and $\kappa_N(w)\ge0$ give $\sum_i(z_w(x_i)-y_i)^2\le C+\sum_i(z_{w_0}(x_i)-y_i)^2$. With the two previous bullets,
  $$\Big(\sqrt X-\tfrac1{\sqrt n}\Big)^2\le R':=C+Y+2\sqrt2+\tfrac2n,\qquad\text{so}\qquad X\le R'+\tfrac2{\sqrt n}\sqrt{R'}+\tfrac1n .$$
* **Conclusion.** Subtracting $W$ and using $Y-W\le na^2$,
  $$\Delta(\zeta)=X-W\le C+na^2+2\sqrt2+\tfrac3n+\tfrac2{\sqrt n}\sqrt{R'} .$$
  With $C\le n$ and $Y\le2n$, $R'\le3n+3$, so $\frac2{\sqrt n}\sqrt{R'}\le2\sqrt{3+3/n}\le3.49$ for $n\ge100$; also $2\sqrt2+\frac3n\le2.86$. Hence $\Delta(\zeta)\le C+na^2+7=B''$.

Step 6 applies Jensen's inequality to the convex functional $\Delta$, so the posterior-mean bounds follow with $B''$ as before. Finally, $B''/M=\epsilon+7/M$ because $M\epsilon=c(K_{\rm mem}+t)+na^2$. Under the hypotheses of Corollary 4.5, $c_d(K_{\rm mem}+t)=o(2^d)=o(n_d)$, so $C\le n$ for large $d$, and $n_d\ge100$ for large $d$. $\square$

At $c=t=1$, $\delta=0.01$ and $\lambda=1$, with $a=a^*$ of Remark 4.7, Proposition 7.2a certifies $0.2489$ at $(H,d)=(2,20)$, $0.4337$ at $(2,30)$, $0.4063$ at $(3,20)$ and $0.4845$ at $(2,60)$, the values of Theorem 4.4 to three or four digits; in each row $c(K_{\rm mem}+t)/n\le0.04$ (`../checks/A/r2_numbers.out`, part 1). The computation referee tested the inequality $\Delta(\zeta)\le B''$ on $19{,}669$ adversarial random instances and found it with slack at least $2.83$ (`../checks/verify-A-computation/c7_sharper_step4.out`).

**Corollary 7.2b (A′ refutes (P$_L$)).** Fix $L\ge3$ and $t>0$, and let $c>0$ be fixed or let $c=c(n)$ satisfy (4.4) along $n_d=2^d$. For each $d$ let $D'_d=D'_{d,r}$ be the law of Theorem 7.2 with $n=2^d$, $a=a_d$ and $\delta=\delta_d$ as in Corollary 4.5; its radius $r$ depends on $(d,c,t,H)$. Then the conclusions of Proposition 5.1 hold with $D_d$ replaced by $D'_d$: for the competitor $g\equiv0$, which has $L_{D'_d}(g)=1$, any $\varepsilon\in(0,\beta(1))$ and any $\delta\in(0,1)$, for all large $d$, at $n=2^d$ and every learner width $N\ge N_0(d,2^d,a_d)$, the probability in (P$_L$) is below $1-\delta$ for all sufficiently small $\sigma$, under each of the readings (R1)–(R3). The Bayes risk of $D'_d$ is $0$.

*Proof.* Repeat the proof of Proposition 5.1 with Theorem 7.2(i)–(iv) in place of Theorem 4.4(i)–(iv), the event $\mathcal E'$ in place of $\mathcal E$, and the deterministic bound $\underline e'_d\to\beta(1)$ of Theorem 7.2 in place of $\underline e_d\to\beta(1)$. The uniformity over samples needed under (R1) and (R2) is Theorem 7.2(iv). The law $D'_d$ depends on $n$. That is allowed, because (P$_L$) must hold for every law at every $n$ above the polynomial threshold, so one law per $d$, tested at the single sample size $n=2^d$, suffices. $\square$

**Remark 7.3.** Three points about the construction.

* *What it shows.* The inputs have a density, so almost surely no two inputs coincide. The labels are a deterministic function of $x$, so the Bayes risk is $0$. Yet the learner's risk is at least $1+\beta(\lambda)-o(1)$, worse than the zero network's risk $1$. Every network with polynomially bounded width and weights has risk $1-o(1)$ once $r'$ is chosen accordingly (Lemma 7.1(d)). §7.3 explains why this answers the two objections only formally.
* *Why it works.* Fine-scale structure that the competitors cannot resolve acts as noise. Small-energy networks are polynomially Lipschitz, so they cannot resolve it either. The near-minimizer energy bound $\kappa_N\le n/c+t$ comes from comparing with the zero network.
* *Scale.* The radius is polynomially small in $n$, hence exponentially small in $d$. It does not depend on the width $N$ or on $\sigma$, which is what lets one law serve every width $N\ge N_0$. Only statement (i) is free of $\sigma$; (ii) and (iii) are statements about the limit $\sigma\to0$.

### 7.3 How near-atomic the law is

The proof of Theorem 7.2 transfers the noise fitted at a training input to nearby test inputs through the Lipschitz bound of Lemma 3.1(b). That transfer needs test inputs very close to training inputs. The next proposition bounds the test mass that can be that close, for any input law with bounded density.

**Proposition 7.4 (test mass within the transfer radius).** Let the $x$-marginal of a law $D$ on $[-1,1]^d\times[-1,1]$ have a density at most $K\cdot2^{-d}$, that is, at most $K$ times the uniform density on $[-1,1]^d$. Let $x_1,\dots,x_n,x$ be i.i.d. from this marginal.

* (a) For every $\rho>0$,
  $$\Pr\Big[\min_{i\le n}\|x-x_i\|_2<\rho\Big]\ \le\ nK\,2^{-d}\,{\rm vol}\big(B_d(\rho)\big)\ \le\ nK\,2^{-d}\Big(\frac{2\pi e\rho^2}d\Big)^{d/2}.$$
* (b) For $K'>0$ put $\rho_{\rm tr}(K')=2\sqrt d\,(L/K')^{L/2}$. By Lemma 3.1(b), every network with $\kappa_N(w)\le K'$ satisfies $|z_w(x)-z_w(x')|\le2$ whenever $\|x-x'\|_2\le\rho_{\rm tr}(K')$. At $n=2^d$,
  $$\Pr\Big[\min_i\|x-x_i\|_2<\rho_{\rm tr}(K')\Big]\ \le\ K\,(8\pi e)^{d/2}\Big(\frac L{K'}\Big)^{Ld/2}=K\,2^{\frac d2\log_2(8\pi e)-\frac{Ld}2\log_2(K'/L)} .$$
* (c) Take $n=2^d$ and the energy level $K_2=\max\{n/c+t,K_{\rm mem}(d,n,a,H)\}$ of Theorem 7.2. For every $c,t>0$ and $a\in(0,1]$, the bound in (b) at $K'=K_2$ is at most $K\,2^{3.05d-(L/(2H))d^2}$. If $c\le1$, it is at most $K\,2^{3.05d-(L/2)d(d-\log_2L)}$.

*Proof.*

(a) By the union bound it suffices to treat one index $i$. Conditionally on $x_i$, $\Pr[\|x-x_i\|<\rho]$ is the integral of the density over $B(x_i,\rho)$, which is at most $K2^{-d}{\rm vol}(B_d(\rho))$. Next, ${\rm vol}(B_d(\rho))=\pi^{d/2}\rho^d/\Gamma(\frac d2+1)$. For $y>0$, $\Gamma(y+1)\ge\int_y^\infty s^ye^{-s}ds\ge y^y\int_y^\infty e^{-s}ds=(y/e)^y$. With $y=d/2$ this gives ${\rm vol}(B_d(\rho))\le(2\pi e\rho^2/d)^{d/2}$.

(b) Lemma 3.1(b) gives $|z_w(x)-z_w(x')|\le(K'/L)^{L/2}\|x-x'\|/\sqrt d\le2$ for $\|x-x'\|\le\rho_{\rm tr}(K')$. In (a), $2\pi e\rho_{\rm tr}^2/d=8\pi e\,(L/K')^L$, and $n2^{-d}=1$.

(c) With $s=\min\{n,M\}=2^d$ and $L=H+1$, $K_2\ge K_{\rm mem}\ge(H+1)(8ds)^{1/H}$ gives $K_2/L\ge(8d\,2^d)^{1/H}\ge2^{d/H}$. So $\frac{Ld}2\log_2(K_2/L)\ge\frac L{2H}d^2$. Also $\frac d2\log_2(8\pi e)=3.047\,d$. If $c\le1$, then $K_2\ge n=2^d$, so $\log_2(K_2/L)\ge d-\log_2L$. $\square$

**Remark 7.5 (what Proposition 7.4 means for Theorem 7.2).** This remark interprets Proposition 7.4 as a statement about the proof technique of Theorem 7.2; it is not a theorem, and "certify" below refers to that technique only. The proof of Theorem 7.2 links a test input to the sample only through Lemma 3.1(b) at the energy level $K_2$. Consider the clipped outputs, whose values at training inputs lie in $[-1,1]$. Take a test input $x$ with $\min_i\|x-x_i\|\ge\rho_{\rm tr}(K_2)$. For each $i$, the link says only that ${\rm clip}\,z_w(x)$ lies within $(K_2/L)^{L/2}\|x-x_i\|/\sqrt d\ge2$ of ${\rm clip}\,z_w(x_i)\in[-1,1]$. Every such interval contains $[-1,1]$, so the link cannot exclude ${\rm clip}\,z_w(x)=\eta(x)$ and certifies no excess at $x$. By Proposition 7.4(c), the test mass at which it can certify anything is at most $K\,2^{3.05d-(L/(2H))d^2}$ for every $c$. To certify a constant excess, the argument therefore needs a density ratio $K\ge2^{(L/(2H))d^2-O(d)}$, and $K\ge2^{(L/2)d^2-O(d)}$ when $c\le1$.

The A′ law meets this requirement with room to spare. Its density on $X$ is $(Mr^d)^{-1}$, which is $r^{-d}$ times the uniform density, and at $n=2^d$
$$\log_2r^{-d}=d\log_2n+\frac{Ld}2\log_2\frac{K_2}L\ \ge\ \Big(1+\frac L{2H}\Big)d^2 .$$
At $c=1$ this is $(1+\frac L2)d^2(1-o(1))$. Table 7.1 gives the numbers at $c=t=1$, $n=2^d$ and $a=a_d$ (`../checks/A/r1_density.out`).

| $(H,d)$ | $\log_{10}r$ | A′ density ratio, $\log_{10}r^{-d}$ | uniform inputs: $\log_{10}$ of the bound of Proposition 7.4(a) at $\rho_{\rm tr}(K_2)$, with the exact ball volume | $\log_{10}K$ needed for test mass $\frac12$ | $\log_{10}$ of the all-$c$ bound of (c), per unit $K$ |
|---|---|---|---|---|---|
| (2,20) | −14.3 | 286.7 | −148.9 | 148.6 | −72.0 |
| (2,30) | −21.9 | 655.8 | −358.4 | 358.1 | −175.7 |
| (2,40) | −29.4 | 1175.5 | −658.2 | 657.9 | −324.5 |
| (3,20) | −16.9 | 337.2 | −199.3 | 199.0 | −61.9 |
| (3,30) | −25.9 | 776.7 | −479.2 | 478.9 | −153.1 |
| (3,40) | −34.9 | 1396.8 | −879.5 | 879.2 | −284.4 |

The fourth column uses the exact volume ${\rm vol}(B_d(\rho))=\pi^{d/2}\rho^d/\Gamma(\frac d2+1)$, the first expression in Proposition 7.4(a); the Gamma-function bound, the second expression, is about one order of magnitude weaker, for example $-148.0$ instead of $-148.9$ at $(2,20)$ (`../checks/verify-A-computation/c5_density.out`). So, in the sense of Remark 7.5, the argument of Theorem 7.2 certifies nothing for uniform inputs on $[-1,1]^d$, or for any law whose density ratio is $2^{o(d^2)}$. Whether tightly conditioned SP$_c$ fails on such laws with noisy labels is a question of benign versus tempered overfitting for this learner. `red-team.md` §6.4 lists it as open, and its §6.2 surveys related results. It is open here as well (§10).

### 7.4 TUBE on A′ data

**Remark 7.6 (A′ does not transfer to TUBE).** Take the law of Theorem 7.2, for any $c>0$, with its radius $r$, and let $0<\rho<1$. Suppose some cluster $X_p$ contains two training inputs $x_i,x_j$ with $y_i\ne y_j$. Then every $w\in U_{\rho,S}$ satisfies
$$\kappa_N(w)\ >\ L\Big(\frac{2-2\rho}r\Big)^{2/L}=(2-2\rho)^{2/L}\,n^{2/L}\,K_2 .$$
Indeed, $|z_w(x_i)-z_w(x_j)|>|y_i-y_j|-2\rho=2-2\rho$ and $\|x_i-x_j\|\le r\sqrt d$, so Lemma 3.1(b) gives $(\kappa_N(w)/L)^{L/2}r>2-2\rho$; then substitute $r=\frac1n(L/K_2)^{L/2}$. The hypothesis holds with probability $1-e^{-\Omega(M)}$ at $n=\lambda M$, by Lemma 7.1(b) and Lemma 6.4(b) applied to the pairs $(p_i,y_i)$. At $\rho=\frac12$, $c=t=1$ and $n=2^d$, the energy floor is $10^3$ to $10^8$ times $K_2$ for $H\in\{2,3\}$ and $d\in\{20,30,40\}$ (`../checks/A/r1_density.out`). Every feasible network varies by more than $2-2\rho$ inside that cluster, so Step 2 of the proof of Theorem 7.2 is unavailable, and A′ yields no lower bound for TUBE$_\rho$. Whether TUBE$_\rho$ succeeds or fails on A′ data is not determined here.

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
* *Numbers.* For $s=2^d$ and $a=\frac12$ (`../checks/A/check_tube_and_lb.py`): at $(H,d)=(2,40)$, construction $5.6\cdot10^7$ against lower bound $2.1\cdot10^4$ (precisely $2.1499\cdot10^4$); at $(3,40)$, $2.9\cdot10^5$ against $1.5\cdot10^3$.
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

* *Below.* Theorem 4.4 gives memorization, with seen-atom excess at least $\beta(\lambda)-o(1)$, whenever $c=o(n^{1-1/H}d^{-1/H})$.
* *Above.* By Proposition 8.3(a), memorization is absent, with seen-atom excess $\to0$, whenever $\frac{2D_{d,H}}{\sqrt n}\big(\frac{n}{cH}\big)^{H/2}\to0$ and $c=o(n)$ (at a fixed slack $t$). The first condition reads $c\gg n^{1-1/H}(2D_{d,H})^{2/H}/H$, which is about $n^{1-1/H}d^{2/H}$.
* *Window.* The two thresholds differ by a factor $d^{3/H}$, polylogarithmic in $n$.

So the memorization transition of SP$_c$ on the cube example happens at $c=n^{1-1/H}$ up to polylogarithmic factors. The exponent $1/H$ is optimal on the construction side (Proposition 8.2) and on the learner side (Proposition 8.3(a)).

Proposition 8.3(a) controls only the outputs on seen atoms. Proposition 8.3(b) bounds the full test excess of unclipped near-minimizers on the cube example, unseen atoms included, when $\vartheta<1/(H+1)$; this matches the range $\theta<1/L$ of B-tempered-likelihood.md Theorem 6.4 on this example. Neither part covers the full test excess for $1/(H+1)\le\vartheta<1/H$. B-tempered-likelihood.md settles the test excess for clipped predictors. Its Theorem 6.3 gives vanishing excess for $c=n^{1-\theta}$, $0<\theta<1/H$, on every law, and its §7.5 (item 1) locates the remaining gap in a polylogarithmic window around $c\asymp n^{1-1/H}$. For unclipped predictors B-tempered-likelihood.md Theorem 6.4 covers $\theta<1/L$, and the window $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$, that is $\theta\in[1/L,1/H]$, is open (B-tempered-likelihood.md §7.5, item 2). Proposition 8.3 itself concerns only the centred-noise cube example.

---

## 9. Numerical checks

The scripts are in `../checks/A/`, with outputs `*.out` next to them; each was run from that folder as `python3 X.py > X.out`, except that `check_memorizer.py` and `spc_small_d.py` take the configuration as command-line arguments and their outputs list the configurations run. Items 1–6 are the first version's scripts, item 7 the scripts added in revision 1, and item 8 the script added in the second round. They are sanity checks, not proofs. Floating-point evaluations of explicit networks are not certified. The docstrings of the first-version scripts call this note `A.md` and use the numbering of an earlier draft: their Theorem 4.1 is Theorem 4.4, Lemma 6.2 in `check_tube_and_lb.py` is Lemma 6.4(b), Lemma 4.2 in `spc_small_d.py` is Lemma 4.1(b), and identity (2.3) in `check_parity.py` is (2.2). Those scripts were left unchanged, so their outputs remain the ones reported here.

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
   * No run of `check_memorizer.py` uses the lemma's own width $N_0$. The first-round computation referee's `../checks/verify-A-first-version-computation/v2_memorizer.py` does, in 8 configurations with $d\in\{3,\dots,6\}$, $H\in\{2,3,4\}$ and $a\in\{1,\frac12,\frac14\}$, and finds (2.1) satisfied in each; the second-round computation referee re-ran it with the same result (`../checks/verify-A-computation/c8_v2_memorizer_rerun.out`).
3. **`check_constants.py`.**
   * $|t-\tanh t|\le|t|^3/3$ on a grid. In double precision the ratio of the chain error to the bound (2.3) is at most $1.0000$ to four digits; the first-round computation referee's 50-digit evaluation finds it at most $0.99999998$ (`../checks/verify-A-first-version-computation/v1_constants.out`). It tends to 1 as $g\to0$, as Taylor's theorem predicts. At $R^2=9/(2a)$ and $|g|\le\frac32$, the error is at most $0.503\cdot\frac a2$.
   * $\beta(\lambda)$: the series and the closed form agree. $\beta(1)=0.484829$; the maximum is at $\lambda^*=1.50286$, where $\beta=0.517351=(1-e^{-\lambda^*})/\lambda^*$. On $[0.01,20]$ the largest finite-difference slope the script finds is $0.981$; the exact maximum of $|\beta'|$ there is $\beta'(0.01)=0.985$ (`../checks/A/r1_misc.out`). The supremum over $(0,\infty)$ is $1$, approached as $\lambda\to0$ ($\beta'(10^{-3})=0.9985$ in `../checks/A/r1_misc.out`), so the constant $1$ in Lemma 4.3(d) is sharp.
   * Binomial against Poisson: $|\beta_n-\beta(n/M)|$ is below Le Cam's $n/M^2$ for $d\in\{6,\dots,30\}$.
   * Monte Carlo of $Q/M$ at $n=2^d$, $d\in\{10,14,18\}$: means $0.48507,0.48484,0.48469$ against $\beta_n=0.48503,0.48484,0.48483$. Standard deviations are $0.0147,0.0038,0.0009$, inside the McDiarmid deviation at $\delta=0.01$, which is $0.095,0.024,0.006$.
   * Random networks satisfy Lemma 3.1: empirical gradient over $(\prod\kappa^{(\ell)}/d)^{1/2}$ is at most $0.84$, and $|z|/\sqrt\kappa\le0.62$.
   * The clip-mixture identity of step 3 in Lemma 8.1 holds to $1.3\cdot10^{-15}$.
4. **`bounds_table.py`.** The first version of Table 4.1 and of the admissible-$c$ values, with $a$ on a logarithmic grid. Superseded by `r1_table41.py` (item 7).
5. **`check_tube_and_lb.py`.**
   * Monte Carlo of "no atom carries both labels" lies below the bound of Lemma 6.4(b) in every tested case, for example $0.0000$ against $0.0232$ at $M=1024$, $n=256$.
   * Proposition 8.2 against Lemma 2.1, for $s=2^d$ (§8.2; the lower bound at $(2,40)$ is $2.1499\cdot10^4$, which the first version rounded to $2.2\cdot10^4$).
   * The Claim A′ radius $r(n)$: $\log_2r=-47.6,-72.6,-97.6$ at $d=20,30,40$ with $H=2$.
6. **`spc_small_d.py`** (illustration of Theorem 4.4 at small $d$, with $c=1$). L-BFGS on $F_c$ for the cube example with $n=2^d$.
   * $d=8$, $H=2$, $N=128$: the minimizer found has $\kappa=46.5$ and $\Delta=2.98$, so $F=49.5$, against $160.3$ for the zero network. Its test excess is $0.491$, of which $0.384$ is on seen atoms and $0.106$ on unseen ones; here $Q/M=0.4995$.
   * $d=8$, $H=3$, $N=96$: $\kappa=33.8$, $\Delta=0.92$, test excess $0.609$, of which $0.170$ is on unseen atoms.
   * $d=9$, $H=2$, $N=160$: $\kappa=58.6$, $\Delta=2.73$, test excess $0.547$, against $Q/M=0.475$.
   * Using the network found as the comparator in Lemma 4.1(b) *certifies* a lower bound for **all** near-minimizers: $0.069$, $0.111$ and $0.116$ respectively, up to floating-point evaluation.
   * Larger $c$ (`spc_small_d_largec.out`): at $d=8$, $H=2$ with $c=16=\sqrt n$ and with $c=64$, the optimizer returns the zero network, with test excess $0$. The memorizing configuration costs energy $\approx46$, more than the reduction of the data term it would bring, $(\Delta_0-\Delta)/c=(160.33-2.98)/16\approx9.8$ at $c=16$, where $\Delta=\sum_xk_x(z(x)-\bar y_x)^2$ is the quantity the script reports for the memorizer and $\Delta_0=160.33$ its value for the zero network (`spc_small_d.out`, `spc_small_d_largec.out`). $\Delta$ differs from the summed squared training residual by the within-atom variance, which is the same for every network, so $\Delta_0-\Delta$ is the reduction of that residual. This agrees with the threshold $c\approx n^{1-1/H}$ of §8.3.
   * These finite-$d$ runs illustrate the mechanism only. The asymptotic constants of §4 become informative around $d\approx20$–$30$ (Table 4.1).
7. **Scripts added in revision 1** (`r1_*.py`). In the second round their docstrings were updated to name this note and its current item numbers, `r1_table41.py` was corrected and extended as described next, and all five were re-run; apart from `r1_table41.out` and two labels, the outputs are unchanged.
   * `r1_table41.py`: Table 4.1. Revision 1 found the optimal $a$ for each $\lambda$ with a bounded scalar optimizer; at $(2,60)$ the values of $\underline e$ near the optimum differ by about $10^{-17}$, below double precision, and the optimizer stopped at $2.0\cdot10^{-10}$ instead of $a_{\rm kink}=1.91\cdot10^{-10}$, so revision 1 printed $N_0=4.7\cdot10^{42}$ instead of $5.1\cdot10^{42}$. The script now uses the closed form $a^*=\min\{a_{\rm int},a_{\rm kink},1\}$ of Remark 4.7 and keeps the optimizer as a cross-check. It also gives the $N_0$ columns; the largest $a$ with $\underline e\ge\underline e^*-0.001$ and its $N_0$; the gap to $\beta_n$ at $d=40$ ($0.0099$ and $0.0102$); the largest admissible $c$ by bisection ($29.25$ at $(2,30)$, $1583$ at $(3,30)$, $813$ at $(2,40)$, $1.59\cdot10^5$ at $(3,40)$); and the fixed-$a$ numbers of Remark 4.7, now with the finite-$d$ values.
   * `r1_fixed_d.py`: Proposition 5.2 and Table 5.1. For $d\in\{4,6,8\}$ and $n/M\in\{1,4,16,64,256,1024\}$ it simulates $U_S$. In every cell the empirical frequency of $\{U_S\le(8M/\delta'+4ct)/n\}$ at $\delta'=0.05$ is at least the guaranteed level $1-\delta'-Me^{-n/(8M)}$ (it is $1.000$ whenever $n/M\ge16$). It also runs the L-BFGS check reported after Proposition 5.2.
   * `r1_density.py`: Table 7.1 and the energy floor of Remark 7.6. It checks the exact ball volume against the Gamma-function bound of Proposition 7.4(a), and the $c=1$ values against the all-$c$ bound of Proposition 7.4(c).
   * `r1_tube_fixed_d.py`: Proposition 6.6(b), in exact rational arithmetic, as reported after its proof.
   * `r1_misc.py`: the §8.2 numbers ($2.1499\cdot10^4$ and $1.4513\cdot10^3$); $\beta(1)=0.4848291$, $\lambda^*=1.502861$, $\beta(\lambda^*)=0.5173514$ and $\beta'(\lambda)$ near $0$; the two-sided bound of Proposition 6.1(a′) on $20{,}000$ random instances, with no violation; sample sizes from Proposition 5.2.
8. **Script added in the second round.** `r2_numbers.py`, part 1: the certified A′ excess of Theorem 7.2 and of Proposition 7.2a against that of Theorem 4.4, with $a$ optimized separately for each bound, and the hypothesis $c(K_{\rm mem}+t)\le n$ of Proposition 7.2a at the optimum (paragraph after Theorem 7.2, and after Proposition 7.2a). Part 2: Corollary 4.5 against Corollary 4.5a, with $\bar\epsilon_d$, the displayed lower bound and $N_0/n$ for $d$ from $20$ to $400$ (after Corollary 4.5a). The second-round referees' scripts are in `../checks/verify-A-logic/`, `../checks/verify-A-computation/` and `../checks/verify-A-scope/`; the text cites their outputs where it uses them.

---

## 10. What is proved, and what is not

**What is refuted, and what is not.** This note refutes (P$_L$) for SP$_c$ with $c\,K_{\rm mem}=o(n)$, including $c=1$, at depth $L\ge3$ and learner widths $N\ge N_0$, in the strong-prior limit, uniformly over the input dimension (here $d=\log_2n$). It also refutes (P$_L$) for TUBE$_\rho$ at every tolerance, at a fixed input dimension: in the strong-prior limit for every schedule $\rho(n)$, and for both repository priors at every scale without a limit (Propositions 6.6 and 6.6a). It does not refute the conjecture, which allows any Bayesian learner. B-tempered-likelihood.md proves (P$_L$) for SP$_c$ with $c=n^{1-\theta}$, $\theta<1/H$ (clipped predictors, every learner width $N\ge m$), and E-finite-prior-scale.md proves a finite-scale analogue. What fails is the heuristic in the reading "condition each training output to within less than the noise level", for SP$_c$ at learner widths $N\ge N_0$ on laws whose test inputs (nearly) repeat training inputs (§5.4).

**Proved** (paper proofs, with all hypotheses stated above).

* Lemma 2.1: real-valued memorization with explicit $K_{\rm mem}$ and $N_0$, at every width $N\ge N_0$ and depth $\ge3$, with no margin conditioning.
* Lemmas 3.1–3.2 and Corollary 3.3: output, Lipschitz and strong-prior concentration bounds, including control of the posterior-mean tail.
* Theorem 4.4 and Corollaries 4.5, 4.5a and 4.6: Claim A for near-minimizers, Gibbs draws and posterior means, clipped or unclipped. Every term is explicit, $c=c(n)$ is arbitrary subject to (4.4), general label laws on $\mathcal C_d\times[-1,1]$ with ${\rm Var}(y\mid x)\ge v_0$ are covered, and the full limiting excess holds at learner widths $N\ge45\,d^3(d+1)2^d=O(n\log^4n)$.
* Proposition 5.1 and Remark 5.1a: refutation of (P$_L$) for SP$_c$ under the readings (R1)–(R3), and of its in-expectation version, for every $L\ge3$ and every $c$ satisfying (4.4) along $n=2^d$.
* Proposition 5.2: at a fixed $d$ the cube family is consistent at every width, with excess $O(2^d/n)$.
* Proposition 6.1: sampling without replacement, with a two-sided bound at $n=M$.
* Lemma 6.2, Propositions 6.3, 6.5, 6.6 and 6.6a, and Lemma 6.4: the TUBE$_\rho$ regimes of Table 6.1, including every tolerance for non-centred labels.
* Theorem 7.2, Proposition 7.2a and Corollary 7.2b: Claim A′ with an explicit radius $r(n)$ and label pattern, its sharper form under $c(K_{\rm mem}+t)\le n$ and $n\ge100$, and the refutation of (P$_L$) on these atomless laws.
* Proposition 7.4 and the energy floor of Remark 7.6: at $n=2^d$, for inputs whose density is at most $K$ times uniform, a test input lies within the transfer radius $\rho_{\rm tr}(K_2)$ of some training input with probability at most $K\,2^{3.05d-(L/(2H))d^2}$; and every TUBE$_\rho$-feasible network on A′ data with a conflicting cluster has energy above $(2-2\rho)^{2/L}n^{2/L}K_2$. Remark 7.5, which reads Proposition 7.4 as saying that the argument of Theorem 7.2 needs a density ratio $2^{\Omega(d^2)}$, is an interpretation, not a theorem.
* Lemma 8.1 and Propositions 8.2–8.3: optimality of the exponent $1/H$ on the construction side, and on the learner side for $n^{1-\vartheta}\le c=o(n)$.

**Not proved, or open.**

1. **The conjecture.** It is not refuted (§5.4). Within SP$_c$, B-tempered-likelihood.md Corollary 9.3 bounds how fast the competitors' weights may grow. Other Bayesian learners are not analysed here.
2. **Fixed input dimension beyond the cube family.** At a fixed $d$, SP$_c$ is consistent on the cube family (Proposition 5.2). Whether some other law at a fixed $d$ defeats tightly conditioned SP$_c$ is open. There the energy bound $\kappa_N\le n/c+t$ allows Lipschitz constants polynomial in $n$, while typical sample spacings are of order $n^{-1/d}$, so the Lipschitz bound does not prevent fitting individual points. The question is again one of benign versus tempered overfitting.
3. **Input laws with bounded density.** Input laws whose density is at most $2^{o(d^2)}$ times uniform, in particular uniform inputs on $[-1,1]^d$, with noisy labels: open. Proposition 7.4, as interpreted in Remark 7.5, shows that the Lipschitz transfer of Theorem 7.2 at the energy level $K_2$ cannot reach them. `red-team.md` §6.4 lists the same question.
4. **Depth two ($L=2$).** The memorizer costs $\Theta(s)$ energy, up to factors polynomial in $d$, at $H=1$ (Remark 2.5 and Proposition 8.2). Whether SP$_1$ at depth two still has a constant excess on $D_d$ is not settled here. [`depth-two.md`](depth-two.md), the refereed repair of `red-team.md` §5 (refereed in two rounds and re-refereed twice during finalization, on intermediate texts; the changes made after the last round were checked independently but not refereed again; see its header), proves a lower bound of order $(dc+1)^{-2}$ on the excess of depth-two SP$_c$ on the cube for every $0<c\le{\rm poly}(d)$, at learner widths $N\ge N_0=O(n\log^4n)$ and $n=\lceil\lambda2^d\rceil$ (its Theorem 5.1 and Corollary 5.2). At $c=1$ this lower bound is of order $d^{-2}=\Theta(1/\log^2n)$: enough to rule out polynomial sample bounds at depth two, but it tends to $0$. For $c\le\nu/\log_2n$ the excess is a constant, and $\beta(\lambda)-o(1)$ when $dc\to0$. Whether the excess at $c=1$ tends to $0$ is open there as well.
5. **Learner widths below $N_0$.** All SP$_c$ failures are proved for $N\ge N_0={\rm poly}(n)$: $N_0\le45\,d^3(d+1)2^d=O(n\log^4n)$ for the full limiting excess (Corollary 4.5a), and $N_0=O(n\log^2n)$ at a fixed accuracy, which is at least $2\cdot10^5n$ for $d\ge20$ and $a\le0.3$. Nothing is claimed for smaller widths. `small-learner-width.md` (the corrected `red-team.md` Proposition 6.1) gives a positive result for clipped predictions of SP$_c$ at small learner widths: for fixed $c>0$, a fixed competitor of width at most $N$ and fixed $d$, when $N=o(\sqrt{n/\log n})$; and at $c=1$, against competitors of the repository architecture with width and weights at most $n^\alpha$, at learner width $\lceil n^\alpha\rceil$ and $d\le n^\alpha$, excess $O(n^{2\alpha-1/2})$ for every $\alpha<1/4$ (§5.3 item 3).
6. **Finite-scale priors $\mu_{N,\gamma}$** with likelihood variance $cN^{-\gamma}$ (Claim E). SP$_c$ at finite scale is not treated in this note. E-finite-prior-scale.md (Theorem 5.2, Corollaries 5.3–5.4) transfers Claim A to every $\gamma\ge1$ at widths $N\ge N_*={\rm poly}(n)$, using a memorizer that survives the prior's noise (E-finite-prior-scale.md Proposition 4.4). Three referee reports on E-finite-prior-scale.md, through the logic, computation and scope lenses, the last after its three revision checks (`../verification/E-logic.md`, `../verification/E-computation.md`, `../verification/E-scope.md`), found this correct, with minor fixes; the scope report's one major issue concerned the README draft's summary of that note. A′ at finite scale is open (E-finite-prior-scale.md §5.4(c)). Of the TUBE results, Lemma 6.4(a) and Proposition 6.6(b) hold for every prior with full support, at every scale and width; Proposition 6.5 at every scale and at every width at which the tube is nonempty, in particular every $N\ge N_0(d,n,\rho/2)$; and Proposition 6.6a for both repository priors at every scale and width. The collapse for $\rho>1$ of Lemma 6.2 at finite scale is shown only as $N\to\infty$ at fixed $\gamma$ (the remark after Lemma 6.2). Proposition 6.3 and Proposition 6.6(a) are statements about the limit $\sigma\to0$.
7. **The progressive-mixture predictor.** Its prefix posterior means at small prefix lengths are not controlled by Lemma 4.1, so no lower bound is given. A heuristic count suggests a constant excess smaller than $\beta$.
8. **The window in $c$.** For clipped predictors, B-tempered-likelihood.md (Theorem 6.3 and §7.5) closes the window up to a polylogarithmic factor around $c\asymp n^{1-1/H}$. For unclipped predictors the window $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$ is open (B-tempered-likelihood.md Theorem 6.4 and §7.5). On the cube example, Proposition 8.3(a) controls only the seen atoms, and Proposition 8.3(b) bounds the full test excess of unclipped near-minimizers for $c=n^{1-\vartheta}$ with $0<\vartheta<1/(H+1)=1/L$, that is, for $c$ above that window and $c=o(n)$.
9. **TUBE on continuous i.i.d. inputs with $\rho<1$.** Not covered, and A′ does not transfer (Remark 7.6). TUBE$_1$ with fair labels and distinct inputs is also open: the minimum-energy sign interpolants are not analysed. A failure at $\rho=1$ is given only for other label laws (Propositions 6.3(b), 6.6 and 6.6a).
10. **Constants.** The $d$-dependence of $K_{\rm mem}$ is not shown optimal: there is a gap $O(d^{3/H})$ to Proposition 8.2, and the first-layer term $d^2\log^2 d$ is not shown necessary. The widths $N_0$ are far from economical.

---

## Appendix R. Response to the first-round referees

The first-round reports are [`../verification/A-first-version-logic.md`](../verification/A-first-version-logic.md), [`../verification/A-first-version-computation.md`](../verification/A-first-version-computation.md) and [`../verification/A-first-version-scope.md`](../verification/A-first-version-scope.md). They review the first version, preserved at [`../verification/A-first-version.md`](../verification/A-first-version.md), and this appendix records how revision 1 answered them. Their checks are in `../checks/verify-A-first-version-logic/`, `../checks/verify-A-first-version-computation/` and `../checks/verify-A-first-version-scope/`.

None of the three reports found a false theorem, lemma or proposition. Their issues concern what the results were said to mean, a few displayed formulas, and some numbers. I found every issue valid and changed the text accordingly. The list below gives the change for each issue. Issue titles keep the referees' locations, which use the first version's numbering; all other section numbers refer to the current text. Theorem, lemma and proposition numbers of the first version are unchanged, because the sibling notes cite them; the results added in revision 1 are Propositions 5.2, 6.6 and 7.4 and Remarks 7.5–7.6. Many passages named below were edited again in the second round, and Appendix R2 records those edits. Where such an edit changed what an entry below describes, so that the entry alone would misdescribe the current text, a bracketed note at the entry says what changed and points to Appendix R2.

### R.1 The three major issues (scope report, S1–S3)

**S1 (the conjecture is existential in the learner).** Valid. The first version never said that the conjecture survives, and its §0 item 4 and §5 title invited the reading "the conjecture is false". Changes:

* new §0.1, and §0.2 item 4 now carries the referee's suggested sentences [second round: §0.1 now separates the failure mechanisms of SP$_c$ and TUBE$_\rho$, and the last suggested sentence, "What fails is the heuristic that close conditioning is needed", now reads "What fails is the heuristic that the learner should condition closely on the training outputs, in its per-output reading and in the setting of Theorem 4.4"; §0.1 is restricted in the same way; see R2, scope N1 and N2 and logic issue 12];
* §5 is retitled "Why Claim A refutes (P$_L$) for tightly conditioned SP$_c$";
* new §5.4 states what is and is not refuted, citing B-tempered-likelihood.md Theorems 6.3–6.4 and Corollaries 8.1 and 9.3, E-finite-prior-scale.md Theorem 2.7, and `red-team.md` Remark 6.2, with the refereeing status of each [second round: these citations and statuses are updated; see R2, logic issues 6–7 and scope N2, N5 and N7];
* §10 opens with the same statement. [Second round: its sentence on the heuristic is restricted in the same way; see R2, scope N2 and logic issue 12.]

I checked each cited statement in its source before citing it.

**S2 (the refutation needs $d\to\infty$).** Valid. It agrees with logic issues 1 and 8 and computation issue 1. Changes:

* The referee's Proposition R1 is now Proposition 5.2. I re-derived its proof, extended it to the Gibbs and posterior-mean predictors in the limit $\sigma\to0$ (part (b)), and added an explicit sample size.
* §0.1, §0.2 items 3–5 and §5.3 items 1–2 now say that the refutation is uniform over the input dimension (here $d=\log_2n$).
* "Refuted for every $\alpha$ and every $o(1)$" now reads: refuted for every $o(1)$ term that is uniform over the input dimensions $d\le\log_2n$ (for example over all $d\le n^\alpha$), or more generally vanishes along $n=2^d$, as ${\rm poly}(d)\,n^{-\gamma}$ does. [Second round: the example is now $d\le{\rm polylog}(n)$, and the sentence names the learner and the learner widths; see R2, scope N4–N5.]
* The unproved phrase "only after exponentially many samples" is removed. §5.3 item 1 states what is known below and above the window $n=\Theta(2^d)$.
* `../checks/A/r1_fixed_d.py` reproduces the referee's simulation: the median bound decays like $4M/n$.

**S3 (A′ is near-atomic at the learner's resolution).** Valid. Changes:

* The §7 introduction now says that A′ meets the two objections formally and explains in what sense it does not. Remark 7.3 is reworded.
* New §7.3 proves the referee's Observation R2 as Proposition 7.4, with two refinements. First, it uses the transfer radius over which the Lipschitz bound allows a variation of $2$, the largest variation that matters for labels in $[-1,1]$. The referee's radius allowed a variation of $\frac12$, so the refined statement is stronger. Second, Proposition 7.4(c) gives a bound valid for every $c$, with exponent $(L/(2H))d^2$ from $K_2\ge K_{\rm mem}$, besides the exponent $(L/2)d^2$ for bounded $c$ that the referee computed.
* Remark 7.5 explains why the argument certifies no excess at test inputs beyond the transfer radius. [Second round: Remark 7.5 is now marked as an interpretation of Proposition 7.4, not a theorem, and Proposition 7.4 is retitled "test mass within the transfer radius"; see R2, logic issue 11.]
* Table 7.1 reproduces the referee's density ratios, $10^{287}$ to $10^{1397}$.
* §0.1, §0.2 item 10 and §10 item 3 list input laws with density ratio $2^{o(d^2)}$ and noisy labels as open, and §0.2 item 7 says that the Lipschitz transfer of the proof does not reach them. [Second round: §0.2 item 7 now presents that statement as Remark 7.5's interpretation of Proposition 7.4; see R2, logic issue 11.]

### R.2 Scope report, minor issues

* **S4 (TUBE on continuous i.i.d. inputs; A′ does not transfer).** Valid. The sentence after Proposition 6.3 is replaced as the referee suggested, and Observation R3 is now Remark 7.6. The optional fixed-$d$ TUBE negative (Observation R4) is now Proposition 6.6, with the explicit bound $2e^{-n(1-\eta_0)/(2M)}$ in place of a limit argument. `../checks/A/r1_tube_fixed_d.py` checks it exactly.
* **S5 (progressive mixture).** Valid. §0.2 item 4 and §5.1 now say that it is not covered.
* **S6 (order of $N_0$).** Valid. §0.2 item 3 and §5.3 item 3 give $N_0=O(n\log^2n/a^2)$, the range $N_0/n\in[2\cdot10^5,7.3\cdot10^6]$, and "nothing is proved for $N<N_0$". [Second round: revision 1 printed the upper end as $7\cdot10^6$; see R2, logic issue 13.]
* **S7 (finite scale; "the slt-likelihood theorem").** Valid. The text now says "the strong-prior theorem of slt-likelihood §2", and §10 item 6 cites E-finite-prior-scale.md for the finite scale.
* **S8 (stale window).** Valid. §8.3 and §10 item 8 now cite B-tempered-likelihood.md Theorems 6.3–6.4 and §7.5.
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
12. *§10 item 3 (now §10 item 6) overstated the finite-scale TUBE results.* Valid. §10 item 6 lists which TUBE statements hold at finite scale, and the remark after Lemma 6.2 says that its finite-scale collapse is asymptotic in $N$. [Second round: that list omitted the width hypothesis of Proposition 6.5; it now gives it, as every width at which the tube is nonempty, in particular every $N\ge N_0(d,n,\rho/2)$, and adds Proposition 6.6a; the remark after Lemma 6.2 gives the same corrected list; see R2, logic issue 3 and scope N6.]
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
   * (d) Table 4.1 is recomputed with continuous optimization of $a$ (`../checks/A/r1_table41.py`). The optimizing $a$ at $(2,60)$ is $1.9\cdot10^{-10}$, and the new $N_0$ column reaches $5.1\cdot10^{42}$. [Second round: revision 1 printed $2.0\cdot10^{-10}$ and $4.7\cdot10^{42}$, because its optimizer stopped short of the optimum at $(2,60)$; see R2, computation issue 3.]
   * (e) §9 item 3 now says that $\sup|\beta'|=1$, approached as $\lambda\to0$.
   * (f) §9 item 2 now says which runs of `check_memorizer.py` used the Hoeffding feature count, and cites the computation referee's `../checks/verify-A-first-version-computation/v2_memorizer.py` for runs at the lemma's own width $N_0$.
8. *(R1) wording; $P$ used for two things.* Valid. (R1) is fixed as in logic issue 9, and the path norm in Lemma 8.1 is now $\varpi$.

---

## Appendix R2. Second referee round

Three referees reviewed revision 1, each through one lens: [`../verification/A-logic.md`](../verification/A-logic.md) (logic and definitions), [`../verification/A-computation.md`](../verification/A-computation.md) (constants, probabilities and quoted numbers) and [`../verification/A-scope.md`](../verification/A-scope.md) (scope and adversarial interpretation). Their checks are in `../checks/verify-A-logic/`, `../checks/verify-A-computation/` and `../checks/verify-A-scope/`. All three returned the verdict "minor fixes". None found a false theorem, lemma, proposition or corollary, or a step of a proof that fails. All three checked the first-round issues in the body of the text and found them fixed, with one exception and two caveats: the computation referee found the entries that revision 1 gave for the $(2,60)$ row of Table 4.1 slightly off (answered as computation issue 3); the scope referee noted under S6 that the range of $N_0/n$ should end at $7.3\cdot10^6$ (answered as logic issue 13); and the logic referee marked its first-round issue 12 as fixed but referred to its new issue 3, on the width hypothesis of Proposition 6.5. Their issues concern summary sentences that dropped hypotheses, the framing of what is refuted, citations of other notes, a few numbers, and presentation. I found every issue valid and changed the text for each; the referee record at the end of this appendix lists them one by one. The paragraphs below explain the changes that go beyond a local correction.

**Items added.** Six items were added, all with lettered numbers, so no existing number moved.

* Corollary 4.5a (computation issue 1(b)). The accuracy schedule $a'_d=\max\{a_d,1/d\}$ keeps the limit $\beta(\lambda)$ and lowers the width threshold from $O(n^{5/3}\log^2n)$ to $45\,d^3(d+1)2^d=O(n\log^4n)$, at the price of slower convergence. The argument is the referee's; I re-derived it.
* Remark 5.1a (scope issue N9). The in-expectation version of (P$_L$) fails as well.
* Proposition 6.6a (scope issue N6). This is the referee's Observation S-1, re-derived. It shows that TUBE fails at every tolerance for both repository priors at every scale, with no limit $\sigma\to0$. It answers logic issue 2 by proving the statement rather than only qualifying it. Proposition 6.6 is kept: it also covers $\delta\ge\frac12$ under (R1) for the strong prior, and the sentences that rest on it alone now carry the strong-prior qualifier.
* Remark 6.6b (scope issues N1 and N7). It cites `red-team.md` Proposition 4.1, the positive TUBE bound with a matched tolerance, with its verification status, and explains why it does not conflict with Propositions 6.6 and 6.6a.
* Proposition 7.2a (computation issue 2). This is the referee's sharper Step 4, re-derived, under the extra hypotheses $c(K_{\rm mem}+t)\le n$ and $n\ge100$; it recovers the numbers of Theorem 4.4 for A′. Theorem 7.2 is unchanged, because other notes cite it, and the paragraph after it now says how slowly its bound converges.
* Corollary 7.2b (logic issue 15). The refutation of (P$_L$) on the A′ laws, which revision 1 asserted without stating it.

**Summaries that claimed too much.** Several summary sentences dropped hypotheses of the results they summarize: the width threshold and $\rho<b$ in the bullet on TUBE without replacement, which was false as written (scope N3); the width threshold of Proposition 6.5 elsewhere (logic issue 3); the hypotheses of Proposition 6.1 (logic issue 4); the strong-prior restriction for $\rho>1$ (logic issue 2); the dependence of a $\sigma$-threshold on $\varepsilon$ (logic issue 5); the learner and the learner widths in the $n^\alpha$ reading (logic issue 8, scope N4); and the status of Remark 7.5 (logic issue 11). Two sentences misdescribed a proved result: §8.3 and §10 understated Proposition 8.3(b) (logic issue 1), and §8.3 asserted a limit where only a lower bound is proved (logic issue 10). Each of these sentences now says what the cited result proves.

**What is refuted, and why.** The title, §0.1, §5.4 and §10 no longer present TUBE as a tightly conditioned learner (scope N1). For $\rho\le1$ it fails because the tube is empty, and for $\rho>1$ because a per-point tolerance centres the admissible outputs at the midrange of the labels rather than at their mean. The user's heuristic is now said to fail only in the reading "condition each training output to within less than the noise level", for SP$_c$ at widths $N\ge N_0$, on laws whose test inputs (nearly) repeat training inputs, with $d\to\infty$. The reading "fit the training data about as well as the best small network does" is said to describe the successful learners (scope N2 and N8, logic issue 12).

**Other notes.** Every citation of another note was checked again in its source. B-tempered-likelihood.md Theorem 6.3 is now summarized with its limit $\sigma\to0$, the probability $1-\delta-\eta$ for a single Gibbs draw and its competitor architecture (logic issue 7), and Corollary 8.1 with its ${\rm poly}(d)$ factor (scope N5). E-finite-prior-scale.md is cited with both of its referee reports (computation issue 7, scope N7). The `red-team.md` results are cited with their verification status at the time of this revision (logic issue 6, scope N7). Two referees (logic and computation) found Proposition 4.1 correct, with minor fixes only. Two referees found the proofs of §5 correct, but one sentence of its Corollary 5.2 is false for $c\to0$, and a repair is in progress (§10 item 4). One logic referee found Remark 6.2 correct, with minor fixes. Proposition 6.1 is refereed with a corrected rate, and its repair is under review. `C-fixed-temperature-bayes.md` is now cited for FIX$_\eta$ (scope N9).

**Numbers and scripts.** `../checks/A/r1_table41.py` now computes the optimal accuracy in closed form. This corrects the $(2,60)$ row of Table 4.1 and item 7(d) of Appendix R (computation issue 3). The script also gives the new last column of Table 4.1 (computation issue 1(a)) and the finite-$d$ values at a fixed accuracy (computation issue 5). For the latter the referee suggested $0.226$ at $(H,d)=(2,20)$ and $a=0.1$; the value is $0.22547$, so the text gives $0.225$. The new script `../checks/A/r2_numbers.py` gives the numbers of Corollary 4.5a, of Proposition 7.2a and of Theorem 7.2 as stated. Those of Corollary 4.5a and of Theorem 7.2 agree with the computation referee's `../checks/verify-A-computation/c10_cor45_width.out` and `../checks/verify-A-computation/c2_table41.out` to the printed digits. Those of Proposition 7.2a agree with the referee's `../checks/verify-A-computation/c2b_flatness.out` to within $10^{-4}$: at $(3,20)$ that file gives $0.4062$ against $0.4063$, because its logarithmic grid in $a$ does not contain the optimum $a^*=8.16\cdot10^{-3}$, at which `r2_numbers.py` evaluates the bound. The docstrings of the five revision-1 scripts named this note by its draft name `A.r1.md`; they now give its file name and current item numbers, and one printed label (Proposition 6.1(a) for (a′)) and one column header (the exact ball volume of Table 7.1) were corrected. All five were re-run from `../checks/A/`, each in under a minute, and their outputs are unchanged apart from Table 4.1 and those two labels. The first-version scripts were left unchanged; their docstrings use an earlier draft's numbering, which §9 now translates. Changing them would have required a re-run: `spc_small_d.py` takes more than five minutes (the first-round computation referee's re-run of three of its configurations took over seven), and the seeds of the reported `check_memorizer.py` runs are not recorded.

**Not adopted, with reasons.**

* The optional remark in logic issue 11, that the $2^{\Theta(d^2)}$ threshold should persist beyond the energy level $K_2$, is not added. The referee marks it as unchecked, and Remark 7.5 restricts its claim to the level $K_2$.
* The symbols listed in logic issue 16 were not renamed. A list of their meanings was added at the end of §1.4 instead, because other notes cite these results with the current symbols; for example, E-finite-prior-scale.md applies Lemma 4.2(b) "with $B=\eta n$".

**Other corrections.** The opening paragraph now follows the repository layout. Paths to scripts in `A_scripts/`, `A_r1_scripts/` and `verify_A_computation_scripts/` now point to `../checks/A/` and `../checks/verify-A-first-version-computation/`. §9 item 3 attributed a 60-digit evaluation of the chain bound to `check_constants.py`, which computes in double precision; the high-precision evaluation, at 50 digits, is the first-round computation referee's, and the text now says so. Proposition 7.4 is retitled "test mass within the transfer radius", because its former title, "the Lipschitz transfer needs near-duplicates", stated the interpretation that Remark 7.5 now marks as such (logic issue 11). The second-round reports cite line numbers of revision 1. Section and result numbers have not changed since, so their references by number still apply, but their line numbers do not.

### Referee record

**Reports.**

* First round, on the first version ([`../verification/A-first-version.md`](../verification/A-first-version.md)), answered in Appendix R:
  * [`../verification/A-first-version-logic.md`](../verification/A-first-version-logic.md): logic and definitions; checks in `../checks/verify-A-first-version-logic/`.
  * [`../verification/A-first-version-computation.md`](../verification/A-first-version-computation.md): computation; checks in `../checks/verify-A-first-version-computation/`.
  * [`../verification/A-first-version-scope.md`](../verification/A-first-version-scope.md): scope; checks in `../checks/verify-A-first-version-scope/`.
* Second round, on revision 1, answered in this appendix:
  * [`../verification/A-logic.md`](../verification/A-logic.md): logic and definitions; checks in `../checks/verify-A-logic/`.
  * [`../verification/A-computation.md`](../verification/A-computation.md): computation; checks in `../checks/verify-A-computation/`.
  * [`../verification/A-scope.md`](../verification/A-scope.md): scope and adversarial interpretation; checks in `../checks/verify-A-scope/`.
* Checks of the revision: three independent checkers, not referees, each read this revision against revision 1 and the three second-round reports, each after the previous check's points had been answered: [`../verification/A-revision-check-1.md`](../verification/A-revision-check-1.md), [`../verification/A-revision-check-2.md`](../verification/A-revision-check-2.md) and [`../verification/A-revision-check-3.md`](../verification/A-revision-check-3.md), with their scripts in `../checks/revision-check-A-1/` to `../checks/revision-check-A-3/`. Each found every second-round issue answered. The first two raised five minor points each, answered in the tables "First check of the revision" and "Second check of the revision" below; the third raised three, which the lead editor resolved (last table).

All six reports returned the verdict "minor fixes", and so did all three checks of the revision.

**Resolutions.** *Fixed* means that a wrong number or expression was corrected, a missing statement, proof step, citation or explanation was added, or an ambiguity was removed, without reducing what any proved statement asserts. *Weakened* means that a sentence that was false, unproved or overstated now carries the missing hypothesis or qualifier, or claims less. *Rebutted* means that the issue was judged invalid and the text left unchanged; no issue of either round, and no point of either check of the revision, was rebutted.

**Second round.** The table has one row per issue in the issue lists of the three reports (`../verification/A-logic.md` §4, `../verification/A-computation.md` §5, `../verification/A-scope.md` §4), with the parts of an issue in separate rows. Two further rows record a remark in §4 of the computation report and a suggestion in §5 of the scope report.

| report | issue | resolution | where |
|---|---|---|---|
| logic 1 | §8.3 and §10 item 8 say that Proposition 8.3 controls only the seen atoms, but part (b) bounds the full test excess | fixed: parts (a) and (b) distinguished; (b) covers $\vartheta<1/(H+1)$, matching B-tempered-likelihood.md Theorem 6.4, and neither part covers $1/(H+1)\le\vartheta<1/H$ | §8.3, last paragraph; §10 item 8; §0.2 item 8 |
| logic 2 | "every tolerance schedule" drops the strong-prior restriction for $\rho>1$ | fixed: the qualifier added where only Proposition 6.6 is used, and Proposition 6.6a proves the statement for both repository priors at every scale | §0.2 item 6; Prop 6.6 (consequence); §6.2 after Prop 6.3; Prop 6.6a (new); Table 6.1 |
| logic 3 | Proposition 6.5 is cited as holding at every width, but it assumes $N\ge N_0(d,n,\rho/2)$; §0.2 also omits $\rho<b$ | weakened: "at every width at which the tube is nonempty, in particular every $N\ge N_0(d,n,\rho/2)$"; $\rho<b$ added | remark after Lemma 6.2; §10 item 6; §0.2 item 6 |
| logic 4 | the without-replacement summary omits $\epsilon'$, its asymptotic regime and the width threshold | weakened | §0.2 item 6 |
| logic 5 | the $\sigma$-threshold of Proposition 5.1 also depends on $\varepsilon$ and $H$ | weakened | Prop 5.1, statement and end of proof |
| logic 6 | `red-team.md` Proposition 6.1 is cited with $\alpha<1/4$ and reads as covering the unclipped learner | weakened: clipped predictions; $\alpha<1/8$ as displayed, $\alpha<1/4$ only with the Bernstein step under review; cited as refereed with a corrected rate, repair under review, with links to its two referee reports (added after the second check, point 5) | §5.3 item 3; §5.4, "The heuristic"; §10 item 5 |
| logic 7 | the summary of B-tempered-likelihood.md Theorem 6.3 overstates its Gibbs and posterior-mean statements | weakened: limit $\sigma\to0$; probability $1-\delta-\eta$ for a single Gibbs draw | §5.4, first bullet; §0.1 |
| logic 8 | the $n^\alpha$ reading is refuted only at learner widths $N\ge N_0$ | weakened | §5.3 item 2 |
| logic 9 | Corollary 4.6 and Proposition 6.1(b) use Theorem 4.4(iv) although the labels need not take finitely many values | fixed: the compact-inputs case of Remark 3.4 cited | proofs of Cor 4.6 and Prop 6.1(b) |
| logic 10 | "seen-atom excess $\to\beta(\lambda)$" is not proved | weakened: "at least $\beta(\lambda)-o(1)$" | §8.3, "The threshold, sharply" |
| logic 11 | §10 lists the interpretive claims of Remark 7.5 as proved; an optional remark on the threshold beyond $K_2$ | weakened: Remark 7.5 marked as an interpretation of Proposition 7.4, Proposition 7.4 retitled, and §10 lists Proposition 7.4 and the energy floor of Remark 7.6 as proved; the optional remark is not adopted, since it is unchecked | Remark 7.5; Prop 7.4 (title); §7 introduction; §7.3, after Table 7.1; §0.1; §0.2 item 7; §10 ("Proved"; item 3) |
| logic 12 | "conditioning tight enough … is what breaks the property" attributes the failure to the training MSE alone | weakened: restricted to laws whose test inputs (nearly) repeat training inputs, widths $N\ge N_0$ and $d\to\infty$; bounded-density laws stated open | §0.1; §5.4, "The heuristic"; §10 |
| logic 13 | the range of $N_0/n$ ends at $7.3\cdot10^6$, not $7\cdot10^6$ | fixed | §0.2 item 3; §5.3 item 3; Appendix R (S6) |
| logic 14 | the order of limits in Proposition 6.1(a′) is implicit | fixed: $\sigma\to0$ first, then $d\to\infty$, with explicit bounds $\ell_d$ and $u_d$ | Prop 6.1(a′); §0.2 item 6 |
| logic 15 | the refutation of (P$_L$) through A′ is asserted but not stated | fixed: Corollary 7.2b | Cor 7.2b (new); §7 introduction; §0.1; §0.2 items 4 and 7; §5.4; §10 |
| logic 16 | overloaded symbols ($B$, $\delta$, $p$, $\rho$, $m$, $\gamma$, $E$) | fixed: their local meanings listed; not renamed, because other notes cite the current symbols | §1.4, end |
| computation 1(a) | Table 4.1 reports $N_0$ at a flat maximum, overstating the width the bound needs by up to 13 orders of magnitude | fixed: closed form for the optimal $a$; new column with $N_0$ at the largest $a$ within $0.001$ of the maximum ($5.0\cdot10^{13}$ to $2.1\cdot10^{29}$); the "astronomically large" sentence replaced | Remark 4.7 and Table 4.1; `../checks/A/r1_table41.py` |
| computation 1(b) | the exponent $5/3$ in Corollary 4.5 comes from the choice of $a_d$; a slower schedule gives $N_0=O(n\log^4n)$ | fixed: Corollary 4.5a | Cor 4.5a (new); §0.2 items 3–4; §5.3 item 3; §10 ("Proved"; item 5); `../checks/A/r2_numbers.py` |
| computation 2 | Step 4 of Theorem 7.2 is loose; at $(H,d)=(2,20)$ the theorem certifies only $0.0015$ | fixed: the slow convergence stated after Theorem 7.2 with numbers; Proposition 7.2a gives the sharper Step 4 under $c(K_{\rm mem}+t)\le n$ and $n\ge100$ | paragraph after Thm 7.2; Prop 7.2a (new); §0.2 item 7; `../checks/A/r2_numbers.py` |
| computation 3 | the $(2,60)$ row of Table 4.1 and Appendix R item 7(d) should read $1.9\cdot10^{-10}$ and $5.1\cdot10^{42}$ | fixed: script corrected and re-run | Table 4.1; Appendix R (R.4, item 7(d)); §9 item 7; `../checks/A/r1_table41.py` |
| computation 4 | "$7\cdot10^6$" should read $7.3\cdot10^6$ | fixed (as logic 13) | as logic 13 |
| computation 5 | the fixed-$a$ value $0.356$ is the $d\to\infty$ limit | fixed: stated as a limit, with the finite-$d$ values; $0.225$, not $0.226$, at $(2,20)$ and $a=0.1$ | Remark 4.7; §0.2 item 3; §5.3 item 3; `../checks/A/r1_table41.py` |
| computation 6, first part | Table 7.1, column 4: exact ball volume or Gamma-function bound? | fixed: the header says "with the exact ball volume", and the Gamma-bound value is given for comparison; the script's column header changed accordingly | Table 7.1 and the paragraph after it; `../checks/A/r1_density.py` |
| computation 6, second part | "$\max\lvert\beta'\rvert=0.981$" is a finite-difference value | fixed: the finite-difference value and the exact maximum $0.985$ both given | §9 item 3 |
| computation 7 | E-finite-prior-scale.md has two referee reports | fixed | §5.4; §10 item 6 |
| computation §4 | the entries of Table 5.1 are Monte Carlo medians; the $(6,16)$ entry sits at the edge | fixed: stated, with the 8000-sample median | §5.2, before Table 5.1 |
| scope N1 | TUBE is not tightly conditioned when $\rho>1$, yet the title, §0.1 and §5.4 enlist it as evidence | weakened: the two learners and their failure mechanisms separated; retitled | title; §0.1; §5.4; §10 |
| scope N1, optional part | complete the TUBE picture with `red-team.md` Proposition 4.1 | fixed: Remark 6.6b | Remark 6.6b (new) |
| scope N2 | "the heuristic fails" needs a reading, a width qualifier and the near-atomic restriction | weakened: the per-output reading, $N\ge N_0$, near-atomic laws; the aggregate-fit reading described as what the successful learners do | §0.1; §5.4, "The heuristic"; §10 |
| scope N3 | §0.2 item 6, third bullet, is false as written | weakened: $\rho<b$ and $N\ge N_0(d,n,\rho/2)$ added | §0.2 item 6 |
| scope N4 | §5.3 item 2 refutes the $n^\alpha$ reading without naming the learner | weakened: SP$_c$ with $c\,K_{\rm mem}=o(n)$ at $N\ge N_0$; the tempered learner's positive result cited | §5.3 item 2 |
| scope N5 | the error term of B-tempered-likelihood.md Corollary 8.1 has a ${\rm poly}(d)$ factor; the uniformity example should be $d\le{\rm polylog}(n)$ | fixed: error term, competitor architecture and learner widths stated; the range of uniformity stated | §5.4, first bullet; §5.3 item 2; Appendix R (S2) |
| scope N6 | Proposition 6.6(a) does not need the strong-prior limit (Observation S-1) | fixed: Proposition 6.6a | Prop 6.6a (new); §0.1; §0.2 item 6; §6.2; Table 6.1; §5.4; §10 |
| scope N7 | refereeing status of E-finite-prior-scale.md and of `red-team.md` Proposition 6.1, Remark 6.2 and Proposition 4.1 | fixed: current statuses stated, with links to the referee reports (for the `red-team.md` results, added after the second check, point 5) | §5.3 item 3; §5.4; §10 items 4–6; Remark 6.6b |
| scope N8 | "pays the difference back at test time" | weakened: "pays a constant part of the difference back", with the training deficit $0.63$ and the test excess $0.48$ | §5.4, "The heuristic" |
| scope N9, first part | the in-expectation reading fails too | fixed: Remark 5.1a | Remark 5.1a (new); §0.2 item 4; §10 |
| scope N9, second part | the repository's main result 4 is a precedent for uniformity in $d$ | fixed | §0.1; §5.4 |
| scope N9, third part | FIX$_\eta$ and a hyperprior on the noise scale lie outside the note | fixed: listed as not covered, with C-fixed-temperature-bayes.md's results on FIX$_\eta$ | §0.1 |
| scope §5 item 2 | state the three regimes of a learner width $N=n^{\alpha'}$ | fixed | §5.3 item 3 |

**First round.** One row per issue of the three first-round reports, as answered in Appendix R; the locations are those of the current text.

| report | issue | resolution | where |
|---|---|---|---|
| logic 1 | the "$o(1)$" reading needs uniformity in $d$ | weakened (with scope S2) | §0.1; §5.3 item 2 |
| logic 2 | "every reading" includes the progressive mixture | weakened (with scope S5) | §0.2 item 4; §5.1; §10 item 7 |
| logic 3 | the above-threshold claims need $c=o(n)$ | weakened | §0.2 item 8; §5.3 item 5; §8.3 |
| logic 4 | "$=$" for an upper bound in Corollary 4.5; $a_d\le1$ only for large $d$ | fixed | Cor 4.5 |
| logic 5 | Corollary 4.5 assumed $t\le1$, Proposition 5.1 any $t$ | fixed | Cor 4.5; Prop 5.1 |
| logic 6 | "test MSE tending to 2" lacked an upper bound | fixed: upper bound proved | Prop 6.1(a′) |
| logic 7 | Remark 7.3 overstated | weakened | Remark 7.3 |
| logic 8 | the first version's §5.2 item 1 was unproved | weakened (with scope S2) | §5.3 item 1; Prop 5.2 |
| logic 9 | the repository's $\sigma$-thresholds were described imprecisely | fixed: both sources quoted | §5.1, (R1) |
| logic 10 | §0 item 7 mixed Proposition 8.2(a) and (b) | fixed | §0.2 item 8 |
| logic 11 | treating "undefined" as failure needs a convention | fixed: conventions (U1) and (U2); Proposition 6.6 | §6.2; Prop 6.6 |
| logic 12 | the finite-scale TUBE results were overstated | weakened | remark after Lemma 6.2; §10 item 6 |
| logic 13 | Corollary 3.3 needs $\Pi_\sigma(\mathcal N_t)>0$ | fixed | Cor 3.3 |
| logic 14 | the nearest-neighbour remark | fixed | paragraph after Lemma 4.3 |
| logic 15 | (R3) should use outer probability | fixed | §5.1, (R3); Prop 5.1 |
| logic 16 | $\underline e'$ in Theorem 7.2(i) depended on the sample | fixed | Thm 7.2 |
| computation 1 | the $\Omega(1)$ excess holds only along $n\asymp2^d$ | weakened (with scope S2) | §5.3 items 1–2; Prop 5.2 |
| computation 2 | the above-threshold claims need $c=o(n)$ | weakened (as logic 3) | as logic 3 |
| computation 3 | Corollary 4.5's display and range of $d$ | fixed (as logic 4 and 5) | Cor 4.5 |
| computation 4 | the $\rho=1$ tube set | fixed | §6.2, after Table 6.1 |
| computation 5 | "tends to" where only a lower bound was proved | fixed | Prop 6.1(a′); Remark 7.3 |
| computation 6 | §0 item 7 mixed Proposition 8.2(a) and (b) | fixed (as logic 10) | §0.2 item 8 |
| computation 7 | numbers that did not reproduce exactly, (a)–(f) | fixed | §8.2; Remark 4.7 and Table 4.1; §9 items 2–3 |
| computation 8 | (R1) wording; $P$ used for two things | fixed | §5.1, (R1); Lemma 8.1 ($\varpi$) |
| scope S1 | the conjecture is existential in the learner; the first version never said that it is not refuted | weakened | §0.1; §0.2 item 4; §5 title; §5.4; §10 |
| scope S2 | the refutation needs $d\to\infty$ | weakened: uniformity over $d$ stated; Proposition 5.2 added | §0.1; §0.2 items 3–5; §5.2; §5.3 |
| scope S3 | A′ is near-atomic at the learner's resolution | weakened: the scope of A′ stated; Proposition 7.4 and Remark 7.5 added | §7 introduction; Remark 7.3; §7.3; §0.1; §10 item 3 |
| scope S4 | TUBE on continuous i.i.d. inputs is not covered, and A′ does not transfer | weakened: stated; Remark 7.6 and Proposition 6.6 added | §6.2; Remark 7.6; Prop 6.6 |
| scope S5 | the progressive mixture is not covered | weakened | §0.2 item 4; §5.1 |
| scope S6 | the learner widths of the failure should be stated | fixed | §0.2 item 3; §5.3 item 3 |
| scope S7 | the finite-scale status; "the slt-likelihood theorem" was ambiguous | fixed | §5.3 item 5; Remark 4.9; §10 item 6 |
| scope S8 | the window in $c$ was stale | fixed | §8.3; §10 item 8 |
| scope S9 | the convention for an undefined posterior | weakened: under (U2) the fair-label row is not a failure | §6.2; Table 6.1 |
| scope S10 | Remark 4.9's wording | fixed | Remark 4.9 |

**First check of the revision** ([`../verification/A-revision-check-1.md`](../verification/A-revision-check-1.md)). One row per point raised by the first independent check. I found all five valid. None affects a theorem, lemma, proposition or corollary.

| point | issue | resolution | where |
|---|---|---|---|
| 1 | §10 item 8 said that Proposition 8.3(b) covers $\vartheta<1/(H+1)$, "that is, below the same window"; the window was written in $c$, and $\vartheta<1/L$ puts $c=n^{1-\vartheta}$ above it | fixed: "for $c=n^{1-\vartheta}$ with $0<\vartheta<1/(H+1)=1/L$, that is, for $c$ above that window and $c=o(n)$" | §10 item 8 |
| 2 | Remark 4.7 said that the columns for $a$ and $N_0$ were added in revision 1, but the first version's Table 4.1 already had the column of optimizing $a$ | fixed: the first version had that column; revision 1 changed four of its entries and added the $N_0$ column; the second round corrected the $(2,60)$ entries of both columns and added the last column | Remark 4.7 |
| 3 | §5.3 item 2 cited B-tempered-likelihood.md Corollary 8.1 for the $n^\alpha$ reading without its restrictions to $\alpha<1/(4H)$ and to clipped predictions, so the sentence read as covering every $\alpha$, while B-tempered-likelihood.md Corollary 9.3 shows that no $c(n)$ works for $\alpha>L/(2H(2L-1))$ | weakened: "for $\alpha<1/(4H)$ and clipped predictions", with the learner widths $N\ge n^\alpha$ of Corollary 8.1 and a pointer to the limit of Corollary 9.3 stated in §5.4 | §5.3 item 2 |
| 4 | the symbol list of §1.4 said that each meaning is local to the places listed, but omitted $\rho$ as a ball radius in Proposition 7.4(a), the coefficients $\gamma_j$ of Lemma 2.1 and the generic exponent in ${\rm poly}(d)\,n^{-\gamma}$, and $B$ as a ball | fixed: these meanings added, with the others that a search of the text for the seven listed symbols found ($B$ as a Borel set in (1.3), $p$ as a binomial parameter in two proofs, $m$ as the index in Lemma 2.2, and further places of several listed meanings); the lead sentence now says that the list covers the seven symbols flagged by the logic referee, not every reused letter, and names the subscripted variants that are separate symbols; that search missed two details, corrected after the second check (point 2) | §1.4, end |
| 5 | Appendix R2 said that all three referees confirmed the first-round fixes, but the computation referee excepted the $(2,60)$ entries of Table 4.1; it also said that the numbers of Proposition 7.2a agree with the referee's `../checks/verify-A-computation/c2b_flatness.out`, which gives $0.4062$ against $0.4063$ at $(3,20)$ | weakened: the computation referee's exception stated, together with the caveats of the scope referee (under S6) and of the logic referee (at its first-round issue 12); "to within $10^{-4}$", with the reason: the referee's grid in $a$ does not contain the optimum | Appendix R2, first paragraph and "Numbers and scripts" |

While making these changes I corrected one more cross-reference, which the first check did not raise. §10 item 4 said that `red-team.md` §5 gives depth-two SP$_c$ "an excess of order $(dc+1)^{-2}$", which can be read as two-sided; the result cited there is a lower bound, so the item now says "a lower bound of order $(dc+1)^{-2}$ on the excess" (weakened).

**Second check of the revision** ([`../verification/A-revision-check-2.md`](../verification/A-revision-check-2.md)). One row per point raised by the second independent check, which read the text after the first check's points had been answered. I found all five valid, including the fifth, which the check marked as optional, and changed the text for each. None affects a theorem, lemma, proposition or corollary.

| point | issue | resolution | where |
|---|---|---|---|
| 1 | the preamble of Appendix R promised a bracketed note wherever the second round changed a passage described there, but R.1 S1 (its bullets on §0.1 and §0.2 item 4, and on §10) and R.3 item 12 had none, although the second round rewrote the sentence on the heuristic and corrected the list of finite-scale TUBE statements | fixed: notes added at those entries, and R.3 item 12 no longer calls revision 1's list exact. I then checked every entry of Appendix R against the current text; this added a note on the retitling of Proposition 7.4 to R.1 S3 and a note on §0.2 item 7 to its last bullet. The preamble now says what the notes mark: entries whose description a later edit made inaccurate. Many other passages named in Appendix R were edited again for other reasons, as Appendix R2 records, and carry no note | Appendix R: preamble; R.1 (S1, S3); R.3 item 12 |
| 2 | §1.4 omitted Remark 2.5 from the uses of $m$ as the number of sampled features, and put the path weights $\rho^\ell_j$ in step 3 of the proof of Lemma 8.1, which contains only the slope | fixed: Remark 2.5 added; the slope placed in step 3 and the path weights in step 4. A repeated search of the mathematics for the seven listed symbols, which now also finds a letter inside a product such as $mk_t$, found one more use, $m$ as the number of points in the paragraph after the proof of Lemma 8.1, now listed, and no other omission. The variants $\delta'$ and $\delta_d$ are now named by the results that define them ("of Proposition 5.2", "of Corollary 4.5"), because they recur where those results are applied or checked; and the lead sentence now says that the referee appendices, like the summaries in §0 and §10, use the meaning of the passage they discuss | §1.4, end |
| 3 | §5.4 cited B-tempered-likelihood.md Lemma 2.3(c) without its hypothesis $N\ge m$, and with the slack $1$ of B-tempered-likelihood.md although the near-minimizers of this note have slack $t$ | weakened: "at every learner width $N\ge m$", with the bound $c(E_*+t)/n$ for slack $t$ and a note that the theorems of B-tempered-likelihood.md use slack $1$; $\hat L_S$, which the paragraph used without a definition, is now defined as the training MSE | §5.4, "The heuristic", second paragraph |
| 4 | the last sentence of the consequence of Proposition 6.6, "Proposition 6.6a removes the strong-prior restriction", read as covering every prior, but Proposition 6.6a needs a prior with full support that is invariant under the readout flip | weakened: "for every prior with full support that is invariant under the readout flip, which includes both repository priors at every scale" | Prop 6.6, consequence |
| 5 (optional) | logic issue 6 and scope N7 asked that the referee reports on `red-team.md` Proposition 6.1 be cited; the text gave only the prescribed status | fixed: the two width reports are linked where the status of Proposition 6.1 is stated. For uniformity, the reports behind the other `red-team.md` statuses are linked too: Proposition 4.1 in Remark 6.6b, Remark 6.2 in §5.4 and §5 in §10 item 4. The statuses themselves are unchanged. Reports on the repairs, which this note cites only as in progress or under review, are not linked | §5.3 item 3; §5.4, third bullet; Remark 6.6b; §10 items 4–5; R2 table, rows logic 6 and scope N7 |

While making these changes I corrected two further points that the check did not raise.

* R.1 S3's last bullet said that §0.2 item 7 lists input laws with density ratio $2^{o(d^2)}$ and noisy labels as open. Since revision 1 that item has said only that the Lipschitz transfer of the proof does not reach those laws; §0.2 item 10 lists them as open. The bullet now says so (fixed).
* Convention (U2) falls back to the prior mean of $z_w$, which is the zero function for both repository priors but need not be for other priors. Yet Proposition 6.6(b) and the consequences of Propositions 6.6 and 6.6a use (U2) for every prior, or for every prior invariant under the readout flip, and §0.2 item 6, the remark after Lemma 6.2 and §10 item 6 repeat that scope. One sentence added to (U2) now says that for any other prior these statements assume that, for every $x$, the output $z_w(x)$ is integrable under that prior with mean $0$; for a prior invariant under the readout flip, integrability suffices (weakened).

**Third check of the revision** ([`../verification/A-revision-check-3.md`](../verification/A-revision-check-3.md)). The third independent check found every second-round issue and every point of the second check resolved, found no mathematical error in a changed passage, and reproduced every new number. It raised three minor points; the lead editor resolved them as follows. None affects a theorem, lemma, proposition or corollary.

| point | resolution | where |
|---|---|---|
| 1. The sentence added to (U2) restricted only "the statements below that use (U2)" to priors whose outputs have prior mean $0$, but §0.2 item 6 and the remark after Lemma 6.2 come before §6.2; read alone, §0.2 item 6 still said that Proposition 6.6 gives the failure for any prior when $\rho(n)\le1$ | weakened: (U2) now says "the statements of this note that use (U2), including the summaries in §0.2 item 6, in the remark after Lemma 6.2 and in §10 item 6", and §0.2 item 6 carries the proviso itself | §6.2, (U2); §0.2 item 6 |
| 2. Row 5 of the second-check table said that the two width reports are linked where the status of `red-team.md` Proposition 6.1 is stated, but §5.4 "The heuristic" states that status without them | fixed: the two reports are linked there too | §5.4, "The heuristic", second paragraph |
| 3. (optional) §9 item 6 used a symbol $G$ that the note never defines | fixed: the bullet now gives the reduction of the data term, $(\Delta_0-\Delta)/c=(160.33-2.98)/16\approx9.8$ at $c=16$, and defines $\Delta$ and $\Delta_0$ as in `spc_small_d.py` | §9 item 6, "Larger $c$" |

**Lead editor's notes at finalization.** After the third check, the lead editor made three edits. (i) The citations of `red-team.md` Proposition 6.1 in §5.3 item 3, §5.4 and §10 item 5 now cite [`small-learner-width.md`](small-learner-width.md), the refereed repair, in the wording that note suggests (its §7.4). (ii) §10 item 4 now cites [`depth-two.md`](depth-two.md), the refereed repair of `red-team.md` §5. (iii) The §5.4 bullet on `red-team.md` Remark 6.2 now gives the probability $1-2\delta$ of the corrected remark. Rows of the record above that describe these results as under review or in repair describe the text as it was when it was refereed and checked. Edits (i) and (ii) also removed the links to the two reports on `red-team.md` Proposition 6.1 (`RT-width-logic.md`, `RT-width-computation.md`) from §5.4, "The heuristic", and §10 item 5, and the links to the two reports on `red-team.md` §5 (`RT-depth2-logic.md`, `RT-depth2-computation.md`) from §10 item 4, which row 5 of the second-check table and row 2 of the third-check table describe; §5.3 item 3 still links the width reports, and [`small-learner-width.md`](small-learner-width.md) links the two width reports and [`depth-two.md`](depth-two.md) the two reports on `red-team.md` §5. After a final cross-reference check of all the research notes, the header now says that the lead editor edited the text after the third check. §10 item 4 now describes the refereeing of `depth-two.md` as its header does: two referee rounds, two re-refereeing rounds on intermediate texts, and an independent check, not a referee round, of the last changes. Remark 6.6b now summarizes `red-team.md` Proposition 4.1 as finalized, with its parts (a)–(c), the qualifier of its tightness example and both bounds in the comparison with Propositions 6.6 and 6.6a, and no longer refers to a statement that such conditioning "never memorizes", which the finalized note does not contain. §5.4 and §10 item 6 now name the scope report on E-finite-prior-scale.md along with its logic and computation reports. §0.1 and §0.2 item 10 now point to `depth-two.md` and `small-learner-width.md`, as §10 items 4–5 do. Appendix R2 ("Numbers and scripts") and row 5 of the first-check table now name the computation referee's output files with their folder, `../checks/verify-A-computation/`.
