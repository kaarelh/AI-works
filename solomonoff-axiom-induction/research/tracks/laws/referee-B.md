# Referee report B (computation and counterexamples) on thread `laws`

*Referee B, 2026-10-16. Record reviewed: `notes.md` (653 lines) and the nine scripts in `checks/` with their saved outputs. Independent code: `referee_code/rb1_*.py` to `rb8_*.py`, each seeded or deterministic, each with its output saved next to it. Referee A's report (`referee-A.md`) was read only after all rb scripts had been run; where both reports raise the same point, this is noted.*

## Verdict

**Accept after revision. Nothing is fatal. Two issues are major.**

* **The formal results hold.** Every exact formula I could test exactly holds. This covers the formulas of §§1–7: Lemma 3.2 in rational arithmetic in all regimes, Lemma 3.6, Props 3.4 and 3.5 (including atoms), Thm 3.8, Prop 4.1, Helly in dimension 1, Prop 5.5's closed form, Prop 5.6, Prop 5.8, Prop 7.1(a)–(c),(e), and the semimeasure and coding claims of §1 on propositional fragments.
* **The scripts reproduce.** All nine developer scripts reproduce their saved outputs exactly, apart from the runtime line. This includes `l4`, whose 117 residual arrays are bitwise equal.
* **Major issue 1.** Under "SAI's pricing" the comparison pool leaves out natural randomised laws that are just as short. They beat the honest law H everywhere. So the record's headline that "under SAI's pricing the inducer holds Kepler's law honestly, at every precision" is an artifact of the pool. One half of a refutation in §10 is reversed.
* **Major issue 2.** The reading of Prop 7.1, that the honest form is "exactly what the two theories have in common", is false. Referee A's M2 says the same.
* **Minor issues.** Most are statement scope or numerics. Two numerical artifacts in `l8` change reported values.

## What was run

| script | tests | result |
|---|---|---|
| `rb1_dither_exact` | Lemma 3.2 in exact rationals, all regimes; Lemma 3.6 (coarse cost, fine-regime bound); Prop 3.5 with atoms; Prop 3.4 thresholds; Prop 2.4 $r(\delta)$; Prop 2.5 $p_\Delta$ | 20000/20000 exact matches; 21712/21712 quantile-rule tests; thresholds as recorded; fine bound loose by a factor 2 (issue 8) |
| `rb2_sai_pricing` | completeness of the R/rand pool: two band-confined machines added (HY, SH), synthetic errors and the real residuals | issue 1 |
| `rb3_selection` | the code-Q statements of §3.6 recomputed exactly from the residuals; Cor 3.9 and the tie claims by independent simulation (seed 20261017) | "17 of 39" reproduced; takeover widths reproduced to grid resolution; all sample means inside Wald intervals |
| `rb4_best_system` | Prop 5.5 brute force (10500 cases, exact); the K3 statement; Prop 5.6 (7170 exact checks, degenerate families); N2's hull; Prop 5.8 | closed form correct; literal (b) wrong in 475/5035 cases (issue 3); Prop 5.6 and N2's kink $(7.03,135.37)$ confirmed |
| `rb5_horizons` | Prop 4.1(b) by enumerating all sign vectors in exact rationals; $r^*(\delta)$; a nonlinear map; Helly; Remark 4.4 | zonotope exact in 600/600; horizon formula exact in 2015/2015; "iff" fails for nonlinear $F$ (issue 6) |
| `rb6_correction` | Prop 7.1 in exact rationals; models refuting the reading | (a)–(c),(e) reproduced digit for digit; issue 2 |
| `rb7_domains` | Props 6.1, 6.2 recomputed from the residuals with exact dither averages; bisection for $\Delta^*$ | issues 4, 5 |
| `rb8_logic_finite` | Def 1.1, Prop 1.10(ii), Prop 1.11(a), Prop 2.1 on 4-atom propositional fragments (exact); the machine $G_T$ of Prop 1.8 simulated bit by bit | 0 violations in 236267 + 4000 + 2986 cases; simulation within 1 s.e. of $P^R_T$ |

