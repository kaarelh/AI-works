# Referee report: red-team Remark 6.2 (conditioning on aggregate training error)

*Lens: logic and definitions.* Claim under review: `../research-notes/red-team.md`, §6.3, Remark 6.2, together with its entries in the verdict list (§0 item 7) and in the list of surviving versions (§6.3 item 4). Scripts and outputs are in `../checks/verify-RT-aggregate-logic/`. `NNG/` denotes the project folder `neural-network-generalization/` of this repository.

## Verdict: minor fixes

The displayed bound is **correct**. It holds in the strong-prior limit of the prior conditioned on $\{\hat L(z_w)<\tau\}$ whenever the competitor's empirical MSE is below $\tau$, and it holds for every learner width $N\ge m$.

- **The concentration step is justified.** The conditioning event is open in parameter space, because it is a strict sublevel set of a function that is continuous in $w$ at a fixed sample. It contains the competitor's exact clone. So the Laplace comparison in the proof of `paper.tex` Cor. `exact` applies word for word.
- **The generalization step is justified.** It is the uniform-deviation bound over the width-free class $\mathcal Z_{E_*+1}$. That bound is identical to `../research-notes/B-tempered-likelihood.md` Lemma 5.3(a), which has already been refereed. I also re-checked its engine, red-team Lemma 3.1 (`noisy-interpolation/README.md` eqs. (12)–(15)), step by step.
- **The required $n$ is polynomial** in $d,m,B,1/\varepsilon,\log(1/\delta)$ at fixed depth.

No step is wrong. The defects are of four kinds:

1. **Hypotheses left unstated.** The remark needs:
   - learner width $N\ge m$;
   - a Gaussian prior;
   - a competitor with the learner's depth and the repository architecture;
   - labels in $[-1,1]$.
2. **Missing quantifiers.** The remark does not say "with probability at least $1-\delta$" or "for every $N$", and it does not say which posterior functional is bounded.
3. **A limit-order subtlety.** The scale threshold depends on the sample. This differs from Lemma 1.1, so the report's §1 remark that "with probability $\ge 1-\delta$" and "for all $\sigma<\sigma_0$" can be interchanged does not carry over.
4. **Imprecise interpretation.**
   - "$\tau\approx\mathrm{OPT}$" must mean $\tau\ge\mathrm{OPT}+\Theta(n^{-1/2})$. At $\tau=\mathrm{OPT}$ the hypothesis fails with probability about $1/2$.
   - The learner needs this oracle number. So the claim "survives (proved here)" in §0 and §6.3 must carry the caveat. The remark's own text does carry it.
   - The oracle can be removed by setting $\tau$ from the data; see §6(c) below. I checked this; the remark does not claim it.

---

## 1. The claim as written

> **Remark 6.2.** Let $\Pi^\tau_\sigma\propto\mu_\sigma\mathbf 1\{\hat L(z_w)<\tau\}$. If $\hat L(g)<\tau$, then the strong-prior limit concentrates on $\{\kappa_N\le E_*+\zeta\}$, by the argument of the proof of Cor. `exact`. Lemma 3.1 then gives
> $$L_D(\operatorname{clip}z_w)\le\tau+8\mathcal D\bigl((E_*+1)/H\bigr)^{H/2}n^{-1/2}+4\sqrt{\ln(2/\delta)/(2n)}.$$
> So conditioning on "fit as well as the best small network does in mean square" works, whereas conditioning on each output does not. The catch is that $\tau\approx\mathrm{OPT}$ must be supplied. A hyperprior over $\tau$ is not analysed here.

The remark inherits $g,m,B,U=mB$ and $E_*=d(d+1)B^2+2(L-1)m^2B^2$ from Theorem 3.2, and $\mathcal D$ from Lemma 3.1.

## 2. The claim with every quantifier written out (what I verified)

Fix the following:

- depth $L=H+1\ge2$ and a compact $X\subseteq[-1,1]^d$;
- a law $D$ on $X\times[-1,1]$;
- a competitor $g$ of depth $L$ and width $m$ in the repository architecture: $\bar x=(1,x)$, tanh hidden layers, no internal biases, linear readout, and every weight in $[-B,B]$;
- $K:=E_*+1$, a level $\tau>0$, a confidence $\delta\in(0,1)$ and a sample size $n$.

For width $N$, let $\mu_\sigma$ be the strong-prior Gaussian prior, with density proportional to $e^{-\kappa_N/(2\sigma^2)}$. Put $O_\tau(S)=\{w:\hat L_S(z_w)<\tau\}$ and $\Pi^\tau_{\sigma,N,S}=\mu_\sigma(\cdot\mid O_\tau(S))$.

