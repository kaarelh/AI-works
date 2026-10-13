# Referee report B (computation and counterexamples) on sub-track "teacher"

*Track "split", target T3. Report on `notes.md` and `checks/` of 2026-10-13. Written 2026-10-13.*

* **Read.**
  * The brief `../00-brief.md`, in full.
  * `notes.md`, in full.
  * The four scripts in `checks/` and `tcommon.py`, line by line.
  * Paper 2: `setup.tex`, `app-setup.tex`, `teacher.tex`, `app-teacher.tex`, `limits.tex`, `app-limits.tex`, `split.tex`, and §8 of `algstat.tex`.
  * `../kink/notes.md` §3 and §5, for the comparisons in Remark 1.3 and Prop 2.4.
  * `referee-A.md`. I read it only after my scripts rB0–rB6 had run. §5 below says where my computations bear on A's issues.
* **My code.** It is in `referee_code/`. I wrote it independently and import nothing from `checks/`, except rB0, which re-runs the prover's own t2 and t3 with one function replaced. The scripts are seeded or deterministic, and each output is saved next to its script.

| script | what it does |
|---|---|
| `rBcommon.py` | exact log-binomials and ceilings; Elias-delta integer code; rate code; exact Bernoulli fits; λ-sets by an O(\|G\|·\|P\|) secant test (no hull routine) |
| `rB0_rerun_exactceil.py` | re-runs t2 and t3 with exact ceilings of $\log_2\binom{n}{k}$ and diffs the outputs |
| `rB1_kink_lemma.py` | Lemma 1.1 (all parts), Remark 1.2 and its converse, Remark 1.3; necessity and tightness examples |
| `rB2_constants.py` | the example's constants, Prop 3.1's table, Prop 2.4's offsets, the ceiling bug, Prop 2.1(b) from (D2) |
| `rB3_fulltable_class.py` | a different explicit product class K on full tables: reuse factor, the noisy parity with $m=d$, envelopes, rate blindness, an exhaustive check |
| `rB4_sampled.py` | sampled data in K, reported per sample |
| `rB5_iid_repeats.py` | i.i.d. inputs with repeats and per-query fits, under fixed λ, $\sqrt n$ and $cn$; teacher errors, fresh noise and frozen noise |
| `rB6_coding_lemmas.py` | the sampled coding lemma (AM–GM) and `lem:teacher:coding` on random semimeasures |
| `rB7_junta_window.py` | §5: ψ₂ in closed form; the constants and $a^*$; $\Phi_2^\sharp$ with **exact integer** information $I$ (no I-grid) |
| `rB8_sharper_identification.py` | two sharper forms of `thm:teacher:main`(ii)(a) and (e) |

---

## 1. Verdict

**Sound. Accept after one major and eleven minor revisions. No fatal issue.**

* **What survives independent computation.**
  * Every proved statement I could test numerically held.
    * Lemma 1.1: 335,162 near-optimal checks, exact arithmetic, including the general form of (i) at 250,842 slopes with $m_N(c)<0$.
    * Prop 2.1's identities, recomputed from (D2) itself: 3.4·10⁻¹³.
    * Prop 2.4's offset identity.
    * The coding lemmas.
    * The §5 constants, by a closed form.
  * The paper's identification row is reproduced exactly: 0.9831, $d+20.43$, 37.72, 0.1991.
  * The reuse-factor picture of §3 reproduces in a second explicit class with a different code (class K, rB3).
    * The good model's lower end is $2^{d-m}\times(0.93$–$0.99)$ for every $m\ge6$.
    * The noisy parity with $m=d$ starts at λ = 1.00–1.07.
    * Envelopes raise the lower end: 14.9 → 42.7 → 79.8 → empty.
    * Rate blindness closes the window, at $d=12$ in K against $d=13$ in t3.
  * The i.i.d. simulation (rB5) confirms Prop 3.2(c)–(d): fixed λ and $\sqrt n$ end at the memoriser, while λ = cn keeps the model.
  * The switch points match the reuse factor quantitatively: the memoriser wins once the multiplicity of the reused unit, times θ ≈ 0.98, exceeds λ.
* **The one major issue (B-M1).** It concerns the explanatory claim at the centre of T3, "fixed λ for noise, λ ∝ n for errors".
  * The noise column holds only for labels redrawn at every query.
  * In Paper 2's own data model, noise is drawn once per distinct input. I simulated it: once inputs repeat, every fixed λ and every $\sqrt n$ schedule ends at the memoriser of the noise, exactly as for errors (rB5(Z)).
  * Referee A raised the same point as M4 from the definitions. I add the simulation and a reformulation that keeps the notes' main idea and makes it exact.
