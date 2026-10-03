# Review: mathematical correctness of the two-tier, simplicity and existence sections

**Lens.** Mathematical correctness of `paper/sections/twotier.tex`, `simplicity.tex`, `existence.tex` and their appendices `app-twotier.tex`, `app-simplicity.tex` and `app-existence.tex`. I checked the main results against `research/theory/T5`, `T6` and `T7`, including both repair rounds of T7 (Referees A and B, and Round 2: R2-1 to R2-4), and against `research/verification/{T5,T6,T7}-verification.md` and `reverification-round2.md`. I also checked the Lean tags against `lean/InfLearn/*.lean`, `lean/audit-output.txt` and `paper/sections/app-lean.tex`.

**Method.** I re-derived each listed result by hand from the paper's own definitions, then compared it with the repaired T-file statement. I recomputed the quoted constants in Python: noise-free $N_1=16$; $\varepsilon_E=0.0144$ at $p=0.2$, $d=20$; the kink threshold $p<0.1421$; the note's rates $8.99\cdot10^{-3}$ and $1.12\cdot10^{-6}$ (window factor about 8000, MDL switch at $N\approx8.9\cdot10^5$); $\hat s\ge0.980$; the guard-erosion rates $1.22\cdot10^{-2}$ and $1.8\cdot10^{-4}$, and $10^{-4}$ and $7.2\cdot10^{-4}$; the AC rate $5.4\cdot10^{-3}$; $1/\omega(2)=2.4094$; the burn-in counterexample values $-0.585$ and $-0.405$; and the round-1 floor counterexample values $19.8$, $0.9375$ and $3.3$. All of them reproduce.

## 1. Verdict on the main results

