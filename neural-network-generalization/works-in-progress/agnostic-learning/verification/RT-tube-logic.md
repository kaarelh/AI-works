# Referee report on `../research-notes/red-team.md` §4.3, Proposition 4.1 (TUBE with a sup-norm residual budget): logic and definitions

**Lens.** I checked quantifiers, the limit order ($\sigma\downarrow0$ after the sample and the width are fixed), case splits and definitions against `../research-notes/problem-brief.md` and the cited sources. I looked for circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers, label range), and steps that assume what they set out to prove. Under review: Proposition 4.1, its proof, the paragraph after it (`../research-notes/red-team.md` lines 363–383), and the places that cite it (§0 item 7, §6.3 item 3, §7 item 5). `NNG/` denotes the project folder `neural-network-generalization/` of this repository, and `paper.tex` abbreviates `NNG/side-results/continuous-domains/source/paper.tex`.

**Verdict: minor fixes.** I checked every step, and the displayed inequality is correct. I found no circularity and no false step. Nine issues are listed in Section 3. All are presentational or about scope:

- "verbatim" needs three explicit qualifications;
- the "never memorizes" sentence overstates what is proved;
- the bound is loose by a large constant factor;
- the citing sentences present Proposition 4.1 as a surviving version of an agnostic oracle inequality, which it is not.

Section 4 gives a sharper statement that the same ingredients support.

### Answers to the three focus questions

