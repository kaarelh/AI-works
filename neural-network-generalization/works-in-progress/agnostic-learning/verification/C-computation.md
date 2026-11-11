# Referee report on `../research-notes/C-fixed-temperature-bayes.md` (Claim C). Lens: computation

**Verdict: minor fixes.** I recomputed every constant, exponent, energy bound, probability estimate and concentration inequality in ../research-notes/C-fixed-temperature-bayes.md. No step of any proof is wrong, and no theorem or corollary changes. The issues are:

- **C1.** One numerical table in §C.8 does not tabulate the quantity it names. The values quoted for $\varepsilon_n(d)$ of (C.4.2) are about half of $\varepsilon_n(d)$ as defined: $5.7\cdot10^{-2}$ should be $1.1\cdot10^{-1}$, and $1.6\cdot10^{-8}$ should be $3.2\cdot10^{-8}$.
- **C2.** A remark after Theorem C.1 says the argument would fail with an unclipped likelihood. For the predictor ../research-notes/C-fixed-temperature-bayes.md actually uses, it does not fail, so the remark understates the theorem's scope.
- **C3, C4.** Two summary phrases are stronger than what is proved: the "rate $O(\eta n/N^\gamma)$" for the posterior, and "sharp up to the factor $A_L$".
- **C5–C7.** Wording and one optional improvement.

The two load-bearing estimates check out:

- **Tube mass.** Lemma C.3.1 / Appendix C.A matches `paper.tex` Prop. `tube` and eq. `A` constant for constant.
- **Lemma C.6.1.** It holds in every exact test I ran, for Gaussian and non-Gaussian coordinate laws. Bound (i) is also nearly tight: an adversarial sample reaches $0.49$ of it, against the authors' observed ratio of about $0.1$.

Scripts and outputs are in `../checks/verify-C-computation/`; all runs use fixed seeds. The authors' seven scripts were rerun from `../checks/C/`; outputs are in `../checks/verify-C-computation/repro/`, and all are byte-identical to the recorded `.out` files.

---

## 1. What was checked, and how