| result | verdict |
|---|---|
| `thm:twotier:main`, including the $N_1$ formula | **Correct.** Noisy mode: on each tag there are $1+c_i$ Hoeffding events, each failing with probability at most $e^{-2N_1\Delta^2}$. This works because $e_i=\lfloor(\bar\alpha_i+\Delta)N_1\rfloor$ and (Floor) gives $p\ge\rho_i\beta_i\ge\bar\alpha_i+2\Delta$. Summed over $K$ tags with $c\ge c_i\ge1$, this gives $(1+c)Ke^{-2N_1\Delta^2}\le\delta$. The trimmed-lgg mgu equals $\bigcap_{\lvert E\rvert=e_i}\mathrm{inst}(\mathrm{lgg}(P_i\setminus E))$ on $G$. Noise-free mode: $\sum_ic_ie^{-N_1\pi_i\rho_i}\le cKe^{-N_1\lambda}$, with the ground-rule convention $\rho_i=c_i=1$ (R2-3) and $e_i=0$ (A5). Parts (i)–(v) follow from Lemma `audit`, the closure monotonicity and the "at most two changes" count for both tie-breaking rules. |
| `prop:twotier:practice` | Correct. The $\top/\bot$ closed instance plus a complete $\Sigma^*$ trivializes. The single step $p\step q$ does not, because $p$ is not a tautology. |
| `thm:twotier:burnin` | Correct as repaired in round 2 under (OE). $P_1^{\otimes t}\vert_{E_t}=(1-\pi)^tP_2^{\otimes t}$ and the common-kernel argument are right. The second inequality needs $\delta+\delta'<1$, which is stated. The tightness learner attains $\min(1,\delta(1-\pi)^{-t})$. The practice-following-escalation counterexample is valid. |
| `thm:twotier:depth` | Correct. The reduction uses (b) only when $\varphi_e(e)$ diverges and (a) only when it converges, so $S=\overline K$ would be $\Sigma_1$. |
| `cor:twotier:cpc` | Correct. The closed-instance oracle is exact and deterministic, which is all that Lemma `audit` and Steps 1–4 use (R2-4). The singleton minimal conflicts follow from Lemma `onesided`(b). |
| `thm:twotier:arith` (a)–(f) | Correct. (a) The size $2\lvert\theta\rvert+mn+2$ checks; for $x<S^50$ the total is $10+13=23$. (b) Gödel II plus $\Delta_0$-completeness of $\mathsf Q$. (d) The limit-lemma argument. (e) The tag bound $\le1/(2\Delta)$, and the floor bound $1-(1-\delta)(1-\pi)^t$, which is tight. (f) Backward propagation through $\neg$E. There is a small gap in the proof of (b): see issue 10. |
| `thm:simplicity:kink` | Correct. (a): the argmax argument needs $\tfrac n2\log_2\tfrac{1-p}{p}>u$, which holds for $p<1/4$. The minimizer bound $\tfrac\lambda{\lambda-1}(2\kappa'+o(1))$ is a valid weakening of $(2\lambda\kappa'+o(1))/(\lambda-1)$. (b) follows from Lemmas 2.5a–c; the term $\kappa_n\ni\log_2 n$ pays for $pn$. (c) follows from the coding theorem plus symmetry of information. |
| `thm:simplicity:separable`, `cor:simplicity:selectable` | Correct; standard separable thresholding. |
| `thm:simplicity:validation` | (ii) and (iii) are correct. (i) needs unique population minimizers at the grid values, a hypothesis the round-2 re-verifier flagged and that is still missing (issue 5). |
| `thm:simplicity:division`, `cor:simplicity:window`, `prop:simplicity:sacrifice`, `prop:simplicity:postulates`(a) | Correct. I re-derived the tightened proof, including the zero-value case. |
| `thm:existence:points` | Correct. (b) ⇒ needs only strong completeness. The counterexample to (c) without soundness checks out. |
| `thm:existence:bilindenbaum` | Correct: Zorn on finite witnesses, (Ov) for disjointness, (Wk)+(Cut) for exhaustiveness. |
| `thm:existence:arity` | Correct. The two-atom marginals are independent of $J$, as claimed. |
| `thm:existence:threshold` | Correct. (a) $(t-1)(t-2)\ge0$. (b) The integrality argument gives $m\ge(k-2)s+1$. |
| `thm:existence:omega`, `cor:existence:inductors` | Correct. The induction is on logical symbols, and numerals carry none. The $\Delta_2$ argument and the one-element-structure example are right. |
| `thm:existence:computability` | Correct: the textbook argument, with Tarski, MRDP and Trakhtenbrot applied correctly. |

**Lean tags.** Every Lean name cited in these three sections exists and appears in `audit-output.txt` with only `[propext, Classical.choice, Quot.sound]`; none uses `sorry`. Two problems remain, both in the tagging (issues 1 and 7). `existence.tex` says that almost nothing in the section is formalized, which contradicts `app-lean.tex` and the `Bilateral` and `Specker` modules. In Lemma `twotier:reiter` the one tag is placed after part (c) but names the part-(b) theorem.

## 2. Issues

### Issue 1 — major — `existence.tex` (line 42, "Credit"; line 140; and the theorem environments)
**Problem.** The text says: "Apart from the semantic half of thm:existence:duality ... nothing in this section is formalized in Lean". The tag on `thm:existence:duality` reads "Carnap.Val_mrel (semantic half, propositional Fm)". Both are false. `lean/InfLearn/Bilateral.lean` proves Thm 2.2 (`thm_2_2_a`, `thm_2_2_b`, `coherent_iff_realizable`), Cor 2.3 (`cor_2_3`), the full duality for an arbitrary formula type (`Val_Th`, `scottClosedIso`) and Thm 2.6 (`thm_2_6_a`, `structuralClosedIso`, `thm_2_6_b_realize`). `Specker.lean` proves Thm 3.4 (`thm_3_4`) and the probabilistic triangle (`frustrated_triangle`). All of these appear in `audit-output.txt` without `sorry`, and `app-lean.tex` (lines 76–81) lists them as "exact". The section therefore contradicts the Lean appendix and omits `\leanok` tags on six results.

