# Sub-track "teacher": adversarial referee A (proofs)

*Report on `notes.md` of this folder and its scripts `checks/t1`–`t4` and `checks/tcommon.py`. Written 2026-10-13.*

* **Read.**
  * The brief `../00-brief.md`, in full.
  * `notes.md`, in full, every proof line by line.
  * Paper 2 (`paper-steeper/sections/`):
    * `setup.tex` and `app-setup.tex` (objectives, `lem:setup:hull`, `lem:setup:coding`, (F1)–(F5));
    * `split.tex` and the first half of `app-split.tex` (`lem:split:ville`, `lem:split:stream`, `thm:split:private`);
    * `algstat.tex` and `app-algstat.tex` (`prop:algstat:product`, `prop:algstat:parity`);
    * `teacher.tex` and `app-teacher.tex` in full (all four lemmas, `lem:teacher:sharpfloor`, the proof of `thm:teacher:main`, the corollaries);
    * `limits.tex` and `app-limits.tex` in full.
  * The sibling notes on which `notes.md` relies:
    * `../iid/notes.md`: §1, Lemmas 2.1–2.2, Thm 3.1, Prop 3.4, Thm 4.1, §5 (Lemma 5.2), Lemma 8.1;
    * `../kink/notes.md`: Def 3.1, Thm 3.2, Cor 3.3, §4 (Props 4.1–4.2), §5 (Lemmas 5.1–5.3, Thm 5.4), §8;
    * the two sibling referee reports `../iid/referee-A.md` (issues M1, M2) and `../kink/referee-A.md` (issue 1), where they bear on results cited here.
* **Code.**
  * The four scripts were re-run in a scratch directory (`PYTHONDONTWRITEBYTECODE=1`). Each reproduced its saved output byte for byte.
  * My probes are in `referee_code/rA1_checks.py`, with output in `referee_code/rA1_checks.out` (deterministic, Python 3.11.15). "rA1(k)" below means part (k) of that output.
* **Status tags in this report.**
  * **[checked]**: I re-derived the notes' argument line by line and found it correct.
  * **[proved]**: argued here in full.
  * **[computed: rA1(k)]**: checked by my script.

Line numbers refer to `notes.md` as of this report.

---

## Verdict

**Accept after five major revisions and the minor ones below. No fatal issue.**

* **The mathematics of the core is correct.** Lemma 1.1, Remark 1.2, Props 2.1, 2.3 and 2.4, Prop 3.1, Prop 3.2(a)–(d) as stated, Props 4.1–4.2, Lemma 5.1 and Props 5.2–5.3 are all correct. I found no false inequality in them. Every identity of Prop 2.1(c) holds algebraically, and t1 confirms them.
* **The problems are in what §3, the summaries and the Readings say about the proofs.**
  * The Reading after Prop 3.2 calls the teacher's good model an interior vertex of the population hull whose λ-interval contains $(2^{-m},c_{\rm hi}]$. This is not proved. In natural explicit codes it is false (M1).
  * Windows in λ on sampled data are stated as proved. Only population and full-table versions are proved (M2).
  * "Right flatness", the central quantity of §3, is never defined. Its two-sided bound in the claims table mixes two different objects (M3).
  * The noise side of §3 is the per-query object with fresh labels at repeats. Paper 2 excludes that object. In Paper 2's frozen object the dichotomy shown is "label redrawn versus label reused", not "noise versus errors" (M4).
  * The summary of §5 states Prop 5.3 for an unbounded range of $c$. The proposition proves a bounded range. The proof in fact gives more than the proposition states, but less than the summary (M5).
* **Scripts.** All four scripts reproduce. The certification logic of t4 is sound, and I checked it step by step. Several sentences that report t2 and t4 do not match their outputs (m10, m11).

---

## Checked and found correct

* **Lemma 1.1** [checked].
  * (i) The bound on M follows as written. $\Phi\ge\inf J'$ because $F\ge F'$.
  * (ii) Membership, the length bound, the lower-fit bound (both cases) and the upper-fit bound follow as written.
  * (iii) $m_N$ is an infimum of affine functions of $c$, so it is concave.
  * The hypothesis $g\ge0$ is needed only for $\Delta(c)\ge0$ and the "in particular" of (i) [proved]. The other conclusions hold for every real $g$. In the lower-fit case $\ell<\ell_0$ with $g+\epsilon<0$, the bound $J'\le c\ell_0+F_0+\epsilon$ gives $(c-\tau)(\ell_0-\ell)\ge-(g+\epsilon)$. Hence $F'\ge F_0-g+\tau(\ell_0-\ell)\ge F_0-(cg+\tau\epsilon)/(c-\tau)$.
