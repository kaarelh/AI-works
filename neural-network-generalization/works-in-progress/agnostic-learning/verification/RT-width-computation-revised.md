# Referee report (computation lens, round 1 of the revision): `../research-notes/small-learner-width.md`

**What was refereed.** `../research-notes/small-learner-width.md`, the revised §6.3 of `../research-notes/red-team.md`. It covers Proposition 6.1, its proof, its "In particular" clause and the closing sentence on the width transition. The revision replaces them with:

- Lemmas A–F, Theorem 1, Corollaries 2 and 3, and Theorem 4;
- Remarks 5–8;
- replacement wording for `../research-notes/red-team.md` (§7.3).

**Inputs re-read against their sources.**

- `../research-notes/red-team.md`: §1 (Lemmas 1.0 and 1.1), §3 (Theorem 3.2, first paragraph) and §6.3 (Proposition 6.1 and the closing sentence).
- `../research-notes/B-tempered-likelihood.md`: Lemma 2.3, Lemma 3.1, Corollary 8.1, Proposition 9.1 and Lemma 9.2.
- `../research-notes/A-tight-conditioning-fails.md`: Lemma 2.1, Theorem 4.4, Corollary 4.5 and Remark 4.7.
- `paper.tex` (`NNG/side-results/continuous-domains/source/paper.tex`): eq. `eq:energy` (line 293), eq. `eq:teacher-energy` (line 303) and the model section (lines 112–125). They match the note's §1 and Lemma A.

The revision is self-contained. Lemma B is `../research-notes/B-tempered-likelihood.md` Lemma 2.3(a),(c), and Lemmas A and B replace the first paragraph of `../research-notes/red-team.md` Theorem 3.2. Lemma F replaces `../research-notes/red-team.md` Lemma 1.1, and no Rademacher bound is used.

**Scripts.** All are in `../checks/verify-RT-width-computation-revised/` (§5). Each was run as `python3 X.py > X.out`.

## Verdict: minor fixes

Every computation behind the corrected clause is right. I recomputed each constant and exponent by hand, checked the algebra symbolically, and tested the inequalities numerically, including adversarial searches. Results:

1. **Perturbation bound (Lemma C): correct.** Adversarial maximization of the linearized change $\lVert\nabla_wz_w(x)\rVert_1$ over the energy ellipsoid reaches $0.92$ of the sharper form at $H=1$, against $0.73$ in earlier checks. So the sharper form is nearly tight there. The worst ratio to the closed form is $0.74$. Finite perturbations, with $\eta$ up to $5$, reach $0.84$ of the sharper form. There are no violations.
2. **Grid mesh and log-cardinality (Lemma D): correct.** Checked in exact rational arithmetic: $|T|\le2+2R/\eta_N$, the last grid point is at least $R$, and the covering radius is exactly $\eta_N/2$. This gives sup-error $1/(2n)$ and hence the discretization cost $4/n$.
3. **Uniform deviation (Theorem 1(a)): correct.** One-sided Hoeffding with range $4$, $\delta'=\delta/(4|\mathcal T_N|)$, and $\ln|\mathcal T_N|\le P_N\Lambda_N$ give $\mathrm{Dev}_N(\delta)+4/n$, with failure probability at most $\delta/4$.
4. **Exponents.** The original rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ is correctly withdrawn. The new explicit bound (5.2) holds:
   - maximum of exact $\mathrm{Exc}$ over (5.2): $0.69$ on a random search with $H\le40$ and $n\le10^{300}$, and $0.67$ under Nelder–Mead;
   - every step of its proof was checked separately, and the arithmetic was checked in sympy;
   - the slopes are $4\alpha-1$ (clone), $\alpha-\frac12$ (deviation), $2\alpha-\frac12$ (Bernstein) and $4\alpha-\frac12$ (Hoeffding), to three decimals.
5. **"Polynomially small for $\alpha<1/4$" on the stated class** (width $\le\lceil n^\alpha\rceil$, weights $\le n^\alpha$, $d\le n^\alpha$): **holds with the Bernstein step.** The rate is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$. With the Hoeffding step (the original display), the bound is polynomially small exactly for $\alpha<1/8$; at $\alpha=1/8$ its slope is $0.000$.
6. **Closing sentence, now Remark 8: correct, with one overstatement.** "The full excess $\beta(\lambda)-o(1)$ needs $a\to0$, and then $N_0=O(n^{5/3}\log^2n)$" suggests that the full excess needs width $n^{5/3}$. It does not. Any accuracy schedule $a_n\to0$ works and gives $N_0=O(n\log^2n/a_n^2)$, for example $O(n\log^4n)$ with $a=1/d$ (§3, issue 1).

The remaining issues are presentational or about coverage (§3, issues 2–7). None affects the corrected clause.

### Answers to the focus questions

