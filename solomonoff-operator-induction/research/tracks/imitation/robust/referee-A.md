# Referee report A (proofs): sub-track "robust" (target I1)

*Adversarial referee for the proofs. Written 2026-10-14. Object of the report: `notes.md` (533 lines), the scripts `checks/r1`–`r6` and their `.out` files.*

* **What was read.**
  * The brief `../00-brief.md` in full, including the author's message.
  * `notes.md` in full.
  * All six author scripts and all six outputs in full.
  * From Paper 2 (`paper-steeper/sections/`):
    * `setup.tex` and `app-setup.tex` in full: the data objects, the classes, the hull lemma and its proof, (F1)–(F5);
    * `kinks.tex` and `app-kinks.tex` in full: `def:kink:kinks`, `lem:kink:main` and its proof, `lem:kink:secant`;
    * `recovery.tex` in full; `app-recovery.tex`: `lem:recovery:ratios`, the proof of `thm:recovery:main`, `prop:recovery:beyond` and its proof; `app-split.tex`: the proofs of `lem:split:ville` and `thm:split:private`;
    * `teacher.tex` in full; `app-teacher.tex` up to the finite-sample lemma;
    * `parity.tex` up to `lem:teacher:twopart`; `app-parity.tex`: the proofs of the list-decoding lemma, the floors, the sharp floor and the coding lemma;
    * `absorb.tex` in full; `app-absorb.tex`: the shared-randomness proof, `prop:absorb:history`, `prop:absorb:inputs`;
    * `limits.tex` from the envelope proposition on; `app-limits.tex`: separable components, guard erosion, `prop:limits:noident`, the input law.
* **What was checked.**
  * Every statement marked **[proved]** in `notes.md`: Lemma 2.1, Theorem 2.2, Proposition 2.3, Propositions 3.1 and 3.3, Remark 3.4, Propositions 4.2 and 4.3, Lemmas 4.4 and 4.5, Theorem 4.6, Corollaries 4.7 and 4.8, Proposition 4.9, the proved parts of Remarks 4.11 and 4.12, and Propositions 5.1–5.3. Each proof was redone from the Paper 2 lemmas it cites; each cited lemma was read in its current form.
  * The six questions the brief puts to this referee: hidden hypotheses, quantifier order, measure versus semimeasure, whether "alien" is defined so that robustness becomes vacuous or circular, whether the window conditions use the right quantities, and whether the toys capture "better at prediction". They are answered in §5.
* **Code.**
  * The six author scripts were rerun with `python3 -I` on copies in the session scratchpad. All six outputs are byte-identical to the saved `.out` files, with empty stderr (Verification log).
  * One independent script was written: `referee-A-checks/ra1_referee.py`, with output `referee-A-checks/ra1_referee.out`. It does not import the author's code. It is seeded (`default_rng(101)`, `default_rng(102)`) or exact, and runs in about 2 s.
* **Status tags.**
  * **[proved]** and **[computed: ra1(X)]** mark this referee's own results.
  * **[confirmed]** means a claim of the record was rederived here.
  * **[refuted]** marks a statement shown false as written, with the counterexample kept.
  * **[gap]** marks a step or reading that the record does not support, without a counterexample to the statement itself.
  * **[remark]** and **[heuristic]** are as named.
* **Repository.** No git command was run. Files written: this report, `referee-A-checks/ra1_referee.py`, `referee-A-checks/ra1_referee.out`.

---

## 0. Verdict

* **The mathematics is sound.** Every statement marked [proved] follows from its cited lemmas as stated, with three exceptions:
  * Proposition 4.9(b) is false as written when a copy of the human is shorter than $\pi_H$, which Setting 4.1 allows (**M3**) [refuted, ra1(C)].
  * The last sentence of Proposition 4.9(b) states more than its proof gives (m1).
  * The proved content of Remark 4.12 is weaker than its "Consequence" sentence (m5).
* **The readings overclaim in four places.** The proofs are right. What the record says they show, in §0, §4.3–§4.4 and §6.1, goes further than the theorems.
  * **M1 (major).** Theorem 4.6 has no upper end. It never says that the human, or a copy of it, is selected. For the coin-flipping human, Corollary 4.7(a) holds "for every $c>2^{-m}$", yet above the human's left steepness the fair coin is selected. That holds in the record's own toy of r4(B) and in ra1(A). So "a coin-flipping human, unconditionally" (§6.1 item 3) is not a solved toy case of *picking the human*. What it solves is narrower: no near-optimal program exploits the environment.
  * **M2 (major).** "Robust against every program, whatever its internal structure" is proved only for programs that already encode the human's model ($M_t$). Every other program is handled by the left condition, which is assumed. The explicit classes of r2, r3 and r4(B) contain no program that predicts well without being built on the human's model. So they never test the case the author cares most about.
    * The referee supplies two pieces that settle the scope.
    * **A1 [proved].** The left condition can always be dropped by taking $t=K(h^*)+\kappa$. The cost is an offset of order $\ell_H$ instead of order $t$. Every alien, whatever its structure, then gains at most about $\ell_H/2^m$ bits per sample in the window. This is an unconditional robustness theorem for a human much simpler than the coupling, $\ell_H\ll2^m$. It matches, up to constants, the necessary condition of Proposition 4.9(d).
    * **R1 [proved].** That hypothesis cannot be dropped. A world with an incompressible coupling ($\Pr[\delta_\beta>j]<2^{-j}$) exists in which *no procedure* copies the human with probability above $C(2^m,s_0)^{-1}$. In that world the human's response depends on the same cells that drive its coins. Every twin world in the argument is again a human with private coins driven by an incompressible coupling. So R1 is not Proposition 4.9(a)'s twin, and the left condition is a real hypothesis, not a technicality.
  * **M3 (moderate).** Setting 4.1 puts the input mechanism $\mu(\cdot\mid\cdot)$ into $h^*$ and pads $\pi_H$ with it. The human's kernel does not depend on $\mu$. When $\mu$ is complex, a shorter copy violates the left condition, and Theorem 4.6 becomes vacuous. It also breaks the "every copy" statements of Proposition 4.9(b),(c) and Theorem 4.6(vi). Fix: take $\pi_H\in\mathcal E_0$.
  * **M4 (moderate).** "Every near-optimal hypothesis is the human's model with essentially fresh coins" is not a conclusion of Theorem 4.6 in $\Hcl{\times}$. The theorem bounds length, risk and information about β. It does not bound any divergence between $\nu_\pi$ and $\nu_H$.
* **Minor issues.** There are fourteen (m1–m14).
* **Code.** All six author scripts reproduce byte for byte. The independent script confirms the following.
  * The r4(B) window and its selections.
  * The union bound of Remark 3.4 is essentially exact: ratio 0.999992 at $n=100$ [computed: ra1(E)].
  * The in-context learner of r5 has a bounded cumulative Hellinger gap against the human. So it is "$P_H$-equivalent on the run", which bears on the claims-table row "(a)-brief refuted" (m2) [computed: ra1(D)].