* **Remark 1.2** [checked]. All three cases are correct. In the converse, "take $c=0$" should read "let $c\downarrow0$", since $m_N$ is defined for $c>0$; the conclusion is the same.
* **Remark 1.3** [checked].
  * kink Cor 3.3 is (R) with τ = 1 and $g=b_0+\kappa$.
  * kink Thm 5.4(ii) is (R) with τ = 1 and $g=\ell_0+\log(1/\varepsilon)$.
  * The window variant follows by the same one-line proof.
  * For the left kink, see m2.
* **Prop 2.1** [checked].
  * (a) follows from (o). The wedge's slanted side is the inequality at $c_{\rm hi}$. Its flat side is the risk floor and the monotonicity of $G$.
  * (b) is (D1) and (D2) rearranged. I verified that $F_0-g-\tau(\ell-\ell_0)=B_S/2^m-2^{-m}(\ell-\ell_M)$.
  * (c): $\Phi_1$, $\Delta$, $\Delta_\ell$ and the risk bound all agree with the paper's, and the displayed identity for $\Delta_\ell$ is right.
  * (d): see m5.
* **Prop 2.3** [checked]. Ville's line is (R) with τ = 1 and $g=k+\delta^*\ge0$, since $\xi_{\mathcal C}(D_n)\ge2^{-k}\nu(D_n)$. $\Phi(\lambda)\ge-\log\nu(D_n)-\delta^*$ is correct. See m3 and m4 for what the proposition claims beyond this.
* **Prop 2.4** [checked].
  * The coding lemma applies to every program.
  * $K(y_D\mid\dom D)\ge d+L_E-\delta_E-2\log(d+1)-\kappa$ follows from the decoding argument of `prop:algstat:parity`(i).
  * The rearrangement around $\ell_0$ is right, and so is the difference $\Lambda_2-b_0'=4+4\log d-2\log(d+1)$.
* **Prop 3.1** [checked].
  * On the full table $\lambda\ell+NR=NJ_{\lambda/N}$ exactly.
  * $c2^m>1$ is equivalent to $\lambda>2^{d-m}$.
  * $J_g<\Phi_2$ holds strictly on $(0,c_{\rm hi})$ because $J_g-\Phi_2$ is a maximum of strictly increasing affine functions.
  * $\Delta_\ell$ at ε = 0 is $\kappa_g+2^{d-m}\Lambda_2/(\lambda-2^{d-m})$.
  * (b) is (iv) rescaled, and (c) is Prop 2.1(b) times $N$.
* **Prop 3.2(a)–(d) as stated** [checked].
  * (a) is the strong law for nonnegative variables, with the limit $+\infty$ allowed.
  * (b) is Gibbs' inequality for a sub-probability, with the equality case.
  * (d) is correct for a finite class with a unique minimiser.
  * The hypothesis $\lambda_n\ge1$ in (a) is not used.
* **Prop 3.3(a)** [checked]. Both secants are those of explicit competitors. The covering fill-in needs the hypothesis of m16.
* **Prop 3.3(b), the sampled coding lemma** [checked], up to m6.
  * The AM–GM step gives $q_z(0)+q_z(1)\le1$.
  * $Q$ is lower semicomputable.
  * $-\log Q(S\cap Z)=\sum_zF_z/n_z$.
  * The chain-rule display is true; a proof is in m6.
* **Props 4.1–4.2** [checked]. Every secant bound uses (D1) and the stated length bounds correctly, including the side condition $d-4-\Lambda_1-\kappa>0$ for the coin.
* **Lemma 5.1** [checked].
  * Both uses of (F3) are correct, and so is the symmetry-of-information step.
  * The case split $\min\{s(t)+2\log d,K(a)\}-K(a)\le\min\{s(t)+2\log d,d\}-d$ is right.
  * $K(a)\le2d-1$ holds under the stated hypothesis on $d$.
* **Prop 5.2** [checked].
  * Lemma 5.1 gives $\ell\ge d-\min\{\cdot\}+I^+-2\log(2d)-2\kappa$ in both signs of $I$.
  * The sharp floor is monotone in $u$ (since $1-2p>0$) and in the budget.
  * $\Phi_2^\sharp\ge\Phi_2$ holds, because the first term of $LB_t$ is the paper's bound before the reduction $s(t)\le4t$.
  * I checked every use of (o) in `app-teacher.tex`'s proofs of (i) and (ii). Only "level ≥ 2 implies $J^B_c\ge\Phi_2$" is used, as the notes say.
* **Prop 5.3** [checked]. The convergence of the deviation term, the uniform lower bound on $[0,X]$, the tail bound for $x>X$, the reduction to level 2 and the conclusion are correct. $\psi_2$ is nondecreasing in $a$ and $\Psi_2$ is nondecreasing in $c$.
* **t4's certification logic** [checked].
  * Each cell uses the first term at $c_1$, the second term's coefficient at the worse end, and $\Psi_t(c_1)$, by monotonicity.
  * The infimum over $I$ is bounded below by $cI_k+{\rm Floor}(I_{k+1})$, since Floor is nonincreasing; beyond the grid it is bounded by $cI_K$.
  * Restricting $g\le40$ only weakens the floor.
  * The level-$T$ bound covers $t\ge T$ and ∞.
  * $J_g$ is taken at the upper end of each cell.