---

## Major issues

### 1 (major). Under SAI's pricing the pool is incomplete, and the uniform honest law is not what SAI favours

**Where.**
* §0, T3, "Real Kepler residuals" and "Criterion" ("under SAI's own pricing … honesty wins unless the error is very peaked").
* Prop 3.4, the R/rand specialisation (threshold "roughly 5–30").
* §3.6, "Selection", first bullet ("the inducer holds Kepler's law as approximately true … for every planet and the Moon") and its Reading.
* §3.5, the Reading after Prop 3.10.
* §8, first bullet.
* §9.1, first and second bullets ("for Kepler's real errors, wins at every precision").
* §10, item 2 (its R/rand half: "under R/rand the peaked error ($\mathrm{pk}=20$) is held honestly") and item 6.

**Problem.** The R/rand comparison has a fixed pool:
* 0, the empty law;
* P, the exact law whose exceptions are completed uniformly on the *whole circle*;
* H, the band $[f-\varepsilon^*,f+\varepsilon^*]$ completed *uniformly*;
* tolerance laws with whole-circle exceptions.

$M_A$ mixes all theory machines (Prop 1.9(a)), and two equally natural, equally short machines are missing:
* **HY($\rho$):** with probability $1-\rho$ emit $q_t=f(t)$, otherwise a uniform point of the band. In words: "exact, except in a share $\rho$ of cases, and then within $\varepsilon^*$". It is a theory machine of length $|T^{\varepsilon^*}|+O(\text{bits of }\rho)$. Its random theory is always consistent.
* **SH:** a point of the band drawn from a fixed density shaped like the error distribution (in `rb2`, a 40-bin histogram fitted on half of the sample times and evaluated on the other half).

**Two exact facts (proved here; both checked in `rb2`).** Work in the coarse regime $\Delta\ge2\varepsilon^*$, in band coordinates $[0,1]$, with $f$ at $\tfrac12$ and $q$ at $x=(\varepsilon^*-e)/(2\varepsilon^*)$.

By the proof of Lemma 3.6, a band-confined machine costs 0 unless a cell boundary falls inside the band. That happens with probability $2\varepsilon^*/\Delta$, and the boundary's position $V$ is then uniform on $[0,1]$. A machine with completion CDF $G$ then pays $-\log G(V)$ if $x<V$ and $-\log(1-G(V))$ if $x>V$. So every band-confined machine has rate $(2\varepsilon^*/\Delta)\,c_G$, where $c_G$ is a per-straddle cross-entropy, and **their ranking does not depend on $\Delta$**.

* **(F1) Uniform completion is optimal only for uniform errors.** For each $V$ the outcome $[x<V]$ is Bernoulli$(F(V))$, where $F$ is the law of $x$. So $c_G\ge\Ex_V H_2(F(V))=c_F$ (Gibbs), with equality iff $G=F$ almost everywhere. Hence H (which has $G(V)=V$) is the best band-confined machine iff $e$ is uniform on $[-\varepsilon^*,\varepsilon^*]$.
* **(F2) When "exact except in a share $\rho$" beats the honest law.** For HY$(1-s)$, $c(s)=\Ex[-\log(\text{affine in }s)]$ is convex in $s$. Its right derivative at $s=0$ (in nats) is
  $$c'(0^+)=\Ex\ln\!\Big(1+\frac{|e|}{\varepsilon^*}\Big)+1-2\ln2 .$$
  Derivation: by symmetry take $x\le\tfrac12$. The three ranges $V<x$, $x<V<\tfrac12$ and $V>\tfrac12$ contribute $-\int_0^x\frac{V}{1-V}dV$, $+(\tfrac12-x)$ and $-\int_{1/2}^1\frac{1-V}{V}dV$; the sum is $\ln(1-x)+1-\ln2$; and $1-x=(1+|e|/\varepsilon^*)/2$.

  So **HY($\rho$) beats H for some $\rho<1$ iff $\Ex\ln(1+|e|/\varepsilon^*)<2\ln2-1\approx0.386$.** By Jensen ($\Ex\ln(1+X)\le\ln(1+\Ex X)$), a sufficient condition is
  $$\mathrm{pk}(e)\ >\ \frac{e}{4-e}\ \approx\ 2.12 .$$
  Uniform $|e|$ sits exactly on the boundary, since $\int_0^1\ln(1+u)\,du=2\ln2-1$.