| question | answer | evidence |
|---|---|---|
| Perturbation bound | correct; sharper form nearly tight at $H=1$ | §2.3; `perturb_adv.out` |
| Grid mesh, log-cardinality | correct; covering radius $\eta_N/2$ | §2.4; `lemmas_check.out` (D) |
| Uniform deviation | correct; $\mathrm{Dev}_N+4/n$ with probability $\ge1-\delta/4$ | §2.6 |
| Exponent $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ | not proved; correctly withdrawn; the proved rate is $n^{2\alpha-1/2}$ | §2.9–2.10; `bound_check.out` (4) |
| Polynomially small for $\alpha<1/4$ on the stated class | yes, with Bernstein; only $\alpha<1/8$ with Hoeffding | §2.9–2.11 |
| Closing sentence (Remark 8) | correct window, $o(\sqrt{n/\ln n})$ to $O(n\log^2n/a^2)$; the $n^{5/3}$ remark overstates | §2.14; `transition_check.out` |

---

## 1. Constants and conventions

Fixed throughout: $L=H+1$, $P_N=N(d+1)+(H-1)N^2+N$, $K=n/c+1$, $\ell=\ln(4/\delta)$,
$$\Lambda_N=\ln\bigl(2+2n\sqrt{KN}\,H(d+N+1)(K+1)^{H/2}\bigr),\qquad\mathrm{Dev}_N(\delta)=4\sqrt{(P_N\Lambda_N+\ell)/(2n)} .$$
$P_N$ is the exact number of parameters ($W^1$: $N(d+1)$; $H-1$ internal $N\times N$ layers; readout $N$). It agrees with the original's $N(d+1)+(L-2)N^2+N$.

## 2. Step-by-step recomputation

### 2.1 Lemma A (cloning)

The group construction computes $g$ exactly: by induction, the layer-$\ell$ preactivation of unit $p$ is $\sum_jU^\ell_{j(p)j}h^{\ell-1}_{g,j}$. Energy:

- first layer: $\frac dN\sum_jk_j|U^1_{j,:}|^2\le d(d+1)B^2$;
- each internal layer: $\sum_{j,j'}(k_j/k_{j'})(U^\ell_{jj'})^2\le2m^2B^2$, using $\lceil N/m\rceil/\lfloor N/m\rfloor\le2$;
- readout: $N\sum_ju_j^2/k_j<2m^2B^2$, using $N/\lfloor N/m\rfloor<2m$.

The total is $d(d+1)B^2+2Hm^2B^2=E_*$. ✓

Numerics (`lemmas_check.py` (A)): 3,274 clones, including all-$\pm B$ and all-$+B$ weights at the worst widths $N\in\{m,m+1,2m-1\}$.

- Clone error is at most $9.5\cdot10^{-14}$.
- $\kappa_N/E_*\le0.969$.
- The first-layer bound is attained (ratio $1.000$). The internal and readout bounds are loose by about $2$ (worst $0.5625$, at $m=2$, $N=3$).

### 2.2 Lemma B (near-minimizers)

(a) $\kappa_N(w)\le F(w)\le F(0)+\zeta=c^{-1}\sum y_i^2+\zeta\le n/c+\zeta$.

(b) $F(w)\le F(w^g_N)+\zeta\le E_*+\zeta+\frac nc\hat L(g)$; dropping $\kappa_N(w)$ gives $\hat L(z_w)\le\hat L(g)+c(E_*+\zeta)/n$. ✓

### 2.3 Lemma C (perturbation)

Re-derived:

- $e_1\le\eta(d+1)\sqrt N$;
- $e_\ell\le\sqrt Ke_{\ell-1}+\eta N^{3/2}$;
- output change $\le\sqrt{K/N}\,e_H+\eta N$.

Unrolling gives $\eta[(d+1)K^{H/2}+N\sum_{j=0}^{H-1}K^{j/2}]\le\eta H(d+N+1)(K+1)^{H/2}$. The same expression is the backpropagation bound on $\lVert\nabla_wz_w(x)\rVert_1$, so the bracket is exactly the linearized worst case of the proof's chain.

Adversarial check (`perturb_adv.py`): 220 configurations ($H\le4$, $d\le4$, $N\le6$, $K\in[0.5,300]$), 4 restarts each. Projected gradient ascent ran on $\lVert\nabla_wz_w(x)\rVert_1$ over $\{\kappa_N\le K\}$ jointly with sign ascent on $x$, starting from random and from aligned rank-one weights.

| quantity | maximum observed | must be |
|---|---|---|
| $\lVert\nabla z\rVert_1/$sharper form | **0.919** ($H=1$, $d=3$, $N=6$, $K=300$) | $\le1$ |
| $\lVert\nabla z\rVert_1/$closed form | 0.740 | $\le1$ |
| finite $\eta\in\{10^{-3},0.1,1,5\}$: $\lvert\Delta z\rvert/(\eta\cdot\text{sharper})$, 3,000 networks | 0.839 | $\le1$ |

Earlier checks reached $0.61$–$0.73$. The bound is valid and, for $H=1$, nearly tight.

### 2.4 Lemma D (grid mesh and log-cardinality)

- $|T|=\lceil2R/\eta_N\rceil+1\le2+2R/\eta_N=e^{\Lambda_N}$, so $\ln|\mathcal T_N|=P_N\ln|T|\le P_N\Lambda_N$.
- The last point $-R+\lceil2R/\eta_N\rceil\eta_N$ is at least $R$, so the covering radius is $\eta_N/2$.
- Lemma C with $\eta=\eta_N/2$ gives $\frac12\eta_NH(d+N+1)(K+1)^{H/2}=\frac1{2n}$.
- Entry bounds on $\{\kappa_N\le K\}$ are $\sqrt{KN/d}$, $\sqrt K$ and $\sqrt{K/N}$, each at most $R=\sqrt{KN}$.

All ✓. `lemmas_check.py` (D) checks the count and the radius in exact rational arithmetic on 4,000 random $(R,\eta)$: no violation, and maximum distance/$\eta$ is exactly $1/2$.

### 2.5 Lemma E (concentration)

- (i) Hoeffding: the root of $2nt^2/b^2=\ell'$ is $t=b\sqrt{\ell'/(2n)}$ (sympy). ✓
- (ii) Bernstein: the cited form is Boucheron–Lugosi–Massart Corollary 2.11 with $c=b/3$, valid for $X_i\le b$. The variance bound is $\operatorname{Var}Z\le\mathbb EZ^2\le b\mu$. With $t=A+C$, sympy gives
$$t^2-\tfrac{2\ell'}n\bigl(b\mu+\tfrac{bt}3\bigr)=\tfrac{2\sqrt2}{3}\,\frac{b^{3/2}\ell'^{3/2}\mu^{1/2}}{n^{3/2}}\ge0 . \quad✓$$

Remark: BLM Theorem 2.10 gives the sharper linear term $b\ell'/(3n)$. The note's $2b\ell'/(3n)$ is valid, and the difference is harmless.

Exact binomial tails for two-point losses $\{0,b\}$ were checked on 24,000 cases, including $n\in\{1,2,3\}$, $\mu/b$ down to $10^{-9}$ and $\delta'$ down to $10^{-6}$. Two-point laws are the extremal laws for a given mean and range. The maximum of tail$/\delta'$ is $0.19$ for the Bernstein threshold and $0.59$ for the Hoeffding threshold.

### 2.6 Theorem 1(a) (uniform deviation)

For each grid point, Lemma E(i) is applied with $b=4$ and $\delta'=\delta/(4|\mathcal T_N|)$. A union bound gives
$$L_D(\operatorname{clip}z_{w'})\le\hat L(\operatorname{clip}z_{w'})+4\sqrt{(\ln|\mathcal T_N|+\ell)/(2n)}\le\hat L(\operatorname{clip}z_{w'})+\mathrm{Dev}_N(\delta).$$
Rounding costs $4\cdot\frac1{2n}$ in $L_D$ and $4\cdot\frac1{2n}$ in $\hat L$, by the 4-Lipschitz clipped loss (1.1). The total is $+4/n$. ✓ The grid depends only on $(n,c,N,d,H)$. ✓

### 2.7 Theorem 1(b), (c)

- (4.2) follows from (a), Lemma B(a) with $\zeta=1$ (which gives $\kappa_N\le K$), $\hat L(\operatorname{clip}z)\le\hat L(z)$, and Lemma B(b). ✓
- $\Gamma_H$ is Lemma E(i) with $b=(U+1)^2$. ✓
- $\Gamma_B$ is Lemma E(ii) with $b\mu=(U+1)^2L_D(g)$; the case $L_D(g)\ge4$ is trivial because $L_D(\operatorname{clip}z_w)\le4$. ✓
- Probabilities: $\mathcal E_0\cap\mathcal E_H\cap\mathcal E_B$ has probability $\ge1-3\delta/4$, and any two of the three events give $\ge1-\delta/2$. ✓
- (c): $K=n/c+1\le K'=E_*+1+n(U+1)^2/c$, the logarithm increases in $K$, and $4/n\le8/n$. So the original display holds with probability $\ge1-\delta/2$. ✓

### 2.8 Corollary 2 (class minimum)

- A minimizer $g^*$ exists, by compactness of $[-\bar B,\bar B]^Q$ and dominated convergence (the loss is at most $(\bar U+1)^2$). ✓
- $L_D(g^*)\le L_D(0)=\mathbb Ey^2\le1$. ✓
- Zero padding preserves the function and the weight bound, so $U=\bar U$ and $E_*=\bar E_*$. ✓
- Since $\min\{L_D(g^*),4\}\le1$, $\Gamma_B(g^*)\le(\bar U+1)\sqrt{2\ell/n}+\frac23(\bar U+1)^2\ell/n$. ✓

### 2.9 Corollary 3, the explicit bound (5.2)

Each step was recomputed and checked in sympy (`symbolic_check.out`), with $\nu=n^\alpha$:

| step | claim | check |
|---|---|---|
| 1 | $\bar E_*+1\le(2+8(L-1)+1)\nu^2\bar B^2=(8L-5)\nu^2\bar B^2$; with $4/n\le4\bar B^2n^{2\alpha-1}$ the total is $(8L-1)\bar B^2n^{2\alpha-1}$ | $2+8H+1=8H+3=8L-5$; plus $4$ gives $8L-1$ ✓ |
| 2 | $\bar U+1\le3\nu\bar B$; terms $3\sqrt2\bar Bn^{\alpha-1/2}\sqrt\ell$ and $6\bar B^2n^{2\alpha-1}\ell$ | $2\cdot9/3=6$ ✓ |
| 3 | $P_N=N(d+2)+(H-1)N^2\le6\nu^2+4(H-1)\nu^2=(4H+2)\nu^2$ | ✓ |
| 4 | $2n\sqrt{KN}H(d+N+1)(K+1)^{H/2}\le8\sqrt3H2^{H/2}n^{(2H+9)/4}$; the "+2" is absorbed into $16H2^{H/2}n^{(2H+9)/4}$; $\Lambda_N\le(3+\frac{3H}2)\ln2+\frac{2H+9}4\ln n\le(H+5)\ln2n$ | sympy: product ratio $=1$; absorption margin $(16-8\sqrt3)\sqrt2\,2^{11/4}=20.4\ge2$; difference $(2-\frac H2)\ln2+(\frac H2+\frac{11}4)\ln n\ge\frac{19}4\ln2$ ✓ |
| 5 | $\mathrm{Dev}_N\le4\sqrt{(2H+1)(H+5)\ln2n}\,n^{\alpha-1/2}+2\sqrt2\sqrt{\ell/n}$ | $(4H+2)(H+5)/2=(2H+1)(H+5)$; $4/\sqrt2=2\sqrt2$ ✓ |
| sum | $3\sqrt2+2\sqrt2=5\sqrt2$ using $n^{-1/2}\le\bar Bn^{\alpha-1/2}$; $(8L-1)+6\ell\le(8L-1)(1+\ell)$ | ✓ |

Numerics (`bound_check.py`):

- Random search over $n\in[2,10^{300}]$, $\alpha\in[0,\frac12)$, $H\le40$, $N\in[1,2n^\alpha]$, $d\in[1,n^\alpha]$, $\bar B\in[1,n^{0.9}]$ and $\delta\in[10^{-12},0.999]$: maximum $\mathrm{Exc}/(5.2)=0.691$.
- Nelder–Mead over $(\ln n,\alpha,N,d,\log_n\bar B)$ for $H\in\{1,2,3,5,10,30\}$: maximum $0.671$.
- Per-step ratios: steps 1–3 are attained, with ratio exactly $1$ at $\alpha=0$, $d=1$, $N=2$, $\bar B=1$. Step 4 reaches $0.595$, step 5 reaches $0.758$, and $\Lambda_N/((H+5)\ln2n)$ reaches $0.631$, the same as the author's value.

**Looseness (informational).** In case (i), $\mathrm{Exc}/(5.2)\to0.200$ as $n\to\infty$ (0.200 at $n=10^{48}$ and $10^{96}$ for $\alpha=0.1,0.2$). The true leading term is $(\bar U+1)\sqrt{2\ell/n}\approx\sqrt2\,n^{2\alpha-1/2}\sqrt\ell$, and (5.2) has $5\sqrt2$. The factor 5 comes from allowing $N\le2\nu$ (so $\bar U+1\le3\nu\bar B$) and from absorbing $2\sqrt2\sqrt{\ell/n}$. This is not an error.

### 2.10 Exponents and thresholds

Slopes of $\ln(\text{term})$ against $\ln n$, between $n=10^{150}$ and $10^{300}$, in case (i) ($N=\lceil n^\alpha\rceil$, $d=\lfloor n^\alpha\rfloor$, $\bar B=n^\alpha$, $H=2$, $\delta=0.05$; `bound_check.out` (4)):

| $\alpha$ | clone $(4\alpha-1)$ | deviation $(\alpha-\frac12)$ | Bernstein $(2\alpha-\frac12)$ | Hoeffding $(4\alpha-\frac12)$ | full Bernstein form | full Hoeffding form |
|---|---|---|---|---|---|---|
| 0.100 | −0.600 | −0.399 | −0.300 | −0.100 | −0.300 | −0.100 |
| 0.125 | −0.500 | −0.374 | −0.250 | **0.000** | −0.250 | **0.000** |
| 0.126 | −0.496 | −0.373 | −0.248 | +0.004 | −0.248 | +0.004 |
| 0.200 | −0.200 | −0.299 | −0.100 | +0.300 | −0.100 | +0.300 |
| 0.249 | −0.004 | −0.250 | −0.0025 | +0.496 | −0.003 | +0.496 |
| 0.250 | 0.000 | −0.249 | 0.000 | +0.500 | **0.000** | +0.500 |

So the Hoeffding form is polynomially small iff $\alpha<1/8$, and the Bernstein form iff $\alpha<1/4$. The deviation slope differs from $\alpha-\frac12$ by about $0.001$ because of the $\sqrt{\ln n}$ factor. For $\alpha\in(0,\frac14)$ the Bernstein form has slope exactly $2\alpha-\frac12$, as the clause states.

How slow this is near $\alpha=1/4$ (informational): at $\alpha=0.24$ the exact $\mathrm{Exc}$ is $4.36$ at $n=10^{12}$, $0.668$ at $n=10^{40}$ and $0.037$ at $n=10^{96}$. "Polynomially small" is an asymptotic statement only.

### 2.11 Remarks 5 and 6(b)

**Remark 5.**

- $n^{2\alpha}<\bar U+1\le n^{2\alpha}+n^\alpha+1\le3n^{2\alpha}$, so the Hoeffding term lies in $[\sqrt{\ell/2},\,\frac9{\sqrt2}\sqrt\ell]\cdot n^{4\alpha-1/2}$. ✓
- The values $5.9\cdot10^3$ ($n=10^{12}$) and $1.48\cdot10^{12}$ ($n=10^{40}$) for the Hoeffding form, and $0.228$ and $3.0\cdot10^{-4}$ for the Bernstein form, are reproduced ($\alpha=0.2$; `check_explicit_bound.out` (4)). ✓

**Remark 6(b).** For the competitor $g(x)=mB\tanh(mB\tanh(Bx))$:

- it is in the class (width $\lceil n^\alpha\rceil$, weights $n^\alpha$, zero bias, $d=1$, $L=3$);
- $L_D(g)=p(G+1)^2=1$ and $L_D(0)=p$.

The exact binomial $95\%$ quantile divided by $(G+1)/\sqrt n$ is between $1.638$ and $1.716$. Its ratios to the withdrawn rate are:

- $\alpha=0.10$: $2.73$, $3.80$, $5.02$, $7.54$;
- $\alpha=0.15$: $5.68$, $10.32$, $19.15$, $35.26$;
- $\alpha=0.20$: $6.39$, $11.71$, $19.98$, $33.55$.

These match the table (`lemmas_check.out` (6b)). ✓

### 2.12 Lemma F and Theorem 4 (passage to the posterior)

**Lemma F.**

- Lipschitz constant on the compact convex set $\Omega$: $\ell_F=2R_\Omega\lambda_{\max}+\frac ncG_\Omega(2Z_\Omega+2)$, independent of $S$. ✓
- Ball of radius $\rho=\min\{1,\zeta/(4\ell_F)\}$ around $w_*$: it lies in $\Omega$, and $F\le m_*+\zeta/4$ on it. ✓
- Tail: $F\ge(1-a)(m_*+\zeta)+a|\Lambda w|^2$ on $\{F>m_*+\zeta\}$, and $\int e^{-a|\Lambda w|^2/(2\sigma^2)}=(2\pi\sigma^2/a)^{P/2}/\det\Lambda$. ✓
- Margin: with $a=\zeta/(4(n/c+\zeta))$, sympy gives $(1-a)(m+\zeta)-m-\zeta/4-\zeta/2=0$ at $m=n/c$, with derivative $-c\zeta/(4c\zeta+4n)<0$ in $m$. So the margin $\ge\zeta/2$ holds for every $m_*\le n/c$, with equality at the worst case, and the ratio is $\le C(\sigma)e^{-\zeta/(4\sigma^2)}$, uniformly in $S$. ✓

**Theorem 4.**

- Gibbs: $\mathbb E\Phi\le\sup_{\mathcal N_1}\Phi+4\Pi_\sigma(\mathcal N_1^c)$. ✓
- Posterior mean: Jensen at each $(x,y)$, then Tonelli. ✓
- $\sigma_0$ depends only on $(d,H,N,n,c,\epsilon')$. ✓

### 2.13 Remark 7 (critical-exponent window)

- $m=\lfloor n^\alpha\rfloor\ge n^\alpha/2$ and $H+L=2L-1$, so $\eta\le(\tanh1)^{-H}2^Hn^{-\alpha(2L-1)}((n+1)/L)^{L/2}$. ✓
- I re-derived `../research-notes/B-tempered-likelihood.md` Lemma 9.2: the chain has all weights in $[-B,B]$, zero first-layer bias, and $v\le B$ iff $Gt_H\ge1$, which follows from $t_\ell\ge(\tanh1)^\ell\min\{1,G^{\ell-1}B\delta_0\}$. ✓
- $\log_{10}\eta$ changes sign across $L/(2(2L-1))$ for $L=2,3,4,8$ ($n$ up to $10^{300}$; `transition_check.out` (c)).
- The window $[0.25,0.333]$ at $L=2$ and $[0.25,0.3]$ at $L=3$ is right, and $L/(4L-2)$ decreases to $1/4$. ✓

### 2.14 Remark 8 (the closing sentence)

**Success side.**

- With $N,d\le n$, the argument of $\Lambda_N$ is $O_H(n^{3+H/2})$, so $\Lambda_N=O_H(\ln n)$. ✓
- $\Lambda_N\ge\ln2n$ (the argument exceeds $2n$) and $P_N\ge(H-1)N^2$, so $\mathrm{Dev}_N\ge4$ once $N\ge N^*=\sqrt{2n/((H-1)\ln2n)}$. ✓ Numerically, $\mathrm{Dev}(N^*)\approx7.1$ and $\mathrm{Dev}(N^*/2)\approx3.5$ ($H=2$, cube family).
- The largest $N$ with $\mathrm{Dev}\le0.1$ is $\approx0.020\sqrt{n/\ln n}$ (`transition_check.out` (b)).

**Failure side**, imported from `../research-notes/A-tight-conditioning-fails.md` Theorem 4.4:

- $N_0=\lfloor64\ln2\cdot d(d+1)\min\{n,2^d\}/a^2\rfloor+1$ matches `../research-notes/A-tight-conditioning-fails.md` Lemma 2.1. ✓
- The limit $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2$ at fixed $a$ follows from (4.3), since $c(K_{\rm mem}+t)/M\to0$. ✓ Recomputed:
  - $a=1/2$: certified excess $0.0385$ at $d=100$, with $N_0\approx180\,n\log_2^2n$;
  - $a=0.1$: $0.3556$.
- "With probability at least $1-\delta$" matches the event $\mathcal E$ of Theorem 4.4. ✓

**One overstatement:** "The full excess $\beta(\lambda)-o(1)$ needs $a\to0$, and then $N_0=O(n^{5/3}\log^2n)$." See issue 1.

---

## 3. Issues

All are minor. None affects the corrected clause.

1. **Minor. Location:** Remark 8, "Failure" bullet, last sentence.
   - **Problem.** It reads "The full excess $\beta(\lambda)-o(1)$ needs $a\to0$, and then $N_0=O(n^{5/3}\log^2n)$ (`../research-notes/A-tight-conditioning-fails.md` Corollary 4.5)." The bound $n^{5/3}$ belongs to Corollary 4.5's particular schedule $a_d=2^{-d/3}$, but the sentence reads as what the full excess *needs*. In `../research-notes/A-tight-conditioning-fails.md` Theorem 4.4, $\epsilon=c(K_{\rm mem}+t)/M+\lambda a^2\to0$ for **any** $a_d\to0$, because the $9(H+1)/(2a)$ term of $K_{\rm mem}$ is $o(M)$.
   - **Recomputed** (`transition_check.out` (a); $c=1$, $H=2$, $\lambda=1$, $\delta=0.01$). With $a=1/d$ the certified excess is $0.449$, $0.462$ and $0.471$ at $d=40,60,100$, tending to $\beta(1)=0.4848$. The threshold is $N_0\approx4.5\cdot10^5\,n\log_2^2n=O(n\log^4n)$, which equals $3.8\cdot10^{-11}\,n^{5/3}$ at $d=100$.
   - **Consequence.** The full excess is proved at every $N\ge\omega_n\,n\log^2n$, for any $\omega_n\to\infty$; the upper end of the window is $n^{1+o(1)}$ even for the full excess. (The earlier logic report's "the full $\beta(\lambda)$ needs $a=n^{-1/3}$" was also not right.)
   - **Fix.** Write "The full excess $\beta(\lambda)-o(1)$ holds for every schedule $a=a_n\to0$, at $N\ge N_0=O(n\log^2n/a_n^2)$. For example, $a_n=1/\log_2n$ gives $N_0=O(n\log^4n)$; Corollary 4.5's $a_n=n^{-1/3}$ gives $O(n^{5/3}\log^2n)$."

2. **Minor (coverage). Location:** §0 ("Corrected wording for every place in `../research-notes/red-team.md` that cites Proposition 6.1") and §7.3.
   - **Problem.** `../research-notes/red-team.md` line 562 (§8, "E, positive direction for $\gamma>1$ (sketch)") also cites Proposition 6.1: "For $m\le N<T$ … Proposition 6.1 applies if $T\le n^{1/2-\epsilon}$." §7.3 does not list it.
   - **That use is outside the scope of Theorem 1.**
     - It concerns the finite-scale posterior $\mu_{N,\gamma}$ with $c=n^{1-\theta}$. Theorem 1 covers $\mathcal N_1$ in the strong-prior limit.
     - The grid argument needs an energy budget, here $\kappa_N\le n/c+1$, which Lemma B(a) supplies only for near-minimizers of $F_c$. The finite-$\gamma$ posterior has no such automatic bound, and the sketch's concentration set $\{\hat L\le\hat L(g)+\dots\}$ bounds only the training loss.
     - Clipping is also required.
   - **Fix.** Add line 562 to §7.3. Say that Theorem 1(a) applies to any parameter set of energy at most $K$, so the sketch needs, in addition, a posterior energy bound at finite $\gamma$ and clipped predictions. Alternatively, mark that bullet "not covered by Theorem 1". The exponent arithmetic there ($T\le n^{1/2-\epsilon}$ iff $\theta<(\gamma-1)/(2(L-2))$) is right.

3. **Minor. Location:** §7.3, replacement for §2.3 A2.
   - **Problem.**
     - The second replacement sentence ("At learner width $\lceil n^\alpha\rceil$ … $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$ … (Corollary 3(i))") omits the hypothesis $d\le n^\alpha$, which Corollary 3 needs: $\bar E_*\ge d(d+1)\bar B^2$ and $P_N\ge N(d+2)$.
     - The instruction "Replace the two sentences on Proposition 6.1" is ambiguous; only one sentence of A2 names it. The other relevant sentence ("It does not refute 'Bayesian learning at width $n^\alpha$ competes with width-$n^\alpha$ networks', and that statement is true for $\alpha<1/4$") has no weight bound. `../research-notes/B-tempered-likelihood.md` §9 shows that without one the statement is false, so it must be among those replaced.
   - **Fix.** Add "and $d\le n^\alpha$", and name the two sentences explicitly.

4. **Minor (notation).** $\Lambda_N$ means two different things:
   - the diagonal energy matrix (§1, "$\kappa_N(w)=|\Lambda_Nw|^2$"; Lemma F, "$\Lambda=\Lambda_N$", $\det\Lambda$);
   - the logarithm in $\mathrm{Dev}_N$ (§1 "Constants"; Corollary 3 step 4).

   Lemma F and Corollary 3 use the two meanings a page apart. There are smaller clashes too:
   - $U=mB$ versus the weight matrices $U^\ell$;
   - $\eta$ for the perturbation size (Lemma C) versus `../research-notes/B-tempered-likelihood.md`'s $\eta=\delta_0(K/L)^{L/2}$ (Remark 7) versus the brief's regression function $\eta(x)$;
   - $\beta$ for the weight exponent (Corollary 3(ii)) versus $\beta(\lambda)$ (Remark 8).

   **Fix.** Rename the logarithm, for example to $\mathcal L_N$.

5. **Minor (presentation). Location:** Corollary 3(i), and the last paragraph of the proof of (5.2).
   - **Problem.** It says the bound is at most $C_{L,\delta,\alpha,\kappa}n^{-\kappa}$ "for every $\kappa<\frac12-2\alpha$". The corrected clause states the stronger $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$, which is the case $\kappa=\frac12-2\alpha$. It is true, because $n^{\alpha-1/2}\sqrt{\ln2n}=n^{2\alpha-1/2}\cdot n^{-\alpha}\sqrt{\ln2n}$ and $n^{-\alpha}\sqrt{\ln 2n}$ is bounded for $\alpha>0$, but the proof as written proves only the strict-$\kappa$ version.
   - **Fix.** State and prove the $\kappa=\frac12-2\alpha$ form; the constant depends on $\alpha$ through $\sup_n n^{-\alpha}\sqrt{\ln2n}$.

6. **Minor (scope wording). Location:** §5, "In the user's words."
   - **Problem.** It compares with "depth-$L$ tanh networks of width and weights at most $n^\alpha$" and "every data law with labels in $[-1,1]$". The theorem's class is the **repository architecture** (no internal biases; offsets only through the constant input coordinate), and the inputs must lie in $X\subseteq[-1,1]^d$. A reader will take "tanh networks" to include internal biases. Those can be emulated with one extra constant unit per layer, at the cost of width $m+1$ and weights up to about $B/\tanh B$, but the note does not prove this.
   - **Fix.** Add "(of the repository architecture)" and "inputs in $[-1,1]^d$".

7. **Informational (no change needed).**
   - The leading constant $5\sqrt2$ in (5.2) is about $5\times$ the true leading coefficient $\sqrt2$ in case (i) (§2.9).
   - Lemma E(ii)'s linear term could be $b\ell'/(3n)$ (BLM Theorem 2.10).
   - Lemma C's sharper bracket is nearly attained at $H=1$ (ratio $0.92$).
   - §7.1 item 2's "SP$_1$ cannot satisfy such a bound at all widths" should read "cannot have vanishing excess at all widths". Theorem 1's bound is vacuous, so trivially true, at large $N$.

I found no arithmetic or exponent error in Lemmas A–F, Theorem 1, Corollaries 2 and 3, Theorem 4 or Remarks 5–7. Every number quoted from the scripts in §§5 and 8–9 of the note is reproduced by its own script output or by mine.

---

## 4. Corrected statement (strongest version I can support)

The corrected clause of `../research-notes/small-learner-width.md` §0 is supported as stated. With the fixes above:

> Let $c=1$, $L=H+1\ge2$, $0<\alpha<\frac14$, $n\ge2$, $\delta\in(0,1)$, $d\le n^\alpha$, and let $D$ be any law on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact. Run SP$_1$ at learner width $N=\lceil n^\alpha\rceil$. Let $\mathcal G_n$ be the depth-$L$ networks **of the repository architecture** with width at most $N$ and all weights in $[-n^\alpha,n^\alpha]$. With probability at least $1-\delta/2$, every $w\in\mathcal N_1$ satisfies
> $$L_D(\operatorname{clip}z_w)\le\min_{\mathcal G_n}L_D+5\sqrt2\,n^{2\alpha-\frac12}\sqrt{\ln\tfrac4\delta}+4\sqrt{(2H+1)(H+5)}\,n^{\alpha-\frac12}\sqrt{\ln2n}+(8L-1)\bigl(1+\ln\tfrac4\delta\bigr)n^{4\alpha-1}.$$
> The same bound holds, on the same event, for $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk and of the risk of the posterior mean of the clipped outputs. The excess is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$. With Hoeffding's inequality in place of Bernstein's, as in the original display, it is polynomially small only for $\alpha<1/8$. The rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ is not established.

**Width transition** ($L\ge3$, $c=1$, clipped predictions):

- Success against any fixed competitor, for every $D$, is proved for $N(N+d)\ln n=o(n)$, for example $N=o(\sqrt{n/\ln n})$ on the cube family. The method stops at $N\approx\sqrt{2n/((H-1)\ln2n)}$.
- Failure on the cube family is proved at every $N\ge O(n\log^2n/a^2)$, with excess $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2-o(1)$. The full excess $\beta(\lambda)-o(1)$ already holds at $N\ge\omega_nn\log^2n$, for any $\omega_n\to\infty$; it does not need $n^{5/3}$.
- Nothing is proved in between.

---

## 5. Scripts (`../checks/verify-RT-width-computation-revised/`)

| script | checks | result |
|---|---|---|
| `bound_check.py` → `.out` | (1) exact $\mathrm{Exc}$ (5.1) against (5.2): random search ($H\le40$, $n\le10^{300}$, $\delta\in[10^{-12},0.999]$) and Nelder–Mead; (2) each proof step of (5.2); (3) $\Lambda_N$ bounds; (4) slopes and the thresholds $1/8$ and $1/4$; (5) clause against exact $\mathrm{Exc}$ | (1) maxima $0.691$ and $0.671$; (2) steps 1–3 attained (ratio 1), steps 4 and 5 at most $0.595$ and $0.758$; (3) $0.631$; (4) table in §2.10; (5) ratio $\to0.200$ |
| `perturb_adv.py` → `.out` | Lemma C: adversarial maximization of $\lVert\nabla_wz_w(x)\rVert_1$ over $\{\kappa_N\le K\}\times[-1,1]^d$; finite perturbations $\eta\le5$ | at most $0.919$ of the sharper form, $0.740$ of the closed form; finite $0.839$ |
| `lemmas_check.py` → `.out` | (A) clones at the worst widths with extremal weights; (D) grid count and radius in exact arithmetic; (E) Bernstein and Hoeffding against exact binomial tails (24,000 cases); (6b) Remark 6(b) quantiles | (A) $\kappa/E_*\le0.969$, first-layer bound attained; (D) no violation, radius $\eta/2$; (E) $0.19$, $0.59$; (6b) table reproduced |
| `transition_check.py` → `.out` | Remark 8: `../research-notes/A-tight-conditioning-fails.md` Theorem 4.4 certified excess and $N_0$ under several schedules $a_d$; the point where $\mathrm{Dev}_N\ge4$; Remark 7 sign change | full excess with $a=1/d$ at $N_0=O(n\log^4n)$; $\mathrm{Dev}(N^*)\approx7.1$; sign change confirmed |
| `symbolic_check.py` → `.out` | sympy: Lemma E roots, Lemma F margin, every constant of Corollary 3, Remarks 5 and 7 | all identities hold |