* **Bottom line for the paper.**
  * The robust-imitation material supports one claim with a precise toy behind it. *For λ = cn in a window above the reuse factor $2^{-m}$, a length-penalised learner does not learn an incompressible coupling between the environment and a human's coins, whatever the alien. This holds unconditionally when the human is much simpler than the coupling (A1). The learner also returns the human's own model when that model is decodable from good predictions (Theorem 4.6, proved for parities).*
  * The window must be stated with both ends. The claim must not say that the human is "selected" or "copied" in $\Hcl{\times}$ without the upper end and without M4's caveat.
  * The positive case is the one where the alien's extra prediction comes from memorising incompressible environment structure. Aliens with a *compact* model of how the environment drives the human's apparent randomness defeat every $c$ (Proposition 4.9(c)), and so do humans entangled with their coupling (R1). The caveats paragraph (target I3) should say this plainly.

---

## 1. Statement by statement

| record item | verdict | comment |
|---|---|---|
| Lemma 2.1 | **confirmed** | The supermartingale computation, the measurability of $M_n$ for $\mathcal A_{n+1}$, $M_0\le1$ and Ville's inequality were all rederived. The novelty claim should be weaker: this is Ville's inequality for a countable mixture of predictable forecasters against the true conditional law. Under (Priv), $\nu_H$ is that law, so the lemma says the truth is not beaten by more than $\ell+\delta^*$. The content is standard; the side-information reading is useful. |
| Thm 2.2(1) | **confirmed** | Every inequality was rederived: the length bound, both fit bounds, the posterior tail $2^{\lambda k+\delta^*-(\lambda-1)\bar\ell}$ and the fill-in mass $2^{\lambda k+\lambda\delta^*-(\lambda-1)L_n}$. |
| Thm 2.2(2) | **confirmed** | Gibbs' inequality with $\sum_y\nu_\pi\le1$. |
| Thm 2.2(3) | **confirmed**, with m14 | Needs $z$ in a countable set, so that $(x,z)$ is an input of $\Hcl{\times}$. |
| Thm 2.2(4) | **confirmed** | $g_{n+1}$ is $\mathcal A_{n+1}$-measurable and the Hellinger martingale goes through. Note that it covers classes containing the in-context learner (m2, A3). |
| Prop 2.3(a),(b) | **confirmed** | Both integrability bounds were rederived. The §0 wording "every $\lambda_n=o(n)$ eventually selects it" (line 25) overstates: what is proved is that every copy is a MAP only finitely often (m4). |
| Remark 2.4 | confirmed as a remark | "About $40\log(n/80)$": the observed regret is 59–86 % of that (m13). |
| Prop 3.1 | **confirmed** | Elementary. |
| Prop 3.3 | (a),(c),(d),(e) **confirmed**; (b) **[gap]** | "Interventions on internal variables" is not defined for programs of $\Hcl{\times}$, which are kernels without internal variables. Read formally, (b) is (c) with the input $(x,\iota)$. Parts (a)–(c) move the non-identifiability to the enlarged observation rather than remove it: among programs with the enlarged kernel the shortest is selected, and it can again be a non-human mechanism (m6). |
| Remark 3.4 | **confirmed** | The exact probability agrees with the union bound to 6 digits at $n\ge100$ [computed: ra1(E)]. |
| Prop 4.2(a) | **confirmed** | |
| Prop 4.2(b) | **confirmed**, with m10 | "They are aliens" needs $P^*\ne\nu_H$ on positive mass. If $x$ is independent of $w$, then $P^*=\nu_H$, because β has exact type ρ. |
| Prop 4.3 | **confirmed** | The hull lemma (iii) applies to the population points. As "robustness" it is a tautology for $J_c$-minimisers, which the record says ("for these procedures"). The rates are relative to $\pi_H$'s point, which matters under M3. |
| Lemma 4.4 | **confirmed** | Rederived. Its proof differs from that of `lem:teacher:coding`: it uses the arithmetic mean $q_w(b)=\sum_x\mu(x\mid w)\nu_\pi(h(x,b)\mid x)$ with Jensen's inequality for $-\log$, where Paper 2 uses a truncated geometric mean. The new proof is simpler and needs no truncation; "same proof" should be "a simpler proof". The step needs $\mu(x\mid w)$ to be lower semicomputable from $h^*$. Finite support is not needed for lower semicomputability: an infinite sum of nonnegative lsc terms is lsc. |
| Lemma 4.5 (a)–(c) | **confirmed** | The chain (F4), (F3), (F1) was rederived. The offset is $G_t=t+\delta_\beta+|B|\log(2^m+1)+2\log(m+1)+(\ell_H-K(h^*))+\kappa$. "Of order $m+\delta_\beta$" (lines 30, 294, 415) hides the factor $|B|$ and the terms $t$ and $\ell_H-K(h^*)$ (m9). The line holds on $M_t$ only; on the whole class the offset can be as large as $H(\rho)\,\ell_H$ (R1(c), ra1(B)). |
| Thm 4.6 (i)–(v) | **confirmed as stated** | Every hypothesis of `lem:kink:main`(i),(ii),(iv) was matched again. The conclusions follow. The issues are M1, M3, M4. |
| Thm 4.6(vi) | **confirmed for $\pi_H$**; "no copy of the human minimises $J_c$" **[gap]** | The proof compares the memoriser with $\pi_H$ only. Under M3 a copy can be shorter than $\pi_H$ by $K(\mu\mid h,\rho)$. The fix is easy in the feature case: the memoriser needs only $h$, ρ and β, not $\mu'$. |
| Cor 4.7(a) | **confirmed as stated**; reading **[refuted]** | See M1. |
| Cor 4.7(b) | **confirmed** | Two small points. The extra $2\log(d+1)$ in $t$ is harmless. $B_\beta=K(S\mid h^*,K(h^*))$ and Paper 2's $B_S=K(S\mid a,K(a))$ differ by $O(\log d+\log m+K(p))$. So the quoted Paper 2 numbers use $\delta_S$, not $\delta_\beta$ (m11). |
| Cor 4.8 | **confirmed for $\Hcl{\times}$** | "Any countable Kraft class containing $\pi_H$" is too general. Lemma 4.4 needs $\nu_\pi$ lsc uniformly, and (F1) needs a c.e. prefix-free class (m7). |
| Prop 4.9(a) | **confirmed** | Elementary. |
| Prop 4.9(b) | first two sentences **[refuted]** as written (M3, ra1(C)); last sentence **[gap]** (m1); the $\ell_{\min}$ sentence **confirmed** | |
| Prop 4.9(c) | **confirmed**, with the caveat of M3 | See also the remark on interpretation in §5.6. |
| Prop 4.9(d) | **confirmed** | The algebra was redone. |
| Remark 4.11, first part | **confirmed** | Averaging over $b'$ inside $q_w$ works, because $b\mapsto b\oplus b'$ is a bijection for each $b'$. |
| Remark 4.12 | **[gap]** | See m5. |
| Prop 5.1 | **confirmed**, with m12 | |
| Prop 5.2 | **confirmed** | |
| Prop 5.3 | **confirmed** | The backward induction ($M_t\ge\Ex[M_T\mid\mathcal F_t]=1$ and $\Ex M_t=1$) and the per-episode Hölder step $\Ex Z^s\le(\Ex Z^{1/2})^{2(1-s)}(\Ex Z)^{2s-1}$ were rederived. The learner is excluded by the design of the class (m3). |
| Claims table, row "(a)-brief" | **[gap]** | See m2. |

