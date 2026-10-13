# Referee A (proofs): sub-track "iid", target T1

*2026-10-13.*

**What I read.**
* `notes.md`, all 601 lines, and the brief `../00-brief.md`.
* Paper 2:
  * `setup.tex`;
  * `split.tex` and `app-split.tex` (`lem:split:ville`, `lem:split:stream`, `lem:split:hash`, `thm:split:lambda1`, `thm:split:private`);
  * `thm:absorb:absorption` in `absorb.tex`.
* Paper 1: `prop:learn:perquery` and `prop:learn:freshnoise`, with their proofs.
* The scripts `checks/i2` and `checks/i3`, with their outputs.

**Independent code.** `referee_code/rA1_checks.py`, with its output `referee_code/rA1_checks.out`.

**Repository.** I ran no git command. All files are under `research/tracks/split/iid/`.

---

## Verdict

**The core is sound. No issue is fatal, but the scope of several statements must be fixed before they go into Paper 2.**

**What checks out.**
* I re-derived these line by line and found them correct as stated:
  * Lemmas 2.1 and 2.2;
  * Theorem 3.1, for every schedule $1\le\lambda_n=o(n)$, **including λ = 1**;
  * Theorem 3.2 and Prop 3.4;
  * Theorem 4.1 (i)–(vii);
  * Props 4.2, 4.3 and 4.4(a);
  * Prop 5.1(a);
  * Lemma 5.2, with its own $k$;
  * Prop 7.2(b), Prop 7.3(i) and (iv), Props 7.5 and 7.6;
  * Lemma 8.1, for per-query data.
* The numerical constants 8.66, 0.083 and $1+1/a$, and Lemma 5.2's bound on $\lceil\log M\rceil$, also check out [computed: rA1(A), (F)].
* The "correction to the brief" is right. Theorem 3.1's proof (Ville's inequality plus the prior tail) never uses λ > 1, so at λ = 1 two-part selection is also eventually exact, in the per-query i.i.d. object.

**What needs fixing.** The problems are in the *scope* of several statements, not in the central arguments.
* **M1, major.** "Or distinct inputs" silently admits Paper 2's frozen data sets. There the statements are false, and the notes' own Prop 7.6(d) is a counterexample.
* **M2, major.** "Paper 2's statements with $k$ hold with $\ell^*$" is not valid for constructions that use the sampler's program as a decoder (Lemma 5.2). It is also not valid without an input law μ.
* **M3, major.** Prop 7.3(iii) and its summary line state the fill-in/projection threshold for more objects than are proved. They omit that in the notes' main object the coin always wins.
* **Minor.** Two statements are false as written but have one-line fixes (m1, m2). Several statuses claim more than is proved (m6).

---

## Checked and found correct

These are the points that need care, with what I verified. They are worth keeping in the paper's proofs.

* **Lemma 2.1.**
  * (a) The sum runs over $\{y:\nu(y\mid x)>0\}$, so defective kernels and labels outside the support are handled.
  * (b) The Jensen equality case is right:
    * equality forces $\nu_\pi=c\nu$ on $\operatorname{supp}\nu(\cdot\mid x)$ with $c=1$, and then $\sum_y\nu_\pi\le1$ forces $\nu_\pi=\nu$;
    * the integrability $\Ex(\log Z)^+\le\log e/e$ is right;
    * the strong law with $\Ex X^-=\infty$ is standard; when $Z=0$ has positive probability, $\Lambda_n$ is eventually 0, which is trivial.
  * (c) The Hölder equality case is right.
  * (d) The Hölder exponents in both ranges, $2(1-s)+(2s-1)=1$ and $2s+(1-2s)=1$, are right, and so is $(1-\gamma)^a\le1-a\gamma$.
* **Lemma 2.2.**
  * The initial value is $\sum2^{-\ell}\le1$.
  * The supermartingale property needs only that $x_{n+1}$ is chosen before $y_{n+1}$ is drawn, so adaptive inputs and fresh labels at repeats are fine.
  * Part (b), with $\Lambda^\eta$, is right.
