# Referee report on `../research-notes/red-team.md` §5 (depth two): Theorem 5.1, Corollary 5.2, Proposition 5.3 — logic and definitions

**Lens.** I checked quantifiers, the limit order ($\sigma\downarrow0$ after the sample, $n$, $c$ and the width are fixed), case splits and definitions against `../research-notes/problem-brief.md` and the cited sources. I looked for circularity, misapplied lemmas, and missing hypotheses: widths, weight bounds, clipping, measurability, existence of minimizers, label range, input domain.

**What I read.**

- Under review: `../research-notes/red-team.md` §5 (lines 387–440): Theorem 5.1 and its proof, Corollary 5.2, Proposition 5.3 and its proof, and the paragraphs "This example has $n\asymp d$…" and "The positive side at $L=2$".
- Everything these use:
  - Lemma 1.0(1) (line 37);
  - Lemma 1.1 (line 47);
  - Lemma 1.2 (line 73);
  - Lemma 1.3 (line 86);
  - Lemma 2.1, part (2) and Steps 1–5 (line 120);
  - Theorem 2.2, part 2, for "the limits follow as in Theorem 2.2".
- Places that summarise or cite §5:
  - §0 item 6 (lines 25–28);
  - §2.3 A3 (line 197);
  - §6.1 (line 452);
  - Appendix A (line 588).
- Sources, compared line by line:
  - `NNG/side-results/continuous-domains/source/paper.tex`: §2 Model (lines 113–232, including Theorem `strong` and Remark `cube`), Lemma `posterior` (line 248), eq. `energy` (line 293), eq. `teacher-energy` (line 303), proof of Theorem `strong` (lines 506–528), Prop. `exact` and Cor. `exact` (lines 605–697).
  - `NNG/works-in-progress/noisy-interpolation/README.md` §§1–3, eqs. (2)–(11).
  - `NNG/works-in-progress/slt-likelihood/README.md` §2, for the input domain and the likelihood scaling.
  - `../research-notes/A-tight-conditioning-fails.md` Remark 2.5, §8 (Prop. 8.2, 8.3); `../research-notes/B-tempered-likelihood.md` §7.5 item 3; `RT-width-logic.md`, for Prop. 6.1, which I cite.

**Abbreviations.** `NNG/` is the project folder `neural-network-generalization/` of this repository. "RT" is `../research-notes/red-team.md`. $M=2^d$ on the cube; $\vartheta_c=1/(18dc+1)$; $E_0=c(dF_d+1)+2$; $F_d=1+(d+1)(d+2)^2$; $\gamma(\lambda)=(1-e^{-\lambda})^2/(4\lambda)$.

**Scripts.** They are in `../checks/verify-RT-depth2-logic/`; each `.py` has a matching `.out` (§5 below).

---

## Verdict: major flaw in a scope claim of Corollary 5.2; the three proofs are correct

- **Theorem 5.1 is correct as stated.** I re-derived every step:
  - the memorizer energy;
  - the residual of $tg$;
  - the bracket minimisation;
  - the near-minimiser chain;
  - Lemma 1.2(b);
  - the asymptotics;
  - the transfer to Gibbs and posterior-mean risks.

  All hold. The constants $\gamma(1)=0.0999$ and $\max\gamma=0.1018$ at $\lambda=1.256$ are right.
- **Proposition 5.3 is correct as stated**, inside the brief's formalisation, where inputs lie in $[-1,1]^d$. The Hadamard memorizer is checked exactly: it is $z=\epsilon^{-1}\tanh(\epsilon u\cdot x)$ with $\kappa_N=\epsilon^2Q+\epsilon^{-2}=2\sqrt Q$ and error at most $\epsilon^2/3$, at every width $N\ge1$.
- **Corollary 5.2: the refutation is correct; the scope sentence is wrong.**
  - Correct: it refutes the width-uniform polynomial-sample inequality of BRIEF §1 for $c\le\mathrm{poly}(d)$.
  - Wrong: the sentence "It does **not** refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$" is false on part of the corollary's own stated range, "every $c\le\mathrm{poly}(d)$". That range includes $c\to0$.
    - For $c=\kappa/d$, Theorem 5.1's own bound is the $d$-independent constant $\gamma(\lambda)/(18\kappa+1)^2$.
    - For $dc\to0$, the same near-minimiser bound with Lemma 1.2(a) in place of 1.2(b) gives excess $\ge\beta(\lambda)-o(1)$.

    So depth-two SP$_c$ with $c=O(1/\log n)$ fails the "$+o(1)$" formulation too, with the same constant $\beta(\lambda)$ as Theorem 2.2 at depth $\ge3$ when $dc\to0$. Conditioning closely is exactly the regime the user proposed. The same under-statement appears in A3 (line 197).