1. **Is $\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le(\tau+\rho_0)^2+4\varepsilon/3$ correct at the sample size of Theorem `strong`, uniformly over $N\ge C$?** Yes, in exactly the sense of Theorem `strong`. Write $D_X$ for the input marginal of $D$.
   - The sample size $n\ge\frac6\varepsilon[p_L(d,C,B,u')+\log\frac1\delta]$ does not depend on $N$.
   - The high-probability sample event has three properties: it depends only on the inputs (and on $g$, $\rho+\rho_0$, $\tau$, $\varepsilon$), it is the same for every $N\ge C$ and every $\sigma$, and it holds together with the probability-one event $\{\max_i\lvert y_i-g(x_i)\rvert\le\rho_0\}$.
   - The scale threshold is $\sigma_0=\sigma_0(N,g,\rho-\rho_0,\varepsilon)$. It does not depend on the sample, on $n$, on $\delta$, or on $D$ within the class of laws whose residual from this $g$ is at most $\rho_0$.

   The display should say "with probability at least $1-\delta$, for every $N\ge C$ and every $\sigma<\sigma_0(N,\dots)$" (issue 2).
2. **Does Theorem `strong` hold verbatim after the replacements?** Yes, up to bookkeeping. Clean labels enter the proof of `strong` in exactly three places (Section 2.2), and each is handled correctly: the denominator, the step "fitted $\Rightarrow$ no training input in $A_h$", and the bound on the posterior mass of high-energy networks. Three qualifications are needed (issue 1):
   - "for every sample" becomes "for every sample with $\max_i\lvert y_i-g(x_i)\rvert\le\rho_0$", which holds with probability one;
   - $\sigma_0$ also depends on $\rho_0$;
   - Lemma `posterior` is used in a two-radius form that its statement does not cover. The proof's "cover step" bullet re-proves that form correctly.
3. **Does hard conditioning within the residual budget never memorize?** The fact offered for it is true once "minimum" is replaced by "infimum": for every admissible sample and every $n$, the infimum of $\kappa_N$ over the open constraint set is at most $E_*$, and the strong-prior posterior stays in the $n$-independent sublevel $\{\kappa_N\le E_*+2\}$. That limits memorization capacity uniformly in $n$. But "never memorizes" is not a consequence of Proposition 4.1 (issue 5).
   - The proposition's risk bound exceeds $9\rho_0^2$. It allows an excess over $L_D(g)$ of more than $8\rho_0^2$. The memorization harm exhibited in A (scaled to labels $\pm\rho_0$) is $\beta(\lambda)\rho_0^2\le0.52\rho_0^2$. So the bound cannot certify the absence of memorization-level excess.
   - At finite $n$, nothing in the argument stops energy-minimizing feasible networks from tracking the noise at binding constraints. The energy bound only limits how much.
   - TUBE also has a tolerance bias of up to $(\rho-\rho_0)^2$ that is unrelated to memorization (../research-notes/A-tight-conditioning-fails.md Prop. 6.3).

   The sharpened bound of Section 4 ($\rho^2+\varepsilon$) does make the contrast with SP$_1$ quantitative.

---

## 1. Statements compared against the sources

| use in `../research-notes/red-team.md` §4.3 | source (opened and compared) | match |
|---|---|---|
| TUBE$_\rho$: strong-prior Gaussian prior conditioned on $\lvert z_w(x_i)-y_i\rvert<\rho$ for all $i$ | `paper.tex` eq. `posterior` (lines 130–135) with $f(x_i)\to y_i$; `../research-notes/problem-brief.md` §2 "TUBE$_\rho$"; ../research-notes/A-tight-conditioning-fails.md eq. (1.3) | yes |
| $R_\tau(\Pi)=\mathbb E_\Pi D\{\lvert z_w-f\rvert>\tau\}$, $q_\tau$, eq. `confidence` | `paper.tex` lines 137–146 | yes, with $f\to g$. $D$ must be read as the input marginal $D_X$, because the paper's $D$ is a law on $X$ |
| $u=1/\min\{1,\tau-\rho\}$ | `paper.tex` line 174 | yes; $u$ enters only through the cover radius $a=\min\{1/2,(\tau-\rho)/4\}\ge1/(4u)$ |
| Theorem `strong`: quantifier order (teacher, $N\ge C$, $0<\rho<\tau$, $\varepsilon$, then $\sigma_0$, then all $\sigma<\sigma_0$, all $D$, $\delta$, $n$); "the scale threshold may depend on that finite width, the teacher, $\rho$, and $\varepsilon$; it does not depend on $D,n,\delta$" | `paper.tex` lines 178–197 | yes. In the agnostic version $\sigma_0$ also depends on $\rho_0$ (issue 1) |
| Lemma `posterior` | `paper.tex` lines 248–268 | The lemma has **one** radius $\rho$, used both in the hypothesis on $\mu(U_\rho)$ and in $A_h=\{\lvert h-f\rvert>\rho+a\}$, with $2a<\tau-\rho$. Its proof hard-wires the clean-label posterior. Proposition 4.1 needs radius $\rho-\rho_0$ in the tube and $\rho+\rho_0$ in $A_h$, so it does not apply the lemma as stated; the "cover step" bullet re-proves the needed form correctly (Section 2.2) |
| proof of `strong`: Laplace bounds; $K=(M/m)E_*+2$; $a=\min\{1/2,(\tau-\rho)/4\}$; $t=b=\varepsilon/6$; then eq. `confidence` | `paper.tex` lines 510–533 | yes. For Gaussian coordinates $M=m=1$, so $K=E_*+2$ |
| clone energy $E_*=d(d+1)B^2+2(L-1)C^2B^2$ | eq. `teacher-energy`, lines 297–308 | yes; I re-derived the three layer contributions $d(d+1)B^2$, $2C^2B^2$ per internal layer, and $2C^2B^2$ for the readout, using $k_a\ge N/(2C)$ |
| width-free cover $\mathcal H_{K,a}$, common to all widths | Prop. `energy-cover`, lines 462–503 (with Lemma `compression`, lines 413–460) | yes; used as a black box, as Theorem `strong` uses it |
| $X\subseteq[-1,1]^d$ | Remark `cube`, lines 225–232 | yes |
| Prop. `exact`, Cor. `exact` (context paragraph before Prop. 4.1): clean labels, $\kappa_N\le E_*$, $\max_i\lvert z_w(x_i)-f(x_i)\rvert\le\tau/2$ | lines 613–688 | yes |
| TUBE regimes: collapse to $0$ when $\max_i\lvert y_i\rvert<\rho$ (../research-notes/A-tight-conditioning-fails.md Lemma 6.2, Prop. 6.3); infeasibility or forced memorization when $\rho$ is below the residual (../research-notes/A-tight-conditioning-fails.md Lemma 6.4, Prop. 6.5) | `../research-notes/A-tight-conditioning-fails.md` §6.2 (refereed) | consistent with Prop. 4.1, which requires $\rho>\rho_0$ (Section 2.6) |

---

## 2. Audit of the proof

### 2.1 Setting and quantifiers

Fix $L$, a teacher $g$ of depth $L$, width $C\ge1$ and weights in $[-B,B]$ ($B\ge1$, as in the paper), $\rho_0\ge0$, $\rho>\rho_0$ and $\tau>\rho+\rho_0$. The law $D$ on $X\times[-1,1]$ satisfies $\lvert y-g(x)\rvert\le\rho_0$ almost surely. The set $\{(x,y):\lvert y-g(x)\rvert\le\rho_0\}$ is closed because $g$ is continuous, so with probability one every training pair satisfies the bound. Call such samples **admissible**. The posterior is $\Pi_{N,\sigma,S}=\mu_\sigma(\cdot\mid U_{\rho,S})$ with $U_{\rho,S}=\{w:\max_i\lvert z_w(x_i)-y_i\rvert<\rho\}$. This set is open, so it is Borel, and it has positive mass for admissible $S$ (Section 2.2(i)), so the posterior is well defined.

### 2.2 Every place where the proof of `strong` uses clean labels

I traced the proof of Theorem `strong` (lines 510–533) and everything it calls. Labels enter at exactly three points:

**(i) Denominator** (`posterior`, lines 136–137; Lemma `posterior`, hypothesis $\mu(U_\rho)>0$). The tube $U_{\rho-\rho_0}(g)=\{w:\sup_X\lvert z_w-g\rvert<\rho-\rho_0\}$ lies in $U_{\rho,S}$ for every admissible $S$, since $\lvert z_w(x_i)-y_i\rvert\le\lvert z_w(x_i)-g(x_i)\rvert+\rho_0<\rho$. It is open: $X$ is compact and $(w,x)\mapsto z_w(x)$ is jointly continuous. It contains the exact clone $w_*$, because $z_{w_*}=g$ and $\rho-\rho_0>0$. So the paper's Laplace estimates apply unchanged:

$$\liminf_{\sigma\downarrow0}\sigma^2\log\mu_\sigma(U_{\rho-\rho_0}(g))\ge-\tfrac12E_*,\qquad\limsup_{\sigma\downarrow0}\sigma^2\log\mu_\sigma\{\kappa_N>E_*+2\}\le-\tfrac12(E_*+2).$$

I re-derived both from the envelopes $ce^{-Mt^2/2}\le q\le C_0e^{-mt^2/2}$, with $M=m=1$. The ratio tends to $0$, and the threshold depends on $N$, $g$, $\rho-\rho_0$ and $\varepsilon$ only. ✓.

**(ii) "Every fitted $w\in G$ has an approximant $h$ whose $A_h$ contains no training input"** (Lemma `posterior`, proof). Put $A_h=\{\lvert h-g\rvert>\rho+\rho_0+a\}$. If $w\in U_{\rho,S}$ and $\sup_X\lvert z_w-h\rvert\le a$, then
$$\lvert h(x_i)-g(x_i)\rvert\le a+\lvert z_w(x_i)-y_i\rvert+\lvert y_i-g(x_i)\rvert<a+\rho+\rho_0 .$$
So no $x_i$ lies in $A_h$. ✓. The approximant exists because $\mathcal H_{K,a}$ is finite, so the infimum in Prop. `energy-cover` is attained. No measurable selection is needed, as the paper notes (lines 284–289). The union-bound event "every $h$ with $D_X(A_h)>t$ has a training input in $A_h$" depends only on the inputs and holds with probability at least $1-\lvert\mathcal H\rvert e^{-nt}$. ✓.

The test-side implication does not use labels: $\lvert z_w-g\rvert>\tau$ implies $\lvert h-g\rvert>\tau-a>\rho+\rho_0+a$, by $2a<\tau-\rho-\rho_0$. ✓. With the paper's choice $a=\min\{1/2,(\tau-\rho-\rho_0)/4\}$ we have $2a\le(\tau-\rho-\rho_0)/2$ and $a\le1$, as Prop. `energy-cover` requires. Also $1/a\le4u'$, so $\log\lvert\mathcal H_{E_*+2,a}\rvert\le p_L(d,C,B,u')$ for the same (monotone) polynomial majorant. ✓.

**(iii) "For every sample, $\Pi(G^c\mid S_n)\le\mu(G^c)/\mu(U_\rho)$"** (Lemma `posterior`, last lines). This becomes "for every admissible sample, $\Pi(G^c\mid S)\le\mu_\sigma(\kappa_N>E_*+2)/\mu_\sigma(U_{\rho-\rho_0}(g))$", by (i). ✓.

Everything else is label-free and transfers unchanged, with $D$ replaced by $D_X$:

- the Laplace estimates;
- the cover;
- eq. `confidence`, which is Tonelli plus Markov: $\mathbb E_{D_X}[1-q_\tau]=R_\tau(\Pi)$;
- the final integration $R_\tau(\Pi)\le t\,\Pi(G)+\Pi(G^c)\le t+b=\varepsilon/3$.

### 2.3 The risk step

For $\lvert y\rvert\le1$, clipping is the projection onto $[-1,1]\ni y$, so $\lvert\operatorname{clip}z-y\rvert\le\min\{2,\lvert z-y\rvert\}\le\min\{2,\lvert z-g\rvert+\rho_0\}$ almost surely. Splitting on $\{\lvert z_w-g\rvert\le\tau\}$ and using Tonelli (the integrand is continuous in $(w,x,y)$):
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\min\{4,(\tau+\rho_0)^2\}+4R_\tau(\Pi)\le(\tau+\rho_0)^2+\tfrac43\varepsilon .$$
✓. The label range $[-1,1]$ is used here and nowhere else. The example $\rho=2\rho_0$, $\tau=4\rho_0$ needs $\rho_0>0$, and then $u'=1/\min\{1,\rho_0\}$, so the sample size grows polynomially in $1/\rho_0$ (issue 3). $\mathrm{OPT}\le L_D(g)\le\rho_0^2$ is correct.

### 2.4 Width uniformity and limit order

- The cover is common to all widths, so the sample event of (ii) is the same for every $N\ge C$. The sample size has no $N$.
- Only $\sigma_0$ depends on $N$, which is the brief's order: width fixed, then $\sigma\downarrow0$.
- Because $\sigma_0$ does not depend on the sample or on $n$, the statement holds for any order of "$n$ large" and "$\sigma$ small".
- $N\ge C$ is needed for the clone and is assumed.
- No bound on the learner's weights is needed.
- No minimizer is used, since the proof goes through Laplace bounds and not through near-minimizers.
- The conclusion concerns the **clipped Gibbs risk**. By Jensen it also covers $L_D(\mathbb E_\Pi\operatorname{clip}z_w)$. It does not, as written, cover the brief's BMA $\mathbb E_\Pi z_w$ or the unclipped Gibbs risk (issue 8).

### 2.5 The paragraph after the proof

- "*The minimum energy over the constraint set is at most $E_*$ for every $n$*": true for admissible samples, as an **infimum**, since $w_*\in U_{\rho,S}$. The set $U_{\rho,S}$ is open, and the infimum need not be attained; ../research-notes/A-tight-conditioning-fails.md §6.2 points out exactly this at $\rho=1$. Say "infimum" (issue 4).
- "*Never memorizes*": see focus answer 3 and issue 5.
- "*A Gaussian likelihood with fixed $c$ always rewards fitting below the residual level*": correct as a description of $F_{c,S}$, whose data term decreases strictly in every residual. Whether SP$_c$ actually memorizes depends on the memorization cost: A needs $L\ge3$ and $N\ge N_0$, and Prop. 6.1 shows that small widths are safe. As a heuristic contrast it is fine.
- "*For noise-like residuals ($\rho_0\ge1$ for fair signs) Proposition 4.1 is vacuous*": correct.
  - For fair signs, every $g$ has $\operatorname{ess\,sup}\lvert y-g(x)\rvert\ge\max\{\lvert1-g\rvert,\lvert1+g\rvert\}\ge1$ (checked numerically).
  - Then $\tau+\rho_0>3\rho_0\ge3$, and the bound exceeds $9>4$.
  - More generally, the bound is vacuous for every admissible $(\rho,\tau)$ once $\rho_0\ge2/3$.

### 2.6 Consistency with the refereed TUBE results (../research-notes/A-tight-conditioning-fails.md §6.2)

- **Lemma 6.2 / Prop. 6.3** (collapse to the zero network when $\max_i\lvert y_i\rvert<\rho$; excess $\eta_0^2$). Take $g\equiv\eta_0$ (width one, weights at most 2) and $\rho_0=b$, with $\eta_0+b<\rho$. The actual limit risk is $b^2+\eta_0^2<b^2+(\rho-b)^2\le\rho^2<(\tau+\rho_0)^2$. Consistent. It also shows that some excess over $L_D(g)$ of order $(\rho-\rho_0)^2$ is unavoidable for TUBE at a fixed tolerance, even with noiseless labels ($b=0$).
- **Lemma 6.4 / Prop. 6.5** (labels differing by $\ge2\rho$ make TUBE undefined; $\rho<b$ forces memorization). Both require $\rho$ below the residual amplitude. Proposition 4.1 assumes $\rho>\rho_0$. Under that assumption two labels at one input differ by at most $2\rho_0<2\rho$, so TUBE stays defined even with repeated atoms. Consistent.

---

## 3. Issues

1. **(minor) "Verbatim" needs three explicit qualifications.**
   - (a) In Theorem `strong`, "all distributions $D$ on $X$" becomes "all laws $D$ on $X\times[-1,1]$ with $\lvert y-g(x)\rvert\le\rho_0$ a.s.". $R_\tau$ and $q_\tau$ are then taken under $D_X$.
   - (b) "For every sample" (Denominator bullet, and the last line of Lemma `posterior`) becomes "for every admissible sample", which holds with probability one.
   - (c) The scale threshold depends on $\rho_0$ through $\rho-\rho_0$, as well as on $N$, $g$ and $\varepsilon$. So "does not depend on $D$" holds only within the class of laws with residual at most $\rho_0$ for this $g$. Also, $\sigma_0$ depends on $g$, which in the agnostic setting is chosen after $D$. This is harmless in the $\sigma\downarrow0$ formulation, but it should be stated.
   - Further, Lemma `posterior` is not applicable as stated, because it has a single radius. The proposition should state the two-radius variant: tube radius $\rho-\rho_0$, $A_h$ radius $\rho+\rho_0$, condition $2a<\tau-\rho-\rho_0$. The proof bullet already proves it.
   - State the paper's standing hypotheses $C\ge1$ and $B\ge1$, and $X\subseteq[-1,1]^d$ compact (Remark `cube`).

   *Fix:* restate Theorem `strong` in agnostic form, as in the corrected statement (Section 4).
2. **(minor) The displayed conclusion omits its quantifiers.** It holds with probability at least $1-\delta$ over the sample, for every $N\ge C$ and every $\sigma<\sigma_0(N,g,\rho-\rho_0,\varepsilon)$, and the sample event can be taken common to all $N\ge C$ and all $\sigma$. *Fix:* write these into the display.
3. **(minor) The example choice $\rho=2\rho_0$, $\tau=4\rho_0$.** It needs $\rho_0>0$, and it gives $u'=1/\min\{1,\rho_0\}$, so the sample size is $\mathrm{poly}(d,C,B,1/\rho_0)/\varepsilon$. The resulting $25\rho_0^2$ is below $1$ (an upper bound on the zero predictor's risk $L_D(0)=\mathbb Ey^2$) only when $\rho_0<0.2$; the trivial bound for the clipped TUBE risk itself is $4$. *Fix:* state these.
4. **(minor, wording) "the minimum energy over the constraint set".** The constraint set is open, so this should be "the infimum". The strong-prior posterior concentrates near the infimum over the closure, which is still at most $E_*$.
5. **(minor, overstatement) "Hard conditioning within the sup-norm residual of a small network never memorizes."** Only the energy statement is proved: the posterior stays in $\{\kappa_N\le E_*+2\}$ for every $n$. Via Lemma 3.1 or Remark 3.5, that bounds the fraction of noise it can fit, uniformly in $n$, by $O(\mathcal D(E_*/H)^{H/2}/\sqrt n)$. The sentence is not a consequence of Proposition 4.1's risk bound:
   - (a) That bound allows an excess over $L_D(g)$ of more than $8\rho_0^2$. The memorization harm exhibited in A (labels $\pm\rho_0$, scaled) is $\beta(\lambda)\rho_0^2\le0.5174\rho_0^2$ (`check_examples.out`). So the bound does not certify that TUBE avoids memorization-level excess, and it cannot be used to separate TUBE from SP$_1$.
   - (b) At finite $n$, energy-minimizing feasible networks can track the noise at binding constraints. Nothing in the argument excludes this.
   - (c) TUBE has a tolerance bias of up to $(\rho-\rho_0)^2$ that is not memorization (../research-notes/A-tight-conditioning-fails.md Prop. 6.3).

   *Fix:* reword as "the strong-prior TUBE posterior stays in an $n$-independent energy sublevel, so it cannot memorize a growing number of residuals". Cite the sharpened bound of Section 4 for the risk comparison: with $\rho<\sqrt{1+\beta}\,\rho_0\approx1.23\rho_0$ it gives a TUBE risk below SP$_1$'s memorization lower bound $(1+\beta)\rho_0^2$.
6. **(minor, framing) Proposition 4.1 is presented as a "version of the conjecture that survives"** (§0 item 7, §6.3 item 3, §7 item 5). It is not an agnostic oracle inequality, for three reasons:
   - (a) It assumes an almost-sure sup-norm residual bound for a fixed small network. That is a near-realizable assumption, and it excludes every law with binary noisy labels, for which $\rho_0\ge1$.
   - (b) The learner must know $\rho_0$ within a constant factor to set $\rho$.
   - (c) The guarantee is relative to $\rho_0^2$, not to $L_D(g)$ or OPT. When the residual is mostly much smaller than $\rho_0$, OPT can be far below the bound. By ../research-notes/A-tight-conditioning-fails.md Prop. 6.3(b), TUBE at a fixed tolerance has excess up to $(\rho-\rho_0)^2$ even for noiseless labels, so no admissible $\rho$ gives OPT $+\,\varepsilon$ in general.

   §6.3's qualifier "at the price of a constant factor and the sup norm" covers part of this. *Fix:* call it a bounded-residual (near-realizable) guarantee, and state (a)–(c).
7. **(minor, looseness) The constant.** $(\tau+\rho_0)^2>(\rho+2\rho_0)^2$ can be replaced by $\rho^2$ (Section 4, part (b)). That is a factor of $25/4$ at $\rho=2\rho_0$, and as $\rho\downarrow\rho_0$ the bound tends to $\rho_0^2$. The sharpened bound is nearly tight: over the family of ../research-notes/A-tight-conditioning-fails.md Prop. 6.3(b), the actual limit risk reaches $\rho_0^2+(\rho-\rho_0)^2$, and it reaches $\rho^2$ when $\rho_0=0$ (`check_examples.out`). The trade-off is that the sample size scales as $1/\varepsilon^2$ instead of $1/\varepsilon$. In exchange it no longer depends on $\tau$, $\rho$ or $\rho_0$.
8. **(minor, scope) Predictors and priors.**
   - Proposition 4.1 bounds the clipped Gibbs risk, and by Jensen the risk of $\mathbb E_\Pi\operatorname{clip}z_w$.
   - The brief's BMA $\mathbb E_\Pi z_w$ and the unclipped Gibbs risk need an extra uniform-integrability step. This is likely routine from the Gaussian tails (compare Lemma 1.1), but it is not given.
   - The proposition covers only the strong-prior limit.
     - The $\gamma>1$ finite-scale route appears to transfer as well. In Lemma `mass-posterior`, a parameter with $D_X\{\lvert z_w-g\rvert>\tau\}>t$ violates the constraint at any training input in that set, since $\lvert z_w-y\rvert>\tau-\rho_0>\rho$. The tube-mass constant would become $A_L(d,C,B,\rho-\rho_0)$. I did not check this in full, and the red team does not claim it.
     - The mean-field endpoint was not examined.
9. **(minor, context paragraph, line 361) "Remark 3.5 with $\phi=p=1$".** With $p=1$, Remark 3.5 says that if *every* sign vector can be interpolated at energy $K$, then $K\ge H(s/\mathcal D^2)^{1/H}$. That is a worst-case statement over labelings, not a statement about random labels. For random labels use $p<1$: with probability at least $1-p_0$ over the signs, every interpolant has energy at least $H(p_0^2s/\mathcal D^2)^{1/H}$. This is the same $s^{1/H}$ growth, so the conclusion "$\to\infty$, outside the budget $E_*$" stands.

I found no issue in the logic of the denominator step, the cover step or the risk step.

---

## 4. Strongest statement supported

**Proposition 4.1′.** Fix $L\ge2$ and a depth-$L$ teacher $g$ of width $C\ge1$ with weights in $[-B,B]$, $B\ge1$. Put $E_*=d(d+1)B^2+2(L-1)C^2B^2$. Let $X\subseteq[-1,1]^d$ be compact, let $\rho_0\ge0$, and let $D$ be any law on $X\times[-1,1]$ with $\lvert y-g(x)\rvert\le\rho_0$ $D$-almost surely. Let $\rho>\rho_0$. At width $N\ge C$ let $\Pi=\Pi_{N,\sigma,S}$ be the strong-prior Gaussian prior $\mu_\sigma$ conditioned on $\max_i\lvert z_w(x_i)-y_i\rvert<\rho$.

**(a) Agnostic form of Theorem `strong`.** Let $\tau>\rho+\rho_0$, put $u'=1/\min\{1,\tau-\rho-\rho_0\}$, and let $p_L$ be the polynomial of Theorem `strong`. For every $\varepsilon\in(0,1)$ and $N\ge C$ there is $\sigma_0=\sigma_0(N,g,\rho-\rho_0,\varepsilon)>0$. It does not depend on the sample, on $n$, on $\delta$, or on $D$ within this class. For every $\delta\in(0,1)$ and every $n\ge\frac6\varepsilon[p_L(d,C,B,u')+\log\frac1\delta]$ there is a sample event of probability at least $1-\delta$. It is the same for all $N\ge C$ and all $\sigma$. On it, for every $N\ge C$ and every $\sigma<\sigma_0$:
$$R_\tau(\Pi):=\mathbb E_\Pi D_X\{\lvert z_w-g\rvert>\tau\}\le\varepsilon/3,\qquad D_X\{q_\tau\le2/3\}\le\varepsilon,$$
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\min\{4,(\tau+\rho_0)^2\}+\tfrac43\varepsilon .$$
By Jensen, the same holds for $L_D(\mathbb E_\Pi\operatorname{clip}z_w)$.