**(R)** There is a sample event $G_\delta$ with $\Pr(G_\delta)\ge1-\delta$. It depends only on $(D,n,\delta,K)$, not on $N$, $\sigma$, $\tau$ or the identity of $g$. On $G_\delta\cap\{\hat L_S(g)<\tau\}$, for **every** $N\ge m$, the following hold.

- **(R1)** For every $\zeta>0$, $\Pi^\tau_{\sigma,N,S}\{\kappa_N>E_*+\zeta\}\to0$ as $\sigma\downarrow0$.
- **(R2)** Every $w$ with $\kappa_N(w)\le K$ and $\hat L_S(z_w)\le\tau$ satisfies
$$L_D(\operatorname{clip}z_w)\le\tau+\mathsf R,\qquad \mathsf R:=8\mathcal D_n\Bigl(\tfrac KH\Bigr)^{H/2}n^{-1/2}+4\sqrt{\tfrac{\ln(1/\delta)}{2n}} .$$
- **(R3)** Hence:
  - every weak limit point of $\Pi^\tau_{\sigma,N,S}$ as $\sigma\downarrow0$ is carried by a set on which (R2) holds;
  - $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk is at most $\tau+\mathsf R$;
  - $\limsup_{\sigma\downarrow0}L_D(\mathbb E_\Pi\operatorname{clip}z_w)$ is at most $\tau+\mathsf R$.

Here $\mathcal D_n$ must be a bound that does not depend on the sample (issue 6). The remark's $4\sqrt{\ln(2/\delta)/(2n)}$ is larger than the term needed here, so its display is implied.

---

## 3. Step-by-step check

### 3.1 The conditioning event

- *Open.* At a fixed sample, $w\mapsto z_w(x_i)$ is a composition of linear maps and tanh, so it is continuous. Hence $w\mapsto\hat L_S(z_w)=\frac1n\sum_i(z_w(x_i)-y_i)^2$ is continuous, and its strict sublevel set $O_\tau(S)$ is open. It is therefore Borel, and it has positive Gaussian mass whenever it is nonempty.
- *Nonempty.* This needs $N\ge m$. By `paper.tex` eq. `teacher-energy` (lines 297–308), the balanced clone $w_g$ "computes $f$ exactly for every real input" and has $\kappa_N(w_g)\le E_*$ at every $N\ge C$ (here $C=m$). So $\hat L_S(z_{w_g})=\hat L_S(g)<\tau$ and $w_g\in O_\tau(S)$. I re-derived the three layer contributions:
  - first layer, $\le d(d+1)B^2$;
  - each internal layer, $\le\sum_{j,k}(n_j/n_k)V_{jk}^2\le2m^2B^2$;
  - readout, $\le N\sum_ju_j^2/n_j\le2m^2B^2$.

  `clone_energy.py` confirms exactness, with output error below $10^{-10}$, and $\kappa_N/E_*\le0.962$, over 400 random teachers with $L\le5$, $m\le6$ and several $N\ge m$, including sign-saturated weights.
- **Missing hypothesis:** the remark never says $N\ge m$. For $N<m$ the clone need not exist, and nothing bounds $\inf_{O_\tau}\kappa_N$ (issue 3).

### 3.2 Concentration on $\{\kappa_N\le E_*+\zeta\}$ (the Laplace step)

The cited argument is the first paragraph of the proof of `paper.tex` Cor. `exact` (lines 656–675). It conditions on the open set $O_\rho=\{e_S<\rho\}$ and puts $b_\rho=\inf_{O_\rho}\kappa_N$. It takes an open ball inside $O_\rho$ whose energy is below $b_\rho+\eta/2$, and compares the ball's Gaussian mass with the tail $\{\kappa_N>b_\rho+\eta\}$. It uses only two facts: the conditioning set is open and nonempty, and the coordinates are Gaussian. The specific form of $e_S$ plays no role. Here is the transfer, written out.

Fix $S$, $N\ge m$ and $\eta>0$, and put $b_\tau:=\inf_{O_\tau(S)}\kappa_N\le\kappa_N(w_g)\le E_*$.