Every row was re-derived by hand. "Numeric" names my independent script (not the authors' `C_scripts`).

| ../research-notes/C-fixed-temperature-bayes.md item | quantity recomputed | numeric (script) | status |
|---|---|---|---|
| Lemma C.2.1 | $\psi_y''=2\eta(2\eta(p-y)^2-1)\psi_y$; threshold $8\eta-1\le0$; converse at $(p,y)=(-1,1)$ | authors' sympy/grid reproduced | correct |
| Lemma C.2.2 | DV inequality; $\int(\log p)^-dQ\le1/e$; truncation $h\wedge k$; closed form (C.2.2) | n/a | correct |
| Thm C.1(a),(b) | per-step Jensen; telescoping with $Z_0=1$; DV comparison; ghost sample; Fubini/Tonelli; convexity | `v_concentration.py` B: (C.2.5) holds on two new distributions | correct |
| §C.3.1 cloning | $E_*=d(d+1)B^2+2(L-1)m^2B^2$; $k_j/k_k\le2$; $N/\min k_j\le2m$; $\lVert W^\ell_*\rVert_{\rm op}\le\sqrt2\lVert T^\ell\rVert_{\rm op}$ via $D^{1/2}TD^{-1/2}$; $\sqrt N\lVert v_*\rVert\le\sqrt2mB$ | authors' `check_tube_lemma.py` reproduced | correct |
| Lemma C.3.1 / App. C.A | Step 1 count $N[d+2+(L-2)m]$ and $c_\nu$; Step 2 net, $(4L)^{-N}$; Step 3 layer bounds; Step 5 $\bar t$-scaling; "in particular" | `v_constants.py` §5 (100k random tuples, 0 violations); `v_cylinder_translation.py`; `v_translation_gauss_exact.py`; `v_tube_fanin_misc.py` (1) | correct; matches `paper.tex` lines 339–401 |
| (C.3.3) majorant | $P_0\le3mB(d+L+1)A_0^{L-2}$, $A_0\le(5+b_0)mB$, $6/c_\nu=16/\min\{1,\sqrt{m_\nu}\}$ | `v_constants.py` §3: 200k tuples, min slack $+0.30$ | correct |
| Lemma C.3.2 | $(a-y)^2-(b-y)^2=(a-b)(a+b-2y)$, $\lvert a+b-2y\rvert\le4$; Minkowski refinement | n/a | correct |
| Thm C.2, Cor C.2.1 | $\mathrm{KL}(Q\Vert\mu)=\log(1/\mu(U_\rho))$; $\rho=\varepsilon/8$, $n+1\ge2A_LN^\gamma/(\eta\varepsilon)$ | `v_concentration.py` A (sympy) | correct |
| Cor C.2.2 | monotonicity of $A_L$; $N_n\le2n^\alpha$; $E_*\le2Ld^2n^{4\alpha}$; bracket $\le(L+1)dn^\alpha$; $\Lambda_L\le K_1\log(dn)$; $4/n\le1/(2\eta n)$; exponent $(4+\gamma)\alpha$ | `v_constants.py` §4, §6, §7 | correct; explicit $K$ in §2.5 below |
| Separate exponents | $2a+2b+\gamma\beta-1$ | `v_constants.py` §7 (fitted slopes $-0.500,-0.409,-0.511,-0.250$ vs $-0.5,-0.4,-0.5,-0.25$) | correct (wording C6) |
| Remark C.4.1 | parity: $2de^{-A}=\varepsilon'$ at $A=\log(2d/\varepsilon')$; $1-\tanh a\le2e^{-2a}$; $\tanh(7/8)>1/2$ | `v_tube_fanin_misc.py` (3) | correct (wording C5) |
| Remark C.4.2 | (C.3.1) at $\sigma\sqrt N=N^{(1-\gamma)/2}$ | n/a | correct (wording C6) |
| Prop C.3 | $\eta=1/(2c\sigma^2)$, $\eta\sigma^2=1/(2c)$, $2cA_L/(n+1)$, $\eta\le1/8\iff\sigma^2\ge4/c$; (c) thresholds | n/a | correct |
| Prop C.4, App. C.B | per-coordinate KL; $E^{\rm fi}_N$ bound; $Q_N$; recursion $r_\ell\le m^2B^2r_{\ell-1}+t$; $A^{\rm fi}$; $t-1-\log t\le\log(1/t)$ | `v_tube_fanin_misc.py` (2): sympy KL identity; MC at $N\le400$, $L\le5$ | correct |
| Lemma C.6.1 | (P1)–(P4); (C.6.1); (C.6.2); quadratic solve to $\sigma_{\rm out}^2(4k+\sqrt{2k})$; $\mathbb Ee^{G^2/4}=\sqrt2$ | `v_lemma_c61_exact.py`: exact quadrature, $N=1,2$, three laws, 0 violations | correct, nearly tight |
| Thm C.5 | $\sigma_{\rm out}^2=N^{-\gamma}$; TV via Pinsker; Gibbs term; competitor $u^*=0.957504$, readout $\le1.0444$; $4(4+\sqrt2)=21.66<22$ | `v_tube_fanin_misc.py` (3); `v_constants.py` §8 | correct (wording C3, C4) |
| Remark C.6.2 | $\mathbb P\{\lvert z\rvert\ge\frac12\}\le2e^{-m_\nu N^\gamma/8}$ | n/a | correct |
| Thm C.6 | Hoeffding range 4 $\Rightarrow e^{2s^2}$; $s=u/(4n)$; $e^{-u^2/(8n)}$; $2u/n=4\sqrt{2\log(1/\delta)/n}$; $512\log(1/\delta)/\varepsilon^2$; $4A_LN^\gamma/(\eta\varepsilon)$; $\frac{n+1}n\varepsilon_n$ | `v_concentration.py` A (sympy); B (martingale tail, failure rates at $\delta=0.01$) | correct |
| Thm C.7 | $e^{2\lambda^2/n}$; chain total $4\lambda/n=4\eta$; (i) $n\ge32(\cdot)/\varepsilon^2$; (ii) difference $=2\ell(N^\gamma-1)/\sqrt{N^\gamma n}\ge0$; Remark 1: $8/n$ | `v_concentration.py` A, B (also $\eta=1,4$) | correct |
| §C.8 numbers | all tables | `v_constants.py` §1, §2, §8; reruns in `repro/` | correct except item 6 (C1) |
| Remark 3 after Thm C.1 | unclipped likelihood | `v_unclipped.py` | incorrect remark (C2) |