---

## 2. Major and moderate issues

### M1 (major). Theorem 4.6 has no upper end, and "solved unconditionally" does not mean "the human is picked"

* **What the record says.**
  * Corollary 4.7(a) (line 227, claims row 4.7(a)): for the coin-flipping human, (i)–(v) of Theorem 4.6 "hold for **every** $c>2^{-m}$".
  * §6.1 item 3 (lines 365–366) lists "a coin-flipping human, unconditionally" among the "toy cases solved" of "the ideal theorem in the author's strong form".
  * "What the theorem says" (line 224): "every near-optimal hypothesis is the human's model with essentially fresh coins".
* **What the theorem gives.**
  * (i) is vacuous for the coin human, because $M_t$ is the whole class.
  * (iii) allows $R(\pi)$ up to $H(\rho)+c(\ell_H-\ell_{\rm fl})+\varepsilon$, a slack that grows linearly in $c$.
  * (v) allows the human to be $g_t+(c-2^{-m})(\ell_H-\ell_{\rm fl})$ worse than optimal.
  * Nothing in (i)–(v) excludes a *shorter, worse* program: a cruder coin law, the uniform coin, a program in $M_t$ that knows less of the model. Such a program wins whenever $c$ exceeds the human's left steepness $s_-(H)$. Nothing in (i)–(v) is false; they simply do not speak to selection.
* **Counterexample to the reading** [computed: ra1(A); also the record's own r4(B)]. The coin-flipping human has 16 cells, $|S|=2$, $p=1/8$, so $2^{-m}=0.0625$. In the explicit class of r4(B) the population window is $(s_+,s_-)=(0.0544,0.1521)$. The population $J_c$-minimiser is:
  * the human $H(1/8)$ for $c\in\{0.06,0.0625,0.07,0.10,0.15\}$;
  * the **fair coin**, risk 1.0 against $H(1/8)=0.5436$, for every $c\in\{0.16,0.25,0.5,1\}$, all of them above $2^{-m}$.

  r4(B) shows the same from samples: at $c=0.25$ the cn-MAP is the coin with probability 1.0000 from $n=256$. So at $c=0.25$ "Theorem 4.6 holds", and the procedure returns a program that is not a copy of the human and predicts 0.456 bits per sample worse. By the record's own definition (§1.1: "an alien is any program of the class that is not a copy"), that program is an alien.
* **What is true.**
  * Theorem 4.6 is a statement that *the environment is not exploited*. Near-optimal programs hold little information about β and predict no better than the human up to slack.
  * Selection of the human needs, in addition, $c$ below the human's left steepness among all programs. That is $s_-(H)$ of Proposition 4.3, or for $\Hcl{\times}$ the left steepness at $(\ell_H,H(\rho))$, which nothing in §4 bounds below except Corollary 4.7(b) via $c_{\rm hi}$.
  * In $\Hcl{\times}$, the "neither better nor worse" clause of (iii) is informative only when $c(\ell_H-\ell_{\rm fl})$ is small. For $c=a2^{-m}$ that means $a(\ell_H-\ell_{\rm fl})\ll2^m$.
* **Fix.**
  * State the window with both ends: $c\in(2^{-m},\,\bar c)$, with $\bar c$ the human's left steepness, or $c_{\rm hi}$ for parities.
  * Rewrite Corollary 4.7(a) as "(ii)–(v) hold for every $c>2^{-m}$; the human is the minimiser only for $c<s_-(H)$".
  * In §6.1 item 3, replace "a coin-flipping human, unconditionally" by "a coin-flipping human: no exploitation of the environment for every $c>2^{-m}$; selection of the human for $c\in(2^{-m}(1+o(1)),s_-(H))$".

### M2 (major). Robustness "whatever its internal structure" is proved only for aliens built on the human's model

* **What the record says.**
  * Lines 30 and 198: Lemma 4.5 "bounds every program of the class, whatever its internal structure, by the information it holds".
  * Line 365: "The robustness comes from an information bound (Lemma 4.5), not from listing aliens".
* **What Lemma 4.5 bounds.** It bounds the programs of $M_t=\{\pi:K(h^*\mid\pi)\le t\}$, those that already contain the human's model. A program that predicts $y$ well *without* encoding $h^*$ is outside $M_t$. That is the author's "arbitrarily alien thinking to think about what the human might say next". Such a program is controlled only by the left condition $(\mathrm L_{t,c,\varepsilon})$, which Theorem 4.6 assumes. The record is careful in the statement of Theorem 4.6 and in §6.2 item 4. Its readings are not.
* **The computed evidence does not test this case.** In the explicit classes of r2, r3 and r4(B), the only programs that do not contain the true parity are the coin and the wrong-parity programs. The latter have risk ≥ 1 and are dominated by the coin. Every alien is "the human's model plus memorised cells" or "the human's model plus a generator". The exact windows of Remark 4.10 are therefore Proposition 4.3 evaluated in a class where the left condition holds by construction.
* **The left condition is a real hypothesis.** Proposition R1 below gives a world in which:
  * the coupling is incompressible ($\Pr[\delta_\beta>j]<2^{-j}$);
  * an alien of length at most $\ell_H+O(\log m)$ has risk 0;
  * *no procedure* copies the human with probability above $C(2^m,s_0)^{-1}$, here $2^{-341.1}$.

  In an explicit class for that world, a right line of slope $2^{-m}$ on the whole class needs an offset of $351$ bits, $0.34\,\ell_H$ [computed: ra1(B)]; R1(c) gives the same order in $\Hcl{\times}$. The record's machine-free offset on $M_t$ is $26.9$ bits.
* **Part of the left condition is never needed (A1 below).** Taking $t=K(h^*)+\kappa$ makes $M_t$ the whole class for *every* human, not only the coin. The conclusions (ii)–(v) then hold unconditionally with an offset $G^*\approx\ell_H+\delta_\beta+|B|\log(2^m+1)$. So robustness against every alien holds, in the sense of non-exploitation, whenever the human is much simpler than the coupling, $\ell_H\ll2^m$. The left condition only buys (i), "knows the model", and an offset of order $t$ instead of $\ell_H$.
* **Fix.**
  * Restate the robust part as two statements.
    * (α) Unconditional (A1): when $\ell_H\ll2^m$, no near-optimal program, whatever its structure, gains more than $O(a\ell_H/((a-1)2^m))$ bits per sample at $c=a2^{-m}$, or holds more than $O(a\ell_H/(a-1))$ bits about β.
    * (β) Under the left condition, proved for parities: near-optimal programs know the human's model, with offsets of order $t$.
  * Say explicitly that R1 makes the condition "$\ell_H\ll2^m$ or a left condition" necessary.
  * Replace "whatever its internal structure" in lines 30 and 198 by "among programs that encode the human's model; for all programs with an offset of order $\ell_H$ (A1)".

### M3 (moderate). $\pi_H$ is padded with the input mechanism, so shorter copies break the left condition and the "every copy" statements

* **The problem.**
  * Setting 4.1 (line 143) lets $h^*$ describe $(h,\rho,\mu(\cdot\mid\cdot))$ and builds $\pi_H$ from $h^*$, so that $t_0=K(h^*\mid\pi_H)$ is a constant.
  * The kernel $\nu_H(y\mid x)=\rho(b)$ for $y=h(x,b)$ does not depend on μ. A shortest copy $\pi'\in\mathcal E_0$ therefore has length about $\ell_H-K(\mu(\cdot\mid\cdot)\mid h,\rho)$.
* **Consequences.**
  * (a) *Theorem 4.6 can be vacuous.* $\pi'$ has $K(h^*\mid\pi')\approx K(\mu\mid h,\rho)$. If this exceeds $t$, then $\pi'$ lies outside $M_t$ and $J_c(\pi')<J_c(\pi_H)$, so $(\mathrm L_{t,c,\varepsilon})$ fails for every $c$.
    * Both instances of Corollary 4.7 are unaffected: μ is trivial for the parity, and $t=K(h^*)+\kappa$ for the coin.
    * In the general latent-cause reading the hypothesis silently requires $K(\mu\mid h,\rho)\le t$.
    * Taking $\pi_H:=\pi'$ repairs it. Then $t_0\approx K(\mu\mid h,\rho)$ is no longer a constant, but $t_0$ and $\ell_H-K(h^*)$ cancel in $G_t$.
    * The reading "it knows the human's model" then includes knowing the environment's input mechanism. The record says this once (line 143) but not in §6.
  * (b) *Proposition 4.9(b) is false as written.* "π beats every copy of the human" uses the rate $r(\pi)$ relative to $\pi_H$. Relative to a shorter copy the rate is smaller.
    * Counterexample [computed: ra1(C)]: $\pi'=(10,R_H)$, $\pi_H=(20,R_H)$, alien $(30,R_H-0.5)$. The rate against $\pi_H$ is 0.05 and against $\pi'$ is 0.025.
    * At $c'=0.0375<r(\pi)$ the alien beats $\pi_H$ ($J=1.125$ against $1.25$) but not $\pi'$ ($J=0.875$).
    * The same applies to the second sentence (shorter programs), to Proposition 4.9(c) ("no $c$ makes any copy … the unique minimiser") and to Theorem 4.6(vi) ("no copy of the human minimises $J_c$").
  * (c) *Proposition 4.3* is correct for $\pi_H$. But with a shorter copy present, $s_-(\pi_H)=0$ and $\pi_H$ is never selected. So "the window" should be the window of a shortest copy.