* **The class in t2 and t3** [checked]. Its Kraft sum is at most 1.
  * Each family has a 3-bit tag, and there are at most 8 families. Each tag is followed by prefix codes.
  * The rate code gives 1/2 to the deterministic flag. The rates $j/2^b$ get $\sum_b2^{b-1}2^{-{\rm RC}(b)}=\sum_b2^{-1-g(b)}\le1/2$. The total is at most 1, as `tcommon.py` asserts.

---

## Issues

### Major

**M1. The good model is not proved to be a vertex, and in natural codes its λ-interval does not contain $(2^{-m},c_{\rm hi}]$.**

*Where.*
* The Reading after Prop 3.2 (lines 329–331): "The good model is an **interior** vertex … Only $\lambda=cn$ … can stop at an interior vertex, and only for $c$ in that vertex's interval. Here that interval contains $(2^{-m},c_{\rm hi}]$."
* §0 item 4 (line 70) and §6.1 item 1 (line 579), which repeat it.
* The reporting of t2(A) (line 307, and §0 item 4): "the good model's λ-interval is (0.995, 46.2)".

*Problem.*
* **What `thm:teacher:main` gives.** It is an approximate statement. Every ε-near-optimal program is level 1, at most $\Delta_\ell$ bits longer than $d$, and so on. Also $J_c(\pi_g)\le\Phi(c)+\Delta(c)$.
  * It does not say which program minimises $J_c$.
  * It does not say that $\pi_g$, or any one program, is a vertex.
  * Prop 3.2(d) is for a finite class with a unique minimiser. It says nothing about which program that is in the canonical class.
* **Counterexample in explicit codes** [computed: rA1(A)].
  * Take the paper's instance ($d=100$, $m=20$, $p=2^{-10}$, population).
  * Compare the programs "true parity + flip rate $q$", which differ only in the code for $q$. Their risk is $H(p)+\mathrm{KL}(p\Vert q)$, and $\mathrm{KL}(2^{-10}\Vert2^{-9})=4.33\cdot10^{-4}$ bits.
  * **Code 1.** In the notes' own rate code (`tcommon.py`) the rate $2^{-9}$ costs one bit less than $2^{-10}$. So the rate-$2^{-9}$ parity beats the good model for every $c>4.33\cdot10^{-4}$. The minimiser among these programs is then:
    * rate $p$ only on $(2^{-20},4.33\cdot10^{-4}]$;
    * rate $2^{-9}$ up to $1.85\cdot10^{-3}$;
    * rate $2^{-8}$ up to $3.78\cdot10^{-3}$;
    * rate $2^{-6}$ up to $c_{\rm hi}=8.06\cdot10^{-3}$.
  * **Code 2.** With the length $2\log r$ that `def:teacher:instance` uses for $\kappa_g$, the switch to rate $2^{-9}$ is at $1.42\cdot10^{-3}$.
  * In both codes the rate-$p$ good model is not selected on most of the logarithmic width of the upper part of the window. The selected programs still satisfy every conclusion of `thm:teacher:main`(ii): they are level 1, short, and have $R>H(p)$.
* **The notes' own output shows the same thing** [computed: rA1(B), a re-reading of `t2_reuse_factor.out`].
  * In t2(A) the rate-1/16 parity is a vertex only on $(0.995,31.55)$ at $m=10$.
  * The rate-1/8 parity is the vertex on $(31.55,46.22)$.
  * The notes report the union, $(0.995,46.2)$, as "the good model's λ-interval".
* **"Only λ = cn" is not proved.**
  * Prop 3.2(a) excludes $\lambda_n=o(n)$.
  * The same argument excludes $\lambda_n/n\to\infty$.
  * But any schedule with $\lambda_n/n$ eventually in a compact subset of the vertex's open interval works as well as $\lambda=cn$.

*Fix.*
* Replace the vertex language by the near-optimal set $\mathcal N_\epsilon(c):=\{\pi:J_c(\pi)\le\Phi(c)+\epsilon\}$. The proved statement is that for $c\in(2^{-m},c_{\rm hi})$ every program of $\mathcal N_\epsilon(c)$ satisfies `thm:teacher:main`(ii) whenever $J_g(c)+\epsilon<\Phi_2(c)$.
* Say "the selected program is a vertex near the good model, not necessarily $\pi_g$". Cite rA1(A) as the reason.
* For sampled data with $\lambda=cn$: `cor:teacher:sampled` gives $\epsilon_n\to0$ for fixed $c$ and $B$. So every $\lambda$-MAP eventually satisfies (ii) with $\epsilon=\epsilon_n$, with probability $1-\delta$ (almost surely if $\delta_n$ is summable). This is what "λ = cn stops at the model" can honestly mean.
* Replace "only λ = cn" by "only schedules with $\lambda_n/n$ eventually in the model's interval".
* Report t2(A) per rate. Alternatively, define "good model" in t2 as "the true parity at any rate" and say so.

