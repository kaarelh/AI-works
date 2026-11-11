# Referee report on `../research-notes/red-team.md` §6.3, Proposition 6.1 (learner width tied to $n$): logic and definitions

**Lens.** I checked quantifiers, the limit order ($\sigma\downarrow0$ after the sample and the width are fixed), case splits and definitions against `../research-notes/problem-brief.md` and the cited sources. I looked for circularity, misapplied lemmas, and missing hypotheses: widths, weight bounds, clipping, measurability, existence of minimizers, label range.

**What I read.**

- Under review: Proposition 6.1, its proof, and the closing paragraph (`../research-notes/red-team.md` lines 480–497).
- Everything the proof uses:
  - Lemma 1.0 and Lemma 1.1 (lines 37–71);
  - the first paragraph of the proof of Theorem 3.2 (lines 259–277);
  - Theorem 2.2 and Lemma 2.1 (lines 120–182), for the closing sentence.
- The places that cite the proposition: §0 item 1 (line 20), §0 item 7 (line 30), §2.3 A2 (line 196), §6.3 item 2 (line 475) and §7 item 6 (line 530).

**Abbreviations.** `NNG/` is the project folder `neural-network-generalization/` of this repository. `paper.tex` is `NNG/side-results/continuous-domains/source/paper.tex`.

**Scripts.** They are in `../checks/verify-RT-width-logic/` (Section 5).

## Verdict: major flaw (the claim survives after a repair)

- **The display is correct.** I re-derived the perturbation recursion, the grid mesh and log-cardinality, the uniform deviation and the comparison chain. Every step holds. I found no circularity and no misapplied lemma.
- **The "in particular" sentence is wrong.** It claims excess $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$, "polynomially small for $\alpha<1/4$". That does not follow from the display.
  - The display's last term, $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$, is the Hoeffding bound for the competitor's empirical loss. The sentence drops it.
  - For the stated class (competitor width up to $N=\lceil n^\alpha\rceil$, weights up to $B=n^\alpha$), $U=mB$ can reach $\lceil n^\alpha\rceil n^\alpha$. The term is then $\Theta(n^{4\alpha-1/2})$, and it dominates both claimed terms for every $\alpha>0$.
  - So the display gives a polynomially small excess **only for $\alpha<1/8$**. For $1/8<\alpha<1/4$ the displayed bound grows with $n$: at $\alpha=0.2$ it grows like $n^{0.3}$ (`exponents.out`).
- **The repair.** Replace Hoeffding for $g$ by Bernstein's inequality (the variance is at most $(U+1)^2L_D(g)$, and $L_D(g)<4$ may be assumed). This restores "polynomially small for every $\alpha<1/4$", with the slower rate $O_L\bigl(n^{2\alpha-1/2}\sqrt{\log(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n+\log(1/\delta)}\bigr)$, not the stated one.
- **The stated rate cannot be recovered by sharpening the concentration step.** The proof bounds the learner through $\hat L(g)$, so its rate is no better than the upper tail of $\hat L(g)-L_D(g)$ over the class. For a competitor in the class, that tail is $\Theta(U/\sqrt n)=\Theta(n^{2\alpha-1/2})$, which exceeds the claimed rate by a factor that grows like $n^{\min\{\alpha,\,1/2-2\alpha\}}$ up to logarithms (exact binomial computation, `competitor_fluctuation.out`).
- **Other issues are minor.** They concern which predictors are covered (clipped only), the unstated passage from near-minimizers to the Bayesian learner, the infimum over the class, and the qualifiers that the closing sentence on the width transition needs. Section 3 lists them all.

### Answers to the focus questions

1. **Perturbation bound: correct.** Re-derived in §2.4, including a sharper intermediate form. On 800 random networks, each perturbed in 6 ways (three kinds of perturbation, both signs), the largest ratio of actual change to the sharper form was $0.607$ (`check_perturbation.out`).
2. **Grid mesh and log-cardinality: correct.** With mesh $\delta'=1/(nH(d+N+1)(K+1)^{H/2})$ on $[-\sqrt{KN},\sqrt{KN}]^{P_N}$, each coordinate has at most $2+2\sqrt{KN}/\delta'$ grid values. That is exactly the displayed argument of the logarithm (§2.5).
3. **Uniform deviation: correct, and slightly conservative.** The two Hoeffding events each have failure probability $\delta/4$ (§2.6).
4. **Exponents: wrong.** The competitor term $\Theta(n^{4\alpha-1/2})$ is dropped (§2.8, issue 1).
5. **Polynomially small for $\alpha<1/4$: not from the display, which gives only $\alpha<1/8$.** It is true after the Bernstein repair. The repaired range $\alpha<1/4$ is close to the best possible for this version: `../research-notes/B-tempered-likelihood.md` Proposition 9.1 with Lemma 9.2 shows that SP$_1$ fails against this class at every width once $\alpha>L/(2(2L-1))$ (issue 8).
6. **Closing sentence: essentially right, but it needs four qualifiers.** Success is proved for $N=o(\sqrt{n/\log n})$, not up to $\sqrt n$, and only for clipped predictions. The failure at $N\gtrsim d^2n$ is on the cube family with $n\approx\lambda2^d$, at a fixed memorizer accuracy $a$, with a constant excess below $\beta(\lambda)$. "Transition" should be read as "success proved below, failure proved above, open in between" (issue 7).