**Cited sources confirmed.** The following statements were read in the repository and match their use:

- `paper.tex`, lines 113–122 (model), 151–170 (eqs. `law`, `strong-scales`, `finite-scales`), 225–232 (Remark `cube`), 293–308 (`energy`, cloning, `teacher-energy`), 310–335 (`subgaussian`, `translation` and its proof), 339–404 (Prop. `tube`, eq. `A`).
- `slt-finite-sample/README.md` §1 (lines 13–29) and §3 (lines 107–158).
- `slt-likelihood/README.md` lines 98–100 ("Gaussian observation variance $N^{-\gamma}$"), 204 (the quoted bound $\mathbb Ez_w(x)^2\le\sigma^2$), 215 ("does not prove failure of the sign of the posterior mean"), 304 ("width-dependent $N^\gamma$ factor").
- `subcritical-exponential.tex` lines 104–145 (weights, conditioning, $F_N$, Theorem `thm:main`, width-limit order).
- `parity-circuit.tex` (width $k+1$, $A=\log(16(k+1))$, error $2e^{-A}$ per step, margin $\tanh(7/8)$).

---

## 2. Re-derivations of the load-bearing inequalities

### 2.1 Theorem C.1

For $p,y\in[-1,1]$, $\psi_y''(p)=2\eta\,(2\eta(p-y)^2-1)\,\psi_y(p)\le2\eta(8\eta-1)\psi_y(p)\le0$ iff $\eta\le1/8$. At $(p,y)=(-1,1)$ the value is $2\eta(8\eta-1)e^{-4\eta}$, which is positive for $\eta>1/8$. The per-step bound is
$$\frac{Z_{t+1}}{Z_t}=\int\psi_{y_{t+1}}(\phi_w(x_{t+1}))\,d\Pi_t\le\psi_{y_{t+1}}(\hat f_t(x_{t+1})).$$
Telescoping with $Z_0=1$ gives the first inequality of (C.2.3). DV with $h=-\eta\sum_{i\le T}\ell_i$ gives the second. The ghost-sample step uses only $\hat f_t\in\sigma(S_t)$ and boundedness. Every constant is as stated.

### 2.2 Tube mass (Appendix C.A)

**Step 1.** I re-derived $\mathbb P(\lvert Y\rvert\le s)\ge\frac{s}{R}\cdot\frac34$ with $R=2\max\{1,m_\nu^{-1/2}\}$, so $\frac{3}{4R}=\frac38\min\{1,\sqrt{m_\nu}\}=c_\nu$. This needs $s\le R$, which holds since $s\le\frac12$. Numerically, the worst ratio $\mathbb P(\lvert Y\rvert\le s)/(c_\nu s)$ over $s\in(0,1]$ is $1.82$ for the Gaussian, $2.37$–$2.40$ for the log-cosh law with $b=1$, and $4.18$–$4.24$ with $b=5$. This holds for single coordinates and for normalized group sums of $k\le10$ coordinates, all with variance $1.0000$.