**M2. Windows in λ on sampled data are stated as proved; only population and full-table versions are.**

*Where.*
* §0 item 4 (line 66, tagged [proved; computed: t1(D), t2]): "So the window in λ is $(1,\Theta(n))$ for noise and $(n2^{-m},nc_{\rm hi})$ for errors."
* Remark 3.4, the row "schedules that select the model" and the right-flatness row for $n$ samples.
* Remark 3.5, "λ > n2^{-m}".
* §7 (line 651): "on samples Prop 3.3" answers kink open question 3.

*Problem.*
* On $n$ samples the notes prove only lower bounds (Prop 3.3(a)). Below about $\max\{1,n2^{-m}\theta_m\}$ the good model is beaten.
* That λ slightly above $n2^{-m}$ suffices on samples is not proved.
  * It is proved for equal cell multiplicities only (Prop 3.3(b)). This covers the full table and the regime where every cell is hit at most once.
  * The unequal case, which is the typical one, is open.
* The upper end $nc_{\rm hi}$ is a population quantity. On samples it holds only through `cor:teacher:sampled`, at about $10^{11}$ samples at the example's sizes.
* For $n<2^m$ the formula $(n2^{-m},\dots)$ contradicts the notes' own Prop 3.3(a). There the lower end is at least about 1, not $n2^{-m}<1$.

*Fix.*
* State the windows where they are proved:
  * population: $c=\lambda/n\in(2^{-m},c_{\rm hi}]$;
  * full table: $\lambda\in(2^{d-m},Nc_{\rm hi})$ (Prop 3.1).
* On samples, state the proved lower bound $\approx\max\{1,n2^{-m}\theta_m\}$. Mark the matching upper bound "conjecture (computed: t2(B))".
* In §7, say that Prop 3.3 answers kink open question 3 only for equal multiplicities.

**M3. "Right flatness" is undefined, and its stated two-sided bound mixes two objects.**

*Where.*
* §3.1 (line 275): "the number of data points that one bit of the 'noise' … explains".
* The claims table row 3.1 (line 678, [proved]): "total-bit right flatness in $[2^{d-m}\theta_m,2^{d-m}]$".
* Prop 3.3's title.
* Remark 3.4.
* Remark 4.3: "an incompressible error rule has rate at most $2^{-m}$".

*Problem.*
* **The lower end** $2^{d-m}\theta_m$ is the secant of one competitor, the memoriser. Below it the good model is beaten. This is a lower bound on the slope of the hull edge to the right of the good model.
* **The upper end** $2^{d-m}$ is the slope τ of a valid (R) line with offset $2^{d-m}\Lambda_2$. It is not an upper bound on that hull slope.
  * (R) allows a program at $\ell_0+x$ whose secant from the reference is up to $2^{d-m}(\Lambda_2+x)/x$.
  * What is proved is asymptotic: for $\lambda>2^{d-m}$, every λ-MAP is at most $2^{d-m}\Lambda_2/(\lambda-2^{d-m})$ bits longer than $\ell_0$.
  * In t2(A) the exact lower ends happen to lie below $2^{d-m}$. That is one explicit class, not a proof.
* So the interval in row 3.1 bounds no single quantity.

*Fix.* Define the two quantities and use each where it is meant.
* $\tau_{\rm line}$: the least τ for which (R) holds with some finite $g$. It is the flatness at large lengths.
* $s_{\rm sec}$: the slope of the hull edge (or the supremum of right secants) at the reference point.

Then Prop 3.1 proves $\tau_{\rm line}\le2^{d-m}$ and $s_{\rm sec}\ge2^{d-m}\theta_m$. Prop 3.3 proves $s_{\rm sec}\gtrsim\max\{1,n2^{-m}\theta_m\}$, and $\tau_{\rm line}\le\bar n$ under equal multiplicities. "The right flatness is the reuse factor" should then be stated for $\tau_{\rm line}$.

**M4. The noise side of §3 is the per-query object, which Paper 2 excludes. In Paper 2's frozen object, noise is on the errors' side once inputs repeat.**

*Where.*
* Prop 3.2(b).
* The Reading after Prop 3.2 ("every schedule with $1\le\lambda_n=o(n)$ ends there", via iid Thm 3.1).
* Remark 3.4's first column.
* Remark 3.5.
* §0 item 4.
* The title of §3.