- **Why "major" although every proof step holds.** The focus question summarises the claim as "refutes the polynomial-sample inequality … with $c\le\mathrm{poly}(d)$ **but not the $+o(1)$ formulation**". As a statement to cite, that is false for $c=O(1/\log n)$, and its stated reason ($\varepsilon_d\asymp1/\log^2n$) is false there. The repair is easy and strengthens the result (§4), but the final note must not copy the sentence.
- **Minor issues.** Five minor issues are listed in §3 (issues 2–6):
  - the learner width needed by Corollary 5.2;
  - which predictors are covered (not the progressive mixture);
  - the input-norm convention behind the "dimension-free" reading of Proposition 5.3;
  - the quantifier on $d$ in the "$+o(1)$" formulation;
  - wording and edge cases, including the "$c^\star=\mathrm{polylog}(n)$" paragraph.

### Answers to the focus questions

| Question | Answer |
|---|---|
| Energy of the depth-two memorizer | **Correct.** Lemma 2.1(2): readout $tA_0/(m_0k_j)$ on the copies of feature $j$, with $k_j\ge N/(2m_0)$. This gives readout energy $\le2t^2A_0^2=18dt^2Q$ and first-layer energy $\le dF_d$. Checked exactly on $d=4,5,6$ with explicit width-$N$ networks for $N\in\{m_0,\,2.5m_0+3\}$ and $t\in\{1,0.37,0.05\}$ (`check_lemma21_H1.out`). |
| Bracket minimisation | **Correct.** $\min_t[\alpha t^2+(1-t)^2]=\alpha/(1+\alpha)$ at $t=1/(1+\alpha)$; with $\alpha=18dc$ this is $1-\vartheta_c$ (sympy, `check_thm51_chain.out`). |
| Limits | **Correct.** Lemma 1.1 (re-checked) gives posterior concentration on $\mathcal N_1$, uniformly over samples, at fixed $(N,n,c)$. Gibbs: $\mathbb E_\Pi\Phi\ge\Pi(\mathcal N_1)\inf_{\mathcal N_1}\Phi$. Posterior mean: convexity of $\mathcal R$ and $\Phi=\mathcal R\le cF$. The sample event involves neither $N$ nor $\sigma$. |
| Hadamard construction | **Correct.** $u=M^{-1}\sum_T\bar y_ja_j$ gives $u\cdot a_k=\bar y_k\mathbf 1_T(k)$ and $\lVert u\rVert^2=Q/M$. Then $\kappa_N=d\epsilon^2Q/M+\epsilon^{-2}=\epsilon^2Q+\epsilon^{-2}$ (using $d=M$) and $\lvert z(a_k)-\bar y_k\rvert\le\epsilon^2\lvert\bar y_k\rvert^3/3\le\epsilon^2/3$. Verified with explicit matrices at $N\in\{1,2,7\}$ and $M\le4096$; the largest ratio of error to $\epsilon^2/3$ is $0.9915$ (`check_hadamard.out`). |
| $\gamma(1)=0.0999$ and the $(18dc+1)^{-2}$ form | **Correct** for $c\le\mathrm{poly}(d)$. The explicit $c=1$ bound is first positive at $d=30$ ($2.0\cdot10^{-8}$), with peak $2.3\cdot10^{-7}$ at $d=35$. |
| Corollary 5.2 | Refutation: **correct** (width-uniform, specified predictors). "Not the $+o(1)$ formulation": **false for $c=O(1/d)$** (issue 1). |
| Proposition 5.3, $c=o(\sqrt M)$, every $N\ge1$ | **Correct**, with $o(1)=O(\sqrt c\,M^{-1/4})$. The result depends on inputs of norm $\sqrt d$ (issue 4). |

---

## 1. Statements compared against the sources