* **Fix.** Throughout §4, let $\pi_H\in\mathcal E_0$ be a shortest copy, and define $r$, $s_\pm$ and the window at $(\ell_0,H(\rho))$. Then:
  * set $t_0:=K(h^*\mid\pi_H)$ without claiming that it is a constant;
  * in Theorem 4.6(vi), build the memoriser from a copy plus the index of β: in the feature case it needs $h$, ρ and β only. Recovering $h$ from a copy costs $O(|B|\log|B|)$ for the labelling of the coins.

### M4 (moderate). "Essentially fresh coins" and "copy" are not conclusions of Theorem 4.6 in $\Hcl{\times}$

* **What the theorem bounds.** Theorem 4.6 bounds $\ell(\pi)$, $R(\pi)$ from both sides, and $I_\beta(\pi)$. It bounds no distance between $\nu_\pi$ and $\nu_H$.
  * "It knows the model, … predicts no better than the human up to a slack, holds only a few bits about β" is proved.
  * "Every near-optimal hypothesis is the human's model with essentially fresh coins" (lines 224, 365) is an interpretation.
* **What the instances give.**
  * For the parity, Paper 2 gives more: agreement $u\ge0.983$ and probability on environment-driven labels $e\le0.200$. These are behavioural statements close to "a copy", but still not $\nu_\pi\approx\nu_H$.
  * Paper 2's `rem:teacher:selected` already warns that the minimiser can be another rate. The record repeats this.
* **Fix.** Say "holds only $O(\cdot)$ bits about β and has risk within the slacks of the human's". Reserve "copy" for $\mathcal E(\nu_H)$, which is reached only in the explicit classes of r2, r3 and r4(B).

---

## 3. Minor issues

* **m1. The last sentence of Proposition 4.9(b)** (line 254) says "a schedule keeps the human only if $\lambda_n/n$ eventually stays in $[s_+(H),s_-(H)]$".
  * The first two sentences give, by contraposition, only $\liminf_n\lambda_n/n\ge s_+$ and $\limsup_n\lambda_n/n\le s_-$, once both are repaired under M3.
  * A schedule with $\lambda_n/n=s_+-1/n$ never lies in the interval and is not covered: no $c'<s_+$ bounds it on an infinite set.
  * It does not keep the human either, since the comparison with the maximising alien is then a driftless random walk plus a bounded term. But that needs a separate argument.
  * State the liminf/limsup form.
* **m2. The claims-table row "(a)-brief … refuted for classes that contain an in-context learner"** (line 435) needs a qualification.
  * Theorem 2.2(4), the record's own result, proves the weak form of the brief's claim for *every* predictor class: from some $n$ on, every λ-MAP is "equivalent on the run". That covers classes containing the learner.
  * The dominating mixture has $\Ex\sum_i\KL\le\log(1/w)$, so its cumulative Hellinger gap is almost surely finite, and the λ-MAP of Proposition 5.2 *is* equivalent on the run [computed: ra1(D)]. Along three trajectories of length 4000, $\sum\Hel$ is 1.14, 2.20 and 1.02, flat after $n\approx2000$. A memoryless sampler reaches about 100.
  * So the row should read: "holds in the weak sense (equivalent on the run) in every class (2.2(4)); fails in the strong sense (the selected program is the human's program, or a copy) in classes with a dominating learner (5.2)".
