# Referee report on `../research-notes/E-finite-prior-scale.md` (Claim E: finite exponent $\gamma\ge1$, every width, no $\sigma$ limit)

*Lens: logic and definitions. I checked quantifiers, limit order, case splits and definitions against the brief and the cited sources, opening each source. I also looked for circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimisers), and steps that assume their conclusion. I re-derived every step of the main chain by hand. My check script and its output are in `../checks/verify-E-logic/`. Nothing in the repository was modified.*

---

## 1. Verdict: `minor_fixes`

I found no wrong step and no unjustified step in the proofs. Both main results hold as stated.

- **Positive direction (Theorem 2.7).** Clipped Gibbs risk and clipped posterior mean satisfy the agnostic oracle inequality, simultaneously for every learner width $N\ge m$, at the stated $\theta_{L,\gamma}$.
- **Negative direction (Theorem 5.2, Corollaries 5.3–5.4).** Memorisation on the noisy cube holds at every $\gamma\ge1$, at all widths $N\ge N_*={\rm poly}(n)$.

The $\gamma=1$, $L\ge3$ part of Theorem 2.7 depends on the mean-field cover (I3). ../research-notes/E-finite-prior-scale.md correctly marks that part as conditional (§8), since the source proof defers calculations to a companion paper.

The issues below are minor:

- missing qualifiers ("for all large $d$", two omitted width hypotheses);
- summary sentences that overstate claim status ("it is smaller", "at every width", "this proves");
- a discontinuity in the proven threshold at $\gamma=1$ that the phase diagram does not mention;
- a mismatch between the predictor readings used on the positive and negative sides of the "sharp" dichotomy (harmless, because Theorem 5.2(i) also covers the reading the positive side uses);
- incomplete reporting of the numerical check of Proposition 4.4;
- notation clashes;
- two caveats inherited from ../research-notes/A-tight-conditioning-fails.md.

---

## 2. Source statements compared with their use