*Problem.*
* Paper 2 says (`setup.tex`): "all noisy data in this paper draw each label once per distinct input (*frozen* noise)".
* Prop 3.2 and iid Thm 3.1 concern pairs i.i.d. from $\mu\otimes P^*$ with per-query likelihoods, so the label is redrawn at every repeat. Paper 2's input set is countable, so μ is atomic and inputs repeat (`../iid/referee-A.md` M1; `../kink/referee-A.md` issue 1).
* **In the frozen object, sampled noise is a fixed table $F$.** Prop 3.2(a) then applies to it with $y^*=F$.
  * Fix a sampler with nondegenerate noise and a program π₁ that memorises $F$ on finitely many atoms and uses ν elsewhere. It has $R(\pi_1)<R(\pi_\nu)$ against $F$.
  * So every $\lambda_n=o(n)$ eventually rejects the sampler.
  * This is the mechanism of iid Prop 7.5–7.6.
* So what §3 shows is "label randomness redrawn per query" against "a label function reused across queries or within cells". It is not "noise" against "errors".
  * On distinct inputs, frozen noise and idiosyncratic errors ($m=d$) both have reuse 1, as the notes themselves say for the latter.
* **Remark 3.4's first column mixes the two objects.**
  * Its left-steepness entry cites kink Thm 5.4, a frozen-noise result on distinct inputs. Its (iid) scheme is empty on Paper 2's $X$ (`../kink/referee-A.md` issue 1).
  * Its schedule entry cites iid Thm 3.1, which is per-query.

*Fix.*
* Name the object in Prop 3.2(b), the Reading, Remark 3.4 and §0 item 4.
* Add a "frozen noise" column to Remark 3.4. It coincides with the $m=d$ column on distinct inputs. With repeats, $\lambda_n=o(n)$ memorises it, by Prop 3.2(a).
* Retitle §3 along the lines of "Why fixed λ suffices when labels are redrawn, and λ ∝ n is needed when they are reused".
* State the brief's question "why do the teacher's errors, unlike i.i.d. noise, require λ ∝ n" with this qualification. If Paper 2 is to use the per-query object, it must say so in `def:setup:data`.

**M5. The summary of §5 states Prop 5.3 for a range of $c$ that the proposition does not cover.**

*Where.*
* §0 item 6 (line 80, [proved]): "holds for every $p<0.12331$ in the limit of large $m$, for $c\ge a^*(p)2^{-m}$".
* §5 "This answers … `q:limits:open`(b): a window for $p<0.123$ with $c$ well above $2^{-m}$ exists" (line 561).

*Problem.*
* **What Prop 5.3 proves.** $c\in[a2^{-m},A2^{-m}]$ for fixed $a>a^*(p)$ (strict) and fixed $A$. It needs $d2^{-m}\to0$, $\delta_S=o(2^m)$, $B=\infty$ and dyadic $p$.
* **What the summary claims.** The range $c\ge a^*(p)2^{-m}$, with no upper end and with $a=a^*$ allowed.
* **"Well above $2^{-m}$".** The phrase is supported only by the κ-dependent computations at $d=100$, $m=20$.
* **The generalisation is asserted, not checked.** The extension of `def:teacher:instance` to $s_0=p2^m$ with $p$ not a power of 2 is asserted. Rates such as 5/64 need it.

*Fix.*
* **The proof gives more than the proposition states** [proved]. The only place $A$ enters is the bound $c\,(d+\kappa_g+2\log(2d)+\kappa)\to0$. The bound $\Psi_2(c)\ge\Psi_2(a2^{-m})$ holds for every $c\ge a2^{-m}$. So the conclusion holds uniformly for $c\in[a2^{-m},c_m]$ for any $c_m$ with $c_m\,d\to0$, for example $c_m=2^{-m/2}$.
* State Prop 5.3 for that range. This does support "well above $2^{-m}$" asymptotically.
* Restate the summary accordingly: $a>a^*(p)$, and $c$ up to $o(1/d)$.
* For the generalisation, add one sentence. Only $\kappa_g$ changes, to $2\log d+K(p)+\kappa$. `lem:teacher:sharpfloor` already holds for every $s_0$. No other step of `thm:teacher:main` uses $p=2^{-r}$; I checked (o), (i), (ii)(a)–(e) and the four lemmas.

### Minor

**m1. $g\ge0$ in Prop 2.1(b) is not verified.**
* Lemma 1.1 assumes $g=\Lambda_2/2^m\ge0$. The claim that Δ equals the paper's $\max\{0,\cdot\}$ "exactly" uses it.
* The paper's stated lower bound on $\delta_S$ does not give $\Lambda_2\ge0$. At that bound, $\Lambda_2$ would be $-113$ at $d=m=100$, $r=2$ [computed: rA1(D)].
* (D2) applied to $\pi_g$ does give it: $d+\kappa_g+2^mH(p)\ge d+B_S-4-\Lambda_1$.
* *Fix.* Add this line. Alternatively, note that Lemma 1.1 needs $g\ge0$ only for $\Delta\ge0$ (see "Checked").