* **m3. Proposition 5.3 excludes the learner by the design of the class.**
  * The class consists of episodic predictors that restart. A class whose hypotheses keep memory across episodes contains a cross-episode mixture. That mixture pays $\log(1/w)$ once in total, and Proposition 5.2's argument then applies again.
  * §6.1 item 1 (line 363) attributes the exclusion to randomness "private … to each episode". It should say that the *hypotheses* restart at episode boundaries. This is a modelling choice of the same kind as the product class, not a property of the human.
* **m4. Line 25 says "every $\lambda_n=o(n)$ eventually selects it".**
  * Proposition 2.3(b) proves that every copy is a $\lambda_n$-MAP only finitely often, not that $\pi^*$ is selected.
  * "Privacy is exactly the condition" also presupposes a calibrated human. In the latent-cause case of §4 privacy fails through $x$ itself.
* **m5. Remark 4.12 is marked "[proved, new; elementary]".** Two parts are proved:
  * in $W_E$, Theorem 4.6 with $E2^m$ cells, under its left condition;
  * in $W''$, the memoriser beats every copy of $\nu_H$ below about $2^{-m}$.

  The "Consequence" sentence, that the procedure "attributes … one that is shared across environments to the human", needs the selected program in $W''$ to have $W''$'s kernel, or low risk. For general $h$ that needs a memoriser-regime theorem like `thm:teacher:main`(iii), which §4 does not have. Downgrade the sentence to [remark], or restrict it to the parity instance.
* **m6. Proposition 3.3(b).** See the table in §1. Also add one sentence: data about the mechanism identify the kernel of the enlarged observation, and the selected program is again a shortest program for *that*. Mechanism is identified only to the extent the enlarged observation pins it down.
* **m7. Corollary 4.8** should be stated for $\Hcl{\times}$, or for classes as in `def:setup:class` covered by `prop:related:computable`, with their own κ. Lemma 4.4 needs uniform lower semicomputability, and (F1) needs a c.e. prefix-free class.
* **m8. $h^*$ is "a finite description".**
  * $K(h^*)$ and $K(h^*\mid\pi)$ depend on which description is meant.
  * Fix $h^*$ as a shortest program for the triple, or as its canonical index. Otherwise "knows the human's model" can fail for a program that computes the same triple through a different description.
* **m9. "Offset of order $m+\delta_\beta$"** (lines 30, 294, 415). $G_t$ contains $|B|\log(2^m+1)$, so it is linear in the coin alphabet size, and it also contains $t$ and $\ell_H-K(h^*)$. Write $|B|m+t+\delta_\beta$.
* **m10. Proposition 4.2(b)** needs "if $x$ carries information about $w$". See the table in §1.
* **m11. Corollary 4.7(b)** quotes Paper 2's numbers, which use $\delta_S$. In the record's notation $\delta_\beta$ is conditioned on $h^*$, and the two differ by $O(\log d+\log m+K(p))$. Say which is meant.
* **m12. Proposition 5.1.**
  * "The human's predictive law given the observable history" is a property of the human alone only if the environment chooses $x_i$ from the observable history and independent randomness. If the inputs depend on anything correlated with the hidden state, $P_H$ depends on the environment's policy.
  * Proposition 5.3's $\mathcal E^{\rm ep}$ likewise depends on the environment's law.
  * State the assumption.
* **m13. Numerical comparisons.**
  * r1(A) and r5(A) compare the empirical tail of δ* with $2^{-j}$. The sharper bound is (Kraft sum)$\cdot2^{-j}$: 0.125 and 0.258. The data are consistent with it within sampling error. In r5(A) at $j=1$ the value is 0.1375 against 0.129, which is 55 runs against 51.6. At $j=6$ it is 2 runs against 1.6.
  * Remark 2.4's "about $40\log(n/80)$" is above the observed regret, which is 14–41 % lower.
* **m14. Theorem 2.2(3)** needs the environment features $z$ to range over a countable set, so that $(x,z)$ is an input of $\Hcl{\times}$. Setting 2.0 does not say so.

---

## 4. Referee additions

### A1. Theorem 4.6 without the left condition, for every human [proved]

**Proposition A1.** In Setting 4.1, put
$$G^*:=\ell_H+\delta_\beta+|B|\log(2^m+1)+2\log(m+1)+\kappa .$$
For every $c>2^{-m}$ and $\varepsilon\ge0$, every program $\pi\in\Hcl{\times}$ with $J_c(\pi)\le\Phi(c)+\varepsilon$ satisfies:
* $\ell(\pi)\le\ell_H+(G^*/2^m+\varepsilon)/(c-2^{-m})$;
* $H(\rho)-\dfrac{cG^*/2^m+2^{-m}\varepsilon}{c-2^{-m}}\le R(\pi)\le H(\rho)+c\,\ell_H+\varepsilon$;
* $I_\beta(\pi)\le\ell(\pi)+\kappa$;
* moreover $J_c(\pi_H)\le\Phi(c)+G^*/2^m+(c-2^{-m})\ell_H$.

At $c=a2^{-m}$ with $a>1$:
* $\ell(\pi)\le\ell_H+(G^*+2^m\varepsilon)/(a-1)$;
* $|R(\pi)-H(\rho)|\le\max\{(aG^*/2^m+\varepsilon)/(a-1),\ a\ell_H/2^m+\varepsilon\}$;
* $I_\beta(\pi)\le\ell_H+(G^*+2^m\varepsilon)/(a-1)+\kappa$.

*Proof.* Lemma 4.4, (F3) and (F1) give, for every π,
$$B_\beta-O(1)\le K(\beta\mid h^*)\le K(\pi)+K(\beta\mid h^*,\pi)+\kappa\le\ell(\pi)+2^mR(\pi)+2\log(m+1)+\kappa .$$
With $B_\beta=L_\beta-\delta_\beta\ge2^mH(\rho)-|B|\log(2^m+1)-\delta_\beta$ this is the right line
$$\ell(\pi)-\ell_H\ge2^m\big(H(\rho)-R(\pi)\big)-G^*$$
on the whole class, with length floor 0. Equivalently, it is Lemma 4.5 with $t=K(h^*)+\kappa$, which is $\ge t_0$; then $M_t=\Hcl{\times}$, and $t+(\ell_H-K(h^*))=\ell_H+\kappa$. Apply `lem:kink:main`(ii),(iv),(i) with $\mathcal N=\emptyset$, so that $\eta_{\mathcal N}=+\infty$, $\tau=2^{-m}$, $g=G^*/2^m$ and $\ell_{\mathcal M}=0$. The information bound is $I_\beta(\pi)\le K(\pi)+\kappa$ (Lemma 4.5(b) with $K(h^*\mid\pi)\le K(h^*)+\kappa$). ∎