* **Minor issues.**
  * The t4(C) "convergence" is a grid artefact. With exact integer $I$ the bound does reach $\psi_2$ (B-m1).
  * A one-line sharpening of (ii)(a) and (e) is available (B-m2). It raises $u\ge0.75$ to $u\ge0.83$ in the notes' new $p=1/16$ row.
  * A floating-point ceiling bug in `tcommon.py` (B-m3).
  * Several reporting errors (B-m4 to B-m7).
  * Smaller points (B-m8 to B-m11).

---

## 2. What I checked and found correct

1. **Lemma 1.1, Remarks 1.2–1.3** [computed: rB1; exact rationals; seed 20261013].
   * *Lemma 1.1.*
     * 37,759 random point sets, with many ties. In half of them the M-points were pushed onto the (R) line, to exercise the boundary.
     * (i) in its general form, $\inf J'_c\ge c\ell_0+F_0+\min\{m_N,-\Delta\}$, at 302,072 values of $c$, of which 250,842 have $m_N(c)<0$.
     * (ii) on 335,162 near-optimal points.
     * The inclusion $\{J_c\le\Phi+\epsilon\}\subseteq\{J'_c\le c\ell_0+F_0+\epsilon\}$.
     * (iii), concavity of $m_N$.
   * *Remark 1.2.* 20,000 wedges at 820,000 slopes; the converse on 7,791 sets.
   * *Remark 1.3's window variant.* 658,478 near-optimal points.
   * *Necessity.*
     * The lemma fails for $c\le\tau$ and for $\epsilon\ge m_N(c)$.
     * The length bound is attained: a point on the (R) line at $\ell_0+g/(c-\tau)$ ties with the reference.
2. **Prop 2.1(b)–(c)** [computed: rB2(E)]. $g$ was recomputed from (D2) at $\ell_0$, not from the shared Λ₂ formula. Over 4 instances, κ ∈ {0, 30} and δ_S ∈ {0, 20}, and 39 values of $c$ each, $g\cdot2^m=\Lambda_2$ and Lemma 1.1's length bound equals the paper's $\Delta_\ell$ at ε = 0.01, to $3.4\cdot10^{-13}$.
3. **The running example** [computed: rB2(A); $L_S$ from the exact integer $\binom{2^{20}}{1024}$].
   * $L_S=11{,}710.273$, $2^mH(p)-L_S=6.3252$, $\Lambda_2=52.188$.
   * $c_{\rm hi}=8.0618\cdot10^{-3}$ (κ = 0) and $3.6590\cdot10^{-3}$ (κ = 30), in closed form and by bisection.
   * At $c=10^{-4}$, all four rows of `tab:teacher:numbers` are reproduced to the last digit; for example (0, 0): $u\ge0.9831$, $\ell\le d+20.43$, $I\le37.72$, $e\le0.1991$.
   * The notes' t4 row at $c=1.226\cdot10^{-4}$ is reproduced: 0.9812, $d+20.34$, 37.63, 0.2010.
4. **Prop 3.1's table** [computed: rB2(B)]. Every row of the notes' table agrees: θ_m, $2^{d-m}\theta_m$, $Nc_{\rm hi}$, Λ₂, for $d=20,100$ and κ = 0, 30. One exception: $L_S$ at $d=20$, $m=12$ (B-m5).
5. **Prop 2.4** [computed: rB2(C)]. $\Lambda_2-b_0'=12.5031=4+4\log d-2\log(d+1)$ at $d=20$, for κ = 0 and 30. The length bounds at λ = 2 are $d+58.19$ (paper) and $d+45.69$ (sufficiency line).
6. **Prop 3.1 in a different code** [computed: rB3(A); class K, seed 4242].
   * The class has an Elias-delta integer code, a different rate code and exact ceilings. Its families: coin, parity + rate, parity + rule, subcube envelopes, named inputs, lookup table and partial parities.
   * For $d=10$ and $d=12$, $p=1/16$ and every $m$ from $d$ down to 6, the good model's lower end equals the rule memoriser's secant, $2^{d-m}\times\theta_K$:

     | $d$ | θ_K at $m=d,d-1,\dots,6$ |
     |---|---|
     | 10 | 0.978, 0.965, 0.928, 0.939, 0.981 |
     | 12 | 0.992, 0.987, 0.978, 0.965, 0.928, 0.939, 0.981 |

   * So "the lower end is the reuse factor times a code-dependent θ ≤ 1" holds in a second code.
   * At $m=5$ the secant ratio is **1.079 > 1**. See §5 (M3).
7. **The noisy parity, $m=d$** [computed: rB3(B)]. For $d=8,10,12$ and $p=1/32,1/16$, the good model's λ-set starts at 1.070, 1.016, 1.012, 1.001, 1.000 and 0.998.
   * Just below the lower end the MAP is the all-errors fill-in (family E).
   * This is Prop 2.4(iii): both windows start at λ = 1. It holds for $p=1/16$ too, where $G_1<H(p)$, because K contains none of the dangerous level-≥2 competitors.
8. **Envelopes and rate blindness** [computed: rB3(C), (D)]. Both are qualitatively as in t3.
   * The cheap parts of 0, 2, 4, 8 and 16 cells move the lower end to 14.86, 14.86, 42.67 and 79.78, and then to empty.
     * K has no "envelope + named cells" family, so the 2-cell case does not move.
     * At 4 and 8 cells the envelope vertex sits just below the good model, as in t3.
   * A fixed 4-cell rule at $m=5$ closes the window at $d=12$ (t3: $d=13$).
9. **Exhaustive check of the restricted class** [computed: rB3(E)]. At $d=8$, $m=4$, with every parity and every one of the $2^{16}$ rules in family C, the whole MAP path for λ > 0 equals that of the restricted class in all 6 instances.
   * At λ = 0 the exhaustive class has extra tied zero-fit programs. A parity $a'$ that differs from $a$ only on cell coordinates, plus a rule $T$, is the same hypothesis as $(a,T\triangle L)$.
   * This check is weak: at these sizes the MAP path has 2–3 points.
10. **Prop 3.2 by simulation** [computed: rB5; seed 5150; 24 runs per source; $d=10$; inputs i.i.d. uniform with repeats; per-query fits]. Teacher with junta errors, $m=6$, $p=1/16$. The tables list the fraction of runs whose λ-MAP is the good model.

    | $n$ | λ = 2 | λ = 8 | $\sqrt n$ | $cn$ |
    |---|---|---|---|---|
    | 64 | 0.92 | 0 | 0 | 0.79 |
    | 256 | 0 (memoriser) | 1.00 | 0 | 1.00 |
    | 1024 | 0 | 0 | 1.00 | 1.00 |
    | 4096 | 0 | 0 | 0.79 | 1.00 |
    | ≥ 16384 | 0 | 0 | 0 | 1.00 |

    * The 0 entries under λ = 8 and $\sqrt n$ at $n\le256$ are left-side failures: λ is above the model's left steepness.
    * Every other non-good fraction is the memoriser.
    * $c$ is taken inside the population c-interval of K, $(0.0153,0.0421)$, which contains $2^{-m}=0.0156$.
    * *Switch points.* The memoriser wins once $\theta\cdot n2^{-m}>\lambda$, that is, once the error cells' multiplicity $n/64$ times θ ≈ 0.98 exceeds λ:
      * λ = 2 switches between $n=64$ and 256;
      * λ = 8 between 256 and 1024;
      * $\sqrt n$ between 4096 and 16384, where $n/64$ overtakes $\sqrt n$ at $n=4096$.
11. **The coding lemmas** [computed: rB6].
    * *The sampled coding lemma of Prop 3.3(b).* On 3,000 random semimeasure hypotheses with zeros and random samples:
      * $\max(q_z(0)+q_z(1)-1)=0$; equality is attained by measures constant on a cell;
      * the total mass of $Q$ is at most 1;
      * the identity $-\log Q_z=F_z/n_z$ holds to $1.5\cdot10^{-16}$;
      * 25,000 cells with infinite fit are matched.
    * *`lem:teacher:coding`.* On 2,000 instances with $B\in\{\infty,r,r+1,r+3\}$, the identity holds to $6.3\cdot10^{-15}$, and per-factor normalisation gives mass at most 1. A single global division by $1+\tau_B$ gives total mass up to $2^{43}$, which confirms the paper's remark.
12. **§5 constants** [computed: rB7(A); closed form].
    * With $y=\sqrt x$, $\psi_2$'s objective is $apy^2-\log(A+ky)$. It is convex, and its minimiser solves $2ap\ln2\cdot y(A+ky)=k$.
    * The roots are $G_1=H$ at 0.05596, $\psi_2(p,1)=H$ at 0.07787 and $1-\log(3/2-p)=H$ at 0.12331. Each crossing is the only sign change on a 4,999-point grid of $(0,1/4)$.
    * $a^*(p)$ is 1.011, 2.128, 3.034, 5.999, 15.585 and 30.200 at 5/64, 3/32, 0.1, 7/64, 15/128 and 0.12, as in the notes.
    * $\psi_2$ is nondecreasing in $a$.
13. **Re-runs.**
    * All four prover scripts, re-run in a scratch copy, reproduce their `.out` files byte for byte.
    * rB0 re-imports t2 and t3 read-only, without writing bytecode into `checks/`. Its unpatched re-runs are identical too.

---

## 3. Major issue

### B-M1. "Fixed λ suffices for noise, errors need λ ∝ n" is true for noise redrawn at every query, false for Paper 2's frozen noise once inputs repeat. The reuse factor explains both, and the notes should say so.

*Where.*
* §0 item 4.
* §3's title and §3.1 ("Noise drawn fresh at each input is used once").
* Prop 3.2(b) and the Reading after it.
* Remarks 3.4 and 3.5.

*Problem.*
* **Paper 2's data model.** Paper 2 fixes one label per distinct input: "all noisy data in this paper draw each label once per distinct input (frozen noise)" (`setup.tex`).
* **Prop 3.2's data model.** Prop 3.2 and iid Thm 3.1, which the Reading cites, assume pairs i.i.d. from $\mu\otimes P^*$ with per-query likelihoods. The label is redrawn at every repeat.
* **On a finite domain, frozen noise is an error rule with $m=d$.** Its reuse factor is the multiplicity of the inputs, and that grows like $n/N$. So by the notes' own §3 mechanism, every λ_n = o(n) must eventually memorise it.

*Evidence* [computed: rB5; $d=10$, $p=1/16$, 24 runs; fraction of runs whose λ-MAP is the sampler, "good"].

| source | λ = 2 | λ = 8 | $\sqrt n$ | $cn$ |
|---|---|---|---|---|
| (R) noise redrawn per query | 1.00 at every $n\ge64$ | 1.00 from $n=256$ | 1.00 from $n=1024$ | 1.00 from $n=256$ |
| (Z) frozen noise, same sampler | 1.00 up to $n=256$, 0.96 at 1024, **0 (memoriser) from 4096** | 1.00 up to 4096, **0 from 16384** | 1.00 up to $2^{18}$, **0 from $2^{20}$** | 1.00 from $n=256$ |

* For frozen noise the switch points are those of the teacher's errors with the cell multiplicity replaced by the input multiplicity $n/N$: θ·n/N > λ.
  * For λ = 2, $n/N\approx2$; observed between $n/N=1$ and 4.
  * For λ = 8, $n/N\approx8$; observed between 4 and 16.
  * For $\sqrt n$, $n\approx(N/\theta)^2\approx1.1\cdot10^6$; observed between $2^{18}$ and $2^{20}$.
* The population c-interval of the sampler under frozen noise has lower end 0.000978–0.000988. This is about $2^{-d}=0.000977$, the reuse factor per sample for $m=d$, and not 0 as for redrawn noise.
* So the dichotomy is not noise against errors. It is labels redrawn at every use against labels reused.

*Fix.* The notes already contain the right concept; state it as the thesis.
1. Retitle §3: "Fixed λ works while the reuse factor stays bounded; λ must grow like the reuse factor."
2. Say in Prop 3.2(b) and in the Reading that the noise there is redrawn per query. Add one sentence: "For frozen labels, noise included, the least-risk vertex is the memoriser, and Prop 3.2(a) applies with $y^*$ the frozen table."
3. Add a "frozen noise" column to Remark 3.4.
   * Right flatness: 1 on distinct inputs. Once inputs repeat, about $\theta\cdot n/N$: the multiplicity of the repeated unit.
   * Schedules: $\lambda_n>\theta\cdot n/N$, hence ∝ n.
   * This column coincides with the $m=d$ column. The junta column is the same with "input" replaced by "cell" and $N$ by $2^m$.
4. In the answer to the brief's question "why do the teacher's errors, unlike i.i.d. noise, require λ ∝ n", give the one-line answer this yields:
   * the errors are a fixed function of the input, so each of their bits is reused at every repeat of its cell;
   * i.i.d. noise is reused only if it is frozen and its input repeats.
5. Cite rB5 or reproduce its table. It is a three-line simulation in an exactly enumerable class.

Referee A's M4 makes the same point from the definitions. B-M1 adds the computation, the quantitative switch points, and the reformulation in items 1–4.

---

## 4. Minor issues

### B-m1. The t4(C) "convergence to ψ₂" is a grid artefact; with exact integer $I$ the bound does converge (§5, line 525).

* *What t4(C) shows.* The values plateau: 0.3965, 0.3966 and 0.3966 at $m=20$, 28 and 40, against ψ₂ = 0.3980 ($p=1/16$, $a=1$). The 0.0014 gap is the loss of the geometric I-grid of ratio 1.02. Each cell lower-bounds $cI+{\rm Floor}(I)$ by $cI_k+{\rm Floor}(I_{k+1})$, which costs about 1% of the deviation term $2p\gamma\approx0.07$, that is ≈ 0.0014 in $\log_2$.
* *The exact computation.* $I(\pi)=B_S-K(S\mid a,\pi)$ is an **integer**. So $\Psi_t(c)=\min_{I\in\mathbb Z_{\ge0}}[cI+{\rm Floor}_t(I)]$ is exact over $0\le I\le1/c$, beyond which the charge exceeds every Floor ≤ 1. rB7 evaluates it through the lower convex hull of the integer points.

  [computed: rB7(C)]

  | $(p,a)$ | exact $\Psi_2$ at $m=12$, 16, 20, 22 | ψ₂ |
  |---|---|---|
  | (1/16, 1) | 0.3837, 0.3968, 0.3979, 0.3980 | 0.3980 |
  | (1/16, 4) | 0.4117, 0.4510, 0.4549, 0.4552 | 0.4552 |
  | (1/16, 16) | 0.4117, 0.4581, 0.4698, 0.4707 | 0.4710 |

  The remaining rows of rB7(C) are in its output.
* *Fix.*
  * Replace the I-grid in t4 by the integer computation. It is rigorous and needs no Floor-monotonicity argument.
  * Or keep the grid and say that the plateau is its discretisation loss.
  * In either case reword line 525.
* *What it changes.* The certified windows of t4(B) are slightly conservative at both ends.
  * The exact windows are in rB7(B), quoted under B-m10.
  * A notes the upper-end effect of the c-grid (A m10). The I-grid adds a second, smaller loss.

### B-m2. `thm:teacher:main`(ii)(a), and with it (e), can be sharpened in one line; the notes' new rows benefit most.

* *The two sharper bounds.*
  * **(a1).** A near-optimal π has level 1, so (D1) gives $\ell(\pi)\ge d-4-\Lambda_1$. Hence $R_B(\pi)\le R_{\max}:=J_g(c)+\epsilon-c(d-4-\Lambda_1)=c(\kappa_g+4+\Lambda_1)+H(p)+\epsilon$. The floor then gives $u\ge2^{-R_{\max}}-p-2^{-B}$. The paper uses $R_B\le J_g+\epsilon$ and so wastes $c\,d$ in the exponent.
  * **(a2).** `lem:teacher:sharpfloor` with $I(\pi)\le\Delta_\ell+\Lambda_3$, from (ii)(d), gives $u\ge(2^{-R_{\max}}-p(1+2\gamma_g+2^{1-g})-2^{-B})/(1-2p)$, with $\gamma_g$ exactly as in (ii)(e).
* Both are [proved] by the displayed one-liners. (e) improves through $u$.
* *Numbers* [computed: rB8].

  | instance | $u\ge$: paper / (a1) / (a2) | $e\le$: paper / (a1) / (a2) |
  |---|---|---|
  | example, $c=10^{-4}$, κ = 0, δ_S = 0 | 0.9831 / 0.9882 / 0.9897 | 0.1991 / 0.1940 / 0.1925 |
  | example, $c=4\cdot10^{-3}$, near the top of the window | 0.75 / 0.873 / 0.874 | 0.432 / 0.309 / 0.308 |
  | t4(B) row $p=1/16$ ($c=6.7\cdot10^{-5}$) | 0.75 / 0.75 / **0.828** | 0.274 / 0.274 / **0.197** |
  | t4(B) row $p=5/64$ | 0.75 / 0.75 / 0.803 | 0.273 / 0.273 / 0.220 |
  | t4(B) row $p=3/32$ | 0.75 / 0.75 / 0.780 | 0.271 / 0.271 / 0.240 |

* *Fix.*
  * Add (a1)–(a2) as a remark after Prop 5.2.
  * Update the identification column of the t4(B) table and §5's sentence "e ≤ 0.27–0.28".
  * Optionally pass (a1) to the paper. It is free, and it matters most near $c_{\rm hi}$, where the paper's (a) gives only 3/4.

### B-m3. `tcommon.log2binom` takes the ceiling of an lgamma value and is one bit too high when the binomial is a power of 2.

* `math.ceil` of the lgamma value gives $m+1$ for $\log_2\binom{2^m}{1}=m$ and $\log_2\binom{2^m}{2^m-1}=m$ at $m=4,6,7,8,10,11,13$, and for $\binom{1024}{1}$ [computed: rB2(D): 13 mismatches among 14,342 pairs].
* So the single-cell rule and the single named input are charged one bit too many.
* Re-running t2 and t3 with exact ceilings changes only two vertex lines of t2(A) at $m=4$: the coin's lower end 51.2 → 53.89, and F5's length 27 → 26 [computed: rB0]. No quoted number changes.
* *Fix.*
  * Use `(math.comb(n, k) - 1).bit_length()`.
  * Say in the verification log that this was checked.

### B-m4. "For m = 4 the rule is one cell, cheaper than the model's own rate code" (line 308) is false.

* In t2's code, the one-cell rule memoriser is **4 bits longer** than the good model's rate code, and 5 bits with the bug of B-m3. The extra cost is $g(4)+g(1)+4+RC(0)=13$ bits against $RC(1/16)=9$. In class K it is 5 bits longer.
* The good model fails to be a vertex for another reason. The rule's secant from it, 345.39/4 = 86.4 bits per bit, exceeds the model's own secant from the coin, (1024 − 345.39)/15 = 45.2 [computed: rB3(F)].
* *Fix.* "For $m=4$ the one-cell rule saves 345 bits for 4 bits of length, a rate of 86 per bit, above the model's own rate of 45. So the good model is not a vertex." This is rate blindness, as the notes say.

### B-m5. Numbers that do not match.

1. **$L_S$ at $d=20$, $m=12$** is $\log_2\binom{4096}{4}=43.41$ bits, not 41 (line 304) [rB2(B)]. θ_m = 0.5473 is right. A's m10 also has this.
2. **"The kink sub-track's $b_0$ is the same offset"** (line 256). Kink's $b_0$ has $2\log d$; Prop 2.4's $b_0'$ has $2\log(d+1)$. Hence $d+45.55$ (kink's "45.5") against $d+45.69$ from $b_0'$ [rB2(C)]. Say "the same up to $2\log((d+1)/d)$", or align the definitions.