**m2. Remark 1.3 needs a finiteness condition.**
* Lemma 1.1(ii) at ε = 0 needs $m_N(c)>0$, and $m_N$ is an infimum. kink Thm 3.2(a) argues pointwise.
* If $N$ is infinite with real lengths, the infimum can be 0 without being attained. Example: lengths $\alpha_--1/k$, fits $L_-+\sigma/k$, and λ < σ. Then Lemma 1.1 gives nothing, while kink Thm 3.2(a) still excludes $N$.
* In prefix classes $N=\{\ell<\alpha_--w_-\}$ is finite by Kraft, so the reduction is valid.
* *Fix.* Say so, or state Lemma 1.1(ii) with a pointwise margin.

**m3. Prop 2.3 claims slightly more than Lemma 1.1 gives.**
* "These are `thm:split:private`(i)" (line 235). Lemma 1.1's lower-fit bound is the worst case over lengths.
* The paper's bound $-\log\nu(D_n)-\ell(\hat\pi)-\delta^*$ is (R) itself, and it is pointwise stronger.
* t1(C) compares the two only at $\ell=(\lambda k+\delta^*)/(\lambda-1)$.
* *Fix.* Say "(i)'s length bound follows; its fit bound is (R)".

**m4. "$m_N$ grows linearly in $n$" is false for `thm:split:private`(iv).**
* Where: line 237.
* `thm:split:private`(iv) allows adaptive inputs and concerns equivalence on the run. Its proof is Kakutani's martingale argument, which gives no rate.
* iid Lemma 8.1 is per-query and holds with a probability bound.
* kink Thm 5.4(i) holds at fixed $n$ with probability $1-2\varepsilon$.
* *Fix.* Restrict the sentence to those two results and state their probability qualifiers.

**m5. Lemma 1.1's third inequality is used without (R).**
* Prop 2.1(d) and Prop 4.1(b) use it, and Lemma 1.1 as stated assumes (R) and $c>\tau$.
* (R) holds trivially with τ = 0 and $g=F_0$, so the use is valid.
* *Fix.* Say so, or make the third inequality a separate item that needs only $\pi\in M$ and $\ell\ge\ell_M$.

**m6. Prop 3.3(b) drops additive terms.**
* **The sampled coding lemma omits $m$.** The cells need $m$, which $\dom D_n$ does not determine. So the bound is $K(S\cap Z\mid\pi,a,\dom D_n)\le\sum_zF_z/n_z+2\log m+\kappa$. The paper's `lem:teacher:coding` pays the same $2\log m$.
* **The offset of the equal-multiplicity line** is $\bar n(\beta+O(\log d))$ around $\ell_0=d$, not $\bar n\beta$.
* **The chain-rule display is only sketched**, yet the claims table marks the dependent line "proved". It is true [proved]:
  * $C\le K(\pi\mid a,\dom D_n)+K(S\cap Z\mid\pi,a,\dom D_n)+\kappa$;
  * $K(\pi\mid a,\dom D_n)\le K(\pi\mid a,K(a))+K(K(a))+\kappa$;
  * $K(\pi\mid a,K(a))\le\ell+K(a\mid\pi)-K(a)+\kappa\le x+4+2\log d+\kappa$;
  * $K(K(a))\le2\log(2d)+\kappa$.
* *Fix.* Insert this proof and the two missing terms.

**m7. Prop 3.2(d) is stated for a finite class, but the Reading applies it to the canonical class.**
* The finite class is unnecessary [proved]. A $cn$-MAP has $\ell\le\ell(\pi_c)+\hat R_n(\pi_c)/c$, which is a.s. bounded when $R(\pi_c)<\infty$. With integer lengths and Kraft, finitely many candidates remain.
* *Fix.* State (d) for countable Kraft classes.

**m8. The converse attributed to iid Prop 3.4 is not proved there.**
* Line 332: "With λ = cn the noise case also works if $c$ is below the truth's left steepness (iid Prop 3.4)". iid Prop 3.4 proves only failure above that steepness.
* The converse holds by a short argument, for the per-query object and with a unique shortest equivalent program:
  * longer programs are excluded by Ville, $cn(\ell-\ell^*)>\ell+\delta^*$ eventually;
  * the finitely many shorter ones are excluded by the strong law.
* *Fix.* Give this argument.

**m9. Remark 3.4 drops terms and mixes readings.**
* kink Thm 5.4's steepness is quoted without its $-2\log(1/\varepsilon)$ term and without the probability $1-2\varepsilon$.
* "≥ n c_hi (population)" places a population constant in a total-bits row for samples.