**(b) Sharper risk bound.** Let $\mathcal H=\mathcal H_{E_*+2,\varepsilon/32}$ be the width-free cover of Prop. `energy-cover`, and let $n\ge32\varepsilon^{-2}[\log\lvert\mathcal H\rvert+\log\frac1\delta]$. This is polynomial in $d,C,B,1/\varepsilon$ and $\log(1/\delta)$ at fixed $L$, and does not depend on $\rho,\rho_0,\tau,N$. Then there is $\sigma_0'=\sigma_0'(N,g,\rho-\rho_0,\varepsilon)$ such that, with probability at least $1-\delta$, for every $N\ge C$ and every $\sigma<\sigma_0'$:
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\rho^2+\varepsilon .$$
More precisely, every $w$ with $\max_i\lvert z_w(x_i)-y_i\rvert<\rho$ and $\kappa_N(w)\le E_*+2$ has $L_D(\operatorname{clip}z_w)\le\hat L(\operatorname{clip}z_w)+\tfrac34\varepsilon<\rho^2+\tfrac34\varepsilon$.

**(c) Energy.** For every admissible sample and every $n$, $\inf\{\kappa_N(w):\max_i\lvert z_w(x_i)-y_i\rvert<\rho\}\le E_*$. So the posterior stays in the $n$-independent sublevel $\{\kappa_N\le E_*+2\}$, up to mass that tends to $0$ as $\sigma\downarrow0$.

