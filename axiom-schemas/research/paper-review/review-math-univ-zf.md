# Review: mathematical correctness of §4 (universal axioms) and §5 (ZF schemas, PA induction)

Lens: mathematical correctness of `paper/sections/universal.tex`, `app-universal.tex`, `zfc.tex`, `app-zfc.tex`,
checked against `research/tracks/cases/{notes-final,referee}.md`, `research/prior/induction/*` (raw-impossibility,
second-order and annotated notes and referee reports), `research/tracks/untagged/notes-final.md` (Lemma 5.5, Props 5.6,
5.13), `research/tracks/single/notes-final.md` (Thm B, Cor D.1–D.3), `research/tracks/experiments/notes-final.md`, and
`code/results/e1_universal.md`, `e2_schemas.md`. Writers' notes read.

Scratch scripts (all run with `python3 -I`, in `research/paper-review/scratch/`):
- `univzf_qmodel.py`: independent check of the model of Q (Ex. univ:q) on {0..60} ∪ {a,b}: Q1–Q7 hold, 0+a = b,
  Sa = a. **No violation.**
- `univzf_debruijn.py`: de Bruijn indices of P's arguments and of the frame atoms of all templates of tab:zf:forms.
  Confirms tab:zf:classify and app:zf:enc; finds the mislabelled index in the proof of thm:zf:nounion(iii) (issue 6).
- `univzf_indeq.py`: IndEq(φ) ↔ Ind(φ) on 6000 random (motive, finite L_A-structure) pairs, 1503 motives binding y,
  385 with Ind false: **0 disagreements**; the universal-closure counterexample P := (x=0 ∨ ¬x=y) checked.
- `univzf_repls_pair.py`: the ReplS counterexample of issue 2 (the candidate is an instance of the computed named lgg).

## Verdict in brief

No invalid proof found. The core theorems (identity lemma and DT anchors for first-order targets; rates; capture
decomposition; Tarski–Vaught characterization; the Q model; Thm E / facing lemma / Thm E′; classification B1/B1α;
deep-leaf impossibility; C3/C3′; prior C3/C4/C6.2/C7/C9; K0 consistency; Sub; IndEq; Metamath guards) were checked line
by line and agree with the records. Four statements are false or overclaim as written (issues 1–4); the rest are local.

## Issues (most severe first)

### 1. [major] universal.tex, §4 overview item (2): "not in … a nonstandard model of PA"
**Problem.** "is truth-safe for all φ in M iff M₀ ≼ M: in ℕ, not in ℝ, V or a nonstandard model of PA." For any model
M of PA, M₀ ≅ ℕ, and M₀ ≼ M iff M ≡ ℕ. So in every nonstandard model of *true arithmetic* (which is a nonstandard model
of PA) the step *is* truth-safe. prop:univ:tv itself says "(i) holds … for every model of true arithmetic", so the
overview contradicts the proposition. (The record's A10.2 has the same loose wording; Ex. A7′ only treats models of
PA + ¬Con(PA).)
**Fix.** Replace "in $\N$, not in $\R$, $V$ or a nonstandard model of $\PA$." by "in $\N$ and in every model of true
arithmetic, but not in $\R$, in $V$, or in a model of $\PA$ that is not elementarily equivalent to $\N$ (e.g.\ a model of
$\PA+\neg\Con(\PA)$, \cref{ex:univ:fail})."

