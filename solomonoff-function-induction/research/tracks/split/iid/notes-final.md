# Track "split", sub-track "iid": exact model recovery with i.i.d. inputs (target T1), final record

*Brief: `../00-brief.md`, target T1. This is the revised and final record of the sub-track. It replaces `notes.md` (the first version, kept unchanged) after the referee reports `referee-A.md` (proofs) and `referee-B.md` (computation and counterexamples). Written 2026-10-13.*

* **Sources read.**
  * The brief, in full.
  * Paper 2 (`paper-steeper/sections/`): `setup.tex`, `absorb.tex`, `split.tex`, `app-split.tex`, `algstat.tex`, `limits.tex`.
  * The refereed record `research/tracks/steeper/notes-final.md` (§1, §2.5–2.6, §3.1–3.6), cited as "St".
  * Paper 1 (`paper/sections/`): `setting.tex`, `versions.tex`, `learn.tex` and `app-learn.tex` (`prop:learn:perquery`, `prop:learn:freshnoise`).
  * `paper/NOTATION.md`.
  * The two referee reports of this sub-track and their code.
  * The sibling sub-tracks `../kink/notes.md` and `../teacher/notes.md` (no `notes-final.md` existed when this was written), and, where they bear on this sub-track, `../kink/referee-A.md` (issue 1), `../kink/referee-B.md` (issue 1) and `../teacher/referee-A.md` (M4, m7, m8).
* **Scripts.**
  * Prover: `checks/i1`–`i8`, Python 3.11, deterministic or seeded; each output is saved next to its script as a `.out` file. `i7` and `i8` are new in this revision. `i1`–`i6` were relabelled to this file's numbering and re-run (verification log).
  * Referees: `referee_code/rA1`, `rB1`–`rB9`. They were re-run for this revision.
* **Status tags.**
  * **[proved]**: full proof here.
  * **[computed: iN]** or **[computed: rXN]**: checked by that script; output in the `.out` file of the same name.
  * **[known: ref]**: standard or published. "(unverified)" means the statement was not checked against the source.
  * **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]**: as named. Refuted claims are kept, with their counterexamples.