* **Reading.**
  * When the human is much simpler than the coupling, $\ell_H\ll2^m$ (with $\delta_\beta$ and $|B|m$ also $\ll2^m$), then at every $c=a2^{-m}$ with fixed $a>1$:
    * no near-optimal program, *whatever its structure and whether or not it knows the human's model*, predicts better than the human by more than $O(a\ell_H/((a-1)2^m))$ bits per sample;
    * none holds more than $O(a\ell_H/(a-1))$ of the $L_\beta\approx2^mH(\rho)$ bits of the coupling;
    * the human is within $O(a\ell_H/2^m)$ per sample of optimal.
  * This is the unconditional robustness theorem. Corollary 4.7(a) is its special case, and it needs no left condition.
  * It matches Proposition 4.9(d), which says a window needs $2^m\gtrsim(\ell_H-\ell_{\rm u})/(\log|Y|-H(\rho))$, up to the factor $\log|Y|-H(\rho)$ and constants.
  * The left condition of Theorem 4.6 adds two things: (i), and an offset of order $t$ in place of $\ell_H$. Both matter when $\ell_H$ is not small compared with $2^m$, as for the parity at Paper 2's sizes, where $d=100$ and $2^m\approx10^6$.
  * As in M1, A1 does not say that the human is selected.

### R1. Model–coupling confounding: incompressibility is not enough, for any procedure [proved; computed: ra1(B)]

**Proposition R1.**
* **Setup.**
  * Fix $m\ge2$ and $1\le s_0<2^{m-1}$, and put $p=s_0/2^m$.
  * Take the feature case of Setting 4.1 with $X=W=\{0,1\}^m$, $\mu(\cdot\mid w)=\delta_w$, $Y=B=\{0,1\}$ and $\rho=\mathrm{Bern}(p)$.
  * For a table $f:W\to\{0,1\}$, the human $H_f$ answers $h_f(w,b)=f(w)\oplus b$, with kernel $\nu_f(y\mid w)=1-p$ if $y=f(w)$ and $p$ otherwise.
  * Draw $f$ uniformly, and β uniformly among the $s_0$-subsets of $W$, independently. The data are i.i.d. pairs $(w_i,T(w_i))$ with $T:=f\oplus\ind_\beta$ and $w_i$ uniform.
* **(a)** $\Pr[\delta_\beta>j]<2^{-j}$: the coupling is incompressible given the human's model, as Lemma 4.5 and Theorem 4.6 require.
* **(b)** For every procedure Ψ (any measurable function of the data, randomised or not) and every $n$,
  $$\Pr[\Psi_n\in\mathcal E(\nu_f)]\le\binom{2^m}{s_0}^{-1}=2^{-L_\beta},$$
  the probability being over $(f,\beta)$, the data and Ψ's randomness. Hence $\Pr[\Psi_n\in\mathcal E(\nu_f)\mid\delta_\beta\le j]\le2^{-L_\beta}/(1-2^{-j})$.
* **(c)** In $\Hcl{\times}$, with probability at least $1-2^{-j}$:
  * every copy of $H_f$ has length at least $2^m-j-\kappa$;
  * the table program $D(T)$ has length at most $2^m+2\log(m+1)+\kappa$ and risk 0.

  So the right line of slope $2^{-m}$ at the human's point $(\ell_0,H(p))$ needs, on the whole class, an offset of at least $2^mH(p)-j-2\log(m+1)-2\kappa\approx H(p)\,\ell_0$. Once $H(p)(2^m-j-2\kappa)>(1-H(p))(j+2\log(m+1)+2\kappa)$, every $c>0$ has $D(T)$ or the fair coin beating every copy of the human, so no window exists.