### B-m6. Per-sample reporting of t2(B), replicated in class K [computed: rB4; 40 samples per $n$; fresh $(a,S)$].

| $n$ | fraction with the good model as 2-MAP | fraction at λ = 4n2^{-m} | fraction at λ = 16n2^{-m} | median $\tau_n$ | median $\tau_n/(n2^{-m})$ | median σ_n |
|---|---|---|---|---|---|---|
| 32 | 0.23 | 0.25 | 0.23 | 0.56 | 4.49 | 1.17 |
| 64 | 0.53 | **0.97** | 0 | 0.71 | 2.85 | 2.13 |
| 128 | 1.00 | 1.00 | 0 | 0.86 | 1.72 | 4.26 |
| 256 | 1.00 | 1.00 | 0 | 1.25 | 1.25 | 8.22 |
| 512 | 0.23 | 1.00 | 0 | 2.15 | 1.08 | 16.9 |
| 1024 | 0 | 1.00 | 0 | 3.76 | 0.94 | 34.1 |
| 4096 | 0 | 1.00 | 0 | 14.8 | 0.93 | 136 |
| 16384 | 0 | 1.00 | 0 | 59.4 | 0.93 | 545 |

* **"λ = 2 keeps the good model in every sample up to $n=2^m$"** (line 371) fails at $n\le64$ in both classes: 0.10 and 0.70 in t2, 0.23 and 0.53 in K. These failures are on the left, where λ is above $\sigma_n$; A's m11 says the same.
* **"λ = 4n2^{-m} keeps it at every $n\ge64$"** (line 372). It does so in 39 of 40 samples at $n=64$ in K, and in all samples for $n\ge128$. The notes' evidence is a mode. State the per-sample fraction.
* **The c-window at these sizes is narrow.** $\sigma_n/n\approx8.5\cdot2^{-m}$, so λ = 16n2^{-m} never selects the model for $n\ge64$. The c-window in K is about $(0.93,8.5)\cdot2^{-m}$, a factor of 9. §0's "$(n2^{-m},nc_{\rm hi})$" should carry this caveat for the explicit illustrations.
* **What the lower end tracks.** It is the mean multiplicity of the sampled error cells, not the largest.
  * $\tau_n$ divided by the mean multiplicity is 0.83–0.93 for $n\ge256$.
  * The largest multiplicity is up to about twice the mean: 1.3–2.0 times it for $256\le n\le8192$.
  * In all 40 samples, for every $n\ge128$, the right neighbour is the parity plus rule cells (family C).
  * Nothing at these sizes supports "the effective slope can approach $\max_zn_z$" (Prop 3.3(b)). Mark it [open], or restate it as a conjecture in the mean multiplicity, with rB4 and t2(B) as evidence.