**Step 2.** On the net, $\langle Za,b\rangle\ge\lVert Z\rVert_{\rm op}(1-\frac14-\frac14)$. The tail is
$$81^Ne^{-m_\nu q^2N/2}=81^N\cdot81^{-N}(4L)^{-N}=(4L)^{-N}.$$
The union over the $L-2$ internal layers gives $\mathbb P_{\mathcal C}(E^c)\le\frac{L-2}{4L}<\frac14$. So in fact $\mathbb P(E)\ge\frac34\mathbb P(\mathcal C)$; ../research-notes/C-fixed-temperature-bayes.md's $\frac12$ is conservative. ../research-notes/C-fixed-temperature-bayes.md correctly drops the paper's factor $2$, because the one-sided bilinear maximum already controls the operator norm.

**Step 3.** Each bound is checked:

- Layer 1: $\sigma\sqrt{N/d}\,s(d+1)=\frac t{\bar t}\frac{h(d+1)}{\sqrt d}\le h(d+1)$.
- Internal layers: $\lVert\zeta^\ell P\rVert_F^2=\sum_{i,j}\langle\zeta^\ell_{i,*},u_j\rangle^2\le Nms^2$. This gives $e_\ell\le a\,e_{\ell-1}+\frac t{\bar t}\sqrt m\,h$.
- Readout: $\lVert v-v_*\rVert_1\le N\sigma N^{-1/2}s=ts\le h$.
- Recursion: $e_{L-1}\le h(d+L-1)A_0^{L-2}$. ../research-notes/C-fixed-temperature-bayes.md's $d+L+1$ is slightly weaker, as in the paper.

**Step 5.** $A_0(\bar t)\le\bar tA_0(1)$ and $P_0(\bar t)\le\bar t^{L-2}P_0(1)$; 100k random tuples gave 0 violations.

**"In particular".** Since $N\le\sigma^{-2}$ and $1\le\sigma^{-2}$, the right side of (C.3.1) is at most $(A_L-1)/\sigma^2$; 100k random tuples gave 0 violations.

**Translation inequality.** Under the exact normal CDF (mpmath, 50 digits), the minimum over 20,000 symmetric sets of $\mathbb P(E+a)/[\mathbb P(E)e^{-a^2/2}]$ is $1.000000000000000001$; the bound is attained in the limit $s\to0$. For the log-cosh laws the minimum is $1.000000$, with masses computed from the CDF.

**Conditioned sub-Gaussian bound.** The maximum of $\log\mathbb Ee^{\theta\langle u,Y\rangle}/(\theta^2\lVert u\rVert^2/(2m_\nu))$ over symmetric intervals and boxes is $1.000000$ (Gaussian, equality when unconditioned), $0.79$ ($b=1$) and $0.45$ ($b=5$).

**Monte Carlo of the tube mass.** I ran tiny networks ($d=1$, $L=2$, $m=1$, $B=1$, $N=1,2$). The tube masses were $1.5\cdot10^{-2}$ to $2.0\cdot10^{-1}$, against bounds $e^{-A_LN}$ of $3.7\cdot10^{-17}$ to $2.8\cdot10^{-8}$. The bound is valid but very loose, as C.9 item 5 says.

### 2.3 Constants of §C.8 item 6 (Gaussian)

Recomputed independently: $A_L=346.0,\ 1387.4,\ 23088.2,\ 82584.8$. The sample sizes are $5.54\cdot10^4$, $2.22\cdot10^6$, $3.69\cdot10^7$ and $1.32\cdot10^9$, and $b_0(L=3)=7.4185$. All match the text.

### 2.4 Lemma C.6.1

I re-derived each step:

- **Step 1.** $\mathrm{KL}\le\int(\ell-\ell^0)d\mu-\int(\ell-\ell^0)d\Pi_t\le\eta t\sigma_{\rm out}^2+2\eta tF_t$.
- **Step 2.** Optimising $\theta$ gives $F_t\le\sigma_{\rm out}\sqrt{2\mathrm{KL}/m_\nu}$.
- **Step 3.** With $b=2\sigma_{\rm out}^2/m_\nu$ we have $b\eta t=2\sigma_{\rm out}^2k$, hence $2b\eta t=4\sigma_{\rm out}^2k$ and $\sigma_{\rm out}\sqrt{b\eta t}=\sigma_{\rm out}^2\sqrt{2k}$.
- **Step 4.** With $\lambda\sigma_{\rm out}^2/m_\nu=\frac14$, $\mathbb Ee^{G^2/4}=(1-\frac12)^{-1/2}=\sqrt2$.