**m10. Several numbers do not match the outputs.**
* $L_S$ at $d=20$, $m=12$, $p=2^{-10}$ is 43.4 bits, not 41 (line 304). $\theta_m=0.547$ is right [computed: rA1(C)].
* "$\theta_m=1-O(\cdot)$" should be "$1+O(\cdot)$": the sign is not determined.
* "δ_S = 20 changes the windows by at most a few percent" (line 545) is false at $p=15/128$. The upper end falls by 24% and the lower end rises by 11% [computed: rA1(C), from `t4_junta_window.out`].
* **The certified upper ends are conservative** by up to one grid cell, a factor 1.0275.
  * This is why the certified end at $p=2^{-10}$ is $7.88\cdot10^{-3}<c_{\rm hi}=8.06\cdot10^{-3}$, although $\Phi_2^\sharp\ge\Phi_2$ makes the true window contain the paper's.
  * Say so next to the table, or the table reads as if §5 were weaker than the paper at $p=2^{-10}$.

**m11. The reporting of t2 does not match its output.**
* "λ = 2 keeps the good model in every sample up to $n=2^m$" (line 371) is false. The fraction is 10% at $n=32$ and 70% at $n=64$ [computed: rA1(B)]. The $n=32$ row is omitted from the notes' table.
* "λ = 4n2^{-m} keeps it at every n ≥ 64" (line 372) cites a column that reports the mode, over samples, of the MAP's family name. "F1" there includes any parity and any rate.
* "from about 1 at $n\ll2^m$" understates the gap: $\tau_n=0.64$ at $n=32$.
* "Exact hull of the class" is not quite right. For $n_{\rm err}>64$, F3's $j$ ranges over $\{0,\dots,64\}$, powers of two and $n_{\rm err}$ only. Its rate is below 1, below $\tau_n$, so this should not change the intervals, but the docstring should say why.

