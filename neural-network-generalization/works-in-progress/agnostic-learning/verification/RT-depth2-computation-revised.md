# Referee report (computation lens, revision round 1): depth two, `../research-notes/depth-two.md`

**What was refereed.**

- Theorem 5.1, Corollary 5.2 and Proposition 5.3 of `../research-notes/depth-two.md`.
- Every lemma they use, in the form restated and re-proved in its §2: Lemma 1.0(1), Lemma 1.1, Lemma 1.2, Lemma 1.3 and the depth-two Lemma 2.1. I compared each with `../research-notes/red-team.md` §1, §2.1 and §5.
- Remarks 5.4–5.8, the §0 summary and scope table, the §6 errata, and the numerical claims of §4, §5, §7 and §8, because the final note will cite them.
- For the remarks, the cited sources: `../research-notes/red-team.md` Theorem 3.2 and Proposition 6.1, `../research-notes/B-tempered-likelihood.md` §1, Lemma 5.3 and Proposition 6.1, `../research-notes/A-tight-conditioning-fails.md` Propositions 5.2 and 8.2, and the width referees' verdicts on RT Proposition 6.1.

**Lens.** Computation.

- I re-derived by hand every constant, exponent, energy bound, probability estimate and concentration inequality.
- I checked them numerically with scripts written independently of the authors'. They use their own binomial evaluation, their own Sylvester–Hadamard matrices (built by Kronecker products), their own build of Lemma 2.1, and exact rational enumeration for Lemma 1.3.
- The scripts and outputs are in `../checks/verify-RT-depth2-computation-revised/` (Appendix).

**Abbreviations.** $M=2^d$, $n=\lceil\lambda M\rceil$, $\lambda'=n/M$, $\vartheta_c=1/(18dc+1)$, $F_d=1+(d+1)(d+2)^2$, $h_d=2n^{2/3}/M$, $\varepsilon_d=\gamma(\lambda)\vartheta_c^2/3$.

---

## Verdict: minor fixes

1. **Theorem 5.1 is correct.** Every step re-derives:
   - the memorizer energy $\kappa_N(w_t)\le dF_d+18dt^2Q$;
   - the residual $\mathcal R(tg)\le(1-t)^2G+nta$ for $a\le4$;
   - the bracket minimum $1-\vartheta_c$ at $t=\vartheta_c$;
   - the budget $\mathcal R_{\max}=(1-\vartheta_c)G+c(dF_d+1)+\vartheta_cna$;
   - both lower bounds $\Psi_{\rm tri}$ and $\Psi_{\rm cor}$;
   - the strong-prior transfer, uniform in the sample.

   I found no arithmetic or exponent error.
2. **Corollary 5.2 is correct.**
   - $\underline\Psi_d$ is the correct worst case on the event of Lemma 1.3, and the four monotonicity claims hold.
   - Regimes (i)–(iv) and consequences (a)–(c) follow, and $\Gamma_\lambda$ is as stated.
   - All 40 numbers I recomputed reproduce: the $c=1$ values, the 15-entry small-$c$ table, the $\Gamma_1$ table, the branch crossing and vanishing point, and the widths.
3. **Proposition 5.3 is correct.**
   - The Hadamard construction is exact: $z=\tau^{-1}\tanh(\tau u\cdot x)$, $\kappa_N=\tau^2Q+\tau^{-2}=2\sqrt Q$, error $\le\tau^2\lvert\bar y\rvert^3/3\le\tau^2/3$, at every width $N\ge1$.
   - Both rates hold: the limit $\beta(1-\sqrt{2\nu/\sqrt\beta})^2$, and $\beta-4\sqrt c\,M^{-1/4}-O_\lambda(M^{-1/3})$.
   - Remark 5.4 (unit ball) reproduces.
4. **Six minor issues and one note** (§7). None changes a theorem or a regime:
   - one table entry is misrounded ($0.016$ should be $0.015$);
   - one sentence in the errata rounds two lower bounds up ("at least 0.40/0.58" against measured $0.396/0.578$);
   - one proof step uses "$Q^+\le2M$", which needs $M$ large;
   - the rest are wording and scope: Lemma 1.2 is worded "in the cube example" but is applied to the Hadamard atoms; the fixed-$d$ row's $O(2^d/n)$ needs bounded $c$; and "tends to 0" in Cor. 5.2(b) is an iterated limit.

### Answers to the focus questions

