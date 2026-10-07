# Review: mathematical and empirical correctness of §6 (many.tex, app-many.tex) and §7 (experiments.tex, app-experiments.tex)

Lens: theorem statements against `research/tracks/untagged/notes-final.md`, `research/tracks/single/notes-final.md` §10 and
`research/tracks/experiments/notes-final.md` (+ referee reports); appendix proofs line by line; every number in §7 and its
appendix against `code/results/*.md` and `code/experiments/recheck/*.out`. Scripts written for this review are in
`research/paper-review/scratch/` (`e1_se.py`, `e6_dtf_vs_dt.py`, `e9_survivors.py`, `skel.py`, `share_cex.py`).

## Summary

One fatal error (Prop E4-share, a counterexample computed with the implementation); the rest are major and minor.
I re-derived the pigeonhole theorem, the split/threshold theorem, slot accounting and the PA
corollary (c = 4 / c = 7, the four-slot criterion), the DTRC theorem (i)-(v), the residue theorem and the fragmentation
example, the ambiguity proposition, the two-point lemma, Prop 5.6 and Prop 5.13, the MRDP depth-impossibility proof
(facts 1-6 and the Sigma_1 reduction), the head-class propositions (Steps 0-4, closed form), the 2-SAT algorithm, both
coNP-hardness reductions (k-colouring; set cover), the NP-hardness of the refutation test (CNF-SAT; I re-checked which
n_C are instances of which T_A), the MDL propositions, the normal-form proposition, oracle soundness, Thm E4, the
mixture case table A-E, Prop E9(a),(b) (the writer's added hypothesis "some motive uses its variable" is correct and
necessary) and q_F. They hold. Every number in §7/app checked against the results files matches, except the items below.

Main problems:
* §6 numbers Q's axioms differently from §2 and §7 (and once uses a third numbering).
* §6 counts "eight root specializations" of T_Ind, but the paper's L_A contains `<` (nine).
* Prop E4-share silently assumes that every target owns a phase-1 cluster; with three valid PA targets and four data
  that satisfy all its hypotheses, DTRC+share is not exact for a target whose membership-labelled data contain an anchor.
* E6's "8/8 from three … reproduces the prior untagged result" holds only because DT°_F lacks f(x); in DT° the result is
  the opposite (verified).
* Three overclaims about what experiments show (Prop E9(b) last sentence, E5 "schemas exact after 5-20 examples",
  "T_Ind exact for every learner") and several wrong small descriptions (skeleton clustering's lumps, E9 survivor count,
  anchor probability, an E2 exhibit taken from v1 output).

## Issues