**Fix.** Replace "Apart from the semantic half of \Cref{thm:existence:duality}, which is \Cref{lem:coherence:duality}(a) and is formalized for the propositional language, nothing in this section is formalized in Lean;" with:

> "\Cref{thm:existence:bilindenbaum,cor:existence:bilateral,thm:existence:duality} are formalized in Lean for an arbitrary set $\Fm$ (module \texttt{Bilateral}), \Cref{thm:existence:structural} for the fixed propositional term algebra, and \Cref{thm:existence:arity} and the probabilistic half of \Cref{prop:existence:triangle} in module \texttt{Specker} (\Cref{tab:lean:map}); nothing else in this section is formalized;"

Make the following tag changes:
* Line 140: `\hfill\leanok{Bilateral.scottClosedIso}\ \leanok{Bilateral.Val\_Th}`.
* Add `\hfill\leanok{Bilateral.thm\_2\_2\_a}\ \leanok{Bilateral.thm\_2\_2\_b}` to `thm:existence:bilindenbaum`.
* Add `\leanok{Bilateral.cor\_2\_3}` to `cor:existence:bilateral`.
* Add `\leanok{Bilateral.thm\_2\_6\_a}\ \leanok{Bilateral.thm\_2\_6\_b\_realize}` to `thm:existence:structural`.
* Add `\leanok{Specker.thm\_3\_4}` to `thm:existence:arity`.
* Add `\leanok{Specker.frustrated\_triangle}` to `prop:existence:triangle`.

Also update the source comment on line 11.

### Issue 2 — major — `intro.tex` line 101 (Table `tab:intro:answers`)
**Problem.** The table says the learner "is sound and exactly convergent for classical propositional logic and complete decidable theories (cor:twotier:cpc, cor:twotier:decidable)". But `cor:twotier:decidable` is explicitly conditional on realizability, and `twotier.tex` line 410 says "The realizability hypothesis is not established for the listed theories". In fact it fails for any calculus that contains $\forall$E as a single schema: the lgg of three $\forall$E instances is over-general (`ind_lgg.py`). Without realizability the paper only shows that the learner stays sound "eventually ... under the depth schedule", and that exactness fails.

**Fix.** Replace the cell with:

> "**Yes, with explicit scope.** The two-tier learner (\cref{thm:twotier:main}) is sound and exactly convergent for classical propositional logic (\cref{cor:twotier:cpc}). For complete decidable theories the residue is empty, and exact convergence holds provided the target calculus is realizable as first-order patterns (\cref{cor:twotier:decidable}); this is open for the usual axiomatizations of RCF, ACF$_p$ and Presburger arithmetic, and fails for a literal $\forall$-elimination schema. It is Popperian for arithmetic, with sharp impossibility results beyond $\Sigma_1$ (\cref{thm:twotier:arith})."

### Issue 3 — major — `philosophy.tex` line 167
**Problem.** The same overclaim appears here: "Yes for classical propositional logic and complete decidable theories". It drops the realizability proviso of `cor:twotier:decidable`.

**Fix.** Replace with:

> "Yes for classical propositional logic (\cref{cor:twotier:cpc}); for complete decidable theories, yes provided the target calculus is realizable in the schema class, which is open for RCF, ACF$_p$ and Presburger arithmetic (\cref{cor:twotier:decidable}). Arithmetic is Popperian. There are sharp limits at $\Sigma_2$ and for Turing progressions."

### Issue 4 — major — `twotier.tex` line 412
**Problem.** "Over $\R$, coherence with a designated truth catches what this computation misses; over $\N$ the converse holds (\Cref{lem:coherence:delta0})." The "converse" would be "computation catches what coherence misses". The cited lemma says the opposite: "$\Delta_0$ feedback is subsumed by coherence; ... no $\Delta_0$ feedback refutes [a consistent $T\supseteq\mathsf Q$]". T7 §6.2 Remark 2 itself glosses the phrase as "Δ₀ computation adds no refutations beyond coherence". That is the same direction as the $\R$ case, not its converse. The paper dropped that gloss, so the sentence now asserts the reverse of the lemma it cites.