| Question | Answer |
|---|---|
| Theorem 5.1: excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$, $\gamma(1)=0.0999$ | **Correct.** $\gamma(1)=0.09989410$. The $(1-o(1))$ is uniform over $c\in(0,d^k]$. With $a_d=1/d$ it is $1-\Theta(1/d)$: the ratio to $\gamma\vartheta_c^2$ is $0.9686$ at $d=100$ and $0.9921$ at $d=400$ for every $c=d^k$, $k\le3$ (`t51_r1.out` (4)). |
| Corollary 5.2: refutes the polynomial-sample inequality for $c\le\mathrm{poly}(d)$, "but not the $+o(1)$ formulation" | **First half correct.** The second half holds **only when $c\log n\to\infty$**, which is how the revision states it (Cor. 5.2(c), (iv)). For $c\le\nu/\log_2n$ the revision proves that the $+o(1)$ formulation, uniform over $d\le\log_2n+C_0$, is refuted with constant excess $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ when $c\log n\to0$. I confirm this. The phrase "but not the $+o(1)$ formulation" must not be cited without the restriction $c\log n\to\infty$. |
| Proposition 5.3: $d=M$, $c=o(\sqrt M)$, excess $\ge\beta(\lambda)-o(1)$ at every $N\ge1$ | **Correct**, for inputs of norm $\sqrt d$. The $o(1)$ is $\le4\sqrt c\,M^{-1/4}+CM^{-1/3}$, and $C=2.07$ suffices at $\lambda=1$ on my grid. |
| Energy of the depth-two memorizer | **Correct.** First layer $\le dF_d$, readout $\le2t^2A_0^2=18dt^2Q$. Explicit width-$N$ builds at $d=6$ give $\kappa_N(t=1)=1498.7$ against the bound $5670$; at $d=4$ an arbitrary $r$ was used. |
| Bracket minimization | **Correct.** $\min_t[\alpha t^2+(1-t)^2]=\alpha/(1+\alpha)$ at $t=1/(1+\alpha)$; with $\alpha=18dc$, $t=\vartheta_c\in(0,1]$. |
| Limits | **Correct**: both the $d\to\infty$ limits of Cor. 5.2 and the $\sigma\downarrow0$ limits of Theorem 5.1(3), which rest on Lemma 1.1 being uniform in $S$. |
| Hadamard construction | **Correct**: $\kappa_N=\frac dN N\tau^2\lVert u\rVert^2+N\cdot N(N\tau)^{-2}=\tau^2Q+\tau^{-2}$ using $d=M$, and $\lvert z(\xi_l)-\bar y_l\rvert\le\tau^2/3$. Verified in 54 configurations; the largest ratio of error to $\tau^2/3$ was $0.9912$. |

---

## 1. What was checked