### MAJOR 1 — many.tex / app-many.tex: Q1–Q7 numbered differently from §2 and §7
*Location:* many.tex cor:many:paslots ("Q3--Q6 share $z_0=z_1$; Q1, Q2, Q7 stay alone", "for Q2 and Q7"), many.tex
after prop:many:forall ("numeral instances of Q3--Q5"), app-many.tex proof of cor:many:paslots, tab:many:pacross.
*Problem:* setting.tex fixes Q3 = ∀x(¬x=0→∃y x=Sy), Q4 = x+0=x, Q5 = x+Sy=S(x+y), Q6 = x·0=0, Q7 = x·Sy=x·y+x, and §7
uses it ("Q4 is the datum ∀x(x+0=x)", "Q4 and Q6 absorbed", case B "Q4–Q6 and Q5–Q7"). §6 follows the untagged record:
its Q3 = p+0=p, Q4 = p+Sp'=…, Q5 = p·0=0, Q6 = p·Sp'=…, Q7 = ¬p=0→∃y p=Sy. A reader comparing §6 and §7 (e.g. "Q3–Q4:
p+z0=z1" vs "Q4–Q6: F-slot") gets contradictory facts. (The univ writer flagged this; it is still in the file.)
*Fix:* renumber §6 to §2's order (old→new: Q3→Q4, Q4→Q5, Q5→Q6, Q6→Q7, Q7→Q3):
- many.tex cor:many:paslots list: "($\neg Sp=0$; $Sp=Sp'\to p=p'$; $\neg p=0\to\exists y\,p=Sy$; $p+0=p$; $p+Sp'=S(p+p')$; $p\cdot0=0$; $p\cdot Sp'=p\cdot p'+p$)"; "is $F_0$, or $F_0\to F_1$ for Q2 and Q7" → "lies above $F_0$, or above $F_0\to F_1$ for Q2 and Q3"; "(Q3--Q6 share $z_0=z_1$; Q1, Q2, Q7 stay alone)" → "(Q4--Q7 share $z_0=z_1$; Q1, Q2, Q3 stay alone)".
- many.tex: "numeral instances of Q3--Q5" → "numeral instances of Q4--Q6".
- app-many.tex proof: "Q2 and Q7 have root" → "Q2 and Q3 have root"; "two of Q1, Q2, Q7, or one of them and one of Q3--Q6" → "two of Q1, Q2, Q3, or one of them and one of Q4--Q7"; "for Q2--Q7" → "for Q2--Q3"; "So Q1, Q2 and Q7 need a slot each and Q3--Q6 at least one; $z_0=z_1$ covers Q3--Q6" → "So Q1, Q2 and Q3 need a slot each and Q4--Q7 at least one; $z_0=z_1$ covers Q4--Q7"; "Q3 and Q4 have the lgg" → "Q4 and Q5 have the lgg"; "Q5 and Q6 have $p\cdot z_0=z_1$" → "Q6 and Q7 have $p\cdot z_0=z_1$"; "pairs among Q3--Q6 … so Q3--Q6 need a slot each" → "pairs among Q4--Q7 … so Q4--Q7 need a slot each"; "the cover \{Q1, Q2, Q7, $z_0=z_1$\}" → "the cover \{Q1, Q2, Q3, $z_0=z_1$\}".
- tab:many:pacross rows: "different roots (Q1--Q4 etc.)"; "Q2--Q3, Q2--Ind, Q3--Ind"; "Q4--Q6, Q4--Q7, Q5--Q6, Q5--Q7"; "Q4--Q5 & $p+z_0=z_1$"; "Q6--Q7 & $p\cdot z_0=z_1$". Add to the caption: "Numbering as in \cref{sec:setting}."

### MAJOR 2 — "eight root specializations" ignores `<` in L_A
*Location:* many.tex rem:many:numerals ("$T_{\Ind}$ with $m\ge8$, where the eight root specializations already cover
$\inst(T_{\Ind})$"); app-many.tex cor:many:failure examples ("$f\in\{=,\neg,\wedge,\vee,\to,\leftrightarrow,\forall,\exists\}$");
app-many.tex paragraph after the corollary ("vacuous for $T_{\Ind}$ at $k\ge8$, because the eight root specializations
cover every induction instance").
*Problem:* setting.tex fixes $L_A=\{0,S,+,\cdot,=,<\}$. An induction instance whose motive has root `<` (e.g. Ind(x<Sx))
lies in none of the eight listed specializations, so the claims "cover inst(T_Ind)" / "vacuous at k ≥ 8" are false in
the paper's language. The untagged prototype's language has no `<`, which is where "eight" comes from.
*Fix:* either state in sec:many:setting "In this section (and in the untagged prototype) arithmetic is over
$\{0,S,+,\cdot,=\}$", or replace by nine: "$f\in\{=,<,\neg,\wedge,\vee,\to,\leftrightarrow,\forall,\exists\}$", "$T_{\Ind}$
with $m\ge9$, where the nine root specializations already cover $\inst(T_{\Ind})$", "vacuous for $T_{\Ind}$ at $k\ge9$,
because the nine root specializations …".

### FATAL 1 — experiments.tex prop:exp:share: "the cluster of $T_l$" need not exist; the conclusion fails
*Location:* prop:exp:share ("after the sharing pass the cluster of $T_l$ is $C^+=D\cap\inst(T_l)$, in any order; and
$\Acc(C^+)\subseteq\inst(T_l)$, with equality whenever $C^+$ contains an anchor of $T_l$"), its proof in
app-experiments.tex ("Let $C'$ be the growing cluster, initially the phase-one cluster $C$ with $l(C)=l$"), and E3's
"as \cref{prop:exp:share} predicts".
*Problem:* the proof shows only that each phase-1 cluster C grows to D∩inst(T_{l(C)}). Nothing guarantees that every
target labels a phase-1 cluster, and then the target can lose exactness although its membership-labelled data contain an
anchor. Counterexample satisfying (T), (R), (S⁺), (P), computed with the implementation (`scratch/share_cex.py`): valid
targets U_add0 = z+0=z, U_0add = 0+z=z, T₃ = 1+z=Sz; D = {0+0=0, 0+2=2, 1+0=1, 1+1=2}. Every set lying in no single
instance set contains a cross pair with a false minimal template (0+0=0/1+1=2: z+z=w; 0+2=2/1+0=1: z₀+z₁=Sz₂;
0+2=2/1+1=2: z₀+Sz₁=2), so (S⁺) holds for an ideal refuter. The merge order (largest common prefix first) builds
{1+0=1, 1+1=2} (only in inst(T₃)) and {0+0=0, 0+2=2} (only in inst(U_0add)); (P) holds; the sharing pass adds nothing.
U_add0 owns no cluster, and DTRC+share rejects 2+0=2 and 3+0=3, while the membership-labelled tagged learner sees
{0+0=0, 1+0=1}, an anchor (Min = {z+0=z}), and is exact. So the record's "DTRC+share is exact whenever the tagged learner
with membership labels is" is false even for anchor-based exactness, and the paper's (ii)/(iii), read for every target,
are false. (Nested targets, e.g. U_add00 ⊆ U_add0 in E4(a), also own no cluster, though there the union stays exact.)
*Fix:* replace the conclusion of prop:exp:share by: "Then distinct phase-1 clusters have distinct labels; after the
sharing pass each phase-1 cluster $C$, with $l:=l(C)$, has become $C^+=D\cap\inst(T_l)$, in any order; and
$\Acc(C^+)\subseteq\inst(T_l)$, with equality whenever $C^+$ contains an anchor of $T_l$. Under \textup{(H-ref)}
$\Acc(C^+)$ is the acceptance set of the tagged learner with membership labels for $T_l$. A target that labels no
phase-1 cluster gets no cluster of its own and may be learned incompletely even when its membership-labelled data contain
an anchor (\cref{app:exp:dtrc})." In the proof write "For each phase-1 cluster $C$, with $l:=l(C)$, let $C'$ be the
growing cluster, initially $C$." Add the counterexample after the proof. In E3's Reading replace "as
\cref{prop:exp:share} predicts" by "consistent with \cref{prop:exp:share} (here every target with data labels a phase-1
cluster)".

### MAJOR 4 — experiments.tex E6: "8/8 from three … This reproduces the prior untagged result" is a DT°_F artifact
*Location:* §E6/E7 paragraph: "$k=9$ accepts $0/8$ from two induction instances … and $8/8$ from three. … This reproduces
the prior untagged result (\cref{sec:many})".
*Problem:* one of the two three-instance runs uses motives x=x, ¬x=0, x+0=x. The 2-block split
{Ind(x=x), Ind(x+0=x)} | {Ind(¬x=0)} is root-homogeneous in its first block, hence not a DT° anchor (§3/§5 anchor
theorem (R)+(N); §6 slot accounting). Computed (`scratch/e6_dtf_vs_dt.py`): the DT° template
(f(0)=0 ∧ ∀x(f(x)=x → f(Sx)=Sx)) → ∀x f(x)=x covers both data, has only true instances (so avoids every sound negative)
and misses the query Ind(x·0=0); so the DT° k=9 learner (and the prior/§6 theory) rejects it. In DT°_F the pair has
Min = {T_Ind, (f₀=0 ∧ ∀x(P(x)→P(Sx)))→∀xP(x)}, the second refuted, so the block is an anchor only relative to the
refutation negatives and only because f(x) is not in DT°_F. The run with third motive ∃y.x<y does agree with the theory.
*Fix:* replace the last two sentences by: "… and $8/8$ from three. With third motive $\exists y\,x<y$ this agrees with the
slot accounting of \cref{sec:many} (every 2-block split has an anchor block). With third motive $x+0=x$ it does not:
$\{\Ind(x=x),\Ind(x+0=x)\}$ is root-homogeneous, and the $\DT$ template
$(f(0)=0\wedge\forall x(f(x)=x\to f(Sx)=Sx))\to\forall x\,f(x)=x$ covers it, has only true instances, and misses
held-out queries such as $\Ind(x\cdot0=0)$; $\DTF$ lacks this
template, so here the implemented class accepts more than $\DT$ would. No false non-instance was accepted. The other rows
reproduce the prior untagged result \src{experiments E6; prior pa-untagged}."

### MAJOR 5 — experiments.tex prop:exp:hard(b): "Other merges of this pair are valid"
*Location:* last sentence of prop:exp:hard(b).
*Problem:* as a statement it says every other EInd/EInd2 merge is valid, then "and some false ones are refuted only at
budget 400" contradicts it. The record (Prop E9(b)) says merges *can* be valid (EInd(x=x)/EInd2(x=x)) and that the case
"EInd motive begins with ∀z∈y" gives a false template.
*Fix:* "Some other merges of this pair are valid (e.g.\ $\EInd(x=x)$ with $\mathrm{EInd2}(x=x)$), and some false ones are
refuted only at budget $400$."

### MAJOR 6 — experiments.tex E5: "the schemas are exact after 5–20 examples"
*Location:* E5 paragraph, last sentence.
*Problem:* in §7 "schema targets" are T_Ind and the three instance schemas (tab:exp:e3 caption). In e5_curves.md the
instance schemas are much slower: U_0add first stays exact at >120 in four of five DTRC streams (numerals), U_add0 at
120/>120. The record's statement is "(Ind, Sep, Rep, EInd)".
*Fix:* "… the schemas $T_{\Ind}$, Separation, Replacement and $\in$-induction are exact after $5$--$20$ examples, the
instance schemas only after their $0$-instance appears (for \DTRC{} on $U_{\mathrm{0add}}$, beyond $120$ examples in four
of five numeral streams)."

### MINOR 1 — app-many.tex K₀ paragraph: "the descent through Q3 is unblocked once Q3 is designated"
*Problem:* this is the prior record's numbering (prior raw-impossibility B5(d): Q3 = ∀x∀y(x+Sy=S(x+y))). In §6's own
numbering that axiom is Q4, in §2's Q5; §6's Q3 is p+0=p, which plays no role in the descent.
*Fix:* "(a derivation found in the prior work: the descent through $\forall x\forall y\,(x+Sy=S(x+y))$, Q5, is unblocked
once Q5 is designated)."

### MINOR 2 — many.tex rem:many:numerals: "spare slots", missing hypotheses
*Problem:* (i) "with $m\ge h$ spare slots": m = k−k'+1 is the number of slots available to the target; spare slots are
m−1. (ii) "numeral-only data never make … accept ∀xφ with one spare slot" needs φ(a) to lie in no other target's instance
set (thm:many:splits). (iii) "exact threshold is known for m ≤ h" needs (H2),(H3) of prop:many:onevar.
*Fix:* "So once $m\ge h$ (i.e.\ at least $h-1$ spare slots) the ``failure family'' covers everything." … "For
quantifier-free, parameter-free $\varphi$, under the hypotheses of \cref{prop:many:onevar}, the exact threshold is known
…; in particular \emph{numeral-only data never make the cautious $k$-union learner accept $\forall x\varphi$ with one spare
slot} when $\varphi(a)$ lies in no other target's instance set: …".

### MINOR 3 — many.tex prop:many:forall(e) and the paragraph after prop:many:qf
*Problem:* "R-Δ₀ does so for quantifier-free φ … but not for quantified φ" overgeneralizes (it fails for some quantified
φ, e.g. the wrong-base sentence; for others, e.g. bounded or Σ₁ ones, it succeeds). "that is truth-sound in ℕ for
quantifier-free φ with R-Δ₀" holds only at unbounded depth (at depth d, false universals with large counterexamples are
accepted, as (e) itself says).
*Fix:* "… but not for every quantified $\varphi$." and "that is truth-sound in $\N$ for quantifier-free $\varphi$ with
R-$\Delta_0$ in the limit of unbounded depth (at a fixed depth only relative to $\Res_d$), and otherwise …".

### MINOR 4 — many.tex ZF paragraph and summary: sampled results stated as universal
*Problem:* "All 36 cross pairs have a unique minimal covering template, refuted by …" is computed on one sampled instance
per schema (record u4; app ex:many:zfcross says so). For other instances the template can differ (e.g. Rep–EInd with an
EInd motive whose root is ∃ gives (∀x(F₀(x)→∃yF₁(x,y)))→F₂, still refutable). The summary/intro "PA, ZF and ZFC are
separated at small depth" is proved only for Q1–Q7 + T_Ind; for ZF/ZFC it is verified on sampled pairs and on every
run's data.
*Fix:* "All 36 cross pairs (one sampled instance per schema) have a unique minimal covering template …"; in the summary:
"… and PA is separated at small depth (proved for Q1–Q7 and $T_{\Ind}$), ZF and ZFC on every sampled pair and every run
(\cref{sec:exp} proves pairwise separation for its $\forall$-closed forms)."

### MINOR 5 — many.tex end of "Where separation fails": "a budget effect of the same type"
*Problem:* the preceding text is about the *permanent* residue; q_F of §7 is refuted by the oracle and by DTRC at budget
2000, i.e. it is a finite-depth residue (Res_d).
*Fix:* "\Cref{sec:exp} reports a finite-budget effect (a residue in $\Res_d$, not a permanent one): …".

### MINOR 6 — many.tex thm:many:dtrc(iv): "the failure probability of the tagged learner"
*Problem:* the appositive is attached to the sum Σ_i Pr[D_i has no anchor], which is a union bound on that probability.
*Fix:* "$\Pr[\Acc_d\neq\manyRstar]\le\Pr[\text{some }D_i\text{ contains no anchor}]\le\sum_i\Pr[D_i\text{ contains no
anchor}]$; the middle term is the failure probability of the tagged learner, bounded explicitly in \cref{sec:single}."