### 2. [major] zfc.tex, prop:zf:false, parenthetical "For ReplS in the named encoding with textbook names there is no such pair; see Prop zf:coll."
**Problem.** Prop C3 (prop:zf:coll) only covers *anchor* data ((R) and N_y). For non-anchor pairs the claim depends on
the guard family, and is false for the family the records use (freshness guards on *formula* metavariables, cases §1;
setting.tex's example fresh(v,A)). Counterexample (checked by `univzf_repls_pair.py`): data ReplS(x∈y), ReplS(y∈A)
(both bodies have root ∈, so (R) fails). The named lgg is
∀A(∀x(x∈A → ∃y(V₀∈V₁ ∧ ∀u(V₂∈V₃ → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ V₀∈V₁))) with term metavariables only, so no
formula-metavariable guard applies. Its instance V₀:=Y, V₁:=y, V₂:=V₃:=u is
∀A(∀x(x∈A → ∃y(Y∈y ∧ ∀u(u∈u → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ Y∈y))), Y free (a parameter) in the antecedent. At
A={∅}, Y=∅ the antecedent holds (y={∅}; no u∈u by Foundation) and the consequent requires y∈Y′∈y, contradicting
Foundation; so the sentence is false and ZF-refutable. If freshness guards are also learned for term metavariables
(fresh(Y,V₀) holds on the data), this instance is excluded and the claim seems true (every guarded instance then has
Y ∉ FV of the tied occurrence-1/3 text, so Collection proves it), but the paper neither says so nor proves it.
**Fix.** Replace the parenthetical by: "(The complete list is in \Cref{app:zf:fofail}. For $\ReplS$ in the named
encoding with textbook names, anchor data give no such instance: the lgg is truth-sound, \Cref{prop:zf:coll}.)" Optionally
add to app:zf:fofail: "Non-anchor pairs can still give false instances when freshness guards are available only for
formula metavariables: from $\ReplS(x\in y)$ and $\ReplS(y\in A)$ the lgg has term metavariables $V_0\in V_1$ at
occurrences 1 and 3, and $V_0:=Y$, $V_1:=y$ gives $y\in Y\wedge Y\in y$ in the consequent."

### 3. [major] zfc.tex, section introduction: "Where it fails, no finite union of first-order schemas covers the schema without a false member (Thm zf:nounion)."
**Problem.** Overclaim. Spelled-out Replacement in the named encoding with textbook names is not a first-order pattern,
yet a single guarded first-order schema (L_S) covers it with only true (ZF-provable) instances (prop:zf:coll; record C2
"that exception is necessary"). The section later says so, but the introduction states the opposite.
**Fix.** "Where it fails, no finite union of guarded first-order schemas covers the schema without a false member
(\Cref{thm:zf:nounion}), with one exception: spelled-out Replacement in the named encoding with textbook names, whose
first-order lgg is a truth-sound over-generalization (\Cref{prop:zf:coll})."

### 4. [major] universal.tex, prop:univ:learner (1): "in (N) and (dB) it also needs nocap whenever some free x_i lies under a binder"
**Problem.** Two errors. (a) "also needs": the closedness guard already excludes every capture instance (closed values
contain no variable; prop:univ:open(c) says the guarded learner "accepts neither φ(p̄) nor any capture instance"), so with
closed(z_i) nocap is never needed in addition. (b) Wrong condition: by prop:univ:capture(b), in (dB) and in (N) with
sentences as data Cap(φ) can be empty although some free x_i lies under a binder (e.g. φ = (x=0 ∧ ∀y(x=y)) in (dB):
the first occurrence is at depth 0, so #0 is ill-formed there). Then no capture guard is needed. The appendix proof of
(1) correctly uses "whenever Cap(φ) ≠ ∅".
**Fix.** Replace the sentence by: "If parameters are admissible values, the cautious single-schema learner over
$\Hk1(\FO)$ or $\Hk1(\DT)$ is sound for it only with a closedness guard. In (N) and (dB), even without parameters, it
must also exclude capture instances whenever $\Cap(\varphi)\neq\emptyset$ (\cref{prop:univ:capture}(b)), by
$\mathrm{nocap}$ or by $\mathrm{closed}$, which implies it; under the $\lambda$ convention this is automatic."

### 5. [minor] universal.tex prop:univ:capture(e), tab:univ:learner row 4, app proof of (e): one parameter datum and k ≥ 2
**Problem.** "A datum at a parameter deletes closed(z_i) but not nocap(z_i), and the accepted set becomes insto(φ)."
The most-specific-guard rule deletes closed(z_i) only for the z_i whose value contains a parameter. For k ≥ 2 a datum
φ(p, 0) leaves closed(z₂), and the accepted set is {φ(t₁,t₂): t₁ capture-free, t₂ closed} ≠ insto(φ).
**Fix.** (e): "A datum whose value at $z_i$ contains a parameter deletes $\mathrm{closed}(z_i)$ but not
$\mathrm{nocap}(z_i)$; once this has happened for every $i$ (for $k=1$, after one such datum), the accepted set is
$\insto(\varphi)$." Table row 4: "data with a parameter at every $z_i$ (…)". App proof of (e): "…so only
$\mathrm{closed}(z_i)$ is deleted, and once it is deleted for every $i$, $\inst(\sigma_\varphi,\{\mathrm{nocap}(z_i)\}_i)$ is …".

### 6. [minor] app-zfc.tex, proof of thm:zf:nounion (iii), uniqueness
**Problem.** "the slot's atom x∈A reads #1∈#3, while the frame atoms read #0∈#2 (consequent) and #1∈#2 (antecedent)."
The antecedent frame atom x∈A sits under ∀A∀x and reads #0∈#1 (`univzf_debruijn.py`); #1∈#2 is the x∈A atom inside the
*antecedent occurrence's slot*. Uniqueness still holds.
**Fix.** "…reads $\#1\in\#3$, while the frame atoms read $\#0\in\#1$ (antecedent) and $\#0\in\#2$ (consequent), and the
slot atom $x\in A$ of the other occurrences reads $\#1\in\#2$ (antecedent occurrence) and, for $\ReplS$, $\#2\in\#3$
(uniqueness occurrence)."

### 7. [minor] zfc.tex prop:zf:russell(a) and prop:zf:false(iv): Russell's instance needs (R)
**Problem.** "The unguarded lgg of Separation data (either encoding) has Russell's instance." If all bodies have the same
atomic root (e.g. x∈z and z∈x), the lgg is ∀z∃y∀x(x∈y ↔ x∈z ∧ V₁∈V₂) with term metavariables, and ¬x∈y is not an
instance (record D1 assumes the lgg ∀z∃y∀x(x∈y ↔ x∈z ∧ A)).
**Fix.** (a): "If the bodies' main symbols are not all equal, the unguarded lgg of Separation data (either encoding) has
Russell's instance …". (iv): "Without its guard, Separation's lgg on data with \evR{} has Russell's instance".

### 8. [minor] zfc.tex, Conventions: "the cautious verifier over H is then exact, and it is sound before whenever T* is closed in H"
**Problem.** Exactness after an anchor also needs closedness: after an anchor Acc = cl_H(inst T*), which can be strictly
larger (prop:zf:indgen(b): DT_s, 7 ≤ s ≤ 11, accepts a false sentence on every anchor).
**Fix.** "…has $\inst(T)\supseteq\inst(T^*)$. If $T^*$ is closed in $H$ (e.g.\ $T^*\in H$), the cautious verifier over
$H$ is sound on all data from $T^*$ and exact once they contain an anchor; otherwise an anchor makes it accept
$\mathrm{cl}_H(\inst(T^*))\supsetneq\inst(T^*)$ (\Cref{sec:setting}, \Cref{prop:zf:indgen}(b))."

### 9. [minor] app-zfc.tex, Metamath sufficiency: "induction gives X = ℕ"
**Problem.** The claim is that the instances are *derived rules of PA*; the argument as written only shows truth
preservation in ℕ. The record (P9) argues in any model: X is definable, so induction gives X = everything.
**Fix.** "Fix a model $M$ of $\PA$ and a valuation $v$ in $M$ …; $X$ is definable from the parameters of $v$, so
induction in $M$ gives $X=M$. Hence the universal closures of the premises imply that of the conclusion in every model of
$\PA$, i.e.\ the rule is a derived rule of $\PA$."

### 10. [minor] universal.tex prop:univ:learner(3): "It is derivable from the instances only by an ω-rule"
**Problem.** Overstated: for many φ (e.g. logically valid ones, or over PA) ∀x̄φ is first-order derivable; Ex. univ:q
shows non-derivability for one φ over Q.
**Fix.** "(3) In general it is not derivable from the instances in first-order logic, even over $\Q$
(\cref{ex:univ:q}); it is an $\omega$-rule step."

### 11. [minor] universal.tex overview (1) "Rates have exact formulas" and §4 summary "rates have exact formulas"
**Problem.** thm:univ:rates gives exact formulas for k = 1, 2 and only an exponential bound for general k.
**Fix.** "Failure rates have exact formulas for one and two variables and an exponential bound in general
(\cref{thm:univ:rates})"; in the summary: "…two instances suffice, and the failure rates are known exactly for one and
two variables."

### 12. [minor] app-universal.tex lem:univ:identity, prop:univ:dt(a), app intro: "values without bound variables"
**Problem.** For formula sort this literally excludes closed quantified formulas (∀w(w=w)), which the λ convention admits
and which the proof handles (no loose indices, so no shifting). The intended hypothesis is "no free bound variables".
**Fix.** Replace "without bound variables" by "without free bound variables (closed apart from parameters; a formula
value may contain its own binders)" in app-universal intro, lem:univ:identity, the proof of prop:univ:dt(a), and
prop:univ:dt(a) in universal.tex.

### 13. [minor] app-universal.tex, proof of prop:univ:open(c): "a metavariable at or above q"
**Problem.** Metavariables of lgg(D) lie at or below the metavariable positions of σ_φ (all data agree above them), so
"above" never occurs; the case meant is "at q".
**Fix.** "…the hypothesis either has a metavariable at $q$ (metavariables of $\lgg(D)$ lie at or below the metavariable
positions of $\sigma_\varphi$), whose value in $\varphi(\bar p)$ contains a parameter …, or is rigid at $q$ …".

### 14. [minor] zfc.tex after thm:zf:anchor: "the 'shielding' that separates SO from DT … cannot occur"
**Problem.** True for one metavariable only; with several metavariables SO and DT anchors differ even over L∈ (T_A in the
next paragraph, a metavariable with no pattern occurrence choosing different arguments on different data).
**Fix.** "Since $L_\in$ has no function symbols, for one metavariable the ``shielding'' … cannot occur; with several
metavariables $\SO$ and $\DT$ anchors differ even over $L_\in$ (example $T_A$ below)."

### 15. [minor] universal.tex rates paragraph: "while the bound (c) needs N=11 and 13"
**Problem.** Only the exponential form of (c) needs 11 and 13 (ρ = 0.5: 2e^{−N/2}, 5e^{−N/2}); the (1−ρ)^N form of the
same bound needs 8 and 9.
**Fix.** "…while the exponential form $(2k+\binom k2)e^{-N\rho}$ of bound (c) ($\rho=0.5$) needs $N=11$ and $13$ (the
$(1-\rho)^N$ form needs $8$ and $9$)".

