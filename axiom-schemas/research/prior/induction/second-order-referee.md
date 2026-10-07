# Referee report on Track C (second-order templates for raw induction; SOCL)

Referee C (adversarial). I checked every proof step by hand and re-implemented the machinery from scratch: representation, instantiation, determinate matching, projection/imitation matching, the enumerator, generality, pattern anti-unification and first-order lgg. My code uses de Bruijn **levels**, where the authors use indices, and imports nothing from `so_core`/`so_enum`. The one exception is r6(2), which deliberately runs the authors' enumerator to show what SOCL itself does.

All referee code is in `referee_C/`. Run any script with `python3 run.py <script>`, which sets a large stack. Each script's output sits next to it as a `.out` file.

| script | what it checks | result |
|---|---|---|
| `rc_core.py`, `rc_enum.py`, `rc_pool.py` | library; 52-motive pool with ∨, ∃, ·, internal binders, shielding under binders, 30 random motives | — |
| `r1_matching.py` | C1 | all claims reproduced |
| `r2_anchors.py 14 150` | C3, C7 on 176 new data sets | 0 disagreements (after the T_Θ remark below) |
| `r3_finitary.py` | C8.3, C8.2 | **counterexample: infinitely many minimal DT templates** |
| `r4_threshold.py` | C4, C6.2 | reproduced exactly |
| `r5_pattern_au.py` | C9 | reproduced (914/914 pairs) |
| `r6_socl_nested.py` | SOCL soundness for DT targets | **SOCL as specified is unsound for a DT target with nested arguments** |
| `r7_misc.py` | C5(a) with own lgg, C8.1, C10 | reproduced |
| `r8_crosscount.py` | cross-check of the authors' enumeration counts | identical: 7241 / 11 and 7803 / 26 |

## Verdicts

| # | verdict | one-line reason |
|---|---|---|
| C1 matching | holds | proof correct; uniqueness, 2^k and linear time reproduced independently |
| C2 rigid prefix / enumeration | holds (for SO°, as stated) | but SOCL cites it for DT, where it is incomplete (see Algorithm) |
| C3 DT anchor ⇔ (R)∧(N) | holds | proof checked line by line; 0/176 disagreements on new motives |
| C4 26 generalizations, lgg = T_ind | holds | recounted by hand (9 prefixes: 1+1+1+1+2+1+2+4+13); same size histogram |
| C5 same anchors as Sub-lgg; rates | holds | own first-order lgg: 1326/1326 pairs, 6000/6000 triples |
| C6.1 H-closed lemma | holds | trivial and correct; generalizes lem:imitation:cautious(a) |
| C6.2 threshold s ≥ 12 | holds | s* and s0* accepted iff s ≤ 11; on 5434 random frame sentences, 0 non-instances accepted at s ≥ 12 |
| C7 SO° anchor ⇔ (R)∧(B) | holds | but needs unbounded arity and argument size (see remark) |
| C8.1 DT not unitary | holds | 11 covering templates, minimal = {G1, G2}; w1/w2 separate them |
| C8.2 version space before anchor | holds-with-fix | the counts are for DT° (no nested arguments) within bounds; in DT, {Ind(x=x), Ind(0=x)} has infinitely many minimal templates |
| C8.3 finitary | **false** (for DT as defined) | infinite antichain T_k of minimal covering templates; plausibly true for DT° |
| C9 pattern lgg = T12, unsound | holds | own BKLV-style anti-unifier |
| C10 noise | holds | proof correct; e = 1 example checked (102 trimmed templates, all ≥ T_ind) |
| C11 escalations | unclear | correctly labelled a conjecture; its proof idea relies on finite Min(D), which fails in DT |
| C12 literature / proof assistants | holds-with-fix | Lean/Coq details partly wrong (see C12) |

## Algorithm issues (SOCL)

**A1. The enumeration is incomplete for DT, and SOCL can then be unsound for a target in DT.** The class DT, as defined, allows metavariables inside arguments (e.g. M(F(x)) with F determinate elsewhere). SOCL's steps 3–4 consider only derived fillers M_π(ū) with one fixed, metavariable-free ū for all data. The authors' enumerator `so_enum` likewise enumerates only SO° fillers. Lemma C2 is proved only for SO°, so "complete by the rigid-prefix lemma" does not hold for DT.