*Proof.*
* (a) Conditional on $f$, hence on $h^*=(f,\rho,\mu)$, β is uniform on its type class. This is the record's counting statement.
* (b) The map $(f,\beta)\mapsto(T,\beta)$ is a bijection, so $T$ is uniform and independent of β. The data, and so $\Psi_n$, depend on $(f,\beta)$ only through $T$ and the independent $w_i$. Fix $T$, the $w_i$ and Ψ's randomness; then $\Psi_n=\psi$ is one program with one kernel. The kernels $\nu_{T\oplus\beta'}$ for distinct $\beta'$ differ at the cells of $\beta\,\Delta\,\beta'$, each of μ-mass $2^{-m}$. So ψ lies in $\mathcal E(\nu_{T\oplus\beta'})$ for at most one $\beta'$, and its conditional probability of copying the human is at most $\max_{\beta'}\Pr[\beta=\beta']=2^{-L_\beta}$. Average over the conditioning.
* (c) From any copy π the table $f$ is computable: $f(w)$ is the label whose lower approximations of $\nu_\pi(\cdot\mid w)$ eventually exceed $\frac12$, as $p<\frac12$. So $K(f)\le\ell(\pi)+\kappa$, and $\Pr[K(f)<2^m-j]<2^{-j}$. $D(T)$ reads $m$ self-delimitingly and then $2^m$ bits. The fair coin has length at most κ and risk 1. Compare $J_c$. ∎

[computed: ra1(B), $m=10$, $s_0=64$, an explicit prefix class: tag, table, 6-bit rate.]
* $D(T)$ is 6 bits shorter than the human-type program $H(f,p)$, which has length 1032, and has risk 0. So $J_c(H(f,p))-J_c(D(T))>0.337$ for every $c$.
* The slope-$2^{-m}$ offset at the human's point is $351.4$ bits $=0.3405\,\ell_H$, against $H(p)=0.3373$. The record's machine-free offset is $26.9$ bits.
* Five random $\beta'$ give human-type programs $H(T\oplus\beta',p)$ with risk exactly $H(p)$ and the human's length. Their kernels differ from the true human's at 120–124 of the 1024 cells. There are $2^{341.1}$ such humans.

* **Reading.**
  * R1 differs from Proposition 4.9(a). There the twin is a human who really responds to the environment. Here *every* twin is a human with private coins driven by an incompressible coupling, exactly the situation in which the record's theorems are meant to succeed.
  * What fails is the human's response function depending on the same cells as the coupling, with $\ell_H$ of the order of $2^m$. Then the decomposition $T=f\oplus\beta$ into "human" and "environment" is not identified by anything.
  * So the left condition of Theorem 4.6, or $\ell_H\ll2^m$ as in A1, is a necessary hypothesis, not a technicality. The record's list of failure modes (§6.2) should gain this one.
  * [heuristic] In $\Hcl{\times}$ the cn-MAP at $c>2^{-m}$ in this world would likely select a human-type program $H(f',p)$ with the *simplest* $f'$ within Hamming radius $s_0$ of $T$: a rate–distortion choice, not $f$. This is not proved here.

### A3. The in-context learner is equivalent on the run [computed: ra1(D)]

This uses the setting of r5: the two-mood hidden Markov human, the 3375-member family with weights $2^{-12}$ and the Bayes mixture $U$. The mixture's predictive law is normalised, so the first step differs from the semimeasure by a constant factor 0.824. Along three trajectories:

| | $n=500$ | $n=1000$ | $n=2000$ | $n=4000$ |
|---|---|---|---|---|
| $\sum_i\Hel(P_H,P_U)$, run 0 | 1.02 | 1.07 | 1.13 | 1.14 |
| $\sum_i\Hel(P_H,P_U)$, run 1 | 1.44 | 1.91 | 2.18 | 2.20 |
| $\sum_i\Hel(P_H,P_U)$, run 2 | 0.79 | 0.95 | 1.02 | 1.02 |

* At $n=4000$ the sums of KL are 6.40, 12.45 and 5.84 bits. The bound $\log(1/w)=12$ holds for the *expected* sum; on one path it can be slightly exceeded, as run 1 does at 12.45.
* A memoryless Krichevsky–Trofimov sampler has $\sum\Hel\approx100$ at $n=4000$, linear in $n$.
* So Theorem 2.2(4) and Proposition 5.2 are consistent. The learner that is selected is equivalent on the run, and what fails is only the identity of the selected program (m2).

### A4. Remark 3.4's bound is essentially exact [computed: ra1(E)]

The exact probability that some $e_j$ is a 1.2-MAP per query was computed by inclusion–exclusion in rational arithmetic. Against the record's union bound $10((9/10+1/640)^n-(9/10)^n)$:

| $n$ | exact | union bound | ratio |
|---|---|---|---|
| 10 | $5.9352\cdot10^{-2}$ | $6.1010\cdot10^{-2}$ | 0.9728 |
| 50 | $4.6629\cdot10^{-3}$ | $4.6694\cdot10^{-3}$ | 0.99859 |
| 100 | $5.0311\cdot10^{-5}$ | $5.0311\cdot10^{-5}$ | 0.999992 |

The record's numbers $5.0\cdot10^{-5}$ and $5.0\cdot10^{-18}$ stand.

---

## 5. The six questions put to this referee

### 5.1 Hidden hypotheses

* **§2.**
  * (Priv) is a calibration-plus-independence condition. It makes $\nu_H$ the Bayes-optimal predictor given everything a hypothesis sees. It is stated.
  * Setting 2.0 should also say that $z$ is countable (m14).
* **§4.** The stated hypotheses are the uniform cells, the exact type, injectivity in $b$, computable $h$, ρ and μ, a small $\delta_\beta$, and the left condition. There are three unstated ones:
  * (i) $\pi_H$ is padded with μ, or equivalently $K(\mu\mid h,\rho)\le t$ (M3);
  * (ii) $h^*$ is a canonical description (m8);
  * (iii) for any *identification* reading, $\ell_H\ll2^m$ or the left condition, which R1 shows is necessary.
* **§5.**
  * The inputs depend only on the observable history (m12).
  * The hypotheses restart at episode boundaries; this is stated as a property of the class but read in §6.1 as a property of the human (m3).

### 5.2 Quantifier order

No error was found.
* In Lemma 2.1, δ* is one random variable, uniform over all predictors and all $n$.
* In Theorem 2.2(1) the bounds hold simultaneously for all $n$.
* In Theorem 4.6 everything is at a fixed $c$, and the left condition depends on $c$.
* Corollary 4.8 holds for each fixed $c$, almost surely eventually. It is not uniform in $c$. Paper 2's `prop:teacher:schedules`(c) gives uniformity over compact subintervals only for the parity, and the record does not claim more.
* Proposition 4.9(a) holds for every procedure and every $n$.
* The only quantifier slip is the "eventually stays in" of m1.

### 5.3 Measure versus semimeasure

No error was found.
* Hypotheses are sub-probabilities throughout. Gibbs' inequality, Lemma 4.4's $\sum_bq_w(b)\le1$ and $Q$'s total mass all use $\sum_y\nu_\pi\le1$ correctly, and r6(A) tests sub-probability kernels.
* The human, $P^*$ and $P_H$ are probability kernels where (Priv) and Ville require it.
* Proposition 5.2's mixture is a chronological semimeasure with weight sum 0.824, which is harmless.
* Proposition 5.3's "KL $=0\Rightarrow$ copy" uses $\sum_yq_\pi\le1$ at the last step, correctly.

### 5.4 Is "alien" defined so that robustness is vacuous or circular?

The robustness claims are not vacuous: every class considered contains aliens, and the theorems say something about them. In each section, however, the *hard* aliens are removed by an assumption or by the design of the class:
* **§2.** Under (Priv) no alien predicts better in population. Robustness is the standard fact that the truth is not beaten by a countable mixture by more than its log-weight plus δ*. This is the degenerate case of the author's scenario, which the record says (line 364). It should not be called "the ideal theorem holds".
* **§3.** Equivalent aliens are not excluded, and they win. This is honest.
* **§4.** Lemma 4.5 covers aliens built on the human's model. Every other alien is excluded by the left condition, an assumption verified only for parities (Paper 2) and for trivial models (M2). The explicit classes contain no other aliens. A1 removes the assumption at offset $\ell_H$; R1 shows that something of the kind is needed.
* **§5.** The cross-episode learner is excluded by restricting the class to restarting hypotheses (m3).

Nothing is circular in the strict sense: no theorem assumes its conclusion. But in §4 the reading "robust against every alien whose advantage per bit is below $c$" (line 365) is Proposition 4.3, a tautology for $J_c$-minimisers. The non-trivial content is the bound on the advantage per bit. That bound is $2^{-m}$ with offset $t$ on $M_t$ (Lemma 4.5), and $2^{-m}$ with offset $\ell_H$ on the whole class (A1).

### 5.5 Are the window conditions stated with the right quantities?

* **Lower end.** $2^{-m}$ is the reuse factor for uniform cells, and it is the right quantity.
  * The exact lower end is the largest alien rate $s_+$, which is $2^{-m}(1-o(1))$ in the explicit classes. It can also be slightly *above* $2^{-m}$: with the machine constants set to 0, r6(C) gives the memoriser's rate $1.0105\cdot2^{-m}$ for $\rho=(\frac12,\frac14,\frac14)$, $m=6$.
  * Theorem 4.6's slack $g_t/(c-2^{-m})$ blows up at $2^{-m}$, consistently.
  * Non-uniform cells are open, as the record says.
* **Upper end.** It is missing from Theorem 4.6 (M1). It is the human's left steepness, or $c_{\rm hi}$ for parities.
* **Offsets.** They are $|B|m+t+\delta_\beta$ on $M_t$ (m9), and of order $\ell_H$ on the whole class (A1, sharp by R1(c)).
* **Reference point.** It should be a shortest copy (M3).
* **The necessary condition.** Proposition 4.9(d) uses the right quantities: cells against bits of the human per bit of the human's explanatory power. A1 gives the matching sufficient condition up to constants.

### 5.6 Does the toy capture "better at prediction"?

* **§2: no, by design.** Aliens win only on samples.
* **§3: no.** Aliens predict identically.
* **§4: yes.** Aliens beat the human in population by up to $H(\rho)-H_W(Y\mid X)$ bits per sample. Three caveats belong in the paper.
  * (i) **The alien's extra prediction is memorisation.** The coupling is a fixed incompressible table on $2^m$ cells, so the only way to predict better is to store it cell by cell, which is the least "alien" kind of thinking. An alien with a *compact* model of how the environment drives the human's apparent randomness is the case of a compressible coupling. Proposition 4.9(c) shows that this defeats every $c$.
  * (ii) **The deterministic-brain case.** When the "coupling" is the human's own deterministic brain with a short seed (line 375), the program that models it is arguably the more faithful copy of the human. "Failure" there is failure to return the *stipulated* target $\nu_H$, the human with fresh coins. The target is a modelling choice, which Proposition 4.9(a) shows the data cannot make. Line 375 should say this rather than call it a defeat.
  * (iii) **"Better at prediction" is measured in population log-loss.** The sample statements are asymptotic (Corollary 4.8). The finite-sample form for general $h$ is open, as the record says.
* **§5.** Proposition 5.2 is a genuine case of "an alien that just thinks about what the human would say and predicts as well". The record handles it correctly as a negative result.

---

## 6. Recommended changes

1. **§0 item 3, §4.4 "What the theorem says", §6.1 item 3.**
   * Replace "every near-optimal hypothesis is the human's model with essentially fresh coins" by "no near-optimal hypothesis exploits the coupling: each holds at most [bound] bits about β and predicts within [slack] of the human".
   * Add the upper end of the window (M1, M4).
   * List the coin-flipping case as "no exploitation for every $c>2^{-m}$; human selected for $c\in(2^{-m}(1+o(1)),s_-(H))$".
2. **Add A1** as the unconditional form of Theorem 4.6, and say that Corollary 4.7(a) is its special case. Keep Theorem 4.6 with the left condition as the "knows the model" refinement.
3. **Add R1 to §4.5 and to §6.2** as a failure mode: the human's response is entangled with the coupling, and $\ell_H\not\ll2^m$. Replace "whatever its internal structure" in lines 30 and 198 (M2).
4. **Take $\pi_H\in\mathcal E_0$** in Setting 4.1 and in Propositions 4.3 and 4.9, and in Theorem 4.6(vi). Fix the first two sentences of Proposition 4.9(b) and its last sentence (M3, m1).
5. **Requalify the claims-table rows** "(a)-brief" (m2), 4.7(a) (M1) and 4.12 (m5).
6. **For the caveats paragraph of target I3**, three sentences carry the results.
   * The positive results hold when the environment's influence on the human's apparent randomness is incompressible and much larger than the human's own description. Then no learner in the window learns it, whatever the learner's structure.
   * They fail when that influence is compact, or when it is entangled with the human's own response function, for every complexity weight and, in the entangled case, for every procedure.
   * Nothing here identifies the human's mechanism, or chooses $c$.

---

## Verification log

*Run 2026-10-14 with Python 3.11.15 and NumPy 2.4.6.*

**Reruns of the author's scripts.** Each was copied to the session scratchpad and run with `python3 -I`; the output was compared with the saved `.out` file by `cmp`.

| script | time | result |
|---|---|---|
| r1_side_info_ville | 5 s | byte-identical, stderr empty |
| r2_window_exact | 1 s | byte-identical, stderr empty |
| r3_window_samples | 7 s | byte-identical, stderr empty |
| r4_nonident_exact | 34 s | byte-identical, stderr empty |
| r5_latent_state | 398 s | byte-identical, stderr empty |
| r6_coding_lemma | 1 s | byte-identical, stderr empty |

**Independent script** `referee-A-checks/ra1_referee.py`, output `ra1_referee.out`: 2.2 s, stderr empty. It imports only `fractions`, `math` and `numpy`, and not the author's code.
* **(A)** Explicit coin-flipping class, rebuilt: lengths, the rate grid $\{j/8\}$, aliens with Elias-gamma $t$ plus a subset index. Population minimisers at eleven values of $c$. The window $(0.0544,0.1521)$ agrees with r4(B).
* **(B)** R1's world, seeded `default_rng(101)`, with $m=10$, $s_0=64$. The risks are exact, because the disagreement fractions are exactly $p$. The offset is $351.39$ bits. The count of tied human-type programs is $\log_2\binom{1024}{64}=341.10$.
* **(C)** Explicit points for M3. Exact arithmetic.
* **(D)** Forward filters for the 3375 hidden Markov models, seeded `default_rng(102)`, three trajectories of length 4000. Cumulative Hellinger and KL of the mixture, and of a memoryless Krichevsky–Trofimov sampler, against the human.
* **(E)** Inclusion–exclusion with `fractions.Fraction`. The exact probability is $\sum_{k=1}^{10}(-1)^{k+1}\binom{10}{k}P_k$, with $P_k=\sum_{u=0}^k(-1)^u\binom ku(1-k\cdot\frac{63}{640}-u\cdot\frac1{640})^n$.

**Proof checks done by hand for this report.**
* Lemma 2.1.
* Theorem 2.2(1)–(4).
* Proposition 2.3: both integrability bounds.
* Lemma 4.4: the semimeasure property, Jensen's inequality, (F2) uniformly in $(\pi,h^*,m)$.
* Lemma 4.5: (F4), (F3), (F1), and the derivation of $G_t$.
* Theorem 4.6: every hypothesis of `lem:kink:main`(i),(ii),(iv); (vi) against $\pi_H$.
* Corollary 4.7(b): the inclusion of the complement of $M_t$ in the programs of level at least 2.
* Proposition 4.9(a)–(d).
* Remark 4.11, first part.
* Propositions 5.1–5.3, including the backward induction and the per-episode Hölder bound.
* A1 and R1, proved above.

**Not checked.**
* The literature, which is outside this referee's remit; the record cites no new literature.
* The numbers quoted from Paper 2's tables, which were taken as given.
* The decay sub-track.
