# Referee B (computation and counterexamples): sub-track "iid", target T1

*2026-10-13.*

**What I read.**
* The brief `../00-brief.md`, in full.
* `notes.md`, all 601 lines.
* Paper 2: `setup.tex`, `split.tex`, `app-split.tex`.
* The refereed record `research/tracks/steeper/notes-final.md`, §3.1–3.4.
* `paper/NOTATION.md`, §1 and §3.1.
* The prover's scripts `checks/i1`–`i6` and their outputs.
* For the cross-track points only: `../kink/notes.md` §5.
* I read `referee-A.md` after my own code was written and run. Where we agree, I say so.

**What I ran.**
* I re-ran all six prover scripts from a scratch copy.
* I wrote nine independent scripts, `referee_code/rB1`–`rB9`. Each is seeded or deterministic, and its output is saved next to it as a `.out` file.
* The scripts use methods that differ from the prover's:
  * closed-form rank laws over GF(2) in place of a truncated Markov chain;
  * brute force over all parities, not the span reduction;
  * exact multinomial enumeration over random classes;
  * hull computations checked against brute-force argmins.

**Status tags.**
* **[computed: rBn]**: output in `referee_code/rBn_*.out`.
* **[proof sketch]**: an argument given here, not yet written out in full.
* **[proved]**: a full argument given here.

**Repository.** I ran no git command. Every file I wrote is under `research/tracks/split/iid/`: this report and `referee_code/rB*`.

---

## Verdict

**No fatal issue.** No formal theorem, lemma or proposition of the notes failed any exact enumeration, simulation or counterexample search I ran.

**The prover's numbers reproduce.** All six scripts give byte-identical outputs on a re-run.

**The issues are in readings, scope and missed strengthenings.**
* **B1.** The notes' λ = 1 "correction" is narrower than what their own argument gives. Step 1 of Thm 3.1, combined with Paper 2's Kakutani step, extends `thm:split:private`(iv) to λ = 1:
  * for every input rule;
  * in the frozen object too.

  So in neither object does a steeper prior change the asymptotic identification guarantee:
  * E* in the per-query i.i.d. object;
  * ν-equivalence on the run in the frozen or adaptive object.

  It changes the uniform and finite-sample guarantees. The restructured Paper 2 must be framed that way.
* **B2.** The reading after Lemma 8.1, the bridge to T2, is false. The right side of the sample's kink has slack ℓ* + δ*, not δ*.
* **B3.** The KL-projection conjecture is refuted only for fixed λ. For growing schedules with $\lambda_n/\sqrt{n\log\log n}\to\infty$ and $\lambda_n=o(n)$ it holds in both of the notes' counterexamples.
* **B4.** Frozen noise breaks exact rate identification in the noisy-parity instance itself. This is new evidence for Referee A's M1.

Eleven minor issues follow. They include one strengthening of Thm 4.1(iv) with a free Chernoff exponent, which is up to 30 times sharper in a computed class.

---

## What I checked and found consistent

* **The prover's scripts** [re-run]. i1–i6 reproduce their saved outputs byte for byte. Run times: 112 s, 61 s, 4 s, 4 s, 5 s and 21 s.
* **Lemma 2.1(c), (d)** [computed: rB1(1)].
  * $\rho_s\le\rho_{1/2}^{2\min(s,1-s)}$ was checked on $5\cdot10^5$ (kernel pair, s) cases. They include sub-probability kernels, zeros and deterministic truths. No violation; away from s = 1/2 the largest difference is $-4.2\cdot10^{-6}$.
  * $\Ex\Lambda_5^s=\rho_s^5$ holds by exact enumeration to $7.8\cdot10^{-16}$.
* **Thm 4.1(iv)** [computed: rB1(2)].
  * Setting: 300 random finite classes with Kraft sum ≤ 1. Each has 7–17 programs: random, sub-probability, deterministic, locally perturbed, exception and coin kernels. Each has an input of μ-mass 0; in most classes some E-programs differ from ν there.
  * Exact multinomial enumeration over 12,600 (class, λ, n) rows, with λ ∈ {1, …, 5} and n ≤ 128.
  * Exact ≤ Rényi sum in every row, and Rényi sum ≤ margin bound in every row with λ > 1.
  * Among the 1,849 rows where the Rényi sum is below 1, the largest ratio exact/Rényi is 0.674.
  * The 282 E-programs that differ from ν on the null input behave as members of E, as Def 1.2 says.
* **Thm 4.1(i)–(iii), pathwise** [computed: rB3(B)].
  * Setting: a 583-program class with near-equivalent, exception, threshold, Bernoulli and all 256 deterministic programs; 2000 runs of 2000 queries; λ ∈ {1.25, 2, 4}.
  * Every bound was checked at every n, with the *current* deficiency $\delta_n=\log(\xi_n/L_n(\nu))$. This is stronger than using the supremum δ*.
  * No violation of the MAP length bound, the posterior length tail (L = 12, 14, 16, 20), or the power and tempered fill-in bounds.