---

## 1. Statements compared against the sources

| use in Prop. 6.1 or its proof | source (opened and compared) | match |
|---|---|---|
| Architecture: $h^0=\bar x=(1,x)$, $h^\ell=\tanh(W^\ell h^{\ell-1})$, $z_w=v^\top h^{L-1}$, all hidden layers of width $N$, no internal biases, linear readout | `paper.tex` lines 114–125; `../research-notes/problem-brief.md` §2 | yes. $P_N=N(d+1)+(L-2)N^2+N$ counts exactly these parameters |
| Energy $\kappa_N=\frac dN\lVert W^1\rVert_F^2+\sum_{\ell=2}^{L-1}\lVert W^\ell\rVert_F^2+N\lVert v\rVert^2$ | `paper.tex` eq. `energy` (lines 293–296) | yes |
| Competitor: depth $L$, width $m$, weights in $[-B,B]$, $B\ge1$ | `paper.tex` lines 122–124 (teacher of the same depth, width $C\ge1$, weights at most $B\ge1$) | yes, provided the competitor has the **repository architecture** (same depth, no internal biases). This is implicit in Theorem 3.2 and should be stated (issue 5) |
| Exact clone at every $N\ge m$ with $\kappa_N\le E_*=d(d+1)B^2+2(L-1)m^2B^2$ | eq. `teacher-energy` (lines 297–308) | yes. I re-derived the three contributions: first layer $\le d(d+1)B^2$; each internal layer $\le2m^2B^2$ (because $\max k/\min k\le2$); readout $\le2m^2B^2$ (because $N/\min k\le2m$) |
| $X\subseteq[-1,1]^d$ | `../research-notes/problem-brief.md` §1; `paper.tex` Remark `cube` (lines 225–232) | yes. The perturbation bound uses only $\lVert\bar x\rVert_1\le d+1$, which holds on the cube and on the unit ball |
| Labels $y\in[-1,1]$ | `../research-notes/problem-brief.md` §1 | used for: the clipped loss is 4-Lipschitz with range $[0,4]$; $\hat L(\operatorname{clip}z)\le\hat L(z)$; $\hat L(g)\le(U+1)^2$; uniformity in Lemma 1.1 |
| SP$_1$ is "the clean-label-scaled learner" | `NNG/works-in-progress/slt-likelihood/README.md` §2 (observation variance $\sigma^2$, i.e. $c=1$, objective $J_S=\kappa_N+\sum_i(z_w(x_i)-f(x_i))^2$) | yes |
| Strong-prior limit order: $N$ and $n$ fixed, $\sigma_0$ may depend on them, uniform over $D$ | `paper.tex` Theorem `strong` (lines 178–197); slt-likelihood §2 ("$\sigma_0$ may depend on the selected $n,N$ … uniform over $D$") | yes, via `../research-notes/red-team.md` Lemma 1.1, whose threshold depends on $(N,n,c,\zeta)$ only and is uniform over samples and over $D$ |
| Lemma `posterior`, Prop. `exact`, Theorem `strong` (cover route) | `paper.tex` lines 248–268, 613–645, 510–533 | **not used** by Prop. 6.1, which replaces the width-free energy cover by a width-dependent parameter grid. This is consistent: a parameter grid needs no cover and pays $P_N$ |
| Brief's formalisation (uniform over learner width $N\ge m$) | `../research-notes/problem-brief.md` §1 | Prop. 6.1 is **not** width-uniform: $N=\lceil n^\alpha\rceil$ is tied to $n$. `../research-notes/red-team.md` says so explicitly (A2, §6.3 item 2). It is the brief's alternative reading "min over width and weights $\le n^\alpha$, plus $o(1)$", with the learner's width fixed to $\lceil n^\alpha\rceil$ |

---

## 2. Audit of the proof

### 2.1 Setting and quantifiers

The fixed objects are $L=H+1\ge2$, $c>0$, $\delta\in(0,1)$, a law $D$ on $X\times[-1,1]$, a competitor $g$ $(m,B\ge1)$, and a learner width $N\ge m$. The derived quantities are $U=mB$, $E_*$, $K=E_*+1+n(U+1)^2/c$ and $P_N$.