### MINOR 7 — experiments.tex anchor probability for numerals
*Location:* prop:exp:numerals ("numerals uniform in $0..7$ form an anchor iff they include $0$") and the E3 Reading ("$n$
numerals form an anchor with probability $1-(7/8)^n$").
*Problem:* by the proposition itself, n numerals are an anchor iff not all roots are equal, i.e. they include 0 *and* a
nonzero numeral; the probability is 1−(7/8)^n−(1/8)^n (e.g. n=4: 0.4136 vs 0.4138).
*Fix:* "form an anchor iff they include $0$ and a nonzero numeral"; "with probability $1-(7/8)^n-(1/8)^n$".

### MINOR 8 — experiments.tex E9: "The one survivor in E9 is false but is refuted only at budget 400"
*Problem:* tab:exp:e9 shows 1 (pairs) / 2 (sets) distinct unrefuted ZF-hard templates. The second (sets) survivor is
(∀x(∀y∈x∀z∈y P₀(z) → P₁(x))) → ∀xP₁(x). Computed (`scratch/e9_survivors.py`): both are unrefuted at 80 and refuted at
400 (one-hot pass, witness (∀x(∀y∈x∀z∈y⊥ → ¬x=w₀)) → ∀x¬x=w₀).
*Fix:* "The surviving templates in E9 (one in the pairs protocol, two in the sets protocol, all EInd/EInd2) are false and
are refuted at budget $400$."

### MINOR 9 — experiments.tex E3: "$T_{\Ind}$ is exact for every learner in every seed"
*Problem:* false for the pattern-lgg baseline in the same table, which is never exact on induction (E2: 0/30 at every N;
prior C9).
*Fix:* "$T_{\Ind}$ is exact for \DTRC, \DTRC+share and both tagged learners in every seed (the pattern $\lgg$ never is)".

### MINOR 10 — experiments.tex E3 Reading: what skeleton clustering lumps
*Problem:* "unsound on PA (it lumps Q4 and Q6 into ∀xP(x))". Per-target exactness in results/e3_mix.json and a re-run
(`scratch/skel.py`): the axioms lost are Q5 and Q7, lumped into ∀x∀yP(x,y) (numerals seeds 0, 1, 4; mixed seeds 0–4);
Q4 and Q6 are lumped into ∀xP(x) only in mixed seed 0; in numerals seed 2 it instead lumps U_add0 and U_0add data into
z₀+z₁=SSz₂. The refuted exhibit in e3_mix.md is ∀x∀y x<2, an instance of ∀x∀yP(x,y).
*Fix:* "unsound on PA (it lumps Q5 and Q7 into $\forall x\forall y\,P(x,y)$, in one run also Q4 and Q6 into $\forall
x\,P(x)$, and data of $U_{\mathrm{add0}}$ and $U_{\mathrm{0add}}$ into templates such as $z_0+z_1=SSz_2$)".