* **Lemma 2.2(a), (c)** [computed: rB3(A), (A′)]. Empirical $\Prob[\delta^*\ge j]$ is below $2^{-j}$ at every j tested (0.5 to 8), in two settings:
  * i.i.d. inputs with repeats;
  * an adaptive rule that queries where the mixture deviates most from ν, with fresh labels at repeats (1000 runs).

  For example, the adaptive frequencies are 0.139, 0.032 and 0.014 at j = 1, 2, 3. The supremum is over n ≤ 2000 (i.i.d.) or n ≤ 1000 (adaptive), so these frequencies are lower estimates of the true tail.
* **Thm 3.2** [computed: rB1(2)].
  * Within E the posterior shares equal the prior shares $w_\lambda$ at every n, to $2.2\cdot10^{-16}$. This is an identity, since $\Lambda_n=1$ on E, and it checks the formula for $w_\lambda$, not a rate.
  * I did not tabulate $\Ex\Pi_\lambda(E\mid h_n)$ separately. The prover's i1(C) shows its convergence to 1.
* **Prop 3.4 and the "population hull" sentence after it** [computed: rB7(A)].
  * Setting: the i1 class (rebuilt), with $\lambda_n=cn$ for c ∈ {0.05, …, 0.4}.
  * At n = 10^5 the cn-MAP equals the population minimiser of $c\ell+R$ in 200 of 200 runs for every c, including c = 0.13 and 0.14 on either side of c* = 0.1348.
  * This supports the sentence that Referee A (m6) asks to prove or downgrade. For finite classes it is a uniform strong law, and I agree it should be marked as a proof sketch until written out.
* **The hull characterisation of λ-MAPs** [computed: rB4(D)].
  * On 200 sampled noisy-parity data sets, I compared the argmin over a fine λ grid, plus every hull breakpoint and points just beside it, with the set of programs on the supporting line of slope −λ of the lower convex hull of $\{(\ell(\pi),-\log L(\pi))\}$.
  * There were 0 mismatches in 24,981 (data set, λ) pairs.
  * The λ-interval on which the truth is the MAP is, for example, (1.09, 2.14) at n = 22 and (0, 7.47) at n = 110. At n = 35 it is empty: the truth is above the hull.
* **Props 5.1(a) and 4.4(b), and Thm 4.1(iv) in the parity classes** [computed: rB2(A), (C)–(E)].
  * The closed-form rank law agrees with brute force over all matrices with n·m ≤ 12, to $2.2\cdot10^{-16}$.
  * A Monte Carlo test that tries all $2^m$ parities, with no span argument, agrees within 2σ at 7 points. So the "padding" and "span" reductions are correct.
  * Prop 5.1(a): $\min_{13\le M<4000}\Prob[\text{a parity is consistent at }n=M-5]=0.9845\ge31/32$.
  * For λ > 1, $\Prob[\text{MAP}\ne\text{coin}]\le2^{k-2-(1-1/\lambda)n}$ holds in every case (k ∈ {8, 12, 20}, four λ, M ≤ 400, n < 300). The ratio reaches 1.000, so this Rényi bound is **attained** in $\mathcal C_{k,M}$.
  * In $\mathcal C_k$ the bound $0.25\cdot2^{k-(1-1/\lambda)n}$ holds for all n ≤ 3000. There it is loose by a factor of at least 125.
* **Cor 6.1(iii), the closed-form gap** [computed: rB6(A)]. It agrees with direct computation to $7\cdot10^{-17}$.
* **Prop 7.3(iii), the threshold λ = 1/H(p)** [computed: rB5(B)].
  * I tested it in an *explicit* prefix-free memoriser class, with no machine constant set to 0. The class has distinct inputs, the coin, and the programs "f xor $1_S$" of length $10+c(m)+c(k)+\lceil\log\binom mk\rceil$.
  * For p = 0.1 at λH = 0.97 the MAP is a memoriser for all n ≥ 1566. At λH = 1.03 it is the coin at every n ≤ 10^6.
  * For p = 0.25 the corresponding numbers are 5019 and all n.
  * This confirms the prover's κ = 0 illustration i3(B) rigorously, in a concrete class.

---

## Major issues

### B1. At λ = 1 the MAP is also eventually ν-equivalent on the run, for every input rule and in the frozen object. The λ = 1 vs λ > 1 contrast is quantitative in both objects.

**Where.**
* §0 item 2, "correction to the brief".
* Prop 5.3(a) and its status row.
* Prop 7.6(a) ("for every fixed λ > 1").
* The §5 table.
* Indirectly Paper 2: `thm:split:private`(iv) is stated for λ > 1, and the opening of `sec:split` says that at λ = 1 SFI "has no preference".