| ../research-notes/E-finite-prior-scale.md item | Source and label | Statement matches use? |
|---|---|---|
| Prior $\mu_{N,\gamma}$, variances $N^{1-\gamma}/d$, $N^{-\gamma}$, $N^{-\gamma-1}$ | `paper.tex` eq. `finite-scales` ($m=M=1$); brief §2 ($\sigma^2=N^{-\gamma}$) | Yes. I re-derived (1.2), $\lVert D_N^{-1}w\rVert^2=N^\gamma\kappa_N(w)$, entry by entry. |
| Energy $\kappa_N$ | `paper.tex` eq. `energy`; brief §2 | Yes ($\sum_{\ell=2}^{L-1}=\sum_{\ell=2}^H$). |
| (I1) teacher tube $\mu_{N,\gamma}(U_\rho)\ge e^{-AN^\gamma}$, $N\ge m$ | `paper.tex` Prop. `tube`, eqs. `tube-mass`, `A`, Remark `cube` | Yes. At $m=M=1$, $c_m=3/8$ gives $\ln\frac1{c_m\eta}=\ln\frac8{3\eta}$, and $b_0=2\sqrt{2[2\ln9+\ln(4L)]}$. I re-derived the cylinder count $N[d+2+(L-2)C]$, $e_1\le\eta(d+1)$ on the cube, the recursion $e_\ell\le(\sqrt2CB+b_0)e_{\ell-1}+\eta\sqrt C$ (group-constant part bounded by $\eta\sqrt C$), and the absorption of $\ln2$ and $N\le N^\gamma$ into $A$. The source needs $B\ge1$; ../research-notes/E-finite-prior-scale.md assumes $B\ge1$. |
| (I2) $\Psi_n(K,\delta')=8(K/H)^{H/2}D_n/\sqrt n+4\sqrt{\ln(1/\delta')/(2n)}$ over $\mathcal Z_K=\bigcup_N\{\kappa_N\le K\}$ | ../research-notes/B-tempered-likelihood.md Lemma 5.3(a), built on Lemma 5.2 | Yes, verbatim, including $D_n=\sqrt{2(d+1)\ln(n+1)}+\frac{H-1}2$. The event is defined over the union over all widths, so it does not depend on $N$. That is what Theorem 2.7 needs. Three companion referees found Lemmas 5.2–5.3 correct. |
| (I3) mean-field cover, $c=\min\{\frac14,\frac m{16}\}=\frac1{16}$, $K\ge K_0^{\rm mf}\ge4$, $N\ge T_L$ | `meanfield.tex` Prop. `mf-cover`, cube change at eq. `mf-net` | Yes. I recomputed the degrees from $G_r=8rK\bar K/a^2$, $G_\ell=8G_{\ell+1}(1+G_{\ell+1})^2$, eq. `T`, $\eta$, $J$, $P$. $D_T=4\cdot3^{L-1}$ comes from $c_\nu^2P_3(G_1)^2\asymp G_1^6$ with $G_1\asymp K^{2\cdot3^{L-2}}$. $D_H=4+16(L-2)3^{L-2}$ comes from $P\asymp J^2$. A numerical check gives degrees $36/52$ ($L=3$) and $108/292$ ($L=4$). The baseline $K_0^{\rm mf}$ does not depend on $d$: about $82$ from the internal-layer net bound, and $\le8\ln2$ from the first layer. |
| (I4) $\lvert c_{k,\infty}\rvert\ge(2k)^{-1/2}$; Fourier $\ell^1$ bound; $R_S=\Delta+W$; $\Delta({\rm clip}f)\le\Delta(f)$; test-loss bound; $Q$ concentration | ../research-notes/A-tight-conditioning-fails.md Lemma 2.2(b), eq. (2.4), Lemma 4.1(a),(c), Lemma 4.2(b), Lemma 4.3(b)–(d) | Yes. Lemma 4.2(b) needs $\lvert f-g\rvert\le\varsigma$ only on $\mathcal S$, and ../research-notes/E-finite-prior-scale.md uses it only there. |
| (P$_L$), and readings for Corollary 5.4 | ../research-notes/A-tight-conditioning-fails.md §5.1 | Yes. (F1)/(F2) are the finite-scale analogues of (R1)/(R2), with no $\sigma$. |
| slt-likelihood finite-scale proof: $\rho=n^{-1/2}$, $Z_S\ge e^{-s(A+1/2)}$, clean small-width argument $e^{-nc_\tau r}$ | `slt-likelihood/README.md` §2, "Finite scales" | Yes; ../research-notes/E-finite-prior-scale.md §2.7 describes it accurately. |
| Paper's spectral lemma: $b=a/[2L(\sqrt K+1)^{L-2}]$, $N^{\gamma-1}\ge256/(mb^2)$ | `paper.tex` Lemma `spectral` | Yes, quoted correctly; ../research-notes/E-finite-prior-scale.md's Lemma 2.4 is an independent re-proof. |
| Red-team sketch: $\theta<(\gamma-1)/(2(L-2))$, mean field "open" both ways | `../research-notes/red-team.md` §8 | Yes, quoted correctly. |
| B Theorem 6.3: $\theta<1/H$, every $N\ge m$, near-minimisers $\mathcal N_1$ | ../research-notes/B-tempered-likelihood.md Theorem 6.3, Prop. 6.1 statement 1 | Yes. A minimiser lies in $\mathcal N_1$, so Remark 1.2's transfer to the MAP is valid. |

---

## 3. Step-by-step audit of the main chain

### 3.1 Posterior identity and Gaussian facts

- **Lemma 1.1.**
  - The covariance is $(N^\gamma\Gamma_N)^{-1}$, and $N^\gamma\kappa_N\sim\chi^2_{P_N}$.
  - The posterior is $\propto e^{-\Lambda_N\hat L_S}\mu$ with $\Lambda_N=N^\gamma n/(2c)$.
  - It is integrable because $F\ge\kappa_N$. Correct.
- **(G1)–(G5).**
  - (G1): $\mathbb Ee^{Y/4}=2^{P/2}$ and $\ln2/6<1/8$.
  - (G2): symmetry turns the tilt into $\cosh$.
  - (G3)–(G4): standard results, correctly stated.
  - (G5) is Mirsky's inequality, and the distance-to-ball corollary follows. Correct.

### 3.2 Positive direction (§2)

- **Lemma 2.1.**
  - (a): Minkowski with $\sqrt{\hat L_S(g)}\le U+1$, since $\lvert g\rvert\le\lVert u\rVert_1\le mB$.
  - (b): $\frac{n^\theta}2\eta=n^\theta\rho(U+1)+\frac{n^\theta\rho^2}2+A+\ln\frac{64}\varepsilon$ exactly, and $N^\gamma\ge1$.
  - (c): numerator $\le e^{\Lambda\hat L_S(g)}\mu(G^c)$, and $(U+1+\rho)^2\le(U+2)^2$.
  - Correct for every sample and every $N\ge m$.
