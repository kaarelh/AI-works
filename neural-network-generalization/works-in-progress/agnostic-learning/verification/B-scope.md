# Referee report on `../research-notes/B-tempered-likelihood.md` (Claim B, positive side of D): scope and adversarial interpretation

**Lens.** Does what ../research-notes/B-tempered-likelihood.md proves establish (or refute) the intended version of the user's conjecture (brief §1)? Would the user, who proposed the conjecture, object that it concerns a different learner, a degenerate distribution, a different loss, or the wrong order of limits? Can any stated theorem be falsified? Is anything in tension with the repository's theorems?

**Verdict: minor fixes.**

- **The positive claim stands.** Theorems 6.3 and 6.4 prove the brief's reading of the conjecture:
  - a uniform agnostic oracle inequality;
  - polynomial sample complexity;
  - every learner width $N\ge m$;
  - $\sigma\downarrow0$ taken after the sample and the width are fixed.

  I re-derived the main chain (Lemmas 2.1–2.3, 3.1, 5.1–5.3, Proposition 6.1, Theorems 6.3–6.4) and agree with `B-logic.md` that it is correct. I tried nine adversarial scenarios against the stated theorems and none falsifies them (Section 3).
- **No conflict with the repository.** I compared ../research-notes/B-tempered-likelihood.md with:
  - the noisy-interpolation theorem;
  - the slt-likelihood theorems;
  - the continuous-domain exact-interpolation results;
  - FAQ Questions 33, 34 and 39;
  - the conditional depth obstruction.

  None conflicts with ../research-notes/B-tempered-likelihood.md (Section 4).
- **The scope problems are in summary and discussion sentences, not in theorems.**
  - Several of these sentences drop quantifiers that change their truth value: uniformity over laws, and learner width at least $N_0(n)$.
  - ../research-notes/B-tempered-likelihood.md never relates its learner to three features of the user's own wording: no weight bound, "condition to be pretty close to the given outputs", and no requirement that every learner width work.
  - Issue 1 is the one the user would raise first. Every issue can be fixed with wording and short remarks, and none affects Claim B.

Scripts and outputs are in `../checks/verify-B-scope/` (Section 6).

---

## 1. Sources checked

I read ../research-notes/B-tempered-likelihood.md and the brief in full, and checked every repository statement that bears on scope against its source.