| Item | Source | Matches RT's use? |
|---|---|---|
| Energy $\kappa_N=\frac dN\lVert W^1\rVert_F^2+\sum_{\ell=2}^{L-1}\lVert W^\ell\rVert_F^2+N\lVert v\rVert^2$; at $L=2$ only the first and last terms | `paper.tex` eq. `energy` (line 293); BRIEF §2; slt-likelihood §2 | yes |
| SP$_c$: posterior $\propto e^{-F_c/(2\sigma^2)}$, $F_c=\kappa_N+\frac1c\sum_i(z_w(x_i)-y_i)^2$, $c$ may depend on $n$ (so $c\to0$ is allowed) | BRIEF §2; slt-likelihood §2 for $c=1$ | yes. RT writes $F_{c,S}$; $c\,F_{c,S}-W=c\kappa_N+\mathcal R$ |
| Limit order: sample and width fixed, then $\sigma\downarrow0$; $\sigma_0$ may depend on $(N,n)$ | BRIEF §5; `paper.tex` Thm `strong` (lines 178–197); slt-likelihood §2 | yes. Lemma 1.1's threshold depends on $(N,n,c,\zeta)$ only |
| Input domain | BRIEF §1: "$X$ compact in $[-1,1]^d$"; BRIEF §2: "(or unit ball)"; `paper.tex` §2: unit ball, with Remark `cube` (line 225) extending to $[-1,1]^d$; slt-likelihood §2: $[-1,1]^d$ | Theorem 5.1 and Prop. 5.3 use $\pm1$ inputs. Valid for the brief's §1 formalisation. Prop. 5.3 is **not** robust to unit-ball normalisation (issue 4) |
| Labels in $[-1,1]$ | BRIEF §1 | fair signs. Used for $m_*\le n/c$ (Lemma 1.1), $\lvert r\rvert\le1$ (Lemma 2.1), and for clipping not increasing $\mathcal R$ or $L_D$ |
| Learner width "every $N\ge m$" | BRIEF §1 | Theorem 5.1 needs $N\ge72dn^3\ln(2M)+2$; Prop. 5.3 needs $N\ge1$. Both fine for the width-uniform formalisation (issue 2) |
| Competitor | BRIEF §1: depth $L$, width $m$, weights $\le B$ | the zero network: depth 2, width 1, weights $0\le B=1$, $L_D=1=\mathrm{OPT}$ |
| Parity representation and Fourier $\ell^1$ bound | noisy-interpolation README eqs. (2)–(4): $\sum_S\lvert\hat r(S)\rvert\le\lVert r\rVert_2$; $\lvert c_{k,a_d}\rvert\ge1/(2\sqrt{2k})$; total coefficient $\le3\sqrt d$; row norms $\le F_d$; empty parity $\tanh(1)/\tanh(1)$ | yes. RT replaces the README's accuracy $1/4$ and $32A_s^2$ by accuracy $a/2$ and $8A_0^2$. Hoeffding: $2\exp(-2m(a/2)^2/(2A_0)^2)=2\exp(-ma^2/(8A_0^2))$, correct |
| Depth-two readout | README §3 ("For $H=1$ … readout coefficient $A/(m_sk_j)$ … at most $6A^2$") | RT scales by $t$ and uses the full width $N$ for the correction, giving $2t^2A_0^2$ instead of the README's $6A^2$, which reserves half the width for a teacher. Correct |
| Predictors | BRIEF §2: Gibbs, posterior mean, progressive mixture | RT §5 covers near-minimisers, Gibbs and posterior means, clipped and unclipped; **not** the progressive mixture (issue 3) |

---

## 2. Step-by-step check

### 2.1 Lemma 1.1 (used with $\zeta=1$)

I re-checked the lemma line by line; the prior referees (`RT-width-logic.md` §2.9 and `RT-width-computation.md`) reached the same conclusion.

- **Pointwise bound.** $(1+t)e^{-t/(2\sigma^2)}\le(1+2\sigma^2/\alpha)e^{-(1-\alpha)t/(2\sigma^2)}$ holds: $\max_s s\,e^{-s}=1/e$.
- **Split.** $(1-\alpha)F\ge(1-\alpha)^2(m_*+\zeta)+(1-\alpha)\alpha\kappa_N$ on $\{F>m_*+\zeta\}$, using $F\ge\kappa_N$.
- **Gaussian integral and $\alpha$.** The integral is correct. The choice of $\alpha$ is uniform because $(1-\alpha)^2(m+\zeta)-m-\zeta/2$ decreases in $m$ and $m_*\le F(0)\le n/c$; the last step uses labels in $[-1,1]$ and $z_0\equiv0$.
- **Uniform ball in $V$.** The radius is uniform over samples, because $F_{c,S}$ is Lipschitz near $\{\kappa_N\le n/c\}$ with a constant free of $S$.

**Uses in §5.**

- *Gibbs.* $\Phi=L_D(z_w)\le2\kappa_N+2\le2F+2$ by Lemma 1.0(1), and $\Phi=L_D(\operatorname{clip}z_w)\le4$.
- *Posterior means.* $\Phi=\mathcal R(z_w)=cF-c\kappa_N-W\le cF$.
- *Integrability.* $\lvert z_w\rvert\le\sqrt{F}$ and $e^{-F/(2\sigma^2)}\le e^{-\kappa_N/(2\sigma^2)}$, so $\mathbb E_\Pi z_w$ exists and the posterior is proper.
- *Existence of minimisers.* $F$ is continuous and coercive, so $\mathcal N_1\ne\emptyset$.

**No gap.**

### 2.2 Lemma 1.2

- **(1.1).** This is the within/between decomposition. It holds for every $f$, and $W$ does not depend on $f$.
- **(a).** Triangle inequality in $\ell^2(T)$, plus $\sum_T(f-\bar y)^2\le\mathcal R(f)$ because $k_x\ge1$.
- **(b).** Expanding gives $\mathcal R(f)=\sum_Tk_xf^2-2\sum_xfS_x+G$, since $k_x\bar y_x=S_x$ and $S_x=0$ off $T$. Hence $2\sum fS\ge\vartheta G-E_0$, and Cauchy–Schwarz gives the bound.
- **Edge case.** (b) needs $V>0$; with $V=0$ the right side is $0/0$. This is harmless: on the event of Lemma 1.3, $V\ge n-n^{2/3}$.
- **In the cube example**, $L_D(f)=1+M^{-1}\sum_xf^2$, because $y$ is centred, independent of $x$, and $y^2=1$.
- **Numerics.** No violation of (1.1), (a) or (b) in 3000 random trials, including near-saturating $f$ (`check_thm51_chain.out` (3)).