* **Theorem 3.1.** Each step checks out.
  * MAPs exist: $J\ge\lambda\ell\ge\ell$, and Kraft allows at most $2^m$ programs of length $m$.
  * (3.1) holds on the a.s. event $L_n(\pi_0)=L_n(\nu)$.
  * Step 1: $B_L$ decreases in $L$, and $\Prob(B_L)\le2^{\ell^*}t_L$.
  * Step 2 covers its three cases correctly.
  * Ties are handled:
    * all of $E^*$ share one value of $J$;
    * $E\setminus E^*$ fails (3.1) at every $n$;
    * every non-$E$ program eventually fails the *non-strict* (3.1), so nothing outside $E^*$ ever ties with it.
  * Quantifiers: $n_0$ is random, and the statement is "a.s., from some $n$ on", as claimed.
* **Theorem 3.2.**
  * The Borel–Cantelli choice $t_{L_j}\le4^{-j}$ is right.
  * The limit shares $w_\lambda$ are right.
  * The refutation of "concentration on $E^*$" is valid. The values 0.8, 0.8889 and 0.9412 check.
* **Theorem 4.1.**
  * (i)–(iii): the exponent arithmetic is right, including $\lambda\delta^*$ in (iii) and the tempered normaliser $2^{-\ell^*}$.
  * (iv):
    * the event inclusion also covers the case where no $E^*$ program is a MAP;
    * the first term needs $\Prob[\delta^*>j]\le2^{-j}$, which Lemma 2.2(a) gives;
    * Markov for $\Lambda^{1/\lambda}$ is right;
    * $\min(1/\lambda,1-1/\lambda)=\min(1,\lambda-1)/\lambda$ is right;
    * the sample size $n(\lambda,\ell^*,\gamma,\varepsilon)$ is right.
  * (v): $1/(1-e^{-a})\le1+1/a$ is right.
  * (vi): $\|\cdot\|_\lambda\le\|\cdot\|_1$ is right.
  * (vii): Hölder is right.
* **Props 4.2 and 4.4(a).**
  * The mean, variance, Chebyshev and Taylor-sign steps are right.
  * Exact binomial values are at most 0.11 times the stated bound $8.66/(\lambda\Delta)$ on a grid of 30 cases [computed: rA1(A)].
  * $\gamma/\varepsilon'^2\in[0.500,0.507]$, and $n_1\ge0.083\lambda\Delta/\gamma$ holds with slack factor 1.015 [computed: rA1(A)].
* **Prop 4.3.**
  * The perturbation $\nu_j$ is lsc and in the class.
  * The bound $\Hel\le\tfrac12\sum(P-Q)^2/P$ is right.
  * $j(L)\ge h(L-\ell^*-\kappa)$ follows directly from $K(h(m))\le2\log m+\kappa_h$.
  * One technicality is in m8.
* **Prop 5.1(a).** The inequality is strict because $k\ge8$. The rank bound $2^{n-M}=2^{-5}$ is right.
* **Lemma 5.2.**
  * $|\mathcal D_R|\le2^{n(d+1+\log|Y|)}$.
  * $M>2^{R+2}\ln A$.
  * The union bound and the decidability of coverage are right.
  * $\lceil\log M\rceil\le R+4+\log n+\log(d+1+\log|Y|)$, with at least 1 bit of slack on a grid [computed: rA1(F)].
  * All of this is valid with $k$ the length of a program for the computable *measure* ν. See M2.
* **Prop 7.2(b).** Kakutani gives $\Lambda_\infty>0$ with $\Ex\Lambda_\infty=1$. The strict MAP on $\{\Lambda_\infty>2^{-\lambda\Delta}\}$ is right.
* **Prop 7.3(i), (iv).**
  * The integrability of the difference of log-ratios is right.
  * In (iv), $d_L>D^*$ holds because a finite minimum of values above an unattained infimum is above it.
