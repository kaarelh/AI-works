# Referee report (computation lens): Proposition 6.1 of `../research-notes/red-team.md`

**What was refereed.** This report covers `../research-notes/red-team.md` §6.3:

- Proposition 6.1 ("fixed polynomial learner width") and its proof;
- the "In particular" clause: $c=1$, learner width $\lceil n^\alpha\rceil$, competitors of width and weights $\le n^\alpha$, $d\le n^\alpha$, excess $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$, "polynomially small for $\alpha<1/4$";
- the closing sentence on where the width transition lies.

The proof uses three inputs, all re-checked:

- the first paragraph of Theorem 3.2 (clone, near-minimizer budget, $K$);
- `NNG/side-results/continuous-domains/source/paper.tex`, eq. `teacher-energy` (lines 297–308);
- for transferring the result to the posterior, Lemma 1.1.

The report contains no "Lemma 2.3"; I took the task's "Lemma 2.3-type facts" to mean these inputs.

Scripts and their outputs are in `../checks/verify-RT-width-computation/` (Appendix).

## Verdict: major flaw, repairable

1. **The displayed inequality of Proposition 6.1 is correct.** I re-derived every constant: entry bounds, perturbation recursion, mesh, log-cardinality, Hoeffding plus union bound, the $8/n$ discretization term, and the probability accounting. The probability accounting is conservative.
2. **The "In particular" clause is misderived, and it is the part the note wants to cite.** The displayed bound contains the competitor's Hoeffding term $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$, and the stated rate omits it.
   - In the stated class, $U=mB$ can be $\lceil n^\alpha\rceil n^\alpha$, so this term is $\Theta(n^{4\alpha-1/2})$, and it is the dominant term of the bound.
   - Read off the displayed bound, the excess is $O(n^{4\alpha-1/2}\sqrt{\ln(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n})$. This is polynomially small only for $\alpha<1/8$, and it **diverges** for $1/8<\alpha<1/4$. For example, at $\alpha=0.2$, $n=10^{12}$ the bound is $5.9\cdot10^3$.
3. **Repair.** Apply Bernstein's inequality to the competitor's empirical loss, with $L_D(g)\le1$, which holds without loss of generality because the zero network is in the class.
   - This restores "polynomially small for every $\alpha<1/4$".
   - The rate becomes $\tilde O(n^{2\alpha-1/2})$, not $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$.
   - An explicit competitor in the class (§3.3) shows that $\hat L(g)-L_D(g)$ really fluctuates at scale $U/\sqrt n\asymp n^{2\alpha-1/2}$. So the stated rate cannot come out of this proof; it is unproven.
4. **Knock-on.** Section 0 item 1 and A2 cite Proposition 6.1 for "every competitor of width $\le N$" at $N\le n^{1/2-\epsilon}$. With fixed $B$, that needs the same Bernstein repair whenever $\epsilon<1/4$ (§4).
5. **Closing sentence.** On the cube example at $c=1$, it is right up to a $\sqrt{\log n}$ factor at the lower end and large constants at the upper end. Four qualifications are needed (§5): it holds only for the cube example; at the upper end the excess is reduced; the window depends on the competitor class; and nothing shows the failure set in $N$ is an interval.

---

## 1. Inputs

- **Clone energy.** `paper.tex` lines 297–308: balanced groups $k_j\in\{\lfloor N/C\rfloor,\lceil N/C\rceil\}$ give an exact clone at every $N\ge C$, with energy at most $E_*=d(d+1)B^2+2(L-1)C^2B^2$. I re-derived the three contributions:
  - first layer: $\frac dN\cdot N(d+1)B^2$;
  - each internal layer: $\sum_{ij}(k_i/k_j)W_{ij}^2\le2C^2B^2$;
  - readout: $N\sum_jv_j^2/k_j\le2C\cdot CB^2$.

  This matches the report's $E_*$ with $C=m$.
- **$U=mB\ge\sup\lvert g\rvert$.** True, and attained: the network in §3.3 has $\sup\lvert g\rvert/U=1.000$.
- **Budget (Theorem 3.2, first paragraph).** For $w\in\mathcal N_1$, $F(w)\le F(w_g)+1$. This gives $\kappa_N(w)\le K=E_*+1+n(U+1)^2/c$ and $\hat L(z_w)\le\hat L(g)+c(E_*+1)/n$. Correct.
- **Lemma 1.1.** I re-checked the inequality $(1+t)e^{-t/2\sigma^2}\le(1+2\sigma^2/\alpha)e^{-(1-\alpha)t/2\sigma^2}$ (the maximum of $(1+t)e^{-st}$ is $\le\max(1,1/s)$), the Gaussian integral, and the choice of $\alpha$. All correct. Proposition 6.1 does not invoke Lemma 1.1, but it is needed for the claim that "the same learner" (its Gibbs and posterior-mean predictors) is consistent (minor issue 4 in §6).

## 2. The displayed inequality, step by step

**2.1 Entry bounds.** On $\mathcal W_K=\{\kappa_N\le K\}$ the entries are bounded by $\sqrt{KN/d}$, $\sqrt K$ and $\sqrt{K/N}$, all at most $\sqrt{KN}$. The count $P_N=N(d+1)+(L-2)N^2+N$ is the exact number of parameters. Correct.

**2.2 Perturbation.** Let $w\in\mathcal W_K$ and $\lVert w-w'\rVert_\infty\le\delta'$.

- First layer: $\lVert\Delta W^1\bar x\rVert_2\le\delta'\lVert\bar x\rVert_1\sqrt N\le\delta'(d+1)\sqrt N$.
- Next layers: $e_\ell\le\lVert W^\ell\rVert_{\rm op}e_{\ell-1}+\lVert\Delta W^\ell\rVert_F\lVert h'^{\ell-1}\rVert_2\le\sqrt Ke_{\ell-1}+\delta'N\cdot\sqrt N$. The norm of the *unperturbed* $W^\ell$ is used, as it must be.
- Output: $\lvert v^\top(h^H-h'^H)\rvert+\lvert(v-v')^\top h'^H\rvert\le\sqrt{K/N}\,e_H+\delta'N$.

Chaining gives the exact bound
$$
\lvert z_w-z_{w'}\rvert\le\delta'\Bigl[(d+1)K^{H/2}+N\textstyle\sum_{j=0}^{H-1}K^{j/2}\Bigr]\le\delta'H(d+N+1)(K+1)^{H/2},
$$
where the last step uses $K^{j/2}\le(K+1)^{H/2}$ and $d+1+NH\le H(d+N+1)$. All three steps are correct.

Numerical check (`perturb.py`):

- 4608 instances with $H=1..4$, $d\in\{1,3,8\}$, $N\in\{2,5,16,40\}$, $K\in\{0.5,3,20,200\}$, and four weight modes: Dirichlet energy split, equal split, rank-one internal layers, and rank-one layers in the linear regime with $h^1(x)=0$.
- Perturbations: random signs, and a projected sign-gradient ascent over the $\ell_\infty$ box (the worst perturbation found).
- Each one-step inequality was tested with the actual $e_{\ell-1}$, as well as the chained bound and the closed form. There were **0 violations**.
- The largest observed $\lvert\Delta z\rvert$ was 0.70 of the chained bound; the largest ratio to the closed form, over all instances, was 0.40. A grid check confirms chained $\le$ closed (maximum ratio 0.999).

**2.3 Grid and log-cardinality.** With $\delta'=1/(nH(d+N+1)(K+1)^{H/2})$:

- A grid of spacing $\delta'$ on $[-\sqrt{KN},\sqrt{KN}]$ has $\lceil2\sqrt{KN}/\delta'\rceil+1\le2+2\sqrt{KN}/\delta'$ points.
- Its covering radius is $\delta'/2$ (checked in `grid_union.py`).
- $2\sqrt{KN}/\delta'=2n\sqrt{KN}H(d+N+1)(K+1)^{H/2}$, which matches the displayed logarithm exactly.
- The grid depends only on $(n,c,N,d,L,E_*,U)$, so it is fixed before the data. Correct.

**2.4 Uniform deviation and assembly.**

- The clipped loss takes values in $[0,4]$ and is 4-Lipschitz in $u$, since $\lvert\operatorname{clip}u+\operatorname{clip}u'-2y\rvert\le4$.
- One-sided Hoeffding plus a union bound at level $\delta/4$ solves $\lvert G\rvert e^{-nt^2/8}=\delta/4$, giving $t=4\sqrt{(\ln\lvert G\rvert+\ln(4/\delta))/(2n)}$ (sympy-verified).
- Discretization costs $4\cdot\frac1n$ in each of $L_D$ and $\hat L$, hence $8/n$. Since the covering radius is $\delta'/2$, $4/n$ would suffice.
- $\hat L(\operatorname{clip}z_w)\le\hat L(z_w)$ because $\lvert y\rvert\le1$.
- The competitor step is one-sided Hoeffding with range $(U+1)^2$ at level $\delta/4$, giving $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$ (sympy-verified).

The chain
$$
L_D(\operatorname{clip}z_w)\le\hat L(\operatorname{clip}z_{w'})+\text{dev}+\tfrac4n\le\hat L(z_w)+\text{dev}+\tfrac8n\le\hat L(g)+\tfrac{c(E_*+1)}n+\text{dev}+\tfrac8n
$$
is correct.

**2.5 Probability.** The total failure probability is at most $\delta/4+\delta/4=\delta/2\le\delta$, which is conservative.

**Conclusion for §2:** the displayed inequality holds as stated.

## 3. The "In particular" clause: an exponent error

### 3.1 Term by term

Set $c=1$, $N=\lceil n^\alpha\rceil$, $m\le N$, $B\le n^\alpha$, $d\le n^\alpha$, so $U=mB\le\lceil n^\alpha\rceil n^\alpha$.

| term of the displayed bound | order | in the report's rate? |
|---|---|---|
| $c(E_*+1)/n$, with $E_*\le(2L-1)(n^\alpha+1)^2n^{2\alpha}$ | $n^{4\alpha-1}$ | yes |
| $8/n$ | $n^{-1}$ | yes (negligible) |
| $4\sqrt{(P_N\ln(\cdot)+\ln(4/\delta))/(2n)}$, with $P_N=O(Ln^{2\alpha})$ and $\ln(\cdot)\approx C_H\ln n$ | $n^{\alpha-1/2}\sqrt{\log n}$ | yes |
| $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$ | $\boldsymbol{n^{4\alpha-1/2}}$ | **no** |

For the third row, $C_H=1+\tfrac{1+5\alpha}2+\alpha+\tfrac{H(1+4\alpha)}2$. Measured values: 3.2545 against 3.25 predicted at $\alpha=0.1$, and 4.0045 against 4.0 at $\alpha=0.2$ ($H=2$).

The last term dominates for every $\alpha>0$. The displayed bound therefore gives excess $O(n^{4\alpha-1/2}\sqrt{\ln(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n})$, which tends to 0 iff $\alpha<1/8$.

### 3.2 Numbers (`exponents.py`)

Local log–log slopes between $n=10^{100}$ and $10^{200}$ ($L=3$, $\delta=0.05$, extreme admissible $m=N$, $B=d=n^\alpha$):

| $\alpha$ | $c(E_*+1)/n$ (pred. $4\alpha-1$) | deviation (pred. $\alpha-\frac12$) | competitor Hoeffding (pred. $4\alpha-\frac12$) | Bernstein repair (pred. $2\alpha-\frac12$) |
|---|---|---|---|---|
| 0.10 | −0.600 | −0.398 | **−0.100** | −0.300 |
| 0.125 | −0.500 | −0.373 | **0.000** | −0.250 |
| 0.20 | −0.200 | −0.298 | **+0.300** | −0.100 |
| 0.24 | −0.040 | −0.258 | **+0.460** | −0.020 |

Values at $\alpha=0.2$, $L=3$:

| $n$ | $(E_*+1)/n$ | deviation | Hoeffding term | Bernstein term | report's rate expression | displayed total |
|---|---|---|---|---|---|---|
| $10^{12}$ | 0.020 | 0.0107 | $5.9\cdot10^3$ | 0.199 | 0.0053 | $5.9\cdot10^3$ |
| $10^{40}$ | $5\cdot10^{-8}$ | $8\cdot10^{-11}$ | $1.5\cdot10^{12}$ | $3.0\cdot10^{-4}$ | $1.0\cdot10^{-8}$ | $1.5\cdot10^{12}$ |

At $n=10^{100},10^{200},10^{400}$ the displayed total is:

- $\alpha=0.12$: $0.0148$, $1.5\cdot10^{-4}$, $1.5\cdot10^{-8}$ (tends to 0);
- $\alpha=0.13$: $148$, $1.5\cdot10^4$, $1.5\cdot10^8$ (diverges).

So the threshold of the displayed bound is $\alpha=1/8$. The pattern is identical for $L=2,3,4$.

### 3.3 Not just a loose inequality: an explicit competitor (`competitor_fluct.py`)

Take depth 3, even width $m\le\lceil n^\alpha\rceil$, all weights in $[-B,B]$ with $B=n^\alpha$.

- **Layer 1.** Neuron 1 has row $(B,0,\dots)$, giving the constant $\tanh B$. Neurons $2..m$ have row $(0,B,0,\dots)$, giving $\tanh(Bx_1)$.
- **Layer 2.** The first half takes weight $B$ from neurons $2..m$. The second half takes weight $B$ from neuron 1 only.
- **Readout.** $+B$ on the first half and $-B$ on the second.

The output is $g=\tfrac m2B[\tanh(B(m-1)\tanh(Bx_1))-\tanh(B\tanh B)]$. It is $\approx0$ at $x_1=1$ and $\approx-mB=-U$ at $x_1=-1$ (computed $\sup\lvert g\rvert/U=1.000$).

Let $D$ put mass $p=1/(2g(x^{(1)})^2)$ on $x^{(1)}=(-1,0,0)$, the rest on $x^{(0)}=(1,0,0)$, and set $y=0$. Then $L_D(g)=1/2$, and the exact binomial law of $\hat L(g)$ gives:

| $\alpha$ | $n$ | $U$ | sd$(\hat L(g))$ | $U/\sqrt n$ | 95% quantile of $\hat L-L_D$ | Bernstein, level $1-\delta/4$ | Hoeffding term | report's rate | ratio (quantile/rate) |
|---|---|---|---|---|---|---|---|---|---|
| 0.2 | $10^6$ | 253.6 | 0.179 | 0.254 | 0.336 | 0.722 | 95.9 | 0.122 | 2.8 |
| 0.2 | $10^{10}$ | $10^4$ | 0.0707 | 0.100 | 0.120 | 0.239 | $1.5\cdot10^3$ | 0.0148 | 8.1 |
| 0.2 | $10^{12}$ | $6.3\cdot10^4$ | 0.0448 | 0.0633 | 0.0730 | 0.144 | $5.9\cdot10^3$ | 0.0053 | 13.8 |
| 0.1 | $10^{12}$ | 253.6 | 0.0002 | 0.0003 | 0.0003 | 0.0005 | 0.0959 | $8.3\cdot10^{-5}$ | 3.5 |

The proof's chain ends in $\hat L(g)$. To state the result in terms of $L_D(g)$, it needs an upper bound on $\hat L(g)-L_D(g)$ that holds with probability $\ge1-\delta/4$ for every admissible $(D,g)$. Two conclusions follow:

- That bound must be of order $U/\sqrt n\asymp n^{2\alpha-1/2}$. It exceeds the report's rate by a factor $\asymp n^\alpha/\sqrt{\log n}$, and the ratio grows from 2.8 to 13.8 between $n=10^6$ and $10^{12}$ at $\alpha=0.2$.
- Hoeffding overshoots by a further factor $U$; Bernstein is within a factor of about 2 of the true quantile.

This does **not** show that the learner's actual excess is that large: for this $D$ the learner beats $g$. It shows that the stated rate is not established by this proof, and cannot be.

### 3.4 Repair

**Bernstein step.** Let $\ell=(g(x)-y)^2\in[0,b]$ with $b=(U+1)^2$, mean $L_D(g)$, and $\operatorname{Var}\ell\le bL_D(g)$. With probability $\ge1-\delta/4$,
$$
\hat L(g)\le L_D(g)+(U+1)\sqrt{\frac{2L_D(g)\ln(4/\delta)}n}+\frac{2(U+1)^2\ln(4/\delta)}{3n}. \tag{B}
$$
The root formula was checked with sympy. Against exact binomial tails for two-valued losses, the worst tail was $1.5\cdot10^{-3}\le\delta/4=0.0125$ (`bernstein_repair.py`).

**Reduction to $L_D(g)\le1$.** The zero network lies in the class, so $\min_{\mathcal G}L_D\le L_D(0)\le1$. Apply (B) to a best-in-class $g^*$; it exists because the parameter set is compact and $L_D$ is continuous in the parameters. To bound the excess against an arbitrary $g$ with $L_D(g)>1$, compare with the zero network instead, at the cost of one more $\delta/4$ event. Define $K$ and the grid with the class maxima $m=N$, $B=n^\beta$, so that a single grid serves every competitor.

**Resulting rate.** For competitors of width $\le n^\alpha$ and weights $\le n^\beta$, with $d\le n^\alpha$, the excess over the class minimum is
$$
O\Bigl(n^{2(\alpha+\beta)-1}\ln\tfrac4\delta+n^{\alpha+\beta-\frac12}\sqrt{\ln\tfrac4\delta}+n^{\alpha-\frac12}\sqrt{\ln n}\Bigr).
$$
The measured slopes match exactly for $(\alpha,\beta)=(0.2,0.2),(0.4,0),(0.3,0.15),(0.45,0.04)$ (`bernstein_repair.out`). This is polynomially small iff $\alpha+\beta<1/2$.

- For the stated class, $\beta=\alpha$, this is $\tilde O(n^{2\alpha-1/2})$: polynomially small for every $\alpha<1/4$, as claimed. The rate, however, is not the stated one.
- At $\alpha=1/4$ the barrier comes from the **competitor**, through the clone-energy budget $E_*/n$ and the loss range in (B). It does not come from the learner's parameter count, which alone would allow $\alpha<1/2$.
- With bounded competitor weights ($\beta=0$), every $\alpha<1/2$ works, at rate $\tilde O(n^{\alpha-1/2})$.

## 4. Knock-on in §0 item 1 and A2

A2 says that at $N\le n^{1/2-\epsilon}$ the learner "satisfies an agnostic oracle inequality against every competitor of width $\le N$ (Proposition 6.1)". With fixed $B$ and $m=N=n^{1/2-\epsilon}$, the displayed Hoeffding term is about $B^2n^{1/2-2\epsilon}$, which diverges for $\epsilon<1/4$ (`transition.py` (c), $d=10$, $B=1$):

| $\epsilon$ | $n$ | Hoeffding term | Bernstein term |
|---|---|---|---|
| 0.1 | $10^{20}$ | $1.5\cdot10^6$ | 0.030 |
| 0.1 | $10^{80}$ | $1.5\cdot10^{24}$ | $3\cdot10^{-8}$ |
| 0.2 | $10^{20}$ | 148 | $3\cdot10^{-4}$ |
| 0.2 | $10^{80}$ | $1.5\cdot10^{8}$ | $3\cdot10^{-16}$ |

As written, the A2 sentence needs either the Bernstein repair or the restriction $N\le n^{1/4-\epsilon}$. Section 0 item 1, "agnostically consistent" for a **fixed** competitor at $N\le n^{1/2-\epsilon}$, is fine as written. The A2 sentence "that statement is true for $\alpha<1/4$" inherits §3 and is true after the repair.

## 5. The closing sentence

> "Parameter counting cannot help once $N\gtrsim\sqrt n$, and A shows that the clean-label-scaled learner fails at $N\gtrsim d^2n$. For depth $\ge3$ the width transition therefore lies between $\sqrt n$ and $n\log^2n$."

**(a) Lower end** (cube example, zero competitor, $c=1$, $n=2^d$; `transition.py` (a)).

- The deviation term is at least $4\sqrt{(L-2)N^2\ln(2n)/(2n)}$, which is $\ge1$ once $N\ge\sqrt{n/(8(L-2)\ln 2n)}$. So the bound is vacuous already at $N\asymp\sqrt{n/\log n}$.
- The largest $N$ with deviation $\le\varepsilon$ is $N^*\approx0.020\sqrt{n/\ln n}$ for $\varepsilon=0.1$ and $\approx0.10\sqrt{n/\ln n}$ for $\varepsilon=0.5$. The ratio is stable for $d=40..100$ at $L=3$, while $N^*/\sqrt n$ keeps falling (from 0.0039 to 0.0024 for $\varepsilon=0.1$).
- So the proven-good range is $N\lesssim\sqrt{n/\log n}$, not $\sqrt n$. The sentence drops a $\sqrt{\log n}$ at the lower end while keeping $\log^2n$ at the upper end.

**(b) Upper end** (Theorem 2.2, $N_0=\lceil72dn\ln(2M)/a^2\rceil+1$).

- At fixed $a$, $N_0\approx72\ln2\cdot d(d+1)n/a^2$. Computed $N_0/(n\log_2^2n)$ is about 205 at $a=1/2$ and about 820 at $a=1/4$. So "$d^2n$", that is $n\log^2n$, is right up to these large constants.
- At those widths the proven excess is the **reduced** constant $(\sqrt{\beta(\lambda)}-\sqrt\lambda a)^2$: 0.0385 at $a=1/2$ and 0.199 at $a=1/4$ ($\lambda=1$, $\beta(1)=0.4848291$), not $\beta(\lambda)$.
- The full $\beta(\lambda)$ (choice (i), $a=n^{-1/3}$) needs $N_0\approx51\,d^2n^{5/3}$.

**(c) Qualifications.**

1. The window is established only for the cube family (and A′) at $c=1$ against the zero competitor.
2. "The transition" presumes one threshold. Nothing shows that the set of widths where the learner fails is an interval, i.e. monotone in $N$.
3. For the In-particular class (competitors tied to $n$), the positive side stops at $N\approx n^{1/4}$ because of the competitor-energy barrier of §3.4. The location of the window therefore depends on the competitor class.

With these provisos the sentence is correct as an order-of-magnitude statement: proven good for $N\lesssim\sqrt{n/\log n}$, proven bad for $N\gtrsim n\log^2n$.

## 6. Minor issues (harmless)

1. The probability accounting uses $\ln(4/\delta)$ for both events, so the total failure probability is $\delta/2$. This is conservative.
2. The covering radius is $\delta'/2$, so $8/n$ could be $4/n$.
3. "For $L\ge3$" in the clause is unnecessary. With $d\le n^\alpha$, $L=2$ has $P_N=N(d+2)=O(n^{2\alpha})$ and the same exponents; the measured slopes are identical at $L=2$.
4. Proposition 6.1 is stated for near-minimizers only. Sections 0, 6.3 and 7 speak of "the same learner". Transferring to Gibbs and to the posterior mean of clipped outputs needs Lemma 1.1 with the bounded $\Phi=L_D(\operatorname{clip}z_w)\le4$, plus convexity of $L_D$. One sentence, as in Theorem 3.2, should be added.
5. The sample event depends on $N$, because the grid does. The statement is per width. Uniformity over all $N\le n^{1/2}$ costs only an extra $\ln n$ in a union bound, and should be said if "every width $\le n^{1/2-\epsilon}$" is cited.
6. The $O(\cdot)$ in the clause hides $L$-dependent constants and the $\sqrt{\ln(1/\delta)}$ factor; both should be shown.
7. The perturbation bound is loose (observed at most 0.40 of the closed form). This is harmless, since it enters only inside a logarithm.

## 7. Strongest correct statement

**Proposition 6.1 (repaired).** The hypotheses are unchanged. With probability $\ge1-\delta$, every $w\in\mathcal N_1$ at width $N$ satisfies the displayed bound; the Hoeffding version is correct as stated. It also satisfies the same bound with the last term replaced by
$$
(U+1)\sqrt{\frac{2L_D(g)\ln(4/\delta)}{n}}+\frac{2(U+1)^2\ln(4/\delta)}{3n}.
$$

*Consequence.* Take $c=1$, $N=\lceil n^\alpha\rceil$, $d\le n^\alpha$, and let $\mathcal G_n$ be the class of depth-$L$ networks of width $\le N$ and weights $\le n^\beta$. Every near-minimizer satisfies
$$
L_D(\operatorname{clip}z_w)-\min_{\mathcal G_n}L_D\le C_L\Bigl[n^{2(\alpha+\beta)-1}\ln\tfrac4\delta+n^{\alpha+\beta-\frac12}\sqrt{\ln\tfrac4\delta}+n^{\alpha-\frac12}\sqrt{\ln n}\Bigr],
$$
and so does the strong-prior posterior (Gibbs, and the posterior mean of clipped outputs), by Lemma 1.1. The bound is polynomially small iff $\alpha+\beta<1/2$.

- In the report's class ($\beta=\alpha$) the excess is $\tilde O(n^{2\alpha-1/2})$, polynomially small for every $\alpha<1/4$.
- Using the displayed Hoeffding bound instead, the clause holds only for $\alpha<1/8$, with excess $O(n^{4\alpha-1/2}\sqrt{\ln(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n})$.
- The rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ is not established.

On the cube example at $c=1$, the proven-good widths are $N\lesssim\sqrt{n/\log n}$. The proven-bad widths are $N\gtrsim n\log^2n$, with excess $(\sqrt{\beta(\lambda)}-\sqrt\lambda a)^2$ at fixed accuracy $a$.

---

## Appendix: scripts (`../checks/verify-RT-width-computation/`)

| script | checks | output |
|---|---|---|
| `perturb.py` | one-step, chained and closed-form perturbation bounds; 4608 instances including projected sign-gradient worst cases | `perturb.out`: 0 violations; max ratio to chained bound 0.70, to closed form 0.40 |
| `grid_union.py` | grid count and covering radius; Hoeffding/union constant; competitor Hoeffding; Bernstein root (sympy) | `grid_union.out`: all match |
| `exponents.py` | term-by-term slopes and values of the bound for the In-particular class; $L=2,3,4$; threshold $\alpha=1/8$ | `exponents.out` |
| `competitor_fluct.py` | explicit admissible spiky competitor; exact binomial quantiles of $\hat L(g)-L_D(g)$ | `competitor_fluct.out` |
| `bernstein_repair.py` | validity of (B) against exact tails; slopes for general $(\alpha,\beta)$ | `bernstein_repair.out` |
| `transition.py` | closing-sentence window on the cube example; $N_0$ of Theorem 2.2; the A2 knock-on | `transition.out` |