The proof uses only (P1)–(P4) conditionally on the hidden weights. It therefore applies with fixed hidden features, and the posterior is then an exact low-dimensional integral.

**Exact tests (`v_lemma_c61_exact.py`).** I used $N=1$ quadrature on 800,001 points in log space, $N=2$ quadrature on a $1201^2$ grid, and three laws: Gaussian, and log-cosh with $b=1$ ($m_\nu=0.592$, $M_\nu=1.184$) and $b=5$ ($m_\nu=0.190$, $M_\nu=1.142$). These laws also confirm C.1.2's remark $m_\nu\le1\le M_\nu$. Across random and adversarial samples there were no violations of (i), (ii) or (iii).

**Tightness.** In the adversarial case (all features $1$, labels $+1$, small $s$), the Gaussian posterior is $\mathcal N\bigl(\frac{2ks}{1+2ks^2},\frac1{1+2ks^2}\bigr)$, so
$$\frac{F_t}{\sigma_{\rm out}^2(4k+\sqrt{2k})}=\frac{2k}{(1+2ks^2)(4k+\sqrt{2k})}\to\frac12 .$$
Quadrature reproduces this exactly: $0.369,\,0.450,\,0.483,\,0.489$ at $\eta t=1,10,100,10^4$. Bound (i) is therefore sharp up to a factor of about $2$, and the lower bound of Theorem C.5(c) is correspondingly meaningful. The authors' "about one tenth of the bound" (§C.8 item 4) refers to a non-adversarial Monte Carlo sample. The maximum ratios were $0.25$ for (ii) and $0.72$ for (iii).

### 2.5 Corollary C.2.2 with an explicit constant

With $m=B=n^\alpha\le n$, $\rho=1/n$ and $\alpha\le1$:

- $\Lambda_L\le K_1\log(dn)$, where $K_1=2L-1+\bigl[\log(L+2)+(L-2)\log(5+b_0)+\log(16/\sqrt{m_\nu})\bigr]/\log2$. This uses $d+L+1\le d(L+2)$ and $\log(dn)\ge\log2$.
- $A_L\le K_2\,d^2n^{4\alpha}\log(dn)$, where $K_2=\frac{1+\log2}{\log2}+\frac{M_\nu L}{\log2}+(L+1)K_1$.
- $\varepsilon_n(d)\le K\,d^2n^{(4+\gamma)\alpha}\log(dn)/(\eta n)$, where $K=2^\gamma K_2+\frac1{2\log2}$.

The table compares this explicit $K$ with the largest ratio needed on a grid (Gaussian; $d\le10^4$, $n\le10^{30}$, seven values of $\alpha$, $\eta\in\{1/8,10^{-3}\}$). The bound holds at every grid point.

| | $L=2$ | $L=3$ | $L=5$ |
|---|---|---|---|
| $\gamma=1$: explicit $K$ / grid sup | 65.4 / 33.4 | 133.9 / 63.7 | 341.7 / 156.0 |
| $\gamma=2$: explicit $K$ / grid sup | 130.0 / 66.1 | 267.1 / 126.7 | 682.6 / 311.3 |

The authors may wish to state $K$ explicitly.

### 2.6 Theorem C.5(d)

