# Track "pa": PA, ZF and "the axioms we actually have" (brief H7)

Status labels: **proved** (full proof here), **proved (checked)** (a derivation checked by `checks/nd.py`, a small
proof checker, plus a short informal proof here), **computed** (script and output in `checks/`), **known** (with
reference; "location not verified" when I could not check the page), **proof sketch**, **conjecture**, **refuted**.

All scripts are in `checks/`, are deterministic or seeded, and write `*.out` next to themselves. Section 6 is the
verification log.

## Summary

1. **Equivalent axiomatisations.**
   * Over B = Q1–Q5 plus a definition of <, the full schemas of induction (Ind), course-of-values induction (CVI) and
     the least number principle (LNP) are interderivable, instance by instance. **Proved (checked).**
   * CVI(P) and LNP(P) are higher-order *patterns*; Ind(P) is not. So PA = Q + Dlt + CVI is "Q plus one pattern".
     **Proved.**
   * Under a derivation likelihood the posterior does not prefer the logically minimal axiomatisation. It prefers
     the one whose primitives match the usage. Deriving one form from another costs 570–2250 bits per use. A
     template costs 70–190 bits of prior. So a form that is used a handful of times is worth making primitive.
     **Computed.**
   * The "textbook axioms" win only when the data are essentially direct uses of exactly those axioms. Among minimal
     theories the winner depends on the usage mix. For example, T_Ind beats T_CVI iff p_CVI/p_Ind < 0.60. **Computed,
     with upper-bound constants.**
   * All candidates are deductively equivalent, so the theorems are right whichever one wins.
2. **The MDL finding survives a derivation likelihood.** The split of T_Ind by main connective comes from the
   *instantiation grammar*, not from the likelihood family.
   * The u7 codes of ../axiom-schemas are Bayesian marginal likelihoods. **Known (KT = Dirichlet(½)).**
   * A shared, positional grammar removes the linear gain. The split then sits at the prior difference (+762 to
     +770 bits, constant from n=10³ to 2.56·10⁵). **Computed.**
   * The brief's context-free grammar Q does not remove it. **Computed.**
   * What a derivation likelihood does change: a split containing any non-atomic connective still derives every
     induction instance. **Proved (checked).** An unseen-connective datum then costs 370–490 bits instead of having
     probability 0. **Computed.**
3. **Th(ℕ) data.**
   * With 0/1 derivability every consistent r.e. theory is eventually refuted. **Proved.**
   * Inconsistent theories are never refuted without a consistency filter. **Proved.**
   * The posterior drifts upward, logarithmically in a toy reflection tower. **Computed.**
   * Pointwise limiting correctness is trivial (memorisation). The meaningful notion of success is regret against
     every theory plus an exception budget. **Proved for the mixture likelihood L_ε.**
   * The IΣₙ chain is no obstacle for stochastic data. **Proved for 0/1 likelihood; the per-use penalty is a proof
     sketch.** Inside DT° the posterior lands on the L∞ (PA) side of the Gold dilemma (**proof sketch**).
4. **Bayesian DTRC.** On unlabelled Q+Ind data the posterior puts mass ≥ 1−2·10⁻⁵ on Q+T_Ind from n=100. With two
   negatives this holds from n=10. **Computed, on a hand-picked candidate set.** The other effects:
   * Spare slots cost ½log₂n + prior bits. **Proved; matches the computation.**
   * Fragmentation costs a constant. **Computed.**
   * Rarely used ground axioms are lumped unsoundly at small n. **Computed.**
   * ∀xφ is learned as a sound merge. **Computed.**
   * The sound split that covers only closed instances gains O(log n) on the schema. This is a Bayesian ω-gap.
     **Computed.**
5. **Robust failures.** The worst is a false generalisation whose counterexamples never occur in the data.
   * Positive data favour the false Euler schema Prime(z·z+z+41) by 2·10⁵ bits at n = 10⁶. **Computed.**
   * With a positional grammar its predictive mass on the counterexample goes to 0 like 1/n while the theory keeps
     entailing it. **Computed.**
   * Only refutation removes it, and by ../axiom-schemas Thm. `thm:many:depth` no computable learner can avoid
     depth-relative soundness. **Known.**

---

## 0. Definitions: what this track uses

**Syntax and templates.** Sentences and templates are as in ../axiom-schemas (`setting.tex`):
* DT° templates are second-order templates. Each metavariable has a pattern occurrence, so matching is unique.
* PAT ⊆ DT° are the templates all of whose occurrences are pattern occurrences.

A *theory* is a finite set of templates plus mixture weights. Weights carry a Dirichlet(½) prior unless said
otherwise. Ground templates are single sentences.

**Prior.** π(T) ∝ 2^(−β·Σ_{τ∈T}|τ|), where |τ| counts symbols. The rate is β = 5 bits per symbol in the u7-based
computations (as in ../axiom-schemas, `tab:many:mdl`) and β = log₂23 ≈ 4.52 in the derivation computations.

**Likelihoods.** I use four members of the family of brief H1.

* **L0 (citation).** A datum is an instance τθ of a template τ ∈ T:
  P_T(d) = Σ_{τ∈T, d∈inst(τ)} w_τ · Q(θ_{τ,d}).
  * Q is the *instantiation grammar*. It is a sequential KT model of the metavariable bodies, symbol by symbol,
    given a context.
  * The contexts matter (section 2). The **positional** grammar codes each body as the datum's subtree at the
    metavariable's read-off occurrence, with context (sort, depth, parent symbol, child index). This continues
    the sentence's parse tree, so two templates that fix different amounts of a sentence code the remaining
    symbols in the same contexts (`checks/c4_bdtrc.py`, `occ_positions`).
* **L1-sch (schematic derivation code).** A datum is the conclusion of a derivation in the natural-deduction
  calculus of `checks/nd.py`.
  * The rules are hyp, ax, tc (tautological consequence), →I, ∀E, ∀I, ∃I, ∃E, refl and subst (equality). This is
    a standard sound and complete calculus.
  * The derivation is written schematically in a predicate metavariable P. The datum's motive φ is then coded once
    by Q. Code length is bits(π) + L_Q(φ).
  * bits(π) charges, per line: log₂10 for the rule, log₂|T| for an axiom citation, log₂(line index) per premise
    reference, and β per written symbol.
  * Two-part: −log P_T(d) is approximated by the minimum over derivations. Every number I report is for explicit
    derivations, so it is an **upper bound** on the minimum.
* **L1-naive.** As L1-sch, but every written formula is written out at the instance. This corresponds to H1's
  "instantiate each axiom leaf independently from Q". A derivation that writes P K times then costs about
  β(K−1)(|φ|−1) more than citing.