**Problem.**
* The notes refute "λ = 1 never makes the split exact" only for the per-query i.i.d. object (Thm 3.1).
* Referee A (m6) observes that in the frozen object the brief's sentence is true, since no procedure is exact (Prop 7.5).
* Neither the notes nor Referee A's m6 says that the notes' own Step 1 gives the frozen and adaptive analogue at λ = 1. That analogue is identification on the run, which is all that λ > 1 gives there.

**Claim (λ ≥ 1 on the run)** [proof sketch].
* *Setting.* Let $\mathcal C$ be countable with Kraft sum ≤ 1, containing a program $\pi_\nu$ of length k whose kernel equals ν at every input. Inputs are chosen by any rule before their labels: adaptive, randomised, or i.i.d. Labels are fresh per query, or frozen on distinct inputs. Fix λ ≥ 1.
* *Conclusion.* Almost surely:
  * (a) the λ-MAPs have bounded length, uniformly in n;
  * (b) from some n on, every λ-MAP is ν-equivalent on the run;
  * (c) $\Pi_\lambda(\text{not equivalent on the run}\mid\cdot)\to0$.

*Proof sketch.*
* (a)
  * A MAP with $\ell(\hat\pi)>L\ge k$ has $\log\Lambda_n(\hat\pi)\ge\lambda(\ell(\hat\pi)-k)\ge\ell(\hat\pi)-k$, so $Z^L_n\ge2^{-k}$.
  * $Z^L$ is a nonnegative supermartingale started at $t_L$ under any such input rule (Lemma 2.2(b), (c); Paper 2's proof of `lem:split:ville`).
  * So $\Prob[\exists n:Z^L_n\ge2^{-k}]\le2^kt_L\to0$, and the events decrease in L. This is the notes' Step 1 with k in place of ℓ*.
* (b)
  * By (a), the MAPs lie in a finite random set.
  * For each π that is not equivalent on the run, $\Lambda_n(\pi)\to0$ a.s. This is Paper 2's Kakutani step in `app:split:private`(iv), which is valid for adaptive inputs.
  * Hence $\log\Lambda_n(\pi)<\lambda(\ell(\pi)-k)$ eventually.
* (c) As in the proof of Thm 3.2: take $t_{L_j}\le4^{-j}$, apply Borel–Cantelli, and use the normaliser bound $2^{-\lambda k}$. ∎

For λ = 1 this is exactly Paper 2's `thm:split:private`(iv). The proof there uses λ > 1 only through the length bound (i), and (a) replaces that bound.

**Consequences.**
* (i) Prop 7.6(a) holds for λ ≥ 1, not only λ > 1.
* (ii) In the frozen object, λ = 1 and λ > 1 achieve the same asymptotic identification: on the run, and nothing beyond it (Prop 7.5).
* (iii) The fill-ins' posterior at λ = 1 tends to 0 in Paper 2's own distinct-input setting, whenever $\sum_n\beta_{x_n}=\infty$.
  * This is consistent with `thm:split:lambda1`(ii): its lower bound $2^{-k-2\log(t_n+1)-\kappa-\delta^*}$ decays like $(\log d_n)^{-2}$, and $d_n\to\infty$ on distinct inputs in $\{0,1\}^*$.
* So "two reasons to be interested in SFI with a stronger complexity penalty" cannot rest on asymptotic identification in either object. What λ > 1 adds is:
  * the uniform length bound (Thm 4.1(i));
  * the exponential fill-in bound (Thm 4.1(iii));
  * the explicit recovery time (Thm 4.1(iv)).

  The cost of λ = 1 is quantitative, and large.

**Evidence.**
* At λ = 1, 1857 of 2000 runs have the 1-MAP in E* at every n ∈ [1000, 2000] [computed: rB3(E)].
* In the parity class the λ = 1 failure probability decays like $2^{k-1}/n^2$, up to a factor of 4 [computed: rB2(F)].

**Fix.**
* Add the claim above as a proposition, with the proof. Its proof is the notes' Step 1 plus Paper 2's Kakutani step.
* Change Prop 7.6(a) to λ ≥ 1.
* In §0 and the §5 table, state the contrast in both objects. The *limit* is the same at λ = 1 and λ > 1. The *uniform* and *finite-sample* guarantees differ:
  * no recovery-time bound at λ = 1 (Prop 5.1);
  * $O(\lambda\ell^*/(\min(1,\lambda-1)\gamma))$ at λ > 1.
* Flag for the paper restructure: `thm:split:private`(iv) should read λ ≥ 1, and `sec:split`'s opening should not suggest that λ = 1 fails in the limit.

### B2. The reading of Lemma 8.1's right side is false: the slack is ℓ* + δ*, not δ*

**Where.**
* Lemma 8.1, last bullet: "To the right, each bit of length buys at most one bit of fit, plus δ* in total."
* §0 item 7: "while longer programs gain at most one bit per bit plus δ*".

**Problem.**
* The lemma proves $\rho_{\mathcal C}(\alpha)\ge S_n-\alpha-\delta^*$. Measured from the kink point $(\ell^*,\rho_{\mathcal C}(\ell^*))$ with $\rho_{\mathcal C}(\ell^*)\le S_n$, this allows a drop of $(\alpha-\ell^*)+\ell^*+\delta^*$. That is ℓ* more than the reading says.
* A program longer than ℓ* may gain up to its whole length over the sampler, not only its length beyond ℓ*. In the parity class below it does.

**Counterexample** [computed: rB4(A), exact; rB4(B), Monte Carlo].
* *Class* (Kraft sum $0.625+2^{-k}$, contains ν):
  * the truth, a fair coin, of length k = ℓ*;
  * Bern(1/4), of length 2;
  * Bern(3/4), of length 3;
  * the $2^M$ deterministic parities on M input bits, of length M + 2.
* *Data.* Inputs uniform on $\{0,1\}^M$, labels fresh per query, at n = M − 5 and α = M + 2 > ℓ*. Let $\text{excess}:=\rho(\ell^*)-\rho(\alpha)-(\alpha-\ell^*)$.
* *Exactness.* The probability is exact: given y ≠ 0, the probability that some parity is consistent does not depend on y, by GL(n, 2) symmetry.
* *Bound.* Since $\Prob[\delta^*\ge c]\le2^{-c}$,
  $$\Prob[\text{reading fails}]\ \ge\ \Prob[\text{excess}\ge c,\ \text{a parity is consistent}]-2^{-c}.$$
* *Values.*

| k = ℓ* | n | α − ℓ* | c | lower bound on P[reading fails] |
|---|---|---|---|---|
| 16 | 60 | 51 | 7 | 0.963 |
| 24 | 30 | 13 | 12 | 0.979 |
| 24 | 60 | 43 | 15 | 0.971 |
| 32 | 60 | 35 | 20 | 0.982 |

* *Monte Carlo* (k = 24, n = 30, 4000 runs). The median excess is 17 bits and the minimum 8.96. In the median run the reading would need δ* ≥ 17, which has probability at most $2^{-17}$.

**Why it matters.**
* This sentence is the bridge to T2 that the brief asks for: "the kink exists … with σ growing linearly in n".
* With slack ℓ* + δ*, the right side of the sample kink is a kink of flatness τ only beyond a window $(\ell^*+\delta^*)/(\tau-1)$. This is how `../kink/notes.md` Thm 5.4(ii) states it.
* So at finite n, if the margin controls all competitors up to length $\bar\alpha$, Ville controls the longer ones only for $\lambda>1+(\ell^*+\delta^*)/(\bar\alpha-\ell^*)$, not for $\lambda>1+\delta^*/(\bar\alpha-\ell^*)$. This is the same $1/(\lambda-1)$ trade-off as Thm 4.1(i), and the same as kink Thm 5.4(iii)'s $\tau_{\bar\ell}$.
* The right slope tends to at most 1 only as n → ∞ (kink Cor 5.7(b)).

**Fix.**
* Replace the sentence by: "for every α, $\rho_{\mathcal C}(\ell^*)-\rho_{\mathcal C}(\alpha)\le(\alpha-\ell^*)+\ell^*+\delta^*$; so the right side is a kink of flatness τ beyond the window $(\ell^*+\delta^*)/(\tau-1)$."
* Cite kink Thm 5.4. Its Lemma 5.2 is also a factor of 2 sharper in the exponent than Lemma 8.1's left side (see b10).
* The paper should carry one version of this lemma, not two.

### B3. The KL-projection conjecture is refuted for fixed λ only. For growing schedules it holds in both counterexamples.

**Where.**
* §0 item 6 ("refuted twice").
* Prop 7.3(ii) and (iii).
* The status row "KL-proj.".

**Problem.**
* The brief asks whether the λ-MAP is eventually a shortest KL-projection, and to prove it or give a counterexample.
* The notes answer "refuted". Both refutations need fixed λ:
  * (ii) needs a mean-zero walk to cross a *fixed* level λΔ infinitely often;
  * (iii) needs λH(p) < 1.
* The header of Prop 7.3 allows schedules $1\le\lambda_n=o(n)$, but (ii) is proved only for fixed λ, and nothing is said about schedules in (iii).

**What happens with schedules** [computed: rB5(A); proof sketch].
* *Example (ii)*: two projections, 20 runs of $2\cdot10^6$ samples each.

| schedule | runs with a switch after n = 10^5 | latest last switch |
|---|---|---|
| λ = 2 fixed | 17/20 | 1,966,541 |
| $\lambda_n=\sqrt n$ | 5/20 | 1,787,850 |
| $n^{0.6}$, $n^{0.75}$, $n/\log n$ | 0/20 | ≤ 26 |

  The longer projection is never the MAP at the end of a run under any growing schedule.
* *Proof sketch.* Take a finite class with $D^*<\infty$, in which the log-likelihood ratios between projections have finite variance. They are mean-zero random walks, so the law of the iterated logarithm bounds them by $O(\sqrt{n\log\log n})$ a.s. Non-projections lose linearly. So if $\lambda_n/\sqrt{n\log\log n}\to\infty$ and $\lambda_n=o(n)$, the MAP is eventually a shortest projection, a.s.
* *Example (iii).* Any $\lambda_n\to\infty$ gives $\lambda_nH(p)>1$ eventually. The notes' own large-λ argument (fill-ins have $\ell\ge S-\delta^*$) then makes the coin, the unique projection, eventually the MAP.
* *Countable classes.* The positive statement does not follow for general countable classes. A program of length about $nD^*/\lambda_n$ is not excluded by Ville when ν ∉ $\mathcal C$, which is the regime of Conjecture 7.4.

**Fix.**
* Add Prop 7.3(v): the finite-class statement for $\lambda_n/\sqrt{n\log\log n}\to\infty$, $\lambda_n=o(n)$, with the LIL proof. Add the remark that in (iii) every $\lambda_n\to\infty$ selects the coin.
* Change the summary and status row to: "refuted for fixed λ (two mechanisms); true in finite classes for schedules growing faster than $\sqrt{n\log\log n}$; open for countable classes (Conj 7.4)".
* Add Referee A's m1 condition $D^*<\infty$ to (ii).

### B4. Frozen noise breaks exact rate identification in the noisy-parity instance itself (new evidence for Referee A's M1)

**Where.**
* Cor 6.1, setting ("or distinct inputs").
* Cor 6.1(i) ("the exact rate p").
* §0 item 5.

**Computation** [computed: rB6(B), (C)].
* *Class.* d = 6, μ uniform on 64 inputs. Programs:
  * parity × rate, with rates {1/8, 1/4, 1/16, 3/16, 0, 3/32, 5/32} and prefix-code lengths 2–5;
  * one-input function competitors g = f xor $1_{x_0}$;
  * the coin.

  Truth (a*, 1/8), with ℓ* = 10.
* *Frozen noise, full table.* Once every input has been seen, the data set is the table, and the MAP depends on the number K ~ Bin(64, 1/8) of flipped inputs. The computation is exact for K ≤ 15; the remaining mass is 0.0047.

| λ | P[frozen λ-MAP ≠ (a*, 1/8)] | selected instead |
|---|---|---|
| 1 | 0.132 | rate 1/16 (0.085), rate 1/4 (0.047) |
| 1.5 | 0.132 | rate 1/16 (0.085), rate 1/4 (0.047) |
| 2 | 0.080 | coin (0.047), rate 1/16 (0.033) |
| 4 | 0.562 | coin (0.552) |

* *Fresh noise, same class* (1000 runs). The failure frequency is at most 0.003 at n = 3200 and 0 at n = 6400, for every λ ∈ {1, 1.5, 2, 4}.

**Reading.**
* "The exact rate p" (Cor 6.1(i)) is a statement about the noisy oracle, the per-query object, only.
* On a frozen table the selected rate is the penalised fit to the empirical flip count. Prop 7.5 shows no procedure can do better.
* λ = 4 lies above the table's kink window: the coin wins on more than half of the tables. With fresh noise every fixed λ > 1 eventually works. This is a direct contrast between T1 (per-query) and T2 (one data set).

**Fix.** As Referee A's M1, and:
* use this example in the paper as the frozen/fresh contrast, within the corollary's own instance;
* state in Cor 6.1 that, for frozen data on a finite domain, the λ-MAP's rate is the penalised empirical rate and is wrong with probability bounded away from 0.

---

## Minor issues

**b1. The recovery-time table of Prop 5.1 uses grid values. The exact values are smaller, and λ = 1 has a closed form** [computed: rB2(B), (F)].
* *Exact values.* I computed P(n) for every integer n from the closed-form rank law. P(n) is non-increasing in n in every case; the largest increase between consecutive n is $3\cdot10^{-16}$. The exact $n_{\rm rec}(0.01)$, with the notes' values in brackets:

| k | λ = 1 | 1.1 | 1.25 | 1.5 | 2 | 3 |
|---|---|---|---|---|---|---|
| 16 | 1030 (1084) | 78 (88) | 46 (50) | 34 (38) | 23 (25) | 20 (22) |
| 24 | 16390 (17736) | 144 (153) | 76 (76) | 52 (58) | 38 (38) | 29 (29) |
| 32 | 262150 (290272) | 232 (233) | 116 (116) | 70 (76) | 51 (58) | 38 (38) |
| 40 | 4194310 (4750753) | 298 (308) | 146 (153) | 94 (101) | 67 (76) | 50 (50) |

* *Closed form.* At λ = 1, $n_{\rm rec}(0.01)=2^{(k+4)/2}+6$ exactly for all four k. So "multiplies by about 16 per 8 bits" is exactly 16.
* *Accuracy of "P ≈ $2^{k-1}/n^2$".* For $n\ge2^{k/2+2}$ the ratio $P\,n^2/2^{k-1}$ lies in [0.25, 1.00], because of the ceiling in ℓ(m).
* *Fix.*
  * Replace the table with the exact values and give the closed form.
  * Write "within a factor 4" for the $2^{k-1}/n^2$ approximation, and mark it [computed] (agrees with Referee A's m6).

**b2. Cor 6.1(iii), "rate competitors have the smallest gaps", is false in general** [computed: rB6(A)]. This agrees with Referee A's m2, independently.
* At d = 10, the competitor g = f xor $1_{x_0}$ with q = p has gap 0.000331. That is below the smallest rate gap, 0.001013 (q = 5/32).
* At d = 6 the rate competitors do attain the margin.
* *Fix.* As Referee A's m2.

**b3. The margin-based sample size is vacuous in classes with near-equivalent programs; a free Chernoff exponent repairs much of the Rényi form** [computed: rB3(C), rB8].
* *The margin form.* In the 583-program class of rB3, $\gamma_{L_\varepsilon}=3.2\cdot10^{-14}$ for λ ≤ 2. This comes from a program that moves ν(1|x) by $2^{-20}$. So $n(\lambda,\ell^*,\gamma,0.05)\approx3\cdot10^{14}$. The empirical failure frequency is at most 1% from n ≈ 400–800 on.
* *The Rényi form.* It plateaus at about 0.11 (λ = 2), which is the prior weight of the near-equivalent programs.
* *The improvement.* Markov for $\Lambda^s$ holds for every s ∈ (0, 1], so
  $$\Prob[J_\lambda(\pi)\le J_\lambda(\pi_0)]\ \le\ \min_{0<s\le1}2^{-s\lambda(\ell(\pi)-\ell^*)}\rho_s(\pi)^n,$$
  which is never worse than the notes' choice s = 1/λ. [proved: Markov's inequality and Lemma 2.1(c)]
  * For a near-equivalent program longer than ℓ*, s = 1 replaces $2^{-(\ell-\ell^*)}$ by $2^{-\lambda(\ell-\ell^*)}$.
  * At λ = 2, n = 2000 this lowers the bound from 0.110 to 0.0035, against an empirical 0.0030.
  * At λ = 4, n = 800 it lowers the bound from 0.045 to 0.0043.
* *Relation to the kink track.* This is the per-program form of `../kink/notes.md` Thm 5.6, the near/far split. It is related to the open problem after Prop 4.3, which it does not solve.
* *Fix.*
  * State this as Thm 4.1(iv′), and derive the margin form from it.
  * Present the Rényi or free-exponent form as the primary finite-sample statement, and the margin form as a corollary.

**b4. The failure probability is not monotone in n** [computed: rB3(C), rB9].
* *Observation.* In rB3's class at λ = 1, rB3 gives $\Prob[\text{MAPs}\ne E^*]=0.066$ at n = 400 and 0.102 at n = 800. rB9 (same class, fresh seed, finer grid) shows the shape. The probability falls from 0.142 (n = 200) to 0.062 (n = 300), rises to 0.157 (n = 600), and falls again, to 0.0075 at n = 2000. λ = 1.25 behaves the same way: 0.023 at n = 400, 0.086 at n = 800.
* *Cause* (rB9). The cause is the partial fill-in "ν, but label 1 at x = 7". There ν(1|7) = 15/16 and μ(7) = 0.046. It gains $\log(16/15)$ bits per visit to x = 7 and dies at the first label 0 there. So it wins with the largest probability at intermediate n.
* *Reading.* This is the per-query analogue of the frozen $e_j$ of Prop 7.6(d).
* *Fix.*
  * Say that recovery times must be read through the uniform-in-time bound (Thm 4.1(v)), not as the first n with small failure probability.
  * Add a remark that partial fill-ins at low-noise atoms are the typical medium-n competitors in the per-query object.
  * i2's definition, the least n *after which* P ≤ ε, is already correct.

**b5. The length bound of Thm 4.1(i) is attained, 1/(λ−1) included** [computed: rB7(B)].
* *Setting.* In $\mathcal C_{k,M}$ with $M=n=\lambda(k-2)/(\lambda-1)$, a consistent parity ties the coin.
* *Result.* Over the runs with a consistent parity, the smallest value of $(\lambda k+\delta_n)/(\lambda-1)$ equals the parity's length exactly:

| k | λ | parity length = bound |
|---|---|---|
| 20 | 2 | 38 |
| 20 | 1.5 | 56 |
| 30 | 3 | 44 |
| 16 | 1.25 | 72 |

  The slack is $\log_2$ of the number of consistent parities.
* *Reading.* So at these n the λ-MAP is a fill-in of length about $\ell^*\lambda/(\lambda-1)$, as long as Thm 4.1(i) allows.
* *Fix.* Add this as a remark next to Prop 4.4(b). It strengthens the "1/(λ−1) is necessary" claim from recovery times to the length bound itself.

**b6. Thm 4.1(vi) is valid but almost never informative at small n** [computed: rB1(2)].
* *Observation.* In 21,600 (class, λ > 1, n ≤ 128, ε ∈ {0.1, 0.01}) cases the bound was below 1 once. The factor $2^{\lambda\ell^*}(2/\varepsilon)^\lambda$ dominates.
* *Fix.* Optional: state (vi) with the Rényi sum in place of $e^{-a_Ln}$, namely $(\tfrac2\varepsilon\sum_{\pi\notin E,\ell\le L}2^{-\ell}\rho_{1/\lambda}(\pi)^n)^\lambda$. The proof is the same Markov step.

**b7. λ > 1 is slower than λ = 1 in about half of random small classes** [computed: rB1(3)].
* *Observation.* At n ∈ {64, 128}, λ = 2 has the larger exact failure probability in 300 of 592 (class, n) cases:
  * in 258 of 313 when the dominant λ = 1 competitor is shorter than ℓ*;
  * in 42 of 279 when it is longer.
* *Reading.* This confirms Prop 4.4(c) and quantifies it. The advantage of λ > 1 is specific to long competitors: fill-ins and memorisers.
* *Fix.*
  * Mark Prop 4.4(c) [computed], as Referee A's m6 also asks.
  * State the quantified version in the paper, so that λ > 1 is not read as uniformly faster.

**b8. The script docstrings and printed headers use an older numbering.**
* *Stale references.*
  * i1: "Thm 3(ii)", "Thm 2".
  * i2: "Proposition 6", "Theorem 3(ii)"; its printed header "(B) Theorem 3(ii) bounds" means Thm 4.1(iv).
  * i3: "Prop 11", "Prop 12(ii)", "Prop 12(iii)", "Prop 13", "Lemma 7".
  * i4: "Corollary 8", "Theorem 4(iii)".
  * i5: "Lemma 7".
  * i6: "Lemma 2", "Theorem 4(i)".
* *Kraft remark.* i2's docstring says the parities' Kraft weight is "< 0.33". It is 0.25, as i2 itself prints.
* *Fix.* Renumber to the notes' current labels, re-run, and re-save the outputs.

**b9. The ties at 31/32 (Props 5.1(b), 4.4(b))** [computed: rB2(D)]. This agrees with Referee A's m3.
* *Values.* Over **all** n in the stated ranges, for k ∈ {16, 24, 32} and λ ∈ {1, 1.1, 1.5, 2, 3}:
  * the strict event "some parity has J < J(coin)" has minimum probability 0.9692;
  * the weak event "≤" has minimum probability 0.9845.

  Both are at least 31/32 = 0.96875, but the proof covers only the weak event.
* *Fix.* Use Referee A's fix (state "the set of MAPs contains a parity", or use "<" and 15/16).

**b10. Lemma 8.1's left side is valid but loose, and it duplicates the kink track** [computed: rB4(C)].
* *Exact check.* Class: coin with ℓ* = 6; Bern(1/4), Bern(3/4) and Bern(0.6) shorter; $\gamma_<=0.00506$.
  * At n = 800 the exact probability of the left-side event is 0.985, while the lemma's lower bound is negative.
  * The bound becomes informative only at n ≈ 2000 (0.595, against an exact 0.9996).
* *Duplication.* `../kink/notes.md` Lemma 5.2 gives the same event with exponent $2\log e\cdot n\,\mathrm{Hel}-2\ell-2\log(1/\varepsilon)$, uniformly over all programs.
* *Fix.* Keep one version, preferably kink's, in the paper.

**b11. Cross-track: the sub-tracks use different data objects.**
* T1 (these notes) uses the per-query object with repeats.
* The kink track's §5 uses (iid) non-atomic μ and (wor) sampling without replacement.
* The bridge (B2) therefore connects different objects. In particular, Lemma 8.1 is stated "per-query (or distinct inputs)", and its "distinct inputs" reading is false for frozen data on atoms (Referee A, M1).
* *Fix.* For the restructured paper, fix one object per thread:
  * per-query (stamped, stamp-ignoring) for the asymptotic and finite-sample T1 theorems;
  * single data sets (frozen; wor) for T2.

  Then state the bridge for the pair explicitly.

---

## Brief checklist (computational side)

| item of the brief (T1) | finding |
|---|---|
| a.s. exact MAP recovery, λ > 1 | holds (Thm 3.1), and also at λ = 1; no counterexample in exact checks [rB1, rB2, rB3] |
| posterior concentration | on E with prior shares, not on E* (Thm 3.2): shares confirmed [rB1]; convergence shown by the prover's i1(C) |
| fill-ins' posterior decays exponentially in $S_n$ | holds pathwise [rB3(B)] |
| finite-sample $n(\lambda,k,\gamma,\varepsilon)$ | correct, but vacuous with near-equivalent programs; use the Rényi or free-exponent form [rB3, rB8] |
| λ = 1 contrast | the limit is the same at λ = 1 in both objects (B1); the quantitative contrast is real and exactly computed (b1) |
| noisy computable functions | exact rate only with fresh noise; frozen noise fails with probability 0.08–0.56 at d = 6 (B4) |
| shared randomness | not re-tested (cited from Paper 2) |
| non-i.i.d. inputs | only "on the run", now also at λ = 1 (B1) |
| misspecification | refuted for fixed λ; holds for fast-growing schedules in finite classes (B3); threshold 1/H(p) confirmed in an explicit class [rB5(B)] |
| finite domains / λ = cn | cn-MAP equals the population minimiser [rB7(A)]; frozen finite tables have a bounded λ-window [rB6(C)] |
| link to T2 | left side fine but loose; right-side reading false (B2) |

---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and scipy 1.17.1. Each script was run from `referee_code/`, and its output is the `.out` file of the same name.*

* **Prover's scripts.**
  * i1–i6 were copied to a scratch directory and re-run.
  * All six outputs are byte-identical to the saved ones in `checks/`.
* **rB1_random_classes_exact** (seed 20261013; rB1(3) builds further classes from the same generator).
  * Lemma 2.1 on $5\cdot10^5$ cases.
  * Thm 4.1(iv), (vi) and Thm 3.2 by exact multinomial enumeration in 300 random classes: 12,600 rows, 0 violations.
  * The λ = 2 vs λ = 1 comparison.
* **rB2_parity_exact** (deterministic, except a Monte Carlo with seed 2026).
  * Closed-form GF(2) rank law, against brute force ($2.2\cdot10^{-16}$) and an all-parities Monte Carlo (within 2σ at 7 points).
  * Exact recovery times on all integers up to $8\cdot10^6$, with P(n) monotone.
  * Props 5.1(a), (b) and 4.4(b) on all n in range.
  * Thm 4.1(iv) in $\mathcal C_k$ and $\mathcal C_{k,M}$.
* **rB3_sim_bounds** (seed 31), 2000 runs × 2000 queries, 583 programs.
  * Ville tails, i.i.d. and adaptive.
  * Thm 4.1(i)–(iii) pathwise, 0 violations.
  * Empirical failure frequencies against Thm 4.1(iv) and (v).
  * Thm 3.1 at λ = 1.
  * An earlier version contained two invalid kernels, with ν(1|x) ± 2^{-j} outside [0, 1].
  * The corrected script keeps only moved values strictly inside (0, 1) and asserts validity. This also drops two valid boundary kernels, so the class has 583 programs instead of 587.
  * The saved output is from the corrected run.
* **rB4_kink_link** (seed 41).
  * The Lemma 8.1 right-side counterexample, exact (GL(n, 2) symmetry, closed-form rank law) and Monte Carlo.
  * The left side, exact.
  * The hull vs brute force: 24,981 pairs, 0 mismatches.
* **rB5_misspecification** (seed 51).
  * Two projections under five schedules, 20 × $2\cdot10^6$.
  * The explicit memoriser class, p ∈ {0.1, 0.25}, n ≤ $10^6$.
* **rB6_noisy_parity** (seed 61).
  * Gap closed form vs direct computation.
  * The fresh-noise simulation, 1000 runs.
  * The frozen full table, exact for K ≤ 15 (residual mass 0.0047).
* **rB7_schedules_tightness** (seed 71).
  * λ = cn vs the population minimiser.
  * Tightness of Thm 4.1(i).
* **rB8_chernoff_bound** (deterministic). The free-exponent bound vs the notes' bound in the rB3 class. The empirical values are copied from rB3's output.
* **rB9_nonmonotone** (seed 91). The source of the non-monotone failure frequency.
* **Reproducibility.** After the final edits, all nine rB scripts were re-run from copies in a scratch directory. Every output is byte-identical to the saved one.
  * Run times: rB1 621 s, rB2 119 s, rB3 396 s, rB9 91 s, and at most 10 s for each of the others.
  * rB2 was run in two scratch directories, with identical results both times.
* **By hand.**
  * The proof sketch of B1: Step 1 of Thm 3.1 with k for ℓ*, plus `app:split:private`(iv).
  * The LIL argument of B3.
  * The Markov step of b3.
  * The exactness argument of B2: for y ≠ 0, $\Prob[y\in\mathrm{colspan}A]$ is the same for all y, because $A\mapsto TA$ preserves the uniform law for invertible T.
* **Not done.**
  * I did not re-test Prop 7.1 (shared randomness), Prop 4.3, or Lemma 5.2's covering step beyond reading i5.
  * I did not check the Barron–Cover attribution.