The ratio of the two thresholds is
$$\frac{4(4k_n+\sqrt{2k_n})\cdot4A_L}{\eta(n+1)}\longrightarrow\frac{64A_L}{m_\nu}.$$
It equals $3080.3$ ($d=2$) and $20929.4$ ($d=10$), against $64A_L=3050.1$ and $20908.5$; at $d=100$ it is $1.36\cdot10^6$. This is consistent with the text's "about $2\cdot10^4\approx64A_L(10,1,2,1/16)$", where $A_L(10,1,2,1/16)=326.7$.

### 2.7 Concentration (Theorems C.6, C.7)

SymPy reproduces every constant:

- Hoeffding exponent $2s^2$ for range $4$.
- Chernoff optimum $s=u/(4n)$, giving $e^{-u^2/(8n)}$; $u=\sqrt{8n\log(1/\delta)}$ gives $\delta$ and $2u/n=4\sqrt{2\log(1/\delta)/n}$.
- Thresholds $512\log(1/\delta)/\varepsilon^2$, $4A_LN^\gamma/(\eta\varepsilon)$ and $\rho=\varepsilon/8$.
- Theorem C.7: $n\cdot(\lambda/n)^2\cdot2=2\lambda^2/n$, chain total $4\eta$, (i) threshold $32(A_LN^\gamma+2\log(1/\delta))/\varepsilon^2$, and (ii) as claimed when $N^\gamma\ge1$.

The Monte Carlo used two new distributions ($\pm1$ labels; one agnostic, one pure noise), a dictionary containing the zero function at prior mass $10^{-6}$, $n\in\{10,50,200\}$ and 2000 replications.

- The empirical tails of $\sum_t\Delta_t$ lie far below $e^{-u^2/(8n)}$; for example $P(S\ge\sqrt n)\le0.032$ against $0.88$.
- Failure rates of (C.7.1) and (C.7.2) at $\delta=0.01$ were $0.000$. This also holds for (C.7.2) at $\eta=1$ and $\eta=4$, outside the exp-concave range, as Theorem C.7 allows.
- (C.2.5) held in all six settings.

---

## 3. Issues found

**C1 (minor; numerical). §C.8 item 6 does not tabulate $\varepsilon_n(d)$ as defined in (C.4.2).**

- (C.4.2) defines $\varepsilon_n(d)=\frac4n+\frac{(2n^\alpha)^\gamma A_L(d,n^\alpha,n^\alpha,1/n)}{\eta(n+1)}$.
- `C_scripts/constants_table.py` (line 29) evaluates $\frac4n+\frac{\lceil n^\alpha\rceil^\gamma A_L}{\eta(n+1)}$, although its docstring states the $(2n^\alpha)^\gamma$ form.
- On the tabulated grid the defined quantity is larger by $(2n^\alpha/\lceil n^\alpha\rceil)^\gamma\in[1.87,2.00]$. At $d=10$, $L=3$:
  - $\alpha=0.1$: $\varepsilon_{10^6}=1.14\cdot10^{-1}$ (quoted $5.7\cdot10^{-2}$) and $\varepsilon_{10^{18}}=3.22\cdot10^{-8}$ (quoted $1.6\cdot10^{-8}$);
  - $\alpha=0.19$, $n=10^{18}$: $4.03$ (quoted "still above $1$", which stays true).
- No conclusion changes. The tabulated quantity is itself a valid, slightly sharper, bound: it is what Theorem C.2 gives directly at $N_n=\lceil n^\alpha\rceil$.

*Fix:* either define $\varepsilon_n(d)$ with $N_n^\gamma=\lceil n^\alpha\rceil^\gamma$ and use $N_n\le2n^\alpha$ only in the majorant, or replace the two quoted numbers. Correct the script's docstring either way.

**C2 (minor; an incorrect scope remark). Remark 3 after Theorem C.1, first bullet.**

The remark says that with an unclipped likelihood the argument "would need concavity of $\psi_y$ on all of $\mathbb R$". That is true only if the predictor is the posterior mean of *unclipped* outputs. For the predictor ../research-notes/C-fixed-temperature-bayes.md uses, the mean of clipped outputs, inserting (C.1.1) before Jensen gives, for $\eta\le1/8$,
$$\int e^{-\eta(z_w(x)-y)^2}\,d\Pi_t\ \le\ \int e^{-\eta(\phi_w(x)-y)^2}\,d\Pi_t\ \le\ e^{-\eta(\hat f_t(x)-y)^2}.$$
Consequences for the unclipped-likelihood posterior:

- Theorem C.1 holds, with $\int L_D(z_w)\,dQ$ in place of $\int L_D(\phi_w)\,dQ$.
- Theorem C.2 holds, with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$. On the tube, $\lVert z_w-y\rVert_{L^2(D)}<\sqrt{L_D(g)}+\rho$ by Minkowski; no clipping is needed.

`v_unclipped.py` confirms this: 12,000 per-step checks with dictionary outputs in $[-3,3]$ gave no violations. The raw-mean predictor does fail, for example $y=1$ with outputs $\{3,7\}$ at weights $\frac12$ gives $16>9.40$. The remark therefore understates the result; nothing proved is affected.

*Fix:* restate the remark: clipping in the *predictor* is essential, clipping in the likelihood is not.

**C3 (minor; imprecise rates). §C.9, "the posterior tends to the prior and the predictor to $0$, at the quantitative rate $O(\eta n/N^\gamma)$"** (similarly the paragraph after Theorem C.5). What Lemma C.6.1 gives, with $k_n=\eta n/m_\nu$:

- $\sup\lvert\hat f_n\rvert\le N^{-\gamma}(4k_n+\sqrt{2k_n})$. This is $O(\eta n/N^\gamma)$ only when $k_n\gtrsim1$, and $O(\sqrt{\eta n}/N^\gamma)$ when $k_n\ll1$.
- $\mathrm{KL}\le\eta nN^{-\gamma}(1+8k_n+2\sqrt{2k_n})=O((\eta n)^2/(m_\nu N^\gamma))$ for large $k_n$.
- $\mathrm{TV}=O(\eta n\,N^{-\gamma/2})$.

Neither distance between posterior and prior is $O(\eta n/N^\gamma)$.

*Fix:* state the three rates separately.

**C4 (minor; overstatement). "Sharp up to the factor $A_L$"** (C.0 item 4, Theorem C.5(d), §C.9). What is proved: for the constant target at excess level $\frac12$, the critical $N^\gamma$ is located within the factor $64A_L/m_\nu$ (§2.6). Equivalently, the sample size needed for excess $\le\frac12$ is $\Theta(N^\gamma/\eta)$ up to that factor. This does not show that the $1/\varepsilon$ dependence of Corollary C.2.1, or the functional form of the excess in $N^\gamma/(\eta n)$, is sharp. "$O(A_L)$" also hides the factor $64/m_\nu$.

*Fix:* "the linear dependence of the required sample size on $N^\gamma/\eta$ cannot be improved by more than the factor $64A_L/m_\nu$ (at fixed excess $\frac12$)".