* **L_ε (Hänni's "need not prove, must not contradict").**
  L_ε(T; d) = (1−ε)·P_T(d) + ε·μ₀(d)·[T ⊬_k ¬d],
  for a fixed background law μ₀ and a bounded refutation search ⊬_k.
  * ε → 0 gives Hänni's "must prove" variant.
  * ε = 1 gives "must not contradict" (section 4.6).

**Bounded derivations.** H1's bounded variant (derivations of length ≤ d) is not used in the computations. Every
derivation scored here is explicit, hence of bounded length. Bounds enter only through the consistency filter of
section 3 and the remarks in F9.

**Negative data.** If a sentence certified false is an instance of T (L0), or derivable in T (L1), then T has
likelihood 0.

**Posterior odds.** In the u7, c2 and c4 computations every code is −log₂ of a Dirichlet(½) marginal likelihood
plus prior bits. Sequential KT is the Dirichlet(½) mixture (**known**: Krichevsky and Trofimov 1981). So code-length
differences are log₂ posterior odds, exactly, except where a datum covered by two templates is coded by the cheaper
one (a two-part bound).

---

## 1. Equivalent axiomatisations: which does the posterior favour?

### 1.1 The equivalences, and over which base theory

Notation:
* Dlt := ∀u∀v(u<v ↔ ∃z(u+Sz=v)), the definition of <.
* For a motive φ with distinguished variable x (parameters allowed):
  * Ind(φ) = φ(0) ∧ ∀x(φ→φ(Sx)) → ∀xφ;
  * CVI(φ) = ∀x(∀y(y<x→φ(y)) → φ(x)) → ∀xφ;
  * LNP(φ) = ∃xφ → ∃x(φ ∧ ∀y(y<x→¬φ(y)));
  * θ_φ := ∀y(y<x→φ(y)).

**Proposition 1.1 (proved, checked).** Let B = {Q1,…,Q5, Dlt}, where Q1–Q5 are Robinson's axioms for S and +, with
Q3 as x=0 ∨ ∃y x=Sy. For every motive φ:
* (A) B ⊢ CVI(φ) → Ind(φ). This uses Q3, Q4, Q5 and Dlt.
* (B) B ⊢ Ind(θ_φ) → CVI(φ). This uses Q1–Q5 and Dlt.
* (C1) ⊢ CVI(¬φ) → LNP(φ). Pure logic.
* (C2) ⊢ LNP(¬φ) → CVI(φ). Pure logic.

Hence B+Ind, B+CVI and B+LNP have the same theorems. So do Q+Dlt+Ind (that is, PA with < defined), Q+Dlt+CVI and
Q+Dlt+LNP. The multiplication axioms are not needed for the equivalence.

*Proof.* Machine check: `checks/arith.py` builds each derivation schematically in a unary predicate symbol P, and
`nd.py` checks every line. Substituting a formula for P is a substitution for a predicate symbol, after renaming the
derivation's bound and eigen-variables away from φ. It maps derivations to derivations (standard: the substitution theorem
for predicate symbols, e.g. in Shoenfield 1967, *Mathematical Logic*; location not verified). `test_nd.py` replays all four derivations on 200 random concrete
motives with parameters; all check. The cited axioms are listed by `c1_costs.py` (last block of `c1_costs.out`).

Informal proofs:
* **(A)** Assume φ(0) and ∀x(φ→φ(Sx)), and show progressiveness. Take x with ∀y<x φ(y). By Q3, x=0, so φ(x); or
  x=Sw. In the second case w+S0 = S(w+0) = Sw by Q5 and Q4, so w<x by Dlt. Hence φ(w), hence φ(Sw) = φ(x). Then
  CVI gives ∀xφ.
* **(B)** Apply Ind to θ_φ.
  * Base: y<0 gives y+Sz = 0 for some z. Then S(y+z) = 0 by Q5, which contradicts Q1.
  * Step: y<Sx gives y+Sz = Sx. So y+z = x by Q5 and Q2. By Q3, z=0 or z=Sv.
    * If z=0, then y = x by Q4, and φ(x) follows from θ_φ(x) and progressiveness.
    * If z=Sv, then y+Sv = x, so y<x and φ(y) follows from θ_φ(x).
  * So ∀x θ_φ(x), and progressiveness gives ∀xφ.
* **(C1), (C2)** are contrapositions.

∎