- Pick $w'\in O_\tau$ with $\kappa_N(w')<b_\tau+\eta/4$, and pick $r>0$ with $B(w',r)\subseteq O_\tau$ and $\kappa_N<b_\tau+\eta/2$ on that ball. Both exist because $O_\tau$ is open and $\kappa_N$ is continuous.
- With $P$ the number of parameters and $\kappa_N=\lVert\Lambda w\rVert^2$,
$$\mu_\sigma(O_\tau)\ge(2\pi\sigma^2)^{-P/2}\det\Lambda\;\mathrm{vol}(B_r)\,e^{-(b_\tau+\eta/2)/(2\sigma^2)}.$$
- By the Chernoff bound for $\chi^2_P$, once $T:=b_\tau+\eta\ge P\sigma^2$,
$$\mu_\sigma\{\kappa_N>T\}=\Pr(\chi^2_P>T/\sigma^2)\le(T/(P\sigma^2))^{P/2}e^{-(T/\sigma^2-P)/2}.$$
- The powers of $\sigma$ cancel in the ratio, which is at most $C(P,T,\Lambda,r)\,e^{-\eta/(4\sigma^2)}\to0$. Hence $\Pi^\tau_\sigma\{\kappa_N>E_*+\eta\}\le\Pi^\tau_\sigma\{\kappa_N>b_\tau+\eta\}\to0$. ✓
- *Tightness and weak limits.* As in Cor. `exact`, the posteriors are tight, because energy sublevels are compact. Every weak limit point is carried by $\overline{O_\tau}\cap\{\kappa_N=b_\tau\}$, and $\overline{O_\tau}\subseteq\{\hat L_S\le\tau\}$. On that set $\kappa_N\le E_*$, so (R2) applies. ✓

**"Not open in the same way as a tube."** There is exactly one difference from the tube $U_\rho$ of Theorem `strong` (`paper.tex` eq. `tube`, lines 240–245). $U_\rho$ is a fixed open set that lies in the conditioning event *for every sample*, so the denominator bound, and with it $\sigma_0$, does not depend on the sample. By contrast, $O_\tau(S)$ is open for each sample but varies with the sample. The radius $r$ above, and with it $\sigma_0$, depends on $S$. Near the clone, $r$ shrinks with the margin $\tau-\hat L_S(g)$.

This dependence is real, not an artefact of the proof. Suppose $O_\tau(S)$ has a thin low-energy part and a fat part of higher energy. In the agnostic setting the fat part is exactly what memorizers provide (Lemma 2.1), because they fit far below $\tau$. Then at any fixed $\sigma$, most of the posterior sits in the fat part once the margin is small enough. The caricature in `sigma0_nonuniform.out` shows this: at $\sigma=0.2$, the posterior mass above the low-energy level is $5\cdot10^{-11}$ for margin $10^{-8}$, $0.005$ for margin $10^{-16}$, and $1.0$ for margin $10^{-32}$. At each fixed margin the mass still tends to $0$ as $\sigma\downarrow0$.

So the remark's claim, a limit as $\sigma\downarrow0$ with the sample fixed, is correct in the brief's limit order. It is not a statement of the form "for all $\sigma<\sigma_0$, with probability $\ge1-\delta$" (issue 5).

`pcn_concentration.out` shows the concentration on a toy model ($d=1$, $L=2$, $N=4$, $n=10$, 12 parameters). The sampler is an exact pCN sampler for the Gaussian prior restricted to $O_\tau$.

- At margin $0.05$, the median energy falls from $4.21$ at $\sigma=0.5$ to $1.77$ at $\sigma=0.13$, towards $b_\tau\approx1.56$. The gap left is about $P\sigma^2/2$.
- At margin $0.005$, it falls to $2.24$, towards $b_\tau\approx2.02$.

Both levels are below $\kappa_N(\text{clone})=3.59$ and $E_*=10$. No sample ever exceeded $E_*+1$.

### 3.3 Uniform deviation over $\mathcal Z_{E_*+1}$ (Lemma 3.1 and the step it skips)

"Lemma 3.1 then gives" compresses four steps.

1. **Rademacher bound (red-team Lemma 3.1).** I re-checked every step against `NNG/works-in-progress/noisy-interpolation/README.md` §4.
   - *(12), clip contraction.* $\operatorname{clip}_t(u)=\frac12(\lvert u+t\rvert-\lvert u-t\rvert)$. Splitting the supremum and using sign symmetry reduces it to the scalar contraction of $\lvert\cdot\rvert$, which holds with constant 1 and needs no absolute value outside. Then $\mathrm{Rad}(\mathcal F\pm[0,1])=\mathrm{Rad}(\mathcal F)+\mathbb E(\pm\sum\varepsilon_i)_+/n$, and the two average to $\mathbb E\lvert\sum\varepsilon_i\rvert/(2n)\le1/(2\sqrt n)$. ✓
   - *(13), clip mixture.* The weights integrate to $\tanh^2r+\operatorname{sech}^2r=1$. For $u\in[0,1]$, the derivative of the right side is $\int_u^1w+\operatorname{sech}^2r=\operatorname{sech}^2(ru)$. Both sides vanish at $0$ and are odd. ✓
   - *Path normalization.* With $\rho^\ell_j=\sum_i\lvert W^\ell_{ji}\rvert\rho^{\ell-1}_i$, the normalized preactivation is a signed convex combination of members of the symmetric convex set $\mathcal F_{\ell-1}\subseteq[-1,1]^n$. By (13), $\tanh(\rho u)/\rho\in\overline{\mathrm{conv}}\,\mathrm{Clip}(\mathcal F_{\ell-1})=\mathcal F_\ell$. ✓
   - *(14), path norm.* $P=\lvert v\rvert^\top\lvert W^H\rvert\cdots\lvert W^2\rvert\mathbf 1\le\sqrt N\lVert v\rVert_2\prod_{\ell=2}^H\lVert W^\ell\rVert_F\le(\kappa_N/H)^{H/2}$, by AM–GM over $H$ factors. The first-layer energy is not used. ✓
   - *Scaling.* Since $0\in\mathcal F_H$, $\{z|_S:z\in\mathcal Z_K\}\subseteq(K/H)^{H/2}\mathcal F_H$. ✓
   - *First layer.* $\tanh s=\mathbb E\operatorname{sign}(s-T)$. For each $a$, ties with the sample occur at only finitely many values of $T$. So $\mathcal F_1$ lies in the convex hull of the sample's affine-halfspace dichotomies. Massart's lemma with $R=\sqrt n$ and Sauer–Shelah (VC dimension $d+1$) complete the bound. ✓

   This is the same lemma as `../research-notes/B-tempered-likelihood.md` Lemma 5.2. B states it with $D_n=\sqrt{2(d+1)\ln(n+1)}+\tfrac{H-1}2$, and its referees passed it: `B-logic.md` line 38 and `B-computation.md` lines 30–31, including exact sign-enumeration checks.
2. **Symmetrization.** Mohri–Rostamizadeh–Talwalkar (MRT), Thm 3.3, applied to the loss class divided by 4, which takes values in $[0,1]$.
3. **Talagrand contraction with per-coordinate maps.** MRT Lemma 5.7. Here $\varphi_i(u)=(\operatorname{clip}u-y_i)^2/4$ is 1-Lipschitz because $\lvert y_i\rvert\le1$.
4. **McDiarmid's inequality.** It applies to a supremum that is measurable. Measurability follows by the countable reduction of ../research-notes/B-tempered-likelihood.md Lemma 5.3: the integrand is continuous in $w$ on each compact $\{\kappa_N\le K\}$, and the union over $N$ is countable.

The result is $L_D(\operatorname{clip}z)\le\hat L_S(\operatorname{clip}z)+8\,\mathbb E_S\hat{\mathfrak R}_S(\mathcal Z_K)+4\sqrt{\ln(1/\delta)/(2n)}$ for all $z\in\mathcal Z_K$, which is exactly ../research-notes/B-tempered-likelihood.md Lemma 5.3(a). ✓ The coefficient 4 in front of the square root belongs to the *expected*-Rademacher form. The bound therefore needs a sample-free majorant of $\mathcal D$ (issue 6).

Two properties of $G_\delta$ matter later:

- it depends on $K$ but not on $N$, $\sigma$ or $\tau$;
- it does not depend on which competitor produced $K$.

So the competitor, and even $\tau$, may be chosen after seeing the sample.

### 3.4 From the energy sublevel to the posterior functionals

On $G_\delta\cap\{\hat L_S(g)<\tau\}$, take any $w$ with $\kappa_N(w)\le K$ and $\hat L_S(z_w)\le\tau$. Because $\lvert y_i\rvert\le1$, $\hat L_S(\operatorname{clip}z_w)\le\hat L_S(z_w)\le\tau$. Then §3.3 gives (R2).

- *Gibbs risk.* The clipped risk is at most 4. So
$$\mathbb E_{\Pi^\tau_\sigma}L_D(\operatorname{clip}z_w)\le\tau+\mathsf R+4\,\Pi^\tau_\sigma\{\kappa_N>K\},$$
and the last term tends to $0$ by §3.2. No integrability issue arises, which is why Lemma 1.1 is not needed.
- *Posterior mean of clipped outputs.* Jensen's inequality.
- *Weak limits.* §3.2.

The remark leaves all of this unstated (issue 4).

### 3.5 Sample size, and what "$\tau\approx\mathrm{OPT}$" must mean

The hypothesis is the sample event $\{\hat L_S(g)<\tau\}$.

- If $\tau=L_D(g)$ exactly, this event has probability close to $1/2$. `tau_margin.out` gives $0.500$, $0.508$ and $0.514$ at $n=10^2,10^3,10^4$.
- Any competitor in the class may serve as $g$, but heuristically this does not rescue $\tau=\mathrm{OPT}$. For a smooth $p$-parameter class, the optimism of the empirical minimum is typically $O(p/n)$, which is negligible against the $\Theta(n^{-1/2})$ fluctuation of $\hat L_S(g^*)$. So the probability that some competitor has $\hat L_S<\mathrm{OPT}$ is still about $1/2$ for large $n$. I did not prove this; it is not needed for the corrected statement.
- On the complementary event the remark says nothing. There the posterior sits at $b_\tau$, which can exceed $E_*$, and can partially memorize.
- One-sided Hoeffding for the fixed $g$, whose losses lie in $[0,(U+1)^2]$, shows what works: with $\tau=L_D(g)+t$ and $t\ge(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, the event has probability at least $1-\delta$. `tau_margin.out` confirms this empirically: frequency $1.0000$ against the target $0.95$.

On $G_\delta\cap\{\hat L_S(g)<\tau\}$, which has probability at least $1-2\delta$, every functional in (R3) is at most $L_D(g)+t+\mathsf R$. For excess at most $\varepsilon$, take $t=\varepsilon/3$. It suffices that
$$n\ge\max\Bigl\{576\,\mathcal D_n^2\bigl(\tfrac{E_*+1}H\bigr)^H,\ 72\ln\tfrac1\delta,\ 4.5\,(mB+1)^4\ln\tfrac1\delta\Bigr\}\Big/\varepsilon^2,$$
with $\mathcal D_n^2=O(d\ln n+H^2)$ and the $\ln n$ absorbed in the usual way. This is polynomial in $d,m,B,1/\varepsilon,\log(1/\delta)$, of degree about $2H+1$ at fixed depth, uniform over $N\ge m$ and over $D$. **Yes, polynomial.**

### 3.6 The report's §1 lemmas

Remark 6.2 uses none of Lemmas 1.0–1.3.

- **Lemma 1.1** is specific to the SP$_c$ posterior $e^{-F_c/(2\sigma^2)}$, and it would not apply here. Its threshold is uniform over samples; the threshold here is not (§3.2). The sentence after Lemma 1.1 ("may be interchanged") must therefore not be applied to $\Pi^\tau$.
- **Lemma 1.0(1)**, $\lvert z_w\rvert\le\sqrt{\kappa_N}$, is needed only for the unclipped extension in §6(d). I re-checked both parts of Lemma 1.0:
  - the readout bound $\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2$;
  - the constant coordinate cancels in $\bar x-\bar x'$;
  - AM–GM over the $L$ energy terms.

  All are correct.
- **The §1 preamble.** Its limit-order convention (sample and width fixed, then $\sigma\downarrow0$; sample events free of $\sigma$ and $N$) is respected: $G_\delta$ and $\{\hat L_S(g)<\tau\}$ involve neither.

---

## 4. Comparison with the sources

| Ingredient | Source and exact statement | Use in Remark 6.2 | Matches? |
|---|---|---|---|
| Clone, $E_*$ | `paper.tex` lines 297–308: balanced clone computes $f$ exactly for every real input; $\kappa_N\le E_*=d(d+1)B^2+2(L-1)C^2B^2$ for $N\ge C$; teacher of the same depth, no internal biases, weights $\le B$ (lines 121–124) | $w_g\in O_\tau$, $b_\tau\le E_*$ | yes, if $N\ge m$ and the competitor has this architecture (issue 3) |
| Concentration | `paper.tex` Cor. `exact` proof, lines 656–675: Gaussian coordinates, fixed $N\ge C$, open $O_\rho$, comparison of ball mass to the tail $\{\kappa_N>b_\rho+\eta\}$; weak limits carried by $\{e_S\le\rho,\kappa_N=b_\rho\}$ | the same argument with $O_\tau=\{\hat L<\tau\}$ | yes; only openness, nonemptiness and Gaussianity are used |
| Laplace estimates | `paper.tex` Thm `strong` proof, lines 510–527: $\liminf\sigma^2\log\mu_\sigma(U_\rho)\ge-\tfrac M2E_*$ and $\limsup\sigma^2\log\mu_\sigma\{\kappa_N>K\}\le-\tfrac m2K$ ($M=m=1$ for Gaussian); $\sigma_0$ free of $D,n,\delta$ because $U_\rho$ is sample-free | implicit | the exponents match; the sample-freeness of $\sigma_0$ does **not** transfer (issue 5) |
| Prop. `exact`, Lemma `posterior` | clean labels; cover plus a sup-norm fit on the sample | not used, correctly so; the remark cites only the *concentration* half of Cor. `exact` | n/a |
| Rademacher bound | README §4, eqs. (12)–(15) (cube); red-team Lemma 3.1 and ../research-notes/B-tempered-likelihood.md Lemma 5.2 (arbitrary inputs) | $\hat{\mathfrak R}_S(\mathcal Z_{E_*+1})$ | yes (§3.3), given a sample-free $\mathcal D$ (issue 6) |
| Uniform deviation | MRT Thm 3.3 and Lemma 5.7; ../research-notes/B-tempered-likelihood.md Lemma 5.3(a), refereed: $8(K/H)^{H/2}D_n/\sqrt n+4\sqrt{\ln(1/\delta')/(2n)}$ | the displayed bound | yes; $\ln(2/\delta)\ge\ln(1/\delta)$, so it is conservative |
| Label range | BRIEF §1: $D$ on $X\times[-1,1]$ | $\hat L(\operatorname{clip}z)\le\hat L(z)$; loss range 4; Lipschitz constant 4 | yes; should be stated |
| Prior | BRIEF §2: Gaussian, density $\propto e^{-\kappa_N/(2\sigma^2)}$ | Cor. `exact` assumes Gaussian | yes; for the log-concave law of `paper.tex` eq. `law`, replace $E_*$ by $(M/m)E_*$ in $K$ |

**Checklist of hypotheses.**

- *Widths:* $N\ge m$ is required and missing. There is no upper limit, and the result is uniform in $N$. ✓
- *Weight bounds:* all layers, including the first, lie in $[-B,B]$; this enters through $E_*$. ✓
- *Clipping:* the bound is for clipped outputs; unclipped outputs also work (§6(d)).
- *Measurability:* $O_\tau$ is open; $G_\delta$ is measurable by the countable reduction. ✓
- *Existence of minimizers:* not needed. $b_\tau$ is an infimum, and weak limits exist by tightness. ✓
- *Label range:* $[-1,1]$ is needed. ✓
- *Circularity:* none.

---

## 5. Issues

1. **(minor; interpretation) "$\tau\approx\mathrm{OPT}$" and "fit as well as the best small network does".**
   - *Problem.* The hypothesis is a strict inequality on the sample. At $\tau=\mathrm{OPT}$ it holds with probability about $1/2$ (§3.5), and the remark gives nothing on the complement. Read literally ("as well as"), the summary sentence is therefore not covered by the proof.
   - *Fix.* State that one needs $\tau>\hat L_S(g)$. For a high-probability oracle inequality, take $\tau=L_D(g)+t$ with $t\ge(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, which yields excess at most $t+\mathsf R$ with probability at least $1-2\delta$.
2. **(minor, but it must be carried into any citation; scope) "Survives (proved here)".**
   - *Problem.* §0 item 7 and §6.3 item 4 list Remark 6.2 among the "versions [that] survive, all proved here", without the oracle caveat. BRIEF §1 fixes the learner before $D$ and $g$, and $\Pi^\tau$ needs $\tau$ tuned to within $O(\varepsilon)$ of $\mathrm{OPT}(D)$. So it is a family of learners indexed by an oracle hyperparameter, like Prop. 4.1, which needs $\rho>\rho_0$. The remark's own text admits this ("the catch").
   - *Fix.* Reword along the lines of "survives if $\tau$ is supplied". Optionally add §6(c): since $G_\delta$ does not depend on $\tau$, the data-driven level $\hat\tau=\min_{\mathcal G_{m,B}}\hat L_S+t$ removes the dependence on $D$. That costs a non-Bayesian ERM step. A hyperprior over $\tau$ remains open.
3. **(minor; missing hypotheses)**
   - *Problem.* The remark does not state:
     - $N\ge m$, needed for the clone;
     - that the competitor has the learner's depth $L$ and the repository architecture;
     - Gaussian coordinates, which are what Cor. `exact` uses;
     - labels in $[-1,1]$.
   - *Fix.* Import these hypotheses from Theorem 3.2 and BRIEF §§1–2.
4. **(minor; quantifiers) The display has no probability qualifier, no width quantifier, and no named functional.**
   - *Problem.* A $\sigma\downarrow0$ limit has no single "$z_w$".
   - *Fix.* Use the form (R)–(R3) of §2: one event $G_\delta$, free of $N$, $\sigma$ and $\tau$. On it, every weak limit point, the clipped Gibbs risk and the posterior mean of the clipped outputs all satisfy the bound, for every $N\ge m$.
5. **(minor; limit order) The scale threshold depends on the sample.**
   - *Problem.* $\sigma_0$ depends on $S$ through the geometry of $O_\tau(S)$, and near the clone through $\tau-\hat L_S(g)$. For each fixed $\sigma$ there are samples on which the posterior sits above $E_*+1$ (§3.2). The claimed pointwise limit is unaffected. But the "interchange" sentence after Lemma 1.1 does not apply, and the remark cannot be quoted in the form of Theorem `strong` ("for all $\sigma<\sigma_0$, with probability $\ge1-\delta$").
   - *Fix.* Keep the per-sample limit, or add a margin $\hat L_S(g)\le\tau-\xi$. Then, by Minkowski's inequality, the sup-norm tube $U_r(g)$ with $r=\sqrt\tau-\sqrt{\tau-\xi}$ lies in $O_\tau(S)$ for every such sample. It is sample-free, open and contains $w_g$, so $\sigma_0=\sigma_0(N,g,\tau,\xi,\zeta)$. With $\tau=L_D(g)+2\xi$, Hoeffding bounds the margin event's failure probability by $e^{-2n\xi^2/(U+1)^4}$.
6. **(minor; definitions) $\mathcal D$ is not defined in the remark, and Lemma 3.1 defines it through the given sample's dichotomy count.**
   - *Problem.* The deviation term $4\sqrt{\cdot}$ is the expected-Rademacher form, so it needs a sample-free majorant. The remark also skips symmetrization, contraction and McDiarmid ("Lemma 3.1 then gives").
   - *Fix.* Take $\Pi_d(n)$ to be the growth function, or use $\mathcal D_n=\sqrt{2(d+1)\ln(n+1)}+\tfrac{H-1}2$ as in ../research-notes/B-tempered-likelihood.md. Cite ../research-notes/B-tempered-likelihood.md Lemma 5.3(a), or the proof of Theorem 3.2, for the deviation step. If the sample's own count is kept, the deviation term must be $12\sqrt{\ln(2/\delta)/(2n)}$ (MRT Thm 3.3, second form).
7. **(minor; wording) "whereas conditioning on each output does not".**
   - *Problem.* Read literally, this contradicts the report's own Prop. 4.1, where per-output conditioning with tolerance matched to a small sup-norm residual works.
   - *Fix.* Say "conditioning on each output at a tolerance below the noise level does not (Claim A, A5)".

---

## 6. Corrected statement (strongest form I can support)

**Remark 6.2 (corrected).** Fix the following:

- $L=H+1\ge2$;
- a law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact;
- a depth-$L$ competitor $g$ of width $m$ in the repository architecture, with all weights in $[-B,B]$;
- $E_*=d(d+1)B^2+2(L-1)m^2B^2$, $K=E_*+1$ and $U=mB$;
- $\tau>0$ and $\delta\in(0,1)$;
- $\mathcal D_n=\sqrt{2(d+1)\ln(n+1)}+\tfrac{H-1}2$.

For width $N$, let $\mu_\sigma$ be the strong-prior Gaussian prior and $\Pi^\tau_{\sigma,N,S}=\mu_\sigma(\cdot\mid\hat L_S(z_w)<\tau)$.

**(a)** There is an event $G_\delta$ with $\Pr(G_\delta)\ge1-\delta$, free of $N$, $\sigma$ and $\tau$. On $G_\delta\cap\{\hat L_S(g)<\tau\}$, for every $N\ge m$:

- $\Pi^\tau_{\sigma,N,S}\{\kappa_N>E_*+\zeta\}\to0$ as $\sigma\downarrow0$, for every $\zeta>0$;
- every weak limit point is carried by $\{\hat L_S\le\tau,\ \kappa_N=\inf_{\{\hat L_S<\tau\}}\kappa_N\}\subseteq\{\hat L_S\le\tau,\ \kappa_N\le E_*\}$;
- on that set, the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk, and that of the risk of the posterior mean of the clipped outputs, are each at most
$$\tau+8\mathcal D_n\Bigl(\tfrac{E_*+1}H\Bigr)^{H/2}n^{-1/2}+4\sqrt{\tfrac{\ln(1/\delta)}{2n}}.$$

The scale threshold depends on the sample. It is uniform over samples with $\hat L_S(g)\le\tau-\xi$.

**(b)** If $\tau=L_D(g)+t$ with $t\ge(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, then with probability at least $1-2\delta$ the same functionals are at most $L_D(g)+t+8\mathcal D_n((E_*+1)/H)^{H/2}n^{-1/2}+4\sqrt{\ln(1/\delta)/(2n)}$. This holds at every width $N\ge m$, with the polynomial sample size of §3.5. The learner depends on $\tau$, so on $L_D(g)$: it is an oracle hyperparameter.

**(c) (Removing the oracle; checked here, not claimed in the remark.)** $G_\delta$ does not depend on $\tau$, and the concentration argument works sample by sample. So $\tau$ may be computed from the data as $\hat\tau_S=\min_{g'\in\mathcal G_{m,B}}\hat L_S(g')+t$ for any $t>0$.

- The minimum is attained: it is taken over a compact parameter set, and it is a continuous function of $S$.
- The minimizer has a clone in the conditioning set with energy at most $E_*$.
- The bound becomes $\inf_{\mathcal G_{m,B}}L_D+t+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}+8\mathcal D_n((E_*+1)/H)^{H/2}n^{-1/2}+4\sqrt{\ln(1/\delta)/(2n)}$, with probability at least $1-2\delta$. This uses Hoeffding for a fixed near-optimal $g^\circ\in\mathcal G_{m,B}$.
- The learner then depends on the comparator class $(m,B)$ but not on $D$. It includes an ERM step, so it is not purely Bayesian.
- With $m=B=n^\alpha$ and $d\le n^\alpha$, we get $K=O(Hn^{4\alpha})$. The excess is then $\tilde O(n^{2\alpha H-1/2})+O(n^{4\alpha-1/2})+t$, which vanishes polynomially for $\alpha<1/(4H)$ when $H\ge2$ (and for $\alpha<1/8$ when $H=1$). A hyperprior over $\tau$ is not analysed.

**(d) (Unclipped outputs; optional.)** On $\{\kappa_N\le K\}$, $\lvert z_w\rvert\le\sqrt K$ by Lemma 1.0(1). ../research-notes/B-tempered-likelihood.md Lemma 5.3(b) then gives the same statement for $L_D(z_w)$, with the excess term $4(\sqrt K+1)\mathcal D_n(K/H)^{H/2}n^{-1/2}+(\sqrt K+1)^2\sqrt{\ln(1/\delta)/(2n)}$. This is also polynomial.

## 7. Answers to the focus questions

- **Is the bound correct?** Yes, for:
  - the Gibbs risk of clipped outputs;
  - the posterior mean of clipped outputs;
  - every point carrying a $\sigma\downarrow0$ weak limit;

  for every $N\ge m$, under a Gaussian prior, on $G_\delta\cap\{\hat L_S(g)<\tau\}$. The remark's $\ln(2/\delta)$ is conservative. Issues 3, 4 and 6 must be fixed in the statement.
- **Is the concentration justified?** Yes. The event is open because it is a strict sublevel set of a function continuous in $w$. It is nonempty because it contains the clone. Cor. `exact`'s comparison of ball mass to tail mass needs nothing else. What does not carry over from the tube is the sample-free scale threshold (issue 5).
- **Is $n$ polynomial?** Yes. For excess $\varepsilon$ over $\tau$, it suffices that $n\gtrsim\mathcal D_n^2(E_*/H)^H/\varepsilon^2$. For the hypothesis to hold with high probability at $\tau=L_D(g)+\varepsilon/3$, it suffices that $n\gtrsim(mB+1)^4\ln(1/\delta)/\varepsilon^2$. Both are polynomial at fixed depth.

## 8. Numerical record (`../checks/verify-RT-aggregate-logic/`)

| Script | Checks | Result |
|---|---|---|
| `clone_energy.py` / `.out` | clone exactness and $\kappa_N\le E_*$ for 400 random teachers ($d\le5$, $L\le5$, $m\le6$, several $N\ge m$, including saturated weights) | exact to $10^{-10}$; $\max\kappa_N/E_*=0.9618$ |
| `pcn_concentration.py` / `.out` | toy model ($d=1$, $L=2$, $N=4$, $n=10$): exact pCN sampling of $\mu_\sigma(\cdot\mid\hat L<\tau)$; energy quantiles as $\sigma\downarrow0$; SLSQP upper estimate of $b_\tau$ | median $\kappa_N$ falls from $4.21$ to $1.77$ (margin $0.05$, $b_\tau\approx1.56$) and from $4.63$ to $2.24$ (margin $0.005$, $b_\tau\approx2.02$); never above $E_*+1=11$ |
| `tau_margin.py` / `.out` | $\Pr[\hat L(g)<L_D(g)]$, and the same probability with Hoeffding slack | $0.500$ / $0.508$ / $0.514$ at $n=10^2,10^3,10^4$; with slack, $1.0000$ against the target $0.95$ |
| `sigma0_nonuniform.py` / `.out` | one-dimensional caricature: thin low-energy part of width $r$ against a fat high-energy part; posterior mass of the high part | at $\sigma=0.2$: $5\cdot10^{-11}$, $0.005$ and $1.0$ for $r=10^{-8},10^{-16},10^{-32}$; for each $r$ it tends to $0$ as $\sigma\downarrow0$ |

The pCN and SLSQP runs give one-sided evidence only: $b_\tau$ is an upper estimate, and the toy model is far from the asymptotic regime. They illustrate the concentration step and do not prove it.