### 2.3 Lemma 1.3

- **McDiarmid.** $\Sigma_1=\sum_Tk_x^{-1}$ and $s$ have bounded differences 2. With $t=n^{2/3}$, McDiarmid gives $2e^{-n^{1/3}/2}$ for each.
- **Conditional moments.**
  - $\mathbb E[S_x^4]=3k^2-2k$, so $\mathrm{Var}(S_x^2)=2k^2-2k$.
  - $\mathrm{Var}(Q\mid x)=\sum_T(2k^2-2k)/k^4\le2s$ and $\mathrm{Var}(G\mid x)\le2s$.
  - $\mathrm{Var}\,V=2n(n-1)/M$: only the paired terms $i\ne j$ with $x_i=x_j$ survive.
- **Failure probability.** Chebyshev at $n^{2/3}$ gives the stated total $4e^{-n^{1/3}/2}+(4+2n/M)n^{-1/3}$.
- **Poisson limit.** It holds because the test functions are bounded.
- **Monte Carlo** ($d=8$, $4\cdot10^4$ label resamples; `check_thm51_chain.out` (4)):

  | Quantity | Monte Carlo | Exact |
  |---|---|---|
  | $\mathbb E[Q\mid x]$ | 121.42 | $\Sigma_1=121.42$ |
  | $\mathrm{Var}(Q\mid x)$ | 14.69 | 14.74 |
  | $\mathbb E[G\mid x]$ | 160.005 | $s=160$ |
  | $\mathrm{Var}(G\mid x)$ | 77.12 | 77.17 |
  | $\mathrm{Var}\,V$ | 508.1 | 510 |

- **Hadamard atoms.** The lemma uses only "uniform on $M$ atoms, independent fair signs". So it applies verbatim to the Hadamard atoms of Prop. 5.3, as RT says.

### 2.4 Lemma 2.1(2) ($H=1$)

- **Step 1.** Parseval and Cauchy–Schwarz over $M$ normalised coefficients give $\sum_S\lvert\hat r(S)\rvert\le\lVert r\rVert_2$ (unnormalised $\ell^2$ norm).
- **Step 2.** For $k\le d$, $\lvert c_{k,a_d}\rvert\ge1/\sqrt{2k}-2e^{-2a_d}\ge1/(2\sqrt{2k})$, and $2\sqrt{2k}\le3\sqrt d$. Rows have $\lVert\omega\rVert^2=a_d^2(k+b_k^2)\le(d+2)^2(d+1)<F_d$. Signs are absorbed by oddness, and the zero row takes the leftover probability.
  - Checked exactly for $d=4,5,6$: the signed mixture reproduces $r$ to $10^{-10}$. The total weight (5.2, 6.8, 12.6) is far below $A_0$ (16, 25.3, 42.1), and the largest $\lVert\omega\rVert^2$ is far below $F_d$.
- **Step 3.** Hoeffding with summands in $[-A_0,A_0]$ and $m_0>8A_0^2\ln(2M)/a^2$ gives failure probability $<1$. All $5/5$ random draws met $\sup\lvert g-r\rvert\le a/2$ at $a\in\{1,\tfrac12\}$.
- **Step 4.** $N\ge m_0$ implies $\lfloor N/m_0\rfloor\ge N/(2m_0)$, so the first-layer energy is $\le dF_d$.
- **Step 5.** The output is exactly $tg$. The readout energy is $\frac{Nt^2A_0^2}{m_0^2}\sum_j k_j^{-1}\le2t^2A_0^2$. Checked with explicit networks (`check_lemma21_H1.out`).
- **Degenerate case.** If $Q=0$ then $A_0=0$, $m_0=1$ and $g\equiv0$; harmless.

**Correct.**

### 2.5 Theorem 5.1