### B-m7. In class K the rate-$p$ good model is selected on a small part of its family's λ-set; this supports A's M1.

* In K, the λ-set of "true parity, any rate" at $d=10$ is $[1.001,43.14]$. The rate-$p$ member is selected only on $[1.001,15.78]$, and rate 1/8 on the rest. At $d=12$ the split is at 63.11 [computed: rB3(A)].
* At $d=10$, $m=5$ (two error cells), the rate-$p$ member is **never** a λ-MAP, while the rate-1/8 member is selected on $[31.4,43.1]$ in 2 of 3 instances.
* So "the good model's λ-interval" in t2, t3, rB3 and rB4 is a family statement, as A says. Report it per rate.

### B-m8. Lemma 1.1's hypothesis $g\ge0$ is automatic when the reference is bounded by a program of M.

* *The argument.* If $b\in M$ has $\ell(b)\le\ell_0$ and $F(b)\le F_0$, then (R) at $b$ gives $g\ge F_0-F'(b)+\tau(\ell_0-\ell(b))\ge0$.
* *The other case.* If every bounding program is in N, then $m_N(c)\le0$ for all $c$, and (ii) is vacuous.
* *Computed* [rB1(A)].
  * Of 2,903 random sets with least admissible $g<0$, none had $m_N(c)>0$ at any tested $c$.
  * The sandwich's lower end fails in 176 cases. All have $m_N(c)=0$ exactly, with the bounding program in N.