- **Lemma 2.2 (PAC-Bayes).**
  - Hoeffding's lemma: each of the $n$ centred terms lies in an interval of length $4\Lambda/n$, giving $e^{2\Lambda^2/n}$.
  - Tonelli, Markov, then Donsker–Varadhan with a bounded integrand.
  - Gibbs identity: ${\rm KL}(\Pi\Vert\mu)=-\Lambda\mathbb E_\Pi\hat L'_S-\ln Z'$, with $\mathbb E_\Pi\hat L'_S<\infty$.
  - Clipped loss $\le$ unclipped loss.
  - Substituting $\Lambda=N^\gamma n^\theta/2$ gives exactly the displayed bound. Correct.
- **Lemma 2.3.**
  - (a): (G1) requires $N^\gamma K'\ge3P_N$.
  - (b): good and bad sets partition $\mathcal W_N$. Bad mass is $\le\varepsilon/32$ with loss $\le4$.
  - Remark: $3P_N/N^\gamma=3(d+2)N^{1-\gamma}+3(H-1)N^{2-\gamma}$, with $P_N=N(d+2)+(H-1)N^2$. Correct.
- **Lemma 2.4 (spectral truncation).**
  - Step 1: $\kappa^{(1)}=N^{-\gamma}\lvert\xi^1\rvert^2$ and $\kappa^{(L)}=N^{-\gamma}\lvert\zeta\rvert^2$; $N^\gamma K\ge3N(d+2)$ makes (G1) applicable.
  - Step 2: $b/(2\sigma)\ge3.5\sqrt N\ge2\sqrt N+\sqrt{2\ln2}$ for $N\ge1$.
  - Step 3: $s_j>b\Rightarrow s_j\le2(s_j-b/2)$, then (G5), then (G4) at $t=\sqrt K/(2\sigma)$.
  - Step 4: $2+\frac{H-1}2\le L$.
  - Step 6: $e_\ell\le\sqrt Ke_{\ell-1}+b$ from the split $W=W_{>b}+W_{\le b}$, and the output error is $\le b(H-1)K^{(H-1)/2}=a/2$ for all $x\in\mathbb R^d$.
  - Correct.
- **Lemma 2.5.**
  - $N\ge T(K)\iff N^{(\gamma-1)/2}\ge896(H-1)K^{(H-1)/2}/\varepsilon=7/b$ at $a=\varepsilon/64$.
  - $K\ge K_T$ makes the exceptional mass $\le\varepsilon/64$.
  - The Lipschitz transfer costs $2a+2a=4a=\varepsilon/16$.
  - $z_{\tilde w}\in\mathcal Z_{LK}\subseteq\mathcal Z_{\bar K}$, so the uniform event (I2) applies with no measurable selection of $\tilde w$. Correct.
- **Lemma 2.6.**
  - One-sided Hoeffding on $[0,4]$, union over $\lvert\mathcal C\rvert\le e^{H^{\rm mf}}$, gives ${\rm dev}_{\rm mf}$ exactly.
  - $K/16\ge A+\frac{n^\theta}2(U+2)^2+\ln\frac{128L}\varepsilon$ gives exceptional mass $\le\varepsilon/64$.
  - The set $G$ is Borel: $w\mapsto\sup_X\lvert z_w-h\rvert$ is lower semicontinuous, and the cover is finite.
  - Correct, conditional on (I3).
- **Theorem 2.7.**
  - **Events.** $\delta/4+\delta/4+\delta\pi^2/24=0.911\,\delta<\delta$. The intersection over all $N$ is one event that does not depend on $N$.
  - **Arithmetic.**
    - (C1) gives $h_n\le\varepsilon/32$ and $4\sqrt{\ln(4/\delta)/2n}\le\varepsilon/8$.
    - (C2) gives $2n^{-\theta}(A+\ln\frac{64}\varepsilon)\le\varepsilon/8$.
    - Excess totals: regimes E/T $0.8164\varepsilon$, regime S $0.7539\varepsilon$, regime MF $0.7539\varepsilon$.
    - In regime S, $2\ln N\le N\le N^\gamma$.
  - **Case coverage.** Case I covers $H=1$ (all $\gamma$) and $H\ge2,\gamma\ge2$; Case II covers $H\ge2$, $1<\gamma<2$; Case III covers $H\ge2$, $\gamma=1$. These are disjoint and exhaustive.
  - **Width coverage in each case.**
    - Case I: regime E at all $N$.
    - Case II: regime T for $N\ge\max(m,T)$, and route (i) or (ii) for $m\le N<T$.
    - Case III: regime MF for $N\ge T_{\rm mf}$, regime S below.
  - **Exponent algebra.**
    - Route (i): $e_{\rm i}=\frac{\gamma-1-\theta(\gamma H-1)}{\gamma(\gamma-1)}$.
    - Route (ii): $\theta'H<1\iff\theta<\min\{\frac1H,\frac{\gamma-1}{H(H-1)(2-\gamma)}\}$.
    - $\frac{\gamma-1}{H(H-1)(2-\gamma)}\ge\frac1H\iff\gamma\ge2-\frac1H$.
    - For $L\ge3$, $D_H\ge D_T+1$.
  - **Polynomiality and quantifier order.** Every sufficient condition is monotone in $n$, so "for all $n\ge p$" is justified. The quantifier order is $\exists p\ \forall(d,X,D,g,\varepsilon,\delta,n\ge p)\ \exists\mathcal E\ \forall N\ge m$, as (P$_L$) requires.
  - Correct.

