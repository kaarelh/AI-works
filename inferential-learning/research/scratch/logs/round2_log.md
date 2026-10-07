
### Round 2

A re-verification of the round-1 repairs found two major and one minor residual issue. I re-checked each one, agreed with all three, and repaired them as below. I also re-read the six round-1 majors against the new changes; that check follows the table. New check script: `two_point_bounds.py` (author, round 2).

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| R2-1 | Thm 5.5: the round-1 statement assumed that escalation answers "follow the practice (§5 conventions)". That convention gives equal laws only for scenarios with the *same* practice, and Thm 5.5's two practices differ. | major | Yes, and it is worse than a proof gap: with practice-following escalation the conclusion is false. Some μ-instance $s_\mu$ lies outside $\mathrm{Sound}(R_{\{\sigma,\tau\}})$. A human with practice $\{\sigma,\tau,\mu\}$ confirms it, and one with practice $\{\sigma,\tau\}$ rejects it, so one escalation separates the scenarios. [computed: `two_point_bounds.py` (C), the cap 0 becomes 1.] | **Fixed.** The statement now assumes **(OE)**: every non-sample input is generated from the history by the same kernel in both scenarios. (OE) is shown to hold for $\mathrm{Ref}_d$ and $W$ (Lemma 2.1(c)), for the fixed prover and red team, for non-escalating learners and for TTL's tier. It is shown to fail for practice-following and target-truthful escalation. The proof is rewritten with the identity $P_1^{\otimes t}\vert_{E_t}=(1-\pi)^tP_2^{\otimes t}$ and a common kernel $K_t$. Tightness is checked by linear programming over all tag sequences: 0 mismatches in 108 cases. The §5 conventions are rewritten, so that the escalation convention is scoped to same-practice results (Props 5.2–5.3, Thms 5.6–5.7). A scope remark on membership queries is added, and §0, §4 Remark 4, §9 weak point 3 and the Reading are qualified. |
| R2-2 | Thm 6.6(e), "what the floor buys": the bound $\ln\frac{1-\delta'}\delta/\ln\frac1{1-\pi}$ is false. In Thm 5.5 the rare tag lives in the scenario where acceptance is unsound; here $\mathrm{Con}(T_{k-1})$ lives in $T_k$, where acceptance is sound. | major | Yes. Counterexample: take $\pi=1/2$, $\delta=10^{-6}$, $\delta'=0.1$. The round-1 bound demands $t\ge19.8$. The learner "accept iff the tag has occurred" is 0-sound under $T_{k-1}$ and accepts with probability 0.9375 at $t=4$ [computed]. | **Fixed by correcting the bound.** The correct mirror-image bound is $\Pr_k(\text{accept at }t)\le1-(1-\delta)(1-\pi)^t$. Hence $t\ge\ln\frac{1-\delta}{\delta'}/\ln\frac1{1-\pi}$ when $\delta+\delta'<1$. It is proved in place and shown tight, both by an explicit learner and by linear programming (0 mismatches in 108 cases). It is still unbounded as $\pi\to0$, so "no uniform bound without the floor" survives. The text explains why the bound scales with $\ln(1/\delta')$, not $\ln(1/\delta)$. (OE) and the reading as calculus-soundness (Con is true) are added, and the proof line of (e) is corrected. The undefined $1/\pi_{\min}$ in the tag bound is replaced by $\lfloor1/(2\Delta)\rfloor$. |
| R2-3 | Lemma 2.5(d) needs size to count distinct judgments, which Def 1.5 did not say. Thm 4.1 Step 1's $(1+c_i)$ count needs T1 Thm 6.3's ground-rule convention, while Def 1.2 cited T1 Thm 5.3, which has $c_i=0$ and leaves $\rho_i$ undefined for ground rules. | minor | Yes, both. | **Fixed.** Def 1.5: a derivation is a sequence (DAG) of distinct judgments, size counts distinct judgments, and tree derivations compress without growing. The computed minimal refutations repeat no judgment, so their numbers (9, 13, 29) are unchanged. The proof of Lemma 2.5(d) now orders the extracted judgments by fixed-point stage and shows that they are distinct. Thm 5.6(c) cites Def 1.5. Def 1.2 now sets $c_i:=1$, $\rho_i:=1$ for ground rules (T1 Thm 6.3), so $c_i\ge1$ for every tag. §3.1, Thm 4.1(iii) and Step 1 cite this one convention. In noisy mode a ground tag gives two events, which are T1 Thm 6.2(b)(i)–(ii). In noise-free mode, T1 Thm 5.3's separate ground-rule term becomes $c_ie^{-N\pi_i\rho_i}$. |

*Consistency of the round-1 majors with the round-2 changes.*
* **Prop 2.4(c).** Unaffected. The schema-level equality and the instance-level superset use neither escalation nor the size convention.
* **Prop 3.2.** Unaffected. It uses Lemma 2.5 only through (c) and the consistency certificate.
* **Prop 5.2(a).** Its admissible targets share the practice, so this is a case where the escalation convention does apply. A sentence in the proof now says so.
* **Thm 5.6.** All scenarios in (a) and (b) share the practice, so the convention applies.
  * (b) uses Lemma 2.5(d), whose size bound now rests on Def 1.5.
  * The sizes 9 and 13 in (c) count distinct judgments, as Def 1.5 now says.
* **Cor 6.5.** Unaffected; it remains conditional on realizability.
* **Thm 6.6(e).** The identification part is unaffected. The ground axioms ($\mathrm{Con}(T_j)$, Q) fall under the Def 1.2 convention. The floor remark is replaced (R2-2), and the applicability of T1 Thm 6.3 rests, as before, on the Sub-encoding.
* **Thm 5.7** (not a round-1 major, but it uses the conventions). It has the same practice in both cases. The proof now notes that practice-following escalation answers are computable, so the reduction is unaffected.

*Items to re-verify after round 2:*
* Def 1.2 (ground-rule convention) and Def 1.5 (derivations and size);
* the proof of Lemma 2.5(d);
* Thm 4.1(iii) and proof Step 1, both modes;
* the §5 standing conventions;
* Thm 5.5: statement with (OE), proof, tightness and the scope remark;
* Thm 6.6(e): the floor remark, its proof line, and the tag-count bound;
* the last bullet of the proof of Thm 5.7;
* `two_point_bounds.py`.