**Fix.** Replace with:

> "Over $\R$, coherence with a designated truth catches what this computation misses. Over $\N$ there is no converse: $\Delta_0$ computation refutes nothing that coherence from $\RobQ$ does not already refute (\Cref{lem:coherence:delta0}); what it adds there is localization (\Cref{thm:twotier:arith}(a))."

### Issue 5 — minor — `simplicity.tex` line 301 (`thm:simplicity:validation`(i))
**Problem.** The claim that held-out log-loss picks "with probability tending to one ... a grid value whose selected hypothesis has least risk" needs each grid value to have a unique population minimizer. The round-2 re-verification of T5 Thm 4.3(i) said it is "essentially correct when each grid c has a unique population minimizer". Without that, $\hat h_c$ can alternate between tied minimizers with different risks, because Lemma `empirical` recovers only a unique minimizer with a gap. The hypothesis is still absent.

**Fix.** Insert "and with a unique population minimizer at each grid value" after "in the computable version with a noise floor". Optionally add: "(if some grid value lies exactly at a hull breakpoint, the selected hypothesis there may alternate between co-minimizers of different risk)."

### Issue 6 — major — `existence.tex` line 292 (`def:existence:truecontext`, clause (iii))
**Problem.** Clause (iii) says "that bridge is sound: whenever $c$ establishes $\varphi$ and $\sigma$ holds in the actual world, so does $\varepsilon$". Given $\Gamma$, the canonical state of $c$ and the actual world are fixed objects, so "whenever" ranges over a single case. Under (i) and (ii), (iii) is then equivalent to "$\varepsilon$ is true in the actual world", and "true enough" collapses to "$\varphi$ is derivable in $c$, some bridge to $\varepsilon$ exists, and $\varepsilon$ is true". It no longer expresses bridge soundness, the world-relative property the next paragraph says must be certified. The round-2 re-verification flagged this ("clause (iii) is now degenerate"), and it was not repaired in T6 or in the paper.

**Fix.** Replace (iii) with:

> "(iii) that bridge is \emph{sound} in the sense of \Cref{def:physics:calculus}: every instance of it preserves truth at every world $w\in W_\rho$ admitted by the background, i.e.\ whenever $c$ establishes $\varphi$ and $\sigma$ holds at $w$, $\varepsilon$ holds at $w$ (quantifying only over the actual world would make (iii) equivalent to the truth of $\varepsilon$)."

### Issue 7 — minor — `twotier.tex` line 136 (`lem:twotier:reiter`)
**Problem.** The only tag, `\leanok{Blame.iInter\_maxClean\_eq}`, sits after part (c) and renders as "Lean: Blame.iInter_maxClean_eq". That name is the part-(b) theorem. Part (c) is `existsUnique_minTransversal_iff` and part (a) is `isMaxClean_iff`, as the next paragraph and `app-lean.tex` line 68 say.

**Fix.** Replace the tag with `\hfill\leanok{Blame.isMaxClean\_iff}\ \leanok{Blame.iInter\_maxClean\_eq}\ \leanok{Blame.existsUnique\_minTransversal\_iff}`, placed after the whole lemma.

### Issue 8 — minor — `twotier.tex` line 397
**Problem.** "dense linear orders" is listed as a complete theory. Only the theory of dense linear orders *without endpoints* (or with a fixed choice of endpoints) is complete. Plain DLO is not complete, and Lemma `twotier:complete` uses completeness of $T$.

**Fix.** Replace "or dense linear orders" with "or dense linear orders without endpoints". Make the same change in `app-twotier.tex` and wherever "DLO" is called complete.