### 3.3 Laplace bound (§3) and robust memoriser (§4)

- **Lemma 3.1.**
  - $E$ is symmetric with $\gamma_P(E)\ge\frac12$: $L$ conditions, each failing with probability $\le\frac1{2L}$.
  - $e_1\le2\sqrt2\tau$ and $e_\ell\le\sqrt{K_0}e_{\ell-1}+3\tau$.
  - Output error $\le(2\sqrt2+3(H-1)+2)K_0^{H/2}\tau\le(3H+2)K_0^{H/2}\tau$.
  - Translation by $D_N^{-1}w_0$. Correct, including $H=1$.
- **Lemma 4.1.**
  - Third-derivative bounds $\le2$, using $\max_{t\in[0,1]}(1-t)\lvert1-3t\rvert=1$.
  - Stein's identity gives $\frac d{dq}\mathbb Ef(\sqrt qG)=\frac12\mathbb Ef''(\sqrt qG)$.
  - $\cosh y\le e^{y^2/2}$.
  - Correct.
- **Lemma 4.2.**
  - (a) is a bijection argument.
  - (b): $1-\phi(\alpha)\le2e^{4-2\alpha}\le(2\sqrt{2d})^{-1}$, and odd-integer arguments give $\lvert c_k^\phi-c_{k,\infty}\rvert\le1-\phi(\alpha)$.
  - (c): ${\rm sech}^2\le4e^{-2\lvert y\rvert}$ and $\mathbb Ee^{s\lvert G\rvert}\le2e^{s^2/2}$.
  - Correct. Numerically at the worst case $\tau=1$, $\min_k\lvert c^\phi_k\rvert2\sqrt{2k}\ge1.86$ for $d\le30$.
- **Lemma 4.3 (noisy chain).**
  - The reference chain gives $\tilde u_{H+1}=\Pi_*S$.
  - Size bounds: $\lvert u_j\rvert\le2\bar S/R$ under the induction hypothesis $E_j\le\Xi\le1$, with $\bar S\ge1$.
  - Recursion: $f_j\le u_0+u_j^2+\tau^2f_{j-1}$.
  - Four-term split of $u_{\ell+1}-\tilde u_{\ell+1}$, with Lipschitz bounds in $q$ at arguments $\tau^2q\in[0,1]$.
  - Telescoping sums: $\sum_{i=1}^{H-1}R^i\le2R^{H-1}$ and $\sum_{i\ge1}R^{-2i}\le2/R^2$ for $R\ge2$.
  - The induction is well founded: base case $E_2=0$. Correct.
- **Proposition 4.4.**
  - Expansion and amplitude: $\mathcal A\le2\sqrt{2ds}/\Pi_*\le\mathcal A_{\max}$.
  - Sampling: $m_{\rm f}$ exceeds $128\ln2\,\mathcal A^2(d+1)/a^2$, so the failure probability is $<1$.
  - Centre energy: $\sum_jc_j^2\le2\mathcal A^2/N$ because $k_t\ge N/(2m)$ when $N\ge m$, and $2\mathcal A^2/R^{2H-2}\le2R^2$.
  - Conditional structure: rows of $W^\ell_0$ are constant, so given $\mathcal F_{\ell-1}$ the $h^\ell_k(x)$ are i.i.d.
  - Typical event: $2H$ events, each failing with probability $\le\frac1{8H}$.
  - Accuracy: $\lvert q_1-1\rvert\le\varphi$ from the choice of $\alpha$, and $\Xi<0.39a$, which I checked on a grid for $H\le8$.
  - Final steps: output error $<0.77a$, symmetrisation $E\cap(-E)$, translation.
  - The case $\mathcal A=0$ is handled.
  - $N_*$ and $K_{\rm rob}$ do not depend on $\gamma$; only the centre depends on $\gamma$, through $\tau$. Correct, uniformly in $\gamma\ge1$.