* In every application the bounding program is in M: $\pi_g$ is level 1, and $\pi_\nu$ is in M.
* *Fix.* Replace "$g\ge0$" by "the reference is bounded by a program of M", or add the two-line remark. This settles A's m1 inside the lemma.

### B-m9. Remark 3.4 mixes units in its last row.

* "Offset of the right line" gives $k+\delta^*$ and $b_0'$ in total bits, and $\Lambda_2/2^m$ per sample.
* *Fix.* Give the junta entry in total bits on the full table, $2^{d-m}\Lambda_2$ (cf. t1(D)'s "g_total" column), or label the row's units per column.

### B-m10. The certified windows of t4(B) against the exact $\Phi_2^\sharp$.

* *The comparison* [computed: rB7(B)]. The exact window $\{c>2^{-20}:J_g(c)<\Phi_2^\sharp(c)\}$, with integer $I$, a 3,000-point geometric scan, and bisection at the ends, is:

  | $p$ | κ | exact window | t4(B) certified |
  |---|---|---|---|
  | $2^{-10}$ | 0 | $[2^{-20},\ 8.198\cdot10^{-3}]$ | $(2^{-20},\ 7.88\cdot10^{-3}]$ |
  | $2^{-10}$ | 30 | $[2^{-20},\ 3.687\cdot10^{-3}]$ | $(2^{-20},\ 3.59\cdot10^{-3}]$ |
  | 1/16 | 0 | $[2^{-20},\ 2.529\cdot10^{-3}]$ | $(2^{-20},\ 2.39\cdot10^{-3}]$ |
  | 1/16 | 30 | $[2^{-20},\ 6.56\cdot10^{-4}]$ | $(2^{-20},\ 6.5\cdot10^{-4}]$ |
  | 5/64 | 0 | $[1.013\cdot2^{-20},\ 1.521\cdot10^{-3}]$ | $[1.056\cdot2^{-20},\ 1.46\cdot10^{-3}]$ |
  | 3/32 | 0 | $[2.140\cdot2^{-20},\ 9.10\cdot10^{-4}]$ | $[2.20\cdot2^{-20},\ 8.7\cdot10^{-4}]$ |
  | 7/64 | 0 | $[6.22\cdot2^{-20},\ 3.18\cdot10^{-4}]$ | $[6.52\cdot2^{-20},\ 3.0\cdot10^{-4}]$ |
  | 7/64 | 30 | $[6.53\cdot2^{-20},\ 8.56\cdot10^{-5}]$ | $[6.70\cdot2^{-20},\ 8.4\cdot10^{-5}]$ |
  | 15/128 | 0 | $[21.4\cdot2^{-20},\ 6.23\cdot10^{-5}]$ | $[22.7\cdot2^{-20},\ 5.9\cdot10^{-5}]$ |
  | 15/128 | 30 | none | none |
  | 1/8 | 0 and 30 | none | none |

  * Every exact window is a single interval.
  * Every certified window lies inside the exact one.
  * The certified ends are conservative by 1–6% at each end.
  * At $p=2^{-10}$ the exact upper end, $8.198\cdot10^{-3}$, exceeds the paper's $c_{\rm hi}=8.062\cdot10^{-3}$. It equals t1(B)'s "exact steepness of the level regions": at $p=2^{-10}$ the first term of $LB_t$ decides, without the paper's two-endpoint reduction.
  * The κ = 30 rows for 5/64 and 3/32 are in the output.

* *What it confirms.*
  * The certified windows are inside the exact ones, as they should be.
  * The upper ends lie above the paper's $c_{\rm hi}$ wherever the paper has a window.
* *Fix.* Quote the exact ends next to the certified ones, or say that the certified ends are conservative by the c-cell and I-grid losses (A m10; B-m1).

### B-m11. Smaller points.

1. **"Exact hull of the class"** (t2 and t3 docstrings).
   * Families C/F5, D and E use only the true parity. rB3(E) shows that this does not change the MAP path at $d=8$, $m=4$ for λ > 0, but such a check is not in the notes.
   * At λ = 0 the claim is false: a parity that differs on cell coordinates, plus a rule, is an equal-fit duplicate.
   * Say "exact for λ > 0 over the families as restricted".
2. **The status of the t4(A) convexity claim** ("checked on a grid"). It has a two-line proof, and rB7 uses the resulting quadratic for the minimiser. A's m15 says the same.
3. **"Prop 3.3(a): the right flatness is at least about $\max\{1,n2^{-m}\theta_m\}$".** In explicit classes without a covering fill-in, the lower end is below 1 for $n\le128$: 0.56–0.86 in K, 0.64–0.94 in t2. Say that the "1" needs the covering fill-in of the canonical class.

---

## 5. Where my computations bear on referee A's issues

* **A-M1** (the good model is not proved to be a vertex). Confirmed in a second code; see B-m7.
* **A-M2** (sampled windows not proved). My computations agree; see B-m6.
  * In K the lower end on samples is about 0.93·n2^{-m} only for $n\ge1024$.
  * The upper end is about 8.5·n2^{-m}.
  * Neither is a theorem.
* **A-M3** ("right flatness" mixes the line slope with the hull slope). rB3(A) gives a concrete instance where the hull slope exceeds the line slope τ.
  * At $d=10$, $m=5$ in K, the memoriser's secant from the rate-$p$ good model is $1.079\cdot2^{d-m}$, above τ = 2^{d-m}.
  * The rate-$p$ model is beaten up to λ = 34.5 > 32.
  * So "$\theta_m\le1$" and "right flatness ≤ $2^{d-m}$" are false for hull slopes in explicit codes, as A says.
* **A-M4** (frozen noise). B-M1 gives the simulation and the reformulation.
* **A-M5** (the range of Prop 5.3). Not tested beyond the constants, which agree.
* **A-m10 and A-m11** (numbers and reporting). Confirmed: $L_S=43.41$; good@2 fails at small $n$ in a second class.
* **A-m14** (the window need not be an interval). At $d=100$, $m=20$ the exact window is one interval for every $p$ and κ tested (rB7(B)). The remark is still right in general.
* **A-m1** (g ≥ 0). See B-m8.

---

## 6. The brief's checklist, from the computational side

* **Instances of a kink lemma.** Lemma 1.1 is correct and tight. Props 2.1, 2.3 and 2.4 are its instances, and I recomputed the constants independently.
* **Role of λ ∝ n versus fixed λ.** It is correctly explained by the reuse factor. The explanation must be stated for frozen labels too (B-M1). The simulation confirms it quantitatively.
* **The teacher's hypotheses and the kink conditions** (Table 2.2). Not computable. The parts I could test numerically (product form → τ = 2^{-m}; uniform inputs → rates) agree with the simulations.
* **Structured errors and a second kink.** Confirmed in a second code (rB3(C), (D)).
* **Anything else.**
  * §5's constants are confirmed by a closed form.
  * §5's windows are confirmed exactly (rB7(B)).
  * A free sharpening of (ii)(a) and (e) is available (B-m2).

---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and scipy 1.17.1. Every script was run from `referee_code/` with `PYTHONDONTWRITEBYTECODE=1 python3 -B`, and its output saved as the `.out` file of the same name.*

* **Prover's scripts.** t1–t4 were copied to a scratch directory and re-run. Each output is byte-identical to the saved `.out` file. Times: t1 6.2 s, t2 1.3 s, t3 0.2 s, t4 28 s.
* **rB0** [deterministic; prover's seeds; 2.6 s].
  * The unpatched re-runs of t2 and t3 are identical to the saved outputs.
  * With exact ceilings, 4 lines of t2(A) change, at $m=4$; none of t3 changes.
  * No file was written to `checks/`; its listing was checked afterwards.
* **rB1** [seed 20261013; 12 s]. All assertions passed. A first version asserted the sandwich of (i) also for $g<0$ and failed. That is the degenerate case of B-m8, now recorded rather than asserted. Part (D)(3) was corrected to an example where the bound is attained.
* **rB2** [deterministic; under 1 s].
  * The first version computed $\binom{2^m}{s_0}$ exactly also at $m\ge98$ and overflowed. Above $m=26$ it now uses Stirling's series.
  * All quoted numbers are from the final run.
* **rB3** [seed 4242; 27 s].
  * The first version of (E) compared the MAP paths including λ = 0. It reported differences, which are equal-fit zero-risk duplicates; it now compares λ > 0.
  * The first version of (F) used a wrong coin length (5 instead of 7 bits). Corrected; quoted values are from the final run.
* **rB4** [seed 777; 11 s].
* **rB5** [seed 5150; 2 s].
* **rB6** [seed 66; 6 s]. A first run failed on $\log_2 0$ and on an infinite fit in the equal-multiplicity line. Guarded, and the hypothesis made strictly positive there.
* **rB7** [deterministic; about 13 min (16:55–17:08), dominated by the convex hulls of $2^{21}$ integer points per level].
* **rB8** [deterministic; under 1 s].
* **Hand checks.**
  * Lemma 1.1 and Remarks 1.2–1.3.
  * Prop 2.1(b)–(c), the identities.
  * Prop 2.4's offset.
  * Prop 3.1(a)–(b).
  * Prop 3.2(a), (b) and (d).
  * The sampled coding lemma and the chain-rule display. $K(\pi\mid a,\dom D_n)\le K(\pi\mid a)+\kappa$, so no assumption on $\dom D_n$ is needed.
  * Props 4.1 and 4.2.
  * Lemma 5.1.
  * Prop 5.2.
  * Prop 5.3's limit argument.
  * The (a1) and (a2) bounds of B-m2.
* **Not checked.**
  * The sibling results cited as such: iid Thm 3.1 and Lemma 5.2; kink Thm 5.4.
  * Table 2.2's entries, beyond their numerical consequences.
* **Repository.** No git command was run. Files written:
  * this report;
  * in `referee_code/`: `rBcommon.py` and `rB0`–`rB8` with their `.out` files.

  No `__pycache__` was left.