**Remark 1.2 (proved).** CVI(P) and LNP(P) are in PAT. Every occurrence of P in them is P(x) or P(y) under a binder
for that variable, so it is a pattern occurrence (definition: ../axiom-schemas `setting.tex`). T_Ind is in DT°∖PAT
because of P(0) and P(Sx). So PA (with Dlt) is axiomatised by Q, Dlt and one higher-order pattern. This complements
`prop:zf:indeq` (Tarski's IndEq, a first-order pattern). It matters for learnability, because pattern
anti-unification applies to CVI and LNP but not to Ind (`prop:zf:indpat`).

**Fragments (known; locations not verified).** The task asked about the exact base theory.
* For restricted motive classes the equivalences are the classical ones: over PA⁻, IΣₙ ⇔ IΠₙ ⇔ LΣₙ ⇔ LΠₙ for
  every n (Paris and Kirby 1978; Kaye 1991, *Models of Peano Arithmetic*, ch. on fragments; Hájek and Pudlák 1993,
  ch. I §2).
* I could not check the theorem numbers. The chain is restated in secondary sources (K. Gao, PKU slides on end
  extensions, 2018; K. Tanaka, lecture exercise).
* These sources also note that the IΣₙ ⇔ IΠₙ equivalence fails for parameter-free schemes (Cordón-Franco and
  Lara-Martín, slides).
* The motive transformation of (B), φ ↦ θ_φ, puts a bounded universal quantifier in front. That is why fragment-level
  equivalence needs work (bounded collection) that the full-schema case does not.
* DT° templates cannot express "motive in Σₙ", since metavariables range over all formulas. So within this
  project's hypothesis class only the full-schema equivalence (Prop. 1.1) is relevant.

### 1.2 What the posterior does: the per-use cost of a non-primitive form

**Setting (L1-sch).**
* Data are i.i.d. *uses* (f, φ): a form f ∈ {Ind, CVI, LNP} with probability p_f, and a motive φ ~ Q.
* Theories are T_S = Q1–Q7 + Dlt + S, for nonempty S ⊆ {Ind, CVI, LNP}.
* A use costs c_S(f) + L_Q(φ). Here c_S(f) is the bit cost of the cheapest derivation of f(P) from T_S in a fixed
  library of checked derivations: a one-line citation if f ∈ S.

**Computed** (`checks/c1_costs.py`, output `c1_costs.out`; β = log₂23):

| theory | form | lines | written symbols | K (writes of P) | bits | overhead over citing |
|---|---|---:|---:|---:|---:|---:|
| T_Ind | CVI | 63 | 204 | 14 | 1483.6 | 1468.0 |
| T_Ind | LNP | 82 | 332 | 33 | 2249.6 | 2234.1 |
| T_CVI | Ind | 39 | 127 | 18 | 896.0 | 880.4 |
| T_CVI | LNP | 20 | 117 | 20 | 662.0 | 646.4 |
| T_LNP | Ind | 65 | 253 | 38 | 1707.7 | 1692.1 |
| T_LNP | CVI | 27 | 128 | 21 | 773.1 | 757.5 |
| any T_S with f ∈ S | f | 1 | 2 | 1 | 15.5–15.8 | 0 |

Template prior costs β|f(P)|: Ind 72 bits, CVI 81, LNP 86.

**Proposition 1.3 (proved, given the library constants).**
* Statement:
  * Let D_n be n i.i.d. uses.
  * Then (1/n)·(L(T_S; D_n) − L(T_{S'}; D_n)) → Σ_f p_f (c_S(f) − c_{S'}(f)) almost surely.
  * So the posterior concentrates on the S minimising E_p[c_S(f)], if the minimiser is unique.
* Proof:
  * The prior terms are constants. The L_Q(φ) terms are equal under every theory and cancel.
  * The difference of the rest is a sum of i.i.d. bounded terms, so the strong law of large numbers applies.
  * Posterior odds are 2 to the minus the code-length difference, which tends to 0 or ∞ exponentially when the
    limit is nonzero.
* ∎

The constants are upper bounds on the true minima, because I did not search for shortest derivations. The *lower*
bound needed for "a non-primitive form costs more than citing" is trivial: for generic φ, CVI(φ) is not an instance
of any axiom of T_Ind. So every T_Ind-derivation has at least two lines and costs at least log₂10 + β bits more than a
citation.

**Consequences (computed from the table).**

* **Among minimal theories, the asymptotic winner is a function of usage** (`c1_costs.out`, grid):
  * T_Ind wins only for p_Ind ≳ 0.7.
  * T_CVI wins a broad middle region. CVI is a cheap "hub": both Ind and LNP derive from it in 650–900 bits.
  * T_LNP wins when p_LNP is large.
  * Pairwise break-even points:
    * T_Ind beats T_CVI iff p_CVI/p_Ind < 0.600;
    * T_Ind beats T_LNP iff p_LNP/p_Ind < 0.757;
    * T_CVI beats T_LNP iff p_LNP/p_CVI < 1.172.
* **The redundant union wins as soon as two forms are used.**
  * T_all = Q+Dlt+{Ind, CVI, LNP} pays 81 + 86 bits more prior and log₂(11/9) ≈ 0.29 bits more per citation.
  * One CVI use saves 1468 bits under T_Ind. So after about one use of a non-primitive form the redundant theory is
    ahead.
  * By Prop. 1.3 the posterior concentrates on the **usage-closed** axiomatisation: every form used at a rate
    above roughly 0.3/650 ≈ 5·10⁻⁴ per use is primitive.
  * This is a quantitative form of the brief's H2 remark that a derivation likelihood identifies an
    axiomatisation, not a theory.
* **The code matters for which minimal theory wins.** Under L1-naive the overhead grows by about β(K−1) bits per
  symbol of the motive (computed: e.g. CVI from T_Ind costs 1621, 1915, 2515 and 3832 bits at |φ| = 5, 10, 20, 40).
  Ind-from-CVI has the larger K (18 versus 14). So at |φ| = 40 its overhead (4030) exceeds CVI-from-Ind's (3832):
  the asymmetry flips for large motives. The redundant-union conclusion does not depend on the code.

### 1.3 Recursion conventions for + ("Q5 as written versus variants")

T_right = Q + Ind (Q4: x+0=x, Q5: x+Sy=S(x+y)). T_left replaces these by Q4L: 0+x=x and Q5L: Sx+y=S(x+y).

**Proposition 1.4 (proved, checked).** T_left ⊢ Q4, Q5 and T_right ⊢ Q4L, Q5L, each with one induction. The motives
are x+0=x; ∀y(x+Sy=S(x+y)); 0+x=x; and Sp+x=S(p+x) with parameter p. So the two theories are equivalent.

**Computed.** Overheads per use: Q4 in T_left 213.8 bits, Q5 in T_left 593.4, Q4L in T_right 213.8, Q5L in T_right
545.1. So the posterior adopts whichever convention the data use. T_right wins iff
r₄·213.8 + r₅·593.4 > l₄·213.8 + l₅·545.1, where r and l are the usage rates of the two conventions.

### 1.4 ZF: Replacement versus Collection, Foundation versus ∈-induction, Separation from Replacement

Forms (`checks/zf.py`; schema constructors rename their own binders away from the motive's free variables):
* SepJ: ∀X∃Y∀u(u∈Y ↔ u∈X ∧ φ).
* ReplJ (image form): ∀x∀y∀z(ψ∧ψ[z/y] → y=z) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X∧ψ)).
* ReplK (bounding form, ∃! spelled out).
* Coll, EInd and Found, as in ../axiom-schemas `tab:zf:forms`.

The checker caught one error of mine: a first version of SepJ let its bound X capture the motive's parameter X.

**Equivalences and base theories.**
* **Separation from Replacement (proved, checked).** ⊢ ReplJ(λxy. φ(x) ∧ y=x) → SepJ(φ), in pure logic with
  equality. The pair is functional, and its image of X is {x∈X : φ(x)}.
  * Computed cost: 36 lines, overhead 1209 bits per use. The SepJ template costs 72 bits.
  * Jech's book remarks that Separation follows from Replacement (recalled, not re-checked). The checked derivation
    does not depend on that remark.
  * Whether Kunen's bounding form ReplK yields Separation was not studied.
* **Replacement from Collection (proved, checked).**
  * ⊢ Coll(ψ) → ReplK(ψ), in pure logic: the ∃! antecedent implies the ∃ antecedent. Computed: 15 lines, 574 bits.
  * Coll(ψ) together with two SepJ instances ⊢ ReplJ(ψ). Separate the domain {x∈X : ∃y ψ}, collect, then separate
    the image. Computed: 43 lines, 1432 bits.
* **Collection from Replacement.**
  * It holds over ZF. **Known**: via ranks or reflection (Lévy 1979; Jech 2003; location not verified).
  * It fails without Power Set. **Known**: Zarach 1996, "Replacement ↛ Collection", Gödel '96, Lecture Notes in Logic
    6, pp. 307–322/323 (page range differs between sources). Also Gitman, Hamkins and Johnstone, "What is the theory
    ZFC without power set?", MLQ 62(4–5):391–406, 2016, doi 10.1002/malq.201500019. Both verified via
    abstracts and catalogue records, not full text.
  * Without Foundation but with Power Set: **unknown to me**. The standard proof uses V = ⋃V_α. The sources I found
    do not settle it, and ../axiom-schemas `prop:zf:coll` leaves it open too.
  * A derivation of Coll from Repl must therefore use Power Set and Foundation-like machinery. I did not formalise
    it. **Conjecture**: its overhead is far larger than 574 bits.
* **Foundation from ∈-induction (proved, checked).** ⊢ EInd(¬x∈S) → Found, in pure logic. Computed: 21 lines, 758
  bits. The Found sentence costs 109 bits.
* **∈-induction from Foundation.**
  * It needs transitive closures. So it holds over ZF minus Foundation, where Infinity, Union and Replacement give
    TC({a}) (standard).
  * Without Infinity, transitive containment (equivalently ∈-induction) has to be assumed. **Known**: Kaye and Wong,
    "On interpretations of arithmetic and set theory", NDJFL 48(4):497–510, 2007, abstract verified.
  * I recall, but did not verify, that ZF−Inf with Foundation does not prove transitive containment.
  * Not formalised. **Conjecture**: its overhead is much larger than 758 bits.

**When do the textbook ZF axioms win?** By the same accounting as Prop. 1.3:
* **Separation.** It is redundant given ReplJ, yet every use of it saves about 1209 bits against its 72-bit
  template. So the posterior keeps Separation whenever Separation is used. It agrees with the textbooks here, which
  keep it.
* **Foundation versus ∈-induction.** If set-theoretic practice uses ∈-induction or ∈-recursion, then EInd becomes
  primitive. The single sentence Found survives only if it is itself cited: each citation saves about 758 bits
  against its 109-bit cost.
* **Collection versus Replacement.** The posterior adds Collection as soon as Collection is used, since the reverse
  derivation is long (conjectured). It keeps Replacement as soon as Replacement is used. With only Replacement uses,
  T_Coll pays 574–1432 bits per use, so Replacement wins.

### 1.5 Answer to question 1

The posterior favours the axiomatisation that makes the **used forms primitive**: one citation instead of a
derivation of hundreds to thousands of bits.
* Logical economy (fewer, independent axioms) enters only through prior terms of about 70–190 bits per template.
  These are swamped after about one use.
* So "the textbook axioms" win exactly when the data consist of direct uses of the textbook axioms and of nothing
  else that the textbook axioms derive only at a cost.
* Among minimal axiomatisations the winner is set by the usage mix, with the break-even ratios above.
* In every case considered, all competitors are deductively equivalent. So the posterior gets the *theorems* right
  even when it gets the textbook *presentation* wrong.
* The constants are for one calculus and one code. The qualitative conclusions use only two facts: overheads ≫
  template costs, and overheads > 0.

---

## 2. The MDL finding of ../axiom-schemas revisited

**The finding** (`sec:many:mdl`, `app:many:mdl`, `tab:many:mdl`): "MDL tracks the statistics of usage, not the logical
boundaries of schemas". A naive two-part code splits T_Ind by the motive's main connective, by a margin linear in n.
Under a natural usage law (G1) even the depth-aware code DPC splits for n ≥ 1.6·10⁴.

### 2.1 The u7 codes are Bayes factors

The PC and DPC codes of u7 are sequential KT, so they are Dirichlet(½) marginal likelihoods. The template part
(5 bits per symbol) is a prior. So the u7 table already gives log₂ posterior odds. Its finding is a Bayesian finding,
not an artefact of two-part coding. **Known** (Krichevsky–Trofimov), applied.

### 2.2 Exact comparisons with new grammars

`checks/c2_mdl.py` (output `c2_mdl.out`) re-runs u7 with its data generators and seeds. It reproduces the u7 numbers
exactly at n=1000 (NAIVE −223, PC +2325, DPC +2701 on G1; −915, +1141, +1428 on G2). It adds:
* **SDPC**: one grammar shared by all templates, context (depth, parent, child index). The split templates' bodies
  are coded at the position they occupy in T_Ind. So the split changes only how the root symbol is coded (by the
  template index instead of the grammar).
* **RDPC**: for H_true, the grammar may condition on the motive's root symbol. H_root keeps u7's per-template DPC.

`checks/c2b_cf.py` (output `c2b_cf.out`) adds **CF**, a shared context-free grammar with one distribution per sort.
This is the brief's H1 "probabilistic grammar Q".

L(H_root) − L(H_true) in bits (positive: the posterior keeps T_Ind whole; "template part" is the prior difference):

| law | n | NAIVE | PC | DPC | SDPC | RDPC | CF | template part |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| G1 | 1000 | −223 | +2325 | +2701 | +770 | +1677 | +710 | +780 |
| G1 | 16000 | −16466 | −1199 | −3036 | +766 | +3725 | −302 | +780 |
| G1 | 64000 | −68243 | −19783 | −34412 | +764 | +4837 | −3583 | +780 |
| G1 | 256000 | −274656 | −94089 | −163028 | +762 | +5986 | — | +780 |
| G2 | 1000 | −915 | +1141 | +1428 | +415 | +881 | +248 | +425 |
| G2 | 64000 | −87156 | −1522 | +3564 | +409 | +1965 | −10581 | +425 |
| G2 | 256000 | −350750 | −12368 | +4313 | +407 | +2369 | — | +425 |

**Reading.**
* **A grammar shared across templates and positioned in the sentence (SDPC)** makes the split worthless. The
  difference is the prior difference minus 10–18 bits, constant from n=10³ to 2.56·10⁵. The posterior keeps T_Ind
  whole by about 2⁷⁶⁰ to 1, which is the prior ratio.
* **RDPC also keeps T_Ind whole**, with a margin growing like log n. H_root's per-template grammar has more
  parameters, and they buy nothing.
* **The brief's context-free Q (CF) does not fix the split.** The split wins at a linear rate (−0.056 bits per datum
  on G1 and −0.165 on G2 at n=64000).
  * Under CF the motive's root is coded with the pooled distribution of all formula symbols.
  * That distribution is not the distribution of roots.
  * Moving the root into the template index buys the KL divergence per induction datum.