The claim reads: there is an event $\mathcal E$ with $D^n(\mathcal E)\ge1-\delta$ on which every $w\in\mathcal N_1=\{F_{c,S}\le\min F_{c,S}+1\}$ at width $N$ satisfies the display.

- $\mathcal E$ does not depend on $\sigma$.
- $\mathcal E$ depends on $N$ through the grid. That is fine for a fixed $N$. Unlike Theorem 3.2, the statement is not simultaneous in $N$, and it does not claim to be.
- $\min F_{c,S}$ is attained, because $F_{c,S}$ is continuous and $F_{c,S}\ge\kappa_N$ is coercive (Lemma 1.1). So $\mathcal N_1\neq\emptyset$.
- The proof exhibits a measurable sub-event (the intersection of two Hoeffding events). Measurability of "every $w\in\mathcal N_1$ satisfies …" is not needed.

### 2.2 Step 1: near-minimizers have bounded energy and small training loss

Let $w_g$ be the exact clone at width $N\ge m$. Then $\min F\le F(w_g)$, so for $w\in\mathcal N_1$:

$$
\kappa_N(w)+\tfrac nc\hat L(z_w)\le E_*+1+\tfrac nc\hat L(g).
$$

Since $\kappa_N\ge0$, this gives $\hat L(z_w)\le\hat L(g)+c(E_*+1)/n$. Since $\hat L(g)\le(U+1)^2$, it also gives $\kappa_N(w)\le K$. ✓ (This is the first paragraph of the proof of Theorem 3.2.)

### 2.3 Step 2: entry bounds on $\mathcal W_K=\{\kappa_N\le K\}$

The bounds are $\lvert W^1_{jk}\rvert\le\sqrt{KN/d}$, $\lvert W^\ell_{jk}\rvert\le\sqrt K$ and $\lvert v_j\rvert\le\sqrt{K/N}$. Each is at most $\sqrt{KN}$ because $d,N\ge1$. ✓

### 2.4 Step 3: the perturbation bound

Take $w\in\mathcal W_K$ and any $w'$ with $\lVert w-w'\rVert_\infty\le\delta'$. Then:

- $e_1=\lVert\tanh(W^1\bar x)-\tanh(W'^1\bar x)\rVert_2\le\sqrt N\,\delta'\lVert\bar x\rVert_1\le\delta'(d+1)\sqrt N$.
- For $\ell\ge2$, write $W^\ell h^{\ell-1}-W'^\ell h'^{\ell-1}=W^\ell(h^{\ell-1}-h'^{\ell-1})+(W^\ell-W'^\ell)h'^{\ell-1}$. This gives $e_\ell\le\lVert W^\ell\rVert_F e_{\ell-1}+\sqrt N\,\delta'\lVert h'^{\ell-1}\rVert_1\le\sqrt K e_{\ell-1}+\delta'N^{3/2}$. Only $w$'s norms and $\lvert h'\rvert\le1$ are used, so $w'$ need not lie in $\mathcal W_K$. ✓
- For the output, $\lvert v^\top h^H-v'^\top h'^H\rvert\le\lVert v\rVert_2e_H+\delta'\lVert h'^H\rVert_1\le\sqrt{K/N}\,e_H+\delta'N$. ✓

Unrolling the recursion gives the sharper intermediate form

$$
\sup_X\lvert z_w-z_{w'}\rvert\le\delta'\Bigl[(d+1)K^{H/2}+N\sum_{j=0}^{H-1}K^{j/2}\Bigr]\le\delta'\bigl(d+1+NH\bigr)(K+1)^{H/2}\le\delta'H(d+N+1)(K+1)^{H/2}. \quad✓
$$

For $L=2$ the recursion is empty, and the same formula holds with $H=1$.

Numerically (`check_perturbation.py`): over 800 random networks at energy exactly $K$, with four energy splits, $1\le H\le5$, $d\le8$ and $N\le16$, I applied random-sign, gradient-sign and activation-aligned perturbations of both signs (4,800 perturbed networks). There were no violations. The maximum of actual over sharper form was $0.607$, and of actual over stated form $0.380$. The algebraic inequality "sharper form $\le$ stated form" also holds on a parameter grid.

### 2.5 Step 4: grid and log-cardinality

The grid has mesh $\delta'=1/(nH(d+N+1)(K+1)^{H/2})$ on $[-\sqrt{KN},\sqrt{KN}]^{P_N}$.

- Each coordinate takes at most $\lfloor2\sqrt{KN}/\delta'\rfloor+1\le2+2n\sqrt{KN}H(d+N+1)(K+1)^{H/2}$ values. Raising this to the power $P_N$ gives exactly the displayed $\ln\lvert G\rvert$. ✓
- Every $w\in\mathcal W_K$ is within $\delta'/2\le\delta'$ in sup norm of a grid point, so $\sup_X\lvert z_w-z_{w'}\rvert\le1/n$ by Step 3.
- The grid depends on $(n,c,N,d,H,E_*,U)$ but not on the sample. ✓

### 2.6 Step 5: the uniform deviation and the comparison chain

- For each grid point $w'$, the loss $(\operatorname{clip}z_{w'}(x)-y)^2$ lies in $[0,4]$. Hoeffding's inequality and a union bound with total failure probability $\delta/4$ give $L_D(\operatorname{clip}z_{w'})\le\hat L(\operatorname{clip}z_{w'})+4\sqrt{(\ln\lvert G\rvert+\ln(4/\delta))/(2n)}$. ✓
- The map $u\mapsto(\operatorname{clip}u-y)^2$ is 4-Lipschitz for $\lvert y\rvert\le1$. So moving from $w$ to $w'$ and back costs at most $4/n$ in $L_D$ and $4/n$ in $\hat L$, which is the $8/n$ of the display. With the $\delta'/2$ rounding the cost would be $4/n$, so this is conservative. ✓
- $\hat L(\operatorname{clip}z_w)\le\hat L(z_w)$, because clipping is the projection onto $[-1,1]\ni y_i$. ✓
- Step 1 then gives $\hat L(z_w)\le\hat L(g)+c(E_*+1)/n$. ✓

### 2.7 Step 6: the competitor term

Hoeffding's inequality for the single function $g$, with loss range $[0,(U+1)^2]$ and failure probability $\delta/4$, gives

$$
\hat L(g)\le L_D(g)+(U+1)^2\sqrt{\ln(4/\delta)/(2n)}. \quad✓
$$

The total failure probability is $\delta/2\le\delta$. **The display is therefore correct as stated.**

### 2.8 Step 7: the "in particular" sentence, term by term

The setting is $c=1$, $N=\lceil n^\alpha\rceil$, competitor width $m\le N$, weights at most $B=n^\alpha$ (so $B\ge1$ as Theorem 3.2 requires), and $d\le n^\alpha$. At the worst case of the class:

| term of the display | order | claimed? |
|---|---|---|
| $c(E_*+1)/n$, with $E_*\le d(d+1)B^2+2(L-1)m^2B^2\le(8L-6)n^{4\alpha}$ | $n^{4\alpha-1}$ | yes |
| $8/n$ | $n^{-1}$ | (absorbed) |
| grid term, with $P_N=O(Ln^{2\alpha})$ and $\ln(\cdot)=O(L\ln n)$ since $K=O(n^{1+4\alpha})$ | $n^{\alpha-1/2}\sqrt{\log n}$ | yes |
| **$(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$, with $U=mB$ up to $\lceil n^\alpha\rceil n^\alpha$** | **$n^{4\alpha-1/2}\sqrt{\log(1/\delta)}$** | **no: dropped** |

The dropped term dominates the claimed rate for every $\alpha>0$, and it is not $o(1)$ for $\alpha\ge1/8$. `exponents.py` evaluates every term in 60-digit arithmetic at $L=3$ and $\delta=0.05$. The fitted asymptotic slopes (between $n=10^{150}$ and $10^{300}$) are $4\alpha-1$, $\alpha-1/2$ and $4\alpha-1/2$, matching theory to three decimals. The displayed right-hand side has slope:

- $-0.1$ at $\alpha=0.1$;
- $0$ at $\alpha=0.125$;
- $+0.1$ at $\alpha=0.15$;
- $+0.3$ at $\alpha=0.2$;
- $+0.46$ at $\alpha=0.24$.

At $\alpha=0.2$ and $n=10^{12}$ the displayed bound is $\approx6\cdot10^3$.

**The repair (Bernstein).** If $L_D(g)\ge4$, the conclusion is trivial, because $L_D(\operatorname{clip}z_w)\le4$. Otherwise $Z=(g(x)-y)^2\in[0,(U+1)^2]$ has $\operatorname{Var}Z\le(U+1)^2L_D(g)\le4(U+1)^2$, and Bernstein's inequality with failure probability $\delta/4$ gives

$$
\hat L(g)\le L_D(g)+(U+1)\sqrt{\frac{8\ln(4/\delta)}n}+\frac{2(U+1)^2\ln(4/\delta)}{3n}.
$$

For the class this is $O(n^{2\alpha-1/2}\sqrt{\log(1/\delta)}+n^{4\alpha-1}\log(1/\delta))$. With it, the excess is

$$
O_L\Bigl(n^{2\alpha-1/2}\sqrt{\log(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n+\log(1/\delta)}+n^{4\alpha-1}\log(1/\delta)\Bigr),
$$

which is polynomially small exactly for $\alpha<1/4$. The fitted slope of the repaired bound is $2\alpha-1/2$ in every row of `exponents.out`. For $\alpha<1/4$ the dominant term is $n^{2\alpha-1/2}$, not $n^{4\alpha-1}$ (their exponents vanish together at $\alpha=1/4$, since $4\alpha-1=2(2\alpha-1/2)$).

**This proof cannot deliver the claimed rate.** The chain bounds $L_D(\operatorname{clip}z_w)$ by $L_D(g)+[\hat L(g)-L_D(g)]+\dots$. Its rate, uniformly over the class, is therefore at least the upper $(1-\delta)$-quantile of $\hat L(g)-L_D(g)$. Here is a competitor in the class:

- $L=3$, $d=1$, $X=\{0,1\}$; first-layer rows $(0,B)$, internal weights $B$, readout weights $B$, width $m=\lceil n^\alpha\rceil$;
- so $g(x)=mB\tanh(mB\tanh(Bx))$, with $g(0)=0$ and $G=g(1)\approx mB$;
- the law: $x=1$ with probability $p=1/(G+1)^2$ and label $-1$; otherwise $x=0$ with label $0$.

Then $L_D(g)=1$, and the exact binomial $95\%$ quantile of $\hat L(g)-L_D(g)$ is $\approx1.65\,(G+1)/\sqrt n$. It exceeds the claimed rate $n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\ln n}$ by factors $2.7$–$7.5$ ($\alpha=0.1$), $5.7$–$35$ ($\alpha=0.15$) and $6.4$–$34$ ($\alpha=0.2$), for $n=10^8$ to $10^{14}$. The factors grow like $n^{\min\{\alpha,\,1/2-2\alpha\}}$ up to logarithms (`competitor_fluctuation.out`).

For this particular $g$ the *conclusion* still holds, because the zero competitor already gives it. So the example shows that the stated rate is **unproven**, not that it is false. Whether SP$_1$ at width $n^\alpha$ actually achieves $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ against the class minimum is open. The best competitor $g^*$ satisfies $\mathbb E g^{*2}\le1$ (shrink its readout), but nothing in the argument controls $\mathbb E(g^*-y)^4$ better than $(U+1)^2$.

### 2.9 Passage to the Bayesian learner (not stated in Proposition 6.1)

The "in particular" sentence says "the learner is the clean-label-scaled Bayesian learner ($c=1$, strong-prior limit)", but the proposition is proved only for $w\in\mathcal N_1$. The missing step is valid and short.

- **Gibbs risk.** Apply Lemma 1.1 with $\zeta=1$ and $\Phi(w)=L_D(\operatorname{clip}z_w)\in[0,4]$. $\Phi$ is continuous in $w$ by bounded convergence, hence measurable. This gives $\limsup_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_1}\Phi$.
- **Posterior mean.** By Jensen, the same bound holds for the posterior mean $\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$.
- **I re-checked Lemma 1.1 line by line.** The pointwise inequality $(1+t)e^{-t/(2\sigma^2)}\le(1+2\sigma^2/\alpha)e^{-(1-\alpha)t/(2\sigma^2)}$ holds. The monotonicity in $m_*$ that makes $\alpha$ uniform holds. The radius of the ball in $V$ is uniform in $S$, because $F_{c,S}$ is Lipschitz on a neighbourhood of $\{\kappa_N\le n/c\}$ with a constant that depends on $(N,n,c)$ but not on $S$.
- **The order of events is correct.** For each $n$, the width $N=\lceil n^\alpha\rceil$ and the sample are fixed first. The sample event does not involve $\sigma$. Then $\sigma\downarrow0$. Because Lemma 1.1 is uniform over samples, "with probability $\ge1-\delta$" and "for all $\sigma<\sigma_0(N,n,c)$" can be interchanged at a cost of an arbitrarily small additive slack.
- **Not covered:** the Gibbs risk or posterior mean of **unclipped** outputs, and $\operatorname{clip}(\mathbb E_\Pi z_w)$. On $\mathcal W_K$ unclipped outputs reach $\sqrt K=\Theta(n^{1/2+2\alpha})$, so the parameter-counting bound for the unclipped loss is vacuous (issue 3).

### 2.10 The closing sentence

> "Parameter counting cannot help once $N\gtrsim\sqrt n$, and A shows that the clean-label-scaled learner fails at $N\gtrsim d^2n$. For depth $\ge3$ the width transition therefore lies between $\sqrt n$ and $n\log^2n$."

- **"Parameter counting cannot help once $N\gtrsim\sqrt n$."** This is correct as a remark about the method: for $L\ge3$, $P_N\ge N^2$.
- **Lower end.**
  - For a fixed competitor (fixed $m,B$; here the zero network) on the cube family with $d\approx\log_2n$, the display's competitor term is $O(n^{-1/2})$. The grid term is $\Theta(\sqrt{N^2H\log n/n})$, so success is proved for $N=o(\sqrt{n/\log n})$, not up to $\sqrt n$.
  - It is proved for **clipped** predictions only (issue 3).
  - The Hoeffding problem of issue 1 does not arise here, because $U$ is fixed.
- **Upper end.** In `../research-notes/red-team.md` Theorem 2.2, $N_0=\lceil72dn\ln(2M)/a^2\rceil+1\approx50\,d(d+1)n/a^2$.
  - With a fixed accuracy $a$, the failure is a constant excess $(\sqrt{\beta(\lambda)}-\sqrt\lambda a)^2-o(1)$, below $\beta(\lambda)$.
  - The full $\beta(\lambda)$ needs $a=n^{-1/3}$, and then $N_0=\Theta(d^2n^{5/3})$.
  - On the cube family $n=\lceil\lambda2^d\rceil$, so $d^2n=\Theta(n\log^2n)$. ✓
  - The refereed companion `../research-notes/A-tight-conditioning-fails.md` (Theorem 4.4, Remark 4.7) has the same order, $N_0\approx44\,d(d+1)n/a^2$.
- **"Transition."** Nothing shows that the behaviour is monotone in $N$. What is proved: success for every $D$ when $N=o(\sqrt{n/\log n})$, and failure on one family when $N\ge C_a\,n\log^2n$. Between the two nothing is known. The two ends also carry different quantifiers ("for every $D$" versus "for the cube family"), so the sentence describes a worst case over $D$.

---

## 3. Issues

1. **Major. Location:** "In particular …" (line 486) and the proof's last line ("Finally use Hoeffding for $g$"). **Problem:** the claimed excess $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ drops the display's own competitor term $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$. That term is $\Theta(n^{4\alpha-1/2}\sqrt{\log(1/\delta)})$ for the stated class, because $U=mB$ can be $\lceil n^\alpha\rceil n^\alpha$. From the display, the excess is polynomially small only for $\alpha<1/8$; for $\alpha\in[1/8,1/4)$ the displayed bound does not tend to 0. The sharpest rate this proof can give is $\Theta(n^{2\alpha-1/2})$ (§2.8). **Fix:** replace Hoeffding for $g$ by Bernstein's inequality, with the case split $L_D(g)\ge4$ trivial, $L_D(g)<4$ giving variance $\le4(U+1)^2$. Then state the excess as $O_L(n^{2\alpha-1/2}\sqrt{\log(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n+\log(1/\delta)}+n^{4\alpha-1}\log(1/\delta))$, polynomially small for $\alpha<1/4$. Alternatively keep Hoeffding and restrict to $\alpha<1/8$ with rate $O_L(n^{4\alpha-1/2}\sqrt{\log(1/\delta)})$. `../research-notes/B-tempered-likelihood.md` Corollary 8.1 keeps this term correctly ("$4+(U+1)^2\le8n^{4\alpha}$, and $4\alpha-\frac12\le-\beta$"), so the companion documents are currently inconsistent on this point.

2. **Minor (inherits issue 1). Locations:** §2.3 A2 (line 196), "At $N\le n^{1/2-\epsilon}$ (for $L\ge3$), the same learner satisfies an agnostic oracle inequality against every competitor of width $\le N$", and "that statement is true for $\alpha<1/4$". **Problem:** with competitor width up to $N=n^{1/2-\epsilon}$ and a fixed weight bound $B$, the displayed Hoeffding term is $\approx B^2n^{1/2-2\epsilon}$, which diverges for $\epsilon<1/4$. **Fix:** the claim holds after the Bernstein repair, where the term becomes $\approx Bn^{-\epsilon}$; it also needs the weight bound $B$ fixed and $d\le n^{1/2-\epsilon}$. §0 item 1 ("agnostically consistent") and §7 item 6 concern a fixed competitor and are unaffected.

3. **Minor (scope). Locations:** line 486, "The learner is the clean-label-scaled Bayesian learner"; §0 item 1, "the same learner"; A2. **Problem:** Prop. 6.1 covers only **clipped** predictions: $\operatorname{clip}z_w$ for $w\in\mathcal N_1$, the Gibbs risk of $\operatorname{clip}z_w$, and $\mathbb E_\Pi\operatorname{clip}z_w$. The learner of Claim A is shown to fail for clipped and unclipped predictors alike. Unclipped near-minimizers can reach $\lvert z_w\rvert\approx\sqrt K=\Theta(n^{1/2+2\alpha})$, and no parameter-counting bound controls them. **Fix:** say "with clipped predictions" wherever Prop. 6.1 is cited as a positive result for "the same learner".

4. **Minor (unstated step). Location:** Prop. 6.1 is stated for $\mathcal N_1$, while line 486 speaks of the Bayesian learner in the strong-prior limit. **Fix:** add "By Lemma 1.1 (with $\zeta=1$, $\Phi=L_D(\operatorname{clip}z_w)\le4$) and Jensen, the right side also bounds $\limsup_{\sigma\downarrow0}$ of the Gibbs risk and the risk of $\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$, on the same $\sigma$-free event; $\sigma_0$ depends on $(N,n,c)$ only." This mirrors the last sentence of Theorem 3.2 (§2.9).

5. **Minor (hypotheses for "min over the class"). Location:** line 486. **Problem:** the display is per competitor. To state "test loss $\le\min_{\mathcal G}L_D+$ excess", one needs three things:
   - (i) uniform class bounds $U\le\lceil n^\alpha\rceil n^\alpha$ and $E_*\le(8L-6)n^{4\alpha}$, so that one grid serves the whole class;
   - (ii) existence of a minimizer $g^*$ (the parameter set is compact under zero padding and $L_D$ is continuous), or an approximate minimizer chosen independently of the sample, as in `../research-notes/C-fixed-temperature-bayes.md` §C.7;
   - (iii) the competitor class must be **repository-architecture** networks (same depth $L$, no internal biases, linear readout), because the exact clone in Step 1 requires it.

   **Fix:** state (i)–(iii) explicitly, as `../research-notes/B-tempered-likelihood.md` Corollary 8.1 does.

6. **Minor (notation). Location:** line 486, "$O(\cdot)$". **Problem:** the constant depends on $L$ (through $P_N$ and the logarithm) and on $\delta$. **Fix:** write $O_L(\cdot)$ and show the $\sqrt{\log(1/\delta)}$ factor. The phrase "for $L\ge3$" is harmless: for $L=2$, $P_N=N(d+2)=O(n^{2\alpha})$ as well.

7. **Minor (closing sentence). Location:** line 497.
   - (a) The lower end is $N=o(\sqrt{n/\log n})$, i.e. $n^{1/2-o(1)}$, not $\sqrt n$, and it is proved only for clipped predictions.
   - (b) The upper end holds on the cube family ($n\approx\lambda2^d$, so $d^2n=\Theta(n\log^2n)$) at a fixed memorizer accuracy $a$, with a constant excess $(\sqrt{\beta(\lambda)}-\sqrt\lambda a)^2$. The full $\beta(\lambda)$ needs $N_0=\Theta(d^2n^{5/3})$.
   - (c) "The width transition lies between" should read "success is proved for $N=o(\sqrt{n/\log n})$ (every $D$, clipped predictions) and failure for $N\ge C_a\,n\log^2n$ (cube family); in between nothing is known". No monotonicity in $N$ is shown.
   - (d) Both ends refer to $c=1$ and $H\ge2$.

8. **Context, not an error.** The repaired threshold $\alpha<1/4$ is close to the true one for this version. `../research-notes/B-tempered-likelihood.md` Proposition 9.1(a) and Lemma 9.2 (refereed) give the following on the noiseless two-point law $D_{\delta_0}$ ($d=1$):
   - every near-minimizer and every limiting posterior predictor of SP$_c$ has $L_D(\operatorname{clip}\cdot)\ge(1-\eta)^2$, with $\eta=\delta_0(K/L)^{L/2}$ and $K=n/c+1$, **at every width**;
   - the class of width $\lfloor n^\alpha\rfloor$ and weights $\le n^\alpha$ fits $D_{\delta_0}$ exactly once $\delta_0\ge(\tanh1)^{-H}/(m^HB^L)\approx1.31^Hn^{-\alpha(2L-1)}$.

   At $c=1$ this forces $\eta\to0$ whenever $\alpha>L/(2(2L-1))$. I re-derived the exponent, and the Lipschitz input (Lemma 1.0(2), AM–GM) is correct. So at learner width $\lceil n^\alpha\rceil$ the critical exponent of SP$_1$ lies in $[1/4,\,L/(2(2L-1))]$, for example $[0.25,0.30]$ at $L=3$. The final note can state this window.

I found no circularity, no misapplied lemma, no problem with the label range or clipping beyond issue 3, and no problem with the limit order.

---

## 4. Corrected statement (strongest version I can support)

**Proposition 6.1′.** Fix $L=H+1\ge2$, $c>0$, $\delta\in(0,1)$, a law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, and a competitor $g$ of the repository architecture (depth $L$, width $m$, weights in $[-B,B]$, $B\ge1$). Put $U=mB$, $E_*=d(d+1)B^2+2(L-1)m^2B^2$, $K=E_*+1+n(U+1)^2/c$ and $P_N=N(d+1)+(L-2)N^2+N$, and fix a learner width $N\ge m$. Then with probability at least $1-\delta$ over the sample, every $w\in\mathcal N_1$ at width $N$ satisfies

$$
L_D(\operatorname{clip}z_w)\le L_D(g)+\frac{c(E_*+1)}n+\frac8n+4\sqrt{\frac{P_N\ln\bigl(2+2n\sqrt{KN}H(d+N+1)(K+1)^{H/2}\bigr)+\ln(4/\delta)}{2n}}+\Gamma_n,
$$

where either $\Gamma_n=(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$ (Hoeffding, as in `../research-notes/red-team.md`), or, when $L_D(g)<4$, $\Gamma_n=(U+1)\sqrt{8\ln(4/\delta)/n}+\tfrac23(U+1)^2\ln(4/\delta)/n$ (Bernstein). When $L_D(g)\ge4$ the inequality is trivial. By Lemma 1.1 and Jensen, the same right side bounds $\limsup_{\sigma\downarrow0}$ of the Gibbs risk of $\operatorname{clip}z_w$ and the risk of $\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$, on the same $\sigma$-free event.

**Corollary (the user's formulation, learner width tied to $n$).** Let $c=1$, $N=\lceil n^\alpha\rceil$, and let $\mathcal G_n^{(\alpha)}$ be the repository-architecture depth-$L$ networks with width at most $N$ and weights in $[-n^\alpha,n^\alpha]$, with $d\le n^\alpha$. With probability at least $1-\delta$, the clipped near-minimizers, and in the strong-prior limit the clipped Gibbs and posterior-mean predictors, satisfy

$$
L_D(\operatorname{clip}\cdot)\le\min_{\mathcal G_n^{(\alpha)}}L_D+O_L\Bigl(n^{2\alpha-\frac12}\sqrt{\log\tfrac1\delta}+n^{\alpha-\frac12}\sqrt{\log n+\log\tfrac1\delta}+n^{4\alpha-1}\log\tfrac1\delta\Bigr),
$$

which is polynomially small for every $\alpha<1/4$. With the Hoeffding form of $\Gamma_n$ (the proposition as written), the excess is only $O_L(n^{4\alpha-1/2}\sqrt{\log(1/\delta)}+n^{\alpha-1/2}\sqrt{\log n+\log(1/\delta)})$, polynomially small for $\alpha<1/8$.

The rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ stated in `../research-notes/red-team.md` is not established. Unclipped predictions are not covered. For $\alpha>L/(2(2L-1))$ the same learner fails against this class at every width (`../research-notes/B-tempered-likelihood.md` Prop. 9.1, Lemma 9.2).

**Width transition (closing sentence).** For $L\ge3$, $c=1$ and clipped predictions:

- success (excess $\to0$ against any fixed competitor, for every $D$) is proved at $N=o(\sqrt{n/\log n})$;
- failure (constant excess on the cube family $n=\lceil\lambda2^d\rceil$) is proved at $N\ge C_a\,n\log^2n$;
- the behaviour in between is open.

---

## 5. Scripts (`../checks/verify-RT-width-logic/`)

| script | checks | result |
|---|---|---|
| `check_perturbation.py` → `.out` | Step 3 perturbation bound on 800 random networks at energy exactly $K$ (4 energy splits; random-sign, gradient-sign and activation-aligned perturbations of both signs, 4,800 perturbed networks; 500 inputs each), plus "sharper form $\le$ stated form" on a parameter grid | no violation; max actual/sharper $=0.607$, actual/stated $=0.380$ |
| `exponents.py` → `.out` | every term of the display at the worst case of the stated class ($L=3$, $c=1$, $\delta=0.05$), 60-digit arithmetic, $n$ up to $10^{300}$; asymptotic slopes; sympy exponent bookkeeping | slopes $4\alpha-1$ (energy), $\alpha-\frac12$ (grid), $4\alpha-\frac12$ (Hoeffding $g$-term), $2\alpha-\frac12$ (Bernstein); display polynomially small iff $\alpha<1/8$, repaired iff $\alpha<1/4$ |
| `competitor_fluctuation.py` → `.out` | exact binomial $95\%$ quantile of $\hat L(g)-L_D(g)$ for a competitor in the class with $L_D(g)=1$ | quantile $\approx1.65(G+1)/\sqrt n$, matching Bernstein's order; it exceeds the claimed rate by factors $2.7$–$35$ that grow like $n^{\min\{\alpha,1/2-2\alpha\}}$ up to logarithms |