Concrete failure (r6, run with the authors' own enumerator):
- Target: T* = Ax(f(x)=f(x)) & (f(f(0)) = f(f(0))). It is in DT, since f(x) is a pattern occurrence.
- Data: D = { Ax(Sx=Sx) & SS0=SS0 , Ax(x+0=x+0) & (0+0)+0=(0+0)+0 }, both in inst(T*).
- SOCL computes Min(D) = { Ax f0(x)=f0(x) & f1=f1 }.
- So SOCL accepts q = Ax(Sx=Sx) & 0=0, which is not in inst(T*). The true DT cautious verifier rejects q, because T* ∈ VS(D).

The general lemma C6.1 is fine. What fails is that SOCL does not compute ∩VS_DT(D). For the induction target nothing breaks, because T_ind ∈ DT° = DT ∩ SO° is enumerated.

*Fix:* take the hypothesis class to be **DT°** (metavariable-free arguments). C2 then gives completeness, and C3, C4, C6.2, C8.1, C9 and C10 hold verbatim, because every template they use is in DT°. Alternatively, extend step 3 to nested derived fillers; but then A2 applies.

**A2. Min(D) can be infinite in DT, so "accept iff q ∈ inst(T) for all T ∈ Min(D)" is not an algorithm there.** See C8.3 below. Within DT_s (bounded size) or DT°, Min(D) is finite. In DT°, derived arguments are forced, because each variable of ȳ_π occurs in the column, by injectivity of substitution.

**A3. Minor points.**
- In DT_s with s = 12 or 13, an anchor gives Min(D) = the minimal frame generalizations of size ≤ s, not {T_ind}. T_ind has size 14. Acc is still Ind, by C6.2, so the linear-time "read P off the conclusion" verifier is still equivalent.
- Before an anchor, SOCL's cost is exponential in general (prefixes × fillers × sharings). The linear bound applies only to verification after the anchor. The authors do not claim otherwise, but the brief answer should say so.

## Per-proposition notes

**C1 (holds).**
- (a) Uniqueness follows from preservation plus one pattern occurrence. The O(|T|·|s|) lazy evaluation is right: every node of s is consumed once, with at most |T| non-consuming jumps between consumptions.
- r1 reproduces the following on my 82-motive pool:
  - T_ind has a unique matcher with P = motive;
  - 2965 random determinate generalizations each have exactly one matcher, counted by full projection/imitation enumeration;
  - T8, T11 and T12 have unique bodies;
  - 2^k matchers for P(0); 8 for (P(0)&B)->C against Ind(0+x=x);
  - nested determinate templates are recovered correctly;
  - matching time is near-linear.
- (b) is correct. The recursion is per position and the subproblems are independent. This is consistent with NP-completeness of general second-order matching, since hardness needs nesting or shared unknowns.
- Wording: in (b), "ground arguments" should be "metavariable-free arguments". They may contain the template's bound variables.

**C2 (holds as stated).**
- My enumerator reproduces the authors' counts exactly: 7241 SO° / 11 DT covering templates for the C8.1 data, and 7803 / 26 for the anchor pair (r8). This is a strong independent check of their c0–c4 machinery.
- The issue is only SOCL's use of C2 for DT (A1).

**C3 (holds).** I re-derived every step.
- Under (R) the skeleton is a frame prefix (C2(a) plus Lemma A(i)).
- No term-valued metavariable can be determinate, since there are no rigid term positions. So all arguments are metavariable-free and nested DT templates are covered too.
- Pattern occurrences are M(x) at W, b, c, d. The ℓ-classes are {a,b,c,d}, {W} and singletons.
- Lemma A(ii)/(iii) forces x, Sx, 0. The pattern-only-at-c case is excluded by St ≠ x and St ≠ 0.
- The witnesses for "only if" are in DT and have size ≤ 7.

r2 checked 176 new data sets: pairs plus 15 triples, including ∨, ∃, ·, motives with internal binders, closed quantified motives and random motives. Results:
- DT-anchor ⟺ (R)∧(N) in every case with (R);
- for every non-(R) set, a determinate witness of size ≤ 7 was found;
- 0 undetermined templates.

**C4, C6.2 (hold).**
- r4 finds exactly 26 determinate covering templates, with the same size histogram as the authors' list.
- s* and s0* are accepted for s ≤ 11 and rejected for s ≥ 12.
- On 5434 random frame sentences:

  | s | accepted | of which non-induction |
  |---|---|---|
  | 7 | 5434 | 5428 |
  | 8–10 | 681 | 675 |
  | 11 | 18 | 12 |
  | ≥ 12 | 6 | 0 |

- T8 ∩ T11 ∩ T12 = Ind on all candidates.

**C5 (holds).**
- (a) follows from lem:setting:recover, whose statement I checked in paper/sections/setting.tex. (D) for each pair reduces to (N) via Lemma A(ii) with 0 ≠ Sx.
- (b) is correct inclusion–exclusion.
- r7(a) uses my own n-ary first-order lgg: 1326/1326 pairs and 6000/6000 triples agree with (R)∧(N).

**C7 (holds), with a caveat on evidence.**
- The proof is correct: unshieldedness pins the hole exactly at q, and T_Θ covers D and misses Ind(x=x).
- However, the characterization needs **unbounded** arity and argument size. In 7 of my non-(B) sets, no bad SO° template of arity ≤ 2 and argument size ≤ 3 exists (size ≤ 14), so within those bounds the set *is* an anchor. Examples: {Ind(Ey.(x+0)*y=0), Ind(SSx=x+S0)}, and pairs with motive Ey.(x+Sx)=y.
- The bad template is T_Θ with arity 3 or larger arguments. I verified it covers and misses on all 38 non-(B) sets.
- So the authors' 351/351 computational agreement (arity ≤ 2) is pool-dependent. Bounded SO° classes have weaker anchor conditions than (B). The statement says "any arity", so the theorem itself stands.

**C8.1 (holds).** Reproduced in r7(b): 11 covering templates, minimal set {G1, G2}, and w1/w2 separate them.

**C8.2 (holds-with-fix).** The counts (8, 2, …) were computed with an enumerator that has no nested arguments and caps argument size at ≤ 2. So they are counts for DT° within bounds, not for DT. For {Ind(x=x), Ind(0=x)}, the DT count is infinite (next item). The qualitative claims hold, by C6.1:
- the minimal set can have more than one element;
- one minimal template is a specialization of T_ind;
- acceptance stays inside Ind.

**C8.3 (false for DT).** Take D = {Ind(x=x), Ind(0=x)} and

    T_k = (0=0 & Ax(f(x)=x -> f^k(Sx)=Sx)) -> Ax f(x)=x,   k = 1, 2, 3, ...

(and similarly U_k with f^k(x) at b).

- *T_k ∈ DT.* f(x) at d is a pattern occurrence.
- *T_k covers D.* Use f = λz.z and f = λz.0; f^k(Sx) is then Sx, resp. 0.
- *Pairwise incomparable, even as instance sets.* The instance with f = λz.z+0 has k copies of "+0" in its c-slot, so it lies in T_k and in no other member of the family.
- *Each T_k is minimal (hand proof).* T_k's rigid skeleton equals C(D). A covering T ≤ T_k has the form T_k[f := λz.β]↓. β[x] must be a single metavariable occurrence g(ū), because the data disagree there. Determinacy forces ū = (z): the only rigid occurrences of g are at the three LHS slots, and a pattern needs ū(x) to be distinct bound variables. Any further metavariable in β would sit inside g's arguments and have no pattern occurrence. So T is a renaming of T_k.
- r3 confirms covering, incomparability, no syntactic generality between members, and that among 867 candidate β (|β| ≤ 5, with fresh g, h, c) only β = g(z) keeps T_k determinate and covering.

So D has infinitely many pairwise incomparable minimal covering templates. Note that ∩_k inst(T_k) = inst(T_1) ∩ inst(T_2), so the acceptance set here is still finitely described. What fails is finiteness of Min(D), not necessarily decidability, which is open.

For DT°, the conjecture is plausible by the forced-argument argument in A2. I have not proved it.

**C9 (holds).**
- r5 implements BKLV-style pattern anti-unification: a fresh variable applied to the occurring bound variables, with identical anti-unification problems merged.
- It returns T12 on all 914 (R)∧(N) pairs of my pool. T12's instance (0=0 & Ax(x=0 -> x=0)) -> Ax x=0 is not an induction instance.
- PAT ⊆ DT and the "least among pattern frame generalizations" argument are correct.

**C10 (holds).**
- The proof is correct: removing ≤ e clean data preserves (R)∧(N) under e-robust diversity, then C3 applies.
- r7(c) checks it with e = 1: clean = {x=x, ~x=0, x=0∨~x=0, Ay.x·y=y·x} plus the mistake s*. All 102 trimmed-version-space templates of size ≤ 14 are ≥ T_ind, and T_ind misses only s*.
- A remark in the notes (§C10 "Remark") says one mistake destroys exactness "without destroying soundness of the class". That is confusing: untrimmed, the acceptance set then contains false sentences, as the remark itself goes on to say.

**C11 (unclear).** It is correctly labelled a conjecture.
- The proof idea ("each escalation removes a rigid symbol or derived equation from every minimal template") presupposes a finite Min(D), which fails in DT (C8.3).
- In DT° a feature-counting sketch suggests a finite bound that is polynomial, roughly O(|first datum|²): Acc(D) = {q : q has every expressible feature of D}, and each escalation kills at least one feature. Linearity is not established.
- I found no counterexample.

**C12 (holds-with-fix).** Checked against the Lean 4.32 source installed at /root/lean-toolchains:
- Lean 4's `Nat.rec` takes the motive as an **implicit** argument, `{motive : Nat → Sort u}`. It is recorded in the elaborated term but is not "the first explicit argument", as the notes say. In Coq's nat_rect/nat_ind, P is explicit.
- `elab_as_elim`'s `mkMotive` does use `kabstract`. Its docstring: "Infer the `motive` using the expected type by `kabstract`ing the discriminants" (Lean/Elab/App.lean).
- The `induction` tactic builds the motive with `mkLambdaFVars` over the target fvars. It first generalizes non-fvar targets (`generalizeTargets` → `generalize`), and uses `kabstract` for complex arguments (Lean/Elab/Tactic/Induction.lean, `setMotiveArg`).
- The error text "motive is not type correct" is **Lean's** (Meta/Tactic/Rewrite.lean, Elab/App.lean), not Coq's. Coq's analogous message is "Abstracting over the term … leads to a term … which is ill-typed" (from memory and a web search; not checked against Coq source).
- Metamath `finds`/`nnind` use implicit-substitution hypotheses, as claimed (checked in the set.mm excerpt).
- "Recording the motive is redundant" holds for closed ∀-form steps. In CIC proof terms, the eliminator's conclusion is `motive t`, a non-pattern occurrence. The motive is recoverable from the successor premise's type only up to conversion, so recording it is not literally redundant there.
- Citations:
  - Correct as far as I know: Huet–Lang 1978; Goldfarb 1981; Stirling 2009; Miller 1991; Pfenning LICS 1991; BKLV JAR 2017; Cerna–Kutsia FSCD 2019; Hirata–Ogawa–Harao ILP 2004; Libal–Miller FSCD 2016; Vaught JSL 1967.
  - Baxter's 1977 Waterloo thesis "The Complexity of Unification" exists. The NP-completeness attribution is the usual one, but I did not see the statement itself.

## Overall

The core mathematics is sound. Matching (C1), the DT anchor theorem (C3, two instances with different main connectives, one non-vacuous), the 26 generalizations and lgg = T_ind (C4), the equivalence with the Sub-encoded learner (C5), the H-closure lemma and the size threshold 12 (C6), the SO° characterization (C7), non-unitarity (C8.1), unsoundness of pattern anti-unification (C9) and noise (C10) all survived hand checking and independent re-implementation on a richer motive language. I found no counterexample to any of them.

Two real defects:
1. **C8.3 is false for DT as defined.** There is an infinite antichain of minimal covering templates, and C8.2's counts are DT°-with-bounds artifacts.
2. **SOCL as specified is not the DT cautious verifier.** Its enumeration ignores nested arguments and can be unsound for DT targets that use them.

Both are repaired by restricting the hypothesis class to **DT°**, where arguments are metavariable-free. This costs nothing for induction, since T_ind and every template in the C3/C4/C6 proofs lie in DT°.

C12 needs small corrections about Lean. C11 remains open.