1. **Width.** $A_0^2=9dQ$ and $m_0=\lceil72dQn^2\ln(2M)\rceil+1\le72dn^3\ln(2M)+2$, because $Q\le s\le n$. So every $N\ge72dn^3\ln(2M)+2$ admits $w_t$.
2. **Residual of $tg$.** On $T$, $tg-\bar y=-(1-t)\bar y+te$ with $\lvert e\rvert\le a/2$. So $(tg-\bar y)^2\le(1-t)^2\bar y^2+ta+a^2/4$, and summing with weights $k_x$ (total $n$) gives $\mathcal R(tg)\le(1-t)^2G+n(ta+a^2/4)\le(1-t)^2G+2$ at $a=1/n$. Worst case over 2000 random and adversarial trials: $-5.8\cdot10^{-4}\le0$.
3. **Objective.** $cF(w_t)-W=c\kappa_N(w_t)+\mathcal R(tg)\le c\,dF_d+2+G[18dct^2+(1-t)^2]$, using $Q\le G$, which holds because $k_x\ge1$; the direction is right.
4. **Bracket.** The minimum is $1-\vartheta_c$ at $t=\vartheta_c\in(0,1]$ (sympy).
5. **Near-minimisers.** For $w\in\mathcal N_1$, $\mathcal R(z_w)=cF(w)-c\kappa_N(w)-W\le c(F(w_{\vartheta})+1)-W\le(1-\vartheta_c)G+E_0$. This is correct.
6. **Clipping.** Clipping is the projection onto $[-1,1]\ni\bar y_x$, so $\mathcal R(\operatorname{clip}z_w)\le\mathcal R(z_w)$; and $L_D(z_w)\ge L_D(\operatorname{clip}z_w)$ since $\lvert y\rvert\le1$. Lemma 1.2(b) gives the display.
   - The display is deterministic; "on the event of Lemma 1.3" is needed only for the asymptotics.
7. **Asymptotics.** On the event, $G=(1-e^{-\lambda})M(1+o(1))$ and $V=\lambda M(1+o(1))$. Moreover $E_0/(\vartheta_cG)=O(c^2d^5/M)\to0$ for $c\le\mathrm{poly}(d)$. So the excess is $\ge\gamma(\lambda)\vartheta_c^2(1-o(1))$. As $c\to0$, $\vartheta_c\to1$ and the bound tends to $\gamma(\lambda)$, a constant (issue 1).
8. **Gibbs and posterior means.** These follow by §2.1, with the liminf. For the posterior mean, $\mathcal R(\mathbb E_\Pi z_w)\le\mathbb E_\Pi\mathcal R(z_w)\le\sup_{\mathcal N_1}\mathcal R+o_\sigma(1)$ uniformly in the sample; then apply Lemma 1.2(b) and let $\sigma\downarrow0$. The same works for $\mathbb E_\Pi\operatorname{clip}z_w$.

**No circularity and no misapplied lemma. Theorem 5.1 is correct.**

### 2.6 Corollary 5.2

- **Refutation (correct).** Take the zero competitor $(m,B)=(1,1)$, $\delta$ fixed, $\varepsilon_d=\gamma/(3(18dc+1)^2)$ and $n=\lceil\lambda2^d\rceil$.
  - For $c\le\mathrm{poly}(d)$, $1/\varepsilon_d=\mathrm{poly}(d)$, so $n>p(d,1,1,1/\varepsilon_d,\log\frac1\delta)$ eventually.
  - The excess is $\ge3\varepsilon_d(1-o(1))>\varepsilon_d$ with probability $\to1>1-\delta$.
  - The learner width $N\ge72dn^3\ln(2M)+2\ge m$ is admissible in the width-uniform formalisation.
  - If $c=c(n)$ is a function of $n$, the condition reads $c(\lceil\lambda2^d\rceil)\le\mathrm{poly}(d)$, that is, $c(n)\le\mathrm{polylog}(n)$.
- **"Does not refute the $+o(1)$ formulation, since $\varepsilon_d\asymp1/\log^2n$": wrong on part of the stated range.**
  - $\varepsilon_d\asymp1/\log^2n$ holds only for $c$ bounded above and below. For "every $c\le\mathrm{poly}(d)$", $\varepsilon_d\asymp(dc+1)^{-2}$, which is $\Theta(1)$ when $c=O(1/d)$.
  - Two refutations follow (`small_c.out`).
    - *(ii-a)* $c=\kappa/d$: Theorem 5.1's own bound gives excess $\ge\gamma(\lambda)/(18\kappa+1)^2-o(1)$; this is $0.0277$ at $\kappa=0.05$.
    - *(ii-b)* $dc\to0$: then $\mathcal R(z_w)\le(1-\vartheta_c)G+E_0\le18dcG+c(dF_d+1)+2=o(M)$ on $\mathcal N_1$. Lemma 1.2(a), exactly as in Theorem 2.2 part 1, gives excess $\ge(\sqrt{Q/M}-\sqrt{o(1)})^2=\beta(\lambda)-o(1)$. Explicit values at $c=d^{-3}$: $0.342$ ($d=30$), $0.410$ ($d=60$), $0.462$ ($d=200$), against $\beta(1)=0.4848$.
  - Both transfer to Gibbs and posterior means as in Theorem 2.2 part 2.
  - With $d=\log_2(n/\lambda)$, this refutes "test loss $\le$ min over width/weights $\le n^\alpha$, $+o(1)$" for depth-two SP$_{c(n)}$ with $c(n)\le\kappa/\log_2n$. This assumes the $o(1)$ is uniform over $d\le\log_2n+O(1)$, the reading under which A3 says Theorem 2.2 "refutes both".
  - The sentence is true only for $c\ge c_0>0$, in particular for every fixed $c$, which is the first half of the corollary's opening clause.