| statement | source | match / relevance |
|---|---|---|
| strong-prior theorem; "the scale threshold may depend on that finite width … it does not depend on $D,n,\delta$" | `NNG/side-results/continuous-domains/source/paper.tex`, Theorem `strong` | ../research-notes/B-tempered-likelihood.md uses the same convention: $\sigma_0(N,n,c,d,H,\eta)$, independent of $D,\delta,g,S$ (remark after Proposition 6.1). ✓ |
| cloning energy $E_*$; $\mathrm{Lip}\le K^{L/2}/\sqrt d$ | same file, eqs. `teacher-energy`, `energy-lipschitz` | ✓ (the source assumes $B\ge1$; ../research-notes/B-tempered-likelihood.md's re-proof needs only $B>0$) |
| "every low-energy interpolant generalizes"; iterated limit $\sigma\downarrow0$ then $\rho\downarrow0$ | same file, Proposition `exact`, Corollary `exact` | stated for **clean** labels $f(x_i)$ only; see Section 4 |
| SP$_1$ with clean labels; "observation variance $c\sigma^2$, for any fixed $c>0$, works too" | `NNG/works-in-progress/slt-likelihood/README.md` §2 | clean labels only; see Section 4 |
| fixed smooth likelihoods: posterior $\to$ prior; XOR counterexample | same README §3 | concerns a likelihood whose variance does **not** shrink with $\sigma$ |
| noisy-interpolation theorem (exact fit; global margin; distinct inputs; clean classification error $\le(B_L+As)/n$ at widths $N\ge W_s$); eqs. (12)–(16) | `NNG/works-in-progress/noisy-interpolation/README.md` §§1–6 | see Section 4 |
| "a fixed gap $\Delta\kappa$ … At fixed $n$, the prior gap wins as $\sigma\to0$" | `NNG/TECHNICAL-FAQ.md`, Q33 "Scope" | concerns a fixed noisy likelihood, not a co-scaled one |
| "broader misspecification remain[s] open" | FAQ Q39 | ../research-notes/B-tempered-likelihood.md would settle the strong-prior case |
| no universal bound polynomial **jointly** in $(d,C,L)$, assuming P/poly $\neq$ TC¹ | `NNG/works-in-progress/conditional-nonpolynomial-learning/README.md` | see Section 4 |

---

## 2. What is proved, against what the user asked

### 2.1 The proved statement, with every quantifier

**Positive results.** Fix $L=H+1\ge2$ and $\theta\in(0,1/H)$, and let $c(n)=n^{1-\theta}$. Fix $d$, a compact $X\subseteq[-1,1]^d$, a Borel law $D$ on $X\times[-1,1]$, a competitor $g$ of the repository architecture (depth $L$, width $m$, weights in $[-B,B]$), $\delta\in(0,1)$ and $n$.

There is an event $\mathcal E(D,g,n,\delta)$ with $D^n(\mathcal E)\ge1-\delta$, not depending on $N$ or $\sigma$. On $\mathcal E$, for every $N\ge m$:

- every $w$ with $F_{c,S}(w)\le\min F_{c,S}+1$ satisfies $L_D(\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}_n$;
- so do the limiting Gibbs risk, the support of every weak limit, and the mean of the clipped outputs $\bar f_\sigma=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$, all as $\sigma\downarrow0$.

Moreover $\mathrm{Exc}_n\le\varepsilon$ for $n\ge n_0$, where $n_0$ is polynomial in $(d,m,B,1/\varepsilon,\log1/\delta)$ at fixed $(L,\theta)$. For unclipped outputs, including the Bayes model average $\bar z_\sigma=\mathbb E_{\Pi_\sigma}z_w$, the same holds when $\theta<1/L$ (Theorem 6.4).

**Negative results, with the qualifiers stated in the theorems.**

| result | law | learner widths | sample event |
|---|---|---|---|
| Theorem 7.4(b): failure for $\theta>1/H$ ($H\ge2$) | noisy cube, $n=2^d$; atomic, $d=\log_2n$ | $N\ge N_0(n)=\lceil2(d+1)^3n^{1+\theta}\ln2\rceil+1$ | probability $\ge1-e^{-n^{1/3}/2}$ |
| Proposition 9.1(a) | two-point law $D_{\delta_0}$; $d=1$; $\delta_0$ may depend on $n$ | **every** $N$ | every sample |
| Corollary 9.3, Case 1 | noisy cube | $N\ge N_0(n)=\lceil2(d+1)^3n\,(n/c)\ln2\rceil+1$ | |
| Corollary 9.3, Case 2 | two-point law with $\delta_0=\delta_0(n)\to0$ | every $N$ | |

### 2.2 Mapping: user's words → brief → ../research-notes/B-tempered-likelihood.md

| user's wording | brief's interpretation | what ../research-notes/B-tempered-likelihood.md delivers | gap a skeptical user could raise |
|---|---|---|---|
| "NN Bayesian learning … whichever version is best" | SP$_c$, strong-prior limit $\sigma\downarrow0$ at fixed $N,n$ | exactly this | In the limit the learner is the near-minimizer set of $n^{-\theta}\kappa_N+\hat L_S$, a penalized least-squares problem. Posterior averaging adds nothing beyond Lemma 3.1. This is the repository's convention, but ../research-notes/B-tempered-likelihood.md should say it (issue 4). |
| "should condition to be pretty close to the given outputs" | SP$_c$ is "the condition closely learner" | $c=n^{1-\theta}\gg1$. Near-minimizers fit only to within the competitor's training error plus $(E_*+1)n^{-\theta}$. | The user's heuristic is **refuted** for every-width learners. Close conditioning ($c=O(1)$, or any $n$-independent $c$) fails at large widths (Proposition 7.3 with Corollary 9.3, Case 1). ../research-notes/B-tempered-likelihood.md never says so (issue 2). |
| "after seeing $n$ data points" | $c=c(n)$ allowed | the likelihood scale depends on $n$ | This is not one Bayesian model updated as data arrive. No $n$-independent $c$ works at large width when $H\ge2$ (issue 3). |
| "width poly($n$) MLPs" (no weight bound) | width **and weights** bounded; sample bound polynomial in $(d,m,B)$ | width and weights $\le n^\alpha$ with $\alpha<1/(4H)$; width-1 classes with $\alpha<1/(2H)$ | ../research-notes/B-tempered-likelihood.md presents weight bounds as necessary. They are necessary only (i) uniformly over laws and (ii) for learners that must work at all large widths. For a fixed law, ../research-notes/B-tempered-likelihood.md's own Theorem 6.3 gives the width-only statement with no weight bound (issue 1). |
| "use MSE loss" | $L_D(f)=\mathbb E(f(x)-y)^2$, labels in $[-1,1]$ | clipped outputs for $\theta<1/H$; $\bar z_\sigma$ only for $\theta<1/L$ | Gaussian (unbounded) label noise is excluded (issue 7). The natural Bayes prediction $\bar z_\sigma$ is covered on the smaller range only (issue 10). |
| "MLPs" | same depth $L$, tanh, no internal biases | same | Standard MLPs need a translation that ../research-notes/B-tempered-likelihood.md does not discuss (issue 8). |
| order of limits | $\sigma\downarrow0$ after $S,N$ | exactly this; $\sigma_0$ depends on $N$ | Nothing is proved at a fixed prior scale; Claim E is open, as ../research-notes/B-tempered-likelihood.md lists. Not an error. |

---

## 3. Attempts to falsify the stated theorems

Each scenario below was run against the exact statements of Theorems 6.3, 6.4 and 7.4, Proposition 9.1 and Corollaries 8.1 and 9.3.

1. **Atoms and repeated inputs with conflicting labels.**
   - Lemma 5.2 needs no distinct points, since Sauer–Shelah counts dichotomies of the distinct points.
   - The competitor event $\mathcal E_2$ uses only that $g$ is fixed before the sample.

   Theorem 6.3 holds.
2. **$d\ge n$.** $D_n$ grows like $\sqrt{d\log n}$, and $n_0$ is polynomial in $d$. The theorem is vacuous when $d\gtrsim n$, which is allowed. It is not false.
3. **Competitors with huge outputs.** These enter only through $U=mB$ in the Hoeffding term and through $E_*$, both polynomial. Theorem 6.3 holds.
4. **Steep or high-energy first layers in the learner.** Lemma 5.2 charges the first layer through halfspace VC dimension, not through energy, so arbitrarily large first-layer weights inside the budget are harmless. Theorem 6.3 holds.
5. **Learner width $N<m$.** This is excluded by hypothesis, and the clone needs $N\ge m$. Under Corollary 8.1 the learner width must be at least $n^\alpha$. Not a counterexample.
6. **Uniformity of the $\sigma$-threshold.**
   - $\sigma_0$ depends on $N$ and $n$, and ../research-notes/B-tempered-likelihood.md says so.
   - $\sigma_0$ does not depend on $S$, $D$ or $g$: $G$ and $Z$ in Lemma 3.1 are maxima over $\Omega\times[-1,1]^d$.

   Not a counterexample.
7. **Laws whose regression function is not representable.** The oracle inequality is relative to $g$, and nothing requires realizability. Theorem 6.3 holds.
8. **Learner widths between $m$ and $N_0(n)$ in the negative results.** Theorem 7.4(b) and Corollary 9.3, Case 1, say "at every width $N\ge N_0(n)$". That is correct, but nothing is claimed below $N_0(n)$, and $N_0(n)>n$. See issues 1 and 9.
9. **Fixed law, growing $n$, in Section 9's examples.** For each fixed $\delta_0$, SP$_{n^{1-\theta}}$ eventually fits $D_{\delta_0}$. `scope_numbers.out`, Part D, gives both thresholds:

   | quantity | at $L=3$, $\theta=1/4$, $\delta_0=10^{-3}$ |
   |---|---|
   | largest $n$ with certified failure ($L_D\ge1/4$) | $10^{9.1}$ |
   | smallest $n$ certified by Remark 6.5 to give excess $\le0.1$ | $10^{14.2}$ |

   Both thresholds grow polynomially in $1/\delta_0$. So Section 9's examples refute only the statement that is uniform over laws. They do not refute any theorem.

**Conclusion.** I found no counterexample to any theorem or proposition as stated. Counterexamples exist only to unqualified summary sentences (issues 1, 6 and 9).

---

## 4. Consistency with repository theorems

| repository result | apparent tension | resolution |
|---|---|---|
| Noisy interpolation (exact fit of flipped labels generalizes, with clean error $\le(B_L+As+8\log\tfrac1\delta)/n$) | ../research-notes/B-tempered-likelihood.md and Claim A say interpolating noise fails. | Different loss and regime. The repository bounds **clean classification error** for a small corruption fraction, with distinct inputs and global margin conditioning. ../research-notes/B-tempered-likelihood.md measures **MSE against the noisy labels**, using pure noise and atomic laws with $n=M$. With flips at rate $\eta$ and $n\asymp M$, an interpolator has MSE excess of order $\eta$. That is consistent with the repository's own bound, which also does not vanish at fixed $\eta$: README eq. (21) has a term $2A(d,L,U)\eta$. No conflict. |
| Noisy-interpolation eqs. (15)–(16): Rademacher complexity $\propto(K/H)^{H/2}$ and $\mathrm{VCdim}(\mathcal G_K)\lesssim D^2K^H$ | none | ../research-notes/B-tempered-likelihood.md's memorizer (Lemma 7.2) fits $s$ points at energy $\approx(d^2s)^{1/H}$, i.e. effective dimension $K^H$. This is exactly what makes $1/H$ the threshold. Consistent. |
| slt-likelihood §2: SP$_1$ with clean labels; "any fixed $c>0$ works too" | ../research-notes/B-tempered-likelihood.md and Claim A say $c=O(1)$ fails | Both slt statements are for clean labels. With clean labels ../research-notes/B-tempered-likelihood.md's $c=n^{1-\theta}$ also works (Theorem 6.3 with $L_D(g)=0$). The slt Chernoff route with residual budget $c(E_*+1)$ also gives degree $1/\theta$. Consistent. |
| slt-likelihood §3 and FAQ Q33 "Scope": fixed likelihoods lose to the prior as $\sigma\to0$ | none | ../research-notes/B-tempered-likelihood.md's likelihood variance $c\sigma^2$ shrinks with the prior scale, so its weight $\frac{n}{c}\hat L_S$ stays comparable to $\kappa_N$. Consistent. |
| continuous-domain Proposition `exact` and Corollary `exact` | ../research-notes/B-tempered-likelihood.md says low-energy (near-)interpolants of noisy labels fail | The repository results assume clean labels. Consistent. |
| conditional depth obstruction | none | ../research-notes/B-tempered-likelihood.md's $n_0\ge(3(E_*+1)/\varepsilon)^{1/\theta}$ with $1/\theta>H$ has exponent growing with depth. It is not jointly polynomial in $(d,C,L)$. Consistent. |
| FAQ Q34: "They do not assert the same bound for data corrupted by fixed positive observation noise" | none | ../research-notes/B-tempered-likelihood.md supplies such a bound (agnostic, strong-prior limit) by tempering. Q34 and Q39 would need updating if ../research-notes/B-tempered-likelihood.md is adopted. |

No contradiction found.

---

## 5. Issues

Severity is judged relative to the claim under review (Claim B, the positive side of D). No issue invalidates a theorem.

### Issue 1 (minor for Claim B; the most consequential for the user): "weights must be bounded" and "no choice of $c(n)$ works" drop two quantifiers

**Locations.**

- Section 0, row "the weight bound": "Here $\alpha^*$ is the threshold above which **no** choice of $c(n)$ works".
- Section 8, after Corollary 8.1: "for width-and-weight classes no choice of $c(n)$ works beyond …".
- Section 9, Discussion: "A width bound alone does not suffice, and the weights must be bounded in a way tied to the tempering"; and "Corollary 9.3 shows that no $c(n)$ does better".

The theorems behind these sentences, Proposition 9.1 and Corollary 9.3, are correct as stated. The summaries omit two qualifiers, and without them the sentences are false.

**(a) Uniformity over laws.** Both counterexample families use laws that change with $n$: $D_{\delta_0(n)}$ with $\delta_0\to0$, or the cube with $d=\log_2n$. For a **fixed** law, ../research-notes/B-tempered-likelihood.md's own Theorem 6.3 gives the user's literal statement: width poly($n$), no weight bound. The argument:

- Let $R^*=\mathbb E(y-\mathbb E[y\mid x])^2$.
- One-hidden-layer tanh networks with input bias are dense in $C(X)$.
- For $H\ge2$, a near-identity tanh chain converts such a network $f_2$ into the repository architecture, with sup error $\le\frac{2\lVert f_2\rVert_\infty^3}{3R^2}$. This is the construction of Lemma 7.2, Steps 5–6.
- $C(X)$ is dense in $L^2(D_X)$.
- Hence for every $\varepsilon$ there is a fixed network $g_\varepsilon$ with $L_D(g_\varepsilon)\le R^*+\varepsilon$.
- Theorem 6.3 applied to $g_\varepsilon$: for $n\ge n_0(g_\varepsilon,\varepsilon,\delta)$, with probability $\ge1-\delta$, every near-minimizer at every width $N\ge m_\varepsilon$ (and the Gibbs and mean predictors) has $L_D(\operatorname{clip}z_w)\le R^*+2\varepsilon\le\inf_{\mathcal G}L_D+2\varepsilon$, for every competitor class $\mathcal G$, of any width and any weights.

So SP$_{n^{1-\theta}}$ is universally consistent, and the width-only statement holds law by law. Part D of `scope_numbers.out` shows this concretely for Section 9's own two-point laws. The weight bound is the price of a guarantee **uniform** over laws, which is the brief's reading. ../research-notes/B-tempered-likelihood.md should say this, and might add the consistency corollary, which costs three lines.

**(b) Learner width.** Corollary 9.3, Case 1, and Theorem 7.4(b) need $N\ge N_0(n)>n$.

- **On the two-point law, a tiny $c$ succeeds at every width.** At $n=1024$, $\alpha=0.4>1/(2H)$, take the width-1 competitor of Lemma 9.2 (weights $\le16$, zero loss, energy $599$). With $c=10^{-3}$, Lemma 2.3(b) certifies $L_D\le6\times10^{-4}$ for **every** near-minimizer at **every** width. With $c=n^{0.6}$, Proposition 9.1(a) certifies $L_D\ge0.989$ at every width (`width_dependence.out`, Part C).
- **On the noisy cube, a tiny $c$ fails only at large width.** At $d=10$, $n=M=1024$ and width $1024$, an explicit random-feature memorizer with $\kappa=472.6$ certifies, through Lemma 2.3(b) and Lemma 7.1(b), excess $\ge0.47$ for every near-minimizer when $c=10^{-3}$, and $\ge0.24$ when $c=0.1$ (Part A). At width $1$ with the same sample and $c=10^{-3}$, the best of 400 L-BFGS runs has excess $0.029$ (Part B). This last number is one-sided optimisation evidence, not a certificate.
- **Sketch, not proved here.** At a fixed learner width $N=n^\alpha$ the class $\mathcal W_N$ has pseudo-dimension polynomial in $(N,d,L)$ and independent of the weights (Karpinski–Macintyre). Near-minimizers with small $c$ satisfy $\hat L_S(z_w)\le\hat L_S(g)+c(\kappa(g)+1)/n$. So the tempering-versus-weights trade-off of Section 9 does not arise for fixed-width learners.

The user's formulation says nothing about every learner width. The every-width requirement comes from the brief and the repository. It is exactly what forces both tempering (Section 7) and the weight bound (Section 9).

**Fix.**

- Section 0 row: replace "no choice of $c(n)$ works" by "no choice of $c(n)$ gives a guarantee uniform over laws (with $d$ allowed to grow like $\log n$) at all learner widths $N\ge N_0(n)$".
- Section 9 Discussion: replace "A width bound alone does not suffice" by "For SP$_c$ at every width, and uniformly over laws, a width bound alone does not suffice".
- Add one remark:
  - for each fixed law, Theorem 6.3 and universal approximation give consistency, so the width-only comparison holds law by law;
  - whether some Bayesian learner, for instance one of bounded width or with a non-Gaussian prior, achieves the width-only statement uniformly is not addressed.

### Issue 2 (minor, scope): the user's "condition closely" heuristic is refuted but never addressed

The user wrote: "The Bayesian learning should condition to be pretty close to the given outputs on train inputs for this to be plausibly true."

- ../research-notes/B-tempered-likelihood.md's learner does not do this. It fits only to $\hat L_S(g)+(E_*+1)n^{-\theta}$ (Lemma 2.3(c)).
- The closely-conditioned learners fail at large widths: SP$_c$ with $c=O(1)$, or any $c$ with $c\,K_{\rm mem}=o(n)$ (Proposition 7.3, Theorem 7.4(b)). The tube learner fails as well, per Claim A.

This is the main qualitative message for the user: in the agnostic setting the learner must be **tempered**, not tightly conditioned. ../research-notes/B-tempered-likelihood.md says it only indirectly ("$c=1$ memorizes noise").

**Fix.** Add one sentence to Section 0 or Section 9 stating that this heuristic of the user's is false for every-width learners, and why.

### Issue 3 (minor, scope): the learner is not a single Bayesian model across $n$

With $c=n^{1-\theta}$, the posterior after $n$ points is not the posterior after $n-1$ points updated by one more point. It is a power posterior whose temperature, relative to the co-scaled Gaussian model, is $n^{\theta-1}$.

../research-notes/B-tempered-likelihood.md's own Proposition 7.3 shows this is unavoidable at large width when $H\ge2$. For every fixed $c$, take $t=n^{-1/4}$; then $\varepsilon_{c,t}\to0$, because $(c/n)\bigl((d+1)^2n\bigr)^{1/H}\to0$ and $(c/n)\cdot\tfrac{9}{4t}\to0$. Every $n$-independent $c$ therefore fails on the noisy cube at widths $\gtrsim n^{3/2}\log^3n$.

The brief allows $c(n)$, so this is not an error. But a skeptical user will ask, and ../research-notes/B-tempered-likelihood.md should answer.

**Fix.** Add one sentence after the definition of SP$_c$ in Section 1.

### Issue 4 (minor, scope): what "Bayesian" means in the limit

In the limit $\sigma\downarrow0$, all four predictors are controlled through the near-minimizer set of $n^{-\theta}\kappa_N+\hat L_S$ (Corollary 3.2). So Theorem 6.3 is a uniform-convergence theorem for energy-penalized least squares plus a Laplace lemma, and posterior averaging plays no further role. This is the repository's convention, as in the continuous-domain Theorem `strong` and the slt-likelihood note, so it is legitimate.

The user may still object that this is "MAP, not Bayes". Nothing is proved at a fixed prior scale (Claim E).

**Fix.** State this in Section 0, next to the limit order.

### Issue 5 (minor, presentational; confirms `B-logic.md` issues 3 and 4)

- After Theorem 6.3: "$\mathrm{Exc}_n\le\varepsilon$ first holds at $n\approx10^{13.4}$". For the displayed $\mathrm{Exc}_n$ the threshold is $10^{14.09}$, and its value at $10^{13.4}$ is $0.146$. The figure $10^{13.38}$ belongs to the sharper bound with $K=n^\theta+1$ (`exc_threshold.out`).
- Section 0, "the user's formulation": "plus $O(n^{-\beta})$" should be $\tilde O(n^{-\beta})$, with $d$- and $\delta$-dependent factors, because $\Xi_n$ contains $\sqrt{2(d+1)\ln(n+1)}$.

### Issue 6 (minor, overstatement; confirms `B-logic.md` issue 5a with an explicit counterexample)

Section 9, Discussion: "Competitors whose minimal energy exceeds it by a constant factor cannot be matched." This is false as a universal statement.

**Counterexample.** Take $d=1$, $x$ uniform on $[-1,1]$, and $y$ a fair sign independent of $x$, so $\mathrm{OPT}=1$. Let $g$ be the width-1 depth-$L$ network with first-layer row $(0,R)$, internal weights $1$ and readout $\tfrac1{10}$, so $g(x)=\tfrac1{10}\tanh(\tanh(\cdots\tanh(Rx)))$ and $g'(0)=R/10$.

- Every network that agrees with $g$ on $X$, at any width, has Lipschitz constant at least $R/10$. By Lemma 2.1(b) its energy is at least $L\,(R/10)^{2/L}$, which tends to $\infty$ with $R$.
- Yet $L_D(g)=1+\mathbb Eg^2>1$, and Theorem 6.3 with the zero competitor gives $L_D(\text{learner})\le1+\varepsilon$. So $g$ is matched.

The relevant quantity is the energy-penalized population risk $\inf_{w'}[L_D(z_{w'})+n^{-\theta}\kappa_N(w')]$ of Remark 6.5, not the competitor's own energy. The sentence in Proposition 9.1(c), "the competitor energy at which matching breaks down is of order $n^\theta$", should likewise say "in the worst case over laws". It also needs $\theta<1/H$, per the logic report's issue 1.

### Issue 7 (minor, scope): bounded labels

Every result assumes $\lvert y\rvert\le1$. This is used in Lemma 2.3(a), in (1.1) and in the loss ranges. The canonical MSE noise model, $y=f(x)+\mathcal N(0,s^2)$, is therefore not covered. The brief imposes $[-1,1]$, so this is not an error.

**Fix.** Add one sentence saying this. An extension through truncation at $O(\sqrt{\log n})$ is plausible but not checked.

### Issue 8 (minor, scope): competitor architecture versus the user's "MLPs"

The competitor must have the learner's exact depth, tanh activations and no internal biases.

- Standard MLPs with biases translate by adding one constant wire per layer: width $m+1$, weights up to $B/\tanh1$.
- Shallower competitors translate approximately through near-identity chains, with energy cost $O(R^2)$ per added layer and sup error $O(\lVert g\rVert_\infty^3/R^2)$.
- Other activations, such as ReLU, need an approximation argument.

../research-notes/B-tempered-likelihood.md is silent on all of these.

**Fix.** Add a remark, so that "depth-$L$ MLPs" in Corollary 8.1 is not read more broadly than proved.

### Issue 9 (minor, scope): the sharpness statement needs its qualifiers in the summary

"So $1/H$ is the sharp exponent for clipped predictors" (Section 0 table; after Theorem 7.4) is correct with these qualifiers, all present in Theorem 7.4 but absent from the summary:

- worst case over laws;
- $d$ growing like $\log_2n$;
- atomic inputs with replacement;
- learner widths $N\ge N_0(n)\approx2(d+1)^3n^{1+\theta}\ln2$.

At fixed $d$, or for learner widths below $n$, nothing is shown.

Also, the two-point counterexamples of Section 9 have $d=1$ and a scale $\delta_0(n)\to0$. Rescaling the inputs removes them. A version robust to rescaling would put half the mass on $x=\pm1$ with label $0$, so that the input range is $[-1,1]$ regardless. This is optional.

**Fix.** Add the qualifiers to the Section 0 row.

### Issue 10 (minor; confirms `B-logic.md` issue 10)

For $\theta\in[1/L,1/H)$ only $\bar f_\sigma=\mathbb E\operatorname{clip}z_w$ is controlled. The user's most natural Bayesian MSE prediction is the posterior predictive mean $\bar z_\sigma$, or its clip, and that is covered only for $\theta<1/L$. Corollary 8.1, "the user's formulation", is proved only for clipped predictors.

**Fix.** Say so in the Corollary 8.1 prose.

---

## 6. Independent checks (`../checks/verify-B-scope/`)

Each script was run as `python3 X.py > X.out` from that folder.

| script | what it checks | result |
|---|---|---|
| `scope_numbers.py`, Part D | Fixed two-point laws $D_{\delta_0}$: largest $n$ with certified failure (Proposition 9.1(a)) and smallest $n$ with certified excess $\le0.1$ (Remark 6.5 with $w'$ the chain clone), for $L\in\{2,3,4\}$ and $\delta_0\in[10^{-4},10^{-1}]$. | Both thresholds are finite for every fixed law and grow polynomially in $1/\delta_0$. Example: $L=3$, $\theta=1/4$, $\delta_0=10^{-3}$ gives failure up to $10^{9.1}$ and success from $10^{14.2}$. So Section 9 refutes only the version uniform over laws. |
| `scope_numbers.py`, Part E | Independent recomputation of the §7.5 window: root-finding, with continuous optimization over $t$. | $H=2$, $d=400$: $0.4612$ and $0.5355$. $H=3$: $0.6340$ and $0.6880$. Identical to `transition_window.out`. |
| `width_dependence.py`, Part A | Noisy cube, $d=10$, $n=M=1024$, width $1024$. Explicit memorizer: random tanh features plus a scalar chain, with targets $R\,\mathrm{artanh}(\bar y/R)$ so that the fit is exact. Gives $\kappa=472.6$ and $\mathcal R=4\times10^{-26}$. | Certified excess of **every** near-minimizer: $\ge0.490$, $0.470$, $0.408$, $0.242$ for $c=10^{-4}$, $10^{-3}$, $10^{-2}$, $10^{-1}$. For $c=1$ only $\ge0.0007$. |
| `width_dependence.py`, Part B | Same sample, width 1, 400 L-BFGS starts. Illustration only. | Best found excess: $0.029$ ($c=10^{-3}$) and $0.028$ ($c=10^{-2}$). |
| `width_dependence.py`, Part C | Two-point law of Corollary 9.3, Case 2, with $\alpha=0.4$ and $n=1024$. | $c=10^{-3}$: $L_D\le6\times10^{-4}$ at every width (certified). $c=n^{0.6}$: $L_D\ge0.989$ at every width (certified). |
| `exc_threshold.py` | Sample size quoted after Theorem 6.3. | Displayed $\mathrm{Exc}_n\le0.1$ first at $10^{14.09}$. With $K=n^\theta+1$: $10^{13.38}$. |

---

## 7. Summary for the author

**Claim B is proved** in the form the brief asks for. Every quantifier and the limit order are as required, and I could not falsify it.

The write-up should make five things explicit:

1. The weight bound, and the claim that "no $c(n)$ works", concern guarantees that are **uniform over laws** and hold **at all large learner widths**. For each fixed law the learner is consistent, so the user's width-only statement holds law by law.
2. The user's "condition closely" heuristic is false for every-width learners: tempering is required.
3. The learner's likelihood scale must depend on $n$.
4. In the limit, "Bayesian" means the near-minimizers of a penalized least-squares objective.
5. Bounded labels, the competitor architecture, and clipped versus Bayes-average predictions limit how literally Corollary 8.1 can be read as "the user's formulation".