### 3.4 Negative direction (§5)

- **Lemma 5.1.**
  - The ratio bound $2e^{-N^\gamma t}$ is exact.
  - $\mathbb E_\mu\kappa^{(L)}=N^{1-\gamma}\le1$.
  - Correct.
- **Theorem 5.2.**
  - $r=\bar y\mathbf 1_{\mathcal S}$ has $\sum r^2=Q\le s_0$.
  - $R_V=na^2+W$, which gives $B_t=\{\Delta>\eta n\}$.
  - Gibbs: ../research-notes/A-tight-conditioning-fails.md Lemma 4.2(b) with $\varsigma=0$.
  - Means: Jensen on the convex $\Delta$, then closeness only on $\mathcal S$, where $\lvert m\rvert\le1+\sqrt{\eta n}$.
  - $(\cdot)_+^2$ is monotone, so $\sqrt{\lvert\mathcal S\rvert/M}\varsigma\le\varsigma$ is the right direction.
  - Correct.
- **Corollary 5.3.**
  - $\epsilon_{\rm fs}\to0$ term by term.
  - Deviation term $\sqrt{2\lambda_d}\,2^{-d/4}$.
  - $\beta_{n_d}\to\beta(\lambda)$ by ../research-notes/A-tight-conditioning-fails.md Lemma 4.3(c),(d).
  - $N_*\ge s_0$ gives $\sup_{N\ge N_*}\varsigma_N\to0$.
  - Correct, but see issue 1.
- **Corollary 5.4.**
  - All quantifiers of (P$_L$) other than $\mathsf p$ are universal, so the tuple $(d,D_d,g\equiv0,N\ge N_*,\varepsilon,\delta,n=2^d)$ may be chosen freely.
  - $c=n^{1-\theta}$ with $\theta>1/H$ satisfies (5.1).
  - Correct.
- **Consistency with Theorem 2.7.** For $\theta<1/H$, $cK_{\rm rob}/n\asymp d^{1/H}n^{1/H-\theta}\to\infty$, so (5.1) fails and the two results do not conflict.

No circularity: §2 uses only (I1)–(I3) and Gaussian facts; §5 uses only Proposition 4.4, Lemma 5.1 and (I4). The existence of a posterior mode (Remark 1.2) follows from continuity and coercivity of $F_{c,S}$ (../research-notes/B-tempered-likelihood.md Lemma 3.1). ../research-notes/E-finite-prior-scale.md does not say this, but it is immediate.

---

## 4. Issues

Severity "minor" means the proof survives unchanged after the fix.

### Issue 1 (minor): Corollary 5.3 needs "for all large $d$"

**Location.** Corollary 5.3 statement, line 558.

**Problem.**
- Proposition 4.4 and Theorem 5.2 need $a\in(0,1]$. With $a_d=(\max\{c_d,1\}/2^d)^{1/3}$, this needs $c_d\le2^d$, which holds only for large $d$ (by (5.1)).
- The bound $\varsigma_N\le2e^{-N}(2+\sqrt{n_d})$ uses $\eta\le1$, which ../research-notes/E-finite-prior-scale.md says holds "for large $d$".
- The statement itself asserts (i)–(ii) without this qualifier.
- This repeats A-logic Issue 4 for ../research-notes/A-tight-conditioning-fails.md Corollary 4.5.

**Fix.** Add "for all $d$ large enough that $a_d\le1$ and $\eta\le1$".

### Issue 2 (minor): missing hypotheses in two summaries of Lemma 3.1

**Locations.** §0 row 4 (line 16); §3 "Consequences", first bullet (line 351).

**Problem.**
- Row 4 states the Laplace bound under $N^{(\gamma-1)/2}\ge(3H+2)K_0^{H/2}/a$ only. Lemma 3.1 also needs $N\ge(\sqrt{d+1}+t_L)^2$, which step 2 uses.
- The "clone of $g$" bullet also needs $N\ge m$, so that the clone $w^g_N$ exists.

**Fix.** Add both hypotheses.

### Issue 3 (minor): claim-status wording overstates in three summaries

**Locations.**
- §0, "Answers (1)" (line 22): "It is smaller for $1\le\gamma<2-1/H$".
- §3 "Consequences", second bullet (line 352): "This proves Claim A at every $\gamma>1$ along the lines of Section 5."
- §6 (line 608): "The phase transition sits at $c=n^{1-1/H}$, at every width."