- **Numerical remark.** "Positive from $d\approx30$ on, about $2\cdot10^{-7}$" is slightly off: the bound is $2.0\cdot10^{-8}$ at $d=30$ and peaks at $2.3\cdot10^{-7}$ at $d=35$. Trivial.

### 2.7 Proposition 5.3

1. **Orthogonality.** $u\cdot a_k=M^{-1}\sum_{j\in T}\bar y_ja_j\cdot a_k=\bar y_k\mathbf 1_T(k)$ and $\lVert u\rVert^2=Q/M$.
2. **Energy.** $\kappa_N=\frac dN\cdot N\epsilon^2\lVert u\rVert^2+N\cdot N(N\epsilon)^{-2}=\epsilon^2Q+\epsilon^{-2}$. This uses $d=M$; the minimum at $\epsilon^2=Q^{-1/2}$ is $2\sqrt Q$.
3. **Accuracy.** $\lvert\tanh s-s\rvert\le\lvert s\rvert^3/3$ gives $\lvert z(a_k)-\bar y_k\rvert\le\epsilon^2/3$ on $T$, and $z=0$ off $T$. Then $\mathcal R(z)\le n\epsilon^4/9=n/(9Q)$.
4. **Near-minimisers.** For $w\in\mathcal N_1$, $\mathcal R(z_w)\le c(F(w_u)+1)-W=c(2\sqrt Q+1)+\mathcal R(z_{w_u})$. This gives the stated bound for every $N\ge1$ (all rows equal) and every $c>0$, provided $Q>0$ (true on the event).
5. **Conclusion.** On the Lemma 1.3 event, $Q=\Theta(M)$. If $c=o(\sqrt M)$ then $\mathcal R=o(M)$, and Lemma 1.2(a) gives $\ge(\sqrt{Q/M}-o(1))^2\to\beta(\lambda)$. Gibbs and posterior means follow via Lemma 1.1, as in Theorem 2.2. The rate is slow:
   $$o(1)=O\bigl(\sqrt c\,M^{-1/4}\bigr).$$
   At $c=1$ the explicit bound is $0.237$ ($M=1024$) and $0.299$ ($M=4096$), against $\beta=0.485$ (`check_hadamard.out`).
6. **Optimisation sanity check** (`opt_hadamard.out`, $N=8$, L-BFGS from the memorizer, from zero and from 4 random starts). The best networks found under the cube convention nearly interpolate:
   - $M=64$: $\mathcal R/G=0.03$, test excess $0.28$;
   - $M=256$: $\mathcal R/G=0.006$, test excess $0.43$;
   - at $c=4$: still $0.13$ and $0.20$.

   This is consistent with the proposition.

**"$n\asymp d$, so no contradiction with polynomial-in-$d$ bounds": correct.** Even $p$ linear in $d$ survives: the excess is about $\beta(\lambda)\approx1/\lambda$ for large $\lambda$, while $n=\lambda d$.

### 2.8 The paragraph "The positive side at $L=2$" (line 425)

This paragraph is not one of the three results, but it is the natural companion citation.

- **Clipping.** "(3.1) gives … $\approx8\mathcal D/\sqrt c$" uses (3.1), which is for **clipped** predictors. For unclipped ones, (3.2) at $H=1$ gives about $4\mathcal D\sqrt n/c$, which vanishes only for $c\gg\mathcal D\sqrt n$.
- **The lower bound.** "Between $\Omega(1/(dc)^2)$ and $O(d/\sqrt c)$" should read $\Omega((dc+1)^{-2})$; as written it exceeds 1 when $dc<1$.
- **"The depth-two threshold is $c^\star=\mathrm{polylog}(n)$"** is not supported by what RT wrote. For any fixed $c$, RT's only lower bound tends to $0$, so no constant-excess regime is exhibited on the cube.
  - With the repair of §2.6, the claim becomes defensible as a two-sided window for clipped predictors: constant excess for $c\le\kappa/\log n$, vanishing excess for $c\gg\log^2n$.
  - Between them, only $\Omega((dc)^{-2})$ versus $O(d/\sqrt c)$ is known.

---

## 3. Issues, most severe first

1. **Major (false scope claim). Location:** Corollary 5.2, last sentence (line 405); same in A3 (line 197, "Theorem 5.1 refutes only the polynomial one").
   - **Problem.** "It does not refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$" is stated after "every $c\le\mathrm{poly}(d)$". It fails for $c=O(1/d)$, where Theorem 5.1's own bound is a constant, and for $dc\to0$, where the proof gives excess $\ge\beta(\lambda)-o(1)$ via Lemma 1.2(a).
   - **Consequence.** Depth-two SP$_c$ with $c(n)=O(1/\log n)$, the "condition very closely" learner of the user's conjecture, has constant excess on the cube at $n=\lambda2^d$, just as at depth $\ge3$.
   - **Fix.** Restrict the sentence to $c\ge c_0>0$, add parts (ii-a) and (ii-b) of §4, and restrict §0 item 6's "Open" bullet explicitly to $c$ bounded below; it is headed "$c=1$" already.