* **First lesson: the finding is about Q.** Any template split pays off linearly whenever the grammar ignores a
  feature that the split conditions on and that usage depends on.

**Proposition 2.1 (proved; chain rule).**
* Statement:
  * Fix the parameters.
  * Let H_true have weight w on T_Ind and body law Q(φ) = Q(root f)·Q(rest | f).
  * Let H_F have weights w·Q(f) on T_f and body law Q(· | f), with F ⊇ supp(root).
  * Then P_{H_F} = P_{H_true} on every datum.
* Proof:
  * For an induction datum Ind(φ) with root f, P_{H_F} = w·Q(f)·Q(φ|f) = w·Q(φ) = P_{H_true}.
  * Ground data have the same weight under both.
* ∎

So, with a well-specified shared grammar, the data cannot separate the split from the schema, and the posterior odds
equal the prior odds (here 2^(β·(Σ_f|T_f| − |T_Ind|))).

With Dirichlet uncertainty both hypotheses have the same number of free parameters when every root occurs. The
log-marginal difference then converges to a constant. **Proof sketch**: Clarke and Barron 1990 asymptotics, (d/2)·log n
+ O(1) with the same d. **Computed**: SDPC.

### 2.3 Never-used roots: fragmentation wins, at a logarithmic rate

G3 is u7's natural law restricted to the roots {=, →, ∀}. Under SDPC:
* the full split H_root stays at +300…+292 bits;
* the split into the *used* roots only drifts down from +285 (n=10³) to +261 (n=2.56·10⁵), about 3 bits per doubling
  of n.

The reason: H_true's grammar keeps paying ½·log₂n for each root symbol never used, while the used-roots split pays
only for its extra templates. The crossover is near n ≈ 2¹⁰⁵. **Computed** (`c2_mdl.out`, G3 block). The same effect
appears in section 4.5 for the universal x+0=x, where it is a Bayesian ω-gap.

### 2.4 What a derivation likelihood changes

**Proposition 2.2 (proved, checked; and known for the converse).**
* H_F derives every instance of induction if F contains a non-atomic connective.
  * The wrappers are ¬¬P, P∧P, P∨P, (0=0)→P, ∀zP and ∃zP. Each is logically equivalent to P and has the required
    main connective.
  * `checks/c2_detour.py` checks a schematic derivation of Ind(P) from Ind(w_f(P)) for each.
* If F = {=}, H_F is contained in IOpen, so it is strictly weaker than PA.
  * IOpen does not prove the irrationality of √2: **known**, Shepherdson, "A non-standard model for a free variable
    fragment of number theory", Bull. Acad. Polon. Sci. 12 (1964) 79–86. Verified through secondary sources (Kaye
    1993 survey; Kennedy and Kossak), not the original.
  * PA proves it.

**Computed** (`c2_detour.out`). Overhead of the detour, over citing Ind(P) directly:

| root | wrapper | lines | overhead (bits) |
|---|---|---:|---:|
| ¬ | ¬¬P | 17 | 409.9 |
| ∧ | P∧P | 17 | 441.6 |
| ∨ | P∨P | 17 | 441.6 |
| → | (0=0)→P | 19 | 488.9 |
| ∀ | ∀zP | 17 | 369.2 |
| ∃ | ∃zP | 19 | 425.6 |

