# Which targets are hard for the subcritical learners?

Claude · 19 October 2026

**Work in progress.** This note asks whether the bad sample complexity of the $\gamma<1$ learners is specific to parity. Its propositions are short arguments built from lemmas of the [subcritical paper](../../main-results/subcritical-exponential/paper.pdf), standard learning-theory bounds, and an elementary Boolean-function fact. They were written after the 19 October collection review and were not part of it. They have had two rounds of independent AI-agent checks ([record](verification/review.md)), but they are not Lean verified and have not been reviewed by a human. Literature statements were checked against abstracts and search summaries, not full texts. The [technical FAQ](../../TECHNICAL-FAQ.md#is-the-bad-sample-complexity-specific-to-parity) gives the interpretation.

## Summary

- **Regression.** The NNGP posterior mean given exact real labels is kernel regression. Its expected squared error depends on the target only through the Fourier weight at each degree. Weight at degree $k$ stays essentially unlearned while $n$ is below about $d^{k^*}(d\log d)^{-\beta}$, where $k^*$ is $k$ rounded up to an odd integer. Squared error is therefore poor for every target with substantial high-degree weight. This includes leap-one targets, for which the merged-staircase property is nearly sufficient for SGD to learn from $O(d)$ samples (Section 1).
- **Sign posteriors.** For the $\gamma<1$ posteriors, our lower bounds are governed by the distance $\mathrm{err}_r(f)$ of the target from degree-$r$ polynomial threshold functions, not by its Fourier degree. Our upper bounds use exact sign representations with margin. Take a fixed junta with threshold degree $t\ge2$, and let $\kappa$ be $t$ rounded up to an odd integer.
  - The $\gamma<0$ learner needs between about $d^{\kappa}$ and $d^{\kappa+1}$ samples, with the lower bound holding for every training set.
  - For typical uniform iid samples, Gibbs error stays bounded below up to about $d^{\kappa-2\beta}$ samples at $\gamma=0$ and $d^{\kappa-\beta}$ at $0<\gamma<1$. About $d^{\kappa+1}/\varepsilon$ (up to a logarithm) and $d^{\kappa}/\varepsilon^2$ samples bring the error below $\varepsilon$, respectively. These Gibbs-error lower bounds never reach the $1/3$ needed for a confidence statement.
- **Halfspaces.** Halfspaces on a fixed set of coordinates have threshold degree one and need at most about $d^2$ samples. They include majority and AND of a fixed number of bits (Sections 2–4).
- **Leap.** Every Boolean function satisfies $\mathrm{Leap}(f)\le\mathrm{thr}(f)\le\deg f$, and $\mathrm{err}_r(f)\le W^{>r}(f)$. For fixed juntas, targets that are hard for SGD in the leap sense are therefore also hard for these learners (in Gibbs error for $\gamma\ge0$). The converse fails: $x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$ has leap one and threshold degree three (Section 5).
- **Exponential lower bounds.** Targets far from threshold functions of linear degree get exponential bounds directly, but most such functions are hard for every learner. Parity is close to threshold functions of degree $O(\sqrt d)$. So main result 4 needs, on our reading, two margin-sensitive lemmas, plus a sign-only bound for small samples. These appear to extend to targets that restrict to large parities, such as inner product mod 2 (Section 6).

## Setting and notation

Inputs are uniform on $X=\lbrace -1,1\rbrace ^d$ unless stated otherwise, and $f:X\to\lbrace -1,1\rbrace $ is the target. The three $\gamma<1$ limits of the subcritical paper use the kernel

$$
K(x,y)=\Psi^{\circ(L-1)}\left(\frac{1+x\cdot y}{d+1}\right),\qquad
\Psi(t)=\frac2\pi\arcsin t,\qquad \beta=2^{-(L-1)}.
$$

- **$\gamma<0$:** $G\sim N(0,K)$ conditioned on $f(X_i)G(X_i)>0$ at the training inputs. $q_S(x)$ is the conditional probability that $f(x)G(x)>0$, and $F_\theta(S)=\Pr_x\lbrace q_S(x)\le\theta\rbrace$.
- **$\gamma=0$:** the same law, additionally conditioned on $\lvert G(x)\rvert>a$ at every input.
- **$0<\gamma<1$:** the posterior concentrates on the signs of the minimizers of $\tfrac12\lVert z\rVert_K^2$ subject to $\lvert z(x)\rvert\ge a$ at every input and $f(X_i)z(X_i)\ge a$ at the training inputs. Ties may receive any weights.

All limits are width first, at fixed $d$, $L$, and training sample. The Gibbs error $R_S=\mathbb E_x[1-q_S(x)]$ is the error of a posterior draw.

**Spectrum.** $K$ is diagonal in the Walsh basis $\chi_U$. Let $\lambda_j$ be the normalized eigenvalue at degree $j$, so that $\sum_U\lambda_{\lvert U\rvert}=1$, and write $\lVert h\rVert_K^2=\sum_U\hat h(U)^2/\lambda_{\lvert U\rvert}$. The subcritical paper proves the following, in its lemmas on power coefficients and paired eigenvalues and on sharp level and tail estimates, and in its lower-spectrum corollary.

- **(K1)** $\lambda_{2i}=\lambda_{2i+1}$, and the eigenvalues strictly decrease from one pair to the next.
- **(K2)** $\binom{d+1}{j}\lambda_j\asymp j^{-1-\beta}$ for odd $j\le(d+1)/4$. In particular $\lambda_j\asymp d^{-j^*}$ for fixed $j$, where $j^*=2\lfloor j/2\rfloor+1$.
- **(K3)** The least eigenvalue $\nu_{\min}$ of the $2^d\times2^d$ kernel matrix satisfies $\nu_{\min}\ge c_L(d\log d)^{-\beta}$.
- **(K4)** For odd $r\le(d+1)/8$, $\lambda_{r+1}/\tau_r\asymp1/(r\binom{d+1}{r+2})$, where $\tau_r=\sum_{\lvert U\rvert>r}\lambda_{\lvert U\rvert}$.

Constants $c,C$ depend only on $L$ unless stated otherwise. The pairing comes from the odd activation and the bias coordinate: the kernel is an odd function of the inner product of $(1,x)$ and $(1,y)$. Thus $x_1x_2$ costs exactly as much as $x_1x_2x_3$, and the constant function as much as a single coordinate. For $L=2$, the exact values of $\lambda_j(d+1)^{j^*}$ at $d=40,80,160$ approach $2/\pi$, $2/\pi$, and $18/\pi$ for $j^*=1,3,5$. These are the coefficients of $t^{j^*}$ in $\frac2\pi\arcsin t$, times $j^*!$ ([check script](verification/check_beyond_parity.py), section 1).

**Boolean quantities.**

- $W^k(f)=\sum_{\lvert U\rvert=k}\hat f(U)^2$ is the Fourier weight at degree $k$, and $W^{\ge k}(f)=\sum_{j\ge k}W^j(f)$.
- $\mathrm{thr}(f)$, the **threshold degree**, is the least degree of a real polynomial $p$ with $f(x)p(x)>0$ on $X$; $\mathrm{thr}(f)=1$ exactly for nonconstant halfspaces.
- $\mathrm{err}_r(f)=\min_{\deg p\le r}\Pr_x[f(x)p(x)\le0]$, so $\mathrm{err}_r(f)=0$ exactly when $r\ge\mathrm{thr}(f)$.
- $\kappa(f)=\mathrm{thr}(f)^*$.
- $\mathrm{Leap}(f)$ ([Abbe, Boix-Adserà, and Misiakiewicz 2023](https://arxiv.org/abs/2302.11055)) is the least $\ell$ for which the nonempty sets in the Fourier support of $f$ can be ordered $S_1,\ldots,S_m$ with $\lvert S_i\setminus\bigcup_{j<i}S_j\rvert\le\ell$ for every $i$.

## 1. Regression

Let $P_Sf=K(\cdot,X)(K_{XX}+\sigma^2I)^{-1}f(X)$ be kernel ridge regression with ridge $\sigma^2\ge0$, on a training set $X$ of distinct inputs. It is the posterior mean of the Gaussian process given exact real labels, with observation variance $\sigma^2$.

**Proposition 1 (weight profile; proved).** Suppose the training set is drawn uniformly without replacement, or iid with repeated inputs removed. Then

$$
\mathbb E_S\lVert f-P_Sf\rVert_2^2=\sum_{k=0}^dW^k(f)\,m_k(n),
$$

where $m_k(n)$ is the expected error for a single degree-$k$ character. The same holds for every kernel that depends only on Hamming distance, provided $K_{XX}+\sigma^2I$ is invertible.

*Proof.* Let $A=\mathbb E_S[(I-P_S)^*(I-P_S)]$, with adjoints in $L^2$ of the uniform measure. Coordinate permutations and sign flips preserve the kernel and the law of $S$, and $P_{gS}(f\circ g^{-1})=(P_Sf)\circ g^{-1}$. Hence $A$ commutes with their action on functions. Distinct characters $\chi_U$ restrict to distinct characters of the sign-flip group, so commuting with sign flips makes $A$ diagonal in the Walsh basis. Commuting with permutations makes its diagonal entries depend only on $\lvert U\rvert$. ∎

The check script verifies the identity exactly at $d=5$, $n=4$, by averaging over all 35,960 training sets.

**Proposition 2 (lower bound; proved).** For every training set of $n$ distinct inputs and every $\sigma^2\ge0$,

$$
\lVert\chi_U-P_S\chi_U\rVert_2^2\ \ge\ 1-\frac{2n\lambda_{\lvert U\rvert}}{\nu_{\min}+\sigma^2}.
$$

Consequently, under the sampling of Proposition 1, for every $k$,

$$
\mathbb E_S\lVert f-P_Sf\rVert_2^2\ \ge\ W^{\ge k}(f)\left(1-\frac{2n\lambda_k}{\nu_{\min}+\sigma^2}\right).
$$

*Proof.* Put $\alpha=(K_{XX}+\sigma^2I)^{-1}\chi_U(X)$. Then $\lVert\chi_U-P_S\chi_U\rVert_2^2\ge1-2\langle\chi_U,P_S\chi_U\rangle$, and $\langle\chi_U,K(\cdot,X_i)\rangle=\lambda_{\lvert U\rvert}\chi_U(X_i)$. So

$$
\langle\chi_U,P_S\chi_U\rangle=\lambda_{\lvert U\rvert}\,\chi_U(X)^{\mathsf T}(K_{XX}+\sigma^2I)^{-1}\chi_U(X)\le\frac{n\lambda_{\lvert U\rvert}}{\nu_{\min}+\sigma^2},
$$

since $K_{XX}$ is a principal submatrix of the full kernel matrix. The second display follows from Proposition 1, since $m_j(n)\ge0$ for every $j$, and since $\lambda_j\le\lambda_k$ for $j\ge k$ by (K1). ∎

By (K2) and (K3), for fixed $k$ the high-degree weight $W^{\ge k}(f)$ remains essentially unlearned while $n=o\big(d^{k^*}(d\log d)^{-\beta}\big)$. This is the lower half of the standard picture in which kernel regression in the polynomial regime learns approximately the eigenspaces with eigenvalues much larger than $1/n$: [Ghorbani, Mei, Misiakiewicz, and Montanari 2021](https://arxiv.org/abs/1904.12191) on the sphere, [Mei, Misiakiewicz, and Montanari 2022](https://arxiv.org/abs/2101.10588), whose examples include the hypercube, and [Misiakiewicz 2022](https://arxiv.org/abs/2204.10425). We have not checked their hypotheses for this $d$-dependent kernel, and the matching upper half is not used below. For parities, [Hsu](https://arxiv.org/abs/2508.13346) gives a dimension lower bound of about $(1-\varepsilon)\binom dk$ samples for squared error $\varepsilon$, for every kernel method against the class of $k$-sparse parities. We saw this bound only through its abstract and a citing paper. [Simon, Dickens, Karkada, and DeWeese](https://arxiv.org/abs/2110.03922) give about $2^{d-1}(1-\sqrt\varepsilon)$ for full parity under every rotation-invariant kernel.

**Consequences.**

- **Weight matters, not degree.** AND of all $d$ bits has Fourier degree $d$, but all except $O(2^{-d})$ of its weight is at degree zero.
- **Majority.** For majority of all $d$ bits ($d$ odd), [O'Donnell, §5.3](https://www.contrib.andrew.cmu.edu/~ryanod/?p=877) gives $W^{>k}(\mathrm{MAJ})\sim(2/\pi)^{3/2}k^{-1/2}$ for odd $k$, in the limit of many inputs. So squared error $\varepsilon$ requires $n\gtrsim\binom{d+1}{c/\varepsilon^2}(d\log d)^{-\beta}$. This is $d^{\Omega(1/\varepsilon^2)}$ once $d\ge\varepsilon^{-2-\eta}$ for a fixed $\eta>0$. Yet $\mathrm{sign}\sum_ix_i$ is majority itself. At $d=12$ and $L=2$, regression on the majority of seven bits has squared error $0.120$ at $n=2400$, while its sign errs on $0.1\%$ of inputs (check script, section 5).
- **Leap one.** Let $g=x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$, meaning $x_1x_2x_3$ when $x_4=1$ and the majority of $x_1,x_2,x_3$ when $x_4=-1$. Then

  $$
  g=\tfrac14(x_1+x_2+x_3)+\tfrac14x_1x_2x_3-\tfrac14x_4(x_1+x_2+x_3)+\tfrac34x_1x_2x_3x_4 .
  $$

  It has leap one and $9/16$ of its weight at degree four. So kernel regression leaves squared error at least $9/16-o(1)$ while $n=o\big(d^5(d\log d)^{-\beta}\big)$. [Abbe, Boix-Adserà, and Misiakiewicz 2022](https://arxiv.org/abs/2202.08658) show that the merged-staircase (leap-one) property is necessary and nearly sufficient for SGD on two-layer mean-field networks to learn such sparse targets from $O(d)$ samples.
- **The sign of the regression mean** is not covered by Propositions 1 and 2. In the same $d=12$ runs, its error on $x_1x_2x_3$ is $0.002$ at $n=800$, against $0.199$ for $g$ ($0.041$ at $n=2400$).

## 2. Lower bounds for the sign posteriors

The small-sample part of the parity lower bounds of main result 4 combines three ingredients:

1. control of the posterior for every labeling of the sample. For $\gamma\ge0$ this is a cheap globally margined interpolant; for $\gamma<0$ it is the bound $\lVert m\rVert_K^2\le n$ on the Gaussian posterior mean;
2. spectral decay, which forces posterior-typical functions to lie near low-degree polynomial threshold functions;
3. distance of the target from those threshold functions.

The first two do not depend on the target. At exponential sample sizes, parity also enters the second ingredient, through the squared-balance lemma of Section 6. Replacing the third ingredient by $\mathrm{err}_r(f)$ gives the following.

**Proposition 3 ($\gamma<0$, every target, every training set; proved).** Fix $L\ge2$. There is $C_L$ such that the following holds for every $d$, every odd $r$ with $1\le r\le(d+1)/8$, every target $f$, and every training sample $S$ of size $n$. The sample may be iid, selected, or contain repeats.

$$
F_{13/20}(S)\ \ge\ \mathrm{err}_r(f)-\frac{C_L\,n}{r\binom{d+1}{r+2}}.
$$

For each fixed $\gamma<0$, the same lower bound holds for $\liminf_{N\to\infty}$ of the finite-width strict-$2/3$ confidence-failure fraction.

*Proof.* Let $m=\mathbb E[G\mid\text{signs}]$ and $\sigma_x^2=\mathrm{Var}(G(x)\mid G_S)$. The subcritical paper's lemma on the Gaussian mean and confidence holds for every sign pattern. It gives three facts:

- $q_S(x)>13/20$ and $\sigma_x>0$ imply $f(x)m(x)>c_\theta\sigma_x$, where $c_\theta=\sqrt{2\pi}(1/e-7/20)$;
- $\Pr_x\lbrace\sigma_x^2<\tau_r/2\rbrace\le2n\lambda_{r+1}/\tau_r$;
- $\lVert m-\Pi_{\le r}m\rVert_2^2\le n\lambda_{r+1}$.

By Markov's inequality for the square, $\Pr_x\lbrace\lvert m-\Pi_{\le r}m\rvert\ge c_\theta\sqrt{\tau_r/2}\rbrace\le2n\lambda_{r+1}/(c_\theta^2\tau_r)$. Outside these two sets, confidence above $13/20$ forces $f\,\Pi_{\le r}m>0$. Since $\Pi_{\le r}m$ has degree at most $r$, we get $F_{13/20}(S)\ge\mathrm{err}_r(f)-(2+2/c_\theta^2)\,n\lambda_{r+1}/\tau_r$. Now apply (K4). The paper's conditional width limit and $13/20<2/3$ give the finite-width statement. ∎

This is the paper's own small-sample argument, from the last part of the proof of its $\gamma<0$ theorem, with its parity threshold-function lemma replaced by $\mathrm{err}_r(f)$.

**Proposition 4 ($0<\gamma<1$, Gibbs error; proved).** Fix $L\ge2$ and $a>0$. Let $d$ be sufficiently large, and draw $n\le e^{d/25}$ iid uniform inputs. With probability at least $1-e^{-cd}$, the following holds simultaneously for every target $f$ and every odd $r$ with $r+2\le(d+1)/4$: every minimizer $z$ satisfies

$$
\Pr_x[\mathrm{sign}\,z(x)\ne f(x)]\ \ge\ \mathrm{err}_r(f)-C_L\,\lambda_{r+1}\,(d+nd^{\beta}),
\qquad
\lambda_{r+1}=\lambda_{r+2}\asymp\frac{(r+2)^{-1-\beta}}{\binom{d+1}{r+2}}.
$$

*Proof.* On this sample event, the paper's strict-margin comparator gives, for every labeling, a feasible $h$ with $\lVert h\rVert_K^2\le C_La^2(d+nd^\beta)$. Every minimizer $z$ therefore satisfies the same bound. Write $z=z_{\le r}+z_{>r}$. Then $\lVert z_{>r}\rVert_2^2\le\lambda_{r+1}\lVert z\rVert_K^2$. Since $\lvert z\rvert\ge a$ everywhere, the event $\lbrace fz_{\le r}\le0\rbrace$ is contained in $\lbrace fz<0\rbrace\cup\lbrace\lvert z_{>r}\rvert\ge a\rbrace$. Markov's inequality for $z_{>r}^2$ completes the proof. ∎

**Proposition 4′ ($\gamma=0$, Gibbs error; proved).** Fix $L\ge2$ and $a>0$. Let $d$ be sufficiently large, and draw $1\le n\le e^{d/25}$ iid uniform inputs. With probability at least $1-e^{-cd}$, the following holds simultaneously for every target $f$ and every odd $r$ with $1\le r\le(d+1)/8$:

$$
R_S\ \ge\ \mathrm{err}_r(f)-\frac{C_{L,a}}{d}-C_{L,a}\,\frac{\tau_r+\lambda_{r+1}(d^2+nd^{1+\beta})}{d^{1-\beta}}.
$$

*Proof.* Let $A_S$ be the conditioning event for the labels $f(X_i)$. The rough bound `eq:zero-rough-cost` of the paper's conditioning-cost lemma does not depend on $r$. It gives, on this sample event and for every labeling at once, $\mathcal D(S)=-\log\Pr(A_S)\le C(d^2+nd^{1+\beta})$, which is at most $e^{.045d}$ for large $d$. Write $\mathbb E^*$ for the posterior expectation. The paper's quadratic-entropy lemma `lem:zero-quadratic` applies to $2^{-d/2}G_{>r}$ under the posterior, whose relative entropy from the prior is exactly $\mathcal D(S)$. It gives $\mathbb E^*\lVert G_{>r}\rVert_2^2\le2\tau_r+4\lambda_{r+1}\mathcal D$; the paper's display `eq:zero-tail-population` is the parity instance. Its posterior-amplitude lemma gives $\mathbb E^*\Pr_x\lbrace\lvert G(x)\rvert\le b_d\rbrace\le C/d$ with $b_d=b\,d^{(1-\beta)/2}$.

Now fix a posterior draw. Where $fG>0$ but $fG_{\le r}\le0$, we have $\lvert G_{>r}\rvert\ge fG=\lvert G\rvert$. Hence

$$
\lbrace fG_{\le r}\le0\rbrace\subseteq\lbrace fG<0\rbrace\cup\lbrace\lvert G\rvert\le b_d\rbrace\cup\lbrace\lvert G_{>r}\rvert\ge b_d\rbrace .
$$

Since $G_{\le r}$ has degree at most $r$, the left side has probability at least $\mathrm{err}_r(f)$. Take probabilities, apply Markov's inequality for $G_{>r}^2$ to the last set, and average over the posterior. ∎

The amplitude lemma is what makes a fixed cutoff possible here. The paper's own small-sample argument at $\gamma=0$ instead takes $r\asymp d^{1/3}$, so that $\tau_r=o(1)$. The constants inherited from the amplitude lemma are large, so the bound is asymptotic and says nothing at the dimensions of Section 7. This proposition was suggested by the independent check recorded in [verification/review.md](verification/review.md).

Propositions 4 and 4′ bound Gibbs error. By the mixture inequality $F\ge(3R-1)/2$ ([FAQ Questions 5 and 6](../../TECHNICAL-FAQ.md#5-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)), they give a confidence lower bound only when the right side exceeds $1/3$. That requires $\mathrm{err}_r(f)>1/3$.

## 3. Upper bounds

**Proposition 5 (proved; standard arguments).** Let $p$ be a real polynomial with $f(x)p(x)\ge1$ on $X$, and put $t_0^2=2\ln(2^{d+2})$. Let $n\ge8$ training inputs be iid from any law $\mathcal D$ on $X$, and measure error under $\mathcal D$. With probability at least $1-\delta$:

- for $\gamma<0$, the limiting Gibbs error satisfies $R_S\le\frac1n\left[(d+2)\ln2\,\lVert p\rVert_K^2+\ln2+\ln(2\sqrt n/\delta)\right]$;
- for $\gamma=0$, the same holds with $\tfrac12(a+t_0)^2$ in place of $(d+2)\ln2=\tfrac12t_0^2$;
- for $0<\gamma<1$, every minimizer has error at most $2\lVert p\rVert_K/\sqrt n+\sqrt{\ln(1/\delta)/(2n)}$.

For $\gamma\le0$, the limiting confidence-failure fraction is at most $3R_S$, and so is the $\limsup$ of the finite-width strict-$2/3$ fraction. For $0<\gamma<1$, tied minimizers may carry weights that do not converge. Markov's inequality at each width, together with the paper's rate proposition, gives $\limsup_NF_N\le3\max_z\Pr_x[\mathrm{sign}\,z\ne f]$ over the minimizers $z$. Also $\lVert p\rVert_K^2\le\lVert p\rVert_2^2/\lambda_{\deg p}$ by (K1).

*Proof.* For $\gamma\le0$, the limiting posterior is the prior conditioned on the version space $V_S$. The PAC-Bayes bound in [Maurer's form](https://arxiv.org/abs/cs/0411099), $\mathrm{kl}(\hat R\Vert R)\le[\mathrm{KL}(Q\Vert\Pi)+\ln(2\sqrt n/\delta)]/n$ for $n\ge8$, has $\hat R=0$ and $\mathrm{KL}=\ln(1/\Pi(V_S))$ here. Since $\mathrm{kl}(0\Vert R)\ge R$, it gives $R_S\le[\ln(1/\Pi(V_S))+\ln(2\sqrt n/\delta)]/n$.

- For $\gamma<0$: $\Pi(V_S)\ge\Pr\lbrace\mathrm{sign}\,G=f\rbrace\ge\Pr\lbrace G\in t_0p+B\rbrace$, where $B=\lbrace\max_x\lvert G(x)\rvert<t_0\rbrace$. A union bound over the $2^d$ inputs, with $K(x,x)=1$, gives $\Pr(B)\ge1/2$. The Gaussian shift inequality $\Pr(G\in h+B)\ge e^{-\lVert h\rVert_K^2/2}\Pr(G\in B)$ for symmetric convex $B$ then applies; the paper uses it in its adaptive conditioning-cost lemma.
- For $\gamma=0$: $\Pi(V_S)\ge\Pr\lbrace f(x)G(x)>a\ \forall x\rbrace$, and the shift $h=(a+t_0)p$ works the same way.
- For $0<\gamma<1$: the comparator $ap$ is feasible. So every minimizer lies in the $K$-ball of radius $a\lVert p\rVert_K$ and has training margin $a$. That ball has Rademacher complexity at most $a\lVert p\rVert_K/\sqrt n$, because $K(x,x)=1$. The standard margin bound gives the claim.

For $\gamma\le0$, the limits use Markov's inequality, $F\le3R$, and the fact that $q_S(x)>2/3$ in the limit implies $q_N(x)>2/3$ at large width. ∎

## 4. Fixed juntas

**Corollary 6 (proved, from Propositions 3–5).** Let $f$ depend on a fixed set of $P$ coordinates as $d$ grows, let $t=\mathrm{thr}(f)$ and $\kappa=t^*$. The constants $c_f,C_f$ depend on $f$ and $L$, and at $\gamma\ge0$ also on $a$. The statements hold for $d\ge d_f$; the case $n=0$ is trivial, since the posterior is then symmetric under $G\mapsto-G$ and every Gibbs error equals $1/2$.

1. Let $t\ge2$. Then $\mathrm{err}_{\kappa-2}(f)\ge2^{-P}$, and:
   - for $\gamma<0$, every training sample with $n\le c_fd^{\kappa}$ has $F_{13/20}(S)\ge\mathrm{err}_{\kappa-2}(f)/2$. Conversely, $n\ge C_f(d^{\kappa+1}+\ln(1/(\varepsilon\delta)))/\varepsilon$ iid samples give limiting confidence failure at most $\varepsilon$ with probability $1-\delta$;
   - for $\gamma=0$, with probability $1-e^{-cd}$ over uniform iid samples, the Gibbs error is at least $\mathrm{err}_{\kappa-2}(f)/2$ when $n\le c_fd^{\kappa-2\beta}$. The same upper bound as for $\gamma<0$ holds;
   - for $0<\gamma<1$, with probability $1-e^{-cd}$ over uniform iid samples, every minimizer has error at least $\mathrm{err}_{\kappa-2}(f)/2$ when $n\le c_fd^{\kappa-\beta}$. Conversely, $n\ge C_f(d^{\kappa}+\ln(1/\delta))/\varepsilon^2$ samples make every minimizer's error at most $\varepsilon$ with probability $1-\delta$.
2. Let $t=1$, so that $f$ is a halfspace on its $P$ coordinates. Examples are majority and AND of $P$ bits. Then $C_f(d^2+\ln(1/(\varepsilon\delta)))/\varepsilon$ samples suffice for $\gamma\le0$, and $C_f(d+\ln(1/\delta))/\varepsilon^2$ for $0<\gamma<1$. Majority of all $d$ bits ($d$ odd) is not a fixed junta: the sign representation $\sum_ix_i$ has $\lVert p\rVert_K^2\asymp d^2$, giving about $d^3/\varepsilon$ samples for $\gamma\le0$.

*Proof.* In part 1, fix the coordinates outside the junta. A polynomial of degree at most $\kappa-2<t$ restricts to a polynomial of degree at most $\kappa-2$ in the junta coordinates. This restriction cannot sign-represent $f$, so it errs on at least one of the $2^P$ junta cells. Apply Proposition 3 with $r=\kappa-2$ and $\binom{d+1}{\kappa}\asymp d^\kappa$, and Propositions 4 and 4′ with $\lambda_{\kappa-1}=\lambda_\kappa\asymp d^{-\kappa}$ and $\tau_{\kappa-2}\le1$. In Proposition 4′ the terms not involving $n$ are $O(d^{-(1-\beta)}+d^{1+\beta-\kappa})=o(1)$, since $\kappa\ge3$. For the upper bounds, scale a degree-$t$ sign representation in the junta coordinates so that $fp\ge1$. Then $\lVert p\rVert_K^2\le\lVert p\rVert_2^2/\lambda_t\le C_fd^{\kappa}$, and Proposition 5 applies. Part 2 is the same with $\lambda_1\asymp1/d$. ∎

For threshold degree at most one, the available lower bounds are weaker. For $\gamma<0$ every target needs $n\gtrsim d$, by [the sparse-parity paper's](../../side-results/sparse-parity/paper.pdf) universal bound $F_\theta(S)\ge1-(2+1/(\pi(\theta-1/2)^2))\,n/(d+1)$. For $0<\gamma<1$, a dictator is learned from $O(\log d)$ samples, by the sparse-parity paper's `thm:dictator-fast`.

**Examples.** All values below are exact, from linear programming in the [check script](verification/check_beyond_parity.py), section 3.

| target | Fourier degree | leap | threshold degree | $\kappa$ | $\mathrm{err}_{\kappa-2}$ |
|---|---|---|---|---|---|
| $\mathrm{MAJ}_5$; $\mathrm{AND}_4$; $\mathrm{sign}(4x_1+3x_2+2x_3+x_4+x_5)$ | 5; 4; 5 | 1 | 1 | 1 | – |
| $x_1x_2$ | 2 | 2 | 2 | 3 | 1/4 |
| $x_1\,?\,x_2:x_3$ | 2 | 1 | 2 | 3 | 1/8 |
| $\mathrm{AND}(x_1,x_2)\oplus\mathrm{AND}(x_3,x_4)$ | 4 | 1 | 2 | 3 | 1/8 |
| $x_1x_2x_3$ | 3 | 3 | 3 | 3 | 1/4 |
| $x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$ | 4 | 1 | 3 | 3 | 3/16 |
| $x_1x_2x_3x_4$ | 4 | 4 | 4 | 5 | 1/16 |
| $x_5\,?\,x_1x_2x_3x_4:\mathrm{sign}(2x_1+x_2+x_3+x_4)$ | 5 | 1 | 4 | 5 | 1/32 |

Since $\mathrm{err}_r(f)\le1/2$, the $\gamma\ge0$ bounds of part 1 never exceed $1/4$. So they are Gibbs-error statements only and give no confidence-failure bound. For $\gamma<0$, two-bit XOR has confidence failure at least $1/4-o(1)$ on every training sample with $n=o(d^3)$. The leap-one target $x_4\,?\,x_1x_2x_3:\mathrm{MAJ}$ has failure at least $3/16-o(1)$ in the same range. For fixed $k$, Proposition 3 gives $k$-sparse parity failure fraction $\mathrm{err}_{k^*-2}(\chi_k)$ at the natural scale $n=o(d^{k^*})$. That fraction decays with $k$. The sparse-parity paper instead proves a small universal fraction that also covers growing $k$.

Instead, fix $c\le1/2$, let $k\ge k_0(c,L)$ and $d\ge64$, and let $r$ be the largest odd integer at most $c\sqrt k$. The bound of Aspnes, Beigel, Furst, and Rudich (the subcritical paper's `lem:ptf-parity`, applied on the $k$ relevant coordinates) gives $\mathrm{err}_r(\chi_k)\ge2^{-k}\sum_{j\le(k-r-1)/2}\binom kj$, which is about $\Phi(-c)$ for large $k$. So at $\gamma<0$, Proposition 3 gives the following. Every training set with $n\le c'r\binom{d+1}{r+2}$, where $c'=\mathrm{err}_r(\chi_k)/(2C_L)$, keeps $F_{13/20}(S)$ and the finite-width $\liminf$ at least $\mathrm{err}_r(\chi_k)/2$. For $k\ge k_0$ this range includes every $n\le(d/\sqrt k)^{c\sqrt k}$. The bound holds for deliberately selected training sets too.

Compare the $0<\gamma<1$ [selected-examples paper](../../side-results/selected-examples-parity/paper.pdf). There, for sufficiently large odd $k$ and $d\ge(C_Lk)^{C_Lk}$, selected sets of size $d^{O_\delta(\sqrt k)}$ make every minimizer's error at most $\delta$. The two exponents are of the same order $\sqrt k$. Whether selected sets of that size suffice at $\gamma<0$, rather than the iid natural scale, is open.

## 5. Leap and threshold degree

**Proposition 7 (proved; elementary).** Every $f:X\to\lbrace -1,1\rbrace $ satisfies $\mathrm{Leap}(f)\le\mathrm{thr}(f)\le\deg f$.

*Proof.* The second inequality holds because $f\cdot f=1>0$. For the first, let $\ell=\mathrm{thr}(f)$, and let $q$ have degree at most $\ell$ with $fq>0$. Starting from $T=\varnothing$, repeatedly add to $T$ any support set $S$ with $\lvert S\setminus T\rvert\le\ell$ until none remains. If every support set ends up in $T$, these additions order the support with leap at most $\ell$.

Suppose instead that some support set is left. Every support set not contained in $T$ then has more than $\ell$ elements outside $T$. Fix $a\in\lbrace -1,1\rbrace ^T$, and let $g(y)=f(a,y)$ and $q_a(y)=q(a,y)$. The Fourier coefficient of $g$ at $V\subseteq T^c$ is $\sum_{S\setminus T=V}\hat f(S)\chi_{S\cap T}(a)$. It vanishes unless $V=\varnothing$ or $\lvert V\rvert>\ell$, while $q_a$ has degree at most $\ell$. Since $g=\mathrm{sign}\,q_a$,

$$
\mathbb E\lvert q_a\rvert=\mathbb E[g\,q_a]=\hat g(\varnothing)\,\hat q_a(\varnothing)\le\lvert\hat g(\varnothing)\rvert\,\mathbb E\lvert q_a\rvert .
$$

So $\lvert\hat g(\varnothing)\rvert\ge1$ and $g$ is constant. Then $f$ depends only on $x_T$, and every support set lies in $T$, a contradiction. ∎

A companion inequality links threshold functions to Fourier weight: $\mathrm{err}_r(f)\le W^{>r}(f)$ for every $r$. Indeed, $\mathrm{sign}(f_{\le r})$ can differ from $f$ only where $\lvert f-f_{\le r}\rvert\ge1$. With Proposition 2, a target that keeps $\mathrm{err}_r(f)\ge c$, for fixed odd $r$, therefore also keeps squared regression error at least $c-o(1)$ while $n=o(d^{r+2}(d\log d)^{-\beta})$.

The check script confirms Proposition 7 on all $2^{16}$ Boolean functions of four bits. In the same census, 62,144 functions depend on all four bits and have leap one. Of these, 1,536 have threshold degree one, 53,856 have threshold degree two, and 6,752 have threshold degree three.

**Comparison of exponents for a fixed junta** (powers of $d$; constants depend on the junta):

| learner | exponent | status |
|---|---|---|
| online SGD, two-layer network | $\max(\mathrm{Leap}-1,1)$ | conjectured ([Abbe, Boix-Adserà, and Misiakiewicz 2023](https://arxiv.org/abs/2302.11055), stated as time $d^{\max(\mathrm{Leap},2)}$); proved for a class of Gaussian-data problems. For leap one, the 2022 paper shows the merged-staircase property necessary and nearly sufficient in the mean-field setting |
| $\gamma<0$ sign posterior | between $\kappa$ and $\kappa+1$ if $\mathrm{thr}\ge2$; at most $2$ if $\mathrm{thr}\le1$ | Corollary 6 |
| $\gamma=0$ and $0<\gamma<1$, Gibbs error | at least $\kappa-2\beta$ and $\kappa-\beta$ if $\mathrm{thr}\ge2$; at most $\kappa+1$ and $\kappa$ | Corollary 6 |
| kernel-regression squared error below the top-degree weight | at least $(\deg f)^*$, up to $(d\log d)^\beta$ | Proposition 2 |

Since $\kappa\ge\mathrm{thr}\ge\mathrm{Leap}$, whenever $\mathrm{thr}(f)\ge2$ the $\gamma<0$ posterior needs at least about $d$ times as many samples as the conjectured online-SGD rate. Leap-one juntas of threshold degree at least two give gaps of $d^2$ or more, and the four-bit census suggests they are the typical case among juntas. For $k$-sparse parity, the three exponents differ only by a constant. [Barak, Edelman, Goel, Kakade, Malach, and Zhang 2022](https://arxiv.org/abs/2207.08799) find SGD taking $d^{O(k)}$ iterations, near the statistical-query limit. Reusing batches can beat the correlational exponents, at least for Gaussian data ([Dandi et al. 2024](https://arxiv.org/abs/2402.03220); [Lee, Oko, Suzuki, and Wu 2024](https://arxiv.org/abs/2406.01581)). [Glasgow 2024](https://arxiv.org/abs/2309.15111) shows that minibatch SGD on a standard two-layer network learns two-bit XOR on the hypercube from $d\,\mathrm{polylog}\,d$ samples. The SGD statements concern exponents for fixed juntas and are taken from abstracts. No theorem here relates SGD to these posteriors.

## 6. Superpolynomial and exponential sample sizes

**Growing degree.** Suppose $\mathrm{err}_r(f)\ge c$ for some odd $r=r(d)\to\infty$ with $r\le(d+1)/8$. Then Proposition 3 shows that the $\gamma<0$ learner keeps confidence failure at least $c/2$ on every training set unless $n\gtrsim r\binom{d+1}{r+2}$, which is superpolynomial in $d$. Propositions 4 and 4′ give the corresponding Gibbs-error statements for typical samples at $0<\gamma<1$ and $\gamma=0$, with an extra polynomial factor, but only for $n\le e^{d/25}$. At linear $r$ all of these are exponential. Most Boolean functions qualify by a counting argument, but they need about $2^d$ samples for every learner, so they say nothing specific about these learners.

**Parity needs more.** Parity is close to low-degree threshold functions. Under uniform inputs, a univariate polynomial in $\sum_ix_i$ of degree $O(\sqrt{d\log(1/\varepsilon)})$ alternates in sign on the central range and has the sign of parity outside probability $\varepsilon$. So the route above gives only $\exp(\Theta(\sqrt d\log d))$ for parity, which is the scale of the [earlier superpolynomial paper](../../side-results/subcritical-sample-complexity/paper.pdf). Main result 4 reaches $\exp(\Omega(d))$ through two margin-sensitive lemmas. It also uses a sign-only bound for small samples. On our reading, these three lemmas, together with `lem:small-cutoff`, which uses parity only through the first of them, are the only places its proof uses parity:

- `lem:ptf-parity`, the bound of Aspnes, Beigel, Furst, and Rudich, used only for $n\le\exp((\log d)^3)$;
- `lem:parity-squared-balance`, $\mathbb E(fP)_-^2\ge(1/2-\sqrt{r/d})\lVert P\rVert_2^2$ for $\deg P\le r$, used for $r$ up to a small multiple of $d$;
- `lem:clipped-parity`, $\lvert\mathbb E f\,\mathrm{clip}(P/b)\rvert\le\lVert\Delta P\rVert_1/(bd)$, through the discrete Laplacian $\Delta$.

The two margin-sensitive lemmas use that parity changes sign along every edge of the cube. The ABFR lemma uses that parity is orthogonal to every polynomial of degree below $d$.

**Extension suggested by the proof.** The three lemmas appear to transfer, one restriction at a time, to restriction parities. These are targets for which some set $A$ of coordinates has the following property: after $x_A$ is fixed uniformly at random, the restriction equals $\pm$ a parity of at least $cd$ remaining coordinates, except with probability $e^{-cd}$. Examples:

- inner product mod 2, $\prod_{i\le d/2}\mathrm{AND}(x_i,y_i)$ in $\pm1$ notation: fixing $x$ leaves the parity of the $y_i$ with $x_i=-1$;
- parity times an arbitrary function of a small fraction of the coordinates;
- XORs of $\Omega(d)$ copies of a fixed nonconstant gadget on disjoint blocks.

The squared-balance lemma additionally needs a hypercontractive bound on the exceptional restrictions. This has not been written out. Targets such as $\mathrm{MAJ}_3\circ\mathrm{XOR}_{d/3}$, whose restrictions fail to be large parities with constant probability, are not covered.

**Worst-case measures do not transfer.** Exact threshold degree is a worst-case notion. The Minsky–Papert AND of ORs has threshold degree $\Theta(d^{1/3})$, and some AC⁰ functions have threshold degree $\Omega(d^{1-\epsilon})$ (Sherstov and Wu, STOC 2019). Yet such functions can be nearly constant under uniform inputs. ODD-MAX-BIT has threshold degree one with exponentially small degree-one margin. Under uniform inputs, however, it is $2^{-m}$-close to a function of its last $m$ bits. Our lower bounds respond to $\mathrm{err}_r(f)$ under the input distribution, not to worst-case threshold degree. Our upper bounds need exact sign representations with margin on every input. So neither settles such targets.

**Deep families fail for every target.** At depth growing linearly in $d$, the deep tanh NNGP family ([NNGP note](../../side-results/nngp-sample-complexity/paper.pdf), `thm:tanh`) and the deep $\gamma\le0$ family ([near-independent confidence](../../side-results/gamma-below-one/paper.pdf), `thm:deep-confidence`) learn nothing beyond the observed inputs, for every target. Those exponential bounds are not about parity at all.

## 7. Numerical illustrations

Sign-GP learner ($\gamma<0$), $d=12$, $L=2$, exact Hamiltonian Monte Carlo for the orthant-truncated Gaussian. The table gives the strict confidence-failure fraction $F_{2/3}=\Pr_x\lbrace q_S(x)\le2/3\rbrace$ by number of iid samples $n$. Each entry is the mean over 5 seeds, or 3 seeds at the two largest sizes, with training inputs shared across targets. Observed inputs count as successes.

| target | 100 | 200 | 400 | 800 | 1600 | 2400 |
|---|---|---|---|---|---|---|
| $\mathrm{MAJ}(x_1,\ldots,x_7)$ | .18 | .03 | .00 | .00 | .00 | .00 |
| $x_1x_2x_3$ | .80 | .75 | .63 | .33 | .04 | .00 |
| $x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$ | .60 | .55 | .52 | .44 | .32 | .23 |
| full parity | .81 | .84 | .81 | .76 | .64 | .54 |

On unseen inputs alone, the leap-one target's failure at $n=2400$ is $0.41$, and full parity's is $0.97$. For each run of the leap-one target, the two chains agree to within $0.005$ in $F$; over all runs the largest difference is $0.009$.

A plausible but heuristic explanation for the leap-one target's slower learning at equal $\kappa$ is its larger kernel norm. The sign representation $p=x_1x_2x_3+(1-x_4)(x_1+x_2+x_3)$ has $\lVert p\rVert_K^2=1/\lambda_3+3/\lambda_1+3/\lambda_2\approx4/\lambda_3$, four times the squared norm of $x_1x_2x_3$. It is the least squared norm among margin-one sign representations of degree at most three. Allowing degree four lowers the minimum to about $2.4/\lambda_3$ at $d=12$; the minimum approaches $4/\lambda_3$ as $d$ grows. At $d=12$, $\binom{13}{3}=286$, so these runs cannot resolve the asymptotic windows of Corollary 6.

## Files

- [`verification/check_beyond_parity.py`](verification/check_beyond_parity.py) and [its output](verification/check_beyond_parity.out): the spectrum (K1)–(K2) at small and moderate $d$, the exact check of Proposition 1, the example table, the four-bit census, and the regression numbers.
- [`verification/sign-gp/`](verification/sign-gp/README.md): the sign-GP sampler, its validation, the run driver, and aggregated results.
- [`verification/review.md`](verification/review.md): the independent check of the propositions.