2. **Minor (width). Location:** Corollary 5.2.
   - **Problem.** The corollary does not say that the failure is proved only at learner width $N\ge72dn^3\ln(2M)+2=\Theta(n^3\log^2n)$. That is polynomial in $n$ but exponential in $d$.
   - **Why it matters.** At widths with $N(d+2)\log n=o(n)$, the same learner's clipped predictors are consistent on every law, by Prop. 6.1 with the zero competitor (its display was confirmed in `RT-width-logic.md`; $P_N=N(d+2)$ at $L=2$). So the corollary refutes only the width-uniform inequality of BRIEF §1, which is how BRIEF formalises it.
   - **Fix.** State the width.
   - **Optional improvement.** Take $a=\eta(18dc+1)^{-1/2}$ instead of $a=1/n$, with a small constant $\eta$. The extra residual $n(\vartheta a+a^2/4)$ then stays a small fraction of $\vartheta G$, and $m_0=O((dc+1)d^2n)$. The cost is a constant factor in the bound; for example $\eta=\tfrac12$ keeps about $0.8\gamma\vartheta^2$.
3. **Minor (predictors). Location:** Theorem 5.1 and Corollary 5.2.
   - **Problem.** The progressive-mixture predictor of BRIEF §2 is not covered. The proof handles near-minimisers, Gibbs and posterior means only.
   - **Plausible extension, not proved.** Average the prefix correlations $\sum_xf_t(x)S^{(t)}_x$ and control the future-label cross terms.
   - **Fix.** Name the predictors in the corollary.
4. **Minor (input convention). Location:** Prop. 5.3 and the sentence "it does refute the user's dimension-free phrasing" (line 423).
   - **Problem.** The construction relies on $\lVert a_j\rVert=\sqrt d=\sqrt M$. Under `paper.tex`'s main unit-ball model, which BRIEF §2 allows as "(or unit ball)", inputs are $a_j/\sqrt M$.
     - The same memorizer then costs $2\sqrt{MQ}=\Theta(M)$, comparable to the gain $G$, and the proof fails.
     - Numerically the depth-two learner then does not memorise: the best networks found have $\mathcal R/G$ between $0.897$ and $1.000$ and test excess $\le0.003$ (`opt_hadamard.out`; local optimisation from 6 starts, so this is evidence, not proof).
   - **Scope.** The proposition is valid in BRIEF §1's formalisation ($X\subseteq[-1,1]^d$). Theorem 5.1 and Cor. 5.2 survive unit-ball normalisation with $dF_d$ replaced by $d^2F_d$ in $E_0$. The "dimension-free" refutation, however, is a statement about inputs whose norm grows like $\sqrt d$.
   - **Fix.** Say so.
5. **Minor (quantifier on $d$). Location:** Cor. 5.2 versus the paragraph after Prop. 5.3 and A3.
   - **Problem.** The "$+o(1)$" formulation must say over which $d$ the $o(1)$ is uniform.
     - Uniform over all $d$ (or $d\le n$): refuted at depth two by Prop. 5.3 (cube convention), at every $c=o(\sqrt n)$.
     - Uniform over $d\le\log_2n+O(1)$: refuted at depth two only for $c=O(1/\log n)$ (issue 1).
     - Fixed $d$: untouched.
   - **Fix.** State this table in the final note.
6. **Minor (wording and edge cases).**
   - In the "positive side" paragraph:
     - write $\Omega((dc+1)^{-2})$;
     - say that $O(d/\sqrt c)$ is for clipped predictors only;
     - restate "$c^\star=\mathrm{polylog}(n)$" as the two-sided window of §2.8.
   - Lemma 1.2(b) needs $V>0$, and Prop. 5.3 needs $Q>0$; both hold on the event.
   - "On the event of Lemma 1.3" in Theorem 5.1's display is superfluous.
   - The §5 heading "with $c=1$" is narrower than its content.
   - $\epsilon$ (network scale) clashes with $\varepsilon$ (accuracy).
   - Prop. 5.3's $o(1)$ is $O(\sqrt c\,M^{-1/4})$, so the constant is approached slowly.

Not checked here: the §5.4 numerics (`memorize_opt*.py`), the "Open" paragraph's $\beta^{\rm eff}$ estimates, and the §6.1 heuristic.

---

## 4. Strongest correct statement

**Setting.** Depth two ($H=1$) and the cube example $D_d$ (uniform $x\in\{-1,1\}^d$, fair sign $y$ independent of $x$, $\mathrm{OPT}=1$). Take $n=\lceil\lambda2^d\rceil$ samples, a learner width $N\ge72dn^3\ln(2M)+2$, and any $c=c_d>0$.