### MINOR 11 — experiments.tex tab:exp:e2 caption: "their soundness fails (text)"
*Problem:* the text (and E2 probes, 0/182) says first-order lggs are sound on ∈-induction in de Bruijn indices.
*Fix:* "their soundness fails except on $\in$-induction in de Bruijn indices (text)".

### MINOR 12 — experiments.tex: "The ZF schemas … are learned from 2–3 instances"
*Problem:* Replacement is exact in 23/30 runs at N=2 and 24/30 at N=3, 30/30 only at N=8 (Sep 27/30 and EInd 29/30 at N=3).
*Fix:* "… are learned in most runs from $2$--$3$ instances (in every run by $N=8$) …".

### MINOR 13 — app-experiments.tex E2 exhibit for ∈-induction (named) is from the first record's run
*Problem:* "(∀x(∀y(y∈x→y∈w₀)→¬x∈w₀))→∀x¬x∈w₀" appears in code/results_v1/e2_schemas.md; the current
code/results/e2_schemas.md (to which the paragraph points) lists (∀x(∀y(y∈x→x=y)→¬x∈w₀))→∀x¬x∈w₀ (also false at
w₀={{∅}}). The other three exhibits match the v2 file.
*Fix:* replace by "$\in$-induction, named, $(\forall x(\forall y(y\in x\to x=y)\to\neg x\in w_0))\to\forall x\,\neg x\in
w_0$, false with $w_0=\{\{\emptyset\}\}$ (the premise only says $\emptyset\notin w_0$)".