## Checked and found correct (no action)

- **Q model** (Ex. univ:q, app:univ:omega): every case of Q5 and Q7 by hand and by script; 0+a=b; Sa=a used correctly in
  prop:univ:refute(d).
- **Tarski–Vaught** (prop:univ:tv): both directions; M₀ is a substructure because L has a constant; the true-arithmetic
  remark is right (and contradicts only the overview, issue 1).
- **Capture** (prop:univ:capture): decomposition, criterion (b) in all three regimes, the examples ∃y¬(y=y) and
  ∃y(y=Sy); guards (e) up to issue 5.
- **Identity lemma and prop:univ:dt(a)** (the writer's generalization to several metavariables, formula sort and
  parameters): proof valid; a coincidence inside another metavariable's value cannot be exploited because the template's
  rigid part lies in C(D). (b), (c) and the binder examples T₁, T₂ checked by hand.
- **Rates** thm:univ:rates (a)–(c): inclusion–exclusion re-derived; independent-component specialization; GW numbers
  for k=1 recomputed (.300, .0354, .00489, .000111), k=2 at N=2 estimated ≈ .5156.
- **E1/E2 numbers** match `e1_universal.md` and `e2_schemas.md` (927 probes = 232+287+200+208).
- **Merge** prop:univ:merge and lem:univ:qf: match untagged Prop 5.6 (corrected) and Prop 5.13.
- **Classification** (thm:zf:classify, tab:zf:classify, prop:zf:alpha, prop:zf:folgg incl. the writer's new proof of the
  all-tied case): all index tuples and depths confirmed by script; d = least depth; guards per entry.
- **False lgg instances** (prop:zf:false, app list items 1–8): each is an instance of the lgg, respects the most specific
  guards, and is false with the stated ZF refutation.
- **No finite union** (lem:zf:deepleaf, thm:zf:nounion (i)–(iv)): every proper prefix on each path handled; uniqueness
  holds (issue 6 is a labelling slip).
- **C3/C3′**, **Thm E**, **facing lemma**, **Thm E′**, separating examples T_A, T_B, **Cor F/F′**, **Thm G**.
- **Induction**: indtwo, indunion (incl. the guard padding), **K₀** (both orientations, termination measures,
  confluence, amalgamation, Δ₀ with <), indpat, indanchor (incl. sizes ≤ 7 of the witnesses), indgen (9 prefixes, 26
  partitions, sizes 8/11/12/14, threshold 12, s*), indso (key fact and substitutions (i)–(v)), Sub (rate formula),
  **IndEq** (a)–(c) incl. the capture counterexample and the parameter-elimination trick, Lean redex capture example,
  Metamath guard characterization (both counterexamples verified by hand; issue 9 only concerns the model).