### Issue 9 — minor — `twotier.tex` line 414 (Arithmetic setting)
**Problem.** "(the logic can be learned first, at the propositional level, by \Cref{cor:twotier:cpc})" suggests that the trusted first-order logic can be learned first. Only its propositional fragment is covered. The quantifier rules are not first-order patterns, and the paper says so itself at line 410 ($\forall$E's lgg is over-general).

**Fix.** Replace with "(its propositional fragment can be learned first by \Cref{cor:twotier:cpc}; the quantifier rules are not first-order patterns and must be trusted, \Cref{cor:twotier:decidable})".

### Issue 10 — minor — `app-twotier.tex` line 247 (proof of `thm:twotier:arith`(b)), and `twotier.tex` line 420
**Problem.** The proof ends "Hence ... $\tau\in F_{\mathrm{res}}$, and by \Cref{thm:twotier:main}(iii) $\tau\in A$ at every depth". Part (iii) gives only $A\subseteq\Sigma^*\cup\Fres d$, not $\tau\in A$. A residual fallacy can still be withheld in the fallback if it lies in a minimal conflict with other fallacies. "Asserted forever" holds because the practice is $\PA\cup\{\tau\}$ and is clean at every depth, so the first oracle call returns NONE. The statement does not say that the practice is exactly $\PA\cup\{\tau\}$.

**Fix.** In `twotier.tex` line 420, write "For the practice $\Sigma^P=\PA\cup\{\tau\}$ with $\tau=(\step\neg\Con(\PA))$ (so $\Sigma^*=\PA$, $F=\{\tau\}$) ...". In `app-twotier.tex`, replace "and by \Cref{thm:twotier:main}(iii) $\tau\in A$ at every depth" with "and since $\Sigma^P=\Sigma^*\cup\{\tau\}$ is clean at every depth, the first call $\Refut_d(\Sigma^P)$ returns NONE at every $d$, so $A=\Sigma^P\ni\tau$ at every depth (given $\hat P=\Sigma^P$)".

### Issue 11 — minor — `twotier.tex` line 246 (Reading after the main theorem) and line 462
**Problem.** "It identifies the target calculus exactly, modulo a residue" leaves out the collateral. In the fallback, $A$ misses $\Coll_d(B_0)$, and by `thm:twotier:blame`(b) this loss is forced at stable depth. Line 462's "the resulting checker cannot be fooled by any prover" leaves out the residue. Theorem (i) gives soundness only relative to $\Rstar\cup R_{\Fres d}$; in arithmetic, $\neg\Con(\PA)$ is accepted.

**Fix.** Line 246: "It identifies the target calculus exactly when blame is localized (no descent blocked, or (SB$_d$)), and otherwise up to the collateral $\Coll_d(B_0)$, which every sound learner must give up at stable depth (\Cref{thm:twotier:blame}(b)); in both cases modulo a residue that no refutational channel at depth $d$ can see." Line 462: "... the resulting checker cannot be fooled by any prover beyond the depth-$d$ residue $\Fres d$ (\Cref{thm:twotier:main}(i))."

### Issue 12 — minor — `twotier.tex` line 46 ("Depth, honestly") and `abstract.tex` line 15
**Problem.** The list of round-2 repairs "checked by their author and by computation, not by a further independent referee" is incomplete. Two further round-2 repairs had no independent check:
* R2-3, the ground-rule convention $\rho_i=c_i=1$. It is load-bearing for the $(1+c)K$ union bound in the $N_1$ formula of `thm:twotier:main`, and for `thm:twotier:arith`(e).
* R2-4, the oracle specification of `cor:twotier:cpc`. The T7 author wrote "The re-verifier should confirm whether this was the intended point".

Separately, the abstract's "Every main result passed adversarial verification" is stronger than what this note admits.

**Fix.** `twotier.tex`: replace the parenthesis with "(assumption (OE) in \Cref{thm:twotier:burnin}, the floor bound in \Cref{thm:twotier:arith}(e), the size convention of \Cref{def:twotier:refutation}, the ground-rule convention $\rho_i=c_i=1$ behind the $N_1$ formula, and the oracle specification of \Cref{cor:twotier:cpc})". `abstract.tex`: replace with "Every main result passed adversarial verification; a few second-round repairs, listed where they occur, were checked only by their author and by computation."

### Issue 13 — minor — `existence.tex` line 190 ("Scope")
**Problem.** "For any single finite agenda the finitely many rational inequalities defining $\Pi_F$ ... give finitely many counting sequents that characterize coherence." Two parts of this need qualifying. First, $\Pi_F$ is never full-dimensional here, since it lies in $P(\varphi)+P(\varphi^*)=1$. Second, turning its defining (in)equalities into counting sequents uses negation coherence. Counting sequents alone cannot impose $P(\varphi)+P(\varphi^*)\le1$: `thm:existence:definetti` notes that $P\equiv1$ satisfies every valid counting sequent. The round-2 re-verification flagged this sentence as too broad.

**Fix.** Replace with: "For any single finite agenda (a union of complementary pairs) and negation-coherent $P$, the finitely many rational facet inequalities of $\Pi_F$ give finitely many counting sequents that characterize coherence (\Cref{thm:existence:definetti}); ..."

## 3. Points checked and found correct (no action)

* **Lemma `twotier:descent`(d) extraction.** The extracted refutation's judgments are distinct and occur in order; the size bound needs the distinct-judgment convention, which Def `twotier:refutation`(a) now states. The tree-to-sequence compression by least height is valid.
* **Prop `twotier:voting`(b).** The count $(\lvert\Ac\rvert-m')(\lvert F\rvert+1)+m'(\lvert F\rvert+\lvert\Sigma^*\rvert+1)\le\lvert\Ac\rvert(\lvert F\rvert+1)+m\lvert\Sigma^*\rvert$ is right, and the forward rule makes an output step untrusted.
* **Prop `twotier:sandbox`(b).** $\beta^mw(h_0)\le(\tfrac{1+\beta}2)^D$ gives the stated bound.
* **`thm:twotier:blame`(b).** All three facts hold: maximal $d$-clean $M\subseteq B_0$ is admissible at $d\ge d_0$; $\Fres d(M)=\emptyset$ via Lemma `descent`(d); and the witness transfers via (F2).
* **`thm:twotier:blame`(c) and the depth-non-monotonicity example.** The sizes 9, 13 and 29 recompute by hand. With no world, every refutation on $A_1$ ends at an MP step with the underived premise $p$, so it is blocked.
* **Hilbert four-step $\{K,\mathrm{AC}\}$ refutation.** The instances check, and the descent is blocked.
* **`cor:simplicity:shapes`.** The Legendre-duality band inequalities follow from $\lvert\Phi-\Psi\rvert\le cC'+\epsilon$.
* **`thm:simplicity:idealized`.** The repaired clause (b) and the implied forms, with $1/\omega(2)=2.4094<2.41$, are right.
* **`prop:simplicity:guard`.** The vertex condition is $\rho_\sigma>\rho_G$.
* **Language relativity (d6).** The Kraft construction is valid.
* **`prop:existence:closed`, `thm:existence:gaifman` and `thm:existence:leibniz`.** Countable additivity on clopens via compactness, and the push-forward of congruences along a surjection, are both right.
* **`ex:existence:residue`(i).** $\langle\mathbf H_3,\{1\}\rangle$ is reduced, and $T$ is a non-maximal point.
* **Lean tags in `simplicity.tex` (`NoAdaptation.*`, `RateThreshold.*`) and the `Post.*` tag in `twotier.tex`.** All are present and sorry-free. Their statements match the claimed scope: lower bound only for `thm:simplicity:pricing`, finite classes for the hull lemma, and the separable case only for `thm:simplicity:blind`.