### MINOR 14 — E0b wording (experiments.tex and app-experiments.tex)
*Problem:* (i) app: "differs from the literal one on 38/200 (PA) and 72/200 (ZF) parameter-free data sets" — these data
sets carry parameters (as the sentence itself says); they are generated from a parameter-free T*. (ii) experiments.tex:
"the literal one failed exactly when the generating template had a rigid parameter" — it failed in 17/200 and 36/200 of
those data sets, never otherwise.
*Fix:* (i) "on $38/200$ (PA) and $72/200$ (ZF) data sets generated from a parameter-free $T^*$"; (ii) "the literal one
failed only when the generating template had a rigid parameter ($17/200$ PA, $36/200$ ZF)".

### MINOR 15 — experiments.tex: "This is \DTRC{} of \cref{sec:many} with the class $\DTF$, a fixed merge order and a budgeted refuter."
*Problem:* the implementation also (a) inherits failed pairs (exact only for an ideal refuter, prop:exp:mono(a); a
heuristic for the budgeted one), (b) sets Acc(C)=C when all members of Min_F(C) are refuted (§6 uses ∅), (c) discards
refuted data, (d) optionally shares data.
*Fix:* append: "It differs in four details: failed pairs are inherited (exact for an ideal refuter by
\cref{prop:exp:mono}(a)); refuted data are discarded; a cluster all of whose minimal templates are refuted accepts its
data (\cref{sec:many}: nothing); and the sharing pass is optional."