On an event of probability $\ge1-4e^{-n^{1/3}/2}-(4+2n/M)n^{-1/3}$ that depends on neither $N$ nor $\sigma$, every $w\in\mathcal N_1$ has $\mathcal R(z_w)\le(1-\vartheta_c)G+E_0$. The same lower bounds below hold for $z_w$ and $\operatorname{clip}z_w$, for the $\liminf_{\sigma\downarrow0}$ of the Gibbs risk, and for the risks of $\mathbb E_{\Pi_\sigma}z_w$ and $\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$:

$$
\text{excess}\ \ge\ \max\Bigl\{\tfrac{(\vartheta_cG-E_0)_+^2}{4MV},\ \tfrac1M\bigl(\sqrt Q-\sqrt{(1-\vartheta_c)G+E_0}\bigr)_+^2\Bigr\}.
$$

Consequently:

- **(i)** If $c\le\mathrm{poly}(d)$, the excess is $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ with probability $1-o(1)$, with $\gamma(1)=0.0999$. This refutes BRIEF §1's width-uniform polynomial-sample inequality for depth-two SP$_c$ (near-minimiser, Gibbs and posterior-mean predictors), for every $c(n)\le\mathrm{polylog}(n)$.
- **(ii-a)** If $c\le\kappa/d$, the excess is $\ge\gamma(\lambda)/(18\kappa+1)^2-o(1)$.
- **(ii-b)** If $dc\to0$, the excess is $\ge\beta(\lambda)-o(1)$.
  - In both (ii-a) and (ii-b) the "$+o(1)$" formulation, uniform over $d\le\log_2n+O(1)$, is refuted as well.
- **(iii)** Only for $c$ bounded below is the lower bound $\Theta(1/\log^2n)$, which leaves the "$+o(1)$" formulation open. At learner widths with $N(d+2)\log n=o(n)$, the clipped predictors of the same learner are consistent (Prop. 6.1), so the failure is a large-width phenomenon.

**Proposition 5.3 (as stated, correct).** Take inputs $a_j\in\{-1,1\}^M$ (rows of a Sylvester–Hadamard matrix, $d=M$, norm $\sqrt M$). Then for every width $N\ge1$ and every $c=o(\sqrt M)$, near-minimisers, Gibbs predictors and posterior means have excess $\ge\beta(\lambda)-O(\sqrt c\,M^{-1/4})$ with probability $1-o(1)$.

This refutes a depth-two "$+o(1)$" formulation that is uniform over $d\le n$, for inputs in $[-1,1]^d$. It does not contradict polynomial-in-$d$ sample bounds. It is not established under unit-ball input normalisation, where the same memorizer costs $\Theta(M)$.

---

## 5. Scripts and outputs (`../checks/verify-RT-depth2-logic/`)

| Script | What it checks | Result (`.out`) |
|---|---|---|
| `check_hadamard.py` | Prop. 5.3 with explicit weight matrices at $N\in\{1,2,7\}$, $M\in\{16,\dots,4096\}$, $\lambda\in\{1,1.5\}$: orthogonality, $\kappa_N=2\sqrt Q$, error $\le\epsilon^2/3$, $\mathcal R\le n/(9Q)$, residual bound, explicit excess bound | all assertions pass; largest error ratio $0.9915$; excess LB at $c=1$: $0.071$ ($M=64$), $0.138$ ($256$), $0.237$ ($1024$), $0.299$ ($4096$) |
| `check_lemma21_H1.py` | Lemma 2.1(2): exact parity mixture, total weight $\le A_0$, rows $\le F_d$, Hoeffding sampling, explicit width-$N$ network computing $tg$ with $\kappa_N\le dF_d+2t^2A_0^2$ ($d=4,5,6$) | all pass |
| `check_thm51_chain.py` | bracket (sympy); $\mathcal R(tg)$ bound (2000 random and adversarial trials); Lemma 1.2 (3000 trials); Lemma 1.3 moments (Monte Carlo); $\gamma$; first $d$ with a positive bound; width thresholds | all pass; first positive $d=30$ ($c=1$), $d=35$ ($c=4$); width at $d=30$: $5.7\cdot10^{31}$ |
| `small_c.py` | Theorem 5.1's bound for $c\in\{1,1/d,0.05/d,d^{-2},d^{-3}\}$ via Lemma 1.2(b) and (a), $d\in\{30,\dots,200\}$ | $c=0.05/d$: $0.0277$ for all $d$; $c=d^{-3}$: $0.342\to0.462$ ($\beta=0.485$); $c=1/d$: $3\cdot10^{-4}$ |
| `opt_hadamard.py` | L-BFGS minimisation of $F_c$ at depth two on Hadamard atoms, cube versus unit-ball inputs, $M\in\{64,256\}$, $c\in\{1,4\}$ | cube: test excess $0.28$, $0.43$ ($c=1$) and $0.13$, $0.20$ ($c=4$); ball: excess $\le0.003$, $\mathcal R/G\ge0.90$ |
| RT's `constants.py`, `bounds_table.py` (re-run) | $\beta,\gamma$, parity coefficients, Theorem 5.1 numbers | reproduced exactly |