* **Props 7.5 and 7.6.**
  * Mutual absolute continuity under a one-factor change is right.
  * $E_\nu\cap E_{\nu'}=\emptyset$.
  * The exact value $1-(63/64)^{10}=0.1457$ is right.
* **Lemma 8.1.**
  * Markov for $\Lambda^{1/2}$ with $t=\gamma_<n\log e$ is right.
  * The count of programs shorter than $\ell^*$ is at most $2^{\ell^*-1}$, which is even better than stated.

---

## Major issues

### M1. "Distinct inputs" silently admits Paper 2's frozen data sets, where several statements are false

**Where.**
* §0 item 1: "All theorems of §3–§6 are about this object".
* Remark 1.4(a): "every theorem of §3–§6 applies to Paper 2's data sets".
* Cor 6.1, setting: "Data are per-query i.i.d. …, or distinct inputs".
* Lemma 8.1, setting: "(or distinct inputs)".
* §5 (Lemma 5.2, Prop 5.3(b)–(d)), which is in fact about single data sets on $\{0,1\}^*$, not about the per-query object.

**Problem.**
* Paper 2's input set is $X=\{0,1\}^*$ (`def:setup:data`). Every μ on it is atomic.
  * The only data sets with i.i.d. inputs and distinct inputs there are the frozen data sets of Def 1.3.
  * For those, Prop 7.5 shows that no procedure recovers every sampler.
* **Cor 6.1(i) is false for frozen data, and Prop 7.6(d) is a counterexample.** Prop 7.6(d) satisfies every hypothesis of Cor 6.1:
  * $f\equiv0$ is total computable;
  * $p=1/64$ is computable;
  * the class has Kraft sum $2^{-5}+10\cdot2^{-9}<1$ and contains $\nu_{f,p}$.

  Yet for λ < 1.5 the λ-MAP is eventually some $e_j\notin E$ with probability 0.1457 (proved there; computed in i3(C)).
* **Lemma 8.1 is false for frozen data on a finite support, with $n$ read as the number of draws.**
  * $D_n$ is eventually a fixed data set $D_\infty$, so $-\log L_n(\pi)-S_n$ is eventually constant.
  * But the lemma asserts a drop of $\gamma_<n\log e\to\infty$ with probability tending to 1.
  * The step that breaks is $\Ex\Lambda^{1/2}=\rho_{1/2}^n$. It needs i.i.d. pairs. The distinct inputs of a frozen data set on atoms are not i.i.d., so the step fails whether $n$ counts draws or distinct inputs.
* **Remark 1.4(a) covers no data set that Paper 2 has.**
  * The non-atomic case of Remark 1.4(a) needs an uncountable $X$.
  * But Prop 4.3, Lemma 5.2, Prop 5.3 and Cor 6.1(v) are stated for the canonical class on $\{0,1\}^*$.
  * So "applies to Paper 2's data sets" is vacuous for Paper 2 as written.

**Fix.**
1. In §3, §4, §6 and §8, replace "or distinct inputs" by "or distinct inputs drawn i.i.d. from a non-atomic μ on an uncountable input space (not Paper 2's $X$)".
2. In Remark 1.4(a) and §0 item 1, say that on $X=\{0,1\}^*$ only the per-query object is covered by §3, §4, §6 and §8, and that the frozen object is governed by Props 7.5–7.6.
3. Say that Lemma 5.2 and Prop 5.3(b)–(d) are statements about single data sets with distinct inputs.
4. In Cor 6.1, add one sentence citing Prop 7.6(d) as the frozen-noise counterexample.

### M2. $\ell^*$ versus $k$: the blanket transfer in Def 1.2 fails for decoder constructions

**Where.**
* Def 1.2, second bullet: "Paper 2's statements with $k$ hold with $\ell^*$".
* §0 item 4: "a single deterministic fill-in of length $\ell^*-\log\nu(D)+\dots$".
* Prop 5.3(c).
* The §5 table row "best single fill-in vs sampler".
* Prop 7.2(a).

**Problem.**
* An $E^*$-program $\pi_0$ has a kernel $\nu_0$ that equals ν only μ-a.e. Off $\operatorname{supp}\mu$ it may be a semimeasure, not a measure.
* **What transfers.** Statements that only compare $J$ on the sample transfer to $\ell^*$, because $L_n(\pi_0)=L_n(\nu)$ almost surely. These are the Ville upper bounds: Thm 4.1(i)–(iii) and `thm:split:private`(i)–(iii).
* **What does not transfer: Lemma 5.2.**
  * Its proof computes $q(D')$ to within $2^{-R-2}$ for *every* data set $D'$ with $n$ inputs of length at most $d$. It does so to *decide* the finite set $\mathcal D_R$ and then search for a covering family.
  * With a decoder that is defective at one such input, this computation need not halt.
  * Then $\mathcal D_R$ is only c.e., and "the first covering family" is not computable.
  * So the fill-in of length $\ell^*-\log\nu(D)+O(\log)$ in §0 item 4 is not proved.
* **What does transfer, on sampled data: `lem:split:stream` and `lem:split:hash`.**
  * Certifying or decoding at an input $x$ needs $\nu_0(\cdot\mid x)$ to be a measure only at that $x$.
  * The fill-in may be undefined elsewhere. Define $\varphi_w(x)$ as the first certified label, so that it is a function.
  * Prop 5.3(d) relies on this, and the notes should say so.
* **Prop 5.3(c) mixes the two lengths.**
  * With $\pi_\nu$ a length-$k$ program for the measure ν, which is the decoder of Lemma 5.2, Ville gives $J_1(\varphi)-J_1(\pi_\nu)\ge-k-\delta^*$, not $-\ell^*-\delta^*$.
  * Toy class [computed: rA1(E)]:
    * the shortest $E$-program has length 3 and is defective off $\operatorname{supp}\mu$;
    * the program for ν has length 12;
    * the deterministic tables have length 9.
  * In it, the stated lower end, $-\ell^*-\delta^*=-2.32$, fails: the actual value is −7. The $k$-version, −11.32, holds.
  * The toy class is not $\Hcl{\times}$. It shows that the stated inequality does not follow from the argument given.
* **Prop 7.2(a), adaptive inputs.**
  * It cites Thm 4.1(i)–(iii).
  * Without μ, the sets $E$ and $\ell^*$ are undefined.
  * An adaptive rule can query the μ-null set where $\pi_0$ and ν differ.
  * These parts hold with $k$, the length of a program for ν itself.

**Fix.**
* Define $k_\nu$ as the least length of a program in $\mathcal C$ whose kernel is a computable *measure* equal to ν, on all inputs (or on all inputs of length at most $d$). Note that $\ell^*\le k_\nu$.
* State Lemma 5.2, the upper end of Prop 5.3(c), §0 item 4 and the §5 table with $k_\nu$.
* In Prop 5.3(c), write both ends for the same program. If two different programs are meant, name them.
* Replace the sentence in Def 1.2 by: "Statements that compare $J$ with a program for ν on the sample hold with $\ell^*$. Constructions that use ν's program as a decoder need a program whose kernel is a measure at every input it must handle. On sampled data this holds for `lem:split:stream` and `lem:split:hash` with an $E^*$-program. Lemma 5.2 needs $k_\nu$."
* In Prop 7.2(a), use $k$.

### M3. Prop 7.3(iii) and its summary are broader than the proof

**Where.**
* Prop 7.3(iii), setting: "non-atomic μ, or the frozen data set …".
* §0 item 6: "with deterministic programs in the class, the λ-MAP is eventually a fill-in for $\lambda<1/H(p)$ …".
* The status table rows "7.3(iii)" and "KL-proj."

**Problem.**
* **The non-atomic alternative is unproved.**
  * The small-λ half rests on Lemma 5.2.
  * Lemma 5.2 is proved only for inputs in $\{0,1\}^{\le d}$: it uses the count $2^{n(d+1+\log|Y|)}$ and finite tables.
  * For non-atomic μ on an uncountable $X$ there is no $d$, and no fill-in construction is given.
* **The object is not stated in the summary.**
  * Prop 7.3 is headed "per-query i.i.d. data", but (iii) needs distinct inputs.
  * In the notes' main object, per-query data on an atomic μ, the opposite holds: the coin is eventually the unique MAP for every λ ≥ 1. The notes' own "Readings" after Prop 7.3 say this.
  * §0 item 6 states the threshold without naming the object. So, for the per-query object, only (ii) refutes the brief's KL-projection conjecture.
* **Kraft.**
  * "The class of $W$ plus one coin program" need not satisfy Kraft. The initial value in Lemma 2.2 is then up to $1+2^{-\ell_c}$.
  * This does not change the conclusion, since δ* is still a.s. finite. But Lemma 2.2 assumes Kraft, so it should be stated.

**Fix.**
* Restrict (iii) to frozen data sets on $\{0,1\}^*$ from an infinite-support μ with $\log d_n=o(m_n)$, or prove a version of Lemma 5.2 for oracle inputs.
* Add "on distinct inputs (frozen data)" to §0 item 6 and to the status row 7.3(iii).
* In the KL-projection row, say that (ii) refutes the conjecture in the per-query object, and (iii) refutes it in the frozen object.
* Make the class prefix-free, for example $0\cdot\{W\text{-programs}\}\cup\{1^{\ell_c}\}$, or state the δ* tail as $(1+2^{-\ell_c})2^{-j}$.

---

## Minor issues

**m1. Prop 7.3(ii) needs $D^*<\infty$. As written, the statement is false.**
* The proof uses "mean $D(\pi_1)-D(\pi_2)=0$". This is $\infty-\infty$ when $D^*=\infty$, in which case $P=\mathcal C$.
* *Counterexample.*
  * Setting:
    * $\mu(x)\propto x^{-3}$ on $x\ge1$, with fair-coin labels;
    * $\pi_1=c(x)\cdot\Bern(1/4)$ with $\ell=2$;
    * $\pi_2=c(x)\cdot\text{coin}$ with $\ell=5$;
    * $c(x)=2^{-x^2}$.
  * Then $D(\pi_1)=D(\pi_2)=\infty$, because $\sum_xx^2x^{-3}=\infty$. So both are in $P$.
  * The log-ratio is bounded, with mean $\tfrac12\log(4/3)>0$. So $\pi_2$ is eventually the unique MAP forever, and there is no oscillation.
  * In 20 runs of $2\cdot10^5$ steps, the last time $\pi_1$ was the MAP was at most $n=71$ [computed: rA1(C)].
* *Fix:* add $D^*<\infty$. The example in the notes satisfies it.

**m2. Cor 6.1: details of the statement.**
* (i) For sub-probability kernels, "$\nu_\pi(1\mid x)=p+(1-2p)g(x)$" does not give π ∈ E. Require $\nu_\pi(\cdot\mid x)=\nu_{f,p}(\cdot\mid x)$, both labels.
* (iii) "Rate competitors have the smallest gaps" is false in general.
  * A competitor $(g,p)$ with $g\ne f$ on a set of small μ-mass has gap $\mu(g\ne f)\,h_{\ne}(p,p)$.
  * With μ uniform on $\{0,1\}^7$ and one differing input, this is 0.0026, below the rate competitor's 0.0037 [computed: rA1(B)].
  * Restrict the remark to the parity class of i4, where $\mu(g\ne f)=1/2$.
* (iv) $p=1/2$ lies outside the stated range $[0,\tfrac12)$.
* (v) Prop 4.3 assumes β > 0, so it does not cover $p=0$.

**m3. Ties in Prop 4.4(b) and Prop 5.1(b).**
* The proofs show only that some consistent parity has $J\le J(\text{coin})$. At equality in the stated conditions the coin is also a MAP, so "the λ-MAP is a parity, not the truth" does not follow.
* The strict claim does hold numerically at every boundary case tried: $\Prob[\text{a parity strictly beats the coin}]=0.9692\ge31/32=0.96875$ [computed: rA1(D)]. But the margin is $4\cdot10^{-4}$, and the proof does not supply it.
* *Fix:* use "<" in the condition, so that $m=n+4$ and the proof's rank bound give 15/16. Alternatively, conclude "the set of λ-MAPs contains a parity".

**m4. Quantifiers and constants in §0 item 3.**
* "Three bounds hold for all $n$ simultaneously" is not right for the third. Thm 4.1(iv) is a per-$n$ statement; the simultaneous version is (v), with the extra $\ln(1+1/a)$.
* "Both the margin (factor 1/γ) and the factor 1/(λ−1) are necessary, up to constants" claims more than Prop 4.4 shows:
  * (a) is shown for λ ≥ 2 and up to the ratio $\ell^*/\Delta$;
  * (b) is up to logarithmic terms, and only while $\lambda-1\gtrsim\ell^*2^{-\ell^*/2}$, since its lower bound needs $\ell^*>6+2\lceil\log(n+6)\rceil$;
  * the two are shown in separate classes, so the joint factor $1/(\min(1,\lambda-1)\gamma)$ is not shown to be necessary.

**m5. Hidden side conditions.**
* Prop 4.2's conclusion needs $\varepsilon<1-8.66/(\lambda(\ell^*-1))$. The exact failure probability at $n_1$ is about 0.9 [computed: rA1(A)], so this is a weakness of Chebyshev, not of the claim.
* Prop 4.4(a) and Prop 7.2(b) need $\ell^*-\Delta\ge1$ for Kraft.
* Prop 5.1 should read $1\le m\le D$. With $m=0$ the Kraft sum is $0.75+2^{-k}$, not $0.25+2^{-k}$; i2 uses $m\ge1$.
* Lemma 8.1 should set $\gamma_<:=+\infty$ when no program is shorter than $\ell^*$.
* Prop 7.1 needs $U(o)>0$.

**m6. Statuses that claim more than is proved.**
* Prop 4.4(c) sits under a "[proved]" header but is an observation. Its "about λ times as many samples" is heuristic. Mark it [computed: i1(A); heuristic].
* Two statements in §5 are computed, not proved, yet §0 item 3 marks them "[proved; computed]". Split the status. They are:
  * "$\Prob\approx2^{k-1}/n^2$";
  * the upper side of "recovery time about $2^{\ell^*/2}$ at λ = 1".
* Two statements about λ = cn are unproved. Prop 3.4 shows only that $E^*$ is *not* selected. They are:
  * "with λ = cn the selection is governed by the population hull", after Prop 3.4;
  * "selects the hull vertex at slope c (Prop 3.4)", in §7.5.

  For a finite class, the hull statement follows from the uniform strong law and a unique population minimiser. Prove that case, or mark both as proof sketches.
* Status row 5.3(a), "refuted (Thm 3.1)", should name the object. In the frozen object, Prop 7.5 shows that no procedure is exact for every sampler. There the brief's sentence is true, for every λ.

**m7. Prop 7.2.**
* §0 item 6 drops "with positive probability".
* The last bullet of Thm 4.1(iii), $S_n/n\to H_\mu(\nu)$, needs i.i.d. inputs. It is not among the parts that survive adaptive inputs.

**m8. Prop 4.3.**
* The function $h$ uses $\lceil\log(1/(\beta g(\cdot)))\rceil$. The ceiling of a computable real is not computable in general. Use a computable rational $g'$ with $g/2\le g'\le g$.
* §0 item 3 drops the hypotheses $Y=\{0,1\}$ and β > 0.

**m9. Theorem 3.2(ii) cites the wrong part of Lemma 2.1.** It cites Lemma 2.1(c) for "$\Lambda_n^\eta\to0$ a.s.", but (c) gives only expectations. Cite (b): $\Lambda_n\to0$ a.s., hence $\Lambda_n^\eta\to0$. Alternatively, use Borel–Cantelli with $\sum_n\rho_\eta^n<\infty$.

**m10. Remark 1.4(c), stamps.**
* The per-query object equals Paper 2's product class on stamped inputs only after restricting to stamp-ignoring programs, as stated.
* The full class $\Hcl{\times}$ on stamped data also contains fill-ins that read the stamp, and these never conflict. Its inputs $\langle x,t\rangle$ are not i.i.d. So Thm 3.1 says nothing about $\Hcl{\times}$ on stamped data.
* One sentence would prevent this misreading.

**m11. Prop 5.3(b): "On any data set".**
* The upper end $\ell(\hat\pi)\le\ell^*+S$ uses $L(\pi_0)=\nu(D)$. This holds almost surely for sampled data, not for any data set.
* The lower end holds for any $D$ with $\delta(D):=\log(\xi_{\mathcal C}(D)/\nu(D))$ in place of δ*.

**m12. Fill-in mass tends to 0 only for non-deterministic ν.** Prop 5.3(d) and Cor 6.1(ii) need ν not deterministic μ-a.e. If $H_\mu(\nu)=0$, then E contains fill-ins, and Thm 3.2 gives no decay for them.

**m13. Measurability.**
* "Non-atomic μ gives a.s. distinct inputs" (Remark 1.4(a)) needs a measurable diagonal, for example a standard Borel $X$.
* On an uncountable $X$, the map $(F,x)\mapsto F(x)$ of Def 1.3 is not jointly measurable for the product σ-algebra. Define the frozen law on distinct inputs directly.

**m14. An implicit step: the Rényi bound without its first term.**
* Props 4.4(b) and 5.1(a) use Thm 4.1(iv) without its first term.
* This is valid. Let $L\to\infty$, or take $L$ at least the largest length in a finite class. That gives $\Prob[\text{MAPs}\ne E^*]\le\sum_{\pi\notin E}2^{\ell^*-\ell(\pi)}\rho_{1/\lambda}(\pi)^n$.
* State it as Thm 4.1(iv′).

---

## The brief's checklist

| concern | finding |
|---|---|
| "a.s., from some $n$ on" versus uniform | Thm 3.1: a.s. with a random $n_0$, correct. Thm 4.1(i)–(iii) and (v): uniform in $n$, correct. (iv): per $n$ (m4). |
| measurability | the events are countable unions or intersections, correct; minor points in m13 |
| semimeasures, defective programs | the equality cases of Lemma 2.1(b), (c) handle defect, correct; Lemma 5.2's decoder needs a measure (M2) |
| ties, non-unique MAPs | Thm 3.1 identifies the whole set $E^*$, correct; Prop 7.3(ii) uses "unique", correct; Props 4.4(b), 5.1(b) (m3) |
| finitely many candidates | $J\ge\lambda\ell\ge\ell$, at most $2^m$ programs of each length, and δ* < ∞ a.s.: correct |
| μ-a.e. equivalent programs have equal likelihoods | a.s. for per-query and frozen i.i.d. data, correct; not for adaptive inputs (M2), not "on any data set" (m11) |
| Kraft sums | correct, except Prop 7.3(iii) (M3) and Props 4.4(a), 7.2(b), 5.1 (m5) |
| additive log terms | Lemma 5.2's count is correct [rA1(F)]; $k$ versus $\ell^*$ (M2) |
| repeated inputs on atomic μ | the per-query object handles repeats, correct; the "distinct inputs" variants (M1) |

---

## Verification log

* **Script.** `referee_code/rA1_checks.py`, output in `referee_code/rA1_checks.out`.
  * Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and scipy 1.17.1. Runtime 2 s.
  * Deterministic, except (C), which is seeded with `default_rng(101)`.
* **(A) Prop 4.4(a), exact binomial, 30 cases** ($\lambda\Delta\in\{9,\dots,300\}$, $\varepsilon'\in\{0.01,\dots,0.1\}$, all $n\le n_1$ on a grid).
  * Every case is within the bound. The largest ratio of exact value to bound is 0.110.
  * Constants:
    * $\max_{\varepsilon'\le0.1}4(1+2\varepsilon')/((1-2\varepsilon')\ln2)=8.6562$;
    * $0.96\ln2/8=0.08318$;
    * $\gamma/\varepsilon'^2\in[0.5000,0.5064]$;
    * $\min n_1/(0.083\lambda\Delta/\gamma)=1.0149$.
* **(B) Gaps for Cor 6.1(iii).** The rate competitor's gap is 0.003736. A one-input function competitor has gap 0.002645 at $d=7$ and 0.000331 at $d=10$.
* **(C) The walk with $D^*=\infty$.** Mean increment 0.2075 bits. In 20 runs, the last time $\pi_1$ was the MAP was at $n\le71$ (median 27).
* **(D) Boundary ties** (9 cases). The strict probabilities lie in 0.9692–0.9844 and the weak ones in 0.9845–0.9922. Both are at least 31/32 = 0.96875.
* **(E) The $k$ versus $\ell^*$ toy class.**
  * Kraft sum 0.6252 and δ* = −0.6775.
  * $J_1(\text{fill})-J_1(\pi_\nu)=-7$. This is below $-\ell^*-\delta^*=-2.32$ and above $-k-\delta^*=-11.32$.
* **(F) Arithmetic checks.**
  * Lemma 5.2: $\lceil\log M\rceil$ is at least 1 bit below the stated bound on the grid.
  * Thm 4.1(v): $1/(1-e^{-a})\le1+1/a$, with a maximum difference of $-2\cdot10^{-2}$ on $[10^{-6},50]$.
* **The notes' scripts.** I read `checks/i2` and `checks/i3` and their outputs. They match the notes' quotations: the table of Prop 5.1 and i3(A)–(D). i2 uses $m\ge1$ (see m5).
* **By hand.** I re-derived every proof listed under "Checked and found correct". I did not check the Barron–Cover attribution. The notes mark it as unverified, and Theorem 3.1 does not depend on it.
* **Repository.** I ran no git command. The files written are `referee-A.md`, `referee_code/rA1_checks.py` and `referee_code/rA1_checks.out`.