**Limits of the statement.** These are bounded-residual guarantees, relative to $\rho_0^2$ (or $\rho^2$), not oracle inequalities against OPT. The best bound that depends only on $(\rho,\rho_0)$ lies between $\rho_0^2+(\rho-\rho_0)^2$ (../research-notes/A-tight-conditioning-fails.md Prop. 6.3(b)) and $\rho^2$.

*Proof of (b).*

- **High-energy mass.** As in Section 2.2(i), choose $\sigma_0'$ so that $\Pi(\kappa_N>E_*+2)\le\varepsilon/16$ for every admissible sample.
- **Uniform deviation.** The losses $\ell_h(x,y)=(\operatorname{clip}h(x)-y)^2$, $h\in\mathcal H$, are Borel with values in $[0,4]$. One-sided Hoeffding and a union bound give, with probability at least $1-\delta$,
$$L_D(\operatorname{clip}h)\le\hat L(\operatorname{clip}h)+4\sqrt{\ln(\lvert\mathcal H\rvert/\delta)/(2n)}\le\hat L(\operatorname{clip}h)+\varepsilon/2\quad\text{for all }h\in\mathcal H .$$
- **Cover approximation.** Since $\lvert(\operatorname{clip}u-y)^2-(\operatorname{clip}u'-y)^2\rvert\le4\lvert u-u'\rvert$ for $\lvert y\rvert\le1$, an approximant with $\sup_X\lvert z_w-h\rvert\le\varepsilon/32$ moves both the population and the empirical loss by at most $\varepsilon/8$.
- **Feasible networks.** Every feasible $w$ has $\hat L(\operatorname{clip}z_w)\le\max_i(z_w(x_i)-y_i)^2<\rho^2$. Hence $L_D(\operatorname{clip}z_w)<\rho^2+\varepsilon/8+\varepsilon/2+\varepsilon/8$.
- **Conclusion.** Integrating over $\Pi$, and adding $4\cdot\varepsilon/16$ for the high-energy mass, gives $\rho^2+\varepsilon$. ∎

---

## 5. Independent checks

Scripts and outputs are in `../checks/verify-RT-tube-logic/`.

- **`check_elementary.py` → `check_elementary.out`.** $2\times10^6$ random instances of each elementary implication of the proof, with zero violations:
  - the two cover-step implications;
  - the risk inequality $(\operatorname{clip}z-y)^2\le\min\{4,(\lvert z-g\rvert+\rho_0)^2\}$;
  - the 4-Lipschitz bound for the clipped loss used in Section 4;
  - the tube-in-constraint-set containment.
- **`check_examples.py` → `check_examples.out`.**
  - Over the family of ../research-notes/A-tight-conditioning-fails.md Prop. 6.3(b) ($\rho_0\in\{0.02,0.05,0.1\}$, $\rho\in\{1.1\rho_0,2\rho_0\}$), the exact limit TUBE risk $\rho_0^2+\eta_0^2$ always lies below $\rho^2$, which lies below $(\rho+2\rho_0)^2$.
  - The supremum of the actual risk over the family is $\rho_0^2+(\rho-\rho_0)^2$, and it equals $\rho^2$ at $\rho_0=0$.
  - $\max_\lambda\beta(\lambda)=0.517351$ at $\lambda\approx1.503$, and $\beta(1)=0.484829$ (agreeing with `../research-notes/red-team.md`).
  - $\sqrt{1+\max\beta}=1.2318$.
  - $\min_g\max\{\lvert1-g\rvert,\lvert1+g\rvert\}=1$.