**Problem.**
- (a) Only the *proven* range is smaller. §6 itself says the window $[\theta_{L,\gamma},1/H)$ is open, and conjectures that $\theta<1/H$ suffices. As written, the sentence can be read as a statement about the learner.
- (b) The bullet is a one-line sketch. The actual proof at $\gamma>1$ is Section 5, through Proposition 4.4. The sketch would also need $N\ge N_0(d,s,a)$ for ../research-notes/A-tight-conditioning-fails.md's memoriser and $N\ge(\sqrt{d+1}+t_L)^2$.
- (c) The positive side holds at every $N\ge m$. The negative side holds only at $N\ge N_*(n)={\rm poly}(n)$; §5.3 and open problem 4 say smaller widths are not addressed.

**Fix.**
- (a) "The range proved here is smaller …; the true range there is open (§6)."
- (b) "This would give Claim A at every $\gamma>1$; Section 5 proves it for all $\gamma\ge1$."
- (c) "… for the width-uniform property (P$_L$); the failure is shown at widths $N\ge N_*(n)$."

### Issue 4 (minor): the proven threshold jumps at $\gamma=1$, and the phase diagram does not say so

**Location.** Theorem 2.7 (definition of $\theta_{L,\gamma}$, line 235); §6 table (lines 605–606); §0 row 7.

**Problem.**
- For $1<\gamma<2-\frac1H$, $\theta_{L,\gamma}=\max\{\frac{\gamma-1}{\gamma H-1},\frac{\gamma-1}{H(H-1)(2-\gamma)}\}\to0$ as $\gamma\downarrow1$.
- At $\gamma=1$ the separate mean-field route gives $\theta_{L,1}=1/D_H>0$.
- So for $\gamma$ slightly above $1$ the proven range is *smaller* than at mean field. My script finds this for $1<\gamma<1.020$ ($H=2$, $\theta_{3,1}=1/52$), $1<\gamma<1.0069$ ($H=3$) and $1<\gamma<1.0023$ ($H=4$).
- This is not an error: (I3) is stated only for $\mu_{N,1}$. But the table reads as if $\theta_{L,\gamma}$ were monotone in $\gamma$. The degree of $p_{L,\gamma,\theta}$ also blows up as $\gamma\downarrow1$, since $T\asymp n^{\theta(H-1)/(\gamma-1)}$. The source paper likewise disclaims uniformity as $\gamma\downarrow1$, but ../research-notes/E-finite-prior-scale.md does not mention it.

**Fix.** Add one sentence to §6, and to open problem 6:

> "The proven threshold is discontinuous at $\gamma=1$: for $\gamma\in(1,\gamma_H)$ it is below $\theta_{L,1}$. A mean-field-type cover for $\mu_{N,\gamma}$, $\gamma>1$, would remove this; the polynomial is not uniform as $\gamma\downarrow1$."

### Issue 5 (minor): the "sharp" dichotomy compares different predictor readings

**Locations.** §0 "Answers (1)" ("it is sharp, since $\theta>1/H$ fails (Corollary 5.4)"); §6 definition of "Works" and "Fails"; Remark 2.9(b) (line 303).

**Problem.**
- Theorem 2.7 bounds the *expected* Gibbs risk $\mathbb E_\Pi L_D({\rm clip}\,z_w)$ and the clipped posterior mean. In regime S only the expectation is controlled (Remark 2.9(b)).
- Corollary 5.4 refutes (F1), "probability over $S$ and the draw", and (F2).
- So the two sides of "sharp" are statements about different predictor readings. Neither reading implies the other.
- The dichotomy survives because Theorem 5.2(i) also gives $\mathbb E_\Pi L({\rm clip}\,z_w)\ge(1-2e^{-N^\gamma t})(1+e)$. That refutes the expected-Gibbs reading that the positive side uses. ../research-notes/E-finite-prior-scale.md does not say this.

**Fix.** Either:
- (a) add to Corollary 5.4 a third reading, (F0) "expected Gibbs risk $\le L_D(g)+\varepsilon$ with probability $\ge1-\delta$ over $S$", refuted by Theorem 5.2(i); or
- (b) prove the high-probability-over-the-draw version in regime S, which makes the positive side cover (F1) at every width. This is a three-line PAC-Bayes argument with $\varrho=\Pi(\cdot\mid B)$, where $B=\{L_D({\rm clip}\,z_w)>L_D(g)+\varepsilon\}$.
  - ${\rm KL}(\varrho\Vert\mu)=-\Lambda\mathbb E_\varrho\hat L'_S-\ln Z'-\ln\Pi(B)$.
  - The same chain as in Lemma 2.2 then gives $\Lambda^{-1}\ln\frac1{\Pi(B)}\ge\varepsilon-0.754\,\varepsilon$, so $\Pi(B)\le\exp(-0.12\,\varepsilon N^\gamma n^\theta)$. This becomes small after strengthening (C2) by a constant factor.