### MINOR 16 — experiments.tex after prop:exp:budget: "So a budgeted refuter harms \DTRC{} only through clustering"
*Problem:* true for soundness; fewer refutations also cost exactness within a pure cluster (prop:exp:budget: more
refutations enlarge Acc(C); E2 shows +refutation exact 27/30 vs 25/30 on induction at N=2).
*Fix:* "So a budgeted refuter harms the soundness of \DTRC{} only through clustering …".

### MINOR 17 — experiments.tex "In brief": "for these mixtures we prove refutation separation"
*Problem:* proved (cor:exp:mixsep) for an ideal refuter; for the implemented budgeted refuter separation is the computed
E9 result.
*Fix:* "for these mixtures we prove refutation separation for an ideal refuter, and the implemented refuter achieved it
on every sampled merge".

### MINOR 18 — experiments.tex E4(b): "ZF: 6 mistakes"
*Problem:* `datasets.zf_mistakes(rng, 6)` cycles sep_capture, eind_wrong, naive; the complement-comprehension sentence is
the same both times, so there are 5 distinct mistake sentences (e4_stress.md fate counts sum to 5 per ZF run).
*Fix:* "ZF: $6$ mistakes ($5$ distinct; …)".

## Checks that passed (numbers)
E0 (48 sets, 3703 / 2515 templates), E0b table (all 8 rows), E1 (3.27/3.25, 8.42/8.11, z = 1.85 with the sample SD;
2000/2000 agreement), E2 table and probe counts (927 = 98+134+130+157+80+120+85+123; 182; 224/229, 58; 213/220, 46), E3
table and per-target rows, ZF-mix numbers and timings (≤ 0.78 s PA, ≤ 5.99 s ZF), E4(a)(b)(c) and tab:exp:e4, q_F
(re-derived by hand; F1 exhibit YES at 80/400, no at 2000 in both regimes; r15), E5 means and first-exact N's, E6 table,
E7 table, E9 table (2200/2200 … 432 431/430, 14/15, 1/2), E9b (0/12 vs 10/12), E10 (9100 pairs), recheck (2197; 413 +
179; 3000 + 600; 39/600, 292/600), 43 tests, 593 s. §6 numbers (24/24; 2000/2000, 60/60, 254/254, 2509/2509; 68 / 49; 147,
201, 175; 22 + 14 = 36; 598; 180/180; 0/30; 12; 467/371/348; 614/294/428; 81/91; 999; 6258; 63+102+98, 164+131+147; 104 =
91 + 13; MDL table; 5,918; 118,818; 15,220; 12 graphs; 25 set systems; 360/360; 3000 + 1206) agree with the untagged and
single records.
