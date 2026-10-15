# Track "split": independent check of the post-referee teacher results

*Independent verification, 2026-10-13, of the results of `teacher/notes-final.md` that the synthesis (`notes-final.md` §5.0) puts in Paper 2's main text and that no referee has read in their final form: Lemma 1.1 in its final form, Def 1.4 with Lemma 1.5, Lemma 3.0, Prop 3.1(c), Props 3.6 and 3.7, Remark 2.6, and the dependence of Prop 5.3 on the computed constants $p^*$ and $a^*(p)$. Each statement was compared with its proof (hypotheses, quantifiers, constants), and each proof was re-derived. Every numerical claim in these items was recomputed with new code in `teacher/verify_code/`, which shares no code with `teacher/checks/` or `teacher/referee_code/`. The records were not edited.*

* **Sources read.**
  * `teacher/notes-final.md`, in full (§1.0–§9 and the verification log).
  * `teacher/referee-A.md` (summary and M3). `teacher/checks/t7_lemma_checks.py` and `t6_exact_window.py` were read only to find the $c$-values and the $K(p)$ convention behind the printed numbers; none of their code was reused.
  * The synthesis `notes-final.md`: §4, §5.0, §5.1 (plan items P5 and P8) and §8. `verify-kink.md`, for the format.
  * Paper 2 at the base commit `dcb3a3a3`. The current `sections/teacher.tex`, `app-teacher.tex`, `setup.tex` and `split.tex` are identical to it.
    * `def:teacher:instance`, the four lemmas, `lem:teacher:sharpfloor`, `thm:teacher:main` and its proof;
    * `lem:teacher:finite`, `cor:teacher:sampled`;
    * `def:setup:data`, `def:setup:objectives`, `rem:setup:persample`;
    * `def:split:setting`, `lem:split:ville`, `thm:split:private`.
  * `research/paper-review/DECISIONS.md`: the rounding rule, computed numbers, and κ = 0 illustrations.
* **Files written.**
  * This file.
  * `teacher/verify_code/v1_lemmas.py`, `v2_fulltable.py`, `v3_schedules.py`, `v4_frozen.py` and `v5_junta_constants.py`, each with its `.out`.

Numbers in brackets, such as v5(D), point to a script and the part of its output.

---

## 1. Verdicts

| item (`teacher/notes-final.md`) | verdict | in one line |
|---|---|---|
| Lemma 1.1 (real $g$, pointwise margin, (iv)) | **verified** | Every step re-derived. Under the hypotheses of (ii), $g\ge0$ is automatic, so the case $g+\epsilon<0$ of the proof never occurs (§2). |
| Def 1.4 | **verified with correction** | The example "a right line exists for every τ, for example with $g=F_0$" is false. $g=F_0+\tau(\ell_0-\ell_M)$ works (§3). |
| Lemma 1.5 | **verified** | (c) is for $\lambda\ge0$, $\lambda\ne s_+$, as its proof shows. |
| Lemma 3.0 | **verified** | The reference moves from $(\ell_0,F_0)$ to $(\ell_0,rF_0)$; then every listed threshold scales by $r$. |
| Prop 3.1(c) | **verified with correction** | Three fixes (§5): <br>(1) bullets 2–3 need $p<1/4$ ($r\ge3$), since $u(\pi_b)=1-p$; <br>(2) bullet 2 needs "unless the memoriser dominates the point"; <br>(3) the sentence "every line flatter than the memoriser's secant costs an offset linear in $L_S$" holds only for slopes $\rho2^{d-m}$ with ρ bounded away from 1. |
| Prop 3.6 | **verified** | Minor wording fixes: <br>(c) inherits $B\in[\log(1/p),\infty)$, an integer, from `thm:teacher:main`, with $c_{\rm hi}$ taken at that $B$; <br>the closing sentence on $\Phi_2^\sharp$ needs the window as a set, and the continuity of $\Phi_2^\sharp$, which holds (§6). |
| Prop 3.7 | **verified** | (a) uses `lem:split:ville` for the process of distinct inputs; that use was checked. (b) also rejects every other program for ν (§7). |
| Remark 2.6 | **verified with correction** | (a1) and (a2) hold as stated. They are sharper than (ii)(a) only when $d>4+\Lambda_1$. With $c(d-4-\Lambda_1)^+$ in $R_{\max}$ they are never weaker. All printed numbers are reproduced (§8). |
| Prop 5.3: dependence on $p^*$, $a^*(p)$ | **verified** (claim and proof); its **readings verified with correction** | The claim "for every $a>a^*(p)$" needs no computed constant. The three crossings are now proved unique, by derivative bounds, and bracketed to 12 digits. The quoted thresholds 0.07787 and 0.12331 are rounded *up*, and dyadic rates lying between each root and its decimal break the "iff" (§9). |