### Issue 6 (minor): the numerical check of Proposition 4.4 is reported selectively

**Location.** §7 item 4 and its table (lines 636–650); `E_scripts/robust_memorizer_det.py`, line 2.

**Problem.**
- The table's "robust" column ($0.193,0.084,0.048,0.025,0.173,0.152$) comes from `robust_memorizer_det.py`. That script allocates neurons deterministically and drops up to 17% of the coefficient mass ("dropped-coef mass" $0.132$–$0.173$ at the smaller widths).
- The construction actually used in Proposition 4.4, i.i.d. feature sampling, is `robust_memorizer.py`. Its output (`robust_memorizer.out`) gives median errors $0.838,0.710,0.451$ ($H=2$, $\gamma=1$, $N=1000,4000,8000$) and $0.691,0.420$ ($H=3$). Sampling error dominates there, since $m\le2000$ is far below $m_{\rm f}$. These numbers are not reported.
- Neither run tests the proposition at its hypotheses, so this does not affect the proof. But §7 presents the table as a check of Proposition 4.4.
- The det script's docstring says "Same network form as ../research-notes/E-finite-prior-scale.md Section 6"; the construction is in §4.

**Fix.**
- Report both scripts.
- Say that the det script is a variant (deterministic allocation with dropped coefficients) and that the sampling version is dominated by sampling error at these sizes.
- Fix the docstring.

### Issue 7 (minor): an unproved side remark in §2.7

**Location.** §2.7 item 1 (line 311): "At that energy no width-free capacity bound is $o(1)$".

**Problem.**
- What is shown is that the Rademacher bound (I2) is not $o(1)$ at $K\asymp n$.
- For $H\ge2$ a true capacity lower bound follows from memorisation (Section 5).
- For $H=1$ no lower bound is given. ../research-notes/A-tight-conditioning-fails.md's depth-two memoriser costs $\Theta(ds)$ energy, so it is not clear that $K=4n(U+2)^2$ suffices to shatter.

**Fix.** "At that energy the bound (I2) is not $o(1)$ …".

### Issue 8 (minor, inherited from ../research-notes/A-tight-conditioning-fails.md): two caveats not restated

- **(a) Fixed $d$** (A-logic Issue 1, A-scope S2).
  - Corollaries 5.3–5.4 refute (P$_L$) along $n\asymp2^d$, $d\to\infty$. At fixed $d$ the cube example is consistent as $n\to\infty$.
  - ../research-notes/E-finite-prior-scale.md's §0 row 6 and "Answers (2)" do not say that the refutation needs uniformity in $d$. The formal statement (P$_L$) is uniform in $d$, so the corollaries stand.
- **(b) "Test MSE tends to 2"** (§5.4(a), line 586; A-logic Issue 6).
  - Only the lower bound $\ge2-o(1)$ is proved.

**Fix.** Add the qualifier to (a), and write "at least $2-o(1)$" in (b).

### Issue 9 (minor): small omissions in Theorem 5.2 and Remark 1.2

- Theorem 5.2(ii) conditions on $G=B_t^c$. This needs $\Pi(G)>0$, which holds because $V\subseteq G$ and $\mu(V)>0$. This is not stated.
- Remark 1.2 uses the existence of a minimiser of $F_{c,S}$ without saying why. The reason is continuity plus coercivity ($F\ge\kappa_N$).

**Fix.** One clause each.

### Issue 10 (presentational): notation clashes

- **$\eta$** has four meanings:
  - the empirical slack of §2;
  - $a^2+c(K+2t)/n$ in Theorem 5.2;
  - the regression function in §5.4(b) ($Q_\eta$, $\mathcal E_\eta$);
  - the cylinder radius $\eta_\rho$ in (I1).
- **$c$**: the likelihood ratio vs. the cover constant in (I3).
- **$m$**:
  - competitor width;
  - the log-concavity constant in (I3)'s $c=\min\{\frac14,\frac m{16}\}$;
  - $m:=m_{\rm f}$ in Proposition 4.4.