**Consequences.**
* **(a) No incompleteness at the level of theorems.** Under L0 a split is incomplete: induction on an unused
  connective is never a citation. In the Bayesian L0 model it is worse: one datum with an unsplit root has
  probability 0 and kills the split. Under L1 the split derives every induction instance, and such a datum costs
  370–490 bits. So the incompleteness error of MDL in `app:many:mdl` ("errs towards incompleteness for schemas") is
  removed by a derivation likelihood, as soon as the split contains a non-atomic root. This is the conversation's
  "at the level of theorems it is nearly trivial" (../axiom-schemas `research/conversation.md` §7), now with a cost
  attached.
* **(b) The usage effect is unchanged.** On data whose roots are all covered, an L1-sch derivation of a direct
  instance is one citation, so it costs exactly what it costs under L0. The split-versus-schema comparison is
  therefore the same as in 2.2. It is decided by the grammar.
* **(c) The unsoundness error of MDL** ("towards unsoundness for rarely used ground axioms") is not removed either.
  Under L1 the size principle does not even see inconsistency (Prop. 4.3). Section 4.4 computes it.

**Answer to question 2.**
* A derivation likelihood does not change the MDL finding about *which templates* the posterior picks. The split is
  driven by the instantiation grammar, and so are both the linear gain (NAIVE, PC, DPC, CF) and its absence (SDPC,
  RDPC).
* It does change the *consequences*. A split with a non-atomic connective is deductively equivalent to PA. The
  verifier "accept s iff the posterior mass of theories deriving s is ≥ 1−δ" then accepts every induction instance.
* A well-specified, positional, shared grammar keeps T_Ind whole by its prior margin, with the logarithmic exception
  of never-used parts (2.3).

---

## 3. Data from Th(ℕ)

Data are i.i.d. true sentences under a law μ on Th(ℕ). No r.e. theory derives all of them.

**Proposition 3.1 (proved).**
* Statement:
  * Use the 0/1-support likelihood: P_T(d) > 0 iff T ⊢ d (L1 with every rule, template and grammar symbol having
    positive weight).
  * Suppose μ has full support on Th(ℕ).
  * Then every consistent r.e. theory T has posterior 0 after finitely many data, almost surely.
* Proof:
  * If T proves a false φ, then ¬φ ∈ Th(ℕ) and T ⊬ ¬φ by consistency.
  * Otherwise T ⊆ Th(ℕ). Th(ℕ) is not r.e. while T's theorems are, so some true σ has T ⊬ σ.
  * In both cases a single sentence s with μ(s) > 0 and P_T(s) = 0 exists.
  * The probability that s is absent from n draws is (1−μ(s))ⁿ → 0.
* ∎

**Proposition 3.2 (proved).**
* Inconsistent theories derive every sentence, so under 0/1 support they are never refuted.
* With a consistency filter (exclude T if ⊥ has a T-derivation of length ≤ d_n) and d_n → ∞, each fixed
  inconsistent theory is excluded after finitely many steps. Proof: its shortest refutation has some finite length.
* The filter is necessary for any soundness, and by `thm:many:depth` of ../axiom-schemas no computable learner avoids
  the depth parameter (**known**).

**Computed: a toy model of the drift** (`checks/c3_tower.py`, output `c3_tower.out`).
* Setup:
  * A datum has a "level" ℓ: the least k with T_k ⊢ it, along a progression T₀ = PA, T_{k+1} = T_k + Con(T_k).
  * Levels are i.i.d. Geometric(ρ).
  * The prior is 2^(−b(k+1)) with b = 50.
  * Each T_k generates its own theorems with a truncated geometric level law, rate s.
* Results:
  * The MAP level equals the largest level seen (logarithmic drift: 16 at n=10⁵ for ρ=½).
  * The posterior probability that the next datum is unprovable decays like 1/n (7.6·10⁻⁶ at n=10⁵).
  * The regret against the true law grows like b × (largest level): 799 bits at n=10⁵ for ρ=s=½.
  * With misspecified s (s=0.3, ρ=0.5) the regret is linear (0.26 bits per datum).
  * With L_ε (ε=0.01) the MAP lags the record, since rare high levels are paid as exceptions. The regret is lower
    (674 bits).
* Why the drift goes through ground sentences: the reflection schema Pr_T(⌜φ⌝) → φ is not a DT° template, since
  quoting a formula is not a substitution (**proof sketch** below). So in DT° each step up the progression adds a
  ground sentence, at a cost of about b bits.

**Proof sketch (reflection is not a template).**
* In a DT° template, the term at the position of ⌜φ⌝ is either rigid, or built from term metavariables and rigid
  symbols.
* Term metavariables are instantiated independently of the formula metavariable P, unless they occur inside φ's
  position too. Even then they are bodies, not functions of P's syntax.
* So any template covering all instances Pr(⌜φ⌝) → φ has an instance with a numeral unrelated to φ, such as
  Pr(⌜0=0⌝) → 0=S0, which is false.
* A full proof needs care with term metavariables that occur both in the numeral position and inside φ. Not done.
* The same argument applies to Hänni's assigner schema "T(⌜φ⌝)=accept → φ". This bears on H6, the universal track's
  question.

**Proposition 3.3 (proved; regret against a theory plus exceptions).**
* Statement:
  * Use the likelihood L_ε (section 0), with mixture P_mix(D) = Σ_T π(T)·Π_{d∈D} L_ε(T; d).
  * For every theory T in the class and every data sequence D_n, write E(T, D_n) for the set of data that T does
    not derive (but does not refute). Then
    −log₂P_mix(D_n) ≤ −log₂π(T) + Σ_{d∈D_n∖E} −log₂((1−ε)P_T(d)) + Σ_{d∈E} −log₂(εμ₀(d)).
  * The same holds with 0/1 support (ε=0), with T replaced by T∪E (memorised exceptions). There the exceptions cost
    prior bits, β|e| each.
* Proof:
  * P_mix(D_n) ≥ π(T)·Π_d L_ε(T; d).
  * For d ∉ E, L_ε(T; d) ≥ (1−ε)P_T(d).
  * For d ∈ E, L_ε(T; d) ≥ εμ₀(d).
  * Take −log₂.
* ∎

**Remark 3.4 (proved; pointwise limits are trivial).**
* Under 0/1 support and full-support μ, each fixed true s eventually appears in the data. From then on every
  surviving theory derives s.
* Each fixed false s has ¬s eventually in the data. From then on every surviving *consistent* theory fails to derive
  s.
* So "every sentence is eventually decided correctly" is achieved by memorisation alone, and it carries no
  information about generalisation.
* With inconsistent theories present, the second statement needs the filter of Prop. 3.2. Whether the posterior mass
  of not-yet-filtered inconsistent theories deriving s tends to 0 is **open**. Their likelihood can be large (section
  5, F4).

**The IΣₙ chain** (../axiom-schemas `research/conversation.md` §§7–10; `research/prior/pa-untagged`). In the Gold
model the chain IΣ₁ ⊂ IΣ₂ ⊂ … with union PA is a limit point, so no learner identifies PA from a text of theorems.