| Item | Check | Result |
|---|---|---|
| $\beta(1)$, $\gamma(1)$, maxima | series vs Ei form; golden-section maximisation | $\beta(1)=0.484829107$; $\max\beta=0.51735144$ at $1.502861$; $\gamma(1)=0.09989410$; $\max\gamma=0.10181609$ at $1.2564312$, where $e^\lambda-1-2\lambda=2\cdot10^{-25}$ ✓ |
| (1.0) $4\gamma\le\beta<1-e^{-\lambda}$ | Cauchy–Schwarz re-derived; log grid $\lambda\in[10^{-4},60]$ | min $\beta/(4\gamma)=1.000025$ (it tends to $1$ as $\lambda\to0$); $1-e^{-\lambda}-\beta>0$ ✓ |
| $\Gamma_1$ table, crossing, zero | direct evaluation | $0.484829,0.348779,0.148821,0.027671,0.024974,0.012742,0.000277$; crossing $\nu=0.0389937$; tri-branch zero $\nu=0.182868$; nonincreasing on $[0,2]$ ✓ |
| Le Cam: $\lvert\beta_d-\beta(\lambda)\rvert,\lvert p_d-(1-e^{-\lambda})\rvert\le(\lambda'+1)/M$ | exact binomial, $d\le24$, $\lambda\in\{0.5,1,1.5,3\}$ | worst ratio to the bound $0.16$ ✓ |
| Lemma 1.3 moments and bounded differences | exact rational enumeration of all inputs and labels, $(M,n)\in\{(3,4),(4,5),(2,6),(5,4)\}$ | $\mathbb E\Sigma_1=M\beta_d$, $\mathbb Es=Mp_d$, conditional means and variances of $Q,G$ exact, $\mathbb EV=n$, $\mathrm{Var}V=2n(n-1)/M$ exact; true bounded differences $3/2$ ($\Sigma_1$) and $1$ ($s$), within the claimed 2 ✓ |
| Lemma 1.1 scalar steps | grid | $\sup_t(1+t)e^{-st}\le\max\{1,1/s\}$ (ratio $\le1.000000$); the choice of $\varrho$ works for every $m_*\le n/c$ ✓ |
| Lemma 2.1 | independent explicit build; $d=6$ with $r=\bar y\mathbf 1_T$, $a\in\{1,0.7\}$; $d=4$ with arbitrary $r$; $N=2m_0+3$; $t\in\{0.2,\vartheta_c,1\}$; $c\in\{1,0.01,d^{-3}\}$ | exact mixture to $10^{-10}$; $\sum\lvert\hat r\rvert\le\lVert r\rVert_2$ (ratio 0.766); mass/$A_0$ = 0.25–0.34; rows $<F_d$; first Hoeffding draw always succeeded; output $=tg$ to $10^{-9}$; energy bound; (1.1) on the raw sample; residual; objective chain ✓ |
| Parity coefficients | identity $\sum_{i\le t}(-1)^i\binom qi=(-1)^t\binom{q-1}t$ for $q<40$; $u_m\ge1/(2\sqrt m)$ for $m\le10^5$ | ✓ (the minimum of $2\sqrt m\,u_m$ is $1$, at $m=1$) |
| Theorem 5.1 / Cor. 5.2 numbers | my own $\underline\Psi_d$ from the §4 formulas, $d=1..1000$ | every $c=1$ claim, the 15-entry small-$c$ table and the widths reproduce ✓ |
| Prop. 5.3 | own Kronecker Sylvester matrices, $M\in\{8,32,128,512,2048,4096\}$, $\lambda\in\{0.5,1,2\}$, $N\in\{1,2,5\}$ | all identities ✓; table ✓ except one rounding (Issue 1) |
| Remark 5.4 | unit-ball rows $(0,\tau\sqrt d\,u)$ | cost $\tau^2MQ+\tau^{-2}$ exact; limits $0.0025$, $0.1044$, $0.3344$ at $c=0.3,0.1,0.01$; threshold $0.3481$ ✓ |
| Remarks 5.5, 5.7 | sympy instantiation of RT Prop. 6.1 and of ../research-notes/B-tempered-likelihood.md Prop. 6.1 with Lemma 5.3(a) | both displays match exactly (difference $0$) ✓ |

---

## 2. The lemmas

### 2.1 Lemma 1.0(1)

$\lvert z_w\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2\le\sqrt{\kappa_N}$, and $\sqrt{\kappa_N}\le1+F$ is used for integrability. ✓

### 2.2 Lemma 1.1

- **(i)** $m_*\le F(0)=c^{-1}\sum y_i^2\le n/c$. ✓
- **Pointwise bound.** $\sup_{t\ge0}(1+t)e^{-st}$ equals $1$ for $s\ge1$ and $s^{-1}e^{-(1-s)}\le1/s$ for $s<1$. This gives $(1+t)e^{-t/2\sigma^2}\le(1+2\sigma^2/\varrho)e^{-(1-\varrho)t/2\sigma^2}$. ✓
- **Split on $\{F>m_*+\zeta\}$.** The split and the Gaussian integral $(2\pi\sigma^2/(\varrho(1-\varrho)))^{P/2}/\det\Lambda$ are correct. ✓
- **Choice of $\varrho$.** $\varrho=1-\sqrt{(n/c+\zeta/2)/(n/c+\zeta)}$ works, and the map $m\mapsto(1-\varrho)^2(m+\zeta)-m-\zeta/2$ is decreasing. ✓
- **Denominator.** The open ball $B(w_*,r_0)$ lies in $K_1$, and $F$ is $\mathrm{Lip}_1$-Lipschitz on it, so the ball lies in $\{F<m_*+\zeta/4\}$. $\mathrm{Lip}_1$ is uniform in $S$ because $\lvert y_i\rvert\le1$ and $X$ is compact. ✓
- **Ratio exponent.** $-(1-\varrho)^2(m_*+\zeta)+m_*+\zeta/4\le-\zeta/4$, which gives $e^{-\zeta/(8\sigma^2)}$. ✓
- **(iii)** Both inequalities are correct. With $b_0=0$ and $b_1=c$, the error term is $c\,\epsilon_\sigma$. ✓

### 2.3 Lemma 1.2

- **(1.1).** Within/between decomposition. ✓
- **Clipping.** Clipping is the projection onto $[-1,1]\ni\bar y_x$. ✓
- **(a).** Triangle inequality in $\ell^2(T)$, with $\sum_T(f-\bar y)^2\le\mathcal R(f)$ because $k_x\ge1$. ✓
- **(b).** $\mathcal R(f)=\sum_Tk_xf^2-2\sum_xfS_x+G$, so $B<G$ forces $\sum fS>0$, hence $V>0$; then Cauchy–Schwarz. ✓
- **Numerics.** The authors' 3000-instance exact-minimum check (`lemma_checks.out` (A)) reproduces. The max ratios of bound to true minimum are $1.0000$ (tri) and $0.9999$ (cor), so both bounds are essentially tight in some instances.

### 2.4 Lemma 1.3

- **McDiarmid.** Bounded differences $\le2$ (true values $3/2$ and $1$, by enumeration). At $t=n^{2/3}$, $2e^{-2t^2/(4n)}=2e^{-n^{1/3}/2}$. ✓
- **Label moments.** $\mathbb ES^4=3k^2-2k$, so $\mathrm{Var}(S^2)=2k^2-2k$. Then $\mathrm{Var}(Q\mid x)=\sum_T(2k^2-2k)/k^4\le2s$ and $\mathrm{Var}(G\mid x)=\sum_T(2k^2-2k)/k^2\le2s$. All exact by enumeration. ✓
- **$V$.** $\mathrm{Var}(V)=2n(n-1)/M$, exact. Chebyshev at $n^{2/3}$ gives $2(n/M)n^{-1/3}$. ✓
- **Total failure probability.** $4e^{-n^{1/3}/2}+(4+2n/M)n^{-1/3}$. ✓
- **Poisson comparison.** Le Cam gives $d_{TV}\le n/M^2=\lambda'/M$ (half the $\ell^1$ form $2\sum p_i^2$). The coupling bound gives $d_{TV}(\mathrm{Poi}(\lambda'),\mathrm{Poi}(\lambda))\le1-e^{-(\lambda'-\lambda)}<1/M$. The test functions take values in $[0,1]$. ✓

### 2.5 Lemma 2.1 (depth two)

- **Step 1.** Parseval plus Cauchy–Schwarz over $M$ coefficients. ✓ Measured $\sum\lvert\hat r\rvert/\lVert r\rVert_2=0.766$ at $d=6$.
- **Step 2.**
  - $\mathfrak c_{2m+1}=(-1)^m\binom{2m}m4^{-m}$ and $\mathfrak c_{2m}=(-1)^{m-1}\binom{2m}m4^{-m}$, using $\binom{2m-1}{m-1}=\binom{2m}m/2$. ✓
  - $u_m/u_{m-1}=(2m-1)/(2m)\ge\sqrt{(m-1)/m}$, so $u_m\ge1/(2\sqrt m)$ and $\lvert\mathfrak c_k\rvert\ge1/\sqrt{2k}$. ✓
  - $1-\tanh\alpha_d<2e^{-2\alpha_d}\le1/(2\sqrt{2d})$. The case $\alpha_d=1$ occurs only at $d=1$, where $2e^{-2}=0.271\le0.354$. ✓
  - Rows have $\alpha_d^2(b_k^2+k)\le(d+2)^2(d+1)<F_d$, and the total mass is $\le\max\{2\sqrt{2d},1/\tanh1\}\lVert r\rVert_2\le A_0$. ✓
- **Step 3.** Hoeffding at deviation $a/2$ with range $2A_0$ gives exponent $m_0a^2/(8A_0^2)$, and $m_0>8A_0^2\ln(2M)/a^2$ makes the union bound $<1$. ✓
- **Steps 4–5.** $k_l\ge\lfloor N/m_0\rfloor\ge N/(2m_0)$. The readout energy is $\frac{Nt^2A_0^2}{m_0^2}\sum_l k_l^{-1}\le2t^2A_0^2$. ✓ Measured $\kappa_N(t=1)=1498.7\le5670$ at $d=6$.

---

## 3. Theorem 5.1

- **Width.** $m_0=\lceil72dQ\ln(2M)/a^2\rceil+1\le N_0(a)$ since $Q\le n$. $N_0(1/n)\le72dn^3\ln(2M)+2$ and $N_0(1/d)=\lceil72d^3n\ln(2M)\rceil+1$. ✓
- **Residual.** $(te-(1-t)\bar y)^2\le(1-t)^2\bar y^2+t(1-t)a\lvert\bar y\rvert+t^2a^2/4$. Summing with weights $k_x$ (total $n$) gives $(1-t)^2G+nt[(1-t)a+ta^2/4]\le(1-t)^2G+nta$ iff $a\le4$. ✓ The authors' 20000-instance check (`lemma_checks.out` (B), max excess $0$) reproduces, and my explicit networks satisfy it.
- **Objective and bracket.** $cF-W=c\kappa_N+\mathcal R$ (verified on the raw sample, not only through $\mathcal R$). Then $Q\le G$ and the bracket minimum give $cF(w_{\vartheta_c})-W\le c\,dF_d+(1-\vartheta_c)G+n\vartheta_ca$. ✓
- **Budget on $\mathcal N_1$.** The near-minimizer slack $+1$ in $F$ is $+c$ in $cF$. So $\mathcal R(z_w)\le\mathcal R_{\max}$, and $E_0=c(dF_d+1)+\vartheta_cna$. ✓ RT's $E_0=c(dF_d+1)+2$ is recovered at $a=1/n$, since $\vartheta_c\le1<2$.
- **Lower bounds.** $\Psi_{\rm tri}=(\sqrt Q-\sqrt{\mathcal R_{\max}})_+^2/M$ and $\Psi_{\rm cor}=(\vartheta_cG-E_0)_+^2/(4MV)$, from Lemma 1.2(a),(b) with $B=\mathcal R_{\max}$ and $G-B=\vartheta_cG-E_0$. ✓
- **Part 3.**
  - Choosing $\epsilon_\sigma\le\eta\min\{1,1/c\}$ gives $\Pi_\sigma(\mathcal N_1^c)\le\eta$ and $c\epsilon_\sigma\le\eta$. ✓
  - Jensen applies, since $\mathcal R$ is convex in $(f(x))_{x\in T}$ and $\lvert z_w\rvert\le1+F$ is integrable. Clipping does not increase $\mathcal R$. ✓
  - $\Psi(\eta)$ is continuous in $\eta$. When $V=0$, $G=0$ and the cor branch is identically 0. ✓

---

## 4. Corollary 5.2

- **Worst case on $\mathcal E_d$.** $Q/M\ge\beta_d-h_d$, $G/M\in[p_d-h_d,p_d+h_d]$ and $V/M\le\lambda'+h_d/2$. $\Psi_{\rm tri}$ is nondecreasing in $Q$ and nonincreasing in $G$; $\Psi_{\rm cor}$ is nondecreasing in $G$ and nonincreasing in $V$. So $\Psi\ge\underline\Psi_d$. The formulas for $\underline\Psi_{\rm tri}$ and $\underline\Psi_{\rm cor}$ are exactly $\Psi_{\rm tri},\Psi_{\rm cor}$ divided by $M$, with $E_0/M=c(dF_d+1)/M+\vartheta_c\lambda'a$. ✓
- **(i).** $c(dF_d+1)/(M\vartheta_c)=c(18dc+1)(dF_d+1)/M$ increases in $c$, so the $o(1)$ is uniform over $(0,d^k]$. ✓ First $d$ at which the ratio to $\gamma\vartheta_c^2$ reaches $2/3$, with $a=1/d$: $34,47,61,77$ for $c=d^0,d^1,d^2,d^3$.
- **(ii).** The four substitutions are monotone in the right direction, including $c(dF_d+1)\le\nu(F_d+1)$. The limits are $\gamma\vartheta_\nu^2$ and $(\sqrt\beta-\sqrt{(1-e^{-\lambda})(1-\vartheta_\nu)})_+^2$. ✓ At $c=\nu/d$ the explicit bound converges to $\Gamma_1(\nu)$ from below: for $\nu=0.05$ it is $0.0275$ at $d=30$ and $0.0277$ at $d\ge60$. ✓
- **(iii).** $\nu\downarrow0$ with continuity, and $\Gamma_\lambda(0)=\max\{\gamma,\beta\}=\beta$ by (1.0). ✓
- **(iv).** $\Psi_{\rm cor}\le\vartheta_c^2n^2/(4M(n-n^{2/3}))\to0$, and $(1-\vartheta_c)(p_d-h_d)\to1-e^{-\lambda}>\beta$ makes $\Psi_{\rm tri}=0$. ✓
- **(a)–(c).**
  - $\varepsilon_d<1$ because $\gamma\le0.102$.
  - In (R1), $\rho_n<(1-\delta)/2$ and $\eta=(1-\delta)/2$ give a sum $<1-\delta$.
  - In (b), $dc_d\le\nu d/(d+\log_2\lambda)\to\nu$, and $C_0\ge\log_2(1/\lambda)$ gives $d\le\log_2n+C_0$.
  - All three steps check. ✓
- **Numbers.** Recomputed with my own binomial evaluation:
  - **$c=1$, $a=1/n$.**
    - The bound is $0$ for every $d\le29$ (checked from $d=1$). The tri branch is $0$ for all $d\le1000$.
    - $1.9285\cdot10^{-8}$ at $d=30$; maximum $2.2584\cdot10^{-7}$ at $d=35$; $8.5484\cdot10^{-8}$ at $d=60$.
    - First $d$ with bound $\ge2\varepsilon_d$: $33$, and no failure on $[33,1000]$. The minimum ratio is $0.718483$, at $d=33$. ✓
  - **Small-$c$ table.** All 15 entries match to 4 decimals: $0.0003$; $0.0275/0.0277/0.0277$; $0.0430/0.0988/0.2189$; $0.3403/0.4099/0.4616$; $0.2328/0.3090/0.3889$. ✓
  - **Widths.** $N_0(1/n)=5.746\cdot10^{31}$ and $N_0(1/d)=4.485\cdot10^{16}=4.177\cdot10^7\,n$ at $d=30$. ✓

---

## 5. Proposition 5.3 and Remark 5.4

- **Identities.** $u\cdot\xi_l=\bar y_l\mathbf 1_T(l)$ and $\lVert u\rVert^2=Q/M$ (verified as exact).
  - $\kappa_N=\tau^2Q+\tau^{-2}=2\sqrt Q$ at $\tau^2=Q^{-1/2}$.
  - $\lvert\tanh s-s\rvert\le\lvert s\rvert^3/3$ holds for all real $s$: the derivative of $\tanh s-s+s^3/3$ is $s^2-\tanh^2s\ge0$. On a grid of $[-20,20]$ the maximum ratio is $1$, attained only as $s\to0$.
  - $\mathcal R\le n\tau^4/9=n/(9Q)$, and $z=0$ off $T$.
  - The budget is $c(2\sqrt Q+1)+n/(9Q)$.
  - All of this holds at $N\in\{1,2,5\}$ and $\lambda\in\{0.5,1,2\}$, for $M$ up to $4096$. ✓
- **Part 2.**
  - The limit for $c\le\nu\sqrt M$ is $\beta(1-\sqrt{2\nu/\sqrt\beta})^2$. Indeed $\sqrt{2\nu\sqrt\beta}=\sqrt\beta\sqrt{2\nu/\sqrt\beta}$, and the limit is positive iff $\nu<\sqrt\beta/2=0.3481$. ✓
  - The inequality $(\sqrt q-r)_+^2\ge q-2r$ for $q\le1$ also holds in the case $\sqrt q<r$. ✓
  - The rate $\beta-4\sqrt c\,M^{-1/4}-CM^{-1/3}$ holds on my grid ($M=2^8..2^{120}$, $c\in[1/M,\sqrt M]$, $\lambda=1$) with $C=2.07$. ✓
- **Table** (worst case on $\mathcal E_M$, $\lambda=1$).
  - $c=1$: $0.0931,0.2794,0.4157,0.4738,0.4830,0.4848$. ✓
  - $c=0.1\sqrt M$: $0.01549,0.06187,0.09301,0.10326,0.10429,0.10441$, with limit $0.1044$. ✓ The first entry is printed as $0.016$ (Issue 1).
- **Remark 5.4.**
  - The unit-ball cost $\tau^2MQ+\tau^{-2}$, minimised at $2\sqrt{MQ}$, is checked exactly.
  - The limits are $0$ ($c\ge0.5$), $0.0025$ ($c=0.3$), $0.1044$ ($c=0.1$) and $0.3344$ ($c=0.01$). ✓
  - The row map $(\omega_0,\omega_{1:d})\mapsto(\omega_0,\sqrt d\,\omega_{1:d})$ has squared norm $\le d\lVert\omega\rVert^2$. So the first-layer energy is $\le d^2F_d$, and the asymptotics of Cor. 5.2 survive. ✓

---

## 6. Remarks 5.5–5.8 and errata

- **Remark 5.5.** RT Prop. 6.1 at $L=2$ with $m=B=1$: $U=1$, $E_*=d^2+d+2$, $K=d^2+d+3+4n/c$ and $P_N=N(d+2)$. The display matches exactly (sympy difference $0$).
  - RT Thm 3.2 requires $B\ge1$, so $B=1$ is the right instantiation.
  - Both width referees confirmed the display (`RT-width-computation.md` §2, `RT-width-logic.md` §2).
  - "Tends to 0 iff $N=o(n/\log^2n)$, for $n^{-O(1)}\le c\le\mathrm{poly}(d)$" follows: the grid term is $\Theta(\sqrt{N(d+2)\log n/n})$. ✓
- **Remark 5.7.** ../research-notes/B-tempered-likelihood.md Prop. 6.1 with Lemma 5.3(a) at $H=1$, $\delta'=\delta/2$, $K=n/c+1$, $U=1$ gives exactly $c(d^2+d+3)/n+8D_n\sqrt{1/c+1/n}+8\sqrt{\ln(2/\delta)/(2n)}$ (sympy difference $0$).
  - $D_n=\Theta(d)$ along the family.
  - The unclipped main term is $4(\sqrt K+1)\sqrt KD_n/\sqrt n\approx4D_n\sqrt n/c$, so $c\gg\sqrt n\log n$ is needed. ✓
- **Remark 5.8.** A.r1 Prop. 8.2(a) at $H=1$ gives $K\ge(1-a)^2s/(2\ln2\,(d+1)^2)$, of order $s/d^2$. ✓ A network of energy $\mathrm{poly}(d)+Ct^2G$ would give $\vartheta=1/(1+cC)$, which is bounded below for fixed $c$. ✓
- **Errata.** "$\approx0.0999/(18d+1)^2$ at $c=1$, $\lambda=1$" ✓. The numerics bullet rounds its lower bounds up (Issue 2).

---

## 7. Issues

1. **(minor, numerical) §5, table after Proposition 5.3, row $c=0.1\sqrt M$, column $M=2^{10}$.**
   - *Problem.* It prints $0.016$, but the value is $0.01549$. `prop53_check.out` prints $0.0155$; my recomputation gives $0.01549$. So the correct 3-decimal value is $0.015$; the error is a double rounding.
   - *Fix.* Print $0.015$.
2. **(minor, numerical; erratum text the note will cite) §6, replacement for RT §0 item 6, "Numerics" bullet.**
   - *Problem.* The bullet says "low-objective networks absorb at least 0.40 of the noise at $d=8$ and at least 0.58 at $d=10$". The recorded captured fractions are $\phi=0.396$ (`scripts/` run at $d=8$, re-run in `verify_RT_depth2_computation_scripts/rerun_d8_L2_c1.txt`) and $\phi=0.578$ (`scripts/run_d10_L2.txt`).
     - Here $\phi=1-c(F-W/c)/G$: $1-93.51/154.8=0.3959$ and $1-267.75/634.1=0.5777$.
     - So "at least" with values rounded **up** overstates both. Every network whose objective is at most the found one's satisfies $\mathcal R\le(1-\phi)G$, so it absorbs at least $0.3959$ and $0.5777$ respectively.
     - Read as a guarantee for every point of $\mathcal N_1$, the fraction is $\phi-c/G=0.389$ and $0.576$, because of the $+1$ slack.
   - *Fix.* Write "at least 0.39 at $d=8$ and at least 0.57 at $d=10$" for networks at least as good as those found. For every near-minimizer, write "at least 0.38 and 0.57". Alternatively write "0.396 and 0.578 for the networks found".
3. **(minor, proof step) Proposition 5.3 proof, "Part 2, quantities on the event": "$Q^+\le2M$".**
   - *Problem.* $Q^+=M\beta_d+2n^{2/3}\le2M$ requires $2n^{2/3}\le(2-\beta_d)M$, which holds only for $M$ large depending on $\lambda$. It is used in the case $c\le\sqrt M$.
   - *Fix.* Use $Q\le s\le M$, which always holds. Then $2\sqrt Q+1\le3\sqrt M$, so $\sqrt{\mathcal R^{\rm H}_{\max}/M}\le\sqrt3\sqrt c\,M^{-1/4}+O(M^{-1/2})$ and the constant $4$ improves to $2\sqrt3\approx3.46$. The asymptotic statements are unchanged.
4. **(minor, presentation) Lemma 1.2(a),(b) are stated "In the cube example", but Proposition 5.3 applies them to the Hadamard atoms.**
   - *Problem.* Both parts are deterministic: they hold for any finite atom set, with $\sum_xf(x)^2$ over the atoms and the §1.3 notation. The proof of Proposition 5.3 implicitly relies on this.
   - *Fix.* State Lemma 1.2(a),(b) for a general finite atom set.
5. **(minor, scope precision) §0.2, last row: "at fixed $d$ its excess is $O(2^d/n)$ at every width (../research-notes/A-tight-conditioning-fails.md Prop. 5.2)".**
   - *Problem.* A.r1 Prop. 5.2(c) gives excess $\le(8M/\delta'+4ct)/n$ with probability $\ge1-\delta'-Me^{-n/(8M)}$, that is, $O((2^d/\delta+c)/n)$. This is $O(2^d/n)$ only for bounded $c$ (and fixed $\delta$). For $c=c(n)\to\infty$ it is $O(c/n)$.
   - *Fix.* Add "for bounded $c$", or quote the full bound.
6. **(minor, quantifier) Corollary 5.2(b): "the probability that the inequality holds tends to 0 at every $N\ge N_0(a_d)$".**
   - *Problem.* Under (R1) the proof bounds this probability by $\rho_n+\eta$ for $\sigma<\sigma_0(\eta;d,n,c,N)$. So it tends to 0 in the iterated limit ($\sigma\downarrow0$ first, then $d\to\infty$), not at a fixed $\sigma$. The next sentence of (b) states this correctly.
   - *Fix.* Write "$\limsup_{\sigma\downarrow0}$ of the probability tends to 0".
7. **(note, not an error) The $c=1$ numbers use $a=1/n$, as §4 says; the corollary recommends $a_d=1/d$.**
   - With $a=1/d$, the $c=1$ bound first reaches $2\varepsilon_d$ at $d=34$, not 33: at $d=33$ it is $1.80\cdot10^{-7}<2\varepsilon_d=1.88\cdot10^{-7}$.
   - Any quotation of "from $d=33$" must keep "$a=1/n$", that is, width $N_0\approx10^{32}$.

Script-level remark, not a document issue: `t1_range.py`'s docstring promises a monotonicity check, and its output lists 68 "decreases" at $d\ge806$. At 200 digits there are none (`t1_mono_r1.out`); they are 80-digit rounding noise, with $1-\text{ratio}\approx10^{-83}$. The document does not use monotonicity.

---

## 8. Strongest correct statement

The revision's statements are correct as written, with the following adjustments.

- **Theorem 5.1** as stated, deterministic, for every $c>0$, $a\in(0,1]$ and $N\ge N_0(a)$.
- **Corollary 5.2** as stated, (i)–(iv) and (a)–(c), with:
  - Issue 6's wording in (b);
  - the $c=1$ quantitative remarks tagged "$a=1/n$" (Issue 7).

  In particular, the polynomial-sample property is refuted for every $0<c\le\mathrm{poly}(d)$. The "$+o(1)$" formulation, uniform over $d\le\log_2n+C_0$, is refuted for $c\le\nu/\log_2n$, with excess $\ge\Gamma_\lambda(\nu)\ge\gamma(\lambda)/(18\nu+1)^2$, and $\beta(\lambda)$ when $c\log n\to0$. The theorem is silent only when $c\log n\to\infty$.
- **Proposition 5.3** as stated, with:
  - the explicit-rate case using $Q\le M$ (Issue 3), which gives excess $\ge\beta(\lambda)-2\sqrt3\sqrt c\,M^{-1/4}-O_\lambda(M^{-1/3})$ for $c\le\sqrt M$;
  - the table entry $0.015$ (Issue 1);
  - Lemma 1.2 stated for general atoms (Issue 4).
- **Errata.** The numerics bullet should read "at least 0.39 / 0.57 for networks at least as good as those found; 0.38 / 0.57 for every near-minimizer" (Issue 2), and the fixed-$d$ scope row should say "for bounded $c$" (Issue 5).

---

## Appendix. Scripts and outputs (`../checks/verify-RT-depth2-computation-revised/`)

| Script | Purpose | Output |
|---|---|---|
| `constants_r1.py` | $\beta,\gamma$ (series and Ei), maxima, (1.0) on a log grid, $\Gamma_1$ table, crossing, zero, monotonicity, Le Cam vs exact binomial | `constants_r1.out` |
| `t51_r1.py` | own $\underline\Psi_d$ from the §4 formulas with a log-product binomial pmf; $c=1$ over $d=1..1000$; small-$c$ table; widths; Cor. 5.2(i) ratio for $c=d^k$ | `t51_r1.out` |
| `prop53_r1.py` | Kronecker Sylvester build; identities at $N\in\{1,2,5\}$, $\lambda\in\{0.5,1,2\}$; $\lvert\tanh s-s\rvert\le\lvert s\rvert^3/3$; event table; rate constant; Remark 5.4 | `prop53_r1.out` |
| `lemma21_r1.py` | explicit Lemma 2.1 networks ($d=6$ sample, $d=4$ arbitrary $r$), objective chain from the raw sample | `lemma21_r1.out` |
| `lemma13_11_r1.py` | exact rational enumeration for Lemma 1.3; bounded differences; Lemma 1.1 scalar steps | `lemma13_11_r1.out` |
| `remarks_r1.py` | sympy instantiation of RT Prop. 6.1 (Remark 5.5) and ../research-notes/B-tempered-likelihood.md Prop. 6.1 with Lemma 5.3(a) (Remark 5.7) | `remarks_r1.out` |
| `misc_r1.py` | binomial identity, $u_m$ bound, Hoeffding draw, first $d$ with bound $\ge2\varepsilon_d$ at $a=1/n$ vs $a=1/d$ | `misc_r1.out` |
| `t1_mono_r1.py` | 200-digit recheck of the ratio's monotonicity near $d=800$ | `t1_mono_r1.out` |