**C5 (minor; wording). Remark C.4.1, depth $L=3$.** "Replacing the weight of the last hidden neuron by $\log(2/\varepsilon')$" describes $L\ge4$, where that neuron has the single incoming weight $2$. At $L=3$ the last hidden neuron is the summing neuron, which has $d+1$ incoming weights ($\pm1$ and $c/\tanh1$). All of them must be multiplied by $\log(2/\varepsilon')$, as `check_misc.py` does. The weights are then up to $\log(2/\varepsilon')/\tanh1$, and the error is $\le2e^{-2\cdot\frac78\log(2/\varepsilon')}\le\varepsilon'$. The conclusion is unaffected.

**C6 (trivial).**

- Remark C.4.2: "$\sigma\sqrt N=N^{(1-\gamma)/2}>1$" is an equality at $N=1$ (harmless, since $\log^+=0$ there). "$\mathrm{poly}_L$" also depends on $\gamma$ and $\nu$.
- The separate-exponent sentence after Corollary C.2.2: it is the *bound* (not the excess) that is $o(1)$ iff $2a+2b+\gamma\beta<1$, at fixed $d$. At equality the bound tends to a positive constant, because the $E_*$ term carries no logarithm, while the stated $O(\cdot)$ majorant grows like $\log n$. Also $O_L$ should read $O_{L,\gamma,\nu}$.
- C.0 item 2 and Corollary C.2.2: "minimum test loss" should read "infimum".

**C7 (optional improvement; not an error). The constant $c_\nu$.** Every form $Y$ has variance exactly $1$, so Chebyshev with $R=2$ already gives $\mathbb P(\lvert Y\rvert\le s)\ge\frac38s$, independently of $m_\nu$. The factor $\min\{1,\sqrt{m_\nu}\}$, which always equals $\sqrt{m_\nu}$ by C.1.2's own remark $m_\nu\le1$, can be dropped from $c_\nu$ and from (C.3.3). ../research-notes/C-fixed-temperature-bayes.md inherits the factor from `paper.tex`, which uses the weaker "variance at most $1/m$". Numerically, $\min_{s\le1}\mathbb P(\lvert Y\rvert\le s)/s\ge0.68$ even at $m_\nu=0.19$.

---

## 4. Reproduction of the authors' checks

All seven scripts in `../checks/C/` were rerun with `python3 -I`. Each output is byte-identical to the recorded `.out` file: `constants_table`, `check_misc`, `check_expconcavity`, `check_fanin_reference`, `check_tube_lemma`, `check_width_lower_bound` and `check_oracle_mc`.

Every number quoted in §C.8 matches these outputs, with these notes:

- Item 6, rate: see C1.
- Item 3: the quoted ratios $0.53$, $0.73$, $0.86$ and $0.063$ are the maxima of the recorded output.
- Item 4: every table entry rounds correctly from the recorded output.

---

## 5. Not checked here

- The general-$\nu$ proofs behind `paper.tex` eqs. `subgaussian` and `translation`: Brascamp–Lieb and the relative-entropy argument. I checked these only numerically, in one and two dimensions, for two non-Gaussian laws.
- Literature statements not used in any proof: mixability of squared loss for $\eta\le1/2$, and Audibert (2007) on deviation suboptimality.
- Measurability and the logic of quantifier order, beyond what the computations touch; that is the logic lens.

---

## 6. Scripts (all in `../checks/verify-C-computation/`)

| script | checks |
|---|---|
| `v_constants.py` | $A_L$ table; $\varepsilon_n$ as defined vs as tabulated (C1); (C.3.3); monotonicity; Lemma C.3.1 "in particular" and $\bar t$-scaling; explicit $K$ of Cor. C.2.2; separate exponents; Thm C.5(d) thresholds |
| `v_lemma_c61_exact.py` | Lemma C.6.1 (i)–(iii) by exact quadrature, $N=1,2$, Gaussian and log-cosh laws; tightness $\to\frac12$ |
| `v_cylinder_translation.py` | Step 1 cylinder bound (including group sums); translation inequality; conditioned sub-Gaussian MGF |
| `v_translation_gauss_exact.py` | Gaussian translation inequality with exact CDF (mpmath) |
| `v_concentration.py` | SymPy constants of Thms C.6, C.7 and the corollaries; martingale tail; failure rates; (C.2.5) on new distributions |
| `v_unclipped.py` | C2: unclipped likelihood with clipped-mean predictor (holds) vs raw-mean predictor (fails) |
| `v_tube_fanin_misc.py` | tube-mass Monte Carlo vs $e^{-A_LN^\gamma}$; fan-in reference law at $N\le400$, $L\le5$; small numeric facts |
| `v_equality_case.py` | C6: at $2a+2b+\gamma\beta=1$ the bound tends to the constant $32$ ($L=3$, $\gamma=1$, $\eta=1/8$) |
| `repro/` | outputs of the authors' seven scripts (identical to the recorded ones) |