* **Conventions.**
  * $\log=\log_2$ and $\ln$ is natural. Code lengths, fits, KL divergences and deficiencies are in bits.
  * $\Hel(P,Q):=1-\sum_y\sqrt{P(y)Q(y)}$ is the squared Hellinger distance, also for a sub-probability $Q$ (Paper 2's convention).
  * κ is a machine constant (Paper 2's κ). A number marked "κ = 0" sets the unknown machine constant to 0; it is an illustration, not a result about a reference machine.
  * $c:=\lambda/n$ (Paper 2's convention).

**Notation changes from `notes.md`.** The new names follow the kink sub-track and avoid a clash with Paper 2's absorption bound $\ell^*_\lambda$.

| `notes.md`, referee reports, outputs before this revision | this file |
|---|---|
| $\ell^*$, $E^*$ (shortest μ-a.e. equivalent length and programs) | $\ell_0$, $E_0$ (kink's $\ell_0$) |
| $L_n(\pi)$ (the per-query *likelihood*) | $\nu_\pi(h_n)$; the *fit* is now $L_n(\pi):=-\log\nu_\pi(h_n)$ (kink's $L(\pi)$) |
| $\gamma(\pi)$ (the Hellinger gap) | $\Hel_\mu(\pi)$ (kink's notation) |
| $\gamma_<$ | $\gamma_-$ (kink's notation) |
| $L_\lambda$ (absorption length bound) | $\ell^*_\lambda$ (Paper 2's notation) |

The scripts `i1`–`i6` now print `l0`, `E0`. The referees' scripts still print `l*`, `E*`.

---

## Revision summary

Every fatal and major issue was accepted; none was fatal. §10 lists every issue with its resolution and location.

* **Objects (A M1, B4, B11).** The three data objects are now separated throughout: the per-query object (PQ), the frozen object (FR) and the single data set (DS) (§1). On Paper 2's input set $X=\{0,1\}^*$, every input law is atomic. So §3–§4, §6 and §8 are about PQ only. "Or distinct inputs" now means a non-atomic law on an uncountable standard Borel space, outside both papers. The frozen counterexamples are cited where they bite. Cor 6.1(vi) records the frozen failure in the corollary's own instance: 0.20–0.57 [computed: i8(D), rB6(C)].
* **$\ell_0$ versus $k$ (A M2).** Comparisons on the sample hold with $\ell_0$. Constructions that decode with ν's program need a program that is a measure where it decodes: $k_\nu$ in Lemma 5.2 (Def 1.2).
* **Prop 7.3(iii) (A M3).** It is restricted to frozen data on distinct inputs, in a prefix-free class. New (iii′): in PQ the coin wins in that class for every λ.
* **λ = 1 on the run (B1).** New Prop 3.3 [proved]: for every λ ≥ 1, every input rule, and PQ or FR, the λ-MAPs are eventually ν-equivalent on the run, and the posterior concentrates there. So `thm:split:private`(iv) holds at λ = 1. In neither object does λ > 1 change the asymptotic identification guarantee; it changes the uniform and finite-sample guarantees.
* **The right side of the sample kink (B2).** The slack is $\ell_0+\delta^*$, not $\delta^*$. The $\ell_0$ term cannot be dropped: in $\mathcal C_{k,M}$ the excess is exactly $k-7$ bits with probability ≥ 31/32 [proved; computed: i8(G), rB4]. Lemma 8.1 now uses the kink sub-track's sharper left side (B b10).
* **Misspecification with schedules (B3).** New Prop 7.3(v) [proved, with the law of the iterated logarithm]. In finite classes, the KL-projection conjecture holds for $\lambda_n/\sqrt{n\log\log n}\to\infty$, $\lambda_n=o(n)$. It fails for $\lambda_n=O(\sqrt{n\log\log n})$ with a small enough constant, and for fixed λ.
* **Finite-sample bounds (B b3, A m14, B b6).** New Thm 4.1(iv′), with a free Chernoff exponent, is the primary finite-sample statement. It needs no Ville term. New Remark 4.7 [proved] says exactly what λ > 1 buys there: with λ = 1 the bound needs $\sum_\pi2^{-s\ell(\pi)}<\infty$ for some $s<1$, a property of the class that fails in the parity class of Prop 5.1.
* **New results:**
  * λ = cn recovers if and only if $c<c^*$ (strict inequalities on both sides), and converges to the population minimisers in every countable Kraft class (Prop 3.4(b),(c)) [proved].
  * The length bound of Thm 4.1(i), with the current deficiency $\delta_n$, is attained up to $2^{2-k}/((\lambda-1)\ln2)$ bits (Remark 4.5) [proved].
  * At λ = 1 the recovery time in $\mathcal C_k$ lies in $(2^{(k-8)/2}-6,\ \max(32,2^{(k+1)/2}/\sqrt\varepsilon)]$ (Prop 5.1(b′)) [proved].
  * The exact recovery-time table [computed: i7, rB2].
* **Minor fixes.** The ties of Props 4.4(b) and 5.1(b) are fixed with strict conditions. The statement of Cor 6.1 is repaired. Prop 4.3's computability step is repaired. Prop 7.3(ii) now requires $D^*<\infty$. The statuses, the measurability conditions and the side conditions are corrected.
* **Cross-track consistency (§9)** is new.

---

## 0. Summary

1. **Three objects (§1).**
   * **(PQ)** *Per query.* Pairs i.i.d. from $\mu\otimes\nu$, with the label redrawn at every query, and the per-query likelihood (the terms of Paper 1's $\Mpq$). Repeats are allowed.
   * **(FR)** *Frozen.* One label per distinct input, with Paper 2's data-set likelihood.
   * **(DS)** *A single data set,* with no probability model.

   On $X=\{0,1\}^*$, μ is atomic, inputs repeat, and PQ and FR differ. They coincide only for a non-atomic μ on an uncountable standard Borel space, or for stamped inputs with stamp-ignoring programs. Unless an item says otherwise, §3–§6 and §8 are about PQ.
2. **Exact recovery in the limit (§3) [proved].**
   * *Thm 3.1.* In every countable class with Kraft weights that contains the sampler (μ-a.e.), for **every schedule $1\le\lambda_n=o(n)$, λ = 1 included**, almost surely the set of $\lambda_n$-MAPs is eventually exactly $E_0$: the shortest programs whose kernel equals ν μ-a.e.
   * *Thm 3.2.* The power and tempered posteriors concentrate on the set $E$ of *all* μ-a.e. equivalent programs, with the prior's shape inside $E$.
   * *Refuted.* "The posteriors concentrate on $E_0$" [refuted; computed: i1(C)].
   * *Prop 3.4, λ = cn.* With $c^*:=\min_{\ell(\pi)<\ell_0}D(\pi)/(\ell_0-\ell(\pi))$, the cn-MAP set is eventually $E_0$ if $c<c^*$, and eventually excludes $E_0$ if $c>c^*$. In general it converges to the minimisers of the population objective $c\ell+R$ [proved; computed: i1(D), i8(B), rB7(A)].
3. **Identification on the run, every λ ≥ 1 (Prop 3.3) [proved].**
   * For every input rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn, in PQ and in FR, and every fixed λ ≥ 1: almost surely the λ-MAPs eventually are ν-equivalent on the run, and the power posterior concentrates there.
   * In PQ with i.i.d. inputs, "equivalent on the run" is "in E".
   * So λ > 1 does not change the asymptotic identification guarantee in either object. In FR no procedure does better (Prop 7.5).
4. **What λ > 1 adds: uniform and finite-sample guarantees (§4).**
   * *For all n simultaneously* (Thm 4.1(i)–(iii)) [proved]:
     * the MAP length is at most $\ell_0+(\ell_0+\delta^*)/(\lambda-1)$;
     * the fill-ins' posterior is at most $2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)S_n}$.

     With the current deficiency $\delta_n$ in place of δ*, the length bound is attained up to $2^{2-k}/((\lambda-1)\ln2)$ bits (Remark 4.5) [proved; computed: i7(E), rB7(B)].
   * *Per n* (Thm 4.1(iv′)) [proved]:
     $$\Prob[\text{λ-MAPs}\ne E_0]\le\sum_{\pi\notin E}\inf_{0<s\le1}2^{-s\lambda(\ell(\pi)-\ell_0)}\rho_s(\pi)^n.$$
     With a margin γ this gives every λ-MAP in $E_0$ with probability ≥ 1 − ε once
     $$n\ \ge\ n(\lambda,\ell_0,\gamma,\varepsilon)=\Big\lceil\frac{\lambda(\ell_0+\log(2/\varepsilon))\ln2}{2\min(1,\lambda-1)\gamma}\Big\rceil$$
     (Thm 4.1(iv)). A uniform-in-time version is (v).
   * *Why λ > 1 (Remark 4.7)* [proved]. At λ = 1 the same bound needs $\sum_\pi2^{-s\ell(\pi)}<\infty$ for some $s<1$, a property of the class. It holds in finite classes and fails in the parity class of Prop 5.1.
   * *Necessity.*
     * The factor $1/\gamma$ is necessary for λ ≥ 2, up to $\ell_0/\Delta$ (Prop 4.4(a)) [proved].
     * The factor $1/(\lambda-1)$ is necessary up to logarithms, for $\lambda-1\gtrsim\ell_0 2^{-\ell_0/2}$ (Prop 4.4(b)) [proved].
     * The two are shown in separate classes.
   * *λ > 1 is not uniformly faster.* It is slower against shorter competitors (Prop 4.4(c)) [computed: i1(A), rB1(3)].
   * *Canonical class (Prop 4.3)* [proved]. With $Y=\{0,1\}$ and ν bounded away from 0 and 1, the margin is smaller than every computable function of $L$. So the margin form gives no computable sample size there.
5. **λ = 1 (§5).**
   * In the parity class $\mathcal C_k$ with a uniform margin 0.293, the recovery time at λ = 1 lies between $2^{(k-8)/2}-6$ and $\max(32,2^{(k+1)/2}/\sqrt\varepsilon)$ (Prop 5.1) [proved]. Its exact value at ε = 0.01 is $2^{(k+4)/2}+6$ for $k\in\{16,24,32,40\}$ [computed: i7, rB2]. At λ > 1 it is about $\lambda k/(\lambda-1)$ (Thm 4.1, Prop 4.4(b)).
   * A single deterministic fill-in of length $k_\nu-\log\nu(D)+O(\log n+\log d+\log S)$ exists on every data set (Lemma 5.2) [proved; computed: i5].
   * Prop 5.3 says what the 1-MAP is, object by object.
6. **Corollaries (§6).**
   * *Noisy computable functions in PQ.* $f$ (μ-a.e.) and the **exact** rate $p$ are selected; the flips are the noise (Cor 6.1) [proved; computed: i4].
   * *In FR on a finite domain* the selected rate is a penalised empirical rate. It is wrong with probability 0.20–0.57 in the i4 class at $d=6$ [computed: i8(D)]. A proved lower bound is $(7/8)^{64}$.
   * Every countable subclass: time-bounded, circuit, finite (Cor 6.2) [proved].
7. **What fails (§7).**
   * *Shared randomness* (Prop 7.1) [proved, from Paper 2].
   * *Non-i.i.d. inputs.* With positive probability the eventual MAP is a shorter program that differs from ν at every queried input (Prop 7.2) [proved; computed: i3(D)].
   * *Misspecification.* The KL-projection conjecture is **refuted for fixed λ**, by two mechanisms:
     * in PQ, two projections with different kernels make the MAP oscillate (Prop 7.3(ii));
     * in FR, fill-ins beat the projection for $\lambda<1/H(p)$ (Prop 7.3(iii)).

     In PQ the second mechanism does not occur (Prop 7.3(iii′)). The conjecture **holds in finite classes for schedules with $\lambda_n/\sqrt{n\log\log n}\to\infty$, $\lambda_n=o(n)$**, and this growth rate is sharp up to the constant (Prop 7.3(v)) [proved; computed: i8(C), rB5]. Countable classes are open (Conj 7.4).
   * *Frozen noise.* No procedure recovers every sampler (Prop 7.5) [proved]. What survives:
     * identification on the run, for λ ≥ 1 (Prop 7.6);
     * finite-sample identification on large uniform finite domains (Remark 7.7, which cites the kink sub-track).
8. **Link to T2 (§8) [proved].**
   * With probability ≥ 1 − ε, simultaneously for all π,
     $$L_n(\pi)-S_n>2\log e\cdot n\Hel_\mu(\pi)-2\ell(\pi)-2\log(1/\varepsilon).$$
     This is kink Lemma 5.2 in PQ form.
   * For all $n$, $L_n(\pi)-S_n\ge-\ell(\pi)-\delta^*$.
   * So the sample has a left kink at $(\ell_0,S_n)$ of steepness linear in $n$. On the right it is a kink of flatness τ beyond the window $(\ell_0+\delta^*)/(\tau-1)$. The $\ell_0$ in the window is necessary.

---

## 1. Setting: the class, the target and the three objects

**Definition 1.1 (class, sampler, per-query data).**
* *Class.* A countable set $\mathcal C$ of programs with lengths $\ell(\pi)\in\mathbb N$ and Kraft sum $\sum_{\pi\in\mathcal C}2^{-\ell(\pi)}\le1$.
  * Each π has a kernel $\nu_\pi(y\mid x)\ge0$ with $\sum_y\nu_\pi(y\mid x)\le1$, measurable in $x$. $Y$ is finite.
  * The tail of the prior is $t_L:=\sum_{\ell(\pi)>L}2^{-\ell(\pi)}$. It tends to 0 as $L\to\infty$.
  * Prefix-freeness, lower semicomputability and the structure of Paper 2's canonical classes are used only where a statement names $\Hcl{\times}$ or a canonical class: Prop 4.3, Lemma 5.2, Prop 5.3(c),(d), Cor 6.1(v), Prop 7.1, and the canonical parts of §7.4–§7.5. Everything else uses only countability and the Kraft inequality.
  * $\Hcl{\times}$ and every time-bounded or circuit product class are instances.
* *Sampler and input law.* ν is a probability kernel, $\sum_y\nu(y\mid x)=1$, on an input space $X$ with a probability measure μ. Neither needs to be computable.
* *Per-query data (PQ).* The pairs $(x_i,y_i)$ are i.i.d. from $\mu\otimes\nu$, so the label is drawn afresh at every query, repeats included. Write $h_n:=(x_1,y_1,\dots,x_n,y_n)$.
  * The per-query likelihood of π is $\nu_\pi(h_n):=\prod_{i\le n}\nu_\pi(y_i\mid x_i)$. This is π's term in Paper 1's per-query mixture $\Mpq$ (`prop:learn:perquery`).
  * The fit of π is $L_n(\pi):=-\log\nu_\pi(h_n)\in[0,\infty]$.
  * The sampled randomness is $S_n:=-\log\nu(h_n)$.
  * The likelihood ratio is $\Lambda_n(\pi):=\nu_\pi(h_n)/\nu(h_n)=2^{S_n-L_n(\pi)}$. Almost surely $\nu(y_i\mid x_i)>0$ for all $i$, so $\Lambda_n$ is well defined.
  * The two-part objective is $J_\lambda(\pi):=\lambda\ell(\pi)+L_n(\pi)$, and its minimisers are the λ-MAPs.
  * The power posterior is $\Pi_\lambda(\pi\mid h_n)\propto2^{-\lambda\ell(\pi)}\nu_\pi(h_n)$, and the tempered posterior is $\Pi^\eta(\pi\mid h_n)\propto2^{-\ell(\pi)}\nu_\pi(h_n)^\eta$. These are `def:setup:objectives` with the per-query likelihood.
  * On distinct inputs $\nu_\pi(h_n)$ is Paper 2's product law $\nu_\pi(D_n)$.

**Definition 1.2 (target; the lengths $\ell_0$, $k$, $k_\nu$).**
* $E:=\{\pi\in\mathcal C:\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)\text{ for μ-a.e. }x\}$. Assume $E\neq\emptyset$ ("ν is in the class").
* $\ell_0:=\min_{\pi\in E}\ell(\pi)$ and $E_0:=\{\pi\in E:\ell(\pi)=\ell_0\}$. By Kraft, $E_0$ is finite.
* For π ∈ E, almost surely $\Lambda_n(\pi)=1$ for all $n$, because every $x_i$ falls a.s. where the two kernels agree.
* *Three lengths for "a program for ν".*
  * $\ell_0$ is defined through μ. A program in $E_0$ may differ from ν, and may be defective, on a μ-null set.
  * $k$ denotes the length of a given program $\pi_\nu\in\mathcal C$ whose kernel equals ν at **every** input. This is Paper 2's $k$ (`def:split:setting`).
  * $k_\nu$ denotes the length of a program whose kernel is a computable *measure* equal to ν on every input the construction at hand must handle (in Lemma 5.2: all inputs of length at most $d$).
  * If $\pi_\nu$ exists, then $\ell_0\le k$. Its kernel is lsc with total mass 1, hence a computable measure, so $\pi_\nu$ can serve as the decoder of Lemma 5.2: the least possible $k_\nu$ is at most $k$. A decoder that is a measure only on $\{0,1\}^{\le d}$ may be shorter than $\ell_0$, since it need not be in $E$.
* **Which length a statement may use (A M2).**
  * Statements that compare $J$ or likelihoods with a program for ν *on the sample* hold with $\ell_0$, because a.s. $\nu_{\pi_0}(h_n)=\nu(h_n)$ for $\pi_0\in E_0$. Examples are Thm 4.1(i)–(iii) and `thm:split:private`(i)–(iii) in per-query form.
  * Constructions that *decode* with ν's program at inputs off the sample need that program to be a measure there. Lemma 5.2 enumerates all data sets on $\{0,1\}^{\le d}$, so it needs $k_\nu$.
  * Without an input law (adaptive inputs, Prop 7.2(a), Prop 3.3), $E$ is undefined. Statements then use $k$.
  * Paper 2's stream lemma `lem:split:stream` transfers to an $E_0$-program on data sets whose inputs lie where its kernel equals ν. Certifying a label at $x$ needs the kernel to be a measure only at that $x$. Define the fill-in's value at $x$ as the first label certified in a dovetailed search. That is a partial computable function whatever the kernel does elsewhere, and at the inputs of the data set the proof of `lem:split:stream` applies unchanged. [proved: this modification of the proof of `lem:split:stream`.]

**Definition 1.3 (the frozen object, FR).** The inputs $x_1,x_2,\dots$ are i.i.d. from μ.
* The data set $D_n$ is the set of distinct pairs among the first $n$. Each distinct input carries one label, and, given the input sequence, the labels at the distinct inputs are independent with laws $\nu(\cdot\mid x)$.
* The likelihood is Paper 2's product law $\nu_\pi(D_n)=\prod_{x\in\dom D_n}\nu_\pi(D_n(x)\mid x)$, with each distinct input counted once.
* On a countable $X$ this is the same as drawing a random function $F$ with independent values $F(x)\sim\nu(\cdot\mid x)$ once, and setting $D_n=\{(x_i,F(x_i))\}$.
* This is Paper 2's setting (`def:setup:data`, frozen noise) with i.i.d. inputs.
* Indexed by its distinct inputs in order of first appearance, FR is an instance of an input rule that picks each new input before its label is drawn.
* (DS) denotes a single data set with no probability model.

**Remark 1.4 (which object; repeats) [proved].**
* (a) *Non-atomic μ.*
  * Let $X$ be a standard Borel space and $(x,\pi)\mapsto\nu_\pi(y\mid x)$ measurable. If μ is non-atomic, inputs are a.s. distinct, because the diagonal is measurable and has $\mu\otimes\mu$-measure 0. Then PQ and FR coincide, and every PQ statement applies to Paper 2's data-set likelihood.
  * Such μ needs an uncountable $X$, for example infinite sequences read as oracles. That is outside both papers.
  * No proof here uses computability, except where a canonical class is named (Def 1.1).
* (b) *Paper 2's $X=\{0,1\}^*$.* $X$ is countable, so μ is purely atomic and inputs repeat almost surely. PQ then models a source that **redraws** the label at each query (a noisy oracle); FR models a fixed noisy table. They lead to different theorems:
  * on $\{0,1\}^*$ only PQ is covered by §3–§4, §6 and §8;
  * FR is governed by Prop 3.3, Props 7.5–7.6 and Remark 7.7;
  * Lemma 5.2 and Prop 5.3(b),(c) are statements about single data sets (DS) with distinct inputs.
* (c) *Stamps.* Stamping the queries with their index makes the inputs distinct.
  * A stamp-ignoring program $\tilde\nu_\pi(y\mid\langle x,t\rangle):=\nu_\pi(y\mid x)$ has product law $\nu_\pi(h_n)$ on the stamped data set (Paper 1, `prop:learn:perquery`(d)). So PQ is Paper 2's product class on stamped inputs, *restricted to stamp-ignoring programs*.
  * The full class $\Hcl{\times}$ on stamped data also contains fill-ins that read the stamp. These never conflict, and the stamped inputs $\langle x,t\rangle$ are not i.i.d. So Thm 3.1 says nothing about $\Hcl{\times}$ on stamped data (A m10).
* (d) *Shared randomness.* Random-function SFI cannot model fresh noise: its expected loss is infinite once inputs repeat with positive probability (Paper 1, `prop:learn:freshnoise`). PQ is the natural object for a product class.

**Remark 1.5 (FR on a uniform finite support is sampling without replacement) [proved; computed: i8(E)].**
* *Claim.* Let μ be uniform on a finite $X_0$. The distinct inputs of an i.i.d. sequence, in order of first appearance, form a uniformly random ordering of $X_0$.
* *Proof.* The law of that ordering is invariant under every permutation of $X_0$, because μ is. ∎
* *Consequence.* FR with μ uniform on $X_0$, observed at its first $m$ distinct inputs, is the kink sub-track's scheme (wor) with $m$ samples. The kink sub-track's finite-sample results for (wor) (kink Lemma 5.1, Cor 5.5, Thm 5.6) therefore hold in FR on a uniform finite support, counted in distinct inputs (Remark 7.7).
* *Non-uniform atomic μ.* For such μ the ordering is not uniform, and kink Lemma 5.1 can fail (`../kink/referee-B.md`, issue 1, rB6 there).
* [computed: i8(E): 120,000 runs on $X_0=\{0,1,2,3\}$; all 24 orderings occur; χ² = 24.2 on 23 df, p = 0.39.]

---

## 2. Tools

**Lemma 2.1 (likelihood ratios) [proved; (b) uses the strong law of large numbers, known].** Let π ∈ $\mathcal C$, and let $Z:=\nu_\pi(y\mid x)/\nu(y\mid x)$ for $(x,y)\sim\mu\otimes\nu$. In PQ, $\Lambda_n(\pi)$ is a product of $n$ i.i.d. copies of $Z$. For $s\in(0,1]$ put
$$\rho_s(\pi):=\Ex_{x\sim\mu}\sum_{y:\nu(y\mid x)>0}\nu(y\mid x)^{1-s}\nu_\pi(y\mid x)^s,\qquad \Hel_\mu(\pi):=1-\rho_{1/2}(\pi)=\Ex_\mu\Hel\big(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x)\big).$$
* (a) $\Ex[Z\mid x]=\sum_{y:\nu(y\mid x)>0}\nu_\pi(y\mid x)\le1$. So $\Lambda_n(\pi)$ and $\Lambda_n(\pi)^\eta$ ($0<\eta\le1$) are nonnegative supermartingales. Also $\rho_1(\pi)\le1$.
* (b) $D(\pi):=-\Ex\log Z\in[0,\infty]$, and $D(\pi)>0$ iff π ∉ E. Moreover $\Ex(\log Z)^+\le\log e/e<0.531$, and $\frac1n\log\Lambda_n(\pi)\to-D(\pi)$ a.s., also when $D(\pi)=\infty$.
* (c) $\Ex\Lambda_n(\pi)^s=\rho_s(\pi)^n$. For $s<1$, $\rho_s(\pi)<1$ iff π ∉ E.
* (d) For $s\in(0,1)$, $\rho_s(\pi)\le\rho_{1/2}(\pi)^{2\min(s,1-s)}$. Hence $1-\rho_s(\pi)\ge2\min(s,1-s)\Hel_\mu(\pi)$ and $\rho_s(\pi)^n\le e^{-2\min(s,1-s)\Hel_\mu(\pi)n}$.

*Proof.*
* (a) Sum over the labels with $\nu(y\mid x)>0$. Jensen gives $\Ex[Z^\eta\mid x]\le(\Ex[Z\mid x])^\eta\le1$. The supermartingale property holds because the pairs are i.i.d.
* (b) Positivity.
  * Conditional Jensen for the strictly concave log gives $\Ex[\log Z\mid x]\le\log\Ex[Z\mid x]\le0$.
  * Equality in both holds iff $Z$ is a.s. constant given $x$ and $\sum_{y:\nu>0}\nu_\pi(y\mid x)=1$. That means $\nu_\pi(y\mid x)=c\,\nu(y\mid x)$ on the support of $\nu(\cdot\mid x)$, with $c=1$. Then $\sum_y\nu_\pi(y\mid x)\le1$ forces $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$.
  * So $\Ex[\log Z\mid x]<0$ exactly where the kernels differ, and $D(\pi)>0$ iff they differ on a set of positive μ-measure.
* (b) Strong law.
  * The positive part is integrable: $\log z\le z\log e/e$ for $z>0$, since $\ln z/z\le1/e$. So $\Ex(\log Z)^+\le(\log e/e)\Ex Z\le\log e/e$.
  * The strong law for i.i.d. variables with integrable positive part gives $\frac1n\sum\log Z_i\to\Ex\log Z\in[-\infty,0]$ a.s. [known: e.g. Durrett, *Probability: Theory and Examples*, the strong law and its extension to $\Ex X^-=\infty$ (section number unverified)].
  * When $Z=0$ has positive probability, $\Lambda_n$ is eventually 0.
* (c)
  * Independence gives $\Ex\Lambda_n^s=(\Ex Z^s)^n$, and $\Ex Z^s=\rho_s$.
  * For $s<1$, Hölder gives $\sum_{y:\nu>0}\nu^{1-s}\nu_\pi^s\le(\sum_y\nu)^{1-s}(\sum_{y:\nu>0}\nu_\pi)^s\le1$. Equality holds iff $\nu_\pi(\cdot\mid x)$ is proportional to $\nu(\cdot\mid x)$ on its support with total mass 1 there, that is, iff $\nu_\pi(\cdot\mid x)=\nu(\cdot\mid x)$.
* (d) Hölder on $\mu(dx)\times$ counting measure on $Y$, with exponents $a+b=1$.
  * For $s\in[\tfrac12,1)$: $\nu^{1-s}\nu_\pi^s=(\sqrt{\nu\nu_\pi})^{2(1-s)}\,\nu_\pi^{2s-1}$. So $\rho_s\le\rho_{1/2}^{2(1-s)}(\Ex_\mu\sum_y\nu_\pi)^{2s-1}\le\rho_{1/2}^{2(1-s)}$.
  * For $s\in(0,\tfrac12]$: $\nu^{1-s}\nu_\pi^s=(\sqrt{\nu\nu_\pi})^{2s}\,\nu^{1-2s}$. So $\rho_s\le\rho_{1/2}^{2s}$.
  * Then use $(1-\gamma)^a\le1-a\gamma$ for $a\in[0,1]$, and $1-u\le e^{-u}$. ∎

[computed: i1(B). The inequality of (d) holds for all 8 programs of a test class and $s\in\{0.05,\dots,0.95\}$; the largest violation is $2.2\cdot10^{-16}$ (rounding). $\Ex\Lambda_6^s=\rho_s^6$ by exact enumeration, error $1.7\cdot10^{-15}$. rB1(1): (d) on $5\cdot10^5$ random kernel pairs, sub-probabilities and zeros included, with no violation.]

**Lemma 2.2 (Ville deficiency, per query) [proved; computed: i6, rB3(A),(A′); Ville's inequality known].** Let $\xi_{\mathcal C}(h_n):=\sum_\pi2^{-\ell(\pi)}\nu_\pi(h_n)$. Define the current deficiency $\delta_n:=\log(\xi_{\mathcal C}(h_n)/\nu(h_n))$ and $\delta^*:=\sup_n\delta_n$.
* (a) $\Prob[\delta^*\ge j]\le2^{-j}$ for every real $j\ge0$. Also $\Lambda_n(\pi)\le2^{\ell(\pi)+\delta_n}\le2^{\ell(\pi)+\delta^*}$ for all π and $n$.
* (b) For every $L$, $Z^L_n:=\sum_{\ell(\pi)>L}2^{-\ell(\pi)}\Lambda_n(\pi)$ is a nonnegative supermartingale with $Z^L_0=t_L$. So $\Prob[\sup_nZ^L_n\ge a]\le t_L/a$. The same holds with $\Lambda_n^\eta$, $0<\eta\le1$, in place of $\Lambda_n$.
* (c) Both hold for any input rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn (adaptive, randomised, non-computable), with fresh labels at repeats or with distinct inputs. They also hold when ν ∉ $\mathcal C$, since only the truth's own likelihood is in the denominator. They need the Kraft sum ≤ 1. With Kraft sum $K>1$ the tail in (a) is $K2^{-j}$.
* (d) At a fixed $n$, $\Ex2^{\delta_n}\le1$, so $\Prob[\delta_n\ge j]\le2^{-j}$ by Markov's inequality.

*Proof.* By Lemma 2.1(a) applied termwise, $\Ex[\xi_{\mathcal C}(h_{n+1})/\nu(h_{n+1})\mid h_n,x_{n+1}]\le\xi_{\mathcal C}(h_n)/\nu(h_n)$. The initial value is $\sum2^{-\ell}\le1$. Ville's maximal inequality [known: Ville 1939] gives (a), and the same argument gives (b). For the consequence in (a), $2^{-\ell(\pi)}\Lambda_n(\pi)\le\xi_{\mathcal C}(h_n)/\nu(h_n)=2^{\delta_n}$. This is `lem:split:ville` with per-query likelihoods; the proof there uses only the one-step inequality. ∎

[computed: i6. Inputs uniform on 8 points (so they repeat), 32 programs, 4000 runs of 3000 queries. The empirical $\Prob[\delta^*\ge j]$ is 0.207, 0.103, 0.053, 0.026 and 0.007 for $j=1,2,3,4,6$, all below $2^{-j}$. rB3(A′): an adaptive rule that queries where the mixture deviates most from ν gives 0.139, 0.032, 0.014 at $j=1,2,3$.]

---

## 3. Exact recovery in the limit

**Theorem 3.1 (exact recovery of the MAP, PQ) [proved; computed: i1(A), i2, i4, i7, rB3(E)].** In the setting of Definitions 1.1–1.2, let $(\lambda_n)$ be any schedule with $\lambda_n\ge1$ and $\lambda_n/n\to0$. Fixed λ ≥ 1 is allowed, **including λ = 1**. Almost surely there is $n_0$ such that for every $n\ge n_0$ the set of $\lambda_n$-MAPs equals $E_0$.

*Proof.* Work on the almost sure event where $\nu_\pi(h_n)=\nu(h_n)>0$ for all π ∈ E and all $n$.
* *MAPs exist.* $J_{\lambda_n}(\pi)\ge\ell(\pi)$, and only finitely many programs have length below $J_{\lambda_n}(\pi_0)<\infty$, $\pi_0\in E_0$. So the set of MAPs is finite and nonempty.
* *A MAP beats $E_0$.* If $\hat\pi$ is a $\lambda_n$-MAP, then $J_{\lambda_n}(\hat\pi)\le J_{\lambda_n}(\pi_0)$, that is,
  $$\log\Lambda_n(\hat\pi)\ \ge\ \lambda_n\big(\ell(\hat\pi)-\ell_0\big).\tag{3.1}$$
* *Step 1: long programs, uniformly in $n$.*
  * Let $L\ge\ell_0$. If a MAP has $\ell(\hat\pi)>L$, then (3.1) and $\lambda_n\ge1$ give $\log\Lambda_n(\hat\pi)\ge\ell(\hat\pi)-\ell_0$. So $2^{-\ell(\hat\pi)}\Lambda_n(\hat\pi)\ge2^{-\ell_0}$, hence $Z^L_n\ge2^{-\ell_0}$.
  * Let $B_L:=\{\exists n:\ Z^L_n\ge2^{-\ell_0}\}$. By Lemma 2.2(b), $\Prob(B_L)\le2^{\ell_0}t_L\to0$. Since $Z^L_n$ is nonincreasing in $L$ pathwise, $B_L$ decreases in $L$, and $\Prob(\bigcap_LB_L)=0$.
  * So almost surely there is a finite $L_0$ such that no $\lambda_n$-MAP, at any $n$, is longer than $L_0$.
* *Step 2: the finitely many short programs.*
  * By Lemma 2.1(b) and countability, almost surely $\frac1n\log\Lambda_n(\pi)\to-D(\pi)<0$ simultaneously for all π ∉ E.
  * Take π ∉ E with $\ell(\pi)\le L_0$.
    * If $\ell(\pi)\ge\ell_0$, the left side of (3.1) tends to $-\infty$ and the right side is $\ge0$. So π is eventually not a MAP.
    * If $\ell(\pi)<\ell_0$, the left side is eventually at most $-nD(\pi)/2$ (or tends to $-\infty$ faster), while the right side is $-\lambda_n(\ell_0-\ell(\pi))=-o(n)$. So π is eventually not a MAP.
  * Programs in $E\setminus E_0$ have $\Lambda_n=1$ and $\ell>\ell_0$, so (3.1) fails for them at every $n$.
  * There are finitely many programs with $\ell\le L_0$. So from some $n_0$ on every MAP lies in $E_0$. All of $E_0$ have the same $J$, so the set of MAPs is exactly $E_0$. ∎

*Remarks.*
* **λ = 1 is included.** The asymptotic split does not need a steeper prior. The tail $t_L$ of the prior bounds the probability that a long program, for example a fill-in, is ever selected. What λ > 1 adds is a length bound that depends only on $\ell_0$, λ and δ* (Thm 4.1(i)), in place of the class-dependent tail $t_L$, together with finite-sample rates (§4). §5 shows that the difference is real.
* **Known.** For i.i.d. density estimation with a countable list of densities and Kraft code lengths, consistency of two-part MDL (λ = 1) is attributed to Barron & Cover 1991 [known: per Poland & Hutter 2005, which states that i.i.d. MDL estimates are consistent [BC91]; whether Barron and Cover state "equals the true density for all large n a.s." and for which complexity weights is unverified]. Theorem 3.1 is the conditional (supervised) analogue. It allows sub-probability kernels, an arbitrary input law and schedules $\lambda_n=o(n)$, and it identifies the limit as the *shortest* μ-a.e. equivalent programs. The proof is the standard Ville-plus-strong-law argument. No novelty is claimed for the method.
* μ enters only through "μ-a.e.". The theorem identifies ν on the support of μ, and says nothing about inputs of μ-measure zero.
* The object is PQ. In FR on Paper 2's $X$ the statement is false (Prop 7.5; Prop 7.6(d) is a counterexample).

**Theorem 3.2 (posterior concentration, PQ) [proved; computed: i1(C), rB1(2)].** Fix λ ≥ 1 and η ∈ (0, 1]. Almost surely:
* (i) $\Pi_\lambda(E\mid h_n)\to1$, and $\Pi_\lambda(\pi\mid h_n)\to2^{-\lambda\ell(\pi)}/W_\lambda$ for every π ∈ E, where $W_\lambda:=\sum_{\pi\in E}2^{-\lambda\ell(\pi)}$. In particular $\Pi_\lambda(E_0\mid h_n)\to w_\lambda:=|E_0|2^{-\lambda\ell_0}/W_\lambda$.
* (ii) The tempered posterior satisfies $\Pi^\eta(E\mid h_n)\to1$ and $\Pi^\eta(E_0\mid h_n)\to w_1$.
* (iii) $w_\lambda\ge w_1$, and $w_\lambda=1$ iff $E=E_0$.

*Proof.*
* (i), the denominator. Divide numerator and denominator by $\nu(h_n)$. The weights become $2^{-\lambda\ell(\pi)}\Lambda_n(\pi)$, and the denominator is at least $W_\lambda$.
* (i), the non-equivalent mass. For any $L$,
  $$\sum_{\pi\notin E}2^{-\lambda\ell(\pi)}\Lambda_n(\pi)\ \le\ \sum_{\pi\notin E,\ \ell(\pi)\le L}2^{-\lambda\ell(\pi)}\Lambda_n(\pi)\ +\ Z^L_n,$$
  using $2^{-\lambda\ell}\le2^{-\ell}$.
  * The finite sum tends to 0 a.s., by Lemma 2.1(b).
  * Choose $L_j$ with $t_{L_j}\le4^{-j}$. Lemma 2.2(b) gives $\Prob[\sup_nZ^{L_j}_n\ge2^{-j}]\le2^{-j}$. By Borel–Cantelli, a.s. $\sup_nZ^{L_j}_n<2^{-j}$ for all large $j$.
  * Hence $\limsup_n\sum_{\pi\notin E}2^{-\lambda\ell}\Lambda_n\le2^{-j}$ for all large $j$, so the limit is 0.
* (i), the limit law. The denominator therefore tends to $W_\lambda$, and the E-terms are constant.
* (ii) The same argument, with weights $2^{-\ell}\Lambda_n^\eta$. For π ∉ E, $\Lambda_n\to0$ a.s. by Lemma 2.1(b), hence $\Lambda_n^\eta\to0$. Lemma 2.2(b) for $\Lambda^\eta$ handles the tail. (A m9: notes.md cited Lemma 2.1(c) here, which gives only expectations.)
* (iii) $W_\lambda2^{\lambda\ell_0}=\sum_E2^{-\lambda(\ell-\ell_0)}\le\sum_E2^{-(\ell-\ell_0)}=W_12^{\ell_0}$, since $\ell\ge\ell_0$ on $E$. Equality holds iff no program in E is longer than $\ell_0$. ∎

**Refuted (brief, T1, second bullet as written): "the power posterior and the tempered posterior concentrate on that set", read as $E_0$.**
* *Counterexample.* Any class with two programs for ν, of lengths 5 and 7, as in i1. Then $w_\lambda=2^{-5\lambda}/(2^{-5\lambda}+2^{-7\lambda})$, which is 0.889 at λ = 1.5 and 0.941 at λ = 2. The tempered posterior's limit is $w_1=0.8$ for every η.
* Computed exactly: $\Ex\Pi_{1.5}(E_0\mid h_{400})=0.8889$ and $\Ex\Pi_2(E_0\mid h_{400})=0.9412$; the tempered posterior gives 0.8000 [computed: i1(C)].
* In a canonical class every program has infinitely many equivalent padded versions, so $w_\lambda<1$ always. The correct statement is Theorem 3.2: concentration on $E$, with the prior's shape inside $E$.
* Only the MAP singles out $E_0$. A larger λ moves more of the limiting mass onto $E_0$.

**Proposition 3.3 (identification on the run, for every λ ≥ 1, any input rule, PQ or FR) [proved; from Referee B's B1].**
* *Setting.*
  * $\mathcal C$ is countable with Kraft sum ≤ 1. It contains a program $\pi_\nu$ of length $k$ whose kernel equals ν at every input the rule can query. In FR with i.i.d. inputs on a countable $X$, any $\pi_0\in E_0$ qualifies, with $k=\ell_0$, because μ-a.e. equality is equality on the support.
  * Inputs are chosen by any rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn: adaptive, randomised, non-computable or i.i.d.
  * Labels are fresh per query (likelihood $\nu_\pi(h_n)$), or frozen on distinct inputs. In the frozen case the process is indexed by distinct inputs, and FR is such a rule (Def 1.3).
* *The random set $K$.* π is **ν-equivalent on the run** if $\sum_ig_i(\pi)<\infty$, where $g_i(\pi):=\Hel(\nu(\cdot\mid x_i),\nu_\pi(\cdot\mid x_i))$ and the sum runs over the queries (PQ) or the distinct inputs (FR). $K$ is the random set of such programs. Note that $\pi_\nu\in K$.
* *Claim.* Fix λ ≥ 1. Almost surely:
  * (a) the λ-MAPs have bounded length, uniformly in $n$;
  * (b) there is $n_0$ such that for $n\ge n_0$ every λ-MAP is in $K$;
  * (c) $\Pi_\lambda(\mathcal C\setminus K\mid\text{data}_n)\to0$.
* *Two special cases.*
  * In PQ with i.i.d. inputs, $K=E$ almost surely. For π ∉ E, $\sum_ig_i=\infty$ a.s. by the strong law, since $g_i\in[0,1]$ has mean $\Hel_\mu(\pi)>0$. For π ∈ E, $g_i=0$ a.s. Then use countability.
  * In FR with i.i.d. inputs and $\mathrm{supp}\,\mu$ infinite, the run of distinct inputs eventually enumerates $\mathrm{supp}\,\mu$. So $K=\{\pi:\sum_{x\in\mathrm{supp}\,\mu}\Hel(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))<\infty\}$, a deterministic set.

*Proof.* Write $\Lambda_n(\pi)$ for the likelihood ratio along the run.
* (a) This is Step 1 of Theorem 3.1 with $k$ in place of $\ell_0$.
  * A λ-MAP $\hat\pi$ has $J_\lambda(\hat\pi)\le J_\lambda(\pi_\nu)$. Since $\nu_{\pi_\nu}=\nu$ on the run, this gives $\log\Lambda_n(\hat\pi)\ge\lambda(\ell(\hat\pi)-k)$.
  * For $L\ge k$ and $\ell(\hat\pi)>L$, it gives $\log\Lambda_n(\hat\pi)\ge\ell(\hat\pi)-k$, so $Z^L_n\ge2^{-k}$.
  * $Z^L$ is a nonnegative supermartingale started at $t_L$ under any such rule (Lemma 2.2(b),(c)). So $\Prob[\exists n:Z^L_n\ge2^{-k}]\le2^kt_L$.
  * These events decrease in $L$ and their probabilities tend to 0.
* (b) Kakutani step [known in Paper 2: `app:split:private`(iv)].
  * Fix π. Given the past and $x_{n+1}$, $\Ex\sqrt{\Lambda_{n+1}/\Lambda_n}=\sum_{y:\nu>0}\sqrt{\nu(y\mid x_{n+1})\nu_\pi(y\mid x_{n+1})}=1-g_{n+1}$. Here $g_{n+1}$ is determined before $y_{n+1}$ is drawn.
  * If $g_{n+1}=1$, then a.s. $\Lambda$ is 0 from then on. Otherwise $M_n:=\sqrt{\Lambda_n}/\prod_{i\le n}(1-g_i)$ is a nonnegative supermartingale, so it converges a.s.
  * On $\{\sum_ig_i=\infty\}$, $\prod_{i\le n}(1-g_i)\to0$, so $\Lambda_n(\pi)\to0$.
  * By countability, a.s. simultaneously for all π ∉ K, $\Lambda_n(\pi)\to0$.
  * On this event and that of (a), the MAPs lie in the finite set $\{\ell\le L_0\}$. A MAP has $\log\Lambda_n(\hat\pi)\ge\lambda(\ell(\hat\pi)-k)\ge-\lambda k$. Each π ∉ K in the finite set eventually has $\Lambda_n(\pi)<2^{-\lambda k}$, so eventually none of them is a MAP.
* (c) Divide by $\nu$ of the data. The normaliser is at least $\pi_\nu$'s weight $2^{-\lambda k}$. For every $L$,
  $$\Pi_\lambda(\mathcal C\setminus K\mid\cdot)\ \le\ 2^{\lambda k}\Big[\sum_{\pi\notin K,\ \ell(\pi)\le L}2^{-\lambda\ell(\pi)}\Lambda_n(\pi)+Z^L_n\Big].$$
  The finite sum tends to 0. Choose $t_{L_j}\le4^{-j}$. By Lemma 2.2(b) and Borel–Cantelli, a.s. $\sup_nZ^{L_j}_n<2^{-j}$ for all large $j$. So the lim sup is at most $2^{\lambda k-j}$ for every large $j$. ∎

*Remarks.*
* **`thm:split:private`(iv) holds at λ = 1.** Its proof uses λ > 1 only through the Ville length bound (i), which confines the MAPs to a finite set. Part (a) replaces that bound. The same holds for the posterior part, which uses only (ii) of that theorem for the tail, and $Z^L$ does that job here. *Flag for the Paper 2 restructure:* state `thm:split:private`(iv) for λ ≥ 1, and do not suggest in the opening of `sec:split` that λ = 1 fails in the limit. What fails at λ = 1 is the posterior *odds* at finite $n$ (`thm:split:lambda1`).
* **Consequences.**
  * In FR, λ = 1 and λ > 1 achieve the same asymptotic identification: on the run, and nothing beyond it (Prop 7.5).
  * The fill-ins' posterior at λ = 1 tends to 0 in Paper 2's own distinct-input setting whenever $\sum_n\beta_{x_n}=\infty$, with $\beta_x:=1-\max_y\nu(y\mid x)$ (Prop 7.6(b)). This is consistent with `thm:split:lambda1`(ii). Its lower bound $2^{-k-2\log(t_n+1)-\kappa-\delta^*}$ decays like $(\log d_n)^{-2}$, and $d_n\to\infty$ on distinct inputs in $\{0,1\}^*$.
* **Evidence** [computed: rB3(E)]. At λ = 1, 1857 of 2000 PQ runs have the 1-MAP in $E_0$ at every $n\in[1000,2000]$.

**Proposition 3.4 (λ = cn, PQ) [proved; computed: i1(D), i8(B), rB7(A)].** Let $\lambda_n=cn$ with $c>0$.
* Put $R(\pi):=\Ex[-\log\nu_\pi(y\mid x)]\in[0,\infty]$, the population risk under the true channel. Then $R(\pi)=H_\mu(\nu)+D(\pi)$, with $H_\mu(\nu):=\Ex_\mu H(\nu(\cdot\mid x))\le\log|Y|$.
* Put $J_c(\pi):=c\ell(\pi)+R(\pi)$.
* Put $c^*:=\min\{D(\pi)/(\ell_0-\ell(\pi)):\ell(\pi)<\ell_0\}>0$ (a minimum over finitely many positive numbers; $c^*:=+\infty$ if no program is shorter than $\ell_0$).

Then:
* **(a) Failure above $c^*$.** If $c>c^*$, that is, if some π′ has $\ell(\pi')<\ell_0$ and $D(\pi')<c(\ell_0-\ell(\pi'))$, then almost surely no program of $E_0$ is a cn-MAP for all large $n$.
* **(b) Recovery below $c^*$.** If $c<c^*$, then almost surely the set of cn-MAPs equals $E_0$ for all large $n$.
* **(c) In general.** Let $A_c:=\arg\min_\pi J_c(\pi)$. It is nonempty and finite. Almost surely, every cn-MAP is in $A_c$ for all large $n$. If all programs in $A_c$ have the same kernel μ-a.e., then the set of cn-MAPs equals $A_c$ for all large $n$.
* (c) holds in every countable Kraft class, also when ν ∉ $\mathcal C$, provided $\min J_c<\infty$. It does not need the class to be finite (`../teacher/referee-A.md` m7).

*Proof.*
* (a) $\frac1n[J_{cn}(\pi_0)-J_{cn}(\pi')]=c(\ell_0-\ell(\pi'))+\frac1n\log\Lambda_n(\pi')\to c(\ell_0-\ell(\pi'))-D(\pi')>0$, by Lemma 2.1(b).
* (c)
  * *$A_c$ exists.* $J_c(\pi)\ge c\ell(\pi)$, so only finitely many programs have $J_c\le J_c(\pi_1)$ for any π₁ with $J_c(\pi_1)<\infty$.
  * *Notation.* Put $\hat R_n(\pi):=L_n(\pi)/n$, so $J_{cn}(\pi)/n=c\ell(\pi)+\hat R_n(\pi)$. By the strong law for nonnegative i.i.d. variables (possibly with infinite mean) [known], a.s. $\hat R_n(\pi)\to R(\pi)$ simultaneously for all π.
  * *Bounded candidate set.* Fix $\pi_c\in A_c$. A cn-MAP $\hat\pi$ has $cn\,\ell(\hat\pi)\le J_{cn}(\pi_c)$. So $\ell(\hat\pi)\le\ell(\pi_c)+\sup_n\hat R_n(\pi_c)/c=:L_0$, which is a.s. finite because $\hat R_n(\pi_c)$ converges to the finite $R(\pi_c)$.
  * *The finitely many candidates.* For π ∉ $A_c$ with $\ell(\pi)\le L_0$, $J_{cn}(\pi)/n\to J_c(\pi)>J_c(\pi_c)$, possibly $+\infty$, while $J_{cn}(\pi_c)/n\to J_c(\pi_c)$. So π is eventually not a MAP. There are finitely many such π.
  * *Ties inside $A_c$.* If the members of $A_c$ share one kernel μ-a.e., they have equal $R$, hence equal lengths, and a.s. equal likelihoods at every $n$. So they tie, and all of them are MAPs eventually.
* (b) From (c).
  * $J_c(\pi)-J_c(\pi_0)=c(\ell(\pi)-\ell_0)+D(\pi)$ for $\pi_0\in E_0$.
  * For π ∈ E this is $\ge0$, with equality iff π ∈ $E_0$.
  * For π ∉ E with $\ell(\pi)\ge\ell_0$ it is $>0$.
  * For π ∉ E with $\ell(\pi)<\ell_0$ it is $D(\pi)-c(\ell_0-\ell(\pi))>0$ when $c<c^*$.
  * So $A_c=E_0$, whose members share the kernel ν μ-a.e. ∎

*Reading.*
* With λ = cn, selection follows the population hull of the points $(\ell(\pi),R(\pi))$ (`lem:setup:hull`): the cn-MAP tends to the vertex of slope $c$. notes.md stated this without proof (A m6); (c) proves it.
* The truth's interval is $c\in(0,c^*)$. That is the teacher's regime of Paper 2, not exact recovery for every $c$.
* At $c=c^*$ a shorter program ties the truth in population, and nothing is claimed.
* [computed: i1(D), i8(B)] In i1's class $c^*=0.1348$, attained by the coin. The exact $\Prob[\text{cn-MAPs}=E_0]$ at $n=25,\dots,400$ rises to 1.0000 (c = 0.05) and 0.9887 (c = 0.10), and falls to 0.1529 (c = 0.15) and 0.0000 (c = 0.20). rB7(A): at $n=10^5$ the cn-MAP equals the population minimiser in 200 of 200 runs for every $c$ on a grid across $c^*$.

---

## 4. What λ > 1 adds: uniform and explicit guarantees (PQ)

**Theorem 4.1 (fixed λ > 1) [proved; computed: i1(A), i2(B), i4(B), i6, i8(A), rB1(2), rB3(B)–(D), rB8].** In the setting of Definitions 1.1–1.2, fix λ > 1, and define $\delta_n$ and δ* by Lemma 2.2. For a set $A$ of programs, $\Pi_\lambda(A\mid h_n)$ is its power-posterior mass. Put $\gamma_L:=\min\{\Hel_\mu(\pi):\pi\notin E,\ \ell(\pi)\le L\}$.
* **(i) Length, for all n.** Every λ-MAP has
  $$\ell(\hat\pi)\le\frac{\lambda\ell_0+\delta_n}{\lambda-1}\le\frac{\lambda\ell_0+\delta^*}{\lambda-1}=\ell_0+\frac{\ell_0+\delta^*}{\lambda-1}.$$
  More generally, every π with $J_\lambda(\pi)\le J_\lambda(\pi_0)$ satisfies this.
* **(ii) Posterior length tail, for all n.** $\Pi_\lambda(\{\ell>L\}\mid h_n)\le2^{\lambda\ell_0+\delta^*-(\lambda-1)L}$.
* **(iii) Fill-ins, for all n.**
  * A deterministic program consistent with the data has $\ell\ge S_n-\delta^*$.
  * $\Pi_\lambda(\det\mid h_n)\le2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)S_n}$, and $\Pi^{1/\lambda}(\det\mid h_n)\le2^{\ell_0+\delta^*-(1-1/\lambda)S_n}$.
  * With i.i.d. inputs, $S_n/n\to H_\mu(\nu)$ a.s. So if $H_\mu(\nu)>0$, the fill-ins' posterior decays exponentially in $n$, almost surely. If $H_\mu(\nu)=0$, then E may contain fill-ins and no decay is claimed (A m12).
* **(iv′) Finite sample, free exponent (the primary form).** For every $n$ (and every λ > 0),
  $$\Prob\big[\text{the set of λ-MAPs at }n\ne E_0\big]\ \le\ \sum_{\pi\notin E}\ \inf_{0<s\le1}2^{-s\lambda(\ell(\pi)-\ell_0)}\rho_s(\pi)^n .$$
  * With $s=1/\lambda$ for every π, this gives $\sum_{\pi\notin E}2^{\ell_0-\ell(\pi)}\rho_{1/\lambda}(\pi)^n\le2^{\ell_0}\sup_{\pi\notin E}\rho_{1/\lambda}(\pi)^n$, which needs no length cut-off (A m14). It is useful when the margin holds over all wrong programs, as in the parity classes of Prop 5.1.
  * With $s=1/\lambda$ for $\ell(\pi)\le L$ and $s=1$ above, it gives
    $$\sum_{\pi\notin E,\ \ell(\pi)\le L}2^{\ell_0-\ell(\pi)}\rho_{1/\lambda}(\pi)^n+2^{\lambda\ell_0-(\lambda-1)L}t_L.$$
* **(iv) Finite sample, margin form.** For every $n$ and every $L\ge\ell_0$,
  $$\Prob\big[\text{the set of λ-MAPs at }n\ne E_0\big]\ \le\ 2^{\lambda\ell_0-(\lambda-1)L}+\sum_{\pi\notin E,\ \ell(\pi)\le L}2^{\ell_0-\ell(\pi)}\rho_{1/\lambda}(\pi)^n\ \le\ 2^{\lambda\ell_0-(\lambda-1)L}+2^{\ell_0}e^{-a_Ln},$$
  where $a_L:=2\min(1,\lambda-1)\gamma_L/\lambda$.
  * **The margin is automatic.** $\gamma_L>0$, as a minimum of finitely many positive numbers. A *margin condition* is an explicit lower bound $\gamma\le\gamma_L$.
  * **The sample size.** Put $L_\varepsilon:=\lceil(\lambda\ell_0+\log(2/\varepsilon))/(\lambda-1)\rceil$ and take $\gamma\le\gamma_{L_\varepsilon}$. Then the probability is at most ε for every
    $$n\ \ge\ n(\lambda,\ell_0,\gamma,\varepsilon):=\Big\lceil\frac{\lambda\,(\ell_0+\log(2/\varepsilon))\ln2}{2\min(1,\lambda-1)\,\gamma}\Big\rceil .$$
  * This is a statement for each $n$ separately. The simultaneous version is (v) (A m4).
* **(v) Uniformly in time.** $\Prob[\exists n\ge n_0:\ \text{MAPs}\ne E_0]\le2^{\lambda\ell_0-(\lambda-1)L}+2^{\ell_0}e^{-a_Ln_0}(1+1/a_L)$. So it suffices that $n_0\ge(\ell_0\ln2+\ln(2/\varepsilon)+\ln(1+1/a))/a$, with $a:=2\min(1,\lambda-1)\gamma/\lambda$ and $\gamma\le\gamma_{L_\varepsilon}$.
* **(vi) Posterior, finite sample.** For every $n$, every $L$ and ε ∈ (0, 1), with probability at least 1 − ε,
  $$\Pi_\lambda(\mathcal C\setminus E\mid h_n)\ \le\ 2^{\lambda\ell_0}\Big[\Big(\frac2\varepsilon\sum_{\pi\notin E,\ \ell(\pi)\le L}2^{-\ell(\pi)}\rho_{1/\lambda}(\pi)^n\Big)^\lambda+2^{\log(2/\varepsilon)-(\lambda-1)L}\Big]\ \le\ 2^{\lambda\ell_0}\Big[(2/\varepsilon)^\lambda e^{-\lambda a_Ln}+2^{\log(2/\varepsilon)-(\lambda-1)L}\Big].$$
  The first, Rényi, form is new (B b6). The second is that of notes.md.
* **(vii) Tempered tail.** For η ∈ (0, 1), $\Pi^\eta(\{\ell>L\}\mid h_n)\le2^{\ell_0+\eta\delta^*}t_L^{1-\eta}$. This depends on the class's prior tail $t_L$, not only on $\ell_0$ and $L$.

*Proof.*
* (i) A program with $J_\lambda(\pi)\le J_\lambda(\pi_0)$ has $\lambda(\ell(\pi)-\ell_0)\le\log\Lambda_n(\pi)\le\ell(\pi)+\delta_n$, by Lemma 2.2(a). Then use $\delta_n\le\delta^*$.
* (ii) $\sum_{\ell>L}2^{-\lambda\ell}\Lambda_n\le2^{-(\lambda-1)L}\sum_\pi2^{-\ell}\Lambda_n\le2^{-(\lambda-1)L+\delta^*}$. The normaliser, divided by $\nu(h_n)$, is at least $2^{-\lambda\ell_0}$.
* (iii) As in `thm:split:private`(iii), with $W_{\det}\le\xi_{\mathcal C}\le2^{\delta^*}\nu(h_n)$.
  * A consistent deterministic π has $\Lambda_n(\pi)=2^{S_n}\le2^{\ell(\pi)+\delta^*}$.
  * $\sum_{\det}2^{-\lambda\ell}\Lambda_n\le2^{-(\lambda-1)(S_n-\delta^*)}\sum_{\det}2^{-\ell}\Lambda_n\le2^{-(\lambda-1)(S_n-\delta^*)+\delta^*}$, with normaliser at least $2^{-\lambda\ell_0}$.
  * Tempered: the fill-ins' weight is $\sum2^{-\ell}\Lambda_n^{1/\lambda}$, with $\Lambda_n^{1/\lambda}=2^{-(1-1/\lambda)S_n}\Lambda_n$ for consistent deterministic π. So it is at most $2^{-(1-1/\lambda)S_n+\delta^*}$, with normaliser at least $2^{-\ell_0}$.
  * $S_n/n\to H_\mu(\nu)$ by the strong law, since $0\le\Ex[-\log\nu(y\mid x)]\le\log|Y|$.
* (iv′)
  * Programs in $E\setminus E_0$ have $J_\lambda$ larger than $J_\lambda(\pi_0)$ by $\lambda(\ell-\ell_0)>0$, almost surely. So the event "MAPs ≠ $E_0$" is contained in the union over π ∉ E of $\{J_\lambda(\pi)\le J_\lambda(\pi_0)\}=\{\Lambda_n(\pi)\ge2^{\lambda(\ell(\pi)-\ell_0)}\}$.
  * For each π and each $s\in(0,1]$, Markov's inequality for $\Lambda_n^s$ and Lemma 2.1(a),(c) give probability at most $2^{-s\lambda(\ell(\pi)-\ell_0)}\rho_s(\pi)^n$.
  * Take the infimum over $s$ and a union bound.
  * For the second form, $\sum_{\ell(\pi)>L}2^{-\lambda(\ell(\pi)-\ell_0)}\le2^{\lambda\ell_0}2^{-(\lambda-1)L}\sum_{\ell>L}2^{-\ell}$.
* (iv) The event is contained in the event that some π ∉ E has $J_\lambda(\pi)\le J_\lambda(\pi_0)$.
  * If such π has $\ell(\pi)>L$, then by (i) $(\lambda-1)L<\lambda\ell_0+\delta^*$. By Lemma 2.2(a) this has probability at most $2^{\lambda\ell_0-(\lambda-1)L}$.
  * Otherwise use (iv′) with $s=1/\lambda$, Lemma 2.1(d) with $\min(s,1-s)=\min(1,\lambda-1)/\lambda$, and $\sum2^{-\ell}\le1$.
  * For the sample size: $L_\varepsilon$ makes the first term at most ε/2, and $n\ge n(\lambda,\ell_0,\gamma,\varepsilon)$ makes $2^{\ell_0}e^{-an}\le\varepsilon/2$. (By (iv′), the first term could even carry the factor $t_L$.)
* (v) The first term is already uniform in $n$, because δ* is a supremum. Sum the second over $n\ge n_0$: $\sum_{n\ge n_0}e^{-an}=e^{-an_0}/(1-e^{-a})\le e^{-an_0}(1+1/a)$.
* (vi) Split the non-equivalent mass at $L$.
  * Since λ ≥ 1, $\sum_{\pi\notin E,\ell\le L}2^{-\lambda\ell}\Lambda_n=\sum(2^{-\ell}\Lambda_n^{1/\lambda})^\lambda\le(\sum2^{-\ell}\Lambda_n^{1/\lambda})^\lambda$.
  * The inner sum has expectation $\sum2^{-\ell}\rho_{1/\lambda}^n$. By Markov's inequality it exceeds $2/\varepsilon$ times that with probability at most ε/2. Its expectation is at most $e^{-a_Ln}$.
  * The tail is at most $2^{\delta^*-(\lambda-1)L}$, and $\delta^*\le\log(2/\varepsilon)$ with probability at least 1 − ε/2.
  * The normaliser is at least $2^{-\lambda\ell_0}$.
* (vii) Hölder with exponents $1/\eta$ and $1/(1-\eta)$: $\sum_{\ell>L}2^{-\ell}\Lambda^\eta=\sum(2^{-\ell}\Lambda)^\eta(2^{-\ell})^{1-\eta}\le(2^{\delta^*})^\eta t_L^{1-\eta}$. The normaliser is at least $2^{-\ell_0}$. ∎

*Checks.*
* [computed: i1(A)] Exact enumeration in an 8-program class on two inputs (minimum gap 0.044). At every λ ∈ {1.25, 1.5, 2, 3} and $n\le400$, exact probability ≤ Rényi bound ≤ margin bound.
  * At λ = 2: exact $1.5\cdot10^{-4}$, Rényi $1.6\cdot10^{-3}$, margin $2.8\cdot10^{-2}$ at $n=160$.
  * At $n=400$: $2.0\cdot10^{-9}$, $3.1\cdot10^{-8}$ and $7.4\cdot10^{-7}$.
* [computed: i8(A)] In the same class, exact ≤ free-exponent bound ≤ Rényi bound at all 16 (λ, n) points, with λ ∈ {1, 1.5, 2, 3} and $n\le160$.
  * The free exponent gains a factor 1.0–2.7 for λ > 1.
  * At λ = 1 the gain is unbounded: at $n=160$ the bound is $1.2\cdot10^{-3}$, against a Rényi bound of 18.5 (Remark 4.7).
* [computed: rB1(2)] 300 random finite classes with sub-probability, deterministic, exception and coin kernels, and E-programs that differ from ν on a null input. Exact ≤ Rényi in all 12,600 rows, and Rényi ≤ margin in every row with λ > 1.
* [computed: rB3(B)] In a 583-program class, 2000 runs of 2000 queries, λ ∈ {1.25, 2, 4}. Thm 4.1(i)–(iii) hold at every $n$, with the current deficiency $\delta_n$.
* [computed: rB8] In the same class at λ = 2, $n=2000$, the free exponent lowers the bound from 0.110 to 0.0035, against an empirical 0.0030. At λ = 4, $n=800$, it lowers it from 0.045 to 0.0043.
* [computed: i2(B), i7] In the parity classes of Prop 5.1 the Rényi bound is $0.25\cdot2^{\ell_0-(1-1/\lambda)n}$ ($\mathcal C_k$) and $2^{\ell_0-2-(1-1/\lambda)n}$ ($\mathcal C_{k,M}$). The second is attained (rB2(C): ratio 1.000).

*Reading.*
* (i)–(iii) hold for every $n$, every countable class and every input law. They are the per-query form of `thm:split:private`(i)–(iii), with $\ell_0$ in place of $k$.
* (iv′)–(vi) are the requested finite-sample version. (iv′) is the primary form, and the margin form (iv) is a corollary.
* In the margin form, the margin enters only through the programs of length at most $L_\varepsilon\approx\lambda\ell_0/(\lambda-1)$. Longer programs are handled by the prior, which is what the steeper exponent buys (Remark 4.7).
* **Near-equivalent programs.** In classes with programs very close to ν, the margin form is vacuous.
  * In rB3's class $\gamma_{L_\varepsilon}=3.2\cdot10^{-14}$, so $n(\lambda,\ell_0,\gamma,0.05)\approx3\cdot10^{14}$. Yet for λ ∈ {2, 4} the empirical failure frequency is about 1% or less from $n\approx400$–800 on [computed: rB3(C)].
  * (iv′) with $s=1$ charges such a program $2^{-\lambda(\ell-\ell_0)}$, its prior weight raised to the power λ, instead of the margin. This is the per-program form of kink Thm 5.6 (near/far split).

**Remark 4.5 (the length bound (i) is attained) [proved; computed: i7(E), rB7(B)].**
* *Setting.* Take $\mathcal C_{k,M}$ of Prop 5.1: the fair coin of length $k$ and the $2^M$ parities on $M$ bits, of length $M+2$. Take integers $k$ and λ > 1 with $n:=\lambda(k-2)/(\lambda-1)\in\mathbb N$, and set $M:=n$.
* *Claim.* With probability $\prod_{i=1}^n(1-2^{-i})>0.2887$, the λ-MAP set is $\{\text{coin},\varphi\}$ for a parity φ of length
  $$\ell(\varphi)=\frac{\lambda k-2}{\lambda-1}=\frac{\lambda k+\delta_n}{\lambda-1}-\frac{\log(1+2^{2-k})}{\lambda-1}.$$
  So the bound of (i) with $\delta_n$ is attained up to $\log(1+2^{2-k})/(\lambda-1)\le2^{2-k}/((\lambda-1)\ln2)$ bits. With δ* ≥ $\delta_n$, the bound of (i) is at least as large.
* *Proof.*
  * If the $n\times n$ input matrix $A$ is invertible, exactly one parity φ is consistent with the labels.
  * Its objective is $J_\lambda(\varphi)=\lambda(n+2)$, and $J_\lambda(\text{coin})=\lambda k+n$. These are equal by the choice of $n$. All other parities have $J=\infty$.
  * The mixture is $\xi(h_n)=2^{-k}2^{-n}+2^{-(n+2)}$, so $\delta_n=\log(2^{-k}+1/4)$.
  * The probability that $A$ is invertible is $\prod_{i=1}^n(1-2^{-i})$. ∎
* *Computed.* At (k, λ) = (20, 2), (20, 1.5), (30, 3), (16, 1.25) and (40, 2) the parity lengths are 38, 56, 44, 72 and 78. The gap to the bound is between $5.2\cdot10^{-12}$ and $3.5\cdot10^{-4}$ bits [computed: i7(E)]. rB7(B) finds the same minima by simulation.
* *Reading.* The factor $1/(\lambda-1)$ in (i) is necessary, not only in recovery times (Prop 4.4(b)) but in the length bound itself (B b5).

**Remark 4.6 (the failure probability is not monotone in n) [computed: rB3(C), rB9].**
* In rB3's class at λ = 1, the probability that the MAP set is not $E_0$ falls from 0.142 ($n=200$) to 0.062 ($n=300$), rises to 0.157 ($n=600$), and falls to 0.0075 at $n=2000$. λ = 1.25 behaves alike.
* *Cause.* A partial fill-in, "ν, but label 1 at $x=7$". There $\nu(1\mid7)=15/16$ and $\mu(7)=0.046$. It gains $\log(16/15)$ bits per visit to $x=7$ and dies at the first label 0 there. So it wins with the largest probability at intermediate $n$.
* This is the per-query analogue of the frozen exception programs $e_j$ of Prop 7.6(d). Partial fill-ins at low-noise atoms are the typical medium-$n$ competitors in PQ.
* Recovery times should therefore be read through the uniform-in-time bound (v), or defined as the least $n$ *after which* the probability stays below ε, as in i2, i7 and rB2.

**Remark 4.7 (what λ > 1 buys in the finite-sample bound) [proved; computed: i8(A)].**
* *Rewriting (iv′).* Write it as
  $$\Prob[\text{MAPs}\ne E_0]\le2^{s\lambda\ell_0}\sum_{\pi\notin E}2^{-s\lambda\ell(\pi)}\rho_s(\pi)^n\quad\text{for each fixed }s\in(0,1].$$
* *λ > 1.* The choice $s=1/\lambda<1$ makes the prior factor $2^{-\ell(\pi)}$, which is Kraft-summable in every class. The likelihood factor $\rho_{1/\lambda}^n$ then decays at a rate set by the margin. That is (iv).
* *λ = 1.* Every $s<1$ leaves the prior factor $2^{-s\ell(\pi)}$. Its sum $Z(s):=\sum_\pi2^{-s\ell(\pi)}$ is finite in finite classes, and then (iv′) decays exponentially at λ = 1 too: in i1's class, 0.42 at $n=40$ and $1.2\cdot10^{-3}$ at $n=160$ [computed: i8(A)].
* In the parity class $\mathcal C_k$, $Z(s)=\infty$ for every $s<1$. The class has $2^m$ programs of length $m+2\lceil\log(m+1)\rceil+1$. Prop 5.1 shows that no bound in terms of $(\ell_0,\gamma,\varepsilon)$ exists there.
* So at λ = 1 the finite-sample rate is a property of the class, through $Z(s)$. At λ > 1 it depends only on $(\lambda,\ell_0,\gamma,\varepsilon)$.

**Proposition 4.2 (no finite-sample bound without a margin) [proved].**
* *Setting.* Let λ > 1 and $\ell_0\ge2$ with $\lambda(\ell_0-1)\ge9$, and let $N$ be any number. Take the two-program class of Prop 4.4(a) with Δ = $\ell_0$ − 1:
  * the truth Bern(1/2), of length $\ell_0$;
  * Bern(1/2 + ε′), of length 1, with ε′ so small that $0.083\,\lambda(\ell_0-1)/\Hel_\mu\ge N$.
* *Claim.* $\Prob[\text{MAP}\ne E_0\text{ at }n]\ge1-8.66/(\lambda(\ell_0-1))$ for every $n\le N$. So for every ε < 1 − 8.66/(λ($\ell_0$ − 1)), no sample size depending only on $(\lambda,\ell_0,\varepsilon)$ exists without a margin. The exact failure probability at $n_1$ is about 0.9 (rA1(A)), so the restriction on ε is a weakness of Chebyshev's inequality, not of the claim.
* *Proof.* Prop 4.4(a), proved below. The Kraft sum is $1/2+2^{-\ell_0}\le1$. ∎

**Proposition 4.3 (the margin in the canonical class is not computably bounded) [proved].**
* *Setting.* Let $Y=\{0,1\}$ and $\mathcal C=\Hcl{\times}$. Let ν be a computable sampler with $\nu(1\mid x)\in[\beta,1-\beta]$ for all $x$, for a rational β ∈ (0, 1/2]. Let $g:\mathbb N\to(0,1]$ be computable: $g(L)$ is a computable real, uniformly in $L$.
* *Claim.* Then $\gamma_L<g(L)$ for all sufficiently large $L$.

*Proof.*
* *The perturbations.* Let $\pi_0\in E_0$. Let τ be the flipped kernel, $\tau(1\mid x):=\nu_{\pi_0}(0\mid x)$ and $\tau(0\mid x):=\nu_{\pi_0}(1\mid x)$; it is lsc. If ν = Bern(1/2) μ-a.e., let τ := Bern(1/4) instead. Either way τ is lsc, and τ ≠ ν on a set of positive μ-measure. (Which case holds need not be decidable; the proof only uses that one of the two τ works.) For $j\ge1$ let $\nu_j:=(1-2^{-j})\nu_{\pi_0}+2^{-j}\tau$.
* *Each $\nu_j$ is in the class and wrong.* $\nu_j$ is an lsc conditional semimeasure, uniformly in $j$. It equals $(1-2^{-j})\nu+2^{-j}\tau\ne\nu$ on a set of positive μ-measure, so its programs are not in E. By closure under prefix-free simulation it has a program $\sigma\,\pi_0\,p_j$, where $p_j$ is a shortest $V$-program for $j$. So $\ell(\pi_j)\le\ell_0+K(j)+\kappa$.
* *Its gap is tiny.* μ-a.e., $\nu_j(\cdot\mid x)$ and $\nu(\cdot\mid x)$ are probability measures. Then $\Hel(P,Q)=\frac12\sum_y(\sqrt P-\sqrt Q)^2\le\frac12\sum_y(P-Q)^2/P$. With $|\nu_j-\nu|\le2^{-j}$ and ν ≥ β this gives $\Hel_\mu(\pi_j)\le2^{-2j}/\beta$.
* *A computable rational lower bound for g.* Approximate $g(L)$ to precisions $2^{-1},2^{-2},\dots$ until an approximation $a$ with $a\ge3\cdot2^{-i}$ appears, and put $g'(L):=a-2^{-i}$. This terminates because $g(L)>0$, and $g(L)/2\le g'(L)\le g(L)$ (A m8). Put
  $$h(m):=\Big\lceil\tfrac12\log\frac{2}{\beta g'(m+\ell_0+\kappa)}\Big\rceil+1 .$$
  This is computable, since $\lceil\frac12\log r\rceil$ is computable for rational $r>0$. Then $2^{-2h(m)}/\beta\le g'/8<g(m+\ell_0+\kappa)$.
* *Lengths are cheap.* Let $j(L):=\max\{j:K(j)\le L-\ell_0-\kappa\}$, so that $\ell(\pi_{j(L)})\le L$. For $m=L-\ell_0-\kappa$, $K(h(m))\le K(m)+\kappa_h\le2\log(m+1)+\kappa'_h\le m$ for all large $m$. So $j(L)\ge h(m)$.
* *Conclusion.* $\gamma_L\le\Hel_\mu(\pi_{j(L)})\le2^{-2h(m)}/\beta<g(L)$ for all large $L$. ∎

*Reading (and an open problem).*
* In the canonical class, (iv) gives no sample size computable from $(\lambda,\ell_0,\varepsilon)$.
* This is a weakness of the margin form, not obviously of the MAP. A near-equivalent $\pi_j$ beats $\pi_0$ only if $\log\Lambda_n(\pi_j)\ge\lambda(K(j)+\kappa)$. By (iv′) with $s=1$, the total probability of that is at most $\sum_j2^{-\lambda(K(j)+\kappa)}$, a constant that does not decrease with $n$.
* **[open]** A recovery-time bound for the canonical class that is computable from $(\lambda,\ell_0,\varepsilon)$ and a margin for programs "far" from ν. It should handle near-equivalent programs through their small likelihood fluctuations, of order $\sqrt n\,2^{-j}$ while $n\ll2^{2j}$. Kink Thm 5.6 and (iv′) with $s=1$ give a bound of the form "margin for far programs plus $W_{\rm near}$". That does not solve the problem, because $W_{\rm near}$ does not tend to 0 with $n$.

**Proposition 4.4 (the margin and the factor 1/(λ−1) are necessary; λ > 1 is not uniformly faster) [(a), (b) proved; (c) computed].**
* **(a) Margin: the factor 1/γ.**
  * *The class.* Two programs. The truth $\pi_0$ gives Bern(1/2) labels and has length $\ell_0$. The program π′ gives Bern(1/2 + ε′), $0<\varepsilon'\le1/10$, and has length $\ell_0-\Delta\ge1$ (Kraft), with $\lambda\Delta\ge9$. Then $\Hel_\mu(\pi')\in[\varepsilon'^2/2,2\varepsilon'^2]$.
  * *The claim.* For every
    $$n\ \le\ n_1:=\lambda\Delta(1-4\varepsilon'^2)\ln2/(4\varepsilon'^2),\qquad\text{in particular every }n\le0.083\,\lambda\Delta/\Hel_\mu(\pi'),$$
    the λ-MAP is π′ with probability at least $1-8.66/(\lambda\Delta)$.
  * *Comparison.* Theorem 4.1(iv) gives recovery by $n\approx0.35\,\lambda(\ell_0+\log(2/\varepsilon))/(\min(1,\lambda-1)\gamma)$. For λ ≥ 2 the dependence on γ is tight up to a constant factor and the ratio $\ell_0/\Delta$. The kink sub-track's Prop 5.8 gives the same conclusion on the KL scale, by Markov's inequality.
* **(b) The factor 1/(λ−1).** Work in the parity class $\mathcal C_k$ of Prop 5.1, with λ > 1.
  * For every $n$ with $(\lambda-1)n<\lambda(\ell_0-6-2\lceil\log(n+6)\rceil)$ (strict; A m3), the λ-MAP is a parity and the coin is not a λ-MAP, with probability at least 31/32.
  * By Thm 4.1(iv′), the λ-MAP is the coin with probability at least 1 − ε once $n\ge\lambda(\ell_0+\log(1/(4\varepsilon)))/(\lambda-1)$.
  * So the recovery time is $\Theta(\lambda\ell_0/(\lambda-1))$ up to logarithmic terms. The lower bound needs $\ell_0>6+2\lceil\log(n+6)\rceil$, so it applies while $\lambda-1\gtrsim\ell_02^{-\ell_0/2}$ (A m4).
  * Remark 4.5 shows the same factor in the length bound.
* **(c) λ > 1 delays recovery against shorter programs** [computed: i1(A), rB1(3); heuristic explanation].
  * If every wrong program is shorter than $\ell_0$, a shorter π loses only when $\log\Lambda_n(\pi)<-\lambda(\ell_0-\ell(\pi))$. Heuristically that takes about λ times as many samples.
  * [i1(A)] In the class of i1, whose dangerous competitors are all shorter, the exact $\Prob[\text{MAP}\ne E_0]$ at $n=80$ is 0.0063 at λ = 1, 0.0074 at λ = 1.5, 0.0090 at λ = 2 and 0.0137 at λ = 3.
  * [rB1(3)] Over random small classes at $n\in\{64,128\}$, λ = 2 has the larger exact failure probability in 300 of 592 (class, n) cases. This happens in 258 of 313 cases when the dominant λ = 1 competitor is shorter than $\ell_0$, and in 42 of 279 when it is longer.
  * The steeper prior helps against *longer* competitors, that is, fill-ins and memorisers. That is where λ = 1 has no class-free bound (Remark 4.7, §5).
* The necessity results (a) and (b) are shown in separate classes. The joint factor $1/(\min(1,\lambda-1)\gamma)$ is not shown to be necessary (A m4).

*Proof.*
* (a)
  * π′ is the MAP iff $\log\Lambda_n(\pi')>-\lambda\Delta$. Write $\log\Lambda_n(\pi')=\sum_iX_i$, with $X_i\in\{\log(1+2\varepsilon'),\log(1-2\varepsilon')\}$ equally likely.
  * *Mean.* $m=\frac12\log(1-4\varepsilon'^2)\ge-2\varepsilon'^2/((1-4\varepsilon'^2)\ln2)$.
  * *Variance.* $\Var X\le\log^2(1-2\varepsilon')\le4\varepsilon'^2/((1-2\varepsilon')^2\ln^22)$.
  * *Chebyshev.* For $n\le n_1$ we have $n|m|\le\lambda\Delta/2$. So
    $$\Prob[\textstyle\sum X_i\le-\lambda\Delta]\le\frac{4n\Var X}{(\lambda\Delta)^2}\le\frac{4(1+2\varepsilon')}{(1-2\varepsilon')\ln2\cdot\lambda\Delta}\le\frac{8.66}{\lambda\Delta}.$$
  * *The gap.* $\sqrt{1+u}+\sqrt{1-u}\le2-u^2/4$, since the even Taylor coefficients of $\sqrt{1+u}$ beyond the constant are negative. So $\Hel_\mu(\pi')=1-\frac12(\sqrt{1+2\varepsilon'}+\sqrt{1-2\varepsilon'})\ge\varepsilon'^2/2$. Also $\Hel_\mu\le\frac12\sum(P-Q)^2/P=2\varepsilon'^2$. Hence $n_1\ge0.96\ln2\,\lambda\Delta/(8\Hel_\mu)\ge0.083\lambda\Delta/\Hel_\mu$.
* (b)
  * Take $m=n+5$. The parity length is $\ell(m)=n+6+2\lceil\log(n+6)\rceil$. So $\lambda\ell(m)<\lambda\ell_0+n$ under the stated strict condition.
  * Such a parity is consistent whenever the $n\times(n+5)$ input matrix has rank $n$, which has probability at least $1-2^{-5}$.
  * The upper bound is Thm 4.1(iv′) with the Rényi sum $0.25\cdot2^{\ell_0-(1-1/\lambda)n}$ computed in Prop 5.1. ∎

[computed: rA1(A). Exact binomial values are at most 0.110 times the bound $8.66/(\lambda\Delta)$ on 30 cases; the constants 8.6562 and 0.08318 and the ratio $\min n_1/(0.083\lambda\Delta/\gamma)=1.0149$ check. i7(C): with the strict condition the minimum probability over the stated range is 0.9845 ≥ 31/32 for $k\in\{16,24,32\}$ and λ ∈ {1, 1.1, 1.5, 2, 3}.]

---

## 5. λ = 1: exact in the limit, with no class-free bound

**Proposition 5.1 (no recovery-time bound at λ = 1, PQ) [(a), (b), (b′), (c) proved; the table computed: i2, i7, rB2].**
* *Setting.* Inputs are uniform on $\{0,1\}^{D}$ ($D$ large). Labels are fresh per query from the fair coin ν = Bern(1/2). Two classes:
  * $\mathcal C_k$: the coin, of length $k$, and, for every $1\le m\le D$ and $w\in\{0,1\}^m$, the deterministic parity $f_{m,w}(x)=\langle w,x_{1:m}\rangle\bmod2$, of length $\ell(m)=m+2\lceil\log(m+1)\rceil+1$. The parities have Kraft weight 1/4 (A m5: $m\ge1$; with $m=0$ it would be 3/4), so the Kraft sum is $2^{-k}+1/4$.
  * $\mathcal C_{k,M}$: the coin (length $k$) and the $2^M$ parities on the first $M$ bits, each of length $M+2$. The Kraft sum is $2^{-k}+1/4$.
* *Margin.* $E=E_0=\{\text{coin}\}$ and $\ell_0=k$. Every parity has $\Hel_\mu=1-2^{-1/2}=0.293$. So the margin condition holds uniformly over **all** wrong programs.
* **(a)** In $\mathcal C_{k,M}$ with $k\ge8$, at $n:=M-5$, the 1-MAP is a parity with probability at least 31/32. So no function $n(1,\ell_0,\gamma,\varepsilon)$ bounds the recovery time at λ = 1, even with a uniform margin. For λ > 1 in the same class, $\Prob[\text{MAP}\ne\text{coin at }n]\le2^{k-2-(1-1/\lambda)n}$, whatever $M$ is.
* **(b)** In $\mathcal C_k$ at λ = 1, for every $n$ with $2\lceil\log(n+6)\rceil+6<k$ (strict; A m3), the 1-MAP is a parity and the coin is not a 1-MAP, with probability at least 31/32. Such $n$ go up to $2^{(k-8)/2}-6$ for even $k$.
* **(b′) Upper bound at λ = 1** (new). In $\mathcal C_k$, $\Prob[\text{set of 1-MAPs}\ne\{\text{coin}\}\text{ at }n]\le2^{k+1}/n^2$ for every $n\ge32$. Hence the recovery time $n_{\rm rec}(\varepsilon)$, the least $n$ after which this probability stays at most ε, satisfies
  $$2^{(k-8)/2}-6\ <\ n_{\rm rec}(\varepsilon)\ \le\ \max\big(32,\ \lceil2^{(k+1)/2}/\sqrt\varepsilon\,\rceil\big)\qquad(\varepsilon<31/32,\ k\text{ even}).$$
  At λ > 1 the recovery time is $\Theta(\lambda k/(\lambda-1))$ up to logarithms (Prop 4.4(b)).
* **(c)** Theorem 3.1 still holds in both classes at λ = 1: almost surely the 1-MAP is eventually the coin.

*Proof.*
* *When a parity is a MAP.* A parity on $m$ bits is consistent with the data iff the label vector $y$ lies in the column span of the $n\times m$ matrix $A$ of the first $m$ input bits. A parity on fewer bits is a parity on more bits (pad $w$ with zeros). So, with $m^*(n):=\max\{m\ge1:\lambda\ell(m)\le\lambda k+n\}$, the set of λ-MAPs differs from {coin} iff $y\in\mathrm{colspan}(A_{n\times m^*})$. That has probability $P(n)=\Ex[2^{\mathrm{rank}(A)-n}]\le2^{m^*-n}$.
* *(a), λ = 1.* The rows of $A$ are i.i.d. uniform in $\{0,1\}^M$. So $\Prob[\mathrm{rank}A<n]\le\sum_{i<n}2^{i-M}<2^{n-M}=2^{-5}$. When the rank is $n$, $y$ is in the span. That parity has $J_1=M+2=n+7<k+n=J_1(\text{coin})$.
* *(a), λ > 1.* Each fixed parity has $\rho_{1/\lambda}=2^{1/\lambda-1}$. Thm 4.1(iv′) with $s=1/\lambda$ gives the Rényi sum $2^k\cdot2^M2^{-M-2}\cdot2^{-(1-1/\lambda)n}$.
* *(b)* Take $m=n+5$. Then $\ell(m)=n+6+2\lceil\log(n+6)\rceil<k+n$ under the strict condition. Argue as in (a): with probability $\ge1-2^{-5}$ that parity is consistent, so it strictly beats the coin, and only parities remain as MAPs.
* *(b′)*
  * Let $n\ge32$. From $\ell(m^*)\le k+n$, we get $m^*-n\le k-1-2\lceil\log(m^*+1)\rceil$, so $P(n)\le2^{m^*-n}\le2^{k-1}/(m^*+1)^2$.
  * Lower bound on $m^*$. Put $m_1:=n+k-1-2\lceil\log(n+1)\rceil$.
    * If $1\le m_1\le n$, then $\ell(m_1)\le m_1+2\lceil\log(n+1)\rceil+1=n+k$, so $m^*\ge m_1$.
    * If $m_1>n$, then $\ell(n)<n+k$, so $m^*\ge n$.
    * For $n\ge32$, $m_1\ge n/2-1\ge1$, since $n/2\ge2\lceil\log(n+1)\rceil$ there.
  * So $m^*+1\ge n/2$ and $P(n)\le2^{k+1}/n^2$, which is decreasing in $n$.
  * The upper bound on $n_{\rm rec}$ follows. The lower bound is (b).
* *(c)* Thm 3.1. ∎

**Recovery times.** [computed: i7(A), exact on every integer $n$, certified]
* *Definition.* $n_{\rm rec}(0.01)$ is the least $n$ after which $\Prob[\text{MAP set}\ne\{\text{coin}\}]\le0.01$ at every $n$.
* *How it is certified.* The scan covers every integer up to the point where the bound $2^{m^*(n)-n}$, which is nonincreasing in $n$ for λ ≥ 1, falls below 0.01.
* *Agreement.* The values agree with referee B's independent scan (rB2(B)). They replace notes.md's grid values, given in brackets (B b1).

| $\ell_0=k$ | λ = 1 | λ = 1.1 | λ = 1.25 | λ = 1.5 | λ = 2 | λ = 3 |
|---|---|---|---|---|---|---|
| 16 | 1030 (1084) | 78 (88) | 46 (50) | 34 (38) | 23 (25) | 20 (22) |
| 24 | 16390 (17736) | 144 (153) | 76 (76) | 52 (58) | 38 (38) | 29 (29) |
| 32 | 262150 (290272) | 232 (233) | 116 (116) | 70 (76) | 51 (58) | 38 (38) |
| 40 | 4194310 (4750753) | 298 (308) | 146 (153) | 94 (101) | 67 (76) | 50 (50) |

* *λ = 1.* $n_{\rm rec}(0.01)=2^{(k+4)/2}+6$ exactly, for all four $k$ [computed]. It multiplies by exactly 16 for every 8 bits of $\ell_0$. The proved bounds (b), (b′) give $\Theta(2^{k/2})$.
* *λ > 1.* The recovery time grows linearly in $\ell_0$, with slope about $\lambda/(\lambda-1)$.
* *The decay at λ = 1.* For $n\ge2^{k/2+2}$ the ratio $P(n)\,n^2/2^{k-1}$ lies in [0.496, 0.992] up to the end of i7's scan, and in [0.249, 1.002] over the longer range of rB2(F). So $P\approx2^{k-1}/n^2$ within a factor 4 [computed]. The bound $P\le2^{k+1}/n^2$ of (b′) [proved] had no violation on any scanned $n\ge32$ [computed: i7(B)]. The decay is polynomial, not exponential.
* *Cross-checks.*
  * The closed-form rank law agrees with exact enumeration of all matrices ($nm\le16$) to $2.2\cdot10^{-16}$.
  * It agrees with a Monte Carlo that solves $Aw=y$ by Gaussian elimination (6 points, within 1.04 standard errors).
  * It agrees with i2's chain values to the printed digits [computed: i7(D1)–(D3)].
  * $P(n)$ is nonincreasing in $n$ up to $3\cdot10^{-16}$ in all four classes at λ = 1.

**Lemma 5.2 (a single short fill-in; DS) [proved; computed: i5, rA1(F)].**
* *Setting.*
  * The class is $\Hcl{\times}$, or the class of deterministic programs of $W$; $Y$ is finite.
  * $\pi_\nu$ is a program, in $\Hcl{\times}$, or a $V$-program for an index, of a computable conditional **measure** equal to ν on all inputs of length at most $d$. Its length is $k_\nu$ (Def 1.2; A M2).
  * $D$ is a data set with $n$ distinct inputs of length at most $d$, with $\nu(D)>0$. Put $R:=\lceil-\log\nu(D)\rceil$.
* *Claim.* There is a deterministic program in the class, consistent with $D$, of length
  $$\ell\ \le\ k_\nu+R+\log n+\log(d+1+\log|Y|)+2\log(n+1)+2\log(d+1)+2\log(R+1)+\kappa\ \le\ k_\nu-\log\nu(D)+3\log(n+1)+3\log(d+2+\log|Y|)+2\log(R+1)+\kappa .$$

*Proof.*
* *Candidate data sets.* Given $(\pi_\nu,n,d,R)$, compute for every data set $D'$ with $n$ distinct inputs of length at most $d$ a rational $q(D')$ with $|q(D')-\nu(D')|\le2^{-R-2}$. This is possible because the kernel of $\pi_\nu$ is a computable measure on these inputs. Let $\mathcal D_R:=\{D':q(D')\ge2^{-R-1}\}$.
  * Every $D'\in\mathcal D_R$ has $\nu(D')\ge2^{-R-2}$.
  * $D\in\mathcal D_R$, since $\nu(D)\ge2^{-R}$.
  * $|\mathcal D_R|\le A:=2^{n(d+1+\log|Y|)}$.
* *A covering family exists.* Let $M:=\lfloor2^{R+2}n(d+1+\log|Y|)\rfloor+1>2^{R+2}\ln A$. Draw $M$ i.i.d. random total functions $f_j\sim\nu$ on the inputs of length at most $d$, with one independent label per input. For each $D'\in\mathcal D_R$, $\Prob[\text{no }f_j\supseteq D']\le(1-2^{-R-2})^M<e^{-M2^{-R-2}}<1/A$. By the union bound, some family $(f_1,\dots,f_M)$ of finite tables extends every $D'\in\mathcal D_R$.
* *The program.*
  * The first such family in a fixed enumeration of $M$-tuples of tables is computable from $(\pi_\nu,n,d,R)$, because coverage of the computable finite set $\mathcal D_R$ is decidable.
  * The program reads $\pi_\nu$ (by simulating $V$), codes of $n$, $d$ and $R$, and then $\lceil\log M\rceil$ bits naming $j$. It outputs an index of the deterministic function $f_j$, undefined on longer inputs.
  * By closure under prefix-free simulation it is a member of the class.
  * Its length is $|\sigma|+k_\nu+\sum(2\log(\cdot+1)+1)+\lceil\log M\rceil$, with $\lceil\log M\rceil\le R+4+\log n+\log(d+1+\log|Y|)$. ∎
* *Why $k_\nu$ and not $\ell_0$.* With a decoder that is defective at one candidate input, computing $q(D')$ need not halt. Then $\mathcal D_R$ is only c.e., and "the first covering family" is not computable. The stream lemma does not have this problem (Def 1.2), but its cost is a total weight, not a single program.

[computed: i5(A). On four tiny instances (up to 7 inputs and 280 candidate data sets), random families of the lemma's size $M$ (193 to 3073) covered $\mathcal D_R$ in 400 of 400 trials. Families of size 16–64 already covered with probability at least 1/2, so the union bound is loose by a factor 10–50. i5(B): the overhead is 65 bits at $n=10^3,d=20$; 122 bits at $n=10^6,d=100$; and 233 bits at $n=10^{12},d=1000$. The total-weight cost of `lem:split:stream` at the same sizes is 5.6–7.2 bits. rA1(F): $\lceil\log M\rceil$ is at least 1 bit below its stated bound on a grid.]

**Proposition 5.3 (what the λ = 1 MAP is, object by object) [proved; (d) from Paper 2].**
* **(a) PQ.**
  * The 1-MAP is eventually in $E_0$, almost surely (Thm 3.1). It is not a fill-in forever. The brief's "λ = 1 never makes the split exact" is **[refuted]** in PQ, as an asymptotic statement about the MAP.
  * The finite-$n$ contrast is real: no class-free recovery time exists (Prop 5.1, Remark 4.7).
* **(a′) FR (A m6, B B1).**
  * No procedure is exact for every sampler, for any λ (Prop 7.5). So the brief's sentence is true in FR, but it does not separate λ = 1 from λ > 1.
  * Both achieve identification on the run (Prop 3.3, Prop 7.6(a)).
* **(b) DS: the length of a fill-in 1-MAP.** Let $D$ be a data set with distinct inputs. Put $S:=-\log\nu(D)$ and $\delta(D):=\log(\xi_{\mathcal C}(D)/\nu(D))$. If the 1-MAP $\hat\pi$ is a fill-in (deterministic and consistent), then:
  * $\ell(\hat\pi)\ge S-\delta(D)$, for every $D$. Indeed $1=\nu_{\hat\pi}(D)\le2^{\ell(\hat\pi)}\xi_{\mathcal C}(D)$.
  * $\ell(\hat\pi)\le\ell_0+S$ whenever some $\pi_0\in E_0$ has $\nu_{\pi_0}(D)=\nu(D)$, because then $J_1(\hat\pi)\le J_1(\pi_0)$. This holds a.s. for sampled data in PQ and FR, and for every $D$ whose inputs lie where $\nu_{\pi_0}=\nu$ (A m11). It need not hold for an arbitrary $D$.

  So its length is about the sampled randomness.
* **(c) DS: the best single fill-in against the sampler, in $\Hcl{\times}$.** Let $D$ have $n$ distinct inputs of length at most $d$. Let $\varphi^*$ be a shortest consistent deterministic program. Name both comparison programs (A M2):
  * against $\pi_\nu$ of length $k_\nu$ (a measure on $\{0,1\}^{\le d}$),
    $$-k_\nu-\delta(D)\ \le\ J_1(\varphi^*)-J_1(\pi_\nu)\ \le\ 3\log(n+1)+3\log(d+2+\log|Y|)+2\log(R+1)+\kappa;$$
  * against $\pi_0\in E_0$, when $\nu_{\pi_0}(D)=\nu(D)$,
    $$-\ell_0-\delta(D)\ \le\ J_1(\varphi^*)-J_1(\pi_0)\ \le\ (k_\nu-\ell_0)+3\log(n+1)+3\log(d+2+\log|Y|)+2\log(R+1)+\kappa.$$

  The lower ends are (b). The upper ends are Lemma 5.2. So at λ = 1 the sampler and its best single fill-in are tied up to $k_\nu+\delta(D)$ bits one way and $O(\log n+\log d+\log S)$ the other. Which one is the 1-MAP at a given $n$ depends on these terms, that is, on the reference machine.
  * notes.md stated the lower end as $-\ell^*-\delta^*$ against $\pi_\nu$. That is false in general: rA1(E) gives a toy class where the value is −7 against a stated bound of −2.32. The $k_\nu$ form holds there (−11.32).
  * In $\mathcal C_k$ the 1-MAP is a fill-in for $n$ up to about $2^{(k-8)/2}$ (Prop 5.1).
* **(d) The fill-ins' posterior at λ = 1.**
  * On data sets with distinct inputs (FR or DS), `thm:split:lambda1`(ii) gives a lower bound $2^{-k-2\log(t_n+1)-\kappa-\delta^*}$. Here $k$ may be taken as $\ell_0$ on sampled data, since the stream lemma transfers (Def 1.2).
  * Since $t_n\approx\log(2d_n)$, this decays no faster than about $(\log d_n)^{-2}$ in the input length.
  * In FR it tends to 0 when $\sum_n\beta_{x_n}=\infty$ (Prop 7.6(b), λ ≥ 1). On a finite support the data set stops changing, and the mass is eventually a fixed positive number.
  * In PQ it tends to 0 a.s. when $H_\mu(\nu)>0$ (Thm 3.2). On an atomic μ, deterministic fill-ins die at the first repeated input whose labels disagree.
  * At λ > 1 it decays like $2^{-(\lambda-1)S_n}$ for all $n$ (Thm 4.1(iii)).

So the honest contrast between λ = 1 and λ > 1 is quantitative in both objects, and large:

| | λ = 1 | λ > 1 |
|---|---|---|
| MAP set $=E_0$ eventually (PQ, i.i.d.) | yes, a.s. (Thm 3.1) | yes, a.s. (Thm 3.1) |
| MAP ν-equivalent on the run eventually (any input rule; PQ or FR) | yes, a.s. (Prop 3.3) | yes, a.s. (Prop 3.3, `thm:split:private`(iv)) |
| exact recovery in FR | impossible for every procedure (Prop 7.5) | impossible for every procedure (Prop 7.5) |
| MAP length bound, all $n$ | only $\Prob[\exists n:\ell>L]\le2^{\ell_0}t_L$ (class tail) | $\ell_0+(\ell_0+\delta^*)/(\lambda-1)$, attained (Remark 4.5) |
| finite-sample failure bound (PQ) | needs $\sum_\pi2^{-s\ell(\pi)}<\infty$ for some $s<1$ (Remark 4.7) | $n(\lambda,\ell_0,\gamma,\varepsilon)=O(\lambda\ell_0/(\min(1,\lambda-1)\gamma))$ |
| recovery time in $\mathcal C_k$ (uniform margin 0.293) | $\Theta(2^{\ell_0/2})$ (Prop 5.1) | $\Theta(\lambda\ell_0/(\lambda-1))$ up to logs (Prop 4.4(b)) |
| fill-ins' posterior | $\ge2^{-\ell_0-O(\log\log d_n)-\delta^*}$ on distinct inputs; → 0 in the limit | $\le2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)S_n}$, all $n$ |
| best single fill-in vs sampler (DS) | tie up to $k_\nu+\delta$ and $O(\log nd)$ | fill-in loses once $(\lambda-1)S>\lambda(\ell_0+\delta^*)$ |

---

## 6. Corollaries

**Corollary 6.1 (noisy computable functions) [(i)–(v) proved; (vi) proved lower bound and computed: i4, i8(D), rB6, rA1(B)].**
* *Setting.* $Y=\{0,1\}$; $f:X\to\{0,1\}$ is total computable; $p\in[0,\frac12]$ is computable; $\nu_{f,p}(y\mid x):=1-p$ if $y=f(x)$ and $p$ otherwise. $\mathcal C$ is any countable class with Kraft weights that contains a program for $\nu_{f,p}$ (μ-a.e.).
  * In (i)–(v) the data are PQ with i.i.d. inputs: a noisy oracle that redraws its flip at every query.
  * Distinct inputs from a non-atomic μ (Remark 1.4(a)) are also covered.
  * Frozen data are covered only by (vi).
* **(i) The selected model (PQ).**
  * π ∈ E iff $\nu_\pi(\cdot\mid x)=\nu_{f,p}(\cdot\mid x)$, for both labels, for μ-a.e. $x$ (A m2: the value at label 1 alone does not suffice for a sub-probability kernel).
  * For $p<\frac12$ such a kernel determines $f$ μ-a.e., as its more likely label, and $p$, as its smaller probability.
  * So, by Thm 3.1, for every schedule $1\le\lambda_n=o(n)$, almost surely every $\lambda_n$-MAP is eventually a shortest program in $\mathcal C$ whose kernel is "$f$ (up to μ-null sets) with flips at rate exactly $p$".
  * The noise rate, a real number, is identified **exactly**, not approximately.
  * The flips $\{i:y_i\ne f(x_i)\}$ are the noise. They are not part of the selected model.
* **(ii) Fill-ins (PQ).** For fixed λ > 1, every fill-in, including "$f$ plus the list of flipped queries", has posterior mass at most $2^{\lambda\ell_0+\lambda\delta^*-(\lambda-1)S_n}$, with $S_n/n\to H(p)$ (Thm 4.1(iii)). This decays exponentially iff $p>0$ (A m12). On an atomic μ with $p>0$, every deterministic program dies at the first repeated input whose labels disagree.
* **(iii) Margins.** A competitor $\nu_{g,q}$ has gap $\Hel_\mu=\mu(g\ne f)\,h_{\ne}(p,q)+\mu(g=f)\,h_=(p,q)$, where
  $$h_=(p,q)=1-\sqrt{pq}-\sqrt{(1-p)(1-q)},\qquad h_{\ne}(p,q)=1-\sqrt{p(1-q)}-\sqrt{(1-p)q}.$$
  * In the class of i4, every wrong parity has $\mu(g\ne f)=1/2$, and rate competitors ($g=f$, $q\ne p$) attain the margin [computed: i4(A)].
  * In general they do not. A competitor $(g,p)$ with $g=f$ except at one input has gap $\mu(x_0)h_{\ne}(p,p)$. Under μ uniform on $\{0,1\}^7$ this is 0.0026, below the rate competitor's 0.0037; on $\{0,1\}^{10}$ it is 0.00033 [computed: rA1(B), rB6(A)]. notes.md's "rate competitors have the smallest gaps" is withdrawn (A m2, B b2).
* **(iv) Degenerate cases.**
  * If $p=\frac12$, ν is the coin, $f$ is not identifiable, and the selected model is a shortest coin program.
  * If $p=0$, E is the set of programs computing $f$ μ-a.e. (Paper 1's deterministic case). Then E contains fill-ins, and (ii) gives no decay.
* **(v) Canonical class.** In $\Hcl{\times}$ the exact identification of $p$ holds almost surely. For $p\in(0,\frac12]$ Prop 4.3 applies with β = $p$, so no computable sample size follows from the margin form of Thm 4.1(iv). The case $p=0$ is not covered by Prop 4.3 (A m2).
* **(vi) Frozen data on a finite domain (B4; A M1).**
  * Let μ have finite support $X_0$, with frozen noise (FR). The data set is eventually the full table $F|_{X_0}$. Every λ-MAP is then eventually a minimiser of $J_\lambda(\cdot\,;F|_{X_0})$, a function of $F$ alone. Its rate is a penalised empirical rate: among the programs $(f,q)$, the one minimising $\lambda\ell(f,q)+K\log(1/q)+(|X_0|-K)\log(1/(1-q))$, where $K$ is the number of flipped inputs.
  * By Prop 7.5 no procedure identifies every such sampler.
  * In the class of i4 ($d=6$, 64 inputs, $p=1/8$, $\ell_0=10$), the λ-MAP is wrong with probability at least $(7/8)^{64}=1.9\cdot10^{-4}$, for every λ [proved]. On the event that no input is flipped, the shorter program $(a^*,0)$ (9 bits) has $J=9\lambda<10\lambda+64\log(8/7)$.
  * The actual failure probabilities [computed: i8(D), 200,000 tables; the exact contribution of the programs $(a^*,q)$ and the coin, which depends only on $K$, agrees to within one standard error]:

    | λ | P[frozen λ-MAP ≠ $(a^*,1/8)$] | selected instead |
    |---|---|---|
    | 1 | 0.2555 | rate 1/4: 0.169; rate 1/16: 0.086 |
    | 1.5 | 0.2555 | rate 1/4: 0.168; rate 1/16: 0.086 |
    | 2 | 0.2037 | rate 1/4: 0.158; rate 1/16: 0.034; coin: 0.011 |
    | 4 | 0.5661 | coin: 0.556; rate 1/16: 0.010 |

  * In referee B's class (different rate code) the values are 0.132, 0.132, 0.080 and 0.562, each up to a further 0.005 from tables with $K\ge16$ [computed: rB6(C)].
  * With fresh noise the same classes recover exactly: failure frequency ≤ 0.003 at $n=3200$ and 0 at $n=6400$ (rB6(B)), and 0 at $n=800$ for λ = 2 (i4(B)).
  * λ = 4 lies above this table's kink window, and the coin wins on most tables. This is the T1/T2 contrast inside the corollary's own instance.
  * Prop 7.6(d) is a second frozen counterexample satisfying the hypotheses of (i) (A M1).

[computed: i4]
* *The class.* Inputs uniform on $\{0,1\}^6$, fresh flips. Parities $a$ with rates $q$ from an 8-element list with a prefix code, plus a coin; 513 programs, Kraft sum 0.625.
* *Truth and competitors.* The truth is $(a^*,1/8)$, with $\ell_0=10$. The competitors $(a^*,0)$ and $(a^*,1/4)$ are shorter (9 bits).
* *Margin.* γ = 0.003736, attained by the rate 3/16 ($=h_=(1/8,3/16)$). A wrong parity has gap at least 0.090.
* *Sample sizes.* $n(\lambda,\ell_0,\gamma,\varepsilon)=2843$ at λ = 2, ε = 0.05; 4264 at λ = 1.5; 5686 at λ = 4.
* *Simulation (2000 runs).* $\Prob[\text{MAP}\ne\text{truth}]$ is 0.054 at $n=200$, 0.014 at 400 and 0 at 800, for λ = 2. The Rényi bound is 0.41, 0.11 and 0.017 there. The margin bound is below 1 only from $n=3200$ (0.0066). At λ = 1 the frequencies are 0.092, 0.026 and 0.002 at $n=200,400,800$.

**Corollary 6.2 (subclasses) [proved].**
* Theorems 3.1, 3.2 and 4.1 and Props 3.3 and 3.4 use only countability, the Kraft inequality, and (for $E\ne\emptyset$) the presence of the sampler. They therefore hold in every time-bounded product class, every circuit class with private output noise, and every finite class.
* "Shortest" refers to the subclass's own code. A time-bounded class may select a longer but faster program than $\Hcl{\times}$ would.
* If ν has no program in the subclass, §7.4 applies.
* For a finite input set, such as circuits on $\{0,1\}^d$, inputs repeat. So PQ is the object for which recovery holds (§7.5).
* For finite classes, and for parametric classes whose rates lie on a known grid, $\gamma_L$ is computable, and Thm 4.1(iv) gives an explicit sample size (Cor 6.1, i4). In finite classes Thm 4.1(iv′) also gives a rate at λ = 1 (Remark 4.7).

---

## 7. What fails

### 7.1 Shared randomness

**Proposition 7.1 [proved, from Paper 2].** Let the class satisfy (Dom): it contains a member $U$ of length $\ell_U$ with $P_\pi\le2^{\ell(\pi)+\kappa_0}U$ for all π. Examples are SFI's machine-law class with $U=\MF$, the chronological class with $U=\MH$, and SI.
* For every λ > 1 and every observation $o$ with $U(o)>0$ (A m5), every λ-MAP has length at most $\ell^*_\lambda=(\lambda\ell_U+\kappa_0)/(\lambda-1)$ (`thm:absorb:absorption`(a)).
* So if every program for ν in the class is longer than $\ell^*_\lambda$, no λ-MAP is ever a program for ν, whatever $n$, the input law or the noise model. Exact recovery fails for every fixed λ > 1 (`thm:split:shared`).
* For fresh per-query noise the relevant shared class is the chronological class $\Hcl{\mathrm{chr}}$, where (Dom) holds with $U=\MH$ (`thm:split:shared`). The per-query mixture $\Mpq$ is one of its members (Paper 1, `prop:hist:operator`).

*Proof.* The cited theorems. ∎

* The per-query mixture $\Mpq$ is a shared object (one mixture), but its *terms* are product kernels. Exact recovery needs the class to consist of the terms, not to contain the mixture.
* In kink form this is kink Prop 3.5: a universal member flattens every left kink (§9).

### 7.2 λ → 1 and λ ∝ n

* *Fixed λ ↓ 1.* The guarantees of Thm 4.1 degrade like $1/(\lambda-1)$, and this is necessary (Prop 4.4(b), Remark 4.5).
* *λ = 1.* The limit statements survive (Thm 3.1, Prop 3.3). No class-free recovery-time bound survives (Prop 5.1, Remark 4.7).
* *λ = cn.* Exact recovery holds iff $c<c^*$, with the boundary case $c=c^*$ not covered (Prop 3.4).
* *$\lambda_n\to\infty$ with $\lambda_n=o(n)$.* Exact recovery holds (Thm 3.1). Moreover, the length bound of Thm 4.1(i), $\ell_0+(\ell_0+\delta^*)/(\lambda_n-1)$, tends to $\ell_0$, so eventually no MAP is longer than $\ell_0$ [proved: Thm 4.1(i) holds at each $n$ with $\lambda=\lambda_n$, since δ* does not depend on λ].

### 7.3 Non-i.i.d. and adaptive inputs

**Proposition 7.2 [(a) from Paper 2 and Prop 3.3; (b) proved; computed: i3(D)].**
* **(a) What survives.** Take any input rule that picks $x_{n+1}$ before $y_{n+1}$ is drawn (adaptive, randomised, non-computable), with distinct inputs or fresh labels. Let $\pi_\nu$ be a program of length $k$ that equals ν at every input (A M2: without μ, $E$ and $\ell_0$ are undefined, and the rule may query where an $E_0$-program differs from ν). Then:
  * `thm:split:private`(i)–(iii) and Thm 4.1(i)–(iii) hold with $k$ in place of $\ell_0$ (Lemma 2.2(c)). The exception is the last bullet of (iii), $S_n/n\to H_\mu(\nu)$, which needs i.i.d. inputs (A m7).
  * Every λ-MAP, for every λ ≥ 1, is eventually ν-equivalent on the run (Prop 3.3).
* **(b) What fails.**
  * *The example.* Inputs $x_j=0^j$, a fixed non-i.i.d. sequence. The truth is $\nu(1\mid0^j)=\frac12+2^{-j/2-2}$, with a program of length $\ell_0$. The class also contains the coin, of length $\ell_0-\Delta\ge1$ (Kraft; A m5).
  * *The coin is ν-equivalent on the run.* $\sum_j\Hel(\nu(\cdot\mid0^j),\text{coin})<\infty$, although the coin differs from ν at **every** queried input.
  * *The claim.* In the class {truth, coin}, with positive probability the λ-MAP is the coin for all large $n$ (A m7: notes.md's summary dropped "with positive probability").
  * *Proof.* $\Lambda_n(\text{coin})$ is a product of independent positive factors with mean 1 and $\sum\Hel<\infty$. By Kakutani's theorem it converges in $L^1$ to some $\Lambda_\infty>0$ with $\Ex\Lambda_\infty=1$ [known: Kakutani 1948]. So $\Prob[\Lambda_\infty\ge1]>0$. On $\{\Lambda_\infty>2^{-\lambda\Delta}\}$ the coin's $J$ is eventually below the truth's.
  * *With i.i.d. inputs* this cannot happen. Every set of positive μ-measure on which two kernels differ is visited at a linear rate, so Lemma 2.1(b) applies.
  * [computed: i3(D): λ = 2, Δ = 3; $\sum_j\Hel=0.032$; in 2000 of 2000 runs the MAP at $n=4000$ is the coin.]
* **(c) Reading.** With adaptive inputs there is no μ, and "exact recovery" has no target beyond the run. An input rule that avoids the inputs where a shorter program errs keeps that program selected. That is the correct answer to the questions asked, not a failure of the split: the selected program is still a sampler, not a fill-in (Thm 4.1(iii)).

### 7.4 Misspecification

Let ν have no program in $\mathcal C$ that equals it μ-a.e., so $E=\emptyset$.
* Put $D(\pi):=\Ex_{\mu\otimes\nu}\log(\nu/\nu_\pi)\in(0,\infty]$ and $D^*:=\inf_\pi D(\pi)$.
* Let $P:=\{\pi:D(\pi)=D^*\}$ be the set of KL-projections, possibly empty, and $P_0$ its shortest elements.
* Lemma 2.2 holds unchanged; only Lemma 2.1's "iff π ∉ E" becomes "always".

**Brief's conjecture (T1, "what fails"): the λ-MAP is eventually a shortest program among the KL-projections onto $\mathcal C$.**
* **[refuted for fixed λ]**, by two independent mechanisms: (ii) in PQ, and (iii) in FR.
* **[proved]** for finite classes under growing schedules $\lambda_n/\sqrt{n\log\log n}\to\infty$, $\lambda_n=o(n)$ (v).
* **[proved]** for fixed λ in finite classes with a unique projection kernel (i).
* **[open]** for countable classes (Conj 7.4).

**Proposition 7.3 [proved; computed: i3(A),(B), i8(C), rB5].** Objects as named in each part.
* **(i) Positive case (PQ).** Let $\mathcal C$ be finite, $D^*<\infty$, and suppose all KL-projections have the same kernel μ-a.e. Then for every schedule $0<\lambda_n=o(n)$, fixed λ > 0 included, almost surely every MAP is eventually in $P_0$.
* **(ii) Two projections: oscillation (PQ).**
  * *Claim.* Let $\pi_1,\pi_2\in P$ with $\ell(\pi_1)<\ell(\pi_2)$ and **$D^*<\infty$** (A m1). Assume $\Ex|\log(\nu_{\pi_2}/\nu_{\pi_1})|<\infty$, and that $\log(\nu_{\pi_2}(y\mid x)/\nu_{\pi_1}(y\mid x))$ is not a.s. zero under $\mu\otimes\nu$. Then in $\mathcal C=\{\pi_1,\pi_2\}$, for every fixed λ ≥ 1, almost surely $\pi_2$ is the unique λ-MAP for infinitely many $n$, and so is $\pi_1$.
  * *Example.* The truth gives fair-coin labels; $\pi_1$ = Bern(1/4) with $\ell=2$; $\pi_2$ = Bern(3/4) with $\ell=5$. Both have $D=\frac12\log\frac43$.
  * *Why $D^*<\infty$ is needed.* Without it the claim is false. With $\mu(x)\propto x^{-3}$ and both programs multiplied by $2^{-x^2}$, $D(\pi_1)=D(\pi_2)=\infty$. The log-ratio has mean $\frac12\log\frac43>0$, so $\pi_2$ wins forever (rA1(C): last switch at $n\le71$ in 20 runs).
* **(iii) Fill-ins beat the projection when λ is small (FR, distinct inputs; A M3).**
  * *Class.* $\mathcal C:=\{0w:w\text{ a program of }W\text{'s deterministic class}\}\cup\{1^{\ell_c}\}$, with $\ell_c\ge1$. The second element is a fair-coin program. The class is prefix-free, with Kraft sum ≤ 1/2 + $2^{-\ell_c}$ ≤ 1.
  * *Sampler.* ν = $f\oplus\Bern(p)$ with $f$ computable and $p\in(0,\frac12)$ computable, so ν ∉ $\mathcal C$. The coin is the unique KL-projection, for every input law: deterministic programs have $D=\infty$.
  * *Data.* FR on $X=\{0,1\}^*$ from a μ with infinite support. Count in distinct inputs $m_n\to\infty$, with maximal input length $d_n$, and assume $\log d_n=o(m_n)$.
  * *If $\lambda H(p)<1$:* almost surely every λ-MAP is a fill-in for all large $n$.
  * *If $\lambda H(p)>1$, or more generally $\liminf_n\lambda_nH(p)>1$ for a schedule:* almost surely the unique MAP is the coin for all large $n$. In particular every schedule $\lambda_n\to\infty$ selects the projection (B3).
* **(iii′) The same class in PQ: the conjecture holds (new).** Let μ be atomic, with i.i.d. inputs and fresh labels. Almost surely there is a time after which some input has received both labels. From then on every deterministic program has likelihood 0, and the coin is the unique λ-MAP for every λ > 0. Such a time exists a.s.: an atom of positive mass is queried infinitely often, and its labels are i.i.d. with both values of probability ≥ $p>0$. So (iii) is a frozen-object phenomenon.
* **(iv) No projection (PQ).** If $D^*<\infty$ is not attained, then almost surely the length of every MAP tends to ∞.
* **(v) Growing schedules (PQ; B3).** Let $\mathcal C$ be finite with $D^*<\infty$, and assume $\Ex[(\log(\nu_\pi/\nu_{\pi'}))^2]<\infty$ for all π, π′ ∈ P (automatic on a finite $X$).
  * (a) If $\lambda_n/\sqrt{n\log\log n}\to\infty$ and $\lambda_n=o(n)$, then almost surely every $\lambda_n$-MAP is eventually in $P_0$.
  * (b) The growth rate is sharp. Let π, π′ ∈ P with $\ell(\pi')>\ell(\pi)$, and let σ² > 0 be the variance of the log-ratio. If $\lambda_n(\ell(\pi')-\ell(\pi))\le(1-\eta)\sigma\sqrt{2n\ln\ln n}$ eventually, for some η > 0, then in $\{\pi,\pi'\}$ the longer projection π′ is the unique MAP for infinitely many $n$, almost surely. This covers $\lambda_n=a\sqrt n$ for every $a$, and fixed λ.

*Proof.*
* (i)
  * Fix $\pi_P\in P_0$. For π ∉ P, $\frac1n\log(\nu_\pi(h_n)/\nu_{\pi_P}(h_n))\to D^*-D(\pi)\in[-\infty,0)$ a.s. This is the strong law for the difference of $\log(\nu_\pi/\nu)$, whose positive part is integrable, and $\log(\nu_{\pi_P}/\nu)$, which is integrable since $D^*<\infty$ (Lemma 2.1(b)).
  * The length penalties differ by $o(n)$. So eventually no π ∉ P is a MAP.
  * Elements of P have a.s. equal likelihoods, since they share a kernel μ-a.e. So the shortest win.
* (ii)
  * $W_n:=\log(\nu_{\pi_2}(h_n)/\nu_{\pi_1}(h_n))$ is a random walk with i.i.d. integrable increments of mean $D(\pi_1)-D(\pi_2)=0$, which needs $D^*<\infty$. The increments are not a.s. zero.
  * Such a walk has $\limsup W_n=+\infty$ and $\liminf W_n=-\infty$ a.s. [known: e.g. Durrett, the theorem on the possible behaviours of a one-dimensional random walk (theorem number unverified)].
  * $\pi_2$ is the unique MAP iff $W_n>\lambda(\ell(\pi_2)-\ell(\pi_1))$, and $\pi_1$ iff $W_n<\lambda(\ell(\pi_2)-\ell(\pi_1))$.
* (iii)
  * *Sampled randomness.* On distinct inputs the flips are i.i.d. Bern(p), so $S:=-\log\nu(D_n)$ satisfies $S/m_n\to H(p)$ a.s.
  * *Which programs compete.* The coin has $J=\lambda\ell_c+m_n$. Every other program with finite $J$ is a consistent deterministic program, a fill-in.
  * *Small λ.* By Lemma 5.2, applied in $W$'s class with a $V$-program for ν as decoder, of length $k_\nu$, a fill-in of length $1+k_\nu+S+O(\log m_n+\log d_n+\log S)+\kappa$ exists. If $\lambda H(p)<1$, then $\lambda(k_\nu+S+o(m_n))<\lambda\ell_c+m_n$ eventually.
  * *Large λ.* Every fill-in has $\ell\ge S-\delta^*$, by Lemma 2.2 for the distinct-input run, with Kraft sum ≤ 1 and the true ν in the denominator. If $\liminf\lambda_nH(p)>1$, then $\lambda_n(S-\delta^*)-\lambda_n\ell_c-m_n\to\infty$, since δ* < ∞ a.s.
* (iii′) Stated above.
* (iv)
  * For each $L$, $d_L:=\min_{\ell(\pi)\le L}D(\pi)>D^*$, as a finite minimum of values above an unattained infimum. Pick π′ with $D(\pi')<d_L$.
  * For each π with $\ell(\pi)\le L$, $\frac1n[J(\pi)-J(\pi')]\to D(\pi)-D(\pi')>0$, by the strong law as in (i), with $D(\pi')<\infty$.
  * So eventually no program of length at most $L$ is a MAP.
* (v)(a)
  * Non-projections lose linearly, as in (i).
  * For π ∈ $P_0$ and π′ ∈ P ∖ $P_0$, the walk $W_n:=\log(\nu_{\pi'}(h_n)/\nu_\pi(h_n))$ has i.i.d. increments of mean 0 and finite variance σ². If σ = 0 then $W_n=0$ a.s. Otherwise the law of the iterated logarithm gives $|W_n|\le2\sigma\sqrt{n\ln\ln n}$ eventually, a.s. [known: Hartman & Wintner 1941 (unverified details)].
  * Then $J(\pi')-J(\pi)=\lambda_n(\ell(\pi')-\ell(\pi))-W_n\ge\lambda_n-2\sigma\sqrt{n\ln\ln n}>0$ eventually.
  * The class is finite, so eventually every MAP is in $P_0$.
* (v)(b) By the same law, $\limsup W_n/(\sigma\sqrt{2n\ln\ln n})=1$ a.s. So $W_n>\lambda_n(\ell(\pi')-\ell(\pi))$ for infinitely many $n$. ∎

[computed: i3(A). 20 runs of $10^6$ samples, λ = 2. In 17 of 20 runs the MAP switched after $n=10^5$; run 0 switched 1251 times, the last at $n=814{,}744$.]

[computed: i8(C), independent of rB5(A). 20 runs of $2\cdot10^6$ samples in example (ii). The longer projection is a MAP at some $n>10^5$ in 19/20 runs at fixed λ = 2, in 2/20 runs at $\lambda_n=\sqrt n$ (last at $n=611{,}086$), and in 0/20 runs at $n^{0.6}$, $n^{0.75}$ and $n/\ln n$. rB5(A), with another seed: 17/20, 5/20, 0, 0, 0. The rare late switches at $\sqrt n$ are what (v)(b) predicts: infinitely many, but sparse.]

[computed: i3(B), an illustration with κ = 0 in Lemma 5.2's bound: $p=0.1$, $1/H(p)=2.13$, input length 64. The MAP is a fill-in for all $n\ge534$ (λ = 1.5) and $n\ge4404$ (λ = 2). It is the coin for all $n\ge242$ (λ = 2.3) and $n\ge91$ (λ = 3), using the rigorous fill-in lower bound with δ* = 5; $n\le2\cdot10^5$. rB5(B) confirms the threshold in an *explicit* prefix-free memoriser class, with no machine constant: for $p=0.1$ the MAP is a memoriser for all $n\ge1566$ at λH = 0.97 and the coin at every $n\le10^6$ at λH = 1.03; for $p=0.25$ the corresponding values are 5019 and every $n$.]

*Readings.*
* (ii) needs two projections with *different* kernels. With a unique projection kernel the oscillation disappears, and (v) removes it for fast-growing schedules.
* (iii) is the misspecified, frozen version of the teacher's-mistakes phenomenon. When no model in the class explains the noise, the cheapest explanation of the noise is to memorise it, unless λ exceeds the inverse noise entropy. With fresh noise on repeated inputs, memorisation is impossible, by (iii′).
* So, for fixed λ, the conjecture fails for two independent reasons: ties between projections (PQ), and fill-ins that are cheaper than any model (FR).

**Conjecture 7.4 (misspecified selection in rich classes).**
* *Setting.* Let $\mathcal C$ be closed under memorisation: with each model π and each data set $D$ on distinct inputs, it contains, for every region $A\subseteq X$ of finite complexity, a program that agrees with π off $A$ and reproduces $D$ on $A$, of length $\ell(\pi)+K(A)+S_A(D)+o(n)$, where $S_A(D):=-\log\nu(D|_A)$. Fix λ > 1 and use distinct inputs (non-atomic μ).
* *Conjecture.* The per-sample objective $J_\lambda(\hat\pi_n)/n$ of the λ-MAP converges a.s. to
  $$\inf_{\pi,A}\Big\{\lambda\,\Ex_\mu\big[H(\nu(\cdot\mid x));A\big]+\Ex_\mu\big[H(\nu(\cdot\mid x))+\KL(\nu(\cdot\mid x)\,\|\,\nu_\pi(\cdot\mid x));X\setminus A\big]\Big\}.$$
  The minimising region is $A^*=\{x:(\lambda-1)H(\nu(\cdot\mid x))<\KL(\nu(\cdot\mid x)\|\nu_\pi(\cdot\mid x))\}$: memorise where the model's excess loss exceeds $(\lambda-1)$ times the local entropy.
* *Evidence.* Prop 7.3(iii) is the case $A^*\in\{\emptyset,X\}$, with π the coin. The heuristic is the two-part code count; there is no proof. B3's remark applies: in countable classes Ville does not exclude a program of length about $nD^*/\lambda_n$ when ν ∉ $\mathcal C$, so (v) does not extend directly.

### 7.5 Frozen noise, finite domains and repeats

**Proposition 7.5 (frozen noise: no procedure recovers every sampler) [proved].**
* *Setting.* FR (Def 1.3) on a countable $X$. Let ν, ν′ be samplers that differ only at one input $x_0$ with $\mu(x_0)>0$, where $\nu(\cdot\mid x_0)$ and $\nu'(\cdot\mid x_0)$ are mutually absolutely continuous and distinct.
* *Claim.* The laws $P_\nu$, $P_{\nu'}$ of the whole data process are mutually absolutely continuous. So for every estimator $(\hat\pi_n)$ with values in $\mathcal C$,
  $$P_\nu[\hat\pi_n\in E_\nu\text{ for all large }n]=1\ \Longrightarrow\ P_{\nu'}[\hat\pi_n\in E_{\nu'}\text{ for all large }n]=0.$$
* *In the canonical class.* Every computable ν with $\nu(y_0\mid x_0)\in(0,1)$, for some $x_0$ of positive mass and some $y_0$, has such a computable ν′: $\nu'(\cdot\mid x_0):=\frac12(\nu(\cdot\mid x_0)+\delta_{y_0})$. So no procedure, the λ-MAP for any λ included, achieves frozen exact recovery for all computable samplers with noise on the support of μ.

*Proof.*
* The data process is a measurable function of the input sequence and of $F$ restricted to the support of μ. The input sequence has the same law under both samplers, and it is independent of $F$.
* Under ν and ν′ the field $F$ has product laws that differ in the single factor at $x_0$. The density $\nu'(F(x_0)\mid x_0)/\nu(F(x_0)\mid x_0)$ lies in $(0,\infty)$ a.s., so the laws are mutually absolutely continuous.
* $E_\nu\cap E_{\nu'}=\emptyset$, since $\mu(x_0)>0$. If $A=\{\hat\pi_n\in E_\nu\text{ eventually}\}$ has $P_\nu(A)=1$, then $P_{\nu'}(A)=1$, and on $A$ the estimator is eventually outside $E_{\nu'}$. ∎

**Proposition 7.6 (what frozen noise does give) [proved; computed: i3(C)].** FR with i.i.d. inputs on a countable $X$. The run of distinct inputs eventually enumerates the support of μ.
* (a) *Identification on the run, every λ ≥ 1 (B1).* Suppose $\mathrm{supp}\,\mu$ is infinite, and let $K:=\{\pi:\sum_{x\in\mathrm{supp}\,\mu}\Hel(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))<\infty\}$. For every fixed λ ≥ 1, almost surely every λ-MAP is eventually in $K$, and $\Pi_\lambda(K\mid D_n)\to1$. This is Prop 3.3, with $\pi_0\in E_0$ in the role of $\pi_\nu$. notes.md had λ > 1, from `thm:split:private`(iv).
* (b) *Fill-ins leave in the limit.* $K\supseteq E$. Let $\beta_x:=1-\max_y\nu(y\mid x)$. If $\sum_{x\in\mathrm{supp}\,\mu}\beta_x=\infty$, no deterministic program is in $K$, and for every λ ≥ 1 the posterior mass of all deterministic programs tends to 0 a.s.
* (c) *Finite support.* $D_n$ is eventually the fixed data set $D_\infty=F|_{\mathrm{supp}\,\mu}$. The MAP is eventually constant, a minimiser of $J_\lambda(\cdot\,;D_\infty)$. This is a single-data-set question, the subject of target T2. No identification of ν is possible (Prop 7.5).
* (d) *A concrete failure.*
  * *Setting.* $X=\{0,\dots,9\}$ with μ uniform. The truth is Bern(1/64) at every input, with a program of length 5. Exception programs $e_j$ equal ν except $P(1\mid j)=1$, and have length 9.
  * *Frozen noise.* For λ < 1.5 the λ-MAP is eventually some $e_j$ with probability exactly $1-(63/64)^{10}=0.1457$. An $e_j$ with $F(j)=1$ gains 6 bits for $4\lambda$ bits of length.
  * *Fresh noise.* The $e_j$ die at the first label 0 at $j$, and Thm 3.1 applies.
  * [computed: i3(C): $10^4$ runs, $n=2000$. Frozen: 0.1468 (λ = 1) and 0.1387 (λ = 1.25), and 0 at λ = 1.75. Fresh: 0 for all three.]

*Proof.*
* (a) Prop 3.3. In FR on a countable $X$, $\pi_0\in E_0$ equals ν at every input of the run, and the run of distinct inputs is all of $\mathrm{supp}\,\mu$.
* (b) A deterministic φ has $\Hel(\nu(\cdot\mid x),\delta_{\varphi(x)})=1-\sqrt{\nu(\varphi(x)\mid x)}\ge1-\sqrt{1-\beta_x}\ge\beta_x/2$, and $=1$ where φ is undefined. That is not summable under the stated condition. Then use Prop 3.3(c).
* (c) There are finitely many distinct inputs.
* (d) Direct. ∎

**Remark 7.7 (frozen noise: finite-sample identification on large uniform domains) [proved, from Remark 1.5 and the kink sub-track; computed: i8(D), rB6(C)].**
* By Remark 1.5, FR with μ uniform on a finite $X_0$, at $m\le|X_0|$ distinct inputs, is the kink sub-track's (wor) scheme. So kink Cor 5.5 and Thm 5.6 apply there [cited, not re-proved: kink Lemma 5.1 uses Hoeffding's comparison of sampling with and without replacement]. With probability ≥ 1 − 2ε, every λ-MAP is a shortest equivalent program once $2\log e\cdot m\gamma>(2-\lambda)^+\bar\ell_\lambda+\lambda\ell_0+2\log(1/\varepsilon)$.
* So frozen identification holds with high probability when the domain is large compared with the sample size this needs. It fails with probability bounded away from 0 once the whole table is seen, as in Cor 6.1(vi). There $|X_0|=64$ is far below the sample sizes these bounds need; for instance $n(2,10,0.0037,0.05)=2843$ in Thm 4.1(iv).
* This is consistent with Prop 7.5, which excludes only *almost sure eventual* identification.

*Finite domains, summary.*
* With fresh noise, Thm 3.1 identifies ν on the support exactly, including for circuits on $\{0,1\}^d$.
* With frozen noise, no procedure identifies every sampler (Prop 7.5). Identification is possible with high probability only while the table is far from exhausted (Remark 7.7).
* With λ = cn in PQ, the selection tends to the minimisers of the population objective $c\ell+R$ (Prop 3.4(c)).
  * With frozen noise on a finite support, the data are eventually one table, and every schedule faces the fixed problem $J_{\lambda_n}(\cdot\,;D_\infty)$.
  * For large λ that problem selects, among the shortest programs with $\nu_\pi(D_\infty)>0$, those of least fit. With fixed λ it selects the vertex of the table's hull at slope λ (kink Thm 2.2).
  * Against a *fixed table counted per query* (the teacher's population risk with $y^*=F$), Prop 3.4(c) applies with the channel $\delta_F$. Every $\lambda_n=o(n)$ then ends at the least-risk programs, which memorise $F$ (teacher Prop 3.2(a)). This is a different likelihood from Paper 2's data-set likelihood (§9.4).

---

## 8. Link to target T2: a sample has a kink at $\ell_0$

Write $\rho_{\mathcal C}(\alpha):=\min\{L_n(\pi):\ell(\pi)\le\alpha\}$ for the class's structure function on the per-query data $h_n$. For $\mathcal C=\Hcl{\times}$ on distinct inputs it is Paper 2's $\rho^\times_D$.

**Lemma 8.1 (the sample kink, PQ) [proved; computed: i8(F), i8(G), rB4].** PQ with i.i.d. inputs. Put $\gamma_-:=\min\{\Hel_\mu(\pi):\ell(\pi)<\ell_0\}$, with $\gamma_-:=+\infty$ if no program is shorter than $\ell_0$ (A m5).
* **(i) Left side, uniformly over programs (kink Lemma 5.2 in PQ form; B b10).** For each $n$ and ε ∈ (0, 1), with probability at least 1 − ε, simultaneously for all π ∈ $\mathcal C$:
  $$L_n(\pi)-S_n\ >\ 2\log e\cdot n\,\Hel_\mu(\pi)-2\ell(\pi)-2\log(1/\varepsilon).$$
  In particular every π with $\ell(\pi)<\ell_0$ has $L_n(\pi)-S_n>2\log e\cdot n\gamma_--2\ell(\pi)-2\log(1/\varepsilon)$.
* **(ii) Right side (Ville).** For all $n$ and all π, $L_n(\pi)-S_n\ge-\ell(\pi)-\delta_n\ge-\ell(\pi)-\delta^*$, with $\Prob[\delta^*\ge j]\le2^{-j}$.
* **(iii) The structure function.** On the event of (i), and a.s. for the rest:
  * $\rho_{\mathcal C}(\ell_0)\le S_n$;
  * for $\alpha<\ell_0$: $\rho_{\mathcal C}(\alpha)\ge S_n+2\log e\cdot n\gamma_--2\alpha-2\log(1/\varepsilon)$;
  * for $\alpha\ge\ell_0$: $\rho_{\mathcal C}(\ell_0)-\rho_{\mathcal C}(\alpha)\le(\alpha-\ell_0)+\ell_0+\delta^*$.

  So $(\ell_0,S_n)$ carries a zero-window left kink (kink Def 3.1) of steepness at least $(2\log e\cdot n\gamma_--2\log(1/\varepsilon))/\ell_0$ when that quantity is at least 2 (kink Thm 5.4(i)). This is linear in $n$. For every τ > 1 it carries a right kink of flatness τ with window $(\ell_0+\delta^*)/(\tau-1)$ (kink Thm 5.4(ii)).
* **(iv) The $\ell_0$ in the right-side slack cannot be dropped (B2).** notes.md read the right side as "each bit of length buys at most one bit of fit, plus δ* in total", that is, $\rho_{\mathcal C}(\ell_0)-\rho_{\mathcal C}(\alpha)\le(\alpha-\ell_0)+\delta^*$. That reading is **[refuted]**.
  * *Counterexample.* In $\mathcal C_{k,M}$ (Prop 5.1) with $M+2>k$, $n=M-5\ge1$ and $\alpha=M+2$: on the event that some parity is consistent, which has probability $\Prob[\mathrm{rank}A=n]\ge31/32$, we have $\rho(\ell_0)=n$ and $\rho(\alpha)=0$. So the excess $\rho(\ell_0)-\rho(\alpha)-(\alpha-\ell_0)$ is exactly $k-7=\ell_0-7$ bits.
  * The refuted reading needs δ* ≥ $\ell_0-7$, which has probability at most $2^{-(\ell_0-7)}$. So it fails with probability at least $31/32-2^{7-\ell_0}$.
* **(v) The form of notes.md, kept.** With probability at least $1-2^{\ell_0}e^{-\gamma_-n/2}$, every π shorter than $\ell_0$ has $L_n(\pi)\ge S_n+\gamma_-n\log e$. It is valid but weaker than (i): it is informative in rB4(C)'s class only from $n\approx2000$, while the event has exact probability 0.985 already at $n=800$.

*Proof.*
* (i) Fix π and put $a:=2\log e\cdot n\Hel_\mu(\pi)-2\ell(\pi)-2\log(1/\varepsilon)$.
  * By Markov's inequality for $\Lambda_n^{1/2}$ and Lemma 2.1(c), $\Prob[\Lambda_n(\pi)\ge2^{-a}]\le2^{a/2}\rho_{1/2}(\pi)^n\le2^{a/2}e^{-n\Hel_\mu(\pi)}=\varepsilon2^{-\ell(\pi)}$.
  * Sum over π using Kraft. The event $L_n(\pi)-S_n\le a$ is $\Lambda_n(\pi)\ge2^{-a}$.
  * In PQ, kink Lemma 5.1 holds with equality, $\Ex\sqrt{\Lambda_n}=(1-\Hel_\mu)^n$, so this is kink's proof.
* (ii) Lemma 2.2(a).
* (iii)
  * $\rho_{\mathcal C}(\ell_0)\le L_n(\pi_0)=S_n$ a.s.
  * The middle line is (i) with $\Hel_\mu(\pi)\ge\gamma_-$ and $\ell(\pi)\le\alpha$.
  * The last line is $\rho_{\mathcal C}(\alpha)\ge S_n-\alpha-\delta^*$, from (ii).
  * The kink statements are kink Thm 5.4(i),(ii) applied to these bounds.
* (iv)
  * In $\mathcal C_{k,M}$, $\ell_0=k$ and $\rho(\ell_0)=L_n(\text{coin})=n$, because the parities are longer than $k$ when $M+2>k$.
  * A consistent parity has fit 0 and length $M+2$.
  * So the excess is $n-(M+2-k)=k-7$.
  * The probability bound is the rank bound of Prop 5.1(a).
* (v) Markov's inequality for $\Lambda^{1/2}$ with $t=\gamma_-n\log e$, and a union over the at most $2^{\ell_0}$ shorter programs. ∎

[computed: i8(F). Exact enumeration in i1's class at $n\in\{25,50,100,200\}$ and ε ∈ {0.1, 0.01}: the failure probability of (i) is at most $3.3\cdot10^{-3}$, and that of the fixed-$n$ Ville event $\{\exists\pi:L_n(\pi)-S_n\le-\ell(\pi)-\log(1/\varepsilon)\}$ is at most $4.3\cdot10^{-3}$, both below ε. i8(G): $\Prob[\text{a parity is consistent}]=0.9845$ at $n=M-5$ for $k\in\{16,24,32\}$ and three values of $M$ each. rB4(A),(B): the same counterexample, with excess median 17 bits at $k=24$, $n=30$.]

**Remark 8.2 (the bridge to T2, and one object per thread) [remark, from proved results].**
* *T2's deterministic theory applies to PQ data.* The kink sub-track's §2–§3 (hull characterisation of λ-MAPs, Def 3.1, Thm 3.2, Thm 3.4) hold verbatim for any family of points $(\ell(\pi),L(\pi))$ with integer lengths and finitely many points per length (kink §1). So they apply to the per-query point set $\{(\ell(\pi),L_n(\pi))\}$.
* *The bridge.* Lemma 8.1 shows that this point set has, with high probability, a two-sided kink at $(\ell_0,S_n)$.
  * The left steepness is $\Theta(n)$.
  * The right flatness is 1 beyond a window $(\ell_0+\delta^*)/(\tau-1)$.
  * Kink Thm 3.2(c), with τ ↑ λ, then places every λ-MAP, for λ between the two, at length in $[\ell_0,\ \ell_0+(\ell_0+\delta^*)/(\lambda-1)]$. This is Thm 4.1(i).
  * Identification inside that window needs the margin of the programs of length up to $\ell_0+(\ell_0+\delta^*)/(\lambda-1)$. That is Thm 4.1(iv) and kink Cor 5.5.
* *Why λ > 1 appears.* Because of the $\ell_0$ in the right window, no fixed λ ≤ 1 lies inside a guaranteed kink interval at finite $n$. kink Remark 5.9 says the same. This is the kink-form statement of Remark 4.7 and Prop 5.1. In the limit the right slope at $(\ell_0,S_n)$ is eventually below 1 in PQ: Thm 3.1 makes $E_0$ the unique 1-MAP eventually, so every longer program has a secant below 1 from $(\ell_0,S_n)$. This answers kink open question 2 for PQ, in the limit only.
* *Recommendation for the paper (B b11).* Fix one object per thread:
  * PQ for T1's asymptotic and finite-sample theorems (§3–§4);
  * single data sets for T2;
  * the bridge stated for the pair, as Lemma 8.1 together with kink Thm 3.2.

  The paper should carry one version of the sample-kink lemma: kink Lemma 5.2 in PQ form, which is (i) here.

---

## 9. Cross-track consistency

This section compares the three sub-tracks of track "split": iid (this file, T1), kink (`../kink/notes.md`, T2) and teacher (`../teacher/notes.md`, T3). It aligns their definitions and notation. Neither sibling had a `notes-final.md` when this was written. Their referee reports were read where they concern objects shared with this file.

### 9.1 Objects

| object | iid (this file) | kink | teacher | Paper 2 now |
|---|---|---|---|---|
| **PQ**: pairs i.i.d., label redrawn per query, per-query likelihood | §3–§6, §8 (main object) | §5 after its referees' fix; its scheme (iid) "non-atomic μ" is empty on $\{0,1\}^*$ (kink referee A issue 1, B issue 1) | §3's noise side; Prop 3.2 (per-query risk under any label channel) | not used; `def:setup:data` fixes frozen noise |
| **FR**: one label per distinct input, data-set likelihood | §7.5, Prop 3.3, Cor 6.1(vi), Remark 7.7 | scheme (wor) = FR on a uniform finite support, counted in distinct inputs (Remark 1.5) | full tables; samples without replacement (§3.2) | `def:setup:data`; `thm:split:private` |
| **DS**: one data set, no probability model | Lemma 5.2; Prop 5.3(b),(c) | §2–§4 (hull, kinks, noisy parity) | Lemma 1.1; §2, §4 | `algstat.tex`; `teacher.tex` (full tables) |

* *Agreed.* T1's limit and finite-sample theorems are PQ statements. The single-data-set theory is DS. The two meet through Lemma 8.1 and kink Thm 3.2 (Remark 8.2).
* *For the paper.* If T1 goes into Paper 2, `def:setup:data` must add the per-query reading, or T1 must be stated for stamped inputs with stamp-ignoring programs (Remark 1.4(c)). The teacher referee's M4 asks for the same.

### 9.2 Notation

| object | this file | kink | teacher | Paper 2 / NOTATION.md |
|---|---|---|---|---|
| least length of a μ-a.e. equivalent program | $\ell_0$ (notes.md: $\ell^*$) | $\ell_0$ | reference length $\ell_0$ of Lemma 1.1 in Prop 2.3 (there $k$) | — (Paper 2 uses $\ell^*_\lambda$ for the absorption bound) |
| the shortest equivalent programs | $E_0$ (notes.md: $E^*$) | "shortest equivalent programs" | — | — |
| length of a program equal to ν everywhere; of a decoder that is a measure on $\{0,1\}^{\le d}$ | $k$; $k_\nu$ | $\ell(\pi^*)$ | $k$ | $k$ (`def:split:setting`) |
| fit of π on the data | $L_n(\pi)=-\log\nu_\pi(h_n)$ | $L(\pi)=-\log\nu_\pi(D)$ | $F(\pi)$ (data reading) | $-\log P_\pi(o)$ |
| sampled randomness | $S_n=-\log\nu(h_n)$ | $L_0=-\log\nu(D_n)$ | $F_0$ in Prop 2.3 | $-\log\nu(D_n)$ |
| likelihood ratio | $\Lambda_n(\pi)$ | $\Lambda_n(\pi)$ | — | $\Lambda_n$ (`app:split:private`) |
| Hellinger gap | $\Hel_\mu(\pi)$ (notes.md: $\gamma(\pi)$) | $\Hel_\mu(\pi)$ | — | $\Hel$ pointwise |
| margins | $\gamma_L$ (length ≤ L), $\gamma_-$ (shorter than $\ell_0$) | $\gamma_{\bar\ell}$, $\gamma_-$ (the same sets) | — | — |
| Ville deficiency | δ*, and the current $\delta_n$ | δ*, and $\log(1/\varepsilon)$ at fixed $n$ | δ* | δ* (`lem:split:ville`) |
| structure function | $\rho_{\mathcal C}(\alpha)$ | $\rho_D(\alpha)$ | $\rho_{\rm pop}$ (population) | $\rho^\times_D$ |
| per-sample rate; population risk | $c=\lambda/n$; $R(\pi)$ under the true channel | $c=\lambda/n$ | $c$; $R(\pi)$ (Prop 3.2: any channel) | $c$; $R(\pi)$ against a teacher $y^*$ |

The two δ*'s agree. This file's δ* is Paper 2's δ* computed with per-query likelihoods; on distinct inputs they are the same random variable.

### 9.3 Results that coincide

* **Asymptotic identification.**
  * Thm 3.1 contains kink Cor 5.7(c). Kink's is for fixed λ > 1 in its (iid) scheme, read as PQ. Thm 3.1 adds λ = 1 and every schedule $1\le\lambda_n=o(n)$.
  * Teacher Prop 3.2(a),(b) gives the same target from the population side. Every $\lambda_n=o(n)$ ends at the least-risk programs, and for a sampler with fresh noise these are E (Gibbs). Thm 3.1 picks the shortest of them.
* **Finite sample.**
  * Thm 4.1(iv) and kink Cor 5.5 give the same order, $n=O(\lambda\ell_0/(\min(1,\lambda-1)\gamma))$. They even use the same length cap. Kink's $\bar\ell_\lambda=\ell_0+(\ell_0+\log(1/\varepsilon))/(\lambda-1)$ is this file's $L_\varepsilon$ up to the convention for ε.
  * The free exponent with $s=1$ for near-equivalent programs (Thm 4.1(iv′)) reproduces the $W_{\rm near}$ term of kink Thm 5.6: $2^{-\lambda(\ell-\ell_0)}$ per program.
* **The sample kink.**
  * Lemma 8.1(i) is kink Lemma 5.2 in PQ form.
  * Lemma 8.1(iii)'s right side is kink Lemma 5.3 with Thm 5.4(ii), with window $(\ell_0+\delta^*)/(\tau-1)$.
  * The corrected reading (B2) agrees with kink's form. notes.md's reading did not.
* **Necessity of the margin.** Prop 4.4(a) (Chebyshev, on the Hellinger scale, exact constants in a two-point class) and kink Prop 5.8 (Markov, on the KL scale, general) show the same thing.
* **λ = cn.**
  * Prop 3.4(c) is teacher Prop 3.2(d), extended from finite to countable Kraft classes (teacher referee m7).
  * Prop 3.4(b) is the converse that teacher's Reading after Prop 3.2 attributes to this file. notes.md did not prove it (teacher referee m8); it is now proved.
* **The τ = 1 instance of the kink lemma.**
  * Teacher Prop 2.3 derives `thm:split:private`(i) from its Lemma 1.1 with τ = 1 and $g=k+\delta^*$. In PQ the same holds with $\ell_0$ in place of $k$ (Thm 4.1(i)), because the comparison is on the sample (Def 1.2).
  * Kink Cor 5.7(c) uses `thm:split:private`(i) "with a shortest equivalent program in the role of $\pi_\nu$". Referee A's M2 confirms that this is valid.
* **λ = 1.**
  * Teacher Remark 3.5 ("asymptotically λ = 1 still selects for i.i.d. noise, by the Kraft tail") is Thm 3.1.
  * Kink Remark 5.9 (λ = 1 lies in no guaranteed interval at finite $n$) agrees with Remark 4.7 and Prop 5.1. At finite $n$ λ = 1 has bounds only through the class ($\sum2^{-s\ell}<\infty$), never class-free ones.
* **Shared randomness.** Prop 7.1 is kink Prop 3.5 and Remark 5.9 in selection form: a universal member flattens every left kink, so no fixed λ > 1 selects ν.

### 9.4 Points that needed reconciliation

* **(a) Two readings of "frozen noise with repeats".**
  * *Paper 2's data-set likelihood* counts each distinct input once (Def 1.3). Under it, a program longer than $\ell_0$ that agrees with ν off a finite set $A$ of atoms gains over $\pi_0\in E_0$ at most $\sum_{x\in A}\log(1/\nu(F(x)\mid x))$ bits, a bounded amount. So any $\lambda_n\to\infty$ eventually ranks it below $\pi_0$ [proved: one line].
  * *The per-query likelihood against a fixed table* counts every query. This is the teacher's population risk with $y^*=F$. Under it, every $\lambda_n=o(n)$ ends at least-risk programs, which memorise $F$ (teacher Prop 3.2(a); Prop 3.4(c) here with the channel $\delta_F$).
  * Teacher referee M4's statement "in the frozen object λ_n = o(n) memorises" is about the second reading. Both readings agree with this file. The paper must say which likelihood it uses when inputs repeat.
* **(b) Kink's (iid) scheme.** "Non-atomic μ on X" is empty on $\{0,1\}^*$. Kink's referees ask kink to restate §5 in PQ, as Remark 1.4 does here. Kink Lemma 5.1 then holds with equality.
* **(c) "Right flatness 1" for fresh noise** (teacher Remark 3.4; kink Remark 5.9).
  * Ville gives a line of slope −1 under all programs, with offset $\ell_0+\delta^*$ (teacher's $\tau_{\rm line}=1$, in the terms of teacher referee M3).
  * It does not give secant slopes ≤ 1 from the model point. Those can exceed 1 by up to $(\ell_0+\delta^*)/(\alpha-\ell_0)$, and in $\mathcal C_{k,M}$ they do: the excess is $k-7$ bits (Lemma 8.1(iv)).
  * The teacher sub-track's use of the line, not of the secant, is consistent with this. Statements of the form "right flatness 1 at every $n$" must mean the line.
* **(d) Lengths.** Statements that compare objectives on the sample use $\ell_0$. Decoder constructions use $k_\nu$ (Def 1.2). The stream lemma transfers to $\ell_0$ on sampled data; the single-fill-in lemma does not. Kink's and teacher's uses of `thm:split:private` are comparisons on the sample, so they are unaffected.
* **(e) Statuses.**
  * notes.md's Lemma 8.1 reading is now refuted (Lemma 8.1(iv)).
  * Teacher Prop 2.3's τ = 1 instance cites notes.md's Lemma 8.1 for "the linear left margin". That still holds, in the sharper form (i), with probability ≥ 1 − ε at fixed $n$ (teacher referee m4).

### 9.5 Recommendations for the restructured Paper 2

1. **Headline of the split thread.** State Thm 3.1 (PQ; λ = 1 included) as the limit theorem. State Thm 4.1(i), (iii) and (iv′) as what λ > 1 adds, with $\ell_0$, and Remark 4.7 as the reason. State Prop 5.1 as the λ = 1 contrast: recovery time $\Theta(2^{\ell_0/2})$ against $\Theta(\lambda\ell_0/(\lambda-1))$.
2. **`thm:split:private`(iv) for λ ≥ 1** (Prop 3.3). Reword the opening of `sec:split`: at λ = 1 the posterior *odds* between sampler and fill-ins are balanced at finite $n$, but the limit is the same.
3. **One sample-kink lemma:** Lemma 8.1(i)–(iii), with the right side as corrected.
4. **Frozen versus fresh noise**, within the noisy-function corollary: Cor 6.1(i) against (vi), and Prop 7.5.
5. **Misspecification:** Prop 7.3 as revised, with the honest summary "refuted for fixed λ; true for fast schedules in finite classes; open in general".
6. **λ = cn:** Prop 3.4. It also gives the teacher thread its population-hull limit (teacher Prop 3.2(d)).

---

## 10. Response to the referees

Every issue was checked against the notes and, where possible, against the referees' code. That code was re-run and reproduced its saved outputs byte for byte (verification log). No issue was rejected. Where the fix differs from the one the referee suggested, the table says so.

**Referee A (proofs).**

| issue | verdict | resolution | where |
|---|---|---|---|
| M1 "distinct inputs" admits FR, where statements fail | accepted | Objects PQ/FR/DS separated. On $\{0,1\}^*$ only PQ is covered by §3–§4, §6, §8. Non-atomic μ needs an uncountable standard Borel $X$. Lemma 5.2 and Prop 5.3(b),(c) are DS statements. Cor 6.1 cites Prop 7.6(d) and the new (vi). | Def 1.3, Rem 1.4, §0.1, Cor 6.1(vi), Lemma 8.1 |
| M2 $\ell^*$ vs $k$ | accepted | $k$ and $k_\nu$ defined. Comparisons on the sample use $\ell_0$; Lemma 5.2 uses $k_\nu$; Prop 7.2(a) and Prop 3.3 use $k$. Prop 5.3(c) names both programs. The stream lemma's transfer to $\ell_0$ is explained and proved. | Def 1.2, Lemma 5.2, Prop 5.3(c),(d), Prop 7.2(a) |
| M3 Prop 7.3(iii) broader than proved; Kraft | accepted | (iii) restricted to FR on $\{0,1\}^*$ with $\log d_n=o(m_n)$, in the prefix-free class $0\cdot W\cup\{1^{\ell_c}\}$. New (iii′) proves the PQ contrast: the coin wins for every λ. Summary and status rows name the object. | Prop 7.3(iii),(iii′), §0.7, §11 |
| m1 Prop 7.3(ii) needs $D^*<\infty$ | accepted | added, with A's counterexample | Prop 7.3(ii) |
| m2 Cor 6.1 details | accepted | both labels in (i); the "rate competitors smallest" remark restricted to the i4 class; $p\in[0,\frac12]$ with $p=\frac12$ as a degenerate case; Prop 4.3 covers $p\in(0,\frac12]$ only | Cor 6.1(i),(iii)–(v) |
| m3 ties in Props 4.4(b), 5.1(b) | accepted; fix varied | strict conditions, as A suggests, but keeping $m=n+5$ and 31/32: under the strict condition the parity on $n+5$ bits already beats the coin strictly. A's version used $m=n+4$ and 15/16. | Props 4.4(b), 5.1(b); i7(C) |
| m4 quantifiers and constants in §0 | accepted | (iv) per $n$, (v) uniform; necessity qualified (λ ≥ 2, $\ell_0/\Delta$, logs, separate classes) | §0.4, Thm 4.1(iv), Prop 4.4 |
| m5 side conditions | accepted | ε range in 4.2; $\ell_0-\Delta\ge1$ in 4.4(a), 7.2(b); $m\ge1$ in 5.1; $\gamma_-=+\infty$ convention; $U(o)>0$ in 7.1 | Props 4.2, 4.4, 5.1, 7.1, 7.2, Lemma 8.1 |
| m6 statuses | accepted | 4.4(c) computed and heuristic; $P\approx2^{k-1}/n^2$ computed (with a proved bound added); the "population hull" sentences now proved (Prop 3.4(c)); row 5.3(a) names the object | Prop 3.4, 4.4(c), 5.1, 5.3, §11 |
| m7 Prop 7.2 | accepted | "with positive probability" restored; $S_n/n\to H_\mu$ excluded under adaptive inputs | §0.7, Prop 7.2 |
| m8 Prop 4.3 computability; hypotheses dropped in §0 | accepted | computable rational $g'$; direct proof of $j(L)\ge h(m)$; hypotheses in §0 | Prop 4.3, §0.4 |
| m9 Thm 3.2(ii) cites Lemma 2.1(c) | accepted | cites 2.1(b) | Thm 3.2 |
| m10 stamps | accepted | sentence added | Rem 1.4(c) |
| m11 Prop 5.3(b) "on any data set" | accepted | lower end for any $D$ with δ(D); upper end where $\nu_{\pi_0}(D)=\nu(D)$ | Prop 5.3(b) |
| m12 decay only for non-deterministic ν | accepted | stated | Thm 4.1(iii), Cor 6.1(ii),(iv), Prop 5.3(d) |
| m13 measurability | accepted | standard Borel $X$ and jointly measurable kernels; FR defined on distinct inputs directly | Rem 1.4(a), Def 1.3 |
| m14 the Rényi bound without its first term | accepted | Thm 4.1(iv′) | Thm 4.1(iv′) |

**Referee B (computation and counterexamples).**

| issue | verdict | resolution | where |
|---|---|---|---|
| B1 λ = 1 is also identified on the run, any rule, FR too | accepted | new Prop 3.3 with full proof; Prop 7.6(a),(b) for λ ≥ 1; contrast table rewritten for both objects; flag for `thm:split:private`(iv) | Prop 3.3, Prop 5.3(a′), Prop 7.6, §5 table, §9.5 |
| B2 Lemma 8.1's right-side reading false | accepted | Lemma 8.1 rewritten; the refuted reading kept as (iv), with a proved counterexample (excess exactly $k-7$) | Lemma 8.1, Rem 8.2 |
| B3 KL projection holds for growing schedules | accepted, extended | Prop 7.3(v)(a) [proved, LIL]; (v)(b) proves sharpness; (iii) for $\lambda_n\to\infty$; summary changed | Prop 7.3, §0.7, §11 |
| B4 frozen noise breaks rate identification in the noisy-parity instance | accepted | Cor 6.1(vi), computed in the i4 class (i8(D)), with a proved lower bound | Cor 6.1(vi), Rem 7.7 |
| b1 recovery-time table on a grid | accepted | exact certified table (i7), equal to rB2's; λ = 1 closed form computed; proved $\Theta(2^{k/2})$ bounds added (Prop 5.1(b′)) | Prop 5.1 |
| b2 = A m2 | accepted | — | Cor 6.1(iii) |
| b3 free Chernoff exponent | accepted | Thm 4.1(iv′) as the primary form; Remark 4.7 on what it says at λ = 1 | Thm 4.1, Rem 4.7 |
| b4 failure probability not monotone | accepted | Remark 4.6 | Rem 4.6 |
| b5 length bound attained | accepted, proved | Remark 4.5 [proved], with the exact gap | Rem 4.5; i7(E) |
| b6 Thm 4.1(vi) rarely informative | accepted | Rényi form added to (vi) | Thm 4.1(vi) |
| b7 λ > 1 slower in half the random classes | accepted | Prop 4.4(c) computed and quantified | Prop 4.4(c) |
| b8 stale script numbering | accepted | i1–i6 relabelled and re-run; outputs identical except labels; i2's Kraft remark corrected to 1/4 | verification log |
| b9 = A m3 | accepted | — | Props 4.4(b), 5.1(b) |
| b10 Lemma 8.1's left side loose | accepted | (i) is kink's form; the old form kept as (v) | Lemma 8.1 |
| b11 different objects across sub-tracks | accepted | §9 | §9.1, Rem 8.2 |

**Points from sibling referee reports that concern this file.**
* Teacher referee m8: the converse of Prop 3.4 is now proved (Prop 3.4(b)).
* Teacher referee m7: Prop 3.4(c) gives the countable-class version of teacher Prop 3.2(d).
* Teacher referee M4: reconciled in §9.4(a).
* Kink referees A and B, issue 1: consistent with Remark 1.4 and §9.1.

---

## 11. Claims and statuses

| # | claim | status |
|---|---|---|
| 1.4 | PQ = data-set object on distinct inputs (non-atomic μ, standard Borel $X$) = stamped inputs with stamp-ignoring programs; on $\{0,1\}^*$ PQ ≠ FR | proved |
| 1.5 | FR on a uniform finite support, at its distinct inputs, is sampling without replacement | proved; computed i8(E) |
| 2.1 | likelihood-ratio facts; $\rho_s\le\rho_{1/2}^{2\min(s,1-s)}$ | proved; computed i1(B), rB1(1) |
| 2.2 | Ville deficiency for per-query likelihoods: adaptive inputs, repeats, misspecification; current deficiency $\delta_n$ | proved; computed i6, rB3(A),(A′) |
| 3.1 | PQ, every $1\le\lambda_n=o(n)$: MAP set $=E_0$ eventually a.s. (λ = 1 included) | proved; computed i1, i2, i4, i7, rB3(E) |
| 3.1-rem | the λ = 1 i.i.d. density case is Barron–Cover's consistency | known (secondary source; unverified) |
| 3.2 | $\Pi_\lambda$, $\Pi^\eta$ concentrate on $E$; limit share of $E_0$ is $w_\lambda$ (tempered: $w_1$) | proved; computed i1(C), rB1(2) |
| 3.2-ref | "posteriors concentrate on $E_0$" | **refuted** (two programs for ν; i1(C)) |
| 3.3 | every λ ≥ 1, any input rule, PQ or FR: MAPs eventually ν-equivalent on the run; posterior concentrates there; `thm:split:private`(iv) holds at λ = 1 | proved |
| 3.4(a) | λ = cn, $c>c^*$: $E_0$ eventually never selected | proved; computed i1(D), i8(B) |
| 3.4(b) | λ = cn, $c<c^*$: MAP set $=E_0$ eventually | proved; computed i8(B), rB7(A) |
| 3.4(c) | λ = cn, countable Kraft class: MAPs eventually in $\arg\min(c\ell+R)$; equal to it if it has one kernel | proved; computed rB7(A) |
| 4.1(i)–(iii) | length bound (with $\delta_n$ or δ*), posterior length tail, fill-in bounds, all $n$, with $\ell_0$ | proved; computed i6, rB3(B) |
| 4.1(iv′) | free-exponent finite-sample bound | proved; computed i8(A), rB8 |
| 4.1(iv)–(vi) | margin form; $n(\lambda,\ell_0,\gamma,\varepsilon)$; uniform in time; posterior (Rényi and margin forms) | proved; computed i1(A), i2(B), i4(B), rB1(2), rB3(C),(D) |
| 4.1(vii) | the tempered tail depends on the prior tail $t_L$ | proved |
| 4.2 | no finite-sample bound without a margin | proved |
| 4.3 | canonical class: $\gamma_L<g(L)$ for every computable $g$ | proved |
| 4.3-open | a computable recovery-time bound in the canonical class | open |
| 4.4(a) | the factor 1/γ is necessary (λ ≥ 2, up to constants and $\ell_0/\Delta$) | proved; computed rA1(A) |
| 4.4(b) | the factor 1/(λ−1) is necessary (up to logarithms; for $\lambda-1\gtrsim\ell_02^{-\ell_0/2}$) | proved; computed i2, i7(C), rB2(D) |
| 4.4(c) | λ > 1 delays recovery against shorter competitors | computed i1(A), rB1(3) (heuristic explanation) |
| 4.5 | the length bound of 4.1(i) is attained up to $\log(1+2^{2-k})/(\lambda-1)$ | proved; computed i7(E), rB7(B) |
| 4.6 | the failure probability is not monotone in $n$; partial fill-ins at low-noise atoms | computed rB3(C), rB9 |
| 4.7 | at λ = 1 the bound (iv′) needs $\sum_\pi2^{-s\ell(\pi)}<\infty$ for some $s<1$; class-free only for λ > 1 | proved; computed i8(A) |
| 5.1(a),(b) | λ = 1: the 1-MAP is a parity w.p. ≥ 31/32 (strict conditions) | proved; computed i2, i7, rB2(C),(D) |
| 5.1(b′) | λ = 1 in $\mathcal C_k$: $P\le2^{k+1}/n^2$ for $n\ge32$; $n_{\rm rec}\in(2^{(k-8)/2}-6,\max(32,2^{(k+1)/2}/\sqrt\varepsilon)]$ | proved; computed i7(B) |
| 5.1-tab | exact recovery times; $n_{\rm rec}(0.01)=2^{(k+4)/2}+6$ at λ = 1 for $k\in\{16,24,32,40\}$; $P\approx2^{k-1}/n^2$ within a factor 4 | computed i7(A),(B), rB2(B),(F) |
| 5.2 | a single fill-in of length $k_\nu-\log\nu(D)+O(\log n+\log d+\log R)$ | proved; computed i5, rA1(F) |
| 5.3(a) | "λ = 1 never makes the split exact", in PQ, for the MAP, asymptotically | **refuted** (Thm 3.1) |
| 5.3(a′) | the same sentence in FR | true for every λ and every procedure (Prop 7.5); λ = 1 and λ > 1 both identify on the run (Prop 3.3) |
| 5.3(b)–(d) | DS/FR: fill-in 1-MAP length in $[S-\delta(D),\ell_0+S]$; tie with $k_\nu$ or $\ell_0$ named; fill-in mass at λ = 1 | proved |
| 5.3(c)-old | lower end $-\ell^*-\delta^*$ against $\pi_\nu$ | **refuted** (rA1(E)); replaced by the $k_\nu$ form |
| 6.1(i)–(v) | PQ: $f$ (μ-a.e.) and the exact rate $p$ are selected; flips are noise; margins | proved; computed i4, rB6(A),(B) |
| 6.1(iii)-old | "rate competitors have the smallest gaps" in general | **refuted** (rA1(B), rB6(A)); true in the i4 class |
| 6.1(vi) | FR on a finite domain: the rate is a penalised empirical rate; i4 class: wrong w.p. ≥ $(7/8)^{64}$ for every λ, and 0.20–0.57 | proved (lower bound); computed i8(D), rB6(C) |
| 6.2 | every countable subclass (time-bounded, circuits, finite) | proved |
| 7.1 | shared randomness: no recovery once every program for ν is longer than $\ell^*_\lambda$ | proved (Paper 2) |
| 7.2 | non-i.i.d. inputs: on the run survives (any λ ≥ 1); with positive probability a shorter program wrong at every queried input is the eventual MAP | proved; computed i3(D) |
| 7.3(i) | PQ, finite class, unique projection kernel: shortest projection | proved |
| 7.3(ii) | PQ, two projections with different kernels, $D^*<\infty$: oscillation for fixed λ | proved; computed i3(A), i8(C), rB5(A) |
| 7.3(ii)-old | the same without $D^*<\infty$ | **refuted** (rA1(C)) |
| 7.3(iii) | FR, distinct inputs: fill-ins beat the projection iff $\lambda H(p)<1$; any $\lambda_n\to\infty$ selects the projection | proved; computed i3(B) (κ = 0 illustration), rB5(B) (explicit class) |
| 7.3(iii′) | PQ, atomic μ, same class: the coin is eventually the unique MAP for every λ | proved |
| 7.3(iv) | PQ, no projection: MAP length → ∞ | proved |
| 7.3(v) | PQ, finite class: $\lambda_n/\sqrt{n\log\log n}\to\infty$, $\lambda_n=o(n)$ selects $P_0$; the rate is sharp | proved (LIL known); computed i8(C), rB5(A) |
| KL-proj. | "the λ-MAP is eventually a shortest KL-projection" (brief) | **refuted** for fixed λ (7.3(ii) in PQ, 7.3(iii) in FR); true under 7.3(i) and 7.3(v); open in countable classes |
| 7.4 | misspecified selection memorises where $(\lambda-1)H_x<\KL_x$ | conjecture |
| 7.5 | FR: no procedure recovers every sampler exactly | proved |
| 7.6 | FR: on the run (λ ≥ 1); fill-ins leave if $\sum\beta=\infty$; finite support; concrete failure 0.1457 | proved; computed i3(C) |
| 7.7 | FR on a uniform finite support: kink's finite-sample identification applies (counted in distinct inputs) | proved (from Rem 1.5; kink results cited) |
| 8.1(i)–(iii) | the sample kink in PQ: left steepness linear in $n$; right flatness 1 beyond the window $(\ell_0+\delta^*)/(\tau-1)$ | proved; computed i8(F) |
| 8.1(iv) | "longer programs gain at most one bit per bit plus δ*" (notes.md) | **refuted**: excess $k-7$ in $\mathcal C_{k,M}$ (proved; computed i8(G), rB4) |
| 8.1(v) | notes.md's left side, $1-2^{\ell_0}e^{-\gamma_-n/2}$ | proved (superseded by (i)) |

---

## References

* A. R. Barron, T. M. Cover, "Minimum complexity density estimation", *IEEE Trans. Inform. Theory* 37(4):1034–1054, 1991. The bibliographic data were verified by search. The consistency statement is known only through the secondary source below; its content is unverified.
* J. Poland, M. Hutter, "Asymptotics of discrete MDL for online prediction", *IEEE Trans. Inform. Theory* 51(11):3780–3795, 2005; arXiv cs/0506022. A search snippet states: "If the data is generated by an i.i.d. process, then the MDL estimates are consistent [BC91]".
* P. Hartman, A. Wintner, "On the law of the iterated logarithm", *Amer. J. Math.* 63:169–176, 1941. This is the law of the iterated logarithm for i.i.d. variables with finite variance. The bibliographic details are from memory and unverified.
* S. Kakutani, "On equivalence of infinite product measures", *Ann. Math.* 49:214–224, 1948 (as cited by Paper 2; not re-checked).
* J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars, 1939 (as cited by Paper 2).
* R. Durrett, *Probability: Theory and Examples*: the strong law with $\Ex X^-=\infty$ or for nonnegative variables with infinite mean, and the recurrence of one-dimensional mean-zero random walks. These are standard; the edition and theorem numbers are unverified.
* Paper 1 (`paper/`): `prop:learn:perquery`, `prop:learn:freshnoise`, `def:versions:variants`, `prop:hist:operator`.
* Paper 2 (`paper-steeper/`): `def:setup:data`, `def:setup:objectives`, `lem:setup:hull`, `lem:split:ville`, `lem:split:stream`, `thm:split:lambda1`, `thm:split:private`, `thm:split:shared`, `thm:absorb:absorption`.
* Sibling sub-tracks:
  * `../kink/notes.md`: Thm 2.2, Def 3.1, Thm 3.2, Prop 3.5, Lemmas 5.1–5.3, Thm 5.4, Cor 5.5, Thm 5.6, Cor 5.7, Prop 5.8, Remark 5.9, open question 2.
  * `../teacher/notes.md`: Lemma 1.1, Prop 2.3, Prop 3.2, Remarks 3.4–3.5.
  * Their referee reports, as cited in §9.

---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and scipy 1.17.1. Every prover script lives in `checks/` and every referee script in `referee_code/`. Each output is the `.out` file of the same name.*

**Prover scripts carried over from notes.md (i1–i6).**
* *Relabelling (B b8).* The docstrings and printed labels were changed to this file's numbering and notation: "Thm 3(ii)" → "Thm 4.1(iv)", "Prop 12(iii)" → "Prop 7.3(iii)", "Lemma 7" → "Lemma 5.2", "l*"/"E*" → "l0"/"E0", and so on. i2's Kraft remark "< 0.33" was corrected to "= 1/4", and its assertion to `<= 0.25`. No computation was changed.
* *Re-run.* All six were re-run from a scratch copy: i3 4 s, i4 4 s, i5 5 s, i6 19 s, i2 58 s, i1 98 s.
* *Diff against the saved outputs.* i3 and i5 are byte-identical. In i1, i2, i4 and i6 the only differing lines are the relabelled ones: "E*" → "E0" and "l*" → "l0" in headers, "(< 0.33)" → "(<= 1/4)", and "Theorem 3(ii)"/"Thm 3" → "Thm 4.1(iv)". Every number is unchanged. The new outputs replaced the old ones in `checks/`.
* *What they check* (unchanged from notes.md):
  * **i1** (deterministic). Exact enumeration over all count vectors up to $n=400$ in an 8-program class on two inputs, Kraft sum 0.633.
    * (A) Exact ≤ Rényi ≤ margin at all 50 (λ, n) rows.
    * (B) Lemma 2.1(d), largest violation $2.2\cdot10^{-16}$.
    * (C) Posterior limits 0.8000, 0.8889, 0.9412.
    * (D) $c^*=0.1348$.
  * **i2** (deterministic, except (C), seed 2). Rank chain and recovery times on a geometric grid (superseded by i7). The Monte Carlo agrees within 0.004.
  * **i3** (seed 3). Props 7.2(b), 7.3(ii),(iii) and 7.6(d). The frozen value 0.1457 against simulations 0.1468 and 0.1387 (standard error 0.0035).
  * **i4** (seed 4). The noisy-parity class; margin 0.003736 = $h_=(1/8,3/16)$; empirical frequencies below the Rényi bound wherever it is below 1.
  * **i5** (seed 5). Lemma 5.2's covering step: 400/400 at the lemma's $M$.
  * **i6** (seed 6). Ville tail below $2^{-j}$ at five values of $j$; zero violations of the length bound over 4000 paths × 3 values of λ × 3000 steps.

**New prover scripts.**
* **i7_parity_exact** (deterministic, except (D2), seed 7; about 3 min). The parity classes on every integer $n$, from the closed-form GF(2) rank law.
  * (D1) Closed form against exact enumeration of all matrices with $nm\le16$, in Fractions: difference $2.2\cdot10^{-16}$.
  * (D2) Against a Monte Carlo that solves $Aw=y$ by Gaussian elimination, 6 points × 20,000 runs: within 1.04 standard errors.
  * (D3) Against i2's six printed values: equal to the printed digits.
  * (A) Certified recovery times $n_{\rm rec}(0.01)$ for $k\in\{16,24,32,40\}$ and six values of λ. The scan of each case stops only where the nonincreasing bound $2^{m^*(n)-n}$ falls below 0.01. All 24 values equal referee B's rB2(B).
  * (B) λ = 1:
    * $n_{\rm rec}-2^{(k+4)/2}=6$ for all four $k$;
    * $P(n)n^2/2^{k-1}\in[0.496,0.992]$ on $[2^{k/2+2},n_{\rm rec})$;
    * no violation of $P\le2^{k+1}/n^2$ ($n\ge32$) on any scanned $n$;
    * $P(n)$ nonincreasing up to $3.3\cdot10^{-16}$.
  * (C) With the strict conditions, the minimum probability is 0.9845 ≥ 31/32 over the stated ranges, in 15 (k, λ) cases.
  * (E) Remark 4.5 at five (k, λ): $J(\text{parity})=J(\text{coin})$ in exact arithmetic; $\Prob[A\text{ invertible}]=0.2888$; the gap to the bound equals $\log(1+2^{2-k})/(\lambda-1)$.
* **i8_revision_checks** (exact in (A), (B), (F), (G); seed 8 in (C), (D), (E); about 2 min).
  * (A) Thm 4.1(iv′) in i1's class: exact ≤ free-exponent bound ≤ Rényi bound at 16 (λ, n) points, 0 violations. At λ = 1 the free-exponent bound decays (0.42 at $n=40$, $1.2\cdot10^{-3}$ at $n=160$), while the Rényi bound stays at 18.5.
  * (B) Prop 3.4: exact $\Prob[\text{cn-MAPs}=E_0]$.
    * Below $c^*$ it rises to 1.0000 (c = 0.05) and 0.9887 (c = 0.10).
    * Above $c^*$ it falls to 0.1529 (c = 0.15) and 0.0000 (c = 0.20, 0.40).
    * The population minimiser set is {t5} below $c^*$ and {coin} above.
  * (C) Prop 7.3(v): a late switch occurs in 19/20 runs (λ = 2), 2/20 ($\sqrt n$) and 0/20 ($n^{0.6}$, $n^{0.75}$, $n/\ln n$). This is an implementation independent of rB5.
  * (D) Cor 6.1(vi), 200,000 frozen full tables. Failure probability 0.2555, 0.2555, 0.2037 and 0.5661 for λ = 1, 1.5, 2, 4 (standard errors ≤ 0.0011). The exact $(a^*,q)$-and-coin part is 0.2554, 0.2554, 0.2040 and 0.5664. The proved lower bound is $(7/8)^{64}=1.9\cdot10^{-4}$.
  * (E) Remark 1.5: 24/24 orderings; χ² = 24.2 on 23 df (p = 0.39).
  * (F) Lemma 8.1(i) and the fixed-$n$ Ville event, exactly: failure probabilities at most $3.3\cdot10^{-3}$ and $4.3\cdot10^{-3}$, below ε ∈ {0.1, 0.01}, at $n\in\{25,50,100,200\}$.
  * (G) Lemma 8.1(iv): $\Prob[\text{consistent parity}]=0.9845$ at $n=M-5$, excess $k-7$.
* *Reproducibility.* After this file was written, i7 and i8 were re-run from a scratch copy with `python3 -I`. Both outputs are byte-identical to the saved ones.
  * i8 prints one numpy RuntimeWarning on stderr. It comes from $0\cdot(-\infty)$ inside an `np.where` whose result at those entries is discarded, and is harmless.

**Referees' scripts.** All ten were copied to a scratch directory and re-run with `python3 -I`. Run times: rA1 2 s, rB1 607 s, rB2 122 s, rB3 415 s, rB4 10 s, rB5 2 s, rB6 4 s, rB7 4 s, rB8 2 s, rB9 92 s. **All ten outputs are byte-identical to the saved ones.** stderr was empty for all ten. The results used in this file:
* rA1: (A) Prop 4.4(a) constants and exact ratios ≤ 0.110; (B) the function competitor's gap; (C) the $D^*=\infty$ counterexample to old 7.3(ii); (D) tie probabilities; (E) the toy class refuting the old lower end of Prop 5.3(c); (F) arithmetic side conditions.
* rB1: Lemma 2.1 on $5\cdot10^5$ cases; Thm 4.1(iv),(vi) and Thm 3.2 on 12,600 exact rows, 0 violations; the λ = 2 vs λ = 1 comparison (Prop 4.4(c)).
* rB2: exact recovery times, equal to i7(A); Props 5.1(a),(b), 4.4(b); the attained Rényi bound in $\mathcal C_{k,M}$.
* rB3: Ville tails, i.i.d. and adaptive; Thm 4.1(i)–(iii) pathwise, 0 violations; empirical failure frequencies (Remark 4.6, Thm 4.1 reading); Thm 3.1 at λ = 1 (1857/2000).
* rB4: the counterexample to old Lemma 8.1's reading; the old left side; hull vs brute force, 24,981 pairs, 0 mismatches.
* rB5: the schedules for two projections; the explicit memoriser class for Prop 7.3(iii).
* rB6: gap closed form; fresh vs frozen noisy parity.
* rB7: λ = cn vs the population minimiser; tightness of Thm 4.1(i).
* rB8: the free-exponent bound in rB3's class.
* rB9: the cause of non-monotonicity.

**Proof checks done for this revision.**
* *Prop 3.3.* Checked step by step against `app:split:private`(iv). The only use of λ > 1 there is the Ville length bound, which confines the MAPs to a finite set; Step 1 of Thm 3.1 with $k$ replaces it. The Kakutani step needs only that $g_{n+1}$ is fixed before $y_{n+1}$ is drawn, which holds in PQ and in FR indexed by distinct inputs.
* *Prop 3.4(c).* The a.s. bounded candidate set uses $\sup_n\hat R_n(\pi_c)<\infty$, which follows from convergence to a finite limit. Ties inside $A_c$ use "same kernel ⇒ same $R$ ⇒ same length".
* *Thm 4.1(iv′).* One Markov step per program. The second displayed form was checked by summing $2^{-\lambda(\ell-\ell_0)}$ over $\ell>L$.
* *Remark 4.5.* The tie $\lambda(n+2)=\lambda k+n$ at $n=\lambda(k-2)/(\lambda-1)$, and $\delta_n=\log(2^{-k}+1/4)$, were derived by hand and checked in exact arithmetic (i7(E)).
* *Prop 5.1(b′).* The chain $P\le2^{m^*-n}\le2^{k-1}/(m^*+1)^2\le2^{k+1}/n^2$ and the case split for $m^*\ge\min(n,m_1)$ were derived by hand. i7(B) found no violation.
* *Prop 4.3.* The new computable rational $g'$ and the inequality $2^{-2h}/\beta\le g'/8<g$ were re-derived.
* *Prop 7.3(v).* Both directions use only the Hartman–Wintner law for i.i.d. increments with finite variance. (b) uses the lim sup half.
* *Lemma 8.1(iv).* The excess $k-7$ was derived by hand. It matches rB4(B)'s median excess of 17 bits at $k=24$.
* *§9.* Every sibling statement cited there was re-read in `../kink/notes.md` and `../teacher/notes.md` (versions of 2026-10-13, 14:39 and 15:03). Those files may change after this revision; the citations are to these versions.

**Literature.**
* No new searches were made.
* Barron–Cover's consistency statement remains known only through a secondary source (unverified).
* Hartman–Wintner's bibliographic details are from memory (unverified).
* Theorem 3.1 and Prop 7.3(v) do not depend on the exact form of either source beyond the standard statements quoted.

**Repository.**
* No git command was run.
* Files written or changed, all under `research/tracks/split/iid/`:
  * `notes-final.md` (new);
  * `checks/i7_parity_exact.py` and `.out` (new);
  * `checks/i8_revision_checks.py` and `.out` (new);
  * `checks/i1`–`i6` `.py` and `.out` (relabelled and re-run, as above).
* `notes.md`, the referee reports and `referee_code/` were not changed.