So a peakedness criterion does survive under SAI's pricing. But its threshold is about 2.1, not the record's 5–30, and the winner above it is "exact except in a share $\rho$, then within $\varepsilon^*$", not the honest law.

**Evidence (computed: `rb2_sai_pricing.out`).** Per-straddle costs are in bits.

| error | H | HY* (best $\rho$) | SH |
|---|---|---|---|
| sinusoid, pk $=\pi/2$ | 0.8854 (closed form 0.8854) | 0.8854 at $\rho=1$ ($\Ex\ln(1+|e|/\varepsilon^*)=0.473$) | 0.8507 |
| peaked, $\pm1$ on 5%, pk = 20 | 0.4925 | **0.1795 at $\rho=0.099$** | 0.1977 |
| $|e|\sim U[0,1]$, pk = 2 | 0.7208 | 0.7208 at $\rho=0.999$ (boundary case) | 0.7198 |
| Mars, 12 y (real) | 0.6043 | 0.5826 at $\rho=0.72$ | 0.5621 |
| EMB, 100 y (real) | 0.5194 | 0.4548 at $\rho=0.53$ | 0.4106 |
| Jupiter, 30 y (real) | 0.8374 | 0.8374 at $\rho=1$ | 0.8003 |

* **The real residuals** (39 body–window pairs, minimax-fit series):
  * SH < H in **39/39** pairs (split sample, so not in-sample flattery);
  * HY* < H in **33/39** pairs, with best $\rho$ between 0.53 and 0.95;
  * the exact criterion of (F2) agrees in 39/39; the Jensen corollary has 0 violations;
  * with exact coarse-regime rates and stratified fine-regime rates at $\Delta\in\{1',10',60',600',1800'\}$, adding HY and SH changes the winner in **195/195** cells. In every cell the record's winner among $\{0,\mathrm P,\mathrm H\}$ is H, which reproduces `l5`; SH has the least rate. SH's rate is 0.6%–21% below H's. At fine precision the gain stays: at $\Delta=1'$, EMB over 300 years has H 1.459 against SH 1.152 bits per datum.
* **The peaked synthetic error at $\Delta=60'$:** P 0.0171, H 0.0164, HY* 0.0060 bits per datum. So under SAI's pricing, with exceptions completed inside the band, the peaked error is held as "exact except in about 10% of cases", at about a third of H's rate. This is scout N2's original reading ("concentrated errors favour exact laws with exceptions"). The R/rand half of §10 item 2 therefore does not survive.

**What this means.** In the deterministic, code-Q reading the record's dichotomy (honest law against law with exceptions) is real. In SAI's randomised reading, which the record itself calls "the pricing SAI's one-tape law actually uses", the competing objects are *predictive distributions over the band*:
* the uniform band is the special case for uniform errors;
* asymptotically the posterior favours a law plus an error distribution that matches the residuals (SH);
* when the residuals are concentrated near 0, even the crude two-point model HY beats the uniform band.

"Humility" in this reading is calibration of a learned error distribution, not a uniform spread over the band (compare the Reading of Prop 3.10(c)). The comparisons are asymptotic, like the record's own (Thm 3.8(i)). HY needs a few bits more than H (for $\rho$), and SH a few hundred (a histogram). So the crossover comes after roughly $10^2$–$10^5$ data, depending on $\Delta$ (for example, HY for Mars over 12 years: about 100 data at $\Delta=1'$, about $10^4$ at $60'$).

**Fix.**
1. State every R/rand verdict relative to its pool: "among $0$, P, H and the tolerance family with whole-circle exceptions".
2. Add (F1) and (F2), with their proofs, after Lemma 3.6. Add the HY/SH rows of `rb2` to §3.6.
3. Rewrite the §3.6 Reading, §8 bullet 1, §9.1 bullets 1–2 and §0 accordingly. A suitable formulation: under SAI's pricing what is selected among simple laws is a law with an error distribution shaped like the residuals. The two-point form "exact except in a share $\rho$, then within $\varepsilon^*$" beats the uniform honest law iff $\Ex\ln(1+|e|/\varepsilon^*)<2\ln2-1$, which holds for 33 of the 39 Kepler body–window pairs.
4. Restrict §10 item 2 to Q/rand (where the sinusoid counterexample stands), and drop or reverse its R/rand half.
5. In §10 item 6, "win on Kepler's residuals" needs the same scope.

### 2 (major; Referee A's M2 found the same independently). Prop 7.1's reading: the honest form is not "exactly what the two theories have in common"

**Where.** §0 (T7: "shares with it exactly the honest form"); §7, Reading, second bullet; §9.1, "Explanation" ("exactly what its successor derives and what the two theories have in common").

**Problem.** Prop 7.1(d) is correct as stated: among the *uniform-tolerance* sentences $H^\varepsilon_W$, the strongest common consequence is $H^{\varepsilon_{\min}(W)}_W$. The readings drop that restriction, and are false without it. Two exact counterexamples (`rb6_correction.out`):
* **(i) A stronger common tolerance law.** The time-dependent tolerance law $\{|x_t-R^ta|\le\varepsilon_t:t\le W\}$, with $\varepsilon_t:=|A^ta-R^ta|$, is a common consequence of $T_0^W$ and $T_N^W$. It is strictly stronger than $H^{\varepsilon_{\min}(W)}_W$:
  * for $P=JR$ and $W=100$, $\varepsilon_1=0.01$ against $\varepsilon_{\min}=0.961$;
  * the uniform tolerance is 1.7–2.2 times the mean of $\varepsilon_t$ for the three perturbations at $W=10,100$;
  * the rational point $x_1=Ra+(35807/73735,0)$ satisfies $H^{\varepsilon_{\min}}_W$ and violates it.
* **(ii) The strongest common consequence.** Since $T_0^W$ and $T_N^W$ are finite, it is $(\bigwedge T_0^W)\vee(\bigwedge T_N^W)$, which includes $x_0=a$. The rational model $x_t=R^ta+(10^{-4},0)$ satisfies $H^{\varepsilon_{\min}}_W$ and neither theory.

Also, the successor derives far more than the honest form (it proves $x_t=A^ta$).

**Fix.** Read (d) as: "among tolerance statements of the form 'within $\varepsilon$ of the old law's prediction at every $t\le W$', the strongest one the successor proves is $H^{\varepsilon_{\min}(W)}_W$; the time-dependent version is stronger still." Then rephrase §0 and §9.1: the successor derives an honest form of the old law with a derived, window-dependent tolerance, and refutes its exact form. Drop "exactly what the two have in common".

---

## Minor issues

### 3 (minor; not in Referee A). Prop 5.5(b): "K3 enters iff $s|S|>L_3$, whatever $\lambda$ is" is false read literally

The closed form is right: brute force over all $2^{m+2}$ theories agrees with it in 10500/10500 exact cases (`rb4` A). The record's own check (`l7` A) tests only the conditional comparison $J^*(\Lambda+K3)<J^*(\Lambda)$. Statement (b) says "enters", and the bullet of §5.2 and §9.1 read it as "is in the λ-MAP". Among 5035 random cases with $S$ the same with and without K3, the literal reading fails in **475**: there the empty theory beats both law choices.
* Hand counterexample: two bodies with one observation each, $c=10$, $L=1000$, $k=5$, $s=4$, $L_3=1$, $\lambda=1$. Then $S$ is both bodies with and without K3, and $s|S|=8>L_3$. But the λ-MAP is the empty theory: $J=20$, against $J^*(\Lambda)=1010$ and $J^*(\Lambda+K3)=1003$.
* Random counterexample: one body with $n=28$, $c=4$, $L=100$, $L_3=1$, $k=60$, $s=31$: $J^*(\emptyset)=112<J^*(\Lambda+K3)=130<J^*(\Lambda)=160$.

**Fix.** Write "$J^*_{\Lambda+K3}<J^*_\Lambda$ iff $s|S|>L_3$; K3 is in the λ-MAP iff in addition $J^*_{\Lambda+K3}<J^*_\emptyset$". The refutation of N2's criterion stands.

### 4 (minor; not in Referee A). `l8` B: the code-R values of $\Delta^*$ at $c_N=1$ are artifacts of an upper bound

`l8_domains.py` prices silence in the fine regime with the bound $\log(2\varepsilon^*/\Delta)+2\log e$ (its line "fine-regime upper bound"). That bound never falls below 1 bit per datum, so every code-R entry at $c_N=1$ lands just above $2\varepsilon^*$:

| row | record | $2\varepsilon^*$ |
|---|---|---|
| Mercury 100 y | 4.13′ | 4.05′ |
| Mars 12 y | 2.92′ | 2.88′ |
| Mars 2000 y | 102′ | 99.8′ |
| Jupiter 100 y | 13.5′ | 13.1′ |
| Saturn 2000 y | 166′ | 164′ |
| Moon 1 month | 62.4′ | 61.8′ |

With the exact fine-regime rate (512 stratified dithers per time, bisection; `rb7` B), the values are **Mars 12 y: 1.744′** and **Moon 1 month: 44.4′**. The other columns agree with the record up to its grid (Mars 12 y: Q 1202′, 195.6′, 27.7′; R 174.2′, 17.4′). Also, `rb7` finds the code-R rate of K non-increasing in $\Delta$ on a 120-point grid for both series (computed support for Prop 6.2(c); compare Referee A's m5).

**Fix.** Compute the fine regime exactly, or label the $c_N=1$ code-R column "upper bound on $\Delta^*$". The §6.2 Reading's "about ten times finer" should then be recomputed.

### 5 (minor). Prop 6.1(b) fails at the exact tie on which the record's own Moon example rests; and one `l8` A cell is decided by Monte Carlo noise

* **The tie (Referee A's M4 also).** In code Q with $\Delta\le2\varepsilon^*_M$, the honest law is silent on *every* datum. So its per-datum cost equals the restriction's ($\gamma$) identically: `rb7` A finds $H(Q)-\gamma=0$ exactly at $\Delta=10',60',300'$. By Thm 3.8(ii) the constants then decide, and the restriction ($\lambda\|\mathrm{Dom}\|$ against $\lambda(k_M+h_M)$) wins forever. But (b)'s condition $\gamma<\min(m_P,m_H)$ is **false** there. (b) predicts no restriction, while the table (and the truth) has "Moon excluded". (c) states this case correctly.
* **The noisy cell (not in Referee A).** The `l8` A cell "$\Delta=600'$, $\lambda=2$, code Q: honest (rates within 0.001: 34542 data to overtake)" is decided by noise. This cell is in the coarse regime, where H's rate is exactly $q\gamma=2.6939$; `l8` estimated it by Monte Carlo as 2.692. The exact rate of P is $p(\lambda\pi_c+\gamma)=2.6934$. P has both the lower rate and the smaller constant, so it wins from the start. The cell should read "exceptions".

**Fix.** Use Thm 3.8's three cases in (b), as Referee A proposes. Compute coarse-regime cells of `l8` A exactly, as `l5` already does.

### 6 (minor; Referee A's m9 for Prop 4.2). Prop 4.1(c) and Prop 4.2 state an "iff" that holds only for linear $F$

(c) is stated "in $d=1$ with $e_0=0$" in a setting that allows any Lipschitz $F$. Counterexample (`rb5` C, exact): $F(x)=0$ on $[-1,1]$ and $F(x)=2(x-\operatorname{sign}x)$ outside, so $L=2$, with $a=0$ and $\varepsilon=1/10$.
* The exact set of values of $x_r$ over the models is $[-1/10,1/10]$ for every $r\le30$.
* So the honest law proves "$x_r\in[-1/10,1/10]$" at every depth, while $e_r=(2^r-1)/10$ gives $r^*(1/10)=1$.

For linear maps the horizon formula is exact in 2015/2015 cells, and the zonotope is exact in 600/600 cases (`rb5` A, B).

**Fix.** Add "for linear $F(x)=Ax$, $L=|A|$" to (c) and to the "iff" of Prop 4.2. For general $F$ only "if" holds.

### 7 (minor). Lemma 3.6's fine-regime bound is loose by a factor 2

This is Referee A's m4; here is the computed side. Over $L/\Delta\in[1,20]$ and $w\in[0,1]$, the maximum of $\Ex[-\log(y/\Delta)]$ is **1.4427 = $\log e$**. It is attained at the corner $L=\Delta$, $w=1$, where the cost is $\Ex[-\log U]$ (`rb1` B). So the constant $R/(2e^2)\approx24°$ of Prop 3.7, Prop 6.1(c) and §§6.1, 8 becomes $R/(2e)\approx66°$ once the bound $\log e$ is proved. The present statements are correct as sufficient conditions. But the Reading of §6.1 presents 24° as the threshold at which sharp domains appear.

### 8 (minor; Referee A's M6). The reported peakedness is a cross-fit ratio

`l5` A computes $\mathrm{pk}=\varepsilon^*(\text{minimax fit})/\Ex|e|(\text{mean fit})$. That ratio ranges over 1.85–3.98. The single-fit values are 1.60–3.95 for the minimax fit and 1.89–7.08 for the mean fit (computed here from `l4_residuals.npz`). Issue 1's criterion uses the minimax fit's own error, as it must.

### 9 (minor). Small numerical statements

* **§3.6, $\pi_c$.** "$\pi_c=\log(\text{days in window})+2$ bits (14–22 bits)": the Moon's windows give 6.9 bits (1 month), 10.5 (1 year) and 14.7 (18.6 years).
* **§2.2, "1/p" values.** The values quoted as $1/p_\Delta$ are Monte Carlo estimates (94.2, 943.4, 12006). The exact values are $\pi\Delta/2=94.25$ and $942.48$, and $12000$ (`rb1` F).
* **The "1757/1757" check of Prop 3.4.** In the det pricings it compares a formula with its own rearrangement, so it is a consistency check of the code, not evidence for the proposition. The exact checks of `rb1` A and D are the evidence.
* **§3.6, "in two windows already 10°".** Three pairs reach H at 600′ under Q/det at $\lambda=1$: Jupiter 30 y, Saturn 300 y and Saturn 2000 y. `l5` marks the Saturn 300 y cell lower-case, meaning within 2% of the runner-up. Say "two (three, counting a near-tie)".

### 10 (minor; Referee A's M1). Setting S3's times

An atomless law of i.i.d. times cannot live on the countable set of numerals that Def 1.5 requires. I agree with Referee A's analysis and fix (a fine finite time grid, with repeats either handled or shown negligible). Computationally this changes nothing in the scripts, which use float times and a fixed $\pi_c$.

---

## What was checked and found correct (with the evidence)

* **Lemma 3.2.** The exact u-measures of "prove" and "refute" were computed from the two defining inequalities in rational arithmetic: 20000/20000 agree with the closed forms over $\Delta\in(0,60]$, $\varepsilon\in[0,40]$ and $e\in[-80,80]$. Silence is exactly $2\varepsilon/\Delta$ in the coarse regime (`rb1` A).
* **Lemma 3.6, coarse formula.** $\log e-H_2(w)$ agrees to $2.5\times10^{-6}$ by quadrature. $\beta_e$ is 0.8854 for the sinusoid and 0.4927 for the peaked error (`rb1` B, D).
* **Prop 3.5.** Over 3000 random discrete $|e|$ laws with atoms (21712 tests, exact rationals), the minimiser set equals $\{\varepsilon:\Pr[|e|>\varepsilon]\le\theta\le\Pr[|e|\ge\varepsilon]\}$, including the $\theta\ge1$ case. "Pure honest optimal iff $\Pr[|e|\ge\varepsilon^*]\ge\theta$" holds with 0 mismatches (`rb1` C).
* **Prop 3.4 thresholds** (`rb1` D):
  * Q/rand: 0.637, 0.742, 0.971;
  * R/rand: 9.22–9.31 for the sinusoid, 20.45–20.46 for the peaked error;
  * Q/det: sinusoid P/P/H at $\Delta=3',10',60'$.

  All as recorded. They are correct *within the record's pricings*; issue 1 concerns the pool, not the arithmetic.
* **Props 2.4 and 2.5** (`rb1` E, F). The exact $r(\delta)$ is $0.218$ at $\delta=1$, $6.0\times10^{-4}$ at $1.49$ and 0 at $\ge1.5$, matching `l2` A's Monte Carlo values. $p_\Delta$ has the closed form $\Ex|e|/\Delta$.
* **Thm 3.8 and Cor 3.9.** Independent simulation with 2000 runs and a different seed (`rb3` B):

  | quantity | $\lambda=1$ | $\lambda=2$ |
  |---|---|---|
  | P→H mean | 612 ± 34 (Wald [494, 1248]) | 214 ± 6 (Wald [146, 338]) |
  | H→N mean | 7017.9 ± 10.0 (Wald [6994.9, 7024.9]) | 14009 ± 14 (Wald [13990, 14020]) |
  | first refutation | 92.0 ± 2.1 (1/p = 94.25) | 94.2 ± 2.1 (1/p = 94.25) |

  The ties are as recorded within noise (sign changes 11.3/135.6 against 14.9/148; the share still changing after $10^5$ is 0.52 against 0.43; the arcsine law gives ½).
* **§3.6, code Q** (`rb3` A, exact rates from the residuals):
  * "17 of the 39 pairs not even at 30°" is reproduced exactly;
  * the takeover widths match the record to its grid: $\lambda=2$ from 8.1′ (Jupiter 30 y) to 962′ (Moon 18.6 y), median 134′; $\lambda=4$ from 0.72′ (Venus 12 y), median 13.4′;
  * in the fine regime H's code-Q cost is exactly $\gamma$, the empty law's.
* **Prop 4.1(b),(c)** in exact rationals; **Prop 4.3(c)**: all 12628 families of 2–4 integer intervals, 20000 box families, the disc counterexample; **Remark 4.4**: $7.9589\varepsilon$, $25.225\varepsilon$, $4.611\varepsilon$, $1.378\times10^5$ and $2.40\times10^4$ (`rb5`).
* **Prop 5.5** (closed form), **Prop 5.6** (7170/7170, including collinear points, duplicate points, interval ends at hull slopes and $\sigma=\infty$), and N2's hull vertex "law + 8 planets" with slopes 135.3667 in and 7.0267 out (`rb4` A–C).
* **Prop 5.8.** The identity $U=I(D_1;D_2\mid h)-I(D_1;D_2)$ holds to $9\times10^{-16}$ on 2000 random tables. $U=6,0,3$ in the three parameter cases (`rb4` D).
* **Prop 7.1(a)–(c),(e)** (`rb6`):
  * $\varepsilon_{\min}(W)$ = 0.01, 0.09998, 0.9612, 1.691 (JR); 0.01, 0.01271, 0.01859, 0.02431 (SR); 0.01, 0.1027, 1.332, 3.495 (I);
  * the bound holds at every $W\le200$;
  * $Aa\ne Ra$;
  * numeral bits 1894 and 180321 (JR), 1430 (SR), 1322 (I), identical to `l9`.
* **§1 on propositional fragments** (`rb8`):
  * Def 1.1's "proves iff $A_T(\mathcal Q)=\{a\}$": 236267 cases;
  * Prop 1.10(ii)'s semimeasure inequality: 4000 cases, exact;
  * Prop 1.11(a)'s $w_T$ sums to at most 1, and $-\log P'_T\le n+\mathrm{Exc}^Q$;
  * Prop 2.1: 2986 cases;
  * the machine $G_T$ of Prop 1.8(a), simulated to 40 bits: the frequency of "proves every datum" is within 1.0 s.e. of $P^R_T$ in 12 cases;
  * $P^R_T$ is a measure over a further question at an already-asked time (2000/2000, exact).
* **Proofs read and found correct** without code: Prop 1.4, Prop 1.9(c) (the theorem on constants), Prop 1.9(d) (the length bound, even with $\kappa_0=0$), Prop 1.11, Prop 5.3(b), Prop 6.1(a).

## Re-runs of the developer's scripts

Each script was run on a scratch copy (scratchpad `refB_laws_rerun/`) and its output compared with `diff`, ignoring the runtime line.
* `l2` (21 s), `l3` (15 s), `l5` (332 s, on a copy of the saved `l4_residuals.npz`), `l6` (4 s), `l7` (1 s), `l8` (<1 s), `l9` (4 s): identical.
* `l4` was re-run with pyerfa 2.0.1.5 from the scratch library, in 1403 s. Its output is identical, and all 117 arrays of the re-run `l4_residuals.npz` are bitwise equal to the saved ones.

---

## Verification log

1. **Restart check.** At the start, my folder held no `referee-B.md` and no rb scripts; `referee_code/` held only Referee A's `ra1_checks.*`. A skeleton of this report was saved first, the issue list after the first scripts finished, and this final version last.
2. **Reading.**
   * The project brief and the thread brief, in full.
   * `notes.md`, in full.
   * The developer scripts `l3`, `l5`, `l7` and `l8`, in full; `l2`, `l4`, `l6` and `l9` through their docstrings and outputs.
   * Referee A's report, after my code was run, to cross-reference overlapping issues (noted at each issue).
3. **Independent code.** All in `referee_code/`, written from the record's statements, not from the developer's code.

   | script | runtime | seed |
   |---|---|---|
   | `rb1_dither_exact.py` | 4 s | 20261016 |
   | `rb2_sai_pricing.py` | 12 s | 20261016 |
   | `rb3_selection.py` | 29 s | 20261017 (a different seed on purpose) |
   | `rb4_best_system.py` | 12 s | 20261016 |
   | `rb5_horizons.py` | 9 s | 20261016 |
   | `rb6_correction.py` | <1 s | deterministic |
   | `rb7_domains.py` | 14 s | deterministic |
   | `rb8_logic_finite.py` | 11 s | 20261016 |

   Each writes `<name>.out` next to itself. `rb2`, `rb3` and `rb7` read `../checks/l4_residuals.npz` (read only, `allow_pickle=False`). Python 3.11.15, numpy 2.4.6. **Determinism:** all eight were re-run on a scratch copy, and the outputs were identical apart from the runtime line.
4. **Defects found and fixed in my own code during the work.**
   * `rb2`'s first version averaged the coarse regime over 64 dither strata, which misses the rare straddles at large $\Delta$; it now uses the exact coarse formula.
   * `rb5` B first tested the contraction limit $\delta\ge\varepsilon/(1-L)$ in floating point and misfired at equality ($L=0.9$, $\delta/\varepsilon=10$); the test is now in exact rationals.
   * `rb3` B's first run (600 runs) had one first-refutation mean 3 s.e. below $1/p$. A separate check with 20000 runs gave 93.97 ± 0.66 against 94.25, and the script now uses 2000 runs.
5. **Own proofs in this report.**
   * (F1): Gibbs' inequality per boundary position.
   * (F2): the convexity of $c(s)$ (an expectation of $-\log$ of functions affine in $s$), the derivative at $s=0$ (a three-range integral, written out in issue 1) and Jensen's inequality.
   * Both are checked numerically: the criterion agrees in 39/39 pairs and in the synthetic cases, including the boundary case of uniform $|e|$.
6. **Not done.**
   * The literature was not re-verified; that is Referee A's remit, and the record's §12 states its levels.
   * The `l5` tolerance-family tables (section C) were not recomputed beyond spot reading.
   * T8 was not tested (open in the record).
   * The fine-regime bound $\log e$ of issue 7 is computed on a grid, not proved here.