**m12. The comparison of envelope and good model omits a term.**
* Line 435: "its two deterministic flags cost 2 bits, against 9 for the rate 1/16".
* The envelope also pays $g(j')=5$ bits, so the comparison is 7 against 9.

**m13. "Window" in Prop 4.1(b) is undefined.**
* "the window of `thm:teacher:main`, read for this rule, cannot extend below $c_{\rm env}$" (line 402) conflicts with `limits.tex`. There `thm:teacher:main` applies to this rule with its $\delta_S$ (about 1,300 bits), with weaker bounds.
* *Fix.* Define the window meant: the set of $c$ at which some program with $R\ge H(p)$ is ε-near-optimal.

**m14. The window in Prop 5.2 need not be an interval.**
* Replacing $\Phi_2$ by $\Phi_2^\sharp$ in (i) also replaces "$c\le c_{\rm hi}$" by "$J_g(c)\le\Phi_2^\sharp(c)$".
* $\Phi_2^\sharp$ is an infimum of maxima of concave functions and need not be concave. So $\{c:J_g\le\Phi_2^\sharp\}$ need not be an interval.
* *Fix.* Say "window" means a union of certified cells.

**m15. Some status labels are wrong.**
* Table 2.2 "[proved: by inspection]" is an interpretive mapping and should be [remark].
* "convex in $y=\sqrt x$, as checked on a grid" (line 524) can be proved: the function is $apy^2$ plus $-\log$ of an affine function, a sum of convex functions. The script's docstring says this.
* "(iii) and (iv) … are not geometry" is inaccurate. (iv) is a secant statement, and it is used as one in Prop 3.1(b) and Prop 4.2. (iii) is the $c<\tau$ side of the same argument.

**m16. The decoder in Prop 3.3(a) must be total on $\{0,1\}^{\le d}$.**
* The covering fill-in of iid Lemma 5.2 uses $\pi_g$ as decoder.
* Lemma 5.2's proof needs the decoder's kernel to be a computable measure on all inputs of length at most $d$ (`../iid/referee-A.md` M2).
* *Fix.* Choose $\pi_g$ total there and say so.

**m17. Prop 2.4(ii) compares only the length bounds.**
* The sufficiency line improves $g$, and so the length bound.
* It has $\ell_M=0$, so its Δ in Lemma 1.1(i) is $b_0'+(\lambda-1)(d+\kappa_g)$, much worse, and so is the third inequality.
* *Fix.* Say "improves the length bound".

**m18. t1(D)'s exact agreement is partly by construction.**
* In `fulltable_md_check` the "corollary" and "Lemma 1.1" forms are the same typed expression (`cor_l` and `kl`, `cor_F` and `kF`).
* The only real check is the substitution $c2^m-1=\lambda-1$ in the general $\Delta_\ell$ and risk formulas.
* *Fix.* Describe it that way in the verification log.

**m19. The paper allows non-integer $B$, but the coding lemma needs integer $B$.**
* Inherited from the paper. `thm:teacher:main` allows any $B\in[\log(1/p),\infty]$, but `lem:teacher:coding` is stated for integer or infinite $B$, and Prop 2.1 uses (D2) through it.
* For non-integer $B$, use $\lfloor B\rfloor\ge r$ in $\Lambda_1$. $R_{\lfloor B\rfloor}\le R_B$ makes this valid.
* Every number in the notes uses $B=\infty$ or $B=30$.

---

## The brief's checklist

* **Hidden hypotheses.**
  * $g\ge0$ (m1).
  * A finite $N$ for the strict margin (m2).
  * A finite class in Prop 3.2(d), unnecessary (m7).
  * A decoder that is a measure (m16).
  * Integer $B$ (m19).
* **Quantifier order.** Prop 3.2(a) is pointwise, per program, and is stated so. The uniform statement "from some $n$ on every MAP …" is taken from iid Thm 3.1 for noise.
  * For the teacher it also holds [proved]: with $\lambda_n\ge1$, MAP lengths are at most $\ell(\pi_b)$, so finitely many candidates remain.
  * The Reading's "ends at the least-risk vertex" needs the object of M4.
* **Measurability.** $X$ is countable. No issue.
* **Semimeasure versus measure.**
  * Prop 3.2(b) handles sub-probabilities correctly.
  * The sampled coding lemma is a semimeasure by AM–GM.
  * The covering fill-in needs a measure (m16).
* **Ties and non-uniqueness of MAPs.**
  * Prop 3.2(d) assumes a unique minimiser.
  * The "good model's interval" in t2 and t3 is a union over rates (M1, m11).
  * The vertex claim fails (M1).
* **Finitely many candidates.** Yes in Prop 3.2(d) and in the teacher case. For the noise case it comes from iid Thm 3.1's tail argument.
* **μ-a.e. equivalent programs.** These are used only in population form (Prop 3.2(b)). No issue.
* **Kraft sums.** The t2 and t3 classes have Kraft sum at most 1, as checked.
* **Additive log terms.**
  * $2\log m$ and $\bar n\,O(\log d)$ (m6).
  * $-2\log(1/\varepsilon)$ (m9).
  * Lemma 5.1's κ's are counted in t4 (4κ).
* **Repeated inputs on atomic μ.** M4.
* **Statements no stronger than the proofs.** M1, M2, M3, M5, m3, m4, m8, m13.

---

## Verification log

*Run 2026-10-13 with Python 3.11.15. All files written by this referee are under `research/tracks/split/teacher/`: this report, and `referee_code/rA1_checks.py` with its output `referee_code/rA1_checks.out`. No git command was run.*

* **Reproduction.**
  * `t1_kink_instances.py`, `t2_reuse_factor.py`, `t3_second_kink.py` and `t4_junta_window.py` were copied to a scratch directory with `tcommon.py` and run with `PYTHONDONTWRITEBYTECODE=1`.
  * All four exited 0, and each output is byte-identical to the saved `.out` file.
  * Nothing was written to `checks/`.
* **rA1_checks.py** [deterministic; under 1 s].
  * (A) Population minimiser among "true parity + rate $q$" at $d=100$, $m=20$, $p=2^{-10}$, for two rate codes, on a 20,001-point geometric grid of $c\in(2^{-20},c_{\rm hi}]$ ($\kappa=0$ and 30). The first crossover is also computed in closed form. The rate-$p$ program is the minimiser only up to $4.33\cdot10^{-4}$ (code 1) or $1.42\cdot10^{-3}$ (code 2).
  * (B) Re-reading of `t2_reuse_factor.out`. The rate-1/16 and rate-1/8 vertex intervals are given separately. good@2 is 0.10, 0.70, 1.00 and 1.00 at $n=32$, 64, 128 and 256.
  * (C) $L_S=43.41$ at $d=20$, $m=12$; $\theta_m=0.547$; the δ_S = 20 effect at $p=15/128$ (factors 1.115 and 0.762); the t4 grid ratio 1.0275.
  * (D) $\Lambda_2$ at the paper's stated lower bound on $\delta_S$, for four instances. It is negative for three of them, so that bound alone does not give $g\ge0$, while (D2) at $\pi_g$ does.
* **Proof checks by hand.**
  * Lemma 1.1, including the version with real $g$ (see "Checked").
  * The identities of Prop 2.1(c).
  * (R) for Props 2.1(b), 2.3 and 2.4.
  * Prop 3.1(a)–(c).
  * Prop 3.2(a), (b) and (d), and the countable extension of (d) (m7).
  * The sampled coding lemma and the chain-rule display (m6).
  * Props 4.1 and 4.2.
  * Lemma 5.1.
  * Prop 5.2, against every use of (o) in `app-teacher.tex`.
  * Prop 5.3, and its extension to $c\le c_m$ with $c_md\to0$ (M5).
  * The certification logic of t4.
  * The Kraft sums of t2 and t3.
* **Not checked.**
  * The sibling results cited as such: iid Thm 3.1, Lemma 5.2 and Lemma 8.1; kink Thm 3.2, Cor 3.3, Props 4.1–4.2 and Thm 5.4. I read them only as far as needed for the citations, and noted the sibling referees' issues where they apply (M4, m16).
  * The numerical values of t1(B)'s 17,411 comparisons beyond the code review.