**Proposition 3.5.**
* **(a) Proved, given known facts.**
  * Statement:
    * Let the data be i.i.d. theorems from PA's L1 derivation process. It gives every PA-theorem positive
      probability, provided all weights are positive.
    * Represent each IΣₙ (n ≥ 1) in DT° as Q plus a single sentence σₙ. **Known**: IΣₙ is finitely axiomatisable for
      n ≥ 1.
    * Then IΣₙ has posterior 0 after finitely many data, almost surely.
  * Proof:
    * PA ⊢ Con(IΣₙ), indeed IΣ_{n+1} ⊢ Con(IΣₙ). **Known**: stated in secondary sources (an FOM post of 2006;
      lecture notes); the conversation, §7, also uses it. Primary location not verified.
    * IΣₙ ⊬ Con(IΣₙ) by Gödel II, since IΣₙ is consistent (it is true).
    * So P_PA(Con(IΣₙ)) > 0 = P_{IΣₙ}(Con(IΣₙ)).
  * ∎
  * Stochastic data thus separate the chain from its limit, as in Angluin's stochastic setting (Angluin 1988, cited
    by the brief). The waiting time is about 1/P_PA(Con(IΣₙ)), which is astronomically large.
* **(b) Proof sketch.** Before that happens, σₙ is already penalised per use. Deriving Ind(φ) for a Σₙ motive φ from σₙ
  needs the Tarski biconditional for the partial truth predicate at ⌜φ⌝. That is a derivation whose length grows with
  |φ|, whereas citing T_Ind costs L_Q(φ) plus a constant. So on induction-use data the PA template wins at a linear
  rate. I did not formalise this and did not check the growth rate.
* **(c) Proof sketch.**
  * Statement: if the community uses only Σₙ motives, every DT° theory that covers its practice as citations (L0)
    contains PA-strength induction. (Under L1 the single sentence σₙ also derives the practice; (b) is about it.)
  * Argument:
    * A metavariable ranges over all formulas.
    * By the anchor theorem (`thm:zf:indanchor`), two Σₙ instances with different main connectives and x free force
      every covering template to contain inst(T_Ind).
    * With per-connective splits, the wrappers of Prop. 2.2 give full induction.
  * So in DT° the posterior lands on the **L∞ side** of conversation §9. This is truth-safe in this chain, since all
    the IΣₙ and PA are true.
  * To identify IΣ₅ one needs templates with sort-restricted metavariables ("Σ₅ formula"). But a template with a
    restricted metavariable and an unrestricted one with a grammar concentrated on Σ₅ have the same likelihood when
    the grammar can express the restriction. **Proof**: same chain-rule argument as Prop. 2.1. **Status**: proof
    sketch, since grammar expressivity is not formalised.
  * Then only the prior separates them.

**General lesson (proof sketch).** The model draws the line between *theory* (what templates entail) and *usage*
(what the grammar makes probable).
* Positive data identify usage.
* Deductive strength beyond usage is fixed by the prior and the template class, not by data.
* This is the Bayesian form of the L∞-versus-L₅ choice.

**What is the right notion of success for Th(ℕ)?**
* *Identification* is impossible (Prop. 3.1).
* *Pointwise limiting correctness* is trivial (Remark 3.4).
* *Soundness at all times* fails in general (section 5, F4).
* What can be promised:
  * **(i) Predictive competitiveness** against every theory in the class, paying its exceptions (Prop. 3.3). Per-datum
    regret against the best theory-plus-exceptions vanishes when the exception rate does (computed in the toy).
  * **(ii) Depth-relative soundness.** Theories refuted within the current depth carry no mass. This is the
    residue-relative soundness of ../axiom-schemas, and `thm:many:depth` says it cannot be improved.
* With progressions one may hope for (iii), completeness along a path through ordinal notations (Turing 1939;
  Feferman 1962; cited from memory). That path is not effective, and DT° does not express reflection, so I make no
  claim.

---

## 4. Unlabelled mixtures: a Bayesian DTRC

**The model.**
* Hypotheses are finite sets of DT° templates.
* The prior is 5 bits per template symbol. A prior on the number of templates is implicit, since every template
  costs bits.
* Weights are Dirichlet(½).
* There is one shared positional grammar for all bodies (section 0).
* Negative data give likelihood 0.
* Candidate theories would come from DTRC's Min(·) clusters. Here I score a hand-picked candidate set (computed in
  `checks/c4_bdtrc.py`, output `c4_bdtrc.out`). I do **not** compute the posterior over all finite unions.

**Proposition 4.1 (proved; cost of a spare slot).**
* Statement:
  * Adding a never-used template τ to a theory with K templates costs β|τ| + ½·log₂n + log₂(Γ(K/2)/Γ((K+1)/2)) + o(1)
    bits.
  * So a spare slot's posterior odds decay like n^(−1/2)·2^(−β|τ|), polynomially and not exponentially.
* Proof:
  * The Dirichlet(½) marginal of counts (n₁…n_K, 0) over K+1 categories, divided by that of (n₁…n_K) over K, equals
    Γ((K+1)/2)Γ(n+K/2) / (Γ(K/2)Γ(n+(K+1)/2)).
  * By Stirling, Γ(n+a+½)/Γ(n+a) ~ n^(1/2).
* ∎
* Check: for K=8 and τ = (F→F) (15 bits), the formula gives 19.03 bits at n=1000 and 19.82 at n=3000. The computed
  values are +19.0 and +19.8.

**Computed: Q + Ind practice** (u7 law G1, induction with probability ½, seed 11). L − L_true in bits:

| candidate | n=10 | n=30 | n=100 | n=1000 | n=3000 |
|---|---:|---:|---:|---:|---:|
| true Q+T_Ind | 0 | 0 | 0 | 0 | 0 |
| root split (7 T_f) | +776.4 | +773.6 | +772.7 | +769.9 | +768.3 |
| spare Q+T_Ind+(F→F) | +15.9 | +16.6 | +17.4 | +19.0 | +19.8 |
| memorise instances | +1792 | +5393 | +15901 | +133905 | +399840 |
| over-general Q+T_L∞ | +550 | +1501 | +3833 | +27257 | +82196 |
| lump Q: F₀+T_Ind | **−174.7** | **−42.0** | +319 | +6440 | +19412 |
| bare F₀ | +584 | +2149 | +6068 | +46311 | +137534 |

T_L∞ is Z₁ ∧ ∀x(Z₂(x)→Z₃(x)) → ∀xZ₂(x), the over-general template of `prop:zf:indtwo`.

* **Posterior mass on Q+T_Ind.**
  * Without negatives: 2.6·10⁻⁵³ at n=10, 2.2·10⁻¹³ at n=30, and ≥ 1−6·10⁻⁶ from n=100 on. The remainder is almost
    all on the spare slot.
  * With the two negatives {0=S0, the false T_L∞ instance (0=0)∧∀x(0=S0→0=S0)→∀x(0=S0)}: ≥ 1−1.6·10⁻⁵ from n=10 on.
  * The root split and the spare are deductively equivalent to PA: the spare template F→F is a tautology schema,
    and the split contains ¬. So, within this candidate set, the mass on PA-equivalents is ≥ 1−10⁻⁹⁶ from n=100
    on, and the remainder at n=100 is the lump. With negatives the remainder is 0.
* **4.4 Unsound lumps of rarely used ground axioms.** At n=10 and n=30 the posterior prefers F₀+T_Ind. The seven
  Q-axioms are each seen about once, and the bare metavariable F₀ codes them through the grammar more cheaply than
  seven ground templates cost in the prior.
  * F₀ has every sentence as an instance, so the theory is unsound.
  * This is the Bayesian form of `app:many:mdl`'s "errs towards unsoundness for rarely used ground axioms".
  * The negative datum 0=S0 refutes it at once. Without negatives the crossover lies between n=30 and n=100 here.
* **Lumps, memorisation and over-generalisation** all lose at a linear rate without negatives. This is the size
  principle.