**No item is "not verified".** No mathematical statement planned for the main text has to be weakened in substance. The corrections concern one example offset (Def 1.4), two hypotheses and one summary sentence (Prop 3.1(c)), the formula for $R_{\max}$ (Remark 2.6), and the direction in which thresholds are rounded (Prop 5.3; the same issue affects the paper's existing "$p<0.0560$").

---

## 2. Lemma 1.1 (final form)

**Statement against proof.** The hypotheses are:
* Setting 1.0, with $0\le F'\le F\le\infty$;
* a bounded reference: $\ell(b)\le\ell_0$ and $F(b)\le F_0$ for some program $b$; here $\ell_0$ and $F_0$ are real, which the lemma uses without saying so;
* (R) with $\tau\ge0$, $g\in\mathbb R$ and $\ell_M\le\ell_0$;
* $c>\tau$.

The conclusions follow from these exactly as stated.

**Re-derivation.**
* **(i).** For $\pi\in M$, (R) and $\ell\ge\ell_M$ give
  $$J'_c(\pi)\ge(c-\tau)\ell+\tau\ell_0+F_0-g\ge c\ell_0+F_0-\Delta(c),$$
  using $c-\tau>0$. For $\pi\in N$ the bound is the definition of $m_N$. So the infimum over $\mathcal P=M\sqcup N$ is at least the smaller of the two; empty $M$ or $N$ are covered by the conventions.
  * $\Phi\ge\inf J'$ because $F\ge F'$, and $\Phi\le c\ell_0+F_0$ because of $b$.
  * If $b\in M$, then (R) at $b$ gives $g\ge F_0-F'(b)+\tau(\ell_0-\ell(b))\ge0$. Then $\Delta\ge g\ge0$, because $c>\tau$ and $\ell_M\le\ell_0$.
  * The sandwich: $\min\{m_N,-\Delta\}=-\Delta$ when $m_N\ge0\ge-\Delta$.
* **(ii).**
  * *Every π with $J_c\le\Phi+\epsilon$ is included*, because $J'_c\le J_c\le\Phi+\epsilon\le c\ell_0+F_0+\epsilon$.
  * *Membership in $M$*: by the pointwise margin.
  * *Length*: (R) plus $J'_c\le c\ell_0+F_0+\epsilon$ gives $(c-\tau)(\ell-\ell_0)\le g+\epsilon$.
  * *Lower fit bound, case $\ell\ge\ell_0$*: insert the length bound into (R), using τ ≥ 0.
  * *Lower fit bound, case $\ell<\ell_0$*: it needs $\tau(\ell_0-\ell)\ge-\tau(g+\epsilon)/(c-\tau)$. This is trivial if $g+\epsilon\ge0$, and follows from the length bound if $g+\epsilon<0$. Both cases are correct.
* **(iii).** $m_N$ is an infimum of affine functions of $c$, together with constant $+\infty$ members (for $F'=\infty$), so it is concave. It is $>-\infty$ because $J'_c\ge0$.
* **(iv).** This is a rearrangement of $J'_c\le c\ell_0+F_0+\epsilon$ plus $\ell\ge\ell_M$. It uses neither (R), nor $c>\tau$, nor membership in $M$.
* **Last bullet.** $m_N(c)\le J'_c(b)-(c\ell_0+F_0)\le c(\ell(b)-\ell_0)+F(b)-F_0\le0$.

**An observation that shortens the proof.** Under the hypotheses of (ii), $g\ge0$ always holds.
* The bounding program $b$ has $J'_c(b)\le c\ell_0+F_0\le c\ell_0+F_0+\epsilon$. So the pointwise margin excludes $b\in N$; hence $b\in M$, and (i) gives $g\ge0$.
* So the case $g+\epsilon<0$ in the proof of (ii) never occurs.
* The case $\ell<\ell_0$ then takes one line: $F'\ge F_0-g$, and $(cg+\tau\epsilon)/(c-\tau)-g=\tau(g+\epsilon)/(c-\tau)\ge0$.
* Real $g$ is still useful in (i), where no margin is assumed.

[computed: v1(1).]
* 3984 random point sets, in exact rational arithmetic. Unlike `t7`(A), the two fits differ ($F'<F$ on about half the programs, some fits infinite), $g$ is either the least admissible offset or a larger one, and $\ell_M$ is random.
* Checks at 39,840 slopes:
  * (i), with the sandwich in 6960 cases;
  * the last bullet in 9730;
  * concavity in 36,960;
  * (ii) at 13,878 margins, with 37,690 near-optimal points;
  * (iv) at 225,199 points.
* In 469 sets the least admissible $g$ is negative. In none of them do the hypotheses of (ii) hold at any of the tested slopes and margins (counter `ii_hyp_in_sets_with_least_gneg` = 0).
* v1(5) gives two explicit point sets showing that $c>\tau$ and the strictness of the margin cannot be dropped.

**For the paper (`lem:kink:main`).** The synthesis plans to state the lemma "for the data reading", where $F=F'$. The teacher theorem with a finite truncation $B$ uses two fits ($F=R$, $F'=R_B$; Prop 2.1). Stating the lemma with $F'\le F$ costs nothing and covers both readings. With one fit, Prop 2.1 is covered only for $B=\infty$.

---

## 3. Def 1.4 and Lemma 1.5 (right lines and right secants)

**Def 1.4.**
* **The definition itself is correct.** A right line is a pair $(\tau,g)$ for which (R) holds on $M$ with some $\ell_M$. The right secant is $s_+=\max\{0,\sup\text{secants of longer }M\text{-programs}\}$.
* **Correction: the example offset.** The record says: "On a single finite data set a right line exists for every τ ≥ 0, for example with $g=F_0$."
  * The existence claim is true, but the example is false. (R) with $g=F_0$ requires $F'(\pi)\ge\tau(\ell_0-\ell(\pi))$ for every $\pi\in M$ shorter than $\ell_0$, and nothing guarantees this.
  * *Minimal counterexample:* reference $(10,5)$, τ = 1, $M=\{(0,0)\}$. (R) with $g=F_0$ would need $0\ge10$.
  * In random sets, $g=F_0$ fails in 1363 of 2981 [computed: v1(2)].
  * *Correct offset:* $g=F_0+\tau(\ell_0-\ell_M)$, at most $F_0+\tau\ell_0$, always works, because $F'\ge0$ and $\ell\ge\ell_M$ [v1(2): all 2981 sets].
  * The point of the sentence, "a slope alone says nothing", is unaffected.
* **"When the reference is a hull vertex, $s_+$ is the slope of the hull edge to its right."** This holds with three precisions:
  * the hull is that of the points of $M$ together with the reference;
  * "slope" means minus the slope;
  * the supremum must be attained (for an infinite $M$ there may be no edge).

  Suggested wording: "minus the slope of the hull edge to its right, when that edge exists".

**Lemma 1.5.**
* *(a)*: (R) rearranged.
* *(b)*: (R) at $\pi_1$. (If $F'(\pi_1)=\infty$, then $s_1=-\infty$ and the claim is trivial.)
* *(c)*: $J'_\lambda(\pi)-J'_\lambda(\pi_0)=x(\lambda-\text{secant}(\pi))$ for $\ell(\pi)=\ell_0+x$.
  * For $\lambda<s_+$ with $\lambda\ge0$: $s_+>0$, so the supremum is over a nonempty set and exceeds λ.
  * For $\lambda>s_+$: every secant is at most $s_+<\lambda$.
  * The case $\lambda=s_+$ is not covered, and the lemma does not claim it.
  * λ ≥ 0 is implicit. For negative λ with no longer programs, the first half fails; it is irrelevant in the paper, where $\lambda\ge1$ or $c>0$.

  **Verified.**

[computed: v1(3), with $F'\neq F$.]
* (a) and (b) at 10,062 longer programs.
* (c) at 15,888 values of λ ≥ 0, including λ = 0 and $\lambda=s_+$, the latter not asserted.

---

## 4. Lemma 3.0 (duplication)

**Statement against proof.** If every term of the data set $D$ is counted $r$ times ($r\ge1$ an integer), then every fit is $rL(\pi)$, and $\lambda\ell+rL=r((\lambda/r)\ell+L)$. Since positive scaling preserves arg-min sets, the λ-MAPs are the $(\lambda/r)$-MAPs of $D$. Each listed threshold scales by $r$, provided the reference fit scales too, $(\ell_0,F_0)\mapsto(\ell_0,rF_0)$:
* hull slopes, because the hull is scaled vertically by $r$;
* right lines, $(\tau,g)\mapsto(r\tau,rg)$, because (R) is homogeneous in $(F_0,F',g,\tau)$;
* right secants;
* left steepness and the wedge margin μ;
* every λ-interval of a vertex.

The parenthesis "FQ in which every input of dom D has been queried exactly r times, and no other input" is the setting of Prop 3.7(c). **Verified.**

[computed: v1(4) and v4(C).]
* v1(4): 3000 random point sets, $r\in\{2,\dots,9\}$.
  * The exact λ-interval of each of 20,983 points is multiplied by $r$.
  * The least offsets, right secants, left steepness and MAP sets at random λ scale as stated.
* v4(C): 3000 FQ cases in an explicit class, with $\bar n\in\{2,5,17\}$, against the full table at $\lambda/\bar n$.

**For the paper.** Write the scaling of the reference ($F_0\mapsto rF_0$) into the statement. Without it, "right lines $(\tau,g)\mapsto(r\tau,rg)$" is ambiguous.

---

## 5. Prop 3.1(c) (full tables: line, secant, offsets)

**Bullet 1: verified.** $(2^{d-m},2^{d-m}\Lambda_2)$ is a right line at $(d+\kappa_g,NH(p))$ on the level-1 programs.
* This is Prop 2.1(b), i.e. (D2) at level 1 with $s(1)=4$, multiplied by $N$. On the full table under uniform inputs, the fit is $NR$.
* The other conditions of (R) hold: $\ell_M=d-4-\Lambda_1\le\ell_0$, and every level-1 program is at least that long (D1).

**Bullet 3: verified, given $p<1/4$.**
* (R) at the memoriser gives $g\ge NH(p)-\tau(\ell(\pi_b)-\ell_0)\ge NH(p)-\tau(\lceil L_S\rceil+\kappa_b-\kappa_g)$, for every sign of $\ell(\pi_b)-\ell_0$.
* For $\tau=\rho2^{d-m}$, the expression in units of $2^{d-m}$ is $2^mH(p)-\rho(\lceil L_S\rceil+\kappa_b-\kappa_g)\ge(1-\rho)L_S-\rho(1+\kappa_b-\kappa_g)$.
* As a consistency check of bullets 1 and 3: at $\tau=2^{d-m}$, the line's offset $2^{d-m}\Lambda_2$ exceeds bullet 3's lower bound by exactly $2^{d-m}(\lceil L_S\rceil-L_S+\delta_S+4+\Lambda_1+\kappa_b)\ge0$ [computed: v2(B), five sizes, κ ∈ {0, 30}, $\delta_S\in\{0,20\}$].

**Correction (1): $p<1/4$.**
* Bullets 2 and 3 apply (R), or take the supremum in $s_+$, at the memoriser, and so need $\pi_b\in M$, i.e. $\lev(\pi_b)=1$.
* $u(\pi_b)=1-p$, and level 1 needs $u>3/4$. So this holds iff $p<1/4$, i.e. $r\ge3$.
* `def:teacher:instance` allows $r=2$. There $\pi_b$ has level 2, and bullets 2–3 are not proved. The record's proof says "$u(\pi_b)=1-p>\frac34$" without the condition.
* At $r=2$ the window is empty ($G_1<H(1/4)$), so (a) is vacuous there. The fix is to add $r\ge3$ to (c), as Prop 2.4 already does.

**Correction (2): bullet 2 needs a case distinction.** "At every level-1 point with $R\ge H(p)$ the right secant is at least $2^{d-m}\theta_m$" is proved only for points to the left of the memoriser.
* The proof bounds the memoriser's secant from $P=(\ell,NR)$ by $NH(p)/(\ell(\pi_b)-\ell)$. This presupposes $\ell(\pi_b)>\ell$.
* Level-1 programs of every length beyond $d-4-\Lambda_1$ exist (padding). For a point at or beyond $\ell(\pi_b)$, the memoriser is not a longer program and does not enter $s_+$.
* In a class consisting of $\pi_g$, $\pi_b$ and a padded copy of $\pi_g$ longer than $\pi_b$, the padded copy is level 1 with $R=H(p)$ and has right secant 0 [computed: v2(E), $d=20$, $m=16$].
* In $\Hcl{\times}$, padded memorisers probably restore the bound up to machine constants, but the record does not prove this.

*Corrected bullet 2.* "Let $p<1/4$. For every level-1 program π with $R(\pi)\ge H(p)$, either $\ell(\pi_b)\le\ell(\pi)$, and then the memoriser dominates $(\ell(\pi),NR(\pi))$, or its secant from that point is at least $2^{d-m}\theta_m$, and then so is the right secant there."
* This is the form of Prop 4.1(a) and Prop 4.2, which handle the case correctly.
* At the reference itself the second case holds whenever $B_S>4+\Lambda_1+\kappa_g$, because (D2) puts $\pi_b$ at length at least $d+B_S-4-\Lambda_1$. This holds at every size in v2(D) except $d=20$, $m=12$, κ = 30.

**Correction (3): the summary sentence.** "Every line flatter than the memoriser's secant costs an offset linear in $L_S$" is too strong.
* At slope $\tau=\theta_m2^{d-m}$, just below the secant, bullet 3 gives only about $2^{d-m}(4+\Lambda_1+\kappa_g)$, the order of the line's own offset.
  * At $d=20$, $m=16$, κ = 0, in units of $2^{d-m}$: the bound is $0.0465\,L_S=33.9$, while $\Lambda_2=40.3$ [computed: v2(C)].
* *Correct reading:* a line of slope $\rho2^{d-m}$ needs offset at least $2^{d-m}\big((1-\rho)L_S-O(\log d+\log m+\kappa)\big)$, which is linear in $L_S$ for ρ bounded away from 1.

[computed: v2(A).] The record's table rows are reproduced exactly:
* $L_S=11{,}710.27$, 2923.82, 727.96 and 43.41;
* $\theta_m=0.9955$, 0.9836, 0.9421, 0.5473 and 0.9947;
* $2^{d-m}\theta_m$;
* $Nc_{\rm hi}=1.195\cdot10^4$ and $1.022\cdot10^{28}$.

---

## 6. Prop 3.6 (which schedules keep the identification)

### (a) $\lambda_n/n\to0$, with $\lambda_n>0$: verified

1. *Few candidates.* Since $\pi_b$ has fit 0, every MAP has $\ell\le\ell(\pi_b)$. This step divides by $\lambda_n>0$, which is needed: at $\lambda_n=0$ there are infinitely many candidates. Kraft then leaves finitely many candidates, and the infimum is attained.
2. *Each candidate with $R>0$ eventually loses.* Each such candidate is eventually not a MAP (Prop 3.2(a) with $\pi_1=\pi_b$, $R(\pi_b)=0$).
   * On the finite input set, $\hat R_n(\pi)=\sum_x(N_n(x)/n)\,\mathrm{loss}(x)\to R(\pi)$ almost surely, by the strong law for the counts $N_n(x)$. So no strong law for infinite means is needed.
3. *Finitely many null sets.* There are finitely many candidates.
4. *Risk 0 means $e=1$.* Uniform inputs give every input positive mass.

### (b) $\lambda_n/n\to\infty$: verified

1. *Long programs lose.* Lengths are integers. Every program longer than $\ell_{\min}$ loses to $\pi_0$ once $\lambda_n>n\hat R_n(\pi_0)$, and $\hat R_n(\pi_0)\to R(\pi_0)<\infty$ almost surely.
2. *In $\Hcl{\times}$.* $\ell_{\min}\le\ell(\pi_{\rm coin})\le\kappa<d-4-\Lambda_1$, and (D1) excludes level 1 below $d-4-\Lambda_1$.
3. *Shorter programs.* Programs shorter than $\ell_{\min}$ have $R=\infty$ and are not excluded. The record says so, and they are not level 1 either.

### (c) $\lambda_n/n$ in a compact subset of the window: verified, with two wording fixes

**The bound.** With $c=\lambda_n/n$ fixed for each $n$, `lem:teacher:finite` gives
$$J^B_c(\hat\pi)\le J_c(\pi_g)+\epsilon_1+B\sqrt{(\hat L(c)\ln2+\ln(2/\delta))/(2n)}.$$
* $\hat L(c)\le\bar L$, because $J_g$ is increasing and $c\ge c_1$.
* In PQ, Hoeffding's inequality for independent variables replaces the without-replacement form, both for $\pi_g$ (losses in $[0,\log(1/p)]$) and, with a Kraft-weighted union bound, for every program (truncated losses in $[0,B]$).
* Both events of the lemma are free of $c$. So, with probability $1-\delta$, the conclusion holds simultaneously for all $c$. This is slightly more than stated.

**The window condition.** $\Phi_2-J_g$ is a minimum of strictly decreasing affine functions. It is therefore continuous and positive on $[c_1,c_2]\subset(0,c_{\rm hi})$, and its minimum there is positive. $\bar\epsilon_n\to0$, also with $\delta_n=n^{-2}$. Borel–Cantelli then gives the almost-sure form in PQ, with no independence needed.

**Wording fix 1.** Let $B<\infty$ be an integer in $[\log(1/p),\infty)$, and let $c_{\rm hi}$ be computed at that $B$.
* The range of $B$ is inherited from `thm:teacher:main` and `lem:teacher:coding`. It is the same implicit condition as in `cor:teacher:sampled`.
* $c_{\rm hi}$ depends on $B$ through $G_j$ and $\Lambda_1$. At the example's sizes $c_{\rm hi}(B=30)=6.736\cdot10^{-3}$, against $8.062\cdot10^{-3}$ at $B=\infty$ [v3(B)].

**Wording fix 2: the closing sentence.** "With $\Phi_2^\sharp$ … the same holds for $p<0.1233$" should read: "(c) holds for every compact $[c_1,c_2]\subset\{c>2^{-m}:J_g(c)<\Phi_2^\sharp(c)\}$".
* That set need not be an interval (Prop 5.2), and for given $d$, $m$ it can be empty below 0.1233. For example, at $d=100$, $m=20$ it is empty at $p=1/8$.
* The margin argument needs $\Phi_2^\sharp$ to be continuous, which the record does not show. It holds for the following reason.
  * Let $t_0$ be the least level with $s(t_0)\ge d-\Lambda_1$ and $s(t_0)+2\log d\ge d$. From $t_0$ on, $LB_t$ is nondecreasing in $t$: the first term is $G_{t-1}$, the coefficient of $c$ is constant, and $\Psi_t$ is nondecreasing because $\theta_{t-1}$ decreases. Also $LB_\infty\ge LB_{t_0}$.
  * So $\Phi_2^\sharp=\min_{2\le t\le t_0}LB_t$. Each $LB_t$ is continuous on $(0,\infty)$, because $\Psi_t$ is locally a minimum of finitely many affine functions.
  * [computed: v5(E). At $d=100$, $m=20$, $t_0=39$; monotone over $t_0,\dots,t_0+39$ and at $t=\infty$, for $p=2^{-10}$, 1/16 and 15/128, at five values of $c$ each.]

### Computed illustrations

* **v3(A): an explicit class.** $d=6$, idiosyncratic rule, $p=1/8$, PQ, one sample path to $n=2^{40}$. The proofs of (a) and (b) are class-generic, so this is a fair test of their mechanism, but not of the teacher's constants.
  * $\sqrt n$ and $n^{0.8}$ end at the risk-0 memoriser, from $n=2^{12}$ and $n=2^{30}$.
  * $n^{1.5}$ ends at the shortest finite-risk program, the coin.
  * $0.03\,n$, inside the class's $c$-window $(0.0175,0.0507)$, ends at the rate-1/8 true parity.
* **v3(B): at the example's sizes.** $B=30$, δ = 0.01, κ = 0 (an illustration).
  * The margins $\min(\Phi_2-J_g)$ on three compact ranges are 0.396, 0.342 and 0.163.
  * $\bar\epsilon_n$ falls below them from $n=10^8$, $10^7$ and $10^7$ on.
  * At those $n$ the slack in (ii) is 0.13–0.21 bits per sample, so the identification is coarse but proved.

---

## 7. Prop 3.7 (frozen noise: FR against FQ)

### (a) FR: verified

**Ville in this process.** `lem:split:ville` requires that each new distinct input be chosen before its label is drawn, and that the label be drawn from $\nu(\cdot\mid x)$ independently of the past. In FR with i.i.d. inputs:
* the next new input is fixed by the input stream, which is independent of $F$;
* $F(x)$ at a new $x$ is independent of the earlier labels and of all inputs.

So $\xi_{\mathcal C}(D)/\nu(D)$ is a nonnegative supermartingale in the distinct-input index, by the one-point inequality $\sum_y\nu_\pi(y\mid x)\le1$, with initial value at most 1. Ville then gives $\Pr[\delta^*\ge j]\le2^{-j}$.

Points that check out:
* computability of ν is not used;
* finitely many distinct inputs (finite support) are allowed;
* the sup over the distinct index covers every $n$, repeats included.

**The rest.**
* The line $(1,k+\delta^*)$ is (R) with $\ell_M=0$ and $M=\mathcal C$, at a reference bounded by $\pi_0$, which equals ν on $\mathrm{supp}\,\mu$.
* The length bound $k+(k+\delta^*)/(\lambda-1)$ is Lemma 1.1(ii) with $N=\emptyset$ and ε = 0.
* *The bounded gain.* The likelihood ratio has factors only at $x\in A\cap\dom D_n$, each at most $1/\nu(F(x)\mid x)$, and the missing factors are at least 1.

### (b) FQ: verified

The identity holds term by term: off $A$ the two programs give equal losses, and on $A$, $\pi_A$ has loss 0. Then:
* $N_n(x)/n\to\mu(x)>0$ for atoms of the countable $X$;
* the limit is positive because some $x\in A$ has $\nu(F(x)\mid x)<1$;
* $\lambda_n(k-\ell(\pi_A))=o(n)$.

**A point for the synthesis's wording.** §4.2 says "every $\lambda_n=o(n)$ eventually rejects every program for ν". (b) is about one program $\pi_0$. The extension holds because all programs equal to ν on $\mathrm{supp}\,\mu$ have the same FQ fit; take $\pi_0$ shortest among them, and every longer one is beaten whenever $\pi_0$ is. The condition "ν(F(x)|x) < 1 for some x ∈ A" must stay, since otherwise $\pi_A$ is itself a program for ν.

### (c): verified

This is Lemma 3.0 with $r=\bar n$.

### Computed checks

[computed: v4.] The instance: 12 inputs with a non-uniform μ; a class with Kraft sum 0.197, containing ν, four wrong samplers, all memorisers of one or two inputs, and the 4096 fill-in tables in closed form.
* **(A)** 20,000 FR runs of 400 queries with repeats.
  * The empirical tails $\Pr[\delta^*\ge j]$ are 0.0150, 0.0046, 0.0015, 0.0005 and 0.0001 at $j=1,2,3,4,6$, all below $2^{-j}$.
  * The line holds at 239,892 (run, $n$) pairs.
  * The length bound for λ ∈ {1.5, 2, 4} holds at 719,676.
  * The bounded gain holds at 18.7 million (pair, memoriser) cases.
* **(B)** The identity of (b) holds exactly at 1482 (n, memoriser) pairs. On one run to $n=2^{22}$:
  * FQ rejects $\pi_0$ at λ = 2 (from $n=2^6$), at λ = 8 (from $2^8$) and at $\sqrt n$ (from $2^9$);
  * FR keeps $\pi_0$ at λ = 2, 8 and $\sqrt n$ throughout.

---

## 8. Remark 2.6 ((a1), (a2) and the larger $u$ in (e))

**The derivation, re-derived.**
* $R_B(\pi)=J^B_c(\pi)-c\ell(\pi)\le J_g(c)+\epsilon-c(d-4-\Lambda_1)=R_{\max}$, by (D1) at level 1.
* *(a1)* is `lem:teacher:floor` together with $u>3/4$.
* *(a2)* is `lem:teacher:sharpfloor`. The budget $I(\pi)\le\Delta_\ell+\Lambda_3$ comes from (ii)(d), and "the least $j$ with $j-2\log(j+1)>T$" is nondecreasing in $T$ (fewer $j$ qualify). So $\gamma(\pi)\le\gamma_g$.
  * More simply, the proof of the sharp floor works for any $j$ above its threshold, so $j_g$ can be used directly.
  * Then divide by $1-2p>0$.
* *(e)* is stated in terms of the true $u(\pi)$, so any lower bound on $u$ can be inserted.

**Correction: (a1) and (a2) are not always sharper than (ii)(a).** $R_{\max}\le J_g(c)+\epsilon$ iff $d\ge4+\Lambda_1$.
* When $d<4+\Lambda_1$, $R_{\max}$ exceeds $J_g(c)+\epsilon$, and (a1) is weaker than the paper's (a). This happens on the full table $d=m=20$ of `cor:teacher:fulltable`, where $\Lambda_1=17.29$ at κ = 0 and 47.29 at κ = 30.
  * Example: at κ = 30 and λ = 1000, (a) gives $u\ge0.9494$ and (a1) only $0.9299$ [computed: v5(G)].
* Both bounds are valid, so $u\ge\max\{(a),(a1),(a2)\}$.
* *Corrected definition* that is never weaker:
  $$R_{\max}:=J_g(c)+\epsilon-c\,(d-4-\Lambda_1)^+ ,$$
  valid because $\ell\ge\max\{0,d-4-\Lambda_1\}$.
* At $d=100$ and κ ≤ 30 the two definitions coincide ($d-4-\Lambda_1\ge44$), so no printed number changes.
* The record's "a sharper form" and "(a1) is free and can be passed to the paper" should use this definition, or keep the paper's (a) alongside.

[computed: v5(D).] Every printed number of the Remark 2.6 table, and of the identification column of §5, is reproduced to every printed digit.
* *Running example, $p=2^{-10}$:*
  * at $c=10^{-4}$: $u\ge0.9831/0.9882/0.9897$ and $e\le0.1991/0.1940/0.1925$;
  * at $c=4\cdot10^{-3}$: 0.7500/0.8728/0.8742 and 0.4322/0.3093/0.3080;
  * at $c=1.226\cdot10^{-4}$: (a2) 0.9890 and $e\le0.1932$, with $\ell\le d+20.34$ and $I\le37.63$.
* *§5 rows* at $c=6.745$, 5.282, 4.278, 4.337 and $3.586\cdot10^{-5}$: (a2) gives $u\ge0.8279$, 0.8026, 0.7803, 0.7596 and 0.7500, and $e\le0.1965$, 0.2200, 0.2403, 0.2597 and 0.2688.
* *Window membership.* Each $c$ was checked to lie in the window where the remark is applied.
  * $p=2^{-10}$: $J_g<\Phi_2$, with margins 0.397, 0.203 and 0.396.
  * The other rates: $J_g<\Phi_2^\sharp$, with margins 0.131, 0.088, 0.051, 0.017 and 0.0014, while $\Phi_2-J_g<0$ in all of them.

  The 15/128 row is inside its window by only 0.0014 bits per sample.
* *The $K(p)$ convention behind these numbers.* $\kappa_g=2\log d+2\log r$ for $p=2^{-r}$ (`def:teacher:instance`), and $2\log d+2\log(h+1)+2\log(e+1)$ for $p=h/2^e$ with $h$ odd. The paper's table caption must say this.

---

## 9. Prop 5.3 and its computed constants

### The claim and its proof: verified, and no computed constant is needed

The claim: for every $a>a^*(p)$, for all large $m$ and every $c\in[a2^{-m},c_m]$, $J_g(c)+\epsilon<\Phi_2^\sharp(c)$. Re-derivation:

1. *Charge per sample.* $cI=apx$ at $c=a2^{-m}$, where $I=xs_0$; this uses $s_0=p2^m$, an integer for dyadic $p$ and large $m$.
2. *Size of $j$.* $j\le I+r_g+O(\log(I+r_g))$, from the minimality of $j$, since $f(j)=j-2\log(j+1)$ increases for $j\ge2$.
3. *Choice of $g_m$.*
   * The constant $r_g$ is at least about $1+g+2\log g$, because $\delta_S\ge-2\log m-2\log s_0-\kappa$.
   * With $g_m\to\infty$ and $g_m=o(s_0)$, and $\delta_S=o(2^m)$: $r_{g_m}=o(s_0)$, and $\log(Xs_0+r_g)=O(m)=o(s_0)$.
   * So $\gamma_{g_m}(xs_0)^2=x\ln2/2+o(1)$ uniformly on $[0,X]$, and $p2^{1-g_m}\to0$.
4. *Floor and tail.* Floor is a supremum over $g$, so the choice $g=g_m$ gives a lower bound. Uniform continuity of $-\log$ on $[\frac34-\frac p2,\infty)$ then gives $\mathrm{Floor}_2(xs_0)\ge f(x)-o(1)$ on $[0,X]$. For $x>X$, the bound $apX>\psi_2+1$ together with Floor ≥ 0 handles the tail.
5. *Uniformity in $t$.* $\Psi_t\ge\Psi_2$, since $\theta_{t-1}\le\theta_1$, and the coefficient of $c$ is at least $-2\log(2d)-\kappa$. This gives the uniform bound $J_g-LB_t\le c(d+\kappa_g+2\log(2d)+\kappa)+H(p)-\Psi_2(c)$, and $\Phi_2^\sharp=\inf_tLB_t$ inherits it.
6. *Monotonicity in $c$.* $\Psi_2(c)\ge\Psi_2(a2^{-m})$ for $c\ge a2^{-m}$, since $I\ge0$.
7. *Vanishing length term.* $c_m(d+O(\log d))\to0$. The assumption $d2^{-m}\to0$ is used only to make the range $[a2^{-m},c_m]$ nonempty with $c_md\to0$.
8. *Positive ε.* $\psi_2(p,a)>H(p)$ for every $a>a^*(p)$:
   * $\psi_2(p,\cdot)$ is nondecreasing, and continuous as an infimum of affine functions of $a$;
   * it is strictly increasing, since the minimiser $y^*>0$;
   * so ε := $\frac12(\psi_2-H)>0$.
9. *$c2^m>1$.* This holds since $a>a^*\ge1$.

**The dependence on $p^*$ and $a^*(p)$.**
* The claim is stated for $a>a^*(p)$ with $a^*$ defined as an infimum. It is proved for every dyadic $p\in(0,1/4)$ and needs no computed value. When $a^*(p)=\infty$, it is vacuous.
* The computed constants enter only the readings: for which $p$ the claim is non-vacuous ($a^*<\infty$), where the window reaches $2^{-m}$ ($a^*=1$), and the tabulated $a^*$.
* All three readings are now proved, up to bracketing roots, as follows.

**(1) $a^*(p)<\infty$ iff $p<p_1$, the unique root of $f_1(p):=1-\log(3/2-p)-H(p)$ in $(0,1/4]$.**
* As $a\to\infty$, $\psi_2(p,a)\uparrow f(0)=1-\log(3/2-p)$. This was checked analytically, by continuity at $x=0$ and $apx\to\infty$ elsewhere, and numerically in v5(B).
* So $a^*<\infty$ iff $f_1(p)>0$.
* $f_1'(p)=1/((3/2-p)\ln2)-\log((1-p)/p)\le1/(1.25\ln2)-\log3=-0.431<0$ on $(0,1/4]$. So the root is unique.
* At 40 digits, $p_1=0.123307285520$, to 12 digits [computed: v5(A)].

**(2) $a^*(p)=1$ iff $p\le p^*$, the unique root of $h(p):=\psi_2(p,1)-H(p)$.**
* *The "iff" itself.* If $\psi_2(p,1)\ge H$, then strict increase in $a$ gives $\psi_2(p,a)>H$ for every $a>1$. So $a^*=1$ also at $p=p^*$, where the record says "$p<p^*$". This is immaterial for dyadic $p$.
* *Uniqueness of the root.* By Danskin's theorem (the minimiser is unique and interior),
  $$h'(p)=y^{*2}-\frac{2\sqrt{\ln2/2}\,y^*-\frac12}{(A+ky^*)\ln2}-\log\frac{1-p}p .$$
  * At $a=1$ the minimiser solves $y^*(A+ky^*)=1/\sqrt{2\ln2}$, so $y^*\in[0.7385,1.3589]$ on $(0,1/4]$.
  * Hence $h'(p)\le1.8466-0.4636-\log3=-0.202<0$, and the root is unique.
  * The derivative formula agrees with central differences to $10^{-8}$ [computed: v5(A)].
* *Its value.* $p^*=0.077865864597$, to 12 digits.

**(3) $G_1>H(p)$ iff $p<p_0=0.055964349999$.** This is the hypothesis of `thm:teacher:main` at $B=\infty$. $(G_1-H)'<-\log3<0$, so the root is unique.

**(4) The tabulated $a^*$.** $a^*(5/64)=1.0114$, $a^*(3/32)=2.1276$, $a^*(0.1)=3.0341$, $a^*(7/64)=5.9987$, $a^*(15/128)=15.585$ and $a^*(0.12)=30.200$. Each agrees with the record to its printed digits [computed: v5(B), bisection in $a$ on $\psi_2$ minimised by bisection on its derivative].

**Correction: the direction of rounding.** The record's "$a^*(p)<\infty$ iff $p<0.12331$" and "$a^*(p)=1$ iff $p<0.07787$" round the roots *up*. Each "iff" is therefore false on a small interval that contains dyadic rates, and dyadic rates are exactly the domain of Prop 5.3 [computed: v5(H)].
* $p=129298/2^{20}=0.1233082<0.12331$ has $f_1(p)=-1.6\cdot10^{-6}<0$, so $a^*=\infty$ there.
* $p=81650/2^{20}=0.0778675<0.07787$ has $h(p)=-6.2\cdot10^{-6}<0$, so $a^*>1$ there.
* The paper's existing "$G_1>H(p)$ … if and only if $p<0.0560$" (`sec:teacher:theorem`) and hypothesis "(4) $p<0.056$" have the same defect: $p=3669/2^{16}=0.0559845$ has $G_1-H=-1.2\cdot10^{-4}$. No power of 2 lies in the gap, so the original instance with $p=2^{-r}$ is unaffected. The generalised instance, with dyadic $p$, is affected.

*Fix.* Define the roots, e.g. "let $p_1\approx0.12331$ be the unique root of $1-\log(3/2-p)=H(p)$ in $(0,1/4)$". For sufficient conditions in decimals, round down: $p<0.1233$ ($a^*<\infty$), $p<0.0778$ ($a^*=1$), $p<0.05596$ ($G_1>H$). This follows DECISIONS.md's rule (lower bounds rounded down).

**The finite-size numbers that Prop 5.3's table rests on** [computed: v5(C), v5(F)].
* $\Psi_2(a2^{-m})$ with integer $I$ at $m=12$, 16 and 20, for the five $(p,a)$ pairs of the record's table, is reproduced to four digits, for example 0.3837, 0.3968 and 0.3979 at (1/16, 1). The values approach $\psi_2$ from below.
* The upper ends of the exact windows at $d=100$, $m=20$, κ = 0 are reproduced to every printed digit, by brute-force minimisation over all $I\le1/c$ with no hull: $8.1983\cdot10^{-3}$, $2.5293\cdot10^{-3}$, $1.5211\cdot10^{-3}$, $9.0978\cdot10^{-4}$, $3.1842\cdot10^{-4}$ and $6.2252\cdot10^{-5}$.
* The lower end at 15/128 is $21.432\cdot2^{-20}$, as recorded.
* The window is open at its upper end, because identification needs the strict inequality $J_g+\epsilon<\Phi_2^\sharp$. So the synthesis's "$(2^{-20},2.53\cdot10^{-3}]$" for $p=1/16$ should read $(2^{-20},2.529\cdot10^{-3})$, since $2.53\cdot10^{-3}$ itself lies outside.

---

## 10. Statements the paper may use, with the corrections applied

1. **Kink lemma** (`lem:kink:main`).
   * Teacher Lemma 1.1 as recorded, with two fits $F'\le F$.
   * Optionally add "under the hypotheses of (ii), $g\ge0$", and shorten the proof of the lower fit bound accordingly.
2. **Right line and right secant** (`def:kink:kinks`).
   * Def 1.4, with the example offset $F_0+\tau(\ell_0-\ell_M)$.
   * The hull sentence reads "minus the slope of the hull edge to its right, when that edge exists".
   * Lemma 1.5 as recorded, with λ ≥ 0 in (c).
3. **Duplication** (`lem:teacher:reuse`). Lemma 3.0, with "the reference $(\ell_0,F_0)$ becomes $(\ell_0,rF_0)$" in the statement.
4. **Full tables, every $m$.**
   * Prop 3.1(a), (b) as recorded.
   * (c) for $r\ge3$, with bullet 2 in the case-distinction form of §5.
   * The offset statement reads "slope $\rho2^{d-m}$ needs offset $\ge2^{d-m}((1-\rho)L_S-O(\log d+\log m+\kappa))$".
5. **Schedules** (`prop:teacher:schedules`).
   * Prop 3.6(a), (b) as recorded.
   * (c) with "$B\in[\log(1/p),\infty)$ an integer, and $c_{\rm hi}$ at that $B$".
   * The $\Phi_2^\sharp$ extension reads "for every compact $[c_1,c_2]\subset\{c>2^{-m}:J_g(c)<\Phi_2^\sharp(c)\}$", with the continuity of $\Phi_2^\sharp$ (§6) as a one-line justification.
6. **FR against FQ.** Prop 3.7 as recorded.
7. **(ii)(a) sharpened.**
   * $u\ge\max\{\frac34,\,2^{-R_{\max}}-p-2^{-B}\}$ with $R_{\max}=J_g(c)+\epsilon-c(d-4-\Lambda_1)^+$.
   * (a2) with the same $R_{\max}$.
8. **Flip rates up to $p_1$.**
   * Prop 5.3 as recorded, for $a>a^*(p)$.
   * The readings with the defined roots $p_1$ and $p^*$; "$a^*=1$ iff $p\le p^*$"; decimals rounded down in sufficient conditions.
   * The uniqueness of each crossing is now proved (§9), so the paper can say so in one sentence per crossing instead of citing a grid.
   * The same rounding fix applies to "$p<0.0560$" in `sec:teacher:theorem` and `rem:teacher:hypotheses` once the instance is generalised to dyadic $p$.

**For the paper's prose (DECISIONS.md).** The κ = 0 numbers of §§5, 8 and 9 above are illustrations, with the machine constant set to 0. Numbers enter only after a statement, with "a direct computation (code in the accompanying repository) gives …". The uniqueness arguments of §9 are proofs, not computations; only the root values are computed.

---

## Verification log

*Run 2026-10-13 with Python 3.11.15, numpy 2.4.6 and mpmath 1.3.0. Every script was run as `python3 -I -B <script>.py` from `teacher/verify_code/`, and its output was saved as the `.out` file of the same name.*

* **Scripts.** Each exited with code 0 and all assertions passed.

  | script | randomness | time |
  |---|---|---|
  | `v1_lemmas` | `random.Random(20261013)` | 11 s |
  | `v2_fulltable` | none | < 1 s |
  | `v3_schedules` | `default_rng(613)` | < 1 s |
  | `v4_frozen` | `default_rng(3707)` | 100 s |
  | `v5_junta_constants` | none | 107 s |

* **Reproduction.** The final versions of all five scripts were copied to a scratch directory and re-run there in parallel. Each output was byte-identical to the saved `.out`. No `__pycache__` was written.
* **Independence.**
  * No code was imported or copied from `teacher/checks/`, `teacher/referee_code/` or `kink/verify_code/`.
  * Methods differ from the record's where it matters:
    * Lemma 1.1 was tested with two distinct fits;
    * $\psi_2$ is minimised by bisection on the derivative, not by the closed-form quadratic of t6 and rB7;
    * $j$ comes from a fixed-point iteration;
    * $\Psi_t$ is a brute-force minimum over all integers $I\le1/c$, not a convex hull;
    * $L_S$ comes from `mpmath.loggamma`;
    * Floor uses $g\le60$, where t6 uses $g\le40$; this can only raise $\Phi_2^\sharp$, and the reproduced window ends show it does not change them at the printed digits.
* **Proof checks by hand.**
  * Lemma 1.1 (i)–(iv) and the last bullet, including the lower fit bound in both cases, and the observation that the hypotheses of (ii) force $g\ge0$.
  * Def 1.4, with its counterexample.
  * Lemma 1.5 (a)–(c), and Lemma 3.0.
  * Prop 3.1(c): all three bullets, the level of $\pi_b$, the case $\ell(\pi_b)\le\ell$, and the offset for slopes near the secant.
  * Prop 3.6 (a)–(c): the candidate set, Prop 3.2(a), the use of `lem:teacher:finite` with $c$ varying in $[c_1,c_2]$, the compactness argument, Borel–Cantelli, and the continuity of $\Phi_2^\sharp$.
  * Prop 3.7 (a)–(c), including the supermartingale property of $\xi_{\mathcal C}/\nu$ in FR's distinct-input index.
  * Remark 2.6 (a1), (a2) and (e), and the sign condition $d\ge4+\Lambda_1$.
  * Prop 5.3: every step of the proof; the limit of $\psi_2$ in $a$; the derivative bounds that make each of the three crossings unique.
* **Not checked here.**
  * The parts of the teacher record that are not in the list of §5.0: Props 2.1, 2.3, 2.4, 3.2, 3.3, 4.1, 4.2, Lemma 5.1 and Prop 5.2. They were refereed, and are used here only as cited.
  * The Paper 2 lemmas they rest on, which were refereed earlier.
  * Kink sub-track results, which `verify-kink.md` covers.
  * Prop 3.7's computed rows t5(D) and rB5 were not re-run. v4 is an independent instance of the same mechanism, not a reproduction of those tables.
* **Repository.**
  * No git command that changes state was run (only `git show` and `git diff` against `dcb3a3a3`).
  * No paper was built, so `check_companion_numbers.py` was not needed.
  * Files written: this file, and `teacher/verify_code/` (five scripts and five outputs). The records `teacher/notes-final.md`, the synthesis and all referee files were not modified.