- **$\gamma$**: the prior exponent vs. the coefficients $\gamma_j$ vs. $\gamma_P$.
- **$e$**: the excess in Theorem 5.2 vs. the exponent $e=\frac{1-\theta H}2$ vs. Euler's number.
- **$S$**: the sample vs. $S(x)$ in Proposition 4.4 vs. subsets $S\subseteq[d]$.
- **$\mathcal E$**: in Corollary 5.4 it means $\mathcal E_{\delta_d}$, not the event of Theorem 2.7.
- **Brief vs. ../research-notes/E-finite-prior-scale.md**: the brief's Claim B also asks about unclipped outputs and all near-minimisers. ../research-notes/E-finite-prior-scale.md covers the MAP (Remark 1.2) and clipped predictors, and says unclipped outputs are not done (Remark 2.9(a)). It does not discuss TUBE$_\rho$ at finite scale. ../research-notes/A-tight-conditioning-fails.md Prop. 6.5 already covers $\mu_{N,\gamma}$ without replacement, which could be cited.

**Fix.** Rename $\eta$ in Theorem 5.2 (e.g. $\bar\eta$) and in §5.4(b) (use $f^*$ for the regression function), write $m_\nu$ in (I3), and write $\mathcal E_{\delta_d}$ in Corollary 5.4.

---

## 5. Numerical checks (mine)

The script is `../checks/verify-E-logic/check_E_constants.py`, with output in `check_E_constants.out`. These are sanity checks, not proofs.

- Theorem 2.7 arithmetic: regimes E/T $0.8164<0.82$; regimes S and MF $0.7539<0.76$; $\pi^2/24=0.4112<0.42$; Remark 2.9(b) good-parameter bounds $0.629,0.691,0.629<0.7$.
- $\theta$ algebra:
  - the identity for $e_{\rm i}$;
  - $\frac{\gamma-1}{H(H-1)(2-\gamma)}\ge\frac1H$ iff $\gamma\ge2-\frac1H$;
  - both routes are $<\frac1H$ below that value;
  - the discontinuity at $\gamma=1$ (issue 4).
- (I3) degrees from the source formulas in 50-digit arithmetic: $\deg_KT_L=36,108$ and $\deg_KP=52.08,292.09$ for $L=3,4$. The $+0.08$ is the logarithmic factor $\log s$ in $J$.
- Lemma 4.2 at $\tau=1$ with $\alpha=2+\alpha_d$: $\min_k\lvert c^\phi_k\rvert2\sqrt{2k}\ge1.86$; $1-\phi(\alpha)\le(2\sqrt{2d})^{-1}$; $1/\phi(\alpha)\le1.1<2\sqrt{2d}$.
- Proposition 4.4: $\Xi<0.39a$ on a grid over $H\le8$, $a\in\{1,0.1,10^{-4}\}$, $\mathcal A_{\max}\in\{1,10^3,10^9\}$.
- Lemma 2.4 and Lemma 3.1 constants: $3.5\ge2+\sqrt{2\ln2}$, and $2\sqrt2+3(H-1)+2\le3H+2$.

I also read the outputs of ../research-notes/E-finite-prior-scale.md's own scripts. They agree with the text, apart from issue 6.

---

## 6. What is proved, conditional, and open after this review

- **Proved, given the companion lemmas.**
  - Lemma 1.1, Remark 1.2.
  - Lemmas 2.1–2.5.
  - Theorem 2.7 for $L=2$ (all $\gamma\ge1$) and for $L\ge3$, $\gamma>1$, at the stated $\theta_{L,\gamma}$.
  - Lemma 3.1; Lemmas 4.1–4.3 and Proposition 4.4, uniformly in $\gamma\ge1$.
  - Lemma 5.1, Theorem 5.2, Corollaries 5.3 ("for large $d$") and 5.4.
  - §5.4(a) (lower bound only) and §5.4(b).
- **Conditional on (I3).** Theorem 2.7 at $\gamma=1$, $L\ge3$, with $\theta<1/(4+16(L-2)3^{L-2})$. The statement and degrees match the source; the source proof defers calculations to `nongaus`.
- **Open, as ../research-notes/E-finite-prior-scale.md says.**
  - The window $[\theta_{L,\gamma},1/H)$ for $1\le\gamma<2-\frac1H$.
  - Unclipped predictors.
  - A′ at finite scale.
  - Widths below $N_*$.
  - Non-Gaussian coordinate laws.
  - Depth two with small $c$.
  - Also, per issue 4: the range $\gamma\in(1,\gamma_H)$, where the proven threshold is below the mean-field value.