* **Fragmentation** costs a constant, about the prior difference. It shrinks by about one bit per doubling of n
  (½·log₂n for each of the two never-used formula symbols ⊤, ⊥ in the grammar alphabet). The posterior keeps the
  schema in practice.

**4.5 ∀xφ as a sound merge** (u7's rand_closed terms t, data t+0=t, seed 12). L − L_schema in bits:

| candidate | n=10 | n=100 | n=1000 | n=3000 |
|---|---:|---:|---:|---:|
| schema z+0=z | 0 | 0 | 0 | 0 |
| split by head of t (0, S, +, ·): sound | +115.5 | +101.0 | +84.6 | +76.7 |
| memorise instances | +520 | +3750 | +34024 | +83197 |
| over-general z₁+0=z₂ | +146 | +927 | +7976 | +22702 |
| L1: ∀x(x+0=x) plus one ∀E step per datum | +38 | +337 | +3327 | +9971 |

* **The schema wins.** The instance schema is the merge of the instances, as in `prop:many:forall`.
* **The universal sentence loses under L1.** It pays about log₂10 bits per datum for the extra ∀E step, so its
  posterior odds fall like 2^(−3.3n). This is H4's prediction: instance data move mass from H_∀ to H_sch. Here the
  computation is crude: the extra step is charged log₂10 per datum and the sentence's template one more symbol.
* **The over-general template** has a false instance and dies with the negative 0+0=S0.
* **A Bayesian ω-gap.** The sound split by head symbol covers every instance t+0=t whose t is not a bare variable.
  That includes all closed instances, but not a+0=a, which in closure-normal form is ∀x(x+0=x). (With Q3 in the
  theory, the split's members S(z)+0=S(z) and 0+0=0 would give ∀x(x+0=x) by case analysis. Here the theory is
  the templates alone.)
  * It closes in on the schema at about 5 bits per doubling of n. The schema's grammar pays ½log₂n for each term
    symbol that never occurs at the root of t (parameters, holes).
  * Extrapolated crossover: about n ≈ 10⁸ (76.7 bits at 5 bits per doubling from n=3000).
  * So, with closed-instance data only, the posterior *eventually* prefers the theory that does not entail ∀x(x+0=x).
  * Under L1 this costs nothing at the level of closed theorems. Whether the universal is entailed then depends on
    the prior. This is the universal track's question; I only report the number.

**4.6 Negative data, refutation, and "does not contradict".**
* **Refutation** is the likelihood-0 rule. Each true datum d refutes every theory that derives ¬d, so true data act as
  negative data for their negations.
* **Proposition 4.2 (proved): pure "does not contradict" learns nothing.**
  * Statement: if L(T; d) = μ₀(d)·[T ⊬ ¬d] with μ₀ independent of T, then the posterior is the prior restricted to
    data-compatible theories.
  * Proof: the likelihood is the same constant μ₀(D) for every compatible theory, and 0 otherwise.
  * Consequences: the empty theory and every weak compatible theory keep their prior ratio forever, and no axiom
    gains mass from data. Hänni's note asks for weight depending on "how many of the given statements can be proven".
    L_ε is the minimal model that does this.
  * Under L_ε a theory pays −log₂(εμ₀(d)) for data it does not derive. So it is credited for derivations and not
    killed by gaps.
* **Proposition 4.3 (proved): the size principle does not see inconsistency.** This is a statement about L1.
  * Statement:
    * Let T' = T ∪ {σ} with fixed weights, where a fraction w goes to σ.
    * Then P_{T'}(d) ≥ (1−w)^{c(d)}·P_T(d), with P_T the two-part (best-derivation) likelihood and c(d) the number
      of citations in d's best T-derivation.
    * With Dirichlet weights the cost of σ is at most its prior plus about ½log₂n, as in Prop. 4.1.
  * Proof: every T-derivation is a T'-derivation whose citations each lose a factor (1−w).
  * ∎
  * Consequence: adding a sentence that makes T inconsistent costs no more than adding a useless true sentence,
    unless derivations through the contradiction are what explains the data. Consistency must be enforced by
    refutation (negative data or a depth-bounded check), not by the size principle.

**Answer to question 4.**
* **Recovery.** From unlabelled Q+Ind data the posterior recovers Q+T_Ind, and puts almost all mass on it:
  * from n ≈ 100 with no negatives;
  * from n = 10 with two negatives.
  This is computed on a candidate set, not over all unions.
* **Competitors.**
  * Fragmentations and spare slots are the only competitors that survive. Both are deductively equivalent to PA.
  * The spare slot decays polynomially.
  * Fragmentation is held back by a prior margin. It gains only O(log n) when parts of the schema are never used.
* **Negative data.** These are what remove unsound lumps at small n, and in general the false templates of section 5.

---

## 5. Robust failures, and whether they are fixable

* **F1. Usage over logic** (section 1; computed).
  * What happens: the posterior identifies the *usage-closed* axiomatisation, not the textbook minimal one.
  * Fixable? It is not a bug of the method. The likelihood is right to prefer it. To recover "the textbook axioms"
    one must change the target, for example:
    * report the deductive equivalence class (theorem-level acceptance is unaffected); or
    * use a prior with strong pressure for independence.
  * More data does not help: the effect grows with n.
* **F2. Grammar misspecification produces fragmentation** (section 2; computed).
  * What happens: under NAIVE, PC, DPC or the context-free Q of H1, splitting T_Ind wins at a linear rate.
  * Fixable: a shared, positional grammar rich enough to condition on every feature a split could condition on.
    With it the split is held at the prior margin (SDPC, RDPC).
  * Not fully fixable: some feature can always be left out of the grammar. Then a template split pays off linearly
    if usage depends on that feature.
* **F3. Never-used parts of a schema** (sections 2.3 and 4.5; computed).
  * What happens: splits that exclude never-used parts win at rate (number of unused symbols)/2 · log₂n. This
    includes the Bayesian ω-gap for x+0=x.
  * At the level of theorems it is harmless under L1 if a non-atomic connective is covered (Prop. 2.2). The
    universal is a separate matter, left to the universal track.
  * Not fixable at the level of templates without a prior choice.
* **F4. False generalisations whose counterexamples are rare or absent in the data** (computed, `checks/c5_euler.py`,
  output `c5_euler.out`).
  * Setup:
    * Data: true sentences Prime(k·k+k+41), with k geometric(ρ) conditioned on primality. The false k are 40, 41,
      44, 49, 56, ….
    * H_sch is the template Prime(z·z+z+41): false.
    * H_mem memorises: true.
    * No finite union of unguarded templates covering these data is true without memorising. **Proof sketch**: a
      template covering infinitely many data needs a metavariable at or above a numeral position, so its instances
      include arbitrarily large numerals, or mismatched ones. Among them are values such as k = 41j, for which
      k²+k+41 is divisible by 41.
  * Results:
    * The posterior prefers the false schema by 3.5·10⁴ bits at n=100 and 2.1·10⁵ bits at n=10⁶ (ρ=0.9). The figure is
      1.2·10⁶ bits at n=10⁶ for ρ=0.97.
    * The memorising theory's prior grows with every new value of k, while the schema's extra cost is only the
      grammar's mass on false k.
    * With a depth-indexed (positional) grammar, the schema's predictive probability of the counterexample k=40 falls
      like 1/n (5.0·10⁻⁷ at n=10⁶). Yet H_sch still *entails* Prime(40·40+40+41), which is false.
  * The positive data do not expose the error at any n computed. The grammar absorbs the gap, and the theory keeps
    the false consequence.
    * Under the flat grammar the linear KL term (about 0.007 bits per datum for ρ=0.9) must eventually outweigh
      memorisation's prior, which grows like (log n)². That happens beyond n=10⁶. **Proof sketch.**
    * Under the depth-indexed grammar both costs grow like (log n)². The schema pays about ½log₂n per false k below
      the largest k seen. Memorisation pays about 30k bits per new value of k, a constant about 10³ times larger. So
      the false schema stays ahead. **Proof sketch** (constants estimated, not computed).
  * Not fixable from positive data. Fixable for this example by refutation: evaluate 40²+40+41 = 41². In general,
    refutation depth is unavoidable (`thm:many:depth`, **known**).
* **F5. Rarely used ground axioms are merged unsoundly at small n** (section 4; computed).
  * What happens: F₀+T_Ind beats Q+T_Ind at n = 10 and 30.
  * Fixable: one negative datum (0=S0) removes it, as does a little more data (crossover between n=30 and 100).
* **F6. Inconsistency is invisible to the size principle under L1** (Prop. 4.3; proved).
  * Fixable only by a consistency filter at growing depth. By `thm:many:depth` the filter's adequacy cannot be
    certified.
* **F7. No well-specified hypothesis for Th(ℕ)** (section 3; proved and computed).
  * What happens: the posterior drifts. Under 0/1 support every consistent theory is eventually refuted, while
    inconsistent ones survive without the filter.
  * Fixable in the sense of Prop. 3.3: L_ε with a regret guarantee. Not fixable as identification.
* **F8. Deductive strength beyond usage is not identified** (section 3; proof sketch).
  * What happens: IΣ₅ and PA are separated only by Con-type theorems at astronomical waiting times, or by the prior.
    DT° forces the L∞ (PA) choice.
  * Truth-safe in this chain. Unsafe where the stronger theory can be false (conversation §9).
* **F9. Computing the likelihood** (sections 0 and 1).
  * L1 needs derivation search. Shortest derivations are not computable in general, and the constants here are upper
    bounds.
  * Fixable only by bounding derivations (H1's bounded variant). That changes which theories look good: a deep
    theorem with no short proof is cheaper to add as an axiom. Under bounded search the posterior would treat cited
    deep results as axioms, as people do. Not computed.

**Overall answer to the user's question for PA and ZF.**
* A Bayesian axiom inducer with templates and a derivation likelihood does **not** robustly pick up the textbook
  axioms. It picks up the axioms that are *used*.
* It does robustly get a theory **deductively equivalent** to PA, with nearly all posterior mass, in the cases computed
  here:
  * clean Q+Ind usage data;
  * any usage mix of Ind, CVI and LNP;
  * either recursion convention;
  * splits by main connective.
* The robust failures concern **truth beyond the data**: false generalisations with rare counterexamples (F4),
  inconsistency (F6), and deductive strength beyond usage (F8). Only refutation fixes F4 and F6, and only up to a
  depth.

---

## 6. Verification log

| what | how | result |
|---|---|---|
| checker soundness (`nd.py`) | `test_nd.py`: 10 unsound steps; output `test_nd.out` | all 10 rejected (eigenvariable conditions on ∀I and ∃E, non-tautology, capture, mismatched substitution, wrong goal, open hypotheses, quantified atom in tc, wrong ∃I witness) |
| Prop 1.1 derivations A, B, C1, C2 | checked schematically in P; replayed on 200 random concrete motives with a parameter (seed 20261008) | all checked; 200/200 replays |
| Prop 1.4 (recursion conventions) | 4 derivations checked (`c1_costs.py`) | all checked |
| ZF derivations SepJ←ReplJ, Found←EInd, ReplK←Coll, ReplJ←Coll+SepJ | checked schematically (`c1_costs.py`, `zf.py`) | all checked. The checker found a capture bug in my SepJ constructor, now fixed; every schema constructor renames its binders |
| per-use costs, phase diagram, break-even, naive-code growth, cited base axioms | `c1_costs.py` → `c1_costs.out` (deterministic; naive part seed 7) | as quoted in section 1; growth per motive symbol ≈ β(K−1), within about 10% |
| reproduction of u7 | `c2_mdl.py` at n=1000 | NAIVE/PC/DPC identical to `tab:many:mdl` (−223/+2325/+2701; −915/+1141/+1428) |
| SDPC, RDPC, CF, used-roots split | `c2_mdl.py` → `c2_mdl.out`; `c2b_cf.py` → `c2b_cf.out` (seeds random.Random(n)) | section 2 table. A first SDPC version mis-coded the bound variable of ∀/∃ split bodies as a hole and showed a spurious growing margin; fixed by re-plugging the body (`plug(b, [H(0), V(0)])`), verified on an example |
| wrapper derivations | `c2_detour.py` → `c2_detour.out` | all six checked |
| toy drift | `c3_tower.py` → `c3_tower.out` (seed 1) | as quoted |
| Bayesian DTRC candidates and ∀-merge | `c4_bdtrc.py` → `c4_bdtrc.out` (seeds 11, 12) | as quoted. A first version coded bodies from a root context; the sound split then crossed the schema at n=1000 and back at 3000, an artefact. Replaced by the positional grammar |
| spare-slot formula (Prop 4.1) | closed form versus computed | 19.03 vs 19.0; 19.82 vs 19.8 |
| Euler example | `c5_euler.py` → `c5_euler.out` (seeds 5, 6); primality by trial division | as quoted |
| reproducibility | every script re-run from the final code; outputs diffed against the saved `*.out` | all 8 outputs byte-identical (test_nd, c1_costs, c2_mdl, c2b_cf, c2_detour, c3_tower, c4_bdtrc, c5_euler) |
| references | web search, no full texts | Zarach 1996 and Gitman–Hamkins–Johnstone 2016 (catalogue and abstract); Kaye–Wong 2007 (abstract); Shepherdson 1964 (secondary); IΣₙ ⇔ LΠₙ chain and PA ⊢ Con(IΣₙ) (secondary only). Not verified: Kaye 1991 and Hájek–Pudlák theorem numbers; Lévy 1979 and Jech 2003 locations; Shoenfield's substitution lemma location; Turing 1939 and Feferman 1962 (from memory). Whether ZF without Foundation proves Collection: not settled by the sources found |

**Refuted along the way** (kept, with the reason).
* "Under a shared grammar the root split loses by a growing margin on G1" (first SDPC run: +803, +953, +1504,
  +3475 and +12270 bits at n = 10³…2.56·10⁵). **Refuted**: it was an encoding artefact. The ∀/∃ split bodies coded
  the bound variable as hole h1 instead of v0. After re-plugging, the margin is constant (+770…+762).
* "The sound split of x+0=x by head symbol overtakes the schema at n=1000" (first c4 run: −12.5 bits, then +28.1 at
  n=3000). **Refuted**: an artefact of coding split bodies from a root context instead of their position. Under the
  positional grammar the split stays behind (+84.6 at n=1000) and closes in at a logarithmic rate.

**Not done, or open.**
* Shortest-derivation searches: all overheads are upper bounds.
* A formal derivation of Coll from Repl in ZF, or of EInd from Found.
* The posterior over *all* finite template unions (only candidate sets were scored).
* A full proof that reflection is not DT°-expressible.
* The per-use penalty of IΣₙ's single-sentence axiomatisation.
* Whether the mass of not-yet-filtered inconsistent theories vanishes (Remark 3.4).

